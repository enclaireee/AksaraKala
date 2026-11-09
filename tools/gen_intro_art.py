#!/usr/bin/env python3
"""Art for the launch intro (ui/intro.gd, ui.md 4.0) -> assets/art/intro/.

Ten seconds, no words: Kala's face in the storm clouds, the Wiku on the crag, Ka written in light, dawn.
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
# Kala, the devourer (the kala head of the temple gates: bulging eyes, upper jaw and fangs, flame hair).
# Not saved on its own: kala_cloud() rebuilds it out of storm cloud.
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


# ---------------------------------------------------------------------------------------------------------------
# Dawn (after the light breaks the storm) and the shared ridge helpers
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
# The storm: Kala's face in the clouds, the volcanoes, the crag and the Wiku
# ---------------------------------------------------------------------------------------------------------------

STORM = [hx("0A0612"), hx("120A1E"), hx("1C0E2A"), hx("2A1234"), hx("3C1638"), hx("561C3A"), hx("76223C"),
         hx("9A2E40"), hx("C44448"), hx("E8704E")]
KALA_CLOUD = [hx("080310"), hx("120616"), hx("1E0A1E"), hx("2E0E26"), hx("44142E"), hx("601A34"), hx("82243A"),
              hx("AA3242"), hx("D64A4C")]
VOLCANO = (446, 158)        # the erupting cone behind the hero
HERO_FEET = (372, 206)      # top of the crag; ui/intro.gd HERO_POS puts the sprite's feet here
CLOSE = (2.8, (-180, -152))  # kala_head scale and origin for the close-up: the eyes centred at (240, 120)
CLOSE_LOOK = dict(soft=1, cell=6, power=2.2, lift=0.0)   # crisper and darker than the sky version
SKY_KALA = (1.15, (27, -6))  # ... and for the wide shot: the face looming over the left of the sky


def storm_sky():
    """Bruised storm clouds, darkest at the top, burning red towards the horizon and the erupting volcano."""
    yy, xx = np.mgrid[0:H, 0:W]
    c = fbm(H * 2, W, 44, 71, 5)[::2]               # sampled every other row: the clouds stretch out wide
    fine = fbm(H, W, 8, 73, 2)
    v = 0.06 + (yy / H) ** 1.5 * 0.5 + (c - 0.5) * 0.7 + (fine - 0.5) * 0.08
    d = np.sqrt(((xx - VOLCANO[0]) / 1.5) ** 2 + (yy - VOLCANO[1] - 40) ** 2)
    v += np.clip(1 - d / 210, 0, 1) ** 2 * 0.55       # the eruption lights the cloud from below
    d2 = np.sqrt(((xx - 200) / 2.2) ** 2 + (yy - 210) ** 2)
    v += np.clip(1 - d2 / 160, 0, 1) ** 2 * 0.25
    im = banded(np.clip(v, 0, 1), STORM)
    # the ash column over the crater, leaning with the wind
    a = np.array(im)
    col = np.abs(xx - (VOLCANO[0] + (VOLCANO[1] - yy) * 0.35)) < (8 + (VOLCANO[1] - yy) * 0.28 + (c - 0.5) * 30)
    col &= (yy < VOLCANO[1]) & (bayer(H, W) < 0.5 + (yy / VOLCANO[1]) * 0.5)
    a[col] = hx("1C0A1C")
    return Image.fromarray(a, "RGBA")


def _kala_maps(scale):
    """kala_head as two float maps (shade 0..1, alpha 0..1), scaled up smooth so its shapes stay clean curves."""
    a = np.array(kala_head()).astype(np.float32)
    lum = (0.3 * a[..., 0] + 0.59 * a[..., 1] + 0.11 * a[..., 2]) / 255.0
    shade = np.clip(lum / 0.2, 0, 1) ** 0.8
    size = (round(300 * scale), round(190 * scale))
    up = lambda m: np.array(Image.fromarray(m.astype(np.float32), "F").resize(size, Image.BICUBIC))
    return up(shade), up(a[..., 3] / 255.0)


def _place(m, origin, canvas):
    """Paste float map `m` at `origin` on a zero canvas (w, h), clipped."""
    w, h = canvas
    out = np.zeros((h, w), np.float32)
    ox, oy = origin
    x0, y0 = max(0, ox), max(0, oy)
    x1, y1 = min(w, ox + m.shape[1]), min(h, oy + m.shape[0])
    if x1 > x0 and y1 > y0:
        out[y0:y1, x0:x1] = m[y0 - oy:y1 - oy, x0 - ox:x1 - ox]
    return out


def blur(m, r):
    """Box blur, applied twice (close to a gaussian), radius r px."""
    k = 2 * r + 1
    for _ in range(2):
        for ax in (0, 1):
            p = np.pad(m, [(r, r) if a == ax else (0, 0) for a in (0, 1)], mode="edge")
            c = np.cumsum(p, axis=ax, dtype=np.float64)
            c = np.insert(c, 0, 0, axis=ax)
            m = (np.take(c, range(k, c.shape[ax]), axis=ax) - np.take(c, range(0, c.shape[ax] - k), axis=ax)) / k
    return m.astype(np.float32)


def kala_cloud(scale, origin, seed=90, soft=2, fray=0.9, cell=9, power=1.5, lift=0.25):
    """Kala's face made of storm cloud: the temple-gate kala head, huge, filled with churning cloud and frayed
    into wisps at its edges, lit red from below. `soft` rounds the shapes into billows, `fray` tears the edge."""
    shade, alpha = _kala_maps(scale)
    S, A = _place(shade, origin, (W, H)), _place(alpha, origin, (W, H))
    S, A = blur(S, soft), blur(A, soft + 1)
    n = fbm(H, W, max(6, int(cell * scale)), seed, 4)
    fine = fbm(H, W, 3, seed + 5, 2)
    v = np.clip(S, 0, 1) ** power * 0.95 + (n - 0.5) * 0.38 + (fine - 0.5) * 0.1
    yy = np.arange(H)[:, None]
    v += np.clip((yy - H * 0.55) / H, 0, 1) * lift     # brighter low down, over the fire
    im = np.array(banded(np.clip(v, 0, 1), KALA_CLOUD))
    edge = A + (n - 0.5) * fray
    solid = edge > 0.5
    fringe = (edge > 0.25) & ~solid & (bayer(H, W) < (edge - 0.25) / 0.25)   # dithered wisps fading out
    im[..., 3] = np.where(solid, 255, np.where(fringe, 140, 0)).astype(np.uint8)
    out = Image.fromarray(im, "RGBA")
    out = rim(out, hx("B03A48"), dirs=((0, 1),))      # lit from the fire below
    return rim(out, hx("3A1430"), dirs=((0, -1),))


EYE_COLS = [hx("F2B27A"), hx("FFE2A8"), ROSE, hx("2A0610"), CREAM]


def kala_cloud_eyes(scale, origin):
    """kala_eyes at the same scale and origin as kala_cloud, with a red glow baked around each eye."""
    e = kala_eyes().resize((round(300 * scale), round(190 * scale)), Image.BICUBIC)
    canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    r = round(42 * scale)
    for s in (-1, 1):
        cx, cy = origin[0] + (150 + s * 46) * scale, origin[1] + 97 * scale
        g = alpha_glow(r * 2, hx("E0566A"), 5, 170, 1.4)
        canvas.alpha_composite(g, (int(cx - r), int(cy - r)))
    a = np.array(e).astype(int)
    keep = a[..., 3] > 127
    pal = np.array([c[:3] for c in EYE_COLS])
    d = ((a[..., None, :3] - pal[None, None]) ** 2).sum(-1)
    snap = pal[d.argmin(-1)].astype(np.uint8)
    eyes = np.zeros(a.shape, np.uint8)
    eyes[..., :3] = snap
    eyes[..., 3] = keep * 255
    canvas.alpha_composite(Image.fromarray(eyes, "RGBA"), (int(origin[0]), int(origin[1])))
    return canvas


def storm_far():
    """Two volcanoes on the horizon; the right one erupts behind the hero, lava running down its flanks."""
    y = ridge_profile(23, 204, 22, 80, peaks=[(110, 162, 80), (VOLCANO[0], VOLCANO[1], 92)])
    im = layer_from_profile(y, hx("2C1030"), hx("C44448"), hx("3C1436"))
    a = np.array(im)
    r = np.random.default_rng(8)
    for k in range(7):   # lava rivulets wandering down from the crater
        x, yy = VOLCANO[0] + r.integers(-5, 6), VOLCANO[1] + 2
        side = -1 if k % 2 else 1
        while yy < 210:
            if 0 <= x < W and yy >= y[int(x)]:
                a[yy, x] = hx("E8704E") if yy < VOLCANO[1] + 18 else hx("C44448")
            yy += 1
            if r.random() < 0.5:
                x += side * (1 if r.random() < 0.8 else -1)
    d = ImageDraw.Draw(im := Image.fromarray(a, "RGBA"))
    d.rectangle((VOLCANO[0] - 6, VOLCANO[1] - 1, VOLCANO[0] + 6, VOLCANO[1] + 1), fill=hx("FFC27A"))
    return im


def storm_mid():
    y = ridge_profile(31, 230, 22, 46)
    r = np.random.default_rng(4)
    for x in range(0, W, 3):
        if r.random() < 0.5:
            y[x] -= r.integers(2, 6)
    im = layer_from_profile(y, hx("1A0A1E"), hx("76223C"))
    d = ImageDraw.Draw(im)
    for x in range(14, 330, 41):   # palms bent by the wind
        base = int(y[x])
        d.line([(x, base), (x + 4, base - 15)], fill=hx("1A0A1E"))
        for dx, dy in [(5, 3), (7, 1), (6, -2), (3, -3), (-3, 1)]:
            d.line([(x + 4, base - 15), (x + 4 + dx, base - 15 + dy + 2)], fill=hx("1A0A1E"))
    return im


def storm_peak():
    """The crag the Wiku stands on: a spire on the right with a cliff dropping away to the left."""
    xs = np.arange(W).astype(float)
    n = fbm(1, W, 18, 43, 3)[0]
    fx = HERO_FEET[0]
    left = np.maximum(fx - 12 - xs, 0)
    right = np.maximum(xs - fx - 14, 0)
    y = HERO_FEET[1] + left ** 1.35 * 0.55 + right ** 1.1 * 0.22 + (n - 0.5) * 8 * np.clip((left + right) / 30, 0, 1)
    y = y + ((xs.astype(int) % 4 == 0) & ((left + right) > 0)) * 1
    im = layer_from_profile(y, hx("0E0612"))
    a = np.array(im)
    yy, xx = np.mgrid[0:H, 0:W]
    top = np.round(y)[None, :]
    cracks = (((yy + xx // 3) % 11 == 0) | ((yy - xx // 5) % 17 == 0)) & (yy > top + 2) & (bayer(H, W) < 0.5)
    a[cracks] = hx("1C0C20")
    lit = xx > fx - 30   # the eruption behind rims the crag on its right and top
    for k, col in enumerate([hx("F6A85C"), hx("C44448"), hx("5A1A34")]):
        a[(yy == top + k) & lit] = col
        a[(yy == top + k) & ~lit & (k > 0)] = hx("3A1230")
    return Image.fromarray(a, "RGBA")


def hero_storm():
    """The Wiku on the crag, seen from behind and side-on, facing left into the wind towards Kala.
    Three 64x96 frames: two with the cloak and scarf cracking in the wind, staff planted; one with the staff
    thrust up at the sky to write. Feet at (32, 95)."""
    fw, fh = 64, 96
    sheet = Image.new("RGBA", (fw * 3, fh), (0, 0, 0, 0))
    body, cloth = hx("100614"), hx("1C0A20")
    for f in range(3):
        im = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        cx = 30
        ph = (0.0, 1.0, 0.5)[f]
        # the cloak streaming right from the shoulders, its hem rippling
        hem = []
        for k in range(9):
            t = k / 8
            hem.append((cx + 4 + t * 30, 70 - t * 26 + math.sin(t * 7 + ph * 3.1) * 4))
        top = [(cx + 6 + t * 26, 28 + t * 6 + math.sin(t * 5 + ph * 3.1) * 2) for t in (0.3, 0.6, 0.85)]
        d.polygon([(cx - 4, 30), (cx + 6, 27)] + top + hem[::-1] + [(cx - 2, 74)], fill=cloth)
        # selendang scarf: two long ribbons snapping in the wind
        for off, ln in ((0, 30), (5, 22)):
            pts = [(cx + 4 + i * ln / 6, 30 + off - i * 1.6 + math.sin(i * 1.3 + ph * 4 + off) * 2.2) for i in range(7)]
            d.line(pts, fill=cloth, width=3 if off == 0 else 2)
        # robe flaring to the feet, pushed right by the wind
        d.polygon([(cx - 7, 30), (cx + 7, 30), (cx + 15, 90), (cx + 18 + ph * 2, 95), (cx - 9, 95), (cx - 10, 88)], fill=body)
        # shoulders, head, iket headcloth with its knot tails flying
        d.ellipse((cx - 10, 24, cx + 10, 38), fill=body)
        d.ellipse((cx - 7, 9, cx + 6, 25), fill=body)
        d.polygon([(cx - 8, 13), (cx + 7, 13), (cx + 6, 7), (cx - 7, 7)], fill=cloth)
        d.polygon([(cx + 5, 10), (cx + 15, 6 + ph * 2), (cx + 13, 12), (cx + 18, 13 - ph), (cx + 7, 15)], fill=cloth)
        if f < 2:
            # staff planted ahead of him, the left hand on it
            d.line([(cx - 13, 4), (cx - 13, 95)], fill=hx("26141E"), width=2)
            d.polygon([(cx - 6, 32), (cx - 14, 44), (cx - 11, 46), (cx - 3, 36)], fill=body)
            gem = (cx - 13, 2)
        else:
            # the staff thrust up and forward at the sky, both arms behind it
            d.polygon([(cx - 4, 30), (cx - 18, 10), (cx - 14, 8), (cx + 2, 30)], fill=body)
            d.polygon([(cx + 4, 30), (cx - 12, 16), (cx - 9, 13), (cx + 8, 30)], fill=body)
            d.line([(cx - 4, 40), (cx - 24, 4)], fill=hx("26141E"), width=2)
            gem = (cx - 25, 2)
        im = rim(im, hx("F6A85C"), dirs=((1, 0), (0, -1)))   # the eruption behind and to the right
        im = rim(im, hx("6A2448"), dirs=((-1, 0),))
        d = ImageDraw.Draw(im)
        gx, gy = gem
        d.ellipse((gx - 3, gy - 2, gx + 3, gy + 4), outline=hx("C98A52"))   # the crescent head of the staff
        d.point((gx, gy + 1), fill=CYAN)
        d.point((gx, gy + 2), fill=CREAM)
        sheet.paste(im, (f * fw, 0))
    return sheet


HERO_GEM_UP = (30 - 25, 3)   # the gem in the raised frame, relative to the frame's top-left (ui/intro.gd GEM_UP)


def lightning():
    """Two forked bolts side by side (hframes 2), 120x200 each: white core, violet halo."""
    fw, fh = 120, 200
    sheet = Image.new("RGBA", (fw * 2, fh), (0, 0, 0, 0))
    for f in range(2):
        r = np.random.default_rng(300 + f)
        im = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)

        def bolt(x, y, length, width, depth):
            pts = [(x, y)]
            while y < length:
                x += int(r.integers(-9, 10))
                y += int(r.integers(6, 14))
                pts.append((x, min(y, fh - 1)))
                if depth < 2 and r.random() < 0.16:
                    bolt(x, y, y + int(r.integers(30, 70)), max(1, width - 1), depth + 1)
            d.line(pts, fill=hx("6A4AAA", 110), width=width + 4)
            d.line(pts, fill=hx("C8B8FF"), width=width + 1)
            d.line(pts, fill=CREAM, width=max(1, width - 1))

        bolt(fw // 2 + (-14 if f else 10), 0, fh - 4, 2, 0)
        sheet.paste(im, (f * fw, 0))
    return sheet
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




def _dim(img, k):
    a = np.array(img).astype(float)
    a[..., :3] *= np.array(k)
    return Image.fromarray(a.astype(np.uint8), "RGBA")


def storyboard(a):
    """tools/intro_preview.png: four key frames, staged the way ui/intro.gd places things."""
    frames = []
    hero_at = (HERO_FEET[0] - 30, HERO_FEET[1] - 95)
    frame = lambda i: a["hero_storm"].crop((i * 64, 0, i * 64 + 64, 96))
    # 1: lightning shows the face in the clouds
    f = _dim(a["storm_sky"], (0.3, 0.3, 0.35))
    f.alpha_composite(a["kala_close"])
    f.alpha_composite(a["lightning"].crop((0, 0, 120, 200)), (330, 0))
    frames.append(f)
    # 2: the eyes open
    f = _dim(a["storm_sky"], (0.3, 0.3, 0.35))
    f.alpha_composite(_dim(a["kala_close"], (0.55, 0.5, 0.55)))
    f.alpha_composite(a["kala_close_eyes"])
    frames.append(f)
    # 3: the Wiku writes Ka at the face in the sky
    wide = a["storm_sky"].copy()
    wide.alpha_composite(a["kala_sky"])
    wide.alpha_composite(a["kala_sky_eyes"])
    for k in ("storm_far", "storm_mid", "storm_peak"):
        wide.alpha_composite(a[k])
    f = wide.copy()
    gem = (hero_at[0] + HERO_GEM_UP[0], hero_at[1] + HERO_GEM_UP[1])
    f.alpha_composite(a["glow_cyan"], (gem[0] - 48, gem[1] - 48))
    f.alpha_composite(frame(2), hero_at)
    _draw_glyph(f, "sunda_ka", (196, 96), (130, 110), CYAN, 3)
    frames.append(f)
    # 4: the light breaks the storm; dawn and the logo
    f = a["dawn_sky"].copy()
    for k in ("storm_far", "storm_mid", "storm_peak"):
        f.alpha_composite(_dim(a[k], (0.8, 0.7, 0.9)))
    f.alpha_composite(a["beam"].crop((0, 0, 40, gem[1])).resize((56, gem[1]), Image.NEAREST), (gem[0] - 28, 0))
    f.alpha_composite(frame(2), hero_at)
    logo = Image.open(os.path.join(ROOT, "assets", "art", "ui", "logo.png")).convert("RGBA")
    f.alpha_composite(logo, (240 - logo.width // 2, 70 - logo.height // 2))
    frames.append(f)
    sheet = Image.new("RGBA", (W * 2 + 4, H * 2 + 4), (0, 0, 0, 255))
    for i, fr in enumerate(frames):
        sheet.paste(fr, ((i % 2) * (W + 4), (i // 2) * (H + 4)))
    sheet.save(os.path.join(ROOT, "tools", "intro_preview.png"))


def main():
    out = {
        "storm_sky": storm_sky(),
        "kala_close": kala_cloud(*CLOSE, **CLOSE_LOOK), "kala_close_eyes": kala_cloud_eyes(*CLOSE),
        "kala_sky": kala_cloud(*SKY_KALA, seed=95, soft=3, fray=1.5, cell=12), "kala_sky_eyes": kala_cloud_eyes(*SKY_KALA),
        "storm_far": storm_far(), "storm_mid": storm_mid(), "storm_peak": storm_peak(),
        "hero_storm": hero_storm(), "lightning": lightning(),
        "glow_cyan": alpha_glow(96, hx("7FE8E0"), 5, 200, 1.5),
        "glow_red": alpha_glow((360, 240), hx("B02040"), 6, 230, 1.1),
        "dawn_sky": dawn_sky(), "beam": beam(), "ring": ring(),
    }
    for k, im in out.items():
        save(im, k)
    storyboard(out)


if __name__ == "__main__":
    main()
