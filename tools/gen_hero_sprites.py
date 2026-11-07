#!/usr/bin/env python3
"""Budayago hero sprite sheets (v3, Phase 6c). 24x24 cells (was 16x24: attack poses need room for the weapon), 6 cols x 18 rows (contract used by player.gd):
 rows 0-2 idle (down, side, up), cols 0-3 | 3-5 walk (down, side, up), cols 0-3
 rows 6-8 attack hit 1-3, SIDE view (game flips for left), 6 frames each
 row 9 dodge, 6 frames: crouch, launch, tuck, roll, land, rise | 10 hurt (cols 0-3) | 11 death (cols 0-3)
 rows 12-14 attack hit 1-3, DOWN view | rows 15-17 attack hit 1-3, UP view
 Attack frames: 0 anticipation, 1 coil, 2 strike, 3 smear-pose, 4 follow-through, 5 settle.
   melee: wind-up = 0-1, active = 2-3, recovery = 4-5. Ranged (bow/staff, no active phase): wind-up = 0-2
   (raise, draw/charge, hold), recovery = 3-5 (release, recoil, settle).
 Hit 1 forehand, hit 2 backhand, hit 3 finisher (thrust for base/rogue, ground slam for warrior and mage staff,
 full draw for the bow). The weapon smear is a separate sprite (tools/gen_combat_fx.py).
Art is authored as layered ASCII (head/torso, class overlays, legs) then auto-outlined by pixlib.
Run: python3 tools/gen_hero_sprites.py
Outputs: assets/art/hero_{base,warrior,archer,rogue,mage}.png, hero_shadow.png, and a preview in tools/hero_preview.png
Needs PIL, or falls back to the stdlib shim tools/pilite.py.
"""
import math
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pilite
pilite.install()
from PIL import Image
import pixlib as px
from pixlib import hexc

COLS, ROWS = 6, 18

CW, CH = 24, 24      # 24 wide so attack poses have room for the weapon in front of the body
AW = 22              # attack canvas width (body composed on IW, pasted at an offset)
IW, IH = 14, 21      # inner canvas (outline adds 1 px each side)
Y0 = 3               # row of the first head row (headroom for hats/buns/crowns)

# ---- shared colors ----
COMMON = {
    "s": hexc("E3A66E"), "k": hexc("F6CC9A"), "S": hexc("B87848"),
    "h": hexc("2A1D26"), "H": hexc("4F3A4A"), "e": hexc("18122B"),
    "m": hexc("C9D3DF"), "M": hexc("F4F8FC"), "g": hexc("F2B84B"), "G": hexc("FFE08A"),
    "b": hexc("3A2A33"), "w": hexc("FFFFFF"),
}

CLASSES = {
    "base": dict(t="C8A06A", T="9C7A4A", u="E2C08A", a="7A4E2A", p="5E4630", P="43321F", c="D8D2B8", C="A39E86", q="7A4E2A", f="E8E2D0"),
    "warrior": dict(t="B8353A", T="7E2230", u="E0575A", a="F2B84B", p="3B2B4A", P="271C33", c="8A5A2B", C="5E3B1E", q="7A4E2A", f="E8E2D0"),
    "archer": dict(t="5F9E4A", T="3A6B34", u="8DC265", a="C98A2B", p="8A6A44", P="5E4630", c="E7D27C", C="B59B48", q="7A4E2A", f="F4EFD8"),
    "rogue": dict(t="4B446E", T="2D2847", u="8A82B8", a="D93848", p="2D2847", P="1A162E", c="1A162E", C="0E0C1C", q="6E6794", f="E8E2D0"),
    "mage": dict(t="1E8C8F", T="12606A", u="57C7BE", a="F2B84B", p="1E8C8F", P="12606A", c="F2B84B", C="C98A2B", q="7A4E2A", f="BFF3FF"),
}


def palette(cls):
    pal = dict(COMMON)
    for k, v in CLASSES[cls].items():
        pal[k] = hexc(v)
    return pal


