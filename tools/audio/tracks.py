"""Theme data and arrangements for the composed music (registry: tools/gen_music.py).

Each region has one Theme; explore / dark / combat are three arrangements of it, and the special scenes have their own.
Towns, bosses, title and epilogue are finished tracks (tools/audio/sources/music.json). Every arrangement plays its
16-bar form twice: pass A is sparse and orchestral, pass B is full, with the gamelan and a second voice. ASSUMED: all melodies are original compositions in gamelan / degung idiom, not transcriptions.
"""
import numpy as np
import inst as I
from dsp import Mix, master, n_of, SR
from theory import freq
import music as M
from music import Theme, BARS, BEATS

# ------------------------------------------------------------------------------------------------------------
# THEMES (bal = 8 bars x 4 beats; lead = 8 bars x 8 half-beats)
# ------------------------------------------------------------------------------------------------------------

THEMES = {
    # Tatar Sunda: misty highlands, degung, suling + kacapi
    "sunda": Theme("sunda", "degung", 146.83, 88,
                   "3 2 3 5 | 4 3 2 1 | 2 3 5 4 | 3 2 1 - | 5 4 3 5 | 3 2 3 4 | 5' 4 3 2 | 3 2 1 -",
                   "3 - 5 - 4 3 2 - | 3 - 2 1 2 - - . | 2 3 5 5 4 . 3 - | 2 - 1 - 1 - - . | "
                   "5 - 5 4 3 - 4 5 | 5' - 5 4 3 - 2 3 | 4 5 5' - 4 - 3 2 | 3 - 2 - 1 - - -",
                   shiftB=2, endB_bal="3 2 1 -", endB_lead="3 - 2 - 1 - - -", colour="sunda"),
    # Karajaan Galuh: stately court, pelog, rebab
    "galuh": Theme("galuh", "pelog", 110.0, 76,
                   "2 3 5 6 | 5 3 2 3 | 6 5 3 5 | 3 2 1 - | 3 5 6 7 | 6 5 3 5 | 6 5 3 2 | 3 2 1 -",
                   "2 - 3 - 5 - 6 - | 5 - 3 2 3 - - . | 6 - 5 - 3 5 6 5 | 3 - 2 - 1 - - - | "
                   "3 - 5 - 6 - 7 - | 6 5 6 - 5 3 5 - | 6 - 5 3 2 3 5 3 | 2 - 1 - 1 - - -",
                   shiftB=1, endB_bal="3 2 1 -", endB_lead="2 - 3 - 2 - 1 -", colour="court"),
    # Bhumi Mataram: flooded sawah and candi, slendro, gender
    "mataram": Theme("mataram", "slendro", 174.61, 84,
                     "2 3 5 3 | 2 1 2 3 | 5 3 2 3 | 2 1 1 - | 3 5 6 5 | 3 2 3 5 | 6 5 3 2 | 3 2 1 -",
                     "5 - 3 - 2 3 5 - | 3 - 2 1 2 - 3 - | 5 - 6 - 5 3 2 3 | 2 - 1 - 1 - - . | "
                     "6 - 5 - 3 5 6 - | 5 3 2 3 5 - 3 - | 6 - 5 - 3 - 2 - | 3 - 2 - 1 - - -",
                     shiftB=1, endB_bal="3 2 1 -", endB_lead="3 - 2 - 1 - - -", colour="mataram"),
    # Tanah Timur: golden savanna and volcanic sands, bright interlocking pelog
    "timur": Theme("timur", "pelog_timur", 196.0, 112,
                   "1 1 2 3 | 5 3 2 3 | 5 6 5 3 | 2 3 2 1 | 3 5 6 7 | 6 5 3 5 | 7 6 5 3 | 2 3 1 -",
                   "3 . 3 5 . 5 6 5 | 5 3 . 2 3 . 5 - | 6 . 6 7 . 6 5 3 | 5 . 3 2 . 3 - - | "
                   "7 . 6 5 . 6 7 5 | 6 5 3 . 5 6 . 5 | 7 . 6 . 5 3 5 6 | 5 3 2 . 1 - - -",
                   shiftB=0, endB_bal="2 3 1 -", endB_lead="5 3 2 . 1 - - -", colour="timur"),
    # Segara Kidul: tides and the deep palace, slow pelog, choir + harp
    "kidul": Theme("kidul", "pelog", 116.54, 66,
                   "1 - 3 - | 5 - 4 - | 3 - 2 - | 1 - - - | 2 - 3 - | 6 - 5 - | 4 - 3 - | 2 - 1 -",
                   "5 - - - 3 - 2 - | 3 - - - - - - - | 6 - - - 5 - 4 - | 3 - 2 - 1 - - - | "
                   "2 - 3 - 5 - - - | 6 - - - 5 - 3 - | 4 - 3 - 2 - 3 - | 2 - - - 1 - - -",
                   shiftB=0, colour="kidul"),
    # Gua Kala: time itself, heavy sparse pelog
    "kala": Theme("kala", "pelog", 82.41, 72,
                  "1 . 2 . | 1 . 4 . | 1 . 2 . | 5 . 4 . | 1 . 2 . | 1 . 4 . | 6 . 5 . | 4 . 1 -",
                  "5 - - - 4 - 2 - | 1 - - - - - 2 - | 5 - 6 - 5 - 4 - | 2 - 1 - 2 - - - | "
                  "6 - - - 5 - 4 - | 2 - - - 4 - 5 - | 6 - 7 - 6 - 5 - | 4 - 2 - 1 - - -",
                  shiftB=0, colour="kala"),
}

