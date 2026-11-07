#!/usr/bin/env python3
"""Budayago class-select portraits (Elden-style big figures).

Outputs assets/art/portraits/class_{warrior,archer,rogue,mage}.png, each a strip of 6 idle frames of 96x128
(576x128), plus tools/portraits_preview.png (all four at 2x on a dark ground).

Pure Python (no Pillow needed): masks are bytearrays, shading is procedural (warm key light from the upper
left, 4 tones per material, cool rim light on the right edge, 1 px dark outline), PNGs are written with zlib.
Palettes, clothes, headgear and weapons follow tools/gen_hero_sprites.py (the in-game 16x24 sprites).
Run: python3 tools/gen_portraits.py
"""
import math
import os
import struct
import zlib

W, H, NF = 96, 128, 6
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUTDIR = os.path.join(ROOT, "assets", "art", "portraits")
PREVIEW = os.path.join(ROOT, "tools", "portraits_preview.png")

# ----------------------------------------------------------------------------------------------- colour
def hexc(s):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16))


def shade(c, f):
    if f <= 1:
        return (int(c[0] * f), int(c[1] * f), int(c[2] * f))
    t = f - 1
    return tuple(int(c[i] + (255 - c[i]) * t) for i in range(3))


def mix(a, b, t):
    return tuple(int(a[i] * (1 - t) + b[i] * t) for i in range(3))


def mat(h):
    """(hi, mid, shd, deep): warm highlights, cool shadows."""
    b = hexc(h)
    hi = mix(shade(b, 1.2), (255, 205, 130), 0.16)
    shd = (int(b[0] * 0.68), int(b[1] * 0.66), int(b[2] * 0.76))
    deep = (int(b[0] * 0.42), int(b[1] * 0.40), int(b[2] * 0.54))
    return (hi, b, shd, deep)


OUT = hexc("0E0B0A")
RIM = hexc("8FBAFF")
TF = (1.22, 1.0, 0.72, 0.5)

# ----------------------------------------------------------------------------------------------- masks
def new():
    return bytearray(W * H)


def poly(pts):
    m = new()
    n = len(pts)
    ys = [p[1] for p in pts]
    for y in range(max(0, int(math.floor(min(ys)))), min(H - 1, int(math.ceil(max(ys)))) + 1):
        yc = y + 0.5
        xs = []
        for i in range(n):
            ax, ay = pts[i]
            bx, by = pts[(i + 1) % n]
            if (ay <= yc < by) or (by <= yc < ay):
                xs.append(ax + (yc - ay) * (bx - ax) / (by - ay))
        xs.sort()
        for k in range(0, len(xs) - 1, 2):
            for x in range(max(0, int(math.ceil(xs[k] - 0.5))), min(W - 1, int(math.floor(xs[k + 1] - 0.5))) + 1):
                m[y * W + x] = 1
    return m


def ell(cx, cy, rx, ry):
    m = new()
    for y in range(max(0, int(cy - ry - 1)), min(H, int(cy + ry + 2))):
        for x in range(max(0, int(cx - rx - 1)), min(W, int(cx + rx + 2))):
            if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1.0:
                m[y * W + x] = 1
    return m


def OR(*ms):
    r = bytearray(ms[0])
    for m in ms[1:]:
        for i, v in enumerate(m):
            if v:
                r[i] = 1
    return r


def AND(a, b):
    return bytearray(1 if (x and y) else 0 for x, y in zip(a, b))


def SUB(a, b):
    return bytearray(1 if (x and not y) else 0 for x, y in zip(a, b))


def bres(x0, y0, x1, y1):
    x0, y0, x1, y1 = int(round(x0)), int(round(y0)), int(round(x1)), int(round(y1))
    dx, dy = abs(x1 - x0), -abs(y1 - y0)
    sx, sy = (1 if x0 < x1 else -1), (1 if y0 < y1 else -1)
    err = dx + dy
    out = []
    while True:
        out.append((x0, y0))
        if x0 == x1 and y0 == y1:
            break
        e2 = 2 * err
        if e2 >= dy:
            err += dy
            x0 += sx
        if e2 <= dx:
            err += dx
            y0 += sy
    return out


def L(pts, w=1):
    """Polyline mask, w px wide (square stamp)."""
    m = new()
    o = w // 2
    for i in range(len(pts) - 1):
        for (x, y) in bres(pts[i][0], pts[i][1], pts[i + 1][0], pts[i + 1][1]):
            for a in range(w):
                for b in range(w):
                    xx, yy = x - o + a, y - o + b
                    if 0 <= xx < W and 0 <= yy < H:
                        m[yy * W + xx] = 1
    return m


def dots(pts):
    m = new()
    for x, y in pts:
        if 0 <= x < W and 0 <= y < H:
            m[y * W + x] = 1
    return m


def tube(pts, ws):
    ms = []
    for i in range(len(pts) - 1):
        (x0, y0), (x1, y1) = pts[i], pts[i + 1]
        w0, w1 = max(ws[i], 1.5), max(ws[i + 1], 1.5)
        dx, dy = x1 - x0, y1 - y0
        l = math.hypot(dx, dy) or 1
        px_, py_ = -dy / l, dx / l
        ms.append(poly([(x0 + px_ * w0 / 2, y0 + py_ * w0 / 2), (x1 + px_ * w1 / 2, y1 + py_ * w1 / 2),
                        (x1 - px_ * w1 / 2, y1 - py_ * w1 / 2), (x0 - px_ * w0 / 2, y0 - py_ * w0 / 2)]))
    for (x, y), w in zip(pts, ws):
        ms.append(ell(x, y, max(w, 1.5) / 2, max(w, 1.5) / 2))
    return OR(*ms)


LX, LY = -0.62, -0.78


def tube_lam(pts, ws):
    segs = []
    for i in range(len(pts) - 1):
        (x0, y0), (x1, y1) = pts[i], pts[i + 1]
        dx, dy = x1 - x0, y1 - y0
        l2 = dx * dx + dy * dy or 1
        segs.append((x0, y0, dx, dy, l2, ws[i], ws[i + 1]))

    def f(x, y):
        x, y = x + 0.5, y + 0.5
        best, bs, bd = 9e9, 0.0, 0.0
        for (x0, y0, dx, dy, l2, w0, w1) in segs:
            t = max(0.0, min(1.0, ((x - x0) * dx + (y - y0) * dy) / l2))
            cx, cy = x0 + t * dx, y0 + t * dy
            w = max((w0 + (w1 - w0) * t) / 2, 0.8)
            d = math.hypot(x - cx, y - cy)
            if d / w < best:
                l = math.sqrt(l2)
                nx_, ny_ = -dy / l, dx / l
                s = ((x - cx) * nx_ + (y - cy) * ny_) / w
                best, bs, bd = d / w, max(-1, min(1, s)), nx_ * LX + ny_ * LY
        return 0.5 + 0.5 * (0.85 * bd * bs + 0.6 * math.sqrt(max(0.0, 1 - bs * bs)))
    return f


def rot(pts, ox, oy, ang):
    a = math.radians(ang)
    c, s = math.cos(a), math.sin(a)
    return [(ox + x * c - y * s, oy + x * s + y * c) for x, y in pts]


