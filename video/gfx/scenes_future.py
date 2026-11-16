"""Segment 7, "What's next": animated mock-ups of features in development (skins, co-op, mobile + classroom, map).
Registered into the same SCENES dict as scenes.py (render_all imports this module). 480x270 native, opaque."""
import colorsys
import math
import os
import random
from functools import lru_cache

import numpy as np
from PIL import Image, ImageDraw, ImageFont

from pxkit import *            # noqa: F401,F403
import pxkit as K
from scenes import SCENES, scene, finish, SHADOW, GLOW_C, typed   # noqa: F401

FUT_FONTS = os.path.join(HERE, "fonts")   # noqa: F405
DARK = rgb("0F0C20")
PANEL_BG = rgb("120E24")
GOLD = rgb("E2B64A")
SOFT = rgb("D8CCE8")


def putpx(c, xy, col):
    if 0 <= xy[0] < c.width and 0 <= xy[1] < c.height:
        c.putpixel(xy, col)


def diamond(c, x, y, size=5, col=CYAN, core=CYAN_HI):          # clipped version (panels slide in from off-screen)
    r = size // 2
    px = c.load()
    for dy in range(-r, r + 1):
        k = r - abs(dy)
        for dx in range(-k, k + 1):
            if 0 <= x + dx < W and 0 <= y + dy < H:
                px[x + dx, y + dy] = col
    if core and size >= 5 and 0 <= x < W and 0 <= y < H:
        px[x, y] = core


def rule(c, x0, x1, y, col=HAIR, mid=CYAN, gap=0):
    d = ImageDraw.Draw(c)
    cx = (x0 + x1) // 2
    d.line([(x0, y), (cx - 6 - gap, y)], fill=col)
    d.line([(cx + 6 + gap, y), (x1, y)], fill=col)
    diamond(c, cx, y, 5, mid, CYAN_HI)


# ================================================================ generic helpers
def cell(path, col, row, cw=32, ch=32):
    return load(path).crop((col * cw, row * ch, (col + 1) * cw, (row + 1) * ch))


def blit(c, im, x, y, flip=False):
    if flip:
        im = im.transpose(Image.FLIP_LEFT_RIGHT)
    paste(c, im, x, y)


def rect(c, x0, y0, x1, y1, col):
    ImageDraw.Draw(c).rectangle([int(x0), int(y0), int(x1), int(y1)], fill=col)


def hline(c, x0, x1, y, col):
    ImageDraw.Draw(c).line([(int(x0), int(y)), (int(x1), int(y))], fill=col)


def recolor(im, rules):
    """rules: list of (h_lo, h_hi, s_min, v_min, dh, ds_mul, dv_mul, set_s). Hue in degrees (circular range lo..hi).
    A pixel matching a rule has its hue shifted by dh, S scaled, V scaled (clamped). Hard alpha preserved."""
    a = np.array(im).astype(float)
    rgbf = a[..., :3] / 255.0
    mx, mn = rgbf.max(-1), rgbf.min(-1)
    v = mx
    d = mx - mn
    s = np.where(mx > 0, d / np.maximum(mx, 1e-9), 0)
    r, g, b = rgbf[..., 0], rgbf[..., 1], rgbf[..., 2]
    h = np.zeros_like(v)
    dd = np.maximum(d, 1e-9)
    h = np.where(mx == r, ((g - b) / dd) % 6, h)
    h = np.where(mx == g, (b - r) / dd + 2, h)
    h = np.where(mx == b, (r - g) / dd + 4, h)
    h = np.where(d == 0, 0, h) * 60.0
    done = np.zeros(v.shape, bool)
    H2, S2, V2 = h.copy(), s.copy(), v.copy()
    for (lo, hi, smin, vmin, dh, dsm, dvm, sset) in rules:
        if lo <= hi:
            inr = (h >= lo) & (h <= hi)
        else:
            inr = (h >= lo) | (h <= hi)
        m = inr & (s >= smin) & (v >= vmin) & ~done & (a[..., 3] > 0)
        H2 = np.where(m, (h + dh) % 360, H2)
        S2 = np.where(m, (np.minimum(1, s * dsm) if sset is None else sset), S2)
        V2 = np.where(m, np.minimum(1, v * dvm), V2)
        done |= m
    out = a.copy()
    hh = (H2 / 60.0) % 6
    c_ = V2 * S2
    x_ = c_ * (1 - np.abs(hh % 2 - 1))
    m_ = V2 - c_
    z = np.zeros_like(hh)
    sel = [(c_, x_, z), (x_, c_, z), (z, c_, x_), (z, x_, c_), (x_, z, c_), (c_, z, x_)]
    R = np.zeros_like(hh); G = np.zeros_like(hh); B = np.zeros_like(hh)
    for i, (rr, gg, bb) in enumerate(sel):
        mm = (np.floor(hh).astype(int) % 6) == i
        R = np.where(mm, rr, R); G = np.where(mm, gg, G); B = np.where(mm, bb, B)
    out[..., 0] = (R + m_) * 255
    out[..., 1] = (G + m_) * 255
    out[..., 2] = (B + m_) * 255
    return Image.fromarray(np.clip(out + 0.5, 0, 255).astype("uint8"), "RGBA")


def blend_dither(a, b, p, steps=8):
    """Per-pixel Bayer-dither crossfade between equal-size RGBA images (hard alpha)."""
    p = math.floor(clamp(p) * steps + 1e-9) / steps if p < 1 else 1.0
    A, B = np.array(a), np.array(b)
    h, w = A.shape[:2]
    thr = (BAYER4[np.arange(h)[:, None] % 4, np.arange(w)[None, :] % 4] + 0.5) / 16.0
    return Image.fromarray(np.where((thr <= p)[..., None], B, A), "RGBA")


def tag_layer(c, t):
    tg = SCENES["tag_in_development"][0]()(t)
    c.alpha_composite(tg)


def header_chip(c, t, title, sub, t0=0.15):
    """Title chip top-left (slides in from the left, stepped). Returns bottom y."""
    wt = max(text_w(title, SUB), text_w(sub, LABEL)) + 26
    h = 46
    off, vis = slide(t, t0, 1e9, 0.4, 0.3, dist=wt + 20, steps=8)
    if not vis:
        return
    x = SAFE - off
    chip(c, x, SAFE, wt, h, FILL, HAIR_LO, accent=AMBER)
    text(c, title, x + 10, SAFE + 3, SUB, CREAM)
    text(c, sub, x + 10, SAFE + 26, LABEL, LABEL_C)


def dpanel(c, x, y, w, h, fill=PANEL_BG, hair=HAIR, edge=EDGE):
    paste(c, panel(w, h, hair, fill, edge), x, y)


def sparkle_cluster(c, t, cx, cy, t0, dur=1.2, n=8, spread=34, seed=1):
    if t < t0 or t > t0 + dur:
        return
    r = random.Random(seed)
    for i in range(n):
        dx, dy = r.uniform(-spread, spread), r.uniform(-spread * 0.8, spread * 0.8)
        sparkle(c, int(cx + dx), int(cy + dy), t - t0 - r.random() * 0.3, period=0.55, size=3 if i % 3 == 0 else 2)


def cursor_at(c, x, y, pressed=False):
    cur = load("ui/cursor.png")
    off = 1 if pressed else 0
    paste(c, cur, int(x) + off, int(y) + off)


def path_pos(keys, t):
    """keys: [(t, x, y)]; stepped ease-in-out between keys. Returns (x, y)."""
    if t <= keys[0][0]:
        return keys[0][1], keys[0][2]
    for (t0, x0, y0), (t1, x1, y1) in zip(keys[:-1], keys[1:]):
        if t < t1:
            p = step_ease(ease_io(prog(t, t0, t1 - t0)), 24)
            return ri(lerp(x0, x1, p)), ri(lerp(y0, y1, p))
    return keys[-1][1], keys[-1][2]


def icon_heart(c, x, y, col=ROSE):
    for dx, dy in ((1, 0), (2, 0), (4, 0), (5, 0), (0, 1), (1, 1), (2, 1), (3, 1), (4, 1), (5, 1), (6, 1), (0, 2), (1, 2),
                   (2, 2), (3, 2), (4, 2), (5, 2), (6, 2), (1, 3), (2, 3), (3, 3), (4, 3), (5, 3), (2, 4), (3, 4), (4, 4),
                   (3, 5)):
        putpx(c, (x + dx, y + dy), col)
    putpx(c, (x + 1, y + 1), rgb("FFB0B8"))


def icon_coin(c, x, y, t=0.0):
    pts = [(1, 0), (2, 0), (3, 0), (0, 1), (4, 1), (0, 2), (4, 2), (0, 3), (4, 3), (1, 4), (2, 4), (3, 4)]
    for dx, dy in pts:
        putpx(c, (x + dx, y + dy), AMBER_LO)
    for dx, dy in ((1, 1), (2, 1), (3, 1), (1, 2), (2, 2), (3, 2), (1, 3), (2, 3), (3, 3)):
        putpx(c, (x + dx, y + dy), GOLD)
    putpx(c, (x + 1, y + 1), AMBER_HI)


def bar(c, x, y, w, h, p, col=CYAN, back=HAIR_LO, edge=EDGE, hi=CYAN_HI):
    rect(c, x, y, x + w - 1, y + h - 1, edge)
    rect(c, x + 1, y + 1, x + w - 2, y + h - 2, back)
    fw = ri((w - 2) * clamp(p))
    if fw > 0:
        rect(c, x + 1, y + 1, x + fw, y + h - 2, col)
        hline(c, x + 1, x + fw, y + 1, hi)


