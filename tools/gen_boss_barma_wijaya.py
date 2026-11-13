#!/usr/bin/env python3
"""Prabu Barma Wijaya (the False King), boss redraw (wave 4 art pass v8). 56x64 cells (was 26x40).

Outputs assets/art/enemies/barma_wijaya.png (4x4: idle, walk, telegraph, hurt) and barma_wijaya_moves.png (4x7: cast,
slam, dash, roar, rise, kneel, death), the contract of components/enemy_art.gd. Faces RIGHT, feet on the bottom row.
A king in a magenta robe with a gold hem, a gold crown with a cyan gem, a thin moustache, and a wavy kris; cyan glamour
light. tools/gen_bosses.py and gen_boss_moves.py no longer write these files. Painter and row builder come from
gen_boss_faceless_captain.py. Also writes tools/boss_barma_wijaya_preview.png.
Run: python3 tools/gen_boss_barma_wijaya.py
"""
import math
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_boss_faceless_captain as F
from gen_boss_faceless_captain import mat, hexc, GOLD, STEEL, WOOD, REST_L, REST_R

CW, CH = 56, 64
ROBE = mat("A02FA8", "2E0A34", "6C1A74", "D878E0")
SKIN = mat("D9A98A", "5E3228", "A8705A", "F6D0B2")
HAIR = mat("2A1E26", "0C080E", "1A1218", "50404A")
CY = mat("5DF2FF", "103848", "2E9AB0", "E0FFFF")
ACC = hexc("5DF2FF")


