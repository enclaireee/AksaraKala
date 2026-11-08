#!/usr/bin/env python3
"""Glyph spell FX sheets (spells.md 7). Every sheet is a horizontal strip of equal frames in assets/art/fx/spells/.
Most art is white or pale grey with a little colour so spells/spell_fx.gd can tint it per glyph and per class;
the tiger spirit keeps its own colours. Frames that move face +x (right); the game rotates or flips them.
Run: python3 tools/gen_spell_fx.py   Output: assets/art/fx/spells/*.png and tools/spell_fx_preview.png
"""
import math
import os
import random

from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "art", "fx", "spells")
os.makedirs(OUT, exist_ok=True)

WHITE = (255, 255, 255, 255)
PALE = (214, 226, 240, 255)
MID = (150, 170, 200, 255)
DARK = (70, 84, 120, 255)


def a(c, al):
    return (c[0], c[1], c[2], int(al))


def strip(n, w, h):
    return Image.new("RGBA", (n * w, h), (0, 0, 0, 0))


def frame(n, w, h):
    return [Image.new("RGBA", (w, h), (0, 0, 0, 0)) for _ in range(n)]


def join(frames):
    w, h = frames[0].size
    s = strip(len(frames), w, h)
    for i, f in enumerate(frames):
        s.paste(f, (i * w, 0))
    return s


def px(im, x, y, c):
    x, y = int(round(x)), int(round(y))
    if 0 <= x < im.width and 0 <= y < im.height:
        im.putpixel((x, y), c)


def line(im, p0, p1, c):
    n = int(max(abs(p1[0] - p0[0]), abs(p1[1] - p0[1]))) + 1
    for i in range(n + 1):
        t = i / max(n, 1)
        px(im, p0[0] + (p1[0] - p0[0]) * t, p0[1] + (p1[1] - p0[1]) * t, c)


def ring(im, cx, cy, r, c, a0=0, a1=360, step=1.0):
    n = int(2 * math.pi * r) + 8
    for i in range(n):
        ang = math.radians(a0 + (a1 - a0) * i / n)
        px(im, cx + math.cos(ang) * r, cy + math.sin(ang) * r, c)


def disc(im, cx, cy, r, c):
    for y in range(int(cy - r) - 1, int(cy + r) + 2):
        for x in range(int(cx - r) - 1, int(cx + r) + 2):
            if (x - cx) ** 2 + (y - cy) ** 2 <= r * r:
                px(im, x, y, c)


def over(im, x, y, c):
    if not (0 <= x < im.width and 0 <= y < im.height):
        return
    d = im.getpixel((x, y))
    sa, da = c[3] / 255.0, d[3] / 255.0
    oa = sa + da * (1 - sa)
    if oa <= 0:
        return
    im.putpixel((x, y), tuple(int((c[k] * sa + d[k] * da * (1 - sa)) / oa) for k in range(3)) + (int(oa * 255),))


def save(name, frames):
    join(frames).save(os.path.join(OUT, name + ".png"))


# ---- bolt (Sunda Ka): crackling spear of light, 4 frames 24x12 ---------------------------------
def make_bolt():
    fr = frame(4, 24, 12)
    for i, im in enumerate(fr):
        rnd = random.Random(10 + i)
        # tail glow
        for x in range(0, 14):
            al = 40 + x * 9
            for y in (4, 5, 6, 7):
                over(im, x, y, a(MID, al * (0.5 if y in (4, 7) else 1.0)))
        # core
        for x in range(8, 21):
            over(im, x, 5, WHITE)
            over(im, x, 6, WHITE)
        for x in range(12, 22):
            over(im, x, 4, a(PALE, 230))
            over(im, x, 7, a(PALE, 230))
        # head
        px(im, 22, 5, WHITE); px(im, 22, 6, WHITE); px(im, 23, 5, a(WHITE, 200)); px(im, 23, 6, a(WHITE, 200))
        px(im, 21, 3, a(PALE, 200)); px(im, 21, 8, a(PALE, 200))
        # crackle: zig-zag arcs that change per frame
        y = 5.5
        for x in range(2, 20, 2):
            y += rnd.choice([-1.5, -1, 1, 1.5])
            y = max(1, min(10, y))
            px(im, x, y, a(WHITE, 255))
            px(im, x + 1, y + rnd.choice([-1, 1]), a(PALE, 190))
    save("bolt_fly", fr)


