"""One-shot sound effects and stingers. Every recipe returns a mono array; gen_audio.py normalises and encodes."""
import numpy as np
import inst as I
from dsp import (SR, RNG, n_of, tt, noise, exp_env, adsr, fade, lowpass, highpass, bandpass, peak, phase_of, sine,
                 softclip, convolve, make_ir, delay)

R = np.random.default_rng(21)


def _n(sec):
    return R.standard_normal(n_of(sec))


def _fit(parts, total=None):
    n = max(len(p) for p in parts) if total is None else n_of(total)
    out = np.zeros(n)
    for p in parts:
        m = min(n, len(p))
        out[:m] += p[:m]
    return out


def _at(sig, t, n):
    out = np.zeros(n)
    a = n_of(t)
    m = min(len(sig), n - a)
    if m > 0:
        out[a:a + m] = sig[:m]
    return out


def sweep(f0, f1, dur, shape="exp", amp_t60=None):
    n = n_of(dur)
    t = np.arange(n) / SR
    k = t / dur
    f = f0 * (f1 / f0) ** k if shape == "exp" else f0 + (f1 - f0) * k
    y = np.sin(phase_of(f))
    return y * (exp_env(n, amp_t60) if amp_t60 else 1.0)


def whoosh(dur=0.25, f0=500.0, f1=3000.0, peak_at=0.5, width=0.25, level=1.0):
    """Swept band-limited noise (blade through air, spell travel)."""
    n = n_of(dur)
    out = np.zeros(n)
    src = RNG.standard_normal(n)
    steps = 9
    t = np.arange(n) / n
    for i in range(steps):
        c = i / (steps - 1)
        fc = f0 * (f1 / f0) ** c
        band = bandpass(src, fc * 0.7, fc * 1.4, 2)
        g = np.exp(-0.5 * ((t - (0.08 + 0.84 * c)) / (width * 0.45)) ** 2)
        out += band * g
    env = np.exp(-0.5 * ((t - peak_at) / width) ** 2) * 0.6 + 0.4
    return fade(out * env * level * 0.5, 0.004, 0.04)


def thump(f0=120.0, f1=45.0, dur=0.25, level=1.0, click=0.3):
    n = n_of(dur)
    t = np.arange(n) / SR
    fr = f1 + (f0 - f1) * np.exp(-t / 0.03)
    y = np.sin(phase_of(fr)) * np.exp(-6.9 * t / dur)
    y += lowpass(_n(dur), 800, 1) * np.exp(-t / 0.015) * click
    return fade(y * level, 0.0008, 0.02)


def tonal_hit(f, dur=0.5, vel=0.8, kind="metal"):
    return I.bell(f, dur, vel)[: n_of(dur + 0.6)] * 0.8


def chime(f, dur=1.2, vel=0.8, parts=((1, 1.0), (2.01, 0.5), (3.02, 0.32), (4.2, 0.14)), t60=None):
    n = n_of(dur)
    t = np.arange(n) / SR
    y = np.zeros(n)
    for i, (r, a) in enumerate(parts):
        if f * r < SR * 0.45:
            y += a * np.sin(2 * np.pi * f * r * t + R.uniform(0, 6.28)) * np.exp(-6.9 * t / ((t60 or dur) / (1 + 0.6 * i)))
    return fade(y * 0.4 * (0.4 + 0.6 * vel), 0.0008, 0.05)


def crunch(dur=0.12, lo=700, hi=6000, level=1.0):
    n = n_of(dur)
    t = np.arange(n) / SR
    y = bandpass(_n(dur), lo, hi, 2) * np.exp(-t / (dur * 0.35))
    return y * level


def _reverb(y, rt=0.7, wet=0.25, seed=1):
    ir = make_ir(rt, seed=seed, stereo=False)[0]
    w = convolve(y, ir)[: len(y) + n_of(rt)]
    out = np.zeros(len(w))
    out[: len(y)] += y
    return out + w * wet * (np.sqrt(np.sum(y * y)) / (np.sqrt(np.sum(w * w)) + 1e-9))


# ---------------------------------------------------------------------------------------------------------------
# player / combat
# ---------------------------------------------------------------------------------------------------------------

def swing(i):
    f0 = (380, 460, 330)[i]
    f1 = (2600, 3300, 1800)[i]
    y = whoosh(0.22 + 0.05 * i, f0, f1, 0.55, 0.22, 1.0)
    if i == 2:   # the third swing of a combo carries more weight
        y = y + 0.4 * whoosh(0.32, 200, 900, 0.4, 0.2)[: len(y)]
    return y