# ---- head + torso + hips (14 wide, 14 rows). Face down, side (faces right), up (back) ----
FRONT = [
    "....hhhhhh....",
    "...hhHHhhhh...",
    "...hhhhhhhh...",
    "...hssssssh...",
    "...hsessesh...",
    "...hssssssh...",
    "....SssssS....",
    ".....SssS.....",
    "..tttttttttt..",
    ".ttutttttTttt.",
    ".sTaaaaaaaaTs.",
    "..tTtttttTtT..",
    "...pppppppp...",
    "...ppPppPpp...",
]
SIDE = [
    "....hhhhhh....",
    "...hhHHhhhh...",
    "...hhhhhhhh...",
    "...hhhssssk...",
    "...hhsssses...",
    "...hhssssssS..",
    "...hhhssssS...",
    ".....hhSsS....",
    "...tttttttt...",
    "...tuttttTt...",
    "...tTaaaaTTs..",
    "...tTtttttT...",
    "...ppppppp....",
    "...ppPppPp....",
]
BACK = [
    "....hhhhhh....",
    "...hhHHhhhh...",
    "...hhhhhhhh...",
    "...hhhhhhhh...",
    "...hhhHhhhh...",
    "...hhhhhhhh...",
    "....hhhhhh....",
    ".....SssS.....",
    "..tttttttttt..",
    ".ttttttttttTt.",
    ".sTaaaaaaaaTs.",
    "..tTtttttTtT..",
    "...pppppppp...",
    "...ppPppPpp...",
]
VIEWS = {"down": FRONT, "side": SIDE, "up": BACK}

# ---- class overlays: (rows, y relative to first head row; '.' = leave). Applied on top of the base ----
OVER = {
    "base": {
        "down": [(["...cccccccc..."], 2)],
        "side": [(["...cccccccc..."], 2)],
        "up": [(["...cccccccc..."], 2)],
    },
    "warrior": {   # blangkon cap, broad pauldrons, kris at hip
        "down": [([".....cccc.....", "...cccccccc...", "...CCCgCCCC..."], -1),
                 ([".mmmttttttmmm."], 8), (["............GG", "............gG"], 11)],
        "side": [([".....cccc.....", "...cccccccc...", "...CCCCCgCC..."], -1),
                 (["..mmmtttt...."], 8), (["..........GG.."], 11)],
        "up": [([".....cccc.....", "...cccccccc...", "...CCCCCCCC..."], -1),
               ([".mmmttttttmmm."], 8), (["....gggggggg.."], 10)],
    },
    "archer": {    # hair bun + iket tail, quiver on the back, leaf-green hood line
        "down": [(["......hh......", ".....hHHh....."], -2), (["...cccccccc..."], 2), (["...........ccc"], 3),
                 (["..qf..........", "..qf..........", "..q..........."], 7)],
        "side": [(["....hhh.......", "...hHHhh......"], -2), (["...cccccccc..."], 2), (["..ccc........."], 3),
                 (["..fq..........", "..fq..........", "..qq.........."], 8)],
        "up": [(["......hh......", ".....hHHh....."], -2), (["...cccccccc..."], 2), (["...........ccc"], 3),
               (["...qqqqqqqq..."], 8), (["...qfqfqfqf..."], 9), (["...qqqqqqqq..."], 10)],
    },
    "rogue": {     # mask-scarf over the lower face, long knotted tail, kujang at the back
        "down": [(["...cccccccc..."], 2), (["...hCCCCCCh..."], 5), (["....CCCCCC...."], 6), (["..........cc.."], 3), (["..........Cc.."], 4)],
        "side": [(["...cccccccc..."], 2), (["...hhCCCCCC.."], 5), (["..cc.........."], 3), (["..Cc.........."], 4)],
        "up": [(["...cccccccc..."], 2), (["..cc.........."], 3), (["..Cc.........."], 4), (["..cc.........."], 5),
               (["....mmmm......", "...mM.........", "..mM.........."], 9)],
    },
    "mage": {      # pearl crown, long hair behind, robe down to the feet
        "down": [(["....g.gg.g....", "....gGwGGg...."], 0), (["..h...hh...h.."], 5), (["..hh......hh.."], 6),
                 (["...tttttttt..."], 12), ([".tttutttttTttt"], 13)],
        "side": [(["....g.gg.g....", "....gGwGGg...."], 0), (["..hh.........."], 4), (["..hhh........."], 5), (["..hhh........."], 6)],
        "up": [(["....g.gg.g....", "....gGwGGg...."], 0), (["...hhhhhhhh..."], 7)],
    },
}

