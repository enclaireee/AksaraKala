#!/usr/bin/env python3
"""UI v3 "Senja" (dusk) art set (ui.md 0.1, 4.1, 5): one twilight look for every screen.

Writes the whole UI surface set under the file names the game already loads (so no layout moves), the title scene
(sky, far ruins, split gate, ground, floating aksara), the pixel logo and tools/ui_dusk_preview.png.
Run it LAST: the older generators (gen_ui.py, gen_ui_rpg.py, gen_menu_book.py, gen_title_book.py, gen_ui_ink.py) would
overwrite the dusk set.

    python3 tools/gen_ui_dusk.py
"""
import math
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "art" / "ui"
FONTS = ROOT / "assets" / "fonts"

T = (0, 0, 0, 0)


def rgb(h, a=255):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), a)


# ---------------------------------------------------------------- palette (ui.md 5)
EDGE = rgb("0A0814")
WELL = rgb("0C0A18", 245)
FILL = rgb("141026", 232)
PAGE = rgb("1A1530")
RAISED = rgb("241C40")
HAIR = rgb("3A2F5C")
HAIR_LO = rgb("2B2347")
HEAD = rgb("FFF4E6")
TEXT = rgb("ECE6F2")
LABEL = rgb("A99BC8")
DIM = rgb("8C83A6")
DIM_LO = rgb("5A4E80")
CYAN = rgb("7FE8E0")
CYAN_HI = rgb("D8FFFB")
CYAN_HALO = rgb("3FB8C0")
CYAN_DEEP = rgb("1F6E78")
AMBER = rgb("F2B27A")
AMBER_LO = rgb("C98A52")
AMBER_HI = rgb("FFE2BC")
ROSE = rgb("E0566A")
ROSE_LO = rgb("8E2F45")
GREEN = rgb("8FD9A0")
GREEN_LO = rgb("4E8A64")

SKY = [rgb(c) for c in ("1B1433", "221839", "2A1D47", "3A2456", "52305E", "6B3A5E", "8E4763",
                         "B5566A", "D27268", "E8946A", "F2B27A")]

BAYER4 = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]


def new(w, h, col=T):
    return Image.new("RGBA", (w, h), col)


def with_alpha(c, a):
    return (c[0], c[1], c[2], a)


def mix(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(4))


# ---------------------------------------------------------------- surfaces

def panel(w, h, hair=HAIR, fill=FILL, edge=EDGE):
    """Chamfered 1 px outline, fill, 1 px hairline inset (the one dusk surface)."""
    im = new(w, h)
    px = im.load()
    for y in range(h):
        for x in range(w):
            if (x in (0, w - 1)) and (y in (0, h - 1)):
                continue
            px[x, y] = edge if (x in (0, w - 1) or y in (0, h - 1)) else fill
    for x in range(2, w - 2):
        px[x, 1] = hair
        px[x, h - 2] = hair
    for y in range(2, h - 2):
        px[1, y] = hair
        px[w - 2, y] = hair
    return im


def well(w, h, hair=HAIR_LO):
    im = panel(w, h, hair, WELL)
    px = im.load()
    for x in range(2, w - 2):   # top inner shadow: reads as recessed
        px[x, 2] = (4, 3, 10, 255)
    return im


def glow_panel(w, h, fill=FILL):
    """Focused surface: cyan hairline with brighter corners of the hairline."""
    im = panel(w, h, CYAN_HALO, fill)
    px = im.load()
    for (x, y) in ((2, 1), (1, 2), (w - 3, 1), (w - 2, 2), (2, h - 2), (1, h - 3), (w - 3, h - 2), (w - 2, h - 3)):
        px[x, y] = CYAN
    return im


def keycap(w=10, h=10):
    im = new(w, h)
    px = im.load()
    face, lip = rgb("E4DEF0"), rgb("9E94BE")
    for y in range(h):
        for x in range(w):
            if (x in (0, w - 1)) and (y in (0, h - 1)):
                continue
            if x in (0, w - 1) or y in (0, h - 1):
                px[x, y] = EDGE
            elif y == h - 2:
                px[x, y] = lip
            else:
                px[x, y] = face
    return im


def diamond(size=5, col=CYAN, core=CYAN_HI):
    im = new(size, size)
    px = im.load()
    c = size // 2
    for y in range(size):
        for x in range(size):
            if abs(x - c) + abs(y - c) <= c:
                px[x, y] = col
    px[c, c] = core
    return im


def tri_down(col=CYAN):
    im = new(5, 4)
    px = im.load()
    for y, r in enumerate(["#####", ".###.", "..#..", "....."]):
        for x, c in enumerate(r):
            if c == "#":
                px[x, y] = col
    px[2, 3] = EDGE
    return im


def sprite(rows, pal):
    im = new(len(rows[0]), len(rows))
    px = im.load()
    for y, r in enumerate(rows):
        for x, c in enumerate(r):
            if c in pal:
                px[x, y] = pal[c]
    return im


def arrow():
    return sprite([
        "##.......",
        "#O##.....",
        "#hOO##...",
        "#hOOOO##.",
        "#hOOOOOO#",
        "#OOOOO##.",
        "#OOO##...",
        "#O##.....",
        "##.......",
    ], {"#": EDGE, "O": AMBER, "h": AMBER_HI})


def ilmu_icon():
    return sprite([
        "..####..",
        ".#hAAa#.",
        "#hhAAaa#",
        "#AAAAaa#",
        ".#AAaa#.",
        "..#Aa#..",
        "...##...",
        "........",
    ], {"#": EDGE, "A": AMBER, "a": AMBER_LO, "h": AMBER_HI})


def save_icon():
    # a small glowing glyph-leaf: the game is "written" to memory
    return sprite([
        "..####..",
        ".#cCCc#.",
        "#cC##Cc#",
        "#C#cc#C#",
        "#C#cc#C#",
        "#cC##Cc#",
        ".#cCCc#.",
        "..####..",
    ], {"#": EDGE, "C": CYAN, "c": CYAN_HALO})


def mote():
    return sprite([".c.", "cCc", ".c."], {"C": CYAN_HI, "c": with_alpha(CYAN, 150)})


def star(big=False):
    if big:
        return sprite(["..s..", "..S..", "sSWSs", "..S..", "..s.."],
                      {"W": rgb("FFFFFF"), "S": rgb("F4EEFF", 210), "s": rgb("D8CCF0", 90)})
    return sprite([".s.", "sWs", ".s."], {"W": rgb("FFFFFF"), "s": rgb("E6DCF8", 110)})


