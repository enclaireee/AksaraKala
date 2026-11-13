#!/usr/bin/env python3
"""Tiny pixel-art toolkit for Budayago sprite generators.

Author a sprite as ASCII rows + a palette dict ('.' is clear), then:
  img = sprite(rows, pal)           # fill only, no outline
  img = outline(img)                # 1 px selective outline (darkened neighbour color)
  frames = enemy_frames(img, ...)   # idle/walk/telegraph/hurt 4x4 sheet
Sheets are saved to assets/art/... by the caller.
"""
import os
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART = os.path.join(ROOT, "assets", "art")


def hexc(s, a=255):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), a)


def shade(c, f):
    """f<1 darkens, f>1 lightens (toward white)."""
    r, g, b, a = c
    if f <= 1:
        return (int(r * f), int(g * f), int(b * f), a)
    t = f - 1
    return (int(r + (255 - r) * t), int(g + (255 - g) * t), int(b + (255 - b) * t), a)


def ramp(base):
    """(hi, mid, shd, deep) from one mid color. Shadows shift slightly cool."""
    r, g, b, a = base
    hi = shade(base, 1.35)
    shd = (int(r * 0.68), int(g * 0.66), int(b * 0.74), a)
    deep = (int(r * 0.42), int(g * 0.40), int(b * 0.52), a)
    return hi, base, shd, deep


def sprite(rows, pal, size=None):
    h = len(rows)
    w = max(len(r) for r in rows)
    if size:
        w, h = size
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch in (".", " "):
                continue
            if ch not in pal:
                raise KeyError(f"palette missing {ch!r} (row {y})")
            img.putpixel((x, y), pal[ch])
    return img


def pad(img, l=1, t=1, r=1, b=1):
    out = Image.new("RGBA", (img.width + l + r, img.height + t + b), (0, 0, 0, 0))
    out.paste(img, (l, t))
    return out


def outline(img, k=0.35, keep_pad=True):
    """Outer 1 px outline; colour = darkest adjacent fill * k. Adds a 1 px border."""
    src = pad(img) if keep_pad else img
    w, h = src.size
    px = src.load()
    out = src.copy()
    op = out.load()
    for y in range(h):
        for x in range(w):
            if px[x, y][3] > 0:
                continue
            best = None
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and px[nx, ny][3] > 0 and px[nx, ny][3] == 255:
                    c = px[nx, ny]
                    if best is None or sum(c[:3]) < sum(best[:3]):
                        best = c
            if best:
                r, g, b, _ = best
                op[x, y] = (int(r * k), int(g * k * 0.95), int(b * k * 1.1) if int(b * k * 1.1) < 255 else 255, 255)
    return out


def paste(dst, src, x, y):
    dst.alpha_composite(src, (x, y)) if (0 <= x and 0 <= y and x + src.width <= dst.width and y + src.height <= dst.height) else _clip_paste(dst, src, x, y)


def _clip_paste(dst, src, x, y):
    sp, dp = src.load(), dst.load()
    for sy in range(src.height):
        for sx in range(src.width):
            c = sp[sx, sy]
            if c[3] and 0 <= x + sx < dst.width and 0 <= y + sy < dst.height:
                d = dp[x + sx, y + sy]
                dp[x + sx, y + sy] = c if c[3] == 255 or d[3] == 0 else tuple(int(c[i] * c[3] / 255 + d[i] * (1 - c[3] / 255)) for i in range(3)) + (255,)


def shift(img, dx=0, dy=0):
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    _clip_paste(out, img, dx, dy)
    return out


def flip(img):
    return img.transpose(Image.FLIP_LEFT_RIGHT)


def crop_rows(img, y0, y1):
    return img.crop((0, y0, img.width, y1))


def tint(img, color, amt):
    out = img.copy()
    p = out.load()
    for y in range(out.height):
        for x in range(out.width):
            c = p[x, y]
            if c[3]:
                p[x, y] = tuple(int(c[i] * (1 - amt) + color[i] * amt) for i in range(3)) + (c[3],)
    return out


