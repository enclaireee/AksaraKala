#!/usr/bin/env python3
"""Batara Kala, final boss, on the 8-frame contract (v9) with two extra forms.

Writes assets/art/enemies/batara_kala{,_moves,_p2,_p2_moves,_p3,_p3_moves}.png: base sheets 8x4 cells (768x320), moves
sheets 8x9 (768x720), cells 96x80. Rows: idle, walk, telegraph, hurt / cast, slam, dash, roar, rise, kneel, death, sig1 (devour
lunge), sig2 (eclipse shield). One drawing function, kala(form=1|2|3): phase 2 = total eclipse, molten cracks, cracked crown, big
tusks; phase 3 = near-cosmic violet-black with stars, wild red corona, a shadow arm, white-hot eyes, hourglass sand.
Painter and the shared pose table come from gen_boss_faceless_captain.py (gen_portraits.py dropped Paint). Also writes
tools/boss_kala_preview.png.   Run: python3 tools/gen_boss_kala.py
"""
import math
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_boss_faceless_captain as F
from gen_boss_faceless_captain import Paint, mat, hexc, GOLD, STEEL, WOOD, RED, ease, expand
from PIL import Image
import pixlib as P

CW, CH = 96, 80
PADX = 16
OUT = F.OUT
HIDES = {1: mat("6A5A9A", "241A40", "443868", "9C8CC8"), 2: mat("6A5A9A", "241A40", "443868", "9C8CC8"),
         3: mat("2C2048", "08040E", "160E2A", "5A4896")}
MANES = {1: mat("2A2244", "0E0A1C", "1A1430", "4E4478"), 3: mat("140C26", "04020A", "0A0618", "30285A")}
CLOTHS = {1: mat("7A2440", "2A0C1C", "521830", "A8405C"), 3: mat("4A1634", "14040E", "2E0C20", "7A2A58")}
FANG = mat("F0E8D4", "6A6070", "B8AEA8", "FFFFFF")
EMBER = hexc("FF8A3C")
CORONA = hexc("FFD070")
WHITEGOLD = hexc("FFF4C0")
CRIMSON = hexc("E0283C")
SHIELD = mat("2A2040", "0A0614", "181030", "4A3C78")
# eclipse-shield sockets, cell pixels (unflipped), fixed across the hold frames
SHIELD_C = (PADX + 32, 47)
SOCKETS = ((PADX + 32, 41), (PADX + 26, 52), (PADX + 38, 52))
STARS = ((-9, 38), (4, 41), (13, 36), (-14, 47), (8, 49), (-3, 53), (12, 57), (-10, 60), (2, 64), (-6, 72), (9, 71), (-15, 66), (15, 68), (0, 29), (-18, 33), (17, 45))


