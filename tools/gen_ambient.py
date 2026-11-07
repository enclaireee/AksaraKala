#!/usr/bin/env python3
"""Generate town-life art (assets/art/ambient/) for Budayago. Stdlib only (no PIL).

Writes:
  villager_00..NN.png   16x24 cells, 4 cols x 8 rows: rows 0-3 walk down/up/left/right (4 frames),
                        rows 4-7 idle down/up/left/right (2 frames, cols 0-1)
  animal_<name>.png     8 cols x N palette rows: idle0 idle1 walk0-3 extra0 extra1
  smoke.png pot.png fire.png butterfly.png laundry_cloth.png mats.png
  fences.png            16 autotile masks (N=1 E=2 S=4 W=8) x 3 kinds (bamboo, bilik, stone), 16x16
  crops.png             16x32 cells: cassava, chili, rice, banana x 2 variants
  goods.png             16x16 cells: stall tables with fruit, batik, pottery, fish, spice x 2
  entities/ambient/ambient_defs.gd (variant table and cell sizes) and tools/ambient_preview.png
"""
import os
import struct
import zlib
import math
import random

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "art", "ambient")


# ------------------------------------------------------------------ image toolkit
def hexc(s, a=255):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), a)


def shade(c, f):
    r, g, b, a = c
    if f <= 1:
        return (int(r * f), int(g * f), int(b * f), a)
    t = f - 1
    return (int(r + (255 - r) * t), int(g + (255 - g) * t), int(b + (255 - b) * t), a)


class Img:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.p = [(0, 0, 0, 0)] * (w * h)

    def get(self, x, y):
        if 0 <= x < self.w and 0 <= y < self.h:
            return self.p[y * self.w + x]
        return (0, 0, 0, 0)

    def set(self, x, y, c):
        x, y = int(x), int(y)
        if c is None or not (0 <= x < self.w and 0 <= y < self.h):
            return
        if c[3] < 255:
            d = self.p[y * self.w + x]
            if d[3] == 0:
                self.p[y * self.w + x] = c
            else:
                t = c[3] / 255.0
                self.p[y * self.w + x] = (int(c[0] * t + d[0] * (1 - t)), int(c[1] * t + d[1] * (1 - t)),
                                          int(c[2] * t + d[2] * (1 - t)), 255)
        else:
            self.p[y * self.w + x] = c

    def rect(self, x, y, w, h, c):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                self.set(xx, yy, c)

    def hline(self, x0, x1, y, c):
        for x in range(x0, x1 + 1):
            self.set(x, y, c)

    def vline(self, x, y0, y1, c):
        for y in range(y0, y1 + 1):
            self.set(x, y, c)

    def blit(self, src, ox, oy):
        for y in range(src.h):
            for x in range(src.w):
                c = src.p[y * src.w + x]
                if c[3]:
                    self.set(ox + x, oy + y, c)

    def flip(self):
        o = Img(self.w, self.h)
        for y in range(self.h):
            for x in range(self.w):
                o.p[y * self.w + x] = self.p[y * self.w + (self.w - 1 - x)]
        return o

    def outline(self, k=0.36):
        o = Img(self.w, self.h)
        o.p = list(self.p)
        for y in range(self.h):
            for x in range(self.w):
                if self.p[y * self.w + x][3]:
                    continue
                best = None
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    c = self.get(x + dx, y + dy)
                    if c[3] == 255 and (best is None or sum(c[:3]) < sum(best[:3])):
                        best = c
                if best:
                    o.p[y * self.w + x] = (int(best[0] * k), int(best[1] * k), min(255, int(best[2] * k * 1.15)), 255)
        return o

    def crop(self, x, y, w, h):
        o = Img(w, h)
        for yy in range(h):
            for xx in range(w):
                o.p[yy * w + xx] = self.get(x + xx, y + yy)
        return o


def ell(im, cx, cy, rx, ry, c, shaded=True):
    for y in range(int(cy - ry - 1), int(cy + ry + 2)):
        for x in range(int(cx - rx - 1), int(cx + rx + 2)):
            dx = (x + 0.5 - cx) / rx
            dy = (y + 0.5 - cy) / ry
            if dx * dx + dy * dy <= 1.0:
                col = c
                if shaded:
                    if dy < -0.45:
                        col = shade(c, 1.22)
                    elif dy > 0.4:
                        col = shade(c, 0.74)
                im.set(x, y, col)


def write_png(path, im):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    raw = bytearray()
    for y in range(im.h):
        raw.append(0)
        for x in range(im.w):
            raw.extend(im.p[y * im.w + x])

    def chunk(t, d):
        c = struct.pack(">I", len(d)) + t + d
        return c + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff)
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", im.w, im.h, 8, 6, 0, 0, 0)) \
        + chunk(b"IDAT", zlib.compress(bytes(raw), 9)) + chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(png)


def sheet(cw, ch, cols, rows):
    return Img(cw * cols, ch * rows)


def put(sh, col, row, frame, cw, ch):
    sh.blit(frame, col * cw, row * ch)


# ------------------------------------------------------------------ villagers
SKIN = [hexc("F2C9A0"), hexc("E3A66E"), hexc("C98B58"), hexc("A8693F")]
HAIR = {"black": hexc("2A1D26"), "brown": hexc("4F3324"), "white": hexc("ECE8DC"), "grey": hexc("A9A8AE")}
EYE = hexc("18122B")
C = {k: hexc(v) for k, v in dict(
    maroon="B84A62", teal="2A9D8F", cream="F4E9D0", blue="4A78A8", orange="E08A3A", green="6A994E", pink="E58FA8",
    brown="8A5A35", indigo="2D4E73", white="F4F1DE", black="2A2838", red="C23B2E", yellow="E8C040", grey="8C8C98",
    sogan="A0662E", straw="D9B15C", dgreen="386641", purple="7B4F8C").items()}

# name, body, skin, hair, top, bottom, head, item, regions
# top: (kind, color) kind in kebaya shirt surjan bare dress ; bottom: (kind, c1, c2, pattern) kind in kain sarong pants shorts
V = [
    ("man", 1, "black", ("shirt", "white"), ("pants", "black"), ("iket", "indigo", "white"), "none", "sunda timur galuh"),
    ("woman", 0, "black", ("kebaya", "teal"), ("kain", "sogan", "brown", "batik"), ("bun", "pink"), "basket", "sunda mataram galuh"),
    ("elder", 1, "white", ("shirt", "grey"), ("sarong", "indigo", "white", "check"), ("iket", "brown", "sogan"), "cane", "sunda mataram galuh kidul timur"),
    ("woman", 2, "black", ("kebaya", "cream"), ("sarong", "maroon", "yellow", "check"), ("scarf", "maroon"), "jar_hip", "sunda mataram galuh kidul timur"),
    ("man", 2, "black", ("shirt", "straw"), ("pants", "black"), ("caping",), "rice", "sunda mataram galuh timur"),
    ("woman", 1, "black", ("kebaya", "orange"), ("kain", "indigo", "white", "batik"), ("bun", "yellow"), "baby", "sunda mataram galuh"),
    ("man", 0, "black", ("surjan", "blue"), ("kain", "sogan", "brown", "batik"), ("blangkon", "sogan", "brown"), "none", "mataram galuh"),
    ("woman", 1, "black", ("kebaya", "green"), ("kain", "sogan", "brown", "batik"), ("bun", "white"), "jar_head", "sunda mataram galuh"),
    ("man", 3, "black", ("shirt", "dgreen"), ("pants", "black"), ("caping",), "pole", "sunda mataram galuh timur"),
    ("man", 2, "black", ("bare", "none"), ("shorts", "blue"), ("none",), "net", "kidul"),
    ("woman", 2, "black", ("kebaya", "blue"), ("sarong", "teal", "cream", "check"), ("scarf", "teal"), "basket", "kidul timur"),
    ("elder", 0, "white", ("kebaya", "brown"), ("kain", "indigo", "white", "batik"), ("bun", "white"), "cane", "sunda mataram galuh kidul timur"),
    ("child", 1, "black", ("shirt", "orange"), ("shorts", "indigo"), ("none",), "none", "sunda mataram galuh kidul timur"),
    ("child", 0, "black", ("dress", "pink"), ("kain", "pink", "white", "plain"), ("pigtail",), "none", "sunda mataram galuh kidul timur"),
    ("man", 1, "black", ("shirt", "white"), ("kain", "sogan", "brown", "batik"), ("blangkon", "brown", "sogan"), "pole", "mataram galuh"),
    ("woman", 0, "black", ("kebaya", "pink"), ("kain", "sogan", "brown", "batik"), ("bun", "pink"), "rice", "sunda mataram galuh"),
    ("man", 2, "black", ("shirt", "green"), ("sarong", "red", "black", "check"), ("iket", "red", "yellow"), "none", "timur kidul"),
    ("woman", 2, "black", ("kebaya", "maroon"), ("kain", "sogan", "brown", "batik"), ("scarf", "orange"), "jar_head", "timur kidul"),
    ("elder", 1, "grey", ("shirt", "blue"), ("sarong", "sogan", "brown", "check"), ("blangkon", "sogan", "brown"), "none", "mataram galuh"),
    ("man", 3, "black", ("bare", "none"), ("shorts", "indigo"), ("none",), "pole", "kidul"),
    ("woman", 3, "black", ("kebaya", "cream"), ("sarong", "blue", "white", "check"), ("scarf", "yellow"), "baby", "kidul timur"),
    ("child", 3, "black", ("bare", "none"), ("shorts", "blue"), ("none",), "none", "sunda kidul timur"),
    ("child", 1, "black", ("dress", "yellow"), ("kain", "yellow", "white", "plain"), ("scarf", "red"), "none", "timur mataram galuh"),
    ("man", 1, "brown", ("shirt", "cream"), ("pants", "black"), ("caping",), "none", "sunda mataram galuh timur"),
    ("woman", 0, "black", ("kebaya", "blue"), ("kain", "indigo", "white", "batik"), ("bun", "white"), "none", "sunda mataram galuh"),
    ("man", 2, "black", ("shirt", "green"), ("pants", "black"), ("iket", "green", "yellow"), "rice", "sunda"),
    ("elder", 2, "grey", ("kebaya", "maroon"), ("sarong", "indigo", "white", "check"), ("scarf", "cream"), "basket", "sunda kidul timur"),
    ("man", 1, "black", ("jacket", "black"), ("kain", "indigo", "white", "batik"), ("blangkon", "brown", "sogan"), "none", "mataram galuh"),
    ("man", 3, "brown", ("bare", "none"), ("shorts", "sogan"), ("iket", "indigo", "white"), "net", "kidul"),
    ("child", 0, "black", ("dress", "teal"), ("kain", "teal", "white", "plain"), ("bun2",), "none", "sunda mataram galuh"),
]


