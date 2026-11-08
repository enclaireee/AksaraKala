#!/usr/bin/env python3
"""The Last Aksara: art for the pause/Tab menu "field book" (ui.md 4.3, 5).
Leather cover, two parchment pages with a very faint kawung tile, spine shadow, carved (ukiran) corner pieces,
tab ribbons, footer band, wax seals, stat icons, pips, ground disc, paper-doll outline, NEW dot, tab icons.
Ornament is kawung and plain tooled leather only. Parang Rusak is never used (restricted court motif).
Same pixel writer and palette as tools/gen_ui_rpg.py (no PIL needed).
Run: python3 tools/gen_menu_book.py   Output: assets/art/ui/book_*.png and tools/menu_book_preview.png
"""
import math
import os
import random
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_ui as G
from gen_ui import Img, hexc, sprite, nine_patch
import gen_ui_rpg as R

OUT = G.OUT
CLEAR = (0, 0, 0, 0)
PAPER_HI, PAPER, PAPER_MID, PAPER_LO, PAPER_DK = R.PAPER_HI, R.PAPER, R.PAPER_MID, R.PAPER_LO, R.PAPER_DK
INK, INK_SOFT, INK_FADE = R.INK, R.INK_SOFT, R.INK_FADE
INK_RED = hexc("7A2A1E")
LEA_HI, LEA, LEA_LO, LEA_DK = R.LEA_HI, R.LEA, R.LEA_LO, R.LEA_DK
STITCH = R.STITCH
IRON_HI, IRON, IRON_LO, IRON_DK = R.IRON_HI, R.IRON, R.IRON_LO, R.IRON_DK
WAX_HI, WAX, WAX_LO = R.WAX_HI, R.WAX, R.WAX_LO
VERD, VERD_HI = R.VERD, R.VERD_HI
VERD_LO = hexc("24493C")
SAKTI, SAKTI_HI, SAKTI_LO = hexc("2F5F9A"), hexc("6A9AD0"), hexc("1A3560")
STAM, STAM_HI, STAM_LO = hexc("4C7A3A"), hexc("7FB060"), hexc("2A4A22")


def a(c, al):
    return (c[0], c[1], c[2], al)


def round_corners(im, col=CLEAR):
    for (x, y) in ((0, 0), (im.w - 1, 0), (0, im.h - 1), (im.w - 1, im.h - 1)):
        im.put(x, y, col)


def ellipse(im, cx, cy, rx, ry, col, fill=True):
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            d = ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2
            if fill and d <= 1.0:
                im.put(x, y, col)
            elif not fill and 0.62 <= d <= 1.0:
                im.put(x, y, col)


# ---------------------------------------------------------------- cover, pages, spine, corners
def make_cover():
    """24x24 nine-patch, margin 8: stitched leather cover. Centre is plain dark leather (pages cover it)."""
    w = h = 24
    im = Img(w, h)
    im.rect(0, 0, w - 1, h - 1, LEA_DK)
    im.rect(1, 1, w - 2, h - 2, LEA)
    im.rect(1, 1, w - 2, 1, LEA_HI)
    im.rect(1, 1, 1, h - 2, LEA_HI)
    im.rect(1, h - 2, w - 2, h - 2, LEA_LO)
    im.rect(w - 2, 1, w - 2, h - 2, LEA_LO)
    # stitched seam 2 px in: continuous so it survives stretching
    seam = hexc("9A7A50")
    im.rect(2, 2, w - 3, 2, seam)
    im.rect(2, h - 3, w - 3, h - 3, seam)
    im.rect(2, 2, 2, h - 3, seam)
    im.rect(w - 3, 2, w - 3, h - 3, seam)
    im.rect(3, 3, w - 4, h - 4, LEA_LO)
    im.rect(3, 3, w - 4, 3, LEA_DK)   # inner lip where the pages sit
    round_corners(im)
    return im


