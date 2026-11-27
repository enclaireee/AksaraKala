#!/usr/bin/env python3
"""The Cursed Keris of Mpu Gandring, boss redraw (wave 4 art pass v8). 72x72 cells (was 38x38).

It is a floating blade spirit (no wielder, no legs): a crimson wavy-bladed keris, gold ganja guard, dark wood hilt with a gold
pommel, wrapped in a stepped crimson aura. Idle points up; telegraph rears back then lunges right; dash flies right; slam
plunges point-down. The "feet" are the hover shadow on the bottom rows. Walk = a leaning float, kneel = the blade sinking,
dim, to rest slanted near the ground.
Outputs assets/art/enemies/keris_gandring.png (8x4: idle, walk, telegraph, hurt) and keris_gandring_moves.png (8x9: cast, slam,
dash, roar, rise, kneel, death, blade drill, split into seven), plus the _p2 pair (cracked blade, black-red aura), the 8-frame contract of components/enemy_art.gd. Faces RIGHT.
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
BLADE2 = mat("A01830", "1A040E", "5A0C22", "E04868")    # phase 2: darker, cracked
GHOST = mat("E8B8D0", "3A1A3A", "B8788E", "FFF0F6")
AURA2 = (150, 14, 40, 255)
T = (BLADE[3], BLADE[2], BLADE[1])
L = 27.0   # half the keris length; the pivot is its middle


def aura(p, px, py, ca, sa, level, col=None):
    """Stepped crimson glow: capsules around the blade axis, alpha 3 levels, drawn under the blade."""
    for r, a in ((11, 44), (7, 84), (4, 120))[:level]:
        for y in range(CH):
            for x in range(CW):
                dx, dy = x + 0.5 - px, y + 0.5 - py
                u = max(-L + 11, min(L - 12, dx * ca + dy * sa))
                if math.hypot(dx - ca * u, dy - sa * u) <= r and ((x, y) not in p.pix or (x, y) in p.soft):
                    p.pix[(x, y)] = (col or ACC)[:3] + (a,)
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


def keris(p, px, py, ang, bm=BLADE, gm=GOLD, lift=0.0, s=1.0, wscale=1.0, p2=False):
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    wx = lambda u, v: px + (ca * u - sa * v) * s
    wy = lambda u, v: py + (sa * u + ca * v) * s
    amp = 4.0 if p2 else 2.7          # p2: a deeper, wilder luk

    def luk(u):
        t = (u + 9) / 36.0
        return amp * math.sin(2 * math.pi * (u + 9) / 11.0) * (1.0 - 0.45 * t)

    def hw(u):
        t = (u + 9) / 36.0
        return max(1.15, 6.4 * (1 - t) ** 0.85) * wscale

    def fn(x, y):
        dx, dy = (x - px) / s, (y - py) / s
        u, v = dx * ca + dy * sa, -dx * sa + dy * ca
        if u < -9 or u > L:
            return None
        w = hw(u)
        t = (v - luk(u)) / w
        return (-sa * t, ca * t) if abs(t) <= 1.0 else None
    # hilt: handle, bent head, gold mendak ring and pommel
    p.cap(wx(-22, 0), wy(-22, 0), wx(-14, 0), wy(-14, 0), 2.7 * s, 2.3 * s, WOOD)
    p.cap(wx(-22, 0), wy(-22, 0), wx(-25, -3.2), wy(-25, -3.2), 2.7 * s, 2.6 * s, WOOD)
    p.ell(wx(-26, -3.4), wy(-26, -3.4), 3.5 * s, 3.5 * s, gm)
    p.cap(wx(-15.5, 0), wy(-15.5, 0), wx(-13.5, 0), wy(-13.5, 0), 3.6 * s, 3.6 * s, gm)
    reg = p.region(fn, (px - 32, py - 32, px + 32, py + 32))
    blade = p.shade(reg, bm, lift=lift)
    if s >= 1.0:
        pts = [(wx(u, luk(u)), wy(u, luk(u))) for u in range(-4, 22, 2)]
        p.line(pts, bm[3], 2.0, blade)                                  # the lit ridge down the blade
        pts = [(wx(u, luk(u) + 3.0 * (1 - (u + 9) / 40.0)), wy(u, luk(u) + 3.0 * (1 - (u + 9) / 40.0))) for u in range(-4, 16, 2)]
        p.line(pts, bm[1], 2.0, blade)                                  # a shaded pamor groove under it
    p.cap(wx(-11.5, -6.5), wy(-11.5, -6.5), wx(-11.5, 6.5), wy(-11.5, 6.5), 2.2 * s, 2.2 * s, gm)   # ganja, the guard
    if p2 and s >= 1.0:                                                 # the crack, with red curse light leaking out
        zz = [(wx(3, -4), wy(3, -4)), (wx(6, 0), wy(6, 0)), (wx(9, -2), wy(9, -2)), (wx(12, 3), wy(12, 3)), (wx(15, 1), wy(15, 1))]
        p.line(zz, bm[0], 2.0, blade)
        for (x, y), c in zip(zz[1:4], (hexc("FF8090"), hexc("FFE0E4"), hexc("FF6A78"))):
            F.rect(p, x - 1, y - 1, x + 1, y + 1, c)
        for dx, dy in ((-3, -3), (4, 3)):
            F.rect(p, zz[2][0] + dx, zz[2][1] + dy, zz[2][0] + dx + 2, zz[2][1] + dy + 2, hexc("FF6A78"))


def wisp(p, x, y, bright, seed):
    """The trapped spirit: a small flame-shaped ghost at the pommel. p2 is larger and brighter."""
    tn = (hexc("A01030"), hexc("FF4060"), hexc("FF98A8"), hexc("FFFFFF")) if bright else (hexc("3A2060"), hexc("6A48A8"), hexc("A488E0"), hexc("E4D8FF"))
    k = 1.35 if bright else 1.0
    w = (seed % 3 - 1) * 0.8
    p.ell(x + w, y - 3 * k, 2.8 * k, 3.2 * k, tn)
    p.ell(x + w * 1.8, y - 7.5 * k, 1.9 * k, 2.6 * k, tn)
    p.ell(x + w * 2.6, y - 11 * k, 1.1 * k, 1.6 * k, tn)


def drill_fx(p, px, py, ca, sa, ph):
    """Two chunky helix strands wound round the blade, narrowing to the tip."""
    for strand in (0.0, math.pi):
        for i in range(15):
            u = -18 + i * 3.4
            R = 7.5 * (1 - (u + 18) / 62.0)
            v = R * math.sin(ph + u * 0.32 + strand)
            x, y = px + ca * u - sa * v, py + sa * u + ca * v
            r = 1.5 + 0.6 * (0.5 + 0.5 * math.cos(ph + u * 0.32 + strand))
            p.ell(x, y, r, r, BLADE)


def burst_fx(p, px, py, k):
    for i in range(8):
        th = math.radians(i * 45 + 10)
        p.cap(px + math.cos(th) * 6, py + math.sin(th) * 6, px + math.cos(th) * (9 + 17 * k), py + math.sin(th) * (9 + 17 * k), 2.4, 0.9, GHOST, rim=False)


def cell(ang=-90, px=36, py=33, hover=0, glow=2, tone=0, orb=0, spark=(0, 0, 0), ring=0, streak=False, rise=0, lift=0.0, drill=0.0,
         flash=0.0, fan=0.0, p2=False, **_):
    p = F.Paint(CW, CH)
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    glow = int(glow)
    if streak:
        F.streaks(T)(p, False)
    if rise:                                                          # climbs out of a ground hole
        for r_, c in ((13, hexc("1E1030")), (9, hexc("0E0818"))):
            p.ell(CW / 2, 64, r_, r_ * 0.28 + 1.4, (c,) * 4, rim=False)
    shadow(p, CW / 2 if abs(ca) < 0.5 else px, hover)
    if glow:
        aura(p, px, py, ca, sa, glow, AURA2 if p2 else None)
    if p2:                                                            # black-red aura chunks drifting round the blade
        rnd = random.Random(int(py) * 7 + int(ang) % 11 + int(spark[2]))
        for i in range(8):
            u, v = rnd.uniform(-22, 24), rnd.choice((-1, 1)) * rnd.uniform(9, 15)
            x, y = px + ca * u - sa * v, py + sa * u + ca * v
            n = rnd.choice((2, 3))
            F.rect(p, x, y, x + n, y + n, (14, 4, 12, 255) if i % 2 else (110, 8, 30, 255))
            F.rect(p, x, y, x + n, y + 1, (190, 24, 52, 255))
    bm, gm = (BLADE_D, GOLD_D) if tone >= 0.5 else ((BLADE2 if p2 else BLADE), GOLD)
    if flash > 0:
        bm = tuple(F.mix(c, (255, 255, 255, 255), flash * 0.8) for c in bm)
        burst_fx(p, px, py, flash)
    bx, by = px + ca * -27 - sa * -3.4, py + sa * -27 + ca * -3.4
    wisp(p, bx, by - 3, p2, int(spark[2]))
    if drill > 0:
        drill_fx(p, px, py, ca, sa, drill)
    if fan > 0:                                                       # seven ghost blades fanned out from the split
        for i in (0, 6, 1, 5, 2, 4, 3):
            a = ang + (i - 3) * 24
            ra = math.radians(a)
            keris(p, px + math.cos(ra) * fan, py + math.sin(ra) * fan, a, GHOST, GOLD_D, s=0.72, p2=False)
    else:
        keris(p, px, py, ang, bm, gm, lift, wscale=(0.55 + 0.45 * abs(math.cos(drill * 1.0)) if drill > 0 else 1.0), p2=p2)
    if orb:
        for ox, oy, r in orbit(orb):
            F.orb(p, px + ox, py + oy, r, (BLADE[1], ACC, BLADE[3], hexc("FFE0E4")))
    if spark[0] >= 0.5:
        sparks(p, px, py, int(round(spark[0])), spark[1], int(spark[2]))
    if ring:
        F.ground_rings(T, CW // 2, CW, CH)(p, ring, True)
    if rise:
        for k_ in [k_ for k_ in p.pix if k_[1] > rise]:
            del p.pix[k_]
            p.soft.discard(k_)
    return p.image()


def orbit(f, n=3, rx=22, ry=8, r=2.6):
    return [(rx * math.cos(f * 1.4 + k * 2.09), ry * math.sin(f * 1.4 + k * 2.09) - 4, r) for k in range(n)]


def spec():
    cyc = [2 * math.pi * f / 8 for f in range(8)]
    idle = [dict(py=33 - (1 - math.cos(a)), hover=1 - math.cos(a), ang=-90 + 1.5 * math.sin(a), glow=2, spark=(3, 17, f)) for f, a in enumerate(cyc)]
    walk = [dict(px=35 + 2.2 * math.sin(a), py=35 - (1 - math.cos(2 * a)), hover=1 - math.cos(2 * a), ang=-70 - 8 * math.sin(a), glow=2, spark=(5, 19, 10 + f)) for f, a in enumerate(cyc)]
    wa, wb = dict(px=33, py=31, hover=4, ang=-120, glow=3, spark=(6, 20, 20)), dict(px=29, py=29, hover=6, ang=-138, glow=3, spark=(8, 22, 21))
    tele = F.pulse(wa, wb) + [dict(px=36, py=32, hover=3, ang=-60, glow=3, spark=(5, 16, 22)), dict(px=40, py=34, hover=2, ang=-18, glow=3, spark=(4, 14, 23)),
                              dict(px=45, py=36, ang=0, glow=3, streak=True), dict(px=46, py=36, ang=0, glow=3, streak=True)]
    sa_, sb_ = dict(px=33, py=34, ang=-108, glow=1, lift=0.45, spark=(7, 20, 30)), dict(px=34, py=34, ang=-102, glow=1, lift=0.3, spark=(5, 18, 31))
    hurt = F.pulse(sa_, sb_) + F.expand([dict(px=31, py=36, ang=-122, glow=1, lift=0.5, spark=(8, 22, 32)), dict(ang=-94, glow=2), dict(ang=-90, glow=2)], 4, [0, 1, 3], ["out", "io"])
    cast = F.expand([dict(py=28, hover=5, glow=3, orb=0.5 + f * 0.9, spark=(4, 18, 40 + f)) for f in range(4)], 8, [0, 2, 4, 7], "io")
    slam = F.expand([dict(py=27, hover=6, glow=3, spark=(5, 19, 50)), dict(py=20, hover=9, glow=3, spark=(7, 21, 51), px=35),
                     dict(ang=90, py=38, glow=3, ring=20, spark=(5, 18, 52)), dict(ang=90, py=38, glow=2, ring=27)], 8, [0, 3, 4, 7], ["io", "out", "out"])
    dash = F.expand([dict(px=30, py=36, ang=-12, glow=3), dict(px=36, py=36, ang=0, glow=3, streak=True), dict(px=40, py=36, ang=0, glow=3, streak=True),
                     dict(px=38, py=36, ang=6, glow=2)], 8, [0, 2, 5, 7], ["out", "io", "io"])
    roar = F.expand([dict(py=33, glow=3, px=34, spark=(6, 22, 60)), dict(py=29, hover=4, glow=3, px=38, ring=14, spark=(9, 26, 61)),
                     dict(py=29, hover=4, glow=3, px=34, ring=20, spark=(9, 28, 62)), dict(py=31, hover=3, glow=3, ring=26, spark=(7, 28, 63))], 8, [0, 2, 4, 7], ["in", "io", "io"])
    rise = F.expand([dict(py=33 + dy, glow=g, rise=64, hover=dy, spark=(3, 14, 70 + dy)) for dy, g in ((36, 0), (24, 1), (12, 2), (3, 3))], 8, [0, 2, 5, 7], "io")
    kneel = F.expand([dict(ang=a, px=x, py=y, glow=0, tone=1, hover=0) for a, x, y in ((-62, 36, 40), (-46, 35, 45), (-34, 35, 49), (-27, 34, 51))], 8, [0, 2, 5, 7], "out")
    death = F.expand([dict(ang=-27, px=34, py=51, glow=0, tone=1, _a=1.0, spark=(0, 15, 80)), dict(ang=-27, px=34, py=51, glow=0, tone=1, _a=0.1, spark=(10, 24, 90))], 8, None, "in")
    sp = dict(idle=idle, walk=walk, tele=tele, hurt=hurt, cast=cast, slam=slam, dash=dash, roar=roar, rise=rise, kneel=kneel, death=death)
    # sig1 blade drill: rears back (cols 0-1), then spins point-first, 6-frame loop on cols 2-7
    drill = [dict(px=28, py=34, ang=-35, glow=3, spark=(4, 16, 100)), dict(px=26, py=33, ang=-48, glow=3, spark=(6, 18, 101))] + \
            [dict(px=29, py=36, ang=0, glow=3, streak=True, drill=0.01 + 2 * math.pi * (f - 2) / 6, spark=(6, 18, 102 + f)) for f in range(2, 8)]
    # sig2 split into seven: the blade flashes white (cols 0-3), seven ghost blades fan out (cols 4-7)
    split = [dict(px=30, py=36, ang=0, glow=3, flash=(0.2, 0.55, 0.9, 1.0)[f], spark=(4 + f * 2, 16, 120 + f)) for f in range(4)] + \
            [dict(px=21, py=36, ang=0, glow=3, fan=(8, 17, 22, 21)[f], flash=(0.5, 0.2, 0, 0)[f], spark=(8, 24, 130 + f)) for f in range(4)]
    return sp, drill, split


def main():
    sp, d, sl = spec()
    rows = F.assemble(cell, sp, d, sl)
    sp2 = {k: [dict(kw, p2=True) for kw in v] for k, v in sp.items()}
    rows2 = F.assemble(cell, sp2, [dict(kw, p2=True) for kw in d], [dict(kw, p2=True) for kw in sl])
    F.finish("keris_gandring", CW, CH, rows[0], rows[1], p2=rows2)


if __name__ == "__main__":
    main()
