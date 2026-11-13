#!/usr/bin/env python3
"""Enemy sprite sheets (batch B, art pass v8): 18 Budayago enemies at the hero standard.

Hand-built from masks: every form is a filled shape painted in 3 tones lit from the top-left
(light rim top-left, shadow rim bottom-right, no dither), then one plum outline (pixlib.PLUM).
Each creature is draw(pose, t) -> RGBA image of exactly one sheet cell (feet on row cell.y-2,
art faces RIGHT). Poses: idle, walk, wind, strike. Sheet rows: idle / walk /
telegraph (wind, wind, strike, strike) / hurt. Cell sizes: CELL below (sheet = 4x cell).
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pixlib as P
from pixlib import hexc, ramp
from PIL import Image

OUT_DIR = "enemies"
PREVIEW = os.path.join(os.path.dirname(os.path.abspath(__file__)), "enemies_b_preview.png")
WHITE = (255, 255, 255, 255)


def tones(hexstr):
    """(hi, mid, shd, deep) from one mid colour."""
    return ramp(hexc(hexstr))


def M_rect(x0, y0, x1, y1):
    return {(x, y) for y in range(int(y0), int(y1) + 1) for x in range(int(x0), int(x1) + 1)}


def M_ell(cx, cy, rx, ry):
    m = set()
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1.0:
                m.add((x, y))
    return m


def M_poly(pts):
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    m = set()
    n = len(pts)
    for y in range(int(min(ys)) - 1, int(max(ys)) + 2):
        for x in range(int(min(xs)) - 1, int(max(xs)) + 2):
            px, py = x + 0.5, y + 0.5
            inside = False
            j = n - 1
            for i in range(n):
                xi, yi = pts[i]
                xj, yj = pts[j]
                if (yi > py) != (yj > py) and px < (xj - xi) * (py - yi) / (yj - yi) + xi:
                    inside = not inside
                j = i
            if inside:
                m.add((x, y))
    return m


def M_line(x0, y0, x1, y1, th=2):
    n = int(round(max(abs(x1 - x0), abs(y1 - y0), 1)))
    m = set()
    o = th // 2
    for i in range(n + 1):
        x = int(round(x0 + (x1 - x0) * i / n))
        y = int(round(y0 + (y1 - y0) * i / n))
        for a in range(th):
            for b in range(th):
                m.add((x - o + a, y - o + b))
    return m


def M_rows(y0, y1, fn):
    """Mask from per-row spans: fn(y) -> (x0, x1) inclusive."""
    m = set()
    for y in range(int(y0), int(y1) + 1):
        a, b = fn(y)
        for x in range(int(round(a)), int(round(b)) + 1):
            m.add((x, y))
    return m


def M_chain(pts, r0, r1):
    """Union of discs along a path, radius easing r0 -> r1."""
    m = set()
    n = len(pts)
    for i, (x, y) in enumerate(pts):
        r = r0 + (r1 - r0) * i / max(1, n - 1)
        m |= M_ell(x, y, r, r)
    return m


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
        for x, y in M_rect(x0, y0, x1, y1):
            self.px(x, y, c)

    def fill(self, mask, c):
        for x, y in mask:
            self.px(x, y, c)

    def paint(self, mask, tn, hk=1, sk=1, ol=None):
        """3-tone lit fill: light rim top-left (hk px), shadow rim bottom-right (sk px).
        ol: optional inner contour colour drawn just outside the shape."""
        if not mask:
            return
        if ol is not None:
            for x, y in mask:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    if (x + dx, y + dy) not in mask:
                        self.px(x + dx, y + dy, ol)
        hi, mid, shd = tn[0], tn[1], tn[2]
        for x, y in mask:
            if (x + sk, y + sk) not in mask:
                c = shd
            elif (x - hk, y - hk) not in mask:
                c = hi
            else:
                c = mid
            self.px(x, y, c)

    def spots(self, pts, c):
        for x, y in pts:
            self.px(x, y, c)

    def done(self):
        return P.plum_outline(self.img)


def eye(cv, x, y, w=2, h=2, c=WHITE, pupil=None, side=1):
    cv.rect(x, y, x + w - 1, y + h - 1, c)
    if pupil:
        cv.px(x + (w - 1 if side > 0 else 0), y + h - 1, pupil)


def L(lst, t):
    return lst[t % len(lst)]


# ---------------------------------------------------------------- tuyul / leader
def tuyul_gen(pose, t, leader=False):
    W = H = 32 if leader else 24
    cv = Cv(W, H)
    m = tones("#7fd24a")
    cloth = tones("#b3203a" if leader else "#c24b3a")
    gold = tones("#f2c94c")
    dark = hexc("#10260a")
    gy = H - 3
    lg = 4 if leader else 3          # leg height
    lw = 3 if leader else 2
    hrx, hry = (8, 7) if leader else (6, 5.5)
    brx, bry = (5, 4.5) if leader else (3.5, 3.2)
    step = L([0, 1, 0, -1], t) if pose == "walk" else 0
    bounce = 1 if (pose == "idle" and t in (1, 2)) else 0
    hop = (3 if leader else 2) if pose == "strike" else 0
    crouch = 1 if pose == "wind" else 0
    cx = W // 2 - 1 + (1 if pose == "strike" else (-1 if pose == "wind" else 0))
    # legs
    for sx, s in ((-lw - 1, step), (1, -step)):
        lift = 1 if s > 0 else 0
        cv.paint(M_rect(cx + sx, gy - lg + 1 + crouch - hop, cx + sx + lw - 1, gy - lift - hop), m, ol=None)
        cv.rect(cx + sx, gy - lift - hop, cx + sx + lw, gy - lift - hop, m[3])
    # cape (leader)
    bt = gy - lg - int(bry * 2) + 1 - hop + crouch
    if leader:
        cap = tones("#b3203a")
        sw = L([0, 1, 0, -1], t)
        cv.paint(M_poly([(cx - 3, bt + 1), (cx + 1, bt + 1), (cx - 1, gy - 2 - hop), (cx - 9 - sw, gy - hop - 1), (cx - 8, bt + 5)]), cap)
    # body
    bcy = bt + bry
    cv.paint(M_ell(cx + 0.5, bcy, brx, bry), m, sk=1)
    cv.paint(M_rect(cx - brx + 1, bcy + bry - 3, cx + brx, bcy + bry - 1), cloth)
    if leader:
        cv.rect(cx - brx + 1, bcy + bry - 3, cx + brx, bcy + bry - 3, gold[1])
        cv.px(cx, bcy + bry - 3, gold[0])
    # head
    hcx = cx + 1
    hcy = bt - int(hry) + 3 + bounce
    ear = M_poly([(hcx - hrx + 1, hcy - 1), (hcx - hrx - 3, hcy - 5), (hcx - hrx + 1, hcy + 2)])
    ear2 = M_poly([(hcx + hrx - 1, hcy - 2), (hcx + hrx + 2, hcy - 5), (hcx + hrx - 1, hcy + 1)])
    cv.paint(ear, m)
    cv.paint(ear2, m)
    cv.paint(M_ell(hcx, hcy, hrx, hry), m, hk=1, sk=2)
    # face
    e = 3 if leader else 2
    ex = hcx + 1
    ey = hcy - 1
    for k in (0, e + 2):
        cv.rect(ex + k, ey, ex + k + e - 1, ey + e - 1, WHITE)
        cv.rect(ex + k + e - 1, ey + (1 if e > 2 else 0), ex + k + e - 1, ey + e - 1, dark)
    cv.px(ex - 1, ey - 1, m[3])
    cv.px(ex + e + 1, ey - 2 + (0 if pose == "wind" else 1), m[3])
    my = hcy + int(hry * 0.55)
    if pose in ("wind", "strike"):
        cv.rect(ex, my, ex + e + 3, my + (2 if leader else 1), dark)
        cv.px(ex + 1, my, WHITE)
        cv.px(ex + e + 2, my, WHITE)
    else:
        cv.rect(ex, my, ex + e + 2, my, dark)
        cv.px(ex + 1, my + 1, WHITE)
    # crown
    if leader:
        cy0 = hcy - int(hry) + 1
        cv.paint(M_rect(hcx - 5, cy0, hcx + 5, cy0 + 2), gold)
        for q in (-5, -2, 1, 4):
            cv.paint(M_poly([(hcx + q, cy0 + 1), (hcx + q + 1, cy0 - 4), (hcx + q + 2, cy0 + 1)]), gold)
        cv.px(hcx, cy0 + 1, hexc("#ff4d6d"))
        cv.px(hcx + 3, cy0 + 1, hexc("#ff4d6d"))
    # arms (small hands clawing)
    ay = bcy - bry + 2
    th = 2
    if pose in ("idle", "walk"):
        sw = (t % 2) if pose == "walk" else 0
        cv.paint(M_line(cx + brx - 1, ay, cx + brx + 1, ay + 4 - sw, th), m, ol=m[3])
        cv.paint(M_line(cx - brx, ay, cx - brx - 1, ay + 4 + sw, th), m)
    elif pose == "wind":
        up = t % 2
        cv.paint(M_line(cx + brx - 1, ay, cx + brx + 2, ay - 6 - up, th), m, ol=m[3])
        cv.paint(M_line(cx - brx, ay, cx - brx - 2, ay - 5 - up, th), m)
        cv.px(cx + brx + 2, ay - 8 - up, WHITE)
        cv.px(cx - brx - 2, ay - 7 - up, WHITE)
    else:
        cv.paint(M_line(cx + brx - 1, ay + 1, cx + brx + 4, ay + 1, th), m, ol=m[3])
        for q in range(3):
            cv.px(cx + brx + 6, ay - 1 + q * 2, WHITE)
        cv.paint(M_line(cx - brx, ay + 1, cx - brx - 3, ay + 4, th), m)
    return cv.done()


def tuyul(pose, t):
    return tuyul_gen(pose, t, False)


def tuyul_leader(pose, t):
    return tuyul_gen(pose, t, True)
# ---------------------------------------------------------------- kemamang
def kemamang(pose, t):
    cv = Cv(24, 24)
    f = tones("#22d3ee")
    core = hexc("#e6ffff")
    dark = hexc("#06303d")
    bob = {"idle": L([0, 1, 1, 0], t), "walk": L([0, 1, 0, 1], t), "wind": L([1, 0, 1, 0], t), "strike": 0}[pose]
    hx = 11 + (1 if pose == "strike" else 0) - (1 if pose == "wind" else 0)
    hy = 12 + bob
    # trailing flame body: curls down and back
    pts = []
    for i in range(10):
        u = i / 9
        x = hx - 1 - u * 5 + math.sin(u * 4 + t * 1.6) * 1.6 - (3 * u if pose == "strike" else 0)
        pts.append((x, hy + 3 + u * 6))
    cv.paint(M_chain(pts, 4.2, 0.9), f, sk=1)
    # head with flame crest, flicks lean back
    up = 1 if pose == "wind" else 0
    head = M_ell(hx, hy, 5.5, 5)
    for k, (dx, h) in enumerate([(-4, 5), (-1, 8), (2, 6), (4, 3)]):
        hh = h + up + (1 if (t + k) % 2 else 0)
        head |= M_poly([(hx + dx - 2, hy - 2), (hx + dx - 2 - (k % 2), hy - 3 - hh), (hx + dx, hy - 5), (hx + dx + 2, hy - 2)])
    cv.paint(head, f, hk=1, sk=2)
    cv.paint(M_ell(hx - 2, hy - 1, 3, 3.5), (core, f[0], f[0]), hk=1, sk=1)
    # hollow face
    cv.rect(hx + 1, hy - 2, hx + 2, hy + 1, dark)
    cv.rect(hx + 4, hy - 2, hx + 5, hy + 1, dark)
    cv.px(hx + 1, hy - 2, core)
    cv.px(hx + 4, hy - 2, core)
    if pose in ("wind", "strike"):
        cv.rect(hx + 1, hy + 2, hx + 5, hy + 4, dark)
        cv.px(hx + 2, hy + 4, core)
        cv.px(hx + 4, hy + 4, core)
    else:
        cv.rect(hx + 1, hy + 3, hx + 4, hy + 3, dark)
    if pose == "strike":
        bx, by = hx + 7, hy + 2
        cv.paint(M_poly([(hx + 5, by - 2), (bx, by - 1), (bx, by + 2), (hx + 5, by + 3)]), f)
        cv.paint(M_ell(bx + 1, by, 2.6, 2.6), (core, f[0], f[1]), hk=1, sk=1)
    if pose == "wind":
        cv.fill({(hx + 7, hy - 3), (hx + 8, hy - 4), (hx - 7, hy + 1)}, core)
    return cv.done()


# ---------------------------------------------------------------- lampor
def lampor(pose, t):
    cv = Cv(24, 24)
    g = tones("#58f57a")
    core = hexc("#eaffee")
    dark = hexc("#05301a")
    bob = {"idle": L([0, 1, 1, 0], t), "walk": L([0, 1, 0, 1], t), "wind": L([1, 0, 1, 0], t), "strike": 0}[pose]
    hx = 13 + (2 if pose == "strike" else 0) - (1 if pose == "wind" else 0)
    hy = 8 + bob
    spread = 2 if pose == "wind" else 0
    # dangling entrails: three wavy ropes
    for k, dx in enumerate([-4, 0, 4]):
        ln = 7 + (k % 2) * 2
        pts = []
        for i in range(ln):
            u = i / (ln - 1)
            x = hx + dx * (1 + spread * 0.4) * (0.5 + u * 0.5) + math.sin(u * 5 + t * 1.3 + k * 2) * 1.5
            if pose == "strike":
                x -= i * 0.7
            pts.append((x, hy + 4 + i))
        cv.paint(M_chain(pts, 1.6, 0.8), (g[1], g[2], g[3]), hk=1, sk=1)
    # ragged wings
    wing = M_poly([(hx - 4, hy - 2), (hx - 10, hy - 6 + (t % 2) * 2), (hx - 8, hy - 1), (hx - 11, hy + 3 + (t % 2)), (hx - 4, hy + 3)])
    cv.paint(wing, (g[1], g[2], g[3]), hk=1, sk=1)
    cv.paint(M_ell(hx, hy, 6, 5.5), g, hk=1, sk=2)
    # glowing hollow eyes, wide maw with teeth
    cv.rect(hx - 1, hy - 3, hx + 1, hy, dark)
    cv.rect(hx + 3, hy - 3, hx + 5, hy, dark)
    cv.px(hx - 1, hy - 3, core)
    cv.px(hx + 3, hy - 3, core)
    mh = 3 if pose in ("wind", "strike") else 1
    cv.rect(hx - 1, hy + 2, hx + 5, hy + 2 + mh, dark)
    for k in range(0, 7, 2):
        cv.px(hx - 1 + k, hy + 2, core)
        if mh > 1:
            cv.px(hx + k, hy + 2 + mh, core)
    return cv.done()


# ---------------------------------------------------------------- pocong
def pocong(pose, t):
    cv = Cv(32, 32)
    cl = tones("#f2e8c8")
    face = hexc("#6a7a5a")
    dark = hexc("#1b140c")
    red = hexc("#ff4040")
    tie = tones("#8a6a3a")
    hop = {"idle": 0, "walk": L([0, 3, 5, 1], t), "wind": 0, "strike": 3}[pose]
    lean = {"idle": 0, "walk": L([0, 1, 1, 0], t), "wind": -1 - (t % 2), "strike": 3}[pose]
    crouch = (2 if pose == "wind" else 0) + (1 if (pose == "idle" and t in (1, 2)) else 0)
    gy = 29 - hop
    top = 4 + crouch - (hop and 0)
    height = gy - top

    def cxr(y):
        return 15 + round(lean * (1 - (y - top) / height))

    def span(y):
        u = y - top
        if u < 13:
            hw = 5 * math.sqrt(max(0.0, 1 - ((u - 7.5) / 5.5) ** 2))
        elif u < 15:
            hw = 4
        else:
            hw = min(6, 4.8 + (u - 15) * 0.12)
        if gy - y < 2:
            hw += 1
        c = cxr(y)
        hw = max(hw, 1.5)
        return c - hw + 0.5, c + hw - 0.5

    body = M_rows(top + 2, gy, span)
    cv.paint(body, cl, hk=1, sk=2)
    # folds
    for y in range(top + 17, gy - 1):
        c = cxr(y)
        if (y // 3) % 2 == 0:
            cv.px(c + 1, y, cl[2])
        else:
            cv.px(c - 3, y, cl[2])
    # ties: neck, waist, ankle
    for yy in (top + 14, gy - 4):
        c = cxr(yy)
        w = 5 if yy == top + 14 else 6
        cv.paint(M_rect(c - w, yy, c + w - 1, yy + 1), tie)
    # top knot and ribbons
    kc = cxr(top + 1)
    cv.paint(M_poly([(kc - 2, top + 4), (kc, top - 1), (kc + 3, top + 4)]), cl)
    cv.paint(M_line(kc - 1, top, kc - 4, top - 1 + (t % 2), 2), cl)
    cv.paint(M_line(kc + 1, top, kc + 4, top + 1 - (t % 2), 2), cl)
    # face window
    fc = cxr(top + 8)
    cv.rect(fc + 0, top + 4, fc + 5, top + 11, face)
    cv.rect(fc + 0, top + 4, fc + 5, top + 4, hexc("#4c5a42"))
    cv.rect(fc + 0, top + 6, fc + 1, top + 8, dark)
    cv.rect(fc + 3, top + 6, fc + 4, top + 8, dark)
    cv.px(fc + 1, top + 7, red)
    cv.px(fc + 4, top + 7, red)
    if pose in ("wind", "strike"):
        cv.rect(fc + 1, top + 10, fc + 4, top + 11, dark)
        cv.px(fc + 2, top + 10, WHITE)
        cv.px(fc + 4, top + 10, WHITE)
    else:
        cv.rect(fc + 1, top + 10, fc + 3, top + 10, dark)
    # mud stains near the hem
    for dx, dy in ((-3, 2), (2, 3), (-5, 4), (4, 1)):
        cv.px(cxr(gy) + dx, gy - dy, tie[1])
    # strike: bound arms reach out
    if pose == "strike":
        ay = top + 18
        c = cxr(ay)
        cv.paint(M_line(c + 3, ay, c + 10, ay - 1, 3), cl, ol=cl[3])
        cv.paint(M_rect(c + 10, ay - 2, c + 13, ay + 1), (hexc("#8fa080"), face, hexc("#4c5a42")))
        for q in range(2):
            cv.px(c + 14, ay - 2 + q * 3, dark)
    return cv.done()
# ---------------------------------------------------------------- kuntilanak
def kuntilanak(pose, t, elite=False):
    cv = Cv(32, 32)
    dress = tones("#f2dfe8" if elite else "#f1f1f7")
    hair = tones("#3a3852")
    skin = tones("#dfe3ee")
    red = hexc("#ff1e42" if elite else "#ff3b3b")
    trim = tones("#b8253a")
    gold = tones("#f2c94c")
    dark = hexc("#2a0f1c")
    yo = {"idle": L([0, 1, 1, 0], t), "walk": L([0, 1, 0, 1], t), "wind": L([1, 2, 1, 2], t), "strike": 0}[pose]
    sway = L([0, 1, 0, -1], t)
    hx = 14 + (2 if pose == "strike" else (-1 if pose == "wind" else 0))
    hy = 9 + yo
    hem = 26 + yo
    # long hair behind (left side, down past the waist)
    hb = M_ell(hx - 1, hy + 1, 7, 7)
    hb |= M_rows(hy + 3, hem - 1, lambda y: (hx - 9 - (sway if y > hy + 9 else 0) - (1 if y > hy + 14 else 0), hx - 1))
    cv.paint(hb, hair, hk=1, sk=2)
    # dress: bell, ragged hem
    def dspan(y):
        hw = min(9, 3.5 + (y - hy - 5) * 0.4)
        return hx - hw + 0.5, hx + hw - 0.5
    d = M_rows(hy + 5, hem, dspan)
    d = {(x, y) for (x, y) in d if y <= hem - ((x * 5 + t) % 3)}
    cv.paint(d, dress, hk=1, sk=2)
    for x, y in d:
        if y >= hem - 2 and elite and (x, y + 1) not in d:
            cv.px(x, y, trim[1])
    # folds
    for y in range(hy + 10, hem - 1, 3):
        cv.px(hx - 2 + (y % 2) * 4, y, dress[2])
        cv.px(hx - 2 + (y % 2) * 4, y + 1, dress[2])
    if elite:
        cv.paint(M_rect(hx - 3, hy + 8, hx + 3, hy + 9), trim)
    # arms
    if pose == "wind":
        up = t % 2
        cv.paint(M_line(hx + 3, hy + 7, hx + 8, hy - 1 - up, 3), dress, ol=dress[3])
        cv.paint(M_rect(hx + 7, hy - 5 - up, hx + 9, hy - 2 - up), skin)
        for q in range(3):
            cv.px(hx + 6 + q * 2, hy - 7 - up + (q % 2), skin[2])
    elif pose == "strike":
        cv.paint(M_line(hx + 3, hy + 8, hx + 10, hy + 8, 3), dress, ol=dress[3])
        cv.paint(M_rect(hx + 10, hy + 7, hx + 12, hy + 9), skin)
        for q in range(3):
            cv.px(hx + 13, hy + 6 + q * 2, skin[2])
            cv.px(hx + 14, hy + 6 + q * 2, skin[3])
    else:
        sw = (t % 2) if pose == "walk" else 0
        cv.paint(M_line(hx + 3, hy + 7, hx + 4, hy + 13 + sw, 3), dress, ol=dress[3])
        cv.paint(M_rect(hx + 4, hy + 14 + sw, hx + 5, hy + 16 + sw), skin)
    # head
    cv.paint(M_ell(hx + 1.5, hy, 4.5, 5), skin, hk=1, sk=1)
    # fringe and the strand over the face
    cv.paint(M_rect(hx - 4, hy - 6, hx + 3, hy - 4) | M_rect(hx - 4, hy - 6, hx - 2, hy + 3), hair, hk=1, sk=1)
    cv.paint(M_rect(hx - 1, hy - 4, hx, hy + 9), hair, hk=1, sk=1)
    # eyes: dark sockets with red glow, thin mouth
    cv.rect(hx + 1, hy - 1, hx + 2, hy + 1, dark)
    cv.rect(hx + 4, hy - 1, hx + 5, hy + 1, dark)
    cv.px(hx + 2, hy, red)
    cv.px(hx + 5, hy, red)
    if elite:
        cv.px(hx + 1, hy - 1, red)
        cv.px(hx + 4, hy - 1, red)
    if pose in ("wind", "strike"):
        cv.rect(hx + 2, hy + 3, hx + 4, hy + 5, dark)
        cv.px(hx + 3, hy + 4, red)
    else:
        cv.rect(hx + 2, hy + 3, hx + 4, hy + 3, dark)
    if elite:
        cv.paint(M_rect(hx - 3, hy - 7, hx + 5, hy - 6), gold)
        for q in (-3, 0, 3):
            cv.paint(M_poly([(hx + q, hy - 6), (hx + q + 1, hy - 8), (hx + q + 2, hy - 6)]), gold)
        cv.px(hx + 1, hy - 7, red)
    return cv.done()


# ---------------------------------------------------------------- keris_hantu
def keris_hantu(pose, t):
    cv = Cv(32, 32)
    s = tones("#b266ff")
    steel = (hexc("#e6ecff"), hexc("#a8b4e0"), hexc("#5e66a0"), hexc("#3a3f70"))
    gold = tones("#f2c94c")
    wood = tones("#7a4a2a")
    glow = hexc("#ff4d6d")
    oy = {"idle": L([0, 1, 1, 0], t), "walk": L([0, 1, 0, 1], t), "wind": L([0, 1], t), "strike": 0}[pose]
    cx = 16 + (L([0, 1, 0, -1], t) if pose == "walk" else 0)
    top = 2 + oy
    # cursed flame above the pommel
    for k, (dx, h) in enumerate([(-3, 2), (0, 3), (3, 2)]):
        hh = h + ((t + k) % 2)
        cv.paint(M_poly([(cx + dx - 1, top + 3), (cx + dx, top + 3 - hh), (cx + dx + 2, top + 3)]), s)
    # pommel, handle, guard with glowing eyes, wavy blade
    cv.paint(M_ell(cx, top + 3, 3.5, 3), gold, hk=1, sk=1)
    cv.paint(M_rect(cx - 1, top + 6, cx + 1, top + 9), wood, ol=wood[3])
    cv.rect(cx - 1, top + 8, cx + 1, top + 8, gold[1])
    cv.paint(M_poly([(cx - 6, top + 9), (cx + 6, top + 9), (cx + 4, top + 13), (cx - 4, top + 13)]), gold)
    cv.rect(cx - 4, top + 10, cx - 3, top + 11, glow)
    cv.rect(cx + 2, top + 10, cx + 3, top + 11, glow)

    def bspan(y):
        u = (y - top - 13) / 13
        hw = 4.2 * (1 - u) + 0.9
        c = cx + round(math.sin(u * 6.5) * 1.6)
        return c - hw + 0.5, c + hw - 0.5
    cv.paint(M_rows(top + 13, top + 26, bspan), steel, hk=1, sk=1)
    img = cv.img
    if pose == "wind":
        img = img.rotate(-28, resample=Image.NEAREST, center=(16, 16))
    elif pose == "strike":
        img = img.rotate(90, resample=Image.NEAREST, center=(16, 16))
    out = Cv(32, 32)
    out.img = img
    out.p = img.load()
    if pose == "wind":
        for k in range(4):
            out.paint(M_rect(3 + k * 7, 6 + (t + k) % 2 * 2, 4 + k * 7, 7 + (t + k) % 2 * 2), s)
    if pose == "strike":
        for yy in (11, 20):
            out.paint(M_rect(1, yy, 9, yy + 1), s, hk=1, sk=1)
    return out.done()


# ---------------------------------------------------------------- ririwa
def ririwa(pose, t):
    cv = Cv(32, 32)
    b = tones("#c9d4ff")
    robe = tones("#7f90d0")
    dark = hexc("#2a2f55")
    red = hexc("#ff5577")
    yo = {"idle": L([0, 1, 1, 0], t), "walk": L([0, 1, 0, 1], t), "wind": L([1, 2, 1, 2], t), "strike": 0}[pose]
    hx = 14 + (2 if pose == "strike" else 0) - (1 if pose == "wind" else 0)
    hy = 9 + yo
    # long tapering tail in an S curve
    pts = []
    for i in range(13):
        u = i / 12
        x = hx - 1 - u * 2 + math.sin(u * 5 + t * 1.2) * 2.5 - (u * 3 if pose == "strike" else 0)
        pts.append((x, hy + 5 + u * 12))
    cv.paint(M_chain(pts, 5.5, 1.2), robe, hk=1, sk=2)
    cv.paint(M_chain(pts[:6], 4.2, 3.0), b, hk=1, sk=2)
    # sleeves
    if pose in ("idle", "walk"):
        sw = L([0, 1, 0, -1], t)
        cv.paint(M_line(hx + 4, hy + 7, hx + 6, hy + 13 + sw, 3), robe, ol=robe[3])
        cv.paint(M_rect(hx + 6, hy + 14 + sw, hx + 8, hy + 16 + sw), b)
    elif pose == "wind":
        up = t % 2
        cv.paint(M_line(hx - 2, hy + 7, hx - 8, hy + 1 - up, 3), robe, ol=robe[3])
        cv.paint(M_line(hx + 4, hy + 7, hx + 9, hy - 3 - up, 3), robe, ol=robe[3])
        cv.paint(M_rect(hx + 9, hy - 7 - up, hx + 11, hy - 4 - up), b)
        cv.paint(M_rect(hx - 10, hy - 3 - up, hx - 8, hy - up), b)
    else:
        cv.paint(M_line(hx + 4, hy + 8, hx + 12, hy + 9, 3), robe, ol=robe[3])
        cv.paint(M_rect(hx + 12, hy + 8, hx + 14, hy + 11), b)
        for q in range(4):
            cv.px(hx + 7 + q * 2, hy + 14 - q // 2, WHITE)
            cv.px(hx + 8 + q * 2, hy + 14 - q // 2, b[0])
    # head: big bald dome
    cv.paint(M_ell(hx, hy, 7, 6.5), b, hk=2, sk=2)
    cv.rect(hx - 2, hy - 5, hx - 1, hy - 4, WHITE)
    for dx in (-0, 4):
        cv.paint(M_ell(hx + dx + 1.5, hy + 0.5, 1.8, 2.4), (dark, dark, dark))
        cv.px(hx + dx + 2, hy + 1, red)
    my = hy + 4
    cv.rect(hx - 1, my, hx + 5, my + (2 if pose in ("wind", "strike") else 0), dark)
    cv.px(hx + 1, my, WHITE)
    cv.px(hx + 4, my, WHITE)
    return cv.done()


# ---------------------------------------------------------------- shooter
def shooter(pose, t):
    cv = Cv(32, 32)
    cloak = tones("#8e9bb8")
    bone = tones("#cfd6e6")
    dark = hexc("#1d2233")
    wood = tones("#a0662e")
    red = hexc("#ff4d4d")
    yo = {"idle": L([0, 1, 1, 0], t), "walk": L([0, 1, 0, 1], t), "wind": L([0, 1], t), "strike": 0}[pose]
    hx = 11 + (1 if pose == "strike" else 0)
    hy = 9 + yo
    # quiver on the back
    cv.paint(M_line(hx - 8, hy + 1, hx - 5, hy + 10, 3), wood, ol=wood[3])
    cv.spots([(hx - 8, hy), (hx - 6, hy - 1), (hx - 7, hy - 1)], red)
    # cloak: bell that tapers to a wisp
    def cs(y):
        u = y - hy - 5
        hw = min(8, 4 + u * 0.55) if u < 8 else max(1.5, 8 - (u - 8) * 0.7)
        c = hx - u * 0.05 - (math.sin((u + t * 1.3) * 0.8) * 0.9 if u > 7 else 0)
        return c - hw + 0.5, c + hw - 0.5
    cv.paint(M_rows(hy + 5, hy + 19, cs), cloak, hk=1, sk=2)
    # hood and skull mask
    cv.paint(M_ell(hx, hy, 6, 6), cloak, hk=1, sk=2)
    cv.paint(M_ell(hx + 2, hy + 1, 4, 4.5), bone, hk=1, sk=1)
    cv.rect(hx + 1, hy - 1, hx + 2, hy + 1, dark)
    cv.rect(hx + 4, hy - 1, hx + 5, hy + 1, dark)
    cv.px(hx + 2, hy, red)
    cv.px(hx + 5, hy, red)
    cv.rect(hx + 2, hy + 3, hx + 5, hy + 3, dark)
    cv.px(hx + 3, hy + 4, dark)
    # bow in the near hand
    bx, by = hx + 10, hy + 6
    pull = (3 + (t % 2)) if pose == "wind" else 0
    cv.paint(M_line(hx + 3, by + 1, bx - 1, by, 2), cloak, ol=cloak[3])
    bow = M_line(bx, by - 8, bx + 2, by - 4, 2) | M_line(bx + 2, by - 4, bx + 2, by + 4, 2) | M_line(bx + 2, by + 4, bx, by + 8, 2)
    cv.paint(bow, wood, hk=1, sk=1)
    for yy in range(by - 8, by + 9):
        # string: straight or drawn back to a point
        d = pull * (1 - abs(yy - by) / 8) if pose != "strike" else 0
        cv.px(bx - d, yy, hexc("#e8e8e8"))
    if pose == "wind":
        for xx in range(bx - pull, bx + 6):
            cv.px(xx, by, hexc("#ffe08a"))
        cv.paint(M_poly([(bx + 6, by - 2), (bx + 9, by), (bx + 6, by + 2)]), (hexc("#ffffff"),) * 3)
    if pose == "strike":
        for xx in range(bx + 2, bx + 8):
            cv.px(xx, by, hexc("#ffe08a"))
        cv.px(bx + 8, by, WHITE)
        cv.px(bx + 7, by - 1, red)
        cv.px(bx + 7, by + 1, red)
    return cv.done()
# ---------------------------------------------------------------- prajurit_terkutuk
def prajurit_terkutuk(pose, t):
    cv = Cv(40, 36)
    a = tones("#4b4fd8")
    steel = tones("#9aa3d6")
    gold = tones("#d4a73a")
    glow = hexc("#7dffe6")
    skin = tones("#3a3d66")
    gy = 33
    step = L([0, 1, 0, -1], t) if pose == "walk" else 0
    bob = 1 if (pose == "idle" and t in (1, 2)) else 0
    cx = 19 + (-1 if pose == "wind" else 0)
    ty = gy - 21 + bob + (1 if pose == "wind" else 0)
    # tattered cape behind
    sw = L([0, 1, 0, -1], t)
    cape = M_poly([(cx - 5, ty + 2), (cx + 4, ty + 2), (cx + 1, gy - 3), (cx - 3 - sw, gy - 1), (cx - 8, gy - 4), (cx - 11 - sw, gy - 2), (cx - 9, ty + 6)])
    cv.paint(cape, (a[2], a[3], a[3]), hk=1, sk=1)
    # legs and boots
    for sx, s in ((-5, step), (1, -step)):
        lift = 1 if s > 0 else 0
        cv.paint(M_rect(cx + sx, gy - 9 + lift, cx + sx + 3, gy - 1 - lift), a, hk=1, sk=1)
        cv.paint(M_rect(cx + sx - 1, gy - 3 - lift, cx + sx + 4, gy - lift), (a[2], a[3], a[3]))
    # torso, breastplate, belt, tasset
    cv.paint(M_rect(cx - 7, ty + 1, cx + 7, ty + 10), a, hk=1, sk=2)
    cv.paint(M_rect(cx - 4, ty + 2, cx + 4, ty + 8), steel, hk=1, sk=1)
    cv.rect(cx, ty + 3, cx, ty + 7, steel[2])
    cv.rect(cx - 7, ty + 9, cx + 7, ty + 10, gold[1])
    cv.rect(cx - 7, ty + 9, cx + 7, ty + 9, gold[0])
    cv.paint(M_rect(cx - 6, ty + 11, cx + 6, ty + 13), (a[1], a[2], a[3]))
    # shield (far side, left)
    cv.paint(M_ell(cx - 10, ty + 8, 5, 7), a, hk=1, sk=2, ol=a[3])
    cv.paint(M_ell(cx - 10, ty + 8, 3, 5), (a[0], a[1], a[2]), hk=1, sk=1)
    cv.paint(M_ell(cx - 10, ty + 8, 1.5, 1.5), gold)
    # pauldrons
    cv.paint(M_ell(cx - 7, ty + 1, 3.5, 3), steel, hk=1, sk=1, ol=steel[3])
    cv.paint(M_ell(cx + 7, ty + 1, 3.5, 3), steel, hk=1, sk=1, ol=steel[3])
    # helmet with cursed flame crest
    hy = ty - 5
    for k, (dx, h) in enumerate([(-2, 3), (0, 5), (2, 3)]):
        hh = h + ((t + k) % 2)
        cv.paint(M_poly([(cx + dx - 1, hy - 1), (cx + dx, hy - 1 - hh), (cx + dx + 2, hy - 1)]), (glow, hexc("#38d6c0"), hexc("#1f8f8a")))
    cv.paint(M_ell(cx + 1, hy + 3, 5.5, 5), a, hk=1, sk=2, ol=a[3])
    cv.paint(M_rect(cx - 4, hy + 6, cx + 6, hy + 7), steel, hk=1, sk=1)
    cv.rect(cx + 1, hy + 3, cx + 6, hy + 5, skin[3])
    cv.px(cx + 2, hy + 4, glow)
    cv.px(cx + 5, hy + 4, glow)
    cv.rect(cx + 1, hy + 2, cx + 6, hy + 2, a[2])
    # sword arm + sword
    sx, sy = cx + 8, ty + 6
    blade = (hexc("#ffffff"), hexc("#d6defa"), hexc("#8a96c8"))
    if pose in ("idle", "walk"):
        cv.paint(M_line(sx - 1, ty + 3, sx + 1, sy + 3, 3), skin, ol=skin[3])
        cv.paint(M_line(sx + 1, sy + 2, sx + 7, sy - 10 - bob, 2), blade, hk=1, sk=1)
        cv.paint(M_rect(sx - 1, sy + 2, sx + 4, sy + 3), gold)
    elif pose == "wind":
        up = t % 2
        cv.paint(M_line(sx - 1, ty + 3, sx + 1, ty - 3, 3), skin, ol=skin[3])
        cv.paint(M_line(sx + 2, ty - 3, sx - 1, ty - 10 - up, 2), blade, hk=1, sk=1)
        cv.paint(M_rect(sx - 1, ty - 4, sx + 4, ty - 3), gold)
        for k in range(2):
            cv.px(sx + 5, ty - 6 - k * 3, glow)
    else:
        cv.paint(M_line(sx - 1, ty + 3, sx + 6, sy, 3), skin, ol=skin[3])
        cv.paint(M_line(sx + 7, sy - 1, sx + 9, sy + 14, 2), blade, hk=1, sk=1)
        cv.paint(M_rect(sx + 5, sy - 2, sx + 10, sy - 1), gold)
        for k in range(8):
            ang = -1.0 + k * 0.33
            cv.px(sx + 6 + 5 * math.cos(ang), sy - 3 + 9 * math.sin(ang), glow)
    return cv.done()


# ---------------------------------------------------------------- tank
def tank(pose, t):
    cv = Cv(48, 48)
    m = tones("#6f9a3a")
    brown = tones("#6b4a2a")
    metal = tones("#9aa0a8")
    tusk = tones("#f4ecd0")
    dark = hexc("#2a1a10")
    gy = 45
    step = L([0, 1, 0, -1], t) if pose == "walk" else 0
    bob = 1 if (pose == "idle" and t in (1, 2)) else 0
    cx = 24 + (1 if pose == "strike" else (-2 if pose == "wind" else 0))
    # legs and big feet
    for sx, s in ((-11, step), (3, -step)):
        lift = 1 if s > 0 else 0
        cv.paint(M_rect(cx + sx, gy - 11 + lift, cx + sx + 8, gy - 2 - lift), m, hk=1, sk=2)
        cv.paint(M_rect(cx + sx - 1, gy - 3 - lift, cx + sx + 10, gy - lift), brown, hk=1, sk=1)
    # belly and torso
    by = 16 + bob
    cv.paint(M_ell(cx, by + 14, 15, 13), m, hk=2, sk=3)
    cv.paint(M_ell(cx - 3, by + 18, 8, 6), (m[1], m[1], m[2]), hk=1, sk=1)  # belly highlight patch
    # belt and loincloth
    cv.paint(M_rect(cx - 13, by + 19, cx + 13, by + 22), brown, hk=1, sk=1)
    cv.paint(M_rect(cx - 3, by + 18, cx + 3, by + 23), metal, hk=1, sk=1)
    cv.paint(M_poly([(cx - 8, by + 23), (cx + 8, by + 23), (cx + 5, by + 29), (cx - 5, by + 29)]), brown)
    # spiked pauldrons
    for sgn in (-1, 1):
        px_ = cx + sgn * 14
        cv.paint(M_ell(px_, by + 5, 5, 4), brown, hk=1, sk=1, ol=brown[3])
        cv.paint(M_poly([(px_ - 2, by + 2), (px_ + sgn * 1, by - 4), (px_ + 2, by + 2)]), metal)
    # head (small, forward)
    hx, hy = cx + 4, by - 1
    cv.paint(M_ell(hx, hy, 7, 6), m, hk=1, sk=2, ol=m[3])
    cv.rect(hx - 2, hy - 3, hx + 6, hy - 3, m[3])  # heavy brow
    cv.rect(hx + 1, hy - 2, hx + 2, hy - 1, hexc("#ffdd55"))
    cv.rect(hx + 4, hy - 2, hx + 5, hy - 1, hexc("#ffdd55"))
    mo = 1 if pose in ("wind", "strike") else 0
    cv.paint(M_rect(hx - 2, hy + 1, hx + 6, hy + 3 + mo), (dark, dark, dark))
    cv.paint(M_poly([(hx - 1, hy + 2), (hx, hy - 2), (hx + 2, hy + 2)]), tusk)
    cv.paint(M_poly([(hx + 4, hy + 2), (hx + 5, hy - 2), (hx + 7, hy + 2)]), tusk)
    # arms and fists
    if pose in ("idle", "walk"):
        fy = by + 22 + (L([0, 1, 0, 1], t) if pose == "idle" else 0)
        for sgn, ex in ((-1, cx - 16), (1, cx + 16)):
            cv.paint(M_line(cx + sgn * 14, by + 8, ex, fy - 4, 6), m, hk=1, sk=2, ol=m[3])
            cv.paint(M_ell(ex + 1, fy, 5, 5), m, hk=1, sk=2, ol=m[3])
            cv.paint(M_rect(ex - 4, fy - 4, ex + 6, fy - 3), brown)
    elif pose == "wind":
        up = t % 2
        for sgn in (-1, 1):
            ex = cx + sgn * 12
            cv.paint(M_line(cx + sgn * 14, by + 6, ex, by - 5 - up, 6), m, hk=1, sk=2, ol=m[3])
            cv.paint(M_ell(ex, by - 8 - up, 5.5, 5.5), m, hk=1, sk=2, ol=m[3])
            cv.paint(M_rect(ex - 5, by - 4 - up, ex + 4, by - 3 - up), brown)
    else:
        cv.paint(M_line(cx - 14, by + 8, cx + 1, gy - 8, 6), m, hk=1, sk=2, ol=m[3])
        cv.paint(M_ell(cx + 1, gy - 6, 5, 5), m, hk=1, sk=2, ol=m[3])
        cv.paint(M_line(cx + 14, by + 8, cx + 12, gy - 8, 6), m, hk=1, sk=2, ol=m[3])
        cv.paint(M_ell(cx + 12, gy - 6, 5.5, 5.5), m, hk=1, sk=2, ol=m[3])
        dust = hexc("#d8d0b0")
        for k in range(5):
            cv.fill(M_ell(cx + 15 + k * 1, gy - 1 - (k % 2) * 2, 1.2, 1.2), dust)
        cv.px(cx + 16, gy - 8, hexc("#fff0a8"))
        cv.px(cx + 18, gy - 11, hexc("#fff0a8"))
    return cv.done()
# ---------------------------------------------------------------- wewe_gombel
def wewe_gombel(pose, t, elite=False):
    cv = Cv(56, 52)
    hr = tones("#8a2e7a" if elite else "#6a3fb0")
    skin = tones("#e5d4df" if elite else "#cdbfdc")
    dark = hexc("#1c1030")
    eye_c = hexc("#ff3050") if elite else hexc("#a0a8ff")
    bone = tones("#efe6cf")
    gy = 49
    sway = L([0, 1, 0, -1], t)
    lean = {"idle": 0, "walk": L([0, 1, 0, 1], t), "wind": -2, "strike": 2}[pose]
    flare = 2 if pose == "wind" else 0
    bob = 1 if (pose == "idle" and t in (1, 2)) else 0
    cx = 24 + lean
    top = 8 + bob + (1 if pose == "wind" else 0)

    def hs(y):
        u = (y - top) / (gy - top)
        half = 5 + 12 * math.sin(min(1, u * 1.4) * math.pi / 2) + flare * u
        off = lean * (1 - u) - 3 * (1 - u)
        return cx - half + off, cx + half * 0.85 + off
    hair = M_rows(top, gy, hs)
    hair = {(x, y) for (x, y) in hair if y <= gy - ((x * 7 + t * (x % 3)) % 4)}
    cv.paint(hair, (hr[1], hr[2], hr[3]), hk=2, sk=2)
    for k in range(7):
        x0 = cx - 11 + k * 4 + lean // 2
        y0 = top + 12 + (k % 3) * 3
        cv.fill(M_line(x0, y0, x0 - 1 - sway, y0 + 14 + (k % 2) * 6, 2), hr[1])
        cv.px(x0, y0, hr[0])
    # far arm (behind, left) in wind pose
    fx, fy = cx + 9 + (2 if pose == "strike" else 0), top + 14
    # face peeking out, hunched forward
    if pose == "wind":
        up = t % 2
        for ex, ey, sgn in ((fx - 6, fy - 4, -1), (fx + 3, fy + 5, 1)):
            cv.paint(M_line(ex, fy + 8, ex + sgn * 6, fy - 12 - up, 4), skin, ol=skin[3])
            for q in range(3):
                cv.fill(M_line(ex + sgn * 6 + (q - 1) * 3, fy - 13 - up, ex + sgn * 6 + (q - 1) * 4, fy - 17 - up, 2), skin[2])
    cv.paint(M_ell(fx, fy, 7, 8), skin, hk=1, sk=2, ol=skin[3])
    # bangs and side locks over the face
    cv.paint(M_rect(fx - 8, fy - 9, fx + 1, fy - 4) | M_rect(fx - 8, fy - 9, fx - 4, fy + 7), (hr[1], hr[2], hr[3]))
    # sunken eyes, wail mouth, tear
    for ex in (fx - 2, fx + 3):
        cv.rect(ex, fy - 3, ex + 2, fy - 1, dark)
        cv.px(ex + 2, fy - 2, eye_c)
    cv.px(fx + 5, fy + 1, hexc("#a0a8ff"))
    cv.px(fx + 5, fy + 2, hexc("#a0a8ff"))
    mo = 4 if pose in ("wind", "strike") else 2
    cv.rect(fx - 1, fy + 3, fx + 4, fy + 3 + mo, hexc("#2a0f2a"))
    cv.px(fx, fy + 3, WHITE)
    cv.px(fx + 3, fy + 3, WHITE)
    if elite:
        for q in range(-1, 3):
            cv.paint(M_poly([(fx - 4 + q * 3, fy - 8), (fx - 3 + q * 3, fy - 14 - (q % 2) * 2), (fx - 1 + q * 3, fy - 8)]), bone)
        cv.rect(fx - 6, fy - 9, fx + 4, fy - 8, bone[1])
    # long saggy arms with claws
    if pose in ("idle", "walk"):
        ax = fx + 1
        by = gy - 8 + sway
        cv.paint(M_line(ax, fy + 9, ax + 4, fy + 19, 4), skin, ol=skin[3])
        cv.paint(M_line(ax + 4, fy + 19, ax + 6, by, 4), skin, ol=skin[3])
        for q in range(3):
            cv.fill(M_line(ax + 4 + q * 2, by + 1, ax + 5 + q * 2 + (q - 1), by + 6, 2), skin[2])
    elif pose == "strike":
        ax = fx + 2
        cv.paint(M_line(ax, fy + 10, ax + 8, fy + 11, 4), skin, ol=skin[3])
        for q in range(4):
            cv.fill(M_line(ax + 9, fy + 8 + q * 2, ax + 12, fy + 7 + q * 3 + (q - 1), 2), skin[2])
        for q in range(3):
            cv.px(ax + 13, fy + 3 + q * 5, hr[0])
            cv.px(ax + 14, fy + 3 + q * 5, WHITE)
    return cv.done()


def wewe_elite(pose, t):
    return wewe_gombel(pose, t, True)


# ---------------------------------------------------------------- wild_boar
def wild_boar(pose, t, elite=False):
    cv = Cv(40, 24)
    b = tones("#5c3b28" if elite else "#9c6232")
    mane = tones("#c83228" if elite else "#3e2412")
    tusk = tones("#ffd166" if elite else "#fff5d0")
    hoof = hexc("#2a1810")
    gy = 21
    ph = t % 4
    ox = {"idle": 0, "walk": 0, "wind": 0, "strike": 2}[pose]
    dip = {"idle": [0, 0, 1, 0][ph], "walk": [0, 1, 0, 1][ph], "wind": 2, "strike": 0}[pose]
    cx = 15 + ox
    by = gy - 14 + dip
    # legs: far pair darker first, then near pair
    lf = [0, 1, 0, 1][ph] if pose == "walk" else 0
    def leg(x, lift, near):
        top = by + 8
        col = b if near else (b[2], b[3], b[3])
        if pose == "strike":
            cv.paint(M_line(x, top, x + (4 if x > cx else -4), gy - 1, 3), col)
        else:
            cv.paint(M_rect(x, top, x + 2, gy - 1 - lift), col, hk=1, sk=1)
            cv.rect(x, gy - 1 - lift, x + 2, gy - lift, hoof)
    leg(cx - 8, lf, False)
    leg(cx + 6, 1 - lf if pose == "walk" else 0, False)
    # tail
    cv.paint(M_line(cx - 11, by + 2, cx - 13, by - 1, 2), b)
    cv.px(cx - 13, by - 2, b[1])
    # body, bristle mane
    cv.paint(M_ell(cx, by + 5, 11.5, 6), b, hk=2, sk=2)
    for k in range(-10, 9, 2):
        hgt = 3 + (1 if k % 4 == 0 else 0) + (1 if elite else 0)
        cv.paint(M_poly([(cx + k - 1, by - 1 + abs(k) // 6), (cx + k + 1 - (1 if k < 0 else 0), by - 1 - hgt + abs(k) // 6), (cx + k + 2, by - 1 + abs(k) // 6)]), mane)
    leg(cx - 4, 1 - lf if pose == "walk" else 0, True)
    leg(cx + 10, lf, True)
    if elite:  # scar across the flank, bone-spike collar
        for q in range(5):
            cv.px(cx + 1 + q, by + 3 + q, hexc("#e8d0b0"))
        for q in range(4):
            cv.paint(M_poly([(cx + 8 + q * 2, by + 1), (cx + 9 + q * 2, by - 3), (cx + 10 + q * 2, by + 1)]), tones("#efe6cf"))
    # head with snout, tusks, ear, eye
    hx = cx + 13
    hy = by + 6 + (2 if pose == "wind" else 0)
    cv.paint(M_ell(hx, hy, 6, 5.5), b, hk=1, sk=2, ol=b[3])
    cv.paint(M_rect(hx + 3, hy - 1, hx + 7, hy + 3), (b[0], b[1], b[2]), hk=1, sk=1)
    cv.paint(M_rect(hx + 7, hy - 1, hx + 8, hy + 2), (hexc("#f0b0a0"), hexc("#e0a090"), hexc("#b07068")))
    cv.px(hx + 8, hy, hexc("#3a1818"))
    up = -1 if pose == "wind" else 0
    cv.paint(M_poly([(hx + 2, hy + 3), (hx + 4, hy + 4), (hx + 7, hy - 1 + up), (hx + 6, hy - 3 + up)]), tusk)
    cv.paint(M_poly([(hx - 1, hy + 4), (hx + 1, hy + 5), (hx + 2, hy + 2)]), tusk)
    cv.paint(M_poly([(hx - 4, hy - 3), (hx - 2, hy - 6), (hx, hy - 3)]), b, ol=b[3])
    cv.rect(hx + 1, hy - 2, hx + 2, hy - 1, hexc("#ff3030") if (pose != "idle" or elite) else WHITE)
    cv.px(hx + 2, hy - 1, mane[2] if not elite else hexc("#601010"))
    if elite:
        cv.px(hx + 3, hy - 3, mane[1])
        cv.px(hx + 4, hy - 3, mane[1])
    if pose == "strike":
        for k in range(3):
            cv.fill(M_line(2, by + 1 + k * 4, 5 - k, by + 1 + k * 4, 2), hexc("#d8d0b0"))
    if pose == "wind":
        d = hexc("#d8d0b0")
        cv.fill(M_ell(hx + 9, gy - 2, 1.5, 1.5), d)
        cv.fill(M_ell(hx + 10, gy - 4 - (t % 2), 1.2, 1.2), d)
    return cv.done()


def wild_boar_elite(pose, t):
    return wild_boar(pose, t, True)


# ---------------------------------------------------------------- yuyu_kangkang
def claw(cv, bx, by, dx, dy, op, r, size=1.0):
    n = math.hypot(dx, dy)
    dx, dy = dx / n, dy / n
    px_, py_ = -dy, dx
    cv.paint(M_ell(bx, by, 5.5 * size, 5 * size), r, hk=1, sk=2, ol=r[3])
    for sgn in (1, -1):
        sx = bx + px_ * 2.2 * sgn + dx * 3 * size
        sy = by + py_ * 2.2 * sgn + dy * 3 * size
        ex = sx + dx * 8 * size + px_ * op * sgn
        ey = sy + dy * 8 * size + py_ * op * sgn
        cv.paint(M_line(sx, sy, ex, ey, 3), r, hk=1, sk=1, ol=r[3])


def yuyu_kangkang(pose, t):
    cv = Cv(44, 32)
    r = tones("#e0412f")
    eye = hexc("#fff0c0")
    dark = hexc("#2a0a08")
    gy = 29
    sk = L([0, 1, 0, 1], t) if pose == "walk" else 0
    cx = 21 + (-1 if pose == "strike" else 0)
    cy = 20 + (L([0, 0, 1, 0], t) if pose == "idle" else 0) + (1 if pose == "wind" else 0)
    # legs, 3 per side
    for i in range(3):
        wig = (sk + i) % 2
        for sgn in (-1, 1):
            x0 = cx + sgn * 8
            y0 = cy + 1 + i * 2
            kx = cx + sgn * (13 + (1 if i == 1 else 0))
            ky = y0 + 3 + (wig if sgn < 0 else 1 - wig)
            fx_ = cx + sgn * (15 + (2 if i == 1 else 0))
            fy_ = min(gy - 1, gy - 3 + i * 1)
            cv.paint(M_line(x0, y0, kx, ky, 2), (r[2], r[2], r[3]))
            cv.paint(M_line(kx, ky, fx_, fy_, 2), (r[2], r[3], r[3]))
    # carapace
    cv.paint(M_ell(cx, cy, 12, 8), r, hk=2, sk=3)
    cv.rect(cx - 6, cy + 4, cx + 6, cy + 4, r[2])
    for q in (-6, -2, 3):
        cv.rect(cx + q, cy - 3, cx + q + 1, cy - 2, r[2])
    # eye stalks
    for ex in (cx + 2, cx + 8):
        cv.paint(M_rect(ex, cy - 9, ex + 1, cy - 5), r)
        cv.paint(M_ell(ex + 0.5, cy - 10, 2.3, 2.3), (WHITE, eye, hexc("#c8a888")), hk=1, sk=1)
        cv.rect(ex + 1, cy - 10, ex + 2, cy - 9, dark)
    cv.rect(cx + 3, cy + 1, cx + 9, cy + 1, dark)
    # claws
    if pose in ("idle", "walk"):
        bob = L([0, 1, 0, 1], t)
        for sgn, op in ((-1, 3 if t % 2 == 0 else 1), (1, 1)):
            ex = cx + sgn * 11
            cv.paint(M_line(cx + sgn * 8, cy - 1, ex, cy - 3 - bob, 3), r, ol=r[3])
            claw(cv, ex, cy - 6 - bob, sgn * 0.5, -2, op, r, 0.8)
    elif pose == "wind":
        up = t % 2
        for sgn in (-1, 1):
            ex = cx + sgn * 9
            cv.paint(M_line(cx + sgn * 8, cy - 1, ex, cy - 6 - up, 3), r, ol=r[3])
            claw(cv, ex + sgn, cy - 7 - up, sgn * 0.5, -2, 3, r, 0.8)
        cv.px(cx + 3, cy - 15, hexc("#ffe08a"))
    else:
        cv.paint(M_line(cx + 8, cy - 1, cx + 9, cy, 3), r, ol=r[3])
        claw(cv, cx + 10, cy, 1, 0, 0, r, 0.85)
        cv.paint(M_line(cx - 8, cy - 1, cx - 11, cy - 4, 3), r, ol=r[3])
        claw(cv, cx - 11, cy - 7, -0.5, -2, 2, r, 0.8)
        for k in range(3):
            cv.fill(M_line(cx + 18, cy - 3 + k * 3, cx + 19, cy - 5 + k * 4, 2), hexc("#fff0a8"))
    return cv.done()


# ---------------------------------------------------------------- ula_segara
def ula_segara(pose, t):
    cv = Cv(40, 36)
    s = tones("#1fa3d8")
    belly = tones("#bff0ff")
    fin_c = tones("#2ee6c8")
    dark = hexc("#052538")
    gy = 33
    ph = t * 0.9
    pts = []
    n = 22
    for i in range(n):
        u = i / (n - 1)
        if pose in ("idle", "walk"):
            x = 12 + u * 6 + math.sin(u * 7 + ph) * 3.2 * (1 - u * 0.3)
            y = gy - 9 - u * 15 + math.sin(u * 7 + ph) * 0.8
        elif pose == "wind":
            x = 14 + math.sin(u * 3.2) * 5 + u * -2 + (t % 2) * 0.5
            y = gy - 9 - u * 15
        else:
            x = 12 + u * 14
            y = gy - 9 - math.sin(u * 3.0) * 11 - u * 2 + math.sin(u * 8 + ph) * 0.7
        pts.append((x, y))
    hx, hy = pts[-1][0] + 3, pts[-1][1] - 1
    if pose == "wind":
        hx, hy = pts[-1][0] - 2, pts[-1][1] - 1
    # coiled tail on the ground
    coil = M_ell(14, gy - 4, 11, 4) | M_ell(11, gy - 3, 8, 3.5)
    cv.paint(coil, s, hk=1, sk=2)
    for q in range(4):
        cv.fill(M_line(8 + q * 5, gy - 5 + q % 2, 9 + q * 5, gy - 2, 2), s[2])
    cv.paint(M_ell(15, gy - 3, 5, 1.5), belly, hk=1, sk=1)
    # neck: discs along the path, bigger at the base
    body = M_chain(pts, 4.6, 3.0)
    cv.paint(body, s, hk=1, sk=2)
    for i, (x, y) in enumerate(pts):
        if i % 3 == 0 and i > 1:
            cv.px(x + 1, y + 2, belly[1])
            cv.px(x + 2, y + 1, belly[1])
            cv.px(x + 1, y + 3, belly[0])
        if i % 4 == 1 and i < n - 2:
            cv.paint(M_poly([(x - 3, y - 1), (x - 6, y - 4), (x - 2, y - 3)]), fin_c)
    # head with open jaw, crest fin, eye
    op = pose in ("wind", "strike")
    cv.paint(M_poly([(hx - 3, hy - 3), (hx - 7, hy - 6), (hx - 6, hy - 2), (hx - 8, hy + 1), (hx - 3, hy + 1)]), fin_c)
    cv.paint(M_ell(hx, hy, 6, 4.6), s, hk=1, sk=2, ol=s[3])
    cv.paint(M_rect(hx + 2, hy - 1, hx + 7, hy + 1), (s[0], s[1], s[2]), hk=1, sk=1)
    if op:
        cv.rect(hx + 1, hy + 1, hx + 8, hy + 4, dark)
        cv.paint(M_rect(hx + 1, hy + 4, hx + 7, hy + 5), s, hk=1, sk=1)
        for q in (2, 5, 7):
            cv.px(hx + q, hy + 1, WHITE)
        cv.px(hx + 3, hy + 3, hexc("#ff6a6a"))
    else:
        cv.paint(M_rect(hx + 1, hy + 1, hx + 7, hy + 3), (s[1], s[2], s[3]))
        cv.px(hx + 3, hy + 1, WHITE)
        cv.px(hx + 6, hy + 1, WHITE)
    cv.rect(hx, hy - 2, hx + 1, hy - 1, hexc("#fff050"))
    cv.px(hx + 1, hy - 1, dark)
    for k in range(0, 30, 3):
        cv.px(2 + k + (t % 2), gy + (0 if k % 2 == 0 else -1), hexc("#9aeaff"))
    return cv.done()


CELL = {
    "tuyul": (24, 24), "kemamang": (24, 24), "lampor": (24, 24),
    "tuyul_leader": (32, 32), "kuntilanak": (32, 32), "kuntilanak_elite": (32, 32), "pocong": (32, 32),
    "ririwa": (32, 32), "keris_hantu": (32, 32), "shooter": (32, 32),
    "prajurit_terkutuk": (40, 36), "ula_segara": (40, 36),
    "wild_boar": (40, 24), "wild_boar_elite": (40, 24),
    "yuyu_kangkang": (44, 32), "tank": (48, 48),
    "wewe_gombel": (56, 52), "wewe_elite": (56, 52),
}

ENEMIES = {
    "kemamang": "kemamang", "keris_hantu": "keris_hantu", "kuntilanak": "kuntilanak",
    "kuntilanak_elite": "kuntilanak_elite", "lampor": "lampor", "pocong": "pocong",
    "prajurit_terkutuk": "prajurit_terkutuk", "ririwa": "ririwa", "shooter": "shooter",
    "tank": "tank", "tuyul": "tuyul", "tuyul_leader": "tuyul_leader", "ula_segara": "ula_segara",
    "wewe_gombel": "wewe_gombel", "wewe_elite": "wewe_elite", "wild_boar": "wild_boar",
    "wild_boar_elite": "wild_boar_elite", "yuyu_kangkang": "yuyu_kangkang",
}


def kuntilanak_elite(pose, t):
    return kuntilanak(pose, t, True)


def wewe_elite(pose, t):
    return wewe_gombel(pose, t, True)


def wild_boar_elite(pose, t):
    return wild_boar(pose, t, True)


def build(name, fn):
    cw, ch = CELL[name]
    fr = {p: [fn(p, i) for i in range(4)] for p in ("idle", "walk", "wind", "strike")}
    for p, lst in fr.items():
        for f in lst:
            assert f.size == (cw, ch), (name, p, f.size)
    sh = Image.new("RGBA", (cw * 4, ch * 4), (0, 0, 0, 0))
    rows = [fr["idle"], fr["walk"], [fr["wind"][0], fr["wind"][1], fr["strike"][0], fr["strike"][1]]]
    for r, lst in enumerate(rows):
        for c, f in enumerate(lst):
            sh.paste(f, (c * cw, r * ch))
    # hurt: white flash flinch (cols 0-1), idle (cols 2-3)
    for i in range(2):
        fl = P.tint(P.shift(fr["idle"][i], -1 + i, 0), WHITE, 0.7 if i == 0 else 0.4)
        sh.paste(fl, (i * cw, 3 * ch))
        sh.paste(fr["idle"][i], ((2 + i) * cw, 3 * ch))
    return sh


def contact_sheet(items, scale=3, width=1700):
    """Fixed order = ENEMIES order, wrapped left to right."""
    pad, x, y, rowh = 6, 6, 6, 0
    placed = []
    for name, sh in items:
        w, h = sh.width * scale, sh.height * scale
        if x + w + pad > width:
            x, y, rowh = 6, y + rowh + pad, 0
        placed.append((sh, x, y))
        x += w + pad
        rowh = max(rowh, h)
    out = Image.new("RGBA", (width, y + rowh + pad), (70, 96, 70, 255))
    for sh, px, py in placed:
        out.alpha_composite(sh.resize((sh.width * scale, sh.height * scale), Image.NEAREST), (px, py))
    out.save(PREVIEW)


def main(only=None):
    items = []
    for name, fname in ENEMIES.items():
        if only and name not in only:
            continue
        sh = build(name, globals()[fname])
        P.save(sh, f"{OUT_DIR}/{name}.png")
        items.append((name, sh))
    contact_sheet(items)
    print("preview order:", ", ".join(n for n, _ in items))
    for n, s in items:
        print(n, s.size, "cell", (s.width // 4, s.height // 4))


if __name__ == "__main__":
    main(sys.argv[1:] or None)
