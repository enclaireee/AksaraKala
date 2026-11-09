#!/usr/bin/env python3
"""UI v2 "ink" surface set (ui.md 0, 5): everything drawn over the world shares one look.

Dark lacquer fill at ~90%, a 1 px near-black outline with chamfered corners, and one warm hairline inset by 1 px.
No studs, stitches, leather or wax: those belong to the paper book only. Run after gen_ui_rpg.py (it overwrites
frame_portrait, keycap, continue_arrow and arrow_objective with the v2 versions).

    python3 tools/gen_ui_ink.py
"""
from pathlib import Path
from PIL import Image

OUT = Path(__file__).resolve().parent.parent / "assets" / "art" / "ui"

EDGE = (8, 6, 4, 255)          # outline
FILL = (20, 14, 10, 232)       # lacquer, ~90%
WELL = (12, 8, 6, 245)         # recessed well (slots, portrait)
HAIR = (74, 58, 40, 255)       # warm hairline
HAIR_HI = (224, 179, 90, 255)  # accent gold hairline (focus)
GOLD = (224, 179, 90, 255)
GOLD_LO = (150, 110, 50, 255)
CREAM = (234, 223, 196, 255)
CREAM_LO = (165, 154, 130, 255)
INK = (20, 14, 10, 255)
T = (0, 0, 0, 0)


def panel(w, h, hair=HAIR, fill=FILL):
    im = Image.new("RGBA", (w, h), T)
    px = im.load()
    for y in range(h):
        for x in range(w):
            corner = (x in (0, w - 1)) and (y in (0, h - 1))
            if corner:
                continue
            edge = x in (0, w - 1) or y in (0, h - 1)
            px[x, y] = EDGE if edge else fill
    for x in range(2, w - 2):   # hairline inset 1 px inside the outline
        px[x, 1] = hair
        px[x, h - 2] = hair
    for y in range(2, h - 2):
        px[1, y] = hair
        px[w - 2, y] = hair
    return im


def well(w, h, hair=HAIR):
    im = panel(w, h, hair, WELL)
    px = im.load()
    for x in range(2, w - 2):   # inner shadow row: reads as recessed
        px[x, 2] = (4, 3, 2, 255)
    return im


def keycap():
    # 10x10 light key: cream face, darker bottom lip, ink outline; the letter is drawn by the game on top
    im = Image.new("RGBA", (10, 10), T)
    px = im.load()
    for y in range(10):
        for x in range(10):
            if (x in (0, 9)) and (y in (0, 9)):
                continue
            if x in (0, 9) or y in (0, 9):
                px[x, y] = INK
            elif y == 8:
                px[x, y] = CREAM_LO
            else:
                px[x, y] = CREAM
    return im


def tri_down():
    im = Image.new("RGBA", (5, 4), T)
    px = im.load()
    rows = ["#####", ".###.", "..#..", "....."]
    for y, r in enumerate(rows):
        for x, c in enumerate(r):
            if c == "#":
                px[x, y] = GOLD
    for x in range(5):   # dark underside so it reads on any panel
        if px[x, 3] == T and (x == 2):
            px[x, 3] = EDGE
    return im


def diamond(size=5, col=GOLD):
    im = Image.new("RGBA", (size, size), T)
    px = im.load()
    c = size // 2
    for y in range(size):
        for x in range(size):
            if abs(x - c) + abs(y - c) <= c:
                px[x, y] = col
    px[c, c] = (255, 236, 180, 255) if col == GOLD else col
    return im


def arrow():
    # 9x9 chevron pointing right, gold with a dark rim (rotated by the HUD toward the target)
    rows = [
        "##.......",
        "#O##.....",
        "#OOO##...",
        "#OOOOO##.",
        "#OOOOOOO#",
        "#OOOOO##.",
        "#OOO##...",
        "#O##.....",
        "##.......",
    ]
    im = Image.new("RGBA", (9, 9), T)
    px = im.load()
    for y, r in enumerate(rows):
        for x, c in enumerate(r):
            if c == "#":
                px[x, y] = EDGE
            elif c == "O":
                px[x, y] = GOLD
    return im


def ilmu_icon():
    # 8x8 cut gem (Ilmu): flat gold facets, one light facet, dark rim; reads at a glance
    rows = [
        "..####..",
        ".#hGGg#.",
        "#hhGGgg#",
        "#GGGGgg#",
        ".#GGgg#.",
        "..#Gg#..",
        "...##...",
        "........",
    ]
    im = Image.new("RGBA", (8, 8), T)
    px = im.load()
    for y, r in enumerate(rows):
        for x, c in enumerate(r):
            px[x, y] = {"#": EDGE, "G": GOLD, "g": GOLD_LO, "h": (255, 236, 180, 255)}.get(c, T)
    return im


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    panel(12, 12).save(OUT / "ink_panel.png")
    panel(12, 12, HAIR_HI).save(OUT / "ink_panel_focus.png")
    well(20, 20).save(OUT / "ink_slot.png")
    fp = well(56, 56)
    fp.save(OUT / "frame_portrait.png")
    keycap().save(OUT / "keycap.png")
    tri_down().save(OUT / "continue_arrow.png")
    diamond().save(OUT / "ink_cursor.png")
    arrow().save(OUT / "arrow_objective.png")
    ilmu_icon().save(OUT / "icon_ilmu.png")
    print("ink set ->", OUT)


if __name__ == "__main__":
    main()
