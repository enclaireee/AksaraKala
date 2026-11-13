#!/usr/bin/env python3
"""Batara Kala, final boss, redrawn (2026-11-12 boss redesign; the template for the other nine bosses).

Outputs assets/art/enemies/batara_kala.png and batara_kala_moves.png: 4x4 sheets of 96x80 cells (was 48x62), the
contract of components/enemy_art.gd:
  base:  row 0 idle, row 1 walk, row 2 telegraph (cols 0-1 wind-up, 2-3 strike), row 3 hurt
  moves: row 0 cast, row 1 slam, row 2 dash, row 3 roar
Painted with the rounded-form painter of tools/gen_portraits.py: a giant in ash-violet with a brass makuta, an
eclipsed sun behind his head, tusks, and the bedama (a broad cleaver). tools/gen_bosses.py and gen_boss_moves.py
no longer write these two files. Also writes tools/boss_kala_preview.png.
Run: python3 tools/gen_boss_kala.py
"""
import math
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_portraits as gp
from gen_portraits import Paint, mat, hexc, GOLD, STEEL, WOOD, RED
from PIL import Image
import pixlib as P

CW, CH = 96, 80      # 16 px of room each side of the 64 px figure for the bedama and the rings
PADX = 16
OUT = os.path.join(gp.ROOT, "assets", "art", "enemies")
HIDE = mat("6A5A9A", "241A40", "443868", "9C8CC8")      # ash-violet skin
MANE = mat("2A2244", "0E0A1C", "1A1430", "4E4478")
CLOTH = mat("7A2440", "2A0C1C", "521830", "A8405C")
FANG = mat("F0E8D4", "6A6070", "B8AEA8", "FFFFFF")
EMBER = hexc("FF8A3C")
CORONA = hexc("FFD070")


