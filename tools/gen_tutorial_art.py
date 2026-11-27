#!/usr/bin/env python3
"""Generate pixel-art UI assets for the Pelajaran Desa Purwa tutorial system.

Outputs to assets/art/ui/:
  tut_mouse_lmb.png  (24x16, 2 frames of 12x16: idle + LMB lit in warm gold)
  tut_mouse_rmb.png  (24x16, 2 frames of 12x16: idle + RMB lit in sky cyan)
  tut_ring.png       (112x28, 4 frames of 28x28: pulsing ground target ring)
  tut_spotlight.png  (16x16, 9-patch glowing corner-bracket HUD highlight)
  tut_check.png      (9x9, green tick with a lacquer outline)
"""
import math
import os
import sys
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import ART, hexc, sprite

OUT = os.path.join(ART, "ui")

# Senja dusk palette (ui.md 0.1 / ui_fx.gd)
LACQUER = hexc("#0A0814")
NIGHT = hexc("#141026")
NIGHT_HI = hexc("#2B234A")
RIM = hexc("#6E6394")
CREAM = hexc("#ECE6F2")
HEAD = hexc("#FFF4E6")
WARM = hexc("#F2B27A")
WARM_HI = hexc("#FFE0A8")
WARM_LO = hexc("#C98A52")
CYAN = hexc("#7FE8E0")
CYAN_LO = hexc("#3FB8C0")
OK = hexc("#8FD9A0")


MOUSE = [
    "..OOOOOOOO..",
    ".OccccccccO.",
    "OcLLLccRRRcO",
    "OcLLLwwRRRcO",
    "OcLLLwwRRRcO",
    "OcLLLccRRRcO",
    "OcLLLccRRRcO",
    "OccccccccccO",
    "OcbbbbbbbbcO",
    "OcbbbbbbbbcO",
    "OcbbbbbbbbcO",
    "OcbbbbbbbbcO",
    "OcbbbbbbbbcO",
    ".OcbbbbbbcO.",
    "..OccccccO..",
    "...OOOOOO...",
]


def _mouse_frame(side, lit):
    """One 12x16 mouse: lacquer rim, cream outline, navy body, a wheel between the buttons. When lit, the active
    button fills (amber for LMB, cyan for RMB: the cast colour) with a pale top row."""
    hi, mid = (WARM_HI, WARM) if side == "l" else (hexc("#D8FFFB"), CYAN)
    img = Image.new("RGBA", (12, 16), (0, 0, 0, 0))
    px = img.load()
    for y, row in enumerate(MOUSE):
        for x, ch in enumerate(row):
            if ch == "O":
                px[x, y] = LACQUER
            elif ch == "c":
                px[x, y] = CREAM
            elif ch == "w":
                px[x, y] = RIM
            elif ch == "b":
                px[x, y] = NIGHT_HI
            elif ch in "LR":
                on = lit and ch == side.upper()
                px[x, y] = (hi if y == 2 else mid) if on else NIGHT_HI
    return img


def make_mouse(side, filename):
    sheet = Image.new("RGBA", (24, 16), (0, 0, 0, 0))
    sheet.paste(_mouse_frame(side, False), (0, 0))
    sheet.paste(_mouse_frame(side, True), (12, 0))
    sheet.save(os.path.join(OUT, filename))


def make_ring():
    """4-frame 28x28 ground ring: a 2 px white stroke (code tints it) between dark 1 px edges, so it reads on grass
    and dirt alike; four pixel studs at the cardinal points."""
    sheet = Image.new("RGBA", (112, 28), (0, 0, 0, 0))
    cx, cy = 13.5, 13.5
    radii = [(9.5, 5.5), (10.5, 6.0), (11.5, 6.5), (10.5, 6.0)]
    alphas = [215, 255, 235, 195]
    def inside(x, y, rx, ry):
        return rx > 0 and ry > 0 and ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0
    for fi, ((rx, ry), a) in enumerate(zip(radii, alphas)):
        frame = Image.new("RGBA", (28, 28), (0, 0, 0, 0))
        px = frame.load()
        for y in range(28):
            for x in range(28):
                if inside(x, y, rx, ry) and not inside(x, y, rx - 2, ry - 2):
                    px[x, y] = (255, 250, 235, a)
                elif inside(x, y, rx - 2, ry - 2) and not inside(x, y, rx - 3, ry - 3):
                    px[x, y] = LACQUER[:3] + (int(a * 0.55),)    # dark inner edge
                elif inside(x, y, rx + 1, ry + 1) and not inside(x, y, rx, ry):
                    px[x, y] = LACQUER[:3] + (int(a * 0.4),)     # soft outer edge
        for ox, oy in ((int(round(cx)), int(round(cy - ry + 0.5))), (int(round(cx)), int(round(cy + ry - 0.5))),
                       (int(round(cx - rx + 0.5)), int(round(cy))), (int(round(cx + rx - 0.5)), int(round(cy)))):
            if 1 <= ox < 27 and 1 <= oy < 27:
                px[ox, oy] = (255, 255, 255, 255)
        sheet.paste(frame, (fi * 28, 0))
    sheet.save(os.path.join(OUT, "tut_ring.png"))


def make_spotlight():
    """16x16 9-patch corner-bracket highlight frame (white/alpha, code tints gold or cyan)."""
    rows = [
        "WWWWWW....WWWWWW",
        "Wsssss....sssssW",
        "Ws............sW",
        "Ws............sW",
        "Ws............sW",
        "Ws............sW",
        "................",
        "................",
        "................",
        "................",
        "Ws............sW",
        "Ws............sW",
        "Ws............sW",
        "Ws............sW",
        "Wsssss....sssssW",
        "WWWWWW....WWWWWW",
    ]
    pal = {
        "W": (255, 252, 240, 255),
        "s": (255, 240, 200, 115),
    }
    img = sprite(rows, pal, (16, 16))
    img.save(os.path.join(OUT, "tut_spotlight.png"))


def make_check():
    """9x9 tick: a 2 px green stroke with a 1 px lacquer outline, no disc."""
    core = {(6, 2), (7, 2), (5, 3), (6, 3), (1, 4), (4, 4), (5, 4), (1, 5), (2, 5), (3, 5), (4, 5), (2, 6), (3, 6)}
    img = Image.new("RGBA", (9, 9), (0, 0, 0, 0))
    px = img.load()
    for y in range(9):
        for x in range(9):
            if (x, y) in core:
                px[x, y] = OK
            elif any((x + dx, y + dy) in core for dx in (-1, 0, 1) for dy in (-1, 0, 1)):
                px[x, y] = LACQUER
    img.save(os.path.join(OUT, "tut_check.png"))


def main():
    os.makedirs(OUT, exist_ok=True)
    make_mouse("l", "tut_mouse_lmb.png")
    make_mouse("r", "tut_mouse_rmb.png")
    make_ring()
    make_spotlight()
    make_check()
    print("Generated 5 tutorial UI sprites in", OUT)


if __name__ == "__main__":
    main()
