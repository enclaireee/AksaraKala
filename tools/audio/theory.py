"""Scales and a tiny note DSL.

ASSUMED: tuning values are approximations of Javanese/Sundanese tunings (real gamelans are each tuned differently,
so no two sets share exact cents). VERIFY with a recorded set before claiming accuracy.
"""
import re

SCALES = {
    # Javanese slendro: five near-equal steps of ~240 cents.
    "slendro": [0, 240, 480, 720, 960],
    # Javanese pelog (7 notes, unequal steps; a common Central-Java approximation).
    "pelog": [0, 120, 270, 540, 670, 800, 950],
    # Sundanese degung (5 notes: da mi na ti la), a pelog-degung approximation.
    "degung": [0, 130, 410, 570, 700],
    # Madenda (Sunda): the "minor" colour used in kacapi/tembang cianjuran.
    "madenda": [0, 200, 330, 700, 840],
    # Pelog barang-ish with a raised 4th for the Balinese/East Javanese gamelan bite.
    "pelog_timur": [0, 110, 260, 560, 690, 790, 940],
}


def freq(root, scale, degree, octave=0):
    """degree is 1-based and may be <1 or > len(scale): it wraps by octaves."""
    s = SCALES[scale]
    n = len(s)
    d = degree - 1
    o = d // n
    cents = s[d % n] + 1200 * (o + octave)
    return root * 2 ** (cents / 1200.0)


_tok = re.compile(r"([0-9]+|\.|-|~)([',]*)(\*[0-9.]+)?")


def parse(line, scale, root, unit=0.5, octave=0):
    """Parse 'balungan' strings into [(beat, freq, dur_beats, vel)].

    tokens (space separated, each = `unit` beats):
      N      scale degree N (1-based), suffix ' = octave up, , = octave down
      .      rest      -   hold previous note (lengthens it)     |  bar line (ignored)
      N*0.5  velocity multiplier
    """
    out = []
    beat = 0.0
    for tok in line.replace("|", " ").split():
        m = _tok.fullmatch(tok)
        if not m:
            raise ValueError("bad token " + tok)
        body, oct_s, vel_s = m.groups()
        vel = float(vel_s[1:]) if vel_s else 1.0
        if body == ".":
            beat += unit
            continue
        if body == "-" or body == "~":
            if out:
                b, f, d, v = out[-1]
                out[-1] = (b, f, d + unit, v)
            beat += unit
            continue
        o = octave + oct_s.count("'") - oct_s.count(",")
        out.append((beat, freq(root, scale, int(body), o), unit, vel))
        beat += unit
    return out, beat