def kala(p, breath=0, lean=0.0, crouch=0, arm_r=((56, 50), (55, 62)), arm_l=((8, 50), (10, 62)), blade=-58.0,
         legs=(0, 0), mouth=1, eyes="open", halo=1.0, orb=0.0, head=(0, 0), dim=False):
    """One pose. Arms are (elbow, hand) points; blade is the bedama's angle in degrees (y down); legs are lifts."""
    b = breath + crouch
    cx = 32 + lean
    hx, hy = cx + head[0] + lean * 0.6, 24 + b + head[1]
    # the eclipsed sun
    if halo > 0:
        p.glow(hx, hy - 3, 27, CORONA, 1.3 * halo)
        for a in range(0, 360, 30):
            ca, sa = math.cos(math.radians(a)), math.sin(math.radians(a))
            p.line([(hx + ca * 15, hy - 3 + sa * 15), (hx + ca * (18.5 + (a // 30 % 2) * 2), hy - 3 + sa * (18.5 + (a // 30 % 2) * 2))], CORONA, 1.0)
    p.ell(hx, hy - 3, 14.5, 14.5, (MANE[0], MANE[0], MANE[1], MANE[2]))
    # mane
    for dx, dy, r in ((-10, -2, 6), (10, -2, 6), (-8, -9, 5.5), (8, -9, 5.5), (0, -12, 6), (-12, 6, 4.5), (12, 6, 4.5)):
        p.ell(hx + dx, hy + dy, r, r + 0.8, MANE)
    # legs
    for i, (hipx, footx) in enumerate(((cx - 7, cx - 8), (cx + 7, cx + 8))):
        lift = legs[i]
        p.ell(footx, 76.5 - lift, 6.2, 2.8, HIDE)
        p.cap(hipx, 62 + crouch, footx, 73 - lift, 6.0, 5.0, HIDE)
        p.cap(footx - 4, 70 - lift, footx + 4, 70 - lift, 1.3, 1.3, GOLD)
    # dodot
    sk = p.trap([(56 + b, cx - 13, cx + 13), (62 + crouch, cx - 15, cx + 15), (70, cx - 16.5, cx + 16.5)], CLOTH)
    p.poly([(cx - 4, 57 + b), (cx + 4, 57 + b), (cx + 5.5, 73), (cx, 76), (cx - 5.5, 73)], GOLD[2])
    p.line([(cx - 4, 57 + b), (cx - 5.5, 73), (cx, 76)], GOLD[3], 1.0)
    p.line([(cx + 4, 57 + b), (cx + 5.5, 73), (cx, 76)], GOLD[0], 1.0)
    p.dot(cx, 64, RED[2]); p.dot(cx, 69, RED[2])
    for i in range(9):
        p.dot(cx - 15 + i * 3.8, 68.6, GOLD[2], sk)
    # torso
    tor = p.trap([(32 + b, cx - 14, cx + 14), (36 + b, cx - 18, cx + 18), (44 + b, cx - 18.5, cx + 18.5), (56 + b, cx - 13, cx + 13), (60 + b, cx - 12.5, cx + 12.5)], HIDE)
    p.line([(cx - 11, 45 + b), (cx - 2, 47 + b)], HIDE[1], 1.0, tor)
    p.line([(cx + 2, 47 + b), (cx + 11, 45 + b)], HIDE[1], 1.0, tor)
    p.line([(cx, 48 + b), (cx, 56 + b)], HIDE[1], 1.0, tor)
    neck = [(cx + math.cos(math.radians(a)) * 11, 35 + b + math.sin(math.radians(a)) * 6.5) for a in range(10, 171, 16)]
    p.line(neck, GOLD[2], 2.0, tor)
    p.line(neck, GOLD[3], 1.0, tor)
    p.ell(cx, 42.5 + b, 3.0, 3.2, GOLD)
    p.dot(cx, 42.5 + b, EMBER)
    belt = p.trap([(55 + b, cx - 13.2, cx + 13.2), (59.5 + b, cx - 13, cx + 13)], GOLD, rim=True)
    p.ell(cx, 57.3 + b, 3.2, 3.0, RED)
    # head
    p.ell(hx, hy, 10.2, 10.4, HIDE, lift=0.05)
    p.trap([(hy - 10.5, hx - 8, hx + 8), (hy - 5.5, hx - 9.8, hx + 9.8)], GOLD)
    for dx, hgt in ((-6, 4), (0, 8), (6, 4)):
        p.poly([(hx + dx - 2.4, hy - 10), (hx + dx, hy - 10 - hgt), (hx + dx + 2.4, hy - 10)], GOLD[2])
        p.line([(hx + dx - 2.4, hy - 10), (hx + dx, hy - 10 - hgt)], GOLD[3], 1.0)
    p.ell(hx, hy - 8, 1.8, 1.8, RED)
    for side in (-1, 1):
        ex, ey = hx + side * 4.4, hy - 1.2
        p.line([(ex - side * 3.2, ey - 3.4), (ex + side * 2.6, ey - 4.6)], MANE[0], 2.0)        # heavy brow
        if eyes == "shut":
            p.line([(ex - 2.4, ey), (ex + 2.4, ey)], MANE[0], 1.0)
        else:
            p.ell(ex, ey, 2.7, 2.5, (MANE[0], hexc("E8B050"), hexc("FFE9A0"), hexc("FFFFFF")))
            p.dot(ex + 0.3, ey, hexc("C8201C"))
            if eyes == "glow":
                p.glow(ex, ey, 5.0, EMBER, 1.0)
    p.line([(hx - 1.6, hy + 2.6), (hx + 1.6, hy + 2.6)], HIDE[1], 1.0)                          # broad nose
    p.dot(hx - 2.2, hy + 3.4, HIDE[0]); p.dot(hx + 2.2, hy + 3.4, HIDE[0])
    mh = 1.4 + mouth * 1.4
    p.trap([(hy + 4.8, hx - 6, hx + 6), (hy + 4.8 + mh * 2, hx - 5, hx + 5)], (MANE[0], hexc("3A0C18"), hexc("5A1420"), hexc("5A1420")))
    for dx in (-3, -1, 1, 3):
        p.line([(hx + dx, hy + 5.6), (hx + dx, hy + 6.4)], FANG[2], 1.0)
    for side in (-1, 1):                                                                        # tusks
        p.poly([(hx + side * 4.2, hy + 5.4 + mh * 1.4), (hx + side * 6.6, hy + 5.4 + mh * 1.4), (hx + side * 6.2, hy + 0.6 + mh)], FANG[2])
        p.line([(hx + side * 6.6, hy + 5.4 + mh * 1.4), (hx + side * 6.2, hy + 0.6 + mh)], FANG[3] if side < 0 else FANG[1], 1.0)
    # arms: the left one (screen left) may hold an orb; the right one holds the bedama
    (el, hl), (er, hr) = arm_l, arm_r
    el, hl = (el[0] + lean, el[1] + b), (hl[0] + lean, hl[1] + b)
    er, hr = (er[0] + lean, er[1] + b), (hr[0] + lean, hr[1] + b)
    shl, shr = (cx - 17.5, 37 + b), (cx + 17.5, 37 + b)
    p.cap(el[0], el[1], hl[0], hl[1], 5.2, 4.6, HIDE)
    p.cap(shl[0], shl[1], el[0], el[1], 6.8, 5.4, HIDE)
    p.ell(el[0], el[1], 3.6, 3.6, (HIDE[2], HIDE[1], HIDE[2], HIDE[2]), rim=False)
    p.cap(hl[0] - 3.5, hl[1] - 4, hl[0] + 3.5, hl[1] - 4, 1.5, 1.5, GOLD)
    p.ell(hl[0], hl[1] + 1, 4.8, 4.8, HIDE)
    if orb > 0:
        p.glow(hl[0], hl[1] - 9, 5 + orb * 7, hexc("FF5AA0"), 1.0)
        p.ell(hl[0], hl[1] - 9, 1.5 + orb * 2.5, 1.5 + orb * 2.5, (hexc("7A1450"), hexc("C8327A"), hexc("FF7AB8"), hexc("FFFFFF")))
    # bedama
    ca, sa = math.cos(math.radians(blade)), math.sin(math.radians(blade))
    gx, gy = hr[0] + ca * 4, hr[1] + sa * 4
    tx, ty = hr[0] + ca * 38, hr[1] + sa * 38
    nx, ny = -sa, ca
    pts = [(gx - nx * 2, gy - ny * 2), (gx + ca * 20 - nx * 6.5, gy + sa * 20 - ny * 6.5), (tx - nx * 5, ty - ny * 5), (tx + ca * 3 + nx * 2, ty + sa * 3 + ny * 2),
           (gx + ca * 26 + nx * 2.6, gy + sa * 26 + ny * 2.6), (gx + nx * 2.2, gy + ny * 2.2)]
    bl = p.poly(pts, STEEL[2])
    p.line(pts[:3], STEEL[3], 1.0)
    p.line(pts[3:] + [pts[0]], STEEL[1], 1.0)
    p.line([(gx + ca * 3, gy + sa * 3), (gx + ca * 30 - nx * 1.5, gy + sa * 30 - ny * 1.5)], STEEL[1], 1.0, bl)
    p.line([pts[2], pts[3]], STEEL[0], 1.0)
    for d in (9, 15, 21):
        p.dot(gx + ca * d - nx * 2.2, gy + sa * d - ny * 2.2, EMBER, bl)
    p.cap(gx - nx * 4.5, gy - ny * 4.5, gx + nx * 4.5, gy + ny * 4.5, 1.7, 1.7, GOLD)
    p.cap(hr[0] - ca * 5, hr[1] - sa * 5, gx, gy, 1.6, 1.6, WOOD)
    p.cap(er[0], er[1], hr[0], hr[1], 5.2, 4.6, HIDE)
    p.cap(shr[0], shr[1], er[0], er[1], 6.8, 5.4, HIDE)
    p.ell(er[0], er[1], 3.6, 3.6, (HIDE[2], HIDE[1], HIDE[2], HIDE[2]), rim=False)
    p.cap(hr[0] - 3.5 * nx - ca * 4, hr[1] - 3.5 * ny - sa * 4, hr[0] + 3.5 * nx - ca * 4, hr[1] + 3.5 * ny - sa * 4, 1.5, 1.5, GOLD)
    p.ell(hr[0], hr[1], 4.8, 4.8, HIDE)


def cell(**kw):
    extra = kw.pop("extra", None)
    p = Paint(CW, CH, 1.0, PADX, 0.0)
    if extra:
        extra(p, False)
    kala(p, **kw)
    if extra:
        extra(p, True)
    return p.image()


def rings(r):
    def fn(p, front):
        if front:
            for a in range(0, 360, 6):
                p.pix.setdefault((int(PADX + 32 + math.cos(math.radians(a)) * r), int(30 + math.sin(math.radians(a)) * r * 0.85)), CORONA[:3] + (200,))
    return fn


def streaks(p, front):
    if not front:
        for y in (30, 40, 50, 60):
            p.line([(-14, y), (12, y)], hexc("9C8CC8")[:3] + (150,), 1.0)


UP = ((58, 34), (56, 20))        # the bedama arm raised
REST = ((56, 50), (55, 62))


def build():
    base = [
        [cell(breath=(0, 0, 1, 1)[f], halo=(0.8, 0.9, 1.0, 0.9)[f]) for f in range(4)],
        [cell(breath=(0, 1, 0, 1)[f], lean=1.0, legs=((3, 0), (0, 0), (0, 3), (0, 0))[f], halo=0.9) for f in range(4)],
        [cell(arm_r=UP, blade=-100, eyes="glow", mouth=2, breath=-1),
         cell(arm_r=((59, 33), (58, 19)), blade=-112, eyes="glow", mouth=2, breath=-1, lean=-1.0),
         cell(arm_r=((57, 52), (60, 60)), blade=24, eyes="glow", mouth=2, crouch=2, lean=2.0),
         cell(arm_r=((56, 54), (58, 63)), blade=40, eyes="glow", mouth=2, crouch=2, lean=2.0)],
        [cell(eyes="shut", mouth=0, head=(-2, 1), lean=-2.0, halo=0.25, arm_r=((57, 52), (59, 64)), blade=-40),
         cell(eyes="shut", mouth=2, head=(-1, 0), lean=-1.0, halo=0.6),
         cell(eyes="shut", mouth=0, head=(-2, 2), lean=-2.0, crouch=2, halo=0.2, arm_r=((57, 53), (59, 65)), blade=-30),
         cell(eyes="shut", mouth=0, head=(-2, 2), lean=-2.0, crouch=3, halo=0.15, arm_r=((57, 54), (59, 66)), blade=-20)],
    ]
    cast_l = (((6, 44), (5, 32)), ((5, 42), (4, 28)), ((5, 41), (4, 26)), ((6, 44), (8, 34)))
    moves = [
        [cell(arm_l=cast_l[f], orb=(0.2, 0.6, 1.0, 0.3)[f], eyes="glow", mouth=1) for f in range(4)],
        [cell(arm_r=UP, arm_l=((6, 34), (8, 20)), blade=-96, eyes="glow", mouth=2, breath=-2),
         cell(arm_r=((59, 32), (57, 17)), arm_l=((5, 32), (7, 17)), blade=-100, eyes="glow", mouth=2, breath=-3),
         cell(arm_r=((56, 54), (52, 66)), arm_l=((8, 54), (12, 66)), blade=70, eyes="glow", mouth=2, crouch=4, extra=rings(20)),
         cell(arm_r=((56, 54), (52, 66)), arm_l=((8, 54), (12, 66)), blade=70, mouth=1, crouch=3, extra=rings(29))],
        [cell(lean=1.0, crouch=2, arm_r=((56, 48), (60, 56)), blade=-8, eyes="glow"),
         cell(lean=3.0, crouch=2, arm_r=((57, 47), (62, 54)), blade=-4, eyes="glow", legs=(3, 0), extra=streaks),
         cell(lean=4.0, crouch=2, arm_r=((57, 47), (62, 54)), blade=0, eyes="glow", legs=(0, 3), extra=streaks),
         cell(lean=2.0, crouch=1, arm_r=((56, 50), (60, 58)), blade=10)],
        [cell(head=(0, 1), mouth=1, arm_l=((6, 50), (6, 62)), breath=1),
         cell(head=(0, -2), mouth=3, eyes="glow", arm_l=((4, 46), (2, 56)), arm_r=((60, 46), (62, 56)), blade=-60, breath=-1, extra=rings(16)),
         cell(head=(0, -2), mouth=3, eyes="glow", arm_l=((4, 46), (2, 56)), arm_r=((60, 46), (62, 56)), blade=-60, breath=-1, extra=rings(24)),
         cell(head=(0, -1), mouth=2, eyes="glow", arm_l=((5, 48), (4, 59)), arm_r=((59, 48), (60, 59)), blade=-70, extra=rings(30))],
    ]
    # boss fights v7: row 4 rise (entrance), 5 kneel, 6 death (fades out)
    down = dict(eyes="shut", mouth=0, lean=-1.0, arm_r=((57, 54), (59, 66)), blade=-20)
    kn = [bow(cell(head=(-1, 1 + f // 2), crouch=(3, 5, 7, 8)[f], halo=(0.5, 0.35, 0.2, 0.12)[f], **down), (0.95, 0.86, 0.78, 0.74)[f]) for f in range(4)]
    moves.append([bow(cell(crouch=8, halo=0.1, head=(-1, 2), **down), 0.7), bow(cell(crouch=5, halo=0.4, eyes="glow", mouth=1), 0.86),
                  cell(crouch=2, halo=0.8, eyes="glow", mouth=2, extra=rings(18)), cell(halo=1.0, eyes="glow", mouth=3, breath=-1, extra=rings(28))])
    moves.append(kn)
    moves.append([fade(bow(cell(head=(-1, 2), crouch=8, halo=h, **down), k), a) for h, a, k in ((0.5, 1.0, 0.72), (0.9, 0.75, 0.68), (1.0, 0.45, 0.62), (1.0, 0.2, 0.56))])
    return base, moves


def bow(img, sy):
    """Sink about the feet (the painter's own crouch only bends the knees a little)."""
    return P.squash(img, sy, 1.0 + (1.0 - sy) * 0.25)


def fade(img, k):
    out = img.copy()
    out.putalpha(img.getchannel("A").point(lambda v: int(v * k)))
    return out


def sheet(rows):
    sh = Image.new("RGBA", (CW * 4, CH * len(rows)), (0, 0, 0, 0))
    for r, row in enumerate(rows):
        for c, im in enumerate(row):
            sh.paste(im, (c * CW, r * CH))
    return sh


def main():
    base, moves = build()
    a, b = sheet(base), sheet(moves)
    a.save(os.path.join(OUT, "batara_kala.png"))
    b.save(os.path.join(OUT, "batara_kala_moves.png"))
    prev = Image.new("RGBA", (CW * 8 + 12, CH * 4 + 8), (52, 44, 66, 255))
    prev.paste(a, (4, 4), a)
    prev.paste(b, (CW * 4 + 8, 4), b)
    prev.resize((prev.width * 3, prev.height * 3), Image.NEAREST).save(os.path.join(gp.ROOT, "tools", "boss_kala_preview.png"))
    print("wrote batara_kala sheets (%dx%d cells)" % (CW, CH))


if __name__ == "__main__":
    main()