# ---- walk / idle leg poses: list of (left_len, right_len, spread) ----
def legs_img(pal, view, left, right, spread=0, hem=0, cls="base"):
    img = Image.new("RGBA", (IW, 4), (0, 0, 0, 0))
    P = pal
    if cls == "mage":
        # robe skirt; hem sways, feet barely show
        rows = [" ...tttttttt...", "..tttTtttttT...", "..tttTtttttTt..", "..bb......bb.."]
        rows = ["..tttttttttt..", "..ttTttttTtt..", "..tttttttttt..", "...bb....bb..."]
        if view == "side":
            rows = ["...ttttttt....", "...ttTtttTt...", "...tttttttt...", "....bb..bb...."]
        sh = hem
        out = px.sprite(rows, P, (IW, 4))
        return px.shift(out, sh, 0)
    def draw_leg(x, length, shd):
        for y in range(length):
            c = P["P"] if shd else P["p"]
            if 0 <= y < 4:
                img.putpixel((x, y), c) if 0 <= x < IW else None
                img.putpixel((x + 1, y), c) if 0 <= x + 1 < IW else None
        fy = min(3, length - 1) if length > 0 else 0
        for fx in (x - 1, x, x + 1):
            if 0 <= fx < IW and length > 0:
                img.putpixel((fx, fy), P["b"])
    if view == "side":
        draw_leg(4 + spread, left, True)
        draw_leg(7 - spread, right, False)
    else:
        draw_leg(4, left, True)
        draw_leg(8, right, False)
    return img


def overlay(img, rows, y, pal, rel0=Y0):
    for i, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch == "." or ch == " ":
                continue
            yy = rel0 + y + i
            if 0 <= yy < IH and 0 <= x < IW:
                img.putpixel((x, yy), pal[ch])


def body(cls, view, pose=None):
    """Upper body (head+torso+hips) on an IW x IH canvas, feet area empty."""
    pal = palette(cls)
    img = Image.new("RGBA", (IW, IH), (0, 0, 0, 0))
    rows = VIEWS[view]
    # base art (mage keeps its robe over the hips: overlay handles it)
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch != ".":
                img.putpixel((x, Y0 + y), pal[ch])
    for rws, y in OVER[cls][view]:
        overlay(img, rws, y, pal)
    return img, pal


def compose(cls, view, bob=0, lx=0, legs=(4, 4, 0), hem=0, extra=None, upper_mod=None):
    up, pal = body(cls, view)
    if upper_mod:
        up = upper_mod(up)
    can = Image.new("RGBA", (IW, IH), (0, 0, 0, 0))
    leg = legs_img(pal, view, *legs, hem=hem, cls=cls) if True else None
    px._clip_paste(can, leg, 0, Y0 + 14)
    px._clip_paste(can, px.shift(up, lx, bob), 0, 0)
    if extra:
        extra(can, pal)
    return can



# =====================================================================================
# Attack poses (Phase 6c, combat.md 2.3b). Procedural: body offsets + arm vector + weapon vector, authored once
# for the SIDE view (facing right) and projected to the down / up views.
# Frame order for every attack: 0 anticipation, 1 coil, 2 strike, 3 smear-pose, 4 follow-through, 5 settle.
# =====================================================================================
ARCH = {"base": "light", "rogue": "light", "warrior": "heavy", "mage": "staff", "archer": "bow"}
WLEN = {"base": 6, "rogue": 6, "warrior": 8, "mage": 9}      # px of weapon beyond the hand at w_l = 1.0
SMEAR = {"warrior": hexc("FFFFFF", 235), "base": hexc("FFFFFF", 200), "archer": hexc("D4F5A0", 220),
         "rogue": hexc("C7B8FF", 220), "mage": hexc("9EF2FF", 235)}

N, W, L, L3 = (4, 4, 0), (4, 4, -2), (4, 3, -2), (4, 3, -3)


def F(bob, lx, lean, sq, legs, aa, al, wa, wl=1.0):
    return dict(bob=bob, lx=lx, lean=lean, sq=sq, legs=legs, aa=aa, al=al, wa=wa, wl=wl)


