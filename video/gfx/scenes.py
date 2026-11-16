"""Trailer text / graphic scenes built with pxkit. Every factory returns fn(t) -> 480x270 RGBA frame.
SCENES maps name -> (factory, default_duration_s, alpha). Durations and copy are factory parameters."""
import math

from PIL import Image, ImageDraw

from pxkit import *
from portraits import portrait

GLOW_C = (CYAN_DEEP, rgb("1B3A52"))
GLOW_R = (ROSE_LO, rgb("3A1428"))
GLOW_A = (AMBER_LO, rgb("4A3028"))
SHADOW = (EDGE, 2, 2)

SCENES = {}


def scene(name, dur, alpha=False):
    def deco(f):
        SCENES[name] = (f, dur, alpha)
        return f
    return deco


def finish(c, t, dur, fade_in=0.25, fade_out=0.3, col=NIGHT):
    """Bayer-dither in from / out to black at the clip ends (set 0 to disable)."""
    if fade_in and t < fade_in:
        c = dither_fade(c, col, 1 - t / fade_in)
    if fade_out and t > dur - fade_out:
        c = dither_fade(c, col, (t - (dur - fade_out)) / fade_out)
    return c.convert("RGB").convert("RGBA")


def runs(c, parts, cx, y, role, chars=None, anchor="c", mods=None, **kw):
    """Draw coloured runs [(str, col), ...] as one line centred on cx. chars = typewriter count over the whole line."""
    ws = [text_w(s, role) for s, _ in parts]
    total = sum(ws)
    x = cx - total // 2 if anchor == "c" else cx
    off = 0
    for (s, col), w in zip(parts, ws):
        n = None if chars is None else int(clamp(chars - off, 0, len(s)))
        if n is None or n > 0:
            text(c, s, x, y, role, col, "l", chars=n, **kw)
        x += w
        off += len(s)
    return total


def typed(t, t0, cps):
    return int(max(0.0, (t - t0)) * cps)


# ---------------------------------------------------------------- 1-4, 6, 7, 11: cards
@scene("card_written", 4.0)
def card_written(dur=4.0, l1="What is written...", l2="is remembered."):
    st = Stars(11, 70)
    em = Embers(7, 22, CYAN_RAMP, speed=(5, 12), sway=4, area=(0, 120, W, H))
    ul = smooth_path([(150, 152), (200, 156), (260, 150), (330, 155)], 10)

    def fn(t):
        c = night_bg(t, st)
        if t > 1.8:
            em.draw(c, t)
        text(c, l1, 240, 78, DISPLAY, CREAM, "c", shadow=SHADOW, chars=typed(t, 0.4, 16))
        if t >= 2.0:
            pulse = int(t * 3) % 2
            text(c, l2, 240, 126, DISPLAY, CYAN, "c", shadow=(EDGE, 2, 2), glow=GLOW_C, glow_r=2 + pulse,
                 glow_phase=int(t * 6) % 2, mod=m_dither(prog(t, 2.0, 0.6), 8))
            for i, (x, y) in enumerate(((150, 120), (330, 132), (240, 118), (372, 170), (118, 168))):
                if t > 2.5 + i * 0.12:
                    sparkle(c, x, y, t, phase=i * 0.37, period=1.2)
        return finish(c, t, dur)
    return fn


@scene("card_forgotten", 4.0)
def card_forgotten(dur=4.0, l1="What is forgotten", l2="is devoured by Batara Kala."):
    st = Stars(23, 50, dim=0.6)
    em = Embers(9, 34, EMBER_RAMP, speed=(8, 22), sway=6, area=(0, 100, W, H))
    ash = Embers(13, 40, [rgb("8E2F45"), rgb("5A1426"), rgb("3A1428"), rgb("2A1020"), rgb("1A0C18")], speed=(14, 34),
                 sway=3, area=(40, 60, 440, 250), up=False)

    def fn(t):
        c = night_bg(t, st, tint=(1.5, 0.75, 0.9))
        em.draw(c, t)
        eat = prog(t, 2.7, 1.0)
        if eat > 0:
            ash.draw(c, t - 2.7)
        e1 = m_eat(eat, 3, 0.55, 2) if eat > 0 else None
        e2 = m_eat(eat, 8, 0.55, 2) if eat > 0 else None
        text(c, l1, 240, 78, DISPLAY, CREAM, "c", shadow=(EDGE, 2, 2), chars=typed(t, 0.4, 16), mod=e1)
        if t > 1.5:
            n = typed(t, 1.5, 24)
            col = ROSE if int(t * 8) % 11 else AMBER
            text(c, l2, 240, 126, DISPLAY, ROSE, "c", shadow=(EMBER_DEEP, 2, 2), glow=GLOW_R, glow_r=2,
                 glow_phase=int(t * 5) % 2, chars=n, mod=e2)
        return finish(c, t, dur)
    return fn


