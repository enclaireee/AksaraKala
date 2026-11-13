#!/usr/bin/env python3
"""The Nameless Hunter (Si Tanpa Ngaran), boss redraw (wave 4 art pass v8). 64x72 cells (was 28x44).

Outputs assets/art/enemies/nameless_hunter.png (4x4: idle, walk, telegraph, hurt) and nameless_hunter_moves.png (4x7: cast,
slam, dash, roar, rise, kneel, death), the contract of components/enemy_art.gd. Faces RIGHT, feet on the bottom row, centred.
A tall hooded stalker in a long ragged black cloak, a blank cracked mask, a pale blade, a chain on the belt and the lontar
roll of names (cream strips with red marks) at his hip. tools/gen_bosses.py and gen_boss_moves.py no longer write these files.
Painter and row builder come from gen_boss_faceless_captain.py. Also writes tools/boss_nameless_hunter_preview.png.
Run: python3 tools/gen_boss_nameless_hunter.py
"""
import math
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_boss_faceless_captain as F
from gen_boss_faceless_captain import mat, hexc, STEEL, REST_L, REST_R

CW, CH = 64, 72
G = 69.0
CLOAK = mat("34324A", "0A0912", "1A1826", "5A5878")
INNER = mat("5A586E", "14121E", "34324A", "8E8CA8")
HAND = mat("C8C0C8", "4A4258", "8E869A", "F4F0F4")
MASK = mat("ECE8DA", "5A5468", "ACA6A8", "FFFFF6")
LONTAR = mat("E8D8A8", "5E4A3A", "B8A47A", "FFF4D0")
LEATHER = mat("6A4A30", "24160E", "44301E", "A07850")
RED = hexc("D0283A")
ACC = hexc("9CD8FF")
T = (ACC, hexc("5C90C8"), hexc("2C4880"))


def legs(p, cx, hip, lifts, st, kneel):
    th = (3.0, 2.6)
    if kneel:
        p.ell(cx - 20, G - 1.6, 4.0, 2.4, CLOAK)
        p.ell(cx + 17, G - 1.8, 4.6, 2.6, LEATHER)
        return
    for i, side in enumerate((-1, 1)):
        fx, lift = cx + side * 4.2 + st[i] * 1.2, lifts[i] * 1.5
        p.cap(cx + side * 3.5, hip, fx, G - 3 - lift, th[0], th[1], CLOAK)
        p.ell(fx + 1.4, G - 1.8 - lift, 4.4, 2.6, LEATHER)


def sword(p, hx, hy, ang, back, fwd):
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    nx, ny = -sa, ca
    if nx * -0.6 + ny * -0.7 < 0:
        nx, ny = -nx, -ny   # n points to the lit side
    p.cap(hx - ca * back, hy - sa * back, hx, hy, 1.7, 1.7, LEATHER)
    gx, gy = hx + ca * 2.5, hy + sa * 2.5
    p.cap(gx - nx * 4.0, gy - ny * 4.0, gx + nx * 4.0, gy + ny * 4.0, 1.3, 1.3, F.GOLD)
    bx, by = hx + ca * 4, hy + sa * 4
    ex, ey = hx + ca * fwd * 0.92, hy + sa * fwd * 0.92
    p.poly([(bx + nx * 2.8, by + ny * 2.8), (ex, ey), (bx - nx * 2.8, by - ny * 2.8)], STEEL[2])
    p.line([(bx + nx * 1.4, by + ny * 1.4), (ex - ca * 3 + nx * 0.3, ey - sa * 3 + ny * 0.3)], STEEL[3], 2.0)
    p.line([(bx - nx * 1.5, by - ny * 1.5), (ex - ca * 4, ey - sa * 4)], STEEL[1], 2.0)