# melee tables: [hit][frame]. Angles in degrees, screen space, 0 = forward, 90 = down, -90 = up, 180 = back.
LIGHT = [
    [  # hit 1: forehand, overhead to low-forward
        F(1, -1, -1, .95, N, -100, 3, -70), F(1, -2, -2, .92, W, -150, 3, -135),
        F(0, 1, 1, 1, N, -30, 3, -10), F(0, 2, 2, 1, L, 10, 3, 35),
        F(0, 2, 2, 1, L, 40, 3, 70), F(0, 1, 0, 1, N, 50, 3, 85)],
    [  # hit 2: backhand, low-back to high-forward
        F(1, 0, 0, .95, N, 60, 3, 100), F(1, -1, -2, .92, W, 90, 3, 140),
        F(0, 1, 1, 1, N, 20, 3, 0), F(0, 2, 2, 1, L, -20, 3, -40),
        F(0, 2, 2, 1, L, -50, 3, -80), F(0, 1, 0, 1, N, -20, 3, -45)],
    [  # hit 3: finisher thrust (lunge)
        F(1, -1, -1, .94, W, 140, 3, -15), F(1, -2, -2, .9, W, 180, 3, 0),
        F(0, 2, 1, 1, L, 0, 2, 0), F(0, 3, 2, 1, L3, 0, 3, 0, 1.15),
        F(0, 3, 2, 1, L3, 0, 3, 5, 1.1), F(0, 1, 0, 1, N, 20, 2, 30)],
]
HEAVY = [
    [  # hit 1: forehand, big overhead arc
        F(0, -1, -1, .98, N, -90, 3, -60), F(1, -2, -3, .92, W, -135, 3, -140),
        F(0, 1, 1, 1, N, -40, 3, -20), F(0, 2, 2, 1, L, 10, 3, 30),
        F(0, 2, 2, .96, L, 40, 3, 70), F(0, 1, 0, 1, N, 50, 3, 80)],
    [  # hit 2: backhand sweep
        F(1, 0, 0, .95, N, 70, 3, 110), F(1, -1, -3, .92, W, 100, 3, 155),
        F(0, 1, 1, 1, N, 20, 3, 10), F(0, 2, 2, 1, L, -20, 3, -40),
        F(0, 2, 2, 1, L, -50, 3, -80), F(0, 1, 0, 1, N, -30, 3, -50)],
    [  # hit 3: finisher ground slam
        F(0, 0, 0, 1, N, -100, 3, -90), F(-1, -2, -3, 1.04, W, -125, 3, -115),
        F(1, 1, 2, .96, N, -30, 3, 15), F(1, 2, 3, .88, L, 40, 3, 80),
        F(1, 2, 3, .86, L, 60, 3, 88), F(0, 1, 1, .96, N, 50, 3, 65)],
]
# bow: (bob, lx, lean, sq, legs, draw 0..1, tilt, front-arm angle). raise, draw, hold, release, recoil, settle
def B(bob, lx, lean, sq, legs, draw, tilt, fa):
    return dict(bob=bob, lx=lx, lean=lean, sq=sq, legs=legs, draw=draw, tilt=tilt, fa=fa)


BOW = [
    [B(0, 0, 0, 1, N, 0, 0, -25), B(0, -1, -1, 1, N, .5, 0, -10), B(0, -1, -1, 1, N, 1, 0, -5),
     B(0, 0, 0, 1, N, 0, -1, -8), B(0, -1, -2, 1, N, 0, -2, -35), B(0, 0, 0, 1, N, 0, 0, -20)],
    [B(0, 0, 0, 1, N, 0, 0, -10), B(0, -1, -1, 1, N, .5, 0, 0), B(0, -1, -1, 1, N, 1, 0, 5),
     B(0, 0, 0, 1, N, 0, 1, 2), B(0, -1, -2, 1, N, 0, 2, -15), B(0, 0, 0, 1, N, 0, 0, -10)],
    [B(1, -1, -1, .96, W, 0, 0, -30), B(1, -2, -2, .94, W, .6, 0, -15), B(1, -2, -2, .94, W, 1, 0, -8),
     B(0, 0, 0, 1, W, 0, -2, -10), B(0, -2, -3, 1, W, 0, -3, -45), B(0, 0, -1, 1, N, 0, 0, -20)],
]
SHOULDER = {"side": (8, 12), "down": (11, 12), "up": (11, 12)}
LAT = {0: -0.5, 1: 0.5, 2: -0.1}      # sideways swing factor per hit for the down and up views


