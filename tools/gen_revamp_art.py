#!/usr/bin/env python3
"""Revamp art pass v2 (2026-11-10, .docs/revamp_plan.md 1 and 3): the sprites that used to be code-drawn.

v2 redraws every sprite in the house style the rest of the game uses (props_preview, story_preview, cutscene puppets):
a 1 px selective dark outline (pixlib.outline), 3-4 tone ramps lit from the top-left, a soft ground shadow under
things that stand, the shared WOOD / GOLD / INK palette, and wayang-kulit lacework (tatahan) for anything that is a
shadow on the kelir. Canvas sizes, frame counts and anchors are unchanged, so no scene needs new offsets.

K0 kelir: the full screen (gawang frame, kelir cloth with its dark border, gedebog, the dark pendapa), Batara Kala as a
punched-leather wayang (3 poses), the shadow tide edge, lamp glow, ignition burst, the hint ring, the wayang hand.
Kelir set pieces: cloth, lesung, pouch, slab, basket, beans, water, stone (2 frames each: undone / done).
Combat and world: aim pointers per weapon archetype, arrow, spirit shot, thrown rock, chest, kabut fog, pillar, oncor,
curse stake, pouch fields, arena post, villager emotes, boss shots.
Run: python3 tools/gen_revamp_art.py     (writes assets/art/... and tools/revamp_preview.png, tools/k0_screen_preview.png)
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
from pixlib import hexc, shade
from gen_cutscene_art import C, strip, INK, T, WOOD, WOOD_HI, WOOD_LO, GOLD, GOLD_HI, GOLD_LO

HERE = os.path.dirname(os.path.abspath(__file__))
PREVIEW = []

BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]
SHADOW = (20, 14, 26, 96)                 # ground shadow, same weight as the story props
WOOD_DK = hexc("2A1810")
PAPER = hexc("F2D9A0")                   # kelir paper (assets.md 1)


def out(img, rel, preview=True):
    px.save(img, rel)
    if preview:
        PREVIEW.append((rel, img))
    return img


def lerp(a, b, t):
    t = max(0.0, min(1.0, t))
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(4))


def dith(x, y, t):
    """Ordered-dither test: True on a fraction t of pixels."""
    return BAYER[y % 4][x % 4] < t * 16


# ----------------------------------------------------------------------------------------------- house-style helpers
def bevel(img, hi=1.22, lo=0.70):
    """Top/left edge pixels a step lighter, bottom/right a step darker: the top-left light every prop in the game has."""
    src = img.copy()
    s, p = src.load(), img.load()
    w, h = img.size

    def clear(x, y):
        return not (0 <= x < w and 0 <= y < h) or s[x, y][3] < 255
    for y in range(h):
        for x in range(w):
            c = s[x, y]
            if c[3] < 255:
                continue
            if clear(x, y - 1) or clear(x - 1, y):
                p[x, y] = shade(c, hi)
            elif clear(x, y + 1) or clear(x + 1, y):
                p[x, y] = shade(c, lo)
    return img


def finish(img, shadow=None, k=0.4):
    """Outline (inside the canvas) and lay it over a soft ground shadow (cx, cy, rx, ry)."""
    if isinstance(img, C):
        img = img.done()
    o = px.outline(img, k, keep_pad=False)
    if not shadow:
        return o
    cx, cy, rx, ry = shadow
    base = C(o.width, o.height)
    base.ell(cx, cy, rx, ry, SHADOW)
    b = base.done()
    b.alpha_composite(o)
    return b


# ----------------------------------------------------------------------------------------------- K0: Batara Kala
KALA_DARK = hexc("0B0610")
KALA_RIM = hexc("5E3270")                  # ash-violet rim (Gua Kala colour)
LACE = hexc("7A3626")                      # light leaking through the punched holes
LACE_HOT = hexc("C0602A")
FANG = hexc("D8B07A")
EYE_A = hexc("FF4A1E")
EYE_B = hexc("FFD25A")
KALA_HX = (0, 4, 9)                        # head shift per pose; k0_ruwatan.gd KALA_EYE uses the same numbers
KALA_EYE = (27, 27)                        # eye centre at pose 0


def _arm(c, pts, w0, w1):
    """A wayang arm: a tapered chain of segments."""
    n = len(pts) - 1
    for i in range(n):
        (ax, ay), (bx, by) = pts[i], pts[i + 1]
        steps = int(max(abs(bx - ax), abs(by - ay))) + 1
        for s in range(steps + 1):
            t = s / steps
            wv = w0 + (w1 - w0) * ((i + t) / n)
            c.ell(ax + (bx - ax) * t, ay + (by - ay) * t, wv / 2 + .3, wv / 2 + .3, KALA_DARK)


def _claw(c, x, y, ang, spread=0.42, ln=8):
    for k in range(4):
        a = ang + (k - 1.5) * spread
        mx, my = x + math.cos(a) * ln * .6, y + math.sin(a) * ln * .6
        c.line(x, y, mx, my, KALA_DARK, 2)
        a2 = a - 0.6                                         # nails hook
        c.line(mx, my, mx + math.cos(a2) * ln * .45, my + math.sin(a2) * ln * .45, KALA_DARK, 1)


def _lace_edge(c, pts, col, step=2, inset=None):
    """Dots along a polygon's edge: the tatahan line that draws a part inside the silhouette."""
    k = 0
    for i in range(len(pts)):
        (ax, ay), (bx, by) = pts[i], pts[(i + 1) % len(pts)]
        n = int(max(abs(bx - ax), abs(by - ay)))
        for s in range(n):
            if k % step == 0:
                x, y = ax + (bx - ax) * s / max(1, n), ay + (by - ay) * s / max(1, n)
                if inset:
                    x, y = x + (inset[0] - x) * 0.06, y + (inset[1] - y) * 0.06
                c.set(round(x), round(y), col)
            k += 1


