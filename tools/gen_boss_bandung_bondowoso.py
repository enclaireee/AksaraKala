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
JIN = mat("2C8C88", "0A2C34", "1C6068", "7CF0D0")
FLAME = (hexc("1C8C84"), hexc("3CD8B8"), hexc("9CFFE0"), hexc("F0FFF8"))
TATT = hexc("7CFFD8")
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
            reach=(8, 26), glow=False, mouth=1, orb=0.0, tilt=False, kneel=False, sway=0, p2=False):
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
    if lift[1] >= 5:        # the raised knee comes out in front of the kilt
        kx, ky = cx + 12, 44 + crouch - lift[1] * 0.1
        p.cap(cx + 4, 46 + crouch, kx, ky, 5.2, 4.6, CLOTH)
        p.cap(kx, ky, cx + 10, 62 - lift[1], 4.4, 3.8, HIDE)
        p.ell(cx + 11, 62 - lift[1], 5.4, 2.8, DARK)
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
    if p2:      # headdress flames
        for dx, h, w in ((-4.5, 7, 2.6), (0, 11 + breath * 0.5, 3.2), (4.5, 8, 2.6)):
            for c, k in ((FLAME[1], 1.0), (FLAME[2], 0.7), (FLAME[3], 0.4)):
                bx, by = hx + dx, hy - 13
                p.poly([(bx - w * k, by), (bx - w * k * 0.7, by - h * k * 0.5), (bx + dx * 0.15 + sway * 0.3, by - h * k), (bx + w * k * 0.7, by - h * k * 0.45), (bx + w * k, by)], c)
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
    if p2:      # glowing tattoo lines
        for pts in (((-10, 31), (-5, 35), (-8, 41)), ((10, 31), (5, 35), (8, 41)), ((0, 36), (0, 43)), ((-6, 29), (-12, 29))):
            p.line([(cx + x, y + b) for x, y in pts], TATT, 1.0)
        for (a_, b_) in ((el, shl), (er, shr)):
            p.line([(a_[0] * 0.6 + b_[0] * 0.4, a_[1] * 0.6 + b_[1] * 0.4 - 2), (a_[0] * 0.6 + b_[0] * 0.4 + 1, a_[1] * 0.6 + b_[1] * 0.4 + 2)], TATT, 1.0)
        p.line([(hx - 2, hy - 4), (hx + 3, hy - 4.5)], TATT, 1.0)
        p.line([(hx - 1, hy - 2.5), (hx - 1, hy - 5.5)], TATT, 1.0)


def jin(g, x, y, s_, arms=-1):
    """A ghost jin silhouette (feet at y): horned head, wide trapezoid body, a raised arm and a spear."""
    g.cap(x + 7 * s_, y - 34 * s_, x + 7 * s_, y - 6 * s_, 0.9, 0.9, JIN[2:] * 2, rim=False)
    g.trap([(y - 18 * s_, x - 3.4 * s_, x + 3.4 * s_), (y - 8 * s_, x - 4.6 * s_, x + 4.6 * s_), (y, x - 3 * s_, x + 3 * s_)], JIN)
    g.cap(x + 3 * s_, y - 16 * s_, x + 7 * s_, y - 20 * s_, 1.6, 1.4, JIN)
    g.ell(x, y - 22 * s_, 3.0 * s_, 3.2 * s_, JIN)
    g.poly([(x - 2.4 * s_, y - 24 * s_), (x - 3.6 * s_, y - 27.5 * s_), (x - 0.8 * s_, y - 25 * s_)], JIN[2])
    g.poly([(x + 2.4 * s_, y - 24 * s_), (x + 3.6 * s_, y - 27.5 * s_), (x + 0.8 * s_, y - 25 * s_)], JIN[2])
    g.dot(x - 0.8 * s_, y - 22 * s_, JIN[3])
    g.dot(x + 1.2 * s_, y - 22 * s_, JIN[3])


