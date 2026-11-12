# Audio

Music, ambience and sound effects for Aksara Kala. Related: [architecture.md](architecture.md) 3 (Audio autoload), [combat.md](combat.md) (hit feedback), [ui.md](ui.md), [assets.md](assets.md) 4.1.

Status (2026-11-12): **redesign.** The first pass was fully synthesised and sounded cheap and harsh. Now: sound effects and ambience are **real recordings**, set-piece music (title, home, towns, bosses, epilogue) is **downloaded finished tracks**, and the region explore / dark / combat layers, `kelir`, `ruwatan`, `select`, `intro` and the stingers are **composed here and rendered with sampled instruments** (hybrid JRPG + gamelan: strings, harp, flute carry the tune; gamelan, suling and kendang are the colour). Sources are downloads for a private build: **not cleared for release** (credits and URLs are in `tools/audio/sources/*.json`). Checked by measurement and an audition page, then by ear. Tags: ASSUMED (a decision), VERIFY (a culture fact), TUNE (a number to adjust by ear).

---

## 1. Design goals

1. **It must read as an RPG soundtrack, not a loop pack.** Every region has an exploration theme, a grim variant, a combat theme and a boss theme built from the *same* melody, so the score has identity per place and the game has leitmotifs.
2. **Hybrid JRPG + gamelan.** An orchestral backbone with gamelan as colour. Instrument set (saron, demung, peking, bonang, gender, kenong, kempul, gong ageng, kendang, bedug, suling, rebab, tarompet, kacapi, angklung) over the colotomic structure (gong cycle, kenong, kempul, kethuk) with a Western RPG arrangement on top (pads, bass ostinato, drum fills, risers).
3. **The soundtrack reacts.** Combat is a layer, not a cut. Bosses take over. Stingers duck the mix. Menus and casting muffle it.
4. **Time is the motif.** `The Script of Time`: a faint clock tick runs under the title theme, the Gua Kala themes and ambience, and the Batara Kala boss.

## 2. Music map

Composed loops are A/B sections (about 90-120 s). Tempo in BPM. The `boss_*`, `home`, `town_*`, `title` and `epilogue` rows are downloaded tracks: their tempo and scale columns describe the brief, not the file. Scale names are in `tools/audio/theory.py` (**ASSUMED** approximations of Javanese slendro/pelog and Sundanese degung/madenda tunings; real gamelans each tune differently. **VERIFY** against a recorded set before claiming accuracy).

| Region | Scale / root | Explore | Dark | Combat | Boss | Character |
|---|---|---|---|---|---|---|
| Tatar Sunda (+ Desa Purwa) | degung, D3 | `explore_sunda` 88 | `dark_sunda` | `combat_sunda` 88 | `boss_sunda` 132 | misty highlands: suling over kacapi arpeggios |
| Karajaan Galuh | pelog, A2 | `explore_galuh` 76 | `dark_galuh` | `combat_galuh` 76 | `boss_galuh` 126 | stately court: rebab, harp, slow gongs |
| Bhumi Mataram | slendro, F3 | `explore_mataram` 84 | `dark_mataram` | `combat_mataram` 84 | `boss_mataram` 128 | sawah and candi: gender-led, suling then rebab |
| Tanah Timur | pelog timur, G3 | `explore_timur` 112 | `dark_timur` | `combat_timur` 112 | `boss_timur` 144 | bright, interlocking bonang (kotekan) |
| Segara Kidul | pelog, Bb2 | `explore_kidul` 66 | `dark_kidul` | `combat_kidul` 66 | `boss_kidul` 108 | tidal: choir pad, harp, slow rebab |
| Gua Kala | pelog, E2 | `explore_kala` 72 | `dark_kala` | `combat_kala` 72 | `boss_kala` 120, `boss_kala_2` 134 | time: drone, ticking, sparse gender; phase 3 of Batara Kala switches to `boss_kala_2` |

Explore and combat of one region share tempo, length and harmony, so the combat layer can play muted in sync and fade in (no restart, no tempo jump). `dark_*` uses sub-biome 2 zones (see `Audio.DARK_ZONES`, mirrors `zones/zone.gd sub_biome`).