def swing_heavy():
    return whoosh(0.42, 200, 1800, 0.55, 0.28, 1.1)


def hit(kind="light"):
    if kind == "light":
        y = _fit([crunch(0.09, 900, 7000, 0.9), thump(190, 80, 0.16, 0.7, 0.2), tonal_hit(520, 0.2, 0.5) * 0.2])
    elif kind == "heavy":
        y = _fit([crunch(0.18, 500, 6000, 1.0), thump(160, 50, 0.4, 1.0, 0.4), tonal_hit(300, 0.35, 0.7) * 0.25])
    elif kind == "armor":
        y = _fit([crunch(0.07, 2000, 9000, 0.8), I.kenong(740, 0.3, 0.9)[: n_of(0.7)] * 0.6, thump(200, 90, 0.12, 0.5)])
    elif kind == "kill":
        y = _fit([crunch(0.25, 400, 6000, 1.0), thump(150, 40, 0.55, 1.1, 0.5),
                  _at(sweep(900, 140, 0.35, "exp", 0.3) * 0.35, 0.02, n_of(0.6)), _at(chime(880, 0.8, 0.5, t60=0.8), 0.05, n_of(0.9)) * 0.35])
    elif kind == "flesh":
        y = _fit([crunch(0.1, 300, 2500, 0.9), thump(130, 55, 0.2, 0.9, 0.25)])
    return fade(y * 0.8, 0.0008, 0.03)


def player_hurt():
    y = _fit([thump(140, 50, 0.35, 1.0, 0.4), crunch(0.14, 400, 3500, 0.7), _at(I.kenong(330, 0.4, 0.7)[: n_of(0.8)] * 0.35, 0.01, n_of(0.8))])
    return fade(y * 0.85, 0.001, 0.05)


def dodge():
    return whoosh(0.2, 800, 4500, 0.4, 0.2, 0.8)


def perfect_dodge():
    y = _fit([chime(1568, 1.1, 0.9, t60=1.0), _at(chime(2349, 0.9, 0.7, t60=0.8), 0.05, n_of(1.1)), whoosh(0.18, 1500, 7000, 0.4, 0.2, 0.5)])
    return _reverb(y, 0.8, 0.3)


def shoot():
    n = n_of(0.3)
    t = np.arange(n) / SR
    y = _at(sweep(220, 90, 0.18, "exp", 0.12) * 0.7, 0, n) + bandpass(_n(0.3), 1500, 6000, 1) * np.exp(-t / 0.03) * 0.5
    y += 0.4 * np.sin(2 * np.pi * 180 * t) * np.exp(-t / 0.09)
    return fade(_at(y, 0, n) + _at(whoosh(0.22, 2500, 700, 0.3, 0.2, 0.6), 0.03, n), 0.0005, 0.03)


def arrow_hit():
    return _fit([crunch(0.06, 900, 5000, 0.8), thump(260, 120, 0.1, 0.6)])


def block():
    return _fit([crunch(0.05, 3000, 10000, 0.7), I.kenong(980, 0.3, 0.9)[: n_of(0.6)] * 0.6, thump(240, 120, 0.1, 0.4)])


def enemy_death():
    y = _fit([sweep(520, 90, 0.5, "exp", 0.4) * 0.35, whoosh(0.5, 3000, 300, 0.4, 0.25, 0.7), thump(110, 40, 0.5, 0.7, 0.3),
              _at(chime(660, 1.0, 0.5, t60=1.0), 0.0, n_of(1.0)) * 0.3])
    return _reverb(y, 0.7, 0.3)


def enemy_telegraph():
    n = n_of(0.45)
    t = np.arange(n) / SR
    y = np.sin(phase_of(300 * (700 / 300) ** (t / 0.45))) * np.minimum(1, t / 0.4) ** 2 * 0.6
    y += bandpass(_n(0.45), 600, 4000, 1) * (t / 0.45) ** 2 * 0.2
    return fade(y, 0.01, 0.03)


def stagger():
    return _fit([crunch(0.2, 1200, 8000, 0.9), I.kenong(520, 0.4, 0.8)[: n_of(0.8)] * 0.5, thump(150, 50, 0.3, 0.9)], total=0.9)


def player_death():
    y = _fit([I.gong(55.0, 3.5, 1.0)[: n_of(4.5)], sweep(420, 70, 1.6, "exp", 1.2) * 0.25, whoosh(1.6, 1500, 150, 0.3, 0.5, 0.5)])
    return _reverb(y, 1.4, 0.35)


