#!/usr/bin/env python3
"""Budayago boss sprite generator (10 bosses) -> assets/art/enemies/<name>.png

Each sheet: 4 cols x 4 rows. Row0 idle, row1 walk, row2 telegraph (0-1 windup,
2-3 strike), row3 hurt (0-1 flinch, 2-3 idle). Art faces RIGHT, feet bottom-center.
Bosses are drawn procedurally (shaded primitives + pose parameters) so every
frame of every boss has a hand-authored windup, strike and walk.
"""
import math
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pixlib as P  # noqa: E402

H = P.hexc
OUTDIR = "enemies"
SCRATCH = "/Users/taufan.zamzami/.gemini/antigravity/brain/f643650e-c552-4c12-b6bf-2a7c6d77ba67/scratch"


# --------------------------------------------------------------------------- canvas
class Cv:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.m = Image.new("RGBA", (w, h), (0, 0, 0, 0))   # main art (outlined)
        self.g = Image.new("RGBA", (w, h), (0, 0, 0, 0))   # glow / aura (behind, no outline)

    def p(self, x, y, c, layer=None):
        x, y = int(round(x)), int(round(y))
        if 0 <= x < self.w and 0 <= y < self.h:
            (layer or self.m).putpixel((x, y), c)

    def rect(self, x0, y0, x1, y1, c):
        for y in range(int(y0), int(y1) + 1):
            for x in range(int(x0), int(x1) + 1):
                self.p(x, y, c)

    def rect_s(self, x0, y0, x1, y1, r):
        """shaded rect: ramp r=(hi,mid,shd,deep); light from upper-left."""
        w, h = x1 - x0 + 1, y1 - y0 + 1
        for y in range(int(y0), int(y1) + 1):
            for x in range(int(x0), int(x1) + 1):
                u = (x - x0) / max(1, w - 1) - .5
                v = (y - y0) / max(1, h - 1) - .5
                d = u * .6 + v * .5
                c = r[0] if d < -.38 else (r[1] if d < .12 else r[2])
                self.p(x, y, c)

    def ell(self, cx, cy, rx, ry, c):
        for y in range(int(math.floor(cy - ry)), int(math.ceil(cy + ry)) + 1):
            for x in range(int(math.floor(cx - rx)), int(math.ceil(cx + rx)) + 1):
                if ((x - cx) / (rx + .3)) ** 2 + ((y - cy) / (ry + .3)) ** 2 <= 1:
                    self.p(x, y, c)

    def ell_s(self, cx, cy, rx, ry, r):
        for y in range(int(math.floor(cy - ry)), int(math.ceil(cy + ry)) + 1):
            for x in range(int(math.floor(cx - rx)), int(math.ceil(cx + rx)) + 1):
                u = (x - cx) / (rx + .3)
                v = (y - cy) / (ry + .3)
                if u * u + v * v <= 1:
                    d = u * .55 + v * .65
                    c = r[0] if d < -.5 else (r[1] if d < .2 else (r[2] if d < .8 else r[3]))
                    self.p(x, y, c)

    def line(self, x0, y0, x1, y1, c, th=1, layer=None):
        n = int(max(abs(x1 - x0), abs(y1 - y0))) * 2 + 1
        for i in range(n + 1):
            t = i / n
            x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
            if th <= 1:
                self.p(x, y, c, layer)
            else:
                for dx in range(th):
                    for dy in range(th):
                        self.p(x - th // 2 + dx, y - th // 2 + dy, c, layer)

    def poly(self, pts, c, layer=None):
        ys = [q[1] for q in pts]
        for y in range(int(min(ys)), int(max(ys)) + 1):
            xs = []
            for i in range(len(pts)):
                a, b = pts[i], pts[(i + 1) % len(pts)]
                if (a[1] <= y + .5 < b[1]) or (b[1] <= y + .5 < a[1]):
                    xs.append(a[0] + (y + .5 - a[1]) * (b[0] - a[0]) / (b[1] - a[1]))
            xs.sort()
            for i in range(0, len(xs) - 1, 2):
                for x in range(int(round(xs[i])), int(round(xs[i + 1]))):
                    self.p(x, y, c, layer)

    def glow(self, cx, cy, rx, ry, col, a=70):
        c = col[:3] + (a,)
        for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
            for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
                if ((x - cx) / (rx + .5)) ** 2 + ((y - cy) / (ry + .5)) ** 2 <= 1:
                    self.p(x, y, c, self.g)

    def done(self):
        o = P.outline(self.m)
        g = P.pad(self.g)
        g.alpha_composite(o)
        return g


# --------------------------------------------------------------------------- pose
def pose(kind, i):
    """Generic pose numbers shared by humanoids. hf/hb = hand offsets in arm-lengths."""
    d = dict(bob=0, sw=0, lean=0, la=0, lb=0, hf=(.35, .85), hb=(-.3, .85), wd=(.35, -.95),
             flare=0, crouch=0, spread=0)
    if kind == "idle":
        d.update(bob=[0, 0, -1, -1][i], sw=[0, 1, 0, -1][i], hf=[(.35, .85), (.35, .8), (.38, .75), (.35, .8)][i],
                 hb=[(-.3, .85), (-.3, .8), (-.32, .75), (-.3, .8)][i])
    elif kind == "walk":
        d.update(bob=[0, -1, 0, -1][i], sw=[1, 0, -1, 0][i], la=[3, 0, -3, 0][i], lb=[-3, 0, 3, 0][i],
                 hf=[(.8, .6), (.35, .85), (-.2, .85), (.35, .85)][i], hb=[(-.7, .6), (-.3, .85), (.35, .8), (-.3, .85)][i],
                 lean=1)
    elif kind == "wind":
        d.update(bob=[1, 2][i] - 1, lean=[-1, -2][i], hf=[(.0, -.95), (-.1, -1.1)][i], hb=[(-.35, -.85), (-.45, -1.0)][i],
                 wd=[(-.25, -1), (-.45, -.95)][i], flare=[1, 2][i], crouch=[1, 1][i], sw=[1, -1][i])
    elif kind == "strike":
        d.update(bob=0, lean=[3, 4][i], hf=[(1.15, .35), (1.3, .5)][i], hb=[(-.5, .5), (-.7, .4)][i],
                 wd=[(1, .35), (1, .55)][i], flare=[1, 0][i], sw=[-2, -1][i], spread=[1, 2][i])
    elif kind == "hurt":
        d.update(lean=-3, bob=1, hf=(-.2, .75), hb=(-.6, .6), wd=(-.2, -.95), sw=-2)
    return d


def sh(c, f):  # quick shade
    return P.shade(c, f)


# --------------------------------------------------------------------------- humanoid
def human(cv, p, cfg):
    """Draw a chibi humanoid. cfg keys: skin, cloth, trim (ramps), legc, W/H via cv, legH, torsoW,
    torsoH, headR, armL, armTh, cb(back callback), cf(front callback), hem (no legs, tattered skirt)."""
    W, Hh = cv.w, cv.h
    cx = W // 2 + cfg.get("ox", 0)
    fy = Hh - 1
    legH = cfg.get("legH", 7) - p["crouch"]
    tw, tH, hr = cfg["torsoW"], cfg["torsoH"], cfg["headR"]
    hipY = fy - legH
    top = hipY - tH + 1 + p["bob"] + p["crouch"] * 0
    lean = p["lean"]
    ttop = (cx + lean, top)
    hcx = cx + lean + cfg.get("headFwd", 1)
    hcy = top - hr + cfg.get("neck", 2) + (1 if p["bob"] > 0 else 0)
    shF = (cx + tw // 2 - 1 + lean, top + 2)
    shB = (cx - tw // 2 + 1 + lean, top + 2)
    L = cfg["armL"]
    hf = (shF[0] + p["hf"][0] * L, shF[1] + p["hf"][1] * L)
    hb = (shB[0] + p["hb"][0] * L, shB[1] + p["hb"][1] * L)
    J = dict(cx=cx, fy=fy, hipY=hipY, top=top, hc=(hcx, hcy), shF=shF, shB=shB, hf=hf, hb=hb, hr=hr,
             tw=tw, tH=tH, p=p, lean=lean, legH=legH)
    skin, cloth, trim = cfg["skin"], cfg["cloth"], cfg.get("trim", cfg["cloth"])
    if cfg.get("cb"):
        cfg["cb"](cv, J)
    # back arm
    th = cfg.get("armTh", 2)
    cv.line(shB[0], shB[1], hb[0], hb[1], cfg.get("armB", sh(cloth[1], .8)), th)
    cv.ell(hb[0], hb[1], 1.2 if th < 3 else 1.8, 1.2 if th < 3 else 1.8, sh(skin[1], .85))
    # legs / hem
    if cfg.get("hem"):
        cfg["hem"](cv, J)
    else:
        lw = cfg.get("legW", 3)
        lc = cfg.get("legc", cloth)
        for (ox, lift, col) in ((-tw // 4 + p["lb"] // 2 * 0, max(0, p["lb"]) // 2, sh(lc[1], .8)),
                                (tw // 4 + 1, max(0, p["la"]) // 2, lc[1])):
            x0 = cx + ox - lw // 2 + (p["la"] if ox > 0 else p["lb"]) // 3
            cv.rect(x0, hipY - 1, x0 + lw - 1, fy - lift, col)
            cv.rect(x0 - 0, fy - lift - 1, x0 + lw, fy - lift, cfg.get("boot", sh(lc[2], .8)))
    # torso
    tx0, tx1 = cx - tw // 2 + lean // 2, cx + tw // 2 - 1 + lean // 2
    cv.rect_s(tx0 + (lean > 1), top, tx1, hipY, cloth)
    if cfg.get("torso"):
        cfg["torso"](cv, J)
    # head
    cv.ell_s(hcx, hcy, hr, hr - .5 + cfg.get("headH", 0), skin)
    if cfg.get("head"):
        cfg["head"](cv, J)
    # front arm
    cv.line(shF[0], shF[1], hf[0], hf[1], cfg.get("armF", cloth[1]), th)
    cv.ell(hf[0], hf[1], 1.2 if th < 3 else 1.8, 1.2 if th < 3 else 1.8, skin[1])
    if cfg.get("cf"):
        cfg["cf"](cv, J)
    return J


def eyes(cv, J, col, dx=2, dy=0, n=1, glow=True):
    x, y = J["hc"]
    for k in range(n):
        cv.p(x + dx + k * 2, y + dy, col)
        if glow:
            cv.p(x + dx + k * 2, y + dy - 1, sh(col, .6))


def wdir(J):
    wx, wy = J["p"]["wd"]
    n = math.hypot(wx, wy)
    return wx / n, wy / n


def blade(cv, J, length, col, edge, hilt=None, th=2, tip=None):
    x, y = J["hf"]
    dx, dy = wdir(J)
    ex, ey = x + dx * length, y + dy * length
    cv.line(x, y, ex, ey, col, th)
    cv.line(x - dy * 0 + dx * 2 - 0, y + dy * 2, ex, ey, edge, 1)
    if hilt:
        cv.line(x - dy * 2, y + dx * 2, x + dy * 2, y - dx * 2, hilt, 1)
    return ex, ey


def auraflare(cv, J, col, n):
    """Windup flare: radiating glow + spark pixels."""
    f = J["p"]["flare"]
    if not f:
        return
    cx, cy = J["cx"] + J["lean"], J["top"] + J["tH"] // 2
    cv.glow(cx, cy, J["tw"] * (.9 + .35 * f) + 2, J["tH"] * .8 + 3 * f, col, 55 + 20 * f)
    for k in range(n * f):
        a = k * 2.4 + f
        rr = J["tw"] + 3 + (k % 3) * 2
        cv.p(cx + math.cos(a) * rr, cy + math.sin(a) * rr * .9, col, cv.g)
        cv.p(cx + math.cos(a) * rr, cy + math.sin(a) * rr * .9, sh(col, 1.3))


def slash_arc(cv, J, col, r):
    """Strike smear in front of the figure."""
    if J["p"]["spread"] == 0:
        return
    s = J["p"]["spread"]
    x, y = J["hf"]
    for a in range(-70, 60, 6):
        ar = math.radians(a)
        px, py = x - 4 + math.cos(ar) * (r + s * 2), y + math.sin(ar) * (r + s * 2)
        cv.p(px, py, col[:3] + (150 if s == 1 else 90,), cv.g)


# --------------------------------------------------------------------------- bosses
def boss_sandekala(kind, i):
    # twilight demon: near-black/violet, no legs (tattered wisps), horns, claws
    W, Hh = 22, 38
    cv = Cv(W, Hh)
    p = pose(kind, i)
    body = P.ramp(H("#2b2347"))
    skin = P.ramp(H("#3b2f66"))
    acc = H("#ff4df0")
    dusk = H("#ff8a3d")

    def hem(cv, J):
        cx, fy, hy = J["cx"], J["fy"], J["hipY"]
        sw = p["sw"]
        for k in range(-5, 6):
            hgt = [5, 8, 6, 9, 5, 10, 6, 8, 7, 9, 5][k + 5] - (2 if kind == "walk" and (k + i) % 2 else 0)
            x = cx + k + sw * (hgt // 4)
            for y in range(hy - 1, hy + hgt):
                c = body[2] if (k + y) % 4 else body[3]
                cv.p(x + J["lean"] // 2, y, c if y < hy + hgt - 2 else sh(body[2], .7))
        for k in range(-3, 4, 2):  # wisps
            cv.p(cx + k * 2 + sw, fy - 1 - (i % 2), acc[:3] + (140,), cv.g)

    def cb(cv, J):
        cx, cy = J["hc"]
        cv.glow(J["cx"], J["top"] + 8, 9, 12, H("#6a2cff"), 40 + 20 * p["flare"])
        auraflare(cv, J, acc, 4)
        # horns (swept back)
        for sgn, col in ((-1, sh(skin[2], .7)), (1, skin[1])):
            hx = cx + sgn * 4
            cv.line(hx, cy - 4, hx + sgn * 2 - 1, cy - 9, col, 2)
            cv.line(hx + sgn * 2 - 1, cy - 9, hx + sgn * 4 - 1, cy - 11, H("#b9a7ff"), 1)
        # shoulder wisps/cape
        cv.poly([(J["cx"] - 7 + J["lean"], J["top"]), (J["cx"] - 10 + J["lean"] // 2 - p["sw"], J["hipY"] + 6),
                 (J["cx"] - 3, J["hipY"] + 2)], body[3])

    def head(cv, J):
        x, y = J["hc"]
        cv.rect(x + 1, y + 1, x + 5, y + 1, H("#0d0a1a"))  # grin slot
        for k in range(x + 1, x + 6, 2):
            cv.p(k, y + 1, H("#e8e0ff"))
        eyes(cv, J, acc, 2, -1, 2)
        cv.p(x + 2, y - 2, dusk)

    def cf(cv, J):
        x, y = J["hf"]
        for k in (-1, 0, 1):  # claws
            cv.line(x + 1, y + k, x + 4, y + k * 2, H("#d9ccff"), 1)
        x, y = J["hb"]
        for k in (-1, 1):
            cv.line(x - 1, y + k, x - 3, y + k * 2, sh(H("#d9ccff"), .7), 1)
        slash_arc(cv, J, acc, 8)

    human(cv, p, dict(skin=skin, cloth=body, torsoW=9, torsoH=11, headR=5, armL=9, armTh=2, hem=hem,
                      cb=cb, head=head, cf=cf, legH=8, armF=skin[1], armB=skin[2]))
    return cv.done()


def boss_faceless_captain(kind, i):
    W, Hh = 22, 32
    cv = Cv(W, Hh)
    p = pose(kind, i)
    iron = P.ramp(H("#3a3d4c"))
    red = H("#c4283a")
    mask = P.ramp(H("#e8e4d6"))
    skin = mask
    acc = H("#ff3b4e")

    def cb(cv, J):  # cape
        sw = p["sw"]
        cx = J["cx"] + J["lean"]
        cv.poly([(cx - 3, J["top"] + 1), (cx - 7 - sw - J["lean"] // 2, J["hipY"] + 5), (cx - 2, J["hipY"] + 4)], H("#8a1c2c"))
        cv.poly([(cx - 3, J["top"] + 1), (cx - 6 - sw, J["hipY"] + 1), (cx - 2, J["hipY"])], H("#a8263a"))
        auraflare(cv, J, acc, 3)

    def torso(cv, J):
        x0, x1, t, hy = J["cx"] - J["tw"] // 2 + J["lean"] // 2, J["cx"] + J["tw"] // 2 - 1 + J["lean"] // 2, J["top"], J["hipY"]
        cv.rect(x0, t, x0, hy, red)  # trim edges
        cv.rect(x1, t, x1, hy, red)
        cv.rect(x0, hy, x1, hy, red)
        cv.rect(x0 + 2, t + 2, x1 - 2, t + 2, red)
        cv.rect((x0 + x1) // 2, t + 3, (x0 + x1) // 2, hy - 1, iron[0])
        # pauldrons
        cv.ell_s(J["shF"][0], J["shF"][1], 3, 2.5, iron)
        cv.rect(J["shF"][0] - 2, J["shF"][1] + 2, J["shF"][0] + 2, J["shF"][1] + 2, red)
        cv.ell_s(J["shB"][0], J["shB"][1], 2.5, 2.2, [sh(c, .8) for c in iron])

    def head(cv, J):
        x, y = J["hc"]
        # helmet crest + cracked mask
        cv.rect(x - 4, y - 4, x + 3, y - 3, iron[1])
        cv.rect(x - 4, y - 4, x - 4, y + 2, red)
        for k in range(3):
            cv.p(x - 1 + k, y - 6 + k % 2, red)
        cv.line(x - 4, y - 7, x - 7 - p["sw"], y - 2, red, 1)  # plume
        cv.line(x + 1, y - 2, x + 2, y + 1, H("#2a2a33"))      # crack
        cv.line(x + 2, y + 1, x + 1, y + 3, H("#2a2a33"))
        cv.line(x + 2, y + 1, x + 4, y + 2, H("#2a2a33"))
        cv.p(x + 3, y - 1, acc)          # single glowing eye through crack
        cv.p(x + 4, y - 1, sh(acc, .6))

    def cf(cv, J):
        ex, ey = blade(cv, J, 14, H("#b9c0d0"), H("#f2f5ff"), hilt=red, th=2)
        slash_arc(cv, J, H("#ff9aa6"), 10)

    human(cv, p, dict(skin=skin, cloth=iron, torsoW=10, torsoH=10, headR=5, armL=8, armTh=2, cb=cb, torso=torso,
                      head=head, cf=cf, legH=7, armF=iron[1], armB=iron[2], legc=P.ramp(H("#2d3040"))))
    return cv.done()


def boss_sangkuriang(kind, i):
    W, Hh = 26, 32
    cv = Cv(W, Hh)
    p = pose(kind, i)
    skin = P.ramp(H("#a8693a"))
    sarong = P.ramp(H("#6b3a1e"))
    cloth = skin
    acc = H("#ff7a1f")
    gold = H("#e6b84a")

    def cb(cv, J):
        # small boat (perahu) carried on his back
        bx, by = J["cx"] - 7 + J["lean"], J["top"] - 1
        cv.poly([(bx - 3, by), (bx + 2, by + 1), (bx + 3, by + 9), (bx - 2, by + 10)], H("#5a3418"))
        cv.line(bx - 3, by, bx + 3, by + 9, H("#8a5a2e"))
        auraflare(cv, J, acc, 3)

    def torso(cv, J):
        x0, x1, t, hy = J["cx"] - J["tw"] // 2 + J["lean"] // 2, J["cx"] + J["tw"] // 2 - 1 + J["lean"] // 2, J["top"], J["hipY"]
        cv.rect(x0, t + 5, x1, hy, sarong[1])
        cv.rect(x0, t + 5, x1, t + 5, gold)
        for k in range(x0 + 1, x1, 2):
            cv.p(k, t + 7, sarong[0])
            cv.p(k + 1, t + 8, sarong[3])
        cv.line(x0 + 1, t + 1, x1 - 1, t + 3, sarong[2])  # sash

    def head(cv, J):
        x, y = J["hc"]
        # udeng headcloth with knot
        cv.rect(x - 5, y - 4, x + 4, y - 2, H("#3b2410"))
        cv.rect(x - 5, y - 3, x + 4, y - 3, gold)
        cv.poly([(x - 1, y - 8), (x + 3, y - 4), (x - 3, y - 4)], H("#4e2f16"))
        cv.p(x + 1, y - 6, gold)
        cv.p(x - 6, y - 3, H("#3b2410"))
        cv.p(x - 7, y - 2 + p["sw"], H("#3b2410"))
        eyes(cv, J, acc, 2, 0, 2)
        cv.line(x + 1, y + 3, x + 4, y + 3, H("#3a1c10"))  # beard / mouth

    def cf(cv, J):
        # log club: thick brown log with rings
        x, y = J["hf"]
        dx, dy = wdir(J)
        L = 13
        ex, ey = x + dx * L, y + dy * L
        cv.line(x - dx * 3, y - dy * 3, ex, ey, H("#6e4220"), 4)
        cv.line(x - dx * 3 - 1, y - dy * 3 - 1, ex - 1, ey - 1, H("#9a6232"), 1)
        cv.ell(ex, ey, 2.4, 2.4, H("#b98450"))
        cv.p(ex, ey, H("#6e4220"))
        for k in (4, 8):
            cv.p(x + dx * k, y + dy * k + 2, H("#4a2a12"))
        cv.p(ex + dx * 2, ey, H("#a14a1c"))
        slash_arc(cv, J, H("#ffb26a"), 11)

    human(cv, p, dict(skin=skin, cloth=skin, torsoW=11, torsoH=11, headR=5, armL=8, armTh=3, cb=cb, torso=torso,
                      head=head, cf=cf, legH=7, armF=skin[1], armB=skin[2], legc=sarong, legW=4))
    return cv.done()


def boss_barma_wijaya(kind, i):
    W, Hh = 22, 36
    cv = Cv(W, Hh)
    p = pose(kind, i)
    robe = P.ramp(H("#a02fa8"))
    skin = P.ramp(H("#d9a98a"))
    acc = H("#5df2ff")
    gold = H("#ffd34d")

    def hem(cv, J):
        cx, hy, fy = J["cx"] + J["lean"] // 2, J["hipY"], J["fy"]
        sw = p["sw"]
        cv.poly([(cx - 5, hy - 1), (cx + 5, hy - 1), (cx + 7 + sw, fy), (cx - 7 + sw, fy)], robe[1])
        cv.poly([(cx + 1, hy - 1), (cx + 5, hy - 1), (cx + 7 + sw, fy), (cx + 3 + sw, fy)], robe[2])
        cv.rect(cx - 7 + sw, fy - 1, cx + 7 + sw, fy, gold)
        for k in range(-4, 5, 4):
            cv.p(cx + k + sw, fy - 4, robe[0])
        if kind == "walk":
            cv.p(cx + (4 if i % 2 else -4), fy, H("#2b0f33"))

    def cb(cv, J):
        auraflare(cv, J, H("#ff4de8"), 4)

    def torso(cv, J):
        x0, x1, t = J["cx"] - J["tw"] // 2 + J["lean"] // 2, J["cx"] + J["tw"] // 2 - 1 + J["lean"] // 2, J["top"]
        cv.rect(x0, t + 7, x1, t + 7, gold)
        cv.rect((x0 + x1) // 2, t + 1, (x0 + x1) // 2, t + 6, gold)
        cv.p(x1 - 1, t + 5, acc)
        # 4 shoulder spikes: 2 each side
        for (sx, sy, sg) in ((J["shF"][0], J["shF"][1], 1), (J["shB"][0], J["shB"][1], -1)):
            col = P.ramp(H("#7a1d85"))
            cv.ell_s(sx, sy, 3, 2.5, col)
            cv.poly([(sx - 1, sy - 2), (sx + 1, sy - 2), (sx + sg * 1, sy - 7)], H("#e6c8ff") if sg > 0 else H("#b898dd"))
            cv.poly([(sx + sg * 1, sy - 1), (sx + sg * 3, sy - 2), (sx + sg * 7, sy - 4)], H("#e6c8ff") if sg > 0 else H("#b898dd"))

    def head(cv, J):
        x, y = J["hc"]
        # spiky crown
        cv.rect(x - 4, y - 5, x + 3, y - 4, gold)
        for k, hgt in zip((-4, -2, 0, 2), (3, 5, 6, 4)):
            cv.poly([(x + k, y - 5), (x + k + 2, y - 5), (x + k + 1, y - 5 - hgt)], gold)
        cv.p(x - 1, y - 4, H("#ff4d6a"))
        cv.line(x + 1, y + 3, x + 3, y + 3, H("#4a1a40"))
        eyes(cv, J, acc, 2, 0, 2)
        cv.line(x - 5, y, x - 5, y + 5, H("#3a1040"))  # hair

    def cf(cv, J):
        # staff with orb
        x, y = J["hf"]
        dx, dy = wdir(J)
        L = 17
        ex, ey = x + dx * L, y + dy * L
        cv.line(x - dx * 6, y - dy * 6, ex, ey, H("#5a3a22"), 1)
        cv.line(ex - dy * 2, ey + dx * 2, ex + dy * 2, ey - dx * 2, gold, 1)
        cv.ell(ex, ey, 2.2, 2.2, acc)
        cv.p(ex - 1, ey - 1, H("#ffffff"))
        cv.glow(ex, ey, 4 + p["flare"] * 2, 4 + p["flare"] * 2, acc, 80)
        slash_arc(cv, J, acc, 9)

    human(cv, p, dict(skin=skin, cloth=robe, torsoW=10, torsoH=11, headR=5, armL=8, armTh=2, cb=cb, torso=torso,
                      head=head, cf=cf, legH=8, hem=hem, armF=robe[1], armB=robe[2]))
    return cv.done()


def boss_bandung_bondowoso(kind, i):
    W, Hh = 28, 34
    cv = Cv(W, Hh)
    p = pose(kind, i)
    stone = P.ramp(H("#8a6a4c"))
    dark = P.ramp(H("#5a4630"))
    gold = H("#f0c040")
    acc = H("#ffb02e")

    def cb(cv, J):
        auraflare(cv, J, acc, 4)
        if p["flare"]:
            for k in range(3):
                cv.p(J["cx"] - 8 + k * 7, J["fy"] - 1, H("#a89070"))

    def torso(cv, J):
        x0, x1, t, hy = J["cx"] - J["tw"] // 2 + J["lean"] // 2, J["cx"] + J["tw"] // 2 - 1 + J["lean"] // 2, J["top"], J["hipY"]
        # ornate gold belt
        cv.rect(x0, hy - 3, x1, hy, gold)
        cv.rect(x0, hy - 3, x1, hy - 3, H("#fff0a0"))
        cv.rect(x0, hy, x1, hy, H("#a07818"))
        for k in range(x0 + 1, x1, 3):
            cv.p(k, hy - 2, H("#c0261c"))
        cv.rect((x0 + x1) // 2 - 1, hy - 4, (x0 + x1) // 2 + 1, hy + 1, H("#fff0a0"))
        # chest cracks + gem
        cv.line(x0 + 2, t + 2, x0 + 4, t + 5, dark[3])
        cv.line(x1 - 3, t + 3, x1 - 5, t + 6, dark[3])
        cv.p((x0 + x1) // 2 + 1, t + 3, acc)
        # shoulder stones
        cv.ell_s(J["shF"][0], J["shF"][1] - 1, 4, 3.3, stone)
        cv.ell_s(J["shB"][0], J["shB"][1] - 1, 3.6, 3, dark)

    def head(cv, J):
        x, y = J["hc"]
        # tiered temple-prasada crown
        cv.rect(x - 4, y - 5, x + 3, y - 4, gold)
        cv.rect(x - 3, y - 7, x + 2, y - 6, H("#c89a28"))
        cv.rect(x - 2, y - 9, x + 1, y - 8, gold)
        cv.p(x - 1, y - 10, gold)
        cv.p(x, y - 10, gold)
        cv.rect(x + 1, y + 3, x + 4, y + 4, dark[3])  # stern beard
        eyes(cv, J, acc, 2, 0, 2)
        cv.rect(x + 1, y - 2, x + 5, y - 2, dark[3])  # brow

    def cf(cv, J):
        # stone pillar/slab weapon
        x, y = J["hf"]
        dx, dy = wdir(J)
        L = 13
        ex, ey = x + dx * L, y + dy * L
        cv.line(x - dx * 2, y - dy * 2, ex, ey, H("#a89478"), 4)
        cv.line(x - dx * 2 - 1, y - dy * 2 - 1, ex - 1, ey - 1, H("#d0c0a0"), 1)
        cv.line(x + dx * 3, y + dy * 3 + 1, x + dx * 9, y + dy * 9 + 1, H("#6c5a42"), 1)
        cv.ell(ex, ey, 3.2, 3.2, H("#9a8468"))
        cv.p(ex, ey, H("#d0c0a0"))
        slash_arc(cv, J, H("#e8d8b0"), 11)

    human(cv, p, dict(skin=stone, cloth=stone, torsoW=14, torsoH=12, headR=5, armL=8, armTh=4, cb=cb, torso=torso,
                      head=head, cf=cf, legH=6, armF=stone[1], armB=dark[1], legc=dark, legW=5))
    return cv.done()


def boss_hariang_banga(kind, i):
    W, Hh = 22, 30
    cv = Cv(W, Hh)
    p = pose(kind, i)
    steel = P.ramp(H("#4f7fb5"))
    skin = P.ramp(H("#d9a47e"))
    acc = H("#7df0ff")
    gold = H("#e8c860")

    def cb(cv, J):
        sw = p["sw"]
        cx = J["cx"] + J["lean"]
        cv.poly([(cx - 3, J["top"] + 1), (cx - 8 - sw, J["hipY"] + 3), (cx - 2, J["hipY"] + 2)], H("#e8f0ff"))
        cv.poly([(cx - 3, J["top"] + 1), (cx - 7 - sw, J["hipY"] + 1), (cx - 2, J["hipY"] + 1)], H("#c0d4ee"))
        auraflare(cv, J, acc, 3)

    def torso(cv, J):
        x0, x1, t, hy = J["cx"] - J["tw"] // 2 + J["lean"] // 2, J["cx"] + J["tw"] // 2 - 1 + J["lean"] // 2, J["top"], J["hipY"]
        cv.rect(x0 + 1, t + 4, x1 - 1, t + 4, gold)
        cv.rect(x0, hy - 1, x1, hy, gold)
        cv.p((x0 + x1) // 2, t + 2, acc)
        cv.ell_s(J["shF"][0], J["shF"][1], 3, 2.5, steel)
        cv.rect(J["shF"][0] - 2, J["shF"][1] + 2, J["shF"][0] + 2, J["shF"][1] + 2, gold)
        cv.ell_s(J["shB"][0], J["shB"][1], 2.5, 2, [sh(c, .8) for c in steel])

    def head(cv, J):
        x, y = J["hc"]
        cv.rect(x - 5, y - 3, x + 4, y - 3, steel[0])
        cv.ell_s(x - 0.5, y - 2, 5, 3.3, steel)  # helm
        cv.rect(x + 1, y - 1, x + 5, y, skin[1])
        cv.line(x - 1, y - 6, x - 5 - p["sw"], y - 2, H("#e84040"), 2)  # crest
        cv.poly([(x - 1, y - 6), (x + 1, y - 6), (x, y - 9)], gold)
        cv.line(x + 4, y - 3, x + 4, y + 2, steel[3])
        eyes(cv, J, acc, 2, 0, 1)
        cv.p(x + 4, y, acc)

    def cf(cv, J):
        ex, ey = blade(cv, J, 17, H("#d4e6ff"), H("#ffffff"), hilt=gold, th=2)
        x, y = J["hf"]
        cv.p(ex, ey, acc)
        cv.glow(ex, ey, 2 + p["flare"], 2 + p["flare"], acc, 90)
        slash_arc(cv, J, H("#bff6ff"), 11)

    human(cv, p, dict(skin=skin, cloth=steel, torsoW=10, torsoH=10, headR=5, armL=8, armTh=2, cb=cb, torso=torso,
                      head=head, cf=cf, legH=7, armF=steel[1], armB=steel[2], legc=P.ramp(H("#3a5f90"))))
    return cv.done()


def boss_buto_ijo(kind, i):
    W, Hh = 32, 40
    cv = Cv(W, Hh)
    p = pose(kind, i)
    green = P.ramp(H("#4aa83a"))
    acc = H("#ff3030")
    loin = P.ramp(H("#9a2a1a"))

    def cb(cv, J):
        auraflare(cv, J, H("#b6ff4a"), 4)
        x, y = J["hc"]
        # wild hair
        for k in range(-6, 5, 2):
            cv.line(x + k, y - 5, x + k - 1 - p["sw"], y - 9 - (k % 3), H("#2a1a10"), 2)

    def torso(cv, J):
        x0, x1, t, hy = J["cx"] - J["tw"] // 2 + J["lean"] // 2, J["cx"] + J["tw"] // 2 - 1 + J["lean"] // 2, J["top"], J["hipY"]
        # belly
        cv.ell_s((x0 + x1) // 2 + 1, t + 6, 7, 5, green)
        cv.p((x0 + x1) // 2 + 2, t + 7, green[3])
        # loincloth
        cv.poly([(x0 - 1, hy - 3), (x1 + 1, hy - 3), (x1 + 2, hy + 3), ((x0 + x1) // 2, hy + 5), (x0 - 2, hy + 3)], loin[1])
        cv.rect(x0 - 1, hy - 3, x1 + 1, hy - 3, H("#e0b040"))
        for k in range(x0, x1, 3):
            cv.p(k, hy, loin[0])
        cv.ell_s(J["shF"][0], J["shF"][1], 4, 3, green)
        cv.ell_s(J["shB"][0], J["shB"][1], 3.5, 3, [sh(c, .8) for c in green])

    def head(cv, J):
        x, y = J["hc"]
        cv.rect(x + 1, y + 1, x + 6, y + 2, H("#2a0c0c"))  # maw
        cv.line(x + 2, y + 1, x + 2, y - 2 + 2 - 3, H("#fff4d0"), 1)  # tusks up
        cv.line(x + 5, y + 1, x + 5, y - 3, H("#fff4d0"), 1)
        cv.p(x + 2, y + 1, H("#fff4d0"))
        cv.poly([(x - 2, y - 5), (x, y - 5), (x - 1, y - 8)], H("#e8e0b0"))  # horn
        cv.rect(x + 1, y - 3, x + 6, y - 3, green[3])  # heavy brow
        eyes(cv, J, acc, 2, -1, 2)
        cv.p(x + 3, y, green[3])

    def cf(cv, J):
        x, y = J["hf"]
        dx, dy = wdir(J)
        L = 15
        ex, ey = x + dx * L, y + dy * L
        cv.line(x - dx * 3, y - dy * 3, ex, ey, H("#5a3a1c"), 3)
        cv.ell(ex, ey, 3.5, 3.5, H("#6e4a24"))
        for k in range(6):
            a = k * 1.05
            cv.p(ex + math.cos(a) * 3.8, ey + math.sin(a) * 3.8, H("#d8d8d0"))
        cv.p(ex - 1, ey - 1, H("#a67844"))
        slash_arc(cv, J, H("#d6ff9a"), 12)

    human(cv, p, dict(skin=green, cloth=green, torsoW=16, torsoH=13, headR=7, armL=10, armTh=4, cb=cb, torso=torso,
                      head=head, cf=cf, legH=7, armF=green[1], armB=green[2], legc=green, legW=5, headH=-1, neck=3,
                      boot=green[3]))
    return cv.done()


# --- keris gandring ---
def _keris_img():
    """Vertical keris, tip up. 9 wide x 28 tall."""
    img = Image.new("RGBA", (11, 30), (0, 0, 0, 0))
    c = Cv(11, 30)
    c.m = img
    blade_c = P.ramp(H("#d02a3a"))
    # wavy (luk) blade: widens at ganja, 7 luk
    cx0 = 5
    for y in range(0, 20):
        off = [0, 1, 1, 0, -1, -1, 0, 1, 1, 0, -1, -1, 0, 1, 1, 0, -1, 0, 0, 0][y]
        w = 1 if y < 6 else (2 if y < 16 else 3)
        for x in range(-w, w + 1):
            col = blade_c[0] if x < 0 and abs(x) == w else (blade_c[2] if x == w else blade_c[1])
            if y < 2 and abs(x) > 0:
                continue
            c.p(cx0 + off + x, y, col)
    c.p(cx0, 0, H("#ffd0d0"))
    c.p(cx0 + 1, 8, H("#ffd0d0"))
    c.p(cx0 - 1, 13, H("#ffd0d0"))
    # ganja (crossguard) and hilt
    c.rect(2, 20, 8, 21, H("#e6b84a"))
    c.rect(2, 20, 8, 20, H("#fff0a0"))
    c.rect(4, 22, 6, 26, H("#5a2a14"))  # hilt wood
    c.p(4, 23, H("#8a4a24"))
    c.p(6, 25, H("#3a1a0c"))
    c.ell(5, 27, 2.4, 2.2, H("#e6b84a"))
    c.p(4, 26, H("#fff0a0"))
    c.p(5, 28, H("#a07818"))
    return img


def boss_keris_gandring(kind, i):
    W, Hh = 34, 34
    cv = Cv(W, Hh)
    base = _keris_img()
    acc = H("#ff2040")
    ang, bob, flare = 0, 0, 0
    if kind == "idle":
        bob = [0, -1, -2, -1][i]
        ang = [0, 3, 0, -3][i]
    elif kind == "walk":
        bob = [-1, -2, -1, -2][i]
        ang = [-14, -8, -14, -20][i] * 1  # leaning forward-ish: tip toward right = negative
        ang = [-10, -4, -10, -16][i]
    elif kind == "wind":
        bob = [-2, -3][i]
        ang = [38, 52][i]      # tip swung back (left), cocked
        flare = i + 1
    elif kind == "strike":
        bob = -2
        ang = [-75, -90][i]    # tip thrust to the right
        flare = 1 if i == 0 else 0
    elif kind == "hurt":
        bob = 0
        ang = 20
    rot = base.rotate(ang, resample=Image.NEAREST, expand=True)
    cxm, cym = W // 2, Hh - 17 + bob - 2
    if kind == "strike":
        cxm += 3
    # aura behind
    cv.glow(cxm, cym, 9 + flare * 2, 13 + flare * 2, H("#c0102a"), 40 + 25 * flare)
    cv.glow(cxm, cym, 6, 9, H("#ff3050"), 50)
    # wavy crimson wisps rising
    for k in range(9 + 5 * flare):
        t = (k * 37 + i * 11) % 100 / 100
        wx = cxm + math.sin(t * 9 + k) * (6 + 2 * flare)
        wy = cym + 13 - t * 26
        cv.p(wx, wy, acc[:3] + (190,), cv.g)
    x0 = cxm - rot.width // 2
    y0 = cym - rot.height // 2
    P._clip_paste(cv.m, rot, x0, y0)
    if kind == "strike":  # thrust streak behind the hilt
        for k in range(3):
            cv.line(x0 - 2 - k * 3, cym - 1 + k, x0 + 4, cym - 1 + k, acc[:3] + (150 - k * 40,), 1, cv.g)
    # floating shadow on ground
    sy = Hh - 2
    for x in range(cxm - 4 + (0 if bob else 0), cxm + 5):
        cv.p(x, sy, (0, 0, 0, 80), cv.g)
    return cv.done()


def boss_nameless_hunter(kind, i):
    W, Hh = 24, 40
    cv = Cv(W, Hh)
    p = pose(kind, i)
    cloak = P.ramp(H("#2a2a38"))
    skin = P.ramp(H("#1c1c26"))  # shadowed hood interior
    acc = H("#dfe9ff")
    seal = H("#d62a2a")
    paper = H("#f2ecd8")

    def hem(cv, J):
        cx, hy, fy = J["cx"] + J["lean"] // 2, J["hipY"], J["fy"]
        sw = p["sw"]
        cl = cloak
        sp = 2 if kind == "walk" else 0
        cv.poly([(cx - 5, hy - 2), (cx + 5, hy - 2), (cx + 8 + sw + sp * (1 if i % 2 else 0), fy), (cx - 9 + sw - sp * (0 if i % 2 else 1), fy)], cl[1])
        cv.poly([(cx + 1, hy - 2), (cx + 5, hy - 2), (cx + 8 + sw, fy), (cx + 3 + sw, fy)], cl[2])
        for k in range(-8, 8, 3):  # ragged hem
            cv.p(cx + k + sw, fy, (0, 0, 0, 0))
        cv.p(cx + 6, fy, H("#0c0c12"))
        if kind == "walk":
            cv.rect(cx + (3 if i % 2 else -4), fy, cx + (5 if i % 2 else -2), fy, H("#0c0c12"))

    def cb(cv, J):
        # long flaring cloak tail behind
        cx, t, hy, fy = J["cx"] + J["lean"], J["top"], J["hipY"], J["fy"]
        sw = p["sw"]
        tail = 4 + (3 if kind == "walk" else 0) + (2 if kind == "strike" else 0)
        cv.poly([(cx - 3, t), (cx - 7 - tail - sw, hy + 3), (cx - 9 - tail, fy - 1), (cx - 2, hy + 6)], cloak[2])
        # paper name-strips (fluttering)
        for k, (ox, oy) in enumerate(((-6, 2), (-9, 8), (-7, 13), (-11, 4))):
            fx = cx + ox - sw * (1 if k % 2 else -1) - (tail // 2) + (k % 2) * (i % 2)
            fy2 = t + oy + (i + k) % 2
            cv.rect(fx, fy2, fx + 1, fy2 + 4, paper)
            cv.p(fx, fy2 + 1, seal)
            cv.p(fx + 1, fy2 + 3, H("#8a8470"))
        auraflare(cv, J, H("#9ab8ff"), 3)

    def torso(cv, J):
        x0, x1, t = J["cx"] - J["tw"] // 2 + J["lean"] // 2, J["cx"] + J["tw"] // 2 - 1 + J["lean"] // 2, J["top"]
        cv.rect(x0, t + 5, x1, t + 5, H("#5a4a3a"))  # belt
        cv.rect(x0 + 1, t + 4, x0 + 1, t + 6, H("#8a8a96"))
        # shoulders mantle
        cv.ell_s(J["shF"][0], J["shF"][1], 3.2, 2.6, cloak)
        cv.p(x1 - 1, t + 8, paper)
        cv.p(x1 - 1, t + 9, seal)

    def head(cv, J):
        x, y = J["hc"]
        # deep hood: draw a hood shape over the dark face
        cv.ell_s(x - 1, y - 0.5, 6, 6, cloak)
        cv.poly([(x - 2, y - 7), (x + 1, y - 7), (x - 1, y - 11)], cloak[1])
        cv.ell(x + 2, y + 0.5, 3, 3.2, H("#08080e"))   # void face
        cv.p(x + 3, y - 1, acc)
        cv.p(x + 4, y - 1, acc)
        cv.p(x + 3, y - 2, sh(acc, .6))
        cv.p(x + 4, y - 2, sh(acc, .6))
        cv.p(x + 5, y + 4, paper)  # strip hanging from hood
        cv.p(x + 5, y + 5, paper)
        cv.p(x + 5, y + 6, seal)

    def cf(cv, J):
        # long hooked hunting blade (sabit)
        ex, ey = blade(cv, J, 15, H("#9aa4b8"), H("#e4ecff"), hilt=H("#5a4a3a"), th=2)
        cv.p(ex + 1, ey + (1 if J["p"]["wd"][1] < 0 else 0), H("#e4ecff"))
        slash_arc(cv, J, H("#bcd0ff"), 12)

    human(cv, p, dict(skin=skin, cloth=cloak, torsoW=9, torsoH=14, headR=5, armL=9, armTh=2, cb=cb, torso=torso,
                      head=head, cf=cf, legH=9, hem=hem, armF=cloak[1], armB=cloak[2], headH=1, neck=1))
    return cv.done()


def boss_batara_kala(kind, i):
    W, Hh = 44, 58
    cv = Cv(W, Hh)
    p = pose(kind, i)
    body = P.ramp(H("#352a5a"))
    skin = P.ramp(H("#4a3a7a"))
    gold = H("#ffd34d")
    gold_d = H("#b8861c")
    acc = H("#ffe36a")
    L = 13

    def cb(cv, J):
        # clock halo behind head
        x, y = J["hc"]
        r = 11
        cyc = y - 1
        cv.glow(x, cyc, r + 3 + p["flare"] * 2, r + 3 + p["flare"] * 2, H("#ffd34d"), 45 + 20 * p["flare"])
        for a in range(0, 360, 6):
            ar = math.radians(a)
            cv.p(x + math.cos(ar) * r, cyc + math.sin(ar) * r, gold)
            cv.p(x + math.cos(ar) * (r - 1), cyc + math.sin(ar) * (r - 1), gold_d)
        for k in range(12):
            ar = math.radians(k * 30)
            ln = 3 if k % 3 == 0 else 1
            cv.line(x + math.cos(ar) * (r - 2), cyc + math.sin(ar) * (r - 2),
                    x + math.cos(ar) * (r - 2 - ln), cyc + math.sin(ar) * (r - 2 - ln), gold)
        # hands: tick differently each frame / sweeping in telegraph
        ha = {"idle": i * 25, "walk": i * 40 + 100, "wind": 200 + i * 90, "strike": 300 + i * 30, "hurt": 0}[kind]
        for ang, ln in ((ha, r - 3), (ha * 12 % 360, r - 5)):
            ar = math.radians(ang - 90)
            cv.line(x, cyc, x + math.cos(ar) * ln, cyc + math.sin(ar) * ln, acc if ln > r - 4 else gold, 1)
        cv.p(x, cyc, H("#ff6a3a"))
        # extra arms (4-armed): middle pair, behind
        sx, sy = J["cx"] + J["lean"], J["top"] + 6
        rh_y = 6 + (-14 if kind == "wind" else (0 if kind == "strike" else 5))
        rh_x = 10 + p["spread"] * 3 + (3 if kind == "wind" else 0)
        for sg, (hx, hy) in ((-1, (-9 - p["sw"], 9 + p["bob"])), (1, (rh_x, rh_y))):
            cv.line(sx + sg * 6, sy, sx + hx, sy + hy, sh(skin[1], .75), 3)
            cv.ell(sx + hx, sy + hy, 2, 2, sh(skin[1], .8))
        auraflare(cv, J, H("#ffcf3a"), 5)
        # tattered cape
        cx = J["cx"] + J["lean"]
        cv.poly([(cx - 8, J["top"] + 2), (cx - 15 - p["sw"], J["hipY"] + 7), (cx - 4, J["hipY"] + 4)], H("#1a1230"))

    def torso(cv, J):
        x0, x1, t, hy = J["cx"] - J["tw"] // 2 + J["lean"] // 2, J["cx"] + J["tw"] // 2 - 1 + J["lean"] // 2, J["top"], J["hipY"]
        # gold sash + belt + hourglass chest emblem
        cv.line(x0 + 1, t + 1, x1 - 1, t + 8, gold, 2)
        cv.rect(x0, hy - 2, x1, hy, gold)
        for k in range(x0 + 1, x1, 3):
            cv.p(k, hy - 1, gold_d)
        mx = (x0 + x1) // 2 + 2
        cv.poly([(mx - 2, t + 9), (mx + 2, t + 9), (mx, t + 11)], acc)
        cv.poly([(mx, t + 11), (mx - 2, t + 13), (mx + 2, t + 13)], acc)
        for (sx, sy, sg) in ((J["shF"][0], J["shF"][1], 1), (J["shB"][0], J["shB"][1], -1)):
            cv.ell_s(sx, sy - 1, 4.5, 3.6, P.ramp(H("#241a44")))
            cv.poly([(sx - 1, sy - 3), (sx + 1, sy - 3), (sx + sg, sy - 7)], gold)

    def head(cv, J):
        x, y = J["hc"]
        # crown: gold band w/ fangs of light
        cv.rect(x - 6, y - 7, x + 5, y - 6, gold)
        for k, hgt in zip((-6, -3, 0, 3), (3, 5, 6, 4)):
            cv.poly([(x + k, y - 7), (x + k + 3, y - 7), (x + k + 1, y - 7 - hgt)], gold)
        cv.p(x, y - 7, H("#ff4d6a"))
        # face: glaring gold eyes, big fanged maw
        cv.rect(x - 1, y - 3, x + 6, y - 3, skin[3])
        eyes(cv, J, acc, 1, -1, 3)
        cv.rect(x - 1, y + 2, x + 6, y + 4, H("#150c20"))
        for k in range(x - 1, x + 7, 2):
            cv.p(k, y + 2, H("#fff4e0"))
            cv.p(k + 1, y + 4, H("#fff4e0"))
        cv.p(x + 6, y + 1, H("#fff4e0"))

    def cf(cv, J):
        x, y = J["hf"]
        dx, dy = wdir(J)
        ln = 20
        ex, ey = x + dx * ln, y + dy * ln
        # a great scythe of time (hooked blade)
        cv.line(x - dx * 6, y - dy * 6, ex, ey, H("#6a4a22"), 2)
        cv.line(ex, ey, ex + dy * 6 + dx * 2, ey - dx * 6 + dy * 2, H("#d8d0f0"), 2)
        cv.line(ex + 1, ey, ex + dy * 5 + dx * 3, ey - dx * 5 + dy * 3, H("#ffffff"), 1)
        cv.p(x, y, gold)
        slash_arc(cv, J, H("#ffe9a0"), 16)

    human(cv, p, dict(skin=skin, cloth=body, torsoW=18, torsoH=17, headR=8, armL=13, armTh=4, cb=cb, torso=torso,
                      head=head, cf=cf, legH=10, armF=skin[1], armB=sh(skin[2], .9), legc=body, legW=6, headH=-1,
                      neck=4))
    return cv.done()


# --------------------------------------------------------------------------- assemble
BOSSES = [
    ("sandekala", boss_sandekala),
    ("faceless_captain", boss_faceless_captain),
    ("sangkuriang", boss_sangkuriang),
    ("barma_wijaya", boss_barma_wijaya),
    ("bandung_bondowoso", boss_bandung_bondowoso),
    ("hariang_banga", boss_hariang_banga),
    ("buto_ijo", boss_buto_ijo),
    ("keris_gandring", boss_keris_gandring),
    ("nameless_hunter", boss_nameless_hunter),
    ("batara_kala", boss_batara_kala),
]


def build(fn):
    idle = [fn("idle", i) for i in range(4)]
    walk = [fn("walk", i) for i in range(4)]
    wind = [fn("wind", i) for i in range(2)]
    strike = [fn("strike", i) for i in range(2)]
    h0 = fn("hurt", 0)
    h0 = P.tint(h0, (255, 255, 255, 255), 0.5)
    w, h = idle[0].size
    cw, ch = w + 2, h + 2
    sh_ = P.sheet(cw, ch, 4, 4)
    for k in range(4):
        P.put(sh_, k, 0, idle[k], cw, ch)
        P.put(sh_, k, 1, walk[k], cw, ch)
    for k, f in enumerate(wind + strike):
        P.put(sh_, k, 2, f, cw, ch)
    for k in range(4):
        P.put(sh_, k, 3, h0 if k < 2 else idle[0], cw, ch)
    return sh_


def main():
    prev = []
    for name, fn in BOSSES:
        s = build(fn)
        path = P.save(s, f"{OUTDIR}/{name}.png")
        prev.append((name, s))
        print(name, s.width // 4, "x", s.height // 4, "->", path)
    os.makedirs(SCRATCH, exist_ok=True)
    scale = 3
    # contact sheet: sheets laid out in a 2 column grid
    P.preview(prev, os.path.join(SCRATCH, "bosses_stack.png"), scale=2)
    for k in range(0, len(prev), 2):
        pass
    for idx, (name, s) in enumerate(prev):
        P.preview([(name, s)], os.path.join(SCRATCH, f"boss_{name}.png"), scale=scale)
    P.preview(prev, os.path.join(SCRATCH, "bosses.png"), scale=2)


if __name__ == "__main__":
    main()
