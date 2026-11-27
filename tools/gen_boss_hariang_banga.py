#!/usr/bin/env python3
"""Hariang Banga, boss redraw (wave 4 art pass v8). 56x64 cells (was 26x34).

Outputs assets/art/enemies/hariang_banga.png (8x4: idle, walk, telegraph, hurt) and hariang_banga_moves.png (8x9: cast,
slam, dash, roar, rise, kneel, death), the contract of components/enemy_art.gd. Faces RIGHT, feet on the bottom row.
A slim Galuh prince-swordsman in blue lamellar, a long white cape, a tall red plume, a cyan-edged blade held in front guard.
tools/gen_bosses.py and gen_boss_moves.py no longer write these files. Painter comes from gen_boss_faceless_captain.py.
This file also holds the stride-aware pose table (rows), legs2 and the solid ring/streak/chip FX that
gen_boss_bandung_bondowoso.py and gen_boss_sandekala.py import. Also writes tools/boss_hariang_banga_preview.png.
Run: python3 tools/gen_boss_hariang_banga.py
"""
import math
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_boss_faceless_captain as F
from gen_boss_faceless_captain import mat, hexc, GOLD, WHITE, RED

REST_R = ((13, 38), (14, 48))
REST_L = ((-13, 38), (-14, 48))


# ---------------------------------------------------------------- shared: legs, FX, pose table
def legs2(p, cx, gy, hip, step=0, lift=(0, 0), kneel=False, spread=4.5, stride=4, thigh=None, shin=None, boot=None,
          th=3.6, sh=3.0, wid=4.2, bend=2.0):
    """Two legs that stride: step -1..1 puts the left foot forward (+1) or back (-1); lift raises each foot (L, R)."""
    for i, s in enumerate((-1, 1)):
        hx = cx + s * spread * 0.8
        if kneel:
            if i == 0:      # rear leg: knee on the ground, shin lying back
                kx, ky, fx, fy = cx - 2.5, gy - 2.5, cx - 13.0, gy - 2.5
            else:           # front leg: foot planted, thigh near level
                kx, ky, fx, fy = cx + 10.5, hip + 5.0, cx + 9.0, gy
        else:
            fx = cx + s * spread + (stride * step if s < 0 else -stride * step)
            fy = gy - lift[i]
            kx, ky = (hx + fx) / 2 + bend + lift[i] * 0.5, (hip + fy) / 2 - lift[i] * 0.3
        p.cap(kx, ky, fx, fy - 1.5, sh, sh * 0.9, shin)
        p.cap(hx, hip, kx, ky, th, th * 0.88, thigh)
        p.ell(fx + (1.0 if not (kneel and i == 0) else -1.5), fy, wid, 2.7, boot)


def ring_fx(p, cx, cy, r, m, front):
    """A solid 3 px stepped ground ring in perspective. front=False draws the far half (before the body), True the near half."""
    if r < 6:
        return
    ry = max(3.0, r * 0.3)
    t = 4 if r >= 18 else 3
    for y in range(int(cy - ry - 1), int(cy + ry + 2)):
        for x in range(int(cx - r - 1), int(cx + r + 2)):
            if (y >= cy) != front or not (0 <= x < p.w and 0 <= y < p.h):
                continue
            dx, dy = x + 0.5 - cx, y + 0.5 - cy
            if (dx / r) ** 2 + (dy / ry) ** 2 <= 1.0 and (dx / (r - t)) ** 2 + (dy / max(1.0, ry - t + 1)) ** 2 > 1.0:
                p.pix[(x, y)] = m[3] if dy < -ry * 0.35 else (m[2] if dy < ry * 0.45 else m[1])


def streak_fx(p, m):
    """Speed streaks trailing behind: 3 px bars that step down in tone."""
    for y, l, c in ((31, 18, 3), (39, 24, 2), (47, 20, 3), (55, 14, 2)):
        p.line([(-2 + 20 - l, y), (14 + 4, y)], m[c], 3.0)


def chip_fx(p, cx, gy, n, m):
    """Flying chunks (n 1..3): 3 px blobs on a fixed fan so a frame never looks random."""
    for i, (dx, dy, r) in enumerate(((-17, -5, 1.7), (17, -9, 1.9), (-9, -14, 1.5), (11, -17, 1.6), (-22, -13, 1.4), (22, -3, 1.4))[:n * 2]):
        p.ell(cx + dx, gy + dy, r, r, m)


