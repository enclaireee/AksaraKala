#!/usr/bin/env python3
"""Story props: one sprite per examinable clue, codex spot, pickup and quest-trigger object (Prologue and Act I here; Acts II-VI,
the checkpoint shrines and the shortcut gates in gen_story_props_late.py), so no objective sits on empty floor. Output: assets/art/story/<id>.png (ids are the zone
legend's clue_id / item_id / codex_id / trigger_id; loaded by entities/world/story_art.gd) and
assets/art/ui/lontar_card.png (the write card's leaf). Run: python3 tools/gen_story_props.py
Sprites are drawn bottom-centre: the node origin is the object's feet.
"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from PIL import Image, ImageDraw
import pixlib as px
from pixlib import hexc

K = hexc  # alias
WOOD, WOOD_D, WOOD_L = K("8A6A44"), K("5C432B"), K("B58E5A")
LEAF, LEAF_D = K("4F8A3C"), K("2F5E2B")
PAPER, PAPER_D = K("E6D299"), K("B89B5E")
INK = K("2A1D26")
TEAL, TEAL_D = K("2A9D8F"), K("1D6B62")
RED, RED_D = K("B8353A"), K("7D2428")
GOLD, GOLD_L = K("F2B84B"), K("FFE08A")
FLAME, FLAME_L = K("FF9F1C"), K("FFE066")
STONE, STONE_D, STONE_L = K("8C8881"), K("5E5A54"), K("B5B0A6")
MASK, MASK_D = K("EDE6D2"), K("BDB59C")
MUD, MUD_D = K("6B4E35"), K("473321")
WHITE = K("F4F1DE")
GREY = K("6E6A78")
WATER, WATER_L = K("4A78A8"), K("8EC1E0")
BAMBOO, BAMBOO_D = K("A8B04A"), K("6E7A2E")


class C:
    def __init__(self, w, h):
        self.im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.im)
        self.w, self.h = w, h

    def rect(self, x0, y0, x1, y1, c):
        self.d.rectangle([x0, y0, x1, y1], fill=c)

    def ell(self, x0, y0, x1, y1, c):
        self.d.ellipse([x0, y0, x1, y1], fill=c)

    def line(self, x0, y0, x1, y1, c):
        self.d.line([x0, y0, x1, y1], fill=c)

    def pt(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.im.putpixel((x, y), c)

    def poly(self, pts, c):
        self.d.polygon(pts, fill=c)

    def out(self):
        return px.outline(self.im)


def post(c, x, y0, y1):
    c.rect(x, y0, x + 1, y1, WOOD)
    c.rect(x, y0, x, y1, WOOD_L)


# ------------------------------------------------------------------------------------------------ clues
def laras_ribbon_spot():  # teal ribbon snagged on a thorn bush
    c = C(22, 20)
    c.ell(2, 8, 19, 18, LEAF_D)
    c.ell(4, 6, 17, 15, LEAF)
    for x, y in [(6, 8), (11, 6), (14, 10), (8, 12)]:
        c.pt(x, y, LEAF_D)
    c.poly([(10, 5), (16, 2), (20, 6), (15, 7)], TEAL)
    c.poly([(10, 5), (12, 12), (15, 17), (12, 18), (9, 11)], TEAL_D)
    c.rect(9, 4, 11, 6, GOLD)
    return c


def shelf_ribbon():  # ribbon laid on a small shelf
    c = C(24, 18)
    c.rect(1, 12, 22, 14, WOOD)
    c.rect(1, 12, 22, 12, WOOD_L)
    c.rect(2, 15, 3, 17, WOOD_D)
    c.rect(20, 15, 21, 17, WOOD_D)
    c.poly([(5, 11), (10, 7), (14, 8), (19, 11), (14, 12), (10, 12)], TEAL)
    c.rect(10, 8, 13, 11, TEAL_D)
    c.rect(11, 9, 12, 10, GOLD)
    return c


def shelf_board():  # a splintered wagon plank
    c = C(24, 18)
    c.rect(1, 12, 22, 14, WOOD)
    c.rect(1, 12, 22, 12, WOOD_L)
    c.rect(2, 15, 3, 17, WOOD_D)
    c.rect(20, 15, 21, 17, WOOD_D)
    c.poly([(4, 11), (6, 6), (19, 8), (20, 11)], WOOD_L)
    c.line(5, 9, 19, 10, WOOD_D)
    c.pt(7, 7, WOOD_D); c.pt(18, 9, RED_D)
    c.rect(11, 7, 13, 8, RED)
    return c


def shelf_strip():  # a torn lontar strip carrying the Ka glyph
    c = C(24, 18)
    c.rect(1, 12, 22, 14, WOOD)
    c.rect(1, 12, 22, 12, WOOD_L)
    c.rect(2, 15, 3, 17, WOOD_D)
    c.rect(20, 15, 21, 17, WOOD_D)
    c.rect(4, 7, 19, 11, PAPER)
    c.rect(4, 7, 19, 7, WHITE)
    for x in (4, 19):
        c.pt(x, 8, PAPER_D); c.pt(x, 10, PAPER_D)
    c.rect(7, 8, 9, 10, INK); c.rect(8, 9, 8, 9, PAPER)
    c.line(11, 9, 16, 9, INK)
    return c


def kelir_lamp():  # the blencong oil lamp, flame bright
    c = C(16, 24)
    c.ell(1, 1, 14, 14, K("FFE06640"))
    c.rect(6, 11, 9, 12, GOLD)
    c.poly([(7, 3), (9, 8), (8, 11), (6, 8)], FLAME)
    c.rect(7, 6, 8, 10, FLAME_L)
    c.rect(4, 12, 11, 14, GOLD)
    c.rect(5, 15, 10, 15, K("B58228"))
    c.rect(7, 16, 8, 20, WOOD_D)
    c.rect(4, 21, 11, 23, WOOD)
    return c


def c2_reply_letter():  # sealed letter, red wax
    c = C(20, 16)
    c.rect(2, 3, 17, 13, PAPER)
    c.line(2, 3, 9, 8, PAPER_D); c.line(17, 3, 10, 8, PAPER_D)
    c.rect(2, 3, 17, 3, WHITE)
    c.ell(7, 7, 12, 12, RED); c.pt(9, 9, RED_D); c.pt(10, 10, RED_D)
    return c


def s1_offerings():  # banana-leaf tray: rice cone, flowers, incense
    c = C(26, 22)
    c.ell(1, 12, 24, 20, LEAF_D)
    c.ell(2, 11, 23, 18, LEAF)
    c.poly([(8, 12), (13, 3), (18, 12)], WHITE)
    c.line(13, 3, 13, 12, MASK_D)
    for x, col in [(4, RED), (6, GOLD), (20, GOLD), (22, RED)]:
        c.rect(x, 12, x + 1, 14, col)
    c.rect(22, 3, 22, 11, WOOD_D); c.pt(22, 2, FLAME); c.pt(22, 1, GREY)
    c.rect(3, 4, 3, 10, WOOD_D); c.pt(3, 3, FLAME)
    return c


def gorge_prints():  # two bare footprints in damp mud
    c = C(22, 22)
    c.ell(1, 8, 20, 20, MUD)
    c.ell(2, 9, 19, 18, MUD_D)
    for ox, oy in ((5, 4), (12, 9)):
        c.ell(ox + 1, oy + 4, ox + 5, oy + 9, MUD)
        c.ell(ox, oy + 1, ox + 5, oy + 5, MUD)
        for i in range(4):
            c.pt(ox + i, oy, MUD)
    return c


def oncor():  # bamboo torch on a pole
    c = C(14, 28)
    c.rect(6, 10, 7, 27, BAMBOO)
    c.rect(6, 10, 6, 27, BAMBOO_D)
    for y in (14, 20):
        c.rect(5, y, 8, y, BAMBOO_D)
    c.rect(4, 7, 9, 10, WOOD_D)
    c.poly([(7, 0), (10, 5), (9, 8), (4, 8), (3, 5)], FLAME)
    c.poly([(7, 3), (8, 6), (6, 7)], FLAME_L)
    c.rect(4, 26, 9, 27, STONE)
    return c


def sandal():  # a child's single sandal
    c = C(18, 14)
    c.ell(1, 3, 15, 11, WOOD_L)
    c.ell(2, 4, 14, 10, WOOD)
    c.rect(6, 2, 7, 6, TEAL); c.rect(9, 2, 10, 6, TEAL)
    c.line(6, 2, 10, 2, TEAL_D)
    c.pt(4, 8, WOOD_D); c.pt(12, 8, WOOD_D)
    return c


def s1_spring():  # hidden spring: ring of stones round clear water
    c = C(28, 20)
    c.ell(0, 4, 27, 19, STONE_D)
    c.ell(2, 5, 25, 16, STONE)
    c.ell(5, 7, 22, 15, WATER)
    c.ell(8, 8, 17, 12, WATER_L)
    c.pt(11, 9, WHITE); c.pt(14, 11, WHITE)
    return c


def s2_cempaka():  # cempaka blossoms on a stem
    c = C(20, 22)
    c.line(9, 8, 9, 21, LEAF_D)
    c.poly([(9, 16), (4, 12), (8, 14)], LEAF); c.poly([(10, 14), (15, 10), (11, 12)], LEAF)
    for cx, cy in ((6, 6), (13, 5), (10, 9)):
        for dx, dy in ((0, -2), (2, 0), (0, 2), (-2, 0)):
            c.ell(cx + dx - 1, cy + dy - 1, cx + dx + 1, cy + dy + 1, K("F6E2A0"))
        c.pt(cx, cy, GOLD)
    return c


def s2_cloth():  # a torn scrap of cloth snagged on a root
    c = C(22, 16)
    c.poly([(2, 4), (18, 2), (20, 9), (15, 8), (14, 14), (9, 9), (4, 11)], K("7D2B40"))
    c.line(3, 5, 17, 3, K("B84A62"))
    c.line(6, 8, 10, 8, K("B84A62"))
    c.rect(14, 12, 18, 14, WOOD_D)
    return c


def s2_white_cloth():  # white funeral cloth folded on a stone
    c = C(22, 16)
    c.ell(2, 8, 19, 15, STONE)
    c.rect(4, 3, 17, 10, WHITE)
    c.rect(4, 3, 17, 3, K("FFFFFF"))
    c.rect(4, 7, 17, 7, MASK_D); c.rect(4, 10, 17, 10, MASK_D)
    return c


def s2_grave():  # grave mound with a stone marker
    c = C(24, 24)
    c.ell(1, 14, 22, 23, MUD)
    c.ell(3, 15, 20, 22, K("7A5E42"))
    c.rect(9, 4, 14, 19, STONE)
    c.rect(9, 4, 14, 4, STONE_L); c.rect(8, 3, 15, 3, STONE_L)
    c.rect(13, 5, 14, 19, STONE_D)
    c.line(11, 8, 12, 8, STONE_D); c.line(11, 11, 12, 11, STONE_D)
    c.rect(5, 16, 6, 17, WHITE); c.rect(17, 17, 18, 18, GOLD)
    return c


def empty_coops():  # bamboo chicken coop, door open, empty
    c = C(28, 24)
    c.rect(3, 22, 24, 23, WOOD_D)
    for x in range(4, 25, 4):
        c.rect(x, 8, x, 22, BAMBOO)
    c.rect(3, 6, 24, 8, BAMBOO_D)
    c.poly([(1, 7), (14, 0), (26, 7)], K("B59A4E"))
    c.line(14, 0, 14, 7, K("8A7032"))
    c.rect(11, 12, 16, 22, INK)
    c.poly([(16, 12), (20, 14), (20, 22), (16, 22)], BAMBOO)
    c.pt(9, 21, WHITE); c.pt(12, 21, WHITE)
    return c


def loom():  # backstrap/frame loom with half-woven cloth
    c = C(28, 26)
    post(c, 3, 3, 24); post(c, 23, 3, 24)
    c.rect(3, 2, 24, 3, WOOD_D)
    c.rect(3, 22, 24, 23, WOOD_D)
    for x in range(6, 22, 2):
        c.line(x, 4, x, 21, K("D8CFA8"))
    c.rect(6, 13, 21, 21, K("B84A62"))
    for y in (15, 18):
        c.rect(6, y, 21, y, GOLD)
    c.rect(6, 13, 21, 13, K("7D2B40"))
    c.rect(11, 9, 18, 10, WOOD_L)
    return c


def faceless_toy():  # little wooden horse with a name cut in the belly
    c = C(20, 20)
    c.rect(4, 9, 14, 13, WOOD_L)
    c.rect(4, 9, 14, 9, K("D8B27A"))
    c.rect(12, 4, 15, 9, WOOD_L); c.rect(14, 5, 17, 8, WOOD_L)
    c.pt(15, 6, INK)
    c.rect(11, 3, 12, 6, WOOD_D)
    c.rect(4, 14, 5, 18, WOOD); c.rect(7, 14, 8, 18, WOOD)
    c.rect(11, 14, 12, 18, WOOD); c.rect(14, 14, 15, 18, WOOD)
    c.rect(2, 8, 3, 12, WOOD_D)
    c.line(7, 11, 11, 11, WOOD_D)
    return c


def felled_trees():  # a stack of cut logs, fresh pale ends
    c = C(30, 22)
    for (x, y) in ((1, 12), (9, 12), (17, 12)):
        c.rect(x, y, x + 12, y + 8, WOOD_D)
        c.ell(x + 9, y, x + 15, y + 8, K("D8B27A")); c.ell(x + 11, y + 2, x + 13, y + 6, WOOD_L)
    for (x, y) in ((5, 4), (13, 4)):
        c.rect(x, y, x + 12, y + 8, WOOD)
        c.ell(x + 9, y, x + 15, y + 8, K("D8B27A")); c.ell(x + 11, y + 2, x + 13, y + 6, WOOD_L)
    c.rect(24, 17, 28, 19, GOLD)  # sawdust
    return c


def lc1_voice():  # a faint echo: glowing ring over a stone
    c = C(24, 26)
    c.ell(7, 20, 17, 25, STONE)
    for r, col in ((10, K("8EC1E040")), (7, K("8EC1E080")), (4, K("DDF0FFD0"))):
        c.ell(12 - r, 10 - r, 12 + r, 10 + r, col)
    c.ell(10, 8, 14, 12, K("FFFFFF"))
    return c


def boat_ribs():  # the ribs of a wrecked prahu
    c = C(32, 24)
    c.line(2, 20, 29, 20, WOOD_D); c.line(2, 21, 29, 21, WOOD_D)
    c.rect(1, 19, 3, 22, WOOD); c.rect(28, 19, 30, 22, WOOD)
    for x in range(6, 27, 5):
        c.line(x, 20, x - 2, 6, WOOD)
        c.line(x + 1, 20, x - 1, 6, WOOD_L)
        c.line(x, 20, x + 2, 6, WOOD)
    c.pt(10, 10, MUD); c.pt(21, 8, MUD)
    return c


def hunter_mask_1():  # the blank mask, a hairline crack
    c = C(18, 22)
    c.poly([(3, 2), (14, 2), (16, 9), (13, 19), (9, 21), (5, 19), (2, 9)], MASK)
    c.line(3, 2, 14, 2, K("FFFFFF"))
    c.rect(13, 4, 15, 9, MASK_D)
    c.line(9, 3, 8, 8, MASK_D); c.pt(8, 9, MASK_D)
    c.rect(1, 9, 2, 12, WOOD_D); c.rect(15, 9, 16, 12, WOOD_D)  # tie loops
    return c


# ------------------------------------------------------------------------------------------------ codex spots
def banyan():  # roadside banyan shrine: small stone niche with offerings
    c = C(24, 26)
    c.rect(3, 10, 20, 24, STONE_D)
    c.rect(4, 10, 19, 23, STONE)
    c.rect(6, 12, 17, 22, INK)
    c.poly([(2, 10), (12, 2), (21, 10)], STONE_L)
    c.rect(11, 16, 12, 20, GOLD); c.pt(11, 15, FLAME)
    c.rect(8, 21, 15, 22, RED)
    for x in (2, 20):
        c.rect(x, 18, x + 2, 25, LEAF_D)
    return c


def hunter_mask():  # empty mask resting on hearth ash
    c = hunter_mask_1()
    d = C(22, 26)
    d.ell(1, 18, 20, 25, STONE_D)
    d.ell(3, 19, 18, 24, K("3A3436"))
    d.im.alpha_composite(c.im, (2, 3))
    return d


def maghrib():  # dusk sign: lantern hung on a gorge post
    c = C(16, 28)
    post(c, 7, 4, 27)
    c.rect(5, 2, 10, 3, WOOD_D)
    c.rect(5, 4, 10, 11, K("B8353A"))
    c.rect(6, 5, 9, 10, FLAME_L); c.rect(7, 6, 8, 9, FLAME)
    c.rect(5, 12, 10, 12, WOOD_D)
    return c


def tangkuban_perahu():  # upturned boat that is also a mountain
    c = C(34, 24)
    c.poly([(1, 20), (6, 8), (17, 3), (28, 8), (33, 20)], K("4F6B52"))
    c.poly([(6, 8), (17, 3), (28, 8), (17, 12)], K("6E8D6B"))
    c.rect(1, 20, 33, 22, WOOD_D)
    c.poly([(0, 20), (4, 24), (30, 24), (34, 20)], WOOD)
    c.pt(17, 2, WHITE)
    return c


def crater_seal():  # cracked seal stone with a dawn groove
    c = C(24, 26)
    c.ell(2, 19, 21, 25, STONE_D)
    c.rect(5, 3, 18, 22, STONE)
    c.rect(5, 3, 18, 3, STONE_L); c.rect(4, 4, 4, 22, STONE_L)
    c.rect(17, 4, 18, 22, STONE_D)
    c.line(11, 3, 9, 8, INK); c.line(9, 8, 12, 13, INK); c.line(12, 13, 10, 20, INK)
    c.rect(7, 9, 8, 14, FLAME_L)
    return c


# ------------------------------------------------------------------------------------------------ pickups
def angklung():  # bamboo angklung in a frame
    c = C(18, 24)
    c.rect(2, 3, 15, 4, WOOD_D)
    c.rect(2, 3, 2, 21, WOOD_D); c.rect(15, 3, 15, 21, WOOD_D)
    c.rect(2, 21, 15, 22, WOOD_D)
    for x, top in ((5, 7), (8, 5), (11, 9)):
        c.rect(x, top, x + 1, 20, BAMBOO)
        c.rect(x, top, x, 20, K("D2D87A"))
        c.rect(x, top + 5, x + 1, top + 5, BAMBOO_D)
    c.rect(4, 14, 12, 14, RED)
    return c


# ------------------------------------------------------------------------------------------------ trigger objects
def sanggar_lontar():  # sanggar writing table: lontar leaves, inkpot, brush, lamp
    c = C(48, 36)
    c.rect(3, 16, 44, 20, WOOD_L)
    c.rect(3, 16, 44, 16, K("D8B27A"))
    c.rect(3, 20, 44, 21, WOOD_D)
    for x in (5, 40):
        c.rect(x, 22, x + 2, 34, WOOD_D)
    # the long lontar leaf, with a name half-written
    c.rect(8, 10, 34, 15, PAPER)
    c.rect(8, 10, 34, 10, WHITE)
    c.rect(8, 15, 34, 15, PAPER_D)
    for x in range(11, 31, 4):
        c.rect(x, 12, x + 1, 13, INK)
    c.rect(11, 13, 24, 13, INK)
    c.rect(6, 12, 7, 14, WOOD_D); c.rect(35, 12, 36, 14, WOOD_D)  # cord holes
    # torn half beside it
    c.poly([(29, 8), (40, 7), (41, 11), (36, 10), (34, 12)], PAPER_D)
    # ink pot and brush
    c.rect(38, 11, 42, 15, INK); c.rect(38, 11, 42, 11, GREY)
    c.line(36, 6, 40, 11, WOOD_D); c.pt(36, 5, INK)
    # little lamp
    c.rect(4, 11, 7, 15, GOLD); c.poly([(5, 6), (7, 10), (4, 10)], FLAME)
    return c


def purwa_stage_lamps():  # four ceremonial stage oil lamps at the corners
    c = C(48, 40)
    for (x, y) in ((6, 8), (36, 8), (6, 26), (36, 26)):
        c.rect(x + 1, y + 4, x + 4, y + 5, GOLD)
        c.poly([(x + 2, y), (x + 4, y + 3), (x + 1, y + 3)], FLAME)
        c.rect(x + 2, y + 6, x + 3, y + 10, WOOD_D)
        c.rect(x - 1, y + 11, x + 6, y + 12, WOOD)
    return c


def purwa_table():  # Ibu's table: teapot and cups
    c = C(40, 28)
    c.rect(2, 12, 37, 15, WOOD_L)
    c.rect(2, 12, 37, 12, K("D8B27A"))
    c.rect(2, 15, 37, 16, WOOD_D)
    for x in (4, 33):
        c.rect(x, 17, x + 2, 27, WOOD_D)
    c.rect(15, 7, 23, 11, K("9E5A32")); c.rect(24, 8, 26, 9, K("9E5A32")); c.rect(13, 8, 14, 9, K("9E5A32"))
    c.rect(17, 5, 21, 6, K("5C432B"))
    for x in (6, 29, 33):
        c.rect(x, 9, x + 3, 11, WHITE); c.rect(x, 9, x + 3, 9, MASK_D)
    return c


def purwa_north_fog():  # a wall of grey fog at the cave mouth
    c = C(64, 40)
    for (x, y, w, h, col) in ((2, 14, 28, 18, K("B5B0A6C0")), (24, 6, 34, 22, K("C7C2ACB0")),
                              (10, 22, 40, 16, K("8C8881B0")), (36, 18, 26, 18, K("B5B0A6C0")),
                              (16, 12, 24, 14, K("E0DCD0A0"))):
        c.ell(x, y, x + w, y + h, col)
    return c


def leuwi_outer_oncor():  # the outer hamlet lanterns, unlit-to-lit pair on a rail
    c = C(40, 30)
    c.rect(2, 24, 37, 25, WOOD_D)
    for x in (4, 34):
        c.rect(x, 6, x + 1, 25, WOOD)
    c.rect(4, 6, 35, 7, WOOD_D)
    for x in (9, 17, 25):
        c.rect(x + 1, 8, x + 1, 10, WOOD_D)
        c.rect(x - 1, 11, x + 4, 19, K("B8353A"))
        c.rect(x, 12, x + 3, 18, FLAME_L if x != 17 else STONE_L)
        c.rect(x - 1, 20, x + 4, 20, WOOD_D)
    return c


def crater_post():  # eastern post on the crater rim with a notch cut
    c = C(16, 34)
    c.rect(5, 6, 10, 32, WOOD)
    c.rect(5, 6, 6, 32, WOOD_L)
    c.rect(9, 6, 10, 32, WOOD_D)
    c.rect(4, 4, 11, 6, WOOD_D)
    c.rect(6, 14, 9, 16, INK)
    c.rect(3, 31, 12, 33, STONE)
    c.rect(6, 20, 9, 22, RED)
    return c


def spring_bath():  # hidden spring, as s1_spring
    return s1_spring()


def dark_grove():  # twisted tree gateway into the dark grove
    c = C(40, 40)
    c.rect(4, 10, 9, 38, K("2A2030")); c.rect(30, 10, 35, 38, K("2A2030"))
    c.poly([(4, 12), (20, -2), (35, 12), (32, 16), (20, 6), (7, 16)], K("2A2030"))
    c.ell(2, 4, 14, 14, K("1F3A2A")); c.ell(26, 4, 38, 14, K("1F3A2A"))
    c.pt(8, 22, K("C0E080")); c.pt(31, 26, K("C0E080"))
    return c


STORY = {
    "laras_ribbon_spot": laras_ribbon_spot, "shelf_ribbon": shelf_ribbon, "shelf_board": shelf_board,
    "shelf_strip": shelf_strip, "kelir_lamp": kelir_lamp, "c2_reply_letter": c2_reply_letter,
    "s1_offerings": s1_offerings, "gorge_prints": gorge_prints, "oncor": oncor, "sandal": sandal,
    "s1_spring": s1_spring, "s2_cempaka": s2_cempaka, "s2_cloth": s2_cloth, "s2_white_cloth": s2_white_cloth,
    "s2_grave": s2_grave, "empty_coops": empty_coops, "loom": loom, "faceless_toy": faceless_toy,
    "felled_trees": felled_trees, "lc1_voice": lc1_voice, "boat_ribs": boat_ribs, "hunter_mask_1": hunter_mask_1,
    "banyan": banyan, "hunter_mask": hunter_mask, "maghrib": maghrib, "tangkuban_perahu": tangkuban_perahu,
    "crater_seal": crater_seal,
    "angklung_1": angklung, "angklung_2": angklung, "angklung_3": angklung, "angklung_4": angklung,
    "angklung_5": angklung,
    "sanggar_lontar": sanggar_lontar, "purwa_stage_lamps": purwa_stage_lamps, "purwa_table": purwa_table,
    "purwa_north_fog": purwa_north_fog, "leuwi_outer_oncor": leuwi_outer_oncor, "crater_post": crater_post,
    "spring_bath": spring_bath, "dark_grove": dark_grove,
}
NO_OUTLINE = {"purwa_north_fog", "lc1_voice"}


def lontar_card():  # the write card's leaf (a lontar palm-leaf strip with cord holes)
    c = C(120, 24)
    c.rect(4, 3, 115, 20, PAPER)
    c.rect(4, 3, 115, 4, WHITE)
    c.rect(4, 19, 115, 20, PAPER_D)
    for y in (8, 12, 16):
        for x in range(10, 110, 3):
            if (x * 7 + y) % 5:
                c.pt(x, y, K("D8C48A"))
    for x in (12, 108):
        c.ell(x - 2, 9, x + 2, 14, INK)
    c.rect(0, 5, 3, 18, WOOD_D); c.rect(116, 5, 119, 18, WOOD_D)
    return c


def main():
    import gen_story_props_late as late   # Acts II-VI, shrines and gates
    STORY.update(late.STORY)
    NO_OUTLINE.update(late.NO_OUTLINE_LATE)
    imgs = []
    for name, fn in STORY.items():
        c = fn()
        im = c.im if name in NO_OUTLINE else c.out()
        px.save(im, f"story/{name}.png")
        imgs.append((f"story/{name}.png", im))
    px.save(lontar_card().im, "ui/lontar_card.png")
    print("wrote", len(imgs), "story sprites")
    # contact sheet
    W = 14
    sheet = Image.new("RGBA", (W * 72, ((len(imgs) + W - 1) // W) * 56), (70, 96, 70, 255))
    for i, (_, im) in enumerate(imgs):
        im = im if im.width <= 68 and im.height <= 52 else im.crop((0, 0, 68, 52))
        sheet.alpha_composite(im, ((i % W) * 72 + 2, (i // W) * 56 + 2))
    sheet.resize((sheet.width * 2, sheet.height * 2), 0).save(
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "story_preview.png"))


if __name__ == "__main__":
    main()
