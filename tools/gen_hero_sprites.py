#!/usr/bin/env python3
"""Budayago hero sprite sheets (v2). 16x24 cells, 4 cols x 12 rows (contract used by player.gd):
 rows 0-2 idle (down, side, up) | 3-5 walk (down, side, up) | 6-8 attack combo 1-3 (side pose, game flips)
 rows 9 dodge | 10 hurt | 11 death.
Art is authored as layered ASCII (head/torso, class overlays, legs) then auto-outlined by pixlib.
Run: python3 tools/gen_hero_sprites.py
Outputs: assets/art/hero_{base,warrior,archer,rogue,mage}.png, hero_shadow.png, and a preview in tools/hero_preview.png
"""
import os
from PIL import Image
import pixlib as px
from pixlib import hexc

CW, CH = 16, 24
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


# ---- weapons (drawn in the attack frames) ----
WEAPONS = {
    "base": {"raise": ["..q", ".qq", ".q."], "fwd": ["qqq"], "low": ["q.", "qq"]},
    "warrior": {"raise": ["..M", ".Mm", ".gm", "gg."], "fwd": ["gmMMM"], "low": ["g.", "gm", ".mM"]},
    "archer": {"raise": [".q.", "q.f", ".q."], "fwd": ["..q", ".qf", "q.f", ".qf", "..q"], "low": ["q.", ".q"]},
    "rogue": {"raise": ["..M", ".Mm", "mm."], "fwd": ["mMMm."], "low": ["m.", "mM", ".M"]},
    "mage": {"raise": [".w", "wf", ".q", ".q"], "fwd": ["qqfw"], "low": ["q.", "qf", ".w"]},
}
SMEAR = {"warrior": hexc("FFFFFF", 235), "base": hexc("FFFFFF", 200), "archer": hexc("D4F5A0", 220),
         "rogue": hexc("C7B8FF", 220), "mage": hexc("9EF2FF", 235)}


def stamp(can, rows, x, y, pal):
    for dy, row in enumerate(rows):
        for dx, ch in enumerate(row):
            if ch != "." and 0 <= x + dx < IW and 0 <= y + dy < IH:
                can.putpixel((x + dx, y + dy), pal[ch])


def attack_frame(cls, combo, f):
    # f: 0 windup, 1 strike, 2 impact, 3 recovery
    bob = {0: 1, 1: 0, 2: 1, 3: 0}[f]
    lx = {0: -1, 1: 1, 2: 2, 3: 1}[f]
    legs = {0: (4, 4, 1), 1: (4, 3, -1), 2: (4, 3, -2), 3: (4, 4, 0)}[f]
    w = WEAPONS[cls]

    def extra(can, pal):
        hx, hy = 10 + lx, Y0 + 10 + bob
        if f == 0:
            stamp(can, w["raise"], hx - 1, hy - 4 - combo, pal)
        elif f in (1, 2):
            dy = (0, -2, 1)[combo]
            stamp(can, w["fwd"], hx, hy + dy - (2 if combo == 1 else 0), pal)
            if f == 1:  # smear arc
                col = SMEAR[cls]
                for i in range(3 + combo):
                    xx, yy = min(IW - 1, 11 + i), hy - 3 + i + (1 if combo == 2 else 0) - (2 if combo == 1 else 0) + dy
                    if 0 <= yy < IH:
                        can.putpixel((xx, yy), col)
            else:
                for (xx, yy) in ((IW - 1, hy - 1), (IW - 2, hy + 2)):
                    can.putpixel((xx, yy), pal["G"])
        else:
            stamp(can, w["low"], hx, hy + 1, pal)
    return compose(cls, "side", bob, lx, legs, hem=lx, extra=extra)


def idle_frame(cls, view, f):
    bob = (0, 0, -1, -1)[f] if cls != "mage" else (0, -1, -1, 0)[f]
    return compose(cls, view, bob, 0, (4, 4, 0), hem=(0, 0, 0, 0)[f])


def walk_frame(cls, view, f):
    bob = (1, 0, 1, 0)[f]
    lens = {0: (4, 3, 1), 1: (4, 4, 0), 2: (3, 4, -1), 3: (4, 4, 0)}[f]
    hem = (1, 0, -1, 0)[f]
    return compose(cls, view, bob, 0, lens, hem=hem)


def dodge_frame(cls, f):
    can = compose(cls, "side", 0, 0, (4, 4, 0))
    if f == 0:
        r = px.squash(can, 0.8, 1.0)
    elif f in (1, 2):
        r = px.shift(px.squash(can, 0.52, 1.08), 1 + f, -3)
        r = px.shear_top(r, 1 if f == 1 else 2)
        # speed streaks
        r.putpixel((0, IH - 6), hexc("FFFFFF", 160))
        r.putpixel((1, IH - 5), hexc("FFFFFF", 110))
    else:
        r = px.squash(can, 0.86, 1.0)
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
    sh = Image.new("RGBA", (4 * CW, 12 * CH), (0, 0, 0, 0))
    def put(c, r, im):
        sh.alpha_composite(finish(im), (c * CW, r * CH))
    for vi, view in enumerate(("down", "side", "up")):
        for f in range(4):
            put(f, vi, idle_frame(cls, view, f))
            put(f, 3 + vi, walk_frame(cls, view, f))
    for combo in range(3):
        for f in range(4):
            put(f, 6 + combo, attack_frame(cls, combo, f))
    for f in range(4):
        put(f, 9, dodge_frame(cls, f))
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
    # preview: first 3 rows idle/walk/attack for all classes, 6x
    prev = Image.new("RGBA", (5 * 4 * CW + 40, 12 * CH + 8), (70, 96, 70, 255))
    for i, (cls, s) in enumerate(sheets):
        prev.alpha_composite(s, (4 + i * (4 * CW + 8), 4))
    prev = prev.resize((prev.width * 3, prev.height * 3), Image.NEAREST)
    prev.save(os.path.join(os.path.dirname(os.path.abspath(__file__)), "hero_preview.png"))


if __name__ == "__main__":
    main()
