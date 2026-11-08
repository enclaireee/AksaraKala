#!/usr/bin/env python3
"""Generate 7 rich 128x256 (8 cols x 16 rows = 128 tiles per region, 896 tiles total) world tilesets.

Each regional sheet contains 3 distinct Sub-Biomes (5 rows each, rows 0..4, 5..9, 10..14) + 1 Landmark row (row 15):
  - Rows b+0 : Base tile A (ground, path, feature, floor, wall roof, water, flora/pillar A, rock/prop A)
  - Rows b+1 : Variant B (clovers/pebbles, cobbles, terrace B, floor grain B, wall roof B, wave B, shrub/tree B, crate/pot/statue B)
  - Rows b+2 : Rich Decor C (flowers/mushrooms/shells, wagon ruts/stepping stones, ornate mosaic/carpet, floor grate/inlay,
                             window/banner/shelf wall facade, lilypad/reed/coral water, torch/banner/totem C, well/anvil/nisan/shrine C)
  - Rows b+3 : 2.5D Transitions (under-wall shadow on '.', ',', 't', '_'; 2.5D south-facing wall facade on '#';
                                 north shoreline bank+foam on '~'; canopy/capital on 'b'; mossy/cluster prop on 'r')
  - Rows b+4 : Borders & Bridges (tuft border on '.'; wooden bridge / curbed road on ','; terrace border on 't';
                                  doorway steps/threshold on '_'; north wall lip on '#'; south shoreline bank on '~';
                                  pillar base on 'b'; double boulder/chest-plinth on 'r')
  - Row 15   : Landmark / Arena Setpieces (ritual ground, plank bridge over water, glowing rune mosaic, royal carpet,
                                           ornate archway/gate wall, whirlpool/fumarole, brazier/umbul-umbul banner, monument statue)
"""
import os
import shutil
from PIL import Image
import pixlib as px
from pixlib import hexc, shade

S = 16
COLS, ROWS = 8, 16
W, H = COLS * S, ROWS * S


def B(g, p, f, fl, wt, wf, wh, tr, wa, pr, rk, ac, pat="terrace", wstyle="brick", pstyle="bamboo", rstyle="rock"):
    """Build a compact sub-biome palette dictionary from hex codes."""
    return dict(
        ground=hexc(g), ground_shd=shade(hexc(g), 0.80), ground_hi=shade(hexc(g), 1.18),
        path=hexc(p), path_shd=shade(hexc(p), 0.78), path_hi=shade(hexc(p), 1.18),
        feat=hexc(f), feat_shd=shade(hexc(f), 0.75), feat_hi=shade(hexc(f), 1.22),
        floor=hexc(fl), floor_shd=shade(hexc(fl), 0.75), floor_hi=shade(hexc(fl), 1.18),
        wall_top=hexc(wt), wall_face=hexc(wf), wall_hi=hexc(wh), wall_dark=shade(hexc(wt), 0.55),
        wall_trim=hexc(tr),
        water=hexc(wa), water_deep=shade(hexc(wa), 0.70), water_hi=shade(hexc(wa), 1.38), foam=shade(hexc(wa), 1.75),
        pillar=hexc(pr), pillar_hi=shade(hexc(pr), 1.28), pillar_shd=shade(hexc(pr), 0.68),
        rock=hexc(rk), rock_hi=shade(hexc(rk), 1.28), rock_shd=shade(hexc(rk), 0.68),
        accent=hexc(ac), pat=pat, wstyle=wstyle, pstyle=pstyle, rstyle=rstyle,
    )


