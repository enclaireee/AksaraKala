# Quests

The main quest, all side quests, the reward economy and the quest system that runs them. Related: [story.md](story.md), [world.md](world.md), [bestiary.md](bestiary.md), [items.md](items.md), [spells.md](spells.md), [architecture.md](architecture.md).

Conventions as in [README.md](README.md): **ASSUMED**, **VERIFY**, **TUNE**. Every legend detail in this file is from general knowledge and is **VERIFY** unless it is already in the Nov 2026 fact-check (see [HANDOFF.md](HANDOFF.md) section 4).

## 1. Decisions (confirmed by the user, 2026-11-05)
| Topic | Decision |
|-------|----------|
| Guidance | Quest journal in the Tab menu, plus a soft edge-of-screen arrow for the **active main objective only** (the player may pin one side quest instead) |
| Main order | Fixed (v3.1): Desa Purwa, Tatar Sunda, Keraton Galuh, Mataram, Tanah Timur, Desa Purwa (Interlude), Segara Kidul, Gua Kala. All P0. Fog gates enforce it |
| Side quest types | Folklore re-tellings, spirit bounties, errands for villagers. No aksara-reading puzzles as side quests |
| Volume | 3-4 side quests per zone, about 16 in total |
| Missable | Never. No quest closes, fails or times out. All stay open after their zone's boss and after the ending |
| Choices | Side quests can be resolved 2 ways (peaceful or fight), with no effect on the main story. The 3 main-quest choices each change one epilogue card and one visible thing in play (section 4) |
| Language | All quest and dialogue text in **Indonesian and English** from the start |
| Rewards | Left to design: see section 3 |

## 2. Principles
1. **Every quest is a piece of culture.** A quest exists to deliver one legend, custom, object or place. If it would work just as well with generic fantasy names, cut it.
2. **Reuse systems, add data.** A quest is built from things the game already has: NPC dialogue, enemies (normal or elite), pickups, triggers, existing glyphs. No quest needs a new mechanic, except the boss fights in the main quest.
3. **Short.** A side quest takes 3-8 minutes. At most 4 steps. No escort that can fail, no timer.
4. **Respect the sensitivity rules.** Deities are never enemies. Semar is never hostile. Nyi Roro Kidul is never fought. Living rituals (Yadnya Kasada, sedekah laut, labuhan) are scenery only. Kuda lumping is shown as performance only. Tuyul is only a money-stealing child spirit.
5. **The legend is told, not changed.** A re-telling quest follows the legend's real beats. Where the game adds something (the forgetting curse, a fight), the codex says what is legend and what is game.

## 3. Reward economy
The goal is rewards that **scale with the systems already designed** (5 stats, 3 gear slots, flask, codex), so that adding a quest is data entry and no reward breaks balance.

### 3.1 Every quest gives
- **Ilmu** by size and zone (**TUNE**, from [balance.md](balance.md) 8.3): S = half a level, M = one level, L = 1.5 levels at that zone's target level.

  | Zone | S | M | L |
  |------|---|---|---|
  | Tatar Sunda | 30 | 60 | 90 |
  | Keraton Galuh | 30 | 60 | 90 |
  | Mataram | 55 | 110 | 165 |
  | Tanah Timur | 110 | 220 | 330 |
  | Segara Kidul | 190 | 380 | 570 |
  | Gua Kala | 190 | 380 | 570 |

  - Keraton Galuh (MQG, `zone = "keraton_galuh"`, so the journal names the right region) uses the Tatar Sunda row (**ASSUMED** 2026-11-06), so the quest income in balance_model.py is unchanged.
  - Gua Kala uses the Segara Kidul row (**ASSUMED** 2026-11-05). Its only quest, MQ5, pays out after the final boss, so balance_model.py counts 0 for it.

  - Desa Purwa hub quests use the zone of the current main-quest chapter.
- **A codex entry** about the legend, figure or object, with a source line.

### 3.2 Plus one key reward, from these pools
| Pool | What it does | Count | Why it scales |
|------|--------------|-------|---------------|
| **Gear** | The weapons, armor and accessories in [items.md](items.md). Quests are the main source of gear. Chests and secrets hold the rest | 10 from quests | Gear is already data. A new item is one resource |
| **Flask Shard** | +1 max flask charge. Base 3, max 6 | 3 | Rewards exploration with survivability, the most motivating Souls-style reward |
| **Herb Pouch** | +5% flask heal each. Base 40%, max 60% | 4 (3 in P0) | Same as Flask Shard: flask power grows without new systems |
| **Lakon** (wayang story) | Unlocks a performance at the Desa Purwa wayang stage (see section 6.1) | 1 per re-telling | Feeds the hub meta quest, adds no balance |
| **Lontar Kuno** (old palm-leaf manuscript) | New accessory: the "smudged" threshold drops from 0.65 to 0.60 (**TUNE**) | 1 | Helps casting without adding a glyph |

### 3.3 Rules
- **No new glyphs from side quests.** The 8 core glyphs (plus the final glyph from Segara Kidul) come only from the main quest. This keeps the recognizer's candidate set small and tested, and every boss can assume the player has them. A P2 option: up to 2 bonus glyphs via side quests, only if the recognizer test still passes with them added.
- **Two-way quests give the same key reward either way.** The fight path gives +50% Ilmu. The peaceful path gives an extra codex entry and its own dialogue. So the choice is about flavor, never about power.
- **No reward is required to finish the game.** All flask upgrades together are a comfort, not a gate.
- Ilmu from side quests should make up about 25-35% of a full playthrough's Ilmu (**TUNE**), the rest from enemies and bosses.

### 3.4 Where every reward comes from
| Reward | Source |
|--------|--------|
| Kujang | Tatar Sunda secret chest (unchanged) |
| Golok | SQ-S2 Kuntilanak bounty |
| Spear (ex-Tombak) | SQ-M3 Tuyul bounty |
| Panah Pasopati | Mataram secret (unchanged) |
| Keris Luk 7 | SQ-T3 Pamor errand |
| Cakra | P2 (thrown archetype). If built: SQ-K2 sea spirit bounty |
| Iket Sunda | SQ-S1 Lutung Kasarung |
| Blangkon | SQ-M4 Gamelan errand |
| Baju Batik | Main quest, Bandung Bondowoso (MQ2) |
| Kain Hijau | Main quest, Segara Kidul trial (MQ4 4.9) |
| Silver Bangle | SQ-S4 Cepot |
| Feather Charm | SQ-M1 Jaka Tarub |
| Jimat | SQ-M2 Wewe Gombel |
| Stone Ring | SQ-T1 Ande-Ande Lumut |
| Lontar Kuno (new) | SQ-D2 Pustaka, at 50% codex |
| Flask Shard x3 | SQ-S3 Angklung, SQ-T4 Kuda Kepang, SQ-D1 Lakon (4 lakon) |
| Herb Pouch x4 | SQ-S2, SQ-M1, SQ-T2, SQ-K1 (P1) |

## 4. Main quest
Story v4 (the telling pass, user call 2026-11-06; v3.1 plot unchanged, [story.md](story.md) is the canon): the hunt for Laras. A Prologue, six acts and an Interlude, 78 steps, about 9.5 hours (**TUNE**; v4c pacing model below). New in v4: a playable normal day before the raid, a **Hunt** for every legend boss (hook, clues, Kelir memory, fight, aftermath; [story.md](story.md) Hunts), and a smaller cast. Quest ids stay as stable keys (`mq0`, `mq1`, `mqg`, `mq2`, `mq3`, `mq4`, `mq5`); the journal shows the act title. Old gate flag names are kept where they still fit. The arrow always points at the current step. Glyphs are learned only here. Each teacher speaks one hint about the enemy that glyph counters ([bestiary.md](bestiary.md) Glyph weaknesses). Every line of text is in [script.md](script.md). Act titles in Indonesian are **ASSUMED**.

| Quest | Part | Steps | Region |
|-------|------|-------|--------|
| MQ0 | Prologue "Sehari di Desa Purwa" | 9 | Desa Purwa |
| MQ1 | Act I "Segel Kawah" | 15 | Tatar Sunda |
| MQG | Act II "Wajah Pinjaman" | 9 | Keraton Galuh |
| MQ2 | Act III "Darah di Pamali" | 13 | Mataram |
| MQ3 | Act IV "Bilah Tujuh Turunan" | 11 | Tanah Timur |
| MQ4 | Interlude "Rumah yang Sunyi" (4.1-4.5) and Act V "Laut Tak Pernah Lupa" (4.6-4.12) | 12 | Desa Purwa, Segara Kidul |
| MQ5 | Act VI "Ke Rahang Sang Waktu" | 9 | Gua Kala |
| Total | | 78 | |

**Cast cuts (v4, ASSUMED).** Display names and objective text only; NPC ids and file names are unchanged. Abah Karna is "the kampung elder" (`sunda_elder`), Mbah Marto is "the juru kunci" (`juru_kunci`), Mbok Srini is "the widow" (`mbok_srini`), Dewi Pangrenyep is "the queen", Aki and Nini Balangantrang are "the old couple" (`nini_balangantrang` stays as the id). Ki Wangsa is cut: Semar is the village dalang. The names stay in codex entries as legend names. Cepot is met in MQ0 at the sanggar (0.3).

**Pacing model (v4c, user call 2026-11-06).** Every step table has a last column `Play`: the step's pieces from the type list in [story.md](story.md) "Pacing model" (`talk`, `beat`, `lesson`, `write`, `clue`, `fight`, `travel`, `puzzle`, `memory`, `chapter`, `miniboss`, `boss`, `setpiece`), comma-separated, `x2` for repeats. `python3 .docs/pacing_model.py` adds the minutes up per act and fails on: a step under 3 minutes (the Interlude is exempt), an act more than 15% off its target, play share under 55% or reading over 25%, no story piece for 10 minutes, no payoff (`miniboss`, `boss`, `setpiece`, `beat`) for 25, or more than 3 reading pieces in a row. Rows `| **Ch n** | ... |` mark chapters (3-4 per act) and are skipped by the script. A merged step has one `Completes on` for the last event; the earlier events are listed in the cell with `; then` and each sets its own flag. The Hunter memories H1-H4 are 1-minute memories counted as one `clue` piece. All minute numbers are **TUNE**. Merging thin steps cut the step count (78) below the story.md v4b target (112); the minutes, not the step count, are the target now. New `travel` and `puzzle` pieces and the minibosses named in the tables (the tank enemy of each region as an elite, **ASSUMED**) fill the longer acts. Shortcuts replace backtracking (Pacing 5): `sc:` doors open after the camp, the temple and the kampung.

**Hunts (v4).** Each legend boss is a Hunt: hook step (or beat), clue steps (`clue_examined:<id>`, grouped in an `all` step), memory step (`memory_done:<id>`), the fight, an aftermath beat. Step id pattern: `mq<n>_h<k>`. Hunts: K1 Sandekala and K2 Sangkuriang (MQ1), K-II Lengser memory with the portrait clue (MQG), K3 Bondowoso (MQ2), K4 Buto Ijo and K5 Keris (MQ3), K6 the Hunter (MQ3, memory only; the four mask fragments are clues given by the Hunter beats, one per act, flags `clue_mask_gate`, `clue_mask_rim`, `clue_mask_throne`, `clue_mask_graves`), K7 the ruwatan callback (MQ5). Person-boss clues: the Captain's toy (1.10) and Hariang Banga's letters (2.13). The lontar shimmers within 48 px of an unexamined clue ([architecture.md](architecture.md) 9b). Clue and memory steps complete at once if the flag is already set when they become current (**ASSUMED**). Memories cannot be failed hard. Step counts and minutes per act are **TUNE** ([story.md](story.md) Pacing runtime table).

**Pacing rules.** The full list is in [story.md](story.md) Pacing. The ones that shape these tables:
1. Every act runs: arrival hook (first fight within 3 minutes), Laras's trace, the regional story, the turn, petilasan and the Laras beat, the climax boss, an aftermath beat that starts the next quest. No act ends on a talk you have to walk back to. No "return to Semar" steps.
2. A talk on the main path is at most 6 lines and ends on a lead. Lore lives in the codex.
3. No more than 2 plain steps (walk, talk, collect) in a row.
4. **Every glyph is earned by a deed.** The deed step comes first (a fight, a rescue, an inscription read in place), then the glyph step. A teacher may name or show the glyph, never hand it over. The glyph lesson card ([spells.md](spells.md) 5) follows right after.

