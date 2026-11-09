"""DSP core for the Aksara Kala audio generator (numpy only).

Everything is mono float arrays at SR; `Mix` collects voices into a stereo bus with a reverb send.
Filters are zero-phase FFT filters (fine for offline rendering).
"""
import numpy as np

SR = 32000
RNG = np.random.default_rng(7)


def n_of(sec):
    return int(round(sec * SR))


def tt(sec):
    return np.arange(n_of(sec)) / SR


def noise(sec, rng=None):
    r = rng or RNG
    return r.standard_normal(n_of(sec))


def db(x):
    return 10 ** (x / 20.0)


def exp_env(n, t60):
    """Exponential decay reaching -60 dB after t60 seconds."""
    t = np.arange(n) / SR
    return np.exp(-6.9078 * t / max(t60, 1e-3))


def adsr(n, a=0.01, d=0.1, s=0.7, r=0.1):
    a_n, d_n, r_n = n_of(a), n_of(d), n_of(r)
    a_n = min(a_n, n)
    out = np.ones(n) * s
    if a_n > 0:
        out[:a_n] = np.linspace(0, 1, a_n, endpoint=False) ** 1.5
    d_end = min(n, a_n + d_n)
    if d_end > a_n:
        out[a_n:d_end] = np.linspace(1, s, d_end - a_n)
    if r_n > 0 and n > r_n:
        out[-r_n:] *= np.linspace(1, 0, r_n)
    return out


def fade(x, fin=0.003, fout=0.01):
    x = x.copy()
    a, b = min(n_of(fin), len(x)), min(n_of(fout), len(x))
    if a:
        x[:a] *= np.linspace(0, 1, a)
    if b:
        x[-b:] *= np.linspace(1, 0, b)
    return x


def spectral_filter(x, curve):
    """Apply magnitude response curve(freq_array)->gain, zero phase."""
    n = len(x)
    size = 1 << int(np.ceil(np.log2(max(n, 2) + 1)))
    spec = np.fft.rfft(x, size)
    f = np.fft.rfftfreq(size, 1.0 / SR)
    spec *= curve(f)
    return np.fft.irfft(spec, size)[:n]


def lowpass(x, fc, order=2):
    return spectral_filter(x, lambda f: 1.0 / np.sqrt(1.0 + (f / fc) ** (2 * order)))


def highpass(x, fc, order=2):
    return spectral_filter(x, lambda f: 1.0 / np.sqrt(1.0 + (fc / np.maximum(f, 1e-3)) ** (2 * order)))


def bandpass(x, lo, hi, order=2):
    return highpass(lowpass(x, hi, order), lo, order)


def peak(x, fc, q=2.0, gain=3.0):
    """Resonant bump of `gain` (linear) at fc with quality q."""
    def c(f):
        z = (f - fc) / (fc / q)
        return 1.0 + (gain - 1.0) * np.exp(-0.5 * z * z)
    return spectral_filter(x, c)


def phase_of(freq):
    """freq: scalar or array (Hz per sample) -> phase in radians."""
    return 2 * np.pi * np.cumsum(freq) / SR


def sine(freq, n, ph0=0.0):
    f = np.full(n, freq, dtype=float) if np.isscalar(freq) else freq
    return np.sin(phase_of(f) + ph0)


def lfo(rate, n, depth=1.0, ph0=0.0):
    return depth * np.sin(2 * np.pi * rate * np.arange(n) / SR + ph0)


def softclip(x, drive=1.0):
    return np.tanh(x * drive) / np.tanh(drive)


def delay(x, sec, fb=0.35, mix=0.3, taps=3, tone=3500):
    out = x.copy()
    d = n_of(sec)
    cur = x
    for i in range(taps):
        cur = lowpass(np.concatenate([np.zeros(d), cur])[: len(x)], tone, 1) * fb
        out = out + cur * mix
    return out


def smooth_env(x, win_sec=0.02):
    n = max(1, n_of(win_sec))
    k = np.ones(n) / n
    return np.sqrt(np.convolve(x * x, k, mode="same") + 1e-12)


def compress(x, thresh_db=-18.0, ratio=3.0, attack=0.01, release=0.15, makeup_db=0.0):
    env = smooth_env(x, attack + release * 0.2)
    lvl = 20 * np.log10(env + 1e-9)
    over = np.maximum(lvl - thresh_db, 0)
    gain_db = -over * (1 - 1 / ratio)
    k = np.ones(max(1, n_of(release * 0.3))) / max(1, n_of(release * 0.3))
    gain_db = np.convolve(gain_db, k, mode="same")
    return x * db(gain_db + makeup_db)


