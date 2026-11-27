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
import random
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_boss_faceless_captain as F
from gen_boss_faceless_captain import mat, hexc, GOLD, WOOD, REST_L, REST_R

CW, CH = 80, 80
G = 77.0   # the ground line: foot soles sit on row 78
SKIN1 = mat("3FA83C", "0A2A18", "1F6E2C", "92E264")
SKIN2 = mat("2A7A34", "06180E", "164A22", "5CAA4A")   # phase 2: darker, angrier green
SKIN = SKIN1
BROW = mat("1A5A2A", "081E14", "10401E", "2E8438")
HAIR = mat("3A2418", "120A0C", "261610", "6A4630")
CLOTH = mat("B02A26", "380A14", "6E1620", "E8604A")
BONE = mat("EEE2C0", "6A5A58", "B4A68C", "FFFBE8")
CLUB = mat("7A4C2A", "2A160E", "52301C", "B07C4A")
EYE_R = hexc("FF3B2A")
EYE_Y = hexc("FFE070")
ACC = hexc("8CFF5A")
T = (SKIN1[3], SKIN1[2], SKIN1[1])
DUST = mat("A08458", "3E3020", "6E5A3C", "D8BE8C")
SWIRL = (hexc("1F6E2C"), hexc("5ED04A"), hexc("A8F080"), hexc("EEFFD0"))
STEAM = (hexc("7A7E8C"), hexc("B4B8C4"), hexc("DCDEE6"), hexc("FFFFFF"))
VEIN = hexc("7A1428")
PAINT = hexc("D8302A")


def dust_fx(p, x0, ph):
    """Kicked-up dirt behind the feet: round chunks that rise and fall back as the phase advances."""
    rnd = random.Random(7)
    for i in range(7):
        t = (ph * 0.37 + i / 7.0) % 1.0
        r = 3.0 + rnd.random() * 3.0 - t * 1.5
        p.ell(x0 + 6 - t * 28 - rnd.random() * 6, G - 3 - 20 * math.sin(math.pi * t) * (0.5 + rnd.random() * 0.6), r, r * 0.85, DUST)


def inhale_fx(p, mx, my, ph):
    """Chunky curved streaks spiralling into the mouth at (mx, my)."""
    for k in range(5):
        th0 = math.radians(-65 + k * 32)
        s0 = (ph + k / 5.0) % 0.7
        pts = []
        for j in range(5):
            u = s0 + j * 0.08
            r = 30 * (1 - u) + 13
            th = th0 - 2.0 * u * (1 if k % 2 else -1) * 0.8
            pts.append((mx + math.cos(th) * r, my + math.sin(th) * r * 0.85))
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            p.cap(x0, y0, x1, y1, 2.6, 1.8, SWIRL, rim=False)


