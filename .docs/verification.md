# Verification handoff: confirm what is really done

Written 2026-11-12. For an agent whose job is to **confirm**, phase by phase, which items in [schedule.md](schedule.md) are actually done, and to report what is not. You verify; you do not build. If you find a bug, write it down with a repro and move on. Fix it only if the user says to.

## How to work
1. Read [CLAUDE.md](../CLAUDE.md), then [HANDOFF.md](HANDOFF.md) §5 to §7. Read any other doc only one section at a time (`grep -n "^#"`, then `sed -n`).
2. Run every automated check in §1 below first. They are cheap and they decide what the manual checks need to cover.
3. For anything a machine cannot judge (how it looks, how it sounds, how it feels, whether it is fun), **ask the user**. Use AskUserQuestion, one check per question, with:
   - the exact steps: what to launch, what to click, where to go (the **Demo** card skips straight to it),
   - what to look or listen for,
   - answer options like "Looks right", "Something's off (I'll describe it)", "Couldn't get there".
   Batch at most 4 questions per round. Ask only what you need. Never ask the user to run a command you can run yourself.
4. Tick a box in schedule.md only with evidence: a passing command or a user "yes". A box ticked earlier without evidence gets unticked, with a note.
5. At the end, write the report described in §4 and add one line to HANDOFF.md §7.

## Setup
- `GODOT=/Applications/Godot.app/Contents/MacOS/Godot`
- Play the game: `$GODOT --path .` (the user runs it, since it needs a window). On the title screen, the **Demo** card replays the story up to any act start, area arrival or boss door, using its own save slot. Use it so manual checks take minutes, not hours.
- macOS has no `timeout` command. In test loops, use `perl -e 'alarm 180; exec @ARGV' $GODOT ...`.
- A test passes only if it exits 0 **and** prints no `SCRIPT ERROR`.

## 1. Automated checks (run all of them, record the results)
| Check | Command | Expected (2026-11-12) |
|---|---|---|
| Import | `$GODOT --headless --path . --import` | exit 0 |
| All tests | loop over `tests/*.gd` | 80/80 pass |
| Quest audit | `python3 tools/quest_audit.py` | 0 problems |
| Names | `python3 .docs/know_check.py` | 0 fails |
| Pacing | `python3 .docs/pacing_model.py` | 138 main steps, 20 side quests aligned |
| Glyphs | `python3 .docs/glyph_strokes.py` | "Below 85% cast rate: none" |
| Balance | `python3 .docs/balance_model.py` | runs; compare the level numbers with balance.md |
| Zones | `python3 .docs/gen_zones.py .docs/zones/<region>.md` for each region, then `git diff --stat zones/` | no diff |
| Perf | `$GODOT --headless --path . -s tests/perf_probe.gd` | matches performance.md |

**Do not run `.docs/script_to_data.py`.** It no longer matches the CSVs: it rewrites `beats.tres`, ignores rows edited in script.md, and deletes 5 dialogue rows (HANDOFF §5). Report it as a finding instead.

Leave `git status` as you found it. If a check writes files, restore them.

## 2. Per-phase checklist
Fill each row: **Confirmed**, **Not done**, or **Broken** (with a repro).

### Phase 5: remaining regions (exit: the game can be played start to finish)
Every region is marked built, and none has been playtested.
- [ ] Automated: the `*_play_test.gd` and boss tests pass (Galuh, Mataram, Timur, Kidul, Kala).
- [ ] Manual, one question per region: Demo → the region's arrival → walk the main path to the boss door → fight the boss. Ask: can you get through without getting stuck, does the boss fight end and save, does the next region open?
- [ ] Manual: Demo → the final boss → the ending and credits play.
- [ ] Gear: confirm in code or data that all 32 items have a source (chest, starter, choice or reward). `tests/items_test.gd` and `tests/drops_test.gd` cover part of this.

### Phase 6: art, audio and presentation (exit: looks, sounds and feels consistent and complete)
Still open in schedule.md: culture-item icons and glyph art, the final SFX and music pass, custom particle polish. Confirm they are still open, then check the items already ticked:
- [ ] Art: for one area per region (via Demo), ask: are there missing textures, placeholder boxes, wrong-scale sprites, z-order mistakes, or text running out of its box?
- [ ] Kelir v2 memories: Demo → any memory → does the shadow-puppet stage read clearly?
- [ ] HUD and menus: open every Esc tab, the map (`M`) and the class select. Ask whether anything is cut off or misaligned.
- [ ] Audio: ask the user to open `tools/audio/audition.html` in a browser and play one region from start to finish, then in game: does music change on combat and boss, are there loud spikes, silent areas or clicks at loop points? Record what they say against [audio.md](audio.md) §7. This box can only be ticked by ear.
- [ ] Culture-item icons, glyph art, particles: list what exists and what is missing, by file path.

