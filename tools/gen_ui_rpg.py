#!/usr/bin/env python3
"""Budayago UI art, parchment-and-ink RPG theme (replaces the gold/wayang frames of gen_ui.py).
Same file names, sizes and 9-patch margins as before, so ui/theme.tres and the screens keep working.
Palette: parchment (paper), ink, stitched leather, riveted iron, wax red. Light is top-left.
Run: python3 tools/gen_ui_rpg.py   Output: assets/art/ui/*.png and tools/ui_rpg_preview.png
Note: gen_ui.py still draws the title scenery (sky, mountains, glow, vignette, pedestal, light cone) and the old gold set;
re-running it would overwrite these files, so run this script after it.
"""
import os
import random
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_ui as G
from gen_ui import Img, hexc, sprite, nine_patch

OUT = G.OUT
CLEAR = (0, 0, 0, 0)
PAPER_HI, PAPER, PAPER_MID, PAPER_LO, PAPER_DK = hexc("F1E4BE"), hexc("E3D0A0"), hexc("D2BC88"), hexc("B89F6C"), hexc("8F7648")
INK, INK_SOFT, INK_FADE = hexc("2A1C12"), hexc("5A4430"), hexc("8A7656")
LEA_HI, LEA, LEA_LO, LEA_DK = hexc("7C5333"), hexc("5A3A22"), hexc("3A2314"), hexc("22140C")
STITCH = hexc("D8B878")
IRON_HI, IRON, IRON_LO, IRON_DK = hexc("B4B9BE"), hexc("7A7F86"), hexc("40444A"), hexc("24272B")
WAX_HI, WAX, WAX_LO = hexc("C9473B"), hexc("9E2B25"), hexc("5E1814")
VERD, VERD_HI = hexc("3F7A66"), hexc("6FB59A")
CREAM = hexc("EADFC4")


def stud(im, x, y):
    """3x3 iron rivet plate."""
    im.rect(x, y, x + 2, y + 2, IRON)
    im.put(x, y, IRON_HI)
    im.put(x + 1, y, IRON_HI)
    im.put(x + 2, y + 2, IRON_LO)
    im.put(x + 1, y + 2, IRON_LO)
    im.put(x + 1, y + 1, IRON_HI)


def leather_paper_frame(w, h, band, studs=True, paper=PAPER, alpha=255):
    """Paper inlay in a leather band: outline, band with lit top-left, inner shadow, paper with burnt edges."""
    im = Img(w, h)
    im.rect(0, 0, w - 1, h - 1, LEA_DK)
    for (x, y) in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)):
        im.put(x, y, CLEAR)
    im.rect(1, 1, w - 2, h - 2, LEA)
    im.rect(1, 1, w - 2, 1, LEA_HI)
    im.rect(1, 1, 1, h - 2, LEA_HI)
    im.rect(1, h - 2, w - 2, h - 2, LEA_LO)
    im.rect(w - 2, 1, w - 2, h - 2, LEA_LO)
    # stitched seam: one continuous line, so it survives 9-patch stretching
    s0 = band - 1
    im.rect(s0, s0, w - 1 - s0, s0, hexc("8A6A44"))
    im.rect(s0, h - 1 - s0, w - 1 - s0, h - 1 - s0, hexc("8A6A44"))
    im.rect(s0, s0, s0, h - 1 - s0, hexc("8A6A44"))
    im.rect(w - 1 - s0, s0, w - 1 - s0, h - 1 - s0, hexc("8A6A44"))
    # paper
    p0, p1 = band + 1, band + 3
    pap = (paper[0], paper[1], paper[2], alpha)
    im.rect(band, band, w - 1 - band, h - 1 - band, G.mix(PAPER_DK, (0, 0, 0, 255), 0.0) if False else INK_SOFT)   # inner line
    im.rect(band + 1, band + 1, w - 2 - band, h - 2 - band, (PAPER_LO[0], PAPER_LO[1], PAPER_LO[2], alpha))     # burnt edge
    im.rect(band + 2, band + 2, w - 3 - band, h - 3 - band, (PAPER_MID[0], PAPER_MID[1], PAPER_MID[2], alpha))
    if w - 2 * (band + 3) > 0 and h - 2 * (band + 3) > 0:
        im.rect(band + 3, band + 3, w - 4 - band, h - 4 - band, pap)
    if studs and band >= 3:
        for (x, y) in ((1, 1), (w - 4, 1), (1, h - 4), (w - 4, h - 4)):
            stud(im, x, y)
    return im