| Glyph | Deed (comes first) | Glyph step |
|-------|--------------------|------------|
| Sunda Ka | Pull Laras's lontar from the burned stage (0.6) | 0.7 Semar |
| Sunda Ga | Break the ambush at the kampung (1.2) | 1.3 the kampung elder |
| Sunda Nga | Clear the scouts, then read the defaced Batu Tulis in place | 1.7 (the read is the deed) |
| Sunda Ca | Clear the lake shore (1.10) | 1.11 Naganingrum |
| Jawa Ha | Market lead: save Ki Sumarto's show from the looters | 2.3 Ki Sumarto |
| Jawa Na | Ruins lead: the stone guardians fall | 2.3 the inscription on `arca_base` |
| Jawa Ca | Graveyard lead: clear the graveyard that kept the lesung women silent | 2.3 the lesung women |
| Jawa Ra | Break the blockade on the juru kunci's hill (2.5) | 2.5 the juru kunci |
| Jawa Ka (Ombak) | Pass the Trial of the Waves (4.12) | 4.12 the sea pavilion |

Na is no longer taught by Pak Karto. The source is an inscribed object on the Arca's base, `arca_base` (cond `flag:lead_ruins`), read in place. Pak Karto leaves the main path (he becomes a side-quest NPC, section 11).

**Story beats.** `data/dialogue/beats.tres` holds entries in the dialogue format (`if`, `lines`, `do`, optional `choices`). A listener in GameUI (`ui/story_beat.gd`) plays the first entry whose `if` holds, when no dialogue or menu is open, on `Game.changed` and after each zone load. Every beat's `if` includes `!flag:beat_<id>` and its `do` sets `flag:beat_<id>`, so it plays once. Lines may switch speaker with `@NPC_..._NAME` ([ui.md](ui.md) 3). Beats with no speaker are narration. Each act has one **Laras beat** at a petilasan: 2-3 lines, her voice from the dark. `step:<q>=<n>` is the 0-based index of the current step, so a Laras beat that follows a petilasan step reads the index of the step after it.

**Camp talks.** In Acts II and IV the travelling ally has an optional 2-4 line talk at the petilasan (Act II `galuh_1` with Ciung Wanara, Act IV `timur_2` with Hariang Banga). These are `cond`-based entries in the NPC's own dialogue file, `"quiet": true`, so they never complete a step and are never required (**ASSUMED**).

**Choices** (3 in all, [ui.md](ui.md) 3): the deserter (MQG), mercy for the caged king (MQ2), the keris (MQ3). Each sets one flag. Each changes one epilogue card and **one thing you can see in play** (**ASSUMED**, [story.md](story.md) "Choices change more than a card"):
| Choice | Flag | Visible consequence |
|--------|------|---------------------|
| 1 Deserter | `choice_freed` | He stands at the cave mouth in Act VI (beat `mouth_freed`) |
| 1 Deserter | `choice_handed` | Act III: Lengser sends word that the Deserter drew him the camp's layout (beat `lengser_word`, one line before the Mataram camp) |
| 2 Mercy | `choice_mercy` | Interlude: Ciung says the cage now has a lamp (beat `quiet_house`) |
| 2 Mercy | `choice_silent` | Interlude: Ciung says nothing and looks away (beat `quiet_house_silent`) |
| 3 Keris | `choice_reforge` | Wirasana gives you the tamed **Keris Mpu Gandring** (weapon, [items.md](items.md); `give:keris_gandring`, id **ASSUMED**) |
| 3 Keris | `choice_sink` | The river gives you the **Batu Kali** accessory (`give:batu_kali`, [items.md](items.md)) |

**Gating (v3.1).** Segara Kidul is on the main path and is **P0**. The Desa Purwa south exit to `sk_pantai` opens on `flag:mq4_i5` (v4b), which is set by the Interlude talk with Semar (step 4.5), after the doorposts, Ibu and the table, not on `mq3_8`. Flag `mq4_2` (Ibu) is kept for the quiet_house beats. The `tt_pesisir` link to `sk_karang` is a back route that opens on `quest:mq4=done` (flag `mq4_9`), so Act V always starts from Desa Purwa. `gk_mulut` opens from `sk_keraton` when `quest:mq4=done`, and the Desa Purwa to `gk_mulut` gate also opens on `quest:mq4=done`. Between Act IV and the Interlude the only open route is the one the riders carry you on (`goto`, section 7.1). Segara Kidul has 4 areas on the path: `sk_pantai`, `sk_karang`, `sk_tebing`, `sk_keraton`. There is no `sk_desa` or `sk_hutan`. Other gate flags keep their names: `mq1_10` (Desa Purwa east gate), `mq2_6` (temple stairs), `mq2_9` (Mataram east gate), `mqg_7` (road to the Pamali).

**Double bosses.** Where two bosses come back to back (I: Captain then Sangkuriang; IV: the Keris then the Hunter), the beat between them runs `restore` (health, stamina and flask charges, **ASSUMED**, [story.md](story.md) Pacing 8).

Step "Completes on" is the quest trigger; `sets` is the step's `set_flag`. Flags in tables are the existing ones unless a step says new.

### MQ0 Prologue: "Sehari di Desa Purwa" / "A Day in Desa Purwa" (Desa Purwa, 9 steps)
Story v4 (was "Malam Wayang", 8 steps). Teaches: movement and dodge (the tag game), interacting, the Kelir (first memory), class choice, the first glyph, combat basics. About 35 minutes (**TUNE**), no combat before the raid. Before the save: name entry, 2 cards (the village at dawn; "today is the ruwatan"), class choice. New Game starts MQ0 at 0.1 with `class_chosen` struck. Regional character: **Ibu**. Each step plants one thing the game needs later, shown first and named second ([story.md](story.md) Acts, Prologue). Trace: Laras's lontar on the burned stage.

**Renumbering.** Flag ids are the stable keys. The v3.1 morning-after steps keep their flags (`mq0_4`, `mq0_5`, `mq0_7`) and merged into 0.6-0.9; the day's steps have new ids `mq0_d1`-`mq0_d8`. NPC ids (`ibu`, `semar`, `ciung_wanara`, `nini_balangantrang`) are unchanged; new ids (`purwa_old_couple`, `cepot`, `purwa_stall`) are **ASSUMED**. About 39 minutes (**TUNE**, checked by the pacing model). Chapters: Morning and Market, The Ruwatan Night, The Morning After.