def flask():
    n = n_of(0.7)
    y = np.zeros(n)
    for i, t0 in enumerate((0.05, 0.22, 0.38)):
        f0 = 380 + 60 * i
        g = sweep(f0, f0 * 1.9, 0.12, "exp", 0.1) * (0.5 - 0.1 * i)
        y += _at(g, t0, n)
    y += _at(bandpass(_n(0.5), 600, 2500, 1) * exp_env(n_of(0.5), 0.3) * 0.15, 0.0, n)
    return fade(y, 0.002, 0.05)


def stamina_empty():
    return fade(_fit([thump(160, 100, 0.12, 0.5), sine(150, n_of(0.12)) * exp_env(n_of(0.12), 0.08) * 0.35]), 0.002, 0.02)


def interact():
    return fade(_fit([chime(988, 0.5, 0.6, t60=0.45), _at(chime(1480, 0.4, 0.5, t60=0.35), 0.04, n_of(0.5))]), 0.001, 0.05)


# ---------------------------------------------------------------------------------------------------------------
# aksara casting and spells
# ---------------------------------------------------------------------------------------------------------------

def cast_begin():
    """Time slows and the lontar opens: low swell and a soft bell."""
    y = _fit([whoosh(0.5, 150, 1200, 0.7, 0.3, 0.7), sweep(90, 220, 0.5, "exp", 0.4) * 0.3, _at(chime(660, 1.0, 0.5, t60=0.9), 0.15, n_of(1.2)) * 0.5])
    return _reverb(y, 0.9, 0.3)


def ink_scratch(dur=1.6):
    """Loopable stylus-on-bark: filtered noise with slow irregular amplitude."""
    n = n_of(dur)
    y = bandpass(_n(dur), 1800, 7000, 1) * 0.6 + bandpass(_n(dur), 300, 1200, 1) * 0.35
    t = np.arange(n) / SR
    am = 0.65 + 0.35 * np.sin(2 * np.pi * 7.3 * t) * np.sin(2 * np.pi * 3.1 * t + 1)
    y = y * am
    x = int(0.1 * SR)   # loop crossfade
    y[:x] = y[:x] * np.linspace(0, 1, x) + y[-x:] * np.linspace(1, 0, x)
    return y[:-x]


def cast_ok(q=0.5):
    f = 523.25 * 2 ** (q * 0.5)
    return _reverb(_fit([chime(f, 1.3, 0.8, t60=1.2), _at(chime(f * 1.5, 1.1, 0.7, t60=1.0), 0.06, n_of(1.3)),
                         _at(chime(f * 2, 0.9, 0.6, t60=0.8), 0.12, n_of(1.3))]), 0.8, 0.3)


def cast_perfect():
    base = cast_ok(1.0)
    up = _fit([chime(1568, 1.4, 0.9, t60=1.3), _at(chime(2093, 1.4, 0.9, t60=1.3), 0.08, n_of(1.4)), _at(chime(2637, 1.4, 0.8, t60=1.3), 0.16, n_of(1.4)),
               whoosh(0.5, 2000, 9000, 0.3, 0.2, 0.4)])
    return _reverb(_fit([base, up * 0.9]), 1.0, 0.35)


def cast_fail():
    y = _fit([sweep(420, 110, 0.35, "exp", 0.25) * 0.5, bandpass(_n(0.35), 400, 2500, 1) * exp_env(n_of(0.35), 0.25) * 0.5])
    return fade(y, 0.002, 0.03)