SPECIAL = {
    "select": Theme("select", "slendro", 130.81, 80,
                    "1 . 3 . | 2 . 5 . | 3 . 2 . | 1 - 1 - | 5 . 3 . | 6 . 5 . | 3 . 2 . | 1 - - -",
                    "3 - 5 - 3 - 2 - | 5 - 6 - 5 - 3 - | 6 - 5 - 3 - 2 - | 3 - 2 - 1 - - - | "
                    "5 - 6 - 5 - 3 - | 6 - 5' - 6 - 5 - | 3 - 5 - 3 - 2 - | 3 - 2 - 1 - - -",
                    shiftB=0, colour="select"),
    "kelir": Theme("kelir", "slendro", 146.83, 72,
                   "2 . 3 . | 5 . 3 . | 2 . 1 . | 2 - 3 - | 5 . 6 . | 5 . 3 . | 2 . 3 . | 1 - - -",
                   "3 - - - 5 - 3 - | 2 - - - 1 - 2 - | 3 - 5 - 6 - 5 - | 3 - 2 - 1 - - - | "
                   "5 - - - 6 - 5 - | 3 - - - 5 - 3 - | 2 - 3 - 5 - 3 - | 2 - 1 - 1 - - -",
                   shiftB=0, colour="kelir"),
    "ruwatan": Theme("ruwatan", "pelog", 87.31, 60,
                     "1 - - - | 4 - - - | 5 - - - | 3 - 2 - | 1 - - - | 6 - - - | 5 - 4 - | 1 - - -",
                     "5 - - - - - 6 - | 5 - - - - - 3 - | 6 - - - - - 7 - | 5 - 3 - 2 - - - | "
                     "5 - - - - - 6 - | 7 - - - - - 6 - | 5 - 6 - 7 - 5 - | 3 - - - 1 - - -",
                     shiftB=0, colour="ruwatan"),
}

DRUMS = {
    "sunda": "D.tt ..T. D.t. T.tk",
    "court": "D... t.T. D.t. T..k",
    "mataram": "D.t. ..T. D.t. .tTk",
    "timur": "DtDt .tT. DtDt T.tk",
    "kidul": "D... ..T. ..t. B...",
    "kala": "B... ..t. B.D. t.tk",
}
FILLS = {
    "sunda": "DtDt tTtT DtTt dTtB",
    "court": "D.tT D.tT DtDT BtkB",
    "mataram": "D.tD tTtD DtDt TtkB",
    "timur": "DtDt DtDt tTtT dtDB",
    "kidul": "D..t ..Tt DtTt ..BB",
    "kala": "B.tB .tDt BtBt DDBB",
}


def dark_theme(region):
    base = THEMES[region]
    return Theme(base.name + "_dark", base.scale, base.root, base.bpm * 0.72, base.bal_a, base.lead_a, shiftB=0,
                 colour="dark", lead_oct=base.lead_oct)


# ------------------------------------------------------------------------------------------------------------
# ARRANGEMENTS
# ------------------------------------------------------------------------------------------------------------

