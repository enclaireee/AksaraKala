"""Title scene art (ui.md 4.1 v4), imported by tools/gen_ui_dusk.py, which stays the one UI art entry point.

A softer, painterly dusk: smooth gradients finished with a fine ordered dither (no hard colour bands), no black
outlines, and every layer pushed into the haze by its distance. The ruins live in the world, not on the hero's cliff:
temples on the far mountains, a terraced candi and a split gate on the middle range, a broken temple and colonnade
down in the misty valley, and broken pillars, a fallen column and a stone lantern along the bottom of the frame.
The Wiku's outcrop on the right is natural rock, grass and a great tree.

  title_sky   480x270  the sky alone (shared by every full-screen screen through UIFx.sky)
  title_far   480x270  sun glow, rays, three mountain ranges with ruins, mist, the valley with its ruins and river
  title_near  480x270  the cliff and tree on the right, the foreground ruins along the bottom
  PILLAR_GLYPH_AT       where the carved aksara sits on the foreground pillar (title.gd places the breathing glyph there)
"""
import math

import numpy as np
from PIL import Image

W, H = 480, 270
SUN = (318.0, 202.0)
CLIFF_TOP = 214            # the Wiku's feet (title.gd HERO_POS + 24)
PILLAR_GLYPH_AT = (244, 218)   # top-left of title_pillar_glyph on the foreground pillar

BAYER = (np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) + 0.5) / 16.0


def c(h):
    h = h.lstrip("#")
    return np.array([int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)], float)


HAZE = c("E8946A")        # the warm horizon haze everything recedes into
HAZE_HI = c("FFD2A0")
DUSK = c("6B3A5E")


