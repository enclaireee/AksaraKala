#!/usr/bin/env python3
"""Story props for Acts II-VI (Keraton Galuh, Mataram, Tanah Timur, Segara Kidul, Gua Kala) plus the checkpoint shrine
(petilasan, one per region) and the shortcut gates. Merged into gen_story_props.STORY, so run
`python3 tools/gen_story_props.py` (this file is imported by its main()).
Ids are the zone legends' clue_id / codex_id / trigger_id; gates are `gate_<id without sc:>`, shrines `petilasan_<region>`.
Sprites are drawn bottom-centre (origin = feet) except gates, which fill their 16x16 tile.
"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gen_story_props import *  # noqa: F401,F403  (palette, C, post, K, WOOD...)

CLOTH, CLOTH_L = K("7D2B40"), K("B84A62")
INDIGO, INDIGO_L = K("2E3F73"), K("5B72B0")
SAND, SAND_D = K("D8B27A"), K("B08A52")
ASH, ASH_D = K("5A5560"), K("3A3640")
BONE, BONE_D = K("E8E2CC"), K("B8B096")
BRONZE, BRONZE_D = K("B8863A"), K("7A5A24")
SEAGREEN = K("3F9E8A")
VOID, VOID_L = K("1B1426"), K("3B2A55")
FADE = K("C9B8E8")   # faded aksara glow
IRON, IRON_D = K("6A6E78"), K("3E4048")


# ------------------------------------------------------------------------------------------------ parts
def table(c, x0, x1, y):
    c.rect(x0, y, x1, y + 2, WOOD)
    c.rect(x0, y, x1, y, WOOD_L)
    c.rect(x0 + 1, y + 3, x0 + 2, y + 8, WOOD_D)
    c.rect(x1 - 2, y + 3, x1 - 1, y + 8, WOOD_D)


def leaf(c, x0, y0, x1, y1, glyph=None, ink=INK):
    """A lontar leaf / strip; glyph is a tiny stroke pattern name."""
    c.rect(x0, y0, x1, y1, PAPER)
    c.rect(x0, y0, x1, y0, WHITE)
    c.rect(x0, y1, x1, y1, PAPER_D)
    mx, my = (x0 + x1) // 2, (y0 + y1) // 2
    if glyph == "ka":
        c.rect(mx - 2, my - 1, mx - 1, my + 1, ink); c.line(mx, my, mx + 2, my, ink)
    elif glyph == "line":
        c.line(x0 + 2, my, x1 - 2, my, ink)
    elif glyph == "lines":
        for y in range(y0 + 2, y1, 2):
            c.line(x0 + 2, y, x1 - 2, y, ink)
    elif glyph == "scrape":
        c.line(x0 + 1, y0 + 1, x1 - 1, y1 - 1, PAPER_D); c.line(x0 + 1, y1 - 1, x1 - 1, y0 + 1, PAPER_D)


def stone_slab(c, x0, y0, x1, y1, face=STONE):
    c.rect(x0, y0, x1, y1, face)
    c.rect(x0, y0, x1, y0, STONE_L)
    c.rect(x0, y0, x0, y1, STONE_L)
    c.rect(x1 - 1, y0 + 1, x1, y1, STONE_D)


def candle(c, x, y, h=4):
    c.rect(x, y, x, y + h, WHITE)
    c.pt(x, y - 1, FLAME); c.pt(x, y - 2, FLAME_L)


def basket(c, x, y, w=10, h=7, col=BAMBOO):
    c.ell(x, y, x + w, y + h * 2 - 2, BAMBOO_D)
    c.rect(x, y + h - 2, x + w, y + h, col)
    c.ell(x, y, x + w, y + 4, col)
    for i in range(x + 2, x + w, 3):
        c.line(i, y + 3, i, y + h, BAMBOO_D)


def footprints(c, spots, col=ASH_D, size=3):
    for x, y in spots:
        c.ell(x, y, x + size, y + size + 2, col)
        c.rect(x, y - 1, x + size, y - 1, col)


def shell(c, x, y, col=WHITE):
    c.poly([(x, y + 3), (x + 2, y), (x + 5, y), (x + 7, y + 3), (x + 3, y + 5)], col)
    c.line(x + 3, y, x + 3, y + 4, BONE_D)


def mask_shape(c, ox, oy, which="whole"):
    """Hunter's blank mask; which: left half, right half, whole, or crack"""
    pts = [(3, 0), (14, 0), (16, 7), (13, 17), (9, 19), (5, 17), (2, 7)]
    full = [(ox + x, oy + y) for x, y in pts]
    if which == "left":
        c.poly([(ox + 3, oy), (ox + 9, oy), (ox + 9, oy + 19), (ox + 5, oy + 17), (ox + 2, oy + 7)], MASK)
    elif which == "right":
        c.poly([(ox + 9, oy), (ox + 14, oy), (ox + 16, oy + 7), (ox + 13, oy + 17), (ox + 9, oy + 19)], MASK)
    else:
        c.poly(full, MASK)
    c.line(ox + 3, oy, ox + 14, oy, WHITE)
    if which == "whole":
        c.line(ox + 9, oy + 1, ox + 8, oy + 7, MASK_D)
    c.rect(ox + 12, oy + 3, ox + 14, oy + 8, MASK_D)


def glow_letter(c, ox, oy, kind):
    """A faded floating Aksara letter inside a pale halo (ra / sa / la)."""
    c.ell(ox - 2, oy - 2, ox + 17, oy + 19, K("C9B8E830"))
    c.ell(ox + 1, oy + 1, ox + 14, oy + 16, K("C9B8E850"))
    if kind == "ra":
        c.rect(ox + 5, oy + 3, ox + 6, oy + 14, FADE); c.rect(ox + 6, oy + 3, ox + 10, oy + 4, FADE)
        c.rect(ox + 10, oy + 4, ox + 11, oy + 8, FADE); c.rect(ox + 7, oy + 8, ox + 10, oy + 9, FADE)
    elif kind == "sa":
        c.rect(ox + 4, oy + 4, ox + 11, oy + 5, FADE); c.rect(ox + 4, oy + 5, ox + 5, oy + 9, FADE)
        c.rect(ox + 4, oy + 9, ox + 11, oy + 10, FADE); c.rect(ox + 10, oy + 10, ox + 11, oy + 14, FADE)
        c.rect(ox + 4, oy + 14, ox + 11, oy + 15, FADE)
    else:  # la
        c.rect(ox + 5, oy + 3, ox + 6, oy + 14, FADE); c.rect(ox + 6, oy + 13, ox + 11, oy + 14, FADE)
        c.rect(ox + 10, oy + 8, ox + 11, oy + 13, FADE); c.rect(ox + 6, oy + 7, ox + 10, oy + 8, FADE)
    for x, y in ((ox + 1, oy + 3), (ox + 14, oy + 12), (ox + 3, oy + 16)):
        c.pt(x, y, WHITE)


def lamp_post(c, x, ytop, ybot, glow=FLAME_L):
    post(c, x, ytop + 4, ybot)
    c.rect(x - 2, ytop, x + 3, ytop + 1, WOOD_D)
    c.rect(x - 2, ytop + 2, x + 3, ytop + 7, BRONZE)
    c.rect(x - 1, ytop + 3, x + 2, ytop + 6, glow)


# ------------------------------------------------------------------------------------------------ Gua Kala
def name_trees():  # three bare trees whispering, name-shapes carved in the bark
    c = C(34, 34)
    for x, h in ((4, 22), (15, 28), (26, 20)):
        c.rect(x, 33 - h, x + 3, 33, K("3A3040"))
        c.rect(x, 33 - h, x, 33, K("4F4560"))
        c.poly([(x - 4, 33 - h + 6), (x + 1, 33 - h), (x + 2, 33 - h + 6)], K("3A3040"))
        c.poly([(x + 5, 33 - h + 4), (x + 2, 33 - h - 2), (x + 3, 33 - h + 4)], K("3A3040"))
        c.rect(x + 1, 33 - h + 9, x + 2, 33 - h + 14, FADE)
    c.pt(10, 6, FADE); c.pt(22, 3, FADE); c.pt(31, 8, FADE)
    return c