LEADS = {"sunda": (I.suling, I.rebab), "court": (I.rebab, I.suling), "mataram": (I.suling, I.rebab),
         "timur": (I.suling, I.tarompet), "kidul": (I.rebab, I.suling), "kala": (I.rebab, I.suling)}


def _two_pass(th, fn, tail=3.0):
    m = Mix(2 * th.length, tail)
    for v in (0, 1):
        m.t_off = v * th.length
        fn(m, th, v)
    m.t_off = 0.0
    return m


def _drum_style(colour):
    return colour if colour in DRUMS else "sunda"


def _explore(m, th, v):
    c = th.colour
    a, b = LEADS.get(c, LEADS["sunda"])
    M.colotomy(m, th, density=0.5 + 0.2 * v, vel=0.75)
    M.pads(m, th, "strings", gain=0.6, every=2, vel=0.5, att=1.1)
    M.bass_line(m, th, [(0.0, 0, 3.0)], gain=0.45, kind="bow", vel=0.55)
    if v == 0:   # A: one solo voice over harp and strings
        M.arps(m, th, I.harp, gain=0.4, pattern=(0, 2, 4, 5), unit=1.0, octave=0, vel=0.55, rev2=0.4)
        M.lead_line(m, th, a, gain=0.95, vscale=0.75)
    else:        # B: the gamelan joins, the strings take the tune, the second voice answers
        M.arps(m, th, I.harp, gain=0.4, octave=0, vel=0.55, rev2=0.4)
        M.balungan(m, th, gain=0.34, vel=0.55, demung_gain=0.4)
        M.lead_line(m, th, I.strings, gain=0.75, vscale=0.8, rev=0.4, rev2=0.5)
        M.lead_line(m, th, a, gain=0.6, vscale=0.7, to_bar=8)
        M.lead_line(m, th, b, gain=0.7, vscale=0.7, from_bar=8)
    if c == "sunda":
        M.arps(m, th, I.kacapi, gain=0.3 + 0.15 * v, octave=0, vel=0.62)
        if v:
            M.drum_bar(m, th, "..t. .... ..t. ..T.", gain=0.28, vary=True)
    elif c == "court":
        M.gender_fig(m, th, gain=0.3 + 0.1 * v, vel=0.5, octave=0)
        if v:
            M.drum_bar(m, th, "D... .... ..T. ....", gain=0.22)
    elif c == "mataram":
        M.gender_fig(m, th, gain=0.4 + 0.15 * v, vel=0.62, octave=0)
        if v:
            M.drum_bar(m, th, "..t. .... D.t. ..T.", gain=0.24)
    elif c == "timur":
        M.drum_bar(m, th, "D.t. ..T. D.t. .tTk", gain=0.2 + 0.1 * v)
        if v:
            M.imbal_bonang(m, th, gain=0.34, vel=0.6, fast=False)
            M.arps(m, th, I.kacapi, gain=0.22, pattern=(0, 4, 2, 4), unit=0.5, octave=1, vel=0.5)
    elif c == "kidul":
        M.pads(m, th, "choir", gain=0.6 + 0.25 * v, every=2, vel=0.55, att=1.6, octave=0)
    elif c == "kala":
        M.pads(m, th, "drone", gain=0.9, every=2, vel=0.7, att=2.0, octave=0)
        for bar in range(BARS):
            for b in range(4):
                m.add(I.tick(1800 + 80 * (b % 2), 0.4), (bar * 4 + b) * th.beat, 0.35, -0.3 + 0.2 * b, 0.1, 0.3)
        if v:
            M.gender_fig(m, th, gain=0.32, vel=0.5, octave=-1, density=1)


def explore(th):
    return M.finish(_two_pass(th, _explore), th, rt=(1.6, 4.0), rms=-21.0)


