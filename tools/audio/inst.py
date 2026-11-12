"""Instruments: each returns a mono float array (note + natural ring-out)."""
import numpy as np
import sampler as S
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
    shim = highpass(S.resample(S.hit("gong_hit_f"), float(np.clip(f / 58.0, 0.7, 1.5)), n), 500, 1)   # real metal on top
    y[:len(shim)] += shim * 0.5 * vel
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

# ---------------------------------------------------------------------------------------------------------------
# winds, strings, pads
# ---------------------------------------------------------------------------------------------------------------

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
    """Sustained pad. kind: strings (recorded sections) | choir | drone (synthesised)."""
    if kind == "strings":
        sec = "strings_vc" if f < 185 else ("strings_vla" if f < 370 else "strings_vln")
        return S.note(S.bank(sec), f, dur, vel, 0.15, att=att * 0.6, rel=rel)
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


# ---------------------------------------------------------------------------------------------------------------
# recorded instruments (sampler.py). Gains match the levels of the synth voices they replaced.
# ---------------------------------------------------------------------------------------------------------------

def gender(f, dur=0.8, vel=0.8, **_):
    """Vibraphone, soft mallets: the nearest recorded relative of the gender's tube-resonated bars."""
    return S.note(S.bank("vibes", False), f, max(dur, 0.5), vel, 0.6, ring=2.8)


_KENDANG = {"dung": ("Tumba_HitN_v3", 1.0), "tung": ("Conga_HitN_v2", 1.0), "ket": ("Conga_HitFM_v2", 0.6),
            "tak": ("Quinto_HitFM1_v2", 0.8), "de": ("Quinto_HitN_v2", 1.0), "ketipung": ("Quinto_HitN_v2", 1.0)}


def kendang(kind="dung", vel=0.8, **_):
    """Hand drums (conga family) standing in for the kendang; two round-robin takes per stroke. Table: stem, level."""
    stem, lvl = _KENDANG[kind]
    x = S.hit("%s_rr%d_Sum" % (stem, RNG.integers(1, 3)))
    y = S.resample(x, (1.18 if kind == "ketipung" else 1.0) * RNG.uniform(0.985, 1.015), n_of(0.7))
    return fade(y * lvl * (0.4 + 0.6 * vel), 0.0005, 0.05)


def ketipung(vel=0.8, **_):
    return kendang("ketipung", vel)


def bedug(vel=0.9, f=64.0, dec=0.9, **_):
    """Big war/temple drum: a large mallet drum over an orchestral bass drum."""
    n = n_of(dec * 1.6)
    r = float(np.sqrt(f / 64.0))
    y = S.resample(S.hit("EthnicLargeMallet_hit_ff_1" if vel >= 1.0 else "EthnicLargeMallet_hit_f_1"), r, n)
    b = S.resample(S.hit("bassdrum_hit_f"), r, n)
    k = min(len(y), len(b))
    y = y[:k] + b[:k] * 0.6
    y *= np.exp(-3.0 * np.arange(len(y)) / n)
    return fade(y * 0.75 * (0.7 + 0.5 * vel), 0.0005, 0.05)


def suling(f, dur=1.0, vel=0.7, **_):
    """Recorder, with the concert flute taking over above its range."""
    rec = S.bank("recorder")
    pool = rec + [s for s in S.bank("flute") if s[0] > rec[-1][0] * 1.05]
    return S.note(pool, f, dur, vel, 0.28, att=0.03, rel=0.18)


def rebab(f, dur=1.0, vel=0.7, **_):
    """Solo violin, vibrato."""
    return S.note(S.bank("violin"), f, dur, vel, 0.24, att=0.06, rel=0.2)


def tarompet(f, dur=0.8, vel=0.8, **_):
    """Oboe: the double reed of the orchestra for the tarompet's lines."""
    return S.note(S.bank("oboe"), f, dur, vel, 0.22, att=0.02, rel=0.12)


def kacapi(f, dur=1.0, vel=0.8, **_):
    """Plucked zither (dan tranh)."""
    return S.note(S.bank("zither", False), f, max(dur, 0.4), vel, 0.9, ring=1.6)


def harp(f, dur=1.0, vel=0.8, **_):
    return S.note(S.bank("harp", False), f, max(dur, 0.4), vel, 0.65, ring=2.0)


def strings(f, dur=1.0, vel=0.7, **_):
    """String section playing a line (pad() holds chords)."""
    return pad(f, dur, vel, "strings", att=0.12, rel=0.35)


def bass(f, dur=0.6, vel=0.8, kind="pluck", **_):
    """Contrabass: pizzicato or bowed."""
    if kind == "bow":
        return S.note(S.bank("bass_arco"), f, dur, vel, 0.17, att=0.08, rel=0.25)
    return S.note(S.bank("bass_pizz", False), f, dur, vel, 0.75, ring=0.5)