@scene("card_world", 3.0)
def card_world(dur=3.0, n=49, l2="Six legends."):
    st = Stars(31, 60)
    em = Embers(5, 16, EMBER_RAMP, speed=(6, 14), sway=4, area=(0, 140, W, H))
    rest = " areas."
    wn, wr = text_w(str(n), DISPLAY), text_w(rest, DISPLAY)

    def fn(t):
        c = night_bg(t, st)
        em.draw(c, t)
        x0 = 240 - (wn + wr) // 2
        k = prog(t, 0.3, 0.8)
        v = int(n * ease_out(k))
        if t > 0.3:
            text(c, str(v), x0 + wn, 66, DISPLAY, AMBER, "r", shadow=SHADOW)
            text(c, rest, x0 + wn, 66, DISPLAY, CREAM, "l", shadow=SHADOW, mod=m_dither(prog(t, 0.3, 0.3)))
        if t > 1.2:
            text(c, l2, 240, 118, DISPLAY, CYAN, "c", shadow=SHADOW, glow=GLOW_C, glow_r=2,
                 glow_phase=int(t * 6) % 2, mod=m_wipe(prog(t, 1.2, 0.5)))
        for i in range(6):                      # six legend pips, lit in turn
            x, y = 240 + (i - 2.5) * 26, 188
            lit = t > 1.5 + i * 0.14
            diamond(c, int(x), y, 9, CYAN if lit else HAIR, CYAN_HI if lit else None)
            if lit and t < 1.5 + i * 0.14 + 0.3:
                sparkle(c, int(x), y, t, period=0.3, phase=-(1.5 + i * 0.14), size=5)
        return finish(c, t, dur)
    return fn


@scene("card_cast", 3.0)
def card_cast(dur=3.0, l1="Draw the script.", l2="Cast the spell."):
    st = Stars(41, 60)
    em = Embers(15, 26, CYAN_RAMP, speed=(8, 20), sway=5, area=(0, 100, W, H))
    wave = smooth_path([(120, 132), (160, 120), (200, 140), (250, 122), (300, 140), (350, 124)], 10)

    def fn(t):
        c = night_bg(t, st)
        em.draw(c, t)
        text(c, l1, 240, 62, DISPLAY, CREAM, "c", shadow=SHADOW, mod=m_wipe(prog(t, 0.15, 0.5)))
        ink_stroke(c, wave, ease_io(prog(t, 0.6, 0.8)), 2)
        if t > 1.5:
            text(c, l2, 240, 152, DISPLAY, CYAN, "c", shadow=SHADOW, glow=GLOW_C, glow_r=2 + int(t * 3) % 2,
                 glow_phase=int(t * 6) % 2, mod=m_dither(prog(t, 1.5, 0.35)))
            burst(c, 240, 172, prog(t, 1.5, 0.8), 22, 120)
            for i, (x, y) in enumerate(((120, 160), (362, 170), (240, 214))):
                sparkle(c, x, y, t, phase=i * 0.4, period=1.1)
        return finish(c, t, dur)
    return fn


@scene("card_free", 3.0)
def card_free(dur=3.0):
    st = Stars(51, 60)
    em = Embers(17, 30, EMBER_RAMP, speed=(8, 22), sway=5, area=(0, 120, W, H))
    segs = [("30+", " hours."), ("8", " classes."), ("10", " bosses.")]
    ws = [text_w(a + b, TITLE) for a, b in segs]
    gap = 12
    total = sum(ws) + gap * 2

    def fn(t):
        c = night_bg(t, st)
        em.draw(c, t)
        x = 240 - total // 2
        for i, (a, b) in enumerate(segs):
            t0 = 0.2 + i * 0.4
            if t > t0:
                off = ri(10 * (1 - step_ease(prog(t, t0, 0.25), 4)))
                md = m_dither(prog(t, t0, 0.25), 4)
                text(c, a, x, 62 + off, TITLE, AMBER, "l", shadow=SHADOW, mod=md)
                text(c, b, x + text_w(a, TITLE), 62 + off, TITLE, CREAM, "l", shadow=SHADOW, mod=md)
            x += ws[i] + gap
        if t > 1.5:
            off = ri(14 * (1 - step_ease(prog(t, 1.5, 0.2), 4)))
            text(c, "Free.", 240, 112 + off, HERO, CYAN, "c", shadow=SHADOW, glow=GLOW_C, glow_r=3,
                 glow_phase=int(t * 6) % 2, track=2)
            burst(c, 240, 140, prog(t, 1.5, 0.9), 26, 140)
            for i, (x, y) in enumerate(((150, 120), (336, 128), (240, 96), (190, 196), (300, 200))):
                if t > 1.7 + i * 0.1:
                    sparkle(c, x, y, t, phase=i * 0.3, period=1.0, size=4)
        return finish(c, t, dur)
    return fn