def project(view, hit, ang, ln):
    """Side-view polar vector -> screen (dx, dy) in this view."""
    fx, fy = math.cos(math.radians(ang)) * ln, math.sin(math.radians(ang)) * ln
    if view == "side":
        return fx, fy
    k = 0.6 if view == "down" else -0.6
    return fx * LAT[hit], fy + fx * k


def line_pts(x0, y0, x1, y1):
    pts, dx, dy = [], abs(x1 - x0), -abs(y1 - y0)
    sx, sy = (1 if x0 < x1 else -1), (1 if y0 < y1 else -1)
    err = dx + dy
    while True:
        pts.append((x0, y0))
        if x0 == x1 and y0 == y1:
            break
        e2 = 2 * err
        if e2 >= dy:
            err += dy
            x0 += sx
        if e2 <= dx:
            err += dx
            y0 += sy
    return pts


def put_px(can, x, y, c):
    if 0 <= x < can.width and 0 <= y < can.height:
        can.putpixel((x, y), c)


def draw_arm(can, pal, sx, sy, hx, hy):
    for i, (x, y) in enumerate(line_pts(sx, sy, hx, hy)):
        put_px(can, x, y, pal["s"] if (x, y) == (hx, hy) else pal["T"])


def draw_weapon(can, pal, cls, hx, hy, vx, vy, hit):
    """Weapon from the hand along (vx, vy). Handle, guard, blade (+ edge), kujang curve, staff orb."""
    ln = max(1, round(math.hypot(vx, vy)))
    tx, ty = hx + round(vx), hy + round(vy)
    if cls == "mage":
        bx, by = hx - round(vx * 0.25), hy - round(vy * 0.25)    # staff: grip sits near the middle
        pts = line_pts(bx, by, tx, ty)
        for i, (x, y) in enumerate(pts):
            put_px(can, x, y, pal["q"] if i % 3 else pal["f"])
        for ox, oy, ch in ((0, 0, "w"), (1, 0, "f"), (-1, 0, "f"), (0, 1, "f"), (0, -1, "f")):
            put_px(can, tx + ox, ty + oy, pal[ch])
        return
    pts = line_pts(hx, hy, tx, ty)
    n = len(pts)
    mag = math.hypot(vx, vy) or 1.0
    px_, py_ = -vy / mag, vx / mag                              # perpendicular
    for i, (x, y) in enumerate(pts):
        if i < 2 and n > 3:
            put_px(can, x, y, pal["q"])
        elif i == 2 and n > 4 and cls in ("warrior", "base", "rogue"):
            put_px(can, x, y, pal["g"])
            put_px(can, x + round(px_), y + round(py_), pal["g"])
            put_px(can, x - round(px_), y - round(py_), pal["g"])
        else:
            put_px(can, x, y, pal["M"])
            if cls == "warrior" and i > 3:
                put_px(can, x + round(px_), y + round(py_), pal["m"])
            if cls == "rogue" and i >= n - 2:                    # kujang hook
                put_px(can, x + round(px_), y + round(py_), pal["m"])
    put_px(can, tx, ty, pal["w"] if cls != "base" else pal["M"])  # bright tip


def draw_bow(can, pal, fx, fy, draw, tilt, view, back_from):
    """Bow centred on the front hand. draw 0..1 pulls the string back."""
    if view == "side":
        bulge = {-3: 0, -2: 1, -1: 2, 0: 2, 1: 2, 2: 1, 3: 0}
        bx = fx + 1
        for r, b in bulge.items():
            put_px(can, bx + b + round(tilt * r / 3.0), fy + r, pal["q"])
        pull = round(draw * 4)
        mid = (bx - 1 - pull, fy)
        top, bot = (bx + round(tilt * -1), fy - 3), (bx + round(tilt), fy + 3)
        for a, b in ((top, mid), (mid, bot)):
            for x, y in line_pts(a[0], a[1], b[0], b[1]):
                put_px(can, x, y, pal["f"])
        if draw > 0:
            for x in range(mid[0], bx + 4):
                put_px(can, x, fy, pal["m"])
            put_px(can, bx + 4, fy, pal["M"])
            if draw >= .5:
                draw_arm(can, pal, back_from[0], back_from[1], mid[0], mid[1])
    else:
        bx = fx + 1
        for r, b in {-3: 0, -2: 1, -1: 1, 0: 1, 1: 1, 2: 1, 3: 0}.items():
            put_px(can, bx + b, fy + r + round(tilt * 0), pal["q"])
        for r in range(-3, 4):
            put_px(can, bx - 1, fy + r, pal["f"])
        if draw > 0:
            if view == "down":
                put_px(can, bx - 1, fy, pal["M"])
                put_px(can, bx - 1, fy + 1, pal["m"])
            else:
                for r in range(1, 6):
                    put_px(can, bx - 1, fy - r, pal["m"])
                put_px(can, bx - 1, fy - 6, pal["M"])


