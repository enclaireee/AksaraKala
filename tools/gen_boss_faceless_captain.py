#!/usr/bin/env python3
"""Faceless Captain, boss redraw (wave 4 art pass v8). 56x64 cells (was 26x36).

Outputs assets/art/enemies/faceless_captain.png (4x4: idle, walk, telegraph, hurt) and faceless_captain_moves.png
(4x7: cast, slam, dash, roar, rise, kneel, death), the contract of components/enemy_art.gd. Faces RIGHT, feet on the
bottom row, centred. tools/gen_bosses.py and gen_boss_moves.py no longer write these files.
Also writes tools/boss_faceless_captain_preview.png.

This file also holds the rounded-form painter (Paint, mat, ...) and the shared row builder that gen_boss_sangkuriang.py and
gen_boss_barma_wijaya.py import: gen_portraits.py dropped Paint in the hero redraw, so gen_boss_kala.py no longer imports.
Run: python3 tools/gen_boss_faceless_captain.py
"""
import math
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from PIL import Image
import pixlib as P

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "art", "enemies")
OUTLINE = (26, 16, 32, 255)


def hexc(s):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), 255)


def mix(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3)) + (255,)


def mat(h, deep=None, dark=None, light=None):
    """(deep, dark, mid, light): shadows lean to plum, lights to warm paper."""
    m = hexc(h)
    dk = hexc(dark) if dark else mix(mix(m, (0, 0, 0, 255), 0.26), (64, 34, 86, 255), 0.2)
    dp = hexc(deep) if deep else mix(mix(m, (0, 0, 0, 255), 0.55), (40, 20, 56, 255), 0.3)
    lt = hexc(light) if light else mix(m, (255, 240, 208, 255), 0.36)
    return (dp, dk, m, lt)


SKIN = mat("C2814F", "5E2E2A", "94553A", "E6AE7C")
HAIR = mat("2E2634", "120E18", "1E1824", "55485E")
STEEL = mat("AAB6BE", "3E4654", "6E7A88", "F0F5F2")
GOLD = mat("D2A446", "5E3E1C", "9A6E2A", "FAE08A")
WOOD = mat("7C5432", "2E1C16", "523422", "AC7E4C")
WHITE = mat("EFE8D8", "6E6474", "B8AEA8", "FFFFFF")
RED = mat("C0382E")
EYE = hexc("1A1018")


