#!/usr/bin/env python3
"""Aksara Kala hero big art (v3, 2026-11-12 repaint): the class-select figures and the hero's dialogue busts.

Outputs
  assets/art/portraits/class_<id>.png      576x128, 6 idle frames of 96x128 (ui/class_select.gd, Status tab)
  assets/art/portraits/p_hero_<id>[_mood].png  48x48 busts, moods happy / angry / sad (ui/portraits.gd)
  tools/portraits_preview.png
for the 8 classes of .docs/classes.md: warrior, lancer, archer, herder, rogue, dancer, mage, dalang.

Every class is hand-posed (its own stance, weight leg, shoulder tilt and 3/4 turn), not one shared rig. Shapes are
masks shaded with contour-hugging bands from one top-left light over hue-shifted 4-tone ramps (lights warm, shadows
cool and violet). Lines are selective: a part's edge over another part takes its own deepest tone on the shadow side,
and the silhouette takes a dark tint of the local colour (lighter on the lit side) instead of one black line. Faces
use the eye/brow/nose/mouth stamps of tools/gen_speaker_portraits.py (lid, iris, catch-light) in a smaller set for
the figure. The bust is the same figure painted 1.36x larger and cropped to head and shoulders, so the face in a
dialogue is the hero you picked; it always faces right like the NPC busts.
Feet stand on frame row 121 (outline 122) in every frame; ui/class_select.gd puts that row on the pedestal.
Run: python3 tools/gen_portraits.py
"""
import colorsys
import math
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pilite
pilite.install()
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUTDIR = os.path.join(ROOT, "assets", "art", "portraits")
FW, FH, FRAMES = 96, 128, 6
CLASS_IDS = ["warrior", "lancer", "archer", "herder", "rogue", "dancer", "mage", "dalang"]
MOODS = ["", "happy", "angry", "sad"]
LIGHT = (-0.62, -0.78)
GROUND = 122.4           # feet rest on row 121, their outline on 122


# ---------------------------------------------------------------- colour
def hx(s):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), 255)


def mix(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3)) + (255,)


def _toward(h, target, amt):
    d = (target - h + 0.5) % 1.0 - 0.5
    return (h + max(-amt, min(amt, d))) % 1.0


def ramp(base, warm=1.0):
    """(light, mid, shadow, deep): lights lean to warm gold, shadows to cool violet, deep tones darker and richer."""
    r, g, b, _ = hx(base) if isinstance(base, str) else base
    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)

    def c(h_, s_, v_):
        rr, gg, bb = colorsys.hsv_to_rgb(h_ % 1.0, max(0, min(1, s_)), max(0, min(1, v_)))
        return (int(rr * 255 + .5), int(gg * 255 + .5), int(bb * 255 + .5), 255)
    lt = c(_toward(h, 0.13, 0.035 * warm), s * 0.82, v + (1 - v) * 0.42 + 0.04)
    sh = c(_toward(h, 0.70, 0.045), s * 1.06 + 0.07, v * 0.70)
    dp = c(_toward(h, 0.72, 0.08), s * 1.12 + 0.12, v * 0.45)
    return (lt, hx(base) if isinstance(base, str) else base, sh, dp)


def R(*cols):
    return tuple(hx(c) for c in cols)


INK = hx("1E1420")
SKINS = {
    "sawo": R("E8B27E", "C4844F", "92543A", "5E2F2E"),
    "sawo_dk": R("D89C6A", "AE6E44", "7E4634", "4E2628"),
    "langsat": R("F6D2A6", "E0A676", "B4704E", "7A3E3A"),
}
HAIR = R("5A4A5E", "2E2432", "1C1520", "120C14")
GOLD = R("FFE8A0", "E2B64A", "A87A22", "6A4A14")
STEEL = R("F2F6F0", "B4C0C4", "6E7C8A", "3C4458")
WOOD = R("B4844E", "7C5432", "523422", "2E1C16")
BAMBOO = R("EED690", "C8A458", "8E6E36", "5A4224")
CREAM = R("FFF8E6", "EADCB6", "B6A48A", "76687A")
WHITE = R("FFFFF4", "E6E2D6", "AEA8B4", "6C6680")
REDR = ramp("C0362C")
LID = hx("2A1A1C")
EYE_W = hx("F4EEDC")
GLINT = hx("FFF8EA")
TEAR = hx("A8D8F0")


# ---------------------------------------------------------------- painter
class Painter:
    """Masks are sets of raster pixels. Figure coordinates go through x' = ox + sx*k*x, y' = oy + k*y."""

    def __init__(self, w, h, k=1.0, ox=0.0, oy=0.0, sx=1):
        self.w, self.h, self.k, self.ox, self.oy, self.sx = w, h, k, ox, oy, sx
        self.px = {}          # (x, y) -> (colour, ramp or None, level)
        self.fx = {}          # glow overlay, painted after the outline
        self.big = k > 1.2

    def T(self, x, y):
        return (self.ox + self.sx * self.k * x, self.oy + self.k * y)

    def raster(self, test, x0, y0, x1, y1):
        out = set()
        for py in range(max(0, int(math.floor(y0)) - 1), min(self.h, int(math.ceil(y1)) + 2)):
            for px_ in range(max(0, int(math.floor(x0)) - 1), min(self.w, int(math.ceil(x1)) + 2)):
                if test(px_ + .5, py + .5):
                    out.add((px_, py))
        return out

    # masks -------------------------------------------------------------
    def poly(self, pts):
        q = [self.T(*p) for p in pts]

        def test(x, y):
            ins = False
            j = len(q) - 1
            for i in range(len(q)):
                (xi, yi), (xj, yj) = q[i], q[j]
                if (yi > y) != (yj > y) and x < (xj - xi) * (y - yi) / (yj - yi) + xi:
                    ins = not ins
                j = i
            return ins
        return self.raster(test, min(p[0] for p in q), min(p[1] for p in q), max(p[0] for p in q), max(p[1] for p in q))

    def ell(self, cx, cy, rx, ry, rot=0.0):
        X, Y = self.T(cx, cy)
        rx, ry = rx * self.k, ry * self.k
        ca, sa = math.cos(math.radians(rot * self.sx)), math.sin(math.radians(rot * self.sx))
        r = max(rx, ry)

        def test(x, y):
            dx, dy = x - X, y - Y
            u, v = dx * ca + dy * sa, -dx * sa + dy * ca
            return (u / rx) ** 2 + (v / ry) ** 2 <= 1.0
        return self.raster(test, X - r, Y - r, X + r, Y + r)

    def stroke(self, pts, ws):
        """A tapered limb through pts with full widths ws: one mask, so joints never bulge."""
        q = [self.T(*p) for p in pts]
        rs = [w * self.k / 2 for w in ws]
        out = set()
        for (a, ra), (b, rb) in zip(zip(q, rs), zip(q[1:], rs[1:])):
            dx, dy = b[0] - a[0], b[1] - a[1]
            L = dx * dx + dy * dy or 1e-6

            def test(x, y, a=a, dx=dx, dy=dy, L=L, ra=ra, rb=rb):
                t = max(0.0, min(1.0, ((x - a[0]) * dx + (y - a[1]) * dy) / L))
                r = ra + (rb - ra) * t
                ex, ey = x - (a[0] + dx * t), y - (a[1] + dy * t)
                return ex * ex + ey * ey <= r * r
            r = max(ra, rb)
            out |= self.raster(test, min(a[0], b[0]) - r, min(a[1], b[1]) - r, max(a[0], b[0]) + r, max(a[1], b[1]) + r)
        return out

    # paint -------------------------------------------------------------
    def _march(self, m, x, y, d, lim=7.0):
        fx, fy, k = x + .5, y + .5, 0.0
        while k < lim:
            fx += d[0] * .5
            fy += d[1] * .5
            k += .5
            if (int(math.floor(fx)), int(math.floor(fy))) not in m:
                return k
        return lim

    def shade(self, m, rp, hi=1.0, shd=2.0, edge=True, base=1, lit=True, clip=None, light=LIGHT):
        """Contour bands: a lit rim on the light side, a shadow band on the far side, mid between.
        edge: where the part overlaps another, its shadow-side rim takes the deep tone (a selective line)."""
        if clip is not None:
            m = m & clip
        back = (-light[0], -light[1])
        lv = {}
        for (x, y) in m:
            a = self._march(m, x, y, light)
            bb = self._march(m, x, y, back)
            l = base
            if lit and a <= hi and a < bb:
                l = 0
            if bb <= shd and bb <= a:
                l = 2
            lv[(x, y)] = l
        if edge:
            for (x, y) in m:
                for dx, dy in ((1, 0), (0, 1)):
                    q = (x + dx, y + dy)
                    if q not in m and q in self.px:
                        lv[(x, y)] = 3
                if edge == "all":
                    for dx, dy in ((-1, 0), (0, -1)):
                        q = (x + dx, y + dy)
                        if q not in m and q in self.px and lv[(x, y)] < 2:
                            lv[(x, y)] = 2
        for p_, l in lv.items():
            self.px[p_] = (rp[l], rp, l)
        return m

    def flat(self, m, rp, l, clip=None):
        for p_ in m:
            if clip is None or p_ in clip:
                self.px[p_] = (rp[l], rp, l)
        return m

    def color(self, pts, c, clip=None):
        for p_ in pts:
            if 0 <= p_[0] < self.w and 0 <= p_[1] < self.h and (clip is None or p_ in clip):
                self.px[p_] = (c, None, 1)

    def setl(self, pts, l, clip=None, only=None):
        """Re-tone existing ramp pixels to level l (folds, creases). only: only touch pixels at these levels."""
        for p_ in pts:
            v = self.px.get(p_)
            if v and v[1] and (clip is None or p_ in clip) and (only is None or v[2] in only):
                self.px[p_] = (v[1][l], v[1], l)

    def cast(self, m, dx=1, dy=1, to=2):
        """A shape's cast shadow on what is already painted below it."""
        for (x, y) in m:
            q = (x + dx, y + dy)
            if q in m:
                continue
            v = self.px.get(q)
            if v and v[1] and v[2] < to:
                self.px[q] = (v[1][to], v[1], to)

    def pixline(self, pts):
        out = []
        q = [tuple(int(math.floor(c)) for c in self.T(*p)) for p in pts]
        for (x0, y0), (x1, y1) in zip(q, q[1:] or q):
            dx, dy = abs(x1 - x0), -abs(y1 - y0)
            sx, sy = (1 if x0 < x1 else -1), (1 if y0 < y1 else -1)
            err = dx + dy
            while True:
                if not out or out[-1] != (x0, y0):
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

    def line(self, pts, c, clip=None):
        self.color(self.pixline(pts), c, clip)

    def lline(self, pts, l, clip=None, only=None):
        self.setl(self.pixline(pts), l, clip, only)

    def fold(self, pts, clip, lit_side=-1):
        """A crease: a shadow line with a lit pixel line beside it on the light side."""
        ln = self.pixline(pts)
        self.setl([(x + lit_side, y) for x, y in ln], 0, clip, only=(1,))
        self.setl(ln, 2, clip, only=(0, 1))

    def dot(self, x, y, c, clip=None):
        X, Y = self.T(x, y)
        self.color([(int(math.floor(X)), int(math.floor(Y)))], c, clip)

    def at(self, x, y):
        X, Y = self.T(x, y)
        return (int(math.floor(X)), int(math.floor(Y)))

    def stamp(self, x, y, rows, pal, rf=1):
        ax, ay = self.at(x, y)
        for j, row in enumerate(rows):
            for i, ch in enumerate(row):
                if ch not in ". ":
                    c = pal[ch]
                    q = (ax + rf * i, ay + j)
                    if 0 <= q[0] < self.w and 0 <= q[1] < self.h:
                        if isinstance(c, int):
                            self.setl([q], c)
                        else:
                            self.px[q] = (c, None, 1)

    def stamp_px(self, ax, ay, rows, pal, rf=1):
        for j, row in enumerate(rows):
            for i, ch in enumerate(row):
                if ch not in ". ":
                    c = pal[ch]
                    q = (ax + rf * i, ay + j)
                    if 0 <= q[0] < self.w and 0 <= q[1] < self.h:
                        if isinstance(c, int):
                            self.setl([q], c)
                        else:
                            self.px[q] = (c, None, 1)

    def glow(self, x, y, r, c, a=1.0):
        """Two hard rings of light, painted over the finished figure."""
        X, Y = self.T(x, y)
        r *= self.k
        for py in range(int(Y - r) - 1, int(Y + r) + 2):
            for px_ in range(int(X - r) - 1, int(X + r) + 2):
                d = math.hypot(px_ + .5 - X, py + .5 - Y)
                if 0 <= px_ < self.w and 0 <= py < self.h and d <= r:
                    al = (70 if d > r * 0.6 else 130) * a
                    old = self.fx.get((px_, py))
                    if not old or old[3] < al:
                        self.fx[(px_, py)] = c[:3] + (int(al),)

    def image(self, bg=None):
        img = Image.new("RGBA", (self.w, self.h), bg or (0, 0, 0, 0))
        filled = self.px
        for (x, y), v in filled.items():
            img.putpixel((x, y), v[0])
        # silhouette: a dark tint of the local colour, lighter where the light falls on the edge
        for y in range(self.h):
            for x in range(self.w):
                if (x, y) in filled:
                    continue
                nb = [(dx, dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)) if (x + dx, y + dy) in filled]
                if not nb:
                    continue
                lit = all(dx >= 0 and dy >= 0 for dx, dy in nb)
                vs = [filled[(x + dx, y + dy)] for dx, dy in nb]
                v = min(vs, key=lambda v: sum(v[0][:3]))
                base = v[1][3] if v[1] else mix(v[0], INK, 0.5)
                img.putpixel((x, y), mix(base, INK, 0.25) if lit else mix(base, INK, 0.72))
        for (x, y), c in self.fx.items():
            old = img.getpixel((x, y))
            a = c[3] / 255.0
            if old[3] == 0:
                img.putpixel((x, y), c[:3] + (c[3],))
            else:
                img.putpixel((x, y), tuple(int(old[i] + (c[i] - old[i]) * a) for i in range(3)) + (old[3],))
        return img


