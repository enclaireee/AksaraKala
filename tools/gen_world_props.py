#!/usr/bin/env python3
"""World prop sprites for the Phase 6b dressing layer (zones/deco.gd, architecture.md 9).

Writes assets/art/props/<name>_<region>.png for the six tile regions (sunda galuh mataram timur kidul kala)
plus tools/props_preview.png. Pure stdlib (no PIL): a tiny RGBA canvas and a PNG writer live in here.
Rules: 1 px outline, 3-4 tones per material, light from the top-left, palette per region family
(matched to the hexes in gen_world_tilesets.py). Tall props are 32x48 with the trunk base at the bottom
centre; deco.gd positions them by that base.
Run: python3 tools/gen_world_props.py
"""
import math
import os
import random
import struct
import zlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "art", "props")
PREVIEW = os.path.join(ROOT, "tools", "props_preview.png")
CLEAR = (0, 0, 0, 0)


# ---------------------------------------------------------------- canvas
class Img:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.p = [[CLEAR] * w for _ in range(h)]

    def get(self, x, y):
        return self.p[y][x] if 0 <= x < self.w and 0 <= y < self.h else CLEAR

    def put(self, x, y, c):
        x, y = int(x), int(y)
        if 0 <= x < self.w and 0 <= y < self.h:
            self.p[y][x] = c

    def blit(self, o, ox, oy):
        for y in range(o.h):
            for x in range(o.w):
                c = o.p[y][x]
                if c[3] == 0:
                    continue
                d = self.get(ox + x, oy + y)
                if c[3] == 255 or d[3] == 0:
                    self.put(ox + x, oy + y, c)
                else:
                    a = c[3] / 255.0
                    self.put(ox + x, oy + y, tuple(int(c[i] * a + d[i] * (1 - a)) for i in range(3)) + (255,))

    def scaled(self, n):
        o = Img(self.w * n, self.h * n)
        for y in range(o.h):
            for x in range(o.w):
                o.p[y][x] = self.p[y // n][x // n]
        return o

    def padded(self, n=1):
        o = Img(self.w + 2 * n, self.h + 2 * n)
        o.blit(self, n, n)
        return o

    def flipped(self):
        o = Img(self.w, self.h)
        for y in range(self.h):
            o.p[y] = list(reversed(self.p[y]))
        return o

    def save(self, path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        raw = b"".join(b"\x00" + b"".join(struct.pack("4B", *c) for c in row) for row in self.p)

        def chunk(t, d):
            c = struct.pack(">I", len(d)) + t + d
            return c + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)
        png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", self.w, self.h, 8, 6, 0, 0, 0)) \
            + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
        with open(path, "wb") as f:
            f.write(png)


def hexc(s, a=255):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), a)


def shade(c, f):
    r, g, b, a = c
    if f <= 1:
        return (int(r * f), int(g * f), int(b * f), a)
    t = f - 1
    return (int(r + (255 - r) * t), int(g + (255 - g) * t), int(b + (255 - b) * t), a)


def tones(base):
    """deep, shadow, mid, light (shadows lean cool, lights lean warm)."""
    r, g, b, a = base
    return [(int(r * 0.45), int(g * 0.45), int(b * 0.58), a),
            (int(r * 0.70), int(g * 0.69), int(b * 0.80), a),
            base,
            (min(255, int(r * 1.25 + 12)), min(255, int(g * 1.22 + 10)), min(255, int(b * 1.12)), a)]


def outline(img, k=0.34):
    """1 px outline, colour = darkest neighbouring fill * k. Pads the image by 1 px."""
    s = img.padded(1)
    o = Img(s.w, s.h)
    for y in range(s.h):
        for x in range(s.w):
            c = s.p[y][x]
            if c[3] > 0:
                o.p[y][x] = c
                continue
            best = None
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                n = s.get(x + dx, y + dy)
                if n[3] == 255 and (best is None or sum(n[:3]) < sum(best[:3])):
                    best = n
            if best:
                o.p[y][x] = (int(best[0] * k), int(best[1] * k), min(255, int(best[2] * k * 1.15)), 255)
    return o


BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]
LIGHT = (-0.5, -0.7, 0.55)
_n = math.sqrt(sum(v * v for v in LIGHT))
LIGHT = tuple(v / _n for v in LIGHT)


def pick(tn, lum, x, y, dith=0.11):
    t = lum + (BAYER[y % 4][x % 4] / 16.0 - 0.5) * dith
    return tn[max(0, min(len(tn) - 1, int(t * len(tn))))]


def blob(img, cx, cy, rx, ry, tn, rng, bias=0.0, tex=0.14, rag=1.0):
    """Sphere-shaded ellipse with a ragged rim. Light from the top-left."""
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            nx, ny = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
            d = nx * nx + ny * ny
            if d > 1.0:
                continue
            if d > 0.78 and rng.random() < (d - 0.78) * 1.5 * rag:
                continue
            nz = math.sqrt(1.0 - d)
            lum = 0.5 + 0.5 * (nx * LIGHT[0] + ny * LIGHT[1] + nz * LIGHT[2]) + bias + (rng.random() - 0.5) * tex
            img.put(x, y, pick(tn, lum, x, y))


