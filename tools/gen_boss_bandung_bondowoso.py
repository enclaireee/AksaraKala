#!/usr/bin/env python3
"""Bandung Bondowoso, boss redraw (wave 4 art pass v8). 64x72 cells (was 32x38).

Outputs assets/art/enemies/bandung_bondowoso.png (4x4: idle, walk, telegraph, hurt) and bandung_bondowoso_moves.png
(4x7: cast, slam, dash, roar, rise, kneel, death), the contract of components/enemy_art.gd. Faces RIGHT, feet on the bottom row.
A broad, thick-limbed builder-knight in stone-brown with a tiered golden crown, a gold belt set with red gems, orange eyes
and a carved stone pillar for a weapon. tools/gen_bosses.py and gen_boss_moves.py no longer write these files.
Painter comes from gen_boss_faceless_captain.py, the pose table and FX from gen_boss_hariang_banga.py.
Also writes tools/boss_bandung_bondowoso_preview.png.
Run: python3 tools/gen_boss_bandung_bondowoso.py
"""
import math
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_boss_faceless_captain as F
import gen_boss_hariang_banga as H
from gen_boss_faceless_captain import mat, hexc, GOLD

CW, CH = 64, 72
HIDE = mat("8A6A4C", "241810", "5E4630", "C8A27A")
CLOTH = mat("6A4A34", "1E1208", "46301E", "A47C54")
DARK = mat("4A3826", "140C06", "2E2016", "7A5E44")
STONE = mat("A89478", "2E2418", "7E6C54", "E0D0AE")
HAIR = mat("2A1E1A", "0C0806", "1A120E", "50403A")
ACC = hexc("FFB02E")
RUBY = mat("C0261C", "3E0A0A", "8E1A14", "FF7A60")
FXC = mat("C8A878", "4A3826", "9A7E58", "F0E0B8")


def limb(p, sh, el, ha, sleeve, k=1.0):
    """A thick arm: forearm under a gold-edged bracer, upper arm over it, a big fist."""
    p.cap(el[0], el[1], ha[0], ha[1], 4.4 * k, 3.9 * k, HIDE)
    mx, my = el[0] + (ha[0] - el[0]) * 0.55, el[1] + (ha[1] - el[1]) * 0.55
    p.cap(el[0] + (ha[0] - el[0]) * 0.3, el[1] + (ha[1] - el[1]) * 0.3, mx, my, 4.6 * k, 4.4 * k, DARK)
    p.cap(sh[0], sh[1], el[0], el[1], 5.2 * k, 4.4 * k, HIDE)
    p.ell(ha[0], ha[1] + 0.8, 4.0 * k, 3.8 * k, HIDE)


def pillar(p, hx, hy, ang, back, fwd):
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    bx, by = hx - ca * back, hy - sa * back
    tx, ty = hx + ca * fwd, hy + sa * fwd
    p.cap(bx, by, tx, ty, 4.8, 5.2, STONE)
    for t in (0.3, 0.62):      # carved gold bands
        cxp, cyp = bx + (tx - bx) * t, by + (ty - by) * t
        p.cap(cxp - sa * 4.6, cyp + ca * 4.6, cxp + sa * 4.6, cyp - ca * 4.6, 1.3, 1.2, GOLD)
    p.ell(tx, ty, 6.0, 5.6, STONE)                    # the chiselled capital
    p.cap(tx - sa * 5, ty + ca * 5, tx + sa * 5, ty - ca * 5, 1.1, 1.1, (STONE[1], STONE[1], STONE[1], STONE[2]), rim=False)