def mouse_cursor():
    rows = [
        "#...........",
        "##..........",
        "#W#.........",
        "#WW#........",
        "#WWW#.......",
        "#WWWW#......",
        "#WWWWW#.....",
        "#WWWcc##....",
        "#WW#cc#.....",
        "#W#.#cc#....",
        "##..#cc#....",
        ".....##.....",
    ]
    return sprite(rows, {"#": EDGE, "W": rgb("ECE6F2"), "c": CYAN})


def divider(w=64):
    im = new(w, 5)
    px = im.load()
    c = w // 2
    for x in range(4, w - 4):
        d = abs(x - c) / (c - 4)
        a = int(255 * (1 - d) ** 0.6)
        if a > 20:
            px[x, 2] = with_alpha(LABEL, a)
    for (dx, dy) in ((0, 0), (-1, 1), (1, 1), (0, 1), (-2, 2), (2, 2), (-1, 3), (1, 3), (0, 3), (0, 4)):
        pass
    d = diamond(5)
    im.alpha_composite(d, (c - 2, 0))
    return im


def hline(w, col, h=1):
    im = new(w, h)
    for x in range(w):
        for y in range(h):
            im.putpixel((x, y), col)
    return im


# ---------------------------------------------------------------- menu ("book") pieces, dusk star-chart

def speckle(im, seed, density=0.012, cols=(rgb("2E2650"), rgb("3A3164"))):
    rnd = random.Random(seed)
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            if px[x, y][3] == 255 and rnd.random() < density:
                px[x, y] = rnd.choice(cols)
    return im


def page(seed):
    im = new(48, 48, PAGE)
    speckle(im, seed, 0.008)
    return im


def cover():
    im = panel(24, 24, HAIR, rgb("100C20"))
    px = im.load()
    for (x, y) in ((3, 2), (2, 3), (20, 2), (21, 3), (3, 21), (2, 20), (20, 21), (21, 20)):
        px[x, y] = CYAN_HALO
    return im


def spine():
    im = new(32, 4)
    px = im.load()
    for y in range(4):
        for x in range(32):
            d = abs(x - 15.5)
            if d < 1:
                px[x, y] = EDGE
            elif d < 2:
                px[x, y] = HAIR_LO
            elif d < 9:
                px[x, y] = (6, 4, 14, int(110 * (1 - (d - 2) / 7)))
    return im


def corner():
    im = new(14, 14)
    px = im.load()
    for i in range(2, 9):
        px[i, 2] = HAIR
        px[2, i] = HAIR
    px[2, 2] = CYAN
    px[3, 3] = CYAN_HALO
    px[9, 2] = DIM_LO
    px[2, 9] = DIM_LO
    return im


def footer():
    im = new(16, 12, rgb("0E0B1C"))
    px = im.load()
    for x in range(16):
        px[x, 0] = HAIR
        px[x, 11] = EDGE
    return im


def ribbon(state):
    """Tab pill, 16x20 (9-patch 5/5/5/3): the open tab is taller with a cyan rim."""
    w, h = 16, 20
    fill = {"on": RAISED, "off": rgb("120E24"), "hover": rgb("1C1636")}[state]
    hair = {"on": CYAN_HALO, "off": HAIR_LO, "hover": HAIR}[state]
    im = new(w, h)
    px = im.load()
    for y in range(h):
        for x in range(w):
            if y == 0 and x in (0, 1, w - 2, w - 1):
                continue
            if y == 1 and x in (0, w - 1):
                continue
            edge = x in (0, w - 1) or y == 0 or (y == 1 and x in (1, w - 2))
            px[x, y] = EDGE if edge else fill
    for x in range(2, w - 2):
        px[x, 1] = hair
    for y in range(2, h):
        px[1, y] = hair
        px[w - 2, y] = hair
    if state == "on":
        for x in range(3, w - 3):
            px[x, 2] = with_alpha(CYAN, 60)
    return im


def row_hi():
    im = new(12, 12, with_alpha(CYAN, 26))
    px = im.load()
    for y in range(12):
        px[0, y] = with_alpha(CYAN, 150)
    return im


def row_sel():
    return new(12, 12, with_alpha(LABEL, 22))


def rule():
    im = new(32, 3)
    px = im.load()
    for x in range(32):
        px[x, 1] = HAIR
    for x in range(0, 6):
        px[x, 1] = CYAN_HALO
    px[0, 0] = px[0, 2] = with_alpha(CYAN_HALO, 120)
    return im


def btn(hi):
    return glow_panel(12, 12, RAISED) if hi else panel(12, 12, HAIR, RAISED)


def card():
    return panel(16, 16, HAIR_LO, rgb("120E24"))


def slot(sel):
    if sel:
        im = glow_panel(24, 24, rgb("0F0C1E"))
    else:
        im = well(24, 24)
    return im


def bar_frame():
    im = new(8, 8)
    px = im.load()
    for y in range(8):
        for x in range(8):
            if (x in (0, 7)) and (y in (0, 7)):
                continue
            px[x, y] = EDGE if x in (0, 7) or y in (0, 7) else rgb("0E0B1C")
    return im


def bar_fill():
    im = new(4, 6, AMBER)
    for x in range(4):
        im.putpixel((x, 0), AMBER_HI)
        im.putpixel((x, 5), AMBER_LO)
    return im


def pip(kind):
    col = {"on": CYAN, "off": None, "gear": AMBER}[kind]
    im = new(3, 5)
    px = im.load()
    for y in range(5):
        for x in range(3):
            if col:
                px[x, y] = col
            elif x in (0, 2) or y in (0, 4):
                px[x, y] = HAIR
    if col:
        px[1, 1] = CYAN_HI if kind == "on" else AMBER_HI
    return im


def plus(state):
    hair = {"n": CYAN_HALO, "hi": CYAN, "off": HAIR_LO}[state]
    fill = {"n": RAISED, "hi": rgb("2C3D5A"), "off": rgb("120E24")}[state]
    mark = {"n": CYAN, "hi": CYAN_HI, "off": DIM_LO}[state]
    im = panel(11, 11, hair, fill)
    px = im.load()
    for i in range(3, 8):
        px[i, 5] = mark
        px[5, i] = mark
    return im


def ring(size, ring_col, fill, inner=None):
    im = new(size, size)
    px = im.load()
    c = (size - 1) / 2
    r = size / 2
    for y in range(size):
        for x in range(size):
            d = math.hypot(x - c, y - c)
            if d <= r - 0.5:
                px[x, y] = EDGE
            if d <= r - 1.5:
                px[x, y] = ring_col
            if d <= r - 2.5:
                px[x, y] = fill
            if inner and r - 4.5 < d <= r - 3.5:
                px[x, y] = inner
    return im