def bridge_echo():  # name-stones in a row, faint glints
    c = C(40, 20)
    for i, x in enumerate((2, 10, 18, 26, 33)):
        h = 11 + (i % 2) * 3
        stone_slab(c, x, 19 - h, x + 5, 19, STONE)
        c.rect(x + 2, 19 - h + 3, x + 3, 19 - h + 7, FADE)
    c.ell(0, 17, 39, 19, K("1B142660"))
    return c


def letter_la(): c = C(20, 22); glow_letter(c, 2, 2, "la"); return c
def letter_ra(): c = C(20, 22); glow_letter(c, 2, 2, "ra"); return c
def letter_sa(): c = C(20, 22); glow_letter(c, 2, 2, "sa"); return c


def semar_tale():  # a tale stone: carved panel with a small round-bellied figure
    c = C(24, 28)
    c.ell(2, 22, 21, 27, STONE_D)
    stone_slab(c, 3, 3, 20, 24)
    c.ell(9, 7, 15, 12, SAND); c.ell(8, 12, 16, 20, K("2A2030"))
    c.rect(10, 8, 11, 9, INK); c.rect(13, 8, 14, 9, INK)
    c.line(7, 15, 4, 18, STONE_D); c.line(17, 15, 20, 18, STONE_D)
    return c


def semar_kelir():  # a small leather-puppet screen with Semar's shadow
    c = C(30, 30)
    post(c, 3, 3, 28); post(c, 25, 3, 28)
    c.rect(3, 2, 26, 3, WOOD_D)
    c.rect(5, 5, 24, 22, K("F4E9C4")); c.rect(5, 5, 24, 5, WHITE)
    c.ell(11, 8, 18, 14, K("2A1D26")); c.ell(9, 13, 20, 22, K("2A1D26"))
    c.line(8, 16, 5, 20, K("2A1D26")); c.line(21, 16, 24, 20, K("2A1D26"))
    c.rect(2, 27, 27, 29, WOOD_D)
    c.rect(13, 24, 16, 26, GOLD)
    return c


def lc6_lontar():  # Laras's lontar fragment, ember-edged
    c = C(24, 18)
    c.ell(2, 12, 21, 17, STONE_D)
    leaf(c, 3, 4, 20, 13, "lines")
    c.rect(4, 5, 7, 7, INK)
    c.pt(3, 4, FLAME); c.pt(20, 13, FLAME); c.pt(19, 13, FLAME_L)
    return c


def eclipse_veil():  # black curtain of eclipse with a pale ring edge
    c = C(48, 40)
    c.ell(2, 2, 45, 38, K("1B142690"))
    c.ell(9, 6, 38, 34, K("3B2A55C0"))
    c.ell(14, 10, 33, 30, K("0E0A18E0"))
    for a, b in ((8, 8), (38, 12), (10, 30), (36, 31)):
        c.pt(a, b, FADE)
    return c


def ward_inscription():  # time-ward stone ring with an hourglass mark
    c = C(28, 28)
    c.ell(1, 18, 26, 27, STONE_D)
    stone_slab(c, 6, 3, 21, 24)
    c.poly([(10, 7), (17, 7), (14, 13), (17, 19), (10, 19), (13, 13)], FADE)
    c.rect(11, 8, 16, 8, VOID); c.rect(11, 18, 16, 18, SAND)
    return c


def batara_kala():  # fanged guardian relief face
    c = C(26, 26)
    c.ell(1, 20, 24, 25, STONE_D)
    stone_slab(c, 3, 2, 22, 22)
    c.ell(7, 6, 11, 10, WHITE); c.ell(14, 6, 18, 10, WHITE)
    c.rect(9, 8, 9, 8, INK); c.rect(16, 8, 16, 8, INK)
    c.rect(7, 13, 18, 16, INK)
    c.poly([(7, 13), (9, 18), (11, 13)], BONE); c.poly([(14, 13), (16, 18), (18, 13)], BONE)
    c.line(7, 5, 11, 3, STONE_D); c.line(14, 3, 18, 5, STONE_D)
    return c


def ruwatan():  # ruwatan offering stand: white cloth, flowers, small lamp
    c = C(26, 26)
    table(c, 2, 23, 12)
    c.rect(4, 6, 21, 11, WHITE); c.rect(4, 6, 21, 6, K("FFFFFF"))
    c.rect(5, 8, 20, 8, MASK_D)
    for x, col in ((6, RED), (9, GOLD), (17, RED), (20, GOLD)):
        c.rect(x, 4, x + 1, 5, col)
    c.rect(11, 3, 14, 5, BRONZE); c.pt(12, 2, FLAME); c.pt(13, 2, FLAME_L)
    return c


def kala_exit():  # the way out of the cave: a pale split in the dark, carved lintel
    c = C(64, 32)
    c.rect(2, 4, 61, 7, STONE_D)
    c.rect(2, 4, 61, 4, STONE_L)
    c.rect(2, 7, 7, 31, STONE_D); c.rect(56, 7, 61, 31, STONE_D)
    c.ell(8, 8, 55, 34, K("FFE9A860"))
    c.ell(14, 10, 49, 32, K("FFF3C8A0"))
    c.ell(22, 14, 41, 32, K("FFFFFFC0"))
    return c


# ------------------------------------------------------------------------------------------------ Keraton Galuh
def galuh():  # Karang Kamulyan site: two stone markers (umpak) in a ring
    c = C(30, 24)
    c.ell(1, 15, 28, 23, MUD_D)
    c.ell(3, 14, 26, 21, K("4F8A3C"))
    for x, h in ((5, 12), (17, 14)):
        stone_slab(c, x, 20 - h, x + 7, 20, STONE)
    c.rect(8, 4, 9, 6, GOLD)
    return c


def g1_decree():  # decree board posted in the alun-alun
    c = C(24, 30)
    post(c, 4, 6, 29); post(c, 18, 6, 29)
    c.rect(2, 2, 21, 18, WOOD_L); c.rect(2, 2, 21, 2, SAND)
    leaf(c, 5, 5, 18, 15, "lines")
    c.rect(10, 12, 13, 15, RED)
    return c


def g1_basket():  # a half-woven basket with the strands left loose
    c = C(24, 20)
    basket(c, 3, 6, 15, 9)
    for i in range(4):
        c.line(14 + i * 2, 8, 20 + i, 2 + i * 2, BAMBOO_D)
    c.line(6, 4, 12, 7, BAMBOO)
    return c


def c1_feathers():  # a few rooster feathers on a stall
    c = C(24, 20)
    c.rect(1, 13, 22, 15, WOOD); c.rect(1, 13, 22, 13, WOOD_L)
    c.rect(3, 16, 4, 19, WOOD_D); c.rect(19, 16, 20, 19, WOOD_D)
    for x, y, col in ((5, 5, RED), (10, 4, GOLD), (15, 6, K("4F8A3C")), (8, 8, RED)):
        c.line(x, y, x + 5, y + 6, col); c.line(x + 1, y, x + 6, y + 6, col)
    return c


def c1_basket():  # a river basket on the bank
    c = C(26, 22)
    c.ell(0, 15, 25, 21, WATER); c.ell(4, 16, 21, 20, WATER_L)
    basket(c, 6, 4, 14, 9)
    c.rect(11, 3, 15, 4, WHITE)
    return c


def laras_hairpin():  # a jewelled hairpin on a cushion
    c = C(22, 16)
    c.rect(2, 8, 19, 13, INDIGO); c.rect(2, 8, 19, 8, INDIGO_L)
    c.line(4, 11, 16, 5, GOLD)
    c.ell(14, 3, 19, 8, TEAL); c.pt(16, 5, WHITE)
    return c


def g2_broom():  # a worn-down broom leaning on a post
    c = C(16, 28)
    post(c, 11, 4, 26)
    c.rect(6, 4, 7, 20, BAMBOO)
    c.poly([(3, 20), (10, 20), (11, 26), (2, 26)], SAND_D)
    for x in (4, 6, 8):
        c.line(x, 21, x - 1, 26, WOOD_D)
    return c