def make_panel():
    return leather_paper_frame(24, 24, 3, True, alpha=250)


def make_panel_dialogue():
    im = leather_paper_frame(32, 32, 4, False, alpha=252)
    # iron corner brackets
    for (x, y, fx, fy) in ((1, 1, 1, 1), (30, 1, -1, 1), (1, 30, 1, -1), (30, 30, -1, -1)):
        for k in range(0, 6):
            im.put(x + fx * k, y, IRON)
            im.put(x, y + fy * k, IRON)
        im.put(x, y, IRON_HI)
        im.put(x + fx * 3, y + fy * 1, IRON_HI)
    return im


def make_portrait_frame():
    w = h = 40
    im = Img(w, h)
    im.rect(0, 0, w - 1, h - 1, LEA_DK)
    im.rect(1, 1, w - 2, h - 2, LEA)
    im.rect(1, 1, w - 2, 1, LEA_HI)
    im.rect(1, 1, 1, h - 2, LEA_HI)
    im.rect(w - 2, 1, w - 2, h - 2, LEA_LO)
    im.rect(1, h - 2, w - 2, h - 2, LEA_LO)
    im.rect(3, 3, w - 4, h - 4, STITCH)
    im.rect(4, 4, w - 5, h - 5, CLEAR)    # interior stays open for the 32x32 bust
    for x in range(4, w - 4, 3):
        im.put(x, 2, hexc("8A6A44")); im.put(x, h - 3, hexc("8A6A44"))
    for (x, y) in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)):
        im.put(x, y, CLEAR)
    for (x, y) in ((0, 0), (w - 3, 0), (0, h - 3), (w - 3, h - 3)):
        stud(im, x, y)
    return im


def make_button(line, fa, fb, inner, hi):
    w, h = 24, 14
    im = Img(w, h)
    im.rect(0, 0, w - 1, h - 1, LEA_DK)
    for (x, y) in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)):
        im.put(x, y, CLEAR)
    im.rect(1, 1, w - 2, 6, fa)
    im.rect(1, 7, w - 2, h - 2, fb)
    im.rect(1, 1, w - 2, 1, hi)
    im.rect(1, 1, 1, h - 2, hi)
    im.rect(2, 2, w - 3, h - 3, CLEAR) if False else None
    # stitched seam inside
    for x in range(2, w - 2):
        im.put(x, 2, inner)
        im.put(x, h - 3, inner)
    for y in range(2, h - 2):
        im.put(2, y, inner)
        im.put(w - 3, y, inner)
    im.put(2, 2, fa); im.put(w - 3, 2, fa); im.put(2, h - 3, fb); im.put(w - 3, h - 3, fb)
    return im


def make_tab(on):
    w, h = 24, 14
    im = Img(w, h)
    if on:
        im.rect(0, 0, w - 1, h - 1, LEA_DK)
        im.rect(1, 1, w - 2, h - 2, PAPER)
        im.rect(1, 1, w - 2, 1, PAPER_HI)
        im.rect(1, h - 2, w - 2, h - 2, PAPER_MID)
        im.rect(2, h - 3, w - 3, h - 3, PAPER_MID)
        im.rect(0, 0, 0, h - 1, WAX)         # a wax-red tab edge
        im.rect(1, 1, 1, h - 2, WAX_HI)
    else:
        im.rect(0, 0, w - 1, h - 1, LEA_DK)
        im.rect(1, 1, w - 2, h - 2, LEA_LO)
        im.rect(1, 1, w - 2, 1, LEA)
        im.rect(1, h - 2, w - 2, h - 2, LEA_DK)
    for (x, y) in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)):
        im.put(x, y, CLEAR)
    return im