def seal_level():
    return ring(28, AMBER, RAISED, with_alpha(AMBER_LO, 160))


def seal_points():
    return ring(16, CYAN, RAISED)


def quest_seal(kind):
    if kind == "main":
        return sprite(["....#....", "...#A#...", "..#AhA#..", ".#AAhAA#.", "#AAAAAAa#", ".#AAAAa#.",
                       "..#Aaa#..", "...#a#...", "....#...."], {"#": EDGE, "A": AMBER, "a": AMBER_LO, "h": AMBER_HI})
    if kind == "side":
        return sprite(["....#....", "...#L#...", "..#L.L#..", ".#L...L#.", "#L.....L#", ".#L...L#.",
                       "..#L.L#..", "...#L#...", "....#...."], {"#": EDGE, "L": LABEL})
    return sprite([".#######.", "#GGGGGGG#", "#GGGGGgG#", "#GGGGgGG#", "#GgGgGGG#", "#GGgGGGG#",
                   "#GGGGGGG#", "#GGGGGGG#", ".#######."], {"#": EDGE, "G": GREEN_LO, "g": rgb("E8FFEE")})


def new_dot():
    return sprite([".cc...", "cCCc..", "cCCc..", ".cc...", "......", "......"], {"C": CYAN_HI, "c": CYAN})


def equipped():
    return sprite([".#####.", "#CCCCC#", "#CCCCc#", "#CcCcc#", "#CCcCC#", "#CCCCC#", ".#####."],
                  {"#": EDGE, "C": CYAN_DEEP, "c": CYAN_HI})


def updown(up):
    rows = ["..#..", ".###.", "#####", "..#..", "..#.."]
    if not up:
        rows = rows[::-1]
    return sprite(rows, {"#": GREEN if up else ROSE})


def track():
    return sprite(["CCCCC", "CCCCC", "CChCC", "CCCCC", "CCCCC", "CC.CC", "C...C", "....."],
                  {"C": CYAN, "h": CYAN_HI})


def bullet(kind):
    if kind == "now":
        return sprite(["...#...", "..#C#..", ".#ChC#.", "#CCCCC#", ".#CCC#.", "..#C#..", "...#..."],
                      {"#": CYAN_DEEP, "C": CYAN, "h": CYAN_HI})
    if kind == "open":
        return sprite(["...L...", "..L.L..", ".L...L.", "L.....L", ".L...L.", "..L.L..", "...L..."], {"L": DIM})
    return sprite([".......", "......G", ".....GG", "G...GG.", "GG.GG..", ".GGG...", "..G...."], {"G": GREEN})


def disc():
    w, h = 88, 16
    im = new(w, h)
    px = im.load()
    cx, cy = (w - 1) / 2, (h - 1) / 2
    for y in range(h):
        for x in range(w):
            d = ((x - cx) / (w / 2)) ** 2 + ((y - cy) / (h / 2)) ** 2
            if d <= 1.0:
                t = d
                if t > 0.82:
                    col = with_alpha(CYAN_HALO, 140) if y < cy else with_alpha(EDGE, 200)
                else:
                    col = with_alpha(rgb("1E1838"), 230) if (x + y) % 2 or t < 0.5 else with_alpha(rgb("181330"), 230)
                px[x, y] = col
    return im


def glyph_tile():
    im = well(20, 20, HAIR)
    px = im.load()
    for (x, y) in ((2, 2), (17, 2), (2, 17), (17, 17)):
        px[x, y] = CYAN_HALO
    return im


def track_bar(h):
    return new(5, h, with_alpha(HAIR, 255))


# ---------------------------------------------------------------- recolour of paper-era icons

INK_MAP = {
    (42, 28, 18): rgb("D8D0EA"),    # ink -> pale lavender (line art on night pages)
    (90, 68, 48): rgb("8C83A6"),    # brown ink -> dim
    (107, 90, 68): rgb("A99BC8"),
    (138, 118, 86): rgb("8C83A6"),
    (14, 11, 10): EDGE,
    (20, 14, 10): EDGE,
    (241, 228, 190): rgb("ECE6F2"),  # paper highlights -> cool cream
    (227, 208, 160): rgb("D2CAE4"),
    (200, 160, 96): AMBER,          # old gold -> amber
    (224, 179, 90): AMBER,
    (158, 43, 37): CYAN,            # old wax accents -> cyan (markers and chrome only)
    (94, 24, 20): CYAN_DEEP,
    (201, 71, 59): CYAN_HI,
}

KEEP_RED = {"book_ic_hp", "book_ic_vit", "book_ic_atk", "book_ic_str", "book_ic_jamu", "book_ic_sak"}


def recolour(name):
    path = OUT / (name + ".png")
    if not path.exists():
        return None
    im = Image.open(path).convert("RGBA")
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            key = (r, g, b)
            if name in KEEP_RED and key in ((158, 43, 37), (94, 24, 20), (201, 71, 59)):
                continue
            if key in INK_MAP:
                c = INK_MAP[key]
                px[x, y] = (c[0], c[1], c[2], a)
    return im


def doll():
    im = Image.open(OUT / "book_doll.png").convert("RGBA")
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            px[x, y] = with_alpha(LABEL, 46) if a < 60 else with_alpha(DIM_LO, 220)
    return im


# ---------------------------------------------------------------- full-screen art

def bayer(x, y):
    return (BAYER4[y % 4][x % 4] + 0.5) / 16.0


def sky(w=480, h=270, horizon=206, seed=11):
    """Banded twilight: hard colour steps with a 4 px ordered-dither seam between each pair."""
    im = new(w, h)
    px = im.load()
    n = len(SKY) - 1
    for y in range(h):
        t = min(1.0, max(0.0, y / horizon)) ** 1.35 * n
        i = int(t)
        f = t - i
        for x in range(w):
            if i >= n:
                px[x, y] = SKY[n]
                continue
            # most of a band is flat; the last 30 % dithers into the next colour
            g = max(0.0, (f - 0.7) / 0.3)
            px[x, y] = SKY[i + 1] if g > bayer(x, y) else SKY[i]
    rnd = random.Random(seed)
    for _ in range(150):   # dim fixed stars (the bright twinkling ones are sprites in the game)
        x, y = rnd.randrange(w), int(rnd.random() ** 1.7 * horizon * 0.62)
        base = px[x, y]
        px[x, y] = mix(base, rgb("F4EEFF"), rnd.choice((0.35, 0.5, 0.75)))
    return im


