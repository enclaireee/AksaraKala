#!/usr/bin/env python3
"""Sandekala, boss redraw (wave 4 art pass v8). 56x72 cells (was 26x42).

Outputs assets/art/enemies/sandekala.png (4x4: idle, walk, telegraph, hurt) and sandekala_moves.png (4x7: cast, slam,
dash, roar, rise, kneel, death), the contract of components/enemy_art.gd. Faces RIGHT, feet (the hem) on the bottom row.
A tall, hunched dusk spirit: no legs, a ragged indigo shroud, two long swept horns, a void face with magenta eyes and
a row of pale teeth, long arms ending in lavender claws. Its hem tatters stride in the walk row.
tools/gen_bosses.py and gen_boss_moves.py no longer write these files. Painter comes from gen_boss_faceless_captain.py,
the pose table and FX from gen_boss_hariang_banga.py. Also writes tools/boss_sandekala_preview.png.
Run: python3 tools/gen_boss_sandekala.py
"""
import math
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_boss_faceless_captain as F
import gen_boss_hariang_banga as H
from gen_boss_faceless_captain import mat, hexc

CW, CH = 56, 72
SHROUD = mat("2B2347", "0C0818", "1C1432", "524488")
FLESH = mat("3B2F66", "100A22", "2A2050", "7468B4")
BONE = mat("D9CCFF", "5A4C8A", "A898E0", "FFFFFF")
VOID = hexc("0A0614")
MAG = hexc("FF4DF0")
DUSK = hexc("FF8A3D")
FXC = mat("B83AC8", "2A0C3A", "7A2A98", "FF8AF4")
SHROUD2 = mat("14102A", "040208", "0A0618", "3E3270")
FLESH2 = mat("241C48", "08040F", "140E2A", "5C4E9A")
AMBER = hexc("FFB020")
POOL = (hexc("07030E"), hexc("100A20"), hexc("1A1130"), hexc("3A2C66"))
GROUND = 68         # cell y of the ground line (the hem)


def claws(p, hx, hy, dx, dy, n=3, ln=5.5, w=1.5):
    """n lavender claws fanned along the forearm direction (dx, dy)."""
    a0 = math.atan2(dy, dx)
    for i in range(n):
        a = a0 + (i - (n - 1) / 2) * 0.55
        p.cap(hx, hy, hx + math.cos(a) * ln, hy + math.sin(a) * ln, w, 0.8, BONE)


def arm(p, sh, el, ha, shroud=SHROUD, flesh=FLESH, grab=False):
    p.cap(el[0], el[1], ha[0], ha[1], 2.9, 2.2, flesh)
    p.cap(sh[0], sh[1], el[0], el[1], 3.6, 3.0, shroud)
    p.ell(ha[0], ha[1], 3.0, 2.8, flesh)
    claws(p, ha[0], ha[1], ha[0] - el[0], ha[1] - el[1], 4 if grab else 3, 7.5 if grab else 5.5, 1.7 if grab else 1.5)