def line(img, x0, y0, x1, y1, c, w=1):
    n = int(max(abs(x1 - x0), abs(y1 - y0))) + 1
    for i in range(n + 1):
        t = i / max(1, n)
        x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
        for dx in range(w):
            img.put(round(x) + dx, round(y), c)


def trunk(img, cx, y0, y1, w0, w1, tn, rng):
    """Bark column from y0 (top, width w0) to y1 (bottom, width w1), light on the left."""
    for y in range(int(y0), int(y1) + 1):
        t = (y - y0) / max(1, y1 - y0)
        w = w0 + (w1 - w0) * t
        if y >= y1 - 2:
            w += 1.5 * (3 - (y1 - y))   # root flare
        half = w / 2.0
        for x in range(int(cx - half - 1), int(cx + half + 2)):
            u = (x + 0.5 - cx) / max(0.5, half)
            if abs(u) > 1.0:
                continue
            lum = 0.5 - 0.5 * u * 0.9 + (rng.random() - 0.5) * 0.22
            img.put(x, y, pick(tn, lum, x, y, 0.06))
    for _ in range(int((y1 - y0) / 4)):   # bark flecks
        img.put(cx + rng.randint(-int(w1 / 3), int(w1 / 3)), rng.randint(int(y0), int(y1) - 2), tn[0])


def ground_shadow(img, cx, y, rx, ry=2, a=95):
    for yy in range(y - ry, y + ry + 1):
        for xx in range(int(cx - rx), int(cx + rx) + 1):
            if ((xx - cx) / rx) ** 2 + ((yy - y) / ry) ** 2 <= 1.0 and img.get(xx, yy)[3] == 0:
                img.put(xx, yy, (10, 8, 20, a))


