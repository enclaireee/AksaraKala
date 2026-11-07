#!/usr/bin/env python3
"""Budayago enemy sprite sheets, batch A (15 enemies).

Every enemy is a function draw(mode, t) -> fill-only RGBA canvas (facing right,
feet on the bottom row). modes: idle(t0-3) walk(t0-3) windup strike hurt.
build() outlines each frame and lays out the 4x4 sheet via pixlib.enemy_frames.
Run: python3 tools/gen_enemies_a.py
"""
import os
import sys
from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pixlib as pl
from pixlib import hexc as C, ramp

WHITE = (255, 255, 255, 255)


# ---------------------------------------------------------------- primitives
def new(w, h):
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def R(img, x0, y0, x1, y1, c):
    if x1 < x0 or y1 < y0:
        return
    ImageDraw.Draw(img).rectangle([x0, y0, x1, y1], fill=c)


def P(img, x, y, c):
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), c)


def E(img, x0, y0, x1, y1, c):
    ImageDraw.Draw(img).ellipse([x0, y0, x1, y1], fill=c)


def L(img, x0, y0, x1, y1, c):
    ImageDraw.Draw(img).line([x0, y0, x1, y1], fill=c)


def build(name, W, H, fn):
    """fn(mode, t) draws on a W x H canvas. Returns the sheet image."""
    def fr(mode, t=0):
        return pl.outline(fn(mode, t))
    idle = [fr("idle", i) for i in range(4)]
    walk = [fr("walk", i) for i in range(4)]
    wu = fr("windup")
    st = fr("strike")
    hu = pl.tint(fr("hurt"), WHITE, 0.5)
    cw, ch = W + 4, H + 3
    sh = pl.enemy_frames(idle[0], cw, ch, strike=st, windup=wu, hurt=hu, idle=idle, walk=walk)
    return sh