# ---------------------------------------------------------------- the head (3/4, local frame faces right)
JAWS = {
    "soft": [(-6.4, 1.5), (7.2, -1.5), (7.6, 2.5), (7.0, 5.5), (5.2, 8.2), (2.8, 9.6), (0.4, 9.4), (-2.6, 7.4), (-5.4, 4.4)],
    "square": [(-6.4, 1.5), (7.3, -1.5), (7.8, 3.0), (7.4, 6.4), (5.6, 8.8), (2.2, 9.9), (-1.2, 8.8), (-4.8, 5.4)],
    "narrow": [(-6.4, 1.5), (7.0, -1.5), (7.3, 2.5), (6.6, 5.8), (4.6, 8.8), (2.6, 9.8), (0.8, 9.6), (-2.6, 7.0), (-5.4, 4.0)],
}
# eye stamps: (near, far) per size; L lid, w white, I iris, h catch-light, s skin shadow, k skin light
EYES_FIG = {
    "open": (["LLL.", "wIh.", ".s.."], ["LL", "IL"]),
    "narrow": (["LLLL", ".Ih.", "...."], ["LL", "I."]),
    "lash": (["LLLL", "wIh.", ".s.."], ["LLL", "IL."]),
    "hooded": (["LLL.", "LIh.", "...."], ["LL", "I."]),
}
EYES_BIG = {
    "open": (["LLLL.", "wIhs.", ".Is.."], ["LLL", "hIL", ".s."]),
    "narrow": (["LLLL.", ".Ihs.", "....."], ["LLL", "hI.", "..."]),
    "lash": (["LLLLL", "wIhs.", ".Is.."], ["LLLL", "hIL.", ".s.."]),
    "hooded": (["LLLL.", "LIhL.", ".s..."], ["LLL", "IhL", "..."]),
}


class Head:
    def __init__(self, P, cx, cy, fd, spec):
        self.P, self.cx, self.cy, self.fd, self.s = P, cx, cy, fd, spec
        self.rf = fd * P.sx            # facing in raster space

    def L(self, x, y):
        return (self.cx + self.fd * x, self.cy + y)

    def poly(self, pts):
        return self.P.poly([self.L(*p) for p in pts])

    def ell(self, x, y, rx, ry, rot=0.0):
        X, Y = self.L(x, y)
        return self.P.ell(X, Y, rx, ry, rot * self.fd)

    def stroke(self, pts, ws):
        return self.P.stroke([self.L(*p) for p in pts], ws)

    def line(self, pts, c, clip=None):
        self.P.line([self.L(*p) for p in pts], c, clip)

    def lline(self, pts, l, clip=None, only=None):
        self.P.lline([self.L(*p) for p in pts], l, clip, only)

    def dot(self, x, y, c, clip=None):
        self.P.dot(*self.L(x, y), c, clip)

    def stamp(self, x, y, rows, pal):
        """Stamps hang off a pixel anchor in the facing direction, so a mirrored head mirrors its features."""
        X, Y = self.L(x, y)
        self.P.stamp(X, Y, rows, pal, self.rf)

    # ---- the parts
    def neck(self, w=0.0):
        sk = self.s["skin"]
        m = self.poly([(-3.4 - w, 5), (2.8 + w, 6), (3.0 + w, 14), (-3.6 - w, 14)])
        self.P.shade(m, sk, shd=2.5, edge=False)
        return m

    def skull(self):
        sk = self.s["skin"]
        m = self.ell(0, 0, 7.4, 7.6) | self.poly(JAWS[self.s.get("jaw", "soft")])
        self.P.shade(m, sk, hi=1.0, shd=2.0, edge=False)
        self.m = m
        return m

    def ear(self):
        sk = self.s["skin"]
        e = self.ell(-4.7, 2.4, 1.5, 2.1)
        self.P.shade(e, sk, hi=1.0, shd=1.0, edge=False)
        self.P.setl([self.P.at(*self.L(-4.6, 2.4))], 2)
        return e

    def hair(self, pts=None):
        hr = self.s.get("hair", HAIR)
        pts = pts or [(-7.9, 4.0), (-8.1, -1.8), (-6.4, -6.4), (-2.2, -8.6), (3.0, -8.4), (6.6, -6.0), (8.0, -2.6),
                      (7.7, -1.4), (5.0, -2.9), (1.8, -2.6), (-0.6, -2.1), (-2.3, 0.2), (-2.9, 3.2), (-4.4, 0.4), (-6.2, 4.6)]
        m = self.poly(pts)
        self.P.shade(m, hr, hi=1.0, shd=1.5, edge=False)
        self.P.cast(m, 0, 1)
        return m

    def fst(self, dx, dy, rows, pal):
        """A face stamp at a raster offset from the head's centre pixel, mirrored with the head."""
        ax, ay = self.P.at(self.cx, self.cy)
        self.P.stamp_px(ax + self.rf * dx, ay + dy, rows, pal, self.rf)

    def face(self, mood="", blink=False):
        P, sk, s = self.P, self.s["skin"], self.s
        big = P.big
        eset = s.get("eyes", "open")
        if mood == "angry":
            eset = "hooded"
        near, far = (EYES_BIG if big else EYES_FIG)[eset]
        near, far = list(near), list(far)
        pal = {"L": LID, "w": EYE_W, "I": hx(s.get("iris", "2A1810")), "h": GLINT, "s": 2, "k": 0}
        if blink:
            near, far = ["....", "LLL."], ["..", "LL"]
        elif mood == "happy":
            near, far = ["....", ".LL.", "L..L"], ["...", ".LL", "L.."]
        bc = s.get("brow", (s.get("hair", HAIR))[1])
        thick = s.get("thick", False)
        lip = hx(s.get("lip", "7A3436"))
        W = hx("F2EAD8")
        Pm = {"L": lip, "W": W, "k": 0, "s": 2, "d": hx("4A1A1E")}
        if not big:
            e = s.get("eye_y", 1)
            self.fst(-3, e, near, pal)
            self.fst(3, e, far, pal)
            if mood == "angry":
                nb, fb = ["LL..", ".LLL"], ["LL"]
            elif mood == "sad":
                nb, fb = ["..LL", "LL.."], ["L.", ".L"]
            else:
                nb, fb = (["LLL", "..."] if not thick else ["LLL", "LLL"]), ["LL"]
            self.fst(-3, e - 2, nb, {"L": bc})
            self.fst(3, e - 2, fb, {"L": bc})
            self.fst(2, e + 1, ["s.", "s.", "dk"], {"s": 2, "k": 0, "d": 3})
            if mood == "happy":
                self.fst(0, e + 6, ["L..L", ".LL."], {"L": lip})
            else:
                self.fst(0, e + 6, ["LLL", ".k."], Pm)
            if s.get("stache"):
                self.fst(-1, e + 5, ["LLLLL"], {"L": s.get("hair", HAIR)[1]})
            self.fst(6, e + 3, ["s", "s"], {"s": 2})
            if s.get("blush"):
                self.fst(-3, e + 3, ["bb"], {"b": mix(sk[1], hx("E05A50"), 0.35)})
            return
        # the bust uses the NPC bust layout (tools/gen_speaker_portraits.py) around the head centre
        self.fst(-3, 2, near, pal)
        self.fst(5, 2, far, pal)
        if mood == "angry":
            nb, fb = ["LL...", ".LLL.", "...LL"], ["..L", "LL."]
        elif mood == "sad":
            nb, fb = ["...LL", ".LL..", "L...."], ["L..", ".LL"]
        else:
            nb, fb = ([".LLL.", "L...L"] if not thick else [".LLL.", "LLLLL"]), ["LL.", "..L"]
        self.fst(-4, -1, nb, {"L": bc})
        self.fst(5, -1 if mood != "sad" else 0, fb, {"L": bc})
        self.fst(4, 4, [".s.", ".s.", ".ks", "sd."], {"s": 2, "k": 0, "d": 3})
        if mood == "happy":
            self.fst(0, 10, ["L....L", ".LWWL.", "..dd..", "..kk.."], Pm)
        elif mood == "angry":
            self.fst(0, 11, [".LLLL.", "LWWWWL", ".s..s."], Pm)
        elif mood == "sad":
            self.fst(1, 11, [".LLL.", "L...L", ".kk.."], Pm)
            self.fst(-2, 5, ["t", "t"], {"t": TEAR})
        else:
            self.fst(1, 11, ["LLLLs", ".kk.."], Pm)
        if s.get("stache"):
            self.fst(0, 10, ["LLLLLLL", "L.....L"], {"L": s.get("hair", HAIR)[1]})
        self.fst(8, 8, ["s", "s"], {"s": 2})
        if s.get("blush"):
            self.fst(-2, 7, ["bb"], {"b": mix(sk[1], hx("E05A50"), 0.3)})


