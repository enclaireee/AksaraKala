"""Story cinematics (wordless, opaque). cine_taken: the ruwatan night in Desa Purwa, Laras is taken, the village forgets.

World is painted on a 240x135 grid and shown 2x (so every pixel is 2 native px), lit by per-pixel Bayer-dithered
light bands and quantised palette shifts. The lontar strip is a foreground prop on the native 480x270 grid.
Beat map (seconds), exported as CINE_TAKEN_BEATS:
  0.00 night, lamp flickers gently       2.50 lamp starts to gutter, cold light creeps in
  2.80 puppet shadows warp               3.40 faceless shades step off the cloth, heads turn (3.5-4.2)
  4.50 LAMP OUT flash                    4.75 shadow hand reaches, 5.15 Laras seized and dragged
  6.30 Laras gone (ribbon blinks out)    6.50 dawn grey, scorched stage
  6.85 lontar strip rises, 7.30 name eaten, 8.30 strip blank, hold to 9.0"""
import math

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

from pxkit import *  # noqa: F403
from pxkit import BAYER4, load, scaled, text, aksara, m_eat, mask_sub, fill_mask, rgb, clamp, prog, ease_out, ease_io
from scenes import scene

WW, WH = 240, 135
T_GUT, T_WARP, T_SHADE, T_FLASH, T_ARM, T_SEIZE, T_GONE, T_DAWN = 2.5, 2.8, 3.4, 4.5, 4.75, 5.15, 6.3, 6.5
T_STRIP, T_EAT0, T_EAT1, DUR = 6.85, 7.3, 8.3, 9.0
CINE_TAKEN_BEATS = dict(gutter=T_GUT, flash=T_FLASH, arm=T_ARM, seized=T_SEIZE, laras_gone=T_GONE, dawn=T_DAWN,
                        strip=T_STRIP, erase_start=T_EAT0, erased=T_EAT1)

FLOOR = 100
INK = (22, 14, 28, 255)
SKIN = (206, 146, 104, 255)
SKIN_LO = (164, 106, 76, 255)
ROSE_B = (236, 64, 84, 255)
ROSE_HI = (255, 150, 150, 255)
YS, XS = np.mgrid[0:WH, 0:WW]
THR = (BAYER4[YS % 4, XS % 4] + 0.5) / 16.0


def A(n):
    return load(f"cutscene/{n}.png")


def strip_frames(img, n):
    fw = img.width // n
    return [img.crop((i * fw, 0, (i + 1) * fw, img.height)) for i in range(n)]


def hnoise(k):
    k = int(k) & 0xFFFFFFFF
    k = (k * 2654435761) & 0xFFFFFFFF
    k ^= k >> 13
    k = (k * 1274126177) & 0xFFFFFFFF
    return (k & 0xFFFF) / 65535.0


def band(L, n):
    v = np.clip(L, 0, 1) * n
    f = np.floor(v)
    return (f + ((v - f) > THR)) / n


def edge_ring(im, col=INK):
    a = np.array(im)
    al = a[..., 3] > 0
    p = np.pad(al, 1)
    grow = p[:-2, 1:-1] | p[2:, 1:-1] | p[1:-1, :-2] | p[1:-1, 2:]
    ring = grow & ~al
    a[ring] = col
    return Image.fromarray(a, "RGBA")