def spell(kind):
    if kind == "bolt":   # crackling spear of light
        n = n_of(0.8)
        y = _fit([whoosh(0.35, 800, 8000, 0.3, 0.2, 1.0), bandpass(_n(0.5), 2500, 9000, 1) * exp_env(n_of(0.5), 0.25) * 0.9, thump(300, 70, 0.3, 0.7)])
        return _reverb(softclip(y, 1.2), 0.5, 0.2)
    if kind == "ward":   # resonant shimmer dome
        y = _fit([chime(392, 2.0, 0.9, parts=((1, 1), (2, .6), (3, .4), (4.01, .3), (5.04, .2)), t60=2.0), _at(chime(588, 1.8, 0.7, t60=1.6), 0.1, n_of(2.0)),
                  whoosh(0.5, 300, 2500, 0.6, 0.3, 0.5)])
        return _reverb(y, 1.2, 0.35)
    if kind == "bind":   # roots creaking out of the ground
        y = _fit([lowpass(_n(0.8), 700, 2) * (1 - np.exp(-np.arange(n_of(0.8)) / SR / 0.2)) * exp_env(n_of(0.8), 0.7) * 1.2,
                  crunch(0.5, 400, 2200, 0.7), sweep(110, 70, 0.6, "exp", 0.5) * 0.4])
        return y
    if kind == "burst":   # shockwave
        y = _fit([thump(130, 35, 0.9, 1.3, 0.6), whoosh(0.6, 3000, 200, 0.3, 0.3, 1.0), crunch(0.35, 300, 4000, 0.8),
                  _at(chime(440, 1.4, 0.6, t60=1.2), 0.05, n_of(1.4)) * 0.4])
        return _reverb(softclip(y, 1.3), 0.9, 0.3)
    if kind == "heal":   # rising sparkle
        y = np.zeros(n_of(1.6))
        for i, f in enumerate((587, 740, 880, 1175, 1480)):
            y += _at(chime(f, 1.1, 0.7, t60=1.0), 0.09 * i, len(y))
        return _reverb(y * 0.8, 1.0, 0.35)
    if kind == "dash":
        return _fit([whoosh(0.3, 400, 9000, 0.35, 0.18, 1.1), crunch(0.08, 2500, 9000, 0.6), thump(200, 80, 0.2, 0.5)])
    if kind == "rally":   # war-horn gong and shimmer
        y = _fit([I.gong(110.0, 2.2, 1.0)[: n_of(3.0)], I.bedug(0.9, 70, 0.8)[: n_of(1.5)] * 0.8,
                  _at(chime(660, 1.6, 0.7, t60=1.5), 0.2, n_of(2.0)), _at(chime(990, 1.6, 0.7, t60=1.5), 0.3, n_of(2.0)) * 0.6])
        return _reverb(y, 1.1, 0.3)
    if kind == "summon":   # tiger spirit: growl + gong
        n = n_of(1.2)
        t = np.arange(n) / SR
        growl = lowpass(softclip(np.sin(phase_of(75 + 18 * np.sin(2 * np.pi * 22 * t))) + 0.6 * np.sin(phase_of(150 + 25 * np.sin(2 * np.pi * 22 * t))), 3), 900, 2)
        growl = growl * np.minimum(1, t / 0.1) * np.exp(-t / 0.55) + bandpass(_n(1.2), 200, 1500, 1) * np.exp(-t / 0.4) * 0.25
        y = _fit([growl * 1.2, I.gong(98.0, 2.5, 0.8)[: n_of(2.5)] * 0.7])
        return _reverb(y, 1.0, 0.3)
    if kind == "ombak":   # wave crash
        n = n_of(1.8)
        t = np.arange(n) / SR
        swell = np.exp(-0.5 * ((t - 0.55) / 0.4) ** 2)
        y = lowpass(_n(1.8), 1800, 1) * swell * 1.1 + highpass(_n(1.8), 2500, 1) * np.exp(-0.5 * ((t - 0.7) / 0.25) ** 2) * 0.5
        return _reverb(fade(y, 0.02, 0.2), 0.8, 0.2)
    raise ValueError(kind)


# ---------------------------------------------------------------------------------------------------------------
# world
# ---------------------------------------------------------------------------------------------------------------

def chest_open():
    n = n_of(1.4)
    y = _fit([crunch(0.12, 300, 2500, 0.8), thump(180, 90, 0.2, 0.7),
              _at(sweep(180, 300, 0.25, "lin", 0.25) * 0.3, 0.1, n)])
    y += _at(chime(784, 1.2, 0.7, t60=1.1), 0.25, n) + _at(chime(1175, 1.0, 0.6, t60=0.9), 0.35, n) * 0.8 + _at(chime(1568, 0.9, 0.6, t60=0.8), 0.45, n) * 0.6
    return _reverb(y, 0.8, 0.25)


def pickup(rare=False):
    y = _fit([chime(1319, 0.7, 0.8, t60=0.6), _at(chime(1760, 0.8, 0.8, t60=0.7), 0.07, n_of(0.9))])
    if rare:
        y = _fit([y, _at(chime(2217, 1.2, 0.8, t60=1.0), 0.14, n_of(1.3)), _at(chime(2637, 1.3, 0.8, t60=1.1), 0.22, n_of(1.4))])
    return _reverb(y, 0.6, 0.2)


def exit_door():
    return _fit([whoosh(0.4, 250, 1500, 0.5, 0.3, 0.7), thump(90, 50, 0.3, 0.4)])


