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


def claws(p, hx, hy, dx, dy, n=3, ln=5.5):
    """n lavender claws fanned along the forearm direction (dx, dy)."""
    a0 = math.atan2(dy, dx)
    for i in range(n):
        a = a0 + (i - (n - 1) / 2) * 0.55
        p.cap(hx, hy, hx + math.cos(a) * ln, hy + math.sin(a) * ln, 1.5, 0.8, BONE)


def arm(p, sh, el, ha):
    p.cap(el[0], el[1], ha[0], ha[1], 2.9, 2.2, FLESH)
    p.cap(sh[0], sh[1], el[0], el[1], 3.6, 3.0, SHROUD)
    p.ell(ha[0], ha[1], 3.0, 2.8, FLESH)
    claws(p, ha[0], ha[1], ha[0] - el[0], ha[1] - el[1])


def sandekala(p, breath=0, crouch=0, lean=0.0, step=0, lift=(0, 0), head=(0, 0), arm_l=H.REST_L, arm_r=H.REST_R, ang=0,
              reach=(0, 0), glow=False, mouth=1, orb=0.0, tilt=False, kneel=False, sway=0):
    b = breath + crouch
    cx = CW / 2 + lean
    hx, hy = cx + 4 + head[0] + lean * 0.4, 15 + b + head[1] + (2 if kneel else 0)
    # trailing wisps behind the shoulders
    p.cap(cx - 5, 27 + b, cx - 13 - sway * 2, 46 + b, 3.4, 1.0, SHROUD)
    p.cap(cx - 3, 30 + b, cx - 10 - sway * 2, 54, 2.8, 0.8, FLESH)
    # shroud: narrow shoulders, a long ragged skirt
    hem = 60 if not kneel else 61
    p.trap([(24 + b, cx - 4.5, cx + 6.5), (30 + b, cx - 8, cx + 8.5), (44 + crouch, cx - 11 + sway * 0.5, cx + 10), (hem - 5, cx - 12 + sway, cx + 12 + sway * 0.5)], SHROUD)
    # ragged tatters: they stride (step) and lift in the walk row
    for i in range(6):
        x = cx - 11 + i * 4.4 + sway * 0.5
        ph = (i + (step + 1)) % 2
        up_ = lift[ph] + (1 if i % 3 == 0 else 0) * 2
        tx = x + (step * 2.4 if i % 2 else -step * 2.4) + (3 if kneel else 0) * (i - 2.5) / 2.5
        ty = hem - up_ - (0 if kneel else (i % 3))
        p.cap(x, hem - 8, tx, ty, 2.6, 1.3, SHROUD if i % 2 else FLESH)
        p.ell(tx, ty, 1.5, 1.2, (SHROUD[0], MAG, MAG, hexc("FFB0F8")), rim=False)
    # ribs and a dim heart
    tor = p.trap([(28 + b, cx - 6, cx + 7), (40 + b, cx - 8, cx + 8.5)], FLESH, rim=False)
    for k in range(3):
        p.line([(cx - 6, 31 + b + k * 3.4), (cx + 5, 32 + b + k * 3.4)], SHROUD[1], 2.0, tor)
    c = (MAG, MAG, MAG, hexc("FFB0F8")) if glow else (SHROUD[1], SHROUD[1], SHROUD[2], SHROUD[2])
    p.ell(cx + 1, 38 + b, 2.2, 2.2, c, rim=False)
    # head: a long pale-violet skull, the face a void
    p.cap(hx - 2, hy + 3, cx + 1, 27 + b, 3.2, 3.8, FLESH)
    # two long horns: one swept far back, one rising forward, each with a bone tip
    for bx, tx, ty, col, tipx, tipy in ((hx - 4, hx - 12 - sway * 2, hy - 12, SHROUD, hx - 16 - sway * 3, hy - 19),
                                         (hx + 2, hx + 5, hy - 14, FLESH, hx + 8, hy - 19)):
        p.cap(bx, hy - 4, tx, ty, 2.8, 1.6, col)
        p.cap(tx, ty, tipx, tipy, 1.6, 0.9, BONE)
    p.ell(hx, hy, 6.6, 7.4, FLESH)
    fv = p.ell(hx + 1.6, hy + 0.8, 4.8, 5.6, (VOID, VOID, VOID, VOID), rim=False)
    for s in (-1, 1):
        ex, ey = hx + 1.6 + s * 2.2, hy - 0.8
        if tilt:
            p.cap(ex - 1.2, ey, ex + 1.2, ey + 0.8, 0.7, 0.7, (FLESH[2],) * 4, rim=False)
        else:
            p.cap(ex - 0.8, ey, ex + 0.8, ey, 1.0, 1.0, (MAG, MAG, MAG, hexc("FFD0FA")) if glow or True else (MAG,) * 4, rim=False)
    mh = (0.9, 1.3, 2.2, 2.8)[min(3, mouth)]
    p.trap([(hy + 3.0, hx - 0.4, hx + 4.8), (hy + 3.0 + mh * 1.4, hx - 0.2, hx + 4.6)], (VOID,) * 4, rim=False)
    for k in range(3):                                      # pale teeth, 2 px blocks
        p.cap(hx + 0.4 + k * 2.0, hy + 2.8, hx + 0.4 + k * 2.0, hy + 3.4 + mh, 0.9, 0.9, (BONE[2], BONE[2], BONE[3], BONE[3]), rim=False)
    p.ell(hx + 0.4, hy - 5.4, 1.2, 1.2, (DUSK,) * 4, rim=False)    # the dusk spark on the brow
    # long arms
    shl, shr = (cx - 5, 28 + b), (cx + 6, 28 + b)
    el, hl = (cx + arm_l[0][0] * 0.9, arm_l[0][1] + b), (cx + arm_l[1][0] * 0.95, arm_l[1][1] + b)
    er, hr = (cx + arm_r[0][0] * 0.9, arm_r[0][1] + b), (cx + arm_r[1][0] * 0.95, arm_r[1][1] + b)
    arm(p, shl, el, hl)
    if orb > 0:
        F.orb(p, hl[0], hl[1] - 7, 1.8 + orb * 3.4, (SHROUD[1], MAG, hexc("FFB0F8"), hexc("FFFFFF")))
    arm(p, shr, er, hr)


def cell(**kw):
    return H.draw(CW, CH, sandekala, FXC, **kw)


def main():
    base, moves = H.rows(cell, up=-100, rest_r=((12, 40), (15, 56)), rest_l=((-12, 40), (-14, 54)), planted=((13, 46), (14, 53)),
                         walk_swing=5)
    F.finish("sandekala", CW, CH, base, moves)


if __name__ == "__main__":
    main()