@scene("card_built_with", 3.0)
def card_built_with(dur=3.0):
    st = Stars(61, 60)
    em = Embers(19, 20, CYAN_RAMP, speed=(5, 12), sway=4, area=(0, 120, W, H))

    def fn(t):
        c = night_bg(t, st)
        em.draw(c, t)
        n = typed(t, 0.3, 22)
        runs(c, [("Built with the people", CREAM)], 240, 76, DISPLAY, chars=n, shadow=SHADOW)
        runs(c, [("who ", CREAM), ("keep the culture.", AMBER)], 240, 122, DISPLAY, chars=n - 21, shadow=SHADOW)
        if t > 1.6:
            p = prog(t, 1.6, 0.5)
            ImageDraw.Draw(c).line([(240 - ri(60 * p), 190), (240 + ri(60 * p), 190)], fill=HAIR)
            diamond(c, 240, 190, 7, CYAN, CYAN_HI)
            sparkle(c, 240, 190, t, period=1.0, size=4)
        return finish(c, t, dur)
    return fn


@scene("card_next", 2.5)
def card_next(dur=2.5):
    st = Stars(71, 70, speeds=(4, 9, 18))
    em = Embers(21, 26, CYAN_RAMP, speed=(10, 24), sway=5, area=(0, 100, W, H))

    def fn(t):
        c = night_bg(t, st)
        em.draw(c, t)
        text(c, "What's next", 240, 84, DISPLAY, CREAM, "c", shadow=SHADOW, mod=m_wipe(prog(t, 0.15, 0.5)))
        if t > 0.8:
            w = text_w("In development", LABEL) + 38
            x, y = 240 - w // 2, 150
            off = ri(8 * (1 - step_ease(prog(t, 0.8, 0.25), 4)))
            paste(c, panel(w, 24, AMBER_LO, FILL), x, y + off)
            if int(t * 2) % 2 == 0:
                ImageDraw.Draw(c).rectangle([x + 10, y + off + 9, x + 14, y + off + 13], fill=ROSE)
            else:
                ImageDraw.Draw(c).rectangle([x + 10, y + off + 9, x + 14, y + off + 13], fill=ROSE_LO)
            text(c, "In development", x + 22, y + off + 3, LABEL, AMBER, "l", mod=m_dither(prog(t, 0.9, 0.3)))
        return finish(c, t, dur)
    return fn


# ---------------------------------------------------------------- 5: aksara montage
GLYPHS = [("sunda", k) for k in SUNDA_ORDER] + [("jawa", k) for k in JAWA_ORDER]
DEFAULT_BEATS = [0.40] * 4 + [0.30] * 8 + [0.20] * 8      # seconds each glyph is on screen (sum 5.6)


@scene("aksara_montage", 8.0)
def aksara_montage(dur=8.0, beats=None, line="20 aksara. Two living scripts."):
    beats = list(beats or DEFAULT_BEATS)
    assert len(beats) == 20
    starts = [sum(beats[:i]) for i in range(20)]
    grid_t = sum(beats)
    st = Stars(81, 90, speeds=(3, 8, 20))
    em = Embers(25, 30, CYAN_RAMP, speed=(10, 26), sway=5, area=(0, 60, W, H))
    SCOL = {"sunda": CYAN, "jawa": AMBER}
    GCOL = {"sunda": GLOW_C, "jawa": GLOW_A}

    def tile_x(row_n, i):
        return 240 - (row_n * 40 - 4) // 2 + i * 40

    def fn(t):
        c = night_bg(t, st)
        em.draw(c, t)
        if t < grid_t:
            i = max(k for k in range(20) if starts[k] <= t)
            u = t - starts[i]
            script, key = GLYPHS[i]
            ch = (SUNDA if script == "sunda" else JAWA)[key]
            col = SCOL[script]
            # expanding pixel ring behind the glyph
            r = 28 + ri(38 * ease_out(prog(u, 0, min(beats[i], 0.4))))
            if u < 0.35:
                ImageDraw.Draw(c).ellipse([240 - r, 110 - r, 240 + r, 110 + r], outline=DIM_LO if u > 0.12 else HAIR)
            flash = u < 0.07
            sh = (1 if int(u * 60) % 2 else -1) if u < 0.12 else 0
            aksara(c, (ch, script), 240 + sh, 106, 104, CYAN_HI if flash else col, GCOL[script],
                   m_dither(prog(u, 0, 0.05), 4), outline=EDGE)
            text(c, key, 240, 178, TITLE, CREAM, "c", shadow=SHADOW, mod=m_dither(prog(u, 0.03, 0.06), 4))
            text(c, SCRIPT_NAME[script], 240, 212, LABEL, col, "c", mod=m_dither(prog(u, 0.05, 0.06), 4))
            text(c, f"{i + 1:02d}/20", 464, 16, LABEL, DIM, "r")
            for k in range(20):                     # progress pips
                x = 240 - 20 * 6 + k * 12 + (6 if k >= 11 else 0)
                ImageDraw.Draw(c).rectangle([x, 244, x + 7, 245], fill=(SCOL[GLYPHS[k][0]] if k <= i else HAIR))
        else:
            g = t - grid_t
            for row, (script, order, ry, lab) in enumerate((("sunda", SUNDA_ORDER, 48, "Aksara Sunda"),
                                                           ("jawa", JAWA_ORDER, 134, "Aksara Jawa"))):
                n = len(order)
                text(c, lab + f"  /  {n}", tile_x(n, 0), ry - 22, LABEL, SCOL[script], "l",
                     mod=m_wipe(prog(g, row * 0.3, 0.4)))
                for i, key in enumerate(order):
                    gi = i + (0 if row == 0 else 11)
                    a = g - gi * 0.035
                    if a < 0:
                        continue
                    x, y = tile_x(n, i), ry
                    shimmer = int((g * 1.5 - gi * 0.12)) % 6 == 0 and g > 1.0
                    hair = CYAN_HALO if (a < 0.12 or shimmer) and script == "sunda" else (AMBER_LO if (a < 0.12 or shimmer) else HAIR)
                    paste(c, panel(36, 52, hair, FILL), x, y)
                    ch = (SUNDA if script == "sunda" else JAWA)[key]
                    sz = 40
                    while sz > 16 and (aksara_mask(ch, script, sz).width > 30 or aksara_mask(ch, script, sz).height > 28):
                        sz -= 2
                    aksara(c, (ch, script), x + 18, y + 21, sz, SCOL[script], None, m_dither(prog(a, 0, 0.1), 4))
                    text(c, key, x + 18, y + 40, CAP, CREAM, "c")
            if g > 1.0:
                p = prog(g, 1.0, 0.5)
                runs(c, [("20 aksara. ", CREAM), ("Two living scripts.", CYAN)], 240, 208, TITLE, shadow=SHADOW,
                     mod=m_dither(p, 8))
        return finish(c, t, dur, fade_in=0.15)
    return fn