def barma(p, breath=0, crouch=0, lean=0.0, legs=(0, 0), st=(0, 0), head=(0, 0), arm_l=REST_L, arm_r=REST_R, ang=-80, reach=(6, 20),
          glow=False, mouth=1, orb=0.0, tilt=False, sway=0, kneel=False):
    b = breath + crouch
    cx = CW / 2 + lean
    hx, hy = cx + 1 + head[0] + lean * 0.4, 16 + b + head[1]
    # regal robe: narrow shoulders flaring to a wide hem; only the slippers show
    if kneel:
        p.ell(cx - 17, 60.5, 4.2, 2.4, GOLD)
    else:
        for i, side in enumerate((-1, 1)):
            p.ell(cx + side * 8 + st[i], 60.0 - legs[i], 4.6, 2.7, GOLD)
    rb = p.trap([(26 + b, cx - 6.5, cx + 6.5), (34 + b, cx - 8, cx + 8), (44 + crouch, cx - 11 + sway * 0.4, cx + 11 + sway * 0.4),
                 (54, cx - 17 + sway + st[0] * 0.3, cx + 17 + sway + st[1] * 0.3), (58, cx - 19 + sway, cx + 19 + sway)], ROBE)
    for i in range(-3, 4):
        p.line([(cx + i * 3.2, 46 + crouch), (cx + i * 5.6 + sway, 57)], ROBE[1], 1.0, rb)
    p.trap([(53.5, cx - 17 + sway, cx + 17 + sway), (58, cx - 19 + sway, cx + 19 + sway)], GOLD)
    for i in range(-8, 9, 3):
        p.dot(cx + i * 2.2 + sway, 55.8, CY[1], rb)
    if kneel:
        p.ell(cx + 12, 54, 6.5, 5.5, ROBE)
        p.ell(cx + 14, 60.2, 4.4, 2.4, GOLD)
    # chest panel and sash
    p.poly([(cx - 3.4, 26 + b), (cx + 3.4, 26 + b), (cx + 4.4, 44 + crouch + breath), (cx, 48 + crouch + breath), (cx - 5, 44 + crouch + breath)], GOLD[2])
    p.line([(cx - 4, 26 + b), (cx - 5, 44 + b), (cx, 48 + b)], GOLD[3], 1.0)
    p.line([(cx + 4, 26 + b), (cx + 5, 44 + b), (cx, 48 + b)], GOLD[0], 1.0)
    p.ell(cx, 34 + b, 1.8, 1.8, CY)
    p.trap([(42 + b, cx - 9.4, cx + 9.4), (45 + b, cx - 9.8, cx + 9.8)], GOLD)
    # head
    p.cap(hx - 1, hy + 3, cx, 27 + b, 3.0, 3.6, SKIN)
    p.cap(hx - 4, hy - 3, hx - 9 - sway, hy + 7, 2.6, 1.8, HAIR)
    p.ell(hx, hy, 5.8, 6.6, SKIN)
    p.trap([(hy - 6.4, hx - 5.6, hx + 5.6), (hy - 3.4, hx - 6, hx + 6)], HAIR)
    ec = ACC if glow else hexc("120C10")
    for side in (-1, 1):
        ex, ey = hx + side * 2.6 + 1, hy + 0.2
        p.line([(ex - 2.4 * (-side), ey - 1.4 - (1 if side < 0 else 0)), (ex + 2.4 * (-side) * -1 * 0 + 2, ey - 2.4)], HAIR[1], 2.0)
        if tilt:
            p.line([(ex - 1, ey + 0.4), (ex + 1, ey + 0.4)], HAIR[1], 1.0)
        else:
            p.cap(ex - 0.5, ey + 0.4, ex + 0.5, ey + 0.4, 0.9, 0.9, (ec,) * 4, rim=False)
    p.line([(hx - 3, hy + 3.2), (hx + 5, hy + 3.2)], HAIR[1], 1.0)               # moustache
    if mouth > 1:
        p.cap(hx - 0.5, hy + 4.8, hx + 2.5, hy + 4.8, 1.0, 1.0, (SKIN[0],) * 4, rim=False)
    # crown
    p.trap([(hy - 9.4, hx - 5.2, hx + 5.2), (hy - 6, hx - 6.2, hx + 6.2)], GOLD)
    for dx, h in ((-4.4, 4), (0, 6.5), (4.4, 4)):
        p.poly([(hx + dx - 2, hy - 9.4), (hx + dx, hy - 9.4 - h), (hx + dx + 2, hy - 9.4)], GOLD[2])
        p.line([(hx + dx - 2, hy - 9.4), (hx + dx, hy - 9.4 - h)], GOLD[3], 1.0)
    p.ell(hx, hy - 7.4, 1.4, 1.4, CY)
    # arms in wide sleeves
    shl, shr = (cx - 8.5, 27 + b), (cx + 8.5, 27 + b)
    el, hl = F.M(cx, b, 27, 0.9, arm_l[0]), F.M(cx, b, 27, 0.9, arm_l[1])
    er, hr = F.M(cx, b, 27, 0.9, arm_r[0]), F.M(cx, b, 27, 0.9, arm_r[1])
    F.limb_arm(p, shl, el, hl, ROBE, SKIN, 3.0)
    p.cap(shl[0] * 0.3 + el[0] * 0.7, shl[1] * 0.3 + el[1] * 0.7 + 1, hl[0] * 0.8 + el[0] * 0.2, hl[1] * 0.8 + el[1] * 0.2, 4.8, 4.0, ROBE)
    p.cap(el[0] + (hl[0] - el[0]) * 0.55, el[1] + (hl[1] - el[1]) * 0.55, hl[0] * 0.85 + el[0] * 0.15, hl[1] * 0.85 + el[1] * 0.15, 3.5, 3.5, GOLD)
    p.ell(shl[0], shl[1], 4.8, 4.0, ROBE)
    if orb > 0:
        F.orb(p, hl[0], hl[1] - 7, 1.6 + orb * 3.4, (CY[1], CY[2], CY[0], hexc("FFFFFF")))
    # the kris: a wavy blade
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    nx, ny = -sa, ca
    gx, gy = hr[0] + ca * 3, hr[1] + sa * 3
    L = reach[1]
    left, right = [], []
    for i in range(9):
        t = i / 8.0
        w = 2.8 * (1 - t) + 0.5
        wob = math.sin(t * math.pi * 3) * 1.4
        cxx, cyy = gx + ca * L * t + nx * wob, gy + sa * L * t + ny * wob
        left.append((cxx + nx * w, cyy + ny * w))
        right.append((cxx - nx * w, cyy - ny * w))
    p.poly(left + right[::-1], STEEL[2])
    p.line(left, STEEL[3], 1.0)
    p.line(right, STEEL[1], 1.0)
    p.line([(gx + ca * 4, gy + sa * 4), (gx + ca * L * 0.7, gy + sa * L * 0.7)], CY[2] if glow else STEEL[1], 1.0)
    p.cap(gx - nx * 3.5, gy - ny * 3.5, gx + nx * 3.5, gy + ny * 3.5, 1.4, 1.4, GOLD)
    p.cap(hr[0] - ca * reach[0], hr[1] - sa * reach[0], gx, gy, 1.7, 1.7, WOOD)
    F.limb_arm(p, shr, er, hr, ROBE, SKIN, 3.0)
    p.cap(shr[0] * 0.3 + er[0] * 0.7, shr[1] * 0.3 + er[1] * 0.7 + 1, hr[0] * 0.8 + er[0] * 0.2, hr[1] * 0.8 + er[1] * 0.2, 4.8, 4.0, ROBE)
    p.cap(er[0] + (hr[0] - er[0]) * 0.55, er[1] + (hr[1] - er[1]) * 0.55, hr[0] * 0.85 + er[0] * 0.15, hr[1] * 0.85 + er[1] * 0.15, 3.5, 3.5, GOLD)
    p.ell(shr[0], shr[1], 4.8, 4.0, ROBE)


T = (CY[3], CY[2], CY[1])


def cell(**kw):
    rings = kw.pop("rings", 0)
    streak = kw.pop("streak", False)
    return F.draw_cell(CW, CH, barma, extra=F.streaks(T) if streak else None, rings=rings, ring_tones=T, **kw)


def main():
    base, moves = F.build_rows(cell, ang_up=-100, strike=(25, 40), kang=88, kreach=(4, 12), karm=((12, 34), (13, 38)))
    F.finish("barma_wijaya", CW, CH, base, moves)


if __name__ == "__main__":
    main()
