#!/usr/bin/env python3
"""Enemy sprite sheets (batch B): 15 Budayago enemies drawn procedurally with pixlib.

Each creature is a function draw(pose, t) -> RGBA image on a fixed canvas (feet at the
bottom row, art faces RIGHT). poses: idle, walk, wind, strike. Output sheets are
4x4: idle / walk / telegraph (wind, wind, strike, strike) / hurt.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pixlib as P
from pixlib import hexc, ramp
from PIL import Image

OUT_DIR = "enemies"


class Cv:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        self.p = self.img.load()

    def px(self, x, y, c):
        x, y = int(round(x)), int(round(y))
        if 0 <= x < self.w and 0 <= y < self.h:
            self.p[x, y] = c

    def rect(self, x0, y0, x1, y1, c):
        for y in range(int(y0), int(y1) + 1):
            for x in range(int(x0), int(x1) + 1):
                self.px(x, y, c)

    def ell(self, cx, cy, rx, ry, c):
        for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
            for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
                if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1.0:
                    self.px(x, y, c)

    def line(self, x0, y0, x1, y1, c, th=1):
        n = int(round(max(abs(x1 - x0), abs(y1 - y0), 1)))
        for i in range(n + 1):
            x = x0 + (x1 - x0) * i / n
            y = y0 + (y1 - y0) * i / n
            for ox in range(th):
                for oy in range(th):
                    self.px(x + ox, y + oy, c)

    def shaded_ell(self, cx, cy, rx, ry, pal):
        """Ellipse with highlight top-left and shadow bottom-right."""
        hi, mid, shd, deep = pal
        self.ell(cx, cy, rx, ry, shd)
        self.ell(cx - 0.4, cy - 0.4, rx - 0.7, ry - 0.7, mid)
        self.ell(cx - rx * 0.35, cy - ry * 0.4, max(rx * 0.35, 0.8), max(ry * 0.3, 0.8), hi)


def eyes(cv, pts, c=(255, 255, 255, 255), pupil=None):
    for x, y in pts:
        cv.px(x, y, c)
        if pupil:
            cv.px(x + 1, y, pupil)


def zig(t, k=2):
    return [0, 1, 0, -1][(t + k) % 4]


def fin(cv):
    return P.outline(cv.img)


# ---------------------------------------------------------------- kemamang
def kemamang(pose, t):
    cv = Cv(18, 19)
    cy = P.hexc
    f = ramp(hexc("#22d3ee"))
    core = hexc("#e6ffff")
    dark = hexc("#06303d")
    bob = {"idle": [0, 1, 2, 1], "walk": [1, 2, 1, 2], "wind": [2, 1, 2, 1], "strike": [1, 1, 1, 1]}[pose][t % 4]
    hx = 7 + (2 if pose == "strike" else 0) - (1 if pose == "wind" else 0)
    hy = 7 - bob + (1 if pose == "wind" else 0)
    # trailing flame body (tail points down-left)
    for i, y in enumerate(range(hy + 3, 18)):
        wdt = max(1, 6 - i)
        sw = round(math.sin((i + t * 1.5) * 0.9) * 1.2) - i * 0.25
        x0 = hx - wdt // 2 + sw - (2 if pose == "strike" else 0)
        cv.rect(x0 - 0, y, x0 + wdt, y, f[1] if i % 3 else f[2])
    # head flame
    cv.shaded_ell(hx, hy, 4.5, 4.3, f)
    # flame crest, flares on windup
    up = 2 if pose == "wind" else 0
    for k, (dx, ln) in enumerate([(-3, 2), (-1, 3), (1, 4), (3, 2)]):
        fl = ln + up + (1 if (t + k) % 2 else 0)
        cv.line(hx + dx, hy - 3, hx + dx, hy - 3 - fl, f[1] if k % 2 else f[0])
        cv.px(hx + dx, hy - 3 - fl, core)
    # face: hollow eyes, mouth
    cv.rect(hx + 0, hy - 1, hx + 1, hy + 1, dark)
    cv.rect(hx + 3, hy - 1, hx + 4, hy + 1, dark)
    cv.px(hx + 1, hy - 1, core)
    cv.px(hx + 4, hy - 1, core)
    if pose in ("wind", "strike"):
        cv.rect(hx + 1, hy + 2, hx + 4, hy + 4, dark)
        cv.px(hx + 2, hy + 3, core)
    else:
        cv.rect(hx + 1, hy + 3, hx + 3, hy + 3, dark)
    if pose == "strike":
        bx, by = hx + 8, hy + 2
        cv.ell(bx, by, 3, 3, f[1])
        cv.ell(bx, by, 2, 2, f[0])
        cv.ell(bx, by, 1, 1, core)
        cv.line(bx - 6, by, bx - 3, by, f[1])
    if pose == "wind":
        cv.px(hx + 6, hy - 3, core)
        cv.px(hx - 6, hy, f[0])
    return fin(cv)


# ---------------------------------------------------------------- keris_hantu
def keris_hantu(pose, t):
    cv = Cv(24, 24)
    s = ramp(hexc("#b266ff"))
    steel = hexc("#c9c3e6")
    steel_d = hexc("#7a6fa8")
    gold = hexc("#f2c94c")
    glow = hexc("#ff4d6d")
    wob = [0, 1, 0, -1][t % 4]
    if pose in ("idle", "walk", "wind"):
        by = 2 + (0 if pose == "idle" else 0)
        oy = {"idle": [0, 1, 2, 1], "walk": [0, 1, 0, 1], "wind": [0, 0, 0, 0]}[pose][t % 4]
        if pose == "wind":
            oy = -1 + (t % 2)  # quiver
        cx = 12 + (wob if pose == "wind" else 0)
        top = 2 + oy
        # hilt: curved pommel
        cv.ell(cx, top + 2, 2.2, 2.2, gold)
        cv.px(cx + 1, top + 1, hexc("#fff0a8"))
        cv.rect(cx - 1, top + 4, cx, top + 6, s[2])
        # guard
        cv.rect(cx - 3, top + 7, cx + 2, top + 8, gold)
        cv.px(cx - 3, top + 7, hexc("#fff0a8"))
        # luk blade
        for i in range(12):
            off = [0, 0, 1, 1, 0, 0, -1, -1, 0, 0, 1, 0][i]
            wd = max(1, 4 - i // 3)
            x0 = cx - wd // 2 + off
            y = top + 9 + i
            cv.rect(x0 - 1, y, x0 + wd - 1, y, steel if i % 2 else steel_d)
            cv.px(x0 - 1, y, hexc("#efeaff"))
        # cursed eyes
        cv.px(cx - 2, top + 8, glow)
        cv.px(cx + 1, top + 8, glow)
        if pose == "wind":
            for k in range(3):
                cv.px(cx - 4 + k * 4, top + 11 + (t + k) % 2, s[0])
                cv.px(cx - 5 + k * 5, top + 5 - k % 2, s[1])
        else:
            cv.px(cx - 4, top + 11 + oy, s[0])
            cv.px(cx + 4, top + 13, s[1])
    else:
        # strike: horizontal thrust pointing right
        y = 10
        cv.ell(3.5, y, 2.2, 2.2, gold)
        cv.px(3, y - 1, hexc("#fff0a8"))
        cv.rect(5, y - 1, 7, y, s[2])
        cv.rect(8, y - 3, 9, y + 2, gold)
        for i in range(14):
            off = [0, 0, 1, 1, 0, 0, -1, -1, 0, 0, 1, 1, 0, 0][i]
            wd = max(1, 4 - i // 4)
            yy = y - wd // 2 + off
            cv.rect(10 + i, yy, 10 + i, yy + wd - 1, steel if i % 2 else steel_d)
            cv.px(10 + i, yy, hexc("#efeaff"))
        cv.px(8, y - 3, glow)
        cv.px(8, y + 2, glow)
        for k in range(3):
            cv.line(0, y - 4 + k * 4, 3 - k, y - 4 + k * 4, s[1])
    return fin(cv)


# ---------------------------------------------------------------- kuntilanak
def kuntilanak(pose, t, elite=False):
    cv = Cv(20, 22)
    dress = ramp(hexc("#f2dfe8" if elite else "#f1f1f7"))
    hair = ramp(hexc("#2b2a3d"))
    skin = hexc("#dfe3ee")
    skin_d = hexc("#a9b0c8")
    red = hexc("#ff1e42" if elite else "#ff3b3b")
    bob = [0, 1, 2, 1][t % 4] if pose != "strike" else 1
    if pose == "wind":
        bob = 1 + (t % 2)
    hx, hy = 8 + (2 if pose == "strike" else 0), 5 + 2 - bob
    sway = [0, 1, 0, -1][t % 4]
    # hair behind (curtain falling to the left/back and down)
    cv.ell(hx - 1, hy + 1, 5, 5, hair[2])
    for i in range(10):
        wdt = 5 - i // 3
        cv.rect(hx - 5 - sway * (i > 4), hy + 2 + i, hx - 5 + wdt, hy + 2 + i, hair[2] if i % 2 else hair[1])
    cv.rect(hx - 4, hy - 4, hx + 1, hy - 3, hair[1])
    if elite:
        cv.rect(hx - 2, hy - 5, hx + 1, hy - 4, hexc("#ffd166"))
    # dress
    for i in range(10):
        y = hy + 4 + i
        wdt = 3 + i * 0.8
        x0 = hx - wdt / 2 + 0.5
        cv.rect(x0, y, x0 + wdt, y, dress[1] if i % 3 else dress[0])
    cv.rect(hx - 4, hy + 4 + 9, hx + 6, hy + 4 + 9, hexc("#b8253a") if elite else dress[2])
    for k in range(5):  # tattered hem
        cv.px(hx - 4 + k * 2 + (t % 2), hy + 14, hexc("#b8253a") if elite else dress[2])
    # face
    cv.ell(hx + 1.5, hy + 1.5, 3, 3.3, skin)
    cv.px(hx + 4, hy + 1, red)
    cv.px(hx + 2, hy + 1, red)
    cv.rect(hx + 2, hy + 4, hx + 3, hy + 4, (40, 10, 20, 255))
    # hair strand in front of face
    cv.rect(hx - 1, hy - 1, hx, hy + 5, hair[1])
    cv.px(hx - 1, hy - 1, hair[0])
    # arms
    if pose == "wind":
        cv.line(hx + 3, hy + 6, hx + 5, hy - 1 - (t % 2), skin, 1)
        cv.px(hx + 5, hy - 3 - (t % 2), skin)
        cv.px(hx + 6, hy - 3 - (t % 2), skin_d)
        cv.px(hx + 4, hy - 3 - (t % 2), skin_d)
    elif pose == "strike":
        cv.line(hx + 3, hy + 7, hx + 9, hy + 7, skin, 2)
        for k in range(3):
            cv.px(hx + 10, hy + 6 + k, skin_d)
            cv.px(hx + 11, hy + 6 + k, skin_d)
    else:
        cv.line(hx + 3, hy + 6, hx + 3, hy + 9, skin, 1)
    return fin(cv)


# ---------------------------------------------------------------- lampor
def lampor(pose, t):
    cv = Cv(22, 22)
    g = ramp(hexc("#58f57a"))
    core = hexc("#eaffee")
    dark = hexc("#05301a")
    bob = [0, 1, 2, 1][t % 4]
    if pose == "wind":
        bob = 2 - (t % 2)
    hx = 10 + (3 if pose == "strike" else 0) - (1 if pose == "wind" else 0)
    hy = 7 + 2 - (bob if pose != "strike" else 1)
    # dangling entrails
    spread = 2 if pose == "wind" else 0
    for k, dx in enumerate([-3, 0, 3]):
        ln = 7 + (k % 2) * 3
        for i in range(ln):
            x = hx + dx * (1 + spread * 0.5) * (i / ln + 0.4) + math.sin((i + t * 1.3 + k) * 0.9)
            if pose == "strike":
                x -= i * 0.6
            cv.px(x, hy + 4 + i, g[1] if i % 3 else g[0])
            cv.px(x + 1, hy + 4 + i, g[2])
    # wing wisps
    cv.line(hx - 4, hy - 1, hx - 8, hy - 3 + (t % 2) * 2, g[2])
    cv.line(hx - 4, hy, hx - 9, hy + 1 + (t % 2), g[2])
    # head
    cv.shaded_ell(hx, hy, 5, 4.5, g)
    cv.rect(hx + 1, hy - 2, hx + 2, hy, dark)
    cv.rect(hx + 4, hy - 2, hx + 5, hy, dark)
    cv.px(hx + 1, hy - 2, core)
    cv.px(hx + 4, hy - 2, core)
    # teeth maw
    mh = 3 if pose in ("wind", "strike") else 1
    cv.rect(hx, hy + 2, hx + 5, hy + 2 + mh, dark)
    for k in range(0, 6, 2):
        cv.px(hx + k, hy + 2, core)
        if mh > 1:
            cv.px(hx + k + 1, hy + 2 + mh, core)
    return fin(cv)


# ---------------------------------------------------------------- pocong
def pocong(pose, t):
    cv = Cv(20, 24)
    cl = ramp(hexc("#f2e8c8"))
    face = hexc("#6a7a5a")
    dark = hexc("#1b140c")
    red = hexc("#ff4040")
    hop = {"idle": [0, 0, 0, 0], "walk": [0, 3, 4, 1], "wind": [0, 0, 0, 0], "strike": [3, 3, 3, 3]}[pose][t % 4]
    lean = 0
    if pose == "wind":
        lean = -1 - (t % 2)
    if pose == "strike":
        lean = 3
    base_y = 22 - hop
    # body rows from head top down
    rows = [(0, 2), (-1, 5), (-1, 6), (0, 6), (0, 7), (0, 7), (1, 8), (1, 8), (1, 8), (1, 8), (1, 8), (1, 7), (1, 7), (1, 6), (2, 4), (2, 3)]
    top = base_y - len(rows) - 4
    cx = 9
    for i, (o, w) in enumerate(rows):
        wd = w
        off = round(lean * (1 - i / len(rows)))
        x0 = cx - 3 + o - (wd - 6) // 2 + off
        y = top + 4 + i
        cv.rect(x0, y, x0 + wd - 1, y, cl[1])
        cv.px(x0, y, cl[0])
        cv.px(x0 + wd - 1, y, cl[2])
        if i % 5 == 4:
            cv.rect(x0 + 1, y, x0 + wd - 2, y, cl[2])
    # head: rounded top with knot
    hxo = round(lean)
    cv.ell(cx + hxo + 0.5, top + 6, 4, 4, cl[1])
    cv.px(cx + hxo - 2, top + 3, cl[0])
    cv.px(cx + hxo - 1, top + 3, cl[0])
    # face window
    cv.rect(cx + hxo + 0, top + 5, cx + hxo + 4, top + 8, face)
    cv.rect(cx + hxo + 1, top + 6, cx + hxo + 2, top + 6, dark)
    cv.rect(cx + hxo + 3, top + 6, cx + hxo + 4, top + 6, dark)
    cv.px(cx + hxo + 2, top + 6, red)
    cv.px(cx + hxo + 4, top + 6, red)
    if pose in ("wind", "strike"):
        cv.rect(cx + hxo + 1, top + 8, cx + hxo + 3, top + 8, dark)
    # knot + ribbon tails at top
    kx = cx + hxo + 1
    cv.rect(kx - 1, top + 1, kx + 1, top + 2, cl[2])
    cv.px(kx, top, cl[1])
    cv.px(kx - 2, top + 1 - (t % 2), cl[1])
    cv.px(kx + 2, top + 1 + (t % 2) * 0, cl[1])
    cv.px(kx - 3, top + 2, cl[2])
    cv.px(kx + 3, top + 2, cl[2])
    # neck tie
    cv.rect(cx + hxo - 3, top + 9, cx + hxo + 4, top + 9, hexc("#8a6a3a"))
    # foot tie + flare
    fy = base_y - 3 - (0)
    cv.rect(cx - 2 + 1, fy, cx + 3 + 1, fy, hexc("#8a6a3a"))
    cv.rect(cx - 4 + 1, fy + 1, cx + 5 + 1, fy + 2, cl[2])
    cv.px(cx - 4 + 1, fy + 1, cl[1])
    cv.px(cx + 5 + 1, fy + 1, cl[1])
    # arms bound; strike shows hands out front
    if pose == "strike":
        cv.rect(cx + 5 + lean, top + 12, cx + 10 + lean, top + 13, cl[1])
        cv.rect(cx + 10 + lean, top + 12, cx + 11 + lean, top + 13, face)
    return fin(cv)


# ---------------------------------------------------------------- prajurit_terkutuk
def prajurit_terkutuk(pose, t):
    cv = Cv(34, 30)
    a = ramp(hexc("#4b4fd8"))
    steel = ramp(hexc("#9aa3d6"))
    gold = hexc("#d4a73a")
    glow = hexc("#7dffe6")
    skin = hexc("#2b2d4a")
    step = [0, 1, 0, -1][t % 4] if pose == "walk" else 0
    bob = [0, 1, 0, 1][t % 4] if pose in ("idle",) else 0
    cx = 11
    ox = 2 if pose == "strike" else (-1 if pose == "wind" else 0)
    cx += ox
    gy = 29
    # legs
    lh = 6
    l1 = max(-1, step)
    l2 = max(-1, -step)
    cv.rect(cx - 4, gy - lh - 0 + (l1 < 0), cx - 2, gy - (l1 > 0), a[2])
    cv.rect(cx + 2, gy - lh + (l2 < 0), cx + 4, gy - (l2 > 0), a[2])
    cv.rect(cx - 5, gy - 1 - (l1 > 0), cx - 2, gy - (l1 > 0), a[3])
    cv.rect(cx + 2, gy - 1 - (l2 > 0), cx + 5, gy - (l2 > 0), a[3])
    # torso
    ty = gy - lh - 9 + bob
    cv.rect(cx - 6, ty + 2, cx + 6, ty + 9, a[1])
    cv.rect(cx - 6, ty + 7, cx + 6, ty + 9, a[2])
    cv.rect(cx - 2, ty + 2, cx + 2, ty + 7, steel[1])  # breastplate
    cv.rect(cx - 2, ty + 2, cx - 1, ty + 4, steel[0])
    cv.rect(cx - 6, ty + 8, cx + 6, ty + 8, gold)  # belt
    cv.px(cx, ty + 8, hexc("#fff0a8"))
    # pauldrons
    cv.ell(cx - 7, ty + 3, 2.6, 2.4, steel[1])
    cv.ell(cx + 7, ty + 3, 2.6, 2.4, steel[1])
    cv.px(cx - 8, ty + 2, steel[0])
    cv.px(cx + 6, ty + 2, steel[0])
    # helmet
    hy = ty - 3
    cv.rect(cx - 4, hy, cx + 4, hy + 5, a[1])
    cv.rect(cx - 4, hy, cx + 4, hy, a[0])
    cv.rect(cx - 4, hy + 5, cx + 4, hy + 5, a[2])
    cv.rect(cx - 1, hy - 3, cx, hy - 1, gold)  # crest spike
    cv.px(cx - 1, hy - 3, hexc("#fff0a8"))
    cv.rect(cx, hy + 2, cx + 4, hy + 3, skin)
    cv.px(cx + 1, hy + 2, glow)
    cv.px(cx + 3, hy + 2, glow)
    # shield (left)
    cv.ell(cx - 8, ty + 8, 3.2, 3.8, a[2])
    cv.ell(cx - 8, ty + 8, 2.2, 2.8, a[1])
    cv.px(cx - 8, ty + 8, gold)
    # sword arm
    sx, sy = cx + 7, ty + 6
    if pose in ("idle", "walk"):
        cv.rect(sx, sy, sx + 1, sy + 3, skin)
        cv.line(sx + 1, sy + 2, sx + 5, sy - 6 - bob, steel[0], 1)
        cv.line(sx + 2, sy + 2, sx + 6, sy - 6 - bob, steel[1], 1)
        cv.rect(sx - 1, sy + 2, sx + 3, sy + 2, gold)
    elif pose == "wind":
        cv.rect(sx - 1, sy - 2, sx + 1, sy + 2, skin)
        h = 4 + (t % 2)
        cv.line(sx, sy - 3, sx - 2, sy - 3 - 13, steel[0], 1)
        cv.line(sx + 1, sy - 3, sx - 1, sy - 3 - 13, steel[1], 1)
        cv.rect(sx - 2, sy - 3, sx + 2, sy - 3, gold)
        cv.px(sx - 2, sy - 16, hexc("#ffffff"))
        for k in range(2):
            cv.px(sx + 3, sy - 8 - k * 3, glow)
    else:
        cv.rect(sx, sy - 1, sx + 5, sy, skin)
        cv.line(sx + 5, sy - 1, sx + 6, sy + 6, steel[0], 1)
        cv.line(sx + 6, sy - 1, sx + 7, sy + 6, steel[1], 1)
        cv.line(sx + 5, sy - 1, sx + 5 + 0, sy - 1, gold)
        cv.line(sx + 5, sy - 3, sx + 5, sy + 1, gold)
        # slash arc
        for k in range(8):
            ang = -1.2 + k * 0.35
            cv.px(sx + 5 + 8 * math.cos(ang) - 2, sy - 2 + 8 * math.sin(ang), glow)
    return fin(cv)


# ---------------------------------------------------------------- ririwa
def ririwa(pose, t):
    cv = Cv(26, 26)
    b = ramp(hexc("#c9d4ff"))
    dark = hexc("#2a2f55")
    red = hexc("#ff5577")
    bob = [0, 1, 2, 1][t % 4] if pose != "strike" else 1
    if pose == "wind":
        bob = 2 - (t % 2)
    hx = 11 + (2 if pose == "strike" else 0)
    hy = 6 + 2 - bob
    # tail: long S curve tapering to bottom-left
    for i in range(12):
        y = hy + 4 + i
        wd = max(2, 8 - i * 0.55)
        cxx = hx - i * 0.35 + math.sin((i + t * 1.4) * 0.7) * 1.3
        cv.rect(cxx - wd / 2, y, cxx + wd / 2, y, b[1] if i % 4 else b[2])
        cv.px(cxx - wd / 2, y, b[0])
    # head: big bald dome
    cv.shaded_ell(hx, hy, 5, 5, b)
    cv.ell(hx + 3, hy + 1, 1.3, 1.8, dark)
    cv.ell(hx - 0.5, hy + 1, 1.3, 1.8, dark)
    cv.px(hx + 3, hy + 1, red)
    cv.px(hx - 0.5, hy + 1, red)
    cv.rect(hx - 1, hy + 4, hx + 4, hy + 4 + (1 if pose in ("wind", "strike") else 0), dark)
    # sleeves
    if pose in ("idle", "walk"):
        cv.line(hx + 2, hy + 6, hx + 5, hy + 12 + [0, 1, 0, -1][t % 4], b[2], 2)
        cv.px(hx + 5, hy + 14, b[0])
    elif pose == "wind":
        cv.line(hx - 2, hy + 6, hx - 7, hy + 1 - (t % 2), b[2], 2)
        cv.line(hx - 7, hy + 1, hx - 9, hy - 3, b[1], 2)
        cv.px(hx - 9, hy - 4, b[0])
    else:
        cv.line(hx + 2, hy + 7, hx + 9, hy + 7, b[2], 2)
        cv.line(hx + 9, hy + 7, hx + 10, hy + 10, b[1], 2)
        for k in range(9):  # sweep crescent
            ang = -1.1 + k * 0.28
            cv.px(hx + 4 + 9 * math.cos(ang), hy + 9 + 9 * math.sin(ang), hexc("#ffffff"))
            cv.px(hx + 3 + 9 * math.cos(ang), hy + 9 + 9 * math.sin(ang), b[0])
    return fin(cv)


# ---------------------------------------------------------------- shooter
def shooter(pose, t):
    cv = Cv(24, 22)
    b = ramp(hexc("#cfd6e6"))
    cloak = ramp(hexc("#8e9bb8"))
    dark = hexc("#1d2233")
    wood = hexc("#a0662e")
    wood_h = hexc("#d19a54")
    bob = [0, 1, 2, 1][t % 4]
    hx = 9
    hy = 7 + 2 - bob
    # quiver on back
    cv.rect(hx - 6, hy + 2, hx - 4, hy + 8, wood)
    cv.px(hx - 6, hy + 1, hexc("#ff6b6b"))
    cv.px(hx - 5, hy, hexc("#ff6b6b"))
    # cloak body tapers to wisp
    for i in range(9):
        y = hy + 4 + i
        wd = max(2, 8 - i * 0.7)
        cxx = hx - i * 0.25 + math.sin((i + t * 1.3) * 0.8) * 0.8
        cv.rect(cxx - wd / 2, y, cxx + wd / 2, y, cloak[1] if i % 3 else cloak[2])
        cv.px(cxx - wd / 2, y, cloak[0])
    # hooded head with skull mask
    cv.shaded_ell(hx, hy, 5, 4.6, cloak)
    cv.ell(hx + 1.5, hy + 0.8, 3, 3, b[0])
    cv.rect(hx + 1, hy, hx + 2, hy + 1, dark)
    cv.rect(hx + 3, hy, hx + 4, hy + 1, dark)
    cv.px(hx + 4, hy, hexc("#ff4d4d"))
    cv.px(hx + 2, hy, hexc("#ff4d4d"))
    cv.rect(hx + 2, hy + 3, hx + 4, hy + 3, dark)
    # bow & arm
    bx = hx + 7
    pull = 0
    if pose == "wind":
        pull = 3 + (t % 2)
    by = hy + 6
    cv.line(bx, by - 5, bx + 1, by - 3, wood_h)
    cv.line(bx + 1, by - 3, bx + 1, by + 3, wood)
    cv.line(bx + 1, by + 3, bx, by + 5, wood_h)
    cv.line(bx, by - 5, bx - pull, by, hexc("#e8e8e8"))
    cv.line(bx - pull, by, bx, by + 5, hexc("#e8e8e8"))
    cv.line(hx + 3, by + 1, bx, by, cloak[2], 1)
    if pose == "wind":
        cv.line(bx - pull, by, bx + 6, by, hexc("#ffe08a"))
        cv.px(bx + 7, by, hexc("#ffffff"))
        cv.px(bx - pull - 1, by, b[0])
    if pose == "strike":
        cv.line(bx + 2, by, bx + 10, by, hexc("#ffe08a"))
        cv.px(bx + 11, by, hexc("#ffffff"))
        cv.px(bx + 11, by - 1, hexc("#ff4d4d"))
        cv.px(bx + 11, by + 1, hexc("#ff4d4d"))
    return fin(cv)


# ---------------------------------------------------------------- tank
def tank(pose, t):
    cv = Cv(34, 32)
    m = ramp(hexc("#6f9a3a"))
    skin_dark = m[2]
    tusk = hexc("#f4ecd0")
    brown = hexc("#6b4a2a")
    metal = hexc("#9aa0a8")
    gy = 31
    step = [0, 1, 0, -1][t % 4] if pose == "walk" else 0
    bob = 1 if (pose == "idle" and t in (1, 2)) else 0
    ox = 2 if pose == "strike" else (-2 if pose == "wind" else 0)
    cx = 16 + ox
    # legs
    cv.rect(cx - 6, gy - 6 + (step > 0), cx - 2, gy - (step < 0), m[2])
    cv.rect(cx + 2, gy - 6 + (step < 0), cx + 6, gy - (step > 0), m[2])
    cv.rect(cx - 7, gy - 1 - (step < 0), cx - 2, gy - (step < 0), brown)
    cv.rect(cx + 2, gy - 1 - (step > 0), cx + 7, gy - (step > 0), brown)
    # belly body
    by = gy - 19 + bob
    cv.shaded_ell(cx, by + 9, 10, 8, m)
    cv.rect(cx - 8, by + 12, cx + 8, by + 13, brown)  # belt
    cv.rect(cx - 1, by + 12, cx + 1, by + 13, metal)
    # spikes on shoulders
    cv.rect(cx - 10, by + 2, cx - 9, by + 3, metal)
    cv.rect(cx + 8, by + 2, cx + 9, by + 3, metal)
    # head (small, forward)
    hx, hy = cx + 2, by + 1
    cv.shaded_ell(hx, hy, 5, 4, m)
    cv.px(hx + 3, hy - 1, hexc("#ffdd55"))
    cv.px(hx + 1, hy - 1, hexc("#ffdd55"))
    cv.rect(hx - 1, hy - 2, hx + 4, hy - 2, skin_dark)  # brow
    mo = 1 if pose in ("wind", "strike") else 0
    cv.rect(hx - 1, hy + 1, hx + 4, hy + 2 + mo, hexc("#2a1a10"))
    cv.px(hx, hy + 1, tusk)
    cv.px(hx + 3, hy + 1, tusk)
    cv.px(hx, hy, tusk)
    cv.px(hx + 3, hy, tusk)
    # arms/fists
    if pose in ("idle", "walk"):
        fy = by + 11 + [0, 1, 0, 1][t % 4] * (pose == "idle")
        cv.shaded_ell(cx - 11, fy, 3.5, 4, m)
        cv.shaded_ell(cx + 11, fy, 3.5, 4, m)
        cv.rect(cx - 13, fy + 3, cx - 9, fy + 3, brown)
        cv.rect(cx + 9, fy + 3, cx + 13, fy + 3, brown)
    elif pose == "wind":
        up = t % 2
        cv.line(cx - 8, by + 6, cx - 9, by - 2 - up, m[2], 3)
        cv.line(cx + 8, by + 6, cx + 9, by - 2 - up, m[2], 3)
        cv.shaded_ell(cx - 9, by - 3 - up, 4, 4, m)
        cv.shaded_ell(cx + 9, by - 3 - up, 4, 4, m)
        cv.rect(cx - 11, by - 1 - up, cx - 7, by - 1 - up, brown)
        cv.rect(cx + 7, by - 1 - up, cx + 11, by - 1 - up, brown)
    else:
        cv.line(cx + 6, by + 8, cx + 12, gy - 4, m[2], 3)
        cv.line(cx - 6, by + 8, cx - 1, gy - 5, m[2], 3)
        cv.shaded_ell(cx + 13, gy - 4, 4.5, 4, m)
        cv.shaded_ell(cx - 1, gy - 4, 4, 3.5, m)
        for k in range(4):  # dust / shock
            cv.px(cx + 18 + k, gy - 1 - (k % 2), hexc("#d8d0b0"))
            cv.px(cx + 8, gy - 1 - k, hexc("#d8d0b0")) if False else None
        cv.px(cx + 19, gy - 4, hexc("#fff0a8"))
        cv.px(cx + 20, gy - 6, hexc("#fff0a8"))
    return fin(cv)


# ---------------------------------------------------------------- tuyul / leader
def tuyul_gen(pose, t, leader=False):
    k = 1.55 if leader else 1.0
    W, H = (22, 24) if leader else (14, 15)
    cv = Cv(W, H)
    m = ramp(hexc("#7fd24a"))
    gold = hexc("#f2c94c")
    gold_h = hexc("#fff0a8")
    dark = hexc("#10260a")
    gy = H - 1
    step = [0, 1, 0, -1][t % 4] if pose == "walk" else 0
    bounce = 1 if (pose == "idle" and t in (1, 2)) else 0
    hop = 2 if pose == "strike" else 0
    ox = 1 if pose == "strike" else 0
    cx = W // 2 - 1 + ox
    r = round(4.6 * k)
    # legs
    lg = round(3 * k)
    cv.rect(cx - round(2 * k), gy - lg - hop + (step > 0), cx - round(1 * k) + 0, gy - hop - (step < 0), m[2])
    cv.rect(cx + round(1 * k) - 0, gy - lg - hop + (step < 0), cx + round(2 * k), gy - hop - (step > 0), m[2])
    # body + loincloth
    bt = gy - lg - round(3.2 * k) - hop
    cv.ell(cx + 0.5, bt + round(1.8 * k), round(2.6 * k), round(2.2 * k), m[1])
    cv.rect(cx - round(2 * k) + 1, bt + round(2.2 * k), cx + round(3 * k) - 1, bt + round(3.2 * k), hexc("#c24b3a") if not leader else hexc("#b3203a"))
    if leader:  # cape trailing behind
        cv.line(cx - 3, bt, cx - 6 - (t % 2), gy - 2 - hop, hexc("#b3203a"), 2)
        cv.px(cx - 5, bt + 1, hexc("#e0506a"))
    # head
    hy = bt - r + 2 + bounce - 0
    hx = cx + 1
    cv.shaded_ell(hx, hy, r + 0.5, r, m)
    # pointy ears
    cv.line(hx - r - 0, hy - 1, hx - r - 2, hy - 3, m[1], 1)
    cv.line(hx - r, hy, hx - r - 2, hy - 2, m[1], 1)
    cv.px(hx - r - 2, hy - 3, m[0])
    cv.line(hx + r, hy - 1, hx + r + 1, hy - 3, m[1], 1)
    # eyes
    e = round(1.6 * k)
    ex = hx + 1
    cv.rect(ex, hy - 1, ex + e, hy - 1 + (e > 1), (255, 255, 240, 255))
    cv.rect(ex + e + 2, hy - 1, ex + 2 * e + 1, hy - 1 + (e > 1), (255, 255, 240, 255))
    cv.px(ex + e, hy - 1, dark)
    cv.px(ex + 2 * e + 1, hy - 1, dark)
    cv.px(ex + e, hy, dark) if e > 1 else None
    # mouth
    if pose in ("wind", "strike"):
        cv.rect(hx + 1, hy + round(1.8 * k), hx + 1 + round(3 * k), hy + round(2.6 * k), dark)
        cv.px(hx + 2, hy + round(1.8 * k), (255, 255, 255, 255))
    else:
        cv.rect(hx + 1, hy + round(2 * k), hx + 1 + round(2.5 * k), hy + round(2 * k), dark)
        cv.px(hx + 2, hy + round(2 * k) + 0, (255, 255, 255, 255))
    # crown
    if leader:
        cy0 = hy - r + 1
        cv.rect(hx - 4, cy0, hx + 5, cy0 + 1, gold)
        for q in (-4, -1, 2, 5):
            cv.rect(hx + q, cy0 - 2, hx + q, cy0 - 1, gold)
            cv.px(hx + q, cy0 - 3, gold_h)
        cv.px(hx, cy0, hexc("#ff4d6d"))
    # arms
    ay = bt + 1
    if pose in ("idle", "walk"):
        cv.line(cx + round(2 * k), ay, cx + round(3.5 * k), ay + round(3 * k) - (t % 2 if pose == "walk" else 0), m[1])
        cv.line(cx - round(2 * k), ay, cx - round(3 * k), ay + round(3 * k), m[2])
    elif pose == "wind":
        cv.line(cx + round(2 * k), ay, cx + round(3 * k), ay - round(5 * k) - (t % 2), m[1], 1 + leader)
        cv.line(cx - round(2 * k), ay, cx - round(3 * k), ay - round(4 * k), m[2], 1 + leader)
        cv.px(cx + round(3 * k) + 1, ay - round(5 * k) - 1 - (t % 2), dark)
    else:
        cv.line(cx + round(2 * k), ay, cx + round(7 * k), ay + 1, m[1], 1 + leader)
        for q in range(3):
            cv.px(cx + round(7 * k) + 1, ay - 1 + q * 1 * (1 + leader), dark)
        cv.line(cx - round(2 * k), ay + 1, cx - round(4 * k), ay + round(2 * k), m[2])
    return fin(cv)


def tuyul(pose, t):
    return tuyul_gen(pose, t, False)


def tuyul_leader(pose, t):
    return tuyul_gen(pose, t, True)


# ---------------------------------------------------------------- ula_segara
def ula_segara(pose, t):
    cv = Cv(30, 26)
    s = ramp(hexc("#1fa3d8"))
    belly = hexc("#bff0ff")
    fin_c = hexc("#2ee6c8")
    dark = hexc("#052538")
    gy = 25
    ph = t * 0.9
    pts = []
    if pose in ("idle", "walk", "wind"):
        rear = 1 if pose == "wind" else 0
        for i in range(20):
            u = i / 19
            x = 4 + u * (9 - rear * 2) + math.sin(u * 8 + ph) * 1.8 * (1 - u * 0.4) * (1 if pose != "wind" else 0.5)
            y = gy - 3 - u * (16 + (2 if pose == "wind" else 0)) + (math.sin(u * 8 + ph) * 1.0 if pose != "wind" else 0)
            if pose == "wind":
                x = 5 + math.sin(u * 3.2) * 4 + u * -1 + (t % 2) * 0
                y = gy - 3 - u * 16
            pts.append((x, y))
        hx, hy = pts[-1][0] + 2, pts[-1][1] - 1
        if pose == "wind":
            hx, hy = pts[-1][0] - 1, pts[-1][1] + 0
    else:
        for i in range(20):
            u = i / 19
            x = 4 + u * 18
            y = gy - 3 - math.sin(u * 3.0) * 8 - u * 2 + math.sin(u * 8 + ph) * 0.7
            pts.append((x, y))
        hx, hy = pts[-1][0] + 1, pts[-1][1] - 1
    # tail loops on the ground
    for i in range(7):
        cv.ell(2 + i * 1.2, gy - 1.5 + math.sin(i + ph) * 0.8, 2, 1.5, s[2])
    for i, (x, y) in enumerate(pts):
        r = 1.8 + i / 19 * 1.2
        cv.ell(x, y, r, r, s[1] if i % 4 else s[2])
        cv.px(x - 1, y - 1, s[0])
        if i % 3 == 0:
            cv.px(x + 1, y + r * 0.6, belly)
    # head
    op = pose in ("wind", "strike")
    cv.shaded_ell(hx, hy, 4.2, 3.2, s)
    cv.rect(hx + 1, hy + 1, hx + 5, hy + 2 + (2 if op else 0), s[1])
    cv.rect(hx + 2, hy + 2, hx + 5, hy + 2 + (2 if op else 0), dark if op else s[2])
    cv.px(hx + 3, hy + 2, (255, 255, 255, 255)) if op else None
    cv.px(hx + 1, hy - 1, (255, 240, 80, 255))
    cv.px(hx + 2, hy - 1, dark)
    # crest fin
    cv.line(hx - 3, hy - 2, hx - 5, hy - 5, fin_c)
    cv.line(hx - 2, hy - 2, hx - 3, hy - 6, fin_c)
    cv.px(hx - 5, hy - 5, belly)
    # water at base
    for k in range(0, 24, 3):
        cv.px(1 + k + (t % 2), gy, hexc("#9aeaff"))
    return fin(cv)


# ---------------------------------------------------------------- wewe_gombel
def wewe_gombel(pose, t, elite=False):
    cv = Cv(40, 36)
    hr = ramp(hexc("#8a2e7a" if elite else "#6a3fb0"))
    hair_d = hexc("#1c1030")
    skin = hexc("#e5d4df" if elite else "#cdbfdc")
    skin_d = hexc("#a8899f" if elite else "#8f7fa8")
    gy = 35
    sway = [0, 1, 0, -1][t % 4]
    flare = 3 if pose == "wind" else 0
    lean = {"idle": 0, "walk": [0, 1, 0, 1][t % 4], "wind": -2, "strike": 3}[pose]
    cx = 18 + lean
    # hair curtain: big bell from hunched crown
    top = 4 + (1 if pose == "wind" else 0)
    for y in range(top, gy + 1):
        u = (y - top) / (gy - top)
        half = 4 + 10 * math.sin(min(1, u * 1.5) * math.pi / 2) + flare * u
        off = lean * (1 - u) - 3 * (1 - u) * 0.4
        x0 = int(cx - half + off)
        x1 = int(cx + half * 0.8 + off)
        for x in range(x0, x1 + 1):
            base = hr[2] if (x - x0) % 4 else hr[3]
            if (x - x0) < 3:
                base = hr[1] if (y + x) % 3 else hr[2]
            cv.px(x, y, base)
    # ragged hem
    for x in range(int(cx - 14), int(cx + 13)):
        ln = (x * 7 + t * (x % 3)) % 4
        for y in range(gy - ln, gy + 1):
            pass
    for x in range(int(cx - 14), int(cx + 13)):
        if (x + t) % 3 == 0:
            cv.px(x, gy, (0, 0, 0, 0))
    # hair highlights streaks
    for k in range(5):
        x = cx - 9 + k * 4 + lean // 2
        cv.line(x, top + 5 + k, x - 1 - sway, top + 14 + k * 2, hr[0])
    # face peeking out, hunched forward-right
    fx, fy = cx + 5 + (3 if pose == "strike" else 0), top + 9
    cv.ell(fx, fy, 5, 5.5, skin)
    cv.rect(fx - 4, fy - 5, fx - 3, fy + 5, skin_d)
    # hair bangs over face
    cv.rect(fx - 5, fy - 6, fx + 1, fy - 3, hr[2])
    cv.rect(fx - 3, fy - 3, fx - 2, fy + 2, hr[2])
    # droopy eyes & wail mouth
    cv.rect(fx + 1, fy - 1, fx + 2, fy, hair_d)
    cv.rect(fx + 3, fy - 1, fx + 4, fy, hair_d)
    cv.px(fx + 1, fy - 2, skin_d)
    cv.px(fx + 4, fy + 1, hexc("#a0a8ff"))  # tear
    mo = 3 if pose in ("wind", "strike") else 1
    cv.rect(fx + 1, fy + 3, fx + 3, fy + 3 + mo, hexc("#2a0f2a"))
    # saggy long arms
    if pose in ("idle", "walk"):
        ax = fx + 2
        cv.line(ax, fy + 6, ax + 2, gy - 8 + sway, skin, 2)
        cv.line(ax + 2, gy - 8, ax + 4, gy - 5, skin_d, 1)
        cv.px(ax + 5, gy - 4, skin_d)
    elif pose == "wind":
        ax = fx + 3
        cv.line(ax, fy + 6, ax + 4, fy - 8 - (t % 2), skin, 2)
        for q in range(3):
            cv.px(ax + 3 + q * 2, fy - 11 - (t % 2) + q % 2 * 1, skin_d)
        cv.line(ax - 3, fy + 8, ax - 4, fy - 4, skin, 2)
    else:
        ax = fx + 3
        cv.line(ax, fy + 7, ax + 12, fy + 6, skin, 2)
        for q in range(4):
            cv.line(ax + 12, fy + 5 + q, ax + 15, fy + 5 + q + (q - 1), skin_d)
        for q in range(3):
            cv.px(ax + 17 + q, fy + 1 + q * 5, hr[0])
    return fin(cv)


# ---------------------------------------------------------------- wild_boar
def wild_boar(pose, t, elite=False):
    cv = Cv(30, 20)
    b = ramp(hexc("#5c3b28" if elite else "#9c6232"))
    mane = hexc("#c83228" if elite else "#3e2412")
    tusk = hexc("#ffd166" if elite else "#fff5d0")
    gy = 19
    ph = t % 4
    ox = {"idle": 0, "walk": 0, "wind": -1, "strike": 3}[pose]
    dip = {"idle": [0, 0, 1, 0][ph], "walk": [0, 1, 0, 1][ph], "wind": 2, "strike": 1}[pose]
    cx = 12 + ox
    # legs
    def leg(x, lift):
        cv.rect(x, gy - 5 + lift, x + 1, gy - lift * 0 - (1 if lift else 0), b[2])
        cv.rect(x, gy - 1 - (1 if lift else 0), x + 1, gy - (1 if lift else 0), mane)
    if pose == "strike":
        lifts = [1, 0, 1, 0]
        cv.rect(cx - 7, gy - 4, cx - 5, gy - 1, b[2])
        cv.rect(cx + 5, gy - 3, cx + 9, gy - 2, b[2])
        cv.rect(cx - 10, gy - 4, cx - 7, gy - 3, b[2])
        cv.rect(cx + 8, gy - 6, cx + 11, gy - 5, b[2])
    else:
        lf = [0, 1, 0, 1] if pose == "walk" else [0, 0, 0, 0]
        l0 = lf[ph]
        l1 = 1 - lf[ph] if pose == "walk" else 0
        leg(cx - 7, l0)
        leg(cx - 4, l1)
        leg(cx + 3, l1)
        leg(cx + 6, l0)
        if pose == "wind":  # scraping hoof
            cv.rect(cx + 6, gy - 4, cx + 7, gy - 3, b[2])
            cv.px(cx + 9, gy - 2, hexc("#d8d0b0"))
            cv.px(cx + 10, gy - 3 - (t % 2), hexc("#d8d0b0"))
    # body
    by = gy - 10 + dip
    cv.shaded_ell(cx, by + 4, 9.5, 5.5, b)
    # spiky mane
    for k in range(-7, 6, 2):
        cv.line(cx + k, by - 1 + abs(k) // 5, cx + k + 1, by - 3 - (1 if k % 4 == 0 else 0) + abs(k) // 5, mane)
    # tail
    cv.px(cx - 10, by + 2, b[2])
    cv.px(cx - 11, by + 1, b[2])
    cv.px(cx - 11, by, b[2])
    # head
    hx = cx + 9
    hy = by + 4 + (1 if pose in ("wind", "strike") else 0)
    cv.shaded_ell(hx, hy, 5, 4.2, b)
    cv.rect(hx + 3, hy - 1, hx + 7, hy + 2, b[1])  # snout
    cv.rect(hx + 7, hy - 1, hx + 8, hy + 1, hexc("#e0a090"))
    cv.px(hx + 8, hy, mane)
    # tusks
    cv.line(hx + 3, hy + 2, hx + 5, hy - 1 + (1 if pose == "strike" else 0) - (1 if pose == "wind" else 0) , tusk)
    cv.px(hx + 6, hy - 2 + (1 if pose == "strike" else 0), tusk)
    cv.line(hx + 1, hy + 3, hx + 3, hy + 1, tusk)
    # eye + ear
    cv.px(hx + 1, hy - 1, hexc("#ff3030") if pose != "idle" else (255, 255, 255, 255))
    cv.px(hx + 2, hy - 1, mane)
    cv.rect(hx - 3, hy - 4, hx - 2, hy - 3, b[2])
    if pose == "strike":
        for k in range(3):
            cv.line(0, by + 1 + k * 3, 4 - k, by + 1 + k * 3, hexc("#d8d0b0"))
    if pose == "wind":
        cv.px(hx + 9, hy - 1, hexc("#ffffff"))
        cv.px(hx + 10, hy - 2 - (t % 2), hexc("#ffffff"))
    return fin(cv)


# ---------------------------------------------------------------- yuyu_kangkang
def yuyu_kangkang(pose, t):
    cv = Cv(36, 24)
    r = ramp(hexc("#e0412f"))
    claw = ramp(hexc("#ef5a3a"))
    eye = hexc("#fff0c0")
    dark = hexc("#2a0a08")
    gy = 23
    sk = [0, 1, 0, 1][t % 4] if pose == "walk" else 0
    cx = 18 + (2 if pose == "strike" else 0) - (1 if pose == "wind" else 0)
    cy = 15 + ([0, 0, 1, 0][t % 4] if pose == "idle" else 0)
    # legs (3 per side)
    for i in range(3):
        dy = i * 2
        wig = (sk + i) % 2
        cv.line(cx - 7, cy + 1 + dy, cx - 12, cy + 3 + dy + wig, r[2])
        cv.line(cx - 12, cy + 3 + dy + wig, cx - 13, min(gy, cy + 6 + dy), r[3])
        cv.line(cx + 7, cy + 1 + dy, cx + 12, cy + 3 + dy + (1 - wig), r[2])
        cv.line(cx + 12, cy + 3 + dy + (1 - wig), cx + 13, min(gy, cy + 6 + dy), r[3])
    # carapace
    cv.shaded_ell(cx, cy, 9, 6, r)
    cv.rect(cx - 4, cy + 3, cx + 4, cy + 3, r[2])
    cv.px(cx - 3, cy - 3, r[0])
    cv.px(cx + 1, cy + 1, r[2]), cv.px(cx - 2, cy + 1, r[2])
    # eye stalks
    for ex in (cx + 1, cx + 5):
        cv.line(ex, cy - 4, ex, cy - 7, r[2])
        cv.ell(ex, cy - 8, 1.6, 1.6, eye)
        cv.px(ex + 1, cy - 8, dark)
    # mouth angry
    cv.rect(cx + 2, cy + 1, cx + 6, cy + 1, dark)

    def pincer(bx, by, openness, size=1.0, raised=0):
        # arm
        cv.shaded_ell(bx, by, 4.6 * size, 3.8 * size, claw)
        # notch for open pincer
        cv.rect(bx + 2, by - 1 - openness // 2, bx + 6, by + openness // 2 - 0, (0, 0, 0, 0)) if openness else None
        if openness:
            cv.ell(bx + 5.5, by - 2.5 - openness * 0.4, 2.6, 1.8, claw[1])
            cv.ell(bx + 5.5, by + 2 + openness * 0.2, 2.6, 1.6, claw[2])
            cv.px(bx + 7, by - 3 - openness // 2, claw[0])
        else:
            cv.rect(bx + 3, by - 1, bx + 6, by + 1, claw[1])
            cv.px(bx + 7, by, claw[2])
            cv.px(bx + 2, by - 2, claw[0])

    if pose in ("idle", "walk"):
        bob = [0, 1, 0, 1][t % 4]
        cv.line(cx - 7, cy - 1, cx - 11, cy - 4 - bob, r[2], 2)
        cv.line(cx + 7, cy - 1, cx + 11, cy - 4 - bob, r[2], 2)
        pincer(cx - 12, cy - 6 - bob, 1 if t % 2 == 0 else 0, 1.0)
        pincer(cx + 11, cy - 6 - bob, 0, 1.1)
    elif pose == "wind":
        up = t % 2
        cv.line(cx - 7, cy - 1, cx - 10, cy - 8 - up, r[2], 2)
        cv.line(cx + 7, cy - 1, cx + 10, cy - 9 - up, r[2], 2)
        pincer(cx - 11, cy - 11 - up, 3, 1.0)
        pincer(cx + 10, cy - 12 - up, 3, 1.15)
        cv.px(cx + 3, cy - 14, hexc("#ffe08a"))
    else:
        cv.line(cx + 7, cy - 1, cx + 13, cy + 1, r[2], 2)
        cv.line(cx - 7, cy - 1, cx - 3, cy - 3, r[2], 2)
        pincer(cx + 15, cy + 1, 0, 1.2)
        pincer(cx - 3, cy - 5, 2, 1.0)
        for k in range(3):
            cv.line(cx + 24, cy - 3 + k * 3, cx + 26, cy - 5 + k * 4, hexc("#fff0a8"))
    return fin(cv)


ENEMIES = {
    "kemamang": kemamang, "keris_hantu": keris_hantu, "kuntilanak": kuntilanak,
    "kuntilanak_elite": lambda p, t: kuntilanak(p, t, True),
    "lampor": lampor, "pocong": pocong, "prajurit_terkutuk": prajurit_terkutuk,
    "ririwa": ririwa, "shooter": shooter, "tank": tank, "tuyul": tuyul,
    "tuyul_leader": tuyul_leader, "ula_segara": ula_segara,
    "wewe_gombel": wewe_gombel, "wewe_elite": lambda p, t: wewe_gombel(p, t, True),
    "wild_boar": wild_boar, "wild_boar_elite": lambda p, t: wild_boar(p, t, True),
    "yuyu_kangkang": yuyu_kangkang,
}
HOVER = {"keris_hantu", "lampor", "shooter", "kuntilanak", "kuntilanak_elite", "ririwa", "kemamang"}


def build(name, fn):
    idle = [fn("idle", i) for i in range(4)]
    walk = [fn("walk", i) for i in range(4)]
    wind = [fn("wind", i) for i in range(4)]
    strike = [fn("strike", i) for i in range(4)]
    allf = idle + walk + wind + strike
    box = None
    for f in allf:
        b = f.getbbox()
        if b:
            box = b if box is None else (min(box[0], b[0]), min(box[1], b[1]), max(box[2], b[2]), max(box[3], b[3]))
    idle, walk, wind, strike = [[f.crop(box) for f in g] for g in (idle, walk, wind, strike)]
    # cell sized to the largest frame in any pose (+1 px margin for bottom/feet row)
    cw = max(f.width for f in idle + walk + wind + strike)
    ch = max(f.height for f in idle + walk + wind + strike) + 1
    sh = P.enemy_frames(idle[0], cw, ch, idle=idle, walk=walk, windup=wind[0], strike=strike[0],
                        hover=name in HOVER)
    # overwrite telegraph row with animated 2+2 frames
    sh.paste((0, 0, 0, 0), (0, 2 * ch, cw * 4, 3 * ch))
    for i, f in enumerate([wind[0], wind[1], strike[0], strike[1]]):
        P.put(sh, i, 2, f, cw, ch)
    # hurt: white flash flinch (cols 0-1), idle (2-3)
    sh.paste((0, 0, 0, 0), (0, 3 * ch, cw * 2, 4 * ch))
    for i in range(2):
        fl = P.tint(P.shift(idle[i], -1 + i, 0), (255, 255, 255, 255), 0.7 if i == 0 else 0.4)
        P.put(sh, i, 3, fl, cw, ch)
    return sh


def main():
    previews = []
    for name, fn in ENEMIES.items():
        sh = build(name, fn)
        P.save(sh, f"{OUT_DIR}/{name}.png")
        previews.append((name, sh))
    scratch = "/Users/taufan.zamzami/.gemini/antigravity/brain/f643650e-c552-4c12-b6bf-2a7c6d77ba67/scratch"
    os.makedirs(scratch, exist_ok=True)
    # contact sheet in two halves (keeps image size manageable)
    P.preview(previews[:8], os.path.join(scratch, "enemies_b.png"), scale=3)
    P.preview(previews[8:], os.path.join(scratch, "enemies_b2.png"), scale=3)
    for n, s in previews:
        print(n, s.size, "cell", (s.width // 4, s.height // 4))


if __name__ == "__main__":
    main()
