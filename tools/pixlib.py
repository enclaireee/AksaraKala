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
