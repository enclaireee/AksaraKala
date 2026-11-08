#!/usr/bin/env python3
"""Aksara Kala class-select figures (96x128, 6-frame idle each).

Outputs assets/art/portraits/class_{warrior,archer,rogue,mage}.png (each a 576x128 strip of 6 frames of 96x128)
and tools/portraits_preview.png (all four strips at 2x on a dark ground).
Identity (.docs/classes.md "Identity"): Hulubalang (warrior), Pamanah (archer), Pendekar (rogue), Wiku (mage).
Pure Python (no Pillow needed): masks are bytearrays, shading is procedural with hue-shifted 4-tone ramps and one
key light from the top-left, a coloured 1 px ink outline, and the same skin ramps as the speaker portraits
(tools/gen_speaker_portraits.py). The in-world sprites (tools/gen_hero_sprites.py) follow the same palettes.
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
import struct  # noqa: E402

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



def star(cv, x, y, size=2, col=hexc("FFFFFF"), edge=hexc("FFE9A8")):
    cv.put(x, y, col)
    for k in range(1, size + 1):
        for dx, dy in ((k, 0), (-k, 0), (0, k), (0, -k)):
            cv.put(x + dx, y + dy, col if k == 1 else edge)



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



# ------------------------------------------------------------------------------------------ colour
def mat(h, warm=(255, 228, 165), cool=(96, 44, 92)):
    """Hue-shifted 4-tone ramp: highlights toward warm yellow, shadows toward red-violet."""
    b = hexc(h)
    hi = mix(shade(b, 1.22), warm, 0.22)
    shd = mix((int(b[0] * 0.70), int(b[1] * 0.66), int(b[2] * 0.72)), cool, 0.16)
    deep = mix((int(b[0] * 0.44), int(b[1] * 0.40), int(b[2] * 0.48)), (44, 22, 50), 0.32)
    return (hi, b, shd, deep)


def R(*c):
    return tuple(hexc(x) for x in c)


# same ramps as the face portraits (../portraits/proto_portraits.py)
SAWO = R("E8B27E", "C4844F", "92543A", "5E2F2E")
LANGSAT = R("F6D2A6", "E3A877", "B8704F", "7A3E3A")
HAIR = R("5A4A5E", "2E2432", "1C1520", "120C14")
INK = hexc("2A1C12")
EYE = hexc("1E1218")
WHITE = hexc("FFF6E6")

RED, DRED = mat("9E2B25"), mat("6B1E1A")
LEA, DLEA = mat("5A3A22"), mat("3E2717")
STEEL = mat("B8C0C0", cool=(70, 70, 120))
COPPER, GOLD = mat("B8743A"), mat("C9A24A")
PAPER, PAPER_S = mat("E3D0A0"), mat("B89B6A")
VERD, DVERD = mat("3F7A66", cool=(40, 40, 90)), mat("24493D", cool=(30, 30, 70))
BAMBOO, CREAM = mat("B8964E"), mat("E8DDB8")
PANGSI = R("55525E", "34303A", "231F29", "16121A")
PANGSI2 = mat("2F3A44", cool=(30, 30, 70))
WOOD = mat("6E4A2A")

BR = [0, 0, 1, 1, 1, 0]          # breathing rise
SW = [0, 1, 1, 0, -1, -1]        # cloth sway
SW2 = [1, 1, 0, -1, -1, 0]


def put(cv, x, y, c):
    cv.put(int(round(x)), int(round(y)), c)


def lam_box(x0, y0, x1, y1, k=0.75):
    """Round-ish shading for a box: lit from the top-left."""
    def f(x, y):
        nx = 2 * (x + 0.5 - x0) / max(1, x1 - x0) - 1
        ny = 2 * (y + 0.5 - y0) / max(1, y1 - y0) - 1
        return 0.5 + 0.5 * (-k * nx + 0.6 * math.sqrt(max(0.0, 1 - nx * nx))) - 0.12 * ny
    return f


def pattern(cv, base, test, col):
    for i, v in enumerate(base):
        if v and cv.p[i] is not None:
            y, x = divmod(i, W)
            if test(x, y):
                cv.p[i] = col


def lum(c):
    return 0.3 * c[0] + 0.59 * c[1] + 0.11 * c[2]


def batik(cv, base, mt, test, lift=1):
    """Pattern pixels take the colour one tone lighter (lift=-1: darker) than the shaded pixel beneath."""
    for i, v in enumerate(base):
        if v and cv.p[i] is not None:
            y, x = divmod(i, W)
            if test(x, y):
                c = cv.p[i]
                k = min(range(4), key=lambda t: sum(abs(c[j] - mt[t][j]) for j in range(3)))
                cv.p[i] = mt[max(0, min(3, k - lift))]


# ------------------------------------------------------------------------------------------ face
def face(cv, h, sk, mood="calm", beard=False, look=0, brow_col=None):
    """Chin at h(0,0); face rows -14..0. 2x2 dark eyes with a 1 px catch-light (no sclera), nose shadow, lips."""
    fm = h.poly([(-6.6, -14), (6.2, -14), (6.8, -8), (6.0, -4.5), (3, -0.4), (0.0, 0.6), (-3, -0.4), (-5.8, -4), (-7, -8)])
    hx, hy = h.x, h.y

    def fl(x, y):
        nx = (x + 0.5 - hx + 0.3) / 7.0
        return 0.62 + 0.5 * (-0.55 * nx) - 0.35 * max(0, nx - 0.45) - 0.02 * max(0, (y - hy + 3))
    cv.fill(fm, sk, lam=fl, bands=(0.86, 0.45, 0.1), dith=False)
    cv.fill(h.ell(-7.0, -6.5, 1.3, 2.2), sk, flat=1, dith=False)
    cv.fill(h.ell(6.8, -6.5, 1.2, 2.1), sk, flat=2, dith=False)
    h.put(cv, -7, -6, sk[2]); h.put(cv, 7, -6, sk[3])
    p = lambda x, y, c: h.put(cv, x, y, c)
    bc = brow_col or mix(HAIR[1], sk[3], 0.3)
    lid = mix(EYE, sk[3], 0.25)
    # brows
    if mood == "hard":
        bl, brr = [(-5, -11), (-4, -10), (-3, -10), (-2, -10)], [(1, -10), (2, -10), (3, -10), (4, -11)]
    elif mood == "kind":
        bl, brr = [(-5, -10), (-4, -11), (-3, -11), (-2, -11)], [(1, -11), (2, -11), (3, -11), (4, -10)]
    else:
        bl, brr = [(-5, -10), (-4, -11), (-3, -11)], [(2, -11), (3, -11), (4, -10)]
    for x, y in bl + brr:
        p(x, y, bc)
    # eyes
    for ex, outer in ((-4, -5), (1, 3)):
        lx = ex + look
        p(outer, -9 if mood != "hard" else -8, lid)
        p(ex, -9, lid); p(ex + 1, -9, lid)
        p(lx, -8, EYE); p(lx + 1, -8, mix(WHITE, sk[0], 0.25))
        p(lx, -7, EYE); p(lx + 1, -7, EYE)
        p(ex, -6, sk[2]) if ex > 0 else None
    # nose: lit bridge on the left, shadow on the right, nostrils
    p(-1, -7, sk[0]); p(-1, -6, sk[0])
    p(0, -6, sk[2]); p(0, -5, sk[2]); p(1, -4, sk[2])
    p(-1, -4, sk[2]); p(0, -4, sk[3]); p(-2, -4, sk[1])
    # mouth
    lip = mix(hexc("8A3A36"), sk[3], 0.2)
    p(-2, -2, sk[2]); p(-1, -2, lip); p(0, -2, lip); p(1, -2, sk[3] if mood == "hard" else lip)
    p(-1, -1, sk[0]); p(0, -1, sk[1]); p(1, -1, sk[2])
    if mood == "kind":
        p(-2, -2, lip); p(2, -3, sk[2]); p(-3, -3, sk[2])
    p(-4, -4, mix(sk[1], (216, 108, 96), 0.3)); p(-3, -4, mix(sk[1], (216, 108, 96), 0.2))
    p(4, -4, mix(sk[2], (190, 84, 84), 0.25))
    if beard:
        bcol = mix(sk[2], HAIR[1], 0.5)
        for x, y in ((-4, -2), (-3, -1), (-2, 0), (-1, 0), (0, 0), (1, 0), (2, -1), (3, -2), (4, -3), (-2, -3), (1, -3), (0, -3)):
            p(x, y, bcol)
        p(-1, -3, mix(sk[2], HAIR[1], 0.3))


def neck(cv, h, sk, w=6.5):
    nm = tube([(h.x - 0.5, h.y - 3), (h.x - 0.5, h.y + 6)], [w, w + 1])
    cv.fill(nm, sk, flat=2, dith=False)
    cv.paint(AND(nm, poly([(0, h.y + 3), (h.x - 2, h.y + 3), (h.x - 2, h.y + 7), (0, h.y + 7)])), sk[1])


def hand(cv, x, y, sk, r=3.3):
    cv.fill(ell(x, y, r, r - 0.3), sk, sep=True, dith=False)
    for k in (-1.5, 0.3, 2):
        put(cv, x + k - 0.5, y + 1, sk[3])
    put(cv, x - 1.5, y - 1.5, sk[0])


def limb(cv, pts, ws, mt):
    m = tube(pts, ws)
    cv.fill(m, mt, lam=tube_lam(pts, ws), sep=True, dith=False, bands=(0.9, 0.55, 0.28))
    return m


def foot(cv, xc, yb, d, sk, strap=None):
    """Bare foot seen from the front 3/4, toes toward d."""
    m = poly([(xc - 3.5, yb - 5), (xc + 3.5, yb - 5), (xc + 3.5 + 3 * d, yb - 1.5), (xc + 4 + 3.5 * d, yb), (xc - 4 + 0.5 * d, yb), (xc - 4, yb - 2)])
    cv.fill(m, sk, sep=True, dith=False)
    cv.paint(AND(m, L([(xc - 4, yb - 1), (xc + 5 * d + 3, yb - 1)])), sk[2])
    cv.paint(AND(m, L([(xc - 3.5, yb), (xc + 7, yb)])), sk[3])
    if strap:
        cv.paint(AND(m, L([(xc - 3, yb - 3), (xc + 3, yb - 2)])), strap)
    return m


# ------------------------------------------------------------------------------------------ HULUBALANG
def tumpal(x, y, y0, size=4):
    """Row of upward triangles (tumpal border) starting at row y0."""
    r = y - y0
    if r < 0 or r >= size:
        return False
    return abs((x % (2 * size)) - size + 0.5) <= (size - r) - 0.5


def udeng(cv, h, mt, peak=(2, -23), tail=True, sw=0, sw2=0):
    """Javanese-style wrapped headcloth: dome over the hair, band at the brow, folded peak/knot at the front."""
    if tail:
        tl = poly(h.m([(-5, -15), (-8.5, -14), (-13 + sw, -6), (-13.5 + sw2, 1), (-10 + sw, 0.5), (-8.5, -8)]))
        cv.fill(tl, mt, sep=True, lam=lambda x, y: 0.4 - 0.3 * ((x - h.x + 9) / 5.0))
        cv.paint(AND(tl, L(h.m([(-8, -12), (-11 + sw, -4), (-11 + sw2, 0)]))), mt[3])
    dome = h.poly([(-8, -9.5), (-8, -14), (-6, -17.5), (-2, -19.2), (3, -19.2), (6.5, -17.2), (8.2, -13.5), (8.2, -9.5), (4.5, -11.3), (0, -12), (-4.5, -11.3)])

    def dl(x, y):
        nx, ny = (x + 0.5 - h.x) / 8.5, (y + 0.5 - h.y + 14) / 5.5
        return 0.55 - 0.42 * nx - 0.32 * ny + 0.2 * math.sqrt(max(0, 1 - nx * nx))
    cv.fill(dome, mt, sep=True, lam=dl, bands=(0.85, 0.5, 0.2))
    # wrap folds slanting up toward the peak
    for k in (-5, -1, 4):
        cv.paint(AND(dome, h.L([(k, -11.5), (k + 2.5, -17.5)])), mt[2])
    cv.paint(AND(dome, h.L([(-8, -10.2), (-4.5, -11.6), (0, -12.4), (4.5, -11.6), (8.2, -10.2)])), mt[3])
    cv.paint(AND(dome, h.L([(-8, -11.2), (-4.5, -12.6), (0, -13.4), (4.5, -12.6), (8.2, -11.2)])), GOLD[2])
    px, py = peak
    pk = h.poly([(px - 3.5, -17.5), (px - 1.2, py + 1), (px + 0.5, py), (px + 2.2, py + 1.5), (px + 3.5, -17.5), (px, -16.2)])
    cv.fill(pk, mt, sep=True, lam=lambda x, y: 0.75 - 0.6 * ((x + 0.5 - h.x - px) / 3.5), bands=(0.85, 0.5, 0.2))
    cv.paint(AND(pk, h.L([(px + 0.5, -16.5), (px + 0.5, py + 1.5)])), mt[2])
    kn = h.ell(px, -16.6, 2.2, 1.7)
    cv.fill(kn, mt, sep=True, flat=1, dith=False)
    h.put(cv, px - 1, -17, mt[0]); h.put(cv, px + 1, -16, mt[2])


def hulubalang(cv, f):
    u, sw, sw2 = BR[f], SW[f], SW2[f]
    sk = SAWO
    h = HF(48, 31 - u)
    # tameng (round hide shield) strapped on the back, behind the right shoulder
    sx, sy = 63, 44 - u
    tm = ell(sx, sy, 14.5, 14.5)
    cv.fill(tm, WOOD, lam=lambda x, y: 0.55 + 0.5 * (-(x + 0.5 - sx) * 0.62 - (y + 0.5 - sy) * 0.78) / 14.5, bands=(0.85, 0.5, 0.18))
    ring = SUB(tm, ell(sx, sy, 11.6, 11.6))
    cv.paint(ring, DRED[1])
    for i, v in enumerate(ring):
        if v:
            y, x = divmod(i, W)
            a = math.atan2(y + 0.5 - sy, x + 0.5 - sx)
            r = math.hypot(x + 0.5 - sx, y + 0.5 - sy)
            if (int((a + math.pi) / (2 * math.pi) * 12 + (13.6 - r) * 0.35) % 2 == 0):
                cv.p[i] = CREAM[1] if -2.4 < a < 0.7 else CREAM[2]
    cv.paint(SUB(ell(sx, sy, 7.6, 7.6), ell(sx, sy, 6.5, 6.5)), DLEA[2])
    cv.fill(ell(sx, sy, 3.2, 3.2), COPPER, sep=True, dith=False)
    put(cv, sx - 1, sy - 1, COPPER[0])
    # calves with leather puttee wraps, bare feet in thong sandals
    WRAP = mat("9C7B55")
    for pts, d, fx in (([(39, 90), (36, 106), (34, 116)], -1, 33), ([(57, 90), (60, 106), (62, 116)], 1, 63)):
        m = limb(cv, pts, [8.5, 7.2, 6.2], sk)
        wr = AND(m, poly([(0, 101), (W, 101), (W, 116), (0, 116)]))
        cv.fill(wr, WRAP, lam=tube_lam(pts, [8.5, 7.2, 6.2]), dith=False, bands=(0.9, 0.55, 0.28))
        for yy in range(102, 116, 3):
            cv.paint(AND(wr, L([(pts[1][0] - 6, yy + 1 + d), (pts[1][0] + 6, yy - 1 + d)])), WRAP[3])
        foot(cv, fx, 122, d, sk, strap=LEA[2])
    # kain: wrapped below the knee, parang batik, front wiru pleats, tumpal border at the hem
    km = poly([(35, 59), (61, 59), (63, 74), (67 + sw, 96), (58, 98), (48, 97), (38, 98), (29 + sw, 96), (33, 74)])
    cv.fill(km, DRED, sep=True)
    batik(cv, km, DRED, lambda x, y: (x + y) % 6 in (0,) or ((x + y) % 6 == 3 and (x - y) % 3 == 0), lift=-1)
    hem = AND(km, poly([(0, 91), (W, 91), (W, 99), (0, 99)]))
    cv.fill(hem, RED, flat=1, dith=False)
    cv.paint(AND(hem, poly([(0, 91), (W, 91), (W, 92), (0, 92)])), GOLD[2])
    for i, v in enumerate(hem):
        if v:
            y, x = divmod(i, W)
            if tumpal(x, y, 93, 4):
                cv.p[i] = GOLD[1] if x < 50 else GOLD[2]
    folds(cv, km, DRED, [[(40, 64), (34, 90)], [(44, 70), (41, 90)], [(58, 66), (62, 90)]], hi=False)
    # wiru: overlapping front panel with stacked pleats (zig-zag edge)
    wm = poly([(47, 60), (54, 60), (55, 78), (56 + sw, 99), (50, 100), (48, 78)])
    cv.fill(wm, RED, sep=True)
    batik(cv, wm, RED, lambda x, y: (x * 2 + y) % 5 == 0, lift=1)
    for k, xx in enumerate((50, 52, 54)):
        cv.paint(AND(wm, L([(xx - 1, 62), (xx + (sw if k == 2 else 0) * 0.5, 99)])), RED[3] if k else RED[2])
    for yy in range(95, 101):
        for xx in range(48, 58):
            if wm[yy * W + xx] and yy >= 97 and (xx + yy) % 2 == 0:
                put(cv, xx, yy, RED[3])
    # torso: bare chest, V taper; pecs, sternum, abs and obliques modelled as lit bumps
    tor = poly([(33, 38 - u), (63, 38 - u), (62, 46), (58, 53), (57, 60), (39, 60), (38, 53), (34, 46)])
    tor = OR(tor, ell(34.5, 42 - u, 5.5, 5.2), ell(61.5, 42 - u, 5.5, 5.2), poly([(39, 38 - u), (57, 38 - u), (54, 35 - u), (42, 35 - u)]))
    bumps = [(42.5, 45 - u, 6.2, 4.4, 0.55), (54, 45 - u, 6.2, 4.4, 0.55), (34.5, 42 - u, 5, 4.6, 0.5), (61.5, 42 - u, 5, 4.6, 0.5),
             (45.5, 51.5, 2.6, 2.0, 0.35), (50.5, 51.5, 2.6, 2.0, 0.35), (45.5, 55.5, 2.6, 2.0, 0.35), (50.5, 55.5, 2.6, 2.0, 0.35)]

    def tl(x, y):
        x, y = x + 0.5, y + 0.5
        v = 0.6 - 0.32 * (x - 48) / 15.0
        for cx, cy, rx, ry, k in bumps:
            nx, ny = (x - cx) / rx, (y - cy) / ry
            r2 = nx * nx + ny * ny
            if r2 < 1:
                v += k * (-0.62 * nx - 0.78 * ny) * (1 - r2) ** 0.35
            elif r2 < 1.6 and ny > 0.2:
                v -= 0.12
        return v
    cv.fill(tor, sk, lam=tl, sep=True, dith=False, bands=(0.9, 0.52, 0.22))
    cv.paint(AND(tor, L([(48, 42 - u), (48, 57)])), sk[2])
    cv.paint(AND(tor, L([(37, 49 - u), (42, 50 - u), (47, 48.5 - u)])), sk[3])
    cv.paint(AND(tor, L([(49, 48.5 - u), (54, 50 - u), (59, 48 - u)])), sk[3])
    # amulet cord (rajah) with a small copper charm
    cv.paint(L([(44, 38 - u), (46, 42 - u), (48, 43 - u), (50, 42 - u), (52, 38 - u)]), INK)
    cv.fill(ell(48, 44.5 - u, 1.5, 1.8), COPPER, dith=False)
    put(cv, 47, 44 - u, COPPER[0])
    # selempang: banded baldric over the left shoulder to the right hip
    sel = poly([(33, 37 - u), (39, 37 - u), (61, 58), (55, 61)])
    cv.fill(sel, RED, sep=True, lam=lam_box(33, 37, 61, 61, 0.4))
    for k in range(5):
        t = 0.14 + k * 0.19
        x0, y0 = 36 + 22 * t, 37 - u + 22 * t
        cv.paint(AND(sel, L([(x0 - 3, y0 + 2.5), (x0 + 3, y0 - 2.5)])), GOLD[1])
    # stagen belt with copper buckle
    bm = poly([(35, 56), (61, 56), (62, 62), (34, 62)])
    cv.fill(bm, mat("2A1C12", cool=(40, 30, 60)), sep=True, lam=lam_box(34, 56, 62, 62, 0.6), dith=False)
    cv.paint(L([(35, 57), (60, 57)]), mat("4A3428")[0])
    cv.fill(poly([(44, 56.5), (51, 56.5), (51, 61.5), (44, 61.5)]), COPPER, sep=True, dith=False)
    cv.paint(L([(45, 58), (50, 58)]), COPPER[0])
    # right arm: hangs, fist rests on the belt
    ua = [(63, 40 - u), (67, 50), (64, 57)]
    m = limb(cv, ua, [10, 8.5, 7.5], sk)
    cv.paint(AND(m, L([(62, 46 - u), (69, 46 - u)], 2)), GOLD[1])
    cv.paint(AND(m, L([(62, 45 - u), (69, 45 - u)])), GOLD[0])
    m2 = limb(cv, [(65.5, 53), (62.5, 57)], [7.8, 7], LEA)
    cv.paint(AND(m2, L([(62, 54), (67, 55)])), LEA[0])
    hand(cv, 60, 59.5, sk, 3.4)
    # kelewang: single edge, slight curve, widening to a clipped tip; grip in the left fist, blade down-left
    hx_, hy_ = 30, 67
    ang = 116
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    T = lambda pts: rot(pts, hx_, hy_, ang)
    hd = T([(-6, -1.4), (3, -1.4), (3, 1.4), (-6, 1.4), (-8, 2.6), (-9, -0.5), (-7.5, -2.2)])
    cv.fill(poly(hd), WOOD, sep=True, dith=False)
    blade = T([(4, -1.2), (14, -1.5), (24, -2.4), (32, -3.6), (36, -4.0), (39, -0.2), (37.5, 2.6), (26, 2.4), (14, 1.8), (4, 1.6)])
    bl = poly(blade)
    cv.fill(bl, STEEL, lam=lambda x, y: 0.12 + 0.85 * max(0, min(1, 0.5 - 0.5 * (-(x + 0.5 - hx_) * sa + (y + 0.5 - hy_) * ca) / 3.0)), sep=True, dith=False, bands=(0.74, 0.46, 0.2))
    cv.paint(AND(bl, L(T([(5, -1.0), (35, -3.6)]))), hexc("F4F6F0"))
    cv.paint(AND(bl, L(T([(6, 1.4), (37, 2.2)]))), STEEL[3])
    cv.paint(AND(bl, L(T([(8, 0.2), (30, 0.4)]))), STEEL[2])
    cv.fill(poly(T([(2.6, -3.0), (4.4, -3.0), (4.4, 3.0), (2.6, 3.0)])), COPPER, sep=True, dith=False)
    # left arm drops to the grip
    la = [(33, 40 - u), (28, 50), (29, 58)]
    m = limb(cv, la, [10.5, 9, 8], sk)
    cv.paint(AND(m, L([(26, 46 - u), (35, 46 - u)], 2)), GOLD[1])
    cv.paint(AND(m, L([(26, 45 - u), (35, 45 - u)])), GOLD[0])
    put(cv, 30, 52, sk[3]); put(cv, 31, 53, sk[3])
    m2 = limb(cv, [(29, 57), (30, 62)], [8.2, 7.4], LEA)
    cv.paint(AND(m2, L([(26, 59), (33, 60)])), LEA[0])
    fx, fy = T([(-1.5, 0)])[0]
    hand(cv, fx, fy, sk, 3.6)
    tip = T([(34, -3.4)])[0]
    if f in (2, 3):
        star(cv, int(tip[0]), int(tip[1]), 1)
    # head
    neck(cv, h, sk, 8)
    cv.fill(h.ell(0, -9, 7.8, 8), HAIR, dith=False)
    face(cv, h, sk, mood="hard", beard=True)
    udeng(cv, h, RED, peak=(1.5, -21.5), sw=sw, sw2=sw2)


# ------------------------------------------------------------------------------------------ shared: iket, pangsi
def iket(cv, h, mt, trim=None, horns=(), knot_front=False, pat=None, trim_w=1):
    """Sundanese iket: low flat crown with two pointed corners standing up (or a forehead knot)."""
    dome = h.poly([(-8, -9.8), (-8.2, -14), (-6.5, -17.6), (-2, -18.8), (3, -18.8), (7, -17.4), (8.4, -13.5), (8.3, -9.8), (4.5, -11.4), (0, -12), (-4.5, -11.4)])

    def dl(x, y):
        nx, ny = (x + 0.5 - h.x) / 8.5, (y + 0.5 - h.y + 14) / 5.5
        return 0.55 - 0.42 * nx - 0.3 * ny + 0.2 * math.sqrt(max(0, 1 - nx * nx))
    for wp in horns:
        hm = h.poly(wp)
        cx = sum(p[0] for p in wp) / len(wp)
        cv.fill(hm, mt, sep=True, lam=lambda x, y, cx=cx: 0.7 - 0.5 * ((x + 0.5 - h.x - cx) / 3.0) - 0.15 * (y - h.y + 16) / 3, bands=(0.85, 0.5, 0.2))
        cv.paint(AND(hm, h.L([wp[0], wp[1]])), mt[3])
    cv.fill(dome, mt, sep=True, lam=dl, bands=(0.85, 0.5, 0.2))
    if pat:
        batik(cv, dome, mt, pat, lift=-1)
    for k in (-4, 1, 5):
        cv.paint(AND(dome, h.L([(k, -11.6), (k - 2, -17.5)])), mt[2])
    cv.paint(AND(dome, h.L([(-8, -10.3), (-4.5, -11.7), (0, -12.4), (4.5, -11.7), (8.3, -10.3)])), mt[3])
    if trim:
        for k in range(trim_w):
            cv.paint(AND(dome, h.L([(-8, -11.3 - k), (-4.5, -12.7 - k), (0, -13.4 - k), (4.5, -12.7 - k), (8.3, -11.3 - k)])), trim if k == 0 else mix(trim, mt[1], 0.4))
    if knot_front:
        kn = h.poly([(-3, -12), (-4.5, -16.5), (-2, -15), (0, -17.5), (1.5, -14.5), (3.5, -16), (2.5, -12)])
        cv.fill(kn, mt, sep=True, flat=1, dith=False)
        h.put(cv, -1, -14, mt[3]); h.put(cv, 0, -13, mt[3]); h.put(cv, -3, -15, mt[0])
        if trim:
            h.put(cv, -4, -16, trim); h.put(cv, 3, -15, trim)


def pangsi_leg(cv, hip, knee, cuff, mt, wide=(14, 13, 12.5)):
    """Loose three-quarter calana pangsi leg: straight-ish tube that flares at a cut cuff."""
    pts = [hip, knee, cuff]
    m = tube(pts, list(wide))
    cv.fill(m, mt, lam=tube_lam(pts, list(wide)), sep=True, bands=(0.92, 0.58, 0.3))
    return m


def bow_pts(top, bot, bulge, n=24):
    """Gendewa: a simple arc that recurves at both tips (bulge<0 bends to the left)."""
    out = []
    for i in range(n + 1):
        t = i / n
        x = top[0] + (bot[0] - top[0]) * t + bulge * math.sin(math.pi * t)
        y = top[1] + (bot[1] - top[1]) * t
        if t < 0.1:
            x -= bulge * 0.9 * (0.1 - t) / 0.1
        if t > 0.9:
            x -= bulge * 0.9 * (t - 0.9) / 0.1
        out.append((x, y))
    return out


# ------------------------------------------------------------------------------------------ PAMANAH
def pamanah(cv, f):
    u, sw, sw2 = BR[f], SW[f], SW2[f]
    sk = SAWO
    h = HF(49, 30 - u)
    look = [0, 0, -1, -1, 0, 0][f] if f else 0
    # bamboo quiver (bumbung) slanting up behind the right shoulder, fletched arrows
    for i, (ax, ay) in enumerate(((68.5, 15), (72, 17))):
        cv.paint(L([(ax - 1.5, ay + 8), (ax - 4, ay + 18)]), WOOD[1], over_only=False)
        fm = poly([(ax - 1.8, ay + 1), (ax + 0.8, ay + 2), (ax + 0.3, ay + 8), (ax - 2.2, ay + 7)])
        cv.fill(fm, CREAM, lam=lambda x, y, ax=ax: 0.6 - 0.5 * (x - ax + 1), dith=False, bands=(0.9, 0.45, 0.1))
        cv.paint(AND(fm, L([(ax - 0.5, ay + 1), (ax - 1, ay + 8)])), WOOD[2])
        put(cv, ax - 1, ay + 3, RED[2])
    qp = [(57, 70), (65, 46), (70.5, 26)]
    qw = [7, 7, 7]
    qm = tube(qp, qw)
    cv.fill(qm, BAMBOO, lam=tube_lam(qp, qw), sep=True, bands=(0.85, 0.52, 0.26))
    for t in (0.18, 0.5, 0.8):
        cx, cy = qp[0][0] + (qp[2][0] - qp[0][0]) * t, qp[0][1] + (qp[2][1] - qp[0][1]) * t
        cv.paint(AND(qm, L([(cx - 5, cy + 1), (cx + 5, cy - 1)])), BAMBOO[3])
        cv.paint(AND(qm, L([(cx - 5, cy + 2), (cx + 5, cy)])), BAMBOO[0])
    cv.paint(AND(qm, L([(66, 25), (75, 27)], 2)), BAMBOO[3])
    # legs: calana pangsi to mid-calf, bare calves and feet
    for knee, cuff, d, fx in (((42, 86), (40, 102), -1, 39), ((56, 86), (58, 102), 1, 60)):
        cx = cuff[0]
        limb(cv, [(cx, 100), (cx + 0.3 * d, 112), (cx + d, 116)], [7, 6, 5.5], sk)
        foot(cv, fx + 0.5 * d, 122, d, sk)
    PL = mat("4A3324", cool=(50, 30, 70))
    for hip, knee, cuff in (((43, 62), (42, 86), (40, 102)), ((54, 62), (56, 86), (58, 102))):
        m = pangsi_leg(cv, hip, knee, cuff, PL, (14, 13, 13))
        folds(cv, m, PL, [[(hip[0] - 2, 76), (cuff[0] - 1, 98)], [(hip[0] + 3, 70), (knee[0] + 3, 86)]], hi=False)
        cv.paint(AND(m, L([(cuff[0] - 7, cuff[1] + 1), (cuff[0] + 7, cuff[1] + 1)])), PL[3])
    cv.fill(poly([(45, 62), (53, 62), (52, 72), (46, 72)]), PL, flat=2, dith=False)
    # kampret jacket: open front, half sleeves, tied with a verdigris stagen
    J = DVERD
    jm = poly([(36, 37 - u), (62, 37 - u), (61, 50), (61, 68), (58 + sw * 0.5, 74), (40 + sw * 0.5, 74), (37, 68), (37, 50)])
    cv.fill(jm, J, sep=True, lam=lam_box(36, 36, 62, 74, 0.8), bands=(0.88, 0.54, 0.24))
    open_ = poly([(45, 36 - u), (53, 36 - u), (50.5, 50 - u), (49, 56), (47.5, 50 - u)])
    cv.fill(open_, sk, flat=2, dith=False)
    cv.paint(AND(open_, L([(46, 37 - u), (48, 48 - u)])), sk[1])
    cv.paint(L([(44.5, 36 - u), (47.5, 50 - u), (49, 57)]), J[0])
    cv.paint(L([(53.5, 36 - u), (50.5, 50 - u), (49, 57)]), J[3])
    folds(cv, jm, J, [[(40, 46), (41, 56)], [(57, 44), (56, 54)], [(42, 64), (41, 72)], [(56, 64), (57, 72)]], hi=True)
    cv.paint(AND(jm, L([(38, 72 + sw * 0), (60, 72)])), J[3])
    sash = poly([(36, 59), (62, 59), (62, 65), (36, 65)])
    cv.fill(sash, VERD, sep=True, lam=lam_box(36, 59, 62, 65, 0.7), dith=False)
    for x in range(37, 62, 3):
        put(cv, x, 62, CREAM[1] if x < 50 else CREAM[2])
    st = poly([(39, 64), (43, 64), (42 + sw, 76), (43 + sw2, 84), (38 + sw, 84), (38 + sw, 74)])
    cv.fill(st, VERD, sep=True)
    cv.paint(AND(st, L([(38 + sw, 82), (43 + sw2, 82)])), CREAM[1])
    # gourd (kele) at the right hip
    cv.fill(OR(ell(60, 72, 3.6, 4.2), ell(60, 66.5, 2.2, 2.4)), BAMBOO, sep=True, lam=lam_box(56, 62, 64, 76, 0.8))
    cv.fill(ell(60, 63.5, 1.2, 1.2), LEA, dith=False)
    # right arm: half sleeve, bare forearm, hand holds a spare arrow
    ra = [(61, 39 - u), (65, 50), (64, 58)]
    m = limb(cv, ra[:2] + [(64.6, 52)], [9, 8.2, 8], J)
    limb(cv, [(65, 51), (64, 61)], [6.8, 6], sk)
    cv.paint(L([(57, 52), (74, 80)]), WOOD[1], over_only=False)
    cv.fill(poly([(73, 78), (76, 82), (75, 84), (72, 80)]), STEEL, dith=False)
    hand(cv, 64, 62, sk, 3.2)
    # bow: gendewa held upright in the left hand, string on the inside
    bp = bow_pts((33, 24), (31, 110), -7)
    for i in range(len(bp) - 1):
        t = i / (len(bp) - 1)
        w = 3.2 if 0.3 < t < 0.7 else 2.6 if 0.12 < t < 0.88 else 2.0
        seg = tube([bp[i], bp[i + 1]], [w, w])
        cv.fill(seg, WOOD, lam=lambda x, y: 0.55 + 0.4 * (-0.6), flat=None, dith=False, bands=(0.9, 0.5, 0.2))
        cv.paint(AND(seg, L([(bp[i][0] - 0.6, bp[i][1]), (bp[i + 1][0] - 0.6, bp[i + 1][1])])), WOOD[0])
    for (x, y) in (bp[0], bp[-1]):
        cv.fill(ell(x + 0.5, y, 1.3, 1.3), BAMBOO, dith=False)
    cv.paint(L([(bp[1][0] + 1, bp[1][1]), (bp[-2][0] + 1, bp[-2][1])]), hexc("E9E2CC"), over_only=False)
    # left arm: half sleeve, leather bracer on the bow arm, fist on the grip
    la = [(36, 39 - u), (31, 50), (29.5, 54)]
    limb(cv, la, [9.6, 8.6, 8.2], J)
    m = limb(cv, [(30, 53), (27, 63)], [7, 6.4], sk)
    bm = limb(cv, [(29.6, 55.5), (27.4, 62)], [7.4, 6.8], LEA)
    cv.paint(AND(bm, L([(26, 58), (33, 58)])), LEA[0])
    cv.paint(AND(bm, L([(26, 60), (33, 60)])), LEA[3])
    gy = 66
    cv.fill(poly([(bp[12][0] - 2, gy - 4), (bp[12][0] + 2, gy - 4), (bp[12][0] + 2, gy + 4), (bp[12][0] - 2, gy + 4)]), LEA, dith=False)
    hand(cv, bp[12][0] + 0.5, gy, sk, 3.4)
    # head: iket cloth ends hang at the back of the head
    IK = mat("6A4A2E")
    for pts in ([(-6, -14), (-9.5, -13), (-11.5 + sw, -4), (-8 + sw, -3.5), (-7, -9)], [(-4, -14), (-7, -13), (-7.5 + sw2, -1), (-4.5 + sw2, -1.5), (-4.5, -10)]):
        tm_ = h.poly(pts)
        cv.fill(tm_, IK, sep=True, lam=lambda x, y: 0.45 - 0.3 * ((x - h.x + 8) / 4))
        pattern(cv, tm_, lambda x, y: (x + 2 * y) % 4 == 0, VERD[2])
    neck(cv, h, sk, 6.5)
    cv.fill(h.ell(0, -9, 7.6, 8), HAIR, dith=False)
    face(cv, h, sk, mood="calm", look=look)
    # feather tucked into the iket
    fe = poly(h.m([(6.5, -15), (9, -19), (12 + sw * 0.5, -23), (11.5, -19), (8.5, -14)]))
    cv.fill(fe, CREAM, sep=True, lam=lambda x, y: 0.8 - 0.3 * ((x - h.x - 8) / 2.0), dith=False)
    cv.paint(AND(fe, h.L([(7.5, -15), (11, -21)])), BAMBOO[2])
    h.put(cv, 11 + sw * 0.5, -22, RED[1])
    iket(cv, h, IK, trim=GOLD[2], horns=([(-0.5, -17.5), (2.5, -22.5), (4, -22), (6, -17)],))
    dome = h.poly([(-8, -9.8), (-8.2, -14), (-6.5, -17.6), (-2, -18.8), (3, -18.8), (7, -17.4), (8.4, -13.5), (8.3, -9.8)])
    pattern(cv, dome, lambda x, y: (x + 2 * y) % 4 == 0 and (x - y) % 3 == 0 and y < h.y - 13, VERD[1])


# ------------------------------------------------------------------------------------------ PENDEKAR
def kujang(cv, ox, oy, ang, size=1.0):
    """Plain working kujang: belly curving out on the edge side, a notch and hooked tip on the back, one hole."""
    T = lambda pts: rot([(x * size, y * size) for x, y in pts], ox, oy, ang)
    hd = poly(T([(-7, -1.4), (0, -1.6), (0, 1.6), (-7, 1.4), (-8.5, 0)]))
    cv.fill(hd, WOOD, sep=True, dith=False)
    cv.fill(poly(T([(-0.5, -2.4), (1.2, -2.4), (1.2, 2.4), (-0.5, 2.4)])), COPPER, sep=True, dith=False)
    bl = poly(T([(1, -1.4), (4, -1.6), (6.5, -4.4), (7.5, -1.2), (11, -1.6), (15, -2.8), (19.5, -3.6), (17.5, -0.6), (14, 2.0), (9, 3.6), (5, 3.0), (1, 1.4)]))
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    cv.fill(bl, STEEL, lam=lambda x, y: 0.15 + 0.85 * max(0, min(1, 0.55 - 0.5 * (-(x + 0.5 - ox) * sa + (y + 0.5 - oy) * ca) / (3 * size))), sep=True, dith=False, bands=(0.72, 0.45, 0.2))
    cv.paint(AND(bl, L(T([(2, 2.6), (9, 3.2), (14, 1.8), (17.5, 0.2)]))), hexc("F4F6F0"))
    hx, hy = T([(6, 0.6)])[0]
    put(cv, hx, hy, INK)
    return T([(18, -0.6)])[0]


def pendekar(cv, f):
    u, sw, sw2 = BR[f], SW[f], SW2[f]
    sk = SAWO
    h = HF(45, 40 - u)
    BLK = PANGSI
    D = 4                       # crouch: the upper body is drawn on its own layer and dropped D px
    base = cv
    cv = Cv()
    # sash tails flowing behind, to the left
    for pts in ([(39, 70), (31 + sw, 76), (23 + sw2, 88), (27 + sw, 91), (35, 80), (42, 74)],
                [(41, 72), (36 + sw, 86), (33 + sw2, 101), (38 + sw, 99), (44, 78)]):
        sm = poly(pts)
        cv.fill(sm, RED, sep=True)
        batik(cv, sm, RED, lambda x, y: (x + y) % 5 == 0, lift=-1)
    merge(base, cv, 0, D)
    cv = base
    # low wide stance: knees bent and pushed out, weight sunk
    lk, rk = (24, 98), (69, 99)
    limb(cv, [(23, 109), (22, 116)], [6.5, 5.8], sk)
    limb(cv, [(70, 109), (71, 116)], [6.5, 5.8], sk)
    foot(cv, 20, 122, -1, sk)
    foot(cv, 73, 122, 1, sk)
    ml = pangsi_leg(cv, (41, 76), lk, (23, 109), BLK, (15, 13.5, 12.5))
    mr = pangsi_leg(cv, (54, 76), rk, (70, 109), BLK, (15, 13.5, 12.5))
    folds(cv, ml, BLK, [[(37, 82), (27, 95)], [(28, 100), (25, 107)]], hi=True)
    folds(cv, mr, BLK, [[(57, 82), (66, 95)], [(67, 100), (69, 107)]], hi=True)
    cv.fill(poly([(42, 74), (54, 74), (52, 86), (44, 86)]), BLK, flat=2, dith=False)
    top = cv
    cv = Cv()
    # kampret: loose black shirt, chest cloth crossing
    jm = poly([(33, 46 - u), (60, 45 - u), (60, 58), (58, 74), (37, 74), (34, 58)])
    cv.fill(jm, BLK, sep=True, lam=lam_box(33, 44, 60, 74, 0.8), bands=(0.86, 0.55, 0.26))
    folds(cv, jm, BLK, [[(38, 56), (40, 68)], [(55, 54), (54, 66)], [(47, 60), (46, 70)]], hi=True)
    vm = poly([(42, 45 - u), (51, 45 - u), (47, 55 - u)])
    cv.fill(vm, sk, flat=2, dith=False)
    cv.paint(L([(41.5, 45 - u), (47, 56 - u), (52, 45 - u)]), CREAM[2])
    # wide red stagen/sabuk
    sm = poly([(34, 64), (60, 63), (60, 71), (35, 72)])
    cv.fill(sm, RED, sep=True, lam=lam_box(34, 63, 60, 72, 0.7))
    cv.paint(AND(sm, L([(35, 66), (59, 65)])), RED[3])
    cv.paint(AND(sm, L([(35, 69), (59, 68)])), RED[0])
    kn = poly([(37, 65), (43, 64), (44, 71), (37, 72)])
    cv.fill(kn, RED, sep=True, flat=1, dith=False)
    put(cv, 40, 67, RED[3]); put(cv, 41, 68, RED[3])
    # pouch for jamu/charms
    cv.fill(poly([(55, 70), (61, 70), (61, 77), (55, 77)]), LEA, sep=True, lam=lam_box(55, 70, 61, 77, 0.8))
    cv.paint(L([(55, 72), (60, 72)]), LEA[3])
    # back (right) arm low, kujang in reverse grip pointing back
    ra = [(59, 48 - u), (66, 58), (69, 67)]
    limb(cv, ra, [9.6, 8.6, 8.2], BLK)
    limb(cv, [(68.5, 65), (71, 72)], [7, 6.4], sk)
    cv.paint(AND(tube([(68.5, 66), (71, 72)], [7.2, 6.6]), L([(65, 69), (75, 69)])), CREAM[2])
    tip = kujang(cv, 71.5, 74.5, 76, 1.25)
    hand(cv, 71.5, 74.5, sk, 3.3)
    if f in (2, 3):
        star(cv, int(tip[0]), int(tip[1]), 1)
    # front (left) arm: silat guard, open palm up and forward
    la = [(34, 48 - u), (25, 56), (21, 51)]
    limb(cv, la[:2], [9.8, 8.8], BLK)
    limb(cv, [(25, 56), (21, 49)], [7.0, 6.4], sk)
    cv.paint(AND(tube([(25, 56), (21, 49)], [7.2, 6.6]), L([(18, 53), (28, 53)])), CREAM[2])
    pm = OR(poly([(17, 48), (23, 48), (23, 42), (17, 42)]), poly([(17, 42), (17.6, 37.5), (22.6, 37.5), (23, 42)]), ell(20, 48, 3, 2.4))
    cv.fill(pm, sk, sep=True, dith=False, lam=lambda x, y: 1.0 - 0.12 * (x - 17) - 0.01 * (y - 40), bands=(0.86, 0.45, 0.15))
    for x in (18, 20):
        cv.paint(AND(pm, L([(x + 0.5, 37), (x + 0.5, 41)])), sk[2])
    th = poly([(23, 46), (25.5, 43), (26.5, 44), (24, 48)])
    cv.fill(th, sk, sep=True, dith=False, flat=1)
    put(cv, 19, 45, sk[2]); put(cv, 21, 46, sk[2])
    # head, a touch lowered (crouch), glancing; iket knot and tails flutter behind the right side
    IK = R("4E4658", "2E2836", "201B27", "15111A")
    for pts in ([(5, -16), (9, -18), (16 + sw, -14), (17 + sw2, -11), (9, -12)], [(5, -14), (10, -13), (14 + sw2, -5), (11 + sw, -4), (7, -10)]):
        tm_ = h.poly(pts)
        cv.fill(tm_, IK, sep=True, lam=lambda x, y: 0.55 - 0.3 * ((x - h.x - 6) / 6))
        cv.paint(AND(tm_, h.L([pts[1], pts[2]])), CREAM[2])
    neck(cv, h, sk, 6.5)
    cv.fill(h.ell(0, -9, 7.6, 8), HAIR, dith=False)
    face(cv, h, sk, mood="hard", look=[0, 0, 1, 1, 0, 0][f])
    iket(cv, h, IK, trim=CREAM[1], horns=(), knot_front=False, trim_w=1)
    dome = h.poly([(-8, -9.8), (-8.2, -14), (-6.5, -17.6), (-2, -18.8), (3, -18.8), (7, -17.4), (8.4, -13.5), (8.3, -9.8)])
    pattern(cv, dome, lambda x, y: (x - y) % 4 == 0 and y < h.y - 12, mat("5A5070")[1])
    merge(top, cv, 0, D)


# ------------------------------------------------------------------------------------------ WIKU
GLYPH = ["..x...x..",
         ".x.x.x.x.",
         "x...x...x",
         "x.......x",
         ".xxxxxxx.",
         "....x....",
         "...x.x..."]


def wiku(cv, f):
    u, sw, sw2 = BR[f], SW[f], SW2[f]
    sk = LANGSAT
    h = HF(47, 30 - u)
    flick = f in (2, 3)
    # staff: wood, planted at the right, ring crest at the top with small jingle rings
    sx = 71
    sp = [(sx, 14), (sx, 122)]
    cv.fill(tube(sp, [3.2, 3.2]), WOOD, lam=tube_lam(sp, [3.2, 3.2]), sep=True, dith=False)
    for yy in (30, 52, 100):
        cv.paint(L([(sx - 1.5, yy), (sx + 1.5, yy)]), GOLD[1], over_only=False)
    rm = SUB(ell(sx, 10, 6.2, 6.2), ell(sx, 10, 4.2, 4.2))
    cv.fill(rm, VERD, sep=True, lam=lambda x, y: 0.6 - 0.45 * ((x + 0.5 - sx) / 6 + (y + 0.5 - 10) / 6), dith=False, bands=(0.8, 0.5, 0.2))
    cv.fill(ell(sx, 3.4, 1.6, 1.8), GOLD, sep=True, dith=False)
    for k, ox in enumerate((-5, 5)):
        r2 = SUB(ell(sx + ox, 17.5, 1.8, 1.8), ell(sx + ox, 17.5, 0.8, 0.8))
        cv.fill(r2, GOLD, sep=True, dith=False)
    cv.fill(poly([(sx - 2, 15), (sx + 2, 15), (sx + 1.5, 19), (sx - 1.5, 19)]), GOLD, sep=True, dith=False)
    # inner kain to the ankles: tan with kawung batik and a verdigris tumpal border
    km = poly([(37, 80), (58, 80), (60 + sw * 0.5, 104), (61 + sw, 119), (52, 120), (44, 120), (34 + sw, 119), (35 + sw * 0.5, 104)])
    cv.fill(km, PAPER_S, sep=True, lam=lam_box(34, 80, 61, 120, 0.8), bands=(0.88, 0.52, 0.22))
    batik(cv, km, PAPER_S, kawung(0, 1), lift=-1)
    folds(cv, km, PAPER_S, [[(44, 96), (42, 118)], [(54, 96), (57, 118)]], hi=False)
    hem = AND(km, poly([(0, 112), (W, 112), (W, 121), (0, 121)]))
    cv.fill(hem, PAPER, flat=1, dith=False)
    for i, v in enumerate(hem):
        if v:
            y, x = divmod(i, W)
            if tumpal(x, y, 113, 4):
                cv.p[i] = VERD[1] if x < 50 else VERD[2]
    cv.paint(AND(hem, L([(30, 112), (64, 112)])), VERD[3])
    foot(cv, 43, 123, -1, sk)
    foot(cv, 53, 123, 1, sk)
    # outer robe: cream, to below the knee, hem sweeping up at the front opening
    rp = [(36, 37 - u), (59, 36 - u), (58, 50), (57, 62), (59, 80), (62 + sw, 100), (54, 98), (48, 93), (42, 97), (33 + sw, 101), (36, 80), (37, 62), (36, 50)]
    rm = poly(rp)
    cv.fill(rm, PAPER, sep=True, lam=lam_box(33, 36, 62, 101, 0.85), bands=(0.86, 0.5, 0.2))
    folds(cv, rm, PAPER, [[(41, 66), (37, 98)], [(45, 70), (44, 94)], [(53, 68), (56, 96)], [(57, 74), (60, 98)]], hi=True)
    cv.paint(AND(rm, L([(33 + sw, 100), (42, 96), (48, 92), (54, 97), (62 + sw, 99)])), VERD[2])
    # upper body: robe over the left shoulder, right shoulder and arm bare
    cv.fill(poly([(46, 37 - u), (59, 36 - u), (59, 44), (57, 60), (47, 60)]), sk, sep=True, lam=lam_box(44, 36, 60, 60, 0.6), dith=False, bands=(0.86, 0.5, 0.2))
    cv.paint(L([(51, 45 - u), (56, 46 - u)]), sk[2])
    drape = poly([(35, 37 - u), (46, 36 - u), (57, 56), (57, 62), (37, 62), (36, 50)])
    cv.fill(drape, PAPER, sep=True, lam=lam_box(35, 36, 57, 62, 0.85), bands=(0.86, 0.5, 0.2))
    folds(cv, drape, PAPER, [[(40, 42), (42, 56)], [(45, 40), (52, 56)]], hi=True)
    cv.paint(AND(drape, L([(46, 37 - u), (57, 57)])), PAPER[3])
    cv.paint(AND(drape, L([(45, 37 - u), (56, 57)])), PAPER[2])
    # upawita-like cord (generic sacred thread) and a bead necklace
    cv.paint(L([(44, 38 - u), (50, 47 - u), (56, 58)]), RED[1])
    for k in range(7):
        a = math.pi * (0.15 + 0.7 * k / 6)
        put(cv, 47.5 - 5.5 * math.cos(a), 36 - u + 4.5 * math.sin(a), INK if k % 2 else WOOD[2])
    # verdigris sash, lontar bundle hangs at the hip
    sa = poly([(36, 59), (58, 59), (58, 65), (37, 65)])
    cv.fill(sa, VERD, sep=True, lam=lam_box(36, 59, 58, 65, 0.7), dith=False)
    cv.paint(AND(sa, L([(37, 62), (57, 62)])), GOLD[1])
    tl = poly([(52, 64), (56, 64), (57 + sw, 80), (58 + sw2, 92), (53 + sw, 92), (53, 80)])
    cv.fill(tl, VERD, sep=True)
    cv.paint(AND(tl, L([(53 + sw, 90), (58 + sw2, 90)])), GOLD[1])
    # right arm (bare, gold kelat bahu) holds the staff
    ra = [(59, 39 - u), (64, 50), (68, 57)]
    m = limb(cv, ra, [8.2, 7.2, 6.4], sk)
    cv.paint(AND(m, L([(58, 45 - u), (66, 45 - u)], 2)), GOLD[1])
    cv.paint(AND(m, L([(58, 44 - u), (66, 44 - u)])), GOLD[0])
    hand(cv, sx - 0.5, 58, sk, 3.2)
    cv.paint(L([(sx - 3, 57), (sx + 2, 57)]), sk[2])
    # left arm in the robe sleeve, holding an open lontar out in front
    la = [(36, 39 - u), (30, 50), (26, 60)]
    limb(cv, la, [9.6, 9, 8.4], PAPER)
    LON = mat("D4AC5E", warm=(255, 240, 180))
    lx, ly = 19, 57 - u
    # lontar: stacked palm-leaf pages between wooden covers, top page lifted, red binding cord
    cv.fill(poly([(lx - 11, ly + 2), (lx + 11, ly + 2), (lx + 11, ly + 4), (lx - 11, ly + 4)]), WOOD, sep=True, dith=False, lam=lam_box(lx - 11, ly + 2, lx + 11, ly + 4, 0.8))
    pg = poly([(lx - 10.5, ly - 1), (lx + 10.5, ly - 1), (lx + 10.5, ly + 2), (lx - 10.5, ly + 2)])
    cv.fill(pg, LON, sep=True, dith=False, lam=lambda x, y: 0.9 - 0.25 * (y - ly + 1) - 0.01 * (x - lx))
    for yy in (ly, ly + 1):
        cv.paint(AND(pg, L([(lx - 10, yy), (lx + 10, yy)])), LON[2] if yy == ly + 1 else LON[1])
    lift = 4 if flick else 2
    tp = poly([(lx - 10.5, ly - 2), (lx + 10.5, ly - 2 - lift), (lx + 10.5, ly - 0.5 - lift), (lx - 10.5, ly - 0.5)])
    cv.fill(tp, LON, flat=0, dith=False, sep=True)
    for t in range(-8, 10, 2):
        put(cv, lx + t, ly - 1.4 - lift * (t + 10.5) / 21, INK if t % 4 else LON[3])
    cv.paint(L([(lx - 1, ly - 2), (lx - 1, ly + 6)]), RED[1], over_only=False)
    cv.fill(ell(lx - 1, ly + 7.5, 1.2, 1.4), GOLD, dith=False)
    hand(cv, lx + 6, ly + 5, sk, 3.0)
    # head: topknot (gelung) with headband, sumping at the ear, stylus behind the ear
    neck(cv, h, sk, 6)
    hm = OR(h.ell(0, -9.5, 7.6, 8.2), h.ell(0.5, -20.5, 4.2, 3.8))
    cv.fill(hm, HAIR, sep=True, lam=lambda x, y: 0.6 - 0.4 * ((x + 0.5 - h.x) / 7) - 0.2 * ((y - h.y + 14) / 8), bands=(0.85, 0.55, 0.25))
    cv.paint(AND(hm, h.L([(-3, -22), (-1, -24)])), HAIR[0])
    face(cv, h, sk, mood="kind")
    bd = h.poly([(-7.8, -11.5), (0, -13.3), (8, -11.5), (8, -10), (0, -11.8), (-7.8, -10)])
    cv.fill(bd, PAPER, dith=False, flat=2)
    cv.paint(AND(bd, h.L([(-7.8, -11), (0, -12.8), (8, -11)])), GOLD[1])
    cv.fill(h.poly([(-3, -17.5), (4, -17.5), (4, -16), (-3, -16)]), GOLD, sep=True, dith=False)
    h.put(cv, 0, -17, GOLD[0])
    sm = h.poly([(7, -9), (9.5, -12), (12, -12.5), (10.5, -9.5), (12, -8), (9, -6.5), (7, -6)])
    cv.fill(sm, GOLD, sep=True, lam=lambda x, y: 0.75 - 0.4 * ((x - h.x - 7) / 3.0), dith=False)
    h.put(cv, 9, -9, GOLD[3])
    cv.paint(h.L([(8, -13), (12, -17)]), WOOD[1], over_only=False)


def wiku_glow(f):
    ph = 0.5 + 0.5 * math.sin(2 * math.pi * f / 6)
    TEAL, TEAL_HI = hexc("6FE0D0"), hexc("E6FFF6")

    def g(img):
        # ink-light: a crisp teal rim on the open page, wisps rising from the text
        y0 = 57 - BR[f]
        for x in range(8, 31):
            for y in range(y0 - 9, y0 + 1):
                if img[y * W + x][3] == 0 and img[(y + 1) * W + x][3] == 255 and y >= y0 - 7:
                    blend(img, x, y, TEAL_HI if (x + f) % 5 else TEAL, 0.85)
                    break
        for k, wx in enumerate((11, 16, 21, 26)):
            hgt = 3 + int(2 * (0.5 + 0.5 * math.sin(2 * math.pi * (f / 6 + k * 0.3))))
            top = y0 - 7 - (k % 2) - hgt
            for j in range(hgt):
                xx = wx + (1 if (j + k + f) % 4 == 0 else 0)
                blend(img, xx, top + j, TEAL, 0.25 + 0.45 * j / hgt)
        gx, gy = 14, int(31 - round(1.5 * math.sin(2 * math.pi * f / 6)))
        for yy, row in enumerate(GLYPH):
            for xx, ch in enumerate(row):
                if ch == "x":
                    blend(img, gx + xx, gy + yy, TEAL_HI, 0.85 + 0.15 * ph)
        for k in range(4):
            t = ((f / 6.0) + k * 0.25) % 1.0
            px = 19 + 9 * math.sin(2 * math.pi * (t + k * 0.37))
            blend(img, int(px), int(50 - 24 * t), TEAL_HI if k % 2 else TEAL, 0.9 * (1 - t))
        a = math.radians(-135 + 60 * f)
        blend(img, int(round(71 + 5.2 * math.cos(a))), int(round(10 + 5.2 * math.sin(a))), hexc("FFFFFF"), 0.9)
    return g


def blend(img, x, y, col, a):
    if 0 <= x < W and 0 <= y < H and a > 0:
        i = y * W + x
        d = img[i]
        if d[3] == 0:
            img[i] = (col[0], col[1], col[2], int(255 * a))
        else:
            img[i] = (int(d[0] * (1 - a) + col[0] * a), int(d[1] * (1 - a) + col[1] * a), int(d[2] * (1 - a) + col[2] * a), d[3])


# ------------------------------------------------------------------------------------------ output
def finish(cv, glow=None, shx=48):
    p = cv.p
    q = list(p)
    for y in range(H):
        for x in range(W):
            c = p[y * W + x]
            if c is None:
                continue
            re = x + 1 >= W or p[y * W + x + 1] is None
            le = x - 1 < 0 or p[y * W + x - 1] is None
            te = y - 1 < 0 or p[(y - 1) * W + x] is None
            if re:
                q[y * W + x] = mix(c, hexc("9FB8E8"), 0.30)
            elif te or le:
                q[y * W + x] = mix(c, (255, 226, 170), 0.16)
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
                out[y * W + x] = mix(INK, (int(best[0] * 0.38), int(best[1] * 0.3), int(best[2] * 0.36)), 0.5)
    img = [(c[0], c[1], c[2], 255) if c else (0, 0, 0, 0) for c in out]
    for y in range(115, 128):
        for x in range(8, 90):
            d = ((x + 0.5 - shx) / 28.0) ** 2 + ((y + 0.5 - 122.5) / 4.5) ** 2
            if d <= 1.0 and img[y * W + x][3] == 0:
                img[y * W + x] = (16, 10, 18, 110 if d < 0.55 else 60)
    if glow:
        glow(img)
    return img


def png_write(path, w, h, px):
    with open(path, "wb") as fh:
        fh.write(png_bytes(w, h, px))


def png_read(path):
    d = open(path, "rb").read()
    pos, idat, w, h = 8, b"", 0, 0
    while pos < len(d):
        ln, = struct.unpack(">I", d[pos:pos + 4]); t = d[pos + 4:pos + 8]; body = d[pos + 8:pos + 8 + ln]
        if t == b"IHDR":
            w, h = struct.unpack(">II", body[:8])
        elif t == b"IDAT":
            idat += body
        pos += 12 + ln
    raw = zlib.decompress(idat); bpp = 4; st = w * bpp
    px, prev, i = [], bytearray(st), 0
    for _ in range(h):
        fl = raw[i]; line = bytearray(raw[i + 1:i + 1 + st]); i += 1 + st
        for x in range(st):
            a = line[x - bpp] if x >= bpp else 0; b = prev[x]; c = prev[x - bpp] if x >= bpp else 0
            if fl == 1: line[x] = (line[x] + a) & 255
            elif fl == 2: line[x] = (line[x] + b) & 255
            elif fl == 3: line[x] = (line[x] + (a + b) // 2) & 255
            elif fl == 4:
                pp = a + b - c; pa, pb, pc = abs(pp - a), abs(pp - b), abs(pp - c)
                line[x] = (line[x] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        px.extend(tuple(line[x * 4:x * 4 + 4]) for x in range(w)); prev = line
    return w, h, px


def over(bg, c):
    a = c[3] / 255
    return (int(bg[0] * (1 - a) + c[0] * a), int(bg[1] * (1 - a) + c[1] * a), int(bg[2] * (1 - a) + c[2] * a), 255)


def scaled_sheet(tiles, cols, S=4, gap=8, bg=(0x1a, 0x14, 0x20, 255)):
    """tiles: list of rows, each a list of 96x128 pixel lists."""
    rows = len(tiles)
    pw, ph = cols * (W * S + gap) + gap, rows * (H * S + gap) + gap
    out = [bg] * (pw * ph)
    for r, row in enumerate(tiles):
        for c, img in enumerate(row):
            ox, oy = gap + c * (W * S + gap), gap + r * (H * S + gap)
            for y in range(H * S):
                for x in range(W * S):
                    px = img[(y // S) * W + x // S]
                    if px[3]:
                        out[(oy + y) * pw + ox + x] = over(bg, px)
    return pw, ph, out


def merge(dst, src, dx=0, dy=0):
    """Copy the painted pixels of one canvas onto another, shifted (used to drop the upper body into a crouch)."""
    for i, c in enumerate(src.p):
        if c is not None:
            y, x = divmod(i, W)
            if 0 <= x + dx < W and 0 <= y + dy < H:
                dst.p[(y + dy) * W + x + dx] = c


def render(fn, f=0, shx=48, glow=None):
    cv = Cv()
    fn(cv, f)
    return finish(cv, glow(f) if glow else None, shx)



# ----------------------------------------------------------------------------------------------- main
CLASS_FIGS = (("warrior", hulubalang, 48), ("archer", pamanah, 48), ("rogue", pendekar, 46), ("mage", wiku, 50))
GLOWS = {"mage": wiku_glow}


def strip(cid, fn, shx):
    out = [(0, 0, 0, 0)] * (W * NF * H)
    for f in range(NF):
        img = render(fn, f, shx, GLOWS.get(cid))
        for y in range(H):
            for x in range(W):
                out[y * W * NF + f * W + x] = img[y * W + x]
    return out


def main():
    os.makedirs(OUTDIR, exist_ok=True)
    strips = []
    for cid, fn, shx in CLASS_FIGS:
        px = strip(cid, fn, shx)
        path = os.path.join(OUTDIR, f"class_{cid}.png")
        png_write(path, W * NF, H, px)
        strips.append(px)
        print("wrote", path)
    S = 2
    pw, ph = W * NF * S + 16, (H * S + 8) * 4 + 8
    bg = (0x1a, 0x14, 0x20, 255)
    prev = [bg] * (pw * ph)
    for i, px in enumerate(strips):
        oy = 8 + i * (H * S + 8)
        for y in range(H * S):
            for x in range(W * NF * S):
                c = px[(y // S) * W * NF + x // S]
                if c[3]:
                    prev[(oy + y) * pw + 8 + x] = over(bg, c)
    png_write(PREVIEW, pw, ph, prev)
    print("wrote", PREVIEW)


if __name__ == "__main__":
    main()
