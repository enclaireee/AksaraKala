#!/usr/bin/env python3
"""Modular building kit for the Phase 6c towns (zones/buildings.gd, architecture.md 9 "Buildings").

Writes assets/art/buildings/<kit>/{roof_<kind>_<p>, wall_<p>, extras}.png for the kits sunda, galuh, mataram, kidul, pasar
and tools/buildings_preview.png (about 12 composed houses per kit).  Pure stdlib, same PNG writer and tone ramps as
gen_world_props.py.  3/4 top-down view, 1 px outline, 4 tones per material, light from the top-left.

KIT LAYOUT (shared with zones/buildings.gd, keep both in step)
  roof sheet  64x56 = nine-slice.  Columns: left cap 24 | middle 16 | right cap 24.  Rows: top 24 | middle 16 | bottom 16.
              The middle column and row repeat; every pattern is periodic in 16 px.  A roof for a footprint of W x D tiles is
              16*W+16 wide (8 px overhang each side) and 24+16*max(0,D-3)+16 high; its bottom edge sits 20 px above the
              footprint's south edge, so it overlaps the top 4 px of the 24 px front wall.  From D >= 6 the roof is two tiers:
              a 1-slice skirt of full width, and an upper tier inset 1 tile (joglo: 2 tiles, joglo_up sheet).
  wall sheet  128x96, 16x24 cells, 8 columns (see CELLS).  <kit>/wall_<p>.png, one per palette p.
  extras      192x48, 24x24 cells, 8 columns (see EXTRAS), palette independent.
Run: python3 tools/gen_buildings.py   (also: --preview KIT --out FILE --scale N to look at one kit)
"""
import math
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gen_world_props import Img, hexc, tones, ground_shadow  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "art", "buildings")
PREVIEW = os.path.join(ROOT, "tools", "buildings_preview.png")
CLEAR = (0, 0, 0, 0)

CW, TH, MH, BH = 24, 24, 16, 16     # roof slice sizes
WH = 24                              # front wall height (px); cells in the wall sheet are 16 x 24
ROOF_W, ROOF_H = CW * 2 + 16, TH + MH + BH

# wall sheet cells (col, row)
CELLS = {
    "wall_a": (0, 0), "wall_b": (1, 0), "wall_c": (2, 0), "post_l": (3, 0), "post_r": (4, 0), "stilt": (5, 0), "step": (6, 0),
    "pend_a": (7, 0),
    "closed_0": (0, 1), "closed_1": (1, 1), "closed_2": (2, 1), "closed_3": (3, 1),
    "open_0": (4, 1), "open_1": (5, 1), "open_2": (6, 1), "open_3": (7, 1),
    "win_0": (0, 2), "win_1": (1, 2), "win_2": (2, 2), "lit_0": (3, 2), "lit_1": (4, 2), "lit_2": (5, 2),
    "wide_l": (6, 2), "wide_r": (7, 2),
    "wide_m": (0, 3), "pend_post": (1, 3), "pile": (2, 3), "ladder": (3, 3),
}
EXTRAS = ["lamp", "pot_a", "pot_b", "broom", "jar", "wood", "cage", "bench",
          "moss_0", "moss_1", "moss_2", "finial_a", "finial_b", "net", "basket", "sack"]

# ---------------------------------------------------------------- palettes
def P(name, roof, wall, trim, stone, accent="FFD36A"):
    return dict(name=name, roof=hexc(roof), wall=hexc(wall), trim=hexc(trim), stone=hexc(stone), accent=hexc(accent))


KITS = {
    "sunda": dict(
        roofs=["julang", "jolopong", "parahu"], wall="bilik", front="wall",
        pals=[P("ijuk_cream", "4A4A56", "E4D3A0", "7A5232", "8D8A80"),
              P("alang_brown", "A8977A", "A8774A", "5E3B22", "7C786E"),
              P("ijuk_green", "5A4A42", "C79A5C", "3E6B58", "8A8478"),
              P("rumbia_gold", "C2A058", "D9C48E", "8A3E32", "9A9488")]),
    "galuh": dict(
        roofs=["joglo", "limasan", "kampung"], wall="timber", front="wall",
        pals=[P("red_teak", "B8503A", "B07A44", "5B3A22", "A29A88", "F2C85A"),
              P("brown_lime", "86593C", "E0D2AC", "5A3A28", "A29A88"),
              P("slate_teak", "656B78", "A27240", "8E3A2E", "9A9488"),
              P("orange_white", "D27A42", "EEE6D0", "3E6482", "B2AA96")]),
    "mataram": dict(
        roofs=["joglo", "limasan", "kampung"], wall="timber", front="wall",
        pals=[P("maroon_teak", "9C3F2E", "86562C", "C79A3A", "8A8272", "F2C85A"),
              P("sepia_teak", "755038", "9A6A3A", "2E5A5A", "8A8272"),
              P("dark_teak", "4E4E58", "A5733F", "A8452F", "7E7868"),
              P("terracotta", "C4643C", "BE8C52", "3C4A6A", "9A9282")]),
    "kidul": dict(
        roofs=["nipah_a", "nipah_b", "nipah_c"], wall="bilik", front="wall",
        pals=[P("nipah_gold", "A08E4C", "BDAC88", "4E7C7C", "7C8890"),
              P("nipah_grey", "827E72", "8E6C46", "A8503A", "6E7A80"),
              P("nipah_green", "6E7E48", "D0BE8C", "36607E", "7C8890"),
              P("nipah_dark", "5E4A36", "A4A088", "C4703C", "6E7A80")]),
    "pasar": dict(
        roofs=["awning"], wall="counter", front="warung",
        pals=[P("red", "BC4036", "A8743E", "5A3A22", "8A8478", "F4EAD0"),
              P("blue", "3E64A4", "A8743E", "5A3A22", "8A8478", "F4EAD0"),
              P("yellow", "DCAA3C", "9A6A3A", "4E321E", "8A8478", "FFF2C8"),
              P("green", "3E8E52", "A8743E", "5A3A22", "8A8478", "F4EAD0")]),
}

ROOFS = {   # ridge = y of the ridge line in the 64x56 sheet, hip = slant width, wing, prow, verge band, mat = texture
    "julang":   dict(mat="fibre", ridge=10, wing=14, verge=True),
    "jolopong": dict(mat="fibre", ridge=12, verge=True),
    "parahu":   dict(mat="fibre", ridge=8, prow=True),
    "leuit":    dict(mat="fibre", ridge=4, wing=7, verge=True),
    "joglo":    dict(mat="tile", ridge=12, hip=24),
    "joglo_up": dict(mat="tile", ridge=6, hip=22),
    "limasan":  dict(mat="tile", ridge=10, hip=18),
    "kampung":  dict(mat="tile", ridge=6, verge=True),
    "nipah_a":  dict(mat="nipah", ridge=3, verge=True),
    "nipah_b":  dict(mat="nipah", ridge=9, hip=16),
    "nipah_c":  dict(mat="nipah", ridge=10, prow=True, verge=True),
    "awning":   dict(mat="cloth", ridge=11, flat=True),
}
LEUIT_KITS = ["sunda"]


# ---------------------------------------------------------------- helpers
def H(a, b=0, c=0):
    h = ((a * 73856093) ^ (b * 19349663) ^ (c * 83492791)) & 0xFFFFFFFF
    h = (h * 2654435761) & 0xFFFFFFFF
    return ((h >> 8) & 0xFFFF) / 65535.0


def clampi(v, lo, hi):
    return max(lo, min(hi, v))


def rect(img, x, y, w, h, c):
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            img.put(xx, yy, c)


