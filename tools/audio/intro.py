"""The launch intro score (music/intro.ogg): one through-composed 10 s cue, timed to ui/intro.gd beat for beat.

The times in CUE below are the same numbers as the T_* constants at the top of ui/intro.gd; change both together.
Pelog on the title theme's root, so the title music picks up in the same key when the intro hands over.
ASSUMED: original composition in gamelan idiom.
"""
import numpy as np
import inst as I
import sampler as S
from dsp import Mix, master, SR, n_of, noise, lowpass, bandpass, fade
from theory import freq
from music import eq

ROOT = 98.0
SCALE = "pelog"

# seconds (mirror of ui/intro.gd)
CUE = {
    "strikes": [0.7, 1.05],   # lightning shows the face: thunder
    "eyes": 1.7,              # Kala's eyes open: the roar
    "cut": 3.0,               # smash cut to the Wiku on the crag: the drums start
    "bolt": 3.8,              # lightning in the wide shot
    "raise": 4.5,             # the staff goes up
    "ka": 4.75,               # Ka is written: riser, roll, choir
    "impact": 6.2,            # the light, dawn, the logo
    "out": 9.2,               # fade to the title (0.8 s)
}
LENGTH = 10.0


def f(deg, octave=0):
    return freq(ROOT, SCALE, deg, octave)


def crash(dur=3.0):
    n = n_of(dur)
    t = np.arange(n) / SR
    y = bandpass(noise(dur), 3000, 12000, 2) * np.exp(-t / (dur * 0.3))
    y += lowpass(noise(dur), 1800, 1) * np.exp(-t / 0.08) * 0.6
    return fade(y * 0.5, 0.0005, 0.2)


def thunder(dur=2.4, seed=0):
    """A crack and a long low roll."""
    n = n_of(dur)
    t = np.arange(n) / SR
    y = lowpass(noise(dur, np.random.default_rng(seed)), 260, 2) * (np.exp(-t / (dur * 0.45)) * (1 + 0.5 * np.sin(t * 9 + seed)))
    y += bandpass(noise(dur, np.random.default_rng(seed + 1)), 1500, 7000, 2) * np.exp(-t / 0.05) * 0.9
    return fade(y * 0.8, 0.002, 0.3)


