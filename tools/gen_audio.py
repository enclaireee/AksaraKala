#!/usr/bin/env python3
"""Generates every sound in the game (music, ambience, sfx, jingles) into assets/audio/ as Ogg Vorbis.

Pure synthesis (numpy + ffmpeg): no samples, so no licences. Run:  python3 tools/gen_audio.py [--only prefix] [--jobs N]
Source modules live in tools/audio/ (dsp, inst, theory, music, tracks, sfx, amb). Design: .docs/audio.md.
Deterministic: every random source is seeded, so re-running reproduces the same files.
"""
import argparse
import os
import sys
import time
import zlib
from multiprocessing import Pool

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "audio"))
OUT = os.path.join(os.path.dirname(HERE), "assets", "audio")

import numpy as np  # noqa: E402
import dsp  # noqa: E402
import tracks as T  # noqa: E402
import sfx as S  # noqa: E402
import amb as A  # noqa: E402

REGIONS = ["sunda", "galuh", "mataram", "timur", "kidul", "kala"]

# ---- registry -----------------------------------------------------------------------------------------------
MUSIC = {}
for r in REGIONS:
    MUSIC["explore_" + r] = (lambda r=r: T.explore(T.THEMES[r]))
    MUSIC["dark_" + r] = (lambda r=r: T.dark(r))
    MUSIC["combat_" + r] = (lambda r=r: T.combat(T.THEMES[r]))
    MUSIC["boss_" + r] = (lambda r=r: T.boss(r))
MUSIC["boss_kala_2"] = lambda: T.boss("kala", intense=True)
for k, th in T.TOWNS.items():
    MUSIC[("home" if k == "home" else "town_" + k)] = (lambda th=th: T.town(th))
for k in T.SPECIAL:
    MUSIC[k] = (lambda k=k: T.special(k))

# name -> (function, peak dB)
SFX = {
    # player / combat
    "swing_1": (lambda: S.swing(0), -4), "swing_2": (lambda: S.swing(1), -4), "swing_3": (lambda: S.swing(2), -3),
    "swing_heavy": (S.swing_heavy, -3),
    "hit_light": (lambda: S.hit("light"), -3), "hit_heavy": (lambda: S.hit("heavy"), -1.5), "hit_kill": (lambda: S.hit("kill"), -1.5),
    "hit_armor": (lambda: S.hit("armor"), -3), "hit_flesh": (lambda: S.hit("flesh"), -3),
    "player_hurt": (S.player_hurt, -2), "dodge": (S.dodge, -6), "perfect_dodge": (S.perfect_dodge, -3),
    "shoot": (S.shoot, -4), "arrow_hit": (S.arrow_hit, -5), "block": (S.block, -3),
    "enemy_death": (S.enemy_death, -3), "enemy_telegraph": (S.enemy_telegraph, -7), "stagger": (S.stagger, -2),
    "player_death": (S.player_death, -2), "flask": (S.flask, -5), "stamina_empty": (S.stamina_empty, -8), "interact": (S.interact, -8),
    # casting
    "cast_begin": (S.cast_begin, -5), "ink": (S.ink_scratch, -16), "cast_fail": (S.cast_fail, -6),
    "cast_ok_low": (lambda: S.cast_ok(0.0), -5), "cast_ok_mid": (lambda: S.cast_ok(0.5), -5), "cast_ok_high": (lambda: S.cast_ok(0.85), -4),
    "cast_perfect": (S.cast_perfect, -2),
    "spell_bolt": (lambda: S.spell("bolt"), -2), "spell_ward": (lambda: S.spell("ward"), -3), "spell_bind": (lambda: S.spell("bind"), -3),
    "spell_burst": (lambda: S.spell("burst"), -1.5), "spell_heal": (lambda: S.spell("heal"), -4), "spell_dash": (lambda: S.spell("dash"), -3),
    "spell_rally": (lambda: S.spell("rally"), -2.5), "spell_summon": (lambda: S.spell("summon"), -2), "spell_ombak": (lambda: S.spell("ombak"), -2),
    # world
    "chest_open": (S.chest_open, -4), "pickup": (S.pickup, -7), "pickup_rare": (lambda: S.pickup(True), -5), "exit": (S.exit_door, -6),
    "petilasan": (S.petilasan, -3), "lontar": (S.lontar, -10), "thud": (S.thud, -4), "shortcut_open": (S.shortcut_open, -2),
    "puzzle_solve": (S.puzzle_solve, -4), "kabut": (S.kabut, -9), "memory_in": (lambda: S.memory(True), -4), "memory_out": (lambda: S.memory(False), -4),
    "save": (S.save, -8), "wrong": (S.wrong, -8), "torch": (S.torch, -6),
    "boss_roar": (S.boss_roar, -1), "boss_slam": (S.boss_slam, -1), "boss_telegraph": (S.boss_telegraph, -6),
    "boss_phase": (S.boss_phase, -1), "boss_death": (S.boss_death, -1),
    # ui
    "ui_move": (S.ui_move, -11), "ui_confirm": (S.ui_confirm, -8), "ui_back": (S.ui_back, -9), "ui_denied": (S.ui_denied, -9),
    "ui_page": (S.page_flip, -8), "ui_open": (lambda: S.page_flip(True), -7), "ui_close": (lambda: S.page_flip(False, True), -8),
    "ui_slider": (S.ui_slider, -12), "ui_letter": (S.ui_letter, -11), "ui_choice": (S.ui_choice, -9), "ui_equip": (S.ui_equip, -7),
    "ui_pip": (S.ui_pip, -10), "ui_start": (S.ui_start, -3),
}
for i in range(6):
    SFX["blip_%d" % i] = ((lambda i=i: S.blip(i)), -15)
