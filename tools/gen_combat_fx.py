#!/usr/bin/env python3
"""Budayago combat FX sheets (Phase 6c, combat.md 2.3b). Stdlib only (tools/pilite.py PNG writer, no PIL needed).
Every sheet is a horizontal strip of equal square-ish frames, in assets/art/fx/. Smears, sparks, rings, trails and
glows are white or grey so attack_fx.gd can modulate them per class. Ink and dust keep their own colours.
Smear frames are authored facing right (+x) with the pivot (the player's aim origin) at the frame centre; the arc
sits at radius R_REF and spans ARC_REF degrees, and attack_fx.gd scales it to the weapon's reach and arc.
Run: python3 tools/gen_combat_fx.py   Output: assets/art/fx/*.png and tools/fx_preview.png
"""
import math
import os
import random
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pilite
pilite.install()
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "art", "fx")
S = 48            # smear frame size
R_REF = 20.0      # smear arc radius in px
ARC_REF = 100.0   # smear arc span in degrees
INK = (28, 18, 44)


def strip(n, w, h):
    return Image.new("RGBA", (n * w, h), (0, 0, 0, 0))


def blend(im, x, y, c):
    """Alpha-over a pixel."""
    if not (0 <= x < im.width and 0 <= y < im.height) or c[3] == 0:
        return
    d = im.getpixel((x, y))
    sa, da = c[3] / 255.0, d[3] / 255.0
    oa = sa + da * (1 - sa)
    im.putpixel((x, y), tuple(int((c[k] * sa + d[k] * da * (1 - sa)) / oa) for k in range(3)) + (int(oa * 255),))


def grey(v, a=255):
    return (v, v, v, a)


# ---- smears -------------------------------------------------------------------------------
def arc_frame(thick, a0, a1, fade=1.0, core=0.0, grey_lo=170, tail_cut=0.0, dots=0):
    """One crescent frame. Arc spans angles a0..a1 (degrees, 0 = +x, positive = down). The leading edge is a1.
    thick = peak thickness px; core = fraction of thickness drawn as a white core; tail_cut thins the tail end."""
    im = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    cx = cy = S / 2.0
    for y in range(S):
        for x in range(S):
            dx, dy = x + 0.5 - cx, y + 0.5 - cy
            r = math.hypot(dx, dy)
            th = math.degrees(math.atan2(dy, dx))
            if not (a0 <= th <= a1):
                continue
            u = (th - a0) / max(1e-6, a1 - a0)                 # 0 tail .. 1 head
            env = math.sin(math.pi * min(1.0, 0.12 + 0.88 * u)) ** 0.6   # fat middle, thin tips, fatter near the head
            env *= (1 - tail_cut) + tail_cut * u
            half = thick * 0.5 * env
            # crescent: outer edge bulges, inner edge flatter (centre of the ring shifts toward the pivot)
            d = r - (R_REF - thick * 0.1 * (1 - env))
            if abs(d) > half:
                continue
            q = 1 - abs(d) / max(half, 0.5)                    # 1 centre .. 0 edge
            a = fade * (0.7 + 0.3 * q) * (0.55 + 0.45 * u)
            if q > 0.12 and a > 0.2:
                lvl = q * (0.5 + 0.5 * u)
                v = 255 if (core > 0 and abs(d) < half * core) else (255 if lvl > 0.55 else 225 if lvl > 0.3 else grey_lo)
                im.putpixel((x, y), (v, v, v, min(255, int(a * 255 * (1.0 if fade > .6 else 1.0)))))
    if dots:
        rnd = random.Random(7 + dots)
        for _ in range(dots):
            th = math.radians(rnd.uniform(a0, a1))
            rr = R_REF + rnd.uniform(-5, 6)
            blend(im, int(cx + math.cos(th) * rr), int(cy + math.sin(th) * rr), grey(235, int(180 * fade)))
    return im


def smear_sheet(name, frames):
    sh = strip(4, S, S)
    for i, fr in enumerate(frames):
        sh.alpha_composite(fr, (i * S, 0))
    sh.save(os.path.join(OUT, name))
    return sh


