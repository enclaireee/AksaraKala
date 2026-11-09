#!/usr/bin/env python3
"""Art for the launch intro (ui/intro.gd, ui.md 4.0) -> assets/art/intro/.

Everything is drawn procedurally at native resolution (480x270 screen, 1 art px = 1 screen px) in the v3 "Senja"
dusk palette, with banded colour steps and ordered (Bayer) dithering instead of smooth gradients, so it sits with
the title art. Deterministic: re-running reproduces the same files.

  python3 tools/gen_intro_art.py            writes the PNGs and tools/intro_preview.png (a storyboard)
"""
import math
import os

import numpy as np
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "art", "intro")
W, H = 480, 270
RNG = np.random.default_rng(1945)

BAYER4 = (np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) + 0.5) / 16.0


def hx(s, a=255):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), a)


# v3 dusk palette (ui/fx/ui_fx.gd) plus the intro's warm lamp and dawn ramps
LACQUER = hx("0A0814")
NIGHT = hx("141026")
NIGHT_HI = hx("241C40")
LINE_DIM = hx("3A2F5C")
CYAN = hx("7FE8E0")
HALO = hx("3FB8C0")
WARM = hx("F2B27A")
WARM_LO = hx("C98A52")
ROSE = hx("E0566A")
CREAM = hx("FFF4E6")


