#!/usr/bin/env python3
"""World map and map legend art for the Peta tab (.docs/revamp_plan.md 4, ui.md 4.3). Pixel art in the game's own
palette: the sea is dusk indigo (UI v3 "Senja"), the land wears each region's colour cast (assets.md 1), every
object is a small hand-authored sprite (mountains, candi, palace, banyan, huts, boats) stamped by rule.

Outputs (assets/art/ui/): map_world.png 432x184, map_fog_<region>.png (dark dither over a region not yet visited),
map_icons.png (legend and marker icons, 11x11 each, ICON_ORDER), and ui/map_regions.gd (region anchors for the
engine). Run: python3 tools/gen_map_art.py
"""
import math
import os
import random
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import numpy as np
from PIL import Image
import pixlib as px
from pixlib import hexc

W, H = 432, 184
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
BAYER = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0

# region id -> (seed x, seed y, rx, ry, base colours (hi, mid, lo), label anchor)
REGIONS = {
    "tatar_sunda":   (66, 96, 54, 60, ("6FA352", "4E8040", "33592E"), (52, 72)),
    "keraton_galuh": (140, 90, 46, 50, ("C0A05A", "A4803F", "7A5A2E"), (140, 66)),
    "desa_purwa":    (212, 98, 30, 34, ("86B060", "5E9048", "3E6A34"), (212, 98)),
    "mataram":       (284, 92, 50, 54, ("B8AE98", "978C76", "6E6552"), (282, 66)),
    "tanah_timur":   (368, 94, 48, 52, ("D2A04E", "B27D36", "84582A"), (370, 70)),
    "segara_kidul":  (214, 152, 50, 28, ("62BFB0", "3F9A8E", "2B6E6A"), (214, 164)),
    "gua_kala":      (222, 34, 36, 26, ("8A7AA8", "62547E", "403458"), (222, 22)),
}
ORDER = list(REGIONS.keys())
SEA_DEEP, SEA_MID, SEA_SHALLOW = hexc("1B2150"), hexc("25306A"), hexc("3A5090")
FOAM, OUTLINE = hexc("DCE8F0"), hexc("0E0B24")


# ------------------------------------------------------------------------------------------------ noise
def _hash(ix, iy, seed):
    n = (ix * 374761393 + iy * 668265263 + seed * 2147483647) & 0xFFFFFFFF
    n = ((n ^ (n >> 13)) * 1274126177) & 0xFFFFFFFF
    return (n ^ (n >> 16)) / 4294967295.0


def vnoise(x, y, seed):
    ix, iy = np.floor(x).astype(int), np.floor(y).astype(int)
    fx, fy = x - ix, y - iy
    fx, fy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
    h = np.vectorize(lambda a, b: _hash(a, b, seed))
    a, b, c, d = h(ix, iy), h(ix + 1, iy), h(ix, iy + 1), h(ix + 1, iy + 1)
    return a + (b - a) * fx + (c - a) * fy + (a - b - c + d) * fx * fy


def fbm(x, y, seed, octaves=3):
    v, amp, tot = 0.0, 1.0, 0.0
    for o in range(octaves):
        v = v + amp * vnoise(x * 2 ** o, y * 2 ** o, seed + o * 17)
        tot += amp
        amp *= 0.5
    return v / tot


YY, XX = np.mgrid[0:H, 0:W].astype(float)


# ------------------------------------------------------------------------------------------------ land
def build_fields():
    fields = []
    warp = (fbm(XX / 22, YY / 22, 3) - 0.5) * 16
    warp2 = (fbm(XX / 22, YY / 22, 9) - 0.5) * 16
    for rid in ORDER:
        sx, sy, rx, ry, _, _ = REGIONS[rid]
        d = ((XX + warp - sx) / rx) ** 2 + ((YY + warp2 - sy) / ry) ** 2
        fields.append(1.0 - d)
    f = np.stack(fields)
    nz = (fbm(XX / 9, YY / 9, 21, 3) - 0.5) * 0.38
    land = (f.max(0) + nz) > 0.0
    # the island is one body: a drawn spine joins the regions so no lobe floats alone
    region = f.argmax(0)
    return land, region, f.max(0) + nz


