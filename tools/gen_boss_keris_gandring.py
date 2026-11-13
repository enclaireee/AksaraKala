#!/usr/bin/env python3
"""The Cursed Keris of Mpu Gandring, boss redraw (wave 4 art pass v8). 72x72 cells (was 38x38).

It is a floating blade spirit (no wielder, no legs): a crimson wavy-bladed keris, gold ganja guard, dark wood hilt with a gold
pommel, wrapped in a stepped crimson aura. Idle points up; telegraph rears back then lunges right; dash flies right; slam
plunges point-down. The "feet" are the hover shadow on the bottom rows. Walk = a leaning float, kneel = the blade sinking,
dim, to rest slanted near the ground.
Outputs assets/art/enemies/keris_gandring.png (4x4: idle, walk, telegraph, hurt) and keris_gandring_moves.png (4x7: cast, slam,
dash, roar, rise, kneel, death), the contract of components/enemy_art.gd. Faces RIGHT.
tools/gen_bosses.py and gen_boss_moves.py no longer write these files. Painter comes from gen_boss_faceless_captain.py.
Also writes tools/boss_keris_gandring_preview.png.
Run: python3 tools/gen_boss_keris_gandring.py
"""
import math
import os
import random
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_boss_faceless_captain as F
from gen_boss_faceless_captain import mat, hexc

CW, CH = 72, 72
BLADE = mat("D83048", "3A0A1C", "8C1830", "FF6A78")
BLADE_D = mat("8A5A64", "2A1A22", "5A3640", "BE949C")
GOLD = F.GOLD
GOLD_D = mat("8A7850", "2A2216", "5E4E30", "C0AE84")
WOOD = mat("6A4028", "1E100C", "40261A", "9A6A44")
ACC = hexc("FF3B5C")
T = (BLADE[3], BLADE[2], BLADE[1])
L = 27.0   # half the keris length; the pivot is its middle


def aura(p, px, py, ca, sa, level):
    """Stepped crimson glow: capsules around the blade axis, alpha 3 levels, drawn under the blade."""
    for r, a in ((11, 44), (7, 84), (4, 120))[:level]:
        for y in range(CH):
            for x in range(CW):
                dx, dy = x + 0.5 - px, y + 0.5 - py
                u = max(-L + 11, min(L - 12, dx * ca + dy * sa))
                if math.hypot(dx - ca * u, dy - sa * u) <= r and ((x, y) not in p.pix or (x, y) in p.soft):
                    p.pix[(x, y)] = ACC[:3] + (a,)
                    p.soft.add((x, y))


def shadow(p, cx, hover):
    """The hover shadow, two stepped bands: the lowest point of the figure."""
    rx = max(7.0, 15.0 - hover * 0.45)
    for rr, a in ((1.0, 70), (0.62, 130)):
        for y in range(CH - 9, CH):
            for x in range(CW):
                if ((x + 0.5 - cx) / (rx * rr)) ** 2 + ((y + 0.5 - (CH - 4.6)) / (3.3 * rr)) ** 2 <= 1.0:
                    p.pix[(x, y)] = (22, 10, 34, a)
                    p.soft.add((x, y))


def sparks(p, px, py, n, spread, seed, light=BLADE):
    rnd = random.Random(seed)
    for i in range(n):
        x, y = px + rnd.uniform(-spread, spread), py + rnd.uniform(-spread * 1.3, spread * 1.3)
        c = light[3] if i % 2 else ACC
        F.rect(p, x, y, x + 2, y + 2, c)


def keris(p, px, py, ang, bm=BLADE, gm=GOLD, lift=0.0):
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    wx = lambda u, v: px + ca * u - sa * v
    wy = lambda u, v: py + sa * u + ca * v

    def luk(u):
        t = (u + 9) / 36.0
        return 2.7 * math.sin(2 * math.pi * (u + 9) / 11.0) * (1.0 - 0.45 * t)

    def hw(u):
        t = (u + 9) / 36.0
        return max(1.15, 6.4 * (1 - t) ** 0.85)

    def fn(x, y):
        dx, dy = x - px, y - py
        u, v = dx * ca + dy * sa, -dx * sa + dy * ca
        if u < -9 or u > L:
            return None
        w = hw(u)
        t = (v - luk(u)) / w
        return (-sa * t, ca * t) if abs(t) <= 1.0 else None
    # hilt: handle, bent head, gold mendak ring and pommel
    p.cap(wx(-22, 0), wy(-22, 0), wx(-14, 0), wy(-14, 0), 2.7, 2.3, WOOD)
    p.cap(wx(-22, 0), wy(-22, 0), wx(-25, -3.2), wy(-25, -3.2), 2.7, 2.6, WOOD)
    p.ell(wx(-26, -3.4), wy(-26, -3.4), 3.5, 3.5, gm)
    p.cap(wx(-15.5, 0), wy(-15.5, 0), wx(-13.5, 0), wy(-13.5, 0), 3.6, 3.6, gm)
    reg = p.region(fn, (px - 32, py - 32, px + 32, py + 32))
    blade = p.shade(reg, bm, lift=lift)
    pts = [(wx(u, luk(u)), wy(u, luk(u))) for u in range(-4, 22, 2)]
    p.line(pts, bm[3], 2.0, blade)                                  # the lit ridge down the blade
    pts = [(wx(u, luk(u) + 3.0 * (1 - (u + 9) / 40.0)), wy(u, luk(u) + 3.0 * (1 - (u + 9) / 40.0))) for u in range(-4, 16, 2)]
    p.line(pts, bm[1], 2.0, blade)                                  # a shaded pamor groove under it
    p.cap(wx(-11.5, -6.5), wy(-11.5, -6.5), wx(-11.5, 6.5), wy(-11.5, 6.5), 2.2, 2.2, gm)   # ganja, the guard


