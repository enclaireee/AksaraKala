#!/usr/bin/env python3
"""Dialogue speaker portraits (ui.md 3.1): 32x32 wayang-leaning busts for assets/art/portraits/p_<name>.png.
Drawn with the tiny canvas of gen_cutscene_art; sits inside frame_portrait.png (40x40) at offset (4, 4).
Run: python3 tools/gen_speaker_portraits.py   Output: portraits + tools/speaker_portraits_preview.png
Light comes from the top-left like the rest of the UI. ui/portraits.gd maps speaker ids to these names.
"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gen_cutscene_art import C, Image, T
import pixlib as px
from pixlib import hexc, shade

INKC = hexc("1A1210")


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3)) + (255,)


def backdrop(tint):
    c = C(32, 32)
    base = hexc("17110E")
    for y in range(32):
        for x in range(32):
            d = ((x - 8) ** 2 + (y - 6) ** 2) ** 0.5 / 34.0
            t = max(0.0, 1.0 - d) ** 1.6
            col = lerp(base, tint, t * 0.55)
            if (x + y) % 2 == 0 and 0.15 < t < 0.5:
                col = lerp(base, tint, t * 0.55 + 0.06)
            c.set(x, y, col)
    return c


def bust(skin="d9985e", hair="2a1d26", style="short", head=None, cloth="3e5c7a", trim="c9a24a", mood="calm",
         beard=None, tint="5a3a1e", extra=(), hairstyle_back=False, nose=1, eye="1a1210"):
    sk = hexc(skin)
    sk_hi, sk_lo = shade(sk, 1.18), shade(sk, 0.72)
    hr = hexc(hair)
    hr_hi = shade(hr, 1.4)
    fg = C(32, 32)
    # back hair (long styles) behind the shoulders
    if style in ("long", "long_flower"):
        fg.poly([(7, 8), (25, 8), (27, 28), (5, 28)], hr)
    # shoulders / garment
    cl = hexc(cloth)
    fg.poly([(0, 32), (3, 26), (11, 23), (21, 23), (29, 26), (32, 32)], cl)
    fg.rect(0, 28, 6, 31, shade(cl, 0.8)); fg.rect(26, 28, 31, 31, shade(cl, 0.8))
    fg.line(11, 23, 15, 28, hexc(trim)); fg.line(21, 23, 17, 28, hexc(trim))
    fg.line(10, 24, 14, 29, shade(hexc(trim), 0.7)); fg.line(22, 24, 18, 29, shade(hexc(trim), 0.7))
    if "poleng" in extra:
        for y in range(23, 32):
            for x in range(2, 30):
                if (x // 3 + y // 3) % 2 == 0 and fg.get(x, y)[3]:
                    fg.set(x, y, hexc("EDE3CC"))
    # neck
    fg.rect(14, 19, 18, 24, sk_lo)
    # head
    hw, hh = (7.2, 8.4) if head != "round" else (8.2, 8.0)
    fg.ell(16, 13.5, hw, hh, sk)
    for y in range(6, 22):
        for x in range(21, 25):
            if fg.get(x, y)[3] and fg.get(x, y) == sk:
                fg.set(x, y, sk_lo)
    for y in range(8, 14):
        fg.set(10, y, sk_hi)
    fg.ell(8.5, 14, 1.4, 2, sk); fg.ell(23.5, 14, 1.4, 2, sk_lo)   # ears
    # hair cap
    if style in ("short", "bun", "long", "long_flower", "white", "white_bun"):
        fg.poly([(8, 12), (9, 6), (16, 3), (23, 6), (24, 12), (22, 8), (16, 6), (10, 8)], hr)
        fg.set(11, 5, hr_hi); fg.set(12, 4, hr_hi)
        if style in ("bun", "white_bun"):
            fg.ell(16, 3, 3.4, 2.8, hr); fg.set(15, 2, hr_hi)
    if style == "child_tuft":
        fg.rect(15, 3, 17, 6, hr)
    # headgear
    if "iket" in extra:
        fg.poly([(8, 9), (24, 9), (24, 7), (16, 5), (8, 7)], hexc("8a3030"))
        fg.rect(8, 8, 24, 8, hexc("c9a24a"))
        fg.rect(22, 9, 25, 11, hexc("8a3030"))
    if "blangkon" in extra:
        fg.poly([(8, 10), (9, 5), (16, 2), (23, 5), (24, 10), (16, 8)], hexc("3a2a50"))
        fg.rect(8, 9, 24, 9, hexc("c9a24a")); fg.ell(16, 4, 2, 1.4, hexc("52407a"))
        fg.rect(22, 6, 26, 11, hexc("3a2a50"))
    if "caping" in extra:
        fg.poly([(1, 11), (16, -1), (31, 11), (24, 11), (16, 7), (8, 11)], hexc("c9a24a"))
        fg.line(4, 10, 16, 1, hexc("8a6a22")); fg.line(28, 10, 16, 1, shade(hexc("c9a24a"), 1.25))
        fg.line(3, 11, 29, 11, hexc("6a4a18")); fg.set(16, 0, hexc("6a4a18"))
    if "crown" in extra:
        fg.poly([(9, 8), (9, 2), (12, 5), (16, -1), (20, 5), (23, 2), (23, 8)], hexc("e2b64a"))
        fg.rect(9, 7, 23, 8, hexc("a27820")); fg.set(16, 2, hexc("c0392b")); fg.set(12, 5, hexc("ffe08a"))
    if "hood" in extra:
        fg.poly([(5, 30), (6, 12), (11, 2), (21, 2), (26, 12), (27, 30), (21, 22), (11, 22)], hexc("141018"))
        fg.ell(16, 13.5, 5.6, 7.4, hexc("0a0810"))
    if "kuncung" in extra:
        fg.poly([(15, 6), (16, -1), (17, 6)], hexc("f4f1de")); fg.ell(16, 5, 2, 1.5, hexc("f4f1de"))
    if "flower" in extra:
        fg.ell(22, 7, 2, 2, hexc("f4f1de")); fg.set(22, 7, hexc("ffd060")); fg.set(24, 8, hexc("c0392b"))
    if "pearls" in extra:
        for x in (8, 12, 16, 20, 24):
            fg.set(x, 21 + (0 if x in (12, 20) else 1), hexc("e8f4ff"))
    # face
    ey = 13
    if "mask" in extra:
        fg.ell(16, 13.5, 5.6, 7.4, hexc("ece6d6"))
        fg.rect(11, 12, 14, 12, INKC); fg.rect(18, 12, 21, 12, INKC)
        fg.set(16, 17, hexc("b8b09a")); fg.rect(10, 19, 12, 19, hexc("b8b09a"))
    elif "stone" in extra:
        pass
    else:
        e = hexc(eye)
        fg.rect(11, ey, 14, ey, e); fg.rect(18, ey, 21, ey, e)
        fg.set(11, ey + 1, shade(sk, 0.6)); fg.set(21, ey + 1, shade(sk, 0.6))
        fg.set(12, ey - 1, hr); fg.set(13, ey - 1, hr); fg.set(19, ey - 1, hr); fg.set(20, ey - 1, hr)
        if mood == "stern":
            fg.line(11, ey - 2, 14, ey - 1, hr); fg.line(21, ey - 2, 18, ey - 1, hr)
        for k in range(nose):
            fg.set(16, 15 + k, sk_lo)
        fg.set(15, 17, sk_lo)
        mc = hexc("8a3a30")
        if mood == "smile":
            fg.rect(13, 19, 19, 19, mc); fg.set(12, 18, mc); fg.set(20, 18, mc)
        elif mood == "sad":
            fg.rect(14, 19, 18, 19, mc); fg.set(13, 20, mc); fg.set(19, 20, mc)
        elif mood == "grin":
            fg.rect(12, 19, 20, 20, hexc("f4f1de")); fg.rect(12, 19, 20, 19, mc); fg.set(16, 20, mc)
        elif mood == "fang":
            fg.rect(13, 19, 19, 19, mc); fg.set(13, 20, hexc("f4f1de")); fg.set(19, 20, hexc("f4f1de"))
        else:
            fg.rect(14, 19, 18, 19, mc)
    if beard == "white":
        fg.poly([(11, 19), (21, 19), (19, 25), (16, 27), (13, 25)], hexc("e8e4d6"))
        fg.rect(13, 18, 19, 18, hexc("e8e4d6"))
    elif beard == "goatee":
        fg.poly([(14, 20), (18, 20), (16, 24)], hr)
    elif beard == "stache":
        fg.rect(12, 17, 20, 17, hr)
    if "wrinkles" in extra:
        for p in ((10, 16), (22, 16), (11, 17), (21, 17), (12, 10), (20, 10)):
            fg.set(*p, sk_lo)
    if "blush" in extra:
        fg.set(11, 17, lerp(sk, hexc("d94b38"), 0.5)); fg.set(21, 17, lerp(sk, hexc("d94b38"), 0.5))
    img = px.outline(fg.done(), 0.35, keep_pad=False)
    out = backdrop(hexc(tint))
    out.im.alpha_composite(img)
    return out.done()


SKIN_M, SKIN_F, SKIN_O = "d9985e", "e3a66e", "b07a48"

P = {
    "hero": dict(style="short", extra=("iket",), cloth="3e6c4e", mood="calm"),
    "semar": dict(skin=SKIN_O, style="short", head="round", extra=("kuncung", "poleng", "wrinkles"), cloth="3a3a3a", mood="smile", hair="e8e4d6", tint="6a5a2a"),
    "cepot": dict(skin="d94b38", style="short", head="round", extra=("blush",), cloth="a6473f", mood="grin", hair="2a1d26", nose=3, tint="6a2a1a"),
    "laras": dict(skin=SKIN_F, style="long_flower", extra=("flower", "blush"), cloth="2a9d8f", trim="f2b84b", mood="calm", tint="2a5a5a"),
    "hunter": dict(style="short", extra=("hood", "mask"), cloth="231a2c", mood="calm", tint="2a1a3a"),
    "faceless": dict(style="short", extra=("hood", "mask"), cloth="3a3450", trim="8a8aa0", tint="30303a"),
    "kala": dict(skin="4a8a52", hair="a03028", style="short", head="round", extra=("crown", "wrinkles"), cloth="6a1a1a", mood="fang", beard="goatee", tint="7a2a1a"),
    "elder_m": dict(skin=SKIN_M, hair="e8e4d6", style="short", extra=("blangkon", "wrinkles"), beard="white", cloth="5a3e28", mood="calm"),
    "elder_f": dict(skin=SKIN_F, hair="e8e4d6", style="white_bun", extra=("wrinkles",), cloth="7a3e5a", mood="smile"),
    "woman": dict(skin=SKIN_F, style="bun", extra=("blush",), cloth="b84a62", trim="f2b84b", mood="calm"),
    "woman_b": dict(skin=SKIN_F, style="long", cloth="3e7a5a", trim="f2d488", mood="smile", hair="1a1418"),
    "man": dict(skin=SKIN_M, style="short", extra=("iket",), cloth="3e5c7a", mood="calm"),
    "farmer": dict(skin=SKIN_O, style="short", extra=("caping",), cloth="6a5a3a", mood="calm", beard="stache"),
    "child": dict(skin=SKIN_F, style="child_tuft", extra=("blush",), cloth="a6473f", mood="smile", head="round"),
    "smith": dict(skin=SKIN_O, style="short", cloth="4a3a30", trim="b0602a", mood="stern", beard="stache", extra=("iket",)),
    "guard": dict(skin=SKIN_M, style="short", extra=("blangkon",), cloth="7a3030", trim="e2b64a", mood="stern", beard="stache"),
    "royal_m": dict(skin=SKIN_M, style="short", extra=("crown",), cloth="2a3a6a", trim="e2b64a", mood="stern", beard="goatee"),
    "queen": dict(skin=SKIN_F, style="bun", extra=("crown", "pearls"), cloth="7a2a5a", trim="e2b64a", mood="calm", tint="6a3a5a"),
    "sea_queen": dict(skin="9fd8c8", hair="1a4a5a", style="long", extra=("crown", "pearls"), cloth="1d6b62", trim="bff3ff", mood="calm", tint="1a5a6a"),
    "dalang": dict(skin=SKIN_M, style="short", extra=("blangkon", "wrinkles"), cloth="2a2a3a", trim="c9a24a", mood="smile", beard="goatee"),
    "lutung": dict(skin="3a2a26", hair="141012", style="short", head="round", cloth="2a1a1a", mood="grin", nose=2, tint="3a2a1a"),
    "stone": dict(skin="8c8881", hair="5e5a54", style="bald", extra=("stone",), cloth="5e5a54", trim="b5b0a6", mood="calm", tint="3a3a3a"),
}


def main():
    names = list(P)
    imgs = []
    for n in names:
        im = bust(**P[n])
        px.save(im, f"portraits/p_{n}.png")
        imgs.append((n, im))
    cols, sc = 8, 3
    rows = (len(imgs) + cols - 1) // cols
    sheet = Image.new("RGBA", (cols * 34 * sc, rows * 34 * sc), (30, 24, 22, 255))
    for i, (_, im) in enumerate(imgs):
        sheet.alpha_composite(im.resize((32 * sc, 32 * sc), 0), ((i % cols) * 34 * sc + sc, (i // cols) * 34 * sc + sc))
    sheet.save(os.path.join(os.path.dirname(os.path.abspath(__file__)), "speaker_portraits_preview.png"))
    print("ok", len(names))


if __name__ == "__main__":
    main()
