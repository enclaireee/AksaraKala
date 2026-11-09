"""Ambience beds: seamless stereo loops built from layered noise and event sprinkles. No melodic content."""
import numpy as np
import inst as I
from dsp import SR, n_of, exp_env, lowpass, highpass, bandpass, phase_of, fade, softclip, convolve, make_ir

DUR = 24.0
XF = 3.0


def _ns(r, sec):
    return r.standard_normal(n_of(sec))


def _slow(r, sec, rate, depth=1.0, floor=0.0):
    """Slowly varying 0..1 control (lowpassed noise)."""
    x = lowpass(_ns(r, sec), rate, 2)
    x = x / (np.abs(x).max() + 1e-9)
    return floor + (1 - floor) * (0.5 + 0.5 * x * depth)


def wind(r, sec, cut=500, gust=0.25, level=1.0, hp=60):
    x = lowpass(_ns(r, sec), cut, 2)
    x = highpass(x, hp, 1)
    return x * _slow(r, sec, gust, 1.0, 0.25) * level


def leaves(r, sec, level=1.0):
    x = bandpass(_ns(r, sec), 2500, 9000, 1)
    return x * _slow(r, sec, 0.35, 1.0, 0.05) ** 2 * level * 0.5


def _put(y, sig, t):
    a = n_of(t)
    m = min(len(sig), len(y) - a)
    if m > 0 and a >= 0:
        y[a:a + m] += sig[:m]


def birds(r, sec, density=0.35, lo=2200, hi=5200, level=1.0):
    y = np.zeros(n_of(sec))
    t = r.uniform(0.5, 2.5)
    while t < sec - 1.0:
        f0 = r.uniform(lo, hi)
        k = r.integers(2, 6)
        for i in range(k):
            d = r.uniform(0.05, 0.14)
            n = n_of(d)
            tt_ = np.arange(n) / SR
            f = f0 * (1 + r.uniform(-0.25, 0.35) * tt_ / d) * (1 + 0.04 * i)
            c = np.sin(phase_of(f)) * np.sin(np.pi * tt_ / d) ** 1.5
            _put(y, c * r.uniform(0.3, 0.7), t + i * (d + r.uniform(0.04, 0.09)))
        t += r.exponential(1.0 / density) + 1.0
    return y * level * 0.5


def crickets(r, sec, f=4300, rate=60.0, level=1.0, n_voices=5):
    y = np.zeros(n_of(sec))
    t_ = np.arange(n_of(sec)) / SR
    for v in range(n_voices):
        fv = f * r.uniform(0.9, 1.12)
        rv = rate * r.uniform(0.85, 1.2)
        gate = (np.sin(2 * np.pi * rv * t_ + r.uniform(0, 6.28)) > 0.2).astype(float)
        group = (np.sin(2 * np.pi * r.uniform(1.2, 2.2) * t_ + r.uniform(0, 6.28)) > 0.1).astype(float)
        slow = _slow(r, sec, 0.15, 1.0, 0.0) > 0.35
        carrier = np.sin(2 * np.pi * fv * t_) + 0.3 * np.sin(2 * np.pi * fv * 2 * t_)
        env = lowpass(gate * group * slow, 400, 1)
        y += carrier * env * r.uniform(0.5, 1.0) / n_voices
    return y * level * 0.55


def frogs(r, sec, density=0.7, f=420, level=1.0):
    y = np.zeros(n_of(sec))
    t = r.uniform(0.1, 1.0)
    while t < sec - 0.8:
        k = r.integers(3, 8)
        ff = f * r.uniform(0.7, 1.5)
        for i in range(k):
            n = n_of(0.07)
            tt_ = np.arange(n) / SR
            s = np.sin(phase_of(ff * (1 + 0.6 * tt_ / 0.07))) * np.exp(-tt_ / 0.03)
            s += 0.5 * np.sin(phase_of(2 * ff * (1 + 0.6 * tt_ / 0.07))) * np.exp(-tt_ / 0.02)
            _put(y, s * (1 - 0.06 * i) * 0.5, t + i * 0.085)
        t += r.exponential(1.0 / density) + 0.8
    return y * level * 0.6


