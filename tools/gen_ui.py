#!/usr/bin/env python3
"""Budayago UI sprite generator (wayang kelir at night: lacquer, sogan, prada gold).

Pure Python (zlib + struct): the dev machine has no PIL.
Run:  python3 tools/gen_ui.py
Writes assets/art/ui/*.png and tools/ui_preview.png. Light is top-left everywhere.
"""
import math
import os
import random
import struct
import zlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "art", "ui")


def hexc(s, a=255):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), a)


# palette (ui.md 3b)
LACQUER = hexc("0E0B0A")
SOGAN = hexc("3A2618")
GOLD = hexc("C9A24A")
HI = hexc("F2D488")
SH = hexc("7A5A22")
CREAM = hexc("EDE3CC")
DIM = hexc("9C8F78")
INDIGO = hexc("1F2A44")
VERM = hexc("B8432B")
CLEAR = (0, 0, 0, 0)


class Img:
    def __init__(self, w, h, fill=CLEAR):
        self.w, self.h = w, h
        self.p = [[fill] * w for _ in range(h)]

    def put(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.p[y][x] = c

    def get(self, x, y):
        if 0 <= x < self.w and 0 <= y < self.h:
            return self.p[y][x]
        return CLEAR

    def blend(self, x, y, c):
        if not (0 <= x < self.w and 0 <= y < self.h):
            return
        a = c[3] / 255.0
        if a >= 1:
            self.p[y][x] = c
            return
        d = self.p[y][x]
        da = d[3] / 255.0
        oa = a + da * (1 - a)
        if oa <= 0:
            return
        r = [int((c[i] * a + d[i] * da * (1 - a)) / oa + 0.5) for i in range(3)]
        self.p[y][x] = (r[0], r[1], r[2], int(oa * 255 + 0.5))

    def rect(self, x0, y0, x1, y1, c):
        """inclusive corners"""
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.put(x, y, c)

    def paste(self, o, x, y):
        for j in range(o.h):
            for i in range(o.w):
                c = o.p[j][i]
                if c[3]:
                    self.blend(x + i, y + j, c)

    def scaled(self, k):
        o = Img(self.w * k, self.h * k)
        for y in range(self.h):
            for x in range(self.w):
                c = self.p[y][x]
                if c[3]:
                    for j in range(k):
                        for i in range(k):
                            o.p[y * k + j][x * k + i] = c
        return o

    def save(self, path):
        raw = bytearray()
        for row in self.p:
            raw.append(0)
            for c in row:
                raw.extend(c)

        def chunk(t, d):
            b = t + d
            return struct.pack(">I", len(d)) + b + struct.pack(">I", zlib.crc32(b) & 0xFFFFFFFF)

        png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", self.w, self.h, 8, 6, 0, 0, 0))
        png += chunk(b"IDAT", zlib.compress(bytes(raw), 9)) + chunk(b"IEND", b"")
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "wb") as f:
            f.write(png)


def sprite(rows, pal):
    h = len(rows)
    w = max(len(r) for r in rows)
    im = Img(w, h)
    for y, row in enumerate(rows):
        assert len(row) == w, (y, row)
        for x, ch in enumerate(row):
            if ch != ".":
                im.put(x, y, pal[ch])
    return im


def alpha(c, a):
    return (c[0], c[1], c[2], a)


def mix(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t + 0.5) for i in range(4))


# ---------------------------------------------------------------- frames
KAWUNG = [
    "..G..",
    ".G.G.",
    "G.H.G",
    ".G.G.",
    "..G..",
]


def corner_orn(im, ox, oy, flipx, flipy, pat=KAWUNG, pal=None):
    pal = pal or {"G": GOLD, "H": HI}
    ph, pw = len(pat), len(pat[0])
    for j in range(ph):
        for i in range(pw):
            ch = pat[j][i]
            if ch == ".":
                continue
            x = ox + (pw - 1 - i if flipx else i)
            y = oy + (ph - 1 - j if flipy else j)
            im.put(x, y, pal[ch])


def gold_frame(w, h, rich=False, fill=None, inset=(6, 4, 3, 255)):
    """1 px gold line (highlight top-left, shadow bottom-right), 1 px dark inset, lacquer fill."""
    fill = fill if fill is not None else alpha(LACQUER, 235)
    im = Img(w, h)
    im.rect(2, 2, w - 3, h - 3, fill)
    # dark inset ring
    for x in range(1, w - 1):
        im.put(x, 1, inset)
        im.put(x, h - 2, inset)
    for y in range(1, h - 1):
        im.put(1, y, inset)
        im.put(w - 2, y, inset)
    # gold line: lit top/left, shadowed bottom/right
    for x in range(1, w - 1):
        im.put(x, 0, HI if x < w // 2 else GOLD)
        im.put(x, h - 1, SH)
    for y in range(1, h - 1):
        im.put(0, y, HI if y < h // 2 else GOLD)
        im.put(w - 1, y, SH)
    for (x, y) in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)):
        im.put(x, y, CLEAR)
    im.put(1, 0, HI)
    im.put(0, 1, HI)
    im.put(w - 2, 0, GOLD)
    im.put(0, h - 2, GOLD)
    im.put(w - 2, h - 1, SH)
    im.put(w - 1, h - 2, SH)
    if rich:
        # second, fainter gold line under the top edge with a stepped notch each end
        for x in range(4, w - 4):
            im.put(x, 2, alpha(SH, 255))
        for x in range(2, 4):
            im.put(x, 2, GOLD)
            im.put(w - 1 - x, 2, GOLD)
    return im