def make_page(right):
    """48x48 nine-patch, margin 8, centre tiles: parchment, burnt outer edge, page-stack lines on the outer side,
    darker towards the spine. right=True mirrors it."""
    w = h = 48
    im = Img(w, h)
    rnd = random.Random(7 if right else 3)
    for y in range(h):
        for x in range(w):
            n = rnd.random()
            c = PAPER if n < 0.86 else (PAPER_HI if n < 0.93 else PAPER_MID)
            im.put(x, y, c)
    # top / bottom burnt edge
    for x in range(w):
        im.put(x, 0, PAPER_DK)
        im.put(x, 1, PAPER_LO)
        im.put(x, h - 1, PAPER_DK)
        im.put(x, h - 2, PAPER_LO)
        if x % 3 != 1:
            im.put(x, 2, PAPER_MID)
            im.put(x, h - 3, PAPER_MID)
    # outer edge: page stack (alternating paper and shadow lines)
    for y in range(h):
        im.put(0, y, PAPER_DK)
        im.put(1, y, PAPER_MID)
        im.put(2, y, PAPER_LO)
        im.put(3, y, PAPER_HI)
        im.put(4, y, PAPER_MID if y % 4 else PAPER_LO)
    # spine side: a soft warm darkening (the spine texture adds the real gutter shadow)
    for y in range(2, h - 2):
        im.put(w - 1, y, PAPER_MID)
    for (x, y) in ((0, 0), (0, h - 1)):
        im.put(x, y, CLEAR)
    if right:
        o = Img(w, h)
        for y in range(h):
            for x in range(w):
                o.p[y][x] = im.p[y][w - 1 - x]
        return o
    return im


def make_kawung():
    """24x24 tile, transparent: kawung petals (four ovals around each lattice point) in ink at very low alpha."""
    s = 24
    im = Img(s, s)
    line = a(INK, 20)
    dot = a(INK, 26)
    petals = ((6, 6, 1, 1), (18, 18, 1, 1), (18, 6, 1, -1), (6, 18, 1, -1))
    ra, rb = 7.2, 3.4
    for y in range(s):
        for x in range(s):
            for (px, py, dx, dy) in petals:
                for ox in (-s, 0, s):
                    for oy in (-s, 0, s):
                        vx, vy = x + 0.5 - (px + ox), y + 0.5 - (py + oy)
                        u = (vx * dx + vy * dy) / math.sqrt(2)
                        v = (vx * dy - vy * dx) / math.sqrt(2)
                        d = (u / ra) ** 2 + (v / rb) ** 2
                        if 0.66 <= d <= 1.0:
                            im.put(x, y, line)
    for (px, py, _, _) in petals:
        im.put(px, py, dot)
    for (x, y) in ((0, 0), (12, 12)):
        im.put(x, y, dot)
    return im


def make_spine():
    """32x4, stretched vertically: gutter shadow centred, a crease line in the middle."""
    w, h = 32, 4
    im = Img(w, h)
    for x in range(w):
        d = abs(x + 0.5 - w / 2) / (w / 2)   # 0 centre .. 1 edge
        al = int(150 * (1 - d) ** 2.2)
        for y in range(h):
            im.put(x, y, (58, 35, 20, al))
    for y in range(h):
        im.put(15, y, (40, 24, 14, 200))
        im.put(16, y, (90, 62, 38, 150))
    return im


def make_corner():
    """14x14 carved corner piece (top-left; the menu flips it for the others): tooled leather with gold-thread relief,
    a curled ukiran tendril ending in a small kawung bud."""
    rows = [
        "DDDDDDDDDDDDD.",
        "DHHHHHHHHHHHD.",
        "DHGGGGGGGGLLD.",
        "DHGLLLLLLLLD..",
        "DHGLKKGLLDD...",
        "DHGLKHKLD.....",
        "DHGLGKGD......",
        "DHGLLGD.......",
        "DHGLLD........",
        "DHGLD.........",
        "DHLD..........",
        "DHLD..........",
        "DDD...........",
        "..............",
    ]
    return sprite(rows, {"D": LEA_DK, "H": hexc("A88A5C"), "G": STITCH, "L": LEA, "K": hexc("E8CC90")})