# ----------------------------------------------------------------------------------------------- canvas
class Cv:
    def __init__(self):
        self.p = [None] * (W * H)

    def alpha_of(self, i):
        return self.p[i] is not None

    def fill(self, m, mt, lam=None, pat=None, sep=False, dith=True, flat=None, bands=(0.95, 0.62, 0.32)):
        bb = None
        xs0, ys0, xs1, ys1 = W, H, -1, -1
        for i, v in enumerate(m):
            if v:
                y, x = divmod(i, W)
                xs0, xs1, ys0, ys1 = min(xs0, x), max(xs1, x), min(ys0, y), max(ys1, y)
        if xs1 < 0:
            return
        w, h = xs1 - xs0 + 1, ys1 - ys0 + 1
        before = [c is not None for c in self.p] if sep else None
        for y in range(ys0, ys1 + 1):
            for x in range(xs0, xs1 + 1):
                if not m[y * W + x]:
                    continue
                if flat is not None:
                    tone = flat
                else:
                    if lam:
                        lv = lam(x, y)
                    else:
                        nx = 2 * (x - xs0 + 0.5) / w - 1
                        ny = 2 * (y - ys0 + 0.5) / h - 1
                        lv = 0.5 + 0.5 * (-0.75 * nx + 0.65 * math.sqrt(max(0.0, 1 - nx * nx))) - 0.10 * ny
                    if dith:
                        lv += (((x & 1) ^ (y & 1)) - 0.5) * 0.05
                    tone = 0 if lv > bands[0] else 1 if lv > bands[1] else 2 if lv > bands[2] else 3
                col = mt[tone]
                if pat is not None and pat[0](x, y):
                    col = shade(pat[1], TF[tone])
                if sep:
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        nx2, ny2 = x + dx, y + dy
                        if 0 <= nx2 < W and 0 <= ny2 < H and not m[ny2 * W + nx2] and before[ny2 * W + nx2]:
                            col = mt[3]
                            break
                self.p[y * W + x] = col

    def paint(self, m, col, over_only=True):
        for i, v in enumerate(m):
            if v and (self.p[i] is not None or not over_only):
                self.p[i] = col

    def put(self, x, y, col):
        x, y = int(x), int(y)
        if 0 <= x < W and 0 <= y < H:
            self.p[y * W + x] = col


def detail(cv, base, lines_m, col):
    cv.paint(AND(base, lines_m), col)


def folds(cv, base, mt, strokes, hi=True):
    """deep fold lines, a wider shadow on the right of each, and a highlight column on the lit (left) side."""
    for s in strokes:
        m = L(s)
        sh_l, sh_r = new(), new()
        for i, v in enumerate(m):
            if v:
                if i % W > 0:
                    sh_l[i - 1] = 1
                if i % W < W - 1:
                    sh_r[i + 1] = 1
        if hi:
            cv.paint(AND(base, SUB(sh_l, m)), mt[0])
        cv.paint(AND(base, SUB(sh_r, m)), mt[2])
        cv.paint(AND(base, m), mt[3])