def kala(p, form=1, breath=0, lean=0.0, crouch=0, arm_r=((56, 50), (55, 62)), arm_l=((8, 50), (10, 62)), blade=-58.0,
         legs=(0, 0), st=(0, 0), mouth=1, eyes="open", halo=1.0, orb=0.0, head=(0, 0), sway=0.0, shield=0.0, bite=False):
    """One pose. Arms are (elbow, hand) points on the 64 px figure grid; blade = bedama angle (deg, y down); legs = lifts."""
    HIDE, MANE, CLOTH = HIDES[form], MANES[3 if form == 3 else 1], CLOTHS[3 if form == 3 else 1]
    b = breath + crouch
    cx = 32 + lean
    hx, hy = cx + head[0] + lean * 0.6, 24 + b + head[1]
    hy0 = hy - 3
    # the eclipsed sun behind the head
    if halo > 0:
        if form == 1:
            p.glow(hx, hy0, 27, CORONA, 1.3 * halo)
            rays, base_r, tones = 12, 15, (CORONA, CORONA)
        elif form == 2:
            p.glow(hx, hy0, 30, CORONA, 1.5 * halo)
            rays, base_r, tones = 16, 15, (CORONA, WHITEGOLD)
        else:
            p.glow(hx, hy0, 30, CRIMSON, 1.4 * halo)
            rays, base_r, tones = 14, 15, (CRIMSON, hexc("FF7A6A"))
        for i in range(rays):
            a = math.radians(i * 360 / rays + (sway * 2 if form == 3 else 0))
            if form == 1:
                ln = 4 + (i % 2) * 2.5
            elif form == 2:
                ln = 7 + (i % 2) * 6
            else:
                ln = 6 + ((i * 7 + int(abs(sway) * 3)) % 5) * 3.2
            ln *= (0.7 + 0.3 * halo)
            w = 0.16 if form == 1 else 0.2
            tip = (hx + math.cos(a) * (base_r + ln), hy0 + math.sin(a) * (base_r + ln))
            pts = [(hx + math.cos(a - w) * (base_r - 1), hy0 + math.sin(a - w) * (base_r - 1)), tip,
                   (hx + math.cos(a + w) * (base_r - 1), hy0 + math.sin(a + w) * (base_r - 1))]
            p.poly(pts, tones[0])
            if ln > 5:
                p.line([(hx + math.cos(a) * (base_r + 1), hy0 + math.sin(a) * (base_r + 1)), (hx + math.cos(a) * (base_r + ln * 0.6), hy0 + math.sin(a) * (base_r + ln * 0.6))], tones[1], 1.0)
    disc = (MANE[0], MANE[0], MANE[1], MANE[2]) if form == 1 else (hexc("05030A"), hexc("05030A"), hexc("0C0818"), hexc("1A1030"))
    p.ell(hx, hy0, 14.5, 14.5, disc)
    if form >= 2:   # a thin corona ring where the black disc meets the flares
        for a in range(0, 360, 20):
            p.dot(hx + math.cos(math.radians(a)) * 14, hy0 + math.sin(math.radians(a)) * 14, WHITEGOLD if form == 2 else hexc("FF7A6A"))
    # mane
    for dx, dy, r in ((-10, -2, 6), (10, -2, 6), (-8, -9, 5.5), (8, -9, 5.5), (0, -12, 6), (-12, 6, 4.5), (12, 6, 4.5)):
        sw = sway * 0.5 if dy > 0 else sway * 0.25
        p.ell(hx + dx + sw, hy + dy, r, r + 0.8, MANE)
    # legs
    for i, (hipx, footx) in enumerate(((cx - 7, cx - 8 + st[0] * 0.5), (cx + 7, cx + 8 + st[1] * 0.5))):
        lift = legs[i]
        p.ell(footx, 76.5 - lift, 6.2, 2.8, HIDE)
        p.cap(hipx, 62 + crouch, footx, 73 - lift, 6.0, 5.0, HIDE)
        p.cap(footx - 4, 70 - lift, footx + 4, 70 - lift, 1.3, 1.3, GOLD)
    # dodot
    hem = sway * 0.6
    sk = p.trap([(56 + b, cx - 13, cx + 13), (62 + crouch, cx - 15, cx + 15), (70, cx - 16.5 + hem, cx + 16.5 + hem)], CLOTH)
    p.poly([(cx - 4, 57 + b), (cx + 4, 57 + b), (cx + 5.5 + hem, 73), (cx + hem, 76), (cx - 5.5 + hem, 73)], GOLD[2])
    p.line([(cx - 4, 57 + b), (cx - 5.5 + hem, 73), (cx + hem, 76)], GOLD[3], 1.0)
    p.line([(cx + 4, 57 + b), (cx + 5.5 + hem, 73), (cx + hem, 76)], GOLD[0], 1.0)
    p.dot(cx, 64, RED[2]); p.dot(cx, 69, RED[2])
    for i in range(9):
        p.dot(cx - 15 + i * 3.8 + hem * 0.8, 68.6, GOLD[2], sk)
    if form == 3:   # hourglass sand: a small hourglass on the cloth, grains dripping off the hem
        for hxo in (-10.0, 10.0):
            x = cx + hxo
            p.poly([(x - 2.5, 62), (x + 2.5, 62), (x, 65), ], GOLD[3])
            p.poly([(x - 2.5, 68), (x + 2.5, 68), (x, 65), ], GOLD[2])
            p.line([(x - 2.5, 61.5), (x + 2.5, 61.5)], GOLD[0], 1.0)
            p.line([(x - 2.5, 68.5), (x + 2.5, 68.5)], GOLD[0], 1.0)
        ph = int(abs(sway) * 2 + abs(breath) * 2)
        for k, gx in enumerate((-13, -5, 3, 11, 15)):
            gy = 71 + (ph + k * 2) % 6
            p.line([(cx + gx + hem, gy), (cx + gx + hem, gy + 1)], GOLD[3] if k % 2 else GOLD[2], 1.0)
    # torso
    tor = p.trap([(32 + b, cx - 14, cx + 14), (36 + b, cx - 18, cx + 18), (44 + b, cx - 18.5, cx + 18.5), (56 + b, cx - 13, cx + 13), (60 + b, cx - 12.5, cx + 12.5)], HIDE)
    p.line([(cx - 11, 45 + b), (cx - 2, 47 + b)], HIDE[1], 1.0, tor)
    p.line([(cx + 2, 47 + b), (cx + 11, 45 + b)], HIDE[1], 1.0, tor)
    p.line([(cx, 48 + b), (cx, 56 + b)], HIDE[1], 1.0, tor)
    if form == 2:   # molten cracks
        for pts in (((cx - 14, 37 + b), (cx - 10, 41 + b), (cx - 12, 46 + b), (cx - 7, 50 + b)), ((cx + 13, 36 + b), (cx + 9, 42 + b), (cx + 12, 47 + b), (cx + 7, 52 + b)),
                    ((cx + 3, 56 + b), (cx + 6, 60 + b))):
            p.line(pts, EMBER, 1.0, tor)
            p.line(pts[:2], WHITEGOLD, 1.0, tor)
    if form == 3:   # stars
        for sx, sy in STARS:
            x, y = int(cx + sx * 0.5 + p.ox), int(sy + (b if sy < 62 else 0))
            if (x, y) in tor:
                p.pix[(x, y)] = WHITEGOLD if (sx + sy) % 3 else hexc("A8C8FF")
    neck = [(cx + math.cos(math.radians(a)) * 11, 35 + b + math.sin(math.radians(a)) * 6.5) for a in range(10, 171, 16)]
    p.line(neck, GOLD[2], 2.0, tor)
    p.line(neck, GOLD[3], 1.0, tor)
    p.ell(cx, 42.5 + b, 3.0, 3.2, GOLD)
    p.dot(cx, 42.5 + b, EMBER if form < 3 else CRIMSON)
    p.trap([(55 + b, cx - 13.2, cx + 13.2), (59.5 + b, cx - 13, cx + 13)], GOLD, rim=True)
    p.ell(cx, 57.3 + b, 3.2, 3.0, RED)
    # head
    hd = p.ell(hx, hy, 10.2, 10.4, HIDE, lift=0.05)
    if form == 2:
        p.line([(hx - 5, hy - 5), (hx - 3, hy - 1), (hx - 5, hy + 3)], EMBER, 1.0, hd)
        p.line([(hx + 6, hy - 4), (hx + 4, hy)], EMBER, 1.0, hd)
    p.trap([(hy - 10.5, hx - 8, hx + 8), (hy - 5.5, hx - 9.8, hx + 9.8)], GOLD)
    for dx, hgt in ((-6, 4), (0, 8), (6, 4)):
        if form >= 2 and dx == 6:
            hgt = 1.5       # the broken peak
        p.poly([(hx + dx - 2.4, hy - 10), (hx + dx, hy - 10 - hgt), (hx + dx + 2.4, hy - 10)], GOLD[2])
        p.line([(hx + dx - 2.4, hy - 10), (hx + dx, hy - 10 - hgt)], GOLD[3], 1.0)
    p.ell(hx, hy - 8, 1.8, 1.8, RED)
    if form >= 2:   # the crack through the makuta, molten
        p.line([(hx + 1, hy - 17), (hx - 1, hy - 13), (hx + 1, hy - 9), (hx - 1, hy - 6)], hexc("120A18"), 1.0)
        p.dot(hx - 1, hy - 11, EMBER)
        p.dot(hx + 1, hy - 8, WHITEGOLD)
    for side in (-1, 1):
        ex, ey = hx + side * 4.4, hy - 1.2
        p.line([(ex - side * 3.2, ey - 3.4), (ex + side * 2.6, ey - 4.6)], MANE[0], 2.0)
        if eyes == "shut":
            p.line([(ex - 2.4, ey), (ex + 2.4, ey)], MANE[0], 1.0)
        else:
            if form == 3:
                p.ell(ex, ey, 2.7, 2.5, (MANE[0], hexc("FFFFFF"), hexc("FFFFFF"), hexc("FFFFFF")))
                p.glow(ex, ey, 5.5, hexc("FFFFFF"), 1.0)
            else:
                p.ell(ex, ey, 2.7, 2.5, (MANE[0], hexc("E8B050"), hexc("FFE9A0"), hexc("FFFFFF")))
                p.dot(ex + 0.3, ey, hexc("C8201C"))
                if eyes == "glow" or form == 2:
                    p.glow(ex, ey, 5.0, EMBER, 1.0)
    p.line([(hx - 1.6, hy + 2.6), (hx + 1.6, hy + 2.6)], HIDE[1], 1.0)
    p.dot(hx - 2.2, hy + 3.4, HIDE[0]); p.dot(hx + 2.2, hy + 3.4, HIDE[0])
    mh = 1.4 + mouth * 1.4
    p.trap([(hy + 4.8, hx - 6, hx + 6), (hy + 4.8 + mh * 2, hx - 5, hx + 5)], (MANE[0], hexc("3A0C18"), hexc("5A1420"), hexc("5A1420")))
    for dx in (-3, -1, 1, 3):
        p.line([(hx + dx, hy + 5.6), (hx + dx, hy + 6.4)], FANG[2], 1.0)
    if mouth >= 3:    # lower teeth at the bottom of a gaping jaw
        for dx in (-3, 0, 3):
            p.line([(hx + dx, hy + 4.8 + mh * 2 - 1), (hx + dx, hy + 4.8 + mh * 2 - 2.4)], FANG[2], 1.0)
    tk = 1.0 if form == 1 else 1.55
    for side in (-1, 1):                                                                        # tusks
        top = hy + 5.4 + mh * 1.4 - 4.8 * tk
        p.poly([(hx + side * 4.2, hy + 5.4 + mh * 1.4), (hx + side * (6.6 + 0.5 * (tk - 1)), hy + 5.4 + mh * 1.4), (hx + side * (6.2 + 1.2 * (tk - 1)), top)], FANG[2])
        p.line([(hx + side * 6.6, hy + 5.4 + mh * 1.4), (hx + side * (6.2 + 1.2 * (tk - 1)), top)], FANG[3] if side < 0 else FANG[1], 1.0)
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
    if form == 2:
        p.line([(el[0] - 2, el[1] - 1), (hl[0], hl[1] - 2)], EMBER, 1.0)
    if form == 3:   # the shadow arm: dark tongues licking off elbow and hand
        for i, (ox_, oy_, ln) in enumerate(((-4, -2, 7), (-2, 3, 6), (3, -5, 8), (-6, 4, 5), (1, 6, 6))):
            w = int(abs(sway) * 2) + i
            ax_, ay_ = (el[0] + hl[0]) / 2 + ox_, (el[1] + hl[1]) / 2 + oy_
            pts = [(ax_ - 2, ay_ + 2), (ax_ + ((w % 3) - 1) * 2, ay_ - ln), (ax_ + 2.5, ay_ + 2)]
            p.poly(pts, hexc("1C0C34") if i % 2 else hexc("3A1C5C"))
        p.glow(hl[0], hl[1], 9, hexc("5A2CA0"), 0.8)
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
        p.dot(gx + ca * d - nx * 2.2, gy + sa * d - ny * 2.2, EMBER if form < 3 else CRIMSON, bl)
    p.cap(gx - nx * 4.5, gy - ny * 4.5, gx + nx * 4.5, gy + ny * 4.5, 1.7, 1.7, GOLD)
    p.cap(hr[0] - ca * 5, hr[1] - sa * 5, gx, gy, 1.6, 1.6, WOOD)
    p.cap(er[0], er[1], hr[0], hr[1], 5.2, 4.6, HIDE)
    p.cap(shr[0], shr[1], er[0], er[1], 6.8, 5.4, HIDE)
    p.ell(er[0], er[1], 3.6, 3.6, (HIDE[2], HIDE[1], HIDE[2], HIDE[2]), rim=False)
    p.cap(hr[0] - 3.5 * nx - ca * 4, hr[1] - 3.5 * ny - sa * 4, hr[0] + 3.5 * nx - ca * 4, hr[1] + 3.5 * ny - sa * 4, 1.5, 1.5, GOLD)
    p.ell(hr[0], hr[1], 4.8, 4.8, HIDE)
    if bite:   # the clamp: chunky flash chips around the jaws
        for dx, dy, s in ((-11, 9, 3), (11, 9, 3), (-9, 15, 2), (9, 15, 2), (0, 18, 2)):
            F.rect(p, hx + dx, hy + dy, hx + dx + s, hy + dy + s, WHITEGOLD)
            F.rect(p, hx + dx + s - 1, hy + dy + s - 1, hx + dx + s, hy + dy + s, CORONA)
    if shield > 0:     # the eclipse shield, in absolute cell coords so the sockets never move
        draw_shield(p, shield, form)