def g2_roll():  # a servants' roll with names scraped
    c = C(22, 16)
    leaf(c, 2, 3, 19, 13, "lines")
    c.rect(8, 4, 13, 12, PAPER_D); c.line(8, 4, 13, 12, INK); c.line(8, 12, 13, 4, INK)
    c.rect(0, 4, 1, 12, WOOD_D); c.rect(20, 4, 21, 12, WOOD_D)
    return c


def kaputren_mirror():  # a mirror covered with a cloth
    c = C(22, 30)
    c.rect(3, 4, 18, 26, GOLD); c.rect(5, 6, 16, 24, K("3A3446"))
    c.poly([(4, 3), (17, 3), (19, 18), (16, 24), (14, 13), (7, 14), (5, 24), (2, 18)], WHITE)
    c.line(10, 4, 10, 16, MASK_D)
    c.rect(7, 27, 14, 29, WOOD)
    return c


def c2_signet():  # a signet ring on a folded cloth
    c = C(18, 14)
    c.rect(1, 7, 16, 12, CLOTH); c.rect(1, 7, 16, 7, CLOTH_L)
    c.ell(5, 3, 12, 10, GOLD); c.ell(7, 5, 10, 8, VOID)
    c.rect(7, 1, 10, 3, RED); c.pt(8, 2, RED_D)
    return c


def palace_crest():  # a gate pillar, crest scraped off
    c = C(18, 34)
    c.rect(3, 3, 14, 32, STONE); c.rect(2, 2, 15, 4, STONE_L)
    c.rect(3, 3, 4, 32, STONE_L); c.rect(13, 4, 14, 32, STONE_D)
    c.ell(5, 10, 12, 18, STONE_L)
    for i in range(5):
        c.line(5, 10 + i * 2, 12, 12 + i * 2, STONE_D)
    c.rect(1, 31, 16, 33, STONE_D)
    return c


def court_portrait():  # a portrait frame, face scraped to bare cloth
    c = C(24, 30)
    c.rect(2, 2, 21, 25, WOOD); c.rect(2, 2, 21, 2, WOOD_L)
    c.rect(4, 4, 19, 23, K("5A3A46"))
    c.rect(7, 16, 16, 23, INDIGO); c.rect(8, 17, 15, 19, GOLD)
    c.ell(8, 6, 15, 15, SAND_D); c.ell(9, 7, 14, 14, K("D8C9A0"))
    c.rect(2, 26, 21, 28, WOOD_D)
    return c


def hunter_mask_2():  # left half behind the throne
    c = C(22, 26)
    c.ell(1, 18, 20, 25, STONE_D); c.ell(3, 19, 18, 24, K("3A3436"))
    mask_shape(c, 2, 2, "left")
    c.rect(1, 9, 2, 12, WOOD_D)
    return c


def pamali():  # river taboo marker: a white-cloth post at the water
    c = C(26, 28)
    c.ell(0, 20, 25, 27, WATER); c.ell(4, 22, 21, 26, WATER_L)
    post(c, 12, 3, 24)
    c.poly([(14, 4), (22, 6), (20, 12), (14, 10)], WHITE)
    c.poly([(10, 8), (3, 10), (5, 15), (10, 13)], WHITE)
    c.rect(8, 22, 16, 23, STONE)
    return c


def sumarto_show():  # the travelling puppeteer's trunk and rolled screen
    c = C(32, 26)
    c.rect(2, 14, 20, 24, WOOD); c.rect(2, 14, 20, 15, WOOD_L)
    c.rect(2, 19, 20, 19, WOOD_D); c.rect(10, 17, 12, 21, GOLD)
    c.rect(22, 3, 26, 24, K("F4E9C4")); c.rect(22, 3, 22, 24, WHITE); c.rect(26, 3, 26, 24, PAPER_D)
    c.ell(21, 1, 27, 5, K("F4E9C4")); c.ell(21, 22, 27, 26, K("F4E9C4"))
    c.line(5, 8, 10, 12, WOOD_D); c.line(8, 6, 13, 12, WOOD_D)
    return c


