# Aksara Kala (The Script of Time): Session Handoff

Authoritative development status and system architecture reference for **Aksara Kala** as of **2026-11-10**.

---

## 1. Project Overview
- **Title:** Aksara Kala (The Script of Time)
- **Genre:** Top-down 2D pixel-art action RPG set in the mythical folklore and living heritage of Java and Sunda.
- **Engine:** Godot 4.7 (`res://project.godot`), GDScript.
- **Platform:** macOS, Windows, Linux (Compatibility renderer, web export ready).
- **Core Experience:** Real-time action combat (3-hit combos, directional dodges, perfect-dodge rewards, poise breaks, and attack tokens) paired with a unique spellcasting mechanic: drawing authentic **Aksara Sunda** and **Aksara Jawa** glyphs in slow-motion with the mouse.
- **Goal:** A deep, complete, high-quality narrative action RPG with full cultural resonance and zero repetitive design.

---

## 2. Active Design & Narrative Canon (Story v5)
- **Narrative Spine:** "Aksara yang Terlupa: Gerhana Kala & Jejak Laras" ([story.md](story.md)).
  - The hero sets out from Desa Purwa to rescue their younger sister **Laras**, whose True Name and soul were taken by the **Nameless Hunter** (*Si Tanpa Ngaran*) to break the Four Great Seals and awaken **Batara Kala**.
- **Scope & Runtime:**
  - **Main Campaign:** 138 steps across 7 distinct regions (Desa Purwa hub + 6 major acts, 49 areas total), modeled at ~21.5 hours of main quest (~35+ hours for 100% completion).
  - **Side Stories:** 20 rich side and companion quests (~7+ hours) featuring two-way resolutions, folklore investigations, and multi-act companion chains (`SQ-C1`–`SQ-C4`).
- **Anti-Repetitive Regional Structure:**
  - **Prologue (Desa Purwa):** Peaceful village life, Ciung Wanara's egg, the Sanggar Ruwatan ceremony, and the night raid.
  - **Act I (Tatar Sunda):** Rising floodwaters, environmental navigation, Sandekala dusk duel, Faceless Captain, and Sangkuriang at Tangkuban Perahu.
  - **Act II (Keraton Galuh):** Royal court infiltration, genealogy archives cipher, Ririwa elite, and unmasking Prabu Barma Wijaya.
  - **Act III (Mataram):** Two-front war, night-building siege of Candi Seribu, Bandung Bondowoso, and the river duel with Hariang Banga at the Pamali boundary.
  - **Act IV (Tanah Timur):** 3-zone stalking predator ambushes (Buto Ijo), 7-generation blood-curse investigation, Cursed Keris Mpu Gandring, and unmasking the Nameless Hunter (Aria Kebonan).
  - **Interlude (Desa Purwa):** Quiet village return, doorpost protections, and preparing for the southern sea.
  - **Act V (Segara Kidul):** Mangrove maze, coastal restoration, Three Sacred Sea Trials, and receiving *Ombak* from Nyi Roro Kidul.
  - **Act VI (Gua Kala):** Reclaiming the lost syllables `La-Ra-Sa` across memory gaps, dual-perspective battle against Batara Kala with Laras, and calming the devouring eclipse.
  - **Epilogue (Desa Purwa):** Playable celebration day bringing together surviving allies and redeemed figures based on campaign choices.
- **Cross-Time Laras Chapters (`LC1`–`LC6`):**
  - Interactive playable chapters where Laras sabotages enemy operations in captivity, placing physical shortcuts (`laras_key:*`) and exposing boss vulnerabilities (`laras_sabotage:*`) in the present.
- **Six Major Choices:**
  - One irreversible moral choice per Act (`choice_tell_ciung`/`choice_keep_secret`, `choice_freed`/`choice_handed`, `choice_mercy`/`choice_judgment`, `choice_reforge`/`choice_sink`, `choice_offer_memory`/`choice_offer_song`, `choice_redeem_aria`/`choice_release_aria`) that ripples into companion availability, regional politics, combat bonuses, boss phases, and the Epilogue.

