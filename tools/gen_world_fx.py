#!/usr/bin/env python3
"""World FX art (art pass v8, assets.md 1 "FX standard"): exits, arena gates, rehearsal objects, spawn marks, shadows,
stakes, poles, glows, particle textures and the Kala eye strip. Regional palettes (not class-baked).
Output: assets/art/world_fx/*.png and tools/world_fx_preview.png.   Run: python3 tools/gen_world_fx.py
"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from PIL import Image
from pixlib import *  # noqa: F401,F403  (hexc, dot, lit, blob, band, plum_outline, strip, save, preview, PLUM)
import pixlib as px

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = "world_fx/"
SHEETS = []


def R(*h):
    return [hexc(x) for x in h]


def new(w, h):
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def rect(img, x0, y0, x1, y1, c):
    """Inclusive pixel rectangle."""
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            dot(img, x, y, c)


def box(img, x0, y0, x1, y1, t):
    """Lit slab: top-left light, bottom-right deep. t = 4 tones hi..deep."""
    rect(img, x0, y0, x1, y1, t[1])
    rect(img, x0, y0, x1, y0, t[0])
    rect(img, x0, y0, x0, y1, t[0])
    rect(img, x1, y0 + 1, x1, y1, t[2])
    rect(img, x0 + 1, y1, x1, y1, t[3] if y1 - y0 > 2 else t[2])


def ell(img, cx, cy, rx, ry, t, wob=0.0, seed=0):
    rnd = __import__("random").Random(seed)
    k = [rnd.uniform(-wob, wob) for _ in range(4)]
    for y in range(int(cy - ry - 2), int(cy + ry + 3)):
        for x in range(int(cx - rx - 2), int(cx + rx + 3)):
            dx, dy = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
            ang = math.atan2(dy, dx)
            rr = 1 + sum(k[j] * math.cos((j + 2) * ang) for j in range(4))
            if dx * dx + dy * dy <= rr * rr:
                dot(img, x, y, lit(dx, dy, t))


def outl(img):
    big = new(img.width, img.height)
    big.alpha_composite(img)
    return plum_outline(big)


def sheet(frames, rel, name=None):
    s = strip(frames)
    save(s, OUT + rel)
    SHEETS.append((rel, s))
    return s


# ------------------------------------------------------------------ regional palettes
# stone, post wood, mote accent (each hi..deep)
REG = {
    "purwa":   dict(s=R("E4D8BC", "BEB092", "8C8068", "5E5546"), w=R("D6A86E", "A67A44", "74502E", "483220"), m=R("FFE8A0", "E2B64A", "A87A22", "6A4A14"), foot=True),
    "sunda":   dict(s=R("C4D0B0", "92A484", "627860", "3E4E42"), w=R("D0D878", "A0B04C", "6C8032", "465628"), m=R("B8F0A0", "70C050", "3E8442", "26542E"), foot=False),
    "galuh":   dict(s=R("E0BCA4", "B88C74", "845A4A", "58382E"), w=R("E27050", "B8443A", "7E2A2C", "4E1A22"), m=R("FFE890", "F2B84B", "B07C26", "6A4A16"), foot=False),
    "mataram": dict(s=R("EAD8B4", "C8AC84", "967E5C", "625240"), w=R("B88E64", "8E6844", "644830", "3E2C20"), m=R("F4B070", "D07C42", "924C2C", "5A2E20"), foot=True),
    "timur":   dict(s=R("F2CE92", "D8A058", "A66A36", "6C4226"), w=R("C88050", "9C5A34", "6E3C24", "44241A"), m=R("FFCC68", "F29034", "C0561E", "7C3216"), foot=False),
    "kidul":   dict(s=R("C4EAE4", "84C4C0", "4E909A", "2E6070"), w=R("D4C4A0", "A89870", "74684C", "4A4232"), m=R("F4FFFA", "B8F0E8", "5CC8C8", "2C8C9C"), foot=True),
    "kala":    dict(s=R("CABEDC", "9A8EB4", "6A5F88", "423A5E"), w=R("84749A", "5A4E74", "3C3254", "261E38"), m=R("E4B0FF", "B476E4", "7C44AC", "4C2672"), foot=True),
}


def stones(p):
    img = new(16, 16)
    for (cx, cy, rx, ry, sd) in [(4.5, 4.5, 3.6, 2.8, 1), (11, 8, 4.2, 3.2, 2), (5, 12, 3.8, 2.6, 3)]:
        ell(img, cx, cy, rx, ry, p["s"], 0.12, sd)
    return outl(img)


def post(p):
    img = new(16, 16)
    s, w = p["s"], p["w"]
    box(img, 3, 12, 12, 14, s)          # stone footing
    box(img, 5, 3, 10, 12, w)           # pillar
    rect(img, 7, 5, 8, 11, w[2])        # carved groove
    box(img, 4, 2, 11, 3, p["m"])       # cap beam in the accent
    rect(img, 7, 1, 8, 1, p["m"][0])    # finial
    return outl(img)


def mote(p, i):
    """4 fade stages of a footprint or a leaf, chunky, no thin lines."""
    img = new(16, 16)
    t = p["m"]
    c = t[min(i, 3)]
    hi = t[max(i - 1, 0)]
    if p["foot"]:   # a bare footprint: heel + ball + two toes
        rect(img, 6, 10, 8, 12, c)      # heel
        rect(img, 5, 6, 8, 8, c)        # ball
        rect(img, 5, 6, 6, 7, hi)
        rect(img, 5, 3, 6, 4, c)        # toes
        rect(img, 8, 3, 9, 4, c)
        rect(img, 10, 5, 11, 6, c)
    else:           # a drifting leaf, a fat lozenge with a lit side
        rect(img, 5, 7, 10, 9, c)
        rect(img, 7, 6, 9, 10, c)
        rect(img, 4, 8, 5, 9, hi)
        rect(img, 6, 7, 8, 7, hi)
        rect(img, 11, 9, 12, 10, t[3])
    return img


def exits():
    for r, p in REG.items():
        sheet([stones(p), post(p)] + [mote(p, i) for i in range(4)], "exit_%s.png" % r)


def seal():
    """Ink-seal barrier tile, 4 pulse frames (16x16, tiled across the block)."""
    ink = R("5A4A72", "3A2E52", "241C38", "160F24")
    glow = R("FFF4C8", "F2B84B", "C8802E", "7C4A22")
    fr = []
    for i in range(4):
        f = new(16, 16)
        box(f, 0, 3, 15, 12, ink)
        g = glow[[1, 0, 1, 2][i]]
        rect(f, 6, 5, 9, 10, g)            # a hollow seal glyph: ring with a centre pip
        rect(f, 7, 6, 8, 9, ink[3])
        rect(f, 7, 7, 8, 8, glow[[0, 1, 0, 2][i]])
        rect(f, 2, 7, 3, 8, g)             # a dash each side
        rect(f, 12, 7, 13, 8, g)
        fr.append(outl(f))
    sheet(fr, "exit_seal.png")


def gate_fence():
    """Pagar gaib: ghostly lit slats woven with two gold ties, 4 frames of 16x32 tiles, bottom at y 31."""
    A = R("EEFFFA", "A8E4E0", "62AAC0", "386488")
    B = R("FFF0B0", "F0C050", "B07C28", "6A4818")
    fr = []
    for i in range(4):
        f = new(16, 32)
        for k, x in enumerate((1, 6, 11)):
            top = 5 + ((k + i) % 3) * 2
            box(f, x, top, x + 3, 30, A)
            rect(f, x + 1, top - 1, x + 2, top - 1, A[0])   # pointed tip
            glint = 8 + ((i * 5 + k * 7) % 18)
            rect(f, x + 1, glint, x + 1, glint + 2, A[0])
        for y in (14 + (i % 2), 24):          # woven ties
            rect(f, 0, y, 15, y + 1, B[1])
            rect(f, 0, y, 15, y, B[0])
            rect(f, 0, y + 1, 15, y + 1, B[2])
        for k in range(2):                    # ghost wisps drifting up, step down the ramp
            wy = (28 - ((i * 7 + k * 13) % 26))
            rect(f, 3 + k * 8, wy, 5 + k * 8, wy + 1, A[min(3, 1 + (30 - wy) // 9)])
        fr.append(outl(f) if i in (0, 2) else f)
    sheet(fr, "pagar_gaib.png")


# ------------------------------------------------------------------ rehearsal objects (24x32, feet at row 30)
def rehearse():
    WOOD = R("D6A86E", "A67A44", "74502E", "483220")
    CLOTH = R("F8F6EC", "DAD6C4", "A8A494", "78746A")
    GOLDC = R("FFF0B0", "F2B84B", "B07C26", "6A4A16")
    VIO = R("E0D0FF", "A890E0", "7860B0", "4A3880")
    MIST = R("F8FCFF", "D0DCE8", "A0B0C4", "70809C")
    STN = R("B8A8D0", "8C7CAC", "64568A", "403460")
    GLASS = R("EAFAFC", "9AD0DC", "6A9CB4", "3E6682")
    AMB = R("FFE08A", "F2B84B", "C8802E", "7C4A22")

    def frames(draw):
        out = []
        for i in range(3):
            f = new(24, 32)
            draw(f, i)
            out.append(f)
        return out

    def d_post(f, i):
        box(f, 8, 27, 15, 30, STN)
        box(f, 10, 6, 13, 28, WOOD)
        t = GOLDC if i == 2 else CLOTH
        w = 8 if i != 1 else 7
        box(f, 14, 8, 14 + w, 15, t)
        if i == 1:
            rect(f, 14 + w, 12, 14 + w, 15, new(1, 1).getpixel((0, 0)))
            rect(f, 14 + w - 1, 8, 14 + w - 1, 9, t[0])
        rect(f, 10, 5, 13, 5, WOOD[0])
        _ = outl(f)
        f.paste(_, (0, 0))

    def d_mirror(f, i):
        rect(f, 6, 28, 8, 30, WOOD[2])
        rect(f, 15, 28, 17, 30, WOOD[2])
        box(f, 5, 4, 18, 28, WOOD)
        box(f, 8, 7, 15, 25, GLASS)
        if i == 2:   # the false reflection broke: chunky cracks
            for (x, y) in [(9, 8), (10, 10), (11, 12), (12, 14), (13, 17), (12, 19), (11, 21)]:
                rect(f, x, y, x + 1, y + 1, PLUM)
            rect(f, 13, 13, 14, 14, PLUM)
        else:
            ell(f, 11.5, 16.5 + (i == 1), 2.6, 4.2, AMB)
        f.paste(outl(f), (0, 0))

    def mistfig(tones, done_alpha=140):
        def d(f, i):
            ox = (0, 1, 0)[i]
            blobs = [(12, 24, 8, 5), (12 + ox, 18, 6, 5), (12 - ox, 13, 5, 4), (12 + ox, 9, 3, 3)]
            if i == 2:
                blobs = blobs[:2]
            for (cx, cy, rx, ry) in blobs:
                ell(f, cx, cy, rx, ry, tones, 0.1, cx + cy)
            if i < 2:
                f.paste(outl(f), (0, 0))
            else:
                px_ = f.load()
                for y in range(f.height):
                    for x in range(f.width):
                        if px_[x, y][3]:
                            px_[x, y] = px_[x, y][:3] + (done_alpha,)
        return d

    def d_lock(f, i):
        box(f, 4, 6, 19, 29, STN)
        rect(f, 4, 6, 19, 7, STN[0])
        g = GOLDC if i == 2 else R("A898C0", "8878A4", "6A5C88", "4A3E68")
        band(f, 12, 17, 6, 3, tones=g)
        rect(f, 11, 16, 12, 17, g[0])
        if i == 1:
            rect(f, 15, 11, 16, 12, STN[0])
        f.paste(outl(f), (0, 0))

    def d_lesung(f, i):
        top = (4, 5, 10)[i]
        box(f, 11, top, 13, 22, WOOD)   # pestle
        rect(f, 10, top, 14, top + 1, WOOD[0])
        box(f, 3, 20, 20, 30, WOOD)     # mortar
        ell(f, 11.5, 20.5, 8.5, 2.6, R("8A6A44", "5C432B", "483220", "30221A"))
        rect(f, 11, top + 11 if i == 2 else 18, 13, 21, WOOD[1])
        f.paste(outl(f), (0, 0))

    kinds = {"post": d_post, "mirror": d_mirror, "shade": mistfig(VIO), "mist": mistfig(MIST), "lock": d_lock, "lesung": d_lesung}
    for k, d in kinds.items():
        sheet(frames(d), "rehearse_%s.png" % k)


# ------------------------------------------------------------------ small things
def spawn_mark():
    """Cracked ground with a red ink seal, 16x10 (the encounter's wave warning)."""
    f = new(16, 10)
    ell(f, 8, 5, 7.2, 4.0, R("5A2A2A", "3E1C22", "2A1220", "1C0C18"))
    GL = R("FFE08A", "FF7A4A", "D8402E", "962424")
    for (x, y, w, h) in [(2, 4, 3, 2), (4, 3, 2, 2), (6, 2, 2, 3), (8, 4, 3, 2), (10, 5, 3, 2), (7, 6, 2, 2)]:
        rect(f, x, y, x + w - 1, y + h - 1, GL[2])
    rect(f, 7, 4, 8, 5, GL[0])
    rect(f, 6, 3, 6, 3, GL[1])
    save(outl(f), OUT + "spawn_mark.png")
    SHEETS.append(("spawn_mark.png", outl(f)))


def shadows():
    c = (23, 18, 41)
    for name, (w, h) in {"shadow_xs": (6, 2), "shadow_s": (10, 4), "shadow_m": (14, 5), "shadow_l": (20, 6)}.items():
        f = new(w, h)
        for y in range(h):
            for x in range(w):
                d = math.hypot((x + 0.5 - w / 2) / (w / 2), (y + 0.5 - h / 2) / (h / 2))
                if d <= 1.0:
                    dot(f, x, y, c + ((110 if d <= 0.62 else 62),))
        save(f, OUT + name + ".png")
        SHEETS.append((name, f))


def props():
    W = R("C09460", "8E6A3E", "624526", "3E2A1A")
    f = new(6, 12)   # tether stake: a hammered post with a rope eye
    box(f, 1, 1, 4, 10, W)
    rect(f, 1, 1, 2, 1, W[0])
    rect(f, 2, 4, 3, 5, W[3])
    save(outl(f), OUT + "stake.png")
    SHEETS.append(("stake", outl(f)))
    g = new(4, 18)   # laundry pole
    box(g, 0, 1, 3, 17, W)
    rect(g, 0, 0, 3, 0, W[0])
    save(g, OUT + "pole.png")
    SHEETS.append(("pole", g))
    # warm glows, stepped alpha rings, no gradients
    def glow(w, rs, alphas, col):
        im = new(w, w)
        for y in range(w):
            for x in range(w):
                d = math.hypot(x + 0.5 - w / 2, y + 0.5 - w / 2)
                for r, a in zip(rs, alphas):
                    if d <= r:
                        dot(im, x, y, col + (a,))
                        break
        return im
    gf = [glow(32, (15, 10), (22, 40), (255, 140, 40)), glow(32, (15, 11.5), (22, 40), (255, 140, 40))]
    sheet(gf, "glow_fire.png")
    sheet([glow(24, (12, 8), (16, 28), (255, 150, 50))], "glow_pot.png")


def particles():
    d = new(3, 3)
    for o in [(1, 0), (0, 1), (2, 1), (1, 2)]:
        dot(d, o[0], o[1], (255, 255, 255, 110))
    dot(d, 1, 1, (255, 255, 255, 255))
    save(d, OUT + "fx_dot.png")
    l = new(3, 2)
    for x, y in [(0, 0), (1, 0), (2, 0), (0, 1), (1, 1)]:
        dot(l, x, y, (255, 255, 255, 255))
    dot(l, 2, 0, (255, 255, 255, 255))
    dot(l, 0, 1, (200, 200, 200, 255))
    dot(l, 1, 1, (200, 200, 200, 255))
    save(l, OUT + "fx_leaf.png")
    m = new(48, 24)
    for y in range(24):
        for x in range(48):
            r = math.hypot((x - 23.5) / 24.0, (y - 11.5) / 12.0)
            a = 90 if r <= 0.45 else 62 if r <= 0.75 else 34 if r <= 1.0 else 0
            if a:
                dot(m, x, y, (255, 255, 255, a))
    save(m, OUT + "fx_mist.png")
    for n, im in (("fx_dot", d), ("fx_leaf", l), ("fx_mist", m)):
        SHEETS.append((n, im))


def kala_eye():
    """Three pulse frames of a raksasa eye glow, 10x10, centred on the pupil."""
    fr = []
    for i in range(3):
        f = new(10, 10)
        ro, ri = 3.0 + i * 0.8, 1.6 + i * 0.5
        for y in range(10):
            for x in range(10):
                d = math.hypot(x + 0.5 - 5, y + 0.5 - 5)
                if d <= ri:
                    dot(f, x, y, (255, 150, 60, 150 + 35 * i))
                elif d <= ro:
                    dot(f, x, y, (255, 60, 30, 70 + 20 * i))
        if i == 2:
            rect(f, 4, 4, 5, 5, (255, 236, 160, 255))
        fr.append(f)
    sheet(fr, "kala_eye.png")


def main():
    exits()
    seal()
    gate_fence()
    rehearse()
    spawn_mark()
    shadows()
    props()
    particles()
    kala_eye()
    out = os.path.join(HERE, "world_fx_preview.png")
    px.preview(SHEETS, out, scale=4, bg=(70, 96, 70, 255))
    print("wrote", len(SHEETS), "sheets ->", out)


if __name__ == "__main__":
    main()
