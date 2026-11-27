#!/usr/bin/env python3
"""Boss-arena floors + set-piece props (boss revamp v9, combat.md; assets.md big art / FX standard).

Usage (numpy is needed, the system python has it):
    /usr/bin/python3 tools/gen_arena_floors.py            # all 8 floors, 6 props, preview
    /usr/bin/python3 tools/gen_arena_floors.py ts_kawah   # only the named floors (props + preview still written)

Floors: assets/art/arena/<area_id>.png, sized (rect w * k * 16) x (rect h * k * 16); the top-left pixel is the top-left
of the rect's top-left doc cell (entities/world/arena_floor.gd). The CURRENT doc map is read on every run (same
Map/Legend format as .docs/gen_zones.py, parsed here because importing it would regenerate the zones): walkable cells
(legend/base tile '.', ',', '_') get floor, wall / rock / water / void cells stay alpha 0 so the tile walls show.
Re-lay a map, re-run, done: only ARENAS below is hand-set (rects in DOC cells, inclusive).
Props: assets/art/props/arena_*.png. Preview: tools/arena_floors_preview.png."""
import math
import os
import random
import re
import sys

import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import pixlib as P  # noqa: E402

DOCS = os.path.join(P.ROOT, ".docs", "zones")
FLOOR = {"path": ",", "grass": ".", "tea terrace": "t", "floor": "_"}   # legend Floor column -> base tile char (gen_zones.py)
WALK = ".,_"

# area id -> (region doc, arena rect (x0, y0, x1, y1) in DOC cells, inclusive)
ARENAS = {
    "ts_kawah": ("tatar_sunda.md", (8, 11, 29, 22)),
    "ts_leuwi": ("tatar_sunda.md", (12, 19, 34, 30)),
    "kg_keraton": ("keraton_galuh.md", (17, 1, 42, 12)),
    "kg_pamali": ("keraton_galuh.md", (20, 10, 39, 23)),
    "mt_candi": ("mataram.md", (14, 2, 47, 21)),
    "tt_ladang": ("tanah_timur.md", (29, 9, 56, 24)),
    "tt_candi": ("tanah_timur.md", (19, 5, 52, 28)),
    "gk_ruang_kala": ("gua_kala.md", (8, 2, 51, 31)),
}


# ---------------------------------------------------------------- doc parsing
def load_area(doc, aid, rect):
    txt = open(os.path.join(DOCS, doc)).read()
    m = re.search(r"^## Area \d+: %s(?!\w).*?(?=^## |\Z)" % aid, txt, re.S | re.M)
    if not m:
        raise SystemExit("area %s not found in %s" % (aid, doc))
    sec = m.group(0)
    rows = re.search(r"### Map\n+```\n(.*?)\n```", sec, re.S).group(1).split("\n")
    spots = {}
    for ln in re.search(r"### Legend\n(.*?)(?=\n###|\Z)", sec, re.S).group(1).split("\n"):
        if not ln.startswith("| `"):
            continue
        c = [x.strip() for x in ln.strip().strip("|").split(" | ")]
        spots[c[0].strip("`")] = (c[1], FLOOR[c[4]])
    sc = re.search(r"^Scale: (\d+)", sec, re.M)
    k = int(sc.group(1)) if sc else 2
    x0, y0, x1, y1 = rect
    if y1 >= len(rows) or x1 >= len(rows[0]):
        raise SystemExit("%s: rect %s is outside the %dx%d map" % (aid, rect, len(rows[0]), len(rows)))
    grid = []
    for y in range(y0, y1 + 1):
        grid.append("".join(spots[ch][1] if ch in spots else ch for ch in rows[y][x0:x1 + 1]))
    marks = []   # (char, legend text, centre px in the floor image)
    S = k * 16
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            ch = rows[y][x]
            if ch in spots:
                marks.append((ch, spots[ch][0], ((x - x0 + 0.5) * S, (y - y0 + 0.5) * S)))
    return dict(grid=grid, k=k, S=S, marks=marks)


# ---------------------------------------------------------------- colour helpers
def h(s):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16))


def sh(c, f):
    return P.shade(tuple(c) + (255,), f)[:3]


def mix(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3))


PLUM3 = P.PLUM[:3]