def sandekala(p, breath=0, crouch=0, lean=0.0, step=0, lift=(0, 0), head=(0, 0), arm_l=H.REST_L, arm_r=H.REST_R, ang=0,
              reach=(0, 0), glow=False, mouth=1, orb=0.0, tilt=False, kneel=False, sway=0, form=1, sink=0.0, pool=0.0, armfree=0.0, grab=False):
    f2 = form == 2
    shroud, flesh = (SHROUD2, FLESH2) if f2 else (SHROUD, FLESH)
    eye = AMBER if f2 else MAG
    shift = sink * 72       # melting: the whole body slides down into the pool and is cut at the ground
    oy0 = p.oy
    p.oy += shift
    b = breath + crouch
    cx = CW / 2 + lean
    hx, hy = cx + 4 + head[0] + lean * 0.4, 15 + b + head[1] + (2 if kneel else 0) - (3 if f2 else 0)
    # trailing wisps behind the shoulders
    p.cap(cx - 5, 27 + b, cx - 13 - sway * 2, 46 + b, 3.4, 1.0, shroud)
    p.cap(cx - 3, 30 + b, cx - 10 - sway * 2, 54, 2.8, 0.8, flesh)
    if f2:      # more tendrils: long smoky streamers off the shoulders and back
        for k, (dx, ex_, ey_, rr) in enumerate(((-2, -16, 36, 2.4), (0, -18, 50, 2.0), (3, -12, 60, 1.8), (6, 2, 25, 1.6))):
            p.cap(cx + dx, 29 + b, cx + ex_ - sway * (2 + k), ey_ + b * 0.5, rr, 0.7, shroud if k % 2 else flesh)
    # shroud: narrow shoulders, a long ragged skirt
    hem = 60 if not kneel else 61
    p.trap([(24 + b, cx - 4.5, cx + 6.5), (30 + b, cx - 8, cx + 8.5), (44 + crouch, cx - 11 + sway * 0.5, cx + 10), (hem - 5, cx - 12 + sway, cx + 12 + sway * 0.5)], shroud)
    # ragged tatters: they stride (step) and lift in the walk row
    for i in range(8 if f2 else 6):
        x = cx - 11 + i * (3.3 if f2 else 4.4) + sway * 0.5
        ph = (i + int(round(step)) + 1) % 2
        up_ = lift[ph] + (1 if i % 3 == 0 else 0) * 2
        tx = x + (step * 2.4 if i % 2 else -step * 2.4) + (3 if kneel else 0) * (i - 2.5) / 2.5
        ty = hem - up_ - (0 if kneel else (i % 3))
        p.cap(x, hem - 8, tx, ty, 2.6, 1.3, shroud if i % 2 else flesh)
        p.ell(tx, ty, 1.5, 1.2, (shroud[0], eye, eye, hexc("FFE8A0") if f2 else hexc("FFB0F8")), rim=False)
    # ribs and a dim heart
    tor = p.trap([(28 + b, cx - 6, cx + 7), (40 + b, cx - 8, cx + 8.5)], flesh, rim=False)
    for k in range(3):
        p.line([(cx - 6, 31 + b + k * 3.4), (cx + 5, 32 + b + k * 3.4)], shroud[1], 2.0, tor)
    c = (eye, eye, eye, hexc("FFE8A0") if f2 else hexc("FFB0F8")) if glow else (shroud[1], shroud[1], shroud[2], shroud[2])
    p.ell(cx + 1, 38 + b, 2.2, 2.2, c, rim=False)
    # head: a long pale-violet skull, the face a void
    p.cap(hx - 2, hy + 3, cx + 1, 27 + b, 3.2, 3.8, flesh)
    # two long horns: one swept far back, one rising forward, each with a bone tip
    for bx, tx, ty, col, tipx, tipy in ((hx - 4, hx - 12 - sway * 2, hy - 12, shroud, hx - 16 - sway * 3, hy - 19),
                                         (hx + 2, hx + 5, hy - 14, flesh, hx + 8, hy - 19)):
        p.cap(bx, hy - 4, tx, ty, 2.8, 1.6, col)
        p.cap(tx, ty, tipx, tipy, 1.6, 0.9, BONE)
    p.ell(hx, hy, 6.6, 7.4, flesh)
    fv = p.ell(hx + 1.6, hy + 0.8, 4.8, 5.6, (VOID, VOID, VOID, VOID), rim=False)
    for s in (-1, 1):
        ex, ey = hx + 1.6 + s * 2.2, hy - 0.8
        if tilt:
            p.cap(ex - 1.2, ey, ex + 1.2, ey + 0.8, 0.7, 0.7, (flesh[2],) * 4, rim=False)
        else:
            ew = 1.3 if f2 else 0.8
            p.cap(ex - ew, ey, ex + ew, ey, 1.0, 1.0 + 0.4 * f2, (eye, eye, eye, hexc("FFF0B0") if f2 else hexc("FFD0FA")), rim=False)
            if f2:
                p.glow(ex, ey, 4, AMBER, 0.5)
    mh = (0.9, 1.3, 2.2, 2.8)[min(3, mouth)]
    p.trap([(hy + 3.0, hx - 0.4, hx + 4.8), (hy + 3.0 + mh * 1.4, hx - 0.2, hx + 4.6)], (VOID,) * 4, rim=False)
    for k in range(3):                                      # pale teeth, 2 px blocks
        p.cap(hx + 0.4 + k * 2.0, hy + 2.8, hx + 0.4 + k * 2.0, hy + 3.4 + mh, 0.9, 0.9, (BONE[2], BONE[2], BONE[3], BONE[3]), rim=False)
    p.ell(hx + 0.4, hy - 5.4, 1.2, 1.2, (DUSK,) * 4, rim=False)    # the dusk spark on the brow
    if f2:      # edges fraying into smoke chunks
        for k, (dx, dy, rr) in enumerate(((-13, 34, 1.9), (-16, 44, 1.5), (13, 40, 1.7), (14, 52, 1.4), (-9, 56, 1.6), (9, 24, 1.4), (-8, 22, 1.5))):
            px_, py_ = cx + dx - sway * 0.8, dy + b - (k % 3) * (1 if step else 0)
            p.ell(px_, py_, rr, rr, (shroud[0], shroud[1], shroud[2], flesh[2]), rim=False)
    # long arms
    shl, shr = (cx - 5, 28 + b), (cx + 6, 28 + b)
    el, hl = (cx + arm_l[0][0] * 0.9, arm_l[0][1] + b), (cx + arm_l[1][0] * 0.95, arm_l[1][1] + b)
    er, hr = (cx + arm_r[0][0] * 0.9, arm_r[0][1] + b), (cx + arm_r[1][0] * 0.95, arm_r[1][1] + b)
    if armfree:
        er, hr, el, hl = [(q[0], q[1] - shift * armfree) for q in (er, hr, el, hl)]
    arm(p, shl, el, hl, shroud, flesh, grab)
    if orb > 0:
        F.orb(p, hl[0], hl[1] - 7, 1.8 + orb * 3.4, (shroud[1], MAG, hexc("FFB0F8"), hexc("FFFFFF")))
    arm(p, shr, er, hr, shroud, flesh, grab)
    p.oy = oy0
    if sink > 0:            # cut at the ground, then the pool on top
        for k_ in [k_ for k_ in p.pix if k_[1] >= GROUND]:
            del p.pix[k_]
            p.soft.discard(k_)
    if pool > 0:
        rx, ry, gy = 6 + 17 * pool, 2.2 + 3.2 * pool, GROUND + 1.5 - p.oy
        p.ell(cx, gy, rx + 1.5, ry + 1.2, (FLESH[1], FLESH[1], FLESH[2], FLESH[3]), rim=False)     # a violet lip round the pool
        p.ell(cx, gy, rx, ry, POOL)
        p.ell(cx - rx * 0.25, gy - 1, rx * 0.4, ry * 0.4, (POOL[1], POOL[2], POOL[2], POOL[3]), rim=False)
        if pool > 0.5:      # a few bubbles / ripples rising
            for dx, dy, rr in ((-rx * 0.5, 0.5, 1.4), (rx * 0.45, 1.5, 1.2), (rx * 0.1, -1.5, 1.0)):
                p.ell(cx + dx, gy + dy, rr, rr, (POOL[1], FXC[2], FXC[3], hexc("FFB0F8")), rim=False)