def make_smears():
    out = {}
    out["smear_light"] = smear_sheet("smear_light.png", [
        arc_frame(5, -50, -5, .9), arc_frame(6, -50, 28, 1.0),
        arc_frame(6, -45, 50, 1.0), arc_frame(4, -10, 52, .6, tail_cut=.7, dots=3)])
    out["smear_heavy"] = smear_sheet("smear_heavy.png", [
        arc_frame(7, -50, -10, .9), arc_frame(10, -50, 30, 1.0),
        arc_frame(11, -50, 50, 1.0), arc_frame(8, -5, 52, .55, tail_cut=.8, dots=5)])
    out["smear_finisher"] = smear_sheet("smear_finisher.png", [
        arc_frame(10, -55, -5, .9, grey_lo=190), arc_frame(14, -55, 32, 1.0, grey_lo=190),
        arc_frame(15, -52, 54, 1.0, grey_lo=190), arc_frame(10, -10, 56, .5, grey_lo=190, tail_cut=.8, dots=6)])
    out["smear_core"] = smear_sheet("smear_core.png", [
        arc_frame(9, -55, -5, .95, core=0.8), arc_frame(14, -55, 32, 1.0, core=0.8),
        arc_frame(15, -52, 54, 1.0, core=0.85), arc_frame(8, -10, 56, .45, core=0.8, tail_cut=.8)])
    # thrust streak: a wedge from the pivot forward; frames grow then fade
    th = strip(4, S, S)
    for i, (ln, w, a) in enumerate(((22, 2, .8), (30, 4, 1.0), (30, 5, .9), (26, 3, .45))):
        im = Image.new("RGBA", (S, S), (0, 0, 0, 0))
        c = S // 2
        x0 = c + (0 if i < 3 else 6)
        for x in range(x0, min(S, x0 + ln)):
            t = (x - x0) / float(ln)                           # 0 base .. 1 tip
            half = w * (1 - t) ** 0.7 * (0.35 + 0.65 * min(1, t * 4))
            for y in range(S):
                d = abs(y + 0.5 - c)
                if d <= half:
                    q = 1 - d / max(half, 0.5)
                    v = int(180 + 75 * q)
                    im.putpixel((x, y), (v, v, v, int(255 * a * (0.4 + 0.6 * q) * (0.55 + 0.45 * t))))
        th.alpha_composite(im, (i * S, 0))
    th.save(os.path.join(OUT, "smear_thrust.png"))
    out["smear_thrust"] = th
    return out


# ---- impacts ------------------------------------------------------------------------------
def make_spark():
    n, w = 4, 24
    sh = strip(n, w, w)
    for i, (ln, th, a) in enumerate(((5, 2, 1.0), (10, 3, 1.0), (11, 2, .85), (8, 1, .45))):
        im = Image.new("RGBA", (w, w), (0, 0, 0, 0))
        c = w / 2.0
        for y in range(w):
            for x in range(w):
                dx, dy = abs(x + 0.5 - c), abs(y + 0.5 - c)
                # four-point star: two thin crossed diamonds plus a diagonal pair, shorter
                s1 = dx / ln + dy * (1.0 / th) / 4.0 * 0 if False else 0
                v = (dx / float(ln)) ** 0.6 + (dy / float(th)) ** 1.2
                h = (dy / float(ln)) ** 0.6 + (dx / float(th)) ** 1.2
                dg = (dx + dy) / (ln * 0.6) + abs(dx - dy) / 1.8
                if v <= 1 or h <= 1:
                    q = 1 - min(v, h)
                    val = 255 if q > 0.35 else 225
                    im.putpixel((x, y), (val, val, 255 if q > 0.6 else 235, int(255 * a)))
                elif dg <= 1 and i < 3:
                    im.putpixel((x, y), (255, 240, 200, int(170 * a)))
        sh.alpha_composite(im, (i * w, 0))
    sh.save(os.path.join(OUT, "spark.png"))
    return sh


def make_ink_splash():
    n, w = 4, 24
    sh = strip(n, w, w)
    rnd = random.Random(11)
    blobs = [(rnd.uniform(-1, 1), rnd.uniform(-1, 1), rnd.uniform(0.6, 1.4)) for _ in range(9)]
    for i in range(n):
        im = Image.new("RGBA", (w, w), (0, 0, 0, 0))
        grow = (0.4, 0.8, 1.0, 1.05)[i]
        fade = (1, 1, .9, .55)[i]
        for bx, by, bs in blobs:
            # splashes spray forward (+x) from the left-centre
            px_ = 4 + (bx * 0.5 + 0.6) * 15 * grow
            py_ = w / 2 + by * 8 * grow
            rad = max(0.6, bs * (2.2 - i * 0.35))
            for y in range(w):
                for x in range(w):
                    if math.hypot(x + 0.5 - px_, y + 0.5 - py_) <= rad:
                        blend(im, x, y, (INK[0], INK[1], INK[2], int(235 * fade)))
        # lighter rim pixels so the ink reads against dark ground
        for y in range(w):
            for x in range(w):
                if im.getpixel((x, y))[3] > 0 and (x + y) % 5 == 0 and i < 3:
                    im.putpixel((x, y), (86, 62, 120, im.getpixel((x, y))[3]))
        sh.alpha_composite(im, (i * w, 0))
    sh.save(os.path.join(OUT, "ink_splash.png"))
    return sh


