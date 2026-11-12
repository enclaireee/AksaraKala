#!/usr/bin/env python3
"""Aksara Kala hero sprite sheets (v4, 2026-11-12 redesign). 32x32 cells, about 2.6 heads tall, 6 cols x 18 rows
(the contract player.gd reads):
 rows 0-2 idle (down, side, up), cols 0-3 | rows 3-5 walk (down, side, up), cols 0-5
 rows 6-8 attack hit 1-3, SIDE view (the game flips it for left), 6 frames each
 row 9 dodge, 6 frames: crouch, launch, tuck, roll, land, rise | row 10 hurt (cols 0-3) | row 11 death (cols 0-3)
 rows 12-14 attack hit 1-3, DOWN view | rows 15-17 attack hit 1-3, UP view
 Attack frames: 0 anticipation, 1 coil, 2 strike, 3 smear pose, 4 follow-through, 5 settle.
   melee: wind-up 0-1, active 2-3, recovery 4-5. Ranged (bow, sling, staff): wind-up 0-2, recovery 3-5.
The figure is a small rig, not ASCII: head, torso, limbs, lower cloth, headgear, back item and weapon are drawn per
view from a pose (bob, lean, crouch, leg offsets, hand positions, weapon angle), then outlined. One class is one
entry in CLASSES (materials) plus its branches in the part painters below.
Run: python3 tools/gen_hero_sprites.py
Outputs: assets/art/hero_<class>.png for base + the 8 classes, hero_shadow.png, tools/hero_preview.png
Needs PIL, or falls back to the stdlib shim tools/pilite.py.
"""
import math
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pilite
pilite.install()
from PIL import Image
import pixlib as px
from pixlib import hexc

COLS, ROWS = 6, 18
CW = CH = 32
GROUND = 29                      # the row the feet stand on
OUTLINE = (30, 18, 34, 255)
CLASS_IDS = ["base", "warrior", "archer", "rogue", "mage", "lancer", "herder", "dancer", "dalang"]


def mix(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3)) + (255,)


def ramp(h, dark=None, light=None):
    """(dark, mid, light): the dark leans to plum, the light to warm paper."""
    m = hexc(h)
    d = hexc(dark) if dark else mix(mix(m, (0, 0, 0, 255), 0.30), (58, 30, 78, 255), 0.22)
    l = hexc(light) if light else mix(m, (255, 240, 206, 255), 0.34)
    return (d, m, l)


SKIN = ramp("C07F4E", "8A4A34", "E4AC7A")
HAIR = ramp("2B2331", "17121C", "4F4359")
EYE = hexc("1B1018")
STEEL = ramp("AEB8BE", "6A7482", "F2F6F2")
GOLD = ramp("D0A244", "8E6426", "F8DE86")
WOOD = ramp("7A5230", "4C3020", "A87A48")

# materials per class: top (torso cloth), low (lower cloth), sash, gear (headgear), trim, plus extras
CLASSES = {
    "base": dict(top=ramp("C2A674"), low=ramp("5A4030"), sash=ramp("7A4A2A"), gear=ramp("D8C494"), trim=GOLD,
                 legs="pants", sleeve=3, weapon="knife"),
    # Hulubalang: red udeng, bare chest with a red selempang, red kain with a brass hem, round tameng on the back
    "warrior": dict(top=SKIN, low=ramp("A32C26"), sash=ramp("3A2620"), gear=ramp("C4382C"), trim=GOLD,
                    extra=ramp("8E2620"), legs="kain", sleeve=0, weapon="kelewang"),
    # Pamanah: brown iket with a front peak and a feather, green kampret, verdigris sash, bamboo quiver
    "archer": dict(top=ramp("2F6B52"), low=ramp("6A4A30"), sash=ramp("7FC2A0"), gear=ramp("A06E3C"), trim=GOLD,
                   extra=ramp("C2A054"), legs="pants", sleeve=6, weapon="bow"),
    # Pendekar: dark headwrap with long tails, black pangsi, wide red sabuk, kujang
    "rogue": dict(top=ramp("3A3644"), low=ramp("2E2A38"), sash=ramp("C23A2E"), gear=ramp("34303E"), trim=ramp("DCCBA4"),
                  extra=ramp("C23A2E"), legs="pants", sleeve=6, weapon="kujang"),
    # Wiku: topknot and sumping, cream robe, verdigris sash, lontar with teal light, ring staff
    "mage": dict(top=ramp("E6D4A6"), low=ramp("E6D4A6"), sash=ramp("3F8A72"), gear=GOLD, trim=GOLD,
                 extra=ramp("B08C54"), legs="robe", sleeve=6, weapon="staff"),
    # Prajurit: black kuluk with a brass band, red-and-white lurik jacket, white trousers under a short indigo wrap
    "lancer": dict(top=ramp("C63A30"), low=ramp("E8E0CC"), sash=ramp("2A2430"), gear=ramp("2E2834"), trim=GOLD,
                   extra=ramp("38487E"), legs="pants", sleeve=6, weapon="tombak"),
    # Pangangon: wide straw caping, sleeveless pale kutang, indigo sarong slung over one shoulder, short trousers, sling
    "herder": dict(top=ramp("E2D6B0"), low=ramp("8A6A44"), sash=ramp("6A4A2A"), gear=ramp("DDBB6A"), trim=ramp("E8DDB8"),
                   extra=ramp("3E5E8E"), legs="short", sleeve=0, weapon="sling"),
    # Penari Topeng: gold sobrah headdress with red tassels, mask worn at the temple, selendang, twin fans
    "dancer": dict(top=ramp("B8306A"), low=ramp("6E4A2E"), sash=GOLD, gear=GOLD, trim=GOLD,
                   extra=ramp("2FA79A"), legs="kain", sleeve=0, weapon="fans"),
    # Dalang: batik blangkon, indigo beskap with brass buttons, parang kain, gunungan staff
    "dalang": dict(top=ramp("2E3A66"), low=ramp("7A5432"), sash=ramp("A8763A"), gear=ramp("7A5432"), trim=GOLD,
                   extra=ramp("C23A2E"), legs="kain", sleeve=6, weapon="gunungan"),
}
FX = {"mage": hexc("7FF0DC"), "dalang": hexc("FFC860"), "archer": hexc("BFF5D8"), "herder": hexc("F4E8C8")}
RANGED = ("bow", "sling", "staff", "gunungan")


class Cv:
    """A sparse pixel canvas. `soft` pixels (glows) are not outlined."""

    def __init__(self):
        self.p = {}
        self.soft = set()

    def px(self, x, y, c, soft=False):
        k = (int(round(x)), int(round(y)))
        self.p[k] = c
        if soft:
            self.soft.add(k)
        else:
            self.soft.discard(k)

    def rect(self, x0, y0, x1, y1, c):
        for y in range(int(y0), int(y1) + 1):
            for x in range(int(x0), int(x1) + 1):
                self.px(x, y, c)

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

    def ray(self, hx, hy, ang, a, b, c, w=1, c2=None):
        """Pixels from distance a to b along ang (degrees, y down) from (hx, hy). w=2 adds a second row (c2)."""
        co, si = math.cos(math.radians(ang)), math.sin(math.radians(ang))
        d = float(a)
        while d <= b + 1e-6:
            x, y = hx + co * d, hy + si * d
            if w == 2:
                self.px(x - si, y + co, c2 or c)
            self.px(x, y, c)
            d += 0.5

    def disc(self, cx, cy, r, c, soft=False):
        for y in range(int(cy - r - 1), int(cy + r + 2)):
            for x in range(int(cx - r - 1), int(cx + r + 2)):
                if (x - cx) ** 2 + (y - cy) ** 2 <= r * r + 0.3:
                    self.px(x, y, c, soft)

    def glow(self, cx, cy, r, c):
        """A soft halo that never covers a solid pixel."""
        for y in range(int(cy - r - 1), int(cy + r + 2)):
            for x in range(int(cx - r - 1), int(cx + r + 2)):
                d = math.hypot(x - cx, y - cy)
                if d <= r + 0.2 and (x, y) not in self.p:
                    a = int(190 * (1.0 - d / (r + 1.0)))
                    self.px(x, y, c[:3] + (max(a, 40),), True)

    def merge(self, o, dx=0, dy=0):
        for (x, y), c in o.p.items():
            self.px(x + dx, y + dy, c, (x, y) in o.soft)

    def rot_fall(self):
        """Lay the figure on its back: head to the left, feet to the right."""
        o = Cv()
        for (x, y), c in self.p.items():
            o.px(y, CW - 1 - x, c, (x, y) in self.soft)
        return o

    def image(self):
        img = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
        solid = {k for k in self.p if k not in self.soft}
        for (x, y) in solid:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                k = (x + dx, y + dy)
                if k not in solid and 0 <= k[0] < CW and 0 <= k[1] < CH:
                    img.putpixel(k, OUTLINE)
        for (x, y), c in self.p.items():
            if 0 <= x < CW and 0 <= y < CH and ((x, y) in solid or img.getpixel((x, y))[3] == 0):
                img.putpixel((x, y), c)
        return img