def draw_shield(p, s, form):
    """Dark disc, gold corona rim, three empty sockets. s 0..1 grows it. Sockets sit at SOCKETS (cell px) when s = 1."""
    cx, cy = SHIELD_C[0] - PADX, SHIELD_C[1]      # figure grid
    r = 13.5 * s
    rim = (CORONA, WHITEGOLD, GOLD[3]) if form < 3 else (CRIMSON, hexc("FF7A6A"), hexc("FFB0A0"))
    p.ell(cx, cy, r + 2.2, r + 2.2, mat("D2A446", "5E3E1C", "9A6E2A", "FAE08A") if form < 3 else mat("B02838", "40101C", "801C30", "FF7A6A"))
    p.ell(cx, cy, r, r, SHIELD)
    if s >= 0.75:
        for a in range(0, 360, 45):     # corona nubs on the rim
            ca, sa = math.cos(math.radians(a)), math.sin(math.radians(a))
            p.poly([(cx + ca * (r + 1.5) - sa * 2, cy + sa * (r + 1.5) + ca * 2), (cx + ca * (r + 5.5), cy + sa * (r + 5.5)),
                    (cx + ca * (r + 1.5) + sa * 2, cy + sa * (r + 1.5) - ca * 2)], rim[0])
        p.ell(cx, cy, r, r, SHIELD)
        for sx, sy in SOCKETS:
            x, y = sx - PADX, sy
            p.ell(x, y, 3.6, 3.6, mat("D2A446", "5E3E1C", "9A6E2A", "FAE08A"))
            p.ell(x, y, 2.3, 2.3, (hexc("05030A"), hexc("05030A"), hexc("0C0818"), hexc("0C0818")), rim=False)


