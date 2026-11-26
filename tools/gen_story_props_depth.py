#!/usr/bin/env python3
"""v6 depth-floor clue props (Tanah Timur, Segara Kidul, Gua Kala): one PNG per clue_id in assets/art/story/.
Standalone so it only writes these 17 files: run `python3 tools/gen_story_props_depth.py`.
Same style as gen_story_props_late.py: drawn bottom-centre (origin = feet), 1 px auto outline, soft glows painted after it.
"""
import math
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gen_story_props_late import *  # noqa: F401,F403  (C, K, palette, _shadow, footprints, shell, basket, stone_slab...)
from gen_story_props_late import _shadow

HIDE, HIDE_D = K("C89C6A"), K("94704A")
SCORCH = K("2A2224")
RUST_C, RUST_L = K("8A4A2A"), K("B8703E")
JANUR, JANUR_D = K("E8D070"), K("B89E40")
NETC, NETC_D = K("A8B0A4"), K("6E7870")
SILVER, SILVER_D = K("C4CED4"), K("7E8C96")
SQUID = K("E8C4B8")
ROOT, ROOT_D, ROOT_L = K("6A5440"), K("463626"), K("8E7658")
STAIN = K("B4B49C")
BLACK, BLACK_L, BLACK_D = K("2E2A36"), K("4A4456"), K("1E1A24")
PETRI, PETRI_D = K("7E7A84"), K("54505C")
FADE_A, FADE_B = K("C9B8E860"), K("C9B8E830")
DRY = K("A08848")


def glow(im, pts, col=FADE_A):
    """Post-outline soft pixels (pad = +1), no outline around them."""
    for x, y in pts:
        if 0 <= x + 1 < im.width and 0 <= y + 1 < im.height and im.getpixel((x + 1, y + 1))[3] == 0:
            im.putpixel((x + 1, y + 1), col)


# ------------------------------------------------------------------------------------------------ Tanah Timur
def gerbang_lintel():  # carved gate lintel with a warding mark scratched over it
    c = C(32, 24)
    _shadow(c, 1, 30, 23)
    stone_slab(c, 3, 8, 8, 22); stone_slab(c, 23, 8, 28, 22)
    stone_slab(c, 0, 2, 31, 8)
    for x in range(3, 29, 4):               # carved lozenge band
        c.poly([(x, 5), (x + 2, 3), (x + 4, 5), (x + 2, 7)], STONE_D)
        c.pt(x + 2, 5, STONE_L)
    c.line(11, 2, 20, 8, RED); c.line(20, 2, 11, 8, RED)   # the scratch-over
    c.line(12, 2, 21, 8, RED_D)
    c.rect(1, 20, 10, 22, STONE_D); c.rect(21, 20, 30, 22, STONE_D)
    return c


def herd_brand():  # hide on a drying frame with a red curse brand, the iron leaning beside
    c = C(28, 24)
    _shadow(c, 1, 26, 23)
    post(c, 2, 3, 22); post(c, 18, 3, 22)
    c.line(2, 3, 19, 3, WOOD_D)
    c.poly([(4, 4), (17, 4), (16, 9), (17, 15), (11, 17), (5, 16), (4, 10)], HIDE)
    c.poly([(4, 10), (5, 16), (11, 17), (17, 15), (16, 13), (10, 15), (5, 13)], HIDE_D)
    for x, y in [(4, 4), (17, 4), (5, 16), (17, 15)]:
        c.pt(x, y, WOOD_D)
    c.ell(7, 6, 14, 13, RED); c.ell(8, 7, 13, 12, HIDE); c.line(8, 12, 13, 7, RED)   # ringed slash
    c.pt(10, 14, RED_D); c.pt(10, 15, RED_D)                                          # drip
    c.line(25, 22, 22, 7, IRON_D); c.line(24, 22, 21, 7, IRON)                         # iron
    c.ell(18, 4, 23, 8, RED_D); c.ell(19, 5, 22, 7, (0, 0, 0, 0))
    c.rect(3, 21, 9, 22, ASH); c.pt(5, 20, ASH_D)
    return c


