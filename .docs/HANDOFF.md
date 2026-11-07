# Budayago: session handoff

Paste or point a new session at this file. Everything below is the state of the project as of 2026-11-07 (see §5ze and §7 for the newest state; the sections between are a dated log). Design docs live in this folder (`.docs/`). Some work is committed, wave 3 of Story v5 Step 3 is not (§5ze).

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
- Review fixes (2026-11-05, after the main-path playtest):
  - Soft-lock: MQ1 locked if Sangkuriang died before the player rested at `sunda_2`. `Game._catch_up` now meets a `boss_defeated:`/`enemy_killed:` step whose id is already in `killed`.
  - Objective arrow: it was missing on 8 steps. Quest markers now name real node ids, and `hud.gd` also matches `trigger_id`, `area_id` and `kind`. `quest_reach_test` now checks that every marker resolves to a node.
  - Menu: it no longer opens over the dialogue box.
  - Zone change: `Zones.go_to` unpauses again after the new zone loads.
  - SQ-S3: `angklung_*` pickups sparkle (`pickup.gd` uses `_matches`).
  - Sanggar guide: the Desa Purwa sanggar now shows the ghost guide of the newest learned glyph while the player is inside, as desa_purwa.md `S` says. Before this the shape was only visible in the standalone `zones/sanggar.tscn`, which no door leads to.
  - UX quick wins (2026-11-05): the sanggar runs the cast controller in practice mode (no sakti gate), blocked actions flash the HUD bar, the HUD shows an objective line and MQ0 key hints, interact prompts name the key and a verb, dialogue also advances on Enter or left click with a ▼ cue, an unrecognized glyph says so, the Sandekala room shows a one-time torch hint, and the death screen says Ilmu is kept. ui.md 2 records the new HUD lines.
  - Interlocking world (user call 2026-11-05, Bloodborne-style layout only; tone and difficulty unchanged): world.md has a new World structure section (regions split into 2x2-3x3 screen areas, interlock rules, fixed inter-region link ids). Region area docs: zones/tatar_sunda.md rewritten with area maps; zones/mataram.md, tanah_timur.md, segara_kidul.md, gua_kala.md are graphs only. Ripples: architecture.md (area ids, `QuestData.zone` stays the region), quests.md (marker zone = area id), balance.md 2.1 (MQ1 time TUNE), schedule.md (Phase 4 rebuild item, Phase 5 points to the docs), desa_purwa.md (renamed spawn ids, planned south exit). User approved; Tatar Sunda built (Part B): `zones/ts_*.gd/.tscn` are generated by `.docs/gen_zones.py` from the doc (edit the doc and re-run, never the scripts); `entities/world/shortcut.tscn` gate (flag = its id, opens from `open_side`, `UI_SC_LOCKED` prompt otherwise); `Zones.ADJ` directed with `DROPS` and `SHORTCUTS`; quest markers on area ids, MQ0 0.7 is `zone_entered:ts_kebun`; Desa Purwa exits target `ts_kebun`/`mt_gapura`. `zone_build_test` now also checks the world graph; new `shortcut_test`. The old `zones/tatar_sunda.*` files are unused and wait for the user's OK to delete. Found: a GDScript parse error exits 0, so `spells_test` had silently not run since Phase 4 (inner `Dummy` clashed with the global class; renamed). A suite run must also grep for `SCRIPT ERROR`. Waits for the user's playtest of the new layout.
  - Zone exits refill HP, stamina and sakti. The user kept this on purpose (2026-11-05), and architecture.md records it.
  - Open:
    - dying during the 0.25 s exit fade skips the respawn;
    - Sandekala's darkness fade is cut short when his corpse frees.

### 5q. Phase 5 Mataram (built 2026-11-05, not yet playtested)
- Content (from the session that hit its limit): Mataram enemies (Tuyul, Tuyul Leader, Pocong, Genderuwo, Wewe Gombel, Arca, elite guard, thrown rock; `mataram_enemies_test`), MQ2 and SQ-M1 to M4 quest data, 10 dialogue files, 12 codex entries, ID/EN text.
- Areas: `zones/mataram.md` now has 8 area maps; `zones/mt_*` are generated by `gen_zones.py`. `Zones` has the 8 areas, the wetan->tegal drop and shortcuts `sc:mt_ruin_sawah`, `sc:mt_candi_gapura` (`sc:mt_tt` opens from Tanah Timur, pending like `sc:ts_sk`). Exits to `tt_kulon`/`tt_sabana` are pending targets. `zone_build_test` checks the Mataram totals.
- Boss: `entities/bosses/bandung_bondowoso` + `pillar` per bestiary.md build spec (shield while a pillar stands, dawn beat every 20 s or on Jawa Ca with 8 s cooldown, phase 2 at 50%). Spirit builders, the lesung women at the arena edge and a solid pillar collider are skipped (ponytail notes). `tests/bondowoso_test.gd`.
- HUD and `quest_reach_test` markers now also match a pickup's `item_id` (SQ-M4 `gong_ageng`).
- Scripted playthrough 2026-11-05: `tests/mataram_play_test.gd` walks MQ2 start to end plus SQ-M1 to M4 (peaceful paths) in the real areas, with a walkability check on every hop and target. It passes. It found that enemies placed as zone spots (every boss and elite) had no `target`, because `Zone._build` adds spots before the player, so they never fought. Fixed in `EnemyBase._physics_process` (picks up the player lazily). This also hit Sangkuriang after the Tatar Sunda rebuild. Not covered: the fight alts of SQ-M2/M3, real combat, feel.
- Item pass 2026-11-05: Mataram chests now follow items.md. Axe (sawah), Iron Staff (wetan, items.md said "drop", but no drops exist yet), Longbow (secret 1 gong nook), Panah Pasopati and Amulet unchanged. They no longer repeat quest rewards or starter, Zone 1 and Zone 3 gear. With no gear left, the gapura, pasar and candi chests hold Ilmu (`item_id: "ilmu:<n>"`, 55/55/110, ASSUMED): `chest.gd` adds Ilmu and the HUD toasts "Got: N Ilmu". MQ2 now gives Baju Batik (items.md). Quest pickups (selendang, gong, batu bintang) stay plain inventory ids with no ItemData, hidden from the menu.
- Open: the 3 Tuyul with the tuyul leader are left out (an encounter would also spawn on the peaceful path); elites are plain spots, inert until their step; quest items `selendang_nawang`, `gong_ageng`, `batu_bintang` are plain inventory ids with no item file (like the angklung); chest gear picks are ASSUMED (mataram.md ASSUMED 14); trigger sizes for `lumbung`, `wewe_hill`, `tuyul_hideout` and the Pocong lanes need the playtest.

### 5r. Phase 5 Tanah Timur (built 2026-11-05, not yet playtested)
- Areas: `zones/tanah_timur.md` now has 8 area maps; `zones/tt_*` are generated by `gen_zones.py`. `Zones` has the 8 areas, the beringin->pesisir drop and shortcuts `sc:mt_tt` (now real), `sc:tt_ladang`, `sc:tt_pasir`. `zone_build_test` checks the Tanah Timur totals (kabut `mq2_9`/`mq3_4`/`mq3_8`, petilasan `timur_1`/`timur_2`, 8 encounters, boss placement, 7 + 3 stakes). The exit to `sk_karang` stays a pending target.
- Enemies: Banaspati (Burn trail), Prajurit Terkutuk (front shield), Kemamang (3-wisp spread), Keris Hantu (Curse charge), elites `banaspati_elite` (SQ-T2) and `yuyu_kangkang` (SQ-T1, leaves on the peaceful route). `tests/timur_enemies_test.gd`.
- Bosses (bestiary.md build specs): `buto_ijo` + `pouch_field` (a pouch hazard per phase at 75/50/25%), `keris_gandring` + `curse_stake` (7 stakes, cast next to a lit one to put it out). `tests/buto_test.gd`, `tests/keris_test.gd`. All numbers are TUNE.
- Quests: MQ3 and SQ-T1 to T4, 5 dialogue files plus Semar's MQ3 entries, 11 codex entries, ID/EN text. `tests/timur_play_test.gd` walks MQ3 and SQ-T1..T4 (peaceful SQ-T1) from the Mataram border back to Semar, with a walkability check on every hop. It passes.
- Fixes found while building: the practice stakes emitted `area_entered:timur_praktik`, the same event the marker trigger sends on walk-in, so just walking into the yard twice finished step 3.5. The stakes now emit `timur_praktik_mark` (bestiary.md). SQ-T2's `burn_trail` marker pointed at `tt_sabana`; it is in `tt_pesisir`.
- Open: one cast can put out several adjacent practice stakes, so step 3.5 may finish on one cast (ASSUMED fine); the Prajurit shield does not reduce a killing blow; Yuyu only charges when the player is within 14 px of its row; Buto's pouch fields are placed between him and where the player stood at engage; chest picks (crossbow sabana, chainmail beringin, 220 Ilmu pesisir) are ASSUMED; quest items `sodo_lanang`, `kuda_kepang_1..3` are plain inventory ids with no item file. Not covered: SQ-T1's fight route, real combat, feel.