def make_slot(sel):
    w = h = 20
    im = Img(w, h)
    rim, hi = (WAX, WAX_HI) if sel else (IRON_LO, IRON)
    im.rect(0, 0, w - 1, h - 1, IRON_DK)
    im.rect(1, 1, w - 2, h - 2, rim)
    im.rect(1, 1, w - 2, 1, hi)
    im.rect(1, 1, 1, h - 2, hi)
    im.rect(2, 2, w - 3, h - 3, LEA_DK)
    im.rect(3, 3, w - 4, h - 4, hexc("2E1D12"))
    im.rect(2, 2, w - 3, 2, hexc("160D08"))
    im.rect(2, 2, 2, h - 3, hexc("160D08"))
    if sel:
        im.rect(2, 2, w - 3, h - 3, CLEAR) if False else None
        for x in range(3, w - 3):
            im.put(x, 3, PAPER_HI if False else hexc("F1E4BE"))
            im.put(x, h - 4, hexc("F1E4BE"))
        for y in range(3, h - 3):
            im.put(3, y, hexc("F1E4BE")); im.put(w - 4, y, hexc("F1E4BE"))
        im.rect(4, 4, w - 5, h - 5, hexc("2E1D12"))
    for (x, y) in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)):
        im.put(x, y, CLEAR)
    return im


def make_divider():
    im = Img(64, 5)
    for x in range(0, 64):
        if abs(x - 32) > 5:
            im.put(x, 2, INK_SOFT if x % 2 == 0 or abs(x - 32) < 24 else INK_FADE)
    for x in range(4, 28):
        im.put(x, 1 if x % 8 < 2 else 3, INK_FADE) if x % 8 < 2 else None
    for x in range(36, 60):
        im.put(x, 1 if x % 8 < 2 else 3, INK_FADE) if x % 8 < 2 else None
    for (dx, dy) in ((0, 0), (-1, 0), (1, 0), (0, -1), (0, 1), (-2, 0), (2, 0)):
        im.put(32 + dx, 2 + dy, WAX if (abs(dx) + abs(dy)) <= 1 else WAX_LO)
    im.put(32, 2, WAX_HI)
    return im


def make_bar_frame():
    w, h = 12, 7
    im = Img(w, h)
    im.rect(0, 0, w - 1, h - 1, IRON_DK)
    im.rect(1, 1, w - 2, h - 2, IRON)
    im.rect(1, 1, w - 2, 1, IRON_HI)
    im.rect(1, 1, 1, h - 2, IRON_HI)
    im.rect(1, h - 2, w - 2, h - 2, IRON_LO)
    im.rect(w - 2, 1, w - 2, h - 2, IRON_LO)
    im.rect(2, 2, w - 3, h - 3, hexc("0E0A08"))
    for (x, y) in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)):
        im.put(x, y, CLEAR)
    return im


def make_keycap():
    im = Img(10, 10)
    im.rect(0, 0, 9, 9, INK)
    im.rect(1, 1, 8, 8, PAPER_HI)
    im.rect(1, 8, 8, 8, PAPER_LO)
    im.rect(8, 1, 8, 8, PAPER_MID)
    for (x, y) in ((0, 0), (9, 0), (0, 9), (9, 9)):
        im.put(x, y, CLEAR)
    return im


def make_row_highlight():
    w = h = 12
    im = Img(w, h)
    im.rect(0, 0, w - 1, h - 1, (158, 43, 37, 70))
    im.rect(0, 0, w - 1, 0, (158, 43, 37, 120))
    im.rect(0, h - 1, w - 1, h - 1, (158, 43, 37, 120))
    im.rect(0, 0, 1, h - 1, WAX)
    return im


def make_scroll():
    s = Img(5, 12)
    s.rect(1, 0, 3, 11, PAPER_LO)
    s.rect(1, 0, 1, 11, PAPER_DK)
    g = Img(5, 12)
    g.rect(1, 0, 3, 11, LEA)
    g.rect(1, 0, 1, 11, LEA_HI)
    g.rect(3, 0, 3, 11, LEA_LO)
    g.put(2, 5, STITCH); g.put(2, 6, STITCH)
    return s, g