def head(P, cx, cy, fd, spec, mood="", blink=False, hair=True, neckw=0.0):
    """Neck, skull, ear, face. Returns the Head so headgear can be drawn in its frame."""
    H = Head(P, cx, cy, fd, spec)
    H.neck(neckw)
    H.skull()
    H.P.cast(H.poly(JAWS[spec.get("jaw", "soft")]), 0, 1)
    if hair:
        H.hm = H.hair(spec.get("hair_pts"))
    H.ear()
    H.face(mood, blink)
    return H


# ---------------------------------------------------------------- body helpers
def limb(P, pts, ws, rp, **kw):
    m = P.stroke(pts, ws)
    P.shade(m, rp, **kw)
    return m


def fist(P, x, y, sk, d=1):
    m = P.ell(x, y, 2.4, 2.3)
    P.shade(m, sk, hi=1.0, shd=1.0)
    P.lline([(x - 1.4 * d, y + 0.6), (x + 0.6 * d, y + 0.6)], 2)
    return m


def foot(P, x, y, d, sk, ln=6.5, front=False):
    """A bare foot whose ankle stands at (x, y-3); d is the toe direction (-1, 0 toward the viewer, 1)."""
    if front:
        m = P.ell(x, y - 1.6, 2.8, 2.0) | P.poly([(x - 2.2, y - 4.5), (x + 2.2, y - 4.5), (x + 2.6, y - 1.5), (x - 2.6, y - 1.5)])
    else:
        m = P.poly([(x - 2.4 * d, y - 4.8), (x + 1.8 * d, y - 4.8), (x + ln * d, y - 1.6), (x + ln * d, y),
                    (x - 2.8 * d, y), (x - 3.0 * d, y - 2.0)])
    P.shade(m, sk, hi=1.0, shd=1.0)
    P.setl([(xx, int(math.floor(P.T(x, y)[1]))) for xx in range(min(P.at(x - 3 * d, y)[0], P.at(x + ln * d, y)[0]),
                                                            max(P.at(x - 3 * d, y)[0], P.at(x + ln * d, y)[0]) + 1)], 2, m)
    return m


def tile(P, m, rows, pal, ox=0, oy=0):
    """A small motif repeated on a fixed grid inside m: batik that reads as cloth, never as noise.
    pal maps a char to a level offset toward the light (0) or to a colour; colours dim on shadowed pixels."""
    hh, ww = len(rows), len(rows[0])
    for (x, y) in m:
        ch = rows[(y - oy) % hh][(x - ox) % ww]
        if ch in ". ":
            continue
        v = P.px.get((x, y))
        if not v:
            continue
        c = pal[ch]
        if isinstance(c, int):
            if v[1]:
                l = max(0, min(3, v[2] + c))
                P.px[(x, y)] = (v[1][l], v[1], l)
        else:
            P.px[(x, y)] = ((c if v[2] <= 1 else mix(c, v[0], 0.55)), None, v[2])


def wave(f, amp=1.0, ph=0.0):
    return amp * math.sin(2 * math.pi * f / FRAMES + ph)


BREATH = (0, 0, 1, 1, 1, 0)


# ---------------------------------------------------------------- the classes
def tumpal(P, pts, clip, c=None, step=4):
    """A row of tumpal triangles standing on the hem line pts."""
    c = c or GOLD[1]
    ln = P.pixline(pts)
    seen = set()
    for i, (x, y) in enumerate(ln):
        if x % step or x in seen:
            continue
        seen.add(x)
        P.color([(x, y - 1), (x + 1, y - 1), (x + 2, y - 1), (x + 1, y - 2), (x, y), (x + 1, y), (x + 2, y)],
                c, clip)
        P.color([(x + 1, y - 3)], GOLD[0], clip)


def sleeve_cuff(P, x, y, ang, rp, w=5.4, ln=2.4):
    dx, dy = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    m = P.stroke([(x - dx * ln / 2, y - dy * ln / 2), (x + dx * ln / 2, y + dy * ln / 2)], [w, w])
    P.shade(m, rp, hi=1.0, shd=1.0)
    return m


# ---------------------------------------------------------------- warrior
def warrior(P, f, mood="", bust=False):
    """Hulubalang: wide and low behind the round tameng, the kelewang hanging ready by the back leg. Turned right."""
    sk = SKINS["sawo_dk"]
    red, maroon, leather = ramp("B8322A"), ramp("7E2226"), ramp("5A3A2C")
    b = BREATH[f]
    sw = wave(f, 1.0)
    spec = dict(skin=sk, jaw="square", lip="6A2C2C")
    # back leg (screen left), braced straight; front leg bent over the toes
    limb(P, [(41, 76), (33, 97), (28, 116)], [9.0, 6.6, 4.6], sk)
    foot(P, 28.5, GROUND, -1, sk, 6.0)
    limb(P, [(54, 76), (62, 95), (62.5, 116)], [9.4, 6.8, 4.8], sk)
    P.lline([(60, 94), (62, 96)], 2)
    foot(P, 63, GROUND, 1, sk, 7.0)
    # kain to the knee: pulled tight between the legs, wiru pleats down the front, tumpal hem
    kain = P.poly([(38, 63), (59, 62), (63, 72), (67, 89 + sw * .3), (59, 93), (49, 87), (40, 93), (30, 90 + sw * .3), (35, 72)])
    P.shade(kain, red, hi=1.0, shd=3.0)
    P.fold([(40, 68), (33, 88)], kain)
    P.fold([(57, 68), (63, 86)], kain)
    P.fold([(53, 68), (55, 84)], kain)
    wiru = P.poly([(45, 64), (51, 64), (52, 88), (49, 86), (45, 89)])
    P.shade(wiru, ramp("D04A38"), hi=1.0, shd=1.0)
    for x in (47, 49):
        P.lline([(x, 66), (x + (x - 48) * 0.6, 87)], 2, wiru)
    tumpal(P, [(31, 88 + sw * .3), (40, 91), (49, 85), (59, 91), (66, 87 + sw * .3)], kain)
    P.lline([(31, 89 + sw * .3), (40, 92), (49, 86), (59, 92), (66, 88 + sw * .3)], 3, kain)
    # far arm, mostly hidden by the shield
    limb(P, [(59, 42 + b), (65, 52 + b)], [6.8, 5.6], sk)
    # torso, turned right: the near pectoral broad, the far one foreshortened
    tor = P.poly([(36, 41 + b), (44, 37 + b), (56, 37 + b), (61, 41 + b), (59, 52 + b), (57, 63), (38, 64), (37, 54), (35, 47 + b)])
    P.shade(tor, sk, hi=1.0, shd=3.0)
    P.lline([(41, 50 + b), (45, 52 + b), (50, 51 + b)], 2, tor)
    P.lline([(53, 51 + b), (57, 50 + b)], 2, tor)
    P.lline([(51, 53 + b), (50, 60)], 2, tor)
    P.lline([(46, 56), (47, 56)], 2, tor)
    P.lline([(46, 59), (47, 59)], 2, tor)
    P.lline([(42, 41 + b), (46, 40 + b)], 0, tor)
    band = P.stroke([(38, 39 + b), (48, 50 + b), (58, 61)], [4.8, 4.6, 4.4])
    P.shade(band, maroon, hi=1.0, shd=1.4, clip=tor)
    P.cast(band & tor, 1, 1)
    for i in range(4):
        P.dot(40.6 + i * 4.8, 42.2 + b + i * 5.4 - (0 if i < 2 else (i - 1) * 0.6 * b), GOLD[0], tor)
    belt = P.poly([(37, 61), (58, 60), (58, 65), (37, 66)])
    P.shade(belt, leather, hi=1.0, shd=1.0)
    bk = P.ell(48, 63, 2.6, 2.4)
    P.shade(bk, GOLD, hi=1.0, shd=1.0)
    P.dot(48, 63, GOLD[3])
    # head, chin down, watching over the shield rim
    H = head(P, 52, 28 + b, 1, spec, mood, f == 4 and not bust, neckw=0.8)
    ud = H.poly([(-8.4, 2.4), (-8.6, -3.0), (-6.6, -7.0), (-2.4, -9.0), (3.2, -8.8), (7.0, -6.2), (8.3, -2.6), (7.8, -1.4),
                 (4.0, -2.6), (-1.0, -2.2), (-3.8, -0.4), (-6.0, 2.0)])
    P.shade(ud, red, hi=1.0, shd=2.0)
    P.cast(ud, 0, 1)
    bandm = H.poly([(-8.8, -1.6), (-4.0, -3.0), (4.0, -4.4), (8.4, -4.0), (8.3, -2.4), (4.0, -2.6), (-1.0, -2.2), (-3.8, -0.4), (-8.6, 0.8)])
    P.shade(bandm, maroon, hi=0.0, shd=1.0, clip=ud, edge=False)
    for i in range(5):
        H.dot(-6.2 + i * 3.2, -2.2 - i * 0.45, GOLD[0], bandm)
    knot = H.poly([(1.6, -7.6), (5.6, -14.8), (7.2, -7.8), (5.0, -6.4)])
    P.shade(knot, red, hi=1.0, shd=1.0)
    tail = H.stroke([(-7.8, -0.5), (-9.6 - sw * .3, 5.0), (-10.0 - sw * .6, 9.5)], [3.2, 2.6, 1.6])
    P.shade(tail, maroon, hi=1.0, shd=1.0)
    # the tameng on the far forearm, rim toward the light
    cx, cy = 64.5, 54 + b
    rim = P.ell(cx, cy, 11.6, 14.6)
    P.shade(rim, maroon, hi=1.0, shd=2.0)
    fc = P.ell(cx + 0.5, cy + 0.2, 9.8, 12.6)
    P.shade(fc, red, hi=1.5, shd=3.5)
    ring = P.ell(cx + 0.5, cy, 6.4, 8.4) - P.ell(cx + 0.5, cy, 5.2, 7.0)
    P.flat(ring, maroon, 1, fc)
    for a in range(0, 360, 45):
        P.dot(cx + 0.5 + math.cos(math.radians(a)) * 8.2, cy + math.sin(math.radians(a)) * 10.6, GOLD[1 if 30 < a < 240 else 0])
    boss = P.ell(cx + 0.3, cy, 2.8, 3.4)
    P.shade(boss, GOLD, hi=1.0, shd=1.0)
    P.dot(cx - 0.7, cy - 1.4, GOLD[0])
    # near arm hanging easy, kelewang reversed back along the leg
    hx_, hy_ = 31.0, 69 + b
    if not bust:
        bl = P.poly([(hx_ - 0.6, hy_ + 2), (hx_ + 2.2, hy_ + 3), (hx_ - 2.4, hy_ + 22), (hx_ - 8.6, hy_ + 38),
                     (hx_ - 9.4, hy_ + 33), (hx_ - 5.6, hy_ + 18)])
        P.shade(bl, STEEL, hi=1.0, shd=1.5)
        P.lline([(hx_ + 0.6, hy_ + 5), (hx_ - 3.0, hy_ + 20), (hx_ - 7.6, hy_ + 32)], 0, bl)
        gd = P.stroke([(hx_ - 3.2, hy_ + 2.0), (hx_ + 3.2, hy_ + 3.4)], [2.0, 2.0])
        P.shade(gd, GOLD, hi=1.0, shd=1.0)
    limb(P, [(38, 42 + b), (35.5, 56 + b), (31.5, 66 + b)], [7.2, 5.6, 4.8], sk)
    P.lline([(36, 55 + b), (37, 57 + b)], 2)
    ab = P.stroke([(33.4, 50 + b), (39.2, 51 + b)], [2.0, 2.0])
    P.shade(ab, GOLD, hi=1.0, shd=1.0)
    fist(P, 31.0, 69 + b, sk, -1)
    return H


