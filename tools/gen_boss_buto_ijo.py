#!/usr/bin/env python3
"""Buto Ijo, boss redraw (wave 4 art pass v8). 80x80 cells (was 36x44), the biggest figure in the game.

Outputs assets/art/enemies/buto_ijo.png (4x4: idle, walk, telegraph, hurt) and buto_ijo_moves.png (4x7: cast, slam, dash,
roar, rise, kneel, death), the contract of components/enemy_art.gd. Faces RIGHT, feet on the bottom row, centred.
A hunched green giant: huge hump and shoulders, a low forward head with tusks and a wild mane, a red studded loincloth,
a spiked club. tools/gen_bosses.py and gen_boss_moves.py no longer write these files. Painter and row builder come from
gen_boss_faceless_captain.py. Also writes tools/boss_buto_ijo_preview.png.
Run: python3 tools/gen_boss_buto_ijo.py
"""
import math
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_boss_faceless_captain as F
from gen_boss_faceless_captain import mat, hexc, GOLD, WOOD, REST_L, REST_R

CW, CH = 80, 80
G = 77.0   # the ground line: foot soles sit on row 78
SKIN = mat("3FA83C", "0A2A18", "1F6E2C", "92E264")
BROW = mat("1A5A2A", "081E14", "10401E", "2E8438")
HAIR = mat("3A2418", "120A0C", "261610", "6A4630")
CLOTH = mat("B02A26", "380A14", "6E1620", "E8604A")
BONE = mat("EEE2C0", "6A5A58", "B4A68C", "FFFBE8")
CLUB = mat("7A4C2A", "2A160E", "52301C", "B07C4A")
EYE_R = hexc("FF3B2A")
EYE_Y = hexc("FFE070")
ACC = hexc("8CFF5A")
T = (SKIN[3], SKIN[2], SKIN[1])


def legs(p, cx, hip, lifts, st, kneel, spread=10.5, sway=0):
    th, sh = (7.6, 6.6), (6.2, 5.4)
    if kneel:
        kx, ky = cx - 7, G - 5
        p.cap(cx - 5, hip, kx, ky, th[0], th[1] - 0.5, SKIN)
        p.cap(kx, ky, cx - 28, G - 4, sh[0] - 0.4, sh[1] - 0.6, SKIN)
        p.ell(cx - 29, G - 2.4, 5.5, 2.8, BROW)
        p.cap(cx + 6, hip, cx + 22, G - 24, th[0], th[1], SKIN)
        p.cap(cx + 22, G - 24, cx + 21, G - 4, sh[0], sh[1], SKIN)
        p.cap(cx + 20, G - 24, cx + 23, G - 22, 5.0, 4.4, BROW)   # knee wrap
        p.ell(cx + 24, G - 2.4, 7.6, 3.0, SKIN)
        p.cap(cx + 20, G - 3.4, cx + 28, G - 3.4, 1.0, 1.0, BONE, rim=False)
        return
    for i, side in enumerate((-1, 1)):
        lift = lifts[i] * 2.2
        hx_, fx = cx + side * spread * 0.8, cx + side * spread + st[i] * 1.8
        kx, ky = (hx_ + fx) / 2 + side * 1.5, (hip + G) / 2 - lift * 0.5
        p.cap(hx_, hip, kx, ky, th[0], th[1], SKIN)
        p.cap(kx, ky, fx, G - 4 - lift, sh[0], sh[1], SKIN)
        p.ell(fx + 1.6, G - 2.4 - lift, 7.4, 3.2, SKIN)
        for tx in (-3.5, 0.5, 4.5):
            p.cap(fx + 3 + tx * 0.6, G - 2.2 - lift, fx + 3 + tx * 0.6, G - 1.6 - lift, 1.0, 1.0, BONE, rim=False)   # toe nails