| # | Objective (EN) | Objective (ID) | Completes on | Play |
|---|----------------|----------------|--------------|------|
| **Ch 1** | **Pagi dan Pasar / Morning and Market** | | | |
| 0.1 | Catch Laras: she dares you to a game of tag | Tangkap Laras: dia menantangmu bermain kejar-kejaran | `area_entered:purwa_tag_end`, sets `mq0_d1` (teaches move and dodge; she calls a stray cat by its "real name" and it comes; the old banyan's leaves shiver at its name) | `setpiece` |
| 0.2 | Have tea with Ibu, then fetch Ciung and his egg from the tree | Minum teh bersama Ibu, lalu jemput Ciung dan telurnya dari pohon | `talked_to:ibu`, sets `mq0_d2` (two cups, one for each; "have Laras home before the show"; the old couple next door ask you to fetch Ciung, lead-in talk `purwa_old_couple`); then `talked_to:ciung_wanara`, sets `mq0_d3` (Laras: "Ciung isn't his whole name, you know.") | `talk, travel, talk` |
| 0.3 | Meet Semar and Cepot at the sanggar, write your names on the lontar, then ask around the market | Temui Semar dan Cepot di sanggar, tulis namamu di lontar, lalu bertanya di pasar | `talked_to:semar`, sets `mq0_d4` (aksara; a written name keeps a person in the world; Cepot pesters him, a one-line quiet talk `cepot`); `area_entered:sanggar_lontar`, sets `mq0_d5` (Laras writes her name at one end of her strip and yours at the other); then `talked_to:purwa_stall`, sets `mq0_d6` ("A tall man in a blank mask was asking children's names today. I didn't tell him.") | `talk, talk, write, travel, talk` |
| **Ch 2** | **Malam Ruwatan / The Ruwatan Night** | | | |
| 0.4 | Watch Semar's wayang ruwatan from behind the kelir | Saksikan wayang ruwatan Semar dari balik kelir | `memory_done:k0_ruwatan`, sets `mq0_d7` (K0, the first Kelir memory, a tutorial: move a figure in the lamp's light while Kala's shadow eats the unlit side; Kala, the four Seals, Sangkuriang; then the dalang reads the children's names aloud, Ciung's among them) | `memory, beat` |
| 0.5 | Find Laras in the crowd as the shadows step off the screen | Temukan Laras di tengah kerumunan saat bayangan melangkah turun dari layar | `area_entered:purwa_crowd`, sets `mq0_d8` (plays beat `raid`) | `setpiece, beat` |
| **Ch 3** | **Pagi Setelahnya / The Morning After** | | | |
| 0.6 | Ask Ibu where Laras is, then pull her lontar from the burned stage | Tanya Ibu di mana Laras berada, lalu ambil lontarnya dari panggung yang terbakar | `talked_to:ibu`, sets `mq0_4` (old 0.3; she doesn't know any Laras, yet two cups are set out; "Semar was up all night at the sanggar"); then `area_entered:wayang_stage`, sets `mq0_5` (old 0.4; the lontar is a pickup, `item_picked:laras_lontar`) | `talk, beat, clue` |
| 0.7 | Show the lontar to Semar, learn Ka and cast it three times | Tunjukkan lontar kepada Semar, pelajari Ka dan rapalkan tiga kali | `glyph_learned:sunda_ka` (old 0.5; he remembers her; Ka, "for kakak, what she called you"; his entry needs `flag:mq0_5`); then `spell_cast:sunda_ka` x3 (old 0.6) | `talk, lesson, fight x2` |
| 0.8 | Drive the faceless out of the village square | Usir para tanpa rupa dari alun-alun desa | `area_cleared:purwa_raid` (3 Faceless at the plaza), sets `mq0_7` (old 0.7) | `fight x3` |
| 0.9 | Follow the raiders to the west gate and see the Hunter | Ikuti para penyerbu ke gerbang barat dan lihat sang Pemburu | `zone_entered:ts_kebun` after the `hunter_raid` beat at the west gate | `beat, talk, travel` |

Every step has `recap = "Q_MQ0_S<n>_DONE"` (section 7.4). Name tags (first speaker only): Laras, Ibu, Ciung, Semar, Cepot, the stall-keeper ([ui.md](ui.md) 3). The calm day has no combat before the raid (0.5); it is made of tag, a walk with talks, and the Kelir show, each with play in it.

Beats:
- `raid` (if `flag:mq0_d8`; step 0.5): the raid. The shadows step off the screen: blank masks, reaching hands. They want Ciung, who is already gone into the dark. Laras looks at the tallest and whispers "Aria". He takes her: "Wrong child. A better one." The lontar tears between you. `do`: `flag:beat_raid`. Ends in the morning (card), then 0.9. The Hunter is seen here for the first time (Pacing 7).
- Turn, Laras beat, camp talk, double boss: none. The training dummies stay in the sanggar for practice (0.12) but no other step needs them.
- `hunter_raid` (if `flag:mq0_7`): the Hunter's appearance and the aftermath. The Nameless Hunter at the west gate: "Wrong child. A better one." He wanted the boy with the egg. The old woman next door (`nini_balangantrang`; display name "the old woman"): our Ciung ran west in the night, and the Faceless went the same way. The first mask fragment lies at the gate (clue `mask_gate`, set by this beat, section 7.1 `clue:` action). `do`: `flag:beat_hunter_raid`, `clue:mask_gate`, `codex:faceless`, `start:mq1`.

**Prologue clues and memory (v4).** Clue ids: `mask_gate` (given by the beat). Memory id: `k0_ruwatan`. The prologue has no Hunt, but K0 is its memory.

### MQ1 Act I: "Segel Kawah" / "The Crater Seal" (Tatar Sunda, 15 steps)
Goal: find Laras's trail, the boy the Faceless hunt, and stop the first seal. Regional character: **Dewi Naganingrum**, a mother looking for a son. Twist: the Faceless aren't hunting a thief, they hunt an heir. Story v4: two Hunts (**K1 Sandekala**, **K2 Sangkuriang**) and the Captain's toy clue add 6 steps (were 13). New flag ids `mq1_h1`-`mq1_h6`. Old flags are kept.

**Renumbering.** Flag ids are the stable keys (all v3.1 flags are kept). Merged steps list their events in order. New flag ids: `mq1_a1`, `mq1_h1`-`mq1_h7`, `mq1_lc`. About 102 minutes (**TUNE**). Chapters: Tea and the Trail, Sandekala, The Batu Tulis and the Weaver, The Lake and the Crater.

| # | Objective (EN) | Objective (ID) | Completes on | Play |
|---|----------------|----------------|--------------|------|
| **Ch 1** | **Daun Teh dan Jejak / Tea and the Trail** | | | |
| 1.1 | **Arrival.** Walk the tea terraces at dawn, meet the elder's grandson, break the ambush at the bamboo edge and find Laras's ribbon | Jalani kebun teh saat fajar, temui cucu sesepuh, patahkan penyergapan di rumpun bambu dan temukan pita Laras | `talked_to:sunda_grandson`, sets `mq1_a1` (pickers sing; the boy shows the bamboo he is learning to play, angklung, codex; the first fight comes within 5 minutes, Pacing 1); then `area_cleared:sunda_edge` | `talk, travel, fight, clue, fight` |
| 1.2 | Rest at the petilasan by the tea terraces (Cepot), then break the ambush at the kampung | Beristirahat di petilasan dekat kebun teh (Cepot), lalu patahkan penyergapan di kampung | `petilasan_activated:sunda_1`, sets `mq1_1` (Cepot is here; SQ-S4); then `area_cleared:sunda_kampung` (new id) | `travel, talk, fight, miniboss` |
| 1.3 | Ask the kampung elder about Laras, learn Ga, then follow a mother's calling to the hamlet by the gorge | Tanya sesepuh kampung tentang Laras, pelajari Ga, lalu ikuti suara seorang ibu ke dusun di tepi ngarai | `glyph_learned:sunda_ga`, sets `mq1_3` (NPC id `sunda_elder`; he saw her with "a wild boy"; the talk also sets `mq1_2`, SQ-S1/S2); then `area_entered:sunda_hamlet`, sets `mq1_h1` (dusk; she calls her son's name into the trees and nobody answers) | `talk, lesson, travel, beat` |
| **Ch 2** | **Sandekala / Sandekala** | | | |
| 1.4 | **K1 clues.** Find out what took the children: the sandal, the unlit torches, the prints | Cari tahu apa yang membawa anak-anak: sandal, obor yang padam, jejak kaki | `all`: `clue_examined:sandal`, `clue_examined:oncor`, `clue_examined:gorge_prints`; sets `mq1_h2` | `clue x3` |
| 1.5 | **K1 memory.** Follow the lontar's pull: a child at maghrib | Ikuti tarikan lontar: seorang anak saat maghrib | `memory_done:k1_maghrib`, sets `mq1_h3` (last clue `gorge_prints` has `memory_id: k1_maghrib`) | `memory` |
| 1.6 | Defeat Sandekala in the river gorge at dusk | Kalahkan Sandekala di ngarai sungai saat senja | `boss_defeated:sandekala`, sets `mq1_3b` (light the four oncor; Laras's and the boy's tracks split here) | `boss, beat` |
| **Ch 3** | **Batu Tulis dan Penenun / The Batu Tulis and the Weaver** | | | |
| 1.7 | Read the defaced Batu Tulis and learn Nga | Baca Batu Tulis yang dirusak dan pelajari Nga | `glyph_learned:sunda_nga`, sets `mq1_5` (the scouts there fall first, `area_cleared:sunda_batutulis`; a king's face scratched out; under it Laras's warning: "They need me to read") | `travel, fight x2, puzzle, lesson, beat` |
| 1.8 | Drive the faceless off the rice terraces and take the Boeh Rarang from the Weaver | Usir para tanpa rupa dari teras sawah dan terimalah Boeh Rarang dari Penenun | `area_cleared:sunda_terraces`; then `talked_to:sunda_weaver`, sets `mq1_6` | `travel, fight, miniboss, talk` |
| 1.9 | **K2 clues.** Follow the dammed river and find out why: felled trees, empty coops, the Weaver's loom | Ikuti sungai yang dibendung dan cari tahu sebabnya: pohon tumbang, kandang kosong, alat tenun | `all`: `clue_examined:felled_trees`, `clue_examined:empty_coops`, `clue_examined:loom` (already counted if examined at 1.11); sets `mq1_h4` (hook: the dammed river and the half-built boat on the lake are seen on arrival at the lake road) | `travel, puzzle, clue x3` |
| **Ch 4** | **Danau dan Kawah / The Lake and the Crater** | | | |
| 1.10 | Clear the lake shore and look at what the fallen Faceless dropped | Bersihkan tepi danau dan lihat apa yang dijatuhkan seorang Tanpa Rupa yang tumbang | `area_cleared:sunda_lakeshore`, sets `mq1_6b`; then `clue_examined:faceless_toy`, sets `mq1_h5` (Captain clue: a carved toy with a name scratched on it; the masks were people) | `travel, fight, miniboss, clue` |
| 1.11 | Speak with the woman by the lake and learn Ca, then climb the crater road to the petilasan | Bicara dengan perempuan di tepi danau dan pelajari Ca, lalu daki jalan kawah ke petilasan | `glyph_learned:sunda_ca`, sets `mq1_7` (Naganingrum; **the turn**; "the boy went up to the crater"); then `petilasan_activated:sunda_2` (the road is cleared first, `area_cleared:sunda_crater`; the Captain is seen on the road before the rim) | `talk, beat, lesson, travel, fight x2` |
| 1.12 | **LC1.** Play Laras: reading slowly at the crater | Mainkan Laras: membaca pelan-pelan di kawah | `memory_done:lc1`, sets `mq1_lc` (Laras is put before the seal-stone; read one letter at a time and, when the guard turns, slip a stone into the groove; ends with her writing *Ka*) | `chapter` |
| 1.13 | Defeat the Faceless Captain on the crater rim and take the mask fragment | Kalahkan Kapten Tanpa Rupa di bibir kawah dan ambil pecahan topeng | `boss_defeated:faceless_captain`, sets `mq1_8`; then `memory_done:h1`, sets `mq1_h7` (clue `hunter_mask_1`, `memory_id: h1`; Aria Kebonan sweeps a palace floor and King Nagawiru calls him by name; 1 minute) | `boss, beat, clue` |
| 1.14 | **K2 memory.** Follow the lontar's pull: Dayang Sumbi's night | Ikuti tarikan lontar: malam Dayang Sumbi | `memory_done:k2_dayang_sumbi`, sets `mq1_h6` (clue `boat_ribs` on the rim, `memory_id: k2_dayang_sumbi`; spread the white cloth, pound the lesung; teaches the false dawn: hang the Boeh Rarang, cast Ca) | `memory` |
| 1.15 | End the legend again: the false dawn | Akhiri legenda itu sekali lagi: fajar palsu | `boss_defeated:sangkuriang`, sets `mq1_9` | `boss, beat` |

Each step has `recap = "Q_MQ1_S<n>_DONE"`. Hunt clues are objects with a journal note each ([story.md](story.md) Hunts; section 7.4).

Beats:
- `hamlet_hook` (if `glyph:sunda_ga`, `zone:sunda_hamlet`, inside step 1.3): K1 hook. The mother calls her son's name; nobody answers; she says "Sandekala" once, as "the dusk spirit" (Pacing 10). `do`: `flag:beat_hamlet_hook`.
- `sandekala_after` (if `flag:mq1_3b`): K1 aftermath. The children are found asleep in the gorge. The mother lights her oncor again. Laras's and Ciung's tracks split: hers go up to the Batu Tulis. `do`: `flag:beat_sandekala_after`.
- Turn: the `naganingrum` talk at the lake (NPC entry, cond `flag:mq1_6b`, not a beat). She knows the boy's face without being told. She is his mother. She points to the crater.
- LC1 replaces the old `laras_1` beat (v4b): the chapter is step 1.12, after the petilasan `sunda_2`. A man with no face keeps asking her to read; she reads slowly on purpose. `do`: `flag:beat_laras_1` is set by the step's `memory_done`.
- `crater_seal` (if `flag:mq1_8`): the Hunter's appearance and the double-boss restore. The Captain, with his last strength, smashes the cracked seal-stone and **Sangkuriang** wakes (Seal 1). On the far rim the Hunter watches and leaves; the mask fragment `hunter_mask_1` lies there (step 1.13, H1). Ciung is seen chained as bait. `do`: `flag:beat_crater_seal`, `restore`.
- `naga` (if `quest:mq1=done`): the aftermath that starts MQG. Ciung Wanara and the naga-king Nagawiru are free. Nagawiru: "The man on the throne wears my face. They took the girl to Galuh." Naganingrum reaches the rim too late to be recognised: Ciung doesn't know her. The egg Ciung carried hatches. You go east together. `do`: `flag:beat_naga`, `flag:mq1_10`, `codex:nagawiru`, `codex:sangkuriang`, `lakon:sangkuriang`, `start:mqg`.

Clue ids Act I: `sandal`, `oncor`, `gorge_prints`, `felled_trees`, `empty_coops`, `loom`, `faceless_toy`, `boat_ribs`, `hunter_mask_1`. Memory ids: `k1_maghrib`, `k2_dayang_sumbi`, `lc1`, `h1`. Cepot's hint about Ga plays only after Ga is learned (section 5, SQ-S4).

### MQG Act II: "Wajah Pinjaman" / "The Borrowed Face" (Keraton Galuh, 9 steps)
Goal: get into the court and find where the taken are kept. Regional characters: **Uwa Lengser** and the **Faceless Deserter**. No new glyphs; rewards are gear and pusaka. Twist (the midpoint): the king is unmasked, and the Hunter *is* the name he gave away. Story v4: the person-boss clue (the scraped portrait) and Lengser's memory (**K-II**) add 2 steps (were 9); v4b adds the arrival slice, LC2 and H2 (9 steps after merging). Flag ids are the stable keys. New flag ids `mqg_a1`, `mqg_h1`-`mqg_h3`, `mqg_lc`. About 68 minutes (**TUNE**). Chapters: Tournament Day, The Wagon in the Yard, The Borrowed Face.

| # | Objective (EN) | Objective (ID) | Completes on | Play |
|---|----------------|----------------|--------------|------|
| **Ch 1** | **Hari Sayembara / Tournament Day** | | | |
| g.1 | **Arrival.** Join the tournament crowd, talk to the rooster seller and plan the infiltration with Ciung Wanara | Berbaur dengan kerumunan sayembara, bicara dengan penjual ayam jago dan susun rencana bersama Ciung Wanara | `talked_to:galuh_seller`, sets `mqg_a1` (no fight shown; the first fight comes within 5 minutes); then `talked_to:ciung_wanara`, sets `mqg_0` | `talk x2, travel, beat` |
| g.2 | Win both bouts of the king's tournament | Menangkan kedua babak sayembara raja | `area_cleared:galuh_bout_1`, sets `mqg_1`; then `area_cleared:galuh_bout_2`, sets `mqg_2` | `talk, fight x2, setpiece, miniboss, beat` |
| g.3 | Speak with the old chamberlain, Uwa Lengser, and enter the inner palace | Bicara dengan Uwa Lengser, abdi tua istana, dan masuki istana dalam | `talked_to:lengser`, sets `mqg_3` (opens the palace gate); then `petilasan_activated:galuh_1`, sets `mqg_4` | `talk, beat, travel, puzzle, clue` |
| **Ch 2** | **Kereta di Halaman / The Wagon in the Yard** | | | |
| g.4 | Stop the wagon in the cell yard | Hadang kereta di halaman penjara | `area_cleared:galuh_escort`, sets `mqg_4b` (the near miss: the wagon gets away east) | `setpiece, fight x2, beat` |
| g.5 | Search the cells for Laras | Geledah sel tahanan, cari Laras | `area_cleared:galuh_cells`, sets `mqg_5` (her message on the wall: "The thousand temples. Don't stop.") | `travel, fight x2, clue` |
| g.6 | **LC2.** Play Laras: under the wagon cloth | Mainkan Laras: di bawah kain kereta | `memory_done:lc2`, sets `mqg_lc` (she scratches her message into the wagon floor while the Deserter drives; she hears you fight the escort and throws the lontar strip; ends with *Ka*) | `chapter` |
| **Ch 3** | **Wajah Pinjaman / The Borrowed Face** | | | |
| g.7 | Decide the deserter's fate and look at the court portrait of the king | Putuskan nasib si pembelot dan perhatikan lukisan potret sang raja | `talked_to:faceless_deserter`, sets `mqg_6` (opens the portrait gallery and the throne room). **Choice 1:** free him (`choice_freed`) or hand him to Lengser (`choice_handed`); then `clue_examined:court_portrait`, sets `mqg_h1` (clue: the face scraped off; `memory_id: k_ii`) | `travel, talk, beat, clue` |
| g.8 | Hear Lengser's memory, then take the mask fragment by the throne | Dengarkan kenangan Lengser, lalu ambil pecahan topeng di dekat takhta | `memory_done:k_ii`, sets `mqg_h2` (K-II, 1 minute, **TUNE**; Lengser's younger self; sets up the confession); then `memory_done:h2`, sets `mqg_h3` (clue `hunter_mask_2`, `memory_id: h2`; Aria wears the king's face for the first time and no one says his name again; 1 minute) | `memory, clue, beat` |
| g.9 | Unmask the king | Buka topeng sang raja | `boss_defeated:barma_wijaya`, sets `mqg_7` (opens the road to the Pamali) | `travel, fight, boss, beat x2` |

Each step has `recap = "Q_MQG_S<n>_DONE"`. Pangrenyep is "the queen" in play; her name is in her codex entry only.

Beats:
- `galuh_bout` (if `flag:mqg_2`): the rooster won off-screen; Lengser sees the queen's eyes in Ciung Wanara. Lengser then stands by the ring (cond `flag:mqg_2`). `do`: `flag:beat_galuh_bout`, `codex:ciung_wanara`.
- `galuh_escort` (if `flag:mqg_4b`): the near miss. The wagon clears the yard gate as the last guard falls. A strip of lontar comes over the wall, *Ka* on it, and the wagon is gone east. `do`: `flag:beat_galuh_escort`.
- LC2 replaces the old `laras_2` beat (v4b): the chapter is step g.6, after the cells. Under the wagon cloth she heard you fighting in the yard; she is rocking east. `do`: `flag:beat_laras_2` is set by the step's `memory_done`.
- Camp talk (cond `flag:mqg_4`, `ciung_wanara` entry `camp_galuh`, at `galuh_1`): optional, 2-4 lines. Ciung on the throne he wants and the sister you want. `do`: `flag:camp_galuh`. The entry also needs `!flag:mqg_7` and `zone:kg_keraton`: its last line looks ahead to the unmasking, so it closes after the boss and never replays in later acts (fixed 2026-11-06).
- H2 replaces `throne_shadow` (v4b): the Hunter is seen once, a shape behind the throne, and the mask fragment `hunter_mask_2` lies there (step g.8). The beat `throne_shadow` (if `flag:mqg_h3`) keeps only his shape. `do`: `flag:beat_throne_shadow`.
- `confession` (if `flag:mqg_7`): the turn. In the throne room Barma Wijaya admits Seal 2: he scraped the old king's name to keep the face and gave Kala his own. The Hunter *is* that name. This is the only reveal; the deserter at g.8 only hints ("our master speaks with the king's voice"). `do`: `flag:beat_confession`.
- `cage` (if `flag:beat_confession`): the Hunter's appearance. Ciung cages Barma Wijaya and the queen, as in the legend. The queen has one line: "My son will come, child. What is caged is always ransomed." From the shadows behind the throne the Hunter: "The cage holds the man, not the name." `do`: `flag:beat_cage`, `codex:barma_wijaya`, `codex:pangrenyep`.
- `escape` (if `quest:mqg=done`, `flag:beat_cage`): the aftermath that starts MQ2. Prince Hariang Banga escapes east to raise an army and free his mother; he turns on Ciung only now, over the cage. Ciung stays to hold Galuh. You go on alone. `do`: `flag:beat_escape`, `start:mq2`.

Clue ids Act II: `court_portrait`, `hunter_mask_2`. Memory ids: `k_ii`, `lc2`, `h2`.

Sensitivity: the rooster fights off-screen only. The hero never bets or handles it ([story_ciung_wanara.md](story_ciung_wanara.md) 5).

### MQ2 Act III: "Darah di Pamali" / "Blood on the Pamali" (Mataram, 13 steps)
Goal: stop the war that feeds Kala. Regional character: **Ki Sumarto**, a dalang who performs for both banks because his son marches with Hariang Banga. This is the three-leads act. Step 2.2 is a new step kind, `all` (section 7.1): three triggers that complete in any order, each one struck through in the journal as it fires. Story v4: the **K3 Bondowoso Hunt** (2 steps) and the Hariang Banga letters clue (1 step) add 3 steps (were 13); v4b adds the arrival slice (the two recruiters, who's who), H3, LC3 and K-III (13 steps after merging).

**Renumbering.** Flag ids are the stable keys (v3.1 flags are kept). v4 added the K3 clues and memory and the letters; v4b added the arrival slice, H3, LC3 and K-III. New flag ids: `mq2_a1`, `mq2_h1`-`mq2_h5`, `mq2_lc`. About 109 minutes (**TUNE**). Chapters: The Two-Bank Market, The Thousand Temples, The Pamali River.

| # | Objective (EN) | Objective (ID) | Completes on | Play |
|---|----------------|----------------|--------------|------|
| **Ch 1** | **Pasar Dua Tepi / The Two-Bank Market** | | | |
| 2.1 | **Arrival.** Hear both recruiters at the river market, break the ambush at the border gate and rest at the petilasan | Dengarkan kedua perekrut di pasar sungai, patahkan penyergapan di gerbang perbatasan dan beristirahat di petilasan | `all`: `talked_to:recruiter_a`, `talked_to:recruiter_b`; sets `mq2_a1` (the same story of the war told the other way round; who's who); then `area_cleared:mataram_gerbang` (beat `haulers` follows: the K3 hook); then `petilasan_activated:mataram_1`, sets `mq2_1` | `talk x2, travel, fight x2, beat` |
| 2.2 | Follow the three leads on Laras: the market, the ruins, the graveyard | Telusuri tiga petunjuk tentang Laras: pasar, reruntuhan, dan kuburan | `all` (any order): `area_cleared:mataram_pasar` (sets `lead_pasar`, new), `area_cleared:mataram_ruins` (sets `lead_ruins`, new), `area_cleared:mataram_kuburan` (sets `lead_kuburan`, new). The step sets `mq2_4` (new) when all three are struck | `travel, setpiece, talk, travel, clue, miniboss, travel, fight x2, beat` |
| 2.3 | Learn Ha from Ki Sumarto, read Na off the Arca's base and learn Ca from the lesung women | Pelajari Ha dari Ki Sumarto, baca Na dari dasar Arca dan pelajari Ca dari para perempuan di lesung | `all`: `glyph_learned:jawa_ha` (sets `mq2_2`), `glyph_learned:jawa_na` (sets `mq2_3`), `glyph_learned:jawa_ca` (sets `mq2_5`); each completes at once if already known | `talk, lesson, puzzle, lesson, talk, lesson` |
| 2.4 | **H3.** Take the mask fragment in the graveyard and see the price | Ambil pecahan topeng di kuburan dan lihat harganya | `memory_done:h3`, sets `mq2_h4` (clue `hunter_mask_3`, cond `flag:lead_kuburan`, `memory_id: h3`; alone at night Aria gives his own name to Kala to keep the borrowed face; 1 minute) | `clue, beat, miniboss` |
| **Ch 2** | **Candi Seribu / The Thousand Temples** | | | |
| 2.5 | Break the blockade on the foothill and receive the juru kunci's blessing and Ra | Hancurkan blokade di kaki bukit dan terimalah restu juru kunci dan Ra | `area_cleared:mataram_batu`; then `glyph_learned:jawa_ra`, sets `mq2_6` (NPC id `juru_kunci`; opens the temple stairs) | `travel, talk, fight x2, puzzle, talk, lesson` |
| 2.6 | Fight through the temple gate and storm the Faceless camp at Candi Seribu | Tembus gerbang candi dan serbu perkemahan tanpa rupa di Candi Seribu | `area_cleared:mataram_candi`; then `area_cleared:mataram_camp`, sets `mq2_7` (**the turn**; the Pamali stone wakes) | `travel, fight, talk, fight, miniboss, setpiece, beat` |
| 2.7 | **K3 clues.** Examine the chisel-marked rubble, the abandoned lesung and Laras's strip | Periksa puing berbekas pahat, lesung yang ditinggalkan, dan helai lontar Laras | `all`: `clue_examined:rubble`, `clue_examined:lesung_mid`, `clue_examined:ka_strip`; sets `mq2_h1` (`ka_strip` has `memory_id: k3_lesung`) | `clue x3` |
| 2.8 | **K3 memory.** Follow the lontar's pull: the princess's women | Ikuti tarikan lontar: para dayang sang putri | `memory_done:k3_lesung`, sets `mq2_h2` (keep the rice-pounding beat, 3 short bars; teaches the Jawa Ca beat) | `memory` |
| 2.9 | **LC3.** Play Laras: the reading room | Mainkan Laras: ruang baca | `memory_done:lc3`, sets `mq2_lc` (at Candi Seribu she is told the prisoners will be hurt if she does not read; she reads; ends with *Ka*) | `chapter` |
| 2.10 | End Bandung Bondowoso's night | Akhiri malam Bandung Bondowoso | `boss_defeated:bandung_bondowoso`, sets `mq2_7b` (Seal 3; the lesung rhythm and Jawa Ca) | `boss, beat` |
| **Ch 3** | **Sungai Pamali / The Pamali River** | | | |
| 2.11 | Cross to the Pamali stone and write Nagawiru's true name on it | Seberangi ke batu Pamali dan tuliskan nama sejati Nagawiru di atasnya | `name_written:nagawiru`, sets `mq2_8` (Hariang Banga's camp stands at the ford) | `travel x2, fight x2, write, beat` |
| 2.12 | **K-III.** Watch Ki Sumarto's show: the brothers who split the land | Saksikan pertunjukan Ki Sumarto: dua saudara yang membelah tanah | `memory_done:k_iii`, sets `mq2_h5` (you play the younger brother crossing back; teaches *pamali*: brothers don't fight; sets up the ford and Choice 2) | `memory, beat` |
| 2.13 | Read Hariang Banga's letters to his mother, then duel him at the ford | Baca surat-surat Hariang Banga untuk ibunya, lalu berduel dengannya di tepi penyeberangan | `clue_examined:hariang_letters`, sets `mq2_h3` (Person-boss clue; he comes to the ford after); then `boss_defeated:hariang_banga`, sets `mq2_9` (opens the east gate) | `clue, beat, boss, beat` |

Glyph rewards come from the deeds inside the leads. A glyph's source opens as soon as its lead is cleared, so the player can learn it on the spot. Each source is gated on its lead flag, not on the step number: Ki Sumarto on `lead_pasar`, `arca_base` on `lead_ruins`, the lesung women on `lead_kuburan` (script.md conditions the three entries the same way). Step 2.3 merges the three glyphs (Ha, Na, Ca, an `all` step) and acts as a reminder: a `glyph_learned:` trigger completes at once if the glyph is already known when it becomes current (like `item_picked:`, section 7.1), otherwise the arrow points at the source. In play each glyph is learned right after its lead fight, so the player never walks three plain steps in a row (Pacing 5). The same rule holds for `clue_examined:` and `memory_done:` (section 7.1).

Each step has `recap = "Q_MQ2_S<n>_DONE"`.

Beats:
- `haulers` (if `step:mq2=0`, `zone:mt_gerbang`, after the gate ambush is cleared): K3 hook. Villagers haul stone in the night; temples stand where yesterday there was a field. `do`: `flag:beat_haulers`.
- `hunter_war` (if `flag:lead_kuburan`): the Hunter's appearance, at the graves, where his servants harvest the fallen. The Hunter: "Two armies make twice the forgetting." The mask fragment `hunter_mask_3` lies there (step 2.4, H3). `do`: `flag:beat_hunter_war`.
- `lengser_word` (if `flag:choice_handed`, `flag:mq2_6`): one line, Lengser's word that the Deserter drew him the camp's layout. `do`: `flag:beat_lengser_word`.
- `camp` (if `flag:mq2_7`): the turn. The camp is not a prison, it is a reading room. Seal 3 is broken and **Bandung Bondowoso** wakes. The strip torn from Laras's half, covered with *Ka* written again and again, is now a clue object (`ka_strip`, step 2.11): she is gone east. `do`: `flag:beat_camp`.
- LC3 replaces the old `laras_3` beat (v4b): the chapter is step 2.9, after the K3 memory and before the Bondowoso fight. She read the seal because they hurt the prisoners when she didn't. `do`: `flag:beat_laras_3` is set by the step's `memory_done`.
- The Pamali stone (`pamali_stone`, cond `flag:mq2_7`) runs `write:nagawiru:jawa_na,sunda_ga`: one letter from each script.
- `ford` (if `flag:mq2_h3`): Hariang Banga wades into the ford alone. You helped cage his mother, so it is a duel, not a battle. `do`: `flag:beat_ford`.
- `truce` (if `quest:mq2=done`): the aftermath that starts MQ3. Hariang Banga yields. Nagawiru's voice from the water, Ciung Wanara on the far bank: fighting your brother is *pamali*. The land splits at the river. Ki Sumarto's son (Sapto, **ASSUMED**) wades back across the ford. **Choice 2:** ask Ciung Wanara to show the caged king mercy (`choice_mercy`) or say nothing (`choice_silent`). `do`: `flag:beat_truce`, `codex:pamali`, `codex:roro_jonggrang`, `lakon:roro_jonggrang`, `start:mq3`.

Clue ids Act III: `rubble`, `lesung_mid`, `ka_strip`, `hariang_letters`, `hunter_mask_3`. Memory ids: `k3_lesung`, `lc3`, `h3`, `k_iii`. K-III is triggered by Ki Sumarto at the ford camp (clue `sumarto_show`, `memory_id: k_iii`, cond `flag:mq2_8`); the `ford` beat then waits for the letters (`flag:mq2_h3`).

Path: after 2.10 the `sc:mt_candi_gapura` shortcut brings the player back to `mt_gapura`, one area from `kg_pamali`. Pak Karto stays at `mt_reruntuhan` as a side-quest NPC.

### MQ3 Act IV: "Bilah Tujuh Turunan" / "The Seven-Generation Blade" (Tanah Timur, 11 steps)
Goal: follow the Hunter to the last seal. Regional character: **Mpu Wirasana**. Ally: **Hariang Banga**. No new glyphs; you learn to break curse marks (a technique). Twist: you see Laras, and the Eclipse takes her. Story v4: **K4 Buto Ijo** (2 new steps, hook is 3.5), **K5 Keris** (hook step plus clues plus memory, 3 new) and **K6 Hunter memory** (1 new) add 6 steps (were 11); v4b adds the arrival slice, LC4 and H4 (11 steps after merging).

**Renumbering.** Flag ids are the stable keys (v3.1 flags are kept). v4 added K4, K5 and K6 steps; v4b added the arrival slice, LC4 and H4. New flag ids: `mq3_a1`, `mq3_h1`-`mq3_h7`, `mq3_lc`. About 98 minutes (**TUNE**). Chapters: The Smiths' Road, Timun Mas, Sand and Shrine, The Nameless One.

| # | Objective (EN) | Objective (ID) | Completes on | Play |
|---|----------------|----------------|--------------|------|
| **Ch 1** | **Jalan Para Empu / The Smiths' Road** | | | |
| 3.1 | **Arrival.** Walk the smiths' street, break the ambush at the eastern border and rest at the savanna petilasan | Jalani jalan para pandai besi, patahkan penyergapan di perbatasan timur dan beristirahat di petilasan sabana | `talked_to:timur_daughter`, sets `mq3_a1` (Wirasana's daughter; codex: pamor; the curse marks follow); then `area_cleared:timur_gerbang`; then `petilasan_activated:timur_1`, sets `mq3_1` | `talk, travel, fight, clue, travel, fight` |
| 3.2 | Follow the red curse marks to Mpu Wirasana's forge and learn to break them | Ikuti tanda kutukan merah ke bengkel Mpu Wirasana dan belajar mematahkannya | `area_entered:timur_marks`, sets `mq3_h1`; then `talked_to:timur_empu`, sets `mq3_2` | `travel, beat, talk, lesson, puzzle` |
| **Ch 2** | **Timun Mas / Timun Mas** | | | |
| 3.3 | Help the widow whose hut was smashed, and examine the seeds, needle case, salt jar and terasi pot | Bantu janda yang pondoknya hancur, dan periksa biji timun, tempat jarum, toples garam dan terasi | `talked_to:mbok_srini`, sets `mq3_3` (NPC id kept, display name "the widow"; the four pouches; the river wisps fall first, `area_cleared:timur_wisps`); then `all`: `clue_examined:seeds`, `clue_examined:needle_case`, `clue_examined:salt_terasi`; sets `mq3_h2` (`salt_terasi` has `memory_id: k4_timun_mas`) | `travel, beat, clue x3` |
| 3.4 | **K4 memory.** Follow the lontar's pull: Timun Mas | Ikuti tarikan lontar: Timun Mas | `memory_done:k4_timun_mas`, sets `mq3_h3` (throw each pouch as he closes in; teaches luring him through the pouch fields) | `memory` |
| 3.5 | Defeat Buto Ijo | Kalahkan Buto Ijo | `boss_defeated:buto_ijo`, sets `mq3_4` (cursed mad by the keris) | `boss, beat` |
| 3.6 | Break two practice curse marks, then examine the broken scabbard and the forge records | Patahkan dua tanda kutukan latihan, lalu periksa sarung keris yang patah dan catatan tempa | `area_entered:timur_praktik_mark` x2 (also sets `flag:clue_practice_marks`, the third K5 clue); then `all`: `clue_examined:scabbard`, `clue_examined:forge_records`; sets `mq3_h4` | `puzzle x2, clue x2` |
| **Ch 3** | **Pasir dan Candi / Sand and Shrine** | | | |
| 3.7 | Follow the Hunter's ash trail down the coast and cross the Sea of Sand | Ikuti jejak abu Si Tanpa Ngaran menyusuri pesisir dan seberangi Lautan Pasir | `area_cleared:timur_pesisir`; then `area_cleared:timur_pasir` | `travel, fight x2, clue, travel, fight, miniboss, beat, puzzle` |
| 3.8 | Rest at the desert petilasan, then play Laras on the desert road | Beristirahat di petilasan gurun, lalu mainkan Laras di jalan gurun | `petilasan_activated:timur_2`, sets `mq3_6`; then `memory_done:lc4`, sets `mq3_lc` (on the desert road she tries to draw your face in the sand and can't; she remembers only the tag game and *kakak*; you keep *Ka* written as the sand wipes it) | `talk, chapter` |
| 3.9 | Reach the shrine, see the old forge, and lay the cursed keris to rest | Capai kuil, lihat bengkel tua, dan tenangkan keris terkutuk | `memory_done:k5_forge`, sets `mq3_h5` (clue `forge_stone` at the desert shrine, `memory_id: k5_forge`; douse the curse marks; teaches putting out the curse marks); then `boss_defeated:keris_gandring`, sets `mq3_7` (Seal 4) | `travel, beat, memory, boss, beat` |
| **Ch 4** | **Si Tanpa Ngaran / The Nameless One** | | | |
| 3.10 | Take the last mask fragment, join the mask and see the servant | Ambil pecahan topeng terakhir, satukan topeng dan lihat sang abdi | `memory_done:h4`, sets `mq3_h7` (clue `hunter_mask_4`, cond `flag:beat_keris`, `memory_id: h4`; the prologue raid from Aria's eyes: a small girl says his name, the first time in fifteen years; 1 minute); then `memory_done:k6_servant`, sets `mq3_h6` (the four fragments join into a mask, clue `mask_joined` at the shrine door, cond `flag:mq3_h7`, `memory_id: k6_servant`; 2 minutes, walking only, no mechanic) | `clue, memory, beat` |
| 3.11 | Face the Nameless Hunter | Hadapi Si Tanpa Ngaran | `boss_defeated:nameless_hunter`, sets `mq3_8` | `boss, setpiece, beat` |

Each step has `recap = "Q_MQ3_S<n>_DONE"`. Mask fragments: the prologue one (`mask_gate`) is given by the `hunter_raid` beat; the four after it are clue objects (`hunter_mask_1` to `hunter_mask_4`), each its own step (H1-H4) with a 1-minute Hunter memory (`h1`-`h4`), one per act I-IV. K6 comes last and the joined mask (`mask_joined`) pulls you into it.

Beats:
- `marks_hook` (if `step:mq3=1`, on entering `timur_marks`): K5 hook, the curse marks on the doorposts. `do`: `flag:beat_marks_hook`.
- `widow_hook` (K4 hook): her hut is smashed open, footprints as long as you are tall. Part of the widow's talk (step 3.3), not a beat.
- LC4 replaces the old `laras_4` beat (v4b): the chapter is step 3.8, after the petilasan `timur_2`. She can't remember your face; only one letter is left on her half, *Ka*. `do`: `flag:beat_laras_4` is set by the step's `memory_done`.
- Camp talk (cond `flag:mq3_6`, `zone:tt_pasir`, `hariang_banga` entry `camp_timur`, at `timur_2`): optional, 2-4 lines. Hariang Banga shows you the road east. `do`: `flag:camp_timur`. The zone cond keeps it from replaying at the Interlude table and the Gua Kala mouth (fixed 2026-11-06).
- `shrine_sight` (if `flag:mq3_h5`, `flag:mq3_lc`, `zone:tt_candi`): the turn. You see Laras across the shrine, made to read the last seal. The **Keris Mpu Gandring** wakes (Seal 4). The keris boss cond is `flag:beat_shrine_sight`. `do`: `flag:beat_shrine_sight`. (The old cond `flag:mq3_6` becomes `flag:mq3_h5` so the memory comes first.)
- `keris` (if `flag:mq3_7`): the keris lies quiet. **Choice 3:** take it to the empu to reforge (`choice_reforge`, `give:keris_gandring`) or give it to the river (`choice_sink`, `give:batu_kali`). `do`: `flag:beat_keris`.
- `hunter_shrine` (if `flag:mq3_h6`): the Hunter's appearance (the duel) and the double-boss restore. He steps out of the shrine's shadow (his boss cond is `flag:mq3_h6`; was `flag:beat_keris`). It is a separate beat because no lines can follow a choice. `do`: `flag:beat_hunter_shrine`, `restore`.
- `hunter_name` (if `quest:mq3=done`): the false victory and the aftermath that starts MQ4. His mask cracks; under it, the young face the king wore. You carve *Aria Kebonan* back onto it. In Galuh, the caged man gets his old face back. The bundle at his belt opens and the held names fly home ([story.md](story.md) Two kinds of forgetting). Then the Eclipse begins and takes Laras first. The Hunter, emptied: "She's gone where I was going." Hariang Banga's riders carry you home. `do`: `flag:beat_hunter_name`, `codex:nameless_hunter`, `start:mq4`, `goto:desa_purwa:from_riders` (spawn placed in desa_purwa.md, **ASSUMED**).

Clue ids Act IV: `seeds`, `needle_case`, `salt_terasi`, `scabbard`, `forge_records`, `forge_stone`, `hunter_mask_4`, `mask_joined` (and flag `clue_practice_marks`). Memory ids: `k4_timun_mas`, `k5_forge`, `k6_servant`, `lc4`, `h4`.

### MQ4 Interlude and Act V: "Rumah yang Sunyi" and "Laut Tak Pernah Lupa" (Desa Purwa, then Segara Kidul, 12 steps)
Steps 4.1-4.5 are the Interlude, "The Quiet House" (v4b): about 25 minutes, no combat, the low point, exempt from the 3-minute step rule. Steps 4.6-4.12 are Act V, "The Sea Does Not Forget" (about 64 minutes, **TUNE**; v4b added K8, K9 and LC5). Regional character: **Mbah Wiryo**. The journal shows the Act V title for the whole quest (**ASSUMED**). Nyi Roro Kidul speaks once, from a distance. She is never fought or touched, and she is neither friend nor enemy. Areas: `sk_pantai`, `sk_karang`, `sk_tebing`, `sk_keraton`. Flag ids are the stable keys: old `mq4_2` (Ibu), `mq4_4`, `mq4_8`, `mq4_9` are kept; new: `mq4_i1`, `mq4_i3`, `mq4_i5` (Interlude), `mq4_h1`-`mq4_h3`, `mq4_lc` (Act V). The Aria Kebonan talk is an optional NPC entry, not a step.

| # | Objective (EN) | Objective (ID) | Completes on | Play |
|---|----------------|----------------|--------------|------|
| **Ch 1** | **Rumah yang Sunyi / The Quiet House** | | | |
| 4.1 | Go home to Desa Purwa under the Eclipse | Pulanglah ke Desa Purwa di bawah Gerhana | `zone_entered:desa_purwa` (the riders' `goto` lands you there) | `travel` |
| 4.2 | Write each family's name on their doorpost | Tuliskan nama setiap keluarga di tiang pintu mereka | `all`: `name_written:door_a`, `name_written:door_b`, `name_written:door_c` (three houses, three write cards through the existing `write:` action; sets `mq4_i1`) | `travel, write x3` |
| 4.3 | Bring Ibu three of Laras's things: the ribbon, the wagon-board message and the Ka strip | Bawakan Ibu tiga benda milik Laras: pita, pesan papan kereta, dan helai Ka | `talked_to:ibu`, sets `mq4_2` (entry needs `item:laras_ribbon,item:laras_board,item:laras_strip_ka`; she sets the second cup straight; the old exit gate moves to `mq4_i5`) | `clue x3, talk x2, beat x2` |
| 4.4 | Sit at your mother's table with the two brothers | Duduk di meja ibumu bersama kedua saudara raja | `area_entered:purwa_table`, sets `mq4_i3` (a short playable dinner: pass dishes, choose who to sit beside; plays beat `quiet_house`) | `setpiece, beat` |
| 4.5 | Talk to Semar about the sea, and (optional) hear Aria Kebonan by the burned stage | Bicara dengan Semar tentang laut, dan (opsional) dengarkan Aria Kebonan di dekat panggung terbakar | `talked_to:semar`, sets `mq4_i5` (why Semar remembers; "the sea does not forget"; opens the south exit to `sk_pantai`). The Aria talk is an optional `quiet` NPC entry (`aria_kebonan`, **ASSUMED**), never a step | `beat x2, talk x2` |
| **Ch 2** | **Kampung Nelayan / The Fishing Village** | | | |
| 4.6 | **Arrival.** Rest at the black-sand petilasan, see the village mend its nets and speak with Mbah Wiryo | Beristirahat di petilasan pantai pasir hitam, lihat desa menambal jala, dan bicara dengan Mbah Wiryo | `petilasan_activated:kidul_1`; then `talked_to:kidul_jurukunci`, sets `mq4_4` (respect for the coast; the green belief, told as belief) | `talk x2, travel, fight x2` |
| 4.7 | **K8 clues.** Find the three forgotten verses of the sea song with three families | Temukan tiga bait lagu laut yang terlupa pada tiga keluarga | `all`: `clue_examined:song_1`, `clue_examined:song_2`, `clue_examined:song_3`; sets `mq4_h1` (`song_3` has `memory_id: k8_wiryo_wife`) | `travel, clue x3` |
| 4.8 | **K8 memory.** Follow the lontar's pull: Mbah Wiryo's wife on the shore | Ikuti tarikan lontar: istri Mbah Wiryo di pantai | `memory_done:k8_wiryo_wife`, sets `mq4_h2` (you play her teaching him to call a name to the water; no death shown; teaches calling a name to the sea) | `memory, beat` |
| **Ch 3** | **Karang dan Tebing / Reef and Cliff** | | | |
| 4.9 | Cross the reef | Seberangi karang | `area_cleared:kidul_karang_2` | `travel, fight, clue, puzzle, fight, miniboss, beat` |
| 4.10 | Climb the cliff path, rest at the cliff shrine and hear the queen of the south as one retelling (K9) | Daki jalan setapak tebing, beristirahat di kuil tebing dan dengarkan ratu selatan sebagai satu penceritaan (K9) | `area_cleared:kidul_tebing_2`; then `petilasan_activated:kidul_3` (new petilasan in `sk_tebing`); then `memory_done:k9_queen_south`, sets `mq4_h3` (K9, Ki Sumarto's version, told as belief, no fight) | `travel, fight x2, memory, beat` |
| 4.11 | **LC5.** Play Laras: the voice on the water | Mainkan Laras: suara di atas air | `memory_done:lc5`, sets `mq4_lc` (in Kala's dark she follows a voice that says her name; the sea still says it; ends with *Ka*) | `chapter` |
| **Ch 4** | **Ujian Ombak / The Trial of the Waves** | | | |
| 4.12 | Pass the Trial of the Waves and receive Ombak and the Kain Hijau | Jalani Ujian Ombak dan terimalah Ombak dan Kain Hijau | `area_cleared:kidul_trial`, sets `mq4_8` (three waves, each with its own glyph answer, [bestiary.md](bestiary.md) Zone 4); then `glyph_learned:jawa_ka`, sets `mq4_9` (the Sea Altar `kidul_altar` runs `write:ombak:jawa_ka`, `learn:jawa_ka` and `give:kain_hijau` at `step:mq4=8`; Ombak / Tide, + Kain Hijau, [spells.md](spells.md) 3). The act ends here | `setpiece, clue, setpiece, clue, setpiece, beat, lesson` |

Beats:
- Interlude: the Hunter's appearance is his empty mask in the fire. Turn, camp talk and double boss: none.
- `quiet_house` (if `flag:mq4_i3`, `flag:choice_mercy`): the brothers' table (step 4.4). Ciung Wanara and Hariang Banga meet for the first time as brothers, at your mother's table. The Hunter's empty mask lies in the fire. Ciung: the cage now has a lamp. `do`: `flag:beat_quiet_house`. (Semar's "The sea does not forget. Go south." moves to step 4.5.)
- `quiet_house_silent` (if `flag:mq4_i3`, `flag:choice_silent`): the same scene. Ciung says nothing about the cage and looks away. `do`: `flag:beat_quiet_house`.
- LC5 replaces the old `laras_kidul` beat (v4b): the chapter is step 4.11, after the K9 memory at the cliff shrine and before the Trial. She can hear the sea, and the sea still says her name. `do`: `flag:beat_laras_kidul` is set by the step's `memory_done`.
- Clue ids Interlude and Act V: `song_1`, `song_2`, `song_3`; items `laras_ribbon`, `laras_board`, `laras_strip_ka`; write seq ids `door_a`, `door_b`, `door_c`. Memory ids: `k8_wiryo_wife`, `k9_queen_south`, `lc5`.
- `kidul_trial` (if `flag:mq4_8`): the turn of the act. Nyi Roro Kidul speaks once, from a distance. `do`: `flag:beat_kidul_trial`.
- `kidul` (if `quest:mq4=done`): the aftermath that starts MQ5. Semar: Ombak is the one letter the Eclipse can't eat. It opens the cave from the sea pavilion and breaks Kala's eclipse shield (the sea remembering is a game invention). `do`: `flag:beat_kidul`, `start:mq5`.

### MQ5 Act VI: "Ke Rahang Sang Waktu" / "Into the Maw of Time" (Gua Kala, 9 steps)
Requires `mq4_9`. The Hunter does not appear in this act (his empty mask was the Interlude). Story v4b: the three letters of her name (`La`, `Ra`, `Sa`) are held in three memories of the prologue day (tag, the two cups, the written names); the player replays each and fills the gaps Kala ate by picking the right detail (cannot be failed; a wrong pick shows a grey gap). Then K10 (Murwakala), LC6, the K7 ruwatan callback, Kala and the name. Hook set in the prologue show (K0). About 67 minutes (**TUNE**); chapters: The Cave Mouth, The Abyss of Forgetting, The Maw of Time. Flag ids kept: `mq5_1`, `mq5_1b`, `mq5_1c`, `mq5_1d`, `mq5_2`, `mq5_3`, `mq5_4`; new: `mq5_h1` (K7), `mq5_h2` (K10), `mq5_lc` (LC6), memory ids `la`, `ra`, `sa`, `k10_murwakala`, `lc6`, `k7_ruwatan`.

| # | Objective (EN) | Objective (ID) | Completes on | Play |
|---|----------------|----------------|--------------|------|
| **Ch 1** | **Mulut Gua / The Cave Mouth** | | | |
| 5.1 | Enter Gua Kala and reclaim La in the memory of the tag game | Masuki Gua Kala dan rebut La dalam kenangan permainan kejar-kejaran | `zone_entered:gk_mulut`, sets `mq5_1`; `area_cleared:kala_mulut`, sets `mq5_1b`; then `memory_done:la` (the prologue tag game with grey gaps: what did she call the cat?) | `travel, fight x2, beat, memory` |
| 5.2 | Shatter the western and eastern time-wards on the Hourglass Sands | Hancurkan penangkal waktu barat dan timur di Pasir Jam Pasir | `area_cleared:kala_pasir_1`; then `area_cleared:kala_pasir_2`, sets `mq5_1c` | `travel, fight, clue, puzzle, fight, puzzle, beat` |
| **Ch 2** | **Jurang Lupa / The Abyss of Forgetting** | | | |
| 5.3 | Cross the Abyss of Forgetting and reclaim Ra in the memory of the two cups | Seberangi Jurang Lupa dan rebut Ra dalam kenangan dua cangkir teh | `area_cleared:kala_lupa`, sets `mq5_1d`; then `memory_done:ra` (which cup was hers?) | `travel, miniboss, fight, memory` |
| 5.4 | Rest at the last petilasan and reclaim Sa in the memory of the written names | Beristirahat di petilasan terakhir dan rebut Sa dalam kenangan nama-nama yang ditulis | `petilasan_activated:kala_1`, sets `mq5_2`; then `memory_done:sa` (Laras writing your names on the lontar; Semar waits here) | `talk, memory, beat` |
| **Ch 3** | **Rahang Sang Waktu / The Maw of Time** | | | |
| 5.5 | **K10.** Hear Semar's tale of Murwakala: why the ruwatan turns Kala back | Dengarkan kisah Murwakala dari Semar: mengapa ruwatan membalikkan Kala | `memory_done:k10_murwakala`, sets `mq5_h2` (clue `semar_tale` at `kala_1`; **VERIFY** the Murwakala lakon) | `memory, beat` |
| 5.6 | **LC6.** Play Laras: who's there? | Mainkan Laras: siapa di sana? | `memory_done:lc6`, sets `mq5_lc` (at the bottom of the dark, forgetting you, still writing *Ka*; you hear your own voice reply) | `chapter` |
| 5.7 | **K7 memory.** Read the names aloud at Semar's kelir | Bacakan nama-nama di kelir Semar | `memory_done:k7_ruwatan`, sets `mq5_h1` (clue `semar_kelir` at `kala_1`, `memory_id: k7_ruwatan`; the prologue show again, but you are the dalang; allow_cast on; teaches that the Ruwatan of Dawn alternates Sunda and Jawa letters) | `clue, memory` |
| 5.8 | Calm Batara Kala | Tenangkan Batara Kala | `boss_defeated:batara_kala`, sets `mq5_3` | `boss, setpiece, beat` |
| 5.9 | Write Laras's name | Tuliskan nama Laras | `name_written:laras`, sets `mq5_4` (then the epilogue and credits) | `setpiece, beat` |

Beats:
- `mouth_freed` (if `flag:mq5_1`, `flag:choice_freed`): the two brothers at the cave mouth, one from each bank, with the Deserter beside them. You go in alone. `do`: `flag:beat_mouth`.
- `mouth` (if `flag:mq5_1`): the same, without the Deserter. `do`: `flag:beat_mouth`. (`mouth_freed` is listed first.)
- LC6 replaces the old `laras_5` beat (v4b): the chapter is step 5.6, after K10. "Who's there?" She has forgotten you and is still writing *Ka*; you hear your own voice reply. `do`: `flag:beat_laras_5` is set by the step's `memory_done`.
Each step has `recap = "Q_MQ5_S<n>_DONE"`. Clue id: `semar_kelir`. Memory id: `k7_ruwatan`.

- `write` (if `flag:mq5_3`): Kala turns back into the dark, calmed in the Ruwatan of Dawn. Your half of the lontar is blank. Semar: "Then write it." `do`: `flag:beat_write`; a second, line-less entry (if `!flag:mq5_4`, `flag:beat_write`) runs `write:laras:sunda_la,sunda_ra,sunda_sa`, so a quit mid-card reopens the card. The name-writing card ([ui.md](ui.md) 3) ends with `name_written:laras`.

Epilogue (v4b, about 10 minutes, a short playable day of beats, not quest steps): Laras wakes you, dares you to tag, Ibu pours two cups; you walk the village while the ruwatan stage is built. Present by choice and journey: the elder's grandson with his angklung, Uwa Lengser, Ki Sumarto and his son, Wirasana's daughter, Mbah Wiryo, and the Deserter if freed (`choice_freed`); the three choice cards each also change who is there. Semar tells your story on the kelir and the credits roll over it. The cards below still frame it. Epilogue: 7 cards. 1 Laras comes home and nobody thinks she ever left. 2 Ciung Wanara rules the west, Hariang Banga the east. 3-5 one card per choice (`EPILOGUE_n` or `EPILOGUE_n_ALT` when `choice_handed`, `choice_silent`, `choice_sink` is set). 6 the village wayang plays your story, Semar telling it. 7 your name and hers, the credit line with the codex %. After it the player wakes in Desa Purwa (`from_gua_kala`). Naganingrum is called back to court by her son, and Nagawiru sleeps in the lake (card 2).

Batara Kala is calmed and turned back, never killed. The ruwatan codex note from [story.md](story.md) applies.

**Post-game (ASSUMED):** every zone stays open, so unfinished side quests can still be done (never missable).

## 5. Side quests
Card format: type, size, giver, unlock, steps, resolution, reward, culture and **VERIFY** notes. IDs: `SQ-<zone letter><n>`.

### Tatar Sunda
Theme (names): carried by SQ-S1, where a prince lives under a borrowed face, the lutung, until someone sees him. Naganingrum's story is on the main path ([story.md](story.md)).

**SQ-S1 "Lutung Kasarung"** (re-telling, M)
- Giver: a juru pantun (singer of Sundanese pantun epics, **VERIFY** the role), at the village. Unlock: MQ1 step 1.3.
- Steps: (1) find the black lutung (langur) spirit in the forest, (2) clear the spirits from the hidden spring, (3) bring Purbasari to the spring. The bath cures her skin, as in the legend.
- Reward: **Iket Sunda**, lakon "Lutung Kasarung", Ilmu M.
- Culture: Purbasari, her sister Purbararang, and the lutung who is really Guruminda, a heavenly being. He is an ally. **VERIFY** the cure and the names.

**SQ-S2 "Kuntilanak Rumpun Bambu" / "The Bamboo-Grove Kuntilanak"** (bounty, L)
- Giver: the kepala desa (village head). Unlock: MQ1 step 1.3.
- Steps: (1) hear the reports, (2) find the elite kuntilanak in the bamboo grove at night (a marked arena), (3) defeat her, (4) report back.
- Reward: **Golok**, **Herb Pouch #1**, Ilmu L.
- Culture: label her as pan-Indonesian folklore. Cartoonish, no gore. Which tree she is tied to varies (**VERIFY**: bamboo, waru or another).

**SQ-S3 "Angklung yang Tercerai" / "The Scattered Angklung"** (errand, M)
- Giver: the leader of a village angklung group. Unlock: entering Tatar Sunda.
- Steps: (1) find 5 angklung scattered across the zone (each plays one note when picked up), (2) return them. The group plays a short piece with all 5 notes.
- Reward: **Flask Shard #1**, Ilmu M.
- Culture: each angklung sounds one note, so a tune needs every player. That is the point of the quest and the codex entry. Angklung is UNESCO 2010 (verified). **VERIFY** the traditional scale (pentatonic salendro/pelog vs the later diatonic angklung).

**SQ-S4 "Cepot Si Pemberani" / "Brave Cepot"** (errand, S, first-hour path)
- Giver: Cepot. Unlock: MQ1 step 1.2, so the quest system shows up early. Cepot is first met in the prologue (MQ0 0.3, sanggar, a quiet talk). v4: his hint about Ga (what the glyph counters) must only play when `glyph:sunda_ga` holds. He is at the petilasan before Ga is learned (1.2 comes before 1.4), so the hint is a second entry in his file with cond `glyph:sunda_ga`; the first meeting only starts the quest. **ASSUMED**.
- Steps: (1) Cepot wants to prove he is brave and asks you to defeat 3 Wild Boar (was Maung, dropped with the tiger spirit, **ASSUMED** 2026-11-05) while he "supervises" from a tree, commenting on each kill, (2) report back.
- Reward: **Silver Bangle**, Ilmu S.
- Culture: Cepot's humor as in wayang golek. Barks are one-liners in both languages.

**SQ-S5 (retired in v3.1).** Sangkuriang is fought on the main path (MQ1 1.15), so the echo is cut. Its lakon "Sangkuriang" and codex `sangkuriang` are given when MQ1 completes. Dayang Sumbi keeps an idle talk at the lake after MQ1 (cond `quest:mq1=done`). Code follow-up: remove `data/quests/sq_s5.tres` and Sangkuriang's `quest:sq_s5=active` cond.

### Mataram
Theme (forgetting): carried by SQ-M2, where a neglected child is lost because no one looked for it. Ki Sumarto's story is on the main path.

**SQ-M1 "Jaka Tarub dan Nawang Wulan" / "Jaka Tarub and Nawang Wulan"** (re-telling, M)
- Giver: Nawang Wulan, a quiet woman in a rice-farming household. Unlock: MQ2 step 2.1.
- Steps: (1) she says her rice pot's magic broke after someone lifted the lid, (2) search the lumbung (rice barn), (3) find her selendang (shawl) hidden under the last of the rice, (4) return it.
- Resolution: she returns to the sky, as in the legend, and leaves her weaving scarf behind as thanks.
- Reward: **Feather Charm**, **Herb Pouch #2**, lakon "Jaka Tarub", Ilmu M.
- Culture: one grain of rice filled the pot while the lid stayed closed. Jaka Tarub hid the shawl. Their daughter Nawangsih. Nawang Wulan is a bidadari (celestial maiden), not a deity, and shown with respect. **VERIFY** all beats and the legend's location.

**SQ-M2 "Wewe Gombel"** (bounty, two-way, L). Wewe Gombel moved to Mataram (decided 2026-11-05).
- Giver: a worried neighbor. Unlock: MQ2 step 2.3.
- Steps: (1) a neglected child has gone missing, (2) find the hill where Wewe Gombel hides children.
- Resolution:
  - **Peaceful:** go back and talk to the parents. They come to the hill and call the child kindly (and bang pots, as in the folk practice, **VERIFY**). Wewe Gombel returns the child, since in folklore she takes children who are neglected, not to harm them.
  - **Fight:** defeat the elite Wewe Gombel and bring the child home.
- Reward: **Jimat**, Ilmu L (fight +50%). Peaceful adds the codex entry "Wewe Gombel's lesson".
- Culture: the legend is a warning about neglect. The peaceful ending tells that story best.

**SQ-M3 "Tuyul di Pasar" / "A Tuyul at the Market"** (bounty, two-way, M)
- Giver: a pande besi (blacksmith) with a market stall. Unlock: MQ2 step 2.1.
- Steps: (1) coins vanish from the stalls, (2) find the tuyul swarm's hideout.
- Resolution:
  - **Peaceful:** set out the folk distraction (**VERIFY**: crabs, or green beans the tuyul must count) and catch the leader while it plays.
  - **Fight:** defeat the elite tuyul leader and its swarm.
- Reward: **Spear**, Ilmu M (fight +50%).
- Culture: described only as a mischievous money-stealing child spirit. Light comedy.

**SQ-M4 "Gamelan yang Bisu" / "The Silent Gamelan"** (errand, M)
- Giver: Ki Dalang, the MQ2 teacher. Unlock: MQ2 step 2.3.
- Steps: (1) the village gamelan's gong ageng was carried off into the temple ruins, (2) fight through the Arca to find it, (3) bring it back. The zone music gains its gong layer from then on (a cheap audio-state change, strong payoff).
- Reward: **Blangkon**, Ilmu M.
- Culture: the gong ageng marks the end of the musical cycle (**VERIFY** wording). Gamelan is UNESCO 2021 (verified).

**SQ-M5 (retired in v3.1).** Bandung Bondowoso is fought on the main path (MQ2 2.10), so the echo is cut. Its lakon "Roro Jonggrang" and codex `roro_jonggrang` are given when MQ2 completes. Code follow-up: remove `data/quests/sq_m5.tres` and Bondowoso's `quest:sq_m5=active` cond.

### Tanah Timur
Theme (names): carried by SQ-T1, where a hero hides behind a borrowed name.

**SQ-T1 "Ande-Ande Lumut"** (re-telling, two-way, M)
- Giver: Klething Kuning at the riverbank. Unlock: MQ3 step 3.1.
- Steps: (1) she must cross the river to reach Ande-Ande Lumut, but Yuyu Kangkang, a giant crab, demands a payment from everyone who crosses.
- Resolution:
  - **Peaceful (the legend's way):** fetch the sodo lanang (a stick from a palm-leaf broom) she was given, and she strikes the river with it. The water dries up (**VERIFY** who gave it and what it does).
  - **Fight:** defeat Yuyu Kangkang (an elite charger).
- Reward: **Stone Ring**, lakon "Ande-Ande Lumut", Ilmu M (fight +50%).
- Culture: a Panji tale. Ande-Ande Lumut is Panji in disguise. Child-friendly retelling: the crab demands "a payment", not a kiss.

**SQ-T2 "Banaspati Padang Sabana" / "The Savanna Banaspati"** (bounty, L)
- Giver: a herder. Unlock: MQ3 step 3.1.
- Steps: (1) the grassland keeps catching fire, (2) follow the burn trail to the elite Banaspati, (3) defeat it.
- Reward: **Herb Pouch #3**, Ilmu L.
- Culture: fire spirit. Do not tie it to the Tengger or Bromo rituals.

**SQ-T3 "Pamor dari Langit" / "Pamor from the Sky"** (errand, cross-zone, M)
- Giver: the empu. Unlock: MQ3 step 3.2.
- Steps: (1) the empu needs a batu bintang (meteorite) to forge a keris with pamor (the patterned metal layers), (2) travel back to Mataram, where a fragment lies near the temple plain, (3) bring it back.
- Reward: **Keris Luk 7**, Ilmu M.
- Culture: the Prambanan meteorite is known for keris pamor (**VERIFY**). This is a quest reward, not a crafting system. Keris is UNESCO 2008 (verified). It teaches backtracking on the open map.

**SQ-T4 "Kuda Kepang yang Hilang" / "The Lost Kuda Kepang"** (errand, S)
- Giver: the leader of a kuda lumping troupe. Unlock: MQ3 step 3.1.
- Steps: (1) find 3 kuda kepang (woven bamboo horses) blown away in a storm, (2) return them and watch a short performance.
- Reward: **Flask Shard #2**, Ilmu S.
- Culture: performance only. No trance, no glass-eating, no fire (rule from [world.md](world.md)).

### Segara Kidul
The main path here is P0 (section 4). These side quests are P1. Theme (the sea remembers, **ASSUMED**): carried by SQ-K1, where hatchlings find their own way back.

**SQ-K1 "Tukik Pulang ke Laut" / "Hatchlings Home to the Sea"** (errand, S)
- Giver: a fisher's child. Steps: (1) pick up 3 stranded turtle hatchlings in the dunes (`item_picked:tukik_*` x3), (2) carry them to the surf (`area_entered:kidul_tukik_laut`), (3) tell the child. Synced 2026-11-06 to the built quest and the sk_pantai map (3 pickups); the escort version with crabs and birds is dropped, since bestiary.md has no such enemies.
- Reward: **Herb Pouch #4**, Ilmu S.
- Culture: Java's south coast has real turtle nesting beaches (**VERIFY**: e.g. Pangumbahan, Sukamade). A conservation note in the codex.

**SQ-K2 sea spirit bounty** (bounty, L). Target: Bajul Putih Tua, an old white crocodile elite ([bestiary.md](bestiary.md) Zone 4). Reward: **Cakra** if the thrown archetype is built, otherwise Ilmu L x2.

## 6. Hub meta quests (Desa Purwa)
These grow with the content, so they reward the whole game without new systems.

### 6.1 SQ-D1 "Lakon" (the wayang stage)
- Giver: the Desa Purwa dalang who performs the prologue. Unlock: MQ0.
- Every finished re-telling (S1, M1, T1) and every main-quest legend (Sangkuriang, Roro Jonggrang, Ciung Wanara, Timun Mas, Ken Arok) adds a lakon. 8 in total, plus the hero's own story at the end (v3.1).
- At the stage, the player can watch any unlocked lakon: about 30 seconds of silhouette slides with narration text in P0, animated wayang in P2.
- Thresholds: 4 lakon gives **Flask Shard #3**. All 7 adds a line to the credits.

### 6.2 SQ-D2 "Pustaka" (the codex keeper)
- Giver: a keeper of old manuscripts in Desa Purwa. Unlock: first codex entry.
- Thresholds on codex completion (**TUNE**): 25% Ilmu M, 50% **Lontar Kuno**, 75% Ilmu L, 100% a credits line and the keeper's farewell.
- The codex percentage counts only content reachable in the current build (P0 or P1), so 100% is always possible.

## 7. Quest system (technical)
Fits [architecture.md](architecture.md): data-driven resources, quest state in the `Game` autoload, signals through `Events`. **No new autoload.**

### 7.1 Data
`QuestData` (Resource, one `.tres` per quest in `data/quests/`):
| Field | Example |
|-------|---------|
| `id` | `sq_m2` |
| `kind` | `main` / `side` |
| `type` | `main` / `retelling` / `bounty` / `errand` / `meta` |
| `zone` | `mataram` |
| `size` | `S` / `M` / `L` (sets Ilmu) |
| `giver` | `npc_id` |
| `requires` | flags that must be set to unlock, e.g. `["mq2_2"]` |
| `steps` | `Array[QuestStep]` |
| `rewards` | `{items: [...], flask_shard: 0, herb_pouch: 0, lakon: "", flags: []}` |

`QuestStep`:
| Field | Example |
|-------|---------|
| `objective` | translation key, e.g. `Q_SQ_M2_S1` |
| `on` | event string, e.g. `"enemy_killed:wild_boar"` (`<signal>:<arg>`; the arg is the enemy `kind`, npc id, item id, etc.). A bare `<signal>` matches any arg; a trailing `*` is a prefix (`item_picked:angklung_*`). An `item_picked:` step counts matching items already held when it becomes current, so early pickups never soft-lock it. `give:` fires `item_picked`. |
| `count` | `3` |
| `alt` | for two-way steps: `{"enemy_killed:wewe_elite": "fight", "talked_to:wewe_parents_2": "peaceful"}`. Any key completes the step and stores `resolution`; `fight` gives +50% quest Ilmu. Built 2026-11-05 |
| `marker` | `{zone: "mt_alas", id: "wewe_hill"}`: `zone` is the area id where the node sits ([world.md](world.md) World structure); `QuestData.zone` stays the region id |
| `set_flag` | `mq2_2` |
| `all` | Built 2026-11-06 (bits saved in the quest record, `all`). For a step that has several triggers: `[{on: "area_cleared:mataram_pasar", set_flag: "lead_pasar"}, ...]`. Each trigger completes on its own, in any order, and stores its own bit in the quest state. The step completes (and sets its own `set_flag`) when all are done. `on` is empty on such a step. The journal strikes each trigger through as it fires (each needs a text key, e.g. `Q_MQ2_S3_A`). Used for the three leads in MQ2 step 2.2 and for every Hunt's clue set (e.g. MQ1 1.4; each clue's trigger is `clue_examined:<id>`) |
| `recap` | v4 (**ASSUMED**, [architecture.md](architecture.md) 9b). Optional text key for the journal's "Story so far", one or two lines in the past tense. Every main-quest step has one: `Q_<QUEST>_S<n>_DONE`, e.g. `Q_MQ1_S7_DONE`. Side quests may omit it |

Built 2026-11-06: a `glyph_learned:` step (or `all` trigger) completes at once if that glyph is already known when the step becomes current (same rule as `item_picked:`), so MQ2 2.3 never block a player who took the glyph early. v4 (**ASSUMED**): a `clue_examined:<id>` trigger completes at once if `flag:clue_<id>` is set, and a `memory_done:<id>` step if `flag:memory_<id>` is set, for the same reason.

Dialogue (`DialogueData`, one `.tres` per NPC in `data/dialogue/`, **ASSUMED** 2026-11-05): `npc_id`, `name_key`, `entries: Array[Dictionary]`, each `{"if": [conditions], "lines": [keys], "do": [actions]}`. The first entry whose conditions all hold plays; an entry with no `if` is the fallback and goes last.
- Conditions: `quest:<id>=<locked|available|active|done>`, `step:<id>=<n>` (0-based current step), `flag:<f>`, `!flag:<f>`, `glyph:<id>`, `item:<id>` (held), `clue:<id>` is not a condition (use `flag:clue_<id>`; v4), and comma lists (all of). `zone:<area_id>` (the player is in that area, built 2026-11-06); the Act IV `shrine_sight` beat uses it.
- An entry with `"quiet": true` does not fire `talked_to` (a refusal that must not complete a talk step).
- Actions run when the box closes, in order: `start:<quest>`, `give:<item>`, `learn:<glyph>`, `flag:<f>`, `codex:<id>`, `write:<seq_id>:<glyph>,<glyph>`, `clue:<id>` (v4, **ASSUMED**: sets `flag:clue_<id>`, adds the journal note, emits `clue_examined`; used by the Hunter beats that leave a mask fragment). Then `talked_to:<npc_id>` fires.
- Built 2026-11-06: `goto:<area>:<spawn>` moves the player to that area and spawn after the box closes (Act IV aftermath: Hariang Banga's riders carry you home, `goto:desa_purwa:from_riders`); it fires `zone_entered`. `restore` refills health, stamina and flask charges (double-boss beats, **ASSUMED**); it does not save or reset the sakti gauge. `lakon:<id>` sets the same flag a quest's lakon reward sets.
- `Game.check(cond)` and `Game.run(action)` hold the logic, so the NPC script only walks the list.

`CodexEntry` (`data/codex/<id>.tres`): `id`, `category` (`enemy` / `legend` / `item` / `aksara`), `source`. Text keys `CODEX_<ID>_TITLE`, `_BODY`, `_WEAK` (enemies only). Unlocks on the first kill of that enemy `kind`, an item pick, a glyph learned, or a `codex:` action. A weakness trigger sets flag `weak:<kind>`, which shows the `_WEAK` line.

### 7.2 Events
Quests listen to signals that `Events` already plans plus a few more: `talked_to(npc_id)`, `item_picked(item_id)`, `enemy_killed(enemy_id)`, `boss_defeated(boss_id)`, `area_cleared(area_id)`, `area_entered(trigger_id)`, `zone_entered(zone_id)`, `petilasan_activated(id)`, `glyph_learned(glyph_id)`, `spell_cast(glyph_id, score)`, `class_chosen(class_id)`, `trial_completed(id)`, and (v4, **ASSUMED**, [architecture.md](architecture.md) 9b) `clue_examined(clue_id)` and `memory_done(memory_id)`. Plus outgoing: `quest_started`, `quest_updated`, `quest_completed`.

- `clue_examined:<id>`: emitted by a clue Interactable (`Clue`) when its lines finish. Also sets `flag:clue_<id>` and adds a journal note (`CLUE_<ID>_NOTE`). Examining again re-plays the lines and emits nothing new.
- `memory_done:<id>`: emitted when a Kelir memory scene ends (`memory.gd` `finish()`). Also sets `flag:memory_<id>`. Ids: `k0_ruwatan`, `k1_maghrib`, `k2_dayang_sumbi`, `k_ii`, `k3_lesung`, `k4_timun_mas`, `k5_forge`, `k6_servant`, `k7_ruwatan`. A step on `memory_done` is the only way a Hunt's memory counts; a quit mid-memory resumes at the clue.

### 7.3 State (in `Game`)
- `quests: {id: {state, step, count, resolution}}`, state in `locked / available / active / done`.
- `flags: {}`, already planned for story flags.
- On any event, `Game` checks only the current step of each `active` quest, so it is cheap.
- Saved with the rest of `Game` in the autosave ([rpg.md](rpg.md) 11). Every quest start, step and completion triggers a save.

### 7.4 Journal ("Catatan" / "Journal")
- A tab in the Tab menu with 3 lists: Main, Side, Done.
- Each quest: title, giver, zone, current objective, earlier steps struck through, reward preview (key reward only).
- **Story so far** (v4, **ASSUMED**): a page in the Main list. For each finished main step it shows that step's `recap` line (key `Q_<QUEST>_S<n>_DONE`, 1-2 lines, past tense), grouped by act, newest last. A returning player reads it to catch up; it is the only place the whole plot is told in order. Hidden steps (not yet reached) are not shown.
- **Clues** (v4): a list under the quest, one line per examined clue (`CLUE_<ID>_NOTE`), grouped by Hunt, read from `flag:clue_*`. Unexamined clues of a Hunt show as "?" once its hook step is struck, so the player knows how many remain (**TUNE**).
- The player can pin one side quest. Pinning moves the arrow to it, and unpinning moves it back to the main quest.

### 7.5 Marker (soft arrow)
- A small arrow at the screen edge pointing at the pinned or main objective. It hides when the target is on screen.
- Target in another zone: the arrow points to the exit toward that zone. `Zones` already knows the adjacency, so a breadth-first search over all areas (about 30) is enough.
- Errand collectibles sparkle when within one screen while their quest is active, instead of each getting a marker.
- Settings: the arrow can be turned off.

### 7.6 NPC indicators and toasts
- Icon above an NPC: quest available (gold), in progress (grey), ready to turn in (gold, gently bobbing). The icon is a small lontar leaf (**ASSUMED**) instead of a generic "!".
- Toast at the top center on start, update and completion, with a short gamelan-style chime.

### 7.7 Dialogue and language
- Each NPC's dialogue is a list of entries with a condition on quest state or flags. The first matching entry plays. So an NPC naturally changes lines before, during and after its quest.
- All text is keys in CSV string tables (`data/text/quests.csv`, `dialogue.csv`, `codex.csv`) with `keys,id,en` columns. Godot imports CSV as translations natively and `tr()` looks them up. The language is chosen at first launch and changeable in settings.
- This replaces the `text_id` / `text_en` field pairs in `CodexEntry` and `ItemData` with one key each (update [architecture.md](architecture.md) and [items.md](items.md)).
- The pixel font must cover Indonesian Latin text plus é (used in Sundanese terms such as rarangkén and pamaéh).

### 7.8 Testing
- A headless check (same style as the recognizer test) that loads every `QuestData` and asserts: every `requires` flag is set by some step, every `marker` names an existing zone, every key exists in both `id` and `en` columns, and every item in `rewards` exists. This catches broken quest chains without playing. v4: the test must accept the events `clue_examined:<id>` and `memory_done:<id>`, check that each `clue_examined` id has a Clue spot in its zone or a `clue:` action, and that each `memory_done` id has a `zones/kelir/<id>.tscn`; it must also check every main step has a `recap` key in both languages.

## 8. First-hour path
Story v4/v4c (2026-11-06; minutes **TUNE**, from the pacing model). Name entry -> 2 cards (the village at dawn; "today is the ruwatan") -> class -> **a calm day** (about 39 minutes): tag with Laras (0.1, move and dodge; she calls a cat by its "real name") -> tea with Ibu, two cups, and Ciung with his egg (0.2) -> the sanggar: Semar, Cepot, the names written on the lontar, then the market warning (0.3) -> Semar's ruwatan, the first Kelir memory (0.4) -> the raid, Laras taken and the lontar torn (0.5) -> Ibu does not remember her, yet two cups are set out; the lontar from the burned stage (0.6) -> Semar, Ka, cast Ka (0.7) -> the faceless in the square (0.8) -> the Hunter at the west gate ("Wrong child. A better one."), west (0.9) -> MQ1 1.1-1.3 (about 22 minutes: the tea terraces, ribbon, the petilasan and Cepot's SQ-S4, the kampung ambush and Ga, the mother calling at the gorge). By the end of the first hour the player knows who they are looking for, who took her, what the Hunter wants, what Kala and the Seals are, has played one Kelir memory and has entered the first Hunt (Sandekala follows in 1.4-1.6, a further 13 minutes), with a side quest, two glyphs each earned by a deed, a codex entry and the journal's "Story so far". No name is spoken before it is shown (Pacing 10).

## 9. Scope
| Tier | Content |
|------|---------|
| P0 | Quest system (sections 7.1-7.7) with the new `all` step, the `goto` and `restore` actions and the `zone:` condition; the whole main quest, MQ0, MQ1, MQG, MQ2, MQ3, **MQ4 (Interlude and the Segara Kidul main path, v3.1)** and MQ5, bilingual text for all of it, SQ-S4 (first-hour path) |
| P1 | All other side quests in Sunda, Mataram, Timur (11), hub meta quests, the Segara Kidul side quests (SQ-K1, SQ-K2), the headless quest check |
| P2 | Animated lakon performances, bonus glyphs from side quests, SQ-K2 Cakra reward |

Writing budget, rough: main quest about 120 dialogue lines before v3.1 (the Interlude, camp talks and choice variants add more; [script.md](script.md) has the real count), each side quest 15-30, so about 450 lines per language (**TUNE**).

## 10. VERIFY list for this file
Lutung Kasarung (cure at the spring, Guruminda, juru pantun role), kuntilanak's tree, angklung scale, Jaka Tarub (rice pot, lumbung, Nawangsih, location), Wewe Gombel folk practice of banging pots and returning children, tuyul distractions, gong ageng role, Ande-Ande Lumut (Yuyu Kangkang, sodo lanang, Panji link), Prambanan meteorite and pamor, turtle beaches, Roro Jonggrang's fake dawn (rice pounding, burning straw). Verified 2026-11-05: gejog lesung, Timun Mas (hermit, four pouches, Mbok Srini).

## 11. Open decisions and doc changes this implies
1. ~~Wewe Gombel to Mataram~~: decided yes (2026-11-05). Tatar Sunda's tank is Jurig Leuweung, a descriptive name kept on purpose ([bestiary.md](bestiary.md)).
2. **Sangkuriang's light glyph:** reuse Ca (Burst), no extra glyph (**ASSUMED** here).
3. **NPC names** (decided 2026-11-05, **ASSUMED**). Ordinary given names with the usual address: Abah (Sundanese elder), Ki (respected man, performers), Pak and Mbah (Javanese village), Mpu (smith), Nyai. **VERIFY** with a native speaker, and search each name so none matches a living dalang or juru kunci.

| Role | Name | Where |
|------|------|-------|
| Village elder (sesepuh) | the kampung elder (was Abah Karna; `sunda_elder`) | Tatar Sunda, MQ1 1.3 |
| Juru pantun | Ki Darsa | Tatar Sunda, SQ-S1 |
| Dalang | Ki Sumarto | Mataram, MQ2 2.4 and regional character |
| Stone-carver (pemahat batu) | Pak Karto | Mataram, `mt_reruntuhan`. Off the main path since v3.1 (Na is read off `arca_base`); a side-quest NPC (no quest assigned yet) |
| Ki Sumarto's son | Sapto | Keraton Galuh, `kg_pamali`, MQ2 aftermath (`truce`), **ASSUMED** |
| Juru kunci | the juru kunci (was Mbah Marto; `juru_kunci`) | Mataram, MQ2 2.5 |
| Empu | Mpu Wirasana | Tanah Timur, MQ3 3.2 |
| Widow of Timun Mas | the widow (was Mbok Srini; `mbok_srini`) | Tanah Timur, MQ3 3.3 |
| The old couple | the old couple (was Aki and Nini Balangantrang; id `nini_balangantrang`) | Desa Purwa, MQ0 0.2 and `hunter_raid` |
| The queen | the queen (was Dewi Pangrenyep; codex `pangrenyep`) | Keraton Galuh, MQG `cage` |
| Semar's son | Cepot | Desa Purwa, MQ0 0.4; SQ-S4 at MQ1 1.2 |
| Wayang stage dalang | Semar (Ki Wangsa cut in v4, ASSUMED) | Desa Purwa, MQ0 0.3 and 0.4 |
| Codex keeper | Nyai Rukmi | Desa Purwa, SQ-D2 |
| Juru kunci of the coast | Mbah Wiryo | Segara Kidul, MQ4 4.6 |

Cast cuts (v4): the table lists display names; the ids, files and codex entries keep the old names where noted. Zone docs that place `G` (Ki Wangsa) in `desa_purwa.md` need a follow-up (not done here).
4. Docs to sync: [scope.md](scope.md) (bilingual moves from P2 to P0, side quests are 3-4 per zone), [story.md](story.md) (side quest section now points here), [items.md](items.md) (add Lontar Kuno, Flask Shard, Herb Pouch; Golok and Spear sources), [architecture.md](architecture.md) (translation keys, `QuestData`, `data/quests/`, `data/text/`), [rpg.md](rpg.md) (flask max 6 charges, heal up to 60%).
