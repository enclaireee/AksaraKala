"""Region vista establishing shots (segment 3): six 4 s landscapes, slow parallax, ambient life. No text."""
import math
import random

import numpy as np
from PIL import Image, ImageDraw

from scenes import scene
from vistalib import *

DUR = 4.0


def finish(c, t, dur=DUR, fade_in=0.2, fade_out=0.2):
    from pxkit import dither_fade, NIGHT
    if fade_in and t < fade_in:
        c = dither_fade(c, NIGHT, 1 - t / fade_in)
    if fade_out and t > dur - fade_out:
        c = dither_fade(c, NIGHT, (t - (dur - fade_out)) / fade_out)
    return c.convert("RGB").convert("RGBA")


def sunglow(w, h, cx, cy, rx, ry=None):
    ry = ry or rx
    yy, xx = np.mgrid[0:h, 0:w]
    return np.clip(1 - np.sqrt(((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2), 0, 1)


def disc(im, cx, cy, r, cols):
    d = ImageDraw.Draw(im)
    for rr, col in zip(range(r, 0, -max(1, r // len(cols))), cols):
        d.ellipse((cx - rr, cy - rr, cx + rr, cy + rr), fill=col)


# ============================================================================ 1. SUNDA
def _sunda():
    HZ = 178
    sky_cols = ["#173f52", "#25606c", "#3f8488", "#79b0a0", "#b9d6b0", "#e6e3a8", "#f8e9ae"]
    yy = np.repeat(np.arange(H)[:, None] / HZ, W, 1)
    v = np.clip(yy, 0, 1) ** 1.25
    v = np.clip(v + sunglow(W, H, 96, 140, 200, 110) ** 1.6 * 0.45, 0, 1)
    sky = gradient(W, H, sky_cols, v)
    SX, SY = 96, 140
    d = ImageDraw.Draw(sky)
    for r, col in [(22, hx("f6e8a4")), (18, hx("faeeb0")), (15, hx("fff6cc"))]:
        d.ellipse((SX - r, SY - r, SX + r, SY + r), fill=col)
    stars = make_stars(4, 26, 60)
    clouds = []
    for y, thick, spd, seed in [(30, 7, 3, 1), (58, 10, 5, 2), (88, 9, 7, 3), (112, 6, 9, 4)]:
        clouds.append((cloud_band(480, 18, thick, seed, hx("d8ead0"), hx("9cc6b0"), cell=90, floor=0.3), y, spd))

    # far ridge (speed 4)
    far = newl()
    prof = prof_pts([(0, 166), (50, 158), (110, 160), (190, 170), (330, 170), (400, 160), (470, 152), (540, 158), (640, 166)], smooth=4)
    prof = prof + noise1(LW, 30, 8, 2) * 5
    far = fill_below(far, prof, hx("86b9a8"), rim=hx("d0e4b4"), haze=hx("a8d0b0"))

    # the mountain Tangkuban Perahu: the overturned boat (speed 6)
    O0 = 0
    pts = [(60, 178), (95, 172), (125, 161), (150, 147), (172, 131), (195, 116), (220, 105), (250, 98), (300, 96), (350, 95),
           (385, 93), (410, 91), (424, 95), (438, 108), (453, 124), (473, 140), (510, 156), (560, 170), (640, 178)]
    pts = [(x + O0, y) for x, y in pts]
    mp0 = prof_pts(pts, smooth=3)
    mp = mp0 + noise1(LW, 22, 11, 3) * 2.2
    p_i = np.round(mp).astype(int)
    yyL, xxL = np.mgrid[0:H, 0:LW]
    depth = yyL - p_i[None, :]
    m = fill_below(newl(), mp, hx("3f7f84"))
    a = arr(m)
    inside = a[..., 3] > 0
    slope = np.gradient(np.convolve(np.pad(mp0, 40, mode='edge'), np.ones(61) / 61, "same"))[40:-40]
    litf = np.clip(-slope[None, :] * 30, 0, 1)      # rising to the right = faces the sun on the left
    shf = np.clip(slope[None, :] * 14, 0, 1)
    ramp_ = np.clip(1.5 - depth / np.maximum(litf * 38 + 2, 1), 0, 1)
    a[inside & (depth < litf * 38 + 2) & (bay(H, LW) < ramp_) & (litf > 0.05)] = hx("7fb698")
    a[inside & (depth < litf * 15) & (litf > 0.1) & (bay(H, LW) < 0.55)] = hx("cfdc9c")
    tt = np.clip((xxL - 392 + depth * 0.45) / 22.0, 0, 1)
    a[inside & (bay(H, LW) < tt)] = hx("2b6068")
    m = img(a)
    allm = np.ones((H, LW), bool)
    m = tex(m, allm, hx("2f6c72"), fbm2(LW, H, 12, 6, 21, 3) + depth / 220.0, 0.80, 0.08)
    m = tex(m, allm, hx("5f9f88"), fbm2(LW, H, 10, 5, 33, 3) - depth / 100.0 - (shf * 0.3), 0.72, 0.07)
    a = arr(m)
    for x in range(LW):
        y = p_i[x]
        a[y, x] = hx("f4e6a4") if litf[0, x] > 0.12 else (hx("b6d8b4") if shf[0, x] < 0.1 else hx("5d9aa0"))
        if litf[0, x] > 0.3 and x % 2 == 0:
            a[y + 1, x] = hx("d7e19c")
    m = img(a)
    d = ImageDraw.Draw(m)
    r = random.Random(7)
    for _ in range(46):           # pine ticks on the skyline
        x = r.randrange(20, LW - 20)
        y = p_i[x] + 1
        d.line([(x, y), (x, y - r.choice([1, 2, 3]))], fill=hx("2f6c72"))
    # lake-side tree line (speed 8)
    shore = newl()
    sp = prof_pts([(0, 176), (60, 175), (130, 173), (200, 175), (300, 174), (380, 172), (460, 174), (640, 176)], smooth=2)
    sp = sp + noise1(LW, 14, 5, 2) * 3
    shore = fill_below(shore, sp, hx("356c66"), rim=hx("94bc90"))
    shore = tex(shore, allm, hx("2b5a58"), fbm2(LW, H, 7, 5, 9, 2), 0.55, 0.1)

    # knoll + julang-ngapak house (speed 14)
    kn = newl()
    kp = prof_pts([(190, 208), (218, 198), (246, 190), (280, 186), (318, 187), (346, 192), (370, 201), (392, 210)], smooth=3)
    kn_p = np.where((np.arange(LW) > 190) & (np.arange(LW) < 392), kp, 400)
    kn = fill_below(kn, kn_p, hx("2f6a56"), rim=hx("b6d88a"))
    a = arr(kn)
    ink = a[..., 3] > 0
    dk = yyL - kn_p[None, :]
    a[ink & (bay(H, LW) < 0.5) & (dk > 5)] = hx("245649")
    a[ink & (dk > 10)] = hx("1f4a43")
    kn = img(a)
    rows = []
    hw = [3, 4, 5, 6, 7, 8, 10, 13, 16, 18]
    for r_, h_ in enumerate(hw):
        row = ["."] * 40
        for x in range(20 - h_, 20 + h_):
            row[x] = "x"
        if r_ >= 8:       # upswept wing tips: carve a concave under-curve
            for x in range(20 - h_ + 3, 20 + h_ - 3):
                row[x] = "x"
        rows.append("".join(row))
    rows[8] = "." * 4 + "x" * 32 + "." * 4
    rows[9] = "x" + "x" * 2 + "." * 2 + "x" * 28 + "." * 2 + "x" * 2 + "x"
    rows.append("." * 6 + "d" * 28 + "." * 6)
    for _ in range(4):
        rows.append("." * 8 + "b" * 24 + "." * 8)
    rows[11] = "." * 8 + "b" * 9 + "l" * 6 + "b" * 9 + "." * 8
    rows[12] = rows[11]
    rows[13] = "." * 8 + "b" * 9 + "l" * 6 + "b" * 9 + "." * 8
    rows.append("." * 7 + "pp" + "." * 5 + "pp" + "." * 10 + "pp" + "." * 5 + "pp" + "." * 7)
    house = spr(rows, {"x": hx("3a4d44"), "d": hx("1d2a2a"), "b": hx("7a6340"), "l": hx("ffd77a"), "p": hx("2a2a24")})
    ha = arr(house)
    for y in range(10):
        xs = np.where(ha[y, :, 3] > 0)[0]
        if len(xs):
            ha[y, xs.min()] = hx("f0dc92")
            if y < 8:
                ha[y, xs.min() + 1] = hx("b8b074")
            ha[y, xs.max()] = hx("26362f")
    house = img(ha)
    HX, HY = 272, 171
    d = ImageDraw.Draw(kn)
    for cx, cy, rr in [(250, 180, 8), (258, 174, 7), (344, 182, 8), (352, 185, 6), (334, 187, 5)]:
        d.ellipse((cx - rr, cy - rr, cx + rr, cy + rr), fill=hx("23524a"))
        d.arc((cx - rr, cy - rr, cx + rr, cy + rr), 190, 290, fill=hx("86b878"))
    comp(kn, house, HX, HY)

    # foreground tea terraces (speed 22): smooth contour sweeps
    ta = np.zeros((H, LW, 4), "uint8")
    xs = np.arange(LW)
    bases = [214, 225, 238, 253, 270]
    rise = lambda x: 30 / (1 + np.exp(-(x - 360) / 70.0))
    edges = []
    for k, b in enumerate(bases):
        e = b - rise(xs) * (1 - k * 0.1) + np.sin(xs / (95 + k * 30.0) + k * 1.9) * (5 + k * 1.5)
        edges.append(np.round(e).astype(int))
    S = ["#7fb868", "#5fa25a", "#418648", "#2c6446", "#1d4a40"]
    SL = ["#d2e592", "#b0d27c", "#84bc68", "#56984f", "#3a7a50"]
    R = ["#2a6a58", "#22594c", "#1a4a42", "#143a3a", "#102e32"]
    for k in range(len(bases) - 1, -1, -1):
        e = edges[k]
        last = k + 1 == len(bases)
        for x in range(LW):
            y0 = e[x]
            y1 = H if last else edges[k + 1][x]
            hk = y1 - y0
            for y in range(max(0, y0), min(H, y1)):
                ta[y, x] = hx(R[k]) if (not last and y - y0 >= hk - 3) else hx(S[k])
            if 0 <= y0 < H:
                ta[y0, x] = hx(SL[k])
            for hr in (4, 8):
                yy_ = y0 + hr
                if hr < hk - 4 and 0 <= yy_ < H and (x + hr + k) % 4 < 3:
                    ta[yy_, x] = hx(SL[k]) if (x // 2) % 2 == 0 else hx(S[k])
                    if yy_ + 1 < H and (x + hr) % 4 < 3:
                        ta[yy_ + 1, x] = hx(R[k])
    ter = img(ta)
    vg = (1 - xxL / 420.0) * 0.55 + (yyL - 200) / 110.0
    ter = tone(ter, vg, 0.85, 0.35, hx('0e2a30'), 0.55)
    return dict(sky=sky, stars=stars, clouds=clouds, far=far, mtn=m, shore=shore, kn=kn, ter=ter, HX=HX, HY=HY, O0=O0, HZ=HZ)


def _bamboo(c, t, off, stalks):
    """stalks: [(x, top, lean, width)] in layer coords; rim-lit silhouettes with swaying leaf tufts."""
    for i, (x0, top, lean, wd) in enumerate(stalks):
        for y in range(top, H):
            x = int(x0 - off + (H - y) * lean)
            if x < -14 or x > W + 14:
                continue
            for k in range(wd):
                col = hx("9ed07a") if k == 0 else (hx("3f8460") if k == 1 else (hx("1f5446") if k < wd - 1 else hx("123a38")))
                px(c, x + k, y, col)
            if y % 19 == (top * 3 + i * 5) % 19:
                for k in range(-1, wd + 1):
                    px(c, x + k, y, hx("c6e890") if k < 1 else hx("0f302f"))
        for j, ly in enumerate(range(top + 4, top + 80, 16)):
            bx = int(x0 - off + (H - ly) * lean)
            sw = int(round(math.sin(t * 1.4 + i * 1.7 + j) * 1.3))
            for sgn in (-1, 1):
                for k in range(1, 12 - j):
                    yy_ = ly + int(k * 0.5) + (1 if k > 6 else 0) + (1 if k > 9 else 0)
                    xx_ = bx + (wd // 2) + sgn * k + sw
                    px(c, xx_, yy_ - 2, hx("8cc874") if k % 3 == 0 else hx("4a9460"))
                    px(c, xx_, yy_ - 1, hx("2a6a52"))
                    px(c, xx_, yy_, hx("133e3a"))


@scene("vista_sunda", DUR)
def vista_sunda(dur=DUR):
    S = _sunda()
    stalks = [(448, 34, -0.05, 4), (468, 70, 0.02, 4), (486, 12, -0.06, 4), (508, 56, 0.04, 4)]
    mist_a = mist(480, 40, 5, hx("cfe4cc"), 0.45, 70, 12)
    mist_b = mist(480, 20, 8, hx("bcd8c4"), 0.38, 90, 8)

    def fn(t):
        c = Image.new("RGBA", (W, H))
        c.alpha_composite(S["sky"])
        twinkle(c, S["stars"], t, [hx("5fa0a0"), hx("a7d0c0"), hx("e6f0d6"), hx("ffffff")])
        for cb, y, spd in S["clouds"]:
            view(c, cb, spd * t, y, wrap=True)
        view(c, S["far"], 20 + 4 * t)
        view(c, S["mtn"], 20 + 6 * t)
        view(c, mist_a, 8 * t, 150, wrap=True)
        view(c, S["shore"], 20 + 8 * t)
        reflect(c, S["HZ"], 236, t, hx("2e6e78"), 0.36, amp=1, period=1.0)
        glints(c, 182, 222, t, 3, 20, [hx("fff2b8"), hx("f0dc90"), hx("c8c07a")], 60, 150, (2, 6))
        glints(c, 182, 232, t, 9, 22, [hx("d6efd6"), hx("a2d0bc"), hx("78b0a4")], 150, 460, (3, 7), 1.6)
        view(c, mist_b, 12 * t, 172, wrap=True)
        off = 20 + 14 * t
        view(c, S["kn"], off)
        motes(c, t, 31, 6, (S["HX"] + 14 - int(off), S["HY"] - 20, S["HX"] + 20 - int(off), S["HY"] + 2),
              [hx("f0ecd0"), hx("cfd8bc"), hx("a4bcae")], (5, 8), 2, True)
        if int(t * 3) % 6:
            px(c, S["HX"] + 20 - int(off), S["HY"] + 13, hx("fff0a8"))
        view(c, S["ter"], 40 + 22 * t)
        for i, (bx, by, sp) in enumerate([(-10, 142, 16), (-70, 152, 14), (-40, 128, 18)]):
            bird(c, (bx + sp * t + 120 * i) % 600 - 40, by + int(math.sin(t * 1.2 + i) * 2), int(t * 6 + i), hx("f6f0dc"))
        _bamboo(c, t, 11 * t, stalks)
        motes(c, t, 77, 12, (0, 150, W, 230), [hx("e0f0b0"), hx("b0d890"), hx("78b070")], (3, 7), 6, True)
        return finish(c, t, dur)
    return fn


# ============================================================================ 2. GALUH
def tier_roof(im, cx, ybot, hwb, hwt, h, tiles, curve=1.7, tip=3):
    """one tier of a pendopo roof: concave flared silhouette, tile rows, upturned eave tips, shaded underside."""
    lit, mid, shd, line, deep = tiles
    d = ImageDraw.Draw(im)
    left, right = [], []
    for i in range(h + 1):
        s = i / h
        w_ = hwt + (hwb - hwt) * (s ** curve)
        left.append((cx - w_, ybot - h + i))
        right.append((cx + w_, ybot - h + i))
    pts = left + [(cx - hwb - tip, ybot - 2), (cx - hwb - tip + 1, ybot - 3)] + right[::-1][:0]
    poly = left + [(cx - hwb - tip, ybot - 3)] + [(cx + hwb + tip, ybot - 3)] + right[::-1]
    d.polygon([(round(x), round(y)) for x, y in poly], fill=mid)
    # underside + eave shadow
    d.rectangle((round(cx - hwb - tip + 2), ybot - 2, round(cx + hwb + tip - 2), ybot - 1), fill=deep)
    d.line([(round(cx - hwb - tip + 1), ybot - 3), (round(cx + hwb + tip - 1), ybot - 3)], fill=shd)
    a = arr(im)
    H_, W_ = a.shape[:2]
    m = poly_mask([(round(x), round(y)) for x, y in poly], W_, H_)
    yy, xx = np.mgrid[0:H_, 0:W_]
    ln = m & ((yy - (ybot - h)) % 3 == 0) & (yy < ybot - 3)
    a[ln & ((xx + yy) % 2 == 0)] = line
    # lit left half (sun upper-left) with dithered core edge
    lm = m & (xx < cx - 1) & (yy < ybot - 3)
    a[lm & (bay(H_, W_) < 0.5) & (yy % 3 != 0)] = lit
    sm = m & (xx > cx + 2)
    a[sm & ((yy - (ybot - h)) % 3 == 1) & ((xx + yy) % 2 == 0)] = shd
    # ridge cap
    top_y = ybot - h
    a[top_y, round(cx - hwt):round(cx + hwt) + 1] = lit
    return img(a)


def _galuh():
    HZ = 186
    sky = gradient(W, H, ["#3f78c0", "#5f94d4", "#8fb8e2", "#c0d6e4", "#e8e4cc", "#f8e8bc"],
                   np.clip((np.repeat(np.arange(H)[:, None] / 175.0, W, 1)) ** 1.15 + sunglow(W, H, 70, 40, 180, 140) * 0.28, 0, 1))
    d = ImageDraw.Draw(sky)
    for r, col in [(16, hx("fff0c8")), (13, hx("fff6dc")), (10, hx("ffffee"))]:
        d.ellipse((70 - r, 36 - r, 70 + r, 36 + r), fill=col)
    cc = (hx("fffaf0"), hx("f0e2d4"), hx("a8b4d8"))
    clouds = [(cumulus(150, 46, 3, cc, rmax=22), 36, 5, 0), (cumulus(110, 34, 8, cc, rmax=16), 70, 4, 250),
              (cumulus(170, 52, 12, cc, rmax=24), 84, 7, 120), (cumulus(90, 28, 4, cc, rmax=13), 28, 3, 380),
              (cumulus(130, 40, 21, cc, rmax=19), 112, 6, 70)]
    # far hills (speed 4)
    far = newl()
    prof = prof_pts([(0, 150), (70, 140), (130, 146), (210, 154), (330, 150), (420, 138), (500, 128), (570, 140), (640, 150)], smooth=4)
    prof += noise1(LW, 30, 4, 2) * 6
    far = fill_below(far, prof, hx("7f9cc8"), rim=hx("bcd0e4"), haze=hx("a0b8d8"))
    far = tex(far, np.ones((H, LW), bool), hx("7090c0"), fbm2(LW, H, 16, 6, 3, 2), 0.6, 0.1)

    # ---- the walled compound (speed 8)
    O = 24
    comp_ = newl()
    d = ImageDraw.Draw(comp_)
    # backdrop trees
    r = random.Random(11)
    cs = []
    for i in range(34):
        cx = 100 + i * 11 + r.randint(-3, 3)
        cs.append((cx + O, 146 - r.randint(2, 14), r.randint(8, 14), r.randint(7, 12)))
    for cx, cy in [(112, 112), (452, 108)]:        # two big shade trees flank the compound
        for k in range(9):
            cs.append((cx + O + r.randint(-24, 24), cy + r.randint(-12, 14), r.randint(10, 17), r.randint(9, 14)))
    tm = circles_mask(cs, LW, H)
    tm[158:] = False
    comp_ = shaded(comp_, tm, hx("2f6a42"), hx("86b44e"), hx("1c4638"), None, -1, -1, 3, 4)
    comp_ = tex(comp_, tm, hx("3f7e48"), fbm2(LW, H, 6, 5, 3, 2), 0.55, 0.1)
    comp_ = tex(comp_, tm, hx("245a3c"), fbm2(LW, H, 6, 5, 8, 2) - (np.mgrid[0:H, 0:LW][0] - 110) / 120.0, 0.55, 0.1)
    # wall
    wall = [(100 + O, 154), (480 + O, 154), (480 + O, 178), (100 + O, 178)]
    d = ImageDraw.Draw(comp_)
    d.rectangle((100 + O, 154, 480 + O, 178), fill=hx("b84a30"))
    a = arr(comp_)
    yy, xx = np.mgrid[0:H, 0:LW]
    wm = (yy >= 154) & (yy <= 178) & (xx >= 100 + O) & (xx <= 480 + O)
    a[wm & ((yy - 154) % 4 == 3) & ((xx + (yy // 4) * 5) % 9 != 0)] = hx("8e3228")
    a[wm & ((yy - 154) % 4 == 0) & (xx % 2 == 0)] = hx("d46a44")
    a[wm & (yy > 170) & (bay(H, LW) < 0.45)] = hx("8e3228")
    a[wm & (yy > 174)] = hx("6e2a2c")
    a[(yy == 152) & (xx >= 100 + O) & (xx <= 480 + O)] = hx("f0d8a4")
    a[(yy == 153) & (xx >= 100 + O) & (xx <= 480 + O)] = hx("c8a070")
    # merlons: little pale-capped triangular crests
    for x in range(100 + O, 480 + O, 8):
        a[150:152, x:x + 4] = hx("e8c890")
        a[149, x + 1:x + 3] = hx("f8e8b4")
    comp_ = img(a)
    d = ImageDraw.Draw(comp_)
    # roofs
    TL = (hx("f08a58"), hx("cc5638"), hx("93313a"), hx("e47448"), hx("5e1c2e"))
    def pavilion(cx, ybot, tiers, post=True):
        # white-washed colonnade under the roof
        d2 = ImageDraw.Draw(comp_)
        hw0 = tiers[0][0]
        d2.rectangle((cx + O - hw0 + 6, ybot, cx + O + hw0 - 6, 156), fill=hx("e8d8b8"))
        for k in range(-hw0 + 8, hw0 - 6, 6):
            d2.rectangle((cx + O + k, ybot, cx + O + k + 1, 156), fill=hx("6a3a2a"))
        d2.rectangle((cx + O - hw0 + 8, ybot + 2, cx + O + hw0 - 8, ybot + 5), fill=hx("3a1c24"))
        yb = ybot
        for hwb, hwt, h in tiers:
            nonlocal_im = tier_roof(newl(), cx + O, yb, hwb, hwt, h, TL)
            comp_.alpha_composite(nonlocal_im)
            yb -= h - 1
        top = yb
        d2.line([(cx + O, top - 6), (cx + O, top)], fill=hx("f2c25a"))
        d2.point((cx + O, top - 7), fill=hx("fff0a0"))
        d2.point((cx + O - 1, top - 2), fill=hx("f2c25a"))
        d2.point((cx + O + 1, top - 2), fill=hx("c9953e"))
    pavilion(176, 148, [(26, 17, 8), (17, 5, 11)])
    pavilion(386, 146, [(28, 19, 9), (19, 6, 12)])
    pavilion(262, 142, [(42, 31, 12), (31, 22, 11), (22, 8, 15)])
    # the split gate (candi bentar): two stepped halves with a dark gap that shows the dais beyond
    GX = 262 + O
    gate_l = [(GX - 28, 178), (GX - 28, 160), (GX - 24, 160), (GX - 24, 150), (GX - 20, 150), (GX - 20, 142), (GX - 16, 142), (GX - 16, 134),
              (GX - 7, 134), (GX - 7, 178)]
    gate_r = [(2 * GX - x, y) for x, y in gate_l]
    gap = [(GX - 7, 178), (GX - 7, 136), (GX + 7, 136), (GX + 7, 178)]
    d = ImageDraw.Draw(comp_)
    d.polygon(gap, fill=hx("3a1c24"))
    # glimpse of the inner court: white dais + warm lamp
    d.rectangle((GX - 6, 156, GX + 6, 160), fill=hx("e6d4aa"))
    d.rectangle((GX - 3, 146, GX + 3, 156), fill=hx("7a3a30"))
    d.point((GX, 150), fill=hx("ffd470"))
    for pts, lit_side in ((gate_l, True), (gate_r, False)):
        d.polygon(pts, fill=hx("c05034"))
    a = arr(comp_)
    for gx0, gx1, lt in ((GX - 28, GX - 7, True), (GX + 7, GX + 28, False)):
        sub = (yy >= 134) & (yy < 178) & (xx >= gx0) & (xx < gx1)
        brick = sub & (a[..., 0] > 150) & (a[..., 1] < 100)
        a[brick & ((yy - 134) % 4 == 3) & ((xx + (yy // 4) * 3) % 7 != 0)] = hx("8e3228")
        edge_x = gx1 - 1 if lt else gx0
        a[brick & (xx == (gx0 if lt else gx1 - 1))] = hx("e6805a") if lt else hx("8e3228")
        a[brick & (xx == (gx1 - 1 if lt else gx0))] = hx("6e2a2c")
        a[brick & (xx == (gx0 + 1 if lt else gx1 - 2)) & (yy % 2 == 0)] = hx("d46a44") if lt else hx("8e3228")
    # pale caps on every step
    for pts in (gate_l, gate_r):
        for i in range(len(pts) - 1):
            (xa, ya), (xb, yb_) = pts[i], pts[i + 1]
            if ya == yb_ and ya < 178:
                a[ya - 1:ya + 1, min(xa, xb):max(xa, xb) + 1] = hx("f0d8a4")
    # steps down from the gate
    for i in range(5):
        a[178 + i, GX - 12 - i * 2:GX + 12 + i * 2 + 1] = hx("e0d0a8") if i % 2 == 0 else hx("b8a47c")
    comp_ = img(a)
    # ---- bank (speed 10): ochre earth, reeds, grass fringe
    bank = newl()
    bp = prof_pts([(0, 180), (100, 178), (220, 182), (330, 180), (460, 178), (640, 181)], smooth=2) + noise1(LW, 18, 3, 2) * 2
    bank = fill_below(bank, bp, hx("a8723c"), rim=hx("7fae4a"), rim2=hx("6a9a40"))
    a = arr(bank)
    inside = a[..., 3] > 0
    dep = yy - np.round(bp).astype(int)[None, :]
    a[inside & (dep > 3)] = hx("a8723c")
    a[inside & (dep > 5) & (bay(H, LW) < 0.5)] = hx("8e5a34")
    a[inside & (dep > 7)] = hx("6e4430")
    bank = img(a)
    r = random.Random(5)
    d = ImageDraw.Draw(bank)
    for _ in range(60):
        x = r.randrange(0, LW)
        y = int(bp[x])
        hh = r.randint(2, 5)
        d.line([(x, y), (x + r.choice([-1, 0, 1]), y - hh)], fill=hx("86b450") if r.random() < 0.6 else hx("c8cf7c"))
    # foreground earth + post for the rooster (speed 16)
    fg = newl()
    fp = prof_pts([(0, 260), (120, 257), (250, 254), (380, 246), (470, 236), (560, 232), (640, 232)], smooth=3) + noise1(LW, 16, 6, 2) * 2
    fg = fill_below(fg, fp, hx("8a5a38"), rim=hx("e0b068"), rim2=hx("c08c4c"))
    a = arr(fg)
    inside = a[..., 3] > 0
    dep = yy - np.round(fp).astype(int)[None, :]
    a[inside & (dep > 3) & (bay(H, LW) < 0.5)] = hx("6e4230")
    a[inside & (dep > 6)] = hx("4e2e2c")
    fg = img(a)
    d = ImageDraw.Draw(fg)
    # post
    PX = 452
    d.rectangle((PX, 224, PX + 6, 268), fill=hx("7a4a30"))
    d.rectangle((PX, 224, PX + 1, 262), fill=hx("c88a50"))
    d.rectangle((PX + 5, 224, PX + 6, 262), fill=hx("4a2a2a"))
    d.rectangle((PX - 1, 222, PX + 7, 224), fill=hx("9a6038"))
    d.line([(PX - 1, 222), (PX + 7, 222)], fill=hx("e8b070"))
    for k in range(230, 262, 8):
        d.line([(PX + 1, k), (PX + 5, k)], fill=hx("5a3428"))
    r = random.Random(9)
    for _ in range(70):       # tall dry grass
        x = r.randrange(0, LW)
        y = int(fp[x])
        hh = r.randint(3, 9) if not (PX - 8 < x < PX + 14) else 2
        lean = r.choice([-1, -1, 0, 1])
        for k in range(hh):
            d.point((x + (lean * k) // 3, y - k), fill=hx("d8b868") if k > hh // 2 else hx("8a7a3c"))
    return dict(sky=sky, clouds=clouds, far=far, comp=comp_, bank=bank, fg=fg, O=O, HZ=HZ, PX=PX, TOP=222)


ROOSTER = ["...........rr.....",
           "..........rrrr....",
           ".........orrro....",
           "....g....oooo.....",
           "...ggo..ooooo.....",
           "....ooooooooo.....",
           "....oooooooo..tt..",
           "....bbbbbbbbbttt..",
           "...bbbbbbbbbbtttt.",
           "...wbbbbbbbbbbttt.",
           "...wwbbbbbbbbbbtt.",
           "....wbbbbbbbbbbt..",
           ".....bbbbbbbbb....",
           "......bbbbbbb.....",
           ".......y..y.......",
           ".......y..y......."]
PAL_R = {"r": hx("e8402c"), "o": hx("d8602a"), "g": hx("f2c25a"), "b": hx("8e2a30"), "w": hx("e89a3a"), "t": hx("1f5a50"), "y": hx("c8962e")}


@scene("vista_galuh", DUR)
def vista_galuh(dur=DUR):
    G = _galuh()
    HZ = G["HZ"]
    rooster = spr(ROOSTER, PAL_R)
    ra = arr(rooster)
    ra[(ra[..., 0] == 232) & (ra[..., 1] == 64)] = (232, 64, 44, 255)
    rooster = img(ra)
    rooster_b = rooster.transpose(Image.FLIP_TOP_BOTTOM) if False else rooster
    mist_a = mist(480, 24, 7, hx("fff0d0"), 0.3, 80, 8)
    poles = [(222, 90), (310, 86), (404, 94), (160, 108)]
    boatA = spr(["......................", "..............w.......", ".............ww.......", "............www.......", "...........wwww..h....",
                 "..........wwwww.hh....", "..dd.hhhhhhhhhhhhhhdd.", "..dddddrrrrrrrrdddddd.", "...dddddddddddddddd...", ".....dddddddddddd....."],
                {"d": hx("4a2a26"), "r": hx("d8402e"), "w": hx("f4e6c0"), "h": hx("7a4a30")})
    boatB = flip(spr(["......................", "..............c.......", ".............cc.......", "............ccc.......", "...........cccc..h....",
                      "..........ccccc.hh....", "..dd.hhhhhhhhhhhhhhdd.", "..dddddyyyyyyyydddddd.", "...dddddddddddddddd...", ".....dddddddddddd....."],
                     {"d": hx("3a2a30"), "y": hx("f2c25a"), "c": hx("d8402e"), "h": hx("7a4a30")}))

    def fn(t):
        c = Image.new("RGBA", (W, H))
        c.alpha_composite(G["sky"])
        for im, y, spd, x0 in G["clouds"]:
            view(c, im, spd * t + x0, y, wrap=True) if False else None
        # clouds drift on a 640 wrap
        for im, y, spd, x0 in G["clouds"]:
            xx = int(x0 - spd * t) % 640 - 100
            put(c, im, xx, y)
        view(c, G["far"], 20 + 4 * t)
        view(c, mist_a, 6 * t, 146, wrap=True)
        off = G["O"] + 8 * t
        view(c, G["comp"], off)
        # pennants on tall poles (wave in whole pixels)
        for i, (px_, top) in enumerate(poles):
            x = px_ + G["O"] - int(off)
            for y in range(top, 152):
                px(c, x, y, hx("5a3426"))
            px(c, x, top - 1, hx("f2c25a"))
            for k in range(1, 15):
                wv = int(round(math.sin(t * 6 - k * 0.6 + i) * (1 + k * 0.1)))
                wd = max(1, 5 - k // 3)
                for j in range(wd):
                    col = hx("d8402e") if (k // 3) % 2 == 0 else hx("f6e2b8")
                    px(c, x + k, top + 1 + j + wv, col)
        # kitchen smoke
        motes(c, t, 4, 8, (330 + G["O"] - int(off), 112, 338 + G["O"] - int(off), 150), [hx("f4ecd8"), hx("d0d0d4"), hx("a8b4d0")], (5, 9), 2, True)
        view(c, G["bank"], 30 + 10 * t)
        reflect(c, 186, 250, t, hx("2a62b0"), 0.58, amp=2, period=1.0)
        # river sheen: far-bank light, drifting highlight dashes
        glints(c, 188, 246, t, 3, 46, [hx("fff6d8"), hx("cfe4f4"), hx("8fc0e4")], 0, W, (2, 7), 1.3)
        mist_b = None
        # the two brothers part: two boats crossing in opposite directions
        for im, bx, sp, by in ((boatA, 360, -8, 203), (boatB, 150, 7, 224)):
            x = bx + sp * t
            bob = int(math.sin(t * 2.0 + bx) * 1)
            put(c, im, x, by + bob)
            wk = 1 if sp < 0 else -1
            for j in range(3):
                px(c, x + (24 if sp < 0 else -3) + wk * j * 3, by + 9 + bob, hx("e8f4fc"))
        view(c, G["fg"], 30 + 16 * t)
        # rooster on the post: head bob / crow beat, tail sway
        fx = G["PX"] - 30 - 16 * t - 5
        beat = int(t * 2.5) % 4
        put(c, rooster, fx + 1, G["TOP"] - 16 - (1 if beat == 1 else 0))
        if beat == 1:
            px(c, fx + 3, G["TOP"] - 22, hx("fff0a0"))
        for i, (bx, by, sp) in enumerate([(-10, 60, 14), (-80, 40, 12), (-40, 90, 16), (-120, 52, 13)]):
            bird(c, (bx + sp * t + 150 * i) % 640 - 60, by + int(math.sin(t * 1.1 + i) * 2), int(t * 6 + i), hx("fffaf0"))
        motes(c, t, 70, 16, (0, 120, W, 240), [hx("fff0a8"), hx("f8d870"), hx("d8a850")], (3, 6), 6, True)
        return finish(c, t, dur)
    return fn


# ============================================================================ 3. MATARAM
def _hw(f):
    """half-width (0..1) of a Prambanan-style candi at fraction f above its base: stepped plinth, body, tiered needle."""
    if f < 0.05:
        return 1.0
    if f < 0.10:
        return 0.88
    if f < 0.15:
        return 0.76
    if f < 0.40:
        return 0.64 - (f - 0.15) * 0.12
    if f < 0.44:
        return 0.70
    g = (f - 0.44) / 0.56
    base = 0.56 * (1 - g) ** 0.85
    tier = int(g * 8)
    bump = 0.10 * (1 - g) if (int(g * 16) % 2 == 0 and g < 0.8) else 0.0
    return max(0.03, base + bump) if g < 0.93 else 0.03


def candi(w, h, cols, niches=True, lamps=False, seed=0):
    lit, mid, shd, deep = cols
    im = Image.new("RGBA", (w + 2, h + 2), (0, 0, 0, 0))
    a = np.zeros((h + 2, w + 2, 4), "uint8")
    cx = (w + 1) / 2.0
    spans = {}
    for y in range(h):
        f = (h - 1 - y) / max(1, h - 1)
        hwp = _hw(f) * w / 2.0
        x0, x1 = int(round(cx - hwp)), int(round(cx + hwp - 1))
        x1 = max(x1, x0)
        spans[y] = (x0, x1)
        a[y + 1, x0:x1 + 1] = mid
    for y, (x0, x1) in spans.items():
        f = (h - 1 - y) / max(1, h - 1)
        wd = x1 - x0 + 1
        a[y + 1, x0] = lit
        if wd > 4:
            a[y + 1, x1] = deep
            a[y + 1, x1 - 1] = shd
        if wd > 8:
            half = x0 + wd // 2
            for x in range(half, x1):
                if (x + y) % 2 == 0:
                    a[y + 1, x] = shd
        # tier grooves
        if f > 0.44 and int((f - 0.44) / 0.56 * 16) % 2 == 1 and wd > 3:
            a[y + 1, x0 + 1:x1] = shd if wd > 5 else a[y + 1, x0 + 1:x1]
            a[y + 1, x0] = lit
        if f < 0.44 and f > 0.04 and (y % 6 == 0) and wd > 8:
            a[y + 1, x0 + 1:x1] = shd
    if niches and w >= 14:
        ny0, ny1 = int(h * (1 - 0.38)), int(h * (1 - 0.20))
        for dx in (-int(w * 0.22), int(w * 0.18)):
            xx0 = int(cx) + dx
            a[ny0 + 1:ny1 + 1, xx0:xx0 + 3] = deep
            if lamps:
                a[ny1, xx0 + 1] = hx("ffb050")
        dy0 = int(h * (1 - 0.14))
        a[dy0 + 1:h, int(cx) - 1:int(cx) + 2] = deep
        a[dy0, int(cx)] = deep
    # finial ball
    a[0, int(cx)] = lit
    return img(a)


def _spire_row(seed, base_y, x0, x1, step, hr, wr, cols, density=0.9, niches=False, extra=None):
    r = random.Random(seed)
    layer = newl()
    x = x0
    while x < x1:
        if r.random() < density:
            h = r.randint(*hr)
            w = r.randint(*wr)
            if h > w * 4:
                w = max(5, h // 4)
            layer.alpha_composite(candi(w, h, cols, niches=niches), (x - w // 2, base_y - h))
        x += r.randint(step - 2, step + 4)
    if extra:
        for ex, ew, eh in extra:
            layer.alpha_composite(candi(ew, eh, cols, niches=True, lamps=True), (ex - ew // 2, base_y - eh))
    return layer


def _mataram():
    SX, SY = 332, 152
    cols = ["#1d1240", "#3f1a62", "#7a2a74", "#b8386c", "#e8583c", "#ff8a3a", "#ffb850", "#ffe08a"]
    yy = np.repeat(np.arange(H)[:, None] / 178.0, W, 1)
    v = np.clip(yy ** 1.15 + sunglow(W, H, SX, SY, 220, 130) ** 1.4 * 0.35, 0, 1)
    sky = gradient(W, H, cols, v)
    a = arr(sky)
    yyg, xxg = np.mgrid[0:H, 0:W]
    ang = np.arctan2(yyg - SY, xxg - SX)
    d2 = np.hypot((xxg - SX), (yyg - SY))
    ray = (np.sin(ang * 11 + 0.6) > 0.72) & (yyg < SY - 4) & (d2 < 260) & (bay(H, W) < 0.42)
    a[ray] = np.clip(a[ray].astype(int) + [34, 22, 4, 0], 0, 255).astype("uint8")
    sky = img(a)
    d = ImageDraw.Draw(sky)
    for r, col in [(34, hx("ffb44a")), (29, hx("ffcf6a")), (25, hx("ffe28c")), (21, hx("fff0b4"))]:
        d.ellipse((SX - r, SY - r, SX + r, SY + r), fill=col)
    sky = img(np.where((np.mgrid[0:H, 0:W][0] >= 177)[..., None], arr(gradient(W, H, ['#a8407a', '#7a2a74', '#4a2062'], np.clip((np.repeat(np.arange(H)[:, None], W, 1) - 177) / 40.0, 0, 1))), arr(sky)))
    stars = make_stars(12, 30, 70)
    # long dusk cloud streaks lit from below by the sun
    clouds = []
    for y, th, sp, sd in [(52, 6, 3, 1), (80, 9, 5, 2), (106, 7, 7, 3), (128, 5, 4, 4)]:
        clouds.append((cloud_band(480, 18, th, sd, hx("a8327a"), hx("ff8a58"), cell=100, floor=0.28), y, sp))
    # four receding skylines of temples
    far = _spire_row(1, 170, -20, LW + 20, 8, (14, 32), (5, 9), [hx(c) for c in ("f2a07e", "d8688a", "bc4a82", "9a3a7a")])
    rowB = _spire_row(2, 176, -20, LW + 20, 10, (22, 44), (7, 12), [hx(c) for c in ("e07a80", "b04a84", "8a3478", "682a6c")],
                      extra=[(250, 16, 56)])
    rowC = _spire_row(3, 183, -20, LW + 20, 17, (30, 56), (9, 16), [hx(c) for c in ("c85a7e", "8c3a7c", "682c70", "4a2060")],
                      extra=[(120, 22, 64), (420, 20, 60)], niches=True)
    # the near terrace platform with the great central candi group
    rowD = newl()
    d = ImageDraw.Draw(rowD)
    d.rectangle((60, 192, 520, 214), fill=hx("2c1a42"))
    d.rectangle((60, 192, 520, 193), fill=hx("ff9650"))
    d.rectangle((60, 194, 520, 194), fill=hx("a8508a"))
    CT = [hx(c) for c in ("ff9a58", "4a2468", "2c1646", "180c2e")]
    CT2 = [hx(c) for c in ("ff9a58", "55306e", "34204e", "1c1032")]
    for cx, w_, h_ in [(200, 36, 96), (150, 26, 66), (252, 28, 74), (112, 18, 46), (292, 20, 52), (82, 14, 34), (326, 14, 36)]:
        rowD.alpha_composite(candi(w_, h_, CT if w_ > 20 else CT2, niches=True, lamps=True), (cx - w_ // 2, 192 - h_))
    # little shrine rows on the platform front
    for cx in range(70, 520, 26):
        if 330 > cx or cx > 372:
            rowD.alpha_composite(candi(8, 18, CT2, niches=False), (cx - 4, 193 - 18 + 6))
    d = ImageDraw.Draw(rowD)
    d.rectangle((60, 198, 520, 214), fill=hx("261640"))
    a = arr(rowD)
    yy2, xx2 = np.mgrid[0:H, 0:LW]
    pm = (yy2 >= 195) & (yy2 <= 214) & (xx2 >= 60) & (xx2 <= 520)
    a[pm & ((yy2 - 195) % 5 == 4)] = hx("180c2e")
    a[pm & ((xx2 + (yy2 // 5) * 7) % 12 == 0) & ((yy2 - 195) % 5 != 4)] = hx("3a2058")
    rowD = img(a)

    # rice terraces (speed 20): flooded paddies mirroring the sunset, dark bunds, seedling rows
    pad = newl()
    a = arr(pad)
    edges = [208, 219, 232, 247, 264]
    skyc = ["#ffb050", "#ff8a48", "#e8603c", "#b8386c", "#7a2a74"]
    xs = np.arange(LW)
    es = []
    for k, b in enumerate(edges):
        es.append(np.round(b - 10 / (1 + np.exp(-(xs - 360) / 80.0)) * (1 - 0.15 * k) + np.sin(xs / (90 + 25 * k) + k * 2.1) * (3 + k * 1.2)).astype(int))
    for k in range(len(edges) - 1, -1, -1):
        e = es[k]
        nx = es[k + 1] if k + 1 < len(edges) else np.full(LW, H)
        for x in range(LW):
            y0, y1 = e[x], min(H, nx[x])
            for y in range(max(0, y0), y1):
                dd = y - y0
                if dd < 2:
                    col = hx("2a2036")
                elif dd >= (y1 - y0) - 3 and k + 1 < len(edges):
                    col = hx("1a1230")
                else:
                    f = (dd - 2) / max(1, (y1 - y0) - 5)
                    col = hx(skyc[min(len(skyc) - 1, k + (1 if f > 0.55 and (x + y) % 2 == 0 else 0))])
                a[y, x] = col
            # seedling dots along a row
            yy_ = y0 + 6
            if k < 3 and y1 - y0 > 12 and 0 <= yy_ < H and (x + k) % 5 == 0:
                a[yy_, x] = hx("2c6a40")
                if yy_ - 1 >= 0:
                    a[yy_ - 1, x] = hx("5a9a4a")
    pad = img(a)
    pad = tone(pad, (1 - xx2 / 440.0) * 0.5 + (yy2 - 200) / 120.0, 0.8, 0.3, hx("1a0e30"), 0.55)
    # princess terrace: carved stone platform (speed 20, shares the paddy layer's pan)
    tr = newl()
    d = ImageDraw.Draw(tr)
    TX0, TX1, TY = 312, 470, 214
    d.rectangle((TX0, TY, TX1, TY + 12), fill=hx("2e1c46"))
    d.rectangle((TX0, TY, TX1, TY), fill=hx("ff9a58"))
    d.rectangle((TX0, TY + 1, TX1, TY + 1), fill=hx("b0508a"))
    a = arr(tr)
    tm = (yy2 >= TY + 2) & (yy2 <= TY + 12) & (xx2 >= TX0) & (xx2 <= TX1)
    a[tm & ((xx2 // 8 + (yy2 // 4)) % 2 == 0)] = hx("3a2456")
    a[tm & ((yy2 - TY) % 4 == 0)] = hx("1e1034")
    # balustrade posts with small lamp niches
    for x in range(TX0 + 4, TX1, 14):
        a[TY - 6:TY, x:x + 3] = hx("2c1a44")
        a[TY - 7, x:x + 3] = hx("ff9a58")
        a[TY - 4, x + 1] = hx("ffb050")
    tr = img(a)
    return dict(sky=sky, stars=stars, clouds=clouds, far=far, rowB=rowB, rowC=rowC, rowD=rowD, pad=pad, tr=tr, TX0=TX0, TY=TY, SX=SX, SY=SY)


PRINCESS = ["......g......",
            ".....ggg.....",
            ".....hhh.....",
            ".....hhh.....",
            "......h......",
            ".....bbb.....",
            "....bbbbb....",
            "....bbbbb.a..",
            ".....bbb..a..",
            ".....kkk.....",
            "....kkkkk....",
            "....kkkkkk...",
            "...kkkkkkk...",
            "...kkkkkkkk..",
            "..kkkkkkkkk..",
            "..kkkkkkkkkk."]


@scene("vista_mataram", DUR)
def vista_mataram(dur=DUR):
    M = _mataram()
    pal = {"g": hx("ffb050"), "h": hx("2a1844"), "b": hx("2a1844"), "k": hx("221238"), "a": hx("2a1844")}
    pr = spr(PRINCESS, pal)
    pa = arr(pr)
    for y in range(pa.shape[0]):               # sun on her right side: warm rim on the right-hand edge
        xs = np.where(pa[y, :, 3] > 0)[0]
        if len(xs):
            pa[y, xs.max()] = hx("ff9a58")
    pr = img(pa)
    mistA = mist(480, 28, 3, hx("ffb078"), 0.5, 80, 10)
    mistB = mist(480, 30, 5, hx("d8587c"), 0.5, 90, 10)
    mistC = mist(480, 30, 9, hx("a83c78"), 0.45, 100, 10)

    def fn(t):
        c = Image.new("RGBA", (W, H))
        c.alpha_composite(M["sky"])
        twinkle(c, M["stars"], t, [hx("6a4a90"), hx("a890c8"), hx("e8d8f0"), hx("ffffff")])
        for cb, y, spd in M["clouds"]:
            view(c, cb, spd * t, y, wrap=True)
        view(c, M["far"], 20 + 4 * t)
        view(c, mistA, 5 * t, 148, wrap=True)
        view(c, M["rowB"], 20 + 7 * t)
        view(c, mistB, 8 * t, 156, wrap=True)
        view(c, M["rowC"], 20 + 11 * t)
        view(c, mistC, 11 * t, 162, wrap=True)
        off = 20 + 15 * t
        view(c, M["rowD"], off)
        # lamps glimmer in the great candi's niches
        for i, (lx, ly) in enumerate([(196, 128), (190, 150), (214, 144), (150, 150), (248, 160), (172, 162), (200, 168)]):
            flicker(c, lx - int(off), ly, t, i * 3, [hx("ffc060"), hx("ff9040")])
        view(c, M["pad"], 40 + 20 * t)
        view(c, M["tr"], 40 + 20 * t)
        # the princess on the terrace: a long selendang streaming in the evening breeze
        px0 = M["TX0"] + 64 - 40 - int(20 * t)
        py0 = M["TY"] - 16
        put(c, pr, px0, py0)
        for k in range(1, 10):
            wv = int(round(math.sin(t * 3.2 - k * 0.7) * (0.6 + k * 0.18)))
            px(c, px0 + 11 + k, py0 + 8 + wv + k // 4, hx("ff7a58") if k % 3 else hx("ffb050"))
            if k > 4:
                px(c, px0 + 11 + k, py0 + 9 + wv + k // 4, hx("e0505a"))
        for k in range(1, 7):       # kain hem sways
            px(c, px0 + 12 + int(round(math.sin(t * 2.4) * 1)), py0 + 15, hx("221238"))
        # dusk fliers homing to the temples
        for i, (bx, by, sp) in enumerate([(-10, 100, 15), (-60, 118, 13), (-30, 86, 17), (-90, 108, 14)]):
            bird(c, (bx + sp * t + 110 * i) % 560 - 40, by + int(math.sin(t * 1.3 + i) * 2), int(t * 6 + i), hx("3a1a50"))
        motes(c, t, 55, 20, (0, 196, W, 262), [hx("fff0a0"), hx("ffc858"), hx("d88838")], (3, 7), 7, True)
        return finish(c, t, dur)
    return fn


# ============================================================================ 4. TIMUR
def _blob_tree(cs, mid, lit, shd, seed, y_cut=None):
    m = circles_mask(cs, LW, H)
    if y_cut:
        m[y_cut:] = False
    im = shaded(newl(), m, mid, lit, shd, None, -1, -1, 3, 4)
    im = tex(im, m, mid, fbm2(LW, H, 6, 5, seed, 2), 0.5, 0.1) if False else im
    im = tex(im, m, tuple(max(0, c - 18) for c in shd[:3]) + (255,), fbm2(LW, H, 7, 5, seed + 5, 2), 0.66, 0.08)
    return im, m


def _timur():
    HZ = 176
    sky = gradient(W, H, ["#4a86c4", "#7fb0d8", "#c4d8d0", "#f4e4a0", "#ffd478"],
                   np.clip(np.repeat(np.arange(H)[:, None] / 176.0, W, 1) ** 1.2 + sunglow(W, H, 410, 60, 200, 150) * 0.3, 0, 1))
    d = ImageDraw.Draw(sky)
    for r, col in [(18, hx("ffe9a0")), (14, hx("fff2c0")), (11, hx("ffffe0"))]:
        d.ellipse((410 - r, 56 - r, 410 + r, 56 + r), fill=col)
    clouds = [(cumulus(120, 34, 31, (hx("fffae0"), hx("f6e8c8"), hx("c8c0c0")), rmax=15), 44, 4, 60),
              (cumulus(90, 26, 32, (hx("fffae0"), hx("f6e8c8"), hx("c8c0c0")), rmax=11), 92, 6, 290)]
    # volcano (speed 4)
    vol = newl()
    vp = prof_pts([(300, 176), (360, 150), (405, 124), (432, 108), (452, 100), (460, 103), (472, 101), (486, 108), (510, 126), (560, 152), (640, 176)], smooth=2)
    vp += noise1(LW, 20, 5, 2) * 2
    vol = fill_below(vol, vp, hx("6e82b0"), rim=hx("c8d4e4"))
    a = arr(vol)
    yy, xx = np.mgrid[0:H, 0:LW]
    dep = yy - np.round(vp).astype(int)[None, :]
    ins = a[..., 3] > 0
    a[ins & (xx > 470 + 0.4 * dep) & (bay(H, LW) < np.clip((xx - 470 - 0.4 * dep) / 20, 0, 1))] = hx("55689a")
    vol = img(a)
    vol = tex(vol, ins, hx("5a70a2"), fbm2(LW, H, 5, 18, 4, 2) + dep / 160.0, 0.72, 0.08)
    # the giant on the far ridge (speed 6): hulking green silhouette, hazed by distance
    gi = newl()
    d = ImageDraw.Draw(gi)
    GC, GL, GD = hx("5e8f52"), hx("8cb46a"), hx("3f6a40")
    gx, gy = 130, 160
    d.polygon([(gx - 22, gy), (gx - 26, gy - 26), (gx - 20, gy - 44), (gx - 8, gy - 52), (gx + 8, gy - 52), (gx + 20, gy - 44), (gx + 27, gy - 24), (gx + 22, gy)], fill=GC)
    d.ellipse((gx - 8, gy - 66, gx + 8, gy - 50), fill=GC)                       # head
    d.polygon([(gx - 7, gy - 63), (gx - 12, gy - 72), (gx - 4, gy - 66)], fill=GC)  # horns
    d.polygon([(gx + 7, gy - 63), (gx + 12, gy - 72), (gx + 4, gy - 66)], fill=GC)
    d.polygon([(gx - 26, gy - 40), (gx - 36, gy - 20), (gx - 34, gy - 2), (gx - 28, gy - 2), (gx - 24, gy - 22)], fill=GC)      # arms
    d.polygon([(gx + 24, gy - 40), (gx + 36, gy - 30), (gx + 40, gy - 8), (gx + 34, gy - 8), (gx + 28, gy - 28)], fill=GC)
    d.line([(gx + 38, gy - 8), (gx + 42, gy - 56)], fill=GD, width=3)               # club
    d.ellipse((gx + 36, gy - 66, gx + 48, gy - 52), fill=GD)
    gi = rim_light(gi, GL, -1, -1)
    gi = dmask(gi, arr(gi)[..., 3] > 0, hx("7ea66a"), 0.18)
    gi = dmask(gi, np.zeros((H, LW), bool) | (arr(gi)[..., 3] > 0), hx("3f6a40"), 0.0)
    gi.alpha_composite(Image.new("RGBA", gi.size, (0, 0, 0, 0)))
    for (x, y) in [(gx - 3, gy - 60), (gx + 3, gy - 60)]:
        gi.putpixel((x, y), hx("ffd040"))
    # far and mid hills
    h1 = newl()
    p1 = prof_pts([(0, 164), (80, 154), (170, 160), (260, 168), (340, 160), (430, 150), (540, 160), (640, 164)], smooth=4) + noise1(LW, 30, 3, 2) * 5
    h1 = fill_below(h1, p1, hx("b0ac66"), rim=hx("e0d890"), haze=hx("c8c47c"))
    h2 = newl()
    p2 = prof_pts([(0, 180), (90, 170), (200, 176), (310, 184), (420, 174), (540, 170), (640, 178)], smooth=4) + noise1(LW, 26, 7, 2) * 4
    h2 = fill_below(h2, p2, hx("8c9448"), rim=hx("d0cc78"), haze=hx("a8ac5c"))
    h2 = tex(h2, np.ones((H, LW), bool), hx("747e3c"), fbm2(LW, H, 9, 4, 5, 2), 0.58, 0.1)
    # savanna plain + the great banyan (speed 14)
    sv = newl()
    sp_ = prof_pts([(0, 204), (150, 200), (300, 202), (450, 198), (640, 202)], smooth=3) + noise1(LW, 20, 4, 2) * 2
    r = random.Random(4)
    cs = []
    for i in range(22):
        cs.append((int(260 + r.gauss(0, 58)), int(118 + r.gauss(0, 12)), r.randint(14, 26), r.randint(10, 17)))
    cs += [(210, 142, 30, 14), (300, 138, 34, 15), (360, 148, 28, 12), (250, 150, 30, 12)]
    bt, bm = _blob_tree(cs, hx("4e7a34"), hx("b4c850"), hx("24442c"), 3, 176)
    sv = fill_below(sv, sp_, hx("d8b050"), rim=hx("fbe898"), rim2=hx("e8c870"))
    d = ImageDraw.Draw(sv)
    d.polygon([(246, 204), (252, 170), (258, 152), (268, 150), (278, 152), (284, 170), (292, 204)], fill=hx("5e3c26"))
    for k in range(6):       # buttress roots / trunk bark
        d.line([(252 + k * 7, 204), (254 + k * 6, 160)], fill=hx("3e2620") if k % 2 else hx("7a4e30"))
    sv.alpha_composite(bt)
    d = ImageDraw.Draw(sv)
    for _ in range(28):      # hanging aerial roots
        x = int(260 + r.gauss(0, 55))
        top = 150 + r.randint(0, 14)
        ln = r.randint(14, 44)
        for y in range(top, min(203, top + ln)):
            d.point((x, y), fill=hx("4a2e22") if y % 3 else hx("7a4e30"))
    a = arr(sv)
    ins = a[..., 3] > 0
    gd = ins & (yy > np.round(sp_).astype(int)[None, :] + 3)
    a[gd & (bay(H, LW) < 0.45)] = hx("b88a38")
    a[gd & (yy > 214)] = hx("a07430")
    sv = img(a)
    # foreground: dry grass + giant cucumber vines (speed 24)
    fg = newl()
    fp = prof_pts([(0, 256), (200, 252), (360, 244), (520, 238), (640, 238)], smooth=3) + noise1(LW, 18, 2, 2) * 2
    fg = fill_below(fg, fp, hx("8a6a2c"), rim=hx("e8c868"))
    d = ImageDraw.Draw(fg)
    for x in range(380, 560, 1):     # vine
        y = 250 - int(18 * math.sin((x - 380) / 38.0)) - (x - 380) // 12
        d.point((x, y), fill=hx("3e7a30"))
        d.point((x, y + 1), fill=hx("2a5a28"))
    for cx, cy in [(408, 232), (452, 226), (498, 218)]:
        d.ellipse((cx - 11, cy - 20, cx + 11, cy + 20), fill=hx("78a838")) if False else None
        cy += 18
        d.ellipse((cx - 14, cy - 6, cx + 14, cy + 6), fill=hx("5e9a30"))
        d.line([(cx - 12, cy - 4), (cx + 12, cy - 4)], fill=hx("b8d860"))
        d.line([(cx - 12, cy + 4), (cx + 12, cy + 4)], fill=hx("34602a"))
        for q in range(-10, 12, 5):
            d.point((cx + q, cy), fill=hx("e8e090"))
        d.polygon([(cx - 14, cy), (cx - 22, cy - 3), (cx - 22, cy + 3)], fill=hx("e8c040"))
        for sgn in (-1, 1):
            d.polygon([(cx, cy - 6), (cx + sgn * 16, cy - 20), (cx + sgn * 24, cy - 8), (cx + sgn * 8, cy - 4)], fill=hx("3e8a38"))
            d.line([(cx, cy - 6), (cx + sgn * 20, cy - 14)], fill=hx("a0d058"))
    fg = tone(fg, (1 - xx / 420.0) * 0.5 + (yy - 220) / 80.0, 0.8, 0.3, hx("4a3818"), 0.5)
    return dict(sky=sky, clouds=clouds, vol=vol, gi=gi, h1=h1, h2=h2, sv=sv, fg=fg, fp=fp)


@scene("vista_timur", DUR)
def vista_timur(dur=DUR):
    T = _timur()
    r = random.Random(8)
    blades = [(r.randrange(0, LW), r.randint(8, 26), r.random() * 6.28) for _ in range(110)]

    def fn(t):
        c = Image.new("RGBA", (W, H))
        c.alpha_composite(T["sky"])
        for im, y, spd, x0 in T["clouds"]:
            put(c, im, int(x0 - spd * t) % 640 - 100, y)
        view(c, T["vol"], 20 + 4 * t)
        # smoke plume leaning in the wind: stacked dithered puffs
        ox = 20 + 4 * t
        for k in range(9):
            cx = 466 - int(ox) + int(k * 6 + math.sin(t * 0.8 + k) * 2)
            cy = 100 - k * 8
            rr = 4 + k
            for yy_ in range(-rr, rr + 1):
                for xx_ in range(-rr, rr + 1):
                    if xx_ * xx_ + yy_ * yy_ <= rr * rr and BY4[(cy + yy_) % 4, (cx + xx_) % 4] < 0.62 - k * 0.04:
                        px(c, cx + xx_, cy + yy_, hx("8c9cc0") if yy_ < 0 else hx("6e82b0"))
        view(c, T["h1"], 20 + 6 * t)
        view(c, T["gi"], 20 + 6 * t)
        view(c, T["h2"], 20 + 10 * t)
        view(c, T["sv"], 20 + 14 * t)
        for i, (bx, by, sp) in enumerate([(-10, 46, 10), (-70, 70, 9), (-120, 30, 11)]):
            bird(c, (bx + sp * t + 160 * i) % 560 - 40, by + int(math.sin(t * 1.1 + i) * 2), int(t * 5 + i), hx("3a2a2a"))
        off = 40 + 24 * t
        view(c, T["fg"], off)
        fp = T["fp"]
        for x, hh, ph in blades:
            sx = x - int(off)
            if 0 <= sx < W:
                y = int(fp[x])
                sw = int(round(math.sin(t * 1.6 + ph + x * 0.05) * 1.5))
                for k in range(hh):
                    px(c, sx + (sw * k) // hh, y - k, hx("f0d070") if k > hh * 0.5 else hx("a88a38"))
        motes(c, t, 90, 22, (0, 130, W, 250), [hx("fff0a0"), hx("f8d870"), hx("d8a850")], (3, 8), 8, True)
        return finish(c, t, dur)
    return fn


# ============================================================================ 5. KIDUL
def _kidul():
    HZ = 150
    sky = gradient(W, H, ["#040a1a", "#081a2c", "#0e3240", "#1a5a62", "#2c8a86"],
                   np.clip(np.repeat(np.arange(H)[:, None] / 150.0, W, 1) ** 1.3 + sunglow(W, H, 330, 70, 150, 100) * 0.3, 0, 1))
    MX, MY = 330, 66
    d = ImageDraw.Draw(sky)
    for r, col in [(30, hx("1e5860")), (26, hx("3a8284")), (22, hx("8fc4c0")), (19, hx("e4f4ee"))]:
        d.ellipse((MX - r, MY - r, MX + r, MY + r), fill=col)
    a = arr(sky)
    yy, xx = np.mgrid[0:H, 0:W]
    cr = (np.hypot(xx - MX, yy - MY) < 18) & (fbm2(W, H, 5, 5, 3, 2) > 0.58) & (bay(H, W) < 0.8)
    a[cr] = hx("b4d4d0")
    sky = img(a)
    stars = make_stars(21, 70, 100)
    clouds = [(cloud_band(480, 16, th, sd, hx("12404c"), hx("0a2634"), cell=100, floor=0.3), y, sp) for y, th, sp, sd in [(40, 6, 3, 5), (100, 7, 5, 6), (126, 5, 4, 7)]]
    # karst stacks (speed 8) with the shrine
    ks = newl()
    kp = np.full(LW, 400.0)
    def stack(cx, wd, top, steep):
        for x in range(cx - wd, cx + wd):
            k = abs(x - cx) / wd
            y = top + (k ** steep) * (HZ + 20 - top)
            kp[x] = min(kp[x], y + noise1(LW, 8, x // 9 + 3, 1)[x] * 6 if False else y)
    stack(430, 70, 96, 1.6)
    stack(500, 50, 124, 1.5)
    stack(70, 40, 128, 1.7)
    kp = kp + noise1(LW, 10, 12, 3) * 5 * (kp < 300)
    ks = fill_below(ks, kp, hx("0a1c26"), rim=hx("7fc4c0"))
    a = arr(ks)
    yy2, xx2 = np.mgrid[0:H, 0:LW]
    ins = a[..., 3] > 0
    dep = yy2 - np.round(kp).astype(int)[None, :]
    a[ins & (dep < 12) & (xx2 < 440) & (bay(H, LW) < 0.45)] = hx("16384a")
    a[ins & (dep > 30) & (bay(H, LW) < 0.4)] = hx("060e18")
    ks = img(a)
    d = ImageDraw.Draw(ks)
    SHX, SHY = 428, int(kp[428])
    d.rectangle((SHX - 8, SHY - 7, SHX + 8, SHY), fill=hx("2a3c4a"))
    for k, (hw_, yb) in enumerate([(11, SHY - 7), (8, SHY - 11), (5, SHY - 15)]):          # tiered tumpang roof
        d.polygon([(SHX - hw_, yb), (SHX - hw_ + 3, yb - 4), (SHX + hw_ - 3, yb - 4), (SHX + hw_, yb)], fill=hx("1a2c3c"))
        d.line([(SHX - hw_, yb), (SHX - hw_ + 3, yb - 4)], fill=hx("8fc4c0"))
    d.point((SHX, SHY - 20), fill=hx("ffd060"))
    d.rectangle((SHX - 2, SHY - 6, SHX + 2, SHY - 1), fill=hx("ffb040"))
    for dx in (-7, -5, 5, 7):
        d.point((SHX + dx, SHY - 1), fill=hx("ffd060"))
        d.point((SHX + dx, SHY - 2), fill=hx("e86a50"))
    # wave bands (periodic over 640 so they wrap): far to near
    bands = []
    spec = [(158, 3, 5, "#0e3a48", "#2a7a84", 4, 1), (168, 4, 6, "#0c3440", "#2c8a8a", 5, 2), (181, 5, 8, "#0a2c38", "#34988e", 6, 3),
            (198, 7, 10, "#08242f", "#48ac98", 7, 1), (222, 9, 14, "#061c28", "#68c8ae", 8, 2), (250, 11, 20, "#04141e", "#8ee0c0", 9, 3)]
    for base, amp, spd, col, crest, nper, ph in spec:
        L = newl()
        x = np.arange(LW)
        u = x * 2 * math.pi / LW
        p = base + np.sin(u * nper + ph) * amp + np.sin(u * (nper + 2) + ph * 2.3) * amp * 0.6 + np.sin(u * (2 * nper + 1) + ph * 0.7) * amp * 0.3
        p = p + np.abs(np.sin(u * (nper + 1) * 0.5 + ph)) * amp * 0.5
        L = fill_below(L, p, hx(col), rim=hx(crest), rim2=hx(crest), haze=hx(crest), haze_h=5)
        a = arr(L)
        ins = a[..., 3] > 0
        dd = yy2 - np.round(p).astype(int)[None, :]
        a[ins & (dd > 6) & (dd < 12) & (bay(H, LW) < 0.25)] = hx(crest)
        L = img(a)
        bands.append((L, p, spd, crest))
    # palace lights far out, under the horizon
    return dict(sky=sky, stars=stars, clouds=clouds, ks=ks, bands=bands, MX=MX)


@scene("vista_kidul", DUR)
def vista_kidul(dur=DUR):
    K = _kidul()
    lamps = [(150, 153), (158, 154), (166, 151), (174, 154), (182, 152), (190, 154), (162, 156), (178, 156), (170, 148)]

    def fn(t):
        c = Image.new("RGBA", (W, H))
        c.alpha_composite(K["sky"])
        twinkle(c, K["stars"], t, [hx("2a5a6a"), hx("6aa8b0"), hx("c8ece8"), hx("ffffff")])
        for cb, y, spd in K["clouds"]:
            view(c, cb, spd * t, y, wrap=True)
        view(c, K["ks"], 20 + 7 * t)
        # the sea floor lights of her palace glimmer under the swell
        for i, (lx, ly) in enumerate(lamps):
            flicker(c, lx, ly, t, i * 2, [hx("7affc8"), hx("2aa88a")])
        for i, (L, p, spd, crest) in enumerate(K["bands"]):
            view(c, L, 20 + spd * t, 0, wrap=True)
            if i == 2:       # moon path on the water (before the nearer swells)
                for y in range(156, 215):
                    wd = 4 + (y - 156) // 2
                    for dx in range(-wd, wd + 1):
                        if (int(t * 3 + y * 0.7 + dx * 1.3)) % 3 == 0:
                            px(c, K["MX"] + dx + int(math.sin(t * 1.5 + y) * 1), y, hx("e4f4ee") if abs(dx) < wd // 2 else hx("8fc4c0"))
        # silver foam on the near crests
        for i, (L, p, spd, crest) in enumerate(K["bands"][3:]):
            off = int(20 + spd * t)
            for x in range(0, W, 3):
                y = int(p[(x + off) % LW])
                if int(t * 4 + x * 0.37 + i) % 5 < 2:
                    px(c, x, y - 1, hx("dff4ec"))
        for i, (bx, by, sp) in enumerate([(-10, 112, 12), (-80, 128, 10)]):
            bird(c, (bx + sp * t + 170 * i) % 560 - 40, by + int(math.sin(t * 1.0 + i) * 2), int(t * 5 + i), hx("0a1c26"))
        motes(c, t, 12, 12, (0, 200, W, 262), [hx("c8f0e0"), hx("7acab8"), hx("2a7a78")], (3, 6), 6, True)
        return finish(c, t, dur)
    return fn


# ============================================================================ 6. KALA
HERO = ["....c....",
        "....c....",
        "....c.hh.",
        "....c.hhh",
        "....cbbbb",
        "....bbbbb",
        "...bbbbbb",
        "...bbbbbb",
        "...bbbbbb",
        "...bbbbbb",
        "..bbbbbbb",
        "..bbbbbbb"]


def _kala():
    cols = ["#06040e", "#0e0a22", "#1c1240", "#2c1a5e", "#4a2a8a"]
    bg = gradient(W, H, cols, np.clip(1 - np.hypot(np.mgrid[0:H, 0:W][1] - 250, (np.mgrid[0:H, 0:W][0] - 170) * 1.4) / 230.0, 0, 1))
    a = arr(bg)
    yy, xx = np.mgrid[0:H, 0:W]
    # far arches / depth ribs inside the cave
    far = newl(LW)
    d = ImageDraw.Draw(far)
    for i, cx in enumerate([120, 260, 400, 540]):
        d.polygon([(cx - 40, 240), (cx - 30, 120), (cx, 90), (cx + 30, 120), (cx + 40, 240)], fill=hx("160e34"))
        d.polygon([(cx - 26, 240), (cx - 20, 130), (cx, 108), (cx + 20, 130), (cx + 26, 240)], fill=hx("231552"))
    far = rim_light(far, hx("5a38a8"), 1, 0)
    # the mouth: heavy rock frame carved like a kala face (brows, eye sockets, fangs, jaw)
    fr = newl()
    d = ImageDraw.Draw(fr)
    d.rectangle((0, 0, LW, H), fill=hx("0a0618"))
    m = Image.new("L", (LW, H), 0)
    md = ImageDraw.Draw(m)
    OX = 270                                                       # mouth centre in layer coords (screen 240 at off 40 -> shifted)
    mouth = [(OX - 110, 250), (OX - 104, 160), (OX - 84, 130), (OX - 50, 118), (OX, 112), (OX + 50, 118), (OX + 84, 130), (OX + 104, 160), (OX + 110, 250)]
    md.polygon(mouth, fill=255)
    mm = np.array(m) > 0
    fa = arr(fr)
    fa[mm] = (0, 0, 0, 0)
    fr = img(fa)
    fr = tone(fr, fbm2(LW, H, 30, 16, 3, 3), 0.52, 0.2, hx("1c1240"), 0.45)
    d = ImageDraw.Draw(fr)
    ys = 52
    for sgn in (-1, 1):
        ex = OX + sgn * 52
        d.polygon([(ex - 30, ys + 18), (ex - 24, ys + 4), (ex + 10, ys - 6), (ex + 30, ys + 4), (ex + 26, ys + 22), (ex, ys + 26)], fill=hx("1c1240"))
        d.polygon([(ex - 22, ys + 14), (ex - 12, ys + 8), (ex + 14, ys + 6), (ex + 22, ys + 14), (ex, ys + 20)], fill=hx("06040e"))   # eye socket
        d.line([(ex - 30, ys + 4), (ex + 6, ys - 8), (ex + 32, ys)], fill=hx("4a2a8a"), width=2)          # heavy brow
    d.polygon([(OX - 6, ys + 4), (OX + 6, ys + 4), (OX + 10, 112), (OX - 10, 112)], fill=hx("1c1240"))      # nose bridge
    d.polygon([(OX - 16, ys + 30), (OX + 16, ys + 30), (OX + 10, 108), (OX - 10, 108)], fill=hx("160e34"))
    # fangs hanging from the upper jaw, tusks rising from the lower
    for fx, ln in [(OX - 78, 14), (OX - 60, 22), (OX - 40, 12), (OX - 22, 34), (OX + 22, 34), (OX + 40, 12), (OX + 60, 22), (OX + 78, 14)]:
        d.polygon([(fx - 6, 126), (fx + 6, 126), (fx, 126 + ln)], fill=hx("e8e0f4") if ln > 30 else hx("a89cc8"))
    fa = arr(fr)
    fr = rim_light(img(fa), hx("5a38b0"), 0, 1)
    return bg, far, fr, OX


def _crystal(im, x, y, h, w, seed):
    r = random.Random(seed)
    d = ImageDraw.Draw(im)
    for i in range(3):
        cx = x + i * w // 2 + r.randint(-2, 2)
        hh = h * (1 - 0.25 * i) + r.randint(-4, 4)
        d.polygon([(cx - w // 2, y), (cx - w // 3, y - hh + 6), (cx, y - hh), (cx + w // 3, y - hh + 8), (cx + w // 2, y)], fill=hx("5a2ab0"))
        d.polygon([(cx - w // 3, y - 1), (cx - w // 3, y - hh + 6), (cx, y - hh)], fill=hx("9a62f0"))
        d.line([(cx, y - hh), (cx + 1, y - hh // 2)], fill=hx("d8b8ff"))
        d.polygon([(cx + w // 4, y), (cx + w // 3, y - hh + 8), (cx + w // 2, y)], fill=hx("341a74"))


@scene("vista_kala", DUR)
def vista_kala(dur=DUR):
    bg, far, fr, OX = _kala()
    fl = newl()
    fp = prof_pts([(0, 232), (200, 228), (400, 230), (640, 226)], smooth=3)
    fl = fill_below(fl, fp, hx("100a28"), rim=hx("6a40c8"), rim2=hx("3a2290"))
    a = arr(fl)
    yy, xx = np.mgrid[0:H, 0:LW]
    a[(a[..., 3] > 0) & (yy > 236) & (bay(H, LW) < 0.5)] = hx("0a0618")
    fl = img(a)
    cr_l, cr_r = newl(), newl()
    _crystal(cr_l, 40, 262, 64, 22, 1)
    _crystal(cr_l, 96, 270, 36, 14, 2)
    _crystal(cr_r, 520, 262, 70, 24, 3)
    _crystal(cr_r, 470, 270, 34, 14, 4)
    hero = spr(HERO, {"c": hx("7fe8e0"), "h": hx("2a2060"), "b": hx("1a1240")})
    ha = arr(hero)
    ha[3, 0] = (0, 0, 0, 0)
    for y in range(4, 12):
        xs = np.where(ha[y, :, 3] > 0)[0]
        ha[y, xs.min()] = hx("5ac8d0")
    hero = img(ha)
    stars_ = make_stars(30, 40, 110)

    def fn(t):
        c = Image.new("RGBA", (W, H))
        c.alpha_composite(bg)
        view(c, far, 30 + 4 * t)
        off = 20 + 7 * t
        view(c, fr, off)
        # two dim eye-glows burning in the carved sockets
        for sgn in (-1, 1):
            ex = OX + sgn * 52 - int(off) + 2
            lvl = 0.55 + 0.25 * math.sin(t * 2.2 + sgn)
            for yy_ in range(-7, 8):
                for xx_ in range(-12, 13):
                    dd = (xx_ / 12.0) ** 2 + (yy_ / 6.0) ** 2
                    if dd < 1 and BY4[(60 + yy_) % 4, (ex + xx_) % 4] < (1 - dd) * lvl * 1.6:
                        px(c, ex + xx_, 66 + yy_, hx("c8a0ff") if dd < 0.25 else (hx("8a5ae0") if dd < 0.6 else hx("5a38a8")))
        # the sand trickle between the central fangs, pooling on the threshold
        sx = OX - int(off)
        for k in range(26):
            y = 120 + ((k * 4 + int(t * 40)) % 104)
            px(c, sx, y, hx("f0d890") if k % 2 else hx("c8a860"))
        px(c, sx - 1, 224, hx("c8a860")); px(c, sx + 1, 224, hx("c8a860"))
        for i in range(5):
            for dx in range(-(5 - i), 6 - i):
                px(c, sx + dx, 226 + i - 4 + 4, hx("d8b870") if (dx + i) % 3 else hx("a88848"))
        view(c, fl, off)
        # hero at the threshold, cyan staff pulsing
        hxp = OX + 52 - int(off)
        hyp = int(fp[OX + 52]) - 12
        put(c, hero, hxp, hyp)
        pul = 0.6 + 0.3 * math.sin(t * 3)
        for yy_ in range(-9, 10):
            for xx_ in range(-9, 10):
                dd = math.hypot(xx_, yy_) / 9
                if dd < 1 and BY4[(hyp + yy_) % 4, (hxp + 4 + xx_) % 4] < (1 - dd) * pul * 0.9:
                    px(c, hxp + 4 + xx_, hyp - 1 + yy_, hx("7fe8e0") if dd < 0.3 else hx("3a9aa8"))
        px(c, hxp + 4, hyp - 1, hx("ffffff")); px(c, hxp + 4, hyp, hx("d8fffb"))
        view(c, cr_l, 20 + 22 * t * 0.5)
        view(c, cr_r, 20 + 22 * t * 0.5)
        motes(c, t, 6, 26, (0, 40, W, 230), [hx("d8fffb"), hx("a888f0"), hx("5a38a8")], (3, 9), 8, True)
        twinkle(c, [(x, y, k, p) for x, y, k, p in stars_ if y > 0][:6], t, [hx("5a38a8"), hx("8a68d8"), hx("c8a8ff"), hx("ffffff")])
        return finish(c, t, dur)
    return fn