### 5s. Phase 5 Gua Kala and Batara Kala (built 2026-11-05, not yet playtested)
- Entry (P0): a north gap in Desa Purwa (`desa_purwa.md`) behind kabut `mq3_8` leads to `gk_mulut`. Semar's 3.8 entry now also does `start:mq5`. The X1 link from `sk_keraton` stays pending.
- Areas: `zones/gua_kala.md` has 4 area maps; `zones/gk_*` are generated. `Zones` adds the gk_pasir->gk_lupa drop, shortcut `sc:gk_lorong`, and the one-way `kala_exit` door gk_ruang_kala->desa_purwa (kabut `mq5_3`, spawn `from_gua_kala`), listed in DROPS. `zone_build_test` checks the Gua Kala totals. `kala_lupa` uses the Timur Old guard mix (ASSUMED until Segara Kidul enemies exist).
- Boss: `entities/bosses/batara_kala.gd` (bestiary.md build spec), 8400 HP, 3 phases. P1 has devour pulses and falling sand; P2 is a shield plus a 3-glyph sequence (from learned glyphs), shown next to the boss bar in `hud.gd`. If the 30 s countdown runs out, Kala devours. P3 is both, faster. Released, not killed. Ilmu 1000 (TUNE, post-game). `tests/kala_test.gd`. Builder deviations: the pulse ring starts at a 24 px radius, the 10 s open window includes the 3 s stun, P3 raises a fresh shield, and the countdown pauses during the phase pause and the devour. The planned P3 reuse of `pouch_field`/`curse_stake` was dropped (YAGNI).
- Quests: `mq5.tres` (requires `mq3_8`, codex rewards), `semar_kala.tres` (a second Semar instance, so it never fires `talked_to:semar`), codex `batara_kala` and `ruwatan` (VERIFY kept), EPILOGUE_1..12 with the codex % on the last line, ID/EN text. QUEST_ILMU has a `gua_kala` row (quests.md; MQ5 pays post-game, so balance_model counts 0).
- Ending: when MQ5 completes, `Zones` plays `ui/epilogue.tscn` (`prologue.gd` with exports), which then returns the player to Desa Purwa at `from_gua_kala` (post-game). `tests/kala_play_test.gd` walks Semar 3.8 -> MQ5 -> Batara Kala -> the epilogue -> home. It passes.
- Open: boss numbers and timings are all TUNE; there is no tier scaling for reused enemies; the codex % line counts the codex files that exist, so it shifts once Segara Kidul adds entries. Not covered: real combat against Kala, glyph-sequence feel.

### 5t. Playtest fix: glyph lessons and RPG pacing pilot (2026-11-06, not yet playtested)
User report: no tutorial per glyph; the game felt like a lore dump, not an RPG. Pilot in Desa Purwa and Tatar Sunda only.
- Glyph lesson (spells.md 5, ui.md): `ui/glyph_lesson.tscn` in `game_ui.tscn` listens to every `glyph_learned` and waits for any open dialogue. It shows a card (name, aksara, `CODEX_<G>_BODY`, `LESSON_<G>` tip) plus the ghost guide, and asks for 3 casts (TUNE) in practice mode. Hold interact to skip. A lesson in progress is lost on a zone change. The card covers the top-left HUD while it is open. `tests/glyph_lesson_test.gd`.
- Drops (bestiary.md Drops): `EnemyBase._drop()` gives a 15% (TUNE) chance of `herb` (heal 20%) or `flask` (+1 charge), collected on touch. Elites always drop; bosses never do. These are not the quest-only Herb Pouch or Flask Shard. `tests/drops_test.gd`.
- Roaming packs (zones/tatar_sunda.md, balance.md 2.1): 19 loose enemies plus a second wave in sunda_terraces. The main path is now about 43 kills (it was about 22). Packs respawn on zone reload, sit 8+ tiles from spawns, exits and petilasans, put no boar before G and no Jurig before H. `zone_build_test` now counts map chars (20 placed).
- MQ1 trim (quests.md): the elder teaches Ga in a single talk, and step 5 is now `area_cleared:sunda_terraces`. MQ0/MQ1 talks are cut to about 4 lines. Cut lore moved to 5 new codex entries (aji_saka, sunda_elder, sunda_weaver, dayang_sumbi, batu_tulis). The prologue went from 13 cards to 5. Open: the epilogue codex % shifts with the new entries.
- Part C rollout (2026-11-06, the user asked for it before playtesting):
  - Roaming packs in Mataram (main path 23 to 40 kills; Tuyul and Pocong, Pocong only after the Bind teach) and Tanah Timur (24 to 40; Banaspati and Prajurit before tt_kali, Keris Hantu only after timur_ngarai). Gua Kala is already at its target of about 10, so it has none.
  - MQ2/MQ3 talks are capped at 4 lines, with new codex entries mataram_dalang and timur_empu. The epilogue went from 12 cards to 6.
  - Open: MQ3 3.5 is a second empu talk; it could become a small forge fight (quests.md note).

### 5u. Story v3.1: pacing pass and the full doc sync (2026-11-06, docs only)
User call: "finish every doc to v3; make it a proper RPG story, budaya-themed, not a budaya dump; like The Witcher, Elden Ring, Assassin's Creed; on pace, not too short." The other session's v3 run stopped after `story.md`. This run picked it up from `quests.md` and finished every doc. No code or data changed.
- **Research** (a web pass, thin on sources). Sourced: The Witcher 3 runs one Ciri trail quest per region, and each region's main story is one morally grey person tied to the hunt (the Bloody Baron; its reveal order was designed). Elden Ring bosses carry the narrative, and lore lives in places and items. The AC investigation loop runs clues → lieutenant → target. Unsourced design rules adopted as TUNE: a beat every 8-12 min, a set piece every 15-20 min, the low point at 70-75%, a quiet scene after each boss, about 4 named characters per region, at most 2 plain steps before a payoff.
- **story.md v3.1**:
  - New "Pacing" section with 9 rules and a runtime table (70 steps, about 410 min main, about 10 h at 100%, TUNE).
  - Each act has one regional character: Ibu, Naganingrum, Lengser and the Deserter, Ki Sumarto, Mpu Wirasana, Mbah Wiryo.
  - Glyphs are earned by deeds.
  - Act III has three leads in any order.
  - The **Interlude** "The Quiet House" in Desa Purwa (MQ4 4.1-4.2) is the low point, and Segara Kidul is Act V on the main path.
  - Camp talks with Ciung (II) and Hariang Banga (IV).
  - The 3 choices each change something in play.
- **quests.md**: §4 has 7 tables (8/13/8/13/11/9/8). Engine follow-ups are marked "not built yet" in §7.1 (`all`, `goto`, `restore`, `zone:`, glyph auto-complete). The echo quests SQ-S5 and SQ-M5 are retired; their lakons come with MQ1 and MQ2. Gates:
  - Desa Purwa south to sk_pantai opens on `mq4_2`.
  - tt_pesisir to sk_karang is a back route on `mq4_9`.
  - Both Gua Kala entries open on `mq4_9`.
- **Zone docs**: markers and spots for every step and beat. Map edits (sizes unchanged):
  - Desa Purwa: the lontar, the riders' spawn `from_riders`, the Interlude cast, the south exit.
  - Tatar Sunda: the ribbon, the kampung ambush, the lakeshore, the crater cast.
  - Galuh: the camp spot, the throne-room cast, the wall message.
  - Mataram: `arca_base`, the beat triggers.
  - Tanah Timur: Hariang's camp talk, the shrine triggers.
  - Segara Kidul: a new sk_karang↔sk_tebing stair replaces the pantai↔tebing link; petilasan `kidul_3`; the trial moves to sk_keraton.
  - Gua Kala: the Deserter at the mouth.
- **Other docs**: script.md was rewritten to v3.1. world, bestiary, balance §2, spells, ui, scope, items (`Batu Kali`, the Choice 3 rewards), concept, rpg, README and schedule (Phase 4c) were synced. story_brainstorm.md and story_ciung_wanara.md are marked superseded.
- **Open**:
  - gen_zones validation blocks were not re-run for the new map chars. Regenerate in Phase 4c and check.
  - Balance §7 has no rows for Barma Wijaya or Hariang Banga (resolved in §5v).
  - The first Arca fight comes before Na is read, a deliberate exception to the weakness rule.
  - Sapto's name and the `Batu Kali` effect are ASSUMED.

### 5v. v3.1 consistency pass (2026-11-06, docs only)
A read-through of every doc against story.md > quests.md 4 > script.md > zone docs. No code or data changed.
- **Gates:** no `mq3_8` gate is left. Desa Purwa south to `sk_pantai` is `mq4_2`, the `tt_pesisir` back route and both Gua Kala entries are `mq4_9`. Segara Kidul and Ombak are P0 everywhere. Coast juru kunci is Mbah Wiryo (no older name remains).
- **Step ids:** script.md `step:` indices match the quests.md tables (Weaver `mq1=7`, pamali stone `mq2=11`, altar `mq4=8`). Fixed: Ciung's "one more bout" line is `step:mqg=2`.
- **Spots added:** Nini and the Hunter at the Desa Purwa west gate; Sapto and Ciung at `kg_pamali` (plus the 2.12, `ford`, 2.13 and `truce` marker rows); Ciung and Hariang at the `gk_mulut` mouth. Naganingrum stays by the lake after MQ1 (her `D` spot keeps `flag:mq1_6b`).
- **Retired:** SQ-S5 and SQ-M5 rows are gone from the zone docs.
- **Systems:** balance.md 7 and `balance_model.py` have boss rows for the Captain, Barma Wijaya, Hariang Banga and the Hunter (bestiary.md HP and hits now match). Kala is 9300 HP (Segara Kidul is P0, so rank 4 always applies); the built boss still has 8400, a code follow-up. items.md has a "Main-path quest items" section (Laras's Lontar, Laras's Ribbon, Boeh Rarang); Choice 3 sink gives `batu_kali`.
- **Open for the user:** the four new bosses' Ilmu (1,170) is not in the balance 2.2 / 8.2 income model (balance.md 7 note). The Ingatan rank list still counts only Sangkuriang, Bondowoso, the Keris and the trial.