def kawung_corners(im, margin):
    w, h = im.w, im.h
    o = 1 if margin <= 6 else 2
    corner_orn(im, o + 1, o + 1, False, False)
    corner_orn(im, w - o - 6, o + 1, True, False)
    corner_orn(im, o + 1, h - o - 6, False, True)
    corner_orn(im, w - o - 6, h - o - 6, True, True)


def make_panel():
    im = gold_frame(24, 24)
    kawung_corners(im, 6)
    return im


def make_panel_dialogue():
    im = gold_frame(32, 32, rich=True)
    kawung_corners(im, 8)
    # small L flourish along both edges of each corner
    for (sx, sy, fx, fy) in ((0, 0, 1, 1), (1, 0, -1, 1), (0, 1, 1, -1), (1, 1, -1, -1)):
        bx = 7 if fx > 0 else 24
        by = 7 if fy > 0 else 24
        for k in range(1, 4):
            im.put(bx + fx * k, by + fy * 0, GOLD)
            im.put(bx + fx * 0, by + fy * k, GOLD)
    return im


def make_portrait_frame():
    im = Img(40, 40)
    w = h = 40
    for x in range(w):
        im.put(x, 0, HI if x < 20 else GOLD)
        im.put(x, h - 1, SH)
        im.put(x, 1, (6, 4, 3, 255))
        im.put(x, h - 2, (6, 4, 3, 255))
        im.put(x, 2, SH)
        im.put(x, h - 3, GOLD)
    for y in range(h):
        im.put(0, y, HI if y < 20 else GOLD)
        im.put(w - 1, y, SH)
        im.put(1, y, (6, 4, 3, 255))
        im.put(w - 2, y, (6, 4, 3, 255))
        im.put(2, y, SH)
        im.put(w - 3, y, GOLD)
    im.rect(3, 3, 3, h - 4, (6, 4, 3, 255))
    im.rect(w - 4, 3, w - 4, h - 4, (6, 4, 3, 255))
    im.rect(3, 3, w - 4, 3, (6, 4, 3, 255))
    im.rect(3, h - 4, w - 4, h - 4, (6, 4, 3, 255))
    for (x, y) in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)):
        im.put(x, y, CLEAR)
    big = [
        "GGGG....",
        "GHHG....",
        "GH.G.G..",
        "GG.G.H..",
        "...HGG..",
        "..G.G...",
        "..H.....",
        "........",
    ]
    corner_orn(im, 0, 0, False, False, big, {"G": GOLD, "H": HI})
    corner_orn(im, w - 8, 0, True, False, big, {"G": GOLD, "H": HI})
    corner_orn(im, 0, h - 8, False, True, big, {"G": GOLD, "H": HI})
    corner_orn(im, w - 8, h - 8, True, True, big, {"G": GOLD, "H": HI})
    return im


def make_button(border_hi, border_lo, fa, fb, bevel, dots, shadow_top=None):
    w, h = 24, 14
    im = Img(w, h)
    for y in range(h):
        for x in range(w):
            im.put(x, y, fa if y <= 6 else fb)
    if bevel:
        for x in range(1, w - 1):
            im.put(x, 1, bevel)
        for y in range(1, h - 1):
            im.put(1, y, mix(fa if y <= 6 else fb, bevel, 0.5))
    if shadow_top:
        for x in range(1, w - 1):
            im.put(x, 1, shadow_top)
        for y in range(1, h - 1):
            im.put(1, y, shadow_top)
    for x in range(w):
        im.put(x, 0, border_hi)
        im.put(x, h - 1, border_lo)
    for y in range(h):
        im.put(0, y, border_hi)
        im.put(w - 1, y, border_lo)
    for (x, y) in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)):
        im.put(x, y, CLEAR)
    if dots:
        for (x, y) in ((1, 1), (w - 2, 1), (1, h - 2), (w - 2, h - 2)):
            im.put(x, y, dots)
        im.put(2, 0, border_hi)
    return im


def make_tab(on):
    w, h = 24, 14
    im = Img(w, h)
    if on:
        fa, fb = hexc("3A2618"), hexc("2A1B11")
        for y in range(h):
            for x in range(w):
                im.put(x, y, fa if y < 5 else fb)
        for x in range(w):
            im.put(x, 0, HI if x < 12 else GOLD)
        for y in range(h):
            im.put(0, y, HI if y < 7 else GOLD)
            im.put(w - 1, y, SH)
        for x in range(1, w - 1):
            im.put(x, 1, hexc("5A3C24"))
        im.put(0, 0, CLEAR)
        im.put(w - 1, 0, CLEAR)
        im.put(1, 0, GOLD)
        im.put(w - 2, 0, SH)
        # bottom row blends into the panel beneath
        for x in range(1, w - 1):
            im.put(x, h - 1, hexc("2A1B11"))
    else:
        for y in range(2, h):
            for x in range(w):
                im.put(x, y, hexc("17110D") if y < 6 else hexc("120D0A"))
        dimg = hexc("5E4C2C")
        for x in range(w):
            im.put(x, 2, dimg)
            im.put(x, h - 1, SH)
        for y in range(2, h):
            im.put(0, y, dimg)
            im.put(w - 1, y, hexc("3E3018"))
        im.put(0, 2, CLEAR)
        im.put(w - 1, 2, CLEAR)
        for x in range(1, w - 1):
            im.put(x, 3, hexc("221810"))
    return im