def bayer():
    return np.tile(BAYER, (H // 4 + 1, W // 4 + 1))[:H, :W]


def finish(rgb, a=None, step=6.0):
    """Float image -> RGBA. Colours snap to `step` levels per channel with an ordered dither between them, so the
    gradients stay pixel art (a fine stipple, not bands) without looking sharp."""
    d = bayer()[..., None]
    q = np.floor(np.clip(rgb, 0, 255) / step + d) * step
    out = np.zeros((H, W, 4), np.uint8)
    out[..., :3] = np.clip(q, 0, 255).astype(np.uint8)
    if a is None:
        out[..., 3] = 255
    else:
        aq = np.floor(np.clip(a, 0, 1) * 8 + bayer()) / 8.0   # alpha in 8 dithered steps
        out[..., 3] = (np.clip(aq, 0, 1) * 255).astype(np.uint8)
    return Image.fromarray(out, "RGBA").copy()


def noise1(n, seed, scale):
    r = np.random.default_rng(seed)
    k = n // scale + 3
    g = r.standard_normal(k)
    x = np.arange(n) / scale
    i = x.astype(int)
    f = x - i
    f = f * f * (3 - 2 * f)
    return g[i] * (1 - f) + g[i + 1] * f


def fbm1(n, seed, scale, oct_=4):
    v, a, s = np.zeros(n), 1.0, scale
    for o in range(oct_):
        v += noise1(n, seed + o * 31, max(1, int(s))) * a
        a *= 0.5
        s /= 2.0
    return v


def noise2(seed, sx, sy):
    r = np.random.default_rng(seed)
    gh, gw = int(H / sy) + 3, int(W / sx) + 3
    g = r.random((gh, gw))
    yy, xx = np.mgrid[0:H, 0:W]
    fy, fx = yy / sy, xx / sx
    y0, x0 = fy.astype(int), fx.astype(int)
    ty, tx = fy - y0, fx - x0
    ty, tx = ty * ty * (3 - 2 * ty), tx * tx * (3 - 2 * tx)
    a = g[y0, x0] * (1 - tx) + g[y0, x0 + 1] * tx
    b = g[y0 + 1, x0] * (1 - tx) + g[y0 + 1, x0 + 1] * tx
    return a * (1 - ty) + b * ty


def over(dst_rgb, dst_a, rgb, a):
    a = np.clip(a, 0, 1)[..., None]
    out_a = a[..., 0] + dst_a * (1 - a[..., 0])
    num = rgb * a + dst_rgb * dst_a[..., None] * (1 - a)
    out = np.where(out_a[..., None] > 0, num / np.maximum(out_a[..., None], 1e-6), 0)
    return out, out_a


# ---------------------------------------------------------------------------------------------------------------- sky

SKY_STOPS = [(0.0, c("1B1433")), (0.18, c("2A1D47")), (0.36, c("442A5C")), (0.52, c("6B3A5E")),
             (0.66, c("9A4C66")), (0.78, c("C9636A")), (0.88, c("E8946A")), (1.0, c("F6BE84"))]


def gradient(t, stops):
    t = np.clip(t, 0, 1)
    out = np.zeros(t.shape + (3,))
    for (t0, c0), (t1, c1) in zip(stops, stops[1:]):
        m = (t >= t0) & (t <= t1)
        k = ((t - t0) / (t1 - t0))[m][..., None]
        out[m] = c0 * (1 - k) + c1 * k
    return out


def sky():
    yy, xx = np.mgrid[0:H, 0:W].astype(float)
    t = (yy / 214.0) ** 1.15
    rgb = gradient(t, SKY_STOPS)
    # the sky warms toward the sun, faintly, so every screen sharing it has the same light
    d = np.sqrt(((xx - SUN[0]) / 1.8) ** 2 + (yy - SUN[1]) ** 2)
    rgb += (HAZE_HI - rgb) * (np.clip(1 - d / 210, 0, 1) ** 2.2 * 0.35)[..., None]
    # long thin clouds lit from below
    cl = noise2(3, 90, 5)
    band = np.exp(-((yy - 150) / 26) ** 2) * np.clip((cl - 0.55) * 4, 0, 1)
    rgb += (c("F2A27A") - rgb) * (band * 0.35)[..., None]
    band2 = np.exp(-((yy - 92) / 18) ** 2) * np.clip((noise2(8, 120, 4) - 0.6) * 4, 0, 1)
    rgb += (c("8E4D78") - rgb) * (band2 * 0.3)[..., None]
    img = finish(rgb)
    px = img.load()
    r = np.random.default_rng(11)
    for _ in range(170):   # dim fixed stars (the twinkling ones are sprites in the game)
        x, y = int(r.integers(0, W)), int(r.random() ** 1.8 * 130)
        k = r.choice([0.3, 0.45, 0.7]) * (1 - y / 150)
        p = px[x, y]
        px[x, y] = tuple(int(p[i] + (244 - p[i]) * k) for i in range(3)) + (255,)
    return img


# ---------------------------------------------------------------------------------------------------------------- ranges

def ridge(base, peaks, seed, rough, scale=40):
    """Ridge line y(x): a base line, raised by peaks (x, top, half-width, sharpness), roughened by noise."""
    x = np.arange(W, dtype=float)
    y = base + fbm1(W, seed, scale) * rough
    for px_, top, hw, k in peaks:
        d = np.clip(np.abs(x - px_) / hw, 0, 1)
        prof = (1 - d) ** k
        y = np.minimum(y, base - (base - top) * prof + fbm1(W, seed + int(px_), 9, 2) * rough * 0.4 * (1 - prof))
    return y


def mountain(y_top, peaks, body, lit, shade, haze, seed, crest=None):
    """Crisp pixel-art mountains: flat colours, hard edges. Each peak is split down a jagged spine: the face toward
    the sun is lit, the far face in shadow, a 1 px highlight runs along the lit crest. The whole range then takes
    one flat amount of haze for its distance (no gradients inside a range)."""
    yy, xx = np.mgrid[0:H, 0:W].astype(float)
    top = np.round(y_top)[None, :]
    a = (yy >= top).astype(float)
    rgb = np.broadcast_to(body, (H, W, 3)).copy()
    r = np.random.default_rng(seed)
    if peaks:
        # which peak owns each column: the nearest one, measured in half-widths
        own = np.argmin([np.abs(np.arange(W) - p[0]) / p[2] for p in peaks], axis=0)
        jag = np.cumsum(r.choice([-1, 0, 0, 1], size=H)) * 0.6
        for i, (px_, ptop, hw, _) in enumerate(peaks):
            side = 1.0 if SUN[0] >= px_ else -1.0
            spine = px_ + (yy - ptop) * 0.28 * side + jag[:, None] * 0.5   # the spine leans away from the light
            mine = (own[None, :] == i) & (a > 0)
            lit_face = mine & ((xx - spine) * side > 0)
            dark_face = mine & ((xx - spine) * side < -hw * 0.55)
            rgb[lit_face] = lit
            rgb[dark_face] = shade
            # a couple of secondary ridges on the lit face: thin shadow lines running down and out
            for k in (0.35, 0.65):
                sx = px_ + side * hw * k
                sy = ptop + (base_at(y_top, int(sx)) - ptop) * 0.3
                line = mine & (np.abs((xx - sx) - (yy - sy) * 0.5 * side) < 0.6) & (yy > sy) & (yy < sy + hw * 0.5)
                rgb[line] = body
    if crest is not None:   # the lit crest line
        edge = (yy == top) & (a > 0)
        rgb[edge] = crest
    rgb += (HAZE - rgb) * haze
    return rgb, a


def base_at(y_top, x):
    return float(y_top[max(0, min(W - 1, x))])


def mist(y0, thick, col, strength, seed):
    """A soft band of mist lying at y0 (array over x or scalar), thickest at its middle."""
    yy, xx = np.mgrid[0:H, 0:W].astype(float)
    y0 = np.broadcast_to(np.asarray(y0, float), (W,))[None, :]
    n = noise2(seed, 50, 6)
    a = np.exp(-((yy - y0) / thick) ** 2) * strength * (0.6 + 0.8 * n)
    return np.broadcast_to(col, (H, W, 3)).copy(), np.clip(a, 0, 1)


# ---------------------------------------------------------------------------------------------------------------- ruins (as masks on the canvas)

def m_rect(m, x0, y0, x1, y1):
    m[max(0, int(y0)):max(0, int(y1)), max(0, int(x0)):max(0, int(x1))] = 1


def candi(m, cx, base, s, broken=0.0, seed=0):
    """A Javanese stepped temple: plinth, body with a doorway, tiered roof to a finial. `broken` cuts the top away
    along a slanting line (0 = whole)."""
    tiers = [(9, 2), (8, 2), (6, 6), (7, 1), (5, 3), (4, 2), (3, 2), (2, 2), (1, 3)]
    y = base
    for hw, th in tiers:
        m_rect(m, cx - hw * s, y - th * s, cx + hw * s + 1, y)
        y -= th * s
    m[int(base - 9 * s):int(base - 2 * s), int(cx - 1.2 * s):int(cx + 1.2 * s) + 1] = 0   # doorway
    if broken:
        r = np.random.default_rng(seed)
        top = base - sum(t for _, t in tiers) * s
        for x in range(int(cx - 10 * s), int(cx + 10 * s) + 1):
            if 0 <= x < W:
                cut = top + (base - top) * broken + (x - cx) * 0.6 + r.integers(-1, 2)
                m[:max(0, int(cut)), x] = 0


def stupa_mountain(m, cx, base, s):
    """A terraced candi in the Borobudur manner: square terraces, a ring of small stupas, the great stupa on top."""
    y = base
    for hw, th in [(26, 3), (22, 3), (18, 3), (14, 2), (11, 2)]:
        m_rect(m, cx - hw * s, y - th * s, cx + hw * s + 1, y)
        y -= th * s
    for k in (-9, -5, 0, 5, 9):   # small stupas on the top terrace
        sx = cx + k * s
        m_rect(m, sx - 1.2 * s, y - 2 * s, sx + 1.2 * s + 1, y)
        m_rect(m, sx - 0.3 * s, y - 3 * s, sx + 0.3 * s + 1, y - 2 * s)
    yy, xx = np.mgrid[0:H, 0:W]
    m[((xx - cx) / (4.5 * s)) ** 2 + ((yy - (y - 1 * s)) / (4 * s)) ** 2 <= 1] = 1   # the great stupa
    m_rect(m, cx - 0.5 * s, y - 7.5 * s, cx + 0.5 * s + 1, y - 3 * s)


def split_gate(m, cx, base, s, gap=3):
    """A candi bentar: one gate split clean down the middle, the two halves stepped."""
    for side in (-1, 1):
        x_in = cx + side * gap * s
        y = base
        for wd, th in [(7, 3), (6, 4), (5, 4), (4, 3), (3, 3), (2, 2), (1, 2)]:
            x0, x1 = sorted((x_in, x_in + side * wd * s))
            m_rect(m, x0, y - th * s, x1 + 1, y)
            y -= th * s


def spires(m, cx, base, s):
    """Prambanan-like: a tall central spire flanked by two lower ones."""
    for dx, hgt, wd in [(-9, 22, 4), (0, 34, 6), (9, 22, 4)]:
        x = cx + dx * s
        for k in range(int(hgt * s)):
            hw = wd * s * (1 - k / (hgt * s)) ** 0.8 + 0.5
            m_rect(m, x - hw, base - k - 1, x + hw + 1, base - k)
    m_rect(m, cx - 14 * s, base - 3 * s, cx + 14 * s + 1, base)


def colonnade(m, x0, base, s, heights, lintel=None):
    for i, h_ in enumerate(heights):
        x = x0 + i * 7 * s
        m_rect(m, x, base - h_ * s, x + 3 * s + 1, base)
        m_rect(m, x - 1, base - 2 * s, x + 3 * s + 2, base)
    if lintel:
        a, b, h_ = lintel
        m_rect(m, x0 + a * 7 * s - 1, base - h_ * s - 3 * s, x0 + b * 7 * s + 3 * s + 2, base - h_ * s)


def paint_mask(m, body, lit, haze, lit_dir=(-1, 0)):
    """Colour a ruin mask: flat body, its sun-facing and top edges lit, pushed into the haze by `haze`."""
    rgb = np.broadcast_to(body, (H, W, 3)).copy()
    mb = m.astype(bool)
    top_edge = mb & ~np.roll(mb, 1, axis=0)
    side_edge = mb & ~np.roll(mb, -lit_dir[0], axis=1) if lit_dir[0] else np.zeros_like(mb)
    rgb[top_edge | side_edge] = lit
    rgb += (HAZE - rgb) * haze
    return rgb, mb.astype(float)


# ---------------------------------------------------------------------------------------------------------------- far

def far():
    rgb = np.zeros((H, W, 3))
    a = np.zeros((H, W))
    yy, xx = np.mgrid[0:H, 0:W].astype(float)

    # the sun's glow and a fan of soft rays
    d = np.sqrt(((xx - SUN[0]) / 1.5) ** 2 + (yy - SUN[1]) ** 2)
    rgb, a = over(rgb, a, np.broadcast_to(HAZE_HI, (H, W, 3)), np.clip(1 - d / 150, 0, 1) ** 2.4 * 0.7)
    ang = np.arctan2(yy - SUN[1], xx - SUN[0])
    rays = (np.sin(ang * 13 + 0.7) * 0.5 + 0.5) ** 8 * (yy < SUN[1]) * np.clip(1 - d / 300, 0, 1) * 0.22
    rgb, a = over(rgb, a, np.broadcast_to(c("FFE2BC"), (H, W, 3)), rays)
    sun = ((xx - SUN[0]) ** 2 + (yy - SUN[1]) ** 2) <= 15 ** 2
    rgb, a = over(rgb, a, np.broadcast_to(c("FFF1D0"), (H, W, 3)), sun * 0.9)

    # range A: the far volcanoes, almost haze. A twin-spired temple on the left summit.
    pa = [(304, 92, 120, 1.5), (204, 128, 70, 1.4), (452, 114, 66, 1.5)]
    ya = ridge(160, pa, 1, 2.5)
    ya[(np.arange(W) > 298) & (np.arange(W) < 310)] = 94   # the crater rim
    m_rgb, m_a = mountain(ya, pa, c("9C5478"), c("E59A86"), c("85466E"), 0.38, 10, crest=c("FFD2A0"))
    rgb, a = over(rgb, a, m_rgb, m_a)
    ruins = np.zeros((H, W))
    spires(ruins, 204, int(ya[204]) + 3, 0.9)
    candi(ruins, 452, int(ya[452]) + 2, 1.0)
    r_rgb, r_a = paint_mask(ruins, c("8A4A6E"), c("FFC896"), 0.38)
    rgb, a = over(rgb, a, r_rgb, r_a)
    rgb, a = over(rgb, a, *mist(ya.mean() + 26, 16, HAZE, 0.55, 2))

    # range B: the middle hills. The terraced candi on the central hill, a split gate on the left ridge.
    pb = [(250, 146, 70, 1.3), (82, 150, 64, 1.4), (400, 158, 60, 1.4)]
    yb = ridge(184, pb, 3, 3)
    m_rgb, m_a = mountain(yb, pb, c("6E3660"), c("C46A70"), c("562A52"), 0.16, 20, crest=c("F6B07E"))
    rgb, a = over(rgb, a, m_rgb, m_a)
    ruins = np.zeros((H, W))
    stupa_mountain(ruins, 250, int(yb[250]) + 3, 1.0)
    split_gate(ruins, 82, int(yb[82]) + 2, 1.0)
    candi(ruins, 168, int(yb[168]) + 3, 0.9, broken=0.45, seed=4)
    r_rgb, r_a = paint_mask(ruins, c("5E2E58"), c("F6B07E"), 0.2)
    rgb, a = over(rgb, a, r_rgb, r_a)
    rgb, a = over(rgb, a, *mist(yb + 22, 12, c("D27268"), 0.6, 4))

    # range C: forested hills above the valley, a canopy edge of soft bumps
    yc = ridge(200, [(140, 186, 90, 1.2), (330, 190, 90, 1.2)], 5, 3)
    canopy = noise1(W, 77, 3) * 1.6 + noise1(W, 78, 7) * 1.2
    yc = yc - np.clip(canopy, -1, 3)
    m_rgb, m_a = mountain(yc, [], c("452650"), None, None, 0.05, 30, crest=c("B5566A"))
    rgb, a = over(rgb, a, m_rgb, m_a)
    rgb, a = over(rgb, a, *mist(yc + 14, 9, c("B5566A"), 0.5, 6))

    # the valley floor: the river catches the sky, ruins stand half in the mist
    yv = np.full(W, 214.0) + fbm1(W, 9, 60) * 2
    vrgb = np.broadcast_to(c("3A2350"), (H, W, 3)).copy()
    vrgb += (c("B5566A") - vrgb) * (np.clip(1 - (yy - 214) / 40, 0, 1) * 0.45)[..., None]
    va = (yy >= yv[None, :]).astype(float)
    rgb, a = over(rgb, a, vrgb, va)
    river_x = SUN[0] - 40 * np.sin((yy - 214) / 18.0) - (yy - 214) * 3.2
    river = (np.abs(xx - river_x) < 1.5 + (yy - 214) * 0.12) & (yy >= 216)
    shimmer = (noise2(12, 6, 2) > 0.45)
    rgb, a = over(rgb, a, np.broadcast_to(c("F6BE84"), (H, W, 3)), (river & shimmer) * (0.75 - np.clip((yy - 214) / 120, 0, 0.5)))
    ruins = np.zeros((H, W))
    candi(ruins, 128, 222, 1.5, broken=0.38, seed=7)
    colonnade(ruins, 186, 222, 1.2, [24, 22, 15, 20, 9], lintel=(0, 1, 24))
    for x0, wd, ht in [(156, 8, 3), (178, 5, 3), (232, 9, 3), (104, 6, 2)]:
        m_rect(ruins, x0, 222 - ht, x0 + wd, 222)
    r_rgb, r_a = paint_mask(ruins, c("3E2248"), c("E08A80"), 0.12)
    rgb, a = over(rgb, a, r_rgb, r_a)
    rgb, a = over(rgb, a, *mist(226, 9, c("C9636A"), 0.55, 8))
    rgb, a = over(rgb, a, *mist(244, 14, c("8E4763"), 0.35, 9))
    return finish(rgb, a)


# ---------------------------------------------------------------------------------------------------------------- near

def _soft_shade(mask, body, rim, dark, seed, rim_dir=(-1, -1), tex=0.12):
    """Foreground stone / earth: body colour with a soft texture, a 2 px warm rim on the edges facing the light and
    a darker band on the far side; no outline."""
    mb = mask.astype(bool)
    rgb = np.broadcast_to(body, (H, W, 3)).copy()
    n = noise2(seed, 4, 4) - 0.5
    rgb *= (1 + n * tex)[..., None]
    dx, dy = rim_dir
    edge1 = mb & ~np.roll(np.roll(mb, -dy, 0), -dx, 1)
    edge2 = mb & ~np.roll(np.roll(mb, -2 * dy, 0), -2 * dx, 1) & ~edge1
    far1 = mb & ~np.roll(np.roll(mb, 2 * dy, 0), 2 * dx, 1)
    rgb[far1] = rgb[far1] * 0.75 + dark * 0.25
    rgb[edge2] = rgb[edge2] * 0.5 + rim * 0.5
    rgb[edge1] = rim
    return rgb, mb.astype(float)


def _tree(m_trunk, blobs, cx, base, top):
    for y in range(top, base):
        k = (y - top) / (base - top)
        hw = 3 + 4 * k ** 3
        x = cx + 3 * math.sin(y / 17.0)
        m_rect(m_trunk, x - hw, y, x + hw + 1, y + 1)
    for (bx, by, rx, ry) in blobs:
        yy, xx = np.mgrid[0:H, 0:W]
        m_trunk[((xx - bx) / rx) ** 2 + ((yy - by) / ry) ** 2 <= 1] = 2


def near():
    rgb = np.zeros((H, W, 3))
    a = np.zeros((H, W))
    yy, xx = np.mgrid[0:H, 0:W].astype(float)

    # --- the great tree on the right, behind the cliff edge: scalloped leaf clusters, lit on the sun side
    r = np.random.default_rng(41)
    tm = np.zeros((H, W))
    _tree(tm, [], 458, CLIFF_TOP - 4, 100)
    for (bx, by, rx) in [(468, 76, 30), (436, 94, 24), (472, 112, 20), (424, 70, 18), (452, 54, 20), (410, 96, 13),
                         (480, 136, 14), (446, 120, 14)]:
        for _ in range(int(rx * 1.6)):   # each cluster is a heap of small round leaf-balls
            ang, rad = r.random() * 6.283, r.random() ** 0.6 * rx
            cx, cy, cr = bx + math.cos(ang) * rad, by + math.sin(ang) * rad * 0.7, r.integers(4, 8)
            tm[((xx - cx) ** 2 + (yy - cy) ** 2) <= cr * cr] = 2
    canopy = tm == 2
    trunk = (tm == 1) & ~canopy
    c_rgb, _ = _soft_shade(canopy, c("2C2A44"), c("E0907A"), c("181428"), 42, rim_dir=(-1, -1), tex=0.0)
    lobe = noise2(44, 9, 9) > 0.55   # darker leaf masses inside the canopy
    c_rgb[canopy & lobe] = c_rgb[canopy & lobe] * 0.8
    tint = noise2(45, 14, 14) > 0.6   # touches of green where the light gets in
    c_rgb[canopy & tint & ~lobe] = c("3A4A4A")
    rgb, a = over(rgb, a, c_rgb, canopy.astype(float))
    t_rgb, _ = _soft_shade(trunk, c("2A1C30"), c("A0646A"), c("140E1C"), 43, rim_dir=(-1, 0), tex=0.2)
    rgb, a = over(rgb, a, t_rgb, trunk.astype(float))

    # --- the cliff: natural rock, a grassy top. The Wiku stands on the flat 352-420 at y 214.
    cm = np.zeros((H, W))
    t = CLIFF_TOP
    xs = np.arange(W)
    top = np.where(xs < 352, t + (np.clip(352 - xs, 0, None) / 56.0) ** 1.6 * 40, t - np.clip((xs - 420) / 60.0, 0, 1) * 8.0)
    top = top + fbm1(W, 51, 8, 2) * 0.8 * (xs < 352)
    cm[(yy >= top[None, :]) & (xx >= 290)] = 1
    r_rgb, _ = _soft_shade(cm, c("2E2140"), c("E08A80"), c("150F20"), 52, rim_dir=(-1, -1), tex=0.18)
    strata = (noise2(53, 40, 3) - 0.5) * 0.25
    r_rgb *= (1 + strata)[..., None]
    rgb, a = over(rgb, a, r_rgb, cm)
    # grass along the crest, tufts, a few flowers catching the light
    r = np.random.default_rng(54)
    crest = np.round(top).astype(int)
    for x in range(296, W):
        y = crest[x]
        if 0 <= y < H:
            g = c("5E6B46") if x > 330 else c("7A5A5A")
            for k in range(0, 3):
                if y + k < H:
                    rgb[y + k, x] = g * (1 - k * 0.18)
                    a[y + k, x] = 1
            for k in range(1, int(r.integers(1, 5))):
                if y - k >= 0 and r.random() < 0.7:
                    rgb[y - k, x] = c("4C5A40") if r.random() < 0.6 else c("6E7A4E")
                    a[y - k, x] = 1
            if r.random() < 0.035 and x > 340:
                rgb[y - 2, x] = c("F2B27A") if r.random() < 0.5 else c("E8D0F0")
                a[y - 2, x] = 1

    # --- foreground ruins along the bottom, dark, soft, rim-lit by the sun
    fm = np.zeros((H, W))
    # a tall broken pillar at the left edge
    m_rect(fm, 0, 160, 16, 270)
    m_rect(fm, 0, 156, 19, 162)
    for x in range(0, 20):
        fm[:160 + (x * 7) % 5 - (3 if x < 6 else 0), x] = 0
    # a fallen column lying across the left, and its drums
    for x in range(26, 118):
        y0 = 250 - (x - 26) * 0.12
        fm[int(y0):int(y0) + 11, x] = 1
    m_rect(fm, 122, 254, 136, 266)
    m_rect(fm, 140, 258, 150, 266)
    # the carved pillar standing in front of the valley (its aksara breathes in the game)
    m_rect(fm, 240, 206, 260, 270)
    m_rect(fm, 237, 202, 263, 208)
    m_rect(fm, 237, 244, 263, 249)
    for x in range(236, 264):   # broken top, higher on the right
        fm[:202 - int((x - 236) * 0.3) + (x * 3) % 3, x] = 0
    # a stone lantern
    for x0, y0, x1, y1 in [(196, 262, 212, 270), (200, 246, 208, 262), (194, 242, 214, 246), (197, 232, 211, 242),
                           (193, 228, 215, 232), (200, 223, 208, 228)]:
        m_rect(fm, x0, y0, x1, y1)
    # the ground they stand in: a low dark bank along the bottom
    gy = 258 + 3 * np.sin(xs / 13.0) + 2 * np.sin(xs / 5.0 + 1)
    fm[(yy >= gy[None, :]) & (xx < 300)] = 1
    f_rgb, _ = _soft_shade(fm, c("221833"), c("B5566A"), c("110B1C"), 61, rim_dir=(-1, -1), tex=0.14)
    # carved bands and drum joints
    for y in range(214, 270, 10):
        f_rgb[y, 242:258] *= 0.7
    for x in range(40, 118, 13):
        f_rgb[236:262, x] *= 0.7
    # the lantern's window glows faintly cyan
    f_rgb[235:239, 202:206] = c("3FB8C0")
    f_rgb[236:238, 203:205] = c("7FE8E0")
    rgb, a = over(rgb, a, f_rgb, fm)
    # moss on the pillars and grass tufts on the bank
    r = np.random.default_rng(62)
    for _ in range(260):
        x = int(r.integers(0, 300))
        y = int(gy[x]) - int(r.integers(0, 4))
        if 0 <= y < H:
            rgb[y, x] = c("3E4A3A") if r.random() < 0.6 else c("566A46")
            a[y, x] = 1
    for _ in range(120):
        x = int(r.choice([r.integers(0, 18), r.integers(240, 260)]))
        y = int(270 - r.random() ** 1.6 * 70)
        if 0 <= y < H and fm[y, x]:
            rgb[y, x] = c("3E4A3A") if r.random() < 0.5 else c("4C5A40")
    # a breath of haze over everything, so the foreground never goes pure black
    rgb += (c("3A2350") - rgb) * 0.12
    return finish(rgb, a, step=5.0)
