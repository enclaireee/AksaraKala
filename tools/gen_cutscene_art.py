#!/usr/bin/env python3
"""Budayago cutscene art: Ruwatan wayang stage (Desa Purwa), the prologue/epilogue kelir and the K0 kelir memory.
Stdlib only (tools/pilite.py when PIL is missing). Output: assets/art/cutscene/*.png and tools/cutscene_preview.png
Run: python3 tools/gen_cutscene_art.py
Everything is authored with a tiny canvas (rect/ellipse/line/poly) so shapes stay readable at 1x.
Wayang puppets are single-ink silhouettes with punched holes (lubang) so the backlight shows through.
"""
import math
import os
import random
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pilite
pilite.install()
from PIL import Image
import pixlib as px
from pixlib import hexc

OUT = "cutscene"
INK = hexc("1C130F")
T = (0, 0, 0, 0)


class C:
    def __init__(self, w, h):
        self.im = Image.new("RGBA", (w, h), T)
        self.w, self.h = w, h

    def set(self, x, y, c):
        x, y = int(x), int(y)
        if 0 <= x < self.w and 0 <= y < self.h:
            self.im.putpixel((x, y), c)

    def get(self, x, y):
        return self.im.getpixel((x, y))

    def rect(self, x0, y0, x1, y1, c):
        for y in range(int(y0), int(y1) + 1):
            for x in range(int(x0), int(x1) + 1):
                self.set(x, y, c)

    def ell(self, cx, cy, rx, ry, c):
        for y in range(int(cy - ry - 1), int(cy + ry + 2)):
            for x in range(int(cx - rx - 1), int(cx + rx + 2)):
                if ((x + .5 - cx) / rx) ** 2 + ((y + .5 - cy) / ry) ** 2 <= 1.0:
                    self.set(x, y, c)

    def line(self, x0, y0, x1, y1, c, th=1):
        n = int(max(abs(x1 - x0), abs(y1 - y0))) * 2 + 1
        for i in range(n + 1):
            t = i / n
            x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
            for dx in range(th):
                for dy in range(th):
                    self.set(round(x) + dx, round(y) + dy, c)

    def poly(self, pts, c):
        ys = [p[1] for p in pts]
        for y in range(int(min(ys)), int(max(ys)) + 1):
            yy = y + .5
            xs = []
            for i in range(len(pts)):
                (ax, ay), (bx, by) = pts[i], pts[(i + 1) % len(pts)]
                if (ay <= yy < by) or (by <= yy < ay):
                    xs.append(ax + (yy - ay) / (by - ay) * (bx - ax))
            xs.sort()
            for i in range(0, len(xs) - 1, 2):
                for x in range(int(math.floor(xs[i] + .5)), int(math.floor(xs[i + 1] + .5))):
                    self.set(x, y, c)

    def hole(self, x, y):
        self.set(x, y, T)

    def holes(self, pts):
        for x, y in pts:
            self.hole(x, y)

    def mirror(self):
        """Copy the left half onto the right half (symmetric figures)."""
        for y in range(self.h):
            for x in range(self.w // 2):
                self.set(self.w - 1 - x, y, self.get(x, y))
        return self

    def done(self):
        return self.im


def save(img, name):
    px.save(img, f"{OUT}/{name}.png")
    return img


def strip(frames):
    w, h = frames[0].width, frames[0].height
    s = Image.new("RGBA", (w * len(frames), h), T)
    for i, f in enumerate(frames):
        s.alpha_composite(f, (i * w, 0))
    return s


def burn(img, seed=1):
    """Charred copy: dark, desaturated, flecked with ash and a few live embers."""
    rnd = random.Random(seed)
    out = img.copy()
    p = out.load()
    for y in range(out.height):
        for x in range(out.width):
            c = p[x, y]
            if c[3] == 0:
                continue
            g = int((c[0] + c[1] + c[2]) / 3 * 0.38)
            r = rnd.random()
            if r < 0.07:
                p[x, y] = (g + 38, g + 36, g + 34, c[3])
            elif r < 0.09:
                p[x, y] = (220, 90, 28, c[3])
            else:
                p[x, y] = (g + 6, g + 3, g + 2, c[3])
    return out


# ----------------------------------------------------------------------------------------------- puppets
def puppet_gunungan():
    c = C(24, 42)
    c.poly([(12, 0), (10, 4), (11, 9), (8, 12), (10, 17), (4, 22), (6, 29), (1, 34), (1, 41), (12, 41)], INK)
    c.mirror()
    c.holes([(12, 6), (12, 7), (12, 12), (11, 13), (12, 13), (12, 14), (10, 20), (13, 20), (11, 21), (12, 21),
             (9, 26), (14, 26), (12, 24), (12, 25), (12, 26), (12, 27)])
    c.rect(9, 31, 14, 40, T)             # the gate (pintu) with a tiny tree in it
    c.rect(11, 33, 12, 38, INK)
    c.holes([(10, 34), (13, 34), (10, 36), (13, 36)])
    c.set(11, 32, INK); c.set(12, 32, INK)
    return c.done()


def puppet_semar():
    c = C(24, 36)
    c.poly([(10, 3), (11, 0), (12, 3)], INK)           # kuncung
    c.ell(11, 8, 5, 5, INK)
    c.poly([(15, 7), (18, 9), (15, 11)], INK)           # nose
    c.ell(11, 21, 8.5, 9, INK)                          # the round belly
    c.rect(7, 28, 10, 34, INK); c.rect(12, 28, 15, 34, INK)
    c.rect(5, 34, 10, 35, INK); c.rect(12, 34, 17, 35, INK)
    c.line(17, 16, 22, 6, INK, 1)                       # raised hand
    c.holes([(13, 8), (9, 8), (14, 11), (13, 11), (11, 22), (11, 23), (7, 19), (15, 19), (8, 25), (14, 25)])
    return c.done()


def puppet_arjuna():
    c = C(22, 38)
    c.poly([(7, 4), (8, 0), (10, 2), (12, 0), (13, 4)], INK)     # crown
    c.ell(10, 7, 3, 4, INK)
    c.poly([(12, 7), (14, 8), (12, 9)], INK)
    c.poly([(7, 11), (13, 11), (12, 21), (8, 21)], INK)
    c.poly([(6, 21), (14, 21), (16, 32), (5, 32)], INK)
    c.rect(7, 32, 9, 37, INK); c.rect(11, 32, 13, 37, INK)
    c.line(12, 13, 17, 15, INK, 1)
    c.line(18, 8, 20, 15, INK); c.line(20, 15, 18, 24, INK)      # the bow
    c.line(18, 8, 18, 24, INK)
    c.holes([(10, 14), (10, 17), (8, 26), (11, 26), (14, 26), (9, 29), (12, 29), (11, 6)])
    return c.done()


def puppet_ajisaka():
    """The dalang's hero puppet of the prologue: a tall crowned figure holding a staff."""
    c = C(22, 50)
    c.poly([(8, 7), (9, 0), (11, 3), (13, 0), (14, 7)], INK)
    c.ell(11, 11, 3.5, 4.5, INK)
    c.poly([(14, 11), (16, 12), (14, 13)], INK)
    c.poly([(7, 16), (15, 16), (14, 29), (8, 29)], INK)
    c.poly([(6, 29), (16, 29), (19, 44), (3, 44)], INK)
    c.rect(7, 44, 10, 49, INK); c.rect(12, 44, 15, 49, INK)
    c.line(15, 19, 20, 22, INK); c.line(20, 8, 20, 46, INK)
    c.holes([(11, 10), (10, 19), (12, 19), (11, 22), (11, 25), (7, 34), (10, 34), (13, 34), (8, 38), (11, 38), (14, 38), (11, 3), (11, 5)])
    return c.done()


def puppet_buto():
    c = C(26, 38)
    c.poly([(4, 4), (8, 0), (11, 3), (15, 0), (20, 4), (18, 8), (6, 8)], INK)   # wild hair
    c.ell(12, 11, 6, 5, INK)
    c.ell(7, 13, 3, 3, INK)                                                      # bulbous nose
    c.poly([(8, 15), (18, 15), (17, 18), (8, 18)], INK)
    c.poly([(5, 19), (20, 19), (22, 31), (4, 31)], INK)
    c.rect(6, 31, 10, 36, INK); c.rect(14, 31, 18, 36, INK)
    c.line(21, 22, 24, 6, INK, 2)                                                # raised club
    c.ell(24, 5, 2, 3, INK)
    c.holes([(10, 10), (11, 10), (14, 10), (15, 10), (9, 16), (12, 16), (15, 16), (13, 23), (9, 23), (11, 27), (15, 27)])
    return c.done()


def puppet_kala():
    """Batara Kala, 60x72, faces left; the eyes are glow spots the scene draws at KALA_EYES."""
    c = C(60, 72)
    c.poly([(18, 28), (50, 24), (58, 71), (22, 71)], INK)                         # torso
    c.poly([(6, 22), (30, 10), (40, 26), (22, 34), (9, 31)], INK)                 # head
    c.poly([(10, 21), (1, 4), (7, 2), (15, 14)], INK)                             # near horn
    c.poly([(26, 11), (24, 1), (31, 0), (34, 11)], INK)                           # far horn
    c.poly([(8, 30), (20, 34), (18, 46), (11, 42), (6, 36)], INK)                 # lower jaw
    c.line(21, 40, 8, 54, INK, 3); c.line(8, 54, 2, 50, INK, 2); c.line(8, 54, 1, 57, INK, 2)   # reaching arm + claws
    c.line(8, 54, 4, 60, INK, 2)
    for x in (9, 12, 15):
        c.set(x, 31, T); c.set(x, 32, T)                                          # fangs read as light
    c.holes([(40, 38), (42, 44), (44, 38), (46, 50), (40, 56), (46, 62), (36, 62), (36, 48)])
    return c.done()


KALA_EYES = [(15, 20), (21, 18)]

# ----------------------------------------------------------------------------------------------- frame / cloth
WOOD = hexc("6A4529"); WOOD_HI = hexc("8D6038"); WOOD_LO = hexc("3F2616")
GOLD = hexc("E2B64A"); GOLD_HI = hexc("FFE08A"); GOLD_LO = hexc("A27820")
FRAME_W, FRAME_H = 92, 70
CLOTH = (6, 10, 80, 44)      # x, y, w, h of the cloth opening inside the frame


def post(c, x, top, bot, lo=WOOD_LO, mid=WOOD, hi=WOOD_HI):
    c.rect(x, top, x + 4, bot, mid)
    c.rect(x, top, x, bot, hi)
    c.rect(x + 4, top, x + 4, bot, lo)
    for y in range(top + 6, bot, 8):
        c.rect(x + 1, y, x + 3, y, lo)


def kelir_frame(burned=False):
    c = C(FRAME_W, FRAME_H)
    post(c, 0, 5, 62); post(c, FRAME_W - 5, 5, 62)
    for x in (0, FRAME_W - 5):                                          # gilded lotus finials
        c.poly([(x + 2, 0), (x + 5, 3), (x + 5, 6), (x - 0, 6), (x + 0, 3)], GOLD)
        c.set(x + 2, 1, GOLD_HI); c.set(x + 2, 2, GOLD_HI)
        c.rect(x, 5, x + 4, 5, GOLD_LO)
    c.rect(0, 6, FRAME_W - 1, 9, WOOD)                                    # top beam with gold inlay
    c.rect(0, 6, FRAME_W - 1, 6, WOOD_HI)
    c.rect(5, 8, FRAME_W - 6, 8, GOLD)
    for x in range(8, FRAME_W - 8, 6):
        c.set(x, 8, GOLD_HI)
    c.rect(0, 54, FRAME_W - 1, 57, WOOD); c.rect(0, 54, FRAME_W - 1, 54, WOOD_HI); c.rect(0, 57, FRAME_W - 1, 57, WOOD_LO)
    # gedebog: banana trunk the puppets are planted in
    G, GH, GL = hexc("6FA043"), hexc("9CCB64"), hexc("3F6B2C")
    c.rect(2, 58, FRAME_W - 3, 68, G); c.rect(2, 58, FRAME_W - 3, 59, GH); c.rect(2, 67, FRAME_W - 3, 68, GL)
    for x in range(8, FRAME_W - 4, 11):
        c.rect(x, 58, x, 68, GL)
    for x in range(5, FRAME_W - 4, 9):
        c.set(x, 62, GL); c.set(x + 2, 64, GH)
    img = px.outline(c.done(), 0.4, keep_pad=False)
    return burn(img, 3) if burned else img


def kelir_cloth(burned=False):
    w, h = CLOTH[2], CLOTH[3]
    c = C(w, h)
    rnd = random.Random(11)
    base, weave, edge = hexc("F6EDD0"), hexc("EADCB4"), hexc("D8C593")
    c.rect(0, 0, w - 1, h - 1, base)
    for y in range(h):
        for x in range(w):
            if (x + y * 2) % 7 == 0 and rnd.random() < 0.8:
                c.set(x, y, weave)
            if x < 2 or x >= w - 2 or y < 1 or y >= h - 1:
                c.set(x, y, edge)
    if not burned:
        return c.done()
    smoke, scorch = hexc("6B5E52"), hexc("2A1A12")
    for y in range(h):
        for x in range(w):
            d = (h - y) / h
            if rnd.random() < 0.65 * (1 - d) ** 1.5 + 0.1:
                c.set(x, y, smoke)
    tears = [[(30, 0), (44, 0), (39, 10), (46, 26), (36, 43), (24, 43), (29, 25), (22, 12)],
             [(4, 20), (13, 18), (16, 30), (8, 43), (0, 43)],
             [(62, 2), (74, 5), (68, 18), (73, 30), (60, 22)]]
    holes = C(w, h)
    for t in tears:
        holes.poly(t, (1, 1, 1, 255))
    for y in range(h):
        for x in range(w):
            if holes.get(x, y)[3]:
                continue
            near = any(0 <= x + dx < w and 0 <= y + dy < h and holes.get(x + dx, y + dy)[3]
                       for dx in (-1, 0, 1) for dy in (-1, 0, 1))
            if near:
                c.set(x, y, scorch if rnd.random() < 0.75 else hexc("E0661F"))
    for y in range(h):
        for x in range(w):
            if holes.get(x, y)[3]:
                c.hole(x, y)
    return c.done()


def kelir_glow():
    """Banded, dithered warm glow for the cloth (80x32): drawn over the cloth, flickered by alpha."""
    w, h = CLOTH[2], CLOTH[3]
    c = C(w, h)
    bayer = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]
    for y in range(h):
        for x in range(w):
            d = math.hypot((x - w / 2) / (w * 0.5), (y - h * 0.45) / (h * 0.62))
            lvl = max(0.0, 1.0 - d)
            lvl = lvl ** 1.2
            if lvl * 16 > bayer[y % 4][x % 4]:
                c.set(x, y, (255, 214, 120, 120 if lvl > 0.5 else 80))
    return c.done()