def owl(r, sec, n_hoots=1, level=1.0):
    y = np.zeros(n_of(sec))
    for _ in range(n_hoots):
        t = r.uniform(2, sec - 4)
        for i, f in enumerate((330, 280)):
            n = n_of(0.45)
            tt_ = np.arange(n) / SR
            s = (np.sin(phase_of(np.full(n, f) * (1 - 0.03 * tt_))) + 0.2 * np.sin(phase_of(np.full(n, f * 2.0)))) * np.sin(np.pi * tt_ / 0.45) ** 2
            _put(y, s * 0.3, t + i * 0.62)
    return y * level


def drips(r, sec, rate=0.35, level=1.0, f=(1100, 2400), tail=1.4):
    y = np.zeros(n_of(sec))
    t = r.uniform(0.2, 1.5)
    ir = make_ir(tail, seed=int(r.integers(1, 99)), stereo=False)[0]
    while t < sec - 1.5:
        n = n_of(0.12)
        tt_ = np.arange(n) / SR
        fz = r.uniform(*f)
        s = np.sin(phase_of(fz * (1 + 0.9 * np.exp(-tt_ / 0.02)))) * np.exp(-tt_ / 0.03)
        _put(y, s * r.uniform(0.3, 0.8), t)
        t += r.exponential(1.0 / rate) + 0.5
    w = convolve(y, ir)[: len(y)]
    return (y * 0.5 + w * 3.0) * level


def waves(r, sec, period=9.0, level=1.0):
    n = n_of(sec)
    t = np.arange(n) / SR
    ph = (t / period + r.uniform(0, 1)) % 1.0
    swell = np.exp(-0.5 * ((ph - 0.45) / 0.18) ** 2) * 0.85 + 0.15
    body = lowpass(_ns(r, sec), 1200, 1) * swell
    foam = highpass(_ns(r, sec), 2500, 1) * np.exp(-0.5 * ((ph - 0.55) / 0.1) ** 2) * 0.35
    wash = lowpass(_ns(r, sec), 5000, 1) * (0.3 + 0.7 * np.exp(-0.5 * ((ph - 0.7) / 0.15) ** 2)) * 0.2
    return (body + foam + wash) * level


def stream(r, sec, level=1.0):
    x = bandpass(_ns(r, sec), 700, 5000, 1) * (0.55 + 0.45 * _slow(r, sec, 12.0, 1.0, 0.0))
    y = np.zeros(n_of(sec))
    t = 0.1
    while t < sec - 0.3:
        n = n_of(0.08)
        tt_ = np.arange(n) / SR
        f0 = r.uniform(500, 1400)
        s = np.sin(phase_of(f0 * (1 + 1.5 * tt_ / 0.08))) * np.exp(-tt_ / 0.025)
        _put(y, s * r.uniform(0.05, 0.2), t)
        t += r.exponential(0.07)
    return (x * 0.7 + y) * level


def rumble(r, sec, level=1.0, cut=90):
    return softclip(lowpass(_ns(r, sec), cut, 3) * 6, 1.2) * _slow(r, sec, 0.3, 1.0, 0.5) * level * 0.5


def steam(r, sec, level=1.0):
    g = _slow(r, sec, 0.4, 1.0, 0.0) ** 3
    return highpass(_ns(r, sec), 2500, 1) * g * level * 0.6


def crackle(r, sec, rate=18.0, level=1.0):
    y = np.zeros(n_of(sec))
    t = 0.0
    while t < sec - 0.1:
        n = n_of(r.uniform(0.004, 0.03))
        c = bandpass(_ns(r, n / SR), 800, 7000, 1) * np.exp(-np.arange(n) / SR / r.uniform(0.002, 0.012))
        _put(y, c * r.uniform(0.2, 1.0), t)
        t += r.exponential(1.0 / rate)
    return y * level


