#!/usr/bin/env python3
"""Item icon generator (items.md, ui.md 3b). Writes assets/art/items/<id>.png, 16x16, plus tools/items_preview.png.

Each icon is drawn on a 14x14 canvas (chars -> palette), outlined (+1 px each side = 16x16), light from top-left.
Letters: 1 2 3 steel hi/mid/shd | 4 5 6 wood | 7 8 9 gold | A B C primary | X Y Z secondary | k deep dark | w white.
Pusaka (mythic) icons get a small gold (or red for Mpu Gandring) sparkle in a free corner.
"""
import math
import os
import struct
import zlib

# PIL is not installed here, so this file carries its own tiny RGBA image + PNG writer.
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART = os.path.join(ROOT, "assets", "art")


def hexc(s, a=255):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), a)


def ramp(base):
    """(hi, mid, shd, deep) from one mid colour, same rule as pixlib.ramp."""
    r, g, b, a = base
    hi = tuple(int(v + (255 - v) * 0.35) for v in (r, g, b)) + (a,)
    shd = (int(r * 0.68), int(g * 0.66), int(b * 0.74), a)
    deep = (int(r * 0.42), int(g * 0.40), int(b * 0.52), a)
    return hi, base, shd, deep


class Img:
    def __init__(self, w, h, fill=(0, 0, 0, 0)):
        self.w, self.h = w, h
        self.p = [fill] * (w * h)
        self.size = (w, h)

    def get(self, x, y):
        return self.p[y * self.w + x]

    def put(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.p[y * self.w + x] = c

    def over(self, other, ox, oy):
        for y in range(other.h):
            for x in range(other.w):
                c = other.get(x, y)
                if c[3]:
                    self.put(ox + x, oy + y, c)

    def scaled(self, k):
        o = Img(self.w * k, self.h * k)
        for y in range(o.h):
            for x in range(o.w):
                o.p[y * o.w + x] = self.get(x // k, y // k)
        return o

    def save(self, path):
        raw = b"".join(b"\x00" + b"".join(bytes(c) for c in self.p[y * self.w:(y + 1) * self.w]) for y in range(self.h))

        def chunk(t, d):
            return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)
        data = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", self.w, self.h, 8, 6, 0, 0, 0)) \
            + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
        with open(path, "wb") as f:
            f.write(data)


def outline(img, k=0.35):
    """Pad 1 px each side, then outline with the darkest adjacent fill * k (as pixlib.outline)."""
    src = Img(img.w + 2, img.h + 2)
    src.over(img, 1, 1)
    out = Img(src.w, src.h)
    out.p = list(src.p)
    for y in range(src.h):
        for x in range(src.w):
            if src.get(x, y)[3]:
                continue
            best = None
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < src.w and 0 <= ny < src.h and src.get(nx, ny)[3] == 255:
                    c = src.get(nx, ny)
                    if best is None or sum(c[:3]) < sum(best[:3]):
                        best = c
            if best:
                r, g, b, _ = best
                out.put(x, y, (int(r * k), int(g * k * 0.95), min(255, int(b * k * 1.1)), 255))
    return out

OUT = os.path.join(ART, "items")
N = 14

BASE = {
    "1": hexc("#E8EFF4"), "2": hexc("#A4B2C2"), "3": hexc("#5F6E86"),
    "4": hexc("#B98650"), "5": hexc("#8A5A32"), "6": hexc("#55341E"),
    "7": hexc("#F2D488"), "8": hexc("#C9A24A"), "9": hexc("#7A5A22"),
    "k": hexc("#1B1512"), "w": hexc("#FFFFFF"),
}


class C:
    def __init__(self):
        self.g = [[None] * N for _ in range(N)]

    def px(self, x, y, ch):
        x, y = int(x), int(y)
        if 0 <= x < N and 0 <= y < N:
            self.g[y][x] = None if ch == "." else ch

    def line(self, a, b, ch):
        (x0, y0), (x1, y1) = a, b
        n = max(abs(x1 - x0), abs(y1 - y0), 1)
        for i in range(n + 1):
            self.px(round(x0 + (x1 - x0) * i / n), round(y0 + (y1 - y0) * i / n), ch)

    def bar(self, a, b, chars, axis="x"):
        """Thick line: chars[i] drawn shifted i px along axis (x: light on left side, y: light on top)."""
        for i, ch in reversed(list(enumerate(chars))):
            d = (i, 0) if axis == "x" else (0, i)
            self.line((a[0] + d[0], a[1] + d[1]), (b[0] + d[0], b[1] + d[1]), ch)

    def rect(self, x, y, w, h, ch):
        for j in range(h):
            for i in range(w):
                self.px(x + i, y + j, ch)

    def blit(self, rows, ox=0, oy=0):
        for j, r in enumerate(rows):
            for i, ch in enumerate(r):
                if ch not in ". ":
                    self.px(ox + i, oy + j, ch)

    def shaded(self, test, hi, mid, shd, cx=6.5, cy=6.5, k=0.0):
        """Fill every pixel where test(x,y) with a 3-tone by (x+y) position (top-left light)."""
        pts = [(x, y) for y in range(N) for x in range(N) if test(x, y)]
        for x, y in pts:
            v = (x - cx) + (y - cy)
            self.px(x, y, hi if v < -1.8 + k else (shd if v > 1.8 + k else mid))


def pal_for(ext):
    p = dict(BASE)
    for key, col in ext.items():
        h, m, s, _ = ramp(hexc(col))
        p[key.upper() if False else key] = m
        p[{"A": "A", "X": "X"}.get(key, key)] = m
    return p


def make_pal(a=None, x=None):
    a, x = a or "#8C8C8C", x or "#C9A24A"
    p = dict(BASE)
    for (hi, mid, sh), col in ((("A", "B", "C"), a), (("X", "Y", "Z"), x)):
        if col:
            h, m, s, d = ramp(hexc(col))
            p[hi], p[mid], p[sh] = h, m, s
    return p


def render(c, pal):
    img = Img(N, N)
    for y in range(N):
        for x in range(N):
            ch = c.g[y][x]
            if ch:
                img.put(x, y, pal[ch])
    return outline(img)


def sparkle(img, spot, col):
    """Small 4-point glint in a free corner (pusaka aura)."""
    cx, cy = spot
    gold = hexc(col)
    soft = hexc(col, 150)
    for dx, dy, c in ((0, 0, gold), (1, 0, soft), (-1, 0, soft), (0, 1, soft), (0, -1, soft)):
        x, y = cx + dx, cy + dy
        if 0 <= x < 16 and 0 <= y < 16 and img.get(x, y)[3] == 0:
            img.put(x, y, c)


ICONS = {}   # id -> (builder, palette args, mythic spot or None, sparkle colour)


def icon(id, a=None, x=None, spot=None, spark="#F2D488"):
    def deco(fn):
        ICONS[id] = (fn, make_pal(a, x), spot, spark)
        return fn
    return deco


# ---------------------------------------------------------------- weapons
@icon("dagger", a="#7A3A2A")
def _(c):
    c.bar((10, 1), (5, 6), "12")
    c.px(11, 0, "1")
    c.line((3, 5), (7, 9), "8")
    c.px(3, 5, "7")
    c.bar((4, 8), (2, 10), "45")
    c.px(1, 11, "9"); c.px(0, 12, "8")


@icon("short_sword")
def _(c):
    c.bar((11, 0), (5, 6), "123")
    c.line((3, 6), (8, 11), "8"); c.line((3, 5), (4, 6), "7")
    c.bar((4, 9), (2, 11), "45")
    c.rect(0, 12, 2, 2, "8"); c.px(0, 12, "7")


@icon("broadsword")
def _(c):
    c.bar((11, 0), (4, 7), "1223")
    c.px(12, 0, "1")
    c.line((2, 7), (8, 13), "9"); c.line((2, 6), (3, 7), "8"); c.line((3, 6), (9, 12), "8")
    c.line((2, 7), (2, 7), "7")
    c.bar((3, 10), (1, 12), "45")
    c.px(0, 13, "8")


@icon("axe")
def _(c):
    c.bar((2, 13), (9, 4), "45")
    c.blit([
        "......11.....",
        ".....1222....",
        "....12222211.",
        "....12.4522 3",
        "....12.4 223.",
        "....1222233..",
        ".....2223....",
        "......33.....",
    ], 1, 0)
    c.bar((2, 13), (4, 11), "45")


@icon("spear", a="#B8432B")
def _(c):
    c.bar((1, 13), (10, 4), "45")
    c.blit([
        "....1.",
        "...12.",
        "..123.",
        ".1223.",
        ".223..",
        "..3...",
    ], 8, 0)
    c.blit(["AA", "AB", "BC"], 7, 4)
    c.px(9, 3, "k"); c.px(9, 3, "5")


@icon("golok")
def _(c):
    c.blit([
        ".........11...",
        "........1222..",
        ".......12222..",
        "......122223..",
        ".....1222233..",
        "....12222333..",
        "...122223.3...",
        "..1222233.....",
        "..12223.......",
    ], 0, 0)
    c.px(10, 0, "."); 
    c.line((1, 8), (4, 11), "8")
    c.bar((2, 10), (0, 12), "45")
    c.px(1, 9, "7")


@icon("hunting_bow")
def _(c):
    c.blit([
        "....4555......",
        "..45....w.....",
        ".45......w....",
        ".5........w...",
        "45........w...",
        "45........w...",
        "5.........w...",
        "5.........w...",
        "45........w...",
        "45........w...",
        ".5........w...",
        ".45......w....",
        "..45....w.....",
        "....4555......",
    ])
    for y in range(0, 14):
        pass
    c.g = [[("2" if ch == "w" else ch) for ch in row] for row in c.g]
    c.line((3, 6), (11, 6), "6"); c.px(12, 6, "1"); c.px(11, 5, "1"); c.px(11, 7, "1")
    c.px(3, 5, "A"); c.px(3, 7, "A")


@icon("longbow", a="#4F7A38")
def _(c):
    for y in range(14):
        x = round(2 + 3.0 * math.sin(math.pi * y / 13) * -1 + 3)
    pts = [(6, 0), (5, 1), (4, 2), (3, 3), (3, 4), (2, 5), (2, 6), (2, 7), (2, 8), (3, 9), (3, 10), (4, 11), (5, 12), (6, 13)]
    for i, (x, y) in enumerate(pts):
        c.px(x, y, "5"); c.px(x + 1, y, "4") if i in (1, 2, 3) else None
        c.px(x - 1 if x > 2 else x, y, "4")
    c.line((6, 0), (6, 13), "2")
    c.line((3, 6), (13, 6), "6"); c.px(13, 6, "1"); c.px(12, 5, "1"); c.px(12, 7, "1")
    c.px(3, 5, "A"); c.px(3, 7, "A")


@icon("crossbow")
def _(c):
    c.blit([
        "..............",
        "..............",
        "......6.......",
        "...455.55.....",
        "..45..6..5....",
        ".45...6...5...",
        ".5....6....5..",
    ], 0, 0)
    c.line((1, 4), (12, 4), "3")
    c.line((1, 4), (1, 4), "2")
    c.rect(5, 5, 2, 7, "5"); c.rect(5, 5, 1, 7, "4")
    c.rect(4, 11, 4, 2, "5"); c.px(4, 11, "4")
    c.line((6, 2), (6, 8), "2"); c.px(6, 1, "1")
    c.px(6, 5, "9")


@icon("tombak_prajurit", a="#C63A30")
def _(c):
    c.bar((1, 14), (10, 5), "45")
    c.blit([
        "...1.",
        "..12.",
        ".123.",
        ".23..",
    ], 10, 1)
    c.blit(["XX", "AB", "BC", "A."], 8, 5)
    c.px(2, 13, "X"); c.px(1, 14, "X")


@icon("kipas", a="#B8306A")
def _(c):
    c.blit([
        "...XXXXXX...",
        "..XABXBAXX..",
        ".XABBXBBABX.",
        ".ABBXBBXBBAC",
        "..BBXBBXBBC.",
        "...BBXXBBC..",
        "....B45C....",
        ".....45.....",
        ".....45.....",
        ".....X5.....",
    ], 2, 2)


@icon("bandring", a="#6A4A2A")
def _(c):
    c.blit([
        "..44......44",
        ".4..4....4..",
        ".4...4..4...",
        "..4...44....",
        "...4.BBBB...",
        "....B1222C..",
        "....B2223C..",
        ".....CCCC...",
    ], 2, 3)


@icon("kayon", a="#C23A2E")
def _(c):
    c.bar((2, 14), (8, 8), "45")
    c.blit([
        "....X...",
        "...XYX..",
        "..XYAYX.",
        ".XYYAYYX",
        ".XYAYAYZ",
        "..XYYYZ.",
        "...YYZ..",
    ], 7, 1)


@icon("oak_staff", a="#6FA84B")
def _(c):
    c.bar((2, 13), (10, 5), "45")
    c.blit([
        "..AA..",
        ".ABBA.",
        "ABBBBC",
        ".BBBC.",
        "..CC..",
    ], 8, 0)
    c.px(9, 1, "7"); c.px(12, 2, "C")
    c.rect(9, 4, 2, 2, "5")


@icon("iron_staff", a="#5DB1D6")
def _(c):
    c.bar((2, 13), (10, 5), "23")
    c.px(3, 12, "k")
    c.blit([
        "..AA..",
        ".ABBA.",
        "AB1BBC",
        ".BBBC.",
        "..CC..",
    ], 8, 0)
    c.line((9, 4), (12, 4), "3"); c.line((9, 5), (11, 5), "2")
    c.px(8, 6, "2")


@icon("kujang", spot=(13, 1))
def _(c):
    c.blit([
        "....1.........",
        "...12.........",
        "...122........",
        "..1223........",
        "..1223......1.",
        "..12233....12.",
        "..12223...123.",
        "..122231.1223.",
        "..12222312233.",
        "..1222222233..",
        "...12222233...",
    ], 0, 0)
    c.px(4, 6, "k"); c.px(5, 8, "k")
    c.rect(3, 11, 5, 1, "8"); c.px(3, 11, "7"); c.px(7, 11, "9")
    c.rect(4, 12, 2, 2, "5"); c.px(4, 12, "4"); c.px(5, 13, "6")


@icon("keris_luk_7", a="#7A3A2A", spot=(13, 1))
def _(c):
    offs = [0, 1, 1, 0, -1, -1, 0, 1, 1, 0]
    for i, o in enumerate(offs):
        cx = 6 + o
        if i == 0:
            c.px(cx + 1, i, "1")
        else:
            c.px(cx, i, "1"); c.px(cx + 1, i, "2")
            if i >= 7:
                c.px(cx + 2, i, "3")
    c.px(5, 9, "2"); c.px(6, 9, "1")
    c.rect(3, 10, 7, 1, "8"); c.px(3, 10, "7"); c.px(9, 10, "9")
    c.rect(6, 11, 2, 2, "5"); c.px(6, 11, "4")
    c.rect(5, 13, 4, 1, "8"); c.px(5, 13, "7")


@icon("keris_mpu_gandring", a="#C04A7A", spot=(13, 1), spark="#E0485A")
def _(c):
    offs = [0, 1, 1, 0, -1, -1, 0, 1, 1, 0]
    for i, o in enumerate(offs):
        cx = 6 + o
        if i == 0:
            c.px(cx + 1, i, "A")
        else:
            c.px(cx, i, "A"); c.px(cx + 1, i, "B")
            if i >= 7:
                c.px(cx + 2, i, "C")
    c.px(5, 9, "B"); c.px(6, 9, "A")
    c.rect(3, 10, 7, 1, "3"); c.px(3, 10, "2")
    c.rect(6, 11, 2, 2, "6"); c.px(6, 11, "5")
    c.rect(5, 13, 4, 1, "3"); c.px(5, 13, "2")
    c.px(7, 4, "k"); c.px(5, 7, "k")


@icon("panah_pasopati", a="#F2D488", spot=(2, 2))
def _(c):
    c.bar((2, 11), (10, 3), "45")
    c.blit([
        "..7...",
        ".178..",
        "17788.",
        ".1788.",
        "..78..",
    ], 9, -1)
    c.px(10, 2, "7")
    c.blit(["XX", "XY", "YZ"], 0, 10)
    c.blit(["X.", "XY"], 2, 9)
    c.px(12, 2, "1")


@icon("cakra", spot=(1, 1))
def _(c):
    cx = cy = 6.5

    def r_of(x, y):
        dx, dy = x - cx, y - cy
        th = math.atan2(dy, dx)
        return math.hypot(dx, dy), th

    def body(x, y):
        r, th = r_of(x, y)
        spike = 4.2 + 2.2 * max(0.0, math.cos(8 * th)) ** 2
        return r <= spike and r >= 1.9
    c.shaded(body, "1", "2", "3")
    for x in range(N):
        for y in range(N):
            r, th = r_of(x, y)
            if 3.0 <= r <= 3.9 and c.g[y][x]:
                c.px(x, y, "7" if (x + y) < 13 else "8")
            if r < 2.7 and r >= 1.9 and c.g[y][x]:
                c.px(x, y, "3" if (x + y) > 12 else "2")


# ---------------------------------------------------------------- armor
@icon("padded_tunic", a="#C9B38A")
def _(c):
    c.blit([
        "..AABBBBAA..",
        ".ABBBkkBBBC.",
        "ABBBBBBBBBBC",
        "ABBBBBBBBBBC",
        "BBABBBBBBCBC",
        "BCABBBBBBCBC",
        ".CABBBBBBCC.",
        "..ABBBBBBC..",
        "..ABBBBBBC..",
        "..ABBBBBBC..",
        "..ABBBBBBC..",
        "..BCCCCCCC..",
    ], 1, 1)
    for y in (4, 6, 8, 10):
        c.px(7, y, "C"); c.px(8, y, "C")
    c.line((7, 3), (7, 11), "C") if False else None
    c.px(6, 2, "C"); c.px(9, 2, "C")


@icon("leather_armor", a="#9A6034", x="#6B4326")
def _(c):
    c.blit([
        "..AAB..BAA..",
        ".ABBBkkBBBC.",
        "ABBBBBBBBBBC",
        "ABBBBBBBBBBC",
        "BBXBBBBBBXCC",
        "BCXYBBBBYXCB",
        ".CXYBBBBYXC.",
        "..XYBBBBYX..",
        "..XYYYYYYX..",
        "..BBBBBBBC..",
        "..BBBBBBBC..",
        "..BCCCCCCC..",
    ], 1, 1)
    c.px(7, 6, "8"); c.px(8, 6, "9")
    c.px(7, 8, "8"); c.px(8, 8, "9")


@icon("chainmail")
def _(c):
    c.blit([
        "..223..322..",
        ".22333k33332",
        "223232323233",
        "232323232323",
        "322323232323",
        "322232323233",
        ".32323232323",
        "..2323232..3",
        "..3232323232",
        "..2323232323",
        "..3232323233",
        "..3333333333",
    ], 1, 1)
    c.g = [[("1" if (ch == "2" and (x + y) % 4 == 0) else ch) for x, ch in enumerate(row)] for y, row in enumerate(c.g)]
    for y in range(N):
        for x in range(N):
            if c.g[y][x] and (x + y) % 2 == 0 and c.g[y][x] in "23":
                pass


@icon("iket_sunda", a="#1F3F7A", x="#C9A24A", spot=(13, 1))
def _(c):
    c.blit([
        "......AA......",
        ".....ABBA.....",
        "....ABBBBA....",
        "...ABBBBBBC...",
        "..ABBXBBXBBC..",
        ".ABBBBBBBBBBC.",
        ".BBXBBBBBBXBBC",
        ".BCCCCCCCCCCC.",
        ".XXXXXXXXXXXX.",
        "..BC......BC..",
        "..BB......BB..",
        "...C......C...",
    ], 0, 1)
    c.px(7, 6, "X"); c.px(5, 8, "X"); c.px(9, 8, "X")


@icon("blangkon", a="#5A3A22", x="#C9A24A", spot=(13, 1))
def _(c):
    c.blit([
        "....AAAAAA..",
        "...ABBBBBBA.",
        "..ABBXBBXBBC",
        ".ABBBBBBBBBC",
        ".ABXBBYBBXBC",
        ".ABBBBBBBBBC",
        ".BXXXXXXXXYC",
        ".BCCCCCCCCCC",
    ], 1, 4)
    c.blit([
        ".AAA",
        "ABBB",
        "BBBB",
        "BBBC",
        ".BCC",
    ], 0, 6)
    c.px(2, 7, "1") if False else None
    c.px(2, 8, "X"); c.px(1, 9, "C")
    c.px(6, 5, "8"); c.px(9, 6, "8")


@icon("baju_batik", a="#6B3F22", x="#E0B25A", spot=(13, 1))
def _(c):
    c.blit([
        "..AAB..BAA..",
        ".ABBBkkBBBC.",
        "ABBBBBBBBBBC",
        "ABBBBBBBBBBC",
        "BBABBBBBBCBB",
        "BCABBBBBBCBC",
        ".CABBBBBBCC.",
        "..ABBBBBBC..",
        "..ABBBBBBC..",
        "..ABBBBBBC..",
        "..ABBBBBBC..",
        "..BCCCCCCC..",
    ], 1, 1)
    for (x, y) in ((6, 5), (9, 5), (7, 7), (10, 7), (6, 9), (9, 9), (8, 6), (8, 8), (8, 10), (4, 7), (12, 7)):
        c.px(x, y, "X")
    for (x, y) in ((7, 6), (6, 8), (9, 8), (7, 10), (10, 10)):
        c.px(x, y, "Y")
    c.px(4, 4, "X"); c.px(12, 4, "X"); c.px(2, 6, "X"); c.px(14, 6, "X") if False else None


@icon("kain_hijau", a="#2F8F5B", x="#7CD6A0", spot=(13, 1))
def _(c):
    c.blit([
        ".AAAAAAAAAAA..",
        "ABBBBBBBBBBBC.",
        "ABBXBBBBBBBBBC",
        "ABBBBBBCBBBBBC",
        "ABBBBBBBCBBBXC",
        ".BBBCBBBBBBBBC",
        ".BBBBCBBBBBBC.",
        ".BBXBBBCBBBBC.",
        ".BBBBBBBBCBBC.",
        "..BBCBBBBBBC..",
        "..BBBBBBBBCC..",
        "..XYXYXYXYXY..",
    ], 0, 1)
    c.px(0, 0, "."); c.px(12, 12, "Z")


# ---------------------------------------------------------------- accessories
@icon("iron_ring")
def _(c):
    def ring(x, y):
        return 4.6 <= math.hypot((x - 6.5) / 1.0, (y - 7.0) / 1.15) * 1.0 <= 6.0 and math.hypot(x - 6.5, y - 6.5) <= 6.5 and math.hypot(x - 6.5, y - 6.5) >= 3.3
    c.shaded(lambda x, y: 3.1 <= math.hypot(x - 6.5, y - 6.5) <= 5.6, "2", "3", "3", k=-0.3)
    for y in range(N):
        for x in range(N):
            if c.g[y][x] and (x + y) < 10:
                c.px(x, y, "2")
    c.px(4, 3, "1"); c.px(3, 4, "1"); c.px(5, 2, "1")


@icon("amulet", a="#B8432B")
def _(c):
    c.line((2, 0), (5, 4), "6"); c.line((11, 0), (8, 4), "6")
    c.shaded(lambda x, y: math.hypot(x - 6.5, y - 8.5) <= 4.2, "A", "B", "C", cy=8.5)
    c.shaded(lambda x, y: 3.2 <= math.hypot(x - 6.5, y - 8.5) <= 4.4, "7", "8", "9", cy=8.5)
    for y in range(N):
        for x in range(N):
            if math.hypot(x - 6.5, y - 8.5) < 3.2 and c.g[y][x]:
                c.px(x, y, "B")
    c.px(5, 7, "1"); c.px(6, 7, "A"); c.px(5, 8, "A")


@icon("feather_charm", a="#3FA9A0")
def _(c):
    c.line((2, 12), (11, 1), "6")
    c.blit([
        "...........A",
        "..........AB",
        ".........ABB",
        "........ABBC",
        ".......ABBC.",
        "......ABBC..",
        ".....ABBC...",
        "....ABBC....",
        "...ABBC.....",
        "...BBC......",
    ], 1, 1)
    c.line((2, 12), (11, 2), "6")
    c.line((3, 11), (10, 4), "A")
    c.px(1, 13, "8"); c.px(2, 13, "8"); c.px(1, 12, "7")


@icon("silver_bangle")
def _(c):
    c.shaded(lambda x, y: 3.6 <= math.hypot((x - 6.5) * 0.85, (y - 6.5) * 1.0) <= 5.9, "1", "2", "3")
    for (x, y) in ((4, 3), (3, 4), (5, 2), (3, 5)):
        c.px(x, y, "w")


@icon("stone_ring")
def _(c):
    c.shaded(lambda x, y: 3.4 <= math.hypot(x - 6.5, y - 7.5) <= 5.6, "7", "8", "9", cy=7.5)
    c.shaded(lambda x, y: math.hypot(x - 6.5, y - 2.3) <= 2.2, "1", "2", "3", cy=2.3)
    c.px(5, 1, "w"); c.px(5, 2, "1")


@icon("lontar_kuno", a="#C9B070", x="#6B5A2A", spot=(13, 1))
def _(c):
    c.rect(0, 4, 14, 6, "B")
    c.line((0, 4), (13, 4), "A"); c.line((0, 9), (13, 9), "C")
    c.px(0, 4, "."); c.px(13, 9, ".")
    for x in range(2, 12):
        if x % 3 != 0:
            c.px(x, 6, "Z"); c.px(x, 7, "Z") if x % 2 == 0 else None
    c.px(3, 5, "Z"); c.px(6, 5, "Z"); c.px(9, 5, "Z"); c.px(5, 8, "Z"); c.px(8, 8, "Z")
    c.px(3, 6, "B"); c.px(6, 6, "B"); c.px(9, 6, "B")
    c.px(1, 6, "k"); c.px(12, 6, "k")
    c.line((2, 3), (2, 11), "6") if False else None
    c.px(1, 6, "6"); c.px(12, 6, "6")
    c.line((0, 6), (13, 6), "B") if False else None
    c.px(6, 4, "8"); c.px(7, 9, "9")


@icon("batu_kali", a="#6E8793", spot=(13, 1))
def _(c):
    c.shaded(lambda x, y: ((x - 6.5) / 5.8) ** 2 + ((y - 7.5) / 4.4) ** 2 <= 1.0, "A", "B", "C", cy=7.5)
    c.px(4, 5, "w"); c.px(5, 5, "w"); c.px(4, 6, "w")
    c.px(8, 8, "C"); c.px(9, 9, "C")
    c.px(7, 6, "9"); c.px(8, 6, "8")


@icon("sabuk_galuh", a="#6B2A2A", spot=(13, 1))
def _(c):
    c.rect(0, 4, 14, 6, "B")
    c.line((0, 4), (13, 4), "A"); c.line((0, 9), (13, 9), "C")
    c.rect(4, 3, 6, 8, "8")
    c.rect(4, 3, 6, 1, "7"); c.rect(4, 10, 6, 1, "9")
    c.rect(5, 5, 4, 4, "9")
    c.rect(6, 6, 2, 2, "7"); c.px(6, 6, "w")
    for x in (1, 2, 11, 12):
        c.px(x, 6, "8")


@icon("jimat", a="#C9A24A", x="#B8432B", spot=(13, 1))
def _(c):
    c.line((6, 0), (6, 2), "6"); c.line((7, 0), (7, 2), "6")
    c.px(5, 2, "8"); c.px(8, 2, "8")
    c.blit([
        "..XXXX..",
        ".XYYYYX.",
        "ABBBBBBC",
        "ABBBBBBC",
        "ABBkkBBC",
        "ABBBkBBC",
        "ABBkkBBC",
        ".BBBBBC.",
        "..CCCC..",
    ], 3, 3)
    c.px(6, 3, "Y"); c.px(7, 3, "Z")
    c.line((4, 5), (9, 5), "Z")


# ---------------------------------------------------------------- extras
@icon("jamu", a="#6FB34F", x="#C9A24A")
def _(c):
    c.blit([
        "..44..",
        "..55..",
        "..22..",
        ".2112.",
        ".1..3.",
    ], 4, 0)
    c.shaded(lambda x, y: y >= 5 and ((x - 6.5) / 4.6) ** 2 + ((y - 9.2) / 4.0) ** 2 <= 1.0, "2", "2", "3", cy=9.0)
    c.shaded(lambda x, y: y >= 7 and ((x - 6.5) / 3.8) ** 2 + ((y - 9.5) / 3.2) ** 2 <= 1.0, "A", "B", "C", cy=9.5)
    c.px(4, 6, "w"); c.px(4, 7, "1"); c.px(5, 6, "1")
    c.px(5, 8, "1")


@icon("ilmu", a="#5DB1D6", x="#C9A24A")
def _(c):
    c.blit([
        "......",
    ], 0, 0)
    c.shaded(lambda x, y: abs(x - 6.5) + abs(y - 6.5) * 0.8 <= 6.3, "1", "A", "C", k=-0.6)
    c.shaded(lambda x, y: abs(x - 6.5) + abs(y - 6.5) * 0.8 <= 6.3 and abs(x - 6.5) + abs(y - 6.5) * 0.8 >= 5.0, "7", "8", "9")
    c.px(5, 5, "w"); c.px(6, 4, "1"); c.px(4, 6, "1"); c.px(5, 6, "1")
    c.line((6, 7), (7, 8), "B") if False else None


@icon("laras_lontar", a="#C9B070", x="#B8432B")
def _(c):
    c.rect(0, 4, 14, 6, "B")
    c.line((0, 4), (13, 4), "A"); c.line((0, 9), (13, 9), "C")
    c.px(0, 4, "."); c.px(13, 9, ".")
    for x in (3, 4, 6, 8, 9, 11):
        c.px(x, 6, "X"); c.px(x, 7, "Y") if x % 2 else None
    c.px(6, 5, "Y"); c.px(10, 8, "Y")
    c.px(1, 6, "6"); c.px(12, 6, "6")
    c.px(7, 3, "X"); c.px(7, 10, "X")


@icon("laras_ribbon", a="#B8432B")
def _(c):
    c.blit([
        "AAA...AAA",
        "ABBA.ABBB",
        "ABBBkBBBC",
        "ABBBkBBCC",
        ".CBBkBBC.",
        "..CCBCC..",
    ], 2, 3)
    c.blit([
        "BB",
        "BC",
        "BC",
        "C.",
    ], 5, 9)
    c.blit(["B.", "BC", ".C"], 8, 9)
    c.px(6, 5, "A")


@icon("boeh_rarang", a="#B8432B", x="#E0B25A")
def _(c):
    c.blit([
        "AAAAAAAAAAAAA",
        "ABBBBBBBBBBBC",
        "AXBXBXBXBXBXC",
        "ABYBYBYBYBYBC",
        "AXBXBXBXBXBXC",
        "ABBBBBBBBBBBC",
        "CCCCCCCCCCCCC",
    ], 0, 3)
    c.px(0, 10, "A"); c.px(2, 10, "A"); c.px(4, 10, "A"); c.px(6, 10, "A"); c.px(8, 10, "A"); c.px(10, 10, "A"); c.px(12, 10, "A")
    c.px(0, 11, "B"); c.px(4, 11, "B"); c.px(8, 11, "B"); c.px(12, 11, "B")


@icon("flask_shard", a="#6FB34F")
def _(c):
    c.blit([
        "......1.....",
        ".....12.....",
        "....12A.....",
        "...12AB.....",
        "..12ABBC....",
        "..2ABBBC....",
        ".2ABBBBBC...",
        ".2ABBBBBCC..",
        "..3CBBBCC3..",
        "...33CC33...",
    ], 1, 2)
    c.px(5, 5, "w"); c.px(4, 7, "1")


@icon("herb_pouch", a="#6B8A3A", x="#B98650")
def _(c):
    c.blit([
        "..XYYX..",
        "...kk...",
        "..ABBC..",
        ".ABBBBC.",
        "ABBBBBBC",
        "ABBBBBBC",
        "ABBBBBBC",
        ".BBBBBC.",
        "..CCCC..",
    ], 3, 4)
    c.blit([".G.G", "GGGG"], 4, 2) if False else None
    c.px(5, 3, "6"); c.px(6, 2, "A"); c.px(7, 1, "A"); c.px(8, 2, "B"); c.px(9, 3, "A"); c.px(7, 2, "B")
    c.px(7, 3, "B"); c.px(6, 3, "A")


@icon("herb", a="#5FAE4A")
def _(c):
    c.line((6, 13), (6, 5), "6")
    c.blit([
        "AAB.....",
        "ABBB....",
        "ABBBC...",
        ".BBC....",
    ], 0, 6) if False else None
    c.blit(["AB.", "ABB", "BBC", ".C."], 1, 6)
    c.blit(["..BA", ".BBB", "BBBC", ".CC."], 7, 4)
    c.blit(["AAB", "ABBB", "BBBC", ".CC"], 4, 0)
    c.px(6, 4, "6")


@icon("gulungan", a="#E3D3A8", x="#B8432B")
def _(c):
    c.rect(1, 3, 12, 8, "B")
    c.line((1, 3), (12, 3), "A")
    c.line((1, 10), (12, 10), "C")
    c.rect(0, 2, 2, 10, "8"); c.rect(12, 2, 2, 10, "8")
    c.line((0, 2), (0, 11), "7"); c.line((13, 2), (13, 11), "9")
    c.px(0, 2, "7"); c.px(13, 2, "8")
    for x in (3, 4, 6, 8, 9):
        c.px(x, 5, "X"); c.px(x, 7, "X") if x % 2 == 0 else None
    c.px(5, 6, "Y"); c.px(7, 6, "Y"); c.px(10, 6, "Y"); c.px(4, 8, "Y"); c.px(8, 8, "Y")


def build():
    os.makedirs(OUT, exist_ok=True)
    out = {}
    for id, (fn, pal, spot, spark) in ICONS.items():
        c = C()
        fn(c)
        img = render(c, pal)
        if spot:
            sparkle(img, spot, spark)
        assert img.size == (16, 16), id
        img.save(os.path.join(OUT, id + ".png"))
        out[id] = img
    return out


FONT = {
    "a": "010101111101101", "b": "110101110101110", "c": "011100100100011", "d": "110101101101110", "e": "111100110100111",
    "f": "111100110100100", "g": "011100101101011", "h": "101101111101101", "i": "111010010010111", "j": "001001001101010",
    "k": "101101110101101", "l": "100100100100111", "m": "101111111101101", "n": "110101101101101", "o": "010101101101010",
    "p": "110101110100100", "q": "010101101110011", "r": "110101110101101", "s": "011100010001110", "t": "111010010010010",
    "u": "101101101101111", "v": "101101101101010", "w": "101101111111101", "x": "101101010101101", "y": "101101010010010",
    "z": "111001010100111", "_": "000000000000111", "0": "111101101101111", "1": "010110010010111", "2": "110001010100111",
    "3": "110001010001110", "4": "101101111001001", "5": "111100110001110", "6": "011100111101111", "7": "111001010010010",
    "8": "111101111101111", "9": "111101111001110",
}


def text(img, x, y, s, col):
    for ch in s:
        g = FONT.get(ch)
        if g:
            for i, b in enumerate(g):
                if b == "1":
                    img.put(x + i % 3, y + i // 3, col)
        x += 4


def preview(icons, path):
    cols = 8
    cell_w, cell_h = 76, 84
    rows = (len(icons) + cols - 1) // cols
    sheet = Img(cols * cell_w, rows * cell_h, hexc("#0E0B0A"))
    for i, (id, img) in enumerate(icons.items()):
        x, y = (i % cols) * cell_w, (i // cols) * cell_h
        for j in range(68):
            for k in range(68):
                edge = j in (0, 67) or k in (0, 67)
                sheet.put(x + 4 + j, y + 4 + k, hexc("#7A5A22") if edge else hexc("#3A2618"))
        sheet.over(img.scaled(4), x + 6, y + 6)
        text(sheet, x + 4, y + 75, id[:17], hexc("#EDE3CC"))
    sheet.save(path)


# Class-favoured gear (items.md): each has its own drawn silhouette; `a` is the tier/accent colour.
def M(c, rows, tones=("A", "B", "C"), ox=0, oy=0):
    """Paint a '#' mask with a 1 px bevel: top/left edge light, bottom/right edge shade, rest mid."""
    hi, mid, shd = tones
    on = {(x, y) for y, r in enumerate(rows) for x, ch in enumerate(r) if ch == "#"}
    for x, y in on:
        if (x, y - 1) not in on or (x - 1, y) not in on:
            t = hi
        elif (x, y + 1) not in on or (x + 1, y) not in on:
            t = shd
        else:
            t = mid
        c.px(ox + x, oy + y, t)


def P(c, pts, ch):
    for x, y in pts:
        c.px(x, y, ch)


TUNIC = [
    "..####..####..", ".#####..#####.", "##############", "##.########.##", "##.########.##",
    "##.########.##", "##.########.##", "...########...", "...########...", "...########...",
    "...########...", "...########...",
]


@icon("parang_perang", a="#8A2A2A")
def _(c):
    c.blit([
        "..........111.",
        "........11222.",
        ".......122222.",
        "......1222223.",
        ".....12222233.",
        "....122222333.",
        "...1222223333.",
        "..12222233333.",
        "..222223333...",
        "...33333......",
    ], 0, 0)
    c.bar((2, 9), (0, 11), "AB"); c.line((3, 10), (1, 12), "C")
    c.line((3, 8), (5, 10), "8"); c.px(3, 8, "7")
    c.px(0, 12, "8"); c.px(0, 13, "9"); c.px(1, 13, "9")


@icon("tombak_panji", a="#B8302A")
def _(c):
    c.bar((0, 13), (10, 3), "45")
    c.blit(["...1.", "..12.", ".122.", ".223.", "..3.."], 9, 0)
    c.blit(["AAA", "ABB", ".BC", "..C"], 10, 5)
    c.px(10, 5, "A")
    c.px(9, 4, "8"); c.px(10, 4, "9")


@icon("zirah_sisik", a="#7A6A3A")
def _(c):
    rows = ["..####..####..", ".#####..#####.", "##############", "##.########.##", "##.########.##",
            "...########...", "...########...", "...########...", "...########...", "...########...", "...########..."]
    pts = [(x, y) for y, r in enumerate(rows) for x, ch in enumerate(r) if ch == "#"]
    for x, y in pts:
        yy = y // 2; xx = (x + yy) % 3
        c.px(x, y + 1, "1" if (y % 2 == 0 and xx == 0) else ("3" if y % 2 == 1 else "2"))
    P(c, [(x, 2) for x in (2, 3, 4, 5, 8, 9, 10, 11)], "B")   # collar trim
    c.line((3, 12), (10, 12), "C"); c.line((3, 11), (10, 11), "B")
    P(c, [(0, 5), (1, 5), (12, 5), (13, 5)], "B")


@icon("gelang_baja", a="#5A6A7A")
def _(c):
    M(c, [
        "..##########..", ".############.", "##############", "##############", "##############",
        "##############", ".############.", "..##########..",
    ], ("1", "2", "3"), 0, 3)
    c.line((2, 6), (11, 6), "A"); c.line((2, 7), (11, 7), "B")
    P(c, [(3, 5), (10, 5)], "7"); P(c, [(3, 8), (10, 8)], "8")
    c.px(6, 4, "1"); c.px(7, 4, "1")


@icon("busur_petung", a="#7A9A3A")
def _(c):
    for y, x in enumerate([7, 6, 5, 4, 3, 3, 2, 2, 2, 2, 3, 3, 4, 5, 6][:14]):
        c.px(x, y, "B"); c.px(x + 1, y, "C")
        c.px(x - 1, y, "A") if x > 0 else None
    P(c, [(2, 0), (3, 0)], "A")
    for ny in (3, 7, 11):
        P(c, [(2, ny)], "k")
    c.line((9, 0), (9, 13), "2")
    c.line((5, 6), (13, 6), "6"); c.px(13, 6, "1"); c.px(12, 5, "1"); c.px(12, 7, "1")
    c.px(8, 0, "A"); c.px(8, 13, "A")


@icon("gendewa_tanduk", a="#E2D4B0")
def _(c):
    pts = [(9, 0), (8, 0), (7, 1), (6, 2), (5, 3), (4, 4), (4, 5), (3, 6), (3, 7), (4, 8), (4, 9), (5, 10), (6, 11), (7, 12), (8, 13), (9, 13)]
    for x, y in pts:
        c.px(x, y, "B"); c.px(x - 1, y, "A")
    for x, y in ((9, 0), (8, 0), (9, 13), (8, 13)):
        c.px(x, y, "C")
    P(c, [(12, 0), (11, 0), (12, 1)], "3"); P(c, [(12, 13), (11, 13), (12, 12)], "3")
    c.line((10, 0), (10, 13), "2")
    c.line((6, 6), (13, 6), "6"); c.px(13, 6, "1"); c.px(12, 5, "1"); c.px(12, 7, "1")
    P(c, [(2, 5), (2, 6), (2, 7), (3, 5), (3, 8)], "9")


@icon("kampret_pemburu", a="#4A6A3A")
def _(c):
    M(c, ["..####..####..", ".#####..#####.", "######..######", "######..######", "####.#..#.####",
          "####.#..#.####", ".##..#..#..##.", "....##..##....", "....##..##....", "....##..##....", "....##..##...."], ("A", "B", "C"), 0, 1)
    P(c, [(6, y) for y in range(1, 10)] + [(7, y) for y in range(1, 10)], "k")
    P(c, [(6, 3), (7, 3), (6, 6), (7, 6)], "8")
    P(c, [(0, 7), (1, 7), (12, 7), (13, 7)], "C")


@icon("kantong_panah", a="#C8402A")
def _(c):
    c.blit([
        "........AA...",
        ".......ABA...",
        "........B.A..",
        ".......2.2...",
    ], 0, 0)
    c.px(9, 3, "A"); c.px(11, 2, "A")
    c.bar((2, 13), (8, 5), "456"); c.bar((3, 13), (9, 5), "456")
    c.line((1, 12), (7, 5), "6"); c.line((10, 8), (9, 4), "6")
    P(c, [(8, 4), (9, 4), (10, 4)], "9")
    c.line((4, 6), (11, 11), "8"); c.px(4, 6, "7"); c.px(11, 11, "9")


@icon("golok_pendek", a="#6A4A3A")
def _(c):
    c.blit([
        "..........1111",
        "........111222",
        ".......1122223",
        "......11222233",
        ".....112222333",
        "....1122223333",
        "....222223333.",
        "....22333333..",
    ], 0, 0)
    c.line((3, 8), (5, 6), "8"); c.px(3, 8, "7")
    c.bar((2, 9), (0, 11), "AB"); c.line((3, 10), (1, 12), "C")
    c.px(0, 12, "8"); c.px(0, 13, "9")
    P(c, [(9, 2), (10, 3), (11, 4), (12, 5)], "3")


@icon("kujang_kembar", a="#C8A030")
def _(c):
    left = [
        "...1.....",
        "..122....",
        ".1223....",
        ".1223....",
        "122.3....",
        "12223....",
        "1.223....",
        "..223....",
        "..223....",
        "...3.....",
    ]
    for j, r in enumerate(left):
        for i, ch in enumerate(r):
            if ch not in ". ":
                c.px(i, j, ch); c.px(13 - i, j, ch)
    for x in (4, 5, 8, 9):
        c.px(x, 10, "X")
    c.rect(4, 10, 2, 1, "Y"); c.rect(8, 10, 2, 1, "Y")
    c.rect(5, 11, 4, 2, "5"); c.rect(5, 11, 4, 1, "4")
    c.rect(5, 13, 4, 1, "X"); c.px(6, 13, "Y")


@icon("pangsi_hitam", a="#34344A")
def _(c):
    M(c, ["..####..####..", ".############.", "##############", "##.########.##", "##.########.##",
          "##.########.##", "...########...", "..##########..", "..####..####..", "..####..####..",
          "..####..####..", "..####..####..", ".#####..#####."], ("A", "B", "C"), 0, 0)
    P(c, [(6, 1), (7, 1), (6, 2), (7, 2), (6, 3), (7, 3)], "k")
    c.line((3, 7), (10, 7), "C")
    P(c, [(6, 5), (7, 5)], "A")


@icon("sabuk_merah", a="#B8302A")
def _(c):
    M(c, ["##############", "##############", "##############", "##############", "##############", "##############"], ("A", "B", "C"), 0, 2)
    for x in range(1, 14, 3):
        c.line((x + 2, 2), (x, 7), "C")
    c.rect(5, 3, 4, 4, "B"); c.rect(5, 3, 4, 1, "A"); c.rect(5, 6, 4, 1, "C")
    c.px(5, 4, "A")
    M(c, ["###", "###", "###", ".##", ".#."], ("A", "B", "C"), 4, 8)
    M(c, ["###", "###", "###", "##.", ".#."], ("A", "B", "C"), 8, 8)
    P(c, [(4, 13), (9, 13)], "7")


@icon("tongkat_genta", a="#C8A030")
def _(c):
    c.bar((6, 7), (6, 13), "45")
    c.blit([
        "..9999.",
        "..7888.",
        ".788889",
        ".788889",
        "7888889",
        "7888889",
        "9999999",
    ], 3, 0)
    c.line((3, 6), (10, 6), "9")
    c.px(6, 5, "k"); c.px(7, 5, "k")
    c.px(6, 7, "7"); c.px(7, 7, "8")
    c.rect(5, 12, 4, 1, "6"); c.px(5, 12, "5")


@icon("tongkat_cendana", a="#B87A4A")
def _(c):
    c.bar((3, 13), (9, 4), "AB"); c.bar((4, 13), (10, 4), "B")
    c.blit([
        "..AAAA..",
        ".ABBBBC.",
        "AB....BC",
        "AB.....C",
        "AB......",
        "AB......",
    ], 6, 0)
    P(c, [(7, 11), (6, 12), (5, 13)], "C")
    c.line((4, 11), (6, 9), "C"); c.line((5, 8), (7, 6), "A")


@icon("jubah_wiku", a="#E8E0C8")
def _(c):
    M(c, ["..####..####..", ".######..#####", "..###########.", "###.########.#", "###.########.#",
          "##..########.#", "....########..", "....########..", "...##########.", "...##########.",
          "..############", "..############"], ("A", "B", "C"), 0, 1)
    c.rect(0, 0, 0, 0, "A")
    P(c, [(6, 1), (7, 1), (6, 2), (7, 2)], "C")
    c.line((4, 7), (11, 7), "Y"); c.line((4, 8), (11, 8), "Z")
    P(c, [(6, 9), (6, 10), (6, 11), (6, 12)], "C")


@icon("genitri", a="#6A3A2A")
def _(c):
    for k in range(10):
        a = 2 * math.pi * k / 10 - math.pi / 2
        x = round(6 + 4.6 * math.cos(a)); y = round(4.6 + 4.2 * math.sin(a))
        c.px(x, y, "B"); c.px(x + 1, y, "C"); c.px(x, y + 1, "C"); c.px(x + 1, y + 1, "C"); c.px(x, y, "A")
    P(c, [(6, 9), (7, 9)], "7"); P(c, [(6, 10), (7, 10)], "8")
    c.px(6, 11, "A"); c.px(7, 11, "B"); c.px(6, 12, "B"); c.px(7, 12, "C"); c.px(6, 13, "C"); c.px(7, 13, "C")
    P(c, [(5, 11), (8, 11)], "k")


@icon("tombak_galah", a="#7A9A3A")
def _(c):
    c.bar((0, 13), (11, 2), "AB")
    c.bar((1, 13), (12, 2), "C")
    for t in (4, 8):
        c.px(t - 1 + 0, 13 - t - 0, "X"); c.px(t, 13 - t, "Y")
    c.blit(["..11", ".122", "1223", "123.", "13.."], 10, 0)
    c.px(11, 0, "1")
    P(c, [(9, 3), (10, 3)], "8"); P(c, [(10, 4)], "9")
    c.line((2, 11), (4, 9), "9")


@icon("tombak_bendera", a="#C8A030", x="#B8302A")
def _(c):
    c.bar((0, 13), (9, 4), "45")
    c.blit(["..1.", ".12.", ".223", "..3."], 8, 0)
    c.blit([
        ".AAAAAA",
        "ABBBYBB",
        "ABBYYBC",
        "ABBBYBC",
        ".CCCCCC",
    ], 6, 3)
    c.px(7, 8, "5")


@icon("baju_keprajuritan", a="#8A2A3A")
def _(c):
    M(c, TUNIC, ("A", "B", "C"), 0, 1)
    P(c, [(x, 2) for x in (1, 2, 3, 10, 11, 12)], "X"); P(c, [(0, 3), (13, 3)], "Y")
    P(c, [(6, 2), (7, 2)], "k")
    for y in (4, 6, 8, 10):
        c.px(6, y, "Y"); c.px(7, y, "Z")
    c.line((3, 12), (10, 12), "X")
    P(c, [(6, 3), (7, 3)], "C")


@icon("tameng_rotan", a="#B8904A")
def _(c):
    R = 6.3
    for y in range(14):
        for x in range(14):
            d = math.hypot(x - 6.5, y - 6.5)
            if d <= R:
                v = (x - 6.5) + (y - 6.5)
                ring = int(d // 2) % 2
                if d > R - 1.4:
                    ch = "A" if v < -1 else "C"
                else:
                    ch = ("A" if ring == 0 else "B") if v < 3 else ("B" if ring == 0 else "C")
                c.px(x, y, ch)
    c.rect(5, 5, 4, 4, "8"); c.rect(5, 5, 2, 2, "7"); c.rect(7, 7, 2, 2, "9")
    P(c, [(6, 6)], "w")


@icon("bandring_kulit", a="#8A5A3A")
def _(c):
    c.line((1, 0), (5, 8), "5"); c.line((2, 0), (6, 8), "4")
    c.line((12, 0), (8, 8), "5"); c.line((11, 0), (7, 8), "6")
    c.blit([
        "..AAAAA.",
        ".ABBBBBC",
        "ABB22BBC",
        "ABB22BBC",
        ".ACCCCC.",
        "...CC...",
    ], 3, 7)
    P(c, [(0, 0), (1, 0), (13, 0), (12, 0)], "9")


@icon("bandring_ijuk", a="#4A4A4A")
def _(c):
    c.bar((2, 2), (5, 9), "AB"); c.bar((11, 2), (8, 9), "BC")
    c.blit(["A.BA", ".AB."], 1, 0); c.blit(["AB.B", ".BA."], 9, 0)
    c.blit([
        "..AAAAAA..",
        ".ABBBBBBC.",
        "ABB.22.BBC",
        "ABB.23.BBC",
        ".ACBBBBCC.",
        "..CCCCCC..",
    ], 2, 8)


@icon("sarung_gembala", a="#3A7A8A")
def _(c):
    M(c, ["####........", "######......", ".#######....", "..#######...", "...#######..", "....#######.", ".....#######", "......######"],
      ("A", "B", "C"), 0, 2)
    for k in range(-2, 14, 4):
        c.line((k, 2), (k + 8, 10), "X")
    P(c, [(0, 2), (1, 2), (0, 3)], "X")
    for i in range(4):
        P(c, [(0 + i, 11 - 0), ], "Y") if False else None
    P(c, [(2, 0), (3, 1)], "A")
    P(c, [(0, 1), (1, 1)], "Y"); P(c, [(12, 12), (13, 12), (13, 13)], "Y")
    P(c, [(0, 0), (1, 0)], "Y"); P(c, [(12, 11)], "Z")


@icon("suling_bambu", a="#C8B050")
def _(c):
    c.bar((0, 13), (11, 2), "ABC")
    c.line((11, 1), (13, 3), "A")
    for t in (2, 5, 8, 11):
        c.px(t + 1, 13 - t, "k")
    c.px(2, 11, "X"); c.px(1, 12, "Y"); c.px(10, 3, "X"); c.px(11, 2, "Y")
    c.px(12, 1, "k")


def _fan(c, cx, cy, r, a0, a1, tones, k):
    for y in range(14):
        for x in range(14):
            dx, dy = x - cx, cy - y
            d = math.hypot(dx, dy)
            if d <= r and d >= 1:
                a = math.degrees(math.atan2(dy, dx))
                if a0 <= a <= a1:
                    band = int((a - a0) / k)
                    rib = (a - a0) % k < 3.2 and d > 3
                    c.px(x, y, tones[2] if (rib or d > r - 1.2) else (tones[0] if band % 2 == 0 else tones[1]))


@icon("kipas_bambu", a="#8AAA4A")
def _(c):
    _fan(c, 3, 11, 12, 5, 85, ("A", "B", "C"), 16)
    c.bar((0, 13), (3, 10), "45")
    c.px(3, 11, "8"); c.px(4, 11, "9"); c.px(3, 12, "9")


@icon("kipas_kembar", a="#C8A030", x="#B8302A")
def _(c):
    _fan(c, 1, 12, 8, 8, 82, ("A", "B", "C"), 18)
    c.bar((0, 13), (1, 12), "45")
    c.bar((9, 13), (12, 3), "XY"); c.line((11, 13), (13, 4), "Z")
    c.px(12, 2, "Y"); c.px(13, 2, "Z"); c.px(12, 1, "X")
    c.px(9, 13, "8")


@icon("baju_penari", a="#B8306A")
def _(c):
    M(c, ["..###....###..", ".#####..#####.", "##.########.##", "##.########.##", "...########...", "....######....",
          "....######....", "...########...", "..##########..", ".############.", "##############"], ("A", "B", "C"), 0, 1)
    P(c, [(6, 1), (7, 1), (6, 2), (7, 2)], "k")
    c.line((3, 2), (10, 10), "Y"); c.line((4, 2), (11, 10), "Z")
    c.line((1, 11), (12, 11), "X")
    c.px(0, 2, "X"); c.px(13, 2, "X")


@icon("gelang_kaki", a="#C8A030")
def _(c):
    for k in range(9):
        a = math.pi * (0.12 + 0.76 * k / 8)
        x = round(5.5 + 5.5 * math.cos(a)); y = round(1 + 5 * math.sin(a))
        c.rect(x, y, 2, 2, "8"); c.px(x, y, "7"); c.px(x + 1, y + 1, "9")
    for bx in (1, 5, 9):
        c.rect(bx + 1, 8, 3, 3, "8"); c.px(bx + 1, 8, "7"); c.px(bx + 2, 8, "7")
        c.px(bx + 3, 10, "9"); c.px(bx + 2, 10, "9"); c.px(bx + 2, 9, "k")
        c.px(bx + 2, 11, "9")
    P(c, [(2, 6), (3, 7), (7, 6), (8, 7), (11, 6), (12, 7)], "9")


@icon("cempala", a="#5A3A2A")
def _(c):
    c.bar((1, 13), (7, 7), "AB"); c.line((2, 13), (8, 7), "C")
    c.blit([
        "...AAAAAA",
        "..ABBBBBC",
        "..ABBBBBC",
        "..ABBBBBC",
        "..ACCCCCC",
    ], 5, 1)
    c.px(2, 12, "X"); c.px(1, 13, "Y")
    c.px(8, 6, "7"); c.px(8, 7, "9")
    c.line((6, 2), (6, 5), "C")


@icon("kayon_gapuran", a="#7A4A2A")
def _(c):
    M(c, [".....##.....", "....####....", "...######...", "..########..", ".##########.", ".##########.", ".##########.",
          ".##########.", "..########..", "...######..."], ("X", "Y", "Z"), 1, 0)
    M(c, ["..##..", ".####.", "######", "######", "######", "######"], ("A", "B", "C"), 4, 3)
    P(c, [(6, 6), (7, 6), (6, 7), (7, 7), (6, 8), (7, 8)], "k")
    P(c, [(6, 4), (7, 4)], "7")
    c.bar((6, 10), (6, 13), "45")
    c.px(7, 10, "6")


@icon("beskap_dalang", a="#2A2A4A")
def _(c):
    M(c, ["..####..####..", ".#####..#####.", "##############", "###.######.###", "###.######.###", "###.######.###",
          ".##.######.##.", "...########...", "...########...", "...########...", "...########...", "...########..."], ("A", "B", "C"), 0, 1)
    P(c, [(6, 1), (7, 1), (6, 2), (7, 2)], "k")
    c.line((7, 3), (10, 9), "Y")
    for p in ((7, 4), (8, 6), (9, 8)):
        c.px(*p, "7")
    P(c, [(5, 2), (8, 2), (4, 1), (9, 1)], "Y")
    c.line((3, 12), (10, 12), "Y")


@icon("blencong", a="#F0B030")
def _(c):
    c.blit([
        "......A.....",
        ".....AB.....",
        ".....ABA....",
        "....ABBBC...",
        "....ABBBC...",
        ".....BBC....",
    ], 1, 0)
    c.px(6, 3, "w"); c.px(6, 4, "w") if False else None
    c.blit([
        "..........",
        ".77888888.",
        "7788888899",
        ".99888899.",
        "..999999..",
    ], 2, 6)
    c.px(2, 7, "8"); c.px(1, 7, "9"); c.px(12, 7, "9")
    c.rect(6, 11, 3, 2, "8"); c.px(6, 11, "7"); c.px(8, 12, "9")
    c.rect(4, 13, 7, 1, "9"); c.rect(4, 13, 3, 1, "8")


if __name__ == "__main__":
    icons = build()
    preview(icons, os.path.join(ROOT, "tools", "items_preview.png"))
    print(len(icons), "icons")