# ---------------------------------------------------------------- humanoids
def humanoid(cfg, mode, t):
    W, H = cfg["W"], cfg["H"]
    img = new(W, H)
    cx = cfg.get("cx", W // 2 - 2)
    tw, th, lh, hw, hh = cfg["tw"], cfg["th"], cfg["lh"], cfg["hw"], cfg["hh"]
    skin, cloth, trim, pants = cfg["skin"], cfg["cloth"], cfg["trim"], cfg["pants"]
    cl = ramp(cloth)
    pn = ramp(pants)
    sk = ramp(skin)
    uy, lean = 0, 0
    legoff = (0, 0)
    lifted = (False, False)
    if mode == "idle":
        uy = 1 if t in (1, 2) else 0
    elif mode == "walk":
        uy = 1 if t in (1, 3) else 0
        legoff = [(-1, 1), (0, 0), (1, -1), (0, 0)][t]
        lifted = [(False, False), (True, False), (False, False), (False, True)][t]
    elif mode == "windup":
        lean = -1
    elif mode == "strike":
        lean, uy = 2, 1
    elif mode == "hurt":
        lean, uy = -2, 1
    ybot = H - 1 - lh
    ytop = ybot - th + 1 + uy
    tx0 = cx - tw // 2 + lean
    tx1 = tx0 + tw - 1
    # far arm
    R(img, tx0 - 1, ytop + 1, tx0, ytop + 3, cl[2])
    P(img, tx0 - 1, ytop + 4, sk[2])
    # legs
    for i, (lx, off, lf) in enumerate(((cx - 2, legoff[0], lifted[0]), (cx + 1, legoff[1], lifted[1]))):
        c = pn[2] if i == 0 else pn[1]
        h = lh - (1 if lf else 0)
        R(img, lx + off, H - h - 0, lx + off + 1, H - 1, c)
        P(img, lx + off + 1, H - 1, pn[3])
    # torso
    R(img, tx0, ytop, tx1, ybot, cl[1])
    R(img, tx0, ytop, tx0, ybot, cl[2])
    R(img, tx0 + 1, ytop, tx1 - 1, ytop, cl[0])
    R(img, tx0, ybot, tx1, ybot, trim)  # belt
    if cfg.get("ragged"):
        for x in range(tx0, tx1 + 1):
            if (x + t) % 2 == 0 or mode != "idle":
                P(img, x, ybot + 1, cl[2] if x % 2 else cl[3])
        P(img, tx0 - 1, ybot, cl[2])
        P(img, tx0 - 2 + (t % 2), ybot + 1, cl[3])
    # head
    hx0 = cx - hw // 2 + 1 + lean
    hx1 = hx0 + hw - 1
    hy1 = ytop + 1
    hy0 = hy1 - hh + 1
    ht = cfg["head"]
    if ht == "mask":
        mk = ramp(cfg["mask"])
        R(img, hx0, hy0, hx1, hy1, mk[1])
        for (x, y) in ((hx0, hy0), (hx1, hy0)):
            P(img, x, y, (0, 0, 0, 0))
        R(img, hx0, hy0 + 1, hx0, hy1, mk[2])
        R(img, hx0 + 1, hy0, hx1 - 1, hy0, mk[0])
        P(img, hx1 - 1, hy0 + 1, mk[0])
        # ragged hood behind
        R(img, hx0 - 1, hy0, hx0, hy1 + 1, cl[2])
        P(img, hx0 - 2, hy1 + 1, cl[3])
        if cfg.get("crest"):
            g = cfg["glow"]
            for x in (hx0 + 1, hx1 - 1):
                R(img, x, hy0 - 2, x, hy0 - 1, trim)
            P(img, hx0 + hw // 2, hy0 - 1, trim)
    elif ht == "hood":
        hd = ramp(cfg["hood"])
        R(img, hx0, hy0, hx1, hy1, hd[1])
        R(img, hx0, hy0, hx1, hy0, hd[0])
        R(img, hx0, hy0 + 1, hx0, hy1, hd[2])
        R(img, hx1 - 1, hy0 + 2, hx1, hy1 - 1, sk[1])
        P(img, hx1 - 1, hy0 + 2, (20, 14, 20, 255))
        P(img, hx0 - 1, hy0 + 1, hd[2])
    else:  # skin head with headband / cap
        R(img, hx0, hy0, hx1, hy1, sk[1])
        R(img, hx0, hy0 + 1, hx0, hy1, sk[2])
        P(img, hx1 - 1, hy0 + hh // 2 + 1, (24, 14, 20, 255))
        P(img, hx1, hy0 + hh // 2 + 1, (24, 14, 20, 255))
        R(img, hx0, hy1, hx1, hy1, sk[2])
        if ht == "headband":
            R(img, hx0, hy0, hx1, hy0 + 1, (40, 28, 30, 255))
            R(img, hx0, hy0 + 1, hx1, hy0 + 1, trim)
            tail = (t % 2) if mode in ("idle", "walk") else 1
            P(img, hx0 - 1, hy0 + 1, trim)
            P(img, hx0 - 2, hy0 + 1 + tail, trim)
        elif ht == "cap":
            c2 = ramp(cfg["cap"])
            R(img, hx0 - 1, hy0, hx1, hy0 + 1, c2[1])
            R(img, hx0 - 1, hy0, hx1, hy0, c2[0])
            R(img, hx1, hy0 + 2, hx1 + 1, hy0 + 2, c2[2])
    # front arm + weapon
    sx, sy = tx1, ytop + 1
    wt = cfg["weapon"]
    mid = ytop + th // 2
    if mode == "windup":
        hnd = (cx + lean, hy0 - 1)
    elif mode == "strike":
        hnd = (tx1 + 2, ytop + 2)
    elif mode == "hurt":
        hnd = (tx1 + 1, mid + 1)
    else:
        hnd = (tx1 + 1, mid)
    L(img, sx, sy, hnd[0], hnd[1], cl[0])
    hx, hy = hnd
    steel = C("#cfd6e2") if not cfg.get("glow") else C("#bff7ff")
    if wt == "blade":
        bl = cfg.get("bl", 4)
        if mode == "windup":
            L(img, hx, hy, hx - 2, hy - bl, steel)
            P(img, hx - 2, hy - bl, WHITE)
        elif mode == "strike":
            L(img, hx, hy, hx + bl, hy + 1, steel)
            P(img, hx + bl, hy + 1, WHITE)
            # slash arc
            arc = C("#ffffff") if not cfg.get("glow") else C("#8ff4ff")
            for k in range(4):
                P(img, hx + bl - 1 - k, hy - 3 + k, arc)
            P(img, hx + bl, hy + 3, arc)
        elif mode == "hurt":
            L(img, hx, hy, hx + 1, hy + bl - 1, steel)
        else:
            L(img, hx, hy, hx + 1, hy - bl + 1, steel)
            P(img, hx + 1, hy - bl + 1, WHITE)
        P(img, hx, hy, sk[1])
        P(img, hx - 1 if mode != "strike" else hx, hy + 1 if mode != "windup" else hy, trim)
        if cfg.get("glow"):
            pass
    elif wt == "club":
        wood = ramp(C("#a0693a"))
        if mode == "windup":
            a, b = (hx - 1, hy - 1), (hx - 3, hy - 5)
        elif mode == "strike":
            a, b = (hx, hy), (hx + 5, hy + 2)
        elif mode == "hurt":
            a, b = (hx, hy), (hx + 1, hy + 4)
        else:
            a, b = (hx, hy), (hx + 1, hy - 4)
        L(img, a[0], a[1], b[0], b[1], wood[1])
        E(img, b[0] - 1, b[1] - 1, b[0] + 1, b[1] + 1, wood[1])
        P(img, b[0], b[1] - 1, wood[0])
        P(img, b[0] + 1, b[1], wood[2])
        P(img, b[0], b[1], (130, 140, 150, 255))  # iron stud
        P(img, hx, hy, sk[1])
    elif wt == "bow":
        wood = ramp(C("#b07a42"))
        stringc = C("#e8e0c8") if not cfg.get("glow") else C("#8ff4ff")
        bx = tx1 + 3 if mode != "windup" else tx1 + 2
        by = mid - 3 if mode != "hurt" else mid - 2
        n = 8
        for k in range(n):
            off = round(2.0 * (1 - ((k - (n - 1) / 2) / ((n - 1) / 2)) ** 2))
            P(img, bx + off, by + k, wood[1] if k not in (0, n - 1) else wood[2])
        pull = 0
        if mode == "windup":
            pull = 3
        P(img, bx + 1, by + 2, wood[0])
        # string
        top, bot = (bx, by), (bx, by + n - 1)
        mid_pt = (bx - pull, by + (n - 1) // 2)
        L(img, top[0], top[1], mid_pt[0], mid_pt[1], stringc)
        L(img, bot[0], bot[1], mid_pt[0], mid_pt[1], stringc)
        L(img, hnd[0], hnd[1], bx + 1, by + 3, cl[0])
        if mode == "windup":
            ay = mid_pt[1]
            L(img, mid_pt[0], ay, bx + 4, ay, C("#d8c090"))
            P(img, bx + 4, ay, WHITE)
            P(img, mid_pt[0] - 1, ay, sk[1])
        elif mode == "strike":
            ay = by + 3
            L(img, bx + 3, ay, bx + 8, ay, C("#d8c090"))
            P(img, bx + 8, ay, WHITE)
            P(img, bx + 9, ay, C("#ffe9a0"))
    elif wt == "spear":
        gold = cfg["trim"]
        wd = C("#6b4a2a")
        if mode == "windup":
            L(img, hx, hy + 3, hx, hy - 8, wd)
            R(img, hx - 1, hy - 10, hx + 1, hy - 8, gold)
            P(img, hx, hy - 11, WHITE)
        elif mode == "strike":
            L(img, hx - 3, hy, hx + 8, hy, wd)
            R(img, hx + 7, hy - 1, hx + 10, hy + 1, gold)
            P(img, hx + 11, hy, WHITE)
        elif mode == "hurt":
            L(img, hx, hy + 2, hx + 2, hy - 6, wd)
            P(img, hx + 2, hy - 7, gold)
        else:
            L(img, hx + 1, hy + 3, hx + 2, hy - 7, wd)
            R(img, hx + 1, hy - 9, hx + 3, hy - 7, gold)
            P(img, hx + 2, hy - 10, WHITE)
        P(img, hx, hy, sk[1])
    return img


BANDIT = dict(W=17, H=15, tw=6, th=4, lh=2, hw=7, hh=5, skin=C("#e0a878"), cloth=C("#8a4a2a"),
              trim=C("#d83a3a"), pants=C("#3a3a52"), head="headband", weapon="blade", bl=4)
CHASER = dict(W=17, H=15, tw=6, th=4, lh=2, hw=7, hh=5, skin=C("#d9a07a"), cloth=C("#3f72c0"),
              trim=C("#e8c040"), pants=C("#5a4430"), head="cap", cap=C("#8c96a6"), weapon="club")
ARCHER = dict(W=19, H=17, cx=7, tw=5, th=5, lh=2, hw=6, hh=5, skin=C("#e0a878"), cloth=C("#d2a15a"),
              trim=C("#7a2438"), pants=C("#4a2a38"), head="hood", hood=C("#9a2e50"), weapon="bow")
FACELESS = dict(W=17, H=15, tw=6, th=5, lh=1, hw=7, hh=5, skin=C("#ece9df"), cloth=C("#76859a"),
                trim=C("#5be8ff"), pants=C("#3a4252"), head="mask", mask=C("#efede4"),
                weapon="blade", bl=4, ragged=True, glow=True)
FACELESS_A = dict(W=19, H=17, cx=7, tw=5, th=6, lh=1, hw=6, hh=5, skin=C("#ece9df"), cloth=C("#76859a"),
                  trim=C("#5be8ff"), pants=C("#3a4252"), head="mask", mask=C("#efede4"),
                  weapon="bow", ragged=True, glow=True)
CHAMP = dict(W=24, H=22, cx=8, tw=9, th=6, lh=2, hw=9, hh=6, skin=C("#ece9df"), cloth=C("#4f5a6e"),
             trim=C("#e6b84a"), pants=C("#2e3442"), head="mask", mask=C("#f4f2ea"),
             weapon="spear", ragged=True, crest=True, glow=True)


# ---------------------------------------------------------------- dummy
def dummy(mode, t):
    W, H = 16, 17
    img = new(W, H)
    wood = ramp(C("#b9803f"))
    sack = ramp(C("#d8bd78"))
    red = C("#d8403c")
    # base feet
    R(img, 3, H - 2, 12, H - 1, wood[2])
    R(img, 4, H - 3, 11, H - 3, wood[1])
    # post
    R(img, 7, 4, 8, H - 3, wood[1])
    R(img, 7, 4, 7, H - 3, wood[0])
    R(img, 8, 5, 8, H - 3, wood[2])
    # crossbar (arms)
    R(img, 2, 7, 13, 8, wood[1])
    R(img, 2, 7, 13, 7, wood[0])
    R(img, 2, 8, 13, 8, wood[2])
    P(img, 2, 9, sack[2]); P(img, 13, 9, sack[2]); P(img, 3, 9, sack[1]); P(img, 12, 9, sack[1])
    # straw hands
    for x, y in ((1, 7), (1, 9), (14, 7), (14, 9), (0, 8), (15, 8)):
        P(img, x, y, C("#e8cf80"))
    # burlap head with target
    E(img, 4, 0, 11, 6, sack[1])
    E(img, 5, 1, 10, 5, sack[0])
    E(img, 6, 2, 9, 4, red)
    E(img, 7, 3, 8, 3, WHITE)
    P(img, 4, 3, sack[2]); P(img, 4, 4, sack[2]); P(img, 5, 5, sack[2])
    P(img, 11, 1, C("#e8cf80")); P(img, 3, 1, C("#e8cf80"))
    # rope belt
    R(img, 6, 11, 9, 11, C("#7a5a30"))
    # sway
    if mode == "idle":
        img = pl.shear_top(img, [0, 0, 1, 1][t] * -1 if False else [0, 1, 0, -1][t])
    elif mode == "walk":
        img = pl.shear_top(pl.shift(img, 0, -1 if t % 2 else 0), [1, 0, -1, 0][t] * 2)
    elif mode == "windup":
        img = pl.shear_top(img, -3)
    elif mode == "strike":
        img = pl.shear_top(pl.squash(img, 0.94, 1.0), 4)
    elif mode == "hurt":
        img = pl.shear_top(img, -4)
    return img


# ---------------------------------------------------------------- arca (statues)
def arca_gen(cfg, mode, t):
    W, H = cfg["W"], cfg["H"]
    img = new(W, H)
    st = ramp(cfg["stone"])
    g = cfg["glow"]
    gh = pl.shade(g, 1.5)
    gold = cfg.get("gold")
    px = 0
    if mode == "walk":
        px = [0, 1, 0, -1][t]
    if mode == "hurt":
        px = -2
    if mode == "strike":
        px = 1
    cx = cfg["cx"]
    pw, ph = cfg["pw"], cfg["ph"]
    # pedestal
    R(img, cx - pw // 2, H - ph, cx + pw // 2, H - 1, st[2])
    R(img, cx - pw // 2, H - ph, cx + pw // 2, H - ph, st[1])
    R(img, cx - pw // 2 + 1, H - 1, cx + pw // 2 - 1, H - 1, st[3])
    P(img, cx, H - 2, st[3])
    bob = 1 if (mode == "idle" and t in (1, 2)) else 0
    tw, th = cfg["tw"], cfg["th"]
    ty1 = H - ph - 1
    ty0 = ty1 - th + 1
    tx0 = cx - tw // 2 + px
    tx1 = tx0 + tw - 1
    R(img, tx0, ty0, tx1, ty1, st[1])
    R(img, tx0, ty0, tx0, ty1, st[2])
    R(img, tx0 + 1, ty0, tx1, ty0, st[0])
    R(img, tx0, ty1, tx1, ty1, gold or st[2])
    # chest gem
    pulse = {"windup": 2, "strike": 2}.get(mode, 1 if (t % 2 == 1 and mode == "idle") else 0)
    gx, gy = tx0 + tw // 2 + 1, ty0 + 2
    P(img, gx, gy, gh if pulse else g)
    if pulse == 2:
        P(img, gx - 1, gy, g); P(img, gx + 1, gy, g); P(img, gx, gy - 1, g); P(img, gx, gy + 1, g)
    # crack
    P(img, tx0 + 1, ty0 + 3, st[3]); P(img, tx0 + 2, ty0 + 4, st[3])
    # head
    hw, hh = cfg["hw"], cfg["hh"]
    hx0 = cx - hw // 2 + 1 + px
    hy1 = ty0 + 1 + bob
    hy0 = hy1 - hh + 1
    R(img, hx0, hy0, hx0 + hw - 1, hy1, st[1])
    R(img, hx0, hy0, hx0 + hw - 1, hy0, st[0])
    R(img, hx0, hy0 + 1, hx0, hy1, st[2])
    # headdress / crown
    cc = gold or st[0]
    R(img, hx0 - 1, hy0 - 1, hx0 + hw, hy0, cc)
    for k in range(0, hw, 2):
        P(img, hx0 + k, hy0 - 2, cc)
    if cfg.get("fangs"):
        P(img, hx0 + hw - 2, hy1 + 1, WHITE)
        P(img, hx0 + 2, hy1 + 1, WHITE)
    # eyes glowing
    ey = hy0 + 2
    eyec = gh if mode in ("windup", "strike") else g
    P(img, hx0 + hw - 2, ey, eyec)
    P(img, hx0 + hw - 4, ey, eyec)
    P(img, hx0 + hw - 3, hy1, st[3])
    # arms and weapon
    sx, sy = tx1, ty0 + 1
    if cfg["kind"] == "shooter":
        if mode == "windup":
            hnd = (tx1 + 2, ty0 - 2)
            L(img, sx, sy, hnd[0], hnd[1], st[0])
            E(img, hnd[0] - 1, hnd[1] - 3, hnd[0] + 1, hnd[1] - 1, g)
            P(img, hnd[0], hnd[1] - 2, WHITE)
        elif mode == "strike":
            hnd = (tx1 + 3, ty0 + 1)
            L(img, sx, sy, hnd[0], hnd[1], st[0])
            R(img, hnd[0] + 1, hnd[1] - 1, W - 1, hnd[1] + 1, g)
            R(img, hnd[0] + 1, hnd[1], W - 1, hnd[1], WHITE)
        else:
            hnd = (tx1 + 1, ty0 + 4)
            L(img, sx, sy, hnd[0], hnd[1], st[0])
            P(img, hnd[0], hnd[1], g)
        R(img, tx0 - 1, ty0 + 1, tx0, ty0 + 4, st[2])
    else:  # guardian with club
        wood = ramp(C("#4a3a30"))
        if mode == "windup":
            hnd = (cx + px, hy0 - 2)
            L(img, sx, sy, hnd[0], hnd[1], st[0])
            L(img, hnd[0], hnd[1], hnd[0] - 2, hnd[1] - 7, wood[1])
            R(img, hnd[0] - 4, hnd[1] - 11, hnd[0] - 1, hnd[1] - 7, cc if cc != st[0] else st[2])
            P(img, hnd[0] - 3, hnd[1] - 10, g)
        elif mode == "strike":
            hnd = (tx1 + 3, ty0 + 3)
            L(img, sx, sy, hnd[0], hnd[1], st[0])
            L(img, hnd[0], hnd[1], hnd[0] + 4, hnd[1] + 4, wood[1])
            R(img, hnd[0] + 3, hnd[1] + 3, W - 1, hnd[1] + 7, cc if cc != st[0] else st[2])
            P(img, W - 2, hnd[1] + 5, g)
        else:
            hnd = (tx1 + 2, ty0 + 5)
            L(img, sx, sy, hnd[0], hnd[1], st[0])
            L(img, hnd[0], hnd[1] + 1, hnd[0] + 1, hnd[1] - 7, wood[1])
            R(img, hnd[0] - 1, hnd[1] - 10, hnd[0] + 2, hnd[1] - 7, st[2])
            P(img, hnd[0], hnd[1] - 9, g)
        R(img, tx0 - 2, ty0 + 1, tx0, ty0 + 5, st[2])
        # shield on back arm
        R(img, tx0 - 3, ty0 + 2, tx0 - 2, ty0 + 6, cc)
    # dust when walking/hurt
    if mode == "walk" and t % 2:
        P(img, cx - pw // 2 - 1, H - 1, C("#a8a090"))
    return img


ARCA = dict(W=22, H=22, cx=8, pw=8, ph=3, tw=6, th=7, hw=6, hh=5, stone=C("#a69a86"),
            glow=C("#3fe0e8"), kind="shooter")
ARCA_P = dict(W=26, H=29, cx=10, pw=10, ph=3, tw=10, th=9, hw=8, hh=6, stone=C("#7c7488"),
              glow=C("#ff5a3a"), gold=C("#e0b040"), kind="guard", fangs=True)


# ---------------------------------------------------------------- bajul (side-view croc)
def bajul(cfg, mode, t):
    W, H = cfg["W"], cfg["H"]
    img = new(W, H)
    bc = ramp(cfg["body"])
    belly = cfg["belly"]
    legh, bh = cfg["legh"], cfg["bh"]
    hl = cfg["hl"]  # head length
    dx = 0
    op = 0
    hy = 0
    bob = 0
    tail = 0
    legs = [0, 0, 0, 0]
    lf = [False] * 4
    if mode == "idle":
        bob = 1 if t in (1, 2) else 0
        op = 1 if t == 2 else 0
        tail = [0, 1, 0, -1][t]
    elif mode == "walk":
        legs = [[-1, 1, 1, -1], [0, 0, 0, 0], [1, -1, -1, 1], [0, 0, 0, 0]][t]
        lf = [[False] * 4, [True, False, False, True], [False] * 4, [False, True, True, False]][t]
        tail = [1, 0, -1, 0][t]
        bob = t % 2
    elif mode == "windup":
        dx, op, hy = -2, cfg["open"], -2
        bob = -0
    elif mode == "strike":
        dx, op, hy = 3, 1, 1
    elif mode == "hurt":
        dx, op, hy = -2, 2, -1
    gy = H - 1
    by1 = gy - legh
    by0 = by1 - bh + 1 + bob
    bx0 = 4 + max(dx, 0) - (2 if mode == "windup" or mode == "hurt" else 0)
    bx1 = W - hl - 2 + dx - 1
    # far legs (dark)
    for i, x in enumerate((bx1 - 3 + legs[2], bx0 + 2 + legs[3])):
        h = legh - (1 if lf[2 + i] else 0)
        R(img, x, gy - h + 1, x + 1, gy, bc[3])
    # tail
    seg = bx0
    ty = by0 + bh // 2
    for k in range(1, cfg["tl"] + 1):
        w = max(1, bh - 1 - k * (bh - 1) // (cfg["tl"] + 1) * 1)
        x = seg - k
        yy = ty + (tail if k > cfg["tl"] // 2 else 0)
        R(img, x, yy - w // 2 + (1 if bob else 0), x, yy - w // 2 + w - 1 + (1 if bob else 0), bc[1] if k % 2 else bc[2])
    # body
    R(img, bx0, by0, bx1, by1, bc[1])
    R(img, bx0, by0, bx1, by0, bc[0])
    R(img, bx0, by1, bx1, by1, belly)
    R(img, bx0 + 1, by1 - 1, bx1 - 1, by1 - 1, bc[2])
    # dorsal bumps
    for x in range(bx0 + 1, bx1, 2):
        P(img, x, by0 - 1, bc[0] if not cfg.get("spike") else cfg["spike"])
        if cfg.get("spike") and x % 4 == 1:
            P(img, x, by0 - 2, cfg["spike"])
    if cfg.get("scar"):
        P(img, bx0 + 3, by0 + 1, cfg["scar"]); P(img, bx0 + 4, by0 + 2, cfg["scar"])
        P(img, bx0 + 6, by0 + 2, cfg["scar"]); P(img, bx0 + 7, by0 + 3, cfg["scar"])
    # head
    hx0 = bx1 - 1
    hx1 = min(W - 1, hx0 + hl + 1)
    hh_up = max(2, bh // 2)
    hh_lo = max(1, bh // 3)
    hty = by0 + 1 + hy
    uy0 = hty - op
    # lower jaw
    ly0 = hty + hh_up
    R(img, hx0, ly0, hx1 - 1, ly0 + hh_lo - 1, bc[1] if True else belly)
    R(img, hx0, ly0 + hh_lo - 1, hx1 - 1, ly0 + hh_lo - 1, belly)
    # mouth interior
    if op > 0:
        R(img, hx0 + 2, hty + hh_up - op, hx1 - 1, ly0 - 1, C("#d8505a"))
        # teeth
        for x in range(hx0 + 3, hx1, 2):
            P(img, x, ly0 - 1, WHITE)
            P(img, x - 1 if x - 1 > hx0 + 2 else x, uy0 + hh_up, WHITE)
    else:
        for x in range(hx0 + 3, hx1, 2):
            P(img, x, ly0, WHITE)
    # upper jaw
    R(img, hx0, uy0, hx1, uy0 + hh_up - 1, bc[1])
    R(img, hx0, uy0, hx1, uy0, bc[0])
    R(img, hx1 - 1, uy0 + 1, hx1, uy0 + 1, bc[2])  # nostril
    P(img, hx1, uy0 + 1, bc[3])
    # eye
    ec = cfg["eye"]
    P(img, hx0 + 1, uy0 + 1, ec)
    P(img, hx0 + 2, uy0 + 1, ec) if cfg.get("big_eye") else None
    P(img, hx0 + 1, uy0, bc[2])
    # near legs
    for i, x in enumerate((bx1 - 4 + legs[0], bx0 + 1 + legs[1])):
        h = legh - (1 if lf[i] else 0)
        R(img, x, gy - h + 1, x + 2, gy, bc[1])
        R(img, x, gy, x + 2, gy, bc[2])
        P(img, x + 2, gy, bc[3])
    return img


BAJUL = dict(W=22, H=14, body=C("#e6e0c8"), belly=C("#fff6d8"), legh=2, bh=5, hl=7, tl=4, eye=C("#d8a020"), open=3)
BAJUL_T = dict(W=30, H=18, body=C("#b8b4a0"), belly=C("#e8e0c0"), legh=3, bh=7, hl=9, tl=5, eye=C("#fff8e0"),
               open=4, spike=C("#6a6a72"), scar=C("#6a4a4a"), big_eye=True)


# ---------------------------------------------------------------- banaspati (flame heads)
def banaspati(cfg, mode, t):
    W, H = cfg["W"], cfg["H"]
    img = new(W, H)
    r = cfg["r"]
    out, mid, core = cfg["cols"]
    dark = cfg["dark"]
    cx = cfg["cx"]
    cy = H - 1 - r - cfg["lift"]
    sw = 0
    dy = 0
    open_ = False
    flare = 0
    if mode == "idle":
        dy = [0, -1, -1, 0][t]
    elif mode == "walk":
        dy = [0, -1, 0, -1][t]
        sw = [-1, 0, 1, 0][t]
    elif mode == "windup":
        flare = 2
        dy = 1
        sw = -2
    elif mode == "strike":
        sw = 3
        open_ = True
        dy = 0
    elif mode == "hurt":
        sw = -2
        dy = 1
    cx += sw
    cy += dy
    # trail (left/down)
    n = cfg["trail"]
    for k in range(n):
        tr = max(1, r - 1 - k * (r - 1) // n)
        tx = cx - r - k * (2 if mode != "strike" else 3) + (1 if mode == "strike" else 0)
        ty = cy + r // 2 + k // 2 + [0, 1, 0, 1][(t + k) % 4] * (1 if mode in ("idle", "walk") else 0)
        E(img, tx - tr // 2, ty - tr // 2, tx + tr // 2, ty + tr // 2, out if k % 2 == 0 else mid)
        if tr >= 3:
            P(img, tx, ty, core)
    # flame tips on top
    tips = cfg["tips"]
    for i, ox in enumerate(tips):
        h = 2 + ((i + t) % 3) + flare
        if mode == "strike":
            h = 1
        x = cx + ox - 1
        R(img, x, cy - r - h + 1, x + (1 if r > 6 else 0), cy - r + 1, out)
        P(img, x, cy - r - h + 1, mid)
    # head
    E(img, cx - r, cy - r, cx + r, cy + r, out)
    E(img, cx - r + 1, cy - r + 2, cx + r - 1, cy + r - 1, mid)
    E(img, cx - r + 2, cy - r + 3, cx + r - 3, cy + r - 2, core)
    # face on right
    fy = cy - r // 3
    ex1 = cx + r // 2 + 1
    ex0 = cx + 0
    if mode in ("windup", "strike"):
        L(img, ex0 - 1, fy - 1, ex0 + 1, fy, dark)
        L(img, ex1 + 1, fy - 1, ex1 - 1, fy, dark)
    R(img, ex0, fy, ex0 + (1 if r > 5 else 0), fy + 1, dark)
    R(img, ex1, fy, ex1 + (1 if r > 5 else 0), fy + 1, dark)
    P(img, ex0, fy, WHITE if r < 7 else cfg["eye"])
    P(img, ex1, fy, WHITE if r < 7 else cfg["eye"])
    my = cy + r // 2
    if open_ or mode == "windup":
        R(img, ex0, my - 1, ex1 + 1, my + 1, dark)
        P(img, ex0 + 1, my - 1, WHITE); P(img, ex1, my + 1, WHITE)
    else:
        for x in range(ex0, ex1 + 1):
            P(img, x, my + (x % 2), dark)
    # embers
    if cfg.get("crown"):
        for k, ox in enumerate((-3, 0, 3)):
            hh = 3 + ((k + t) % 2) + flare
            L(img, cx + ox, cy - r, cx + ox + (1 if ox > 0 else -1 if ox < 0 else 0), cy - r - hh, cfg["crown"])
    return img


BANASPATI = dict(W=17, H=15, r=4, cx=10, cols=(C("#ff6a1a"), C("#ffa828"), C("#ffe680")), dark=C("#4a1008"),
                 eye=C("#ff3a1a"), lift=1, trail=3, tips=(-2, 0, 2))
BANASPATI_E = dict(W=28, H=24, r=7, cx=16, cols=(C("#d8267a"), C("#ff5a3a"), C("#ffd060")), dark=C("#2a0a28"),
                   eye=C("#7a1a8a"), lift=1, trail=4, tips=(-4, -1, 2, 5), crown=C("#8a3ae0"))


# ---------------------------------------------------------------- genderuwo
def genderuwo(mode, t):
    W, H = 30, 30
    img = new(W, H)
    fur = ramp(C("#6a4636"))
    rock = ramp(C("#8d939c"))
    dark = C("#1a0e10")
    cx = 11
    uy, lean = 0, 0
    lo = (0, 0)
    lf = (False, False)
    armswing = 0
    if mode == "idle":
        uy = 1 if t in (1, 2) else 0
        armswing = [0, 1, 1, 0][t]
    elif mode == "walk":
        uy = 1 if t in (1, 3) else 0
        lo = [(-2, 2), (0, 0), (2, -2), (0, 0)][t]
        lf = [(False, False), (True, False), (False, False), (False, True)][t]
        armswing = [-2, 0, 2, 0][t]
    elif mode == "windup":
        lean = -2
    elif mode == "strike":
        lean, uy = 3, 1
    elif mode == "hurt":
        lean, uy = -3, 1
    gy = H - 1
    # legs
    for i, (x, off) in enumerate(((cx - 5, lo[0]), (cx + 1, lo[1]))):
        h = 4 - (1 if lf[i] else 0)
        R(img, x + off, gy - h + 1, x + off + 3, gy, fur[2] if i == 0 else fur[1])
        R(img, x + off, gy, x + off + 3, gy, fur[3])
        P(img, x + off, gy - 1, WHITE)  # claws hint
    # torso (wide, hunched)
    ty1 = gy - 4
    ty0 = ty1 - 9 + uy
    tx0 = cx - 6 + lean
    tx1 = cx + 6 + lean
    R(img, tx0, ty0 + 1, tx1, ty1, fur[1])
    R(img, tx0 + 1, ty0, tx1 - 1, ty0, fur[1])
    R(img, tx0, ty0 + 1, tx0 + 2, ty1, fur[2])
    R(img, tx0 + 3, ty0, tx1 - 4, ty0, fur[0])
    # fur tufts (jagged bottom and sides)
    for x in range(tx0, tx1 + 1, 2):
        P(img, x, ty1 + 1, fur[2])
    for y in range(ty0 + 2, ty1, 2):
        P(img, tx0 - 1, y, fur[2])
        P(img, tx1 + 1, y, fur[1])
    for x in range(tx0 + 2, tx1 - 1, 3):
        P(img, x, ty0 + 3, fur[0]); P(img, x + 1, ty0 + 4, fur[3])
    # chest tuft pale
    R(img, cx + lean - 1, ty0 + 5, cx + lean + 2, ty0 + 6, fur[0])
    # head (small, between shoulders, forward)
    hx0 = cx - 3 + 2 + lean
    hy1 = ty0 + 2
    hy0 = hy1 - 6
    R(img, hx0, hy0, hx0 + 7, hy1, fur[1])
    R(img, hx0 - 1, hy0 + 1, hx0 + 8, hy1 - 1, fur[1])
    R(img, hx0, hy0, hx0 + 7, hy0, fur[0])
    # hair tufts
    for k, x in enumerate(range(hx0, hx0 + 8, 2)):
        P(img, x, hy0 - 1 - (k % 2), fur[1])
    # face: dark mask area
    R(img, hx0 + 3, hy0 + 2, hx0 + 7, hy1 - 1, C("#9a6a50"))
    R(img, hx0 + 3, hy0 + 2, hx0 + 7, hy0 + 2, fur[3])  # brow
    eye = C("#ff3030") if mode in ("windup", "strike") else C("#ffb030")
    P(img, hx0 + 4, hy0 + 3, eye); P(img, hx0 + 6, hy0 + 3, eye)
    P(img, hx0 + 5, hy0 + 3, dark)
    # tusks + mouth
    R(img, hx0 + 3, hy1 - 1, hx0 + 7, hy1 - 1, dark)
    if mode in ("windup", "strike", "hurt"):
        R(img, hx0 + 3, hy1 - 2, hx0 + 7, hy1, dark)
    P(img, hx0 + 3, hy1 - 2, WHITE); P(img, hx0 + 7, hy1 - 2, WHITE)
    # arms
    sx, sy = tx1 + 1, ty0 + 2
    bx, by = tx0, ty0 + 2
    # back arm
    R(img, bx - 2, by, bx, by + 6 + armswing, fur[2])
    R(img, bx - 3, by + 6 + armswing, bx, by + 8 + armswing, fur[3])
    if mode == "windup":
        hx, hy = cx - 1 + lean, hy0 - 4
        L(img, sx, sy, hx, hy + 1, fur[1]); L(img, sx, sy + 1, hx, hy + 2, fur[1]); L(img, sx, sy + 2, hx + 1, hy + 2, fur[2])
        # rock overhead
        E(img, hx - 3, hy - 5, hx + 3, hy + 1, rock[1])
        R(img, hx - 2, hy - 4, hx, hy - 3, rock[0]); P(img, hx + 2, hy, rock[2]); R(img, hx - 3, hy - 1, hx - 2, hy, rock[2])
        R(img, hx - 3, hy + 1, hx - 1, hy + 2, fur[1]); R(img, hx + 1, hy + 1, hx + 3, hy + 2, fur[1])
    elif mode == "strike":
        hx, hy = tx1 + 6, ty0 + 5
        R(img, sx, sy, hx, sy + 3, fur[1]); R(img, sx, sy, hx, sy, fur[0])
        R(img, hx - 1, hy - 2, hx + 3, hy + 2, fur[1]); R(img, hx + 3, hy - 1, hx + 3, hy + 1, fur[2])
        # thrown rock flying
        E(img, W - 6, hy - 3, W - 1, hy + 2, rock[1]); R(img, W - 5, hy - 2, W - 4, hy - 2, rock[0]); P(img, W - 2, hy + 1, rock[2])
        for k in range(3):
            P(img, W - 8 - k * 1, hy - 1 + k, WHITE)
    elif mode == "hurt":
        R(img, sx, sy, sx + 2, sy + 6, fur[1]); R(img, sx, sy + 6, sx + 3, sy + 8, fur[2])
    else:
        a = armswing
        R(img, sx, sy, sx + 3, sy + 6 - a, fur[1]); R(img, sx, sy, sx, sy + 6 - a, fur[0])
        R(img, sx, sy + 6 - a, sx + 4, sy + 8 - a, fur[1])
        R(img, sx + 3, sy + 6 - a, sx + 4, sy + 8 - a, fur[2])
        P(img, sx + 4, sy + 9 - a, WHITE)
    return img


# ---------------------------------------------------------------- jurig leuweung
def jurig(mode, t, elite=False):
    W, H = 26, 28
    img = new(W, H)
    bark = ramp(C("#5e3c32" if elite else "#7c5a4a"))
    moss = ramp(C("#f4a236" if elite else "#b4e070"))
    glow = C("#ff5040" if elite else "#5ff0d0")
    dark = C("#1a1218")
    cx = 11
    sway = 0
    uy = 0
    fo = (0, 0)
    if mode == "idle":
        sway = [0, 0, 1, 0][t]
        uy = 1 if t in (1, 2) else 0
    elif mode == "walk":
        fo = [(-1, 1), (0, 0), (1, -1), (0, 0)][t]
        sway = [-1, 0, 1, 0][t]
        uy = 1 if t % 2 else 0
    elif mode == "windup":
        sway = -2
    elif mode == "strike":
        sway = 3
        uy = 1
    elif mode == "hurt":
        sway = -3
        uy = 1
    gy = H - 1
    # roots (feet)
    for dx, off in ((-6, fo[0]), (-3, 0), (2, 0), (5, fo[1])):
        R(img, cx + dx + off, gy - 1, cx + dx + off + 2, gy, bark[2])
    R(img, cx - 5, gy - 3, cx + 5, gy - 2, bark[2])
    P(img, cx - 6, gy - 2, bark[3]); P(img, cx + 6, gy - 2, bark[3]); P(img, cx + 7 + fo[1], gy, bark[3])
    # trunk tapering: wider at bottom, shoulders in middle
    top = 7 + uy
    for y in range(top + 4, gy - 3):
        w = 4 + (y - top - 4) // 4
        off = round(sway * (1 - y / gy))
        R(img, cx - w + off, y, cx + w + off, y, bark[1])
        P(img, cx - w + off, y, bark[2]); P(img, cx - w + off + 1, y, bark[2])
        P(img, cx + w + off, y, bark[2])
    # bark texture
    for y in range(top + 6, gy - 4, 3):
        off = round(sway * (1 - y / gy))
        P(img, cx - 2 + off, y, bark[3]); P(img, cx + 1 + off, y + 1, bark[3]); P(img, cx + 3 + off, y - 1, bark[0])
    # moss patches
    off = round(sway * 0.5)
    R(img, cx - 6 + off, top + 10, cx - 4 + off, top + 11, moss[1])
    P(img, cx - 5 + off, top + 10, moss[0])
    R(img, cx + 2 + off, top + 13, cx + 4 + off, top + 13, moss[1])
    P(img, cx + 7 + off, top + 6, moss[2])
    # head: hollow hooded crown
    hx = cx + sway
    R(img, hx - 5, top, hx + 5, top + 6, bark[1])
    R(img, hx - 4, top - 1, hx + 4, top - 1, bark[1])
    R(img, hx - 5, top, hx - 4, top + 6, bark[2])
    R(img, hx - 3, top, hx + 3, top, bark[0])
    # face hollow
    R(img, hx - 1, top + 2, hx + 5, top + 5, dark)
    eye = glow
    P(img, hx + 1, top + 3, eye); P(img, hx + 4, top + 3, eye)
    if mode in ("windup", "strike"):
        P(img, hx + 1, top + 2, eye); P(img, hx + 4, top + 2, eye)
        R(img, hx + 1, top + 5, hx + 4, top + 5, eye)
    else:
        R(img, hx + 2, top + 5, hx + 3, top + 5, glow)
    # leafy crown / hair
    lc = moss
    up = 2 if mode == "windup" else 0
    for k, x in enumerate(range(hx - 5, hx + 6, 2)):
        hh = 2 + (k + t) % 2 + up
        R(img, x, top - 1 - hh, x + 1, top - 1, lc[1] if k % 2 else lc[2])
        P(img, x, top - 1 - hh, lc[0])
    # arms: branches
    sx, sy = hx + 5, top + 6
    bx, by = hx - 5, top + 6
    R(img, bx - 3, by, bx, by + 1, bark[2])
    L(img, bx - 3, by + 1, bx - 5, by + 6, bark[2])
    P(img, bx - 5, by + 7, moss[2])
    if mode == "windup":
        L(img, sx, sy, sx - 2, sy - 8, bark[1]); L(img, sx + 1, sy, sx - 1, sy - 8, bark[1])
        L(img, sx - 2, sy - 8, sx - 5, sy - 11, bark[1]); L(img, sx - 2, sy - 8, sx, sy - 11, bark[1])
        P(img, sx - 5, sy - 12, moss[0]); P(img, sx, sy - 12, moss[0])
        L(img, bx, by, bx - 2, by - 7, bark[2])
        P(img, bx - 3, by - 8, moss[2])
    elif mode == "strike":
        L(img, sx, sy, W - 3, sy + 4, bark[1]); L(img, sx, sy + 1, W - 3, sy + 5, bark[1])
        L(img, W - 3, sy + 4, W - 1, sy + 1, bark[1]); L(img, W - 3, sy + 4, W - 1, sy + 7, bark[1])
        L(img, W - 3, sy + 5, W - 2, sy + 8, bark[2])
        for k in range(4):
            P(img, W - 8 + k, sy - 3 + k, glow)
    elif mode == "hurt":
        L(img, sx, sy, sx + 2, sy + 6, bark[1]); P(img, sx + 3, sy + 7, moss[2])
    else:
        a = 1 if t in (1, 2) else 0
        L(img, sx, sy, sx + 3, sy + 6 + a, bark[1]); L(img, sx + 1, sy, sx + 4, sy + 6 + a, bark[1])
        L(img, sx + 3, sy + 6 + a, sx + 2, sy + 9 + a, bark[2]); L(img, sx + 4, sy + 6 + a, sx + 6, sy + 9 + a, bark[2])
        P(img, sx + 3, sy + 7 + a, moss[1])
    return img


# ---------------------------------------------------------------- driver
def make_all():
    sheets = []
    def H_(cfg):
        return lambda m, t: humanoid(cfg, m, t)
    def A_(cfg):
        return lambda m, t: arca_gen(cfg, m, t)
    def B_(cfg):
        return lambda m, t: bajul(cfg, m, t)
    def N_(cfg):
        return lambda m, t: banaspati(cfg, m, t)
    jobs = [
        ("arca", ARCA["W"], ARCA["H"], A_(ARCA)),
        ("arca_penjaga", ARCA_P["W"], ARCA_P["H"], A_(ARCA_P)),
        ("bajul_putih", BAJUL["W"], BAJUL["H"], B_(BAJUL)),
        ("bajul_putih_tua", BAJUL_T["W"], BAJUL_T["H"], B_(BAJUL_T)),
        ("banaspati", BANASPATI["W"], BANASPATI["H"], N_(BANASPATI)),
        ("banaspati_elite", BANASPATI_E["W"], BANASPATI_E["H"], N_(BANASPATI_E)),
        ("bandit", BANDIT["W"], BANDIT["H"], H_(BANDIT)),
        ("bandit_archer", ARCHER["W"], ARCHER["H"], H_(ARCHER)),
        ("chaser", CHASER["W"], CHASER["H"], H_(CHASER)),
        ("dummy", 16, 17, dummy),
        ("faceless", FACELESS["W"], FACELESS["H"], H_(FACELESS)),
        ("faceless_archer", FACELESS_A["W"], FACELESS_A["H"], H_(FACELESS_A)),
        ("faceless_champion", CHAMP["W"], CHAMP["H"], H_(CHAMP)),
        ("genderuwo", 30, 30, genderuwo),
        ("jurig_leuweung", 26, 28, jurig),
        ("jurig_leuweung_elite", 26, 28, lambda m, t: jurig(m, t, True)),
    ]
    for name, w, h, fn in jobs:
        sh = build(name, w, h, fn)
        pl.save(sh, f"enemies/{name}.png")
        sheets.append((name, sh))
    return sheets


if __name__ == "__main__":
    sheets = make_all()
    out = sys.argv[1] if len(sys.argv) > 1 else None
    if out:
        # contact sheet: two columns of sheets
        scale = 3
        half = (len(sheets) + 1) // 2
        cols = [sheets[:half], sheets[half:]]
        imgs = []
        for col in cols:
            tmp = os.path.join(os.path.dirname(out), "_col.png")
            pl.preview(col, tmp, scale=scale)
            imgs.append(Image.open(tmp))
        W = sum(i.width for i in imgs)
        Hh = max(i.height for i in imgs)
        o = Image.new("RGBA", (W, Hh), (70, 96, 70, 255))
        x = 0
        for i in imgs:
            o.alpha_composite(i, (x, 0))
            x += i.width
        o.save(out)
    for n, s in sheets:
        print(n, s.size, (s.width // 4, s.height // 4))
