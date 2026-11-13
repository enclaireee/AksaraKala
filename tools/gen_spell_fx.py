#!/usr/bin/env python3
"""Glyph spell FX sheets (spells.md 7), art pass v8 (assets.md 1 "FX standard"). Every sheet is a horizontal strip
of equal frames in assets/art/fx/spells/. Chunky lit pixel art drawn once in pixlib KEY tones (a = main ramp,
b = accent ramp, w = hot core, plum outline on key frames) and written by pixlib.bake_all as a neutral strip plus
one <name>_<class>.png per class (spells/spell_fx.gd picks it by Game.class_id). The tiger spirit and the ember
keep their own colours and have no class variants. Frames that move face +x (right); the game rotates or flips them.
Also writes zone_fill.png (16x16 tile for SpellZone rings) and zap / dash_streak (replace the old Line2D / Polygon2D).
Run: python3 tools/gen_spell_fx.py   Output: assets/art/fx/spells/*.png and tools/spell_fx_preview.png
"""
import math
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from PIL import Image, ImageDraw

from pixlib import *

D = "fx/spells/"
W = KEY["w"]
IMGS = {}   # name -> neutral strip, for the preview


def fr(n, w, h):
    return [Image.new("RGBA", (w, h), (0, 0, 0, 0)) for _ in range(n)]


def mk(w, h):
    return Image.new("L", (w, h), 0)


def shade_mask(img, m, tones=None):
    """Fill mask m with lit chunky tones: 1 px light rim top-left, 2 px shadow bottom-right, mid inside."""
    tones = tones or A
    p, W_, H_ = m.load(), m.width, m.height

    def on(x, y):
        return 0 <= x < W_ and 0 <= y < H_ and p[x, y] > 0

    for y in range(H_):
        for x in range(W_):
            if not p[x, y]:
                continue
            light = not on(x - 1, y) or not on(x, y - 1)
            shd = not on(x + 1, y) or not on(x, y + 1)
            if light and not shd:
                t = 0
            elif shd and not light:
                t = 3 if (not on(x + 2, y + 2) or not on(x + 1, y + 1)) else 2
            elif light and shd:
                t = 1
            else:
                t = 1 if on(x + 2, y + 2) else 2
            dot(img, x, y, tones[min(t, len(tones) - 1)])


def ell(w, h, cx, cy, rx, ry):
    m = mk(w, h)
    ImageDraw.Draw(m).ellipse([cx - rx, cy - ry, cx + rx - 1, cy + ry - 1], fill=255)
    return m


def poly(w, h, pts):
    m = mk(w, h)
    ImageDraw.Draw(m).polygon(pts, fill=255)
    return m