# ---------------------------------------------------------------- lancer
def lancer(P, f, mood="", bust=False):
    """Prajurit at parade rest: heels in, chest up, the tombak planted by the near foot, far hand behind the back. Turned left."""
    sk = SKINS["sawo"]
    red, indigo, dark, white = ramp("BC3A30"), ramp("34407A"), ramp("2E2834"), WHITE
    b = BREATH[f]
    sw = wave(f, 1.0)
    spec = dict(skin=sk, jaw="narrow", lip="7A3436", eye_y=1)
    # legs in white trousers: weight on the screen-right leg, the other knee eased
    limb(P, [(42, 72), (38.5, 94), (38, 115)], [8.6, 7.0, 6.0], white, shd=2.5)
    foot(P, 37.5, GROUND, -1, sk, 5.5)
    limb(P, [(51, 72), (52, 95), (52, 115)], [8.6, 7.0, 6.0], white, shd=2.5)
    foot(P, 52.5, GROUND, 1, sk, 4.0)
    P.lline([(39, 97), (39, 112)], 2)
    P.lline([(38, 92), (40, 94)], 2)
    # the far arm folded behind the back: only the elbow shows past the body
    limb(P, [(38, 43 + b), (31.5, 54 + b), (40, 60 + b)], [6.4, 5.6, 5.2], red)
    # short indigo wrap with brass dots
    wr = P.poly([(37, 61), (56, 61), (58, 80), (47, 82), (36, 80)])
    P.shade(wr, indigo, hi=1.0, shd=3.0)
    P.fold([(45, 65), (43, 80)], wr)
    P.fold([(53, 65), (55, 79)], wr)
    for i in range(6):
        P.dot(38.6 + i * 3.4, 77.6 + (0.6 if 1 < i < 4 else 0), GOLD[1], wr)
    P.lline([(37, 79), (47, 81), (57, 79)], 3, wr)
    # lurik jacket: red with thin white stripes, closed down the front
    tor = P.poly([(36, 41 + b), (42, 37 + b), (51, 37 + b), (57, 42 + b), (56, 52 + b), (56, 63), (37, 63), (37, 52 + b)])
    P.shade(tor, red, hi=1.0, shd=3.0, edge="all")
    tile(P, tor, ["l..."], {"l": hx("EADCCC")}, ox=1)
    P.lline([(43, 40 + b), (43, 62)], 3, tor)
    P.lline([(44, 40 + b), (44, 62)], 1, tor)
    for i in range(4):
        P.dot(44, 44 + b + i * 4.5, GOLD[0], tor)
    P.fold([(40, 49 + b), (39, 60)], tor)
    collar = P.poly([(40.5, 37 + b), (49.5, 37 + b), (49, 40 + b), (41, 40 + b)])
    P.shade(collar, white, hi=1.0, shd=1.0)
    belt = P.poly([(36.5, 59), (56.5, 59), (56.5, 64), (36.5, 64)])
    P.shade(belt, dark, hi=1.0, shd=1.0)
    bk = P.ell(44, 61.5, 2.6, 2.3)
    P.shade(bk, GOLD, hi=1.0, shd=1.0)
    # head: chin lifted, eyes front
    H = head(P, 45, 27 + b, -1, spec, mood, f == 4 and not bust, hair=True)
    kul = H.poly([(-7.8, -1.6), (-6.6, -21.4), (6.0, -21.8), (7.8, -2.8), (3.0, -3.4), (-3.0, -2.6)])
    P.shade(kul, dark, hi=1.0, shd=2.5)
    P.cast(kul, 0, 1)
    bnd = H.poly([(-8.0, -6.6), (8.0, -7.4), (8.0, -4.2), (-8.0, -3.4)])
    P.shade(bnd, GOLD, hi=1.0, shd=1.0, clip=kul, edge=False)
    H.lline([(-7.0, -8.0), (7.0, -9.0)], 3, kul)
    med = H.ell(2.4, -13.6, 2.2, 2.6)
    P.shade(med, GOLD, hi=1.0, shd=1.0)
    H.dot(2.4, -13.4, REDR[1])
    H.lline([(-5.6, -19.6), (-6.0, -9.0)], 0, kul, only=(1,))
    # tombak: planted beside the near foot, gripped at the chest
    x = 61.5
    if not bust:
        sh = P.stroke([(x, 15), (x, 121.0)], [2.2, 2.2])
        P.shade(sh, WOOD, hi=1.0, shd=1.0)
        blade = P.poly([(x, 1), (x + 2.6, 7), (x + 1.4, 13), (x - 1.4, 13), (x - 2.6, 7)])
        P.shade(blade, STEEL, hi=1.0, shd=1.0)
        P.lline([(x, 2), (x, 12)], 2, blade)
        cl = P.stroke([(x - 1.8, 14.2), (x + 1.8, 14.2)], [2.2, 2.2])
        P.shade(cl, GOLD, hi=1.0, shd=1.0)
        for i, dx in enumerate((-1.6, 0.2, 1.8)):
            ts = P.stroke([(x + dx * 0.6, 15.5), (x + dx + sw * 0.7, 23 + (i % 2) * 2)], [1.8, 1.4])
            P.shade(ts, REDR, hi=1.0, shd=1.0)
        fe = P.stroke([(x - 1.4, 120), (x + 1.4, 120)], [2.6, 2.6])
        P.shade(fe, GOLD, hi=1.0, shd=1.0)
    # near arm up to the shaft
    limb(P, [(55, 43 + b), (59, 55 + b), (61, 50 + b)], [6.6, 5.6, 5.0], red)
    sleeve_cuff(P, 60.5, 51.4 + b, -60, white, w=5.2, ln=2.0)
    fist(P, 61.5, 48.5 + b, sk, -1)
    return H


