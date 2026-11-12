"""Music engine: arranges one 'theme' (scale, tempo, balungan core melody, lead) into explore / dark / combat / boss /
town stems. Explore and combat of the same theme share tempo and length so the game can crossfade between them
in sync (autoload/audio.gd keeps both playing and swaps volumes).

Notation: see theory.parse. A theme's bal is 8 bars x 4 tokens (1 token = 1 beat); lead is 8 bars x 8 tokens
(1 token = 1/2 beat). Section B (bars 9-16) repeats A shifted by `shiftB` scale steps with its last bar replaced.
"""
import numpy as np
import inst as I
from dsp import Mix, master, n_of, SR, RNG
from theory import parse, freq, SCALES

BARS = 16
BEATS = 4


def shift_line(line, k, nscale):
    out = []
    for tok in line.replace("|", " ").split():
        base = tok.rstrip("',")
        marks = tok[len(base):]
        vel = ""
        if "*" in base:
            base, vel = base.split("*")
            vel = "*" + vel
        if base.isdigit():
            n = int(base) + k
            o = (n - 1) // nscale
            d = (n - 1) % nscale + 1
            marks = marks + "'" * max(o, 0) + "," * max(-o, 0)
            tok = str(d) + marks + vel
        out.append(tok)
    return " ".join(out)


class Theme:
    def __init__(self, name, scale, root, bpm, bal, lead, shiftB=2, endB_bal=None, endB_lead=None, lead_oct=1,
                 colour="sunda", swing=0.0, answer=None):
        self.name, self.scale, self.root, self.bpm = name, scale, root, bpm
        self.bal_a, self.lead_a = bal, lead
        self.n = len(SCALES[scale])
        bb = shift_line(bal, shiftB, self.n).split()
        lb = shift_line(lead, shiftB, self.n).split()
        if endB_bal:
            bb[-4:] = endB_bal.split()
        if endB_lead:
            lb[-8:] = endB_lead.split()
        self.bal = bal.replace("|", " ").split() + bb
        self.lead = lead.replace("|", " ").split() + lb
        self.lead_oct = lead_oct
        self.colour = colour   # decides the lead / texture voices
        self.beat = 60.0 / bpm
        self.length = BARS * BEATS * self.beat
        self.answer = answer

    # helpers ------------------------------------------------------------------------------------------------
    def notes(self, toks, unit, octave=0):
        n, beat = parse(" ".join(toks), self.scale, self.root, unit, octave)
        return n

    def oc(self, lo):
        """Smallest octave shift that puts the tonic at or above `lo` Hz (keeps contours intact, unlike folding notes)."""
        k = 0
        while self.root * 2 ** k < lo:
            k += 1
        while self.root * 2 ** (k - 1) >= lo:
            k -= 1
        return k

    def f(self, degree, octave=0, lo=0.0):
        """Frequency of a scale degree. `lo` clamps the octave so the tonic is not below lo Hz (instrument registers)."""
        if lo:
            octave = max(octave, self.oc(lo))
        return freq(self.root, self.scale, degree, octave)

    def deg_at(self, i):
        """Scale degree (octave-aware) of the last sounding balungan token at or before index i."""
        for k in range(i, -1, -1):
            tk = self.bal[k]
            base = tk.split("*")[0].rstrip("',")
            if base.isdigit():
                return int(base) + (tk.count("'") - tk.count(",")) * self.n
        return 1

    def bar_root(self, bar):
        """Scale degree of the first sounding balungan note of the bar (drives pad/bass harmony)."""
        for k in range(bar * BEATS, bar * BEATS + BEATS):
            tk = self.bal[k]
            if tk.split("*")[0].rstrip("',").isdigit():
                return self.deg_at(k)
        return self.deg_at(bar * BEATS)


def _place(mix, ev, fn, spb, gain=1.0, pan=0.0, rev=0.2, rev2=0.0, t0=0.0, vscale=1.0, **kw):
    for (b, f, d, v) in ev:
        sig = fn(f, d * spb, min(1.0, v * vscale), **kw)
        mix.add(sig, t0 + b * spb, gain, pan, rev, rev2)


def _hum(rng_seed):
    return np.random.default_rng(rng_seed)


# ---- colotomic backbone ------------------------------------------------------------------------------------

def colotomy(mix, th, density=1.0, gong_every=4, vel=0.8, kenong=True, kethuk=True):
    spb = th.beat
    rg = np.random.default_rng(11)
    for bar in range(BARS):
        t = bar * BEATS * spb
        if bar % gong_every == 0:
            mix.add(I.gong(th.f(1, -2, 55.0), 7.0, vel), t, 0.9 * density, 0.0, 0.1, 0.5)
        if kenong:
            for b in (1, 3):
                deg = th.bar_root(bar) if b == 1 else th.deg_at(bar * BEATS + 3)
                mix.add(I.kenong(th.f(deg, -1, 150.0), 1.0, vel * 0.75), t + (b + 0.0) * spb, 0.55 * density, -0.2, 0.25, 0.2)
        if bar % 2 == 1:
            mix.add(I.kempul(th.f(th.bar_root(bar), -1, 100.0), 1, vel * 0.7), t + 2 * spb, 0.5 * density, 0.2, 0.2, 0.3)
        if kethuk:
            for b in range(4):
                mix.add(I.kethuk(vel=0.5 + 0.2 * rg.random()), t + (b + 0.5) * spb, 0.35 * density, -0.3, 0.1)
                if b % 2 == 0:
                    mix.add(I.kempyang(vel=0.5), t + (b + 0.75) * spb, 0.2 * density, 0.3, 0.2)