def score():
    m = Mix(LENGTH, tail=3.0)
    c = CUE

    # --- 0: the storm in the dark: a low drone and a growing rumble, thunder on each strike ---
    m.add(I.pad(f(1, -2), 3.2, 0.6, "drone", att=0.8, rel=0.6), 0.0, 0.7, 0, 0.1, 0.4)
    m.add(I.pad(f(2, -2), 3.0, 0.5, "strings", att=1.4, rel=0.5, bright=0.2), 0.2, 0.45, 0.2, 0.2, 0.4)   # the pelog rub
    m.add(fade(lowpass(noise(3.0, np.random.default_rng(3)), 120, 2) * np.linspace(0.2, 1.0, n_of(3.0)), 0.5, 0.1), 0.0, 0.6)
    for k, t in enumerate(c["strikes"]):
        m.add(thunder(2.2, seed=11 + k), t, 0.8 - 0.2 * k, (-0.4, 0.5)[k], 0.3, 0.5)
        m.add(I.sub_boom(42.0, 1.4, 0.7), t, 0.5)

    # --- the eyes: reversed gong sucks in, the hit, the roar, a heartbeat ---
    rg = I.reverse(I.gong(52.0, 1.2, 0.9))
    m.add(rg, c["eyes"] - len(rg) / SR, 0.5, 0, 0.1, 0.3)
    t = c["eyes"]
    m.add(I.bedug(1.0, 50.0, 1.2), t, 1.0, 0, 0.2, 0.5)
    m.add(I.sub_boom(36.0, 2.5, 1.0), t, 0.9)
    m.add(S.sfx("boss_roar"), t + 0.05, 0.6, 0, 0.3, 0.4)
    for deg, o, g in [(1, -1, 0.6), (2, -1, 0.55), (5, -1, 0.4)]:
        m.add(I.pad(f(deg, o), 1.3, 0.8, "strings", att=0.05, rel=0.3, bright=0.3), t, g, 0, 0.2, 0.4)
    for tb in (t + 0.6, t + 0.85):
        m.add(I.bedug(0.7, 58.0, 0.6), tb, 0.5, 0, 0.15)
    rc = I.reverse(crash(0.9))
    m.add(rc, c["cut"] - len(rc) / SR, 0.45, 0, 0.2, 0.3)

    # --- 1: the cut: a hit, then the drums drive under the wide shot ---
    t = c["cut"]
    m.add(I.gong(55.0, 4.0, 1.0), t, 1.1, 0, 0.1, 0.6)
    m.add(I.bedug(1.0, 52.0, 1.2), t, 1.0, 0, 0.2, 0.4)
    m.add(I.sub_boom(40.0, 2.0, 0.9), t, 0.8)
    m.add(crash(1.6), t, 0.45, 0, 0.3, 0.5)
    span = c["impact"] - t
    for deg, o, g in [(1, -1, 0.55), (5, -1, 0.4), (1, 0, 0.3)]:
        m.add(I.pad(f(deg, o), span, 0.8, "strings", att=0.3, rel=0.1, bright=0.6), t, g * 1.4, 0, 0.2, 0.5)
    beat = 0.2
    bal = [1, 1, 2, 1, 5, 3, 2, 1]
    k = 0
    while t + k * beat < c["impact"] - 0.4:   # drives on under the Ka roll
        tb = t + k * beat
        m.add(I.kendang("dung" if k % 4 == 0 else ("tak" if k % 2 else "tung"), 0.9), tb, 1.0, (-0.15, 0.15)[k % 2], 0.15)
        if k % 2 == 0:
            m.add(I.demung(f(bal[(k // 2) % 8], -1), 0.4, 0.8), tb, 0.75, -0.1, 0.2)
            m.add(I.saron(f(bal[(k // 2) % 8], 0), 0.35, 0.7), tb, 0.6, 0.2, 0.2)
        if k % 8 == 4:
            m.add(I.kempul(f(5, -1), 0.6, 0.7), tb, 0.45, -0.1, 0.3, 0.3)
        k += 1
    m.add(thunder(1.8, seed=21), c["bolt"], 0.55, -0.5, 0.3, 0.5)

    # --- 2: the staff goes up, Ka is written: riser, accelerating roll, choir swelling ---
    m.add(I.kecer(0.9), c["raise"], 0.5, 0.2, 0.3)
    m.add(S.sfx("cast_begin"), c["raise"], 0.5, 0.3, 0.3)
    t = c["ka"]
    span = c["impact"] - t
    m.add(np.resize(S.sfx("ink"), n_of(span)), t, 0.12, 0, 0.2)
    m.add(I.riser(span, 200.0, 4000.0, 0.9), t, 0.55, 0, 0.2)
    for deg, g in [(1, 0.8), (5, 0.6), (1, 0.4)]:
        m.add(I.pad(f(deg, 0 if g > 0.5 else 1), span, 0.8, "choir", att=span * 0.9, rel=0.1), t, g, 0, 0.2, 0.6)
    n_roll = 20
    for k in range(n_roll):
        tb = t + span * (1 - (1 - k / n_roll) ** 1.6)
        m.add(I.kendang("tung" if k % 2 else "dung", 0.4 + 0.6 * k / n_roll), tb, 0.3 + 0.4 * k / n_roll, (-0.2, 0.2)[k % 2], 0.15)
    for k, deg in enumerate([1, 2, 3, 5, 6]):
        m.add(I.bonang(f(deg, 1), 0.4, 0.8), t + 0.1 + k * 0.26, 0.4, 0.2, 0.3)

    # --- 3: the light: gong + bedug + boom + crash + the full chord; the title phrase rings out ---
    t = c["impact"]
    m.add(I.gong(49.0, 6.0, 1.0), t, 1.2, 0, 0.1, 0.9)
    m.add(I.bedug(1.0, 50.0, 1.6), t, 1.0, 0, 0.2, 0.5)
    m.add(I.sub_boom(38.0, 3.5, 1.0), t, 0.9)
    m.add(crash(3.5), t, 0.5, 0, 0.3, 0.7)
    for deg, o, g, kind in [(1, -1, 0.7, "strings"), (5, -1, 0.5, "strings"), (1, 0, 0.8, "choir"), (3, 0, 0.6, "choir"),
                            (5, 0, 0.6, "choir"), (1, 1, 0.45, "strings")]:
        m.add(I.pad(f(deg, o), 3.0, 0.85, kind, att=0.05, rel=1.5, bright=0.8), t, g, 0, 0.2, 0.7)
    m.add(I.bell(f(1, 2), 3.5, 0.8), t, 0.4, 0, 0.4, 0.8)
    for beat, deg, dur in [(0.6, 1, 0.35), (0.95, 3, 0.35), (1.3, 5, 0.8), (2.2, 6, 0.35), (2.55, 5, 1.0)]:
        m.add(I.suling(f(deg, 1), dur + 0.2, 0.8), t + beat, 0.6, -0.15, 0.4, 0.7)
        m.add(I.rebab(f(deg, 0), dur + 0.2, 0.6), t + beat, 0.35, 0.2, 0.3, 0.5)
    m.add(I.kempul(f(5, -1), 1.0, 0.7), t + 1.3, 0.5, -0.1, 0.3, 0.4)

    st = m.render(loop=False, rt=(1.6, 4.4), wet=1.0, seed=7)
    st = eq(st, 3.0)
    # one long fade at the very end so a stream that outlives the scene never clicks
    n = len(st)
    k = n_of(2.5)
    st[n - k:] *= np.linspace(1, 0, k)[:, None]
    return master(st, rms_db=-20.0, ceiling_db=-1.5, glue=False)
