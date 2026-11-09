"""Theme data and arrangements for every music track in the game (see tools/gen_audio.py for the registry).

Each region has one Theme; explore / dark / combat / boss are four arrangements of it. Towns and special scenes have
their own themes. ASSUMED: all melodies are original compositions in gamelan / degung idiom, not transcriptions.
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

TOWNS = {
    "home": Theme("home", "degung", 196.0, 96,
                  "3 5 3 2 | 1 2 3 5 | 4 3 2 3 | 5 3 2 1 | 3 5 5' 4 | 3 4 5 3 | 2 3 5 4 | 3 2 1 -",
                  "5 . 3 5 4 . 3 2 | 3 - 5 - 4 3 2 - | 3 . 2 3 5 . 4 3 | 2 - 3 2 1 - - . | "
                  "5 . 5' 4 3 . 4 5 | 5' - 4 - 3 - 2 - | 3 5 6 5 4 3 2 3 | 3 - 2 - 1 - - -",
                  shiftB=0, colour="sunda"),
    "kampung": Theme("kampung", "madenda", 146.83, 90,
                     "2 3 5 3 | 2 1 2 3 | 5 4 3 2 | 1 - 2 - | 3 5 4 3 | 2 3 5 4 | 3 2 3 2 | 1 - - -",
                     "3 . 5 . 3 2 1 . | 2 . 3 5 3 - - . | 5 - 4 3 2 . 3 5 | 3 - 2 - 1 - - . | "
                     "5 . 5 4 3 . 2 3 | 5 - 6 - 5 3 2 - | 3 2 3 5 4 3 2 1 | 2 - 1 - 1 - - -",
                     shiftB=0, colour="sunda"),
    "galuh": Theme("galuh_town", "pelog", 98.0, 108,
                   "3 5 6 5 | 3 2 3 5 | 6 7 6 5 | 3 2 1 - | 5 6 5 3 | 2 3 5 6 | 5 3 2 3 | 2 3 1 -",
                   "3 . 5 6 5 . 3 2 | 3 5 3 . 2 3 . . | 6 . 7 6 5 . 6 5 | 3 . 2 . 1 - - . | "
                   "5 6 5 . 3 5 6 7 | 6 . 5 . 3 . 2 3 | 5 . 3 2 3 5 6 5 | 3 2 3 . 1 - - -",
                   shiftB=0, colour="court"),
    "mataram": Theme("mataram_town", "slendro", 130.81, 100,
                     "1 2 3 2 | 1 2 3 5 | 3 2 1 2 | 3 5 3 - | 5 6 5 3 | 2 3 5 3 | 2 1 2 3 | 2 1 1 -",
                     "3 . 5 3 2 . 3 5 | 6 - 5 3 2 3 5 . | 3 2 1 . 2 3 5 3 | 5 - 3 - 2 - - . | "
                     "6 . 5 3 5 6 . 5 | 3 5 3 2 3 . 5 . | 6 5 3 . 2 3 5 6 | 5 3 2 . 1 - - -",
                     shiftB=0, colour="mataram"),
    "kidul": Theme("kidul_town", "madenda", 116.54, 88,
                   "1 3 5 3 | 2 3 5 4 | 3 2 1 2 | 3 - 2 - | 5 4 3 5 | 4 3 2 3 | 5 3 2 1 | 2 - 1 -",
                   "5 . 3 . 5 6 5 . | 3 5 4 3 2 . 3 . | 1 . 2 3 5 . 3 2 | 3 - 2 - 1 - - . | "
                   "5 6 5 . 3 . 4 5 | 6 - 5 3 5 - 3 . | 4 3 2 . 3 5 4 3 | 2 - 1 - 1 - - -",
                   shiftB=0, colour="sunda"),
}

SPECIAL = {
    "title": Theme("title", "pelog", 98.0, 66,
                   "1 - 3 - | 5 - 6 - | 5 - 3 - | 2 - 1 - | 3 - 5 - | 6 - 7 - | 6 - 5 - | 3 - 1 -",
                   "5 - - - 6 - 5 - | 3 - - - 2 - 3 - | 5 - - - 6 - 7 - | 5 - 3 - 2 - 1 - | "
                   "7 - - - 6 - 5 - | 6 - - - 5 - 3 - | 7 - 6 - 5 - 6 - | 5 - 3 - 1 - - -",
                   shiftB=0, colour="title"),
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
    "epilogue": Theme("epilogue", "slendro", 146.83, 68,
                      "1 - 3 - | 5 - 3 - | 2 - 3 - | 1 - - - | 3 - 5 - | 6 - 5 - | 3 - 2 - | 1 - - -",
                      "3 - - - 5 - 6 - | 5 - - - 3 - 2 - | 3 - - - 5 - 6 - | 5 - 3 - 2 - 1 - | "
                      "6 - - - 5' - 6 - | 5 - - - 3 - 5 - | 6 - 5 - 3 - 2 - | 3 - 2 - 1 - - -",
                      shiftB=0, colour="epilogue"),
}

# Boss material: heavy ostinato bal (bar roots drive the chords) and a riff lead, per region.
BOSS = {
    "sunda": dict(scale="degung", root=146.83, bpm=132, shiftB=1,
                  bal="1 . 1 2 | 1 . 4 . | 1 . 1 2 | 5 . 4 2 | 1 . 1 2 | 1 . 4 . | 2 . 4 5 | 4 . 1 -",
                  lead="1 . 1 . 2 . 3 . | 5 . 3 . 2 . 1 . | 1 . 1 . 2 . 3 . | 5 . 5' . 4 . 2 . | "
                       "3 . 3 . 5 . 5' . | 4 . 3 . 2 . 3 . | 5 . 5' . 4 . 3 . | 2 . 4 . 1 - - -"),
    "galuh": dict(scale="pelog", root=110.0, bpm=126, shiftB=1,
                  bal="1 . 2 . | 1 . 4 . | 1 . 2 . | 5 . 4 . | 6 . 5 . | 4 . 5 . | 2 . 4 . | 3 2 1 -",
                  lead="5 . 5 . 6 . 5 . | 3 . 2 . 3 . - . | 5 . 5 . 6 . 7 . | 6 . 5 . 3 . 2 . | "
                       "6 . 6 . 7 . 6 . | 5 . 3 . 5 . - . | 7 . 6 . 5 . 3 . | 2 . 3 . 1 - - -"),
    "mataram": dict(scale="slendro", root=130.81, bpm=128, shiftB=1,
                    bal="1 . 2 3 | 5 . 3 2 | 1 . 2 3 | 5 . 6 5 | 3 . 5 6 | 5 . 3 2 | 3 . 2 1 | 2 . 1 -",
                    lead="5 . 5 6 5 . 3 . | 2 . 3 5 3 . 2 . | 5 . 5 6 5 . 3 . | 6 . 5 3 5 . - . | "
                         "6 . 6 5 6 . 5 . | 3 . 5 6 5 . 3 . | 2 . 3 5 6 . 5 . | 3 . 2 . 1 - - -"),
    "timur": dict(scale="pelog_timur", root=196.0, bpm=144, shiftB=1,
                  bal="1 1 1 2 | 1 1 4 5 | 1 1 1 2 | 5 4 2 1 | 6 6 6 7 | 5 5 4 5 | 7 6 5 4 | 2 3 1 -",
                  lead="1 . 3 . 5 . 3 . | 1 . 3 . 6 . 5 . | 1 . 3 . 5 . 3 . | 7 . 6 . 5 . 3 . | "
                       "6 . 7 . 6 . 5 . | 3 . 5 . 6 . 7 . | 6 . 5 . 4 . 3 . | 2 . 3 . 1 - - -"),
    "kidul": dict(scale="pelog", root=116.54, bpm=108, shiftB=2,
                  bal="1 . 3 . | 4 . 5 . | 1 . 3 . | 6 . 5 . | 2 . 4 . | 5 . 6 . | 4 . 3 . | 2 . 1 -",
                  lead="5 - 6 - 5 . 3 . | 4 - 3 - 2 . 3 . | 5 - 6 - 7 . 6 . | 5 - 3 - 4 . 5 . | "
                       "6 - 7 - 6 . 5 . | 3 - 4 - 5 . 3 . | 4 . 3 . 2 . 3 . | 2 - 1 - 1 - - -"),
    "kala": dict(scale="pelog", root=82.41, bpm=120, shiftB=1,
                 bal="1 1 . 1 | 2 2 . 2 | 1 1 . 1 | 4 4 . 5 | 6 6 . 6 | 5 5 . 5 | 4 4 . 2 | 1 1 . 1",
                 lead="1 . 2 . 1 . 4 . | 5 . 4 . 2 . 1 . | 1 . 2 . 1 . 4 . | 5 . 6 . 5 . 4 . | "
                      "6 . 7 . 6 . 5 . | 4 . 5 . 6 . 4 . | 7 . 6 . 5 . 4 . | 2 . 1 . 1 - - -"),
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


def boss_theme(region, intense=False, name=None):
    d = BOSS[region]
    bpm = d["bpm"] * (1.12 if intense else 1.0)
    return Theme(name or region + "_boss", d["scale"], d["root"], bpm, d["bal"], d["lead"], shiftB=d["shiftB"],
                 endB_bal="2 . 1 -", endB_lead="2 . 3 . 1 - - -", colour="boss", lead_oct=1)


def dark_theme(region):
    base = THEMES[region]
    t = Theme(base.name + "_dark", base.scale, base.root, base.bpm * 0.72, base.bal_a, base.lead_a, shiftB=0,
              colour="dark", lead_oct=base.lead_oct)
    return t


def sync_theme(region):
    return THEMES[region]


# ------------------------------------------------------------------------------------------------------------
# ARRANGEMENTS
# ------------------------------------------------------------------------------------------------------------

def _drum_style(colour):
    return colour if colour in DRUMS else {"mataram": "mataram"}.get(colour, "sunda")


def explore(th):
    m = Mix(th.length)
    c = th.colour
    M.colotomy(m, th, density=0.7, vel=0.75)
    M.balungan(m, th, gain=0.38, vel=0.55, demung_gain=0.42)
    M.pads(m, th, "strings", gain=0.55, every=2, vel=0.5, att=1.1)
    M.bass_line(m, th, [(0.0, 0, 3.0)], gain=0.45, kind="bow", vel=0.55)
    if c == "sunda":
        M.arps(m, th, I.kacapi, gain=0.5, octave=0, vel=0.62, pluck=0.28)
        M.lead_line(m, th, I.suling, gain=1.0, vscale=0.75)
        M.drum_bar(m, th, "..t. .... ..t. ..T.", gain=0.28, vary=True)
    elif c == "court":
        M.lead_line(m, th, I.rebab, gain=0.9, oct_a=1, oct_b=1, vscale=0.7, vib=1.0)
        M.gender_fig(m, th, gain=0.4, vel=0.5, octave=0)
        M.arps(m, th, I.harp, gain=0.3, pattern=(0, 2, 4, 5), unit=1.0, octave=1, vel=0.5)
        M.drum_bar(m, th, "D... .... ..T. ....", gain=0.22)
    elif c == "mataram":
        M.gender_fig(m, th, gain=0.55, vel=0.62, octave=0)
        M.lead_line(m, th, I.suling, gain=0.9, to_bar=8, vscale=0.72)
        M.lead_line(m, th, I.rebab, gain=0.8, from_bar=8, vscale=0.68)
        M.drum_bar(m, th, "..t. .... D.t. ..T.", gain=0.24)
    elif c == "timur":
        M.imbal_bonang(m, th, gain=0.34, vel=0.6, fast=False)
        M.lead_line(m, th, I.suling, gain=0.95, vscale=0.75, breath=1.2)
        M.drum_bar(m, th, "D.t. ..T. D.t. .tTk", gain=0.3)
        M.arps(m, th, I.kacapi, gain=0.22, pattern=(0, 4, 2, 4), unit=0.5, octave=1, vel=0.5)
    elif c == "kidul":
        M.pads(m, th, "choir", gain=0.85, every=2, vel=0.55, att=1.6, octave=0)
        M.arps(m, th, I.harp, gain=0.5, pattern=(0, 2, 4, 5, 4, 2, 0, 2), unit=0.5, octave=0, vel=0.55, rev2=0.5)
        M.lead_line(m, th, I.rebab, gain=0.75, vscale=0.62, vib=1.3, oct_a=1, oct_b=1)
        M.lead_line(m, th, I.suling, gain=0.5, vscale=0.5, oct_a=2, oct_b=2, from_bar=8, breath=1.5)
    elif c == "kala":
        M.pads(m, th, "drone", gain=0.9, every=2, vel=0.7, att=2.0, octave=0)
        M.lead_line(m, th, I.rebab, gain=0.75, vscale=0.6, vib=1.5, oct_a=1, oct_b=1)
        for bar in range(BARS):
            for b in range(4):
                m.add(I.tick(1800 + 80 * (b % 2), 0.4), (bar * 4 + b) * th.beat, 0.35, -0.3 + 0.2 * b, 0.1, 0.3)
        M.gender_fig(m, th, gain=0.32, vel=0.5, octave=-1, density=1)
    return M.finish(m, th, rt=(1.6, 4.0), rms=-21.0)


def dark(region):
    th = dark_theme(region)
    m = Mix(th.length, tail=5.0)
    spb = th.beat
    M.pads(m, th, "drone", gain=1.0, every=4, vel=0.65, att=2.5, octave=-1, third=False)
    M.pads(m, th, "choir", gain=0.5, every=4, vel=0.45, att=2.2, octave=0)
    M.colotomy(m, th, density=0.5, gong_every=4, vel=0.7, kenong=False, kethuk=False)
    for bar in range(BARS):
        r = th.bar_root(bar)
        m.add(I.gender(th.f(r, 0, 140.0), 2.0 * spb, 0.5), bar * BEATS * spb + 0.1, 0.4, -0.2, 0.5, 0.5)
        if bar % 2 == 1:
            m.add(I.bell(th.f(r + 4, 1, 500.0), 3.0, 0.4), (bar * BEATS + 2.5) * spb, 0.25, 0.4, 0.4, 0.8)
        if bar % 4 == 3:
            rv = I.reverse(I.gong(th.f(1, -1, 55.0), 3.0, 0.7))
            m.add(rv, (bar * BEATS + 4) * spb - len(rv) / SR + 0.5, 0.5, 0, 0.3, 0.5)
    M.lead_line(m, th, I.rebab if th.colour != "x" else I.suling, gain=0.6, vscale=0.5, vib=1.6,
                oct_a=0, oct_b=0, from_bar=0, to_bar=8, rev=0.7, rev2=0.6)
    M.lead_line(m, th, I.suling, gain=0.45, vscale=0.45, oct_a=1, oct_b=1, from_bar=8, breath=1.6, rev=0.7, rev2=0.7)
    return M.finish(m, th, rt=(1.8, 4.8), rms=-23.0)


def combat(th):
    m = Mix(th.length)
    c = th.colour
    ds = _drum_style(c)
    M.colotomy(m, th, density=0.6, vel=0.9, kenong=True, kethuk=False)
    M.balungan(m, th, gain=0.62, vel=0.9, peking_gain=0.55, demung_gain=0.6, imbal=True)
    M.imbal_bonang(m, th, gain=0.4, vel=0.75, fast=True)
    M.pads(m, th, "strings", gain=0.6, every=2, vel=0.7, att=0.4, bright=0.9)
    M.bass_line(m, th, [(0.0, 0, 0.5), (0.5, 0, 0.5), (1.0, 0, 0.5), (1.5, 0, 0.5), (2.0, 0, 0.5), (2.5, 2, 0.5),
                        (3.0, 0, 0.5), (3.5, 4, 0.5)], gain=0.55, octave=-2, vel=0.8)
    plain = [b for b in range(BARS) if b % 4 != 3]
    fills = [b for b in range(BARS) if b % 4 == 3]
    M.drum_bar(m, th, DRUMS[ds], gain=0.85, bars=plain)
    M.drum_bar(m, th, FILLS[ds], gain=0.9, bars=fills)
    for bar in range(0, BARS, 2):
        m.add(I.bedug(0.9, 62.0, 1.0), bar * BEATS * th.beat, 0.8, 0, 0.2, 0.3)
    M.lead_line(m, th, I.tarompet, gain=0.55, vscale=0.85, oct_a=th.lead_oct, oct_b=th.lead_oct, rev=0.35, rev2=0.3)
    M.lead_line(m, th, I.suling, gain=0.35, vscale=0.7, oct_a=th.lead_oct + 1, oct_b=th.lead_oct + 1, from_bar=8,
                breath=1.4)
    for bar in range(0, BARS, 4):
        m.add(I.kecer(0.9), bar * BEATS * th.beat, 0.8, 0.3, 0.3)
    return M.finish(m, th, rt=(1.0, 2.4), rms=-18.5)


def _boss_layers(m, th, region, variant):
    spb = th.beat
    ds = {"sunda": "sunda", "galuh": "court", "mataram": "mataram", "timur": "timur", "kidul": "kidul", "kala": "kala"}[region]
    M.colotomy(m, th, density=0.9, gong_every=2, vel=1.0, kenong=True, kethuk=False)
    M.balungan(m, th, gain=0.7, vel=1.0, peking_gain=0.6, demung_gain=0.7, imbal=True)
    M.imbal_bonang(m, th, gain=0.45, vel=0.85, fast=True)
    M.pads(m, th, "choir", gain=0.9 if variant == 0 else 1.1, every=1, vel=0.7, att=0.35, octave=0, third=True)
    M.pads(m, th, "strings", gain=0.6, every=1, vel=0.8, att=0.2, octave=-1, bright=1.0)
    M.bass_line(m, th, [(0.0, 0, 0.5), (0.5, 0, 0.25), (1.0, 0, 0.5), (1.5, 0, 0.5), (2.0, 0, 0.5), (2.5, 0, 0.25),
                        (3.0, 1, 0.5), (3.5, 0, 0.5)], gain=0.7, octave=-2, vel=0.95)
    M.bass_line(m, th, [(0.0, 0, 4.0)], gain=0.5, octave=-2, kind="bow", vel=0.9)
    plain = [b for b in range(BARS) if b % 4 != 3]
    fills = [b for b in range(BARS) if b % 4 == 3]
    M.drum_bar(m, th, DRUMS[ds], gain=0.95, bars=plain)
    M.drum_bar(m, th, FILLS[ds], gain=1.0, bars=fills)
    for bar in range(BARS):
        m.add(I.bedug(1.0, 58.0, 1.1), bar * BEATS * spb, 0.9, 0, 0.2, 0.4)
        m.add(I.bedug(0.7, 70.0, 0.7), (bar * BEATS + 2.5) * spb, 0.6, 0, 0.2, 0.3)
    if variant == 0:   # first pass: reed leads, fiddle answers in the second half
        M.lead_line(m, th, I.tarompet, gain=0.7, vscale=0.95, oct_a=1, oct_b=1, rev=0.3, rev2=0.3)
        M.lead_line(m, th, I.rebab, gain=0.45, vscale=0.9, oct_a=2, oct_b=2, from_bar=8, vib=1.4)
    else:              # second pass, a whole tone higher: fiddle takes the tune, reed doubles above, suling cries on top
        M.lead_line(m, th, I.rebab, gain=0.75, vscale=0.95, oct_a=1, oct_b=1, vib=1.5)
        M.lead_line(m, th, I.tarompet, gain=0.6, vscale=0.95, oct_a=2, oct_b=2, rev=0.3, rev2=0.3)
        M.lead_line(m, th, I.suling, gain=0.4, vscale=0.9, oct_a=2, oct_b=2, from_bar=8, breath=1.6)
    for bar in range(0, BARS, 4):
        m.add(I.kecer(1.0), bar * BEATS * spb, 0.9, 0.3, 0.3)
        m.add(I.sub_boom(th.f(1, -3, 38.0), 2.8, 1.0), bar * BEATS * spb, 0.7, 0, 0, 0)
    if region == "kala":
        for bar in range(BARS):
            for b in range(8):
                m.add(I.tick(2000, 0.5), (bar * 4 + b * 0.5) * spb, 0.2, 0.3 * (-1) ** b, 0.1, 0.2)


def boss(region, intense=False):
    """32 bars: the theme, then the same theme a whole tone higher with the voices swapped (lift, then drop on loop)."""
    a = boss_theme(region, intense)
    b = boss_theme(region, intense)
    b.root = a.root * 2 ** (200 / 1200.0)
    m = Mix(a.length * 2)
    m.t_off = 0.0
    _boss_layers(m, a, region, 0)
    m.t_off = a.length
    _boss_layers(m, b, region, 1)
    return M.finish(m, a, rt=(1.1, 2.6), rms=-17.5)


def town(th):
    m = Mix(th.length)
    c = th.colour
    M.colotomy(m, th, density=0.55, vel=0.7, gong_every=4)
    M.balungan(m, th, gain=0.4, vel=0.6, peking_gain=0.3, demung_gain=0.4)
    M.pads(m, th, "strings", gain=0.4, every=2, vel=0.45, att=1.0, bright=0.8)
    M.bass_line(m, th, [(0.0, 0, 0.75), (1.5, 0, 0.5), (2.0, 2, 0.75), (3.0, 0, 0.5)], gain=0.4, octave=-2, vel=0.7)
    M.angklung_part(m, th, gain=0.6 if c != "court" else 0.35, vel=0.6, octave=1)
    M.arps(m, th, I.kacapi, gain=0.42, octave=0, vel=0.6, pluck=0.25)
    M.gender_fig(m, th, gain=0.32, vel=0.5, octave=0)
    lead_fn = I.suling if c in ("sunda", "mataram") else I.rebab
    M.lead_line(m, th, lead_fn, gain=0.95, vscale=0.75, oct_a=th.lead_oct, oct_b=th.lead_oct + 1)
    M.drum_bar(m, th, "D... ..t. .T.. .t.k", gain=0.35)
    for bar in range(0, BARS):
        m.add(I.kecer(0.5), (bar * BEATS + 1.5) * th.beat, 0.25, 0.3, 0.3)
    return M.finish(m, th, rt=(1.2, 2.8), rms=-20.0)


def special(name):
    th = SPECIAL[name]
    m = Mix(th.length, tail=5.0)
    spb = th.beat
    if name == "title":
        M.pads(m, th, "choir", gain=1.0, every=2, vel=0.6, att=2.0, octave=0)
        M.pads(m, th, "strings", gain=0.6, every=2, vel=0.55, att=1.5, octave=-1)
        M.arps(m, th, I.gender, gain=0.55, pattern=(0, 2, 4, 2, 5, 4, 2, 4), unit=0.5, octave=0, vel=0.55, rev2=0.5)
        M.lead_line(m, th, I.suling, gain=1.0, vscale=0.7, oct_a=1, oct_b=1, vib=1.2, rev=0.6, rev2=0.6)
        M.lead_line(m, th, I.rebab, gain=0.6, vscale=0.6, oct_a=0, oct_b=0, from_bar=8, vib=1.3)
        M.colotomy(m, th, density=0.9, gong_every=4, vel=0.85, kethuk=False)
        for bar in range(0, BARS, 4):
            m.add(I.bell(th.f(5, 1, 500.0), 4.0, 0.6), (bar * BEATS + 2) * spb, 0.4, 0.3, 0.4, 0.8)
        for bar in range(BARS):   # the clock under the script: one faint tick every bar
            m.add(I.tick(1500, 0.3), bar * BEATS * spb, 0.12, 0.0, 0.2, 0.5)
        M.bass_line(m, th, [(0.0, 0, 4.0)], gain=0.55, octave=-2, kind="bow", vel=0.7)
        return M.finish(m, th, rt=(1.9, 4.8), rms=-21.0)
    if name == "select":
        M.pads(m, th, "drone", gain=0.9, every=2, vel=0.6, att=1.6, octave=-1)
        M.lead_line(m, th, I.rebab, gain=0.9, vscale=0.7, oct_a=1, oct_b=1, vib=1.2)
        M.gender_fig(m, th, gain=0.45, vel=0.55, octave=0)
        M.colotomy(m, th, density=0.8, gong_every=4, vel=0.8)
        for bar in range(BARS):
            m.add(I.kendang("dung", 0.7), bar * BEATS * spb, 0.5, -0.1, 0.2)
            m.add(I.kendang("tak", 0.5), (bar * BEATS + 2.5) * spb, 0.35, 0.2, 0.2)
        M.lead_line(m, th, I.suling, gain=0.6, vscale=0.55, oct_a=2, oct_b=2, from_bar=8, breath=1.4)
        return M.finish(m, th, rt=(1.5, 3.8), rms=-21.0)
    if name == "kelir":
        M.gender_fig(m, th, gain=0.7, vel=0.6, octave=0, density=1)
        M.pads(m, th, "drone", gain=0.8, every=2, vel=0.55, att=1.8, octave=-1)
        M.colotomy(m, th, density=0.7, gong_every=4, vel=0.8, kethuk=False)
        M.lead_line(m, th, I.rebab, gain=0.75, vscale=0.62, oct_a=1, oct_b=1, vib=1.4)
        M.lead_line(m, th, I.suling, gain=0.55, vscale=0.55, oct_a=2, oct_b=2, from_bar=8, breath=1.6)
        for bar in range(BARS):   # kepyak: the dalang's wooden clacks
            for b in (0.0, 1.5, 2.0, 3.5):
                m.add(I.kethuk(430 + 40 * ((bar + int(b * 2)) % 3), 0.8), (bar * BEATS + b) * spb, 0.5, 0.0, 0.15)
            if bar % 2 == 0:
                m.add(I.kendang("dung", 0.6), (bar * BEATS) * spb, 0.4, -0.2, 0.2)
        return M.finish(m, th, rt=(1.6, 4.0), rms=-21.0)
    if name == "ruwatan":
        M.pads(m, th, "choir", gain=1.1, every=2, vel=0.75, att=1.8, octave=0)
        M.pads(m, th, "choir", gain=0.8, every=2, vel=0.7, att=1.8, octave=-1)
        M.pads(m, th, "strings", gain=0.5, every=2, vel=0.6, att=1.6, octave=1, bright=1.0)
        M.lead_line(m, th, I.rebab, gain=0.9, vscale=0.75, oct_a=1, oct_b=2, vib=1.4)
        M.colotomy(m, th, density=1.0, gong_every=2, vel=0.95, kethuk=False)
        for bar in range(0, BARS, 2):
            m.add(I.bell(th.f(th.bar_root(bar) + 4, 1, 500.0), 5.0, 0.7), bar * BEATS * spb + 0.5, 0.4, 0.3, 0.4, 0.9)
            m.add(I.bedug(0.9, 55.0, 1.4), bar * BEATS * spb, 0.7, 0, 0.2, 0.5)
        M.bass_line(m, th, [(0.0, 0, 4.0)], gain=0.6, octave=-2, kind="bow", vel=0.85)
        return M.finish(m, th, rt=(2.2, 5.2), rms=-20.0)
    if name == "epilogue":
        M.pads(m, th, "strings", gain=0.8, every=2, vel=0.6, att=1.4, octave=-1, bright=0.9)
        M.pads(m, th, "choir", gain=0.6, every=2, vel=0.5, att=1.8, octave=0)
        M.arps(m, th, I.harp, gain=0.6, pattern=(0, 2, 4, 5, 4, 2, 0, 2), unit=0.5, octave=0, vel=0.58, rev2=0.5)
        M.lead_line(m, th, I.suling, gain=1.0, vscale=0.72, oct_a=1, oct_b=1, vib=1.2, rev=0.6, rev2=0.6)
        M.lead_line(m, th, I.rebab, gain=0.6, vscale=0.62, oct_a=1, oct_b=1, from_bar=8, vib=1.2)
        M.gender_fig(m, th, gain=0.3, vel=0.5, octave=0, density=1)
        M.colotomy(m, th, density=0.7, gong_every=4, vel=0.8, kethuk=False, kenong=False)
        return M.finish(m, th, rt=(1.8, 4.5), rms=-21.0)
    raise ValueError(name)
