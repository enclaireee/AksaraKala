# Roadmap

No fixed dates. Phases run in order. Each phase has **exit criteria**: do not start the next phase until they hold. Tick boxes as you go. Priority tiers are in [scope.md](scope.md).

## Phase 0: Project setup
- [x] Project settings for pixel art (see [architecture.md](architecture.md))
- [x] Folder structure, autoloads, input map, physics layers
- [x] Version control and `.gitignore` check
- Exit: an empty scene runs at 480x270, scaled with crisp pixels. **Done 2026-11-05** (user confirmed). Aksara render test passes: HarfBuzz shapes pre-base vowels and pasangan (`tests/aksara_render_test.gd`).

## Phase 1a: Combat core (feel first)
**Done 2026-11-05**: the user playtested one chaser in the test room and confirmed the feel.
- [x] Player scene: move, aim, state machine, input buffer ([controls.md](controls.md) 3)
- [x] Stamina and health components
- [x] 3-hit combo for melee and ranged, dodge with i-frames ([combat.md](combat.md))
- [x] One chaser enemy with chase, a telegraphed attack and flinch
- [x] Hit flash, hit-stop, screenshake, `CombatTuning` resource
- [x] One test room with tilemap and walls
- Exit: fighting one chaser in one room feels good with placeholder art. Do not start 1b until it does.

## Phase 1b: Combat depth
- [x] Perfect dodge
- [x] Poise and the tank role, enemy turn speed (backstab window)
- [x] Statuses component (Burn, Slow/Bound, Stagger, Curse)
- [x] Attack tokens, a shooter enemy, one 3-4 enemy mix from [bestiary.md](bestiary.md) Encounters
- Exit: the mix is readable, and the combat.md section 8 checks pass.