# ---------------------------------------------------------------- archer
def archer(P, f, mood="", bust=False):
    """Pamanah at ease: hip dropped, the gendewa hanging loose from one hand, the other thumb hooked in the quiver strap.
    Turned left, looking off past the viewer."""
    sk = SKINS["sawo"]
    green, mint, brown, tan = ramp("2F6E54"), ramp("7EC2A0"), ramp("6C4C32"), ramp("C4A256")
    strap = ramp("8C5E34")
    b = BREATH[f]
    sw = wave(f, 1.0)
    spec = dict(skin=sk, jaw="soft", eyes="narrow", lip="7A3436")
    # quiver on the back, its mouth over the near shoulder
    q = P.stroke([(58, 30 + b), (61, 60 + b)], [6.0, 5.4])
    P.shade(q, BAMBOO, hi=1.0, shd=2.0)
    for y in (38, 47, 56):
        P.lline([(55, y + b), (64, y + b + 0.6)], 2, q)
    for i, (c, dx) in enumerate(((WHITE, -2.2), (REDR, 0.2), (WHITE, 2.4))):
        P.line([(58 + dx * 0.5, 30 + b), (57.4 + dx, 23 + b)], WOOD[2])
        fl = P.poly([(56.0 + dx, 18 + b), (58.4 + dx, 18.5 + b), (58.2 + dx, 24 + b), (56.6 + dx, 24 + b)])
        P.shade(fl, c, hi=1.0, shd=1.0)
    # legs in brown pangsi: weight on the screen-right leg, the near knee bent and turned out
    limb(P, [(51.5, 70), (53, 93), (53, 114)], [9.4, 7.0, 5.6], brown, shd=2.5)
    foot(P, 53.5, GROUND, 1, sk, 4.5)
    limb(P, [(43, 71), (38.5, 92), (35.5, 113)], [9.4, 7.0, 5.6], brown, shd=2.5)
    foot(P, 35, GROUND, -1, sk, 6.0)
    for (kx, ky, kx2) in ((53, 98, 53), (37.6, 98, 35.6)):
        wrp = P.stroke([(kx, ky), (kx2, ky + 15)], [6.2, 5.8])
        P.shade(wrp, tan, hi=1.0, shd=1.5)
        for yy in range(ky + 1, ky + 15, 3):
            P.lline([(kx - 3, yy), (kx + 3, yy + 1)], 2, wrp, only=(1,))
    P.fold([(44, 74), (40, 88)], None)
    P.fold([(52, 78), (53, 90)], None)
    # kampret jacket: dark green, a V at the throat, hip length; the shoulder line tips against the hip
    tor = P.poly([(36, 41 + b), (41, 37 + b), (51, 38 + b), (57, 43 + b), (57, 54 + b), (57.5, 69), (38.5, 70), (37, 54 + b)])
    P.shade(tor, green, hi=1.0, shd=3.0)
    vn = P.poly([(40, 37 + b), (46, 37 + b), (42.5, 45 + b)])
    P.shade(vn, sk, hi=1.0, shd=1.0, edge=False)
    P.lline([(46, 37 + b), (42.6, 45 + b), (42.6, 69)], 3, tor)
    P.lline([(41.6, 47 + b), (41.6, 69)], 0, tor, only=(1,))
    for i in range(3):
        P.lline([(43.6, 48 + b + i * 4), (46, 48 + b + i * 4)], 0, tor)
    P.fold([(51, 47 + b), (53, 58)], tor)
    sash = P.poly([(36.5, 61), (56.5, 60), (56.5, 65), (36.5, 66)])
    P.shade(sash, mint, hi=1.0, shd=1.0)
    kn = P.ell(40, 64, 2.4, 2.2)
    P.shade(kn, mint, hi=1.0, shd=1.0)
    tl = P.stroke([(40, 65), (38.5 + sw * .5, 76)], [2.6, 1.6])
    P.shade(tl, mint, hi=1.0, shd=1.0)
    # strap across the chest to the quiver
    st = P.stroke([(55, 39 + b), (38, 62)], [2.6, 2.6])
    P.shade(st, strap, hi=1.0, shd=1.0, clip=tor)
    # head turned left
    H = head(P, 45, 27 + b, -1, spec, mood, f == 4 and not bust)
    ik = H.poly([(-8.2, 1.6), (-8.4, -3.2), (-6.4, -7.2), (-2.0, -9.0), (3.4, -8.8), (7.2, -6.0), (8.2, -2.6), (7.8, -1.6),
                 (4.0, -3.2), (-1.0, -2.6), (-3.6, -0.6), (-5.8, 1.8)])
    P.shade(ik, ramp("7A5230"), hi=1.0, shd=2.0)
    P.cast(ik, 0, 1)
    tb = H.poly([(-8.6, -3.0), (8.2, -5.4), (8.2, -3.0), (4.0, -3.2), (-1.0, -2.6), (-3.6, -0.6), (-8.6, -0.4)])
    P.shade(tb, ramp("3E9C84"), hi=0.0, shd=1.0, clip=ik, edge=False)
    pk = H.poly([(1.6, -8.0), (3.6, -13.2), (6.0, -7.2)])
    P.shade(pk, ramp("7A5230"), hi=1.0, shd=1.0)
    fe = H.stroke([(-4.0, -7.0), (-9.0 + sw * .3, -16.0), (-11.0 + sw * .6, -20.5)], [2.6, 2.2, 1.2])
    P.shade(fe, WHITE, hi=1.0, shd=1.0)
    H.lline([(-4.4, -7.6), (-10.4 + sw * .6, -19.6)], 2, fe)
    # far arm across the body, thumb hooked in the strap
    limb(P, [(38, 43 + b), (37, 55 + b), (44, 53 + b)], [6.4, 5.4, 4.8], green)
    sleeve_cuff(P, 43, 53.4 + b, 0, mint, w=5.0, ln=2.0)
    fist(P, 46, 53 + b, sk, 1)
    # near arm hanging, the gendewa held loose at the grip, lower limb near the ground
    gx, gy = 62.5, 72 + b
    if not bust:
        top, bot = (69.5, 34 + b), (57.5, 112)
        pts = []
        for i in range(17):
            t = i / 16.0
            bx = top[0] + (bot[0] - top[0]) * t
            by = top[1] + (bot[1] - top[1]) * t
            bend = math.sin(t * math.pi) * 4.2 - (math.sin(t * math.pi * 2) * 0.0)
            tip = (1 - min(t, 1 - t) * 8) if min(t, 1 - t) < 0.12 else 0
            pts.append((bx + bend + tip * -1.6, by))
        P.line([top, bot], hx("E8E2D0"))
        bow = P.stroke(pts, [2.6] * 17)
        P.shade(bow, ramp("A2703E"), hi=1.0, shd=1.0)
        grip = P.stroke([(pts[8][0], gy - 4), (pts[8][0] - 0.2, gy + 4)], [3.2, 3.2])
        P.shade(grip, ramp("4E3626"), hi=1.0, shd=1.0)
        for tp in (pts[0], pts[-1]):
            nk = P.ell(tp[0], tp[1], 1.4, 1.4)
            P.shade(nk, GOLD, hi=1.0, shd=0.5)
    limb(P, [(55, 43 + b), (59.5, 57 + b), (62, 68 + b)], [6.6, 5.6, 5.0], green)
    sleeve_cuff(P, 61.8, 67.5 + b, 75, mint, w=5.0, ln=2.0)
    fist(P, 62.5, 71.5 + b, sk, -1)
    return H


# ---------------------------------------------------------------- herder
def herder(P, f, mood="", bust=False):
    """Pangangon leaning easy: hip thrown out, fist on the hip, the bandring swinging from the other hand. Turned left."""
    sk = SKINS["sawo_dk"]
    straw, kut, brown, blue = ramp("DEBC6C"), ramp("E2D6B0"), ramp("8C6C46"), ramp("3E5E90")
    b = BREATH[f]
    sw = wave(f, 1.0)
    spec = dict(skin=sk, jaw="soft", eyes="open", lip="7A3436", blush=True)
    # legs: weight on the screen-right leg under the thrown hip, the other knee bent in, heel up
    limb(P, [(52, 71), (54, 93), (53, 116)], [8.0, 6.0, 4.8], sk)
    foot(P, 53.5, GROUND, 1, sk, 5.0)
    limb(P, [(43, 71), (42, 92), (38, 111)], [8.0, 6.0, 4.6], sk)
    P.lline([(41, 91), (43, 93)], 2)
    toe = P.poly([(35.6, 108), (40.4, 110), (38.6, 116), (36.6, 120), (34, GROUND), (30.4, GROUND), (31.6, 119.6), (34.6, 116)])
    P.shade(toe, sk, hi=1.0, shd=1.0)
    # short trousers to the knee
    sh = P.poly([(39, 64), (57, 63), (59, 72), (59, 87), (49, 88), (48, 78), (46, 86), (37, 86), (37, 72)])
    P.shade(sh, brown, hi=1.0, shd=2.5)
    P.fold([(48, 70), (47, 80)], sh)
    P.fold([(54, 74), (56, 86)], sh)
    P.lline([(37, 86), (46, 86)], 3, sh)
    P.lline([(49, 87), (59, 86)], 3, sh)
    # the akimbo arm (screen left): elbow out, fist on the hip, drawn behind the body
    limb(P, [(39, 43 + b), (30, 54 + b), (37, 63)], [6.4, 5.4, 4.8], sk)
    fist(P, 38, 63, sk, 1)
    # kutang: pale and sleeveless, open at the neck
    tor = P.poly([(37, 42 + b), (41, 38 + b), (52, 38 + b), (58, 42 + b), (57, 52 + b), (58, 64), (39, 65), (39, 54 + b)])
    P.shade(tor, kut, hi=1.0, shd=3.0)
    vn = P.poly([(43, 38 + b), (50, 38 + b), (46, 47 + b)])
    P.shade(vn, sk, hi=1.0, shd=1.0, edge=False)
    P.lline([(43, 38 + b), (46, 47 + b), (50, 38 + b)], 2, tor)
    P.fold([(50, 50 + b), (52, 60)], tor)
    # sarong slung over the far shoulder, across to the near hip
    sa = P.stroke([(41, 39 + b), (49, 51 + b), (57, 63)], [7.6, 7.6, 7.0])
    P.shade(sa, blue, hi=1.0, shd=2.0)
    P.cast(sa, 1, 1)
    tile(P, sa, ["w...", ".w..", "..w.", "...w"], {"w": hx("C8D2E6")})
    P.lline([(38, 41 + b), (46, 53 + b), (53, 64)], 3, sa)
    belt = P.poly([(38.5, 61), (57.5, 60), (57.5, 65), (38.5, 66)])
    P.shade(belt, ramp("6C4C2C"), hi=1.0, shd=1.0)
    # suling tucked in the belt
    su = P.stroke([(50, 58), (56, 72)], [2.6, 2.6])
    P.shade(su, BAMBOO, hi=1.0, shd=1.0)
    for i in range(3):
        P.dot(52.2 + i * 1.3, 64 + i * 3.0, WOOD[3])
    # head under the caping, a little tilted
    H = head(P, 46, 28 + b, -1, spec, mood, f == 4 and not bust)
    apex, base = -21.0, -4.8
    under = H.ell(0.5, base + 0.8, 20.0, 3.2, rot=-4)
    P.flat(under, straw, 3)
    cone = H.poly([(-0.6, apex), (0.8, apex), (21.0, base - 1.4), (20.6, base + 0.8), (-19.4, base + 2.6), (-19.8, base + 0.6)])
    P.shade(cone, straw, hi=1.5, shd=2.0)
    for i in range(-5, 6):
        H.lline([(0.1 + i * 0.25, apex + 2), (i * 3.8, base + 1.0 - i * 0.18)], 2 if i % 2 else 0, cone, only=(0, 1))
    for r in (6.0, 11.0):
        H.lline([(-r * 1.15, apex + r + 1.0 + 0.1 * r), (r * 1.15, apex + r + 0.4)], 2, cone)
    kn = H.ell(0.1, apex - 0.2, 1.4, 1.2)
    P.shade(kn, WOOD, hi=1.0, shd=0.5)
    H.line([(-7.4, -2.0), (-6.6, 5.0), (-3.6, 9.6), (0.4, 11.4)], BAMBOO[2])
    # near arm hanging, the bandring's doubled cord swinging from the fist
    hx_, hy_ = 60.5, 72 + b
    limb(P, [(56, 43 + b), (59, 57 + b), (60.5, 68 + b)], [6.4, 5.4, 4.6], sk)
    fist(P, hx_, hy_, sk, -1)
    if not bust:
        px_, py_ = hx_ + 2.0 + sw * 2.4, hy_ + 22
        P.line([(hx_ - 0.6, hy_ + 2), (px_ - 1.2, py_ - 1)], WHITE[2])
        P.line([(hx_ + 1.0, hy_ + 2), (px_ + 1.0, py_ - 1)], WHITE[1])
        pouch = P.ell(px_, py_, 3.0, 2.4)
        P.shade(pouch, WOOD, hi=1.0, shd=1.0)
        stn = P.ell(px_ - 0.2, py_ - 0.8, 1.6, 1.3)
        P.shade(stn, STEEL, hi=0.5, shd=0.5, edge=False)
    return H