def blencong_frames():
    fr = []
    for f in range(3):
        c = C(14, 22)
        c.line(7, 0, 7, 8, hexc("6B5A3A"))
        flame = [[(7, 3), (5, 8), (9, 8)], [(7, 2), (5, 8), (9, 8)], [(8, 3), (5, 8), (9, 8)]][f]
        c.poly([(7, 5), (4, 11), (10, 11)], hexc("FF9A22"))
        c.poly(flame, hexc("FF9A22")); c.poly([(7, 6), (6, 10), (8, 10)], hexc("FFF0A0"))
        c.rect(3, 12, 10, 13, GOLD); c.rect(4, 14, 9, 15, GOLD_LO)
        c.poly([(10, 12), (13, 11), (11, 14)], GOLD)
        c.set(7, 12, GOLD_HI)
        fr.append(px.outline(c.done(), 0.4, keep_pad=False))
    return fr


# ----------------------------------------------------------------------------------------------- gamelan
BRONZE, BRONZE_HI, BRONZE_LO = hexc("B8872E"), hexc("F0CC66"), hexc("7A5418")


def gong_ageng(fallen=False):
    c = C(30, 40)
    post(c, 1, 6, 38); post(c, 24, 6, 38)
    c.rect(0, 5, 29, 8, WOOD); c.rect(0, 5, 29, 5, WOOD_HI); c.rect(0, 8, 29, 8, WOOD_LO)
    for x in (0, 25):
        c.poly([(x, 5), (x + 2, 0), (x + 4, 5)], GOLD); c.set(x + 2, 2, GOLD_HI)
    c.rect(0, 38, 5, 39, WOOD_LO); c.rect(24, 38, 29, 39, WOOD_LO)
    c.line(15, 8, 15, 12, hexc("D8C898"))
    c.ell(15, 24, 10.5, 11.5, BRONZE_LO)
    c.ell(15, 24, 9, 10, BRONZE)
    c.ell(14, 23, 6.5, 7.5, hexc("C99B3C"))
    c.ell(15, 24, 3.2, 3.2, BRONZE_HI)
    c.ell(15, 24, 1.5, 1.5, BRONZE)
    c.line(8, 17, 11, 14, BRONZE_HI)
    img = px.outline(c.done(), 0.4, keep_pad=False)
    return img