# ---------------------------------------------------------------- 8: quotes
QUOTES = {
    "quote_pearly": ("pearly", "Pearly", "16, high-school student, Garut",
                     "It takes me a long time to read Aksara Sunda... but it matters, so we still know our own culture."),
    "quote_nurbani": ("nurbani", "F. Nurbani", "43, school principal, SMPN 1 Cipeundeuy, Garut",
                      "With interactive media, students are far more enthusiastic."),
    "quote_munawar": ("munawar", "D. Munawar", "52, District Secretary, Malangbong, Garut",
                      "Sacred figures should not be enemies, but wise protectors. Not every problem is solved with violence."),
    "quote_yazid": ("yazid", "Yazid", "24, Javanese Literature alumnus, Universitas Indonesia",
                    "Master the base aksara first, and never treat Jawa and Sunda as the same."),
}
TEXT_X, TEXT_W = 112, 332
QUOTE_LINES = max(len(wrap("“" + q[3] + "”", SUB, TEXT_W)) for q in QUOTES.values())


def make_quote(who, dur=4.5):
    pid, name, role, quote = QUOTES[who]
    lines = wrap("“" + quote + "”", SUB, TEXT_W)
    lh = 22
    bh = 14 + 20 + 12 + len(lines) * lh + 16
    bx, bw = 24, 432
    by = 254 - bh
    st = Stars(91, 40, y_max=130)
    em = Embers(27, 18, EMBER_RAMP, speed=(5, 12), sway=4, area=(0, 130, W, H))
    frame = load("ui/frame_portrait.png")
    full = "".join(lines)
    plate_w = text_w(name, SUB) + 20

    def fn(t):
        c = dusk_bg(t, st)
        em.draw(c, t)
        # big quotation mark floating above the box
        bob = int(math.sin(t * 1.2) * 2)
        text(c, "“", 40, 28 + bob, HERO, AMBER, "l", shadow=(EDGE, 2, 2))
        off, vis = slide(t, 0.1, dur - 0.45, 0.35, 0.3, bh + 24, 6)
        if vis:
            y0 = by + off
            paste(c, panel(bw, bh, HAIR, FILL), bx, y0)
            paste(c, panel(plate_w, 22, AMBER_HI, AMBER_LO), bx + 14, y0 - 11)
            text(c, name, bx + 14 + 10, y0 - 9, SUB, EDGE, "l")
            fy = y0 + 16
            paste(c, frame, bx + 12, fy)
            paste(c, portrait(pid), bx + 16, fy + 4)
            text(c, role, TEXT_X, y0 + 14, CAP, LABEL_C, "l")
            n = typed(t, 0.7, 52)
            y = y0 + 32
            used = 0
            for ln in lines:
                k = int(clamp(n - used, 0, len(ln)))
                if k > 0:
                    text(c, ln, TEXT_X, y, SUB, TEXT, "l", chars=k)
                used += len(ln)
                y += lh
            if n >= len(full) and int(t * 2.5) % 2 == 0:   # continue mark
                ImageDraw.Draw(c).polygon([(bx + bw - 22, by + bh - 16 + off), (bx + bw - 14, by + bh - 16 + off),
                                           (bx + bw - 18, by + bh - 11 + off)], fill=AMBER)
        return finish(c, t, dur, 0.2, 0.2)
    return fn