def attack_frame(cls, hit, view, f):
    arch = ARCH[cls]
    if arch == "bow":
        p = BOW[hit][f]
    elif arch == "staff":
        p = (HEAVY[2] if hit == 2 else LIGHT[hit])[f]
    else:
        p = (HEAVY if arch == "heavy" else LIGHT)[hit][f]
    bob, lx, lean, sq, legs = p["bob"], p["lx"], p["lean"], p["sq"], p["legs"]
    if view != "side":     # forward is toward (down) or away from (up) the camera: lean becomes a vertical nudge
        dy = round(lx / 2.0)
        bob += dy if view == "down" else -dy
        lx, lean = 0, 0
    can = compose(cls, view, bob, lx, legs, hem=lx,
                  upper_mod=(lambda u: px.shear_top(u, lean)) if lean else None)
    pal = palette(cls)
    sx0, sy0 = SHOULDER[view]
    sx = sx0 + lx + round(lean * (1 - 12 / 20.0))
    sy = sy0 + bob
    nh = max(1, round(IH * sq))
    can = px.squash(can, sq, 1.0)
    offx = 3 if view == "side" else 4     # side: body sits a pixel back so the weapon has room in front
    wide = Image.new("RGBA", (AW, IH), (0, 0, 0, 0))
    px._clip_paste(wide, can, offx, 0)
    can = wide
    sx += offx
    sy = IH - nh + round(sy * nh / IH)
    if arch == "bow":
        dx, dy = project(view, hit, p["fa"], 3)
        fxp, fyp = sx + round(dx), sy + round(dy)
        if view != "side":
            fxp, fyp = sx + 1, sy - 1
        draw_arm(can, pal, sx, sy, fxp, fyp)
        draw_bow(can, pal, fxp, fyp, p["draw"], p["tilt"], view, (sx - 1 if view == "side" else sx, sy))
        return can
    dx, dy = project(view, hit, p["aa"], p["al"])
    hx, hy = sx + round(dx), sy + round(dy)
    draw_arm(can, pal, sx, sy, hx, hy)
    vx, vy = project(view, hit, p["wa"], WLEN[cls] * p["wl"])
    draw_weapon(can, pal, cls, hx, hy, vx, vy, hit)
    put_px(can, hx, hy, pal["s"])
    return can


def idle_frame(cls, view, f):
    bob = (0, 0, -1, -1)[f] if cls != "mage" else (0, -1, -1, 0)[f]
    return compose(cls, view, bob, 0, (4, 4, 0), hem=(0, 0, 0, 0)[f])


def walk_frame(cls, view, f):
    bob = (1, 0, 1, 0)[f]
    lens = {0: (4, 3, 1), 1: (4, 4, 0), 2: (3, 4, -1), 3: (4, 4, 0)}[f]
    hem = (1, 0, -1, 0)[f]
    return compose(cls, view, bob, 0, lens, hem=hem)