def waterhole_hoofprints():  # cracked rim, low water, cloven prints turning back, ash
    c = C(32, 20)
    c.ell(0, 4, 31, 19, SAND_D)
    c.ell(5, 7, 26, 16, MUD)
    c.ell(7, 8, 24, 15, WATER); c.line(10, 10, 15, 10, WATER_L); c.pt(19, 12, WATER_L)
    for x, y in [(3, 15), (27, 11), (26, 15), (5, 7)]:   # cracks
        c.line(x, y, x + 2, y - 1, MUD)
    for x, y in [(2, 10), (6, 14), (11, 16), (16, 17), (21, 16), (25, 13)]:   # prints come in, then turn away
        c.pt(x, y, MUD_D); c.pt(x, y + 1, MUD_D); c.pt(x + 2, y, MUD_D); c.pt(x + 2, y + 1, MUD_D)
    for x, y in [(19, 4), (24, 6), (14, 4)]:
        c.ell(x, y, x + 4, y + 2, ASH); c.pt(x + 2, y + 1, ASH_D)
    return c


def ladang_dry_furrow():  # furrow burnt into a spiral, ditch dry, one dead stalk
    c = C(30, 20)
    c.ell(0, 6, 29, 19, SAND_D)
    c.ell(2, 7, 27, 17, MUD)
    pts = [(15 + 0.9 * t * math.cos(t) * 1.4, 12 + 0.9 * t * math.sin(t) * 0.55) for t in [i * 0.25 for i in range(10, 45)]]
    for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
        c.line(round(x0), round(y0), round(x1), round(y1), SCORCH)
    c.pt(15, 12, ASH)
    for x, y in [(4, 10), (23, 16), (6, 16)]:
        c.line(x, y, x + 2, y + 1, MUD_D)
    c.line(24, 12, 24, 2, DRY); c.line(24, 5, 27, 8, DRY); c.line(24, 7, 21, 9, DRY); c.pt(25, 1, DRY)
    return c


# ------------------------------------------------------------------------------------------------ Segara Kidul
def wreck_hull_marks():  # a jukung hull on its side: tally cuts and a red burn
    c = C(34, 18)
    _shadow(c, 1, 32, 17)
    c.poly([(1, 6), (33, 4), (29, 15), (5, 15)], WOOD)
    c.poly([(5, 15), (29, 15), (31, 10), (3, 11)], WOOD_D)
    c.line(1, 6, 33, 4, WOOD_L)
    c.rect(24, 1, 25, 5, WOOD_D)                     # outrigger arm stub
    for i, x in enumerate(range(5, 17, 2)):          # tally: five and a strike
        c.line(x, 7, x, 10, WHITE)
    c.line(4, 10, 14, 7, WHITE)
    c.pt(16, 7, WHITE); c.pt(16, 8, WHITE)
    c.ell(20, 6, 27, 12, RED_D); c.ell(22, 7, 25, 10, RED); c.pt(23, 8, SCORCH)
    return c


def shore_tide_line():  # sand with the old weed line high up and the sea far below it
    c = C(32, 16)
    c.ell(0, 1, 31, 15, SAND)
    c.ell(2, 9, 29, 15, SAND_D)
    for x in range(2, 30):
        y = 4 + round(math.sin(x * 0.7))
        c.pt(x, y, LEAF_D if x % 3 else SEAGREEN)
    shell(c, 6, 1); shell(c, 20, 2, BONE)
    c.ell(4, 12, 27, 15, WATER); c.line(6, 12, 25, 12, WATER_L)
    return c