def silhouette_profile(w, seed, base, amp, roughness):
    rnd = random.Random(seed)
    pts = []
    y = base
    for x in range(w):
        y += rnd.uniform(-roughness, roughness)
        pts.append(y)
    # smooth
    out = []
    for x in range(w):
        a = pts[max(0, x - 3):x + 4]
        out.append(sum(a) / len(a))
    return out


def candi_shape(px, cx, base_y, s, col, cap, w, h):
    """A small stepped temple silhouette; every tier's top row catches the light."""
    tiers = [(7, 4), (6, 4), (5, 3), (4, 3), (3, 3), (2, 2), (1, 3)]
    y = base_y
    for half, th in tiers:
        hw = int(half * s)
        t = max(1, int(th * s))
        for yy in range(y - t, y):
            for xx in range(cx - hw, cx + hw + 1):
                if 0 <= xx < w and 0 <= yy < h:
                    px[xx, yy] = col
        for xx in range(cx - hw, cx + hw + 1):
            if 0 <= xx < w and 0 <= y - t < h:
                px[xx, y - t] = cap
        y -= t
    for k in (1, 2):
        px[cx, y - k] = cap


def far(w=480, h=270):
    """Layered ridges receding into the peach haze, a far candi on the middle hill (ui.md 4.1). Each layer is a
    flat colour with an ordered-dither mist band at its foot, never a smooth blend."""
    im = new(w, h)
    px = im.load()
    layers = [
        # top line function, fill, lit crest, mist colour
        (lambda x: 160 + 10 * math.sin(x / 61.0 + 0.6) + 5 * math.sin(x / 23.0) - 16 * math.exp(-((x - 270) / 30.0) ** 2),
         rgb("A85A6C"), rgb("C77474"), rgb("D27268")),
        (lambda x: 178 + 10 * math.sin(x / 47.0 + 2.0) + 5 * math.sin(x / 17.0 + 1.0),
         rgb("82425F"), rgb("9E5268"), rgb("B5566A")),
        (lambda x: 202 + 9 * math.sin(x / 39.0 + 4.0) + 4 * math.sin(x / 11.0),
         rgb("4E2C52"), rgb("6B3A5E"), rgb("8E4763")),
        (lambda x: 232 + 7 * math.sin(x / 29.0 + 1.3) + 3 * math.sin(x / 9.0 + 2.0),
         rgb("2A1D3E"), rgb("3E2850"), rgb("52305E")),
    ]
    tops = []
    for i, (f, fill, crest, mist) in enumerate(layers):
        top = [int(round(f(x))) for x in range(w)]
        tops.append(top)
        for x in range(w):
            for y in range(max(0, top[x]), h):
                px[x, y] = fill
            if 0 <= top[x] < h:
                px[x, top[x]] = crest
        if i == 0:   # the far candi sits on the high hill of the back ridge
            peak = min(range(240, 360), key=lambda x: top[x])
            candi_shape(px, peak, top[peak] + 2, 1.3, rgb("8E4E66"), rgb("D88A80"), w, h)
        # mist at the foot of this layer, under where the next layer starts
        if i + 1 < len(layers):
            nxt = [int(round(layers[i + 1][0](x))) for x in range(w)]
            for x in range(w):
                for y in range(nxt[x] - 8, nxt[x]):
                    if 0 <= y < h and px[x, y][3]:
                        t = (y - (nxt[x] - 8)) / 8.0
                        if t * 0.9 > bayer(x, y):
                            px[x, y] = mist
    return im


def constellation(seed=4):
    """An aksara written in stars (Sundanese Ka): the glyph is thinned to a 1 px skeleton, drawn as a faint dotted
    line, with stars on its ends, joints and along the strokes."""
    f = ImageFont.truetype(str(FONTS / "NotoSansSundanese.ttf"), 76)
    tmp = Image.new("L", (160, 140), 0)
    ImageDraw.Draw(tmp).text((20, 10), "\u1B8A", font=f, fill=255)
    tmp = tmp.crop(tmp.getbbox())
    w, h = tmp.width + 8, tmp.height + 8
    g = [[1 if (0 <= x - 4 < tmp.width and 0 <= y - 4 < tmp.height and tmp.getpixel((x - 4, y - 4)) > 120) else 0
          for x in range(w)] for y in range(h)]
    # Zhang-Suen thinning
    changed = True
    while changed:
        changed = False
        for step in (0, 1):
            kill = []
            for y in range(1, h - 1):
                for x in range(1, w - 1):
                    if not g[y][x]:
                        continue
                    n = [g[y-1][x], g[y-1][x+1], g[y][x+1], g[y+1][x+1], g[y+1][x], g[y+1][x-1], g[y][x-1], g[y-1][x-1]]
                    b = sum(n)
                    a = sum(1 for i in range(8) if n[i] == 0 and n[(i + 1) % 8] == 1)
                    if not (2 <= b <= 6 and a == 1):
                        continue
                    if step == 0 and n[0] * n[2] * n[4] == 0 and n[2] * n[4] * n[6] == 0:
                        kill.append((x, y))
                    if step == 1 and n[0] * n[2] * n[6] == 0 and n[0] * n[4] * n[6] == 0:
                        kill.append((x, y))
            for x, y in kill:
                g[y][x] = 0
            changed = changed or bool(kill)
    im = new(w, h)
    p = im.load()
    pts = [(x, y) for y in range(h) for x in range(w) if g[y][x]]
    for i, (x, y) in enumerate(pts):
        if (x + y) % 2 == 0:
            p[x, y] = with_alpha(LABEL, 110)
    # stars: endpoints and junctions, then a sparse sample along the strokes
    def nb(x, y):
        return sum(g[y + dy][x + dx] for dx in (-1, 0, 1) for dy in (-1, 0, 1) if (dx or dy))
    keys = [(x, y) for (x, y) in pts if nb(x, y) != 2]
    stars = []
    for q in keys + pts:
        if all((q[0] - s_[0]) ** 2 + (q[1] - s_[1]) ** 2 > 49 for s_ in stars):
            stars.append(q)
    rnd = random.Random(seed)
    for i, (x, y) in enumerate(stars):
        col = CYAN_HI if i % 4 == 0 else rgb("F4EEFF")
        p[x, y] = col
        if i % 3 == 0:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                p[x + dx, y + dy] = with_alpha(CYAN if col == CYAN_HI else LABEL, 140)
    return im