# ---- impact starburst, 5 frames 32x32 ------------------------------------------------------------
def make_hit():
    fr = frame(5, 32, 32)
    for i, im in enumerate(fr):
        t = i / 4.0
        cx = cy = 16
        r = 3 + t * 11
        al = 255 * (1 - t * 0.85)
        ring(im, cx, cy, r, a(WHITE, al))
        if i < 4:
            ring(im, cx, cy, r - 1.2, a(PALE, al * 0.6))
        rnd = random.Random(40)
        for k in range(8):
            ang = k * math.pi / 4 + 0.2
            r0, r1 = r * 0.5, r + 3 * (1 - t) + 2
            line(im, (cx + math.cos(ang) * r0, cy + math.sin(ang) * r0),
                 (cx + math.cos(ang) * r1, cy + math.sin(ang) * r1), a(WHITE, al))
        if i < 2:
            disc(im, cx, cy, 4 - i * 1.5, WHITE)
    save("hit_burst", fr)


# ---- ward bubble, 6 frames 44x44, loops; and shatter, 5 frames 64x64 ----------------------------
def make_ward():
    fr = frame(6, 44, 44)
    for i, im in enumerate(fr):
        cx = cy = 22
        # soft fill
        for y in range(44):
            for x in range(44):
                d = math.hypot(x - cx, y - cy)
                if d < 19:
                    over(im, x, y, a(PALE, 14 + 18 * (d / 19) ** 2))
        ring(im, cx, cy, 19, a(WHITE, 230))
        ring(im, cx, cy, 18, a(PALE, 110))
        # rotating rune ticks
        for k in range(6):
            ang = math.radians(k * 60 + i * 10)
            x0, y0 = cx + math.cos(ang) * 16, cy + math.sin(ang) * 16
            x1, y1 = cx + math.cos(ang) * 21, cy + math.sin(ang) * 21
            line(im, (x0, y0), (x1, y1), WHITE)
            px(im, cx + math.cos(ang + 0.2) * 19, cy + math.sin(ang + 0.2) * 19, a(MID, 255))
        # travelling glint
        ang = math.radians(i * 60 - 40)
        disc(im, cx + math.cos(ang) * 19, cy + math.sin(ang) * 19, 1.6, WHITE)
        # top highlight arc
        ring(im, cx, cy, 15, a(WHITE, 120), 215, 300)
    save("ward_bubble", fr)

    fr = frame(5, 64, 64)
    rnd = random.Random(7)
    shards = [(rnd.uniform(0, math.tau), rnd.uniform(0.7, 1.3)) for _ in range(14)]
    for i, im in enumerate(fr):
        t = i / 4.0
        cx = cy = 32
        if i < 3:
            ring(im, cx, cy, 14 + 14 * t, a(WHITE, 255 * (1 - t)))
        for ang, sp in shards:
            r = 12 + t * 20 * sp
            x, y = cx + math.cos(ang) * r, cy + math.sin(ang) * r
            L = 4 * (1 - t * 0.6)
            line(im, (x, y), (x + math.cos(ang + 1.2) * L, y + math.sin(ang + 1.2) * L), a(WHITE, 255 * (1 - t * 0.9)))
    save("ward_break", fr)


# ---- shock wave (Burst, ward pulse), 6 frames 128x128 --------------------------------------------
def make_shock():
    fr = frame(6, 128, 128)
    for i, im in enumerate(fr):
        t = i / 5.0
        cx = cy = 64
        r = 8 + t * 54
        al = 255 * (1 - t ** 2 * 0.9)
        if i < 2:   # opening flash
            for y in range(128):
                for x in range(128):
                    d = math.hypot(x - cx, y - cy)
                    if d < r:
                        over(im, x, y, a(WHITE, 120 * (1 - d / r) * (1 - i * 0.4)))
        for w in range(3):
            ring(im, cx, cy, r - w, a(WHITE if w == 0 else PALE, al * (1 - w * 0.3)))
        ring(im, cx, cy, r * 0.72, a(PALE, al * 0.4))
        rnd = random.Random(5)
        for k in range(18):
            ang = rnd.uniform(0, math.tau)
            rr = r + rnd.uniform(-3, 5) * (0.3 + t)
            x, y = cx + math.cos(ang) * rr, cy + math.sin(ang) * rr
            px(im, x, y, a(WHITE, al))
            px(im, x + math.cos(ang), y + math.sin(ang), a(PALE, al * 0.7))
        # rune notches around the ring
        for k in range(12):
            ang = k * math.tau / 12 + t * 0.6
            x0, y0 = cx + math.cos(ang) * (r - 3), cy + math.sin(ang) * (r - 3)
            x1, y1 = cx + math.cos(ang) * (r + 3), cy + math.sin(ang) * (r + 3)
            line(im, (x0, y0), (x1, y1), a(WHITE, al * 0.85))
    save("shock", fr)