def inner_outline(img, k=0.34):
    """1 px outline drawn inside the silhouette (keeps the canvas size). Edges of the canvas count as empty."""
    o = Img(img.w, img.h)
    for y in range(img.h):
        for x in range(img.w):
            c = img.p[y][x]
            if c[3] == 0:
                continue
            edge = False
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                if img.get(x + dx, y + dy)[3] == 0:
                    edge = True
            if edge:
                o.p[y][x] = (int(c[0] * k), int(c[1] * k), min(255, int(c[2] * k * 1.15)), 255)
            else:
                o.p[y][x] = c
    return o


def outline_pad(img, k=0.34):
    s = img.padded(1)
    return inner_outline(s, k)


def sub(img, x, y, w, h):
    o = Img(w, h)
    for yy in range(h):
        for xx in range(w):
            o.p[yy][xx] = img.get(x + xx, y + yy)
    return o


def mix(a, b, t):
    return tuple(int(a[i] * (1 - t) + b[i] * t) for i in range(3)) + (255,)


# ---------------------------------------------------------------- roofs
def tex_tone(mat, u, v, x, y):
    """Tone index 0..3 for the front slope. u,v are phase coordinates (period 16)."""
    ux, vy = u % 16, v % 16
    if mat == "tile":
        row, r = vy // 8, vy % 8
        tx = (ux + (4 if row else 0)) % 8
        if tx == 0:
            return 0
        if r == 7:
            return 0
        if r == 6:
            return 1
        if r == 0:
            return 3 if tx < 6 else 2
        if tx <= 1 or (r <= 2 and tx <= 4):
            return 3 if r < 4 else 2
        return 2 if tx < 6 else 1
    if mat == "fibre":          # ijuk: long vertical strokes, 1 px wide, grouped by tone; faint courses every 16 rows
        g = ux // 3
        base = 1 if H(g, 2, 7) < 0.45 else 2
        off = int(H(ux, 1, 17) * 7)
        seg = (vy + off) // 7
        f = H(ux, seg, 5)
        t = base
        if f < 0.22:
            t = base - 1
        elif f > 0.8:
            t = base + 1
        if (vy + off) % 7 == 6 and f < 0.5:
            t = max(0, t - 1)           # stroke tips
        if vy % 16 == 15:
            t = max(0, t - 1) if H(ux, 3, 4) < 0.7 else t
        elif vy % 16 == 0:
            t = min(3, t + 1)
        return clampi(t, 0, 3)
    if mat == "nipah":          # long leaf strands, slanted, in 16 px bands
        r, b = vy, 0
        g = (ux + r // 4) % 16 // 2
        f = H(g, 3, 5)
        t = 2 if f < 0.45 else (3 if f < 0.7 else 1)
        if r % 8 == 7:
            t = 0 if H(ux, r, 1) < 0.7 else 1
        elif r % 8 in (0, 1) and H(ux // 2, r, 3) < 0.4:
            t = 3
        flen = 13 + int(H(g, 7, 4) * 3)
        if r >= flen:
            t = 0 if r > flen else 1
        return t
    if mat == "cloth":
        s = (ux // 8) % 2
        t = 3 if s == 0 else 2
        if vy % 8 == 7:
            t -= 1
        return clampi(t, 0, 3)
    return 2


def silhouette(kind, x, RW, RH):
    """(top, bottom, ridge) pixel rows of the roof at column x of the 64x56 sheet (or any assembled width)."""
    pr = ROOFS[kind]
    xl = min(x, RW - 1 - x)
    ridge = pr["ridge"]
    top = ridge - 3
    bot = RH - 1
    if pr.get("wing"):                  # julang ngapak: the ends pinch into upswept wings
        w = pr["wing"]
        if xl < w:                      # a separate lower wing plane: straight slanted edges, tip flared up
            f = (w - xl) / float(w)
            top += int(round(f * 9))
            bot -= int(round(f * 12))
    if pr.get("hip"):
        hx = pr["hip"]
        if xl < hx:
            top = ridge - 2 + int((hx - xl) * 0.72)
    if pr.get("prow"):                  # parahu kumureb: bowed hull, ends lifted
        if xl < 22:
            top = ridge - 3 + int(round(13 * ((22 - xl) / 22.0) ** 1.5))
        if xl < 8:
            bot -= int(round(((8 - xl) / 8.0) ** 2 * 5))
        ridge = top + 3                 # the ridge rim follows the hull curve
    if pr.get("flat"):
        top = ridge - 1
    return top, bot, ridge


def render_roof(kind, pal, m=1, n=1):
    pr = ROOFS[kind]
    mat = pr["mat"]
    RW = CW * 2 + 16 * m
    RH = TH + 16 * n + BH
    tn = tones(pal["roof"])
    trim = tones(pal["trim"])
    img = Img(RW, RH)
    for y in range(RH):
        for x in range(RW):
            top, bot, ridge = silhouette(kind, x, RW, RH)
            if y < top or y > bot:
                continue
            left = x < RW / 2
            xl = min(x, RW - 1 - x)
            u = x - CW
            v = y - TH
            if mat in ("fibre", "nipah") and y > bot - 4:   # ragged thatch fringe
                k = (y - (bot - 4)) / 4.0
                if H(u % 16, y, 9) < k * 0.5:
                    continue
            if mat == "cloth" and y > bot - 4:   # scalloped valance
                ph = (u % 8) / 8.0
                depth = 1 + int(3 * (1 - abs(ph * 2 - 1)))
                if y > bot - 4 + depth - 1 + 0 and y > bot - depth + 0:
                    pass
                if y > bot - 4 + depth:
                    continue
            # side strips and verge
            tone = None
            hip = pr.get("hip")
            if hip and y >= top and y < top + 3 and xl < hip:
                tone = 3 if left else 0     # hip rafter along the slant
            elif pr.get("verge") and xl <= 1:
                tone = 3 if (left and xl == 0) else (2 if left else 1)
                col = trim[tone]
                img.put(x, y, col)
                continue
            elif pr.get("wing") and xl < pr["wing"]:
                tone = tex_tone(mat, u + 5, v, x, y)       # wing plane: its own pitch, so lit on the left, shaded on the right
                tone = clampi(tone + (1 if left else -1), 0, 3)
                if xl == pr["wing"] - 1:
                    tone = 0                # visible break in pitch
                elif xl == pr["wing"] - 2:
                    tone = 3 if left else 1
            elif y < ridge:
                tone = 1                    # back slope
                if mat == "tile" and (x + y) % 2 == 0 and y > top:
                    tone = 2 if False else 1
            elif y == ridge:
                tone = 3
            elif y == ridge + 1:
                tone = 2 if mat != "cloth" else 3
            elif y == ridge + 2 and mat != "cloth":
                tone = 0
            else:
                tone = tex_tone(mat, u, v, x, y)
                if hip and xl < 4:
                    tone = clampi(tone + (1 if left else -1), 0, 3)
                    if xl == 3:
                        tone = 0 if not left else 3
            if y >= bot - 1:
                tone = min(tone, 1)
            if mat == "fibre" and y == bot - 1:
                tone = 0                    # dark eave line under the thatch
            if mat == "cloth":
                s = ((u // 8) % 2)
                base = pal["roof"] if s == 0 else hexc("F0E8D2")
                tt = tones(base)
                col = tt[clampi(tone, 0, 3)]
                if y < ridge + 3:
                    col = tt[3] if y == ridge else tt[2]
                img.put(x, y, col)
                continue
            img.put(x, y, tn[clampi(tone, 0, 3)])
    # ridge ties on thatch, ridge-cap rhythm on tile
    for x in range(RW):
        top, bot, ridge = silhouette(kind, x, RW, RH)
        xl = min(x, RW - 1 - x)
        if pr.get("hip") and xl < pr["hip"]:
            continue
        if mat == "tile" and (x - CW) % 8 == 0 and img.get(x, ridge)[3]:
            img.put(x, ridge, tn[2])
            img.put(x, ridge + 1, tn[0])
        if mat == "fibre" and (x - CW) % 8 == 4 and img.get(x, ridge + 1)[3]:
            img.put(x, ridge + 1, tn[3])
    return inner_outline(img)


# ---------------------------------------------------------------- walls
def lift(tile, mode="copy"):
    """16x16 art -> 16x24 cell. copy: the new top 8 rows repeat row 0 (walls). over: transparent top (overlays)."""
    o = Img(16, WH)
    if mode == "copy":
        for y in range(8):
            o.p[y] = list(tile.p[0])
    o.blit(tile, 0, WH - 16)
    return o


def wall_tile(style, pal, variant):
    """16x24 front-wall tile: roof shadow at the top, wall body, 3 rows stone plinth."""
    tn = tones(pal["wall"])
    tr = tones(pal["trim"])
    st = tones(pal["stone"])
    img = Img(16, WH)
    for y in range(WH - 3):
        for x in range(16):
            yy = y - (WH - 16)      # 16-row pattern coordinates; negative above the old top
            t = 2
            if style == "bilik":
                if variant == "a":      # basket weave in 4x4 blocks
                    bx, by = x // 4, yy // 4
                    if (bx + by) % 2 == 0:
                        t = 3 if x % 2 == 0 else 2
                    else:
                        t = 3 if yy % 2 == 0 else 2
                    if x % 4 == 3 or yy % 4 == 3:
                        t = 0
                elif variant == "b":    # vertical bamboo slats with a rail
                    t = 3 if x % 4 == 0 else (2 if x % 4 in (1, 2) else 1)
                    if yy in (6, 7):
                        img.put(x, y, tr[2] if yy == 6 else tr[1])
                        continue
                else:                   # diagonal twill
                    d = (x + yy) % 4
                    t = 3 if d == 0 else (2 if d in (1, 2) else 0)
            elif style == "timber":
                if variant == "a":      # vertical planks
                    t = 2
                    if x % 4 == 0:
                        t = 1
                    elif x % 4 == 1:
                        t = 3 if H(x // 4, yy // 5, 3) < 0.5 else 2
                    if H(x // 4, yy // 3, 7) < 0.14 and x % 4 == 2:
                        t = 1
                elif variant == "b":    # gebyok-like carved panels in a frame
                    px = x % 8
                    t = 2
                    if px == 0 or yy in (-5, 12) or yy == 5:
                        img.put(x, y, tr[1] if px == 0 or yy in (-5, 12) else tr[2])
                        continue
                    cx, cy = abs(px - 4), abs(yy - 9)
                    if cx + cy == 2 and 1 <= px <= 7 and yy > 5:
                        t = 3
                    elif cx + cy == 3:
                        t = 1
                    elif yy < 5:
                        t = 3 if px in (2, 6) else 2
                else:                   # horizontal planks
                    t = 3 if yy % 4 == 0 else (1 if yy % 4 == 3 else 2)
                    if H(x // 5, yy // 4, 11) < 0.12:
                        t = 1
            if y < 3:
                t = max(0, t - 2)       # deep roof shadow
            elif y < 6:
                t = max(0, t - 1)
            img.put(x, y, tn[clampi(t, 0, 3)])
    for y in range(WH - 3, WH):    # stone plinth
        for x in range(16):
            t = 3 if y == WH - 3 else (2 if y == WH - 2 else 1)
            if x % 8 == 0 or (y == WH - 2 and x % 8 == 4 and H(x // 8, 1) < 0.5):
                t = 0
            img.put(x, y, st[t])
    return img


def counter_tile(pal, variant):
    """Warung counter: dark interior with hanging goods above a plank counter."""
    tr = tones(pal["trim"])
    wd = tones(pal["wall"])
    img = Img(16, 16)
    for y in range(16):
        for x in range(16):
            if y < 9:
                img.put(x, y, tuple(int(c * (0.7 - 0.06 * (y < 3))) for c in tr[0][:3]) + (255,))
            elif y == 9:
                img.put(x, y, wd[3])
            elif y == 10:
                img.put(x, y, wd[2])
            else:
                t = 2 if x % 4 else 1
                if y == 15:
                    t = 0
                img.put(x, y, wd[t])
    rng = random.Random(variant * 7 + 1)
    cols = [hexc(s) for s in ("D9482E", "F2A33A", "6CB04A", "F4EAD0", "A24E9E", "E8C84A")]
    if variant == 0:            # fruit on the counter, strings of chilli hanging
        for i in range(3):
            c = cols[(i * 2 + rng.randint(0, 2)) % len(cols)]
            cx = 3 + i * 5
            for dx in range(-2, 3):
                for dy in range(-2, 1):
                    if dx * dx + dy * dy * 2 <= 5:
                        img.put(cx + dx, 8 + dy, tones(c)[3 if dx < 0 and dy < 0 else 2])
            img.put(cx + 1, 8, tones(c)[1])
        for x in (4, 10):
            for y in range(1, 5):
                img.put(x, y, cols[0] if y % 2 else tones(cols[0])[1])
    elif variant == 1:          # cloth bolts
        for i, c in enumerate((cols[4], cols[5], cols[1], cols[2])):
            tt = tones(c)
            rect(img, 1 + i * 4, 4, 3, 5, tt[2])
            rect(img, 1 + i * 4, 4, 1, 5, tt[3])
            rect(img, 3 + i * 4, 4, 1, 5, tt[1])
        for y in range(1, 4):
            img.put(2, y, tones(cols[3])[2])
            img.put(11, y, tones(cols[3])[2])
    else:                       # jars and a hanging basket
        for i in range(2):
            cx = 4 + i * 7
            tt = tones(hexc("B5653A"))
            for dy in range(-3, 1):
                for dx in range(-2, 3):
                    if abs(dx) <= 2 - (1 if dy < -2 else 0):
                        img.put(cx + dx, 8 + dy, tt[3 if dx < 0 else (1 if dx > 1 else 2)])
        rect(img, 7, 2, 3, 2, tones(hexc("C9A35A"))[2])
    return lift(img, "copy")


def post_tile(pal, left):
    tr = tones(pal["trim"])
    img = Img(16, WH)
    xs = (0, 1, 2) if left else (13, 14, 15)
    tones_ = (3, 2, 1) if left else (2, 1, 0)
    for y in range(WH):
        for x, t in zip(xs, tones_):
            img.put(x, y, tr[t])
    return img


def _cell(img, name, tile):
    cx, cy = CELLS[name]
    img.blit(tile, cx * 16, cy * WH)


def door_closed(style, pal):
    tr = tones(pal["trim"])
    wl = tones(pal["wall"])
    ac = pal["accent"]
    img = Img(16, 16)
    for y in range(1, 16):          # frame
        img.put(2, y, tr[2])
        img.put(13, y, tr[1])
    rect(img, 2, 1, 12, 2, tr[3])
    rect(img, 2, 2, 12, 1, tr[2])
    wood = tones(mix(pal["trim"], (120, 84, 50, 255), 0.35))
    for y in range(3, 16):
        for x in range(3, 13):
            if style == 0:          # planks
                t = 1 if (x - 3) % 3 == 2 else (3 if (x - 3) % 3 == 0 else 2)
                img.put(x, y, wood[t])
            elif style == 1:        # double leaf with inset panels
                if x == 7 or x == 8:
                    img.put(x, y, wood[0] if x == 7 else wood[3])
                else:
                    inset = (4 <= y <= 8 or 10 <= y <= 14) and x in (4, 5, 6, 9, 10, 11)
                    img.put(x, y, wood[3 if inset and y in (4, 10) else (1 if inset else 2)])
            elif style == 2:        # woven bamboo door
                img.put(x, y, wl[3 if (x + y) % 4 == 0 else (2 if (x + y) % 4 < 3 else 1)])
                if x in (3, 12) or y in (3, 9):
                    img.put(x, y, tr[2])
            else:                   # carved gebyok door in gold-trimmed frame
                if y < 6:
                    img.put(x, y, wood[3 if (x + y) % 2 == 0 else 1])
                else:
                    sq = abs(x - 7.5) + abs(y - 10.5)
                    img.put(x, y, wood[2])
                    if int(sq) == 3:
                        img.put(x, y, ac)
                    elif sq < 3:
                        img.put(x, y, wood[1])
    if style in (0, 1):
        img.put(10 if style == 0 else 9, 9, ac)
    if style == 3:
        rect(img, 3, 3, 10, 1, ac)
    return lift(img, "over")


def door_open(style, pal):
    tr = tones(pal["trim"])
    ac = pal["accent"]
    img = Img(16, 16)
    dark = (28, 20, 26, 255)
    warm = (92, 62, 36, 255)
    for y in range(2, 16):
        for x in range(3, 13):
            t = (y - 2) / 13.0
            img.put(x, y, mix(dark, warm, max(0.0, t - 0.55) * 1.6))
    for y in range(13, 16):
        for x in range(3, 13):
            img.put(x, y, mix(warm, hexc("C9985A"), 0.5 if y == 13 else 0.2))
    for y in range(1, 16):
        img.put(2, y, tr[2])
        img.put(13, y, tr[1])
    rect(img, 2, 1, 12, 2, tr[3] if style != 3 else tr[2])
    if style == 1:                  # kain curtain on the left
        cl = tones(hexc("A8433A"))
        for y in range(3, 12):
            for x in range(3, 8):
                img.put(x, y, cl[3 if x % 2 == 0 else 2] if y < 11 else cl[1])
        for x in range(3, 8):
            img.put(x, 11 if x % 2 else 12, cl[1])
    elif style == 2:                # leaf ajar on the right
        wood = tones(mix(pal["trim"], (120, 84, 50, 255), 0.35))
        for y in range(3, 15):
            img.put(11, y, wood[2])
            img.put(12, y, wood[1])
        img.put(11, 9, ac)
    elif style == 3:                # arched, carved lintel
        for (x, y) in ((3, 3), (4, 3), (3, 4), (12, 3), (11, 3), (12, 4), (3, 5), (12, 5)):
            img.put(x, y, tr[2] if x < 8 else tr[1])
        for x in range(3, 13):
            img.put(x, 1, ac if x % 2 == 0 else tr[3])
    return lift(img, "over")


def window(style, lit, pal):
    tr = tones(pal["trim"])
    img = Img(16, 16)
    if lit:
        g1, g2 = hexc("FFE59A"), hexc("F0A84A")
    else:
        g1, g2 = hexc("45566E"), hexc("26303F")
    if style == 0:          # shuttered window, shutters open
        for y in range(4, 12):
            for x in range(3, 13):
                img.put(x, y, tr[1])
        for y in range(5, 11):
            for x in range(6, 10):
                img.put(x, y, mix(g1, g2, (y - 5) / 6.0))
        for y in range(4, 12):
            for x in (3, 4, 5, 10, 11, 12):
                lo = tr[3] if (y % 2 == 0) else tr[2]
                img.put(x, y, lo if x in (3, 4, 10, 11) else tr[1])
        rect(img, 5, 4, 1, 8, tr[0])
        rect(img, 10, 4, 1, 8, tr[0])
        if not lit:
            img.put(6, 5, hexc("A8B8D0"))
    elif style == 1:        # bamboo lattice window
        rect(img, 3, 5, 10, 7, tr[2])
        rect(img, 4, 6, 8, 5, mix(g1, g2, 0.5))
        for x in range(4, 12, 2):
            for y in range(6, 11):
                img.put(x, y, tr[3] if x == 4 else tr[1])
        rect(img, 3, 11, 10, 1, tr[0])
        rect(img, 3, 4, 10, 1, tr[3])
    else:                   # round window
        for y in range(3, 13):
            for x in range(3, 13):
                d = (x - 7.5) ** 2 + (y - 7.5) ** 2
                if d <= 21:
                    img.put(x, y, tr[1] if d > 13 else mix(g1, g2, (y - 4) / 8.0))
        for i in range(4, 12):
            img.put(i, 7, tr[2])
            img.put(7, i, tr[2])
        img.put(5, 5, tr[3])
    if lit:
        for x in range(3, 13):
            img.put(x, 12, mix(hexc("C9985A"), hexc("FFE59A"), 0.3))
        for (x, y) in ((2, 8), (13, 8)):
            img.put(x, y, (255, 210, 120, 120))
    o = Img(16, WH)
    o.blit(img, 0, 3)        # window sits mid-wall
    return o


def step_piece(pal):
    tr = tones(pal["trim"])
    img = Img(16, 16)
    rect(img, 2, 0, 12, 3, tr[2])
    rect(img, 2, 0, 12, 1, tr[3])
    rect(img, 2, 2, 12, 1, tr[1])
    rect(img, 1, 3, 14, 3, tr[2])
    rect(img, 1, 3, 14, 1, tr[3])
    rect(img, 1, 5, 14, 1, tr[1])
    rect(img, 0, 6, 16, 1, (10, 8, 20, 90))
    for x in (2, 13):
        rect(img, x, 0, 1, 6, tr[0])
    o = Img(16, WH)
    o.blit(img, 0, 0)
    return o


def stilt_piece(pal):
    tr = tones(pal["trim"])
    img = Img(16, 16)
    for y in range(9, 16):
        for x in range(16):
            img.put(x, y, (24, 18, 26, 255) if y > 10 else tr[1])
    rect(img, 0, 9, 16, 1, tr[3])
    rect(img, 0, 10, 16, 1, tr[1])
    for y in range(11, 16):
        for x, t in ((6, 3), (7, 2), (8, 1)):
            img.put(x, y, tr[t])
    st = tones(pal["stone"])        # umpak: a stone block under each post
    rect(img, 4, 13, 7, 3, st[2])
    rect(img, 4, 13, 7, 1, st[3])
    rect(img, 4, 15, 7, 1, st[1])
    rect(img, 10, 13, 1, 3, st[1])
    rect(img, 3, 13, 1, 3, st[0])
    rect(img, 11, 13, 1, 3, st[0])
    return lift(img, "over")


def pend_a(pal):
    tr = tones(pal["trim"])
    st = tones(pal["stone"])
    wl = tones(pal["wall"])
    img = Img(16, WH)
    for y in range(WH):
        for x in range(16):
            if y < WH - 6:
                c = (30 + y, 22 + y // 2, 24 + y // 2, 255)
                if y == 9 and x % 4 == 1:
                    c = tr[1]
                img.put(x, y, c)
            elif y < WH - 3:
                img.put(x, y, wl[3 if y == WH - 6 else 2])
            else:
                img.put(x, y, st[3 if y == WH - 3 else (2 if y == WH - 2 else 1)])
    rect(img, 0, 6, 16, 2, tr[2])
    rect(img, 0, 6, 16, 1, tr[3])
    return img


def pend_post(pal):
    tr = tones(pal["trim"])
    st = tones(pal["stone"])
    img = Img(16, WH)
    for y in range(WH):
        for x, t in ((6, 3), (7, 2), (8, 2), (9, 1)):
            img.put(x, y, tr[t])
    for x in range(5, 11):
        img.put(x, 6, tr[3] if x < 8 else tr[1])
        img.put(x, WH - 3, st[3])
        img.put(x, WH - 2, st[2])
    rect(img, 6, 12, 4, 1, pal["accent"])
    return img


def wide_piece(pal, which):
    tr = tones(pal["trim"])
    img = Img(16, 16)
    dark = (28, 20, 26, 255)
    warm = (92, 62, 36, 255)
    xa = 3 if which == "l" else 0
    xb = 13 if which == "r" else 16
    for y in range(2, 16):
        for x in range(xa, xb):
            t = (y - 2) / 13.0
            c = mix(dark, warm, max(0.0, t - 0.55) * 1.6)
            if y >= 13:
                c = mix(warm, hexc("C9985A"), 0.4)
            img.put(x, y, c)
    rect(img, 2 if which == "l" else 0, 1, 14 if which != "m" else 16, 2, tr[3])
    if which == "l":
        for y in range(1, 16):
            img.put(2, y, tr[2])
    if which == "r":
        for y in range(1, 16):
            img.put(13, y, tr[1])
    return lift(img, "over")


def pile_piece(pal):
    """Tall stilts (kidul): two posts per tile with a cross brace, in the bottom 10 rows of the cell."""
    tr = tones(pal["trim"])
    img = Img(16, WH)
    for y in range(WH - 10, WH):
        for x in range(16):
            img.put(x, y, (22, 16, 24, 255) if y > WH - 9 else tr[0])
    for x0 in (1, 11):
        for y in range(WH - 10, WH):
            for dx, t in ((0, 3), (1, 2), (2, 1)):
                img.put(x0 + dx, y, tr[t])
        img.put(x0 - 1 if x0 > 8 else x0 + 3, WH - 1, (10, 8, 20, 110))
    for i in range(10):
        x = 3 + i
        y = WH - 8 + (i * 5) // 10
        if 4 <= x <= 10:
            img.put(x, y, tr[2])
    return img


def ladder_piece(pal):
    tr = tones(pal["trim"])
    img = Img(16, WH)
    for y in range(WH - 14, WH):
        img.put(5, y, tr[3])
        img.put(6, y, tr[2])
        img.put(10, y, tr[2])
        img.put(11, y, tr[1])
        if y % 3 == 0:
            for x in range(7, 10):
                img.put(x, y, tr[3])
    return img


def build_wall_sheet(kit, pal):
    sheet = Img(128, WH * 4)
    style = KITS[kit]["wall"]
    if style == "counter":
        for i, nm in enumerate(("wall_a", "wall_b", "wall_c")):
            _cell(sheet, nm, counter_tile(pal, i))
    else:
        for nm, v in (("wall_a", "a"), ("wall_b", "b"), ("wall_c", "c")):
            _cell(sheet, nm, wall_tile(style, pal, v))
    _cell(sheet, "post_l", post_tile(pal, True))
    _cell(sheet, "post_r", post_tile(pal, False))
    _cell(sheet, "stilt", stilt_piece(pal))
    _cell(sheet, "step", step_piece(pal))
    _cell(sheet, "pend_a", pend_a(pal))
    for i in range(4):
        _cell(sheet, "closed_%d" % i, door_closed(i, pal))
        _cell(sheet, "open_%d" % i, door_open(i, pal))
    for i in range(3):
        _cell(sheet, "win_%d" % i, window(i, False, pal))
        _cell(sheet, "lit_%d" % i, window(i, True, pal))
    _cell(sheet, "wide_l", wide_piece(pal, "l"))
    _cell(sheet, "wide_r", wide_piece(pal, "r"))
    _cell(sheet, "wide_m", wide_piece(pal, "m"))
    _cell(sheet, "pend_post", pend_post(pal))
    _cell(sheet, "pile", pile_piece(pal))
    _cell(sheet, "ladder", ladder_piece(pal))
    return sheet


# ---------------------------------------------------------------- extras (24x24 cells, bottom-centre anchored)
def fin(img, w=24, h=24, dy=0):
    """Outline a small sprite and put it on a 24x24 cell, base on row 22."""
    o = outline_pad(img)
    cell = Img(w, h)
    cell.blit(o, (w - o.w) // 2, h - 2 - o.h + dy)
    return cell


def ellipse(img, cx, cy, rx, ry, tn, tex=0.0, rng=None):
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            nx, ny = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
            d = nx * nx + ny * ny
            if d > 1:
                continue
            lum = 0.5 + 0.5 * (-0.6 * nx - 0.7 * ny)
            t = clampi(int(lum * 4), 0, 3)
            img.put(x, y, tn[t])


def ex_lamp():
    img = Img(7, 12)
    br = tones(hexc("8A6A3A"))
    rect(img, 3, 0, 1, 3, br[1])
    rect(img, 1, 3, 5, 1, br[3])
    rect(img, 2, 2, 3, 1, br[2])
    for y in range(4, 9):
        for x in range(1, 6):
            img.put(x, y, tuple(hexc("FFE59A") if y < 7 else hexc("F4B450")))
    img.put(1, 4, hexc("FFF6D0"))
    rect(img, 1, 9, 5, 1, br[1])
    img.put(3, 10, br[2])
    return fin(img, dy=0)


def ex_pot(v):
    img = Img(12, 16)
    cl = tones(hexc("B8663C"))
    lf = tones(hexc("3F8F4A") if v == 0 else hexc("2F7A58"))
    rect(img, 2, 10, 8, 5, cl[2])
    rect(img, 2, 10, 2, 5, cl[3])
    rect(img, 8, 10, 2, 5, cl[1])
    rect(img, 1, 9, 10, 2, cl[3])
    rect(img, 1, 10, 10, 1, cl[1])
    rng = random.Random(40 + v)
    blobs = [(6, 5, 4, 4), (3, 7, 3, 3), (9, 7, 3, 3)] if v == 0 else [(6, 3, 2, 3), (3, 6, 3, 4), (9, 6, 3, 4), (6, 7, 3, 3)]
    for cx, cy, rx, ry in blobs:
        ellipse(img, cx, cy, rx, ry, lf)
    if v == 1:
        for (x, y) in ((3, 3), (9, 2), (6, 1)):
            img.put(x, y, hexc("F28AAE"))
            img.put(x + 1, y, hexc("FFC4D6"))
    else:
        img.put(4, 4, lf[3])
        img.put(7, 3, hexc("FFD23F"))
    return fin(img)


def ex_broom():
    img = Img(7, 16)
    for i in range(11):
        img.put(1 + i // 3, 0 + i, hexc("8A6A3A"))
        img.put(2 + i // 3, 0 + i, hexc("6E5230"))
    tn = tones(hexc("C2A25A"))
    for y in range(10, 16):
        for x in range(1 + (y - 10) // 4, 6 - (15 - y) // 5 if False else 6):
            img.put(x, y, tn[3 if x < 3 else (2 if x < 5 else 1)])
    rect(img, 1, 10, 5, 1, hexc("5A4630"))
    return fin(img)


def ex_jar():
    img = Img(12, 14)
    cl = tones(hexc("A8643C"))
    ellipse(img, 6, 8, 5, 5, cl)
    rect(img, 3, 1, 6, 3, cl[2])
    rect(img, 3, 1, 2, 3, cl[3])
    rect(img, 2, 2, 8, 1, cl[3])
    rect(img, 4, 2, 4, 1, (30, 56, 82, 255))
    rect(img, 4, 7, 4, 1, cl[0])
    return fin(img)


def ex_wood():
    img = Img(16, 11)
    br = tones(hexc("8A5A34"))
    for row, n in ((0, 3), (1, 4), (2, 5)) if False else ((2, 5), (1, 4), (0, 3)):
        for i in range(n):
            cx = 3 + i * 3 + (0 if n % 2 else 0) + (5 - n) * 1
            cy = 3 + (2 - row) * 3
            rect(img, cx - 1, cy - 1, 3, 3, br[2])
            img.put(cx - 1, cy - 1, br[3])
            img.put(cx, cy, hexc("D8B070"))
            img.put(cx + 1, cy + 1, br[1])
    return fin(img)


def ex_cage():
    img = Img(9, 13)
    br = tones(hexc("B58A4A"))
    rect(img, 4, 0, 1, 3, br[1])
    for y in range(3, 11):
        w = 3 + min(y - 3, 3) if y < 7 else 6 - (y - 7)
        x0 = 4 - w // 2
        for x in (x0, x0 + w - 1):
            img.put(x, y, br[2] if x == x0 else br[1])
    rect(img, 1, 10, 7, 1, br[3])
    for x in (3, 5):
        for y in range(4, 10):
            img.put(x, y, br[1])
    img.put(4, 8, hexc("FFD23F"))
    img.put(4, 7, hexc("FFE680"))
    return fin(img)


def ex_bench():
    img = Img(18, 9)
    br = tones(hexc("A8723E"))
    rect(img, 0, 2, 18, 2, br[2])
    rect(img, 0, 2, 18, 1, br[3])
    rect(img, 0, 4, 18, 1, br[0])
    for x in (1, 15):
        rect(img, x, 4, 2, 5, br[1])
    return fin(img)


def ex_basket():
    img = Img(10, 9)
    br = tones(hexc("C29A52"))
    ellipse(img, 5, 5, 4.5, 3.5, br)
    for x in range(2, 9):
        img.put(x, 4, br[1] if x % 2 else br[3])
    rect(img, 1, 1, 8, 1, br[3])
    return fin(img)


def ex_sack():
    img = Img(10, 11)
    br = tones(hexc("C2B280"))
    ellipse(img, 5, 6, 4, 4.5, br)
    rect(img, 3, 1, 4, 3, br[2])
    rect(img, 3, 3, 4, 1, hexc("6E5A32"))
    return fin(img)


def ex_net():
    img = Img(14, 13)
    cord = tones(hexc("D4C49A"))
    for y in range(0, 12):
        for x in range(0, 14):
            if (x + y) % 3 == 0 or (x - y) % 3 == 0:
                img.put(x, y, cord[2] if (x + y) % 2 else cord[1])
    rect(img, 0, 0, 14, 1, hexc("6E5230"))
    for x in (2, 7, 11):
        rect(img, x, 5, 2, 2, hexc("E8607A"))
    return fin(img)


def ex_moss(v):
    img = Img(16, 16)
    mt = tones(hexc("5F8F3E"))
    rng = random.Random(90 + v)
    for _ in range(3):
        cx, cy = rng.randint(4, 11), rng.randint(4, 11)
        r = rng.randint(2, 4)
        for y in range(16):
            for x in range(16):
                d = (x - cx) ** 2 + (y - cy) ** 2
                if d <= r * r and rng.random() < 0.9 - d / (r * r + 1) * 0.5:
                    img.put(x, y, mt[3 if (x + y) % 3 == 0 else (2 if x < cx else 1)])
    return img


def ex_finial(kit, v):
    img = Img(14, 18)
    if kit in ("sunda", "kidul", "pasar") and v == 0:    # cagak gunting: crossed poles
        w = tones(hexc("7A5232"))
        for i in range(14):
            img.put(1 + i // 2, 15 - i, w[2])
            img.put(12 - i // 2, 15 - i, w[3])
            img.put(2 + i // 2, 15 - i, w[1])
            img.put(11 - i // 2, 15 - i, w[1])
    elif kit in ("sunda", "kidul", "pasar"):             # topknot of ijuk / shell
        w = tones(hexc("6E5230") if kit == "sunda" else hexc("E6DCC8"))
        ellipse(img, 7, 12, 3, 3, w)
        ellipse(img, 7, 7, 2, 3, w)
        rect(img, 7, 2, 1, 3, w[1])
        rect(img, 6, 14, 3, 2, w[1])
    else:
        cl = tones(hexc("B8503A") if kit == "galuh" else hexc("8A4A2E"))
        gold = tones(hexc("E0B040"))
        if v == 0:                                       # mustaka
            ellipse(img, 7, 13, 4, 3, cl)
            ellipse(img, 7, 9, 3, 3, cl)
            ellipse(img, 7, 5, 2, 2, gold)
            rect(img, 7, 1, 1, 3, gold[2])
            rect(img, 4, 15, 7, 1, cl[1])
        else:                                            # lotus bud
            for k, (cx, w, h) in enumerate(((7, 2, 8), (4, 2, 6), (10, 2, 6))):
                ellipse(img, cx, 14 - h // 2, w, h // 2 + 1, cl if k else gold)
            rect(img, 4, 14, 7, 2, cl[1])
    o = outline_pad(img)
    cell = Img(24, 24)
    cell.blit(o, 12 - o.w // 2, 23 - o.h)
    return cell


def build_extras(kit):
    sheet = Img(192, 48)
    pieces = {"lamp": ex_lamp(), "pot_a": ex_pot(0), "pot_b": ex_pot(1), "broom": ex_broom(), "jar": ex_jar(), "wood": ex_wood(),
              "cage": ex_cage(), "bench": ex_bench(), "moss_0": ex_moss(0), "moss_1": ex_moss(1), "moss_2": ex_moss(2),
              "finial_a": ex_finial(kit, 0), "finial_b": ex_finial(kit, 1), "net": ex_net(), "basket": ex_basket(), "sack": ex_sack()}
    for i, nm in enumerate(EXTRAS):
        p = pieces[nm]
        if nm.startswith("moss"):
            sheet.blit(p, (i % 8) * 24 + 4, (i // 8) * 24 + 4)
        else:
            sheet.blit(p, (i % 8) * 24, (i // 8) * 24)
    return sheet


# ---------------------------------------------------------------- composition (mirrors zones/buildings.gd)
class Kit:
    def __init__(self, name):
        self.name = name
        self.cfg = KITS[name]
        self.roof = {}
        self.wall = {}
        self.extras = build_extras(name)
        kinds = list(self.cfg["roofs"]) + (["leuit"] if name in LEUIT_KITS else []) + (["joglo_up"] if "joglo" in self.cfg["roofs"] else [])
        for k in kinds:
            for pi, pal in enumerate(self.cfg["pals"]):
                self.roof[(k, pi)] = render_roof(k, pal)
        for pi, pal in enumerate(self.cfg["pals"]):
            self.wall[pi] = build_wall_sheet(name, pal)

    def cell(self, pi, nm):
        cx, cy = CELLS[nm]
        return sub(self.wall[pi], cx * 16, cy * WH, 16, WH)

    def extra(self, nm):
        i = EXTRAS.index(nm)
        return sub(self.extras, (i % 8) * 24, (i // 8) * 24, 24, 24)


def roof_image(kit, kind, pi, W, n):
    """Nine-slice assembly of a roof for a footprint W tiles wide (W >= 2) with n repeated middle rows."""
    sh = kit.roof[(kind, pi)]
    m = max(0, W - 2)
    RW, RH = CW * 2 + 16 * m, TH + 16 * n + BH
    out = Img(RW, RH)
    cols = [(0, CW)] + [(CW, 16)] * m + [(ROOF_W - CW, CW)]
    rows = [(0, TH)] + [(TH, MH)] * n + [(TH + MH, BH)]
    x = 0
    for sx, sw in cols:
        y = 0
        for sy, shh in rows:
            out.blit(sub(sh, sx, sy, sw, shh), x, y)
            y += shh
        x += sw
    return out


TIER_TINT = {1: [1.0], 2: [0.86, 1.0], 3: [0.76, 0.88, 1.0]}


def roof_tiers(kind, W, D):
    """[(kind, width_tiles, n_mid_rows, inset_tiles)] from the bottom tier up. Mirrors buildings.gd."""
    n = max(0, D - 3)
    if kind == "awning":
        return [("awning", W, max(0, D - 4), 0)]
    if kind == "joglo" and W < 6:
        kind = "limasan"
    if kind == "joglo":
        if W >= 8 and n >= 2:
            return [("joglo", W, 1, 0), ("joglo_up", W - 4, n // 2, 2), ("joglo_up", W - 8, max(0, n // 2 - 1), 4)]
        return [("joglo", W, min(n, 1), 0), ("joglo_up", W - 4, max(0, n - 2), 2)]
    if n >= 3 and W >= 4:
        return [(kind, W, 1, 0), (kind, W - 2, n - 2, 1)]
    return [(kind, W, n, 0)]


def tint_img(img, f):
    o = Img(img.w, img.h)
    for y in range(img.h):
        for x in range(img.w):
            c = img.p[y][x]
            o.p[y][x] = c if c[3] == 0 else (int(c[0] * f), int(c[1] * f * 0.98), int(min(255, c[2] * f * 1.03)), c[3])
    return o


def compose(kit, plan, W, D, door_col, door_w):
    """Returns (Img, ox, oy): the building image and the pixel offset of its local origin (bottom-left of the footprint).
    Local y: 0 = south edge of the footprint, the wall spans -24..0, the roof's bottom edge is at -20."""
    pi = plan["pal"]
    front = plan.get("front") or kit.cfg["front"]
    rng = random.Random(plan["seed"])
    tiers = roof_tiers(plan["kind"], W, D)
    sh = plan.get("stilt_h", 0)          # tall stilts (kidul): the whole house is lifted by sh px
    tints = TIER_TINT[len(tiers)]
    placed = []
    ybot = -WH + 4 - sh
    for ti, (k, tw, n, inset) in enumerate(tiers):
        r = tint_img(roof_image(kit, k, pi, tw, n), tints[ti])
        if ti > 0:
            ybot = placed[-1][2] + 24          # previous top edge + 24: the upper eave covers the lower ridge
        placed.append((r, 16 * inset - 8, ybot - r.h, k))
    top = min(p[2] for p in placed) - 24
    RW = 16 * W + 16
    img = Img(RW, -top + 14)
    ox, oy = 8, -top
    def put(p, lx, ly):
        img.blit(p, ox + lx, oy + ly)
    names = ["wall_a", "wall_b", "wall_c"]
    base = plan["wallv"]
    for i in range(W):
        if front == "pendopo":
            put(kit.cell(pi, "pend_a"), 16 * i, -WH - sh)
            if i % 2 == 0 or i == W - 1:
                put(kit.cell(pi, "pend_post"), 16 * i, -WH - sh)
        elif front == "warung":
            put(kit.cell(pi, names[(i + base) % 3]), 16 * i, -WH - sh)
        else:
            put(kit.cell(pi, names[base] if plan["mix"] == 0 or i % 2 == 0 else names[(base + 1) % 3]), 16 * i, -WH - sh)
    if front in ("wall", "warung"):
        put(kit.cell(pi, "post_l"), 0, -WH - sh)
        put(kit.cell(pi, "post_r"), 16 * (W - 1), -WH - sh)
        if front == "warung":
            for i in range(4, W - 1, 4):
                put(kit.cell(pi, "post_l"), 16 * i, -WH - sh)
    door_cols = list(range(door_col, door_col + door_w)) if front == "wall" else []
    if sh:
        for i in range(W):
            put(kit.cell(pi, "pile"), 16 * i, -WH)
    elif plan["stilts"] and front == "wall":
        for i in range(W):
            if i not in door_cols:
                put(kit.cell(pi, "stilt"), 16 * i, -WH)
    if front == "wall":
        prev = -9
        for i in range(W):
            if i in door_cols or (door_cols and abs(i - door_cols[0]) < 1):
                prev = -9
                continue
            if i - prev >= 2 and 0 < i < W - 1 and rng.random() < 0.6:
                lit = rng.random() < plan["lit"]
                put(kit.cell(pi, ("lit_%d" if lit else "win_%d") % plan["win"]), 16 * i, -WH - sh)
                prev = i
    if door_cols:
        if door_w == 1:
            put(kit.cell(pi, ("open_%d" if plan["enterable"] else "closed_%d") % plan["door"]), 16 * door_col, -WH - sh)
        else:
            for j, i in enumerate(door_cols):
                put(kit.cell(pi, "wide_l" if j == 0 else ("wide_r" if j == door_w - 1 else "wide_m")), 16 * i, -WH - sh)
        for i in door_cols:
            put(kit.cell(pi, "ladder" if sh else "step"), 16 * i, 0 if not sh else -WH)
    for nm, cx, dy in plan["ground"]:
        put(kit.extra(nm), cx - 12, dy - 22)
    for r, lx, ly, k in placed:
        put(r, lx, ly)
    # moss on the top tier's front slope (fractions of its middle area)
    r, lx, ly, k = placed[-1]
    mx0, mx1 = lx + CW, lx + r.w - CW - 16
    my0, my1 = ly + TH, ly + r.h - BH - 16
    for fx, fy, v in plan["moss"]:
        if mx1 > mx0 and my1 > my0:
            put(kit.extra("moss_%d" % v), int(mx0 + (mx1 - mx0) * fx) - 4, int(my0 + (my1 - my0) * fy) - 4)
    if plan["finial"] is not None and k != "awning":
        ry = ly + ROOFS[k]["ridge"]
        if k == "julang":               # capit gunting (crossed poles) at both ridge ends
            put(kit.extra("finial_a"), lx + 14 - 12, ry - 20)
            put(kit.extra("finial_a"), lx + r.w - 14 - 12, ry - 20)
        else:
            put(kit.extra("finial_%s" % plan["finial"]), lx + r.w // 2 - 12, ry - 20)
    for nm, cx, dy in plan["hung"]:
        put(kit.extra(nm), cx - 12, -WH - sh + dy)
    return img, ox, oy


def make_plan(kit, rng, W, D, enterable, door_col=None, door_w=1, kind=None, pi=None):
    cfg = kit.cfg
    kind = kind or rng.choice(list(cfg["roofs"]))
    if kit.name in LEUIT_KITS and W <= 4 and D <= 4 and not enterable:
        kind = "leuit"
    pi = rng.randrange(len(cfg["pals"])) if pi is None else pi
    if door_col is None:
        door_col = W // 2 if rng.random() < 0.5 else rng.randint(1, max(1, W - 2))
    plan = dict(kind=kind, pal=pi, seed=rng.randrange(1 << 30), enterable=enterable, wallv=rng.randrange(3), mix=rng.randrange(2),
                door=rng.randrange(4), win=rng.randrange(3), lit=rng.choice((0.2, 0.4, 0.7)), finial=None, moss=[],
                stilts=kit.name in ("sunda", "kidul"), ground=[], hung=[])
    if kind == "leuit":
        plan["wallv"] = 1
    if kit.name == "kidul":
        plan["stilt_h"] = 10
    if kit.name in ("galuh", "mataram") and W >= 8 and D >= 5 and not enterable and rng.random() < 0.2:
        plan["front"] = "pendopo"
        plan["kind"] = "joglo"
    if kit.name in ("galuh", "mataram", "sunda") and rng.random() < 0.7:
        plan["finial"] = rng.choice("ab")
    if rng.random() < 0.55:
        for _ in range(rng.randint(1, 3)):
            plan["moss"].append((rng.random(), rng.random(), rng.randrange(3)))
    door_cols = list(range(door_col, door_col + door_w))
    free = [i for i in range(W) if i not in door_cols]
    slots = [door_col - 1, door_col + door_w] + [i for i in free if abs(i - door_col) > 1]
    rng.shuffle(slots)
    ground_pool = ["pot_a", "pot_b", "jar", "wood", "broom", "basket", "bench", "sack"]
    if kit.name == "kidul":
        ground_pool = ["jar", "basket", "sack", "wood", "bench"]
    hung_pool = ["lamp", "cage", "lamp"] + (["net", "net"] if kit.name == "kidul" else [])
    for s in slots[:rng.randint(2, 4)]:
        if s < 0 or s >= W:
            continue
        cx = 16 * s + 8
        if rng.random() < 0.35 and s not in door_cols:
            plan["hung"].append((rng.choice(hung_pool), cx, 6))
        else:
            plan["ground"].append((rng.choice(ground_pool), cx + rng.randint(-2, 2), 7))
    if cfg["front"] == "wall" and rng.random() < 0.8:
        lx = 16 * (door_col + door_w) + 3 if door_col + door_w < W else 16 * door_col - 3
        plan["hung"].append(("lamp", lx, 8))
    return plan, door_col


# ---------------------------------------------------------------- preview
def shadow_img(W, D_unused=0):
    s = Img(16 * W + 16, 24)
    for y in range(24):
        for x in range(16 * W + 16):
            if 4 <= x <= 16 * W + 12 and 8 <= y < 22:
                s.put(x, y, (12, 10, 24, 80))
    return s


def preview_kit(name, count=12, seed_=1, scale=2, out=None, extra_special=True):
    kit = Kit(name)
    rng = random.Random(seed_ * 131 + len(name))
    items = []
    for i in range(count):
        if name == "pasar":
            W, D = rng.randint(3, 7), rng.randint(3, 4)
        else:
            W, D = rng.choice((5, 6, 7, 8, 9, 10, 12)), rng.randint(4, 8)
        enterable = i % 3 == 0 and name != "pasar"
        kind = None
        plan, dc = make_plan(kit, rng, W, D, enterable, door_w=2 if (i % 5 == 4) else 1)
        if name == "sunda" and i == count - 1:
            W, D = 3, 3
            plan, dc = make_plan(kit, rng, W, D, False)
        if name in ("galuh", "mataram") and i == 1:
            W, D = 10, 6
            plan, dc = make_plan(kit, rng, W, D, False, kind="joglo")
        if name in ("galuh", "mataram") and i == 5:
            W, D = 9, 5
            plan, dc = make_plan(kit, rng, W, D, False, kind="joglo")
        if name in ("galuh", "mataram") and i == 4:
            W, D = 8, 4
            plan, dc = make_plan(kit, rng, W, D, False)
            plan["stilts"] = False
        if name in ("galuh", "mataram") and i == 6:
            W, D = 10, 6
            plan, dc = make_plan(kit, rng, W, D, False)
            plan["front"], plan["kind"] = "pendopo", "joglo"
        if name == "pasar":
            plan["stilts"] = False
        dw = 2 if (i % 5 == 4 and W >= 4) else 1
        img, ox, oy = compose(kit, plan, W, D, dc, dw if (plan.get("front") or kit.cfg["front"]) == "wall" else 1)
        if name in ("galuh", "mataram") and i in (4, 9):
            pass
        items.append((img, ox, oy, W))
    # layout: rows
    colsn = 4 if name != "pasar" else 4
    cellw = max(it[0].w for it in items) + 14
    cellh = max(it[0].h for it in items) + 14
    rows = (len(items) + colsn - 1) // colsn
    sheet = Img(cellw * colsn + 8, cellh * rows + 8)
    ground = {"sunda": "58844A", "galuh": "5E8A52", "mataram": "6C8442", "kidul": "4F8066", "pasar": "6C8A52"}[name]
    g = hexc(ground)
    for y in range(sheet.h):
        for x in range(sheet.w):
            c = g if H(x // 2, y // 2, 5) > 0.12 else tuple(int(v * 0.93) for v in g[:3]) + (255,)
            sheet.p[y][x] = c
    for idx, (img, ox, oy, W) in enumerate(items):
        cx, cy = idx % colsn, idx // colsn
        bx = 4 + cx * cellw + (cellw - img.w) // 2
        by = 4 + cy * cellh + cellh - 6 - (img.h - oy)   # origin y of local (0,0)
        by = 4 + cy * cellh + cellh - 14 - img.h + img.h - (img.h - oy) + 6 - 6 + (img.h - oy) - (img.h - oy)
        # simple: align image bottom (local y = +12) near cell bottom
        by = 4 + cy * cellh + cellh - img.h - 6
        sheet.blit(shadow_img(W), bx + 0, by + oy - 16 + 0)
        sheet.blit(img, bx, by)
    big = sheet.scaled(scale) if scale > 1 else sheet
    big.save(out or PREVIEW)
    return big


def build_all():
    n = 0
    for name, cfg in KITS.items():
        kit = Kit(name)
        d = os.path.join(OUT, name)
        for (k, pi), im in kit.roof.items():
            im.save(os.path.join(d, "roof_%s_%d.png" % (k, pi)))
            n += 1
        for pi, im in kit.wall.items():
            im.save(os.path.join(d, "wall_%d.png" % pi))
            n += 1
        kit.extras.save(os.path.join(d, "extras.png"))
        n += 1
    return n


def full_preview(scale=2):
    """One contact sheet: about 12 composed houses per kit, kits stacked."""
    names = list(KITS)
    tmp = []
    for nm in names:
        tmp.append(preview_kit(nm, 12 if nm != "pasar" else 8, scale=scale, out=os.path.join(ROOT, "tools", ".bprev_%s.png" % nm)))
    W = max(t.w for t in tmp)
    H = sum(t.h for t in tmp)
    out = Img(W, H)
    y = 0
    for t in tmp:
        out.blit(t, 0, y)
        y += t.h
    out.save(PREVIEW)
    for nm in names:
        try:
            os.remove(os.path.join(ROOT, "tools", ".bprev_%s.png" % nm))
        except OSError:
            pass


if __name__ == "__main__":
    args = sys.argv[1:]
    if "--preview" in args:
        nm = args[args.index("--preview") + 1]
        sc = int(args[args.index("--scale") + 1]) if "--scale" in args else 2
        o = args[args.index("--out") + 1] if "--out" in args else None
        seed_ = int(args[args.index("--seed") + 1]) if "--seed" in args else 1
        preview_kit(nm, 12, seed_=seed_, scale=sc, out=o)
    else:
        print("wrote %d kit sheets to %s" % (build_all(), OUT))
        full_preview()
        print("wrote", PREVIEW)