## Phase 2: Aksara casting (the gimmick)
- [x] Cast mode: slow-mo, vignette, ink trail
- [x] Recognizer ($P or $1) and glyph data resource
- [x] Glyph recorder tool and the first 3 glyph templates (start from the designs in `glyph_strokes.py`)
- [x] Confusability check verified across all 12 glyphs (`python3 .docs/glyph_strokes.py`)
- [x] Sakti gauge and the first 3 spells
- [x] Sanggar practice scene with ghost guide
- Exit (built 2026-11-05, waits for the user's recorded templates and playtest): a new player can learn to draw a glyph in the sanggar and cast it in combat with at least 90% success on a clean stroke, and the wrong spell is never cast by accident. Ga/Nga and Na/Ca fizzle under 10% on honest drawings, otherwise swap Nga.

## Phase 3: RPG loop
- [x] `Game` autoload: class, stats, Ilmu, glyphs, gear, last petilasan
- [x] Autosave and Continue: `Game.to_dict()`/`from_dict()`, safe write, round-trip test ([rpg.md](rpg.md) 11)
- [x] Classes and class select (4 cards)
- [x] Petilasan: heal, flask refill, level-up UI, respawn
- [x] Death and respawn, enemy respawn
- [x] Remaining 5 glyphs and spells
- Exit (built 2026-11-05, waits for the user's playtest): a full loop works: fight, earn Ilmu, rest, level up, die, respawn, quit, Continue with nothing lost.

## Phase 4: First region (Desa Purwa + Tatar Sunda)
- [x] Zone loader and edge transitions, camera bounds
- [x] Desa Purwa with the wayang prologue, Semar, class choice
- [x] Tatar Sunda: tileset, enemies, NPCs, petilasans, boss Sangkuriang
- [x] Dialogue system, quest system (QuestData, journal, marker), CSV string tables (ID/EN), codex v1
- [x] Main quest MQ0-MQ1 and the Cepot side quest ([quests.md](quests.md))
- [x] Extras (user call, 2026-11-05): Sandekala miniboss, SQ-S1 Lutung Kasarung, SQ-S2 Kuntilanak bounty, SQ-S3 Angklung
- [x] Interlocking rebuild of Tatar Sunda (user call 2026-11-05): 8 areas, shortcuts and a drop, from [zones/tatar_sunda.md](zones/tatar_sunda.md) and [world.md](world.md) World structure
- [x] i18n sweep: all existing UI, items and classes become translation keys; ID/EN toggle on the title screen (`user://settings.cfg`, first launch follows the OS locale)
- Exit (main path playtested and confirmed 2026-11-05; SQ-S1 to S4 and Sandekala wait for the user's playtest): New Game to Sangkuriang's release and the Mataram gate opening is playable (about 40 min, [balance.md](balance.md) 2.1), with SQ-S1 to S4 and Sandekala completable, on placeholder art.

## Phase 4b: Story v2 (user call 2026-11-06; built, then superseded by Phase 4c)
The main story becomes the Ciung Wanara integration v2: Laras taken, the Faceless, the Nameless Hunter, Ciung Wanara, Kala. Plan: rewrite every main quest, add Keraton Galuh, and write all main-path dialogue in [script.md](script.md).
- [ ] Name entry, dialogue choices, the name-writing finale ([ui.md](ui.md) 3)
- [ ] The Faceless, the captain, Barma Wijaya, Hariang Banga, the Nameless Hunter ([bestiary.md](bestiary.md) Story v2)
- [ ] Keraton Galuh, 4 areas ([zones/keraton_galuh.md](zones/keraton_galuh.md))
- [ ] Quests MQ0, MQ1, MQG, MQ2, MQ3, MQ5 and the echo side quests SQ-S5, SQ-M5 ([quests.md](quests.md) 4-5), story beats, all text from [script.md](script.md)
- Exit: every test passes; New Game to the credits plays the v2 story with no "return to Semar" steps; the user's playtest says it feels like an RPG and the pace holds.

## Phase 4c: Story v3.1 (user call 2026-11-06)
The main story is now [story.md](story.md) v3.1, with Act III's three leads, the Interlude, Segara Kidul as Act V on the main path, glyphs earned by deeds, camp talks and choice consequences. All docs were updated first (2026-11-06). The code still runs the v2/brainstorm data, so this phase brings the code in line with the docs.
- [x] Docs: story, quests, script, world, every zone doc, bestiary, balance, spells, ui, scope, items, concept, rpg (HANDOFF §5u)
- [x] Quest engine: `all` steps, `goto:<area>:<spawn>`, `restore`, `zone:<area>` condition, and a `glyph_learned:` step that completes at once if the glyph is already known ([quests.md](quests.md) 7.1). `deep-implementer`, with tests
- [x] Quest data: rewrite `data/quests/mq0`-`mq5`, `mqg` to quests.md §4 (71 steps); remove `sq_s5`, `sq_m5` and the bosses' echo conds
- [x] Beats and dialogue: `beats.tres` and NPC dialogue from [script.md](script.md); camp talks; choice consequences; new codex entries
- [x] Zones: regenerate the areas whose maps changed (`gen_zones.py`) and move the kabut flags (`mq4_2`, `mq4_9`); new objects `laras_lontar`, `laras_ribbon`, `seal_stone`, `arca_base`, `hunter_mask`, `laras_wall`; petilasan `kidul_3`; the trial moves to `sk_keraton`
- [x] Items: `batu_kali`; the Choice 3 rewards
- [x] Tests: update the play tests (prologue, galuh, mataram, timur, kidul, kala) and `quest_reach_test` to the new steps
- Built 2026-11-06 (HANDOFF §5x): all 52 tests pass. The Ombak spell is built too.
- Exit: every test passes; New Game to the credits plays the v3.1 story; the user's playtest says it feels like an RPG and measures the minutes per act against the story.md runtime table.

## Phase 4d: Story v4 telling pass (user call 2026-11-06)
The story is now [story.md](story.md) v4 (Pacing rules 10-14, Hunts K0-K7). The aim: the player always knows who a person is, why a boss is there, and what the boss's trick is before the fight. Spec: [architecture.md](architecture.md) 9b, [ui.md](ui.md) 3.
- [x] **Part 1, docs:** story, ui, architecture, bestiary, schedule (this pass, 2026-11-06); then quests.md (clue and memory steps, `recap` field), script.md (name tags, clue lines, memory narration) and the zone docs (clue spots)
- Code order (with Phase 4e, plan 2026-11-06): **Milestone A** = the engine, the UI, `.docs/gen_memories.py` (memory scenes generated from the zone docs, architecture.md 9b) and the elites `ririwa`/`wewe_elite`, then the Prologue and Act I data (all CSVs via `script_to_data.py`, `mq0`, `mq1`, `sq_s1`-`sq_s4`, `sq_c4`, their NPC and camp-talk `.tres`); exit A = the Sandekala playtest below. **Milestone B** = Acts II-VI, the Interlude and the other side stories, two regions at a time; exit B = the Interlude playtest and the Phase 4e exit.
- [ ] **Part 2, code, engine** (`deep-implementer`, with tests): `Clue` interactable (`entities/world/clue.gd`), Kelir memory base and stand-in (`zones/kelir/memory.gd`, `entities/player/stand_in.tscn`), `Zones.enter_memory/exit_memory` and `Game.memory_return` (saved), the lontar shimmer, the name tag in `dialogue_box.gd`, the Journal "Story so far" and Clues sections in `menu.gd`, the new `Events` signals (`clue_examined`, `memory_started`, `memory_done`), memory kinds `walk`, `chapter` (Laras, `faceless_patrol.gd`, checkpoints) and `gap` (`GapMemoryData`), the doorpost write seq ids (architecture.md 9b)
- [ ] **Part 2, code, data:** the MQ0 day (a normal day before the raid), K0 plus all memories (k0-k10, k_ii, k_iii, h1-h4, lc1-lc6, gap_la/ra/sa; story.md Depth pass v4b), the clues placed in each area, all script lines and `NPC_*_WHO`, `CLUE_*`, `MEM_*` keys in both languages, `recap` lines for every main step; zone regen with `gen_zones.py`
- [ ] **Tests:** `clue_test`, `memory_test`, the know-before-you-meet check (script.md order: every name's first use is at or after its introduction, Pacing 10), the key check; update the play tests and `quest_reach_test` for the new steps
- Exit: every test passes; the know-before-you-meet check passes; the user plays New Game through Sandekala and reports that they understand who everyone is and why each boss is there. Then a second playtest through the Interlude: the user says the second half has depth (Laras chapters, the doorposts, the gap memories). If not, fix the lines and clues before Act II.

## Phase 4e: Side stories v4d (user call 2026-11-06)
Side quests get the main path's telling ([story.md](story.md) "Side stories (v4d)", [quests.md](quests.md) 5): side Hunts (hook, 2 clues, a 1-2 min Kelir memory, fight or the legend's peaceful way, aftermath), two Keraton Galuh stories (G1 Si Kabayan, G2 the Ririwa of the Kaputren), companion chains C1-C4, and camp talks in Acts I-V. **No new systems:** it reuses Phase 4d's Clue, Kelir memory, write card and `quiet` entries.
- [x] **Docs:** story.md, quests.md 5 (a `Play` line on every card), bestiary.md, script.md, the 7 zone docs; `pacing_model.py` checks the side size bands (S 5-10, M 10-20, L 20-30 min, TUNE) and that every side Hunt has a clue and a memory
- [ ] **Code, data** (superseded into Phase 4f below)

## Phase 4f: Story v5 Major RPG Expansion & Anti-Repetition Pass (user call 2026-11-06)
Expands the game to **~21.5 h main story (138 steps, 1,285 min modeled, 49 areas across 6 regions + hub; ~35 h+ at 100%)**, breaks the repetitive Hunt formula so every Act/boss has a unique gameplay structure, expands smaller regions (`Keraton Galuh`, `Segara Kidul`, `Gua Kala`) from 4 to 7 areas each (+9 new sub-areas), upgrades `LC1`–`LC6` into cross-time puzzle & boss-sabotage chapters (`laras_key:*`, `laras_sabotage:*`), lifts the 4-line dialogue cap to 8–12 lines with optional `"Ask about..."` topic hubs, and expands choices from 3 to **6 Major Choices** (one per Act) with multi-act character arcs.
- [x] **Step 1, Core Docs & Pacing Blueprint (done 2026-11-06):** `story.md`, `quests.md`, `pacing_model.py` (passes: 138 main steps = 1,285 min, 20 side quests = 454 min), `world.md` (49 areas), `bestiary.md`, `architecture.md`, `ui.md`, `balance.md`, `README.md`, `schedule.md`, `HANDOFF.md`
- [x] **Step 2, Zone Docs & Full Script Sync (done 2026-11-07, HANDOFF §5zd):** update `.docs/zones/*.md` (adding the 9 new sub-areas `kg_pasar`, `kg_pustaka`, `kg_kaputren`, `sk_nelayan`, `sk_bakau`, `sk_gua`, `gk_pelataran`, `gk_hutan`, `gk_jembatan`, plus the new cross-time Laras spots, Buto Ijo stalking ambushes, and environmental puzzles) and `.docs/script.md` (8–12 line talks, `"Ask about..."` topic hubs, 6 Major Choices, and new steps)
- [x] **Step 3, Code & Data Rollout (done 2026-11-07, HANDOFF §5ze–§5zf):** engine support for `"Ask about..."` topic loops, `puzzle_solved` signal, `hunt_id` on `Clue`, and `laras_key:*` / `laras_sabotage:*` boss/gate hooks; regenerate zones (`gen_zones.py`) and memories (`gen_memories.py`); update all 28 quest `.tres`, 48 codex `.tres`, NPC dialogue `.tres`, and CSVs (`script_to_data.py`); update all 55 headless tests (0 failures, 0 warnings)
- Exit: `pacing_model.py`, `know_check.py`, `gen_zones.py`, `gen_memories.py --check`, and all headless Godot tests pass; each Act plays with its own distinct structure and deep character conversations.

## Phase 4g: Class depth (user call 2026-11-12)
Gives each of the four classes something only it has: one signature aksara with its own spell, and four favoured items.
- [x] Docs: [classes.md](classes.md) "Signature aksara" and "Favoured gear", [spells.md](spells.md) 2, 3, 10, [items.md](items.md) "Class-favoured gear", [quests.md](quests.md) 6.3.
- [x] Four glyphs (`sunda_ha`, `sunda_pa`, `jawa_pa`, `jawa_wa`) and four spells in `SpellVariants`.
- [ ] `SQ-X1`, the `class:` cond, 16 favoured items with icons and chest sources (was ticked 2026-11-12 but not in code or data; unticked the same day).
- [ ] Second-path identity (user call 2026-11-12, "not reskins"): four mechanics (Kuda-kuda, Batu Pantul, Wirama, Lakon), 32 class spells in `spells/path_*.gd`, four signature glyphs (`jawa_ga`, `sunda_ba`, `sunda_ta`, `jawa_la`), 16 sibling items.
- [ ] By hand: draw the four shapes in `tools/glyph_recorder.tscn` and record more templates if one reads badly; play each signature spell once and tune.
- Exit: `glyph_strokes.py` passes with the eight signature glyphs, the headless tests pass, each of the eight classes can finish `SQ-X1`.

## Phase 5: Remaining regions
Build each region from its area graph in `zones/<region>.md` ([mataram](zones/mataram.md), [tanah_timur](zones/tanah_timur.md), [segara_kidul](zones/segara_kidul.md), [gua_kala](zones/gua_kala.md)): first add tile maps per area (AGENTS.md 5), then build.
- [x] Mataram zone and boss (built 2026-11-05, played 2026-11-12)
- [x] Tanah Timur zone, miniboss and boss (built 2026-11-05, played 2026-11-12)
- [x] Gua Kala and the final boss (built 2026-11-05, played 2026-11-12)
- [x] Segara Kidul (main path, P0 since story v3.1: 4 areas, the Trial of the Waves, Ombak; built in Phase 4c, played 2026-11-12)
- [x] All gear as data, drops and chests (all 32 items wired to chests, starters, choices and quest rewards; 32/32 since the 2026-11-12 fixes, `tests/item_source_test.gd`)
- Exit: the game can be played start to finish with placeholder or pack art.

## Phase 6: Art, audio and presentation pass
- [x] World and entity art: hero + 4 classes, 34 enemy sheets, 10 boss sheets, 12 NPC/prop archetypes, 7 regional 128x256 world tilesets with 896 tiles across 21 sub-biomes
- [x] Phase 6b: themed UI and smooth typography ([ui.md](ui.md)), Elden-style class select with 96x128 animated portraits, 32 item icons, world scale x2 with erosion, deco and ambient mood ([architecture.md](architecture.md) 9)
- [x] Phase 6c: living towns (`zones/town_life.gd`), regional building kit (`zones/buildings.gd`), ground expansion, and fluid 4-directional attack animations with weapon arcs
- [x] Phase 6d: Revamp pass (2026-11-10) — Kelir v2 shadow-puppet presentation (`zones/kelir/kelir_stage.gd`, K0 wayang raksasa sprites), quiet in-story tutorial ladder (`ui/tutorial.gd`, `data/lessons.gd`), illustrated world map art (`tools/gen_map_art.py`, `assets/art/ui/map_world.png`, `map_fog_*.png`, `map_icons.png`), painted area maps, direct `M` key map toggle, revamp pixel-art sprite pass (`tools/gen_revamp_art.py`), and quest audit validation (`tools/quest_audit.py` 0 problems)
- [x] Quest & narrative UX: Scene Director camera easing, letterbox bars, choices with consequences (`remember:<key>`), and HUD quest cards
- [ ] Culture-item icons and glyph art refinement
- [x] First full audio pass (2026-11-09): 35 music tracks, 17 ambience beds, 92 sfx, 12 stingers, layered Audio autoload ([audio.md](audio.md)); played in game 2026-11-12, verification.md §5
- [ ] Final SFX and music pass: listen and tune every track in the engine ([audio.md](audio.md) 7), per-enemy sounds, optional recorded instruments
- [ ] Custom particle polish
- Exit: the game looks, sounds, and feels consistent, responsive, and complete.

## Phase 7: Culture and polish
- [ ] VERIFY pass on cultural claims, source citations complete
- [x] In-game codex entries cited and verified (97/97 `data/codex/*.tres` sourced 2026-11-13)
- [ ] Full text review and dialogue balance pass
- [ ] Combat and balance tuning: verify [balance.md](balance.md) metrics across all classes
- [x] Accessibility options and assist mode testing (`GameSettings`, `tab_system.gd`, `tests/settings_test.gd`, 2026-11-13)
- [x] Full end-to-end playtests (2026-11-12: every region, final boss, ending and a fresh-eyes run, verification.md §5)
- Exit: someone unfamiliar with the game can finish it smoothly without assistance.

## Phase 8: Release
- [x] Export builds for macOS, Windows, Linux (and Web if possible) *(macOS & Windows Desktop exported)*
- [x] Title, credits, and asset attributions
- [ ] Release distribution and packaging
- Exit: standalone builds run cleanly on all target platforms.