def make_hud_plate():
    """Dark stitched-leather plaque behind the HUD vitals, 16x16, 9-patch margin 5."""
    w = h = 16
    im = Img(w, h)
    im.rect(0, 0, w - 1, h - 1, (20, 12, 8, 235))
    im.rect(1, 1, w - 2, h - 2, (58, 35, 20, 235))
    im.rect(1, 1, w - 2, 1, (92, 60, 36, 240))
    im.rect(1, 1, 1, h - 2, (92, 60, 36, 240))
    im.rect(2, 2, w - 3, h - 3, (34, 20, 12, 235))
    for x in range(3, w - 3):
        im.put(x, 2, hexc("8A6A44")); im.put(x, h - 3, hexc("8A6A44"))
    for y in range(3, h - 3):
        im.put(2, y, hexc("8A6A44")); im.put(w - 3, y, hexc("8A6A44"))
    for (x, y) in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)):
        im.put(x, y, CLEAR)
    for (x, y) in ((0, 0), (w - 3, 0), (0, h - 3), (w - 3, h - 3)):
        stud(im, x, y)
    return im


def make_inset():
    """Sunken paper well for the menu's content area, 12x12, 9-patch margin 4."""
    w = h = 12
    im = Img(w, h)
    im.rect(0, 0, w - 1, h - 1, (184, 159, 108, 150))
    im.rect(1, 1, w - 2, h - 2, (214, 192, 140, 120))
    im.rect(0, 0, w - 1, 0, (90, 68, 48, 200)); im.rect(0, 0, 0, h - 1, (90, 68, 48, 200))
    im.rect(0, h - 1, w - 1, h - 1, (241, 228, 190, 220)); im.rect(w - 1, 0, w - 1, h - 1, (241, 228, 190, 220))
    return im


def make_lozenge():
    return sprite(["..R..", ".RHR.", "RHRRS", ".RSS.", "..S.."], {"R": WAX, "H": WAX_HI, "S": WAX_LO})


# ------------------------------------------------------------------ icons
def seal(color, hi, lo, glyph, gcol=CREAM):
    """A 12x12 wax-seal medallion with a 5x5 glyph; HUD vital badges."""
    im = Img(12, 12)
    cx = cy = 5.5
    for y in range(12):
        for x in range(12):
            d = ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5
            if d <= 5.7:
                c = color
                if d > 4.6:
                    c = lo
                elif x + y < 9 and d > 3.4:
                    c = hi
                im.put(x, y, c)
    for (x, y) in ((1, 3), (3, 1), (10, 8), (8, 10)):
        im.put(x, y, lo)
    for j, row in enumerate(glyph):
        for i, ch in enumerate(row):
            if ch == "#":
                im.put(3 + i, 3 + j, gcol)
    return im