### Phase 7: culture and polish (exit: someone new can finish the game without help)
- [ ] VERIFY tags: count them by doc (`grep -c VERIFY .docs/*.md`; on 2026-11-12, script.md alone has 71). List any that matter for release. Never remove a VERIFY tag without a source.
- [ ] Codex sources: `data/text/codex.csv` has about 97 entry groups and only 21 lines containing "Sumber". List the entries without one.
- [ ] Text: known gaps from HANDOFF §5: orphan text rows not deleted, the deserter lines for `tt_pasir` and `sk_pantai` never fire, no HINT rows for MQ2 and MQ4. Confirm each one.
- [ ] Balance: ask the user to play one boss per act with two different classes. Too easy, about right, or too hard?
- [ ] Accessibility: list the options in [controls.md](controls.md) and check that each is in the settings menu (code plus a test or a user check).
- [ ] Fresh-eyes run: this needs a person who hasn't played the game. Note it as not done unless the user says it happened.

### Phase 8: release
- [ ] Export: there is no `export_presets.cfg` yet. Confirm and note it.
- [ ] Credits: `ui/title.gd` has a credits list. Check that every asset attribution in [assets.md](assets.md) (fonts, recorded sounds, any packs) appears in game.

## 3. Rules
- Docs are the source of truth. If the code and a doc disagree, report it. Change neither unless the user says so.
- Never commit, push, delete files or install anything.
- Do not trust the ticks in schedule.md or the claims in HANDOFF. Re-check them.
- If a manual check fails, ask for a short description or a screenshot, and record the area, the class and what happened.