# ------------------------------------------------------------------ procedural back / side view people (game palette)
def person(w, h, shirt, sarong, hair, pose="back", bob=0, hat=None, ribbon=False, stand=False, pad=0, arm=None,
           skin=SKIN):
    """w x h figure drawn from behind (pose back) or in profile facing right (pose side). Returns (img, ribbon_px)."""
    W2 = w + 2 * pad
    im = Image.new("RGBA", (W2 + 2, h + 2), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    o = pad + 1
    cx = o + w // 2
    hr = 4 if w >= 16 else 3
    ty = 2 * hr
    legtop = h - (8 if not stand else 9)
    dark = tuple(int(c * 0.72) for c in shirt[:3]) + (255,)
    lite = tuple(min(255, int(c * 1.22)) for c in shirt[:3]) + (255,)
    # lower body
    if stand:
        d.rectangle([cx - 4, legtop + 1, cx - 1, h], fill=sarong)
        d.rectangle([cx + 1, legtop + 1, cx + 4, h], fill=sarong)
        d.rectangle([cx - 4, h, cx - 1, h], fill=skin)
        d.rectangle([cx + 1, h, cx + 4, h], fill=skin)
    else:
        d.ellipse([o, h - 8 + 1, o + w - 1, h], fill=sarong)
        d.line([o + 3, h - 4, o + w - 4, h - 4], fill=tuple(int(c * 0.78) for c in sarong[:3]) + (255,))
    # torso
    d.polygon([(o + 1, legtop + 2), (o + 2, ty + 2), (cx, ty + 1), (o + w - 3, ty + 2), (o + w - 2, legtop + 2)], fill=shirt)
    d.line([o + 3, ty + 3, o + 3, legtop], fill=lite)
    d.line([cx, ty + 4, cx, legtop + 1], fill=dark)
    d.line([o + w - 3, ty + 3, o + w - 3, legtop], fill=dark)
    d.rectangle([cx - 1, ty, cx + 1, ty + 1], fill=skin)
    # head
    hy = bob
    if pose == "back":
        d.ellipse([cx - hr, hy, cx + hr, hy + 2 * hr], fill=hair)
        d.point([(cx - hr, hy + hr + 1), (cx + hr, hy + hr + 1)], fill=skin)
        d.line([cx - 1, hy + 2 * hr, cx + 1, hy + 2 * hr], fill=skin)
        rb = (cx + hr - 1, hy + 1)
    else:
        d.ellipse([cx - hr, hy, cx + hr, hy + 2 * hr], fill=skin)
        d.ellipse([cx - hr - 1, hy - 1, cx + hr - 2, hy + 2 * hr - 1], fill=hair)
        d.rectangle([cx - hr, hy - 1, cx + hr - 1, hy + 1], fill=hair)
        d.point([(cx + hr - 1, hy + hr)], fill=(30, 18, 28, 255))
        d.point([(cx + hr + 1, hy + hr + 1)], fill=SKIN_LO)
        rb = (cx - hr + 1, hy + 1)
    if hat:
        d.rectangle([cx - hr, hy + 1, cx + hr - (1 if pose == "side" else 0), hy + 2], fill=hat)
        d.point([(cx - hr - 1 if pose == "back" else cx - hr - 1, hy + 2)], fill=hat)
    rpx = []
    if ribbon:
        bx, by = rb
        for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1), (-1, 0), (2, 1), (1, 2), (2, 3), (1, 3)):
            rpx.append((bx + dx, by + dy))
        for p in rpx:
            d.point([p], fill=ROSE_B)
        d.point([(bx, by)], fill=ROSE_HI)
    if arm == "up":
        sx, sy = o + w - 3, ty + 3
        d.line([sx, sy, sx + 4, sy - 5], fill=skin, width=1)
        d.line([sx + 1, sy, sx + 4, sy - 4], fill=skin, width=1)
        d.rectangle([sx + 4, sy - 7, sx + 5, sy - 5], fill=skin)
    elif arm == "out":
        sx, sy = o + w - 3, ty + 4
        d.line([sx, sy, sx + 5, sy - 3], fill=skin)
        d.line([sx, sy + 1, sx + 5, sy - 2], fill=skin)
    return edge_ring(im), [(x + 0, y + 0) for x, y in rpx]


def mirror(pair):
    im, rp = pair
    return im.transpose(Image.FLIP_LEFT_RIGHT), [(im.width - 1 - x, y) for x, y in rp]


# ------------------------------------------------------------------ hero (assets/art/hero_base.png, 32x32 cells)
_HB = None


def hero_cell(r, c):
    global _HB
    if _HB is None:
        _HB = load("hero_base.png")
    return _HB.crop((c * 32, r * 32, c * 32 + 32, r * 32 + 32))


def hero_seated(row, flip=False):
    cell = hero_cell(row, 0)
    bb = cell.getbbox()
    top = cell.crop((bb[0], bb[1], bb[2], bb[1] + 17))
    im = Image.new("RGBA", (top.width + 4, 24), (0, 0, 0, 0))
    im.alpha_composite(top, (2, 0))
    d = ImageDraw.Draw(im)
    sar, sar_hi = (122, 72, 52, 255), (150, 92, 62, 255)
    d.ellipse([0, 13, im.width - 1, 23], fill=sar)
    d.line([3, 16, im.width - 4, 16], fill=sar_hi)
    im = edge_ring(im)
    return im.transpose(Image.FLIP_LEFT_RIGHT) if flip else im


def hero_frame(row, col, flip=False):
    c = hero_cell(row, col)
    bb = c.getbbox()
    im = c.crop((0, bb[1], 32, bb[3]))
    return im.transpose(Image.FLIP_LEFT_RIGHT) if flip else im


