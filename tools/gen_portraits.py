#!/usr/bin/env python3
"""Aksara Kala hero big art (v2, 2026-11-12 redesign): the class-select figures and the hero's dialogue busts.

Outputs
  assets/art/portraits/class_<id>.png      576x128, 6 idle frames of 96x128 (ui/class_select.gd, Status tab)
  assets/art/portraits/p_hero_<id>[_mood].png  48x48 busts, moods happy / angry / sad (ui/portraits.gd)
  tools/portraits_preview.png
for the 8 classes of .docs/classes.md: warrior, lancer, archer, herder, rogue, dancer, mage, dalang.

One painter draws both: the figure is built from rounded forms (ellipses, tapered capsules, lathe-shaded
trapezoids) lit from the top-left and cut to 4 tones per material, so the big art is clean cel shading with no
dither. The bust is the same figure drawn 1.7x larger and cropped to the head and shoulders, so the face in a
dialogue is the hero you picked. The in-world sprites (tools/gen_hero_sprites.py) use the same dress and colours.
Run: python3 tools/gen_portraits.py
"""
import math
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pilite
pilite.install()
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUTDIR = os.path.join(ROOT, "assets", "art", "portraits")
FW, FH, FRAMES = 96, 128, 6
OUTLINE = (26, 16, 32, 255)
CLASS_IDS = ["warrior", "lancer", "archer", "herder", "rogue", "dancer", "mage", "dalang"]
MOODS = ["", "happy", "angry", "sad"]


def hexc(s):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), 255)


def mix(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3)) + (255,)


def mat(h, deep=None, dark=None, light=None):
    """(deep, dark, mid, light): shadows lean to plum, lights to warm paper."""
    m = hexc(h)
    dk = hexc(dark) if dark else mix(mix(m, (0, 0, 0, 255), 0.26), (64, 34, 86, 255), 0.2)
    dp = hexc(deep) if deep else mix(mix(m, (0, 0, 0, 255), 0.55), (40, 20, 56, 255), 0.3)
    lt = hexc(light) if light else mix(m, (255, 240, 208, 255), 0.36)
    return (dp, dk, m, lt)


SKIN = mat("C2814F", "5E2E2A", "94553A", "E6AE7C")
HAIR = mat("2E2634", "120E18", "1E1824", "55485E")
STEEL = mat("AAB6BE", "3E4654", "6E7A88", "F0F5F2")
GOLD = mat("D2A446", "5E3E1C", "9A6E2A", "FAE08A")
WOOD = mat("7C5432", "2E1C16", "523422", "AC7E4C")
WHITE = mat("EFE8D8", "6E6474", "B8AEA8", "FFFFFF")
RED = mat("C0382E")
EYE = hexc("1A1018")

STYLE = {
    "warrior": dict(top=SKIN, low=mat("A62E28", light="CC4A3A"), sash=mat("3C2822"), gear=mat("C83A2E"), sleeve=0, legs="kain", fx=hexc("FFB070")),
    "lancer": dict(top=mat("C43A30"), low=mat("E6DEC8"), sash=mat("2C2632"), gear=mat("302A36"), sleeve=2, legs="pants", extra=mat("3A4A82"), fx=hexc("FFE0A0")),
    "archer": dict(top=mat("2F6E54"), low=mat("6C4C32"), sash=mat("80C4A2"), gear=mat("A2703E"), sleeve=2, legs="pants", extra=mat("C4A256"), fx=hexc("BFF5D8")),
    "herder": dict(top=mat("E2D6B0"), low=mat("8C6C46"), sash=mat("6C4C2C"), gear=mat("DEBC6C"), sleeve=0, legs="short", extra=mat("3E5E90"), fx=hexc("F4E8C8")),
    "rogue": dict(top=mat("3C3846"), low=mat("302C3A"), sash=mat("C43A2E"), gear=mat("36323F"), sleeve=2, legs="pants", fx=hexc("FF9080")),
    "dancer": dict(top=mat("BA326C"), low=mat("704C30"), sash=GOLD, gear=GOLD, sleeve=0, legs="kain", extra=mat("30A89A"), fx=hexc("FFE08A")),
    "mage": dict(top=mat("E8D6A8"), low=mat("E8D6A8"), sash=mat("3F8C74"), gear=GOLD, sleeve=2, legs="robe", extra=mat("B28E56"), fx=hexc("7FF0DC")),
    "dalang": dict(top=mat("2F3B68"), low=mat("7C5634"), sash=mat("AA783C"), gear=mat("7C5634"), sleeve=2, legs="kain", extra=RED, fx=hexc("FFC860")),
}