| Id | Where | Notes |
|---|---|---|
| `home` | Desa Purwa | warm degung, angklung + kacapi + suling, 96 |
| `town_kampung` | ts_kampung | madenda (minor colour), 90 |
| `town_galuh` | kg_alun, kg_pasar | lively court market, pelog, 108 |
| `town_mataram` | mt_pasar | bustling slendro, 100 |
| `town_kidul` | sk_nelayan | fishing village, madenda, 88 |
| `title` | title screen, prologue | choir pad, gender arpeggio, suling; clock tick underneath |
| `select` | name entry, class select, hub, sanggar | ritual: rebab, drone, slow kendang |
| `kelir` | Kelir memories | wayang shadow-play: gender, kepyak clacks, rebab |
| `ruwatan` | memories `k0_ruwatan`, `k10_murwakala` | choir, bells, bedug; the cleansing hymn |
| `epilogue` | epilogue | hope: harp, suling, strings |

Stingers (`assets/audio/jingle/`, stereo Ogg): `victory` (boss), `quest_new`, `quest_done`, `rest` (petilasan), `death`, `discover`, `area_clear`, `choice`, `glyph`, `boss_intro`, `levelup`, `area_title`. A stinger ducks the mix 12 dB for its `Audio.JINGLE_HOLD` seconds (`area_title` does not duck).

## 3. Ambience (`assets/audio/amb/`, field recordings, seamless stereo loops, 60-90 s, -27 LUFS)

`forest_day`, `forest_night`, `village`, `market`, `river`, `sea`, `cave`, `crater`, `desert`, `swamp`, `ruins`, `graveyard`, `kala`, `palace`, `prison`, `kelir`, `forge`. Chosen per zone from `Audio.AMBIENCE` (all 47 zones listed; the test fails if one is missing). They play on the Ambience bus under the music, crossfade 3 s, and dip when a boss starts.

## 4. Sound effects (`assets/audio/sfx/`, 44.1 kHz mono WAV, recorded, peak-normalised per sound)

A repeated sound has variations: `hit_light.wav`, `hit_light__2.wav`, `hit_light__3.wav`. Audio wraps them in an `AudioStreamRandomizer` (no immediate repeats), so code only ever names `hit_light`.

- **Player:** `swing_1..3`, `hit_light/heavy/kill`, `player_hurt`, `dodge`, `perfect_dodge`, `shoot`, `arrow_hit`, `flask`, `stamina_empty`, `player_death`, `step_<grass|stone|sand|wood|water>` (4 variations each) (surface from `Audio.SURFACE*`).
- **Aksara casting:** `cast_begin` (time slows, world muffles), `ink` (looping stylus-on-bark while drawing, pitch follows speed), `cast_fail`, `cast_ok_low/mid/high` (by score), `cast_perfect` (score >= 0.92), and one spell sound per glyph: `spell_bolt` (Sunda Ka), `ward` (Ga), `bind` (Nga), `burst` (Ca), `heal` (Jawa Ha), `dash` (Na), `rally` (Ca), `summon` (Ra, tiger), `ombak` (Ka).
- **Enemies and bosses:** `enemy_death`, `stagger`, `enemy_telegraph`, `boss_telegraph`, `boss_slam`, `boss_roar`, `boss_phase`, `boss_death`.
- **World:** `chest_open`, `pickup`, `pickup_rare`, `exit`, `petilasan`, `lontar` (clue shimmer), `shortcut_open`, `puzzle_solve`, `kabut`, `memory_in/out`, `save`, `wrong`.
- **UI:** `ui_move`, `ui_confirm`, `ui_back`, `ui_open/close/page` (the field book: lontar leaf turn), `ui_slider`, `ui_choice`, `ui_start`.
- **Dialogue:** `blip` (3 variations), soft bamboo knocks; the speaker key's hash picks one of 6 pitches so each character has a recognisable voice (narration is quieter).

## 5. How the game plays it