def cell(ang=-90, px=36, py=33, hover=0, glow=2, tone=0, orbs=(), spark=(0, 0, 0), ring=0, streak=False, rise=None, lift=0.0, alpha=1.0, **_):
    p = F.Paint(CW, CH)
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    if streak:
        F.streaks(T)(p, False)
    if rise is not None:                                              # climbs out of a ground hole
        for r_, c in ((13, hexc("1E1030")), (9, hexc("0E0818"))):
            p.ell(CW / 2, 64, r_, r_ * 0.28 + 1.4, (c,) * 4, rim=False)
    shadow(p, CW / 2 if abs(ca) < 0.5 else px, hover)
    if glow:
        aura(p, px, py, ca, sa, glow)
    bm, gm = (BLADE_D, GOLD_D) if tone else (BLADE, GOLD)
    keris(p, px, py, ang, bm, gm, lift)
    for k, (ox, oy, r) in enumerate(orbs):
        F.orb(p, px + ox, py + oy, r, (BLADE[1], ACC, BLADE[3], hexc("FFE0E4")))
    if spark[0]:
        sparks(p, px, py, spark[0], spark[1], spark[2])
    if ring:
        F.ground_rings(T, CW // 2, CW, CH)(p, ring, True)
    if rise is not None:
        for k_ in [k_ for k_ in p.pix if k_[1] > rise]:
            del p.pix[k_]
            p.soft.discard(k_)
    img = p.image()
    return F.fade(img, alpha) if alpha < 1.0 else img


def orbit(f, n=3, rx=22, ry=8, r=2.6):
    return [(rx * math.cos(f * 1.4 + k * 2.09), ry * math.sin(f * 1.4 + k * 2.09) - 4, r) for k in range(n)]


def main():
    idle = [cell(py=33 - h, hover=h, ang=-90 + a, glow=2, spark=(3, 17, f)) for f, (h, a) in enumerate(((0, 0), (1, 1.5), (2, 0), (1, -1.5)))]
    walk = [cell(px=px, py=35 - h, hover=h, ang=a, glow=2, spark=(5, 19, 10 + f)) for f, (px, h, a) in enumerate(((34, 0, -70), (35, 2, -62), (37, 0, -70), (36, 2, -78)))]
    tele = [cell(px=33, py=31, hover=4, ang=-120, glow=3, spark=(6, 20, 20)),
            cell(px=29, py=29, hover=6, ang=-138, glow=3, spark=(8, 22, 21)),
            cell(px=40, py=34, hover=2, ang=-18, glow=3, streak=False, spark=(4, 14, 22)),
            cell(px=45, py=36, hover=0, ang=0, glow=3, streak=True)]
    hurt = [cell(px=33, py=34, ang=-108, glow=1, lift=0.45, spark=(7, 20, 30)), cell(px=34, py=34, ang=-102, glow=1, lift=0.3, spark=(5, 18, 31)),
            cell(ang=-94, glow=2), cell(ang=-90, glow=2)]
    cast = [cell(py=28, hover=5, glow=3, orbs=orbit(f), spark=(4, 18, 40 + f)) for f in range(4)]
    slam = [cell(py=27, hover=6, glow=3, spark=(5, 19, 50)), cell(py=20, hover=9, glow=3, spark=(7, 21, 51), px=35),
            cell(ang=90, py=38, glow=3, ring=20, spark=(5, 18, 52)), cell(ang=90, py=38, glow=2, ring=27)]
    dash = [cell(px=30, py=36, ang=-12, glow=3), cell(px=36, py=36, ang=0, glow=3, streak=True), cell(px=40, py=36, ang=0, glow=3, streak=True),
            cell(px=38, py=36, ang=6, glow=2)]
    roar = [cell(py=33, glow=3, px=34, spark=(6, 22, 60)), cell(py=29, hover=4, glow=3, px=38, ring=14, spark=(9, 26, 61)),
            cell(py=29, hover=4, glow=3, px=34, ring=20, spark=(9, 28, 62)), cell(py=31, hover=3, glow=3, ring=26, spark=(7, 28, 63))]
    rise = [cell(py=33 + dy, glow=g, rise=64, hover=dy, spark=(3, 14, 70 + dy)) for dy, g in ((36, 0), (24, 1), (12, 2), (3, 3))]
    sink = [(-62, 36, 40), (-46, 35, 45), (-34, 35, 49), (-27, 34, 51)]
    kneel = [cell(ang=a, px=x, py=y, glow=0, tone=1, hover=0) for a, x, y in sink]
    death = [cell(ang=-27, px=34, py=51, glow=0, tone=1, alpha=a, spark=(n, 15 + 3 * i, 80 + i)) for i, (a, n) in enumerate(((1.0, 0), (0.75, 4), (0.45, 7), (0.2, 10)))]
    base, moves = [idle, walk, tele, hurt], [cast, slam, dash, roar, rise, kneel, death]
    F.finish("keris_gandring", CW, CH, base, moves)


if __name__ == "__main__":
    main()