def petilasan():
    y = _fit([I.gong(73.0, 5.0, 0.9)[: n_of(6.0)], _at(I.bell(587, 3.0, 0.7)[: n_of(3.5)], 0.3, n_of(6.0)) * 0.8, _at(I.bell(880, 3.0, 0.6)[: n_of(3.5)], 0.6, n_of(6.0)) * 0.6,
              _at(whoosh(1.5, 200, 3000, 0.7, 0.4, 0.5), 0, n_of(6.0))])
    return _reverb(y, 2.0, 0.35)


def lontar():
    return _reverb(_fit([chime(1760, 0.9, 0.6, parts=((1, 1), (2.76, .35), (5.4, .15)), t60=0.8), _at(chime(2349, 0.8, 0.5, t60=0.7), 0.1, n_of(0.9)) * 0.7]), 0.7, 0.3)


def thud():
    return _fit([thump(100, 50, 0.3, 0.9, 0.35)])


def shortcut_open():
    return _fit([crunch(0.4, 150, 1200, 0.8) * np.linspace(0.3, 1, n_of(0.4)), thump(70, 38, 0.7, 1.0, 0.5), whoosh(0.5, 150, 900, 0.5, 0.3, 0.5)[: n_of(0.7)]])


def puzzle_solve():
    y = np.zeros(n_of(1.6))
    for i, f in enumerate((523, 659, 784, 1047)):
        y += _at(chime(f, 1.2, 0.8, t60=1.1), 0.11 * i, len(y))
    return _reverb(y, 1.0, 0.3)


def kabut():
    return _reverb(_fit([whoosh(1.2, 300, 2000, 0.5, 0.5, 0.5), sweep(200, 400, 1.2, "lin", 1.0) * 0.1]), 1.0, 0.3)


def memory(entering=True):
    y = _fit([I.gong(70.0, 3.0, 0.8)[: n_of(4.0)], whoosh(1.4, 200, 4000, 0.6, 0.4, 0.7), chime(880, 2.0, 0.6, t60=1.8) * 0.5])
    y = _reverb(y, 1.5, 0.4)
    return I.reverse(y) if entering else y


def save():
    return _reverb(_fit([chime(784, 0.8, 0.6, t60=0.7), _at(chime(1175, 0.8, 0.6, t60=0.7), 0.1, n_of(0.9))]), 0.6, 0.2)


def wrong():
    return fade(_fit([sweep(300, 180, 0.22, "exp", 0.2) * 0.5, sine(145, n_of(0.22)) * exp_env(n_of(0.22), 0.15) * 0.3]), 0.002, 0.03)


def torch():
    n = n_of(0.9)
    return _fit([whoosh(0.5, 300, 3500, 0.35, 0.2, 0.9), _at(bandpass(_n(0.7), 1500, 8000, 1) * exp_env(n_of(0.7), 0.4) * 0.3, 0.1, n)])


def boss_roar():
    n = n_of(1.8)
    t = np.arange(n) / SR
    f = 62 * (1 + 0.5 * np.exp(-((t - 0.3) / 0.5) ** 2)) * (1 + 0.04 * np.sin(2 * np.pi * 14 * t))
    y = softclip(np.sin(phase_of(f)) + 0.7 * np.sin(phase_of(f * 2.01)) + 0.4 * np.sin(phase_of(f * 3.02)), 3)
    y = lowpass(y, 1200, 2) * np.minimum(1, t / 0.15) * np.exp(-((t - 0.5) / 0.9) ** 2)
    y += bandpass(_n(1.8), 200, 2000, 1) * np.exp(-((t - 0.5) / 0.6) ** 2) * 0.35
    return _reverb(fade(y * 1.1, 0.01, 0.2), 1.2, 0.3)


def boss_slam():
    return _reverb(_fit([thump(110, 30, 1.2, 1.4, 0.6), crunch(0.4, 120, 3000, 0.9), whoosh(0.7, 2500, 100, 0.3, 0.3, 0.6)]), 1.0, 0.3)


def boss_telegraph():
    n = n_of(0.9)
    t = np.arange(n) / SR
    y = sweep(120, 360, 0.9, "exp") * (t / 0.9) ** 1.5 * 0.5 + bandpass(_n(0.9), 200, 3000, 1) * (t / 0.9) ** 2 * 0.25
    return fade(y, 0.02, 0.05)


def boss_phase():
    y = _fit([I.gong(55.0, 4.0, 1.0)[: n_of(5.0)], I.bedug(1.0, 60, 1.2)[: n_of(2.0)], whoosh(1.5, 150, 5000, 0.8, 0.4, 0.8), chime(660, 3.0, 0.7, t60=3.0) * 0.4])
    return _reverb(y, 1.6, 0.35)


