"""Stingers: short musical phrases played over the music (assets/audio/jingle). Registry: tools/gen_music.py."""
import numpy as np
import inst as I
import sampler as S
from dsp import n_of, convolve, make_ir


def _at(sig, t, n):
    out = np.zeros(n)
    a = n_of(t)
    m = min(len(sig), n - a)
    if m > 0:
        out[a:a + m] = sig[:m]
    return out


def _reverb(y, rt=0.7, wet=0.25, seed=1):
    """Mono phrase in, stereo out: the dry signal centred, the room wide."""
    n = len(y) + n_of(rt)
    out = np.zeros((n, 2))
    for ch, ir in enumerate(make_ir(rt, seed=seed)):
        w = convolve(y, ir)[:n]
        out[:len(y), ch] += y
        out[:len(w), ch] += w * wet * (np.sqrt(np.sum(y * y)) / (np.sqrt(np.sum(w * w)) + 1e-9))
    return out


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
            y += _at(I.rebab(f, 1.4, 0.7), 0.8 + i * 0.9, len(y)) * 0.8
        y += _at(I.pad(98, 5.0, 0.6, "drone", att=1.0, rel=2.0), 0.5, len(y))
        return _reverb(y, 2.4, 0.45)
    if kind == "discover":
        y = _phrase([(988, 0.7), (1319, 0.8), (1760, 0.9)], I.kacapi, 0.14, 2.0) + 0
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
            y += _at(I.kacapi(f, 0.8, 0.8), i * 0.13, len(y)) + _at(I.bell(f * 2, 1.4, 0.4), i * 0.13 + 0.05, len(y)) * 0.3
        y += _at(I.pad(330, 3.0, 0.5, "choir", att=0.5, rel=1.4), 0.2, len(y))
        return _reverb(y, 1.6, 0.4)
    if kind == "boss_intro":
        y = np.zeros(n_of(5.0))
        y += _at(I.bedug(1.0, 55, 1.6), 0.0, len(y)) + _at(I.gong(55.0, 5.0, 1.0), 0.0, len(y)) + _at(I.sub_boom(36, 3.0, 1.0), 0.0, len(y)) * 0.6
        y += _at(I.tarompet(147, 1.4, 0.9), 0.4, len(y)) * 0.8 + _at(S.sfx("boss_roar"), 0.1, len(y)) * 0.6
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