def buto(p, breath=0, crouch=0, lean=0.0, legs_=(0, 0), st=(0, 0), head=(0, 0), arm_l=REST_L, arm_r=REST_R, ang=-80, reach=(12, 34),
         glow=False, mouth=1, orb=0.0, tilt=False, sway=0, kneel=False, **_):
    """A hunched giant: hump behind, shoulders higher than the low head, arms hanging to the knees."""
    b = breath + crouch
    cx = CW / 2 + lean - 1
    hx, hy = cx + 5 + head[0] + lean * 0.4 + (3 if kneel else 0), 25 + b + head[1] + (3 if kneel else 0)
    sy = 38 + b
    # mane at the back, behind the hump
    p.ell(cx - 14, 30 + b, 16, 13, SKIN)
    p.cap(cx - 6, 25 + b, cx - 20 - sway, 40 + b, 5.0, 2.4, HAIR)
    legs(p, cx, 55 + crouch, legs_, st, kneel, sway=sway)
    p.trap([(53 + crouch, cx - 16, cx + 17), (60 + crouch * 0.6, cx - 19, cx + 20), (69, cx - 18 + sway * 0.5, cx + 19 + sway * 0.5)], CLOTH)
    for i in range(5):
        p.ell(cx - 12 + i * 6.2 + sway * 0.3, 64 + crouch * 0.4, 1.3, 1.3, GOLD, rim=False)
    p.trap([(52 + crouch, cx - 17, cx + 17), (55 + crouch, cx - 18, cx + 18)], GOLD)
    # barrel chest and belly
    tor = p.ell(cx + 1, 43 + b, 21, 16, SKIN)
    tor |= p.ell(cx + 3, 52 + b, 17, 9, SKIN)
    p.line([(cx + 5, 33 + b), (cx + 5, 49 + b)], SKIN[1], 2.0, tor)
    p.line([(cx - 13, 45 + b), (cx - 2, 48 + b)], SKIN[1], 2.0, tor)
    p.line([(cx + 8, 48 + b), (cx + 19, 45 + b)], SKIN[1], 2.0, tor)
    p.ell(cx + 4, 55 + b, 2.2, 2.0, (SKIN[0],) * 4, rim=False)
    # head: heavy brow, broad jaw, tusks
    p.cap(cx + 2, 36 + b, hx - 1, hy + 2, 7.5, 7.0, SKIN)
    p.ell(hx - 6, hy - 9, 13, 9, HAIR)
    for k, (dx, dy, ex, ey) in enumerate(((-4, -14, -9, -23), (3, -15, 1, -25), (9, -12, 11, -22), (-9, -11, -19, -19))):
        p.cap(hx + dx, hy + dy, hx + ex - sway * 0.5, hy + ey, 3.6, 1.0, HAIR)
    jy = hy + 4.2 + mouth * 0.7
    p.ell(hx + 1.5, jy, 9.6, 6.0, SKIN)
    p.ell(hx, hy - 0.5, 10.4, 8.6, SKIN)
    p.ell(hx - 9.5, hy + 0.5, 2.6, 4.0, SKIN)                                        # ear
    p.cap(hx - 9.8, hy + 3.5, hx - 9.8, hy + 5.5, 1.1, 1.1, GOLD, rim=False)
    p.trap([(hy - 9, hx - 7, hx + 8), (hy - 4.0, hx - 8.6, hx + 9.5)], HAIR)          # fringe
    mh = 1.5 + mouth * 1.4
    p.trap([(jy - 2.4, hx - 4.5, hx + 8.5), (jy - 2.4 + mh, hx - 3.4, hx + 7.4)], (BROW[1], hexc("2A0810"), hexc("4A1018"), hexc("6A1A20")))
    for tx in (-1.6, 3.2):
        p.cap(hx + tx, jy - 2.0, hx + tx, jy - 0.6, 1.1, 1.1, BONE, rim=False)       # upper teeth
    p.cap(hx - 6.0, jy + 3.0, hx - 8.6, jy - 6.0, 1.9, 0.7, BONE)                    # tusks
    p.cap(hx + 9.0, jy + 3.0, hx + 11.4, jy - 6.0, 1.9, 0.7, BONE)
    ec = EYE_Y if glow else EYE_R
    for ex in (hx - 2.4, hx + 6.4):
        if tilt:
            p.line([(ex - 2, hy - 0.4), (ex + 2, hy - 0.4)], BROW[1], 2.0)
        else:
            p.ell(ex, hy - 0.2, 2.1, 1.6, (BROW[1], ec, ec, hexc("FFF8D0")), rim=False)
            p.dot(ex + 0.8, hy - 0.4, hexc("1A0808"))
    if not tilt:
        p.line([(hx - 6, hy - 3.4), (hx + 0.6, hy - 1.6)], BROW[1], 3.0)
        p.line([(hx + 10, hy - 3.2), (hx + 3.6, hy - 1.6)], BROW[1], 3.0)
    p.ell(hx + 2.8, hy + 2.6, 2.8, 2.2, SKIN)
    p.dot(hx + 3.8, hy + 3.2, BROW[1])
    # arms (far arm first), club between them
    shl, shr = (cx - 22, sy), (cx + 23, sy)
    el, hl = F.M(cx, b, sy - 1, 1.5, arm_l[0], 1.25), F.M(cx, b, sy - 1, 1.5, arm_l[1], 1.25)
    er, hr = F.M(cx, b, sy - 1, 1.5, arm_r[0], 1.25), F.M(cx, b, sy - 1, 1.5, arm_r[1], 1.25)
    F.limb_arm(p, shl, el, hl, SKIN, SKIN, 6.2, 1.9)
    p.cap(el[0] + (hl[0] - el[0]) * 0.55, el[1] + (hl[1] - el[1]) * 0.55, el[0] + (hl[0] - el[0]) * 0.95, el[1] + (hl[1] - el[1]) * 0.95, 5.6, 5.2, BROW)
    p.ell(shl[0], shl[1], 9.5, 8.0, SKIN)
    if orb > 0:
        F.orb(p, hl[0], hl[1] - 9, 2.4 + orb * 4.6, (BROW[1], ACC, hexc("C8FF9A"), hexc("F4FFE0")))
    F.limb_arm(p, shr, er, hr, SKIN, SKIN, 6.4, 2.0)
    p.cap(er[0] + (hr[0] - er[0]) * 0.55, er[1] + (hr[1] - er[1]) * 0.55, er[0] + (hr[0] - er[0]) * 0.95, er[1] + (hr[1] - er[1]) * 0.95, 5.8, 5.4, BROW)
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    bx, by = hr[0] - ca * reach[0], hr[1] - sa * reach[0]
    tx, ty = hr[0] + ca * reach[1] * 0.8, hr[1] + sa * reach[1] * 0.8
    p.cap(bx, by, tx, ty, 3.6, 6.2, CLUB)
    for t in (0.55, 0.72, 0.9):
        qx, qy = bx + (tx - bx) * t, by + (ty - by) * t
        for s in (-1, 1):
            p.cap(qx - sa * 5.4 * s, qy + ca * 5.4 * s, qx - sa * 8.4 * s, qy + ca * 8.4 * s, 1.5, 0.9, BONE)
    p.ell(shr[0], shr[1], 9.5, 8.0, SKIN)


def cell(**kw):
    kw["legs_"] = kw.pop("legs", (0, 0))
    rings = kw.pop("rings", 0)
    streak = kw.pop("streak", False)
    return F.draw_cell(CW, CH, buto, extra=F.streaks(T) if streak else None, rings=rings, ring_tones=T, **kw)


def main():
    base, moves = F.build_rows(cell, ang_up=-95, strike=(35, 50), kang=-84, kreach=(4, 26))
    F.finish("buto_ijo", CW, CH, base, moves)


if __name__ == "__main__":
    main()
