#!/usr/bin/env python3
"""Renders the composed music and the stingers into assets/audio/{music,jingle} (tools/audio/tracks.py, intro.py,
jingles.py). Finished downloaded tracks and all recorded sounds are tools/build_audio.py's job.

  /usr/bin/python3 tools/gen_music.py [--only explore_sunda,victory]
Needs the multisamples (tools/audio/sampler.py) and, for the intro and boss_intro, the built sfx.
"""
import argparse
import os
import sys
import zlib
from multiprocessing import Pool

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "audio"))
import dsp  # noqa: E402
import intro  # noqa: E402
import jingles  # noqa: E402
import tracks as T  # noqa: E402
import build_audio as B  # noqa: E402

OUT = os.path.join(HERE, "..", "assets", "audio")
# name -> (render, LUFS target)
MUSIC = {"intro": (intro.score, -18.0)}
for _r, _th in T.THEMES.items():
    MUSIC["explore_" + _r] = (lambda th=_th: T.explore(th), -20.0)
    MUSIC["dark_" + _r] = (lambda r=_r: T.dark(r), -22.0)
    MUSIC["combat_" + _r] = (lambda th=_th: T.combat(th), -17.0)
for _k in T.SPECIAL:
    MUSIC[_k] = (lambda k=_k: T.special(k), -20.0)
JINGLES = "victory quest_new quest_done rest death discover area_clear choice glyph boss_intro levelup area_title".split()


def build(name):
    # every file starts from its own random state, so a run is reproducible whatever the job order
    dsp.RNG.bit_generator.state = np.random.default_rng(zlib.crc32(name.encode())).bit_generator.state
    if name in MUSIC:
        fn, target = MUSIC[name]
        x = fn()
        x = x * 10 ** ((target - B.lufs(x)) / 20)
        x *= min(1.0, 10 ** (-1 / 20) / np.abs(x).max())
        path = os.path.join(OUT, "music", name + ".ogg")
    else:
        x = jingles.jingle(name)
        p = np.abs(x).max(axis=1)
        x = x[:np.nonzero(p > p.max() * 10 ** (-58 / 20))[0][-1] + dsp.n_of(0.02)]
        k = dsp.n_of(0.15)
        x[-k:] *= np.linspace(1, 0, k)[:, None]
        x = x * 10 ** ((-16.0 - B.lufs(x)) / 20)   # equal loudness between stingers, peaks kept under -3 dBFS
        x *= min(1.0, 10 ** (-3 / 20) / np.abs(x).max())
        path = os.path.join(OUT, "jingle", name + ".ogg")
    B.write_ogg(x, path)
    return "%-16s %6.1f s  %6.1f LUFS  peak %5.1f dB" % (name, len(x) / dsp.SR, B.lufs(x), B.peak_db(x))


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", default="")
    names = [n for n in ap.parse_args().only.split(",") if n] or list(MUSIC) + JINGLES
    with Pool(min(6, len(names))) as pool:
        for line in pool.imap_unordered(build, names):
            print(line, flush=True)
