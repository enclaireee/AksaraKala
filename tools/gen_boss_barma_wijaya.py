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
import gen_boss_hariang_banga as H
from PIL import Image
from gen_boss_faceless_captain import mat, hexc, GOLD, STEEL, WOOD, REST_L, REST_R

CW, CH = 56, 64
ROBE = mat("A02FA8", "2E0A34", "6C1A74", "D878E0")
SKIN = mat("D9A98A", "5E3228", "A8705A", "F6D0B2")
HAIR = mat("2A1E26", "0C080E", "1A1218", "50404A")
ROBE2 = mat("5C3E90", "160C2C", "3C2A66", "A394E0")
SILV = mat("B8B0F0", "2A2050", "7468C0", "F2F0FF")
CY = mat("5DF2FF", "103848", "2E9AB0", "E0FFFF")
ACC = hexc("5DF2FF")


def barma(p, breath=0, crouch=0, lean=0.0, legs=(0, 0), st=(0, 0), head=(0, 0), arm_l=REST_L, arm_r=REST_R, ang=-80, reach=(6, 20),
          glow=False, mouth=1, orb=0.0, tilt=False, sway=0, kneel=False, p2=False):
    rob = ROBE2 if p2 else ROBE
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
                 (54, cx - 17 + sway + st[0] * 0.3, cx + 17 + sway + st[1] * 0.3), (58, cx - 19 + sway, cx + 19 + sway)], rob)
    for i in range(-3, 4):
        p.line([(cx + i * 3.2, 46 + crouch), (cx + i * 5.6 + sway, 57)], rob[1], 1.0, rb)
    p.trap([(53.5, cx - 17 + sway, cx + 17 + sway), (58, cx - 19 + sway, cx + 19 + sway)], GOLD)
    for i in range(-8, 9, 3):
        p.dot(cx + i * 2.2 + sway, 55.8, CY[1], rb)
    if kneel:
        p.ell(cx + 12, 54, 6.5, 5.5, rob)
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
    if p2:      # cracked and slipping: tilted, a notch missing, a dark crack through the band
        p.trap([(hy - 9.4, hx - 6.2, hx + 4.2), (hy - 6, hx - 6.2, hx + 6.2)], GOLD)
        for dx, h in ((-4.6, 3), (-0.4, 6.5)):
            p.poly([(hx + dx - 2, hy - 9.4), (hx + dx - 1, hy - 9.4 - h), (hx + dx + 2, hy - 9.4)], GOLD[2])
        p.poly([(hx + 3, hy - 9.4), (hx + 5.4, hy - 11.6), (hx + 6.4, hy - 8)], GOLD[2])
        p.line([(hx - 1, hy - 9.4), (hx + 1, hy - 7.4), (hx, hy - 6)], GOLD[0], 1.0)
        p.ell(hx + 2.4, hy - 7.2, 1.3, 1.3, SILV)
    else:
        p.trap([(hy - 9.4, hx - 5.2, hx + 5.2), (hy - 6, hx - 6.2, hx + 6.2)], GOLD)
        for dx, h in ((-4.4, 4), (0, 6.5), (4.4, 4)):
            p.poly([(hx + dx - 2, hy - 9.4), (hx + dx, hy - 9.4 - h), (hx + dx + 2, hy - 9.4)], GOLD[2])
            p.line([(hx + dx - 2, hy - 9.4), (hx + dx, hy - 9.4 - h)], GOLD[3], 1.0)
        p.ell(hx, hy - 7.4, 1.4, 1.4, CY)
    # arms in wide sleeves
    shl, shr = (cx - 8.5, 27 + b), (cx + 8.5, 27 + b)
    el, hl = F.M(cx, b, 27, 0.9, arm_l[0]), F.M(cx, b, 27, 0.9, arm_l[1])
    er, hr = F.M(cx, b, 27, 0.9, arm_r[0]), F.M(cx, b, 27, 0.9, arm_r[1])
    F.limb_arm(p, shl, el, hl, rob, SKIN, 3.0)
    p.cap(shl[0] * 0.3 + el[0] * 0.7, shl[1] * 0.3 + el[1] * 0.7 + 1, hl[0] * 0.8 + el[0] * 0.2, hl[1] * 0.8 + el[1] * 0.2, 4.8, 4.0, rob)
    p.cap(el[0] + (hl[0] - el[0]) * 0.55, el[1] + (hl[1] - el[1]) * 0.55, hl[0] * 0.85 + el[0] * 0.15, hl[1] * 0.85 + el[1] * 0.15, 3.5, 3.5, GOLD)
    p.ell(shl[0], shl[1], 4.8, 4.0, rob)
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
    F.limb_arm(p, shr, er, hr, rob, SKIN, 3.0)
    p.cap(shr[0] * 0.3 + er[0] * 0.7, shr[1] * 0.3 + er[1] * 0.7 + 1, hr[0] * 0.8 + er[0] * 0.2, hr[1] * 0.8 + er[1] * 0.2, 4.8, 4.0, rob)
    p.cap(er[0] + (hr[0] - er[0]) * 0.55, er[1] + (hr[1] - er[1]) * 0.55, hr[0] * 0.85 + er[0] * 0.15, hr[1] * 0.85 + er[1] * 0.15, 3.5, 3.5, GOLD)
    p.ell(shr[0], shr[1], 4.8, 4.0, rob)
    if p2:      # torn robe: ragged hem, a slash through the cloth, mirror shards stuck in it and orbiting
        for k in range(-9, 10):
            d = 2 + (k * 5 % 4) * 1.4
            for yy in range(int(58 - d), 59):
                for xx in (int(cx + k * 2 + sway),):
                    p.pix.pop((xx, yy), None)
                    p.pix.pop((xx + 1, yy), None)
        p.line([(cx + 3, 46 + crouch), (cx + 11 + sway, 55)], rob[0], 2.0)
        for (sx, sy, ang_, ln) in ((-9, 49, 70, 6), (6, 40, -50, 5), (13, 52, 20, 5), (-3, 56, -80, 4)):
            ca_, sa_ = math.cos(math.radians(ang_)), math.sin(math.radians(ang_))
            X, Y = cx + sx + sway * 0.5, sy + breath * 0.3
            p.poly([(X - sa_ * 1.6, Y + ca_ * 1.6), (X + ca_ * ln, Y + sa_ * ln), (X + sa_ * 1.6, Y - ca_ * 1.6)], SILV[2])
            p.poly([(X - sa_ * 0.8, Y + ca_ * 0.8), (X + ca_ * ln * 0.8, Y + sa_ * ln * 0.8), (X, Y)], SILV[3])
        for (sx, sy, ln) in ((-20, 24, 5), (22, 18, 4), (-17, 41, 3.5), (23, 36, 4)):     # orbiting shards
            X, Y = cx + sx, sy + breath * 0.8
            p.poly([(X, Y - ln), (X + 2.2, Y), (X, Y + ln * 0.8), (X - 2, Y)], SILV[2])
            p.poly([(X, Y - ln), (X + 1.2, Y), (X, Y + 1)], SILV[3])


