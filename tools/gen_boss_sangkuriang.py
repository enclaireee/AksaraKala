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
SKIN2 = mat("C4663A", "4A1A14", "8A3C24", "F0A870")
BLADE = mat("A8B4BC", "3A4452", "6E7A88", "E8F0F2")
ROCK = mat("8A8478", "2A2630", "5E5A58", "C0B8A8")
SWEAT = (hexc("5A8CB0"), hexc("9ADCF4"), hexc("CFF2FF"), hexc("FFFFFF"))
SUN = hexc("FFA040")
LOG = mat("8A5C34", "2E1C16", "5E3C22", "BC8A58")


def wrap(p, e, h):
    """A leather bracer on the forearm."""
    p.cap(e[0] + (h[0] - e[0]) * 0.35, e[1] + (h[1] - e[1]) * 0.35, e[0] + (h[0] - e[0]) * 0.85, e[1] + (h[1] - e[1]) * 0.85, 4.0, 3.6, SAR)


def sangku(p, breath=0, crouch=0, lean=0.0, legs=(0, 0), st=(0, 0), head=(0, 0), arm_l=REST_L, arm_r=REST_R, ang=-80, reach=(12, 34),
           glow=False, mouth=1, orb=0.0, tilt=False, sway=0, kneel=False, form=1, adze=False, rock=None):
    """A broad, muscular young giant: wide stance, heavy shoulders, big head."""
    f2 = form == 2
    skin = SKIN2 if f2 else SKIN
    if f2:      # dawn panic: hunched and heaving
        crouch, lean = crouch + 1, lean + 0.8
    b = breath + crouch
    cx = CW / 2 + lean
    hx, hy = cx + 1 + head[0] + lean * 0.4, 16 + b + head[1]
    sy = 28 + b
    # the perahu on his back
    p.poly([(cx - 22, 20 + b), (cx - 15, 24 + b), (cx - 8, 34 + b), (cx - 10, 47 + b), (cx - 17, 41 + b), (cx - 23, 30 + b)], HULL[2])
    p.line([(cx - 22, 21 + b), (cx - 15, 25 + b), (cx - 9, 35 + b)], HULL[3], 2.0)
    p.line([(cx - 22, 31 + b), (cx - 17, 41 + b), (cx - 11, 47 + b)], HULL[1], 2.0)
    p.cap(cx - 19, 24 + b, cx - 14, 40 + b, 1.0, 1.0, HULL[0], rim=False)
    F.legs_draw(p, cx, 45 + crouch, legs, SAR, skin, skin, wid=5.6, spread=8.6, tw=(5.8, 5.0, 4.6, 3.6), st=st, kneel=kneel)
    p.trap([(43 + crouch, cx - 11, cx + 11), (52, cx - 13 + sway * 0.4, cx + 13 + sway * 0.4), (58, cx - 13.5 + sway, cx + 13.5 + sway)], SAR)
    for i in range(6):
        p.line([(cx - 10 + i * 4, 48), (cx - 11 + i * 4.2 + sway * 0.4, 56)], SAR[1], 1.0)
    tor = p.trap([(24 + b, cx - 8, cx + 8), (28 + b, cx - 14, cx + 14), (36 + b, cx - 13, cx + 13), (46 + b, cx - 9.5, cx + 9.5)], skin)
    p.line([(cx - 11, 34 + b), (cx - 1, 37 + b)], skin[1], 1.0, tor)
    p.line([(cx + 1, 37 + b), (cx + 11, 34 + b)], skin[1], 1.0, tor)
    for i in (-1, 1):
        p.line([(cx + i * 3, 40 + b), (cx + i * 4, 44 + b)], skin[1], 1.0, tor)
    p.line([(cx, 38 + b), (cx, 45 + b)], skin[1], 1.0, tor)
    p.trap([(43 + b, cx - 10, cx + 10), (47 + b, cx - 10, cx + 10)], IKET)
    p.ell(cx, 45 + b, 2.4, 2.4, GOLD)
    # head: a square jaw, heavy brows
    p.cap(hx - 1, hy + 3, cx, 28 + b, 4.0, 4.6, skin)
    p.cap(hx - 3, hy - 4, hx - 13 - sway, hy + 8, 3.6, 2.2, HAIR)
    p.ell(hx, hy - 0.8, 7.0, 6.8, skin)
    p.trap([(hy + 1.4, hx - 6.6, hx + 6.6), (hy + 6.4, hx - 4.8, hx + 4.8)], skin)
    if f2:      # hair wild: spikes flying out of the iket
        for ax, ay, bx_, by_ in ((-3, -6, -10, -13), (0, -7, -2, -16), (3, -6, 6, -15), (5, -5, 11, -11), (-5, -3, -13, -5)):
            p.cap(hx + ax, hy + ay, hx + bx_ - sway, hy + by_, 2.4, 0.9, HAIR)
    p.trap([(hy - 7.6, hx - 6.8, hx + 6.8), (hy - 3, hx - 7.4, hx + 7.4)], HAIR)
    p.trap([(hy - 4.8, hx - 7.2, hx + 7.2), (hy - 2.2, hx - 7.4, hx + 7.4)], IKET)
    ec = hexc("FF5A1C") if f2 else (hexc("FFD070") if glow else hexc("F4E8D0"))
    for side in (-1, 1):
        ex, ey = hx + side * 3.0 + 1, hy + 0.8
        p.line([(ex - side * 3, ey - 3.0), (ex + side * 2.2, ey - 1.4)], HAIR[1], 2.0)
        if tilt:
            p.line([(ex - 1.5, ey + 0.4), (ex + 1.5, ey + 0.4)], HAIR[1], 1.0)
        else:
            p.ell(ex, ey, 1.7, 1.3, (HAIR[1], ec, ec, ec), rim=False)
            p.dot(ex + 0.6, ey, hexc("1A0C08"))
    p.line([(hx + 0.6, hy + 2), (hx + 1.4, hy + 3.6)], skin[1], 1.0)
    if f2:      # strain veins and sweat
        p.line([(hx + 2, hy - 3.6), (hx + 3.6, hy - 5.4)], hexc("D8402A"), 1.0)
        for sx_, sy_ in ((hx - 5, hy + 2.5), (hx + 6.5, hy + 4), (cx + 6, 34 + b), (cx - 6, 38 + b)):
            p.ell(sx_, sy_ + (b > 5) * 0, 1.1, 1.5, SWEAT, rim=False)
    mh = 0.6 + mouth * 0.7
    p.trap([(hy + 5, hx - 2.6 + 1, hx + 2.6 + 1), (hy + 5 + mh * 2, hx - 2 + 1, hx + 2 + 1)], (skin[0], hexc("2A0C10"), hexc("4A1418"), hexc("4A1418")))
    shl, shr = (cx - 14.5, sy), (cx + 14.5, sy)
    el, hl = F.M(cx, b, sy - 1, 1.1, arm_l[0]), F.M(cx, b, sy - 1, 1.1, arm_l[1])
    er, hr = F.M(cx, b, sy - 1, 1.1, arm_r[0]), F.M(cx, b, sy - 1, 1.1, arm_r[1])
    F.limb_arm(p, shl, el, hl, skin, skin, 3.8, 1.3)
    wrap(p, el, hl)
    p.ell(shl[0], shl[1], 6.0, 5.2, skin)
    p.cap(hl[0] - 3, hl[1] - 1, hl[0] + 3, hl[1] - 1, 1.2, 1.2, GOLD)
    if orb > 0:
        F.orb(p, hl[0], hl[1] - 7, 1.6 + orb * 3.4, (SAR[1], ACC, hexc("FFB060"), hexc("FFF0C0")))
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    if rock and rock[2] >= 1:
        boulder(p, cx + rock[0], rock[1], rock[2])
    elif adze:
        adze_draw(p, hr[0], hr[1], ang, reach[0], reach[1])
    elif not rock:
        bx, by = hr[0] - ca * reach[0], hr[1] - sa * reach[0]
        tx, ty = hr[0] + ca * reach[1] * 0.75, hr[1] + sa * reach[1] * 0.75
        p.cap(bx, by, tx, ty, 4.0, 4.6, LOG)
        p.ell(tx, ty, 4.0, 4.4, LOG)
        for t in (0.35, 0.7):
            p.cap(bx + (tx - bx) * t - sa * 3.5, by + (ty - by) * t + ca * 3.5, bx + (tx - bx) * t + sa * 3.5, by + (ty - by) * t - ca * 3.5, 0.9, 0.9, (LOG[1],) * 4, rim=False)
    F.limb_arm(p, shr, er, hr, skin, skin, 4.0, 1.3)
    wrap(p, er, hr)
    p.ell(shr[0], shr[1], 6.0, 5.2, skin)
    if f2:      # sleeves torn: ragged cloth stubs on both upper arms
        for sh_, d_ in ((shl, -1), (shr, 1)):
            p.cap(sh_[0], sh_[1] - 1, sh_[0] + d_ * 1.5, sh_[1] + 6, 5.4, 4.8, SAR)
            for k, ln in enumerate((4, 2, 5)):
                p.cap(sh_[0] - 3 + k * 3, sh_[1] + 5, sh_[0] - 3.5 + k * 3, sh_[1] + 6 + ln, 1.6, 0.7, SAR)