def tline(img, p0, p1, wd, c):
    """Thick line stamped as wd x wd squares (no AA)."""
    n = int(max(abs(p1[0] - p0[0]), abs(p1[1] - p0[1]))) + 1
    for i in range(n + 1):
        t = i / max(n, 1)
        x, y = p0[0] + (p1[0] - p0[0]) * t, p0[1] + (p1[1] - p0[1]) * t
        for dx in range(wd):
            for dy in range(wd):
                dot(img, x + dx - wd // 2, y + dy - wd // 2, c)


def tmask(m, p0, p1, wd):
    d = ImageDraw.Draw(m)
    n = int(max(abs(p1[0] - p0[0]), abs(p1[1] - p0[1]))) + 1
    for i in range(n + 1):
        t = i / max(n, 1)
        x, y = round(p0[0] + (p1[0] - p0[0]) * t - wd // 2), round(p0[1] + (p1[1] - p0[1]) * t - wd // 2)
        d.rectangle([x, y, x + wd - 1, y + wd - 1], fill=255)


def sq(img, x, y, s, c):
    for i in range(s):
        for j in range(s):
            dot(img, x + i, y + j, c)


def chunk_ring(im, c, r, n, size, tone, phase=0.0, alt=None):
    """Sparse ring of fat size x size chunks (a fade stage); every 3rd chunk uses `alt` if given."""
    for k in range(n):
        a = phase + k * math.tau / n
        sq(im, round(c + math.cos(a) * r) - size // 2, round(c + math.sin(a) * r) - size // 2, size,
           alt if (alt and k % 3 == 0) else tone)


def fin(name, frames, outline=(), bake=True):
    out = [plum_outline(f) if i in outline else f for i, f in enumerate(frames)]
    s = strip(out)
    IMGS[name] = s
    if bake:
        bake_all(s, D + name + ".png")
    else:
        save(s, D + name + ".png")


# ---- bolt (Sunda Ka): chunky spear of light, 4 frames 24x12 ---------------------------------------
def make_bolt():
    out = fr(4, 24, 12)
    for i, im in enumerate(out):
        for x in range(0, 6):
            for y in (5, 6):
                dot(im, x, y, A[2] if x < 3 else A[1])
        for x in range(6, 21):
            dot(im, x, 4, A[0]); dot(im, x, 5, W); dot(im, x, 6, W); dot(im, x, 7, A[1])
        for x in range(10 + i % 2, 19):
            dot(im, x, 3, A[1]); dot(im, x, 8, A[2])
        for y in (4, 5, 6, 7):
            dot(im, 21, y, W if y in (5, 6) else A[0])
        dot(im, 22, 5, W); dot(im, 22, 6, A[0])
        sq(im, 8 + 4 * i % 9, 1 if i % 2 else 9, 2, B[0 if i % 2 else 1])   # crackle chunks
        sq(im, 15 - 3 * i % 8, 9 if i % 2 else 1, 2, B[1])
    fin("bolt_fly", out, outline=range(4))


# ---- impact starburst, 5 frames 32x32 ---------------------------------------------------------------
def make_hit():
    out = fr(5, 32, 32)
    c = 16
    for i, im in enumerate(out):
        t = i / 4
        if i == 0:
            blob(im, c, c, 6, [W, A[0], A[1]])
            for k in range(4):
                a = k * math.pi / 2
                tline(im, (c + math.cos(a) * 4, c + math.sin(a) * 4), (c + math.cos(a) * 10, c + math.sin(a) * 10), 3, A[0])
        elif i <= 2:
            r = 4 + i * 4
            band(im, c, c, r + 2, 6 - i, tones=A)
            band(im, c, c, r - 2, 2, tones=B[:3])
            blob(im, c, c, 4 - i, [W, A[0]])
            for k in range(8):
                a = k * math.pi / 4 + 0.2
                tline(im, (c + math.cos(a) * (r + 3), c + math.sin(a) * (r + 3)),
                      (c + math.cos(a) * (r + 7 - i), c + math.sin(a) * (r + 7 - i)), 2, A[0] if k % 2 else B[0])
        else:
            r = 8 + (i - 2) * 3
            chunk_ring(im, c, r, 8, 4 if i == 3 else 3, A[i - 2], i * 0.3, B[i - 2])
            for k in range(4):
                a = math.radians(45 + k * 90 + i * 10)
                sq(im, round(c + math.cos(a) * (r + 5)) - 1, round(c + math.sin(a) * (r + 5)) - 1, 2, B[i - 2])
    fin("hit_burst", out, outline=(0, 1, 2, 3))


# ---- ward bubble (6 frames 44x44, loops) and shatter (5 frames 64x64) ---------------------------------
def make_ward():
    out = fr(6, 44, 44)
    for i, im in enumerate(out):
        c = 22
        for y in range(44):                      # sparse tiled fill, a 2 px checker in the shadow tone
            for x in range(44):
                if math.hypot(x + .5 - c, y + .5 - c) < 16 and x % 6 in (1, 2) and y % 6 in (1, 2) and (x // 6 + y // 6) % 2 == 0:
                    dot(im, x, y, A[1])
        band(im, c, c, 18, 4, tones=A)
        band(im, c, c, 14.5, 2, 190 + 0, 290, tones=[A[0], A[1]])   # top-left sheen
        for k in range(6):                         # rotating rune chunks
            a = math.radians(k * 60 + i * 10)
            x, y = c + math.cos(a) * 18, c + math.sin(a) * 18
            sq(im, round(x) - 2, round(y) - 2, 4, B[1])
            sq(im, round(x) - 2, round(y) - 2, 2, B[0])
        a = math.radians(i * 60 - 40)
        blob(im, c + math.cos(a) * 18, c + math.sin(a) * 18, 2.5, [W, A[0]])
    fin("ward_bubble", out, outline=range(6))

    out = fr(5, 64, 64)
    rnd = random.Random(7)
    shards = [(rnd.uniform(0, math.tau), rnd.uniform(0.8, 1.25)) for _ in range(12)]
    for i, im in enumerate(out):
        c = 32
        if i == 0:
            band(im, c, c, 17, 5, tones=A)
            band(im, c, c, 12, 2, tones=B[:3])
        elif i == 1:
            for k in range(6):
                a = k * 60 + 10
                band(im, c, c, 22, 5, a, a + 44, tones=A)
        for n, (ang, sp) in enumerate(shards):
            if i == 0:
                break
            r = 14 + i * 4.5 * sp
            x, y = c + math.cos(ang) * r, c + math.sin(ang) * r
            s = 5 if i < 3 else 4
            sq(im, round(x) - s // 2, round(y) - s // 2, s, A[min(i - 1, 3)] if n % 3 else B[min(i - 1, 3)])
            if i < 3:
                sq(im, round(x) - s // 2, round(y) - s // 2, 2, A[0])
    fin("ward_break", out, outline=(0, 1, 2))


# ---- shock wave (Burst, ward pulse), 6 frames 128x128 --------------------------------------------------
def make_shock():
    out = fr(6, 128, 128)
    c = 64
    for i, im in enumerate(out):
        t = i / 5
        r = 14 + t * 46
        if i == 0:
            blob(im, c, c, 14, [W, A[0], A[1]])
        if i < 3:
            th = 11 - i * 2
            band(im, c, c, r, th, tones=A)
            band(im, c, c, r - th / 2 - 2, 3, tones=B[:3])
            for k in range(12):
                a = math.radians(k * 30 + i * 8)
                sq(im, round(c + math.cos(a) * (r + th / 2 + 3)) - 2, round(c + math.sin(a) * (r + th / 2 + 3)) - 2, 4, B[0] if k % 2 else A[0])
        else:
            if i == 3:
                for k in range(8):
                    band(im, c, c, r, 7, k * 45 + 27, k * 45 + 57, tones=A[1:])
            else:
                chunk_ring(im, c, r, 16, 4 if i == 4 else 3, A[i - 2], i * 0.2, B[i - 2])
            rnd = random.Random(i)
            for k in range(10):
                a = rnd.uniform(0, math.tau)
                rr = r + rnd.uniform(-6, 8)
                sq(im, round(c + math.cos(a) * rr), round(c + math.sin(a) * rr), 4 if i < 5 else 3, B[min(i - 2, 3)])
    fin("shock", out, outline=(1, 2, 3))


# ---- bind: roots (6 frames 32x32) and ground ring (5 frames 128x128) -----------------------------------
def make_bind():
    out = fr(6, 32, 32)
    rnd = random.Random(3)
    roots = [(rnd.uniform(-1.1, 1.1) - math.pi / 2, rnd.uniform(0.7, 1.1), rnd.choice([-1, 1])) for _ in range(6)]
    for i, im in enumerate(out):
        grow = min(1.0, (i + 1) / 4)
        cx, cy = 16, 27
        for ang, ln, sg in roots:
            m = mk(32, 32)
            x, y = cx, cy
            n = int(18 * ln * grow)
            pts = []
            for s in range(n):
                a2 = ang + math.sin(s * 0.45 + ang * 3) * 0.4 * sg
                x += math.cos(a2)
                y += math.sin(a2) * 0.95
                pts.append((x, y))
            for q in range(1, len(pts)):
                tmask(m, pts[q - 1], pts[q], 3 if q < n * 0.6 else 2)
            shade_mask(im, m, A)
            if pts and n > 4:
                sq(im, round(pts[-1][0]) - 1, round(pts[-1][1]) - 2, 2, B[0])
        blob(im, cx, cy, 5, [A[0], A[1], A[2], A[3]], wobble=0.2, seed=2)
        m = mk(32, 32)
        ImageDraw.Draw(m).rectangle([cx - 8, cy + 1, cx + 8, cy + 3], fill=255)
        shade_mask(im, m, B)
    fin("bind_roots", out, outline=range(6))

    out = fr(5, 128, 128)
    c = 64
    for i, im in enumerate(out):
        t = i / 4
        r = 14 + t * 48
        if i < 3:
            band(im, c, c, r, 8 - i * 2, tones=A)
            for k in range(18):          # thorns pointing inward
                a = math.radians(k * 20 + i * 5)
                for s in range(4):
                    x, y = c + math.cos(a) * (r - 4 - s * 1.5), c + math.sin(a) * (r - 4 - s * 1.5)
                    sq(im, round(x) - (3 - s) // 2 - (1 if s == 0 else 0), round(y) - 1, 3 - s // 2 if s < 3 else 1, B[s if s < 3 else 2])
        else:
            chunk_ring(im, c, r, 18, 4 if i == 3 else 3, A[i - 2], i * 0.25, B[i - 2])
    fin("bind_ring", out, outline=(0, 1, 2))


# ---- heal: rising leaves and sparkles, 8 frames 32x48 (loops) -----------------------------------------
def make_heal():
    out = fr(8, 32, 48)
    rnd = random.Random(12)
    motes = [(rnd.uniform(7, 25), rnd.uniform(0, 1), rnd.uniform(0.8, 1.2), k % 3) for k in range(8)]
    for i, im in enumerate(out):
        t = i / 8
        m = mk(32, 3)
        for x0, ph, sp, kind in motes:
            yy = int(40 - ((t * sp + ph) % 1.0) * 36)
            xx = int(x0 + math.sin((t + ph) * math.tau) * 3)
            edge = abs(yy - 22) > 14
            tn = [A[1], A[2], A[3]] if edge else A
            if kind == 0:   # leaf: 2x4 lit slab with a shaded tip
                lm = mk(32, 48)
                ImageDraw.Draw(lm).polygon([(xx, yy + 3), (xx + 1, yy - 1), (xx + 4, yy - 3), (xx + 3, yy + 1)], fill=255)
                shade_mask(im, lm, tn)
            elif kind == 1:
                sq(im, xx, yy, 3, B[1] if not edge else B[2])
                sq(im, xx, yy, 2, B[0] if not edge else B[1])
                if not edge:
                    spark(im, xx + 1, yy + 1, 2, B[0])
            else:
                sq(im, xx, yy, 2, tn[0])
                sq(im, xx + 1, yy + 1, 1, tn[2])
        gm = ell(32, 48, 16, 44, 11, 3)
        shade_mask(im, gm, B)
        for x in range(8, 24, 4):
            dot(im, x + (i % 2) * 2, 43, B[0])
    fin("heal_rise", out, outline=range(8))


# ---- dash slash: crescent smear 4 frames 64x24 facing right --------------------------------------------
def make_slash():
    out = fr(4, 64, 24)
    for i, im in enumerate(out):
        tones = A[i // 2:] if i > 1 else A
        for k, (y, x0, ln) in enumerate(((7, 4, 22), (12, 0, 28), (17, 6, 20))):   # speed bars
            L = ln - i * 4
            tline(im, (x0, y), (x0 + L, y), 2, B[min(i + (1 if k != 1 else 0), 3)])
        if i < 2:
            crescent(im, 42, 12, 11 - i, 9 - i, -62, 62, tones)
            band(im, 42, 12, 15 - i, 3, -48, 48, tones=[W, A[0]])
        else:
            for a0, a1 in ((-62, -12), (12, 62)):
                crescent(im, 42 + i, 12, 12, 8 - i, a0, a1, tones)
    fin("dash_slash", out, outline=(0, 1))


# ---- rally aura: flame ring at the feet, 6 frames 40x24 (loops) -----------------------------------------
def make_aura():
    out = fr(6, 40, 24)
    for i, im in enumerate(out):
        cx, cy = 20, 15
        m = mk(40, 24)
        for k in range(16):
            ang = k * math.tau / 16
            x, y = cx + math.cos(ang) * 15, cy + math.sin(ang) * 6.5
            h = 4 + 3 * abs(math.sin(ang * 3 + i * 1.05))
            fm = poly(40, 24, [(x - 2, y), (x + 3, y), (x + 2, y - h * 0.6), (x + 0.5, y - h)])
            m.paste(fm, (0, 0), fm)
        shade_mask(im, m, [B[0], A[0], A[1], A[2]])
        rm = ell(40, 24, cx, cy + 1, 17, 8)
        ImageDraw.Draw(rm).ellipse([cx - 13, cy - 5, cx + 12, cy + 6], fill=0)
        shade_mask(im, rm, A)
    fin("rally_aura", out, outline=range(6))


# ---- tiger spirit: run (4 frames) and pounce (3 frames), 48x32, facing right; own colours ----------------
TG = [(255, 240, 178, 255), (255, 196, 92, 255), (214, 118, 40, 255), (140, 64, 26, 255)]
STRIPE = (88, 38, 22, 255)
EYE = (120, 255, 230, 255)


def tiger_frame(phase, pounce=0.0):
    im = Image.new("RGBA", (48, 32), (0, 0, 0, 0))
    lift = -int(round(pounce * 3))
    m = mk(48, 32)
    tw = round(math.sin(phase * 2) * 2)
    tmask(m, (9, 15 + lift), (5, 11 + tw + lift), 3)
    tmask(m, (5, 11 + tw + lift), (3, 6 + tw + lift), 3)
    shade_mask(im, m, TG)
    for k, lx in enumerate((12, 17, 28, 33)):          # legs, back pair darker
        sw = round(math.sin(phase + k * 1.6) * (3.5 if pounce == 0 else 5))
        lm = mk(48, 32)
        tmask(lm, (lx, 18 + lift), (lx + sw, 28 + (1 if pounce else 0)), 4)
        shade_mask(im, lm, TG[1:] + [TG[3]] if k % 2 == 0 else TG)
        sq(im, lx + sw - 2, 28 + (1 if pounce else 0), 5, TG[0])
    body = ell(48, 32, 22, 16 + lift // 2, 17, 8)
    shade_mask(im, body, TG)
    for sx in (13, 19, 25, 30):
        tline(im, (sx, 10 + lift // 2), (sx + 1, 16 + lift // 2), 2, STRIPE)
    hx, hy = 40, 12 + lift
    shade_mask(im, ell(48, 32, hx, hy, 7, 6), TG)
    sq(im, hx - 5, hy - 8, 3, TG[2]); sq(im, hx, hy - 8, 3, TG[2])            # ears
    shade_mask(im, poly(48, 32, [(hx + 2, hy), (hx + 9, hy + 1), (hx + 9, hy + 5), (hx + 1, hy + 5)]), [TG[0], TG[0], TG[1], TG[2]])
    sq(im, hx + 8, hy + 1, 2, STRIPE)
    sq(im, hx + 1, hy - 3, 2, EYE)
    tline(im, (hx - 3, hy - 5), (hx - 3, hy - 1), 2, STRIPE)
    if pounce > 0.5:
        sq(im, hx + 4, hy + 5, 2, W)
        for k in range(3):
            tline(im, (hx + 9, hy - 2 + k * 3), (hx + 14, hy + 1 + k * 3), 2, W)
    return plum_outline(im)


def make_tiger():
    fin("tiger_run", [tiger_frame(i * math.pi / 2) for i in range(4)], bake=False)
    fin("tiger_pounce", [tiger_frame(0.4, 0.0), tiger_frame(0.8, 0.6), tiger_frame(1.2, 1.0)], bake=False)


# ---- spirit hawk: 4 frames 36x28, facing right ----------------------------------------------------------
def make_hawk():
    out = fr(4, 36, 28)
    for i, im in enumerate(out):
        up = [1.0, 0.3, -0.6, 0.3][i]
        cx, cy = 18, 15
        tipx, tipy = cx - 8, cy - 2 - up * 11
        wing = poly(36, 28, [(cx - 5, cy - 2), (cx + 4, cy - 2), (tipx + 3, tipy), (tipx, tipy + 1)])
        shade_mask(im, wing, [A[1], A[2], A[2], A[3]])
        tail = poly(36, 28, [(cx - 8, cy), (cx - 15, cy + 1), (cx - 15, cy + 5), (cx - 8, cy + 3)])
        shade_mask(im, tail, [A[1], A[2], A[3], A[3]])
        shade_mask(im, ell(36, 28, cx, cy + 1, 10, 5), A)
        shade_mask(im, ell(36, 28, cx + 10, cy - 1, 4, 4), A)
        sq(im, cx + 13, cy - 1, 3, B[1]); sq(im, cx + 13, cy - 1, 2, B[0])   # beak
        sq(im, cx + 10, cy - 3, 2, W)                                          # eye
    fin("hawk_fly", out, outline=range(4))


# ---- ombak: wave crest 5 frames 48x32 facing right ---------------------------------------------------------
def make_ombak():
    out = fr(5, 48, 32)
    for i, im in enumerate(out):
        c = 26
        m = ell(48, 32, c, 16, 15, 15)
        ImageDraw.Draw(m).ellipse([c - 7 - 13, 16 - 13, c - 7 + 12, 16 + 12], fill=0)
        shade_mask(im, m, A)
        for sg in (-1, 1):                      # foam on both tips and the leading edge
            sq(im, c + 4, 16 + sg * 12 - 1, 3, B[0])
            sq(im, c + 11, 16 + sg * 7 - 1, 3, B[0])
        sq(im, c + 15 - 3, 15, 3, B[0])
        for k in range(3):                      # trailing ripples, 2 px bars that scroll
            xr = 4 + k * 5
            for dy in range(-8 + k * 2, 9 - k * 2, 4):
                tline(im, (xr + (i + k) % 3, 16 + dy), (xr + (i + k) % 3, 16 + dy + 1), 2, A[1 + (k > 0)])
        rnd = random.Random(i)
        for _ in range(4):
            sq(im, 30 + rnd.randint(0, 14), 6 + rnd.randint(0, 20), 2, B[0])
    fin("ombak_wave", out, outline=range(5))


# ---- cast sigil: rune circle, 6 frames 64x64 -------------------------------------------------------------------
def make_sigil():
    out = fr(6, 64, 64)
    c = 32
    for i, im in enumerate(out):
        t = i / 5
        r = 12 + 17 * t
        if i < 4:
            th = 5 - i // 2
            band(im, c, c, r, th, tones=A)
            band(im, c, c, r - th / 2 - 2.5, 2, tones=B[:3])
            for k in range(8):
                a = math.radians(k * 45 + t * 70)
                x, y = c + math.cos(a) * (r + th / 2 + 3), c + math.sin(a) * (r + th / 2 + 3)
                sq(im, round(x) - 1, round(y) - 1, 3, B[0] if k % 2 else A[0])
            for k in range(4):
                a = math.radians(k * 90 + t * 140 + 20)
                blob(im, c + math.cos(a) * r, c + math.sin(a) * r, 2.5, [W, A[0], A[1]])
        else:
            chunk_ring(im, c, r, 12, 4 if i == 4 else 3, A[i - 3], i * 0.3, B[i - 3])
            for k in range(4):
                a = math.radians(k * 90 + 20 + i * 18)
                sq(im, round(c + math.cos(a) * (r + 5)) - 1, round(c + math.sin(a) * (r + 5)) - 1, 2, B[i - 2])
    fin("cast_sigil", out, outline=(0, 1, 2, 3))


# ---- ember: tiny fire chunk, 4 frames 8x8, fire colours, no class variants ---------------------------------------
FIRE = [(255, 244, 200, 255), (255, 190, 70, 255), (226, 100, 30, 255), (130, 40, 24, 255)]


def make_ember():
    out = fr(4, 8, 8)
    for i, im in enumerate(out):
        s = [4, 4, 3, 2][i]
        o = (8 - s) // 2
        sq(im, o, o, s, FIRE[min(i + 1, 3)] if i else FIRE[1])
        sq(im, o, o, max(s - 1, 1), FIRE[i] if i < 3 else FIRE[2])
        if i == 0:
            sq(im, o + 1, o + 1, 2, FIRE[0])
    fin("ember", out, outline=(0, 1), bake=False)


# ---- zap: jagged lightning, 4 frames 64x16, drawn left to right; the game stretches and rotates it ----------------
def make_zap():
    out = fr(4, 64, 16)
    for i, im in enumerate(out):
        rnd = random.Random(30 + i)
        pts = [(2, 8)]
        y = 8
        for x in (14, 26, 38, 50):
            y = max(5, min(11, y + rnd.choice([-4, -3, 3, 4])))
            pts.append((x, y))
        pts.append((61, 8))
        m = mk(64, 16)
        for q in range(1, len(pts)):
            tmask(m, pts[q - 1], pts[q], 6)
        tn = A if i < 3 else A[2:] + [A[3]]
        shade_mask(im, m, tn)
        core = mk(64, 16)
        for q in range(1, len(pts)):
            tmask(core, pts[q - 1], pts[q], 3)
        shade_mask(im, core, [W, W, A[0], A[1]] if i < 3 else [A[1], A[1], A[2], A[2]])
        for px_, py_ in pts[1:-1]:
            sq(im, px_ - 1, py_ + (-5 if i % 2 else 3), 2, B[0 if i < 3 else 2])
    fin("zap", out, outline=(0, 1, 2))


# ---- dash streak: speed flare over the dasher, 4 frames 20x8 (plays once, 0.16 s) -----------------------------------
def make_streak():
    out = fr(4, 20, 8)
    for i, im in enumerate(out):
        x0 = 2 + i * 2
        tn = A[min(i, 2):]
        for x in range(x0 + 3, 17):
            dot(im, x, 1, tn[0]); dot(im, x, 2, tn[0])
        for x in range(x0, 19):
            dot(im, x, 3, W if i < 2 else tn[0]); dot(im, x, 4, W if i < 2 else tn[1])
        for x in range(x0 + 5, 15):
            dot(im, x, 5, tn[1]); dot(im, x, 6, tn[2] if len(tn) > 2 else tn[-1])
        for x in range(x0 + 2, x0 + 5):
            dot(im, x, 3, B[0]); dot(im, x, 4, B[1])
    fin("dash_streak", out, outline=(0, 1))


# ---- zone fill tile, 16x16: sparse chunk motif drawn under SpellZone rings (tinted at runtime) ----------------------
def make_zone_fill():
    t = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    for x, y in ((2, 2), (10, 6), (5, 11), (13, 13)):
        sq(t, x, y, 2, (255, 255, 255, 255))
        dot(t, x + 2, y, (255, 255, 255, 255))
        dot(t, x, y + 2, (255, 255, 255, 255))
    save(t, D + "zone_fill.png")


def preview():
    rows = [(n, IMGS[n]) for n in IMGS]
    for cls in ("warrior", "mage"):
        for n in ("hit_burst", "ward_bubble", "cast_sigil", "dash_slash", "zap", "heal_rise"):
            rows.append((cls, bake(IMGS[n], cls)))
    pv = os.path.join(ROOT, "tools", "spell_fx_preview.png")
    preview_sheet(rows, pv)


def preview_sheet(rows, path, scale=2):
    imgs = [i for _, i in rows]
    Wd = max(i.width for i in imgs) * scale + 8
    H = sum(i.height * scale + 6 for i in imgs) + 6
    out = Image.new("RGBA", (Wd, H), (46, 52, 74, 255))
    y = 6
    for im in imgs:
        big = im.resize((im.width * scale, im.height * scale), Image.NEAREST)
        out.alpha_composite(big, (4, y))
        y += big.height + 6
    out.save(path)


if __name__ == "__main__":
    make_bolt(); make_hit(); make_ward(); make_shock(); make_bind(); make_heal(); make_slash()
    make_aura(); make_tiger(); make_hawk(); make_ombak(); make_sigil(); make_ember()
    make_zap(); make_streak(); make_zone_fill()
    preview()
    print("ok", len(IMGS), "strips")