def shade_mask(mask, base, lit, dark, outline, lit_dir=(1, -1), noise=None, seed=0):
    """Colours a 1-bit mask: outline on the silhouette edge, `lit` on edges facing lit_dir, `dark` on the opposite
    edges, `base` inside with an optional sparse dither of `noise`. Returns an RGBA image."""
    rnd = random.Random(seed)
    w, h = mask.size
    m = mask.load()
    im = new(w, h)
    px = im.load()

    def inside(x, y):
        return 0 <= x < w and 0 <= y < h and m[x, y]
    lx, ly = lit_dir
    for y in range(h):
        for x in range(w):
            if not m[x, y]:
                continue
            if not (inside(x + 1, y) and inside(x - 1, y) and inside(x, y + 1) and inside(x, y - 1)):
                px[x, y] = outline
            elif not inside(x + lx, y + ly) or not inside(x + 2 * lx, y + 2 * ly):
                px[x, y] = lit
            elif not inside(x - 2 * lx, y - 2 * ly):
                px[x, y] = dark
            else:
                px[x, y] = base
                if noise and rnd.random() < 0.08:
                    px[x, y] = noise
    return im


def near(w=480, h=270, seed=5):
    """The foreground outcrop on the right: dark stone lit along its crest by the horizon, grass on top, a palm and a
    small tree. The Wiku stands on the flat at x 352-420, feet at y 214."""
    im = new(w, h)
    m = Image.new("1", (w, h), 0)
    md = ImageDraw.Draw(m)
    top = 214
    poly = [(296, h), (304, 252), (314, 240), (322, 236), (330, 224), (342, top + 1), (352, top), (420, top),
            (432, top - 3), (446, top - 6), (462, top - 8), (480, top - 9), (480, h)]
    md.polygon(poly, fill=1)
    rock = shade_mask(m, rgb("231A33"), rgb("6B4A66"), rgb("170F22"), rgb("120C1C"), lit_dir=(-1, -1),
                      noise=rgb("2A2040"), seed=seed)
    rp = rock.load()
    rnd = random.Random(seed)
    for x in range(w):   # warm rim and grass along the crest
        for y in range(h):
            if rp[x, y][3]:
                rp[x, y] = rgb("D27268") if x < 352 else rgb("8E8A58")
                if y + 1 < h:
                    rp[x, y + 1] = rgb("6B4A66") if x < 352 else rgb("4C5A40")
                break
    for _ in range(70):   # tufts on the crest
        x = rnd.randrange(340, 480)
        for y in range(h):
            if rp[x, y][3]:
                for k in range(1, rnd.choice((2, 3, 3, 4)) + 1):
                    if y - k >= 0:
                        rp[x, y - k] = rnd.choice((rgb("4C5A40"), rgb("5E6B46"), rgb("3E4A3A")))
                break
    for _ in range(40):   # strata cracks in the face
        x, y = rnd.randrange(300, 480), rnd.randrange(top + 6, h)
        if rp[x, y][3] and rp[x, y] not in (rgb("120C1C"),):
            for k in range(rnd.randint(3, 8)):
                if x + k < w and rp[x + k, y][3]:
                    rp[x + k, y] = rgb("170F22")
    im.alpha_composite(rock)
    d = ImageDraw.Draw(im)

    def palm(x, y, s, seed_):
        trunk, frond, frond_lo = rgb("1C1528"), rgb("1E182C"), rgb("181224")
        n = int(70 * s)
        for i in range(n):
            xx = x - int(math.sin(i / 30.0) * 7 * s)
            for q in range(3 if i < n * 0.6 else 2):
                d.point([xx + q, y - i], fill=trunk)
        tx, ty = x - int(math.sin(n / 30.0) * 7 * s), y - n
        r_ = random.Random(seed_)
        for ang in (-170, -142, -116, -88, -60, -32, -6, 22):
            a = math.radians(ang + r_.uniform(-6, 6))
            L = r_.uniform(20, 27) * s
            for k in range(int(L)):
                t = k / L
                fx = tx + 1 + math.cos(a) * k
                fy = ty + math.sin(a) * k + (t ** 2) * 14 * s
                for q in range(2 if t < 0.7 else 1):
                    d.point([int(fx), int(fy) + q], fill=frond)
                if k % 2 == 0 and 0.2 < t < 0.95:
                    for q in range(1, int(4 * (1 - t)) + 2):
                        d.point([int(fx) + (1 if math.cos(a) > 0 else -1) * (q // 3), int(fy) + 1 + q], fill=frond_lo)

    palm(452, top - 6, 1.05, 2)
    palm(470, top - 8, 0.8, 5)
    # a low shrub at the cliff's left shoulder
    for (cx, cy, r) in ((334, 222, 6), (340, 218, 5), (328, 226, 4)):
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=rgb("1E2A2A"))
        d.arc([cx - r, cy - r, cx + r, cy + r], 200, 290, fill=rgb("8E4763"))
    # foreground grass on the left, darkest, so the menu column has quiet ground under it
    for x in range(0, 300):
        gy = 258 + int(3 * math.sin(x / 13.0) + 2 * math.sin(x / 5.0 + 1))
        for y in range(gy, h):
            im.putpixel((x, y), rgb("140E22"))
        if rnd.random() < 0.35:
            for k in range(1, rnd.randint(2, 6)):
                im.putpixel((x, gy - k), rgb("140E22"))
    return im


def vignette(w=480, h=270):
    im = new(w, h)
    px = im.load()
    for y in range(h):
        for x in range(w):
            dx, dy = (x - w / 2) / (w / 2), (y - h / 2) / (h / 2)
            d = math.sqrt(dx * dx * 0.8 + dy * dy)
            a = max(0.0, (d - 0.7) / 0.6)
            a = min(1.0, a) ** 1.6
            if a > 0.01:
                px[x, y] = (10, 8, 20, int(215 * a))
    return im


def glow(size=64, col=CYAN):
    """Soft banded radial glow (4 alpha steps, no smooth gradient)."""
    im = new(size, size)
    px = im.load()
    c = (size - 1) / 2
    for y in range(size):
        for x in range(size):
            d = math.hypot(x - c, y - c) / (size / 2)
            if d < 1:
                a = 1 - d
                step = math.floor(a * 4 + bayer(x, y) * 0.999) / 4
                if step > 0:
                    px[x, y] = with_alpha(col, int(110 * step ** 1.5))
    return im


def pedestal():
    """Class-select plinth: a low stepped candi base in dusk stone with a cyan inlay."""
    im = new(64, 20)
    d = ImageDraw.Draw(im)
    d.rectangle([2, 8, 61, 19], fill=rgb("2E2640"))
    d.rectangle([6, 2, 57, 9], fill=rgb("3E3352"))
    d.line([6, 2, 57, 2], fill=rgb("8C83A6"))
    d.line([2, 8, 61, 8], fill=rgb("5A4E80"))
    d.line([2, 19, 61, 19], fill=EDGE)
    for x in range(10, 54, 6):
        d.point([x, 13], fill=CYAN_HALO)
    d.point([31, 5], fill=CYAN)
    d.point([32, 5], fill=CYAN)
    return im


def light_cone():
    """Soft cool light from above onto the class figure (replaces the warm lamp cone)."""
    w, h = 96, 160
    im = new(w, h)
    px = im.load()
    for y in range(h):
        half = 10 + y * 0.28
        for x in range(w):
            dx = abs(x - w / 2) / half
            if dx < 1:
                a = (1 - dx) * (0.25 + 0.75 * y / h)
                step = math.floor(a * 4 + bayer(x, y) * 0.999) / 4
                if step > 0:
                    px[x, y] = (200, 240, 255, int(26 * step))
    return im


# ---------------------------------------------------------------- floating aksara

GLYPHS = {
    "ka": ("NotoSansSundanese.ttf", "ᮊ"),
    "ja": ("NotoSansJavanese.ttf", "ꦏ"),   # Javanese ka
    "la": ("NotoSansSundanese.ttf", "ᮜ"),
    "ra": ("NotoSansJavanese.ttf", "ꦫ"),
}


def glyph_sprite(key, size=24):
    font_file, ch = GLYPHS[key]
    f = ImageFont.truetype(str(FONTS / font_file), size)
    tmp = Image.new("L", (64, 64), 0)
    ImageDraw.Draw(tmp).text((10, 6), ch, font=f, fill=255)
    box = tmp.point(lambda v: 255 if v > 120 else 0).getbbox()
    mask = tmp.crop(box).point(lambda v: 255 if v > 120 else 0)
    pad = 3
    w, h = mask.width + pad * 2, mask.height + pad * 2
    im = new(w, h)
    m = mask.load()
    px = im.load()
    solid = set()
    for y in range(mask.height):
        for x in range(mask.width):
            if m[x, y]:
                solid.add((x + pad, y + pad))
    def near(p, r):
        return any((p[0] + dx, p[1] + dy) in solid for dx in range(-r, r + 1) for dy in range(-r, r + 1)
                   if abs(dx) + abs(dy) <= r)
    for y in range(h):
        for x in range(w):
            if (x, y) in solid:
                continue
            if near((x, y), 1):
                px[x, y] = with_alpha(CYAN_HALO, 170)
            elif near((x, y), 2):
                px[x, y] = with_alpha(CYAN_HALO, 60)
            elif near((x, y), 3):
                px[x, y] = with_alpha(CYAN_HALO, 18)
    for (x, y) in solid:
        # pale core where the stroke is thick, cyan at its edge
        inner = all((x + dx, y + dy) in solid for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
        px[x, y] = CYAN_HI if inner else CYAN
    return im


# ---------------------------------------------------------------- logo

# 5-wide pixel letters; caps 7 rows, lowercase x-height rows 2..6 (same baseline)
LETTERS = {
    "A": [".###.", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"],
    "K": ["#...#", "#..#.", "#.#..", "##...", "#.#..", "#..#.", "#...#"],
    "k": ["#....", "#....", "#..#.", "#.#..", "##...", "#.#..", "#..#."],
    "s": [".....", ".....", ".###.", "#....", ".##..", "...#.", "###.."],
    "a": [".....", ".....", ".###.", "....#", ".####", "#...#", ".####"],
    "r": [".....", ".....", "#.##.", "##..#", "#....", "#....", "#...."],
    "l": ["##", ".#", ".#", ".#", ".#", ".#", ".#"],
}
# aksara-style marks: (letter index, kind) per word. "bar" sits on the cap line over an x-height letter,
# "dot" sits two cells under the baseline, "tick" is a short stroke over a tall letter.
MARKS = {
    "Aksara": [(2, "bar"), (5, "bar"), (1, "dot"), (4, "dot")],
    "Kala": [(1, "bar"), (2, "tick"), (2, "dot"), (3, "dot")],
}


def word_mask(word, cell):
    cols = []
    xs = []
    x = 0
    for ch in word:
        g = LETTERS[ch]
        gw = max(len(r.rstrip(".")) for r in g)
        gw = max(gw, 2)
        xs.append((x, gw))
        x += gw + 1
    w_cells = x - 1
    h_cells = 7 + 4   # 1 cell above for ticks, 3 under for dots
    im = Image.new("L", (w_cells * cell, h_cells * cell), 0)
    d = ImageDraw.Draw(im)
    oy = 1
    for (ch, (x0, gw)) in zip(word, xs):
        for ry, r in enumerate(LETTERS[ch]):
            for rx, c in enumerate(r[:gw]):
                if c == "#":
                    d.rectangle([(x0 + rx) * cell, (oy + ry) * cell, (x0 + rx + 1) * cell - 1, (oy + ry + 1) * cell - 1], fill=255)
    for idx, kind in MARKS.get(word, []):
        x0, gw = xs[idx]
        if kind == "bar":
            d.rectangle([x0 * cell, (oy + 0) * cell, (x0 + gw) * cell - 1, (oy + 0) * cell + cell - 2], fill=255)
        elif kind == "tick":
            d.rectangle([(x0 + gw) * cell + 1, (oy - 1) * cell, (x0 + gw) * cell + cell - 2, (oy + 1) * cell - 2], fill=255)
        elif kind == "dot":
            cx = x0 * cell + (gw * cell) // 2
            d.rectangle([cx - cell // 2, (oy + 8) * cell, cx + cell // 2 - 1, (oy + 8) * cell + cell - 1], fill=255)
    return im


def distress(mask, seed):
    """Chip the edges and punch a few specks: the poster's worn-stamp look, kept sparse so it reads clean."""
    rnd = random.Random(seed)
    px = mask.load()
    w, h = mask.size
    edges = []
    for y in range(h):
        for x in range(w):
            if px[x, y] and any(not (0 <= x + dx < w and 0 <= y + dy < h) or not px[x + dx, y + dy]
                                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                edges.append((x, y))
    for (x, y) in edges:
        if rnd.random() < 0.07:
            px[x, y] = 0
            if rnd.random() < 0.3 and x + 1 < w:
                px[x + 1, y] = 0
    for _ in range(int(len(edges) * 0.02)):   # pinholes inside strokes
        x, y = rnd.randrange(w), rnd.randrange(h)
        if px[x, y] and all(0 <= x + dx < w and 0 <= y + dy < h and px[x + dx, y + dy] for dx in (-1, 0, 1) for dy in (-1, 0, 1)):
            px[x, y] = 0
    return mask


def logo(cell=4, seed=21):
    a = word_mask("Aksara", cell)
    k = word_mask("Kala", cell)
    gap = -cell   # Kala's tick row tucks into the empty row under Aksara's dots
    pad = 6
    w = max(a.width, k.width) + pad * 2
    h = a.height + k.height + gap + pad * 2
    mask = Image.new("L", (w, h), 0)
    mask.paste(a, ((w - a.width) // 2, pad))
    mask.paste(k, ((w - k.width) // 2, pad + a.height + gap))
    from PIL import ImageFilter
    mask = mask.filter(ImageFilter.MaxFilter(3))   # bolder: every stroke grows 1 px each side
    bb = mask.getbbox()   # trim to the ink, then a 3 px margin for the shadow and flecks
    mask = mask.crop((bb[0] - 3, bb[1] - 3, bb[2] + 3, bb[3] + 3))
    w, h = mask.size
    mask = distress(mask, seed)
    m = mask.load()
    im = new(w, h)
    px = im.load()
    face, face_lo = rgb("EEE8DC"), rgb("CFC6CC")
    shadow = rgb("140C24", 200)
    for y in range(h):
        for x in range(w):
            if m[x, y]:
                continue
            if x - 2 >= 0 and y - 2 >= 0 and m[x - 2, y - 2]:
                px[x, y] = shadow
            elif x - 1 >= 0 and y - 1 >= 0 and m[x - 1, y - 1]:
                px[x, y] = shadow
    for y in range(h):
        for x in range(w):
            if m[x, y]:
                # bottom cell-row of each stroke a touch darker: a little weight, no gradient
                below = y + 1 < h and m[x, y + 1]
                px[x, y] = face if below or (y % cell) < cell - 1 else face_lo
    rnd = random.Random(seed + 1)
    for _ in range(18):   # loose flecks around the letters, as on the poster
        x, y = rnd.randrange(w), rnd.randrange(h)
        if not m[x, y] and px[x, y][3] == 0:
            near_ = any(0 <= x + dx < w and 0 <= y + dy < h and m[x + dx, y + dy] for dx in range(-4, 5) for dy in range(-4, 5))
            if near_:
                px[x, y] = rgb("EEE8DC", 200)
    return im


# ---------------------------------------------------------------- app icon

def app_icon_pixels(n=32):
    """32x32 pixel icon: banded dusk sky, stars, a ridge on the horizon and Javanese Ka glowing cyan."""
    im = new(n, n)
    px = im.load()
    bands = [SKY[0], SKY[2], SKY[3], SKY[4], SKY[5], SKY[6], SKY[7], SKY[8], SKY[9], SKY[10]]
    for y in range(n):
        t = min(1.0, y / 26.0) ** 1.2 * (len(bands) - 1)
        i = int(t)
        f = t - i
        for x in range(n):
            px[x, y] = bands[min(i + 1, len(bands) - 1)] if (f > 0.6 and (f - 0.6) / 0.4 > bayer(x, y)) else bands[i]
    for (x, y, c) in ((4, 4, rgb("F4EEFF")), (26, 3, rgb("FFFFFF")), (28, 10, rgb("D8CCF0")), (3, 13, rgb("D8CCF0"))):
        px[x, y] = c
    for x in range(n):   # two ridges at the horizon
        r1 = 25 + int(round(1.2 * math.sin(x / 4.0 + 1)))
        r2 = 28 + int(round(math.sin(x / 3.0 + 3)))
        for y in range(r1, n):
            px[x, y] = rgb("52305E")
        for y in range(r2, n):
            px[x, y] = rgb("2A1D3E")
    f = ImageFont.truetype(str(FONTS / "NotoSansJavanese.ttf"), 21)
    tmp = Image.new("L", (80, 80), 0)
    ImageDraw.Draw(tmp).text((10, 4), "\uA98F", font=f, fill=255)
    tmp = tmp.point(lambda v: 255 if v > 110 else 0)
    tmp = tmp.crop(tmp.getbbox())
    ox, oy = (n - tmp.width) // 2, 6 + (16 - tmp.height) // 2
    m = tmp.load()
    solid = {(x + ox, y + oy) for y in range(tmp.height) for x in range(tmp.width) if m[x, y]}
    for y in range(n):
        for x in range(n):
            if (x, y) in solid:
                continue
            d = min((abs(x - a) + abs(y - b) for (a, b) in solid), default=9)
            if d == 1:
                px[x, y] = mix(px[x, y], CYAN_HALO, 0.5)
            elif d == 2:
                px[x, y] = mix(px[x, y], CYAN_HALO, 0.2)
    for (x, y) in solid:
        inner = all((x + dx, y + dy) in solid for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
        px[x, y] = CYAN_HI if inner else CYAN
    return im


def app_icon_svg(path, n=32, size=128):
    """Writes the pixel icon as SVG rects (row runs merged), clipped to a rounded square, so it stays crisp."""
    im = app_icon_pixels(n)
    px = im.load()
    k = size // n
    out = ['<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d" shape-rendering="crispEdges">'
           % (size, size, size, size),
           '  <!-- Aksara Kala app icon, generated by tools/gen_ui_dusk.py (ui.md 5): dusk sky, stars, the horizon and '
           'Javanese Ka in the cyan glyph light. Pixel art, 32x32 at 4x. -->',
           '  <clipPath id="r"><rect width="%d" height="%d" rx="%d"/></clipPath>' % (size, size, k * 6),
           '  <g clip-path="url(#r)">']
    for y in range(n):
        x = 0
        while x < n:
            c = px[x, y]
            x2 = x
            while x2 + 1 < n and px[x2 + 1, y] == c:
                x2 += 1
            out.append('    <rect x="%d" y="%d" width="%d" height="%d" fill="#%02X%02X%02X"/>'
                       % (x * k, y * k, (x2 - x + 1) * k, k, c[0], c[1], c[2]))
            x = x2 + 1
    out += ['  </g>', '</svg>', '']
    Path(path).write_text("\n".join(out))
    return im


# ---------------------------------------------------------------- preview

def preview(files):
    S = 2
    sheet = new(960, 1, rgb("101018"))
    x = y = 0
    rowh = 0
    placed = []
    for name, im in files:
        if im.width > 300:
            continue
        sc = 3 if im.width <= 40 and im.height <= 40 else 2 if im.width <= 120 else 1
        w, h = im.width * sc, im.height * sc
        if x + w > 940:
            x = 0
            y += rowh + 8
            rowh = 0
        placed.append((im.resize((w, h), Image.NEAREST), (x + 10, y + 10)))
        x += w + 8
        rowh = max(rowh, h)
    sheet = new(960, y + rowh + 20, rgb("101018"))
    for im, pos in placed:
        sheet.alpha_composite(im, pos)
    return sheet


def compose_title(art, hero):
    """Static mock of the title (the game animates the stars, the rising glyphs and the menu)."""
    im = new(480, 270)
    im.alpha_composite(art["title_sky"])
    im.alpha_composite(art["title_constellation"], (330, 24))
    im.alpha_composite(art["title_far"])
    if hero is not None:
        im.alpha_composite(art["title_glow"].resize((40, 40), Image.NEAREST), (364, 188))
    im.alpha_composite(art["title_near"])
    if hero is not None:
        im.alpha_composite(hero, (372, 190))
    for key, pos in (("title_glyph_ka", (382, 152)), ("title_glyph_ja", (400, 112)), ("title_glyph_la", (370, 84))):
        im.alpha_composite(art[key], pos)
    lg = art["logo"]
    im.alpha_composite(lg, (36, 32))
    return im


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    art = {}
    # world surfaces (HUD, dialogue, prompts, cards)
    art["ink_panel"] = panel(12, 12)
    art["ink_panel_focus"] = glow_panel(12, 12)
    art["ink_slot"] = well(20, 20)
    art["frame_portrait"] = well(56, 56, HAIR)
    art["keycap"] = keycap()
    art["continue_arrow"] = tri_down()
    art["ink_cursor"] = diamond()
    art["lozenge"] = diamond()
    art["arrow_objective"] = arrow()
    art["icon_ilmu"] = ilmu_icon()
    art["icon_save"] = save_icon()
    art["ink_mote"] = mote()
    art["title_star"] = star()
    art["title_star_big"] = star(True)
    art["cursor"] = mouse_cursor()
    art["divider"] = divider()
    art["vignette"] = vignette()
    art["title_glow"] = glow(64)
    art["pedestal"] = pedestal()
    art["light_cone"] = light_cone()
    # theme.tres set
    art["panel"] = panel(24, 24, HAIR, FILL)
    art["panel_dialogue"] = panel(32, 32, HAIR, FILL)
    art["button_normal"] = panel(24, 14, HAIR, RAISED)
    art["button_hover"] = glow_panel(24, 14, RAISED)
    art["button_pressed"] = glow_panel(24, 14, rgb("1A1530"))
    art["button_disabled"] = panel(24, 14, HAIR_LO, rgb("120E24", 200))
    art["tab_on"] = glow_panel(24, 14, RAISED)
    art["tab_off"] = panel(24, 14, HAIR_LO, rgb("120E24"))
    art["slot"] = well(20, 20)
    art["slot_selected"] = glow_panel(20, 20, WELL)
    art["inset"] = well(12, 12)
    art["row_highlight"] = row_hi()
    art["scroll_track"] = new(5, 12, rgb("0E0B1C"))
    art["scroll_grab"] = panel(5, 12, CYAN_HALO, RAISED)
    art["bullet_now"] = bullet("now")
    art["bullet_open"] = bullet("open")
    art["bullet_check"] = bullet("check")
    # menu "book" set (dusk star chart)
    art["book_cover"] = cover()
    art["book_page_l"] = page(1)
    art["book_page_r"] = page(2)
    art["book_spine"] = spine()
    art["book_corner"] = corner()
    art["book_footer"] = footer()
    for st in ("on", "off", "hover"):
        art["book_ribbon_" + st] = ribbon(st)
    art["book_row"] = row_hi()
    art["book_row_sel"] = row_sel()
    art["book_rule"] = rule()
    art["book_btn"] = btn(False)
    art["book_btn_hi"] = btn(True)
    art["book_card"] = card()
    art["book_slot"] = slot(False)
    art["book_slot_sel"] = slot(True)
    art["book_bar"] = bar_frame()
    art["book_bar_fill"] = bar_fill()
    for k in ("on", "off", "gear"):
        art["book_pip_" + k] = pip(k)
    art["book_plus"] = plus("n")
    art["book_plus_hi"] = plus("hi")
    art["book_plus_off"] = plus("off")
    art["book_seal"] = seal_level()
    art["book_seal_small"] = seal_points()
    for k in ("main", "side", "done"):
        art["book_seal_" + k] = quest_seal(k)
    art["book_new"] = new_dot()
    art["book_equipped"] = equipped()
    art["book_up"] = updown(True)
    art["book_down"] = updown(False)
    art["book_track"] = track()
    art["book_cursor"] = diamond(7)
    art["book_disc"] = disc()
    art["book_glyph_tile"] = glyph_tile()
    art["book_kawung"] = new(24, 24)   # retired pattern, kept transparent for any old reference
    # paper-era icons: recolour ink to pale lavender, gold to amber, wax accents to cyan
    names = [p.stem for p in OUT.glob("book_ic_*.png")] + [p.stem for p in OUT.glob("book_tab_*.png")] + \
            [p.stem for p in OUT.glob("icon_tab_*.png")]
    for n in sorted(set(names)):
        im = recolour(n)
        if im is not None:
            art[n] = im
    art["book_doll"] = doll()
    # title scene
    art["title_sky"] = sky()
    art["title_far"] = far()
    art["title_near"] = near()
    art["title_constellation"] = constellation()
    for k in GLYPHS:
        art["title_glyph_" + k] = glyph_sprite(k)
    art["logo"] = logo()

    for n, im in art.items():
        im.save(OUT / (n + ".png"))
    icon = app_icon_svg(ROOT / "icon.svg")
    art["(icon.svg)"] = icon

    hero = None
    hp = ROOT / "assets" / "art" / "hero_mage.png"
    if hp.exists():
        hero = Image.open(hp).convert("RGBA").crop((0, 48, 24, 72))
    sheet = preview([(n, im) for n, im in art.items()])
    title = compose_title(art, hero).resize((960, 540), Image.NEAREST)
    full = new(960, 540 + sheet.height, rgb("101018"))
    full.alpha_composite(title, (0, 0))
    full.alpha_composite(sheet, (0, 540))
    full.save(ROOT / "tools" / "ui_dusk_preview.png")
    print("dusk set: %d files -> %s" % (len(art), OUT))


if __name__ == "__main__":
    main()
