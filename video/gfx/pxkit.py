#!/usr/bin/env python3
"""pxkit: pixel-art motion-graphics toolkit for the Aksara Kala trailer.

Everything is drawn on the game's native 480x270 grid (W x H) as PIL RGBA images, with HARD alpha (0 or 255) and
whole-pixel motion, then scaled 4x nearest-neighbour to 1920x1080 by ffmpeg (`render`).

Typography scale (define once, use everywhere):
    DISPLAY  Jersey10 40   big statements        TITLE  Jersey10 30   titles / region names
    SUB      Jersey10 20   subtitles / buttons   LABEL  Tiny5 16      labels, folktale lines
    CAP      Tiny5 8       captions (the game's own UI size)           HERO   Jersey10 60  one-word hits ("Free.")
All sizes are integer multiples of the fonts' native pixel grid and rendered with anti-aliasing OFF.
Safe area: SAFE = 16 px inset on the 480x270 grid.
"""
import math
import os
import random
import subprocess
from functools import lru_cache

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
ART = os.path.join(ROOT, "assets", "art")
FONTS = os.path.join(ROOT, "assets", "fonts")
OUT = os.path.join(ROOT, "video", "out", "gfx")
PREVIEW = os.path.join(ROOT, "video", "out", "preview")

W, H = 480, 270
FPS = 60
SAFE = 16


def rgb(h, a=255):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), a)


# ---------------------------------------------------------------- palette (the game's dusk palette, ui.md 5)
EDGE = rgb("0A0814")
WELL = rgb("0C0A18")
FILL = rgb("141026")
PAGE = rgb("1A1530")
RAISED = rgb("241C40")
HAIR = rgb("3A2F5C")
HAIR_LO = rgb("2B2347")
CREAM = rgb("F0E6D2")
HEAD = rgb("FFF4E6")
TEXT = rgb("ECE6F2")
LABEL_C = rgb("A99BC8")
DIM = rgb("8C83A6")
DIM_LO = rgb("5A4E80")
CYAN = rgb("7FE8E0")
CYAN_HI = rgb("D8FFFB")
CYAN_HALO = rgb("3FB8C0")
CYAN_DEEP = rgb("1F6E78")
AMBER = rgb("F2B27A")
AMBER_LO = rgb("C98A52")
AMBER_HI = rgb("FFE2BC")
ROSE = rgb("E0566A")
ROSE_LO = rgb("8E2F45")
EMBER_DEEP = rgb("5A1426")
GREEN = rgb("8FD9A0")
GREEN_LO = rgb("4E8A64")
NIGHT = rgb("0A0814")
CLEAR = (0, 0, 0, 0)