def bandung(p, breath=0, crouch=0, lean=0.0, step=0, lift=(0, 0), head=(0, 0), arm_l=H.REST_L, arm_r=H.REST_R, ang=-70,
            reach=(8, 26), glow=False, mouth=1, orb=0.0, tilt=False, kneel=False, sway=0):
    b = breath + crouch
    cx = CW / 2 + lean
    hx, hy = cx + 1.5 + head[0] + lean * 0.4, 16 + b + head[1]
    # back cloth
    p.trap([(30 + b, cx - 9, cx + 8), (46 + crouch, cx - 12 - sway, cx + 9 - sway), (58, cx - 14 - sway * 2, cx + 10 - sway * 2)], DARK)
    H.legs2(p, cx, 60, 45 + crouch, step, lift, kneel, spread=5.5, stride=4, thigh=CLOTH, shin=HIDE, boot=DARK, th=5.0, sh=4.0, wid=5.6, bend=1.5)
    # kain skirt with gold fringe
    p.trap([(43 + crouch, cx - 10, cx + 10), (54, cx - 13 + sway * 0.4, cx + 13 + sway * 0.4)], CLOTH)
    p.trap([(51, cx - 12.6, cx + 12.6), (54, cx - 13 + sway * 0.4, cx + 13 + sway * 0.4)], GOLD, rim=False)
    for i in range(4):
        p.cap(cx - 8 + i * 5.3, 47 + crouch, cx - 8.4 + i * 5.3 + sway * 0.4, 52, 0.9, 0.9, (CLOTH[1],) * 4, rim=False)
    # torso: a barrel chest
    tor = p.trap([(24 + b, cx - 8, cx + 8), (28 + b, cx - 14, cx + 14), (38 + b, cx - 13, cx + 13), (47 + b, cx - 10.5, cx + 10.5)], HIDE)
    p.line([(cx - 9, 33 + b), (cx - 1, 36 + b)], HIDE[1], 2.0, tor)
    p.line([(cx + 1, 36 + b), (cx + 9, 33 + b)], HIDE[1], 2.0, tor)
    p.line([(cx, 38 + b), (cx, 44 + b)], HIDE[1], 2.0, tor)
    p.line([(cx - 11, 29 + b), (cx - 6, 36 + b), (cx - 8, 42 + b)], HIDE[1], 1.0, tor)     # cracks: he is half stone
    p.trap([(43 + b, cx - 10.8, cx + 10.8), (47 + b, cx - 10.8, cx + 10.8)], GOLD)
    for dx in (-7, 7):
        p.ell(cx + dx, 45 + b, 1.5, 1.5, RUBY, rim=False)
    p.ell(cx + 1, 45 + b, 2.4, 2.8, GOLD)
    p.ell(cx + 1, 33 + b, 2.0, 2.0, (ACC, ACC, ACC, hexc("FFF0C0")) if glow else mat("8E5A14"), rim=False)
    # head: heavy brow, beard, tiered crown
    p.cap(hx - 1, hy + 3, cx, 26 + b, 4.2, 4.6, HIDE)
    p.ell(hx, hy + 0.5, 7.6, 7.2, mat("A8825C", "241810", "7E5E42", "DDB888"))
    p.trap([(hy + 5.2, hx - 1, hx + 5.5), (hy + 8.5, hx + 0.5, hx + 4.5), (hy + 10.5, hx + 1.5, hx + 3.5)], HAIR)    # goatee
    p.cap(hx + 1, hy + 3.2, hx + 5, hy + 3.2, 0.9, 0.9, (HAIR[2],) * 4, rim=False)
    if mouth > 1:
        p.cap(hx + 1.2, hy + 4.2, hx + 4.8, hy + 4.2, 1.0, 1.0, (hexc("2A0C10"),) * 4, rim=False)
    for s in (-1, 1):
        ex, ey = hx + s * 3.2 + 1.5, hy - 0.2
        dy = 1.4 if not tilt else -0.2
        p.cap(ex - 2.4, ey - 2.6 - s * dy * 0.4, ex + 2.4, ey - 2.6 + s * dy * 0.4, 1.1, 1.1, (HAIR[1],) * 4, rim=False)
        if tilt:
            p.cap(ex - 1.2, ey + 0.6, ex + 1.2, ey + 0.6, 0.6, 0.6, (HAIR[1],) * 4, rim=False)
        else:
            ec = ACC if glow else hexc("E88A1C")
            p.cap(ex - 0.8, ey + 0.4, ex + 0.8, ey + 0.4, 1.0, 1.0, (ec, ec, ec, hexc("FFF0C0")), rim=False)
    p.trap([(hy - 7.4, hx - 6.8, hx + 6.8), (hy - 4.6, hx - 7.6, hx + 7.6)], GOLD)                        # crown band
    p.trap([(hy - 11, hx - 5.2, hx + 5.2), (hy - 7.2, hx - 6.2, hx + 6.2)], mat("C89A28", "5E3E1C", "A07818", "FAE08A"))
    p.trap([(hy - 14.4, hx - 3.4, hx + 3.4), (hy - 10.8, hx - 4.4, hx + 4.4)], GOLD)
    p.cap(hx, hy - 14, hx, hy - 17.5, 1.3, 0.9, GOLD)
    # arms: shoulder stones first for the back arm, the pillar sits behind the front fist
    shl, shr = (cx - 13, 28 + b), (cx + 13, 28 + b)
    el, hl = (cx + arm_l[0][0], arm_l[0][1] + b), (cx + arm_l[1][0], arm_l[1][1] + b)
    er, hr = (cx + arm_r[0][0], arm_r[0][1] + b), (cx + arm_r[1][0], arm_r[1][1] + b)
    limb(p, shl, el, hl, DARK, 0.95)
    p.ell(shl[0], shl[1], 6.6, 5.4, STONE)
    p.cap(shl[0] - 4, shl[1] + 2.5, shl[0] + 4, shl[1] + 2.5, 1.0, 1.0, GOLD)
    if orb > 0:
        F.orb(p, hl[0], hl[1] - 8, 1.8 + orb * 3.6, (DARK[1], ACC, hexc("FFD070"), hexc("FFFFFF")))
    pillar(p, hr[0], hr[1], ang, reach[0], reach[1])
    limb(p, shr, er, hr, DARK)
    p.ell(shr[0], shr[1], 6.8, 5.6, STONE)
    p.cap(shr[0] - 4, shr[1] + 2.5, shr[0] + 4, shr[1] + 2.5, 1.0, 1.0, GOLD)


def cell(**kw):
    return H.draw(CW, CH, bandung, FXC, **kw)


def main():
    base, moves = H.rows(cell, idle_ang=-68, up=-42, strike=(30, 58), reach=(8, 26), rest_r=((17, 38), (19, 46)),
                         rest_l=((-17, 38), (-18, 47)), planted=((15, 40), (16, 40)), walk_swing=3)
    F.finish("bandung_bondowoso", CW, CH, base, moves)


if __name__ == "__main__":
    main()