def hunter(p, breath=0, crouch=0, lean=0.0, legs_=(0, 0), st=(0, 0), head=(0, 0), arm_l=REST_L, arm_r=REST_R, ang=-80, reach=(12, 34),
           glow=False, mouth=1, orb=0.0, tilt=False, sway=0, kneel=False, **_):
    """Tall and narrow: long ragged cloak, pointed hood, the sword arm forward."""
    b = breath + crouch
    cx = CW / 2 + lean
    hx, hy = cx + 1 + head[0] + lean * 0.4 + (2 if kneel else 0), 17 + b + head[1] + (2 if kneel else 0)
    sy = 26 + b
    hem = 64 if not kneel else 66
    # trailing back of the cloak
    p.trap([(24 + b, cx - 9, cx + 6), (48, cx - 14 - sway, cx + 8), (hem, cx - 21 - sway * 2, cx + 10 - sway)], CLOAK)
    legs(p, cx, 56, legs_, st, kneel)
    front = p.trap([(23 + b, cx - 7, cx + 7), (30 + b, cx - 10, cx + 10), (48, cx - 11, cx + 11), (hem, cx - 16 - sway, cx + 16 - sway)], CLOAK)
    for xx in range(int(cx - 20), int(cx + 18)):      # ragged hem: v-shaped notches cut into the bottom
        notch = (2.0 + (xx % 6 if xx % 6 < 3 else 6 - xx % 6) * 1.6)
        for yy in range(int(hem - notch), int(hem) + 2):
            if (xx, yy) in p.pix and yy > hem - notch:
                del p.pix[(xx, yy)]
    if kneel:
        p.ell(cx - 12, G - 5, 13, 5.5, CLOAK)                          # the cloak pooled on the ground behind
        p.ell(cx + 10, G - 14, 8.5, 9, CLOAK)                          # the raised knee under the cloak
        p.ell(cx + 10, G - 18, 4.5, 3.5, INNER)
    p.line([(cx + 2, 31 + b), (cx + 3, hem - 4)], CLOAK[0], 2.0, front)      # the cloak's front fold
    p.line([(cx - 5, 36 + b), (cx - 8, hem - 6)], CLOAK[1], 2.0, front)
    p.trap([(38 + b * 0.8, cx - 10, cx + 10), (41 + b * 0.8, cx - 10.5, cx + 10.5)], LEATHER)
    p.ell(cx + 1, 39.5 + b * 0.8, 2.2, 2.0, F.GOLD)
    for i, (x0, ln) in enumerate(((-9, 10), (-6, 13), (-3, 8))):                # the lontar roll of names
        y0 = 41 + b * 0.8
        p.trap([(y0, cx + x0, cx + x0 + 3), (y0 + ln, cx + x0, cx + x0 + 3)], LONTAR, bend=0.5)
        F.rect(p, cx + x0 + 0.5, y0 + 3, cx + x0 + 2.5, y0 + 5, RED)
        if ln > 9:
            F.rect(p, cx + x0 + 0.5, y0 + 8, cx + x0 + 2.5, y0 + 10, RED)
    for i in range(4):                                                      # chain links on the belt
        p.ell(cx + 8.5 + (i % 2) * 0.8, 44 + b * 0.8 + i * 3, 1.7, 2.1, STEEL if i % 2 else INNER)
    # shoulders and hood
    p.cap(hx - 1, hy + 4, cx, 24 + b, 3.4, 4.4, CLOAK)
    p.ell(cx - 7.5, sy - 0.5, 5.4, 4.6, CLOAK)
    p.ell(cx + 7.5, sy - 0.5, 5.4, 4.6, CLOAK)
    p.cap(hx - 1, hy - 5, hx - 6 - sway * 0.5, hy - 15, 5.2, 1.0, CLOAK)       # the hood's point
    p.ell(hx, hy - 1, 8.6, 9.6, CLOAK)
    p.ell(hx + 2.6, hy + 1.2, 5.6, 6.6, (INNER[0],) * 4, rim=False)
    p.ell(hx + 3.0, hy + 1.4, 4.4, 5.6, MASK)
    p.line([(hx + 4.6, hy - 3.4), (hx + 2.6, hy + 0.4), (hx + 3.6, hy + 3.6)], MASK[1], 2.0)   # the crack
    F.rect(p, hx + 2, hy - 4.6, hx + 4, hy - 3.2, RED)
    ec = ACC if glow else MASK[0]
    for ex in (hx + 1.2, hx + 5.6):
        if tilt:
            p.line([(ex - 1, hy - 0.8), (ex + 1, hy - 0.8)], MASK[1], 2.0)
        else:
            p.cap(ex - 1.2, hy - 0.8, ex + 1.2, hy - 0.4, 1.0, 1.0, (MASK[1], ec, ec, hexc("FFFFFF")) if glow else (INNER[0],) * 4, rim=False)
    if mouth > 1:
        p.cap(hx + 2, hy + 4.2, hx + 4.4, hy + 4.2, 1.0, 1.0, (INNER[0],) * 4, rim=False)
    # arms
    shl, shr = (cx - 8, sy), (cx + 8, sy)
    el, hl = F.M(cx, b, sy, 0.8, arm_l[0]), F.M(cx, b, sy, 0.8, arm_l[1])
    er, hr = F.M(cx, b, sy, 0.8, arm_r[0]), F.M(cx, b, sy, 0.8, arm_r[1])
    F.limb_arm(p, shl, el, hl, CLOAK, HAND, 2.7, 0.95)
    p.ell(shl[0], shl[1], 4.6, 3.8, CLOAK)
    if orb > 0:
        F.orb(p, hl[0], hl[1] - 8, 2.0 + orb * 3.6, (INNER[0], ACC, hexc("D8F0FF"), hexc("FFFFFF")))
    sword(p, hr[0], hr[1], ang, reach[0], reach[1])
    F.limb_arm(p, shr, er, hr, CLOAK, HAND, 2.7, 0.95)
    p.ell(shr[0], shr[1], 4.6, 3.8, CLOAK)


def cell(**kw):
    kw["legs_"] = kw.pop("legs", (0, 0))
    rings = kw.pop("rings", 0)
    streak = kw.pop("streak", False)
    return F.draw_cell(CW, CH, hunter, extra=F.streaks(T) if streak else None, rings=rings, ring_tones=T, **kw)


def main():
    base, moves = F.build_rows(cell, ang_up=-100, strike=(30, 45), kang=-86, kreach=(4, 30))
    F.finish("nameless_hunter", CW, CH, base, moves)


if __name__ == "__main__":
    main()
