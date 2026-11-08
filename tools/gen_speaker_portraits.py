#!/usr/bin/env python3
"""Dialogue speaker portraits (ui.md 3.1): 48x48 busts for assets/art/portraits/p_<name>.png plus the expression
variants p_<name>_happy/_angry/_sad.png. They sit inside frame_portrait.png (56x56) at offset (4, 4).
Run: python3 tools/gen_speaker_portraits.py   Output: portraits + tools/speaker_portraits_preview.png
Stdlib only. Art direction: 3/4 view facing right (toward the text), one light from the top-left, 4-tone
hue-shifted ramps (shadows go red-violet, never grey), outline on the outside only, eyes with white, iris and a
catch-light, brows apart from the lids. Shapes are shaded with contour-hugging bands (light from the top-left);
the features are hand-placed stamps. ui/portraits.gd maps speaker ids to these names.
"""
import os
import struct
import zlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "art", "portraits")
N = 48
LIGHT = (-0.55, -0.83)   # toward the light: top-left
MOODS = ("neutral", "happy", "angry", "sad")


# ---------------------------------------------------------------- png
def png_write(path, g):
    raw = bytearray()
    for row in g:
        raw.append(0)
        for c in row:
            raw.extend(c if c else (0, 0, 0, 0))

    def ch(t, b):
        return struct.pack(">I", len(b)) + t + b + struct.pack(">I", zlib.crc32(t + b) & 0xFFFFFFFF)
    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n" + ch(b"IHDR", struct.pack(">IIBBBBB", len(g[0]), len(g), 8, 6, 0, 0, 0))
                + ch(b"IDAT", zlib.compress(bytes(raw), 9)) + ch(b"IEND", b""))


def png_read(path):
    d = open(path, "rb").read()
    pos, idat, w, h = 8, b"", 0, 0
    while pos < len(d):
        ln, = struct.unpack(">I", d[pos:pos + 4]); t = d[pos + 4:pos + 8]; body = d[pos + 8:pos + 8 + ln]
        if t == b"IHDR":
            w, h = struct.unpack(">II", body[:8])
        elif t == b"IDAT":
            idat += body
        pos += 12 + ln
    raw = zlib.decompress(idat); st = w * 4
    rows, prev, i = [], bytearray(st), 0
    for _ in range(h):
        f = raw[i]; line = bytearray(raw[i + 1:i + 1 + st]); i += 1 + st
        for x in range(st):
            a = line[x - 4] if x >= 4 else 0; b = prev[x]; c = prev[x - 4] if x >= 4 else 0
            if f == 1: line[x] = (line[x] + a) & 255
            elif f == 2: line[x] = (line[x] + b) & 255
            elif f == 3: line[x] = (line[x] + (a + b) // 2) & 255
            elif f == 4:
                p = a + b - c; pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                line[x] = (line[x] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        rows.append([tuple(line[x * 4:x * 4 + 4]) for x in range(w)]); prev = line
    return rows


# ---------------------------------------------------------------- colour
def hx(s):
    s = s.lstrip("#"); return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), 255)


def R(*cols):
    return tuple(hx(c) for c in cols)


def mix(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3)) + (255,)


def hsh(x, y, s=0):
    """Stable per-pixel hash in [0, 1) for irregular textile patterns."""
    v = (x * 374761393 + y * 668265263 + s * 2246822519) & 0xFFFFFFFF
    v = ((v ^ (v >> 13)) * 1274126177) & 0xFFFFFFFF
    return (v ^ (v >> 16)) / 4294967296.0


# Skin ramps (hi, mid, shadow, deep)
SKIN = {
    "langsat": R("F6D2A6", "E3A877", "B8704F", "7A3E3A"),
    "sawo": R("E8B27E", "C4844F", "92543A", "5E2F2E"),
    "sawo_old": R("D9A276", "B07448", "804836", "50282A"),
    "deep": R("C68A5E", "9A5C3A", "6C3A2C", "432024"),
    "raksasa": R("F08A55", "CC4A30", "8E2A2A", "561726"),
    "golek": R("F2C890", "D69A5E", "9E6038", "62362A"),        # polished wood (Semar)
    "golek_red": R("F09070", "D0503A", "923030", "5A1C24"),    # Cepot's painted red face
    "laut": R("E2F6EC", "A8DCCC", "68A0A4", "3A6274"),
    "veil": R("C6C2CC", "9A94A6", "6E6880", "463E58"),        # featureless spirit, cool and bloodless
    "stone": R("B8B8A4", "8C8C7C", "62645A", "3E4040"),
    "fur": R("4A4048", "2C262E", "1C181E", "120E14"),
}
HAIR_BLACK = R("5A4A5E", "2E2432", "1C1520", "120C14")
HAIR_GREY = R("F2ECE0", "CFC6B6", "9C9184", "655A52")
GOLD = R("FFE8A0", "E2B64A", "A87A22", "6A4A14")
INK = hx("1E1418")
LID = hx("2A1A1C")
EYE_W = hx("F4EEDC")
GLINT = hx("FFF6E4")
TEAR = hx("A8D8F0")


# ---------------------------------------------------------------- masks and shading
def ell(cx, cy, rx, ry):
    return {(x, y) for y in range(N) for x in range(N) if ((x + .5 - cx) / rx) ** 2 + ((y + .5 - cy) / ry) ** 2 <= 1}


def poly(pts):
    out = set()
    ys = [p[1] for p in pts]
    for y in range(max(0, int(min(ys)) - 1), min(N, int(max(ys)) + 2)):
        for x in range(N):
            px_, py_ = x + .5, y + .5; ins = False; j = len(pts) - 1
            for i in range(len(pts)):
                xi, yi = pts[i]; xj, yj = pts[j]
                if (yi > py_) != (yj > py_) and px_ < (xj - xi) * (py_ - yi) / (yj - yi) + xi:
                    ins = not ins
                j = i
            if ins:
                out.add((x, y))
    return out


def shift(m, dx, dy):
    return {(x + dx, y + dy) for (x, y) in m}