def saron():
    c = C(34, 18)
    c.rect(1, 9, 32, 15, hexc("5C3A22")); c.rect(1, 9, 32, 9, WOOD_HI); c.rect(1, 15, 32, 15, WOOD_LO)
    c.rect(2, 16, 4, 17, WOOD_LO); c.rect(29, 16, 31, 17, WOOD_LO)
    for x in (0, 31):
        c.poly([(x + 1, 6), (x + 2, 2), (x + 3, 6), (x + 3, 11), (x, 11)], GOLD)
    for i in range(7):
        x = 5 + i * 4
        hgt = 4 - (1 if i > 4 else 0)
        c.rect(x, 9 - hgt, x + 2, 8, BRONZE); c.rect(x, 9 - hgt, x + 2, 9 - hgt, BRONZE_HI)
        c.rect(x, 8, x + 2, 8, BRONZE_LO)
    return px.outline(c.done(), 0.4, keep_pad=False)


def kendang():
    c = C(20, 14)
    c.poly([(3, 3), (17, 3), (17, 11), (3, 11)], hexc("7A4B28"))
    c.ell(10, 7, 9, 4.5, hexc("7A4B28"))
    c.rect(3, 3, 17, 3, WOOD_HI)
    c.ell(2, 7, 2, 4, hexc("EBDDB4")); c.ell(18, 7, 2.5, 5, hexc("EBDDB4"))
    for x in range(5, 16, 3):
        c.line(x, 3, x + 2, 11, hexc("D8C898")); c.line(x + 2, 3, x, 11, hexc("D8C898"))
    c.rect(4, 12, 6, 13, WOOD_LO); c.rect(14, 12, 16, 13, WOOD_LO)
    return px.outline(c.done(), 0.4, keep_pad=False)


