"""Aksara Kala showcase trailer: the edit decision list (EDL).

This file is the cut. Edit it, then run  python3 video/edit/build.py  (or --preview for a fast 960x540 draft).
Only segments whose entries change are re-rendered (segment cache in video/out/edit_cache/).

ENTRY  E(src, inp=0.0, dur=None, out=None, **opts)
  src     'raw/<name>'  -> video/out/raw/<name>.mp4  (game footage, its audio is used)
          'gfx/<name>'  -> video/out/gfx/<name>.mp4  (cards / scenes; silent)
          'black'       -> a plain night-colour frame
  inp     source in-point in seconds
  dur     length on the timeline in seconds (or give out= instead). If the source is shorter, its last frame is held.
  opts
    id=        a name so music_plan.py can refer to this entry ('@id+0.5')
    ov=[O(...)]overlays (alpha .mov from video/out/gfx), offset relative to this entry's start; may run on
               into the following entries of the same segment
    fin=, fout= stepped Bayer-dither fade from/to the night colour, in seconds (built on the 480x270 grid)
    gain=      clip-audio gain in dB (default CLIP_GAIN); audio=False mutes the clip
    render=    for gfx scenes: re-render the scene through video/gfx (dict: dur=, kw=) instead of using the stock file;
               used to retime cards to the beat grid and to retime aksara_montage's glyphs to beats
    zoom=      [(t, k, cx, cy), ...]  integer-scale push-in: from time t (entry-relative) show the native 480x270
               picture at k x (k=4 is the normal 1920 frame), centred on native pixel (cx, cy); nearest-neighbour
    need=      the entry only exists if this file (relative to video/out) exists  (vistas, cine_taken)
    skip_if=   the entry is dropped if this file exists (the fallback for a 'need' entry)

GRID   B(n) = n beats of the 112 bpm main/combat theme (Tanah Timur), S(n) = beats of Rynos Theme (boss_sunda,
       128 bpm), H(n) = beats of Morning (home, 120 bpm). Cut lengths are written in beats so every cut lands on the
       music's beat grid; music_plan.py places each track so its downbeat falls on its segment's first frame.
"""

CLIP_GAIN = 3.0          # dB on all game audio before the master


def B(n):                # Tanah Timur explore/combat theme: 112 bpm
    return n * 60.0 / 112.0


def S(n):                # boss_sunda (Rynos Theme): measured 0.46888 s per beat
    return n * 0.46888


def H(n):                # home (Morning): 120 bpm
    return n * 0.5


def E(src, inp=0.0, dur=None, out=None, **kw):
    if dur is None:
        dur = out - inp
    d = dict(src=src, inp=float(inp), dur=float(dur))
    d.update(kw)
    return d


def O(name, at=0.0, inp=0.0, dur=None):
    return dict(src=name, at=float(at), inp=float(inp), dur=dur)


def vista(region, beats):
    """A region vista (4 s source with 0.2 s dither fades at each end: trimmed inside them)."""
    return E(f"gfx/vista_{region}", 0.2, B(beats), need=f"gfx/vista_{region}.mp4")


# rapid-fire glyph run: popup frames of the 8 casts in s4_glyph_rapid (s), and the beats each cut gets
RAPID_POPUP = [1.08, 3.18, 5.28, 7.38, 9.48, 11.58, 13.68, 15.78]
RAPID_BEATS = [2, 1, 1, 1, 1, 1, 0.5, 0.5]
# aksara_montage: 2 glyphs at 1 beat, 18 at half a beat (11 beats), then the grid + line hold for 6 beats
MONTAGE_BEATS = [B(1)] * 2 + [B(0.5)] * 18


def rapid():
    return [E("raw/s4_glyph_rapid", p + 0.45 - B(b), B(b), id=f"rapid{i}") for i, (p, b) in
            enumerate(zip(RAPID_POPUP, RAPID_BEATS))]


