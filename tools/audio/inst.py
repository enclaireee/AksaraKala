"""Instruments: each returns a mono float array (note + natural ring-out)."""
import numpy as np
from dsp import (SR, RNG, n_of, tt, noise, exp_env, adsr, fade, lowpass, highpass, bandpass, peak, phase_of, sine,
                 lfo, softclip)


def _click(ms=3, level=0.3, hp=2500):
    n = max(8, n_of(ms / 1000))
    c = highpass(RNG.standard_normal(n), hp, 1) * np.linspace(1, 0, n) ** 2
    return c * level


def _partials(f, n, parts, vel, t60, beat=0.0, bloom=0.0):
    """Inharmonic additive voice. parts: [(ratio, amp)], t60: seconds for the fundamental; higher partials die faster."""
    t = np.arange(n) / SR
    out = np.zeros(n)
    for i, (r, a) in enumerate(parts):
        fr = f * r
        if fr > SR * 0.46:
            continue
        dec = np.exp(-6.9 * t / (t60 / (1 + 0.55 * i)))
        ph = RNG.uniform(0, 2 * np.pi)
        s = np.sin(2 * np.pi * fr * t + ph)
        if beat:
            s = 0.5 * s + 0.5 * np.sin(2 * np.pi * (fr + beat * (1 + 0.15 * i)) * t + ph)
        env = dec
        if bloom and i > 0:
            env = env * (1 - np.exp(-t / (bloom * (0.6 + 0.2 * i))))
        out += a * (0.55 + 0.45 * vel) ** (1 + 0.35 * i) * s * env
    return out


# ---------------------------------------------------------------------------------------------------------------
# gamelan percussion
# ---------------------------------------------------------------------------------------------------------------

def saron(f, dur=0.5, vel=0.8, beat=0.7, **_):
    n = n_of(max(dur, 0.3) + 1.8)
    y = _partials(f, n, [(1, 1.0), (2.76, 0.42), (5.40, 0.2), (8.93, 0.09)], vel, 1.6, beat=beat)
    y[: n_of(0.004)] += _click(4, 0.25 * vel)[: n_of(0.004)]
    return fade(y * 0.55, 0.0015, 0.05)


def demung(f, dur=0.6, vel=0.8, beat=0.5, **_):
    n = n_of(max(dur, 0.4) + 2.6)
    y = _partials(f, n, [(1, 1.0), (2.76, 0.33), (5.40, 0.12)], vel, 2.6, beat=beat)
    y[: n_of(0.005)] += _click(5, 0.18 * vel, 1500)[: n_of(0.005)]
    return fade(y * 0.6, 0.002, 0.08)


def peking(f, dur=0.25, vel=0.8, beat=0.9, **_):
    n = n_of(max(dur, 0.2) + 0.9)
    y = _partials(f, n, [(1, 1.0), (2.76, 0.55), (5.40, 0.3), (8.93, 0.16)], vel, 0.7, beat=beat)
    y[: n_of(0.003)] += _click(3, 0.3 * vel, 3500)[: n_of(0.003)]
    return fade(y * 0.42, 0.001, 0.03)


def gender(f, dur=0.8, vel=0.8, **_):
    """Metallophone with tube resonators: softer attack, sustained, gently pulsing."""
    n = n_of(max(dur, 0.5) + 2.8)
    t = np.arange(n) / SR
    y = _partials(f, n, [(1, 1.0), (2.0, 0.38), (3.01, 0.17), (4.1, 0.08)], vel, 3.0, beat=0.6)
    y *= 1 + 0.12 * np.sin(2 * np.pi * 5.7 * t)
    y *= 1 - np.exp(-t / 0.004)
    return fade(y * 0.5, 0.002, 0.1)


def bonang(f, dur=0.4, vel=0.8, **_):
    n = n_of(max(dur, 0.3) + 1.3)
    y = _partials(f, n, [(1, 1.0), (2.37, 0.55), (4.09, 0.3), (6.5, 0.14)], vel, 1.1, beat=1.1)
    y[: n_of(0.004)] += _click(4, 0.3 * vel, 2800)[: n_of(0.004)]
    return fade(y * 0.5, 0.001, 0.05)


