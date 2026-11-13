"""Brush-ink FX for the cast stroke (art pass v8): brush tile, blot, splatter, carved-seal strips.
Neutral white/grey so the runtime tints them with the glyph element colour. Hard pixels only.
Run from anywhere: python3 tools/gen_ink_fx.py -> assets/art/fx/ink/*.png + tools/ink_fx_preview.png"""
import os
import sys
import random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from PIL import Image
from pixlib import *

G = [(255, 255, 255, 255), (222, 222, 222, 255), (178, 178, 178, 255), (128, 128, 128, 255)]
P = ROOT_ART = None


def brush():
    """16x8, tiles along x. Rows: 0-1 dry broken edge, 2-5 body lit from the top, 6-7 broken edge."""
    im = Image.new("RGBA", (16, 8), (0, 0, 0, 0))
    r = random.Random(7)
    for x in range(16):
        # edge rows: periodic runs so the tile wraps cleanly
        top = 1 if (x % 5) in (0, 1, 3) else 0
        bot = 1 if (x % 7) in (1, 2, 3, 5) else 0
        for y in range(8):
            if y in (2, 3, 4, 5):
                c = G[0] if y == 2 else G[1] if y == 3 else G[2] if y == 4 else G[3]
                im.putpixel((x, y), c)
            elif y == 1 and top:
                im.putpixel((x, y), G[1])
            elif y == 6 and bot:
                im.putpixel((x, y), G[3])
            elif y == 0 and top and (x % 4) == 0:
                im.putpixel((x, y), G[2])
            elif y == 7 and bot and (x % 6) == 2:
                im.putpixel((x, y), G[3])
    # dry-brush streak gaps inside the body, 2 px runs
    for x0, y in ((3, 4), (11, 3), (8, 5)):
        for dx in range(3):
            im.putpixel(((x0 + dx) % 16, y), (0, 0, 0, 0))
    return im


def blot_frame(i, n=4):
    f = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    r = [3, 5.2, 6.4, 6.0][i]
    blob(f, 8, 8, r, G, wobble=0.35, seed=3 + i)
    if i >= 1:  # satellite drops
        for k, (dx, dy) in enumerate(((-6, -4), (6, 3), (-3, 6))):
            if i + k >= 2:
                blob(f, 8 + dx, 8 + dy, 1.2, G[1:], seed=k)
    if i == 3:  # fade: step the body down the ramp
        f = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
        blob(f, 8, 8, 5.6, G[2:], wobble=0.4, seed=9)
    return f


def splatter_frame(i):
    f = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    rnd = random.Random(11)
    spread = [3, 5, 6.5, 7][i]
    for k in range(7):
        a = rnd.uniform(0, math.tau)
        d = spread * rnd.uniform(0.4, 1.0)
        r = max(1.4, rnd.choice((1.6, 2.0, 2.4)) * (1 - i * 0.12))
        if True:
            blob(f, 8 + math.cos(a) * d, 8 + math.sin(a) * d, r, G[:3] if i < 3 else G[2:], seed=k)
    return f


def seal_frame(i, n=7, s=64):
    f = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    c = s // 2
    t = i / (n - 1)
    rnd = random.Random(5)
    if i <= 2:
        h = [18, 24, 26][i]  # half size of the stamp square
        for y in range(c - h, c + h):
            for x in range(c - h, c + h):
                e = min(x - (c - h), c + h - 1 - x, y - (c - h), c + h - 1 - y)
                tone = G[0] if (x - c < 0 or y - c < 0) and e < 2 else G[1] if e < 3 else G[2]
                if x + y > 2 * c + h // 2 and e < 3:
                    tone = G[3]
                # rough stamped edge: chip a few border pixels
                if e == 0 and (x * 7 + y * 13) % 5 == 0 or e == 1 and (x * 3 + y * 11) % 9 == 0:
                    continue
                dot(f, x, y, tone)
        # kawung carved as negative space: 4 fat petals (rotated ellipses) round a centre dot
        for y in range(c - h + 5, c + h - 5):
            for x in range(c - h + 5, c + h - 5):
                dx, dy = x + 0.5 - c, y + 0.5 - c
                hit = math.hypot(dx, dy) <= 2.3
                for ax, ay in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    u, v = dx - ax * h * 0.42, dy - ay * h * 0.42   # petal centre
                    a, b = (h * 0.3, h * 0.17) if ax else (h * 0.17, h * 0.3)
                    hit = hit or (u / a) ** 2 + (v / b) ** 2 <= 1
                if hit:
                    f.putpixel((x, y), (0, 0, 0, 0))
        f = plum_outline(f)
    else:  # frame breaks into square chunks that drift out and step down the ramp
        tones = G[min(i - 2, 2):] if i < 6 else G[3:]
        for k in range(12):
            a = k * (math.tau / 12) + 0.3
            ring = 22 + (i - 2) * 2.4 + rnd.uniform(-2, 2)
            sz = max(3, int(rnd.choice((5, 6, 7)) * (1 - (i - 2) * 0.1)))
            cx, cy = c + math.cos(a) * ring, c + math.sin(a) * ring
            for yy in range(sz):
                for xx in range(sz):
                    tone = tones[0] if (xx < 2 and yy < 2) else tones[-1] if (xx + yy) > sz else tones[min(1, len(tones) - 1)]
                    dot(f, cx - sz / 2 + xx, cy - sz / 2 + yy, tone)
        if i == 3:
            f = plum_outline(f)
    return f


def main():
    out = os.path.join("fx", "ink")
    b = brush()
    save(b, os.path.join(out, "brush.png"))
    bl = strip([blot_frame(i) for i in range(4)])
    save(bl, os.path.join(out, "blot.png"))
    sp = strip([splatter_frame(i) for i in range(4)])
    save(sp, os.path.join(out, "splatter.png"))
    se = strip([seal_frame(i) for i in range(7)])
    save(se, os.path.join(out, "seal.png"))
    assert b.size == (16, 8) and bl.size == (64, 16) and sp.size == (64, 16) and se.size == (448, 64)
    # preview: each strip tinted with 2-3 element colours (multiply, as Godot modulate does)
    cols = [(0x56, 0xB4, 0xE9), (0xF2, 0x6B, 0x5B), (0xE6, 0xC2, 0x4A)]
    rows = []
    for name, im in (("brush", tiled(b, 96, 8)), ("blot", bl), ("splatter", sp), ("seal", se)):
        for c in cols:
            t = im.copy()
            p = t.load()
            for y in range(t.height):
                for x in range(t.width):
                    q = p[x, y]
                    if q[3]:
                        p[x, y] = (q[0] * c[0] // 255, q[1] * c[1] // 255, q[2] * c[2] // 255, 255)
            rows.append((name, t))
    preview(rows, os.path.join(ROOT, "tools", "ink_fx_preview.png"), scale=2, bg=(48, 56, 52, 255))
    print("ok")


main()