def make_icons():
    out = {}
    heart = ["##.##", "#####", "#####", ".###.", "..#.."]
    leaf = ["..###", ".###.", "###..", "##...", "#...."]
    nib = ["..#..", ".###.", ".###.", "..#..", "..#.."]
    out["seal_hp"] = seal(WAX, WAX_HI, WAX_LO, heart)
    out["seal_st"] = seal(hexc("4C7A3A"), hexc("7FB060"), hexc("2A4A22"), leaf)
    out["seal_sk"] = seal(hexc("2F5F9A"), hexc("6A9AD0"), hexc("1A3560"), nib)
    out["icon_heart"] = sprite([".AA.AA.", "AHHAAAA", "AHAAAAA", "AAAAAAS", ".AAAAS.", "..ASS..", "...S..."],
                               {"A": WAX_HI, "H": hexc("F0A090"), "S": WAX_LO})
    out["icon_bolt"] = sprite(["....HYY", "...HYY.", "..HYYS.", ".HYYYYS", "....YS.", "...YS..", "..YS..."],
                              {"Y": hexc("7FB060"), "H": hexc("B8E090"), "S": hexc("2A4A22")})
    out["icon_brush"] = sprite([".....HB", "....HBS", "...HBS.", "..FFS..", ".WWF...", "WWW....", "KW....."],
                               {"B": hexc("6A9AD0"), "H": hexc("B0D0F0"), "S": hexc("2F5F9A"), "F": PAPER,
                                "W": PAPER_HI, "K": INK})
    # Ilmu: a small rolled scroll with a red ribbon
    out["icon_ilmu"] = sprite(["..PPPP..", ".PHHHHP.", "PHRRRRHP", "PHHHHHHP", "PHRRRRHP", "PHHHHHHP", ".PHHHHP.", "..PPPP.."],
                              {"P": INK_SOFT, "H": PAPER_HI, "R": WAX})
    # Saved: a quill dipped in an ink pot
    out["icon_save"] = sprite(["......HH", ".....HHS", "....HHS.", "...HHS..", "..FFS...", ".IIF....", "IIII....", ".II....."],
                              {"H": PAPER_HI, "S": PAPER_LO, "F": PAPER, "I": INK})
    out["flask_full"] = sprite(["..SSS..", "...S...", "..GGG..", ".GHGGG.", ".GGGGG.", ".GGGGS.", ".GGGSS.", "..SSS..", "......."],
                               {"S": IRON_HI, "G": hexc("2FA38A"), "H": hexc("9FE8D0")})
    out["flask_empty"] = sprite(["..SSS..", "...S...", "..III..", ".I...I.", ".I...I.", ".I...I.", ".I...I.", "..III..", "......."],
                                {"S": IRON_LO, "I": INK_FADE})
    out["marker_quest"] = sprite([".WWWWW.", "WWRRRWW", "WWRRRWW", ".WRRRW.", ".WRRRW.", "..WRW..", "..WRW..", "...W...", "...R..."][:9],
                                 {"W": PAPER_HI, "R": WAX})
    out["marker_talk"] = sprite(["WWWWWWW", "WIIIIIW", "WIWIWIW", "WIIIIIW", "WWWIWWW", "...WI..", "....W.."],
                                {"W": PAPER_HI, "I": INK})
    out["arrow_objective"] = sprite(["...W...", "..WRW..", ".WRRRW.", "WRRRRRW", "..WRW..", "..WRW..", "...W..."],
                                    {"W": PAPER_HI, "R": WAX_HI})
    out["continue_arrow"] = sprite(["IIIII", ".III.", "..I.."][:3] + ["....."][:0], {"I": INK_SOFT})
    # make it 5x4 like before
    out["continue_arrow"] = sprite(["IIIII", ".III.", "..I..", "....."], {"I": INK_SOFT})
    return out


TAB = {
    "icon_tab_status": ["...CCC....", "..C...C...", "..C...C...", "...CCC....", "..CCCCC...", ".CCCCCCC..",
                         ".C.CCC.C..", "...C.C....", "..CC.CC...", "..CC.CC..."],
    "icon_tab_equip": ["........CC", ".......CCD", "......CCD.", ".C...CCD..", ".CC.CCD...", "..CCCD....",
                        "...CC.....", "..CCCC....", ".CC..CC...", "CC........"],
    "icon_tab_journal": ["..CCCCCCC.", ".C.......C", ".C.CCCC..C", ".C.......C", ".C.CCCC..C", ".C.......C",
                          ".C.CCC...C", ".C.......C", "..CCCCCCC.", ".........."],
    "icon_tab_map": ["..........", "CCCCCCCCCC", "C..C..C..C", "C..C.CCC.C", "C.CCC.C..C", "C..C..C.CC",
                      "C..CC.C..C", "C..C..C..C", "CCCCCCCCCC", ".........."],
    "icon_tab_pustaka": [".CCCCCCCC.", "CDDDCDDDDC", "CDCDCDCCDC", "CDDDCDDDDC", "CDCDCDCCDC", "CDDDCDDDDC",
                          "CDCDCDDDDC", "CDDDCDDDDC", ".CCCCCCCC.", ".........."],
    "icon_tab_system": ["....CC....", ".C.CCCC.C.", "..CCDDCC..", ".CCD..DCC.", "CCD....DCC", "CCD....DCC",
                         ".CCD..DCC.", "..CCDDCC..", ".C.CCCC.C.", "....CC...."],
}