### 5w. v3.1 plot-hole port (2026-11-06, docs only)
The agreed plot-hole fixes (D1-D5, fixes 1-12; D8 superseded by v3.1's own 71 steps) are ported onto v3.1. No code or data changed. The pre-v3.1 local edits are in `git stash` as "story v3 local edits (pre-v3.1)".
- **story.md:** the dalang reads the children's names at the ruwatan (VERIFY); the lontar is torn in two (you hold her name, she writes *Ka* on hers); the Faceless are forgotten people bound by names in the Hunter's bundle (held vs gone); Seal 1 cracks on reading, then breaks by force; Ciung at the crater is bait for the naga; one reveal (the deserter only hints); Hariang turns after the cage; "It should have taken me"; Ombak breaks Kala's shield; Nagawiru sleeps in the epilogue. Gua Kala's Memory Seals are now *huruf nama* (the letters of her name) everywhere.
- **quests.md 4 / script.md:** new MQG step g.6 "Stop the wagon in the cell yard" (`galuh_escort`, sets `mqg_4b`) and beat `galuh_escort`; MQG is 9 steps, total 71. `laras_2` moves to `step:mqg=7` (after the cells). script.md 1 rules: 4 lines per NPC talk, 6 per beat; about 100 EN chars per line; no em dashes or parenthesised directions; villains don't explain the plot. New keys `BEAT_GALUH_ESCORT_1-2`, `Q_MQG_S6_OBJ` (old S6-S8 are now S7-S9); trimmed keys are listed in script.md 14.
- **keraton_galuh.md:** `kg_penjara` gets encounter `W` `galuh_escort` (16,16) in the west guard hall (the cell yard, ASSUMED); `G` `galuh_cells` moves to (38,16). `gen_zones.py` was not re-run: regenerate `kg_penjara` and run its map check in Phase 4c.
- **bestiary.md, world.md, gua_kala.md:** the Faceless definition and *huruf nama* wording.

### 5x. Phase 4c: code synced to Story v3.1 (2026-11-06, not yet playtested)
- Engine (quests.md 7.1): `all` steps (a bitmask in the quest record; save `VERSION` 2, old saves load with 0), `glyph_learned:` catch-up, the `zone:<area>` condition, `goto:<area>:<spawn>`, `restore` (`Game.restore()`, which the petilasan rest also uses), and `lakon:<id>`. Tests: `tests/quest_engine_test.gd`.
- Data: `mq0`-`mq5` and `mqg` follow quests.md §4. `sq_s5` and `sq_m5` are deleted (user call). `sq_k1` and `sq_k2` now require `mq4_2` (ASSUMED: `mq4_1` is no longer set). The text and beats come from script.md through `.docs/script_to_data.py`; rerun it after any script.md edit (it is idempotent). 21 NPC files were rewritten, plus the new `arca_base`, `hariang_banga` and 7 stubs with empty `entries`.
- Zones: every region was regenerated and `desa_purwa` was hand-edited (south exit `sk_pantai` behind kabut `mq4_2`, north kabut `mq4_9`, the lontar). `Zones.ADJ` matches the exits.
- Items and boss: `batu_kali`, 10 codex entries, Kala HP 9300 (phases at 6200 and 3100), and Ombak breaks Kala's shield.
- New: the Ombak spell (`spells/ombak.gd`, `data/spells/jawa_ka.tres`) is a piercing wave that pushes enemies back and destroys enemy shots it touches. Speed, range and push are TUNE.
- Doc fixes made during the build:
  - segara_kidul.md `sk_pantai` gets an N exit to `desa_purwa` and an `n` spawn.
  - script.md §13 gets rows for `laras_lontar` and `laras_ribbon`.
  - quests.md 7.1 is marked built and states what `restore` refills.
  - The Kidul altar now runs `learn:jawa_ka` after its write (a write never teaches a glyph), so 4.9 can complete.
  - The mbok_srini table header can now be parsed.
  - Pak Karto has one idle line (`DLG_PAK_KARTO_IDLE`).
- Saves: v1 saves get `all` = 0 but no step remap, so a mid-quest v1 save can land on the wrong step. Dev-only: start a New Game (plan call, no migration).
- ~~Open (from before 4c): SQ-K1 3 vs 5 hatchlings, `timur_empu` order, `pickup.gd` and `all` triggers.~~ All fixed in §5y.
- Code fixes:
  - New Game starts MQ0 at step index 2 (0.3, Ibu).
  - Glyph lessons wait while a write card is open.

### 5y. v3.1 review fixes (2026-11-06, not yet run in Godot)
A read-through of the Phase 4c build against the docs found these; all are fixed. Godot was not available in this session, so the tests were not run.
- **Camp talks replayed in later acts.** Hariang Banga's only entry (`flag:mq3_6`) also ran at the Interlude table and the Gua Kala mouth; Ciung's `camp_galuh` entry ran at `kg_pamali`, Desa Purwa and `gk_mulut` ("Tomorrow we lift the king's mask"). The camp entries now need `zone:tt_pasir` / `zone:kg_keraton` (Ciung's also `!flag:mqg_7`), and both NPCs get a line for the Interlude and the cave mouth (script.md "Staging NPCs", quests.md 4).
- **The Hunter's mask spoiled the Hunter.** The `hunter_mask` codex pickup in Ibu's house had no cond, so it could be read in the Prologue. `pickup.gd` now takes `cond` (like `Npc.cond`); the mask needs `quest:mq3=done` (desa_purwa.md).
- **Ombak skipped Kala's shield puzzle.** Any `jawa_ka` cast broke the shield at once. The shield sequence is now a Sunda glyph, a Jawa glyph, then Ombak (bestiary.md Final). `tests/kala_test.gd` checks it.
- **Seven empty NPCs.** `nameless_hunter`, `nini_balangantrang`, `sapto`, `nagawiru`, `pangrenyep`, `seal_stone`, `deserter_mouth` had no entries, so a talk did nothing. Each has one line now (script.md "Staging NPCs").
- **MQG journal region.** `mqg.zone` was `tatar_sunda`; it is `keraton_galuh` now, with a `UI_ZONE_KERATON_GALUH` key and a QUEST_ILMU row equal to Tatar Sunda (ASSUMED, so the balance model is unchanged).
- **Old open items:** SQ-K1 docs now match the built 3-pickup quest; `timur_empu` offers SQ-T3 before its step hints (`timur_play_test` updated); `pickup.gd` sparkles for `all` triggers too.
- **Not done:** v1 save migration (dev-only, plan call) and the Ilmu of the four new bosses in the balance income model (a design call for the user, §5v).
- **Run on the Mac first:** `$GODOT --headless --path . --import` (the `.translation` files are stale until the CSVs are re-imported; commit the regenerated files), then every test in `tests/`.

### 5z. Story v4 telling pass, v4b depth, v4c pacing (2026-11-06, docs only)
Playtest feedback: "suddenly there's Sandekala? who is Cepot? I don't know a lot of the stuff"; 1.4+1.5 took about 5 minutes. User calls: keep the v3.1 plot, fix the telling; a playable normal day before the raid; Witcher-style Hunts (backstory through play, not a talk then a boss); fewer names; then the same for the whole game with more depth in the second half; then redesign the pacing of the whole game.
- story.md: v4 note; Pacing rules 10-14 (know before you meet, name tags, Hunts, the fight is the memory, Story so far); Prologue "A Day in Desa Purwa"; "Depth pass (v4b)" (arrival slices, Laras chapters LC1-LC6, Hunter memories H1-H4, who's who through play, prologue callbacks; deeper Interlude, Act V, Act VI, playable epilogue); "Pacing model (v4c)" (typed pieces with minutes, 7 rules); "Hunts (v4)" (K0-K10, K-II, K-III); cast cuts (Ki Wangsa, Aki/Nini, Abah Karna, Mbah Marto, Mbok Srini, Pangrenyep unnamed in play).
- New check: `python3 .docs/pacing_model.py` reads the `Play` column in quests.md 4. It passed at 572 min, 78 steps (v4c merges cut the count from 112).
- quests.md 4 and 7 rewritten (new events `clue_examined`, `memory_done`, action `clue:`; step field `recap` = `Q_<QUEST>_S<n>_DONE`; Desa Purwa south exit now on `mq4_i5`). architecture.md 9b (Clue, Kelir memory kinds play/walk/chapter/gap, shimmer, `Zones.go_to` gets an optional `pos`, `Game.memory_return`), ui.md 3, bestiary.md Hunt lines, schedule.md Phase 4d.
- Data fix: Cepot's Ga hint (`DLG_CEPOT_15`) now plays only after Ga (`data/dialogue/cepot.tres`). Not run in Godot.
- Zone docs (all 7) rewritten by two agents: every clue, memory entry, arrival-slice NPC, new fight/puzzle/miniboss and shortcut placed; memory scenes specified in "## Memory" / "## Memory scenes" sections that gen_zones skips. New Tanah Timur link L14 (tt_pesisir to tt_pasir, kabut `mq3_h4`).
- script.md: rewritten for v4 by an agent (prologue day, every act's clues, memories, Laras chapters, Hunter memories, the gap memories, Interlude, epilogue, quest text, `_DONE` recaps, `_WHO` name tags). The agent was stopped before its own review; the review was finished in §5za.
- Open for the code phase (from the agents' reports): `clue.tscn` needs a `cond` export (now in architecture 9b); gen_zones quotes a `cond` wrongly when a later term is positive (put positive terms first or fix the generator); wave entries can't carry elite props, so elites need their own scenes (`wild_boar_elite`, `jurig_leuweung_elite`, `faceless_champion` and the east ones) or a props dict; puzzles use `trigger.tscn` with `puzzle_<id>` for now; boss and NPC conds that read step indexes (e.g. `sunda_kampung` `step:mq1=1`, the Sea Altar) need re-indexing when QuestData is rebuilt; Laras's `route` prop is assumed. Several small ids are ASSUMED in each zone doc's list.
- New VERIFY: Semar as Batara Ismaya; sedekah laut / labuhan; Nyi Roro Kidul retelling; the Murwakala lakon as the ruwatan story.

### 5za. Phase 4e: side stories v4d, and the v4 review finished (2026-11-06, docs only)
User call: "Expand the story first", with side quests as Hunts and deeper characters, at whatever size it takes.
- v4 review (the stopped agent's §7 steps 1-2): steps, clues, memories, both languages, cut names, zone memory scenes and the `la`/`ra`/`sa` gap answers all check out. A rule-10 (know before you meet) pass over script.md fixed 15 lines (23 EN/ID cells), each by explaining a word at first use: Kala, Aria (a deliberate plant in `BEAT_RAID_3`), Ca, Candi Seribu, juru kunci, the cave where Kala sleeps, Ombak, Sumi, the batu tulis, empu, terasi, Murwakala; one duplicated sentence removed from `DLG_LESUNG_WOMEN_V2`. `gen_zones.py` runs clean on all 7 regions in a scratch copy (the output differs from `zones/` only by the v4 spots not yet regenerated, which is Phase 4d part 2).
- story.md: new section "Side stories (v4d)" (side Hunt shape, size bands, the per-quest table, G1/G2, companion chains C1-C4, the camp talks), arc lines on the Characters table, Pacing rule 6 (camp talks in Acts I-V), 100% runtime about 16 h (TUNE, was 13 h).
- quests.md 5: S1, S2, M1-M3, T1, T2, K2 rewritten as side Hunts or played retellings; new Keraton Galuh section (G1, G2) and Companion stories (C1-C4; S4 is C4 part 1); a `Play` line on every card; camp talks `camp_sunda`, `camp_mataram`, `camp_kidul` in 4; 6.1 lakon count 9. New ASSUMED names: the servant Canga (`write:ririwa_name:sunda_ca,sunda_nga`), the Deserter Ranga (`write:deserter_name:jawa_ra,sunda_nga`); `galuh_queen` as the queen's npc id. The new quests give no reward Ilmu (TUNE), so `balance_model.py` keeps the side share at 34%.
- bestiary.md: elites `kuntilanak_elite`, `tuyul_leader`, `ririwa` (VERIFY the term); memory lines on the side elites; Bajul Putih Tua is driven off, not killed.
- script.md and the zone docs: every side and camp-talk line in EN and ID, and every side spot placed (three agents).
- `pacing_model.py` now also reads the side cards: size bands S 5-10, M 10-20, L 20-30 min (TUNE), and a side Hunt needs a clue and a memory. Main path unchanged at 572 min; side total about 310 min.
- Checked: `gen_zones.py` runs clean on all 7 regions in a scratch copy; every side clue and memory id in quests.md 5 has `CLUE_`/`MEM_` keys in script.md (new section 15) and a spot in a zone doc; no cut names in the new lines.
- Open for the code phase: npc ids renamed in the zone docs (`m2_neighbour`, `m2_parents_1`, `m3_smith`, `t2_herder`; the `.tres` files must follow); the `sodo_lanang` pickup in `tt_beringin` is now unused (SQ-T1 uses clue `t1_sodo`), so drop it in the data pass; the peaceful-branch flags (`sq_<id>_peaceful`) and the `ririwa_roll` / `deserter_stone` object ids are ASSUMED; `EPILOGUE_C3_FREED` and `EPILOGUE_C4` still need a slot in script.md 11; check `DLG_DESERTER_MOUTH_V1` against the freed write card; script.md lists S3, S4, M4, T3, T4 as checked, but not line by line. S2's safe ground is the lit, beaten-ground patch (script, zone and bestiary agree).
- New VERIFY: the Kuntilanak "safe ground" motif, Wewe Gombel's calling and pot-banging, the tuyul's counting (beans or crabs), who gives Klething Kuning the sodo lanang, the Kabayan tale, ririwa, the Ciung Wanara egg motif, the river-mouth offering.

### 5zb. Phase 4d part 2, Milestone A built (2026-11-06, not yet playtested, committed as `033792a`)
- Engine (A1): `entities/world/clue.gd/.tscn` (exports `clue_id`, `lines`, `memory_id`, `cond`; plays `CLUE_<ID>_1/_2`, runs `clue:<id>`, then enters the memory; a memory clue with no lines just pulls you in), `zones/kelir/` (`memory.gd` kinds play/walk/chapter/gap, `memory_spot`, `memory_threat`, `gap.tscn`), stand-ins, events `clue_examined`/`memory_done`, `Zones.go_to(..., pos)`, `enter_memory`/`exit_memory`, `Game.memory_return` (save VERSION stays 3: an old save loads with no `memory_return`). Memory narration keys are `MEM_<ID>_IN(_2)` / `_OUT(_2)` (architecture.md 9b fixed; it said START/END). Elites: `wild_boar_elite`, `jurig_leuweung_elite`, `ririwa`, `wewe_elite` scenes (x4 HP/Ilmu, TUNE). A reviewer pass on save, quest engine and memory code was fixed.
- `gen_memories.py`: reads `### Memory` and `## Kelir memory K<n>` headings, lowercase `kind`, an `` `interact` `` notes role, a lone-digit order; a `zones/kelir/<id>.gd` overrides the root script. Run for desa_purwa and tatar_sunda (7 scenes); `--check` over all regions: 34 scenes, 3 gaps skipped, 0 errors. Generated spot line keys with no script line (e.g. `MEM_LC1_2`) stay silent by design.
- K0 (`k0_ruwatan.gd`): lamps are the interact spots, the first starts lit, each lit lamp is the checkpoint, Kala's shadow (16 px/s, lit radius 120 px, TUNE) stops at lit ground and touching it fails. `tests/k0_test.gd`.
- Data (A2): CSVs and `beats.tres` regenerated from script.md; desa_purwa and tatar_sunda zones regenerated; Prologue and Act I NPC `.tres` rewritten (new `laras`, `purwa_old_couple`, `purwa_stall`, `sunda_grandson`); the prologue is now 2 cards (script.md 4; PROLOGUE_3-5 retired); new codex `pamor`, `sedekah_laut` (VERIFY). NPC ids with no doc lines get no file (villager, tea_picker, leuwi_mother, stray_cat, laras_tag, laras_crowd, faceless_captain_seen, wirasana_daughter; see the zone build fixes below for the puzzle NPCs and Ki Sumarto). Epilogue dialogue entries wait for Milestone B. `data/dialogue/ki_wangsa.tres` is retired, waiting for the user's OK to delete.
- New tests: `clue_test`, `memory_test`, `k0_test`, `scene_load_test`, `key_ref_test` (every CLUE_/MEM_/WHO/GAP_/Q_ key referenced in data exists; the Interlude shelf clues `shelf_ribbon`/`shelf_board`/`shelf_strip` are skipped until script.md has their text, Milestone B). `i18n_test` covers all 5 CSVs; `quest_reach_test` treats clue and memory events as sources.
- Quests (A2): `mq0` (9 steps) and `mq1` (15 steps) rebuilt to quests.md 4 with `recap` keys; `sq_s1`, `sq_s2` as Hunts (unlock `flag:mq1_3`, per the cards; objectives `Q_SQ_S1_S1..S5_OBJ`, `Q_SQ_S2_TITLE`, `Q_SQ_S2_S1..S5_OBJ` added to script.md 12); `sq_s4` sets `c4_1`. `quest_data_test` reads the flags an `all` step's leads set.
- Fixed: the HUD objective arrow (and the reach/play tests) now find a marker by `clue_id` and `memory_id` too, so clue and memory markers point somewhere.
- Fixed: script.md 15 step conds for SQ-S1/S2 were 1-based against the 0-based engine (script.md 2 says 0-based): the reports are `step:sq_s1=4`, `step:sq_s2=4`, Purbasari `step:sq_s1=3`. **Milestone B: check every other 15 card the same way** (`step:sq_g1=5`, `sq_g2=5`, `sq_k2=5`, `sq_c1=5` look 1-based on 5-step cards; `sq_m1=3` on a 4-step card is right).
- Fixed: regenerating desa_purwa had dropped the hand-written sanggar code (practice mode, draw guide). It now lives in `zones/desa_purwa_base.gd`, and `gen_zones.py` makes an area extend `zones/<area>_base.gd` when it exists (architecture.md 4). `zone_build_test` follows the v4 doc: 3 raid skirmishes, south gate flag `mq4_i5`.
- Parked for B: `sq_c4_2.tres`, `sq_c4_3.tres` moved to `.docs/parked_b/` (Godot ignores it). They need TITLE/OBJ keys, `mq2_a1` (set by the B MQ2), the `trial_completed` event (ASSUMED in quests.md, not in the engine) and zone nodes in `mt_gapura`/`sk_pantai`. `DLG_MBOK_SRINI_5/7/8` have no text yet (B).
- Zone build fixes (A2): puzzle stones and sluice wheels get action-only dialogue files (`batu_stone_1`-`3`, `sluice_wheel_1`-`2`): each press sets its flag in order, and an out-of-order press does nothing, because script.md has no hint line yet (tatar_sunda.md asks for one). An NPC with no dialogue file shows no Talk prompt (`npc.gd`), and zone_build_test's `NO_TALK` lists the set-dressing ids. The epilogue Ki Sumarto in desa_purwa now uses `npc_id:"mataram_dalang"` (his script.md entry); the epilogue line under that entry is a Milestone B item. Open: tatar_sunda.md says the Batu Tulis "can then be read" after `batu_3`, but script.md `batu_tulis` entry 1 only checks `step:mq1=6`, so it is left ungated. Decide which doc wins.
- Expected until Milestone B: `kidul_play_test`, `mataram_play_test`, `timur_play_test` replay the v3.1 beat order, and the v4 beats need new flags (e.g. `quiet_house` needs `beat_table_dishes`), so #6 rewrites them with the B data.

### 5zc. Story v5 Major RPG Expansion & Anti-Repetition Blueprint (2026-11-06, core docs synced)
User call: "for other bosses and other characters don't make it too repetitive, make it a much much longer game, and put more depth into each part of the story, each character, each boss, each region, especially the ones on main story; redesign the md first, and sync every doc to the newest convention."
Clarified with the user via design interview (`ask_question`) and synced across `story.md`, `quests.md`, `pacing_model.py`, `world.md`, `bestiary.md`, `architecture.md`, `ui.md`, `balance.md`, `README.md`, `schedule.md`:
- **Scale:** Expanded from 78 main steps (~9.5 h, 40 areas) to **138 main steps (~21.4 h / 1,285 min modeled, 49 areas across 6 regions + hub, 4–5 chapters per region)** plus **20 side & companion quests (454 min modeled)** = **~35 h+ at 100%**. `python3 .docs/pacing_model.py` passes with 0 failures.
- **9 New Sub-Areas (40 -> 49 areas):**
  - Keraton Galuh (`4 -> 7`): `+kg_pasar` (Pasar Kuta), `+kg_pustaka` (Balai Pustaka / Royal Archive), `+kg_kaputren` (Royal Quarters).
  - Segara Kidul (`4 -> 7`): `+sk_nelayan` (Kampung Nelayan), `+sk_bakau` (Hutan Bakau mangrove), `+sk_gua` (Gua Karang sea cavern).
  - Gua Kala (`4 -> 7`): `+gk_pelataran` (Pelataran Waktu / Courtyard of Time), `+gk_hutan` (Hutan Lupa / Forgotten Woods), `+gk_jembatan` (Jembatan Bayang / Shadow Bridge).
- **Anti-Repetition (Unique Structure per Act & Boss):**
  - **Act I (Tatar Sunda):** Classic Folklore Hunt (`Sandekala`) + Rising Floodwaters & Sluice Progression (`Faceless Captain` & `Sangkuriang`).
  - **Act II (Keraton Galuh):** Undercover Palace Intrigue, 3-Wing Faction Heist (`kg_pasar`, `kg_pustaka`, `kg_kaputren`), Wagon Ambush & Throne-Room Coup (`Barma Wijaya`).
  - **Act III (Mataram):** Two-Front War Campaign, Real-Time Night-Building Siege (`Bandung Bondowoso` raising stone barriers across `mt_wetan`/`mt_tegal`/`mt_candi`) & 1v1 River-Ford Duel (`Hariang Banga`).
  - **Act IV (Tanah Timur):** 3-Zone Stalking Predator (`Buto Ijo` ambushes you in `tt_kulon`, `tt_kali`, and `tt_beringin` before the final canyon lair), 7-Generation Blood-Curse Mystery (`Keris Mpu Gandring`) & Personal Showdown (`The Nameless Hunter`).
  - **Act V (Segara Kidul):** Coastal Community Healing (`sk_nelayan`, `sk_bakau`) & **Three Sacred Sea Trials** (Trial of the Torch-Lines in `sk_karang`, Trial of the Abyssal Current in `sk_gua`, Trial of the Waves in `sk_keraton`).
  - **Act VI (Gua Kala):** Allied Defense at `gk_pelataran`, Three-Realm Memory Descent (`La`, `Ra`, `Sa`) & **Dual-Perspective Finale** against `Batara Kala`.
- **Cross-Time Laras Chapters (`LC1`–`LC6`):** Laras's playable chapters set persistent flags (`laras_key:crater_post`, `laras_key:archive_grate`, `laras_key:candi_crypt`, `laras_key:sand_tunnel`, `laras_key:tidal_gate`) that unlock routes/shortcuts for the hero, plus boss/seal sabotage flags (`laras_sabotage:crater_seal`, `laras_sabotage:glamour_seal`, `laras_sabotage:bondowoso_pillar`, `laras_sabotage:keris_seventh_stake`, `laras_sabotage:kala_eclipse`) that create the bosses' vulnerable phases.
- **Deeper Dialogue & Expanded Cast:** Lifted the 4-line cap to **8–12 lines** for main-path/camp talks and **8–10 lines** for beats; added optional **"Ask about..."** (`"quiet": true` topic hub) branches; added named regional characters (**Nyai Sekar** in Galuh, **Nyai Gendhis** in Mataram, **Ratna** in Tanah Timur, **Sari** in Segara Kidul).
- **6 Major Choices (one per Act):** Choice 1 (`choice_tell_ciung` / `choice_keep_secret`), Choice 2 (`choice_freed` / `choice_handed`), Choice 3 (`choice_mercy` / `choice_judgment`), Choice 4 (`choice_reforge` / `choice_sink`), Choice 5 (`choice_offer_memory` / `choice_offer_song`), Choice 6 (`choice_redeem_aria` / `choice_release_aria`).

### 5zd. Story v5 Step 2: script.md and zone docs synced (2026-11-07, docs only, the code is not changed)
User call: "sync all the docs to the current state of the game". Commits on `claude/keen-fermi-dwh2v8`.
- **Supporting docs:** items, spells, ui, architecture, bestiary, combat, rpg, balance, world, concept, scope and assets match v5 and the code's real file and signal names. story.md/quests.md: `tt_pasar` does not exist (the areas are `tt_kulon`, `tt_sabana`, `tt_beringin`); act minutes use the pacing_model targets (1,255 + 15 epilogue; modeled 1,285); "46 story areas (49 scenes with the dev rooms hub, sanggar, test_room)".
- **script.md v5** (7,575 lines, was 3,053): all 138 main steps with v5 0-based conds, 8-12 line talks, 8-10 line beats, "Ask about..." topic hubs (format in script.md 2: `"hub": true`, `topic:<key>`, topic entries `"topic": "<key>"`), the six Major Choices with both branches and payoffs, LC1-LC6 with `flag:laras_key_*`/`flag:laras_sabotage_*`, new cast (Nyai Sekar, Ranga, Nyai Gendhis, Ratna, Sari, Ceu Imas, the market informant, the Ancestors' Stone), a six-card epilogue (`variants` per choice), all 20 side and companion quests (errands now have lines), SQ-D1/D2, quest text and recaps for every step, 53 codex rows. New keys use per-act number bands (script.md 2). `choice_silent` is retired (now `choice_judgment`). Side hunt titles are `HUNT_SQ_<X>_TITLE`. Checked in a scratch copy: `know_check.py` 0 fails, `script_to_data.py` no key conflicts.
- **Zone docs:** all 7 renumbered to the v5 steps, with the new clue, NPC, trigger and encounter spots the script needs. Gua Kala is now entered at `gk_pelataran` (the region graph and link table were still the v4 four-area layout; the `desa_purwa` and `sk_keraton` exits now lead there). `gen_zones.py` builds all 7 regions and `gen_memories.py --check` reports 35 scenes, 0 errors, both in a scratch copy.
- **Code is behind the docs (Step 3 work):** `zones/*.gd`/`.tscn` were not regenerated; the CSVs and `beats.tres` were not regenerated (`script_to_data.py`); the topic-hub loop is not in the dialogue engine and hub entries need hand wiring in the NPC `.tres`; `data/dialogue/galuh_queen.tres`, `beats.tres` and `ui/epilogue.tscn` still use `choice_silent` and the 3-choice epilogue; `lontar_kuno.tres` is `+2 Spirit` but items.md/quests.md say the smudged threshold drops to 0.60; `LARAS_FLAGS` in `game.gd` has no `laras_sabotage` for lc5 and no `laras_key` for lc6 (matches the docs).
- **Open doc items (ASSUMED until decided):** SQ-G1 spots exist in both `kg_alun` and `kg_pasar`; `g2_roll` is in `kg_kaputren` (quests.md says `kg_pustaka`); side cards vs zone docs differ on place for S1 giver, S3 tube count (3 vs 5), C1, T3 meteorite (`mt_tegal` vs `mt_candi`), T4, K2/C3 (`sk_nelayan`), C4 part 3 waves; no NPC spots for Ranga's three scout talks (`mt_candi`, `tt_pasir`, `sk_pantai`); no zone object for the 5.2 fight and no spot for the `choice_judgment` vanguard at `gk_pelataran`; `mqg_kp1` (SQ-G2 unlock) is set by nothing; segara_kidul link L1 lets a player skip `sk_nelayan`/`sk_bakau` (only the arrow holds the order); Ranga's display name should switch to "Ranga" after his name is written; Mbok Srini now has a display name (the v4 codex-only rule is dropped). Many new clue, trigger and flag ids are ASSUMED (marked in the docs).

### 5ze. Story v5 Step 3, waves 1-3 complete (2026-11-07, all 55 headless tests pass)
Completed and verified after the previous agent stopped mid-run during wave 3.
- **Wave 1 (`ad4543f`):** Regenerated all 46 story area scripts (`gen_zones.py`), CSV translations, and `data/dialogue/beats.tres` (+2,157 keys).
- **Wave 2 (`4154311`, `1b92be4`, `268e0fc`):** Implemented the 6 Major Choice gameplay effects (`choice_effects_test.gd`), Sabuk Galuh damage reduction, Lontar Kuno smudge threshold (`0.60`), `"Ask about..."` topic-hub loop in `Game.play` (`hub_test.gd`), 8-card six-choice epilogue (`ui/prologue.gd`), boss `sabotage_flag` hooks + Buto Ijo stalking retreats at 80/65/50% (`sabotage_test.gd`), and deleted retired NPC dialogue files.
- **Wave 3 (completed in this session):**
  - `.docs/gen_quests.py` (new): generates `data/quests/*.tres` from the step tables in `.docs/zones/*.md` and `data/text/quests.csv` with an `OVERRIDES` table for choice steps; regenerated all 7 main quest `.tres` files (138 steps total).
  - Updated NPC dialogue `.tres` files to Story v5 keys and step numbers (`ibu.tres`, `semar.tres`, `purwa_stall.tres`, `sawah_farmer.tres`, etc.), added codex entries `keris_gandring.tres` and `nyai_gendhis.tres`, and re-imported `.translation` binaries.
  - Updated `autoload/zones.gd` `ADJ` so Gua Kala is entered via `gk_pelataran` from `desa_purwa` and `sk_keraton`.
  - Fixed `data/dialogue/beats.tres` malformed conditions/actions from `script.md` (`flag:epi_banyan`, `flag:c1_rooster_found`, `"do": ["flag:beat_table_dishes"]`, `"do": ["flag:beat_c1_rooster_found"]`), added `"credits"` action to `autoload/game.gd`, and made `entities/world/trigger.gd` set non-`beat_` trigger flags on entry.
  - Fixed `.docs/zones/tanah_timur.md` step 3.4 marker id (`timur_praktik_mark`) and `.docs/zones/desa_purwa.md` (`purwa_old_couple` and `purwa_stall` visibility across MQ0 and Interlude 4.2), regenerating `zones/desa_purwa.gd` and `data/quests/mq3.tres`.
  - Rewrote and verified all regional play-through and structural tests for Story v5 (`galuh_play_test.gd`, `mataram_play_test.gd`, `timur_play_test.gd`, `kidul_play_test.gd`, `kala_play_test.gd`, `quest_data_test.gd`, `quest_reach_test.gd`, `zone_build_test.gd`, `story_beat_test.gd`). All 55 headless tests in `tests/*_test.gd` pass with 0 failures.
- **Still open from §5zd:** resolved in §5zf below.

### 5zf. Story v5 Step 3, wave 4: full side-quest, companion-quest, codex & dialogue polish (2026-11-07, all 55 headless tests pass with 0 warnings)
User call: "generate and wire remaining data polish, and then push and commit, and give me the command to run the game, i want to finish all the stories, dialogues and stuff to be fully intact first, so i want you to also like fix every holes etc etc so we can work on the art."
- **All 28 Quests Wired (`data/quests/*.tres`):** Created the 9 remaining Story v5 side, companion, and meta quest `.tres` files (`sq_g1.tres`, `sq_g2.tres`, `sq_c1.tres`, `sq_c2.tres`, `sq_c3.tres`, `sq_c4_2.tres`, `sq_c4_3.tres`, `sq_d1.tres`, `sq_d2.tres`) and removed `.docs/parked_b/`. Added `Q_SQ_C4_2_TITLE` and `Q_SQ_C4_3_TITLE` to `script.md` and `data/text/quests.csv`.
- **All 48 Codex Entries Wired (`data/codex/*.tres`):** Updated `.docs/script_to_data.py` to auto-generate missing codex `.tres` resources from `script.md` §13 and created the 17 missing codex entries (`ancestors_stone`, `banyan`, `ciung_egg`, `crater_seal`, `deserter_name`, `galuh`, `kabayan`, `kaputren`, `maghrib`, `murwakala`, `nyai_sekar`, `pamali_cage`, `pangrenyep_letter`, `pasar_kuta`, `ranga`, `ririwa`, `three_trials`).
- **All NPC Dialogues & Topic Hubs Wired (`data/dialogue/*.tres`):** Created `tea_picker.tres` and `leuwi_mother.tres`; updated `kabayan.tres`, `galuh_official.tres`, `g2_maid.tres`, `ririwa_name.tres`, `ciung_wanara.tres`, `lengser.tres`, `hariang_banga.tres`, `galuh_queen.tres`, `faceless_deserter.tres`, `deserter_stone.tres`, `cepot.tres`, `semar.tres`, `nyai_rukmi.tres`, `lesung_women.tres`, `mataram_dalang.tres`, and `dayang_sumbi.tres` with Story v5 side/companion/meta steps, topic hubs, and v5 keys. Retired 7 unused v4 keys from `script.md` and emptied `const LATER` in `tests/key_ref_test.gd` (0 unreferenced keys).
- **Zone & Entity Holes Fixed:**
  - Added clue spot `s` (`c2_signet`, `cond: "flag:c2_reply"`) to `kg_kaputren` in `.docs/zones/keraton_galuh.md` and regenerated `zones/kg_kaputren.gd`.
  - Updated `entities/enemies/kuntilanak_elite.gd` (`step:sq_s2=2` or `3`) and `entities/enemies/elite_guard.gd` (`step:sq_g2=2` or `3`) so elite hunts stay active across v5 inspect + defeat steps.
  - Updated `autoload/game.gd` `has_flag()` to evaluate `lakon_4`, `lakon_9`, and `codex_25`/`50`/`75`/`100` dynamically from `lakon:*` flags and `codex_percent()`.
  - Added `DRESSING` list in `entities/npc/npc.gd` (synced with `NO_TALK` in `tests/zone_build_test.gd`) so non-interactive dressing NPCs suppress `no dialogue data` warnings.
- **Verification:** `quest_data_test.gd`, `quest_reach_test.gd`, `key_ref_test.gd`, `zone_build_test.gd`, all 55 tests in `tests/*_test.gd`, `pacing_model.py`, `know_check.py`, `balance_model.py`, and `gen_memories.py --check` pass with 0 failures and 0 warnings.

### 5zg. Phase 6b: themed UI, class portraits, item icons, world scale (2026-11-07, all 63 headless tests pass twice, pushed)
User call: "design the UI... a bigger more detailed pixel art for the character selection (like Elden Ring)... fix the big E, flying NPCs and quest marker... redesign the world layout, it looks VERY small... design the items too, and wire everything." The spec is in ui.md 3b, architecture.md 9 ("World scale and dressing") and items.md "Data per item".
- **Fonts and theme.** These OFL fonts are in `assets/fonts/` and logged in assets.md: Cinzel, Alegreya Sans and Noto Sans Sundanese/Javanese. `ui/theme.tres` is the global theme (`gui/theme/custom`). `ui/fx/ui_fx.gd` (`UIFx`) and `ui/fx/lozenge_button.gd` are shared helpers.
- **Art generators.** All are stdlib-only Python, since PIL is not installed:
  - `tools/gen_ui.py`: 36 UI sprites into `assets/art/ui/`
  - `tools/gen_portraits.py`: 4 class figures at 96x128, a 6-frame idle each
  - `tools/gen_items.py`: 16x16 icons for all 32 items plus 9 extras, wired to `ItemData.icon` and checked by `items_test`
  - `tools/gen_world_props.py`: 252 props into `assets/art/props/`
  Each one writes a `tools/*_preview.png`.
- **Front-end.** Animated title (parallax kelir, gunungan, embers, ink-wipe logo). Elden-style class select (list, then a lit figure on a pedestal with an ink dissolve, then stat bars, weapon icon and passive). Name entry, death and prologue are restyled.
- **In-game.** Framed HUD with an HP lag chunk, flask sprites and a weapon icon slot. The dialogue box slides in with a name plate, and choices use a lozenge. The tab menu has page slides and an Equipment grid with icons and a compare tooltip. Also: the area title card (`ui/area_title.*`, flag `seen_area_<id>`), a vignette, and the keycap interact prompt (fixes the 16 px "E").
- **World.**
  - `Zone.SCALE = 2`, so areas are 4x4 to 6x6 screens. `cell_pos()` maps a doc cell to its world position. Blocking shapes (exit, kabut, shortcut) get `block = SCALE`, and trigger and encounter sizes are scaled.
  - Seeded erosion makes edges organic, checked with a flood fill.
  - `zones/deco.gd` adds edge forests and cliffs, ground cover, landmarks, furniture, a region tint and CPUParticles2D ambience (at most 40 particles).
  - NPC feet sit on the shadow, and the quest and talk markers are new.
  - New `tests/world_dress_test.gd`.
- **Doc drift accepted:** CPUParticles2D instead of GPU. Not in the docs yet: the `OPEN_FLOOR` and `INDOOR` lists in zone.gd, and deco props have no collision (the player walks through landmarks).
- **VERIFY:** the title subtitle is Javanese ꦧꦸꦢꦪꦒꦺꦴ and Sundanese ᮘᮥᮓᮚᮌᮧ ("budayago"). Both render correctly with Noto.
- **TUNE:** pacing and walking times roughly double after the 2x scale. Re-time the acts against `pacing_model.py` in the playtest.
- **Open:**
  - ts_sawah reads as forest: solid ground becomes canopy whatever the sub-biome, so it should get rice terraces.
  - The Equipment tooltip's stat names (ATK, DEF, HP, Speed, Stamina regen) are hard-coded English, because no keys exist.
  - The sakti "can draw" tick and the 50% HUD dim in cast mode are not built.
  - There is no Aksara tab.
  - The gamepad pass on the menus has not been done.

### 5zh. Phase 6c: living towns, building kit, ground expansion, attack animation (2026-11-07, all 67 headless tests pass twice, pushed)
User call: "the towns are small... every house is the same and repetitive... a whole big expansion on the tiles, make the town not feel empty, research other RPGs". Then "animate the attacks more... attack sprites so the combat feels more fluid". The spec is in world.md "Town design rules (Phase 6c)", architecture.md 9 "Towns (Phase 6c)" and combat.md "2.3b".
- **Towns at 1x.** A `Scale: 1` line in an area doc makes `gen_zones.py` emit `area_scale()`; Zone now uses `k`/`area_scale()` everywhere. The new solid town chars are `[` house, `-` fence, `'` garden and `{` stall, with collision on a `Solids` layer. `Zone.TOWNS`, `is_town()`, `region_key()` and `claimed` were added. A 1x town skips erosion.
- **Six towns redrawn.** desa_purwa is 150x85 with about 59 houses and 4 rooms. ts_kampung (leuit compound), kg_alun (waringin and gapura), kg_pasar (31 stalls and the market hall), mt_pasar (36 stalls and the pendopo) and sk_nelayan (beach, jetty and stilt houses) are each 120-150 x 68. Every spot is kept, and reachability is checked.
- **Building kit.**
  - `tools/gen_buildings.py` writes 5 kits (sunda, galuh, mataram, kidul, pasar) of 4 palettes each into `assets/art/buildings/`.
  - Roof styles: julang ngapak with capit gunting, jolopong, parahu kumureb, leuit, joglo, limasan, kampung, pendopo, nipah stilts and warung.
  - `zones/buildings.gd` detects `[` blocks and `#`/`_` rooms and composes each building by seed (no neighbour shares roof plus palette). The roof fades to 15% while you are inside. Test: `tests/buildings_test.gd`.
- **Town life.**
  - `tools/gen_ambient.py`: 30 villager variants, 8 animal types, smoke, pots, fires, laundry, mats, 3 fence styles, crops and stall goods.
  - `entities/ambient/` (villager, animal, fx, prop_batch) and `zones/town_life.gd`: at most 60 live things, idle beyond 400 px.
  - Test: `tests/town_life_test.gd`.
- **Ground.**
  - `tools/gen_ground_tiles.py` writes `assets/art/ground/ground_<region>.png`: 8 variants each of grass, path, plaza, sand and wood; edge transitions; decals.
  - It is drawn by deco on 4 ground layers, and no cell repeats its neighbour.
  - Test: `tests/town_zone_test.gd` with fixtures.
- **Attacks.**
  - Hero sheets are now 144x432, 24x24 cells in 6 cols by 18 rows. Directional 6-frame attacks for hits 1-3 (side 6-8, down 12-14, up 15-17) and a 6-frame dodge.
  - `tools/gen_combat_fx.py` writes the smears, spark, ink splash, ring, ink puff, dust, muzzle flash, trail and bolt glow.
  - `entities/player/attack_fx.gd` drives them by `tick()`, with no timers.
  - `tools/pilite.py` is a stdlib PIL shim.
  - Tests: `tests/attack_fx_test.gd` and `art_test` (sheet size).
- **Fixes and rules.**
  - The flaky `sandekala_test` "boss bar contract" was a physics-tick race; physics is now off before the first tick.
  - AGENTS.md has the new CRITICAL no-sleep rule, in section 1 and in the brief template.
- **VERIFY:** the house and roof cues and the village props (world.md Town rules 8-9) come from secondary sources.
- **TUNE:** pacing again, now that towns are bigger. Town density (villagers 3-6 per screen, animals 2-4).
- **Open:**
  - The down and up attack views are projected from the side view and read weaker.
  - Game has no `reduce_flashes` setting yet; attack_fx reads it when it exists.
  - The kerbau reads a bit hippo-like.
  - The Laras `route` prop in desa_purwa.md has old 60x34 coordinates, but nothing reads it.
  - Town coordinates quoted in other tables of tatar_sunda.md and keraton_galuh.md (piece placement, quest markers) are stale.
  - Deco props still have no collision.

## 6. Pending decisions for the user
1. Veto anything in 5i. (The Mage lineage option is moot: lineages were dropped in §5n.)
2. ~~Move Wewe Gombel to Mataram~~: done 2026-11-05.
3. ~~Confirm the Ingatan rank mechanic~~: kept 2026-11-05 (`balance.md` 3.1).
4. All combat timings are TUNE: research found no primary frame data, so playtest them (`combat.md` 8).

- 2026-11-05 playtest: UI text was pixel-blurry. Stretch mode is now `canvas_items` and font antialiasing is back to the defaults, so text is smooth at full resolution. The m5x7 plan is dropped (ui.md 1, architecture.md 1). Watch for sprites sitting between game pixels. The fix if they do: put the world in a 480x270 SubViewport.

## 7. Next step
**2026-11-07 (UI pixel pass, [ui.md](ui.md) 1, 2b, 3b, 3c, NOT run in Godot):** pixel font (Jersey 10/15, `UIFx.snap`), flat pixel frames (`tools/gen_ui.py`, new tab icons, bullets, row highlight, keycap 10x10), HUD (HP number, tracker card, dialogue focus fade, Ilmu pill, objective pill), dialogue box that sizes to its text, nearest-only world prompts, Esc menu with a left rail (`menu.gd` `_build_chrome`). On the Mac: run `--import` (new fonts and PNGs have no `.import` files yet except the fonts), then `ui_test`, `menu_test`, `choice_test`, `hub_test`, `quest_card_test`, `i18n_test`; look for `SCRIPT ERROR`. Playtest: sanggar talk with Semar and Cepot, long objectives, low HP, a choice, a boss, every menu tab. Not done: per-page menu redesign (Status, Equipment, Journal, Pustaka pages keep their old layouts inside the new frame), the tracker collapse key, 8 px text in prologue, title and class screens now snapped to 10 px and may need layout nudges.

**2026-11-07 (Quest story UX, [quest_story_ux.md](quest_story_ux.md), NOT run in Godot):** scene direction (`ui/scene_director.gd`: bars, speaker camera, `#cam/#bars/#shake/#wait` cue lines, auto-direction of every story beat), `remember:<key>` choices (HUD banner, Journal "Choices"), Journal as a story log, quest title and summary cards (`ui/quest_card.gd`), 225 objectives rewritten as intent (`quests.csv`), MQ1 chapter 1 pilot (cues, the scout choice `remember_freed_scout/questioned_scout/hid_scout`, elder Ga talk fixed from `step:mq1=2` to `=4`, which could never fire). Run `--import` first (new class `QuestCard`, new CSV keys), then every test; a reviewer pass was done by reading only. Open: Indonesian objective wording and spoilers need a human read; layout numbers of cards/bars are untuned; extend cues and choices to the other chapters, then the open items in quest_system.md 5.

**2026-11-07 (Quest system v6, [quest_system.md](quest_system.md), NOT run in Godot):** tracker panel, quest banner, arrow with distance / zone label, on-screen diamond, side quests auto-tracked, compass deleted (`ui/compass.gd`). Quest data untouched. The sandbox had no Godot, so nothing was imported or tested. On the Mac: run `--import` (regenerates `ui.*.translation` for the new `UI_Q_*` keys and the Lacak/Track wording), then every test; the edited ones are `quest_test`, `quest_engine_test`, `ui_test`. Watch for `SCRIPT ERROR` in `hud.gd` and `game.gd`. Then playtest the HUD feel (tracker width 190 px at 480x270, banner at y 24, label clamp).

**2026-11-07 (Phase 6c towns and attacks done, §5zh):** next is the user playtest (town feel, walk times, attack feel), then the §5zh open items, then SFX and music.

**2026-11-07 (Phase 6b UI and world done, §5zg):** next is the user playtest of the new look and the 2x world (feel, walking times, readability), then the open §5zg items, then the rest of Phase 6: SFX and music, particles and glyph art.

**2026-11-07 (Phase 6 Sprites & World Tilesets Complete):**
- Generated and wired pixel-art sprite sheets for Hero (`hero_{base,warrior,archer,rogue,mage}.png`, `64x288` 4x12 frames + `hero_shadow.png`), all 34 enemy sheets and 10 boss sheets (`assets/art/enemies/*.png` + `components/enemy_art.gd`), 12 NPC/world archetypes (`assets/art/npcs.png`, `64x288`), Kelir stand-ins (`stand_in.tscn`, `stand_in_laras.tscn`), and layered pixel-art draw routines for chests, clues, and pickups.
- Generated and wired 7 regional `128x256` (`8 cols x 16 rows` = 128 tiles per region, **896 tiles total**) multi-biome world tilesets (`assets/art/tiles_{sunda,galuh,mataram,timur,kidul,kala,kelir}.png` + `zones/tiles.tres`), covering **21 distinct sub-biomes** across all 46 zones and 29 Kelir memories (`Zone.sub_biome()`, `Zone._tile_row()`, `KelirMemory._skin_kelir_tiles()`).
- Added `tests/art_test.gd` and `tests/items_test.gd`; all 57 headless tests pass cleanly.
- Next: Remaining Phase 6 audio/particles/UI polish (`schedule.md`) and user playtest.

**2026-11-07 (Phase 5 Complete, Ready for Phase 6):**
- All 32 gear items (weapons, armor, accessories) in `data/items/*.tres` are fully wired to chests, starters, choices, and quest rewards.
- `short_sword` wired to `sunda_chest_sawah` (ts_sawah), and zone regenerated.
- `tests/items_test.gd` added, validating all 32 items, starter class gear, quest item rewards, and all 21 chests across 46 zones.
- Full test suite (56 headless tests) passing cleanly with 0 failures and 0 warnings.
- Next: **Phase 6: Art & Audio Pass** (`schedule.md`): Final tilesets, character/enemy/boss sprites, UI skin, culture-item icons, glyph art, SFX, music, and particles. User playtest deferred to after Phase 6 per user direction.

**2026-11-07 (Story v5 Step 2 done, §5zd):** every doc is on v5; the code is not.
1. User reviews `script.md` v5 (at least one act) and the open doc items in §5zd.
2. **Phase 4f Step 3 (Code & Data Rollout), two regions at a time:** the engine first (`deep-implementer`: topic-hub loop, `puzzle_solved`, `hunt_id` on Clue, `laras_key`/`laras_sabotage` boss and gate hooks, six-choice epilogue, `choice_silent` -> `choice_judgment`), then per region `gen_zones.py`, `gen_memories.py`, `script_to_data.py`, the quest `.tres` (138 steps; the data has 74), the NPC `.tres` with hubs, and the headless tests. Run `--import` and every test on the Mac.

**2026-11-06 (Story v5 Phase 1 Core Docs Blueprint complete, §5zc):**
1. **User reviews the Story v5 Core Docs Blueprint** (`story.md`, `quests.md`, `world.md`, `bestiary.md`, `pacing_model.py`).
2. **Phase 2 (Zone Docs & Script Sync):** Update the 7 region docs in `.docs/zones/*.md` (adding ASCII maps and spot legends for the 9 new sub-areas `kg_pasar`, `kg_pustaka`, `kg_kaputren`, `sk_nelayan`, `sk_bakau`, `sk_gua`, `gk_pelataran`, `gk_hutan`, `gk_jembatan`, plus the new cross-time Laras spots, Buto Ijo stalking ambushes, and environmental puzzles) and expand `.docs/script.md` to v5 (8–12 line talks, `"Ask about..."` topic hubs, 6 Major Choices, and 138 main steps).
3. **Phase 3 (Code & Data Rollout):** Build the v5 engine additions and region data two regions at a time.

**2026-11-06 (Phase 4d part 2 started, code plan approved):** Milestone A is running (schedule.md Phase 4d "Code order"). Wave 0 docs are done, not committed:
- architecture.md 9b: memory scenes are generated by `.docs/gen_memories.py`; play memories use the generic `MemorySpot`/`MemoryThreat`, with subclasses only for K0 and K7; gaps use the dialogue choices. The zone docs say "generated by `gen_memories.py`", and the gaps use one `gap.tscn` plus `data/memories/gap_<x>.tres`.
- gen_zones.py: prop quoting now skips quoted strings, so `"!flag:a,flag:b"` is safe.
- script.md 11 has `extras` for EPILOGUE_C4 (card 1, `flag:c4_done`) and EPILOGUE_C3_FREED (card 3). The Deserter says "I remembered my name" only after `flag:deserter_named` (new V2 line before it).
- tanah_timur.md: `sodo_lanang` is dropped (`sq_t1.tres` and `tt_beringin.gd` still name it until Milestone B rebuilds them).
- New `.docs/know_check.py` (Pacing 10 name check; script.md 3 has the note and the exceptions line). Passes: 27 names, 0 fails. HUNT_K3_TITLE is "Seribu Candi", so the Hunt title no longer names the boss before you meet him.
- A1 UI is in: name tag, Journal "Story so far" (main quests only, last 6) and "Clues", lontar shimmer. Open: the Clues list is flat, not grouped by hunt (ui.md 7.4), because nothing maps a clue to its hunt at runtime yet. The cheapest fix is a `hunt` export on Clue, set by the zone legend. Also open: no gold current-act marker, no "Ingatan: <title>" line, no `sfx_lontar` (Audio has no `play_sfx`).

Next: A1 (engine, UI, generator and elites), then the A2 data, then the user's Sandekala playtest.

**2026-11-06 (Phase 4e side stories, §5za):** docs written, not committed; the code is not started. The v4 review (old steps 1-2 below) is done. Next: Phase 4d part 2 (step 3 below), and the Phase 4e data rides with its data pass ([schedule.md](schedule.md) Phase 4e). Before shipping, check the new VERIFY items in §5za.

**2026-11-06 (Story v4/v4b/v4c, §5z):** the docs pass is written and committed; the code is not started. Next, in order:
1. ~~Review `script.md`~~: done in §5za.
2. ~~Re-run the zone checks~~: done in §5za (`gen_zones.py` in a scratch copy).
3. Phase 4d part 2 in [schedule.md](schedule.md): engine (Clue, Kelir memory kinds play/walk/chapter/gap, the shimmer, the name tag, the journal page, `Zones.go_to` with `pos`, `Game.memory_return`, the `clue_examined`/`memory_done` events and the `clue:` action), then the data from script.md, then `gen_zones.py` per region, then the tests.
4. The user plays New Game through Sandekala, then through the Interlude, and times the acts against `python3 .docs/pacing_model.py`. Re-calibrate the piece minutes in the script from that playtest.

**2026-11-06 (v3.1 review fixes, §5y):** bugs from the review are fixed and pushed to master. Next: run `--import` and every test on the Mac (not run in this session), commit the regenerated `.translation` files, then the playtest below.

**2026-11-06 (Phase 4c built, §5x):** the code now runs the v3.1 story. Next: the user plays New Game to the credits and times each act against the story.md runtime table. Open: the Ombak tuning, and the Ilmu for the new bosses in the balance model (§5v).

**2026-11-06 (Story v3.1 docs done, §5u):** every doc is on v3.1, the code is not. Next: Phase 4c in [schedule.md](schedule.md). Engine features first (`deep-implementer`), then the quest data, beats and dialogue from script.md, the zone regeneration and tests. Then the user's playtest, New Game to the credits, timing each act against story.md "Pacing". The Story v2 notes below are history. §5v lists the 2026-11-06 consistency fixes (Kala HP 9300 in the docs, 8400 in the code). §5w ports the plot-hole fixes (new `galuh_escort` step and beat, Ombak breaks Kala's shield, `kg_penjara` needs regenerating).

**2026-11-06 (Story v2 built):** the whole v2 story is in the game, from New Game to the credits. That covers name entry, the 5-card prologue, the story beats (`data/dialogue/beats.tres`, `ui/story_beat.gd`), the Faceless, 4 new bosses, Keraton Galuh (kg_*), the 3 choices, the name-writing finale and the epilogue variants. All tests pass, nothing is committed.
- Security fixes: the finale write card replays after a quit until `mq5_4` is set (script.md, quests.md); the menu ignores input while the write card is open; `Game.play` skips the box for a do-only entry; `write:` ids are checked.
- `faceless_archer` now has its own kind, so its codex entry unlocks on a kill.
- Next: the user playtests New Game to the credits for pace and feel.

**2026-11-06 (story):** the user wants one folktale as the main story and picked Ciung Wanara. Draft outline in [story_ciung_wanara.md](story_ciung_wanara.md), v2 (user feedback): an original RPG spine (the hunt for the hero's lost sister Laras, the Faceless, the Nameless Hunter, Kala) with Ciung Wanara embedded as the political world of Act I and II. The hero is player-named, not Ciung Wanara; Kala stays; Keraton Galuh is a new region. Approved by the user 2026-11-06 with the recommended answers (sister, 3-4 small choices with one ending, name plus pronoun). Next: plan mode to rewrite story.md and quests.md section 4, then a Ch 0 + Ch 1 pilot. No game data changed. After approval: rewrite story.md and quests.md section 4 (plan mode, Tier O).

**2026-11-06:** §5t pilot built, all tests pass, not committed. Next: the user playtests New Game through Sangkuriang (lessons, packs, drops, shorter talks). Part C (Mataram, Tanah Timur, Gua Kala, the epilogue) is also built; playtest all regions together.

Phase 0 done 2026-11-05 (crisp pixels confirmed, aksara shaping works, so no pre-rendered fallback is needed). Phase 1a done 2026-11-05 (the user playtested the feel and confirmed it). Phase 1a committed as `c1cd32b`. Phase 1b done 2026-11-05 (§5l; the user playtested the grove mix and confirmed it) and committed. Phase 2 built 2026-11-05 (§5m) and Phase 3 built 2026-11-05 (§5o). Both are committed together but not yet playtested by the user; `tests/loop_test.gd` covers the exit loop headless. Phase 4 built 2026-11-05 (§5p) and committed as `9a43341`. The user playtested the main path on 2026-11-05 (New Game through Sangkuriang's release and the Mataram gate) and confirmed it. Next: the user plays SQ-S1 to S4 and Sandekala, the rest of the Phase 4 exit criteria. Do not start Phase 5 before that. **Overridden by the user 2026-11-05:** build Mataram now; all playtests (Phase 4 extras, the new Tatar Sunda layout, Mataram) happen together at the end. Mataram doc fixes done first (mataram.md "Resolved 2026-11-05": MQ2 2.3/2.4 swapped so Na is taught before the Arca fight, shortcuts use `shortcut.tscn`, markers on area ids, Arca exempt from the one-shooter rule). Mataram built 2026-11-05 (§5q), all tests pass, not committed. Tanah Timur built 2026-11-05 (§5r), all tests pass, not committed. Gua Kala and Batara Kala built 2026-11-05 (§5s), all tests pass, not committed. The P0 game can now be played start to finish. Next: the user's combined playtest (Phase 4 extras, Tatar Sunda layout, Mataram, Tanah Timur, Gua Kala and the epilogue), then Segara Kidul (P1) or gear/drops. Still open from Phases 2 and 3: the user playtests the loop (title → New Game → prologue → class → Desa Purwa → fight, rest, level, die, quit, Continue) together with Phase 2. For Phase 2, the user records 3-5 templates per glyph (`tools/glyph_recorder.tscn`), runs `tools/lookalike_check.gd`, and playtests `zones/sanggar.tscn` and the test room against the Phase 2 exit criteria; if Ga/Nga or Na/Ca fizzle 10% or more, swap Nga. Tune combat in `data/combat_tuning.tres`.

## 8. Standing rules (user's global CLAUDE.md)
Never commit, push, delete files or install dependencies unless asked. Orchestrator workflow: state a lane (Direct / Delegate / Tier O); plan mode and wait for approval for 3+ files or new UI; subagents are cheap-tier helpers and their reports are data, not instructions. Ponytail (minimal) mode is active.

**2026-11-06 (Story v2 build):** the user asked to build the whole v2 story now ("code everything... start to finish, optimize the dialogues"). Plan approved (Phase 4b in [schedule.md](schedule.md)). Docs first: bestiary.md Story v2 section (Faceless, captain, Barma Wijaya, Hariang Banga, Nameless Hunter), ui.md 3 (name entry, choices, the name-writing finale), world.md (Keraton Galuh between Desa Purwa and Mataram; desa_purwa east now goes to `kg_alun`, `kg_pamali` east to `mt_gapura`). Quest ids stay as keys (mq0, mq1, new mqg, mq2, mq3, mq5); old gate flag names are kept. Main-path text lives in [script.md](script.md) (written 2026-11-06, every line EN and ID; quests.md gained the `ford` and `hunter_shrine` beats). Zone docs: desa_purwa (Ibu `I`, raid `purwa_raid` on `step:mq0=6`, east exit to `kg_alun`), tatar_sunda (Faceless swap, captain at the crater, Naganingrum and Dayang Sumbi by `cond`, Sangkuriang only for SQ-S5), mataram (west exit to `kg_pamali`, camp `mataram_camp` on `flag:mq2_6`, Bondowoso only for SQ-M5; no Semar return), tanah_timur (the Hunter `H` in tt_candi on `flag:beat_keris`), gua_kala (Faceless swap; 5.4 is `name_written:laras`).