# ---------------------------------------------------------------- ribbons, footer
def make_ribbon(state):
    """Tab ribbon, 16x20, nine-patch margins (5, 5, 5, 3). on = paper (merges with the page), off = leather,
    hover = lighter leather."""
    w, h = 16, 20
    im = Img(w, h)
    if state == "on":
        im.rect(0, 0, w - 1, h - 1, INK_SOFT)
        im.rect(1, 1, w - 2, h - 1, PAPER)
        im.rect(1, 1, w - 2, 1, PAPER_HI)
        im.rect(1, 1, 1, h - 1, PAPER_HI)
        im.rect(w - 2, 2, w - 2, h - 1, PAPER_MID)
        im.rect(2, 2, w - 3, 2, WAX)          # a thin wax-red head band
        im.rect(2, 3, w - 3, 3, WAX_LO)
    else:
        base, hi, lo = (LEA, LEA_HI, LEA_LO) if state == "hover" else (LEA_LO, LEA, LEA_DK)
        im.rect(0, 0, w - 1, h - 1, LEA_DK)
        im.rect(1, 1, w - 2, h - 1, base)
        im.rect(1, 1, w - 2, 1, hi)
        im.rect(1, 1, 1, h - 1, hi)
        im.rect(w - 2, 2, w - 2, h - 1, lo)
        for y in range(3, h, 2):
            im.put(3, y, a(STITCH, 120))
            im.put(w - 4, y, a(STITCH, 120))
    im.put(0, 0, CLEAR)
    im.put(w - 1, 0, CLEAR)
    return im


def make_footer():
    """16x12 nine-patch (margin 4 left/right, 3 top/bottom), centre tiles: dark leather band with dashed stitching."""
    w, h = 16, 12
    im = Img(w, h)
    im.rect(0, 0, w - 1, h - 1, LEA_DK)
    im.rect(0, 1, w - 1, h - 2, LEA_LO)
    im.rect(0, 1, w - 1, 1, LEA)
    for x in range(w):
        if x % 4 < 2:
            im.put(x, 2, a(STITCH, 150))
            im.put(x, h - 3, a(STITCH, 150))
    return im


# ---------------------------------------------------------------- seals, pips, bars, buttons
def wax_seal(size, seed=1):
    im = Img(size, size)
    c = size / 2.0
    rnd = random.Random(seed)
    wob = [rnd.uniform(-0.6, 0.6) for _ in range(12)]
    for y in range(size):
        for x in range(size):
            dx, dy = x + 0.5 - c, y + 0.5 - c
            ang = math.atan2(dy, dx)
            r = c - 0.6 + wob[int((ang + math.pi) / (2 * math.pi) * 12) % 12]
            d = math.hypot(dx, dy)
            if d <= r:
                col = WAX
                if d > r - 1.2:
                    col = WAX_LO
                elif dx + dy < -c * 0.55:
                    col = WAX_HI
                im.put(x, y, col)
    # embossed inner ring
    ri = c * 0.62
    for y in range(size):
        for x in range(size):
            dx, dy = x + 0.5 - c, y + 0.5 - c
            d = math.hypot(dx, dy)
            if abs(d - ri) < 0.55:
                im.put(x, y, WAX_LO if dx + dy > 0 else WAX_HI)
    return im


def make_pips():
    on = sprite([".I.", "IRI", "IRI", "IRI", ".I."], {"I": INK, "R": WAX})
    off = sprite([".F.", "F.F", "F.F", "F.F", ".F."], {"F": INK_FADE})
    gear = sprite([".I.", "IVI", "IVI", "IVI", ".I."], {"I": INK, "V": VERD})   # a point from gear
    return on, off, gear