---

## 3. Systems & Technical Architecture

### 3.1 Display & Rendering ([architecture.md](architecture.md))
- **Native Resolution:** 480x270 viewport, 3x window default (1440x810), `canvas_items` stretch with `integer` scaling and `keep` aspect ratio.
- **Renderer:** Compatibility renderer for optimal 2D performance and web compatibility.
- **Filter:** `Nearest` canvas texture filtering preserves sharp pixel art; pixel transforms and vertices snapped to whole pixels to prevent shimmering.
- **Typography (UI v2/v3):** Four pixel-true steps from `UIFx` (`ui/fx/ui_fx.gd`):
  - Body: Tiny5 8 px (cool cream `#ECE6F2`).
  - Label: Tiny5 8 px tracked CAPS (`#A99BC8`).
  - Heading: Jersey 10 at 19 px (`#FFF4E6`).
  - Display: Jersey 15 at 27 px (logo 54 px).
  - Aksara Script: Noto Sans Sundanese and Noto Sans Javanese.

### 3.2 In-Game HUD & UI ([ui.md](ui.md))
- **Look (v3 "Senja"):** Twilight indigo surfaces (`#141026`), banded dusk sky backdrop, cyan accents (`#7FE8E0`) for focus/magic/selection, warm amber (`#F2B27A`) for quests/loot/Ilmu, and rose (`#E0566A`) for danger.
- **HUD Layout:**
  - Vitals top-left (8, 8): HP (100x6 with "hp/max" label), stamina (72x3), and sakti (60x3).
  - Quest Tracker top-left (8, 36): 124 px ink strip displaying quest name in gold caps, active objective with gold diamond, and checklist counts `(n/m)`.
  - Quest Banner top-centre: sleek 15 px ink pill with gold caps kicker and quest title.
  - Notifications top-right: item and glyph discovery toasts queue cleanly below the Ilmu counter. Quest step hints are kept inside the Journal menu only, keeping the HUD quiet.
  - World Navigation: screen-edge directional chevron showing distance in meters or target zone name (`-> <zone>`), plus floating in-world gold diamond 46 px over active targets.
  - Dialogue Box: 400 px centered ink panel with 48x48 character portrait bust in a 56x56 well, speaker name with first-meeting tag (`NPC_<id>_WHO`), typewriter text, and animated continue mark.
  - Dynamic Focus: HUD elements fade out over 0.2 s during dialogue and cutscenes.

### 3.3 Pause & Tab Menu (7 Tabs)
- **Field Book Frame (`ui/menu/menu_book.gd`):** Two-page dusk star-chart book (~464x248) with Q/E navigation and context footer.
- **Direct Map Keybinding:** Pressing `M` directly opens and toggles Tab 3 (Peta / Map).
- **Tabs:**
  1. **Diri (Status):** 96x128 animated class figure, level, Ilmu progress, 5 attributes with point allocation, derived stats table, and learned glyphs.
  2. **Perlengkapan (Equipment):** Paper-doll slot display (Weapon, Armor, Accessory) and inventory grid with comparison indicators.
  3. **Catatan (Journal):** Main, Side, and Completed quests with step checklists, story logs (`_DONE` entries), choice consequences, and clue notes.
  4. **Peta (Map):** Illustrated world map (`assets/art/ui/map_world.png`, `map_fog_*.png`, `map_icons.png`) with region colour casts, landmark icons, and fog-of-war tracking (`seen_zone:<id>`). DUNIA/AREA view toggle zooms into pixel-painted area maps (`MapRender.painted()`).
  5. **Pustaka (Codex):** Lore, Creatures (with stats and weaknesses), Heirlooms, and Aksara stroke-order animated guides.
  6. **Penuntun (Controls):** Live InputMap bindings display, keycap indicators, aksara drawing guide, and remapping tools.
  7. **Sistem (Settings):** Master/Music/SFX/Ambience audio sliders, display resolution/fullscreen toggles, accessibility settings, and Indonesian/English language toggle.

