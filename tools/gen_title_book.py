#!/usr/bin/env python3
"""Main-screen art for Aksara Kala: an open leather-bound book on a dark desk, candle, ink pot and quill.
Run: python3 tools/gen_title_book.py   Output: assets/art/ui/title_*.png and tools/title_book_preview.png
Pure Python via gen_ui.Img. Light comes from the candle at the right.
"""
import math
import os
import random
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_ui as G
import gen_ui_rpg as R
from gen_ui import Img, hexc

OUT = G.OUT
CLEAR = (0, 0, 0, 0)
BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]


def lerpc(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3)) + (255,)


def make_desk():
    rnd = random.Random(5)
    w, h = 480, 270
    im = Img(w, h)
    planks = [(0, 52), (52, 100), (100, 150), (150, 204), (204, 270)]
    tones = [hexc("33211A"), hexc("2B1B14"), hexc("382318"), hexc("2E1D15"), hexc("352218")]
    for i, (y0, y1) in enumerate(planks):
        base = tones[i]
        for y in range(y0, y1):
            for x in range(w):
                c = base
                if rnd.random() < 0.02:
                    c = lerpc(base, hexc("1A100B"), 0.6)
                im.put(x, y, c)
        for g in range(16):                      # grain streaks
            gy = rnd.randrange(y0 + 3, y1 - 3)
            gx = rnd.randrange(0, w)
            ln = rnd.randrange(30, 140)
            col = lerpc(base, hexc("1A100B"), 0.5) if rnd.random() < 0.7 else lerpc(base, hexc("5A3A26"), 0.5)
            for x in range(gx, min(w, gx + ln)):
                im.put(x, gy + int(math.sin(x * 0.05 + g) * 1.2), col)
        im.rect(0, y1 - 1, w - 1, y1 - 1, hexc("120A07"))              # seam
        im.rect(0, y0, w - 1, y0, lerpc(base, hexc("5A3A26"), 0.45))   # top bevel
        kx, ky = rnd.randrange(30, w - 30), rnd.randrange(y0 + 10, y1 - 10)
        for r, col in ((5, hexc("24160F")), (3, hexc("1A100B")), (1, hexc("120A07"))):
            for yy in range(-r, r + 1):
                for xx in range(-r * 2, r * 2 + 1):
                    if (xx / 2.0) ** 2 + yy ** 2 <= r * r:
                        im.put(kx + xx, ky + yy, col)
    # candle light pool (dithered) and vignette
    cx, cy = 410, 80
    for y in range(h):
        for x in range(w):
            d = math.hypot(x - cx, (y - cy) * 1.2) / 250.0
            lit = max(0.0, 1.0 - d) ** 1.4
            v = math.hypot((x - 240) / 260.0, (y - 135) / 160.0)
            dark = min(1.0, max(0.0, v - 0.55) * 1.3)
            c = im.get(x, y)
            if lit * 16 > BAYER[y % 4][x % 4]:
                c = lerpc(c, hexc("A8702E"), 0.28 * lit + 0.1)
            if dark > 0 and (dark * 16 + (BAYER[y % 4][x % 4] - 8) * 0.4) > BAYER[(y + 1) % 4][(x + 2) % 4]:
                c = lerpc(c, hexc("0A0605"), min(0.8, dark * 0.9))
            im.put(x, y, c)
    return im


BW, BH = 372, 232      # book canvas (includes the ribbon below)
PW, PH = 168, 186      # page size
LX, RX, PY = 14, 190, 12