def boulder(p, x, y, r):
    p.ell(x, y, r, r * 0.92, ROCK)
    p.ell(x - r * 0.35, y - r * 0.35, r * 0.4, r * 0.3, (ROCK[3],) * 4, rim=False)
    p.line([(x + r * 0.1, y - r * 0.2), (x + r * 0.4, y + r * 0.3)], ROCK[0], 1.0)
    p.dot(x - r * 0.4, y + r * 0.35, ROCK[1])


def adze_draw(p, hx, hy, ang, back, fwd):
    """A wood-carving adze: a haft with a steel blade set across the end, the edge facing forward."""
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    nx, ny = -sa, ca
    if nx < 0:
        nx, ny = -nx, -ny
    ex, ey = hx + ca * fwd, hy + sa * fwd
    p.cap(hx - ca * back, hy - sa * back, ex, ey, 1.9, 1.9, LOG)
    p.poly([(ex - ca * 3.5, ey - sa * 3.5), (ex + ca * 2.5, ey + sa * 2.5), (ex + ca * 2.5 + nx * 8, ey + sa * 2.5 + ny * 8), (ex - ca * 3.5 + nx * 6, ey - sa * 3.5 + ny * 6)], BLADE[2])
    p.poly([(ex - ca * 3.5, ey - sa * 3.5), (ex + ca * 0.5, ey + sa * 0.5), (ex + ca * 0.5 + nx * 7, ey + sa * 0.5 + ny * 7), (ex - ca * 3.5 + nx * 6, ey - sa * 3.5 + ny * 6)], BLADE[3])
    p.line([(ex + ca * 2.2 + nx * 3, ey + sa * 2.2 + ny * 3), (ex + ca * 2.2 + nx * 7.6, ey + sa * 2.2 + ny * 7.6)], BLADE[1], 1.0)
    p.cap(ex - nx * 0.5 - ca * 1.5, ey - ny * 0.5 - sa * 1.5, ex - nx * 0.5 + ca * 1.5, ey - ny * 0.5 + sa * 1.5, 2.2, 2.2, SAR)