### 3.4 In-Story Tutorial Ladder ([tutorial.md](tutorial.md))
- Replaces any standalone tutorial rooms with organic, quiet in-story learning in Desa Purwa:
  1. `dodge`: Laras tag game (0.1) teaches movement, obstacle evasion, and stamina cost.
  2. `attack`: Cepot at the sanggar (0.5) teaches combos and stamina recovery.
  3. `rest`: Ibu in the morning (0.10) teaches Petilasan activation, checkpointing, and healing.
  4. `cast`: Semar after Ka is learned (0.11) teaches slow-mo drawing, release, and sakti gating.
  5. `flask`: Triggered on first player hurt (0.10+) to teach jamu healing charges.
  6. `perfect`: Triggered on subsequent hurt in combat to teach rolling into attacks for stamina refunds and sakti gain.
- Lessons display as single ink pills at bottom screen (`ui/tutorial.gd`), never pausing or blocking gameplay, and complete automatically upon performing the action.

### 3.5 Kelir v2 Memory System ([architecture.md](architecture.md))
- Built around `zones/kelir/kelir_stage.gd` (`KelirStage`, CanvasLayer 7) providing authentic wayang shadow-puppet staging:
  1. **Curtain-Up:** 2.7 s cinematic opening with title card, subtitle, and lifting veil.
  2. **Dalang Narration:** Semar's opening lines (`MEM_<ID>_IN`) framing the cultural legend.
  3. **One-Verb Teach:** Clear objective pill with live keycap and visual hint rings.
  4. **Threat Tracking:** Dynamic threat distance meter and visual warning flashes.
  5. **Closing Tableau:** Flash transition into the completed painted tableau and closing lines.
- Complete sprite-based presentation for `k0_ruwatan.gd` (Wayang raksasa Batara Kala with 3 poses, shadow tide, lamp ignition/glow/hint sprites, and pointing wayang hand).
- Memory kinds: `play` (interactive mechanics, e.g. K0–K7), `walk` (movement and narrative triggers), `chapter` (cool-blue Laras stealth segments `LC1`–`LC6`), and `gap` (Act VI syllable recovery).

### 3.6 Real-Time Combat & Poise ([combat.md](combat.md))
- 3-hit weapon combo system with finisher multipliers (x1.5 damage, sakti, interval, and x2 poise damage).
- Directional dodge with 0.25 s invulnerability; perfect-dodge window (first 0.15 s) refunds stamina and adds +10 sakti.
- Poise and stagger meters across tanks (60% HP), elites (30% HP), and bosses (12% HP).
- Four clean status effects: Burn (damage over time), Slow (movement penalty), Bound (rooted), and Curse (sakti generation blocked).
- Attack token manager prevents visual chaos by restricting active simultaneous enemy attacks (max 2 melee, 2 ranged).
- Dedicated sprite pass: facing pointers, arrows, thrown rocks, spirit shots, boss blades, boss orbs, and curse stakes are rendered as authentic pixel art.

### 3.7 Spellcasting & Gesture Recognition ([spells.md](spells.md))
- Real-time point-cloud recognizer (`components/recognizer.gd`) compares mouse strokes against recorded templates.
- Slow-motion activation: holding Right Mouse drops world time scale to 20% (requires 15 sakti to initiate, with 1.0 s lockout on cancel/fizzle).
- 9 Glyphs:
  - Sunda: `Ka` (Bolt), `Ga` (Ward), `Nga` (Bind), `Ca` (Burst).
  - Jawa: `Ha` (Heal), `Na` (Dash-strike), `Ca` (Rally), `Ra` (Summon), `Ka` (*Ombak*).
  - Write-only true name glyphs: Sunda `La`, `Ra`, `Sa` for the final Ruwatan ceremony.