# ------------------------------------------------------------------ static art + backdrop
class Art:
    def __init__(self):
        self.frame = A("kelir_frame")
        self.frame_b = A("kelir_frame_burned")
        self.cloth = A("kelir_cloth")
        self.cloth_b = A("kelir_cloth_burned")
        self.mat, self.mat_b = A("mat"), A("mat_burned")
        self.gong, self.gong_b = A("gong_ageng"), A("gong_ageng_burned")
        self.saron, self.saron_b = A("saron"), A("saron_burned")
        self.kend, self.kend_b = A("kendang"), A("kendang_burned")
        self.ng = strip_frames(A("niyaga_gong"), 3)
        self.ns = strip_frames(A("niyaga_saron"), 3)
        self.nk = A("niyaga_kendang")
        self.lamp = strip_frames(A("blencong"), 3)
        self.burst = strip_frames(A("lamp_burst"), 5)
        self.shade = [edge_ring(f, (8, 6, 14, 255)) if False else f for f in strip_frames(A("faceless_shade"), 4)]
        self.p = {n: A(f"puppet_{n}") for n in ("gunungan", "semar", "arjuna", "buto")}
        self.ember = strip_frames(A("ember"), 3)
        # scaled-tall shades (stretched, nearest) so they read as tall faceless shapes
        self.shade_t = [f.resize((18, 41), Image.NEAREST) for f in self.shade]
        self.laras = {}
        self.bg = self._backdrop()

    def _backdrop(self):
        im = Image.new("RGBA", (WW + 16, WH + 16), (0, 0, 0, 255))
        a = np.zeros((WH + 16, WW + 16, 3), dtype=np.uint8)
        rng = np.random.RandomState(4)
        # thatch wall behind the stage
        for y in range(0, 80):
            for x in range(WW + 16):
                v = 78 + (14 if (x + y // 3) % 5 == 0 else 0) - (10 if y % 6 == 0 else 0) - int(y * 0.15)
                a[y, x] = (v, int(v * 0.72), int(v * 0.5))
        # dirt courtyard
        for y in range(80, WH + 16):
            for x in range(WW + 16):
                n = rng.rand()
                v = 104 + (10 if n > 0.93 else 0) - (14 if n < 0.07 else 0)
                a[y, x] = (v, int(v * 0.74), int(v * 0.52))
        a[78:82, :] = (60, 44, 36)
        return Image.fromarray(a, "RGB").convert("RGBA")


ART = None


def laras_pose(name, bob=0):
    key = (name, bob)
    if key in ART.laras:
        return ART.laras[key]
    col = dict(shirt=(216, 224, 200, 255), sarong=(63, 140, 115, 255), hair=(58, 36, 24, 255))
    if name == "sit_back":
        r = person(12, 15, **col, pose="back", bob=bob, ribbon=True)
    elif name == "sit_side":
        r = person(12, 15, **col, pose="side", bob=bob, ribbon=True)
    elif name == "stand_back":
        r = person(12, 19, **col, pose="back", ribbon=True, stand=True)
    else:  # drag: side-on, arm thrown up toward her brother
        r = person(12, 19, **col, pose="side", ribbon=True, stand=True, pad=4, arm="up")
    ART.laras[key] = r
    return r


# ------------------------------------------------------------------ the scene
def cine_taken(dur=DUR):
    global ART
    if ART is None:
        ART = Art()
    a = ART

    adult_m = dict(shirt=(122, 62, 62, 255), sarong=(58, 42, 24, 255), hair=(34, 24, 28, 255), hat=(138, 48, 48, 255))
    adult_m2 = dict(shirt=(62, 92, 122, 255), sarong=(88, 58, 32, 255), hair=(34, 24, 28, 255), hat=(42, 92, 74, 255))
    adult_w = dict(shirt=(168, 70, 100, 255), sarong=(80, 52, 40, 255), hair=(30, 20, 26, 255))
    adult_w2 = dict(shirt=(60, 120, 120, 255), sarong=(92, 56, 36, 255), hair=(30, 20, 26, 255))
    child_a = dict(shirt=(232, 220, 192, 255), sarong=(150, 112, 56, 255), hair=(42, 28, 24, 255))
    crowd = [  # x, w, h, look dir (+1 turns to the right)
        (58, 18, 22, adult_m, -1), (76, 18, 22, adult_w, -1), (94, 12, 15, child_a, -1),
        (148, 18, 22, adult_m2, 1), (168, 18, 22, adult_w2, 1), (188, 18, 22, adult_m, 1),
    ]
    CR = []
    for i, (x, w, h, col, dr) in enumerate(crowd):
        CR.append(dict(x=x, w=w, h=h, col=col, dir=dr, t=3.55 + 0.11 * ((i * 5) % 6)))
    SHADE_X = (92, 120, 148)

    def render_world(t, burned):
        cam = min(int(t / 1.6), 5) if t < T_GONE else -6
        cx0, cy0 = 8, 8 - cam           # backdrop margin 8; camera creeps down the picture in 1px steps
        base = a.bg.crop((cx0 - 8 + 8, cy0, cx0 - 8 + 8 + WW, cy0 + WH)).copy()
        cover = Image.new("L", (WW, WH), 0)
        rims = []
        ox = oy = 0
        oy = 8 - cy0

        def P(img, x, y, cov=False, rim=True):
            x, y = int(x), int(y) + oy
            base.paste(img, (x, y), img)
            if cov:
                cover.paste(255, (x, y), img.split()[3])
            if rim:
                rims.append((img, x, y))

        # --- warm / cold state
        if t < T_GUT:
            n = hnoise(int(t * 12))
            I = 0.9 - 0.08 * (n > 0.6) - 0.04 * (hnoise(int(t * 5) + 9) > 0.7)
        elif t < T_FLASH:
            p = (t - T_GUT) / (T_FLASH - T_GUT)
            f = int(t * 16)
            mean = 0.85 - 0.62 * p ** 0.7
            dip = hnoise(f * 7 + 3) < 0.12 + 0.55 * p
            I = mean * (0.22 if dip else 0.85 + 0.15 * hnoise(f))
        else:
            I = 0.0
        I = round(I * 20) / 20
        pc = clamp((t - 2.6) / 1.2) if t < T_FLASH else (1.0 if t < T_DAWN else 0.0)
        pc = round(pc * 8) / 8
        dark = T_FLASH <= t < T_DAWN + 0.05
        lamp_xy = (120, 20)

        lampy = 9
        cloth_xy = (80, 16)
        # --- backdrop is already in base. kelir cloth + puppets (emissive, behind frame)
        cl = a.cloth_b if burned else a.cloth
        if burned:
            P(Image.new("RGBA", (80, 44), (30, 22, 30, 255)), *cloth_xy, rim=False)
        P(cl, *cloth_xy, rim=False)
        cloth_clip = Image.new("RGBA", (80, 44), (0, 0, 0, 0))
        if not burned:
            self_puppets(cloth_clip, t)
            P(cloth_clip, *cloth_xy, rim=False)
        fr = a.frame_b if burned else a.frame
        P(fr, 74, 6, cov=True)
        cover_after = len(rims)
        # --- gamelan
        P(a.gong_b if burned else a.gong, 22, 40, cov=True)
        P(a.saron_b if burned else a.saron, 184, 63, cov=True)
        P(a.kend_b if burned else a.kend, 213, 70, cov=True)
        if not burned and t < T_FLASH:
            fi = [0, 1, 2, 0][int(t * 3.2) % 4] if t < T_GUT + 0.3 else 0
            P(a.ng[fi], 40, 58, cov=True)
            P(a.ns[[0, 1, 2, 0][int(t * 3.2 + 1) % 4] if t < T_GUT + 0.3 else 0], 170, 59, cov=True)
            P(a.nk, 208, 58, cov=True)
        # --- mats
        for mx in (50, 70, 90, 108, 126, 148, 168, 188):
            P(a.mat_b if burned else a.mat, mx - 12 + (0), FLOOR - 10, cov=True, rim=False)

        out = dict(base=base, cover=cover, rims=rims, I=I, pc=pc, dark=dark, lamp_xy=lamp_xy, oy=oy)
        act = []  # (img, x, y) actors drawn over mats, with their own rim
        # --- audience
        if not burned:
            for k, c in enumerate(CR):
                turned = t >= c["t"]
                pose = "side" if turned else "back"
                bob = 1 if (int(t * 1.1 + k * 0.37) % 2 and not turned) else 0
                pair = person(c["w"], c["h"], pose=pose, bob=bob, **c["col"])
                im = pair[0]
                if turned and c["dir"] < 0:
                    im = im.transpose(Image.FLIP_LEFT_RIGHT)
                jolt = -1 if (turned and t < c["t"] + 0.12) else 0
                act.append((im, c["x"] - im.width // 2, FLOOR - im.height + 2 + jolt))
            # Laras + brother (drawn separately, moving)
            lp = laras_state(t)
            hp = hero_state(t)
            if lp:
                act.append(lp)
            if hp:
                act.extend(hp)
        else:
            hb = hero_frame(2, int(t * 1.6) % 6)
            act.append((hb, 128 - 16, FLOOR + 2 - hb.height))
        arims = []
        for im, x, y in act:
            P(im, x, y, cov=True, rim=False)
            arims.append((im, x, y + oy))
        out["arims"] = arims
        out["laras_ribbon"] = laras_ribbon(t) if (not burned) else []
        # --- shades (front of cloth)
        sh = []
        if not burned and T_SHADE <= t < T_GONE:
            for i, sx in enumerate(SHADE_X):
                t0 = T_SHADE + 0.18 * i
                pr = ease_out(prog(t, t0, 0.9))
                if pr <= 0:
                    continue
                by = lerp_(58, 74, pr)
                fi = int(t * 5 + i) % 4 if pr < 1 else int(t * 2.5 + i) % 4
                im = a.shade_t[fi]
                x = sx - 9
                # appears out of the cloth: dither reveal while rising
                if pr < 0.5:
                    m = np.array(im.split()[3])
                    thr = THR[:m.shape[0], :m.shape[1]]
                    m = np.where(thr <= pr * 2, m, 0).astype("uint8")
                    im = im.copy()
                    im.putalpha(Image.fromarray(m, "L"))
                sh.append((im, x, int(by) - im.height))
        out["shades"] = sh
        for im, x, y in sh:
            P(im, x, y, cov=True)
        # --- shadow hand
        out["arm"] = arm_poly(t) if not burned else None
        return out

    def lerp_(a0, b0, p):
        return a0 + (b0 - a0) * p

    def self_puppets(layer, t):
        # puppets in cloth-local coordinates (80x44)
        defs = [("semar", 12, 0.0, 1.3), ("gunungan", 40, 0.25, 0.0), ("arjuna", 58, 0.5, 2.1), ("buto", 70, 0.75, 1.7)]
        for k, (n, px, dl, sp) in enumerate(defs):
            img = a.p[n]
            w, h = img.size
            sway = 0
            if sp:
                sway = int(round(math.sin(t * sp + k) * (3 if n != "arjuna" else 5)))
            wp = clamp((t - (T_WARP + 0.1 * k)) / 0.8)
            wp = round(wp * 10) / 10
            gone = clamp((t - (3.75 + 0.08 * k)) / 0.35)
            if gone >= 1:
                continue
            kx, ky = 1 - 0.28 * wp, 1 + 1.35 * wp
            im = img if wp == 0 else img.resize((max(4, int(w * kx)), int(h * ky)), Image.NEAREST)
            arr = np.array(im)
            if wp > 0:  # melt-wobble: per-row horizontal shear growing toward the top
                for r in range(arr.shape[0]):
                    off = int(round(math.sin(r * 0.33 + t * 9 + k) * 2.2 * wp * (1 - r / arr.shape[0] + 0.2)))
                    arr[r] = np.roll(arr[r], off, axis=0)
            im = Image.fromarray(arr, "RGBA")
            if gone > 0:
                m = np.array(im.split()[3])
                thr = THR[:m.shape[0], :m.shape[1]]
                im = im.copy()
                im.putalpha(Image.fromarray(np.where(thr > gone, m, 0).astype("uint8"), "L"))
            bob = 0 if wp > 0 else (1 if int(t * 3 + k) % 2 and n in ("arjuna", "buto") else 0)
            layer.paste(im, (px + sway - im.width // 2, 43 - im.height - bob), im)

    # ---- Laras / hero / arm paths (world coords: feet baseline)
    def laras_x(t):
        if t < T_SEIZE:
            return 110
        return 110 - 70 * ease_io(prog(t, T_SEIZE, 1.1))

    def laras_state(t):
        if t >= T_GONE:
            return None
        if t < 4.0:
            pair = laras_pose("sit_back", 1 if int(t * 1.1) % 2 else 0)
            im = pair[0]
            return (im, 110 - im.width // 2, FLOOR + 2 - im.height)
        if t < T_SEIZE - 0.1:
            im = laras_pose("sit_side", 0)[0]
            return (im, 110 - im.width // 2, FLOOR + 2 - im.height)
        if t < T_SEIZE:
            im = laras_pose("stand_back")[0]
            return (im, 110 - im.width // 2, FLOOR + 2 - im.height - 1)
        im = laras_pose("drag")[0].transpose(Image.FLIP_LEFT_RIGHT)  # faces back toward her brother (right)
        im = laras_pose("drag")[0]
        x = laras_x(t)
        lift = 2 + int(abs(math.sin(t * 9)) * 2)
        y = FLOOR + 2 - im.height - lift - int(8 * prog(t, T_SEIZE, 1.1))
        # body dissolves into the dark, ribbon last
        pd_ = prog(t, 5.75, 0.45)
        if pd_ > 0:
            arr = np.array(im)
            m = arr[..., 3]
            thr = THR[:m.shape[0], :m.shape[1]]
            keep = thr > pd_
            rp = np.zeros(m.shape, bool)
            for (rx, ry) in laras_pose("drag")[1]:
                rp[ry, rx] = True
            arr[..., 3] = np.where(keep | rp, m, 0)
            im = Image.fromarray(arr, "RGBA")
        return (im, int(x) - im.width // 2, int(y))

    def laras_ribbon(t):
        """world coords of the ribbon pixels (drawn bright after lighting) while Laras is visible"""
        if t >= T_GONE:
            return []
        st = laras_state(t)
        if not st:
            return []
        im, x, y = st
        if t < 4.0:
            rp = laras_pose("sit_back", 1 if int(t * 1.1) % 2 else 0)[1]
        elif t < T_SEIZE - 0.1:
            rp = laras_pose("sit_side")[1]
        elif t < T_SEIZE:
            rp = laras_pose("stand_back")[1]
        else:
            rp = laras_pose("drag")[1]
        if t > T_GONE - 0.14 and int(t * 30) % 2:   # last blinks before it is gone
            return []
        return [(x + rx, y + ry) for rx, ry in rp]

    def hero_state(t):
        if t < 3.7:
            im = hero_seated(2)
            return [(im, 128 - im.width // 2, FLOOR + 2 - im.height)]
        if t < 4.9:
            im = hero_seated(1)
            return [(im, 128 - im.width // 2, FLOOR + 2 - im.height + (-1 if t < 3.85 else 0))]
        if t < 5.2:
            im = hero_frame(2, 0)
            return [(im, 128 - im.width // 2, FLOOR + 2 - im.height)]
        if t < 5.95:
            pr = prog(t, 5.2, 0.7)
            x = 128 - 22 * ease_out(pr)
            im = hero_frame(4, int((t - 5.2) * 9) % 6, flip=True)
            out = [(im, int(x) - im.width // 2, FLOOR + 2 - im.height - (1 if int(t * 9) % 2 else 0))]
            return out
        x = 128 - 22
        im = hero_frame(4, 1, flip=True)
        arm = Image.new("RGBA", (16, 6), (0, 0, 0, 0))
        d = ImageDraw.Draw(arm)
        d.line([15, 4, 3, 1], fill=SKIN)
        d.line([15, 5, 3, 2], fill=SKIN_LO)
        d.rectangle([0, 0, 3, 2], fill=SKIN)
        arm = arm.transpose(Image.FLIP_LEFT_RIGHT) if False else arm
        yb = FLOOR + 2 - im.height
        return [(im, int(x) - im.width // 2, yb), (arm, int(x) - 17, yb + 11)]

    def arm_poly(t):
        if not (T_ARM <= t < T_GONE):
            return None
        sh = (SHADE_X[0] - 6, 56)
        if t < T_SEIZE:
            p = ease_out(prog(t, T_ARM, 0.4))
            end = (sh[0] + (106 - sh[0]) * p + 0, sh[1] + (86 - sh[1]) * p)
        else:
            lx = laras_x(t)
            end = (lx + 2, FLOOR - 21 - 8 * prog(t, T_SEIZE, 1.1))
        if t > 5.9:
            end = (end[0], end[1])
        return sh, end

    SS_ = {}

    def draw_arm(c, ar, t, oy=0):
        if not ar:
            return
        (x0, y0), (x1, y1) = ar
        pts = []
        n = 28
        sag = 8 + 0.15 * abs(x1 - x0)
        mx, my = (x0 + x1) / 2 - 4, (y0 + y1) / 2 + sag
        for i in range(n + 1):
            u = i / n
            px = (1 - u) ** 2 * x0 + 2 * (1 - u) * u * mx + u * u * x1
            py = (1 - u) ** 2 * y0 + 2 * (1 - u) * u * my + u * u * y1
            pts.append((px * 2, py * 2 + oy * 2))
        d = ImageDraw.Draw(c)
        for i in range(n):
            wd = int(round(9 - 5 * i / n))
            d.line([pts[i], pts[i + 1]], fill=(40, 26, 66, 255), width=wd)
        ex, ey = pts[-1]
        for k, ang in enumerate((-0.9, -0.4, 0.1, 0.6, 1.0)):
            L = 11 + 4 * (k % 2)
            d.line([(ex, ey), (ex - L * math.cos(ang), ey + L * math.sin(ang) * 1.0)], fill=(18, 10, 26, 255), width=2)
        # rim along the top of the arm
        for i in range(0, n, 2):
            d.point([(pts[i][0], pts[i][1] - 4 + int(3 * i / n))], fill=(120, 104, 200, 255))

    # ---------------------------------------------------------------- lighting
    def light(w, t, burned):
        base = np.array(w["base"]).astype(np.float32)[..., :3]
        I, pc = w["I"], w["pc"]
        lx, ly = w["lamp_xy"][0], w["lamp_xy"][1] + w["oy"]
        d = np.hypot(XS - lx, (YS - ly) * 1.05)
        Lw = band(I * np.clip(1 - d / 150, 0, 1) ** 1.1, 6)
        cxx, cyy = 120, 52 + w["oy"]
        dc = np.hypot(XS - cxx, (YS - cyy) * 1.1)
        cI = 0.9 * pc if not w["dark"] else 0.85
        if burned or t >= T_DAWN:
            cI = 0.0
        Lc = band(cI * np.clip(1 - dc / 125, 0, 1) ** 1.0, 6)
        amb = np.array([0.40, 0.35, 0.50]) * (1 - pc) + np.array([0.27, 0.27, 0.55]) * pc
        if w["dark"]:
            amb = np.array([0.075, 0.065, 0.14])
        M = amb[None, None, :] + Lw[..., None] * np.array([1.05, 0.72, 0.40]) + Lc[..., None] * np.array([0.34, 0.26, 0.78])
        # emissive cloth (anything in the cloth opening not overdrawn by a front object)
        em = np.zeros((WH, WW), bool)
        oy = w["oy"]
        em[16 + oy:60 + oy, 80:160] = True
        em &= np.array(w["cover"]) == 0
        warmE = np.array([1.02, 0.88, 0.62]) * (0.42 + 0.58 * I)
        coldE = np.array([0.52, 0.44, 0.98]) * 0.95
        ce = warmE * (1 - pc) + coldE * pc
        if w["dark"]:
            ce = np.array([0.34, 0.26, 0.62])
        if burned:
            ce = np.array([0.78, 0.8, 0.9])
        M = np.where(em[..., None], ce[None, None, :], M)
        # dawn: grey light wipes in from the top, dithered
        if t >= T_DAWN:
            pd_ = prog(t, T_DAWN, 0.9)
            grey = np.array([0.70, 0.72, 0.84])[None, None, :] * (1.0 - 0.18 * band(YS / WH, 4))[..., None]
            wipe = np.clip((YS / WH) * 0.55 + THR * 0.45, 0, 1)
            Md = np.where((wipe <= pd_ * 1.0)[..., None], grey, np.array([0.045, 0.04, 0.085])[None, None, :])
            M = np.where(em[..., None], np.where((wipe <= pd_)[..., None], grey * 1.05, np.array([0.14, 0.12, 0.26])), Md)
        # vignette (dithered bands)
        r = np.hypot((XS - 120) / 150.0, (YS - 62) / 100.0)
        M = M * (1 - 0.45 * band(np.clip((r - 0.55) / 0.7, 0, 1), 4))[..., None]
        if t >= T_DAWN:
            g = base.mean(axis=2, keepdims=True)
            base = base * 0.4 + g * 0.6
        out = np.clip(base * M, 0, 255)
        return Image.fromarray(out.astype("uint8"), "RGB").convert("RGBA")

    def rim_pass(c, w, col=(118, 104, 196, 255), full=True, key="rims"):
        for im, x, y in w[key]:
            al = np.array(im.split()[3]) > 0
            p = np.pad(al, ((1, 0), (1, 0)))
            top = al & ~p[:-1, 1:]
            left = al & ~p[1:, :-1]
            rcol = col
            rm = top | (left & (np.add.outer(np.arange(al.shape[0]), np.arange(al.shape[1])) % 2 == 0))
            if not full:
                rm &= (np.add.outer(np.arange(al.shape[0]), np.arange(al.shape[1])) % 2 == 0)
            if not rm.any():
                continue
            cl = np.zeros(al.shape + (4,), np.uint8)
            cl[rm] = rcol
            ci = Image.fromarray(cl, "RGBA")
            c.paste(ci, (x, y), ci)

    # ---------------------------------------------------------------- lontar strip (native 480x270)
    SW, SH = 300, 46
    strip = Image.new("RGBA", (SW, SH), (0, 0, 0, 0))
    sd = ImageDraw.Draw(strip)
    body, body_hi, body_lo, edge = (208, 172, 108, 255), (226, 192, 128, 255), (170, 132, 80, 255), (96, 66, 40, 255)
    sd.rectangle([0, 3, SW - 1, SH - 4], fill=body)
    for gy in range(8, SH - 6, 5):
        sd.line([2, gy, SW - 3, gy], fill=body_lo)
    for gy in range(10, SH - 6, 11):
        sd.line([6, gy, SW - 8, gy], fill=body_hi)
    sd.rectangle([0, 3, SW - 1, 4], fill=edge)
    sd.rectangle([0, SH - 5, SW - 1, SH - 4], fill=edge)
    for k in range(6):   # ragged leaf ends
        sd.rectangle([0, 3 + k * 9 + (k % 2) * 2, 1 + (k % 3), 6 + k * 9], fill=(0, 0, 0, 0))
        sd.rectangle([SW - 2 - (k % 3), 3 + k * 9, SW - 1, 6 + k * 9 + (k % 2) * 2], fill=(0, 0, 0, 0))
    for hx in (26, SW - 27):
        sd.ellipse([hx - 3, SH // 2 - 3, hx + 3, SH // 2 + 3], fill=(40, 28, 24, 255))
    sd.line([26, SH // 2, SW - 27, SH // 2 + 0], fill=(0, 0, 0, 0))
    strip = edge_ring(strip, (30, 20, 24, 255))
    INKC = (62, 36, 28, 255)
    CORRUPT = (92, 58, 130, 255)
    SUNDA_LARAS = "ᮜᮛᮞ᮪"

    def strip_layer(t):
        c = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        if t < T_STRIP:
            return c
        pr = ease_out(prog(t, T_STRIP, 0.5))
        pr = round(pr * 8) / 8
        sy = int(H + 4 - pr * (H - 210))   # rises from below the frame
        sx = (W - strip.width - 2) // 2
        # soft pixel shadow
        shd = Image.new("RGBA", strip.size, (0, 0, 0, 0))
        shd.paste((8, 6, 14, 255), (0, 0), strip.split()[3])
        sh2 = np.array(shd)
        sh2[..., 3] = np.where(np.add.outer(np.arange(sh2.shape[0]), np.arange(sh2.shape[1])) % 2 == 0, sh2[..., 3], 0)
        c.alpha_composite(Image.fromarray(sh2, "RGBA"), (sx + 3, sy + 4))
        c.alpha_composite(strip, (sx, sy))
        pe = prog(t, T_EAT0, T_EAT1 - T_EAT0)
        pe = pe if pe < 1 else 1.0
        if pe < 1:
            def eat(m, seed):
                return m_eat(pe, seed=seed, bias=0.55, steps=14)(m)

            def ring(m, seed):
                return mask_sub(m_eat(max(0.0, pe - 0.1), seed=seed, bias=0.55, steps=14)(m), m_eat(pe, seed=seed, bias=0.55, steps=14)(m)) if pe > 0 else Image.new("L", m.size, 0)

            cy = sy + 3
            text(c, "LARAS", W // 2, cy, ("j10", 40), INKC, "c", mod=lambda m: eat(m, 3))
            text(c, "LARAS", W // 2, cy, ("j10", 40), CORRUPT, "c", mod=lambda m: ring(m, 3))
            ak = None
            if ak is not None:
                aksara_draw(c, ak, W // 2, sy + 37, lambda m: eat(m, 7), INKC)
                aksara_draw(c, ak, W // 2, sy + 37, lambda m: ring(m, 7), CORRUPT)
        return c

    def aksara_mask_(s):
        from pxkit import aksara_mask
        m = aksara_mask(s, "sunda", 18)
        return m if m.width > 3 else None

    def aksara_draw(c, m, cx, cy, mod, col):
        mm = mod(m)
        fill_mask(c, mm, int(cx - m.width // 2), int(cy - m.height // 2), col)

    # ---------------------------------------------------------------- frame
    def fn(t):
        burned = t >= T_GONE
        w = render_world(t, burned)
        # arm is drawn into the base pre-light (it is a shadow): in 2x space after lighting instead
        lit = light(w, t, burned)
        oy = w["oy"]
        if w["dark"] and t < T_GONE:
            rim_pass(lit, w)
        elif not burned and w["I"] > 0.1:
            rim_pass(lit, w, (255, 176, 100, 255) if w["pc"] < 0.6 else (170, 130, 230, 255), w["I"] > 0.55, key="arims")
        # emissive: lamp, fireflies, ribbon, embers
        if t < T_FLASH and not burned:
            fl = a.lamp[int(t * 9) % 3].copy()
            arr = np.array(fl)
            I = w["I"]
            lenf = max(0, min(10, int(I * 11)))
            for y in range(2, 12):
                for x in range(14):
                    px = arr[y, x]
                    if px[3] and px[0] > 200 and px[2] < 190 and y < 12 - lenf:
                        arr[y, x] = (0, 0, 0, 0)
            fl = Image.fromarray(arr, "RGBA")
            lit.paste(fl, (113, 9 + oy), fl)
            lit.paste(INK[:3], (119, 5 + oy, 120, 9 + oy)) if False else None
            if t < T_GUT:
                pass
        elif not burned:
            fl = a.lamp[0].copy()
            arr = np.array(fl)
            m = (arr[..., 3] > 0) & (arr[..., 0] > 200) & (arr[..., 2] < 190)
            arr[m] = (0, 0, 0, 0)
            arr[..., :3] = (arr[..., :3] * 0.22).astype("uint8")
            fl = Image.fromarray(arr, "RGBA")
            lit.paste(fl, (113, 9 + oy), fl)
        if t < T_FLASH + 0.05 and not burned:
            fireflies(lit, t)
        if burned and t > T_DAWN + 0.6:
            embers_(lit, t)
        c = lit.resize((W, H), Image.NEAREST)
        # shadow arm (native res, so its pixels are 2px like the rest)
        if not burned and w["arm"]:
            draw_arm(c, w["arm"], t, oy)
        # ribbon: emissive, always on top, never darkened
        d = ImageDraw.Draw(c)
        for (rx, ry) in w["laras_ribbon"]:
            col = ROSE_HI if (rx + ry) % 5 == 0 else ROSE_B
            d.rectangle([rx * 2, ry * 2 + oy * 2, rx * 2 + 1, ry * 2 + oy * 2 + 1], fill=col)
        # hard lamp-out flash
        if T_FLASH <= t < T_FLASH + 0.16:
            k = t - T_FLASH
            if k < 0.034:
                c.paste((255, 244, 230, 255), (0, 0, W, H))
            elif k < 0.1:
                f = a.burst[1 if k < 0.067 else 2]
                big = scaled(f, 5)
                chk = Image.fromarray((np.add.outer(np.arange(H), np.arange(W)) % 2 == 0).astype("uint8") * 255, "L")
                c.paste((255, 226, 170, 255), (0, 0, W, H), chk)
                c.alpha_composite(big, (240 - big.width // 2, 40 - big.height // 2 + oy * 2))
            else:
                f = a.burst[3]
                big = scaled(f, 6)
                c.alpha_composite(big, (240 - big.width // 2, 40 - big.height // 2 + oy * 2))
        c.alpha_composite(strip_layer(t))
        # dither fade in from black / nothing at the end (hold on blank strip)
        if t < 0.35:
            c = dither_fade(c, NIGHT, 1 - t / 0.35)
        return c.convert("RGB").convert("RGBA")

    FF = [(hnoise(i * 3 + 1), hnoise(i * 3 + 2), hnoise(i * 3 + 3)) for i in range(9)]

    def fireflies(c, t):
        fade = 1.0 if t < T_GUT else max(0.0, 1 - (t - T_GUT) / 1.2)
        if fade <= 0:
            return
        d = ImageDraw.Draw(c)
        for i, (a1, a2, a3) in enumerate(FF):
            if a3 > fade:
                continue
            x = 20 + a1 * 200 + math.sin(t * (0.6 + a2) + i) * 12
            y = 82 + a2 * 40 + math.cos(t * (0.5 + a1) + i * 2) * 8
            if int(t * 3 + i * 1.7) % 4 == 3:
                continue
            d.point([(int(x), int(y))], fill=(255, 236, 130, 255))
            if int(t * 3 + i) % 2:
                d.point([(int(x) + 1, int(y))], fill=(150, 130, 60, 255))

    def embers_(c, t):
        d = ImageDraw.Draw(c)
        for i in range(10):
            x = 60 + hnoise(i * 5 + 1) * 120
            y = 74 - ((t * (3 + hnoise(i)) + hnoise(i * 7) * 30) % 22) + 20 * hnoise(i * 3)
            if hnoise(int(t * 4) + i * 9) > 0.45:
                d.point([(int(x), int(y))], fill=(240, 120, 50, 255))
        for i in range(8):   # ash drifting up
            x = 30 + hnoise(i * 11 + 4) * 180 + math.sin(t + i) * 3
            y = 120 - ((t * 4 + hnoise(i * 13) * 80) % 90)
            d.point([(int(x), int(y))], fill=(150, 150, 164, 255))

    return fn


@scene("cine_taken", DUR, False)
def _cine_taken(dur=DUR):
    return cine_taken(dur)