T = (IKET[3], IKET[2], IKET[1])


def rim_light(im, col):
    """Sun-orange rim: lit-edge pixels (outline or empty above / to the right) take the dawn colour."""
    px = im.load()
    out = im.copy()
    po = out.load()
    for y in range(im.height):
        for x in range(im.width):
            c = px[x, y]
            if c[3] == 0 or c[:3] == F.OUTLINE[:3]:
                continue
            def open_(xx, yy):
                if not (0 <= xx < im.width and 0 <= yy < im.height):
                    return True
                n = px[xx, yy]
                return n[3] == 0 or n[:3] == F.OUTLINE[:3]
            if open_(x, y - 1) or open_(x + 1, y):
                po[x, y] = F.mix(c, col, 0.62)[:3] + (c[3],)
    return out


def chips_fx(base, n, lean):
    """Wood chips in a cone off the adze blade on impact (n 1..3, 2 chunks each)."""
    def fn(p, front):
        if base:
            base(p, front)
        if front and n:
            tx = CW / 2 + lean + 16
            for dx, dy, r in ((4, -3, 1.9), (9, -9, 1.7), (11, -2, 1.6), (1, -11, 1.5), (14, -7, 1.4), (-5, -7, 1.5))[:n * 2]:
                p.ell(tx + dx, 59 + dy, r, r, LOG)
    return fn