def kenong(f, dur=0.5, vel=0.8, **_):
    n = n_of(2.6)
    y = _partials(f, n, [(1, 1.0), (1.58, 0.45), (2.52, 0.28), (3.4, 0.12)], vel, 1.9, beat=0.5)
    y[: n_of(0.005)] += _click(5, 0.25 * vel, 1200)[: n_of(0.005)]
    return fade(y * 0.7, 0.001, 0.06)


def kempul(f, dur=0.5, vel=0.8, **_):
    n = n_of(3.4)
    y = _partials(f, n, [(1, 1.0), (1.9, 0.35), (2.9, 0.15)], vel, 2.6, beat=0.4)
    return fade(y * 0.7, 0.004, 0.08)


def gong(f=58.0, dur=6.0, vel=0.9, **_):
    """Gong ageng: swell bloom, slow beating, long ring."""
    n = n_of(dur + 2.0)
    t = np.arange(n) / SR
    parts = [(1, 1.0), (1.51, 0.5), (2.0, 0.62), (2.52, 0.3), (2.99, 0.34), (4.07, 0.2), (5.4, 0.1), (7.1, 0.05)]
    y = np.zeros(n)
    for i, (r, a) in enumerate(parts):
        fr = f * r * (1 + 0.012 * np.exp(-t / 0.15))
        dec = np.exp(-6.9 * t / (dur / (1 + 0.4 * i)))
        bloom = 1.0 if i == 0 else (1 - np.exp(-t / (0.12 + 0.07 * i)))
        s = np.sin(phase_of(fr)) + 0.7 * np.sin(2 * np.pi * (f * r + 0.35 + 0.18 * i) * t)
        y += a * (0.5 + 0.5 * vel) ** (1 + 0.3 * i) * s * dec * bloom
    m = n_of(0.4)
    y[:m] += lowpass(noise(0.4), 400, 1)[:m] * np.exp(-t[:m] / 0.05) * 0.4
    return fade(y * 0.34, 0.002, 0.2)


def kethuk(f=520.0, vel=0.8, **_):
    n = n_of(0.22)
    y = _partials(f, n, [(1, 1.0), (2.3, 0.4), (3.7, 0.2)], vel, 0.12)
    return fade(y * 0.6, 0.0005, 0.01)


def kempyang(f=1400.0, vel=0.8, **_):
    n = n_of(0.7)
    y = _partials(f, n, [(1, 1.0), (2.4, 0.4), (4.0, 0.15)], vel, 0.45, beat=2.0)
    return fade(y * 0.35, 0.0005, 0.03)


def kecer(vel=0.8, **_):
    n = n_of(0.35)
    y = bandpass(noise(0.35), 4500, 12500, 2) * exp_env(n, 0.22)
    y += _partials(3100, n, [(1, 0.5), (1.71, 0.4), (2.9, 0.3)], vel, 0.2)
    return fade(y * 0.12 * (0.5 + vel), 0.0005, 0.02)


# ---------------------------------------------------------------------------------------------------------------
# drums
# ---------------------------------------------------------------------------------------------------------------

def _drum(f0, f1, sweep_t, dec, body_noise=0.25, vel=0.8, n_sec=None, nlp=900):
    n = n_of(n_sec or dec * 2.2)
    t = np.arange(n) / SR
    fr = f1 + (f0 - f1) * np.exp(-t / sweep_t)
    y = np.sin(phase_of(fr)) * np.exp(-6.9 * t / dec)
    y += 0.25 * np.sin(phase_of(fr * 2.3)) * np.exp(-6.9 * t / (dec * 0.4))
    nz = lowpass(noise(n / SR), nlp, 1) * np.exp(-t / 0.012) * body_noise
    return fade((y + nz) * (0.4 + 0.6 * vel), 0.0008, 0.03)