def cell(p2=False, pillar=0.0, rub=0, echo=(0, 0), rings=0, chips=0, streak=False, **kw):
    """H.draw's layer order plus: p2 ghost army behind, a summoned ground pillar and rubble in front, echo rings."""
    off = CH - 64
    p = F.Paint(CW, CH, 1.0, 0.0, off)
    if p2:
        g = F.Paint(CW, CH, 1.0, 0.0, 0.0)
        bob = kw.get("breath", 0) * 0.8
        for (x, y, s_) in ((9, 64 + bob, 1.0), (21, 56 - bob, 0.78), (57, 60 + bob, 0.9)):
            jin(g, x, y, s_)
        for k, c in g.pix.items():
            p.pix[k] = c[:3] + (170,)
            p.soft.add(k)
    for r_ in (rings,) + tuple(echo):
        H.ring_fx(p, CW // 2, CH - 5, r_, FXC, False)
    if streak:
        H.streak_fx(p, FXC)
    bandung(p, p2=p2, **kw)
    for r_ in (rings,) + tuple(echo):
        H.ring_fx(p, CW // 2, CH - 5, r_, FXC, True)
    if chips:
        H.chip_fx(p, CW // 2, 56 + off, chips, FXC)
    rub = int(round(rub))
    if pillar > 0 or rub:
        g = F.Paint(CW, CH, 1.0, 0.0, 0.0)
        cxp = int(CW / 2 + kw.get("lean", 0.0)) + 23
        if pillar > 0:
            top = 62 - 46 * pillar
            g.trap([(top + 6, cxp - 5, cxp + 5), (62, cxp - 5.5, cxp + 5.5)], STONE)
            g.trap([(top, cxp - 7, cxp + 7), (top + 6, cxp - 6, cxp + 6)], STONE)
            g.line([(cxp - 6, top + 6.5), (cxp + 6, top + 6.5)], GOLD[2], 2.0)
            g.line([(cxp - 5, 50), (cxp + 5, 50)], GOLD[2], 2.0)
            g.line([(cxp - 1, top + 12), (cxp + 1, top + 20), (cxp - 1, top + 26)], STONE[1], 1.0)
            g.ell(cxp, 62, 9.5, 2.8, mat("8A7A60", "2E2418", "6A5A44", "C8B890"))
        for i, (dx, dy, r_) in enumerate(((-9, 58, 1.8), (9, 59, 2.0), (-12, 53, 1.5), (12, 52, 1.6), (0, 47, 1.4))[:int(round(rub)) * 2]):
            g.ell(cxp + dx, dy - (4 if pillar < 1 else 0) * (i % 2), r_, r_, STONE)
        p.pix.update(g.pix)
    im = p.image()
    return H.rim_light(im, hexc("A0FFE8"), 0.6) if p2 else im


def sig_pillar():
    A = dict(glow=True, mouth=2, reach=(8, 20), ang=-95, rub=0)
    up = lambda y: dict(arm_r=((16, y + 3), (15, y)), arm_l=((-16, y + 3), (-15, y)))
    return [dict(A, **up(30), pillar=0.0, ang=-75, breath=-1),
            dict(A, **up(24), pillar=0.12, rub=1, breath=-1.5),
            dict(A, **up(19), pillar=0.35, rub=1, breath=-2),
            dict(A, **up(15), pillar=0.65, rub=2, breath=-2.5, lean=-2),
            dict(A, **up(14), pillar=1.0, rub=2, breath=-3, lean=-2, chips=1),
            dict(A, arm_r=((15, 44), (17, 56)), arm_l=((-14, 44), (-15, 55)), ang=75, crouch=5, lean=3, pillar=1.0, rub=3, rings=22, chips=2, step=1),
            dict(A, arm_r=((15, 44), (17, 56)), arm_l=((-14, 44), (-15, 55)), ang=75, crouch=4, lean=2, pillar=1.0, rub=3, rings=28, chips=2, step=1, glow=False),
            dict(A, arm_r=((15, 42), (17, 52)), arm_l=((-14, 42), (-15, 52)), ang=60, crouch=2, lean=1, pillar=1.0, rub=2, glow=False, mouth=1)]


def sig_stomp():
    A = dict(glow=True, mouth=2, ang=-60, reach=(8, 20), arm_r=((16, 34), (17, 28)), arm_l=((-16, 34), (-17, 28)), echo=(0, 0))
    fr = [dict(A, lift=(0, 4), lean=-0.5, breath=-1), dict(A, lift=(0, 8), lean=-1, breath=-1.5),
          dict(A, lift=(0, 12), lean=-1.5, breath=-2), dict(A, lift=(0, 15), lean=-2, breath=-2.5)]
    D = dict(A, arm_r=((15, 42), (17, 52)), arm_l=((-14, 42), (-15, 52)), ang=40, lift=(0, 0), step=1)
    fr += [dict(D, crouch=4, lean=2, rings=18, chips=3),
           dict(D, crouch=3, lean=1.5, rings=24, echo=(13, 0), chips=2),
           dict(D, crouch=2, lean=1, rings=29, echo=(19, 9), chips=1, glow=False),
           dict(D, crouch=1, lean=0.5, rings=31, echo=(25, 16), glow=False, mouth=1)]
    return fr


def main():
    kw = dict(idle_ang=-68, up=-42, strike=(30, 58), reach=(8, 26), rest_r=((17, 38), (19, 46)),
              rest_l=((-17, 38), (-18, 47)), planted=((15, 40), (16, 40)), walk_swing=3)
    base, moves = H.rows(cell, sig1=sig_pillar(), sig2=sig_stomp(), **kw)
    p2 = H.rows(lambda **k: cell(p2=True, **k), sig1=sig_pillar(), sig2=sig_stomp(), **kw)
    F.finish("bandung_bondowoso", CW, CH, base, moves, p2=p2)


if __name__ == "__main__":
    main()