for _n in QUOTES:
    SCENES[_n] = ((lambda n: (lambda dur=4.5: make_quote(n, dur)))(_n), 4.5, False)


# ---------------------------------------------------------------- 9: partners (kawung motif)
def kawung_emblem(size=44, fill=AMBER, line=AMBER_LO, core=CYAN_HI):
    im = Image.new("RGBA", (size, size), CLEAR)
    d = ImageDraw.Draw(im)
    h, q = size // 2, size // 4
    for box in ((1, h - q + 1, h - 1, h + q - 1), (h + 1, h - q + 1, size - 2, h + q - 1),
                (h - q + 1, 1, h + q - 1, h - 1), (h - q + 1, h + 1, h + q - 1, size - 2)):
        d.ellipse(box, fill=fill, outline=line)
    d.rectangle([h - 2, h - 2, h + 1, h + 1], fill=core)
    return im


def kawung_bg(t, col=HAIR_LO, cell=24, speed=5.0):
    """Faint drifting kawung lattice on near-black (hard pixels)."""
    c = night_bg(0)
    d = ImageDraw.Draw(c)
    o = int(t * speed) % cell
    h, q = cell // 2, cell // 4
    for ox in range(-cell, W + cell, cell):
        for oy in range(-cell, H + cell, cell):
            x, y = ox + o, oy + o
            for box in ((1, h - q + 1, h - 1, h + q - 1), (h + 1, h - q + 1, cell - 2, h + q - 1),
                        (h - q + 1, 1, h + q - 1, h - 1), (h - q + 1, h + 1, h + q - 1, cell - 2)):
                d.ellipse([x + box[0], y + box[1], x + box[2], y + box[3]], outline=col)
    return c


@scene("card_partners", 4.0)
def card_partners(dur=4.0):
    st = Stars(101, 40, dim=0.7)
    emb = kawung_emblem(44)

    def fn(t):
        c = kawung_bg(t)
        st.draw(c, t)
        # darken a centre plate so the text reads over the lattice
        paste(c, panel(400, 218, HAIR, FILL), 40, 26)
        off = ri(10 * (1 - step_ease(prog(t, 0.25, 0.3), 4)))
        if t > 0.25:
            paste(c, emb, 240 - 22, 38 - off)
            sparkle(c, 240 + 26, 40, t, period=1.0)
        text(c, "In partnership with", 240, 92, LABEL, LABEL_C, "c", mod=m_dither(prog(t, 0.6, 0.3)))
        text(c, "the Government of", 240, 108, TITLE, CREAM, "c", mod=m_wipe(prog(t, 0.8, 0.45)))
        text(c, "Malangbong District, Garut", 240, 138, TITLE, AMBER, "c", mod=m_wipe(prog(t, 1.1, 0.5)))
        p = prog(t, 1.7, 0.4)
        if p > 0:
            ImageDraw.Draw(c).line([(240 - ri(70 * p), 188), (240 + ri(70 * p), 188)], fill=HAIR)
            diamond(c, 240, 188, 5, CYAN, CYAN_HI)
        w = text_w("Classroom pilot partner: ", SUB) + text_w("SMPN 1 Cipeundeuy", SUB)
        x = 240 - w // 2
        md = m_dither(prog(t, 2.0, 0.4))
        text(c, "Classroom pilot partner: ", x, 200, SUB, LABEL_C, "l", mod=md)
        text(c, "SMPN 1 Cipeundeuy", x + text_w("Classroom pilot partner: ", SUB), 200, SUB, CYAN, "l", mod=md)
        return finish(c, t, dur)
    return fn


# ---------------------------------------------------------------- 10: numbers
NUMBERS = [(85, "", "automated tests"), (30, "", "quests, 5,000+ bilingual lines checked"),
           (85, "%+", "recognition on every aksara"), (None, "v1.0.0", "out now")]


