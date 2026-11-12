"""Sampler over the recorded multisamples in tools/audio/raw/ms (VSCO-2-CE and VCSL, both CC0).

Fetch them once:  cd tools/audio/raw && aria2c -j12 -c -i ../sources/multisamples.txt
inst.py maps the game's instrument names onto these banks; anything without a bank stays synthesised there.
"""
import functools
import glob
import os
import re
import subprocess
import numpy as np
from dsp import SR, RNG, n_of

HERE = os.path.dirname(os.path.abspath(__file__))
MS = os.path.join(HERE, "raw", "ms")
SFX = os.path.join(HERE, "..", "..", "assets", "audio", "sfx")
_SEMI = dict(C=0, D=2, E=4, F=5, G=7, A=9, B=11)


def _decode(path):
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-f", "f64le", "-ac", "1", "-ar", str(SR), "-"],
                         capture_output=True, check=True).stdout
    x = np.frombuffer(raw)
    p = np.abs(x)
    on = int(np.argmax(p > p.max() * 0.02))   # drop the silence before the attack
    return x[max(0, on - n_of(0.004)):].copy()


def _true_pitch(x, f):
    """The libraries' file names are an octave off in places: pick f/2, f or 2f by autocorrelation."""
    seg = x[n_of(0.25):n_of(0.25) + 16384]
    if len(seg) < 4096:
        return f
    seg = seg - seg.mean()
    ac = np.fft.irfft(np.abs(np.fft.rfft(seg, 2 * len(seg))) ** 2)
    cand = []
    for k in (2.0, 1.0, 0.5):   # highest first: a true pitch also correlates at its sub-octaves
        lag = SR / (f * k)
        cand.append((ac[int(lag * 0.97):int(np.ceil(lag * 1.03)) + 1].max(), k))
    top = max(v for v, _ in cand)
    return f * next(k for v, k in cand if v >= 0.85 * top)


@functools.lru_cache(None)
def bank(name, sustain=True):
    """[(pitch Hz, mono samples)] sorted by pitch. Sustained banks are level-matched by RMS, plucked ones by peak."""
    out = []
    for p in sorted(glob.glob(os.path.join(MS, name, "*.wav"))):
        m = re.search(r"(?:^|_)([A-G])(s?)(\d)_", os.path.basename(p))
        x = _decode(p)
        f = 440.0 * 2 ** ((_SEMI[m.group(1)] + len(m.group(2)) + 12 * (int(m.group(3)) - 4) - 9) / 12.0)
        ref = np.sqrt(np.mean(x[n_of(0.1):n_of(1.1)] ** 2)) if sustain else np.abs(x).max()
        out.append((_true_pitch(x, f), x / max(ref, 1e-9)))
    if not out:
        raise FileNotFoundError("no multisamples in %s (see the module docstring)" % os.path.join(MS, name))
    return sorted(out, key=lambda s: s[0])


@functools.lru_cache(None)
def hit(stem):
    """One unpitched hit from raw/ms/perc, peak 1."""
    x = _decode(os.path.join(MS, "perc", stem + ".wav"))
    return x / np.abs(x).max()


@functools.lru_cache(None)
def sfx(name):
    """A built game sound (assets/audio/sfx), so the intro score and stingers share the game's own effects."""
    p = os.path.join(SFX, name + ".wav")
    if not os.path.exists(p):
        return np.zeros(1)
    x = _decode(p)
    return x * 0.8 / np.abs(x).max()


def resample(x, ratio, n):
    # ponytail: linear interpolation, slight aliasing when pitching up; a windowed-sinc kernel if it is ever audible
    idx = np.arange(n) * ratio
    idx = idx[idx < len(x) - 1]
    i = idx.astype(int)
    fr = idx - i
    return x[i] * (1 - fr) + x[i + 1] * fr


def _loop(x, need):
    """Extend a sustained sample by repeating its middle with equal-power crossfades."""
    a, b, xf = int(len(x) * 0.3), int(len(x) * 0.85), n_of(0.3)
    out = x[:b].copy()
    w = np.sin(np.linspace(0, np.pi / 2, xf))
    while len(out) < need:
        seg = x[a:b]
        out[-xf:] = out[-xf:] * w[::-1] + seg[:xf] * w
        out = np.concatenate([out, seg[xf:]])
    return out


def note(pool, f, dur, vel, gain, att=0.0, rel=0.15, ring=0.0):
    """Play f from the nearest sample. Sustained: held for dur, then released over rel. ring > 0: a plucked note that
    is left to ring for up to that long after dur, damped."""
    f0, x = min(pool, key=lambda s: abs(np.log(s[0] / f)))
    ratio = f / f0
    n = n_of(dur + (ring or rel))
    if not ring and n * ratio + 2 > len(x):
        x = _loop(x, int(n * ratio) + 2)
    y = resample(x, ratio, n)
    n = len(y)
    if att > 0:
        k = min(n, n_of(att))
        y[:k] *= np.linspace(0, 1, k) ** 1.5
    k = min(n, n_of(ring or rel))
    if ring:
        y[n - k:] *= np.exp(-np.arange(k) / (k / 3.0))
        k = min(n, n_of(0.08))
    y[n - k:] *= np.cos(np.linspace(0, np.pi / 2, k)) ** 2
    return y * gain * (0.4 + 0.6 * vel)