def balungan(mix, th, gain=0.7, vel=0.72, peking_gain=0.0, demung_gain=0.55, imbal=False):
    spb = th.beat
    ev = th.notes(th.bal, 1.0, th.oc(262.0))   # saron register (~260-1000 Hz); demung an octave under, peking over
    _place(mix, ev, I.saron, spb, gain, -0.25, 0.3, 0.1, vscale=vel)
    _place(mix, [(b, f / 2, d, v) for b, f, d, v in ev], I.demung, spb, demung_gain, 0.15, 0.25, 0.15, vscale=vel)
    if peking_gain:
        pk = []
        for i, (b, f, d, v) in enumerate(ev):
            pk.append((b, f * 2, 0.5, v))
            if imbal:
                nxt = ev[(i + 1) % len(ev)][1]
                pk.append((b + 0.5, nxt * 2, 0.5, v * 0.7))
            else:
                pk.append((b + 0.5, f * 2, 0.5, v * 0.7))
        _place(mix, pk, I.peking, spb, peking_gain, 0.3, 0.25, 0.1, vscale=vel)


def lead_line(mix, th, fn=I.suling, gain=0.8, oct_a=None, oct_b=None, vscale=0.8, pan=0.1, rev=0.5, rev2=0.4,
              from_bar=0, to_bar=BARS, **kw):
    spb = th.beat
    oa = th.lead_oct if oct_a is None else oct_a
    ob = oa if oct_b is None else oct_b
    lo = {I.suling: 330.0, I.rebab: 200.0, I.tarompet: 230.0}.get(fn, 0.0)   # keep each voice in its real range
    if lo:
        oa, ob = max(oa, th.oc(lo)), max(ob, th.oc(lo))
    ev_a = th.notes(th.lead[:64], 0.5, oa)
    ev_b = th.notes(th.lead[64:], 0.5, ob)
    ev = ev_a + [(b + 32 * 1.0 * 0 + 8 * BEATS, f, d, v) for (b, f, d, v) in ev_b]
    ev = [(b, f, d, v) for b, f, d, v in ev if from_bar * BEATS <= b < to_bar * BEATS]
    _place(mix, ev, fn, spb, gain, pan, rev, rev2, vscale=vscale, **kw)


def arps(mix, th, fn=I.kacapi, gain=0.5, pattern=(0, 2, 4, 2, 5, 4, 2, 4), unit=0.5, octave=0, vel=0.6, pan=0.0,
         rev=0.4, rev2=0.2, pluck=0.3, lo=140.0):
    """Rolling arpeggio over the bar's chord (root, +2, +4 scale degrees)."""
    spb = th.beat
    for bar in range(BARS):
        r = th.bar_root(bar)
        for i, p in enumerate(pattern):
            b = bar * BEATS + i * unit
            deg = r + p
            acc = 1.0 if i % 4 == 0 else 0.7
            kw = {"pluck": pluck} if fn in (I.kacapi, I.harp) else {}
            mix.add(fn(th.f(deg, octave, lo), unit * spb * 2, vel * acc, **kw), b * spb, gain, pan + 0.15 * np.sin(i), rev, rev2)


def pads(mix, th, kind="strings", gain=0.9, octave=-1, every=1, vel=0.55, att=0.9, rev2=0.7, third=True, bright=0.5):
    spb = th.beat
    lo = {"strings": 95.0, "choir": 120.0, "drone": 55.0}[kind]
    for bar in range(0, BARS, every):
        r = th.bar_root(bar)
        deg = [r, r + 2, r + 4] if third else [r, r + 4]
        for k, d in enumerate(deg):
            mix.add(I.pad(th.f(d, octave, lo), every * BEATS * spb, vel, kind, att=att, rel=1.5, bright=bright),
                    bar * BEATS * spb, gain * (0.8 if k else 1.0), (-0.4, 0.4, 0.0)[k], 0.2, rev2)


def bass_line(mix, th, pattern, gain=0.8, octave=-2, kind="pluck", vel=0.8, bars=None):
    """pattern: list of (beat_in_bar, degree_offset, dur_beats). Played every bar from the bar's root."""
    spb = th.beat
    for bar in range(BARS):
        r = th.bar_root(bar)
        for (b, off, d) in pattern:
            mix.add(I.bass(th.f(r + off, octave, 45.0), d * spb, vel * (1 if b % 1 == 0 else 0.8), kind),
                    (bar * BEATS + b) * spb, gain, 0.0, 0.1, 0.1)


