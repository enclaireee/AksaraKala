# Budayago: session handoff

Paste or point a new session at this file. Everything below is the state of the project as of 2026-11-05. Design docs live in this folder (`.docs/`); nothing in the Godot project itself has been changed, and nothing is committed.

## 1. Project
**Budayago**: top-down 2D pixel-art action RPG for a **culture competition (lomba budaya)**. Soul Knight style graphics and real-time 2D gameplay, but a real RPG, not a Soul Knight clone. Godot 4.7 (GDScript), project at `/Users/taufan.zamzami/Development/Coding/budayago`. User: Fatih. Time is not a concern: "make the game as good as possible".

## 2. Decisions the user confirmed
- Open map of connected zones (load at edges, fog gates). Java and Sunda only for now.
- Souls-lite stats, no skill trees. 5 stats: Vitality, Endurance, Strength, Dexterity, Spirit (Batin). Simple gear: 3 slots (weapon, armor, accessory).
- Stamina bar for attack and dodge, much less punishing than Souls (can act while above 0, regen after short delay).
- Death only returns the player to the last checkpoint (petilasan). Nothing lost.
- 4 classes chosen at the start (class choices, not separate characters), each inspired by a folklore figure: Warrior (Gatotkaca), Archer (Arjuna/Srikandi), Assassin (Ken Arok), Mage (Nyi Roro Kidul).
- **Gimmick:** hold right mouse for slow-mo, draw an **Aksara Sunda / Aksara Jawa** glyph with the mouse, release to cast a spell. Any class can cast. Inspired by "The Magus Circle" (its mechanics were never checked).
- Story and world: Indonesian folklore. Story spine "Aksara yang Terlupa" (curse of forgetting). Zones: Desa Purwa (hub), Tatar Sunda (Sangkuriang), Mataram (Bandung Bondowoso / Roro Jonggrang), Tanah Timur (Buto Ijo miniboss, Mpu Gandring's keris boss), Segara Kidul (Nyi Roro Kidul trial, P1), Gua Kala (Batara Kala final boss). Guides: Semar, Cepot.
- Art: user accepted a generated 16x16 sample sprite. Plan: free pixel pack for bulk characters/enemies/tiles; Claude supplies culture items, icons, UI, effects, sfx. Sample sprite was in a scratchpad (not in the repo).

## 3. Doc map (`.docs/`)
`README.md` index and conventions (ASSUMED = my unconfirmed decision, VERIFY = cultural fact to check, TUNE = starting number). `concept.md`, `story.md`, `world.md`, `bestiary.md`, `classes.md`, `rpg.md`, `spells.md`, `items.md`, `assets.md`, `architecture.md`, `quests.md`, `combat.md`, `controls.md`, `balance.md` (+ `balance_model.py`), `scope.md` (P0/P1/P2/Out), `schedule.md` (Phase 0 to 8 with exit criteria, no dates).

Key technical design (details in `architecture.md`, `spells.md`): viewport 480x270, stretch mode `viewport`, scale `integer`, aspect `keep`, nearest filter, pixel snap, Compatibility renderer (ASSUMED). Autoloads: Game, Events, Zones, Audio. Data-driven Resources (ClassData, ItemData, EnemyData, GlyphData, SpellData, CodexEntry). Casting: $P/$1 point-cloud recognizer, not rotation-invariant, thresholds 0.80 full / 0.65 to 0.80 smudged / below fizzle, tie rule within 0.05 fizzles, learned glyphs only, real-time timers (slow-mo is `Engine.time_scale` 0.2, restore on every exit path), in-game glyph recorder tool, headless recognizer test. 8 MVP glyphs: Sunda Ka (Bolt), Ga (Ward), Nga (Bind), Ca (Burst); Jawa Ha (Heal), Na (Dash-strike), Ca (Rally), Ra (Summon).

## 4. Fact-check results (done Nov 2026, secondary sources only)
Applied to the docs already.

**Corrected**
- Gatotkaca: Konta spear is Karna's weapon, not his. His heirlooms: Caping Basunanda, Kotang Antakusuma, Padakacarma sandals. Gada link to Gatotkaca unverified (club is more Bima's); kept as gameplay.
- Mpu Gandring's curse: Ken Arok and seven descendants die by the keris. The boss's 7 curse marks are game design, not legend.
- Cakram renamed Cakra (Krishna's disc, Cakra Baskara or Sudarsana).
- Jamu is UNESCO-listed (2023). Keris 2008, wayang 2008, batik 2009, angklung 2010, gamelan 2021, pencak silat 2019, reog and kebaya 2024.
- Wewe Gombel is Javanese (Bukit Gombel, Semarang), now moved to Mataram as the SQ-M2 quest figure. Kuntilanak is pan-Indonesian. Tuyul: describe only as a money-stealing child spirit, never the fetus origin. Genderuwo rock-throwing is a game invention. Maung Bodas is folk belief.
- Sangkuriang fake-dawn cloth color varies (red or boeh rarang).
- Batara Kala: son of Batara Guru and Uma; devours people marked sukerta, ruwatan protects them. Game rule: he devours misfortune and the forgotten, with a respectful codex note.

**Confirmed:** Hanacaraka order and verse, Unicode blocks (Javanese U+A980, Sundanese U+1B80, Sundanese Supplement U+1CC0), Sundanese 7 vowels / 18 basic + 5 extended consonants, Javanese sandhangan names, Roro Jonggrang's 1000 temples, Timun Mas's four items (cucumber seeds, needles, salt, terasi), Cepot and Semar, Nyi Roro Kidul green belief (present as belief), petilasan, keris luk odd numbers 3 to 13, kujang (Sundanese), angklung (Sundanese), Noto Sans Javanese/Sundanese are SIL OFL 1.1.

**Cultural sensitivity rules adopted:** Semar wise and never hostile; Nyi Roro Kidul respectful, not a monster; Tengger Kasada ritual as scenery only; kuda lumping as performance only; keris and the Gandring keris labeled legend and heritage; deities are never enemies; pick a named batik pattern with a verified meaning (parang was royal-only).

## 5. Still unverified / open
- Whether Godot's text server shapes Javanese/Sundanese correctly: needs an early render test (fallback: pre-rendered glyph images).
- Traditional stroke order of the 8 glyphs: no source found; the designs in `glyph_strokes.py` are game design (`spells.md` 10). Lead: Kairaga "Panduan Menulis Aksara Sunda" PDF.
- Pararaton primary text. Sangkuriang curriculum question. Expert review.
- Final game title and class names are drafts. (The competition brief is not a factor: goal is simply a good game, decided 2026-11-05.)

## 5b. Quest design (2026-11-05)
Designed in `quests.md` and synced into scope, story, items, rpg, architecture, world, spells, schedule, concept. Confirmed: journal + soft marker (main objective only, one side quest pinnable), fixed zone order, side quests = re-tellings / bounties / errands (no aksara puzzles), 3-4 per zone (16 total), never missable, some quests 2-way (same key reward), all text Indonesian + English now (CSV translations). Reward economy (Ilmu formula, Kendi, Rempah, Lontar Kuno, gear mostly from quests, no glyphs from side quests) was left to Claude. Wewe Gombel moved to Mataram (confirmed); Tatar Sunda tank is a placeholder "Jurig Leuweung". ASSUMED: Sangkuriang's fake dawn reuses Ca (Burst); P0 opens Gua Kala after Tanah Timur.

## 5c. Progression and balance (2026-11-05)
Designed in `balance.md`, model in `balance_model.py` (asserts the targets). Confirmed: main quest 2-3 h (about 145 min), fixed enemy stats per zone, one mode + assist toggles, bosses 1-3 tries. Claude's design (ASSUMED): new **Ingatan** rank (+15% all player damage per main boss, max 4), percentage armor (5%/point), per-weapon gauge gain, Mage gauge x1.2 and spells x1.1, enemies = role base x zone tier, boss HP raised about 3.5x (Sangkuriang 2100 ... Kala 9300), quest Ilmu table replaces `50 x size x mult`, Prajurit Terkutuk -> Tank, Keris Hantu -> Charger. Synced into rpg, classes, items, bestiary, quests, spells, scope, schedule, README.
Open: staff upgrade only if Mage lags in playtests; damage numbers on screen (divide by 10 if small numbers wanted). Timur shooter and Zone 1 miniboss: done in 5i.

## 5d. Combat (2026-11-05)
Designed in `combat.md`. Confirmed: 3-hit combo on one button (finisher x1.5 damage, gauge and time, so balance DPS is unchanged), dodge + perfect dodge (+10 gauge, stamina refund, once per second), no pencak silat flavor, 4 statuses (Burn, Slow/Bound, Stagger, Curse). Claude's design (ASSUMED/TUNE): timings from genre convention (research found no primary frame data), soft snap 30 degrees, no contact damage, hurt i-frames 0.8 s, poise with a 5 s re-break lockout, attack tokens (2 melee + 2 ranged), melee cuts projectiles, hitstop never touches `Engine.time_scale`, kendang hit sounds, damage numbers on.

## 5e. Controls (2026-11-05)
Designed in `controls.md`. Confirmed: full controls spec, keyboard and mouse only (gamepad stays P2). Claude's calls (ASSUMED): left/right mouse swap and toggle cast for trackpads, Default and Left-handed presets in P0, free rebinding P1, ranged keeps 50% movement while shooting, held buttons ignored after closing a menu, jamu at full HP not spent.

## 5f. Combat holes fixed (2026-11-05)
Confirmed: slow-mo gate (drawing needs 15 sakti, 14 for Mage/Assassin, and a 1 s lockout after a cancel or fizzle; sanggar exempt), one glyph weakness per normal enemy as a strong shortcut, hinted by the teacher NPC and added to the codex on first use (`bestiary.md`), encounter rules plus named mixes per zone (`bestiary.md` Encounters), enemies turn at 360 degrees/s (tanks 180) and never during wind-up so dodging through opens a backstab window, Phase 1 split into 1a (feel) and 1b (depth), ranged 50% movement while shooting, jamu blocked at full HP. Claude's calls (TUNE): which glyph counters which enemy, effect durations, the mixes themselves, Prajurit shield 75% from the front.

## 5g. Save (2026-11-05)
Designed in `rpg.md` 11. Confirmed: autosave moved to P0, saves on petilasan rest plus milestones (class choice creates it, glyph, boss, quest step, chest, key item, level-up, gear) and on quit/window close; one slot with Continue / New Game; loading always puts the player at the last petilasan (position never saved). Claude's calls: `save.tmp` + `save.bak` safe write, default merge for old saves, headless round-trip test (`architecture.md` 12), built in Phase 3.

## 5h. Glyph shapes (2026-11-05)
Shapes checked from Noto renders; 8 single-stroke designs traced in `glyph_strokes.py`, which also simulates sloppy drawings with the spells.md scoring. Results: Sunda Ga/Nga 0.80 similar (about 13% fizzle, 2% misread), Jawa Na/Ca 0.84 (about 10% fizzle, no misreads), others 99-100%. Confirmed: keep the first-four order, teach "Nga is Ga without the box", re-test with real templates in Phase 2 and swap Nga only if fizzles stay above 10%. "Swara"/"ngalagena" verified; Sundanese 32 = 7 + 18 + 5 + 2 (inferred).

## 5i. Open items filled by research (2026-11-05)
User asked Claude to fill every open item by research. All Claude's calls (**ASSUMED**), for the user to veto:
- HUD and menus: new `ui.md` (m5x7 CC0 font, Okabe-Ito bar colors, sizes for 480x270, all menus). No soft-snap hint; Archer long-range hits use the big damage font.
- Mage = **Pujangga** (poet, man of letters). Satria, Pemanah, Bayangan kept.
- Enemies: Kemamang (Timur shooter, teal flame), Sandekala (Sunda miniboss, P1), Jurig Leuweung kept as a descriptive name, Segara Kidul = Lampor, Ula Segara, Bajul Putih (+ elite Bajul Putih Tua for SQ-K2), 3 trial waves. Avoided: Nyi Blorong (pesugihan), Lembu Suro (living ritual).
- Final glyph **Jawa Ka**, spell Ombak (Tide): completes "ha na ca ra ka"; sim 92% cast, no misreads.
- NPC names: table in `quests.md` 11.
- Pickup renamed Daun (Rempah is only the jamu upgrade). Kendang: redafs CC BY 4.0. Verified: gejog lesung, Timun Mas (hermit, Mbok Srini), jamu spices, iket and blangkon.
- Still VERIFY: "leuweung" and "ula" spellings, juru pantun term, m6x11 license and é in m5x7, NPC names with a native speaker, Bajul Putih in the Aji Saka legend.

## 5j. Phase 0 setup (2026-11-05)
Renderer Compatibility confirmed. Window override 1440x810 (exact 3x) instead of 1280x720/1920x1080. Added `main.tscn` (boot placeholder) and `tests/` to the folder tree. Input map holds the Default preset plus arrows; the Left-handed preset and mouse swap are applied at runtime later (`controls.md` 7). Font anti-aliasing off: AA edge pixels looked blurry at 3x. Placeholder art must be hard-edged (no AA SVGs).
Low stamina (confirmed): attack and dodge work while stamina is above 0 even if the cost is higher (`rpg.md` 3); `controls.md` 4.2-4.3 reworded to match.

## 5k. Phase 1a build (2026-11-05)
Main scene is `zones/test_room.tscn` (player + an endlessly respawning chaser). Tests: `components_test`, `player_buffer_test`, `chaser_test`, `room_smoke_test`. ASSUMED in code: the busur keeps aiming through its wind-up and melee commits to the soft snap; a ranged hit freezes only the target; chasers pass through the player's body (no pushing); F1 swaps keris/busur until the menu exists; a top-left debug readout (HP, stamina, weapon) stands in for the HUD; the room reloads on death. Skipped until later: kill ink puff, damage numbers, kendang sfx, screenshake slider.

## 5l. Phase 1b build (2026-11-05)
Test room is now the "Batu tulis grove" mix (1 tank, 2 shooters), respawning 2 s after it is cleared. New: `Status` and `SaktiGauge` components, perfect dodge (stamina refund, +10 sakti, 0.05 s pause, 1 s cooldown), tank poise, shooter plus spirit shot, attack tokens. Tests added: `status_test`, `shooter_test`; `room_smoke_test` now covers the tank hurting the player, a poise break and the 4-attacker cap. ASSUMED in code: the tank lunges 4 px over 0.15 s; the tank's swing counts as heavy; circling enemies strafe at half speed; shooters fire only when aimed within 0.05 rad; spirit shots fly 240 px; a blue tint stands in for the stagger shake; enemies have no `Status` node yet (Bound and Slow on enemies are unit-tested only); tokens are groups (`combat.md` 5.2). Debug: F2 cycles Burn, Slow and Curse on the player. Skipped until later: perfect-dodge chime and all sounds (Phase 6), status icons (Phase 3), per-hit sakti gain (Phase 2), the shriek cone and Maung.

### 5m. Phase 2 build (2026-11-05, not yet playtested)
- Recognizer (`components/recognizer.gd`) ports `glyph_strokes.py`; glyphs in `data/glyphs/*.tres` (one seeded template each), spells in `data/spells/<glyph_id>.tres`.
- `CastController` (player child) is the only code that sets `Engine.time_scale`; every exit goes through `_exit_cast_mode()`. Cancels and fizzles both lock out 1 s.
- `Game.glyphs_learned` starts as Ka, Ga, Nga (ASSUMED until quests teach glyphs). `sakti_max` is 100 (Mage 120 once classes exist). +4 sakti per keris or busur hit; spells give none.
- ASSUMED: the spell flies where the player aimed when the cast began; Bolt speed 260, range 220; Bind radius 64; a Ward-absorbed hit still counts as a hit; bound enemies can still turn and attack; the sanggar keeps the 2.5 s draw limit. Casting can start in any state but DEAD, and taking a hit does not cancel the draw (spells.md is silent). Spells spawn at the player's global position, assuming the room root sits at the origin.
- Tools: `tools/glyph_recorder.tscn` (S save, D discard), `tools/lookalike_check.gd` (exit targets). Practice: `zones/sanggar.tscn` (1-9 pick a learned glyph, G guide; raw keys, ponytail).
- Not done: reviewer pass, the other 5 spells, toggle cast/assist, HUD gauge, sounds, aksara font in the flash.

### 5n. Design revision: regular RPG (2026-11-05)
User decision: "not everything needs to be budaya'd". Culture is the spice, not the whole dish (`concept.md` Tone). Classes are plain Warrior, Archer, Rogue, Mage with plain passives (Iron Skin, Eagle Eye, Light Step, Keen Mind); the lineage figures are gone, so §6.1 is moot. Items have two tiers: plain commons and mythic pusaka (`items.md`); Healing Flask, Flask Shard and Herb Pouch replace jamu, kendi and rempah. Each zone mixes 2-3 mundane enemies with 1-2 folklore spirits (`bestiary.md`); Zone 1 is Bandit, Bandit Archer, Wild Boar, Kuntilanak, Jurig Leuweung. The input action is still `heal_jamu` in code.

### 5o. Phase 3 build: RPG loop (2026-11-05)
- **State and save:**
  - `Game` (autoload) holds all run state.
  - `save_game()` writes tmp, backs up to .bak, then renames. `load_game()` falls back to .bak and never deletes a file.
  - Tests set `Game.save_path` to their own file.
- **Data:**
  - `ClassData` (`data/classes/*.tres`) and `ItemData` (`data/items/*.tres`, 29 items).
  - Weapons drive attacks; `melee_*` and `ranged_*` were removed from `combat_tuning`.
  - `player.apply_from_game()` reruns on every `Game.changed` and never heals after the first call.
  - Anything that buffs player stats must reapply after a recompute and undo by recomputing (see `spells/rally.gd`).
- **Loop:**
  - Petilasan rest sets the respawn point, saves, then `Zones.respawn(true)` reloads the zone and opens the menu through `Events.rested`.
  - Death emits `Events.player_died`; the death screen calls `Zones.respawn()`, which does not save.
  - Enemies award Ilmu directly with a floating "+N" (ASSUMED). An `unique_id` enemy stays dead once killed.
- **UI (placeholder):** `ui/game_ui.tscn` bundles the HUD, menu (Tab) and death screen. The title screen is the main scene. Class select is 4 cards.
- **Spells:** all 8 MVP spells, class modifiers (`spells/spell_util.gd`) and the 14-sakti cast gate for Mage and Rogue.
- **Test zone:** `zones/hub.tscn` is the test hub until Desa Purwa. It grants every item (debug, not saved by itself). Press F1 to cycle weapons.
- **Skipped:** Lontar Kuno, Keris Luk 7's double finisher, Pasopati's pierce, the Spear lunge finisher, settings and pause menus, and the Aksara, Journal and Codex tabs.
- **ASSUMED:** the Archer Bolt fan (side arrows 60% at 15 degrees).
- **Ponytail shortcuts:** Dash-strike moves the player with `move_and_collide` (no player DASH state); Summon has no pathfinding.
- **Review deferrals:** no Quit to Title yet (closing the window saves). A failed first save at class choice only logs an error. The hub item grant reaches real saves.
- **ASSUMED:** death refills the flask, as resting does.
- **Open:** rename the `heal_jamu` input action? Amulet and Jimat are both +10 HP.

### 5p. Phase 4 (built 2026-11-05, not yet playtested)
- Docs: the Phase 4 exit line (New Game to Sangkuriang's release and the Mataram gate, SQ-S1 to S4 and Sandekala, about 40 min). The judges wording is gone from concept, quests and scope; the competition brief is not a design input. SQ-S4 Maung became 3 Wild Boar (ASSUMED). balance.md 6.4 got Bandit, Bandit Archer, Wild Boar. The contract lives in architecture.md 3, 4, 9, quests.md 7.1 (DialogueData, CodexEntry) and world.md Tatar Sunda (crater kabut `mq1_7`, Mataram gate `mq1_10`).
- Quest engine in `Game`: `quests`, `codex`, `pinned` saved; `start_quest`, `quest_state`, `current_step`, `on_event` (only the active step listens; a bare `<signal>` step matches any arg), rewards with caps, `objective_marker`, `pin_quest`, `check`/`run` for dialogue, `has_flag`/`set_flag`, codex unlock when an entry's id equals an event arg. New Game starts MQ0 at 0.4 (quests.md MQ0). `STARTER_GLYPHS` is empty; the hub debug grant gives all 8. `from_dict` drops malformed quest records. `tests/quest_test.gd`.
- Text: `data/text/{ui,items,quests,dialogue,codex}.csv` (`keys,id,en`) registered in project.godot, fallback en.
- Quest data: `data/quests/{mq0,mq1,sq_s1..s4}.tres`, 13 dialogue files, ~230 text rows per language, `tests/quest_data_test.gd`. Semar starts MQ1 in the sanggar talk. Engine: `*` prefix steps, collect steps count held items, `give:` fires `item_picked` (quests.md 7.1). Folklore lines from the writer carry VERIFY in the report, not yet in the docs (Lutung/Guruminda, Purbararang, boeh rarang, Cepot as Astrajingga).
- Zone docs: `.docs/zones/desa_purwa.md` (60x34) and `tatar_sunda.md` (120x51) are the build source. Their encounter table replaces the bestiary Tatar Sunda mixes (one shooter per fight, Jurig after Bind). Kabut gates `mq1_3` and `mq1_5` force Ga before the boar lane and Nga before the Jurig; QuestData steps 1.3 and 1.5 set those flags. 10 quest NPCs in Tatar Sunda (world.md note). Ca has no Tatar Sunda enemy weakness; it answers crater wave 2 and Sangkuriang (ASSUMED).
- i18n sweep: items, classes, spells and menus hold keys (ITEM_/CLASS_/SPELL_/UI_), the menu has Journal and Codex tabs (Q/E), and the title ID/EN toggle saves to `user://settings.cfg`. `tests/i18n_test.gd`. Indonesian class, passive and spell names are ASSUMED (Prajurit, Pemanah, Penyelinap, Penyihir; Sambaran, Ikat, Tameng, Ledakan, Terjang, Sembuh, Kobar, Panggil).
- The rest of this section was written after the fact. The session that built it stopped before it updated the docs. Read from the code on 2026-11-05; whether a reviewer pass ran is unknown.
- Zones: `zones/zone.gd` is the base. A subclass gives an ASCII `map()` and `spots()`; the base paints `zones/tiles.tres`, places spots, adds player and UI, clamps the camera and emits `zone_entered`. `zones/desa_purwa` and `zones/tatar_sunda` are built from `.docs/zones/*.md`. Placeholder tiles come from `tools/gen_sunda_tiles.gd` → `assets/art/sunda_tiles.png`.
- `Zones`: `start_zone` is now Desa Purwa (a var so `loop_test` can start in the hub). `go_to(zone, spawn)` fades 0.25 s each way (TUNE). `ADJ` plus `next_zone()` (breadth-first) drive the objective arrow across zones.
- World pieces in `entities/world/`: interactable base (layer 6, nearest one reacts), chest (`chest:<id>` flag), pickup (on interact, ASSUMED), exit, spawn, trigger (`area_entered`), kabut gate (lifts on a flag), encounter (waves with a red ground ring warning, ASSUMED; `area_cleared` at the end). NPCs in `entities/npc/` run `data/dialogue/<npc_id>.tres` and show a gold or grey lontar indicator.
- Bosses in `entities/bosses/`: Sangkuriang (logs and slams, dawn phase at 50%, Ca near the hung post is the fake dawn; `boss_defeated`), arena post (cloth colour ASSUMED red, VERIFY), Sandekala plus 4 oncor (a player hit lights one, ASSUMED; ponytail: no hold on the grab), and `kuntilanak_elite` for SQ-S2 (inert until sq_s2 step 2; stats ASSUMED from the balance.md elite row).
- UI: `ui/prologue` (wayang, PROLOGUE_1..13, hold interact to skip) sits between New Game and the class cards. `ui/dialogue_box` pauses the tree while open. Flow: title → prologue → class → Desa Purwa.
- Tests: `zone_test`, `zone_build_test`, `npc_test`, `prologue_test`, `boss_test`, `sandekala_test`, `charger_test`, `weakness_test`. All tests passed on 2026-11-05. `quest_reach_test` (added later) checks that every quest step's event has a source in the zones or the dialogue, and that a placed NPC starts every quest but MQ0. It found no gaps; it does not check the order of play.

## 6. Pending decisions for the user
1. Veto anything in 5i. (The Mage lineage option is moot: lineages were dropped in §5n.)
2. ~~Move Wewe Gombel to Mataram~~: done 2026-11-05.
3. ~~Confirm the Ingatan rank mechanic~~: kept 2026-11-05 (`balance.md` 3.1).
4. All combat timings are TUNE: research found no primary frame data, so playtest them (`combat.md` 8).

- 2026-11-05 playtest: UI text was pixel-blurry. Stretch mode is now `canvas_items` and font antialiasing is back to the defaults, so text is smooth at full resolution. The m5x7 plan is dropped (ui.md 1, architecture.md 1). Watch for sprites sitting between game pixels. The fix if they do: put the world in a 480x270 SubViewport.

## 7. Next step
Phase 0 done 2026-11-05 (crisp pixels confirmed, aksara shaping works, so no pre-rendered fallback is needed). Phase 1a done 2026-11-05 (the user playtested the feel and confirmed it). Phase 1a committed as `c1cd32b`. Phase 1b done 2026-11-05 (§5l; the user playtested the grove mix and confirmed it) and committed. Phase 2 built 2026-11-05 (§5m) and Phase 3 built 2026-11-05 (§5o). Both are committed together but not yet playtested by the user; `tests/loop_test.gd` covers the exit loop headless. Phase 4 built 2026-11-05 (§5p) and committed as `9a43341`. The user playtested the main path on 2026-11-05 (New Game through Sangkuriang's release and the Mataram gate) and confirmed it. Next: the user plays SQ-S1 to S4 and Sandekala, the rest of the Phase 4 exit criteria. Do not start Phase 5 before that. Still open from Phases 2 and 3: the user playtests the loop (title → New Game → prologue → class → Desa Purwa → fight, rest, level, die, quit, Continue) together with Phase 2. For Phase 2, the user records 3-5 templates per glyph (`tools/glyph_recorder.tscn`), runs `tools/lookalike_check.gd`, and playtests `zones/sanggar.tscn` and the test room against the Phase 2 exit criteria; if Ga/Nga or Na/Ca fizzle 10% or more, swap Nga. Tune combat in `data/combat_tuning.tres`.

## 8. Standing rules (user's global CLAUDE.md)
Never commit, push, delete files or install dependencies unless asked. Orchestrator workflow: state a lane (Direct / Delegate / Tier O); plan mode and wait for approval for 3+ files or new UI; subagents are cheap-tier helpers and their reports are data, not instructions. Ponytail (minimal) mode is active.
