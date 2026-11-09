"""The launch intro score (music/intro.ogg): one through-composed cue, timed to ui/intro.gd beat for beat.

The times in CUE below are the same numbers as the T_* constants at the top of ui/intro.gd; change both together.
Pelog on the title theme's root, so the title music picks up in the same key when the intro hands over.
ASSUMED: original composition in gamelan idiom.
"""
import numpy as np
import inst as I
import sfx as S
from dsp import Mix, master, SR, n_of, noise, lowpass, bandpass, fade
from theory import freq
from music import eq

ROOT = 98.0
SCALE = "pelog"

# seconds (mirror of ui/intro.gd)
CUE = {
    "lamp": 1.2,         # the lamp catches: gong
    "kelir": 4.4,        # the screen lights up
    "gunungan": 5.6,     # the gunungan rises, kendang starts
    "sweep": 8.6,        # the gunungan sweeps away
    "glyphs": [9.4, 10.2, 11.0, 11.8, 12.6],   # ha na ca ra ka, one stroke-drawn glyph each
    "flare": 13.4,       # all five flare
    "kala": 14.2,        # Kala wakes: the hit
    "eyes": 15.8,        # the eyes open: roar
    "devour": 16.6,      # the glyphs are swallowed
    "black": 17.6,       # cut to black
    "dawn": 20.4,        # dawn on the peak
    "raise": 23.6,       # the Wiku raises the staff and writes Ka
    "impact": 25.6,      # the light, the logo
    "out": 29.6,         # fade to the title
}
LENGTH = 32.0


def f(deg, octave=0):
    return freq(ROOT, SCALE, deg, octave)


def crash(dur=3.0):
    n = n_of(dur)
    t = np.arange(n) / SR
    y = bandpass(noise(dur), 3000, 12000, 2) * np.exp(-t / (dur * 0.3))
    y += lowpass(noise(dur), 1800, 1) * np.exp(-t / 0.08) * 0.6
    return fade(y * 0.5, 0.0005, 0.2)


