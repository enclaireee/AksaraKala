#!/usr/bin/env python3
"""Boss telegraph art (art pass v8, combat.md 5.3 "Telegraph look", assets.md 1 "FX standard").

Writes assets/art/telegraph/:
  motif_<key>.png   16x16 tiling fill motifs in white/grey, tinted at runtime by the telegraph's danger colour
                    (kawung, parang, mega, stone, ash, ombak, cinder; BossKit.MOTIF picks one per boss or region)
  chunks.png        16x4, 4 frames of 4x4: pixel chunks for sparks, hazard motes and shot trails (big -> small)
  small_log.png     14x6, Sangkuriang's lobbed and falling logs
  keris_shard.png   14x6, Keris Gandring's orbit blades (points +x, grey, tinted steel)
  drop_mark.png     16x10, the Faceless Captain's drop-in warning ellipse (tinted)
  kala_clock.png    48x48, the gold clock halo behind Batara Kala
and tools/telegraph_preview.png (motif tiles, then circle/ring/cone/line telegraphs in danger red and a neutral).

The preview runs the same row rasterizer as components/boss_kit.gd (Px): shapes are cut into 1 px rows so every
edge steps on the 480x270 grid, the fill is the tiled motif, the edge is a 1 px dark outline plus a 2 px band lit
from the top-left.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from PIL import Image
from pixlib import *  # noqa: F401,F403  (ROOT, save, hexc, PLUM, KEY, plum_outline, strip, ...)

T = (0, 0, 0, 0)
W, G1, G2, G3 = (255, 255, 255, 255), (222, 222, 230, 255), (180, 180, 194, 255), (136, 136, 154, 255)


# --- motif tiles -------------------------------------------------------------------------------------------------

def _tile(fn):
    img = Image.new("RGBA", (16, 16), W)
    for y in range(16):
        for x in range(16):
            c = fn(x, y)
            if c:
                img.putpixel((x, y), c)
    return img


def _wrapd(x, y, cx, cy):
    """Torus offset from (cx, cy) so motifs tile seamlessly."""
    dx = (x + 0.5 - cx + 8) % 16 - 8
    dy = (y + 0.5 - cy + 8) % 16 - 8
    return dx, dy


def kawung():
    """Four palm-fruit petals on the diagonals, meeting at the centre and the corners; a seed dot in the middle."""
    def fn(x, y):
        if 7 <= x <= 8 and 7 <= y <= 8:
            return G3
        for sx, sy in ((1, 1), (-1, 1), (1, -1), (-1, -1)):
            dx, dy = _wrapd(x, y, 8 + 4 * sx, 8 + 4 * sy)
            u = (dx * sx + dy * sy) * 0.7071   # along the petal (centre -> corner)
            v = (dx * sy - dy * sx) * 0.7071
            if (u / 4.4) ** 2 + (v / 2.3) ** 2 <= 1.0:
                return G2 if (dx + dy) > 1.2 else G1   # lower-right half in shade
        return None
    return _tile(fn)


def parang():
    """Lereng diagonals: a 4 px blade band with a shaded lower edge, a mlinjon diamond in each gap."""
    def fn(x, y):
        k = (x - y) % 16
        if 0 <= k < 3:
            return G1
        if 3 <= k < 5:
            return G2
        if 9 <= k <= 10 and (x + y) % 8 in (3, 4):
            return G3
        return None
    return _tile(fn)


def mega():
    """Mega mendung: a cloud of three lobes with a stepped shaded underside (Sandekala, dusk)."""
    lobes = ((5.0, 9.0, 3.4), (9.5, 7.0, 3.8), (13.0, 10.0, 2.8))

    def inside(x, y):
        for cx, cy, r in lobes:
            dx, dy = _wrapd(x, y, cx, cy)
            if dx * dx + dy * dy <= r * r:
                return True
        return False

    def fn(x, y):
        if not inside(x, y):
            return None
        if not inside(x, y + 1) or not inside(x + 1, y + 1):
            return G3
        if not inside(x, y + 2):
            return G2
        return G1
    return _tile(fn)


def stone():
    """Cracked candi slabs: 2-tone joints (shadow + lit lip) on an 8 px offset course, one zigzag crack (Mataram)."""
    def fn(x, y):
        if y % 8 == 7:
            return G3
        if y % 8 == 0:
            return G1
        off = 0 if (y // 8) % 2 == 0 else 8
        if (x + off) % 16 == 15:
            return G3
        if (x + off) % 16 == 0:
            return G1
        crack = {(4, 2): 1, (5, 3): 1, (5, 4): 1, (6, 5): 1, (11, 10): 1, (11, 11): 1, (12, 12): 1, (13, 13): 1}
        if (x, y) in crack:
            return G3
        if (x - 1, y) in crack:
            return G2
        return None
    return _tile(fn)


def ash():
    """Gua Kala ash: drifted flecks in 2-3 px clusters, a darker ember fleck."""
    flecks = {(2, 3): G2, (3, 3): G2, (3, 4): G3, (9, 1): G1, (10, 1): G1, (10, 2): G2,
              (12, 7): G2, (13, 7): G2, (13, 8): G3, (5, 9): G1, (6, 9): G1, (6, 10): G2,
              (1, 13): G2, (2, 13): G3, (10, 12): G1, (11, 12): G2, (11, 13): G3, (14, 14): G2, (15, 14): G2,
              (7, 5): G3, (8, 5): G3}
    return _tile(lambda x, y: flecks.get((x, y)))


def ombak():
    """Segara Kidul waves: scalloped crests, a 2 px lit crest over a shaded trough, half-offset each row."""
    def fn(x, y):
        row = y // 8
        cx = 8 if row % 2 == 0 else 0
        dx, _ = _wrapd(x, 0, cx, 0)
        yy = y % 8
        crest = 2 + round(dx * dx / 16.0)   # a 16 px wide scallop
        if yy == crest or yy == crest + 1:
            return G1
        if yy == crest + 2:
            return G2
        if yy == crest + 3 and abs(dx) < 4:
            return G3
        return None
    return _tile(fn)


def cinder():
    """Tanah Timur dry ground: a crack network round three plates, a cinder speck in each."""
    seeds = ((4, 4), (12, 6), (7, 12))

    def owner(x, y):
        best, bi = 1e9, 0
        for i, (sx, sy) in enumerate(seeds):
            dx, dy = _wrapd(x, y, sx, sy)
            d = dx * dx + dy * dy
            if d < best:
                best, bi = d, i
        return bi

    def fn(x, y):
        o = owner(x, y)
        if owner(x + 1, y) != o or owner(x, y + 1) != o:
            return G3
        if owner(x - 1, y) != o or owner(x, y - 1) != o:
            return G1
        if any((x, y) == (sx, sy) or (x, y) == (sx + 1, sy) for sx, sy in seeds):
            return G2
        return None
    return _tile(fn)


MOTIFS = {"kawung": kawung, "parang": parang, "mega": mega, "stone": stone, "ash": ash, "ombak": ombak, "cinder": cinder}


# --- sprites -----------------------------------------------------------------------------------------------------

def chunks():
    """4 frames of 4x4, white/grey (tinted at runtime): a 4 px lit chunk, 3 px, 2 px, then a 2 px shaded fleck."""
    fr = []
    shapes = [
        [".ww.", "wwg.", "wggd", ".gd."],
        ["....", ".wg.", ".gd.", "..d."],
        ["....", ".wg.", ".gd.", "...."],
        ["....", ".gd.", "....", "...."],
    ]
    pal = {"w": W, "g": G1, "d": G3}
    for rows in shapes:
        f = Image.new("RGBA", (4, 4), T)
        for y, r in enumerate(rows):
            for x, ch in enumerate(r):
                if ch in pal:
                    f.putpixel((x, y), pal[ch])
        fr.append(f)
    return strip(fr)


def small_log():
    """14x6 teak log in the boss_log style: bark ramp, a knot, pale cut ends, plum outline."""
    bark = [hexc("9A6838"), hexc("6E4628"), hexc("442A16")]
    end = [hexc("D8B07A"), hexc("B88A52")]
    img = Image.new("RGBA", (14, 6), T)
    for x in range(2, 12):
        img.putpixel((x, 1), bark[0])
        for y in (2, 3):
            img.putpixel((x, y), bark[1])
        img.putpixel((x, 4), bark[2])
    for x in (5, 9):
        img.putpixel((x, 2), bark[2])
        img.putpixel((x, 3), bark[2])
    for ex in (1, 12):
        for y in (1, 2, 3, 4):
            img.putpixel((ex, y), end[0] if y < 3 else end[1])
    img.putpixel((12, 2), end[1])
    return plum_outline(img)


def keris_shard():
    """14x6 wavy keris shard pointing +x: grey ramp lit top-left, white edge, plum outline (tinted steel)."""
    rows = [
        "..............",
        "..aaab.aab....",
        ".wbbbbbbbbbaw.",
        ".bcccbcccbbc..",
        "..dd.ddd.d....",
        "..............",
    ]
    pal = {"w": KEY["a0"], "a": KEY["a1"], "b": KEY["a1"], "c": KEY["a2"], "d": KEY["a3"]}
    img = Image.new("RGBA", (14, 6), T)
    for y, r in enumerate(rows):
        for x, ch in enumerate(r):
            if ch in pal:
                img.putpixel((x, y), pal[ch])
    img.putpixel((12, 2), KEY["w"])
    return plum_outline(img)


def drop_mark():
    """16x10 warning ellipse (rx 7, ry 4 as before): kawung-grey fill, 1 px dark rim, a lit 1 px band inside."""
    img = Image.new("RGBA", (16, 10), T)
    cx, cy = 8.0, 5.0

    def inside(x, y, rx, ry):
        dx, dy = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
        return dx * dx + dy * dy <= 1.0
    for y in range(10):
        for x in range(16):
            if not inside(x, y, 7, 4):
                continue
            if not inside(x, y, 6, 3):
                img.putpixel((x, y), G3 if (x + 0.5 - cx) + 1.6 * (y + 0.5 - cy) > 0 else W)
            elif not inside(x, y, 5, 2):
                img.putpixel((x, y), G1)
            else:
                img.putpixel((x, y), G2 if (x + y) % 4 == 0 else W)
    return img


def kala_clock():
    """48x48 gold clock halo for Batara Kala (was a flat gold octagon): a lit octagon rim, a darker face, 12 hour
    studs, two hands, plum outline. Same footprint: the octagon spans 48 px."""
    gold = [hexc("FFE6A0"), hexc("E2B64A"), hexc("A87A22"), hexc("6A4A14")]
    face = [hexc("8A6420"), hexc("6A4A14"), hexc("4E3410")]
    img = Image.new("RGBA", (48, 48), T)
    c = 24.0

    def octo(x, y, r):   # inside a regular octagon of circumradius r (vertices on the axes, as the old polygon)
        dx, dy = abs(x + 0.5 - c), abs(y + 0.5 - c)
        return max(dx, dy) * 0.9239 + 0.3827 * min(dx, dy) <= r * 0.9239
    for y in range(48):
        for x in range(48):
            if not octo(x, y, 24):
                continue
            nx, ny = x + 0.5 - c, y + 0.5 - c
            if not octo(x, y, 20):
                img.putpixel((x, y), lit(nx, ny, gold))
            elif not octo(x, y, 18):
                img.putpixel((x, y), lit(-nx, -ny, face))   # the face sits recessed: its rim is lit bottom-right
            else:
                img.putpixel((x, y), face[0] if (nx + ny) < 0 else face[1])
    for i in range(12):
        a = i * math.tau / 12
        sx, sy = round(c - 1 + math.cos(a) * 15), round(c - 1 + math.sin(a) * 15)
        big = i % 3 == 0
        for dy in range(2):
            for dx in range(2 if not big else 3):
                img.putpixel((sx + dx, sy + dy), gold[0] if dy == 0 else gold[1])
    for (a, ln) in ((-math.pi / 2, 12), (math.pi / 6, 8)):   # hands: 2 px wide, gold
        for t in range(2, ln):
            x, y = c - 1 + math.cos(a) * t, c - 1 + math.sin(a) * t
            for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)):
                img.putpixel((int(x) + dx, int(y) + dy), gold[1] if dy == 0 else gold[2])
    for dx in range(-1, 3):
        for dy in range(-1, 3):
            img.putpixel((23 + dx, 23 + dy), gold[0] if dx + dy < 1 else gold[2])
    return plum_outline(img)


# --- the row rasterizer (mirror of BossKit.Px) ------------------------------------------------------------------

class Px:
    """hp: half-planes (a, b, c), a*x + b*y + c >= 0, (a, b) unit; ex: a convex region cut out; ro / ri: radii."""

    def __init__(self, hp=(), ex=(), ro=math.inf, ri=0.0, y0=0, y1=0):
        self.hp, self.ex, self.ro, self.ri, self.y0, self.y1 = list(hp), list(ex), ro, ri, y0, y1

    def inset(self, d):
        return Px([(a, b, c - d) for a, b, c in self.hp], [(a, b, c + d) for a, b, c in self.ex],
                  self.ro - d, self.ri + d if self.ri > 0 else 0.0, self.y0, self.y1)

    @staticmethod
    def _hp_iv(hp, yc):
        lo, hi = -1e9, 1e9
        for a, b, c in hp:
            k = b * yc + c
            if abs(a) < 1e-6:
                if k < 0:
                    return 1.0, -1.0
            elif a > 0:
                lo = max(lo, -k / a)
            else:
                hi = min(hi, -k / a)
        return lo, hi

    @staticmethod
    def _cut(ivs, a, b):
        out = []
        for l, h in ivs:
            if b <= l or a >= h:
                out.append((l, h))
                continue
            if a > l:
                out.append((l, a))
            if b < h:
                out.append((b, h))
        return out

    def row(self, yc):
        lo, hi = -1e9, 1e9
        if self.ro < math.inf:
            q = self.ro * self.ro - yc * yc
            if q < 0:
                return []
            lo, hi = -math.sqrt(q), math.sqrt(q)
        l2, h2 = self._hp_iv(self.hp, yc)
        lo, hi = max(lo, l2), min(hi, h2)
        if lo > hi:
            return []
        out = [(lo, hi)]
        if self.ri > 0:
            q = self.ri * self.ri - yc * yc
            if q > 0:
                out = self._cut(out, -math.sqrt(q), math.sqrt(q))
        if self.ex:
            el, eh = self._hp_iv(self.ex, yc)
            if el <= eh:
                out = self._cut(out, el, eh)
        return out

    @staticmethod
    def pix(ivs):
        out = []
        for l, h in ivs:
            x0, x1 = math.ceil(l - 0.5), math.floor(h - 0.5)
            if x1 >= x0:
                out.append((x0, x1))
        return out

    def spans(self):
        return [(x0, y, x1) for y in range(self.y0, self.y1 + 1) for x0, x1 in self.pix(self.row(y + 0.5))]

    def band(self, d0, d1):
        a, b = self.inset(d0), self.inset(d1)
        out = []
        for y in range(self.y0, self.y1 + 1):
            ivs = a.row(y + 0.5)
            for l, h in b.row(y + 0.5):
                ivs = self._cut(ivs, l, h)
            out += [(x0, y, x1) for x0, x1 in self.pix(ivs)]
        return out

    def normal(self, x, y):
        """Outward normal of the nearest boundary at (x, y)."""
        best, n = 1e9, (0.0, -1.0)
        r = math.hypot(x, y) or 0.001
        if self.ro < math.inf and self.ro - r < best:
            best, n = self.ro - r, (x / r, y / r)
        if self.ri > 0 and r - self.ri < best:
            best, n = r - self.ri, (-x / r, -y / r)
        for a, b, c in self.hp:
            d = a * x + b * y + c
            if d < best:
                best, n = d, (-a, -b)
        for a, b, c in self.ex:
            d = -(a * x + b * y + c)
            if 0 <= d < best:
                best, n = d, (a, b)
        return n


def tone_of(n):
    d = (-n[0] - n[1]) * 0.7071
    return 0 if d > 0.3 else 2 if d < -0.3 else 1


def px_disc(ro, ri=0.0):
    return Px(ro=ro, ri=ri, y0=-int(ro) - 1, y1=int(ro) + 1)


def px_wedge(d, arc, ro, ri=0.0):
    e0, e1 = (math.cos(d - arc / 2), math.sin(d - arc / 2)), (math.cos(d + arc / 2), math.sin(d + arc / 2))
    s = px_disc(ro, ri)
    if arc >= math.tau - 0.001:
        return s
    if arc <= math.pi:
        s.hp = [(-e0[1], e0[0], 0.0), (e1[1], -e1[0], 0.0)]
    else:
        s.ex = [(-e1[1], e1[0], 0.0), (e0[1], -e0[0], 0.0)]
    return s


def px_rect(d, u0, u1, w):
    dx, dy = math.cos(d), math.sin(d)
    nx, ny = -dy, dx
    s = Px([(dx, dy, -u0), (-dx, -dy, u1), (nx, ny, w / 2), (-nx, -ny, w / 2)])
    ys = [dy * u + ny * v for u in (u0, u1) for v in (-w / 2, w / 2)]
    s.y0, s.y1 = math.floor(min(ys)) - 1, math.ceil(max(ys)) + 1
    return s


def _blend(img, x, y, c, a):
    if not (0 <= x < img.width and 0 <= y < img.height) or a <= 0:
        return
    b = img.getpixel((x, y))
    k = a
    img.putpixel((x, y), tuple(int(b[i] * (1 - k) + c[i] * k) for i in range(3)) + (255,))


def _rgb(c):
    return tuple(int(v * 255) for v in c[:3])


def lighten(c, k):
    return tuple(v + (1 - v) * k for v in c[:3])


def darken(c, k):
    return tuple(v * (1 - k) for v in c[:3])


def draw(img, ox, oy, s, fill, fa, edge, ea, bw=3, outline=True, motif=None):
    """Mirror of BossKit.px_draw: motif fill, then the band (1 px outline + lit, or lit only)."""
    if fa > 0:
        for x0, y, x1 in s.spans():
            for x in range(x0, x1 + 1):
                m = motif.getpixel((x % 16, y % 16)) if motif else W
                _blend(img, ox + x, oy + y, tuple(int(fill[i] * m[i] / 255 * 255) for i in range(3)), fa)
    if bw <= 0 or ea <= 0:
        return
    tones = [lighten(edge, 0.45), edge[:3], darken(edge, 0.4), darken(edge, 0.7)]
    parts = ([(0, 1, True)] if outline else []) + [(1 if outline else 0, bw, False)]
    for d0, d1, is_out in parts:
        for x0, y, x1 in s.band(d0, d1):
            t = 3 if is_out else tone_of(s.normal((x0 + x1 + 1) / 2.0, y + 0.5))
            for x in range(x0, x1 + 1):
                _blend(img, ox + x, oy + y, _rgb(tones[t]), ea)


def preview(path):
    red = (1.0, 0.25, 0.2)
    neutral = (0.85, 0.85, 0.75)
    S = 3
    W_, H_ = 480, 300
    img = Image.new("RGBA", (W_, H_), (58, 66, 54, 255))
    for i in range(0, W_, 16):   # ground checker so alpha reads
        for j in range(0, H_, 16):
            if (i // 16 + j // 16) % 2:
                for y in range(j, min(j + 16, H_)):
                    for x in range(i, min(i + 16, W_)):
                        img.putpixel((x, y), (64, 72, 58, 255))
    x = 6
    for k, fn in MOTIFS.items():
        img.alpha_composite(tiled(fn(), 32, 32), (x, 6))
        x += 38
    for row, (col, key) in enumerate(((red, "kawung"), (neutral, "stone"))):
        mot = MOTIFS[key]()
        oy = 90 + row * 104
        f = 0.6   # mid charge
        # circle: back fill, charged fill, outer band, closing band, ticks
        cx = 48
        draw(img, cx, oy, px_disc(30), col, 0.10, col, 0, motif=mot)
        draw(img, cx, oy, px_disc(round(30 * f)), col, 0.18 + 0.30 * f, col, 0, motif=mot)
        draw(img, cx, oy, px_disc(30), col, 0, col, 0.9, 3, True)
        k = round(30 * f)
        draw(img, cx, oy, px_disc(k, k - 3), col, 0, lighten(col, 0.75), 0.55, 3, False)
        for i in range(8):
            a = 0.7 + math.tau * i / 8
            tx, ty = round(math.cos(a) * 28.5), round(math.sin(a) * 28.5)
            for dy in range(3):
                for dx in range(3):
                    _blend(img, cx + tx - 1 + dx, oy + ty - 1 + dy, _rgb(lighten(col, 0.6)), 0.9)
        # ring
        cx = 140
        draw(img, cx, oy, px_disc(36, 20), col, 0.10, col, 0, motif=mot)
        draw(img, cx, oy, px_disc(round(28 + 8 * f), round(28 - 8 * f)), col, 0.18 + 0.3 * f, col, 0, motif=mot)
        draw(img, cx, oy, px_disc(36, 20), col, 0, col, 0.9, 3, True)
        # cone
        cx = 196
        draw(img, cx, oy, px_wedge(-0.3, 1.7, 70), col, 0.10, col, 0, motif=mot)
        k = round(70 * f)
        draw(img, cx, oy, px_wedge(-0.3, 1.7, k), col, 0.18 + 0.3 * f, col, 0, motif=mot)
        draw(img, cx, oy, px_wedge(-0.3, 1.7, 70), col, 0, col, 0.9, 3, True)
        draw(img, cx, oy, px_wedge(-0.3, 1.7, k, k - 3), col, 0, lighten(col, 0.75), 0.55, 3, False)
        # line, angled
        cx = 290
        d = 0.35
        draw(img, cx, oy - 20, px_rect(d, 0, 150, 20), col, 0.10, col, 0, motif=mot)
        k = round(150 * f)
        draw(img, cx, oy - 20, px_rect(d, 0, k, 20), col, 0.18 + 0.3 * f, col, 0, motif=mot)
        draw(img, cx, oy - 20, px_rect(d, 0, 150, 20), col, 0, col, 0.9, 3, True)
        draw(img, cx, oy - 20, px_rect(d, k - 3, k, 20), col, 0, lighten(col, 0.75), 0.55, 3, False)
    # sprites down the right edge
    y = 40
    for im in (chunks(), small_log(), keris_shard(), drop_mark()):
        img.alpha_composite(im, (430, y))
        y += im.height + 4
    img.alpha_composite(kala_clock(), (424, 236))
    img = img.resize((W_ * S, H_ * S), Image.NEAREST)
    img.save(path)


if __name__ == "__main__":
    for k, fn in MOTIFS.items():
        t = fn()
        assert t.size == (16, 16) and all(t.getpixel((x, y))[3] == 255 for x in range(16) for y in range(16)), k
        save(t, "telegraph/motif_%s.png" % k)
    c = chunks()
    assert c.size == (16, 4)
    save(c, "telegraph/chunks.png")
    save(small_log(), "telegraph/small_log.png")
    save(keris_shard(), "telegraph/keris_shard.png")
    save(drop_mark(), "telegraph/drop_mark.png")
    k = kala_clock()
    assert k.size == (48, 48)
    save(k, "telegraph/kala_clock.png")
    # self-check of the rasterizer: a disc covers about pi r^2, a band is about its ring area, wedges sum to the disc
    n = sum(x1 - x0 + 1 for x0, _, x1 in px_disc(20).spans())
    assert abs(n - math.pi * 400) < 40, n
    b = sum(x1 - x0 + 1 for x0, _, x1 in px_disc(20).band(0, 3))
    assert abs(b - math.pi * (400 - 289)) < 30, b
    w = sum(sum(x1 - x0 + 1 for x0, _, x1 in px_wedge(q * math.tau / 4, math.tau / 4, 20).spans()) for q in range(4))
    assert abs(w - n) <= 20, (w, n)   # pixel centres exactly on a shared diagonal edge may fall either way
    big = sum(x1 - x0 + 1 for x0, _, x1 in px_wedge(0.4, 4.5, 20).spans())
    assert abs(big - n * 4.5 / math.tau) < 25, big
    preview(os.path.join(ROOT, "tools", "telegraph_preview.png"))
    print("ok")