- 32 distinct class-specific spell variants across Hulubalang, Pamanah, Pendekar, and Wiku ([classes.md](classes.md)).
- Perfect Cast: scores >= 0.92 gain +12% power, gold visual flourish, and camera nudge.

### 3.8 Recorded & Layered Audio ([audio.md](audio.md))
- 2026-11-12 audio redesign: recorded sfx (with variations) and field-recording ambience, downloaded set-piece music, region layers and stingers rendered with sampled instruments. Built by `tools/build_audio.py` (manifests in `tools/audio/sources/`) and `tools/gen_music.py`, run with `/usr/bin/python3`. Sources are not cleared for release. Audition page: `tools/audio/audition.html`.
- Authentic modal scales (Sunda degung/madenda, Javanese slendro/pelog) and traditional instrument models (saron, bonang, gender, gong ageng, kendang, suling, rebab, angklung).
- Layered Audio singleton (`autoload/audio.gd`) with dynamic exploration, tension, and boss transitions.

### 3.9 Save & State Management ([rpg.md](rpg.md))
- Single slot autosave to `user://save.json` (schema version 3) with atomic temp-file renaming and `save.bak` recovery.
- Milestones: resting at Petilasan, boss defeats, quest updates, choice commitments, and gear acquisitions trigger immediate saves.

---

## 4. Cultural Accuracy & Ethics
- **Historical Orthography:** Hanacaraka and Kaganga script structures verified against Museum Sonobudoyo and Kairaga historical records.
- **Living Heritage & Rituals:** Authentic representation of Wayang Ruwatan, sedekah laut, labuhan, and gamelan traditions.
- **UNESCO Intangible Heritage Elements:** Wayang (2008), Kris (2008), Batik (2009), Angklung (2010), Gamelan (2021), Jamu (2023).
- **Sacred Figures:** Batara Kala, Nyi Roro Kidul, and Semar are portrayed with dignity and respect, never treated as disposable monsters.

---

## 5. Current Implementation Status & Tests

