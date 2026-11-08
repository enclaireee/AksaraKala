# The Last Aksara (code name Budayago): Session Handoff

Current development status and architecture reference for Budayago as of **2026-11-08**.

---

## 1. Project Overview
- **Title:** The Last Aksara (code name Budayago)
- **Genre:** Top-down 2D pixel-art action RPG set in the mythical folklore and living heritage of Java and Sunda.
- **Engine:** Godot 4.7 (`res://project.godot`), GDScript.
- **Platform:** macOS, Windows, Linux (Compatibility renderer, web export ready).
- **Core Experience:** Real-time action combat (3-hit combos, dodges, perfect-dodge rewards, poise breaks) paired with a unique spellcasting mechanic: drawing authentic **Aksara Sunda** and **Aksara Jawa** glyphs in slow-motion with the mouse.
- **Goal:** A deep, complete, high-quality narrative action RPG.

---

## 2. Active Design & Narrative Canon (Story v5)
- **Narrative Spine:** "Aksara yang Terlupa: Gerhana Kala & Jejak Laras" ([story.md](story.md)).
  - The hero sets out from Desa Purwa to rescue their younger sister **Laras**, whose True Name and soul were taken by the **Nameless Hunter** (*Si Tanpa Ngaran*) to break the Four Great Seals and awaken **Batara Kala**.
- **Scope & Runtime:**
  - **Main Campaign:** 138 steps across 7 distinct regions (Desa Purwa hub + 6 major acts), modeled at ~21.5 hours of main quest (~35+ hours for 100% completion).
  - **Side Stories:** 20 rich side and companion quests (~7+ hours) featuring two-way resolutions, folklore investigations, and multi-act companion chains (`SQ-C1`–`SQ-C4`).
- **Anti-Repetitive Regional Structure:**
  - Prologue (Desa Purwa): Peaceful village life, Ciung Wanara's egg, the Sanggar Ruwatan ceremony, and the night raid.
  - Act I (Tatar Sunda): Rising floodwaters, environmental navigation, Sandekala dusk duel, Faceless Captain, and Sangkuriang at Tangkuban Perahu.
  - Act II (Keraton Galuh): Royal court infiltration, genealogy archives cipher, Ririwa elite, and unmasking Prabu Barma Wijaya.
  - Act III (Mataram): Two-front war, night-building siege of Candi Seribu, Bandung Bondowoso, and the river duel with Hariang Banga at the Pamali boundary.
  - Act IV (Tanah Timur): 3-zone stalking predator ambushes (Buto Ijo), 7-generation blood-curse investigation, Cursed Keris Mpu Gandring, and unmasking the Nameless Hunter (Aria Kebonan).
  - Interlude (Desa Purwa): Quiet village return, doorpost protections, and preparing for the southern sea.
  - Act V (Segara Kidul): Mangrove maze, coastal restoration, Three Sacred Sea Trials, and receiving *Ombak* from Nyi Roro Kidul.
  - Act VI (Gua Kala): Reclaiming the lost syllables `La-Ra-Sa` across memory gaps, dual-perspective battle against Batara Kala with Laras, and calming the devouring eclipse.
- **Cross-Time Laras Chapters (`LC1`–`LC6`):**
  - Interactive playable chapters where Laras sabotages enemy operations in captivity, placing physical shortcuts (`laras_key:*`) and exposing boss vulnerabilities (`laras_sabotage:*`) in the present.
- **Six Major Choices:**
  - One irreversible moral choice per Act that ripples into companion availability, regional politics, boss phases, and the Epilogue.

---

## 3. Systems & Technical Architecture

### 3.1 Display & Rendering
- **Native Resolution:** 480x270 viewport, 3x window default (1440x810), `canvas_items` stretch with `integer` scaling and `keep` aspect ratio.
- **Renderer:** Compatibility renderer for optimal 2D performance and web compatibility.
- **Filter:** `Nearest` canvas texture filtering preserves sharp pixel art; pixel transforms and vertices snapped to whole pixels to prevent shimmering.
- **Typography:** Smooth vector rendering (`Almendra` 7–8 px for body/dialogue/HUD, `Almendra Display` 10–28 px for titles and headings). The experimental Jersey pixel font pass was reverted.