# ---------------------------------------------------------------- adapter from the shared pose table
def ap(pt):
    """Shared pose-table arm point (dx from centre, y with shoulder at 27) -> this giant's figure grid (shoulder at 37)."""
    return (32 + pt[0] * 1.75, 37 + (pt[1] - 27) * 1.25)


def bow(img, sy):
    return P.squash(img, sy, 1.0 + (1.0 - sy) * 0.25)


def make_cell(form=1, **kw):
    rings = kw.pop("rings", 0)
    streak = kw.pop("streak", False)
    kneel = kw.pop("kneel", False)
    tilt = kw.pop("tilt", False)
    glow = kw.pop("glow", False)
    kw.pop("reach", None); kw.pop("chips", None)
    ang = kw.pop("ang", -58.0)
    sway = kw.get("sway", 0.0)
    k = dict(form=form, blade=ang, eyes="shut" if tilt else ("glow" if glow else "open"), halo=1.0 + 0.1 * sway - (0.45 if tilt else 0))
    for key in ("breath", "crouch", "lean", "legs", "st", "head", "mouth", "orb", "sway", "shield", "bite", "halo", "eyes", "blade"):
        if key in kw:
            k[key] = kw[key]
    for key in ("arm_l", "arm_r"):
        if key in kw:
            k[key] = tuple(ap(pt) for pt in kw[key])
    if kneel:
        k["crouch"] = k.get("crouch", 0) * 0.55
    if k.get("shield"):
        k["shield"] = float(k["shield"])
    p = Paint(CW, CH, 1.0, PADX, 0.0)
    tone = {1: (CORONA, GOLD[2], GOLD[1]), 2: (WHITEGOLD, CORONA, GOLD[2]), 3: (hexc("FF7A6A"), CRIMSON, hexc("7A1028"))}[form]
    if streak:
        dark = streak == "dark"
        F.streaks((hexc("3A2A5C"), hexc("1E1438"), hexc("0E0A1C")) if dark else (hexc("9C8CC8"), hexc("6A5A9A"), hexc("443868")))(p, False)
    kala(p, **k)
    if rings:
        F.ground_rings(tone, CW // 2, CW, CH)(p, rings, True)
    im = p.image()
    return bow(im, 0.86) if kneel else im


def cell_for(form):
    return lambda **kw: make_cell(form=form, **kw)


# sig1 "devour lunge": coil back, drop forward with the jaws gaping, lunge with a dark streak, clamp at col 6, recover
SIG1 = [dict(arm_r=((15, 38), (19, 44)), ang=-30, crouch=1, lean=-2.0, mouth=1, glow=True),
        dict(arm_r=((15, 40), (18, 48)), ang=-10, crouch=3, lean=-3.0, head=(-1, 2), mouth=3, glow=True),
        dict(arm_r=((16, 40), (20, 46)), ang=-5, crouch=5, lean=2.0, head=(3, 5), mouth=5, glow=True, arm_l=((-15, 40), (-18, 46))),
        dict(arm_r=((16, 38), (22, 42)), ang=0, crouch=4, lean=5.0, head=(4, 6), mouth=5, glow=True, streak="dark", arm_l=((-16, 38), (-12, 36))),
        dict(arm_r=((16, 38), (22, 42)), ang=0, crouch=4, lean=8.0, head=(5, 6), mouth=5, glow=True, streak="dark", arm_l=((-16, 38), (-12, 36))),
        dict(arm_r=((16, 38), (22, 42)), ang=0, crouch=4, lean=9.0, head=(5, 7), mouth=0, glow=True, bite=True, arm_l=((-16, 38), (-12, 36))),
        dict(arm_r=((15, 40), (19, 46)), ang=5, crouch=2, lean=3.0, head=(2, 2), mouth=2)]
# sig2 "eclipse shield": raise it (cols 0-3), hold it still (cols 4-7, loop): lean 0, no bob, arms at the rim
HOLD = dict(shield=1.0, lean=0.0, breath=0, crouch=0, arm_l=((-12, 39), (-8, 41)), arm_r=((12, 39), (8, 41)), ang=-80, glow=True, mouth=1)
SIG2 = [dict(arm_r=((15, 38), (19, 44)), crouch=1, glow=True),
        dict(arm_r=((15, 40), (12, 44)), arm_l=((-15, 40), (-12, 44)), crouch=2, shield=0.35, glow=True, mouth=2, ang=-70),
        dict(arm_r=((14, 40), (10, 42)), arm_l=((-14, 40), (-10, 42)), crouch=1, shield=0.7, glow=True, mouth=2, ang=-76),
        dict(HOLD, shield=0.9)]
SIG2_T = [0, 1, 2, 3]


def sig2_frames():
    fr = expand(SIG2, 4, SIG2_T, ["out", "out", "io"])
    hold = [dict(HOLD, head=(0, 0), halo=1.0 + 0.1 * math.sin(math.pi * f / 2)) for f in range(4)]
    for f, h in enumerate(hold):
        h["sway"] = 1.2 * math.sin(math.pi * f / 2)
    return fr + hold


def draw8(cell, frames):
    out = []
    for kw in frames:
        kw = dict(kw)
        a = kw.pop("_a", 1.0)
        im = cell(**kw)
        out.append(F.fade(im, a) if a < 1.0 else im)
    return out


def build(form):
    cell = cell_for(form)
    # blade rest angle -58 as the old pose table; the shared table passes ang only for the strokes
    kw = dict(ang_up=-100, strike=(24, 40), kang=-30, kreach=(0, 0), karm=((13, 42), (14, 52)))
    s1 = expand(SIG1, 8, [0, 1, 2, 3, 4, 5, 7], ["out", "io", "out", "io", "in", "io"])
    base, moves = F.build_rows(cell, sig1=s1, **kw)
    moves[8] = draw8(cell, sig2_frames())
    return base, moves


def main():
    sheets = {}
    for form, suf in ((1, ""), (2, "_p2"), (3, "_p3")):
        base, moves = build(form)
        a, b = F.sheet(base, CW, CH), F.sheet(moves, CW, CH)
        a.save(os.path.join(OUT, "batara_kala%s.png" % suf))
        b.save(os.path.join(OUT, "batara_kala%s_moves.png" % suf))
        sheets[form] = (a, b)
    pw = sum(s.width for s in sheets[1]) + 12
    prev = Image.new("RGBA", (CW * 8 * 3 + 16, (CH * 4 + CH * 9) + 12), (52, 44, 66, 255))
    for i, form in enumerate((1, 2, 3)):
        a, b = sheets[form]
        prev.paste(a, (4 + i * (CW * 8 + 4), 4), a)
        prev.paste(b, (4 + i * (CW * 8 + 4), CH * 4 + 8), b)
    prev.resize((prev.width * 2, prev.height * 2), Image.NEAREST).save(os.path.join(F.ROOT, "tools", "boss_kala_preview.png"))
    print("wrote batara_kala sheets, forms 1-3 (%dx%d cells)" % (CW, CH))


if __name__ == "__main__":
    main()