# ---------------------------------------------------------------- rogue
def rogue(P, f, mood="", bust=False):
    """Pendekar in a low silat stance: knees wide and bent, weight back, the open palm guarding forward,
    the kujang reversed along the rear forearm. Turned right."""
    sk = SKINS["sawo"]
    ink, ink2, red = R("54506A", "3A3644", "282434", "17141F"), R("4A465E", "2E2A38", "211E2B", "141119"), ramp("C43A2E")
    b = BREATH[f]
    sw = wave(f, 1.0)
    spec = dict(skin=sk, jaw="narrow", eyes="hooded", lip="6A2C2C")
    # headwrap tails streaming behind
    tails = [P.stroke([(42, 42 + b), (34 - sw, 46 + b), (26 - sw * 1.6, 50 + b)], [3.2, 2.8, 1.6]),
             P.stroke([(42, 44 + b), (35 - sw, 51 + b), (29 - sw * 1.4, 58 + b)], [3.0, 2.6, 1.4])]
    for t in tails:
        P.shade(t, red, hi=1.0, shd=1.0)
    # pangsi legs: deep horse stance, the front leg reaching
    limb(P, [(44, 82), (32, 96), (26, 114)], [11.0, 8.6, 6.4], ink2, shd=3.0)
    foot(P, 25.5, GROUND, -1, sk, 4.5)
    limb(P, [(56, 82), (66, 95), (70, 114)], [11.0, 8.6, 6.4], ink2, shd=3.0)
    foot(P, 70.5, GROUND, 1, sk, 6.5)
    for (x0, y0, x1, y1) in ((28, 104, 26, 114), (68, 104, 70, 114)):
        wr = P.stroke([(x0, y0), (x1, y1)], [6.6, 6.2])
        P.shade(wr, red, hi=1.0, shd=1.5)
        for yy in range(y0 + 1, y1, 3):
            P.lline([(x0 - 4, yy), (x0 + 4, yy + 1)], 2, wr, only=(1,))
    seat = P.poly([(40, 76), (60, 76), (62, 86), (50, 91), (38, 86)])
    P.shade(seat, ink2, hi=1.0, shd=3.0)
    P.fold([(49, 80), (50, 89)], seat)
    P.fold([(37, 89), (31, 97)], None)
    P.fold([(60, 88), (65, 95)], None)
    # torso leaning in over the front knee
    tor = P.poly([(39, 51 + b), (46, 46 + b), (57, 45 + b), (63, 49 + b), (62, 60 + b), (60, 78), (41, 79), (40, 66)])
    P.shade(tor, ink, hi=1.0, shd=3.0)
    P.lline([(48, 47 + b), (58, 64 + b)], 0, tor)
    P.lline([(49, 47 + b), (59, 64 + b)], 3, tor)
    nk = P.poly([(52, 45 + b), (57, 45 + b), (54, 51 + b)])
    P.shade(nk, sk, hi=1.0, shd=1.0, edge=False)
    P.fold([(44, 58 + b), (43, 70)], tor)
    # wide red sabuk, knot at the hip, ends hanging
    sb = P.poly([(40, 68), (61, 67), (61, 75), (40, 76)])
    P.shade(sb, red, hi=1.0, shd=2.0)
    P.lline([(41, 71), (60, 70)], 2, sb)
    kn = P.ell(42, 72, 3.0, 2.8)
    P.shade(kn, red, hi=1.0, shd=1.0)
    for dx in (0, 2):
        te = P.stroke([(41 + dx, 74), (38 + dx + sw * .6, 86), (37 + dx + sw, 92)], [3.0, 2.6, 1.8])
        P.shade(te, red, hi=1.0, shd=1.0)
    # rear arm (screen left): low by the hip, the kujang reversed out of the fist, edge outward
    hx_, hy_ = 35, 76 + b
    if not bust:
        kujang(P, hx_ - 1.0, hy_ + 1.6, (-0.78, 0.62), 15.0)
        hilt = P.stroke([(hx_ + 0.4, hy_ - 2.6), (hx_ - 0.8, hy_ + 2.4)], [2.6, 2.4])
        P.shade(hilt, WOOD, hi=1.0, shd=1.0)
    limb(P, [(43, 52 + b), (34.5, 63 + b), (34.5, 73 + b)], [6.6, 5.6, 5.0], ink, edge="all")
    fist(P, hx_, hy_, sk, -1)
    # head low and forward, eyes on the opponent
    H = head(P, 56, 38 + b, 1, spec, mood, f == 4 and not bust)
    wrap = H.poly([(-8.6, 4.0), (-8.6, -3.2), (-6.6, -7.4), (-2.0, -9.0), (3.4, -8.8), (7.2, -6.2), (8.3, -2.6), (7.8, -1.2),
                   (4.0, -2.4), (-1.0, -2.0), (-3.6, -0.2), (-6.0, 3.4)])
    P.shade(wrap, ramp("36323F"), hi=1.0, shd=2.0)
    P.cast(wrap, 0, 1)
    H.lline([(-8.4, -1.6), (-3.8, -1.6), (4.0, -3.4), (8.2, -3.4)], 0, wrap)
    H.lline([(-4.0, -8.0), (5.0, -4.6)], 3, wrap)
    kn2 = H.ell(-8.8, -3.2, 1.9, 1.9)
    P.shade(kn2, red, hi=1.0, shd=1.0)
    # front arm: the open palm raised in guard
    limb(P, [(58, 49 + b), (66, 58 + b), (72, 52 + b)], [6.6, 5.6, 5.0], ink)
    sleeve_cuff(P, 71.4, 52.6 + b, -40, red, w=5.0, ln=2.0)
    palm = P.poly([(72, 51 + b), (75, 44 + b), (77.5, 44 + b), (77, 49 + b), (75.5, 53 + b), (72.5, 54 + b)])
    P.shade(palm, sk, hi=1.0, shd=1.0)
    th = P.stroke([(73, 50 + b), (72, 47 + b)], [1.8, 1.4])
    P.shade(th, sk, hi=1.0, shd=0.5)
    P.lline([(75.5, 45 + b), (75.5, 49 + b)], 2, palm)
    return H


# ---------------------------------------------------------------- dancer
def dancer(P, f, mood="", bust=False):
    """Penari Topeng mid-figure: weight sunk on the bent screen-right leg, the other foot up on its toes,
    one fan flung high, the other turned down by the hip, the head tipped toward the low fan. Turned left."""
    sk = SKINS["langsat"]
    mag, teal, kainr = ramp("BA326C"), ramp("30A89A"), ramp("704C30")
    b = BREATH[f]
    sw = wave(f, 1.0)
    sw2 = wave(f, 1.0, 1.4)
    spec = dict(skin=sk, jaw="narrow", eyes="lash", lip="B0404A", blush=True, brow=hx("3A2A30"))
    # selendang ends from the hips, flowing back
    s1 = P.stroke([(55, 64), (60 + sw * 0.8, 84), (61 + sw * 1.4, 104)], [4.4, 4.0, 3.0])
    P.shade(s1, teal, hi=1.0, shd=1.5)
    s2 = P.stroke([(40, 64), (33 + sw * 1.0, 78), (27 + sw * 1.8, 90), (25 + sw * 2.4, 100)], [4.6, 4.2, 3.6, 2.6])
    P.shade(s2, teal, hi=1.0, shd=1.5)
    P.lline([(37, 70), (29 + sw * 1.6, 88)], 2, s2)
    # feet: the screen-right foot flat and bearing, the screen-left on its toes
    limb(P, [(53, 106), (54, 116)], [5.0, 4.4], sk)
    foot(P, 54.5, GROUND, 1, sk, 4.5)
    tip = P.poly([(37, 108), (41, 108), (39.5, 117), (36, GROUND), (33, GROUND), (35, 117)])
    P.shade(tip, sk, hi=1.0, shd=1.0)
    # long batik kain, wrapped tight: shaped by the bent knee
    kain = P.poly([(39, 62), (56, 61), (58, 76), (59, 96), (58, 112), (48, 112), (42, 110), (36, 104), (38, 86), (37, 74)])
    P.shade(kain, kainr, hi=1.0, shd=3.0)
    tile(P, kain, ["........", "..g.....", ".g.g....", "..g.....", "........", "......g.", ".....g.g", "......g."], {"g": GOLD[2]})
    P.fold([(49, 66), (44, 90), (41, 108)], kain)
    P.fold([(54, 70), (55, 100)], kain)
    P.lline([(48, 111), (58, 111)], 0, kain)
    P.lline([(42, 109), (48, 111)], 0, kain)
    P.lline([(36, 103), (42, 109)], 0, kain)
    # far arm (screen right): bent down at the hip, fan turned down and out
    if not bust:
        fan(P, 64, 70 + b, 70 + sw2 * 3, 14, mag)
    limb(P, [(54, 43 + b), (61, 55 + b), (63, 68 + b)], [5.6, 4.6, 4.0], sk)
    ab = P.stroke([(58.5, 49 + b), (63.5, 50 + b)], [2.0, 2.0])
    P.shade(ab, GOLD, hi=1.0, shd=0.5)
    # kemben bodice and kace collar
    tor = P.poly([(39, 43 + b), (55, 43 + b), (56, 52 + b), (55, 63), (40, 63), (39, 52 + b)])
    P.shade(tor, sk, hi=1.0, shd=2.5)
    kem = P.poly([(38.5, 48 + b), (56.5, 47 + b), (55.5, 63), (39.5, 63)])
    P.shade(kem, mag, hi=1.0, shd=2.5)
    P.lline([(39, 48 + b), (56, 47 + b)], 0, kem)
    for i in range(4):
        P.dot(41 + i * 4, 56, GOLD[1], kem)
    belt = P.poly([(39, 60), (56, 59), (56, 64), (39, 65)])
    P.shade(belt, GOLD, hi=1.0, shd=1.0)
    jw = P.ell(46, 62, 2.2, 2.0)
    P.shade(jw, REDR, hi=1.0, shd=1.0)
    # head tipped toward the low fan
    H = head(P, 46, 29 + b, -1, spec, mood, f == 4 and not bust, hair=True)
    # long hair gathered behind into a bun under the sobrah
    bun = H.ell(-8.0, -1.0, 3.4, 4.0)
    P.shade(bun, HAIR, hi=1.0, shd=1.0)
    kace = P.poly([(38, 39 + b), (54, 39 + b), (55, 43 + b), (50, 46 + b), (46, 47 + b), (42, 46 + b), (37, 43 + b)])
    P.shade(kace, GOLD, hi=1.0, shd=1.5)
    for i in range(5):
        P.dot(39.5 + i * 3.4, 43.4 + b - (1 if i == 2 else 0), GOLD[3] if i % 2 else REDR[1], kace)
    # sobrah: gold crown, five points, a red stone, ronce tassels at the temples
    cr = H.poly([(-8.2, -2.6), (-7.6, -9.0), (7.6, -10.0), (8.4, -3.0), (2.0, -3.6), (-3.0, -3.0)])
    P.shade(cr, GOLD, hi=1.0, shd=2.0)
    P.cast(cr, 0, 1)
    for dx, hg in ((-6.0, 4.0), (-3.0, 5.6), (0.4, 8.0), (3.6, 5.6), (6.4, 4.0)):
        sp = H.poly([(dx - 1.6, -9.0), (dx, -9.0 - hg), (dx + 1.6, -9.2)])
        P.shade(sp, GOLD, hi=1.0, shd=0.5)
    st = H.ell(1.0, -6.4, 1.6, 1.6)
    P.shade(st, REDR, hi=1.0, shd=0.5)
    H.lline([(-7.8, -4.0), (8.2, -4.6)], 2, cr)
    for (tx, n) in ((-7.6, 5), (7.8, 3)):
        for i in range(n):
            bd = H.ell(tx + sw * 0.15 * i, 0.2 + i * 2.6, 1.3, 1.3)
            P.shade(bd, REDR if i % 2 == 0 else WHITE, hi=0.5, shd=0.5)
    # the topeng pushed up at the temple
    mx, my = -6.6, -12.4
    mk = H.ell(mx, my, 3.8, 4.6, rot=-20)
    P.shade(mk, WHITE, hi=1.0, shd=1.5)
    H.line([(mx - 1.6, my - 0.8), (mx - 0.4, my - 0.6)], LID)
    H.line([(mx + 1.0, my - 0.8), (mx + 2.0, my - 1.2)], LID)
    H.line([(mx - 0.4, my + 2.4), (mx + 1.2, my + 2.2)], REDR[1])
    # near arm (screen left) flung high, fan open above
    if bust:
        limb(P, [(40, 44 + b), (35, 47 + b)], [5.6, 5.0], sk)
        return H
    fan(P, 29, 31 + b, -125 + sw * 3, 15, mag)
    limb(P, [(40, 44 + b), (32, 46 + b), (29, 35 + b)], [5.6, 4.6, 4.0], sk)
    ab = P.stroke([(34, 43 + b), (35, 48 + b)], [2.0, 2.0])
    P.shade(ab, GOLD, hi=1.0, shd=0.5)
    br = P.stroke([(27.6, 37.4 + b), (31.2, 38 + b)], [1.8, 1.8])
    P.shade(br, GOLD, hi=1.0, shd=0.5)
    return H