def make_slot(selected):
    w = h = 20
    im = Img(w, h)
    well = hexc("4A3020") if selected else SOGAN
    im.rect(0, 0, w - 1, h - 1, LACQUER)
    im.rect(2, 2, w - 3, h - 3, well)
    # inset bevel: shadow top-left, lit bottom-right
    for x in range(1, w - 1):
        im.put(x, 1, hexc("1A0F08"))
        im.put(x, h - 2, hexc("5B3D24"))
    for y in range(1, h - 1):
        im.put(1, y, hexc("1A0F08"))
        im.put(w - 2, y, hexc("5B3D24"))
    im.put(1, 1, hexc("120A05"))
    im.put(w - 2, h - 2, hexc("6B4A2C"))
    for (x, y) in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)):
        im.put(x, y, CLEAR)
    if selected:
        for x in range(1, w - 1):
            im.put(x, 0, HI if x < 12 else GOLD)
            im.put(x, h - 1, SH)
        for y in range(1, h - 1):
            im.put(0, y, HI if y < 12 else GOLD)
            im.put(w - 1, y, SH)
        for x in range(2, w - 2):
            im.put(x, 1, GOLD)
            im.put(x, h - 2, SH)
        for y in range(2, h - 2):
            im.put(1, y, GOLD)
            im.put(w - 2, y, SH)
        # bright corner studs
        for (x, y) in ((1, 1), (w - 2, 1), (1, h - 2), (w - 2, h - 2)):
            im.put(x, y, HI)
        im.put(1, 0, HI)
        im.put(0, 1, HI)
    return im


def make_divider():
    w, h = 64, 5
    im = Img(w, h)
    c = w // 2
    for x in range(0, w):
        d = abs(x - c + 0.5)
        if d < 5:
            continue
        # fade to the ends with a stipple
        fade = 1.0 if d < 22 else max(0.0, 1 - (d - 22) / 10.0)
        if fade >= 1 or (fade > 0 and ((x * 7) % 10) / 10.0 < fade + 0.1):
            im.put(x, 2, HI if x < c else GOLD)
            if fade >= 0.7 and d < 24:
                im.put(x, 3, SH)
    loz = [
        "..H..",
        ".HGG.",
        "HGGGS",
        ".GSS.",
        "..S..",
    ]
    pal = {"H": HI, "G": GOLD, "S": SH}
    im.paste(sprite(loz, pal), c - 3, 0)
    # tiny end studs beside the lozenge
    im.put(c - 5, 2, SH)
    im.put(c + 4, 2, SH)
    return im


def make_lozenge():
    return sprite([
        "..H..",
        ".HGG.",
        "HGGGS",
        ".GSS.",
        "..S..",
    ], {"H": HI, "G": GOLD, "S": SH})


def make_bar_frame():
    D = hexc("060403")
    L = LACQUER
    left = [
        ".HG",
        "GHD",
        "HDL",
        "HFL",
        "GDL",
        "GSD",
        ".SS",
    ]
    mid = ["H", "D", "L", "L", "L", "D", "S"]
    pal = {"H": HI, "G": GOLD, "S": SH, "D": D, "L": L, "F": hexc("FFF3C8")}
    im = Img(12, 7)
    for y in range(7):
        for x in range(3):
            ch = left[y][x]
            if ch != ".":
                im.put(x, y, pal[ch])
                # right cap is the mirror, but its top edge loses the highlight (light is top-left)
                rc = pal[ch]
                if ch == "H" and y == 0:
                    rc = GOLD
                if ch == "H" and y in (2, 3):
                    rc = GOLD
                if ch == "F":
                    rc = HI
                if ch == "G" and y in (1, 4):
                    rc = SH if y == 4 else GOLD
                im.put(11 - x, y, rc)
        for x in range(3, 9):
            im.put(x, y, pal[mid[y]] if mid[y] != "H" else (HI if x < 6 else GOLD))
    return im


