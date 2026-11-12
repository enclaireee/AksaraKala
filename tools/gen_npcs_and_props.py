#!/usr/bin/env python3
"""Generate NPC & interactive prop spritesheet (assets/art/npcs.png) for Budayago.
32x32 cells (the hero's cell, gen_hero_sprites.py), 4 columns (idle breathing frames) x 14 archetype rows:
  0: villager / farmer / fisher (brown caping, green kampret, hoe on the shoulder)
  1: elder / juru_kunci / lengser / dalang (white beard, indigo batik, leans on a staff)
  2: woman / ibu / weaver / nyai / dayang_sumbi (maroon kebaya, bakul carried in a selendang)
  3: royal / ciung_wanara / queen / princess (gold makuta and sumping, maroon and gold, blue kain)
  4: semar (panakawan wise figure, short and round, white kuncung tuft, poleng cloth)
  5: cepot (red-faced Sundanese panakawan, iket, warm grin, stocky, hands on hips)
  6: laras (hero's sister, teal/gold kebaya, flower in her sanggul)
  7: smith / empu / guard / official (upright, leather apron, hammer)
  8: lutung / cat (dark sacred monkey / village animal), sitting
  9: stone / prasasti / altar (inscribed candi monolith, glowing script)
 10: wooden mechanism / door / stall / wheel (carved door in its frame)
 11: stone oil lamp (galuh_lamp), animated flame
 12: masked stranger (tall blank mask, wide hat: nameless hunter, market stranger)
 13: faceless villager (hooded, blank face: deserter)
Figures stand on row 29 like the hero (GROUND), about 26 px tall, head 10 px, lit from the top-left, 3 tones per
material (the hero's ramps), a coloured outline on the lit side and the hero's dark plum outline on the shade side.
Idle frames: breathing bob (0, 0, 1, 1) over planted feet, plus cloth, tail, flame and glyph glow loops.
Run: python3 tools/gen_npcs_and_props.py
"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from PIL import Image
import pixlib as px
from pixlib import hexc
from gen_hero_sprites import ramp, mix, SKIN, HAIR, EYE, GOLD, WOOD, STEEL, OUTLINE

CW = CH = 32
GROUND = 29                      # the row the feet stand on, as for the hero
ROWS = 14
BOB = (0, 0, 1, 1)
WHITE_EYE = hexc("F6EEDC")

# materials: (dark, mid, light), the hero's ramp() so both sheets share one palette logic
RED = ramp("D94B38", "8E2A2A", "F27A5C")          # Cepot's red skin
WHITE = ramp("E4DFCC", "9C9484", "FFFCF0")        # white hair, beards, poleng white
TUNIC = ramp("6A994E")                            # villager green kampret
BROWN = ramp("6B4E35")                            # pangsi trousers, kain
CAPING = ramp("8A6A44", "5A4030", "B8935E")       # villager's brown woven hat
INDIGO = ramp("4A78A8")                           # elder's batik
MAROON = ramp("B84A62")                           # kebaya
TEAL = ramp("2A9D8F")                             # Laras' kebaya
DARK = ramp("3E3852", "211C30", "5E5674")         # dark pangsi, iket
ROYAL = ramp("3D5E96")                            # royal blue kain
LEATHER = ramp("8A5A34", "52321E", "B47E4C")      # smith's apron
BAMBOO = ramp("C49A5A", "7E5A30", "E6C68A")       # bakul basket
SELENDANG = ramp("D8A23A", "8E5E22", "F4D27A")    # ochre selendang
STONE = ramp("8C8881", "55505A", "BDB8AC")        # candi stone
MOSS = ramp("5E7A44", "3A4E30", "86A060")
FUR = ramp("3A3444", "1C1824", "5E5868")          # lutung
CLOAK = ramp("6E6A78", "403C4C", "928E9C")        # grey cloak (stranger, faceless)
MASK = ramp("E6DECA", "AEA48C", "FFF8EA")         # blank mask
FLAME = (hexc("E8622A"), hexc("FF9F1C"), hexc("FFE066"))
GLOW = hexc("FFC860")


class Cv:
    """A sparse pixel canvas; `soft` pixels (glows) take no outline."""

    def __init__(self):
        self.p = {}
        self.soft = set()

    def px(self, x, y, c, soft=False):
        k = (int(round(x)), int(round(y)))
        self.p[k] = c
        (self.soft.add if soft else self.soft.discard)(k)

    def rect(self, x0, y0, x1, y1, c):
        for y in range(int(y0), int(y1) + 1):
            for x in range(int(x0), int(x1) + 1):
                self.px(x, y, c)

    def row(self, y, x0, x1, c):
        self.rect(x0, y, x1, y, c)

    def block(self, x0, y0, x1, y1, m):
        """Filled box lit from the top-left: light left column, dark right column."""
        self.rect(x0, y0, x1, y1, m[1])
        if x1 - x0 >= 2:
            self.rect(x0, y0, x0, y1, m[2])
            self.rect(x1, y0, x1, y1, m[0])

    def line(self, x0, y0, x1, y1, c, soft=False):
        n = int(max(abs(x1 - x0), abs(y1 - y0)))
        for i in range(n + 1):
            t = i / n if n else 0.0
            self.px(x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, c, soft)

    def disc(self, cx, cy, r, c):
        for y in range(int(cy - r - 1), int(cy + r + 2)):
            for x in range(int(cx - r - 1), int(cx + r + 2)):
                if (x - cx) ** 2 + (y - cy) ** 2 <= r * r + 0.3:
                    self.px(x, y, c)

    def shaded_disc(self, cx, cy, r, m, ry=None):
        """An ellipse lit from the top-left: light rim up-left, dark rim down-right."""
        ry = ry or r
        for y in range(int(cy - ry - 1), int(cy + ry + 2)):
            for x in range(int(cx - r - 1), int(cx + r + 2)):
                d = ((x - cx) / r) ** 2 + ((y - cy) / ry) ** 2
                if d <= 1.02:
                    lit = (x - cx) / r + (y - cy) / ry
                    c = m[2] if lit < -0.75 else (m[0] if lit > 0.55 else m[1])
                    self.px(x, y, c)

    def glow(self, cx, cy, r, c, amp=1.0):
        """A soft halo that never covers a solid pixel."""
        for y in range(int(cy - r - 1), int(cy + r + 2)):
            for x in range(int(cx - r - 1), int(cx + r + 2)):
                d = ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5
                if d <= r + 0.2 and (x, y) not in self.p:
                    a = int(150 * amp * (1.0 - d / (r + 1.0)))
                    if a > 24:
                        self.px(x, y, c[:3] + (a,), True)

    def image(self):
        """Outline: the lit side (up/left of the shape) takes a dark version of the colour it touches, the shade
        side the hero's plum OUTLINE, so the edge stays dark on grass, sand and stone alike."""
        img = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
        solid = {k for k in self.p if k not in self.soft}
        edge = {}
        for (x, y) in solid:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                k = (x + dx, y + dy)
                if k in solid or not (0 <= k[0] < CW and 0 <= k[1] < CH):
                    continue
                shade_side = dx > 0 or dy > 0
                prev = edge.get(k)
                if shade_side or prev is None:
                    edge[k] = OUTLINE if shade_side or prev == OUTLINE else mix(self.p[(x, y)], OUTLINE, 0.72)
        for k, c in edge.items():
            img.putpixel(k, c)
        for (x, y), c in self.p.items():
            if 0 <= x < CW and 0 <= y < CH and ((x, y) in solid or (x, y) not in edge):
                img.putpixel((x, y), c)
        return img