def boss_death():
    y = _fit([I.gong(48.0, 6.0, 1.0)[: n_of(7.0)], thump(100, 28, 2.0, 1.2, 0.5), whoosh(2.5, 4000, 100, 0.4, 0.5, 0.8),
              _at(chime(528, 4.0, 0.7, t60=4.0), 0.5, n_of(5.0)) * 0.5, _at(chime(792, 4.0, 0.7, t60=4.0), 0.9, n_of(5.0)) * 0.4])
    return _reverb(y, 2.0, 0.4)


# ---------------------------------------------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------------------------------------------

def ui_move():
    return fade(I.kethuk(1100, 0.6)[: n_of(0.07)] * 1.4, 0.0005, 0.01)


def ui_confirm():
    return _reverb(_fit([I.bonang(784, 0.2, 0.7)[: n_of(0.5)] * 1.3, _at(I.bonang(1175, 0.2, 0.7)[: n_of(0.5)], 0.045, n_of(0.5)) * 1.1]), 0.4, 0.15)


def ui_back():
    return _reverb(_fit([I.bonang(659, 0.2, 0.6)[: n_of(0.45)] * 1.2, _at(I.bonang(494, 0.2, 0.6)[: n_of(0.45)], 0.05, n_of(0.45)) * 1.0]), 0.4, 0.12)


def ui_denied():
    return wrong()


def page_flip(opening=False, closing=False):
    """Leaf of lontar turning: papery sweep and a wooden tap."""
    dur = 0.3 if not (opening or closing) else 0.55
    n = n_of(dur)
    t = np.arange(n) / SR
    p = bandpass(_n(dur), 1200, 7500, 1) * np.exp(-0.5 * ((t - dur * 0.35) / (dur * 0.18)) ** 2)
    p += lowpass(_n(dur), 400, 1) * np.exp(-0.5 * ((t - dur * 0.5) / (dur * 0.2)) ** 2) * 0.3
    y = p * 0.9 + _at(I.kethuk(560, 0.7)[: n_of(0.1)] * 0.8, dur * 0.62 if not (opening or closing) else dur * 0.8, n)
    if opening:
        y += _at(chime(660, 0.6, 0.4, t60=0.5), 0.05, n) * 0.5
    if closing:
        y += _at(thump(120, 70, 0.15, 0.5), dur * 0.72, n) * 0.6
    return fade(y, 0.002, 0.03)


def ui_slider():
    return fade(I.kethuk(900, 0.5)[: n_of(0.05)] * 1.2, 0.0005, 0.01)


def ui_letter():
    return fade(I.kethuk(760, 0.6)[: n_of(0.08)] * 1.2 + _at(chime(1320, 0.2, 0.4, t60=0.18), 0, n_of(0.2))[: n_of(0.08)] * 0.2, 0.0005, 0.01)


def ui_choice():
    return _reverb(_fit([I.bonang(880, 0.2, 0.8)[: n_of(0.5)] * 1.2]), 0.4, 0.15)


def ui_equip():
    return _fit([crunch(0.07, 1500, 7000, 0.7), I.kenong(620, 0.3, 0.7)[: n_of(0.5)] * 0.5, thump(200, 100, 0.1, 0.4)])


def ui_pip():
    return fade(chime(1568, 0.4, 0.6, t60=0.35), 0.001, 0.03)


def ui_start():
    y = _fit([I.gong(73.0, 3.0, 1.0)[: n_of(4.0)], _at(whoosh(0.9, 200, 4000, 0.7, 0.3, 0.6), 0, n_of(4.0)), _at(chime(784, 2.0, 0.7, t60=2.0), 0.2, n_of(4.0)) * 0.6])
    return _reverb(y, 1.5, 0.35)


def blip(i):
    """Dialogue typewriter blip: a soft bamboo knock; i picks one of six pitches."""
    f = (330, 392, 440, 523, 587, 659)[i % 6]
    n = n_of(0.07)
    t = np.arange(n) / SR
    y = (np.sin(2 * np.pi * f * t) + 0.35 * np.sin(2 * np.pi * f * 2.4 * t)) * np.exp(-t / 0.022)
    y += highpass(_n(0.07), 2500, 1) * np.exp(-t / 0.004) * 0.12
    return fade(y * 0.7, 0.0005, 0.008)