def _dark(m, th, v):
    spb = th.beat
    M.pads(m, th, "drone", gain=1.0, every=4, vel=0.65, att=2.5, octave=-1, third=False)
    M.pads(m, th, "choir", gain=0.5, every=4, vel=0.45, att=2.2, octave=0)
    M.pads(m, th, "strings", gain=0.35 + 0.2 * v, every=4, vel=0.4, att=2.5, octave=-1, third=False)
    M.colotomy(m, th, density=0.5, gong_every=4, vel=0.7, kenong=False, kethuk=False)
    for bar in range(BARS):
        r = th.bar_root(bar)
        m.add(I.gender(th.f(r, 0, 140.0), 2.0 * spb, 0.5), bar * BEATS * spb + 0.1, 0.4, -0.2, 0.5, 0.5)
        if bar % 2 == 1:
            m.add(I.bell(th.f(r + 4, 1, 500.0), 3.0, 0.4), (bar * BEATS + 2.5) * spb, 0.25, 0.4, 0.4, 0.8)
        if bar % 4 == 3:
            rv = I.reverse(I.gong(th.f(1, -1, 55.0), 3.0, 0.7))
            m.add(rv, (bar * BEATS + 4) * spb - len(rv) / SR + 0.5, 0.5, 0, 0.3, 0.5)
    first, second = (I.rebab, I.suling) if v == 0 else (I.suling, I.rebab)
    M.lead_line(m, th, first, gain=0.6, vscale=0.5, oct_a=0, oct_b=0, to_bar=8, rev=0.7, rev2=0.6)
    M.lead_line(m, th, second, gain=0.45, vscale=0.45, oct_a=1, oct_b=1, from_bar=8, rev=0.7, rev2=0.7)
    if v:
        M.arps(m, th, I.harp, gain=0.3, pattern=(0, 4), unit=2.0, octave=0, vel=0.45, rev2=0.6)


def dark(region):
    th = dark_theme(region)
    return M.finish(_two_pass(th, _dark, 5.0), th, rt=(1.8, 4.8), rms=-23.0)


def _combat(m, th, v):
    ds = _drum_style(th.colour)
    M.colotomy(m, th, density=0.6, vel=0.9, kenong=True, kethuk=False)
    M.balungan(m, th, gain=0.55, vel=0.9, peking_gain=0.5, demung_gain=0.6, imbal=True)
    M.pads(m, th, "strings", gain=0.7, every=2, vel=0.7, att=0.4, bright=0.9)
    M.bass_line(m, th, [(0.0, 0, 0.5), (0.5, 0, 0.5), (1.0, 0, 0.5), (1.5, 0, 0.5), (2.0, 0, 0.5), (2.5, 2, 0.5),
                        (3.0, 0, 0.5), (3.5, 4, 0.5)], gain=0.55, octave=-2, vel=0.8)
    plain = [b for b in range(BARS) if b % 4 != 3]
    fills = [b for b in range(BARS) if b % 4 == 3]
    M.drum_bar(m, th, DRUMS[ds], gain=0.85, bars=plain)
    M.drum_bar(m, th, FILLS[ds], gain=0.9, bars=fills)
    for bar in range(0, BARS, 2 - v):
        m.add(I.bedug(0.9, 62.0, 1.0), bar * BEATS * th.beat, 0.8, 0, 0.2, 0.3)
    for bar in range(0, BARS, 4):
        m.add(I.kecer(0.9), bar * BEATS * th.beat, 0.8, 0.3, 0.3)
    if v == 0:   # A: reed and strings carry the tune
        M.lead_line(m, th, I.tarompet, gain=0.55, vscale=0.85, oct_a=th.lead_oct, oct_b=th.lead_oct, rev=0.35, rev2=0.3)
        M.lead_line(m, th, I.strings, gain=0.6, vscale=0.9, rev=0.3, rev2=0.4)
    else:        # B: fiddle on top, strings an octave up, the bonang interlocks, suling cries in the second half
        M.imbal_bonang(m, th, gain=0.4, vel=0.75, fast=True)
        M.lead_line(m, th, I.rebab, gain=0.6, vscale=0.9, oct_a=th.lead_oct, oct_b=th.lead_oct, rev=0.35, rev2=0.3)
        M.lead_line(m, th, I.strings, gain=0.6, vscale=0.9, oct_a=th.lead_oct + 1, oct_b=th.lead_oct + 1, rev=0.3, rev2=0.4)
        M.lead_line(m, th, I.suling, gain=0.35, vscale=0.7, oct_a=th.lead_oct + 1, oct_b=th.lead_oct + 1, from_bar=8)


def combat(th):
    return M.finish(_two_pass(th, _combat), th, rt=(1.0, 2.4), rms=-18.5)


