#!/usr/bin/env python3
"""Sangkuriang, boss redraw (wave 4 art pass v8). 64x64 cells (was 30x36).

Outputs assets/art/enemies/sangkuriang.png (4x4: idle, walk, telegraph, hurt) and sangkuriang_moves.png (4x7: cast,
slam, dash, roar, rise, kneel, death), the contract of components/enemy_art.gd. Faces RIGHT, feet on the bottom row.
A bare-chested giant in a brown sarong, an orange iket, the small perahu on his back, a heavy log for a club.
tools/gen_bosses.py and gen_boss_moves.py no longer write these files. Painter and row builder come from
gen_boss_faceless_captain.py. Also writes tools/boss_sangkuriang_preview.png.
Run: python3 tools/gen_boss_sangkuriang.py
"""
import math
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_boss_faceless_captain as F
from gen_boss_faceless_captain import mat, hexc, WOOD, GOLD, REST_L, REST_R

CW, CH = 64, 64
SKIN = mat("A8693A", "3A1C14", "6C3C22", "D89A62")
SAR = mat("6B3A1E", "241008", "4A2610", "94562E")
IKET = mat("FF7A1F", "5A2208", "B8460E", "FFB060")
HAIR = mat("2A1E26", "0C080E", "1A1218", "50404A")
HULL = mat("7A2E24", "2A0C0C", "4E1A16", "D0684A")
ACC = hexc("FF7A1F")
LOG = mat("8A5C34", "2E1C16", "5E3C22", "BC8A58")


def wrap(p, e, h):
    """A leather bracer on the forearm."""
    p.cap(e[0] + (h[0] - e[0]) * 0.35, e[1] + (h[1] - e[1]) * 0.35, e[0] + (h[0] - e[0]) * 0.85, e[1] + (h[1] - e[1]) * 0.85, 4.0, 3.6, SAR)


