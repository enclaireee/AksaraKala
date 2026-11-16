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