def step(kind, i=0):
    r = np.random.default_rng(100 + i)
    if kind == "grass":
        n = n_of(0.14)
        t = np.arange(n) / SR
        return fade(bandpass(r.standard_normal(n), 500 + 80 * i, 3500, 1) * np.exp(-t / 0.035) * 0.8, 0.002, 0.02)
    if kind == "stone":
        n = n_of(0.12)
        t = np.arange(n) / SR
        y = bandpass(r.standard_normal(n), 700, 5000, 1) * np.exp(-t / 0.018) + np.sin(2 * np.pi * (170 + 20 * i) * t) * np.exp(-t / 0.03) * 0.5
        return fade(y, 0.001, 0.02)
    if kind == "sand":
        n = n_of(0.2)
        t = np.arange(n) / SR
        return fade(bandpass(r.standard_normal(n), 1500, 7000, 1) * np.exp(-0.5 * ((t - 0.06) / 0.05) ** 2) * 0.7, 0.01, 0.04)
    if kind == "wood":
        n = n_of(0.14)
        t = np.arange(n) / SR
        y = np.sin(2 * np.pi * (240 + 30 * i) * t) * np.exp(-t / 0.035) + bandpass(r.standard_normal(n), 800, 3500, 1) * np.exp(-t / 0.012) * 0.5
        return fade(y, 0.001, 0.02)
    if kind == "water":
        n = n_of(0.3)
        t = np.arange(n) / SR
        y = bandpass(r.standard_normal(n), 400, 4500, 1) * np.exp(-0.5 * ((t - 0.08) / 0.07) ** 2)
        y += np.sin(phase_of(500 + 900 * t / 0.3)) * np.exp(-t / 0.05) * 0.2
        return fade(y, 0.004, 0.06)
    raise ValueError(kind)


# ---------------------------------------------------------------------------------------------------------------
# stingers (short musical phrases)
# ---------------------------------------------------------------------------------------------------------------

def _phrase(notes, fn, spacing=0.18, tail=2.0, gain=1.0, **kw):
    total = len(notes) * spacing + tail
    y = np.zeros(n_of(total))
    for i, (f, v) in enumerate(notes):
        y += _at(fn(f, spacing * 1.5, v, **kw), i * spacing, len(y)) * gain
    return y