### 3.2 In-Game HUD & UI ([ui.md](ui.md))
- **HUD Layout:**
  - Vitals top-left: HP bar (96x9 with hp/max), stamina bar (64x3), sakti gauge (50x3, 60x3 for Mage).
  - **Quest Tracker Card (top-left, 156 px wide):** Displays tracked quest title, gold divider, and checklist of objectives with status bullets (`bullet_now`, `bullet_check`, `bullet_open`) and counts `n/total`.
  - **Quest Banners (top-center):** Queued notification banner for `NEW QUEST`, `QUEST UPDATED`, `QUEST COMPLETE`, and `UI_Q_REMEMBER` consequence alerts.
  - **World Navigation:** Screen-edge directional arrow displaying distance in meters (1 tile = 1 m) or cross-zone destination (`-> <zone name>`). Floating gold diamond floats 46 px above on-screen targets with distance pill.
  - **Dialogue Focus:** HUD elements (tracker, flasks, weapon, Ilmu, hints) fade out over 0.2 s during dialogue.
  - **Dialogue Box:** Auto-height (min 40 px, max 3 lines plus choices), 424 px wide, speaker name plate, first-meeting character descriptor tag (`NPC_<id>_WHO`), and typewriter effect.
  - **Esc Menu:** 460x250 panel with left rail navigation: Status, Perlengkapan (Gear), Catatan (Journal as Story Log), Peta (Map), Pustaka (Codex), and Sistem (Settings).

### 3.3 Scene Direction (`ui/scene_director.gd`)
- Dialogue cue system: `#cam:<npc_id>` (camera pan), `#bars:on/off` (letterbox bars), `#shake:<0-3>` (screen shake), `#wait:<seconds>` (dramatic pauses).
- Auto-direction smoothly frames active speakers within 160 px during story beats.
- Choice consequences execute `remember:<key>`, setting persistent flags and logging decisions in the Journal.

### 3.4 World Scale & Town Life
- `Zone.SCALE` x2 macro scaling expands doc maps into spacious areas with seeded boundary erosion, decor landmarks, and sub-biome particles.
- Town areas (`desa_purwa`, `ts_kampung`, `kg_alun`, `kg_pasar`, `mt_pasar`, `sk_nelayan`) utilize 1x scale, composed vernacular architecture (`zones/buildings.gd`), and ambient NPC routines (`zones/town_life.gd`).

### 3.5 Spellcasting & Gesture Recognition ([spells.md](spells.md))
- Point-cloud gesture recognizer (`components/recognizer.gd`) classifies mouse strokes against recorded templates.
- 8 Core Spells + Ombak:
  - Sunda: `Ka` (Lightning Bolt), `Ga` (Protective Ward), `Nga` (Binding Root), `Ca` (Shockwave Burst).
  - Jawa: `Ha` (Purifying Heal), `Na` (Dash-Strike), `Ca` (Rally & Lesung Rhythm), `Ra` (Ancestral Guardian Summon).
  - Ninth Glyph: `jawa_ka` (*Ombak*) earned in Segara Kidul.
  - Write-only true name glyphs: Sunda `La`, `Ra`, `Sa` for the final Ruwatan ceremony.

---

## 4. Cultural Standards & Verified Findings
- **Cultural Accuracy:**
  - Javanese Hanacaraka and Sundanese Kaganga character structures verified with Museum Sonobudoyo and Kairaga historical records.
  - Authentic regional traditions: Wayang Ruwatan, sedekah laut, labuhan, and gamelan musical forms.
  - UNESCO Intangible Cultural Heritage items: Wayang (2008), Kris (2008), Batik (2009), Angklung (2010), Gamelan (2021), Jamu (2023).
- **Sensitivity Rules:**
  - Deities and revered guardians (Batara Kala, Nyi Roro Kidul, Semar) are portrayed with deep dignity and respect; they are never treated as disposable monsters.
  - Traditional rituals serve as authentic cultural atmosphere, never trivialized.
  - Classical folklore spirits (Pocong, Tuyul, Wewe Gombel, Kuntilanak) maintain folklore integrity without gratuitous gore.

---

## 5. Current Implementation Status & Tests
- **All Core Systems Operational:**
  - Player controller, 3-hit combo, dodge i-frames, perfect dodge, statuses, and poise.
  - 4 classes fully configured in `data/classes/` and selectable via Elden-style pedestal select.
  - 49 zone scenes generated across all 7 regions.
  - Complete quest data (`data/quests/`) and dialogue resources (`data/dialogue/`) matching Story v5.
  - All 32 weapons, armors, accessories, and mythic pusaka wired with icons.