def sangku(p, breath=0, crouch=0, lean=0.0, legs=(0, 0), st=(0, 0), head=(0, 0), arm_l=REST_L, arm_r=REST_R, ang=-80, reach=(12, 34),
           glow=False, mouth=1, orb=0.0, tilt=False, sway=0, kneel=False):
    """A broad, muscular young giant: wide stance, heavy shoulders, big head."""
    b = breath + crouch
    cx = CW / 2 + lean
    hx, hy = cx + 1 + head[0] + lean * 0.4, 16 + b + head[1]
    sy = 28 + b
    # the perahu on his back
    p.poly([(cx - 22, 20 + b), (cx - 15, 24 + b), (cx - 8, 34 + b), (cx - 10, 47 + b), (cx - 17, 41 + b), (cx - 23, 30 + b)], HULL[2])
    p.line([(cx - 22, 21 + b), (cx - 15, 25 + b), (cx - 9, 35 + b)], HULL[3], 2.0)
    p.line([(cx - 22, 31 + b), (cx - 17, 41 + b), (cx - 11, 47 + b)], HULL[1], 2.0)
    p.cap(cx - 19, 24 + b, cx - 14, 40 + b, 1.0, 1.0, HULL[0], rim=False)
    F.legs_draw(p, cx, 45 + crouch, legs, SAR, SKIN, SKIN, wid=5.6, spread=8.6, tw=(5.8, 5.0, 4.6, 3.6), st=st, kneel=kneel)
    p.trap([(43 + crouch, cx - 11, cx + 11), (52, cx - 13 + sway * 0.4, cx + 13 + sway * 0.4), (58, cx - 13.5 + sway, cx + 13.5 + sway)], SAR)
    for i in range(6):
        p.line([(cx - 10 + i * 4, 48), (cx - 11 + i * 4.2 + sway * 0.4, 56)], SAR[1], 1.0)
    tor = p.trap([(24 + b, cx - 8, cx + 8), (28 + b, cx - 14, cx + 14), (36 + b, cx - 13, cx + 13), (46 + b, cx - 9.5, cx + 9.5)], SKIN)
    p.line([(cx - 11, 34 + b), (cx - 1, 37 + b)], SKIN[1], 1.0, tor)
    p.line([(cx + 1, 37 + b), (cx + 11, 34 + b)], SKIN[1], 1.0, tor)
    for i in (-1, 1):
        p.line([(cx + i * 3, 40 + b), (cx + i * 4, 44 + b)], SKIN[1], 1.0, tor)
    p.line([(cx, 38 + b), (cx, 45 + b)], SKIN[1], 1.0, tor)
    p.trap([(43 + b, cx - 10, cx + 10), (47 + b, cx - 10, cx + 10)], IKET)
    p.ell(cx, 45 + b, 2.4, 2.4, GOLD)
    # head: a square jaw, heavy brows
    p.cap(hx - 1, hy + 3, cx, 28 + b, 4.0, 4.6, SKIN)
    p.cap(hx - 3, hy - 4, hx - 13 - sway, hy + 8, 3.6, 2.2, HAIR)
    p.ell(hx, hy - 0.8, 7.0, 6.8, SKIN)
    p.trap([(hy + 1.4, hx - 6.6, hx + 6.6), (hy + 6.4, hx - 4.8, hx + 4.8)], SKIN)
    p.trap([(hy - 7.6, hx - 6.8, hx + 6.8), (hy - 3, hx - 7.4, hx + 7.4)], HAIR)
    p.trap([(hy - 4.8, hx - 7.2, hx + 7.2), (hy - 2.2, hx - 7.4, hx + 7.4)], IKET)
    ec = hexc("FFD070") if glow else hexc("F4E8D0")
    for side in (-1, 1):
        ex, ey = hx + side * 3.0 + 1, hy + 0.8
        p.line([(ex - side * 3, ey - 3.0), (ex + side * 2.2, ey - 1.4)], HAIR[1], 2.0)
        if tilt:
            p.line([(ex - 1.5, ey + 0.4), (ex + 1.5, ey + 0.4)], HAIR[1], 1.0)
        else:
            p.ell(ex, ey, 1.7, 1.3, (HAIR[1], ec, ec, ec), rim=False)
            p.dot(ex + 0.6, ey, hexc("1A0C08"))
    p.line([(hx + 0.6, hy + 2), (hx + 1.4, hy + 3.6)], SKIN[1], 1.0)
    mh = 0.6 + mouth * 0.7
    p.trap([(hy + 5, hx - 2.6 + 1, hx + 2.6 + 1), (hy + 5 + mh * 2, hx - 2 + 1, hx + 2 + 1)], (SKIN[0], hexc("2A0C10"), hexc("4A1418"), hexc("4A1418")))
    shl, shr = (cx - 14.5, sy), (cx + 14.5, sy)
    el, hl = F.M(cx, b, sy - 1, 1.1, arm_l[0]), F.M(cx, b, sy - 1, 1.1, arm_l[1])
    er, hr = F.M(cx, b, sy - 1, 1.1, arm_r[0]), F.M(cx, b, sy - 1, 1.1, arm_r[1])
    F.limb_arm(p, shl, el, hl, SKIN, SKIN, 3.8, 1.3)
    wrap(p, el, hl)
    p.ell(shl[0], shl[1], 6.0, 5.2, SKIN)
    p.cap(hl[0] - 3, hl[1] - 1, hl[0] + 3, hl[1] - 1, 1.2, 1.2, GOLD)
    if orb > 0:
        F.orb(p, hl[0], hl[1] - 7, 1.6 + orb * 3.4, (SAR[1], ACC, hexc("FFB060"), hexc("FFF0C0")))
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    bx, by = hr[0] - ca * reach[0], hr[1] - sa * reach[0]
    tx, ty = hr[0] + ca * reach[1] * 0.75, hr[1] + sa * reach[1] * 0.75
    p.cap(bx, by, tx, ty, 4.0, 4.6, LOG)
    p.ell(tx, ty, 4.0, 4.4, LOG)
    for t in (0.35, 0.7):
        p.cap(bx + (tx - bx) * t - sa * 3.5, by + (ty - by) * t + ca * 3.5, bx + (tx - bx) * t + sa * 3.5, by + (ty - by) * t - ca * 3.5, 0.9, 0.9, (LOG[1],) * 4, rim=False)
    F.limb_arm(p, shr, er, hr, SKIN, SKIN, 4.0, 1.3)
    wrap(p, er, hr)
    p.ell(shr[0], shr[1], 6.0, 5.2, SKIN)


T = (IKET[3], IKET[2], IKET[1])


def cell(**kw):
    rings = kw.pop("rings", 0)
    streak = kw.pop("streak", False)
    return F.draw_cell(CW, CH, sangku, extra=F.streaks(T) if streak else None, rings=rings, ring_tones=T, **kw)


def main():
    base, moves = F.build_rows(cell, ang_up=-95, strike=(35, 50), kang=-84, kreach=(4, 26))
    F.finish("sangkuriang", CW, CH, base, moves)


if __name__ == "__main__":
    main()