def kujang(P, x, y, u, L):
    """A working kujang from the hilt (x, y) along u: a belly on the edge side, the notch in the spine near the tip."""
    n = (-u[1], u[0]) if u[1] * 1 + u[0] * 0 > 0 else (u[1], -u[0])
    n = (abs(n[0]) * (1 if u[0] < 0 else -1), abs(n[1]))          # edge side faces down
    ts = (0.0, 0.15, 0.32, 0.48, 0.56, 0.64, 0.82, 1.0)
    edge = (1.2, 1.9, 2.4, 2.0, 1.6, 1.3, 0.8, 0.0)
    spine = (1.2, 1.2, 1.0, 0.6, -0.4, 0.7, 0.6, 0.0)
    A, B = [], []
    for t, e, sp in zip(ts, edge, spine):
        c = -math.sin(math.pi * t) * 1.4
        cx, cy = x + u[0] * L * t + n[0] * c, y + u[1] * L * t + n[1] * c
        A.append((cx + n[0] * e, cy + n[1] * e))
        B.append((cx - n[0] * sp, cy - n[1] * sp))
    m = P.poly(A + B[::-1])
    P.shade(m, STEEL, hi=1.0, shd=1.0)
    P.lline(B[1:6], 0, m)
    return m


def fan(P, hx_, hy_, ang, r, rp, spread=56):
    pts = [(hx_, hy_)]
    for a in range(-spread, spread + 1, 4):
        pts.append((hx_ + math.cos(math.radians(ang + a)) * r, hy_ + math.sin(math.radians(ang + a)) * r))
    m = P.poly(pts)
    P.shade(m, rp, hi=1.0, shd=1.5)
    inner = P.poly([(hx_, hy_)] + [(hx_ + math.cos(math.radians(ang + a)) * r * 0.45, hy_ + math.sin(math.radians(ang + a)) * r * 0.45)
                                  for a in range(-spread, spread + 1, 8)])
    P.flat(inner - set(), GOLD, 2, m)
    for i, a in enumerate(range(-spread + 14, spread - 13, 14)):
        P.lline([(hx_ + math.cos(math.radians(ang + a)) * r * 0.5, hy_ + math.sin(math.radians(ang + a)) * r * 0.5),
                 (hx_ + math.cos(math.radians(ang + a)) * r * 0.95, hy_ + math.sin(math.radians(ang + a)) * r * 0.95)], 2, m)
    rim = [(hx_ + math.cos(math.radians(ang + a)) * (r - 0.6), hy_ + math.sin(math.radians(ang + a)) * (r - 0.6))
           for a in range(-spread, spread + 1, 6)]
    P.line(rim, GOLD[1], m)
    return m


# ---------------------------------------------------------------- mage
def mage(P, f, mood="", bust=False):
    """Wiku: weight on the staff planted ahead, the free hand lifted with a letter of ink-light, the lontar at the hip.
    Turned right."""
    sk = SKINS["sawo"]
    robe, trim, teal = CREAM, ramp("B28E56"), ramp("3F8C74")
    fxc = hx("7FF0DC")
    b = BREATH[f]
    sw = wave(f, 1.0)
    pulse = (0.7, 0.85, 1.0, 0.9, 0.75, 0.6)[f]
    spec = dict(skin=sk, jaw="soft", eyes="hooded", lip="7A3436")
    # feet under the robe
    foot(P, 40, GROUND, -1, sk, 4.5)
    foot(P, 55, GROUND, 1, sk, 5.0)
    # far arm (screen right) out to the staff
    limb(P, [(57, 43 + b), (63, 55 + b), (67, 56 + b)], [6.6, 6.0, 5.6], robe)
    # robe: falls straight from the shoulders, the hem swinging a little
    rb = P.poly([(37, 42 + b), (42, 38 + b), (53, 38 + b), (58, 42 + b), (58, 62), (60, 78), (62, 92), (63.5 + sw * .5, 117),
                 (34 + sw * .5, 117), (35, 96), (37, 62)])
    P.shade(rb, robe, hi=1.0, shd=3.0)
    P.fold([(44, 66), (41, 116)], rb)
    P.fold([(51, 66), (56, 92), (57, 116)], rb)
    P.fold([(58, 94), (61, 116)], rb)
    P.fold([(38, 92), (37, 116)], rb)
    P.lline([(53, 86), (57, 92)], 0, rb, only=(1,))
    hem = P.poly([(34 + sw * .5, 108), (62 + sw * .5, 108), (62 + sw * .5, 117), (34 + sw * .5, 117)])
    P.flat(hem, trim, 1, rb)
    P.lline([(34 + sw * .5, 108), (62 + sw * .5, 108)], 2, rb)
    for i in range(7):
        P.dot(36.5 + i * 4 + sw * .5, 112.5, GOLD[0], rb)
    P.lline([(34 + sw * .5, 116.6), (62 + sw * .5, 116.6)], 3, rb)
    # crossed front with trim
    P.lline([(44, 38 + b), (52, 58)], 3, rb)
    tr = P.stroke([(45, 38 + b), (53, 58)], [2.0, 2.0])
    P.flat(tr, trim, 1, rb)
    nk = P.poly([(46, 38 + b), (51, 38 + b), (48, 43 + b)])
    P.shade(nk, sk, hi=1.0, shd=1.0, edge=False)
    # sash with knot, lontar hanging at the hip
    sa = P.poly([(37, 59), (58, 58), (58, 63), (37, 64)])
    P.shade(sa, teal, hi=1.0, shd=1.0)
    kn = P.ell(42, 62, 2.2, 2.0)
    P.shade(kn, teal, hi=1.0, shd=1.0)
    tl = P.stroke([(42, 63), (41 + sw * .5, 76)], [2.4, 1.4])
    P.shade(tl, teal, hi=1.0, shd=1.0)
    P.line([(55, 62), (54, 66)], WOOD[3])
    P.line([(59, 62), (60, 66)], WOOD[3])
    lt = P.poly([(50.5, 66), (63.5, 65), (64, 69.5), (51, 70.5)])
    P.shade(lt, ramp("D8B868"), hi=1.0, shd=1.0)
    P.lline([(52, 68), (62.5, 67.2)], 2, lt)
    for xx in (50.5, 63.5):
        cv = P.poly([(xx - 1.2, 65.4), (xx + 1.2, 65.2), (xx + 1.4, 70.6), (xx - 1.0, 70.8)])
        P.shade(cv, WOOD, hi=1.0, shd=1.0)
    P.dot(57, 67.6, fxc, lt)
    P.glow(57, 68, 6.0, fxc, 0.5 * pulse)
    # head: calm, eyes lowered
    H = head(P, 48, 28 + b, 1, spec, mood, f == 4 and not bust)
    bun = H.ell(-1.6, -9.8, 3.6, 3.4)
    P.shade(bun, HAIR, hi=1.0, shd=1.0)
    bb = H.stroke([(-4.6, -7.6), (1.6, -7.6)], [1.8, 1.8])
    P.shade(bb, GOLD, hi=1.0, shd=0.5)
    hb = H.poly([(-8.0, -2.2), (7.8, -3.8), (7.8, -2.4), (-8.0, -0.8)])
    P.shade(hb, GOLD, hi=1.0, shd=0.5, edge=False)
    H.dot(5.0, -3.2, fxc)
    sp = H.poly([(-4.0, -0.6), (-7.6, -6.4), (-6.0, 4.4)])
    P.shade(sp, GOLD, hi=1.0, shd=1.0)
    # staff in the far hand
    x = 68.5
    if bust:
        x = 200
    sh = P.stroke([(x, 22), (x, 121.0)], [2.4, 2.4])
    P.shade(sh, WOOD, hi=1.0, shd=1.0)
    ring = P.ell(x, 13, 6.0, 6.4) - P.ell(x, 13, 4.4, 4.8)
    P.shade(ring, GOLD, hi=1.0, shd=1.0)
    for a in (210, 330, 90):
        rr = P.ell(x + math.cos(math.radians(a)) * 5.2, 13 + math.sin(math.radians(a)) * 5.4 + 2.6, 1.3, 1.3)
        P.shade(rr, GOLD, hi=0.5, shd=0.5)
    orb = P.ell(x, 13, 2.2, 2.2)
    P.flat(orb, (hx("EFFFF8"), fxc, mix(fxc, hx("2A6A70"), 0.4), hx("2A6A70")), 1)
    P.color([P.at(x - 1, 12)], hx("FFFFFF"))
    P.glow(x, 13, 11.0, fxc, pulse * 0.7)
    cl = P.stroke([(x - 1.8, 20.6), (x + 1.8, 20.6)], [2.2, 2.2])
    P.shade(cl, GOLD, hi=1.0, shd=0.5)
    sleeve_cuff(P, 66.2, 56 + b, 0, trim, w=5.6, ln=2.0)
    fist(P, x, 56 + b, sk, 1)
    # near arm lifted, palm up with a floating aksara of ink-light
    limb(P, [(39, 43 + b), (35, 56 + b), (41, 51 + b)], [6.6, 6.0, 5.6], robe)
    sleeve_cuff(P, 40.4, 51.4 + b, -40, trim, w=5.6, ln=2.0)
    palm = P.poly([(41, 50 + b), (46, 48 + b), (47, 50 + b), (43, 52.5 + b)])
    P.shade(palm, sk, hi=1.0, shd=0.5)
    if not bust:
        gx, gy = 45.0, 41.5 + b - (1 if f in (2, 3) else 0)
        P.glow(gx, gy + 1, 6.0, fxc, pulse)
        ink_ = hx("E8FFF8")
        P.line([(gx - 2, gy - 1), (gx + 2, gy - 1)], ink_)
        P.line([(gx - 1, gy - 1), (gx - 1, gy + 2)], ink_)
        P.line([(gx + 1, gy), (gx + 2.6, gy + 2)], ink_)
    return H