`autoload/audio.gd` (Audio) + `components/snd.gd` (`Snd`, the static front door: `Snd.play("hit_light")`, `Snd.music("title")`, `Snd.jingle(...)`, no-op when the autoload is missing).

- **Buses:** Master > Music, SFX, Ambience. Created on start; volumes come from `user://settings.cfg` (`vol_music`, `vol_sfx`, `vol_ambience`); the Sistem tab has a slider for each (`UI_SYS_AMBIENCE`). Music and Ambience carry a low-pass filter that closes while the menu is open (1.7 kHz) or while casting (1.1 kHz). Master ends in a hard limiter (-0.5 dBFS); SFX has a light compressor; Music has a compressor side-chained to SFX, so a burst of hits dips the music about 2 dB instead of piling up.
- **Fades** run in linear amplitude on an equal-power curve (a dB-linear fade from -80 is silent for most of its length, then pops). Zone crossfade 2 s, combat layer in 0.8 s / out 3 s, boss in 1 s, ambience 3 s. **TUNE.**
- **SFX voices:** 16 players; a new sound takes a free player first and only steals the one that has played longest.
- **Zones:** `Events.zone_entered(id)` -> `plan_for(id)` -> base track (+ combat + boss + ambience + footstep surface). Unknown ids (test zones) change nothing. The same base id never restarts.
- **Combat layer:** polled 4 times a second. An enemy within 230 px that is chasing, winding up, attacking, recovering or staggering (EnemyBase `State` 1-6), or any enemy within 90 px, starts combat; it lingers 4 s. The combat layer fades in over 0.8 s and the base ducks 13 dB (synced) or 40 dB (towns and dark zones, where the combat track starts from 0).
- **Bosses:** a node in group `boss` with `engaged` and `health.hp > 0` (the HUD's rule) -> `boss_roar` + `boss_intro` stinger + the region's boss theme; base and combat go silent but keep playing, so the zone music resumes mid-phrase afterwards. A phase change plays `boss_phase`; Batara Kala phase 3 switches to `boss_kala_2`. `Events.boss_defeated` plays `boss_death` + `victory` and holds the music silent for 9 s, then the zone fades back.
- **Death:** `player_died` plays `player_death` + the `death` stinger and holds the music for 7 s; the respawn's `zone_entered` brings the zone back.
- **Memories:** `memory_started` -> `memory_in` (reversed gong), `kelir` (or `ruwatan`) music and ambience; `memory_done` -> `memory_out`.
- **Scenes:** title, prologue/epilogue, name entry and class select call `Snd.music(...)`; the next zone takes the music back.
- **Story cues:** a dialogue line `#music:<id>`, `#music:` (silence), `#sfx:<id>`, `#amb:<id>`, `#jingle:<id>` is handled by Audio (scene_cue), so scripts can score a beat without code.
- **UI sounds are automatic:** Audio hooks `SceneTree.node_added`; every `BaseButton` gets move (focus/hover) and confirm (pressed) sounds, every `Slider` a tick. Explicit hooks: field book open/close/page turn (`menu.gd`), dialogue blips (`dialogue_box.gd`), area card stinger (`area_title.gd`).
- **Hooks in gameplay code** (all `Snd.play`, one line each): `player.gd` (swing per combo hit, dodge, perfect dodge, hurt, shoot, flask, hit light/heavy/kill, blocked -> stamina_empty/wrong, Footsteps child), `enemy_base.gd` (stagger), `boss_kit.gd` (telegraphs, slam when shake >= 3 px, roar), `chest.gd`, `shortcut.gd`, `zones.gd` (exit), `cast_overlay.gd` (cast begin/end, ink, fail). Events handled in Audio: `spell_cast` (spell sound + quality chime), `enemy_killed`, `item_picked`, `clue_examined`, `puzzle_solved`, `trial_completed`, `petilasan_activated`, `rested`, `quest_started/updated/completed`, `glyph_learned`, `area_cleared`, `class_chosen`, `name_written`, `dialogue_*`, `Game.saved`.

## 6. The pipeline (`tools/build_audio.py`, `tools/gen_music.py`, `tools/audio/`)

Run both with `/usr/bin/python3` (it has numpy; nothing to install). Decoding is ffmpeg; Ogg is written through libsndfile (this ffmpeg has no Vorbis encoder).

- **Recorded and downloaded sounds:** `tools/audio/sources/{sfx,amb,music}.json` map each id to its source file(s), trim window, layers, gain and variations. `build_audio.py` downloads into `tools/audio/raw/` (git-ignored cache), trims, layers, normalises and writes `assets/audio/`. `--only sfx/hit`, `--check` (peaks, leading silence, loop seams, loudness), `--audition` (writes `tools/audio/audition.html`, every sound with a play button). **To swap a sound, edit its manifest entry and rebuild that id.** Four sfx sources are `.7z` archives (`oga_misc/arrowhits`, `explosions`, `qubodup-SpeedUpSlowDown`, `qubodup-WisdomMagic_0`) that the tool cannot unpack: on a fresh clone, extract them by hand into those folders under `raw/`.
- **Composed music:** `gen_music.py` renders the region layers, `kelir`, `ruwatan`, `select`, `intro` and the stingers from `tools/audio/` (`theory.py` scales, `tracks.py` themes and arrangements, `music.py` arrangement engine, `inst.py` instruments, `jingles.py` stingers, `intro.py` the launch score, `dsp.py` mixer). `--only explore_sunda,victory`. Strings, harp, flutes, fiddle, oboe, zither, vibraphone (gender), basses and hand drums are recorded multisamples played by `sampler.py` (VSCO-2 CE and VCSL, CC0; fetch once with `cd tools/audio/raw && aria2c -j12 -c -i ../sources/multisamples.txt`); the bronze (saron, bonang, kenong, kempul, gong body), angklung, choir and drone stay modelled. Every loop plays its 16 bars twice: pass A sparse and orchestral, pass B with the gamelan and a second voice. The intro and `boss_intro` reuse built sfx, so run `build_audio.py` first.
- **Composition format:** a theme is `bal` (balungan: 8 bars x 4 one-beat tokens) + `lead` (8 bars x 8 half-beat tokens), digits are scale degrees, `'` up an octave, `,` down, `.` rest, `-` hold. Chord roots come from each bar's first balungan note.
- **Registers:** `Theme.f(degree, octave, lo)` clamps an instrument to its real range. Do not add instruments without a `lo`.
- **Levels:** music -18 LUFS (boss -16), ambience -27 LUFS, all capped at -1.5 dBFS; sfx and stingers peak-normalised per sound (`peak` in the manifest: UI -10 to -18, steps -14, hits -2 to -5).

## 7. Tuning by ear

1. Open `tools/audio/audition.html`, note the ids that sound wrong, swap or re-trim them in the manifest.
2. **Per-sound volume:** `peak` (sfx) or `lufs` (music, ambience) in the manifest, or `vol_db` at the call site.
3. **Transitions:** the fade seconds in `Audio` (`FADE_*` constants) and the combat duck (`Audio._mix`, -13 dB).
4. **Melodies:** the balungan/lead strings in `tracks.py`; re-run `gen_music.py --only <id>`.
5. **Footstep rate:** `Footsteps.STRIDE`. **Combat radius/hold:** `Audio.COMBAT_RANGE`, `COMBAT_HOLD`. **Blip rate:** `vis % 2` in `dialogue_box.gd`.

## 8. Known gaps

- Downloaded tracks are not tempo-matched to anything, so boss and town music crossfade rather than layer.
- No positional audio: all sfx are non-spatial (the camera is top-down and the view is small).
- Enemies share one telegraph, stagger and death sound; per-kind voices wait for the bestiary pass.
- Weather and time-of-day ambience swaps are not modelled.
- **VERIFY:** that the tunings and the pairing of scales to regions (degung for Sunda, pelog for the courts, slendro for Mataram, a harder pelog for the east) are acceptable to practitioners; the compositions are original and not transcriptions of any traditional piece.