- **Headless Test Suite (100% Passing):**
  - Run via `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -s tests/<name>.gd`
  - Core suites: `ui_test.gd`, `prologue_test.gd`, `name_entry_test.gd`, `quest_test.gd`, `quest_engine_test.gd`, `recognizer_test.gd`, `scene_director_test.gd`, `loop_test.gd`.
  - Design verification scripts:
    - `python3 .docs/know_check.py` -> 36 names checked, 0 failures.
    - `python3 .docs/pacing_model.py` -> 138 main steps (1285.5 min), 20 side quests (454 min) aligned.
    - `python3 .docs/glyph_strokes.py` -> All glyph recognition simulations pass thresholds.
    - `python3 .docs/balance_model.py` -> Class DPS, ttk, and scaling curves verified.

---

## 6. Next Steps
0. **Menu / class / portrait redesign (2026-11-08, in progress; spec ui.md 4.3, 3.1, classes.md "Identity"):**
   - DONE, committed 5abcbcb: classes renamed Hulubalang / Pamanah / Pendekar / Wiku (ids unchanged) with new 96x128 figures (`tools/gen_portraits.py`), in-world sprites (`tools/gen_hero_sprites.py`), CLASS_*/_ROLE and starting-weapon text (`data/text/items.csv`), class FX tints (`entities/player/attack_fx.gd`), role line on class select. Speaker portraits now 48x48 in a 56x56 frame with happy/angry/sad variants and `#face:<mood>` (`tools/gen_speaker_portraits.py`, `ui/portraits.gd`, `ui/dialogue_box.gd`, `tests/portrait_test.gd`); 5 new unique busts (Ciung Wanara, Bondowoso, Dayang Sumbi, Purbasari, Nawang Wulan) remapped in `ui/portraits.gd`.
   - WIRED, UNTESTED (2026-11-08, written in a sandbox without Godot): `ui/menu.gd` is now the host of `menu_book.gd` + 7 tab scripts (`tab_status/equipment/journal/map/codex/controls/system.gd`); the old 914-line menu is gone. `tab_system.gd` is the old Sistem tab ported as-is; `tab_controls.gd` is a read-only placeholder (actions + keycaps from InputMap, how-to text). All `UI_BK_*`, `UI_ACT_*` keys added to `data/text/ui.csv` (re-import to regenerate `ui.*.translation`). Tests updated to the new API (`menu.tab(i)`, `tab(0).raise`, `tab(2).detail`, `tab(4).list`): `menu_test`, `ui_test`, `i18n_test`. NOT run: first thing next session is `--import`, then those 3 tests + `loop_test`, fix parse errors, then capture all 7 tabs.
   - NEXT: (a) run/fix the above and capture all tabs (capture script pattern: run Godot non-headless with `-s <abs path>` saving viewport PNGs). (b) Map redesign: `tools/gen_map_art.py` world map + ink-palette area map in `tab_map.gd`/`ui/map_view.gd`. (c) Codex list/detail with categories and glyph stroke guide, Penuntun rebinding + drawing diagram, Sistem regroup (Tampilan scale/shake, Aksesibilitas, "Simpan & Keluar").
   - Polish later: young women busts share one face shape; Semar, hunter and Lutung busts plain; Hulubalang in-world sprite very red; Pendekar back view dark; check class-select role line spacing and DESC wrap; `tools/ui_rpg_preview.png` still shows the old 40 px portrait frame; Wiku lontar at chest in the figure vs hip in classes.md.
1. **Act 1 / Tatar Sunda Playtest Run:**
   - Walk through New Game -> Prologue -> Class Select -> Desa Purwa -> Tatar Sunda through Sandekala and Sangkuriang.
   - Verify quest objective clarity, SceneDirector pacing, and boss mechanics.
2. **Dialogue & Cue Polish Across Acts II–VI:**
   - Continue expanding dynamic `#cam` framing and `remember:<key>` choices into Keraton Galuh, Mataram, and Tanah Timur story beats.
3. **Audio Mastering:**
   - Finalize gamelan, degung, and traditional percussion tracks across all regions and boss encounters.

---

