"""vistalib: helpers for the region vista paintings (480x270 native, hard pixels, ordered dither, hue-shifted ramps)."""
import math
import os
import random
import sys

import numpy as np
from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
W, H = 480, 270
LW = 640          # width of a scrolling layer (480 + room for 4 s of pan at <= 30 px/s)


def hx(s, a=255):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), a)


def mix(a, b, p):
    return tuple(int(round(a[i] + (b[i] - a[i]) * p)) for i in range(4))


def _bayer(n):
    m = np.array([[0, 2], [3, 1]])
    while m.shape[0] < n:
        m = np.block([[4 * m, 4 * m + 2], [4 * m + 3, 4 * m + 1]])
    return (m + 0.5) / (n * n)


BY4 = _bayer(4)
BY8 = _bayer(8)


def bay(h, w, ox=0, oy=0, n=4):
    t = BY4 if n == 4 else BY8
    return np.tile(t, (h // n + 2, w // n + 2))[oy % n:oy % n + h, ox % n:ox % n + w]


def newl(w=LW, h=H):
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def arr(im):
    return np.array(im)


def img(a):
    return Image.fromarray(a.astype("uint8"), "RGBA")


# ---------------------------------------------------------------- noise
def noise2(w, h, cx, cy, seed):
    """smooth value noise 0..1 (cx, cy = feature size in px)."""
    r = np.random.default_rng(seed)
    g = r.random((h // cy + 3, w // cx + 3)).astype("float32")
    im = Image.fromarray(g, "F").resize(((w // cx + 3) * cx, (h // cy + 3) * cy), Image.BICUBIC)
    return np.clip(np.array(im)[:h, :w], 0, 1)


def fbm2(w, h, cx, cy, seed, oct=3):
    t, a, s = np.zeros((h, w), "float32"), 1.0, 0.0
    for o in range(oct):
        t += a * noise2(w, h, max(1, cx >> o), max(1, cy >> o), seed + o * 17)
        s += a
        a *= 0.5
    return t / s


def noise1(n, cell, seed, oct=3):
    return fbm2(n, 1, cell, 1, seed, oct)[0] - 0.5 if False else (fbm2(n, 4, cell, 4, seed, oct)[1] - 0.5)


# ---------------------------------------------------------------- gradients
def gradient(w, h, cols, v=None, steps=4):
    """banded + ordered-dither gradient. v: (h,w) array in 0..1 (default top->bottom). cols: hex strings."""
    c = np.array([hx(s) for s in cols], "uint8")
    n = len(c)
    if v is None:
        v = np.repeat((np.arange(h)[:, None] / max(1, h - 1)), w, 1)
    f = np.clip(v, 0, 1) * (n - 1)
    i = np.minimum(np.floor(f).astype(int), n - 2)
    fr = np.round((f - i) * steps) / steps
    pick = (bay(h, w) < fr).astype(int)
    return img(c[i + pick])


def fill_below(im, prof, col, rim=None, rim2=None, haze=None, haze_h=6):
    """fill everything under a 1-D profile (y per x). rim = 1 px top colour, haze = dithered lighter band under rim."""
    a = arr(im)
    h, w = a.shape[:2]
    p = np.round(prof).astype(int)
    yy = np.arange(h)[:, None]
    m = yy >= p[None, :w]
    a[m] = col
    if haze is not None:
        hm = m & (yy < p[None, :w] + haze_h)
        fr = 1 - (yy - p[None, :w]) / haze_h
        hm &= bay(h, w) < fr * 0.8
        a[hm] = haze
    if rim is not None:
        a[(yy == p[None, :w])] = rim
    if rim2 is not None:
        a[(yy == p[None, :w] + 1) & (bay(h, w) < 0.5)] = rim2
    return img(a)


def comp(base, top, x=0, y=0):
    base.alpha_composite(top, (x, y))


def rim_light(im, col, dx=-1, dy=-1, mask_col=None, every=1):
    """1 px rim on the lit side of any opaque shape (pixel opaque, neighbour at (dx,dy) transparent)."""
    a = arr(im)
    al = a[..., 3] > 0
    sh = np.zeros_like(al)
    ys, xs = slice(max(0, -dy), a.shape[0] - max(0, dy)), slice(max(0, -dx), a.shape[1] - max(0, dx))
    yd, xd = slice(max(0, dy), a.shape[0] + min(0, dy)), slice(max(0, dx), a.shape[1] + min(0, dx))
    nb = np.zeros_like(al)
    nb[ys, xs] = al[yd, xd]
    edge = al & ~nb
    a[edge] = col
    return img(a)


def outline_alpha(im, col, outer=True):
    a = arr(im)
    al = a[..., 3] > 0
    nb = np.zeros_like(al)
    nb[1:] |= al[:-1]
    nb[:-1] |= al[1:]
    nb[:, 1:] |= al[:, :-1]
    nb[:, :-1] |= al[:, 1:]
    e = nb & ~al
    a[e] = col
    return img(a)


def tex(im, mask_alpha, col, noise, thr, soft=0.07, dither=True):
    """recolour opaque pixels where noise>thr (soft ordered-dither edge) with col."""
    a = arr(im)
    h, w = a.shape[:2]
    op = a[..., 3] > 0
    if dither:
        f = np.clip((noise - thr) / soft + 0.5, 0, 1)
        m = bay(h, w) < f
    else:
        m = noise > thr
    a[op & m & mask_alpha] = col
    return img(a)


def dmask(im, mask, col, level=0.5, pat=None):
    """paint col on mask pixels with Bayer coverage `level` (0..1)."""
    a = arr(im)
    h, w = a.shape[:2]
    lv = level if isinstance(level, np.ndarray) else level
    m = mask & (bay(h, w) < lv)
    a[m] = col
    return img(a)


def poly_mask(pts, w=LW, h=H):
    m = Image.new("L", (w, h), 0)
    ImageDraw.Draw(m).polygon([tuple(p) for p in pts], fill=255)
    return np.array(m) > 0


def prof_pts(pts, n=LW, smooth=0):
    xs, ys = zip(*pts)
    p = np.interp(np.arange(n), xs, ys)
    for _ in range(smooth):
        q = np.pad(p, 2, mode="edge")
        p = (q[:-4] + 2 * q[1:-3] + 3 * q[2:-2] + 2 * q[3:-1] + q[4:]) / 9
    return p


def ridge(n, base, amp, seed, cell=48, oct=3):
    return base + noise1(n, cell, seed, oct) * amp


def spr(rows, pal):
    h = len(rows)
    w = max(len(r) for r in rows)
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = im.load()
    for y, r in enumerate(rows):
        for x, ch in enumerate(r):
            if ch not in ". ":
                px[x, y] = pal[ch]
    return im


def flip(im):
    return im.transpose(Image.FLIP_LEFT_RIGHT)


# ---------------------------------------------------------------- scrolling / wrap
def view(c, layer, off, y=0, wrap=False):
    off = int(off)
    if wrap:
        lw = layer.width
        off %= lw
        c.alpha_composite(layer.crop((off, 0, min(lw, off + W), layer.height)), (0, y))
        if off + W > lw:
            c.alpha_composite(layer.crop((0, 0, off + W - lw, layer.height)), (lw - off, y))
    else:
        c.alpha_composite(layer.crop((off, 0, off + W, layer.height)), (0, y))


def put(c, im, x, y):
    c.alpha_composite(im, (int(x), int(y))) if 0 <= x and 0 <= y and x + im.width <= c.width and y + im.height <= c.height \
        else _clip_put(c, im, int(x), int(y))


def _clip_put(c, im, x, y):
    sx, sy = max(0, -x), max(0, -y)
    ex, ey = min(im.width, c.width - x), min(im.height, c.height - y)
    if ex > sx and ey > sy:
        c.alpha_composite(im.crop((sx, sy, ex, ey)), (x + sx, y + sy))


def px(c, x, y, col):
    x, y = int(x), int(y)
    if 0 <= x < c.width and 0 <= y < c.height:
        c.putpixel((x, y), col)


# ---------------------------------------------------------------- clouds / mist (periodic, tile 480 or 640)
def cloud_band(w, h, thick, seed, col, col2=None, cell=70, floor=0.25, mid=None):
    """long thin pixel cloud strip: lens shapes with dithered ragged underside; periodic in x."""
    r = np.random.default_rng(seed)
    g = r.random((cell and 1, w // cell + 1)).astype("float32")
    g = np.concatenate([r.random(w // cell), ])  # one value per cell, periodic
    k = len(g)
    xs = np.arange(w)
    pos = xs / cell
    i0 = np.floor(pos).astype(int) % k
    i1 = (i0 + 1) % k
    f = pos - np.floor(pos)
    f = f * f * (3 - 2 * f)
    n = g[i0] * (1 - f) + g[i1] * f
    n = np.clip((n - floor) / (1 - floor), 0, 1)
    th = n * thick
    a = np.zeros((h, w, 4), "uint8")
    yy = np.arange(h)[:, None]
    cy = h // 2
    top = cy - th * 0.38
    bot = cy + th * 0.62
    body = (yy >= np.round(top)[None, :]) & (yy < np.round(bot)[None, :])
    a[body] = col
    if col2 is not None:      # lit upper edge / shaded under side
        a[body & (yy >= np.round(bot)[None, :] - np.maximum(1, th * 0.3)[None, :])] = col2
    fr = bay(h, w)
    ragged = (yy >= np.round(bot)[None, :]) & (yy < np.round(bot)[None, :] + 2) & (fr < 0.4) & (th[None, :] > 2)
    a[ragged] = col2 if col2 is not None else col
    return img(a)


def mist(w, h, seed, col, density=0.5, cell=60, ycell=14):
    """dithered rolling mist (periodic in x): ordered dither whose coverage follows soft noise."""
    r = np.random.default_rng(seed)
    gx = w // cell
    g = r.random((h // ycell + 3, gx)).astype("float32")
    g = np.concatenate([g, g[:, :3]], 1)
    big = Image.fromarray(g, "F").resize(((gx + 3) * cell, (h // ycell + 3) * ycell), Image.BICUBIC)
    n = np.array(big)[:h, :w]
    yy = np.arange(h)[:, None] / h
    prof = np.sin(np.clip(yy, 0, 1) * math.pi) ** 1.2
    cov = np.clip((n - (1 - density)) * 3, 0, 1) * prof
    cov = np.round(cov * 4) / 4
    m = bay(h, w) < cov
    a = np.zeros((h, w, 4), "uint8")
    a[m] = col
    return img(a)


# ---------------------------------------------------------------- creatures / particles
BIRD_UP = ["x.x", ".x."]
def bird(c, x, y, fr, col):
    """tiny 4-frame wing flap bird (3-5 px wide)."""
    x, y = int(x), int(y)
    f = fr % 4
    if f == 0:
        pts = [(-2, 1), (-1, 0), (0, 1), (1, 0), (2, 1)]
    elif f == 1:
        pts = [(-2, 0), (-1, 0), (0, 1), (1, 0), (2, 0)]
    elif f == 2:
        pts = [(-2, 0), (-1, 1), (0, 1), (1, 1), (2, 0)]
    else:
        pts = [(-2, 0), (-1, 0), (0, 1), (1, 0), (2, 0)]
    for dx, dy in pts:
        px(c, x + dx, y + dy, col)


def twinkle(c, stars, t, cols, speed=1.0):
    """stars: [(x, y, kind, phase)]; stepped twinkle."""
    for x, y, k, ph in stars:
        tw = int(t * 1.5 + ph) % 5
        lv = min(len(cols) - 1, max(0, k + (1 if tw == 0 else (-1 if tw == 2 else 0))))
        px(c, x, y, cols[lv])
        if k >= len(cols) - 2 and tw in (0, 1):
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                px(c, x + dx, y + dy, cols[max(0, lv - 2)])


def make_stars(seed, n, ymax, xmax=W):
    r = random.Random(seed)
    return [(r.randrange(xmax), int(ymax * r.random() ** 0.8), r.choices([0, 1, 2], [6, 3, 1])[0], r.random() * 9)
            for _ in range(n)]


def motes(c, t, seed, n, area, cols, speed=(4, 10), sway=4, up=True, off=0, wrapw=W):
    x0, y0, x1, y1 = area
    r = random.Random(seed)
    hgt = y1 - y0
    for _ in range(n):
        bx, by = r.random() * (x1 - x0) + x0, r.random() * hgt
        v, ph, f = r.uniform(*speed), r.random() * 6.28, r.uniform(0.4, 1.4)
        k = ((by + t * v) % hgt) / hgt
        y = y1 - 1 - int(k * hgt) if up else y0 + int(k * hgt)
        x = int(bx + math.sin(t * f + ph) * sway - off) % wrapw
        lv = min(len(cols) - 1, int(k * len(cols)))
        if k > 0.8 and BY4[y % 4, x % 4] < (k - 0.8) * 5:
            continue
        px(c, x, y, cols[lv])


def flicker(c, x, y, t, seed, cols):
    """firefly / lamp flicker: stepped on-off pattern."""
    ph = (int(t * 7) + seed) % 7
    if ph < 5:
        px(c, x, y, cols[0])
        if ph in (0, 1) and len(cols) > 1:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                px(c, x + dx, y + dy, cols[1])


def dither_vignette(c, col, strength=1.0, bottom=True):
    pass


def reflect(c, y_h, y_b, t, tint, mix_p=0.55, amp=1, period=2.2, squash=1, soft_rows=True):
    """water reflection below y_h: mirror of what is above, darkened toward tint, with row-wise ripple shifts."""
    a = np.array(c.convert("RGBA"))
    out = a.copy()
    tint = np.array(tint[:3], "float32")
    for y in range(y_h, y_b):
        d = (y - y_h) * squash
        sy = y_h - 1 - int(d)
        if sy < 0:
            break
        shift = int(round(math.sin(y * 0.9 + t * period * 2) * amp * (0.4 + (y - y_h) / 18.0)))
        row = np.roll(a[sy], shift, axis=0)
        k = mix_p + 0.25 * (y - y_h) / max(1, (y_b - y_h))
        row = row.astype("float32")
        row[:, :3] = row[:, :3] * (1 - k) + tint * k
        out[y] = row.astype("uint8")
    c.paste(Image.fromarray(out, "RGBA"))


def glints(c, y0, y1, t, seed, n, cols, x0=0, x1=W, length=(2, 5), period=1.3):
    """lapping water highlights: short horizontal dashes that blink in and out and drift."""
    r = random.Random(seed)
    for _ in range(n):
        x, y = r.randrange(x0, x1), r.randrange(y0, y1)
        ph, ln = r.random() * 9, r.randint(*length)
        k = int((t / period + ph)) % 4
        if k == 3:
            continue
        sx = int(math.sin(t * 0.8 + ph) * 2)
        col = cols[min(k, len(cols) - 1)]
        for i in range(ln - k):
            px(c, x + sx + i, y, col)


def save_preview(name, fn, times=(0.5, 2.0, 3.5), outdir=None):
    outdir = outdir or os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "out", "preview")
    os.makedirs(outdir, exist_ok=True)
    for i, t in enumerate(times):
        fn(t).convert("RGB").resize((W * 4, H * 4), Image.NEAREST).save(os.path.join(outdir, f"{name}_{i + 1}.png"))


def tone(im, noise, thr, soft, tint, k=0.3, dither=True):
    """mix opaque pixels toward `tint` by k where noise>thr (dithered edge): cloud shadows / glow patches."""
    a = arr(im)
    h, w = a.shape[:2]
    f = np.clip((noise - thr) / soft + 0.5, 0, 1)
    m = (bay(h, w) < f) & (a[..., 3] > 0)
    t_ = np.array(tint[:3], "float32")
    a[..., :3][m] = (a[..., :3][m] * (1 - k) + t_ * k).astype("uint8")
    return img(a)


def shift_mask(m, dx, dy):
    o = np.zeros_like(m)
    h, w = m.shape
    ys, xs = slice(max(0, dy), h + min(0, dy)), slice(max(0, dx), w + min(0, dx))
    yd, xd = slice(max(0, -dy), h + min(0, -dy)), slice(max(0, -dx), w + min(0, -dx))
    o[ys, xs] = m[yd, xd]
    return o


def shaded(im, mask, mid, lit=None, shade=None, deep=None, dx=-2, dy=-2, t_lit=3, t_sh=4, dither=True):
    """paint a mask as a 3-tone lit/mid/shade volume: light from (dx,dy) direction."""
    a = arr(im)
    h, w = mask.shape
    a[mask] = mid
    if lit is not None:
        inner = shift_mask(mask, -dx * t_lit // 2 or 0, -dy * t_lit // 2 or 0)
        edge = mask & ~shift_mask(mask, -dx, -dy)           # pixels whose light-side neighbour is empty
        # grow the lit band inward by repeated shifts
        band = np.zeros_like(mask)
        cur = mask.copy()
        for i in range(t_lit):
            cur = cur & shift_mask(cur, -dx, -dy) if False else cur
        m2 = mask.copy()
        lit_m = np.zeros_like(mask)
        for i in range(1, t_lit + 1):
            lit_m |= mask & ~shift_mask(mask, int(np.sign(-dx)) * i, int(np.sign(-dy)) * i)
        if dither:
            lit_m &= (bay(h, w) < 0.85) | ~shift_mask(mask, int(np.sign(-dx)), int(np.sign(-dy)))
        a[lit_m] = lit
    if shade is not None:
        sh_m = np.zeros_like(mask)
        for i in range(1, t_sh + 1):
            sh_m |= mask & ~shift_mask(mask, int(np.sign(dx)) * i, int(np.sign(dy)) * i)
        if dither:
            sh_m &= (bay(h, w) < 0.8) | ~shift_mask(mask, int(np.sign(dx)), int(np.sign(dy)))
        a[sh_m] = shade
    return img(a)


def circles_mask(circles, w, h):
    m = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(m)
    for cx, cy, rx, ry in circles:
        d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=255)
    return np.array(m) > 0


def cumulus(w, h, seed, cols, flat=0.5, n=9, rmax=None):
    """a pixel cumulus: bumpy ellipses on a flat base, lit top-left, shaded under side. cols = (lit, mid, shade)."""
    r = random.Random(seed)
    rmax = rmax or h // 2
    cs = []
    base = int(h * 0.78)
    for i in range(n):
        cx = int(w * (0.12 + 0.76 * i / (n - 1)) + r.randint(-4, 4))
        mid = 1 - abs(i / (n - 1) - 0.5) * 2
        ry = int(rmax * (0.35 + 0.65 * mid) * r.uniform(0.6, 1.1))
        rx = int(ry * r.uniform(1.1, 1.6))
        cs.append((cx, base - int(ry * 0.7), rx, ry))
    m = circles_mask(cs, w, h)
    m[base + 1:] = False
    im = newl(w, h)
    im = shaded(im, m, cols[1], cols[0], cols[2], None, -1, -1, 3, 3)
    yy = np.arange(h)[:, None]
    lowm = m & (yy > base - h * 0.22)
    im = dmask(im, lowm, cols[2], np.clip((yy - (base - h * 0.22)) / (h * 0.22), 0, 1) * 0.9)
    return im