def ticks(r, sec, bpm=60, level=1.0, n_clocks=3):
    y = np.zeros(n_of(sec))
    for c in range(n_clocks):
        per = 60.0 / (bpm * r.uniform(0.86, 1.16))
        f = r.uniform(1400, 2400)
        t = r.uniform(0, per)
        pan = r.uniform(-1, 1)
        while t < sec - 0.2:
            _put(y, I.tick(f, 0.7) * r.uniform(0.5, 1.0) * 1.2, t)
            t += per
    return y * level


def drone(r, sec, f=55.0, level=1.0, kind="drone"):
    base = I.pad(f, sec, 0.8, kind, att=1.0, rel=0.1)
    return base[: n_of(sec)] * level * 6


def crowd(r, sec, level=1.0, voices=14):
    y = np.zeros(n_of(sec))
    for v in range(voices):
        f0 = r.uniform(95, 260)
        n = n_of(sec)
        t_ = np.arange(n) / SR
        ph = phase_of(f0 * (1 + 0.05 * np.sin(2 * np.pi * r.uniform(0.2, 0.6) * t_ + r.uniform(0, 6))))
        buzz = sum(np.sin(h * ph) / h for h in range(1, 20))
        formant = bandpass(buzz, r.uniform(500, 900), r.uniform(1400, 2600), 2)
        syl = (np.sin(2 * np.pi * r.uniform(2.5, 4.5) * t_ + r.uniform(0, 6)) + np.sin(2 * np.pi * r.uniform(0.3, 0.9) * t_ + r.uniform(0, 6)) * 1.3)
        gate = np.clip(syl, 0, None) * (_slow(r, sec, 0.8, 1.0, 0.0) > 0.45)
        y += formant * lowpass(gate, 12, 1)
    y += bandpass(_ns(r, sec), 300, 3000, 1) * 0.04
    return y / voices * level * 3.0


def clinks(r, sec, rate=0.4, level=1.0):
    y = np.zeros(n_of(sec))
    t = r.uniform(0.2, 1)
    while t < sec - 1:
        f = r.uniform(1800, 4200)
        _put(y, I.bell(f, 0.25, r.uniform(0.2, 0.5))[: n_of(0.5)] * 0.18, t)
        t += r.exponential(1.0 / rate) + 0.3
    return y * level


def chimes(r, sec, rate=0.25, level=1.0):
    """Bamboo / bell chimes stirred by wind."""
    y = np.zeros(n_of(sec))
    t = r.uniform(0.3, 2)
    notes = (880, 1046, 1175, 1397, 1568)
    while t < sec - 2:
        for k in range(r.integers(1, 4)):
            f = notes[r.integers(0, len(notes))]
            _put(y, I.bell(f, 1.2, r.uniform(0.2, 0.5))[: n_of(1.6)] * 0.25, t + k * r.uniform(0.07, 0.2))
        t += r.exponential(1.0 / rate) + 1.2
    return y * level


def hum(r, sec, f=110.0, level=1.0):
    n = n_of(sec)
    t = np.arange(n) / SR
    y = sum(np.sin(2 * np.pi * f * k * t + r.uniform(0, 6)) / k * (0.7 + 0.3 * np.sin(2 * np.pi * r.uniform(0.05, 0.2) * t)) for k in (1, 2, 3, 5))
    return y * 0.2 * level


def whispers(r, sec, level=1.0):
    n = n_of(sec)
    g = _slow(r, sec, 0.5, 1.0, 0.0) ** 2
    w = bandpass(_ns(r, sec), 1200, 3600, 2) + 0.6 * bandpass(_ns(r, sec), 400, 1100, 2)
    return w * g * level * 0.5


def _loopify(x):
    n = len(x)
    xf = n_of(XF)
    body = x[: n - xf].copy()
    a = np.linspace(0, 1, xf)
    body[:xf] = body[:xf] * np.sin(a * np.pi / 2) + x[n - xf:] * np.cos(a * np.pi / 2)
    return body


def bed(fn, seed):
    r = np.random.default_rng(seed)
    return _loopify(fn(r, DUR + XF))


BEDS = {}


def _reg(name):
    def d(f):
        BEDS[name] = f
        return f
    return d