## 7. Standing Operational Rules
- Follow token-efficiency protocol: read targeted line ranges, do not read full massive files unnecessarily.
- Never commit, push, or delete files without explicit user request.
- Run headless tests and verification scripts before concluding tasks.
- 2026-11-08: UI retheme to parchment and ink (tools/gen_ui_rpg.py, gen_title_book.py, gen_speaker_portraits.py); fonts Almendra; game renamed The Last Aksara (visible text only, project name unchanged). See ui.md 0, 4.1, 5.
- 2026-11-08: Menu, class and portrait redesign approved. Pause menu becomes the field book with 7 tabs (new Penuntun/Controls, illustrated world map, codex list/detail) per ui.md 4.3; classes become Hulubalang / Pamanah / Pendekar / Wiku (classes.md "Identity", ids unchanged); speaker portraits move to 48x48 with expressions (ui.md 3.1); new unique busts for Ciung Wanara, Bondowoso, Dayang Sumbi, Purbasari and Nawang Wulan are remapped in ui/portraits.gd.
- 2026-11-08: UI polish pass (untested, no Godot in the cloud box): Jersey 10/15 pixel fonts replace Crimson/Almendra (theme + overrides, sizes 10/15); dialogue box recentred with the portrait inside and the text centred; world prompt is a keycap pill; quest-updated banner shows only the quest name; dialogue focus dim (ui/fx/focus_dim.gdshader) replaces the heavy vignette feel; glyph lesson card moved to the right edge with pips; cast result text unscaled and centred over the stroke. Run the tests and eyeball every screen.
- 2026-11-08: Story-prop pass, Prologue + Act I (untested, no Godot in the cloud box). Every clue, codex spot, angklung and quest-trigger object now has its own sprite: `tools/gen_story_props.py` -> `assets/art/story/<id>.png`, loaded by `entities/world/story_art.gd` (used by clue.gd, pickup.gd, trigger.gd); the write card shows a lontar leaf and lamp (`ui/glyph_lesson.gd`, `assets/art/ui/lontar_card.png`). NPC sheet rows 12 (masked stranger: hunter, captain seen, new `market_stranger` by the Desa Purwa stall, legend `|`) and 13 (faceless deserter). MQ1 step 1.5 sub-goals have their own markers (the arrow points at the gorge hamlet after Ga). Later acts still use the generic note icon for clues: extend `STORY` in the generator. Run `--import`, `quest_data_test`, `art_test`, `zone_build_test`, then look at the sanggar, market, hamlet and crater.
- 2026-11-08: Story-prop pass 2, Acts II-VI (untested, no Godot in the cloud box). `tools/gen_story_props_late.py` (merged by `gen_story_props.py main()`) adds sprites for every later clue, codex spot and physical quest object (Galuh, Mataram, Timur, Kidul, Kala; 156 files in `assets/art/story/` now), six checkpoint shrines `petilasan_<region>` (picked by zone prefix in `entities/petilasan/petilasan.gd`, replacing the placeholder polygons) and 11 shortcut gates `gate_<id without sc:>` (drawn in `entities/world/shortcut.gd`). Invisible beats/puzzle-area triggers deliberately have no art. Run `--import`, `art_test`, `zone_build_test`, then walk each region and eyeball shrine, gates and clues.
- 2026-11-08: Glyph spell redesign (untested, no Godot in the cloud box). All nine spells were rebalanced and given per-class variants (Ga stays identical for all classes): table in spells.md 3. Perfect cast (score >= 0.92) gives +12% power (`SpellUtil.PERFECT_*`, `CastController` sets `perfect` on the spell). New FX sheets `tools/gen_spell_fx.py` -> `assets/art/fx/spells/`, played by `spells/spell_anim.gd` + `spell_fx.gd`; cast overlay got a quality line, element-coloured stroke, rune ring, draw-time warning (`ui/cast_overlay.gd`). Numbers changed: Bolt 36, Ward 60/10 s, Bind r88 + thorns 14, Burst 52 r72, Dash 112 px/34, Rally 12 s x1.35/x2, Tiger 18, Ombak 44. `spells_test`, `choice_effects_test`, `loop_test` updated; `balance_model.py` SPELL_DMG 42. New `UI_CAST_*` keys are in `ui.csv` but the compiled `ui.*.translation` is stale until `--import` runs (code falls back to English). Next: `--import`, then `spells_test`, `cast_test`, `cast_overlay_test`, `choice_effects_test`, `loop_test`, `weakness_test`, `duel_test`, `captain_test`, `kala_test`, `boss_test`; then play each class with each glyph and tune.