def tebing_stair_rail():  # cliff steps, a rail hung with green cloth and shell charms
    c = C(26, 28)
    _shadow(c, 1, 24, 27)
    for i in range(5):
        stone_slab(c, 1 + i * 4, 22 - i * 4, 24, 26 - i * 4)
    for x, y in [(3, 12), (12, 6), (21, 0)]:
        post(c, x, y, y + 12)
    c.line(3, 12, 22, 0, WOOD_D); c.line(3, 13, 22, 1, WOOD_L)
    for x, ln in [(7, 6), (10, 4), (16, 5)]:
        y = 12 - (x - 3) * 12 // 19
        c.rect(x, y + 1, x + 1, y + ln, SEAGREEN); c.pt(x + 1, y + ln, TEAL_D)
    for x in (13, 19):
        y = 12 - (x - 3) * 12 // 19
        c.pt(x, y + 1, WHITE); c.pt(x, y + 2, WHITE); c.pt(x, y + 3, BONE)
    return c


def nelayan_nets():  # a long gill net on bamboo racks, mended in many coloured knots
    c = C(34, 26)
    _shadow(c, 1, 32, 25)
    c.rect(1, 2, 2, 24, BAMBOO); c.rect(31, 2, 32, 24, BAMBOO)
    c.rect(1, 2, 32, 3, BAMBOO_D)
    for x in range(3, 31):
        for y in range(4, 20):
            if (x + y) % 3 == 0 or (x - y) % 3 == 0:
                c.pt(x, y, NETC if y < 16 else NETC_D)
    for x in range(4, 31, 4):
        c.pt(x, 4, RED); c.pt(x, 5, RED)            # floats
    for x, y, col in [(8, 10, GOLD), (15, 14, RED), (22, 8, TEAL), (26, 15, GOLD), (11, 17, TEAL), (19, 12, WHITE)]:
        c.rect(x, y, x + 1, y + 1, col)              # mend knots
    c.line(3, 20, 30, 20, GREY)                      # lead line
    return c


def nelayan_racks():  # fish and squid drying on a bamboo rack
    c = C(32, 20)
    _shadow(c, 1, 30, 19)
    for x in (2, 28):
        c.rect(x, 8, x + 1, 18, BAMBOO_D)
    c.rect(0, 6, 31, 8, BAMBOO)
    for x in range(1, 31, 3):
        c.pt(x, 8, BAMBOO_D)
    for x in (2, 8, 14):                             # fish
        c.ell(x, 2, x + 5, 5, SILVER); c.line(x, 4, x + 4, 4, SILVER_D)
        c.poly([(x + 5, 3), (x + 7, 1), (x + 7, 5)], SILVER_D); c.pt(x + 1, 3, INK)
    for x in (21, 26):                               # squid
        c.ell(x, 1, x + 3, 5, SQUID)
        for t in range(4):
            c.pt(x + t, 6 if t % 2 else 5, SQUID)
    return c


def nelayan_sedekah():  # sedekah laut offerings: ancak tray, small tumpeng, flowers, fruit, janur, a little boat
    c = C(32, 22)
    _shadow(c, 1, 30, 21)
    c.rect(1, 13, 20, 19, BAMBOO_D); c.rect(1, 13, 20, 15, BAMBOO)       # ancak tray
    for x in range(3, 20, 3):
        c.line(x, 16, x, 19, BAMBOO)
    c.ell(2, 11, 19, 15, LEAF)                                         # banana leaf
    c.poly([(9, 13), (11, 4), (13, 13)], GOLD); c.pt(11, 4, WHITE)     # tumpeng
    c.line(10, 8, 11, 6, GOLD_L)
    for x, y, col in [(4, 11, RED), (6, 12, WHITE), (16, 11, RED), (15, 12, WHITE), (18, 12, GOLD)]:
        c.pt(x, y, col); c.pt(x + 1, y, col)
    c.ell(5, 9, 8, 12, LEAF_D)                                         # young coconut
    c.rect(14, 10, 17, 11, GOLD)                                       # bananas
    c.poly([(1, 9), (3, 7), (5, 9), (3, 11)], JANUR); c.pt(3, 9, JANUR_D)   # ketupat / janur
    c.line(19, 9, 20, 5, JANUR); c.line(20, 5, 22, 7, JANUR)
    c.poly([(22, 17), (31, 17), (29, 20), (24, 20)], RED)              # little boat
    c.line(22, 17, 31, 17, GOLD)
    c.line(26, 9, 26, 16, WOOD_D)
    c.poly([(27, 9), (30, 10), (27, 12)], WHITE); c.poly([(25, 11), (23, 12), (25, 13)], RED)
    return c