def squash(img, sy=1.0, sx=1.0):
    """Nearest-neighbour scale about the bottom-center; keeps canvas size."""
    w, h = img.size
    nw, nh = max(1, round(w * sx)), max(1, round(h * sy))
    s = img.resize((nw, nh), Image.NEAREST)
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    _clip_paste(out, s, (w - nw) // 2, h - nh)
    return out


def shear_top(img, dx):
    """Lean: move rows above the midline sideways (whole pixels), feet fixed."""
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    h = img.height
    for y in range(h):
        off = round(dx * (1 - y / max(1, h - 1)))
        row = img.crop((0, y, img.width, y + 1))
        _clip_paste(out, row, off, y)
    return out


def sheet(cell_w, cell_h, cols, rows):
    return Image.new("RGBA", (cell_w * cols, cell_h * rows), (0, 0, 0, 0))


def put(sh, col, row, frame, cell_w, cell_h):
    """Place a frame bottom-center in its cell (feet 1 px above the bottom)."""
    x = col * cell_w + (cell_w - frame.width) // 2
    y = row * cell_h + cell_h - frame.height - 1
    _clip_paste(sh, frame, x, y)


def enemy_frames(base, cell_w, cell_h, strike=None, windup=None, hurt=None,
                 idle=None, walk=None, bob=1, hover=False):
    """Standard enemy sheet: 4 cols x 4 rows.
    row0 idle, row1 walk, row2 telegraph (windup, windup, strike, strike), row3 hurt.
    Pass any of idle/walk (lists of 4 images), windup/strike/hurt (images) to override.
    The generic fallbacks are squash-and-stretch so even one base drawing animates."""
    sh = sheet(cell_w, cell_h, 4, 4)
    idl = idle or [base, shift(base, 0, -bob if hover else 0), squash(base, 1.0 + 0.0, 1.0) if hover else squash(base, 0.94, 1.04), base]
    if not idle and not hover:
        idl = [base, squash(base, 0.95, 1.03), squash(base, 0.92, 1.05), squash(base, 0.95, 1.03)]
    if not idle and hover:
        idl = [shift(base, 0, 0), shift(base, 0, -1), shift(base, 0, -2), shift(base, 0, -1)]
    if walk:
        wk = walk
    elif hover:
        wk = [shift(base, 0, -1), shift(shear_top(base, 1), 0, -2), shift(base, 0, -1), shift(shear_top(base, -1), 0, -2)]
    else:
        wk = [squash(base, 0.94, 1.03), shear_top(shift(base, 0, -1), 1), squash(base, 0.94, 1.03), shear_top(shift(base, 0, -1), -1)]
    wu = windup or tint(squash(base, 0.86, 1.08), (255, 120, 90, 255), 0.18)
    st = strike or shear_top(squash(base, 1.1, 0.94), 3)
    hu = hurt or tint(shift(shear_top(base, -2), -1, 0), (255, 255, 255, 255), 0.55)
    for i in range(4):
        put(sh, i, 0, idl[i], cell_w, cell_h)
        put(sh, i, 1, wk[i], cell_w, cell_h)
    for i, f in enumerate([wu, wu, st, st]):
        put(sh, i, 2, f, cell_w, cell_h)
    for i in range(4):
        put(sh, i, 3, hu if i < 2 else base, cell_w, cell_h)
    return sh


def save(img, rel):
    path = os.path.join(ART, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)
    return path


def preview(paths_and_images, out_path, scale=4, bg=(70, 96, 70, 255)):
    """Contact sheet: stacks sheets on a green-ish ground so you can eyeball contrast."""
    imgs = [i for _, i in paths_and_images]
    W = max(i.width for i in imgs) * scale + 8
    H = sum(i.height * scale + 8 for i in imgs) + 8
    out = Image.new("RGBA", (W, H), bg)
    y = 8
    for im in imgs:
        big = im.resize((im.width * scale, im.height * scale), Image.NEAREST)
        out.alpha_composite(big, (4, y))
        y += big.height + 8
    out.save(out_path)


# ---------------------------------------------------------------------------
# FX kit (art pass v8, assets.md 1 "FX standard").
# Draw FX once in KEY tones, then bake one PNG per class with bake_all().
# KEY tones double as the neutral base strip (pale, so runtime tint still works).
# ---------------------------------------------------------------------------
import math

PLUM = (30, 18, 34, 255)  # the one dark outline, same as the hero sheets

# Index tones: a = main colour (hi, mid, shd, deep), b = accent, w = hot core.
KEY = {
    "a0": (255, 255, 255, 255), "a1": (214, 226, 240, 255), "a2": (150, 170, 200, 255), "a3": (84, 96, 132, 255),
    "b0": (246, 238, 214, 255), "b1": (214, 198, 160, 255), "b2": (160, 140, 104, 255), "b3": (102, 86, 70, 255),
    "w": (255, 254, 250, 255), "o": PLUM,
}
A = [KEY["a0"], KEY["a1"], KEY["a2"], KEY["a3"]]
B = [KEY["b0"], KEY["b1"], KEY["b2"], KEY["b3"]]


def _r4(*hexes):
    return [hexc(h) for h in hexes]


# Per-class FX ramps from classes.md Palette (main a, accent b, hot core w).
CLASS_FX = {
    "warrior": {"a": _r4("FF9A7A", "D8402E", "962424", "561420"), "b": _r4("FFE6A0", "E2B64A", "A87A22", "6A4A14"), "w": hexc("FFF4DC")},
    "archer":  {"a": _r4("B8F0D0", "4FB08C", "2E7462", "1A4440"), "b": _r4("F2E2A0", "C8A458", "8E6E36", "5A4224"), "w": hexc("F4FFF0")},
    "rogue":   {"a": _r4("8A7C9C", "4A3E5A", "2C2438", "18121E"), "b": _r4("FF9A7A", "D8402E", "962424", "561420"), "w": hexc("FFE4D8")},
    "mage":    {"a": _r4("FFF8E6", "EADCB6", "B6A48A", "76687A"), "b": _r4("A8F4EC", "3CC4B4", "1E8480", "12504E"), "w": hexc("F0FFFC")},
    "lancer":  {"a": _r4("FFA08C", "D23A34", "8E2228", "52141C"), "b": _r4("FFFFFF", "E4E0D8", "A8A2A0", "6A6470"), "w": hexc("FFFFFF")},
    "herder":  {"a": _r4("FFF0B0", "E2C46A", "A88A3C", "6A5426"), "b": _r4("9CB4F0", "4A62B8", "2C3C7C", "1A2248"), "w": hexc("FFFCE8")},
    "dancer":  {"a": _r4("FFE8A0", "E2B64A", "A87A22", "6A4A14"), "b": _r4("FF9AD8", "D2408E", "8E2462", "52143C"), "w": hexc("FFF8E0")},
    "dalang":  {"a": _r4("A0A8F0", "4A4EA8", "2C2C6E", "181840"), "b": _r4("FFE8A0", "F0B848", "B07A22", "6A4414"), "w": hexc("FFF4D0")},
}
CLASSES = list(CLASS_FX)


def bake(img, cls):
    """Palette-swap KEY tones to one class's ramps. Alpha is kept, unknown colours pass through."""
    pal = CLASS_FX[cls]
    m = {KEY["w"][:3]: pal["w"][:3]}
    for i in range(4):
        m[KEY["a%d" % i][:3]] = pal["a"][i][:3]
        m[KEY["b%d" % i][:3]] = pal["b"][i][:3]
    out = img.copy()
    p = out.load()
    for y in range(out.height):
        for x in range(out.width):
            c = p[x, y]
            if c[3] and c[:3] in m:
                p[x, y] = m[c[:3]] + (c[3],)
    return out


def bake_all(img, rel):
    """Save `rel` (the neutral KEY strip) plus `<rel>_<class>.png` for all 8 classes. Returns [(path, img)]."""
    stem = rel[:-4] if rel.endswith(".png") else rel
    out = [(save(img, stem + ".png"), img)]
    for c in CLASSES:
        b = bake(img, c)
        out.append((save(b, "%s_%s.png" % (stem, c)), b))
    return out


def dot(img, x, y, c):
    x, y = int(round(x)), int(round(y))
    if 0 <= x < img.width and 0 <= y < img.height and c[3]:
        img.putpixel((x, y), c)


def lit(nx, ny, tones):
    """Pick a tone for a surface normal: top-left is lit (index 0), bottom-right is deep (last)."""
    d = (-nx - ny) * 0.7071  # 1 = facing the light
    n = len(tones)
    i = int(round((1 - d) / 2 * (n - 1)))
    return tones[max(0, min(n - 1, i))]


def blob(img, cx, cy, r, tones=None, wobble=0.0, seed=0):
    """Solid lit disc (optionally lumpy). No AA: a pixel is in or out."""
    tones = tones or A
    rnd = __import__("random").Random(seed)
    k = [rnd.uniform(-wobble, wobble) for _ in range(8)]
    for y in range(int(cy - r - 2), int(cy + r + 3)):
        for x in range(int(cx - r - 2), int(cx + r + 3)):
            dx, dy = x + 0.5 - cx, y + 0.5 - cy
            ang = math.atan2(dy, dx)
            rr = r * (1 + sum(k[j] * math.cos((j + 1) * ang) for j in range(len(k))) / 4)
            dd = math.hypot(dx, dy)
            if dd <= rr:
                nx, ny = (dx / rr, dy / rr) if rr else (0, 0)
                # rim reads darker, centre-top-left reads light
                dot(img, x, y, lit(nx, ny, tones) if dd > rr * 0.45 else tones[min(1, len(tones) - 1)] if (nx + ny) > -0.2 else tones[0])


def band(img, cx, cy, r, thick, a0=0, a1=360, tones=None, taper=False):
    """Chunky ring/arc band, `thick` px wide, lit per normal. taper=True thins it toward both ends (a smear)."""
    tones = tones or A
    span = (a1 - a0) % 360 or 360
    for y in range(int(cy - r - thick - 2), int(cy + r + thick + 3)):
        for x in range(int(cx - r - thick - 2), int(cx + r + thick + 3)):
            dx, dy = x + 0.5 - cx, y + 0.5 - cy
            dd = math.hypot(dx, dy)
            ang = math.degrees(math.atan2(dy, dx)) % 360
            t = ((ang - a0) % 360) / span
            if t > 1:
                continue
            w = thick * (math.sin(t * math.pi) ** 0.6 if taper else 1)
            if r - w / 2 <= dd <= r + w / 2 and w >= 1:
                u = (dd - (r - w / 2)) / max(w, 1)  # 0 inner edge, 1 outer edge
                nx, ny = dx / max(dd, 0.01), dy / max(dd, 0.01)
                c = lit(nx, ny, tones)
                if u > 0.75 and len(tones) > 2:
                    c = tones[min(len(tones) - 1, tones.index(c) + 1)]
                dot(img, x, y, c)


def crescent(img, cx, cy, r, thick, a0, a1, tones=None):
    """Weapon smear: a tapered arc band with a white-hot leading edge."""
    band(img, cx, cy, r, thick, a0, a1, tones, taper=True)


def spark(img, cx, cy, n, c=None):
    """Plus-shaped spark of arm length n (sparks are the one place 1 px lines are allowed)."""
    c = c or KEY["w"]
    for i in range(-n, n + 1):
        dot(img, cx + i, cy, c)
        dot(img, cx, cy + i, c)


def plum_outline(img):
    """1 px plum outline around opaque pixels, in place size (no padding)."""
    out = img.copy()
    p, o = img.load(), out.load()
    for y in range(img.height):
        for x in range(img.width):
            if p[x, y][3]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < img.width and 0 <= ny < img.height and p[nx, ny][3] == 255:
                    o[x, y] = PLUM
                    break
    return out


def tiled(tile, w, h):
    """Repeat a tile to fill w x h (for edge bands, fences, fills)."""
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    for y in range(0, h, tile.height):
        for x in range(0, w, tile.width):
            out.paste(tile, (x, y))
    return out


def strip(frames):
    """Join equal frames left to right."""
    w, h = frames[0].size
    out = Image.new("RGBA", (w * len(frames), h), (0, 0, 0, 0))
    for i, f in enumerate(frames):
        out.paste(f, (i * w, 0))
    return out


def golden_burst(size=32, n=6):
    """The reference look every FX generator copies: impact burst, 6 frames.
    f0 hot core; f1-2 chunky lit ring (main ramp a) with an accent inner ring (ramp b), accent sparks,
    plum outline on f1-3; f3-5 the ring breaks into fat chunks that fade by stepping down the ramp."""
    c = size / 2
    frames = []
    for i in range(n):
        f = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        t = i / (n - 1)
        r = 4 + t * (size / 2 - 7)
        if i == 0:
            blob(f, c, c, 4, [KEY["w"], A[0], A[1]])
        elif i <= 2:
            band(f, c, c, r, 6 - i, tones=A)
            band(f, c, c, r - (6 - i) / 2 - 1, 2, tones=B[:3])
            blob(f, c, c, 3 - i, [KEY["w"], A[0]])
        else:  # broken ring: 5 fat chunks, tones step down each frame
            tones = A[i - 3:]
            for k in range(5):
                a = k * 72 + i * 12
                band(f, c, c, r, 4 if i < 5 else 3, a, a + 34 - (i - 3) * 6, tones=tones)
        if i in (1, 2, 3):
            for k in range(4):
                a = math.radians(45 + k * 90)
                spark(f, round(c + math.cos(a) * (r + 3)), round(c + math.sin(a) * (r + 3)), 2 if i < 3 else 1, B[0])
        frames.append(plum_outline(f) if i in (1, 2, 3) else f)
    return strip(frames)


if __name__ == "__main__":
    # Self-check + style reference preview (not a game asset): tools/fx_style_preview.png
    g = golden_burst()
    assert g.size == (192, 32)
    rows = [("key", g)] + [(c, bake(g, c)) for c in CLASSES]
    for name, im in rows[1:]:
        pal = CLASS_FX[name]
        ok = {c[:3] for c in pal["a"] + pal["b"] + [pal["w"], PLUM]}
        used = {c[:3] for c in (im.getpixel((x, y)) for y in range(im.height) for x in range(im.width)) if c[3]}
        assert used <= ok, (name, used - ok)
    preview(rows, os.path.join(ROOT, "tools", "fx_style_preview.png"), scale=4, bg=(48, 56, 52, 255))
    print("ok")