def score():
    m = Mix(LENGTH, tail=3.0)
    c = CUE

    # --- 0: the clock in the dark, a low drone breathing in ---
    m.add(I.pad(f(1, -2), 5.0, 0.5, "drone", att=1.4, rel=1.5), 0.0, 0.7, 0, 0.1, 0.4)
    for k in range(6):
        m.add(I.tick(1500 if k % 2 else 1200, 0.5), 0.2 + k * 0.5, 0.18, (-0.3, 0.3)[k % 2], 0.2, 0.4)

    # --- 1: the lamp: gong ageng, a shimmer of kempyang ---
    t = c["lamp"]
    m.add(I.gong(49.0, 9.0, 0.95), t, 1.1, 0, 0.1, 0.8)
    m.add(I.sub_boom(41.0, 3.0, 0.8), t, 0.5)
    m.add(I.kempyang(1400, 0.6), t + 0.05, 0.25, 0.4, 0.4, 0.6)
    # the suling alone over strings: the first words
    m.add(I.pad(f(1, -1), 7.5, 0.5, "strings", att=2.0, rel=2.5), t + 0.6, 0.55, 0, 0.2, 0.6)
    m.add(I.pad(f(5, -1), 7.5, 0.45, "strings", att=2.4, rel=2.5), t + 0.9, 0.4, 0.2, 0.2, 0.6)
    for beat, deg, dur in [(1.0, 5, 0.9), (2.0, 6, 0.5), (2.5, 5, 0.5), (3.0, 3, 1.4)]:
        m.add(I.suling(f(deg, 1), dur + 0.2, 0.65, vib=1.2), t + beat, 0.55, -0.15, 0.4, 0.6)

    # --- 2: the screen lights (a reversed bell swells into the gunungan) ---
    sw = I.reverse(I.bell(f(5, 1), 1.4, 0.7))
    m.add(sw, c["gunungan"] - len(sw) / SR, 0.5, 0, 0.3, 0.5)

    # --- 3: the gunungan dances: kendang, saron balungan, kethuk ---
    t, beat = c["gunungan"], 0.375
    bal = [1, 3, 5, 6, 5, 3, 2, 1]
    for i in range(8):
        tb = t + i * beat
        m.add(I.saron(f(bal[i], 0), 0.5, 0.7), tb, 0.55, -0.2, 0.25)
        m.add(I.demung(f(bal[i], -1), 0.6, 0.6), tb, 0.4, 0.1, 0.2)
        m.add(I.kendang("dung" if i % 4 == 0 else ("tak" if i % 2 else "tung"), 0.75), tb, 0.6, 0.0, 0.15)
        m.add(I.kendang("ket", 0.5), tb + beat * 0.5, 0.35, 0.1, 0.1)
        if i % 2 == 1:
            m.add(I.kethuk(520, 0.7), tb, 0.35, 0.3, 0.2)
    m.add(I.kempul(f(5, -1), 0.8, 0.8), t + 4 * beat, 0.6, -0.1, 0.3, 0.3)
    m.add(I.gong(55.0, 4.0, 0.7), t + 8 * beat, 0.6, 0, 0.1, 0.6)   # lands as it sweeps
    m.add(S.whoosh(0.6, 300.0, 2400.0, 0.5, 0.3, 1.0), c["sweep"], 0.5, 0.4, 0.3)

    # --- 4: ha na ca ra ka: each glyph a bell + gender note, climbing; a soft pad under ---
    m.add(I.pad(f(1, -1), 4.8, 0.5, "choir", att=1.2, rel=1.2), c["glyphs"][0], 0.5, 0, 0.2, 0.7)
    for k, tg in enumerate(c["glyphs"]):
        deg = [1, 2, 3, 5, 6][k]
        m.add(S.ink_scratch(0.6), tg, 0.10, (-0.4, -0.2, 0, 0.2, 0.4)[k], 0.1)
        m.add(I.gender(f(deg, 1), 1.2, 0.75), tg + 0.55, 0.6, (-0.4, -0.2, 0, 0.2, 0.4)[k], 0.4, 0.4)
        m.add(I.bell(f(deg, 2), 1.6, 0.6), tg + 0.55, 0.32, (-0.4, -0.2, 0, 0.2, 0.4)[k], 0.4, 0.6)
        m.add(I.kendang("dung", 0.6), tg, 0.35, 0, 0.2)
    t = c["flare"]
    for deg, o, g in [(1, 0, 0.6), (3, 0, 0.5), (5, 0, 0.5), (1, 1, 0.4)]:
        m.add(I.pad(f(deg, o), 0.9, 0.7, "choir", att=0.08, rel=0.6), t, g, 0, 0.3, 0.6)
    m.add(I.kecer(0.9), t, 0.5, 0.2, 0.3)

    # --- 5: Kala: a reversed gong sucks in, then the hit; a dissonant low cluster; the clock races ---
    rg = I.reverse(I.gong(52.0, 2.5, 0.9))
    m.add(rg, c["kala"] - len(rg) / SR, 0.6, 0, 0.1, 0.3)
    t = c["kala"]
    m.add(I.bedug(1.0, 52.0, 1.4), t, 1.0, 0, 0.2, 0.5)
    m.add(I.sub_boom(36.0, 3.5, 1.0), t, 0.9)
    m.add(crash(2.5), t, 0.35, 0, 0.3, 0.5)
    for deg, o, g in [(1, -2, 0.8), (2, -2, 0.7), (5, -1, 0.5), (6, -1, 0.45)]:   # 1 against 2: the pelog rub
        m.add(I.pad(f(deg, o), 3.4, 0.8, "strings", att=0.3, rel=0.4, bright=0.2), t, g, (-0.3, 0.3, -0.1, 0.1)[deg % 4], 0.2, 0.4)
    for k in range(9):   # heartbeat bedug, quickening
        tb = t + 0.4 + sum(0.42 * 0.88 ** j for j in range(k))
        if tb < c["black"]:
            m.add(I.bedug(0.7, 60.0, 0.6), tb, 0.55, 0, 0.15)
    for k in range(24):   # the clock, faster and faster
        tb = t + 0.2 + sum(0.25 * 0.93 ** j for j in range(k))
        if tb < c["black"]:
            m.add(I.tick(1700, 0.7), tb, 0.22, (-0.4, 0.4)[k % 2], 0.2)
    m.add(I.riser(c["black"] - t, 120.0, 1800.0, 0.6), t, 0.35, 0, 0.2)
    m.add(S.boss_roar(), c["eyes"], 0.7, 0, 0.3, 0.4)
    m.add(S.whoosh(0.8, 2400.0, 200.0, 0.4, 0.3, 1.0), c["devour"], 0.5, 0, 0.3)

    # --- 6: black. One low gong, two heartbeats, silence ---
    t = c["black"]
    m.add(I.gong(41.0, 6.0, 0.8), t + 0.3, 0.7, 0, 0.1, 0.6)
    m.add(I.bedug(0.6, 56.0, 0.5), t + 0.9, 0.45)
    m.add(I.bedug(0.5, 56.0, 0.5), t + 1.25, 0.35)

    # --- 7: dawn: warm strings, the suling sings the title phrase, gender arpeggios ---
    t = c["dawn"]
    for deg, o, g in [(1, -1, 0.6), (5, -1, 0.45), (3, 0, 0.35)]:
        m.add(I.pad(f(deg, o), 5.4, 0.6, "strings", att=1.4, rel=1.4, bright=0.7), t, g, 0, 0.2, 0.6)
    for beat, deg, dur in [(0.4, 5, 0.6), (0.9, 6, 0.4), (1.3, 5, 0.4), (1.7, 3, 0.9), (2.7, 2, 0.4), (3.1, 3, 1.4)]:
        m.add(I.suling(f(deg, 1), dur + 0.2, 0.7, vib=1.2), t + beat, 0.6, -0.15, 0.4, 0.6)
    for k in range(12):
        deg = [1, 3, 5, 3, 6, 5, 3, 5, 1, 3, 5, 6][k]
        m.add(I.gender(f(deg, 0), 0.8, 0.5), t + 0.2 + k * 0.27, 0.3, 0.3, 0.3, 0.3)

    # --- 8: the staff rises, the Ka is written: riser, rolling kendang, choir crescendo ---
    t = c["raise"]
    span = c["impact"] - t
    m.add(I.riser(span, 200.0, 4000.0, 0.9), t, 0.55, 0, 0.2)
    m.add(I.pad(f(1, 0), span, 0.8, "choir", att=span * 0.9, rel=0.1), t, 0.8, 0, 0.2, 0.6)
    m.add(I.pad(f(5, 0), span, 0.8, "choir", att=span * 0.9, rel=0.1), t, 0.6, 0, 0.2, 0.6)
    n_roll = 24
    for k in range(n_roll):
        tb = t + span * (1 - (1 - k / n_roll) ** 1.6)
        m.add(I.kendang("tung" if k % 2 else "dung", 0.4 + 0.6 * k / n_roll), tb, 0.3 + 0.4 * k / n_roll, (-0.2, 0.2)[k % 2], 0.15)
    for k, deg in enumerate([1, 2, 3, 5, 6, 1]):
        m.add(I.bonang(f(deg, 1 if k < 5 else 2), 0.4, 0.8), t + 0.3 + k * 0.28, 0.4, 0.2, 0.3)

    # --- 9: impact: gong + bedug + boom + crash + the full chord; then the title phrase in triumph ---
    t = c["impact"]
    m.add(I.gong(49.0, 9.0, 1.0), t, 1.2, 0, 0.1, 0.9)
    m.add(I.bedug(1.0, 50.0, 1.6), t, 1.0, 0, 0.2, 0.5)
    m.add(I.sub_boom(38.0, 4.0, 1.0), t, 0.9)
    m.add(crash(4.0), t, 0.5, 0, 0.3, 0.7)
    for deg, o, g, kind in [(1, -1, 0.7, "strings"), (5, -1, 0.5, "strings"), (1, 0, 0.8, "choir"), (3, 0, 0.6, "choir"),
                            (5, 0, 0.6, "choir"), (1, 1, 0.45, "strings")]:
        m.add(I.pad(f(deg, o), 4.6, 0.85, kind, att=0.05, rel=2.2, bright=0.8), t, g, 0, 0.2, 0.7)
    m.add(I.bell(f(1, 2), 4.0, 0.8), t, 0.4, 0, 0.4, 0.8)
    for beat, deg, dur in [(1.0, 1, 0.5), (1.5, 3, 0.5), (2.0, 5, 0.9), (3.0, 6, 0.5), (3.5, 5, 1.6)]:
        m.add(I.suling(f(deg, 1), dur + 0.2, 0.8, vib=1.2), t + beat, 0.6, -0.15, 0.4, 0.7)
        m.add(I.rebab(f(deg, 0), dur + 0.2, 0.6, vib=1.2), t + beat, 0.35, 0.2, 0.3, 0.5)
    m.add(I.kempul(f(5, -1), 1.0, 0.7), t + 2.0, 0.5, -0.1, 0.3, 0.4)

    st = m.render(loop=False, rt=(1.6, 4.4), wet=1.0, seed=7)
    st = eq(st, 7.0)
    # one long fade at the very end so a stream that outlives the scene never clicks
    n = len(st)
    k = n_of(2.5)
    st[n - k:] *= np.linspace(1, 0, k)[:, None]
    return master(st, rms_db=-20.0, ceiling_db=-1.5, glue=False)