# ---------------------------------------------------------------- shared parts
def face(cv, x, y, sk, eyes="open", mouth="line", brow=None, w=10):
    """The hero's 10 px head shape below the hairline (rows 4-9 of a head whose top-left is (x, y))."""
    r = w - 1
    cv.row(y + 4, x + 2, x + r - 2, sk[1]); cv.row(y + 4, x + 2, x + 3, sk[2])
    for yy in (5, 6):
        cv.row(y + yy, x, x + r, sk[1]); cv.px(x, y + yy, sk[0]); cv.px(x + r, y + yy, sk[0])
    cv.row(y + 5, x + 1, x + 3, sk[2]); cv.px(x + 1, y + 6, sk[2])
    cv.row(y + 7, x + 1, x + r - 1, sk[1]); cv.px(x + 1, y + 7, sk[2]); cv.px(x + r - 1, y + 7, sk[0])
    cv.row(y + 8, x + 1, x + r - 1, sk[1]); cv.px(x + r - 1, y + 8, sk[0])
    cv.row(y + 9, x + 2, x + r - 2, sk[0]); cv.row(y + 9, x + 3, x + r - 3, sk[0])
    lx, rx = x + 2, x + r - 2
    if eyes == "open":
        for ex in (lx, rx):
            cv.px(ex, y + 6, EYE); cv.px(ex, y + 7, EYE)
        cv.px(lx + 1, y + 6, WHITE_EYE); cv.px(rx - 1, y + 6, WHITE_EYE)
    elif eyes == "old":       # creased, half-lidded
        for ex in (lx, rx):
            cv.px(ex, y + 7, EYE)
        cv.px(lx + 1, y + 7, WHITE_EYE); cv.px(rx - 1, y + 7, WHITE_EYE)
        cv.row(y + 6, lx, lx + 1, sk[0]); cv.row(y + 6, rx - 1, rx, sk[0])
    elif eyes == "lash":      # a woman's eye: a lash flick at the outer corner
        for ex in (lx, rx):
            cv.px(ex, y + 6, EYE); cv.px(ex, y + 7, EYE)
        cv.px(lx + 1, y + 6, WHITE_EYE); cv.px(rx - 1, y + 6, WHITE_EYE)
        cv.px(lx - 1, y + 6, EYE); cv.px(rx + 1, y + 6, EYE)
    if brow is not None and eyes in ("open", "lash"):
        cv.row(y + 5, lx, lx + 1, brow); cv.row(y + 5, rx - 1, rx, brow)
    elif brow is not None and eyes == "old":
        cv.row(y + 5, lx - 1, lx + 1, brow); cv.row(y + 5, rx - 1, rx + 1, brow)
    mid = x + w // 2
    if mouth == "line":
        cv.px(mid - 1, y + 8, sk[0]); cv.px(mid, y + 8, sk[0])
    elif mouth == "smile":
        cv.px(mid - 2, y + 8, sk[0]); cv.px(mid - 1, y + 9, sk[0]); cv.px(mid, y + 9, sk[0]); cv.px(mid + 1, y + 8, sk[0])
        cv.px(mid - 1, y + 8, sk[1]); cv.px(mid, y + 8, sk[1])
    elif mouth == "lips":
        cv.px(mid - 1, y + 8, hexc("A8424A")); cv.px(mid, y + 8, hexc("7E2A36"))


def hair_cap(cv, x, y, h, w=10):
    """Hair rows 0-3 plus the temples on row 4, as the hero's head."""
    r = w - 1
    cv.row(y, x + 2, x + r - 2, h[1]); cv.row(y + 1, x + 1, x + r - 1, h[1])
    cv.row(y + 2, x, x + r, h[1]); cv.row(y + 3, x, x + r, h[1])
    cv.row(y, x + 2, x + 4, h[2]); cv.row(y + 1, x + 1, x + 2, h[2]); cv.px(x, y + 2, h[2])
    cv.px(x + r, y + 3, h[0]); cv.px(x + r, y + 2, h[0])
    cv.row(y + 4, x, x + 1, h[0]); cv.row(y + 4, x + r - 1, x + r, h[0])


def sanggul(cv, x, y):
    """A low Javanese/Sundanese sanggul: seen from the front it shows as a round knot either side of the nape,
    with a glossy band across the crown."""
    for sx, c in ((x - 2, (HAIR[2], HAIR[1], HAIR[1])), (x + 10, (HAIR[1], HAIR[1], HAIR[0]))):
        cv.rect(sx, y + 6, sx + 1, y + 9, HAIR[1]); cv.px(sx, y + 6, c[0]); cv.px(sx + 1, y + 9, c[2])
        cv.px(sx, y + 9, HAIR[0]) if sx > x else cv.px(sx + 1, y + 6, HAIR[1])
    cv.row(y + 1, x + 2, x + 6, HAIR[2]); cv.row(y, x + 3, x + 5, HAIR[2]); cv.px(x + 7, y + 1, HAIR[1])


def arm(cv, x0, y0, x1, y1, sleeve, cloth, skin=SKIN, inner=1):
    """A 2 px arm from the shoulder to the hand: `sleeve` cloth pixels, then skin; the hand a lit knuckle."""
    n = int(max(abs(x1 - x0), abs(y1 - y0)))
    for i in range(n + 1):
        t = i / n if n else 0.0
        xx, yy = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
        m = cloth if i < sleeve else skin
        a, b = (m[2], m[1]) if inner > 0 else (m[1], m[0])
        cv.px(xx, yy, a)
        cv.px(xx + 1, yy, b)
    cv.px(x1, y1 + 1, skin[1]); cv.px(x1 + 1, y1 + 1, skin[0])


def pangsi(cv, low, sk, hip=22, xl=12, xr=19, cuff=27, ground=GROUND, gap=True):
    """Loose pangsi trousers: two 4 px legs to `cuff`, bare ankles and feet."""
    for lx in (xl, xr - 3):
        for y in range(hip, cuff + 1):
            cv.row(y, lx, lx + 3, low[1])
            cv.px(lx, y, low[2]); cv.px(lx + 3, y, low[0])
        cv.row(cuff, lx, lx + 3, low[0])
        cv.row(cuff + 1, lx + 1, lx + 2, sk[1]); cv.px(lx + 2, cuff + 1, sk[0])
    if gap:
        for y in range(hip + 2, cuff + 1):
            cv.px(xl + 4, y, low[0]); cv.px(xr - 4, y, low[0])
        cv.rect(xl + 4, hip + 3, xr - 4, cuff + 1, OUTLINE) if xr - xl > 8 else None
    feet(cv, sk, xl + 1, xr - 2, ground)


def feet(cv, sk, lx, rx, ground=GROUND):
    """Two bare feet on `ground`, toes out."""
    for fx, toe in ((lx, -1), (rx, 1)):
        cv.row(ground, fx - 1, fx + 1, sk[1]); cv.px(fx + 1, ground, sk[0])
        cv.px(fx + toe * 2, ground, sk[1] if toe < 0 else sk[0])
        cv.px(fx - 1 if toe < 0 else fx, ground, sk[2])