# ---------------------------------------------------------------- small icons
def make_icons():
    out = {}
    out["icon_heart"] = sprite([
        ".AA.AA.",
        "AHHAAAA",
        "AHAAAAA",
        "AAAAAAS",
        ".AAAAS.",
        "..ASS..",
        "...S...",
    ], {"A": hexc("D55E00"), "H": hexc("F7A15E"), "S": hexc("8C3A00")})
    out["icon_bolt"] = sprite([
        "....HYY",
        "...HYY.",
        "..HYYS.",
        ".HYYYYS",
        "....YS.",
        "...YS..",
        "..YS...",
    ], {"Y": hexc("F0E442"), "H": hexc("FFFBB0"), "S": hexc("A89B10")})
    out["icon_brush"] = sprite([
        ".....HB",
        "....HBS",
        "...HBS.",
        "..FFS..",
        ".WWF...",
        "WWW....",
        "KW.....",
    ], {"B": hexc("56B4E9"), "H": hexc("A6DCF8"), "S": hexc("2E7FB0"), "F": CREAM,
        "W": hexc("CDE8FA"), "K": hexc("2A5C80")})
    out["icon_ilmu"] = sprite([
        "...HH...",
        "..HHGS..",
        ".HHGGGS.",
        "HHGGGGSS",
        "HGGGGSSS",
        ".GGGSSS.",
        "..GSSS..",
        "...SS...",
    ], {"H": hexc("FFF3C8"), "G": hexc("F2D488"), "S": hexc("C9A24A")})
    out["icon_save"] = sprite([
        "......GH",
        ".....GG.",
        "....GS..",
        "...GS...",
        "..FF....",
        ".WWF....",
        "WWW.....",
        "WK......",
    ], {"G": GOLD, "H": HI, "S": SH, "F": CREAM, "W": hexc("F2E6C8"), "K": hexc("5A4020")})
    flask_pal = {"k": hexc("8A5A30"), "O": hexc("00563F"), "G": hexc("009E73"),
                 "H": hexc("5CE0B8"), "S": hexc("006E50")}
    out["flask_full"] = sprite([
        "..kkk..",
        "..OGO..",
        "..OGO..",
        ".OGGGO.",
        "OGHGGGO",
        "OGHGGGO",
        "OGGGGSO",
        "OGGGSSO",
        ".OOOOO.",
    ], flask_pal)
    e = hexc("3C4A45")
    out["flask_empty"] = sprite([
        "..kkk..",
        "..O.O..",
        "..O.O..",
        ".OiiiO.",
        "Oi.iiiO",
        "Oi.iiiO",
        "OiiiiiO",
        "OiiiiiO",
        ".OOOOO.",
    ], {"k": hexc("4A3420"), "O": e, "i": (14, 11, 10, 190), "G": e})
    out["flask_empty"].put(2, 4, hexc("55645F"))
    out["keycap"] = sprite([
        ".OOOOOO.",
        "OWCCCCCO",
        "OCCCCCCO",
        "OCCCCCCO",
        "OCCCCCCO",
        "OCCCCCCO",
        "ODDDDDDO",
        ".OOOOOO.",
    ], {"O": LACQUER, "W": hexc("FFF8E6"), "C": CREAM, "D": hexc("8A7C62")})
    # quest marker: gold lontar leaf with "!" and a 1 px soft glow
    m = Img(7, 9)
    for y in range(1, 8):
        for x in range(1, 6):
            if (x in (1, 5)) and (y in (1, 7)):
                continue
            m.put(x, y, GOLD)
    for y in range(1, 8):
        m.put(1, y, HI) if y > 1 and y < 7 else None
        m.put(5, y, SH) if y > 1 and y < 7 else None
    for x in range(2, 5):
        m.put(x, 1, HI)
        m.put(x, 7, SH)
    ink = hexc("3A2618")
    for y in (2, 3, 4):
        m.put(3, y, ink)
    m.put(3, 6, ink)
    glow = (242, 212, 136, 95)
    for y in range(9):
        for x in range(7):
            if m.get(x, y)[3]:
                continue
            if any(m.get(x + dx, y + dy)[3] and m.get(x + dx, y + dy) != glow
                   for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                m.put(x, y, glow)
    out["marker_quest"] = m
    out["marker_talk"] = sprite([
        ".OOOOO.",
        "OGGGGGO",
        "OdGdGdO",
        "OGGGGGO",
        ".OGOOO.",
        ".OGO...",
        "..O....",
    ], {"O": LACQUER, "G": hexc("CFC8B8"), "d": hexc("5A5040")})
    out["arrow_objective"] = sprite([
        "..OO...",
        "..OHO..",
        "OOOGHO.",
        "OHGGGGO",
        "OOOGSO.",
        "..OSO..",
        "..OO...",
    ], {"O": LACQUER, "H": HI, "G": GOLD, "S": SH})
    out["continue_arrow"] = sprite([
        "HGGGS",
        ".GGS.",
        "..G..",
        "..S..",
    ], {"H": HI, "G": GOLD, "S": SH})
    out["lozenge"] = make_lozenge()
    out["ink_mote"] = sprite([
        ".b.",
        "bCb",
        ".b.",
    ], {"b": (74, 92, 150, 120), "C": (150, 170, 225, 255)})
    out["ember"] = sprite([
        "HO",
        "OD",
    ], {"H": hexc("FFD27A"), "O": hexc("FF9A3A"), "D": hexc("D2561A")})
    return out


def make_cursor():
    im = Img(12, 12)
    body = {}
    for k in range(10):
        pts = [(k, k)]
        if k >= 3:
            pts.append((k + 1, k))
        if k >= 6:
            pts.append((k, k + 1))
        if k == 0:
            col = INDIGO
        elif k <= 2:
            col = CREAM
        elif k == 3:
            col = SH
        elif k <= 5:
            col = GOLD
        else:
            col = hexc("7A4E2C")
        for i, (x, y) in enumerate(pts):
            c = col
            if k >= 6 and i == 1:
                c = hexc("A0693A")
            if k in (4, 5) and i == 1:
                c = HI
            body[(x, y)] = c
    for (x, y), c in body.items():
        im.put(x, y, c)
    for (x, y) in list(body):
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (x + dx, y + dy)
            if n not in body and 0 <= n[0] < 12 and 0 <= n[1] < 12:
                im.put(n[0], n[1], LACQUER)
    return im


# ---------------------------------------------------------------- big art
def bayer(x, y):
    m = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]
    return (m[y & 3][x & 3] + 0.5) / 16.0


def make_sky():
    w, h = 480, 270
    im = Img(w, h)
    top = (22, 31, 58)
    mid = (15, 18, 36)
    bot = (5, 4, 8)
    levels = 7
    for y in range(h):
        t = y / (h - 1)
        if t < 0.55:
            a, b, u = top, mid, t / 0.55
        else:
            a, b, u = mid, bot, (t - 0.55) / 0.45
        for x in range(w):
            col = [a[i] + (b[i] - a[i]) * u for i in range(3)]
            # ordered dither into coarse steps
            q = []
            for v in col:
                s = v / 255.0 * levels
                f = int(s)
                if s - f > bayer(x, y):
                    f += 1
                q.append(min(255, int(f * 255 / levels)))
            im.put(x, y, (q[0], q[1], q[2], 255))
    rnd = random.Random(7)
    for i in range(95):
        x, y = rnd.randrange(w), rnd.randrange(int(h * 0.7))
        k = rnd.random()
        if k < 0.65:
            c = (110, 118, 150, 255)
            im.put(x, y, c)
        elif k < 0.93:
            im.put(x, y, hexc("C9CCE0"))
        else:
            im.put(x, y, hexc("F2E6C8"))
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                im.put(x + dx, y + dy, (120, 125, 160, 255))
    return im