# ---------------------------------------------------------------- painter
class Paint:
    def __init__(self, w, h, k=1.0, ox=0.0, oy=0.0):
        self.w, self.h, self.k, self.ox, self.oy = w, h, k, ox, oy
        self.pix = {}
        self.soft = set()

    def _box(self, x0, y0, x1, y1):
        k = self.k
        return (max(0, int(x0 * k + self.ox) - 1), max(0, int(y0 * k + self.oy) - 1),
                min(self.w - 1, int(x1 * k + self.ox) + 1), min(self.h - 1, int(y1 * k + self.oy) + 1))

    def region(self, fn, box):
        out = {}
        x0, y0, x1, y1 = self._box(*box)
        for py in range(y0, y1 + 1):
            fy = (py + 0.5 - self.oy) / self.k
            for px_ in range(x0, x1 + 1):
                r = fn((px_ + 0.5 - self.ox) / self.k, fy)
                if r is not None:
                    out[(px_, py)] = r
        return out

    def shade(self, reg, m, clip=None, rim=True, lift=0.0):
        """Paints a region by its normals. Returns the set of pixels painted."""
        done = set()
        for (x, y), (nx, ny) in reg.items():
            if clip is not None and (x, y) not in clip:
                continue
            edge = rim and any((x + dx, y + dy) not in reg for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
            if edge:
                c = m[0]
            else:
                nz = math.sqrt(max(0.0, 1.0 - nx * nx - ny * ny))
                i = -0.52 * nx - 0.6 * ny + 0.52 * nz + lift
                c = m[3] if i > 0.66 else (m[2] if i > 0.12 else m[1])
            self.pix[(x, y)] = c
            self.soft.discard((x, y))
            done.add((x, y))
        return done

    # shapes -------------------------------------------------------------
    def ell(self, cx, cy, rx, ry, m, **kw):
        def fn(x, y):
            nx, ny = (x - cx) / rx, (y - cy) / ry
            return (nx, ny) if nx * nx + ny * ny <= 1.0 else None
        return self.shade(self.region(fn, (cx - rx, cy - ry, cx + rx, cy + ry)), m, **kw)

    def cap(self, ax, ay, bx, by, ra, rb, m, **kw):
        dx, dy = bx - ax, by - ay
        L = dx * dx + dy * dy or 1e-6

        def fn(x, y):
            t = max(0.0, min(1.0, ((x - ax) * dx + (y - ay) * dy) / L))
            r = ra + (rb - ra) * t
            ex, ey = x - (ax + dx * t), y - (ay + dy * t)
            return (ex / r, ey / r) if ex * ex + ey * ey <= r * r else None
        r = max(ra, rb)
        return self.shade(self.region(fn, (min(ax, bx) - r, min(ay, by) - r, max(ax, bx) + r, max(ay, by) + r)), m, **kw)

    def trap(self, rows, m, bend=0.92, **kw):
        """A lathe-shaded band: rows is [(y, x_left, x_right), ...] top to bottom."""
        def fn(x, y):
            if y < rows[0][0] or y > rows[-1][0]:
                return None
            for (y0, l0, r0), (y1, l1, r1) in zip(rows, rows[1:]):
                if y0 <= y <= y1:
                    t = (y - y0) / ((y1 - y0) or 1e-6)
                    l, r = l0 + (l1 - l0) * t, r0 + (r1 - r0) * t
                    if l <= x <= r:
                        return (((x - (l + r) / 2) / ((r - l) / 2 or 1e-6)) * bend, -0.12)
                    return None
            return None
        return self.shade(self.region(fn, (min(r[1] for r in rows), rows[0][0], max(r[2] for r in rows), rows[-1][0])), m, **kw)

    def poly(self, pts, c, clip=None):
        """A flat polygon in one colour."""
        def fn(x, y):
            inside = False
            n = len(pts)
            for i in range(n):
                (x0, y0), (x1, y1) = pts[i], pts[(i + 1) % n]
                if (y0 > y) != (y1 > y) and x < x0 + (x1 - x0) * (y - y0) / (y1 - y0):
                    inside = not inside
            return (0.0, 0.0) if inside else None
        reg = self.region(fn, (min(p[0] for p in pts), min(p[1] for p in pts), max(p[0] for p in pts), max(p[1] for p in pts)))
        for k_ in reg:
            if clip is None or k_ in clip:
                self.pix[k_] = c
                self.soft.discard(k_)
        return set(reg)

    def line(self, pts, c, w=1.0, clip=None):
        """A stroke through pts, w figure units wide."""
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            n = int(max(abs(x1 - x0), abs(y1 - y0)) * self.k * 2) + 1
            for i in range(n + 1):
                t = i / n
                x, y = (x0 + (x1 - x0) * t) * self.k + self.ox, (y0 + (y1 - y0) * t) * self.k + self.oy
                r = max(0.0, (w * self.k - 1.0) / 2.0)
                for py in range(int(y - r), int(y + r) + 1):
                    for px_ in range(int(x - r), int(x + r) + 1):
                        if 0 <= px_ < self.w and 0 <= py < self.h and (clip is None or (px_, py) in clip):
                            self.pix[(px_, py)] = c
                            self.soft.discard((px_, py))

    def dot(self, x, y, c, clip=None):
        self.line([(x, y), (x, y)], c, 1.0, clip)

    def glow(self, cx, cy, r, c, strength=1.0):
        x0, y0, x1, y1 = self._box(cx - r, cy - r, cx + r, cy + r)
        for py in range(y0, y1 + 1):
            for px_ in range(x0, x1 + 1):
                d = math.hypot((px_ + 0.5 - self.ox) / self.k - cx, (py + 0.5 - self.oy) / self.k - cy)
                if d <= r and ((px_, py) not in self.pix or (px_, py) in self.soft):
                    a = int(170 * strength * (1.0 - d / r) ** 1.3)
                    if a > 22:
                        old = self.pix.get((px_, py))
                        self.pix[(px_, py)] = c[:3] + (max(a, old[3] if old else 0),)
                        self.soft.add((px_, py))

    def image(self, bg=None):
        img = Image.new("RGBA", (self.w, self.h), bg or (0, 0, 0, 0))
        solid = {k_ for k_ in self.pix if k_ not in self.soft}
        for k_ in self.soft:
            c = self.pix[k_]
            if bg:
                a = c[3] / 255.0
                c = tuple(int(c[i] * a + bg[i] * (1 - a)) for i in range(3)) + (255,)
            img.putpixel(k_, c)
        for (x, y) in solid:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                k_ = (x + dx, y + dy)
                if k_ not in solid and 0 <= k_[0] < self.w and 0 <= k_[1] < self.h:
                    img.putpixel(k_, OUTLINE)
        for k_ in solid:
            img.putpixel(k_, self.pix[k_])
        return img


# ---------------------------------------------------------------- weapons and props
def blade(p, x0, y0, x1, y1, w, curve=0.0):
    """A steel blade from the guard (x0, y0) to the tip (x1, y1)."""
    dx, dy = x1 - x0, y1 - y0
    L = math.hypot(dx, dy)
    ux, uy = dx / L, dy / L
    nx, ny = -uy, ux
    pts_a, pts_b = [], []
    for i in range(9):
        t = i / 8.0
        bend = math.sin(t * math.pi) * curve
        half = w / 2 * (1.0 if t < 0.7 else (1.0 - (t - 0.7) / 0.3) * 0.9 + 0.1)
        cx, cy = x0 + dx * t + nx * bend, y0 + dy * t + ny * bend
        pts_a.append((cx + nx * half, cy + ny * half))
        pts_b.append((cx - nx * half, cy - ny * half))
    p.poly(pts_a + pts_b[::-1], STEEL[2])
    p.line(pts_a, STEEL[3], 1.0)
    p.line(pts_b, STEEL[1], 1.0)
    p.line([((a[0] + b[0]) / 2, (a[1] + b[1]) / 2) for a, b in zip(pts_a[:7], pts_b[:7])], STEEL[1], 1.0)


def fan(p, hx, hy, ang, r, S, spread=58):
    """An open fan from the hand at (hx, hy), pointing along ang (degrees, y down)."""
    pts = [(hx, hy)]
    for a in range(-spread, spread + 1, 6):
        pts.append((hx + math.cos(math.radians(ang + a)) * r, hy + math.sin(math.radians(ang + a)) * r))
    p.poly(pts, S["top"][2])
    for i, a in enumerate(range(-spread, spread + 1, 2 * spread // 5)):
        ex, ey = hx + math.cos(math.radians(ang + a)) * r, hy + math.sin(math.radians(ang + a)) * r
        p.line([(hx, hy), (ex, ey)], GOLD[1] if i % 2 else GOLD[2], 1.0)
    rim = [(hx + math.cos(math.radians(ang + a)) * r, hy + math.sin(math.radians(ang + a)) * r) for a in range(-spread, spread + 1, 4)]
    p.line(rim, GOLD[3], 1.6)
    mid = [(hx + math.cos(math.radians(ang + a)) * r * 0.62, hy + math.sin(math.radians(ang + a)) * r * 0.62) for a in range(-spread + 8, spread - 7, 4)]
    p.line(mid, S["top"][3], 1.0)
    p.ell(hx, hy, 1.4, 1.4, GOLD)


# ---------------------------------------------------------------- the figure
def figure(p, cid, frame=0, mood="", bust=False):
    S = STYLE[cid]
    top, low, sash, gear = S["top"], S["low"], S["sash"], S["gear"]
    b = (0, 0, 1, 1, 1, 0)[frame]                 # breath
    sw = (0.0, 0.8, 1.2, 0.6, -0.6, -1.0)[frame]  # cloth sway
    pulse = (0.6, 0.8, 1.0, 0.9, 0.7, 0.5)[frame]
    blink = frame == 4 and not bust
    hx, hy = 48.0, 22.0 + b
    shl, shr = (36.5, 41.5 + b), (59.5, 41.5 + b)

    # ---- arm plan: (elbow, hand) for the screen-left (weapon) arm and the screen-right arm
    arms = {
        "warrior": (((30.5, 54 + b), (28.5, 66 + b)), ((66, 53 + b), (63, 62 + b))),
        "lancer": (((30, 52 + b), (27.5, 60 + b)), ((66.5, 53 + b), (60.5, 63 + b))),
        "archer": (((29.5, 52 + b), (26.5, 60 + b)), ((66.5, 53 + b), (60.5, 63 + b))),
        "herder": (((31, 54 + b), (29.5, 66 + b)), ((66.5, 53 + b), (60.5, 63 + b))),
        "rogue": (((29, 53 + b), (31, 43 + b)), ((67, 52 + b), (66.5, 63 + b))),
        "dancer": (((27.5, 46 + b), (21.5, 37 + b)), ((67, 53 + b), (71, 63 + b))),
        "mage": (((30, 52 + b), (27.5, 60 + b)), ((67.5, 51 + b), (68, 41 + b))),
        "dalang": (((30, 52 + b), (27.5, 60 + b)), ((67.5, 51 + b), (68, 41 + b))),
    }[cid]

    # ---- behind the body
    if cid == "archer":      # bamboo quiver over the right shoulder
        p.cap(63, 27 + b, 68, 52 + b, 3.6, 3.2, S["extra"])
        for i, col in enumerate((WHITE[2], RED[2], WHITE[2])):
            p.line([(61.5 + i * 2.2, 26 + b), (60.5 + i * 2.4, 18 + b)], WOOD[2], 1.0)
            p.poly([(60 + i * 2.4, 16 + b), (62.6 + i * 2.4, 17 + b), (62.4 + i * 2.2, 22 + b), (60.6 + i * 2.2, 22 + b)], col)
    elif cid == "rogue":     # headwrap tails streaming to the right
        for j, (dy, m) in enumerate(((0, sash), (3, sash))):
            p.cap(57, 17 + b + dy, 67 + sw, 27 + b + dy * 2, 2.2, 1.8, m)
            p.cap(67 + sw, 27 + b + dy * 2, 70 + sw * 2, 40 + b + dy * 2, 1.8, 1.0, m)
    elif cid == "dancer":    # selendang ends flowing from the hips
        teal = S["extra"]
        for side in (-1, 1):
            x0 = 48 + side * 9.5
            p.cap(x0, 62, x0 + side * (5 + sw * side), 84, 3.0, 2.6, teal)
            p.cap(x0 + side * (5 + sw * side), 84, x0 + side * (9 + sw * 2 * side), 106, 2.6, 1.6, teal)
    elif cid == "dalang":    # keris hilt rising behind the left hip
        p.cap(58, 62, 64, 52 + b, 1.8, 1.4, WOOD)
        p.ell(64.5, 51 + b, 2.2, 2.0, GOLD)

    # ---- legs and the lower cloth
    if not bust:
        legs = S["legs"]
        hipl, kneel, ankl = (43.5, 67), (41.5, 92), (40, 114)
        hipr, kneer, ankr = (52.5, 67), (55, 92), (57, 114)
        p.ell(38.5, 119.2, 5.6, 3.0, SKIN)
        p.ell(59, 119.2, 5.6, 3.0, SKIN)
        if legs in ("pants", "short"):
            for hip, knee, ank in ((hipl, kneel, ankl), (hipr, kneer, ankr)):
                if legs == "short":
                    p.cap(knee[0], knee[1], ank[0], ank[1] + 2, 3.9, 3.0, SKIN)
                    p.cap(hip[0], hip[1], knee[0], knee[1] - 2, 6.2, 5.4, low)
                else:
                    p.cap(ank[0], ank[1] - 3, ank[0], ank[1] + 2, 3.0, 2.8, SKIN)
                    p.cap(knee[0], knee[1], ank[0], ank[1] - 4, 5.2, 4.2, low)
                    p.cap(hip[0], hip[1], knee[0], knee[1], 6.2, 5.4, low)
                    p.ell(knee[0], knee[1], 3.4, 3.0, (low[2], low[1], low[2], low[2]), rim=False)
                    if cid in ("archer", "rogue"):   # calf wraps
                        wm = S["extra"] if cid != "rogue" else sash
                        p.cap(ank[0] + (knee[0] - ank[0]) * 0.3, ank[1] - 10, ank[0], ank[1] - 4, 4.5, 4.0, wm)
            if cid == "lancer":   # short indigo wrap with brass dots
                ex = S["extra"]
                wrap = p.trap([(64, 38.5, 57.5), (72, 36.5, 59.5), (80, 37.5, 58.5)], ex)
                for i in range(6):
                    p.dot(39.5 + i * 3.4, 71 + (i % 2) * 4, GOLD[3], wrap)
                p.line([(37.5, 79.4), (58.5, 79.4)], GOLD[2], 1.0, wrap)
        else:
            hem = 108 if legs == "kain" else 115
            for ax in (40, 57):
                p.cap(ax, hem - 4, ax, 116, 3.0, 2.8, SKIN)
            sk = p.trap([(62, 38.5, 57.5), (72, 36.0, 60.0), (hem - 6, 33.0 + sw * 0.4, 63.0 + sw * 0.4), (hem, 32.0 + sw, 64.0 + sw)], low)
            for fx_ in (41, 46.5, 52, 57):            # folds
                p.line([(fx_, 70), (fx_ - 1.5 + sw * 0.5 + (fx_ - 48) * 0.18, hem - 2)], low[1], 1.0, sk)
            if cid == "warrior":
                p.poly([(45.5, 64), (51.5, 64), (53 + sw, hem), (44 + sw, hem)], low[3], sk)   # wiru pleat
                for fx_ in (47, 49, 51):
                    p.line([(fx_ - 0.5, 66), (fx_ - 0.5 + sw, hem)], low[1], 1.0, sk)
                for i in range(12):                    # tumpal hem
                    x = 33 + i * 2.8 + sw
                    p.poly([(x, hem), (x + 1.4, hem - 4), (x + 2.8, hem)], GOLD[2], sk)
                p.line([(31, hem - 0.5), (65, hem - 0.5)], GOLD[1], 1.2, sk)
            elif cid == "mage":
                band = S["extra"]
                p.trap([(hem - 7, 30, 66), (hem, 30, 66)], band, rim=False, clip=sk)
                for i in range(11):
                    p.dot(34.5 + i * 3 + sw, hem - 3.5, GOLD[3], sk)
                p.line([(31, hem - 7), (65, hem - 7)], band[0], 1.0, sk)
                p.line([(51.5, 66), (53 + sw, hem - 8)], low[1], 1.0, sk)
            elif cid == "dancer":
                for r in range(6):
                    for i in range(8):
                        p.dot(35.5 + i * 3.8 + (r % 2) * 1.9 + sw * r / 6, 70 + r * 6, GOLD[2], sk)
                p.line([(31, hem - 0.5), (65, hem - 0.5)], GOLD[2], 1.6, sk)
                p.line([(31, hem - 3), (65, hem - 3)], GOLD[1], 1.0, sk)
            elif cid == "dalang":
                for i in range(-4, 14):                # parang: slanted bands
                    p.line([(30 + i * 5.5, 62), (16 + i * 5.5 + sw, hem)], sash[2], 1.6, sk)
                    p.line([(31.6 + i * 5.5, 62), (17.6 + i * 5.5 + sw, hem)], low[1], 1.0, sk)
                p.line([(31, hem - 0.5), (65, hem - 0.5)], low[0], 1.2, sk)

    # ---- torso
    tor = p.trap([(37 + b, 38.5, 57.5), (40 + b, 35.6, 60.4), (46 + b, 36.2, 59.8), (58 + b * 0.5, 39.6, 56.4), (66, 38.2, 57.8)], top)
    skin_top = top is SKIN
    if cid == "warrior":
        p.line([(42, 49 + b), (47, 50.5 + b)], SKIN[1], 1.0, tor)
        p.line([(49, 50.5 + b), (54, 49 + b)], SKIN[1], 1.0, tor)
        p.line([(48, 52 + b), (48, 58)], SKIN[1], 1.0, tor)
        band = p.cap(38, 38 + b, 57, 61, 3.0, 3.0, gear, clip=tor, rim=False)
        p.line([(36.5, 40.5 + b), (55.5, 63.5)], gear[0], 1.0, tor)
        p.line([(39.5, 35.5 + b), (58.5, 58.5)], gear[3], 1.0, tor)
        for i in range(5):
            p.dot(40.2 + i * 3.8, 40.6 + b + i * 4.6, GOLD[3], tor)
    elif cid == "lancer":
        white = S["low"]
        for i in range(8):
            p.line([(37.6 + i * 3.0, 38 + b), (39.2 + i * 2.6, 58)], white[2], 1.2, tor)
        p.line([(48, 40 + b), (48, 58)], top[0], 1.0, tor)
        for i in range(4):
            p.dot(48, 43 + b + i * 4, GOLD[3], tor)
        p.poly([(44, 36.5 + b), (52, 36.5 + b), (50.5, 40.5 + b), (48, 41.5 + b), (45.5, 40.5 + b)], white[2], tor)
        p.poly([(46, 36.5 + b), (50, 36.5 + b), (48, 40 + b)], SKIN[1], tor)
    elif cid == "archer":
        p.poly([(45, 36.5 + b), (51, 36.5 + b), (48, 43.5 + b)], SKIN[2], tor)
        p.line([(45, 36.5 + b), (48, 43.5 + b), (51, 36.5 + b)], top[0], 1.0, tor)
        p.line([(48, 44 + b), (48, 58)], top[0], 1.0, tor)
        for i in range(3):
            p.line([(46, 47 + b + i * 3.6), (50, 47 + b + i * 3.6)], top[3], 1.0, tor)
        p.cap(58.5, 38 + b, 39.5, 60, 1.6, 1.6, gear, clip=tor, rim=False)
        p.line([(59.5, 39.5 + b), (40.5, 61.5)], gear[0], 1.0, tor)
    elif cid == "herder":
        p.poly([(44, 36.5 + b), (52, 36.5 + b), (48, 46 + b)], SKIN[2], tor)
        p.line([(44, 36.5 + b), (48, 46 + b), (52, 36.5 + b)], top[1], 1.0, tor)
        blue = S["extra"]
        p.cap(59, 38 + b, 39, 62, 4.0, 4.4, blue, clip=tor, rim=False)
        for i in range(7):
            x, y = 58 - i * 3.0, 39.5 + b + i * 3.6
            p.line([(x - 2.6, y - 2.2), (x + 2.6, y + 2.2)], WHITE[2], 1.0, tor)
        p.line([(61.5, 41.5 + b), (42, 64.5)], blue[0], 1.0, tor)
    elif cid == "rogue":
        p.poly([(45.5, 36.5 + b), (50.5, 36.5 + b), (48, 42 + b)], SKIN[2], tor)
        p.line([(44, 36.5 + b), (53, 53)], WHITE[1], 1.0, tor)
        p.line([(52, 36.5 + b), (48.5, 44 + b)], top[0], 1.0, tor)
        p.line([(44.8, 37.5 + b), (53.6, 53.6)], top[0], 1.0, tor)
    elif cid == "dancer":
        p.trap([(36 + b, 34, 62), (44.5 + b, 34, 62)], SKIN, clip=tor, rim=False)
        p.line([(37, 44.8 + b), (59, 44.8 + b)], top[0], 1.0, tor)
        p.line([(37, 46.2 + b), (59, 46.2 + b)], GOLD[2], 1.0, tor)
        for i in range(5):
            p.dot(40 + i * 4, 51 + b, GOLD[3], tor)
            p.dot(42 + i * 4, 55, GOLD[2], tor)
    elif cid == "mage":
        p.poly([(45.5, 36.5 + b), (50.5, 36.5 + b), (48, 41 + b)], SKIN[2], tor)
        trim = S["extra"]
        p.line([(44.5, 36.5 + b), (53.5, 57)], trim[2], 2.2, tor)
        p.line([(51.5, 36.5 + b), (47.5, 45 + b)], trim[2], 2.2, tor)
        p.line([(43.4, 37.5 + b), (52.4, 58)], top[1], 1.0, tor)
        p.line([(45.8, 36.5 + b), (54.8, 57)], GOLD[3], 1.0, tor)
    elif cid == "dalang":
        p.poly([(45, 36.5 + b), (51, 36.5 + b), (49.5, 39.5 + b), (46.5, 39.5 + b)], WHITE[2], tor)
        p.poly([(46.5, 36.5 + b), (49.5, 36.5 + b), (48, 39 + b)], SKIN[1], tor)
        p.line([(46, 40 + b), (53.5, 58)], top[0], 1.0, tor)
        p.line([(47.2, 40 + b), (54.6, 58)], top[3], 1.0, tor)
        for i in range(4):
            p.dot(48.6 + i * 1.7, 43 + b + i * 4.0, GOLD[3], tor)
    if not skin_top and cid not in ("dancer",):
        pass

    # ---- sash and belt
    if cid == "rogue":
        belt = p.trap([(53.5 + b * 0.5, 39.4, 56.6), (59, 39.0, 57.0), (66, 37.8, 58.2)], sash)
        p.line([(40, 55 + b * 0.5), (56, 55 + b * 0.5)], sash[3], 1.0, belt)
        p.line([(39, 60), (57, 60)], sash[1], 1.0, belt)
        p.ell(40.5, 61, 2.6, 2.4, sash)
        p.cap(40, 62, 36 + sw, 78, 2.2, 1.8, sash)
        p.cap(41.5, 62, 40 + sw, 82, 2.0, 1.4, sash)
    else:
        belt = p.trap([(58 + b * 0.5, 39.2, 56.8), (62, 38.6, 57.4), (66.5, 37.8, 58.2)], sash)
        p.line([(40, 59.4 + b * 0.5), (56, 59.4 + b * 0.5)], sash[3], 1.0, belt)
        if cid in ("warrior", "lancer"):
            p.ell(48, 62.4, 3.0, 2.8, GOLD)
            p.dot(48, 62.4, GOLD[0])
        elif cid == "archer":
            p.ell(42, 62.5, 2.4, 2.2, sash)
            p.cap(41.5, 64, 40 + sw, 76, 1.8, 1.2, sash)
        elif cid == "mage":
            p.ell(44, 62.5, 2.2, 2.0, sash)
            p.cap(43.5, 64, 42.5 + sw, 78, 1.8, 1.2, sash)
            lt = p.trap([(61, 55.5, 62.5), (71, 55.5, 62.5)], GOLD, bend=0.5)   # the lontar at the hip
            for i in range(3):
                p.line([(56.5, 63.5 + i * 2.5), (61.5, 63.5 + i * 2.5)], GOLD[0], 1.0, lt)
            p.glow(59, 66, 7.0, S["fx"], 0.5 * pulse)
        elif cid == "herder":
            p.line([(39.5, 62), (56.5, 62)], sash[0], 1.0, belt)
            p.cap(55, 60, 62, 72, 1.3, 1.3, S["gear"])     # suling tucked in the belt
            for i in range(3):
                p.dot(57 + i * 1.7, 63.5 + i * 2.9, WOOD[0])
        elif cid == "dancer":
            p.ell(48, 62.4, 3.2, 3.0, RED)
            p.dot(47.4, 61.6, hexc("FF9080"))
            for i in (-2, -1, 1, 2):
                p.dot(48 + i * 3.4, 62.4, GOLD[0], belt)
        elif cid == "dalang":
            for i in range(6):
                p.dot(40.5 + i * 3.0, 62.6, GOLD[3], belt)
                p.dot(42 + i * 3.0, 64.6, GOLD[2], belt)

    # ---- neck and head
    p.cap(48, 31 + b, 48, 37.5 + b, 3.4, 3.8, (SKIN[0], SKIN[1], SKIN[1], SKIN[2]))
    if cid == "dancer":      # kace: a gold collar over the shoulders
        col = p.ell(48, 39.5 + b, 9.5, 4.6, GOLD)
        p.ell(48, 41 + b, 2.0, 1.9, RED)
        for i in (-2, -1, 1, 2):
            p.dot(48 + i * 3.2, 40 + b - abs(i) * 0.5, GOLD[0], col)
    for ex in (38.8, 57.2):
        p.ell(ex, hy + 1.5, 2.0, 2.8, SKIN)
    head = p.ell(hx, hy, 9.2, 10.6, SKIN, lift=0.08)
    # hair cap and sideburns
    def hairfn(x, y):
        nx, ny = (x - hx) / 9.9, (y - (hy - 3.2)) / 8.6
        if nx * nx + ny * ny > 1.0:
            return None
        brow = hy - 3.4 + abs(x - hx) * 0.16 - (2.2 if abs(x - hx) > 6.6 else 0.0) * -1.6
        return (nx, ny) if y < brow else None
    hair = p.shade(p.region(hairfn, (hx - 10, hy - 12, hx + 10, hy + 4)), HAIR)
    p.line([(hx - 5.5, hy - 9), (hx - 1.5, hy - 10.6)], HAIR[3], 1.0, hair)
    face(p, hx, hy, mood, blink, head)
    headgear(p, cid, hx, hy, S, sw, b, bust)

    # ---- arms, weapons, hands
    (el, hl), (er, hr) = arms
    sleeve = S["sleeve"]
    cloth = top if not skin_top else SKIN

    def arm(sh, elb, hand, front_item=None):
        up = cloth if sleeve >= 1 or not skin_top else SKIN
        if sleeve == 0:
            up = SKIN
        fore = cloth if sleeve >= 2 else SKIN
        p.cap(elb[0], elb[1], hand[0], hand[1], 3.3, 2.8, fore)
        p.cap(sh[0], sh[1], elb[0], elb[1], 4.4, 3.6, up)
        if up is fore:                      # one sleeve or one bare arm: no joint line at the elbow
            p.ell(elb[0], elb[1], 2.5, 2.5, (fore[2], fore[1], fore[2], fore[2]), rim=False)
        if sleeve >= 2:
            p.cap(hand[0] + (elb[0] - hand[0]) * 0.22, hand[1] + (elb[1] - hand[1]) * 0.22, hand[0], hand[1], 3.0, 2.8,
                  {"lancer": S["low"], "mage": S.get("extra"), "dalang": WHITE, "archer": S["sash"], "rogue": S["sash"]}.get(cid, cloth))
        if cid in ("warrior", "dancer"):   # brass armbands
            mx, my = sh[0] + (elb[0] - sh[0]) * 0.55, sh[1] + (elb[1] - sh[1]) * 0.55
            p.cap(mx - 3.4, my - 0.6, mx + 3.4, my + 0.6, 1.3, 1.3, GOLD)
        if cid == "dancer":
            p.cap(hand[0] + (elb[0] - hand[0]) * 0.3 - 2, hand[1] + (elb[1] - hand[1]) * 0.3, hand[0] + (elb[0] - hand[0]) * 0.3 + 2,
                  hand[1] + (elb[1] - hand[1]) * 0.3, 1.2, 1.2, GOLD)

    def hand(h):
        p.ell(h[0], h[1], 3.1, 3.1, SKIN)

    # screen-right arm first (it is the far one in a 3/4 read), then its prop
    if cid == "warrior":
        arm(shr, er, hr)
        hand(hr)
        if not bust:             # the round tameng, held forward
            sx, sy = 67.5, 58 + b
            p.ell(sx, sy, 12.4, 13.4, mat("8E2620"))
            p.ell(sx, sy, 10.6, 11.6, gear)
            p.ell(sx, sy, 7.4, 8.2, mat("A8302A"))
            p.ell(sx, sy, 3.4, 3.6, GOLD)
            for a in range(0, 360, 45):
                p.dot(sx + math.cos(math.radians(a)) * 9.0, sy + math.sin(math.radians(a)) * 9.9, GOLD[3])
    else:
        arm(shr, er, hr)
        if cid == "rogue" and not bust:    # kujang, reverse grip, edge outward
            blade(p, hr[0] + 0.5, hr[1] + 2, hr[0] + 6, hr[1] + 17, 4.2, -2.4)
            p.cap(hr[0] - 0.5, hr[1] - 3, hr[0] + 0.5, hr[1] + 2.5, 1.5, 1.5, WOOD)
            p.dot(hr[0] + 0.5, hr[1] + 2.6, GOLD[3])
        elif cid == "dancer" and not bust:
            fan(p, hr[0], hr[1], 55 + sw * 2, 15, S)
        elif cid in ("mage", "dalang"):    # an open palm with a floating spark of ink-light
            p.glow(hr[0], hr[1] - 7, 8.0 if not bust else 6.0, S["fx"], pulse)
            if cid == "mage":
                p.line([(hr[0] - 2, hr[1] - 9), (hr[0] + 2, hr[1] - 9), (hr[0] - 1, hr[1] - 5), (hr[0] + 2.5, hr[1] - 5)], hexc("EFFFF8"), 1.0)
            else:                          # a tiny gunungan of lamp light
                p.poly([(hr[0], hr[1] - 12), (hr[0] + 3, hr[1] - 6), (hr[0], hr[1] - 4), (hr[0] - 3, hr[1] - 6)], hexc("FFE9B0"))
                p.dot(hr[0], hr[1] - 7.5, RED[2])
        hand(hr)

    # screen-left arm with the main weapon
    if cid == "warrior":
        if not bust:
            blade(p, hl[0] - 1.5, hl[1] + 3.5, hl[0] - 12, hl[1] + 37, 6.4, 2.6)
            p.cap(hl[0] - 3.6, hl[1] + 1.6, hl[0] + 2.2, hl[1] + 4.2, 1.5, 1.5, GOLD)
            p.cap(hl[0] + 1.0, hl[1] - 4.5, hl[0] - 0.6, hl[1] + 1.5, 1.6, 1.6, WOOD)
        arm(shl, el, hl)
        hand(hl)
    elif cid == "lancer":
        if not bust:
            x = hl[0] - 1.5
            p.cap(x, 14, x, 121, 1.2, 1.2, WOOD)
            p.poly([(x, 0.5), (x + 3.2, 8), (x + 1.2, 13.5), (x - 1.2, 13.5), (x - 3.2, 8)], STEEL[2])
            p.line([(x, 1), (x, 13)], STEEL[1], 1.0)
            p.line([(x - 2.4, 8), (x - 0.4, 2)], STEEL[3], 1.0)
            p.cap(x - 1.6, 14.5, x + 1.6, 14.5, 1.4, 1.4, GOLD)
            for i, dx in enumerate((-2.2, 0, 2.2)):
                p.cap(x + dx, 16.5, x + dx + sw * 0.8, 24 + (i % 2) * 2, 1.4, 0.9, RED)
            p.cap(x - 1.2, 119, x + 1.2, 119, 1.3, 1.3, GOLD)
        arm(shl, el, hl)
        hand(hl)
    elif cid == "archer":
        if not bust:
            x = hl[0] - 1.0
            pts = [(x + 6 - 7.5 * (1 - ((i - 8) / 8.0) ** 2), 18 + i * 5.4) for i in range(17)]
            p.line(pts, S["extra"][0], 3.0)
            p.line(pts, S["extra"][2], 1.6)
            p.line([(q[0] - 0.6, q[1]) for q in pts[1:8]], S["extra"][3], 1.0)
            p.line([pts[0], pts[-1]], WHITE[2], 1.0)
            for q in (pts[0], pts[-1]):
                p.ell(q[0], q[1], 1.4, 1.4, GOLD)
            p.cap(x - 1.6, hl[1] - 4, x - 1.6, hl[1] + 4, 1.9, 1.9, gear)
        arm(shl, el, hl)
        hand(hl)
    elif cid == "herder":
        arm(shl, el, hl)
        if not bust:              # bandring: the cord hangs doubled, a stone in the pouch
            p.line([(hl[0] - 1, hl[1] + 2), (hl[0] - 3.5 + sw, hl[1] + 20)], WHITE[1], 1.0)
            p.line([(hl[0] + 1, hl[1] + 2), (hl[0] - 0.5 + sw, hl[1] + 20)], WHITE[2], 1.0)
            p.ell(hl[0] - 2 + sw, hl[1] + 22.5, 3.4, 2.8, WOOD)
            p.ell(hl[0] - 2 + sw, hl[1] + 21.8, 2.0, 1.7, STEEL)
        hand(hl)
    elif cid == "rogue":
        arm(shl, el, hl)
        p.ell(hl[0] + 0.5, hl[1] - 1.5, 3.0, 3.8, SKIN)          # open-palm guard
        p.line([(hl[0] - 1, hl[1] - 4.5), (hl[0] - 1, hl[1] - 1)], SKIN[1], 1.0)
        p.line([(hl[0] + 1, hl[1] - 4.8), (hl[0] + 1, hl[1] - 1)], SKIN[1], 1.0)
    elif cid == "dancer":
        if not bust:
            fan(p, hl[0], hl[1], -118 - sw * 2, 16, S)
        arm(shl, el, hl)
        hand(hl)
    elif cid in ("mage", "dalang"):
        if not bust:
            x = hl[0] - 1.5
            if cid == "mage":
                p.cap(x, 20, x, 121, 1.3, 1.3, WOOD)
                p.glow(x, 10.5, 13.0, S["fx"], pulse)
                for a in range(0, 360, 12):
                    p.dot(x + math.cos(math.radians(a)) * 5.6, 10.5 + math.sin(math.radians(a)) * 5.6, GOLD[2])
                    p.dot(x + math.cos(math.radians(a)) * 6.6, 10.5 + math.sin(math.radians(a)) * 6.6, GOLD[1 if a > 20 and a < 200 else 3])
                p.cap(x - 1.8, 17.6, x + 1.8, 17.6, 1.5, 1.5, GOLD)
                p.ell(x, 10.5, 2.0, 2.0, (S["fx"], S["fx"], hexc("EFFFF8"), hexc("FFFFFF")), rim=False)
                for i, a in enumerate((200, 340, 90)):
                    p.ell(x + math.cos(math.radians(a)) * 6.1, 10.5 + math.sin(math.radians(a)) * 6.1 + 3.2, 1.3, 1.3, GOLD)
            else:
                p.cap(x, 30, x, 121, 1.3, 1.3, WOOD)
                p.glow(x, 16, 13.0, S["fx"], pulse * 0.8)
                leaf = [(x, 0.5), (x + 3, 5), (x + 6.5, 11), (x + 7.5, 18), (x + 5, 25), (x + 2, 29.5), (x, 31),
                        (x - 2, 29.5), (x - 5, 25), (x - 7.5, 18), (x - 6.5, 11), (x - 3, 5)]
                lf = p.poly(leaf, GOLD[2])
                p.line(leaf + [leaf[0]], GOLD[0], 1.0)
                p.line(leaf[:7], GOLD[1], 1.0, lf)
                p.line([(x, 3), (x, 30)], GOLD[1], 1.0, lf)
                p.poly([(x, 9), (x + 3, 15), (x, 22), (x - 3, 15)], RED[2], lf)
                p.line([(x - 4.5, 12), (x - 1.5, 6)], GOLD[3], 1.0, lf)
                for dy in (12, 18, 24):
                    p.dot(x - 4.2, dy + 2, GOLD[3], lf)
                    p.dot(x + 4.2, dy + 2, GOLD[1], lf)
                p.dot(x, 15, GOLD[3], lf)
        arm(shl, el, hl)
        hand(hl)


def face(p, hx, hy, mood, blink, head):
    s = SKIN
    white = hexc("F6EEDC")
    for side in (-1, 1):
        ex = hx + side * 4.1
        ey = hy + 1.2
        if blink or mood == "happy":
            p.line([(ex - 1.8, ey + 0.7), (ex, ey - 0.9 if mood == "happy" else ey + 0.9), (ex + 1.8, ey + 0.7)], EYE, 1.0, head)
        else:
            p.line([(ex - 1.8, ey), (ex + 1.8, ey)], white, 2.0, head)
            p.line([(ex - 0.3 * side, ey - 0.5), (ex - 0.3 * side, ey + 0.5)], EYE, 1.0 if p.k < 1.2 else 2.0, head)
            p.line([(ex - 2.0, ey - 1.9), (ex + 2.0, ey - 1.9)], EYE, 1.0, head)
            if mood == "sad":
                p.dot(ex + side * 1.6, ey - 1.0, s[2], head)
        # brows
        tilt = {"angry": 1.3, "sad": -1.2}.get(mood, 0.0)
        ey -= 1.0 if mood == "happy" else 0.0
        p.line([(ex - side * 2.0, ey - 4.0 + tilt), (ex + side * 2.0, ey - 4.2 - tilt * 0.5)], HAIR[1], 1.0, head)
    p.line([(hx + 0.6, hy + 2.5), (hx + 0.9, hy + 4.4)], s[1], 1.0, head)          # nose
    p.dot(hx - 0.3, hy + 4.6, s[1], head)
    my = hy + 7.0
    if mood == "happy":
        p.line([(hx - 2.2, my - 0.6), (hx - 1, my + 0.5), (hx + 1, my + 0.5), (hx + 2.2, my - 0.6)], s[0], 1.0, head)
        p.line([(hx - 1, my - 0.3), (hx + 1, my - 0.3)], white, 1.0, head)
    elif mood == "sad":
        p.line([(hx - 2, my + 0.6), (hx - 0.8, my - 0.2), (hx + 0.8, my - 0.2), (hx + 2, my + 0.6)], s[0], 1.0, head)
        p.line([(hx - 5.4, hy + 3.2), (hx - 5.4, hy + 5.6)], hexc("9FD8F0"), 1.0, head)
    elif mood == "angry":
        p.line([(hx - 2, my), (hx + 2, my)], s[0], 1.0, head)
        p.line([(hx - 1.2, my + 1.0), (hx + 1.2, my + 1.0)], s[1], 1.0, head)
    else:
        p.line([(hx - 1.6, my), (hx + 1.6, my)], s[0], 1.0, head)
        p.dot(hx, my + 1.2, s[1], head)
    for side in (-1, 1):                                                           # cheek light and jaw shade
        p.dot(hx + side * 5.6, hy + 4.4, s[3] if side < 0 else s[1], head)


def headgear(p, cid, hx, hy, S, sw, b, bust):
    gear, sash = S["gear"], S["sash"]

    def cap_cloth(m, brow=-3.2, wide=10.3, tall=9.0):
        def fn(x, y):
            nx, ny = (x - hx) / wide, (y - (hy - 3.4)) / tall
            return (nx, ny) if nx * nx + ny * ny <= 1.0 and y < hy + brow else None
        return p.shade(p.region(fn, (hx - wide, hy - 13, hx + wide, hy + 2)), m)
    if cid == "warrior":
        cl = cap_cloth(gear)
        bandr = p.trap([(hy - 6.4, hx - 9.9, hx + 9.9), (hy - 3.0, hx - 9.9, hx + 9.9)], mat("8E2620"), clip=cl, rim=False)
        for i in range(7):
            p.dot(hx - 7.5 + i * 2.5, hy - 4.6, GOLD[3], cl)
        p.poly([(hx - 1.5, hy - 10.5), (hx + 4.5, hy - 17), (hx + 3.2, hy - 9.5)], gear[2])     # the standing knot
        p.line([(hx - 1.5, hy - 10.5), (hx + 4.5, hy - 17)], gear[3], 1.0)
        p.line([(hx + 4.5, hy - 17), (hx + 3.2, hy - 9.5)], gear[0], 1.0)
        p.cap(hx - 9.4, hy - 4, hx - 11.5 - sw * 0.5, hy + 6, 1.8, 1.0, gear)                    # the tail by the ear
    elif cid == "archer":
        cl = cap_cloth(gear, brow=-3.4)
        p.trap([(hy - 6.0, hx - 9.9, hx + 9.9), (hy - 3.4, hx - 9.9, hx + 9.9)], sash, clip=cl, rim=False)
        p.line([(hx - 9, hy - 6.2), (hx + 9, hy - 6.2)], gear[0], 1.0, cl)
        p.poly([(hx - 3.2, hy - 9.2), (hx + 0.5, hy - 16.5), (hx + 3.4, hy - 9.2)], gear[2])
        p.line([(hx - 3.2, hy - 9.2), (hx + 0.5, hy - 16.5)], gear[3], 1.0)
        p.line([(hx + 0.5, hy - 16.5), (hx + 3.4, hy - 9.2)], gear[0], 1.0)
        p.cap(hx + 6.5, hy - 8, hx + 12.5 + sw * 0.4, hy - 19, 1.7, 0.7, WHITE)                  # the feather
        p.line([(hx + 6.5, hy - 8), (hx + 12.3 + sw * 0.4, hy - 18.6)], WHITE[1], 1.0)
        p.dot(hx + 12.5 + sw * 0.4, hy - 19.4, sash[2])
    elif cid == "rogue":
        cl = cap_cloth(gear, brow=-2.4)
        p.line([(hx - 8.8, hy - 2.9), (hx + 8.8, hy - 2.9)], WHITE[2], 1.2, cl)
        p.line([(hx - 4, hy - 9.5), (hx + 5, hy - 5)], gear[1], 1.0, cl)
        p.ell(hx + 9.2, hy - 4.5, 2.2, 2.2, sash)                                               # the knot
    elif cid == "mage":
        p.ell(hx, hy - 13.8, 3.6, 4.2, HAIR)
        p.cap(hx - 3, hy - 10.6, hx + 3, hy - 10.6, 1.3, 1.3, GOLD)
        p.line([(hx - 8.6, hy - 4.2), (hx + 8.6, hy - 4.2)], GOLD[2], 1.2)
        p.dot(hx, hy - 4.2, S["fx"])
        for side in (-1, 1):                                                                    # sumping
            p.poly([(hx + side * 8.6, hy - 2.5), (hx + side * 12.2, hy - 7), (hx + side * 10.6, hy + 2.8)], GOLD[2])
            p.line([(hx + side * 8.6, hy - 2.5), (hx + side * 12.2, hy - 7)], GOLD[3], 1.0)
            p.line([(hx + side * 12.2, hy - 7), (hx + side * 10.6, hy + 2.8)], GOLD[0], 1.0)
    elif cid == "lancer":
        p.trap([(hy - 21, hx - 8.6, hx + 8.6), (hy - 19.5, hx - 9.2, hx + 9.2), (hy - 3.4, hx - 9.9, hx + 9.9)], gear)
        p.trap([(hy - 8.2, hx - 9.9, hx + 9.9), (hy - 5.2, hx - 9.9, hx + 9.9)], GOLD, rim=False)
        p.line([(hx - 9.7, hy - 8.4), (hx + 9.7, hy - 8.4)], GOLD[0], 1.0)
        p.line([(hx - 9.7, hy - 4.8), (hx + 9.7, hy - 4.8)], gear[0], 1.0)
        p.ell(hx, hy - 13.2, 2.4, 2.8, GOLD)
        p.dot(hx, hy - 13.2, RED[2])
        p.ell(hx, hy - 22.2, 2.6, 2.0, RED)
    elif cid == "herder":
        apex, base = hy - 20.5, hy - 5.0
        p.ell(hx, base + 0.6, 21.5, 3.4, (gear[0], gear[0], gear[1], gear[1]))                  # the brim's underside
        cone = p.trap([(apex, hx - 0.8, hx + 0.8), (apex + 4, hx - 5, hx + 5), (base, hx - 21.5, hx + 21.5)], gear, bend=0.99)
        for i in range(-5, 6):
            p.line([(hx + i * 0.3, apex + 1), (hx + i * 4.1, base)], gear[1] if i % 2 else gear[3], 1.0, cone)
        for r in (5.5, 10.5):
            p.line([(hx - r * 1.35, apex + r + 1.5), (hx + r * 1.35, apex + r + 1.5)], gear[0], 1.0, cone)
        p.ell(hx, apex - 0.4, 1.5, 1.3, WOOD)
        p.line([(hx - 8.4, hy - 2.0), (hx - 5, hy + 9.6), (hx, hy + 11.4)], WOOD[1], 1.0)        # the chin cord
        p.line([(hx + 8.4, hy - 2.0), (hx + 5, hy + 9.6), (hx, hy + 11.4)], WOOD[1], 1.0)
    elif cid == "dancer":
        crown = p.trap([(hy - 11.5, hx - 8.8, hx + 8.8), (hy - 3.6, hx - 10.2, hx + 10.2)], gear)
        for dx, hgt in ((-7, 4.5), (-3.5, 6.5), (0, 9.5), (3.5, 6.5), (7, 4.5)):
            p.poly([(hx + dx - 1.9, hy - 11), (hx + dx, hy - 11 - hgt), (hx + dx + 1.9, hy - 11)], GOLD[2])
            p.line([(hx + dx - 1.9, hy - 11), (hx + dx, hy - 11 - hgt)], GOLD[3], 1.0)
            p.line([(hx + dx, hy - 11 - hgt), (hx + dx + 1.9, hy - 11)], GOLD[0], 1.0)
        p.ell(hx, hy - 7.4, 2.0, 2.0, RED)
        for dx in (-5.5, 5.5):
            p.dot(hx + dx, hy - 7.2, S["extra"][3], crown)
        p.line([(hx - 9.6, hy - 4.2), (hx + 9.6, hy - 4.2)], GOLD[0], 1.0, crown)
        for side in (-1, 1):                                                                    # ronce tassels
            x = hx + side * 10.4
            p.ell(x, hy - 2.6, 1.8, 1.8, GOLD)
            for i in range(5):
                p.ell(x + side * 0.3 * i + sw * 0.25 * i, hy + 0.6 + i * 2.7, 1.5, 1.5, RED if i % 2 == 0 else WHITE)
        mx, my = hx + 9.5, hy - 12.5                                                            # the topeng, pushed up at the temple
        p.ell(mx, my, 4.4, 5.4, WHITE)
        p.line([(mx - 2.2, my - 1), (mx - 0.6, my - 0.6)], EYE, 1.0)
        p.line([(mx + 0.8, my - 0.8), (mx + 2.4, my - 1.4)], EYE, 1.0)
        p.line([(mx - 1.2, my + 2.6), (mx + 1.2, my + 2.4)], RED[2], 1.0)
        p.dot(mx - 2.6, my + 1.0, hexc("F0A0A0"))
    elif cid == "dalang":
        cl = cap_cloth(gear, brow=-3.0, wide=10.5, tall=9.4)
        for r in range(4):
            for i in range(7):
                p.dot(hx - 8 + i * 2.8 + (r % 2) * 1.4, hy - 11 + r * 2.2, sash[3] if (i + r) % 3 else GOLD[2], cl)
        p.line([(hx - 9.2, hy - 3.4), (hx - 2, hy - 6.6), (hx, hy - 4.4)], gear[0], 1.0, cl)     # the front folds
        p.line([(hx + 9.2, hy - 3.4), (hx + 2, hy - 6.6), (hx, hy - 4.4)], gear[0], 1.0, cl)
        p.line([(hx - 9, hy - 3.2), (hx + 9, hy - 3.2)], gear[0], 1.0, cl)
        p.ell(hx + 10.2, hy - 0.5, 1.8, 2.4, gear)                                              # a glimpse of the mondolan


# ---------------------------------------------------------------- outputs
def class_strip(cid):
    strip = Image.new("RGBA", (FW * FRAMES, FH), (0, 0, 0, 0))
    for f in range(FRAMES):
        p = Paint(FW, FH)
        figure(p, cid, f)
        strip.paste(p.image(), (f * FW, 0))
    return strip


def bust(cid, mood):
    bg, disc = (0x16, 0x26, 0x2A, 255), (0x22, 0x40, 0x3E, 255)
    img = Image.new("RGBA", (48, 48), bg)
    for y in range(48):
        for x in range(48):
            if (x - 23.5) ** 2 + (y - 22.5) ** 2 <= 23.0 ** 2:
                img.putpixel((x, y), disc)
    k = 1.28
    p = Paint(48, 48, k, 24 - 48 * k, 27 - 22 * k)
    figure(p, cid, 0, mood, True)
    fig = p.image()
    img.alpha_composite(fig) if hasattr(img, "alpha_composite") else img.paste(fig, (0, 0), fig)
    return img


def main():
    os.makedirs(OUTDIR, exist_ok=True)
    strips, busts = [], []
    for cid in CLASS_IDS:
        st = class_strip(cid)
        st.save(os.path.join(OUTDIR, "class_%s.png" % cid))
        strips.append(st)
        row = []
        for mood in MOODS:
            bimg = bust(cid, mood)
            bimg.save(os.path.join(OUTDIR, "p_hero_%s%s.png" % (cid, "_" + mood if mood else "")))
            row.append(bimg)
        busts.append(row)
    # preview: frame 0 of every class, then the busts
    prev = Image.new("RGBA", (FW * 8 + 18, FH + 8 + 4 * 50 + 8), (44, 40, 58, 255))
    for i, st in enumerate(strips):
        fr = st.crop((0, 0, FW, FH))
        prev.paste(fr, (2 + i * (FW + 2), 4), fr)
        for j, bimg in enumerate(busts[i]):
            prev.paste(bimg, (2 + i * (FW + 2) + 24, FH + 10 + j * 50))
    prev = prev.resize((prev.width * 3, prev.height * 3), Image.NEAREST)
    prev.save(os.path.join(ROOT, "tools", "portraits_preview.png"))
    print("wrote %d class strips and %d busts" % (len(strips), len(strips) * len(MOODS)))


if __name__ == "__main__":
    main()