T = (CY[3], CY[2], CY[1])


SEAM = (hexc("F6F4FF"), hexc("B8B0F0"))


def mirror(im, cx, narrow, seam, half):
    """Mirror step post-pass: squeeze the figure side-on around cx, fade the left half, draw a bright vertical seam."""
    w, h = im.size
    if narrow < 1.0:
        nw = max(8, int(round(w * narrow)))
        cn = int(round(cx * narrow))
        sq = im.resize((nw, h), Image.NEAREST)
        im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        im.paste(sq, (int(cx) - cn, 0))
    px = im.load()
    cxi = int(cx)
    if half < 1.0:
        for y in range(h):
            for x in range(cxi):
                r, g, b, a = px[x, y]
                px[x, y] = (r, g, b, int(a * half))
    if seam > 0:
        ys = [y for y in range(h) if any(px[x, y][3] > 40 for x in range(cxi - 2, cxi + 3))]
        if ys:
            ext = int(1 + 2 * seam)
            for y in range(max(0, ys[0] - ext), min(h, ys[-1] + ext)):
                px[cxi, y] = SEAM[0]
                px[cxi + 1, y] = SEAM[0]
                if seam > 0.5 and (y // 2) % 2 == 0:
                    px[cxi - 1, y] = SEAM[1]
                    px[cxi + 2, y] = SEAM[1]
            for k in (-1, 1):       # glints at the ends of the seam
                gy = ys[0] - ext if k < 0 else ys[-1] + ext
                for dx in (-2, -1, 0, 1, 2, 3):
                    if 0 <= gy < h:
                        px[cxi + dx, gy] = SEAM[1]
    return im


def arc_fx(p, cx, arc, crack):
    """Royal cleave FX in pixel coords: a wide cyan smear arc and a ground crack."""
    if arc[1] - arc[0] > 8:
        H.crescent(p, cx + 8, 32, 25, 9, arc[0], arc[1], CY)
    if crack > 0:
        n = int(crack)
        for (x0, x1, y) in ((cx + 12, cx + 22, 60), (cx + 18, cx + 30, 61), (cx + 26, cx + 36, 59), (cx + 8, cx + 14, 62)):
            if x0 - cx < 10 + n * 8:
                x1 = min(x1, cx + 10 + n * 8)
                F.rect(p, x0, y, x1, y + 2, CY[1])
                F.rect(p, x0, y, x1 - 3, y + 1, CY[3])
        for (x, y) in ((cx + 24, 56), (cx + 31, 56), (cx + 18, 55)):
            if x - cx < 12 + n * 8:
                F.rect(p, x, y, x + 3, y + 3, CY[2])
                F.rect(p, x, y, x + 2, y + 1, CY[3])


def cell(p2=False, **kw):
    rings = kw.pop("rings", 0)
    streak = kw.pop("streak", False)
    narrow, seam, half = kw.pop("narrow", 1.0), kw.pop("seam", 0.0), kw.pop("half", 1.0)
    arc, crack = kw.pop("arc", (0, 0)), kw.pop("crack", 0)
    kw.pop("chips", None)
    cx = CW / 2 + kw.get("lean", 0.0)
    st = F.streaks(T) if streak else None

    def extra(p, front):
        if st:
            st(p, front)
        if front:
            arc_fx(p, int(cx), arc, crack)
    im = F.draw_cell(CW, CH, lambda pp, **k: barma(pp, p2=p2, **k), extra=extra, rings=rings, ring_tones=T, **kw)
    if narrow < 1.0 or seam > 0 or half < 1.0:
        im = mirror(im, cx + 1, narrow, seam, half)
    return H.rim_light(im, hexc("C8C0FF"), 0.7) if p2 else im


def sig_mirror():
    A = dict(glow=True, mouth=1, arm_r=((15, 36), (18, 40)), ang=-60)
    spec = ((0.85, 0.3, 1.0, 0), (0.7, 0.7, 1.0, 0), (0.6, 1.0, 1.0, 1), (0.6, 1.0, 0.55, 3), (0.6, 1.0, 0.22, 5),
            (0.6, 1.0, 0.06, 7), (0.85, 0.6, 0.7, 5), (1.0, 0.0, 1.0, 2))
    return [dict(A, narrow=n, seam=s_, half=h, lean=l) for i, (n, s_, h, l) in enumerate(spec)]


def sig_cleave():
    A = dict(glow=True, mouth=2, reach=(6, 13), arc=(0, 0), crack=0)
    return [dict(A, ang=-100, arm_r=((17, 30), (15, 16)), arm_l=((-2, 22), (12, 17)), breath=-1),
            dict(A, ang=-122, arm_r=((16, 27), (12, 13)), arm_l=((-4, 20), (9, 14)), lean=-3, breath=-3, head=(-1, 0)),
            dict(A, ang=-128, arm_r=((16, 27), (12, 12)), arm_l=((-4, 19), (9, 13)), lean=-3.5, breath=-3.5, head=(-1, -1)),
            dict(A, ang=-20, arm_r=((17, 36), (21, 32)), arm_l=((4, 34), (19, 33)), lean=2, crouch=2, arc=(-115, -25)),
            dict(A, ang=65, arm_r=((15, 42), (19, 52)), arm_l=((5, 44), (17, 51)), lean=4, crouch=4, arc=(-115, 60), crack=2, chips=2),
            dict(A, ang=65, arm_r=((15, 42), (19, 52)), arm_l=((5, 44), (17, 51)), lean=4, crouch=4, arc=(-60, 70), crack=3, chips=3),
            dict(A, ang=58, arm_r=((15, 41), (19, 50)), arm_l=((5, 42), (17, 49)), lean=3, crouch=3, arc=(20, 70), crack=3, chips=2),
            dict(A, ang=50, arm_r=((15, 40), (19, 48)), arm_l=((5, 40), (17, 47)), lean=2, crouch=2, glow=False, crack=3)]


def main():
    kw = dict(ang_up=-100, strike=(25, 40), kang=88, kreach=(4, 12), karm=((12, 34), (13, 38)))
    base, moves = F.build_rows(cell, sig1=sig_mirror(), sig2=sig_cleave(), **kw)
    p2 = F.build_rows(lambda **k: cell(p2=True, **k), sig1=sig_mirror(), sig2=sig_cleave(), **kw)
    F.finish("barma_wijaya", CW, CH, base, moves, p2=p2)


if __name__ == "__main__":
    main()