### Verification Toolchain (100% Passing)
- `python3 tools/quest_audit.py` -> **0 problems** (verifies 30 quests, 90 dialogue resources, 4,755 text keys, step alignments, and exit markers).
- `python3 .docs/know_check.py` -> **37 names checked, 0 failures** (verifies proper narrative introduction order).
- `python3 .docs/pacing_model.py` -> **138 main steps (1,290 min), 20 side quests (454 min) fully aligned**.
- `python3 .docs/glyph_strokes.py` -> All glyph recognition simulations pass confusability thresholds.
- `python3 .docs/balance_model.py` -> Class DPS, TTK, and scaling curves verified.
- `python3 .docs/gen_quest_guide.py` -> Generates synchronized `quest_guide.md` from live quest data.
- 2026-11-12 quest and dialogue rewrite (quests.md 9, story.md Voice & Continuity Bible): all quest rows and dialogue rewritten Indonesian first; every `puzzle_solved` step is a real prop (audit check in `tools/quest_audit.py`). Cutscenes: `ui/scene_director.gd` gives an absent or far beat speaker a stand-in sprite beside the hero for the beat (ASSUMED; place the NPC in the zone doc where a stand-in reads badly); absent Semar stays a voice. `tests/cutscene_test.gd` fails on any speaker or `#cam` target out of frame. Open: orphan text rows not deleted; deserter lines for `tt_pasir`/`sk_pantai` never fire; no HINT rows for MQ2/MQ4.
- 2026-11-12 test repair: all 80 headless tests pass (incl. `demo_test`). The 6 failures were stale tests, not game bugs: Hunter's move deck is shuffled (pin `forced_move`), a clean template draw is a Perfect cast (power x1.12), the cast leaves an FX sprite in the world, Rally boosts by class, and stronger Bolt/Dash-strike numbers overkill (count `damaged`, not hp left). `know_check.py` 0 fails: DLG_SUNDA_ELDER_V3, DLG_SUNDA_ELDER_V6 and DLG_LENGSER_V204 now say who Sandekala, the Weaver and Nyai Sekar are (script.md and dialogue.csv edited by hand). Open: `script_to_data.py` is out of step with the CSVs: a run rewrites `beats.tres`, keeps the CSV text for edited rows (`kept_csv`), and deletes DLG_LENGSER_V2-V4, DLG_MATARAM_DALANG_V3, DLG_MBOK_SRINI_V3 (in dialogue.csv, not in script.md). Reconcile before running it again. Test loops on macOS: no `timeout`, use `perl -e 'alarm 180; exec @ARGV'`.
- 2026-11-12 performance pass ([performance.md](performance.md)): zone builds 1.8x faster with byte-identical output (all 46 zones fingerprinted by `tests/perf_probe.gd`); a quest event in Desa Purwa 190 ms -> 2 ms (`QuestData.by_id` now caches `res://` quests); Audio drops music/ambience the zone does not use (+105 MB -> +10 MB over a full walk). Same 8 test failures before and after (pre-existing: aksara_render, cast, chaser, hunter, loop, room_smoke, ui, weakness). Run the probe after touching zone build, deco, town life, quest data or Audio.
- 2026-11-12 verification fixes ([verification.md](verification.md) §5): Choice 3 Judgment now gives `sabuk_galuh` and Choice 4 Reforge gives `keris_mpu_gandring` (was the codex id `keris_gandring`; script.md, gen_quests.py, mq3.tres, beats.tres; `tests/item_source_test.gd`). The freed Faceless Deserter (`R`) now stands in `tt_pasir` and `sk_pantai` (zone docs) so `c3_b`/`c3_c` fire (`tests/npc_zone_test.gd`). The duplicate clue `c3_shore_net` in `sk_nelayan` is removed; the one in `sk_pantai` stays. `.docs/script_to_data.py` is safe to run again: shipped beats win (cue edits kept, differences listed as `kept_beat`) and §14 drops are only listed unless `--drop` is passed. MQ1–MQ5 journal tips (`Q_*_S<n>_HINT`, 126 rows) added. The title About card scrolls (wheel, Up/Down) and credits the 14 Kevin MacLeod tracks (CC BY 4.0, `UI_ABOUT_MUSIC`; ui.md About).

### Headless Godot Test Suite
- Run via `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -s tests/<name>.gd`
- Core suites: `tutorial_test.gd`, `menu_test.gd`, `k0_test.gd`, `memory_test.gd`, `clue_test.gd`, `ui_test.gd`, `choice_effects_test.gd`, `recognizer_test.gd`, `save_test.gd`, `combat_test.gd`, `audio_test.gd`, `loop_test.gd`.

---

## 6. Next Development Priorities
1. **Engine Import & Verification:** Run Godot import pass (`$GODOT --headless --path . --import`) and execute the complete headless test suite.
2. **Gameplay Walkthrough & Balance Review:** Playtest from New Game through Desa Purwa and Tatar Sunda to verify tutorial pacing and boss mechanics against [balance.md](balance.md).
3. **Audio Ear Tuning:** Open `tools/audio/audition.html` and play one region end to end; swap or re-trim sounds in the manifests as outlined in [audio.md](audio.md) section 7.
4. **Cultural Codex Citations:** Finalize the "Sumber" source citations for folklore entries in `data/text/codex.csv`.

5. **Phase 4g class depth (2026-11-12):** built: the four second paths have their own kit (9 spells each in `spells/path_<class>.gd`, signature aksara Jawa Ga / Sunda Ba / Sunda Ta / Jawa La) and mechanic (Kuda-kuda, Batu Pantul, Wirama, Lakon); 32 class-favoured items (16 school items in 12 chests, 16 siblings swapped in by `Game.add_item` for the second path, `SIBLING_ITEM`); `SQ-X1` from Nyai Rukmi gives all eight classes their signature aksara and a class weapon; the `class:` cond; `tests/second_path_test.gd`. 715 chest Ilmu became gear. Still by hand: draw the four new shapes in `tools/glyph_recorder.tscn`, play each second path for feel and numbers (all **TUNE**), check the **VERIFY** names in [classes.md](classes.md) and [items.md](items.md), redraw the recoloured icons. `balance_model.py` now has eight classes but does not model the four mechanics.
---