BAYER4 = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]])
BAYER8 = np.zeros((8, 8), int)
for _y in range(8):
    for _x in range(8):
        BAYER8[_y, _x] = int(BAYER4[_y % 4, _x % 4] * 4 + BAYER4[_y // 4 * 2 % 4, _x // 4 * 2 % 4] // 4)

# ---------------------------------------------------------------- math / easing


def clamp(v, a=0.0, b=1.0):
    return a if v < a else b if v > b else v


def prog(t, t0, dur):
    """0..1 progress of t inside [t0, t0+dur]."""
    return clamp((t - t0) / dur) if dur > 0 else (1.0 if t >= t0 else 0.0)


def ease_out(p):
    return 1 - (1 - p) ** 3


def ease_in(p):
    return p ** 3


def ease_io(p):
    return 3 * p * p - 2 * p ** 3


def step_ease(p, n=6):
    """Quantise a 0..1 progress into n steps (stepped, pixel-style motion)."""
    return math.floor(clamp(p) * n + 1e-9) / n if p < 1 else 1.0


def lerp(a, b, p):
    return a + (b - a) * p


def ri(v):
    return int(round(v))


def mixc(a, b, p):
    return tuple(int(round(a[i] + (b[i] - a[i]) * p)) for i in range(4))


# ---------------------------------------------------------------- canvas


def canvas(bg=None):
    """New 480x270 RGBA canvas: transparent when bg is None, else filled."""
    return Image.new("RGBA", (W, H), bg if bg is not None else CLEAR)


def hard(img):
    """Force 0/255 alpha (and zero colour under clear pixels)."""
    a = np.array(img)
    m = a[..., 3] >= 128
    a[..., 3] = np.where(m, 255, 0)
    a[~m] = 0
    return Image.fromarray(a, "RGBA")


@lru_cache(maxsize=None)
def load(path, hard_alpha=True):
    p = path if os.path.isabs(path) else os.path.join(ART, path)
    im = Image.open(p).convert("RGBA")
    return hard(im) if hard_alpha else im


def paste(c, img, x, y):
    """Composite img at (x, y) with clipping (hard alpha in, so plain mask paste is exact)."""
    c.paste(img, (int(x), int(y)), img)


def fill_mask(c, mask, x, y, col):
    c.paste(col, (int(x), int(y)), mask)


def scaled(img, k):
    return img.resize((img.width * k, img.height * k), Image.NEAREST)


# ---------------------------------------------------------------- fonts / text
_FONT_FILES = {"j10": "Jersey10-Regular.ttf", "j15": "Jersey15-Regular.ttf", "t5": "Tiny5-Regular.woff",
               "sunda": "NotoSansSundanese.ttf", "jawa": "NotoSansJavanese.ttf"}
DISPLAY = ("j10", 40)
TITLE = ("j10", 30)
SUB = ("j10", 20)
LABEL = ("t5", 16)
CAP = ("t5", 8)
HERO = ("j10", 60)


@lru_cache(maxsize=None)
def font(role):
    kind, size = role
    return ImageFont.truetype(os.path.join(FONTS, _FONT_FILES[kind]), size)


@lru_cache(maxsize=4096)
def tmask(s, role=SUB, track=0):
    """Crisp 1-bit text mask ('L', 0/255), layout box = advance width x (ascent+descent)."""
    f = font(role)
    asc, desc = f.getmetrics()
    if track == 0:
        w = int(math.ceil(f.getlength(s))) + 1
        m = Image.new("L", (w, asc + desc + 1), 0)
        d = ImageDraw.Draw(m)
        d.fontmode = "1"
        d.text((0, 0), s, font=f, fill=255)
        return m
    x = 0
    parts = []
    for ch in s:
        parts.append((x, ch))
        x += int(math.ceil(f.getlength(ch))) + track
    m = Image.new("L", (x + 1, asc + desc + 1), 0)
    d = ImageDraw.Draw(m)
    d.fontmode = "1"
    for px, ch in parts:
        d.text((px, 0), ch, font=f, fill=255)
    return m


def text_w(s, role=SUB, track=0):
    return tmask(s, role, track).width - 1


def text_h(role=SUB):
    a, d = font(role).getmetrics()
    return a + d


def wrap(s, role, maxw):
    words, lines, cur = s.split(), [], ""
    for w in words:
        nxt = (cur + " " + w).strip()
        if text_w(nxt, role) <= maxw or not cur:
            cur = nxt
        else:
            lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def dilate(m, r=1):
    return m.filter(ImageFilter.MaxFilter(2 * r + 1)) if r > 0 else m


def checker(w, h, phase=0):
    a = ((np.add.outer(np.arange(h), np.arange(w)) + phase) % 2 == 0)
    return Image.fromarray((a * 255).astype("uint8"), "L")


def mask_and(a, b):
    return Image.fromarray(np.minimum(np.array(a), np.array(b)), "L")


def mask_sub(a, b):
    return Image.fromarray(np.where(np.array(b) > 0, 0, np.array(a)).astype("uint8"), "L")


def text(c, s, x, y, role=SUB, col=CREAM, anchor="l", shadow=None, outline=None, glow=None, chars=None, mod=None,
         track=0, glow_r=3, glow_phase=0):
    """Draw crisp text. (x, y) = left/centre/right (anchor l/c/r) and TOP of the line box.
    shadow=(col, dx, dy)  outline=col  glow=(inner_col, outer_col) dithered halo  chars=n draws only the first n
    chars (typewriter, layout stays fixed)  mod=f(mask)->mask applies a reveal / dissolve to the glyph mask.
    Returns (x0, y0, x1, y1)."""
    full = tmask(s, role, track)
    if chars is not None:
        if chars <= 0:
            return (int(x), int(y), int(x), int(y))
        m = tmask(s[:chars], role, track)
        m = Image.new("L", full.size, 0) if m.size == (0, 0) else _pad_to(m, full.size)
    else:
        m = full
    w = full.width - 1
    x0 = int(x - (w // 2 if anchor == "c" else w if anchor == "r" else 0))
    y0 = int(y)
    if mod is not None:
        m = mod(m)
    if glow:
        d1 = dilate(m, 1)
        d3 = dilate(m, glow_r)
        ring2 = mask_and(mask_sub(d3, d1), _checker_like(d3, glow_phase))
        _blit_m(c, ring2, x0, y0, glow[1], glow_r)
        _blit_m(c, mask_sub(d1, m), x0, y0, glow[0], 1)
    if outline:
        _blit_m(c, dilate(m, 1), x0, y0, outline, 1)
    if shadow:
        sc, dx, dy = shadow
        fill_mask(c, m, x0 + dx, y0 + dy, sc)
    fill_mask(c, m, x0, y0, col)
    return (x0, y0, x0 + w, y0 + full.height)


def _pad_to(m, size):
    o = Image.new("L", size, 0)
    o.paste(m, (0, 0))
    return o


def _checker_like(m, phase=0):
    return checker(m.width, m.height, phase)


def _blit_m(c, m, x0, y0, col, margin):
    fill_mask(c, m, x0 - margin, y0 - margin, col)


def text_lines(c, lines, x, y, role=SUB, col=CREAM, anchor="c", gap=0, **kw):
    """Draw a stack of lines; returns the y after the last line."""
    for ln in lines:
        text(c, ln, x, y, role, col, anchor, **kw)
        y += text_h(role) + gap
    return y


# ---------------------------------------------------------------- reveal masks (pixel-style, no smooth alpha)


@lru_cache(maxsize=256)
def _noise(w, h, seed):
    return np.random.RandomState(seed).rand(h, w)


def m_dither(p, steps=8):
    """Ordered (Bayer) dither reveal, p 0..1 quantised to `steps`."""
    p = math.floor(clamp(p) * steps + 1e-9) / steps if p < 1 else 1.0

    def f(m):
        a = np.array(m)
        h, w = a.shape
        thr = (BAYER4[np.arange(h)[:, None] % 4, np.arange(w)[None, :] % 4] + 0.5) / 16.0
        return Image.fromarray(np.where(thr <= p, a, 0).astype("uint8"), "L")
    return f


def m_wipe(p, direction="r", soft=3):
    """Hard wipe with a 1-px dither edge. direction r = reveal from left to right."""
    def f(m):
        a = np.array(m)
        h, w = a.shape
        if direction in ("r", "l"):
            edge = p * (w + soft)
            xs = np.arange(w)[None, :] + (np.arange(h)[:, None] % 2) * (soft // 2)
            keep = xs < edge if direction == "r" else (w - 1 - xs) < edge
        else:
            edge = p * (h + soft)
            ys = np.arange(h)[:, None] + (np.arange(w)[None, :] % 2) * (soft // 2)
            keep = ys < edge if direction == "d" else (h - 1 - ys) < edge
        return Image.fromarray(np.where(keep, a, 0).astype("uint8"), "L")
    return f


def m_eat(p, seed=3, bias=0.5, tile=1, steps=12):
    """Letters are eaten away: random pixels (blocks of `tile`) vanish, biased left to right."""
    p = math.floor(clamp(p) * steps + 1e-9) / steps if p < 1 else 1.0

    def f(m):
        a = np.array(m)
        h, w = a.shape
        n = _noise((w + tile - 1) // tile + 1, (h + tile - 1) // tile + 1, seed)
        n = np.kron(n, np.ones((tile, tile)))[:h, :w]
        grad = np.tile(np.linspace(0, 1, w)[None, :], (h, 1))
        v = (1 - bias) * n + bias * grad * 0.9 + 0.05
        return Image.fromarray(np.where(v >= p * 1.1, a, 0).astype("uint8"), "L")
    return f


def m_chars(s, n):
    """Helper for scenes: how many chars of s a typewriter shows at count n (clamped)."""
    return int(clamp(n, 0, len(s)))


def dither_fade(c, col, p, steps=8):
    """Fade the whole canvas toward `col` by Bayer dither (p=1 -> solid col). Hard-alpha safe."""
    if p <= 0:
        return c
    p = math.floor(clamp(p) * steps + 1e-9) / steps if p < 1 else 1.0
    a = np.array(c)
    thr = (BAYER4[np.arange(H)[:, None] % 4, np.arange(W)[None, :] % 4] + 0.5) / 16.0
    sel = thr <= p
    a[sel] = col
    return Image.fromarray(a, "RGBA")


def dither_out(c, p, steps=8):
    """Alpha-canvas fade-out: Bayer-dither pixels to fully clear."""
    if p <= 0:
        return c
    p = math.floor(clamp(p) * steps + 1e-9) / steps if p < 1 else 1.0
    a = np.array(c)
    thr = (BAYER4[np.arange(H)[:, None] % 4, np.arange(W)[None, :] % 4] + 0.5) / 16.0
    a[thr <= p] = 0
    return Image.fromarray(a, "RGBA")


# ---------------------------------------------------------------- panels (the game's one dusk surface)


def panel(w, h, hair=HAIR, fill=FILL, edge=EDGE):
    """Chamfered 1 px outline, fill, 1 px hairline inset (gen_ui_dusk.panel, opaque fill)."""
    im = Image.new("RGBA", (w, h), CLEAR)
    px = im.load()
    for y in range(h):
        for x in range(w):
            if (x in (0, w - 1)) and (y in (0, h - 1)):
                continue
            px[x, y] = edge if (x in (0, w - 1) or y in (0, h - 1)) else fill
    for x in range(2, w - 2):
        px[x, 1] = hair
        px[x, h - 2] = hair
    for y in range(2, h - 2):
        px[1, y] = hair
        px[w - 2, y] = hair
    return im


def glow_panel(w, h, fill=FILL, hair=CYAN_HALO, spark=CYAN):
    im = panel(w, h, hair, fill)
    px = im.load()
    for (x, y) in ((2, 1), (1, 2), (w - 3, 1), (w - 2, 2), (2, h - 2), (1, h - 3), (w - 3, h - 2), (w - 2, h - 3)):
        px[x, y] = spark
    return im


def nine_slice(path, w, h, m):
    """9-slice a game PNG (assets/art/...) to w x h with margin m."""
    src = load(path)
    sw, sh = src.size
    out = Image.new("RGBA", (w, h), CLEAR)
    xs = [(0, m, 0, m), (m, sw - m, m, w - m), (sw - m, sw, w - m, w)]
    ys = [(0, m, 0, m), (m, sh - m, m, h - m), (sh - m, sh, h - m, h)]
    for sx0, sx1, dx0, dx1 in xs:
        for sy0, sy1, dy0, dy1 in ys:
            tile = src.crop((sx0, sy0, sx1, sy1)).resize((dx1 - dx0, dy1 - dy0), Image.NEAREST)
            out.paste(tile, (dx0, dy0))
    return out


def diamond(c, x, y, size=5, col=CYAN, core=CYAN_HI):
    """Small diamond pip centred at (x, y)."""
    r = size // 2
    d = ImageDraw.Draw(c)
    for dy in range(-r, r + 1):
        k = r - abs(dy)
        d.line([(x - k, y + dy), (x + k, y + dy)], fill=col)
    if core and size >= 5:
        c.putpixel((x, y), core)


def rule(c, x0, x1, y, col=HAIR, mid=CYAN, gap=0):
    """Ornamental divider: 1 px line with a diamond in the middle."""
    d = ImageDraw.Draw(c)
    cx = (x0 + x1) // 2
    d.line([(x0, y), (cx - 6 - gap, y)], fill=col)
    d.line([(cx + 6 + gap, y), (x1, y)], fill=col)
    diamond(c, cx, y, 5, mid, CYAN_HI)


# ---------------------------------------------------------------- aksara
SUNDA = {"ka": "ᮊ", "ga": "ᮌ", "nga": "ᮍ", "ca": "ᮎ", "la": "ᮜ", "ra": "ᮛ",
         "sa": "ᮞ", "ha": "ᮠ", "pa": "ᮕ", "ba": "ᮘ", "ta": "ᮒ"}
JAWA = {"ha": "ꦲ", "na": "ꦤ", "ca": "ꦕ", "ra": "ꦫ", "ka": "ꦏ", "ga": "ꦒ",
        "la": "ꦭ", "pa": "ꦥ", "wa": "ꦮ"}
SUNDA_ORDER = ["ka", "ga", "nga", "ca", "la", "ra", "sa", "ha", "pa", "ba", "ta"]
JAWA_ORDER = ["ha", "na", "ca", "ra", "ka", "ga", "la", "pa", "wa"]
SCRIPT_NAME = {"sunda": "Aksara Sunda", "jawa": "Aksara Jawa"}
SS = 6   # supersample: rendered at SS x then box-downsampled and thresholded -> crisp, correctly shaped pixels


@lru_cache(maxsize=512)
def aksara_mask(chars, script, size, thresh=96):
    """Pixel-crisp aksara run as an 'L' mask cropped to its ink. `size` = font px on the native grid (glyph ink is
    roughly 0.6-0.8 of it). Complex shaping (raqm: pasangan, vowel signs) works; pass multi-char strings."""
    f = ImageFont.truetype(os.path.join(FONTS, _FONT_FILES[script]), size * SS)
    probe = Image.new("L", (size * SS * 4, size * SS * 3), 0)
    d = ImageDraw.Draw(probe)
    d.text((size * SS, size * SS // 2), chars, font=f, fill=255, layout_engine=ImageFont.Layout.RAQM)
    bb = probe.getbbox()
    if not bb:
        return Image.new("L", (1, 1), 0)
    bb = (bb[0] // SS * SS, bb[1] // SS * SS, (bb[2] + SS - 1) // SS * SS, (bb[3] + SS - 1) // SS * SS)
    big = probe.crop(bb)
    small = big.resize((big.width // SS, big.height // SS), Image.BOX)
    return small.point(lambda v: 255 if v >= thresh else 0)


def aksara(c, key, cx, cy, size, col=CYAN, glow=None, mod=None, outline=None, shadow=None):
    """Draw aksara run centred on (cx, cy). key = (chars, script) with script 'sunda'|'jawa'. Returns bbox."""
    chars, script = key
    m = aksara_mask(chars, script, size)
    if mod:
        m = mod(m)
    x0, y0 = int(cx - m.width // 2), int(cy - m.height // 2)
    if glow:
        d1, d3 = dilate(m, 1), dilate(m, 3)
        ring = mask_and(mask_sub(d3, d1), checker(d3.width, d3.height, 0))
        fill_mask(c, ring, x0 - 3, y0 - 3, glow[1])
        fill_mask(c, mask_sub(d1, m), x0 - 1, y0 - 1, glow[0])
    if outline:
        fill_mask(c, dilate(m, 1), x0 - 1, y0 - 1, outline)
    if shadow:
        fill_mask(c, m, x0 + shadow[1], y0 + shadow[2], shadow[0])
    fill_mask(c, m, x0, y0, col)
    return (x0, y0, x0 + m.width, y0 + m.height)


# ---------------------------------------------------------------- backgrounds


@lru_cache(maxsize=8)
def _night_base(top=(10, 8, 20), bot=(26, 18, 48)):
    """Near-black indigo, Bayer-dithered vertical gradient (3 bands)."""
    ys = np.arange(H)[:, None] / (H - 1)
    thr = (BAYER4[np.arange(H)[:, None] % 4, np.arange(W)[None, :] % 4] + 0.5) / 16.0
    steps = 4
    q = np.clip(np.floor((ys ** 1.4) * steps + thr), 0, steps) / steps
    a = np.zeros((H, W, 4), "uint8")
    for i in range(3):
        a[..., i] = (top[i] + (bot[i] - top[i]) * q).astype("uint8")
    a[..., 3] = 255
    return a


STAR_COLS = [rgb("3A2F5C"), rgb("6B5E9C"), rgb("A99BC8"), rgb("ECE6F2")]


class Stars:
    """Deterministic drifting, twinkling starfield. draw(c, t): 3 parallax layers moving left, stepped twinkle."""

    def __init__(self, seed=1, n=70, dim=1.0, speeds=(1.5, 3.0, 6.0), y_max=H):
        r = random.Random(seed)
        self.s = [(r.randrange(W), r.randrange(int(y_max)), r.choices([0, 1, 2], [6, 3, 1])[0], r.random() * 8)
                  for _ in range(n)]
        self.speeds, self.dim = speeds, dim

    def draw(self, c, t):
        px = c.load()
        for x0, y0, layer, ph in self.s:
            x = int(x0 - self.speeds[layer] * t) % W
            tw = int(t * 1.6 + ph) % 4
            lvl = min(3, max(0, [0, 1, 2][layer] + (1 if tw == 0 else 0) - (1 if tw == 2 else 0)))
            lvl = max(0, int(lvl * self.dim + 0.0001))
            px[x, y0] = STAR_COLS[lvl]
            if layer == 2 and tw in (0, 1) and self.dim >= 0.8:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    xx, yy = (x + dx) % W, y0 + dy
                    if 0 <= yy < H:
                        px[xx, yy] = STAR_COLS[1]


def night_bg(t=0.0, stars=None, tint=None):
    """Opaque near-black starry background (cards)."""
    a = _night_base().copy()
    if tint is not None:   # multiply the indigo by a colour, e.g. (1.5, 0.7, 0.8) for a blood-dark night
        a[..., :3] = np.clip(a[..., :3] * np.array(tint[:3]), 0, 255).astype("uint8")
    c = Image.fromarray(a, "RGBA").copy()
    if stars is not None:
        stars.draw(c, t)
    return c


@lru_cache(maxsize=1)
def _dusk_layers():
    sky = load("ui/title_sky.png", False)
    far = load("ui/title_far.png")
    near = load("ui/title_near.png")
    base = Image.new("RGBA", (W, H), EDGE)
    base.alpha_composite(sky)
    return base, far, near


def dusk_bg(t=0.0, stars=None):
    """The title screen's dusk valley (sky + far ruins + near ridge), opaque; add Stars/Embers on top for motion."""
    base, far, near = _dusk_layers()
    c = base.copy()
    if stars is not None:
        stars.draw(c, t)
    paste(c, far, 0, 0)
    paste(c, near, 0, 0)
    return c


# ---------------------------------------------------------------- particles


EMBER_RAMP = [rgb("FFF4D0"), rgb("FFC070"), rgb("F2884A"), rgb("D0503C"), rgb("8E2F45")]
CYAN_RAMP = [rgb("FFFFFF"), rgb("D8FFFB"), rgb("7FE8E0"), rgb("3FB8C0"), rgb("1F6E78")]


class Embers:
    """Rising ember / firefly motes: pure function of t (random access). Colour steps down a ramp with height,
    motes drop out by Bayer dither near the top (no alpha)."""

    def __init__(self, seed=5, n=40, ramp=EMBER_RAMP, speed=(10, 28), sway=5, area=(0, 0, W, H), up=True):
        r = random.Random(seed)
        self.p = [(r.random() * (area[2] - area[0]) + area[0], r.random() * (area[3] - area[1]),
                   r.uniform(*speed), r.random() * 6.28, r.uniform(0.5, 1.6), r.random() < 0.25) for _ in range(n)]
        self.ramp, self.sway, self.area, self.up = ramp, sway, area, up

    def draw(self, c, t):
        x0, y0, x1, y1 = self.area
        hgt = y1 - y0
        px = c.load()
        for bx, by, v, ph, f, big in self.p:
            k = ((by + (t * v if self.up else -t * v)) % hgt) / hgt     # 0 at spawn .. 1 at end of life
            y = y1 - 1 - int(k * hgt) if self.up else y0 + int(k * hgt)
            x = int(bx + math.sin(t * f + ph) * self.sway) % W
            lvl = min(len(self.ramp) - 1, int(k * len(self.ramp)))
            if k > 0.8 and BAYER4[y % 4, x % 4] / 16.0 < (k - 0.8) * 5:
                continue
            col = self.ramp[lvl]
            if 0 <= y < H:
                px[x, y] = col
                if big and k < 0.6 and 0 <= y + 1 < H:
                    px[x, y + 1] = col
                    px[(x + 1) % W, y] = self.ramp[min(len(self.ramp) - 1, lvl + 1)]


def sparkle(c, x, y, t, col=CYAN_HI, halo=CYAN, size=3, period=1.0, phase=0.0):
    """4-point pixel star that grows and shrinks over `period` seconds (dot, +, big +, +, off)."""
    k = ((t + phase) % period) / period
    frames = [0, 1, 2, size, 2, 1]
    r = frames[int(k * len(frames)) % len(frames)]
    if k > 0.85:
        return
    px = c.load()

    def put(xx, yy, cc):
        if 0 <= xx < W and 0 <= yy < H:
            px[xx, yy] = cc
    put(x, y, col)
    for i in range(1, r + 1):
        cc = col if i <= r - 1 or r <= 1 else halo
        for dx, dy in ((i, 0), (-i, 0), (0, i), (0, -i)):
            put(x + dx, y + dy, cc)


def burst(c, x, y, p, n=14, rmax=60, cols=(CYAN_HI, CYAN, CYAN_HALO, CYAN_DEEP), seed=2):
    """Radial pixel burst: n motes fly out with ease-out and step down the colour ramp. p 0..1."""
    if p <= 0 or p >= 1:
        return
    r = random.Random(seed)
    px = c.load()
    for i in range(n):
        a = r.random() * 6.283
        sp = r.uniform(0.5, 1.0) * rmax
        d = ease_out(p) * sp
        xx, yy = int(x + math.cos(a) * d), int(y + math.sin(a) * d * 0.8)
        col = cols[min(len(cols) - 1, int(p * len(cols)))]
        if 0 <= xx < W and 0 <= yy < H:
            px[xx, yy] = col
            if p < 0.5 and 0 <= xx + 1 < W:
                px[xx + 1, yy] = col


# ---------------------------------------------------------------- ink stroke


def sample_path(pts, step=1.0):
    """Densely sample a polyline [(x,y),...] -> list of points about `step` px apart."""
    out = []
    for (x0, y0), (x1, y1) in zip(pts[:-1], pts[1:]):
        n = max(1, int(math.hypot(x1 - x0, y1 - y0) / step))
        for i in range(n):
            out.append((x0 + (x1 - x0) * i / n, y0 + (y1 - y0) * i / n))
    out.append(pts[-1])
    return out


def smooth_path(pts, per=8):
    """Catmull-Rom through pts -> dense polyline (for hand-drawn looking strokes)."""
    P = [pts[0]] + list(pts) + [pts[-1]]
    out = []
    for i in range(1, len(P) - 2):
        p0, p1, p2, p3 = P[i - 1], P[i], P[i + 1], P[i + 2]
        for k in range(per):
            t = k / per
            t2, t3 = t * t, t * t * t
            out.append(tuple(0.5 * ((2 * p1[j]) + (-p0[j] + p2[j]) * t + (2 * p0[j] - 5 * p1[j] + 4 * p2[j] - p3[j]) * t2
                                    + (-p0[j] + 3 * p1[j] - 3 * p2[j] + p3[j]) * t3) for j in (0, 1)))
    out.append(pts[-1])
    return out


def ink_stroke(c, path, p, width=2, core=CYAN_HI, body=CYAN, halo=CYAN_HALO, head=True, halo_w=2):
    """Cyan 'ink' stroke drawn along `path` (dense polyline) up to progress p (0..1). Trailing dither halo, bright
    head sparkle: the in-game spell-ink look."""
    pts = sample_path(path, 1.0)
    n = int(len(pts) * clamp(p))
    if n < 1:
        return
    d = ImageDraw.Draw(c)
    seg = pts[:n]
    r = width // 2 + halo_w
    for i, (x, y) in enumerate(seg):
        for dy in range(-r, r + 1):
            for dx in range(-r, r + 1):
                dist = max(abs(dx), abs(dy))
                if dist > width // 2 and (x + dx + y + dy) % 2 == 0 and 0 <= int(x) + dx < W and 0 <= int(y) + dy < H:
                    if c.getpixel((int(x) + dx, int(y) + dy))[3] == 0 or True:
                        c.putpixel((int(x) + dx, int(y) + dy), halo)
    for (x, y) in seg:
        d.rectangle([int(x) - width // 2 + (0 if width % 2 else 0), int(y) - width // 2,
                     int(x) + (width - 1) // 2, int(y) + (width - 1) // 2], fill=body)
    tail = max(0, n - 10)
    for (x, y) in seg[tail:]:
        d.point((int(x), int(y)), fill=core)
    if head and p < 1:
        x, y = seg[-1]
        c.putpixel((int(x), int(y)), CYAN_HI)


# ---------------------------------------------------------------- slide / chip helpers


def slide(t, t_in, t_out, dur_in=0.35, dur_out=0.3, dist=40, steps=7):
    """Offset in whole px for a slide-in at t_in / slide-out at t_out (stepped ease). 0 when settled; dist when away.
    Returns (offset, visible)."""
    if t < t_in:
        return dist, False
    if t < t_in + dur_in:
        return ri(dist * (1 - step_ease(ease_out(prog(t, t_in, dur_in)), steps))), True
    if t < t_out:
        return 0, True
    if t < t_out + dur_out:
        return ri(dist * step_ease(ease_in(prog(t, t_out, dur_out)), steps)), True
    return dist, False


def chip(c, x, y, w, h, fill=FILL, hair=HAIR, accent=None):
    paste(c, panel(w, h, hair, fill), x, y)
    if accent:
        ImageDraw.Draw(c).rectangle([x + 2, y + 2, x + 3, y + h - 3], fill=accent)


# ---------------------------------------------------------------- output


def _ffmpeg(path, alpha):
    base = ["ffmpeg", "-y", "-loglevel", "error", "-f", "rawvideo", "-pix_fmt", "rgba" if alpha else "rgb24",
            "-s", f"{W}x{H}", "-r", str(FPS), "-i", "-", "-vf", "scale=1920:1080:flags=neighbor"]
    if alpha:
        return base + ["-c:v", "qtrle", "-pix_fmt", "argb", "-r", str(FPS), path]
    return base + ["-c:v", "libx264", "-crf", "10", "-preset", "medium", "-pix_fmt", "yuv420p", "-r", str(FPS),
                   "-movflags", "+faststart", path]


def render(name, fn, dur, alpha=False, outdir=OUT):
    """Render fn(t)->RGBA(480x270) for t in [0, dur) at 60 fps to <outdir>/<name>.mp4 (opaque) or .mov (alpha)."""
    os.makedirs(outdir, exist_ok=True)
    path = os.path.join(outdir, name + (".mov" if alpha else ".mp4"))
    proc = subprocess.Popen(_ffmpeg(path, alpha), stdin=subprocess.PIPE)
    n = int(round(dur * FPS))
    for i in range(n):
        im = fn(i / FPS)
        if alpha:
            im = hard(im)
            proc.stdin.write(im.tobytes())
        else:
            proc.stdin.write(im.convert("RGB").tobytes())
    proc.stdin.close()
    proc.wait()
    return path


def preview_frames(name, fn, dur, alpha=False, times=None, outdir=PREVIEW, scale=4):
    """Save 3 frames (start / middle / end) as video/out/preview/gfx_<name>_N.png. Alpha scenes are shown over a
    dusk backdrop. Returns the list of times used."""
    os.makedirs(outdir, exist_ok=True)
    times = times or [min(0.2, dur / 4), dur * 0.5, max(dur - 0.1, dur * 0.9)]
    for i, t in enumerate(times):
        im = fn(t)
        if alpha:
            bg = dusk_bg(t).convert("RGBA")
            bg.alpha_composite(hard(im))
            im = bg
        scaled(im.convert("RGB"), scale).save(os.path.join(outdir, f"gfx_{name}_{i + 1}.png"))
    return times