def make_ring():
    n, w = 3, 32
    sh = strip(n, w, w)
    for i, (r, th, a) in enumerate(((7, 3, 1.0), (12, 2, .8), (15, 1.2, .4))):
        im = Image.new("RGBA", (w, w), (0, 0, 0, 0))
        c = w / 2.0
        for y in range(w):
            for x in range(w):
                d = abs(math.hypot(x + 0.5 - c, y + 0.5 - c) - r)
                if d <= th / 2.0 + 0.4:
                    q = 1 - d / (th / 2.0 + 0.4)
                    im.putpixel((x, y), (255, 255, 255, int(255 * a * (0.5 + 0.5 * q))))
        sh.alpha_composite(im, (i * w, 0))
    sh.save(os.path.join(OUT, "ring.png"))
    return sh


def make_ink_puff():
    n, w = 5, 32
    sh = strip(n, w, w)
    rnd = random.Random(23)
    lobes = [(rnd.uniform(0, 6.283), rnd.uniform(0.4, 1.0), rnd.uniform(0.7, 1.2)) for _ in range(8)]
    for i in range(n):
        im = Image.new("RGBA", (w, w), (0, 0, 0, 0))
        c = w / 2.0
        spread = (3, 7, 10, 12, 13)[i]
        fade = (1, 1, .9, .6, .3)[i]
        for ang, dist, size in lobes:
            lx, ly = c + math.cos(ang) * spread * dist, c + math.sin(ang) * spread * dist - i * 0.6
            rad = size * (3.6 - i * 0.45)
            for y in range(w):
                for x in range(w):
                    dd = math.hypot(x + 0.5 - lx, y + 0.5 - ly)
                    if dd <= rad:
                        shade = 0.0 if dd < rad * 0.6 else 1.0
                        col = (INK[0] + int(60 * shade), INK[1] + int(44 * shade), INK[2] + int(70 * shade))
                        blend(im, x, y, col + (int(230 * fade),))
        sh.alpha_composite(im, (i * w, 0))
    sh.save(os.path.join(OUT, "ink_puff.png"))
    return sh


# ---- dust, muzzle, trail, glow --------------------------------------------------------------
def puffs(name, n, w, base_r, grow, seed, col=(226, 214, 190), count=5):
    sh = strip(n, w, w)
    rnd = random.Random(seed)
    lobes = [(rnd.uniform(0, 6.283), rnd.uniform(0.5, 1.0), rnd.uniform(0.7, 1.2)) for _ in range(count)]
    for i in range(n):
        im = Image.new("RGBA", (w, w), (0, 0, 0, 0))
        c = w / 2.0
        fade = (0.95, 0.8, 0.55, 0.3, 0.15)[min(i, 4)] if n > 3 else (0.9, 0.55, 0.25)[i]
        for ang, dist, size in lobes:
            lx = c + math.cos(ang) * (base_r + grow * i) * dist
            ly = c + math.sin(ang) * (base_r + grow * i) * dist * 0.6 - i * 0.5
            rad = size * (base_r * 0.55 + grow * i * 0.25)
            for y in range(w):
                for x in range(w):
                    dd = math.hypot(x + 0.5 - lx, y + 0.5 - ly)
                    if dd <= rad:
                        sh_ = 1.0 if (x - lx) + (y - ly) > 0 else 0.0   # lit top-left, shaded bottom-right
                        k = 0.86 if sh_ else 1.0
                        blend(im, x, y, (int(col[0] * k), int(col[1] * k), int(col[2] * k), int(255 * fade)))
        sh.alpha_composite(im, (i * w, 0))
    sh.save(os.path.join(OUT, name))
    return sh