def bayer(h, w):
    return np.tile(BAYER4, (h // 4 + 1, w // 4 + 1))[:h, :w]


def banded(v, colours, dither=True):
    """v: float array 0..1 -> RGBA image picking from `colours` (dark..light) in bands, dithered at the seams."""
    n = len(colours)
    h, w = v.shape
    x = np.clip(v, 0, 0.9999) * (n - 1)
    lo = np.floor(x).astype(int)
    frac = x - lo
    if dither:
        idx = lo + (frac > bayer(h, w)).astype(int)
    else:
        idx = np.round(x).astype(int)
    idx = np.clip(idx, 0, n - 1)
    pal = np.array(colours, dtype=np.uint8)
    return Image.fromarray(pal[idx], "RGBA")


def alpha_glow(size, colour, levels=5, max_a=200, power=1.6, squash=1.0):
    """A radial glow quantised to `levels` alpha steps, dithered between them (the kelir_glow look)."""
    w, h = (size, size) if isinstance(size, int) else size
    yy, xx = np.mgrid[0:h, 0:w]
    dx = (xx + 0.5 - w / 2) / (w / 2)
    dy = (yy + 0.5 - h / 2) / (h / 2) / squash
    r = np.sqrt(dx * dx + dy * dy)
    v = np.clip(1 - r, 0, 1) ** power
    x = v * levels
    lo = np.floor(x)
    lv = lo + ((x - lo) > bayer(h, w))
    a = (lv / levels * max_a).astype(np.uint8)
    arr = np.zeros((h, w, 4), np.uint8)
    arr[..., 0], arr[..., 1], arr[..., 2] = colour[0], colour[1], colour[2]
    arr[..., 3] = a
    return Image.fromarray(arr, "RGBA")


def value_noise(h, w, cell, seed):
    r = np.random.default_rng(seed)
    gh, gw = h // cell + 2, w // cell + 2
    g = r.random((gh, gw))
    yy, xx = np.mgrid[0:h, 0:w] / cell
    y0, x0 = yy.astype(int), xx.astype(int)
    fy, fx = yy - y0, xx - x0
    fy, fx = fy * fy * (3 - 2 * fy), fx * fx * (3 - 2 * fx)
    a = g[y0, x0] * (1 - fx) + g[y0, x0 + 1] * fx
    b = g[y0 + 1, x0] * (1 - fx) + g[y0 + 1, x0 + 1] * fx
    return a * (1 - fy) + b * fy


def fbm(h, w, cell, seed, octaves=4):
    v, amp, tot = np.zeros((h, w)), 1.0, 0.0
    for o in range(octaves):
        v += value_noise(h, w, max(2, cell >> o), seed + o * 17) * amp
        tot += amp
        amp *= 0.5
    return v / tot


def mask_of(img):
    return np.array(img)[..., 3] > 0


def rim(img, colour, dirs=((0, -1),), inner=False):
    """Paint a 1 px rim on opaque pixels whose neighbour in any of `dirs` is clear (light from that side)."""
    a = np.array(img)
    m = a[..., 3] > 0
    edge = np.zeros_like(m)
    for dx, dy in dirs:
        sh = np.zeros_like(m)
        ys = slice(max(0, dy), m.shape[0] + min(0, dy))
        yd = slice(max(0, -dy), m.shape[0] + min(0, -dy))
        xs = slice(max(0, dx), m.shape[1] + min(0, dx))
        xd = slice(max(0, -dx), m.shape[1] + min(0, -dx))
        sh[yd, xd] = m[ys, xs]
        edge |= m & ~sh
    a[edge, 0], a[edge, 1], a[edge, 2] = colour[0], colour[1], colour[2]
    if colour[3] < 255:
        a[edge, 3] = colour[3]
    return Image.fromarray(a, "RGBA")


def outline(img, colour=LACQUER):
    a = np.array(img)
    m = a[..., 3] > 0
    grow = m.copy()
    grow[1:, :] |= m[:-1, :]
    grow[:-1, :] |= m[1:, :]
    grow[:, 1:] |= m[:, :-1]
    grow[:, :-1] |= m[:, 1:]
    ring = grow & ~m
    a[ring] = colour
    return Image.fromarray(a, "RGBA")


def save(img, name):
    os.makedirs(OUT, exist_ok=True)
    img.save(os.path.join(OUT, name + ".png"))
    return img


# ---------------------------------------------------------------------------------------------------------------
# Act 0: the blencong, the bronze oil lamp of the wayang (a garuda-bird vessel hung on a chain)
# ---------------------------------------------------------------------------------------------------------------

BRONZE = [hx("2A160E"), hx("4A2E1A"), hx("7A4A26"), hx("A8693A"), hx("C98A52"), hx("F2B27A")]


def blencong():
    w, h = 64, 56
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    c = BRONZE
    # chain from the top
    for y in range(0, 16, 3):
        d.rectangle((31, y, 32, y + 1), fill=c[3])
        d.point((31, y + 2), fill=c[1])
    d.ellipse((27, 14, 36, 20), outline=c[3])
    # the vessel: a bird body, tail fanned to the right, head and beak (the spout) to the left
    d.polygon([(14, 34), (20, 26), (32, 22), (44, 24), (52, 28), (50, 36), (40, 42), (24, 42)], fill=c[2])
    # tail feathers
    for i, (tx, ty) in enumerate([(60, 18), (62, 26), (61, 34), (57, 41)]):
        d.polygon([(44, 26 + i * 3), (tx, ty), (tx - 3, ty + 4), (46, 32 + i * 2)], fill=c[3 if i % 2 else 2])
    # wing, swept up
    d.polygon([(26, 28), (34, 14 + 8), (44, 18), (40, 30), (30, 34)], fill=c[3])
    for k in range(4):
        d.line([(30 + k * 3, 30), (34 + k * 3, 21 + k)], fill=c[4])
    # neck and crested head to the left, the beak is the wick spout
    d.polygon([(18, 32), (12, 24), (8, 20), (12, 16), (18, 18), (22, 26)], fill=c[2])
    d.polygon([(12, 16), (10, 10), (15, 13), (17, 8), (19, 15)], fill=c[3])  # crest
    d.polygon([(8, 20), (1, 23), (8, 23)], fill=c[4])                          # beak / spout
    d.point((13, 19), fill=c[5])                                                # eye
    # belly bowl and the drip foot
    d.chord((18, 34, 48, 50), 0, 180, fill=c[1])
    d.line([(20, 42), (46, 42)], fill=c[4])
    d.polygon([(31, 50), (33, 50), (32, 55)], fill=c[2])
    for x in range(22, 46, 4):   # chased band on the belly
        d.point((x, 45), fill=c[4])
        d.point((x + 2, 46), fill=c[3])
    im = rim(im, BRONZE[5], dirs=((0, -1), (-1, 0)))
    return outline(im, hx("120A0A"))


def flame_sheet():
    """4 frames, 12x22 each: the lamp flame, white core, amber body, rose tips."""
    fw, fh = 12, 22
    sheet = Image.new("RGBA", (fw * 4, fh), (0, 0, 0, 0))
    cols = [ROSE, WARM_LO, WARM, hx("FFE2A8"), CREAM]
    for f in range(4):
        yy, xx = np.mgrid[0:fh, 0:fw]
        lean = [0.0, 0.8, -0.4, -0.9][f]
        tall = [1.0, 0.92, 1.06, 0.96][f]
        t = (fh - 1 - yy) / (fh * tall)                 # 0 at the base, 1 at the tip
        cx = fw / 2 - 0.5 + lean * t * t * 3
        half = 4.6 * np.sin(np.clip(t, 0, 1) ** 0.55 * math.pi) * (1 - t * 0.35)
        dist = np.abs(xx - cx) / np.maximum(half, 0.01)
        inside = (dist < 1) & (t >= 0) & (t < 1)
        heat = np.clip((1 - dist) * 0.9 + (1 - t) * 0.6 - 0.25, 0, 1)
        img = banded(heat, cols)
        a = np.array(img)
        a[..., 3] = np.where(inside, 255, 0)
        sheet.paste(Image.fromarray(a, "RGBA"), (f * fw, 0))
    return sheet


# ---------------------------------------------------------------------------------------------------------------
# Act 1: the kelir (shadow-play screen) lit by the lamp, and the gunungan
# ---------------------------------------------------------------------------------------------------------------

def kelir():
    yy, xx = np.mgrid[0:H, 0:W]
    dx = (xx - 240) / 260.0
    dy = (yy - 118) / 150.0
    r = np.sqrt(dx * dx + dy * dy)
    weave = (value_noise(H, W, 6, 7) - 0.5) * 0.05 + ((xx % 3 == 0) * -0.015)
    v = np.clip(1.0 - r, 0, 1) ** 1.25 + weave
    cloth = [hx("120B12"), hx("2A1418"), hx("4A2418"), hx("7A3E1E"), hx("A8642A"), hx("D49446"),
             hx("EEC27C"), hx("FAE0AE"), hx("FFF0D0")]
    im = banded(v, cloth)
    d = ImageDraw.Draw(im)
    # the red border along the top (the screen's sewn edge) and the dark lower hem
    d.rectangle((0, 0, W, 9), fill=hx("4A1018"))
    d.rectangle((0, 10, W, 11), fill=hx("8A2028"))
    d.line([(0, 12), (W, 12)], fill=hx("2A0A10"))
    for x in range(0, W, 8):
        d.point((x + 3, 5), fill=hx("C98A52"))
    # the debog: banana-trunk bed the puppets stand in
    trunk = [hx("0E0A08"), hx("1E1A10"), hx("2E2A16"), hx("3E3A1E"), hx("2A2614")]
    for i, y in enumerate(range(236, 270)):
        k = abs(y - 246) / 24.0
        col = trunk[min(4, int((1 - k) * 4.5))] if y < 262 else trunk[0]
        d.line([(0, y), (W, y)], fill=col)
    for x in range(0, W, 23):
        d.line([(x, 238), (x + 6, 238)], fill=hx("4E4A26"))
        d.point((x + 12, 250), fill=hx("0E0A08"))
    d.line([(0, 235), (W, 235)], fill=hx("0A0806"))
    return im


def gunungan():
    """The kayon / gunungan (tree-of-life puppet) as its shadow: a pointed leaf with a gate at the foot, a tree whose
    branches curl up the middle, a flame-tongue rim, and lace holes punched through the hide (light shows through)."""
    w, h = 80, 140
    m = np.zeros((h, w), bool)
    yy, xx = np.mgrid[0:h, 0:w]
    cx = w / 2 - 0.5
    body_h = 108
    t = yy / body_h                                         # 0 tip .. 1 base of the leaf
    half = 37 * np.sin(np.clip(t, 0, 1) ** 0.62 * math.pi * 0.5) ** 1.1
    half = np.where(t > 0.86, 37 - (t - 0.86) * 60, half)  # the leaf tucks in above the gate
    leaf = (np.abs(xx - cx) <= half) & (yy < body_h)
    # flame-tongue serrations on the rim
    ang = np.arctan2(yy - 70, xx - cx)
    serr = (np.sin(ang * 22) > 0.55) & (np.abs(xx - cx) > half - 2) & (np.abs(xx - cx) <= half + 2) & (yy > 6) & (yy < 96)
    m |= leaf | serr
    # the gate block, with steps
    m |= (yy >= 96) & (yy < 124) & (np.abs(xx - cx) <= 22)
    m |= (yy >= 124) & (yy < 128) & (np.abs(xx - cx) <= 26)
    m |= (yy >= 128) & (yy < 131) & (np.abs(xx - cx) <= 30)
    # the stick (gapit) below
    m |= (yy >= 131) & (np.abs(xx - cx) <= 1)

    solid = np.zeros_like(m)
    # rim band stays solid
    inner = (np.abs(xx - cx) <= half - 3) & (yy > 5) & (yy < body_h - 6)
    solid |= leaf & ~inner
    # the trunk and spiralling branches (solid lines inside the lace)
    solid |= (np.abs(xx - cx) <= 2) & (yy > 18) & (yy < 98)
    for side in (-1, 1):
        for k, y0 in enumerate(range(86, 22, -12)):
            for s in np.linspace(0, 1, 60):
                bx = cx + side * (s * (14 + k * 1.5))
                by = y0 - s * 10 - math.sin(s * math.pi) * 4
                rad = 1.4 - s * 0.6
                solid |= ((xx - bx) ** 2 + (yy - by) ** 2 <= rad * rad + 0.6)
            # the curl at each branch tip
            ex, ey = cx + side * (14 + k * 1.5), y0 - 10
            ring = np.abs(np.sqrt((xx - ex - side * 2) ** 2 + (yy - ey + 2) ** 2) - 2.5) < 0.8
            solid |= ring & leaf
    # a pair of facing birds near the crown, and the kala head over the gate (as solid shapes)
    solid |= ((xx - cx) ** 2 / 16 + (yy - 14) ** 2 / 9 <= 1)
    solid |= (yy >= 96) & (yy < 104) & (np.abs(xx - cx) <= 22)
    lace = (((xx + (yy // 3) % 2 * 2) % 4 == 0) & (yy % 3 == 1))
    hole = leaf & ~solid & lace
    # gate doors: two arched openings
    door = (yy >= 106) & (yy < 124) & (np.abs(np.abs(xx - cx) - 9) <= 4)
    door &= ~((yy < 109) & (np.abs(np.abs(xx - cx) - 9) >= 3))
    hole |= door
    m &= ~hole
    a = np.zeros((h, w, 4), np.uint8)
    shadow = hx("1E0E1C")
    a[m] = shadow
    a[m, 3] = 238
    a[(yy >= 131) & m] = hx("0E060C")
    return Image.fromarray(a, "RGBA")


# ---------------------------------------------------------------------------------------------------------------
# Act 2: Kala, the devourer (the kala head of the temple gates: bulging eyes, upper jaw and fangs, flame hair)
# ---------------------------------------------------------------------------------------------------------------

def kala_head():
    w, h = 300, 190
    cx = w // 2
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    base, mid, hi = hx("1A0A1E"), hx("2E1232"), hx("4A1A44")
    # flame hair: tongues radiating from behind the brow
    for i in range(23):
        a = math.pi * (1.08 + i * 0.84 / 22)
        r0, r1 = 70, 108 + 14 * math.sin(i * 1.7)
        x0, y0 = cx + math.cos(a) * r0, 104 + math.sin(a) * r0 * 0.9
        x1, y1 = cx + math.cos(a) * r1 * 1.25, 104 + math.sin(a) * r1 * 0.88
        perp = a + math.pi / 2
        curl = 10 * (1 if i % 2 else -1)
        mx, my = (x0 + x1) / 2, (y0 + y1) / 2
        d.polygon([(x0 + math.cos(perp) * 11, y0 + math.sin(perp) * 11),
                   (mx + math.cos(perp) * 9 + curl * 0.4, my + math.sin(perp) * 9),
                   (x1 + curl, y1), (x1 + curl * 1.6, y1 + 6), (x1 + curl * 0.6, y1 + 5),
                   (mx - math.cos(perp) * 6, my - math.sin(perp) * 6),
                   (x0 - math.cos(perp) * 11, y0 - math.sin(perp) * 11)], fill=base if i % 2 else mid)
    # side flames curling down past the cheeks
    for s in (-1, 1):
        for k in range(5):
            x0 = cx + s * (92 + k * 6)
            y0 = 92 + k * 16
            d.polygon([(x0, y0), (x0 + s * 30, y0 + 4 - k * 2), (x0 + s * 14, y0 + 16)], fill=base if k % 2 else mid)
    # the face mass
    d.ellipse((cx - 98, 40, cx + 98, 168), fill=mid)
    d.rectangle((cx - 104, 104, cx + 104, 150), fill=mid)
    # crown band with jewels
    d.chord((cx - 92, 26, cx + 92, 100), 180, 360, fill=hi)
    d.rectangle((cx - 92, 58, cx + 92, 66), fill=base)
    for k in range(-4, 5):
        x = cx + k * 19
        d.polygon([(x - 6, 58), (x, 40 - (6 if k == 0 else 0) + abs(k) * 2), (x + 6, 58)], fill=hi)
        d.rectangle((x - 1, 61, x + 1, 63), fill=hx("C98A52"))
    # brows: heavy curling ridges
    for s in (-1, 1):
        ex = cx + s * 46
        d.chord((ex - 34, 64, ex + 34, 104), 180, 360, fill=hi)
        d.ellipse((ex + s * 24 - 6, 66, ex + s * 24 + 6, 78), fill=mid)  # brow curl
    # eye sockets (the eyes are a separate layer that lights up)
    for s in (-1, 1):
        ex = cx + s * 46
        d.ellipse((ex - 26, 76, ex + 26, 118), fill=base)
        d.ellipse((ex - 22, 80, ex + 22, 114), fill=hx("0C0410"))
    # the nose: a broad bulb with flared nostrils
    d.ellipse((cx - 22, 96, cx + 22, 132), fill=hi)
    d.ellipse((cx - 30, 112, cx - 8, 134), fill=mid)
    d.ellipse((cx + 8, 112, cx + 30, 134), fill=mid)
    d.ellipse((cx - 22, 120, cx - 12, 128), fill=base)
    d.ellipse((cx + 12, 120, cx + 22, 128), fill=base)
    # moustache curls
    for s in (-1, 1):
        d.chord((cx + s * 38 - 22, 124, cx + s * 38 + 22, 146), 180, 360, fill=hi)
    # the maw: the upper jaw only, a wide dark mouth with a row of teeth and two great fangs
    d.chord((cx - 92, 110, cx + 92, 210), 0, 180, fill=hx("060208"))
    d.rectangle((cx - 92, 140, cx + 92, 160), fill=hx("060208"))
    d.rectangle((cx - 104, 136, cx + 104, 141), fill=hi)  # the lip
    teeth = hx("D8C8B8")
    for k in range(-6, 7):
        x = cx + k * 12
        if abs(k) == 5:
            continue
        d.polygon([(x - 5, 141), (x + 5, 141), (x, 151)], fill=teeth)
        d.line([(x + 4, 142), (x, 150)], fill=hx("8C7C70"))
    for s in (-1, 1):   # fangs
        x = cx + s * 60
        d.polygon([(x - 8, 141), (x + 8, 141), (x + s * 6, 178)], fill=teeth)
        d.line([(x + s * 7, 142), (x + s * 6, 176)], fill=hx("8C7C70"))
    im = rim(im, ROSE, dirs=((0, -1),))
    im = rim(im, hx("8A2848"), dirs=((-1, 0), (1, 0)))
    return outline(im, hx("050206"))


def kala_eyes():
    """Glowing eyes for the sockets of kala_head (same canvas size so they line up)."""
    w, h = 300, 190
    cx = w // 2
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    for s in (-1, 1):
        ex = cx + s * 46
        d.ellipse((ex - 21, 81, ex + 21, 113), fill=hx("F2B27A"))
        d.ellipse((ex - 17, 84, ex + 17, 110), fill=hx("FFE2A8"))
        d.ellipse((ex - 11, 87, ex + 11, 107), fill=ROSE)
        d.ellipse((ex - 6, 92, ex + 6, 102), fill=hx("2A0610"))
        d.rectangle((ex - 1, 89, ex + 1, 105), fill=hx("2A0610"))   # slit
        d.point((ex - s * 12, 88), fill=CREAM)
        d.point((ex - s * 11, 88), fill=CREAM)
        d.point((ex - s * 12, 89), fill=CREAM)
    return im


def ink_edges():
    """Four steps of ink crawling in from the frame edges, tendrils reaching for the middle."""
    yy, xx = np.mgrid[0:H, 0:W]
    edge = np.minimum(np.minimum(xx, W - 1 - xx) / (W / 2), np.minimum(yy, H - 1 - yy) / (H / 2))
    n = fbm(H, W, 48, 21, 4)
    streak = value_noise(H, W, 9, 33)
    ang = np.arctan2(yy - H / 2, xx - W / 2)
    tendril = (np.sin(ang * 13 + n * 6) * 0.5 + 0.5) ** 6 * 0.35
    field = edge - (n - 0.5) * 0.28 - tendril * 0.6 - (streak - 0.5) * 0.05
    out = []
    for i, lvl in enumerate((0.08, 0.16, 0.27, 0.85)):
        ink = field < lvl
        lip = (field < lvl + 0.025) & ~ink
        a = np.zeros((H, W, 4), np.uint8)
        a[ink] = LACQUER
        a[lip] = hx("3A1030")
        out.append(save(Image.fromarray(a, "RGBA"), "ink_%d" % i))
    return out


def ash_shard():
    """A tiny falling flake of a burned glyph (particle texture)."""
    im = Image.new("RGBA", (3, 3), (0, 0, 0, 0))
    for p in [(1, 0), (0, 1), (1, 1), (2, 1), (1, 2)]:
        im.putpixel(p, (255, 255, 255, 255))
    return im


# ---------------------------------------------------------------------------------------------------------------
# Act 3: dawn over the volcano, the Wiku on the peak
# ---------------------------------------------------------------------------------------------------------------

SKY = [hx("120C2A"), hx("1E1440"), hx("34205A"), hx("552A6A"), hx("7E3470"), hx("AE4672"), hx("D8606A"),
       hx("EE845E"), hx("F6A85C"), hx("FCCB78"), hx("FFE7A8")]
SUN = (240, 196)


def dawn_sky():
    yy, xx = np.mgrid[0:H, 0:W]
    v = (yy / 205.0) ** 1.35
    d2 = np.sqrt(((xx - SUN[0]) / 1.6) ** 2 + (yy - SUN[1]) ** 2)
    v = v + np.clip(1 - d2 / 170, 0, 1) ** 2 * 0.45
    im = banded(np.clip(v, 0, 1), SKY)
    a = np.array(im)
    # sun rays: faint lighter wedges fanning up
    ang = np.arctan2(yy - SUN[1], xx - SUN[0])
    ray = (np.sin(ang * 16) > 0.82) & (yy < SUN[1]) & (d2 < 230) & (bayer(H, W) > 0.4)
    a[ray] = np.clip(a[ray].astype(int) + 22, 0, 255).astype(np.uint8)
    im = Image.fromarray(a, "RGBA")
    d = ImageDraw.Draw(im)
    for k, (r, col) in enumerate([(40, hx("FFE7A8")), (33, hx("FFF2CC")), (28, hx("FFFBEA"))]):
        d.ellipse((SUN[0] - r, SUN[1] - r, SUN[0] + r, SUN[1] + r), fill=col)
    # stars still out at the top
    r = np.random.default_rng(5)
    for _ in range(70):
        x, y = int(r.integers(0, W)), int(r.integers(0, 70))
        d.point((x, y), fill=hx("ECE6F2", int(120 + r.integers(0, 120) * (1 - y / 70))))
    # a few long cloud bands across the sun
    for y, x0, x1, col in [(150, 60, 230, hx("C25670")), (154, 250, 420, hx("C25670")), (172, 140, 330, hx("E07A62")),
                           (118, 300, 470, hx("8E3A72")), (110, 10, 150, hx("8E3A72"))]:
        d.line([(x0, y), (x1, y)], fill=col)
        d.line([(x0 + 10, y + 1), (x1 - 14, y + 1)], fill=col)
    return im


def ridge_profile(seed, base_y, amp, cells, peaks=()):
    xs = np.arange(W)
    n = fbm(1, W, cells, seed, 3)[0]
    y = base_y - (n - 0.5) * amp
    for px, py, pw in peaks:   # volcano cones: steep near the crater, spreading into long gentle slopes
        k = np.clip(1 - np.maximum(np.abs(xs - px) - 7, 0) / pw, 0, 1)
        rough = (fbm(1, W, 6, seed + px, 2)[0] - 0.5) * 5 * (1 - k)
        cone = base_y - (base_y - py) * k ** 1.9 + rough
        cone = np.where(np.abs(xs - px) < 7, py + 1 + (np.abs(xs - px) < 4), cone)   # the notched crater rim
        y = np.minimum(y, cone)
    return y


def layer_from_profile(y, colour, rim_col=None, fade=None):
    a = np.zeros((H, W, 4), np.uint8)
    yy = np.arange(H)[:, None]
    m = yy >= np.round(y)[None, :]
    a[m] = colour
    if fade is not None:   # lighter haze near the top edge of the layer
        top = (yy >= np.round(y)[None, :]) & (yy < np.round(y)[None, :] + 6) & (bayer(H, W) < 0.5)
        a[top] = fade
    if rim_col is not None:
        edge = (yy == np.round(y)[None, :])
        a[edge] = rim_col
    return Image.fromarray(a, "RGBA")


def dawn_far():
    y = ridge_profile(3, 196, 26, 90, peaks=[(118, 118, 78), (372, 136, 70)])
    return layer_from_profile(y, hx("8E3E6E"), hx("D8706E"), hx("A44E72"))


def dawn_haze():
    y = ridge_profile(17, 206, 18, 70, peaks=[(250, 168, 60)])
    return layer_from_profile(y, hx("6E3068"), hx("C8606E"))


def dawn_mid():
    y = ridge_profile(9, 222, 30, 50)
    # a tree line: little crowns on the ridge
    r = np.random.default_rng(2)
    for x in range(0, W, 3):
        if r.random() < 0.55:
            y[x] -= r.integers(2, 7)
    im = layer_from_profile(y, hx("4A1C4C"), hx("B04E66"))
    d = ImageDraw.Draw(im)
    for x in range(8, W, 37):   # palms
        base = int(y[x])
        d.line([(x, base), (x + 2, base - 16)], fill=hx("4A1C4C"))
        for dx, dy in [(-6, 2), (6, 1), (-4, -2), (5, -3), (0, -4)]:
            d.line([(x + 2, base - 16), (x + 2 + dx, base - 16 + dy + 3)], fill=hx("4A1C4C"))
    return im


def dawn_peak():
    """The foreground peak, the Wiku stands on its top at (240, 206)."""
    xs = np.arange(W)
    n = fbm(1, W, 24, 41, 3)[0]
    dist = np.maximum(np.abs(xs - 240) - 9, 0)
    y = 206 + dist ** 1.3 * 0.2 + (n - 0.5) * 10 * np.clip(dist / 40, 0, 1)
    y = y + ((xs % 5 == 0) & (dist > 0)) * 1   # broken rock edge
    im = layer_from_profile(y, hx("1A0C22"))
    a = np.array(im)
    # rock strata and a warm rim where the sun catches the top
    yy, xx = np.mgrid[0:H, 0:W]
    top = np.round(y)[None, :]
    strata = (((yy - top) % 9 == 0) | ((yy + xx // 7) % 13 == 0)) & (yy > top + 2) & (bayer(H, W) < 0.6)
    a[strata] = hx("2A1430")
    for k, col in enumerate([hx("F6A85C"), hx("C25670"), hx("6A2448")]):
        a[(yy == top + k) & (yy < H)] = col
    return Image.fromarray(a, "RGBA")


def hero():
    """The Wiku from behind, two frames (48x72 each): staff planted, and staff raised to write in the sky.
    A dark silhouette with a warm rim from the sun ahead and a cyan rim from the staff's gem."""
    fw, fh = 48, 72
    sheet = Image.new("RGBA", (fw * 2, fh), (0, 0, 0, 0))
    body = hx("120818")
    cloth = hx("1E0E26")
    for f in range(2):
        im = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        cx = 24
        # the selendang scarf streaming right in the wind
        d.polygon([(cx + 2, 26), (cx + 22, 30), (cx + 23, 34), (cx + 19, 33), (cx + 24, 39), (cx + 14, 36), (cx + 3, 31)],
                  fill=cloth)
        # robe flaring to the feet
        d.polygon([(cx - 7, 28), (cx + 7, 28), (cx + 12, 66), (cx + 6, 70), (cx - 6, 70), (cx - 12, 66)], fill=body)
        d.polygon([(cx + 6, 40), (cx + 15, 64), (cx + 12, 66)], fill=cloth)   # robe flap in the wind
        # shoulders, head with the iket headcloth and its knot
        d.ellipse((cx - 10, 22, cx + 10, 34), fill=body)
        d.ellipse((cx - 6, 10, cx + 6, 24), fill=body)
        d.polygon([(cx - 7, 13), (cx + 7, 13), (cx + 6, 8), (cx - 6, 8)], fill=cloth)
        d.polygon([(cx + 5, 10), (cx + 11, 6), (cx + 10, 12)], fill=cloth)
        if f == 0:
            # staff planted at the right side, hand on it
            d.line([(cx + 13, 6), (cx + 13, 70)], fill=hx("2A1820"), width=2)
            d.polygon([(cx + 8, 28), (cx + 14, 36), (cx + 12, 40), (cx + 6, 32)], fill=body)
            gem = (cx + 13, 4)
        else:
            # both arms up, staff held high and tilted: the moment of writing
            d.polygon([(cx + 6, 26), (cx + 14, 6), (cx + 17, 8), (cx + 10, 30)], fill=body)
            d.polygon([(cx - 6, 26), (cx - 10, 10), (cx - 7, 9), (cx - 3, 26)], fill=body)
            d.line([(cx + 6, 34), (cx + 19, -2)], fill=hx("2A1820"), width=2)
            gem = (cx + 19, 1)
        im = rim(im, hx("F6A85C"), dirs=((0, -1), (1, 0)))
        im = rim(im, HALO, dirs=((-1, 0),))
        d = ImageDraw.Draw(im)
        gx, gy = gem
        d.ellipse((gx - 3, gy - 2, gx + 3, gy + 4), outline=hx("C98A52"))   # the crescent head of the staff
        d.point((gx, gy + 1), fill=CYAN)
        d.point((gx, gy + 2), fill=CREAM)
        sheet.paste(im, (f * fw, 0))
    return sheet


def beam():
    """A vertical shaft of glyph light, cyan to white core, thinning to nothing at the top."""
    w, h = 40, 270
    yy, xx = np.mgrid[0:h, 0:w]
    dx = np.abs(xx + 0.5 - w / 2) / (w / 2)
    v = np.clip(1 - dx, 0, 1) ** 1.4 * (0.35 + 0.65 * (yy / h) ** 0.5)
    cols = [(0, 0, 0, 0), hx("3FB8C0", 90), hx("3FB8C0", 170), hx("7FE8E0", 220), hx("D8FFF8"), CREAM]
    return banded(v, cols)


def ring():
    """A shockwave ring, 2 px thick, drawn once and scaled up in the scene."""
    s = 96
    im = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.ellipse((1, 1, s - 2, s - 2), outline=CREAM, width=2)
    d.ellipse((4, 4, s - 5, s - 5), outline=hx("7FE8E0", 160), width=1)
    return im


# ---------------------------------------------------------------------------------------------------------------

def main():
    out = {
        "blencong": blencong(), "flame": flame_sheet(), "kelir": kelir(), "gunungan": gunungan(),
        "kala_head": kala_head(), "kala_eyes": kala_eyes(),
        "glow_warm": alpha_glow(160, hx("F2B27A"), 6, 210, 1.7),
        "glow_cyan": alpha_glow(96, hx("7FE8E0"), 5, 200, 1.5),
        "glow_red": alpha_glow((360, 240), hx("B02040"), 6, 230, 1.1),
        "dawn_sky": dawn_sky(), "dawn_far": dawn_far(), "dawn_haze": dawn_haze(), "dawn_mid": dawn_mid(), "dawn_peak": dawn_peak(),
        "hero_wiku": hero(), "beam": beam(), "ring": ring(), "shard": ash_shard(),
    }
    for k, im in out.items():
        save(im, k)
    inks = ink_edges()
    storyboard(out, inks)


def _template(glyph):
    """First recogniser template of data/glyphs/<glyph>.tres as a list of points."""
    import re
    txt = open(os.path.join(ROOT, "data", "glyphs", glyph + ".tres")).read()
    nums = [float(v) for v in re.search(r"PackedVector2Array\(([^)]*)\)", txt).group(1).split(",")]
    return list(zip(nums[0::2], nums[1::2]))


def _draw_glyph(img, glyph, centre, box, colour, width=2):
    pts = _template(glyph)
    xs, ys = [p[0] for p in pts], [p[1] for p in pts]
    s = min(box[0] / max(1, max(xs) - min(xs)), box[1] / max(1, max(ys) - min(ys)))
    cx, cy = (max(xs) + min(xs)) / 2, (max(ys) + min(ys)) / 2
    q = [(round(centre[0] + (x - cx) * s), round(centre[1] + (y - cy) * s)) for x, y in pts]
    d = ImageDraw.Draw(img)
    d.line(q, fill=colour[:3] + (80,), width=width + 4)
    d.line(q, fill=colour, width=width + 1)
    d.line(q, fill=(255, 255, 255, 220), width=max(1, width - 1))


def storyboard(a, inks):
    """tools/intro_preview.png: six key frames of the intro, staged the way ui/intro.gd places things."""
    frames = []
    lamp, spout = (208, 58), (211, 79)
    flame = a["flame"].crop((0, 0, 12, 22))
    # 1: the lamp catches in the dark
    f = Image.new("RGBA", (W, H), LACQUER)
    f.alpha_composite(a["glow_warm"], (spout[0] + 14 - 80, spout[1] - 80))
    f.alpha_composite(a["blencong"], lamp)
    f.alpha_composite(flame, (spout[0] - 6, spout[1] - 21))
    frames.append(f)
    # 2: the gunungan on the kelir, the lamp hauled up over it
    f = a["kelir"].copy()
    g = a["glow_warm"].copy()
    g.putalpha(g.getchannel("A").point(lambda v: int(v * 0.45)))
    f.alpha_composite(g, (spout[0] + 14 - 80, spout[1] - 46 - 80))
    f.alpha_composite(a["gunungan"], (200, 100))
    f.alpha_composite(a["blencong"], (lamp[0], lamp[1] - 46))
    f.alpha_composite(flame, (spout[0] - 6, spout[1] - 46 - 21))
    frames.append(f)
    # 3: ha na ca ra ka over the darkened screen
    k = np.array(a["kelir"]).astype(float)
    k[..., :3] *= np.array([0.22, 0.2, 0.42])
    f = Image.fromarray(k.astype(np.uint8), "RGBA")
    for i, gl in enumerate(["jawa_ha", "jawa_na", "jawa_ca", "jawa_ra", "jawa_ka"]):
        c = (80 + i * 80, 112)
        gw = a["glow_cyan"].copy()
        gw.putalpha(gw.getchannel("A").point(lambda v: int(v * 0.7)))
        f.alpha_composite(gw, (c[0] - 48, c[1] - 48))
        _draw_glyph(f, gl, c, (60, 44), CYAN)
    frames.append(f)
    # 4: Kala wakes
    k = np.array(a["kelir"]).astype(float)
    k[..., :3] *= np.array([0.6, 0.12, 0.2])
    f = Image.fromarray(k.astype(np.uint8), "RGBA")
    f.alpha_composite(a["glow_red"], (60, 42))
    f.alpha_composite(a["kala_head"], (90, 62))
    f.alpha_composite(a["kala_eyes"], (90, 62))
    for i, gl in enumerate(["jawa_ha", "jawa_na", "jawa_ca", "jawa_ra", "jawa_ka"]):
        _draw_glyph(f, gl, (80 + i * 80, 50), (60, 44), ROSE)
    f.alpha_composite(inks[1])
    frames.append(f)
    # 5: dawn, the Wiku writes Ka
    dawn = a["dawn_sky"].copy()
    for k2 in ("dawn_far", "dawn_haze", "dawn_mid", "dawn_peak"):
        dawn.alpha_composite(a[k2])
    f = dawn.copy()
    f.alpha_composite(a["glow_cyan"], (259 - 48, 137 - 48))
    f.alpha_composite(a["hero_wiku"].crop((48, 0, 96, 72)), (216, 136))
    _draw_glyph(f, "sunda_ka", (240, 68), (120, 104), CYAN, 3)
    frames.append(f)
    # 6: the light and the logo
    f = dawn.copy()
    arr = np.array(f).astype(float)
    arr[..., :3] *= np.array([0.55, 0.5, 0.65])
    f = Image.fromarray(arr.astype(np.uint8), "RGBA")
    f.alpha_composite(a["beam"].crop((0, 0, 40, 137)).resize((56, 137), Image.NEAREST), (259 - 28, 0))
    f.alpha_composite(a["hero_wiku"].crop((48, 0, 96, 72)), (216, 136))
    rg = a["ring"].resize((260, 260), Image.NEAREST)
    f.alpha_composite(rg, (259 - 130, 137 - 130))
    logo = Image.open(os.path.join(ROOT, "assets", "art", "ui", "logo.png")).convert("RGBA")
    f.alpha_composite(logo, (240 - logo.width // 2, 96 - logo.height // 2))
    frames.append(f)
    sheet = Image.new("RGBA", (W * 2 + 4, H * 3 + 8), (0, 0, 0, 255))
    for i, fr in enumerate(frames):
        sheet.paste(fr, ((i % 2) * (W + 4), (i // 2) * (H + 4)))
    sheet.save(os.path.join(ROOT, "tools", "intro_preview.png"))


if __name__ == "__main__":
    main()