REGIONS = {
    "sunda": [
        # Biome 0: Highland Village, Tea & Sawah (desa_purwa, ts_kampung, ts_kebun, ts_sawah)
        B("4A7A44", "A8845A", "5E944B", "8C603A", "3B281B", "735135", "996F4B", "D4A85C",
          "2B6E96", "4D8F44", "6E757A", "FFE066", pat="terrace", wstyle="bilik", pstyle="bamboo", rstyle="village"),
        # Biome 1: Deep Haunted Leuweung Forest & Lake (ts_hutan_*, ts_leuweung, ts_leuwi, ts_situ)
        B("2F5938", "6E5842", "3D6E48", "594533", "1E3324", "3D543A", "577550", "68D8D6",
          "1E5466", "386641", "52615A", "5FF0D0", pat="forest", wstyle="moss", pstyle="tree", rstyle="menhir"),
        # Biome 2: Tangkuban Parahu Volcanic Crater (ts_kawah_jalan, ts_kawah)
        B("4A464C", "6E6259", "5C5549", "3D363B", "241E24", "473B42", "66565E", "FF7B29",
          "2E6E65", "54453F", "3D383D", "FFB703", pat="crater", wstyle="crater", pstyle="deadtree", rstyle="fumarole"),
    ],
    "galuh": [
        # Biome 0: Royal Palace, Alun-Alun & Kaputren Gardens (kg_alun, kg_keraton, kg_kaputren)
        B("548250", "CFC2A4", "9E3642", "E0D4B8", "4A3B30", "C2B295", "E6DCC5", "F2B84B",
          "267878", "8F5836", "C2B69E", "FFD166", pat="carpet", wstyle="palace", pstyle="pendopo", rstyle="plinth"),
        # Biome 1: Pasar Kuta Market & Balai Pustaka Archive (kg_pasar, kg_pustaka)
        B("8C7A62", "B59F7E", "7D4E38", "6E4E34", "362419", "825C3E", "A67B58", "E09F3E",
          "2E6170", "734B30", "9C8970", "F4A261", pat="market", wstyle="shelf", pstyle="awning", rstyle="crates"),
        # Biome 2: Dungeon Prison & Pamali River Border (kg_penjara, kg_pamali)
        B("454D46", "636963", "3B423D", "4F5450", "1F2421", "3D4540", "57615A", "8C968E",
          "2B4A48", "4A3D33", "525954", "E07A5F", pat="grate", wstyle="prison", pstyle="palisade", rstyle="shackles"),
    ],
    "mataram": [
        # Biome 0: Javanese Village, Market & Flooded Sawah (mt_gapura, mt_pasar, mt_sawah, mt_wetan)
        B("647842", "968978", "4E7358", "805B3E", "38261E", "874636", "AD5E4B", "D4A359",
          "366370", "59823E", "736B62", "FFE08A", pat="sawah", wstyle="majapahit", pstyle="palm", rstyle="offering"),
        # Biome 1: Candi Seribu Ancient Temple Ruins (mt_reruntuhan, mt_tegal, mt_candi)
        B("596346", "857E75", "69635B", "736C64", "2E2B29", "57524C", "787169", "ABA194",
          "2E525E", "635D56", "5E5852", "70E0D0", pat="candi", wstyle="candi", pstyle="column", rstyle="stupa"),
        # Biome 2: Mist-Shrouded War Graveyard (mt_kuburan)
        B("4A4F44", "6B6960", "3E4239", "54524B", "21241F", "40423B", "5C5E55", "C2C5B8",
          "263836", "4D423A", "636159", "F4F1DE", pat="grave", wstyle="ruin", pstyle="kamboja", rstyle="nisan"),
    ],
    "timur": [
        # Biome 0: Golden Savanna & Buto Ijo Hunting Grounds (tt_kulon, tt_sabana, tt_ladang)
        B("9E8044", "B8784A", "826836", "8C583A", "422618", "7A492E", "9E6342", "E6A145",
          "455E4B", "6E5236", "736050", "FF9F1C", pat="savanna", wstyle="stockade", pstyle="lontar", rstyle="skull"),
        # Biome 1: Dry Riverbed & Sacred Banyan Forge (tt_kali, tt_beringin)
        B("755E48", "96785E", "594236", "994536", "421C16", "8A382B", "B34F3E", "F2A93B",
          "B84A24", "5C3D28", "544945", "FF6B35", pat="forge", wstyle="majapahit", pstyle="banyan", rstyle="anvil"),
        # Biome 2: Bromo Sea of Sand & Cursed Keris Shrine (tt_pesisir, tt_pasir, tt_candi)
        B("524C4A", "6B625E", "423C3A", "593333", "241618", "4A282B", "6E3B3E", "D93848",
          "4F5E46", "594E4A", "3D3636", "FF2A55", pat="ash", wstyle="cursed", pstyle="tugu", rstyle="lingga"),
    ],
    "kidul": [
        # Biome 0: Black-Sand Beach & Stilt Fishing Village (sk_pantai, sk_nelayan, sk_tebing)
        B("424957", "B0A896", "36596B", "735842", "1F2B36", "384E5E", "547287", "68C7C2",
          "185770", "634B36", "4A5863", "FFE08A", pat="beach", wstyle="net", pstyle="palm", rstyle="boat"),
        # Biome 1: Flooded Coastal Mangrove Forest (sk_bakau)
        B("334A42", "5E6E5E", "285952", "5C4938", "182B26", "2B4740", "42695E", "7AE582",
          "1B4D4A", "4D392B", "3B4F49", "80ED99", pat="mangrove", wstyle="mangrove", pstyle="roots", rstyle="beacon"),
        # Biome 2: Coral Reef, Sunken Cavern & Sea Pavilion (sk_karang, sk_gua, sk_keraton)
        B("294C60", "8AB8B8", "246678", "2E786E", "122A36", "1F5463", "368596", "F2C94C",
          "103D52", "D95988", "3B6E7C", "56CFE1", pat="reef", wstyle="coral", pstyle="coral", rstyle="bell"),
    ],
    "kala": [
        # Biome 0: Abyssal Cavern Mouth & Petrified Forest (gk_mulut, gk_hutan)
        B("383245", "544A66", "453A57", "2E263B", "181224", "2E2342", "4D3B6E", "9D4EDD",
          "4A1880", "8C8596", "3B324A", "C77DFF", pat="petrified", wstyle="abyss", pstyle="petrified", rstyle="sundial"),
        # Biome 1: Sands of Forgetting & Void Bridge (gk_pasir, gk_lupa, gk_jembatan)
        B("282038", "635282", "3D2B59", "4A3B69", "110B1C", "24183B", "432E6B", "C77DFF",
          "300A59", "7B2CBF", "2E2245", "E0AAFF", pat="void", wstyle="void", pstyle="obelisk", rstyle="tablet"),
        # Biome 2: Batara Kala's Astral Temple Sanctum (gk_pelataran, gk_ruang_kala)
        B("241C30", "7A6236", "4A2E66", "332645", "140E1F", "33224A", "593D80", "FFD166",
          "5A189A", "C99B3B", "3D2B54", "FFE066", pat="zodiac", wstyle="kala", pstyle="brazier", rstyle="hourglass"),
    ],
    "kelir": [
        # Biome 0: Warm Blencong Wayang Screen (k0..k10, sq_*)
        B("C4B491", "A89674", "B5A27E", "917958", "2E231A", "4D3B2C", "705842", "D4A048",
          "2B252E", "5C4735", "63584C", "F2B84B", pat="kawung", wstyle="kelir", pstyle="gedebog", rstyle="blencong"),
        # Biome 1: Sepia Lontar Manuscript Scroll (h1..h4, k_ii, k_iii)
        B("B8A37A", "96805B", "A38D66", "786042", "261B12", "423020", "614832", "B8353A",
          "211B18", "4D3826", "544436", "D94B38", pat="lontar", wstyle="scroll", pstyle="pen", rstyle="seal"),
        # Biome 2: Cool Moonlight Laras Batik Screen (lc1..lc6)
        B("8A9BB0", "6E8096", "798DA3", "56677D", "1B2430", "2E3D52", "495E78", "9EE6FF",
          "182230", "3B4E66", "46566B", "BFF3FF", pat="megamendung", wstyle="kelir", pstyle="spindle", rstyle="crane"),
    ],
}