def stage_light(c, cx, top, floor_y, wtop, wbot, core=rgb("2A2250"), edge=rgb("1E1840")):
    """Dithered spotlight cone from y=top to floor_y (hard pixels: solid core + checker edge)."""
    d = ImageDraw.Draw(c)
    px = c.load()
    for y in range(top, floor_y):
        k = (y - top) / max(1, floor_y - top)
        hw = lerp(wtop, wbot, k) / 2
        for x in range(int(cx - hw) - 2, int(cx + hw) + 3):
            ax = abs(x - cx)
            if 0 <= x < W and ax <= hw - 5:
                if BAYER4[y % 4, x % 4] / 16.0 < 0.55 - 0.3 * k + (1 if ax < hw * 0.45 else 0) * 0.45:
                    px[x, y] = core
            elif 0 <= x < W and ax <= hw:
                if (x + y) % 2 == 0:
                    px[x, y] = edge


def pedestal(c, cx, y, t=0.0, glow=CYAN):
    """Round plinth: top ellipse, side drum, a ring of lights."""
    top = rgb("5A4E80")
    side = rgb("2B2347")
    d = ImageDraw.Draw(c)
    d.ellipse([cx - 38, y + 4, cx + 38, y + 20], fill=EDGE)
    d.rectangle([cx - 36, y + 10, cx + 36, y + 17], fill=side)
    d.ellipse([cx - 36, y + 11, cx + 36, y + 21], fill=side)
    d.ellipse([cx - 36, y + 2, cx + 36, y + 16], fill=rgb("3A2F5C"))
    d.ellipse([cx - 32, y + 4, cx + 32, y + 13], fill=top)
    d.ellipse([cx - 26, y + 5, cx + 26, y + 11], fill=rgb("7A6CA8"))
    for i in range(9):
        lx = cx - 32 + i * 8
        on = (int(t * 6) + i) % 9 < 3
        putpx(c, (lx, y + 16), glow if on else DIM_LO)
        putpx(c, (lx + 1, y + 16), glow if on else DIM_LO)


# ================================================================ skins
SKIN_RULES = {
    # indigo jacket -> cream beskap putih; the brown parang kain stays
    "dalang": [(200, 275, 0.4, 0.0, 0, 0.0, 2.25, 0.0), ],
    # red sabuk / headcloth -> ochre
    "rogue": [(330, 12, 0.6, 0.0, 44, 1.0, 1.05, None)],
    # red hulubalang -> golek green
    "warrior": [(330, 10, 0.55, 0.0, 150, 0.95, 1.05, None)],
    # magenta -> vermilion red
    "dancer": [(296, 352, 0.4, 0.0, 34, 1.0, 1.0, None)],
}
SKINS = [
    dict(cls="dalang", name="Batik Parang Sogan", artist="Local artist, Garut", price="Rp20.000", klass="DALANG",
         blurb=["Unbroken parang diagonals mean steady", "effort. Once court cloth in Java."],
         sw=["F4EBD6", "7C5634", "C4844F", "FFC860"], pal=GOLD),
    dict(cls="rogue", name="Pangsi Hideung", artist="Local artist, Bandung", price="Rp20.000", klass="ROGUE",
         blurb=["The loose black pangsi, worn by Sundanese", "farmers and pendekar alike."],
         sw=["2E2A38", "3A3644", "D0A244", "E8B27E"], pal=AMBER),
    dict(cls="warrior", name="Golek Satria", artist="Local artist, Cirebon", price="Rp20.000", klass="WARRIOR",
         blurb=["Inspired by wayang golek, the carved", "rod puppets of West Java."],
         sw=["2F8A5A", "E2B64A", "AE6E44", "7E2226"], pal=GREEN),
    dict(cls="dancer", name="Topeng Cirebon", artist="Local artist, Yogyakarta", price="Rp20.000", klass="DANCER",
         blurb=["Mask dance of Cirebon: every mask is", "a character, calm to wild."],
         sw=["C43A2E", "E2B64A", "30A89A", "F6D2A6"], pal=ROSE),
]


@lru_cache(maxsize=None)
def skin_assets(i):
    s = SKINS[i]
    cls = s["cls"]
    rules = SKIN_RULES[cls]
    port = Image.open(os.path.join(ART, "portraits", f"class_{cls}.png")).convert("RGBA")
    port = hard(recolor(port, rules))
    frames = [port.crop((k * 96, 0, k * 96 + 96, 128)) for k in range(6)]
    sheet = hard(recolor(load(f"hero_{cls}.png"), rules))
    return frames, sheet


def sprite_cell(sheet, col, row):
    return sheet.crop((col * 32, row * 32, col * 32 + 32, row * 32 + 32))


