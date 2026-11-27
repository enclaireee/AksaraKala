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
MIST = (hexc("5C7096"), hexc("8CA4C4"), hexc("BCD0E4"), hexc("E8F2FA"))
PALE = (210, 236, 255)


def topeng(p, x, y, k, crack=False):
    """The pale wooden mask: carved brows, slit eyes, a nose ridge and a thin mouth."""
    p.ell(x, y, 4.4 * k, 5.6 * k, MASK)
    for ex in (-1, 1):
        p.cap(x + ex * 1.9 * k - 1.0 * k, y - 1.0 * k, x + ex * 1.9 * k + 1.0 * k, y - 0.4 * k, 0.9 * k, 0.9 * k, (INNER[0],) * 4, rim=False)
    p.cap(x, y - 0.2 * k, x + 0.4 * k, y + 2.0 * k, 0.8 * k, 0.8 * k, (MASK[1],) * 4, rim=False)
    p.cap(x - 1.5 * k, y + 3.3 * k, x + 1.5 * k, y + 3.3 * k, 0.7 * k, 0.7 * k, (RED,) * 4, rim=False)
    F.rect(p, x - 1 * k, y - 4.6 * k, x + 1 * k, y - 3.2 * k, RED)
    if crack:
        p.line([(x + 2.2 * k, y - 5.2 * k), (x - 0.4 * k, y - 1.6 * k), (x + 1.6 * k, y + 1.8 * k), (x - 0.6 * k, y + 5 * k)], INNER[0], 2.0)
        p.line([(x + 2.8 * k, y - 4.6 * k), (x + 0.4 * k, y - 1.4 * k)], RED, 1.0)
        for yy in range(int(y + 3 * k), int(y + 6 * k)):                 # a chipped corner
            for xx in range(int(x + 2.4 * k), int(x + 5 * k)):
                p.pix.pop((xx, yy), None)
                p.soft.discard((xx, yy))


def halo_fx(p, x, y, h):
    """Stepped pale glow rings behind the mask plus fat rays: the tell."""
    for r, a in ((19, 46), (14.5, 84), (10.5, 126)):
        r = r * (0.7 + 0.3 * h)
        for yy in range(max(0, int(y - r * 1.2)), min(CH, int(y + r * 1.2) + 1)):
            for xx in range(max(0, int(x - r)), min(CW, int(x + r) + 1)):
                if ((xx + 0.5 - x) / r) ** 2 + ((yy + 0.5 - y) / (r * 1.15)) ** 2 <= 1.0 and ((xx, yy) not in p.pix or (xx, yy) in p.soft):
                    p.pix[(xx, yy)] = PALE + (a,)
                    p.soft.add((xx, yy))
    for i in range(8):
        th = math.radians(i * 45 + 22)
        ln = (15 + 5 * h) if i % 2 else 12 + 3 * h
        p.cap(x + math.cos(th) * 11, y + math.sin(th) * 12, x + math.cos(th) * ln, y + math.sin(th) * ln * 1.1, 1.9, 0.9, MASK, rim=False)


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
           glow=False, mouth=1, orb=0.0, tilt=False, sway=0, kneel=False, mask=0.0, halo=0.0, bare=0.0, aside=0.0, clutch=0.0, p2=False, **_):
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
        notch = (2.0 + (xx % 6 if xx % 6 < 3 else 6 - xx % 6) * 1.6) * (1.9 if p2 else 1.0)
        for yy in range(int(hem - notch), int(hem) + 2):
            if (xx, yy) in p.pix and yy > hem - notch:
                del p.pix[(xx, yy)]
    if kneel:
        p.ell(cx - 12, G - 5, 13, 5.5, CLOAK)                          # the cloak pooled on the ground behind
        p.ell(cx + 10, G - 14, 8.5, 9, CLOAK)                          # the raised knee under the cloak
        p.ell(cx + 10, G - 18, 4.5, 3.5, INNER)
    if p2:                                                                  # hanging tatters
        for xo, ln in ((-15, 6), (-8, 4), (6, 5), (13, 6)):
            p.cap(cx + xo, hem - 9, cx + xo - 1.5 - sway * 0.4, min(CH - 2, hem + ln - 2), 2.4, 0.9, CLOAK)
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
    off = mask > 0.3 or bare > 0.5 or aside > 0
    if not off:
        p.ell(hx + 3.0, hy + 1.4, 4.4, 5.6, MASK)
        p.line([(hx + 4.6, hy - 3.4), (hx + 2.6, hy + 0.4), (hx + 3.6, hy + 3.6)], MASK[1], 2.0)   # the crack
        F.rect(p, hx + 2, hy - 4.6, hx + 4, hy - 3.2, RED)
        if p2:
            p.line([(hx + 1.6, hy - 5.2), (hx + 4.4, hy - 1.0), (hx + 2.2, hy + 2.6), (hx + 4.4, hy + 6.0)], INNER[0], 2.0)
            p.line([(hx + 1.0, hy - 4.6), (hx + 3.8, hy - 1.0)], RED, 1.0)
    else:
        p.ell(hx + 3.0, hy + 1.4, 3.8, 5.0, (INNER[0], INNER[0], hexc("1A1626"), hexc("241E34")), rim=False)   # the bare void
        for ex in (hx + 1.8, hx + 5.2):
            p.ell(ex, hy + 0.2, 1.1, 1.3, (ACC,) * 4, rim=False)
    ec = ACC if glow else MASK[0]
    for ex in (hx + 1.2, hx + 5.6) if not off else ():
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
    kk = 1 + 0.7 * mask
    mx, my = hx + 3 + 6 * mask, hy + 1.4 - 6.5 * mask
    w = min(1.0, max(mask * 1.5, clutch))
    if w > 0:                                                               # both hands to the mask / to the face
        tl, tr = ((mx - 6.5 * kk, my + 6.5 * kk), (mx + 6.5 * kk, my + 6.5 * kk)) if mask > 0 else ((hx + 0.5, hy + 4), (hx + 6.5, hy + 2))
        mix = lambda a, c: (a[0] + (c[0] - a[0]) * w, a[1] + (c[1] - a[1]) * w)
        hl, hr = mix(hl, tl), mix(hr, tr)
        el, er = (shl[0] + (hl[0] - shl[0]) * 0.4 - 2, shl[1] + (hl[1] - shl[1]) * 0.5 + 4), (shr[0] + (hr[0] - shr[0]) * 0.4 + 3, shr[1] + (hr[1] - shr[1]) * 0.5 + 5)
    F.limb_arm(p, shl, el, hl, CLOAK, HAND, 2.7, 0.95)
    p.ell(shl[0], shl[1], 4.6, 3.8, CLOAK)
    if orb > 0:
        F.orb(p, hl[0], hl[1] - 8, 2.0 + orb * 3.6, (INNER[0], ACC, hexc("D8F0FF"), hexc("FFFFFF")))
    if mask < 0.3 and clutch < 0.3:
        sword(p, hr[0], hr[1], ang, reach[0], reach[1] * 1.15 + 3 if p2 else reach[1])
    F.limb_arm(p, shr, er, hr, CLOAK, HAND, 2.7, 0.95)
    p.ell(shr[0], shr[1], 4.6, 3.8, CLOAK)
    if p2:                                                                  # mist clinging to the legs, torn sleeve strips
        for xo, yo, r in ((-9 + sway * 0.5, 4, 4.2), (7, 3, 3.6), (-2, 1, 3.2), (14, 5, 2.6), (-15, 6, 2.6)):
            p.ell(cx + xo, G - yo, r, r * 0.8, MIST, rim=False)
        p.cap(shl[0] - 2, shl[1] + 3, shl[0] - 3 - sway * 0.3, shl[1] + 14, 2.4, 0.8, CLOAK)
    if mask > 0:
        if halo > 0:
            halo_fx(p, mx, my, halo)
        topeng(p, mx, my, kk, crack=p2)
        p.ell(hl[0], hl[1], 2.7, 2.7, HAND)
        p.ell(hr[0], hr[1], 2.7, 2.7, HAND)
    if aside > 0:                                                           # the mask knocked away, tumbling to the ground
        t = min(1.0, aside)
        ax_, ay_ = hx + 3 + t * 24, hy + 1.4 - 9 * math.sin(math.pi * min(1.0, t * 1.4)) + (G - 4 - hy - 1.4) * t * t
        sq = 1.2 + 3.2 * abs(math.cos(t * 9)) if t < 1 else 4.4
        p.ell(ax_, ay_, sq, 5.2 if t < 1 else 2.2, MASK)
        F.rect(p, ax_ - 0.5, ay_ - 2, ax_ + 1, ay_ - 0.5, RED)