def steam_fx(p, nx, ny, seed):
    rnd = random.Random(seed)
    for i in range(3):
        r = 2.0 + i * 0.9 + rnd.random()
        p.ell(nx + 3 + i * 4.5 + rnd.random() * 2, ny - 2 - i * 3.2 - rnd.random() * 2, r, r * 0.9, STEAM, rim=False)


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
         glow=False, mouth=1, orb=0.0, tilt=False, sway=0, kneel=False, bull=0.0, maw=0.0, swirl=0.0, ph=0.0, dust=0.0, p2=False, **_):
    """A hunched giant: hump behind, shoulders higher than the low head, arms hanging to the knees."""
    b = breath + crouch
    cx = CW / 2 + lean - 1
    hx = cx + 5 + head[0] + lean * 0.4 + (3 if kneel else 0) + 14 * bull
    hy = 25 + b + head[1] + (3 if kneel else 0) + 13 * bull - 2.5 * maw + (2 if p2 else 0)
    sy = 38 + b
    if dust > 0:
        dust_fx(p, cx - 24, dust)
    # mane at the back, behind the hump (p2: a bigger hunch)
    p.ell(cx - 14 - (2 if p2 else 0), 30 + b - (3 if p2 else 0), 16 + (3 if p2 else 0), 13 + (4 if p2 else 0), SKIN)
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
    if p2:                                                                           # red war paint and swollen veins
        for yy in (38, 44):
            p.line([(cx - 7, yy + b), (cx + 1, yy + 5 + b), (cx + 9, yy + b)], PAINT, 2.0, tor)
        p.line([(cx + 14, 36 + b), (cx + 12, 42 + b), (cx + 16, 47 + b)], VEIN, 2.0, tor)
        p.line([(cx - 12, 40 + b), (cx - 8, 46 + b), (cx - 11, 51 + b)], VEIN, 2.0, tor)
    # head: heavy brow, broad jaw, tusks
    p.cap(cx + 2, 36 + b, hx - 1, hy + 2, 7.5, 7.0, SKIN)
    p.ell(hx - 6, hy - 9, 13, 9, HAIR)
    for k, (dx, dy, ex, ey) in enumerate(((-4, -14, -9, -23), (3, -15, 1, -25), (9, -12, 11, -22), (-9, -11, -19, -19))):
        p.cap(hx + dx, hy + dy, hx + ex - sway * 0.5, hy + ey, 3.6, 1.0, HAIR)
    jy = hy + 4.2 + mouth * 0.7 + maw * 10
    p.ell(hx + 1.5, jy, 9.6, 6.0, SKIN)
    p.ell(hx, hy - 0.5, 10.4, 8.6, SKIN)
    p.ell(hx - 9.5, hy + 0.5, 2.6, 4.0, SKIN)                                        # ear
    p.cap(hx - 9.8, hy + 3.5, hx - 9.8, hy + 5.5, 1.1, 1.1, GOLD, rim=False)
    p.trap([(hy - 9, hx - 7, hx + 8), (hy - 4.0, hx - 8.6, hx + 9.5)], HAIR)          # fringe
    mh = 1.5 + mouth * 1.4
    mt = hy + 2.5 if maw > 0.05 else jy - 2.4
    mb = jy + 0.5 if maw > 0.05 else jy - 2.4 + mh
    p.trap([(mt, hx - 4.5 - maw * 3, hx + 8.5 + maw * 2), (mb, hx - 3.4 - maw * 2, hx + 7.4 + maw * 2)], (BROW[1], hexc("2A0810"), hexc("4A1018"), hexc("6A1A20")))
    if maw > 0.3:
        p.ell(hx + 2.5, mb - 1.6, 5.0, 2.2, (hexc("2A0810"), hexc("8A2030"), hexc("C04050"), hexc("E87080")), rim=False)   # tongue
        for tx in (-3.0, 1.5, 6.0):
            p.cap(hx + tx, mb - 0.4, hx + tx, mb - 3.0, 1.2, 0.8, BONE, rim=False)   # lower teeth
    for tx in (-1.6, 3.2) if maw <= 0.3 else (-3.0, 0.4, 3.8, 7.2):
        p.cap(hx + tx, mt + 0.4, hx + tx, mt + (2.0 if maw <= 0.3 else 3.4), 1.1, 0.8, BONE, rim=False)       # upper teeth
    if bull > 0.5:                                                                   # head down: tusks point forward
        p.cap(hx + 3.0, jy + 2.0, hx + 15.0, jy - 3.0, 2.0, 0.7, BONE)
        p.cap(hx + 6.0, jy + 3.4, hx + (10.0 if p2 else 16.0), jy + (0.6 if p2 else -1.0), 2.0, 0.7 if not p2 else 1.4, BONE)
    else:
        p.cap(hx - 6.0, jy + 3.0, hx - 8.6, jy - 6.0, 1.9, 0.7, BONE)                    # tusks
        p.cap(hx + 9.0, jy + 3.0, hx + 11.4, jy - (1.5 if p2 else 6.0), 1.9, 0.7 if not p2 else 1.5, BONE)   # p2: broken
    if p2:
        p.line([(hx + 2, hy + 1.0), (hx + 9, hy + 5.5)], PAINT, 2.0)                  # cheek slashes
        p.line([(hx + 1, hy + 4.0), (hx + 7, hy + 8.0)], PAINT, 2.0)
        p.line([(hx - 4, hy - 7), (hx - 1, hy - 3.4), (hx + 3, hy - 5)], VEIN, 2.0)
    ec = EYE_Y if glow and not p2 else EYE_R
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
    shl, shr = (cx - 22 - 10 * bull, sy + 3 * bull), (cx + 23 - 18 * bull, sy + 3 * bull)
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
    if p2:
        steam_fx(p, hx + 9, hy + 3.4, int(breath * 5) + int(crouch) * 3 + int(ph * 8))
    if swirl > 0:
        inhale_fx(p, hx + 5, hy + 9, ph)


def cell(p2=False, **kw):
    global SKIN
    SKIN = SKIN2 if p2 else SKIN1
    kw["p2"] = p2
    kw["legs_"] = kw.pop("legs", (0, 0))
    rings = kw.pop("rings", 0)
    streak = kw.pop("streak", False)
    return F.draw_cell(CW, CH, buto, extra=F.streaks(T) if streak else None, rings=rings, ring_tones=T, **kw)


def rush():
    """sig1: wind up, drop the head like a bull, then a 6-frame charge cycle (cols 2-7 loop) with dirt kicked behind."""
    keys = []
    for f in range(8):
        a = 2 * math.pi * (f - 2) / 6.0
        kw = dict(glow=True, bull=1.0, crouch=6, lean=1.0, arm_l=((-20, 40), (-24, 46)), arm_r=((-3, 34), (-15, 36)), ang=150, reach=(4, 20))
        if f < 2:
            kw.update(bull=0.35 + 0.4 * f, crouch=2 + 2 * f, lean=-1.0 + 2.5 * f, dust=0.0, arm_r=((8, 40), (-4, 46)), ang=150)
        else:
            kw.update(legs=(3 * max(0, math.sin(a)), 3 * max(0, -math.sin(a))), st=(-4 * math.cos(a), 4 * math.cos(a)), breath=0.8 * abs(math.cos(a)), dust=f - 1.0)
        keys.append(kw)
    return keys


def maw_keys():
    """sig2: the famine maw. Opens wide (cols 0-3), inhales (3-6), jaws snap shut on col 7."""
    keys = []
    for f in range(8):
        keys.append(dict(glow=True, maw=(0.15, 0.4, 0.7, 1, 1, 1, 1, 0)[f], swirl=(0, 0, 0.4, 1, 1, 1, 1, 0)[f], ph=f * 0.19, breath=(0, -0.5, -1, -1.5, -2, -2.5, -2.5, 1)[f],
                         crouch=(0, 0, 1, 1, 2, 2, 2, 3)[f], lean=(0, -0.5, -1, -1.5, -1.5, -1.5, -1.5, 2)[f], arm_l=((-18, 34), (-23, 40)), arm_r=((18, 34), (23, 40)), ang=-60, mouth=1 if f == 7 else 2))
    return keys


def main():
    kw = dict(ang_up=-95, strike=(35, 50), kang=-84, kreach=(4, 26), sig1=rush(), sig2=maw_keys())
    base, moves = F.build_rows(cell, **kw)
    base2, moves2 = F.build_rows(lambda **k: cell(p2=True, **k), **kw)
    F.finish("buto_ijo", CW, CH, base, moves, p2=(base2, moves2))


if __name__ == "__main__":
    main()