def make_bar():
    """8x8 nine-patch margin 2: inked bar frame with a sunken paper well."""
    im = Img(8, 8)
    im.rect(0, 0, 7, 7, INK)
    im.rect(1, 1, 6, 6, PAPER_LO)
    im.rect(1, 1, 6, 1, PAPER_DK)
    round_corners(im)
    fill = Img(4, 6)
    for x in range(4):
        fill.put(x, 0, WAX_HI)
        fill.put(x, 1, WAX_HI if x % 2 else WAX)
        for y in range(2, 5):
            fill.put(x, y, WAX)
        fill.put(x, 5, WAX_LO)
    return im, fill


def make_btn(hi):
    """12x12 nine-patch margin 3: a small paper button with an ink rim (wax rim when focused)."""
    im = Img(12, 12)
    rim = WAX if hi else INK_SOFT
    im.rect(0, 0, 11, 11, rim)
    im.rect(1, 1, 10, 10, PAPER_HI if hi else PAPER)
    im.rect(1, 10, 10, 10, PAPER_LO)
    im.rect(10, 1, 10, 10, PAPER_MID)
    if hi:
        im.rect(1, 1, 10, 1, (255, 248, 222, 255))
    round_corners(im)
    return im


def make_plus(state):
    rim, fill, mark = {"on": (INK_SOFT, PAPER_HI, WAX), "hi": (WAX, PAPER_HI, WAX), "off": (INK_FADE, PAPER_MID, INK_FADE)}[state]
    im = Img(11, 11)
    im.rect(0, 0, 10, 10, rim)
    im.rect(1, 1, 9, 9, fill)
    im.rect(1, 9, 9, 9, PAPER_LO if state != "off" else PAPER_MID)
    round_corners(im)
    im.rect(5, 3, 5, 7, mark)
    im.rect(3, 5, 7, 5, mark)
    if state == "hi":
        im.rect(1, 1, 9, 1, (255, 248, 222, 255))
        im.rect(4, 3, 6, 7, mark)
        im.rect(3, 4, 7, 6, mark)
    return im


def make_row():
    """12x12 nine-patch margin 4: focused-row wash (faint wax) with an inked underline."""
    im = Img(12, 12)
    im.rect(0, 0, 11, 11, a(WAX, 34))
    im.rect(0, 11, 11, 11, a(WAX, 110))
    im.rect(0, 0, 0, 11, a(WAX, 90))
    return im


def make_row_sel():
    """Selected (not focused) row: a pale paper highlight."""
    im = Img(12, 12)
    im.rect(0, 0, 11, 11, a(PAPER_HI, 200))
    im.rect(0, 11, 11, 11, a(PAPER_LO, 200))
    return im


def make_card():
    """16x16 nine-patch margin 4: an inked card glued onto the page (darker paper, ink rule, small corner ticks)."""
    im = Img(16, 16)
    im.rect(0, 0, 15, 15, INK_SOFT)
    im.rect(1, 1, 14, 14, PAPER_MID)
    im.rect(1, 1, 14, 1, PAPER)
    im.rect(1, 1, 1, 14, PAPER)
    im.rect(2, 2, 13, 13, hexc("DCC794"))
    round_corners(im)
    return im


def make_rule():
    """32x3 nine-patch margin 8 horizontal: an ink rule with faded ends and a centre diamond-less line."""
    im = Img(32, 3)
    for x in range(32):
        if x < 4 or x > 27:
            col = a(INK_FADE, 120) if x % 2 == 0 else CLEAR
        elif x < 8 or x > 23:
            col = INK_FADE
        else:
            col = INK_SOFT
        im.put(x, 1, col)
    return im


def make_slot(sel):
    """24x24 nine-patch margin 5: iron-rimmed well for the paper-doll slots."""
    w = h = 24
    im = Img(w, h)
    rim, hi = (WAX, WAX_HI) if sel else (IRON_LO, IRON)
    im.rect(0, 0, w - 1, h - 1, IRON_DK)
    im.rect(1, 1, w - 2, h - 2, rim)
    im.rect(1, 1, w - 2, 1, hi)
    im.rect(1, 1, 1, h - 2, hi)
    im.rect(2, 2, w - 3, h - 3, hexc("2E1D12"))
    im.rect(2, 2, w - 3, 2, hexc("160D08"))
    im.rect(2, 2, 2, h - 3, hexc("160D08"))
    im.rect(3, h - 3, w - 3, h - 3, hexc("3C2818"))
    round_corners(im)
    for (x, y) in ((1, 1), (w - 2, 1), (1, h - 2), (w - 2, h - 2)):
        im.put(x, y, IRON_HI if not sel else WAX_HI)
    return im