def finish(img, w, h, shadow_rx=0, k=0.34):
    """Outline, then centre on a w x h canvas with the base on the bottom row."""
    o = outline(img, k)
    out = Img(w, h)
    out.blit(o, (w - o.w) // 2, h - o.h)
    if shadow_rx:
        ground_shadow(out, w // 2, h - 2, shadow_rx)
    return out


# ---------------------------------------------------------------- palettes (per tile region family)
# leaf/leaf2: canopy and shrubs; trunk; rock; accent (glow, lantern flame); flowers: three petal colours; wood; stone.
REG = {
    "sunda":   dict(leaf="3F8F4A", leaf2="2F7A58", trunk="6B4A30", rock="6E757A", accent="FFE066", ground="4A7A44",
                    flowers=["F4F0E0", "FFD23F", "E8607A"], wood="8C603A", stone="8A8F8A", bone="D9D2BC", water="2B6E96"),
    "galuh":   dict(leaf="5C9A52", leaf2="3F8068", trunk="7A5A3A", rock="9C9A8A", accent="FFD166", ground="548250",
                    flowers=["FFFFFF", "F2B84B", "D94B6A"], wood="9A6A40", stone="C2B69E", bone="E0D8C0", water="267878"),
    "mataram": dict(leaf="6E8A3E", leaf2="4E7358", trunk="5A3E2A", rock="736B62", accent="FFE08A", ground="647842",
                    flowers=["F4F1DE", "E9C46A", "C75B4A"], wood="805B3E", stone="9C9486", bone="D8D0B8", water="366370"),
    "timur":   dict(leaf="A08E3E", leaf2="7E8A3C", trunk="6E4A30", rock="8C7A66", accent="FF9F1C", ground="9E8044",
                    flowers=["FFE08A", "E85D2A", "F4F0D8"], wood="7A492E", stone="A8906E", bone="E8DEC4", water="455E4B"),
    "kidul":   dict(leaf="2F8F7A", leaf2="3C7A52", trunk="5C4A3A", rock="4A5863", accent="FFE08A", ground="424957",
                    flowers=["F4A0B8", "FFE08A", "9EE6FF"], wood="735842", stone="6C7C86", bone="E6E2D0", water="185770"),
    "kala":    dict(leaf="6A4A9A", leaf2="4A3A7E", trunk="3A2E4A", rock="4D3B6E", accent="C77DFF", ground="383245",
                    flowers=["C77DFF", "9EE6FF", "FFD166"], wood="4A3B69", stone="635282", bone="C8C0D8", water="4A1880"),
}
REGIONS = list(REG)
SPRITES = {}   # name -> Img (name already includes the region suffix)


def seed(name):
    return random.Random(zlib.crc32(name.encode()))


def reg(name, region, img):
    SPRITES["%s_%s" % (name, region)] = img


# ---------------------------------------------------------------- tall trees (32x48)
def tree_teak(P, rng):
    img = Img(30, 46)
    tn_l, tn_t = tones(hexc(P["leaf"])), tones(hexc(P["trunk"]))
    trunk(img, 15, 28, 44, 5, 6, tn_t, rng)
    line(img, 15, 31, 9, 25, tn_t[1], 2)
    line(img, 15, 31, 21, 24, tn_t[1], 2)
    blobs = [(15, 20, 12, 11, -0.12), (8, 24, 8, 7, -0.16), (22, 24, 8, 7, -0.20), (11, 13, 8, 7, 0.0),
             (20, 14, 8, 7, -0.05), (15, 8, 8, 7, 0.08), (6, 17, 5, 5, -0.05), (24, 18, 5, 5, -0.10)]
    for cx, cy, rx, ry, b in blobs:
        blob(img, cx, cy, rx, ry, tn_l, rng, bias=b)
    for _ in range(26):   # light and dark leaf flecks
        x, y = rng.randint(4, 26), rng.randint(3, 28)
        if img.get(x, y)[3]:
            img.put(x, y, tn_l[3] if x < 15 and y < 18 else tn_l[0])
    return finish(img, 32, 48, 11)


def tree_banyan(P, rng):
    img = Img(30, 46)
    tn_l, tn_t = tones(hexc(P["leaf2"])), tones(hexc(P["trunk"]))
    for x in (6, 10, 21, 25):   # aerial roots
        line(img, x, 22, x + rng.randint(-1, 1), 44, tn_t[1])
        img.put(x - 1, 40, tn_t[2])
    trunk(img, 15, 24, 44, 8, 9, tn_t, rng)
    for dx in (-3, 0, 3):
        line(img, 15 + dx, 30, 15 + dx, 43, tn_t[0])
    for cx, cy, rx, ry, b in [(15, 14, 14, 11, -0.08), (7, 19, 8, 6, -0.18), (23, 19, 8, 6, -0.22), (11, 9, 8, 7, 0.0),
                              (20, 9, 8, 6, -0.04), (15, 5, 7, 4, 0.1)]:
        blob(img, cx, cy, rx, ry, tn_l, rng, bias=b)
    for _ in range(22):
        x, y = rng.randint(3, 27), rng.randint(2, 24)
        if img.get(x, y)[3]:
            img.put(x, y, tn_l[3] if y < 14 else tn_l[0])
    return finish(img, 32, 48, 13)


def palm_frond(img, cx, cy, ang, ln, droop, tn):
    pts = []
    steps = int(ln * 1.5)
    for i in range(steps + 1):
        t = i / steps
        x = cx + math.cos(ang) * ln * t
        y = cy + math.sin(ang) * ln * t + droop * t * t * ln
        pts.append((x, y, t))
    for x, y, t in pts:
        c = tn[2] if t < 0.7 else tn[1]
        if math.sin(ang) < 0:   # upward fronds catch the light
            c = tn[3] if t < 0.5 else tn[2]
        img.put(round(x), round(y), c)
        img.put(round(x), round(y) + 1, tn[1] if t > 0.3 else tn[2])
    for i, (x, y, t) in enumerate(pts):   # leaflets
        if i % 2 == 0 and 0.15 < t < 0.95:
            img.put(round(x), round(y) + 2, tn[0] if i % 4 == 0 else tn[1])
            img.put(round(x), round(y) - 1, tn[2])


def tree_palm(P, rng):
    img = Img(30, 46)
    tn_l, tn_t = tones(hexc(P["leaf"])), tones(hexc(P["trunk"]))
    pts = []
    for y in range(44, 11, -1):
        t = (44 - y) / 32.0
        pts.append((15 - 1 + 4.5 * t * t - 2 * t, y))
    for i, (x, y) in enumerate(pts):
        w = 3 if y > 24 else 2
        for dx in range(w):
            c = tn_t[3] if dx == 0 else tn_t[1]
            if (i // 3) % 2 == 0:
                c = tn_t[2] if dx == 0 else tn_t[0]   # ring marks
            img.put(round(x) + dx, y, c)
    cx, cy = pts[-1][0] + 1, pts[-1][1]
    for a, ln, dr in [(-2.4, 11, 0.012), (-1.7, 9, 0.0), (-0.9, 11, 0.012), (3.0, 13, 0.02), (0.15, 13, 0.02),
                      (2.5, 11, 0.03), (0.65, 11, 0.03)]:
        palm_frond(img, cx, cy, a, ln, dr * 6, tn_l)
    for dx, dy in ((-1, 2), (1, 2), (0, 3)):
        img.put(round(cx) + dx, round(cy) + dy, tn_t[0])
    return finish(img, 32, 48, 7)


def tree_acacia(P, rng):
    img = Img(30, 46)
    tn_l, tn_t = tones(hexc(P["leaf"])), tones(hexc(P["trunk"]))
    trunk(img, 15, 24, 44, 4, 5, tn_t, rng)
    line(img, 15, 28, 6, 17, tn_t[1], 2)
    line(img, 15, 27, 24, 15, tn_t[1], 2)
    line(img, 15, 30, 15, 20, tn_t[1], 2)
    for cx, cy, rx, ry, b in [(15, 15, 14, 5, -0.05), (7, 19, 8, 4, -0.18), (23, 17, 8, 4, -0.1), (14, 9, 10, 4, 0.08),
                              (22, 11, 6, 3, 0.0), (8, 12, 6, 3, 0.04)]:
        blob(img, cx, cy, rx, ry, tn_l, rng, bias=b, rag=1.3)
    for _ in range(14):
        x, y = rng.randint(3, 27), rng.randint(5, 22)
        if img.get(x, y)[3]:
            img.put(x, y, tn_l[3] if y < 14 else tn_l[0])
    return finish(img, 32, 48, 11)


def tree_dead(P, rng):
    img = Img(30, 46)
    tn_t = tones(hexc(P["trunk"]))
    tn_t = [shade(c, 1.12) for c in tn_t]
    trunk(img, 15, 22, 44, 4, 6, tn_t, rng)

    def branch(x, y, ang, ln, w, depth):
        for i in range(int(ln)):
            xx, yy = x + math.cos(ang) * i, y + math.sin(ang) * i
            for d in range(w):
                img.put(round(xx) + d, round(yy), tn_t[3] if d == 0 and w > 1 else tn_t[1])
            img.put(round(xx) + w, round(yy), tn_t[0])
        if depth > 0:
            ex, ey = x + math.cos(ang) * ln, y + math.sin(ang) * ln
            branch(ex, ey, ang - 0.55 + rng.random() * 0.2, ln * 0.72, max(1, w - 1), depth - 1)
            branch(ex, ey, ang + 0.5 + rng.random() * 0.2, ln * 0.68, max(1, w - 1), depth - 1)
    branch(15, 24, -math.pi / 2 - 0.15, 9, 2, 3)
    branch(15, 30, -math.pi / 2 - 0.95, 8, 2, 2)
    branch(16, 28, -math.pi / 2 + 0.9, 8, 2, 2)
    return finish(img, 32, 48, 7)


def tree_mangrove(P, rng):
    img = Img(30, 46)
    tn_l, tn_t = tones(hexc(P["leaf2"])), tones(hexc(P["trunk"]))
    for sx in (-1, 1):   # stilt roots
        for k, (x1, h) in enumerate(((11, 14), (7, 10), (4, 7))):
            for i in range(24):
                t = i / 23.0
                x = 15 + sx * (x1 * t)
                y = 44 - (h + 6 - 3 * k) * math.sin(math.pi * (0.5 - 0.5 * t) + 0.0) * (1 - t * 0.2) * (1 - t) ** 0.35
                img.put(round(x), round(y), tn_t[2] if sx < 0 else tn_t[1])
                img.put(round(x) + 1, round(y), tn_t[0])
    trunk(img, 15, 22, 40, 4, 5, tn_t, rng)
    for cx, cy, rx, ry, b in [(15, 15, 10, 9, -0.1), (8, 19, 6, 5, -0.2), (22, 19, 6, 5, -0.24), (12, 9, 6, 6, 0.0),
                              (19, 10, 6, 5, -0.04)]:
        blob(img, cx, cy, rx, ry, tn_l, rng, bias=b)
    for _ in range(14):
        x, y = rng.randint(4, 26), rng.randint(4, 26)
        if img.get(x, y)[3]:
            img.put(x, y, tn_l[3] if y < 14 else tn_l[0])
    return finish(img, 32, 48, 12)


def tree_bamboo(P, rng):
    img = Img(30, 46)
    tn = tones(hexc(P["leaf"]))
    tn = [shade(c, 1.0) for c in tn]
    stalks = [(7, 36, 2), (11, 44, 2), (15, 34, 3), (19, 42, 2), (23, 30, 2), (13, 26, 2), (21, 22, 2)]
    for x, h, w in sorted(stalks, key=lambda s: s[1]):
        top = 44 - h
        for y in range(top, 45):
            for d in range(w):
                c = tn[3] if d == 0 else tn[1]
                if (y - top) % 7 == 0:
                    c = tn[0]
                img.put(x + d, y, c)
        for dy, side in ((0, 1), (5, -1), (10, 1)):   # leaf tufts
            lx, ly = x + (side * 2), top + dy
            for i in range(5):
                img.put(lx + side * i, ly + (i // 2) + (0 if dy else -1), tn[2] if i < 3 else tn[1])
                img.put(lx + side * i, ly + (i // 2) + 1, tn[3] if i < 2 else tn[0])
    return finish(img, 32, 48, 11)


def tree_crystal(P, rng):
    img = Img(30, 46)
    base = hexc(P["accent"])
    tn = tones((int(base[0] * 0.78), int(base[1] * 0.78), int(base[2] * 0.85), 255))
    for cx, h, w in [(15, 40, 6), (8, 28, 5), (22, 24, 5), (12, 17, 4), (19, 14, 4)]:
        top = 44 - h
        for y in range(top, 45):
            t = (y - top) / float(h)
            hw = w * (0.18 + t * 0.82) if t < 0.3 else w
            hw = min(w, hw + 0.0)
            for x in range(int(cx - hw), int(cx + hw) + 1):
                u = (x - cx) / max(1.0, hw)
                c = tn[3] if u < -0.35 else (tn[2] if u < 0.25 else tn[1])
                if y < top + 3:
                    c = tn[3]
                img.put(x, y, c)
        img.put(cx - 1, top + 5, (255, 255, 255, 255))
        img.put(cx - 1, top + 6, tn[3])
    out = finish(img, 32, 48, 10)
    for _ in range(5):   # faint glow specks
        out.put(rng.randint(4, 28), rng.randint(6, 40), (*base[:3], 150))
    return out


def tree_spire(P, rng):
    img = Img(30, 46)
    tn = tones(hexc(P["rock"]))
    for cx, h, w in [(15, 42, 9), (6, 24, 5), (24, 28, 6)]:
        top = 44 - h
        for y in range(top, 45):
            t = (y - top) / float(h)
            hw = 1 + (w - 1) * (t ** 0.8)
            hw += (rng.random() - 0.5) * 0.8
            for x in range(int(cx - hw), int(cx + hw) + 1):
                u = (x - cx) / max(1.0, hw)
                c = tn[3] if u < -0.45 else (tn[2] if u < 0.1 else (tn[1] if u < 0.65 else tn[0]))
                img.put(x, y, c)
        for k in range(3):   # facet cracks
            x = cx - w // 3 + rng.randint(0, w // 2)
            y0 = top + rng.randint(4, h - 10)
            line(img, x, y0, x + rng.randint(-1, 1), y0 + rng.randint(3, 6), tn[0])
    return finish(img, 32, 48, 11)


# ---------------------------------------------------------------- low props
def bush(P, rng):
    img = Img(16, 13)
    tn = tones(hexc(P["leaf"]))
    for cx, cy, rx, ry, b in [(8, 7, 6, 5, -0.12), (4, 8, 4, 3, -0.18), (12, 8, 4, 3, -0.2), (7, 4, 4, 3, 0.05)]:
        blob(img, cx, cy, rx, ry, tn, rng, bias=b)
    for x, y in ((6, 3), (9, 5), (4, 6)):
        img.put(x, y, tn[3])
    return finish(img, 16, 16, 6)


def rock(P, rng, w, h):
    img = Img(w, h)
    tn = tones(hexc(P["rock"]))
    cx = w / 2.0
    for y in range(h):
        t = y / float(h)
        hw = (w / 2.0) * (0.45 + 0.55 * min(1.0, t * 1.6)) * (1.0 if t < 0.92 else 0.85)
        for x in range(int(cx - hw), int(cx + hw) + 1):
            u = (x + 0.5 - cx) / max(1.0, hw)
            lum = 0.62 - 0.38 * u - 0.30 * t + (rng.random() - 0.5) * 0.10
            if t < 0.22:
                lum += 0.18
            img.put(x, y, pick(tn, lum, x, y, 0.06))
    for _ in range(max(1, w // 8)):   # cracks
        x, y = rng.randint(2, w - 3), rng.randint(h // 4, h - 3)
        line(img, x, y, x + rng.randint(-1, 1), y + rng.randint(2, 3), tn[0])
    # moss on top
    mc = tones(hexc(P["leaf"]))
    for x in range(2, w - 2):
        if rng.random() < 0.45:
            img.put(x, 0 if rng.random() < 0.5 else 1, mc[2])
    return finish(img, w + 2, h + 2, w // 2)


def tuft(P, rng, v):
    img = Img(8, 6)
    lt = tones(hexc(P["leaf"]))
    tn = [lt[0], lt[2], lt[3], shade(lt[3], 1.35)]
    for i, (x, h) in enumerate(([(1, 3), (3, 5), (5, 3)], [(2, 4), (4, 4), (6, 2)], [(1, 2), (3, 4), (4, 3), (6, 3)])[v]):
        for y in range(h):
            img.put(x, 5 - y, tn[1] if y < h - 1 else tn[2])
        img.put(x, 5 - h, tn[3])
        img.put(x + (1 if i % 2 else -1), 5 - h + 1, tn[0])
    return img


def flower(P, rng, v):
    img = Img(7, 9)
    tn = tones(hexc(P["leaf"]))
    petal = hexc(P["flowers"][v])
    for y in range(4, 9):
        img.put(3, y, tn[1])
    img.put(2, 6, tn[2])
    img.put(4, 7, tn[2])
    for dx, dy in ((0, 0), (-1, 0), (1, 0), (0, -1), (0, 1)):
        img.put(3 + dx, 3 + dy, petal if (dx, dy) != (0, 0) else shade(petal, 0.7))
    img.put(2, 2, shade(petal, 1.3))
    return img


def pebbles(P, rng, v):
    img = Img(9, 5)
    tn = tones(hexc(P["rock"]))
    spots = [(1, 2, 3, 2), (5, 1, 2, 2), (4, 3, 3, 2)] if v == 0 else [(2, 1, 2, 2), (5, 2, 3, 2), (1, 3, 2, 1)]
    for x, y, w, h in spots:
        for yy in range(h):
            for xx in range(w):
                img.put(x + xx, y + yy, tn[3] if (xx == 0 and yy == 0) else (tn[1] if yy == h - 1 else tn[2]))
    return img


# ---------------------------------------------------------------- landmarks
def lantern(P, rng):
    img = Img(12, 21)
    tn = tones(hexc(P["stone"]))
    ac = hexc(P["accent"])
    for y in range(8, 20):
        for x in range(4, 8):
            img.put(x, y, tn[3] if x == 4 else (tn[2] if x == 5 else tn[1]))
    for x in range(2, 10):
        img.put(x, 19, tn[1])
        img.put(x, 18, tn[2])
    for y in range(3, 8):   # lamp box
        for x in range(3, 9):
            img.put(x, y, tn[2] if x < 5 else tn[1])
    for y in range(4, 7):
        for x in range(4, 8):
            img.put(x, y, ac if (x, y) != (4, 4) else shade(ac, 1.5))
    for x in range(1, 11):   # roof
        img.put(x, 2, tn[3] if x < 5 else tn[2])
        img.put(x, 1 if 2 < x < 9 else 2, tn[2])
    img.put(5, 0, tn[3])
    img.put(6, 0, tn[2])
    out = finish(img, 14, 24, 4)
    for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)):   # warm glow ring
        out.put(7 + dx * 4, 9 + dy * 3, (*ac[:3], 70))
    return out


def candi_pillar(P, rng):
    img = Img(12, 22)
    tn = tones(hexc(P["stone"]))
    for y in range(4, 21):
        w = 6 if y < 18 else 8
        x0 = 6 - w // 2
        for x in range(x0, x0 + w):
            c = tn[3] if x == x0 else (tn[2] if x < x0 + w - 2 else tn[1])
            if y % 5 == 0:
                c = tn[0]
            img.put(x, y, c)
    for x in range(3, 9):   # broken, jagged top
        img.put(x, 3 + (x * 7) % 3, tn[2])
    return finish(img, 14, 24, 5)


def candi_block(P, rng):
    img = Img(18, 14)
    tn = tones(hexc(P["stone"]))
    for (x0, y0, w, h) in [(1, 7, 10, 6), (8, 8, 9, 5), (4, 2, 8, 6)]:
        for y in range(y0, y0 + h):
            for x in range(x0, x0 + w):
                c = tn[3] if y == y0 else (tn[2] if x < x0 + w - 2 else tn[1])
                if x == x0 + w - 1 or y == y0 + h - 1:
                    c = tn[0]
                img.put(x, y, c)
    mc = tones(hexc(P["leaf"]))
    for x in range(2, 15):
        if rng.random() < 0.4:
            img.put(x, 8, mc[2])
    return finish(img, 20, 16, 7)


def candi_arch(P, rng):
    img = Img(28, 26)
    tn = tones(hexc(P["stone"]))
    for x0 in (2, 20):   # two jambs, one broken shorter
        top = 3 if x0 == 2 else 9
        for y in range(top, 25):
            for x in range(x0, x0 + 6):
                c = tn[3] if x == x0 else (tn[2] if x < x0 + 4 else tn[1])
                if y % 6 == 0:
                    c = tn[0]
                img.put(x, y, c)
    for x in range(2, 14):   # lintel stub
        for y in range(2, 6):
            img.put(x, y, tn[3] if y == 2 else (tn[2] if y < 5 else tn[1]))
    for y in range(18, 25):   # rubble
        for x in range(10, 19):
            if rng.random() < 0.55:
                img.put(x, y, tn[rng.randint(0, 2)])
    return finish(img, 30, 28, 11)


def shrine(P, rng):
    img = Img(26, 28)
    tn = tones(hexc(P["stone"]))
    wd = tones(hexc(P["wood"]))
    rf = tones(hexc(P["trunk"]))
    for y in range(18, 26):   # plinth
        for x in range(3, 23):
            img.put(x, y, tn[3] if y == 18 else (tn[2] if x < 19 else tn[1]))
    for y in range(10, 18):   # body with dark niche
        for x in range(6, 20):
            img.put(x, y, wd[3] if x == 6 else (wd[2] if x < 17 else wd[1]))
    for y in range(12, 18):
        for x in range(10, 16):
            img.put(x, y, wd[0])
    ac = hexc(P["accent"])
    img.put(12, 15, ac)
    img.put(13, 15, shade(ac, 1.4))
    for i, (y, x0, x1) in enumerate([(9, 3, 23), (7, 5, 21), (5, 7, 19), (3, 9, 17)]):   # tiered roof
        for x in range(x0, x1):
            img.put(x, y, rf[3] if x < x0 + 3 else rf[2])
            img.put(x, y + 1, rf[1])
    img.put(13, 1, tn[3])
    img.put(13, 2, tn[2])
    return finish(img, 28, 30, 11)


def boat(P, rng):
    img = Img(38, 16)
    wd = tones(hexc(P["wood"]))
    for x in range(2, 34):   # hull
        t = (x - 2) / 31.0
        depth = int(3 + 3 * math.sin(math.pi * t))
        lift = int(3 * (abs(t - 0.5) * 2) ** 2)
        for y in range(5 - lift, 5 - lift + depth):
            c = wd[3] if y == 5 - lift else (wd[2] if y < 5 - lift + depth - 2 else wd[1])
            if (x + y) % 9 == 0:
                c = wd[0]
            img.put(x, y, c)
    for x in range(8, 28):   # outrigger float and struts
        img.put(x, 12, wd[1])
        img.put(x, 11, wd[2])
    for x in (12, 22):
        line(img, x, 6, x, 11, wd[0])
    for x in range(14, 22):   # thwart / bundled net
        img.put(x, 4, wd[0])
    return finish(img, 40, 18, 14)


def bones(P, rng, v):
    img = Img(18, 9)
    tn = tones(hexc(P["bone"]))
    if v == 0:   # ribs
        for x in range(2, 16, 3):
            for y in range(1, 6):
                img.put(x, y, tn[3] if y < 3 else tn[2])
                img.put(x + 1, y + 1, tn[1])
        for x in range(1, 17):
            img.put(x, 6, tn[2])
            img.put(x, 7, tn[1])
    else:   # skull and a long bone
        for y in range(1, 6):
            for x in range(3, 10):
                img.put(x, y, tn[3] if y < 3 else tn[2])
        img.put(4, 3, tn[0]); img.put(7, 3, tn[0]); img.put(5, 5, tn[0]); img.put(6, 5, tn[0])
        line(img, 8, 7, 16, 6, tn[3], 2)
        img.put(16, 5, tn[2]); img.put(16, 7, tn[2])
    return finish(img, 20, 11, 7)


def coral(P, rng, v):
    img = Img(18, 18)
    ac = hexc(["D95988", "56CFE1"][v])
    tn = tones(ac)
    for x0, h in ((5, 11), (9, 14), (13, 9)):
        for y in range(17 - h, 18):
            img.put(x0, y, tn[2]); img.put(x0 + 1, y, tn[1])
        line(img, x0, 17 - h + 3, x0 - 3, 17 - h, tn[3], 1)
        line(img, x0 + 1, 17 - h + 5, x0 + 4, 17 - h + 2, tn[2], 1)
        img.put(x0 - 3, 17 - h - 1, tn[3]); img.put(x0 + 4, 17 - h + 1, tn[3])
    return finish(img, 20, 20, 7)


def crystal_s(P, rng):
    img = Img(14, 20)
    base = hexc(P["accent"])
    tn = tones((int(base[0] * 0.78), int(base[1] * 0.78), int(base[2] * 0.85), 255))
    for cx, h, w in [(7, 17, 3), (3, 10, 2), (11, 8, 2)]:
        for y in range(19 - h, 20):
            t = (y - (19 - h)) / float(h)
            hw = max(0.5, w * min(1.0, 0.2 + t * 1.3))
            for x in range(int(cx - hw), int(cx + hw) + 1):
                u = (x - cx) / max(1.0, hw)
                img.put(x, y, tn[3] if u < -0.3 else (tn[2] if u < 0.3 else tn[1]))
        img.put(cx - 1, 19 - h + 3, (255, 255, 255, 255))
    return finish(img, 16, 22, 5)


def table(P, rng):
    img = Img(26, 15)
    wd = tones(hexc(P["wood"]))
    for y in range(3, 7):
        for x in range(1, 25):
            img.put(x, y, wd[3] if y == 3 else (wd[2] if y < 6 else wd[1]))
    for x in (2, 22):
        for y in range(7, 14):
            img.put(x, y, wd[2]); img.put(x + 1, y, wd[0])
    for x in range(4, 21):
        if rng.random() < 0.3:
            img.put(x, 4, wd[2])
    return finish(img, 28, 17, 11)


def shelf(P, rng):
    img = Img(20, 26)
    wd = tones(hexc(P["wood"]))
    for y in range(2, 25):
        for x in range(2, 18):
            img.put(x, y, wd[3] if x == 2 else (wd[2] if x < 16 else wd[1]))
    for y in (8, 15, 22):
        for x in range(2, 18):
            img.put(x, y, wd[0])
    for (y0, cols) in ((3, ("F2B84B", "C75B4A", "9EE6FF")), (10, ("8AB8B8", "D4A85C")), (17, ("E8607A", "F4F0E0", "6B9E5A"))):
        x = 3
        for c in cols:
            ct = tones(hexc(c))
            for yy in range(y0, y0 + 5):
                for xx in range(x, x + 3):
                    img.put(xx, yy, ct[3] if xx == x else (ct[2] if xx < x + 2 else ct[1]))
            x += 4
    return finish(img, 22, 28, 8)


def jar(P, rng):
    img = Img(10, 13)
    wd = tones(hexc(P["wood"]))
    tn = tones((int(wd[2][0] * 1.1), int(wd[2][1] * 0.9), int(wd[2][2] * 0.8), 255))
    for y in range(1, 12):
        t = (y - 1) / 10.0
        hw = 2 + 2.5 * math.sin(math.pi * min(1.0, t * 1.05 + 0.1))
        for x in range(int(5 - hw), int(5 + hw) + 1):
            u = (x - 4.5) / max(1.0, hw)
            img.put(x, y, tn[3] if u < -0.4 else (tn[2] if u < 0.3 else tn[1]))
    for x in range(3, 8):
        img.put(x, 1, tn[0])
    return finish(img, 12, 15, 4)


def mat(P, rng):
    img = Img(22, 12)
    c = tones(hexc(P["flowers"][1] if rng.random() < 2 else "FFFFFF"))
    wd = tones(hexc(P["wood"]))
    for y in range(1, 10):
        for x in range(1, 21):
            img.put(x, y, wd[3] if (x + y) % 4 < 2 else wd[2])
    for x in range(1, 21):
        img.put(x, 1, wd[3]); img.put(x, 9, wd[1])
    for y in range(1, 10):
        img.put(1, y, wd[1]); img.put(20, y, wd[1])
    for x in range(5, 17):
        img.put(x, 5, c[2])
    return finish(img, 24, 14, 9)


# ---------------------------------------------------------------- fills (16x16 tiling ground under deep canopy / rock)
def fill_forest(P, rng, v):
    img = Img(16, 16)
    tn = tones(hexc(P["leaf2"]))
    tn = [shade(tn[0], 1.12), shade(tn[1], 0.78), shade(tn[1], 0.98), tn[2]]
    for y in range(16):
        for x in range(16):
            img.p[y][x] = tn[0]
    for _ in range(34):   # leaf clumps
        x, y = rng.randint(0, 15), rng.randint(0, 15)
        for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)):
            img.put((x + dx) % 16, (y + dy) % 16, tn[1])
    for _ in range(14):
        x, y = rng.randint(0, 15), rng.randint(0, 15)
        img.put(x, y, tn[2])
        img.put((x + 1) % 16, y, tn[2])
    for _ in range(3):
        img.put(rng.randint(0, 15), rng.randint(0, 15), tn[3])
    return img


def fill_rock(P, rng, v):
    img = Img(16, 16)
    tn = tones(hexc(P["rock"]))
    base = shade(tn[1], 0.82)
    for y in range(16):
        for x in range(16):
            img.p[y][x] = base
    for _ in range(6):   # strata and cracks
        x, y = rng.randint(0, 15), rng.randint(0, 15)
        for i in range(rng.randint(3, 7)):
            img.put((x + i) % 16, (y + i // 3) % 16, tn[0])
    for _ in range(14):
        x, y = rng.randint(0, 15), rng.randint(0, 15)
        img.put(x, y, shade(tn[2], 0.9))
        img.put((x + 1) % 16, y, shade(tn[2], 0.9))
    for _ in range(4):
        img.put(rng.randint(0, 15), rng.randint(0, 15), tn[3])
    return img


# ---------------------------------------------------------------- build
TALL = {"teak": tree_teak, "banyan": tree_banyan, "palm": tree_palm, "acacia": tree_acacia, "dead": tree_dead,
        "mangrove": tree_mangrove, "bamboo": tree_bamboo, "crystal": tree_crystal, "spire": tree_spire}


def build():
    for r in REGIONS:
        P = REG[r]
        for k, fn in TALL.items():
            reg("tree_" + k if k != "bamboo" else "bamboo", r, fn(P, seed("tree_%s_%s" % (k, r))))
        reg("bush", r, bush(P, seed("bush" + r)))
        reg("rock_s", r, rock(P, seed("rs" + r), 9, 7))
        reg("rock_m", r, rock(P, seed("rm" + r), 15, 11))
        reg("rock_l", r, rock(P, seed("rl" + r), 25, 18))
        for v in range(3):
            reg("tuft_%d" % v, r, tuft(P, seed("t%d%s" % (v, r)), v))
            reg("flower_%d" % v, r, flower(P, seed("f%d%s" % (v, r)), v))
            reg("fill_forest_%d" % v, r, fill_forest(P, seed("ff%d%s" % (v, r)), v))
            reg("fill_rock_%d" % v, r, fill_rock(P, seed("fr%d%s" % (v, r)), v))
        for v in range(2):
            reg("pebbles_%d" % v, r, pebbles(P, seed("p%d%s" % (v, r)), v))
            reg("bones_%d" % v, r, bones(P, seed("b%d%s" % (v, r)), v))
            reg("coral_%d" % v, r, coral(P, seed("c%d%s" % (v, r)), v))
        reg("lantern", r, lantern(P, seed("lan" + r)))
        reg("candi_pillar", r, candi_pillar(P, seed("cp" + r)))
        reg("candi_block", r, candi_block(P, seed("cb" + r)))
        reg("candi_arch", r, candi_arch(P, seed("ca" + r)))
        reg("shrine", r, shrine(P, seed("sh" + r)))
        reg("boat", r, boat(P, seed("bo" + r)))
        reg("crystal_s", r, crystal_s(P, seed("cs" + r)))
        reg("table", r, table(P, seed("ta" + r)))
        reg("shelf", r, shelf(P, seed("se" + r)))
        reg("jar", r, jar(P, seed("ja" + r)))
        reg("mat", r, mat(P, seed("ma" + r)))


def contact_sheet(scale=3):
    bg = (74, 98, 72, 255)
    groups = ["tree_teak", "tree_banyan", "tree_palm", "tree_acacia", "tree_dead", "tree_mangrove", "bamboo", "tree_crystal", "tree_spire"]
    small = ["bush", "rock_s", "rock_m", "rock_l", "tuft_0", "tuft_1", "tuft_2", "flower_0", "flower_1", "flower_2",
             "pebbles_0", "pebbles_1", "lantern", "candi_pillar", "candi_block", "candi_arch", "shrine", "boat",
             "bones_0", "bones_1", "coral_0", "coral_1", "crystal_s", "table", "shelf", "jar", "mat",
             "fill_forest_0", "fill_forest_1", "fill_rock_0", "fill_rock_1"]
    rows = []
    for r in REGIONS:
        rows.append((r, [SPRITES["%s_%s" % (n, r)] for n in groups]))
        rows.append((r, [SPRITES["%s_%s" % (n, r)] for n in small]))
    pad = 6
    widths, heights = [], []
    for _, ims in rows:
        widths.append(sum(i.w * scale + pad for i in ims) + pad)
        heights.append(max(i.h for i in ims) * scale + pad)
    W, H = max(widths), sum(heights) + pad
    sheet = Img(W, H)
    for y in range(H):
        sheet.p[y] = [bg] * W
    y = pad
    for (_, ims), h in zip(rows, heights):
        x = pad
        for im in ims:
            sheet.blit(im.scaled(scale), x, y + h - pad - im.h * scale)
            x += im.w * scale + pad
        y += h
    sheet.save(PREVIEW)


if __name__ == "__main__":
    build()
    for name, im in SPRITES.items():
        im.save(os.path.join(OUT, name + ".png"))
    contact_sheet()
    print("wrote %d props to %s and %s" % (len(SPRITES), OUT, PREVIEW))