def _shadow_top(img, strength=0.65):
    out = img.copy()
    p = out.load()
    for y in range(4):
        f = strength + (1.0 - strength) * (y / 4.0)
        for x in range(S):
            r, g, b, a = p[x, y]
            p[x, y] = (int(r * f), int(g * f), int(b * f), a)
    return out


# ---------------- COL 0: GROUND ('.') ----------------
def draw_ground(P, sub_row):
    img = Image.new("RGBA", (S, S), P["ground"])
    p = img.load()
    for y in range(S):
        for x in range(S):
            h = (x * 11 + y * 17 + sub_row * 7) % 19
            if h == 0:
                p[x, y] = P["ground_shd"]
            elif h == 5 and (x + y) % 2 == 0:
                p[x, y] = P["ground_hi"]
    if sub_row == 1:
        # Variant B: lush grass tufts / clover patches / sand ripples
        for bx, by in ((3, 5), (11, 4), (7, 12), (13, 11)):
            p[bx, by] = P["ground_shd"]
            p[bx, by - 1] = P["ground_hi"]
            p[bx + 1, by - 1] = P["ground_hi"]
    elif sub_row == 2:
        # Variant C: Rich ground decor (wildflowers / fallen kamboja petals / glowing mushrooms / shells / crystals)
        for ax, ay in ((4, 5), (11, 11), (10, 4)):
            p[ax, ay] = P["accent"]
            p[ax - 1, ay] = P["ground_hi"]
            p[ax + 1, ay] = P["ground_hi"]
            p[ax, ay + 1] = P["ground_shd"]
    elif sub_row == 3:
        img = _shadow_top(img)
    elif sub_row == 4:
        # Variant E: mossy stepping stone / border tuft patch
        for y in range(5, 11):
            for x in range(5, 11):
                if (x - 7.5) ** 2 + (y - 7.5) ** 2 <= 7.0:
                    p[x, y] = P["path"] if y < 9 else P["path_shd"]
    return img