def ball(can, sq, ang, lift=0):
    """Tuck: squash, rotate about the body centre, rest on the floor."""
    s = px.squash(can, sq, 0.9)
    bb = s.getbbox()
    s = s.crop(bb)
    r = s.rotate(ang, expand=True)
    out = Image.new("RGBA", (IW, IH), (0, 0, 0, 0))
    px._clip_paste(out, r, (IW - r.width) // 2, IH - r.height - lift)
    return out


def dodge_frame(cls, f):
    """6 frames: crouch, launch, tuck, roll, land, rise."""
    can = compose(cls, "side", 0, 0, (4, 4, 0))
    streak = hexc("FFFFFF", 150)
    if f == 0:
        r = px.squash(compose(cls, "side", 1, -1, (4, 4, -2), upper_mod=lambda u: px.shear_top(u, -2)), 0.78, 1.0)
    elif f == 1:
        r = px.shift(px.squash(can, 0.7, 1.0), 1, -2)
        r = px.shear_top(r, 3)
        r.putpixel((0, IH - 7), streak)
        r.putpixel((1, IH - 5), hexc("FFFFFF", 100))
    elif f == 2:
        r = ball(can, 0.62, -50, 2)
        r.putpixel((0, IH - 8), streak)
        r.putpixel((0, IH - 5), hexc("FFFFFF", 100))
    elif f == 3:
        r = ball(can, 0.6, -170, 1)
        r.putpixel((0, IH - 9), streak)
        r.putpixel((1, IH - 6), hexc("FFFFFF", 100))
    elif f == 4:
        r = px.squash(compose(cls, "side", 1, 1, (4, 4, -2), upper_mod=lambda u: px.shear_top(u, 2)), 0.8, 1.05)
    else:
        r = px.squash(can, 0.93, 1.0)
    return r


def hurt_frame(cls, f):
    can = compose(cls, "side", 0, -1 if f == 0 else 0, (4, 4, 0), hem=-1, upper_mod=lambda u: px.shear_top(u, -2 if f == 0 else -1))
    if f == 0:
        can = px.tint(can, (255, 255, 255, 255), 0.6)
    return can


def death_frame(cls, f):
    can = compose(cls, "side", 0, 0, (4, 4, 0))
    if f == 0:
        return px.squash(px.tint(can, (255, 255, 255, 255), 0.35), 0.86, 1.0)
    if f == 1:
        return px.shift(px.shear_top(px.squash(can, 0.7, 1.0), -3), -1, 0)
    rot = can.rotate(-90, expand=True)           # lies on its back
    rot = rot.crop(rot.getbbox())
    out = Image.new("RGBA", (IW, IH), (0, 0, 0, 0))
    px._clip_paste(out, rot, (IW - rot.width) // 2, IH - rot.height)
    if f == 3:
        out = px.tint(out, (60, 50, 80, 255), 0.35)
    return out


def finish(can):
    """Outline then fit into a 16x24 cell, feet 1 px above the bottom edge (Shadow node draws ground shadow)."""
    o = px.outline(can)
    cell = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
    px._clip_paste(cell, o, (CW - o.width) // 2, CH - o.height - 1)
    return cell


def build(cls):
    sh = Image.new("RGBA", (COLS * CW, ROWS * CH), (0, 0, 0, 0))

    def put(c, r, im):
        sh.alpha_composite(finish(im), (c * CW, r * CH))
    for vi, view in enumerate(("down", "side", "up")):
        for f in range(4):
            put(f, vi, idle_frame(cls, view, f))
            put(f, 3 + vi, walk_frame(cls, view, f))
        for hit in range(3):
            row = {"side": 6, "down": 12, "up": 15}[view] + hit
            for f in range(6):
                put(f, row, attack_frame(cls, hit, view, f))
    for f in range(6):
        put(f, 9, dodge_frame(cls, f))
    for f in range(4):
        put(f, 10, hurt_frame(cls, f % 2))
        put(f, 11, death_frame(cls, f))
    return sh


def main():
    sheets = []
    for cls in ["base", "warrior", "archer", "rogue", "mage"]:
        s = build(cls)
        path = os.path.join(px.ART, f"hero_{cls}.png")
        s.save(path)
        sheets.append((cls, s))
        print("wrote", path)
    sh = Image.new("RGBA", (16, 8), (0, 0, 0, 0))
    for dy in range(1, 6):
        for dx in range(1, 15):
            nx, ny = (dx - 7.5) / 6.5, (dy - 3.0) / 2.0
            if nx * nx + ny * ny <= 1.0:
                sh.putpixel((dx, dy), (24, 18, 43, 110))
    sh.save(os.path.join(px.ART, "hero_shadow.png"))
    # preview: all five sheets side by side, 3x
    prev = Image.new("RGBA", (5 * (COLS * CW + 8) + 4, ROWS * CH + 8), (70, 96, 70, 255))
    for i, (cls, s) in enumerate(sheets):
        prev.alpha_composite(s, (4 + i * (COLS * CW + 8), 4))
    prev = prev.resize((prev.width * 3, prev.height * 3), Image.NEAREST)
    prev.save(os.path.join(os.path.dirname(os.path.abspath(__file__)), "hero_preview.png"))


if __name__ == "__main__":
    main()