def cloth(pattern, c1, c2, x, y):
    if pattern == "batik":
        if (x % 4 == 1 and y % 4 == 1) or (x % 4 == 3 and y % 4 == 3):
            return c2
        if (x + y) % 4 == 0:
            return shade(c1, 0.82)
        return c1
    if pattern == "check":
        return c2 if ((x // 2 + y // 2) % 2 == 0) else c1
    return c1


def head_rows(d):
    return {
        "down": [".hhhh.", "hhhhhh", "hssssh", "sesses", ".ssss.", "..SS.."],
        "up": [".hhhh.", "hhhhhh", "hhhhhh", "hhhhhh", ".hhhh.", "..SS.."],
        "left": [".hhhh.", "hhhhhh", "sssshh", "sesshh", ".sssh.", "..SS.."],
    }[d]


def draw_head(im, hx, hy, d, skin, hair):
    for j, row in enumerate(head_rows(d)):
        for i, ch in enumerate(row):
            if ch == ".":
                continue
            col = {"h": hair, "s": skin, "S": shade(skin, 0.78), "e": EYE}[ch]
            if ch == "s" and j == 4:
                col = shade(skin, 0.92)
            im.set(hx + i, hy + j, col)


def draw_gear(im, hx, hy, d, g, hair, skin):
    kind = g[0]
    if kind == "iket":
        c, c2 = C[g[1]], C[g[2]] if len(g) > 2 else C["white"]
        for i in range(1, 5):
            im.set(hx + i, hy, c)
        for i in range(0, 6):
            im.set(hx + i, hy + 1, c if i % 2 == 0 or d == "up" else c2)
        kx = hx + 4 if d == "left" else hx + 2
        im.set(kx, hy - 1, c)
        im.set(kx + 1, hy - 1, shade(c, 0.8))
        im.set(kx + 1 if d != "left" else kx, hy - 2, shade(c, 0.8))
    elif kind == "blangkon":
        c, c2 = C[g[1]], C[g[2]]
        for i in range(1, 5):
            im.set(hx + i, hy, c)
        for i in range(0, 6):
            im.set(hx + i, hy + 1, c if i % 3 else c2)
        if d == "up":
            im.rect(hx + 1, hy + 2, 4, 2, c)
            im.set(hx + 2, hy + 3, c2)
            im.set(hx + 3, hy + 3, c2)
        elif d == "left":
            im.rect(hx + 4, hy + 2, 2, 2, c)
            im.set(hx + 6, hy + 2, shade(c, 0.8))
            im.set(hx + 6, hy + 3, shade(c, 0.8))
        else:
            im.set(hx + 3, hy - 1, c2)
    elif kind == "caping":
        s, sd, sh = hexc("DDB660"), hexc("B98F3E"), hexc("F0D58A")
        im.hline(hx + 1, hx + 4, hy - 2, sh)
        im.hline(hx - 1, hx + 6, hy - 1, s)
        im.hline(hx - 2, hx + 7, hy, s)
        im.hline(hx - 3, hx + 8, hy + 1, sd)
        for x in range(hx - 3, hx + 9, 2):
            im.set(x, hy, sd)
        im.set(hx + 1, hy - 1, sh)
        for x in range(hx, hx + 6):  # brim shadow on the forehead
            if d != "up":
                c = im.get(x, hy + 2)
                if c[3]:
                    im.set(x, hy + 2, shade(c, 0.72))
    elif kind == "scarf":
        c = C[g[1]]
        cs = shade(c, 0.8)
        if d == "down":
            im.hline(hx + 1, hx + 4, hy, c)
            im.hline(hx, hx + 5, hy + 1, c)
            for j in (2, 3, 4):
                im.set(hx, hy + j, c)
                im.set(hx + 5, hy + j, cs)
            im.hline(hx, hx + 5, hy + 5, cs)
            im.set(hx + 1, hy + 2, c)
            im.set(hx + 4, hy + 2, cs)
        elif d == "up":
            for j in range(6):
                im.hline(hx + (1 if j in (0, 4) else 0), hx + (4 if j in (0, 4) else 5), hy + j, c if j < 4 else cs)
            im.hline(hx, hx + 5, hy + 5, cs)
        else:
            im.hline(hx + 1, hx + 4, hy, c)
            im.hline(hx, hx + 5, hy + 1, c)
            for j in (2, 3, 4):
                im.hline(hx + 3, hx + 5, hy + j, c if j < 4 else cs)
            im.hline(hx + 2, hx + 5, hy + 5, cs)
            im.set(hx + 2, hy + 2, c)
    elif kind == "bun":
        a = C[g[1]] if len(g) > 1 else None
        if d == "left":
            im.rect(hx + 5, hy + 1, 2, 3, hair)
            im.set(hx + 6, hy + 1, shade(hair, 1.3))
            if a:
                im.set(hx + 4, hy, a)
        else:
            im.hline(hx + 2, hx + 3, hy - 2, hair)
            im.hline(hx + 1, hx + 4, hy - 1, hair)
            if d == "up":
                im.rect(hx + 1, hy + 1, 4, 3, hair)
            if a:
                im.set(hx + 4, hy - 1, a)
                im.set(hx + 1, hy, a)
    elif kind == "bun2":
        im.rect(hx - 1 if d != "left" else hx + 4, hy - 1, 2, 2, hair)
        im.rect(hx + 5 if d != "left" else hx + 5, hy - 1, 2, 2, hair)
    elif kind == "pigtail":
        if d == "left":
            im.rect(hx + 5, hy + 2, 1, 4, hair)
            im.set(hx + 5, hy + 5, hexc("E58FA8"))
        else:
            for sx in (hx - 1, hx + 6):
                im.rect(sx, hy + 2, 1, 4, hair)
                im.set(sx, hy + 5, hexc("E58FA8"))


BODY = {  # hy, ty, torso rows, lower start
    "man": (5, 11, 5, 15), "woman": (5, 11, 5, 15), "elder": (6, 12, 4, 15), "child": (12, 18, 2, 20),
}


def person(v, d, f, idle=False):
    name, body, skinidx, hairn, top, bottom, gear, item, _ = (v[0], v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7])
    skin, hair = SKIN[skinidx], HAIR[hairn]
    side = d in ("left", "right")
    dd = "left" if side else d
    hy, ty, nt, lo = BODY[body]
    child = body == "child"
    x0, x1 = (6, 9) if child else (5, 10)
    im = Img(16, 24)
    if idle:
        dy = 1 if f == 1 else 0
        step = 0
    else:
        dy = -1 if f in (1, 3) else 0
        step = f  # 0 neutral, 1 left fwd, 2 neutral, 3 right fwd
    hx = 5
    # ----- items drawn before body (back)
    if item == "rice" and side:
        draw_item(im, item, dd, hy + dy, ty + dy, step, "back", skin)
    if item == "net" and side:
        draw_item(im, item, dd, hy + dy, ty + dy, step, "back", skin)
    # ----- lower garment
    bk, c1 = bottom[0], C[bottom[1]]
    c2 = C[bottom[2]] if len(bottom) > 2 else c1
    pat = bottom[3] if len(bottom) > 3 else "plain"
    top_y = lo - 1
    feet = skin if bk in ("shorts", "pants") and False else shade(skin, 0.85)
    if bk in ("kain", "sarong"):
        for y in range(top_y, 22):
            flare = 1 if (body == "woman" and y >= 18 and bk == "kain") or (child and y >= 21) else 0
            if bk == "sarong" and y >= 19:
                flare = 1
            xa, xb = x0 - flare, x1 + flare
            if child:
                xa, xb = 5 - flare, 10 + flare if y > 20 else 9
            for x in range(xa, xb + 1):
                col = cloth(pat, c1, c2, x, y)
                if y == top_y + 1 and bk == "kain" and not child:
                    col = shade(c1, 0.7)  # stagen belt
                if x == xb:
                    col = shade(col, 0.82)
                im.set(x, y, col)
        # hem line
        for x in range(5 if not child else 5, 11):
            c = im.get(x, 21)
            if c[3] and not child:
                im.set(x, 21, shade(c, 0.75))
        fl = 0
        if side:
            feet_pos = {0: [(6, 22), (8, 22)], 1: [(4, 22), (9, 22)], 2: [(6, 22), (8, 22)], 3: [(9, 22), (4, 22)]}[step if not idle else 0]
            if step in (1, 3) and not idle:
                im.set(feet_pos[0][0] + 1, 21, shade(c1, 0.7))
        else:
            feet_pos = {0: [(6, 22), (9, 22)], 1: [(6, 22)], 2: [(6, 22), (9, 22)], 3: [(9, 22)]}[step if not idle else 0]
        for fx, fy in feet_pos:
            im.set(fx, fy, feet)
            im.set(fx + 1, fy, feet) if side else None
    else:  # pants / shorts
        for y in range(top_y, lo + 3 if not child else lo + 1):
            for x in range(x0, x1 + 1):
                im.set(x, y, shade(c1, 0.9) if x >= x1 - 1 else c1)
        ls = lo + 3 if not child else lo + 1
        for y in range(ls, 22):
            if side:
                pass
        legcol = skin if bk == "shorts" else c1
        if side:
            pos = {0: (6, 8), 1: (4, 9), 2: (6, 8), 3: (9, 5)}[step if not idle else 0]
            for k, lx in enumerate(pos):
                end = 21
                if not idle and ((step == 1 and k == 1) or (step == 3 and k == 0)):
                    end = 20
                for y in range(ls if bk != "shorts" else ls + 1, end + 1):
                    im.rect(lx, y, 2, 1, shade(legcol, 0.85) if k == 1 else legcol)
                im.rect(lx, end + 1, 2, 1, hexc("3A2A22"))
        else:
            for k, lx in enumerate((x0, x0 + 3 if not child else x0 + 2)):
                end = 21
                if not idle and ((step == 1 and k == 0) or (step == 3 and k == 1)):
                    end = 20
                lw = 3 if not child else 2
                for y in range(ls if bk != "shorts" else ls + 1, end + 1):
                    im.rect(lx, y, lw, 1, legcol if k == 0 else shade(legcol, 0.88))
                im.rect(lx, end + 1, lw, 1, hexc("3A2A22"))
    # ----- torso
    tk, tc = top
    tcol = C[tc] if tc in C else skin
    ttop = ty + dy
    if tk == "bare":
        tcol = skin
    arm_l, arm_r = x0 - 1, x1 + 1
    nrows = nt
    sleeve = {"kebaya": nt, "shirt": 2, "surjan": nt, "bare": 0, "dress": 1, "jacket": nt}[tk]
    sw = (0, 0)
    if not idle:
        sw = {0: (0, 0), 1: (1, -1), 2: (0, 0), 3: (-1, 1)}[step]
    for y in range(ttop, ttop + nrows):
        for x in range(x0, x1 + 1):
            col = tcol
            if tk == "surjan" and (x % 2 == 0):
                col = shade(tcol, 0.8)
            if x >= x1 - 0 and not side:
                col = shade(col, 0.85)
            if side and x >= x1 - 1:
                col = shade(col, 0.8)
            if tk == "jacket" and x in (7, 8) and d == "down":
                col = C["white"]
            im.set(x, y, col)
        if y == ttop + nrows - 1 and tk in ("kebaya", "shirt", "surjan", "jacket"):
            for x in range(x0, x1 + 1):
                im.set(x, y, shade(im.get(x, y), 0.82))
    if d == "down" and tk != "bare":
        im.set(7, ttop, skin)
        im.set(8, ttop, skin)
        if tk == "kebaya":
            im.set(7, ttop + 1, skin)
            tr = shade(tcol, 1.45)
            im.set(8, ttop + 1, tr)
            for k in range(2, nrows):
                im.set(7 + (k % 2), ttop + k, tr)
        elif tk in ("shirt", "surjan"):
            im.set(8, ttop + 1, shade(tcol, 0.7))
            im.set(6, ttop, shade(tcol, 1.3))
            im.set(9, ttop, shade(tcol, 1.3))
    elif d == "down" and tk == "bare":
        im.set(7, ttop + 2, shade(skin, 0.8))
        im.set(8, ttop + 2, shade(skin, 0.8))
    elif d == "up" and tk == "dress":
        pass
    # belt for shirts over pants
    if tk in ("shirt", "bare", "jacket", "surjan") and bk in ("pants", "shorts"):
        for x in range(x0, x1 + 1):
            im.set(x, ttop + nrows, hexc("5A3A2A"))
    # arms
    if not side:
        for k, ax in enumerate((arm_l, arm_r)):
            off = sw[k]
            y0 = ttop + 1 + max(0, off)
            y1 = ttop + nrows - 1 + (1 if off > 0 else 0) - (1 if off < 0 else 0)
            for y in range(y0, y1 + 1):
                col = tcol if (y - ttop) <= sleeve else skin
                if tk == "bare":
                    col = skin
                im.set(ax, y, col if k == 0 else shade(col, 0.85))
            im.set(ax, y1 + 1, skin if k == 0 else shade(skin, 0.85))
    else:
        offx = {0: 0, 1: -1, 2: 0, 3: 1}[step] if not idle else 0
        ax = 7 + offx
        for y in range(ttop + 1, ttop + nrows):
            col = tcol if (y - ttop) <= sleeve else skin
            im.rect(ax, y, 2, 1, shade(col, 0.92) if tk != "bare" else skin)
        im.rect(ax, ttop + nrows, 2, 1, skin)
    # ----- head
    draw_head(im, hx, hy + dy, dd, skin, hair)
    if body == "elder" and dd == "down":
        im.set(7, hy + dy + 5, HAIR["white"])
        im.set(8, hy + dy + 5, HAIR["white"])
    if child:
        pass
    draw_gear(im, hx, hy + dy, dd, gear, hair, skin)
    # ----- items (front)
    if item == "rice" and side:
        pass
    elif item != "none":
        draw_item(im, item, dd, hy + dy, ty + dy, step, "front", skin)
    out = im.outline()
    if d == "right":
        out = out.flip()
    return out


def draw_item(im, item, d, hy, ty, step, layer, skin):
    wobble = 1 if step in (1, 3) else 0
    sway = {0: 0, 1: 1, 2: 0, 3: -1}[step]
    if item == "rice":
        gold, gd, band = hexc("E8C458"), hexc("B8902A"), hexc("7A5A2A")
        if d == "left":  # behind the back
            if layer != "back":
                return
            for k in range(8):
                im.set(10 + (k // 3), ty + 5 - k, gold if k % 2 else gd)
                im.set(11 + (k // 3), ty + 5 - k, gd)
            im.rect(11, ty + 1, 2, 1, band)
            im.rect(12, ty - 3, 2, 2, gold)
        elif d == "up":
            im.rect(6, ty - 2, 5, 7, gold)
            im.rect(9, ty - 2, 2, 7, gd)
            im.hline(6, 10, ty + 1, band)
            for x in range(5, 12, 2):
                im.set(x, ty - 3, gold)
        else:
            im.rect(11, ty - 3, 3, 8, gold)
            im.rect(13, ty - 3, 1, 8, gd)
            im.hline(11, 13, ty + 1, band)
            im.set(11, ty - 4, gold)
            im.set(13, ty - 4, gold)
    elif item == "basket":
        base, dk, fr = hexc("C99A4A"), hexc("8F6428"), [hexc("D94B38"), hexc("F2B84B"), hexc("6A994E")]
        for j in range(3):
            for x in range(4, 12):
                im.set(x, hy - 3 + j, base if (x + j) % 2 else dk)
        for x in range(5, 11):
            im.set(x, hy - 4, fr[(x // 2) % 3])
        im.hline(5, 10, hy - 5, fr[0]) if False else None
        im.set(6, hy - 5, fr[1])
        im.set(9, hy - 5, fr[0])
        if d != "left":
            for y in range(hy, ty + 1):
                im.set(12, y, hexc("C9A48A") if False else skin)
    elif item == "jar_head":
        c = hexc("B8643A")
        im.hline(7, 8, hy - 5, shade(c, 0.8))
        im.hline(6, 9, hy - 4, c)
        for y in (-3, -2, -1):
            im.hline(5, 10, hy + y, shade(c, 1.2) if y == -3 else (shade(c, 0.78) if y == -1 else c))
        im.set(6, hy - 3, shade(c, 1.5))
        if d != "left":
            for y in range(hy - 1, ty + 1):
                im.set(12, y, skin)
    elif item == "jar_hip":
        c = hexc("B8643A")
        if d == "left":
            ox = 5
        else:
            ox = 11
        for j in range(5):
            w = (2, 4, 4, 4, 3)[j]
            x = ox + (4 - w) // 2 if d != "left" else ox + (4 - w) // 2
            im.hline(x, x + w - 1, ty + 3 + j, shade(c, 1.2 if j == 1 else (0.78 if j >= 3 else 1)))
        im.set(ox + 1, ty + 2, shade(c, 0.8))
        im.set(ox + 2, ty + 2, shade(c, 0.8))
    elif item == "pole":
        wood = hexc("8A6A3A")
        bs = [hexc("C99A4A"), hexc("8F6428")]
        cont = hexc("C9D6DD")
        y = ty + 1
        xs = (1, 14) if d != "left" else (2, 13)
        im.hline(xs[0], xs[1], y, wood)
        im.hline(xs[0] + 1, xs[1] - 1, y - 1, shade(wood, 1.3)) if False else None
        for k, bx in enumerate(xs):
            by = y + 2 + (sway if k == 0 else -sway) * 0
            im.vline(bx, y + 1, by, hexc("5A4A32"))
            bxl = bx - 1 if k == 1 else bx
            bxl = max(0, min(bxl, 12))
            for j in range(3):
                for i in range(3):
                    im.set(bxl + i, by + 1 + j + (wobble if k else 0), bs[(i + j) % 2])
            im.hline(bxl, bxl + 2, by, cont)
    elif item == "baby":
        sash, sd = hexc("B84A62"), hexc("7D2B40")
        cloth_c = hexc("E8D8B0")
        if d == "down":
            for k in range(5):
                im.set(10 - k, ty + k, sash)
                im.set(10 - k + 1, ty + k, sd) if k else None
            im.rect(3, ty + 3, 4, 4, cloth_c)
            im.rect(3, ty + 6, 4, 1, shade(cloth_c, 0.78))
            im.rect(4, ty + 1, 2, 2, skin)
            im.set(4, ty + 1, hexc("2A1D26"))
            im.set(5, ty + 1, hexc("2A1D26"))
        elif d == "up":
            for k in range(5):
                im.set(5 + k, ty + k, sash)
            im.rect(3, ty + 1, 3, 2, hexc("2A1D26"))
            im.set(4, ty + 2, skin)
        else:
            for k in range(5):
                im.set(9 - k, ty + k, sash)
            im.rect(3, ty + 3, 3, 4, cloth_c)
            im.rect(3, ty + 6, 3, 1, shade(cloth_c, 0.78))
            im.rect(3, ty + 1, 2, 2, skin)
            im.set(4, ty + 1, hexc("2A1D26"))
    elif item == "net":
        nc, fl = hexc("C9D6A5"), hexc("E08A3A")
        if d == "left":
            if layer != "back":
                return
            for y in range(ty, ty + 8):
                for x in range(10, 13):
                    if (x + y) % 2 == 0:
                        im.set(x, y, nc)
            im.set(11, ty + 8, fl)
            im.set(10, ty - 1, fl)
        elif d == "up":
            for y in range(ty, ty + 8):
                for x in range(6, 12):
                    if (x + y) % 2 == 0 and x - 6 <= (y - ty) + 2:
                        im.set(x, y, nc)
            im.set(10, ty - 1, fl)
        else:
            for y in range(ty - 1, ty + 8):
                for x in range(10, 14):
                    if (x + y) % 2 == 0:
                        im.set(x, y, nc)
            im.set(12, ty + 8, fl)
            im.set(13, ty + 8, fl)
            im.set(11, ty - 2, fl)
    elif item == "cane":
        wood = hexc("7A5A32")
        if d == "left":
            im.vline(4, ty + 2, 21, wood)
            im.set(4, ty + 3, skin)
        else:
            im.vline(3, ty + 3, 21, wood)
            im.set(3, ty + 2, shade(wood, 1.3))
            im.set(3, ty + 3, wood)
            im.set(4, ty + 3, skin)


def make_villager(v):
    sh = sheet(16, 24, 4, 8)
    for r, d in enumerate(("down", "up", "left", "right")):
        for f in range(4):
            put(sh, f, r, person(v, d, f), 16, 24)
        for f in range(2):
            put(sh, f, 4 + r, person(v, d, f, idle=True), 16, 24)
    return sh


# ------------------------------------------------------------------ animals
def leg(im, x, y0, y1, w, c):
    for y in range(y0, y1 + 1):
        im.rect(x, y, w, 1, c)


def walk_legs(f):
    """lifted flags for [near-front, far-front, near-back, far-back] per frame"""
    return [(1, 0, 0, 1), (0, 0, 0, 0), (0, 1, 1, 0), (0, 0, 0, 0)][f % 4]


def cell_img(cw, ch):
    return Img(cw, ch)


def bird(cw, ch, pal, frame, kind):
    """chicken / rooster / chick / duck facing left. frame: idle0 idle1 walk0..3 extra0 extra1"""
    im = Img(cw, ch)
    body, dark, light, comb, beak, legc, tail = pal
    walk = frame in (2, 3, 4, 5)
    wf = frame - 2 if walk else 0
    bob = 1 if walk and wf in (1, 3) else 0
    gy = ch - 2  # ground row
    if kind == "chick":
        ell(im, 4.5, 4.5 + bob, 2.8, 2.6, body)
        ell(im, 3.0, 3.2 + bob, 1.8, 1.7, body)
        im.set(1, 4 + bob, beak)
        im.set(2, 3 + bob, EYE)
        if frame == 6:
            im.set(1, 5 + bob, beak)
            im.set(2, 3 + bob, body)
        im.set(3, gy, legc) if not (walk and wf in (0, 2)) else im.set(4, gy, legc)
        im.set(5, gy, legc)
        return im.outline()
    if kind == "duck":
        swim = frame in (6, 7)
        by = 6.2 + (1 if swim else 0) + bob * 0.5
        ell(im, 6.6, by, 4.2, 2.6, body)
        ell(im, 3.0, by - 2.6, 1.9, 1.9, dark)  # head
        im.rect(1, int(by - 2), 2, 1, beak)
        im.set(3, int(by - 3), EYE)
        im.rect(8, int(by - 1), 3, 2, light)  # wing
        im.set(10, int(by - 3), body)
        im.set(11, int(by - 2), body)
        if not swim:
            lx = [6, 7] if not walk or wf in (0, 2) else ([5, 8] if wf == 1 else [7, 6])
            for x in lx:
                im.set(x, gy, beak)
                im.set(x, gy - 1, beak)
        else:
            for x in range(2, 11):
                im.set(x, int(by + 2.5) + (1 if (x + frame) % 3 == 0 else 0), hexc("BEE3F0", 170))
        return im.outline()
    # chicken / rooster
    big = kind == "rooster"
    cx = 6.5 + (1 if big else 0)
    cy = (6.2 if not big else 6.8) + bob
    ell(im, cx, cy, 3.3 if not big else 3.8, 2.6 if not big else 3.0, body)
    # tail
    tx = int(cx + (3 if not big else 3.5))
    for k in range(3 if not big else 5):
        tc = tail if k % 2 == 0 else dark
        im.set(tx + (k if big and k < 2 else 0), int(cy - 2 - k * (1 if not big else 1)) + (1 if big and k > 2 else 0), tc)
        im.set(tx + 1, int(cy - 1 - k), tc) if big else None
    im.rect(int(cx) - 1, int(cy) - 1, 3, 2, light)  # wing
    hy = 3.4 + (bob * 0.5)
    hx = 3.0
    if frame == 6:  # peck: head down and forward
        hy, hx = 6.6, 2.0
    elif frame == 1:
        hy = 2.6
    elif frame == 7 and big:  # crow: head back, beak up
        hy, hx = 1.8, 3.6
    ell(im, hx, hy, 1.7, 1.6, body if not big else light, shaded=False)
    im.set(int(hx) - 2, int(hy), beak)
    im.set(int(hx) - 1, int(hy) + 1 if frame == 6 else int(hy), beak) if frame == 6 else None
    im.set(int(hx) - 1, int(hy) - 1, EYE)
    im.set(int(hx), int(hy) - 2, comb)
    im.set(int(hx) + 1, int(hy) - 2, comb)
    if big:
        im.set(int(hx) - 1, int(hy) - 2, comb)
        im.set(int(hx) - 1, int(hy) + 2, comb)
    else:
        im.set(int(hx) - 1, int(hy) + 1, comb) if frame != 6 else None
    # legs
    hop = frame == 7 and not big
    ly = gy - (2 if hop else 0)
    if walk:
        xs = [(int(cx) - 1, int(cx) + 1), (int(cx) - 2, int(cx) + 2), (int(cx) - 1, int(cx) + 1), (int(cx), int(cx))][wf]
    else:
        xs = (int(cx) - 1, int(cx) + 1)
    for x in xs:
        im.set(x, ly, legc)
        im.set(x, ly - 1, legc)
    if hop:
        im.set(int(cx) - 3, int(cy), body)
        im.set(int(cx) + 4, int(cy) - 1, light)
    return im.outline()


def quad_legs(im, xs, y0, y1, f, w, c, dark, stride=1):
    """xs = [near-front, far-front, near-back, far-back] x positions"""
    lift = walk_legs(f) if f is not None else (0, 0, 0, 0)
    order = [1, 3, 0, 2]  # far legs first
    for i in order:
        col = dark if i in (1, 3) else c
        e = y1 - (1 if lift[i] else 0)
        x = xs[i] + (stride if lift[i] else 0)
        leg(im, x, y0, e, w, col)


def cat(pal, frame):
    cw, ch = 14, 12
    im = Img(cw, ch)
    body, dark, light, eye, nose = pal
    walk = frame in (2, 3, 4, 5)
    wf = frame - 2 if walk else 0
    if frame in (6, 7):  # sleeping loaf, curled
        b = 1 if frame == 7 else 0
        ell(im, 7.0, 8.0 - b * 0.0, 5.2, 2.7 + b * 0.4, body)
        ell(im, 4.0, 8.5, 2.2, 1.7, body)
        im.set(2, 8, dark)
        im.set(3, 9, dark)
        im.hline(8, 11, 10, dark)
        im.set(3, 7, dark)
        im.set(5, 7, dark)
        im.hline(5, 6, 6, light)
        im.set(11, 9, body)
        im.set(12, 9, dark)
        return im.outline()
    if not walk:  # sitting
        flick = frame == 1
        ell(im, 8.0, 7.4, 3.0, 3.2, body)
        ell(im, 5.2, 3.6, 2.4, 2.1, body)
        im.set(3, 1, dark)
        im.set(4, 1, body)
        im.set(6, 1, body)
        im.set(7, 1, dark)
        im.set(4, 3, eye)
        im.set(6, 3, eye)
        im.set(5, 4, nose)
        im.hline(5, 7, 5, light)
        im.rect(5, 9, 2, 2, body)
        im.rect(8, 10, 3, 1, dark)
        for k in range(4):
            im.set(11 + (k if not flick else 0), 10 - k * (0 if flick else 0) - (k if flick else 0) // 2, dark if k else body)
        im.set(6, 8, light)
        return im.outline()
    bob = 1 if wf in (1, 3) else 0
    ell(im, 7.5, 6.0 + bob, 4.2, 2.1, body)
    ell(im, 3.0, 4.2 + bob, 2.1, 1.9, body)
    im.set(1, 2 + bob, dark)
    im.set(2, 2 + bob, body)
    im.set(4, 2 + bob, body)
    im.set(5, 2 + bob, dark)
    im.set(2, 4 + bob, eye)
    im.set(1, 5 + bob, nose)
    # tail up
    for k in range(4):
        im.set(11 + (k > 1), 5 - k + bob, dark if k else body)
    im.hline(6, 9, 5 + bob, light)
    quad_legs(im, [4, 3, 10, 9], 8 + bob, 10, wf, 1, body, dark, 1)
    return im.outline()


def dog(pal, frame):
    cw, ch = 16, 13
    im = Img(cw, ch)
    body, dark, light, ear, nose = pal
    walk = frame in (2, 3, 4, 5)
    wf = frame - 2 if walk else 0
    if frame in (6, 7):  # lying
        b = 1 if frame == 7 else 0
        ell(im, 9.0, 8.4, 5.4, 2.6 + b * 0.3, body)
        ell(im, 3.6, 7.0, 2.3, 2.1, body)
        im.rect(0, 8, 3, 2, light)
        im.set(0, 8, nose)
        im.set(2, 5, ear)
        im.rect(3, 4, 2, 3, ear)
        im.set(2, 6, EYE)
        im.hline(5, 13, 10, dark)
        im.hline(13, 14, 9, body)
        return im.outline()
    bob = 1 if walk and wf in (1, 3) else 0
    ell(im, 9.0, 6.3 + bob, 4.8, 2.7, body)
    ell(im, 3.6, 4.0 + bob, 2.3, 2.1, body)
    im.rect(0, 5 + bob, 3, 2, light)
    im.set(0, 5 + bob, nose)
    im.rect(3, 2 + bob, 2, 3, ear)
    im.set(2, 3 + bob, EYE)
    wag = (frame == 1) or (walk and wf % 2 == 1)
    for k in range(4):
        im.set(13 + (1 if k > 1 else 0), 4 - k + bob + (1 if wag and k > 1 else 0), dark if k else body)
    im.hline(6, 11, 6 + bob, light)
    quad_legs(im, [4, 3, 11, 10], 8 + bob, 10, wf if walk else None, 2, body, dark, 1)
    im.rect(4, 8, 2, 3, body) if False else None
    return im.outline()


def goat(pal, frame):
    cw, ch = 18, 16
    im = Img(cw, ch)
    body, dark, light, horn, beard = pal
    walk = frame in (2, 3, 4, 5)
    wf = frame - 2 if walk else 0
    graze = frame in (6, 7)
    bob = 1 if walk and wf in (1, 3) else 0
    ell(im, 10.5, 7.8 + bob, 5.6, 3.0, body)
    # tail
    im.set(16, 5 + bob, body)
    im.set(16, 4 + bob, dark)
    if graze:
        ell(im, 3.4, 11.5 + (1 if frame == 7 else 0), 2.2, 1.9, body)
        ell(im, 6.0, 9.5, 2.3, 2.3, body)
        im.set(1, 12 + (1 if frame == 7 else 0), dark)
        im.set(3, 10, EYE)
        im.rect(4, 8, 2, 1, horn)
        im.set(4, 7, horn)
        im.set(2, 13, beard)
    else:
        ell(im, 5.5, 5.0 + bob, 2.0, 3.0, body)  # neck
        ell(im, 3.3, 3.4 + bob, 2.4, 2.1, body)
        im.set(1, 4 + bob, dark)
        im.set(3, 3 + bob, EYE)
        im.rect(5, 0 + bob, 1, 3, horn)
        im.set(6, 0 + bob, horn)
        im.set(7, 1 + bob, horn)
        im.set(1, 6 + bob, beard)
        im.set(1, 7 + bob, beard)
        ear_y = 3 + (1 if frame == 1 else 0)
        im.rect(5, ear_y + bob, 2, 1, dark)
    im.hline(8, 14, 7 + bob, light)
    quad_legs(im, [5, 4, 14, 13], 10 + bob, 13, wf if walk else None, 1, body, dark, 1)
    for x in (5, 4, 14, 13):
        im.set(x, 14, horn)
    return im.outline()


def kerbau(pal, frame):
    cw, ch = 28, 20
    im = Img(cw, ch)
    body, dark, light, horn, hoof = pal
    walk = frame in (2, 3, 4, 5)
    wf = frame - 2 if walk else 0
    graze = frame in (6, 7)
    bob = 1 if walk and wf in (1, 3) else 0
    ell(im, 16.5, 9.5 + bob, 9.2, 5.2, body)
    ell(im, 10.5, 6.5 + bob, 3.2, 3.0, body)  # shoulder hump
    # tail
    im.vline(25, 6 + bob, 13, dark)
    im.set(24, 5 + bob, dark)
    im.rect(25, 14, 2, 2, dark)
    hy = 12 if graze else 10
    hx = 5
    ell(im, hx + 1, hy + bob + (1 if frame == 7 else 0), 3.6, 2.6, body)
    ell(im, hx - 1.5, hy + 1.5, 2.2, 1.6, light)  # muzzle
    im.set(hx - 3, hy + 1, hoof)
    im.set(hx + 1, hy - 1 + bob, EYE)
    im.hline(13, 22, 8 + bob, light)
    quad_legs(im, [9, 7, 21, 19], 13 + bob, 16, wf if walk else None, 3, body, dark, 1)
    for x in (9, 7, 21, 19):
        im.rect(x, 17, 3, 1, hoof)
    gy = 1 if frame == 7 else 0
    for (hx_, hy_) in (((6, 8), (7, 7), (8, 6), (9, 6), (10, 6), (11, 6), (12, 6), (13, 7), (14, 8)) if not graze else ((7, 10), (8, 9), (9, 8), (10, 8), (11, 8), (12, 9))):
        im.set(hx_, hy_ + bob + gy, horn)
        im.set(hx_, hy_ + 1 + bob + gy, shade(horn, 0.7))
    im.set(3, 7 + bob if not graze else 10, horn) if False else None
    return im.outline()


def make_animal(fn, cw, ch, pals, *extra):
    sh = sheet(cw, ch, 8, len(pals))
    for r, pal in enumerate(pals):
        for f in range(8):
            put(sh, f, r, fn(pal, f) if not extra else fn(*extra, pal, f) if False else fn(pal, f), cw, ch)
    return sh


def make_bird(cw, ch, kind, pals):
    sh = sheet(cw, ch, 8, len(pals))
    for r, pal in enumerate(pals):
        for f in range(8):
            put(sh, f, r, bird(cw, ch, pal, f, kind), cw, ch)
    return sh


P = hexc
ANIMALS = {
    # name: (cw, ch, rows, maker)
    "chicken": (12, 12, 3, lambda: make_bird(12, 12, "chicken", [
        (P("C98B4A"), P("8A5A2A"), P("E6B870"), P("D93A2E"), P("F2B84B"), P("E8B040"), P("5A3A22")),
        (P("F4F1EA"), P("C9C5BC"), P("FFFFFF"), P("D93A2E"), P("F2B84B"), P("E8B040"), P("D9D5CC")),
        (P("3A3440"), P("22202A"), P("6A6478"), P("D93A2E"), P("F2B84B"), P("C89030"), P("2A4A6A"))])),
    "rooster": (14, 14, 2, lambda: make_bird(14, 14, "rooster", [
        (P("B8602E"), P("2E6A4A"), P("E8A050"), P("D93A2E"), P("F2B84B"), P("E8B040"), P("1E8A5A")),
        (P("E8E0D0"), P("8A6A4A"), P("FFFFFF"), P("D93A2E"), P("F2B84B"), P("E8B040"), P("C26A2E"))])),
    "chick": (8, 8, 2, lambda: make_bird(8, 8, "chick", [
        (P("FFE066"), P("E8B040"), P("FFF0A0"), P("D93A2E"), P("F2884B"), P("E8A030"), P("FFE066")),
        (P("F2D090"), P("C89A50"), P("FFF0C0"), P("D93A2E"), P("F2884B"), P("E8A030"), P("F2D090"))])),
    "duck": (12, 12, 2, lambda: make_bird(12, 12, "duck", [
        (P("F4F1EA"), P("F4F1EA"), P("C9C5BC"), P("F2884B"), P("F2A030"), P("F2A030"), P("F4F1EA")),
        (P("8A6A4A"), P("2E6A4A"), P("5A4026"), P("F2884B"), P("F2C040"), P("F2A030"), P("8A6A4A"))])),
    "cat": (14, 12, 4, lambda: make_animal(cat, 14, 12, [
        (P("D98A3A"), P("A85C22"), P("F2C080"), P("7ED06A"), P("E58FA8")),
        (P("34303E"), P("1E1C26"), P("5A5668"), P("F2D03A"), P("8A5A6A")),
        (P("A8A8B2"), P("6E6E7C"), P("DADAE2"), P("7ED06A"), P("E58FA8")),
        (P("F4EFE4"), P("C98A3A"), P("FFFFFF"), P("5AA0D0"), P("E58FA8"))])),
    "dog": (16, 13, 3, lambda: make_animal(dog, 16, 13, [
        (P("B8814A"), P("7A5228"), P("E8C890"), P("5A3A22"), P("2A1D26")),
        (P("34303E"), P("1E1C26"), P("8A8696"), P("1E1C26"), P("0E0C16")),
        (P("F0E8D8"), P("A8845A"), P("FFFFFF"), P("A8845A"), P("2A1D26"))])),
    "goat": (18, 16, 2, lambda: make_animal(goat, 18, 16, [
        (P("F0ECE0"), P("B8B2A4"), P("FFFFFF"), P("8A7A5A"), P("E8E4D8")),
        (P("9A6A3E"), P("5E3E22"), P("C89A66"), P("D8D0B8"), P("5E3E22"))])),
    "kerbau": (28, 20, 2, lambda: make_animal(kerbau, 28, 20, [
        (P("5C6068"), P("3A3E46"), P("8A8E98"), P("D8D0B8"), P("2A2830")),
        (P("C8B0A8"), P("8E7A74"), P("E8D8D0"), P("EEE6D0"), P("5A4A46"))])),
}


# ------------------------------------------------------------------ animated details
def smoke():
    sh = sheet(12, 12, 6, 1)
    rnd = random.Random(7)
    for f in range(6):
        im = Img(12, 12)
        r = 1.8 + f * 0.85
        a = int(235 - f * 36)
        cx, cy = 6, 11 - r
        for y in range(12):
            for x in range(12):
                dx, dy = x + 0.5 - cx, y + 0.5 - cy
                if dx * dx + dy * dy <= r * r + rnd.random() * (f * 0.6):
                    t = (dx + dy * 0.6) / (r * 1.6)
                    c = (236, 236, 242, a) if t < 0.1 else (200, 200, 214, a)
                    im.set(x, y, c)
        for x in range(12):
            for y in range(12):
                pass
        sh.blit(im, f * 12, 0)
    return sh


def fire():
    sh = sheet(12, 14, 4, 1)
    for f in range(4):
        im = Img(12, 14)
        wood, wd = P("7A5030"), P("4A2E1A")
        im.rect(1, 11, 10, 2, wood)
        im.hline(1, 10, 12, wd)
        im.set(0, 11, wood)
        im.set(11, 11, wood)
        im.rect(3, 9, 6, 2, shade(wood, 0.9))
        sh_ = [0, 1, 0, -1][f]
        h = [7, 8, 6, 8][f]
        for y in range(h):
            w = max(1, int(5 * (1 - y / (h + 1)) + 1))
            c = [P("FFE066"), P("FFB030"), P("F26A22"), P("D93A2E")][min(3, y // 2)] if False else None
        # layered flame: red outer, orange, yellow core
        for layer, (col, wmul, hmul) in enumerate(((P("D9442A"), 1.0, 1.0), (P("FF8A22"), 0.72, 0.8), (P("FFE066"), 0.4, 0.55))):
            hh = int(h * hmul)
            for y in range(hh):
                w = max(1, int((4.2 * wmul) * (1 - (y / (hh + 0.5)) ** 1.5) + 0.8))
                cx = 6 + (sh_ if y > hh // 2 else 0)
                for x in range(cx - w + 1, cx + w + 1):
                    im.set(x, 10 - y, col)
        if f % 2 == 0:
            im.set(8 + f // 2, 2, P("FFD060"))
        sh.blit(im.outline(0.3), f * 12, 0)
    return sh


def pot():
    sh = sheet(16, 22, 4, 1)
    for f in range(4):
        im = Img(16, 22)
        st, sd = P("8C8881"), P("5E5A54")
        im.rect(2, 17, 12, 3, st)
        im.hline(2, 13, 19, sd)
        im.rect(4, 18, 8, 2, P("2A1D26"))  # stove mouth
        fl = [P("FFB030"), P("FF8A22"), P("FFD060"), P("FF8A22")][f]
        im.hline(5, 10, 19, fl)
        im.hline(6, 9, 18, P("FFD060") if f % 2 else P("FF8A22"))
        c = P("B8643A")
        im.hline(5, 10, 10, shade(c, 0.8))
        for y in range(11, 17):
            w = [2, 3, 4, 4, 4, 3][y - 11]
            im.hline(8 - w, 7 + w, y, shade(c, 1.2) if y == 11 else (shade(c, 0.76) if y > 14 else c))
        im.hline(6, 9, 10, P("4A3A2A"))
        im.set(5, 12, shade(c, 1.5))
        sh.blit(im.outline(), f * 16, 0)
        for k in range(3):  # steam
            ph = (f + k * 1.3) % 4
            for j in range(5):
                x = 7 + k + int(round(math.sin((ph + j) * 1.3) * 1.0))
                im.set(x, 8 - j * 2 - 0, (240, 240, 246, int(210 - j * 40)))
        st_img = Img(16, 22)
        for k in range(3):
            ph = (f * 0.9 + k * 1.7)
            for j in range(6):
                x = 6 + k * 2 + int(round(math.sin(ph + j * 0.9)))
                y = 8 - j * 1
                st_img.set(x, y - (j // 2) * 0, (246, 246, 250, max(40, 230 - j * 38)))
        sh.blit(st_img, f * 16, 0)
    return sh


def butterfly():
    sh = sheet(7, 6, 4, 4)
    cols = [(P("F2B84B"), P("D9742A")), (P("7AB8E8"), P("3A6AB8")), (P("F2F0E8"), P("B8B4A8")), (P("E58FA8"), P("A8486A"))]
    for r, (a, b) in enumerate(cols):
        for f in range(4):
            im = Img(7, 6)
            wing = [3, 2, 1, 2][f]
            im.set(3, 2, P("2A1D26"))
            im.set(3, 3, P("2A1D26"))
            im.set(3, 4, P("2A1D26"))
            for k in range(wing):
                for dx in (-1, 1):
                    im.set(3 + dx * (k + 1), 2 - (1 if f in (0, 3) else 0) + (k > 1), a)
                    im.set(3 + dx * (k + 1), 3 + (1 if f in (0, 3) else 0) + (k > 1) * 0, b)
            sh.blit(im, f * 7, r * 6)
    return sh


def laundry():
    """cloth hanging from y 0 downwards. cell 8x12, 3 frames, 6 rows (types)."""
    sh = sheet(8, 12, 3, 6)
    kinds = [  # (w, h, c1, c2, pat)
        (6, 10, P("2D4E73"), P("F4F1DE"), "check"), (6, 7, P("F4F1DE"), P("C7C2AC"), "plain"), (6, 10, P("A0662E"), P("6B4426"), "batik"),
        (6, 6, P("E8E4D0"), P("B8B49C"), "plain"), (4, 12, P("2A9D8F"), P("1D6B62"), "plain"), (6, 8, P("B84A62"), P("7D2B40"), "plain")]
    for r, (w, h, c1, c2, pat) in enumerate(kinds):
        for f in range(3):
            im = Img(8, 12)
            for y in range(h):
                off = int(round(math.sin(f * 2.1 + y * 0.45) * (0.4 + y * 0.18)))
                for x in range(w):
                    col = cloth(pat, c1, c2, x, y)
                    if x == w - 1:
                        col = shade(col, 0.82)
                    im.set(1 + x + off, y, col)
                if y == 0:
                    im.set(1 + off, 0, P("5A4A32"))
            sh.blit(im, f * 8, r * 12)
    return sh


def mats():
    sh = sheet(32, 16, 4, 1)
    rnd = random.Random(3)
    for k in range(4):
        im = Img(32, 16)
        if k < 3:
            base = {0: P("C9A46A"), 1: P("B8905A"), 2: P("B09050")}[k]
            for y in range(2, 15):
                for x in range(1, 31):
                    im.set(x, y, shade(base, 0.9) if (x + y) % 2 else base)
            im.hline(1, 30, 2, shade(base, 0.7))
            im.hline(1, 30, 14, shade(base, 0.7))
            if k == 0:  # rice grains
                for y in range(3, 14):
                    for x in range(2, 30):
                        if rnd.random() < 0.8:
                            im.set(x, y, [P("F2E2A0"), P("E8D07A"), P("FFF0C0")][rnd.randint(0, 2)])
            elif k == 1:  # chili
                for y in range(3, 14):
                    for x in range(2, 30):
                        if rnd.random() < 0.55:
                            im.set(x, y, [P("D93A2E"), P("B02A22"), P("E8583A")][rnd.randint(0, 2)])
            else:  # grain / corn
                for y in range(3, 14):
                    for x in range(2, 30):
                        if rnd.random() < 0.7:
                            im.set(x, y, [P("F2C040"), P("D9A02A"), P("FFE070")][rnd.randint(0, 2)])
        else:  # fish drying on a bamboo rack
            bam = P("8FAE4B")
            for y in (3, 8, 13):
                im.hline(1, 30, y, bam)
                im.hline(1, 30, y + 1, shade(bam, 0.7))
            for y in (4, 9):
                for x in range(3, 29, 5):
                    im.rect(x, y, 4, 3, P("C9D6DD"))
                    im.set(x, y + 1, P("8A9AA8"))
                    im.set(x + 3, y + 1, P("C9D6DD"))
                    im.set(x + 1, y, P("F2F4F8"))
            im.vline(1, 2, 15, P("6B4E35"))
            im.vline(30, 2, 15, P("6B4E35"))
        sh.blit(im.outline(), k * 32, 0)
    return sh


# ------------------------------------------------------------------ fences
FENCE_KINDS = ("bamboo", "bilik", "stone")


def fence_tile(kind, mask):
    im = Img(16, 16)
    N, E, S, W = mask & 1, mask & 2, mask & 4, mask & 8
    cols = {"bamboo": (P("D4E27A"), P("A0BE50"), P("6E8A35")), "bilik": (P("D4AC74"), P("B88A52"), P("8A6234")),
            "stone": (P("C4C0B6"), P("9A968E"), P("6A665E"))}[kind]
    if N or S:  # a continuous rail seen along the run, so vertical fences read as one piece
        y0, y1 = (0 if N else 7), (15 if S else 12)
        for y in range(y0, y1 + 1):
            tick = (y % 4 == 3)
            im.hline(5, 10, y, cols[2] if tick else cols[1])
            im.hline(6, 7, y, cols[1] if tick else cols[0])
            im.set(5, y, cols[2])
            im.set(10, y, cols[2])
        N = S = 0
    if kind == "bamboo":
        b, bd, bh = P("A0BE50"), P("6E8A35"), P("D4E27A")

        def picket(x, y0):
            im.vline(x, y0 + 1, 15, b)
            im.vline(x + 1, y0, 15, bd)
            im.set(x, y0, bh)
            im.set(x, 8, bd)
        segs = []
        if E:
            segs.append(range(8, 16))
        if W:
            segs.append(range(0, 8))
        for rg in segs:
            for x in rg:
                if x % 4 == 2:
                    picket(x, 5)
            for ry in (8, 12):
                for x in rg:
                    im.set(x, ry, shade(b, 1.1))
                    im.set(x, ry + 1, bd)
        if N:
            for y in range(0, 9):
                im.set(7, y, bh)
                im.set(8, y, b)
                im.set(6, y, bd) if y % 3 else None
        if S:
            for y in range(9, 16):
                im.set(7, y, bh)
                im.set(8, y, b)
        px_ = (7, 8)
        im.rect(6, 3, 3, 13, b)  # thick post
        im.vline(8, 3, 15, bd)
        im.hline(6, 8, 3, bh)
        im.hline(6, 8, 7, bd)
        im.hline(6, 8, 11, bd)
    elif kind == "bilik":
        w, wd, wh = P("B88A52"), P("8A6234"), P("D4AC74")
        post = P("5E4026")
        rg = []
        if E:
            rg += list(range(8, 16))
        if W:
            rg += list(range(0, 8))
        for x in rg:
            for y in range(5, 16):
                c = w if ((x + y) % 2 == 0) else wd
                if (x // 2 + y // 2) % 2 == 0:
                    c = w if ((x + y) % 2) else wd
                im.set(x, y, c)
            im.set(x, 5, wh)
            im.set(x, 15, wd)
        if N:
            for y in range(0, 9):
                im.set(7, y, wh)
                im.set(8, y, w)
        if S:
            for y in range(9, 16):
                im.set(7, y, wh)
                im.set(8, y, w)
        im.rect(6, 3, 3, 13, post)
        im.vline(8, 3, 15, shade(post, 0.7))
        im.hline(6, 8, 3, shade(post, 1.5))
    else:
        s, sd, sh_ = P("9A968E"), P("6A665E"), P("C4C0B6")
        rg = []
        if E:
            rg += list(range(8, 16))
        if W:
            rg += list(range(0, 8))
        for x in rg:
            for y in range(7, 16):
                brick = ((y - 7) // 3 + (x // 4)) % 2
                c = s if brick else shade(s, 0.93)
                if (y - 7) % 3 == 2 or (x % 4 == 3 and (y - 7) // 3 % 2 == 0) or (x % 4 == 1 and (y - 7) // 3 % 2 == 1 and False):
                    c = sd
                im.set(x, y, c)
            im.set(x, 7, sh_)
            im.set(x, 8, shade(sh_, 0.9))
        if N:
            for y in range(0, 9):
                for x in (5, 6, 7, 8, 9):
                    im.set(x, y, sh_ if x < 8 else s)
        if S:
            for y in range(9, 16):
                for x in (5, 6, 7, 8, 9):
                    im.set(x, y, sh_ if x < 8 else s)
        im.rect(5, 4, 5, 12, s)
        im.vline(9, 4, 15, sd)
        im.hline(5, 9, 4, sh_)
        im.hline(5, 9, 5, shade(sh_, 0.92))
        im.hline(5, 9, 9, sd)
        im.hline(5, 9, 13, sd)
    return im.outline() if False else outline_in(im)


def outline_in(im):
    """Outline that keeps the 16x16 canvas: only draws on transparent pixels touching the figure."""
    return im.outline(0.4)


def fences():
    sh = sheet(16, 16, 16, 3)
    for r, k in enumerate(FENCE_KINDS):
        for m in range(16):
            sh.blit(fence_tile(k, m), m * 16, r * 16)
    return sh


# ------------------------------------------------------------------ crops
def soil(im, wet=False):
    base = P("5E4026") if not wet else P("4A5A44")
    for y in range(16, 32):
        for x in range(16):
            c = base if (x + y) % 5 else shade(base, 0.85)
            if y in (16, 17):
                c = shade(base, 1.2)
            im.set(x, y, c)
    for x in range(0, 16, 4):
        im.hline(x, x + 2, 24, shade(base, 0.7))
        im.hline(x, x + 2, 30, shade(base, 0.7))


def crop_cell(kind, var):
    im = Img(16, 32)
    soil(im, wet=(kind == "rice"))
    rnd = random.Random(zlib.crc32(("%s%d" % (kind, var)).encode()))
    if kind == "cassava":
        leaf, ld, stem = P("5E9A44"), P("386641"), P("8A6A3A")
        for px_ in ((3, 12), (11, 14)) if var == 0 else ((4, 13), (12, 12), (8, 17)):
            x, ytop = px_
            im.vline(x, ytop + 4, 28, stem)
            for a in range(5):
                lx = x + int(round(math.cos(a * 1.26 - 0.3) * 4))
                ly = ytop + 3 + int(round(math.sin(a * 1.26 - 0.3) * 3))
                im.hline(min(x, lx), max(x, lx), ly, leaf if a % 2 else ld)
                im.set(lx, ly - 1, leaf)
            im.set(x, ytop + 2, P("8EC264"))
    elif kind == "chili":
        leaf, ld = P("4F9A3E"), P("2E6A2E")
        for x in (3, 9, 14) if var == 0 else (2, 7, 12):
            ell(im, x + 0.5, 22.5, 3.0, 4.2, leaf)
            for k in range(4):
                fx, fy = x - 1 + rnd.randint(0, 3), 19 + rnd.randint(0, 5)
                im.set(fx, fy, P("D93A2E") if var == 0 or k % 2 else P("FF8A22"))
                im.set(fx, fy + 1, P("B02A22"))
            im.set(x, 18, ld)
    elif kind == "rice":
        w, wd = P("A8D45A"), P("6AA038")
        for x in range(0, 16, 2):
            hgt = 6 + ((x * 7 + var * 3) % 4)
            for k in range(hgt):
                im.set(x, 27 - k - 0, w if k > 1 else wd)
                if k > hgt - 3:
                    im.set(x + (1 if k % 2 else -1), 27 - k, w)
            im.set(x, 27 + 1, wd)
        for x in range(1, 16, 4):
            im.set(x, 29, P("9AB8C8"))
    else:  # banana tree, tall
        trunk, tl = P("7AA050"), P("A0C070")
        leaf, ld, lh = P("4E9A38"), P("2E6A2E"), P("78C050")
        im.rect(7, 12, 3, 17, trunk)
        im.vline(7, 12, 28, tl)
        im.vline(9, 12, 28, shade(trunk, 0.7))
        for k in range(6):
            im.hline(7, 9, 15 + k * 3, shade(trunk, 0.75))
        # crown of drooping leaves
        for (dx, dy, ln) in ((-1, 0, 7), (1, 0, 7), (-1, 2, 6), (1, 2, 6), (0, -2, 5)):
            sx, sy = 8, 10
            for i in range(ln):
                x = sx + dx * (i + 1) - (0 if dx == 0 else 0)
                y = sy + dy + (i * i) // (5 if dx else 99) - (i if dx == 0 else 0)
                im.set(x, y, lh if i % 3 == 0 else leaf)
                im.set(x, y + 1, ld)
                im.set(x, y - 1, leaf) if i < ln - 1 else None
        if var == 1:  # bunch
            im.rect(10, 14, 3, 4, P("E8C84A"))
            im.rect(10, 17, 3, 1, P("B09020"))
            im.set(10, 13, P("5A3A5A"))
    return im.outline()


def crops():
    sh = sheet(16, 32, 8, 1)
    i = 0
    for k in ("cassava", "chili", "rice", "banana"):
        for var in (0, 1):
            sh.blit(crop_cell(k, var), i * 16, 0)
            i += 1
    return sh


# ------------------------------------------------------------------ stall goods
def goods_cell(kind, var):
    im = Img(16, 16)
    wood, wd = P("9A6A3A"), P("6A4426")
    # counter: top slab rows 7..9, front panel rows 10..15
    im.rect(0, 7, 16, 3, shade(wood, 1.15))
    im.hline(0, 15, 7, shade(wood, 1.4))
    im.rect(0, 10, 16, 6, wood)
    im.hline(0, 15, 10, wd)
    for x in range(0, 16, 5):
        im.vline(x, 11, 15, wd)
    cl = [P("E8D8B0"), P("C23B2E"), P("2D4E73"), P("6A994E")][(var + {"fruit": 0, "batik": 1, "pottery": 2, "fish": 3, "spice": 0}[kind]) % 4]
    if kind == "fruit":
        cols = [(P("F2B84B"), P("E08A22"), P("FFD878")), (P("D93A2E"), P("A82A22"), P("FF7A60"))][var % 2]
        for (cx, cy) in ((4, 5), (8, 4), (12, 5), (6, 6), (10, 6)):
            ell(im, cx, cy + 0.5, 2.1, 2.0, cols[0], shaded=False)
            im.set(cx - 1, cy - 1, cols[2])
            im.set(cx + 1, cy + 1, cols[1])
        for x in (3, 9, 13):
            im.set(x, 2, P("6A994E"))
        im.hline(1, 14, 7, P("E8D8B0"))
    elif kind == "batik":
        cs = [(P("A0662E"), P("F4F1DE")), (P("2D4E73"), P("E8C458")), (P("8A3A4A"), P("F4D0A0"))]
        for i, (x, w) in enumerate(((1, 6), (7, 5), (11, 4))):
            c1, c2 = cs[(i + var) % 3]
            for j in range(4):
                y = 6 - j - (1 if i == 1 else 0)
                for xx in range(x, x + w):
                    im.set(xx, y, cloth("batik", c1, c2, xx, y))
                im.hline(x, x + w - 1, 7 if j == 0 else y, shade(c1, 0.75)) if j == 0 else None
        im.hline(0, 15, 7, shade(wood, 1.4))
    elif kind == "pottery":
        c = P("B8643A") if var == 0 else P("8A4A2A")
        for (cx, h) in ((4, 5), (9, 6), (13, 4)):
            for y in range(h):
                w = [1, 2, 3, 3, 3, 2][y] if h == 5 else [1, 2, 3, 3, 3, 3, 2][y] if h == 6 else [1, 2, 2, 2][y]
                im.hline(cx - w, cx + w - 1, 6 - y, shade(c, 1.25) if y == h - 1 else (shade(c, 0.78) if y == 0 else c))
            im.set(cx - 1, 6 - h + 2, shade(c, 1.5))
    elif kind == "fish":
        bk = P("C99A4A")
        for (x, w) in ((1, 6), (9, 6)):
            im.rect(x, 4, w, 4, bk)
            im.hline(x, x + w - 1, 4, shade(bk, 1.3))
            im.hline(x, x + w - 1, 7, shade(bk, 0.7))
            for i in range(2):
                fx = x + 1 + i * 2 + var
                im.rect(fx, 2 + i, 3, 2, P("B8C8D4"))
                im.set(fx, 2 + i, P("F2F4F8"))
                im.set(fx + 2, 2 + i, P("7A8AA0"))
                im.set(fx - 1, 3 + i, P("7A8AA0"))
    else:  # spice sacks
        sk = [P("D8C8A0"), P("C09A58")][var % 2]
        for (x, w, h, col) in ((1, 5, 6, P("D93A2E")), (6, 5, 7, P("E8B040")), (11, 4, 5, P("6A994E"))):
            im.rect(x, 7 - h, w, h, sk)
            im.hline(x, x + w - 1, 7 - h, shade(sk, 1.3))
            im.vline(x + w - 1, 8 - h, 6, shade(sk, 0.78))
            ell(im, x + w / 2, 7 - h - 0.2, w / 2 - 0.2, 1.4, col)
    return im.outline()


def goods():
    sh = sheet(16, 16, 10, 1)
    i = 0
    for k in ("fruit", "batik", "pottery", "fish", "spice"):
        for var in (0, 1):
            sh.blit(goods_cell(k, var), i * 16, 0)
            i += 1
    return sh


# ------------------------------------------------------------------ preview + defs
def preview(items):
    scale = 3
    pad = 6
    W = 1000
    y = pad
    placed = []
    x = pad
    rowh = 0
    for im in items:
        w, h = im.w * scale, im.h * scale
        if x + w > W:
            x = pad
            y += rowh + pad
            rowh = 0
        placed.append((im, x, y))
        x += w + pad
        rowh = max(rowh, h)
    H = y + rowh + pad
    out = Img(W, H)
    out.rect(0, 0, W, H, (74, 104, 70, 255))
    for im, px_, py_ in placed:
        for yy in range(im.h):
            for xx in range(im.w):
                c = im.p[yy * im.w + xx]
                if c[3]:
                    out.rect(px_ + xx * scale, py_ + yy * scale, scale, scale, c) if c[3] == 255 else [out.set(px_ + xx * scale + i, py_ + yy * scale + j, c) for i in range(scale) for j in range(scale)]
    return out


def write_defs(nvar):
    lines = ["extends RefCounted", "## GENERATED by tools/gen_ambient.py: do not edit.",
             "## Villager variants (sheet villager_NN.png) and animal sheet geometry.", "", "const VILLAGERS := ["]
    for i, v in enumerate(V):
        lines.append('\t{"body": "%s", "regions": %s, "item": "%s"},  # %02d' % (v[0], str(v[7].split()).replace("'", '"'), v[6], i))
    lines.append("]")
    lines.append("")
    lines.append("## name -> cell size and palette rows (columns: idle0 idle1 walk0-3 extra0 extra1)")
    lines.append("const ANIMALS := {")
    for n, (cw, ch, rows, _) in ANIMALS.items():
        lines.append('\t"%s": {"cell": Vector2i(%d, %d), "rows": %d},' % (n, cw, ch, rows))
    lines.append("}")
    path = os.path.join(ROOT, "entities", "ambient", "ambient_defs.gd")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write("\n".join(lines) + "\n")


def main():
    prev = []
    for i, v in enumerate(V):
        sh = make_villager(v)
        write_png(os.path.join(OUT, "villager_%02d.png" % i), sh)
        row = Img(16 * 6, 24)
        for k, (d, f) in enumerate((("down", 0), ("down", 1), ("up", 1), ("left", 1), ("right", 3), ("left", 0))):
            row.blit(person(v, d, f), k * 16, 0)
        prev.append(row)
    for n, (cw, ch, rows, mk) in ANIMALS.items():
        sh = mk()
        write_png(os.path.join(OUT, "animal_%s.png" % n), sh)
        prev.append(sh)
    for n, fn in (("smoke", smoke), ("pot", pot), ("fire", fire), ("butterfly", butterfly), ("laundry_cloth", laundry), ("mats", mats),
                  ("fences", fences), ("crops", crops), ("goods", goods)):
        sh = fn()
        write_png(os.path.join(OUT, n + ".png"), sh)
        prev.append(sh)
    write_defs(len(V))
    write_png(os.path.join(ROOT, "tools", "ambient_preview.png"), preview(prev))
    print("villagers:", len(V), "animals:", len(ANIMALS))


if __name__ == "__main__":
    main()