@scene("card_numbers", 5.0)
def card_numbers(dur=5.0, numbers=None):
    nums = numbers or NUMBERS
    st = Stars(111, 50, dim=0.8)
    em = Embers(29, 20, CYAN_RAMP, speed=(6, 14), sway=4, area=(0, 100, W, H))
    tw, th, gx, gy = 218, 104, 12, 12
    x0, y0 = 240 - (2 * tw + gx) // 2, 135 - (2 * th + gy) // 2

    def fn(t):
        c = night_bg(t, st)
        em.draw(c, t)
        for i, (val, suf, lab) in enumerate(nums):
            x, y = x0 + (i % 2) * (tw + gx), y0 + (i // 2) * (th + gy)
            a = t - (0.2 + i * 0.3)
            if a < 0:
                continue
            off = ri(14 * (1 - step_ease(prog(a, 0, 0.25), 4)))
            done = a > 1.1
            hair = CYAN_HALO if (a < 1.4 or int(t * 2) % 4 == i) else HAIR
            paste(c, panel(tw, th, hair, FILL), x, y + off)
            ImageDraw.Draw(c).rectangle([x + 2, y + off + 2, x + 4, y + off + th - 3], fill=CYAN if i != 3 else AMBER)
            if val is None:
                big = suf
            else:
                big = str(int(val * ease_out(prog(a, 0.1, 1.0)))) + suf
            col = AMBER_HI if a < 1.2 and a > 0.1 and val is not None and int(a * 20) % 2 == 0 else (CYAN if i != 3 else AMBER)
            text(c, big, x + 18, y + off + 12, DISPLAY, col, "l", shadow=SHADOW, glow=GLOW_C if i != 3 else GLOW_A,
                 glow_r=2, glow_phase=int(t * 5) % 2)
            ln = wrap(lab, SUB, tw - 32)
            text_lines(c, ln, x + 18, y + off + 58, SUB, CREAM, "l", gap=-1, mod=m_dither(prog(a, 0.3, 0.4)))
        return finish(c, t, dur)
    return fn


# ---------------------------------------------------------------- 12: end card
@scene("end_card", 12.0)
def end_card(dur=12.0):
    st = Stars(121, 80, y_max=150)
    em = Embers(33, 36, EMBER_RAMP, speed=(6, 16), sway=6, area=(0, 120, W, H))
    logo = load("ui/logo.png")
    lm = logo.split()[3]
    LX, LY = 240 - logo.width // 2, 16
    names = ["Muhammad Nafis Yusa'", "Fahmi Milan Amyar", "Muhammad Fatih Zamzami"]

    def fn(t):
        c = dusk_bg(t, st)
        em.draw(c, t)
        # logo drops in with a flash, then a glint sweeps across it twice
        if t > 0.5:
            off = ri(14 * (1 - step_ease(prog(t, 0.5, 0.4), 5)))
            lg = logo.copy()
            if t < 0.62:
                lg = Image.new("RGBA", logo.size, CYAN_HI)
                lg.putalpha(lm)
            for gt in (1.4, 7.0):
                gp = prog(t, gt, 0.8)
                if 0 < gp < 1:
                    gx = ri(-20 + gp * (logo.width + 40))
                    glint = Image.new("L", logo.size, 0)
                    ImageDraw.Draw(glint).polygon([(gx, logo.height), (gx + 5, logo.height), (gx + 5 + 24, 0), (gx + 24, 0)], fill=255)
                    glint = mask_and(glint, lm)
                    lg.paste(CYAN_HI, (0, 0), glint)
            c.paste(EDGE, (LX - 1, LY - off - 1), dilate(lm, 1))
            paste(c, lg, LX, LY - off)
        if t > 1.5:
            text(c, "The Script of Time", 240, 103, SUB, CYAN, "c", outline=EDGE, glow=None, track=1,
                 mod=m_wipe(prog(t, 1.5, 0.8)))
        # left panel: play
        if t > 3.0:
            off = ri(16 * (1 - step_ease(prog(t, 3.0, 0.3), 5)))
            px_, py_, pw, ph = 24, 128, 208, 90
            paste(c, panel(pw, ph, CYAN_HALO, FILL), px_ - off, py_)
            l = px_ + 12 - off
            text(c, "Play free now", l, py_ + 10, SUB, CREAM, "l", mod=m_wipe(prog(t, 3.2, 0.5)))
            text(c, "on Windows & macOS", l, py_ + 28, SUB, CREAM, "l", mod=m_wipe(prog(t, 3.5, 0.5)))
            if t > 4.0:
                uw = text_w("aksarakala.vercel.app", SUB) + 14
                paste(c, panel(uw, 24, CYAN_HALO, WELL), l, py_ + 56)
                text(c, "aksarakala.vercel.app", l + 7, py_ + 59, SUB, CYAN, "l", mod=m_dither(prog(t, 4.0, 0.4)))
                if t < 4.8:
                    sparkle(c, l + uw, py_ + 56, t, period=0.8, phase=-4.0)
        # right panel: team
        if t > 5.0:
            off = ri(16 * (1 - step_ease(prog(t, 5.0, 0.3), 5)))
            px_, py_, pw, ph = 248, 128, 208, 90
            paste(c, panel(pw, ph, AMBER_LO, FILL), px_ + off, py_)
            l = px_ + 12 + off
            text(c, "Tim Biru Muda", l, py_ + 6, SUB, AMBER, "l", mod=m_wipe(prog(t, 5.2, 0.5)))
            text(c, "Universitas Indonesia", l, py_ + 24, CAP, LABEL_C, "l", mod=m_wipe(prog(t, 5.5, 0.4)))
            for i, n in enumerate(names):
                text(c, n, l, py_ + 36 + i * 16, LABEL, CREAM, "l", mod=m_dither(prog(t, 5.7 + i * 0.25, 0.3)))
        if t > 7.0:
            text(c, "BUDAYA GO! 2026", 240, 222, SUB, AMBER_HI, "c", outline=EDGE, track=1, mod=m_wipe(prog(t, 7.0, 0.7)))
        if t > 7.6:
            text(c, "Music: Kevin MacLeod (incompetech.com), CC BY 4.0", 240, 244, CAP, CREAM, "c", outline=EDGE,
                 mod=m_dither(prog(t, 7.6, 0.5)))
        return finish(c, t, dur, 0.5, 0.0)
    return fn


# ---------------------------------------------------------------- 13-16: overlays (alpha)
REGIONS = {
    "desa_purwa": ("Desa Purwa", "The ruwatan night", "jawa", "ꦲ"),
    "tatar_sunda": ("Tatar Sunda", "The legend of Sangkuriang", "sunda", "ᮊ"),
    "keraton_galuh": ("Keraton Galuh", "Ciung Wanara and Hariang Banga", "sunda", "ᮌ"),
    "mataram": ("Mataram", "Roro Jonggrang and Bandung Bondowoso", "jawa", "ꦫ"),
    "tanah_timur": ("Tanah Timur", "Timun Mas, Buto Ijo and the keris of Mpu Gandring", "jawa", "ꦕ"),
    "segara_kidul": ("Segara Kidul", "The legend of Nyi Roro Kidul", "jawa", "ꦭ"),
    "gua_kala": ("Gua Kala", "Batara Kala and the Murwakala", "sunda", "ᮛ"),
}


def make_lt(key, dur=5.0, region=None, line=None):
    reg, tale, script, ch = REGIONS[key]
    reg = region or reg
    tale = line or tale
    tw = max(text_w(reg, TITLE), text_w(tale, LABEL))
    pw, ph = 12 + 36 + 10 + tw + 16, 62
    px_, py_ = SAFE, 254 - ph

    def fn(t):
        c = canvas()
        off, vis = slide(t, 0.1, dur - 0.5, 0.4, 0.35, pw + SAFE + 4, 8)
        if not vis:
            return c
        L = canvas()
        paste(L, panel(pw, ph, HAIR, FILL), px_, py_)
        d = ImageDraw.Draw(L)
        d.rectangle([px_ + 2, py_ + 2, px_ + 3, py_ + ph - 3], fill=CYAN)
        # ornament: diamond frame + one base aksara
        ox, oy = px_ + 12 + 18, py_ + ph // 2
        diamond(L, ox, oy, 31, FILL, None)
        pts = [(ox, oy - 16), (ox + 16, oy), (ox, oy + 16), (ox - 16, oy), (ox, oy - 16)]
        d.line(pts, fill=CYAN_HALO)
        aksara(L, (ch, script), ox, oy, 22, CYAN, None)
        x0 = px_ + 12 + 36 + 10
        a = t - 0.45
        text(L, reg, x0, py_ + 2, TITLE, CREAM, "l", shadow=(EDGE, 1, 1), mod=m_wipe(prog(a, 0, 0.4)))
        text(L, tale, x0, py_ + 36, LABEL, AMBER, "l", mod=m_wipe(prog(a, 0.15, 0.6)))
        if 0 < t - 0.5 < 0.5:   # glint
            gx = px_ + ri(pw * prog(t, 0.5, 0.5))
            d.line([(gx, py_ + 3), (gx - 6, py_ + ph - 4)], fill=CYAN_HI)
        c.paste(L, (-off, 0), L)
        return c
    return fn


for _k in REGIONS:
    SCENES["lt_" + _k] = ((lambda k: (lambda dur=5.0, **kw: make_lt(k, dur, **kw)))(_k), 5.0, True)


@scene("tag_in_development", 4.0, True)
def tag_in_development(dur=4.0, label="IN DEVELOPMENT"):
    w = text_w(label, LABEL, 1) + 34
    x, y = 480 - SAFE - w, SAFE

    def fn(t):
        c = canvas()
        blink = int(t * 2) % 2 == 0
        paste(c, panel(w, 22, AMBER_LO if blink else HAIR, FILL), x, y)
        d = ImageDraw.Draw(c)
        d.rectangle([x + 9, y + 8, x + 13, y + 12], fill=ROSE if blink else ROSE_LO)
        if blink:
            d.point([(x + 8, y + 10), (x + 14, y + 10), (x + 11, y + 7), (x + 11, y + 13)], fill=ROSE_LO)
        text(c, label, x + 20, y + 2, LABEL, AMBER, "l", track=1)
        return c
    return fn


FEATURES = {
    "classes": "8 classes",
    "bosses": "10 legendary bosses",
    "choices": "Choices that change the ending",
    "codex": "Culture Codex: 97 entries",
    "learn": "Learn as you play",
    "ml": "Machine-learning stroke recognition",
}


def make_feature(key, dur=3.0, label=None):
    s = label or FEATURES[key]
    w = text_w(s, SUB) + 40
    h = 28

    def fn(t):
        c = canvas()
        off, vis = slide(t, 0.05, dur - 0.4, 0.3, 0.3, w + SAFE + 4, 6)
        if not vis:
            return c
        L = canvas()
        paste(L, panel(w, h, CYAN_HALO, FILL), SAFE, SAFE)
        ImageDraw.Draw(L).rectangle([SAFE + 2, SAFE + 2, SAFE + 3, SAFE + h - 3], fill=CYAN)
        diamond(L, SAFE + 17, SAFE + h // 2, 7, CYAN, CYAN_HI)
        text(L, s, SAFE + 28, SAFE + 3, SUB, CREAM, "l", mod=m_wipe(prog(t - 0.25, 0, 0.35)))
        p = prog(t, 0.3, 0.5)
        if 0 < p < 1:
            sparkle(L, SAFE + 28 + ri((w - 36) * p), SAFE + h - 4, t, period=0.3, size=2)
        c.paste(L, (-off, 0), L)
        return c
    return fn


for _k in FEATURES:
    SCENES["feature_label_" + _k] = ((lambda k: (lambda dur=3.0, **kw: make_feature(k, dur, **kw)))(_k), 3.0, True)


@scene("accuracy_meter", 5.0, True)
def accuracy_meter(dur=5.0, value=92, weak=65, full=80):
    pw, ph = 264, 62
    px_, py_ = 240 - pw // 2, 254 - ph
    bx, bw, byy = px_ + 14, pw - 28, py_ + 32
    zones = [(0, weak, ROSE, ROSE_LO), (weak, full, AMBER, AMBER_LO), (full, 100, CYAN, CYAN_DEEP)]

    def zone(v):
        return zones[0] if v < weak else zones[1] if v < full else zones[2]

    def fn(t):
        c = canvas()
        off, vis = slide(t, 0.05, dur - 0.45, 0.35, 0.3, ph + 24, 6, )
        if not vis:
            return c
        L = canvas()
        v = value * ease_io(prog(t, 0.5, 1.6))
        jit = (math.sin(t * 40) * 2 * (1 - prog(t, 0.5, 1.6))) if t < 2.1 else 0
        vv = clamp(v + jit, 0, 100)
        zc, zd = zone(vv)[2], zone(vv)[3]
        paste(L, panel(pw, ph, zc if t > 2.1 and int(t * 4) % 2 == 0 else HAIR, FILL), px_, py_)
        d = ImageDraw.Draw(L)
        text(L, f"MATCH {int(vv)}%", px_ + 14, py_ + 5, SUB, zc, "l", shadow=(EDGE, 1, 1))
        if vv >= full:
            lab = "FULL POWER"
        elif vv >= weak:
            lab = "WEAK"
        else:
            lab = "TOO FAINT"
        text(L, lab, px_ + pw - 14, py_ + 9, LABEL, zc, "r")
        # bar: dim zone backgrounds, bright fill over them
        for a, b, hi, lo in zones:
            d.rectangle([bx + ri(bw * a / 100), byy, bx + ri(bw * b / 100) - 1, byy + 9], fill=lo)
        fx = bx + ri(bw * vv / 100)
        for a, b, hi, lo in zones:
            x1, x2 = bx + ri(bw * a / 100), min(fx, bx + ri(bw * b / 100)) - 1
            if x2 >= x1:
                d.rectangle([x1, byy + 1, x2, byy + 8], fill=hi)
                d.line([(x1, byy + 1), (x2, byy + 1)], fill=CYAN_HI if hi == CYAN else AMBER_HI if hi == AMBER else rgb("F28C9A"))
        d.rectangle([bx - 1, byy - 1, bx + bw, byy + 10], outline=EDGE)
        for pct in (weak, full):
            tx = bx + ri(bw * pct / 100)
            d.line([(tx, byy - 3), (tx, byy + 12)], fill=CREAM)
        d.polygon([(fx - 3, byy - 6), (fx + 3, byy - 6), (fx, byy - 2)], fill=CREAM)
        text(L, "weak", bx + ri(bw * weak / 100) - 3, byy + 13, CAP, LABEL_C, "r")
        text(L, "full power", bx + ri(bw * full / 100) + 4, byy + 13, CAP, CYAN, "l")
        if t > 2.1 and t < 2.5:
            sparkle(L, fx, byy + 4, t, period=0.4, phase=-2.1, size=4)
        c.paste(L, (0, off), L)
        return c
    return fn