def kain(cv, low, x0, x1, y0, y1, motif=None, hem=None, flare=1):
    """A wrapped kain from the waist to y1, flaring toward the hem, with an optional dot/stripe motif."""
    for y in range(y0, y1 + 1):
        t = (y - y0) / max(1, y1 - y0)
        f = flare if t > 0.4 else 0
        a, b = x0 - f, x1 + f
        cv.row(y, a, b, low[1]); cv.px(a, y, low[2]); cv.px(b, y, low[0]); cv.px(b - 1, y, low[0]) if t > 0.6 else None
    wiru = x0 + (x1 - x0) // 2 + 1                     # front pleats (wiru)
    for y in range(y0 + 2, y1):
        cv.px(wiru, y, low[0]); cv.px(wiru + 1, y, low[2])
    if motif:
        for y in range(y0 + 2, y1 - 1, 2):
            for x in range(x0 + ((y // 2) % 2), x1, 3):
                if x not in (wiru, wiru + 1):
                    cv.px(x, y, motif)
    if hem:
        cv.row(y1, x0 - flare, x1 + flare, hem[1]); cv.px(x0 - flare, y1, hem[2]); cv.px(x1 + flare, y1, hem[0])


# ---------------------------------------------------------------- humans
def villager(f):
    """Farmer: brown woven caping, green kampret, brown pangsi, a pacul on the shoulder."""
    cv, b = Cv(), BOB[f]
    pangsi(cv, BROWN, SKIN)
    cv.block(12, 14 + b, 19, 22, TUNIC)                    # kampret, worn loose over the waist
    cv.row(14 + b, 11, 20, TUNIC[1]); cv.px(11, 14 + b, TUNIC[2]); cv.px(20, 14 + b, TUNIC[0])
    cv.px(15, 14 + b, SKIN[1]); cv.px(16, 14 + b, SKIN[0]); cv.px(15, 15 + b, SKIN[0])     # open neck
    for y in range(15, 22):
        cv.px(16, y + b, TUNIC[0])                         # the front opening
    cv.px(17, 17 + b, TUNIC[2]); cv.px(17, 19 + b, TUNIC[2])   # cloth knots
    cv.row(21 + b, 12, 19, BROWN[0]); cv.px(13, 21 + b, BROWN[1]); cv.px(14, 21 + b, BROWN[1])   # rope belt
    # pacul: the handle crosses the right shoulder, the iron blade hangs behind
    for i in range(14):
        cv.px(24 - i * 0.62, 9 + i + b, WOOD[2] if i % 4 else WOOD[1])
    cv.rect(24, 8 + b, 26, 10 + b, STEEL[1]); cv.px(24, 8 + b, STEEL[2]); cv.row(11 + b, 24, 26, STEEL[0]); cv.px(26, 9 + b, STEEL[0])
    arm(cv, 10, 15 + b, 10, 21 + b, 3, TUNIC)
    arm(cv, 20, 15 + b, 18, 19 + b, 3, TUNIC, inner=-1)    # hand up on the handle
    cv.px(18, 19 + b, SKIN[2]); cv.px(19, 19 + b, SKIN[1])
    hx, hy = 11, 4 + b
    hair_cap(cv, hx, hy, HAIR)
    face(cv, hx, hy, SKIN, brow=HAIR[0])
    # caping: a low brown cone, woven ticks, the shadow on the brow
    for r, a, c in ((-2, 4, 5), (-1, 2, 7), (0, 0, 9), (1, -2, 11), (2, -3, 12)):
        cv.row(hy + r, hx + a, hx + c, CAPING[1]); cv.px(hx + a, hy + r, CAPING[2]); cv.px(hx + c, hy + r, CAPING[0])
    cv.row(hy + 3, hx - 2, hx + 11, CAPING[0])
    for r, i in ((-1, 3), (0, 5), (1, 1), (1, 8), (2, 3), (2, 10), (0, 2)):
        cv.px(hx + i, hy + r, CAPING[2] if i < 5 else CAPING[0])
    cv.px(hx + 4, hy - 2, CAPING[2])
    cv.row(hy + 4, hx + 1, hx + 8, SKIN[0])
    return cv


def elder(f):
    """Elder: white hair and beard, brown iket, indigo batik baju, brown kain, stooped on a staff."""
    cv, b = Cv(), BOB[f]
    feet(cv, SKIN, 13, 18)
    cv.row(28, 12, 14, SKIN[1]); cv.row(28, 17, 19, SKIN[1]); cv.px(14, 28, SKIN[0]); cv.px(19, 28, SKIN[0])
    kain(cv, BROWN, 12, 19, 22, 27, motif=BROWN[2], hem=BROWN)
    # stooped torso: one row shorter, shoulders rounded up toward the head
    ty = 15 + b
    cv.block(12, ty, 19, 22, INDIGO)
    cv.row(ty, 11, 20, INDIGO[1]); cv.px(11, ty, INDIGO[2]); cv.px(20, ty, INDIGO[0])
    cv.row(ty - 1, 12, 19, INDIGO[1]); cv.px(12, ty - 1, INDIGO[2]); cv.px(19, ty - 1, INDIGO[0])
    for y in range(ty + 1, 21):                            # batik kawung dots
        for x in range(13 + (y % 2), 19, 2):
            if (x + y) % 4 == 0:
                cv.px(x, y, INDIGO[2])
    cv.row(21, 12, 19, GOLD[1]); cv.px(12, 21, GOLD[2]); cv.px(19, 21, GOLD[0]); cv.px(15, 21, GOLD[0])   # sash
    # staff in the right hand, planted beside the right foot, a brass knob
    for y in range(11 + b, GROUND + 1):
        cv.px(22, y, WOOD[1]); cv.px(23, y, WOOD[0])
    cv.px(22, 9 + b, GOLD[2]); cv.px(23, 9 + b, GOLD[1]); cv.px(22, 10 + b, GOLD[1]); cv.px(23, 10 + b, GOLD[0])
    arm(cv, 10, ty + 1, 11, 21, 4, INDIGO)
    arm(cv, 20, ty + 1, 21, 18 + b, 3, INDIGO, inner=-1)
    cv.rect(21, 17 + b, 22, 18 + b, SKIN[1]); cv.px(21, 17 + b, SKIN[2]); cv.px(23, 18 + b, SKIN[0])   # hand on the staff
    hx, hy = 11, 6 + b                                     # the head hangs one row lower and forward
    hair_cap(cv, hx, hy, WHITE)
    face(cv, hx, hy, SKIN, eyes="old", mouth=None, brow=WHITE[2])
    cv.row(hy + 4, hx, hx + 1, WHITE[1]); cv.row(hy + 4, hx + 8, hx + 9, WHITE[0])
    # beard and moustache
    cv.row(hy + 8, hx + 2, hx + 7, WHITE[1]); cv.row(hy + 8, hx + 3, hx + 4, WHITE[2])
    cv.row(hy + 9, hx + 2, hx + 7, WHITE[1]); cv.px(hx + 7, hy + 9, WHITE[0])
    cv.row(hy + 10, hx + 3, hx + 6, WHITE[1]); cv.px(hx + 6, hy + 10, WHITE[0])
    cv.row(hy + 11, hx + 4, hx + 5, WHITE[0])
    cv.px(hx + 4, hy + 8, SKIN[0]); cv.px(hx + 5, hy + 8, SKIN[0])
    cv.px(hx + 4, hy + 7, SKIN[2])                         # nose catches the light
    # brown iket over the crown, a knot at the front
    for r, a, c in ((0, 2, 7), (1, 1, 8), (2, 0, 9)):
        cv.row(hy + r, hx + a, hx + c, BROWN[1])
    cv.row(hy, hx + 2, hx + 4, BROWN[2]); cv.px(hx + 1, hy + 1, BROWN[2]); cv.row(hy + 2, hx, hx + 9, BROWN[0])
    cv.row(hy + 1, hx + 3, hx + 6, GOLD[0])
    cv.px(hx + 4, hy - 1, BROWN[1]); cv.px(hx + 5, hy - 1, BROWN[0])
    return cv


def woman(f):
    """Ibu: sanggul, maroon kebaya with gold trim, batik kain, a bakul on the hip in an ochre selendang."""
    cv, b = Cv(), BOB[f]
    feet(cv, SKIN, 13, 18)
    kain(cv, BROWN, 12, 19, 22, 27, motif=GOLD[0], hem=GOLD)
    ty = 14 + b
    cv.block(12, ty, 19, 22, MAROON)
    cv.row(ty, 11, 20, MAROON[1]); cv.px(11, ty, MAROON[2]); cv.px(20, ty, MAROON[0])
    # kebaya: a V neck with gold edging, a kutu baru panel, the hem flares over the kain
    cv.row(ty, 14, 17, SKIN[1]); cv.px(14, ty, SKIN[2]); cv.row(ty + 1, 15, 16, SKIN[0])
    for i in range(3):
        cv.px(13 + i, ty + i, GOLD[2]); cv.px(18 - i, ty + i, GOLD[1])
    cv.rect(15, ty + 2, 16, ty + 6, MAROON[2]); cv.px(16, ty + 3, GOLD[1]); cv.px(16, ty + 5, GOLD[1])
    cv.row(22, 11, 20, MAROON[0]); cv.px(11, 22, MAROON[1])
    # selendang from the right shoulder down across the body to the basket at the left hip
    for i in range(8):
        x, y = 19 - i, ty + i
        cv.px(x, y, SELENDANG[1]); cv.px(x - 1, y, SELENDANG[2]); cv.px(x, y + 1, SELENDANG[0])
    # bakul: a woven bamboo basket against the left hip
    bx, by = 6, 18 + b
    cv.rect(bx, by, bx + 6, by + 5, BAMBOO[1])
    cv.row(by, bx - 1, bx + 7, BAMBOO[2]); cv.row(by + 5, bx + 1, bx + 5, BAMBOO[0])
    cv.px(bx - 1, by, BAMBOO[1]); cv.px(bx + 7, by, BAMBOO[0])
    for y in range(by + 1, by + 5):
        for x in range(bx, bx + 7):
            if (x + y) % 3 == 0:
                cv.px(x, y, BAMBOO[0])
        cv.px(bx + 6, y, BAMBOO[0])
    cv.row(by - 1, bx + 1, bx + 2, hexc("6A994E")); cv.px(bx + 3, by - 1, hexc("386641")); cv.px(bx + 4, by - 2, hexc("6A994E"))
    arm(cv, 10, ty + 1, 10, 19 + b, 3, MAROON)             # left hand steadies the basket rim
    cv.px(10, by + 1, SKIN[1]); cv.px(11, by + 1, SKIN[0])
    arm(cv, 20, ty + 1, 20, 21 + b, 3, MAROON, inner=-1)
    hx, hy = 11, 4 + b
    hair_cap(cv, hx, hy, HAIR)
    face(cv, hx, hy, SKIN, eyes="lash", mouth="lips", brow=HAIR[1])
    cv.rect(hx, hy + 4, hx, hy + 7, HAIR[1]); cv.rect(hx + 9, hy + 4, hx + 9, hy + 7, HAIR[0])   # hair framing
    cv.row(hy + 1, hx + 4, hx + 5, HAIR[0])                # centre parting
    # sanggul: a round bun on the crown, a gold tusuk konde
    sanggul(cv, hx, hy)
    cv.px(hx + 11, hy + 7, GOLD[2]); cv.px(hx + 12, hy + 6, GOLD[1])                   # tusuk konde
    return cv


def royal(f):
    """Royal: gold makuta with a red stone, sumping wings at the ears, maroon baju with gold, blue batik kain."""
    cv, b = Cv(), BOB[f]
    feet(cv, SKIN, 13, 18)
    kain(cv, ROYAL, 12, 19, 22, 27, motif=GOLD[1], hem=GOLD, flare=1)
    cv.rect(11, 27, 20, 27, GOLD[1]); cv.px(11, 27, GOLD[2]); cv.px(20, 27, GOLD[0])
    ty = 14 + b
    cv.block(12, ty, 19, 22, MAROON)
    cv.row(ty, 11, 20, MAROON[1]); cv.px(11, ty, MAROON[2]); cv.px(20, ty, MAROON[0])
    # gold kalung collar across the shoulders, a pendant, a gold belt with a buckle
    cv.row(ty, 12, 19, GOLD[1]); cv.row(ty + 1, 13, 18, GOLD[0]); cv.row(ty, 12, 14, GOLD[2])
    cv.row(ty + 1, 14, 17, SKIN[0]); cv.px(15, ty + 2, GOLD[1]); cv.px(16, ty + 2, GOLD[0]); cv.px(15, ty + 3, hexc("E8483C"))
    cv.row(21, 12, 19, GOLD[1]); cv.px(12, 21, GOLD[2]); cv.px(19, 21, GOLD[0])
    cv.rect(15, 20, 16, 21, GOLD[2]); cv.px(16, 21, GOLD[0])
    arm(cv, 10, ty + 1, 10, 21 + b, 3, MAROON)             # arms at rest, bare below the elbow
    arm(cv, 20, ty + 1, 20, 21 + b, 3, MAROON, inner=-1)
    for sx in (10, 20):                                    # kelat bahu armbands and gold bracelets
        cv.px(sx, ty + 3, GOLD[2]); cv.px(sx + 1, ty + 3, GOLD[0])
        cv.px(sx, 20 + b, GOLD[1]); cv.px(sx + 1, 20 + b, GOLD[0])
    hx, hy = 11, 4 + b
    hair_cap(cv, hx, hy, HAIR)
    face(cv, hx, hy, SKIN, brow=HAIR[0])
    # makuta: a gold band, three jagged points, a red stone; hair falls behind the ears
    cv.row(hy + 2, hx, hx + 9, GOLD[1]); cv.row(hy + 3, hx, hx + 9, GOLD[0]); cv.px(hx, hy + 2, GOLD[2])
    cv.row(hy + 1, hx + 1, hx + 8, GOLD[1]); cv.row(hy + 1, hx + 1, hx + 3, GOLD[2])
    for i, top in ((1, -1), (4, -3), (5, -3), (8, -1)):
        for r in range(top, 1):
            cv.px(hx + i, hy + r, GOLD[1] if i < 5 else GOLD[0])
    cv.row(hy, hx + 2, hx + 7, GOLD[1]); cv.px(hx + 4, hy - 3, GOLD[2]); cv.px(hx + 1, hy - 1, GOLD[2])
    cv.px(hx + 4, hy + 1, hexc("E8483C")); cv.px(hx + 5, hy + 1, hexc("A82A26"))
    # sumping: gold wings curling up from the ears
    for side, ex in ((-1, hx - 1), (1, hx + 10)):
        cv.px(ex, hy + 4, GOLD[1]); cv.px(ex, hy + 5, GOLD[0])
        cv.px(ex + side, hy + 3, GOLD[1]); cv.px(ex + side, hy + 2, GOLD[2] if side < 0 else GOLD[1])
        cv.px(ex + side, hy + 4, GOLD[0])
    return cv


def semar(f):
    """Semar: short and round, white kuncung tuft, droopy kind eyes, bare round belly, poleng kain, a pointing hand."""
    cv, b = Cv(), BOB[f]
    # short dark legs under the poleng
    for lx in (12, 17):
        cv.rect(lx, 26, lx + 2, 28, DARK[1]); cv.px(lx, 26, DARK[2]); cv.rect(lx + 2, 26, lx + 2, 28, DARK[0])
    feet(cv, SKIN, 12, 19)
    # the belly and chest: one big lit ball under the head
    cv.shaded_disc(16, 20 + b, 7.2, SKIN, 5.2)
    cv.px(12, 19 + b, SKIN[2]); cv.px(13, 20 + b, SKIN[2]); cv.px(12, 18 + b, SKIN[2])          # belly shine
    cv.px(17, 22 + b, SKIN[0]); cv.px(18, 22 + b, SKIN[0])                                        # navel crease
    # poleng kain: black and white squares wrapped under the belly, a red sabuk on top
    for y in range(23, 27):
        for x in range(9, 24):
            c = WHITE[1] if ((x - 9) // 2 + (y - 23) // 2) % 2 == 0 else DARK[1]
            if x == 9:
                c = WHITE[2] if c == WHITE[1] else DARK[2]
            elif x == 23:
                c = WHITE[0] if c == WHITE[1] else DARK[0]
            cv.px(x, y, c)
    cv.row(26, 10, 22, DARK[0])
    cv.row(23, 9, 23, hexc("C23A2E")); cv.px(9, 23, hexc("E8604A")); cv.row(23, 21, 23, hexc("8E2620"))
    # arms: left hand rests on the belly, right hand raised, the index finger up (the teaching gesture)
    arm(cv, 8, 17 + b, 9, 21 + b, 0, SKIN)
    cv.px(10, 22 + b, SKIN[1]); cv.px(11, 22 + b, SKIN[0])
    arm(cv, 23, 17 + b, 24, 14 + b, 0, SKIN, inner=-1)
    cv.rect(24, 12 + b, 25, 14 + b, SKIN[1]); cv.px(25, 13 + b, SKIN[0]); cv.px(24, 12 + b, SKIN[2])
    cv.px(25, 10 + b, SKIN[2]); cv.px(25, 11 + b, SKIN[1])
    # head: wide, round, low on the shoulders
    hx, hy = 10, 8 + b
    w = 12
    for r, a, c in ((1, 2, 9), (2, 1, 10), (3, 0, 11)):
        cv.row(hy + r, hx + a, hx + c, SKIN[1])
    cv.row(hy + 1, hx + 2, hx + 5, SKIN[2]); cv.row(hy + 2, hx + 1, hx + 3, SKIN[2])
    face(cv, hx, hy, SKIN, eyes=None, mouth=None, w=w)
    cv.row(hy + 4, hx, hx + 1, SKIN[1]); cv.row(hy + 4, hx + 10, hx + 11, SKIN[0])
    for ex in (hx + 3, hx + 8):                            # mata rembes: heavy lids, a wet shine
        cv.row(hy + 5, ex - 1, ex, SKIN[0])
        cv.px(ex - 1, hy + 6, EYE); cv.px(ex, hy + 6, EYE); cv.px(ex, hy + 7, WHITE_EYE)
    cv.rect(hx + 5, hy + 6, hx + 6, hy + 8, SKIN[1]); cv.px(hx + 5, hy + 6, SKIN[2]); cv.px(hx + 6, hy + 8, SKIN[0])
    cv.px(hx + 7, hy + 8, SKIN[0]); cv.px(hx + 4, hy + 8, SKIN[0])                                # a big round nose
    cv.px(hx + 3, hy + 9, SKIN[0]); cv.row(hy + 9, hx + 4, hx + 7, hexc("7E2A36")); cv.px(hx + 8, hy + 9, SKIN[0])
    cv.row(hy + 10, hx + 3, hx + 8, SKIN[0])               # double chin, then a crease under it
    crease = mix(SKIN[0], OUTLINE, 0.7)
    cv.row(hy + 11, hx + 3, hx + 8, crease); cv.px(hx + 2, hy + 10, crease); cv.px(hx + 9, hy + 10, crease)
    cv.px(hx + 1, hy + 9, crease); cv.px(hx + 10, hy + 9, crease)
    cv.px(hx - 1, hy + 6, SKIN[1]); cv.px(hx - 1, hy + 7, SKIN[0]); cv.px(hx + 12, hy + 6, SKIN[0])   # ears
    cv.row(hy + 1, hx + 9, hx + 9, SKIN[0]); cv.px(hx + 10, hy + 2, SKIN[0])
    # kuncung: the white tuft curling forward on the bald crown
    cv.rect(hx + 4, hy - 2, hx + 7, hy, WHITE[1]); cv.row(hy - 2, hx + 4, hx + 5, WHITE[2])
    cv.px(hx + 3, hy - 1, WHITE[2]); cv.px(hx + 7, hy, WHITE[0]); cv.px(hx + 8, hy - 1, WHITE[0])
    cv.px(hx + 6, hy - 3, WHITE[1]); cv.px(hx + 5, hy - 3, WHITE[2]); cv.px(hx + 3, hy, WHITE[1])
    cv.px(hx + 2, hy + 1, WHITE[1])                        # the curl falls onto the brow
    return cv


def cepot(f):
    """Cepot: red face, dark iket with a brown band, a big toothy grin, stocky, hands on hips."""
    cv, b = Cv(), BOB[f]
    pangsi(cv, BROWN, RED, xl=11, xr=20, cuff=27)
    ty = 14 + b
    cv.block(11, ty, 20, 22, DARK)                         # wide dark kampret
    cv.row(ty, 10, 21, DARK[1]); cv.px(10, ty, DARK[2]); cv.px(21, ty, DARK[0])
    cv.row(ty, 14, 17, RED[1]); cv.row(ty + 1, 15, 16, RED[1]); cv.px(15, ty + 2, RED[0]); cv.px(14, ty, RED[2])   # red chest at the neck
    cv.row(21, 11, 20, hexc("C23A2E")); cv.px(11, 21, hexc("E8604A")); cv.px(20, 21, hexc("8E2620"))             # red sabuk
    cv.row(22, 11, 20, BROWN[1]); cv.px(11, 22, BROWN[2]); cv.px(20, 22, BROWN[0])
    cv.px(16, 21, GOLD[1]); cv.px(17, 21, GOLD[0])        # buckle
    # akimbo: elbows out, fists on the hips
    for sx, ex, hx_, s in ((9, 7, 10, 1), (21, 23, 21, -1)):
        cv.line(sx, ty + 1, ex, ty + 4, DARK[2] if s > 0 else DARK[0])
        cv.line(sx + 1, ty + 1, ex + 1, ty + 4, DARK[1])
        cv.line(ex, ty + 5, hx_, 20, RED[1]); cv.line(ex + 1, ty + 5, hx_ + 1, 20, RED[0] if s < 0 else RED[1])
        cv.px(ex, ty + 4, DARK[1] if s > 0 else DARK[0])
    cv.rect(10, 20, 11, 21, RED[1]); cv.px(10, 20, RED[2]); cv.rect(20, 20, 21, 21, RED[1]); cv.px(21, 21, RED[0])
    hx, hy = 10, 4 + b
    w = 11
    hair_cap(cv, hx, hy, HAIR, w)
    face(cv, hx, hy, RED, eyes=None, mouth=None, w=w)
    for ex in (hx + 2, hx + 7):                            # big round eyes, pupils toward the nose
        cv.px(ex, hy + 6, WHITE_EYE); cv.px(ex + 1, hy + 6, EYE); cv.px(ex, hy + 7, WHITE[1]); cv.px(ex + 1, hy + 7, EYE)
        cv.row(hy + 5, ex, ex + 1, RED[0])
    cv.px(hx + 5, hy + 6, RED[2]); cv.px(hx + 5, hy + 7, RED[1]); cv.px(hx + 6, hy + 7, RED[0])     # long nose
    cv.row(hy + 8, hx + 2, hx + 8, RED[0])                 # the grin, teeth showing
    cv.row(hy + 9, hx + 3, hx + 7, WHITE[2]); cv.px(hx + 7, hy + 9, WHITE[1]); cv.px(hx + 5, hy + 9, WHITE[1])
    cv.row(hy + 10, hx + 4, hx + 6, RED[0])
    cv.px(hx + 2, hy + 9, RED[0]); cv.px(hx + 8, hy + 9, RED[0])
    # iket: dark cloth, brown band, a pointed knot standing at the front-right
    cv.row(hy, hx + 2, hx + 8, DARK[1]); cv.row(hy + 1, hx + 1, hx + 9, DARK[1])
    cv.row(hy + 2, hx, hx + 10, BROWN[1]); cv.row(hy + 3, hx, hx + 10, DARK[0])
    cv.row(hy, hx + 2, hx + 4, DARK[2]); cv.px(hx + 1, hy + 1, DARK[2]); cv.px(hx, hy + 2, BROWN[2]); cv.px(hx + 10, hy + 2, BROWN[0])
    cv.row(hy - 1, hx + 4, hx + 6, DARK[1]); cv.px(hx + 4, hy - 1, DARK[2]); cv.px(hx + 5, hy - 2, DARK[1])   # front peak
    cv.rect(hx + 10, hy + 1, hx + 11, hy + 2, DARK[1]); cv.px(hx + 11, hy + 3, DARK[0]); cv.px(hx + 12, hy + 4, DARK[0])  # knot, tail
    cv.row(hy + 4, hx, hx + 1, HAIR[0]); cv.row(hy + 4, hx + 9, hx + 10, HAIR[0])
    return cv


def laras(f):
    """Laras: sanggul with a gold-hearted flower, teal kebaya with gold edging, batik kain, hands clasped."""
    cv, b = Cv(), BOB[f]
    feet(cv, SKIN, 13, 18)
    kain(cv, BROWN, 12, 19, 22, 27, motif=GOLD[1], hem=GOLD)
    ty = 14 + b
    cv.block(12, ty, 19, 22, TEAL)
    cv.row(ty, 11, 20, TEAL[1]); cv.px(11, ty, TEAL[2]); cv.px(20, ty, TEAL[0])
    cv.row(ty, 14, 17, SKIN[1]); cv.px(14, ty, SKIN[2]); cv.row(ty + 1, 15, 16, SKIN[0])
    for i in range(4):                                     # gold edging down both fronts
        cv.px(13 + min(i, 2), ty + i, GOLD[2]); cv.px(18 - min(i, 2), ty + i, GOLD[1])
    cv.rect(15, ty + 2, 16, ty + 6, GOLD[1]); cv.px(16, ty + 3, GOLD[0]); cv.px(15, ty + 5, GOLD[2])   # kutu baru panel
    cv.row(22, 11, 20, TEAL[0]); cv.row(22, 12, 19, GOLD[0]); cv.px(11, 22, TEAL[1])
    arm(cv, 10, ty + 1, 13, 20 + b, 3, TEAL)               # hands folded in front
    arm(cv, 20, ty + 1, 17, 20 + b, 3, TEAL, inner=-1)
    cv.row(21 + b, 14, 17, SKIN[1]); cv.px(14, 21 + b, SKIN[2]); cv.px(17, 21 + b, SKIN[0])
    hx, hy = 11, 4 + b
    hair_cap(cv, hx, hy, HAIR)
    face(cv, hx, hy, SKIN, eyes="lash", mouth="lips", brow=HAIR[1])
    cv.rect(hx, hy + 4, hx, hy + 8, HAIR[1]); cv.rect(hx + 9, hy + 4, hx + 9, hy + 8, HAIR[0])
    cv.row(hy + 1, hx + 3, hx + 4, HAIR[0])                # side parting
    sanggul(cv, hx, hy)
    # the flower: four cream petals round a gold heart, tucked at the right of the bun
    fx, fy = hx + 9, hy + 2
    for dx, dy, c in ((0, -1, WHITE[2]), (-1, 0, WHITE[2]), (1, 0, WHITE[1]), (0, 1, WHITE[1])):
        cv.px(fx + dx, fy + dy, c)
    cv.px(fx, fy, GOLD[2]); cv.px(fx + 1, fy + 1, GOLD[0])
    return cv


def smith(f):
    """Smith / official: upright, dark iket, moustache, dark pangsi, a leather apron, a hammer in the right hand."""
    cv, b = Cv(), BOB[f]
    pangsi(cv, DARK, SKIN)
    ty = 14 + b
    cv.block(12, ty, 19, 22, DARK)
    cv.row(ty, 11, 20, DARK[1]); cv.px(11, ty, DARK[2]); cv.px(20, ty, DARK[0])
    # leather apron on a neck strap, down past the knees
    cv.block(13, ty + 2, 18, 26, LEATHER)
    cv.row(ty + 2, 13, 18, LEATHER[2])
    cv.px(13, ty, LEATHER[0]); cv.px(13, ty + 1, LEATHER[0]); cv.px(18, ty, LEATHER[0]); cv.px(18, ty + 1, LEATHER[0])
    cv.row(26, 13, 18, LEATHER[0])
    cv.row(20 + b, 12, 19, GOLD[0]); cv.px(12, 20 + b, GOLD[1])            # belt over the apron
    cv.px(15, 23, LEATHER[0]); cv.px(16, 24, LEATHER[0]); cv.px(14, 18 + b, LEATHER[2])   # scorch and wear
    cv.row(ty, 14, 17, SKIN[1]); cv.px(14, ty, SKIN[2])
    arm(cv, 10, ty + 1, 10, 21 + b, 2, DARK)
    arm(cv, 20, ty + 1, 21, 21 + b, 2, DARK, inner=-1)
    # hammer: the handle drops from the right fist, the iron head at the knee
    cv.line(22, 22 + b, 22, 26, WOOD[1]); cv.line(23, 23 + b, 23, 26, WOOD[0])
    cv.rect(21, 26, 24, 27, STEEL[1]); cv.row(26, 21, 23, STEEL[2]); cv.row(27, 22, 24, STEEL[0])
    hx, hy = 11, 4 + b
    hair_cap(cv, hx, hy, HAIR)
    face(cv, hx, hy, SKIN, mouth=None, brow=HAIR[0])
    cv.row(hy + 8, hx + 3, hx + 6, HAIR[1]); cv.px(hx + 3, hy + 9, HAIR[1]); cv.px(hx + 6, hy + 9, HAIR[0])   # moustache
    cv.px(hx + 4, hy + 7, SKIN[2])
    # dark iket tied tight, the knot ends behind the right ear
    for r, a, c in ((0, 2, 7), (1, 1, 8), (2, 0, 9), (3, 0, 9)):
        cv.row(hy + r, hx + a, hx + c, DARK[1])
    cv.row(hy, hx + 2, hx + 4, DARK[2]); cv.px(hx + 1, hy + 1, DARK[2]); cv.row(hy + 3, hx, hx + 9, DARK[0])
    cv.row(hy + 2, hx + 3, hx + 6, DARK[2])
    cv.px(hx + 10, hy + 2, DARK[1]); cv.px(hx + 11, hy + 3, DARK[0]); cv.px(hx + 10, hy + 4, DARK[0])
    return cv


def stranger(f):
    """Masked stranger: taller than the hero, wide dark hat, a smooth blank mask, grey cloak to the ground, a staff."""
    cv, b = Cv(), BOB[f]
    # cloak hem sways one pixel on the out-breath
    sw = (0, 0, 1, 0)[f]
    for y in range(13 + b, GROUND):
        t = (y - 13) / 16
        a, c = 12 - int(t * 3), 19 + int(t * 3)
        if y > 25:
            a, c = a + sw, c + sw
        cv.row(y, a, c, CLOAK[1]); cv.px(a, y, CLOAK[2]); cv.px(c, y, CLOAK[0]); cv.px(c - 1, y, CLOAK[0])
        if y > 16:
            cv.px(15 + (1 if y > 25 else 0) * sw, y, CLOAK[0]); cv.px(16 + (1 if y > 25 else 0) * sw, y, CLOAK[2])
    cv.row(GROUND - 1, 10 + sw, 22 + sw, CLOAK[0])
    feet(cv, ramp("3A3040"), 13, 18)
    cv.rect(11, 12 + b, 20, 14 + b, CLOAK[1]); cv.row(12 + b, 11, 14, CLOAK[2]); cv.px(20, 13 + b, CLOAK[0])   # mantle
    # staff in the right hand, taller than the head
    for y in range(2, GROUND + 1):
        cv.px(23, y, WOOD[0] if y % 5 else WOOD[1])
    cv.px(22, 2, WOOD[1]); cv.px(23, 1, WOOD[1])
    cv.rect(21, 17 + b, 22, 18 + b, CLOAK[1]); cv.rect(22, 18 + b, 23, 19 + b, MASK[0])    # a gloved hand
    cv.px(22, 16 + b, CLOAK[0])
    hx, hy = 11, 3 + b
    # mask: tall and smooth, a faint brow ridge and nose line, no eyes
    cv.rect(hx + 1, hy + 2, hx + 8, hy + 9, MASK[1]); cv.row(hy + 10, hx + 2, hx + 7, MASK[1])
    cv.rect(hx + 1, hy + 2, hx + 2, hy + 8, MASK[2]); cv.rect(hx + 8, hy + 3, hx + 8, hy + 9, MASK[0])
    cv.row(hy + 10, hx + 5, hx + 7, MASK[0]); cv.row(hy + 11, hx + 3, hx + 6, MASK[0])
    for y in range(15, 23):                                # the left arm under the cloak
        cv.px(13, y + b, CLOAK[0])
    cv.row(hy + 5, hx + 3, hx + 6, MASK[0]); cv.px(hx + 5, hy + 6, MASK[2]); cv.px(hx + 5, hy + 7, MASK[0])
    # wide hat: flat crown, a brim wider than the shoulders
    for r, a, c in ((-1, 2, 7), (0, 1, 8), (1, 1, 8)):
        cv.row(hy + r, hx + a, hx + c, DARK[1])
    cv.row(hy - 1, hx + 2, hx + 4, DARK[2]); cv.row(hy + 1, hx + 1, hx + 8, hexc("6A4A30"))
    cv.row(hy + 2, hx - 3, hx + 12, DARK[1]); cv.row(hy + 3, hx - 2, hx + 11, DARK[0])
    cv.row(hy + 2, hx - 3, hx, DARK[2])
    cv.row(hy + 4, hx + 1, hx + 8, MASK[0])                # the brim's shadow on the mask
    return cv


def faceless(f):
    """Faceless deserter: a grey hood up, the face a smooth blank, grey wrap over a brown pangsi."""
    cv, b = Cv(), BOB[f]
    pangsi(cv, BROWN, SKIN)
    ty = 14 + b
    cv.block(12, ty, 19, 22, CLOAK)
    cv.row(ty, 11, 20, CLOAK[1]); cv.px(11, ty, CLOAK[2]); cv.px(20, ty, CLOAK[0])
    for i in range(7):                                     # the wrap crosses the chest
        cv.px(13 + i, ty + 1 + i, CLOAK[0])
    cv.row(22, 12, 19, BROWN[0])
    arm(cv, 10, ty + 1, 11, 21 + b, 5, CLOAK)
    arm(cv, 20, ty + 1, 20, 21 + b, 5, CLOAK, inner=-1)
    hx, hy = 11, 4 + b
    # hood: a rounded cowl that drapes onto the shoulders, folds down both sides
    for r, l, rr in ((-1, 3, 6), (0, 1, 8), (1, 0, 9), (2, -1, 10), (3, -1, 10), (4, -1, 10), (5, -1, 10), (6, -1, 10),
                     (7, -1, 10), (8, -1, 10), (9, -1, 10), (10, 0, 9), (11, 3, 6), (12, 4, 5)):
        cv.row(hy + r, hx + l, hx + rr, CLOAK[1])
        cv.px(hx + l, hy + r, CLOAK[2]); cv.px(hx + rr, hy + r, CLOAK[0])
    cv.row(hy - 1, hx + 3, hx + 4, CLOAK[2]); cv.row(hy, hx + 1, hx + 3, CLOAK[2])
    cv.rect(hx + 9, hy + 1, hx + 9, hy + 9, CLOAK[0])
    cv.row(hy + 11, hx + 3, hx + 6, CLOAK[0]); cv.row(hy + 10, hx + 7, hx + 9, CLOAK[0]); cv.px(hx + 1, hy + 10, CLOAK[2])
    cv.px(hx, hy + 9, CLOAK[0]); cv.px(hx + 4, hy + 12, CLOAK[1])
    # the blank: a smooth oval, the hood's shadow across its brow, no features at all
    for r, l, rr in ((2, 3, 6), (3, 2, 7), (4, 2, 7), (5, 2, 7), (6, 2, 7), (7, 2, 7), (8, 3, 6)):
        cv.row(hy + r, hx + l, hx + rr, MASK[1])
    cv.row(hy + 2, hx + 3, hx + 6, mix(CLOAK[0], OUTLINE, 0.5)); cv.row(hy + 3, hx + 2, hx + 7, CLOAK[0])
    cv.rect(hx + 2, hy + 4, hx + 2, hy + 7, MASK[2]); cv.rect(hx + 7, hy + 4, hx + 7, hy + 7, MASK[0])
    cv.row(hy + 8, hx + 3, hx + 6, MASK[0]); cv.px(hx + 3, hy + 4, MASK[2])
    return cv


# ---------------------------------------------------------------- creatures and props
def lutung(f):
    """Lutung: a dark sacred monkey squatting, grey-frosted crest, pale grey face, amber eyes, long arms on the knees,
    the long tail hanging behind and curling along the ground."""
    cv, b = Cv(), BOB[f]
    frost = ramp("7A7486", "4A4456", "A49EB0")
    # tail: down from the rump, along the ground, the tip curling up (it flicks on frame 2)
    tip = (0, 0, 1, 0)[f]
    for x, y in ((21, 24), (22, 25), (23, 26), (23, 27), (24, 28), (25, 28), (26, 28), (27, 27), (28, 26 - tip), (28, 25 - tip)):
        cv.px(x, y, FUR[1]); cv.px(x, y + 1, FUR[0])
    cv.px(28, 24 - tip, frost[1])
    # folded legs: knees high at the sides, feet flat on the ground
    for kx, s_ in ((11, -1), (21, 1)):
        cv.shaded_disc(kx, 24, 2.4, FUR, 2.6)
        cv.row(GROUND, kx - 2 + (1 if s_ > 0 else 0), kx + 1 + (1 if s_ > 0 else 0), FUR[0])
    cv.row(GROUND, 10, 12, frost[0]); cv.row(GROUND, 20, 22, frost[0])
    # body: a pear, frosted over the shoulders
    cv.shaded_disc(16, 22 + b * 0.5, 5.2, FUR, 6.2)
    cv.row(17 + b, 13, 19, frost[1]); cv.row(18 + b, 12, 13, frost[1]); cv.px(12, 19 + b, frost[2]); cv.px(13, 17 + b, frost[2])
    cv.row(25, 14, 18, FUR[0])                             # belly shadow between the knees
    # long arms down to the knees, pale hands
    cv.line(12, 18 + b, 10, 23, frost[1]); cv.line(13, 19 + b, 11, 23, FUR[2])
    cv.line(20, 18 + b, 22, 23, FUR[0]); cv.line(19, 19 + b, 21, 23, FUR[1])
    cv.row(23, 10, 11, frost[0]); cv.row(23, 21, 22, frost[0])
    # head with the pointed crest
    hx, hy = 16, 12 + b
    cv.shaded_disc(hx, hy, 4.2, FUR, 3.8)
    cv.row(hy - 5, hx - 2, hx + 1, frost[1]); cv.row(hy - 5, hx - 2, hx - 1, frost[2])          # fanned crest
    cv.row(hy - 4, hx - 3, hx + 2, frost[1]); cv.row(hy - 4, hx - 3, hx - 2, frost[2]); cv.px(hx + 2, hy - 4, frost[0])
    cv.row(hy - 3, hx - 3, hx - 1, frost[2]); cv.row(hy - 3, hx, hx + 2, frost[1])
    cv.px(hx - 5, hy, frost[0]); cv.px(hx + 5, hy, FUR[0])                         # ears
    face_c = ramp("8C8494", "5A5262", "B4ACB8")
    cv.row(hy - 1, hx - 3, hx + 3, FUR[0])                 # deep brow
    cv.row(hy, hx - 2, hx + 2, face_c[1]); cv.rect(hx - 2, hy + 1, hx + 2, hy + 2, face_c[1])
    cv.px(hx - 2, hy + 1, face_c[2]); cv.px(hx + 2, hy + 2, face_c[0]); cv.row(hy + 3, hx - 1, hx + 1, face_c[0])
    cv.px(hx - 1, hy, hexc("FFB43C")); cv.px(hx + 1, hy, hexc("E8862A"))
    cv.px(hx, hy + 1, face_c[0]); cv.px(hx, hy + 2, face_c[2])
    return cv


def prasasti(f):
    """Inscribed candi monolith: rounded top, chipped edges, moss at the base, an aksara inscription that glows."""
    cv = Cv()
    x0, x1, top = 9, 22, 7
    for y in range(top, GROUND + 1):
        if y == top:
            a, c = x0 + 3, x1 - 3
        elif y == top + 1:
            a, c = x0 + 1, x1 - 1
        else:
            a, c = x0, x1
        if y >= GROUND - 2:
            a, c = a - 1, c + 1
        cv.row(y, a, c, STONE[1]); cv.px(a, y, STONE[2]); cv.px(a + 1, y, STONE[2]); cv.px(c, y, STONE[0])
    cv.row(top, x0 + 3, x0 + 6, STONE[2]); cv.row(top + 1, x0 + 1, x0 + 3, STONE[2])
    cv.row(GROUND - 3, x0, x1, STONE[0]); cv.row(GROUND - 2, x0 - 1, x1 + 1, STONE[2]); cv.px(x1 + 1, GROUND - 2, STONE[0])
    cv.row(GROUND, x0 - 1, x1 + 1, STONE[0])
    # cracks and chips
    for x, y in ((20, 11), (20, 12), (21, 13), (11, 22), (12, 23)):
        cv.px(x, y, STONE[0])
    cv.px(x1, top + 4, (0, 0, 0, 0)); cv.p.pop((x1, top + 4), None)
    # moss on the plinth and creeping up the left
    for x, y, c in ((x0 - 1, 27, 1), (x0, 27, 2), (x0 + 1, 27, 1), (x0 + 2, 28, 0), (x0, 26, 1), (x0, 25, 2), (x1, 27, 0), (x1 - 1, 28, 1)):
        cv.px(x, y, MOSS[c])
    # inscription: three lines of aksara strokes in a recessed panel; the glow breathes over four frames
    lvl = (0, 1, 2, 1)[f]
    cv.rect(12, 10, 19, 23, STONE[0])
    cv.rect(12, 10, 19, 10, mix(STONE[0], OUTLINE, 0.4)); cv.rect(12, 11, 12, 23, mix(STONE[0], OUTLINE, 0.4))
    hot = (FLAME[1], FLAME[2], hexc("FFF4C0"))[lvl]
    warm = (FLAME[0], FLAME[1], FLAME[2])[lvl]
    glyphs = [                             # three lines of hooked aksara strokes, a gap between letters
        "xx..x.", "x..xx.", "x...x.",
        None,
        ".x.xx.", "xx..x.", ".x..xx",
        None,
        "xx.x..", ".x.xx.", ".x..x.",
    ]
    for i, g in enumerate(glyphs):
        if g:
            for j, ch in enumerate(g):
                if ch == "x":
                    cv.px(13 + j, 11 + i, hot if i % 4 == 0 else warm)
    for gx, gy in ((16, 15), (16, 19)):
        cv.glow(gx, gy, 5, GLOW, (0.25, 0.45, 0.7, 0.45)[f])
    return cv


def mechanism(f):
    """Carved wooden door in a post-and-lintel frame: gold-leaf kala curls on the lintel, panelled leaves, ring pulls."""
    cv = Cv()
    dark = ramp("5A3E28", "33231A", "7E5A3A")
    # posts and lintel
    for x0 in (7, 22):
        cv.rect(x0, 9, x0 + 2, GROUND, WOOD[1]); cv.rect(x0, 9, x0, GROUND, WOOD[2]); cv.rect(x0 + 2, 9, x0 + 2, GROUND, WOOD[0])
    cv.rect(6, 6, 25, 9, WOOD[1]); cv.row(6, 6, 25, WOOD[2]); cv.row(9, 7, 24, WOOD[0]); cv.px(25, 7, WOOD[0]); cv.px(25, 8, WOOD[0])
    cv.row(5, 8, 23, WOOD[1]); cv.row(5, 8, 13, WOOD[2]); cv.px(23, 5, WOOD[0])
    # gold-leaf carving on the lintel: curls either side of a central bud
    for x, y, c in ((10, 7, 2), (11, 8, 1), (12, 7, 1), (13, 8, 0), (15, 7, 2), (16, 7, 1), (15, 6, 2), (16, 8, 0),
                    (18, 8, 1), (19, 7, 1), (20, 8, 0), (21, 7, 0)):
        cv.px(x, y, GOLD[c])
    # door leaves: two panelled halves, a dark seam, a glint that walks across the gold on the loop
    for lx in (10, 16):
        cv.block(lx, 10, lx + 5, GROUND, dark)
        cv.rect(lx + 1, 12, lx + 4, 18, dark[2]); cv.rect(lx + 2, 13, lx + 3, 17, dark[1]); cv.rect(lx + 4, 12, lx + 4, 18, dark[0])
        cv.rect(lx + 1, 21, lx + 4, 27, dark[2]); cv.rect(lx + 2, 22, lx + 3, 26, dark[1]); cv.rect(lx + 4, 21, lx + 4, 27, dark[0])
        cv.row(19, lx, lx + 5, GOLD[0]); cv.px(lx + 1, 19, GOLD[1])
    cv.rect(15, 10, 16, GROUND, OUTLINE); cv.rect(16, 10, 16, GROUND, dark[0])
    cv.px(14, 19, GOLD[2]); cv.px(13, 20, GOLD[1]); cv.px(18, 19, GOLD[1]); cv.px(18, 20, GOLD[0])   # ring pulls
    cv.row(GROUND, 6, 25, WOOD[0])                         # threshold
    gx = (10, 13, 18, 21)[f]
    cv.px(gx, 19, hexc("FFF4C0"))
    return cv


def lamp(f):
    """Stone oncor: a stepped plinth, a fluted column, a bowl of oil and a flame that dances over four frames."""
    cv = Cv()
    # plinth
    cv.rect(10, 27, 21, GROUND, STONE[1]); cv.row(27, 10, 21, STONE[2]); cv.rect(21, 27, 21, GROUND, STONE[0]); cv.row(GROUND, 11, 21, STONE[0])
    cv.rect(12, 25, 19, 26, STONE[1]); cv.row(25, 12, 19, STONE[2]); cv.px(19, 26, STONE[0]); cv.px(12, 26, STONE[2])
    # column
    cv.rect(14, 15, 17, 24, STONE[1]); cv.rect(14, 15, 14, 24, STONE[2]); cv.rect(17, 15, 17, 24, STONE[0])
    cv.px(16, 17, STONE[0]); cv.px(16, 19, STONE[0]); cv.px(16, 21, STONE[0]); cv.px(16, 23, STONE[0])
    cv.row(18, 14, 17, STONE[0]); cv.px(14, 18, STONE[1])
    for x, y, c in ((13, 26, 1), (14, 26, 2), (18, 26, 0), (14, 24, 1)):
        cv.px(x, y, MOSS[c])
    # bowl: a wide lip lit on top by the flame
    cv.rect(11, 12, 20, 14, STONE[1]); cv.row(12, 11, 20, STONE[2]); cv.row(14, 12, 19, STONE[0]); cv.px(20, 13, STONE[0])
    cv.row(11, 12, 19, GOLD[0]); cv.row(11, 14, 17, GOLD[1])                               # oil, catching the light
    cv.row(12, 13, 18, mix(STONE[2], GLOW, 0.45))
    # flame: four shapes that loop (lean left, tall, lean right, tall)
    shapes = [
        [(-1, -7), (-1, -6), (0, -6), (-1, -5), (0, -5), (1, -5), (-1, -4), (0, -4), (1, -4), (-1, -3), (0, -3), (1, -3), (2, -3), (-2, -2), (-1, -2), (0, -2), (1, -2), (2, -2), (-1, -1), (0, -1), (1, -1), (2, -1)],
        [(0, -8), (0, -7), (1, -7), (0, -6), (1, -6), (-1, -5), (0, -5), (1, -5), (-1, -4), (0, -4), (1, -4), (2, -4), (-1, -3), (0, -3), (1, -3), (2, -3), (-1, -2), (0, -2), (1, -2), (2, -2), (-1, -1), (0, -1), (1, -1), (2, -1)],
        [(2, -7), (1, -6), (2, -6), (0, -5), (1, -5), (2, -5), (0, -4), (1, -4), (2, -4), (-1, -3), (0, -3), (1, -3), (2, -3), (-1, -2), (0, -2), (1, -2), (2, -2), (3, -2), (-1, -1), (0, -1), (1, -1), (2, -1)],
        [(1, -8), (0, -7), (1, -7), (0, -6), (1, -6), (-1, -5), (0, -5), (1, -5), (2, -5), (-1, -4), (0, -4), (1, -4), (2, -4), (-1, -3), (0, -3), (1, -3), (2, -3), (-1, -2), (0, -2), (1, -2), (2, -2), (-1, -1), (0, -1), (1, -1), (2, -1)],
    ][f]
    fx, fy = 15, 11
    pts = set(shapes)
    ys = [y for _, y in shapes]
    for x, y in shapes:
        inner = (x - 1, y) in pts and (x + 1, y) in pts and (x, y - 1) in pts
        c = FLAME[2] if inner and y > min(ys) + 2 else (FLAME[1] if y < -1 or inner else FLAME[0])
        if y <= min(ys) + 1:
            c = FLAME[0] if y == min(ys) else FLAME[1]
        cv.px(fx + x, fy + y, c, soft=True)
    cv.px(fx, fy - 2, hexc("FFF8E0"), soft=True); cv.px(fx + 1, fy - 2, hexc("FFF8E0"), soft=True)
    cv.glow(fx + 0.5, fy - 4, 6, GLOW, (0.55, 0.75, 0.55, 0.7)[f])
    return cv


DRAW = [villager, elder, woman, royal, semar, cepot, laras, smith, lutung, prasasti, mechanism, lamp, stranger, faceless]


def main():
    sh = Image.new("RGBA", (CW * 4, CH * ROWS), (0, 0, 0, 0))
    for r, fn in enumerate(DRAW):
        for c in range(4):
            sh.alpha_composite(fn(c).image(), (c * CW, r * CH))
    out = px.save(sh, "npcs.png")
    print("wrote", out, sh.size)


if __name__ == "__main__":
    main()