def paper_page(im, x0, side, rnd):
    """One page: paper, burnt edges, fibres, gutter shadow, stacked page edges."""
    for y in range(PY, PY + PH):
        for x in range(x0, x0 + PW):
            ex = min(x - x0, x0 + PW - 1 - x)
            ey = min(y - PY, PY + PH - 1 - y)
            e = min(ex, ey)
            c = R.PAPER
            if e < 2:
                c = R.PAPER_LO
            elif e < 5 and (e + BAYER[y % 4][x % 4] // 4) < 5:
                c = R.PAPER_MID
            if rnd.random() < 0.016:
                c = R.PAPER_MID
            elif rnd.random() < 0.004:
                c = R.PAPER_LO
            elif rnd.random() < 0.008:
                c = R.PAPER_HI
            gd = (PW - 1 - (x - x0)) if side == "L" else (x - x0)    # distance to the gutter
            if gd < 16 and (16 - gd) > BAYER[y % 4][x % 4] * 1.2:
                c = lerpc(c, hexc("6A5230"), 0.55 * (16 - gd) / 16.0)
            im.put(x, y, c)
    # stacked page edges under the page
    for k in range(5):
        col = R.PAPER_LO if k % 2 == 0 else R.PAPER_MID
        im.rect(x0 + (k if side == "L" else 0), PY + PH + k, x0 + PW - 1 - (0 if side == "L" else k), PY + PH + k, col)
    # outer side stack
    for k in range(4):
        col = R.PAPER_LO if k % 2 == 0 else R.PAPER_MID
        ox = x0 - 1 - k if side == "L" else x0 + PW + k
        im.rect(ox, PY + 2 + k, ox, PY + PH + 3, col)


def make_book():
    rnd = random.Random(9)
    im = Img(BW, BH)
    # drop shadow on the desk
    for y in range(8, BH - 24):
        for x in range(8, BW):
            im.put(x, y, (0, 0, 0, 110)) if (x + y) % 2 == 0 or (x > 12 and y > 12) else None
    # cover
    im.rect(0, 0, BW - 5, BH - 28, R.LEA_DK)
    im.rect(1, 1, BW - 6, BH - 29, R.LEA)
    im.rect(1, 1, BW - 6, 2, R.LEA_HI)
    im.rect(1, 1, 2, BH - 29, R.LEA_HI)
    im.rect(1, BH - 30, BW - 6, BH - 29, R.LEA_LO)
    im.rect(BW - 7, 1, BW - 6, BH - 29, R.LEA_LO)
    for x in range(8, BW - 12, 4):                    # stitching along the cover rim
        im.put(x, 5, R.STITCH); im.put(x + 1, 5, R.STITCH)
        im.put(x, BH - 34, R.STITCH); im.put(x + 1, BH - 34, R.STITCH)
    for y in range(8, BH - 36, 4):
        im.put(5, y, R.STITCH); im.put(5, y + 1, R.STITCH)
        im.put(BW - 11, y, R.STITCH); im.put(BW - 11, y + 1, R.STITCH)
    for (cx, cy, fx, fy) in ((1, 1, 1, 1), (BW - 7, 1, -1, 1), (1, BH - 30, 1, -1), (BW - 7, BH - 30, -1, -1)):
        for k in range(0, 16):                        # iron corner brackets
            im.put(cx + fx * k, cy + fy * 0, R.IRON); im.put(cx + fx * k, cy + fy * 1, R.IRON_LO)
            im.put(cx + fx * 0, cy + fy * k, R.IRON); im.put(cx + fx * 1, cy + fy * k, R.IRON_LO)
        im.put(cx + fx * 4, cy + fy * 4, R.IRON_HI); im.put(cx + fx * 8, cy + fy * 1, R.IRON_HI)
    paper_page(im, LX, "L", rnd)
    paper_page(im, RX, "R", rnd)
    # spine crease
    gx = LX + PW
    for y in range(PY, PY + PH):
        im.put(gx + 3, y, R.INK_SOFT)
        im.put(gx + 2, y, hexc("7A6240"))
        im.put(gx + 4, y, hexc("7A6240"))
    # ribbon bookmark from the spine, falling over the bottom edge
    for y in range(PY + PH - 6, BH - 2):
        for x in range(gx + 1, gx + 7):
            c = R.WAX if x < gx + 5 else R.WAX_LO
            if x == gx + 1:
                c = R.WAX_HI
            im.put(x, y, c)
    for k in range(4):                                # swallow-tail notch
        for x in range(gx + 3 - k // 2, gx + 5 + k // 2):
            im.put(x, BH - 2 - 3 + k if False else BH - 5 + k, CLEAR) if abs(x - (gx + 3.5)) < (k + 1) * 0.6 else None
    return im


def make_candle(frame):
    w, h = 14, 40
    im = Img(w, h)
    # brass dish
    im.rect(1, 33, 12, 35, hexc("8A6A28")); im.rect(1, 33, 12, 33, hexc("D8B858")); im.rect(3, 36, 10, 37, hexc("6A4A18"))
    im.rect(0, 34, 0, 35, hexc("6A4A18")); im.rect(13, 34, 13, 35, hexc("4A3210"))
    # wax
    im.rect(4, 14, 9, 33, hexc("EADFC4")); im.rect(4, 14, 5, 33, hexc("F6EED8")); im.rect(8, 14, 9, 33, hexc("B8AA88"))
    im.rect(4, 14, 9, 15, hexc("F6EED8"))
    for (x, y0, y1) in ((4, 15, 21), (9, 15, 26), (6, 15, 19)):
        im.rect(x, y0, x, y1, hexc("FFFBEA"))              # melt drips
    im.put(6, 13, hexc("2A1C12")); im.put(7, 13, hexc("2A1C12")); im.put(6, 12, hexc("2A1C12"))
    shapes = [
        [(7, 4), (5, 11), (9, 11)], [(8, 3), (5, 11), (9, 11)], [(6, 3), (5, 11), (9, 11)],
    ][frame]
    ys = range(4, 12)
    pts = shapes
    for y in range(3, 12):
        for x in range(3, 11):
            # point-in-triangle
            (x0, y0), (x1, y1), (x2, y2) = pts
            d1 = (x + .5 - x1) * (y0 - y1) - (x1 - x0) * (y + .5 - y1) if False else 0
            def sign(p1, p2, p3):
                return (p1[0] - p3[0]) * (p2[1] - p3[1]) - (p2[0] - p3[0]) * (p1[1] - p3[1])
            p = (x + .5, y + .5)
            a, b, c = sign(p, pts[0], pts[1]), sign(p, pts[1], pts[2]), sign(p, pts[2], pts[0])
            neg = a < 0 or b < 0 or c < 0
            pos = a > 0 or b > 0 or c > 0
            if not (neg and pos):
                im.put(x, y, hexc("FF9A22"))
    im.rect(6, 7, 7, 11, hexc("FFF0A0")) if frame != 1 else im.rect(7, 7, 8, 11, hexc("FFF0A0"))
    return im


def make_inkpot():
    im = Img(60, 48)
    # quill feather rising to the upper right
    for k in range(0, 40):
        x, y = 12 + int(k * 1.1), 30 - k
        im.put(x, y, hexc("F1E4BE")); im.put(x + 1, y, hexc("D2BC88")); im.put(x - 1, y, hexc("EADFC4"))
        if k > 8:
            im.put(x + 2, y, hexc("B89F6C")); im.put(x - 2, y + 1, hexc("D2BC88"))
    im.put(11, 31, R.INK); im.put(12, 30, R.INK)
    # pot
    for y in range(30, 44):
        for x in range(4, 24):
            dx = (x - 14) / 10.0
            dy = (y - 37) / 7.5
            if dx * dx + dy * dy <= 1.0:
                c = hexc("2C3036")
                if x < 10:
                    c = hexc("4A5058")
                if x > 19:
                    c = hexc("1C1F24")
                im.put(x, y, c)
    im.rect(8, 29, 20, 31, hexc("1C1F24")); im.rect(9, 29, 19, 29, hexc("0A0A0E"))     # ink surface
    im.rect(9, 28, 19, 28, hexc("4A5058"))
    return im


def make_seal():
    im = Img(16, 16)
    for y in range(16):
        for x in range(16):
            d = math.hypot(x - 7.5, y - 7.5)
            if d <= 7.3 + (1.0 if (x * 7 + y * 3) % 5 == 0 and d > 6 else 0):
                c = R.WAX
                if d > 5.7:
                    c = R.WAX_LO
                elif x + y < 12 and d > 4:
                    c = R.WAX_HI
                im.put(x, y, c)
    for (x, y) in ((7, 4), (8, 4), (6, 6), (9, 6), (6, 9), (9, 9), (7, 11), (8, 11), (5, 7), (10, 7), (7, 7), (8, 8)):
        im.put(x, y, R.WAX_LO)          # a stamped glyph: Ka
    return im


def make_scroll():
    im = Img(64, 16)
    im.rect(4, 3, 59, 12, R.PAPER)
    im.rect(4, 3, 59, 3, R.PAPER_HI); im.rect(4, 12, 59, 12, R.PAPER_LO)
    im.rect(0, 1, 6, 14, R.PAPER_MID); im.rect(0, 1, 1, 14, R.PAPER_HI); im.rect(5, 1, 6, 14, R.PAPER_LO)
    im.rect(57, 1, 63, 14, R.PAPER_MID); im.rect(57, 1, 58, 14, R.PAPER_HI); im.rect(62, 1, 63, 14, R.PAPER_LO)
    for x in range(10, 54, 3):
        im.put(x, 7, R.INK_FADE); im.put(x + 1, 7, R.INK_FADE)
    for x in range(12, 50, 4):
        im.put(x, 9, R.INK_FADE)
    im.rect(30, 1, 33, 14, R.WAX); im.rect(30, 1, 30, 14, R.WAX_HI)       # a red ribbon tied round it
    return im


def line(im, x0, y0, x1, y1, c):
    n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in range(n + 1):
        im.put(round(x0 + (x1 - x0) * i / n), round(y0 + (y1 - y0) * i / n), c)


def make_sketch():
    """A quick ink sketch for the left page: three hills, a low sun, birds, a river. 150x58, ink at ~80%."""
    w, h = 150, 58
    im = Img(w, h)
    ink = (60, 40, 26, 215)
    soft = (60, 40, 26, 130)
    # sun with rays
    cx, cy, r = 96, 22, 7
    for y in range(cy - r, cy + r + 1):
        for x in range(cx - r, cx + r + 1):
            d = math.hypot(x - cx, y - cy)
            if r - 1 <= d <= r:
                im.put(x, y, ink)
    for k in range(12):
        a = k * math.pi / 6
        line(im, cx + round(math.cos(a) * (r + 3)), cy + round(math.sin(a) * (r + 3)),
             cx + round(math.cos(a) * (r + 6)), cy + round(math.sin(a) * (r + 6)), soft)
    # hills (outline + hatching on the shaded side)
    peaks = [(28, 26), (64, 12), (118, 30)]
    base = 46
    for (px_, py_) in peaks:
        line(im, px_ - 30, base, px_, py_, ink)
        line(im, px_, py_, px_ + 30, base, ink)
        for k in range(4, base - py_, 3):
            line(im, px_ + 1 + k // 2, py_ + k, px_ + 4 + k // 2, py_ + k + 3, soft)
    # a temple-like stupa on the middle hill
    for (x, y) in ((64, 6), (63, 7), (65, 7), (62, 8), (66, 8)):
        im.put(x, y, ink)
    im.rect(61, 9, 67, 11, ink)
    # birds
    for (bx, by) in ((26, 8), (36, 4), (44, 11)):
        line(im, bx - 3, by, bx, by + 2, ink)
        line(im, bx, by + 2, bx + 3, by, ink)
    # river with ripples
    for x in range(6, 144):
        im.put(x, base + 2 + round(math.sin(x * 0.25) * 1.2), ink if x % 7 else soft)
    for x in range(18, 130, 13):
        line(im, x, base + 7, x + 6, base + 7, soft)
        line(im, x + 3, base + 10, x + 8, base + 10, soft)
    return im


def main():
    A = {"title_desk": make_desk(), "title_book": make_book(), "title_inkpot": make_inkpot(),
         "title_seal": make_seal(), "title_scroll": make_scroll(), "title_sketch": make_sketch()}
    cand = [make_candle(i) for i in range(3)]
    strip = Img(14 * 3, 40)
    for i, c in enumerate(cand):
        strip.paste(c, i * 14, 0)
    A["title_candle"] = strip
    for n, im in A.items():
        im.save(os.path.join(OUT, n + ".png"))
    pv = Img(480, 270)
    pv.paste(A["title_desk"], 0, 0)
    pv.paste(A["title_book"], 54, 18)
    pv.paste(A["title_inkpot"], 6, 200)
    pv.paste(cand[0], 428, 74)
    pv.paste(A["title_seal"], 420, 232)
    pv.paste(A["title_scroll"], 380, 212)
    pv.save(os.path.join(G.ROOT, "tools", "title_book_preview.png"))
    print("ok")


if __name__ == "__main__":
    main()