## 4. Report (the deliverable)
Add a dated section at the end of this file containing:
1. A table: phase → item → Confirmed / Not done / Broken → evidence (a command or the user's answer).
2. Bugs found, each with steps to reproduce.
3. What still needs a human (audio by ear, the fresh-eyes playtest).
4. A one-line verdict per phase: are its exit criteria met?

Then update the schedule.md ticks to match, and add one line to HANDOFF.md §7 pointing to the report.

## 5. Report, 2026-11-12

### 5.1 Automated checks
| Check | Result |
|---|---|
| Import | exit 0 |
| All tests | **80/80 pass**, no `SCRIPT ERROR` |
| Quest audit | 0 problems (30 quests, 137 dialogue files, 4893 keys) |
| Names (`know_check`) | 37 names, 0 fails |
| Pacing | 138 main steps / 1290 min; 20 side quests / 454 min |
| Glyphs | below 85%: none |
| Balance model | runs; levels match balance.md §2.2 |
| Zones (7 regions) | `gen_zones.py` leaves no diff |
| Perf probe | slowest zone 309 ms (doc: 557 ms) fine; **one `quest_updated` event 18.1 ms** (performance.md §1 says 2 ms); 0.43 + 0.13 ms script per frame; 4 orphan nodes, 14 ObjectDB leaks at exit |

### 5.2 Per phase
| Phase | Item | Status | Evidence |
|---|---|---|---|
| 0–4 | Ticked items | Confirmed | 80/80 tests, import, audits |
| 4b/4d | Unticked boxes | Superseded | Built under 4c/4f; tests and quest audit pass |
| 5 | Play tests + boss tests | Confirmed | `*_play_test`, `boss_test`, `keris_test`, `hunter_test`, `demo_test` pass |
| 5 | Tatar Sunda (Sangkuriang, Warrior) | Confirmed | user check 1 |
| 5 | Mataram (Barma Wijaya) | Confirmed | user check 11 |
| 5 | Keraton Galuh (Hariang Banga, Rogue) | Confirmed | user check 9 |
| 5 | Tanah Timur (Keris, Mage) | Confirmed | user check 2 |
| 5 | Segara Kidul path | Confirmed | user check 12 |
| 5 | Final boss, ending, credits | Confirmed | user check 4 |
| 5 | All 32 items have a source | **Broken** | 30/32; see bugs B1, B2 |
| 6 | Region art (Acts II, IV, V) | Confirmed | user check 6 |
| 6 | Kelir v2 memory (K1) | Confirmed | user check 5 |
| 6 | HUD, menus, map | Confirmed | user check 7 |
| 6 | Glyph drawing feel | Confirmed | user check 8 |
| 6 | First audio pass, in game | Confirmed | user check 3 (Act III, 2 min) |
| 6 | Final SFX/music pass (`audition.html`, every track by ear) | Not done | not checked track by track |
| 6 | Culture-item icons, glyph art | Not done | 82 files in `assets/art/items`; no culture-icon set beyond the 32 item icons |
| 6 | Custom particles | Not done | 4 scripts use particle nodes; no polish pass |
| 7 | VERIFY tags | Not done | script.md 71, mataram.md 11, tanah_timur.md 7, keraton_galuh.md 6, segara_kidul.md 6, story.md 6, tatar_sunda.md 4, gua_kala.md 3, items.md 3, audio.md 3, others 1–2 |
| 7 | Codex sources | Not done | 46 of 97 `data/codex/*.tres` have `source = ""` (list in 5.4); 76 of 97 bodies cite no source |
| 7 | Text: orphan rows | Not done | 264 CSV rows used by no data file and in no doc; 1014 more are in script.md but not wired into NPC `.tres` (e.g. `ciung_wanara` hub V263–V285) |
| 7 | Text: deserter lines `tt_pasir`, `sk_pantai` | Not done | entries `c3_b`/`c3_c` in `faceless_deserter.tres` need `zone:tt_pasir`/`zone:sk_pantai`; the NPC is placed only in desa_purwa, kg_penjara, gk_pelataran, mt_candi |
| 7 | Text: HINT rows | Not done | only MQ0 steps have `_HINT` rows (journal reads `<objective>_HINT`) |
| 7 | Balance, one boss per act, two classes | Confirmed | user checks 1, 2, 9, 11 (Warrior, Mage, Rogue) |
| 7 | Balance doc vs data | Not done | Hariang Banga 2800 in scene vs 3200 in balance.md §7; Nameless Hunter 3600 vs 4600; §5.2 DPS table stale |
| 7 | Accessibility | Not done | 0 of the 9 options in controls.md §6 are in the System tab (only volumes, language, fullscreen) |
| 7 | Fresh-eyes run | Confirmed | user check 10 ("Yes, went fine") |
| 8 | Export presets | Not done | no `export_presets.cfg` |
| 8 | Credits / attributions | Not done | `ui/title.gd` About card lacks the Kevin MacLeod CC BY 4.0 credit for 14 tracks (`tools/audio/sources/music.json`); freesound licences unrecorded (assets.md: audio "not cleared for release") |
| — | `.docs/script_to_data.py` | Broken | not run; drops `DLG_LENGSER_V2-V4`, `DLG_MATARAM_DALANG_V3`, `DLG_MBOK_SRINI_V3` and rewrites `beats.tres` (HANDOFF §5) |

### 5.3 Bugs
- **B1. Choice 4 "Reforge" gives an item that does not exist.** Demo → ACT IV → Before Mpu Gandring's Keris → win → pick Reforge → open Inventory: no Keris Mpu Gandring. Cause: the beat runs `give:keris_gandring`; the item id is `keris_mpu_gandring` (`ItemData.by_id` returns null, so it cannot be equipped). `mq3.tres` alt listens for `item_picked:keris_gandring`.
- **B2. Choice 3 "Judgment" never gives Sabuk Galuh** (quests.md §3 table). The beat's `do` is only `flag:choice_judgment`. Repro: Demo → ACT III → Before Hariang Banga → win → pick Judgment → Inventory: no Sabuk Galuh.
- **B3. Deserter lines never fire** (see Phase 7 text row). Repro: carry SQ-C3 to step 2 → walk `tt_pasir`: no deserter.
- **B4. Duplicate clue** `c3_shore_net` is placed in both `sk_pantai.gd:68` and `sk_nelayan.gd:84`.

### 5.4 Codex entries with no source (do not invent one)
aji_saka arca bandit_archer bandung_bondowoso bandit boeh_rarang candi_seribu batu_tulis cepot dayang_sumbi gapura genderuwo gamelan four_seals hanacaraka gejog_lesung jaka_tarub hunter_mask keris_gandring jurig_leuweung kujang keris ki_sumarto keris_hantu laras_lontar kuntilanak kuntilanak_rumpun laras_ribbon lutung_kasarung laras_wall nyai_gendhis prajurit_terkutuk pocong sandekala roro_jonggrang sangkuriang sunda_ca sunda_nga sunda_elder sunda_ka sunda_ga sunda_weaver tangkuban_perahu wewe_gombel tuyul wild_boar. The game-invented ones (hunter_mask, laras_*, four_seals) can take `source = "game"`; the rest need a real source from the user.

### 5.5 Still needs a human
Track-by-track audio listen (`tools/audio/audition.html`, audio.md §7); sources for the codex list above and the VERIFY tags.

### 5.6 Verdict per phase
- 0–4: exit met.
- 5: exit met for play-through; gear exit not met until B1, B2 are fixed.
- 6: not met (final audio pass, culture icons, particles open).
- 7: not met (VERIFY/codex sources, text gaps, accessibility).
- 8: not met (no export presets, credits incomplete).

### 5.7 Fixed, 2026-11-12
Each fix got a failing test or repro first, then the full suite and design checks again: **82/82 tests pass, no `SCRIPT ERROR`; quest audit 0 problems (5020 keys); know_check 0 fails; pacing, glyphs, balance model fine; gen_zones no diff**.
- **B1, B2** (gear): Reforge gives `keris_mpu_gandring`, Judgment gives `sabuk_galuh` (script.md, `gen_quests.py`, `mq3.tres`, `beats.tres`). Test `tests/item_source_test.gd` (every `give:` names a real item; every item has a source: 32/32). User re-checked both in game.
- **B3** (deserter lines): Ranga (`R`, `flag:mq3_6,flag:choice_freed` / `flag:mq4_4,flag:choice_freed`) placed in `tt_pasir` and `sk_pantai` via the zone docs and `gen_zones.py`. Test `tests/npc_zone_test.gd` (a `zone:X` entry needs the NPC in zone X). User re-checked both areas.
- **B4**: duplicate `c3_shore_net` removed from `sk_nelayan` (zone doc, regen); the `sk_pantai` one stays.
- **HINT rows**: 126 `Q_<MQ1…MQ5>_S<n>_HINT` rows in `quests.csv`, both languages (CSV-only, like MQ0). User saw the Journal tip.
- **`.docs/script_to_data.py`** reconciled: shipped beats win (differences listed as `kept_beat`: tag_cat, scout_camp, kampung_raid, t4_dance); §14 drops are listed as `would_delete` and deleted only with `--drop`. Dry run on a copy leaves every CSV and `beats.tres` byte-identical. Not run on the repo.
- **Music credit**: About card scrolls (wheel, Up/Down) and lists Kevin MacLeod, CC BY 4.0, 14 tracks (ui.md About, `UI_ABOUT_MUSIC`). Fits in EN and ID; user re-checked.

### 5.8 Still open (ask first, or needs the user)
| Item | Why it is open |
|---|---|
| Orphan rows | 264 CSV rows used nowhere, plus 5 `would_delete` (`DLG_LENGSER_V2-V4`, `DLG_MATARAM_DALANG_V3`, `DLG_MBOK_SRINI_V3`). Deleting is the user's call. |
| Unwired script lines | 1014 script.md rows not in any NPC `.tres` (e.g. `ciung_wanara` hub). Content work, needs a plan. |
| Accessibility | 0 of 9 options in controls.md §6. New UI: ask first. |
| Export presets | no `export_presets.cfg`. Ask first. |
| Balance doc vs data | Hariang Banga 2800 vs balance.md 3200 (user: feels right, so the doc should change); Nameless Hunter 3600 vs 4600; §5.2 DPS table stale. Balance change: ask first. |
| `quest_updated` 18 ms | one event over the 2 ms budget (performance.md §1). Perf: Tier O. |
| Final audio pass, culture icons, particles | Phase 6 art/audio work. Ask first. |
| Sources | 46 codex ids with `source = ""` (5.4) and the VERIFY tags (5.2). SFX and ambience licences unrecorded (`tools/audio/sources/sfx.json`, `amb.json` hold URLs only), so they are not credited. Needs the user; none invented. |
| Generic tips | some of the 126 new tips only restate the step; worth a text pass. |

### 5.9 Verdict after fixes
- 0–4: exit met.
- 5: exit met (play-through and 32/32 gear).
- 6: not met (final audio pass, culture icons, particles).
- 7: not met (sources, text gaps, balance doc, accessibility). End-to-end playtest now ticked.
- 8: not met (no export presets; SFX/ambience licences missing from credits).