def region(lt, first, rest):
    """first entry carries the lower-third from its start (lt 5 s: in by 1.2 s, gone by 4.85 s)."""
    first = dict(first)
    first["ov"] = [O(f"lt_{lt}", 0.0)]
    first["id"] = f"region_{lt}"
    return [first] + rest


def world(entries, gain=-1.0):
    """World segment: the game's ambience sits under the main theme."""
    return [dict(e, gain=e.get("gain", gain)) if e["src"].startswith("raw/") else e for e in entries]


def region_game(lt, shots):
    return region(lt, shots[0], shots[1:])


SEGMENTS = [
    # 1 ---------------------------------------------------------------- cold open (no music)
    dict(name="s1_cold_open", entries=[
        E("black", 0, 1.0, id="open_black"),
        E("raw/s1_hook_a", 0.6, out=6.35, fin=0.4, id="hook", gain=4.0, atail=0.9),   # cut on the kill hit at 6.35
        E("gfx/card_written", 0, 4.0, id="card_written"),
    ]),
    # 2 ---------------------------------------------------------------- premise
    dict(name="s2_premise", entries=[
        E("raw/s2_prologue", 9.0, 3.7, id="kelir"),
        # wordless cinematic, used when it exists ...
        E("gfx/cine_taken", 0, 9.0, need="gfx/cine_taken.mp4", id="cine_taken"),
        # ... otherwise the raid as the game tells it
        E("raw/s2_prologue_raid_shadows", 0.0, 4.36, skip_if="gfx/cine_taken.mp4", id="raid"),
        E("raw/s2_prologue_raid_wrongchild", 0.0, 2.65, skip_if="gfx/cine_taken.mp4"),
        E("raw/s2_prologue_raid_morning", 5.15, out=7.33, skip_if="gfx/cine_taken.mp4"),
        E("gfx/card_forgotten", 0, 4.0, id="card_forgotten"),
        E("raw/s2_intro", 0.0, 9.25, fout=0.25, id="intro", gain=6.0),   # logo at 7.0, breathes to 9.25
    ]),
    # 3 ---------------------------------------------------------------- world showcase (explore_timur from bar 1)
    dict(name="s3_world", entries=world([
        E("raw/s3_map", 0.0, B(8), id="map", audio=False,
          zoom=[(0.0, 4, 240, 135), (B(2), 5, 238, 130), (B(4), 6, 236, 128), (B(6), 8, 236, 128)]),
        E("gfx/card_world", 0, B(6), render=dict(dur=B(6)), id="card_world"),
        *region_game("desa_purwa", [E("raw/s3_purwa_1", 1.0, B(7)), E("raw/s3_purwa_3", 1.0, B(5))]),
        *region("tatar_sunda", vista("sunda", 4), [E("raw/s3_ts_1", 1.0, B(4)), E("raw/s3_ts_2", 1.0, B(4))]),
        *region("keraton_galuh", vista("galuh", 5), [E("raw/s3_kg_2", 1.0, B(7))]),
        *region("mataram", vista("mataram", 5), [E("raw/s3_mt_2", 1.0, B(7))]),
        *region("tanah_timur", vista("timur", 6), [E("raw/s3_tt_2", 1.0, B(6))]),
        *region("segara_kidul", vista("kidul", 5), [E("raw/s3_sk_1", 1.0, B(7))]),
        *region("gua_kala", vista("kala", 5), [E("raw/s3_gk_1", 1.0, B(7))]),
    ])),
    # 4 ---------------------------------------------------------------- aksara casting (combat_timur, in sync)
    dict(name="s4_casting", entries=[
        E("gfx/card_cast", 0, B(6), render=dict(dur=B(6)), id="card_cast"),
        E("raw/s4_lesson", 0.85, B(8), ov=[O("feature_label_learn", 0.25)], id="lesson"),
        E("raw/s4_cast_demo_1", 1.3, B(11), ov=[O("feature_label_ml", 0.25)], id="demo1"),
        E("raw/s4_cast_weak", 0.5, B(11), id="weak"),
        E("raw/s4_cast_demo_2", 1.6, B(8), id="demo2"),
        E("raw/s4_cast_demo_3", 1.9, B(8), id="demo3"),
        *rapid(),
        E("gfx/aksara_montage", 0, B(17), render=dict(dur=B(17), kw={"beats": MONTAGE_BEATS}), id="montage"),
        E("raw/s4_combo", 2.3, B(10), id="combo"),
    ]),
    # 5 ---------------------------------------------------------------- gameplay & features (boss_sunda peak)
    dict(name="s5_features", entries=[
        E("raw/s5_class_select", 0.0, S(7), ov=[O("feature_label_classes", 0.2)], id="classes", gain=8.0),
        E("raw/s5_class_warrior", 2.25, S(3), id="cls_warrior"),
        E("raw/s5_class_rogue", 2.25, S(3)),
        E("raw/s5_class_lancer", 2.25, S(3)),
        E("raw/s5_class_dalang", 2.25, S(3)),
        E("raw/s5_boss_sangkuriang", 0.5, S(7), ov=[O("feature_label_bosses", 0.15)], id="boss_sangkuriang_card"),
        E("raw/s5_boss_sangkuriang", 5.85, S(3)),
        E("raw/s5_boss_sangkuriang", 8.3, S(3)),
        E("raw/s5_boss_buto_ijo", 1.5, S(3), id="boss_buto_card"),
        E("raw/s5_boss_buto_ijo", 8.9, S(2)),
        E("raw/s5_boss_buto_ijo", 10.9, S(4)),
        E("raw/s5_boss_bondowoso", 1.6, S(2), id="boss_bondo_card"),
        E("raw/s5_boss_bondowoso", 7.2, S(3)),
        E("raw/s5_boss_kala", 0.9, S(5), id="boss_kala_card"),
        E("raw/s5_boss_kala", 6.9, S(3)),          # ends 2 frames before the eclipse's white flash
        E("raw/s5_boss_kala", 10.2, S(5), id="kala_calmed"),        # Jawa KA: Kala is calmed and fades
        E("raw/s5_choice", 2.9, S(8), ov=[O("feature_label_choices", 0.2)], id="choice", gain=8.0),
        E("raw/s5_codex", 0.4, S(7), ov=[O("feature_label_codex", 0.15)], id="codex", gain=8.0),
        E("raw/s5_dialogue", 0.3, S(6), id="semar", gain=6.0),
        E("gfx/card_free", 0, S(7), render=dict(dur=S(7)), id="card_free"),
    ]),
    # 6 ---------------------------------------------------------------- culture, benefit, proof (home / Morning)
    dict(name="s6_culture", entries=[
        E("gfx/card_built_with", 0, H(6), id="card_built_with"),
        E("gfx/quote_pearly", 0, H(8.5), id="quote1"),
        E("gfx/quote_nurbani", 0, H(8.5), id="quote2"),
        E("gfx/quote_munawar", 0, H(8.5), id="quote3"),
        E("gfx/quote_yazid", 0, H(8.5), id="quote4"),
        E("gfx/card_partners", 0, H(7), id="card_partners"),
        E("gfx/card_numbers", 0, H(9), id="card_numbers"),
    ]),
    # 7 ---------------------------------------------------------------- what's next (explore_timur returns at bar 12)
    dict(name="s7_next", entries=[
        E("gfx/card_next", 0, B(5), render=dict(dur=B(5)), id="card_next"),
        E("gfx/fut_skins", 0, B(16), render=dict(dur=B(16)), id="fut_skins"),
        E("gfx/fut_coop", 0, B(16), render=dict(dur=B(16)), id="fut_coop"),
        E("gfx/fut_mobile", 0, B(16), render=dict(dur=B(16)), id="fut_mobile"),
        E("gfx/fut_map", 0, B(18), render=dict(dur=B(18)), id="fut_map"),   # last line lands at 7.4 s
    ]),
    # 8 ---------------------------------------------------------------- end card (theme's final cadence at +B(13))
    dict(name="s8_end", entries=[
        E("gfx/end_card", 0, 12.0, id="end_card"),
    ]),
]