def _select(m, th, v):
    spb = th.beat
    M.pads(m, th, "drone", gain=0.9, every=2, vel=0.6, att=1.6, octave=-1)
    M.pads(m, th, "strings", gain=0.4, every=2, vel=0.5, att=1.2)
    M.lead_line(m, th, I.rebab if v == 0 else I.strings, gain=0.9, vscale=0.7, oct_a=1, oct_b=1)
    M.gender_fig(m, th, gain=0.45, vel=0.55, octave=0)
    M.colotomy(m, th, density=0.8, gong_every=4, vel=0.8)
    for bar in range(BARS):
        m.add(I.kendang("dung", 0.7), bar * BEATS * spb, 0.5, -0.1, 0.2)
        m.add(I.kendang("tak", 0.5), (bar * BEATS + 2.5) * spb, 0.35, 0.2, 0.2)
    M.lead_line(m, th, I.suling, gain=0.6, vscale=0.55, oct_a=2, oct_b=2, from_bar=8 * (1 - v))
    if v:
        M.arps(m, th, I.harp, gain=0.35, pattern=(0, 2, 4, 5), unit=1.0, octave=0, vel=0.5, rev2=0.4)


def _kelir(m, th, v):
    spb = th.beat
    M.gender_fig(m, th, gain=0.7, vel=0.6, octave=0, density=1)
    M.pads(m, th, "drone", gain=0.8, every=2, vel=0.55, att=1.8, octave=-1)
    M.colotomy(m, th, density=0.7, gong_every=4, vel=0.8, kethuk=False)
    M.lead_line(m, th, I.rebab, gain=0.75, vscale=0.62, oct_a=1, oct_b=1)
    M.lead_line(m, th, I.suling, gain=0.55, vscale=0.55, oct_a=2, oct_b=2, from_bar=8)
    if v:
        M.pads(m, th, "strings", gain=0.45, every=2, vel=0.5, att=1.4)
        M.arps(m, th, I.kacapi, gain=0.3, pattern=(0, 4, 2, 4), unit=1.0, octave=0, vel=0.5)
    for bar in range(BARS):   # kepyak: the dalang's wooden clacks
        for b in (0.0, 1.5, 2.0, 3.5):
            m.add(I.kethuk(430 + 40 * ((bar + int(b * 2)) % 3), 0.8), (bar * BEATS + b) * spb, 0.5, 0.0, 0.15)
        if bar % 2 == 0:
            m.add(I.kendang("dung", 0.6), (bar * BEATS) * spb, 0.4, -0.2, 0.2)


def _ruwatan(m, th, v):
    spb = th.beat
    M.pads(m, th, "choir", gain=1.1, every=2, vel=0.75, att=1.8, octave=0)
    M.pads(m, th, "choir", gain=0.8, every=2, vel=0.7, att=1.8, octave=-1)
    M.pads(m, th, "strings", gain=0.7, every=2, vel=0.6, att=1.6, octave=-1)
    M.pads(m, th, "strings", gain=0.5, every=2, vel=0.6, att=1.6, octave=1)
    M.lead_line(m, th, I.rebab, gain=0.9, vscale=0.75, oct_a=1, oct_b=2)
    if v:
        M.lead_line(m, th, I.strings, gain=0.7, vscale=0.8, oct_a=1, oct_b=1, rev2=0.6)
        M.arps(m, th, I.harp, gain=0.4, octave=0, vel=0.55, rev2=0.5)
    M.colotomy(m, th, density=1.0, gong_every=2, vel=0.95, kethuk=False)
    for bar in range(0, BARS, 2):
        m.add(I.bell(th.f(th.bar_root(bar) + 4, 1, 500.0), 5.0, 0.7), bar * BEATS * spb + 0.5, 0.4, 0.3, 0.4, 0.9)
        m.add(I.bedug(0.9, 55.0, 1.4), bar * BEATS * spb, 0.7, 0, 0.2, 0.5)
    M.bass_line(m, th, [(0.0, 0, 4.0)], gain=0.6, octave=-2, kind="bow", vel=0.85)


def special(name):
    fn, rt, rms = {"select": (_select, (1.5, 3.8), -21.0), "kelir": (_kelir, (1.6, 4.0), -21.0),
                   "ruwatan": (_ruwatan, (2.2, 5.2), -20.0)}[name]
    th = SPECIAL[name]
    return M.finish(_two_pass(th, fn, 5.0), th, rt=rt, rms=rms)