def elevation():
    return fbm(XX / 14, YY / 14, 40, 4)


def dist_to_land(land, limit=5):
    """Chebyshev-ish distance for ocean pixels up to `limit` (cheap dilation)."""
    d = np.full(land.shape, 99)
    d[land] = 0
    cur = land.copy()
    for k in range(1, limit + 1):
        n = cur.copy()
        n[1:, :] |= cur[:-1, :]; n[:-1, :] |= cur[1:, :]; n[:, 1:] |= cur[:, :-1]; n[:, :-1] |= cur[:, 1:]
        d[(n & ~cur)] = k
        cur = n
    return d


# ------------------------------------------------------------------------------------------------ sprites
def spr(rows, pal):
    h = len(rows)
    w = max(len(r) for r in rows)
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch in ". ":
                continue
            im.putpixel((x, y), pal[ch])
    return im


def outlined(im):
    return px.outline(im)


P = {"k": hexc("0E0B24"), "w": hexc("F4EEDC"), "s": hexc("8E8A9E"), "d": hexc("5A5670"), "g": hexc("5E9048"),
     "G": hexc("3E6A34"), "l": hexc("86B060"), "b": hexc("7A5030"), "B": hexc("4E3220"), "r": hexc("B8402E"),
     "R": hexc("7E2A22"), "y": hexc("F2C85A"), "Y": hexc("C8963A"), "o": hexc("E8803A"), "c": hexc("7FE8E0"),
     "n": hexc("2B3A78"), "t": hexc("D8C79A"), "p": hexc("6A5A8E"), "P": hexc("40345E"), "e": hexc("F2B27A")}

MOUNTAIN = spr(["....ww....", "...wsww...", "..wsssdw..", ".ssdsssdd.", "sssdsdsssd", "sdsddsdddd"], P)
MOUNTAIN_S = spr(["...ww...", "..wssw..", ".ssdssd.", "sdsddsdd"], P)
VOLCANO = spr(["....oo.....", "...yoy.....", "..ddssdd...", ".dsssdsdd..", "dsssdsssdd.", "dddsdddsddd"], P)
TREE = spr(["..g..", ".glg.", "glggG", ".GgG.", "..b.."], P)
PINE = spr(["..g..", ".glg.", "..g..", ".glgG", "..b.."], P)
PALM = spr(["l.l.l", ".lGl.", "..b..", "..b..", "..b.."], P)
HUT = spr([".rrr.", "rrrrr", "tbtbt", "tbBbt"], P)
CANDI = spr(["....s....", "...sws...", "..sdsds..", ".ssdsdss.", "sddsdsdds", "sdddsdddd"], P)
CANDI_B = spr(["..s..", ".sws.", "sdsds", "sdddd"], P)
PALACE = spr(["...y...", "..yry..", ".rrrrr.", "rRrrrRr", ".t.t.t.", "ttttttt", "tBtBtBt"], P)
BANYAN = spr(["..ggGgg..", ".glgGggG.", "gGgggGggg", ".gG.b.Gg.", "...bBb...", "..b.b.b.."], P)
CAVE = spr([".sssss.", "sdkkkds", "sdkkkds", "sskkkss"], P)
SHIP = spr(["...w...", "..www..", ".wwwww.", "...b...", "bbbbbbb", ".bBBBb."], P)
CRATER = spr([".pPPPp.", "pPeoePp", ".pPPPp."], P)
SERPENT = spr([".cc..cc.", "c.cccc.c", "..c..c.."], P)
RICE = spr(["lglglgl", "GgGgGgG", "lglglgl"], P)
HILL = spr([".ll..", "lllgl", "ggggg"], P)
BOAT_S = spr([".w.", "bbb"], P)