@_reg("forest_day")
def _(r, s):
    return wind(r, s, 450, 0.2, 0.55) + leaves(r, s, 0.5) + birds(r, s, 0.5, level=0.7) + crickets(r, s, 5200, 40, 0.07, 2)


@_reg("forest_night")
def _(r, s):
    return wind(r, s, 350, 0.15, 0.4) + crickets(r, s, 4300, 62, 0.75, 6) + frogs(r, s, 0.35, 380, 0.5) + owl(r, s, 1, 0.8) + leaves(r, s, 0.15)


@_reg("village")
def _(r, s):
    return wind(r, s, 500, 0.2, 0.45) + birds(r, s, 0.35, level=0.55) + chimes(r, s, 0.22, 0.4) + crickets(r, s, 5000, 38, 0.06, 2) + leaves(r, s, 0.25)


@_reg("market")
def _(r, s):
    return crowd(r, s, 1.0, 16) + clinks(r, s, 0.6, 0.6) + wind(r, s, 700, 0.2, 0.15) + birds(r, s, 0.2, level=0.25)


@_reg("river")
def _(r, s):
    return stream(r, s, 0.9) + wind(r, s, 400, 0.2, 0.3) + birds(r, s, 0.2, level=0.35) + leaves(r, s, 0.25)


@_reg("sea")
def _(r, s):
    return waves(r, s, 9.0, 1.0) + wind(r, s, 800, 0.25, 0.35) + birds(r, s, 0.12, 1800, 3200, 0.2)


@_reg("cave")
def _(r, s):
    return drips(r, s, 0.4, 0.8) + hum(r, s, 55.0, 0.5) + rumble(r, s, 0.35, 70) + wind(r, s, 250, 0.2, 0.25)


@_reg("crater")
def _(r, s):
    return rumble(r, s, 1.0, 80) + steam(r, s, 0.6) + crackle(r, s, 7, 0.35) + wind(r, s, 600, 0.3, 0.4)


@_reg("desert")
def _(r, s):
    return wind(r, s, 1400, 0.3, 0.7, 150) + highpass(wind(r, s, 3000, 0.4, 0.4), 800, 1) + hum(r, s, 73.0, 0.12)


@_reg("swamp")
def _(r, s):
    return frogs(r, s, 1.2, 330, 0.9) + crickets(r, s, 4800, 55, 0.5, 5) + stream(r, s, 0.25) + wind(r, s, 300, 0.15, 0.25)


@_reg("ruins")
def _(r, s):
    return wind(r, s, 400, 0.15, 0.45) + hum(r, s, 98.0, 0.4) + chimes(r, s, 0.1, 0.3) + crickets(r, s, 4700, 45, 0.18, 3)


@_reg("graveyard")
def _(r, s):
    return wind(r, s, 500, 0.15, 0.6) + whispers(r, s, 0.55) + hum(r, s, 65.0, 0.35) + owl(r, s, 1, 0.5) + crackle(r, s, 3, 0.15)


@_reg("kala")
def _(r, s):
    return ticks(r, s, 60, 0.55, 4) + hum(r, s, 41.0, 0.8) + whispers(r, s, 0.25) + drone(r, s, 82.0, 0.25, "drone")


@_reg("palace")
def _(r, s):
    return hum(r, s, 87.0, 0.5) + waves(r, s, 11.0, 0.35) + chimes(r, s, 0.12, 0.3) + drips(r, s, 0.2, 0.3)


@_reg("prison")
def _(r, s):
    return drips(r, s, 0.3, 0.7) + rumble(r, s, 0.3, 60) + wind(r, s, 300, 0.12, 0.2) + clinks(r, s, 0.08, 0.3)


@_reg("kelir")
def _(r, s):
    return crackle(r, s, 5, 0.18) + hum(r, s, 73.0, 0.4) + wind(r, s, 300, 0.12, 0.25) + chimes(r, s, 0.07, 0.2)


@_reg("forge")
def _(r, s):
    return crackle(r, s, 28, 0.7) + rumble(r, s, 0.5, 110) + wind(r, s, 500, 0.2, 0.2)