def march(m, x, y, d):
    fx, fy, k = x + .5, y + .5, 0.0
    while k < 48:
        fx += d[0] * .5; fy += d[1] * .5; k += .5
        if (int(fx // 1), int(fy // 1)) not in m:
            return k
    return k


def shade(m, ramp, hi=1.5, shd=2.5, deep=0.0, light=LIGHT):
    """Contour-hugging bands: a lit rim on the top-left edges, a shadow band of fixed width on the far edges."""
    hic, mid, shc, dpc = ramp
    out = {}
    back = (-light[0], -light[1])
    for (x, y) in m:
        a = march(m, x, y, light); b = march(m, x, y, back)
        c = mid
        if a <= hi and a < b:
            c = hic
        if b <= shd and b <= a:
            c = shc
        if deep and b <= deep:
            c = dpc
        out[(x, y)] = c
    return out


class Fig:
    def __init__(self):
        self.g = {}

    def paint(self, d, clip=None):
        for p, c in d.items():
            if 0 <= p[0] < N and 0 <= p[1] < N and (clip is None or p in clip):
                self.g[p] = c

    def fill(self, m, c, clip=None):
        self.paint({p: c for p in m}, clip)

    def px(self, pts, c):
        for p in pts:
            if 0 <= p[0] < N and 0 <= p[1] < N:
                self.g[p] = c

    def stamp(self, x0, y0, rows, pal):
        for j, row in enumerate(rows):
            for i, ch in enumerate(row):
                if ch not in ". ":
                    self.px([(x0 + i, y0 + j)], pal[ch])

    def merge(self, other, dx=0, dy=0):
        for (x, y), c in other.g.items():
            if 0 <= x + dx < N and 0 <= y + dy < N:
                self.g[(x + dx, y + dy)] = c


def outline(fig):
    m = set(fig.g); add = {}
    for y in range(N):
        for x in range(N):
            if (x, y) in m:
                continue
            nb = [(x + dx, y + dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)) if (x + dx, y + dy) in m]
            if not nb:
                continue
            lit = not any(p[0] < x or p[1] < y for p in nb)
            c = min((fig.g[p] for p in nb), key=lambda c: sum(c[:3]))
            add[(x, y)] = mix(c, INK, 0.6) if lit else INK
    fig.g.update(add)


def backdrop(dark, mid, light, cx=22, cy=18):
    g = [[None] * N for _ in range(N)]
    for y in range(N):
        for x in range(N):
            d = ((x + .5 - cx) ** 2 + ((y + .5 - cy) * 1.1) ** 2) ** .5
            g[y][x] = light if d < 15 else mid if d < 24 else dark
    return g


# ---------------------------------------------------------------- head geometry (3/4 view, facing right)
JAWS = {
    "soft": [(14, 19), (33.5, 15), (34, 21), (33, 26), (31, 29.5), (28, 32), (24.5, 32.5), (19.5, 29), (15, 25)],
    "square": [(14, 19), (33.5, 15), (34.5, 21), (34, 27), (31.5, 31), (26.5, 33), (21, 32), (16, 27)],
    "narrow": [(14.5, 19), (33, 15), (33.5, 21), (32.5, 26.5), (30, 30.5), (27, 33), (24, 33), (19.5, 29.5), (15.5, 25)],
    "round": [(13.5, 19), (34, 15), (35, 21), (34.5, 26), (32, 30), (27.5, 32.5), (22, 32), (17, 29), (14, 25)],
}


def head_mask(jaw):
    return ell(23, 17, 10.5, 10.5) | poly(JAWS[jaw])


def skin_head(f, sk, jaw, neck_w=0):
    """Neck, head and ear. The neck takes the jaw's cast shadow as a band that follows the jaw line."""
    head = head_mask(jaw)
    neck = poly([(18.5 - neck_w, 25), (28.5 + neck_w, 25), (28 + neck_w, 42), (19 - neck_w, 42)])
    nk = {}
    for (x, y) in neck:
        under = any((x - 1, y - k) in head for k in (1, 2, 3))
        nk[(x, y)] = sk[2] if under or x >= 27 + neck_w else sk[1]
        if under and (x - 1, y - 1) in head and x > 22:
            nk[(x, y)] = sk[3] if (x - 1, y - 2) in head and x > 25 else sk[2]
    f.paint(nk)
    f.paint(shade(head, sk, hi=1.0, shd=2.0))
    # ear
    f.paint(shade(ell(15.5, 21.5, 2, 3), sk, hi=1.0, shd=1.0))
    f.px([(15, 21), (15, 22)], sk[2]); f.px([(16, 20)], sk[3])
    return head


# eye stamps per set: (near rows, far rows); L lid, w white, I iris, h glint, s skin shadow, k skin highlight
EYES = {
    "open": (["LLLL.", "wIhs.", ".Is.."], ["LLL", "hIL", ".s."]),
    "round": (["LLLL.", "whIL.", "wIIs.", ".ss.."], ["LLL", "hIL", "II.", "s.."]),
    "hooded": (["LLLL.", "LIhL.", ".s..."], ["LLL", "IhL", "..."]),
    "narrow": (["LLLL.", ".Ihs.", "....."], ["LLL", "hI.", "..."]),
}


def eyes(f, sk, eset="open", mood="neutral", x=20, y=19, iris="2A1810"):
    P = {"L": LID, "w": EYE_W, "I": hx(iris), "h": GLINT, "s": sk[2], "k": sk[0], "t": TEAR}
    near, far = EYES[eset]
    if mood == "angry":
        near, far = EYES["hooded"]
        near = ["LLLLL"] + near[1:]
    near, far = list(near), list(far)
    if mood == "happy":
        near[-1] = "".join("k" if c != "." else "." for c in near[-1].replace("s", "k").replace("I", "k").replace("w", "k"))
        far[-1] = "".join("k" if c != "." else "." for c in far[-1].replace("s", "k").replace("I", "k"))
    f.stamp(x, y, near, P); f.stamp(x + 8, y, far, P)
    f.px([(x - 1, y)], LID)
    if mood == "sad":
        f.px([(x - 1, y + 1)], LID); f.px([(x - 1, y)], sk[1])
        f.px([(x + 1, y + len(near)), (x + 1, y + len(near) + 1)], TEAR)


def brows(f, c, mood="neutral", x=20, y=19, thick=False):
    if mood == "angry":
        a = [(x - 1, y - 3), (x, y - 3), (x + 1, y - 2), (x + 2, y - 2), (x + 3, y - 1)]
        b = [(x + 8, y - 1), (x + 9, y - 2), (x + 10, y - 2)]
    elif mood == "sad":
        a = [(x - 1, y - 1), (x, y - 2), (x + 1, y - 2), (x + 2, y - 3), (x + 3, y - 3)]
        b = [(x + 8, y - 3), (x + 9, y - 2), (x + 10, y - 2)]
    else:
        a = [(x - 1, y - 2), (x, y - 3), (x + 1, y - 3), (x + 2, y - 3), (x + 3, y - 2)]
        b = [(x + 8, y - 3), (x + 9, y - 3), (x + 10, y - 2)]
    f.px(a + b, c)
    if thick or mood == "angry":
        f.px([(p[0], p[1] - 1) for p in a[1:4]] + [(b[0][0], b[0][1] - 1), (b[1][0], b[1][1] - 1)], c)


def nose(f, sk, x=27, y=20, big=False):
    f.px([(x + 1, y + 1), (x + 1, y + 2), (x + 2, y + 3)], sk[2])
    f.px([(x, y + 4)], sk[2]); f.px([(x + 1, y + 4)], sk[3])
    f.px([(x + 1, y + 3)], sk[0])
    if big:
        f.px([(x + 2, y + 2), (x + 3, y + 3)], sk[2]); f.px([(x + 2, y + 4)], sk[3]); f.px([(x + 2, y + 2)], sk[0])


def mouth(f, sk, mood="neutral", lip="7A3436", x=24, y=28, teeth=True):
    L = hx(lip); W = hx("F2EAD8")
    P = {"L": L, "W": W if teeth else L, "k": sk[0], "s": sk[2], "d": hx("4A1A1E")}
    if mood == "neutral":
        f.stamp(x, y, ["LLLLs", ".kk.."], P)
    elif mood == "happy":
        f.stamp(x - 1, y - 1, ["L....L", ".LWWL.", "..dd..", "..kk.."], P)
        f.px([(x - 3, y - 3), (x - 2, y - 3)], sk[0])
    elif mood == "angry":
        f.stamp(x - 1, y, [".LLLL.", "LWWWWL", ".s..s."], P)
    elif mood == "sad":
        f.stamp(x, y, [".LLL.", "L...L", ".kk.."], P)


# ---------------------------------------------------------------- hair and headwear
def hair_cap(f, ramp, hairline=13, front=33.5):
    m = poly([(12, 22), (12, 11), (16, 6.5), (23, 5), (30, 6.5), (front, 10.5), (front, 14), (29, hairline), (24, hairline + .5),
              (19, hairline + 2), (17.5, 20), (15, 23)])
    f.paint(shade(m, ramp, hi=1.5, shd=2.0))
    for (x, y) in [(20, 8), (23, 7), (26, 8), (17, 11), (15, 14), (29, 10)]:   # a few comb strands, not a grid
        if (x, y) in m:
            f.px([(x, y), (x - 1, y + 1)], ramp[2])
    return m


def short_hair(f, ramp):
    m = poly([(12, 21), (12, 11), (16, 6.5), (23, 4.5), (31, 6), (34.5, 10), (34, 14), (31, 12), (27, 12.5), (24, 11.5),
              (21, 13.5), (19, 15), (18, 19), (15.5, 22)])
    f.paint(shade(m, ramp, hi=1.5, shd=2.0))
    for (x, y) in [(31, 12), (27, 12), (23, 12), (20, 13)]:   # fringe tips
        f.px([(x, y + 1)], ramp[2])
    f.px([(22, 7), (25, 6), (18, 9)], ramp[0])
    return m


def cast_hairline(f, sk, cover, y0=12, y1=16, x0=19, x1=34):
    for x in range(x0, x1):
        for y in range(y0, y1):
            if (x, y) in cover and (x, y + 1) not in cover and (x, y + 1) in f.g:
                f.px([(x, y + 1)], sk[2])
                break


def batik_fill(f, m, ramp, motif, seed, sparse=0.35, parang=False):
    """Batik over a shaded shape: motifs sit on a jittered grid so the cloth never reads as a stripe pattern.
    parang: broken diagonal lines instead of dots (blangkon, selendang)."""
    sh = shade(m, ramp, hi=1.5, shd=2.0)
    f.paint(sh)
    if parang:
        for (x, y) in m:
            if (x + y) % 5 == 0 and hsh((x - y) // 3, 0, seed) > 0.3:
                lit = sh[(x, y)] in (ramp[0], ramp[1])
                f.px([(x, y)], motif if lit else mix(motif, ramp[2], 0.55))
        return
    for (x, y) in m:
        gx, gy = (x + (y // 4) % 2 * 2) // 4, y // 4
        if hsh(gx, gy, seed) > sparse:
            cx, cy = gx * 4 - (y // 4) % 2 * 2 + 1 + int(hsh(gx, gy, seed + 1) * 2), gy * 4 + 1 + int(hsh(gx, gy, seed + 2) * 2)
            if (x, y) == (cx, cy):
                lit = sh[(x, y)] in (ramp[0], ramp[1])
                f.px([(x, y)], motif if lit else mix(motif, ramp[2], 0.55))
                if (x + 1, y) in m and hsh(x, y, seed + 3) > 0.5:
                    f.px([(x + 1, y)], mix(motif, sh[(x, y)], 0.5))


def iket(f, sk, cloth, motif, seed=1, peak=True, band="B8863A"):
    m = poly([(11.5, 14), (12, 9), (16, 5.5), (24, 4.5), (31, 6.5), (34.5, 10), (34.5, 13), (28, 12.5), (20, 13), (14, 15.5)])
    batik_fill(f, m, cloth, motif, seed)
    f.px([(x, 13) for x in range(29, 35)] + [(x, 14) for x in range(17, 29)], hx(band))
    f.px([(x, 12) for x in range(29, 34)] + [(x, 13) for x in range(18, 28)], cloth[2])
    if peak:
        f.paint(shade(poly([(30, 7), (35, 2.5), (36.5, 6), (34.5, 10)]), cloth, hi=1, shd=1.5))
    f.paint(shade(ell(11, 14, 2.6, 2.4), cloth, hi=1, shd=1.5))
    f.paint(shade(poly([(9, 15), (12, 15), (10.5, 22), (7.5, 21)]), cloth, hi=1, shd=1.5))
    f.paint(shade(poly([(11, 15), (13.5, 15.5), (13, 21), (11, 20)]), cloth, hi=0, shd=2))
    for x in range(19, 33):
        if (x, 14) not in m:
            f.px([(x, 14 + (1 if x < 29 else 0))], sk[2])
    return m


def blangkon(f, sk, cloth, motif, seed=2):
    m = poly([(12, 18), (12, 10), (16, 5.5), (23, 4), (30, 5.5), (34.5, 10), (34.5, 13.5), (26, 13), (19, 14.5), (16, 18)])
    batik_fill(f, m, cloth, motif, seed, parang=True)
    f.paint(shade(ell(11.5, 16, 3.6, 3.4), cloth, hi=1, shd=2))   # mondolan (the knot bulge at the back)
    f.px([(10, 15), (11, 14)], cloth[0])
    f.px([(x, 13) for x in range(26, 35)] + [(x, 14) for x in range(18, 26)], cloth[3])
    for x in range(19, 34):
        if (x, 14) not in m:
            f.px([(x, 14 + (1 if x < 26 else 0))], sk[2])
    return m


def caping(f, sk):
    straw = R("F0D48A", "D2A85A", "9A7436", "5E4420")
    m = poly([(2, 15), (22, 1), (44, 13.5), (40, 15.5), (24, 13), (6, 16.5)])
    f.paint(shade(m, straw, hi=1.5, shd=2))
    for i in range(6, 40, 5):   # woven ribs from the peak
        for k in range(0, 13):
            x = 22 + (i - 22) * k / 13.0; y = 1 + k
            if (int(x), int(y)) in m and k > 2:
                f.px([(int(x), int(y))], straw[2])
    f.px([(x, 16) for x in range(14, 36) if (x, 16) in f.g], sk[3])
    f.px([(x, 17) for x in range(19, 34) if (x, 17) in f.g], sk[2])
    return m


def kuluk(f, sk, cloth):
    m = poly([(13, 14), (13, 3), (17, 0), (29, 0), (33.5, 3), (34, 13), (24, 12.5)])
    f.paint(shade(m, cloth, hi=1.5, shd=2.5))
    f.px([(x, y) for x in range(13, 35) for y in (11, 12) if (x, y) in m], GOLD[1])
    f.px([(x, 11) for x in range(14, 34, 3)], GOLD[0])
    f.px([(x, 4) for x in range(15, 32, 2)], mix(cloth[0], GOLD[1], 0.5))
    for x in range(19, 34):
        f.px([(x, 13)], sk[2])
    return m


def konde(f, ramp, cx=10.5, cy=16, pin=True):
    m = ell(cx, cy, 4.2, 3.8)
    for p in m:
        f.g.pop(p, None)
    f.paint(shade(m, ramp, hi=1.2, shd=1.5))
    f.px([(int(cx) - 1, int(cy) - 1), (int(cx), int(cy) - 1), (int(cx) + 1, int(cy))], ramp[2])
    if pin:
        f.px([(int(cx) - 3, int(cy) - 3), (int(cx) - 2, int(cy) - 4), (int(cx) - 1, int(cy) - 5)], GOLD[1])
        f.px([(int(cx) - 4, int(cy) - 2)], GOLD[0])
    return m


def siger(f, sk, peak=3.0):
    m = poly([(15, 13), (18, 10), (22, 9), (25.5, peak), (29, 9), (32, 9.5), (34.5, 12), (31, 12.5), (26, 13), (20, 14), (16, 15)])
    f.paint(shade(m, GOLD, hi=1.5, shd=1.5))
    f.px([(25, 8), (26, 8)], hx("C0392B")); f.px([(25, 7)], hx("FF8A70"))
    f.px([(21, 11), (30, 11), (18, 12)], hx("C0392B"))
    for x in range(20, 33):
        if (x, 14) not in m:
            f.px([(x, 14)], sk[2])
    return m


def kembang_goyang(f, pts):
    for (x, y) in pts:
        f.px([(x + 1, y + 2), (x + 1, y + 3)], GOLD[2])
        f.px([(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)], GOLD[1]); f.px([(x, y)], GOLD[0])


def melati(f, x0=11, y0=17, y1=39, step=2):
    for i, y in enumerate(range(y0, y1, step)):
        x = x0 + (i % 2) + i // 4
        f.px([(x, y)], hx("F4F0E0")); f.px([(x, y + 1)], hx("B8C8A0"))


# ---------------------------------------------------------------- clothing
def shoulders(f, ramp, narrow=0):
    sh = poly([(0 + narrow, 48), (2 + narrow, 41), (8 + narrow, 37.5), (17, 35), (30, 35), (39 - narrow, 37), (45 - narrow, 40.5), (48 - narrow, 48)])
    f.paint(shade(sh, ramp, hi=1.5, shd=4))
    return sh


def chest_v(f, sk, depth=42, w=0):
    v = poly([(19 - w, 34), (29 + w, 34), (24.5, depth), (23.5, depth)])
    f.paint({p: (sk[2] if p[1] < 36 or p[0] > 25 else sk[1]) for p in v})
    return v


def pangsi(f, sk, cloth, sarung=None):
    sh = shoulders(f, cloth)
    chest_v(f, sk)
    f.fill(poly([(17, 34.5), (19.5, 34), (24, 42.5), (22.5, 43.5)]), cloth[1])
    f.fill(poly([(30, 34.5), (28, 34), (24, 42.5), (25.5, 43.5)]), cloth[2])
    if sarung:
        a, b, c = (hx(s) for s in sarung)
        band = poly([(4, 39), (11, 36), (40, 48), (28, 48)])
        for (x, y) in band & sh:
            u, v = (x + y) // 4 % 2, (x - y) // 4 % 2
            f.px([(x, y)], a if u and v else b if u or v else c)
        f.px([(x, int(36 + (x - 11) * 12 / 29.0)) for x in range(11, 40) if (x, int(36 + (x - 11) * 12 / 29.0)) in sh], mix(c, INK, 0.4))
    return sh


def kebaya(f, sk, cloth, panel="D8C8A4", brooch=True, trim=None):
    sh = shoulders(f, cloth, narrow=1)
    chest_v(f, sk, depth=40, w=0)
    f.fill(poly([(21, 40), (27, 40), (28, 48), (20, 48)]), hx(panel))
    f.fill(poly([(16, 35), (19.5, 34), (22, 40), (20, 48), (17, 48)]), cloth[1])
    f.fill(poly([(31, 35), (28.5, 34), (26.5, 40), (28, 48), (31, 48)]), cloth[2])
    if brooch:
        for y in (42, 45):
            f.px([(24, y)], GOLD[0]); f.px([(23, y)], GOLD[2])
    if trim:
        t = hx(trim)
        for (x, y) in [(16, 35), (17, 36), (18, 38), (19, 39), (20, 41), (28, 39), (29, 38), (30, 36), (31, 35)]:
            f.px([(x, y)], t)
    return sh


def selendang(f, sh, base, motif, seed=5):
    sel = poly([(1, 44), (6, 38), (13, 36), (17, 38), (12, 48), (2, 48)]) & sh
    ramp = (mix(hx(base), hx("FFFFFF"), .2), hx(base), mix(hx(base), INK, .35), mix(hx(base), INK, .6))
    batik_fill(f, sel, ramp, hx(motif), seed, sparse=0.2)
    f.px([(x, int(36 + (x - 6) * 0.3)) for x in range(7, 15)], ramp[3])


def beskap(f, sk, cloth, trim=None):
    sh = shoulders(f, cloth)
    f.fill(poly([(19.5, 34), (28.5, 34), (28, 37), (20, 37)]), cloth[1])   # high collar
    f.px([(x, 34) for x in range(20, 28)], cloth[0])
    f.px([(x, 37) for x in range(20, 28)], cloth[3])
    for y in range(38, 48):   # off-centre front edge
        f.px([(26 + (y - 38) // 4, y)], cloth[3])
    for y in (40, 43, 46):
        f.px([(25 + (y - 38) // 4, y)], GOLD[1] if trim else cloth[0])
    if trim:
        f.px([(x, 35) for x in range(20, 28, 2)], hx(trim))
    return sh


def surjan(f, sk, cloth):
    sh = shoulders(f, cloth)
    for (x, y) in sh:   # lurik stripes, uneven widths
        if x % 7 in (0, 3) or x % 11 == 5:
            f.px([(x, y)], mix(f.g[(x, y)], hx("E8D8B0"), .35))
    f.fill(poly([(19.5, 34), (28.5, 34), (28, 37), (20, 37)]), cloth[1])
    f.px([(x, 37) for x in range(20, 28)], cloth[3])
    for y in range(38, 48):
        f.px([(24, y)], cloth[3])
    for y in (40, 43, 46):
        f.px([(25, y)], GOLD[1])
    return sh


def velvet(f, sk, cloth, kalung=True):
    sh = shoulders(f, cloth, narrow=1)
    v = chest_v(f, sk, depth=41, w=2)
    for (x, y) in [(16, 35), (17, 36), (18, 37), (19, 38), (20, 40), (21, 41), (22, 42), (25, 42), (26, 41), (27, 40), (28, 38), (29, 37), (30, 36), (31, 35)]:
        f.px([(x, y)], GOLD[1]); f.px([(x - 1, y + 1)], GOLD[2])
    f.px([(x, 45) for x in range(5, 44, 3) if (x, 45) in sh], GOLD[2])
    if kalung:
        f.px([(20, 36), (21, 37), (22, 38), (23, 38), (24, 38), (25, 38), (26, 37), (27, 36)], GOLD[0])
        f.px([(23, 39), (24, 39)], hx("C0392B")); f.px([(23, 40)], GOLD[2])
    return sh


def bare(f, sk, broad=0, kelat=True, kalung=False):
    torso = poly([(0, 48), (1, 40 - broad), (8, 35.5 - broad), (18, 34), (30, 34), (40, 35.5 - broad), (47, 39 - broad), (48, 48)])
    f.paint(shade(torso, sk, hi=1.5, shd=3))
    f.px([(x, 42 + (x - 18) // 7) for x in range(14, 38)], sk[2])
    if kelat:
        f.paint(shade(poly([(0, 43), (6, 38), (8, 40), (2, 46)]), GOLD, hi=1, shd=1))
    if kalung:
        for (x, y) in [(15, 36), (17, 38), (19, 39), (21, 40), (24, 40), (27, 40), (29, 39), (31, 38), (33, 36)]:
            f.px([(x, y), (x + 1, y)], GOLD[1]); f.px([(x, y + 1)], GOLD[2])
    return torso


# ---------------------------------------------------------------- characters
def human(c, mood):
    """Common human bust from a spec dict."""
    sk = SKIN[c.get("skin", "sawo")]
    jaw = c.get("jaw", "soft")
    back, body, head = Fig(), Fig(), Fig()
    hr = c.get("hair_ramp", HAIR_BLACK)
    # long hair / back hair behind everything
    if c.get("long"):
        back.paint(shade(poly([(9, 12), (20, 8), (19, 30), (21, 44), (8, 44), (6, 30)]), hr, hi=1, shd=2.5))
    # body
    kind, arg = c["body"][0], c["body"][1:]
    {"pangsi": pangsi, "kebaya": kebaya, "beskap": beskap, "surjan": surjan, "velvet": velvet, "bare": bare}[kind](body, sk, *arg)
    if c.get("selendang"):
        selendang(body, set(body.g), *c["selendang"])
    # head
    skin_head(head, sk, jaw)
    hair = c.get("hair", "short")
    if hair == "short":
        cover = short_hair(head, hr)
    elif hair == "bald":
        cover = set()
    else:
        cover = hair_cap(head, hr)
        head.paint(shade(poly([(15, 13), (20, 13.5), (18.5, 18), (17, 20), (15, 19)]), hr, hi=1, shd=1.5))
    if hair in ("konde", "short_konde"):
        konde(head, hr, pin=c.get("pin", True))
    if not c.get("hat"):
        cast_hairline(head, sk, cover)
    hat = c.get("hat")
    if hat == "iket":
        iket(head, sk, *c["iket"])
    elif hat == "blangkon":
        blangkon(head, sk, *c["blangkon"])
    elif hat == "caping":
        caping(head, sk)
    elif hat == "kuluk":
        kuluk(head, sk, c["kuluk"])
    elif hat == "siger":
        siger(head, sk)
        kembang_goyang(head, [(13, 6), (16, 3), (9, 9)])
    elif hat == "jamang":
        jm = poly([(14, 13), (20, 11), (27, 10.5), (34.5, 11.5), (34.5, 13), (26, 13), (19, 14), (15, 15.5)])
        head.paint(shade(jm, GOLD, hi=1, shd=1))
        for x in (18, 22, 26, 30, 33):
            b = 11 if x < 30 else 10
            head.px([(x, b), (x - 1, b - 1)], GOLD[1]); head.px([(x - 2, b - 2)], GOLD[0]); head.px([(x, b - 1)], GOLD[2])
        head.px([(25, 12)], hx("C0392B"))
    elif hat == "kerudung":
        kc = c["kerudung"]
        kr = (mix(hx(kc), hx("FFFFFF"), .25), hx(kc), mix(hx(kc), INK, .3), mix(hx(kc), INK, .55))
        m = poly([(9, 30), (10, 11), (15, 5.5), (23, 4), (31, 5.5), (35, 10), (35.5, 13.5), (30, 12), (24, 12.5), (19, 14.5), (16.5, 20), (16, 28), (13, 36)])
        head.paint(shade(m, kr, hi=1.5, shd=2.5))
        head.px([(x, 12) for x in range(30, 36)] + [(19, 15), (18, 16), (17, 18)], kr[3])
        head.px([(x, 11) for x in range(30, 35)] + [(18, 14), (17, 15), (16, 17)], hx("F2E8D0"))   # embroidered hem
        for (x, y) in [(14, 10), (20, 7), (26, 6), (12, 20), (12, 27)]:
            head.px([(x, y)], kr[0])
        cast_hairline(head, sk, m)
    if c.get("flower"):
        fx_, fy_ = c["flower"]
        head.px([(fx_ - 1, fy_), (fx_ + 1, fy_), (fx_, fy_ - 1), (fx_, fy_ + 1)], hx("F4F1DE")); head.px([(fx_, fy_)], hx("F2C040"))
    if c.get("melati"):
        melati(head)
    if c.get("earring"):
        head.px([(16, 25)], GOLD[1])
    # face
    eset = c.get("eyes", "open")
    eyes(head, sk, eset, mood, iris=c.get("iris", "2A1810"))
    if c.get("brow") is not False:
        brows(head, c.get("brow_c", hr[1]), mood, thick=c.get("thick_brow", False))
    nose(head, sk, big=c.get("big_nose", False))
    if c.get("stache"):
        head.px([(x, 27) for x in range(23, 30)] + [(22, 28), (29, 28)], c.get("stache_c", hr[1]))
    mouth(head, sk, mood, lip=c.get("lip", "7A3436"), teeth=c.get("teeth", True))
    if c.get("beard"):
        bc = c.get("beard_ramp", HAIR_GREY)
        head.paint(shade(poly([(21, 29), (31, 28), (30, 33), (26.5, 36), (23, 33.5)]), bc, hi=1, shd=1.5))
        head.px([(x, 27) for x in range(23, 30)], bc[1]); head.px([(22, 28), (29, 28)], bc[1])
        head.px([(25, 30), (26, 30), (27, 30)], hx("5A2A28") if mood != "happy" else hx("F2EAD8"))
    if c.get("age"):
        head.px([(18, 21), (25, 26), (24, 27) if mood != "happy" else (23, 26)], sk[2])
    if c.get("blush"):
        head.px([(21, 24), (22, 24)], mix(sk[1], hx("E05A50"), 0.3))
    head.px([(31, 25), (32, 24)], sk[2])   # far cheek plane
    if c.get("goatee"):
        head.px([(26, 32), (27, 32), (26, 33)], hr[1])
    fig = Fig()
    dy = c.get("dy", 0)
    fig.merge(back); fig.merge(body); fig.merge(head, 0, dy)
    return fig


def kala(mood):
    sk = SKIN["raksasa"]
    f = Fig()
    hairR = R("6A3A5A", "3A1E36", "26122A", "180A1C")
    # gimbal mane, a flame-shaped mass behind the head
    mane = poly([(5, 36), (2, 26), (5, 22), (1, 15), (7, 12), (5, 5), (12, 7), (14, 1), (21, 5), (27, 0), (30, 6), (37, 3), (36, 11), (40, 15), (34, 18), (30, 30), (14, 34)])
    f.paint(shade(mane, hairR, hi=1.5, shd=3))
    for (x, y) in [(6, 20), (8, 14), (4, 28), (11, 8), (20, 6), (33, 7), (27, 3)]:
        f.px([(x, y), (x + 1, y + 1)], hairR[0])
    torso = bare(f, sk, broad=1, kalung=True)
    sash = poly([(30, 33), (36, 33.5), (24, 48), (16, 48)])
    f.paint(shade(sash, R("4A6A9A", "2A3E6A", "1A2648", "101830"), hi=1, shd=2), clip=torso)
    head = ell(24, 19, 11, 10.5) | poly([(13, 20), (36, 15), (37, 24), (35, 30), (29, 33), (20, 33), (15, 28)])
    f.paint(shade(head, sk, hi=1.2, shd=2.5))
    # jamang: a gold band hugging the brow with petal-shaped turidan points, garuda mungkur crest behind it
    gm = poly([(4, 12), (6, 6), (9, 3), (12, 4), (11, 7), (14, 9), (15, 13), (10, 16)])
    f.paint(shade(gm, GOLD, hi=1, shd=2))
    f.px([(8, 6), (9, 7), (10, 9), (8, 10), (7, 12)], GOLD[3]); f.px([(9, 4)], hx("C0392B"))
    jam = poly([(13, 14), (17, 11), (25, 9.5), (33, 10), (37.5, 12.5), (37.5, 14.5), (30, 13), (22, 13.5), (15, 16)])
    f.paint(shade(jam, GOLD, hi=1, shd=1))
    for i, x in enumerate((16, 20, 24, 28, 32, 35)):   # turidan petals, small and leaning back like flames
        base = 11 if x < 30 else 10
        f.px([(x, base), (x - 1, base - 1), (x - 1, base - 2)], GOLD[1]); f.px([(x - 2, base - 3)], GOLD[0])
        f.px([(x, base - 1)], GOLD[2])
    f.px([(x, 13) for x in range(18, 36, 3)], hx("2FA88A"))
    sump = poly([(13, 18), (17, 16), (18, 22), (14, 24)])   # sumping at the ear
    f.paint(shade(sump, GOLD, hi=1, shd=1)); f.px([(15, 20)], hx("C0392B"))
    # brow ridge
    bd = {"angry": 1, "sad": -1}.get(mood, 0)
    ridge = poly([(17, 15 + bd), (35, 14), (36, 16), (29, 18 + bd), (26, 16), (22, 17.5 + bd), (18, 18)])
    if mood == "sad":
        ridge = poly([(17, 16), (24, 14.5), (35, 15), (36, 17), (29, 17), (26, 16.5), (22, 17.5), (18, 18)])
    f.paint(shade(ridge, hairR, hi=1, shd=1))
    E = {"W": hx("FFF2C8"), "w": hx("D8C890"), "P": INK, "h": hx("FFFFFF"), "s": sk[3], "k": sk[0]}
    if mood == "happy":
        f.stamp(18, 18, [".sss.", "sWWWs", "WPPhw", "kkkkk"], E); f.stamp(29, 18, [".ss.", "sWWs", "PPhw", "kkk."], E)
    else:
        f.stamp(18, 17, [".sss.", "sWWWs", "WWPPw", "WWPhw", "sWwws", ".sss."], E)
        f.stamp(29, 17, [".ss.", "sWWs", "WPPw", "WPhw", ".ss."], E)
    f.paint(shade(ell(28.5, 25.5, 3, 2.4), sk, hi=1, shd=1))
    f.px([(26, 26), (30, 27)], sk[3]); f.px([(27, 24)], sk[0])
    T, t = hx("F4ECD0"), hx("C8B890")
    if mood == "sad":
        mo = poly([(20, 29), (33, 28.5), (31, 31), (22, 31.5)])
    elif mood == "angry":
        mo = poly([(18, 28), (35, 27), (34, 33), (20, 33.5)])
    else:
        mo = poly([(18, 28.5), (35, 27.5), (33, 32), (21, 32.5)])
    f.fill(mo, hx("3A0E14"))
    top = min(y for _, y in mo)
    f.px([(x, top + 1) for x in range(20, 34) if (x, top + 1) in mo], T)
    f.px([(x, top + 1) for x in range(21, 34, 2) if (x, top + 1) in mo], t)
    if mood == "happy":
        f.px([(x, top) for x in range(19, 35) if (x, top) in mo], sk[3])
    bot = max(y for _, y in mo)
    f.px([(21, bot), (21, bot - 1), (22, bot - 2), (20, bot + 1)], T); f.px([(22, bot - 1)], t)
    f.px([(32, bot - 1), (32, bot - 2), (33, bot - 3), (31, bot)], T)
    f.px([(x, bot + 1) for x in range(22, 32)], sk[2])
    return f


def semar(mood):
    sk = SKIN["golek"]
    f = Fig()
    jacket = R("4A4450", "2C2834", "1C1922", "121016")
    sh = shoulders(f, jacket)
    sh2 = poly([(0, 48), (1, 40), (7, 35), (40, 35), (47, 40), (48, 48)])
    f.paint(shade(sh2, jacket, hi=1.5, shd=4))
    pol = poly([(1, 46), (6, 38), (14, 35.5), (34, 48), (20, 48)]) & sh2   # poleng (black-white check) sash
    for (x, y) in pol:
        f.px([(x, y)], hx("EDE3CC") if (x // 3 + y // 3) % 2 else hx("2A2428"))
    f.px([(x, int(35.5 + (x - 14) * 0.6)) for x in range(14, 34)], hx("8A2A24"))
    head = ell(24, 20, 12, 11) | poly([(14, 22), (36, 18), (37, 27), (34, 32), (28, 35), (20, 34), (15, 30)])
    f.paint(shade(head, sk, hi=1.5, shd=2.5))
    f.px([(x, 33) for x in range(22, 31)], sk[2])   # double chin crease
    f.paint(shade(ell(13.5, 23, 2, 3), sk, hi=1, shd=1))   # ear
    f.px([(13, 22), (13, 23)], sk[2])
    f.px([(18, 12), (19, 11), (17, 25)], hx("FFF4DC"))   # polished-wood speculars
    tuft = poly([(20, 11), (21, 4), (25, 0.5), (31, 1.5), (33, 5), (30, 4.5), (27, 4), (25, 7), (24.5, 10.5)])
    f.paint(shade(tuft, HAIR_GREY, hi=1, shd=1.5))   # kuncung, the white forelock
    f.px([(x, 11) for x in range(20, 25)], sk[2])
    P = {"L": LID, "w": EYE_W, "I": hx("2A1810"), "h": GLINT, "s": sk[2], "k": sk[0]}
    if mood == "happy":
        f.stamp(20, 20, [".LLL.", "L...L"], P); f.stamp(29, 20, [".LL.", "L..L"], P)
    else:
        near, far = ["sssss", "LLLLL", "wwIhL", ".sss."], ["sss", "LLL", "wIh", ".s."]   # heavy drooping lids
        f.stamp(20, 18, near, P); f.stamp(29, 18, far, P)
        if mood == "sad":
            f.px([(21, 22), (21, 23)], TEAR)
    if mood == "angry":
        f.px([(19, 16), (20, 16), (21, 17), (22, 17), (23, 17), (29, 17), (30, 16), (31, 16)], LID)
    f.paint(shade(ell(30, 24.5, 2.4, 2.2), sk, hi=1, shd=1)); f.px([(30, 26), (31, 26)], sk[3])
    lip, W = hx("7A3030"), hx("F4ECD0")
    P2 = {"L": lip, "W": W, "k": sk[0], "s": sk[2]}
    if mood == "happy":
        f.stamp(22, 28, ["L......L", ".LLWLLL.", "..kkkk.."], P2)
    elif mood == "sad":
        f.stamp(23, 29, [".LLLL.", "L....L"], P2)
    elif mood == "angry":
        f.stamp(23, 28, ["LLLLLL", ".WLLL."], P2)
    else:
        f.stamp(22, 28, ["Ls....", ".LLWLL", "..kkk."], P2)   # mesem: a lopsided smile, one tooth
    return f


def cepot(mood):
    sk = SKIN["golek_red"]
    c = dict(skin="golek_red", jaw="round", body=("pangsi", R("4A4A5A", "2A2A36", "1C1C26", "121218"), None),
             hat="iket", iket=(R("5A5A6A", "36364A", "222234", "16161E"), hx("C9A24A"), 7, False, "9A6A2A"),
             eyes="round", big_nose=True, lip="5A1A1E")
    f = human(c, "neutral" if mood == "happy" else mood)
    # wide buck-toothed grin (Cepot's signature), shiny painted cheeks
    P = {"L": hx("4A1218"), "W": hx("F4ECD0"), "d": hx("2A0A10")}
    if mood == "happy":
        f.stamp(20, 26, ["L.........L", "LLWWWWWWWLL", ".LddddddL..", "..LLLLLL..."], P)
    elif mood == "neutral":
        f.stamp(21, 27, ["L.......L", ".LWWWWWL.", "..LLLLL.."], P)
    f.px([(20, 24), (21, 23)], hx("FFC0A0"))
    return f


def hunter(mood):
    cloak = R("4A3E5A", "2E2440", "1E182C", "120E1A")
    f = Fig()
    shoulders(f, cloak)
    hood = poly([(5, 46), (6, 22), (10, 9), (17, 3), (27, 2), (35, 7), (39, 16), (40, 30), (38, 40), (30, 37), (16, 37)])
    f.paint(shade(hood, cloak, hi=1.5, shd=3))
    f.fill(ell(25, 21, 9, 11.5), cloak[3])
    # topeng: carved cream mask, shaded as a 3D object; it does not change with mood except a tilt of shadow
    mk = R("FFF6E0", "E6DCC2", "B0A488", "6E6454")
    mask = poly([(17, 13), (25, 10.5), (33, 12), (34.5, 20), (33, 27), (29, 32), (24, 32.5), (19, 28), (16.5, 21)])
    f.paint(shade(mask, mk, hi=1.5, shd=2.5))
    f.stamp(20, 18, ["LLLL", ".dd."], {"L": INK, "d": mk[3]}); f.stamp(28, 18, ["LLL", ".d."], {"L": INK, "d": mk[3]})
    f.px([(19, 16), (20, 15), (21, 15), (22, 15), (28, 15), (29, 15), (30, 16)], hx("2A1C12"))   # painted brows
    f.px([(27, 21), (27, 22), (28, 23), (27, 24)], mk[2])
    f.px([(23, 27), (24, 27), (25, 27), (26, 27)], hx("9E2B25")); f.px([(24, 28), (25, 28)], mk[2])
    glow = {"angry": hx("E04030"), "sad": hx("7AA0D0"), "happy": hx("F0C060")}.get(mood)
    if glow:
        f.px([(22, 19), (29, 19)], glow)
    if mood == "angry":
        f.px([(20, 17), (23, 18)], INK)
    return f


def faceless(mood):
    sk = SKIN["veil"]
    cloth = R("6A6480", "4A4460", "322E46", "201C30")
    f = Fig()
    shoulders(f, cloth)
    skin_head(f, sk, "narrow")
    veil = poly([(6, 44), (8, 22), (11, 9), (17, 4), (27, 3), (34, 7), (36, 12), (30, 11), (22, 12), (17, 16), (14, 26), (16, 36), (24, 40), (12, 46)])
    f.paint(shade(veil, cloth, hi=1.5, shd=3))
    # no features: only the planes where features should be catch the light
    f.px([(20, 20), (21, 20), (22, 20), (28, 20), (29, 20)], sk[2])   # brow shelf shadow
    f.px([(21, 19), (22, 19), (29, 19)], sk[0])
    f.px([(28, 24), (29, 25)], sk[2]); f.px([(27, 23)], sk[0])
    f.px([(23, 24), (22, 25)], sk[0])
    if mood == "angry":
        f.px([(x, 28) for x in range(23, 29)], sk[3])    # a seam where a mouth tries to open
    elif mood == "sad":
        f.px([(21, 22), (21, 23), (21, 25)], TEAR)
    elif mood == "happy":
        f.px([(23, 28), (24, 29), (25, 29), (26, 29), (27, 28)], sk[2])
    return f


def lutung(mood):
    fur = SKIN["fur"]
    f = Fig()
    sh = shoulders(f, R("4A3E52", "2C2236", "1C1624", "100C16"))
    f.px([(x, 44) for x in range(4, 44, 3) if (x, 44) in sh], GOLD[2])
    head = ell(23, 19, 12, 12) | poly([(12, 22), (35, 15), (37, 26), (32, 33), (20, 34)])
    f.paint(shade(head, fur, hi=1.5, shd=3))
    for (x, y) in [(13, 12), (16, 9), (20, 7), (11, 18), (12, 26)]:
        f.px([(x, y), (x - 1, y - 1)], fur[0])
    crest = poly([(15, 9), (19, 1), (25, 0), (30, 2), (33, 8), (27, 6), (21, 7)])   # the langur's pointed crown tuft
    f.paint(shade(crest, fur, hi=1, shd=1.5))
    # silver fringe: swept-back cheek whiskers and a brow fringe, the langur's pale face frame
    frm = R("B0ACBC", "84808F", "5E5A6C", "3E3A4A")
    fringe = poly([(18, 14), (22, 11), (29, 10.5), (34, 12), (36, 16), (37, 22), (39, 27), (35, 29), (33, 33), (28, 34), (22, 33),
                   (17, 32), (13, 34), (14, 28), (16, 24), (15, 19)])
    f.paint(shade(fringe, frm, hi=1, shd=2))
    for (x, y) in [(14, 31), (16, 27), (17, 22), (37, 25), (35, 20), (24, 12), (30, 12)]:
        f.px([(x, y), (x + 1, y - 1)], frm[2])
    fsk = R("B4A0A8", "8A7480", "5E4A56", "3A2C36")
    face = poly([(20, 15), (33, 14), (34, 22), (32, 28), (27, 31), (22, 28), (19.5, 22)])
    f.paint(shade(face, fsk, hi=1, shd=1.5))
    P = {"L": INK, "w": hx("5A3A28"), "I": hx("E8A830"), "h": GLINT, "s": fsk[2], "k": fsk[0], "t": TEAR}
    near, far = ["LLLL", "LIhI", ".II."], ["LLL", "IhL", ".I."]
    if mood == "happy":
        near, far = ["LLLL", "LIhI", "kkk."], ["LLL", "IhL", "kk."]
    elif mood == "angry":
        near, far = ["LLLL", "LLhL", "...."], ["LLL", "LhL", "..."]
        f.px([(21, 17), (22, 17), (23, 18), (24, 18), (29, 18), (30, 17)], INK)
    f.stamp(21, 18, near, P); f.stamp(28, 18, far, P)
    if mood == "sad":
        f.px([(22, 21), (22, 22)], TEAR); f.px([(21, 16), (22, 16), (23, 15), (29, 15), (30, 16)], INK)
    f.paint(shade(ell(28, 25, 3.5, 2.6), fsk, hi=1, shd=1))   # muzzle
    f.px([(28, 24), (30, 24)], fsk[3]); f.px([(27, 23)], fsk[0])
    m = {"happy": ["L....L", ".LWWL."], "angry": ["LWWWWL", "LLLLLL"], "sad": [".LLLL.", "L....L"]}.get(mood, [".LLLL."])
    f.stamp(25, 27, m, {"L": INK, "W": hx("F4ECD0")})
    return f


def stone(mood):
    st = SKIN["stone"]
    f = Fig()
    plinth = poly([(4, 48), (6, 38), (42, 38), (44, 48)])
    f.paint(shade(plinth, st, hi=1, shd=3))
    for x in range(6, 43, 6):
        f.px([(x, y) for y in range(40, 48)], st[2])
    head = ell(24, 21, 10.5, 12) | poly([(15, 24), (33, 22), (32, 31), (27, 36), (21, 36), (16, 31)])
    f.paint(shade(head, st, hi=1.5, shd=3))
    for (x, y) in [(17, 10), (20, 8), (24, 7), (28, 8), (31, 10), (19, 12), (23, 11), (27, 11), (30, 13)]:   # curls
        f.px([(x, y)], st[0]); f.px([(x + 1, y + 1)], st[2])
    f.paint(shade(ell(24, 6, 3, 2.6), st, hi=1, shd=1))   # ushnisha
    lidc = st[3]
    if mood == "angry":
        f.px([(19, 20), (20, 21), (21, 21), (22, 22), (28, 22), (29, 21), (30, 20)], lidc)
        f.px([(20, 22), (21, 23), (29, 23)], hx("E05A30"))
    else:
        f.px([(19, 21), (20, 22), (21, 22), (22, 21), (27, 21), (28, 22), (29, 22), (30, 21)], lidc)   # lotus-bud lids
        f.px([(19, 18), (20, 17), (21, 17), (22, 18), (28, 18), (29, 17), (30, 17)], st[2])
    f.px([(25, 22), (25, 23), (26, 25), (24, 26), (25, 26)], st[2])
    if mood == "happy":
        f.px([(22, 29), (23, 30), (24, 30), (25, 30), (26, 29)], lidc)
    elif mood == "sad":
        f.px([(22, 30), (23, 29), (24, 29), (25, 29), (26, 30)], lidc); f.px([(20, 24), (20, 25), (20, 27)], hx("8AB8D0"))
    else:
        f.px([(23, 29), (24, 29), (25, 29)], lidc)
    for (x, y) in [(15, 26), (16, 27), (15, 28), (31, 33), (32, 32), (8, 40), (9, 39), (36, 41), (37, 40), (19, 34)]:   # moss
        f.px([(x, y)], hx("6A8A4A"))
    f.px([(30, 14), (31, 15), (31, 16), (32, 17)], st[3])   # crack
    return f


def sea_queen(mood):
    sk = SKIN["laut"]
    hr = R("3A8A90", "1A5A6A", "123E4E", "0A2634")
    c = dict(skin="laut", jaw="soft", hair="cap", hair_ramp=hr, body=("velvet", R("3AA088", "1D6B62", "124A44", "0A302E")),
             eyes="hooded", iris="1A4A5A", lip="3A7A8A", hat="siger", long=False)
    f = Fig()
    drift = poly([(12, 10), (6, 14), (1, 22), (3, 30), (0, 40), (6, 44), (10, 36), (13, 28), (16, 20)])   # hair drifting as if underwater
    f.paint(shade(drift, hr, hi=1.5, shd=2.5))
    f.px([(4, 24), (3, 32), (7, 18)], hr[0])
    f.merge(human(c, mood))
    for (x, y) in [(18, 7), (21, 5), (24, 4)]:   # shells on the siger
        f.px([(x, y)], hx("FFF0F4")); f.px([(x, y + 1)], hx("D8A8B8"))
    melati_g = Fig(); melati(melati_g, x0=13, y0=18, y1=36, step=3)
    for p in melati_g.g:
        f.px([p], hx("8AD8B0"))
    return f


# Spec per portrait. Commoners get no gold; gold is royal, sacred or raksasa regalia.
PANGSI = R("4A4A62", "2C2C3E", "1E1C2C", "141220")
IKET_INDIGO = (R("4E6A9A", "2E4474", "1E2C54", "141C38"), hx("A8B8D8"))
IKET_SOGAN = (R("8A5A34", "5E3A22", "40261A", "2A1810"), hx("E0C080"))
IKET_HIDEUNG = (R("4E5E52", "2E3A32", "1E2822", "121A16"), hx("D8D0A8"))
IKET_RED = (R("B05A4A", "8A3030", "5E2024", "3E1418"), hx("E8C890"))
SPEC = {
    "hero": dict(skin="sawo", body=("pangsi", PANGSI, ("A8443A", "7A2A2C", "3E2228")), hat="iket", iket=IKET_INDIGO + (1,),
                 bg=("16262A", "22403E", "33605A")),
    "laras": dict(skin="langsat", jaw="narrow", eyes="round", hair="cap", long=True, body=("kebaya", R("4AB0A0", "2A8A7E", "1C5E58", "123E3C"), "F2E2B8", False),
                  flower=(17, 13), blush=True, lip="A04040", earring=True, bg=("142A2E", "1E4448", "2E6662")),
    "elder_m": dict(skin="sawo_old", jaw="narrow", eyes="narrow", hair_ramp=HAIR_GREY, hair="short", hat="blangkon", blangkon=IKET_SOGAN + (3,),
                    beard=True, age=True, brow_c=HAIR_GREY[2], body=("beskap", R("7A5A40", "5A3E28", "3E2A1C", "281A12")),
                    bg=("221A12", "3A2C1E", "56422C")),
    "elder_f": dict(skin="sawo_old", jaw="soft", eyes="open", hair="konde", hair_ramp=HAIR_GREY, brow_c=HAIR_GREY[3], age=True,
                    lip="864238", body=("kebaya", R("9A6A7E", "74485E", "523046", "341E30")), selendang=("7A4630", "D8B068"),
                    earring=True, teeth=False, bg=("261A24", "3E2A38", "5A3E4C")),
    "woman": dict(skin="langsat", jaw="soft", eyes="open", hair="konde", lip="9A3A3A", earring=True, blush=True,
                  body=("kebaya", R("D07A8A", "B04A62", "7E2E46", "4E1A2E"), "F2E2C8"), bg=("2A1A1E", "46282E", "663A40")),
    "woman_b": dict(skin="sawo", jaw="narrow", eyes="open", hair="cap", hat="kerudung", kerudung="7A9AC8", lip="8A3A36",
                    body=("kebaya", R("6AA07A", "3E7A5A", "28543E", "183626"), "E8D8B0", False), bg=("1A2418", "2A3A26", "40563A")),
    "man": dict(skin="sawo", jaw="square", eyes="open", hat="iket", iket=IKET_HIDEUNG + (4, False, "C04A3A"),
                body=("pangsi", R("8A6A4A", "6A4E34", "4A3424", "2E2018"), None), bg=("1C2026", "2C3440", "404C5C")),
    "farmer": dict(skin="deep", jaw="square", eyes="narrow", hat="caping", stache=True,
                   body=("pangsi", R("9A8A5A", "6A5E3A", "4A4028", "2E2818"), ("C8B888", "8A7A50", "5A4E30")), bg=("1C2214", "2C3820", "44542E")),
    "child": dict(skin="sawo", jaw="round", eyes="round", hair="short", blush=True, dy=3,
                  body=("pangsi", R("D0604A", "A6473F", "742E2C", "4A1C1E"), None), bg=("2A2014", "443420", "604A2C")),
    "smith": dict(skin="deep", jaw="square", eyes="narrow", hat="iket", iket=IKET_RED + (5, False), stache=True, thick_brow=True,
                  body=("bare", 1, False), bg=("261410", "44221A", "6A3420")),
    "guard": dict(skin="sawo", jaw="square", eyes="narrow", hat="blangkon", blangkon=(R("4A4A6A", "2E2E4A", "1E1E34", "121222"), hx("8A8AB0"), 6),
                  stache=True, body=("surjan", R("5A6A7A", "3A4A5A", "26323E", "182028")), bg=("1A1C24", "2A2E3A", "404658")),
    "royal_m": dict(skin="langsat", jaw="square", eyes="hooded", hat="kuluk", kuluk=R("4A5A9A", "2A3A6A", "1A2448", "10162E"),
                    stache=True, goatee=True, body=("beskap", R("4A5A9A", "2A3A6A", "1A2448", "10162E"), "E2B64A"),
                    bg=("181A2A", "262A44", "3A4066")),
    "queen": dict(skin="langsat", jaw="soft", eyes="hooded", iris="3A2014", hair="konde", pin=False, hat="siger", melati=True,
                  lip="B23A3A", blush=True, earring=True, body=("velvet", R("3E7A5C", "1F5440", "143A2E", "0C2620")),
                  bg=("2A1416", "4A2224", "6A3A2E")),
    "dalang": dict(skin="sawo_old", jaw="soft", eyes="narrow", hat="blangkon", blangkon=(R("5A4A3A", "3A2E24", "261E18", "18120E"), hx("C9A24A"), 8),
                   goatee=True, stache=True, age=True, body=("beskap", R("4A4A5A", "2A2A36", "1C1C26", "121218"), "C9A24A"),
                   bg=("1C1612", "302620", "4A3A2C")),
    # story leads with their own faces
    "ciung_wanara": dict(skin="langsat", jaw="narrow", eyes="round", hair="short", hat="jamang",
                         body=("velvet", R("B04A4A", "8A2A30", "5E1A22", "3A1016"), False), bg=("22161A", "3A2228", "58343A")),
    "bondowoso": dict(skin="deep", jaw="square", eyes="hooded", hair="short", hat="jamang", stache=True, thick_brow=True,
                      body=("bare", 2, True, True), bg=("1A1218", "2E1E2A", "4A2E40")),
    "dayang_sumbi": dict(skin="langsat", jaw="narrow", eyes="open", hair="konde", flower=(9, 12), lip="A03A3A", earring=True,
                         body=("kebaya", R("E0C090", "C09A60", "8A6A3E", "5A4428"), "7A3A2A", False), selendang=("3A4A7A", "C8B888"),
                         bg=("1A1E2A", "2A3044", "404A66")),
    "purbasari": dict(skin="sawo", jaw="soft", eyes="round", hair="cap", long=True, lip="9A3A3A", blush=True, flower=(16, 12),
                      body=("kebaya", R("F0D070", "D0A83A", "9A7424", "5E4614"), "F4EAD0", False), bg=("1E2414", "30381E", "4A5630")),
    "nawang_wulan": dict(skin="langsat", jaw="soft", eyes="hooded", hair="konde", pin=False, hat="jamang", lip="B04050",
                         body=("kebaya", R("E8E4F4", "B8B0D8", "8478AE", "52487A"), "F4F0FA", False), selendang=("D06A8A", "F4E0A8"),
                         earring=True, bg=("1A1A30", "2A2A4E", "44447A")),
}
CUSTOM = {"kala": (kala, ("1A0C0C", "3A1612", "6A2A16")), "semar": (semar, ("201A0E", "3A3018", "5A4A26")),
          "cepot": (cepot, ("201010", "3A1A18", "5A2A22")), "hunter": (hunter, ("140E1C", "221A30", "362A48")),
          "faceless": (faceless, ("12141A", "1E222C", "2E3442")), "lutung": (lutung, ("101A12", "1A2C1E", "2A4430")),
          "stone": (stone, ("161814", "262A22", "3A4034")), "sea_queen": (sea_queen, ("0A1A22", "123040", "1E4C5C"))}


def render(name, mood):
    if name in CUSTOM:
        fn, bg = CUSTOM[name]
        fig = fn(mood)
    else:
        c = SPEC[name]; bg = c["bg"]
        fig = human(c, mood)
    outline(fig)
    g = backdrop(*(hx(b) for b in bg))
    for (x, y), col in fig.g.items():
        g[y][x] = col
    return g


NAMES = ["hero", "semar", "cepot", "laras", "hunter", "faceless", "kala", "elder_m", "elder_f", "woman", "woman_b", "man",
         "farmer", "child", "smith", "guard", "royal_m", "queen", "sea_queen", "dalang", "lutung", "stone",
         "ciung_wanara", "bondowoso", "dayang_sumbi", "purbasari", "nawang_wulan"]


def blit(sheet, img, x0, y0, sc):
    for y, row in enumerate(img):
        for x, c in enumerate(row):
            if c and c[3]:
                for j in range(sc):
                    r = sheet[y0 + y * sc + j]
                    for i in range(sc):
                        r[x0 + x * sc + i] = c[:3] + (255,)


def main():
    os.makedirs(OUT, exist_ok=True)
    rows = []
    for n in NAMES:
        row = []
        for m in MOODS:
            img = render(n, m)
            png_write(os.path.join(OUT, "p_%s.png" % n if m == "neutral" else "p_%s_%s.png" % (n, m)), img)
            row.append(img)
        rows.append(row)
    # preview: two blocks of names, each name = neutral/happy/angry/sad at 2x, plus the neutral at 1x
    sc, cell = 2, 48 * 2 + 4
    per_col = (len(rows) + 1) // 2
    W = 2 * (4 * cell + 60) + 8
    H = per_col * cell + 8
    sheet = [[(30, 24, 22, 255)] * W for _ in range(H)]
    for i, row in enumerate(rows):
        bx = 4 + (i // per_col) * (4 * cell + 60); by = 4 + (i % per_col) * cell
        for k, img in enumerate(row):
            blit(sheet, img, bx + k * cell, by, sc)
        blit(sheet, row[0], bx + 4 * cell + 4, by + 24, 1)
    png_write(os.path.join(ROOT, "tools", "speaker_portraits_preview.png"), sheet)
    print("ok", len(NAMES), "portraits x", len(MOODS))


if __name__ == "__main__":
    main()