def make_mountains():
    W, H = 520, 140
    im = Img(W, H)

    def wd(x, c):
        d = abs(x - c)
        return min(d, W - d)

    def cone(x, c, peak, base, crater=0):
        d = wd(x, c)
        if d >= base:
            return 0
        v = peak * (1 - (d / base) ** 0.85)
        if crater and d < crater:
            v -= (crater - d) * 0.35 + 1
            v = max(v, peak * 0.85)
        return v

    rnd = random.Random(11)
    jag = [rnd.random() for _ in range(W)]
    jag = [(jag[i] + jag[(i + 1) % W] + jag[(i - 1) % W]) / 3 for i in range(W)]

    def back(x):
        h = 28 + 6 * math.sin(2 * math.pi * 3 * x / W) + 4 * math.sin(2 * math.pi * 7 * x / W + 1)
        h = max(h, cone(x, 130, 112, 190, 9), cone(x, 392, 96, 160, 7), cone(x, 270, 62, 90),
                cone(x, 20, 70, 100), cone(x, 480, 56, 80))
        return h + (jag[x] - 0.5) * 3

    def front(x):
        h = 20 + 8 * math.sin(2 * math.pi * 4 * x / W + 2) + 5 * math.sin(2 * math.pi * 9 * x / W)
        h = max(h, cone(x, 70, 52, 80), cone(x, 330, 46, 90), cone(x, 220, 40, 60), cone(x, 470, 48, 70))
        return h + (jag[(x * 3) % W] - 0.5) * 5

    bt = [int(H - back(x)) for x in range(W)]
    ft = [int(H - front(x)) for x in range(W)]
    for x in range(W):
        for y in range(bt[x], H):
            depth = (y - bt[x]) / 70.0
            u = min(1.0, depth)
            c0, c1 = (46, 42, 72), (20, 17, 36)
            col = [c0[i] + (c1[i] - c0[i]) * u for i in range(3)]
            q = []
            for v in col:
                s = v / 255.0 * 12
                f = int(s)
                if s - f > bayer(x, y):
                    f += 1
                q.append(int(f * 255 / 12))
            im.put(x, y, (q[0], q[1], q[2], 255))
        # rim light on slopes that face the top-left light
        if bt[x] < H:
            rising = bt[(x - 1) % W] > bt[x]
            im.put(x, bt[x], (84, 78, 120, 255) if not rising else (62, 57, 96, 255))
            if not rising:
                im.put(x, bt[x] + 1, (58, 53, 90, 255))
    # faint ember in each crater
    for c in (130, 392):
        y = min(bt[c - 4:c + 5])
        for dx in (-1, 0, 1):
            im.put(c + dx, y, VERM)
        im.put(c, y - 1, alpha(VERM, 170))
    for x in range(W):
        for y in range(ft[x], H):
            im.put(x, y, (11, 9, 8, 255))
        if ft[x] < H:
            im.put(x, ft[x], (30, 25, 22, 255) if bt[(x - 1) % W] > 0 and ft[(x - 1) % W] > ft[x] else (21, 18, 16, 255))
    return im


# --- gunungan
GW, GH = 120, 170
GCX = (GW - 1) / 2.0


def g_hw(y):
    if y < 0 or y > GH - 1:
        return -1
    if y >= 126:
        # slightly rounded base corners
        e = max(0, y - 164)
        return GCX + 0.5 - e * 0.8
    t = (y + 1) / 127.0
    return (GCX + 0.5) * (t ** 0.62)


def g_inside(x, y, m=0.0):
    hw = g_hw(y) - m
    if hw <= 0:
        return False
    if y > GH - 1 - m:
        return False
    return abs(x - GCX) <= hw