def cell(**kw):
    kw["legs_"] = kw.pop("legs", (0, 0))
    rings = kw.pop("rings", 0)
    streak = kw.pop("streak", False)
    return F.draw_cell(CW, CH, hunter, extra=F.streaks(T) if streak else None, rings=rings, ring_tones=T, **kw)


def mask_raise():
    """sig1: both hands lift the topeng in front of the face (cols 0-3), held high and glowing (cols 4-7, pulsing)."""
    return [dict(mask=(0.0, 0.25, 0.55, 0.85, 1, 1, 1, 1)[f], halo=(0, 0, 0.3, 0.6, 0.75, 1, 0.75, 1)[f], glow=True, lean=-1.0, head=(0, -1), breath=-0.5 * min(f, 3)) for f in range(8)]


def unmasked_reel():
    """sig2: the mask knocked aside, he staggers back clutching his face (cols 4-7 loop)."""
    keys = []
    for f in range(8):
        a = 2 * math.pi * (f - 4) / 4.0
        kw = dict(aside=(0.08, 0.3, 0.6, 1, 1, 1, 1, 1)[f], bare=1, clutch=(0, 0.4, 0.9, 1, 1, 1, 1, 1)[f], tilt=f < 3, lean=-4.5, head=(-2, 2), crouch=2, glow=False)
        if f >= 4:
            kw.update(lean=-4.5 + 1.3 * math.sin(a), head=(-2 + math.sin(a), 2 + math.cos(a)), sway=1.5 * math.sin(a), legs=(2 * max(0, math.sin(a)), 2 * max(0, -math.sin(a))), st=(-2 * math.sin(a), 2 * math.sin(a)))
        keys.append(kw)
    return keys


def main():
    kw = dict(ang_up=-100, strike=(30, 45), kang=-86, kreach=(4, 30), sig1=mask_raise(), sig2=unmasked_reel())
    base, moves = F.build_rows(cell, **kw)
    base2, moves2 = F.build_rows(lambda **k: cell(p2=True, **k), **kw)
    F.finish("nameless_hunter", CW, CH, base, moves, p2=(base2, moves2))


if __name__ == "__main__":
    main()