# ---- bind: roots erupting at a foe (6 frames 32x32) and a ground ring (5 frames 128x128) -----------
def make_bind():
    fr = frame(6, 32, 32)
    rnd = random.Random(3)
    roots = [(rnd.uniform(-1.2, 1.2) - math.pi / 2, rnd.uniform(0.7, 1.1)) for _ in range(7)]
    for i, im in enumerate(fr):
        grow = min(1.0, (i + 1) / 4.0)
        cx, cy = 16, 26
        for ang, ln in roots:
            L = 17 * ln * grow
            x, y = cx, cy
            n = int(L)
            for s in range(n):
                ang2 = ang + math.sin(s * 0.5 + ang * 3) * 0.35
                x += math.cos(ang2)
                y += math.sin(ang2) * 0.9
                px(im, x, y, WHITE)
                px(im, x + 1, y, a(MID, 220))
            if n > 2:
                px(im, x, y - 1, WHITE)
        # base clump
        for dx in range(-5, 6):
            px(im, cx + dx, cy + 1, a(MID, 230))
            px(im, cx + dx // 2, cy, WHITE)
    save("bind_roots", fr)

    fr = frame(5, 128, 128)
    for i, im in enumerate(fr):
        t = i / 4.0
        cx = cy = 64
        r = 10 + t * 52
        al = 255 * (1 - t ** 2 * 0.8)
        for k in range(36):
            ang = k * math.tau / 36
            for w in range(2):
                rr = r - w
                px(im, cx + math.cos(ang) * rr, cy + math.sin(ang) * rr, a(WHITE, al * (0.9 - 0.3 * w)))
            # thorn spikes pointing in
            if k % 2 == 0:
                L = 5 * (1 - t * 0.4)
                line(im, (cx + math.cos(ang) * r, cy + math.sin(ang) * r),
                     (cx + math.cos(ang + 0.12) * (r - L), cy + math.sin(ang + 0.12) * (r - L)), a(WHITE, al))
    save("bind_ring", fr)


# ---- heal: rising leaves and sparkles, 8 frames 32x48, loops ---------------------------------------
def make_heal():
    fr = frame(8, 32, 48)
    rnd = random.Random(12)
    motes = [(rnd.uniform(6, 26), rnd.uniform(0, 1), rnd.uniform(0.7, 1.2), rnd.randint(0, 3)) for _ in range(9)]
    for i, im in enumerate(fr):
        t = i / 8.0
        for x0, ph, sp, kind in motes:
            yy = 44 - ((t * sp + ph) % 1.0) * 42
            xx = x0 + math.sin((t + ph) * math.tau) * 3
            fade = 1 - abs(((yy - 22) / 22))
            al = 255 * max(0.25, fade)
            if kind == 0:   # leaf
                for dx, dy in ((0, 0), (1, 0), (1, -1), (2, -1), (-1, 1), (0, 1)):
                    px(im, xx + dx, yy + dy, a(WHITE, al))
                px(im, xx, yy - 1, a(PALE, al))
            elif kind == 1:   # cross sparkle
                for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
                    px(im, xx + dx, yy + dy, a(WHITE, al if (dx, dy) == (0, 0) else al * 0.6))
            else:
                px(im, xx, yy, a(WHITE, al)); px(im, xx + 1, yy, a(PALE, al * 0.6))
        # soft ground glow
        for dx in range(-9, 10):
            over(im, 16 + dx, 45, a(WHITE, 90 - abs(dx) * 8))
            over(im, 16 + dx, 44, a(PALE, 50 - abs(dx) * 5))
    save("heal_rise", fr)


# ---- dash slash: speed streak 4 frames 64x24 facing right ------------------------------------------
def make_slash():
    fr = frame(4, 64, 24)
    for i, im in enumerate(fr):
        t = i / 3.0
        fade = 1 - t * 0.8
        for k in range(5):
            y = 12 + (k - 2) * 2.4
            L = 58 - abs(k - 2) * 9 - t * 8
            for x in range(int(64 - L), 64):
                u = (x - (64 - L)) / L
                al = 255 * u * fade * (1 - abs(k - 2) * 0.18)
                over(im, x, int(y), a(WHITE if k == 2 else PALE, al))
        # crescent head
        for dy in range(-9, 10):
            x = 60 - int((dy * dy) / 14.0)
            over(im, x, 12 + dy, a(WHITE, 255 * fade))
            over(im, x - 1, 12 + dy, a(PALE, 200 * fade))
    save("dash_slash", fr)


# ---- rally aura: flame ring at the feet, 6 frames 40x24 (loops) ---------------------------------
def make_aura():
    fr = frame(6, 40, 24)
    rnd = random.Random(21)
    for i, im in enumerate(fr):
        cx, cy = 20, 14
        for k in range(26):
            ang = k * math.tau / 26
            x = cx + math.cos(ang) * 15
            y = cy + math.sin(ang) * 6.5
            h = 3 + 3 * abs(math.sin(ang * 3 + i * 1.1)) + rnd.random()
            for s in range(int(h)):
                al = 255 * (1 - s / h)
                px(im, x, y - s, a(WHITE if s < 2 else PALE, al))
        for k in range(26):
            ang = k * math.tau / 26
            px(im, cx + math.cos(ang) * 15, cy + math.sin(ang) * 6.5, a(WHITE, 255))
    save("rally_aura", fr)


# ---- tiger spirit: run (4 frames) and pounce (3 frames), 48x32, facing right ---------------------------
TIG = (255, 196, 92, 235)
TIG_L = (255, 232, 160, 240)
TIG_D = (190, 96, 30, 240)
STRIPE = (88, 38, 22, 245)
EYE = (120, 255, 230, 255)


def tiger_frame(phase, pounce=0.0):
    im = Image.new("RGBA", (48, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    lift = -int(round(pounce * 3))
    # tail
    tw = math.sin(phase * 2) * 2
    line(im, (9, 15 + lift), (5, 11 + tw + lift), TIG_D)
    line(im, (5, 11 + tw + lift), (3, 7 + tw + lift), TIG_D)
    px(im, 3, 6 + tw + lift, STRIPE)
    # legs
    leg = [(0, 3), (2, 1), (0, -2), (2, 0)]
    for k, lx in enumerate((12, 17, 28, 33)):
        sw = math.sin(phase + k * 1.6) * (3.5 if pounce == 0 else 5)
        base = 29 + (1 if pounce else 0)
        line(im, (lx, 18 + lift), (lx + sw, base), TIG_D if k % 2 == 0 else TIG)
        px(im, lx + sw, min(31, base + 1), TIG_L)
        px(im, lx + sw + 1, min(31, base + 1), TIG_L)
    # body (ellipse)
    for y in range(8, 24):
        for x in range(6, 38):
            if ((x - 22) / 16.5) ** 2 + ((y - 16 + (lift // 2)) / 6.5) ** 2 <= 1:
                px(im, x, y + (lift // 2), TIG if y < 18 else TIG_D)
    for y in range(9, 14):
        for x in range(10, 34):
            if ((x - 22) / 12.5) ** 2 + ((y - 11) / 3.0) ** 2 <= 1:
                px(im, x, y + (lift // 2), TIG_L)
    # stripes
    for sx in (13, 18, 23, 28):
        line(im, (sx, 10 + (lift // 2)), (sx + 1, 17 + (lift // 2)), STRIPE)
    # head
    hx, hy = 40, 12 + lift
    for y in range(-5, 6):
        for x in range(-5, 6):
            if (x / 5.2) ** 2 + (y / 4.8) ** 2 <= 1:
                px(im, hx + x, hy + y, TIG)
    px(im, hx - 4, hy - 5, TIG_D); px(im, hx - 3, hy - 6, TIG_D)   # ears
    px(im, hx + 1, hy - 5, TIG_D); px(im, hx + 2, hy - 6, TIG_D)
    for x in range(3, 8):                                           # muzzle
        px(im, hx + x, hy + 2, TIG_L); px(im, hx + x, hy + 3, TIG_L)
    px(im, hx + 7, hy + 2, STRIPE)
    px(im, hx + 2, hy - 1, EYE); px(im, hx + 3, hy - 1, EYE)       # spirit eyes
    line(im, (hx - 1, hy - 4), (hx + 1, hy - 2), STRIPE)           # brow stripes
    line(im, (hx - 3, hy - 3), (hx - 3, hy), STRIPE)
    if pounce > 0.5:                                                 # open jaw and claw flash
        px(im, hx + 6, hy + 4, WHITE); px(im, hx + 4, hy + 4, WHITE)
        for k in range(4):
            line(im, (hx + 8, hy - 2 + k * 2), (hx + 12, hy + k * 2 + 1), a(WHITE, 220))
    return im


def make_tiger():
    save("tiger_run", [tiger_frame(i * math.pi / 2) for i in range(4)])
    save("tiger_pounce", [tiger_frame(0.4, 0.0), tiger_frame(0.8, 0.6), tiger_frame(1.2, 1.0)])


# ---- ombak: wave crest 5 frames 48x32 facing right -------------------------------------------------
def make_ombak():
    fr = frame(5, 48, 32)
    for i, im in enumerate(fr):
        ph = i * 0.9
        cx, cy = 26, 16
        for y in range(32):
            for x in range(48):
                d_out = math.hypot(x - cx, y - cy)
                d_in = math.hypot(x - (cx - 7), y - cy)
                if d_out <= 15 and d_in >= 13 and x >= cx - 7:
                    u = (d_out - 8) / 7.0
                    c = WHITE if (d_in - 13) < 2.2 else (PALE if (d_in - 13) < 4.5 else MID)
                    px(im, x, y, c)
        # curling lip at both tips
        for sgn in (-1, 1):
            for t in range(6):
                px(im, cx - 5 + t * 1.4, cy + sgn * (14 - t * 0.5) + 0, WHITE)
        # trailing ripples
        for k in range(3):
            xr = 6 + k * 5
            for dy in range(-9 + k * 2, 10 - k * 2):
                if (dy + k + i) % 5 != 0:
                    px(im, xr + math.sin((dy + ph) * 0.7), 16 + dy, a(PALE if k else WHITE, 230 - k * 55))
        rnd = random.Random(i)
        for _ in range(9):
            px(im, 28 + rnd.uniform(0, 16), 16 + rnd.uniform(-13, 13), a(WHITE, 220))
    save("ombak_wave", fr)


# ---- cast sigil: rune circle drawn around the caster, 6 frames 64x64 ------------------------------
def make_sigil():
    fr = frame(6, 64, 64)
    for i, im in enumerate(fr):
        t = i / 5.0
        cx = cy = 32
        r = 12 + 18 * t
        al = 255 * (1 - t ** 2)
        ring(im, cx, cy, r, a(WHITE, al))
        ring(im, cx, cy, r - 2, a(PALE, al * 0.6))
        for k in range(8):
            ang = k * math.tau / 8 + t * 1.2
            line(im, (cx + math.cos(ang) * (r - 4), cy + math.sin(ang) * (r - 4)),
                 (cx + math.cos(ang) * (r + 3), cy + math.sin(ang) * (r + 3)), a(WHITE, al))
        for k in range(4):
            ang = k * math.tau / 4 + t * 2.4 + 0.4
            disc(im, cx + math.cos(ang) * r, cy + math.sin(ang) * r, 1.5, a(WHITE, al))
    save("cast_sigil", fr)


def make_spark():
    """Tiny 4-frame spark used for stroke embers and mote trails."""
    fr = frame(4, 8, 8)
    for i, im in enumerate(fr):
        al = 255 - i * 55
        px(im, 4, 4, a(WHITE, al))
        if i < 3:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                px(im, 4 + dx * (i + 1) // 1, 4 + dy * (i + 1), a(PALE, al * 0.7))
    save("ember", fr)


def preview():
    names = ["bolt_fly", "hit_burst", "ward_bubble", "ward_break", "shock", "bind_roots", "bind_ring", "heal_rise",
             "dash_slash", "rally_aura", "tiger_run", "tiger_pounce", "ombak_wave", "cast_sigil", "ember"]
    sheets = [Image.open(os.path.join(OUT, n + ".png")) for n in names]
    W = max(s.width for s in sheets) + 8
    H = sum(s.height + 6 for s in sheets) + 6
    pv = Image.new("RGBA", (W, H), (46, 52, 74, 255))
    y = 6
    for s in sheets:
        pv.alpha_composite(s, (4, y))
        y += s.height + 6
    pv.save(os.path.join(ROOT, "tools", "spell_fx_preview.png"))


if __name__ == "__main__":
    make_bolt(); make_hit(); make_ward(); make_shock(); make_bind(); make_heal(); make_slash()
    make_aura(); make_tiger(); make_ombak(); make_sigil(); make_spark()
    preview()
    print("ok", sorted(os.listdir(OUT)))