def bakau_tide_mark():  # mangrove roots with old high-water stains and a rotted mooring ring
    c = C(28, 26)
    c.ell(0, 19, 27, 25, WATER); c.line(3, 21, 22, 21, WATER_L)
    c.rect(11, 0, 15, 18, ROOT); c.rect(11, 0, 11, 18, ROOT_L); c.rect(15, 0, 15, 18, ROOT_D)
    for x0, x1 in [(1, 12), (4, 12), (26, 15), (22, 15)]:     # arching prop roots
        top = 9 if x0 in (1, 26) else 12
        c.line(x0, 22, (x0 + x1) // 2, top, ROOT_D)
        c.line((x0 + x1) // 2, top, x1, top - 3, ROOT_D)
        c.line(x0 + (1 if x0 < x1 else -1), 22, (x0 + x1) // 2 + (1 if x0 < x1 else -1), top, ROOT)
    c.rect(10, 6, 16, 7, STAIN); c.pt(4, 12, STAIN); c.pt(23, 12, STAIN)   # old high-water band
    c.ell(16, 11, 21, 16, RUST_C); c.ell(17, 12, 20, 15, (0, 0, 0, 0)); c.pt(17, 12, RUST_L)
    return c


# ------------------------------------------------------------------------------------------------ Gua Kala
def pasir_sand_stream():  # a cracked ledge letting a thin stream of sand fall into a cone
    c = C(22, 34)
    _shadow(c, 0, 21, 33)
    stone_slab(c, 0, 0, 5, 32)                       # rock wall
    stone_slab(c, 0, 0, 15, 5)                       # ledge
    c.line(11, 5, 13, 2, STONE_D); c.line(2, 12, 4, 18, STONE_D)
    c.ell(6, 26, 21, 32, SAND_D)
    c.poly([(7, 30), (13, 23), (20, 30)], SAND)
    c.line(13, 23, 16, 29, SAND_D)
    return c


def _post_sand_stream(im):
    for y in range(6, 24):
        im.putpixel((13, y + 1), BONE if y % 5 == 0 else SAND)
    glow(im, [(12, 22), (14, 22), (11, 23), (15, 23)], K("D8B27A70"))


def sqv1_offerings():  # small ruwatan offerings: flowers on banana leaf, a little cone, folded cradle cloths (VERIFY)
    c = C(28, 18)
    _shadow(c, 1, 26, 17)
    c.ell(1, 8, 16, 16, LEAF_D); c.ell(2, 8, 15, 14, LEAF)
    c.poly([(6, 12), (8, 5), (10, 12)], WHITE)                         # little cone of rice
    for x, y, col in [(3, 10, RED), (4, 12, WHITE), (12, 10, RED), (13, 12, GOLD), (11, 11, WHITE)]:
        c.pt(x, y, col); c.pt(x + 1, y, col)
    for i, (col, dk) in enumerate([(CLOTH, INK), (INDIGO, INDIGO_L)]):  # folded batik cloths
        y = 12 - i * 3
        c.rect(17, y, 26, y + 3, col); c.rect(17, y, 26, y, CLOTH_L if i == 0 else INDIGO_L)
        for x in range(18, 26, 3):
            c.pt(x, y + 2, GOLD)
    return c


def hutan_stone_chimes():  # petrified frame with stone chimes on cords, faintly lit
    c = C(26, 30)
    _shadow(c, 1, 24, 29)
    c.rect(2, 2, 3, 28, PETRI); c.rect(22, 2, 23, 28, PETRI)
    c.rect(2, 2, 2, 28, STONE_L)
    c.rect(1, 2, 24, 4, PETRI_D); c.line(1, 2, 24, 2, PETRI)
    for x, ln in [(6, 6), (10, 9), (14, 5), (18, 8)]:
        c.line(x + 1, 5, x + 1, 4 + ln, BONE_D)
        stone_slab(c, x, 5 + ln, x + 2, 11 + ln, PETRI)
    return c


def _post_chimes(im):
    pts = []
    for x, ln in [(6, 6), (10, 9), (14, 5), (18, 8)]:
        pts += [(x - 1, 7 + ln), (x + 3, 9 + ln), (x + 1, 12 + ln)]
    glow(im, pts)


def _print(c, x, y, col):
    c.rect(x, y, x + 1, y, col)                      # toes
    c.rect(x, y + 2, x + 1, y + 3, col)              # sole


def bridge_footprints():  # a causeway slab with the faint prints of everyone who crossed
    c = C(32, 16)
    stone_slab(c, 0, 2, 31, 14, STONE_D)
    c.line(0, 2, 31, 2, STONE)
    for x in (8, 16, 24):
        c.line(x, 3, x - 1, 14, INK)
    for i, x in enumerate(range(2, 29, 4)):         # newest trail, glowing
        _print(c, x, 4 if i % 2 else 7, FADE)
    for i, x in enumerate(range(4, 28, 5)):         # older trails, nearly gone
        _print(c, x, 10 if i % 2 else 9, VOID_L)
    return c


def pelataran_ancestor_pillars():  # three black-stone pillars with names cut in them
    c = C(30, 32)
    _shadow(c, 1, 28, 31)
    for x0, top in [(1, 6), (11, 1), (21, 8)]:
        c.rect(x0, top, x0 + 7, 30, BLACK)
        c.rect(x0, top, x0 + 7, top + 1, BLACK_L); c.rect(x0, top, x0, 30, BLACK_L)
        c.rect(x0 + 7, top + 2, x0 + 7, 30, BLACK_D)
        for y in range(top + 4, 28, 4):              # cut name marks
            c.line(x0 + 2, y, x0 + 4, y, FADE)
            c.pt(x0 + 5, y - 1, FADE)
            c.pt(x0 + 3, y + 1, FADE)
    return c


def pelataran_siege_line():  # sharpened stakes, a dark trench and scorched ground
    c = C(34, 22)
    c.ell(0, 13, 33, 21, SCORCH)
    c.ell(3, 14, 30, 19, ASH_D)
    c.rect(2, 16, 31, 17, VOID)
    for i, x in enumerate(range(3, 31, 5)):
        lean = 2 if i % 2 else -1
        c.line(x, 15, x + lean, 4 + i % 3, WOOD); c.line(x + 1, 15, x + 1 + lean, 4 + i % 3, WOOD_D)
        c.pt(x + lean, 3 + i % 3, WOOD_L)
        if i in (1, 4):
            c.line(x, 12, x + lean, 7, SCORCH)
    for x, y in [(6, 19), (20, 20), (27, 18)]:
        c.pt(x, y, FLAME)
    return c


DEPTH = [gerbang_lintel, herd_brand, waterhole_hoofprints, ladang_dry_furrow, wreck_hull_marks, shore_tide_line,
         tebing_stair_rail, nelayan_nets, nelayan_racks, nelayan_sedekah, bakau_tide_mark, pasir_sand_stream,
         sqv1_offerings, hutan_stone_chimes, bridge_footprints, pelataran_ancestor_pillars, pelataran_siege_line]
POST = {"pasir_sand_stream": _post_sand_stream, "hutan_stone_chimes": _post_chimes}


def main():
    for fn in DEPTH:
        im = fn().out()
        if fn.__name__ in POST:
            POST[fn.__name__](im)
        px.save(im, f"story/{fn.__name__}.png")
    print("wrote", len(DEPTH), "depth story sprites")


if __name__ == "__main__":
    main()
