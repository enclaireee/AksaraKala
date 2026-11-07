#!/usr/bin/env python3
"""Ground art for zones/deco.gd (architecture.md 9, Phase 6c): assets/art/ground/ground_<region>.png.

Standalone: needs only the standard library (writes PNGs itself). Palettes come from gen_world_tilesets.REGIONS so the
ground matches the regional tilesets (1 px detail, light from the top left).

Sheet layout, 8 columns x 72 rows of 16x16 tiles = 3 sub-biome blocks of BLOCK (24) rows. deco.gd mirrors these numbers:
  row 0 grass x8 | row 1 path x8 | row 2 plaza stone x8 | row 3 sand x8 | row 4 wood floor x8      (opaque)
  rows 5-9 / 10-14 / 15-19: edge sets for path / water (shore) / sand bleeding onto a neighbouring cell. Per set,
      index = variant * 19 + piece (variant 0..1): piece 0..14 = side mask 1..15 (N=1 E=2 S=4 W=8), 15..18 = corner
      NE SE SW NW (used when the orthogonal mask is 0). Tile = column index % 8, row base + index / 8.   (alpha)
  row 20: shade (under a north wall), track H0 H1 V0 V1, puddle x3
  row 21: leaf x4, moss x3, crack0 | row 22: flower x6, crack1, crack2 | row 23: crack3        (alpha decals)
Run: python3 tools/gen_ground_tiles.py   (also writes tools/ground_preview.png)
"""
import os
import struct
import sys
import types
import zlib

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
try:
    import PIL  # noqa: F401
except ImportError:   # gen_world_tilesets only needs PIL for drawing; its palettes are plain data
    pil = types.ModuleType("PIL")
    pil.Image = types.ModuleType("PIL.Image")
    sys.modules["PIL"] = pil
    sys.modules["PIL.Image"] = pil.Image
import gen_world_tilesets as gwt  # noqa: E402

S = 16
COLS = 8
BLOCK = 24
OUT = os.path.join(os.path.dirname(HERE), "assets", "art", "ground")
SEED = 4242