def make_tab_icons():
    """White glyphs, so the menu can tint them ink on the open tab and paper on the closed ones."""
    out = {}
    for n, rows in TAB.items():
        rows = [r.ljust(10, ".")[:10] for r in rows]
        out[n] = sprite(rows, {"C": (255, 255, 255, 255), "D": (255, 255, 255, 110)})   # D = fainter detail, so ink-tinted icons keep their pattern
    return out


def make_bullets():
    out = {}
    out["bullet_open"] = sprite(["CCCCCCC", "C.....C", "C.....C", "C.....C", "C.....C", "C.....C", "CCCCCCC"], {"C": INK_FADE})
    out["bullet_check"] = sprite(["CCCCCCC", "C....GC", "C...G.C", "CG.G..C", "C.G...C", "C.....C", "CCCCCCC"], {"C": VERD, "G": VERD})
    out["bullet_now"] = sprite(["CCCCCCC", "C..H..C", "C.HRR.C", "CHRRRSC", "C.RSS.C", "C..S..C", "CCCCCCC"],
                               {"C": WAX, "H": WAX_HI, "R": WAX, "S": WAX_LO})
    return out


def main():
    A = {}
    A["panel"] = make_panel()
    A["panel_dialogue"] = make_panel_dialogue()
    A["button_normal"] = make_button(None, LEA_HI, LEA, hexc("9A7A52"), hexc("96693F"))
    A["button_hover"] = make_button(None, hexc("A06C40"), LEA_HI, STITCH, hexc("C08A58"))
    A["button_pressed"] = make_button(None, LEA_LO, LEA_DK, hexc("6A4A2C"), LEA_LO)
    A["button_disabled"] = make_button(None, hexc("4A4036"), hexc("3A322A"), hexc("5A5044"), hexc("5A5044"))
    A["tab_on"] = make_tab(True)
    A["tab_off"] = make_tab(False)
    A["slot"] = make_slot(False)
    A["slot_selected"] = make_slot(True)
    A["divider"] = make_divider()
    A["bar_frame"] = make_bar_frame()
    A["frame_portrait"] = make_portrait_frame()
    A["keycap"] = make_keycap()
    A["row_highlight"] = make_row_highlight()
    A["scroll_track"], A["scroll_grab"] = make_scroll()
    A["lozenge"] = make_lozenge()
    A["hud_plate"] = make_hud_plate()
    A["inset"] = make_inset()
    A.update(make_icons())
    A.update(make_tab_icons())
    A.update(make_bullets())
    for name, im in A.items():
        im.save(os.path.join(OUT, name + ".png"))
    # preview
    S = 3
    pv = Img(1100, 420, (60, 50, 44, 255))
    x = y = 10
    rowh = 0
    for n, im in A.items():
        s = im.scaled(S)
        if x + s.w > 1090:
            x = 10; y += rowh + 8; rowh = 0
        pv.paste(s, x, y)
        x += s.w + 8
        rowh = max(rowh, s.h)
    y += rowh + 12
    for n, m, w, h in (("panel", 6, 120, 70), ("panel_dialogue", 8, 200, 60), ("button_normal", 5, 70, 18), ("tab_on", 5, 60, 18)):
        s = nine_patch(A[n], (m, m, m, m), w, h).scaled(2)
        pv.paste(s, x if x + s.w < 1090 else 10, y)
        x += s.w + 10
    final = Img(1100, min(420, y + 160))
    final.p = pv.p[: final.h]
    final.save(os.path.join(G.ROOT, "tools", "ui_rpg_preview.png"))
    print("wrote", len(A))


if __name__ == "__main__":
    main()