class Cv:
    """One arena floor under construction: an RGB array plus the walkable mask (alpha)."""

    def __init__(s, info, seed):
        g = info["grid"]
        s.S = info["S"]
        codes = np.array([[ord(ch) for ch in row] for row in g], np.uint8)
        s.kind = np.kron(codes, np.ones((s.S, s.S), np.uint8))
        s.mask = np.isin(s.kind, [ord(ch) for ch in WALK])
        s.H, s.W = s.mask.shape
        s.rgb = np.zeros((s.H, s.W, 3), np.uint8)
        s.rng = np.random.default_rng(seed)
        s.yy, s.xx = np.mgrid[0:s.H, 0:s.W]
        s.marks = info["marks"]
        boss = [p for _, w, p in s.marks if w.startswith(("boss", "miniboss"))]
        s.boss = boss[0] if boss else (s.W / 2, s.H / 2)
        s.centre = (s.W // 2, s.H // 2)
        s.dist = s._edge_dist(20)

    # -- geometry
    def _edge_dist(s, n):
        cur, d = s.mask.copy(), np.zeros(s.mask.shape, np.uint8)
        for _ in range(n):
            p = np.pad(cur, 1, mode="edge")   # an open rect edge (a gate mouth) is not a wall
            cur = cur & p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:] & p[:-2, :-2] & p[2:, 2:] & p[:-2, 2:] & p[2:, :-2]
            d += cur
        return d

    def shape(s, fn):
        im = Image.new("L", (s.W, s.H), 0)
        fn(ImageDraw.Draw(im))
        return np.asarray(im) > 0

    def disc(s, cx, cy, r):
        return (s.xx + 0.5 - cx) ** 2 + (s.yy + 0.5 - cy) ** 2 <= r * r

    def ring(s, cx, cy, r0, r1):
        d2 = (s.xx + 0.5 - cx) ** 2 + (s.yy + 0.5 - cy) ** 2
        return (d2 >= r0 * r0) & (d2 < r1 * r1)

    def rect(s, x0, y0, x1, y1):
        return (s.xx >= x0) & (s.xx < x1) & (s.yy >= y0) & (s.yy < y1)

    def poly_pts(s, cx, cy, r, n, rot=-90.0):
        return [(cx + r * math.cos(math.radians(rot + 360.0 * i / n)), cy + r * math.sin(math.radians(rot + 360.0 * i / n))) for i in range(n)]

    def pick(s, n, dmin=0, dmax=255, region=None):
        ok = s.mask & (s.dist >= dmin) & (s.dist <= dmax)
        if region is not None:
            ok = ok & region
        pts = np.argwhere(ok)
        if len(pts) == 0:
            return []
        idx = s.rng.integers(0, len(pts), n)
        return [(int(pts[i][1]), int(pts[i][0])) for i in idx]

    def wear(s, shp, n, rmin, rmax):
        """Knock worn chunks out of a painted shape (a ritual ring is never intact)."""
        pts = np.argwhere(shp)
        out = shp.copy()
        if len(pts) == 0:
            return out
        for i in s.rng.integers(0, len(pts), n):
            y, x = pts[i]
            out &= ~s.disc(x, y, float(s.rng.integers(rmin, rmax + 1)))
        return out

    # -- ground fills
    def put(s, m, c):
        s.rgb[m & s.mask] = c

    def blotch(s, base, g, f=(0.95, 1.0, 1.05), region=None):
        """Organic ground: two octaves of value noise cut to len(f) flat tones (no outlines, no speckle)."""
        v = np.zeros((s.H, s.W))
        for oct_g, wgt in ((g, 1.0), (g // 2, 0.5)):
            nx, ny = s.W // oct_g + 3, s.H // oct_g + 3
            grid = s.rng.random((ny, nx))
            fx, fy = s.xx / oct_g, s.yy / oct_g
            ix, iy = fx.astype(int), fy.astype(int)
            tx, ty = fx - ix, fy - iy
            tx, ty = tx * tx * (3 - 2 * tx), ty * ty * (3 - 2 * ty)
            a = grid[iy, ix] * (1 - tx) + grid[iy, ix + 1] * tx
            b = grid[iy + 1, ix] * (1 - tx) + grid[iy + 1, ix + 1] * tx
            v += (a * (1 - ty) + b * ty) * wgt
        v /= 1.5
        lv = np.digitize(v, np.quantile(v, np.linspace(0, 1, len(f) + 1)[1:-1]))
        s.paint_ids(np.zeros((s.H, s.W), np.int64), base, f=f, bevel=False, region=region, tone=lv)

    def slab_ids(s, ch, widths):
        ids = np.zeros((s.H, s.W), np.int64)
        xs = np.arange(s.W)
        for c in range(s.H // ch + 1):
            b, x = [], -16 * int(s.rng.integers(0, 3))
            while x < s.W:
                x += int(widths[int(s.rng.integers(len(widths)))])
                b.append(x)
            ids[c * ch:(c + 1) * ch] = np.searchsorted(b, xs, side="right")[None, :] + c * 1000
        return ids

    def paint_ids(s, ids, base, f=(0.93, 1.0, 1.07), bevel=True, joint=0.74, hi=1.14, region=None, tone=None):
        tones = np.array([sh(base, k) for k in f], np.uint8)
        ti = tone if tone is not None else ((ids * 2654435761) >> 13) % len(tones)
        img = tones[ti]
        if bevel:
            p = np.pad(ids, 1, mode="edge")
            up, lf, dn, rt = p[:-2, 1:-1] != ids, p[1:-1, :-2] != ids, p[2:, 1:-1] != ids, p[1:-1, 2:] != ids
            j = dn | rt
            img[j] = sh(base, joint)
            img[(up | lf) & ~j] = sh(base, hi)
        m = s.mask if region is None else (s.mask & region)
        s.rgb[m] = img[m]

    def slabs(s, base, ch=32, widths=(32, 48, 64), **kw):
        s.paint_ids(s.slab_ids(ch, widths), base, **kw)

    def polar_ids(s, cx, cy, rw, sw):
        dx, dy = s.xx + 0.5 - cx, s.yy + 0.5 - cy
        ring = (np.hypot(dx, dy) // rw).astype(np.int64)
        n = np.maximum(6, (2 * math.pi * (ring + 0.5) * rw / sw).astype(np.int64))
        sec = np.floor((np.arctan2(dy, dx) + math.pi) / (2 * math.pi) * n).astype(np.int64)
        return ring * 1000 + np.minimum(sec, n - 1)

    # -- bevelled inlays (top-left lit, bottom-right deep, optional plum-ish outline)
    def inlay(s, shp, mid, edge=None, hi=1.16, lo=0.74):
        m = shp & s.mask
        p = np.pad(shp, 1, mode="constant")
        up, lf, dn, rt = ~p[:-2, 1:-1], ~p[1:-1, :-2], ~p[2:, 1:-1], ~p[1:-1, 2:]
        s.rgb[m] = mid
        lo_m = m & (dn | rt)
        s.rgb[lo_m] = sh(mid, lo)
        s.rgb[m & (up | lf)] = sh(mid, hi)
        if edge is not None:
            q = np.pad(shp, 1, mode="constant")
            near = q[:-2, 1:-1] | q[2:, 1:-1] | q[1:-1, :-2] | q[1:-1, 2:]
            s.put(near & ~shp, edge)

    def blob(s, cx, cy, r, mid, wob=0.25, hi=1.12, lo=0.8, edge=None):
        ph = s.rng.uniform(0, 6.28, 3)
        x0, x1, y0, y1 = int(cx - r * 1.5) - 1, int(cx + r * 1.5) + 2, int(cy - r * 1.5) - 1, int(cy + r * 1.5) + 2
        x0, y0 = max(x0, 0), max(y0, 0)
        x1, y1 = min(x1, s.W), min(y1, s.H)
        if x1 <= x0 or y1 <= y0:
            return
        dx = s.xx[y0:y1, x0:x1] + 0.5 - cx
        dy = s.yy[y0:y1, x0:x1] + 0.5 - cy
        a = np.arctan2(dy, dx)
        rr = r * (1 + wob * (np.sin(2 * a + ph[0]) * 0.5 + np.sin(3 * a + ph[1]) * 0.3 + np.sin(5 * a + ph[2]) * 0.2))
        d = np.hypot(dx, dy)
        m = (d <= rr) & s.mask[y0:y1, x0:x1]
        t = (dx + dy) / max(r, 1)
        sub = s.rgb[y0:y1, x0:x1]
        if edge is not None:
            e = (d <= rr + 1.2) & (d > rr) & s.mask[y0:y1, x0:x1]
            sub[e] = edge
        sub[m] = mid
        sub[m & (t < -0.45)] = sh(mid, hi)
        sub[m & (t > 0.5)] = sh(mid, lo)

    def crack(s, x, y, n, c, depth=0, a=None):
        """A thin crack: a drifting heading rounded to pixels, with the odd side branch."""
        a = float(s.rng.uniform(0, 6.28)) if a is None else a
        fx, fy = float(x), float(y)
        for _ in range(n):
            x, y = int(round(fx)), int(round(fy))
            if not (0 <= x < s.W and 0 <= y < s.H) or not s.mask[y, x]:
                return
            s.rgb[y, x] = c
            a += float(s.rng.uniform(-0.22, 0.22))
            if depth < 2 and s.rng.random() < 0.03:
                s.crack(x, y, n // 3, c, depth + 1, a + float(s.rng.choice([-0.9, 0.9])))
            fx, fy = fx + math.cos(a), fy + math.sin(a)

    def pool(s, cx, cy, rx, ry, mid, edge=None):
        ph = s.rng.uniform(0, 6.28, 2)
        dx, dy = s.xx + 0.5 - cx, s.yy + 0.5 - cy
        a = np.arctan2(dy, dx)
        k = 1 + 0.16 * np.sin(2 * a + ph[0]) + 0.1 * np.sin(3 * a + ph[1])
        s.inlay(((dx / rx) ** 2 + (dy / ry) ** 2 <= k * k) & (np.abs(dx) < rx * 1.4) & (np.abs(dy) < ry * 1.4), mid, edge=edge, hi=1.35, lo=0.85)

    def cracks(s, n, lo, hi, c, dmin=5):
        for x, y in s.pick(n, dmin=dmin):
            s.crack(x, y, int(s.rng.integers(lo, hi)), c)

    def tuft(s, x, y, c):
        for dx, dy in ((0, 0), (0, -1), (0, -2), (-1, -2), (1, -3), (0, -3)):
            if 0 <= x + dx < s.W and 0 <= y + dy < s.H and s.mask[y + dy, x + dx]:
                s.rgb[y + dy, x + dx] = c

    def bands(s, f=(0.58, 0.76, 0.9), w=2):
        """Stepped 2 px darkening band where the floor meets a wall (tile walls stay visible beside it)."""
        for i, fi in enumerate(f):
            m = s.mask & (s.dist >= i * w) & (s.dist < (i + 1) * w)
            s.rgb[m] = (s.rgb[m] * np.array([fi, fi, min(1.0, fi * 1.05)])).astype(np.uint8)

    def socket(s, cx, cy, stone, hole, glow=None, soot=0.8):
        s.blob(cx, cy, 15, sh(stone, soot * 0.7), wob=0.3, hi=1.0, lo=1.0)
        s.blob(cx, cy, 8.5, stone, wob=0.08, edge=mix(PLUM3, stone, 0.5))
        s.blob(cx, cy, 4.5, hole, wob=0.05, hi=1.0, lo=1.0)
        if glow:
            s.rgb[int(cy) + 1:int(cy) + 3, int(cx) - 2:int(cx)] = glow

    def rgba(s):
        out = np.zeros((s.H, s.W, 4), np.uint8)
        out[..., :3] = s.rgb
        out[..., 3] = np.where(s.mask, 255, 0)
        out[~s.mask, :3] = 0
        return Image.fromarray(out, "RGBA")


def edge_col(base):
    return mix(PLUM3, base, 0.55)


def rot_rect(cx, cy, r0, r1, wd, ang):
    a = math.radians(ang)
    ux, uy, vx, vy = math.cos(a), math.sin(a), -math.sin(a), math.cos(a)
    return [(cx + ux * r + vx * w, cy + uy * r + vy * w) for r, w in ((r0, -wd), (r1, -wd), (r1, wd), (r0, wd))]


# ---------------------------------------------------------------- the eight arenas
def a_kawah(c):
    """Crater rim causeway: coarse basalt flags, sulphur stains, ash, a worn ritual ring."""
    base = sh(mix(h("4A464C"), h("6E6259"), 0.5), 0.84)
    c.slabs(base, ch=32, widths=(32, 48, 64, 96))
    for x, y in c.pick(5, dmin=10):
        c.blob(x, y, float(c.rng.integers(12, 24)), mix(base, (180, 160, 66), 0.26), wob=0.38, hi=1.04, lo=0.92)
    cx, cy = c.centre
    ink = mix(base, (172, 150, 84), 0.34)

    def ritual(d):
        for r0, r1 in ((150, 158), (112, 116), (14, 20)):
            d.ellipse([cx - r1, cy - r1, cx + r1, cy + r1], fill=255)
            d.ellipse([cx - r0, cy - r0, cx + r0, cy + r0], fill=0)
        for i in range(12):
            d.polygon(rot_rect(cx, cy, 124, 146, 3, i * 30 + 15), fill=255)
        pts = c.poly_pts(cx, cy, 90, 8)
        for i in range(8):
            d.line([pts[i], pts[(i + 3) % 8]], fill=255, width=3)
    shp = c.wear(c.shape(ritual), 40, 4, 11)
    c.inlay(shp, ink, edge=edge_col(base))
    c.cracks(14, 30, 80, sh(base, 0.6))
    for x, y in c.pick(26, dmax=16):
        c.blob(x, y, float(c.rng.integers(3, 8)), mix(base, (196, 190, 184), 0.28), wob=0.3, hi=1.1)
    c.bands()


def a_leuwi(c):
    """Dusk riverside clearing: dark wet earth, puddles, a pebble ring, four oncor sockets."""
    earth = sh(h("594533"), 0.72)
    c.blotch(earth, 64, f=(0.93, 1.0, 1.07))
    water = (32, 54, 62)
    for x, y in c.pick(7, dmin=12):
        c.pool(x, y, float(c.rng.integers(18, 32)), float(c.rng.integers(7, 12)), water, edge=mix(PLUM3, earth, 0.6))
    cx, cy = c.boss
    stone = h("6E757A")
    for i in range(22):   # river-pebble ring where the Sandekala is called
        a = i / 22 * 2 * math.pi + 0.1
        c.blob(cx + 104 * math.cos(a), cy + 78 * math.sin(a), 4.2, sh(stone, 0.78), wob=0.2, edge=edge_col(earth))
    for x, y in c.pick(60, dmin=3):
        c.blob(x, y, 2.2, sh(stone, 0.6), wob=0.1, hi=1.2, lo=0.85)
    for x, y in c.pick(40, dmax=30):
        c.tuft(x, y, mix(earth, (74, 110, 62), 0.55))
    for _, w, (x, y) in c.marks:
        if w.startswith("oncor"):
            c.socket(x, y, sh(stone, 0.75), (20, 14, 12), glow=(214, 120, 44))
    c.bands()


def a_keraton(c):
    """Throne room: glazed tile checker, royal carpet runner to a stepped dais."""
    cream = sh(h("E0D4B8"), 0.9)
    ts = 32
    par = (((c.xx // ts) + (c.yy // ts)) % 2).astype(np.int64)
    c.paint_ids((c.yy // ts) * 1000 + c.xx // ts, cream, f=(0.96, 1.04), tone=par)
    tx, ty = (c.xx % ts) - 15.5, (c.yy % ts) - 15.5
    med = ((c.xx // ts) % 4 == 2) & ((c.yy // ts) % 4 == 2)   # one glazed teal medallion every fourth tile
    c.inlay((np.abs(tx) + np.abs(ty) <= 11) & (np.abs(tx) + np.abs(ty) >= 5) & med, mix(cream, h("267878"), 0.3), hi=1.1)
    bx = int(c.boss[0] // 16 * 16)   # boss column, 16-aligned
    stone = mix(cream, (236, 230, 214), 0.5)
    for (xh, y0, y1) in ((112, 96, 152), (80, 0, 96)):   # two dais steps, riser at the foot of each
        c.inlay(c.rect(bx - xh, y0, bx + xh, y1), stone, edge=edge_col(cream))
        c.put(c.rect(bx - xh + 2, y1 - 6, bx + xh - 2, y1 - 1), sh(stone, 0.82))
    red, gold = (128, 44, 54), (200, 152, 76)
    cw = 32
    c.inlay(c.rect(bx - cw, 24, bx + cw, c.H), red, edge=edge_col(red))
    c.put(c.rect(bx - cw + 4, 24, bx - cw + 7, c.H) | c.rect(bx + cw - 7, 24, bx + cw - 4, c.H), gold)
    c.put(c.rect(bx - cw + 4, 24, bx + cw - 4, 27), gold)
    dy = (c.yy % 32) - 16
    dia = (np.abs(c.xx - bx + 0.5) + np.abs(dy + 0.5) <= 10) & (c.xx >= bx - cw + 10) & (c.xx < bx + cw - 10) & (c.yy >= 36)
    c.inlay(dia, (104, 34, 46), hi=1.12)
    c.put(c.rect(bx - 2, 0, bx + 2, c.H) & ((c.yy % 32 >= 14) & (c.yy % 32 < 18)) & (c.yy >= 36), gold)
    c.cracks(6, 10, 26, sh(cream, 0.7), dmin=8)
    for x, y in c.pick(18, dmin=4):
        c.blob(x, y, 2.5, sh(cream, 0.8), wob=0.2, hi=1.05)
    c.bands()


def a_pamali(c):
    """River ford: shingle ford with two shallow streams, stepping stones and gravel bars; mossy banks."""
    ford = c.kind == ord(",")
    bank = c.kind == ord(".")
    sand = sh(mix(h("636963"), (150, 130, 95), 0.4), 0.88)
    moss = sh(mix(h("454D46"), h("548250"), 0.5), 0.9)
    c.blotch(sand, 40, f=(0.93, 1.0, 1.07), region=ford)
    c.blotch(moss, 64, f=(0.94, 1.0, 1.06), region=bank)
    cols = np.where(ford.any(axis=0))[0]
    x0, x1 = (int(cols.min()), int(cols.max())) if len(cols) else (0, c.W)
    water = (50, 82, 90)
    stones = []
    for fr, ph in ((0.34, 0.0), (0.66, 2.1)):
        xc = x0 + (x1 - x0) * fr
        wob = xc + 14 * np.sin(c.yy / 46.0 + ph)
        ch_m = ford & (np.abs(c.xx + 0.5 - wob) < 17)
        bar = ford & (np.abs(np.abs(c.xx + 0.5 - wob) - 30) < 5) & ((c.yy // 34 + int(ph * 3)) % 3 != 0)
        c.inlay(bar, sh(sand, 1.1), hi=1.08, lo=0.86)
        c.inlay(ch_m, water, edge=edge_col(sand), hi=1.5)
        yc = c.H * 0.5 + 10 * math.sin(ph * 3)
        for i, dx in enumerate((-27, -9, 9, 27)):   # stepping stones across the stream
            stones.append((xc + 14 * math.sin(yc / 46.0 + ph) + dx, yc + (-5, 4, -3, 5)[i]))
    for x, y in c.pick(14, dmin=6, region=ford):
        c.put(c.rect(x, y, x + 4, y + 1), (140, 178, 180))
    stone = (118, 118, 110)
    for x, y in stones:
        c.blob(x, y, 8.5, stone, wob=0.12, edge=edge_col(stone))
    for x, y in c.pick(70, dmin=3, region=ford):
        c.blob(x, y, 2.4, sh(sand, 0.74), wob=0.15, hi=1.15)
    for x, y in c.pick(40, dmin=2, region=bank):
        c.tuft(x, y, mix(moss, (96, 140, 84), 0.55))
    c.bands()


def a_candi(c):
    """Temple building site at night: a half-laid andesite mandala foundation on packed earth."""
    earth = (92, 84, 72)   # night-grey packed earth, not the green of the ruins' ground tile
    c.blotch(earth, 96, f=(0.94, 1.0, 1.06))
    cx, cy = c.centre
    half = int(min(c.W, c.H) * 0.44) // 16 * 16
    sq = lambda hw: (np.abs(c.xx + 0.5 - cx) <= hw) & (np.abs(c.yy + 0.5 - cy) <= hw)
    edge = np.zeros(c.H, np.int64)   # ragged laying front, one 32 px course at a time, east of the centre line
    for r in range(0, c.H // 32 + 1):
        edge[r * 32:(r + 1) * 32] = cx + 16 * int(c.rng.integers(-4, 6))
    laid = sq(half - 16) & (c.xx < edge[c.yy])
    stone = sh(mix(h("857E75"), (120, 126, 132), 0.3), 0.8)
    c.slabs(stone, ch=32, widths=(32, 64), region=laid)
    chalk = mix(earth, (206, 200, 172), 0.34)
    open_ = sq(half - 16) & ~laid
    c.put(open_ & ((c.yy - cy) % 64 < 2) & ((c.xx // 8) % 3 != 2), chalk)
    c.put(open_ & ((c.xx - cx) % 64 < 2) & ((c.yy // 8) % 3 != 2), chalk)
    curb = sq(half) & ~sq(half - 16)
    for _ in range(6):   # curb blocks not set yet on the east side
        gy = int(c.rng.integers(cy - half, cy + half - 40)) // 16 * 16
        curb &= ~c.rect(cx + half - 20, gy, cx + half + 2, gy + 48 + 16 * int(c.rng.integers(0, 3)))
    c.inlay(curb, sh(stone, 1.12), edge=edge_col(earth))
    c.inlay(sq(half - 24) & ~sq(half - 28) & laid, sh(stone, 0.9))
    med = c.ring(cx, cy, 20, 34) | c.disc(cx, cy, 7)
    c.inlay(med, sh(stone, 1.2), edge=edge_col(stone))
    c.put(c.disc(cx, cy, 12) & ~c.disc(cx, cy, 7), mix(stone, h("70E0D0"), 0.3))
    for x, y in c.pick(40, dmin=6, region=open_ | ~sq(half + 8)):
        c.blob(x, y, float(c.rng.integers(2, 5)), sh(stone, 1.0), wob=0.3, hi=1.15)
    c.cracks(10, 14, 34, sh(stone, 0.58), dmin=6)
    for x, y in c.pick(26, dmax=20, region=laid):
        c.blob(x, y, float(c.rng.integers(3, 7)), mix(stone, (84, 112, 72), 0.5), wob=0.35)
    c.bands()


def a_ladang(c):
    """Buto Ijo's field: dry golden furrows, a trodden threshing circle with a burnt spiral, dead stalks."""
    earth = sh(mix(h("9E8044"), h("8C583A"), 0.45), 0.8)
    c.blotch(earth, 80, f=(0.94, 1.0, 1.06))
    cx, cy = c.centre
    R = int(min(c.W, c.H) * 0.3)
    nb = c.H // 32 + 1
    seg = np.zeros((nb, c.W), bool)
    for b in range(nb):
        x = -int(c.rng.integers(0, 120))
        while x < c.W:
            n = int(c.rng.integers(90, 240))
            seg[b, max(x, 0):max(x + n, 0)] = True
            x += n + int(c.rng.integers(24, 56))
    fur = seg[c.yy // 32, c.xx]
    out = ~c.disc(cx, cy, R + 8)
    c.put(fur & out & (c.yy % 32 < 4), sh(earth, 0.82))
    c.put(fur & out & (c.yy % 32 == 4), sh(earth, 1.1))
    c.put(c.disc(cx, cy, R), sh(earth, 0.94))
    c.inlay(c.ring(cx, cy, R, R + 6), sh(earth, 0.72), edge=edge_col(earth), hi=1.1)

    def spiral(d):
        pts = [(cx + (10 + t * 0.9) * math.cos(t / 14.0), cy + (10 + t * 0.9) * math.sin(t / 14.0)) for t in range(0, 150)]
        d.line(pts, fill=255, width=4)
    c.inlay(c.wear(c.shape(spiral), 18, 3, 8), mix(earth, (44, 32, 28), 0.5), hi=1.1)
    for x, y in c.pick(16, dmin=4, region=c.disc(cx, cy, R)):
        c.blob(x, y, float(c.rng.integers(3, 8)), mix(earth, (150, 142, 128), 0.4), wob=0.3, hi=1.1)
    straw = mix(earth, (200, 178, 104), 0.5)
    for x, y in c.pick(110, dmin=3, region=out & fur):
        c.tuft(x, y, straw)
    c.cracks(26, 14, 40, sh(earth, 0.62), dmin=5)
    c.bands()


def a_tt_candi(c):
    """Cursed keris court: ash-red slabs, a seven-pointed curse star in a ring, seven stake sockets."""
    base = sh(mix(h("593333"), h("524C4A"), 0.5), 1.0)
    c.slabs(base, ch=32, widths=(32, 64))
    cx, cy = c.centre
    ink = mix(base, (176, 56, 66), 0.34)
    R = int(c.H * 0.39)

    def star(d):
        d.ellipse([cx - R, cy - R, cx + R, cy + R], fill=255)
        d.ellipse([cx - R + 7, cy - R + 7, cx + R - 7, cy + R - 7], fill=0)
        pts = c.poly_pts(cx, cy, R - 3, 7)
        for i in range(7):
            d.line([pts[i], pts[(i + 2) % 7]], fill=255, width=5)
        d.ellipse([cx - 54, cy - 54, cx + 54, cy + 54], fill=255)
        d.ellipse([cx - 46, cy - 46, cx + 46, cy + 46], fill=0)
        d.ellipse([cx - 12, cy - 12, cx + 12, cy + 12], fill=255)
    c.inlay(c.wear(c.shape(star), 22, 4, 9), ink, edge=edge_col(base))
    for x, y in c.pick(12, dmin=8):
        c.crack(x, y, int(c.rng.integers(18, 44)), mix(base, (110, 30, 40), 0.55))
    for _, w, (x, y) in c.marks:
        if w.startswith("curse stake"):
            c.blob(x, y, 11, sh(base, 0.62), wob=0.08, hi=1.0, lo=1.0, edge=mix(PLUM3, (160, 50, 60), 0.4))
            c.blob(x, y, 5, (24, 14, 20), wob=0.05, hi=1.0, lo=1.0)
    for x, y in c.pick(30, dmax=24):
        c.blob(x, y, float(c.rng.integers(3, 7)), mix(base, (150, 140, 136), 0.3), wob=0.3, hi=1.1)
    c.bands()


def a_kala(c):
    """Batara Kala's chamber: polar paving, a gold zodiac ring of twelve houses, an hourglass sigil."""
    cx, cy = (int(c.boss[0]), int(c.boss[1]))
    base = (66, 51, 86)
    c.paint_ids(c.polar_ids(cx, cy, 40, 56), base, f=(0.95, 1.0, 1.05))
    gold = mix(base, h("C99B3B"), 0.42)

    def zodiac(d):
        for r0, r1 in ((372, 382), (306, 312), (232, 236)):
            d.ellipse([cx - r1, cy - r1, cx + r1, cy + r1], fill=255)
            d.ellipse([cx - r0, cy - r0, cx + r0, cy + r0], fill=0)
        for i in range(12):
            a = math.radians(i * 30 + 15)
            gx, gy = cx + 342 * math.cos(a), cy + 342 * math.sin(a)
            d.polygon([(gx - 13, gy), (gx, gy - 17), (gx + 13, gy), (gx, gy + 17)], fill=255)
            d.polygon(rot_rect(cx, cy, 100, 228, 2, i * 30), fill=255)
        up = [(cx - 64, cy - 84), (cx + 64, cy - 84), (cx, cy)]
        dn = [(cx - 64, cy + 84), (cx + 64, cy + 84), (cx, cy)]
        d.polygon(up, fill=255)
        d.polygon(dn, fill=255)
        for pts in (up, dn):
            sx, sy = sum(p[0] for p in pts) / 3, sum(p[1] for p in pts) / 3
            d.polygon([(sx + (px - sx) * 0.55, sy + (py - sy) * 0.55) for px, py in pts], fill=0)
        d.ellipse([cx - 20, cy - 20, cx + 20, cy + 20], fill=255)
    c.inlay(c.wear(c.shape(zodiac), 46, 4, 12), gold, edge=edge_col(base))
    c.inlay(c.disc(cx, cy, 8), mix(gold, h("FFD166"), 0.3), hi=1.1)
    for x, y in c.pick(12, dmin=8):
        c.crack(x, y, int(c.rng.integers(20, 50)), mix(base, h("9D4EDD"), 0.32))
    for x, y in c.pick(24, dmax=22):
        c.blob(x, y, float(c.rng.integers(3, 6)), sh(base, 0.78), wob=0.3, hi=1.05)
    c.bands()


STYLE = {"ts_kawah": a_kawah, "ts_leuwi": a_leuwi, "kg_keraton": a_keraton, "kg_pamali": a_pamali,
         "mt_candi": a_candi, "tt_ladang": a_ladang, "tt_candi": a_tt_candi, "gk_ruang_kala": a_kala}


def build_floors(only):
    out = {}
    for aid, (doc, rect) in ARENAS.items():
        if only and aid not in only:
            continue
        info = load_area(doc, aid, rect)
        cv = Cv(info, seed=sum(map(ord, aid)))
        STYLE[aid](cv)
        im = cv.rgba()
        w, hh = rect[2] - rect[0] + 1, rect[3] - rect[1] + 1
        assert im.size == (w * info["S"], hh * info["S"]), (aid, im.size)
        assert not np.asarray(im)[~cv.mask][:, 3].any()
        P.save(im, "arena/%s.png" % aid)
        out[aid] = im
        print("floor", aid, im.size, "k=%d" % info["k"], "rect", rect)
    return out


# ---------------------------------------------------------------- set-piece props (transparent, plum outline)
def _im(w, h_):
    return Image.new("RGBA", (w, h_), (0, 0, 0, 0))


def _put(im, x, y, c):
    if 0 <= x < im.width and 0 <= y < im.height:
        im.putpixel((x, y), tuple(c)[:3] + (255,))


def _fill(im, x0, y0, x1, y1, c):
    ImageDraw.Draw(im).rectangle([x0, y0, x1, y1], fill=tuple(c)[:3] + (255,))


def _bevel_rect(im, x0, y0, x1, y1, mid, hi=1.25, lo=0.7):
    _fill(im, x0, y0, x1, y1, mid)
    _fill(im, x0, y0, x1, y0, sh(mid, hi))
    _fill(im, x0, y0, x0, y1, sh(mid, hi))
    _fill(im, x1, y0 + 1, x1, y1, sh(mid, lo))
    _fill(im, x0 + 1, y1, x1, y1, sh(mid, lo))


def _poly(im, pts, c):
    ImageDraw.Draw(im).polygon(pts, fill=tuple(c)[:3] + (255,))


def _ell(im, box, c):
    ImageDraw.Draw(im).ellipse(box, fill=tuple(c)[:3] + (255,))


STONE = (138, 132, 124)
WOOD = (146, 96, 58)
GOLD = (214, 164, 70)


def prop_banner():
    """The Faceless Captain's war banner: pole on a cairn, crimson cloth with a blank mask, 4 frames of wave."""
    frames = []
    red = (150, 40, 48)
    for f in range(4):
        im = _im(16, 40)
        for x0, x1, y0, c in ((1, 7, 35, STONE), (6, 13, 36, sh(STONE, 0.86)), (3, 10, 33, sh(STONE, 1.08))):
            _bevel_rect(im, x0, y0, x1, 39 if y0 > 33 else 36, c)
        _bevel_rect(im, 3, 4, 4, 35, WOOD, hi=1.3)
        _fill(im, 3, 1, 4, 3, (200, 204, 208))
        _put(im, 3, 0, (230, 234, 238))
        _bevel_rect(im, 3, 5, 13, 6, sh(WOOD, 0.92))
        _put(im, 13, 7, GOLD)
        _put(im, 13, 8, sh(GOLD, 0.8))
        for y in range(7, 32):
            k = (y - 7) / 24.0
            dx = int(round(1.8 * k * math.sin(f * math.pi / 2 + y / 4.0)))
            left, right = 5, 12 + dx
            mid = (left + right) / 2.0
            for x in range(left, right + 1):
                if y > 26 + min(5, abs(x - mid)):   # swallowtail
                    continue
                t = math.sin(x * 0.95 + y * 0.18 + f * math.pi / 2)
                c = sh(red, 1.22) if t > 0.45 else sh(red, 0.7) if t < -0.45 else red
                if y == 7:
                    c = GOLD
                _put(im, x, y, c)
        cxm = 8 + int(round(1.8 * 0.35 * math.sin(f * math.pi / 2 + 3.0)))
        for y in range(11, 20):   # the blank mask: a pale oval with no face
            half = 2 if y in (11, 19) else 3 if y in (12, 18) else 4 if False else 3
            for x in range(cxm - half + 1, cxm + half):
                _put(im, x, y, (232, 220, 196) if x < cxm + half - 1 and y < 18 else (186, 170, 148))
        frames.append(P.plum_outline(im))
    return P.strip(frames)


def prop_boat():
    """Sangkuriang's half-built overturned perahu (the Tangkuban Parahu legend): planked to the east, bare ribs west."""
    im = _im(64, 32)
    plank = [(176, 124, 76), (146, 96, 58), (112, 72, 46)]
    dark = (40, 28, 30)
    gy = 27
    _fill(im, 3, gy, 61, gy, (52, 40, 36))
    top = {}
    for x in range(3, 62):
        t = (x - 32.0) / 29.0
        top[x] = gy - 1 - int(round(18 * max(0.0, 1 - t * t) ** 0.65))
    for x in range(3, 62):
        for y in range(top[x], gy):
            k = (y - top[x]) // 4
            xs = 12 + 5 * k   # planking front: each plank course starts further east
            laid = x >= xs
            rib = (x - 3) % 7 < 2
            if laid:
                c = plank[1] if k % 2 == 0 else plank[0]
                if (y - top[x]) % 4 == 3:
                    c = plank[2]
                if x == xs:
                    c = plank[2]
            elif rib:
                c = plank[0] if (x - 3) % 7 == 0 else plank[1]
            else:
                c = dark if y - top[x] > 1 else plank[1]
            _put(im, x, y, c)
        _put(im, x, top[x], sh(plank[0], 1.25))
        _put(im, x, top[x] + 1, plank[0])
    for x in range(3, 62):   # keel beam, bolder than the planks
        _put(im, x, top[x] + 2, plank[2])
    for x, y in ((6, 29), (9, 30), (13, 28), (18, 30), (49, 29), (55, 30), (58, 28), (24, 29), (41, 30)):
        _put(im, x, y, (214, 190, 130))   # wood chips
    _fill(im, 3, 28, 6, 29, sh(WOOD, 0.7))   # an offcut
    return P.plum_outline(im)


def prop_mirror():
    """A standing palace mirror in a carved Galuh frame: plain, then cracked."""
    frames = []
    teak, glass = (146, 90, 54), (168, 212, 214)
    for cracked in (False, True):
        im = _im(24, 40)
        _bevel_rect(im, 2, 36, 21, 38, sh(teak, 0.78))
        _bevel_rect(im, 4, 33, 7, 36, sh(teak, 0.9))
        _bevel_rect(im, 16, 33, 19, 36, sh(teak, 0.9))
        _ell(im, (3, 3, 20, 18), teak)
        _fill(im, 3, 11, 20, 34, teak)
        _fill(im, 3, 10, 3, 34, sh(teak, 1.28))
        _fill(im, 20, 14, 20, 34, sh(teak, 0.7))
        _fill(im, 4, 34, 20, 34, sh(teak, 0.7))
        for y in range(8, 33, 3):   # carved border: gold beads down both stiles
            _put(im, 4, y, GOLD)
            _put(im, 19, y, sh(GOLD, 0.8))
        for x in range(6, 18, 3):
            _put(im, x, 34 - 0, GOLD)
        _ell(im, (6, 6, 17, 17), glass)
        _fill(im, 6, 12, 17, 31, glass)
        for y in range(7, 32):   # silvery diagonal glint, deep bottom-right
            for x in range(6, 18):
                if im.getpixel((x, y))[3] and (x + y) % 11 in (0, 1) and x < 15:
                    _put(im, x, y, (232, 246, 244))
                elif im.getpixel((x, y))[3] and x + y > 40:
                    _put(im, x, y, (118, 164, 172))
        _put(im, 11, 1, GOLD)   # finial
        _fill(im, 11, 2, 12, 3, GOLD)
        _put(im, 10, 3, sh(GOLD, 0.8))
        _put(im, 13, 3, sh(GOLD, 0.8))
        if cracked:
            for pts in (((11, 17), (8, 12), (7, 8)), ((11, 17), (15, 13), (16, 9)), ((11, 17), (9, 23), (7, 30)), ((11, 17), (14, 22), (16, 29))):
                ImageDraw.Draw(im).line(pts, fill=(36, 62, 72, 255), width=1)
            for x, y in ((12, 12), (13, 15), (10, 21), (13, 25), (9, 14)):
                _put(im, x, y, (246, 252, 250))
            _poly(im, [(14, 7), (17, 8), (16, 11)], (22, 34, 44))
        frames.append(P.plum_outline(im))
    return P.strip(frames)


def prop_drum():
    """A temple drum-stone: bedug on a carved stone base, idle then struck (glowing head, ringing air)."""
    frames = []
    st = [(150, 144, 134), (116, 110, 104), (80, 76, 74)]
    wood = (148, 92, 54)
    for hit in (False, True):
        im = _im(32, 32)
        _bevel_rect(im, 2, 26, 29, 30, st[1])
        _bevel_rect(im, 5, 22, 26, 25, st[0])
        for x in range(7, 26, 4):
            _put(im, x, 28, st[2])
            _put(im, x, 23, st[2])
        _ell(im, (6, 6, 27, 21), wood)   # the barrel
        _fill(im, 9, 6, 24, 8, sh(wood, 1.2))
        _fill(im, 9, 19, 24, 21, sh(wood, 0.72))
        for x in (12, 21):   # bronze hoops
            _fill(im, x, 7, x + 1, 20, sh(GOLD, 1.12 if hit else 0.95))
            _put(im, x, 13, (255, 240, 190) if hit else sh(GOLD, 1.3))
        for y in (10, 13, 16):
            _put(im, 16, y, sh(wood, 0.62))
        face = (255, 238, 170) if hit else (226, 200, 154)
        _ell(im, (3, 5, 10, 21), sh(wood, 0.62))
        _ell(im, (4, 6, 9, 20), face)
        _ell(im, (5, 9, 8, 17), (255, 252, 226) if hit else sh(face, 1.08))
        if hit:
            for x, y in ((0, 4), (1, 12), (0, 20), (2, 2), (1, 22), (13, 3), (24, 3), (28, 6)):
                _put(im, x, y, (112, 232, 214))
            for y in range(7, 20):
                _put(im, 1, y, (255, 224, 140)) if y % 2 else None
        frames.append(P.plum_outline(im))
    return P.strip(frames)


def prop_sundial():
    """A stone sundial / dawn marker: ticked plate, gnomon fin with its shadow, a small gold sun at the east tick."""
    im = _im(24, 24)
    st = [(158, 152, 142), (124, 118, 110), (88, 84, 82)]
    _bevel_rect(im, 7, 20, 16, 22, st[1])
    _ell(im, (2, 11, 21, 21), st[2])
    _ell(im, (2, 10, 21, 19), st[1])
    _ell(im, (4, 11, 19, 18), st[0])
    for i in range(12):
        a = i * math.pi / 6
        _put(im, int(round(11.5 + 8.0 * math.cos(a))), int(round(14.5 + 3.4 * math.sin(a))), st[2])
    _poly(im, [(13, 14), (18, 16), (15, 17), (12, 15)], (104, 100, 98))
    _poly(im, [(11, 14), (14, 14), (14, 3)], st[1])
    _poly(im, [(11, 14), (12, 14), (12, 5)], st[0])
    _fill(im, 3, 13, 5, 15, GOLD)
    _put(im, 3, 13, (255, 226, 130))
    return P.plum_outline(im)


def prop_hourglass():
    """Batara Kala's hourglass: bronze, carved, empty glass (code draws the sand)."""
    im = _im(24, 40)
    br = [(222, 170, 76), (170, 120, 48), (112, 76, 38)]
    glass = (176, 190, 206)
    inner = (58, 50, 82)
    for y0, y1 in ((2, 5), (34, 37)):
        _bevel_rect(im, 3, y0, 20, y1, br[1])
        for x in range(5, 20, 3):
            _put(im, x, (y0 + y1) // 2, br[2])
    _put(im, 11, 3, (255, 232, 150))
    _put(im, 12, 3, (255, 232, 150))
    for x0 in (3, 18):   # twisted posts
        _fill(im, x0, 6, x0 + 1, 33, br[1])
        for y in range(6, 34, 3):
            _put(im, x0, y, br[0])
            _put(im, x0 + 1, y + 1, br[2])
    for y in range(6, 34):   # two funnels meeting at a neck between y 19 and 20
        yy = y if y < 20 else 39 - y
        half = max(1, int(round(1 + 5.0 * (1 - (yy - 6) / 13.5) ** 0.75)))
        for x in range(12 - half, 12 + half):
            _put(im, x, y, inner if 12 - half < x < 11 + half and y not in (6, 33) else glass)
        _put(im, 12 - half, y, (232, 240, 248))
        _put(im, 11 + half, y, sh(glass, 0.62))
    return P.plum_outline(im)


PROPS = {"arena_banner": prop_banner, "arena_boat": prop_boat, "arena_mirror": prop_mirror,
         "arena_drum": prop_drum, "arena_sundial": prop_sundial, "arena_hourglass": prop_hourglass}


def build_props():
    out = {}
    for name, fn in PROPS.items():
        im = fn()
        P.save(im, "props/%s.png" % name)
        out[name] = im
        print("prop", name, im.size)
    return out


def build_preview(floors, props):
    cw, chh = 560, 330
    cols = 2
    rows = (len(ARENAS) + cols - 1) // cols
    pw = 4
    prop_h = max(i.height for i in props.values()) * 2 + 16
    W = cols * (cw + 8) + 8
    Hh = rows * (chh + 8) + 8 + prop_h + 8
    sheet = Image.new("RGBA", (W, Hh), (20, 24, 30, 255))
    for i, aid in enumerate(ARENAS):
        if aid not in floors:
            continue
        im = floors[aid]
        sc = min(cw / im.width, chh / im.height)
        sm = im.resize((max(1, int(im.width * sc)), max(1, int(im.height * sc))), Image.BOX)
        x, y = 8 + (i % cols) * (cw + 8), 8 + (i // cols) * (chh + 8)
        sheet.alpha_composite(sm, (x, y))
    x = 8
    y = rows * (chh + 8) + 16
    for im in props.values():
        big = im.resize((im.width * 2, im.height * 2), Image.NEAREST)
        sheet.alpha_composite(big, (x, y))
        x += big.width + 14
    sheet.save(os.path.join(HERE, "arena_floors_preview.png"))
    print("preview", sheet.size)


if __name__ == "__main__":
    only = set(sys.argv[1:])
    fl = build_floors(only)
    build_preview(fl, build_props())
