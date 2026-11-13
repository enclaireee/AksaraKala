#!/usr/bin/env python3
"""Budayago enemy sprite sheets, batch A (16 enemies), hero standard (art pass v8).

Each enemy is a function fn(mode, t) -> (body, fx) RGBA canvases of exactly one cell
(facing right, feet on row cell_h-2, so the plum outline lands on the last row).
Body gets the one plum outline; fx (slash arcs, beams) is composited after it.
Modes: idle t0-3, walk t0-3, windup t0-1, strike t0-1, hurt t0-1.
Sheet (components/enemy_art.gd): row0 idle, row1 walk, row2 windup(2) + strike(2), row3 hurt(2) + idle(2).
Shapes are filled with 3 tones lit from the top-left by Cv.shape (no dither).
Run: python3 tools/gen_enemies_a.py   (writes assets/art/enemies/*.png and tools/enemies_a_preview.png)
"""
import os
import sys
from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pixlib as pl
from pixlib import hexc as C, ramp, PLUM

WHITE = (255, 255, 255, 255)
CLEAR = (0, 0, 0, 0)
HERE = os.path.dirname(os.path.abspath(__file__))


# ---------------------------------------------------------------- canvas
class Cv:
    """A cell canvas. shape() fills a mask with a 3 tone ramp lit from the top-left."""

    def __init__(self, w, h):
        self.w, self.h = w, h
        self.im = Image.new("RGBA", (w, h), CLEAR)
        self.fx = Image.new("RGBA", (w, h), CLEAR)
        self.gy = h - 2

    def _mask(self, fn):
        m = Image.new("1", (self.w, self.h), 0)
        fn(ImageDraw.Draw(m))
        return m

    def shape(self, m, rp, big=False):
        mp = m.load()
        ip = self.im.load()
        w, h = self.w, self.h

        def on(x, y):
            return 0 <= x < w and 0 <= y < h and mp[x, y]
        for y in range(h):
            for x in range(w):
                if not mp[x, y]:
                    continue
                if not on(x, y - 1) or not on(x - 1, y):
                    c = rp[0]
                elif not on(x, y + 1) or not on(x + 1, y) or not on(x + 1, y + 1):
                    c = rp[2]
                elif big and not on(x, y + 2):
                    c = rp[2]
                else:
                    c = rp[1]
                ip[x, y] = c

    def rect(self, x0, y0, x1, y1, rp, round_=False, big=False):
        def f(d):
            d.rectangle([x0, y0, x1, y1], fill=1)
            if round_:
                for (x, y) in ((x0, y0), (x1, y0), (x0, y1), (x1, y1)):
                    d.point((x, y), fill=0)
        self.shape(self._mask(f), rp, big)

    def ell(self, x0, y0, x1, y1, rp, big=False):
        self.shape(self._mask(lambda d: d.ellipse([x0, y0, x1, y1], fill=1)), rp, big)

    def poly(self, pts, rp, big=False):
        self.shape(self._mask(lambda d: d.polygon(pts, fill=1)), rp, big)

    def line(self, x0, y0, x1, y1, w, rp):
        self.shape(self._mask(lambda d: d.line([x0, y0, x1, y1], fill=1, width=w)), rp)

    def p(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.im.putpixel((x, y), c)

    def r(self, x0, y0, x1, y1, c):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.p(x, y, c)

    def f(self, x0, y0, x1, y1, c):
        """flat 2 px block / rect on the fx layer (after the outline)."""
        if x1 >= x0 and y1 >= y0:
            ImageDraw.Draw(self.fx).rectangle([x0, y0, x1, y1], fill=c)

    def fp(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.fx.putpixel((x, y), c)

    def result(self, flash=0.0):
        body = self.im
        if flash:
            body = pl.tint(body, WHITE, flash)
        body = pl.plum_outline(body)
        body.alpha_composite(self.fx)
        return body


def build(name, W, H, fn):
    def fr(mode, t=0, flash=0.0):
        cv = fn(mode, t)
        return cv.result(flash)
    idle = [fr("idle", i) for i in range(4)]
    walk = [fr("walk", i) for i in range(4)]
    wu = [fr("windup", i) for i in range(2)]
    st = [fr("strike", i) for i in range(2)]
    hu = [fr("hurt", 0, 0.7), fr("hurt", 1, 0.45)]
    sh = pl.sheet(W, H, 4, 4)
    for i in range(4):
        sh.alpha_composite(idle[i], (i * W, 0))
        sh.alpha_composite(walk[i], (i * W, H))
    for i, f in enumerate([wu[0], wu[1], st[0], st[1]]):
        sh.alpha_composite(f, (i * W, 2 * H))
    for i, f in enumerate([hu[0], hu[1], idle[0], idle[1]]):
        sh.alpha_composite(f, (i * W, 3 * H))
    return sh


STEEL = ramp(C("#b9c4d4"))
WOOD = ramp(C("#a0693a"))
BOOT = ramp(C("#4a3426"))
DARK = C("#1c1220")


# ---------------------------------------------------------------- humanoids
def person(cfg, mode, t):
    CW, CH = cfg["cell"]
    cv = Cv(CW, CH)
    gy = cv.gy
    cx = CW // 2
    tw, th, lh, hw, hh = cfg["tw"], cfg["th"], cfg["lh"], cfg["hw"], cfg["hh"]
    sk, cl, pn = ramp(cfg["skin"]), ramp(cfg["cloth"]), ramp(cfg["pants"])
    robe = cfg.get("robe", False)
    trim = cfg["trim"]
    tr = ramp(trim)
    bob = lean = 0
    fl = [(0, 0), (0, 0)]      # (dx, lift) front, back
    swing = 0
    if mode == "idle":
        bob = 1 if t in (1, 2) else 0
        swing = [0, 0, 1, 1][t]
    elif mode == "walk":
        bob = [1, 0, 1, 0][t]
        fl = [[(2, 0), (0, 0), (-2, 0), (0, 2)][t], [(-2, 0), (0, 2), (2, 0), (0, 0)][t]]
        swing = [-2, 0, 2, 0][t]
    elif mode == "windup":
        lean, bob = -2 - t, t
    elif mode == "strike":
        lean, bob = 1 + t, 1
    elif mode == "hurt":
        lean, bob = -3 + t, 1
    ty1 = gy - lh
    ty0 = ty1 - th + 1 + bob
    tx0 = cx - tw // 2 + lean
    tx1 = tx0 + tw - 1
    hx0 = cx - hw // 2 + 1 + lean
    hx1 = hx0 + hw - 1
    hy1 = ty0 + 1
    hy0 = hy1 - hh + 1
    back_cl = [shade_c(c, 0.82) for c in cl]
    # back arm
    bsx, bsy = tx0 + 1, ty0 + 2
    bhx, bhy = tx0 - 1 - swing // 2 * -1 + (0 if mode != "hurt" else -1), ty0 + th - 2
    if mode == "windup":
        bhx, bhy = tx0 + 2, ty0 + 3
    if mode == "strike":
        bhx, bhy = tx0 - 2, ty0 + 3
    cv.line(bsx, bsy, bhx, bhy, 3, back_cl)
    cv.rect(bhx - 1, bhy, bhx, bhy + 1, sk)
    if cfg.get("quiver"):
        cv.poly([(tx0 - 2, ty0 - 1), (tx0, ty0 - 3), (tx0 + 2, ty0), (tx0, ty0 + 6), (tx0 - 2, ty0 + 4)], WOOD)
        for k in range(3):
            cv.p(tx0 - 2 + k, ty0 - 3 - (k % 2), C("#e8e0c8"))
    # legs / robe
    if robe:
        sway = [0, 1, 0, -1][t] if mode in ("idle", "walk") else 0
        top = ty0 + 1
        cv.poly([(tx0 + 1, top), (tx1 - 1, top), (tx1 + 3, gy - 1), (tx0 - 3 + (-1 if mode == "walk" else 0), gy - 1)], cl, True)
        # ragged hem teeth
        for i, x in enumerate(range(tx0 - 3, tx1 + 4, 2)):
            ln = 1 + ((i + t + (1 if mode == "walk" else 0)) % 2)
            cv.r(x, gy - 1, x + 1, gy - 1 + (1 if ln == 2 else 0), cl[2] if i % 2 else cl[3])
        cv.r(tx0 + 1, gy - 6, tx1 - 1, gy - 6, cl[3])
        # glow wisp under hem
        cv.p(tx0 + 1 + sway, gy, trim)
        cv.p(tx1 - 2 - sway, gy, trim)
    else:
        boot = ramp(cfg.get("boot", C("#4a3426")))
        for i, k in enumerate((1, -3)):   # front leg then back leg
            dx, lift = fl[i]
            lx = cx + k + dx + lean // 2
            col = pn if i == 0 else [shade_c(c, 0.8) for c in pn]
            cv.rect(lx, ty1 - 1, lx + 3, gy - lift - 2, col)
            cv.rect(lx, gy - lift - 2, lx + 4, gy - lift, boot, True)
        # (back leg first would overlap; draw order front last is fine as legs are apart)
    # torso
    if not robe:
        cv.rect(tx0, ty0, tx1, ty1, cl, True, big=True)
        cv.r(tx0, ty1 - 1, tx1, ty1 - 1, tr[1])
        cv.p(tx0 + tw // 2, ty1 - 1, tr[0])
        if cfg.get("sash"):
            for k in range(th - 2):
                cv.r(tx0 + 1 + k * (tw - 3) // max(1, th - 3), ty0 + 1 + k, tx0 + 2 + k * (tw - 3) // max(1, th - 3), ty0 + 1 + k, tr[1])
        if cfg.get("vest"):
            cv.rect(tx0 + 1, ty0 + 1, tx0 + 3, ty1 - 2, ramp(cfg["vest"]))
    else:
        cv.rect(tx0, ty0, tx1, ty0 + 3, cl, True)
        cv.r(tx0 + 1, ty0 + 3, tx1 - 1, ty0 + 3, tr[1])
        if cfg.get("pauldron"):
            cv.rect(tx1 - 2, ty0 - 1, tx1 + 2, ty0 + 3, tr, True)
            cv.rect(tx0 - 2, ty0 - 1, tx0 + 2, ty0 + 3, tr, True)
    # head
    ht = cfg["head"]
    if ht == "mask":
        mk = ramp(cfg["mask"])
        hd = ramp(cfg["cloth"])
        cv.poly([(hx0 - 4, hy1 + 2), (hx0 - 2, hy0), (hx0 + hw // 2 - 1, hy0 - 4), (hx1 + 1, hy0 - 1), (hx1 + 1, hy1)], hd, True)  # hood behind
        cv.ell(hx0, hy0 - 1, hx1, hy1, mk)                              # blank oval mask
        cv.r(hx1 - 3, hy1 - 2, hx1 - 1, hy1 - 2, mk[2])
        cv.p(hx1 - 2, hy0 + 2, mk[2]); cv.p(hx1 - 2, hy0 + 3, mk[2])
        cv.p(hx0 + 1, hy0 + 2, trim)                                 # a single memory spark
        if cfg.get("crest"):
            for k, x in enumerate(range(hx0, hx1 + 1, 2)):
                cv.rect(x, hy0 - 3 - (k % 2), x + 1, hy0, tr)
            cv.r(hx0, hy0 - 1, hx1, hy0, tr[1])
    else:
        cv.rect(hx0, hy0, hx1, hy1, sk, True)
        cv.p(hx1 + 1, hy0 + hh // 2 + 1, sk[1])                        # nose
        cv.p(hx0 - 1, hy0 + hh // 2, sk[2])                            # ear
        ey = hy0 + hh // 2 - 1
        cv.r(hx1 - 2, ey, hx1 - 2, ey + 1, DARK)
        cv.r(hx1 - 5, ey, hx1 - 5, ey + 1, DARK)
        cv.r(hx1 - 3, hy1 - 1, hx1 - 1, hy1 - 1, sk[3])                # mouth
        if ht == "headband":
            cv.rect(hx0 - 1, hy0 - 1, hx1, hy0 + 1, ramp(C("#2a1c24")), True)
            cv.r(hx0 - 1, hy0 + 1, hx1, hy0 + 2, tr[1])
            cv.r(hx0 - 1, hy0 + 1, hx1, hy0 + 1, tr[0])
            fl_ = (t % 2) if mode in ("idle", "walk") else 1
            cv.r(hx0 - 3, hy0 + 1 + fl_, hx0 - 2, hy0 + 2 + fl_, tr[1])
            cv.r(hx0 - 5, hy0 + 2 + fl_ * 2, hx0 - 4, hy0 + 3 + fl_ * 2, tr[2])
            cv.r(hx0 + 1, hy0 + 3, hx0 + 2, hy0 + 3, ramp(C("#2a1c24"))[1])  # sideburn
        elif ht == "cap":
            c2 = ramp(cfg["cap"])
            cv.rect(hx0 - 1, hy0 - 2, hx1, hy0 + 1, c2, True)
            cv.r(hx1, hy0 + 1, hx1 + 2, hy0 + 2, c2[2])               # brim
            cv.r(hx0 - 1, hy0 + 1, hx1, hy0 + 1, c2[2])
            cv.p(hx0 + hw // 2, hy0 - 3, tr[0])
        elif ht == "hood":
            hd = ramp(cfg["hood"])
            cv.poly([(hx0 - 4, hy1 + 3), (hx0 - 2, hy0 + 1), (hx0 + 2, hy0 - 3), (hx1 - 1, hy0 - 2), (hx1 + 1, hy0 + 1),
                     (hx1 - 3, hy0 + 2), (hx0 + 2, hy0 + 3), (hx0 + 3, hy1)], hd, True)
            cv.rect(hx0 - 4, hy0 + 2, hx0 + 1, hy1 + 3, hd, True)
            cv.rect(hx0 + 2, hy0 - 3, hx1 - 1, hy0 + 1, hd, True)
            cv.rect(hx0 - 4, hy0 - 1, hx0 + 1, hy0 + 1, hd)
    # front arm + weapon
    fsx, fsy = tx1 - 1, ty0 + 2
    wl = cfg.get("wl", 9)
    wt = cfg["weapon"]
    if mode == "windup":
        hnd = (tx1 - 1 - t * 2, hy0 - 3 - t) if wt != "bow" else (tx1 + 3, ty0 + 3)
    elif mode == "strike":
        hnd = (tx1 + 3 + t * 2, ty0 + 3 + t * 2)
    elif mode == "hurt":
        hnd = (tx1, ty0 + th - 1)
    else:
        hnd = (tx1 + 2 + swing // 2, ty0 + th - 1 + (1 if mode == "idle" and bob else 0))
        if mode == "walk":
            hnd = (tx1 + 2 - fl[0][0] // 2, ty0 + th - 1)
    # weapon behind the hand gets drawn first when held forward; hand last
    sleeve = cl
    if wt in ("blade", "club", "spear"):
        if mode == "windup":
            d = (-0.55, -1.0) if t == 0 else (-0.9, -0.7)
        elif mode == "strike":
            d = (1.0, 0.25) if t == 0 else (0.85, 0.7)
        elif mode == "hurt":
            d = (0.3, 1.0)
        else:
            d = (0.35, -1.0)
        n = (d[0] ** 2 + d[1] ** 2) ** 0.5
        d = (d[0] / n, d[1] / n)
        hx_, hy_ = hnd
        if wt == "spear":
            back, fwd = 5, wl
            ex, ey2 = hx_ + d[0] * fwd, hy_ + d[1] * fwd
            cv.line(round(hx_ - d[0] * back), round(hy_ - d[1] * back), round(ex), round(ey2), 2, WOOD)
            hd = ramp(trim)
            cv.poly([(round(ex - d[1] * 2), round(ey2 + d[0] * 2)), (round(ex + d[1] * 2), round(ey2 - d[0] * 2)),
                     (round(ex + d[0] * 5), round(ey2 + d[1] * 5))], hd)
            tipx, tipy = round(ex + d[0] * 5), round(ey2 + d[1] * 5)
        elif wt == "blade":
            ex, ey2 = hx_ + d[0] * wl, hy_ + d[1] * wl
            cv.line(round(hx_ - d[0] * 2), round(hy_ - d[1] * 2), round(ex), round(ey2), 2, ramp(cfg.get("steel", C("#cdd5e2"))))
            # curved golok belly: one extra block near the tip
            cv.rect(round(ex - d[0] * 3) - (0 if d[0] > 0.3 else 0), round(ey2 - d[1] * 3) + (1 if d[0] > 0.3 else 0),
                    round(ex - d[0] * 3) + 1, round(ey2 - d[1] * 3) + 2, ramp(cfg.get("steel", C("#cdd5e2"))))
            cv.r(round(hx_ - d[1] * 2), round(hy_ + d[0] * 2), round(hx_ + d[1] * 2), round(hy_ - d[0] * 2), tr[1])  # guard
            tipx, tipy = round(ex), round(ey2)
        else:  # club
            ex, ey2 = hx_ + d[0] * wl, hy_ + d[1] * wl
            cv.line(round(hx_), round(hy_), round(ex), round(ey2), 2, WOOD)
            cv.ell(round(ex) - 2, round(ey2) - 2, round(ex) + 2, round(ey2) + 2, WOOD)
            cv.p(round(ex), round(ey2), C("#9aa4b0")); cv.p(round(ex) + 1, round(ey2) - 1, C("#9aa4b0"))
            tipx, tipy = round(ex), round(ey2)
        cv.line(fsx, fsy, hx_, hy_, 3, sleeve)
        cv.rect(hx_ - 1, hy_ - 1, hx_ + 1, hy_ + 1, sk if ht != "mask" else ramp(cfg["skin"]))
        if mode == "strike":
            fxc = cfg.get("arc", WHITE)
            if t == 0:
                pts = [(hx_ + 1, hy_ - 8), (hx_ + 3, hy_ - 6), (hx_ + 5, hy_ - 4), (hx_ + 6, hy_ - 2)]
            else:
                pts = [(hx_ + 4, hy_ - 5), (hx_ + 6, hy_ - 3), (hx_ + 7, hy_ - 1), (hx_ + 7, hy_ + 1), (hx_ + 6, hy_ + 3)]
            for (ax, ay) in pts:
                cv.f(ax, ay, ax + 1, ay + 1, fxc)
        if cfg.get("glow") and mode in ("windup", "strike"):
            cv.fp(tipx, tipy, WHITE)
    elif wt == "bow":
        wood = ramp(C("#b07a42"))
        sc = C("#e8e0c8") if not cfg.get("glow") else C("#8ff4ff")
        bx = tx1 + 4 + (1 if mode == "strike" else 0)
        by = ty0 - 1 + (2 if mode == "hurt" else 0)
        n = 14
        pts = []
        for k in range(n):
            off = round(3.0 * (1 - ((k - (n - 1) / 2) / ((n - 1) / 2)) ** 2))
            pts.append((bx + off, by + k))
        for (x, y) in pts:
            cv.r(x - 1, y, x, y, wood[1] if y % 3 else wood[0])
        cv.p(pts[0][0], pts[0][1], wood[2]); cv.p(pts[-1][0], pts[-1][1], wood[2])
        pull = 4 if mode == "windup" else 0
        mid_y = by + n // 2
        topx, topy = pts[0][0] - 1, pts[0][1]
        botx, boty = pts[-1][0] - 1, pts[-1][1]
        npx = bx - 1 - pull
        for (ax, ay, bx2, by2) in ((topx, topy, npx, mid_y), (botx, boty, npx, mid_y)):
            ImageDraw.Draw(cv.im).line([ax, ay, bx2, by2], fill=sc)
        hand = (npx - 1, mid_y) if mode == "windup" else (bx + 1, mid_y)
        cv.line(fsx, fsy, hand[0], hand[1], 3, sleeve)
        cv.rect(hand[0] - 1, hand[1] - 1, hand[0] + 1, hand[1] + 1, sk)
        if mode == "windup":
            cv.r(npx, mid_y - 1, bx + 5, mid_y - 1, C("#d8c090"))
            cv.p(bx + 6, mid_y - 1, WHITE)
        elif mode == "strike":
            for k in range(6):
                cv.fp(bx + 4 + k * 2, mid_y, C("#d8c090") if k else WHITE)
                cv.fp(bx + 5 + k * 2, mid_y, C("#d8c090"))
            cv.f(bx + 14, mid_y - 1, bx + 15, mid_y + 1, C("#ffe9a0"))
    return cv


def shade_c(c, f):
    return pl.shade(c, f)


BANDIT = dict(cell=(32, 32), tw=10, th=8, lh=6, hw=9, hh=8, skin=C("#d9a07a"), cloth=C("#2c2c40"), trim=C("#d83a3a"),
              pants=C("#3a3a52"), head="headband", weapon="blade", wl=9, vest=C("#8a4a2a"), sash=True, boot=C("#3a2a22"))
CHASER = dict(cell=(32, 32), tw=11, th=8, lh=6, hw=9, hh=8, skin=C("#d9a07a"), cloth=C("#3f72c0"), trim=C("#e8c040"),
              pants=C("#5a4430"), head="cap", cap=C("#8c96a6"), weapon="club", wl=8)
ARCHER = dict(cell=(32, 32), tw=9, th=8, lh=6, hw=9, hh=8, skin=C("#e0a878"), cloth=C("#d2a15a"), trim=C("#7a2438"),
              pants=C("#4a2a38"), head="hood", hood=C("#9a2e50"), weapon="bow", quiver=True)
FACELESS = dict(cell=(32, 32), tw=9, th=8, lh=6, hw=7, hh=9, skin=C("#ece9df"), cloth=C("#76859a"), trim=C("#5be8ff"),
                pants=C("#3a4252"), head="mask", mask=C("#efede4"), weapon="blade", wl=9, robe=True, glow=True,
                steel=C("#bff7ff"), arc=C("#8ff4ff"))
FACELESS_A = dict(cell=(32, 32), tw=8, th=8, lh=6, hw=7, hh=9, skin=C("#ece9df"), cloth=C("#76859a"), trim=C("#5be8ff"),
                  pants=C("#3a4252"), head="mask", mask=C("#efede4"), weapon="bow", robe=True, glow=True)
CHAMP = dict(cell=(40, 36), tw=14, th=11, lh=8, hw=10, hh=11, skin=C("#ece9df"), cloth=C("#4f5a6e"), trim=C("#e6b84a"),
             pants=C("#2e3442"), head="mask", mask=C("#f4f2ea"), weapon="spear", wl=18, robe=True, glow=True,
             crest=True, pauldron=True)


# ---------------------------------------------------------------- dummy (24x24)
def dummy(mode, t):
    cv = Cv(24, 24)
    gy = cv.gy
    wood = ramp(C("#b9803f"))
    sack = ramp(C("#d8bd78"))
    red = ramp(C("#d8403c"))
    hop = 1 if (mode == "walk" and t in (1, 3)) else 0
    bob = 1 if (mode == "idle" and t in (1, 2)) else 0
    lean = {"windup": -2, "strike": 3, "hurt": -3}.get(mode, 0)
    if mode == "windup":
        lean = -2 - t
    if mode == "strike":
        lean = 2 + t * 2
    if mode == "walk":
        lean = [-1, 0, 1, 0][t]
    # lean = shear: parts higher up move further
    def sx(y):
        return round(lean * (gy - y) / 20)
    base_y = gy - hop
    top = 1 + bob
    o = lambda y: sx(y)
    cv.rect(6, base_y - 2, 17, base_y, wood, True)                                  # cross foot
    cv.rect(11 + o(top + 12), top + 10, 12 + o(top + 12), base_y - 3, wood, big=True)   # post
    cv.rect(8 + o(top + 13), top + 12, 15 + o(top + 13), top + 19, sack, True, big=True)  # sack body
    cv.rect(2 + o(top + 11), top + 11, 21 + o(top + 11), top + 12, wood, True)          # crossbar arms
    for x, d in ((2, -1), (21, 1)):
        cv.rect(x + o(top + 11), top + 13, x + o(top + 11) + 1, top + 16, sack)          # hanging straw
        cv.p(x + o(top + 11), top + 17, C("#e8cf80")); cv.p(x + o(top + 11) + 1, top + 17, C("#e8cf80"))
    cv.rect(8 + o(top + 16), top + 16, 15 + o(top + 16), top + 16, ramp(C("#7a5a30")))   # rope belt
    hx = o(top + 5)
    cv.ell(7 + hx, top, 16 + hx, top + 9, sack, True)
    cv.ell(9 + hx, top + 2, 14 + hx, top + 7, red)
    cv.ell(10 + hx, top + 3, 13 + hx, top + 6, ramp(C("#f0e8d0")))
    cv.r(11 + hx, top + 4, 12 + hx, top + 5, red[1])
    cv.p(7 + hx, top + 2, C("#e8cf80")); cv.p(16 + hx, top + 1, C("#e8cf80")); cv.p(15 + hx, top - 1, C("#e8cf80"))
    if mode == "strike":
        cv.f(19 + hx, top + 4, 20 + hx, top + 5, WHITE)
    return cv


# ---------------------------------------------------------------- arca (temple statues)
def arca_gen(cfg, mode, t):
    CW, CH = cfg["cell"]
    cv = Cv(CW, CH)
    gy = cv.gy
    cx = CW // 2 - 1
    st = ramp(cfg["stone"])
    g = cfg["glow"]
    gh = pl.shade(g, 1.5)
    gold = ramp(cfg["gold"]) if cfg.get("gold") else None
    pw, ph, tw, th, hw, hh = cfg["pw"], cfg["ph"], cfg["tw"], cfg["th"], cfg["hw"], cfg["hh"]
    px = 0
    hop = 0
    bob = 1 if (mode == "idle" and t in (1, 2)) else 0
    if mode == "walk":
        px = [0, 1, 0, -1][t]
        hop = 1 if t in (1, 3) else 0
    elif mode == "windup":
        px = -1 - t
    elif mode == "strike":
        px = 1 + t
    elif mode == "hurt":
        px = -2 - t
    base = gy - hop
    # pedestal
    cv.rect(cx - pw // 2 + px, base - ph + 1, cx + pw // 2 + px, base, st, True, big=True)
    cv.r(cx - pw // 2 + 2 + px, base - ph + 2, cx + pw // 2 - 2 + px, base - ph + 2, st[2])
    ty1 = base - ph
    ty0 = ty1 - th + 1 + bob
    tx0 = cx - tw // 2 + px
    tx1 = tx0 + tw - 1
    # back arm
    cv.rect(tx0 - 3, ty0 + 1, tx0, ty0 + th - 2, st, True)
    # torso
    cv.rect(tx0, ty0, tx1, ty1, st, True, big=True)
    cv.r(tx0, ty1, tx1, ty1, (gold[1] if gold else st[2]))
    if gold:
        cv.r(tx0, ty0 + 2, tx1, ty0 + 2, gold[1])
    # chest gem
    pulse = 2 if mode in ("windup", "strike") else (1 if mode == "idle" and t % 2 else 0)
    gx, gy2 = tx0 + tw // 2, ty0 + 2 + (1 if gold else 0)
    cv.r(gx, gy2, gx + 1, gy2 + 1, gh if pulse else g)
    if pulse == 2:
        cv.p(gx - 1, gy2, g); cv.p(gx + 2, gy2 + 1, g); cv.p(gx, gy2 - 1, g)
    cv.p(tx0 + 1, ty0 + 4, st[3]); cv.p(tx0 + 2, ty0 + 5, st[3])        # crack
    cv.p(tx1 - 2, ty1 - 2, st[3]); cv.p(tx1 - 3, ty1 - 3, st[3])
    # head + crown
    hx0 = cx - hw // 2 + 1 + px
    hy1 = ty0 + 1 + bob * 0
    hy0 = hy1 - hh + 1
    cv.rect(hx0, hy0, hx0 + hw - 1, hy1, st, True)
    cc = gold if gold else st
    cv.rect(hx0 - 1, hy0 - 2, hx0 + hw, hy0 + 1, cc, True)
    for k in range(0, hw + 1, 2):
        cv.rect(hx0 - 1 + k, hy0 - 4 + (k // 2) % 2 * 1, hx0 + k, hy0 - 2, cc)
    cv.rect(hx0 + hw // 2 - 1, hy0 - 6 + (1 if hw < 9 else 0), hx0 + hw // 2 + 1, hy0 - 3, cc)   # crown finial
    ey = hy0 + 3
    eyec = gh if mode in ("windup", "strike") else g
    cv.r(hx0 + hw - 3, ey, hx0 + hw - 2, ey + 1, eyec)
    cv.r(hx0 + hw - 6, ey, hx0 + hw - 5, ey + 1, eyec)
    cv.r(hx0 + hw - 6, hy1 - 1, hx0 + hw - 2, hy1 - 1, st[3])
    if cfg.get("fangs"):
        cv.p(hx0 + hw - 5, hy1, WHITE); cv.p(hx0 + hw - 2, hy1, WHITE)
    # front arm and weapon
    fsx, fsy = tx1 - 1, ty0 + 2
    if cfg["kind"] == "shooter":
        if mode == "windup":
            hnd = (tx1 + 2, ty0 - 2 - t)
            cv.line(fsx, fsy, hnd[0], hnd[1], 4, st)
            r_ = 2 + t
            cv.ell(hnd[0] - r_, hnd[1] - 2 * r_ - 1, hnd[0] + r_, hnd[1] - 1, ramp(g))
            cv.p(hnd[0], hnd[1] - r_ - 1, WHITE)
        elif mode == "strike":
            hnd = (tx1 + 4, ty0 + 3)
            cv.line(fsx, fsy, hnd[0], hnd[1], 4, st)
            for x in range(hnd[0] + 2, CW - 1):
                cv.f(x, hnd[1] - 1, x, hnd[1] + 1, g if x % 5 else gh)
            cv.f(hnd[0] + 2, hnd[1], CW - 2, hnd[1], WHITE)
            if t == 0:
                cv.f(hnd[0] + 1, hnd[1] - 3, hnd[0] + 3, hnd[1] + 3, WHITE)
        else:
            hnd = (tx1 + 2, ty0 + th - 2)
            cv.line(fsx, fsy, hnd[0], hnd[1], 4, st)
            cv.r(hnd[0], hnd[1] + 1, hnd[0] + 1, hnd[1] + 2, g)
    else:   # guardian with mace and shield
        wood = ramp(C("#4a3a30"))
        if mode == "windup":
            hnd = (cx + px - t, hy0 - 3)
            cv.line(fsx, fsy, hnd[0], hnd[1], 5, st)
            cv.line(hnd[0], hnd[1], hnd[0] - 3 - t, hnd[1] - 10, 3, wood)
            cv.rect(hnd[0] - 7 - t, hnd[1] - 17, hnd[0] - 1 - t, hnd[1] - 9, gold or st, True)
            cv.r(hnd[0] - 5 - t, hnd[1] - 14, hnd[0] - 4 - t, hnd[1] - 13, g)
        elif mode == "strike":
            hnd = (tx1 + 4 + t * 2, ty0 + 4 + t * 2)
            cv.line(fsx, fsy, hnd[0], hnd[1], 5, st)
            cv.line(hnd[0], hnd[1], hnd[0] + 6, hnd[1] + 6, 3, wood)
            cv.rect(hnd[0] + 5, hnd[1] + 4, hnd[0] + 11, hnd[1] + 11, gold or st, True)
            cv.r(hnd[0] + 8, hnd[1] + 7, hnd[0] + 9, hnd[1] + 8, g)
            for (ax, ay) in ((hnd[0] + 12, hnd[1] - 1), (hnd[0] + 14, hnd[1] + 4), (hnd[0] + 14, hnd[1] + 10)):
                cv.f(ax, ay, ax + 1, ay + 1, WHITE)
        else:
            hnd = (tx1 + 3, ty0 + th - 1)
            cv.line(fsx, fsy, hnd[0], hnd[1], 5, st)
            cv.line(hnd[0], hnd[1] + 1, hnd[0] + 1, hnd[1] - 9, 3, wood)
            cv.rect(hnd[0] - 3, hnd[1] - 16, hnd[0] + 4, hnd[1] - 8, gold or st, True)
            cv.r(hnd[0], hnd[1] - 13, hnd[0] + 1, hnd[1] - 12, g)
        cv.rect(tx0 - 5, ty0 + 3, tx0 - 1, ty0 + th, gold or st, True)   # round shield on the back arm
        cv.r(tx0 - 3, ty0 + 5, tx0 - 3, ty0 + 6, g)
    if mode == "walk" and t % 2:
        cv.p(cx - pw // 2 - 2, gy, C("#a8a090"))
        cv.p(cx + pw // 2 + 2, gy, C("#a8a090"))
    return cv


ARCA = dict(cell=(32, 32), pw=12, ph=4, tw=10, th=9, hw=8, hh=7, stone=C("#a69a86"), glow=C("#3fe0e8"), kind="shooter")
ARCA_P = dict(cell=(48, 48), pw=20, ph=6, tw=18, th=15, hw=13, hh=10, stone=C("#7c7488"), glow=C("#ff5a3a"),
              gold=C("#e0b040"), kind="guard", fangs=True)


# ---------------------------------------------------------------- bajul (side-view crocodile)
def bajul(cfg, mode, t):
    CW, CH = cfg["cell"]
    cv = Cv(CW, CH)
    gy = cv.gy
    bc = ramp(cfg["body"])
    belly = ramp(cfg["belly"])
    lg, bh, hl, tl = cfg["lg"], cfg["bh"], cfg["hl"], cfg["tl"]
    dx = op = hy = bob = 0
    tail = 0
    legs = [0, 0, 0, 0]
    lf = [0, 0, 0, 0]
    if mode == "idle":
        bob = 1 if t in (1, 2) else 0
        op = 1 if t == 2 else 0
        tail = [0, 1, 0, -1][t]
    elif mode == "walk":
        legs = [[-2, 2, 2, -2], [0, 0, 0, 0], [2, -2, -2, 2], [0, 0, 0, 0]][t]
        lf = [[0, 0, 0, 0], [1, 0, 0, 1], [0, 0, 0, 0], [0, 1, 1, 0]][t]
        tail = [2, 0, -2, 0][t]
        bob = t % 2
    elif mode == "windup":
        dx, op, hy = -2 - t, cfg["open"], -3 - t * 2
    elif mode == "strike":
        dx, op, hy = 3 + t * 2, (3 if t == 0 else 1), 1
    elif mode == "hurt":
        dx, op, hy = -2 - t, 2, -2 + t
    by1 = gy - lg
    by0 = by1 - bh + 1 + bob
    bx0 = 2 + tl + max(dx, 0) + (min(dx, 0))
    bx1 = CW - hl - 4 + dx
    # far legs
    far = [ramp(pl.shade(cfg["body"], 0.75))]
    for i, x in enumerate((bx1 - 4 + legs[2], bx0 + 3 + legs[3])):
        h = lg - lf[2 + i]
        cv.rect(x, gy - h - 1, x + 2, gy - lf[2 + i], far[0])
    # tail
    ty_ = by0 + bh // 2
    cv.poly([(bx0 + 2, by0), (bx0 + 2, by1 - 1), (bx0 - tl // 2, by1 - 1 + tail // 2 + (1 if tail else 0) * 0),
             (bx0 - tl, ty_ + tail), (bx0 - tl // 2, by0 + 2 + tail // 2)], bc, True)
    # body
    cv.rect(bx0, by0, bx1, by1, bc, True, big=True)
    cv.r(bx0 + 1, by1 - 1, bx1 - 1, by1 - 1, belly[1])
    cv.r(bx0 + 1, by1, bx1 - 1, by1, belly[2])
    # scutes
    sc = cfg.get("spike")
    for x in range(bx0 + 1, bx1, 3):
        if sc:
            cv.rect(x, by0 - 3, x + 1, by0 - 1, ramp(sc), False)
        else:
            cv.rect(x, by0 - 2, x + 1, by0 - 1, bc)
    for x in range(bx0 - tl // 2, bx0 + 1, 3):
        cv.p(x + 1, by0 - 1 + abs(tail) // 2, bc[0])
    if cfg.get("scar"):
        for k in range(2):
            for j in range(4):
                cv.p(bx0 + 4 + k * 7 + j, by0 + 2 + j, cfg["scar"])
                cv.p(bx0 + 5 + k * 7 + j, by0 + 2 + j, cfg["scar"])
    # head
    hx0 = bx1 - 1
    hx1 = min(CW - 2, hx0 + hl + 1)
    hu = max(3, bh // 2)
    hty = by0 + 1 + hy
    uy0 = hty - op
    ly0 = hty + hu
    lo = max(2, bh // 3)
    # lower jaw
    cv.rect(hx0 + 1, ly0, hx1 - 1, ly0 + lo - 1, bc, True)
    cv.r(hx0 + 1, ly0 + lo - 1, hx1 - 2, ly0 + lo - 1, belly[1])
    if op > 0:
        cv.r(hx0 + 2, ly0 - op, hx1 - 2, ly0 - 1, C("#d8505a"))
        cv.r(hx0 + 4, ly0 - 1, hx1 - 3, ly0 - 1, C("#a83a48"))
        for x in range(hx0 + 4, hx1 - 1, 2):
            cv.p(x, ly0 - 1, WHITE)
            cv.p(x, ly0 - op, WHITE)
    else:
        for x in range(hx0 + 3, hx1 - 1, 2):
            cv.p(x, ly0, WHITE)
    # upper jaw + snout
    cv.rect(hx0, uy0, hx1, uy0 + hu - 1, bc, True)
    cv.rect(hx1 - 3, uy0 - 1, hx1, uy0, bc)                          # nostril bump
    cv.p(hx1 - 1, uy0 - 1, bc[3])
    # eye bump + eye
    cv.rect(hx0 + 1, uy0 - 2, hx0 + 4, uy0 + 1, bc, True)
    ec = cfg["eye"]
    cv.r(hx0 + 3, uy0 - 1, hx0 + 4, uy0, ec)
    cv.p(hx0 + 4, uy0, DARK)
    # near legs
    for i, x in enumerate((bx1 - 5 + legs[0], bx0 + 2 + legs[1])):
        h = lg - lf[i]
        cv.rect(x, gy - h - 1, x + 3, gy - lf[i], bc, True)
        cv.r(x + 1, gy - lf[i], x + 4, gy - lf[i], bc[2])
        cv.p(x + 4, gy - lf[i], WHITE)
    if mode == "strike" and t == 1:
        cv.f(hx1 + 1, uy0 + 1, hx1 + 2, uy0 + 2, WHITE)
    return cv


BAJUL = dict(cell=(40, 24), body=C("#e6e0c8"), belly=C("#fff6d8"), lg=3, bh=8, hl=11, tl=9, eye=C("#d8a020"), open=4)
BAJUL_T = dict(cell=(48, 28), body=C("#b8b4a0"), belly=C("#e8e0c0"), lg=4, bh=10, hl=13, tl=11, eye=C("#fff8e0"), open=5,
               spike=C("#6a6a72"), scar=C("#c88a86"))


# ---------------------------------------------------------------- banaspati (flame heads)
def banaspati(cfg, mode, t):
    CW, CH = cfg["cell"]
    cv = Cv(CW, CH)
    r = cfg["r"]
    out, mid, core = (ramp(c)[1] for c in cfg["cols"])
    outr, midr, corer = (ramp(c) for c in cfg["cols"])
    dark = cfg["dark"]
    cx = cfg["cx"]
    cy = CH - 2 - r - cfg["lift"]
    sw = dy = flare = 0
    open_ = False
    if mode == "idle":
        dy = [0, -1, -1, 0][t]
    elif mode == "walk":
        dy = [0, -1, 0, -1][t]
        sw = [-1, 0, 1, 0][t]
    elif mode == "windup":
        flare, dy, sw = 2 + t, 1, -2 - t
    elif mode == "strike":
        sw, open_, dy = 3 + t * 2, True, 0
    elif mode == "hurt":
        sw, dy = -2 - t, 1
    cx += sw
    cy += dy
    # trailing flame tail: three tongues streaming left
    n = cfg["trail"]
    for k, (oy, ln) in enumerate(((-r // 2, 1.0), (0, 1.5), (r // 2, 1.1))):
        L_ = int((r * 0.65 + 2) * ln) + ((t + k) % 2) * 2
        if mode == "strike":
            L_ = L_ // 2
        y0 = cy + oy + r // 3
        w = r // 2 + 1
        tipy = y0 + [0, -2, 1, -1][(t + k) % 4] + (2 if mode in ("windup", "hurt") else 0)
        to, tm = ramp(pl.shade(cfg["cols"][0], 0.8)), ramp(pl.shade(cfg["cols"][1], 0.85))
        cv.poly([(cx - r + 3, y0 - w), (cx - r + 3, y0 + w), (cx - r - L_, tipy)], to)
        cv.poly([(cx - r + 3, y0 - w + 2), (cx - r + 3, y0 + w - 1), (cx - r - L_ + 4, tipy)], tm)
    # embers
    for k in range(2):
        cv.p(cx - r - r - 2 - k * 3 + sw, CH - 2 - ((t * 2 + k * 3) % 5) * (1 if mode != "strike" else 0) - 1 + (k * 0), mid)
    # flame tongues on top
    for i, ox in enumerate(cfg["tips"]):
        h = r // 2 + 1 + ((i + t) % 3) + flare
        if mode == "strike":
            h = r // 3 + 1
        x = cx + ox
        cv.poly([(x - 2, cy - r + 3), (x + 2, cy - r + 3), (x + (1 if i % 2 else -1), cy - r - h)], outr)
        cv.poly([(x - 1, cy - r + 3), (x + 1, cy - r + 3), (x, cy - r - h + 3)], midr)
    # head
    cv.ell(cx - r, cy - r, cx + r, cy + r, outr, big=True)
    cv.ell(cx - r + 2, cy - r + 2, cx + r - 2, cy + r - 1, midr, big=True)
    cv.ell(cx - r // 2, cy + 1, cx + r // 2 + 1, cy + r - 1, corer)           # hot jaw glow
    # face on the right: slanted brow, two bright eyes, fanged grin
    ew = 3 if r < 8 else 4
    ex0 = cx - r // 2
    ex1 = ex0 + ew + 2
    fy = cy - r // 3 - 1
    for ex in (ex0, ex1):
        cv.r(ex, fy, ex + ew - 1, fy + ew - 1, WHITE)
        cv.r(ex + ew - 2, fy + 1, ex + ew - 1, fy + ew - 1, dark)
    bw = 2 if mode in ("windup", "strike") else 1
    for ex in (ex0, ex1):
        cv.r(ex - 1, fy - 1 - (bw - 1), ex + ew - 1, fy - 1, dark)
        cv.r(ex - 1, fy - 1, ex - 1, fy + 1, dark)
    my = cy + r // 2 + 1
    open_m = open_ or mode == "windup"
    cv.r(ex0, my, ex1 + ew - 1, my + (3 if open_m else 1), dark)
    for x in range(ex0 + 1, ex1 + ew, 3):
        cv.p(x, my, WHITE)
        if open_m:
            cv.p(x + 1, my + 3, WHITE)
    if open_:
        cv.f(ex1 + ew + 1, my, min(CW - 2, ex1 + ew + 5), my + 2, corer[1])
    if cfg.get("crown"):
        for k, ox in enumerate((-r // 2, 0, r // 2)):
            hh = r // 2 + ((k + t) % 2) + flare
            cv.poly([(cx + ox - 2, cy - r + 2), (cx + ox + 2, cy - r + 2), (cx + ox, cy - r - hh - 3)], ramp(cfg["crown"]))
    return cv


BANASPATI = dict(cell=(24, 24), r=6, cx=15, cols=(C("#ff6a1a"), C("#ffa828"), C("#ffe680")), dark=C("#4a1008"),
                 eye=C("#ff3a1a"), lift=2, trail=2, tips=(-3, 0, 3))
BANASPATI_E = dict(cell=(40, 36), r=10, cx=26, cols=(C("#d8267a"), C("#ff5a3a"), C("#ffd060")), dark=C("#2a0a28"),
                   eye=C("#7a1a8a"), lift=2, trail=2, tips=(-6, -2, 2, 6), crown=C("#8a3ae0"))


# ---------------------------------------------------------------- genderuwo (hairy giant)
def genderuwo(mode, t):
    CW = CH = 48
    cv = Cv(CW, CH)
    gy = cv.gy
    fur = ramp(C("#6a4636"))
    rock = ramp(C("#8d939c"))
    fur_b = [pl.shade(c, 0.8) for c in fur]
    cx = 22
    bob = lean = 0
    lo = [(0, 0), (0, 0)]
    arm = 0
    if mode == "idle":
        bob = 1 if t in (1, 2) else 0
        arm = [0, 1, 1, 0][t]
    elif mode == "walk":
        bob = [1, 0, 1, 0][t]
        lo = [[(3, 0), (0, 0), (-3, 0), (0, 3)][t], [(-3, 0), (0, 3), (3, 0), (0, 0)][t]]
        arm = [-3, 0, 3, 0][t]
    elif mode == "windup":
        lean, bob = -2 - t, t
    elif mode == "strike":
        lean, bob = 3 + t * 2, 1
    elif mode == "hurt":
        lean, bob = -3 + t, 1
    lh = 8
    ty1 = gy - lh
    ty0 = ty1 - 17 + bob
    tx0, tx1 = cx - 10 + lean, cx + 10 + lean
    # back arm
    ba = arm * -1
    cv.line(tx0 + 2, ty0 + 4, tx0 - 3 - ba // 2, ty0 + 18, 6, fur_b)
    cv.rect(tx0 - 7 - ba // 2, ty0 + 17, tx0 - 1 - ba // 2, ty0 + 21, fur_b, True)
    # legs
    for i, k in enumerate((3, -8)):
        dx, lift = lo[i]
        lx = cx + k + dx + lean // 2
        cv.rect(lx, ty1 - 2, lx + 7, gy - lift - 2, fur if i == 0 else fur_b, True, big=True)
        cv.rect(lx, gy - lift - 2, lx + 9, gy - lift, ramp(C("#3a2620")), True)
        cv.p(lx + 9, gy - lift, WHITE); cv.p(lx + 7, gy - lift, WHITE)
    # torso: wide and hunched
    cv.poly([(tx0 + 3, ty0), (tx1 - 3, ty0), (tx1 + 1, ty0 + 5), (tx1 - 1, ty1), (tx0 + 1, ty1), (tx0 - 2, ty0 + 6)], fur, True)
    for x in range(tx0, tx1, 2):     # ragged bottom fur
        cv.p(x, ty1 + 1, fur[2])
    for y in range(ty0 + 3, ty1, 3):     # side tufts
        cv.p(tx0 - 3, y, fur[2]); cv.p(tx1 + 2, y, fur[1])
    for x in range(tx0 + 3, tx1 - 2, 4):    # fur strokes
        cv.r(x, ty0 + 4, x, ty0 + 5, fur[0]); cv.r(x + 2, ty0 + 9, x + 2, ty0 + 10, fur[3])
    cv.rect(cx + lean - 3, ty0 + 8, cx + lean + 3, ty0 + 12, ramp(C("#8e6a56")), True)  # paler chest
    # head: small and forward, between the shoulders
    hx0 = cx + lean + 1
    hy1 = ty0 + 4
    hy0 = hy1 - 11
    cv.rect(hx0 - 1, hy0 + 1, hx0 + 12, hy1, fur, True)
    for k, x in enumerate(range(hx0 - 1, hx0 + 12, 2)):               # wild hair
        cv.rect(x, hy0 - 2 - (k % 2) * 2, x + 1, hy0 + 1, fur)
    cv.rect(hx0 + 4, hy0 + 3, hx0 + 12, hy1 - 1, ramp(C("#a06e52")), True)   # face
    cv.r(hx0 + 4, hy0 + 3, hx0 + 12, hy0 + 3, fur[3])                   # brow
    eye = C("#ff3030") if mode in ("windup", "strike") else C("#ffb030")
    cv.r(hx0 + 5, hy0 + 4, hx0 + 6, hy0 + 5, eye)
    cv.r(hx0 + 9, hy0 + 4, hx0 + 10, hy0 + 5, eye)
    cv.r(hx0 + 5, hy1 - 3, hx0 + 12, hy1 - 1, C("#1a0e10"))               # mouth
    if mode in ("windup", "strike", "hurt"):
        cv.r(hx0 + 5, hy1 - 4, hx0 + 12, hy1, C("#1a0e10"))
    cv.r(hx0 + 5, hy1 - 3, hx0 + 6, hy1 - 2, WHITE)
    cv.r(hx0 + 11, hy1 - 3, hx0 + 12, hy1 - 2, WHITE)
    # front arm
    sx, sy = tx1 - 2, ty0 + 5
    if mode == "windup":
        hx, hy = cx + lean + 2 - t, hy0 - 6
        cv.line(sx, sy, hx + 3, hy + 3, 6, fur)
        cv.line(tx0 + 4, sy, hx - 4, hy + 3, 6, fur_b)
        cv.ell(hx - 6, hy - 9, hx + 6, hy + 1, rock, True)
        cv.r(hx - 4, hy - 7, hx - 2, hy - 6, rock[0]); cv.r(hx + 2, hy - 3, hx + 4, hy - 2, rock[2])
        cv.rect(hx - 7, hy - 1, hx - 3, hy + 3, fur, True); cv.rect(hx + 3, hy - 1, hx + 7, hy + 3, fur, True)
    elif mode == "strike":
        hx, hy = tx1 + 7 + t * 2, ty0 + 9 + t * 3
        cv.line(sx, sy, hx, hy, 6, fur)
        cv.rect(hx - 2, hy - 3, hx + 4, hy + 3, fur, True)
        for k in range(3):
            cv.p(hx + 4, hy - 2 + k * 2, WHITE)
        if t == 0:   # the rock leaves the hand
            cv.ell(CW - 11, hy - 6, CW - 2, hy + 3, rock, True)
            for k in range(3):
                cv.fp(CW - 14 - k, hy - 1 + k, WHITE)
        else:
            for k in range(4):
                cv.fp(hx + 6 + k, hy - 4 + k * 3, WHITE)
    elif mode == "hurt":
        cv.line(sx, sy, sx + 2, sy + 12, 6, fur)
        cv.rect(sx - 1, sy + 11, sx + 5, sy + 16, fur, True)
    else:
        a = arm
        hx, hy = sx + 3 + a // 2, sy + 15 - a
        cv.line(sx, sy, hx, hy, 6, fur)
        cv.rect(hx - 3, hy - 1, hx + 3, hy + 4, fur, True)
        cv.p(hx + 3, hy + 5, WHITE); cv.p(hx, hy + 5, WHITE); cv.p(hx - 2, hy + 5, WHITE)
    return cv


# ---------------------------------------------------------------- jurig leuweung (forest ghost)
def jurig(CW, CH, elite, mode, t):
    cv = Cv(CW, CH)
    gy = cv.gy
    S = CW / 40.0
    bark = ramp(C("#5e3c32" if elite else "#7c5a4a"))
    bark_b = [pl.shade(c, 0.8) for c in bark]
    moss = ramp(C("#f4a236" if elite else "#b4e070"))
    glow = C("#ff5040" if elite else "#5ff0d0")
    dark = C("#1a1218")
    cx = int(CW * 0.42)
    sway = bob = 0
    fo = [(0, 0), (0, 0)]
    if mode == "idle":
        sway = [0, 0, 1, 0][t]
        bob = 1 if t in (1, 2) else 0
    elif mode == "walk":
        fo = [[(2, 0), (0, 0), (-2, 0), (0, 2)][t], [(-2, 0), (0, 2), (2, 0), (0, 0)][t]]
        sway = [-1, 0, 1, 0][t]
        bob = t % 2
    elif mode == "windup":
        sway, bob = -2 - t, t
    elif mode == "strike":
        sway, bob = 3 + t * 2, 1
    elif mode == "hurt":
        sway, bob = -3 + t, 1
    u = lambda v: max(1, round(v * S))
    base_w = u(9)
    top = u(9) + bob + (CH - 36) // 4
    # root feet
    for (dxr, ox) in ((-u(8), fo[1]), (-u(3), 0), (u(2), 0), (u(7), fo[0])):
        lift = ox[1] if isinstance(ox, tuple) else 0
        dxo = ox[0] if isinstance(ox, tuple) else ox
        cv.rect(cx + dxr + dxo, gy - 3 - lift, cx + dxr + dxo + u(4), gy - lift, bark_b if dxr < 0 else bark, True)
    cv.rect(cx - base_w, gy - u(7), cx + base_w, gy - 2, bark, True, big=True)
    # trunk, narrowing towards the shoulders, swaying
    pts = []
    sh_y = top + u(10)
    for y in range(sh_y, gy - u(6)):
        w = u(6) + (y - sh_y) * (base_w - u(6)) // max(1, (gy - u(6) - sh_y))
        off = round(sway * (1 - y / gy))
        pts.append((y, w, off))
    mask = cv._mask(lambda d: [d.line([cx - w + off, y, cx + w + off, y], fill=1) for (y, w, off) in pts])
    cv.shape(mask, bark, True)
    for (y, w, off) in pts[2::3]:
        cv.p(cx - w // 2 + off, y, bark[3]); cv.p(cx + w // 3 + off, y + 1, bark[0])
    off = round(sway * 0.5)
    cv.rect(cx - u(7) + off, sh_y + u(8), cx - u(4) + off, sh_y + u(10), moss, True)
    cv.rect(cx + u(2) + off, sh_y + u(12), cx + u(5) + off, sh_y + u(13), moss, True)
    # head: gnarled knot with a hollow face
    hx = cx + sway
    hwid = u(8)
    cv.ell(hx - hwid - 1, top - 2, hx + hwid + 1, sh_y + 3, bark, True)
    cv.ell(hx - 1, top + u(2), hx + hwid, top + u(9), dark_ramp := ramp(C("#241820")))
    cv.r(hx + 1, top + u(4) - 1, hx + 2, top + u(4) + 2, glow)
    cv.r(hx + u(5), top + u(4) - 1, hx + u(5) + 1, top + u(4) + 2, glow)
    if mode in ("windup", "strike"):
        cv.r(hx, top + u(4) - 2, hx + 2, top + u(4) - 2, glow)
        cv.r(hx + u(5) - 1, top + u(4) - 2, hx + u(5) + 1, top + u(4) - 2, glow)
        cv.r(hx + 1, top + u(7), hx + u(5) + 1, top + u(7) + 1, glow)
    else:
        cv.r(hx + 2, top + u(7), hx + u(5), top + u(7), glow)
    cv.p(hx + 3, top + u(7) + 1, WHITE); cv.p(hx + u(5) - 1, top + u(7) + 1, WHITE)
    # leafy crown
    up = 2 if mode == "windup" else 0
    for k, x in enumerate(range(hx - hwid, hx + hwid, 3)):
        hh = u(3) + (k + t) % 2 + up + (3 if elite and k % 2 else 0)
        cv.poly([(x, top - 1), (x + 3, top - 1), (x + 1 + (k % 2), top - 1 - hh)], moss)
    if elite:     # antler branches
        for sgn in (-1, 1):
            cv.line(hx + sgn * (hwid - 2), top, hx + sgn * (hwid + 3), top - 9 - up, 2, bark)
            cv.line(hx + sgn * (hwid + 1), top - 5 - up, hx + sgn * (hwid + 5), top - 6 - up, 2, bark)
            cv.r(hx + sgn * (hwid + 3), top - 11 - up, hx + sgn * (hwid + 3) + 1, top - 10 - up, glow)
        cv.r(hx - 4, sh_y - 1, hx + 4, sh_y, glow)       # ember crack across the chest
    # arms: branches
    sx, sy = hx + hwid - 1, sh_y + 1
    bx, by = hx - hwid + 1, sh_y + 1
    limb = ramp(C("#8a5e50" if elite else "#a07c64"))
    limb_b = [pl.shade(c, 0.8) for c in limb]
    cv.line(bx, by, bx - 4, by + u(7), 3, limb_b)
    cv.r(bx - 6, by + u(7), bx - 5, by + u(7) + 2, moss[2])
    if mode == "windup":
        ax, ay = sx - 1 - t, sy - u(11)
        cv.line(sx, sy, ax, ay, 4, limb)
        cv.line(ax, ay, ax - 4, ay - 4, 2, limb); cv.line(ax, ay, ax + 3, ay - 4, 2, limb)
        cv.r(ax - 5, ay - 6, ax - 4, ay - 5, moss[0]); cv.r(ax + 3, ay - 6, ax + 4, ay - 5, moss[0])
        cv.line(bx, by, bx - 2, by - u(8), 3, limb_b)
    elif mode == "strike":
        ax, ay = CW - 5 - (1 - t) * 3, sy + u(5) + t * 3
        cv.line(sx, sy, ax, ay, 4, limb)
        cv.line(ax, ay, ax + 3, ay - 3, 2, limb); cv.line(ax, ay, ax + 3, ay + 3, 2, limb)
        for k in range(4):
            cv.f(ax - 9 + k * 2, sy - 3 + k * 2, ax - 8 + k * 2, sy - 2 + k * 2, glow)
    elif mode == "hurt":
        cv.line(sx, sy, sx + 2, sy + u(8), 4, limb)
    else:
        a = 1 if t in (1, 2) else 0
        ax, ay = sx + 4, sy + u(8) + a
        cv.line(sx, sy, ax, ay, 4, limb)
        cv.line(ax, ay, ax - 2, ay + 4, 2, limb_b); cv.line(ax, ay, ax + 3, ay + 4, 2, limb_b)
        cv.p(ax, ay + 1, moss[1])
    return cv


# ---------------------------------------------------------------- driver
def make_all():
    sheets = []
    H_ = lambda cfg: lambda m, t: person(cfg, m, t)
    A_ = lambda cfg: lambda m, t: arca_gen(cfg, m, t)
    B_ = lambda cfg: lambda m, t: bajul(cfg, m, t)
    N_ = lambda cfg: lambda m, t: banaspati(cfg, m, t)
    jobs = [
        ("arca", ARCA["cell"], A_(ARCA)),
        ("arca_penjaga", ARCA_P["cell"], A_(ARCA_P)),
        ("bajul_putih", BAJUL["cell"], B_(BAJUL)),
        ("bajul_putih_tua", BAJUL_T["cell"], B_(BAJUL_T)),
        ("banaspati", BANASPATI["cell"], N_(BANASPATI)),
        ("banaspati_elite", BANASPATI_E["cell"], N_(BANASPATI_E)),
        ("bandit", BANDIT["cell"], H_(BANDIT)),
        ("bandit_archer", ARCHER["cell"], H_(ARCHER)),
        ("chaser", CHASER["cell"], H_(CHASER)),
        ("dummy", (24, 24), dummy),
        ("faceless", FACELESS["cell"], H_(FACELESS)),
        ("faceless_archer", FACELESS_A["cell"], H_(FACELESS_A)),
        ("faceless_champion", CHAMP["cell"], H_(CHAMP)),
        ("genderuwo", (48, 48), genderuwo),
        ("jurig_leuweung", (40, 36), lambda m, t: jurig(40, 36, False, m, t)),
        ("jurig_leuweung_elite", (48, 48), lambda m, t: jurig(48, 48, True, m, t)),
    ]
    for name, (w, h), fn in jobs:
        sh = build(name, w, h, fn)
        pl.save(sh, f"enemies/{name}.png")
        sheets.append((name, sh))
    return sheets


def contact(sheets, out, scale=3):
    """Fixed order (see stdout): two columns of sheets at 3x on a green ground."""
    half = (len(sheets) + 1) // 2
    cols = []
    for part in (sheets[:half], sheets[half:]):
        w = max(s.width for _, s in part) * scale + 8
        h = sum(s.height * scale + 8 for _, s in part) + 8
        c = Image.new("RGBA", (w, h), (70, 96, 70, 255))
        y = 8
        for _, s in part:
            c.alpha_composite(s.resize((s.width * scale, s.height * scale), Image.NEAREST), (4, y))
            y += s.height * scale + 8
        cols.append(c)
    o = Image.new("RGBA", (sum(c.width for c in cols), max(c.height for c in cols)), (70, 96, 70, 255))
    x = 0
    for c in cols:
        o.alpha_composite(c, (x, 0))
        x += c.width
    o.save(out)


if __name__ == "__main__":
    sheets = make_all()
    contact(sheets, os.path.join(HERE, "enemies_a_preview.png"))
    for n, s in sheets:
        print(n, s.size, (s.width // 4, s.height // 4))