# ---------------- COL 1: PATH / ROAD / BRIDGE (',') ----------------
def draw_path(P, sub_row):
    img = Image.new("RGBA", (S, S), P["path"])
    p = img.load()
    for y in range(S):
        for x in range(S):
            h = (x * 7 + y * 13 + sub_row * 5) % 21
            if h == 0:
                p[x, y] = P["path_shd"]
            elif h == 3:
                p[x, y] = P["path_hi"]
    if sub_row == 0:
        for dx in range(5):
            p[3 + dx, 4] = P["path_hi"]
            p[3 + dx, 7] = P["path_shd"]
    elif sub_row == 1:
        # Variant B: Fitted cobblestone / flagstone pattern
        for y in range(S):
            for x in range(S):
                by = y % 8
                bx = (x + (4 if y >= 8 else 0)) % 8
                if by == 0 or bx == 0:
                    p[x, y] = P["path_shd"]
                elif by == 1 and bx > 1:
                    p[x, y] = P["path_hi"]
    elif sub_row == 2:
        # Variant C: Wheel ruts / lantern-lit stone / inlaid stepping stones
        for y in range(S):
            for rx in (4, 11):
                p[rx, y] = P["path_shd"]
                p[rx + 1, y] = P["path_hi"]
        p[8, 8] = P["accent"]
    elif sub_row == 3:
        img = _shadow_top(img)
    elif sub_row == 4:
        # Variant E: Curbed / bordered road edge
        for x in range(S):
            p[x, 0] = P["ground"]
            p[x, 1] = P["path_shd"]
            p[x, 2] = P["path_hi"]
            p[x, S - 1] = P["ground"]
            p[x, S - 2] = P["path_shd"]
    return img