## 7. Standing Operational Rules
- **Source of Truth:** Design docs under `.docs/` are the authoritative source of truth. If code requires a design update, synchronize the doc first.
- **Token Efficiency:** Follow targeted line-range reads (`sed -n`, `grep`), never dumping massive files unnecessarily.
- **Deterministic Blocking:** Never use arbitrary `sleep` or polling loops; rely on deterministic state checks.
- **Clean Git Status:** Before concluding any task, verify with `git status` and `git diff --stat`. Leave no scratch files, debug logs, or unintended edits.
- **No Third-Party Attribution in Commits:** All git commits must be made solely by the user without AI co-author trailers.
- 2026-11-11: quests.md §9 added: quest flow v6 (old → new), pending user approval. Step numbers unchanged; fake puzzles become real props; broken gates listed. Fold into §4–§6 after approval.
- 2026-11-12: Demo mode (user call): title **Demo** card, `ui/demo_route.gd` replays the story through the real quest engine to any act start, area arrival or boss door ([architecture.md](architecture.md) 10b). Own save slot. `tests/demo_test.gd` not yet run (no Godot in the cloud session): run it, and the i18n import for the 6 new `UI_DEMO*` keys.
- 2026-11-11: quests.md §9 (quest flow v6) approved by the user; it overrides §4–§6 where they differ. Build in progress (props, gates, text rewrite).
- 2026-11-12: hero and boss redesign (user call), built in a cloud session with no Godot: **nothing below has been imported or run**. Hero sprites are 32x32 cells (sheets 192x576, 6-frame walk; `player.gd`, `player.tscn`, `stand_in.tscn`, `title.gd`, `memory.gd` follow). 8 classes: lancer, herder, dancer, dalang added as second paths that use a school's spells ([classes.md](classes.md) Schools); 4 new starter weapons (`tombak_prajurit`, `kipas`, `bandring`, `kayon`), 28 new rows in `items.csv`. New class figures and per-class hero busts (`ui/portraits.gd`). Boss staging `ui/boss_stage.gd`, boss bar ghost, telegraph ornaments ([combat.md](combat.md) 5.3). Batara Kala redrawn (`tools/gen_boss_kala.py`, 96x80 cells). To do on a machine with Godot: import (new PNGs, `.uid`s, translations), run the full suite (`art_test`, `attack_fx_test`, `items_test` were edited for the new sizes and items), then check in game: sprite foot position, class select with 8 rows, the entrance card, Kala's size against his hitboxes. Open: the other nine boss sheets, second-path balance, the VERIFY tags in classes.md.
- 2026-11-12: verification pass done ([verification.md](verification.md) §5); B1–B4 fixed and re-checked in game. Run `script_to_data.py` without `--drop` unless the user approves deleting the listed rows; open items are in §5.8.
- 2026-11-12: hero and NPC art pass (user call), built in a cloud session with no Godot: **not imported or run**. Class-select figures and per-class hero busts redrawn with one pose per class (`tools/gen_portraits.py`; same files and sizes). `npcs.png` is now 32x32 cells, 128x448 (`Npc.CELL`; `npc.gd`, `stand_in_laras.tscn`, `scene_director.gd`, `art_test.gd` follow; [assets.md](assets.md)). To do with Godot: import, run `art_test`, check NPC feet, shadow and talk-marker height in a zone, and the figure on the class-select pedestal. Open: the fallback `p_hero*.png` busts keep the old face; normal enemies are still 16x24.
- 2026-11-13: boss fights v7 (user call; [combat.md](combat.md) 5.3, [quests.md](quests.md) §10, [architecture.md](architecture.md) 9). Built: `arena_gate` (threshold engage, shut gate, sealed exits, retry at the gate) in 7 arenas, paused entrance pan and name card, hint pill and glyph ring on each boss's gimmick, TERBUKA punish tag, phase ticks from `phase_marks`, kneel and finishing glyph (6 bosses), arrow fallback for unmarked sub-goals, `cond` on the Keris and Batara Kala, door-step quest text for all 10 bosses, `tools/set_text.py`, `sfx/gate_slam.wav`. The parts left open by that run are covered by the next line.
- 2026-11-13 (second run): boss fights v7 finished in a cloud session with no Godot: **nothing below has been imported, parsed or run by the engine**. Built: `rehearsal` objects (props `id, glyph, boss, look, cond`; once-only; a boss's defeat completes its rehearsal so the blocking sub-goal cannot strand a quest) for the Captain, Sangkuriang, Barma, Hariang Banga, Bondowoso, the Hunter and Kala with `clue_examined:reh_*` sub-goals on 1.22, 1.23, g.19, 2.23, 2.18, 3.22, 5.12, plus an optional `reh_keris`; a phase-2 floor change per boss and `_clear_attack` kneel clean-up in all ten boss scripts ([combat.md](combat.md) 5.3 table); gates on both mouths of the Pamali ford (`kg_pamali`, rock lines on both banks; `arena_gate.gd` now counts "inside" as past every gate's threshold); finishers for Barma (Sunda Nga), Hariang Banga (Jawa Na, at his 15% yield) and Buto Ijo (Jawa Ra, lair only), all **ASSUMED**; "Cara melawan" codex paragraphs for ten bosses incl. the new `CODEX_SANGKURIANG_WEAK`, revealed by `weakness_triggered` at the rehearsal or the kneel; `sfx/boss_intro` and `boss_finish` in the audio test and [audio.md](audio.md), and the engage roar is no longer doubled in gated zones (`autoload/audio.gd`); `tests/rehearsal_test.gd`; rehearsal steps in `mataram_play_test`, `timur_play_test`, `kala_play_test`; `balance_model.py` 7.2 (hazard budget; Sandekala tick 5 to 3, Buto Ijo 8 to 7, Keris pool 7). Threshold fixes: `kg_keraton` guards `T` moved out of the throne room to the courtyard road (their rect covered the arena); `mt_candi` encounters `F I J` now end at `mq2_7`; the Hunter wakes only after the `hunter_shrine` beat (`flag:mq3_h6,flag:beat_hunter_shrine`). Python checks pass (`quest_audit` 0 problems, `know_check` 0 fails, `pacing_model`, `glyph_strokes`, `balance_model`). **To do with Godot:** import (new `boss_intro.wav` / `boss_finish.wav` have no `.import`; `rehearsal_test.gd` has no `.uid`; codex and quest text changed), treat any `SCRIPT ERROR` as a failure (ten boss scripts, `arena_gate.gd`, `rehearsal.gd`, `boss_kit.gd`, `audio.gd` were edited blind), run the full suite, then one played attempt per arena. Watch for: `captain_test` / `galuh_boss_test` / `duel_test` / `buto_test` against the new kneel and `weakness_triggered` emit; the play tests' `do:reh_*` steps (reachability of each object while its step is active); the Pamali duel entered from the east bank. Open: minibosses spawned by encounter waves (`faceless_champion`, `arca_penjaga`) still have no `unique_id` (`encounter.gd` cannot pass props per wave entry); the Keris's stakes are off-screen from the threshold; `kala_p2` / `kala_p3` beats are never set by code; trigger `crater_post` in `ts_kawah` fires at the threshold and nothing listens; `.docs/gen_quests.py` is stale and would overwrite hand edits in the quest `.tres` files: do not run it; the lake side of the `ts_kawah` arena (west) and all hazard numbers are **ASSUMED** / **TUNE**.