SK, SK_HI, SK_LO = hexc("D9985E"), hexc("F0BE88"), hexc("A06A3A")


def seated(jacket, sarong, band, frame, mallet=True, hat=True, belly=False):
    """A niyaga seated cross-legged, 20x22. frame 0 idle, 1 mallet raised, 2 mallet struck."""
    c = C(20, 22)
    c.ell(10, 18, 8, 3.5, sarong)                       # crossed legs under the sarong
    c.rect(3, 18, 16, 19, sarong)
    c.rect(4, 20, 7, 20, SK_LO); c.rect(12, 20, 15, 20, SK_LO)   # feet
    c.poly([(5, 17), (6, 9), (14, 9), (15, 17)], jacket)
    c.rect(6, 9, 7, 17, px.shade(jacket, 1.25)); c.rect(13, 10, 14, 17, px.shade(jacket, 0.7))
    c.rect(9, 11, 10, 17, px.shade(jacket, 0.8))        # jacket seam
    c.ell(10, 6, 3, 3.3, SK)
    c.set(8, 5, SK_HI); c.set(11, 6, hexc("201015")); c.set(9, 6, hexc("201015"))
    if hat:
        c.rect(7, 2, 13, 3, band); c.rect(8, 1, 12, 1, band); c.set(7, 4, band)   # blangkon / iket
        c.rect(8, 2, 12, 2, px.shade(band, 1.3))
    else:
        c.rect(7, 2, 13, 3, hexc("2A1D26"))
    # arms
    if frame == 0:
        c.line(6, 11, 4, 16, SK); c.line(14, 11, 16, 16, SK)
    elif frame == 1:
        c.line(6, 11, 3, 14, SK); c.line(14, 11, 17, 5, SK)
        c.line(17, 5, 17, 2, hexc("6B4E35")); c.ell(17, 1, 1.5, 1.5, hexc("D94B38"))
    else:
        c.line(6, 11, 3, 14, SK); c.line(14, 11, 17, 14, SK)
        c.line(17, 14, 18, 17, hexc("6B4E35")); c.ell(18, 18, 1.5, 1.5, hexc("D94B38"))
    return px.outline(c.done(), 0.4, keep_pad=False)