def kala(pose):
    """Batara Kala as a punched-leather wayang raksasa, 96x96, faces left. pose 0 idle, 1 reaching, 2 lunging.
    In the scene most of him sits over the dark, so he is drawn by his violet rim and by the ember light that leaks
    through his tatahan: crown tiers, the garuda mungkur, gimbal curls, the praba wing, necklace, armlets.
    The eye is cut out; k0_ruwatan.gd adds its pulsing glow at KALA_EYE (+ KALA_HX per pose)."""
    c = C(96, 96)
    hx = KALA_HX[pose]
    jaw = (0, 1, 4)[pose]
    D = KALA_DARK
    def H(pts):
        return [(x + hx, y) for (x, y) in pts]
    praba = [(62, 62), (68, 44), (76, 28), (86, 14), (92, 8), (94, 16), (92, 32), (88, 48), (82, 64)]
    hair = H([(44, 22), (54, 24), (62, 34), (64, 46), (60, 58), (50, 56), (44, 42)])
    torso = [(36, 64), (46, 57), (60, 54), (78, 55), (96, 60), (96, 96), (34, 96), (31, 80)]
    head = H([(16, 20), (42, 16), (48, 26), (48, 42), (42, 54), (34, 58), (22, 54), (12, 44)])
    nose = H([(17, 20), (10, 24), (3, 31), (3, 36), (8, 39), (15, 39), (19, 34)])
    jawp = H([(9, 41), (30, 42), (34, 50), (30, 56 + jaw), (18, 59 + jaw), (10, 52 + jaw)])
    beard = H([(18, 58 + jaw), (32, 55 + jaw), (30, 70 + jaw), (25, 65 + jaw), (21, 71 + jaw)])
    crown = H([(15, 21), (18, 14), (25, 11), (29, 6), (33, 7), (37, 1), (41, 3), (46, 0), (50, 6), (50, 16), (44, 21)])
    mungkur = H([(48, 10), (52, 5), (58, 4), (62, 8), (62, 14), (57, 17), (54, 14), (57, 11), (55, 9), (52, 12), (51, 20)])
    neck = H([(32, 52), (44, 50), (48, 62), (36, 64)])
    for part in (praba, hair, torso):
        c.poly(part, D)
    for (x, y) in ((58, 30), (62, 42), (60, 54)):
        c.ell(x + hx + 2, y, 4.5, 4.5, D)                                    # curls on the hair's back edge
    reach = (0, 1, 2)[pose]
    near = [[(44, 62), (30, 74), (14, 70)], [(44, 62), (26, 70), (6, 62)], [(46, 60), (24, 62), (0, 54)]][reach]
    far = [[(56, 62), (50, 84), (34, 90)], [(56, 62), (44, 80), (22, 84)], [(58, 60), (38, 74), (10, 78)]][reach]
    _arm(c, far, 6, 3)
    _claw(c, far[-1][0], far[-1][1], math.pi + 0.15, ln=7)
    for part in (neck, head, nose, jawp, beard, crown, mungkur):
        c.poly(part, D)
    _arm(c, near, 7, 3)
    _claw(c, near[-1][0], near[-1][1], math.pi - 0.2, ln=9)
    for (hxp, hyp) in (near[-1], far[-1]):
        c.line(hxp + 2, hyp + 1, hxp + 14, 95, hexc("3A2430"), 1)          # tuding rods
    # tatahan: each part drawn by a line of light, inner detail punched in brighter dots
    for part, col in ((praba, LACE), (hair, LACE), (crown, LACE_HOT), (mungkur, LACE), (head, LACE), (torso[:4], LACE)):
        cx = sum(p[0] for p in part) / len(part); cy = sum(p[1] for p in part) / len(part)
        _lace_edge(c, part, col, 2, (cx, cy))
    for i in range(4):                                                       # praba feathers, fanning from the shoulder
        tx, ty = ((78, 32), (85, 22), (90, 15), (90, 34))[i]
        for s in range(0, 22, 2):
            t = s / 22
            c.set(74 + (tx - 74) * t, 62 + (ty - 62) * t, LACE)
    for i in range(11):                                                      # crown: the jamang band and two tiers
        c.set(17 + hx + i * 3, 18 - (i > 8), LACE_HOT)
        if 2 <= i < 10:
            c.set(18 + hx + i * 3, 13 - (i > 5) * 2, LACE)
    for (x, y) in ((24, 15), (33, 10), (40, 5), (46, 4)):
        c.rect(x + hx, y, x + hx + 1, y + 1, LACE_HOT)                        # crown jewels
    for a in range(0, 360, 36):                                              # the garuda mungkur's curl
        c.set(57.5 + hx + math.cos(math.radians(a)) * 3.2, 10.5 + math.sin(math.radians(a)) * 3.2, LACE)
    for (x, y, r) in ((52, 30, 3.2), (56, 42, 3.2), (54, 52, 2.6), (60, 30, 2.4), (62, 42, 2.4), (62, 54, 2.2)):
        for a in range(0, 330, 30):                                          # gimbal curls cut as spirals
            rr = r * (0.45 + a / 600)
            c.set(x + hx + math.cos(math.radians(a)) * rr, y + math.sin(math.radians(a)) * rr, LACE)
    for i in range(14):                                                      # necklace (kalung) with its drop
        t = i / 13
        c.set(40 + t * 34, 64 + math.sin(t * math.pi) * 5 + t * 2, LACE_HOT)
    c.rect(56, 70, 57, 73, LACE_HOT); c.set(56, 74, LACE); c.set(57, 75, LACE)
    for i in range(4):                                                       # armlet (kelat bahu) on the shoulder
        c.set(50 + i * 2, 60 - (i % 2), LACE_HOT)
    for pts in (near, far):                                                  # bracelets
        bx, by = pts[1][0] + (pts[2][0] - pts[1][0]) * .72, pts[1][1] + (pts[2][1] - pts[1][1]) * .72
        c.rect(bx, by - 1, bx + 1, by + 1, LACE_HOT)
    c.ell(42 + hx, 32, 2.4, 3.2, LACE); c.ell(42 + hx, 32, 1.2, 1.8, D)      # sumping (ear ornament)
    c.set(42 + hx, 36, LACE_HOT)
    c.line(14 + hx, 21, 34 + hx, 19, LACE_HOT, 1)                             # the heavy brow
    c.line(11 + hx, 39, 6 + hx, 37, LACE, 1)                                  # nostril
    # mouth: a cut that glows, upper fangs, lower teeth and an upturned tusk
    c.poly(H([(10, 41), (29, 42), (32, 48 + jaw // 2), (13, 48 + jaw)]), LACE_HOT)
    for i in range(5):
        x = 12 + hx + i * 4
        c.poly([(x, 41), (x + 3, 41), (x + 1.5, 45 + (i == 0))], FANG)
    for i in range(3):
        x = 16 + hx + i * 5
        c.poly([(x, 49 + jaw), (x + 3, 49 + jaw), (x + 1.5, 46 + jaw)], FANG)
    c.line(11 + hx, 51 + jaw, 7 + hx, 41 + jaw, FANG, 1); c.set(8 + hx, 40 + jaw, FANG)
    # the eye: the round raksasa eye, cut as a ring with a hot pupil
    ex, ey = KALA_EYE[0] + hx, KALA_EYE[1]
    c.ell(ex + .5, ey + .5, 5.4, 4.6, LACE_HOT)
    c.ell(ex + .5, ey + .5, 4, 3.3, D)
    c.rect(ex - 1, ey - 1, ex + 1, ey + 1, EYE_A)
    c.set(ex, ey, EYE_B); c.set(ex - 1, ey - 1, EYE_B)
    # a violet rim all round, so the shape still reads where it overlaps the tide
    m = c.done()
    w, h = m.size
    s = m.copy().load()
    for y in range(h):
        for x in range(w):
            if s[x, y][3]:
                continue
            if any(0 <= x + dx < w and 0 <= y + dy < h and s[x + dx, y + dy][3] for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                m.putpixel((x, y), KALA_RIM)
    return m


def tide(frame):
    """Shadow edge strip, 40x64, tiles vertically (every wave is a whole harmonic of 64). Dark body to the right.
    The edge licks upward in tapered tongues of darkness, rimmed in ash-violet, with smoke dithered beyond."""
    w, h = 40, 64
    c = C(w, h)
    ph = frame * math.pi / 2
    edge = []
    for y in range(h):
        e = 18 + 3 * math.sin(2 * math.pi * y / 64 + ph) + 2 * math.sin(2 * math.pi * 2 * y / 64 - ph)
        edge.append(int(round(e)))
    # tongues: one every 16 rows, drifting up 4 rows a frame (period 64); each leans up as it reaches left
    tongue = [0] * h
    for k in range(4):
        y0 = (k * 16 - frame * 4) % 64
        ln = (11, 7, 13, 8)[k]
        for d in range(-6, 7):
            t = 1 - abs(d) / 6.5
            reach = ln * t ** 1.6
            yy = (y0 + d) % 64
            tongue[yy] = max(tongue[yy], int(reach))
    for y in range(h):
        x0 = edge[y] - tongue[y]
        for x in range(max(0, x0), w):
            c.set(x, y, KALA_DARK)
    m = c.done()
    s = m.copy().load()
    for y in range(h):
        for x in range(w):
            if s[x, y][3]:
                continue
            nb = (x + 1 < w and s[x + 1, y][3]) or s[x, (y + 1) % h][3] or s[x, (y - 1) % h][3]
            if nb:
                m.putpixel((x, y), KALA_RIM)
            elif x + 2 < w and (s[x + 2, y][3] or s[x + 3 if x + 3 < w else x, y][3]) and dith(x, y, 0.5):
                m.putpixel((x, y), (*KALA_DARK[:3], 140))
            elif x + 5 < w and s[x + 5, y][3] and dith(x, y, 0.2):
                m.putpixel((x, y), (*KALA_DARK[:3], 90))
    # punched diamonds inside the dark (a far-off lace pattern) and two embers
    for y in range(2, h, 8):
        x = edge[y] + 8 + (y // 8) % 2 * 4
        for (dx, dy) in ((0, -1), (-1, 0), (1, 0), (0, 1)):
            if x + dx < w:
                m.putpixel((x + dx, (y + dy) % h), LACE)
    for (x, y) in ((30, (9 - frame * 4) % 64), (34, (41 - frame * 4) % 64)):
        m.putpixel((x, y), LACE_HOT)
    return m


# ----------------------------------------------------------------------------------------------- K0: light
def lamp_glow():
    """Radial warm light, 240x240 (= 2 x LAMP_R), four dithered bands. Drawn additive, never scaled."""
    n = 240
    im = Image.new("RGBA", (n, n), T)
    p = im.load()
    for y in range(n):
        for x in range(n):
            r = math.hypot(x - n / 2 + .5, y - n / 2 + .5) / (n / 2)
            if r >= 1:
                continue
            band = (1 - r) ** 1.5 * 4.0
            b = int(band)
            if BAYER[y % 4][x % 4] / 16.0 < band - b:
                b += 1
            a = (0, 16, 34, 58, 92, 120)[min(b, 5)]
            if a:
                p[x, y] = (255, 214 + b * 6, 140 + b * 14, a)
    return im


def lamp_burst(f):
    """Ignition burst, 40x40, 5 frames: a spark, a four-petal (kawung) bloom, a ring, rising embers."""
    c = C(40, 40)
    cx = cy = 20
    W, Y, O, R = hexc("FFF6D8"), hexc("FFD66A"), hexc("F09A2A"), hexc("B8561E")
    if f == 0:
        c.ell(cx, cy, 3, 3, Y); c.ell(cx, cy, 1.6, 1.6, W)
        c.rect(cx - 6, cy, cx + 5, cy, Y); c.rect(cx, cy - 6, cx, cy + 5, Y)
    if f in (1, 2):
        s = (6, 9)[f - 1]
        for ang in (0, 90, 180, 270):                            # kawung petals
            a = math.radians(ang)
            px_, py_ = cx + math.cos(a) * s * .6, cy + math.sin(a) * s * .6
            c.ell(px_, py_, 2.5 + f, 2.5 + f, O if f == 2 else Y)
            c.ell(px_, py_, 1.2 + f * .5, 1.2 + f * .5, Y if f == 2 else W)
        c.ell(cx, cy, 2.2, 2.2, W)
        for ang in (45, 135, 225, 315):
            a = math.radians(ang)
            for d in range(s, s + 4 + f):
                c.set(cx + math.cos(a) * d, cy + math.sin(a) * d, Y if d < s + 3 else O)
    if f in (2, 3):
        r = (0, 0, 13, 17)[f]
        for deg in range(0, 360, 4):
            a = math.radians(deg)
            col = Y if f == 2 else (O if deg % 12 else R)
            if f == 3 and deg % 8 == 0:
                continue
            c.set(cx + math.cos(a) * r, cy + math.sin(a) * r, col)
    if f >= 3:
        rnd = random.Random(4)
        for k in range(9):
            a = rnd.uniform(0, math.pi * 2)
            d = rnd.uniform(6, 12) + (f - 3) * 5
            x, y = cx + math.cos(a) * d, cy + math.sin(a) * d - (f - 2) * 3
            c.set(x, y, Y if f == 3 else O)
            if f == 3:
                c.set(x, y + 1, R)
    return c.done()


def lamp_hint(f):
    """'This wants a flame': a gold dotted ring with four diamond pips that breathe, and a chevron bobbing on top.
    28x28, 4 frames. Every mark has an ink edge so it reads on the pale kelir and on dark ground alike."""
    c = C(28, 28)
    cx = cy = 14
    r = 9
    for k in range(20):
        a = k * (2 * math.pi / 20) + f * (math.pi / 40)
        if k % 5 in (1, 2, 3):
            c.set(cx + math.cos(a) * r, cy + math.sin(a) * r * 0.86, GOLD_HI if k % 5 == 2 else GOLD)
    d = r + (0, 1, 2, 1)[f]
    for ang in (0, 90, 180, 270):
        a = math.radians(ang)
        x, y = round(cx + math.cos(a) * d), round(cy + math.sin(a) * d * 0.86)
        c.poly([(x, y - 2), (x + 2, y), (x, y + 2), (x - 2, y)], GOLD)
        c.set(x, y - 1, GOLD_HI)
    b = (0, 1, 1, 0)[f]
    c.poly([(11, 1 + b), (17, 1 + b), (14, 5 + b)], GOLD_HI)
    c.rect(13, 1 + b, 14, 2 + b, hexc("FFF6D0"))
    return finish(c, k=0.3)


def pointing_hand(f):
    """A wayang hand on its rod, pointing right, 20x14, 2 frames (the finger lifts). Slender black leather arm with a
    gold bracelet, fingers held together the way a puppet's hand is carved; a painted red nail at the tip."""
    c = C(20, 14)
    lift = f
    c.line(1, 13, 5, 9, hexc("8D6038"), 1)                            # tuding rod
    c.line(2, 11, 9, 7, INK, 2)                                       # forearm
    c.rect(9, 6, 10, 8, GOLD); c.set(9, 6, GOLD_HI); c.set(10, 8, GOLD_LO)   # gelang (bracelet)
    c.rect(11, 6, 13, 8, INK)                                         # hand
    c.set(12, 5, INK); c.set(13, 4 - lift, INK)                       # thumb
    c.rect(14, 6 - lift, 18, 6 - lift, INK)                           # index finger
    c.rect(14, 7, 16, 7, INK); c.set(14, 8, INK)                      # the other fingers, held in
    c.set(19, 6 - lift, hexc("C83A2A"))                               # painted nail
    c.set(4, 9, hexc("4A3A3A")); c.set(6, 8, hexc("4A3A3A")); c.set(12, 6, hexc("4A3A3A"))   # sungging gleam
    return c.done()


# ----------------------------------------------------------------------------------------------- K0: the screen
def screen():
    """The whole K0 stage, 480x272: the gawang (carved beam and posts with gold finials), the kelir cloth with its dark
    plangitan border, two gedebog trunks, and the dark pendapa below with a tikar fading into the night.
    Layout is fixed by k0_ruwatan.gd: cloth x8..471 y12..147, gedebog y148..160, house y162+."""
    W, H = 480, 272
    c = C(W, H)
    rnd = random.Random(11)
    night = hexc("120B0C")
    c.rect(0, 0, W - 1, H - 1, night)
    # cloth: banded warm light, brightest a little above centre, weave and soft vertical folds
    bands = [hexc("F7E7B8"), hexc("EED6A0"), hexc("DDBD82"), hexc("C49D63"), hexc("A27D4A")]
    for y in range(12, 148):
        for x in range(8, 472):
            dx = (x - W / 2) / (W / 2)
            dy = (y - 74) / 80
            v = min(0.999, math.sqrt(dx * dx * 0.8 + dy * dy)) * 4.6
            b = int(v)
            if dith(x, y, v - b):
                b += 1
            col = bands[min(b, 4)]
            if (x * 3 + y) % 7 == 0 and rnd.random() < 0.55:
                col = shade(col, 0.95)                                # weave
            if x % 58 in (0, 1):
                col = shade(col, 0.93 if x % 58 == 0 else 1.03)        # folds where the cloth is tied
            c.set(x, y, col)
    # plangitan: the dark border sewn round the kelir (black-blue at the top, maroon on the sides), gold braid inside
    PL, PLH, MR = hexc("1E1A2E"), hexc("38304E"), hexc("4A1A1E")
    c.rect(8, 12, 471, 19, PL); c.rect(8, 12, 471, 12, PLH)
    for x in range(8, 472):
        if dith(x, 20, 0.5):
            c.set(x, 20, PL)
    c.rect(8, 12, 13, 147, MR); c.rect(466, 12, 471, 147, MR)
    c.rect(14, 20, 14, 147, GOLD_LO); c.rect(465, 20, 465, 147, GOLD_LO)
    for x in range(14, 466):
        c.set(x, 21, GOLD_LO if x % 4 else GOLD)
    for x in range(20, 460, 12):                                     # scalloped hem on the plangitan
        c.poly([(x, 19), (x + 6, 19), (x + 3, 22)], PL)
    # beam: dark teak with a gilded kawung band
    c.rect(0, 0, W - 1, 11, WOOD)
    c.rect(0, 0, W - 1, 0, WOOD_HI); c.rect(0, 1, W - 1, 1, shade(WOOD_HI, 1.1))
    c.rect(0, 10, W - 1, 11, WOOD_LO)
    c.rect(0, 3, W - 1, 3, GOLD_LO); c.rect(0, 8, W - 1, 8, GOLD_LO)
    for x in range(4, W, 10):                                        # kawung: four ovals round a dot
        for (ox, oy) in ((-2, 0), (2, 0), (0, -1), (0, 1)):
            c.set(x + ox, 5 + oy + (oy > 0), GOLD)
        c.set(x, 6, WOOD_DK); c.set(x - 2, 5, GOLD_HI)
    # posts: carved teak with gold lotus finials
    for x0 in (0, 472):
        c.rect(x0, 12, x0 + 7, 166, WOOD)
        c.rect(x0, 12, x0 + 1, 166, WOOD_HI); c.rect(x0 + 6, 12, x0 + 7, 166, WOOD_LO)
        for y in range(26, 160, 22):
            c.rect(x0, y, x0 + 7, y + 1, WOOD_LO); c.rect(x0 + 1, y + 2, x0 + 6, y + 2, GOLD_LO)
            c.set(x0 + 3, y + 8, GOLD); c.set(x0 + 4, y + 8, GOLD)
        c.rect(x0 - 1 if x0 else 0, 163, x0 + 8, 166, WOOD_LO)
    # gedebog: two banana trunks lying along the screen, pale and fibrous, the upper one where puppets are planted
    G = [hexc("E2E0A8"), hexc("C4C884"), hexc("9EAA62"), hexc("6E7C42"), hexc("47522C")]
    for (y0, y1) in ((148, 154), (155, 160)):
        for y in range(y0, y1 + 1):
            t = (y - y0) / (y1 - y0)
            b = 0 if t < 0.15 else (1 if t < 0.4 else (2 if t < 0.7 else (3 if t < 0.9 else 4)))
            for x in range(8, 472):
                cc = G[b]
                if b in (1, 2) and (x * 7 + y * 3) % 11 == 0:
                    cc = G[b + 1]                                      # fibres running along the trunk
                if (x + y0 * 3) % 61 < 2 and 0 < b < 4:
                    cc = hexc("8A6A3E")                                # a dry brown sheath patch
                c.set(x, y, cc)
    for x in range(14, 468, 9):
        c.set(x, 149, G[4]); c.set(x, 150, G[3])                       # puppet pin holes
    c.rect(8, 161, 471, 161, hexc("1A1008"))
    # the dark pendapa: boards fading to night, a pandan tikar under the light spill with a red trim
    for y in range(162, H):
        t = (y - 162) / (H - 162)
        for x in range(W):
            b = min(4, int(t * 4.2 + (0.5 if dith(x, y, (t * 4.2) % 1) else 0)))
            boards = (hexc("3A2618"), hexc("2C1C12"), hexc("20140C"), hexc("150D08"), hexc("0C0706"))[b]
            if y % 12 == 0 or (x + (y // 12) * 40) % 96 == 0:
                boards = shade(boards, 0.6)
            c.set(x, y, boards)
    T1, T2, TR = hexc("6E5434"), hexc("58422A"), hexc("6A2420")
    for y in range(165, 204):
        for x in range(40, 440):
            if x in (40, 439) or y in (165, 203):
                col = TR
            elif x in (42, 437) or y in (167, 201):
                col = hexc("B88A4A")
            else:
                col = T1 if ((x + y) // 2) % 2 == 0 else T2                # diagonal weave
            d = max(0.0, (y - 165) / 38 * 0.9 + abs(x - 240) / 200 * 0.5)
            b = int(d * 3 + (0.5 if dith(x, y, (d * 3) % 1) else 0))
            col = shade(col, (1.0, 0.72, 0.5, 0.34, 0.25)[min(b, 4)])
            c.set(x, y, col)
    for y in range(162, 192):                                        # warm spill from the lit cloth, dithered
        for x in range(30, 450):
            a = (1 - (y - 162) / 30) * (1 - abs(x - 240) / 230)
            if a > 0 and dith(x, y, a * 0.5):
                c.set(x, y, lerp(c.get(x, y), PAPER, 0.2))
    # the blencong chain hanging from the beam
    for y in range(12, 22, 2):
        c.set(240, y, GOLD_LO); c.set(240, y + 1, GOLD)
    return c.done()


# ----------------------------------------------------------------------------------------------- combat: pointers, arrow, shots
def aim_pointers():
    """16x16 each, pointing right, one family of marks with an ink outline: light blade (keris), heavy blade
    (double chevron), ranged (arrowhead and fletch), staff (cyan gem)."""
    frames = []
    S1, S2, S3 = hexc("FFFFFF"), hexc("D6E0E8"), hexc("8C9AAC")
    # light: one sleek steel chevron with a gleam down its edge
    c = C(16, 16)
    c.poly([(6, 3), (14, 8), (6, 13), (9, 8)], S2)
    c.line(7, 4, 13, 8, S1, 1)
    c.line(8, 11, 12, 9, S3, 1)
    frames.append(finish(c.done()))
    # heavy: two broad chevrons, bronze
    c = C(16, 16)
    B1, B2 = hexc("F0C890"), hexc("C88A50")
    c.poly([(3, 4), (8, 8), (3, 12), (5, 8)], B2)
    c.poly([(8, 3), (14, 8), (8, 13), (10, 8)], B1)
    c.line(9, 4, 13, 8, hexc("FFF0D0"), 1)
    frames.append(finish(bevel(c.done())))
    # ranged: arrowhead with red-white fletching
    c = C(16, 16)
    c.rect(4, 8, 11, 8, hexc("C8925A"))
    c.poly([(10, 5), (15, 8), (10, 11), (11, 8)], S2); c.line(11, 7, 14, 8, S1, 1)
    c.rect(2, 6, 4, 6, hexc("C83A2A")); c.rect(2, 10, 4, 10, hexc("C83A2A"))
    c.rect(3, 7, 5, 7, hexc("F0E2C8")); c.rect(3, 9, 5, 9, hexc("F0E2C8"))
    frames.append(finish(c.done()))
    # staff: a cyan gem with a spark and a short trail
    c = C(16, 16)
    A1, A2, A3 = hexc("E8FCFF"), hexc("6FE0FF"), hexc("2E8EC0")
    c.poly([(10, 4), (14, 8), (10, 12), (6, 8)], A2)
    c.poly([(10, 4), (14, 8), (10, 8)], A1)
    c.poly([(6, 8), (10, 12), (10, 8)], A3)
    c.set(4, 8, A2); c.set(2, 8, A3)
    frames.append(finish(c.done()))
    return frames


def arrow():
    """Player arrow in flight, 14x5, points right: steel head, bamboo shaft, red-white fletching."""
    rows = [
        "rR.......oo...",
        "orRooooooosSo.",
        "oRWwwwwwwwsSSs",
        "orRooooooodso.",
        "rR.......oo...",
    ]
    pal = {"o": hexc("2A1A14"), "w": hexc("B8884E"), "W": hexc("8A6236"), "s": hexc("A8B4C0"), "S": hexc("F4F8FC"),
           "d": hexc("5E6A78"), "r": hexc("A82A22"), "R": hexc("F0E2C8")}
    return px.sprite(rows, pal)


def spirit_shot(f):
    """A green will-o'-wisp, 12x12, 3 frames: a hot core, a flame that licks back, an ink edge so it reads."""
    c = C(12, 12)
    G1, G2, G3 = hexc("E8FFF0"), hexc("8CF0B8"), hexc("2FA878")
    tail = [[(2, 3), (5, 4), (4, 6)], [(1, 5), (4, 5), (4, 7)], [(2, 8), (5, 7), (4, 5)]][f]
    c.poly(tail, G3)
    c.ell(6.5, 6, 3.6, 3.6, G3)
    c.ell(6.5, 6, 2.6, 2.6, G2)
    c.rect(6, 5, 7, 6, G1)
    c.set(6, 4, G1)
    c.set((9, 10, 9)[f], (2, 3, 9)[f], G2)
    return finish(c, k=0.35)


def thrown_rock(f):
    """10x10, 2 frames (tumbling): a three-tone lump with a chip."""
    c = C(10, 10)
    shape = [(2, 2), (6, 1), (8, 4), (7, 8), (3, 8), (1, 5)] if f == 0 else [(2, 1), (7, 2), (8, 6), (5, 8), (1, 7), (1, 4)]
    c.poly(shape, hexc("8A7C6C"))
    img = bevel(c.done(), 1.25, 0.66)
    c.im = img
    c.set(*((5, 5) if f == 0 else (4, 4)), hexc("5E5246"))
    c.set(*((4, 3) if f == 0 else (5, 3)), hexc("C4B8A6"))
    return finish(c, k=0.4)


# ----------------------------------------------------------------------------------------------- world props
def chest(opened):
    """18x16: a teak peti with brass corners and a carved lid; base at y 14 (chest.gd draws it 6 px up)."""
    c = C(18, 16)
    body, body_hi, body_lo = hexc("7A4A26"), hexc("A86C3A"), hexc("4E2E18")
    c.rect(2, 7, 15, 13, body)
    c.rect(2, 7, 15, 7, body_hi); c.rect(2, 13, 15, 13, body_lo)
    for y in (9, 11):
        c.rect(3, y, 14, y, shade(body, 0.85))                              # planks
    for x in (2, 14):
        c.rect(x, 7, x + 1, 13, GOLD); c.rect(x, 7, x, 13, GOLD_HI)         # brass corners
    if opened:
        c.poly([(2, 6), (16, 6), (14, 1), (4, 1)], body_lo)                 # lid thrown back, seen from inside
        c.rect(4, 2, 13, 2, body)
        c.rect(3, 6, 14, 7, hexc("2A160A"))
        c.rect(4, 6, 13, 6, GOLD_HI); c.rect(5, 5, 7, 5, GOLD); c.rect(10, 5, 12, 5, hexc("F8E8A0"))   # gold inside
        c.set(8, 4, hexc("FFFFFF")); c.set(6, 4, GOLD_HI)
    else:
        c.poly([(2, 7), (16, 7), (15, 3), (13, 2), (5, 2), (3, 3)], body)    # rounded lid
        c.rect(4, 2, 13, 2, body_hi); c.rect(3, 3, 14, 3, body_hi)
        c.rect(2, 6, 15, 6, body_lo)
        for x in (2, 14):
            c.rect(x, 3, x + 1, 6, GOLD); c.set(x, 3, GOLD_HI)
        c.rect(7, 5, 10, 9, GOLD); c.rect(7, 5, 10, 5, GOLD_HI); c.rect(8, 7, 9, 8, INK)   # hasp
        c.set(6, 4, hexc("C08A50")); c.set(11, 4, hexc("C08A50"))                       # carved lid flowers
    return finish(c, shadow=(8.5, 14, 8, 2))


def kabut():
    """Fog tile, 32x32, wraps both ways: long low streaks in three dithered levels. The scene tints and pulses it."""
    n = 32
    im = Image.new("RGBA", (n, n), T)
    p = im.load()
    rnd = random.Random(5)
    blobs = [(rnd.uniform(0, n), rnd.uniform(0, n), rnd.uniform(7, 12), rnd.uniform(3, 5)) for _ in range(6)]
    for y in range(n):
        for x in range(n):
            v = 0.0
            for (bx, by, rx, ry) in blobs:
                for ox in (-n, 0, n):
                    for oy in (-n, 0, n):
                        d = math.hypot((x - bx - ox) / rx, (y - by - oy) / ry)
                        v = max(v, 1 - d)
            if v <= 0:
                continue
            lvl = v * 3.2
            b = int(lvl)
            if dith(x, y, lvl - b):
                b += 1
            a = (0, 46, 92, 140)[min(b, 3)]
            if a:
                p[x, y] = (226, 232, 242, a)
    return im


def pillar():
    """18x36 candi pillar: a stepped capital and plinth, a carved panel with a kawung, a moss line at the foot."""
    c = C(18, 36)
    st, hi, lo, dk = hexc("8E8676"), hexc("B8AE9A"), hexc("625C52"), hexc("413C36")
    c.rect(3, 6, 14, 31, st)
    c.rect(3, 6, 4, 31, hi); c.rect(13, 6, 14, 31, lo)
    c.rect(1, 1, 16, 3, st); c.rect(1, 1, 16, 1, hi); c.rect(2, 4, 15, 5, lo)        # capital
    c.rect(4, 0, 13, 0, hi)
    c.rect(1, 31, 16, 34, st); c.rect(1, 31, 16, 31, hi); c.rect(1, 34, 16, 34, lo)  # plinth
    c.rect(6, 9, 11, 26, lo); c.rect(7, 10, 10, 25, st)                             # carved panel
    for i, y0 in enumerate((11, 19)):                                               # tumpal: carved triangles
        for k in range(5):
            c.rect(8 - k // 2, y0 + k, 9 + k // 2, y0 + k, dk if i == 0 else lo)
        c.set(8, y0 + 1, hi); c.set(8, y0 + 3, hi)
    c.rect(7, 17, 10, 17, dk); c.rect(7, 18, 10, 18, hi)
    c.set(13, 12, dk); c.set(12, 13, dk); c.set(13, 20, dk); c.set(4, 24, lo)        # cracks
    for x in range(2, 16):
        if (x * 7) % 5 < 3:
            c.set(x, 32, hexc("5E7A3A"))                                             # moss
    c.set(3, 30, hexc("7EA24C")); c.set(14, 29, hexc("5E7A3A"))
    return finish(c, shadow=(9, 35, 8, 1.5))


def oncor(f):
    """Oncor, the Sundanese bamboo torch, 16x34: frame 0 cold, 1-3 burning. Base of the pole at y 33."""
    c = C(16, 34)
    B1, B2, B3 = hexc("C8B062"), hexc("9C8A44"), hexc("6A5C2C")
    c.rect(7, 13, 9, 32, B2); c.rect(7, 13, 7, 32, B1); c.rect(9, 13, 9, 32, B3)
    for y in (17, 24, 30):
        c.rect(7, y, 9, y, B3)                                              # bamboo nodes
    c.poly([(5, 9), (11, 9), (10, 14), (6, 14)], B2)                        # the open culm that holds the oil
    c.rect(5, 9, 11, 9, B1); c.rect(6, 13, 10, 13, B3)
    c.rect(6, 11, 10, 11, hexc("8A3A2A"))                                   # a red rag tied round it
    c.set(11, 12, hexc("8A3A2A")); c.set(12, 13, hexc("6A2A1E"))
    if f == 0:
        c.rect(7, 6, 9, 8, hexc("3A302A")); c.set(8, 5, hexc("5A4E44"))     # charred wick
        c.set(9, 3, hexc("8A8078", 140)); c.set(8, 1, hexc("8A8078", 90))    # a curl of smoke
    else:
        s = (0, 0, 1, -1)[f]
        c.poly([(5, 9), (11, 9), (11, 5 + s), (8 + s, -1), (5, 5)], hexc("E0501E"))
        c.poly([(6, 9), (10, 9), (10, 6), (8 + s, 2), (6, 6)], hexc("FFA834"))
        c.poly([(7, 9), (9, 9), (9, 6), (8, 4)], hexc("FFF0A0"))
    img = finish(c, shadow=(8, 33, 5, 1.2))
    if f:                                                                   # the flame stays un-outlined: it glows
        img.putpixel((8 + (0, 0, 1, -1)[f], 0), (255, 200, 120, 160))
    return img


def curse_stake(f):
    """Curse stake 12x24 (base at y 23): a split bamboo stake bound in black thread with a rajah strip.
    0 unlit, 1 marked (the rajah wakes), 2 lit (it burns red)."""
    c = C(12, 24)
    wood = (hexc("5A4836"), hexc("5E3E36"), hexc("5A2620"))[f]
    c.poly([(4, 7), (8, 7), (7, 22), (5, 22)], wood)
    c.poly([(4, 7), (6, 1), (8, 7)], wood)
    c.im = bevel(c.done(), 1.25, 0.7)
    for y in (8, 15, 19):
        c.rect(4, y, 7, y, hexc("1A1418"))                                   # binding thread
    paper = (hexc("C8B88A"), hexc("E8D4A0"), hexc("F0C8A0"))[f]
    c.rect(5, 10, 6, 14, paper)                                            # rajah strip
    ink = (hexc("6A5A4A"), hexc("C83A2A"), hexc("FF4A2A"))[f]
    c.set(5, 11, ink); c.set(6, 12, ink); c.set(5, 13, ink)
    if f == 2:
        c.set(6, 0, hexc("FF8A3A")); c.set(5, 2, hexc("FFD06A"))
    img = finish(c, shadow=(6, 23, 4, 1))
    if f == 2:
        g = C(12, 24)
        for (x, y) in ((6, 3), (5, 9), (6, 16)):
            g.ell(x, y, 3, 2.5, hexc("FF3A20", 60))
        gi = g.done()
        gi.alpha_composite(img)
        img = gi
    return img


def pouch(kind, size=64):
    """Ground decal for Buto Ijo's pouch fields, 64x64 (scaled to the field). A dark rim marks the edge you must not
    cross, and each kind has its own surface: thorn vines, bamboo shoots, salt crust, wet mud."""
    pal = {"bramble": (hexc("2F5A26"), hexc("4E8A3A"), hexc("1A3418"), hexc("A8D070")),
           "bamboo": (hexc("8AA040"), hexc("B8CC5E"), hexc("56682A"), hexc("E8F0A0")),
           "salt": (hexc("B4C8DA"), hexc("DCE8F4"), hexc("7890A8"), hexc("FFFFFF")),
           "mud": (hexc("4A3018"), hexc("6A4826"), hexc("2A1A0C"), hexc("9A7448"))}[kind]
    base, light, rim, mark = pal
    im = Image.new("RGBA", (size, size), T)
    p = im.load()
    rnd = random.Random(sum(map(ord, kind)) * 977)
    h = size / 2
    for y in range(size):
        for x in range(size):
            r = math.hypot(x - h + .5, y - h + .5) / h
            wob = 0.04 * math.sin(math.atan2(y - h, x - h) * 7 + len(kind))
            r += wob
            if r > 0.98:
                continue
            if r > 0.86:
                if r > 0.93 and not dith(x, y, 0.5):
                    continue
                p[x, y] = (*rim[:3], 200)
                continue
            col = base
            n = math.sin(x * 0.45 + y * 0.2) + math.sin(y * 0.5 - x * 0.15)
            if n > 0.9 and dith(x, y, 0.6):
                col = light
            p[x, y] = (*col[:3], 150)
    def put(x, y, c, a=235):
        if 0 <= x < size and 0 <= y < size and math.hypot(x - h, y - h) < h * 0.82:
            p[x, y] = (*c[:3], a)
    for _ in range({"bramble": 14, "bamboo": 16, "salt": 30, "mud": 14}[kind]):
        x, y = rnd.randint(10, size - 11), rnd.randint(10, size - 11)
        if kind == "bramble":                               # a curling thorn vine
            for k in range(6):
                put(x + k, y + int(math.sin(k * 0.9) * 2), rim)
                put(x + k, y - 1 + int(math.sin(k * 0.9) * 2), light)
            put(x + 2, y - 3, mark); put(x + 4, y + 2, mark)
        elif kind == "bamboo":                              # a sharp shoot (rebung)
            put(x, y, rim); put(x + 1, y, rim)
            put(x, y - 1, light); put(x + 1, y - 1, base)
            put(x, y - 2, mark); put(x, y - 3, mark, 200)
        elif kind == "salt":                                # crystals that glint
            put(x, y, mark)
            if rnd.random() < 0.4:
                put(x - 1, y, light); put(x + 1, y, light); put(x, y - 1, light); put(x, y + 1, light)
            else:
                put(x + 1, y + 1, rim, 200)
        else:                                               # a mud bubble with a wet glint
            put(x, y, rim); put(x + 1, y, rim); put(x, y - 1, light); put(x + 1, y - 1, light); put(x, y - 2, mark)
    return im


def arena_post(hung):
    """Sangkuriang's east post, 14x26 (offset -1,-25: the pole stands at x 1-2). When hung, the red boeh rarang cloth
    flies east from it, with a white band and a gold mark."""
    c = C(14, 26)
    c.rect(1, 3, 3, 24, WOOD); c.rect(1, 3, 1, 24, WOOD_HI); c.rect(3, 3, 3, 24, WOOD_LO)
    c.poly([(1, 3), (3, 3), (2, 0)], WOOD_HI); c.set(2, 1, GOLD)
    for y in (9, 17):
        c.rect(1, y, 3, y, WOOD_LO)
    c.rect(0, 23, 4, 25, WOOD_LO)
    if hung:
        R1, R2, R3 = hexc("D8362E"), hexc("A82222"), hexc("701616")
        c.poly([(4, 3), (12, 4), (10, 7), (12, 11), (4, 11)], R2)
        c.rect(4, 3, 11, 4, R1)
        c.rect(4, 7, 9, 8, hexc("F0E6D2"))                    # white band
        c.rect(4, 10, 11, 11, R3)
        c.set(7, 5, GOLD_HI); c.set(8, 6, GOLD)
        c.rect(4, 3, 4, 11, WOOD_DK)                          # tie
    return finish(c, shadow=(3, 25, 3, 1))


# ----------------------------------------------------------------------------------------------- villagers, boss shots
def emote(kind):
    """Speech bubble 11x10 (tail at bottom): 0 dots, 1 !, 2 ?, 3 heart, 4 note. Dusk ink edge, cream body."""
    ink, paper, ph = hexc("17122A"), hexc("F6EEDC"), hexc("FFFFFF")
    rows = [
        ".ooooooooo.",
        "oPPPPPPPPpo",
        "oP.......po",
        "oP.......po",
        "oP.......po",
        "oP.......po",
        ".oppppppppo",
        "..oooo.ooo.",
        "...opo.....",
        "....o......",
    ]
    rows = [r.replace(".", "_") if 0 < i < 6 else r for i, r in enumerate(rows)]
    rows = [r[0] + r[1:-1].replace("_", "c") + r[-1] if 0 < i < 6 else r for i, r in enumerate(rows)]
    rows = [r.replace("_", ".") for r in rows]
    pal = {"o": ink, "P": ph, "p": hexc("D8CCB4"), "c": paper}
    img = px.sprite(rows, pal)
    sym = {0: ([(3, 4), (5, 4), (7, 4)], hexc("17122A")),
           1: ([(5, 2), (5, 3), (5, 5)], hexc("E09A1A")),
           2: ([(4, 2), (5, 2), (6, 2), (6, 3), (5, 4), (5, 5)], hexc("2E8EB0")),
           3: ([(3, 2), (4, 2), (6, 2), (7, 2), (3, 3), (4, 3), (5, 3), (6, 3), (7, 3), (4, 4), (5, 4), (6, 4), (5, 5)], hexc("D8384A")),
           4: ([(6, 2), (7, 2), (6, 3), (6, 4), (5, 4), (4, 5), (5, 5)], hexc("4A5AC0"))}[kind]
    for (x, y) in sym[0]:
        img.putpixel((x, y), sym[1])
    if kind == 3:
        img.putpixel((4, 2), hexc("FF8A9A"))
    return img


def boss_blade():
    """Blade/shard 24x10 pointing right, in greys: the engine tints it with the shot colour."""
    c = C(24, 10)
    c.poly([(22, 5), (14, 2), (6, 3), (3, 5), (6, 7), (14, 8)], hexc("B8BCC8"))
    c.poly([(21, 5), (14, 3), (7, 4), (7, 5)], hexc("FFFFFF"))
    c.rect(1, 4, 3, 6, hexc("70707E"))
    for x in (10, 14, 18):
        c.set(x, 6, hexc("8C90A0"))
    return finish(c, k=0.35)


def boss_log():
    """A rolling teak log 32x12 with bark, a knot and pale cut ends with rings."""
    c = C(32, 12)
    c.rect(3, 1, 28, 10, hexc("6E4628")); c.rect(3, 1, 28, 2, hexc("9A6838")); c.rect(3, 9, 28, 10, hexc("442A16"))
    for x in (7, 12, 18, 24):
        c.rect(x, 3, x, 8, hexc("4E3220")); c.set(x + 1, 4, hexc("8A5C32"))
    c.ell(15, 6, 1.6, 1.4, hexc("3A2414"))
    for ex in (2.5, 29.5):
        c.ell(ex, 5.5, 2.5, 4.6, hexc("D8B07A"))
        c.ell(ex, 5.5, 1.4, 2.6, hexc("B88A52"))
        c.set(int(ex), 5, hexc("8A5C32"))
    return finish(c)


def boss_skull():
    """A tinted skull 14x14: bone with a jaw, hollow eyes with ember pupils."""
    rows = [
        "...bbbbbb...",
        "..BBBBBBbb..",
        ".BBBBBBBbbb.",
        ".BBBBBBBBbb.",
        ".BkkBBBkkbb.",
        ".BkrkBBkrkb.",
        ".BkkBBBkkbb.",
        "..BBBkBBbb..",
        "...bBBBbb...",
        "...BkBkBk...",
        "...bbbbbb...",
    ]
    pal = {"B": hexc("ECE4D2"), "b": hexc("B8AE98"), "k": hexc("17122A"), "r": hexc("FF5A3A")}
    img = Image.new("RGBA", (14, 14), T)
    img.alpha_composite(px.sprite(rows, pal), (1, 1))
    return px.outline(img, 0.35, keep_pad=False)


def boss_orb(f):
    """A tinted spirit orb 16x16, 3 frames: a ringed sphere with a lit core and a orbiting spark."""
    c = C(16, 16)
    r = (5.6, 6.2, 5.9)[f]
    c.ell(8, 8, r, r, hexc("C8C8D0"))
    c.ell(8, 8, r - 1.4, r - 1.4, hexc("E8E8EE"))
    c.ell(7, 7, r - 3.4, r - 3.4, hexc("FFFFFF"))
    img = finish(c, k=0.35)
    a = f * 2.1
    img.putpixel((int(8 + math.cos(a) * 7.4), int(8 + math.sin(a) * 7.4)), hexc("FFFFFF"))
    return img


# ----------------------------------------------------------------------------------------------- kelir set pieces
# The things you act on in a memory. Painted like the cutscene props (gong, blencong): outlined, lit from the top-left.
CLOTH_C, CLOTH_H, CLOTH_D = hexc("E2D0A4"), hexc("F6EAC6"), hexc("A8906A")
BATIK_R, BATIK_B = hexc("9A2E26"), hexc("2A4C7A")


def prop_cloth(done):
    """K2: the cloth you spread. 0 folded in a stack, 1 spread out, a batik kawung border."""
    c = C(22, 20)
    if not done:
        for i, y in enumerate((14, 11, 8)):
            col = (CLOTH_C, hexc("C88A5A"), CLOTH_C)[i]
            c.rect(5, y, 16, y + 3, col); c.rect(5, y, 16, y, shade(col, 1.15)); c.rect(5, y + 3, 16, y + 3, shade(col, 0.75))
        for x in range(6, 16, 3):
            c.set(x, 13, BATIK_R); c.set(x + 1, 16, BATIK_B)
        c.rect(15, 8, 16, 17, shade(CLOTH_C, 0.8))
        return finish(c, shadow=(11, 18, 8, 1.5))
    c.poly([(1, 17), (21, 17), (18, 8), (4, 8)], CLOTH_C)
    c.poly([(3, 16), (19, 16), (17, 10), (5, 10)], CLOTH_H)
    for x in range(4, 19, 3):
        c.set(x, 9, BATIK_R); c.set(x - 1, 16, BATIK_R)
    for x in range(6, 17, 4):
        for (ox, oy) in ((0, 0), (1, 1), (-1, 1), (0, 2)):
            c.set(x + ox, 12 + oy, BATIK_B)                      # kawung in the field
    return finish(c, shadow=(11, 18, 10, 1.5))


def prop_lesung(done):
    """K2 and K3: the long rice mortar (lesung) and its pestle (alu). 1 = struck: the alu is down, husk flies."""
    c = C(22, 22)
    L1, L2, L3 = hexc("A87444"), hexc("7A4E2A"), hexc("4E301A")
    c.poly([(2, 12), (19, 12), (18, 19), (3, 19)], L2)
    c.rect(2, 12, 19, 12, L1); c.rect(3, 19, 18, 19, L3)
    c.rect(4, 13, 17, 14, hexc("2A180C"))                      # the trough
    c.rect(6, 13, 9, 13, hexc("E8DCB8")); c.rect(12, 14, 15, 14, hexc("D8C890"))   # rice
    c.rect(5, 16, 16, 16, L3)
    c.im = c.done()
    y0 = 6 if done else 0
    c.rect(10, y0, 11, y0 + 9 if done else 12, hexc("D0A870")); c.rect(10, y0, 10, (y0 + 9) if done else 12, hexc("ECCC94"))
    c.rect(9, y0, 12, y0 + 1, hexc("B88A52"))
    if done:
        for (x, y) in ((5, 9), (16, 8), (3, 6), (18, 5), (7, 4), (14, 3)):
            c.set(x, y, hexc("F4ECD0"))
    return finish(c, shadow=(11, 20, 9, 1.5))


def prop_pouch(done):
    """K4: a tied cloth pouch of seeds; thrown, it lies open and the seeds spill."""
    c = C(18, 18)
    P1, P2, P3 = hexc("C88250"), hexc("A06238"), hexc("6A3E22")
    if not done:
        c.poly([(4, 15), (13, 15), (14, 10), (11, 6), (6, 6), (3, 10)], P2)
        c.poly([(4, 14), (8, 14), (8, 7), (6, 7), (4, 10)], P1)
        c.rect(5, 15, 13, 15, P3)
        c.poly([(6, 6), (11, 6), (12, 3), (9, 4), (5, 3)], P2)  # gathered neck
        c.rect(6, 5, 11, 5, GOLD); c.set(12, 6, GOLD); c.set(13, 7, GOLD_LO)   # cord
        c.set(9, 11, hexc("E8C070")); c.set(8, 12, hexc("E8C070")); c.set(10, 12, hexc("E8C070"))
        return finish(c, shadow=(9, 16, 6, 1.5))
    c.poly([(2, 15), (9, 15), (8, 11), (3, 11)], P2)
    c.rect(3, 11, 8, 11, P1); c.rect(4, 12, 7, 12, hexc("3A2414"))
    for (x, y) in ((10, 14), (12, 12), (14, 15), (11, 16), (13, 10), (15, 12), (9, 12), (16, 14)):
        c.set(x, y, hexc("8CCB54")); c.set(x + 1, y, hexc("4E8A2E"))
    return finish(c, shadow=(9, 16, 7, 1.5))


AKSARA = ((7, 9), (7, 10), (7, 11), (8, 11), (9, 11), (9, 10), (9, 9), (10, 9), (11, 9), (11, 10), (11, 11), (11, 12),
          (12, 12), (7, 13), (8, 14), (9, 14), (10, 14), (11, 14))   # an aksara-like carved mark, not a real letter


def prop_slab(done):
    """K7 and the Laras chapters: a prasasti (inscription stone) with the ogee point of old Javanese stelae and a
    carved border; it takes a glyph. 1 = the glyph glows cyan."""
    c = C(20, 24)
    S1, S2, S3, S4 = hexc("B4AEC4"), hexc("8A84A0"), hexc("625C78"), hexc("403A52")
    c.poly([(3, 21), (16, 21), (16, 9), (13, 5), (11, 3), (10, 0), (9, 3), (7, 5), (3, 9)], S2)
    c.im = bevel(c.done(), 1.22, 0.72)
    c.poly([(5, 19), (14, 19), (14, 10), (11, 7), (10, 5), (9, 7), (6, 10)], S3)       # sunk panel
    c.poly([(6, 18), (13, 18), (13, 10), (10, 8), (7, 10)], S2)
    c.rect(2, 20, 17, 22, S3); c.rect(2, 20, 17, 20, S1)                                # plinth
    col = hexc("8CF4EC") if done else S4
    if done:
        for (x, y) in AKSARA:
            for (ox, oy) in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                if (x + ox, y + oy) not in AKSARA:
                    c.set(x + ox, y + oy, hexc("3EA8B0"))
    for (x, y) in AKSARA:
        c.set(x, y, col)
    if done:
        c.set(9, 11, hexc("FFFFFF")); c.set(10, 1, hexc("8CF4EC"))
    c.set(15, 12, S4); c.set(14, 13, S4)
    return finish(c, shadow=(10, 22, 8, 2))


def prop_basket(done):
    """SQ-G1: a woven bamboo basket on the ground, then hung on its hook."""
    c = C(20, 24)
    W1, W2, W3 = hexc("E0BC70"), hexc("BC9450"), hexc("86643A")

    def basket(top, bot):
        c.poly([(3, top), (16, top), (14, bot), (5, bot)], W2)
        for y in range(top + 1, bot):
            for x in range(4, 16):
                if (x + (y // 2) * 2) % 4 == 0:
                    c.set(x, y, W3)
                elif (x + y) % 4 == 1:
                    c.set(x, y, W1)
        c.rect(3, top, 16, top, W1); c.rect(3, top + 1, 16, top + 1, W3)
    if not done:
        basket(12, 20)
        c.line(4, 12, 6, 6, W3, 1); c.line(15, 12, 13, 6, W3, 1); c.rect(6, 5, 13, 5, W3)   # handle
        return finish(c, shadow=(10, 21, 8, 1.5))
    c.rect(9, 0, 10, 1, WOOD); c.set(10, 2, WOOD_LO); c.set(10, 3, WOOD_LO)           # hook
    c.line(10, 3, 5, 9, W3, 1); c.line(10, 3, 14, 9, W3, 1)
    basket(9, 17)
    return finish(c, shadow=(10, 21, 6, 1.2))


def prop_beans(done):
    """SQ-M3: a hemp sack of green beans, tied; then tipped over with the beans scattered."""
    c = C(22, 18)
    K1, K2, K3 = hexc("D8C08A"), hexc("B49A62"), hexc("7E6A40")
    if not done:
        c.poly([(5, 15), (16, 15), (17, 9), (13, 5), (8, 5), (4, 9)], K2)
        c.poly([(5, 14), (9, 14), (9, 6), (8, 6), (5, 9)], K1)
        c.rect(5, 15, 16, 15, K3)
        c.poly([(8, 5), (13, 5), (14, 2), (11, 3), (7, 2)], K2); c.rect(8, 4, 13, 4, hexc("6A4A2A"))
        c.rect(9, 8, 12, 8, K3); c.rect(10, 10, 11, 10, K3)          # stitched mark
        c.set(13, 3, hexc("7FC048")); c.set(12, 2, hexc("4E8A2E"))
        return finish(c, shadow=(10.5, 16, 7, 1.5))
    c.poly([(1, 14), (8, 14), (8, 10), (4, 9), (1, 11)], K2); c.rect(2, 10, 6, 10, K1)
    c.rect(7, 11, 8, 13, hexc("3A2A16"))
    for (x, y) in ((10, 13), (12, 11), (13, 14), (15, 12), (17, 14), (19, 11), (11, 15), (16, 9), (18, 15), (14, 16)):
        c.set(x, y, hexc("7FCC4E")); c.set(x + 1, y, hexc("3E8A2E"))
    return finish(c, shadow=(11, 16, 10, 1.5))


def prop_water(done):
    """SQ-T1: a still pool in a stone rim; struck, it rings."""
    c = C(26, 16)
    c.ell(13, 9, 12, 6, hexc("6E6A7A"))                            # stone rim
    c.ell(13, 8.5, 11, 5, hexc("8C889A"))
    c.ell(13, 9, 10, 4.4, hexc("1E4A7A"))
    c.ell(13, 8.6, 9, 3.6, hexc("2E6AA8"))
    for (x, y) in ((4, 6), (9, 4), (19, 4), (23, 7)):
        c.set(x, y, hexc("B4B0C2"))
    if not done:
        c.rect(8, 8, 11, 8, hexc("6EA8E0")); c.rect(15, 10, 16, 10, hexc("6EA8E0"))
    else:
        for r, col in ((2.5, hexc("FFFFFF")), (5, hexc("BCE0FF")), (7.5, hexc("6EA8E0"))):
            for deg in range(0, 360, 10):
                x, y = 13 + math.cos(math.radians(deg)) * r, 8.6 + math.sin(math.radians(deg)) * r * 0.42
                c.set(x, y, col)
        c.set(13, 6, hexc("FFFFFF")); c.set(13, 5, hexc("DCEEFF"))
    return finish(c)


def prop_stone(done):
    """A ritual stone (SQ memories with a mark): a river boulder set on its end, mossy at the foot; the carved mark on
    its face lights amber when done."""
    c = C(18, 18)
    c.poly([(2, 16), (15, 16), (16, 11), (14, 6), (10, 3), (5, 4), (2, 9)], hexc("8C86A0"))
    c.im = bevel(c.done(), 1.22, 0.7)
    c.set(5, 6, hexc("C4BED6")); c.set(6, 5, hexc("C4BED6"))
    mark = ((6, 7), (7, 7), (8, 7), (9, 7), (10, 7), (10, 8), (10, 9), (10, 10), (9, 10), (8, 10), (8, 9),
            (6, 8), (6, 9), (6, 10), (6, 11), (6, 12), (7, 12), (8, 12), (9, 12), (10, 12), (11, 12))   # a carved spiral
    if done:
        for (x, y) in mark:
            for (ox, oy) in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                if (x + ox, y + oy) not in mark:
                    c.set(x + ox, y + oy, hexc("B86A2A"))
    for (x, y) in mark:
        c.set(x, y, hexc("FFC46A") if done else hexc("4E4862"))
    for x in range(3, 15):
        if (x * 5) % 7 < 3:
            c.set(x, 15, hexc("6E8A3A"))
    c.set(13, 14, hexc("8EAA4A")); c.set(4, 14, hexc("8EAA4A"))
    return finish(c, shadow=(9, 16, 7, 2))


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
    scr = out(screen(), "cutscene/k0_screen.png")
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
    px.preview([(n, i) for n, i in PREVIEW if i.width <= 400 and "lamp_glow" not in n],
               os.path.join(HERE, "revamp_preview.png"), scale=3, bg=(74, 100, 74, 255))
    px.preview([("screen", scr)], os.path.join(HERE, "k0_screen_preview.png"), scale=2, bg=(0, 0, 0, 255))
    print("ok")


if __name__ == "__main__":
    main()