def make_muzzle():
    n, w, h = 3, 24, 24
    sh = strip(n, w, h)
    for i, (ln, th, a) in enumerate(((9, 4, 1.0), (14, 6, .85), (18, 3, .45))):
        im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        c = h / 2.0
        x0 = 3
        for y in range(h):
            for x in range(x0, w):
                t = (x - x0) / float(ln)
                if t > 1:
                    continue
                half = th * (1 - t) ** 0.8 * (0.4 + 0.6 * min(1, t * 5))
                d = abs(y + 0.5 - c)
                if d <= half:
                    q = 1 - d / max(half, 0.5)
                    v = int(200 + 55 * q)
                    im.putpixel((x, y), (v, v, v, int(255 * a * (0.5 + 0.5 * q))))
        for k in (-1, 1):   # side flares
            for t in range(4):
                blend(im, x0 + 2 + t, int(c + k * (1 + t * 0.9 * (i + 1) * 0.5)), grey(235, int(200 * a)))
        sh.alpha_composite(im, (i * w, 0))
    sh.save(os.path.join(OUT, "muzzle.png"))
    return sh


def make_arrow_trail():
    n, w, h = 2, 16, 8
    sh = strip(n, w, h)
    for i, ln in enumerate((12, 15)):
        im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        for x in range(w):
            t = (w - 1 - x) / float(ln)            # 0 at the arrow end (right) .. 1 tail (left)
            if t > 1:
                continue
            half = 1.6 * (1 - t) ** 0.7 + 0.2
            for y in range(h):
                d = abs(y + 0.5 - h / 2.0)
                if d <= half:
                    im.putpixel((x, y), (255, 255, 255, int(200 * (1 - t) ** 1.2 * (1 - 0.5 * d / half))))
        sh.alpha_composite(im, (i * w, 0))
    sh.save(os.path.join(OUT, "arrow_trail.png"))
    return sh


def make_bolt():
    n, w = 3, 16
    glow = strip(n, w, w)
    for i, rad in enumerate((5.0, 6.5, 5.5)):
        im = Image.new("RGBA", (w, w), (0, 0, 0, 0))
        c = w / 2.0
        for y in range(w):
            for x in range(w):
                d = math.hypot(x + 0.5 - c, y + 0.5 - c)
                if d <= rad:
                    q = 1 - d / rad
                    v = 255 if d < rad * 0.4 else int(190 + 60 * q)
                    im.putpixel((x, y), (v, v, v, int(255 * (0.25 + 0.75 * q ** 0.8))))
        glow.alpha_composite(im, (i * w, 0))
    glow.save(os.path.join(OUT, "bolt_glow.png"))
    sp = strip(n, 8, 8)
    rnd = random.Random(5)
    for i in range(n):
        im = Image.new("RGBA", (8, 8), (0, 0, 0, 0))
        for _ in range(4 - i):
            x, y = rnd.randint(1, 6), rnd.randint(1, 6)
            im.putpixel((x, y), (255, 255, 255, 255 - i * 60))
            if i == 0:
                blend(im, x + 1, y, (255, 255, 255, 140))
        sp.alpha_composite(im, (i * 8, 0))
    sp.save(os.path.join(OUT, "bolt_spark.png"))
    return glow, sp


def main():
    os.makedirs(OUT, exist_ok=True)
    sheets = []
    sm = make_smears()
    for k in ("smear_light", "smear_heavy", "smear_thrust", "smear_finisher", "smear_core"):
        sheets.append((k, sm[k], 48))
    sheets.append(("spark", make_spark(), 24))
    sheets.append(("ink_splash", make_ink_splash(), 24))
    sheets.append(("ring", make_ring(), 32))
    sheets.append(("ink_puff", make_ink_puff(), 32))
    sheets.append(("dust", puffs("dust.png", 4, 16, 4.0, 1.4, 31), 16))
    sheets.append(("step_dust", puffs("step_dust.png", 3, 8, 1.6, 0.8, 41, count=3), 8))
    sheets.append(("muzzle", make_muzzle(), 24))
    sheets.append(("arrow_trail", make_arrow_trail(), 16))
    g, s = make_bolt()
    sheets.append(("bolt_glow", g, 16))
    sheets.append(("bolt_spark", s, 8))
    for k, im, _ in sheets:
        print("wrote", k, im.size)
    # preview on dark ground and light ground, 4x
    Z = 4
    W = max(im.width for _, im, _ in sheets) * Z + 16
    H = sum(im.height * Z + 8 for _, im, _ in sheets) + 8
    prev = Image.new("RGBA", (W, H), (60, 80, 64, 255))
    y = 8
    for _, im, _ in sheets:
        big = im.resize((im.width * Z, im.height * Z), Image.NEAREST)
        prev.alpha_composite(big, (8, y))
        y += big.height + 8
    prev.save(os.path.join(os.path.dirname(os.path.abspath(__file__)), "fx_preview.png"))


if __name__ == "__main__":
    main()