def child(shirt, sarong, frame, panic=False, hair=hexc("2A1D26")):
    """A village child on a mat, 14x16. frame 0/1 = breathing; panic = huddled, hands over head."""
    c = C(14, 16)
    by = 0 if frame == 0 else 1
    c.ell(7, 13, 5.5, 2.6, sarong)
    if panic:
        c.poly([(3, 13), (4, 8), (10, 8), (11, 13)], shirt)
        c.ell(7, 6, 3, 3, SK)
        c.rect(4, 3, 10, 4, hair)
        c.line(3, 9, 3, 4, SK, 1); c.line(10, 9, 10, 4, SK, 1)
        c.rect(3, 2, 5, 3, SK); c.rect(9, 2, 11, 3, SK)
        c.set(6, 6, SK_LO); c.set(8, 6, SK_LO)
    else:
        c.poly([(3, 12), (4, 6 + by), (10, 6 + by), (11, 12)], shirt)
        c.rect(4, 6 + by, 5, 11, px.shade(shirt, 1.25))
        c.ell(7, 4 + by, 3, 3, SK)
        c.rect(4, 1 + by, 10, 2 + by, hair)
        c.set(5, 4 + by, hexc("201015")); c.set(9, 4 + by, hexc("201015"))
        c.rect(5, 12, 9, 12, SK)
    return px.outline(c.done(), 0.4, keep_pad=False)