def cell(**kw):
    return H.draw(CW, CH, sandekala, FXC, **kw)


def cell2(**kw):
    return cell(form=2, **kw)


DOWN = dict(arm_l=((-12, 40), (-14, 54)), arm_r=((12, 40), (15, 56)))
# sig1 "melt into shadow": the body sinks into a dark pool; the last frame is just the pool
SIG1 = [dict(glow=True, mouth=1, **DOWN),
        dict(crouch=3, lean=-1.0, glow=True, mouth=2, pool=0.2, **DOWN),
        dict(sink=0.3, pool=0.55, crouch=2, glow=True, mouth=0, **DOWN),
        dict(sink=0.62, pool=0.85, mouth=0, **DOWN),
        dict(sink=1.0, pool=1.0, mouth=0, **DOWN)]
SIG1_T = [0, 1, 3, 5, 7]
# sig2 "rise-and-grab": erupts out of the pool, long arms reaching forward to grab
SIG2 = [dict(sink=1.0, pool=1.0, armfree=1.0, grab=True, arm_l=((8, 56), (12, 60)), arm_r=((8, 56), (12, 60))),
        dict(sink=0.85, pool=0.9, armfree=1.0, grab=True, glow=True, mouth=2, arm_l=((10, 50), (20, 46)), arm_r=((12, 50), (22, 44))),
        dict(sink=0.35, pool=0.5, armfree=1.0, grab=True, glow=True, mouth=3, lean=1.5, arm_l=((12, 40), (26, 41)), arm_r=((14, 38), (28, 40))),
        dict(sink=0.0, pool=0.0, grab=True, glow=True, mouth=3, lean=3.0, arm_l=((13, 38), (25, 38)), arm_r=((15, 36), (27, 36))),
        dict(grab=True, glow=True, mouth=2, lean=3.5, arm_l=((13, 40), (22, 40)), arm_r=((15, 38), (24, 38))),
        dict(glow=True, mouth=1, lean=1.0, arm_l=((-6, 42), (2, 50)), arm_r=((8, 42), (14, 50)))]
SIG2_T = [0, 1, 3, 4, 5, 7]


def main():
    kw = dict(up=-100, rest_r=((12, 40), (15, 56)), rest_l=((-12, 40), (-14, 54)), planted=((13, 46), (14, 53)), walk_swing=5)
    s1, s2 = F.expand(SIG1, 8, SIG1_T, "in"), F.expand(SIG2, 8, SIG2_T, ["out", "out", "io", "io", "io"])
    base, moves = H.rows(cell, sig1=s1, sig2=s2, **kw)
    p2 = H.rows(cell2, sig1=s1, sig2=s2, **kw)
    F.finish("sandekala", CW, CH, base, moves, p2=p2)


if __name__ == "__main__":
    main()