for k in ("grass", "stone", "sand", "wood", "water"):
    for i in range(3):
        SFX["step_%s_%d" % (k, i)] = ((lambda k=k, i=i: S.step(k, i)), -13 if k != "water" else -10)
JINGLES = {k: (lambda k=k: S.jingle(k)) for k in
           ("victory quest_new quest_done rest death discover area_clear choice glyph boss_intro levelup area_title").split()}
AMB = {k: None for k in A.BEDS}

JOBS = ([("music", k) for k in MUSIC] + [("amb", k) for k in AMB] + [("jingle", k) for k in JINGLES]
        + [("sfx", k) for k in SFX])


def trim_tail(x, floor_db=-58.0):
    p = np.abs(x)
    thr = p.max() * dsp.db(floor_db)
    idx = np.nonzero(p > thr)[0]
    end = idx[-1] + 1 if len(idx) else len(x)
    return x[: min(len(x), end + dsp.n_of(0.02))]


def _reseed(name):
    """Every file starts from the same random state, so a run is reproducible whatever the job order."""
    st = np.random.default_rng(zlib.crc32(name.encode())).bit_generator.state
    dsp.RNG.bit_generator.state = st
    S.R.bit_generator.state = np.random.default_rng(zlib.crc32(name.encode()) + 1).bit_generator.state


def build(job):
    kind, name = job
    _reseed(name)
    t0 = time.time()
    d = os.path.join(OUT, {"music": "music", "amb": "amb", "sfx": "sfx", "jingle": "jingle"}[kind])
    os.makedirs(d, exist_ok=True)
    path = os.path.join(d, name + ".ogg")
    if kind == "music":
        st = MUSIC[name]()
        dsp.write_ogg(path, st, q=1.5)
    elif kind == "amb":
        seed = zlib.crc32(name.encode()) % 100000
        fn = A.BEDS[name]
        L, R = A.bed(fn, seed), A.bed(fn, seed + 1)
        st = np.stack([L, R], axis=1)
        st = dsp.master(st, rms_db=-27.0, ceiling_db=-4.0, glue=False)
        dsp.write_ogg(path, st, q=1.5)
    elif kind == "jingle":
        x = JINGLES[name]()
        x = trim_tail(x)
        x = dsp.master_mono(dsp.fade(x, 0.002, 0.15), -3.0)
        dsp.write_ogg(path, x, q=3)
    else:
        fn, pk = SFX[name]
        x = trim_tail(fn())
        x = dsp.fade(x, 0.0005, 0.01)
        x = dsp.master_mono(x, pk)
        dsp.write_ogg(path, x, q=3)
    return kind, name, time.time() - t0, os.path.getsize(path)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", default="", help="substring filter on kind/name, e.g. music/boss")
    ap.add_argument("--jobs", type=int, default=4)
    ap.add_argument("--list", action="store_true")
    a = ap.parse_args()
    jobs = [j for j in JOBS if a.only in "%s/%s" % j]
    if a.list:
        for j in jobs:
            print("%s/%s" % j)
        return
    t0 = time.time()
    total = 0
    with Pool(a.jobs) as p:
        for kind, name, dt, size in p.imap_unordered(build, jobs):
            total += size
            print("%-6s %-22s %5.1fs %7.1f KB" % (kind, name, dt, size / 1024), flush=True)
    print("%d files, %.1f MB, %.0fs" % (len(jobs), total / 1048576, time.time() - t0))


if __name__ == "__main__":
    main()