def mat(burned=False):
    c = C(24, 12)
    a, b, d = hexc("D9C68E"), hexc("BFA969"), hexc("8F7A42")
    c.rect(0, 0, 23, 11, a)
    for y in range(12):
        for x in range(24):
            if (x // 2 + y // 2) % 2 == 0:
                c.set(x, y, b)
    c.rect(0, 0, 23, 0, d); c.rect(0, 11, 23, 11, d); c.rect(0, 0, 0, 11, d); c.rect(23, 0, 23, 11, d)
    return burn(c.done(), 5) if burned else c.done()


# ----------------------------------------------------------------------------------------------- the raid
def torch_raider(frame):
    """Masked shadow raider with a torch, 18x28, 4 frames of sway/flame."""
    c = C(18, 28)
    sway = (0, 1, 0, -1)[frame]
    cl = hexc("0E0A12"); cl2 = hexc("231A2C")
    c.poly([(6 + sway, 11), (12 + sway, 11), (15, 26), (3, 26)], cl)
    c.rect(7 + sway, 11, 8 + sway, 25, cl2)
    c.ell(9 + sway, 7, 4, 4.5, cl)
    c.ell(9 + sway, 8, 2.7, 3.4, hexc("EFE9DA"))                   # the blank white mask
    c.rect(8 + sway, 7, 8 + sway, 8, hexc("1A1020")); c.rect(10 + sway, 7, 10 + sway, 8, hexc("1A1020"))
    c.set(9 + sway, 10, hexc("A89F8C"))
    c.line(12 + sway, 13, 15, 10, cl2, 2)                          # torch arm
    c.line(15, 10, 15, 4, hexc("5C3A22"), 1)
    fl = [[(14, 1), (13, 5), (17, 5)], [(15, 0), (13, 5), (17, 5)], [(14, 1), (12, 5), (16, 5)], [(15, 0), (13, 5), (17, 5)]][frame]
    c.poly(fl, hexc("FF8A1E"))
    c.poly([(15, 3), (14, 5), (16, 5)], hexc("FFE680"))
    for x in (5, 7, 10, 12):
        c.set(x, 26, T)
    return c.done()


def ink_creep():
    """Ink bleeding up and in from the edges of the cloth (80x32) while the raid is on."""
    w, h = CLOTH[2], CLOTH[3]
    c = C(w, h)
    rnd = random.Random(21)
    ink = (14, 8, 20, 235)
    for x in range(w):
        top = int(h * 0.55 + 7 * math.sin(x * 0.19) + 3 * math.sin(x * 0.47))
        for y in range(max(0, top), h):
            c.set(x, y, ink)
    for side in (0, 1):
        for y in range(h):
            reach = int(6 + 5 * math.sin(y * 0.3 + side * 2))
            for k in range(reach):
                c.set(k if side == 0 else w - 1 - k, y, ink)
    for _ in range(40):
        x, y = rnd.randrange(w), rnd.randrange(h)
        if c.get(x, y)[3] == 0 and any(0 <= x + dx < w and 0 <= y + dy < h and c.get(x + dx, y + dy)[3]
                                       for dx in (-2, 2) for dy in (-2, 2)):
            c.set(x, y, ink)
    return c.done()


def lamp_stand_frames():
    """Brass standing oil lamp (K0 kelir), 14x24: frame 0 unlit, 1-3 lit."""
    fr = []
    for f in range(4):
        c = C(14, 24)
        c.rect(4, 21, 9, 22, GOLD_LO); c.rect(5, 20, 8, 20, GOLD)           # foot
        c.rect(6, 12, 7, 19, GOLD); c.set(6, 14, GOLD_HI); c.set(6, 17, GOLD_HI)
        c.poly([(2, 9), (11, 9), (10, 12), (3, 12)], GOLD); c.rect(2, 9, 11, 9, GOLD_HI)
        c.poly([(10, 9), (13, 8), (11, 11)], GOLD)                             # wick spout
        if f:
            fl = [[(7, 2), (4, 9), (10, 9)], [(8, 3), (4, 9), (10, 9)], [(6, 3), (4, 9), (10, 9)]][f - 1]
            c.poly(fl, hexc("FF9A22")); c.poly([(7, 5), (6, 9), (8, 9)], hexc("FFF0A0"))
        else:
            c.rect(6, 8, 7, 8, hexc("3A2A20"))
        fr.append(px.outline(c.done(), 0.4, keep_pad=False))
    return fr


# ----------------------------------------------------------------------------------------------- memory cast
def puppet_putri():
    """A woman (Dayang Sumbi, Timun Mas's mother, Wiryo's wife): bun, kebaya, long kain."""
    c = C(20, 38)
    c.ell(10, 3, 3, 2.5, INK)                                    # bun
    c.ell(10, 8, 3.2, 4, INK); c.poly([(12, 8), (14, 9), (12, 10)], INK)
    c.poly([(7, 12), (13, 12), (12, 21), (8, 21)], INK)
    c.poly([(7, 21), (13, 21), (16, 36), (4, 36)], INK)
    c.line(13, 14, 17, 19, INK); c.line(7, 14, 4, 20, INK)
    c.holes([(10, 8), (10, 15), (10, 18), (7, 28), (10, 28), (13, 28), (8, 32), (12, 32), (10, 3)])
    return c.done()


def puppet_pande():
    """The smith (Pande Besi) swinging a hammer."""
    c = C(26, 36)
    c.ell(10, 7, 4, 4.5, INK); c.rect(6, 2, 14, 3, INK)
    c.poly([(5, 12), (16, 12), (17, 24), (4, 24)], INK)
    c.rect(5, 24, 9, 34, INK); c.rect(12, 24, 16, 34, INK)
    c.line(15, 14, 21, 6, INK, 2); c.rect(19, 2, 24, 6, INK)       # hammer
    c.line(5, 16, 3, 24, INK)
    c.holes([(9, 7), (9, 15), (12, 15), (9, 19), (12, 19), (7, 28), (14, 28)])
    return c.done()


def puppet_cepot():
    c = C(22, 34)
    c.poly([(8, 2), (10, 0), (12, 2)], INK); c.ell(10, 7, 4.5, 4.5, INK)
    c.poly([(14, 7), (18, 8), (14, 10)], INK)
    c.ell(10, 20, 5.5, 8, INK)
    c.rect(6, 27, 8, 32, INK); c.rect(12, 27, 14, 32, INK); c.rect(4, 32, 8, 33, INK); c.rect(12, 32, 17, 33, INK)
    c.line(14, 15, 19, 11, INK); c.line(6, 15, 3, 22, INK)
    c.holes([(11, 6), (9, 6), (13, 10), (9, 18), (10, 22), (8, 25), (12, 25)])
    return c.done()


def puppet_lutung():
    c = C(26, 28)
    c.ell(7, 7, 4, 4, INK); c.ell(5, 9, 2, 2, INK)
    c.poly([(5, 11), (15, 11), (19, 21), (6, 21)], INK)
    c.line(18, 18, 24, 8, INK, 1); c.line(24, 8, 22, 4, INK)         # curling tail
    c.rect(6, 21, 8, 27, INK); c.rect(13, 21, 15, 27, INK)
    c.line(5, 13, 1, 20, INK); c.line(14, 13, 18, 16, INK)
    c.holes([(7, 6), (9, 15), (11, 17)])
    return c.done()


def puppet_bangau():
    c = C(26, 34)
    c.poly([(2, 4), (7, 2), (7, 5), (4, 6)], INK)                    # beak
    c.ell(8, 4, 2.5, 2.5, INK); c.line(8, 6, 11, 16, INK, 2)          # neck
    c.poly([(8, 14), (22, 12), (24, 20), (12, 24)], INK)              # body
    c.poly([(20, 12), (26, 6), (25, 14)], INK)                        # wing tip
    c.line(14, 24, 14, 33, INK); c.line(18, 22, 19, 33, INK)
    c.holes([(8, 4), (15, 17), (18, 16)])
    return c.done()


def puppet_perahu():
    c = C(40, 26)
    c.poly([(0, 14), (40, 14), (34, 22), (6, 22)], INK)
    c.line(20, 14, 20, 0, INK, 2); c.poly([(21, 1), (33, 12), (21, 12)], INK)    # sail
    c.line(0, 14, 3, 8, INK); c.line(40, 14, 37, 8, INK)
    c.holes([(10, 18), (16, 18), (22, 18), (28, 18), (25, 8), (28, 10)])
    return c.done()


def puppet_kerbau():
    c = C(36, 26)
    c.poly([(8, 8), (28, 6), (32, 18), (8, 20)], INK)
    c.ell(6, 10, 4, 3.5, INK); c.line(2, 8, 0, 3, INK); c.line(8, 6, 10, 2, INK)   # horns
    for x in (10, 14, 24, 28):
        c.rect(x, 19, x + 1, 25, INK)
    c.line(32, 10, 35, 18, INK)
    c.holes([(6, 9), (15, 12), (20, 12), (25, 12)])
    return c.done()


def puppet_lesung():
    c = C(26, 22)
    c.poly([(3, 6), (23, 6), (20, 21), (6, 21)], INK)
    c.line(13, 8, 21, 0, INK, 2); c.rect(19, 0, 23, 2, INK)           # alu pestle
    c.holes([(8, 12), (13, 12), (18, 12), (10, 16), (16, 16)])
    return c.done()


def shade_walker(frame):
    """A walking Kelir shadow (MemoryThreat body): a tall ragged puppet, 4 frames, eyes baked in light."""
    c = C(18, 30)
    sw = (0, 1, 0, -1)[frame]
    c.poly([(5 + sw, 4), (13 + sw, 4), (15, 20), (17 + sw, 29), (1 + sw, 29), (3, 20)], hexc("120A14"))
    c.ell(9 + sw, 5, 4, 4.5, hexc("120A14"))
    c.poly([(5 + sw, 2), (7 + sw, 0), (9 + sw, 2), (11 + sw, 0), (13 + sw, 2)], hexc("120A14"))
    for x in (3, 6, 9, 12, 15):
        c.set(x + sw, 29, T)
    c.line(3, 12, 0, 22 + (frame % 2) * 2, hexc("120A14"), 2)
    c.line(15, 12, 17, 22 - (frame % 2) * 2, hexc("120A14"), 2)
    c.rect(7 + sw, 5, 8 + sw, 5, hexc("FFB030")); c.rect(11 + sw, 5, 11 + sw, 5, hexc("FFB030"))
    c.holes([(8, 14), (10, 14), (9, 18)])
    return px.outline(c.done(), 0.5, keep_pad=False)


def faceless_shade(frame):
    """FacelessPatrol body: pale mask, dark robe, 18x30; 4 sway frames."""
    c = C(18, 30)
    sw = (0, 1, 0, -1)[frame]
    c.poly([(5 + sw, 10), (13 + sw, 10), (16, 28), (2, 28)], hexc("2A2438"))
    c.rect(8 + sw, 10, 9 + sw, 27, hexc("40385A"))
    c.ell(9 + sw, 6, 4, 5, hexc("1A1424"))
    c.ell(9 + sw, 6, 3, 4, hexc("E8E4D6"))
    c.rect(7 + sw, 6, 7 + sw, 7, hexc("1A1424")); c.rect(11 + sw, 6, 11 + sw, 7, hexc("1A1424"))
    c.line(4 + sw, 13, 2, 22, hexc("2A2438"), 2); c.line(14 + sw, 13, 16, 22, hexc("2A2438"), 2)
    for x in (4, 7, 10, 13):
        c.set(x, 28, T)
    return px.outline(c.done(), 0.5, keep_pad=False)


def gap_tear(frame):
    """A tear in the memory cloth where a piece of the past is missing (MemorySpot gap), 24x20, 2 frames."""
    c = C(24, 20)
    pts = [(12, 0), (19, 4), (23, 10), (18, 18), (10, 19), (3, 15), (0, 8), (5, 2)]
    pts = [(x + (1 if (i + frame) % 2 else 0), y) for i, (x, y) in enumerate(pts)]
    c.poly(pts, hexc("191220"))
    c.poly([(x * 0.7 + 3.5, y * 0.7 + 3) for x, y in pts], hexc("0A060E"))
    for i, (x, y) in enumerate(pts):
        c.set(x, y, hexc("C8B88A") if i % 2 else hexc("8A7A5A"))     # frayed thread ends
    for i in range(4):
        c.set(6 + i * 4, 8 + (i + frame) % 3, hexc("FFE9A8"))        # faint motes of the lost memory
    return px.outline(c.done(), 0.4, keep_pad=False)


def goal_gate(open_):
    """The exit gunungan gate of a memory, 20x30: dim when closed, glowing when open."""
    c = C(20, 30)
    body = hexc("6A4A2E") if not open_ else hexc("B8872E")
    c.poly([(10, 0), (7, 5), (8, 10), (3, 15), (4, 22), (1, 29), (19, 29), (16, 22), (17, 15), (12, 10), (13, 5)], body)
    c.rect(6, 17, 13, 29, hexc("F6D98A") if open_ else hexc("120C08"))
    if open_:
        c.rect(8, 19, 11, 29, hexc("FFFFFF")); c.holes([])
    else:
        c.rect(9, 17, 10, 29, hexc("3A2A18"))
    c.set(10, 3, hexc("FFE08A") if open_ else hexc("8A6A3A"))
    return px.outline(c.done(), 0.4, keep_pad=False)


def kelir_post_tile():
    c = C(8, 16)
    post(c, 1, 0, 15)
    return c.done()


def prologue_floor():
    """Banana-trunk gedebog strip + wooden rail for the prologue screen, 400x16 (tiled horizontally from 40 px)."""
    c = C(40, 16)
    G, GH, GL = hexc("6FA043"), hexc("9CCB64"), hexc("3F6B2C")
    c.rect(0, 2, 39, 15, G); c.rect(0, 2, 39, 3, GH); c.rect(0, 14, 39, 15, GL)
    c.rect(0, 2, 0, 15, GL); c.rect(20, 2, 20, 15, GL)
    for x, y in ((6, 8), (10, 10), (27, 7), (33, 11)):
        c.set(x, y, GL); c.set(x + 1, y + 1, GH)
    c.rect(0, 0, 39, 1, WOOD)
    return c.done()


def cloth_tile():
    """Seamless 16x16 backlit cloth for the Kelir memory backdrop."""
    c = C(16, 16)
    base, weave, deep = hexc("EADFC0"), hexc("DFD0A6"), hexc("D2C192")
    c.rect(0, 0, 15, 15, base)
    for y in range(16):
        for x in range(16):
            if (x + y * 2) % 8 == 0:
                c.set(x, y, weave)
            if (x * 3 + y) % 17 == 0:
                c.set(x, y, deep)
    return c.done()


def beam_tile():
    """Carved top beam, 16x12, repeats horizontally."""
    c = C(16, 12)
    c.rect(0, 0, 15, 11, WOOD); c.rect(0, 0, 15, 1, WOOD_HI); c.rect(0, 10, 15, 11, WOOD_LO)
    c.rect(0, 5, 15, 5, GOLD); c.set(4, 5, GOLD_HI); c.set(12, 5, GOLD_HI)
    c.poly([(8, 2), (10, 4), (8, 4)], GOLD_LO); c.poly([(8, 7), (10, 9), (8, 9)], GOLD_LO)
    c.rect(0, 6, 15, 6, WOOD_LO)
    return c.done()


def ember_frames():
    fr = []
    for col in (hexc("FF8A1E"), hexc("FFD060"), hexc("C8421A")):
        c = C(3, 3)
        c.set(1, 1, col); c.set(1, 0, px.shade(col, 0.7))
        fr.append(c.done())
    return fr


def main():
    previews = []
    save(puppet_gunungan(), "puppet_gunungan"); save(puppet_semar(), "puppet_semar")
    save(puppet_arjuna(), "puppet_arjuna"); save(puppet_ajisaka(), "puppet_ajisaka")
    save(puppet_buto(), "puppet_buto"); save(puppet_kala(), "puppet_kala")
    save(kelir_frame(), "kelir_frame"); save(kelir_frame(True), "kelir_frame_burned")
    save(kelir_cloth(), "kelir_cloth"); save(kelir_cloth(True), "kelir_cloth_burned")
    save(kelir_glow(), "kelir_glow"); save(strip(blencong_frames()), "blencong")
    gong = gong_ageng(); save(gong, "gong_ageng"); save(burn(gong, 2), "gong_ageng_burned")
    sar = saron(); save(sar, "saron"); save(burn(sar, 4), "saron_burned")
    ken = kendang(); save(ken, "kendang"); save(burn(ken, 6), "kendang_burned")
    save(strip([seated(hexc("5A3E7A"), hexc("32224F"), hexc("8A3030"), f) for f in (0, 1, 2)]), "niyaga_gong")
    save(strip([seated(hexc("3E5C7A"), hexc("5A3A20"), hexc("2A5C4A"), f) for f in (0, 1, 2)]), "niyaga_saron")
    save(strip([seated(hexc("7A3E3E"), hexc("3A2A18"), hexc("C9A14A"), 0, hat=False)]), "niyaga_kendang")
    save(strip([child(hexc("E8DCC0"), hexc("A6473F"), f) for f in (0, 1)] + [child(hexc("E8DCC0"), hexc("A6473F"), 0, True)]), "child_a")
    save(strip([child(hexc("D8E0C8"), hexc("3F8C73"), f, hair=hexc("3A2418")) for f in (0, 1)] + [child(hexc("D8E0C8"), hexc("3F8C73"), 0, True, hexc("3A2418"))]), "child_b")
    save(mat(), "mat"); save(mat(True), "mat_burned")
    save(strip([torch_raider(f) for f in range(4)]), "torch_raider")
    save(strip(lamp_stand_frames()), "lamp_stand")
    for n, f in (("putri", puppet_putri), ("pande", puppet_pande), ("cepot", puppet_cepot), ("lutung", puppet_lutung),
                 ("bangau", puppet_bangau), ("perahu", puppet_perahu), ("kerbau", puppet_kerbau), ("lesung", puppet_lesung)):
        save(f(), "puppet_" + n)
    save(strip([shade_walker(i) for i in range(4)]), "shade_walker")
    save(strip([faceless_shade(i) for i in range(4)]), "faceless_shade")
    save(strip([gap_tear(0), gap_tear(1)]), "gap_tear")
    save(strip([goal_gate(False), goal_gate(True)]), "goal_gate")
    save(prologue_floor(), "prologue_floor"); save(cloth_tile(), "cloth_tile"); save(beam_tile(), "beam_tile"); save(kelir_post_tile(), "post_tile")
    save(ink_creep(), "ink_creep"); save(strip(ember_frames()), "ember")
    names = ["puppet_gunungan", "puppet_semar", "puppet_arjuna", "puppet_ajisaka", "puppet_buto", "puppet_kala",
             "kelir_frame", "kelir_cloth", "kelir_cloth_burned", "gong_ageng", "saron", "kendang", "niyaga_gong",
             "puppet_putri", "puppet_pande", "puppet_cepot", "puppet_lutung", "puppet_bangau", "puppet_perahu", "puppet_kerbau", "puppet_lesung", "shade_walker", "faceless_shade", "gap_tear", "goal_gate", "niyaga_saron", "child_a", "child_b", "mat", "torch_raider", "blencong", "ink_creep"]
    imgs = []
    for n in names:
        im = Image.new("RGBA", (1, 1), T)
        im = _load(n)
        imgs.append((n, im))
    px.preview(imgs, os.path.join(os.path.dirname(os.path.abspath(__file__)), "cutscene_preview.png"), scale=3, bg=(214, 168, 90, 255))
    print("ok")


def _load(n):
    """Read a saved PNG back through the shim-free path: we only need it for the contact sheet."""
    import struct
    import zlib
    with open(os.path.join(px.ART, OUT, n + ".png"), "rb") as f:
        d = f.read()
    pos, idat, w, h = 8, b"", 0, 0
    while pos < len(d):
        ln = struct.unpack(">I", d[pos:pos + 4])[0]
        t = d[pos + 4:pos + 8]
        body = d[pos + 8:pos + 8 + ln]
        if t == b"IHDR":
            w, h = struct.unpack(">II", body[:8])
        elif t == b"IDAT":
            idat += body
        pos += 12 + ln
    raw = zlib.decompress(idat)
    im = Image.new("RGBA", (w, h), T)
    i = 0
    for y in range(h):
        i += 1
        for x in range(w):
            im.putpixel((x, y), tuple(raw[i:i + 4]))
            i += 4
    return im


if __name__ == "__main__":
    main()