def stamp(img, im, x, y, shadow=True):
    o = outlined(im)
    img.alpha_composite(o, (int(x - o.width // 2), int(y - o.height + 1)))


# ------------------------------------------------------------------------------------------------ main painting
def paint():
    land, region, field = build_fields()
    elev = elevation()
    img = Image.new("RGBA", (W, H))
    arr = np.zeros((H, W, 4), dtype=np.uint8)
    dist = dist_to_land(land, 6)
    # sea: banded by distance with dither, deeper toward the edges
    edge = np.minimum(np.minimum(XX, W - 1 - XX) / 40.0, np.minimum(YY, H - 1 - YY) / 24.0).clip(0, 1)
    for y in range(H):
        for x in range(W):
            if land[y, x]:
                continue
            d = dist[y, x]
            b = BAYER[y % 4, x % 4]
            if d <= 2:
                c = SEA_SHALLOW
            elif d <= 5:
                c = SEA_SHALLOW if b < 0.28 else SEA_MID
            else:
                t = edge[y, x]
                c = SEA_MID if b < t * 0.9 else SEA_DEEP
            arr[y, x] = c
    # waves: little pairs of lighter pixels
    rnd = random.Random(5)
    for _ in range(330):
        x, y = rnd.randint(4, W - 8), rnd.randint(4, H - 6)
        if land[y, x] or dist[y, x] < 4:
            continue
        for dx in (0, 1, 2):
            if not land[y, x + dx]:
                arr[y, x + dx] = (0x5C, 0x78, 0xC4, 255) if dx != 1 else (0x7A, 0x98, 0xE0, 255)
        if y + 1 < H and not land[y + 1, x + 1]:
            arr[y + 1, x + 1] = (0x3E, 0x58, 0xA0, 255)
    # land: region base colours, elevation tones, dithered grain
    for y in range(H):
        for x in range(W):
            if not land[y, x]:
                continue
            rid = ORDER[region[y, x]]
            hi, mid, lo = [hexc(c) for c in REGIONS[rid][4]]
            e = elev[y, x]
            b = BAYER[y % 4, x % 4]
            shade = e + (b - 0.5) * 0.28
            # a lit northwest slope: compare with the pixel up-left
            e2 = elev[max(0, y - 1), max(0, x - 1)]
            if shade > 0.60 or e - e2 > 0.03:
                c = hi
            elif shade < 0.36 or e - e2 < -0.03:
                c = lo
            else:
                c = mid
            arr[y, x] = c
    # coast: dark outline on land edge, light foam ring in the sea next to it
    for y in range(H):
        for x in range(W):
            if land[y, x]:
                nb = [land[min(H - 1, y + 1), x], land[max(0, y - 1), x], land[y, min(W - 1, x + 1)], land[y, max(0, x - 1)]]
                if not all(nb):
                    arr[y, x] = OUTLINE
            elif dist[y, x] == 1 and BAYER[y % 4, x % 4] < 0.62:
                arr[y, x] = FOAM
            elif dist[y, x] == 2 and BAYER[y % 4, x % 4] < 0.18:
                arr[y, x] = (0xA8, 0xC0, 0xE8, 255)
    img = Image.fromarray(arr, "RGBA")
    return img, land, region, elev


def river(img, land, pts, width=2):
    col = hexc("5CA8E8")
    for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
        n = int(max(abs(x1 - x0), abs(y1 - y0))) * 2 + 1
        for i in range(n + 1):
            t = i / n
            x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t + math.sin(t * 9 + x0) * 1.5
            xi, yi = int(x), int(y)
            for dx in range(width):
                if 0 <= xi + dx < W and 0 <= yi < H and land[yi, xi + dx]:
                    img.putpixel((xi + dx, yi), col)
                    if (xi + dx + yi) % 4 == 0:
                        img.putpixel((xi + dx, yi), hexc("A8D4F8"))


def lake(img, land, cx, cy, rx, ry):
    for y in range(cy - ry - 1, cy + ry + 2):
        for x in range(cx - rx - 1, cx + rx + 2):
            d = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
            if d <= 1 and 0 <= x < W and 0 <= y < H and land[y, x]:
                img.putpixel((x, y), hexc("4E94D8") if d < 0.6 else hexc("2E6EB8"))
            elif d <= 1.35 and 0 <= x < W and 0 <= y < H and land[y, x]:
                img.putpixel((x, y), OUTLINE)


def road(img, land, pts, col=hexc("F2E6B8")):
    for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
        n = int(max(abs(x1 - x0), abs(y1 - y0)))
        for i in range(n + 1):
            if i % 4 in (0, 1):
                t = i / max(n, 1)
                x, y = int(x0 + (x1 - x0) * t), int(y0 + (y1 - y0) * t + math.sin(t * 6 + x0) * 2)
                if 0 <= x < W and 0 <= y < H and land[y, x]:
                    img.putpixel((x, y), col)


def scatter(img, land, region, rid, sprite, count, seed, keepout=(), minsep=9, ymax=None):
    rnd = random.Random(seed)
    placed = []
    tries = 0
    while len(placed) < count and tries < count * 80:
        tries += 1
        x, y = rnd.randint(8, W - 9), rnd.randint(10, (ymax or H) - 6)
        if not land[y, x] or ORDER[region[y, x]] != rid:
            continue
        if any(math.hypot(x - kx, y - ky) < kr for kx, ky, kr in keepout):
            continue
        if any(math.hypot(x - px_, y - py) < minsep for px_, py in placed):
            continue
        # keep it on land: the sprite foot row and both sides
        if not (land[y, max(0, x - 2)] and land[y, min(W - 1, x + 2)]):
            continue
        placed.append((x, y))
    placed.sort(key=lambda p: p[1])
    for x, y in placed:
        stamp(img, sprite, x, y)
    return placed


def compass(img, cx, cy):
    c = hexc("F2E6B8"); d = hexc("A99BC8"); k = OUTLINE
    for r in range(-9, 10):
        for (x, y) in ((cx + r, cy), (cx, cy + r)):
            img.putpixel((x, y), k if abs(r) > 6 else d)
    pts = [(0, -11, c), (11, 0, d), (0, 11, d), (-11, 0, d)]
    for ox, oy, col in pts:
        for t in range(0, 6):
            img.putpixel((cx + int(ox * (1 - t / 6)), cy + int(oy * (1 - t / 6))), col)
    for dx in (-1, 0, 1):
        for dy in (-1, 0, 1):
            img.putpixel((cx + dx, cy + dy), hexc("FFF4E6") if dx == dy == 0 else d)
    # N pip
    for dx, dy in ((0, -13), (-1, -12), (1, -12), (0, -12)):
        img.putpixel((cx + dx, cy + dy), c)


def border(img):
    """A two-line night frame with corner studs, in the UI dusk palette."""
    for x in range(W):
        for y in (0, 1, H - 2, H - 1):
            img.putpixel((x, y), OUTLINE if y in (0, H - 1) else hexc("5A4E80"))
    for y in range(H):
        for x in (0, 1, W - 2, W - 1):
            img.putpixel((x, y), OUTLINE if x in (0, W - 1) else hexc("5A4E80"))
    for x, y in ((3, 3), (W - 4, 3), (3, H - 4), (W - 4, H - 4)):
        for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)):
            img.putpixel((x + dx - 1, y + dy - 1), hexc("F2B27A"))


def fog(region, land, rid):
    """Dark dithered cover for a region the hero has not visited."""
    arr = np.zeros((H, W, 4), dtype=np.uint8)
    m = land & (region == ORDER.index(rid))
    # include the sea ring around it a little so the silhouette reads
    for y in range(H):
        for x in range(W):
            if m[y, x]:
                a = 205 if BAYER[y % 4, x % 4] < 0.8 else 150
                arr[y, x] = (14, 10, 36, a)
    return Image.fromarray(arr, "RGBA")


# ------------------------------------------------------------------------------------------------ icons
ICON_ORDER = ["you", "goal", "npc", "rest", "chest", "clue", "exit", "boss"]
IP = {"k": hexc("0C0A18"), "w": hexc("FFFFFF"), "W": hexc("D8D2E8"), "c": hexc("7FE8E0"), "C": hexc("3FB8C0"),
      "a": hexc("F2B27A"), "A": hexc("C98A52"), "y": hexc("FFE08A"), "g": hexc("6FE3B4"), "G": hexc("2E9A78"),
      "p": hexc("C9A0E8"), "P": hexc("8A5EB8"), "r": hexc("E0566A"), "R": hexc("8E2A3A"), "b": hexc("7A5030"),
      "s": hexc("7FD6E6")}


def icon(rows):
    return spr(rows, IP)


def icons():
    you = ["...kkk.....", "..kwwwk....", "..kwwwk....", "...kwk.....", "..kwwwk....", ".kwwwwwk...", ".kwkwkwk...", "..kkkkk....", "...........",
           "...........", "..........."]
    goal = ["....kk.....", "...kyyk....", "..kyyyyk...", ".kyyaayyk..", "kyyaaaayyk.", ".kyyaayyk..", "..kyyyyk...", "...kyyk....", "....kk.....",
            "...........", "..........."]
    npc = ["...kkk.....", "..kWWWk....", "..kWkWk....", "..kWWWk....", "...kkk.....", "..kWWWk....", ".kWWWWWk...", ".kWWkWWk...", "..kk.kk....",
           "...........", "..........."]
    rest = ["....k......", "...kgk.....", "..kgygk....", "..kgggk....", "...kGk.....", "..kkkkk....", ".kGGGGGk...", ".kGkGkGk...", "..kkkkk....",
            "...........", "..........."]
    chest = ["...........", "..kkkkkk...", ".kaaaaaak..", ".kAAyyAAk..", ".kaaaaaak..", ".kAAkkAAk..", ".kaaaaaak..", ".kAAAAAAk..", "..kkkkkk...",
             "...........", "..........."]
    clue = ["..kkkkk....", ".kpppppk...", ".kpwwwpk...", ".kpPPPpk...", ".kpwwwpk...", ".kpPPPpk...", ".kpppppk...", "..kkkkk....", "...........",
            "...........", "..........."]
    exit_ = ["....k......", "....ssk....", "kssssssk...", "ksssssssk..", "kssssssk...", "....ssk....", "....k......", "...........", "...........",
             "...........", "..........."]
    boss = [".kkkkkkk...", "kRrrrrrRk..", "kRwrrrwRk..", "kRrrkrrRk..", ".kRrrrRk...", "..kwkwk....", "..kkkkk....", "...........", "...........",
            "...........", "..........."]
    return [icon(r) for r in (you, goal, npc, rest, chest, clue, exit_, boss)]


# ------------------------------------------------------------------------------------------------ main
def main():
    img, land, region, elev = paint()
    ax = {r: REGIONS[r][5] for r in REGIONS}
    ko = [(212, 98, 14), (58, 96, 6)]
    # rivers and lakes first (under the stamps)
    river(img, land, [(78, 70), (98, 82), (118, 96), (140, 118), (160, 140), (172, 150)], 2)
    river(img, land, [(300, 70), (306, 90), (318, 112), (330, 138)], 2)
    river(img, land, [(380, 64), (384, 84), (392, 108)], 2)
    lake(img, land, 48, 110, 9, 5)          # Situ
    lake(img, land, 232, 138, 5, 3)
    # road: the route you actually walk, Purwa out to every region
    for pts in ([(212, 98), (170, 92), (140, 90)], [(212, 98), (120, 96), (80, 96)], [(212, 98), (214, 140)],
                [(212, 98), (222, 50)], [(140, 90), (210, 100), (282, 92)], [(282, 92), (330, 94), (372, 94)]):
        road(img, land, pts)
    # Tatar Sunda: volcano and peaks, tea hills, forest
    stamp(img, VOLCANO, 42, 62)
    scatter(img, land, region, "tatar_sunda", MOUNTAIN, 4, 11, [(42, 62, 14), (66, 96, 8), (48, 108, 12)], 14, ymax=90)
    scatter(img, land, region, "tatar_sunda", PINE, 16, 12, [(42, 62, 12), (66, 96, 8), (48, 108, 12)], 8)
    scatter(img, land, region, "tatar_sunda", TREE, 10, 13, [(66, 96, 8), (48, 108, 12)], 9)
    stamp(img, HUT, 70, 100); stamp(img, HUT, 76, 102); stamp(img, HUT, 84, 99)
    # Keraton Galuh: the palace, walled town, trees
    stamp(img, PALACE, 140, 92)
    for dx in (-9, 9):
        stamp(img, HUT, 140 + dx, 100)
    scatter(img, land, region, "keraton_galuh", TREE, 7, 21, [(140, 92, 14), (212, 98, 8)], 9)
    scatter(img, land, region, "keraton_galuh", HILL, 3, 22, [(140, 92, 14)], 14)
    # Desa Purwa: the village, the banyan
    stamp(img, BANYAN, 205, 104)
    for dx, dy in ((10, 0), (16, 3), (8, 6), (20, -2)):
        stamp(img, HUT, 212 + dx, 100 + dy)
    scatter(img, land, region, "desa_purwa", TREE, 4, 31, [(212, 100, 14)], 9)
    # Mataram: candi, rice fields
    stamp(img, CANDI, 292, 80)
    stamp(img, CANDI_B, 276, 84); stamp(img, CANDI_B, 306, 86); stamp(img, CANDI_B, 284, 94)
    scatter(img, land, region, "mataram", RICE, 4, 41, [(292, 80, 16)], 10)
    scatter(img, land, region, "mataram", TREE, 5, 42, [(292, 80, 16)], 10)
    # Tanah Timur: banyans, dry hills, a far temple
    stamp(img, CANDI, 384, 76)
    scatter(img, land, region, "tanah_timur", BANYAN, 3, 51, [(384, 76, 16)], 18)
    scatter(img, land, region, "tanah_timur", HILL, 7, 52, [(384, 76, 14)], 10)
    scatter(img, land, region, "tanah_timur", MOUNTAIN_S, 3, 53, [(384, 76, 14)], 18)
    # Segara Kidul: palms, a cave, the sea palace shape, boats and a serpent
    scatter(img, land, region, "segara_kidul", PALM, 8, 61, [(214, 152, 8)], 8)
    stamp(img, CAVE, 196, 160)
    stamp(img, PALACE, 232, 156)
    for x, y in ((172, 176), (262, 176), (150, 160)):
        stamp(img, SHIP, x, y)
    stamp(img, SERPENT, 190, 178)
    stamp(img, BOAT_S, 128, 170); stamp(img, BOAT_S, 310, 168)
    # Gua Kala: the crater and a cave mouth in ash-violet rock
    scatter(img, land, region, "gua_kala", MOUNTAIN, 4, 71, [(222, 34, 12)], 12)
    stamp(img, CRATER, 222, 36)
    stamp(img, CAVE, 238, 42)
    compass(img, 410, 28)
    border(img)
    out = os.path.join(px.ART, "ui")
    os.makedirs(out, exist_ok=True)
    img.save(os.path.join(out, "map_world.png"))
    for rid in ORDER:
        fog(region, land, rid).save(os.path.join(out, "map_fog_%s.png" % rid))
    ics = icons()
    sheet = Image.new("RGBA", (11 * len(ics), 11), (0, 0, 0, 0))
    for i, ic in enumerate(ics):
        sheet.alpha_composite(ic, (i * 11, 0))
    sheet.save(os.path.join(out, "map_icons.png"))
    # engine data
    lines = ["# Generated by tools/gen_map_art.py: region anchors on map_world.png (432x184). Do not hand-edit.",
             "class_name MapRegions", "", "const ICONS := %s" % ICON_ORDER, "const REGIONS := {"]
    for rid in ORDER:
        x, y = ax[rid]
        lines.append('\t"%s": {"pos": Vector2(%d, %d)},' % (rid, x, y))
    lines.append("}")
    open(os.path.join(ROOT, "ui/map_regions.gd"), "w").write("\n".join(lines) + "\n")
    px.preview([("world", img.resize((W, H))), ("icons", sheet)], os.path.join(HERE, "map_preview.png"), scale=2, bg=(30, 24, 60, 255))
    print("ok")


if __name__ == "__main__":
    main()