# ----------------------------------------------------------------------------------------------- patterns
def kawung(ox=0, oy=0):
    def f(x, y):
        X, Y = (x + ox) % 6, (y + oy + (3 if ((x + ox) // 6) % 2 else 0)) % 6
        d = (X - 2.5) ** 2 + (Y - 2.5) ** 2
        return 1.6 < d < 5.0
    return f


def parang(ox=0):
    def f(x, y):
        return (x - y + ox) % 7 in (0, 1) or ((x + y) % 7 == 3 and (x - y + ox) % 7 == 4)
    return f


def ceplok(x, y):
    return (x + y) % 4 == 0 and (x - y) % 8 in (0, 4)


def gate(fn, y0=0, y1=H):
    return lambda x, y: y0 <= y < y1 and fn(x, y)


# ----------------------------------------------------------------------------------------------- shared body pieces
SKIN = mat("E3A66E")
HAIR = mat("3A2A36")
HAIR_HI = hexc("7A6078")
BR = [0, 0, 1, 1, 1, 0]
SW = [0, 1, 1, 0, -1, -1]
SW2 = [1, 1, 0, -1, -1, 0]
DK = hexc("22140F")


class HF:
    """Head frame: local coords with the origin at the chin centre, so heads are authored once at 'small' size."""
    def __init__(self, x, y):
        self.x, self.y = x, y

    def m(self, pts):
        return [(self.x + a, self.y + b) for a, b in pts]

    def poly(self, pts):
        return poly(self.m(pts))

    def ell(self, cx, cy, rx, ry):
        return ell(self.x + cx, self.y + cy, rx, ry)

    def L(self, pts, w=1):
        return L(self.m(pts), w)

    def put(self, cv, x, y, c):
        cv.put(self.x + x, self.y + y, c)


def spec(cv, x, y):
    cv.put(x, y, hexc("FFFFFF"))
    cv.put(x + 1, y, hexc("E6F0FF"))
    cv.put(x, y + 1, hexc("E6F0FF"))


def fist(cv, x, y, r=3.4, sk=SKIN):
    cv.fill(ell(x, y, r, r - 0.2), sk, sep=True)
    for k in (-1.6, 0.2, 1.8):
        cv.put(x + k - 0.5, y + 1, sk[3])
    cv.put(x - 1, y - 1, sk[0])


def hand_open(cv, x, y, sk=SKIN):
    cv.fill(OR(ell(x, y, 3.2, 3), poly([(x - 3, y - 1), (x + 3, y - 1), (x + 3, y - 5), (x - 3, y - 5)])), sk, sep=True)
    for k in (-2, 0, 2):
        cv.put(x + k, y - 4, sk[3])
        cv.put(x + k, y - 5, sk[1])
    cv.put(x + 4, y - 1, sk[1])


def face(cv, h, brow="flat", eyes="calm", lip=hexc("A0524A")):
    fm = h.poly([(-6.5, -12.5), (6, -12.5), (6.8, -7), (5.5, -3), (2.5, 0), (-2, 0), (-5, -3), (-7, -7)])
    ear = OR(h.ell(-7.2, -6.5, 1.5, 2.4), h.ell(6.6, -6.5, 1.2, 2.1))
    cv.fill(ear, SKIN, flat=2, dith=False)
    hx = h.x
    cv.fill(fm, SKIN, lam=lambda x, y: 0.5 + 0.5 * (-0.6 * ((x + 0.5 - hx) / 7.5) + 0.75 * math.sqrt(max(0, 1 - ((x + 0.5 - hx) / 8) ** 2))) - 0.02 * (y - h.y), bands=(0.88, 0.5, 0.2), dith=False)
    p = lambda x, y, c: h.put(cv, x, y, c)
    # brows
    bl = {"frown": [(-5, -8), (-4, -8), (-3, -8), (-2, -7)], "arch": [(-5, -7), (-4, -8), (-3, -8), (-2, -7)], "flat": [(-5, -8), (-4, -8), (-3, -8), (-2, -8)]}[brow]
    for x, y in bl:
        p(x, y, HAIR[1])
    for i, (x, y) in enumerate(bl[::-1]):
        p(1 + i, y, HAIR[1])
    # eyes: soft lid, white, dark iris with a highlight pixel
    for ex in (-5, 1):
        for k in range(3):
            p(ex + k, -6, mix(DK, SKIN[2], 0.3))
        p(ex + 1, -6, DK)
        p(ex, -5, hexc("F8F4E8"))
        p(ex + 1, -5, hexc("FFFFFF") if eyes != "narrow" else DK)
        p(ex + 2, -5, DK)
        p(ex + 1, -4, DK)
        p(ex + 2, -4, DK)
        p(ex, -4, SKIN[2])
        if eyes == "narrow":
            p(ex, -5, SKIN[2])
            p(ex + 1, -5, hexc("FFFFFF"))
    # nose
    p(0, -5, SKIN[0])
    p(0, -4, SKIN[0])
    p(1, -3, SKIN[2])
    p(1, -2, SKIN[3])
    p(0, -2, SKIN[2])
    p(2, -2, SKIN[2])
    # mouth, chin
    for x in (-1, 0, 1):
        p(x, -1, lip)
    p(-2, -1, mix(lip, SKIN[1], 0.55))
    p(2, -1, mix(lip, SKIN[2], 0.5))
    p(0, 0, SKIN[2])
    p(-3, -3, mix(SKIN[1], (220, 110, 90), 0.35))
    p(4, -3, mix(SKIN[2], (200, 90, 80), 0.3))


def neck(cv, h):
    nm = tube([(h.x - 1, h.y - 3), (h.x - 2, h.y + 6)], [6.4, 7.5])
    cv.fill(nm, SKIN, flat=1, dith=False)
    cv.paint(AND(nm, poly([(0, h.y + 1), (W, h.y + 1), (W, h.y + 4), (0, h.y + 4)])), SKIN[2])
    cv.paint(AND(nm, poly([(0, h.y + 1), (h.x - 3, h.y + 1), (h.x - 3, h.y + 6), (0, h.y + 6)])), SKIN[1])


def hair_mass(cv, h, ry=9, rx=7.8):
    m = h.ell(0, -8, rx, ry)
    cv.fill(m, HAIR, dith=False)
    cv.paint(AND(m, h.L([(-5, -13), (-6.5, -9), (-6.8, -4)])), HAIR_HI)
    return m


def boot(cv, xc, d, mt, trim, yb):
    pts = [(-4.5, -12), (4.5, -12), (5, -6), (8, -2.5), (8.5, 0), (-5.5, 0), (-5.5, -5)]
    m = poly([(xc + x * d, yb + y) for x, y in pts])
    cv.fill(m, mt, sep=True, dith=False)
    cv.paint(AND(m, L([(xc - 5 * d, yb - 10), (xc + 5 * d, yb - 10)])), trim)
    cv.paint(AND(m, L([(xc - 6, yb - 1), (xc + 9, yb - 1)])), mt[3])
    cv.paint(AND(m, L([(xc - 3 * d, yb - 8), (xc - 3 * d, yb - 3)])), mt[0])
    return m


def leg(cv, pts, mt, wraps=None, ws=(14, 11, 8.5)):
    m = tube(pts, list(ws))
    cv.fill(m, mt, lam=tube_lam(pts, list(ws)), sep=True)
    if wraps:
        for yy in range(wraps, 112, 3):
            t = (yy - pts[1][1]) / max(1, pts[2][1] - pts[1][1])
            xx = pts[1][0] + (pts[2][0] - pts[1][0]) * t
            cv.paint(AND(m, L([(xx - 6, yy), (xx + 6, yy + 2)])), mt[3])
            cv.paint(AND(m, L([(xx - 6, yy - 1), (xx + 6, yy + 1)])), mt[0])
    return m


def star(cv, x, y, size=2, col=hexc("FFFFFF"), edge=hexc("FFE9A8")):
    cv.put(x, y, col)
    for k in range(1, size + 1):
        for dx, dy in ((k, 0), (-k, 0), (0, k), (0, -k)):
            cv.put(x + dx, y + dy, col if k == 1 else edge)


def pauldron(cv, cx, cy, rx, ry, MET, GOLD):
    cv.fill(ell(cx - 0.5, cy + ry * 0.7, rx * 0.82, ry * 0.62), MET, sep=True)
    pm = ell(cx, cy, rx, ry)
    cv.fill(pm, MET, sep=True)
    cv.paint(AND(pm, L([(cx - rx + 1, cy - ry * 0.3), (cx - rx * 0.4, cy - ry * 0.9), (cx + rx * 0.4, cy - ry * 0.9), (cx + rx - 1, cy - ry * 0.3)])), GOLD[1])
    cv.paint(AND(pm, L([(cx - 1, cy + ry * 0.5), (cx + rx - 2, cy + ry * 0.1)], 2)), MET[3])
    spec(cv, int(cx - rx * 0.55), int(cy - ry * 0.55))
    cv.put(cx - 1, cy + 1, GOLD[0])


# ----------------------------------------------------------------------------------------------- WARRIOR
def warrior(cv, f):
    u, sw, sw2 = BR[f], SW[f], SW2[f]
    RED, GOLD, MET = mat("B8353A"), mat("F2B84B"), mat("A9B7CC")
    PANT, BOOT, KAIN = mat("3B2B4A"), mat("5E3B1E"), mat("6E2630")
    LEA, CAP = mat("7A4E2A"), mat("5A3A22")
    h = HF(51, 31 - u)
    # sash tail behind the kain
    st = poly([(54, 58), (60, 58), (63 + sw, 72), (65 + sw2, 88), (59 + sw, 90), (58 + sw, 74)])
    cv.fill(st, mat("E0575A"), sep=True)
    cv.paint(AND(st, L([(60 + sw, 89), (65 + sw2, 87)], 2)), GOLD[1])
    # legs: weight on the right leg, left foot out and forward
    pl = [(41, 63), (36, 90), (29, 114)]
    pr = [(54, 63), (55, 91), (58, 114)]
    leg(cv, pl, PANT)
    leg(cv, pr, PANT)
    folds(cv, tube(pl, [14, 11, 8.5]), PANT, [[(35, 96), (31, 108)]])
    folds(cv, tube(pr, [14, 11, 8.5]), PANT, [[(55, 96), (57, 108)]])
    boot(cv, 28, -1, BOOT, GOLD[1], 123)
    boot(cv, 59, 1, BOOT, GOLD[1], 121)
    # kain
    km = poly([(37, 59), (59, 59), (62, 72), (63 + sw, 84), (56, 86), (48, 86), (40, 88), (32 + sw, 87), (34, 72)])
    cv.fill(km, KAIN, pat=(kawung(0, 0), hexc("B8822E")), sep=True)
    folds(cv, km, KAIN, [[(41, 66), (38, 87)], [(50, 66), (51, 86)], [(57, 66), (60, 84)]], hi=False)
    cv.paint(AND(km, L([(33, 84), (48, 84), (62, 82)], 2)), GOLD[1])
    cv.paint(AND(km, L([(33, 85), (48, 85), (62, 83)])), GOLD[2])
    # kris at the left hip (sheath trails behind)
    sheath = tube([(38, 62), (30, 75), (24, 90)], [4.5, 5.5, 4])
    cv.fill(sheath, LEA, sep=True, dith=False)
    cv.paint(AND(sheath, L([(30, 73), (26, 85)])), LEA[0])
    cv.paint(AND(sheath, L([(32, 71), (28, 83)])), LEA[3])
    # tunic (near shoulder lower, far shoulder higher)
    tun = poly([(33, 37 - u), (61, 35.5 - u), (60, 48), (58, 60), (37, 60), (35, 48)])
    cv.fill(tun, RED, sep=True)
    folds(cv, tun, RED, [[(40, 48), (41, 57)], [(55, 47), (54, 56)], [(47, 50), (47, 57)], [(36, 44), (39, 52)]])
    vm = poly([(44, 35.5 - u), (53, 35 - u), (48.5, 46 - u)])
    cv.fill(vm, SKIN, flat=1, dith=False)
    cv.paint(AND(vm, L([(43, 36 - u), (53, 35 - u)], 2)), SKIN[2])
    cv.paint(L([(43, 36 - u), (48.5, 46 - u), (53, 35 - u)], 1), GOLD[1])
    cv.paint(AND(tun, L([(44, 39 - u), (48.5, 49 - u), (53, 38 - u)])), GOLD[0])
    cv.fill(poly([(36, 55), (59, 55), (59, 60), (36, 60)]), LEA, sep=True, dith=False)
    cv.paint(L([(37, 56), (58, 56)]), LEA[0])
    cv.fill(ell(47.5, 57.5, 3.2, 2.8), GOLD, sep=True)
    cv.put(47, 57, GOLD[3])
    # near (left) arm: forearm drops to the kris hilt
    a1 = [(33, 38 - u), (28, 50), (31, 56)]
    w1 = [11, 9.5, 8]
    cv.fill(tube(a1, w1), RED, lam=tube_lam(a1, w1), sep=True)
    a2 = [(31, 55), (35, 59), (38, 61)]
    w2 = [8, 7, 6]
    cv.fill(tube(a2, w2), SKIN, lam=tube_lam(a2, w2), sep=True)
    cv.fill(tube([(32, 56), (34.5, 58)], [8.5, 8]), LEA, sep=True, dith=False)
    cv.fill(ell(38, 61, 2.8, 2.2), GOLD, sep=True)
    cv.fill(L([(39, 59), (43, 55)], 2), mat("F2E2B0"), dith=False)
    cv.put(43, 54, GOLD[0])
    fist(cv, 38.5, 62.5, 3.4)
    # right arm and golok held low across the body
    fx, fy = 58.5, 62.5
    ang = 150
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    O = (fx - 4 * ca, fy - 4 * sa)
    blp = rot([(0, 2.4), (18, 4.0), (31, 5.0), (37, 1.5), (32, -3.2), (14, -4.2), (0, -2.8)], O[0], O[1], ang)
    bl = poly(blp)

    def blam(x, y):
        ly = -(x + 0.5 - O[0]) * sa + (y + 0.5 - O[1]) * ca
        return 0.5 + 0.5 * (ly / 4.6)
    # (ly > 0 is the spine side, which faces the key light)
    ly_sign = 1
    cv.fill(bl, MET, lam=lambda x, y: 0.1 + 0.9 * max(0, min(1, 0.5 + 0.5 * ((x + 0.5 - O[0]) * (-sa) + (y + 0.5 - O[1]) * ca) / 4.6)), sep=True, dith=False, bands=(0.8, 0.5, 0.25))
    cv.paint(AND(bl, L(rot([(3, -3.2), (33, -2.6)], O[0], O[1], ang))), hexc("F4F8FC"))
    cv.paint(AND(bl, L(rot([(6, 0.4), (27, 0.9)], O[0], O[1], ang))), MET[3])
    cv.paint(AND(bl, L(rot([(8, 2.6), (24, 3.1)], O[0], O[1], ang))), MET[0])
    sx, sy = rot([(8, 3.0)], O[0], O[1], ang)[0]
    spec(cv, int(sx), int(sy))
    hd = poly(rot([(-9, -1.8), (0, -1.8), (0, 1.8), (-9, 1.8)], O[0], O[1], ang))
    cv.fill(hd, LEA, sep=True, dith=False)
    gd = poly(rot([(-0.5, -4), (1.6, -4), (1.6, 4), (-0.5, 4)], O[0], O[1], ang))
    cv.fill(gd, GOLD, sep=True, dith=False)
    cv.fill(ell(*rot([(-9.5, 0)], O[0], O[1], ang)[0], 2.3, 2.3), GOLD, sep=True)
    ua = [(61, 38 - u), (67, 51), (64, 57)]
    uw = [10, 9, 8]
    cv.fill(tube(ua, uw), RED, lam=tube_lam(ua, uw), sep=True)
    fa = [(65, 54), (62, 59), (60, 61)]
    fw = [7.5, 6.5, 6]
    cv.fill(tube(fa, fw), SKIN, lam=tube_lam(fa, fw), sep=True)
    cv.fill(tube([(64, 55.5), (62.5, 58)], [8, 7.6]), LEA, sep=True, dith=False)
    fist(cv, fx, fy, 3.9)
    if f in (1, 2, 3, 4):
        t = (0.2, 0.42, 0.64, 0.86)[f - 1]
        gx, gy = rot([(4 + 30 * t, -3.0)], O[0], O[1], ang)[0]
        star(cv, int(round(gx)), int(round(gy)), 2 if f == 3 else 1)
    # pauldrons
    pauldron(cv, 31, 40 - u, 8.5, 5.8, MET, GOLD)
    pauldron(cv, 62, 38.5 - u, 7, 5, MET, GOLD)
    # head
    hair_mass(cv, h)
    neck(cv, h)
    face(cv, h, brow="frown", eyes="narrow")
    cm = h.poly([(-7.8, -10.5), (-7.8, -14), (-5.5, -17), (-1.5, -19), (3, -19), (6.5, -17), (8, -14), (8, -10.5), (5, -11.8), (0, -12.5), (-5, -11.8)])
    cv.fill(cm, CAP, pat=(parang(), hexc("B07A3A")), sep=True)
    cv.paint(AND(cm, h.L([(-7.8, -11), (0, -12.7), (8, -11)])), GOLD[1])
    cv.paint(AND(cm, h.L([(-7.2, -15), (-4.5, -17.5), (-1, -18.7)])), CAP[0])
    cv.fill(ell(h.x + 0.5, h.y - 15, 1.5, 1.5), GOLD, sep=True)
    cv.put(h.x, h.y - 15, GOLD[0])


# ----------------------------------------------------------------------------------------------- ARCHER
def archer(cv, f):
    u, sw, sw2 = BR[f], SW[f], SW2[f]
    GRN, LEAF, PANT = mat("5F9E4A"), mat("8DC265"), mat("8A6A44")
    LEA, GOLD, IKET, BOOT = mat("7A4E2A"), mat("C98A2B"), mat("E7D27C"), mat("5E4630")
    CREAM = mat("F4EFD8")
    h = HF(50, 31 - u)
    # quiver behind the far shoulder
    qp = [(64, 32), (62, 48), (59, 64)]
    qw = [9, 10, 10]
    for i in range(4):
        sx = 59 + i * 2.6
        cv.paint(L([(sx + 1.5, 30), (sx + 1.5 + (i - 1.5) * 0.4, 21 - (i % 2))]), LEA[1], over_only=False)
        cv.fill(poly([(sx + 0.5, 22 - (i % 2)), (sx + 3.5, 22 - (i % 2)), (sx + 3.2, 28), (sx + 0.8, 28)]), CREAM, dith=False)
        cv.put(sx + 2, 21 - (i % 2), hexc("D93848"))
    qm = tube(qp, qw)
    cv.fill(qm, LEA, lam=tube_lam(qp, qw), sep=True)
    cv.paint(AND(qm, L([(57, 34), (68, 34)], 2)), GOLD[1])
    # legs: weight on the left leg, right foot forward
    pl = [(41, 63), (40, 91), (37, 114)]
    pr = [(55, 63), (60, 90), (67, 114)]
    leg(cv, pl, PANT, wraps=97)
    leg(cv, pr, PANT, wraps=97)
    boot(cv, 36, -1, BOOT, GOLD[1], 121)
    boot(cv, 68, 1, BOOT, GOLD[1], 123)
    # tunic with batik hem
    tm = poly([(34, 37 - u), (60, 36 - u), (59, 50), (61, 75), (62 + sw, 80), (48, 82), (33 + sw, 80), (35, 75), (36, 50)])
    cv.fill(tm, GRN, sep=True)
    folds(cv, tm, GRN, [[(40, 62), (38, 76)], [(54, 62), (56, 76)], [(47, 66), (47, 77)], [(37, 46), (40, 54)]])
    hem = AND(tm, poly([(30, 75), (66, 75), (66, 84), (30, 84)]))
    cv.fill(hem, mat("4F8A3E"), pat=(kawung(1, 0), hexc("E7D27C")), sep=True, dith=False)
    cv.fill(poly([(36, 58), (59, 58), (59, 63), (36, 63)]), GOLD, sep=True, dith=False)
    cv.paint(L([(37, 59), (58, 59)]), GOLD[0])
    cv.fill(ell(47.5, 60.5, 3, 3), mat("F2B84B"), sep=True)
    cv.fill(poly([(54, 62), (62, 62), (62, 71), (54, 71)]), LEA, sep=True)
    cv.paint(L([(55, 64), (61, 64)]), LEA[0])
    # chest strap
    sm = L([(57, 38 - u), (38, 62)], 3)
    cv.fill(AND(sm, tm), LEA, dith=False)
    cv.fill(ell(48, 50, 2.2, 2.2), mat("F2B84B"), sep=True)
    # leaf collar
    cm = poly([(40, 35 - u), (56, 34 - u), (58.5, 40 - u), (54, 40 - u), (51, 45 - u), (48, 42 - u), (45, 45 - u), (42, 40 - u), (37.5, 40 - u)])
    neck(cv, h)
    cv.fill(cm, LEAF, sep=True)
    cv.paint(AND(cm, L([(41, 37 - u), (48, 42 - u), (55, 36 - u)])), LEAF[2])
    # bow held diagonally in the near hand
    t1, t2 = (37.0, 28.0), (19.0, 108.0)
    dx, dy = t2[0] - t1[0], t2[1] - t1[1]
    ln = math.hypot(dx, dy)
    nx, ny = -dy / ln, dx / ln
    if nx > 0:
        nx, ny = -nx, -ny
    bp, bw = [], []
    for i in range(0, 21):
        t = i / 20.0
        b = 7.5 * (1 - (2 * t - 1) ** 2)
        bp.append((t1[0] + dx * t + nx * b, t1[1] + dy * t + ny * b))
        bw.append(2.6 + 3.0 * (1 - abs(2 * t - 1)))
    bm = tube(bp, bw)
    cv.paint(L([t1, t2]), hexc("EFE6C8"), over_only=False)
    cv.fill(bm, LEA, lam=tube_lam(bp, bw), sep=True, dith=False)
    cv.paint(AND(bm, L([(bp[10][0] + 1, bp[10][1] - 5), (bp[10][0] + 1, bp[10][1] + 5)])), LEA[0])
    cv.fill(tube([bp[9], bp[11]], [5.5, 5.5]), GOLD, sep=True, dith=False)
    cv.fill(tube([bp[0], bp[1]], [3.6, 3]), GOLD, sep=True, dith=False)
    # far (right) arm holds an arrow low
    r1 = [(60, 37 - u), (66, 51), (62, 60)]
    rw = [10, 9, 8]
    ar = L([(60, 62), (72, 99)])
    cv.paint(ar, hexc("D9C79A"), over_only=False)
    cv.fill(poly([(70, 98), (74, 98), (73, 105), (71, 105)]), mat("C9D3DF"), dith=False, sep=True)
    for k in range(3):
        cv.paint(L([(60 + k * 0.7 - 2, 61 + k * 2), (61 + k * 0.7, 66 + k * 2)]), CREAM[1], over_only=False)
    cv.paint(L([(62, 63), (62, 66)]), hexc("D93848"), over_only=False)
    cv.fill(tube(r1, rw), GRN, lam=tube_lam(r1, rw), sep=True)
    r2 = [(66, 53), (63, 59), (61, 62)]
    r2w = [7, 6.5, 6]
    cv.fill(tube(r2, r2w), SKIN, lam=tube_lam(r2, r2w), sep=True)
    cv.fill(tube([(65, 55), (63.5, 58)], [8, 7.6]), LEA, sep=True, dith=False)
    fist(cv, 60.5, 62.5, 3.5)
    # near arm along the bow
    a1 = [(33, 38 - u), (27, 52), (24, 60)]
    aw = [11, 9.5, 8]
    cv.fill(tube(a1, aw), GRN, lam=tube_lam(a1, aw), sep=True)
    a2 = [(25, 58), (22.5, 64), (21.5, 67)]
    a2w = [7.5, 6.5, 6]
    cv.fill(tube(a2, a2w), SKIN, lam=tube_lam(a2, a2w), sep=True)
    cv.fill(tube([(25, 59), (23.5, 62.5)], [8, 7.6]), LEA, sep=True, dith=False)
    fist(cv, 21.5, 69, 3.7)
    if f in (2, 3):
        star(cv, int(bp[0][0]), int(bp[0][1]) - 1, 2 if f == 3 else 1)
    if f == 4:
        star(cv, 72, 104, 1)
    # head
    hair_mass(cv, h)
    cv.fill(h.ell(0.5, -17.5, 3.4, 3.2), HAIR, sep=True, dith=False)
    cv.paint(h.L([(-2, -19), (0, -20), (2, -19)]), HAIR_HI)
    face(cv, h, brow="flat")
    for sd in (-1, 1):
        lk = h.poly([(sd * 7.6, -11), (sd * 6.4, -11), (sd * 6.2, -5), (sd * 6.8, -3), (sd * 8, -6)])
        cv.fill(lk, HAIR, dith=False)
    ik = h.poly([(-7.6, -10.5), (-7.4, -14.5), (0, -16.8), (7.6, -14.5), (7.8, -10.5), (0, -13)])
    cv.fill(ik, IKET, sep=True, dith=False)
    cv.paint(AND(ik, h.L([(-7, -12.5), (0, -14.8), (7, -12.5)])), IKET[2])
    cv.paint(AND(ik, h.L([(-7, -14.5), (-3, -16), (0, -16.5)])), IKET[0])
    tl = h.poly([(6, -13.5), (10, -12.5), (12 + sw, -5), (13 + sw2, 3), (10 + sw, 3.5), (9 + sw, -4)])
    cv.fill(tl, IKET, sep=True)
    cv.paint(AND(tl, h.L([(10 + sw, -6), (11 + sw2, 2)])), IKET[2])
    cv.paint(AND(tl, h.L([(8, -10), (10 + sw, -4)])), hexc("D93848"))
    cv.paint(h.L([(2, -20.6), (-3, -14)]), GOLD[1], over_only=False)


# ----------------------------------------------------------------------------------------------- ROGUE
def rogue(cv, f):
    u, sw, sw2 = BR[f], SW[f], SW2[f]
    IND, DK2, CLOTH = mat("4B446E"), mat("2D2847"), mat("3A3460")
    SASH, MET, BOOT = mat("D93848"), mat("9AA6BC"), mat("3A2A33")
    h = HF(54, 36 - u)
    # scarf tail streaming back from the knot
    tp = h.m([(-7, -12), (-12, -10), (-19 + sw, -2), (-26 + sw2, 8), (-21 + sw, 11), (-17 + sw2, 3), (-9, -5)])
    tl = poly(tp)
    cv.fill(tl, CLOTH, sep=True)
    cv.paint(AND(tl, L([(h.x - 11, h.y - 8), (h.x - 20 + sw, h.y + 2), (h.x - 24 + sw2, h.y + 8)])), CLOTH[3])
    cv.paint(AND(tl, L([(h.x - 10, h.y - 10), (h.x - 17 + sw, h.y - 1)])), CLOTH[0])
    # kujang behind the far shoulder
    kj = [(63, 44), (67, 33), (71, 25)]
    kw = [3.4, 3.2, 3]
    cv.fill(tube(kj, kw), MET, lam=tube_lam(kj, kw), sep=True, dith=False)
    cv.fill(poly([(71, 25), (76, 22), (74, 27), (77, 28), (72, 31)]), MET, sep=True, dith=False)
    cv.fill(tube([(62, 46), (65, 39)], [4, 4]), DK2, sep=True, dith=False)
    spec(cv, 70, 27)
    # crouched legs: back leg straight, front knee bent
    pl = [(42, 66), (33, 90), (24, 113)]
    pr = [(55, 66), (66, 86), (62, 112)]
    leg(cv, pl, DK2, wraps=97)
    leg(cv, pr, DK2, wraps=95)
    boot(cv, 23, -1, BOOT, SASH[1], 122)
    boot(cv, 63, 1, BOOT, SASH[1], 123)
    # sash tails flying back
    for pts in ([(40, 63), (32 + sw, 70), (24 + sw2, 80), (28 + sw, 83), (36, 74), (42, 68)], [(42, 64), (36 + sw, 78), (30 + sw2, 92), (36 + sw, 90), (44, 74)]):
        cv.fill(poly(pts), SASH, sep=True)
    # leaning torso
    tm = poly([(36, 42 - u), (64, 40 - u), (62, 53), (59, 66), (40, 66), (38, 53)])
    cv.fill(tm, IND, sep=True)
    folds(cv, tm, IND, [[(43, 52), (44, 62)], [(56, 50), (55, 60)], [(48, 48), (48, 56)], [(38, 48), (41, 56)]], hi=False)
    cv.paint(AND(tm, L([(37, 43 - u), (63, 41 - u)])), IND[0])
    sm = L([(60, 42 - u), (41, 64)], 3)
    cv.fill(AND(sm, tm), DK2, dith=False)
    for k in range(4):
        kx, ky = 57 - k * 4.6, 46 + k * 4.8 - u
        cv.paint(L([(kx, ky - 3), (kx - 1, ky + 1)]), MET[0], over_only=False)
        cv.put(kx, ky - 3, mat("F2B84B")[1])
    sh = poly([(38, 58), (62, 58), (60, 66), (40, 66)])
    cv.fill(sh, SASH, sep=True)
    cv.paint(AND(sh, L([(39, 60), (61, 60)])), SASH[0])
    cv.fill(ell(42, 63, 3.6, 3.2), SASH, sep=True)
    cv.paint(L([(40, 63), (44, 63)]), SASH[3])
    # back arm, guard hand low
    a1 = [(38, 44 - u), (30, 56), (32, 64)]
    w1 = [10, 8.5, 7.5]
    cv.fill(tube(a1, w1), IND, lam=tube_lam(a1, w1), sep=True)
    cv.fill(tube([(30.5, 59), (32, 64)], [8.5, 8]), DK2, sep=True, dith=False)
    fist(cv, 33, 68, 3.3)
    # forward arm: reverse-grip keris
    kris = []
    for i in range(0, 15):
        t = i / 14.0
        kris.append((75 + 2.3 * math.sin(t * 3.2 * math.pi), 63 + t * 27))
    kw2 = [7.0 - 5.6 * (i / 14.0) ** 1.4 for i in range(15)]
    km = tube(kris, kw2)
    cv.fill(km, mat("8E9BB3"), lam=tube_lam(kris, kw2), sep=True, dith=False, bands=(0.85, 0.5, 0.25))
    cv.paint(AND(km, dots([(int(p[0]) + 1, int(p[1])) for p in kris[2:13:2]])), hexc("F4F8FC"))
    cv.paint(AND(km, dots([(int(p[0]) - 1, int(p[1])) for p in kris[3:13:3]])), MET[3])
    spec(cv, 74, 70)
    cv.fill(tube([(75, 61), (75, 64.5)], [6.5, 6]), mat("F2B84B"), sep=True, dith=False)
    cv.fill(tube([(75, 51), (75, 56)], [4, 3.6]), mat("7A4E2A"), sep=True, dith=False)
    cv.fill(ell(75, 49.5, 2.6, 2.2), mat("F2B84B"), sep=True)
    ua = [(63, 44 - u), (71, 55), (74, 58)]
    uw = [10, 8.5, 7.5]
    cv.fill(tube(ua, uw), IND, lam=tube_lam(ua, uw), sep=True)
    cv.fill(tube([(72.5, 56), (74.5, 58)], [8, 7.6]), DK2, sep=True, dith=False)
    fist(cv, 75, 58.5, 3.8)
    if f in (2, 3, 4):
        i = int((0.3, 0.55, 0.8)[f - 2] * 14)
        star(cv, int(kris[i][0]) + 1, int(kris[i][1]), 2 if f == 3 else 1)
    # head: headcloth, narrow eyes, mask scarf
    hair_mass(cv, h)
    neck(cv, h)
    face(cv, h, brow="frown", eyes="narrow")
    mk = h.poly([(-7, -3.5), (-3, -2.7), (0.5, -2.5), (4, -2.7), (7, -3.5), (5.5, -1), (2.5, 1.2), (-2, 1.2), (-5, -1)])
    cv.fill(mk, CLOTH, sep=True, bands=(0.95, 0.55, 0.3))
    cv.paint(AND(mk, h.L([(-5, -0.5), (0, 0.8), (5, -0.5)])), CLOTH[3])
    cv.paint(AND(mk, h.L([(-6, -3), (0, -2), (6, -3)])), CLOTH[0])
    hc = h.poly([(-7.8, -10.5), (-7.8, -14), (-5.5, -17), (-1.5, -18.8), (3, -18.8), (6.5, -17), (8, -14), (8, -10.5), (5, -11.5), (0, -12.2), (-5, -11.5)])
    cv.fill(hc, CLOTH, sep=True)
    cv.paint(AND(hc, h.L([(-7.8, -11), (0, -12.5), (8, -11)])), CLOTH[3])
    cv.paint(AND(hc, h.L([(-6, -15.5), (-3, -17.5), (1, -18.2)])), CLOTH[0])
    cv.fill(h.ell(-7.5, -12.5, 3, 2.7), SASH, sep=True)
    cv.paint(h.L([(-9, -13), (-6, -12)]), SASH[3])


# ----------------------------------------------------------------------------------------------- MAGE
GLYPH = [".x.x.",
         "xxxxx",
         "x...x",
         ".xxx.",
         "..x.."]
GLYPH_BIG = ["...x...",
             ".xxxxx.",
             "x..x..x",
             "x.xxx.x",
             "x..x..x",
             ".xxxxx.",
             "...x..."]


def mage(cv, f):
    u, sw, sw2 = BR[f], SW[f], SW2[f]
    TEAL, CREAM, GOLD = mat("1E8C8F"), mat("BFF3FF"), mat("F2B84B")
    LEA = mat("7A4E2A")
    h = HF(50, 31 - u)
    # long hair behind
    hm = poly([(41, 18 - u), (59, 17 - u), (61, 38), (61, 66), (54, 72), (47, 70), (41, 72), (36, 66), (38, 38)])
    cv.fill(hm, HAIR, sep=True)
    cv.paint(AND(hm, L([(40, 38), (38, 62)])), HAIR_HI)
    cv.paint(AND(hm, L([(59, 40), (59, 64)])), HAIR[3])
    # staff, planted at the right
    sp = [(76, 14), (76, 122)]
    cv.fill(tube(sp, [3.4, 3.4]), LEA, lam=tube_lam(sp, [3.4, 3.4]), sep=True, dith=False)
    for yy in (24, 42, 98):
        cv.paint(L([(74, yy), (78, yy)], 1), GOLD[1], over_only=False)
    cv.fill(poly([(74, 118), (78, 118), (77, 123), (75, 123)]), GOLD, dith=False)
    cv.fill(poly([(70, 18), (72, 18), (73, 12), (71, 8), (69, 12)]), GOLD, sep=True, dith=False)
    cv.fill(poly([(80, 18), (82, 18), (83, 12), (81, 8), (79, 12)]), GOLD, sep=True, dith=False)
    cv.fill(poly([(73, 20), (79, 20), (78, 16), (74, 16)]), GOLD, sep=True, dith=False)
    # robe: asymmetric hem, near knee forward
    rp = [(34, 37 - u), (61, 35.5 - u), (59, 50), (57, 62), (61, 82), (65 + sw, 102), (68 + sw, 119), (60, 121), (49, 120), (38, 123), (27 + sw, 123), (29, 103), (33, 82), (38, 62), (36, 50)]
    rm = poly(rp)
    cv.fill(rm, TEAL, sep=True, pat=(gate(kawung(2, 1), 109, 124), hexc("F2B84B")))
    cv.paint(AND(rm, L([(27, 110), (48, 109), (68, 107)], 1)), GOLD[1])
    cv.paint(AND(rm, L([(27, 109), (48, 108), (68, 106)], 1)), GOLD[0])
    folds(cv, rm, TEAL, [[(41, 66), (35, 106)], [(46, 70), (43, 108)], [(54, 68), (56, 106)], [(58, 74), (63, 104)], [(37, 54), (39, 62)], [(36, 80), (30, 104)]])
    vm = poly([(43.5, 36 - u), (52.5, 35.5 - u), (50, 49 - u), (48, 58), (46, 49 - u)])
    cv.fill(vm, CREAM, flat=1, dith=False)
    cv.paint(L([(43, 37 - u), (46.5, 49 - u), (48, 60)]), GOLD[1])
    cv.paint(L([(53, 36 - u), (50, 49 - u), (48, 60)]), GOLD[2])
    cv.paint(AND(rm, L([(48, 62), (47, 108)])), TEAL[3])
    sh = poly([(37, 56), (59, 56), (58, 63), (38, 63)])
    cv.fill(sh, GOLD, pat=(ceplok, hexc("A8701C")), sep=True)
    tl = poly([(55, 62), (59, 62), (60 + sw, 80), (62 + sw2, 94), (56 + sw, 92), (56, 78)])
    cv.fill(tl, GOLD, sep=True)
    cv.paint(AND(tl, L([(58 + sw, 90), (62 + sw2, 92)], 2)), GOLD[3])
    cv.fill(ell(48, 59.5, 2.4, 2.4), CREAM, sep=True)
    spec(cv, 47, 58)
    cv.fill(poly([(30, 121), (38, 121), (40, 124), (28, 124)]), mat("3A2A33"), dith=False)
    cv.fill(poly([(52, 120), (60, 120), (60, 122), (52, 122)]), mat("3A2A33"), dith=False)
    # raised palm (near arm), glowing aksara above it
    ls = [(33, 38 - u), (28, 52), (24, 49)]
    lw = [11, 12, 13]
    cv.fill(tube(ls, lw), TEAL, lam=tube_lam(ls, lw), sep=True)
    folds(cv, tube(ls, lw), TEAL, [[(31, 44), (27, 51)], [(29, 49), (26, 54)]])
    cv.paint(AND(tube(ls, lw), L([(18, 47), (30, 52)], 2)), GOLD[1])
    hand_open(cv, 23.5, 45)
    # staff arm
    rs = [(61, 37 - u), (70, 50), (75, 58)]
    rw = [10, 11, 10]
    cv.fill(tube(rs, rw), TEAL, lam=tube_lam(rs, rw), sep=True)
    folds(cv, tube(rs, rw), TEAL, [[(67, 46), (71, 56)], [(64, 44), (67, 52)]])
    cv.paint(AND(tube(rs, rw), L([(70, 59), (79, 56)], 2)), GOLD[1])
    fist(cv, 76, 62, 3.4)
    # orb
    ph = 0.5 + 0.5 * math.sin(2 * math.pi * f / 6)
    cv.fill(ell(76, 13, 5.2, 5.2), mat("57C7BE"), lam=lambda x, y: 0.5 + 0.5 * (-0.6 * (x - 76) / 5 - 0.7 * (y - 13) / 5) + 0.2 * ph, sep=True, dith=False, bands=(0.85, 0.55, 0.3))
    for gy, row in enumerate(GLYPH):
        for gx, ch in enumerate(row):
            if ch == "x":
                cv.put(74 + gx, 11 + gy, mix(hexc("F4FFFF"), hexc("BFF3FF"), 1 - ph))
    # head
    neck(cv, h)
    face(cv, h, brow="arch")
    fr = h.poly([(-7, -10.5), (-6.5, -14), (0, -15.5), (6.5, -14), (7, -10.5), (5, -11.5), (2, -12.8), (-3, -12.8)])
    cv.fill(fr, HAIR, dith=False)
    cv.paint(h.L([(-5, -14), (0, -15), (5, -14)]), HAIR_HI)
    cr = h.poly([(-7, -11), (-7, -15), (-4.5, -18.5), (-2.5, -14), (0, -20), (2.5, -14), (4.8, -18.5), (7.2, -15), (7.2, -11), (0, -12.3)])
    cv.fill(cr, GOLD, sep=True, dith=False)
    cv.paint(AND(cr, h.L([(-6.5, -12.2), (0, -13.2), (6.5, -12.2)])), GOLD[2])
    for px_, py_ in ((-4.5, -19.5), (0, -21), (4.8, -19.5)):
        cv.fill(h.ell(px_ + 0.5, py_ + 0.5, 1.5, 1.5), mat("F4F8FC"), dith=False)
        cv.put(h.x + px_ - 0.5, h.y + py_ - 0.5, hexc("FFFFFF"))
    cv.fill(h.ell(0.5, -13.5, 1.5, 1.5), mat("F2B84B"), sep=True, dith=False)
    cv.put(h.x, h.y - 14, hexc("FFFFFF"))
    for side in (0, 1):
        lk = h.poly([(-7.8 + side * 15.6, -10), (-6.5 + side * 13, -10), (-6.4 + side * 12.8, 5), (-7.5 + side * 15, 14), (-9 + side * 18, 5)])
        cv.fill(lk, HAIR, sep=True, dith=False)
        cv.paint(AND(lk, h.L([(-7.2 + side * 14.4, -8), (-7.6 + side * 15.2, 8)])), HAIR_HI)


# ----------------------------------------------------------------------------------------------- finish
def finish(cv, glow=None, shx=48):
    p = cv.p
    q = list(p)
    for y in range(H):
        for x in range(W):
            c = p[y * W + x]
            if c is None:
                continue
            re = x + 1 >= W or p[y * W + x + 1] is None
            re2 = x + 2 >= W or p[y * W + x + 2] is None
            le = x - 1 < 0 or p[y * W + x - 1] is None
            if re:
                q[y * W + x] = mix(c, RIM, 0.55)
            elif re2 and x + 1 < W:
                q[y * W + x] = mix(c, RIM, 0.16)
            elif le:
                q[y * W + x] = mix(c, (255, 220, 160), 0.18)
    out = list(q)
    for y in range(H):
        for x in range(W):
            if p[y * W + x] is not None:
                continue
            best = None
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < W and 0 <= ny < H and p[ny * W + nx] is not None:
                    c = p[ny * W + nx]
                    if best is None or sum(c) < sum(best):
                        best = c
            if best:
                out[y * W + x] = mix(OUT, shade(best, 0.32), 0.45)
    img = [(c[0], c[1], c[2], 255) if c else (0, 0, 0, 0) for c in out]
    # ground contact shadow (dark, ~40% alpha, softer rim)
    for y in range(113, 128):
        for x in range(8, 90):
            d = ((x + 0.5 - shx) / 30.0) ** 2 + ((y + 0.5 - 121.0) / 5.0) ** 2
            if d <= 1.0 and img[y * W + x][3] == 0:
                img[y * W + x] = (10, 8, 14, 102 if d < 0.55 else 56)
    if glow:
        glow(img)
    return img


def blend(img, x, y, col, a):
    if 0 <= x < W and 0 <= y < H and a > 0:
        i = y * W + x
        d = img[i]
        if d[3] == 0:
            img[i] = (col[0], col[1], col[2], int(255 * a))
        else:
            img[i] = (int(d[0] * (1 - a) + col[0] * a), int(d[1] * (1 - a) + col[1] * a), int(d[2] * (1 - a) + col[2] * a), d[3])


def mage_glow(f):
    ph = 0.5 + 0.5 * math.sin(2 * math.pi * f / 6)

    def g(img):
        ox, oy = 76, 13
        r_out = 8.5 + 3.2 * ph
        for y in range(0, 40):
            for x in range(54, 96):
                d = math.hypot(x + 0.5 - ox, y + 0.5 - oy)
                if 5.6 < d < r_out + 3:
                    a = (0.34 * ph + 0.14) * max(0.0, 1 - (d - 5.6) / (r_out + 3 - 5.6)) ** 1.6
                    blend(img, x, y, hexc("9EF2FF"), round(a * 5) / 5)
        # glowing aksara floating above the raised palm
        gx0, gy0 = 20, int(28 - round(1.2 * math.sin(2 * math.pi * f / 6)))
        cx, cy = gx0 + 3.5, gy0 + 3.5
        for y in range(gy0 - 6, gy0 + 14):
            for x in range(gx0 - 6, gx0 + 14):
                d = math.hypot(x + 0.5 - cx, y + 0.5 - cy)
                if 4.5 < d < 10:
                    blend(img, x, y, hexc("9EF2FF"), round(0.42 * (0.55 + 0.45 * ph) * (1 - (d - 4.5) / 5.5) * 4) / 4)
        for yy, row in enumerate(GLYPH_BIG):
            for xx, ch in enumerate(row):
                if ch == "x":
                    blend(img, gx0 + xx, gy0 + yy, hexc("EFFFFF"), 0.75 + 0.25 * ph)
        for k in range(4):
            t = ((f / 6.0) + k * 0.25) % 1.0
            sx = 76 + 8 * math.sin(2 * math.pi * (t + k * 0.3))
            blend(img, int(sx), int(20 - 18 * t), hexc("EFFFFF"), 0.9 * (1 - t))
    return g


# ----------------------------------------------------------------------------------------------- PNG
def png_bytes(w, h, px):
    raw = bytearray()
    for y in range(h):
        raw.append(0)
        for x in range(w):
            raw.extend(px[y * w + x])

    def chunk(tag, data):
        c = struct.pack(">I", len(data)) + tag + data
        return c + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)) + chunk(b"IDAT", zlib.compress(bytes(raw), 9)) + chunk(b"IEND", b"")


SHADOW_X = {"warrior": 44, "archer": 52, "rogue": 44, "mage": 50}


def strip(name, fn, with_glow=False):
    px = [(0, 0, 0, 0)] * (W * NF * H)
    for f in range(NF):
        cv = Cv()
        fn(cv, f)
        img = finish(cv, mage_glow(f) if with_glow else None, SHADOW_X[name])
        for y in range(H):
            for x in range(W):
                px[y * W * NF + f * W + x] = img[y * W + x]
    return px


def main():
    os.makedirs(OUTDIR, exist_ok=True)
    strips = []
    for name, fn, gl in (("warrior", warrior, False), ("archer", archer, False), ("rogue", rogue, False), ("mage", mage, True)):
        px = strip(name, fn, gl)
        path = os.path.join(OUTDIR, f"class_{name}.png")
        with open(path, "wb") as fh:
            fh.write(png_bytes(W * NF, H, px))
        strips.append(px)
        print("wrote", path)
    S = 2
    pw, ph = W * NF * S + 16, (H * S + 8) * 4 + 8
    bg = (20, 15, 26, 255)
    prev = [bg] * (pw * ph)
    for i, px in enumerate(strips):
        oy = 8 + i * (H * S + 8)
        for y in range(H * S):
            for x in range(W * NF * S):
                c = px[(y // S) * W * NF + x // S]
                if c[3]:
                    prev[(oy + y) * pw + 8 + x] = (c[0], c[1], c[2], 255) if c[3] == 255 else tuple(int(bg[k] * (1 - c[3] / 255) + c[k] * c[3] / 255) for k in range(3)) + (255,)
    with open(PREVIEW, "wb") as fh:
        fh.write(png_bytes(pw, ph, prev))
    print("wrote", PREVIEW)


if __name__ == "__main__":
    main()