def hariang_letters():  # a bundle of sealed letters tied with cord
    c = C(24, 18)
    for dx in (0, 3, 6):
        c.rect(3 + dx, 4 + dx // 2, 16 + dx, 14 + dx // 2, PAPER if dx != 3 else WHITE)
        c.rect(3 + dx, 4 + dx // 2, 16 + dx, 4 + dx // 2, WHITE)
    c.rect(11, 3, 12, 16, RED); c.rect(5, 9, 21, 10, RED_D)
    c.ell(10, 8, 13, 11, RED)
    return c


def wagon_manifest():  # a manifest board hung on the storehouse wall
    c = C(26, 24)
    c.rect(1, 2, 24, 20, WOOD); c.rect(1, 2, 24, 2, WOOD_L)
    leaf(c, 3, 4, 22, 17, "lines")
    c.rect(15, 14, 20, 16, RED)
    c.rect(11, 0, 14, 2, IRON)
    return c


def g1_debt_ledger():  # thick ledger with coin
    c = C(24, 18)
    c.rect(2, 4, 21, 15, INDIGO); c.rect(2, 4, 21, 4, INDIGO_L)
    c.rect(3, 6, 20, 14, PAPER); c.rect(11, 5, 12, 15, PAPER_D)
    c.line(5, 9, 10, 9, INK); c.line(14, 9, 19, 9, INK); c.line(5, 12, 10, 12, INK)
    c.ell(16, 11, 21, 16, GOLD); c.ell(17, 12, 20, 15, GOLD_L)
    return c


def g1_palm_sack():  # Kabayan's sack of palm sugar
    c = C(20, 22)
    c.poly([(4, 8), (15, 8), (17, 20), (2, 20)], K("B59A4E"))
    c.poly([(5, 4), (14, 4), (15, 8), (4, 8)], K("8A7032"))
    c.rect(4, 8, 15, 9, WOOD_D)
    c.line(9, 12, 9, 18, K("8A7032")); c.line(5, 14, 14, 15, K("8A7032"))
    c.rect(10, 5, 14, 6, K("B58228"))
    return c


def pamali_cage():  # the iron cage of the legend
    c = C(28, 30)
    c.rect(2, 3, 25, 4, IRON_D); c.rect(2, 26, 25, 28, IRON_D)
    for x in range(4, 25, 4):
        c.rect(x, 4, x, 26, IRON); c.rect(x + 1, 4, x + 1, 26, IRON_D)
    c.rect(2, 14, 25, 15, IRON_D)
    c.rect(11, 0, 15, 3, IRON)
    c.rect(12, 20, 15, 25, SAND_D)
    return c


def laras_wall():  # scratched words on a dungeon wall
    c = C(32, 26)
    c.rect(1, 2, 30, 24, STONE_D); c.rect(1, 2, 30, 2, STONE)
    for y in (6, 11, 16):
        for x in range(4, 28, 3):
            if (x + y) % 5:
                c.pt(x, y, STONE_L); c.pt(x + 1, y, STONE_L)
    c.rect(4, 18, 26, 18, STONE_L)
    c.rect(24, 8, 26, 10, TEAL)
    return c


def wagon_ruts():  # two parallel ruts down steps
    c = C(32, 22)
    for i in range(4):
        c.rect(1, 3 + i * 5, 30, 5 + i * 5, STONE_D)
        c.rect(1, 3 + i * 5, 30, 3 + i * 5, STONE_L)
    c.line(9, 0, 7, 21, MUD_D); c.line(10, 0, 8, 21, MUD)
    c.line(21, 0, 19, 21, MUD_D); c.line(22, 0, 20, 21, MUD)
    return c


def scraped_genealogy():  # a lontar scroll with names rasped out
    c = C(30, 18)
    leaf(c, 3, 4, 26, 14, "lines")
    c.rect(8, 5, 14, 13, PAPER_D); c.rect(18, 5, 22, 13, PAPER_D)
    c.line(8, 5, 14, 13, WOOD_D); c.line(9, 13, 14, 5, WOOD_D)
    c.rect(0, 5, 2, 13, WOOD_D); c.rect(27, 5, 29, 13, WOOD_D)
    return c


# ------------------------------------------------------------------------------------------------ Mataram
def c3_camp_scrap():  # stitched syllable scrap on a stake
    c = C(18, 28)
    c.rect(8, 6, 9, 26, WOOD); c.rect(8, 6, 8, 26, WOOD_L)
    c.rect(6, 25, 11, 27, STONE)
    c.rect(2, 8, 14, 17, PAPER); c.rect(2, 8, 14, 8, WHITE)
    c.line(3, 11, 12, 11, TEAL); c.line(3, 14, 9, 14, TEAL)
    c.pt(13, 9, TEAL_D)
    return c


def rubble():  # rubble with chisel marks and ghost hand-prints
    c = C(30, 22)
    for x, y, w, h in ((2, 10, 10, 9), (11, 6, 11, 13), (20, 12, 8, 7), (7, 14, 8, 7)):
        stone_slab(c, x, y, x + w, y + h, STONE if (x + y) % 2 else K("A09B90"))
    c.line(13, 8, 17, 8, STONE_D); c.line(14, 11, 19, 11, STONE_D)
    for x, y in ((6, 13), (23, 14)):
        c.rect(x, y, x + 3, y + 3, K("DDF0FF90"))
    return c


def lesung_mid():  # a lesung trough with the pestles left mid-stroke
    c = C(34, 26)
    c.rect(2, 14, 31, 22, WOOD_D); c.rect(2, 14, 31, 15, WOOD)
    c.rect(4, 16, 29, 20, K("3A2A1A")); c.rect(6, 17, 27, 19, SAND)
    for x, lean in ((8, -1), (22, 1)):
        c.line(x, 2, x + lean * 5, 17, WOOD); c.line(x + 1, 2, x + 1 + lean * 5, 17, WOOD_L)
    c.rect(5, 22, 7, 25, WOOD_D); c.rect(26, 22, 28, 25, WOOD_D)
    return c


def ka_strip():  # Laras's Ka strip stuck to a post
    c = C(16, 26)
    post(c, 7, 4, 24)
    leaf(c, 2, 6, 13, 17, "ka")
    c.rect(5, 24, 10, 25, STONE)
    return c


def lc3_lontar():
    return lc6_lontar()


def k3_lesung():  # lesung rhythm still sounding: lesung with sound arcs
    c = lesung_mid()
    out = C(34, 32)
    out.im.alpha_composite(c.im, (0, 6))
    for r in (4, 7, 10):
        out.d.arc([17 - r, 6 - r, 17 + r, 6 + r], 200, 340, fill=K("F2B84B"))
    return out


def gapura():  # split stone gate (candi bentar), codex spot
    c = C(36, 34)
    for x0, sh in ((2, 0), (21, 1)):
        c.poly([(x0, 32), (x0 + 3, 20), (x0 + 2, 10), (x0 + 6, 3), (x0 + 12, 3), (x0 + 13, 10), (x0 + 12, 20), (x0 + 13, 32)],
               STONE)
        c.rect(x0 + 3, 4, x0 + 5, 31, STONE_L)
        c.rect(x0 + 10, 5, x0 + 12, 31, STONE_D)
        for y in (9, 16, 23):
            c.rect(x0 + 4, y, x0 + 11, y, STONE_D)
    c.rect(1, 31, 34, 33, STONE_D)
    return c


def c4_roll_a():  # muster roll, north
    c = C(24, 18)
    leaf(c, 2, 3, 21, 14, "lines")
    c.rect(14, 5, 19, 7, RED); c.pt(2, 3, INK)
    c.rect(0, 4, 1, 13, WOOD_D); c.rect(22, 4, 23, 13, WOOD_D)
    return c


def c4_roll_b():
    c = c4_roll_a()
    c.rect(14, 5, 19, 7, INDIGO); c.rect(14, 11, 19, 12, RED)
    return c


def hunter_mask_3():  # right half in the graves
    c = C(22, 26)
    c.ell(1, 18, 20, 25, MUD_D); c.ell(3, 19, 18, 24, MUD)
    mask_shape(c, 2, 2, "right")
    for x in (3, 18):
        c.rect(x, 21, x, 23, LEAF_D)
    return c


def gamelan():  # gamelan: gong on frame and a bronze saron
    c = C(38, 30)
    post(c, 4, 3, 27); post(c, 22, 3, 27)
    c.rect(3, 2, 25, 3, WOOD_D)
    c.ell(6, 6, 20, 21, BRONZE); c.ell(8, 8, 18, 19, BRONZE_D); c.ell(10, 11, 16, 17, GOLD)
    c.rect(28, 17, 36, 22, WOOD); c.rect(28, 17, 36, 17, WOOD_L)
    for i, x in enumerate((29, 31, 33, 35)):
        c.rect(x, 12 + (i % 2), x, 17, BRONZE)
    c.rect(28, 23, 29, 28, WOOD_D); c.rect(35, 23, 36, 28, WOOD_D)
    return c


def m3_footprints():  # tiny ash footprints in a hearth
    c = C(26, 20)
    c.ell(1, 4, 24, 19, STONE_D); c.ell(3, 5, 22, 17, ASH)
    footprints(c, [(7, 8), (11, 12), (15, 7), (18, 11)], K("2A2630"), 2)
    return c


def m3_beans():  # green beans spilled by a stall
    c = C(26, 18)
    c.rect(1, 10, 11, 12, WOOD); c.rect(1, 10, 11, 10, WOOD_L)
    c.rect(2, 13, 3, 17, WOOD_D); c.rect(9, 13, 10, 17, WOOD_D)
    for x, y in ((13, 12), (16, 14), (19, 11), (21, 14), (15, 9), (18, 16), (11, 15), (23, 12)):
        c.ell(x, y, x + 2, y + 1, K("78B24A")); c.pt(x, y, K("A8D870"))
    return c


def m2_toy():  # dropped wooden toy top and string
    c = C(18, 14)
    c.poly([(3, 5), (13, 5), (10, 12), (6, 12)], WOOD_L)
    c.rect(3, 3, 13, 5, RED); c.rect(7, 0, 8, 3, WOOD_D)
    c.line(11, 11, 17, 13, TEAL)
    return c


def candi_seribu():  # model of the thousand-temple: stepped shrine
    c = C(34, 30)
    for i, (x0, y0) in enumerate(((3, 22), (7, 16), (11, 10), (14, 5))):
        c.rect(x0, y0, 33 - x0, y0 + 5, STONE if i % 2 else STONE_L)
        c.rect(x0, y0, 33 - x0, y0, STONE_L); c.rect(x0, y0 + 5, 33 - x0, y0 + 5, STONE_D)
    c.poly([(15, 5), (17, 0), (19, 5)], GOLD)
    c.rect(15, 24, 18, 28, INK)
    return c


def roro_jonggrang():  # statue of a woman with offering, slender
    c = C(22, 32)
    c.rect(2, 28, 19, 31, STONE_D)
    c.rect(7, 12, 14, 28, STONE); c.rect(7, 12, 8, 28, STONE_L)
    c.ell(7, 3, 14, 11, STONE_L); c.rect(6, 1, 15, 3, GOLD)
    c.line(5, 14, 7, 20, STONE); c.line(16, 14, 14, 20, STONE)
    c.rect(2, 4, 3, 7, GOLD); c.rect(17, 4, 18, 7, GOLD)
    return c


def arca():  # a seated stone statue
    c = C(26, 30)
    c.rect(2, 26, 23, 29, STONE_D)
    c.rect(5, 20, 20, 26, STONE)
    c.rect(8, 10, 17, 21, STONE); c.rect(8, 10, 9, 21, STONE_L); c.rect(16, 11, 17, 21, STONE_D)
    c.ell(9, 3, 16, 10, STONE_L)
    c.rect(11, 6, 11, 6, INK); c.rect(14, 6, 14, 6, INK)
    c.rect(10, 1, 15, 3, STONE_D)
    return c


def ka_chalk():  # a chalked Ka on a courtyard wall
    c = C(26, 24)
    c.rect(1, 2, 24, 22, STONE_D); c.rect(1, 2, 24, 2, STONE)
    c.rect(8, 7, 10, 16, WHITE); c.rect(10, 7, 15, 8, WHITE)
    c.rect(14, 8, 15, 12, WHITE); c.line(10, 12, 16, 15, WHITE)
    return c


def gejog_lesung():  # long festival lesung with seven pestles laid on it
    c = C(40, 24)
    c.rect(1, 12, 38, 20, WOOD_D); c.rect(1, 12, 38, 13, WOOD)
    c.rect(3, 14, 36, 18, K("3A2A1A"))
    for x in range(5, 36, 6):
        c.ell(x, 14, x + 3, 17, SAND)
    c.rect(4, 20, 6, 23, WOOD_D); c.rect(33, 20, 35, 23, WOOD_D)
    c.line(6, 3, 30, 12, WOOD_L); c.line(10, 2, 33, 12, WOOD)
    return c


def m1_pot_lid():  # a cooking pot with its lid lifted
    c = C(24, 20)
    c.ell(3, 7, 20, 18, IRON_D); c.rect(3, 9, 20, 14, IRON); c.rect(3, 9, 20, 9, IRON_D)
    c.rect(2, 8, 4, 9, IRON); c.rect(19, 8, 21, 9, IRON)
    c.ell(9, 0, 18, 6, IRON_D); c.rect(11, 0, 15, 1, IRON)
    c.pt(8, 11, STONE_L)
    return c


def m1_rice_gone():  # an empty grain pit with a few stray grains
    c = C(28, 22)
    c.rect(2, 4, 25, 20, WOOD_D); c.rect(4, 6, 23, 18, K("3A2A1A"))
    c.rect(4, 17, 23, 18, SAND)
    for x, y in ((6, 15), (11, 16), (17, 15), (20, 16)):
        c.pt(x, y, WHITE)
    c.rect(2, 4, 25, 4, WOOD)
    return c


def pillar_prints():  # a fallen pillar and scuff prints
    c = C(36, 22)
    c.rect(3, 6, 30, 15, STONE); c.rect(3, 6, 30, 7, STONE_L)
    c.ell(0, 6, 7, 15, STONE_L); c.ell(1, 8, 5, 13, STONE_D)
    c.rect(3, 14, 30, 15, STONE_D)
    footprints(c, [(8, 17), (13, 18), (19, 17), (25, 18)], MUD_D, 2)
    return c


def genderuwo():  # a hairy shadow in a banyan hollow, red eyes
    c = C(26, 30)
    c.rect(2, 4, 23, 28, K("3A2A1E")); c.rect(2, 4, 3, 28, K("5C432B"))
    c.ell(5, 7, 20, 27, VOID)
    c.ell(8, 11, 17, 24, K("2A1D26"))
    c.pt(10, 15, RED); c.pt(11, 15, RED); c.pt(14, 15, RED); c.pt(15, 15, RED)
    for x in (7, 9, 16, 18):
        c.line(x, 20, x, 25, K("0E0A18"))
    return c


def shrine_chisel():  # foothill shrine steps with fresh chisel dust
    c = C(34, 24)
    for i in range(4):
        c.rect(2 + i * 2, 18 - i * 5, 31 - i * 2, 21 - i * 5, STONE if i % 2 else STONE_L)
        c.rect(2 + i * 2, 18 - i * 5, 31 - i * 2, 18 - i * 5, STONE_L)
    c.rect(12, 6, 20, 8, SAND)
    c.rect(26, 14, 28, 16, K("DDF0FF90"))
    c.pt(9, 15, SAND); c.pt(24, 9, SAND)
    return c


def pasar_stage():  # a small puppet stage in the plaza, roofed
    c = C(48, 40)
    post(c, 4, 10, 38); post(c, 42, 10, 38)
    c.poly([(0, 11), (24, 0), (47, 11)], K("9E5A32"))
    c.poly([(3, 11), (24, 3), (44, 11)], K("B87A4A"))
    c.rect(6, 12, 41, 28, K("F4E9C4")); c.rect(6, 12, 41, 12, WHITE)
    c.ell(14, 15, 20, 22, K("2A1D26")); c.ell(26, 15, 32, 22, K("2A1D26"))
    c.rect(4, 29, 43, 34, WOOD); c.rect(4, 29, 43, 29, WOOD_L)
    c.rect(22, 30, 26, 33, GOLD)
    return c


def tuyul_hideout():  # a hole under a root, small footprints, green beans
    c = C(28, 22)
    c.ell(1, 8, 26, 21, MUD); c.ell(5, 10, 22, 19, VOID)
    c.line(3, 10, 9, 4, WOOD_D); c.line(24, 10, 18, 4, WOOD_D); c.rect(8, 3, 19, 5, WOOD_D)
    c.pt(14, 15, K("78B24A")); c.pt(16, 16, K("78B24A"))
    return c


# ------------------------------------------------------------------------------------------------ Segara Kidul
def k2_scale():  # a white scale in a torn net
    c = C(26, 20)
    for x in range(1, 25, 3):
        c.line(x, 3, x + 2, 17, K("8A7032"))
    for y in range(4, 18, 4):
        c.line(1, y, 25, y + 1, K("8A7032"))
    c.ell(9, 6, 17, 14, WHITE); c.ell(11, 8, 15, 12, MASK_D); c.pt(10, 8, SEAGREEN)
    return c


def gua_bell_marks():  # cave wall with green stains and bronze marks
    c = C(32, 26)
    c.rect(1, 2, 30, 24, STONE_D); c.rect(1, 2, 30, 2, STONE)
    for x in (6, 14, 22):
        c.ell(x, 5, x + 5, 19, K("3F9E8A90"))
        c.rect(x + 1, 14, x + 4, 17, BRONZE)
    return c


def lc5_cavern():  # the sunken bronze bells under water
    c = C(34, 28)
    c.ell(0, 10, 33, 27, K("4A78A8A0")); c.ell(3, 13, 30, 25, K("2A5478A0"))
    for x, y in ((6, 8), (15, 4), (24, 9)):
        c.poly([(x, y + 12), (x + 1, y + 4), (x + 7, y + 4), (x + 8, y + 12)], BRONZE)
        c.rect(x, y + 12, x + 8, y + 13, BRONZE_D); c.rect(x + 3, y + 1, x + 4, y + 3, BRONZE_D)
        c.rect(x + 2, y + 6, x + 3, y + 10, GOLD_L)
    return c


def reef_thread():  # green thread on a rock on a sandbar
    c = C(26, 20)
    c.ell(0, 12, 25, 19, SAND); c.ell(5, 4, 17, 15, STONE); c.ell(6, 5, 12, 10, STONE_L)
    c.line(6, 8, 14, 14, SEAGREEN); c.line(14, 14, 22, 12, SEAGREEN); c.pt(6, 8, TEAL_D)
    return c


def causeway_post():  # mooring post with rope and a dry shell
    c = C(18, 30)
    c.rect(6, 4, 11, 28, WOOD); c.rect(6, 4, 7, 28, WOOD_L); c.rect(10, 4, 11, 28, WOOD_D)
    c.rect(5, 2, 12, 4, WOOD_D)
    for y in (10, 13, 16):
        c.rect(5, y, 12, y, SAND)
    c.line(12, 10, 17, 22, SAND_D)
    shell(c, 2, 24)
    c.rect(4, 28, 13, 29, STONE)
    return c


def nyi_roro_kidul():  # offering niche: green cloth, shells, white flowers
    c = C(30, 30)
    c.ell(1, 24, 28, 29, STONE_D)
    stone_slab(c, 3, 4, 26, 25)
    c.rect(6, 7, 23, 22, K("0F2A24")); c.rect(7, 8, 22, 21, SEAGREEN)
    c.poly([(7, 8), (22, 8), (20, 16), (15, 20), (10, 16)], TEAL_D)
    c.rect(13, 6, 16, 8, GOLD)
    shell(c, 8, 20); shell(c, 17, 20, BONE)
    c.rect(13, 14, 15, 16, WHITE)
    return c


def trial_sign_1():  # a driftwood sign rising from shallows
    c = C(22, 28)
    c.ell(0, 20, 21, 27, WATER); c.ell(3, 22, 18, 26, WATER_L)
    post(c, 10, 4, 24)
    c.rect(3, 4, 18, 12, WOOD_L); c.rect(3, 4, 18, 4, SAND)
    c.rect(6, 7, 7, 10, INK); c.rect(10, 7, 11, 10, INK); c.rect(14, 7, 15, 10, INK)
    return c


def trial_sign_2():
    c = trial_sign_1()
    c.rect(4, 5, 17, 11, WOOD_L)
    c.rect(6, 6, 15, 10, K("3F9E8A80"))
    c.rect(7, 7, 8, 9, INK); c.rect(13, 7, 14, 9, INK); c.line(8, 8, 13, 8, INK)
    return c


def c3_shore_net():  # driftwood token in a shore net
    c = C(28, 18)
    for x in range(1, 27, 4):
        c.line(x, 2, x + 2, 15, K("8A7032"))
    for y in range(3, 16, 4):
        c.line(1, y, 27, y + 1, K("8A7032"))
    c.rect(10, 6, 17, 11, WOOD_L); c.rect(10, 6, 17, 6, SAND); c.rect(12, 8, 15, 8, WOOD_D)
    return c


def _verse(c, tone):
    c.ell(1, 18, 22, 25, STONE_D); c.ell(3, 19, 20, 24, STONE)
    leaf(c, 5, 4, 18, 18, "lines")
    c.rect(11, 5, 12, 17, PAPER_D)
    for x, y in ((3, 10), (20, 8)):
        c.pt(x, y, tone)
    c.ell(7, 10, 10, 13, tone)


def song_1():
    c = C(24, 28); _verse(c, TEAL); return c


def song_2():
    c = C(24, 28); _verse(c, GOLD); return c


def song_3():
    c = C(24, 28); _verse(c, RED); return c


def shrine_tale():  # shrine tablet with carved tale and a lamp
    c = C(28, 32)
    c.rect(1, 28, 26, 31, STONE_D)
    stone_slab(c, 4, 8, 23, 28)
    for i, y in enumerate((11, 15, 19, 23)):
        c.line(7, y, 20 - (i % 2) * 4, y, STONE_D)
    c.rect(11, 3, 16, 7, BRONZE); c.rect(12, 4, 15, 6, FLAME_L); c.pt(13, 2, FLAME)
    return c


def c4_lamp():  # tall ward lamp for the wave
    c = C(20, 36)
    c.ell(0, 0, 19, 17, K("FFE06640"))
    lamp_post(c, 9, 4, 34, FLAME_L)
    c.rect(5, 33, 14, 35, STONE)
    for x in (4, 14):
        c.pt(x, 10, FLAME_L)
    return c


# ------------------------------------------------------------------------------------------------ Tanah Timur
def keris():  # inscribed stone with a keris carved (codex ruin)
    c = C(22, 30)
    c.ell(1, 24, 20, 29, STONE_D)
    stone_slab(c, 4, 3, 17, 26)
    c.line(11, 7, 11, 21, STONE_D); c.line(10, 8, 12, 8, STONE_D)
    c.poly([(9, 21), (11, 24), (13, 21)], STONE_D); c.rect(8, 20, 14, 21, STONE_D)
    return c


def mpu_gandring():  # inscribed stone with a smith's anvil sign
    c = C(22, 30)
    c.ell(1, 24, 20, 29, STONE_D)
    stone_slab(c, 4, 3, 17, 26)
    c.rect(7, 10, 15, 12, STONE_D); c.rect(9, 12, 13, 14, STONE_D); c.rect(8, 15, 14, 16, STONE_D)
    c.rect(15, 8, 16, 11, STONE_D)
    return c


def tengger_lautan_pasir():  # a statue plinth with a sand-worn figure
    c = C(24, 32)
    c.rect(2, 22, 21, 31, STONE_D); c.rect(2, 22, 21, 23, STONE)
    c.rect(4, 20, 19, 22, STONE_L)
    c.rect(9, 6, 14, 20, SAND_D); c.rect(9, 6, 10, 20, SAND)
    c.ell(9, 1, 14, 7, SAND)
    for x, y in ((4, 28), (17, 26), (11, 29)):
        c.pt(x, y, SAND)
    return c


def scabbard():  # a broken scabbard on a vault floor
    c = C(30, 16)
    c.poly([(2, 8), (24, 3), (26, 6), (6, 12)], WOOD_D)
    c.poly([(2, 8), (24, 3), (24, 4), (3, 9)], WOOD_L)
    c.rect(24, 2, 28, 7, GOLD)
    c.poly([(12, 5), (15, 4), (13, 13), (10, 12)], IRON_D)
    return c


def forge_records():  # a ledger of seven marks on a stand
    c = C(26, 28)
    post(c, 12, 14, 26)
    c.rect(2, 4, 23, 15, WOOD); c.rect(2, 4, 23, 4, WOOD_L)
    leaf(c, 4, 6, 21, 13, "lines")
    for x in range(6, 20, 2):
        c.rect(x, 12, x, 13, RED)
    c.rect(7, 26, 18, 27, STONE)
    return c


def banyan_altar():  # a flat stone in a banyan hollow with small handprints
    c = C(30, 28)
    c.rect(1, 2, 28, 26, K("3A2A1E")); c.ell(4, 4, 25, 26, VOID)
    c.rect(4, 18, 25, 23, STONE); c.rect(4, 18, 25, 18, STONE_L)
    for x in (8, 15, 20):
        c.rect(x, 19, x + 3, 22, K("8EC1E0A0"))
    for x in (3, 26):
        c.rect(x, 20, x + 1, 26, LEAF_D)
    return c


def forge_stone():  # the old anvil stone
    c = C(26, 24)
    c.ell(2, 16, 23, 23, STONE_D)
    c.poly([(3, 12), (21, 12), (19, 15), (15, 15), (15, 20), (8, 20), (8, 15), (5, 15)], IRON)
    c.rect(3, 12, 21, 12, STONE_L)
    c.poly([(21, 12), (25, 13), (21, 14)], IRON)
    c.rect(11, 9, 14, 11, FLAME)
    return c


def hunter_mask_4():  # the last fragment where the keris lay
    c = C(22, 26)
    c.ell(1, 18, 20, 25, STONE_D); c.ell(3, 19, 18, 24, K("3A3436"))
    mask_shape(c, 2, 2, "right")
    c.rect(9, 13, 11, 18, IRON_D)
    return c


def mask_joined():  # the whole mask at the shrine door
    c = C(22, 26)
    c.ell(1, 20, 20, 25, STONE_D)
    mask_shape(c, 2, 2, "whole")
    c.rect(1, 9, 2, 12, WOOD_D); c.rect(17, 9, 18, 12, WOOD_D)
    c.pt(8, 5, GOLD); c.pt(13, 5, GOLD)
    return c


def seeds():  # cucumber seeds spilled
    c = C(22, 14)
    c.ell(0, 5, 21, 13, SAND_D)
    for x, y in ((3, 7), (7, 9), (10, 6), (13, 10), (16, 7), (6, 11), (18, 11), (11, 8)):
        c.ell(x, y, x + 2, y + 1, K("E8E2A8")); c.pt(x, y, WHITE)
    return c


def needle_case():  # needle case on river rocks
    c = C(24, 16)
    c.ell(0, 8, 23, 15, STONE_D); c.ell(3, 6, 12, 13, STONE)
    c.rect(11, 4, 20, 9, BAMBOO); c.rect(11, 4, 20, 4, K("D2D87A")); c.rect(10, 5, 11, 8, BAMBOO_D)
    c.line(19, 3, 22, 1, SAND)
    return c


def salt_terasi():  # a salt jar and a pot of terasi
    c = C(26, 20)
    c.rect(2, 16, 23, 18, WOOD); c.rect(2, 16, 23, 16, WOOD_L)
    c.ell(3, 4, 11, 16, WHITE); c.rect(4, 3, 10, 5, MASK_D); c.rect(5, 1, 9, 3, WOOD_D)
    c.ell(13, 8, 22, 16, K("5A2A2A")); c.rect(14, 6, 21, 9, K("3A1A1A")); c.rect(16, 7, 19, 8, K("7A3A3A"))
    return c


def t1_claw_marks():  # claw rakes across a jetty plank
    c = C(34, 20)
    c.rect(1, 8, 32, 17, WOOD); c.rect(1, 8, 32, 8, WOOD_L); c.rect(1, 17, 32, 18, WOOD_D)
    for x in (9, 14, 19, 24):
        c.line(x, 1, x + 5, 19, WOOD_D); c.line(x + 1, 1, x + 6, 19, SAND)
    c.rect(1, 15, 3, 19, WOOD_D)
    return c


def t1_sodo():  # a sodo lanang palm rib in a bundle
    c = C(26, 22)
    c.rect(4, 9, 21, 17, K("B59A4E")); c.rect(4, 9, 21, 9, K("D8B27A"))
    c.rect(6, 8, 8, 18, WOOD_D); c.rect(17, 8, 19, 18, WOOD_D)
    c.line(2, 20, 24, 2, K("7A9A32")); c.line(3, 20, 25, 3, K("A8D870"))
    return c


def doorpost_mark():  # a stall doorpost with a red curse mark
    c = C(16, 34)
    c.rect(4, 3, 11, 32, WOOD); c.rect(4, 3, 5, 32, WOOD_L); c.rect(10, 3, 11, 32, WOOD_D)
    c.rect(2, 2, 13, 4, WOOD_D)
    c.line(6, 11, 9, 20, RED); c.line(9, 11, 6, 20, RED); c.rect(5, 15, 10, 16, RED_D)
    c.rect(3, 31, 12, 33, STONE)
    return c


def ladang_stake():  # a red curse stake in the dry field, name charring
    c = C(16, 30)
    c.ell(1, 24, 14, 29, SAND_D)
    c.poly([(5, 4), (10, 4), (11, 26), (4, 26)], WOOD_D)
    c.rect(5, 4, 5, 26, WOOD)
    c.rect(4, 3, 11, 5, RED); c.rect(6, 10, 9, 12, INK); c.rect(6, 15, 9, 16, INK); c.pt(8, 9, FLAME)
    return c


def t2_burn_trail():  # scorched ring in the grass
    c = C(34, 22)
    c.ell(0, 3, 33, 21, K("4F8A3C"))
    c.ell(3, 5, 30, 19, K("2A2A22")); c.ell(8, 8, 25, 16, K("4F8A3C"))
    for x, y in ((6, 6), (28, 10), (14, 18), (24, 6)):
        c.pt(x, y, FLAME)
    return c


def t2_campfire():  # unlit campsite: ring of stones, cold ash
    c = C(28, 20)
    c.ell(2, 4, 25, 19, STONE_D)
    for x, y in ((3, 8), (9, 4), (17, 4), (23, 9), (20, 15), (7, 15)):
        c.ell(x, y, x + 4, y + 3, STONE)
    c.ell(7, 8, 20, 15, ASH_D)
    c.line(9, 11, 18, 12, WOOD_D)
    return c


def lc4_lontar():
    return lc6_lontar()


def c3_road_mark():  # boundary stone with a faded shield mark
    c = C(20, 26)
    c.ell(1, 20, 18, 25, SAND_D)
    stone_slab(c, 4, 3, 15, 22)
    c.poly([(7, 7), (12, 7), (12, 13), (9, 16), (7, 13)], RED_D)
    c.rect(8, 9, 11, 11, SAND)
    return c


def ash_trail():  # a cold trail of ash in the dust
    c = C(34, 14)
    for x in range(1, 32, 4):
        c.ell(x, 3 + (x // 4) % 3 * 2, x + 5, 8 + (x // 4) % 3 * 2, ASH)
    c.pt(30, 8, ASH_D); c.pt(26, 3, ASH_D)
    return c


def kepang_stage():  # a kuda kepang stage: platform with painted horse
    c = C(48, 36)
    c.rect(2, 26, 45, 32, WOOD); c.rect(2, 26, 45, 26, WOOD_L); c.rect(2, 32, 45, 33, WOOD_D)
    for x in (4, 42):
        c.rect(x, 33, x + 2, 35, WOOD_D)
    for x in (4, 41):
        post(c, x, 6, 26)
    c.rect(3, 4, 44, 8, RED); c.rect(3, 4, 44, 4, CLOTH_L)
    c.rect(6, 8, 41, 9, GOLD)
    c.rect(18, 14, 30, 20, WOOD_L); c.rect(28, 10, 32, 16, WOOD_L); c.pt(30, 12, INK)
    for x in (19, 22, 26, 29):
        c.rect(x, 20, x + 1, 25, WOOD_D)
    return c


# ------------------------------------------------------------------------------------------------ checkpoint shrines
def _shrine_base(c, w, col=STONE, light=STONE_L, dark=STONE_D):
    cx = w // 2
    c.ell(cx - 11, 26, cx + 11, 33, dark)
    c.rect(cx - 9, 24, cx + 8, 29, col)
    c.rect(cx - 9, 24, cx + 8, 24, light)
    c.rect(cx + 6, 25, cx + 8, 29, dark)


def _flame(c, cx, y):
    c.ell(cx - 5, y - 4, cx + 5, y + 5, K("8EC1E040"))
    c.poly([(cx - 2, y + 3), (cx, y - 4), (cx + 2, y + 3)], K("5BB8E8"))
    c.poly([(cx - 1, y + 3), (cx, y - 1), (cx + 1, y + 3)], K("DDF4FF"))


def petilasan_sunda():  # moss stone with a bamboo rail, blue flame
    c = C(32, 38)
    _shrine_base(c, 32)
    c.rect(12, 10, 19, 24, STONE); c.rect(12, 10, 13, 24, STONE_L); c.rect(18, 11, 19, 24, STONE_D)
    c.rect(11, 9, 20, 10, STONE_L)
    c.rect(14, 14, 17, 16, INK)
    for x in (4, 26):
        c.rect(x, 14, x, 28, BAMBOO); c.rect(x + 1, 14, x + 1, 28, BAMBOO_D)
    c.rect(3, 18, 28, 18, BAMBOO_D)
    for x in (9, 21):
        c.ell(x, 24, x + 4, 27, LEAF)
    _flame(c, 16, 5)
    return c


def petilasan_galuh():  # royal lingga stone on a tiered plinth, gold band
    c = C(32, 38)
    _shrine_base(c, 32, STONE_L, K("D0CABD"), STONE)
    c.rect(13, 12, 18, 24, STONE_L); c.rect(13, 12, 14, 24, K("D0CABD")); c.rect(17, 12, 18, 24, STONE)
    c.rect(12, 10, 19, 12, GOLD); c.rect(12, 18, 19, 19, GOLD)
    c.rect(6, 21, 25, 24, STONE); c.rect(6, 21, 25, 21, STONE_L)
    _flame(c, 16, 6)
    return c


def petilasan_mataram():  # a small candi: stepped roof over a niche
    c = C(32, 38)
    _shrine_base(c, 32)
    c.rect(9, 14, 22, 24, STONE); c.rect(9, 14, 10, 24, STONE_L); c.rect(21, 15, 22, 24, STONE_D)
    c.rect(13, 17, 18, 24, INK)
    for i, (x0, y0) in enumerate(((7, 11), (10, 8), (13, 5))):
        c.rect(x0, y0, 31 - x0, y0 + 3, STONE_L if i % 2 == 0 else STONE)
        c.rect(x0, y0 + 3, 31 - x0, y0 + 3, STONE_D)
    _flame(c, 16, 20)
    return c


def petilasan_kidul():  # coral-crusted stone with a shell ring, green cloth
    c = C(32, 38)
    _shrine_base(c, 32, K("9AA6A0"), K("C8D2CB"), K("5E6E68"))
    c.rect(12, 10, 19, 24, K("8EA09A")); c.rect(12, 10, 13, 24, K("C8D2CB")); c.rect(18, 11, 19, 24, K("5E6E68"))
    c.poly([(11, 9), (20, 9), (19, 15), (16, 18), (13, 15)], SEAGREEN)
    shell(c, 4, 24); shell(c, 22, 24, BONE)
    c.rect(3, 22, 6, 24, K("E86A5A")); c.rect(25, 22, 28, 24, K("E8A06A"))
    _flame(c, 16, 5)
    return c


def petilasan_timur():  # dark volcanic stone with red cloth bands
    c = C(32, 38)
    _shrine_base(c, 32, ASH, K("7E7A88"), ASH_D)
    c.rect(12, 8, 19, 24, ASH); c.rect(12, 8, 13, 24, K("7E7A88")); c.rect(18, 9, 19, 24, ASH_D)
    c.rect(11, 13, 20, 15, RED); c.rect(11, 19, 20, 20, RED_D)
    c.poly([(19, 14), (25, 17), (19, 20)], RED)
    c.rect(5, 24, 8, 26, K("3A3640")); c.rect(24, 25, 27, 27, K("3A3640"))
    _flame(c, 16, 4)
    return c


def petilasan_kala():  # a pale stone circle, flame guttering violet
    c = C(32, 38)
    _shrine_base(c, 32, K("6A6478"), K("9A94AA"), K("3E3850"))
    c.rect(12, 10, 19, 24, K("6A6478")); c.rect(12, 10, 13, 24, K("9A94AA")); c.rect(18, 11, 19, 24, K("3E3850"))
    c.rect(14, 14, 17, 15, FADE); c.rect(14, 18, 17, 19, FADE)
    for x in (5, 25):
        c.rect(x, 18, x + 1, 26, K("3E3850")); c.pt(x, 17, FADE)
    c.ell(11, 0, 21, 10, K("C9B8E840"))
    c.poly([(14, 8), (16, 0), (18, 8)], K("9A7AE8")); c.poly([(15, 8), (16, 3), (17, 8)], K("E6DAFF"))
    return c


def petilasan_hub():  # the neutral shrine for the hub / unknown region
    return petilasan_sunda()


# ------------------------------------------------------------------------------------------------ shortcut gates (16x16)
def _bars(c, col, hi, n=4, x0=1, step=4):
    for i in range(n):
        x = x0 + i * step
        c.rect(x, 1, x + 1, 14, col); c.rect(x, 1, x, 14, hi)


def gate_ts_pagar():  # bamboo fence gate, tied with rope
    c = C(16, 16)
    _bars(c, BAMBOO, K("D2D87A"), 4, 1, 4)
    c.rect(0, 4, 15, 5, BAMBOO_D); c.rect(0, 10, 15, 11, BAMBOO_D)
    for x in (2, 6, 10, 14):
        c.pt(x, 4, SAND); c.pt(x, 10, SAND)
    return c


def gate_ts_tangga():  # wooden shutter gate at the stair head
    c = C(16, 16)
    c.rect(1, 1, 14, 14, WOOD); c.rect(1, 1, 14, 1, WOOD_L)
    c.rect(7, 1, 8, 14, WOOD_D)
    c.rect(1, 4, 14, 5, WOOD_D); c.rect(1, 10, 14, 11, WOOD_D)
    c.rect(5, 7, 6, 8, IRON); c.rect(9, 7, 10, 8, IRON)
    return c


def gate_ts_leuwi():  # lashed bamboo barricade
    c = C(16, 16)
    for x in (2, 6, 10):
        c.line(x, 14, x + 3, 1, BAMBOO); c.line(x + 1, 14, x + 4, 1, BAMBOO_D)
    for x in (13, 9, 5):
        c.line(x, 14, x - 3, 1, BAMBOO); c.line(x - 1, 14, x - 4, 1, BAMBOO_D)
    c.rect(0, 7, 15, 8, RED_D); c.rect(7, 6, 8, 9, RED)
    return c


def gate_ts_sk():  # driftwood and rope gate toward the sea
    c = C(16, 16)
    for x, h in ((1, 14), (5, 12), (9, 14), (13, 11)):
        c.rect(x, 15 - h, x + 2, 14, K("A89878")); c.rect(x, 15 - h, x, 14, K("D8CCAC"))
    c.rect(0, 5, 15, 6, SAND_D); c.rect(0, 10, 15, 11, SAND_D)
    shell(c, 6, 1); c.pt(14, 8, SEAGREEN)
    return c


def gate_gk_lorong():  # black slab, bone seal
    c = C(16, 16)
    c.rect(1, 1, 14, 14, K("3E3850")); c.rect(1, 1, 14, 1, K("6A6478")); c.rect(1, 1, 1, 14, K("6A6478"))
    c.rect(13, 2, 14, 14, VOID)
    c.line(4, 4, 11, 11, FADE); c.line(11, 4, 4, 11, FADE)
    c.rect(6, 6, 9, 9, BONE); c.rect(7, 7, 8, 8, VOID)
    return c


def gate_mt_candi_gapura():  # half of a candi bentar, stone
    c = C(16, 16)
    c.poly([(1, 15), (2, 6), (5, 1), (14, 1), (14, 15)], STONE)
    c.rect(2, 4, 4, 14, STONE_L); c.rect(12, 3, 14, 14, STONE_D)
    for y in (4, 8, 12):
        c.rect(3, y, 13, y, STONE_D)
    c.rect(7, 5, 10, 7, GOLD)
    return c


def gate_mt_ruin_sawah():  # a collapsed-wall barrier shored up with timbers
    c = C(16, 16)
    for x, y, w, h in ((0, 8, 7, 7), (5, 3, 8, 6), (9, 9, 6, 6), (2, 1, 6, 5)):
        stone_slab(c, x, y, min(15, x + w), min(15, y + h), STONE if (x + y) % 2 else K("A09B90"))
    c.line(1, 14, 14, 2, WOOD_D); c.line(2, 14, 15, 2, WOOD)
    return c


def gate_mt_tt():  # tall wooden palisade gate with crossbar
    c = C(16, 16)
    for x in range(0, 16, 3):
        c.rect(x, 0, x + 2, 15, WOOD); c.rect(x, 0, x, 15, WOOD_L)
        c.poly([(x, 0), (x + 1, -1), (x + 2, 0)], WOOD_D)
    c.rect(0, 5, 15, 6, WOOD_D); c.rect(0, 11, 15, 12, WOOD_D)
    c.rect(6, 7, 9, 9, IRON)
    return c


def gate_sk_gerbang():  # coral and shell gate
    c = C(16, 16)
    for x, col in ((1, K("E86A5A")), (5, K("E8A06A")), (9, K("E86A5A")), (13, K("E8A06A"))):
        c.rect(x, 2, x + 1, 14, col)
        c.pt(x - 1, 5, col); c.pt(x + 2, 8, col); c.pt(x - 1, 10, col)
    c.rect(0, 6, 15, 7, SAND_D)
    shell(c, 4, 9, WHITE); shell(c, 9, 9, BONE)
    return c


def gate_tt_ladang():  # thorn-bound stake gate
    c = C(16, 16)
    for x in (1, 5, 9, 13):
        c.poly([(x, 14), (x, 3), (x + 1, 0), (x + 2, 3), (x + 2, 14)], WOOD_D)
        c.rect(x, 3, x, 14, WOOD)
    c.line(0, 6, 15, 8, K("5A3A2A")); c.line(0, 11, 15, 9, K("5A3A2A"))
    for x in (3, 7, 11):
        c.pt(x, 7, RED); c.pt(x + 1, 10, RED)
    return c


def gate_tt_pasir():  # a sandstone slab half-buried
    c = C(16, 16)
    c.rect(1, 2, 14, 14, SAND_D); c.rect(1, 2, 14, 2, SAND); c.rect(1, 2, 1, 14, SAND)
    c.rect(13, 3, 14, 14, K("8A6A3C"))
    c.line(5, 5, 10, 5, K("8A6A3C")); c.line(5, 8, 10, 8, K("8A6A3C")); c.line(5, 11, 8, 11, K("8A6A3C"))
    for x, y in ((3, 13), (12, 12), (7, 14)):
        c.pt(x, y, SAND)
    return c


STORY = {k: v for k, v in dict(globals()).items()
         if callable(v) and not k.startswith("_") and v.__module__ == __name__
         and k not in {"table", "leaf", "stone_slab", "candle", "basket", "footprints", "shell", "mask_shape",
                       "glow_letter", "lamp_post"}}
NO_OUTLINE_LATE = {"eclipse_veil", "kala_exit", "bridge_echo", "lc5_cavern"}
NO_OUTLINE_LATE |= {k for k in STORY if k.startswith("gate_")}   # gates fill their whole tile