def cell(**kw):
    rings = kw.pop("rings", 0)
    streak = kw.pop("streak", False)
    chips = kw.pop("chips", 0)
    base = F.streaks(T) if streak else None
    im = F.draw_cell(CW, CH, sangku, extra=chips_fx(base, chips, kw.get("lean", 0.0)) if chips else base, rings=rings, ring_tones=T, **kw)
    return rim_light(im, SUN) if kw.get("form") == 2 else im


def cell2(**kw):
    return cell(form=2, **kw)


# sig1 "adze chop": two-handed overhead chop, wood chips on impact (col 5)
SIG1 = [dict(arm_r=((15, 38), (15, 42)), arm_l=((0, 40), (9, 43)), ang=-60, reach=(6, 14), adze=True, glow=True),
        dict(arm_r=((17, 30), (14, 22)), arm_l=((4, 30), (10, 24)), ang=-105, reach=(6, 14), adze=True, breath=-2, lean=-2.0, glow=True),
        dict(arm_r=((16, 26), (12, 16)), arm_l=((2, 26), (8, 19)), ang=-122, reach=(6, 13), adze=True, breath=-3, lean=-3.0, glow=True, mouth=2),
        dict(arm_r=((17, 36), (14, 34)), arm_l=((4, 38), (9, 37)), ang=58, reach=(6, 11), adze=True, crouch=5, lean=3.0, chips=3, glow=True, mouth=2),
        dict(arm_r=((17, 36), (14, 35)), arm_l=((4, 38), (9, 38)), ang=60, reach=(6, 11), adze=True, crouch=4, lean=2.0, chips=2, mouth=1)]
SIG1_T = [0, 2, 3, 5, 7]
# sig2 "boulder heave": squat, lift it overhead, heave it forward (gone by col 7, leaving the hand at col 6)
SIG2 = [dict(rock=(8, 50, 0), glow=True),
        dict(rock=(9, 52, 7), crouch=9, lean=1.0, arm_r=((12, 36), (10, 36)), arm_l=((-2, 36), (5, 36)), glow=True, mouth=2),
        dict(rock=(7, 6, 6.5), breath=-2, lean=-1.0, arm_r=((16, 28), (9, 14)), arm_l=((4, 26), (2, 14)), glow=True, mouth=3),
        dict(rock=(22, 16, 6.5), crouch=1, lean=2.0, arm_r=((20, 22), (19, 20)), arm_l=((8, 22), (13, 20)), glow=True, mouth=3, streak=True),
        dict(rock=(30, 14, 6.5), crouch=2, lean=3.0, arm_r=((20, 24), (21, 22)), arm_l=((8, 24), (14, 22)), glow=True, mouth=2),
        dict(rock=(36, 14, 0), crouch=3, lean=3.0, arm_r=((18, 34), (20, 36)), arm_l=((6, 34), (12, 38)), mouth=1)]
SIG2_T = [0, 2, 4, 5, 6, 7]


def main():
    kw = dict(ang_up=-95, strike=(35, 50), kang=-84, kreach=(4, 26))
    s1, s2 = F.expand(SIG1, 8, SIG1_T, ["io", "io", "in", "io"]), F.expand(SIG2, 8, SIG2_T, ["in", "io", "out", "out", "out"])
    base, moves = F.build_rows(cell, sig1=s1, sig2=s2, **kw)
    p2 = F.build_rows(cell2, sig1=s1, sig2=s2, **kw)
    F.finish("sangkuriang", CW, CH, base, moves, p2=p2)


if __name__ == "__main__":
    main()