def crescent(p, cx, cy, r, thick, a0, a1, m, ry=None):
    """A chunky swept arc in pixel coords: angles a0..a1 (deg, 0 = right, 90 = down), thickest mid-sweep, tone bands step
    from m[1] (inner) to m[3] and a white core on the outer edge. ry squashes it into an ellipse."""
    ry = ry or r
    n = 16

    def band(lo, hi, c):
        o, i_ = [], []
        for k in range(n + 1):
            t = k / float(n)
            a = math.radians(a0 + (a1 - a0) * t)
            th = thick * math.sin(math.pi * t) ** 0.6
            for rad, dst in ((r + th * hi, o), (r + th * lo, i_)):
                dst.append((cx + rad * math.cos(a), cy + rad * (ry / float(r)) * math.sin(a)))
        p.poly(o + i_[::-1], c)
    band(-0.5, 0.5, m[1])
    band(-0.1, 0.5, m[2])
    band(0.15, 0.5, m[3])
    if thick >= 6:
        band(0.38, 0.5, (255, 255, 255, 255))


def rim_light(im, col, amt=0.65):
    """Cold phase-2 rim: solid pixels whose top or right neighbour is empty or outline are pulled toward col."""
    src, out = im.load(), im.copy()
    po = out.load()
    W, H_ = im.size

    def empty(x, y):
        return not (0 <= x < W and 0 <= y < H_) or src[x, y][3] == 0 or src[x, y] == F.OUTLINE
    for y in range(H_):
        for x in range(W):
            c = src[x, y]
            if c[3] == 255 and c != F.OUTLINE and (empty(x, y - 1) or empty(x + 1, y)):
                po[x, y] = F.mix(c, col, amt)
    return out