def kendang(kind="dung", vel=0.8, **_):
    if kind == "dung":   # open low
        return _drum(190, 112, 0.05, 0.32, 0.35, vel)
    if kind == "tung":   # open mid
        return _drum(300, 205, 0.04, 0.22, 0.3, vel)
    if kind == "ket":    # muted
        return _drum(250, 180, 0.02, 0.07, 0.5, vel)
    if kind == "tak":    # slap
        n = n_of(0.16)
        t = np.arange(n) / SR
        y = bandpass(noise(0.16), 1700, 5200, 2) * np.exp(-t / 0.035) * 0.8
        y += np.sin(phase_of(np.full(n, 520.0))) * np.exp(-t / 0.03) * 0.45
        return fade(y * (0.3 + 0.7 * vel), 0.0004, 0.02)
    if kind == "de":     # high open
        return _drum(420, 320, 0.03, 0.15, 0.3, vel)
    raise ValueError(kind)


def bedug(vel=0.9, f=64.0, dec=0.9, **_):
    """Big war/temple drum."""
    n = n_of(dec * 1.6)
    t = np.arange(n) / SR
    fr = f * (1 + 1.1 * np.exp(-t / 0.045))
    y = np.sin(phase_of(fr)) * np.exp(-6.9 * t / dec)
    y += 0.5 * np.sin(phase_of(fr * 1.58)) * np.exp(-6.9 * t / (dec * 0.35))
    y += lowpass(noise(n / SR), 500, 1) * np.exp(-t / 0.02) * 0.6
    y += 0.2 * highpass(noise(n / SR), 2000, 1) * np.exp(-t / 0.01)
    return fade(softclip(y * (0.7 + 0.5 * vel), 1.3) * 0.75, 0.0008, 0.05)


def ketipung(vel=0.8, **_):
    return _drum(330, 240, 0.03, 0.16, 0.25, vel)


# ---------------------------------------------------------------------------------------------------------------
# winds, strings, pads
# ---------------------------------------------------------------------------------------------------------------

def suling(f, dur=1.0, vel=0.7, vib=1.0, breath=1.0, scoop=1.0, **_):
    """Bamboo flute: near-sine with a little 2nd/3rd, breath, late vibrato, upward scoop."""
    n = n_of(dur + 0.25)
    t = np.arange(n) / SR
    vdepth = vib * 0.0035 * np.clip((t - 0.18) / 0.35, 0, 1)
    fr = f * (1 + vdepth * np.sin(2 * np.pi * 5.3 * t)) * (1 - 0.012 * scoop * np.exp(-t / 0.06))
    ph = phase_of(fr)
    y = np.sin(ph) + (0.18 + 0.4 * vel * vel) * np.sin(2 * ph) + 0.07 * vel * np.sin(3 * ph)
    env = adsr(n, 0.06, 0.1, 0.86, 0.16)
    env *= 1 + 0.06 * np.sin(2 * np.pi * 4.4 * t + 1)
    nz = bandpass(noise(n / SR), max(300, f * 1.3), min(f * 7, 12000), 1)
    nz *= (0.07 + 0.08 * vel) * breath * (0.6 + 0.4 * np.exp(-t / 0.12))
    y = (y + nz) * env
    return fade(y * 0.42 * (0.45 + 0.55 * vel), 0.004, 0.06)


def rebab(f, dur=1.0, vel=0.7, vib=1.0, **_):
    """Two-string bowed fiddle: slow attack, nasal formants, vibrato."""
    n = n_of(dur + 0.2)
    t = np.arange(n) / SR
    fr = f * (1 + vib * 0.006 * np.clip((t - 0.1) / 0.3, 0, 1) * np.sin(2 * np.pi * 5.0 * t))
    ph = phase_of(fr)
    y = np.zeros(n)
    for h in range(1, 18):
        if f * h > 9000:
            break
        form = 1 + 1.6 * np.exp(-0.5 * (np.log2(f * h / 1250) / 0.45) ** 2) + 0.9 * np.exp(-0.5 * (np.log2(f * h / 2500) / 0.4) ** 2)
        y += np.sin(h * ph) / h ** 0.85 * form
    bow = bandpass(noise(n / SR), 1500, 6000, 1) * 0.05
    env = adsr(n, 0.09, 0.15, 0.85, 0.18)
    return fade((y * 0.2 + bow) * env * (0.4 + 0.6 * vel), 0.01, 0.08)