# ---------------------------------------------------------------- tiny image + png
class Img:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.d = bytearray(w * h * 4)

    def get(self, x, y):
        i = (y * self.w + x) * 4
        return tuple(self.d[i:i + 4])

    def put(self, x, y, c):
        if not (0 <= x < self.w and 0 <= y < self.h):
            return
        r, g, b, a = c
        i = (y * self.w + x) * 4
        if a >= 255 or self.d[i + 3] == 0:
            self.d[i:i + 4] = bytes((r, g, b, a))
        elif a > 0:
            da = self.d[i + 3] / 255.0
            oa = a / 255.0 + da * (1 - a / 255.0)
            for k, v in enumerate((r, g, b)):
                self.d[i + k] = int((v * (a / 255.0) + self.d[i + k] * da * (1 - a / 255.0)) / oa)
            self.d[i + 3] = int(oa * 255)

    def blit(self, src, ox, oy):
        for y in range(src.h):
            for x in range(src.w):
                c = src.get(x, y)
                if c[3]:
                    self.put(ox + x, oy + y, c)

    def scaled(self, k):
        out = Img(self.w * k, self.h * k)
        for y in range(self.h):
            for x in range(self.w):
                c = self.get(x, y)
                for dy in range(k):
                    for dx in range(k):
                        i = ((y * k + dy) * out.w + x * k + dx) * 4
                        out.d[i:i + 4] = bytes(c)
        return out

    def save(self, path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        raw = b"".join(b"\x00" + bytes(self.d[y * self.w * 4:(y + 1) * self.w * 4]) for y in range(self.h))

        def chunk(t, data):
            c = struct.pack(">I", len(data)) + t + data
            return c + struct.pack(">I", zlib.crc32(t + data) & 0xFFFFFFFF)
        png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", self.w, self.h, 8, 6, 0, 0, 0)) \
            + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
        with open(path, "wb") as f:
            f.write(png)


def hh(*a):
    h = 2166136261
    for v in a:
        h = ((h ^ (v & 0xFFFFFFFF)) * 16777619) & 0xFFFFFFFF
        h ^= h >> 13
        h = (h * 0x5BD1E995) & 0xFFFFFFFF
        h ^= h >> 15
    return h


def r01(*a):
    return (hh(*a) & 0xFFFF) / 65535.0


def mix(a, b, t):
    return tuple(int(a[i] * (1 - t) + b[i] * t) for i in range(3)) + (255,)


def shade(c, f):
    return gwt.shade(c, f)


def al(c, a):
    return (c[0], c[1], c[2], a)


# ---------------------------------------------------------------- palettes
def palette(P):
    q = dict(P)
    q["sand"] = mix(shade(P["path"], 1.12), (232, 214, 160, 255), 0.25)
    q["sand_shd"] = shade(q["sand"], 0.82)
    q["sand_hi"] = shade(q["sand"], 1.15)
    stone = mix(shade(P["rock"], 1.15), P["path"], 0.2)
    q["stone"], q["stone_shd"], q["stone_hi"] = stone, shade(stone, 0.78), shade(stone, 1.2)
    q["moss"] = mix(P["ground"], (70, 130, 60, 255), 0.45)
    return q


# ---------------------------------------------------------------- opaque tiles
def tile(base):
    t = Img(S, S)
    for y in range(S):
        for x in range(S):
            t.put(x, y, base)
    return t


def speckle(t, P, pre, v, shd_p=0.07, hi_p=0.05):
    for y in range(S):
        for x in range(S):
            h = r01(x, y, v, SEED, len(pre))
            if h < shd_p:
                t.put(x, y, P[pre + "_shd"])
            elif h > 1 - hi_p and (x + y) % 2 == 0:
                t.put(x, y, P[pre + "_hi"])


def grass(P, v):
    base = P["ground"] if v < 4 else shade(P["ground"], 0.93)
    t = tile(base)
    Q = dict(P)
    Q["g_shd"], Q["g_hi"] = shade(base, 0.8), shade(base, 1.18)
    speckle(t, Q, "g", v)
    for i in range(3 + v % 3):   # tufts: dark root, light tip up-left
        x, y = 1 + int(r01(i, v, 1) * 13), 2 + int(r01(i, v, 2) * 12)
        t.put(x, y, Q["g_shd"])
        t.put(x - 1, y - 1, Q["g_hi"])
        if i % 2 == 0:
            t.put(x, y - 1, Q["g_hi"])
    k = v % 4
    if k == 1:   # clover
        x, y = 4 + int(r01(v, 5) * 8), 4 + int(r01(v, 6) * 8)
        for dx, dy in ((0, 0), (1, 0), (0, 1)):
            t.put(x + dx, y + dy, Q["g_hi"])
        t.put(x + 1, y + 1, Q["g_shd"])
    elif k == 2:   # pebble
        x, y = 3 + int(r01(v, 7) * 10), 3 + int(r01(v, 8) * 10)
        t.put(x, y, P["rock_hi"])
        t.put(x + 1, y, P["rock"])
        t.put(x + 1, y + 1, P["rock_shd"])
    elif k == 3:   # dry blades
        x, y = 3 + int(r01(v, 9) * 10), 4 + int(r01(v, 10) * 9)
        t.put(x, y, mix(base, P["path"], 0.55))
        t.put(x + 1, y - 1, mix(base, P["path_hi"], 0.55))
    return t


def path(P, v):
    base = mix(P["path"], P["path_shd"], 0.1)
    t = tile(base)
    speckle(t, P, "path", v + 20, 0.08, 0.06)
    for i in range(2 + v % 3):   # stones: light top-left, dark under
        x, y = 1 + int(r01(i, v, 31) * 13), 1 + int(r01(i, v, 32) * 13)
        t.put(x, y, P["path_hi"])
        t.put(x + 1, y, P["path"])
        t.put(x + 1, y + 1, P["path_shd"])
    if v % 3 == 1:   # a few grass blades poking in
        x, y = 2 + int(r01(v, 33) * 11), 2 + int(r01(v, 34) * 11)
        t.put(x, y, P["ground"])
        t.put(x, y - 1, P["ground_hi"])
    if v % 4 == 2:   # faint scuff
        y = 4 + int(r01(v, 35) * 8)
        x = 2 + int(r01(v, 36) * 6)
        for d in range(5):
            t.put(x + d, y, P["path_shd"] if d % 2 == 0 else base)
    return t


def plaza(P, v):
    t = tile(P["stone"])
    for y in range(S):
        for x in range(S):
            by = y % 8
            bx = (x + (4 if y >= 8 else 0)) % 8
            if by == 0 or bx == 0:
                t.put(x, y, P["stone_shd"])
            elif by == 1 and bx > 1:
                t.put(x, y, P["stone_hi"])
            elif r01(x, y, v, 51) < 0.05:
                t.put(x, y, P["stone_shd"])
            elif r01(x, y, v, 52) > 0.96:
                t.put(x, y, P["stone_hi"])
    if v % 2 == 1:   # chipped slab
        x, y = 2 + int(r01(v, 53) * 11), 2 + int(r01(v, 54) * 11)
        t.put(x, y, P["stone_shd"])
        t.put(x + 1, y + 1, P["stone_shd"])
    if v >= 4:   # worn slab
        for y in range(S):
            for x in range(S):
                if r01(x, y, v, 55) < 0.08 and t.get(x, y)[:3] == P["stone"][:3]:
                    t.put(x, y, mix(P["stone"], P["path"], 0.5))
    return t


def sand(P, v):
    t = tile(P["sand"])
    speckle(t, P, "sand", v + 40, 0.05, 0.05)
    for i in range(1 + v % 3):   # ripple arcs
        x, y = 1 + int(r01(i, v, 61) * 8), 3 + int(r01(i, v, 62) * 10)
        n = 4 + int(r01(i, v, 63) * 4)
        for d in range(n):
            yy = y + (1 if d in (0, n - 1) else 0)
            t.put(x + d, yy, P["sand_shd"])
            t.put(x + d, yy - 1, P["sand_hi"])
    if v % 4 == 3:   # shell
        x, y = 3 + int(r01(v, 64) * 10), 3 + int(r01(v, 65) * 10)
        t.put(x, y, (240, 232, 214, 255))
        t.put(x + 1, y + 1, P["sand_shd"])
    return t


def wood(P, v):
    t = tile(P["floor"])
    for y in range(S):
        for x in range(S):
            py = y % 4
            if py == 3:
                t.put(x, y, P["floor_shd"])
            elif py == 0:
                t.put(x, y, P["floor_hi"])
    for row in range(4):   # plank ends
        x = int(r01(row, v, 71) * S)
        for yy in range(row * 4, row * 4 + 3):
            t.put(x, yy, P["floor_shd"])
    for i in range(3):   # grain and nails
        x, y = int(r01(i, v, 72) * S), int(r01(i, v, 73) * S)
        if y % 4 in (1, 2):
            t.put(x, y, mix(P["floor"], P["floor_shd"], 0.5))
    if v % 3 == 0:
        x, y = 2 + int(r01(v, 74) * 12), (int(r01(v, 75) * 4)) * 4 + 1
        t.put(x, y, P["floor_hi"])
        t.put(x + 1, y, P["floor_shd"])
    return t


# ---------------------------------------------------------------- edge sets (alpha)
def profile(side, var, seed):
    """Bleed depth along one side, 2 at both ends so neighbouring cells line up."""
    p = [2] * S
    v = 2
    for t in range(1, S - 1):
        r = r01(t, side, var, seed)
        v += 1 if r < 0.28 else (-1 if r > 0.72 else 0)
        v = max(1, min(4, v))
        if t >= S - 3:
            v += (2 - v) // abs(2 - v) if v != 2 else 0
        p[t] = v
    p[S - 2] = max(1, min(3, p[S - 2]))
    p[S - 1] = 2
    return p


def edge_tile(P, kind, piece, var):
    t = Img(S, S)
    profs = [profile(s, var, 900 + kind * 7) for s in range(4)]
    mask = piece + 1 if piece < 15 else 0
    corner = piece - 15 if piece >= 15 else -1
    cpos = [(15, 0), (15, 15), (0, 15), (0, 0)]
    for y in range(S):
        for x in range(S):
            ds = []   # (side distance, depth margin)
            if mask & 1:
                ds.append((y, profs[0][x] - y))
            if mask & 2:
                ds.append((15 - x, profs[1][y] - (15 - x)))
            if mask & 4:
                ds.append((15 - y, profs[2][x] - (15 - y)))
            if mask & 8:
                ds.append((x, profs[3][y] - x))
            e = -1
            dnear = 99
            for d, m in ds:
                if m > 0:
                    e = max(e, m - 1) if e < 0 else min(e, m - 1)
                    dnear = min(dnear, d)
            if corner >= 0:
                cx, cy = cpos[corner]
                rr = ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5
                lim = 2.6 + 1.3 * r01(corner, var, 901 + kind)
                if rr < lim:
                    e = int(lim - rr)
                    dnear = int(rr)
            if e < 0:
                continue
            t.put(x, y, edge_px(P, kind, x, y, e, dnear, var))
    return t


def edge_px(P, kind, x, y, e, d, var):
    if kind == 0:   # path eating into grass
        if e == 0:
            return mix(P["path"], P["ground_shd"], 0.4) if r01(x, y, var, 911) < 0.7 else P["path"]
        h = r01(x, y, 912)
        return P["path_shd"] if h < 0.08 else (P["path_hi"] if h > 0.95 else mix(P["path"], P["path_shd"], 0.1))
    if kind == 2:   # sand drifting over grass, dithered edge
        if e == 0:
            return P["sand"] if (x + y + var) % 2 == 0 else mix(P["sand"], P["ground"], 0.5)
        h = r01(x, y, 913)
        return P["sand_shd"] if h < 0.06 else (P["sand_hi"] if h > 0.95 else P["sand"])
    # kind 1: wet bank beside water
    if d == 0:
        return mix(P["ground_shd"], P["water_deep"], 0.6)
    if r01(x, y, var, 914) < 0.06:
        return al(P["water_hi"], 255)
    return mix(P["ground_shd"], P["water_deep"], 0.35 if d == 1 else 0.18)


# ---------------------------------------------------------------- decals (alpha)
def shade_tile():
    t = Img(S, S)
    for y, a in enumerate((78, 52, 30, 12)):
        for x in range(S):
            t.put(x, y, (0, 0, 0, a))
    return t


def track(P, horizontal, var):
    t = Img(S, S)
    lines = (5, 10) if var == 0 else (4, 11)
    dark, light = al(P["path_shd"], 215), al(P["path_hi"], 150)
    for ln in lines:
        for i in range(S):
            gap = 0 < i < S - 1 and r01(i, ln, var, 921 + int(horizontal)) < 0.22
            if gap:
                continue
            j = ln + (1 if (i // 5 + var) % 3 == 0 and 2 < i < 13 else 0)
            x, y = (i, j) if horizontal else (j, i)
            t.put(x, y, dark)
            t.put(x + (0 if horizontal else 1), y + (1 if horizontal else 0), light)
    return t


def puddle(P, var):
    t = Img(S, S)
    cx, cy = 7.5 + (var - 1) * 1.2, 8 + (var % 2) * 1.0
    rx, ry = 5.2 - var * 0.4, 2.8 + var * 0.3
    wcol = mix(P["water"], (150, 180, 210, 255), 0.35)
    for y in range(S):
        for x in range(S):
            d = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
            d += (r01(x, y, var, 931) - 0.5) * 0.35
            if d < 0.78:
                t.put(x, y, al(wcol, 215))
            elif d < 1.05:
                t.put(x, y, al(P["path_shd"], 150))
    t.put(int(cx - 2), int(cy - 1), al(P["water_hi"], 255))
    t.put(int(cx - 1), int(cy - 1), al(P["water_hi"], 255))
    t.put(int(cx + 2), int(cy + 1), al(shade(wcol, 1.4), 255))
    return t


def leaf(P, var):
    t = Img(S, S)
    cols = [P["accent"], (190, 120, 48, 255), (150, 72, 34, 255), shade(P["ground"], 0.7)]
    for i in range(3 + var % 2):
        x, y = 1 + int(r01(i, var, 941) * 13), 1 + int(r01(i, var, 942) * 13)
        c = cols[(i + var) % len(cols)]
        t.put(x, y, c)
        t.put(x + 1, y + (i % 2), shade(c, 0.75))
    return t


def moss(P, var):
    t = Img(S, S)
    cx, cy = 5 + var * 3, 6 + (var % 2) * 4
    for y in range(S):
        for x in range(S):
            d = ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5 + (r01(x, y, var, 951) - 0.5) * 3
            if d < 3.6:
                t.put(x, y, al(shade(P["moss"], 1.15) if (x + y) % 3 == 0 else P["moss"], 200))
            elif d < 4.6 and r01(x, y, var, 952) < 0.4:
                t.put(x, y, al(shade(P["moss"], 0.8), 170))
    return t


def crack(P, var):
    t = Img(S, S)
    dark = al(shade(P["stone_shd"], 0.55), 230)
    x, y = 1 + int(r01(var, 961) * 6), 2 + int(r01(var, 962) * 6)
    dx, dy = (1, 1) if var % 2 == 0 else (1, -1)
    if dy < 0:
        y += 8
    for i in range(10):
        t.put(x, y, dark)
        t.put(x + 1, y + 1, al(P["stone_hi"], 120))
        r = r01(i, var, 963)
        if r < 0.45:
            x += dx
        elif r < 0.8:
            y += dy
        else:
            x += dx
            y += dy
        if r01(i, var, 964) < 0.18:   # a short branch
            t.put(x, y + dy, dark)
    return t


def flower(P, var):
    t = Img(S, S)
    cols = [P["accent"], (240, 240, 228, 255), (232, 120, 150, 255), (242, 210, 80, 255), (128, 150, 232, 255), (172, 112, 204, 255)]
    c = cols[var % 6]
    for i in range(2 + var % 2):
        x, y = 2 + int(r01(i, var, 971) * 11), 3 + int(r01(i, var, 972) * 10)
        t.put(x, y + 1, shade(P["ground"], 0.6))
        t.put(x - 1, y, c)
        t.put(x + 1, y, c)
        t.put(x, y - 1, shade(c, 1.2))
        t.put(x, y, (250, 230, 120, 255) if var % 3 != 2 else (250, 250, 240, 255))
    return t


# ---------------------------------------------------------------- sheet
def build_block(P):
    """24 rows x 8 columns of tiles for one sub-biome, as a list of (col, row, Img)."""
    P = palette(P)
    out = []
    for v in range(8):
        out += [(v, 0, grass(P, v)), (v, 1, path(P, v)), (v, 2, plaza(P, v)), (v, 3, sand(P, v)), (v, 4, wood(P, v))]
    for kind in range(3):
        base = 5 + kind * 5
        for var in range(2):
            for piece in range(19):
                idx = var * 19 + piece
                out.append((idx % COLS, base + idx // COLS, edge_tile(P, kind, piece, var)))
    out.append((0, 20, shade_tile()))
    for i, (h, var) in enumerate(((True, 0), (True, 1), (False, 0), (False, 1))):
        out.append((1 + i, 20, track(P, h, var)))
    for v in range(3):
        out.append((5 + v, 20, puddle(P, v)))
    for v in range(4):
        out.append((v, 21, leaf(P, v)))
    for v in range(3):
        out.append((4 + v, 21, moss(P, v)))
    cr = [crack(P, v) for v in range(4)]
    out += [(7, 21, cr[0]), (6, 22, cr[1]), (7, 22, cr[2]), (0, 23, cr[3])]
    for v in range(6):
        out.append((v, 22, flower(P, v)))
    return out


def sheet_for(region):
    sh = Img(COLS * S, 3 * BLOCK * S)
    for sb, P in enumerate(gwt.REGIONS[region]):
        for col, row, im in build_block(P):
            sh.blit(im, col * S, (sb * BLOCK + row) * S)
    return sh


# ---------------------------------------------------------------- preview
def preview_map(region, sb, W=22, H=11):
    """A little field: grass, a dirt lane, a pond, a sand patch and a plaza, put together the way deco.gd does."""
    P = palette(gwt.REGIONS[region][sb])
    blk = build_block(P if False else gwt.REGIONS[region][sb])
    tiles = {(c, r): im for c, r, im in blk}
    mat = {}
    for y in range(H):
        for x in range(W):
            m = "g"
            if 4 <= y <= 5 or (x in (10, 11) and y > 5):
                m = "p"
            if (x - 17) ** 2 / 9.0 + (y - 2.2) ** 2 / 3.0 < 1:
                m = "w"
            if x >= 14 and y >= 7 and not (x - 17) ** 2 + (y - 8) ** 2 > 6:
                m = "s"
            if 2 <= x <= 7 and 7 <= y <= 9:
                m = "z"
            mat[x, y] = m
    img = Img(W * S, H * S)
    rowof = {"g": 0, "p": 1, "z": 2, "s": 3}
    last = {}
    for y in range(H):
        for x in range(W):
            m = mat[x, y]
            if m == "w":
                for yy in range(S):
                    for xx in range(S):
                        img.put(x * S + xx, y * S + yy, P["water"] if (xx + yy * 2 + x * 5) % 11 else P["water_hi"])
                continue
            v = int(r01(x, y, SEED) * 8)
            while v == last.get((x - 1, y)) or v == last.get((x, y - 1)):
                v = (v + 1) % 8
            last[x, y] = v
            img.blit(tiles[v, rowof[m]], x * S, y * S)
    nb = [(0, -1), (1, 0), (0, 1), (-1, 0)]
    for y in range(H):
        for x in range(W):
            if mat[x, y] != "g":
                continue
            for kind, ch in ((1, "w"), (0, "p"), (2, "s")):
                mask = sum(1 << i for i, (dx, dy) in enumerate(nb) if mat.get((x + dx, y + dy)) == ch)
                piece = -1
                if mask:
                    piece = mask - 1
                else:
                    for ci, (dx, dy) in enumerate(((1, -1), (1, 1), (-1, 1), (-1, -1))):
                        if mat.get((x + dx, y + dy)) == ch:
                            piece = 15 + ci
                            break
                if piece >= 0:
                    var = hh(x, y, 3) % 2
                    idx = var * 19 + piece
                    img.blit(tiles[idx % COLS, 5 + kind * 5 + idx // COLS], x * S, y * S)
                    break
    for y in range(H):
        for x in range(W):
            m, h = mat[x, y], r01(x, y, 77)
            pick = None
            if m == "p":
                horiz = mat.get((x - 1, y)) == "p" and mat.get((x + 1, y)) == "p"
                vert = mat.get((x, y - 1)) == "p" and mat.get((x, y + 1)) == "p"
                if h < 0.55 and (horiz or vert):
                    pick = (1 + (0 if horiz else 2) + hh(x, y) % 2, 20)
                elif h > 0.88:
                    pick = (5 + hh(x, y) % 3, 20)
            elif m == "g":
                if h < 0.12:
                    pick = (hh(x, y) % 6, 22)
                elif h > 0.9:
                    pick = (hh(x, y) % 4, 21)
            elif m == "z":
                pick = [(4 + hh(x, y) % 3, 21), ((7, 21)), (6, 22), None][hh(x, y) % 4] if h < 0.6 else None
            if pick:
                img.blit(tiles[pick], x * S, y * S)
    return img


def main():
    shown = []
    for region in gwt.REGIONS:
        sheet_for(region).save(os.path.join(OUT, "ground_%s.png" % region))
        print("wrote ground_%s.png" % region)
        if region != "kelir":
            shown.append((region, preview_map(region, 0)))
    gap = 6
    cw, ch = shown[0][1].w, shown[0][1].h
    pv = Img(2 * cw + 3 * gap, 3 * ch + 4 * gap)
    for y in range(pv.h):
        for x in range(pv.w):
            pv.put(x, y, (24, 24, 28, 255))
    for i, (_, im) in enumerate(shown):
        pv.blit(im, gap + (i % 2) * (cw + gap), gap + (i // 2) * (ch + gap))
    pv.scaled(2).save(os.path.join(HERE, "ground_preview.png"))
    print("wrote tools/ground_preview.png")


if __name__ == "__main__":
    main()