class Paint:
    def __init__(self, w, h, k=1.0, ox=0.0, oy=0.0):
        self.w, self.h, self.k, self.ox, self.oy = w, h, k, ox, oy
        self.pix = {}
        self.soft = set()

    def _box(self, x0, y0, x1, y1):
        k = self.k
        return (max(0, int(x0 * k + self.ox) - 1), max(0, int(y0 * k + self.oy) - 1),
                min(self.w - 1, int(x1 * k + self.ox) + 1), min(self.h - 1, int(y1 * k + self.oy) + 1))

    def region(self, fn, box):
        out = {}
        x0, y0, x1, y1 = self._box(*box)
        for py in range(y0, y1 + 1):
            fy = (py + 0.5 - self.oy) / self.k
            for px_ in range(x0, x1 + 1):
                r = fn((px_ + 0.5 - self.ox) / self.k, fy)
                if r is not None:
                    out[(px_, py)] = r
        return out

    def shade(self, reg, m, clip=None, rim=True, lift=0.0):
        """Paints a region by its normals. Returns the set of pixels painted."""
        done = set()
        for (x, y), (nx, ny) in reg.items():
            if clip is not None and (x, y) not in clip:
                continue
            edge = rim and any((x + dx, y + dy) not in reg for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
            if edge:
                c = m[0]
            else:
                nz = math.sqrt(max(0.0, 1.0 - nx * nx - ny * ny))
                i = -0.52 * nx - 0.6 * ny + 0.52 * nz + lift
                c = m[3] if i > 0.66 else (m[2] if i > 0.12 else m[1])
            self.pix[(x, y)] = c
            self.soft.discard((x, y))
            done.add((x, y))
        return done

    # shapes -------------------------------------------------------------
    def ell(self, cx, cy, rx, ry, m, **kw):
        def fn(x, y):
            nx, ny = (x - cx) / rx, (y - cy) / ry
            return (nx, ny) if nx * nx + ny * ny <= 1.0 else None
        return self.shade(self.region(fn, (cx - rx, cy - ry, cx + rx, cy + ry)), m, **kw)

    def cap(self, ax, ay, bx, by, ra, rb, m, **kw):
        dx, dy = bx - ax, by - ay
        L = dx * dx + dy * dy or 1e-6

        def fn(x, y):
            t = max(0.0, min(1.0, ((x - ax) * dx + (y - ay) * dy) / L))
            r = ra + (rb - ra) * t
            ex, ey = x - (ax + dx * t), y - (ay + dy * t)
            return (ex / r, ey / r) if ex * ex + ey * ey <= r * r else None
        r = max(ra, rb)
        return self.shade(self.region(fn, (min(ax, bx) - r, min(ay, by) - r, max(ax, bx) + r, max(ay, by) + r)), m, **kw)

    def trap(self, rows, m, bend=0.92, **kw):
        """A lathe-shaded band: rows is [(y, x_left, x_right), ...] top to bottom."""
        def fn(x, y):
            if y < rows[0][0] or y > rows[-1][0]:
                return None
            for (y0, l0, r0), (y1, l1, r1) in zip(rows, rows[1:]):
                if y0 <= y <= y1:
                    t = (y - y0) / ((y1 - y0) or 1e-6)
                    l, r = l0 + (l1 - l0) * t, r0 + (r1 - r0) * t
                    if l <= x <= r:
                        return (((x - (l + r) / 2) / ((r - l) / 2 or 1e-6)) * bend, -0.12)
                    return None
            return None
        return self.shade(self.region(fn, (min(r[1] for r in rows), rows[0][0], max(r[2] for r in rows), rows[-1][0])), m, **kw)

    def poly(self, pts, c, clip=None):
        """A flat polygon in one colour."""
        def fn(x, y):
            inside = False
            n = len(pts)
            for i in range(n):
                (x0, y0), (x1, y1) = pts[i], pts[(i + 1) % n]
                if (y0 > y) != (y1 > y) and x < x0 + (x1 - x0) * (y - y0) / (y1 - y0):
                    inside = not inside
            return (0.0, 0.0) if inside else None
        reg = self.region(fn, (min(p[0] for p in pts), min(p[1] for p in pts), max(p[0] for p in pts), max(p[1] for p in pts)))
        for k_ in reg:
            if clip is None or k_ in clip:
                self.pix[k_] = c
                self.soft.discard(k_)
        return set(reg)

    def line(self, pts, c, w=1.0, clip=None):
        """A stroke through pts, w figure units wide."""
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            n = int(max(abs(x1 - x0), abs(y1 - y0)) * self.k * 2) + 1
            for i in range(n + 1):
                t = i / n
                x, y = (x0 + (x1 - x0) * t) * self.k + self.ox, (y0 + (y1 - y0) * t) * self.k + self.oy
                r = max(0.0, (w * self.k - 1.0) / 2.0)
                for py in range(int(y - r), int(y + r) + 1):
                    for px_ in range(int(x - r), int(x + r) + 1):
                        if 0 <= px_ < self.w and 0 <= py < self.h and (clip is None or (px_, py) in clip):
                            self.pix[(px_, py)] = c
                            self.soft.discard((px_, py))

    def dot(self, x, y, c, clip=None):
        self.line([(x, y), (x, y)], c, 1.0, clip)

    def glow(self, cx, cy, r, c, strength=1.0):
        x0, y0, x1, y1 = self._box(cx - r, cy - r, cx + r, cy + r)
        for py in range(y0, y1 + 1):
            for px_ in range(x0, x1 + 1):
                d = math.hypot((px_ + 0.5 - self.ox) / self.k - cx, (py + 0.5 - self.oy) / self.k - cy)
                if d <= r and ((px_, py) not in self.pix or (px_, py) in self.soft):
                    a = int(170 * strength * (1.0 - d / r) ** 1.3)
                    if a > 22:
                        old = self.pix.get((px_, py))
                        self.pix[(px_, py)] = c[:3] + (max(a, old[3] if old else 0),)
                        self.soft.add((px_, py))

    def image(self, bg=None):
        img = Image.new("RGBA", (self.w, self.h), bg or (0, 0, 0, 0))
        solid = {k_ for k_ in self.pix if k_ not in self.soft}
        for k_ in self.soft:
            c = self.pix[k_]
            if bg:
                a = c[3] / 255.0
                c = tuple(int(c[i] * a + bg[i] * (1 - a)) for i in range(3)) + (255,)
            img.putpixel(k_, c)
        for (x, y) in solid:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                k_ = (x + dx, y + dy)
                if k_ not in solid and 0 <= k_[0] < self.w and 0 <= k_[1] < self.h:
                    img.putpixel(k_, OUTLINE)
        for k_ in solid:
            img.putpixel(k_, self.pix[k_])
        return img



# ---------------------------------------------------------------- shared helpers (used by the other two bosses)
REST_R = ((13, 38), (14, 48))
REST_L = ((-13, 38), (-14, 48))


def M(cx, b, sy, ax, pt, ay=1.0):
    """A pose point (dx, y) for a standard shoulder at y 27 -> this body's cell point."""
    return (cx + pt[0] * ax, sy + (pt[1] - 27) * ay + b)


def limb_arm(p, sh, el, ha, sleeve, skin, hand=3.2, th=1.0):
    """Shoulder -> elbow -> hand, drawn upper arm last so the sleeve overlaps the forearm."""
    p.cap(el[0], el[1], ha[0], ha[1], 3.2 * th, 2.8 * th, skin)
    p.cap(sh[0], sh[1], el[0], el[1], 4.2 * th, 3.4 * th, sleeve)
    p.ell(ha[0], ha[1] + 0.6, hand, hand, skin)


def legs_draw(p, cx, hip, lifts, thigh, shin, boot, wid=4.6, spread=5.5, tw=(4.3, 3.8, 3.9, 3.2), st=(0, 0), kneel=False):
    """Two legs. st shifts the feet sideways (a stride); kneel puts the back knee on the ground."""
    if kneel:
        g = 60.0
        p.ell(cx - 19, g, wid - 0.6, 2.4, boot)
        p.cap(cx - 10, g - 2, cx - 17, g - 1, tw[2] * 0.9, tw[3] * 0.9, shin)
        p.cap(cx - 4, hip, cx - 10, g - 2.5, tw[0], tw[1] * 0.95, thigh)
        p.ell(cx + 14, g, wid, 2.7, boot)
        p.cap(cx + 12, hip + 5, cx + 13, g - 2, tw[2], tw[3], shin)
        p.cap(cx + 4, hip, cx + 12, hip + 3, tw[0], tw[1], thigh)
        return
    for i, side in enumerate((-1, 1)):
        fx, lift = cx + side * spread + st[i], lifts[i]
        p.ell(fx, 60.0 - lift, wid, 2.7, boot)
        p.cap(cx + side * (spread - 1.1), hip, fx, 57 - lift, tw[2], tw[3], shin)
        p.cap(cx + side * (spread - 1.0), hip, cx + side * (spread - 0.5) + st[i] * 0.4, hip + 7, tw[0], tw[1], thigh)


def orb(p, x, y, r, m):
    p.ell(x, y, r, r, m)
    p.ell(x - r * 0.3, y - r * 0.3, max(1.0, r * 0.35), max(1.0, r * 0.35), (m[3], m[3], m[3], m[3]), rim=False)


def rect(p, x0, y0, x1, y1, c):
    for y in range(int(y0), int(y1)):
        for x in range(int(x0), int(x1)):
            if 0 <= x < p.w and 0 <= y < p.h:
                p.pix[(x, y)] = c


def ground_rings(tones, cx, cw, ch):
    """A solid ground ring: an elliptical band 2 px or more thick, lit on the far side, shaded on the near side."""
    def fn(p, r, front):
        if not front:
            return
        cy, k = ch - 7, 0.3
        for y in range(ch):
            for x in range(cw):
                dx, dy = x + 0.5 - cx, y + 0.5 - cy
                if (dx / r) ** 2 + (dy / (r * k + 1.4)) ** 2 <= 1.0 and (dx / (r - 2.4)) ** 2 + (dy / max(0.5, r * k - 1.0)) ** 2 > 1.0:
                    p.pix[(x, y)] = tones[0] if dy < -r * k * 0.4 else (tones[1] if dy < r * k * 0.5 else tones[2])
    return fn


def streaks(tones):
    """Dash streaks: stepped 3 px bars, light on top, mid under."""
    def fn(p, front):
        if not front:
            for i, y in enumerate((29, 37, 45, 53)):
                x1 = 6 + (i % 3) * 4
                rect(p, 0, y, x1, y + 2, tones[0])
                rect(p, 0, y + 2, x1, y + 3, tones[1])
                rect(p, 0, y + 3, x1 - 3, y + 4, tones[2])
    return fn


def fade(img, k):
    out = img.copy()
    out.putalpha(img.getchannel("A").point(lambda v: int(v * k)))
    return out


def sheet(rows, cw, ch):
    """Any column count: columns = the longest row."""
    cols = max(len(r) for r in rows)
    sh = Image.new("RGBA", (cw * cols, ch * len(rows)), (0, 0, 0, 0))
    for r, row in enumerate(rows):
        for c, im in enumerate(row):
            sh.paste(im, (c * cw, r * ch))
    return sh


# ---------------------------------------------------------------- pose tweening (v9: 8-frame rows)
FLAGS = ("mouth", "glow", "tilt", "kneel", "streak")          # discrete: take the nearer key
ZERO = dict(rings=0, chips=0, orb=0.0, breath=0, crouch=0, lean=0.0, sway=0, step=0, legs=(0, 0), st=(0, 0), lift=(0, 0),
            head=(0, 0), mouth=1, glow=False, tilt=False, kneel=False, streak=False, _a=1.0)


def ease(t, kind=None):
    """Easing on 0..1: in (anticipation), out (snap), io (smooth), back (overshoot and settle)."""
    if kind == "in":
        return t * t
    if kind == "out":
        return 1 - (1 - t) ** 2
    if kind == "io":
        return t * t * (3 - 2 * t)
    if kind == "back":
        return 1 + 2.7 * (t - 1) ** 3 + 1.7 * (t - 1) ** 2
    return t


def _lerp(a, b, t):
    if isinstance(a, (tuple, list)):
        return tuple(_lerp(x, y, t) for x, y in zip(a, b))
    return a + (b - a) * t


def lerp_pose(a, b, t):
    """Interpolate two cell(**kw) dicts. Numbers and nested tuples lerp, bools and flag ints (mouth, glow...) take the nearer
    key, rings/chips round to ints. A key on one side only falls back to its ZERO default, else holds."""
    out = {}
    for k in list(a) + [k for k in b if k not in a]:
        va, vb = a.get(k, ZERO.get(k, b.get(k))), b.get(k, ZERO.get(k, a.get(k)))
        if k in FLAGS or isinstance(va, (bool, str)) or isinstance(vb, (bool, str)):
            out[k] = vb if t >= 0.5 else va
        elif k in ("rings", "chips"):
            v = int(round(_lerp(va, vb, t)))
            out[k] = v if v >= 6 or k == "chips" else 0
        else:
            out[k] = _lerp(va, vb, t)
    return out


def expand(keys, n=8, times=None, ease_=None):
    """Inbetween 2..n keyframe dicts into n frames. times = the frame index of each key (default evenly spread; hold after the last),
    ease_ = one easing name or one per segment (see ease())."""
    k = len(keys)
    if times is None:
        times = [round(i * (n - 1) / max(1, k - 1)) for i in range(k)]
    if not isinstance(ease_, (list, tuple)):
        ease_ = [ease_] * (k - 1)
    frames = []
    for f in range(n):
        if f <= times[0] or k == 1:
            frames.append(dict(keys[0]))
            continue
        i = max(j for j in range(k) if times[j] <= f) if f < times[-1] else k - 1
        if i == k - 1:
            frames.append(dict(keys[-1]))
            continue
        t = (f - times[i]) / float(times[i + 1] - times[i])
        frames.append(lerp_pose(keys[i], keys[i + 1], ease(t, ease_[i])))
    return frames


def pulse(a, b, n=4):
    """A seamless n-frame loop a -> b -> a (a coil that breathes in and out)."""
    return [lerp_pose(a, b, 0.5 - 0.5 * math.cos(2 * math.pi * f / n)) for f in range(n)]


def heavier(frames):
    """Default sig1: the slam, bigger. Deeper crouch, more lean, wider rings, one more chip."""
    out = []
    for kw in frames:
        kw = dict(kw)
        kw["crouch"] = kw.get("crouch", 0) * 1.3 + (1 if kw.get("crouch", 0) else 0)
        kw["lean"] = kw.get("lean", 0.0) * 1.3
        if kw.get("rings"):
            kw["rings"] = kw["rings"] + 6
        if kw.get("chips"):
            kw["chips"] = min(3, kw["chips"] + 1)
        out.append(kw)
    return out


def lunging(frames):
    """Default sig2: the dash, longer. Leaning further in, wider stride, streaks all the way."""
    out = []
    for kw in frames:
        kw = dict(kw)
        kw["lean"] = kw.get("lean", 0.0) * 1.5 + 1
        kw["crouch"] = kw.get("crouch", 0) + 1
        for k in ("st", "lift", "legs"):
            if k in kw:
                kw[k] = tuple(v * 1.3 for v in kw[k])
        if kw.get("step"):
            kw["step"] = kw["step"] * 1.3
        kw["streak"] = True
        out.append(kw)
    return out


def assemble(cell, spec, sig1=None, sig2=None):
    """spec maps idle/walk/tele/hurt/cast/slam/dash/roar/rise/kneel/death to 8 pose dicts each; sig1/sig2 are 2..8 keyframe dicts
    (None = default from slam/dash). A '_a' key in a pose is an alpha for the fade. Returns (base_rows, moves_rows)."""
    def draw8(frames):
        res = []
        for kw in frames:
            kw = dict(kw)
            a = kw.pop("_a", 1.0)
            im = cell(**kw)
            res.append(fade(im, a) if a < 1.0 else im)
        return res
    s1 = expand(sig1) if sig1 else heavier(spec["slam"])
    s2 = expand(sig2) if sig2 else lunging(spec["dash"])
    base = [draw8(spec[n]) for n in ("idle", "walk", "tele", "hurt")]
    moves = [draw8(spec[n]) for n in ("cast", "slam", "dash", "roar", "rise", "kneel", "death")] + [draw8(s1), draw8(s2)]
    return base, moves


def build_rows(cell, ang_up=-100, strike=(24, 40), kang=-85, kreach=(5, 30), karm=((13, 40), (14, 44)), sig1=None, sig2=None):
    """The shared pose table, 8 frames a row. cell(**kw) draws one pose: breath, crouch, lean, legs, st, head, arm_l, arm_r, ang,
    reach, glow, mouth, orb, kneel, tilt, sway, rings, streak. sig1/sig2: optional keyframe-dict lists for moves rows 7 and 8."""
    cyc = [2 * math.pi * f / 8 for f in range(8)]
    idle = [dict(breath=1.2 * (0.5 - 0.5 * math.cos(a)), sway=1.4 * math.sin(a - 1.0), head=(0.5 * math.sin(a - 1.4), 0.4 * math.sin(a - 0.6)),
                 arm_l=((-13, 38), (-14, 48 + 0.7 * math.sin(a - 0.8))), arm_r=((13, 38), (14, 48 + 0.7 * math.sin(a - 0.8)))) for a in cyc]
    walk = []
    for a in cyc:       # contact (feet apart, body low) -> pass (one foot lifted, body high), arms counter-swing
        s = 3 * math.cos(a)
        walk.append(dict(breath=abs(math.cos(a)), lean=1.0, st=(-4 * math.cos(a), 4 * math.cos(a)), legs=(3 * max(0, math.sin(a)), 3 * max(0, -math.sin(a))),
                         sway=1.5 * math.sin(a - 0.8), head=(0, 0.5 * math.cos(2 * a)),
                         arm_l=((-13 + s * 0.5, 38), (-14 + s, 48 - abs(s) * 0.5)), arm_r=((13 - s * 0.5, 38), (14 - s, 48 - abs(s) * 0.5))))
    wa = dict(arm_r=((16, 33), (14, 26)), ang=ang_up, glow=True, mouth=2, breath=-1, reach=(10, 26))
    wb = dict(arm_r=((17, 31), (16, 24)), ang=ang_up - 12, glow=True, mouth=2, breath=-1.5, lean=-1.5, crouch=1, reach=(10, 26), sway=1)
    mid = (ang_up + strike[0]) / 2.0
    tele = pulse(wa, wb) + [
        dict(arm_r=((16, 38), (20, 38)), ang=mid, glow=True, mouth=2, crouch=1, lean=1.0, reach=(10, 13), streak=True),
        dict(arm_r=((15, 40), (19, 46)), ang=strike[0], glow=True, mouth=2, crouch=2, lean=3.0, reach=(10, 13)),
        dict(arm_r=((15, 42), (18, 49)), ang=strike[1], glow=True, mouth=2, crouch=3, lean=3.0, reach=(10, 13)),
        dict(arm_r=((15, 42), (18, 49)), ang=strike[1], glow=True, mouth=2, crouch=2, lean=2.0, reach=(10, 13))]
    sa = dict(glow=False, mouth=0, head=(-2, 1), lean=-2.0, tilt=True, ang=-60)
    sb = dict(glow=False, mouth=2, head=(-1, 0), lean=-1.0, tilt=True, ang=-60, sway=1)
    hurt = pulse(sa, sb) + expand([dict(glow=False, mouth=0, head=(-3, 3), lean=-4.5, crouch=3, tilt=True, ang=-35),
                                   dict(glow=False, mouth=0, head=(0, 0), lean=0.5, crouch=0, tilt=True, ang=-70, sway=2), sa],
                                  4, [0, 1, 3], ["out", "io"])
    cl = (((-15, 32), (-16, 22)), ((-15, 30), (-16, 18)), ((-15, 29), (-15, 16)), ((-14, 34), (-13, 25)))
    cast = expand([dict(arm_l=cl[f], orb=(0.2, 0.6, 1.0, 0.3)[f], glow=True, mouth=1) for f in range(4)], 8, [0, 2, 4, 7], "io")
    s_up = dict(arm_r=((16, 33), (14, 26)), arm_l=((-15, 32), (-14, 22)), ang=ang_up, glow=True, mouth=2, breath=-2, reach=(10, 26))
    s_up2 = dict(arm_r=((17, 30), (15, 21)), arm_l=((-16, 28), (-15, 19)), ang=ang_up - 6, glow=True, mouth=2, breath=-3, reach=(10, 26), lean=-1.0)
    s_dn = dict(arm_r=((15, 44), (17, 55)), arm_l=((-14, 44), (-15, 55)), ang=70, glow=True, mouth=2, crouch=4, reach=(8, 9), rings=20)
    s_dn2 = dict(arm_r=((15, 44), (17, 55)), arm_l=((-14, 44), (-15, 55)), ang=70, mouth=1, crouch=3, reach=(8, 9), rings=27)
    slam = expand([s_up, s_up2, s_dn, s_dn2], 8, [0, 3, 4, 7], ["io", "out", "out"])
    d0 = dict(lean=1.0, crouch=2, arm_r=((15, 38), (19, 44)), ang=-8, glow=True, reach=(10, 12), st=(-4, 3))
    d1 = dict(lean=3.0, crouch=2, arm_r=((16, 37), (21, 42)), ang=-4, glow=True, st=(-5, 5), legs=(3, 0), reach=(10, 12), streak=True)
    d2 = dict(lean=4.0, crouch=2, arm_r=((16, 37), (21, 42)), ang=0, glow=True, st=(5, -5), legs=(0, 3), reach=(10, 12), streak=True)
    d3 = dict(lean=2.0, crouch=1, arm_r=((15, 40), (19, 46)), ang=10, reach=(10, 12))
    dash = expand([d0, d1, d2, d3], 8, [0, 2, 5, 7], ["out", "io", "io"])
    r0 = dict(head=(0, 1), mouth=1, breath=1)
    r1 = dict(head=(0, -2), mouth=3, glow=True, arm_l=((-17, 36), (-19, 44)), arm_r=((17, 36), (19, 44)), breath=-1, rings=14)
    r2 = dict(head=(0, -2), mouth=3, glow=True, arm_l=((-17, 36), (-19, 44)), arm_r=((17, 36), (19, 44)), breath=-1, rings=20)
    r3 = dict(head=(0, -1), mouth=2, glow=True, arm_l=((-16, 38), (-17, 46)), arm_r=((16, 38), (17, 46)), rings=26)
    roar = expand([r0, r1, r2, r3], 8, [0, 2, 4, 7], ["in", "io", "io"])
    down = dict(glow=False, mouth=0, tilt=True, ang=kang, reach=kreach, arm_r=karm, arm_l=((-8, 40), (-3, 46)))
    rise = expand([dict(kneel=True, lean=1.0, crouch=11, head=(3, 3), **down), dict(kneel=True, lean=0.5, crouch=9, head=(2, 2), **down),
                   dict(crouch=3, glow=True, mouth=2, rings=16), dict(glow=True, mouth=3, breath=-1, rings=24)], 8, [0, 2, 5, 7], "io")
    kn = expand([dict(kneel=True, lean=1.0, crouch=8, head=(2, 1), **down), dict(kneel=True, lean=1.5, crouch=10.5, head=(3, 2), **down),
                 dict(kneel=True, lean=2.0, crouch=11, head=(3, 3), **down)], 8, [0, 3, 7], "out")
    for f, kw in enumerate(kn):     # the kneeler breathes
        kw["breath"] = 0.5 * math.sin(f * 0.9)
    death = expand([dict(kneel=True, lean=2.0, crouch=11, head=(3, 3), _a=1.0, **down), dict(kneel=True, lean=4.0, crouch=14, head=(5, 6), _a=0.1, **down)],
                   8, None, "in")
    spec = dict(idle=idle, walk=walk, tele=tele, hurt=hurt, cast=cast, slam=slam, dash=dash, roar=roar, rise=rise, kneel=kn, death=death)
    return assemble(cell, spec, sig1, sig2)


# ---------------------------------------------------------------- default phase-2 form
def _accent(bid):
    import inspect
    for fr in inspect.stack()[2:]:
        c = fr.frame.f_globals.get("ACC")
        if isinstance(c, tuple):
            return c
    return GOLD[3]


def powerup(im, cw, ch, acc, seed):
    """Default p2 of one sheet: darker body ramp, an accent rim on the top/right edges, chunky 2-3 px aura chunks (3-4 tones) behind."""
    import random
    from PIL import ImageFilter
    src = im.convert("RGBA")
    px = src.load()
    out = Image.new("RGBA", src.size, (0, 0, 0, 0))
    po = out.load()
    tones = (mix(acc, (30, 14, 44, 255), 0.62), mix(acc, (30, 14, 44, 255), 0.3), acc, mix(acc, (255, 255, 255, 255), 0.55))
    line = OUTLINE[:3]
    W, H = src.size

    def solid(x, y):
        return 0 <= x < W and 0 <= y < H and px[x, y][3] > 0 and px[x, y][:3] != line

    for y in range(H):
        for x in range(W):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            if (r, g, b) == line:
                po[x, y] = (r, g, b, a)
                continue
            c = mix((int(r * 0.74), int(g * 0.72), int(b * 0.8), 255), (64, 34, 86, 255), 0.14)
            if not (solid(x, y - 1) and solid(x + 1, y)):       # lit edge: top and right sides
                c = mix(c, acc, 0.7)
            po[x, y] = c[:3] + (a,)
    for r_ in range(H // ch):
        for c_ in range(W // cw):
            box = (c_ * cw, r_ * ch, (c_ + 1) * cw, (r_ + 1) * ch)
            al = src.crop(box).getchannel("A")
            amax = al.getextrema()[1]
            if amax == 0:
                continue
            near, far = al.filter(ImageFilter.MaxFilter(7)), al.filter(ImageFilter.MaxFilter(17))
            npx, fpx = near.load(), far.load()
            rng = random.Random(seed * 1000 + r_ * 17 + c_)
            cand = [(x, y) for y in range(0, ch - 3, 2) for x in range(0, cw - 3, 2) if fpx[x, y] and not npx[x, y] and not npx[x + 2, y + 2]]
            rng.shuffle(cand)
            cand.sort(key=lambda p: p[1] + rng.random() * 30)      # bias upward, like rising embers
            for (x, y) in cand[:7]:
                n = rng.choice((2, 3))
                for dy in range(n):
                    for dx in range(n):
                        t = tones[3] if (dx, dy) == (0, 0) and n == 3 else tones[2] if dy == 0 else tones[1] if dy < n - 1 or n == 2 else tones[0]
                        X, Y = box[0] + x + dx, box[1] + y + dy
                        if po[X, Y][3] == 0:
                            po[X, Y] = t[:3] + (amax,)
    return out


def finish(bid, cw, ch, base, moves, p2=None, accent=None):
    """Write <bid>.png, <bid>_moves.png and (8-column sheets) <bid>_p2.png, <bid>_p2_moves.png plus the preview. p2 = optional
    (base_rows, moves_rows) the boss drew itself; None = powerup() of the phase-1 frames. 4-column calls (Keris) write no p2."""
    a, b = sheet(base, cw, ch), sheet(moves, cw, ch)
    a.save(os.path.join(OUT, bid + ".png"))
    b.save(os.path.join(OUT, bid + "_moves.png"))
    shs = [a, b]
    if a.width >= cw * 8:
        if p2 is not None:
            a2, b2 = sheet(p2[0], cw, ch), sheet(p2[1], cw, ch)
        else:
            acc = accent or _accent(bid)
            a2, b2 = powerup(a, cw, ch, acc, 1), powerup(b, cw, ch, acc, 2)
        a2.save(os.path.join(OUT, bid + "_p2.png"))
        b2.save(os.path.join(OUT, bid + "_p2_moves.png"))
        shs += [a2, b2]
    pw = sum(s.width for s in shs) + 4 * (len(shs) + 1)
    prev = Image.new("RGBA", (pw, max(s.height for s in shs) + 8), (52, 44, 66, 255))
    x = 4
    for s in shs:
        prev.paste(s, (x, 4), s)
        x += s.width + 4
    prev.resize((prev.width * 3, prev.height * 3), Image.NEAREST).save(os.path.join(ROOT, "tools", "boss_%s_preview.png" % bid))
    print("wrote %s sheets (%dx%d cells, %d columns)" % (bid, cw, ch, a.width // cw))


def draw_cell(cw, ch, body, extra=None, rings=0, ring_tones=None, **kw):
    p = Paint(cw, ch, 1.0, 0.0, 0.0)
    if extra:
        extra(p, False)
    body(p, **kw)
    if extra:
        extra(p, True)
    if rings:
        ground_rings(ring_tones, cw // 2, cw, ch)(p, rings, True)
    return p.image()


def spear(p, hx, hy, ang, back, fwd, shaft=None, head=None, tassel=None):
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    nx, ny = -sa, ca
    bx, by = hx - ca * back, hy - sa * back
    tx, ty = hx + ca * (fwd - 7), hy + sa * (fwd - 7)
    p.cap(bx, by, tx, ty, 1.5, 1.5, shaft or WOOD)
    ex, ey = hx + ca * fwd, hy + sa * fwd
    p.poly([(tx + nx * 2.6, ty + ny * 2.6), (ex, ey), (tx - nx * 2.6, ty - ny * 2.6), (tx - ca * 1.5, ty - sa * 1.5)], (head or STEEL)[2])
    p.line([(tx + nx * 2.2, ty + ny * 2.2), (ex, ey)], (head or STEEL)[3], 1.0)
    p.line([(tx - nx * 2.2, ty - ny * 2.2), (ex, ey)], (head or STEEL)[1], 1.0)
    if tassel:
        p.cap(tx - ca * 2, ty - sa * 2, tx - ca * 2 + nx * 1 - 0.5, ty - sa * 2 + 5, 2.0, 1.2, tassel)


# ---------------------------------------------------------------- Faceless Captain
CW, CH = 56, 64
IRON = mat("4A4E62", "14162A", "2C2F42", "8A90AC")
GLOVE = mat("3A3240", "120C18", "241C2C", "665A74")
CRIM = mat("C4283A", "3E0A18", "7C1426", "F0586A")
MASK = mat("E8E4D6", "5A5468", "A8A2A4", "FFFFF4")
ACC = hexc("FF3B4E")
BRASS = mat("D2A446", "5E3E1C", "9A6E2A", "FAE08A")


IRON2 = mat("3E2E40", "160C1C", "2A1C2C", "7A5A6A")
CRIM2 = mat("8A1C2C", "2A0610", "54101C", "C8404C")
EMBER = hexc("FF4A2A")
EMBER_H = hexc("FFC070")
DUST = mat("8A6A4A", "2A1C16", "5A4030", "C8A474")


def war_banner(p, hx, hy, ang, back, fwd, cl):
    """A war banner pole with brass caps; the cloth hangs from the upper end (the back end when the pole points down)."""
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    bx, by, ex, ey = hx - ca * back, hy - sa * back, hx + ca * fwd, hy + sa * fwd
    p.cap(bx, by, ex, ey, 1.6, 1.6, WOOD)
    p.ell(ex, ey, 1.8, 1.8, BRASS)
    if by > ey:     # the upper end carries the cloth
        bx, by, ex, ey = ex, ey, bx, by
    n = math.hypot(ex - bx, ey - by) or 1.0
    ux, uy = (ex - bx) / n, (ey - by) / n
    px_, py_ = bx + ux * 11, by + uy * 11
    d = 1 if ang > 70 else -1       # planted: the cloth streams forward; raised: it trails behind
    L = 13 if d < 0 else 9
    p.poly([(bx, by), (bx + d * L, by + 1.5), (bx + d * (L - 4), by + 5.5), (bx + d * L, by + 10), (px_ - d, py_ + 1)], cl[2])
    p.poly([(bx, by), (bx + d * L, by + 1.5), (bx + d * (L - 1), by + 3.5), (bx, by + 3)], cl[3])
    p.poly([(bx, by + 8), (bx + d * (L - 1), by + 8.6), (bx + d * L, by + 10), (px_ - d, py_ + 1)], cl[1])
    p.ell(bx + d * L * 0.4, by + 5, 1.8, 1.8, BRASS)
    p.ell(bx, by, 1.9, 1.9, BRASS)


def smear_fx(p, hx, hy, ang, fwd, cl):
    """A motion smear trailing the spear head: stepped 2 px slabs."""
    ca, sa = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    ex, ey = hx + ca * fwd, hy + sa * fwd
    for k, (off, c) in enumerate((((-3.5), cl[1]), (3.5, cl[2]), (0, cl[3]))):
        p.cap(ex - ca * 20 - 4, ey - sa * 20 + off, ex - ca * 4, ey - sa * 4 + off * 0.6, 1.0 if k < 2 else 1.1, 1.6, (c,) * 4, rim=False)


def chips_extra(base, n, tones):
    """Dust chips on the ground, n 1..3 pairs, over the usual extra."""
    def fn(p, front):
        if base:
            base(p, front)
        if front and n:
            for i, (dx, dy, r) in enumerate(((-17, -5, 1.7), (17, -9, 1.9), (-9, -14, 1.5), (11, -17, 1.6), (-22, -13, 1.4), (22, -3, 1.4))[:n * 2]):
                p.ell(CW / 2 + 6 + dx, 58 + dy, r, r, tones)
    return fn


def captain(p, breath=0, crouch=0, lean=0.0, legs=(0, 0), st=(0, 0), head=(0, 0), arm_l=REST_L, arm_r=REST_R, ang=-80, reach=(12, 34),
            glow=False, mouth=1, orb=0.0, tilt=False, sway=0, kneel=False, form=1, banner=False, smear=False):
    """A lean, tall soldier: narrow shoulders, long legs, a tall plume."""
    f2 = form == 2
    iron, crim = (IRON2, CRIM2) if f2 else (IRON, CRIM)
    if f2:      # phase 2: a lower, more aggressive stance
        crouch, lean = crouch + 1.5, lean + 1.0
    b = breath + crouch
    cx = CW / 2 + lean
    hx, hy = cx + 1 + head[0] + lean * 0.4, 12 + b + head[1]
    sy = 22 + b
    if f2:      # ragged cape: a short body and torn tatters
        p.trap([(21 + b, cx - 6, cx + 6), (38 + crouch, cx - 8 - sway, cx + 8 - sway), (48, cx - 10 - sway * 2, cx + 9 - sway * 2)], crim)
        for i, (dx, ln) in enumerate(((-10, 9), (-6, 5), (-2, 10), (2, 4), (6, 8))):
            p.cap(cx + dx - sway * 2, 46, cx + dx - sway * 2.4 - 1, 47 + ln, 2.2, 0.9, crim)
    else:
        p.trap([(21 + b, cx - 6, cx + 6), (38 + crouch, cx - 8 - sway, cx + 8 - sway), (56, cx - 11 - sway * 2, cx + 10 - sway * 2)], crim)   # cape
    F_legs(p, cx, 38 + crouch, legs, iron, iron, GLOVE, wid=4.2, spread=4.2, tw=(3.4, 3.0, 3.0, 2.5), st=st, kneel=kneel)
    p.trap([(38 + crouch, cx - 6.5, cx + 6.5), (50, cx - 8.5, cx + 8.5)], crim)                                    # tassets
    for y in (43, 47):
        p.line([(cx - 7, y + crouch * 0.5), (cx + 7, y + crouch * 0.5)], crim[1], 1.0)
    p.trap([(38 + crouch, cx - 6.5, cx + 6.5), (41 + crouch, cx - 7, cx + 7)], iron)
    tor = p.trap([(19 + b, cx - 4.6, cx + 4.6), (22 + b, cx - 8, cx + 8), (30 + b, cx - 6.8, cx + 6.8), (39 + b, cx - 5.8, cx + 5.8)], iron)
    p.line([(cx - 7, 23 + b), (cx + 5, 37 + b)], crim[2], 2.0, tor)
    p.line([(cx - 7, 22 + b), (cx + 5, 36 + b)], crim[3], 1.0, tor)
    p.line([(cx - 6, 30 + b), (cx + 6, 30 + b)], iron[1], 1.0, tor)
    p.trap([(36 + b, cx - 6, cx + 6), (39 + b, cx - 6, cx + 6)], BRASS)
    p.ell(cx - 0.5, 27 + b, 1.8, 1.8, crim)
    if f2:      # armour cracked: ember-red seams glowing through
        p.glow(cx, 29 + b, 11, EMBER, 0.55)
        p.line([(cx - 5, 21 + b), (cx - 2, 26 + b), (cx - 4, 30 + b), (cx + 1, 34 + b), (cx - 1, 39 + b)], EMBER_H, 1.0, tor)
        p.line([(cx + 4, 24 + b), (cx + 2, 29 + b), (cx + 6, 33 + b)], EMBER, 1.0, tor)
        p.line([(cx - 6, 44 + crouch * 0.5), (cx - 3, 48), (cx - 4, 50)], EMBER, 1.0)
        p.line([(cx + 5, 43 + crouch * 0.5), (cx + 3, 47)], EMBER, 1.0)
    p.cap(hx - 1, hy + 3, cx, 21 + b, 2.6, 3.2, iron)
    p.ell(hx, hy + 0.5, 4.6, 5.8, MASK)
    if glow:
        p.cap(hx - 1.5, hy - 1.6, hx + 1.5, hy - 1.6, 1.0, 1.0, (ACC, ACC, ACC, hexc("FFB0B8")), rim=False)
    if mouth > 1:
        p.cap(hx - 1.6, hy + 3.4, hx + 1.6, hy + 3.4, 0.8, 0.8, (MASK[0],) * 4, rim=False)
    p.trap([(hy - 7, hx - 4.6, hx + 4.6), (hy - 3, hx - 5.6, hx + 5.6)], iron)
    p.cap(hx - 5, hy - 3, hx - 5, hy + 3, 1.4, 1.2, iron)
    p.cap(hx + 5, hy - 3, hx + 5, hy + 3, 1.4, 1.2, iron)
    if f2:      # helm crest torn: a stub and a snapped tuft
        p.cap(hx - 0.5, hy - 7, hx - 4 - sway, hy - 9, 2.4, 1.6, crim)
        p.cap(hx - 4 - sway, hy - 9, hx - 7 - sway, hy - 7, 1.4, 0.8, crim)
        p.cap(hx + 1.5, hy - 7, hx + 2.5, hy - 9, 1.4, 1.0, crim)
        p.line([(hx + 1, hy - 5), (hx + 0, hy - 1), (hx + 2.4, hy + 3)], EMBER_H, 1.0)      # a crack down the mask
    else:
        p.cap(hx - 0.5, hy - 7, hx - 6 - sway, hy - 11, 2.4, 1.4, crim)
        p.cap(hx - 0.5, hy - 7, hx + 3, hy - 12, 2.0, 1.2, crim)
    shl, shr = (cx - 8, sy), (cx + 8, sy)
    el, hl = F_M(cx, b, sy, 0.8, arm_l[0]), F_M(cx, b, sy, 0.8, arm_l[1])
    er, hr = F_M(cx, b, sy, 0.8, arm_r[0]), F_M(cx, b, sy, 0.8, arm_r[1])
    limb_arm(p, shl, el, hl, iron, GLOVE, 2.9, 0.8)
    p.ell(shl[0], shl[1], 4.4, 3.4, iron)
    p.ell(shl[0], shl[1] + 2.2, 3.2, 1.6, iron)
    if orb > 0:
        F_orb(p, hl[0], hl[1] - 7, 1.6 + orb * 3.4, (crim[1], ACC, hexc("FF7A88"), hexc("FFFFFF")))
    if banner:
        war_banner(p, hr[0], hr[1], ang, reach[0], reach[1], crim)
    else:
        if smear:
            smear_fx(p, hr[0], hr[1], ang, reach[1], crim)
        spear(p, hr[0], hr[1], ang, reach[0], reach[1], WOOD, STEEL, crim)
    limb_arm(p, shr, er, hr, iron, GLOVE, 2.9, 0.8)
    p.ell(shr[0], shr[1], 4.4, 3.4, iron)
    p.ell(shr[0], shr[1] + 2.2, 3.2, 1.6, iron)


F_legs, F_M, F_orb = legs_draw, M, orb


def cell(**kw):
    rings = kw.pop("rings", 0)
    streak = kw.pop("streak", False)
    chips = kw.pop("chips", 0)
    tn = (CRIM2 if kw.get("form") == 2 else CRIM)
    base = streaks((tn[3], tn[2], tn[1])) if streak else None
    return draw_cell(CW, CH, captain, extra=chips_extra(base, chips, DUST) if chips else base, rings=rings, ring_tones=(tn[3], tn[2], tn[1]), **kw)


def cell2(**kw):
    return cell(form=2, **kw)


# sig1 "plant the banner": raise it overhead, drive the pole in (impact + dust at col 5), hold. The cloth hangs from the upper end.
SIG1 = [dict(arm_r=((15, 36), (19, 42)), ang=55, reach=(20, 6), crouch=1, lean=-1.0, glow=True),
        dict(arm_r=((17, 30), (16, 25)), arm_l=((6, 34), (16, 30)), ang=40, reach=(20, 6), breath=-1.5, lean=-2.0, glow=True, banner=True),
        dict(arm_r=((17, 29), (15, 21)), arm_l=((6, 32), (14, 26)), ang=30, reach=(20, 6), breath=-2.5, lean=-3.0, glow=True, banner=True, mouth=2),
        dict(arm_r=((15, 44), (17, 54)), ang=84, reach=(22, 6), crouch=4, lean=3.0, glow=True, banner=True, chips=2, mouth=2),
        dict(arm_r=((15, 44), (18, 54)), ang=85, reach=(22, 6), crouch=3, lean=2.0, banner=True, chips=1, mouth=1)]
SIG1_T = [0, 2, 3, 5, 7]
# sig2 "long spear lunge": deep crouch, explosive extension with a smear, recovery
SIG2 = [dict(arm_r=((15, 38), (19, 44)), ang=-8, reach=(10, 12), crouch=1, glow=True),
        dict(arm_r=((10, 38), (6, 42)), ang=-6, reach=(14, 14), crouch=7, lean=-3.0, st=(-4, 3), glow=True, mouth=2),
        dict(arm_r=((16, 37), (10, 41)), ang=-2, reach=(22, 15), crouch=3, lean=6.0, st=(-6, 7), glow=True, streak=True, smear=True, mouth=2),
        dict(arm_r=((16, 37), (10, 41)), ang=0, reach=(22, 15), crouch=3, lean=7.0, st=(-6, 7), glow=True, streak=True, smear=True, mouth=2),
        dict(arm_r=((15, 40), (19, 46)), ang=5, reach=(10, 12), crouch=2, lean=2.0)]
SIG2_T = [0, 3, 4, 5, 7]


def sig(keys, times, ease_):
    return expand(keys, 8, times, ease_)


def main():
    kw = dict(ang_up=-100, strike=(30, 45), kang=-86, kreach=(4, 36))
    s1, s2 = sig(SIG1, SIG1_T, ["io", "io", "in", "io"]), sig(SIG2, SIG2_T, ["io", "out", "io", "io"])
    base, moves = build_rows(cell, sig1=s1, sig2=s2, **kw)
    p2 = build_rows(cell2, sig1=s1, sig2=s2, **kw)
    finish("faceless_captain", CW, CH, base, moves, p2=p2)


if __name__ == "__main__":
    main()