def make_ir(rt60=2.0, pre=0.012, damp=5500, seed=1, early=True, stereo=True):
    """Synthetic hall impulse response (2 channels)."""
    r = np.random.default_rng(seed)
    n = n_of(rt60 * 1.15 + pre)
    chans = []
    for c in range(2 if stereo else 1):
        h = r.standard_normal(n)
        t = np.arange(n) / SR
        # darker tail: blend of bright (fast decay) and dark (slow decay) bands
        bright = highpass(h, 1500, 1) * np.exp(-6.9 * t / (rt60 * 0.55))
        dark = lowpass(h, damp * 0.5, 1) * np.exp(-6.9 * t / rt60)
        h = bright * 0.5 + dark
        h[: n_of(pre)] = 0
        if early:
            for k in range(14):
                p = n_of(pre + r.uniform(0.004, 0.09))
                if p < n:
                    h[p] += r.uniform(-1, 1) * 2.2
        h *= np.minimum(1.0, t / 0.02 + 0.0)
        chans.append(h / np.sqrt(np.sum(h * h)))
    return chans


def convolve(x, ir):
    n = len(x) + len(ir) - 1
    size = 1 << int(np.ceil(np.log2(n)))
    return np.fft.irfft(np.fft.rfft(x, size) * np.fft.rfft(ir, size), size)[:n]


class Mix:
    """Stereo mix bus with a reverb send. Times in seconds."""

    def __init__(self, length, tail=3.0):
        self.length = length
        self.tail = tail
        n = n_of(length + tail)
        self.L = np.zeros(n)
        self.R = np.zeros(n)
        self.send = np.zeros(n)
        self.send2 = np.zeros(n)   # long hall (gongs, pads)
        self.t_off = 0.0           # seconds added to every placement (lets one arrangement run twice back to back)

    def add(self, sig, t, gain=1.0, pan=0.0, rev=0.2, rev2=0.0):
        a = n_of(t + self.t_off)
        if a < 0:
            sig = sig[-a:]
            a = 0
        if a >= len(self.L) or len(sig) == 0:
            return
        b = min(len(self.L), a + len(sig))
        s = sig[: b - a] * gain
        ang = (pan + 1) * np.pi / 4
        self.L[a:b] += s * np.cos(ang)
        self.R[a:b] += s * np.sin(ang)
        if rev:
            self.send[a:b] += s * rev
        if rev2:
            self.send2[a:b] += s * rev2

    def render(self, loop=True, rt=(1.3, 3.2), wet=1.0, seed=3):
        ir1 = make_ir(rt[0], seed=seed)
        ir2 = make_ir(rt[1], pre=0.03, damp=3500, seed=seed + 11)
        n = len(self.L)
        wl = convolve(self.send, ir1[0])[:n] + convolve(self.send2, ir2[0])[:n]
        wr = convolve(self.send, ir1[1])[:n] + convolve(self.send2, ir2[1])[:n]
        L = self.L + wl * wet
        R = self.R + wr * wet
        out = np.stack([L, R], axis=1)
        if loop:   # fold the tail onto the start so the loop is seamless
            n0 = n_of(self.length)
            body = out[:n0].copy()
            tail = out[n0:]
            body[: len(tail)] += tail[: n0]
            return body
        return out


def master(st, rms_db=-19.0, ceiling_db=-2.2, glue=True):
    """Gentle glue compression, normalise to an RMS target, soft limit."""
    x = st.copy()
    x -= x.mean(axis=0)
    if glue:
        mono = x.mean(axis=1)
        env = smooth_env(mono, 0.05)
        g = db(-np.maximum(20 * np.log10(env + 1e-9) + 16, 0) * 0.45)
        x *= g[:, None]
    rms = np.sqrt(np.mean(x ** 2))
    x *= db(rms_db) / max(rms, 1e-9)
    c = db(ceiling_db)
    x = np.tanh(x / c * 0.9) * c / np.tanh(0.9)
    return x


def master_mono(x, peak_db=-3.0):
    x = x - x.mean()
    p = np.max(np.abs(x)) + 1e-9
    return x * db(peak_db) / p


def write_ogg(path, st, q=2.0):
    """Encode via ffmpeg (libvorbis). st: float array (n,) or (n,2) in -1..1."""
    import subprocess
    st = np.atleast_2d(st.T).T if st.ndim == 1 else st
    ch = st.shape[1]
    pcm = (np.clip(st, -1, 1) * 32767).astype("<i2").tobytes()
    cmd = ["ffmpeg", "-y", "-loglevel", "error", "-f", "s16le", "-ar", str(SR), "-ac", str(ch), "-i", "-",
           "-c:a", "libvorbis", "-q:a", str(q), str(path)]
    subprocess.run(cmd, input=pcm, check=True)