def tarompet(f, dur=0.8, vel=0.8, vib=1.0, **_):
    """Sundanese double-reed: reedy, nasal, assertive. Great for combat lines."""
    n = n_of(dur + 0.15)
    t = np.arange(n) / SR
    fr = f * (1 + vib * 0.004 * np.clip((t - 0.15) / 0.3, 0, 1) * np.sin(2 * np.pi * 5.6 * t)) * (1 - 0.02 * np.exp(-t / 0.05))
    ph = phase_of(fr)
    y = np.zeros(n)
    for h in range(1, 24):
        if f * h > 10000:
            break
        form = 1 + 2.2 * np.exp(-0.5 * (np.log2(f * h / 1100) / 0.5) ** 2) + 1.4 * np.exp(-0.5 * (np.log2(f * h / 2300) / 0.4) ** 2)
        y += np.sin(h * ph + 0.3 * h) / h ** 0.7 * form
    env = adsr(n, 0.03, 0.08, 0.88, 0.1)
    y = softclip(y * 0.25, 1.4) * env
    return fade(y * 0.5 * (0.5 + 0.5 * vel), 0.003, 0.05)


def kacapi(f, dur=1.0, vel=0.8, pluck=0.3, **_):
    """Sundanese zither: bright plucked string with inharmonic overtones."""
    n = n_of(max(dur, 0.4) + 1.6)
    t = np.arange(n) / SR
    y = np.zeros(n)
    B = 0.00025
    for h in range(1, 20):
        fr = f * h * np.sqrt(1 + B * h * h)
        if fr > SR * 0.45:
            break
        a = np.sin(np.pi * h * pluck) / h ** 1.15
        dec = np.exp(-6.9 * t / (2.2 / (1 + 0.7 * (h - 1))))
        y += a * dec * np.sin(2 * np.pi * fr * t + h)
    c = _click(2, 0.3 * vel, 3000)
    y[: len(c)] += c
    y *= 0.8 + 0.5 * vel
    return fade(y * 0.55, 0.0008, 0.1)


def harp(f, dur=1.0, vel=0.8, **_):
    return kacapi(f, dur, vel, pluck=0.18)


def angklung(f, dur=0.8, vel=0.8, shake=True, **_):
    """Bamboo rattle: octave tube pair, rapid shaken taps."""
    n = n_of(dur + 0.5)
    t = np.arange(n) / SR
    y = np.zeros(n)
    taps = int(dur / 0.058) + 1 if shake else 1
    for i in range(taps):
        p = max(0, n_of(i * 0.058 + RNG.uniform(-0.004, 0.004)))
        m = min(n - p, n_of(0.35))
        if m <= 0:
            break
        tt_ = np.arange(m) / SR
        a = (1.0 - 0.45 * i / max(taps, 1)) * RNG.uniform(0.7, 1.0)
        tone = np.sin(2 * np.pi * f * tt_) + 0.55 * np.sin(2 * np.pi * 2 * f * tt_) + 0.12 * np.sin(2 * np.pi * 3.02 * f * tt_)
        y[p:p + m] += a * tone * np.exp(-tt_ / 0.11) * (1 - np.exp(-tt_ / 0.002))
    y += highpass(noise(n / SR), 3000, 1) * 0.015 * adsr(n, 0.01, 0.1, 0.7, 0.2)
    return fade(y * 0.16 * (0.4 + 0.6 * vel), 0.002, 0.15)