def jingle(kind):
    if kind == "victory":   # boss defeated: gong, rising gender phrase, choir swell
        y = np.zeros(n_of(8.0))
        y += _at(I.gong(73.0, 6.0, 1.0), 0.0, len(y)) + _at(I.bedug(1.0, 58, 1.2), 0.0, len(y))
        for i, f in enumerate((196, 247, 294, 392, 494, 588)):
            y += _at(I.gender(f, 0.5, 0.8), 0.5 + i * 0.22, len(y)) * 0.9 + _at(I.suling(f * 2, 0.5, 0.7), 0.5 + i * 0.22, len(y)) * 0.6
        y += _at(I.pad(196, 4.5, 0.7, "choir", att=0.8, rel=1.5), 1.3, len(y)) + _at(I.pad(294, 4.5, 0.7, "choir", att=0.8, rel=1.5), 1.3, len(y)) * 0.8
        y += _at(I.pad(392, 4.5, 0.6, "choir", att=0.8, rel=1.5), 1.3, len(y)) * 0.7 + _at(I.bell(1176, 3.0, 0.7), 1.9, len(y)) * 0.5
        return _reverb(y, 2.2, 0.4)
    if kind == "quest_new":
        y = _phrase([(392, 0.8), (523, 0.8), (659, 0.9)], I.gender, 0.2, 1.8)
        y += _at(I.suling(784, 1.0, 0.7), 0.6, len(y)) * 0.6
        y += _at(I.bell(1568, 1.2, 0.6), 0.55, len(y)) * 0.5
        return _reverb(y, 1.2, 0.3)
    if kind == "quest_done":
        y = np.zeros(n_of(4.0))
        for i, f in enumerate((392, 494, 588, 784)):
            y += _at(I.gender(f, 0.5, 0.85), i * 0.2, len(y)) + _at(I.suling(f * 2, 0.6, 0.7), i * 0.2, len(y)) * 0.6
        y += _at(I.gong(98.0, 3.0, 0.9), 0.8, len(y)) + _at(I.pad(392, 2.5, 0.6, "choir", att=0.4, rel=1.4), 0.8, len(y)) + _at(I.bell(1568, 2.0, 0.7), 0.85, len(y)) * 0.6
        return _reverb(y, 1.6, 0.35)
    if kind == "rest":   # blessing at a petilasan: soft, ascending, warm
        y = np.zeros(n_of(6.0))
        for i, f in enumerate((220, 294, 330, 440)):
            y += _at(I.harp(f, 1.2, 0.7), i * 0.35, len(y))
        y += _at(I.pad(220, 4.5, 0.6, "choir", att=0.9, rel=1.8), 0.3, len(y)) + _at(I.pad(330, 4.5, 0.55, "choir", att=0.9, rel=1.8), 0.3, len(y)) * 0.8
        y += _at(I.bell(880, 3.0, 0.6), 1.2, len(y)) * 0.5
        return _reverb(y, 2.0, 0.4)
    if kind == "death":
        y = np.zeros(n_of(7.0))
        y += _at(I.gong(46.0, 6.0, 1.0), 0.0, len(y))
        for i, f in enumerate((294, 262, 233, 196)):
            y += _at(I.rebab(f, 1.4, 0.7, vib=1.4), 0.8 + i * 0.9, len(y)) * 0.8
        y += _at(I.pad(98, 5.0, 0.6, "drone", att=1.0, rel=2.0), 0.5, len(y))
        return _reverb(y, 2.4, 0.45)
    if kind == "discover":
        y = _phrase([(988, 0.7), (1319, 0.8), (1760, 0.9)], I.kacapi, 0.14, 2.0, pluck=0.2) + 0
        y += _at(I.bell(2349, 1.5, 0.5), 0.3, len(y)) * 0.4
        return _reverb(y, 1.4, 0.35)
    if kind == "area_clear":
        y = np.zeros(n_of(3.0))
        y += _at(I.gong(110.0, 2.5, 0.8), 0.0, len(y))
        for i, f in enumerate((294, 392, 494)):
            y += _at(I.gender(f, 0.4, 0.8), 0.15 + i * 0.16, len(y))
        y += _at(I.suling(784, 1.0, 0.7), 0.6, len(y)) * 0.7
        return _reverb(y, 1.2, 0.3)
    if kind == "choice":   # Major choice: bell, then a held suspended chord
        y = np.zeros(n_of(5.0))
        y += _at(I.bell(440, 3.0, 0.8), 0.0, len(y)) + _at(I.pad(147, 4.0, 0.6, "choir", att=0.6, rel=1.6), 0.2, len(y)) + _at(I.pad(220, 4.0, 0.55, "choir", att=0.6, rel=1.6), 0.2, len(y)) * 0.8
        y += _at(I.gong(73.0, 4.0, 0.7), 0.0, len(y)) * 0.8
        return _reverb(y, 1.8, 0.4)
    if kind == "glyph":   # new aksara learned
        y = np.zeros(n_of(4.0))
        for i, f in enumerate((660, 880, 1175, 1568)):
            y += _at(I.kacapi(f, 0.8, 0.8, pluck=0.2), i * 0.13, len(y)) + _at(I.bell(f * 2, 1.4, 0.4), i * 0.13 + 0.05, len(y)) * 0.3
        y += _at(I.pad(330, 3.0, 0.5, "choir", att=0.5, rel=1.4), 0.2, len(y))
        return _reverb(y, 1.6, 0.4)
    if kind == "boss_intro":
        y = np.zeros(n_of(5.0))
        y += _at(I.bedug(1.0, 55, 1.6), 0.0, len(y)) + _at(I.gong(55.0, 5.0, 1.0), 0.0, len(y)) + _at(I.sub_boom(36, 3.0, 1.0), 0.0, len(y)) * 0.6
        y += _at(I.tarompet(147, 1.4, 0.9), 0.4, len(y)) * 0.8 + _at(boss_roar(), 0.1, len(y)) * 0.6
        return _reverb(y, 1.6, 0.35)
    if kind == "levelup":
        y = np.zeros(n_of(4.0))
        for i, f in enumerate((392, 523, 659, 784, 1047)):
            y += _at(I.bonang(f, 0.3, 0.85), i * 0.1, len(y)) * 1.1 + _at(I.bell(f * 2, 1.6, 0.4), i * 0.1, len(y)) * 0.3
        y += _at(I.pad(392, 3.0, 0.6, "choir", att=0.3, rel=1.4), 0.3, len(y)) + _at(I.gong(98.0, 3.0, 0.7), 0.5, len(y)) * 0.7
        return _reverb(y, 1.5, 0.35)
    if kind == "area_title":   # new area card
        y = np.zeros(n_of(4.0))
        y += _at(I.gong(82.0, 4.0, 0.7), 0.0, len(y)) + _at(I.pad(165, 3.0, 0.5, "choir", att=0.8, rel=1.2), 0.1, len(y)) * 0.8
        y += _at(I.bell(659, 2.5, 0.5), 0.4, len(y)) * 0.5
        return _reverb(y, 1.8, 0.4)
    raise ValueError(kind)