def make_gunungan():
    im = Img(GW, GH)
    put = im.put

    def put2(x, y, c):
        put(x, y, c)
        put(GW - 1 - x, y, c)

    DARK = hexc("140E0A")
    DARK2 = hexc("1B120C")
    # body
    for y in range(GH):
        for x in range(GW):
            if g_inside(x, y):
                put(x, y, DARK)
    # faint kawung-ish dot lattice
    for y in range(GH):
        for x in range(GW):
            if g_inside(x, y, 3) and ((x % 6 == 0 and y % 6 == 3) or (x % 6 == 3 and y % 6 == 0)):
                put(x, y, DARK2)
    # inner border (m=4) with pearls
    for y in range(GH):
        for x in range(GW):
            if g_inside(x, y, 4) and not g_inside(x, y, 5):
                put(x, y, SH if (x + y) % 5 else GOLD)

    # gate
    cx = GCX
    gr = 14

    def in_door(x, y, e):
        r = gr + e
        if y >= 126:
            return abs(x - cx) <= r and y <= 163
        return (x - cx) ** 2 + (y - 126) ** 2 <= r * r and (126 - y) <= r

    for y in range(GH):
        for x in range(GW):
            if in_door(x, y, 3) and not in_door(x, y, 1):
                put(x, y, GOLD if (x - cx) < 0 or y < 128 else SH)
            elif in_door(x, y, 1):
                put(x, y, hexc("070504"))
    for y in range(GH):
        for x in range(GW):
            if in_door(x, y, 1) and not in_door(x, y, 0):
                put(x, y, SH)
            if in_door(x, y, 3) and not in_door(x, y, 2):
                put(x, y, HI if x < cx else GOLD) if y < 140 else None
    # door interior: kala-ish lozenges stacked, steps
    for k, yy in enumerate((132, 142, 152)):
        r = 3 - (k == 2)
        for j in range(-r, r + 1):
            for i in range(-(r - abs(j)), r - abs(j) + 1):
                c = GOLD if (i + j) <= 0 else SH
                if i == 0 and j == 0:
                    c = HI
                put(int(cx - 0.5) + i, yy + j, c)
                put(int(cx + 0.5) + i, yy + j, c)
    # pillars with studs flanking the gate
    for side in (-1, 1):
        px = int(round(cx + side * 21.5 + (0.5 if side > 0 else -0.5)))
        for y in range(118, 163):
            put(px, y, SH)
        for y in range(120, 163, 8):
            put(px, y, HI if side < 0 else GOLD)
            put(px + 1, y, GOLD)
            put(px - 1, y, GOLD)
            put(px, y - 1, HI)
            put(px, y + 1, SH)

    # leaf: rotated ellipse, lit upper-left, dark vein
    def leaf(lx, ly, ang, a, b, vein=True, col=GOLD):
        ca, sa = math.cos(ang), math.sin(ang)
        ins = set()
        r = int(max(a, b)) + 2
        for j in range(-r, r + 1):
            for i in range(-r, r + 1):
                px_, py_ = lx + i, ly + j
                u = i * ca + j * sa
                v = -i * sa + j * ca
                if (u / a) ** 2 + (v / b) ** 2 <= 1.0:
                    ins.add((px_, py_))
        for (x, y) in ins:
            c = col
            if (x - 1, y) not in ins or (x, y - 1) not in ins:
                c = HI
            elif (x + 1, y) not in ins or (x, y + 1) not in ins:
                c = SH
            put(x, y, c)
        if vein and a >= 3:
            for t in range(int(-a) + 2, int(a) - 1):
                x = int(round(lx + t * ca))
                y = int(round(ly + t * sa))
                if (x, y) in ins:
                    put(x, y, hexc("2A1B11"))

    def line(x0, y0, x1, y1, col):
        n = int(max(abs(x1 - x0), abs(y1 - y0))) * 2 + 1
        for i in range(n + 1):
            t = i / n
            put(int(round(x0 + (x1 - x0) * t)), int(round(y0 + (y1 - y0) * t)), col)

    def bez(p0, p1, p2, col, steps=60):
        pts = []
        for i in range(steps + 1):
            t = i / steps
            x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0]
            y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]
            pts.append((x, y))
        for (x, y) in pts:
            put(int(round(x)), int(round(y)), col)
        return pts

    # tree of life: trunk
    tx0, tx1 = int(cx - 0.5), int(cx + 0.5)
    for y in range(40, 108):
        put(tx0, y, GOLD if y % 7 else HI)
        put(tx1, y, GOLD if y % 7 else SH)
    # branches
    for k, yk in enumerate((100, 88, 76, 64, 53, 43)):
        L = min(30, g_hw(yk - 9) - 11)
        for side in (-1, 1):
            sx = cx + side * 0.5
            p0 = (sx, yk)
            p1 = (sx + side * L * 0.55, yk + 1)
            p2 = (sx + side * L, yk - 9)
            pts = bez(p0, p1, p2, GOLD)
            ex, ey = p2
            ang = math.atan2(-9 - (-4), side * 1.0)
            leaf(int(round(ex + side * 2)), int(round(ey - 1)), -0.9 * side if side > 0 else math.pi + 0.9, 4, 2.2)
            # drooping leaf at the branch's midpoint
            mx, my = pts[len(pts) // 2]
            leaf(int(round(mx)), int(round(my + 4)), math.pi / 2 + side * 0.5, 3.2, 1.8)
            # curl beside the trunk
            ccx, ccy = int(round(sx + side * 4)), yk - 3
            for a in range(0, 300, 25):
                rr = 2.6 - a / 150.0
                if rr > 0.4:
                    put(int(round(ccx + side * rr * math.cos(math.radians(a)))),
                        int(round(ccy + rr * math.sin(math.radians(a)))), SH)
    # crown
    leaf(int(cx - 0.5), 24, math.pi / 2, 8, 2.6)
    leaf(int(cx + 0.5), 24, math.pi / 2, 8, 2.6)
    leaf(int(cx - 6), 29, math.pi / 2 + 0.7, 6, 2.0)
    leaf(int(cx + 7), 29, math.pi / 2 - 0.7, 6, 2.0)
    leaf(int(cx - 10), 36, math.pi / 2 + 1.1, 5, 1.8)
    leaf(int(cx + 11), 36, math.pi / 2 - 1.1, 5, 1.8)
    for (x, y, c) in ((int(cx - 0.5), 12, HI), (int(cx + 0.5), 12, GOLD), (int(cx - 0.5), 11, HI), (int(cx + 0.5), 11, GOLD),
                      (int(cx - 0.5), 10, GOLD), (int(cx + 0.5), 10, SH)):
        put(x, y, c)
    # flanking spirals beside the gate (right side computed, mirrored)
    def spiral(scx, scy, r0, turns=1.6, cw=1):
        n = int(r0 * 18)
        for i in range(n):
            t = i / n
            r = r0 * (1 - t * 0.85)
            a = cw * (t * turns * 2 * math.pi) + math.pi
            x = int(round(scx + r * math.cos(a)))
            y = int(round(scy + r * math.sin(a)))
            put(x, y, GOLD if (x + y) % 3 else HI)
            put(GW - 1 - x, y, GOLD if (x + y) % 3 else HI)
        # leaf off the tail
        return

    spiral(cx + 38, 150, 8)
    spiral(cx + 38, 130, 6, cw=-1)
    spiral(cx + 34, 112, 5)
    for (lx, ly, ang) in ((cx + 47, 147, -0.5), (cx + 45, 126, 0.4), (cx + 40, 108, 0.2), (cx + 28, 143, 0.9)):
        leaf(int(lx), int(ly), ang, 3.4, 1.7)
        leaf(GW - 1 - int(lx), int(ly), math.pi - ang, 3.4, 1.7)
    # bird-ish finial pair below the first branch pair
    for side in (-1, 1):
        bx = int(cx + side * 12)
        for dx, dy in ((0, 0), (1, 0), (2, -1), (3, -1), (-1, -1), (-2, -2)):
            put(bx + side * dx, 111 + dy, GOLD)
        put(bx + side * 3, 110, HI)
    # outline
    edge = {}
    for y in range(GH):
        for x in range(GW):
            if not g_inside(x, y):
                continue
            outL = not g_inside(x - 1, y)
            outU = not g_inside(x, y - 1)
            outR = not g_inside(x + 1, y)
            outD = not g_inside(x, y + 1) or y == GH - 1
            if outL or outU:
                edge[(x, y)] = HI
            elif outR or outD:
                edge[(x, y)] = SH if y > 160 else GOLD
    for (x, y), c in edge.items():
        put(x, y, c)
    # second thin line one px inside, for a double gold edge
    for y in range(GH):
        for x in range(GW):
            if g_inside(x, y, 1.0) and not g_inside(x, y, 2.0):
                put(x, y, hexc("3A2A12"))
    return im


def radial(w, h, color, power, peak):
    im = Img(w, h)
    cx, cy = (w - 1) / 2.0, (h - 1) / 2.0
    for y in range(h):
        for x in range(w):
            d = math.hypot((x - cx) / (w / 2.0), (y - cy) / (h / 2.0))
            a = max(0.0, 1 - d) ** power * peak
            if a > 0:
                im.put(x, y, (color[0], color[1], color[2], int(a * 255)))
    return im


def make_glow():
    im = radial(128, 128, (255, 186, 98), 2.4, 0.95)
    # warmer core
    cx = cy = 63.5
    for y in range(128):
        for x in range(128):
            d = math.hypot(x - cx, y - cy) / 64.0
            if d < 0.35:
                c = im.get(x, y)
                t = (0.35 - d) / 0.35
                im.put(x, y, (255, int(186 + 50 * t), int(98 + 90 * t), c[3]))
    return im


def make_vignette():
    w, h = 480, 270
    im = Img(w, h)
    for y in range(h):
        for x in range(w):
            dx = (x - (w - 1) / 2.0) / (w / 2.0)
            dy = (y - (h - 1) / 2.0) / (h / 2.0)
            d = math.sqrt(dx * dx * 0.8 + dy * dy * 1.1)
            t = max(0.0, (d - 0.55) / (1.15 - 0.55))
            t = min(1.0, t)
            t = t * t * (3 - 2 * t)
            a = int(t * 215)
            if a:
                im.put(x, y, (5, 4, 6, a))
    return im


def make_light_cone():
    w, h = 96, 160
    im = Img(w, h)
    cx = (w - 1) / 2.0
    for y in range(h):
        t = y / (h - 1.0)
        half = 8 + 40 * t
        vfade = min(1.0, t / 0.12) * (1 - 0.35 * t)
        for x in range(w):
            u = abs(x - cx) / half
            if u >= 1:
                continue
            a = (1 - u) ** 1.6 * vfade * 0.42
            if a > 0.004:
                im.put(x, y, (255, 214, 140, int(a * 255)))
    return im


def make_pedestal():
    w, h = 64, 20
    im = Img(w, h)
    cx = (w - 1) / 2.0
    stone = [hexc("C2B79E"), hexc("A39983"), hexc("857B67"), hexc("665D4D"), hexc("453E33"), hexc("2A251E")]

    def in_ell(x, y, ex, ey, rx, ry):
        return ((x - ex) / rx) ** 2 + ((y - ey) / ry) ** 2 <= 1.0

    def inside(x, y):
        if in_ell(x, y, cx, 5, 31.6, 5.4):
            return True
        if 5 <= y <= 13 and abs(x - cx) <= 31.6:
            return True
        if y >= 13 and in_ell(x, y, cx, 13.4, 31.6, 5.6):
            return True
        return False

    def top(x, y):
        return in_ell(x, y, cx, 5, 31.6, 5.4)

    rnd = random.Random(3)
    for y in range(h):
        for x in range(w):
            if not inside(x, y):
                continue
            if top(x, y):
                # lit plate, brighter toward the upper-left
                d = ((x - cx + 12) / 34.0) ** 2 + ((y - 3.5) / 7.0) ** 2
                i = 0 if d < 0.25 else 1 if d < 0.7 else 2
                if in_ell(x, y, cx, 5, 27.5, 3.6):
                    i = min(5, i + (1 if d > 0.35 else 0))
                    if not in_ell(x, y, cx, 5, 26.0, 2.8):
                        i = 0 if x < cx else 3
                else:
                    i = 0 if x < cx - 6 else 1
                if rnd.random() < 0.04:
                    i = min(5, i + 1)
                im.put(x, y, stone[i])
            else:
                u = (x - cx) / 31.6  # -1 left .. 1 right
                i = 2 if u < -0.45 else 3 if u < 0.15 else 4 if u < 0.7 else 5
                if (y - 6) % 5 == 4:
                    i = min(5, i + 1)
                if rnd.random() < 0.05:
                    i = min(5, i + 1)
                im.put(x, y, stone[i])
    # outline on the underside and a lip line where top meets body
    for y in range(h):
        for x in range(w):
            c = im.get(x, y)
            if c[3] and (not inside(x, y + 1) or not inside(x + 1, y) and x > cx):
                im.put(x, y, hexc("14100D"))
            if c[3] and not top(x, y) and top(x, y - 1) and y > 6:
                im.put(x, y, stone[3] if x > cx else stone[2])
    return im


# ---------------------------------------------------------------- 9-patch preview helper
def nine_patch(src, m, w, h):
    l, t, r, b = m
    out = Img(w, h)
    xs = [(0, l, 0, l), (l, w - r, l, src.w - r), (w - r, w, src.w - r, src.w)]
    ys = [(0, t, 0, t), (t, h - b, t, src.h - b), (h - b, h, src.h - b, src.h)]
    for (dx0, dx1, sx0, sx1) in xs:
        for (dy0, dy1, sy0, sy1) in ys:
            for y in range(dy0, dy1):
                sy = sy0 + min(sy1 - sy0 - 1, int((y - dy0) * (sy1 - sy0) / max(1, dy1 - dy0)))
                for x in range(dx0, dx1):
                    sx = sx0 + min(sx1 - sx0 - 1, int((x - dx0) * (sx1 - sx0) / max(1, dx1 - dx0)))
                    out.p[y][x] = src.p[sy][sx]
    return out


NINE = {
    "panel": (6, 6, 6, 6),
    "panel_dialogue": (8, 8, 8, 8),
    "button_normal": (5, 5, 5, 5),
    "button_hover": (5, 5, 5, 5),
    "button_pressed": (5, 5, 5, 5),
    "button_disabled": (5, 5, 5, 5),
    "tab_on": (5, 5, 5, 5),
    "tab_off": (5, 5, 5, 5),
    "bar_frame": (3, 3, 3, 3),
    "frame_portrait": (8, 8, 8, 8),
}


def main():
    A = {}
    A["panel"] = make_panel()
    A["panel_dialogue"] = make_panel_dialogue()
    A["button_normal"] = make_button(GOLD, SH, hexc("2A1B12"), hexc("1E140D"), hexc("4A3220"), GOLD)
    A["button_hover"] = make_button(HI, GOLD, hexc("40291A"), hexc("301F13"), hexc("6E4D2E"), HI)
    A["button_pressed"] = make_button(SH, GOLD, hexc("160E09"), hexc("1D130C"), None, None,
                                      shadow_top=hexc("0A0605"))
    A["button_disabled"] = make_button(hexc("4D4538"), hexc("2E2A24"), hexc("17130F"), hexc("14110D"), None, None)
    A["tab_on"] = make_tab(True)
    A["tab_off"] = make_tab(False)
    A["slot"] = make_slot(False)
    A["slot_selected"] = make_slot(True)
    A["divider"] = make_divider()
    A["bar_frame"] = make_bar_frame()
    A["frame_portrait"] = make_portrait_frame()
    A.update(make_icons())
    A["cursor"] = make_cursor()
    A["title_sky"] = make_sky()
    A["title_mountains"] = make_mountains()
    A["title_gunungan"] = make_gunungan()
    A["title_glow"] = make_glow()
    A["vignette"] = make_vignette()
    A["pedestal"] = make_pedestal()
    A["light_cone"] = make_light_cone()
    for name, im in A.items():
        im.save(os.path.join(OUT, name + ".png"))
    make_preview(A)
    print("wrote", len(A), "sprites to", OUT)


def make_preview(A):
    S = 3
    W, H = 1500, 1500
    pv = Img(W, H, (30, 26, 28, 255))
    # checker-free dark bg; sprites at 3x
    x, y = 12, 12
    rowh = 0

    def place(im, k=S):
        nonlocal x, y, rowh
        s = im.scaled(k) if k > 1 else im
        if x + s.w + 12 > W:
            x = 12
            y += rowh + 12
            rowh = 0
        pv.paste(s, x, y)
        x += s.w + 12
        rowh = max(rowh, s.h)

    def newrow():
        nonlocal x, y, rowh
        x = 12
        y += rowh + 18
        rowh = 0

    small = ["button_normal", "button_hover", "button_pressed", "button_disabled", "tab_on", "tab_off",
             "slot", "slot_selected", "lozenge", "bar_frame", "icon_heart", "icon_bolt", "icon_brush",
             "icon_ilmu", "icon_save", "flask_full", "flask_empty", "keycap", "marker_quest", "marker_talk",
             "arrow_objective", "continue_arrow", "cursor", "ink_mote", "ember", "divider"]
    for n in small:
        place(A[n])
    newrow()
    # stretched 9-patch demos
    place(nine_patch(A["panel"], NINE["panel"], 90, 56))
    place(nine_patch(A["panel_dialogue"], NINE["panel_dialogue"], 150, 48))
    place(nine_patch(A["frame_portrait"], NINE["frame_portrait"], 48, 48))
    place(nine_patch(A["bar_frame"], NINE["bar_frame"], 60, 7))
    place(nine_patch(A["button_normal"], NINE["button_normal"], 56, 16))
    place(nine_patch(A["button_hover"], NINE["button_hover"], 56, 16))
    place(nine_patch(A["tab_on"], NINE["tab_on"], 50, 16))
    place(nine_patch(A["tab_off"], NINE["tab_off"], 50, 16))
    newrow()
    # composed title scene at 1x, plus class-select pieces
    scene = Img(480, 270, (0, 0, 0, 255))
    scene.paste(A["title_sky"], 0, 0)
    scene.paste(A["title_glow"], 20, 120)
    scene.paste(A["title_mountains"], -20, 130)
    scene.paste(A["title_gunungan"], 330, 90)
    scene.paste(A["vignette"], 0, 0)
    pv.paste(scene, x, y)
    px = x + 492
    gg = A["title_gunungan"].scaled(2)
    pv.paste(gg, px, y)
    px += gg.w + 12
    cs = Img(200, 260, (14, 11, 10, 255))
    cs.paste(A["light_cone"], 52, 30)
    cs.paste(A["pedestal"], 68, 180)
    cs.paste(A["title_glow"], 36, -20)
    pv.paste(cs, px, y)
    cropped = Img(W, 1500)
    for yy in range(min(H, y + 350)):
        cropped.p[yy] = pv.p[yy]
    out = Img(W, y + 350)
    out.p = cropped.p[: y + 350]
    out.save(os.path.join(ROOT, "tools", "ui_preview.png"))


if __name__ == "__main__":
    main()