def pad(f, dur=4.0, vel=0.6, kind="strings", att=0.9, rel=1.3, bright=0.5, **_):
    """Sustained pad. kind: strings | choir | drone."""
    n = n_of(dur + rel)
    t = np.arange(n) / SR
    voices = [-9, -3, 3, 9] if kind != "drone" else [-5, 5]
    y = np.zeros(n)
    for c in voices:
        fr = f * 2 ** (c / 1200.0) * (1 + 0.0015 * np.sin(2 * np.pi * (0.2 + 0.07 * abs(c)) * t + c))
        ph = phase_of(fr)
        for h in range(1, 28):
            if fr[0] * h > 9000:
                break
            if kind == "choir":
                form = (np.exp(-0.5 * (np.log2(f * h / 700) / 0.35) ** 2) + 0.55 * np.exp(-0.5 * (np.log2(f * h / 1150) / 0.3) ** 2)
                        + 0.25 * np.exp(-0.5 * (np.log2(f * h / 2800) / 0.3) ** 2) + 0.08)
                a = form / h ** 0.5
            elif kind == "drone":
                a = 1.0 / h ** 1.2 * (1 if h < 8 else 0.4)
            else:
                a = 1.0 / h ** (1.5 - 0.5 * bright) * np.exp(-h / (10 + 10 * bright))
            y += a * np.sin(h * ph + 0.2 * h * c)
    if kind == "choir":
        y += 0.08 * bandpass(noise(n / SR), 600, 3500, 1)
    env = adsr(n, att, 0.3, 0.9, rel)
    return fade(y * env * 0.12 * (0.4 + 0.6 * vel), 0.01, 0.1)


def bass(f, dur=0.6, vel=0.8, kind="pluck", **_):
    """Low voice: pluck (rounded, short) or bow (sustained cello-like)."""
    n = n_of(dur + 0.3)
    t = np.arange(n) / SR
    ph = phase_of(np.full(n, f))
    if kind == "bow":
        fr = f * (1 + 0.004 * np.clip((t - 0.2) / 0.3, 0, 1) * np.sin(2 * np.pi * 4.8 * t))
        ph = phase_of(fr)
        y = sum(np.sin(h * ph) / h ** 1.1 * (1 + 1.2 * np.exp(-0.5 * (np.log2(f * h / 600) / 0.5) ** 2)) for h in range(1, 16) if f * h < 6000)
        y = y * adsr(n, 0.12, 0.2, 0.85, 0.2)
        return fade(y * 0.22 * (0.4 + 0.6 * vel), 0.01, 0.08)
    y = np.sin(ph) + 0.5 * np.sin(2 * ph) * np.exp(-t / 0.25) + 0.25 * np.sin(3 * ph) * np.exp(-t / 0.12)
    y = y * np.exp(-6.9 * t / max(dur * 1.4, 0.2))
    return fade(y * 0.55 * (0.4 + 0.6 * vel), 0.002, 0.06)


def sub_boom(f=40.0, dur=2.0, vel=1.0, **_):
    n = n_of(dur)
    t = np.arange(n) / SR
    y = np.sin(phase_of(f * (1 + 0.6 * np.exp(-t / 0.2)))) * np.exp(-6.9 * t / dur)
    return fade(y * 0.8 * vel, 0.002, 0.2)


def tick(f=1800.0, vel=0.8, **_):
    """Clock tick: tiny wooden/metal click (Kala motif)."""
    n = n_of(0.09)
    t = np.arange(n) / SR
    y = np.sin(2 * np.pi * f * t) * np.exp(-t / 0.012) + 0.5 * np.sin(2 * np.pi * f * 2.76 * t) * np.exp(-t / 0.006)
    y += highpass(noise(0.09), 3000, 1) * np.exp(-t / 0.004) * 0.4
    return fade(y * 0.35 * (0.4 + 0.6 * vel), 0.0003, 0.01)


def bell(f, dur=2.0, vel=0.8, **_):
    n = n_of(dur + 1.0)
    y = _partials(f, n, [(1, 1.0), (2.0, 0.55), (2.76, 0.4), (4.2, 0.25), (5.4, 0.18), (6.8, 0.1)], vel, dur, beat=0.8)
    return fade(y * 0.3, 0.001, 0.2)


def riser(dur=4.0, f0=200.0, f1=2400.0, vel=0.8):
    n = n_of(dur)
    t = np.arange(n) / SR
    g = (t / dur) ** 2
    y = bandpass(noise(dur), f0, f1, 2) * g
    y += np.sin(phase_of(f0 * (f1 / f0) ** (t / dur) * 0.5)) * g * 0.15
    return fade(y * 0.5 * vel, 0.01, 0.01)


def reverse(x):
    return fade(x[::-1].copy(), 0.01, 0.002)