# ---------------- COL 2: FEATURE / CULTIVATED ('t') ----------------
def draw_feature(P, sub_row):
    img = Image.new("RGBA", (S, S), P["feat_shd"])
    p = img.load()
    pat = P["pat"]
    if pat in ("carpet", "kawung"):
        for y in range(S):
            for x in range(S):
                cx, cy = (x % 8) - 3.5, (y % 8) - 3.5
                d = cx * cx + cy * cy
                if d < 5.5:
                    p[x, y] = P["accent"] if (d < 1.5 and sub_row == 2) else (P["feat_hi"] if d < 2.2 else P["feat"])
                elif x % 8 == 0 or y % 8 == 0:
                    p[x, y] = P["wall_trim"] if sub_row == 4 else P["feat_shd"]
                else:
                    p[x, y] = P["feat"]
    elif pat in ("sawah", "mangrove", "beach", "reef"):
        # Flooded water-bed with shoots / tidepool coral / mangrove marsh
        for y in range(S):
            for x in range(S):
                p[x, y] = P["water"] if (x + y) % 3 else P["feat"]
        for sy in (3, 10):
            for sx in (3, 8, 13):
                ox = (sx + sub_row) % 14 + 1
                p[ox, sy] = P["feat_hi"]
                p[ox, sy - 1] = P["accent"] if sub_row == 2 else P["feat_hi"]
                p[ox, sy + 1] = P["water_hi"]
    elif pat in ("candi", "grate", "zodiac", "void", "petrified"):
        # Carved temple floor relief / iron grate / astral mosaic
        for y in range(S):
            for x in range(S):
                edge = x in (0, S - 1) or y in (0, S - 1)
                diag = abs(x - 7.5) + abs(y - 7.5)
                if edge:
                    p[x, y] = P["feat_shd"]
                elif 4.5 <= diag <= 6.0:
                    p[x, y] = P["accent"] if sub_row == 2 else P["feat_hi"]
                else:
                    p[x, y] = P["feat"] if (x + y) % 2 == 0 else P["feat_shd"]
    elif pat in ("lontar", "megamendung"):
        # Inscribed lontar lines or cloud swirls
        for y in range(S):
            for x in range(S):
                if y % 4 == 0:
                    p[x, y] = P["feat_shd"]
                elif y % 4 == 2 and (x + sub_row * 2) % 3 != 0:
                    p[x, y] = P["accent"] if sub_row == 2 else P["feat_hi"]
                else:
                    p[x, y] = P["feat"]
    else:
        # Stepped tea terrace / savanna scrub / forge embers / ash dunes
        for y in range(S):
            ry = (y + sub_row * 2) % 8
            for x in range(S):
                if 1 <= ry <= 5 and (x + (y // 8) * 3) % 8 != 0:
                    p[x, y] = P["accent"] if (sub_row == 2 and ry == 2 and x % 5 == 0) else (P["feat_hi"] if ry == 1 else P["feat"])
                else:
                    p[x, y] = P["feat_shd"]
    if sub_row == 3:
        img = _shadow_top(img)
    return img


# ---------------- COL 3: INTERIOR FLOOR ('_') ----------------
def draw_floor(P, sub_row):
    img = Image.new("RGBA", (S, S), P["floor"])
    p = img.load()
    ws = P["wstyle"]
    for y in range(S):
        for x in range(S):
            if ws in ("palace", "candi", "prison", "cursed", "coral", "abyss", "void", "kala"):
                by = y % 8
                bx = (x + (4 if y >= 8 else 0)) % 8
                if by == 0 or bx == 0:
                    p[x, y] = P["floor_shd"]
                elif by == 1 and bx > 1:
                    p[x, y] = P["floor_hi"]
            else:
                py = y % 4
                seam = (x + (y // 4) * 5 + sub_row * 3) % S
                if py == 3 or x == seam:
                    p[x, y] = P["floor_shd"]
                elif py == 0:
                    p[x, y] = P["floor_hi"]
    if sub_row == 2:
        # Variant C: Woven interior mat / golden floor inlay / drainage grate
        for y in range(3, 13):
            for x in range(3, 13):
                if x in (3, 12) or y in (3, 12):
                    p[x, y] = P["wall_trim"]
                elif (x + y) % 2 == 0:
                    p[x, y] = P["feat"]
    elif sub_row == 3:
        img = _shadow_top(img)
    elif sub_row == 4:
        # Variant E: Doorway threshold / entrance steps
        for y in range(0, 6, 2):
            for x in range(S):
                p[x, y] = P["wall_trim"] if y == 0 else P["floor_hi"]
                p[x, y + 1] = P["floor_shd"]
    return img


# ---------------- COL 4: SOLID WALL ('#') ----------------
def draw_wall(P, sub_row):
    img = Image.new("RGBA", (S, S), P["wall_top"])
    p = img.load()
    ws = P["wstyle"]
    if sub_row in (0, 1):
        # Rooftop / wall interior crown
        for y in range(S):
            for x in range(S):
                if ws == "bilik":
                    # Thatch / ijuk roof texture
                    p[x, y] = P["wall_dark"] if (x + y * 3) % 5 == 0 else (shade(P["wall_top"], 1.15) if y % 3 == 0 else P["wall_top"])
                else:
                    p[x, y] = P["wall_dark"] if (x + y * 2 + sub_row) % 7 == 0 else P["wall_top"]
    elif sub_row in (2, 3):
        # 2.5D SOUTH-FACING WALL FACADE (sub_row 3 = standard facade; sub_row 2 = window / bookshelf / banner / prison-bar facade!)
        for y in range(S):
            for x in range(S):
                if y < 3:
                    p[x, y] = P["wall_top"]
                elif y == 3:
                    p[x, y] = P["wall_trim"]
                elif y == 4:
                    p[x, y] = P["wall_hi"]
                elif y >= 14:
                    p[x, y] = P["wall_dark"]
                elif ws == "bilik":
                    # Woven bamboo bilik diamond weave between timber beams
                    p[x, y] = P["wall_top"] if x in (0, 7, 15) else (P["wall_hi"] if ((x + y) % 4 < 2) else P["wall_face"])
                else:
                    cy = (y - 5) % 4
                    cx = (x + ((y - 5) // 4) * 4) % 8
                    p[x, y] = P["wall_top"] if (cy == 3 or cx == 0) else (P["wall_hi"] if cy == 0 else P["wall_face"])
        if sub_row == 2:
            # Decorated facade: bookshelf / lattice window / prison bars / carved relief / royal banner
            if ws == "shelf":
                # Lontar archive bookshelf rows
                for sy in (6, 10):
                    for x in range(2, 14):
                        p[x, sy] = P["wall_dark"]
                        p[x, sy + 1] = P["accent"] if x % 3 != 0 else P["wall_trim"]
                        p[x, sy + 2] = P["wall_hi"] if x % 2 == 0 else P["path"]
            elif ws == "prison":
                # Iron-barred cell window
                for y in range(5, 13):
                    for x in range(3, 13):
                        p[x, y] = P["wall_dark"] if x % 3 != 0 else P["wall_trim"]
            else:
                # Ornate window / glowing relief / royal banner
                for y in range(5, 13):
                    for x in range(5, 11):
                        if x in (5, 10) or y in (5, 12):
                            p[x, y] = P["wall_trim"]
                        else:
                            p[x, y] = P["accent"] if (x + y) % 3 == 0 else P["wall_dark"]
    elif sub_row == 4:
        # North wall top lip
        for y in range(S):
            for x in range(S):
                p[x, y] = P["wall_dark"] if y == 0 else (P["wall_hi"] if y == 1 else (P["wall_trim"] if y == 2 else P["wall_top"]))
    else:
        # Standalone single-tile wall cap
        img = draw_wall(P, 3)
        p = img.load()
        for x in range(S):
            p[x, 0] = P["wall_dark"]
            p[x, 1] = P["wall_hi"]
            p[x, 2] = P["wall_trim"]
    return img


# ---------------- COL 5: SOLID WATER / HAZARD ('~') ----------------
def draw_water(P, sub_row):
    img = Image.new("RGBA", (S, S), P["water"])
    p = img.load()
    for y in range(S):
        for x in range(S):
            if (x + y * 3) % 7 == 0:
                p[x, y] = P["water_deep"]
    sx = sub_row * 3
    for ry, wx in ((3, 2 + sx), (8, 9 + sx), (13, 5 + sx)):
        for dx in range(4):
            p[(wx + dx) % S, ry] = P["water_hi"]
    if sub_row == 2:
        # Variant C: Floating lotus pad + blossom / glowing coral / sulfur bubble ring
        for y in range(5, 12):
            for x in range(4, 12):
                if (x - 7.5) ** 2 + (y - 8.5) ** 2 <= 10.0 and not (x == 10 and y == 8):
                    p[x, y] = P["pillar"] if y > 7 else P["pillar_hi"]
        p[7, 7] = P["accent"]
        p[8, 7] = P["foam"]
    elif sub_row == 3:
        # North shoreline bank + foam
        for x in range(S):
            c = (x * 3) % 2
            for y in range(2 + c):
                p[x, y] = P["ground_shd"] if y == 1 + c else P["ground"]
            p[x, 2 + c] = P["wall_dark"]
            p[x, 3 + c] = P["foam"]
            p[x, 4 + c] = P["water_hi"]
    elif sub_row == 4:
        #South shoreline bank + foam
        for x in range(S):
            c = (x * 5) % 2
            p[x, S - 1] = P["ground"]
            p[x, S - 2 - c] = P["wall_dark"]
            p[x, S - 3 - c] = P["foam"]
    return img


# ---------------- COL 6: TALL FLORA / PILLAR / ARCHITECTURAL ('b') ----------------
def draw_pillar(P, sub_row):
    img = draw_ground(P, 0)
    p = img.load()
    for y in range(12, 16):
        for x in range(2, 14):
            p[x, y] = P["ground_shd"]
    ps = P["pstyle"]
    if sub_row == 2:
        # Variant C: Lit Torch Brazier / Royal Umbul-Umbul Banner / Glowing Totem
        for y in range(4, 15):
            for x in range(6, 10):
                p[x, y] = P["wall_dark"] if x in (6, 9) else P["pillar"]
        for y in range(1, 6):
            for x in range(5, 11):
                if abs(x - 7.5) + abs(y - 3.5) <= 3.5:
                    p[x, y] = P["accent"] if y < 4 else P["wall_trim"]
        return img
    if ps == "bamboo":
        cols = (3, 7, 11) if sub_row % 2 == 0 else (4, 9)
        for sx in cols:
            for y in range(1, 15):
                p[sx - 1, y] = P["wall_dark"]
                p[sx, y] = P["pillar_hi"] if y % 5 != 0 else P["pillar_shd"]
                p[sx + 1, y] = P["pillar"] if y % 5 != 0 else P["pillar_shd"]
                p[sx + 2, y] = P["wall_dark"]
        for lx, ly in ((2, 2), (6, 1), (10, 2), (13, 4)):
            p[lx, ly] = P["pillar_hi"]
    elif ps in ("tree", "banyan", "kamboja", "palm", "lontar", "roots", "mangrove", "deadtree", "petrified"):
        # Trunk
        for y in range(6, 15):
            for x in range(5, 11):
                p[x, y] = P["wall_dark"] if x in (5, 10) else (P["pillar_hi"] if x == 6 else P["pillar_shd"])
        # Canopy / Fronds / Branches
        for y in range(1, 9):
            for x in range(1, 15):
                if (x - 7.5) ** 2 / 38.0 + (y - 4.5) ** 2 / 14.0 <= 1.0:
                    if y == 8 or x in (1, 14):
                        p[x, y] = P["wall_dark"]
                    elif y < 4:
                        p[x, y] = P["accent"] if (sub_row == 1 and (x + y) % 5 == 0) else P["pillar_hi"]
                    else:
                        p[x, y] = P["pillar"]
    else:
        # Carved Pendopo / Candi / Coral / Obelisk Column
        for y in range(1, 15):
            w = 5 if y in (1, 2, 13, 14) else 4
            for x in range(8 - w, 8 + w):
                p[x, y] = P["wall_dark"] if (x in (8 - w, 8 + w - 1) or y in (1, 14)) else (
                    P["wall_trim"] if y in (2, 13) else (P["pillar_hi"] if x < 7 else P["pillar"]))
    return img


# ---------------- COL 7: ROCK / PROP / SHRINE / CLUTTER ('r') ----------------
def draw_rock(P, sub_row):
    img = draw_ground(P, 0)
    p = img.load()
    rs = P["rstyle"]
    if sub_row == 1:
        # Variant B: Terracotta Water Jar / Market Crate / Carved Plinth / Barrel
        for y in range(3, 15):
            w = 4 if y in (3, 4, 14) else 5
            for x in range(8 - w, 8 + w):
                if x in (8 - w, 8 + w - 1) or y in (3, 14):
                    p[x, y] = P["wall_dark"]
                elif y == 5:
                    p[x, y] = P["wall_trim"]
                elif x < 7:
                    p[x, y] = P["path_hi"]
                else:
                    p[x, y] = P["path_shd"]
        return img
    if sub_row == 2:
        # Variant C: Regional Cultural Prop (Shrine Offering / Smithy Anvil / Nisan Tombstone / Sunken Bell / Sundial)
        for y in range(2, 15):
            w = 3 if y < 6 else (5 if y < 12 else 6)
            for x in range(8 - w, 8 + w):
                if x in (8 - w, 8 + w - 1) or y in (2, 14):
                    p[x, y] = P["wall_dark"]
                elif y in (6, 12):
                    p[x, y] = P["accent"]
                elif x < 8:
                    p[x, y] = P["rock_hi"]
                else:
                    p[x, y] = P["rock"]
        return img
    # Rounded boulder / cluster rock (sub_rows 0, 3, 4)
    ox = -1 if sub_row == 3 else (1 if sub_row == 4 else 0)
    for y in range(3, 15):
        for x in range(1, 15):
            dx = (x - (7.5 + ox * 0.5)) / 6.0
            dy = (y - 8.5) / 5.2
            d = dx * dx + dy * dy
            if d <= 1.05:
                p[x, y] = P["wall_dark"] if (d > 0.76 or y == 14) else (
                    P["rock_hi"] if dx + dy < -0.3 else (P["rock_shd"] if dx + dy > 0.35 else P["rock"]))
    if sub_row == 3:
        # Moss / flower / ember cap on boulder
        p[6, 5] = P["accent"]
        p[7, 5] = P["pillar_hi"]
        p[8, 6] = P["pillar"]
    return img


# ---------------- ROW 15: LANDMARK / ARENA SETPIECES ----------------
def draw_landmark_row(P0, P1, P2):
    """Row 15: 8 special setpiece tiles usable across the region."""
    tiles = []
    # 0 '.': Flower/petal-strewn sacred ground
    tiles.append(draw_ground(P0, 2))
    # 1 ',': Wooden / stone plank bridge over water (used automatically when ',' touches '~'!)
    br = draw_water(P0, 0)
    bp = br.load()
    for y in range(1, 15):
        for x in range(S):
            if y in (1, 14):
                bp[x, y] = P0["wall_dark"]
            elif y in (2, 13):
                bp[x, y] = P0["wall_trim"]
            elif x % 4 == 0:
                bp[x, y] = P0["floor_shd"]
            else:
                bp[x, y] = P0["floor"] if y < 10 else P0["floor_shd"]
    tiles.append(br)
    # 2 't': Glowing ritual mosaic
    tiles.append(draw_feature(P1, 2))
    # 3 '_': Royal bordered carpet / dais
    tiles.append(draw_floor(P0, 2))
    # 4 '#': Ornate gateway / relief wall
    tiles.append(draw_wall(P1, 2))
    # 5 '~': Lotus / whirlpool / fumarole water
    tiles.append(draw_water(P1, 2))
    # 6 'b': Lit brazier / ceremonial banner
    tiles.append(draw_pillar(P0, 2))
    # 7 'r': Sacred shrine / monument statue
    tiles.append(draw_rock(P2, 2))
    return tiles


COLS_FN = [draw_ground, draw_path, draw_feature, draw_floor, draw_wall, draw_water, draw_pillar, draw_rock]


def build_region_sheet(reg_id):
    biomes = REGIONS[reg_id]
    sh = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    for b_idx, B_pal in enumerate(biomes):
        base_row = b_idx * 5
        for sub_row in range(5):
            r = base_row + sub_row
            for c, fn in enumerate(COLS_FN):
                sh.alpha_composite(fn(B_pal, sub_row), (c * S, r * S))
    for c, tile in enumerate(draw_landmark_row(*biomes)):
        sh.alpha_composite(tile, (c * S, 15 * S))
    return sh


def build_placeholder_tiles():
    B0 = REGIONS["sunda"][0]
    sh = Image.new("RGBA", (3 * S, S), (0, 0, 0, 0))
    sh.alpha_composite(draw_floor(B0, 0), (0, 0))
    sh.alpha_composite(draw_path(B0, 1), (S, 0))
    sh.alpha_composite(draw_wall(B0, 3), (2 * S, 0))
    return sh


def write_tiles_tres():
    reg_ids = list(REGIONS.keys())
    lines = ['[gd_resource type="TileSet" format=3 uid="uid://b606r7a4bthf5"]', ""]
    for idx, rid in enumerate(reg_ids):
        tex_path = "res://assets/art/sunda_tiles.png" if idx == 0 else f"res://assets/art/tiles_{rid}.png"
        lines.append(f'[ext_resource type="Texture2D" path="{tex_path}" id="{idx + 1}"]')
    lines.append("")
    for idx, rid in enumerate(reg_ids):
        lines.append(f'[sub_resource type="TileSetAtlasSource" id="src_{rid}"]')
        lines.append(f'texture = ExtResource("{idx + 1}")')
        for r in range(ROWS):
            for c in range(COLS):
                lines.append(f"{c}:{r}/0 = 0")
                if c >= 4:
                    lines.append(f"{c}:{r}/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)")
        lines.append("")
    lines.append("[resource]")
    lines.append("physics_layer_0/collision_layer = 1")
    lines.append("physics_layer_0/collision_mask = 0")
    for idx, rid in enumerate(reg_ids):
        lines.append(f'sources/{idx} = SubResource("src_{rid}")')
    lines.append("")
    tres_path = os.path.join(px.ROOT, "zones", "tiles.tres")
    with open(tres_path, "w") as f:
        f.write("\n".join(lines))
    print("wrote", tres_path)


SAMPLE_ROOM = [
    "##########",
    "#____#..b#",
    "#____#.r.#",
    "###_##.,.#",
    ".,,,,,,tt#",
    ".,~~~,~tt#",
    ".r~~~.b.r#",
    "##########",
]


def render_biome_sample(sh, biome_idx):
    LEG = ".,t_#~br"
    b0 = biome_idx * 5
    rw, rh = len(SAMPLE_ROOM[0]), len(SAMPLE_ROOM)
    out = Image.new("RGBA", (rw * S, rh * S), (0, 0, 0, 0))
    def at(x, y):
        return SAMPLE_ROOM[y][x] if (0 <= y < rh and 0 <= x < rw) else "#"
    for y in range(rh):
        for x in range(rw):
            c = at(x, y)
            col = LEG.find(c)
            up, dn, lf, rt = at(x, y - 1), at(x, y + 1), at(x - 1, y), at(x + 1, y)
            h = (x * 73 + y * 37) % 12
            if c == "#":
                sub = 3 if dn != "#" else (4 if up != "#" else (x + y) % 2)
                if sub == 3 and h % 3 == 0:
                    sub = 2  # decorated window/shelf/relief wall
                row = b0 + sub
            elif c == "~":
                sub = 3 if up != "~" else (4 if dn != "~" else (2 if h % 3 == 0 else (x + y) % 2))
                row = b0 + sub
            elif c == "," and (lf == "~" or rt == "~" or up == "~" or dn == "~"):
                row = 15  # bridge over water!
            elif c in ".,t_":
                if up == "#":
                    sub = 3
                elif c in ",_" and (up == "." or dn == "."):
                    sub = 4
                else:
                    sub = 2 if h < 2 else (1 if h < 6 else 0)
                row = b0 + sub
            else:
                sub = (x * 3 + y * 5) % 4
                row = b0 + sub
            tile = sh.crop((col * S, row * S, (col + 1) * S, (row + 1) * S))
            out.alpha_composite(tile, (x * S, y * S))
    return out


def main():
    samples = []
    for rid in REGIONS:
        sh = build_region_sheet(rid)
        out = px.save(sh, f"tiles_{rid}.png")
        print("wrote", out, sh.size)
        if rid == "sunda":
            shutil.copyfile(out, os.path.join(px.ART, "sunda_tiles.png"))
        samples.append([render_biome_sample(sh, b) for b in range(3)])
    ph = build_placeholder_tiles()
    ph.save(os.path.join(px.ART, "placeholder_tiles.png"))
    write_tiles_tres()

    # Contact sheet: 7 rows (regions) x 3 cols (Biome A, Biome B, Biome C)
    rw, rh = samples[0][0].size
    scale = 2
    pw = 3 * (rw * scale + 8) + 8
    ph_h = 7 * (rh * scale + 8) + 8
    prev = Image.new("RGBA", (pw, ph_h), (20, 15, 34, 255))
    for r_idx, row_rooms in enumerate(samples):
        for b_idx, rm in enumerate(row_rooms):
            big = rm.resize((rw * scale, rh * scale), Image.NEAREST)
            prev.alpha_composite(big, (8 + b_idx * (rw * scale + 8), 8 + r_idx * (rh * scale + 8)))
    prev_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "tileset_preview.png")
    prev.save(prev_path)
    scratch = "/Users/taufan.zamzami/.gemini/antigravity/brain/f643650e-c552-4c12-b6bf-2a7c6d77ba67/scratch"
    if os.path.isdir(scratch):
        prev.save(os.path.join(scratch, "tileset_preview.png"))
    print("wrote 21-biome preview", prev_path, prev.size)


if __name__ == "__main__":
    main()
