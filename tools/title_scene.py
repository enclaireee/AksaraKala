"""Title scene art (ui.md 4.1 v4), imported by tools/gen_ui_dusk.py, which stays the one UI art entry point.
The layered ridges with their far candi and ruined temple (title_far) are still drawn by gen_ui_dusk.far().

  title_sky   480x270  a smooth dusk sky with a fine ordered dither, thin clouds, dim stars (shared by every
                       full-screen screen through UIFx.sky)
  title_near  480x270  the Wiku's outcrop (natural rock, grass, a great tree; no ruins on it) and, along the
                       bottom, a fallen column and a short broken pillar with the carved aksara
  PILLAR_GLYPH_AT       where the carved aksara sits on the foreground pillar (title.gd places the breathing glyph there)
"""
import math

import numpy as np
from PIL import Image

W, H = 480, 270
CLIFF_TOP = 214            # the Wiku's feet (title.gd HERO_POS + 24)
PILLAR_GLYPH_AT = (244, 218)   # top-left of title_pillar_glyph on the foreground pillar

BAYER = (np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) + 0.5) / 16.0


def c(h):
    h = h.lstrip("#")
    return np.array([int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)], float)




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


# ---------------------------------------------------------------------------------------------------------------- near

def m_rect(m, x0, y0, x1, y1):
    m[max(0, int(y0)):max(0, int(y1)), max(0, int(x0)):max(0, int(x1))] = 1


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
    # the ground they stand in: a low dark bank along the bottom
    gy = 258 + 3 * np.sin(xs / 13.0) + 2 * np.sin(xs / 5.0 + 1)
    fm[(yy >= gy[None, :]) & (xx < 300)] = 1
    f_rgb, _ = _soft_shade(fm, c("221833"), c("B5566A"), c("110B1C"), 61, rim_dir=(-1, -1), tex=0.14)
    # carved bands and drum joints
    for y in range(214, 270, 10):
        f_rgb[y, 242:258] *= 0.7
    for x in range(40, 118, 13):
        f_rgb[236:262, x] *= 0.7
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
        x = int(r.integers(240, 260))
        y = int(270 - r.random() ** 1.6 * 70)
        if 0 <= y < H and fm[y, x]:
            rgb[y, x] = c("3E4A3A") if r.random() < 0.5 else c("4C5A40")
    # a breath of haze over everything, so the foreground never goes pure black
    rgb += (c("3A2350") - rgb) * 0.12
    return finish(rgb, a, step=5.0)