def drum_bar(mix, th, steps, gain=0.8, unit=0.25, pan=0.0, rev=0.15, bars=range(BARS), vary=True):
    """steps: list per bar slot, tokens: D dung, T tung, t tak, k ket, d de, B bedug, . rest. Strings like 'D..t .T.. '."""
    spb = th.beat
    toks = steps.replace(" ", "")
    kinds = {"D": ("dung", 0.9), "T": ("tung", 0.8), "t": ("tak", 0.7), "k": ("ket", 0.6), "d": ("de", 0.75)}
    rg = np.random.default_rng(5)
    for bar in bars:
        for i, c in enumerate(toks):
            if c == ".":
                continue
            b = bar * BEATS + i * unit
            if c == "B":
                mix.add(I.bedug(0.85), b * spb, gain * 0.9, 0.0, 0.2, 0.2)
                continue
            k, v = kinds[c]
            v = v * (0.8 + 0.2 * rg.random()) if vary else v
            mix.add(I.kendang(k, v), b * spb, gain, pan + (0.25 if c in "tdk" else -0.2), rev)


def imbal_bonang(mix, th, gain=0.5, vel=0.7, octave=0, fast=True):
    """Interlocking bonang pair (kotekan): two players alternate 16th notes around each balungan note."""
    spb = th.beat
    ev = th.notes(th.bal, 1.0)
    for i, (b, f, d, v) in enumerate(ev):
        f1 = f * 2 ** (octave + th.oc(330.0))   # bonang register (~330-1300 Hz)
        nxt = ev[(i + 1) % len(ev)][1] * 2 ** (octave + th.oc(330.0))
        seq = [(0.0, f1, 0.9, -0.5), (0.25, nxt, 0.55, 0.5), (0.5, f1, 0.8, -0.5), (0.75, nxt, 0.6, 0.5)]
        for (o, ff, vv, pn) in (seq if fast else seq[::2]):
            mix.add(I.bonang(ff, 0.25 * spb, vel * vv), (b + o) * spb, gain, pn, 0.25, 0.15)


def gender_fig(mix, th, gain=0.55, vel=0.6, density=2, octave=0):
    """Gender: parallel 'gembyang' dyads following the balungan, eighth-note motion."""
    spb = th.beat
    ev = th.notes(th.bal, 1.0, th.oc(140.0))
    for i, (b, f, d, v) in enumerate(ev):
        nxt = ev[(i + 1) % len(ev)][1]
        f0 = f * 2 ** octave
        steps = [(0.0, f0, 1.0), (0.5, (f0 + nxt * 2 ** octave) / 2 if density > 1 else f0, 0.7)]
        for (o, ff, vv) in steps:
            mix.add(I.gender(ff, 0.5 * spb, vel * vv), (b + o) * spb, gain, -0.1, 0.4, 0.3)
            if o == 0.0:
                mix.add(I.gender(ff * 2, 0.5 * spb, vel * vv * 0.6), (b + o) * spb + 0.012, gain * 0.7, 0.2, 0.4, 0.3)


def angklung_part(mix, th, gain=0.5, vel=0.6, pattern="x . x . x . x x", octave=1, every_bar=True):
    spb = th.beat
    for bar in range(BARS):
        r = th.bar_root(bar)
        toks = pattern.split()
        for i, c in enumerate(toks):
            if c == ".":
                continue
            deg = r + (0, 2, 4, 2, 0, 4, 2, 0)[i % 8]
            mix.add(I.angklung(th.f(deg, octave, 420.0), 0.45 * spb, vel * (1 if i % 2 == 0 else 0.7), shake=True),
                    (bar * BEATS + i * 0.5) * spb, gain, -0.5 + 0.14 * i, 0.3, 0.2)


def tension_hits(mix, th, gain=0.8, every=4, octave=-3):
    spb = th.beat
    for bar in range(0, BARS, every):
        mix.add(I.bedug(1.0, 58.0, 1.4), bar * BEATS * spb, gain, 0, 0.2, 0.4)
        mix.add(I.sub_boom(th.f(1, octave, 38.0), 2.4, 0.8), bar * BEATS * spb, gain * 0.6, 0, 0.0, 0.0)


def eq(st, hi_db=3.0, lo_cut=35.0, lo_db=-3.0):
    """Gentle tilt: lift 2-8 kHz air, trim sub rumble and the 40-110 Hz bloom."""
    from dsp import spectral_filter, db
    def curve(f):
        hi = 1 + (db(hi_db) - 1) * np.clip((np.log2(np.maximum(f, 1) / 1800.0)) / 1.6, 0, 1)
        lo = 1 + (db(lo_db) - 1) * np.exp(-0.5 * (np.log2(np.maximum(f, 1) / 70.0) / 0.9) ** 2)
        cut = 1 / np.sqrt(1 + (lo_cut / np.maximum(f, 1e-3)) ** 4)
        return hi * lo * cut
    return np.stack([spectral_filter(st[:, 0], curve), spectral_filter(st[:, 1], curve)], axis=1)


def finish(mix, th, rt=(1.4, 3.4), wet=1.0, rms=-19.0, seed=3, hi_db=3.0):
    st = mix.render(loop=True, rt=rt, wet=wet, seed=seed)
    return master(eq(st, hi_db), rms)