# ---------------------------------------------------------------- dalang
def dalang(P, f, mood="", bust=False):
    """Dalang presenting the kayon: the gunungan raised on its staff toward the audience, the free hand open
    with a flame of lamp light, a slight bow. Turned right."""
    sk = SKINS["sawo"]
    indigo, batik, belt_r = ramp("2F3B68"), ramp("7C5634"), ramp("AA783C")
    fxc = hx("FFC860")
    b = BREATH[f]
    sw = wave(f, 1.0)
    pulse = (0.7, 0.85, 1.0, 0.9, 0.75, 0.6)[f]
    spec = dict(skin=sk, jaw="square", eyes="open", lip="6A2C2C", stache=True)
    # keris hilt rising behind the back hip
    kr = P.stroke([(41, 66), (35, 56 + b)], [2.4, 2.0])
    P.shade(kr, WOOD, hi=1.0, shd=1.0)
    kh = P.ell(34.5, 55 + b, 2.2, 2.0)
    P.shade(kh, GOLD, hi=1.0, shd=0.5)
    # feet
    foot(P, 41, GROUND, -1, sk, 4.5)
    foot(P, 56, GROUND, 1, sk, 5.5)
    # parang kain: long, a stepping split at the front
    kain = P.poly([(38, 62), (58, 61), (60, 90), (61, 116), (36, 116), (37, 90)])
    P.shade(kain, batik, hi=1.0, shd=3.0)
    tile(P, kain, ["p.....", ".p....", "..q...", "...p..", "....p.", "......"], {"p": hx("D4A060"), "q": hx("3A2418")})
    wiru = P.poly([(47, 64), (52, 64), (54, 116), (48, 116)])
    P.shade(wiru, batik, hi=1.0, shd=1.0, clip=kain)
    for xx in (49, 51):
        P.lline([(xx, 66), (xx + 1.5, 115)], 2, wiru)
    tile(P, wiru, ["p..", "...", ".p."], {"p": hx("D4A060")})
    P.lline([(36, 115.6), (61, 115.6)], 3, kain)
    # far arm (screen right) reaching up the kayon staff
    limb(P, [(57, 43 + b), (65, 53 + b), (70.5, 48 + b)], [6.6, 5.6, 5.0], indigo)
    # beskap: indigo, cut away at the front, brass buttons down the diagonal closure
    tor = P.poly([(36, 42 + b), (42, 38 + b), (52, 38 + b), (58, 42 + b), (58, 54 + b), (59, 68), (37, 68), (37, 54 + b)])
    P.shade(tor, indigo, hi=1.0, shd=3.0)
    P.lline([(46, 39 + b), (53, 58), (58, 67)], 3, tor)
    P.lline([(47, 39 + b), (54, 58), (58.6, 65)], 0, tor, only=(1,))
    for i in range(4):
        P.dot(47.6 + i * 1.8, 42 + b + i * 4.2, GOLD[0], tor)
    P.fold([(41, 50 + b), (40, 66)], tor)
    col = P.poly([(44, 37 + b), (51, 37 + b), (49.5, 40 + b), (45.5, 40 + b)])
    P.shade(col, WHITE, hi=1.0, shd=1.0)
    belt = P.poly([(37, 60), (58, 59), (58, 64), (37, 65)])
    P.shade(belt, belt_r, hi=1.0, shd=1.0)
    for i in range(6):
        P.dot(39 + i * 3.2, 62, GOLD[0], belt)
    # head, a slight bow toward the kayon
    H = head(P, 49, 28 + b, 1, spec, mood, f == 4 and not bust)
    bl = H.poly([(-8.6, 3.0), (-8.8, -3.0), (-6.8, -7.6), (-2.0, -9.4), (3.6, -9.0), (7.4, -6.2), (8.4, -2.4), (7.8, -1.2),
                 (4.0, -2.2), (-1.0, -1.8), (-3.6, 0.2), (-6.0, 3.0)])
    P.shade(bl, batik, hi=1.0, shd=2.0)
    P.cast(bl, 0, 1)
    tile(P, bl, ["p..", "...", ".p.", "..."], {"p": hx("D4A060")})
    H.lline([(-8.4, -1.6), (-1.0, -2.6), (8.0, -2.8)], 3, bl)
    H.lline([(-4.0, -8.6), (0.0, -3.0)], 2, bl)
    H.lline([(4.0, -8.4), (1.0, -3.0)], 2, bl)
    mo = H.ell(-9.4, 1.8, 2.4, 3.0)
    P.shade(mo, batik, hi=1.0, shd=1.0)
    # the kayon on its staff, raised toward the audience
    st = P.stroke([(62, 98 + b), (75, 32 + b)], [2.2, 2.0])
    P.shade(st, WOOD, hi=1.0, shd=1.0)
    if True:
        kx, ky = 76, 17 + b
        leaf = [(kx, ky - 15), (kx + 3.5, ky - 10), (kx + 7, ky - 3), (kx + 8, ky + 4), (kx + 5.5, ky + 10), (kx + 2, ky + 13.5),
                (kx, ky + 14.5), (kx - 2, ky + 13.5), (kx - 5.5, ky + 10), (kx - 8, ky + 4), (kx - 7, ky - 3), (kx - 3.5, ky - 10)]
        lf = P.poly(leaf)
        P.shade(lf, GOLD, hi=1.0, shd=2.0)
        inner = P.poly([(kx, ky - 11), (kx + 5, ky - 1), (kx + 4, ky + 9), (kx, ky + 11), (kx - 4, ky + 9), (kx - 5, ky - 1)])
        P.flat(inner, REDR, 2, lf)
        tree = P.poly([(kx, ky - 9), (kx + 2.5, ky + 2), (kx + 1, ky + 9), (kx - 1, ky + 9), (kx - 2.5, ky + 2)])
        P.flat(tree, GOLD, 1, lf)
        P.lline([(kx, ky - 8), (kx, ky + 10)], 2, lf)
        for dy in (-3, 1, 5):
            P.lline([(kx - 3.5, dy + ky + 2), (kx, dy + ky)], 2, lf)
            P.lline([(kx + 3.5, dy + ky + 2), (kx, dy + ky)], 2, lf)
        gate = P.poly([(kx - 3, ky + 9), (kx + 3, ky + 9), (kx + 3, ky + 13), (kx - 3, ky + 13)])
        P.flat(gate, GOLD, 0, lf)
        P.lline([(kx, ky + 9), (kx, ky + 13)], 3, lf)
        P.glow(kx, ky, 13.0, fxc, pulse * 0.45)
    sleeve_cuff(P, 70.2, 48.6 + b, -40, WHITE, w=5.0, ln=2.0)
    fist(P, 72.2, 46 + b, sk, 1)
    # near arm: the open palm lifted toward the kayon, a small flame of the blencong floating above it
    limb(P, [(39, 43 + b), (37.5, 56 + b), (44.5, 54 + b)], [6.6, 5.6, 5.0], indigo, edge="all")
    sleeve_cuff(P, 44.2, 54 + b, -10, WHITE, w=5.0, ln=2.0)
    palm = P.poly([(46, 53 + b), (51, 50.5 + b), (52, 52 + b), (48, 55.5 + b)])
    P.shade(palm, sk, hi=1.0, shd=0.5)
    th = P.stroke([(47, 53 + b), (47.4, 50.6 + b)], [1.6, 1.4])
    P.shade(th, sk, hi=1.0, shd=0.5)
    if not bust:
        fy = 45 + b - (1 if f in (2, 3) else 0)
        P.glow(49.5, fy, 5.0, fxc, pulse)
        fl = P.poly([(49.5, fy - 4), (51, fy), (49.5, fy + 1.5), (48, fy)])
        P.flat(fl, (hx("FFF4D0"), hx("FFE09A"), hx("F0A040"), hx("C06020")), 1)
        P.color([P.at(49.5, fy - 1)], hx("FFFFF0"))
    return H


CLASSES = {"warrior": warrior, "lancer": lancer, "archer": archer, "herder": herder, "rogue": rogue,
           "dancer": dancer, "mage": mage, "dalang": dalang}


# ---------------------------------------------------------------- outputs
def frame(cid, f):
    P = Painter(FW, FH)
    CLASSES[cid](P, f)
    return P.image()


def class_strip(cid):
    strip = Image.new("RGBA", (FW * FRAMES, FH), (0, 0, 0, 0))
    for f in range(FRAMES):
        fr = frame(cid, f)
        strip.paste(fr, (f * FW, 0))
    return strip


def bust(cid, mood):
    bg, disc = (0x16, 0x26, 0x2A, 255), (0x22, 0x40, 0x3E, 255)
    img = Image.new("RGBA", (48, 48), bg)
    for y in range(48):
        for x in range(48):
            if (x - 23.5) ** 2 + (y - 22.5) ** 2 <= 23.0 ** 2:
                img.putpixel((x, y), disc)
    probe = Painter(FW, FH)
    H = CLASSES[cid](probe, 0, "", True)
    k = 1.36
    sx = 1 if H.fd > 0 else -1
    # head centre lands at (22, 21) of the bust
    ox = 22 - sx * k * H.cx
    oy = 21 - k * H.cy
    P = Painter(48, 48, k, ox, oy, sx)
    CLASSES[cid](P, 0, mood, True)
    fig = P.image()
    img.alpha_composite(fig)
    return img


def main():
    os.makedirs(OUTDIR, exist_ok=True)
    strips, busts = [], []
    for cid in CLASS_IDS:
        if cid not in CLASSES:
            continue
        st = class_strip(cid)
        st.save(os.path.join(OUTDIR, "class_%s.png" % cid))
        strips.append(st)
        row = []
        for mood in MOODS:
            bimg = bust(cid, mood)
            bimg.save(os.path.join(OUTDIR, "p_hero_%s%s.png" % (cid, "_" + mood if mood else "")))
            row.append(bimg)
        busts.append(row)
    # preview: frame 0 of every class, then the busts
    prev = Image.new("RGBA", (FW * 8 + 18, FH + 8 + 4 * 50 + 8), (44, 40, 58, 255))
    for i, st in enumerate(strips):
        fr = st.crop((0, 0, FW, FH))
        prev.paste(fr, (2 + i * (FW + 2), 4), fr)
        for j, bimg in enumerate(busts[i]):
            prev.paste(bimg, (2 + i * (FW + 2) + 24, FH + 10 + j * 50))
    prev = prev.resize((prev.width * 3, prev.height * 3), Image.NEAREST)
    prev.save(os.path.join(ROOT, "tools", "portraits_preview.png"))
    print("wrote %d class strips and %d busts" % (len(strips), len(strips) * len(MOODS)))


if __name__ == "__main__":
    main()