def P(**kw):
    """A pose. Offsets are pixels; hands are absolute cell points or None for a hanging arm."""
    d = dict(bob=0, lean=0, crouch=0, head=(0, 0), legl=(0, 0), legr=(0, 0), hand_w=None, hand_o=None,
             wang=None, wstate=0, eyes="open", sway=0, wlayer="front", swing=0)
    d.update(kw)
    return d


# ---------------------------------------------------------------- weapons
def draw_weapon(cv, cid, hx, hy, ang, state=0, second=False):
    C = CLASSES[cid]
    kind = C["weapon"]
    co, si = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    fx = FX.get(cid, hexc("FFFFFF"))
    if kind == "knife":
        cv.ray(hx, hy, ang, 0, 1, WOOD[1])
        cv.ray(hx, hy, ang, 2, 6, STEEL[1])
        cv.ray(hx, hy, ang, 5, 6, STEEL[2])
    elif kind == "kelewang":
        cv.ray(hx, hy, ang, -1, 1, WOOD[0])
        cv.ray(hx, hy, ang, 2, 2, GOLD[1], 2, GOLD[2])
        cv.px(hx + co * 2 + si, hy + si * 2 - co, GOLD[0])
        cv.ray(hx, hy, ang, 3, 11, STEEL[1], 2, STEEL[2])
        cv.ray(hx, hy, ang, 3, 9, STEEL[0])
        cv.ray(hx, hy, ang, 10, 12, STEEL[2])
    elif kind == "kujang":
        cv.ray(hx, hy, ang, -1, 1, WOOD[1])
        cv.ray(hx, hy, ang, 2, 7, STEEL[1])
        cv.ray(hx, hy, ang, 3, 5, STEEL[2], 2, STEEL[0])
        cv.px(hx + co * 8 - si, hy + si * 8 + co, STEEL[2])
        cv.px(hx + co * 2, hy + si * 2, GOLD[1])
    elif kind == "tombak":
        a0, top = -8, 11
        cv.ray(hx, hy, ang, a0, top, WOOD[1])
        cv.ray(hx, hy, ang, a0, a0 + 1, GOLD[1])
        for s in (-1, 1):
            cv.px(hx + co * (top - 1) - si * s, hy + si * (top - 1) + co * s, C["top"][1])
        cv.px(hx + co * (top - 1), hy + si * (top - 1) + 1, C["top"][0])
        cv.px(hx + co * top, hy + si * top, GOLD[1])
        cv.ray(hx, hy, ang, top + 1, top + 5, STEEL[1])
        for s in (-1, 1):
            cv.px(hx + co * (top + 2) - si * s, hy + si * (top + 2) + co * s, STEEL[0] if s > 0 else STEEL[2])
        cv.ray(hx, hy, ang, top + 4, top + 5, STEEL[2])
    elif kind == "fans":
        rim = GOLD[2]
        if state == 0:                          # folded at rest
            cv.ray(hx, hy, ang, 1, 5, GOLD[1], 2, C["top"][1])
            cv.ray(hx, hy, ang, 6, 6, rim)
        for a in (range(-52, 53, 4) if state else ()):
            sec = (a + 52) // 21
            col = C["top"][1 if sec % 2 else 2] if sec != 2 else GOLD[1]
            cv.ray(hx, hy, ang + a, 1, 4, col)
            cv.ray(hx, hy, ang + a, 5, 5, rim if abs(a) < 50 else GOLD[0])
        cv.px(hx, hy, GOLD[0])
    elif kind in ("staff", "gunungan"):
        cv.ray(hx, hy, ang, -7, 8, WOOD[1])
        cv.ray(hx, hy, ang, -7, -6, WOOD[0])
        tx, ty = hx + co * 11, hy + si * 11
        if kind == "staff":
            for a in range(0, 360, 30):
                cv.px(tx + math.cos(math.radians(a)) * 2.2, ty + math.sin(math.radians(a)) * 2.2, GOLD[1])
            cv.px(tx - 1.6, ty - 1.6, GOLD[2])
            cv.px(tx, ty, fx)
            cv.px(hx + co * 8, hy + si * 8, GOLD[0])
        else:   # gunungan: a leaf-shaped kayon head, gold with a red heart
            for d, wdt in ((8, 1), (9, 2), (10, 2), (11, 2), (12, 1), (13, 1), (14, 0)):
                for s in range(-wdt, wdt + 1):
                    col = GOLD[1] if abs(s) < wdt or wdt == 0 else GOLD[0]
                    cv.px(hx + co * d - si * s, hy + si * d + co * s, col)
            cv.px(hx + co * 10, hy + si * 10, C["extra"][1])
            cv.px(hx + co * 11, hy + si * 11, C["extra"][1])
            cv.px(hx + co * 14, hy + si * 14, GOLD[2])
            cv.px(hx + co * 9 + si, hy + si * 9 - co, GOLD[2])
            tx, ty = hx + co * 11, hy + si * 11
        if state >= 1:
            cv.glow(tx, ty, 2.2 + state, fx)
        if state >= 3:
            cv.px(tx, ty, hexc("FFFFFF"))
    elif kind == "sling":
        cord = C["trim"][0]
        cv.ray(hx, hy, ang, 1, 6, cord)
        ex, ey = hx + co * 7, hy + si * 7
        cv.rect(round(ex) - 1, round(ey) - 1, round(ex), round(ey), WOOD[1])
        if state != 2:   # 2: the stone is away
            cv.px(round(ex), round(ey), STEEL[1])
            cv.px(round(ex) - 1, round(ey) - 1, STEEL[2])
    elif kind == "bow":
        # ang is the aim; the bow stands across it. state: 0 rest, 1 half draw, 2 full draw, 3 just loosed
        wood = C["extra"]
        tips = []
        for t in range(-7, 8):
            f = 3.0 * (1.0 - (t / 7.0) ** 2)
            x, y = hx + co * f - si * t, hy + si * f + co * t
            cv.px(x, y, wood[2] if abs(t) >= 6 else (wood[1] if t < 0 else wood[0]))
            if abs(t) == 7:
                tips.append((x, y))
        pull = {0: 0.0, 1: 3.0, 2: 5.0, 3: -1.0}[state]
        sx, sy = hx - co * pull, hy - si * pull
        string = hexc("EFE6C8")
        for tx_, ty_ in tips:
            cv.line(tx_, ty_, sx, sy, string)
        if state in (1, 2):
            cv.ray(sx, sy, ang, 0, pull + 6, WOOD[2])
            cv.ray(sx, sy, ang, pull + 6, pull + 7, STEEL[2])
            cv.px(sx, sy, hexc("F4F6F0"))
            if state == 2:
                cv.glow(hx + co * (pull + 3), hy + si * (pull + 3), 1.6, fx)
        cv.px(hx, hy, wood[0])


# ---------------------------------------------------------------- limbs
def limb(cv, x0, y0, x1, y1, sleeve, cloth, wide=2, skin=SKIN, inner=1):
    """A 2 px limb from (x0, y0) to (x1, y1): `sleeve` cloth pixels from the top, then skin."""
    n = int(max(abs(x1 - x0), abs(y1 - y0)))
    vert = abs(y1 - y0) >= abs(x1 - x0)
    for i in range(n + 1):
        t = i / n if n else 0.0
        x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
        m = cloth if i < sleeve else skin
        if vert:
            a, b = (m[2], m[0]) if inner > 0 else (m[0], m[1])
            cv.px(x, y, a if i < n else m[1])
            if wide == 2:
                cv.px(x + 1, y, b if i < n else m[1])
        else:
            cv.px(x, y, m[2])
            if wide == 2:
                cv.px(x, y + 1, m[0] if i < sleeve else m[1])


def leg(cv, hipx, hipy, footx, footy, C, style, fwd=1, far=False):
    """A 3 px leg from the hip to the foot (side and front views). `fwd` is the toe direction."""
    low = C["low"]
    cut = {"pants": 99, "short": 4}.get(style, 99)
    n = max(1, footy - hipy)
    for i in range(n):
        x = hipx + (footx - hipx) * i / n
        m = low if i < cut else SKIN
        if far:
            m = (m[0], m[0], m[1])
        y = hipy + i
        cv.px(x - 1, y, m[2])
        cv.px(x, y, m[1])
        cv.px(x + 1, y, m[0])
    sk = (SKIN[0], SKIN[0], SKIN[1]) if far else SKIN
    wrap = None
    if style == "pants":
        wrap = {"archer": C.get("extra"), "rogue": C["sash"], "lancer": C.get("extra")}.get(C.get("id"))
        if wrap is None:
            wrap = low
    if wrap is not None and n >= 3 and wrap is not low:
        for dx in (-1, 0, 1):
            cv.px(footx + dx, footy - 1, wrap[1] if dx < 1 else wrap[0])
    cv.px(footx - 1, footy, sk[1])
    cv.px(footx, footy, sk[1])
    cv.px(footx + 1, footy, sk[0])
    cv.px(footx + (2 if fwd > 0 else -2), footy, sk[2] if fwd < 0 else sk[1])