def draw(cw, ch, body, fx, rings=0, streak=False, chips=0, guard=(0, 0), smear=(0, 0, 0), **kw):
    """guard = (radius, thickness) of a cyan guard arc behind the body, smear = (a0, a1, thickness) of a slash crescent over it
    (both in pixel coords of Hariang's 56x64 cell, off at thickness < 2)."""
    p = F.Paint(cw, ch, 1.0, 0.0, ch - 64)
    if rings:
        ring_fx(p, cw // 2, ch - 5, rings, fx, False)
    if streak:
        streak_fx(p, fx)
    if guard[1] >= 2:
        g = F.Paint(cw, ch, 1.0, 0.0, 0.0)
        crescent(g, cw // 2 - 3, 38, guard[0], guard[1], -62, 62, fx, ry=guard[0] * 1.05)
        p.pix.update(g.pix)
    body(p, **kw)
    if rings:
        ring_fx(p, cw // 2, ch - 5, rings, fx, True)
    if chips:
        chip_fx(p, cw // 2, 56, chips, fx)
    if smear[2] >= 2:
        g = F.Paint(cw, ch, 1.0, 0.0, 0.0)
        crescent(g, cw // 2 + 11 + kw.get("lean", 0.0), 38, 17, smear[2], smear[0], smear[1], fx)
        p.pix.update(g.pix)
    return p.image()


def rows(cell, idle_ang=-85, up=-105, strike=(35, 55), rest_r=REST_R, rest_l=REST_L, reach=(5, 22), planted=((13, 40), (14, 40)),
         walk_swing=3, sig1=None, sig2=None):
    """Pose table, 8 frames a row (F.expand tweens the keyframes). cell(**kw) draws one pose. sig1/sig2: optional keyframe-dict
    lists (2..8) for moves rows 7 and 8, None = a heavier slam / a lunging dash."""
    cyc = [2 * math.pi * f / 8 for f in range(8)]
    sn = math.sin
    idle = [dict(breath=1.2 * (0.5 - 0.5 * math.cos(a)), arm_r=((rest_r[0][0], rest_r[0][1]), (rest_r[1][0], rest_r[1][1] + 0.7 * sn(a - 0.8))),
                 arm_l=((rest_l[0][0], rest_l[0][1]), (rest_l[1][0], rest_l[1][1] + 0.7 * sn(a - 0.8))), ang=idle_ang + 3 * sn(a - 0.4),
                 reach=reach, sway=1.4 * sn(a - 1.0), head=(0.5 * sn(a - 1.4), 0.4 * sn(a - 0.6))) for a in cyc]
    walk = []
    for a in cyc:       # contact (feet apart, body low) -> pass (one foot lifted, body high), arms counter-swing
        c = math.cos(a)
        walk.append(dict(breath=abs(c), lean=1.0, step=c, lift=(3 * max(0, -sn(a)), 3 * max(0, sn(a))), head=(0, 0.5 * math.cos(2 * a)),
                         arm_r=((rest_r[0][0], rest_r[0][1]), (rest_r[1][0] + walk_swing * c, rest_r[1][1])),
                         arm_l=((rest_l[0][0], rest_l[0][1]), (rest_l[1][0] - walk_swing * c, rest_l[1][1])),
                         ang=idle_ang + 8 * c, reach=reach, sway=1.5 * sn(a - 0.8)))
    wa = dict(arm_r=((16, 33), (14, 25)), ang=up, glow=True, mouth=2, breath=-1, lean=-1.0, reach=reach, step=-1)
    wb = dict(arm_r=((17, 30), (15, 21)), ang=up - 12, glow=True, mouth=2, breath=-1.5, lean=-2.5, crouch=1, reach=reach, step=-1, sway=1)
    tele = F.pulse(wa, wb) + [
        dict(arm_r=((16, 38), (21, 38)), ang=(up + strike[0]) / 2.0, glow=True, mouth=2, crouch=1, lean=1.5, reach=reach, step=0, streak=True),
        dict(arm_r=((15, 40), (20, 46)), ang=strike[0], glow=True, mouth=2, crouch=3, lean=3.5, reach=reach, step=1),
        dict(arm_r=((15, 42), (19, 50)), ang=strike[1], glow=True, mouth=2, crouch=3, lean=3.0, reach=reach, step=1),
        dict(arm_r=((15, 42), (19, 50)), ang=strike[1], glow=True, mouth=2, crouch=2, lean=2.0, reach=reach, step=1)]
    sa = dict(mouth=0, head=(-2, 1), lean=-2.5, tilt=True, ang=-55, arm_r=rest_r, arm_l=((-15, 34), (-17, 42)), reach=reach, step=-1)
    sb = dict(mouth=2, head=(-1, 0), lean=-1.5, tilt=True, ang=-65, arm_r=rest_r, arm_l=rest_l, reach=reach, step=0, sway=1)
    hurt = F.pulse(sa, sb) + F.expand([dict(mouth=0, head=(-3, 3), lean=-5.0, crouch=3, tilt=True, ang=-35, arm_r=rest_r, arm_l=((-16, 32), (-18, 40)), reach=reach, step=-1),
                                      dict(mouth=0, head=(0, 0), lean=0.5, tilt=True, ang=-70, arm_r=rest_r, arm_l=rest_l, reach=reach, sway=2), sa],
                                     4, [0, 1, 3], ["out", "io"])
    cl = (((-15, 32), (-16, 22)), ((-15, 30), (-16, 18)), ((-15, 29), (-15, 16)), ((-14, 34), (-13, 25)))
    cast = F.expand([dict(arm_l=cl[f], orb=(0.2, 0.6, 1.0, 0.3)[f], glow=True, mouth=1, ang=idle_ang, reach=reach, arm_r=rest_r) for f in range(4)],
                    8, [0, 2, 4, 7], "io")
    s_up = dict(arm_r=((15, 31), (14, 25)), arm_l=((-15, 32), (-14, 25)), ang=up, glow=True, mouth=2, breath=-2, reach=reach, lean=-1.0)
    s_up2 = dict(arm_r=((16, 29), (15, 23)), arm_l=((-16, 29), (-15, 23)), ang=up - 6, glow=True, mouth=2, breath=-3, reach=reach, lean=-2.0)
    s_dn = dict(arm_r=((15, 44), (17, 56)), arm_l=((-14, 44), (-15, 55)), ang=75, glow=True, mouth=2, crouch=5, reach=reach, rings=20, chips=1, lean=3.0, step=1)
    s_dn2 = dict(arm_r=((15, 44), (17, 56)), arm_l=((-14, 44), (-15, 55)), ang=75, mouth=1, crouch=4, reach=reach, rings=27, chips=2, lean=2.0, step=1)
    slam = F.expand([s_up, s_up2, s_dn, s_dn2], 8, [0, 3, 4, 7], ["io", "out", "out"])
    d0 = dict(lean=2.0, crouch=3, arm_r=((15, 38), (19, 44)), ang=-8, glow=True, reach=reach, step=-1)
    d1 = dict(lean=4.0, crouch=3, arm_r=((16, 37), (22, 42)), ang=-4, glow=True, step=1, lift=(0, 3), reach=reach, streak=True)
    d2 = dict(lean=5.0, crouch=3, arm_r=((16, 37), (22, 42)), ang=0, glow=True, step=-1, lift=(3, 0), reach=reach, streak=True)
    d3 = dict(lean=2.0, crouch=1, arm_r=((15, 40), (19, 46)), ang=10, reach=reach, step=1)
    dash = F.expand([d0, d1, d2, d3], 8, [0, 2, 5, 7], ["out", "io", "io"])
    r0 = dict(head=(0, 1), mouth=1, breath=1, arm_r=rest_r, ang=idle_ang, reach=reach)
    r1 = dict(head=(0, -2), mouth=3, glow=True, arm_l=((-17, 36), (-19, 44)), arm_r=((17, 36), (19, 44)), breath=-1, rings=14, ang=-60, reach=reach, lean=-1.0)
    r2 = dict(r1, rings=20)
    r3 = dict(head=(0, -1), mouth=2, glow=True, arm_l=((-16, 38), (-17, 46)), arm_r=((16, 38), (17, 46)), rings=26, ang=-70, reach=reach)
    roar = F.expand([r0, r1, r2, r3], 8, [0, 2, 4, 7], ["in", "io", "io"])
    kn = dict(kneel=True, tilt=True, glow=False, arm_r=planted, arm_l=((-8, 40), (-3, 49)), ang=88, reach=(4, 14))
    rise = F.expand([dict(crouch=8, lean=1.0, head=(0, 1), **kn),
                     dict(crouch=6, lean=-1.0, head=(0, 0), mouth=1, **dict(kn, glow=True)),
                     dict(crouch=2, lean=-1.0, glow=True, mouth=2, arm_r=rest_r, arm_l=rest_l, ang=idle_ang, reach=reach, rings=16),
                     dict(glow=True, mouth=3, breath=-1, arm_r=rest_r, arm_l=rest_l, ang=idle_ang, reach=reach, rings=24)], 8, [0, 2, 5, 7], "io")
    kneel = F.expand([dict(crouch=8, lean=2.0, head=(0, 1), **kn), dict(crouch=8, lean=3.0, head=(1, 2), mouth=0, **kn),
                      dict(crouch=8, lean=3.5, head=(1, 3), mouth=0, **kn)], 8, [0, 3, 7], "out")
    for f, kw in enumerate(kneel):     # the kneeler breathes
        kw["breath"] = 0.5 * sn(f * 0.9)
    death = F.expand([dict(crouch=8, lean=4.0, head=(1, 3), mouth=0, _a=1.0, **kn), dict(crouch=8, lean=7.0, head=(1, 5), mouth=0, _a=0.1, **kn)], 8, None, "in")
    spec = dict(idle=idle, walk=walk, tele=tele, hurt=hurt, cast=cast, slam=slam, dash=dash, roar=roar, rise=rise, kneel=kneel, death=death)
    return F.assemble(cell, spec, sig1, sig2)


# ---------------------------------------------------------------- Hariang Banga
CW, CH = 56, 64
BLUE = mat("4F7FB5", "121E36", "2E5080", "9CC4EC")
BLUE2 = mat("3C5E9C", "0C1428", "24407A", "7CA0D8")
NAVY2 = mat("202E52", "080E1C", "141E3C", "4A64A0")
NAVY = mat("2C4468", "0C1426", "1C2C4C", "5A7CA8")
SKIN = mat("D9A47E", "5E2E2A", "A8704E", "F0C8A0")
HAIR = mat("2E2634", "120E18", "1E1824", "55485E")
PLUME = mat("D8323A", "400C18", "9E1E2E", "FF7A78")
BLADE = mat("D4E6FF", "5A6E90", "9CB4D8", "FFFFFF")
GLOWB = mat("7DF0FF", "1C5A78", "46B8D8", "E8FFFF")
ACC = hexc("7DF0FF")
FXC = GLOWB


def blade(p, hx, hy, ang, back, fwd, w, m, hilt):
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    nx, ny = -sa, ca
    if nx + ny > 0:
        nx, ny = -nx, -ny
    gx, gy = hx + ca * 2, hy + sa * 2
    ex, ey = hx + ca * fwd, hy + sa * fwd
    p.cap(hx - ca * back, hy - sa * back, gx, gy, 1.5, 1.5, NAVY)
    kx, ky = gx + (ex - gx) * 0.74, gy + (ey - gy) * 0.74

    def strip(a_, b_, c):
        p.poly([(gx + nx * w * a_, gy + ny * w * a_), (kx + nx * w * a_, ky + ny * w * a_), (ex, ey), (kx + nx * w * b_, ky + ny * w * b_),
                (gx + nx * w * b_, gy + ny * w * b_)], c)
    strip(1.0, -1.0, m[1])
    strip(1.0, -0.25, m[2])
    strip(1.0, 0.4, m[3])
    p.cap(gx + nx * 3.6, gy + ny * 3.6, gx - nx * 3.6, gy - ny * 3.6, 1.3, 1.3, hilt)
    p.ell(hx - ca * back, hy - sa * back, 1.8, 1.8, hilt)


def hariang(p, breath=0, crouch=0, lean=0.0, step=0, lift=(0, 0), head=(0, 0), arm_l=REST_L, arm_r=REST_R, ang=-85,
            reach=(5, 22), glow=False, mouth=1, orb=0.0, tilt=False, kneel=False, sway=0, p2=False):
    if p2:      # phase 2: a fiercer forward lean, cooler cloth, loose hair, a second blade
        lean += 2.0
        crouch += 1
    bl, nv = (BLUE2, NAVY2) if p2 else (BLUE, NAVY)
    b = breath + crouch
    cx = CW / 2 + lean
    hx, hy = cx + 1 + head[0] + lean * 0.4, 16 + b + head[1]
    # long white cape behind the body
    p.trap([(26 + b, cx - 6, cx + 5), (42 + crouch, cx - 10 - sway, cx + 7 - sway), (59, cx - 15 - sway * 2, cx + 10 - sway * 2)], WHITE)
    p.trap([(40 + crouch, cx - 9 - sway, cx - 5 - sway), (59, cx - 15 - sway * 2, cx - 9 - sway * 2)], mat("B8C8E0", "5A6E90", "8CA0C0", "E8F0FF"), rim=False)
    legs2(p, cx, 60, 44 + crouch, step, lift, kneel, spread=4.0, stride=4, thigh=bl, shin=nv, boot=nv, th=3.3, sh=2.8, wid=4.0)
    # skirt panel and torso
    p.trap([(42 + crouch, cx - 7, cx + 7), (50, cx - 10, cx + 10)], bl)
    p.trap([(48, cx - 9.6, cx + 9.6), (50, cx - 10, cx + 10)], GOLD, rim=False)
    tor = p.trap([(25 + b, cx - 5.5, cx + 5.5), (28 + b, cx - 9, cx + 9), (36 + b, cx - 7.6, cx + 7.6), (45 + b, cx - 6.3, cx + 6.3)], bl)
    p.line([(cx - 8, 27 + b), (cx + 5, 44 + b)], GOLD[2], 3.0, tor)
    p.line([(cx - 8, 26 + b), (cx + 5, 43 + b)], GOLD[3], 1.0, tor)
    p.line([(cx - 7, 33 + b), (cx + 7, 33 + b)], bl[1], 1.0, tor)
    p.trap([(43 + b, cx - 6.6, cx + 6.6), (46 + b, cx - 6.6, cx + 6.6)], GOLD)
    p.ell(cx + 1, 44.5 + b, 2.0, 2.0, GOLD)
    gem = (ACC, ACC, ACC, hexc("E8FFFF")) if glow else mat("2E5080")
    p.ell(cx + 1, 31 + b, 1.8, 1.8, gem, rim=False)
    # head: open-faced prince under a plumed helm
    p.cap(hx - 1, hy + 3, cx, 26 + b, 2.8, 3.2, SKIN)
    if not p2:
        p.cap(hx - 4, hy - 1, hx - 7, hy + 6, 2.6, 2.0, nv)
    p.ell(hx, hy + 0.5, 5.6, 6.4, SKIN)
    for s in (-1, 1):
        ex, ey = hx + s * 2.7 + 1.0, hy + 0.2
        p.cap(ex - 1.8, ey - 2.2 - s * 0.3 * (1 if not tilt else -1), ex + 1.8, ey - 2.2 + s * 0.3 * (1 if not tilt else -1), 0.9, 0.9, (HAIR[1],) * 4, rim=False)
        if tilt:
            p.cap(ex - 1.2, ey + 0.6, ex + 1.2, ey + 0.6, 0.6, 0.6, (HAIR[1],) * 4, rim=False)
        else:
            ec = ACC if glow else GLOWB[2]
            p.cap(ex - 0.8, ey + 0.4, ex + 0.8, ey + 0.4, 1.0, 1.0, (ec, ec, ec, ec), rim=False)
    p.cap(hx + 1.4, hy + 3.2, hx + 4.6, hy + 3.2, 0.8, 0.8, (HAIR[2],) * 4, rim=False)
    if mouth > 1:
        p.cap(hx + 1.6, hy + 4.8, hx + 4.0, hy + 4.8, 0.9, 0.9, (SKIN[0],) * 4, rim=False)
    if p2:      # the helm and headband are gone: wild loose hair streaming back
        for i, (dx, dy, ln) in enumerate(((-3, -2, 9), (-5, 1, 12), (-4, 4, 11), (-2, -5, 8))):
            sw = sway * (1 + i * 0.3)
            p.cap(hx + 1 + dx * 0.4, hy - 4 + i, hx + dx - 8 - sw - ln * 0.5, hy + dy + 3 + i * 2.2, 2.4, 1.0, HAIR)
        p.ell(hx, hy - 4.4, 6.4, 3.8, HAIR)
        p.cap(hx - 3, hy - 6.5, hx + 5, hy - 5.2, 1.0, 0.8, (HAIR[3],) * 4, rim=False)
        p.cap(hx + 2, hy - 4, hx + 5, hy - 0.5, 1.1, 0.8, HAIR, rim=False)       # a wild forelock over the brow
    else:
        p.trap([(hy - 8.2, hx - 5.4, hx + 5.4), (hy - 3.4, hx - 6.6, hx + 6.6)], bl)
        p.trap([(hy - 4.6, hx - 6.6, hx + 6.6), (hy - 3.0, hx - 6.8, hx + 6.8)], GOLD, rim=False)
        p.cap(hx + 5.2, hy - 3, hx + 5.2, hy + 1.2, 1.1, 1.1, GOLD)     # nose guard
        p.cap(hx, hy - 8, hx + 0.5, hy - 11, 1.6, 1.0, GOLD)
        p.cap(hx - 2, hy - 8, hx - 7 - sway, hy - 11, 2.8, 2.0, PLUME)
        p.cap(hx - 7 - sway, hy - 11, hx - 11 - sway * 2, hy - 5, 2.0, 1.4, PLUME)
    # arms: left (back) arm balanced, right arm holds the blade in front guard
    shl, shr = (cx - 9, 27 + b), (cx + 9, 27 + b)
    el, hl = (cx + arm_l[0][0] * 0.8, arm_l[0][1] + b), (cx + arm_l[1][0] * 0.8, arm_l[1][1] + b)
    er, hr = (cx + arm_r[0][0] * 0.85, arm_r[0][1] + b), (cx + arm_r[1][0] * 0.85, arm_r[1][1] + b)
    if p2 and orb <= 0:      # a second, short blade reversed in the off hand
        blade(p, hl[0], hl[1], -48, 2, 11, 1.7, GLOWB, GOLD)
    F.limb_arm(p, shl, el, hl, bl, SKIN, 3.0)
    p.ell(shl[0], shl[1], 4.6, 4.0, bl)
    p.cap(shl[0] - 3.4, shl[1] + 1.5, shl[0] + 3.4, shl[1] + 1.5, 1.0, 1.0, GOLD)
    if orb > 0:
        F.orb(p, hl[0], hl[1] - 7, 1.6 + orb * 3.4, (GLOWB[1], ACC, hexc("B8F8FF"), hexc("FFFFFF")))
    blade(p, hr[0], hr[1], ang, reach[0], reach[1], 2.4, GLOWB if glow else BLADE, GOLD)
    F.limb_arm(p, shr, er, hr, bl, SKIN, 3.0)
    p.ell(shr[0], shr[1], 4.6, 4.0, bl)
    p.cap(shr[0] - 3.4, shr[1] + 1.5, shr[0] + 3.4, shr[1] + 1.5, 1.0, 1.0, GOLD)
    if p2:      # cyan streaks cut across the cloth
        for (x0, y0, x1, y1) in ((-8, 30, -2, 41), (-1, 34, 5, 44), (-9, 46, -5, 54), (2, 47, 7, 55)):
            p.line([(cx + x0, y0 + b), (cx + x1, y1 + b)], GLOWB[2], 1.0)
            p.line([(cx + x0 + 1, y0 + b), (cx + x1 + 1, y1 + b)], GLOWB[3], 1.0)
        p.line([(cx - 8, 56), (cx - 13 - sway, 59)], GLOWB[2], 1.0)


def cell(p2=False, **kw):
    im = draw(CW, CH, hariang, FXC, p2=p2, **kw)
    return H_rim(im) if p2 else im


def H_rim(im):
    return rim_light(im, hexc("A8F4FF"), 0.7)


# the two signature rows: 8 explicit frames each (guard = (radius, thickness), smear = (a0, a1, thickness))
G0 = (0, 0)
S0 = (0, 0, 0)


def sig_guard():
    """guard stance: a low crouch, blade level across the body, a cyan guard arc that pulses (cols 2-7 loop)."""
    base = dict(crouch=3, lean=-1.0, step=1, ang=-4, arm_r=((10, 36), (7, 40)), arm_l=((-14, 34), (-17, 29)), reach=(4, 18), glow=True, mouth=2)
    fr = [dict(crouch=1, lean=0.0, step=0, ang=-70, arm_r=((14, 33), (13, 28)), arm_l=((-14, 36), (-15, 34)), reach=(4, 18), glow=True, mouth=2, guard=G0),
          dict(base, crouch=2, ang=-30, arm_r=((12, 35), (9, 38)), guard=(14, 3))]
    for f in range(2, 8):
        ph = 2 * math.pi * (f - 2) / 6.0
        fr.append(dict(base, guard=(21 + 2.0 * math.sin(ph), 5.5 + 1.5 * math.sin(ph + 1.0)), breath=0.6 * math.sin(ph)))
    for k in fr:
        k.setdefault("smear", S0)
    return fr


def sig_riposte():
    """riposte flurry: three fast slashes (upper, lower, wide overhead) with alternating smears, last frame follows through."""
    A = dict(glow=True, mouth=2, reach=(4, 18))
    fr = [dict(A, lean=-2.0, ang=-100, arm_r=((15, 31), (14, 26)), step=-1),
          dict(A, lean=1.0, ang=-35, arm_r=((14, 38), (17, 39)), step=1, smear=(-85, -15, 7), streak=True),
          dict(A, lean=0.0, ang=40, arm_r=((13, 42), (15, 46)), step=1, crouch=1),
          dict(A, lean=2.0, ang=-25, arm_r=((14, 37), (17, 36)), step=0, crouch=2, smear=(75, 0, 7), streak=True),
          dict(A, lean=1.0, ang=-70, arm_r=((14, 32), (15, 27)), step=1),
          dict(A, lean=3.0, ang=35, arm_r=((15, 40), (18, 47)), step=1, crouch=2, smear=(-95, 40, 8), streak=True),
          dict(A, lean=4.0, ang=55, arm_r=((15, 43), (19, 50)), step=1, crouch=3, smear=(15, 50, 3), streak=True),
          dict(A, lean=2.5, ang=30, arm_r=((15, 42), (19, 49)), step=1, crouch=2, glow=False, mouth=1)]
    for k in fr:
        k.setdefault("smear", S0)
        k.setdefault("guard", G0)
    return fr


def main():
    kw = dict(idle_ang=-80, up=-110, strike=(35, 60), reach=(5, 24), rest_r=((15, 38), (19, 45)))
    base, moves = rows(cell, sig1=sig_guard(), sig2=sig_riposte(), **kw)
    p2 = rows(lambda **k: cell(p2=True, **k), sig1=sig_guard(), sig2=sig_riposte(), **kw)
    F.finish("hariang_banga", CW, CH, base, moves, p2=p2)


if __name__ == "__main__":
    main()