@scene("fut_skins", 8.0)
def fut_skins(dur=8.0):
    st = Stars(61, 60, 0.7)
    em = Embers(71, 16, CYAN_RAMP, speed=(6, 16), sway=4, area=(20, 76, 248, 206))
    SX, SY, SW, SH = 16, 70, 236, 184
    CX, CY, CW, CH = 260, 70, 204, 184
    switch = [0.0, 1.9, 3.5, 5.1]                 # when skin i becomes selected
    slot_x = [50 + i * 44 for i in range(4)]
    slot_y = 216
    buy_btn = (CX + CW - 78, CY + 120, 66, 24)
    cur_keys = [(0.5, 440, 120), (1.4, slot_x[1] + 20, slot_y + 18), (3.0, slot_x[2] + 20, slot_y + 18),
                (4.6, slot_x[3] + 20, slot_y + 18), (5.7, buy_btn[0] + 36, buy_btn[1] + 12),
                (6.7, buy_btn[0] + 36, buy_btn[1] + 12), (7.6, buy_btn[0] - 30, buy_btn[1] - 50)]
    click_t = [1.9, 3.5, 5.1, 6.25]
    BUY_T = 6.25

    def sel_at(t):
        i = 0
        for k, s0 in enumerate(switch):
            if t >= s0:
                i = k
        return i

    def draw_hero(c, t, i, cx, feet):
        frames, _ = skin_assets(i)
        f = int(t * 6) % 6
        im = frames[f]
        # slow turntable half way through each skin's time
        s0 = switch[i]
        q = prog(t, s0 + 0.75, 0.7)
        if 0 < q < 1:
            cs = math.cos(2 * math.pi * q)
            w = max(2, int(abs(cs) * 6 + 0.5)) * 16
            if w != 96 or cs < 0:
                im = im.transpose(Image.FLIP_LEFT_RIGHT) if cs < 0 else im
                im = im.resize((w, 128), Image.NEAREST)
                paste(c, im, cx - w // 2, feet - 128)
                return
        paste(c, im, cx - 48, feet - 128)

    def fn(t):
        c = night_bg(t, st)
        header_chip(c, t, "Skin shop", "Made by local artists", 0.15)
        # ------- stage panel
        so, sv = slide(t, 0.35, 1e9, 0.45, dist=60, steps=8)
        if sv:
            sx = SX - so
            st_img = canvas()
            dpanel(st_img, sx, SY, SW, SH)
            rect(st_img, sx + 3, SY + 3, sx + SW - 4, SY + SH - 4, DARK)
            c.alpha_composite(st_img)
        if t >= 0.8:
            clip = c.crop((SX + 3, SY + 3, SX + SW - 3, SY + SH - 3))
            sub = Image.new("RGBA", clip.size, DARK)
            stage_light(sub, 134 - (SX + 3), 0, 130, 38, 120)
            # light pool on the floor
            em.draw(c, t) if False else None
            c.paste(sub, (SX + 3, SY + 3))
            em.draw(c, t - 0.8)
            pedestal(c, 134, 186, t)
            # sparkle floor line
            # hero
            i = sel_at(t)
            fade = prog(t, 0.8, 0.5)
            if i == 0 and t < switch[0] + 1.3:
                im = skin_assets(0)[0][int(t * 6) % 6]
                if fade < 1:
                    base = Image.new("RGBA", (96, 128), CLEAR)
                    base2 = blend_dither(base, im, fade, 10)
                    paste(c, base2, 134 - 48, 202 - 128)
                else:
                    draw_hero(c, t, 0, 134, 202)
            else:
                tr = prog(t, switch[i], 0.45) if i > 0 else 1.0
                if tr < 1:
                    a_im = skin_assets(i - 1)[0][int(t * 6) % 6]
                    b_im = skin_assets(i)[0][int(t * 6) % 6]
                    paste(c, blend_dither(a_im, b_im, tr, 10), 134 - 48, 202 - 128)
                    if 0.1 < tr < 0.9:
                        for k in range(6):
                            sparkle(c, 134 - 30 + k * 12, 206 - 110 + (k * 37) % 90, t + k * 0.1, period=0.4, size=2)
                else:
                    draw_hero(c, t, i, 134, 202)
            # in-game preview window (real sprite sheet, walking)
            pv_x, pv_y = SX + 10, SY + 10
            dpanel(c, pv_x, pv_y, 44, 56, FILL, HAIR_LO)
            text(c, "PREVIEW", pv_x + 22, pv_y + 3, CAP, DIM, "c")
            _, sheet = skin_assets(i)
            dirs = [(3, False), (4, False), (5, False), (4, True)]
            di = int(t / 0.9) % 4
            row, fl = dirs[di]
            col = int(t * 8) % 6
            sp = sprite_cell(sheet, col, row)
            blit(c, sp.crop((0, 4, 32, 32)), pv_x + 6, pv_y + 18, fl)
            # slots
            for k in range(4):
                sx0 = slot_x[k]
                sel = k == i
                dpanel(c, sx0, slot_y, 40, 34, FILL if not sel else rgb("1B2A3E"), CYAN if sel else HAIR_LO)
                sh = skin_assets(k)[1]
                bob = 0 if not sel else (int(t * 4) % 2) * -1
                blit(c, sprite_cell(sh, int(t * 4) % 4, 0).crop((0, 3, 32, 31)), sx0 + 4, slot_y + 3 + bob)
                if sel:
                    for dx, dy in ((0, 0), (39, 0), (0, 33), (39, 33)):
                        putpx(c, (sx0 + dx, slot_y + dy), CYAN_HI)
        # ------- card
        co, cv = slide(t, 0.6, 1e9, 0.45, dist=240, steps=8)
        if cv:
            cx0 = CX + co
            dpanel(c, cx0, CY, CW, CH)
            i = sel_at(t)
            s = SKINS[i]
            q = prog(t, switch[i] + 0.05, 0.45) if t > 1.0 else prog(t, 0.9, 0.5)
            md = m_dither(q, 8)
            px0 = cx0 + 12
            # class chip + counter
            text(c, s["klass"], px0, CY + 9, CAP, s["pal"], "l", track=1, mod=md)
            text(c, f"SKIN {i + 1}/4", cx0 + CW - 12, CY + 9, CAP, DIM, "r", track=1)
            text(c, s["name"], px0, CY + 21, SUB, CREAM, "l", mod=md)
            # artist line with brush icon
            rect(c, px0, CY + 48, px0 + 1, CY + 53, AMBER)
            rect(c, px0 + 2, CY + 52, px0 + 4, CY + 54, AMBER_LO)
            text(c, "by " + s["artist"], px0 + 8, CY + 47, CAP, LABEL_C, "l", mod=md)
            rule(c, px0, cx0 + CW - 12, CY + 62)
            text(c, "ORIGIN & MEANING", px0, CY + 68, CAP, AMBER, "l", track=1, mod=md)
            for k, ln in enumerate(s["blurb"]):
                text(c, ln, px0, CY + 80 + k * 11, CAP, TEXT, "l", mod=md)
            # palette swatches
            text(c, "PALETTE", px0, CY + 106, CAP, DIM, "l", track=1)
            for k, hx in enumerate(s["sw"]):
                rect(c, px0 + 44 + k * 12, CY + 105, px0 + 53 + k * 12, CY + 113, EDGE)
                rect(c, px0 + 45 + k * 12, CY + 106, px0 + 52 + k * 12, CY + 112, rgb(hx))
            # price + buy
            text(c, "Rp20.000", px0, CY + 124, TITLE, AMBER, "l", shadow=SHADOW)
            bx, by, bw, bh = buy_btn
            bx += co
            bought = t >= BUY_T + 0.1
            pressed = BUY_T <= t < BUY_T + 0.15
            hover = t > 5.9
            if not bought:
                paste(c, panel(bw, bh, CYAN if hover else CYAN_HALO, rgb("1F3A4A") if hover else rgb("162838")), bx, by + (1 if pressed else 0))
                text(c, "BUY", bx + bw // 2, by + 1 + (1 if pressed else 0), SUB, CYAN_HI if hover else CYAN, "c")
            else:
                paste(c, panel(bw, bh, GREEN_LO, rgb("173324")), bx, by)
                text(c, "OWNED", bx + bw // 2 + 8, by + 1, SUB, GREEN, "c")
                for dx, dy in ((0, 4), (1, 5), (2, 6), (3, 5), (4, 4), (5, 3), (6, 2), (7, 1)):
                    putpx(c, (bx + 5 + dx, by + 6 + dy), GREEN)
            rule(c, px0, cx0 + CW - 12, CY + 154)
            # earn line
            icon_heart(c, px0, CY + 163, ROSE)
            text(c, "Artists earn from every sale", px0 + 11, CY + 162, CAP, GREEN, "l")
            # coins fly from the button to the artist line after purchase
            if BUY_T + 0.1 < t < BUY_T + 1.5:
                for k in range(6):
                    p = prog(t, BUY_T + 0.15 + k * 0.1, 0.7)
                    if 0 < p < 1:
                        x = lerp(bx + 10, px0 + 4, ease_io(p))
                        y = lerp(by + 22, CY + 164, p) - math.sin(p * math.pi) * 26
                        icon_coin(c, int(x), int(y))
        # ------- cursor + purchase sparkle
        if t > 0.5:
            x, y = path_pos(cur_keys, t)
            x += 0
            pr = any(abs(t - ct) < 0.1 for ct in click_t)
            cursor_at(c, x, y, pr)
        if t > BUY_T:
            sparkle_cluster(c, t, 134, 140, BUY_T + 0.1, 1.4, 12, 46, 5)
            sparkle_cluster(c, t, buy_btn[0] + 33, buy_btn[1] + 12, BUY_T + 0.05, 0.9, 6, 26, 9)
            if prog(t, BUY_T, 0.5) < 1:
                burst(c, 134, 140, prog(t, BUY_T, 0.6), 22, 70, (AMBER_HI, GOLD, AMBER_LO, ROSE_LO), 7)
        tag_layer(c, t)
        return finish(c, t, dur, 0.2, 0.3)
    return fn


# ================================================================ co-op
def white_flash(im, col=CREAM):
    a = im.split()[3]
    o = Image.new("RGBA", im.size, col)
    o.putalpha(a)
    return o


@lru_cache(maxsize=1)
def battlefield():
    """Top-down Tatar Sunda clearing from the real tileset (tiles_sunda: grass + dirt) plus real props."""
    ts = load("tiles_sunda.png")
    t = lambda col, row: ts.crop((col * 16, row * 16, col * 16 + 16, row * 16 + 16))
    img = Image.new("RGBA", (W, H), rgb("33592E"))
    r = random.Random(4)
    cx, cy, rx, ry = 194, 170, 150, 82
    for gy in range(0, H // 16 + 1):
        for gx in range(0, W // 16):
            px_, py_ = gx * 16 + 8, gy * 16 + 8
            e = ((px_ - cx) / rx) ** 2 + ((py_ - cy) / ry) ** 2 + (r.random() - 0.5) * 0.12
            if e < 1.0:
                tile = t(1, 0 if r.random() < 0.8 else 1)
            else:
                tile = t(0, 0 if r.random() < 0.85 else 1)
            img.paste(tile, (gx * 16, gy * 16), tile)
    pr = lambda n: load(f"props/{n}_sunda.png")
    # arena posts + props
    for (x, y) in ((160, 116), (290, 116), (160, 232), (290, 232)):
        paste(img, load("props/arena_post.png"), x - 14, y - 22)
    rr = random.Random(9)
    deco = [("tree_banyan", 4, 78), ("tree_banyan", 60, 262), ("tree_teak", 410, 70), ("tree_banyan", 450, 120),
            ("tree_teak", 440, 252), ("tree_teak", 340, 266), ("tree_banyan", 130, 270), ("tree_teak", 250, 76),
            ("tree_banyan", 200, 74), ("tree_teak", 12, 250), ("tree_banyan", 380, 100)]
    for n, x, y in sorted(deco, key=lambda d: d[2]):
        im = pr(n)
        paste(img, im, x - im.width // 2, y - im.height)
    for n in ("bush", "rock_s", "rock_m", "tuft_0", "tuft_1", "flower_0", "flower_1", "tuft_2"):
        for _ in range(7 if n.startswith("tuft") else 3):
            x, y = rr.randrange(8, 470), rr.randrange(72, 262)
            e = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
            if e > 1.15:
                im = pr(n)
                paste(img, im, x - im.width // 2, y - im.height)
    return img


HEROES = [  # class, name, glyph, x, y(feet), shot offset
    ("warrior", "Rangga", "ᮊ", 104, 158, 0.00),
    ("archer", "Sekar", "ᮌ", 128, 192, 0.30),
    ("mage", "Jaka", "ᮠ", 102, 226, 0.62),
    ("dancer", "Mawar", "ᮕ", 130, 124, 0.88),
]
PERIOD = 1.25
FIRST = 1.45
# enemy slots: (home x, y feet, [(type, spawn t, death t), ...])
ENEMIES = [
    (212, 122, [("bandit", 0.5, 4.1), ("boar", 5.0, 9.9)]),
    (246, 152, [("boar", 0.7, 3.4), ("bandit", 4.4, 9.9)]),
    (214, 184, [("tuyul", 0.9, 5.2), ("tuyul", 5.9, 9.9)]),
    (266, 200, [("bandit", 1.1, 6.1), ("boar", 6.3, 9.9)]),
    (190, 152, [("boar", 1.3, 2.9), ("tuyul", 3.7, 7.0)]),
]
ESPR = {"bandit": ("enemies/bandit.png", 32, 32, 2), "boar": ("enemies/wild_boar.png", 40, 24, 2),
        "tuyul": ("enemies/tuyul.png", 24, 24, 1)}


def enemy_life(slot, t):
    hx, hy, lives = ENEMIES[slot]
    for typ, sp, dt in lives:
        if sp <= t < dt + 0.5:
            return typ, sp, dt, hx, hy
    return None


def shots():
    """Deterministic list of (t_spawn, hero_idx, enemy_slot, t_hit)."""
    out = []
    for hi, (cls, nm, gl, hx, hy, off) in enumerate(HEROES):
        k = 0
        while True:
            ts = FIRST + off + k * PERIOD + 0.2
            if ts > 7.9:
                break
            alive = [s for s in range(len(ENEMIES)) if (lf := enemy_life(s, ts + 0.45)) and ts + 0.45 < lf[2]
                     and ts + 0.45 > lf[1] + 1.0]
            if alive:
                s = alive[(k + hi) % len(alive)]
                lf = enemy_life(s, ts + 0.45)
                tx = lf[3] - 14
                ty = lf[4] - 10
                d = math.hypot(tx - (hx + 14), ty - (hy - 12))
                out.append((ts, hi, s, ts + d / 230.0))
            k += 1
    return out


@scene("fut_coop", 8.0)
def fut_coop(dur=8.0):
    SH = shots()
    PT = 4.3                                              # panel slides in
    members = [("Rangga", "warrior", True, "You"), ("Sekar", "archer", True, ""), ("Jaka", "mage", True, ""),
               ("Mawar", "dancer", True, ""), ("Dimas", "lancer", False, "")]

    def hero_state(hi, t):
        cls, nm, gl, hx, hy, off = HEROES[hi]
        # arrive: walk in from the left edge
        arrive = 0.25 + hi * 0.18
        walk_len = 0.9
        if t < arrive:
            return None
        if t < arrive + walk_len:
            p = (t - arrive) / walk_len
            return ("walk", ri(lerp(-30, hx, ease_out(p))), hy, int(t * 9) % 6)
        # attack?
        k = int((t - (FIRST + off)) // PERIOD) if t >= FIRST + off else -1
        if k >= 0:
            lt = t - (FIRST + off + k * PERIOD)
            if lt < 0.5:
                return ("atk", hx, hy, min(5, int(lt / 0.5 * 6)))
        return ("idle", hx, hy, int(t * 5 + hi) % 4)

    def fn(t):
        c = battlefield().copy()
        d = ImageDraw.Draw(c)
        # ---- ground shadows + enemies + heroes depth sorted by y
        actors = []
        for s in range(len(ENEMIES)):
            lf = enemy_life(s, t)
            if lf:
                actors.append((lf[4], "e", s, lf))
        for hi in range(len(HEROES)):
            hs = hero_state(hi, t)
            if hs:
                actors.append((hs[2], "h", hi, hs))
        actors.sort(key=lambda a: a[0])
        hits = [(sh[3], sh[2]) for sh in SH]
        for _, kind, idx, st in actors:
            if kind == "e":
                typ, sp, dt, hx, hy = st
                path, cw, ch, _ = ESPR[typ]
                sheet = load(path)
                # entrance: walk in from the right
                ent = prog(t, sp, 1.1)
                x = ri(lerp(hx + 130, hx, ease_out(ent)))
                bob = 0
                row, col = 1, int(t * 8) % 4
                if ent >= 1:
                    row, col = 0, int(t * 4 + idx) % 4
                    if int(t * 0.8 + idx * 0.37) % 3 == 0 and (t * 0.8 + idx * 0.37) % 1 < 0.3:
                        row, col = 2, 2 + int(t * 8) % 2
                # hit flash + knockback
                recent = [ht for ht, sl in hits if sl == idx and 0 <= t - ht < 0.12]
                kb = 2 if recent else 0
                dying = t >= dt
                ex, ey = x + kb, hy
                im = sheet.crop((col * cw, row * ch, col * cw + cw, row * ch + ch))
                if recent:
                    im = white_flash(im)
                if dying:
                    row, col = 3, 0
                    im = sheet.crop((0, 3 * ch, cw, 4 * ch))
                    pd = prog(t, dt, 0.5)
                    im = white_flash(im, CYAN_HI) if pd < 0.3 else im
                    a = np.array(im)
                    thr = (BAYER4[np.arange(ch)[:, None] % 4, np.arange(cw)[None, :] % 4] + 0.5) / 16.0
                    a[thr <= pd] = 0
                    im = Image.fromarray(a, "RGBA")
                # enemy sheets face right: flip toward the heroes
                im = im.transpose(Image.FLIP_LEFT_RIGHT)
                shadow_w = cw - 8
                d.ellipse([ex - shadow_w // 2, ey - 3, ex + shadow_w // 2, ey + 2], fill=rgb("1F3B22"))
                paste(c, im, ex - cw // 2, ey - ch + 2)
            else:
                cls, nm, gl, hx, hy, off = HEROES[idx]
                mode, x, y, f = st
                sheet = load(f"hero_{cls}.png")
                row = {"walk": 4, "idle": 1, "atk": 6}[mode]
                im = sheet.crop((f * 32, row * 32, f * 32 + 32, row * 32 + 32))
                d.ellipse([x - 8, y - 3, x + 8, y + 2], fill=rgb("1F3B22"))
                paste(c, im, x - 16, y - 29)
        # ---- spells
        for (ts, hi, s, th) in SH:
            if ts <= t < th + 0.35:
                cls, nm, gl, hx, hy, off = HEROES[hi]
                lf = enemy_life(s, th)
                if not lf:
                    continue
                tx, ty = lf[3] - 14, lf[4] - 10
                sx0, sy0 = hx + 14, hy - 12
                if t < th:
                    p = (t - ts) / (th - ts)
                    x, y = lerp(sx0, tx, p), lerp(sy0, ty, p) - math.sin(p * math.pi) * 6
                    glow = load(f"fx/bolt_glow_{cls}.png")
                    fr = int(t * 18) % 3
                    paste(c, glow.crop((fr * 16, 0, fr * 16 + 16, 16)), int(x) - 8, int(y) - 8)
                    sp = load(f"fx/bolt_spark_{cls}.png")
                    for j in range(1, 4):
                        pp = max(0, p - j * 0.03)
                        xx, yy = lerp(sx0, tx, pp), lerp(sy0, ty, pp) - math.sin(pp * math.pi) * 6
                        paste(c, sp.crop((((fr + j) % 3) * 8, 0, ((fr + j) % 3) * 8 + 8, 8)), int(xx) - 4 - 3 * j, int(yy) - 4)
                else:
                    ph = (t - th) / 0.35
                    ring = load(f"fx/ring_{cls}.png")
                    fr = min(2, int(ph * 3))
                    paste(c, ring.crop((fr * 32, 0, fr * 32 + 32, 32)), tx - 16, ty - 16)
                    burst(c, tx, ty, ph, 8, 18, (CYAN_HI, CYAN, CYAN_HALO, CYAN_DEEP), seed=ts * 10 % 97)
            # muzzle + glyph on cast
            if ts - 0.12 <= t < ts + 0.7:
                cls, nm, gl, hx, hy, off = HEROES[hi]
                lt = t - (ts - 0.12)
                mz = load(f"fx/muzzle_{cls}.png")
                if lt < 0.15:
                    fr = min(2, int(lt / 0.05))
                    paste(c, mz.crop((fr * 24, 0, fr * 24 + 24, 24)), hx + 6, hy - 25)
                gp = prog(t, ts - 0.1, 0.7)
                if gp < 1:
                    gy = hy - 40 - ri(10 * ease_out(gp))
                    aksara(c, (gl, "sunda"), hx + 12, gy + 4, 13, CYAN, glow=GLOW_C, mod=m_dither(1 - max(0, (gp - 0.6) / 0.4), 6))
        # ---- name tags + hp
        for hi in range(len(HEROES)):
            hs = hero_state(hi, t)
            if not hs:
                continue
            cls, nm, gl, hx, hy, off = HEROES[hi]
            x = hs[1]
            w = text_w(nm, CAP) + 8
            tx0 = x - w // 2
            ty0 = hy - 41
            show = prog(t, 0.5 + hi * 0.18, 0.3)
            if show > 0:
                paste(c, panel(w, 13, HAIR, FILL), tx0, ty0)
                text(c, nm, x, ty0 + 2, CAP, GOLD if hi == 0 else CREAM, "c")
        # ---- HUD top-left: wave strip
        header_chip(c, t, "Play together", "Co-op & Paguyuban", 0.15)
        # ---- Paguyuban panel
        po, pv = slide(t, PT, 1e9, 0.5, dist=200, steps=9)
        if pv:
            px0, py0, pw, ph_ = 288 + po, 46, 176, 208
            dpanel(c, px0, py0, pw, ph_, PANEL_BG, HAIR)
            # crest + title
            q = lambda t0: m_dither(prog(t, PT + t0, 0.3), 8)
            diamond(c, px0 + 18, py0 + 20, 13, AMBER_LO, AMBER)
            diamond(c, px0 + 18, py0 + 20, 7, EDGE, None)
            aksara(c, ("ᮊ", "sunda"), px0 + 18, py0 + 20, 8, CYAN)
            text(c, "Paguyuban", px0 + 34, py0 + 6, SUB, CREAM, "l", mod=q(0.15))
            text(c, "Cahaya Aksara", px0 + 34, py0 + 29, CAP, AMBER, "l", track=1, mod=q(0.25))
            text(c, "12 members", px0 + pw - 10, py0 + 29, CAP, DIM, "r", mod=q(0.25))
            rule(c, px0 + 10, px0 + pw - 10, py0 + 42)
            # member rows
            for i, (nm, cls, on, tag) in enumerate(members):
                ry = py0 + 48 + i * 21
                tr = prog(t, PT + 0.45 + i * 0.22, 0.3)
                if tr <= 0:
                    continue
                md = m_dither(tr, 8)
                rowim = canvas()
                paste(rowim, panel(pw - 16, 19, HAIR_LO if i else AMBER_LO, FILL), px0 + 8, ry)
                sh = load(f"hero_{cls}.png")
                head = sh.crop((6, 4, 26, 24))
                f = int(t * 4 + i) % 4
                head = sh.crop((f * 32 + 7, 5, f * 32 + 25, 23))
                paste(rowim, head, px0 + 11, ry)
                text(rowim, nm, px0 + 32, ry + 5, CAP, CREAM if on else DIM, "l")
                text(rowim, tag if tag else cls.capitalize(), px0 + 78, ry + 5, CAP, AMBER if tag else DIM_LO, "l")
                dot = GREEN if on else DIM_LO
                dx_ = px0 + pw - 20
                rect(rowim, dx_, ry + 7, dx_ + 4, ry + 11, EDGE)
                rect(rowim, dx_ + 1, ry + 8, dx_ + 3, ry + 10, dot)
                if on and int(t * 2) % 2:
                    putpx(rowim, (dx_ + 2, ry + 9), rgb("D8FFE0"))
                if tr < 1:
                    arr = np.array(rowim)
                    thr = (BAYER4[np.arange(H)[:, None] % 4, np.arange(W)[None, :] % 4] + 0.5) / 16.0
                    arr[thr > math.floor(tr * 8) / 8] = 0
                    rowim = Image.fromarray(arr, "RGBA")
                c.alpha_composite(rowim)
            # weekly challenge
            cy0 = py0 + 48 + 5 * 21 + 3
            rule(c, px0 + 10, px0 + pw - 10, cy0)
            ch_t = prog(t, PT + 1.2, 0.4)
            if ch_t > 0:
                md = m_dither(ch_t, 8)
                text(c, "WEEKLY CHALLENGE", px0 + 12, cy0 + 6, CAP, AMBER, "l", track=1, mod=md)
                text(c, "Write 1,000 aksara together", px0 + 12, cy0 + 17, CAP, TEXT, "l", mod=md)
                n_cast = sum(1 for s in SH if s[3] <= t)
                count = min(1000, 560 + 9 * n_cast + int(30 * prog(t, PT + 1.2, 3.0)))
                bar(c, px0 + 12, cy0 + 30, pw - 24, 9, count / 1000.0, CYAN, HAIR_LO, EDGE, CYAN_HI)
                for k in (250, 500, 750):
                    putpx(c, (px0 + 12 + ri((pw - 26) * k / 1000), cy0 + 31), HAIR)
                text(c, f"{count:,} / 1,000", px0 + pw - 12, cy0 + 42, CAP, CYAN, "r", mod=md)
                if prog(t, PT + 1.2, 0.4) >= 1:
                    sparkle(c, px0 + 12 + ri((pw - 26) * count / 1000), cy0 + 34, t, period=0.6, size=3)
        tag_layer(c, t)
        return finish(c, t, dur, 0.2, 0.3)
    return fn


# ================================================================ mobile + classroom
KA = [(120, 113), (255, 113), (140, 395), (290, 113), (425, 113), (310, 395)]      # .docs/glyph_strokes.py sunda_ka
GA = [(620, 113), (750, 113), (650, 380), (840, 380), (880, 265), (775, 265)]      # sunda_ga


def fit_path(pts, cx, cy, size):
    xs, ys = [p[0] for p in pts], [p[1] for p in pts]
    sc = size / max(max(xs) - min(xs), max(ys) - min(ys))
    mx, my = (max(xs) + min(xs)) / 2, (max(ys) + min(ys)) / 2
    return [((x - mx) * sc + cx, (y - my) * sc + cy) for x, y in pts]


def finger(c, x, y, press=1.0):
    """A pixel fingertip touching the screen at (x, y), the finger running down to the lower right."""
    d = ImageDraw.Draw(c)
    ex, ey = x + 14, y + 30
    skin, shade, hi = rgb("E8B48C"), rgb("C98A66"), rgb("F4CBA6")
    d.line([(x, y + 3), (ex, ey)], fill=EDGE, width=11)
    d.ellipse([x - 5, y - 3, x + 5, y + 7], fill=EDGE)
    d.line([(x, y + 3), (ex, ey)], fill=shade, width=9)
    d.ellipse([x - 4, y - 2, x + 4, y + 6], fill=shade)
    d.line([(x - 1, y + 3), (ex - 2, ey)], fill=skin, width=6)
    d.ellipse([x - 3, y - 1, x + 3, y + 5], fill=skin)
    d.rectangle([x - 2, y, x + 1, y + 2], fill=hi)          # nail
    putpx(c, (x - 1, y), rgb("FFF0E0"))


def phone_body(c, x, y, w, h):
    d = ImageDraw.Draw(c)
    d.rounded_rectangle([x, y, x + w - 1, y + h - 1], radius=9, fill=EDGE)
    d.rounded_rectangle([x + 1, y + 1, x + w - 2, y + h - 2], radius=8, fill=rgb("4A3F72"))
    d.rounded_rectangle([x + 2, y + 2, x + w - 3, y + h - 3], radius=7, fill=rgb("231C3E"))
    d.rounded_rectangle([x + 4, y + 4, x + w - 5, y + h - 5], radius=5, fill=EDGE)
    # speaker + camera on the left bezel, home bar on the right
    d.rectangle([x + 5, y + h // 2 - 7, x + 6, y + h // 2 + 7], fill=rgb("1E1838"))
    d.point([(x + 5, y + h // 2 - 12)], fill=rgb("3A4A8C"))
    d.rectangle([x + w - 7, y + h // 2 - 8, x + w - 6, y + h // 2 + 8], fill=rgb("2B2347"))
    # side buttons
    d.rectangle([x + 30, y - 1, x + 44, y], fill=rgb("4A3F72"))
    d.rectangle([x + 52, y - 1, x + 58, y], fill=rgb("4A3F72"))


@lru_cache(maxsize=1)
def phone_bg():
    return battlefield().crop((92, 112, 92 + 204, 112 + 108))


@scene("fut_mobile", 8.0)
def fut_mobile(dur=8.0):
    PX, PY, PW, PH = 17, 80, 226, 132
    SX_, SY_, SW_, SH_ = PX + 11, PY + 12, 204, 108
    # touch timeline: (draw start, release, glyph, % match)
    draws = [(1.9, 3.5, KA, 94), (5.0, 6.3, GA, 91)]
    fires = [3.8, 6.55]
    ENT = 4.2                      # classroom card slides in
    students = [("Ayu", 92), ("Bima", 78), ("Citra", 85), ("Dedi", 70), ("Eka", 88)]

    def screen_game(t):
        im = phone_bg().copy()
        # actors drawn in screen-local coordinates
        scr = canvas()
        scr.paste(im, (0, 0))
        mage = load("hero_mage.png")
        # mage
        mx, my = 52, 84
        casting = None
        for f in fires:
            if f - 0.12 <= t < f + 0.4:
                casting = int((t - (f - 0.12)) / 0.52 * 6)
        row, col = (6, min(5, casting)) if casting is not None else (1, int(t * 5) % 4)
        ImageDraw.Draw(scr).ellipse([mx - 8, my - 3, mx + 8, my + 2], fill=rgb("1F3B22"))
        paste(scr, mage.crop((col * 32, row * 32, col * 32 + 32, row * 32 + 32)), mx - 16, my - 29)
        # enemies: one per cast
        for ei, (typ, hx, hy, arrive, death) in enumerate((("bandit", 142, 74, 0.8, fires[0] + 0.35),
                                                             ("boar", 150, 92, 4.4, fires[1] + 0.35))):
            if t < arrive or t > death + 0.5:
                continue
            path, cw, ch, _ = ESPR[typ]
            sh = load(path)
            ent = prog(t, arrive, 1.0)
            x = ri(lerp(hx + 70, hx, ease_out(ent)))
            row_, col_ = (1, int(t * 8) % 4) if ent < 1 else (0, int(t * 4) % 4)
            imm = sh.crop((col_ * cw, row_ * ch, col_ * cw + cw, row_ * ch + ch))
            if 0 <= t - death < 0.5 or t >= death:
                pd = prog(t, death, 0.5)
                imm = sh.crop((0, 3 * ch, cw, 4 * ch))
                if pd < 0.3:
                    imm = white_flash(imm, CYAN_HI)
                a = np.array(imm)
                thr = (BAYER4[np.arange(ch)[:, None] % 4, np.arange(cw)[None, :] % 4] + 0.5) / 16.0
                a[thr <= pd] = 0
                imm = Image.fromarray(a, "RGBA")
            imm = imm.transpose(Image.FLIP_LEFT_RIGHT)
            ImageDraw.Draw(scr).ellipse([x - cw // 2 + 4, hy - 3, x + cw // 2 - 4, hy + 2], fill=rgb("1F3B22"))
            paste(scr, imm, x - cw // 2, hy - ch + 2)
        # spell bolt
        for fi, f in enumerate(fires):
            if f <= t < f + 0.35:
                p = (t - f) / 0.35
                tx = (142 if fi == 0 else 150) - 6
                ty = (74 if fi == 0 else 92) - 10
                x, y = lerp(mx + 14, tx, p), lerp(my - 12, ty, p)
                glow = load("fx/bolt_glow_mage.png")
                fr = int(t * 18) % 3
                paste(scr, glow.crop((fr * 16, 0, fr * 16 + 16, 16)), int(x) - 8, int(y) - 8)
            elif f + 0.35 <= t < f + 0.7:
                p = (t - f - 0.35) / 0.35
                tx = (142 if fi == 0 else 150) - 6
                ty = (74 if fi == 0 else 92) - 10
                ring = load("fx/ring_mage.png")
                paste(scr, ring.crop((min(2, int(p * 3)) * 32, 0, min(2, int(p * 3)) * 32 + 32, 32)), tx - 16, ty - 16)
        return scr

    def fn(t):
        c = night_bg(t, Stars(81, 60, 0.7))
        header_chip(c, t, "Mobile & Classroom", "Touch play and teacher tools", 0.15)
        shift = ri(110 * (1 - step_ease(ease_io(prog(t, ENT - 0.2, 0.7)), 14)))
        PXs, SXs = 17 + shift, 17 + 11 + shift
        # ---------------- phone
        po, pv = slide(t, 0.35, 1e9, 0.5, dist=170, steps=9)
        if pv:
            oy = po
            phone_body(c, PXs, PY + oy, PW, PH)
            if t >= 0.9:
                # game screen (local canvas pasted, then HUD)
                scr = screen_game(t)
                frame = canvas()
                frame.paste(scr, (SXs, SY_ + oy))
                # HUD
                bar(frame, SXs + 6, SY_ + 6, 46, 7, 0.82, rgb("D0503C"), HAIR_LO, EDGE, rgb("FF9070"))
                bar(frame, SXs + 6, SY_ + 15, 36, 5, 0.6, rgb("3FB8C0"), HAIR_LO, EDGE, CYAN_HI)
                # pause + quick slots
                rect(frame, SXs + SW_ - 16, SY_ + 6, SXs + SW_ - 7, SY_ + 15, EDGE)
                rect(frame, SXs + SW_ - 13, SY_ + 8, SXs + SW_ - 12, SY_ + 13, CREAM)
                rect(frame, SXs + SW_ - 10, SY_ + 8, SXs + SW_ - 9, SY_ + 13, CREAM)
                drawing = None
                for (s0, s1, gl, pct) in draws:
                    if s0 - 0.25 <= t < s1 + 0.25:
                        drawing = (s0, s1, gl, pct)
                # dim the world while drawing (dither)
                if drawing:
                    s0, s1, gl, pct = drawing
                    dimp = clamp(min((t - (s0 - 0.25)) / 0.25, ((s1 + 0.25) - t) / 0.25)) * 0.5
                    arr = np.array(frame)
                    lvl = math.floor(dimp / 0.5 * 3 + 1e-9) / 3 * 0.5     # flat colour grade in 3 steps, no dither noise
                    y0r, y1r = SY_ + oy, SY_ + oy + SH_
                    reg = arr[y0r:y1r, SXs:SXs + SW_, :3].astype(float)
                    reg *= (1 - 0.8 * lvl)
                    reg += np.array([8, 6, 22]) * lvl * 0.8
                    arr[y0r:y1r, SXs:SXs + SW_, :3] = np.clip(reg, 0, 255).astype("uint8")
                    frame = Image.fromarray(arr, "RGBA")
                c.alpha_composite(frame)
                # ink + finger
                gcx, gcy = SXs + SW_ // 2 + 6, SY_ + SH_ // 2 + oy - 2
                for (s0, s1, gl, pct) in draws:
                    if t < s0:
                        continue
                    path = smooth_path(fit_path(gl, gcx, gcy, 56), 7)
                    pp = ease_io(prog(t, s0, s1 - s0)) if t < s1 else 1.0
                    fade = prog(t, s1 + 0.9, 0.5)
                    if fade < 1:
                        layer = canvas()
                        ink_stroke(layer, path, pp, 2)
                        if fade > 0:
                            layer = dither_out(layer, fade, 8)
                        c.alpha_composite(layer)
                    if s0 - 0.25 <= t < s1 + 0.15:
                        # finger travels in, follows the path head, lifts
                        pts = sample_path(path, 1.0)
                        i = min(len(pts) - 1, int(len(pts) * pp))
                        fx, fy = pts[i]
                        if t < s0:
                            k = ease_out(prog(t, s0 - 0.25, 0.25))
                            fx, fy = lerp(fx + 60, fx, k), lerp(fy + 50, fy, k)
                        if t > s1:
                            k = prog(t, s1, 0.15)
                            fx, fy = fx + 8 * k, fy + 6 * k
                        # ripple ring
                        rr = 3 + int(((t - s0) * 6) % 3)
                        finger_layer = canvas()
                        ImageDraw.Draw(finger_layer).ellipse([int(fx) - rr, int(fy) - rr, int(fx) + rr, int(fy) + rr],
                                                             outline=CYAN)
                        finger_layer = Image.fromarray(np.where((np.add.outer(np.arange(H), np.arange(W)) % 2 == 0)[..., None],
                                                                np.array(finger_layer), 0).astype("uint8"), "RGBA")
                        c.alpha_composite(finger_layer)
                        # clip finger to the phone region: draw whole finger (it overlaps the bezel realistically)
                        finger(c, int(fx), int(fy))
                    # match pop
                    mp = t - s1
                    if 0.05 <= mp < 1.8:
                        k = ease_out(prog(t, s1 + 0.05, 0.25))
                        yy = int(SY_ + SH_ + oy - 34 - 5 * k)
                        w_ = 88
                        bx = SXs + SW_ // 2 - w_ // 2
                        if mp < 1.5 or int(mp * 12) % 2 == 0:
                            paste(c, panel(w_, 24, CYAN, rgb("0F2A32")), bx, yy)
                            text(c, f"MATCH {pct}%", bx + w_ // 2, yy + 1, SUB, CYAN_HI, "c")
                            sparkle(c, bx + 3, yy - 2, t, period=0.5, size=3)
                            sparkle(c, bx + w_ - 3, yy + 26, t, period=0.5, phase=0.2, size=2)
            # glass glare
            d = ImageDraw.Draw(c)
            for k in range(0, 18, 2):
                d.point([(SXs + 150 + k, SY_ + oy + 2 + k // 2 * 0)], fill=None)
            text(c, "Draw with your finger", PXs + PW // 2, PY + PH + 10 + oy, LABEL, LABEL_C, "c") if t > 1.0 else None
        # ---------------- classroom dashboard
        co, cv = slide(t, ENT, 1e9, 0.5, dist=240, steps=9)
        if cv:
            x0, y0, w0, h0 = 262 + co, 46, 202, 208
            dpanel(c, x0, y0, w0, h0, PANEL_BG, HAIR)
            q = lambda t0: m_dither(prog(t, ENT + t0, 0.3), 8)
            # board icon
            rect(c, x0 + 11, y0 + 10, x0 + 28, y0 + 24, AMBER_LO)
            rect(c, x0 + 12, y0 + 11, x0 + 27, y0 + 23, rgb("1B3A32"))
            hline(c, x0 + 14, x0 + 22, y0 + 15, CREAM)
            hline(c, x0 + 14, x0 + 25, y0 + 19, CREAM)
            text(c, "Bahasa Sunda, 8B", x0 + 34, y0 + 4, SUB, CREAM, "l", mod=q(0.15))
            text(c, "CLASSROOM MODE", x0 + 34, y0 + 28, CAP, AMBER, "l", track=1, mod=q(0.25))
            text(c, "5 students", x0 + w0 - 10, y0 + 28, CAP, DIM, "r", mod=q(0.25))
            rule(c, x0 + 10, x0 + w0 - 10, y0 + 42)
            text(c, "AKSARA ACCURACY", x0 + 12, y0 + 47, CAP, LABEL_C, "l", track=1, mod=q(0.35))
            for i, (nm, v) in enumerate(students):
                ry = y0 + 54 + i * 17
                tr = prog(t, ENT + 0.55 + i * 0.22, 0.25)
                if tr <= 0:
                    continue
                layer = canvas()
                # avatar tile
                paste(layer, panel(16, 16, HAIR_LO, FILL), x0 + 10, ry)
                rect(layer, x0 + 15, ry + 4, x0 + 20, ry + 9, rgb(["C98A66", "E8B48C", "A8704E", "D49A70", "C0845C"][i]))
                rect(layer, x0 + 14, ry + 10, x0 + 21, ry + 13, rgb(["8E4F7A", "3A4A8C", "3FA39B", "C23A2E", "7A5432"][i]))
                text(layer, nm, x0 + 31, ry + 4, CAP, CREAM, "l")
                grow = ease_out(prog(t, ENT + 0.8 + i * 0.22, 1.0))
                val = v * grow
                col = CYAN if val >= 80 else AMBER if val >= 65 else ROSE
                hi = CYAN_HI if val >= 80 else AMBER_HI
                bar(layer, x0 + 58, ry + 4, 100, 8, val / 100.0, col, HAIR_LO, EDGE, hi)
                for tk in (65, 80):
                    putpx(layer, (x0 + 58 + ri(98 * tk / 100) + 1, ry + 11), HAIR)
                text(layer, f"{int(val)}%", x0 + w0 - 10, ry + 4, CAP, col, "r")
                if tr < 1:
                    arr = np.array(layer)
                    thr = (BAYER4[np.arange(H)[:, None] % 4, np.arange(W)[None, :] % 4] + 0.5) / 16.0
                    arr[thr > math.floor(tr * 8) / 8] = 0
                    layer = Image.fromarray(arr, "RGBA")
                c.alpha_composite(layer)
            # legend
            ly = y0 + 54 + 5 * 17 + 2
            lt = prog(t, ENT + 1.9, 0.3)
            if lt > 0:
                lm = m_dither(lt, 8)
                rect(c, x0 + 12, ly + 3, x0 + 15, ly + 6, CYAN); text(c, "80%+ full power", x0 + 19, ly, CAP, DIM, "l", mod=lm)
                rect(c, x0 + 90, ly + 3, x0 + 93, ly + 6, AMBER); text(c, "65-80% weak", x0 + 97, ly, CAP, DIM, "l", mod=lm)
            # summary
            sy = y0 + h0 - 50
            st = prog(t, ENT + 2.2, 0.35)
            if st > 0:
                paste(c, panel(w0 - 20, 46, AMBER_LO, rgb("1C1530")), x0 + 10, sy)
                text(c, "Class average", x0 + 20, sy + 5, CAP, TEXT, "l", mod=m_dither(st, 8))
                cnt = int(15 * step_ease(prog(t, ENT + 2.4, 0.9), 15))
                text(c, f"+{cnt}%", x0 + 20, sy + 12, TITLE, GREEN if cnt == 15 else CREAM, "l", shadow=SHADOW,
                     mod=m_dither(st, 8))
                # target badge
                bw_ = text_w("TARGET", CAP, 1) + 10
                blink = int(t * 2) % 2 == 0 or t < ENT + 3.6
                paste(c, panel(bw_, 13, AMBER if blink else AMBER_LO, FILL), x0 + w0 - 20 - bw_, sy + 8)
                text(c, "TARGET", x0 + w0 - 20 - bw_ + 5, sy + 11, CAP, AMBER, "l", track=1)
                text(c, "Pilot goal, not yet measured", x0 + w0 - 20, sy + 33, CAP, DIM, "r", mod=m_dither(st, 8))
        tag_layer(c, t)
        return finish(c, t, dur, 0.2, 0.3)
    return fn


# ================================================================ Aksara Map of Indonesia
import mapdata as MD   # noqa: E402

MKX = MKY = 9.0
MX0, MY0, MLON0, MLAT0 = 28, 60, 94.8, 6.0


def mxy(lon, lat):
    return MX0 + (lon - MLON0) * MKX, MY0 + (MLAT0 - lat) * MKY


def poly_mask(poly):
    m = Image.new("L", (W, H), 0)
    ImageDraw.Draw(m).polygon([mxy(*p) for p in poly], fill=255)
    return m


def np_mask(m):
    return np.array(m) > 0


def to_mask(a):
    return Image.fromarray((a * 255).astype("uint8"), "L")


def grow(a, r):
    return np.array(to_mask(a).filter(ImageFilter.MaxFilter(2 * r + 1))) > 0


@lru_cache(maxsize=None)
def script_mask(chars, fontfile, size, thresh=96):
    """Crisp aksara mask from a Noto font stored in video/gfx/fonts (same recipe as pxkit.aksara_mask)."""
    f = ImageFont.truetype(os.path.join(FUT_FONTS, fontfile), size * SS)
    probe = Image.new("L", (size * SS * 4, size * SS * 3), 0)
    ImageDraw.Draw(probe).text((size * SS, size * SS // 2), chars, font=f, fill=255, layout_engine=ImageFont.Layout.RAQM)
    bb = probe.getbbox()
    bb = (bb[0] // SS * SS, bb[1] // SS * SS, (bb[2] + SS - 1) // SS * SS, (bb[3] + SS - 1) // SS * SS)
    big = probe.crop(bb)
    small = big.resize((big.width // SS, big.height // SS), Image.BOX)
    return small.point(lambda v: 255 if v >= thresh else 0)


def put_mask(c, m, cx, cy, col):
    fill_mask(c, m, int(cx - m.width // 2), int(cy - m.height // 2), col)


def _vnoise(w, h, seed, cell):
    r = np.random.RandomState(seed)
    gw, gh = w // cell + 3, h // cell + 3
    g = r.rand(gh, gw)
    ys, xs = np.mgrid[0:h, 0:w]
    fx, fy = xs / cell, ys / cell
    ix, iy = fx.astype(int), fy.astype(int)
    tx, ty = fx - ix, fy - iy
    tx, ty = tx * tx * (3 - 2 * tx), ty * ty * (3 - 2 * ty)
    a, b, c_, d = g[iy, ix], g[iy, ix + 1], g[iy + 1, ix], g[iy + 1, ix + 1]
    return a + (b - a) * tx + (c_ - a) * ty + (a - b - c_ + d) * tx * ty


RAMPS = {   # dark, mid, light, rim
    "off": ((40, 35, 82), (53, 46, 100), (68, 59, 122), (118, 106, 178)),
    "sunda": ((24, 88, 84), (44, 130, 114), (108, 212, 188), (200, 255, 240)),
    "jawa": ((122, 74, 40), (180, 122, 62), (240, 176, 120), (255, 232, 190)),
    "bali": ((108, 38, 70), (168, 64, 100), (238, 128, 150), (255, 200, 210)),
    "lontara": ((36, 96, 62), (74, 158, 92), (156, 218, 140), (220, 255, 200)),
    "batak": ((66, 52, 126), (108, 88, 180), (170, 150, 232), (222, 212, 255)),
}
SCOL = {"sunda": CYAN, "jawa": AMBER, "bali": rgb("F08AA0"), "lontara": rgb("9CDC8C"), "batak": rgb("AA96E8")}


@lru_cache(maxsize=1)
def map_layers():
    """All static map data, computed once: land mask, region masks, noise tone, coast rim, shelf rings."""
    land = np.zeros((H, W), bool)
    parts = {}
    for n, p in MD.ALL.items():
        parts[n] = np_mask(poly_mask(p))
        land |= parts[n]
    xs = np.arange(W)[None, :].repeat(H, 0)
    ys = np.arange(H)[:, None].repeat(W, 1)
    lon = MLON0 + (xs - MX0) / MKX
    lat = MLAT0 - (ys - MY0) / MKY
    java = parts["java"]
    reg = {
        "sunda": java & (lon < MD.SPLIT_LON),
        "jawa": (java & (lon >= MD.SPLIT_LON)) | parts["madura"],
        "bali": parts["bali"],
        "lontara": parts["sulawesi"] & (lon < 121.3) & (((lon - 119.9) / 1.5) ** 2 + ((lat + 4.1) / 2.3) ** 2 < 1.0),
        "batak": parts["sumatra"] & (((lon - 98.9) / 2.1) ** 2 + ((lat - 2.7) / 1.9) ** 2 < 1.0),
    }
    n1 = _vnoise(W, H, 5, 9)
    n2 = _vnoise(W, H, 8, 4)
    noise = 0.65 * n1 + 0.35 * n2
    rim = land & ~np.array(to_mask(land).filter(ImageFilter.MinFilter(3))) > 0
    rim = land & ~(np.array(to_mask(land).filter(ImageFilter.MinFilter(3))) > 0)
    sea = ~land
    d3 = grow(land, 3) & sea
    d6 = grow(land, 6) & sea & ~d3
    return dict(land=land, reg=reg, noise=noise, rim=rim, d3=d3, d6=d6, lon=lon, lat=lat, parts=parts)


def lit_layers():
    return map_layers()


# beacons: key -> (lon, lat), activation time, label, glyph spec, sub line
BEACONS = {
    "sunda": dict(pos=(107.4, -6.9), t=0.9, name="Aksara Sunda", sub="AVAILABLE NOW", gl=("ᮊ", "sunda", 0)),
    "jawa": dict(pos=(110.6, -7.55), t=1.8, name="Aksara Jawa", sub="AVAILABLE NOW", gl=("ꦲ", "jawa", 0)),
    "bali": dict(pos=(115.2, -8.45), t=3.1, name="Aksara Bali", sub="COMING 2029", gl=("ᬩ", "NotoSansBalinese-Regular.ttf", 1)),
    "lontara": dict(pos=(119.8, -4.2), t=4.3, name="Lontara", sub="COMING 2030", gl=("ᨒ", "NotoSansBuginese-Regular.ttf", 1)),
    "batak": dict(pos=(98.7, 2.6), t=5.5, name="Aksara Batak", sub="COMING 2031", gl=("ᯅ", "NotoSansBatak-Regular.ttf", 1)),
}
LINKS = [("batak", "sunda", 5.9), ("sunda", "jawa", 2.1), ("jawa", "bali", 3.4), ("bali", "lontara", 4.6)]
CARDS = {"sunda": (16, 214), "jawa": (166, 214), "bali": (310, 214), "lontara": (300, 152), "batak": (134, 18)}
CARD_H = 38


def card_w(k):
    b = BEACONS[k]
    return 28 + 12 + max(text_w(b["name"], SUB), text_w(b["sub"], CAP, 1)) + 10


def card_anchor(k):
    x, y = CARDS[k]
    w = card_w(k)
    return {"sunda": (x + w // 2, y), "jawa": (x + w // 2, y), "bali": (x + w // 2, y),
            "lontara": (x, y + CARD_H // 2), "batak": (x + 14, y + CARD_H)}[k]


def draw_card(c, k, t, lit):
    b = BEACONS[k]
    x, y = CARDS[k]
    w = card_w(k)
    col = SCOL[k]
    layer = canvas()
    paste(layer, panel(w, CARD_H, col if lit >= 1 else HAIR, rgb("120E24")), x, y)
    paste(layer, panel(28, 28, HAIR_LO, rgb("0C0A18")), x + 5, y + 5)
    ch, script, new = b["gl"]
    if new:
        m = script_mask(ch, script, 22 if k != "lontara" else 20)
        put_mask(layer, m, x + 19, y + 19, col)
    else:
        aksara(layer, (ch, script), x + 19, y + 19, 22, col)
    text(layer, b["name"], x + 38, y + 3, SUB, CREAM, "l")
    avail = b["sub"].startswith("AVAIL")
    text(layer, b["sub"], x + 38, y + 27, CAP, GREEN if avail else AMBER, "l", track=1)
    if avail:
        rect(layer, x + w - 10, y + 29, x + w - 7, y + 32, GREEN)
    p = clamp(lit)
    if p < 1:
        a = np.array(layer)
        thr = (BAYER4[np.arange(H)[:, None] % 4, np.arange(W)[None, :] % 4] + 0.5) / 16.0
        a[thr > math.floor(p * 8) / 8] = 0
        layer = Image.fromarray(a, "RGBA")
    c.alpha_composite(layer)


def seg_points(p0, p1, bow=0.0, n=None):
    (x0, y0), (x1, y1) = p0, p1
    L = math.hypot(x1 - x0, y1 - y0)
    n = n or max(2, int(L))
    nx, ny = -(y1 - y0) / L, (x1 - x0) / L
    pts = []
    for i in range(n + 1):
        u = i / n
        off = math.sin(u * math.pi) * bow * L
        pts.append((x0 + (x1 - x0) * u + nx * off, y0 + (y1 - y0) * u + ny * off))
    return pts


@scene("fut_map", 8.0)
def fut_map(dur=8.0):
    L = map_layers()
    land, reg, noise, rim, d3, d6 = L["land"], L["reg"], L["noise"], L["rim"], L["d3"], L["d6"]
    xs = np.arange(W)[None, :].repeat(H, 0)
    ys = np.arange(H)[:, None].repeat(W, 1)
    thr_b = (BAYER4[ys % 4, xs % 4] + 0.5) / 16.0
    # sea
    sea = np.zeros((H, W, 3), "uint8")
    yy = np.arange(H)[:, None] / (H - 1)
    for i, (a, b) in enumerate(zip((10, 12, 38), (18, 22, 62))):
        sea[..., i] = np.clip(np.floor(a + (b - a) * np.clip((yy ** 1.1) * 1 + (thr_b - 0.5) * 0.22, 0, 1)), 0, 255)
    sea[d6 & (thr_b < 0.30)] = (18, 22, 58)
    sea[d3 & (thr_b < 0.65)] = (24, 30, 74)
    sea[d3 & (thr_b >= 0.65) & (((xs + ys) % 2) == 0)] = (20, 26, 66)
    # graticule: faint dotted lines every 5 degrees
    for lo in range(95, 145, 5):
        gx = int(round(MX0 + (lo - MLON0) * MKX))
        if 0 <= gx < W:
            for y in range(0, H, 4):
                if not land[y, gx]:
                    sea[y, gx] = (26, 30, 70)
    for la in range(-10, 8, 5):
        gy = int(round(MY0 + (MLAT0 - la) * MKY))
        if 0 <= gy < H:
            for x in range(0, W, 4):
                if not land[gy, x]:
                    sea[gy, x] = (26, 30, 70)
    rr = random.Random(12)
    waves = [(rr.randrange(W), rr.randrange(70, H - 10), rr.random() * 6.28) for _ in range(46)]
    # static land tone index 0..2 from noise
    tone = np.where(noise < 0.42, 0, np.where(noise < 0.62, 1, 2))
    land_off = np.zeros((H, W, 3), "uint8")
    for k in range(3):
        land_off[tone == k] = RAMPS["off"][k]
    land_off[rim] = RAMPS["off"][3]
    ramp_lit = {}
    for key in reg:
        arr = np.zeros((H, W, 3), "uint8")
        for k in range(3):
            arr[tone == k] = RAMPS[key][k]
        arr[rim] = RAMPS[key][3]
        ramp_lit[key] = arr
    lon, lat = L["lon"], L["lat"]
    halo_mask = {k: grow(reg[k], 3) & ~land for k in reg}
    halo_mask2 = {k: grow(reg[k], 6) & ~land & ~halo_mask[k] for k in reg}

    def fn(t):
        a = sea.copy()
        # wave dashes drift right, twinkle
        for (wx, wy, ph) in waves:
            x = int(wx + t * 3.0) % W
            lvl = int(t * 1.2 + ph) % 4
            if not land[wy, x] and not d3[wy, x]:
                col = (34, 42, 92) if lvl in (0, 1) else (46, 56, 112) if lvl == 2 else (28, 34, 80)
                for dx in (0, 1, 2):
                    xx = (x + dx) % W
                    if not land[wy, xx]:
                        a[wy, xx] = col
        a[land] = land_off[land]
        # lit regions, expanding from their beacon with a dithered edge
        for key, b in BEACONS.items():
            p = prog(t, b["t"], 1.1)
            if p <= 0:
                continue
            bx, by = mxy(*b["pos"])
            m = reg[key]
            dist = np.hypot(xs - bx, ys - by)
            rmax = 120 if key in ("sunda", "jawa") else 60
            lit = m & (dist + (thr_b - 0.5) * 10 < ease_out(p) * rmax)
            # a slow shimmer on lit tone
            sh = ((xs * 3 + ys * 2 + int(t * 8)) % 29 == 0)
            a[lit] = ramp_lit[key][lit]
            a[lit & sh] = RAMPS[key][3]
            # glow ring outside the coast, pulsing
            ph = int(t * 3 + {"sunda": 0, "jawa": 1, "bali": 2, "lontara": 3, "batak": 0}[key]) % 3
            near = halo_mask[key] & (dist < ease_out(p) * rmax + 6)
            gcol = np.array(SCOL[key][:3])
            a[near & (((xs + ys + ph) % 2) == 0)] = (gcol * 0.55).astype("uint8")
            far = halo_mask2[key] & (dist < ease_out(p) * rmax + 8) & (((xs + ys + ph) % 4) == 0)
            a[far & (((xs // 2 + ys) % 2) == 0)] = (gcol * 0.25).astype("uint8")
        c = Image.fromarray(np.dstack([a, np.full((H, W), 255, "uint8")]), "RGBA")
        # island names
        for nm, (lo, la), col in (("SUMATRA", (103.9, -3.6), DIM_LO), ("KALIMANTAN", (113.2, 0.2), DIM_LO),
                                   ("SULAWESI", (123.4, 0.9), None), ("PAPUA", (136.5, -5.0), DIM_LO)):
            if col is None:
                continue
            x, y = mxy(lo, la)
            text(c, nm, int(x), int(y), CAP, rgb("4E4474"), "c", track=1)
        header_chip(c, t, "Aksara Map", "of Indonesia", 0.15)
        # ---- links first (under beacons)
        for (ka, kb, t0) in LINKS:
            p = prog(t, t0, 0.8)
            if p <= 0:
                continue
            pa, pb = mxy(*BEACONS[ka]["pos"]), mxy(*BEACONS[kb]["pos"])
            bow = {"batak": 0.12, "sunda": 0.0, "jawa": 0.08, "bali": -0.1}[ka]
            pts = seg_points(pa, pb, bow)
            n = int(len(pts) * ease_io(p))
            for i, (x, y) in enumerate(pts[:n]):
                xi, yi = int(x), int(y)
                for dx, dy in ((0, 1), (0, -1), (1, 0), (-1, 0)):
                    if (xi + dx + yi + dy + i // 3) % 2 == 0 and 0 <= xi + dx < W and 0 <= yi + dy < H:
                        putpx(c, (xi + dx, yi + dy), rgb("3A5A78"))
            for i, (x, y) in enumerate(pts[:n]):
                putpx(c, (int(x), int(y)), CREAM if (i // 2) % 2 == 0 else AMBER_HI)
            # travelling pulse
            if p >= 1 and n > 4:
                for ph in (0.0, 0.5):
                    k = int(((t * 0.6 + ph) % 1.0) * (len(pts) - 1))
                    x, y = pts[k]
                    sparkle(c, int(x), int(y), t, AMBER_HI, AMBER, size=2, period=0.8, phase=ph)
        # ---- cards + leaders + beacons
        for key, b in BEACONS.items():
            bx, by = mxy(*b["pos"])
            bx, by = int(bx), int(by)
            lt = prog(t, b["t"] + 0.25, 0.4)
            col = SCOL[key]
            # unlit future marker
            if t < b["t"] and t > 2.4 and key in ("bali", "lontara", "batak"):
                diamond(c, bx, by, 5, DIM_LO, None)
            if t >= b["t"]:
                p = prog(t, b["t"], 0.5)
                # leader (dotted)
                ax, ay = card_anchor(key)
                if lt > 0:
                    for i, (x, y) in enumerate(seg_points((bx, by), (ax, ay), 0, None)):
                        if i % 3 == 0 and i / max(1, math.hypot(ax - bx, ay - by)) <= lt:
                            putpx(c, (int(x), int(y)), col)
                pulse = (t * 1.3 + list(BEACONS).index(key) * 0.2) % 1.0
                rad = 3 + int(pulse * 9)
                if pulse < 0.9:
                    d_ = ImageDraw.Draw(c)
                    ring = canvas()
                    ImageDraw.Draw(ring).ellipse([bx - rad, by - rad, bx + rad, by + rad], outline=col)
                    ra = np.array(ring)
                    ra[((xs + ys) % 2 == 0) == False] = 0
                    c.alpha_composite(Image.fromarray(ra, "RGBA"))
                big = 9 if p >= 1 else 3 + int(6 * ease_out(p))
                diamond(c, bx, by, big if big % 2 else big + 1, col, CREAM)
                if p < 1:
                    burst(c, bx, by, p, 10, 22, (CREAM, col, SCOL[key], DIM_LO), seed=ord(key[0]))
            if lt > 0:
                draw_card(c, key, t, lt)
        # ---- tagline
        t1 = 5.9
        if t >= t1:
            tl = "2 scripts today."
            t2s = "5 by 2031."
            x = 464
            text(c, tl, x, 46, TITLE, CREAM, "r", shadow=SHADOW, chars=typed(t, t1, 20))
            if t >= t1 + 0.8:
                text(c, t2s, x, 78, TITLE, CYAN, "r", shadow=SHADOW, glow=GLOW_C, glow_r=2, glow_phase=int(t * 6) % 2,
                     chars=typed(t, t1 + 0.8, 16))
        tag_layer(c, t)
        return finish(c, t, dur, 0.2, 0.3)
    return fn