def skirt(cv, x0, x1, y0, y1, C, cid, sway=0, view="front"):
    """A long kain or robe from y0 to y1, flaring 1 px toward the hem."""
    low = C["low"]
    for y in range(y0, y1 + 1):
        t = (y - y0) / max(1, y1 - y0)
        fl = 1 if t > 0.35 else 0
        s = sway if t > 0.6 else 0
        a, b = x0 - fl + min(s, 0), x1 + fl + max(s, 0)
        for x in range(a, b + 1):
            c = low[1]
            if x == a:
                c = low[2]
            elif x >= b - (1 if view != "side" else 0):
                c = low[0]
            cv.px(x, y, c)
    mid = (x0 + x1) // 2
    if cid == "warrior":      # wiru pleats down the front, brass tumpal hem
        if view != "back":
            for y in range(y0 + 1, y1):
                cv.px(mid + (1 if view == "side" else 0), y, low[2])
                cv.px(mid + 1 + (1 if view == "side" else 0), y, low[0])
        for x in range(x0 - 1, x1 + 2):
            cv.px(x + (sway if sway else 0), y1, GOLD[1] if (x + y1) % 2 else GOLD[0])
    elif cid == "mage":       # a batik band above the hem and a front panel line
        for x in range(x0 - 1, x1 + 2):
            cv.px(x, y1 - 1, C["extra"][1])
            cv.px(x, y1, C["extra"][0] if x % 2 else C["extra"][1])
        if view == "front":
            for y in range(y0, y1 - 1):
                cv.px(mid + 1, y, low[0])
    elif cid == "dancer":     # batik dots and a gold hem; the selendang is drawn by the torso
        for y in range(y0 + 1, y1, 2):
            for x in range(x0 + (y // 2) % 2, x1 + 1, 3):
                cv.px(x, y, GOLD[1])
        for x in range(x0 - 1, x1 + 2):
            cv.px(x, y1, GOLD[1])
    elif cid == "dalang":     # parang: light diagonal bands
        for y in range(y0, y1 + 1):
            for x in range(x0 - 1, x1 + 2):
                if (x + y) % 5 == 0 and (x, y) in cv.p:
                    cv.px(x, y, low[2])
        for x in range(x0 - 1, x1 + 2):
            if (x, y1) in cv.p:
                cv.px(x, y1, low[0])


# ---------------------------------------------------------------- head
def head(cv, cid, view, x, y, eyes="open"):
    """A 10x10 head with its top-left at (x, y), then the class headgear."""
    C = CLASSES[cid]
    s, h = SKIN, HAIR

    def row(r, a, b, c):
        for i in range(a, b + 1):
            cv.px(x + i, y + r, c)
    if view == "front":
        row(0, 2, 7, h[1]); row(1, 1, 8, h[1]); row(2, 0, 9, h[1]); row(3, 0, 9, h[1])
        row(0, 2, 4, h[2]); row(1, 1, 2, h[2])
        row(4, 0, 9, h[0]); row(4, 2, 7, s[1]); row(4, 2, 3, s[2])
        row(5, 0, 9, s[1]); cv.px(x, y + 5, s[0]); cv.px(x + 9, y + 5, s[0]); row(5, 1, 3, s[2])
        row(6, 0, 9, s[1]); cv.px(x, y + 6, s[0]); cv.px(x + 9, y + 6, s[0]); cv.px(x + 1, y + 6, s[2])
        row(7, 1, 8, s[1]); cv.px(x + 1, y + 7, s[2]); cv.px(x + 8, y + 7, s[0])
        row(8, 1, 8, s[1]); cv.px(x + 8, y + 8, s[0]); cv.px(x + 1, y + 8, s[1])
        row(9, 3, 6, s[0])
        cv.px(x + 2, y + 9, s[0]); cv.px(x + 7, y + 9, s[0])
        if eyes == "open":
            for ex in (2, 7):
                cv.px(x + ex, y + 6, EYE); cv.px(x + ex, y + 7, EYE)
            cv.px(x + 3, y + 6, hexc("F6EEDC")); cv.px(x + 6, y + 6, hexc("F6EEDC"))
        else:
            row(7, 2, 3, EYE); row(7, 6, 7, EYE)
        cv.px(x + 4, y + 8, s[0]); cv.px(x + 5, y + 8, s[0])
    elif view == "side":      # faces right
        row(0, 2, 7, h[1]); row(1, 1, 8, h[1]); row(2, 0, 9, h[1]); row(3, 0, 9, h[1])
        row(0, 2, 4, h[2]); row(1, 1, 2, h[2])
        row(4, 0, 4, h[1]); row(4, 5, 9, s[1]); row(4, 5, 6, h[0])
        row(5, 0, 3, h[1]); row(5, 4, 9, s[1]); cv.px(x + 4, y + 5, s[0])
        row(6, 0, 3, h[0]); row(6, 4, 9, s[1]); cv.px(x + 4, y + 6, s[0])
        row(7, 1, 2, h[0]); row(7, 3, 10, s[1]); cv.px(x + 10, y + 7, s[2])
        row(8, 3, 9, s[1]); cv.px(x + 3, y + 8, s[0])
        row(9, 4, 8, s[0])
        row(5, 6, 8, s[2])
        if eyes == "open":
            cv.px(x + 7, y + 6, EYE); cv.px(x + 7, y + 7, EYE); cv.px(x + 8, y + 6, hexc("F6EEDC"))
        else:
            row(7, 7, 8, EYE)
        cv.px(x + 8, y + 8, s[0])
    else:                     # back
        row(0, 2, 7, h[1]); row(1, 1, 8, h[1])
        for r in range(2, 8):
            row(r, 0, 9, h[1]); cv.px(x, y + r, h[2]); cv.px(x + 9, y + r, h[0])
        row(0, 2, 4, h[2]); row(1, 1, 2, h[2]); row(3, 2, 5, h[2]); row(4, 1, 2, h[2]); cv.px(x + 6, y + 3, h[2])
        row(7, 0, 9, h[0]); row(8, 1, 8, h[0]); cv.px(x + 4, y + 8, h[1]); row(9, 3, 6, s[0])
    headgear(cv, cid, view, x, y, C)


def headgear(cv, cid, view, x, y, C):
    g, t = C["gear"], C["trim"]

    def row(r, a, b, c):
        for i in range(a, b + 1):
            cv.px(x + i, y + r, c)
    back = view == "back"
    if cid == "base":         # a plain cloth band
        row(3, 0, 9, g[1]); row(3, 0, 2, g[2]); cv.px(x + 9, y + 3, g[0])
    elif cid == "warrior":    # red udeng with a standing front knot and a tail
        row(0, 2, 7, g[1]); row(1, 1, 8, g[1]); row(2, 0, 9, g[1]); row(3, 0, 9, g[0])
        row(0, 2, 4, g[2]); row(1, 1, 3, g[2]); cv.px(x, y + 2, g[2])
        row(3, 3, 6, GOLD[1])
        if view == "front":
            row(-1, 4, 5, g[1]); cv.px(x + 4, y - 2, g[2]); cv.px(x + 5, y - 1, g[0])
        elif view == "side":
            row(-1, 6, 7, g[1]); cv.px(x + 7, y - 2, g[2])
            cv.px(x - 1, y + 3, g[1]); cv.px(x - 1, y + 4, g[0]); cv.px(x - 2, y + 5, g[0])
        else:
            cv.px(x + 4, y + 4, g[1]); cv.px(x + 5, y + 4, g[0]); cv.px(x + 4, y + 5, g[0]); cv.px(x + 5, y + 6, g[0])
    elif cid == "archer":     # brown iket, one front peak, a pale feather
        row(1, 1, 8, g[1]); row(2, 0, 9, g[1]); row(3, 0, 9, g[0]); row(1, 1, 3, g[2]); cv.px(x, y + 2, g[2])
        row(2, 2, 7, C["sash"][0])
        if view == "front":
            row(0, 4, 5, g[1]); cv.px(x + 4, y - 1, g[2]); cv.px(x + 5, y, g[0])
            cv.px(x + 8, y, hexc("F4F0E0")); cv.px(x + 9, y - 1, hexc("F4F0E0")); cv.px(x + 9, y - 2, C["sash"][1])
        elif view == "side":
            row(0, 6, 8, g[1]); cv.px(x + 8, y - 1, g[2])
            cv.px(x + 2, y, hexc("F4F0E0")); cv.px(x + 1, y - 1, hexc("F4F0E0")); cv.px(x, y - 2, C["sash"][1])
        else:
            cv.px(x + 1, y, hexc("F4F0E0")); cv.px(x, y - 1, hexc("F4F0E0")); cv.px(x, y - 2, C["sash"][1])
            row(4, 4, 5, g[0])
    elif cid == "rogue":      # dark wrap to the brow with a pale edge and two long tails
        row(0, 2, 7, g[1]); row(1, 1, 8, g[1]); row(2, 0, 9, g[1]); row(3, 0, 9, g[1])
        row(0, 2, 4, g[2]); row(1, 1, 2, g[2]); cv.px(x, y + 2, g[2])
        if back:
            for r in range(4, 8):
                row(r, 0, 9, g[1]); cv.px(x + 9, y + r, g[0]); cv.px(x, y + r, g[2])
            row(8, 1, 8, g[0])
            for i in range(5):
                cv.px(x + 3, y + 8 + i, C["sash"][1]); cv.px(x + 6, y + 8 + i, C["sash"][0])
        else:
            row(4, 0, 9 if view == "front" else 5, t[1])
            if view == "front":
                cv.px(x, y + 4, g[0]); cv.px(x + 9, y + 4, g[0])
                for i in range(4):
                    cv.px(x + 10, y + 4 + i, C["sash"][1 if i < 2 else 0])
            else:
                for i in range(6):
                    cv.px(x - 1 - (i // 2), y + 4 + i, C["sash"][1]); cv.px(x - 2 - (i // 2), y + 5 + i, C["sash"][0])
    elif cid == "mage":       # topknot tied with gold, a thin brow band, sumping at the ears
        cx = {"front": 4, "side": 3, "back": 4}[view]
        row(-2, cx, cx + 1, HAIR[1]); row(-1, cx, cx + 1, GOLD[1]); cv.px(x + cx, y - 2, HAIR[2])
        row(-3, cx, cx + 1, HAIR[1]); cv.px(x + cx, y - 3, HAIR[2])
        if not back:
            row(3, 1 if view == "front" else 5, 8 if view == "front" else 9, GOLD[1])
        if view == "front":
            for ex in (0, 9):
                cv.px(x + ex, y + 4, GOLD[2]); cv.px(x + ex, y + 5, GOLD[1]); cv.px(x + ex, y + 6, GOLD[0])
        elif view == "side":
            cv.px(x + 4, y + 4, GOLD[2]); cv.px(x + 4, y + 5, GOLD[1]); cv.px(x + 3, y + 6, GOLD[0])
        else:
            for ex in (0, 9):
                cv.px(x + ex, y + 5, GOLD[1])
    elif cid == "lancer":     # tall black kuluk with a brass band and a red knob
        for r in range(-3, 4):
            row(r, 1, 8, g[1]); cv.px(x + 1, y + r, g[2]); cv.px(x + 8, y + r, g[0])
        row(-4, 2, 7, g[1]); cv.px(x + 2, y - 4, g[2])
        row(2, 1, 8, GOLD[1]); cv.px(x + 1, y + 2, GOLD[2]); cv.px(x + 8, y + 2, GOLD[0])
        row(3, 0, 9, g[0])
        row(-5, 4, 5, C["top"][1]); cv.px(x + 4, y - 5, C["top"][2])
        if view == "front":
            cv.px(x + 4, y, GOLD[1]); cv.px(x + 5, y, GOLD[0])
    elif cid == "herder":     # caping: a wide straw cone
        for r, a, b in ((-3, 4, 5), (-2, 3, 6), (-1, 1, 8), (0, -1, 10), (1, -3, 12), (2, -4, 13)):
            row(r, a, b, g[1])
            cv.px(x + a, y + r, g[2]); cv.px(x + a + 1, y + r, g[2]); cv.px(x + b, y + r, g[0])
        row(3, -3, 12, g[0])
        cv.px(x + 4, y - 3, g[2])
        for r, i in ((-1, 4), (0, 6), (1, 2), (1, 8), (2, 5), (0, 2), (2, 10)):
            cv.px(x + i, y + r, g[0])
        if not back:
            row(4, 1 if view == "front" else 5, 8 if view == "front" else 9, SKIN[0])
    elif cid == "dancer":     # gold sobrah: a jagged crown, red stones, tassels by the ears; a mask at the temple
        row(0, 1, 8, g[1]); row(1, 0, 9, g[1]); row(2, 0, 9, g[1]); row(3, 0, 9, g[0])
        row(0, 1, 3, g[2]); cv.px(x, y + 1, g[2])
        for i in (1, 4, 5, 8):
            cv.px(x + i, y - 1, g[1])
        cv.px(x + 4, y - 2, g[2]); cv.px(x + 5, y - 2, g[1])
        red = C["top"]
        if view == "front":
            cv.px(x + 4, y + 1, hexc("E8483C")); cv.px(x + 5, y + 1, hexc("A82A26"))
            for i in range(5):
                cv.px(x - 1, y + 3 + i, red[1 if i % 2 else 2]); cv.px(x + 10, y + 3 + i, red[0 if i % 2 else 1])
        elif view == "side":
            cv.px(x + 7, y + 1, hexc("E8483C"))
            for i in range(5):
                cv.px(x + 4, y + 4 + i, red[1 if i % 2 else 2])
            # the mask sits at the back of the temple, facing away
            cv.rect(x - 1, y + 2, x + 1, y + 6, hexc("F2ECE0")); cv.px(x - 1, y + 2, hexc("C8BFB0"))
            cv.px(x, y + 4, EYE); cv.px(x - 1, y + 6, hexc("C83A30")); cv.px(x + 1, y + 2, hexc("C83A30"))
        else:
            cv.rect(x + 3, y + 2, x + 6, y + 7, hexc("F2ECE0"))
            cv.px(x + 3, y + 2, hexc("C8BFB0")); cv.px(x + 6, y + 7, hexc("C8BFB0"))
            cv.px(x + 4, y + 4, EYE); cv.px(x + 5, y + 4, EYE); cv.px(x + 4, y + 6, hexc("C83A30")); cv.px(x + 5, y + 6, hexc("C83A30"))
            for i in range(4):
                cv.px(x - 1, y + 3 + i, red[1]); cv.px(x + 10, y + 3 + i, red[0])
    elif cid == "dalang":     # blangkon: smooth batik cap, a front fold, the mondolan knot behind
        row(0, 2, 7, g[1]); row(1, 1, 8, g[1]); row(2, 0, 9, g[1]); row(3, 0, 9, g[1])
        row(0, 2, 4, g[2]); row(1, 1, 2, g[2]); cv.px(x, y + 2, g[2])
        for r, i in ((1, 5), (2, 2), (2, 7), (3, 4)):
            cv.px(x + i, y + r, C["sash"][1])
        if view == "front":
            row(4, 0, 9, g[0]); row(4, 3, 6, SKIN[1])
            cv.px(x + 4, y + 3, g[0]); cv.px(x + 5, y + 3, g[0])
        elif view == "side":
            row(4, 0, 5, g[0])
            cv.rect(x - 1, y + 4, x, y + 6, g[1]); cv.px(x - 1, y + 4, g[2]); cv.px(x, y + 6, g[0])
        else:
            for r in range(4, 7):
                row(r, 0, 9, g[1]); cv.px(x + 9, y + r, g[0]); cv.px(x, y + r, g[2])
            row(7, 1, 8, g[0])
            cv.rect(x + 4, y + 5, x + 5, y + 7, g[1]); cv.px(x + 4, y + 5, g[2]); cv.px(x + 5, y + 7, g[0])


# ---------------------------------------------------------------- torso
def torso_front(cv, cid, x, y, back, sway=0):
    """An 8x8 torso with its top-left at (x, y), shoulders 1 px wider. Class dress on top."""
    C = CLASSES[cid]
    top, sash, s = C["top"], C["sash"], SKIN
    cv.block(x, y, x + 7, y + 7, top)
    cv.rect(x - 1, y, x + 8, y + 1, top[1]); cv.px(x - 1, y, top[2]); cv.px(x + 8, y, top[0]); cv.px(x + 8, y + 1, top[0])
    if not back and top is not SKIN:
        cv.px(x + 3, y, s[1]); cv.px(x + 4, y, s[0])
    if cid == "base":
        cv.rect(x, y + 6, x + 7, y + 7, sash[1]); cv.px(x + 7, y + 6, sash[0]); cv.px(x + 7, y + 7, sash[0])
        if not back:
            cv.px(x + 3, y + 1, s[0]); cv.px(x + 4, y + 2, top[0])
    elif cid == "warrior":
        cv.rect(x, y + 6, x + 7, y + 7, sash[1]); cv.px(x + 7, y + 6, sash[0]); cv.px(x, y + 6, sash[2])
        red = C["gear"]
        for i in range(8):                      # selempang, shoulder to hip
            xx = x + (i if not back else 7 - i)
            yy = y + int(i * 0.72)
            cv.px(xx, yy, red[1]); cv.px(xx, yy + 1, red[0])
        if back:                                # the tameng rides on the back
            cv.disc(x + 3.5, y + 3.5, 4.3, C["extra"][1])
            cv.disc(x + 3.5, y + 3.5, 3.3, C["gear"][1])
            cv.disc(x + 3.5, y + 3.5, 1.2, GOLD[1])
            cv.px(x + 2, y + 1, C["gear"][2]); cv.px(x + 1, y + 2, C["gear"][2]); cv.px(x + 3, y + 3, GOLD[2])
            cv.px(x + 6, y + 6, C["extra"][0]); cv.px(x + 5, y + 7, C["extra"][0])
        else:
            cv.px(x + 2, y + 3, s[0]); cv.px(x + 5, y + 3, s[0]); cv.px(x + 3, y + 5, s[0])
            cv.px(x + 3, y + 6, GOLD[1]); cv.px(x + 4, y + 6, GOLD[2]); cv.px(x + 3, y + 7, GOLD[0]); cv.px(x + 4, y + 7, GOLD[1])
            cv.px(x + 8, y + 2, C["extra"][1]); cv.px(x + 9, y + 3, C["extra"][0])   # shield rim behind the shoulder
    elif cid == "archer":
        cv.rect(x, y + 6, x + 7, y + 7, sash[1]); cv.px(x + 7, y + 6, sash[0]); cv.px(x, y + 6, sash[2]); cv.px(x + 7, y + 7, sash[0])
        for i in range(7):                      # quiver strap
            cv.px(x + (7 - i if not back else i), y + int(i * 0.8), C["gear"][1])
        if back:                                # bamboo quiver slung across the back, fletchings up
            for i in range(8):
                cv.px(x + 6 - i * 0.5, y - 1 + i, C["extra"][1]); cv.px(x + 7 - i * 0.5, y - 1 + i, C["extra"][0])
            for dx, c in ((6, "F4F0E0"), (7, "C8483C"), (8, "F4F0E0")):
                cv.px(x + dx, y - 2, hexc(c)); cv.px(x + dx, y - 3, hexc(c))
        else:
            for i in range(1, 6):
                cv.px(x + 4, y + i, top[0])
            cv.px(x + 3, y + 2, top[2]); cv.px(x + 3, y + 4, top[2])
            cv.px(x + 8, y - 1, hexc("F4F0E0")); cv.px(x + 9, y - 2, hexc("C8483C")); cv.px(x + 8, y - 2, C["extra"][1])
    elif cid == "rogue":
        cv.rect(x, y + 5, x + 7, y + 7, sash[1]); cv.rect(x, y + 5, x + 7, y + 5, sash[2]); cv.rect(x + 7, y + 5, x + 7, y + 7, sash[0])
        cv.rect(x, y + 7, x + 7, y + 7, sash[0])
        if not back:
            for i in range(4):                  # crossed lapel
                cv.px(x + 2 + i, y + 1 + i, C["trim"][0])
            cv.px(x + 1, y + 6, sash[2])
        tx = x - 1 if not back else x + 8       # the sabuk's knot and tails at the hip
        for i in range(6):
            cv.px(tx + (sway if i > 2 else 0), y + 6 + i, sash[1]); cv.px(tx - (1 if not back else -1) + (sway if i > 2 else 0), y + 7 + i, sash[0])
    elif cid == "mage":
        cv.rect(x, y + 6, x + 7, y + 7, sash[1]); cv.px(x + 7, y + 6, sash[0]); cv.px(x, y + 6, sash[2]); cv.rect(x, y + 7, x + 7, y + 7, sash[0])
        if not back:
            for i in range(5):                  # overlapped collar
                cv.px(x + 2 + i, y + 1 + i, top[0])
            cv.px(x + 5, y + 1, top[0]); cv.px(x + 4, y + 2, top[0])
            cv.rect(x + 8, y + 7, x + 9, y + 9, GOLD[1]); cv.px(x + 9, y + 9, GOLD[0])   # lontar at the hip
            cv.px(x + 8, y + 8, FX["mage"], True)
        else:
            cv.px(x + 3, y + 1, top[0]); cv.px(x + 4, y + 1, top[0])
    elif cid == "lancer":
        white = C["low"]
        for i in range(0, 8, 2):                # lurik: red and white stripes
            cv.rect(x + i + 1, y + 1, x + i + 1, y + 5, white[1 if i < 6 else 0])
        cv.rect(x, y + 6, x + 7, y + 7, sash[1]); cv.px(x, y + 6, sash[2])
        cv.rect(x - 1, y, x + 8, y, white[1]); cv.px(x + 8, y, white[0])
        if not back:
            cv.px(x + 3, y + 6, GOLD[1]); cv.px(x + 4, y + 6, GOLD[2]); cv.px(x + 3, y + 7, GOLD[0]); cv.px(x + 4, y + 7, GOLD[1])
            cv.px(x + 3, y, s[1]); cv.px(x + 4, y, s[0])
    elif cid == "herder":
        blue = C["extra"]
        for i in range(8):                      # sarong slung shoulder to hip, three wide
            xx = x + (7 - i if not back else i)
            yy = y + int(i * 0.8)
            cv.px(xx, yy - 1 if yy > y else yy, blue[2]); cv.px(xx, yy, blue[1]); cv.px(xx, yy + 1, blue[0])
            if i % 2:
                cv.px(xx, yy, C["trim"][1])
        cv.rect(x, y + 7, x + 7, y + 7, sash[1]); cv.px(x + 7, y + 7, sash[0])
        if not back:
            cv.px(x + 2, y + 3, s[0]); cv.px(x + 3, y + 5, s[0])
            cv.rect(x - 1, y + 6, x - 1, y + 9, C["gear"][1]); cv.px(x - 1, y + 6, C["gear"][2])   # suling at the belt
    elif cid == "dancer":
        s2, teal = SKIN, C["extra"]
        cv.rect(x - 1, y, x + 8, y + 1, s2[1]); cv.px(x - 1, y, s2[2]); cv.px(x + 8, y + 1, s2[0])
        cv.rect(x + 1, y, x + 6, y + 1, GOLD[1]); cv.px(x + 1, y, GOLD[2]); cv.px(x + 6, y + 1, GOLD[0])   # kace collar
        cv.px(x + 3, y + 1, hexc("E8483C")) if not back else None
        cv.rect(x, y + 6, x + 7, y + 7, GOLD[1]); cv.px(x, y + 6, GOLD[2]); cv.rect(x, y + 7, x + 7, y + 7, GOLD[0])
        if not back:
            cv.px(x + 3, y + 6, hexc("E8483C")); cv.px(x + 4, y + 6, hexc("A82A26"))
        for side, tx in ((-1, x - 1), (1, x + 8)):   # selendang ends hang from the hips
            for i in range(8):
                dx = (sway if i > 3 else 0) + (side if i > 5 else 0)
                cv.px(tx + dx, y + 6 + i, teal[2] if side < 0 else teal[1])
                cv.px(tx + dx + side, y + 7 + i, teal[0]) if i < 6 else None
    elif cid == "dalang":
        cv.rect(x, y + 6, x + 7, y + 7, sash[1]); cv.px(x + 7, y + 6, sash[0]); cv.px(x, y + 6, sash[2])
        for i in range(0, 8, 2):
            cv.px(x + i, y + 7, GOLD[1])
        if not back:
            cv.px(x + 2, y, hexc("F2ECE0")); cv.px(x + 5, y, hexc("F2ECE0"))
            for i in range(4):                  # the beskap closes on a slant with brass buttons
                cv.px(x + 3 + (i // 2), y + 1 + i, top[0])
                cv.px(x + 5 + (i // 3), y + 1 + i, GOLD[2 if i % 2 == 0 else 1]) if i < 4 else None
        else:                                   # keris tucked in the sash behind
            for i in range(5):
                cv.px(x + 2 + i, y + 7 - i, WOOD[1] if i < 3 else GOLD[1])
            cv.px(x + 6, y + 2, GOLD[2])


def torso_side(cv, cid, x, y, sway=0):
    """A 6x8 torso facing right, top-left at (x, y)."""
    C = CLASSES[cid]
    top, sash, s = C["top"], C["sash"], SKIN
    if cid == "warrior":      # shield edge-on behind the back
        cv.rect(x - 2, y, x - 1, y + 7, C["gear"][1]); cv.rect(x - 2, y + 1, x - 2, y + 6, C["extra"][0])
        cv.px(x - 1, y, GOLD[1]); cv.px(x - 1, y + 7, GOLD[0]); cv.px(x - 3, y + 3, GOLD[1]); cv.px(x - 3, y + 4, GOLD[0])
    elif cid == "archer":     # quiver behind the shoulder
        for i in range(8):
            cv.px(x - 2 + i * 0.25, y - 1 + i, C["extra"][1]); cv.px(x - 1 + i * 0.25, y - 1 + i, C["extra"][0])
        for dx, c in ((-3, "F4F0E0"), (-2, "C8483C"), (-1, "F4F0E0")):
            cv.px(x + dx, y - 2, hexc(c)); cv.px(x + dx, y - 3, hexc(c))
    elif cid == "dalang":     # keris hilt at the small of the back
        cv.px(x - 1, y + 5, WOOD[1]); cv.px(x - 2, y + 4, GOLD[1]); cv.px(x - 2, y + 3, GOLD[2])
    cv.block(x, y, x + 5, y + 7, top)
    cv.rect(x, y, x + 5, y, top[1]); cv.px(x, y, top[2])
    if top is not SKIN:
        cv.px(x + 4, y, s[0])
    band = (y + 6, y + 7)
    if cid == "rogue":
        band = (y + 5, y + 7)
    belt = GOLD if cid == "dancer" else sash
    cv.rect(x, band[0], x + 5, band[1], belt[1]); cv.rect(x, band[0], x, band[1], belt[2]); cv.rect(x, band[1], x + 5, band[1], belt[0])
    if cid == "warrior":
        red = C["gear"]
        for i in range(6):
            cv.px(x + i, y + int(i * 0.9), red[1]); cv.px(x + i, y + int(i * 0.9) + 1, red[0])
        cv.px(x + 4, y + 3, s[0])
    elif cid == "archer":
        for i in range(6):
            cv.px(x + 5 - i, y + int(i * 0.9), C["gear"][1])
    elif cid == "rogue":
        for i in range(6):
            cv.px(x - 1 - (i // 3) + sway, y + 6 + i, sash[1]); cv.px(x - 2 - (i // 3) + sway, y + 7 + i, sash[0])
        cv.px(x + 4, y + 2, C["trim"][0]); cv.px(x + 3, y + 3, C["trim"][0])
    elif cid == "mage":
        cv.px(x + 4, y + 1, top[0]); cv.px(x + 3, y + 2, top[0]); cv.px(x + 2, y + 3, top[0])
        cv.rect(x + 1, y + 7, x + 2, y + 9, GOLD[1]); cv.px(x + 2, y + 9, GOLD[0]); cv.px(x + 1, y + 8, FX["mage"], True)
    elif cid == "lancer":
        white = C["low"]
        for i in (1, 3, 5):
            cv.rect(x + i, y + 1, x + i, y + 5, white[1 if i < 5 else 0])
        cv.rect(x, y, x + 5, y, white[1])
        cv.px(x + 5, y + 6, GOLD[1])
    elif cid == "herder":
        blue = C["extra"]
        for i in range(6):
            yy = y + int(i * 1.0)
            cv.px(x + 5 - i, yy, blue[1]); cv.px(x + 5 - i, yy + 1, blue[0])
            if i % 2:
                cv.px(x + 5 - i, yy, C["trim"][1])
        cv.px(x + 4, y + 4, s[0])
    elif cid == "dancer":
        cv.rect(x, y, x + 5, y + 1, SKIN[1]); cv.rect(x + 1, y, x + 5, y + 1, GOLD[1]); cv.px(x + 1, y, GOLD[2]); cv.px(x + 5, y + 1, GOLD[0])
        teal = C["extra"]
        for i in range(8):
            dx = -(i // 3) + (sway if i > 3 else 0)
            cv.px(x - 1 + dx, y + 6 + i, teal[1]); cv.px(x - 2 + dx, y + 7 + i, teal[0]) if i < 7 else None
        cv.px(x + 5, y + 6, hexc("E8483C"))
    elif cid == "dalang":
        for i in range(4):
            cv.px(x + 4, y + 1 + i, GOLD[2 if i % 2 == 0 else 1]) if i % 2 == 0 else None
        cv.px(x + 5, y, hexc("F2ECE0"))
        for i in range(0, 6, 2):
            cv.px(x + i, y + 7, GOLD[1])
    elif cid == "base":
        cv.px(x + 4, y + 1, s[0])


# ---------------------------------------------------------------- whole figures
def figure_front(cid, p, back=False):
    """Down view, or the up view when back is set."""
    C = dict(CLASSES[cid], id=cid)
    cv = Cv()
    style = C["legs"]
    b, cr, ln = p["bob"], p["crouch"], p["lean"]
    ty = 14 + b + cr                      # torso top
    hipy = 22 + cr
    hx, hy = 11 + ln + p["head"][0], 4 + b + cr + p["head"][1]
    (ldx, ll), (rdx, rl) = p["legl"], p["legr"]
    spread = 1 if cr >= 2 else 0
    weapon = Cv()
    if p["wang"] is not None and p["hand_w"] is not None:
        draw_weapon(weapon, cid, p["hand_w"][0], p["hand_w"][1], p["wang"], p["wstate"])
        if C["weapon"] == "fans" and p["hand_o"] is not None:
            draw_weapon(weapon, cid, p["hand_o"][0], p["hand_o"][1], p.get("wang2", 180 - p["wang"]), p["wstate"], True)
    if p["wlayer"] == "back":
        cv.merge(weapon)
    # legs
    if style in ("pants", "short"):
        leg(cv, 13 - spread + ln, hipy, 13 + ldx - spread, GROUND - ll, C, style, -1)
        leg(cv, 18 + spread + ln, hipy, 18 + rdx + spread, GROUND - rl, C, style, 1)
        if cid == "lancer":               # short indigo wrap over the trousers
            ex = C["extra"]
            cv.block(12 + ln, hipy, 19 + ln, hipy + 2, ex)
            for i in range(12, 20, 2):
                cv.px(i + ln, hipy + 1, GOLD[1])
            cv.rect(12 + ln, hipy + 2, 19 + ln, hipy + 2, ex[0])
    else:
        hem = 27 if style == "kain" else 28
        for fx_, lift, toe in ((13 + ldx, ll, -1), (18 + rdx, rl, 1)):
            if lift < 2:
                fy = GROUND - lift
                cv.px(fx_ - 1, fy, SKIN[1]); cv.px(fx_, fy, SKIN[1]); cv.px(fx_ + 1, fy, SKIN[0]); cv.px(fx_ + toe * 2, fy, SKIN[1])
                if style == "kain":
                    cv.px(fx_ - 1, fy - 1, SKIN[1]); cv.px(fx_, fy - 1, SKIN[1]); cv.px(fx_ + 1, fy - 1, SKIN[0])
        skirt(cv, 12 + ln, 19 + ln, hipy, hem - (1 if cr >= 3 else 0), C, cid, p["sway"], "back" if back else "front")
    torso_front(cv, cid, 12 + ln, ty, back, p["sway"])
    # arms: screen-left arm at x 10-11, screen-right at x 20-21
    sl, sr = (10 + ln, ty + 1), (20 + ln, ty + 1)
    wside = "r" if back else "l"          # the weapon hand: screen-left facing down, screen-right facing up
    hands = {"l": None, "r": None}
    hands[wside] = p["hand_w"]
    hands["r" if wside == "l" else "l"] = p["hand_o"]
    sleeve = C["sleeve"]
    for side, sh in (("l", sl), ("r", sr)):
        h = hands[side]
        sw = p["swing"] * (1 if side == "l" else -1)
        if h is None:
            h = (sh[0], sh[1] + 6 + sw)
        limb(cv, sh[0], sh[1], h[0], h[1], sleeve, C["top"], 2, SKIN, 1 if side == "l" else -1)
        if cid == "warrior":
            cv.px(sh[0], sh[1] + 1, GOLD[2]); cv.px(sh[0] + 1, sh[1] + 1, GOLD[0])
        elif cid == "dancer":
            cv.px(sh[0], sh[1] + 1, GOLD[2]); cv.px(sh[0] + 1, sh[1] + 1, GOLD[0])
            cv.px(h[0], h[1] - 1, GOLD[1])
        elif cid == "herder" and not back and side == "r":
            pass
    head(cv, cid, "back" if back else "front", hx, hy, p["eyes"])
    if p["wlayer"] != "back":
        cv.merge(weapon)
        if p["hand_w"] is not None and p["wang"] is not None and C["weapon"] != "bow":
            cv.px(p["hand_w"][0], p["hand_w"][1], SKIN[2])
    return cv


def figure_side(cid, p):
    """Side view, facing right."""
    C = dict(CLASSES[cid], id=cid)
    cv = Cv()
    style = C["legs"]
    b, cr, ln = p["bob"], p["crouch"], p["lean"]
    ty = 14 + b + cr
    hipy = 22 + cr
    hx, hy = 11 + ln + p["head"][0], 4 + b + cr + p["head"][1]
    (ndx, nl), (fdx, fl) = p["legl"], p["legr"]      # near leg, far leg
    sh = (15 + ln, ty + 1)
    sleeve = C["sleeve"]
    far_cloth = (C["top"][0], C["top"][0], C["top"][1])
    far_skin = (SKIN[0], SKIN[0], SKIN[1])
    ho = p["hand_o"]
    if ho is None:
        ho = (sh[0] + 1 - p["swing"], sh[1] + 6)
    limb(cv, sh[0] + 1, sh[1], ho[0], ho[1], sleeve, far_cloth, 2, far_skin)
    weapon = Cv()
    if p["wang"] is not None and p["hand_w"] is not None:
        draw_weapon(weapon, cid, p["hand_w"][0], p["hand_w"][1], p["wang"], p["wstate"])
        if C["weapon"] == "fans":
            w2 = Cv()
            draw_weapon(w2, cid, ho[0], ho[1], p.get("wang2", p["wang"] + 40), p["wstate"], True)
            cv.merge(w2)
    if p["wlayer"] == "back":
        cv.merge(weapon)
    if style in ("pants", "short"):
        leg(cv, 15 + ln, hipy, 15 + fdx, GROUND - fl, C, style, 1, True)
        leg(cv, 16 + ln, hipy, 16 + ndx, GROUND - nl, C, style, 1)
        if cid == "lancer":
            ex = C["extra"]
            cv.block(13 + ln, hipy, 18 + ln, hipy + 2, ex)
            for i in range(13, 19, 2):
                cv.px(i + ln, hipy + 1, GOLD[1])
            cv.rect(13 + ln, hipy + 2, 18 + ln, hipy + 2, ex[0])
    else:
        hem = 27 if style == "kain" else 28
        for fx_, lift, far in ((15 + fdx, fl, True), (16 + ndx, nl, False)):
            if lift < 2:
                fy = GROUND - lift
                sk = far_skin if far else SKIN
                cv.px(fx_ - 1, fy, sk[1]); cv.px(fx_, fy, sk[1]); cv.px(fx_ + 1, fy, sk[1]); cv.px(fx_ + 2, fy, sk[2])
                if style == "kain":
                    cv.px(fx_ - 1, fy - 1, sk[1]); cv.px(fx_, fy - 1, sk[1]); cv.px(fx_ + 1, fy - 1, sk[0])
        stride = max(-2, min(2, (ndx - fdx) // 2))
        skirt(cv, 13 + ln + min(stride, 0), 18 + ln + max(stride, 0), hipy, hem - (1 if cr >= 3 else 0), C, cid, p["sway"], "side")
    torso_side(cv, cid, 13 + ln, ty, p["sway"])
    head(cv, cid, "side", hx, hy, p["eyes"])
    hw = p["hand_w"]
    if hw is None:
        hw = (sh[0] + p["swing"], sh[1] + 6)
    limb(cv, sh[0], sh[1], hw[0], hw[1], sleeve, C["top"])
    if cid in ("warrior", "dancer"):
        cv.px(sh[0], sh[1] + 1, GOLD[2]); cv.px(sh[0] + 1, sh[1] + 1, GOLD[0])
    if p["wlayer"] != "back":
        cv.merge(weapon)
        if p["hand_w"] is not None and p["wang"] is not None and C["weapon"] != "bow":
            cv.px(hw[0], hw[1], SKIN[2])
    return cv


def figure(cid, view, p):
    if view == "side":
        return figure_side(cid, p)
    return figure_front(cid, p, view == "up")


# ---------------------------------------------------------------- poses
def carry(cid, view, sw=0):
    """Where the weapon rests while idle or walking: (hand, angle, layer, off hand)."""
    kind = CLASSES[cid]["weapon"]
    if view == "side":
        hand = (15 + sw, 22)
        table = {"knife": (hand, 55, "front"), "kelewang": ((16 + sw, 22), 38, "front"), "kujang": (hand, 145, "front"),
                 "tombak": ((22, 20), -90, "front"), "fans": ((17 + sw, 22), 70, "front"),
                 "staff": ((22, 19), -90, "front"), "gunungan": ((22, 19), -90, "front"),
                 "sling": (hand, 90, "front"), "bow": ((19 + sw, 20), 0, "front")}
        h, a, l = table[kind]
        return h, a, l, None
    left = view == "down"
    hand = (10, 22 + sw) if left else (21, 22 + sw)
    out = 180 if left else 0               # pointing away from the body
    sgn = 1 if left else -1
    table = {"knife": (hand, out - sgn * 60, "front"), "kelewang": (hand, out - sgn * 48, "front"),
             "kujang": (hand, out - sgn * 50, "front"), "tombak": ((hand[0] - sgn * 3, 20), -90, "front"),
             "fans": (hand, out - sgn * 70, "front"), "staff": ((hand[0] - sgn * 3, 19), -90, "front"),
             "gunungan": ((hand[0] - sgn * 3, 19), -90, "front"), "sling": (hand, 90, "front"),
             "bow": ((hand[0] - sgn, 20), out, "front")}
    h, a, l = table[kind]
    off = None
    if kind == "fans":
        off = (21, 22 - sw) if left else (10, 22 - sw)
    if view == "up" and kind in ("kelewang", "knife", "kujang", "fans", "sling"):
        l = "front"
    return h, a, l, off


def idle_pose(cid, view, f):
    bob = (0, 0, 1, 1)[f]
    h, a, l, off = carry(cid, view)
    h = (h[0], h[1] + bob)
    if off:
        off = (off[0], off[1] + bob)
    kw = dict(bob=bob, hand_w=h, wang=a, wlayer=l, hand_o=off, sway=(0, 0, 0, 0)[f])
    if CLASSES[cid]["weapon"] == "fans":
        kw["wang2"] = 180 - a if view != "side" else a + 30
    return P(**kw)


def walk_pose(cid, view, f):
    if view == "side":
        ndx = (3, 2, 0, -3, -2, 0)[f]
        nl = (0, 0, 0, 0, 0, 2)[f]
        fl = (0, 0, 2, 0, 0, 0)[f]
        bob = (0, 0, -1, 0, 0, -1)[f]
        sw = (-2, -1, 0, 2, 1, 0)[f]
        h, a, l, off = carry(cid, view, sw if CLASSES[cid]["weapon"] not in ("tombak", "staff", "gunungan", "bow") else 0)
        h = (h[0], h[1] + bob)
        return P(bob=bob, legl=(ndx, nl), legr=(-ndx, fl), swing=sw, hand_w=h, wang=a, wlayer=l,
                 sway=(-1, 0, 0, 1, 0, 0)[f], wang2=a + 30)
    ll = (2, 1, 0, 0, 0, 0)[f]
    rl = (0, 0, 0, 2, 1, 0)[f]
    bob = (-1, 0, 0, -1, 0, 0)[f]
    sw = (1, 1, 0, -1, -1, 0)[f]
    h, a, l, off = carry(cid, view, sw if view == "down" else -sw)
    h = (h[0], h[1] + bob)
    if off:
        off = (off[0], off[1] + bob)
    kw = dict(bob=bob, legl=(0, ll), legr=(0, rl), swing=sw, hand_w=h, wang=a, wlayer=l, hand_o=off,
              sway=(1, 0, 0, -1, 0, 0)[f])
    if CLASSES[cid]["weapon"] == "fans":
        kw["wang2"] = 180 - a
    return P(**kw)


SWING1 = (-118, -142, -24, 42, 76, 40)       # forehand, degrees from the facing direction
SWING2 = (112, 138, 22, -44, -78, -38)       # backhand
SLAM = (-84, -104, -30, 56, 62, 42)          # overhead finisher
FACING = {"side": 0.0, "down": 90.0, "up": -90.0}


def attack_pose(cid, view, hit, f):
    kind = CLASSES[cid]["weapon"]
    F = FACING[view]
    if view == "side":
        sh = (16, 16)
    elif view == "down":
        sh = (11, 16)
    else:
        sh = (20, 16)
    fx, fy = math.cos(math.radians(F)), math.sin(math.radians(F))
    lean_seq = (-1, -1, 1, 2, 1, 0)
    kw = dict(wlayer="front")
    if view == "side":
        kw.update(lean=lean_seq[f], legl=((-1, -2, 3, 3, 2, 0)[f], 0), legr=((1, 1, -2, -2, -1, 0)[f], 0))
        sh = (sh[0] + lean_seq[f], sh[1])
    else:
        kw.update(bob=(0, -1, 1, 1, 0, 0)[f], legl=((0, -1, -1, -1, 0, 0)[f], 0), legr=((0, 1, 1, 1, 0, 0)[f], 0))
        sh = (sh[0], sh[1] + kw["bob"])
    if kind in RANGED:
        return ranged_pose(cid, view, hit, f, sh, F, kw)
    thrust = hit == 2 and kind in ("knife", "kujang", "tombak")
    if kind == "tombak" and hit < 2:            # the spear jabs on every hit; hits 1 and 2 are short
        thrust = True
    if thrust:
        reach = ((-3, -5, 4, 6, 3, 0) if hit == 2 else (-2, -3, 3, 4, 2, 0))[f]
        side_off = (0, 0, 0, 0, 0, 0)[f] + (1 if hit == 1 else 0)
        hand = (sh[0] + fx * (3 + reach) - fy * side_off, sh[1] + 3 + fy * (3 + reach) * 0.8)
        if view != "side":
            hand = (sh[0] + fx * reach, sh[1] + 3 + fy * (2 + reach))
        if kind == "tombak":                    # pulled far back, then driven out past the cell edge
            t = ((-4, -6, 3, 5, 3, 0) if hit == 2 else (-3, -4, 2, 3, 2, 0))[f]
            if view == "side":
                hand = (sh[0] + t, sh[1] + 3 + (1 if hit == 1 else 0))
            elif view == "down":
                hand = (sh[0] + 1, sh[1] - 2 + t)
            else:
                hand = (sh[0] + 1, sh[1] + 5 - t)
        ang = F + (0 if view == "side" else 0)
        kw.update(hand_w=hand, wang=ang, wstate=1 if kind == "tombak" else 0)
    else:
        seq = SLAM if (hit == 2 and kind == "kelewang") else (SWING1, SWING2, SWING1)[hit]
        rel = seq[f]
        if kind == "fans" and hit == 2:         # the finisher is a full spin: both fans wide
            rel = (-150, 170, 60, -30, -90, -40)[f]
        ang = F + rel if view != "down" else F - rel
        if view == "up":
            ang = F - rel
        r = 5.0
        hand = (sh[0] + math.cos(math.radians(ang)) * r, sh[1] + 1 + math.sin(math.radians(ang)) * r * 0.85)
        kw.update(hand_w=hand, wang=ang, wstate=1 if kind == "fans" else 0)
        if hit == 2 and kind == "kelewang":
            kw["bob"] = (0, -2, 1, 2, 1, 0)[f] if view != "side" else (-1, -2, 0, 1, 1, 0)[f]
            kw["crouch"] = (0, 0, 1, 2, 1, 0)[f]
    if view == "up":
        a = kw["wang"] % 360
        kw["wlayer"] = "back" if 180 < a < 360 else "front"
    # off hand: out for balance
    if kind == "fans":
        a2 = 2 * F - kw["wang"] + (24 if view == "side" else 0)
        osh = {"side": (17 + lean_seq[f], 16), "down": (20, 16 + kw.get("bob", 0)), "up": (11, 16 + kw.get("bob", 0))}[view]
        kw["hand_o"] = (osh[0] + math.cos(math.radians(a2)) * 5, osh[1] + 1 + math.sin(math.radians(a2)) * 4.2)
        kw["wang2"] = a2
    else:
        back = (-3, -4, -2, -3, -2, 0)[f]
        if view == "side":
            kw["hand_o"] = (sh[0] + 1 + back, sh[1] + 5 - (1 if f in (1, 3) else 0))
        else:
            ox = 20 if view == "down" else 11
            sgn = 1 if view == "down" else -1
            kw["hand_o"] = (ox + sgn * (1 if f in (2, 3) else 0), sh[1] + 5 - (1 if f in (2, 3) else 0))
    return P(**kw)


def ranged_pose(cid, view, hit, f, sh, F, kw):
    kind = CLASSES[cid]["weapon"]
    fx, fy = math.cos(math.radians(F)), math.sin(math.radians(F))
    big = hit == 2
    kw["lean"] = (0, -1, -1, 1, 0, 0)[f] if view == "side" else 0
    kw["legl"] = ((1, 2, 2, 2, 1, 0)[f], 0) if view == "side" else (0, 0)
    kw["legr"] = ((-1, -2, -2, -2, -1, 0)[f], 0) if view == "side" else (0, 0)
    if kind == "bow":
        state = (0, 1, 2, 3, 3, 0)[f]
        ext = (4, 6, 6, 6, 5, 4)[f]
        mid = (16, 17) if view != "side" else (16 + kw["lean"], 17)
        hand = (mid[0] + fx * ext, mid[1] + fy * ext * (0.9 if view != "side" else 1.0))
        if view == "up":
            hand = (16, 12 - (ext - 4))
        pull = {0: 0.0, 1: 3.0, 2: 5.0, 3: -1.0}[state]
        kw.update(hand_w=hand, wang=F, wstate=state, hand_o=(hand[0] - fx * max(pull, 0.0), hand[1] - fy * max(pull, 0.0)))
        if view == "up":
            kw["wlayer"] = "back"
        if big and f == 2:
            kw["lean"] = -2 if view == "side" else 0
    elif kind == "sling":
        spin = (200, 320, 80, 0, 20, 60)[f]
        raised = f < 3
        if view == "side":
            hand = (sh[0] + (0 if raised else 5), sh[1] - (5 if raised else 0))
        else:
            hand = (sh[0], sh[1] - 5) if raised else (sh[0] + fx * 2, sh[1] + 2 + fy * 4)
        ang = spin if raised else F + (0, 25, 70)[f - 3]
        kw.update(hand_w=hand, wang=ang, wstate=0 if raised else 2)
        if view == "up" and not raised:
            kw["wlayer"] = "back"
    else:   # staff, gunungan
        slam = big
        glow = (1, 2, 3, 3, 1, 0)[f]
        if slam:
            tilt = (-90, -90, -90, -90, -90, -90)[f]
            lift = (-2, -4, -5, 1, 1, 0)[f]
            hand = ({"side": 19, "down": 10, "up": 21}[view], 19 + lift)
            kw.update(hand_w=hand, wang=tilt, wstate=glow, crouch=(0, 0, 0, 1, 1, 0)[f])
        else:
            tilt = (-80, -70, -64, -14, -30, -60)[f] if hit == 0 else (-100, -112, -118, -28, -44, -70)[f]
            if view == "side":
                ang = tilt
                hand = (sh[0] + (2, 1, 1, 5, 4, 3)[f], sh[1] + (3, 2, 1, 3, 3, 4)[f])
            elif view == "down":
                ang = 180 - tilt if hit == 0 else tilt + 0
                ang = (-100, -110, -116, 104, 110, -100)[f]
                hand = (sh[0], sh[1] + (3, 2, 1, 5, 4, 4)[f])
            else:
                ang = (-80, -70, -64, -84, -80, -80)[f]
                hand = (sh[0], sh[1] + (3, 2, 1, -1, 1, 3)[f])
                if f == 3:
                    kw["wlayer"] = "back"
            kw.update(hand_w=hand, wang=ang, wstate=glow)
        if view == "side":
            kw["hand_o"] = (sh[0] + 3, sh[1] + (4, 2, 1, 4, 4, 5)[f])
    return P(**kw)


def ball(cid, f):
    """The tucked roll: a round bundle in the class colours."""
    C = CLASSES[cid]
    cv = Cv()
    cx, cy, r = 15.5, 23.0, 5.4
    for y in range(16, 30):
        for x in range(9, 23):
            if (x - cx) ** 2 + (y - cy) ** 2 <= r * r:
                a = math.degrees(math.atan2(y - cy, x - cx)) + f * 150
                a %= 360
                m = C["gear"] if a < 100 else (SKIN if a < 150 else (C["top"] if a < 260 else C["low"]))
                if m is SKIN and C["top"] is SKIN:
                    m = SKIN
                lit = 2 if (x - cx) + (y - cy) < -3 else (0 if (x - cx) + (y - cy) > 4 else 1)
                cv.px(x, y, m[lit])
    sash = C["sash"]
    for i in range(4):
        a = math.radians(200 + f * 150 + i * 14)
        cv.px(cx + math.cos(a) * (r + 1 + i * 0.6), cy + math.sin(a) * (r + 1 + i * 0.6), sash[1])
    return cv


def frames(cid):
    """All 18 rows as lists of 32x32 images."""
    rows = []
    for v in ("down", "side", "up"):
        rows.append([figure(cid, v, idle_pose(cid, v, f)).image() for f in range(4)])
    for v in ("down", "side", "up"):
        rows.append([figure(cid, v, walk_pose(cid, v, f)).image() for f in range(6)])
    for hit in range(3):
        rows.append([figure(cid, "side", attack_pose(cid, "side", hit, f)).image() for f in range(6)])
    # dodge
    h, a, l, off = carry(cid, "side")
    def side(**kw):
        d = dict(hand_w=h, wang=a, wlayer=l)
        d.update(kw)
        if d.get("hand_w") is not None:
            d["hand_w"] = (d["hand_w"][0] + d.get("lean", 0), d["hand_w"][1] + d.get("bob", 0) + d.get("crouch", 0))
        return figure(cid, "side", P(**d))
    dodge = [side(crouch=3, legl=(2, 0), legr=(-2, 0)).image(),
             side(crouch=2, lean=3, legl=(-3, 0), legr=(-1, 1), head=(1, 1)).image(),
             ball(cid, 0).image(), ball(cid, 1).image(),
             side(crouch=3, legl=(3, 0), legr=(-2, 0), head=(0, 1)).image(),
             side(crouch=1, legl=(1, 0), legr=(-1, 0)).image()]
    rows.append(dodge)
    sh = (15, 15)
    hurt = [side(lean=-2, eyes="shut", head=(-1, 0), legl=(2, 0), legr=(-1, 0), hand_w=(19, 13), hand_o=(11, 14), wang=-50).image(),
            side(lean=-1, eyes="shut", head=(-1, 0), legl=(1, 0), legr=(-1, 0), hand_w=(18, 15), wang=-20).image(),
            side(lean=-1, crouch=1, eyes="shut", legl=(1, 0), legr=(-1, 0)).image(),
            side(eyes="shut").image()]
    rows.append(hurt)
    lying = figure(cid, "side", P(eyes="shut", hand_w=(15, 22), hand_o=(17, 21))).rot_fall()
    down1, down2 = Cv(), Cv()
    down1.merge(lying, 0, 5)
    down2.merge(lying, 0, 8)
    death = [hurt[0], side(crouch=4, lean=-1, eyes="shut", head=(0, 2), legl=(3, 0), legr=(-2, 0), hand_w=(17, 20), wang=80).image(),
             down1.image(), down2.image()]
    rows.append(death)
    for v in ("down", "up"):
        for hit in range(3):
            rows.append([figure(cid, v, attack_pose(cid, v, hit, f)).image() for f in range(6)])
    return rows


def build_sheet(cid):
    sh = Image.new("RGBA", (CW * COLS, CH * ROWS), (0, 0, 0, 0))
    for r, row in enumerate(frames(cid)):
        for c in range(COLS):
            sh.paste(row[min(c, len(row) - 1)] if c < len(row) else row[c % len(row)], (c * CW, r * CH))
    return sh


def shadow():
    img = Image.new("RGBA", (20, 8), (0, 0, 0, 0))
    for y in range(8):
        for x in range(20):
            d = ((x - 9.5) / 9.5) ** 2 + ((y - 3.5) / 3.5) ** 2
            if d <= 1.0:
                img.putpixel((x, y), (20, 12, 26, 110 if d < 0.55 else 70))
    return img


def main():
    out = []
    for cid in CLASS_IDS:
        sh = build_sheet(cid)
        out.append((px.save(sh, "hero_%s.png" % cid), sh))
    px.save(shadow(), "hero_shadow.png")
    # preview: every class side by side, rows of the key poses
    W = CW * COLS
    prev = Image.new("RGBA", (W * 3 + 16, (CH * ROWS + 8) * 3), (64, 86, 66, 255))
    for i, (_, sh) in enumerate(out):
        prev.paste(sh, (8 + (i % 3) * (W + 4), 4 + (i // 3) * (CH * ROWS + 8)), sh)
    prev = prev.resize((prev.width * 3, prev.height * 3), Image.NEAREST)
    prev.save(os.path.join(os.path.dirname(os.path.abspath(__file__)), "hero_preview.png"))
    print("wrote %d hero sheets (%dx%d)" % (len(out), CW * COLS, CH * ROWS))


if __name__ == "__main__":
    main()