def make_glyph_tile():
    """20x20 nine-patch margin 4: a lighter paper chip with an ink frame, for a learned aksara."""
    w = h = 20
    im = Img(w, h)
    im.rect(0, 0, w - 1, h - 1, INK_SOFT)
    im.rect(1, 1, w - 2, h - 2, PAPER_HI)
    im.rect(1, h - 2, w - 2, h - 2, PAPER_MID)
    im.rect(w - 2, 1, w - 2, h - 2, PAPER_MID)
    im.rect(2, 2, w - 3, 2, a(WAX, 160))
    round_corners(im)
    return im


# ---------------------------------------------------------------- figure, disc, doll
def make_disc():
    """88x16 painted ground disc: an ink wash ellipse, dithered to the edge."""
    w, h = 88, 16
    im = Img(w, h)
    cx, cy, rx, ry = w / 2, h / 2, w / 2 - 1, h / 2 - 1
    for y in range(h):
        for x in range(w):
            d = math.hypot((x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry)
            if d > 1:
                continue
            b = G.bayer(x, y) if hasattr(G, "bayer") else 0.5
            if d < 0.55:
                im.put(x, y, a(INK_SOFT, 110))
            elif d < 0.8:
                im.put(x, y, a(INK_SOFT, 80) if b < 0.75 else a(INK_SOFT, 110))
            elif b < (1 - d) * 3.2:
                im.put(x, y, a(INK_SOFT, 60))
    # a painted rim stroke on the far side
    for x in range(10, w - 10):
        t = (x + 0.5 - cx) / rx
        y = int(cy - ry * math.sqrt(max(0, 1 - t * t)) + 0.5)
        im.put(x, y, a(INK_SOFT, 90))
    return im


def make_doll():
    """56x104 paper-doll outline: a standing figure in dotted ink with a faint wash, arms a little out."""
    w, h = 56, 104
    im = Img(w, h)
    cx = w / 2

    def inside(x, y):
        px, py = x + 0.5, y + 0.5
        # head
        if math.hypot(px - cx, py - 12) <= 8.5:
            return True
        # neck
        if abs(px - cx) <= 3 and 19 <= py <= 24:
            return True
        # torso (tapering)
        if 23 <= py <= 60:
            half = 12 - (py - 23) * 0.09
            if abs(px - cx) <= half:
                return True
        # arms
        for s in (-1, 1):
            ax0, ay0, ax1, ay1 = cx + s * 12, 25, cx + s * 19, 62
            t = max(0.0, min(1.0, ((px - ax0) * (ax1 - ax0) + (py - ay0) * (ay1 - ay0)) / ((ax1 - ax0) ** 2 + (ay1 - ay0) ** 2)))
            qx, qy = ax0 + (ax1 - ax0) * t, ay0 + (ay1 - ay0) * t
            if math.hypot(px - qx, py - qy) <= 3.6 - t * 0.8:
                return True
        # legs
        if 58 <= py <= 100:
            for s in (-1, 1):
                lx = cx + s * (5.5 + (py - 58) * 0.03)
                if abs(px - lx) <= 4.6 - (py - 58) * 0.03:
                    return True
        return False

    mask = [[inside(x, y) for x in range(w)] for y in range(h)]
    for y in range(h):
        for x in range(w):
            if not mask[y][x]:
                continue
            edge = any(not (0 <= x + dx < w and 0 <= y + dy < h and mask[y + dy][x + dx])
                       for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
            if edge:
                if (x + y) % 3 != 2:
                    im.put(x, y, a(INK_SOFT, 170))
            else:
                im.put(x, y, a(INK_SOFT, 28))
    return im


# ---------------------------------------------------------------- icons (10x10)
ICONS = {
    # attributes
    "vit": ([".WW..WW...", "WHWWWWWW..", "WHWWWWWWS.", "WWWWWWWWS.", ".WWWWWWS..", "..WWWWS...", "...WWS....", "....S.....",
             "..........", ".........."], {"W": WAX_HI, "H": hexc("F0A090"), "S": WAX_LO}),
    "end": (["....LLL...", "...LHHL...", "..LHHLL...", ".LHHL.L...", ".LHL..L...", "LHL..LLL..", "LL..LHHL..", "L..LHHL...",
             "...LHL....", "..LL......"], {"L": STAM_LO, "H": STAM_HI}),
    "str": (["....III...", "...IKKKI..", "..IKKKKKI.", "..IKKKKKI.", "...IKKKI..", "....IKI...", "....IKI...", "....IKI...",
             "...IIKII..", "...IIIII.."], {"I": INK, "K": IRON}),
    "dex": ([".......IHH", "......IHH.", ".....IHH..", "....IHI...", "...III....", "..III.....", ".IWI......", "IWI.......",
             "WI........", ".........."], {"I": INK, "H": PAPER_HI, "W": WAX}),
    "time": ([".IIIIIIII.", "I........I", "I...WW...I", "I...WW...I", "I...WWW..I", "I....WWW.I", "I........I", "I........I",
              ".IIIIIIII.", ".........."], {"I": INK, "W": WAX}),
    "spi": (["....S.....", "...SHS....", "...SHS....", "..SHHHS...", "..SHBHS...", ".SHBBBHS..", ".SHBBBHS..", "..SHBHS...",
             "...SSS....", ".........."], {"S": SAKTI_LO, "H": SAKTI_HI, "B": SAKTI}),
    # derived
    "hp": (["..........", ".WW..WW...", "WHWWWWWW..", "WHWWWWWWS.", "WWWWWWWWS.", ".WWWWWWS..", "..WWWWS...", "...WWS....",
            "....S.....", ".........."], {"W": WAX_HI, "H": hexc("F0A090"), "S": WAX_LO}),
    "sta": (["......HYY.", ".....HYY..", "....HYYS..", "...HYYYYS.", "......YS..", ".....YS...", "....YS....", "...YS.....",
             "..YS......", ".........."], {"Y": STAM_HI, "H": hexc("B8E090"), "S": STAM_LO}),
    "sak": ([".......HB.", "......HBS.", ".....HBS..", "....HBS...", "...FFS....", "..WWF.....", ".WWW......", ".KW.......",
             "..........", ".........."], {"B": SAKTI_HI, "H": hexc("B0D0F0"), "S": SAKTI, "F": PAPER, "W": PAPER_HI, "K": INK}),
    "atk": (["........IH", ".......IHI", "......IHI.", ".....IHI..", "....IHI...", ".I.IHI....", "..IHI.....", "..KI......",
             ".K.I......", "K........."], {"I": INK, "H": IRON_HI, "K": LEA}),
    "def": (["IIIIIIIII.", "IHHHHWWWI.", "IHHHHWWWI.", "IHHHHWWWI.", "IWWWWHHHI.", ".IWWWHHI..", ".IWWWHHI..", "..IWWHI...",
             "...III....", ".........."], {"I": INK, "H": IRON_HI, "W": IRON}),
    "jamu": (["...SSS....", "....S.....", "...III....", "..IGGGI...", ".IGHGGGI..", ".IGGGGGI..", ".IGGGGGI..", "..IGGGI...",
              "...III....", ".........."], {"S": IRON_HI, "I": INK, "G": hexc("2FA38A"), "H": hexc("9FE8D0")}),
    "ilmu": (["..IIII....", ".IHHHHI...", "IHRRRRHI..", "IHHHHHHI..", "IHRRRRHI..", "IHHHHHHI..", ".IHHHHI...", "..IIII....",
              "..........", ".........."], {"I": INK_SOFT, "H": PAPER_HI, "R": WAX}),
    "pin": (["...III....", "..IWWWI...", ".IWHWWWI..", ".IWWWWWI..", "..IWWWI...", "..IWWWI...", "...IWI....", "...IWI....",
             "....I.....", ".........."], {"I": INK, "W": WAX, "H": WAX_HI}),
    "mouse": (["..IIIII...", ".IHHIHHI..", ".IHHIHHI..", ".IIIIIII..", ".IPPPPPI..", ".IPPPPPI..", ".IPPPPPI..", "..IPPPI...",
               "...III....", ".........."], {"I": INK, "H": PAPER_HI, "P": PAPER}),
    "time": (["IIIIIII...", ".IHHHI....", ".IHHHI....", "..IHI.....", "...I......", "..IWI.....", ".IWWWI....", ".IWWWI....",
              "IIIIIII...", ".........."], {"I": INK, "H": PAPER_HI, "W": hexc("C8A060")}),
    "updown": (["....I.....", "...III....", "..IIIII...", "....I.....", "....I.....", "....I.....", "..IIIII...", "...III....",
                "....I.....", ".........."], {"I": INK}),
}

# tab icons: white so the menu tints them (ink on the open paper ribbon, paper on leather)
TAB_EXTRA = {
    "book_tab_controls": ["..CCCCCC..", ".C..C...C.", ".C..C...C.", ".CCCCCCCC.", ".C......C.", ".C......C.",
                          ".C......C.", "..CCCCCC..", "...D..D...", ".DD.DD.D.."],
}


def make_icons():
    out = {}
    for n, (rows, pal) in ICONS.items():
        rows = [r.ljust(10, ".")[:10] for r in rows]
        out["book_ic_" + n] = sprite(rows, pal)
    names = {"icon_tab_status": "book_tab_status", "icon_tab_equip": "book_tab_equip", "icon_tab_journal": "book_tab_journal",
             "icon_tab_map": "book_tab_map", "icon_tab_pustaka": "book_tab_codex", "icon_tab_system": "book_tab_system"}
    for src, dst in names.items():
        rows = [r.ljust(10, ".")[:10] for r in R.TAB[src]]
        out[dst] = sprite(rows, {"C": (255, 255, 255, 255), "D": (255, 255, 255, 110)})
    for n, rows in TAB_EXTRA.items():
        out[n] = sprite([r.ljust(10, ".")[:10] for r in rows], {"C": (255, 255, 255, 255), "D": (255, 255, 255, 110)})
    return out


def make_small():
    out = {}
    out["book_cursor"] = sprite(["...O...", "..OHO..", ".OHWWO.", "OHWWWLO", ".OWWLO.", "..OLO..", "...O..."],
                                {"O": WAX_LO, "H": WAX_HI, "W": WAX, "L": WAX_LO})
    out["book_new"] = sprite([".SSSS.", "SHWWWS", "SWWWWS", "SWWWLS", "SWWLLS", ".SSSS."],
                             {"S": WAX_LO, "H": hexc("F0A090"), "W": WAX_HI, "L": WAX})
    out["book_up"] = sprite(["..V..", ".VVV.", "VVVVV", "..V..", "..V.."], {"V": VERD})
    out["book_down"] = sprite(["..R..", "..R..", "RRRRR", ".RRR.", "..R.."], {"R": WAX})
    out["book_equipped"] = sprite([".SSSSS.", "SWWWWWS", "SWHHHWS", "SWHWWWS", "SWHHWWS", "SWHWWWS", "SWHHHWS", ".SSSSS."][:7],
                                  {"S": WAX_LO, "W": WAX, "H": PAPER_HI})
    out["book_track"] = sprite(["RRRRR", "RHRRR", "RHRRR", "RRRRR", "RRRRR", "RRRRR", "RR.RR", "R...R"],
                               {"R": WAX, "H": WAX_HI})
    out["book_seal_main"] = wax_seal(9, 5)
    side = wax_seal(9, 6)
    for y in range(side.h):
        for x in range(side.w):
            c = side.p[y][x]
            if c[3]:
                side.p[y][x] = {WAX: VERD, WAX_HI: VERD_HI, WAX_LO: VERD_LO}.get(c, c)
    out["book_seal_side"] = side
    done = sprite(["..III....", ".IPPPI...", "IPPPPVI..", "IPPPVPI..", "IVPVPPI..", "IPVPPPI..", ".IPPPI...", "..III....", "........."],
                  {"I": INK_FADE, "P": PAPER_MID, "V": VERD})
    out["book_seal_done"] = done
    return out


# ---------------------------------------------------------------- main
def main():
    A = {}
    A["book_cover"] = make_cover()
    A["book_page_l"] = make_page(False)
    A["book_page_r"] = make_page(True)
    A["book_kawung"] = make_kawung()
    A["book_spine"] = make_spine()
    A["book_corner"] = make_corner()
    A["book_ribbon_on"] = make_ribbon("on")
    A["book_ribbon_off"] = make_ribbon("off")
    A["book_ribbon_hover"] = make_ribbon("hover")
    A["book_footer"] = make_footer()
    A["book_seal"] = wax_seal(28, 2)
    A["book_seal_small"] = wax_seal(16, 3)
    A["book_pip_on"], A["book_pip_off"], A["book_pip_gear"] = make_pips()
    A["book_bar"], A["book_bar_fill"] = make_bar()
    A["book_btn"] = make_btn(False)
    A["book_btn_hi"] = make_btn(True)
    A["book_plus"] = make_plus("on")
    A["book_plus_hi"] = make_plus("hi")
    A["book_plus_off"] = make_plus("off")
    A["book_row"] = make_row()
    A["book_row_sel"] = make_row_sel()
    A["book_card"] = make_card()
    A["book_rule"] = make_rule()
    A["book_slot"] = make_slot(False)
    A["book_slot_sel"] = make_slot(True)
    A["book_glyph_tile"] = make_glyph_tile()
    A["book_disc"] = make_disc()
    A["book_doll"] = make_doll()
    A.update(make_icons())
    A.update(make_small())
    for name, im in A.items():
        im.save(os.path.join(OUT, name + ".png"))
    preview(A)
    print("wrote", len(A))


def preview(A):
    S = 3
    W = 1200
    pv = Img(W, 900, (60, 50, 44, 255))
    # composed mock spread at 2x: cover, pages, kawung, spine, corners
    mw, mh = 232, 128
    mock = nine_patch(A["book_cover"], (8, 8, 8, 8), mw, mh)
    pl = nine_patch(A["book_page_l"], (8, 8, 8, 8), mw // 2 - 4, mh - 8)
    pr = nine_patch(A["book_page_r"], (8, 8, 8, 8), mw // 2 - 4, mh - 8)
    for (pg, x0) in ((pl, 4), (pr, mw // 2)):
        for y in range(4, pg.h - 4):
            for x in range(6, pg.w - 4):
                k = A["book_kawung"].p[y % 24][x % 24]
                if k[3]:
                    pg.blend(x, y, k)
        mock.paste(pg, x0, 4)
    sp = A["book_spine"]
    for y in range(4, mh - 4):
        for x in range(sp.w):
            mock.blend(mw // 2 - 16 + x, y, sp.p[0][x])
    c = A["book_corner"]
    mock.paste(c, 0, 0)
    pv.paste(mock.scaled(2), 10, 10)
    x, y, rowh = 10 + mw * 2 + 16, 10, 0
    for n, im in A.items():
        s = im.scaled(S)
        if x + s.w > W - 10:
            x = 10 if y + rowh > mh * 2 else 10 + mw * 2 + 16
            y += rowh + 8
            rowh = 0
        pv.paste(s, x, y)
        x += s.w + 8
        rowh = max(rowh, s.h)
    final = Img(W, min(900, y + rowh + 12))
    final.p = pv.p[: final.h]
    final.save(os.path.join(G.ROOT, "tools", "menu_book_preview.png"))


if __name__ == "__main__":
    main()
