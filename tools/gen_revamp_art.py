#!/usr/bin/env python3
"""Revamp art pass (2026-11-10, .docs/revamp_plan.md 1 and 3): the sprites that used to be code-drawn.

K0 kelir: the full screen (cloth, frame, log, dark house), Batara Kala (3 poses), the shadow tide edge, lamp glow,
lamp ignition burst, unlit-lamp hint ring, wayang pointing hand.
Combat and world: aim pointers per weapon archetype, arrow, spirit shot, thrown rock, chest, kabut fog,
pillar, oncor, curse stake, pouch fields, arena post.
Run: python3 tools/gen_revamp_art.py     (writes assets/art/... and tools/revamp_preview.png)
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
from gen_cutscene_art import C, strip, INK, T, WOOD, WOOD_HI, WOOD_LO, GOLD, GOLD_HI, GOLD_LO

HERE = os.path.dirname(os.path.abspath(__file__))
PREVIEW = []


def out(img, rel, preview=True):
    px.save(img, rel)
    if preview:
        PREVIEW.append((rel, img))
    return img


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(4))


BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]

# ----------------------------------------------------------------------------------------------- K0: Kala
KALA_DARK = hexc("0B0610")
KALA_RIM = hexc("3A1F4A")
EYE_A = hexc("FF4A1E")
EYE_B = hexc("FFD25A")


def kala(pose):
    """Batara Kala, 96x96, faces left. pose 0 idle, 1 reaching, 2 lunging. Eyes are baked in (the scene pulses them)."""
    c = C(96, 96)
    lunge = (0, 5, 12)[pose]
    # torso: broad shoulders tapering into the tide on the right
    c.poly([(40 + lunge, 40), (96, 30), (96, 96), (46 + lunge, 96), (34 + lunge, 70)], KALA_DARK)
    # head with a heavy brow
    hx = lunge
    c.poly([(8 + hx, 30), (28 + hx, 14), (52 + hx, 22), (58 + hx, 44), (40 + hx, 52), (14 + hx, 48)], KALA_DARK)
    # horns
    c.poly([(14 + hx, 26), (2 + hx, 6), (10 + hx, 4), (22 + hx, 18)], KALA_DARK)
    c.poly([(40 + hx, 16), (40 + hx, 2), (48 + hx, 0), (52 + hx, 20)], KALA_DARK)
    # crown spikes (kala has a ragged mane)
    for i, x in enumerate((30, 38, 46, 54, 62)):
        c.poly([(x + hx, 20 - i), (x + 4 + hx, 4 + i * 2), (x + 8 + hx, 22 - i)], KALA_DARK)
    # lower jaw hangs open, the mouth is a lit hollow with fangs
    c.poly([(10 + hx, 44), (36 + hx, 48), (34 + hx, 64), (22 + hx, 68), (12 + hx, 58)], KALA_DARK)
    c.poly([(14 + hx, 44), (34 + hx, 47), (32 + hx, 55), (18 + hx, 53)], hexc("5A1018"))
    for i in range(5):
        x = 15 + i * 4 + hx
        c.poly([(x, 45), (x + 3, 45), (x + 1.5, 51 - (i % 2))], hexc("E8D8B8"))
    for i in range(3):
        x = 17 + i * 6 + hx
        c.poly([(x, 59), (x + 3, 59), (x + 1.5, 54)], hexc("E8D8B8"))
    # arms: far arm raised, near arm reaches toward the player, more with the pose
    reach = (6, 22, 40)[pose]
    c.line(46 + lunge, 52, 30 - reach // 2 + lunge, 66, KALA_DARK, 5)
    c.line(30 - reach // 2 + lunge, 66, 6 - reach // 3, 78 - pose * 4, KALA_DARK, 4)
    c.line(52 + lunge, 46, 38 - reach // 2 + lunge, 40, KALA_DARK, 5)
    c.line(38 - reach // 2 + lunge, 40, 16 - reach // 3, 34 + pose * 2, KALA_DARK, 4)
    for (ex, ey, a) in ((6 - reach // 3, 78 - pose * 4, 0.5), (16 - reach // 3, 34 + pose * 2, -0.4)):
        for k in range(4):
            ang = math.pi + a + (k - 1.5) * 0.45
            c.line(ex, ey, ex + math.cos(ang) * 11, ey + math.sin(ang) * 11, KALA_DARK, 2)
    # rim light so the shape reads on a dark ground
    for y in range(c.h):
        for x in range(c.w):
            if c.get(x, y)[3] and x > 0 and c.get(x - 1, y)[3] == 0:
                c.set(x - 1, y, KALA_RIM)
            if c.get(x, y)[3] and y > 0 and c.get(x, y - 1)[3] == 0:
                c.set(x, y - 1, KALA_RIM)
    # eyes last
    for (ex, ey) in ((22 + hx, 31), (36 + hx, 29)):
        c.rect(ex - 2, ey - 1, ex + 2, ey + 1, EYE_A)
        c.rect(ex - 1, ey, ex + 1, ey, EYE_B)
    return c.done()


def tide(frame):
    """Shadow edge strip, 40x64, tiles vertically (every wave is an integer harmonic of 64). Dark body to the right."""
    w, h = 40, 64
    c = C(w, h)
    rnd = random.Random(7 + frame)
    ph = frame * math.pi / 2
    for y in range(h):
        e = 15 + 5 * math.sin(2 * math.pi * y / 64 + ph) + 3 * math.sin(2 * math.pi * 3 * y / 64 - ph * 2)
        # claws: a tapered spike every 16 rows, wobbling with the frame
        d = ((y + frame * 2) % 16) - 8
        spike = max(0, 11 - abs(d) * 3) * (1.0 if (y // 16) % 2 == 0 else 0.6)
        x0 = int(e - spike)
        for x in range(max(0, x0), w):
            c.set(x, y, KALA_DARK if x > x0 else KALA_RIM)
        # drips of darkness beyond the edge, dithered
        for k in range(1, 5):
            if x0 - k >= 0 and BAYER[y % 4][(x0 - k) % 4] < (5 - k) * 3 and rnd.random() < 0.6:
                c.set(x0 - k, y, lerp(KALA_DARK, T, 0.35 + k * 0.12))
        if rnd.random() < 0.05 and x0 + 6 < w:
            c.set(x0 + 5 + rnd.randint(0, 6), y, hexc("7A2230"))   # embers inside the dark
    return c.done()


# ----------------------------------------------------------------------------------------------- K0: light
def lamp_glow():
    """Radial warm light, 240x240 (= 2 x LAMP_R), dithered bands. Drawn additive, never scaled."""
    n = 240
    im = Image.new("RGBA", (n, n), T)
    for y in range(n):
        for x in range(n):
            r = math.hypot(x - n / 2 + .5, y - n / 2 + .5) / (n / 2)
            if r >= 1:
                continue
            level = (1 - r) ** 1.6                          # 0..1, strong in the middle
            band = level * 4.0
            base = int(band)
            frac = band - base
            if BAYER[y % 4][x % 4] / 16.0 < frac:
                base += 1                                     # ordered dither between bands
            a = (0, 14, 30, 52, 84, 120)[min(base, 5)]
            if a:
                im.putpixel((x, y), (255, 226 if base < 4 else 240, 150 if base < 4 else 190, a))
    return im


def lamp_burst(f):
    """Ignition burst, 40x40, 5 frames: flash, ring, sparks."""
    c = C(40, 40)
    cx = cy = 20
    r = (3, 8, 13, 17, 19)[f]
    a = (255, 255, 220, 150, 80)[f]
    if f == 0:
        c.ell(cx, cy, 5, 5, hexc("FFF6D0"))
    else:
        for deg in range(0, 360, 6):
            rad = math.radians(deg)
            c.set(cx + math.cos(rad) * r, cy + math.sin(rad) * r, (255, 226, 130, a))
            if f < 4:
                c.set(cx + math.cos(rad) * (r - 1), cy + math.sin(rad) * (r - 1), (255, 246, 200, a))
    for k in range(8):
        ang = k * math.pi / 4 + 0.3
        d = (4, 10, 15, 18, 20)[f] + (k % 2) * 2
        if d < 20:
            c.set(cx + math.cos(ang) * d, cy + math.sin(ang) * d, hexc("FFE08A", a))
            c.set(cx + math.cos(ang) * (d - 1), cy + math.sin(ang) * (d - 1), hexc("FFFFFF", a // 2))
    return c.done()


def lamp_hint(f):
    """Dashed gold ring that breathes, 28x28, 4 frames: tells you 'this lamp wants a flame'."""
    c = C(28, 28)
    r = 8 + (0, 1, 2, 1)[f]
    rot = f * 0.25
    for k in range(14):
        ang = rot + k * (2 * math.pi / 14)
        if k % 2 == 0:
            for t in (0, .12):
                c.set(14 + math.cos(ang + t) * r, 14 + math.sin(ang + t) * r, hexc("FFD66A", 230))
    # small arrow dot above the lamp: the 'press here' pip
    c.rect(13, 1 + (f % 2), 14, 2 + (f % 2), hexc("FFF0B0"))
    return c.done()


def pointing_hand(f):
    """Wayang hand on a horn rod, pointing right, 20x14, 2 frames (bobbing)."""
    c = C(20, 14)
    y = 5 + f
    c.rect(0, y + 2, 8, y + 3, WOOD)                       # rod
    c.rect(0, y + 2, 8, y + 2, WOOD_HI)
    c.poly([(7, y - 1), (13, y - 2), (14, y + 5), (7, y + 5)], INK)   # palm
    c.line(13, y, 19, y, INK, 2)                          # pointing finger
    c.rect(11, y - 3, 13, y - 2, INK)                      # thumb
    c.rect(9, y + 5, 12, y + 6, INK)
    c.holes([(9, y + 1), (11, y + 2)])
    c.set(19, y, GOLD_HI)
    return c.done()


# ----------------------------------------------------------------------------------------------- K0: the screen
def screen():
    """The whole K0 stage, 480x272: carved beam, kelir cloth, bamboo posts, gedebog log, the dark house with the gamelan
    row drawn in by the scene. The cloth is lit warm in the middle so the lamps and the player read on it."""
    W, H = 480, 272
    c = C(W, H)
    rnd = random.Random(11)
    cloth_hi, cloth_lo = hexc("F6E5B4"), hexc("C99D58")
    for y in range(H):
        for x in range(W):
            c.set(x, y, hexc("120B0C"))
    # cloth: y 12..147, x 8..471, warmer in the centre
    for y in range(12, 148):
        for x in range(8, 472):
            dx = (x - W / 2) / (W / 2)
            dy = (y - 80) / 68
            t = min(1.0, (dx * dx * 0.7 + dy * dy * 0.9))
            col = lerp(cloth_hi, cloth_lo, t * 0.9)
            if (x + y) % 2 == 0 and (x // 2 + y // 2) % 3 == 0:
                col = lerp(col, hexc("8A6A3A"), 0.10)            # weave
            if x % 37 == 0:
                col = lerp(col, hexc("8A6A3A"), 0.10)            # soft fold lines
            c.set(x, y, col)
    # stitched border
    for x in range(10, 470, 4):
        c.set(x, 14, hexc("8A5A30")); c.set(x, 145, hexc("8A5A30"))
    for y in range(14, 146, 4):
        c.set(10, y, hexc("8A5A30")); c.set(469, y, hexc("8A5A30"))
    # beam
    c.rect(0, 0, W - 1, 11, WOOD_LO)
    c.rect(0, 0, W - 1, 3, WOOD)
    c.rect(0, 4, W - 1, 4, WOOD_HI)
    for x in range(6, W, 24):                                       # carved gold diamonds
        c.poly([(x, 7), (x + 4, 4), (x + 8, 7), (x + 4, 10)], GOLD_LO)
        c.set(x + 4, 7, GOLD_HI)
    c.rect(0, 11, W - 1, 11, hexc("2A1710"))
    # posts: bamboo with node rings
    for x0 in (0, 472):
        c.rect(x0, 0, x0 + 7, 160, hexc("5E7A32"))
        c.rect(x0, 0, x0 + 2, 160, hexc("86A04A"))
        c.rect(x0 + 6, 0, x0 + 7, 160, hexc("3A5020"))
        for y in range(10, 160, 26):
            c.rect(x0, y, x0 + 7, y + 1, hexc("2C3E18"))
    # gedebog (banana trunk) y 148..160
    for y in range(148, 161):
        for x in range(8, 472):
            t = (y - 148) / 12
            col = lerp(hexc("8CB052"), hexc("3E5A26"), t)
            if x % 17 in (0, 1):
                col = lerp(col, hexc("22331A"), 0.5)
            c.set(x, y, col)
    for x in range(8, 472, 9):                                       # puppet pin holes
        c.set(x, 150, hexc("20301A"))
    c.rect(8, 160, 471, 161, hexc("1A1008"))
    # the dark house below the screen: floor boards fading to black
    for y in range(162, H):
        t = (y - 162) / (H - 162)
        for x in range(0, W):
            base = lerp(hexc("3A2618"), hexc("0A0605"), min(1, t * 1.15))
            if (x // 24) % 2 == 0 and y % 14 == 0:
                base = lerp(base, hexc("000000"), 0.4)
            c.set(x, y, base)
    # light spill from the lit cloth onto the first rows of the house
    for y in range(162, 190):
        for x in range(40, 440):
            a = (1 - (y - 162) / 28) * 0.28
            c.set(x, y, lerp(c.get(x, y), hexc("F2D9A0"), a))
    # hanging dalang lamp chain
    for y in range(12, 20):
        c.set(240, y, GOLD_LO)
    # a ragged vignette inside the cloth so the corners fall off
    for y in range(12, 148):
        for x in list(range(8, 40)) + list(range(440, 472)):
            d = (40 - x) if x < 40 else (x - 439)
            if BAYER[y % 4][x % 4] < d / 3:
                c.set(x, y, lerp(c.get(x, y), hexc("5A3A1C"), 0.45))
    return c.done()


# ----------------------------------------------------------------------------------------------- combat
STEEL = hexc("DCE4EA")


def aim_pointers():
    """16x16 each, pointing right, 4 frames by archetype: light blade, heavy blade, ranged (bow), staff."""
    frames = []
    # light: slim chevron
    c = C(16, 16)
    c.poly([(8, 5), (14, 8), (8, 11), (10, 8)], hexc("F2E6C2")); c.poly([(9, 6), (13, 8), (9, 10), (10, 8)], hexc("FFFFFF"))
    frames.append(c.done())
    # heavy: wide double chevron
    c = C(16, 16)
    c.poly([(5, 4), (11, 8), (5, 12), (7, 8)], hexc("E8B890")); c.poly([(9, 4), (15, 8), (9, 12), (11, 8)], hexc("FFE0C0"))
    frames.append(c.done())
    # ranged: nocked arrow tip with fletching ticks
    c = C(16, 16)
    c.line(5, 8, 12, 8, hexc("D8CBA0"), 1)
    c.poly([(12, 5), (15, 8), (12, 11)], STEEL)
    c.rect(4, 6, 4, 10, hexc("9CD3A2")); c.rect(6, 7, 6, 9, hexc("9CD3A2"))
    frames.append(c.done())
    # staff: glowing orb with a short tail
    c = C(16, 16)
    c.ell(11, 8, 3.2, 3.2, hexc("6FE0FF")); c.ell(11, 8, 1.6, 1.6, hexc("FFFFFF"))
    c.line(4, 8, 8, 8, hexc("9AC7E8"), 1)
    frames.append(c.done())
    return frames


def arrow():
    """Player arrow in flight, 14x5, points right."""
    c = C(14, 5)
    c.rect(1, 2, 11, 2, hexc("D8C79A"))
    c.poly([(10, 0), (14, 2.5), (10, 5)], STEEL)
    c.rect(0, 0, 2, 1, hexc("9CD3A2")); c.rect(0, 3, 2, 4, hexc("9CD3A2"))
    return c.done()


def spirit_shot(f):
    c = C(12, 12)
    r = (4.5, 5.2, 4.8)[f]
    c.ell(6, 6, r + 1.2, r + 1.2, hexc("5FE0A8", 110))
    c.ell(6, 6, r, r, hexc("A8FFD0"))
    c.ell(6, 6, r - 2, r - 2, hexc("FFFFFF"))
    c.set(6 + (f - 1) * 3, 1, hexc("A8FFD0")); c.set(3, 10 - f, hexc("A8FFD0", 160))
    return c.done()


def thrown_rock(f):
    c = C(10, 10)
    c.poly([(2, 2), (7, 1), (9, 5), (6, 9), (1, 7)] if f == 0 else [(3, 1), (8, 3), (8, 7), (4, 9), (1, 5)], hexc("7A6C5E"))
    c.poly([(3, 3), (6, 2), (7, 4), (4, 5)] if f == 0 else [(4, 2), (7, 4), (5, 5), (3, 4)], hexc("A59482"))
    c.set(6, 7, hexc("4E4338")); c.set(3, 6, hexc("4E4338"))
    return c.done()


def chest(opened):
    """18x16: node origin is bottom-centre +2 below the base (offset -9,-14)."""
    c = C(18, 16)
    c.rect(1, 13, 16, 14, hexc("141020", 140))                          # ground shadow
    body = hexc("7A4E26"); body_hi = hexc("A86C34"); body_lo = hexc("4A2E16")
    c.rect(1, 6, 16, 13, body); c.rect(1, 6, 16, 7, body_hi); c.rect(1, 12, 16, 13, body_lo)
    c.rect(1, 6, 1, 13, body_lo); c.rect(16, 6, 16, 13, body_lo)
    for x in (4, 12):
        c.rect(x, 6, x + 1, 13, GOLD)
    if opened:
        c.poly([(1, 5), (16, 5), (14, 0), (3, 0)], body_lo)                 # lid thrown back
        c.rect(3, 1, 14, 1, body); c.rect(4, 4, 13, 5, hexc("1A100A"))
        c.rect(4, 6, 13, 7, hexc("F2D060")); c.rect(6, 5, 7, 5, hexc("FFF0A0")); c.rect(10, 5, 11, 6, hexc("FFE070"))   # treasure
    else:
        c.poly([(1, 6), (16, 6), (15, 1), (2, 1)], body); c.rect(2, 1, 15, 2, body_hi)
        for x in (4, 12):
            c.rect(x, 1, x + 1, 6, GOLD)
        c.rect(8, 5, 9, 8, GOLD_HI); c.rect(8, 6, 9, 7, INK)               # lock
    return c.done()


def kabut():
    """Fog bank tile, 48x32, soft dither. The scene tints and drifts it."""
    n_w, n_h = 32, 32
    im = Image.new("RGBA", (n_w, n_h), T)
    rnd = random.Random(5)
    blobs = [(rnd.uniform(0, 32), rnd.uniform(0, 32), rnd.uniform(6, 11)) for _ in range(7)]
    for y in range(n_h):
        for x in range(n_w):
            v = 0.0
            for (bx, by, br) in blobs:
                for ox in (-n_w, 0, n_w):   # wrap both ways so the tile repeats
                    for oy in (-n_h, 0, n_h):
                        v = max(v, 1 - math.hypot(x - bx - ox, (y - by - oy) * 1.3) / br)
            if v > 0:
                lvl = v * 4
                if BAYER[y % 4][x % 4] / 16 < lvl - int(lvl):
                    lvl += 1
                a = (0, 40, 85, 130, 165)[min(int(lvl), 4)]
                if a:
                    im.putpixel((x, y), (232, 238, 246, a))
    return im


def pillar():
    c = C(18, 36)
    stone, hi, lo = hexc("8C8478"), hexc("B8B0A0"), hexc("5C564E")
    c.rect(2, 4, 15, 34, stone); c.rect(2, 4, 4, 34, hi); c.rect(13, 4, 15, 34, lo)
    c.rect(0, 0, 17, 4, lo); c.rect(1, 0, 16, 1, hi)                           # capital
    c.rect(0, 32, 17, 35, lo); c.rect(1, 32, 16, 32, hi)                       # plinth
    for y in (10, 18, 26):                                                     # carved bands
        c.rect(5, y, 12, y, lo); c.rect(5, y + 1, 12, y + 1, hi)
    c.poly([(8, 12), (10, 14), (8, 16), (6, 14)], lo); c.set(8, 14, hi)        # a kawung-like diamond
    return c.done()


def oncor(f):
    """Torch post 16x34: frame 0 cold, 1-3 burning."""
    c = C(16, 34)
    c.rect(7, 12, 8, 33, WOOD); c.rect(7, 12, 7, 33, WOOD_HI)
    c.poly([(4, 8), (11, 8), (10, 14), (5, 14)], hexc("5A3A22")); c.rect(4, 8, 11, 8, hexc("7A5030"))   # cup
    if f == 0:
        c.poly([(6, 3), (9, 3), (10, 8), (5, 8)], hexc("2A2622")); c.set(7, 5, hexc("4A453F"))      # dead wick
    else:
        s = (0, 0, 1, -1)[f]
        c.poly([(5, 8), (10, 8), (9, 2 + s), (7.5, -1 + s), (6, 2)], hexc("E8501E"))
        c.poly([(6, 8), (9, 8), (8.5, 3 + s), (7.5, 1 + s)], hexc("FFB43A"))
        c.poly([(7, 8), (8.5, 8), (8, 4), (7.5, 4)], hexc("FFF0A0"))
    return c.done()


def curse_stake(f):
    """Curse stake 12x24: 0 unlit, 1 marked, 2 lit."""
    c = C(12, 24)
    wood = hexc("3E3030") if f == 0 else (hexc("5A3030") if f == 1 else hexc("4A1818"))
    c.poly([(3, 6), (8, 6), (7, 23), (4, 23)], wood)
    c.poly([(3, 6), (6, 0), (8, 6)], wood)
    c.rect(3, 6, 3, 22, lerp(wood, hexc("FFFFFF"), 0.18))
    glow = (None, hexc("E88070"), hexc("FF2A1A"))[f]
    if glow:
        for (x, y) in ((5, 9), (6, 13), (5, 17)):
            c.rect(x, y, x + 1, y, glow)
        c.set(5, 3, glow)
        if f == 2:
            c.ell(5.5, 4, 3, 3, hexc("FF4030", 90))
    c.rect(1, 22, 10, 23, hexc("20181A"))
    return c.done()


def pouch(kind, size=64):
    """Ground decal for Buto Ijo's pouch fields, size x size circle with a dithered edge."""
    pal = {"bramble": (hexc("2F6A28"), hexc("63A850")), "bamboo": (hexc("A8B848"), hexc("D8E888")),
           "salt": (hexc("B8D8F0"), hexc("FFFFFF")), "mud": (hexc("4E3418"), hexc("7A5530"))}[kind]
    im = Image.new("RGBA", (size, size), T)
    rnd = random.Random(sum(map(ord, kind)) * 977)
    for y in range(size):
        for x in range(size):
            r = math.hypot(x - size / 2 + .5, y - size / 2 + .5) / (size / 2)
            if r > 1:
                continue
            edge = r > 0.82 and BAYER[y % 4][x % 4] / 16 < (r - 0.82) / 0.18
            if edge:
                continue
            col = pal[0]
            if rnd.random() < 0.10:
                col = pal[1]
            im.putpixel((x, y), (col[0], col[1], col[2], 135))
    px_ = im.load()
    for _ in range(size // 3):                                                   # kind-specific marks
        x, y = rnd.randint(8, size - 9), rnd.randint(8, size - 9)
        if math.hypot(x - size / 2, y - size / 2) < size / 2 - 7:
            if kind == "bramble":
                for k in range(4):
                    px_[x + k, y - k // 2] = (*pal[1][:3], 230)
            elif kind == "bamboo":
                px_[x, y] = (*pal[1][:3], 240)
                px_[x, y - 1] = (*pal[1][:3], 240)
            elif kind == "salt":
                px_[x, y] = (255, 255, 255, 240)
            else:
                px_[x, y] = (*pal[1][:3], 240)
                px_[x + 1, y] = (*pal[1][:3], 200)
    return im


def arena_post(hung):
    """Sangkuriang's east post 14x26 (the red boeh rarang cloth when hung)."""
    c = C(14, 26)
    c.rect(1, 2, 2, 25, hexc("6A4529")); c.rect(1, 2, 1, 25, hexc("8D6038"))
    c.poly([(0, 2), (3, 2), (1.5, 0)], hexc("8D6038"))
    c.rect(0, 24, 4, 25, hexc("3F2616"))
    if hung:
        c.poly([(3, 3), (13, 4), (11, 8), (13, 12), (3, 11)], hexc("C42A2A"))
        c.rect(3, 3, 12, 3, hexc("E8605A")); c.rect(4, 10, 11, 11, hexc("8E1A1A"))
        c.rect(7, 6, 8, 7, hexc("FFD66A"))
    return c.done()


# ----------------------------------------------------------------------------------------------- villagers, boss shots
def emote(kind):
    """Speech bubble 11x10 (tail at bottom): 0 dots, 1 !, 2 ?, 3 heart, 4 note."""
    c = C(11, 10)
    ink, paper = hexc("17122A"), hexc("F6F1E4")
    c.rect(1, 0, 9, 6, ink); c.rect(0, 1, 10, 5, ink)
    c.rect(1, 1, 9, 5, paper); c.rect(1, 1, 9, 1, hexc("FFFFFF"))
    c.rect(4, 7, 6, 8, ink)
    c.set(5, 7, paper)
    if kind == 0:
        for x in (3, 5, 7):
            c.rect(x, 4, x, 4, ink)
    elif kind == 1:
        c.rect(5, 2, 5, 4, hexc("E8A820"))
    elif kind == 2:
        for (x, y) in ((4, 2), (5, 2), (6, 3), (5, 4), (5, 5)):
            c.set(x, y, hexc("3FA8B8"))
        c.set(4, 3, hexc("3FA8B8"))
    elif kind == 3:
        for (x, y) in ((3, 2), (4, 2), (6, 2), (7, 2), (3, 3), (4, 3), (5, 3), (6, 3), (7, 3), (4, 4), (5, 4), (6, 4), (5, 5)):
            c.set(x, y, hexc("D8384A"))
    else:
        for (x, y) in ((6, 2), (6, 3), (6, 4), (5, 4), (4, 5), (5, 5)):
            c.set(x, y, hexc("4A62C0"))
        c.set(7, 2, hexc("4A62C0"))
    return c.done()


def boss_blade():
    """White blade/shard 24x10 pointing right; the engine tints it with the shot colour."""
    c = C(24, 10)
    c.poly([(23, 5), (7, 0.5), (2, 5), (7, 9.5)], hexc("C8C8D0"))
    c.poly([(21, 5), (8, 2.5), (5, 5), (8, 7.5)], hexc("FFFFFF"))
    c.rect(2, 4, 7, 5, hexc("9898A8"))
    return c.done()


def boss_log():
    c = C(32, 12)
    c.rect(1, 1, 30, 10, hexc("7A5030")); c.rect(1, 1, 30, 3, hexc("A87444")); c.rect(1, 9, 30, 10, hexc("4E3220"))
    for x in (6, 14, 22):
        c.rect(x, 2, x, 9, hexc("5A3A22"))
    c.ell(2, 5.5, 2.5, 4.5, hexc("C8A070")); c.ell(29, 5.5, 2.5, 4.5, hexc("C8A070"))
    c.set(2, 5, hexc("7A5030")); c.set(29, 5, hexc("7A5030"))
    return c.done()


def boss_skull():
    c = C(14, 14)
    c.ell(7, 6, 6, 5.5, hexc("E8E0D0")); c.rect(4, 9, 9, 12, hexc("E8E0D0"))
    c.rect(3, 5, 5, 7, hexc("17122A")); c.rect(8, 5, 10, 7, hexc("17122A"))
    c.set(7, 8, hexc("17122A")); c.rect(5, 12, 5, 12, hexc("17122A")); c.rect(7, 12, 7, 12, hexc("17122A")); c.rect(9, 12, 9, 12, hexc("17122A"))
    c.set(4, 6, hexc("FF5A3A")); c.set(9, 6, hexc("FF5A3A"))
    return c.done()


def boss_orb(f):
    c = C(16, 16)
    r = (6.5, 7.2, 6.8)[f]
    c.ell(8, 8, r + 0.8, r + 0.8, hexc("FFFFFF", 90))
    c.ell(8, 8, r, r, hexc("E8E8E8")); c.ell(8, 8, r - 2.2, r - 2.2, hexc("FFFFFF"))
    c.set(8 + (f - 1) * 3, 2, hexc("FFFFFF")); c.set(3, 11 - f, hexc("FFFFFF", 170))
    return c.done()


# ----------------------------------------------------------------------------------------------- kelir set pieces
CLOTH_C, CLOTH_D = hexc("D8C8A0"), hexc("9A8A60")


def prop_cloth(done):
    """K2: the cloth you spread. 0 folded, 1 spread out with a border."""
    c = C(22, 20)
    c.rect(2, 17, 19, 18, hexc("141020", 120))
    if not done:
        c.rect(5, 11, 16, 17, CLOTH_C); c.rect(5, 11, 16, 12, hexc("F0E2BC")); c.rect(5, 15, 16, 17, CLOTH_D)
        c.rect(5, 13, 16, 13, hexc("B8A478"))
    else:
        c.poly([(1, 17), (20, 17), (17, 9), (4, 9)], CLOTH_C)
        c.poly([(3, 16), (18, 16), (16, 11), (5, 11)], hexc("F0E2BC"))
        for x in range(4, 18, 3):
            c.set(x, 14, hexc("B83A3A")); c.set(x + 1, 13, hexc("2A5C9A"))
        c.rect(1, 17, 20, 17, CLOTH_D)
    return c.done()


def prop_lesung(done):
    """K2 and K3: the rice mortar and pestle. 1 = the pestle struck, a puff of dust."""
    c = C(22, 22)
    c.rect(2, 19, 19, 20, hexc("141020", 120))
    c.poly([(3, 9), (18, 9), (16, 19), (5, 19)], hexc("8A6038")); c.rect(3, 9, 18, 10, hexc("B88850"))
    c.rect(5, 10, 16, 11, hexc("2A1A10")); c.rect(5, 12, 5, 18, hexc("A87444"))
    pe = 2 if done else 0
    c.rect(10, 0 + pe, 11, 11, hexc("C8A070")); c.rect(9, 0 + pe, 12, 2 + pe, hexc("E0C090"))
    if done:
        for (x, y) in ((4, 8), (17, 8), (2, 6), (19, 6), (7, 5)):
            c.set(x, y, hexc("F0E8D0", 200))
    return c.done()


def prop_pouch(done):
    """K4: a tied pouch; thrown, its seeds spill."""
    c = C(18, 18)
    c.rect(2, 15, 15, 16, hexc("141020", 120))
    if not done:
        c.poly([(4, 15), (13, 15), (14, 9), (9, 5), (3, 9)], hexc("A86038")); c.rect(7, 4, 10, 6, hexc("5A3A22"))
        c.rect(5, 10, 11, 10, hexc("7A4222")); c.rect(8, 3, 9, 4, hexc("E8C070"))
    else:
        c.poly([(3, 14), (9, 14), (8, 11), (4, 11)], hexc("A86038"))
        for (x, y) in ((10, 13), (12, 12), (14, 14), (11, 15), (9, 11), (13, 10), (15, 12)):
            c.set(x, y, hexc("7FBF48")); c.set(x + 1, y, hexc("3E7A2E"))
    return c.done()


def prop_slab(done):
    """K7 and the Laras chapters: a stone slab that takes a glyph. 1 = the glyph glows."""
    c = C(20, 24)
    c.rect(2, 21, 17, 22, hexc("141020", 120))
    c.poly([(3, 21), (16, 21), (15, 4), (10, 1), (5, 4)], hexc("7E7890")); c.rect(5, 4, 5, 20, hexc("A8A2BC")); c.rect(14, 6, 15, 20, hexc("56506A"))
    col = hexc("7FE8E0") if done else hexc("3A3A52")
    if done:   # the glow sits behind the glyph
        for r, a in ((9, 26), (6, 44)):
            c.ell(10, 10, r, r + 1, hexc("7FE8E0", a))
    for (x, y) in ((8, 7), (9, 7), (10, 7), (11, 7), (11, 8), (10, 9), (9, 10), (8, 11), (9, 12), (10, 12), (11, 12)):
        c.set(x, y, col)
    return c.done()


def prop_basket(done):
    """SQ-G1: the basket on the ground, then hung on its hook."""
    c = C(20, 24)
    c.rect(2, 21, 17, 22, hexc("141020", 120))
    if not done:
        c.poly([(3, 20), (16, 20), (14, 12), (5, 12)], hexc("C8A058")); c.rect(5, 12, 14, 13, hexc("E8C878"))
        for y in (15, 18):
            c.rect(4, y, 15, y, hexc("8A6A38"))
        c.rect(4, 5, 5, 12, hexc("8A6A38")); c.rect(14, 5, 15, 12, hexc("8A6A38")); c.rect(4, 4, 15, 5, hexc("8A6A38"))
    else:
        c.rect(9, 0, 10, 6, hexc("6A4529"))
        c.poly([(4, 17), (15, 17), (14, 10), (5, 10)], hexc("C8A058")); c.rect(5, 10, 14, 11, hexc("E8C878"))
        c.rect(5, 6, 14, 6, hexc("8A6A38")); c.rect(5, 6, 5, 10, hexc("8A6A38")); c.rect(14, 6, 14, 10, hexc("8A6A38"))
        c.rect(7, 2, 12, 3, hexc("6A4529"))
    return c.done()


def prop_beans(done):
    """SQ-M3: a sack of green beans, then the beans scattered."""
    c = C(22, 18)
    c.rect(2, 15, 19, 16, hexc("141020", 120))
    if not done:
        c.poly([(5, 15), (15, 15), (16, 8), (10, 4), (4, 8)], hexc("C8B078")); c.rect(8, 3, 11, 5, hexc("8A7040")); c.rect(5, 10, 15, 10, hexc("A89058"))
    else:
        c.poly([(2, 14), (7, 14), (7, 12), (3, 12)], hexc("C8B078"))
        for (x, y) in ((9, 13), (11, 11), (13, 14), (15, 12), (17, 14), (19, 11), (12, 15), (16, 10)):
            c.set(x, y, hexc("6FC048")); c.set(x + 1, y, hexc("3E8A2E"))
    return c.done()


def prop_water(done):
    """SQ-T1: a still pool; struck, it rings."""
    c = C(26, 16)
    c.ell(13, 9, 12, 5, hexc("1E4E8A")); c.ell(13, 8, 11, 4, hexc("3E78C0"))
    c.ell(13, 8, 6, 2.5, hexc("5C98E0")) if not done else None
    if done:
        for r, a in ((3, 255), (6, 200), (9, 140)):
            for deg in range(0, 360, 12):
                x, y = 13 + math.cos(math.radians(deg)) * r, 8 + math.sin(math.radians(deg)) * r * 0.42
                c.set(x, y, hexc("DCEEFF", a))
    return c.done()


def prop_stone(done):
    """Generic ritual stone (SQ memories with a mark): 1 = lit rune."""
    c = C(18, 18)
    c.rect(2, 15, 15, 16, hexc("141020", 120))
    c.poly([(3, 15), (14, 15), (13, 6), (8, 3), (4, 6)], hexc("8A8498")); c.rect(4, 6, 4, 14, hexc("B0AAC4"))
    c.rect(8, 7, 8, 12, hexc("F2B27A") if done else hexc("4A4458")); c.rect(6, 9, 10, 9, hexc("F2B27A") if done else hexc("4A4458"))
    return c.done()


PROPS = {"cloth": prop_cloth, "lesung": prop_lesung, "pouch": prop_pouch, "slab": prop_slab, "basket": prop_basket,
         "beans": prop_beans, "water": prop_water, "stone": prop_stone}


# ----------------------------------------------------------------------------------------------- main
def main():
    for n, f in PROPS.items():
        out(strip([f(False), f(True)]), "cutscene/prop_%s.png" % n)
    out(strip([emote(i) for i in range(5)]), "ambient/emotes.png")
    out(boss_blade(), "fx/boss_blade.png")
    out(boss_log(), "fx/boss_log.png")
    out(boss_skull(), "fx/boss_skull.png")
    out(strip([boss_orb(i) for i in range(3)]), "fx/boss_orb.png")
    out(screen(), "cutscene/k0_screen.png")
    out(strip([kala(i) for i in range(3)]), "cutscene/k0_kala.png")
    out(strip([tide(i) for i in range(4)]), "cutscene/shadow_tide.png")
    out(lamp_glow(), "cutscene/lamp_glow.png")
    out(strip([lamp_burst(i) for i in range(5)]), "cutscene/lamp_burst.png")
    out(strip([lamp_hint(i) for i in range(4)]), "cutscene/lamp_hint.png")
    out(strip([pointing_hand(i) for i in range(2)]), "cutscene/pointing_hand.png")
    out(strip(aim_pointers()), "fx/aim_pointer.png")
    out(arrow(), "fx/arrow.png")
    out(strip([spirit_shot(i) for i in range(3)]), "fx/spirit_shot.png")
    out(strip([thrown_rock(i) for i in range(2)]), "fx/thrown_rock.png")
    out(strip([chest(False), chest(True)]), "props/chest.png")
    out(kabut(), "fx/kabut.png")
    out(pillar(), "props/pillar.png")
    out(strip([oncor(i) for i in range(4)]), "props/oncor.png")
    out(strip([curse_stake(i) for i in range(3)]), "props/curse_stake.png")
    for k in ("bramble", "bamboo", "salt", "mud"):
        out(pouch(k), "fx/pouch_%s.png" % k)
    out(strip([arena_post(False), arena_post(True)]), "props/arena_post.png")
    px.preview([(n, i) for n, i in PREVIEW if i.width <= 400], os.path.join(HERE, "revamp_preview.png"), scale=3, bg=(214, 168, 90, 255))
    px.preview([("screen", PREVIEW[0][1])], os.path.join(HERE, "k0_screen_preview.png"), scale=2, bg=(0, 0, 0, 255))
    print("ok")


if __name__ == "__main__":
    main()
