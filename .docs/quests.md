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
Story v3.1 (user call 2026-11-06, [story.md](story.md) is the canon): the hunt for Laras. A Prologue, six acts and an Interlude, 71 steps, about 7 hours (**TUNE**). Quest ids stay as stable keys (`mq0`, `mq1`, `mqg`, `mq2`, `mq3`, `mq4`, `mq5`); the journal shows the act title. Old gate flag names are kept where they still fit. The arrow always points at the current step. Glyphs are learned only here. Each teacher speaks one hint about the enemy that glyph counters ([bestiary.md](bestiary.md) Glyph weaknesses). Every line of text is in [script.md](script.md). Act titles in Indonesian are **ASSUMED**.

| Quest | Part | Steps | Region |
|-------|------|-------|--------|
| MQ0 | Prologue "Malam Wayang" | 8 | Desa Purwa |
| MQ1 | Act I "Segel Kawah" | 13 | Tatar Sunda |
| MQG | Act II "Wajah Pinjaman" | 9 | Keraton Galuh |
| MQ2 | Act III "Darah di Pamali" | 13 | Mataram |
| MQ3 | Act IV "Bilah Tujuh Turunan" | 11 | Tanah Timur |
| MQ4 | Interlude "Rumah yang Sunyi" (4.1-4.2) and Act V "Laut Tak Pernah Lupa" (4.3-4.9) | 9 | Desa Purwa, Segara Kidul |
| MQ5 | Act VI "Ke Rahang Sang Waktu" | 8 | Gua Kala |

**Pacing rules.** The full list is in [story.md](story.md) Pacing. The ones that shape these tables:
1. Every act runs: arrival hook (first fight within 3 minutes), Laras's trace, the regional story, the turn, petilasan and the Laras beat, the climax boss, an aftermath beat that starts the next quest. No act ends on a talk you have to walk back to. No "return to Semar" steps.
2. A talk on the main path is at most 6 lines and ends on a lead. Lore lives in the codex.
3. No more than 2 plain steps (walk, talk, collect) in a row.
4. **Every glyph is earned by a deed.** The deed step comes first (a fight, a rescue, an inscription read in place), then the glyph step. A teacher may name or show the glyph, never hand it over. The glyph lesson card ([spells.md](spells.md) 5) follows right after.

| Glyph | Deed (comes first) | Glyph step |
|-------|--------------------|------------|
| Sunda Ka | Pull Laras's lontar from the burned stage (0.4) | 0.5 Semar |
| Sunda Ga | Break the ambush at Abah Karna's kampung (1.3) | 1.4 Abah Karna |
| Sunda Nga | Clear the scouts, then read the defaced Batu Tulis in place | 1.6 (the read is the deed) |
| Sunda Ca | Clear the lake shore (1.9) | 1.10 Naganingrum |
| Jawa Ha | Market lead: save Ki Sumarto's show from the looters | 2.4 Ki Sumarto |
| Jawa Na | Ruins lead: the stone guardians fall | 2.5 the inscription on `arca_base` |
| Jawa Ca | Graveyard lead: clear the graveyard that kept the lesung women silent | 2.6 the lesung women |
| Jawa Ra | Break the blockade on Mbah Marto's hill (2.7) | 2.8 Mbah Marto |
| Jawa Ka (Ombak) | Pass the Trial of the Waves (4.8) | 4.9 the sea pavilion |

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

**Gating (v3.1).** Segara Kidul is on the main path and is **P0**. The Desa Purwa south exit to `sk_pantai` opens on `flag:mq4_2`, which is set by the Interlude talk with Ibu (step 4.2), not on `mq3_8`. The `tt_pesisir` link to `sk_karang` is a back route that opens on `quest:mq4=done` (flag `mq4_9`), so Act V always starts from Desa Purwa. `gk_mulut` opens from `sk_keraton` when `quest:mq4=done`, and the Desa Purwa to `gk_mulut` gate also opens on `quest:mq4=done`. Between Act IV and the Interlude the only open route is the one the riders carry you on (`goto`, section 7.1). Segara Kidul has 4 areas on the path: `sk_pantai`, `sk_karang`, `sk_tebing`, `sk_keraton`. There is no `sk_desa` or `sk_hutan`. Other gate flags keep their names: `mq1_10` (Desa Purwa east gate), `mq2_6` (temple stairs), `mq2_9` (Mataram east gate), `mqg_7` (road to the Pamali).

**Double bosses.** Where two bosses come back to back (I: Captain then Sangkuriang; IV: the Keris then the Hunter), the beat between them runs `restore` (health, stamina and flask charges, **ASSUMED**, [story.md](story.md) Pacing 8).

Step "Completes on" is the quest trigger; `sets` is the step's `set_flag`. Flags in tables are the existing ones unless a step says new.

### MQ0 Prologue: "Malam Wayang" / "The Night of the Wayang" (Desa Purwa, 8 steps)
Teaches: movement, interacting, class choice, the first glyph, combat basics. Before the save: name entry, the prologue (5 cards: the show and the names read aloud, Laras with her lontar, the faceless step out of the screen, she is taken and the lontar tears, morning), class choice. New Game starts MQ0 at 0.3 with 0.1-0.2 struck. Regional character: **Ibu**. Trace: Laras's lontar on the burned stage.

| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| 0.1 | Watch the wayang show and survive the night | Saksikan pertunjukan wayang dan bertahanlah malam itu | struck (prologue) |
| 0.2 | Choose your path | Pilih jalanmu | struck (`class_chosen`) |
| 0.3 | Ask Ibu where Laras is | Tanya Ibu di mana Laras berada | `talked_to:ibu`, sets `mq0_4` (she doesn't know any Laras, yet two cups are set out; "Semar was up all night at the sanggar") |
| 0.4 | Pull Laras's lontar from the burned stage | Ambil lontar Laras dari panggung wayang yang terbakar | `area_entered:wayang_stage`, sets `mq0_5` (new; the lontar is a pickup, `item_picked:laras_lontar`) |
| 0.5 | Show the lontar to Semar and learn Ka | Tunjukkan lontar itu kepada Semar dan pelajari Ka | `glyph_learned:sunda_ka` (he remembers her; Ka, "for kakak, what she called you"; his entry needs `flag:mq0_5`) |
| 0.6 | Cast Ka three times | Rapalkan Ka tiga kali | `spell_cast:sunda_ka` x3 |
| 0.7 | Drive the faceless out of the village square | Usir para tanpa rupa dari alun-alun desa | `area_cleared:purwa_raid` (3 Faceless at the plaza), sets `mq0_7` |
| 0.8 | Follow the raiders west | Ikuti jejak para penyerbu ke barat | `zone_entered:ts_kebun` |

Beats:
- Turn, Laras beat, camp talk, double boss: none. The prologue cards show Laras. The training dummies stay in the sanggar for practice but no step needs them.
- `hunter_raid` (if `flag:mq0_7`): the Hunter's appearance and the aftermath. The Nameless Hunter at the west gate: "Wrong child. A better one." He wanted the boy with the egg. Nini Balangantrang: our Ciung ran west in the night, and the Faceless went the same way. `do`: `flag:beat_hunter_raid`, `codex:faceless`, `start:mq1`.

### MQ1 Act I: "Segel Kawah" / "The Crater Seal" (Tatar Sunda, 13 steps)
Goal: find Laras's trail, the boy the Faceless hunt, and stop the first seal. Regional character: **Dewi Naganingrum**, a mother looking for a son. Twist: the Faceless aren't hunting a thief, they hunt an heir.

| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| 1.1 | Break the ambush at the bamboo edge and find Laras's ribbon | Patahkan penyergapan di tepi rumpun bambu dan temukan pita Laras | `area_cleared:sunda_edge` |
| 1.2 | Rest at the petilasan by the tea terraces | Beristirahat di petilasan dekat kebun teh | `petilasan_activated:sunda_1`, sets `mq1_1` (Cepot is here; SQ-S4) |
| 1.3 | Break the ambush at Abah Karna's kampung | Patahkan penyergapan di kampung Abah Karna | `area_cleared:sunda_kampung` (new id) |
| 1.4 | Ask Abah Karna about Laras and learn Ga | Tanya Abah Karna tentang Laras dan pelajari Ga | `glyph_learned:sunda_ga`, sets `mq1_3` (he saw her with "a wild boy"; the talk also sets `mq1_2`, SQ-S1/S2) |
| 1.5 | Defeat Sandekala in the river gorge at dusk | Kalahkan Sandekala di ngarai sungai saat senja | `boss_defeated:sandekala`, sets `mq1_3b` (Laras's and the boy's tracks split here) |
| 1.6 | Read the defaced Batu Tulis and learn Nga | Baca Batu Tulis yang dirusak dan pelajari Nga | `glyph_learned:sunda_nga`, sets `mq1_5` (the scouts there fall first, `area_cleared:sunda_batutulis`; a king's face scratched out; under it Laras's warning: "They need me to read") |
| 1.7 | Drive the faceless off the rice terraces | Usir para tanpa rupa dari teras sawah | `area_cleared:sunda_terraces` |
| 1.8 | Find the Weaver who hid Laras and take the Boeh Rarang | Temui Penenun yang menyembunyikan Laras dan terimalah Boeh Rarang | `talked_to:sunda_weaver`, sets `mq1_6` |
| 1.9 | Clear the lake shore | Bersihkan tepi danau | `area_cleared:sunda_lakeshore` (new id), sets `mq1_6b` (new) |
| 1.10 | Speak with the woman by the lake and learn Ca | Bicara dengan perempuan di tepi danau dan pelajari Ca | `glyph_learned:sunda_ca`, sets `mq1_7` (Naganingrum; **the turn**; "the boy went up to the crater") |
| 1.11 | Rest at the petilasan on the crater road | Beristirahat di petilasan jalan kawah | `petilasan_activated:sunda_2` (the road is cleared first, `area_cleared:sunda_crater`) |
| 1.12 | Defeat the Faceless Captain on the crater rim | Kalahkan Kapten Tanpa Rupa di bibir kawah | `boss_defeated:faceless_captain`, sets `mq1_8` |
| 1.13 | End the legend again: the false dawn | Akhiri legenda itu sekali lagi: fajar palsu | `boss_defeated:sangkuriang`, sets `mq1_9` |

Beats:
- Turn: the `naganingrum` talk at the lake (NPC entry, cond `flag:mq1_6b`, not a beat). She knows the boy's face without being told. She is his mother. She points to the crater.
- `laras_1` (if `step:mq1=11`, at `sunda_2`): Laras's beat. A man with no face keeps asking her to read; she reads slowly on purpose. `do`: `flag:beat_laras_1`.
- `crater_seal` (if `flag:mq1_8`): the Hunter's appearance and the double-boss restore. The Captain, with his last strength, smashes the cracked seal-stone and **Sangkuriang** wakes (Seal 1). On the far rim the Hunter watches and leaves. Ciung is seen chained as bait. `do`: `flag:beat_crater_seal`, `restore`.
- `naga` (if `quest:mq1=done`): the aftermath that starts MQG. Ciung Wanara and the naga-king Nagawiru are free. Nagawiru: "The man on the throne wears my face. They took the girl to Galuh." Naganingrum reaches the rim too late to be recognised: Ciung doesn't know her. The egg Ciung carried hatches. You go east together. `do`: `flag:beat_naga`, `flag:mq1_10`, `codex:nagawiru`, `codex:sangkuriang`, `lakon:sangkuriang`, `start:mqg`.

### MQG Act II: "Wajah Pinjaman" / "The Borrowed Face" (Keraton Galuh, 9 steps)
Goal: get into the court and find where the taken are kept. Regional characters: **Uwa Lengser** and the **Faceless Deserter**. No new glyphs; rewards are gear and pusaka. Twist (the midpoint): the king is unmasked, and the Hunter *is* the name he gave away.

| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| g.1 | Plan the infiltration with Ciung Wanara at the square gates | Susun rencana menyusup bersama Ciung Wanara di gerbang alun-alun | `talked_to:ciung_wanara`, sets `mqg_0` |
| g.2 | Win the first bout of the king's tournament | Menangkan babak pertama sayembara raja | `area_cleared:galuh_bout_1`, sets `mqg_1` |
| g.3 | Win the second bout | Menangkan babak kedua | `area_cleared:galuh_bout_2`, sets `mqg_2` |
| g.4 | Speak with the old chamberlain, Uwa Lengser | Bicara dengan Uwa Lengser, abdi tua istana | `talked_to:lengser`, sets `mqg_3` (opens the palace gate) |
| g.5 | Rest in the palace courtyard | Beristirahat di pelataran istana | `petilasan_activated:galuh_1`, sets `mqg_4` |
| g.6 | Stop the wagon in the cell yard | Hadang kereta di halaman penjara | `area_cleared:galuh_escort`, sets `mqg_4b` (the near miss: the wagon gets away east) |
| g.7 | Search the cells for Laras | Geledah sel tahanan, cari Laras | `area_cleared:galuh_cells`, sets `mqg_5` (her message on the wall: "The thousand temples. Don't stop.") |
| g.8 | Decide the deserter's fate | Putuskan nasib si pembelot | `talked_to:faceless_deserter`, sets `mqg_6` (opens the throne room). **Choice 1:** free him (`choice_freed`) or hand him to Lengser (`choice_handed`) |
| g.9 | Unmask the king | Buka topeng sang raja | `boss_defeated:barma_wijaya`, sets `mqg_7` (opens the road to the Pamali) |

Beats:
- `galuh_bout` (if `flag:mqg_2`): the rooster won off-screen; Lengser sees the queen's eyes in Ciung Wanara. Lengser then stands by the ring (cond `flag:mqg_2`). `do`: `flag:beat_galuh_bout`, `codex:ciung_wanara`.
- `galuh_escort` (if `flag:mqg_4b`): the near miss. The wagon clears the yard gate as the last guard falls. A strip of lontar comes over the wall, *Ka* on it, and the wagon is gone east. `do`: `flag:beat_galuh_escort`.
- `laras_2` (if `step:mqg=7`, after the cells): Laras's beat. Under the wagon cloth she heard you fighting in the yard; she is rocking east. `do`: `flag:beat_laras_2`. (No petilasan here: the beat fires after the cells fight, **ASSUMED**.)
- Camp talk (cond `flag:mqg_4`, `ciung_wanara` entry `camp_galuh`, at `galuh_1`): optional, 2-4 lines. Ciung on the throne he wants and the sister you want. `do`: `flag:camp_galuh`. The entry also needs `!flag:mqg_7` and `zone:kg_keraton`: its last line looks ahead to the unmasking, so it closes after the boss and never replays in later acts (fixed 2026-11-06).
- `confession` (if `flag:mqg_7`): the turn. In the throne room Barma Wijaya admits Seal 2: he scraped the old king's name to keep the face and gave Kala his own. The Hunter *is* that name. This is the only reveal; the deserter at g.8 only hints ("our master speaks with the king's voice"). `do`: `flag:beat_confession`.
- `cage` (if `flag:beat_confession`): the Hunter's appearance. Ciung cages Barma Wijaya and Queen Pangrenyep, as in the legend. Pangrenyep has one line: "My son will come, child. What is caged is always ransomed." From the shadows behind the throne the Hunter: "The cage holds the man, not the name." `do`: `flag:beat_cage`, `codex:barma_wijaya`, `codex:pangrenyep`.
- `escape` (if `quest:mqg=done`, `flag:beat_cage`): the aftermath that starts MQ2. Prince Hariang Banga escapes east to raise an army and free his mother; he turns on Ciung only now, over the cage. Ciung stays to hold Galuh. You go on alone. `do`: `flag:beat_escape`, `start:mq2`.

Sensitivity: the rooster fights off-screen only. The hero never bets or handles it ([story_ciung_wanara.md](story_ciung_wanara.md) 5).

### MQ2 Act III: "Darah di Pamali" / "Blood on the Pamali" (Mataram, 13 steps)
Goal: stop the war that feeds Kala. Regional character: **Ki Sumarto**, a dalang who performs for both banks because his son marches with Hariang Banga. This is the three-leads act. Step 2.3 is a new step kind, `all` (section 7.1): three triggers that complete in any order, each one struck through in the journal as it fires.

| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| 2.1 | Break the ambush at the border gate | Patahkan penyergapan di gerbang perbatasan | `area_cleared:mataram_gerbang` |
| 2.2 | Rest at the petilasan by the rice fields | Beristirahat di petilasan dekat sawah | `petilasan_activated:mataram_1`, sets `mq2_1` |
| 2.3 | Follow the three leads on Laras: the market, the ruins, the graveyard | Telusuri tiga petunjuk tentang Laras: pasar, reruntuhan, dan kuburan | `all` (any order): `area_cleared:mataram_pasar` (sets `lead_pasar`, new), `area_cleared:mataram_ruins` (sets `lead_ruins`, new), `area_cleared:mataram_kuburan` (sets `lead_kuburan`, new). The step sets `mq2_4` (new) when all three are struck |
| 2.4 | Learn Ha from Ki Sumarto, whose show you saved | Pelajari Ha dari Ki Sumarto, yang pertunjukannya kau selamatkan | `glyph_learned:jawa_ha`, sets `mq2_2` (his entry needs `flag:lead_pasar`) |
| 2.5 | Read Na from the inscription on the Arca's base | Baca Na dari tulisan di dasar Arca | `glyph_learned:jawa_na`, sets `mq2_3` (object `arca_base`, cond `flag:lead_ruins`; marker moves from `pak_karto`) |
| 2.6 | Learn Ca from the lesung women | Pelajari Ca dari para perempuan di lesung | `glyph_learned:jawa_ca`, sets `mq2_5` (their entry needs `flag:lead_kuburan`, not the step) |
| 2.7 | Break the blockade on the foothill | Hancurkan blokade di kaki bukit | `area_cleared:mataram_batu` |
| 2.8 | Receive the juru kunci's blessing and learn Ra | Terimalah restu juru kunci dan pelajari Ra | `glyph_learned:jawa_ra`, sets `mq2_6` (Mbah Marto; opens the temple stairs) |
| 2.9 | Fight through the temple gate | Tembus gerbang candi | `area_cleared:mataram_candi` |
| 2.10 | Storm the Faceless camp at Candi Seribu | Serbu perkemahan tanpa rupa di Candi Seribu | `area_cleared:mataram_camp`, sets `mq2_7` (**the turn**; the Pamali stone wakes) |
| 2.11 | End Bandung Bondowoso's night | Akhiri malam Bandung Bondowoso | `boss_defeated:bandung_bondowoso`, sets `mq2_7b` (Seal 3; the lesung rhythm and Jawa Ca) |
| 2.12 | Write Nagawiru's true name on the Pamali stone | Tuliskan nama sejati Nagawiru di batu Pamali | `name_written:nagawiru`, sets `mq2_8` (Hariang Banga comes to the ford) |
| 2.13 | Duel Hariang Banga at the ford | Berduel dengan Hariang Banga di tepi penyeberangan | `boss_defeated:hariang_banga`, sets `mq2_9` (opens the east gate) |

Glyph rewards come from the deeds inside the leads. A glyph's source opens as soon as its lead is cleared, so the player can learn it on the spot. Each source is gated on its lead flag, not on the step number: Ki Sumarto on `lead_pasar`, `arca_base` on `lead_ruins`, the lesung women on `lead_kuburan` (script.md conditions the three entries the same way). Steps 2.4-2.6 are listed in the order Ha, Na, Ca for the journal and act as a reminder: a `glyph_learned:` step completes at once if the glyph is already known when it becomes current (like `item_picked:`, section 7.1), otherwise the arrow points at the source. In play each glyph is learned right after its lead fight, so the player never walks three plain steps in a row (Pacing 5).

Beats:
- `hunter_war` (if `flag:lead_kuburan`): the Hunter's appearance, at the graves, where his servants harvest the fallen. The Hunter: "Two armies make twice the forgetting." `do`: `flag:beat_hunter_war`.
- `lengser_word` (if `flag:choice_handed`, `flag:mq2_6`): one line, Lengser's word that the Deserter drew him the camp's layout. `do`: `flag:beat_lengser_word`.
- `camp` (if `flag:mq2_7`): the turn. The camp is not a prison, it is a reading room. You find a strip torn from Laras's half, covered with *Ka* written again and again. She is gone east. Seal 3 is broken and **Bandung Bondowoso** wakes. `do`: `flag:beat_camp`.
- `laras_3` (if `step:mq2=10`, `flag:beat_camp`, at the temple petilasan): Laras's beat. She read the seal because they hurt the prisoners when she didn't. `do`: `flag:beat_laras_3`.
- The Pamali stone (`pamali_stone`, cond `flag:mq2_7`) runs `write:nagawiru:jawa_na,sunda_ga`: one letter from each script.
- `ford` (if `flag:mq2_8`): Hariang Banga wades into the ford alone. You helped cage his mother, so it is a duel, not a battle. `do`: `flag:beat_ford`.
- `truce` (if `quest:mq2=done`): the aftermath that starts MQ3. Hariang Banga yields. Nagawiru's voice from the water, Ciung Wanara on the far bank: fighting your brother is *pamali*. The land splits at the river. Ki Sumarto's son (Sapto, **ASSUMED**) wades back across the ford. **Choice 2:** ask Ciung Wanara to show the caged king mercy (`choice_mercy`) or say nothing (`choice_silent`). `do`: `flag:beat_truce`, `codex:pamali`, `codex:roro_jonggrang`, `lakon:roro_jonggrang`, `start:mq3`.

Path: after 2.10 the `sc:mt_candi_gapura` shortcut brings the player back to `mt_gapura`, one area from `kg_pamali`. Pak Karto stays at `mt_reruntuhan` as a side-quest NPC.

### MQ3 Act IV: "Bilah Tujuh Turunan" / "The Seven-Generation Blade" (Tanah Timur, 11 steps)
Goal: follow the Hunter to the last seal. Regional character: **Mpu Wirasana**. Ally: **Hariang Banga**. No new glyphs; you learn to break curse marks (a technique). Twist: you see Laras, and the Eclipse takes her.

| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| 3.1 | Break the ambush at the eastern border | Patahkan penyergapan di perbatasan timur | `area_cleared:timur_gerbang` |
| 3.2 | Rest at the petilasan on the savanna | Beristirahat di petilasan di sabana | `petilasan_activated:timur_1`, sets `mq3_1` |
| 3.3 | Find Mpu Wirasana at the forge and learn to break curse marks | Temui Mpu Wirasana di bengkel tempa dan belajar mematahkan tanda kutukan | `talked_to:timur_empu`, sets `mq3_2` |
| 3.4 | Help Mbok Srini find Timun Mas | Bantu Mbok Srini mencari Timun Mas | `talked_to:mbok_srini`, sets `mq3_3` (the four pouches; the river wisps fall first, `area_cleared:timur_wisps`) |
| 3.5 | Defeat Buto Ijo | Kalahkan Buto Ijo | `boss_defeated:buto_ijo`, sets `mq3_4` |
| 3.6 | Break two practice curse marks | Patahkan dua tanda kutukan latihan | `area_entered:timur_praktik_mark` x2 |
| 3.7 | Follow the Hunter's ash trail down the coast | Ikuti jejak abu Si Tanpa Ngaran menyusuri pesisir | `area_cleared:timur_pesisir` |
| 3.8 | Cross the Sea of Sand | Seberangi Lautan Pasir | `area_cleared:timur_pasir` |
| 3.9 | Rest at the petilasan in the desert | Beristirahat di petilasan di gurun | `petilasan_activated:timur_2`, sets `mq3_6` (new) |
| 3.10 | Lay the cursed keris to rest | Tenangkan keris terkutuk | `boss_defeated:keris_gandring`, sets `mq3_7` (Seal 4) |
| 3.11 | Face the Nameless Hunter | Hadapi Si Tanpa Ngaran | `boss_defeated:nameless_hunter`, sets `mq3_8` |

Beats:
- `laras_4` (if `step:mq3=9`, at `timur_2`): Laras's beat. She can't remember your face; only one letter is left on her half, *Ka*. `do`: `flag:beat_laras_4`.
- Camp talk (cond `flag:mq3_6`, `zone:tt_pasir`, `hariang_banga` entry `camp_timur`, at `timur_2`): optional, 2-4 lines. Hariang Banga shows you the road east. `do`: `flag:camp_timur`. The zone cond keeps it from replaying at the Interlude table and the Gua Kala mouth (fixed 2026-11-06).
- `shrine_sight` (if `flag:mq3_6`, `flag:beat_laras_4`, `zone:tt_candi`): the turn. You see Laras across the shrine, made to read the last seal. The **Keris Mpu Gandring** wakes (Seal 4). The keris boss cond is `flag:beat_shrine_sight`. `do`: `flag:beat_shrine_sight`.
- `keris` (if `flag:mq3_7`): the keris lies quiet. **Choice 3:** take it to the empu to reforge (`choice_reforge`, `give:keris_gandring`) or give it to the river (`choice_sink`, `give:batu_kali`). `do`: `flag:beat_keris`.
- `hunter_shrine` (if `flag:beat_keris`): the Hunter's appearance (the duel) and the double-boss restore. He steps out of the shrine's shadow (his boss cond is `flag:beat_keris`). It is a separate beat because no lines can follow a choice. `do`: `flag:beat_hunter_shrine`, `restore`.
- `hunter_name` (if `quest:mq3=done`): the false victory and the aftermath that starts MQ4. His mask cracks; under it, the young face the king wore. You carve *Aria Kebonan* back onto it. In Galuh, the caged man gets his old face back. The bundle at his belt opens and the held names fly home ([story.md](story.md) Two kinds of forgetting). Then the Eclipse begins and takes Laras first. The Hunter, emptied: "She's gone where I was going." Hariang Banga's riders carry you home. `do`: `flag:beat_hunter_name`, `codex:nameless_hunter`, `start:mq4`, `goto:desa_purwa:from_riders` (spawn placed in desa_purwa.md, **ASSUMED**).

### MQ4 Interlude and Act V: "Rumah yang Sunyi" and "Laut Tak Pernah Lupa" (Desa Purwa, then Segara Kidul, 9 steps)
Steps 4.1-4.2 are the Interlude, "The Quiet House": about 10 minutes, no combat, the low point. Steps 4.3-4.9 are Act V, "The Sea Does Not Forget". Regional character: **Mbah Wiryo**. The journal shows the Act V title for the whole quest (**ASSUMED**). Nyi Roro Kidul speaks once, from a distance. She is never fought or touched, and she is neither friend nor enemy. Areas: `sk_pantai`, `sk_karang`, `sk_tebing`, `sk_keraton`.

| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| 4.1 | Go home to Desa Purwa | Pulanglah ke Desa Purwa | `zone_entered:desa_purwa` (the riders' `goto` lands you there) |
| 4.2 | Talk to Ibu | Bicara dengan Ibu | `talked_to:ibu`, sets `mq4_2` (two cups on the table; opens the south exit to `sk_pantai`) |
| 4.3 | Rest at the petilasan on the black-sand coast | Beristirahat di petilasan di pantai pasir hitam | `petilasan_activated:kidul_1` |
| 4.4 | Speak with Mbah Wiryo, the juru kunci of the coast | Bicara dengan Mbah Wiryo, juru kunci pantai | `talked_to:kidul_jurukunci`, sets `mq4_4` (respect for the coast; the green belief, told as belief) |
| 4.5 | Cross the reef | Seberangi karang | `area_cleared:kidul_karang_2` |
| 4.6 | Climb the cliff path | Daki jalan setapak di tebing | `area_cleared:kidul_tebing_2` |
| 4.7 | Rest at the cliff shrine and listen to the water | Beristirahat di kuil tebing dan dengarkan suara dari air | `petilasan_activated:kidul_3` (new petilasan in `sk_tebing`) |
| 4.8 | Pass the Trial of the Waves | Jalani Ujian Ombak | `area_cleared:kidul_trial`, sets `mq4_8` (three waves, each with its own glyph answer, [bestiary.md](bestiary.md) Zone 4) |
| 4.9 | Receive Ombak and the Kain Hijau | Terimalah Ombak dan Kain Hijau | `glyph_learned:jawa_ka`, sets `mq4_9` (the Sea Altar `kidul_altar` runs `write:ombak:jawa_ka`, `learn:jawa_ka` and `give:kain_hijau` at `step:mq4=8`; Ombak / Tide, + Kain Hijau, [spells.md](spells.md) 3). The act ends here |

Beats:
- Interlude: the Hunter's appearance is his empty mask in the fire. Turn, camp talk and double boss: none.
- `quiet_house` (if `flag:mq4_2`, `flag:choice_mercy`): Ibu has set out two cups and can't say why. Ciung Wanara and Hariang Banga meet for the first time as brothers, at your mother's table. The Hunter's empty mask lies in the fire. Ciung: the cage now has a lamp. Semar: "The sea does not forget." Go south. `do`: `flag:beat_quiet_house`.
- `quiet_house_silent` (if `flag:mq4_2`, `flag:choice_silent`): the same scene. Ciung says nothing about the cage and looks away. `do`: `flag:beat_quiet_house`.
- `laras_kidul` (if `step:mq4=7`, at the cliff shrine): Laras's beat, her voice from the water. She can hear the sea, and the sea still says her name. `do`: `flag:beat_laras_kidul`.
- `kidul_trial` (if `flag:mq4_8`): the turn of the act. Nyi Roro Kidul speaks once, from a distance. `do`: `flag:beat_kidul_trial`.
- `kidul` (if `quest:mq4=done`): the aftermath that starts MQ5. Semar: Ombak is the one letter the Eclipse can't eat. It opens the cave from the sea pavilion and breaks Kala's eclipse shield (the sea remembering is a game invention). `do`: `flag:beat_kidul`, `start:mq5`.

### MQ5 Act VI: "Ke Rahang Sang Waktu" / "Into the Maw of Time" (Gua Kala, 8 steps)
Requires `mq4_9`. The Hunter does not appear in this act (his empty mask was the Interlude).

| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| 5.1 | Enter Gua Kala | Masuki Gua Kala | `zone_entered:gk_mulut`, sets `mq5_1` |
| 5.2 | Reclaim La, the first letter of her name, at the Maw | Rebut La, huruf pertama namanya, di mulut gua | `area_cleared:kala_mulut`, sets `mq5_1b` |
| 5.3 | Shatter the western time-ward on the Hourglass Sands | Hancurkan penangkal waktu sebelah barat di Pasir Jam Pasir | `area_cleared:kala_pasir_1` |
| 5.4 | Shatter the eastern time-ward | Hancurkan penangkal waktu sebelah timur | `area_cleared:kala_pasir_2`, sets `mq5_1c` |
| 5.5 | Reclaim Ra, the second letter of her name, in the Abyss of Forgetting | Rebut Ra, huruf kedua namanya, di Jurang Lupa | `area_cleared:kala_lupa`, sets `mq5_1d` |
| 5.6 | Rest at the last petilasan | Beristirahat di petilasan terakhir | `petilasan_activated:kala_1`, sets `mq5_2` (the third letter, Sa; Semar waits here) |
| 5.7 | Calm Batara Kala | Tenangkan Batara Kala | `boss_defeated:batara_kala`, sets `mq5_3` |
| 5.8 | Write Laras's name | Tuliskan nama Laras | `name_written:laras`, sets `mq5_4` (then the epilogue and credits) |

Beats:
- `mouth_freed` (if `flag:mq5_1`, `flag:choice_freed`): the two brothers at the cave mouth, one from each bank, with the Deserter beside them. You go in alone. `do`: `flag:beat_mouth`.
- `mouth` (if `flag:mq5_1`): the same, without the Deserter. `do`: `flag:beat_mouth`. (`mouth_freed` is listed first.)
- `laras_5` (if `step:mq5=6`, at `kala_1`): Laras's beat. "Who's there?" She has forgotten you. She is still writing *Ka*. `do`: `flag:beat_laras_5`.
- `write` (if `flag:mq5_3`): Kala turns back into the dark, calmed in the Ruwatan of Dawn. Your half of the lontar is blank. Semar: "Then write it." `do`: `flag:beat_write`; a second, line-less entry (if `!flag:mq5_4`, `flag:beat_write`) runs `write:laras:sunda_la,sunda_ra,sunda_sa`, so a quit mid-card reopens the card. The name-writing card ([ui.md](ui.md) 3) ends with `name_written:laras`.

Epilogue: 7 cards. 1 Laras comes home and nobody thinks she ever left. 2 Ciung Wanara rules the west, Hariang Banga the east. 3-5 one card per choice (`EPILOGUE_n` or `EPILOGUE_n_ALT` when `choice_handed`, `choice_silent`, `choice_sink` is set). 6 the village wayang plays your story, Semar telling it. 7 your name and hers, the credit line with the codex %. After it the player wakes in Desa Purwa (`from_gua_kala`). Naganingrum is called back to court by her son, and Nagawiru sleeps in the lake (card 2).

Batara Kala is calmed and turned back, never killed. The ruwatan codex note from [story.md](story.md) applies.

**Post-game (ASSUMED):** every zone stays open, so unfinished side quests can still be done (never missable).

## 5. Side quests
Card format: type, size, giver, unlock, steps, resolution, reward, culture and **VERIFY** notes. IDs: `SQ-<zone letter><n>`.

### Tatar Sunda
Theme (names): carried by SQ-S1, where a prince lives under a borrowed face, the lutung, until someone sees him. Naganingrum's story is on the main path ([story.md](story.md)).

**SQ-S1 "Lutung Kasarung"** (re-telling, M)
- Giver: a juru pantun (singer of Sundanese pantun epics, **VERIFY** the role), at the village. Unlock: MQ1 step 1.4.
- Steps: (1) find the black lutung (langur) spirit in the forest, (2) clear the spirits from the hidden spring, (3) bring Purbasari to the spring. The bath cures her skin, as in the legend.
- Reward: **Iket Sunda**, lakon "Lutung Kasarung", Ilmu M.
- Culture: Purbasari, her sister Purbararang, and the lutung who is really Guruminda, a heavenly being. He is an ally. **VERIFY** the cure and the names.

**SQ-S2 "Kuntilanak Rumpun Bambu" / "The Bamboo-Grove Kuntilanak"** (bounty, L)
- Giver: the kepala desa (village head). Unlock: MQ1 step 1.4.
- Steps: (1) hear the reports, (2) find the elite kuntilanak in the bamboo grove at night (a marked arena), (3) defeat her, (4) report back.
- Reward: **Golok**, **Herb Pouch #1**, Ilmu L.
- Culture: label her as pan-Indonesian folklore. Cartoonish, no gore. Which tree she is tied to varies (**VERIFY**: bamboo, waru or another).

**SQ-S3 "Angklung yang Tercerai" / "The Scattered Angklung"** (errand, M)
- Giver: the leader of a village angklung group. Unlock: entering Tatar Sunda.
- Steps: (1) find 5 angklung scattered across the zone (each plays one note when picked up), (2) return them. The group plays a short piece with all 5 notes.
- Reward: **Flask Shard #1**, Ilmu M.
- Culture: each angklung sounds one note, so a tune needs every player. That is the point of the quest and the codex entry. Angklung is UNESCO 2010 (verified). **VERIFY** the traditional scale (pentatonic salendro/pelog vs the later diatonic angklung).

**SQ-S4 "Cepot Si Pemberani" / "Brave Cepot"** (errand, S, first-hour path)
- Giver: Cepot. Unlock: MQ1 step 1.2, so the quest system shows up early.
- Steps: (1) Cepot wants to prove he is brave and asks you to defeat 3 Wild Boar (was Maung, dropped with the tiger spirit, **ASSUMED** 2026-11-05) while he "supervises" from a tree, commenting on each kill, (2) report back.
- Reward: **Silver Bangle**, Ilmu S.
- Culture: Cepot's humor as in wayang golek. Barks are one-liners in both languages.

**SQ-S5 (retired in v3.1).** Sangkuriang is fought on the main path (MQ1 1.13), so the echo is cut. Its lakon "Sangkuriang" and codex `sangkuriang` are given when MQ1 completes. Dayang Sumbi keeps an idle talk at the lake after MQ1 (cond `quest:mq1=done`). Code follow-up: remove `data/quests/sq_s5.tres` and Sangkuriang's `quest:sq_s5=active` cond.

### Mataram
Theme (forgetting): carried by SQ-M2, where a neglected child is lost because no one looked for it. Ki Sumarto's story is on the main path.

**SQ-M1 "Jaka Tarub dan Nawang Wulan" / "Jaka Tarub and Nawang Wulan"** (re-telling, M)
- Giver: Nawang Wulan, a quiet woman in a rice-farming household. Unlock: MQ2 step 2.2.
- Steps: (1) she says her rice pot's magic broke after someone lifted the lid, (2) search the lumbung (rice barn), (3) find her selendang (shawl) hidden under the last of the rice, (4) return it.
- Resolution: she returns to the sky, as in the legend, and leaves her weaving scarf behind as thanks.
- Reward: **Feather Charm**, **Herb Pouch #2**, lakon "Jaka Tarub", Ilmu M.
- Culture: one grain of rice filled the pot while the lid stayed closed. Jaka Tarub hid the shawl. Their daughter Nawangsih. Nawang Wulan is a bidadari (celestial maiden), not a deity, and shown with respect. **VERIFY** all beats and the legend's location.

**SQ-M2 "Wewe Gombel"** (bounty, two-way, L). Wewe Gombel moved to Mataram (decided 2026-11-05).
- Giver: a worried neighbor. Unlock: MQ2 step 2.4.
- Steps: (1) a neglected child has gone missing, (2) find the hill where Wewe Gombel hides children.
- Resolution:
  - **Peaceful:** go back and talk to the parents. They come to the hill and call the child kindly (and bang pots, as in the folk practice, **VERIFY**). Wewe Gombel returns the child, since in folklore she takes children who are neglected, not to harm them.
  - **Fight:** defeat the elite Wewe Gombel and bring the child home.
- Reward: **Jimat**, Ilmu L (fight +50%). Peaceful adds the codex entry "Wewe Gombel's lesson".
- Culture: the legend is a warning about neglect. The peaceful ending tells that story best.

**SQ-M3 "Tuyul di Pasar" / "A Tuyul at the Market"** (bounty, two-way, M)
- Giver: a pande besi (blacksmith) with a market stall. Unlock: MQ2 step 2.2.
- Steps: (1) coins vanish from the stalls, (2) find the tuyul swarm's hideout.
- Resolution:
  - **Peaceful:** set out the folk distraction (**VERIFY**: crabs, or green beans the tuyul must count) and catch the leader while it plays.
  - **Fight:** defeat the elite tuyul leader and its swarm.
- Reward: **Spear**, Ilmu M (fight +50%).
- Culture: described only as a mischievous money-stealing child spirit. Light comedy.

**SQ-M4 "Gamelan yang Bisu" / "The Silent Gamelan"** (errand, M)
- Giver: Ki Dalang, the MQ2 teacher. Unlock: MQ2 step 2.4.
- Steps: (1) the village gamelan's gong ageng was carried off into the temple ruins, (2) fight through the Arca to find it, (3) bring it back. The zone music gains its gong layer from then on (a cheap audio-state change, strong payoff).
- Reward: **Blangkon**, Ilmu M.
- Culture: the gong ageng marks the end of the musical cycle (**VERIFY** wording). Gamelan is UNESCO 2021 (verified).

**SQ-M5 (retired in v3.1).** Bandung Bondowoso is fought on the main path (MQ2 2.11), so the echo is cut. Its lakon "Roro Jonggrang" and codex `roro_jonggrang` are given when MQ2 completes. Code follow-up: remove `data/quests/sq_m5.tres` and Bondowoso's `quest:sq_m5=active` cond.

### Tanah Timur
Theme (names): carried by SQ-T1, where a hero hides behind a borrowed name.

**SQ-T1 "Ande-Ande Lumut"** (re-telling, two-way, M)
- Giver: Klething Kuning at the riverbank. Unlock: MQ3 step 3.2.
- Steps: (1) she must cross the river to reach Ande-Ande Lumut, but Yuyu Kangkang, a giant crab, demands a payment from everyone who crosses.
- Resolution:
  - **Peaceful (the legend's way):** fetch the sodo lanang (a stick from a palm-leaf broom) she was given, and she strikes the river with it. The water dries up (**VERIFY** who gave it and what it does).
  - **Fight:** defeat Yuyu Kangkang (an elite charger).
- Reward: **Stone Ring**, lakon "Ande-Ande Lumut", Ilmu M (fight +50%).
- Culture: a Panji tale. Ande-Ande Lumut is Panji in disguise. Child-friendly retelling: the crab demands "a payment", not a kiss.

**SQ-T2 "Banaspati Padang Sabana" / "The Savanna Banaspati"** (bounty, L)
- Giver: a herder. Unlock: MQ3 step 3.2.
- Steps: (1) the grassland keeps catching fire, (2) follow the burn trail to the elite Banaspati, (3) defeat it.
- Reward: **Herb Pouch #3**, Ilmu L.
- Culture: fire spirit. Do not tie it to the Tengger or Bromo rituals.

**SQ-T3 "Pamor dari Langit" / "Pamor from the Sky"** (errand, cross-zone, M)
- Giver: the empu. Unlock: MQ3 step 3.3.
- Steps: (1) the empu needs a batu bintang (meteorite) to forge a keris with pamor (the patterned metal layers), (2) travel back to Mataram, where a fragment lies near the temple plain, (3) bring it back.
- Reward: **Keris Luk 7**, Ilmu M.
- Culture: the Prambanan meteorite is known for keris pamor (**VERIFY**). This is a quest reward, not a crafting system. Keris is UNESCO 2008 (verified). It teaches backtracking on the open map.

**SQ-T4 "Kuda Kepang yang Hilang" / "The Lost Kuda Kepang"** (errand, S)
- Giver: the leader of a kuda lumping troupe. Unlock: MQ3 step 3.2.
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
| `all` | Built 2026-11-06 (bits saved in the quest record, `all`). For a step that has several triggers: `[{on: "area_cleared:mataram_pasar", set_flag: "lead_pasar"}, ...]`. Each trigger completes on its own, in any order, and stores its own bit in the quest state. The step completes (and sets its own `set_flag`) when all are done. `on` is empty on such a step. The journal strikes each trigger through as it fires (each needs a text key, e.g. `Q_MQ2_S3_A`). Used once, for the three leads in MQ2 step 2.3 |

Built 2026-11-06: a `glyph_learned:` step (or `all` trigger) completes at once if that glyph is already known when the step becomes current (same rule as `item_picked:`), so MQ2 2.4-2.6 never block a player who took the glyph early.

Dialogue (`DialogueData`, one `.tres` per NPC in `data/dialogue/`, **ASSUMED** 2026-11-05): `npc_id`, `name_key`, `entries: Array[Dictionary]`, each `{"if": [conditions], "lines": [keys], "do": [actions]}`. The first entry whose conditions all hold plays; an entry with no `if` is the fallback and goes last.
- Conditions: `quest:<id>=<locked|available|active|done>`, `step:<id>=<n>` (0-based current step), `flag:<f>`, `!flag:<f>`, `glyph:<id>`, `item:<id>` (held), and comma lists (all of). `zone:<area_id>` (the player is in that area, built 2026-11-06); the Act IV `shrine_sight` beat uses it.
- An entry with `"quiet": true` does not fire `talked_to` (a refusal that must not complete a talk step).
- Actions run when the box closes, in order: `start:<quest>`, `give:<item>`, `learn:<glyph>`, `flag:<f>`, `codex:<id>`, `write:<seq_id>:<glyph>,<glyph>`. Then `talked_to:<npc_id>` fires.
- Built 2026-11-06: `goto:<area>:<spawn>` moves the player to that area and spawn after the box closes (Act IV aftermath: Hariang Banga's riders carry you home, `goto:desa_purwa:from_riders`); it fires `zone_entered`. `restore` refills health, stamina and flask charges (double-boss beats, **ASSUMED**); it does not save or reset the sakti gauge. `lakon:<id>` sets the same flag a quest's lakon reward sets.
- `Game.check(cond)` and `Game.run(action)` hold the logic, so the NPC script only walks the list.

`CodexEntry` (`data/codex/<id>.tres`): `id`, `category` (`enemy` / `legend` / `item` / `aksara`), `source`. Text keys `CODEX_<ID>_TITLE`, `_BODY`, `_WEAK` (enemies only). Unlocks on the first kill of that enemy `kind`, an item pick, a glyph learned, or a `codex:` action. A weakness trigger sets flag `weak:<kind>`, which shows the `_WEAK` line.

### 7.2 Events
Quests listen to signals that `Events` already plans plus a few more: `talked_to(npc_id)`, `item_picked(item_id)`, `enemy_killed(enemy_id)`, `boss_defeated(boss_id)`, `area_cleared(area_id)`, `area_entered(trigger_id)`, `zone_entered(zone_id)`, `petilasan_activated(id)`, `glyph_learned(glyph_id)`, `spell_cast(glyph_id, score)`, `class_chosen(class_id)`, `trial_completed(id)`. Plus outgoing: `quest_started`, `quest_updated`, `quest_completed`.

### 7.3 State (in `Game`)
- `quests: {id: {state, step, count, resolution}}`, state in `locked / available / active / done`.
- `flags: {}`, already planned for story flags.
- On any event, `Game` checks only the current step of each `active` quest, so it is cheap.
- Saved with the rest of `Game` in the autosave ([rpg.md](rpg.md) 11). Every quest start, step and completion triggers a save.

### 7.4 Journal ("Catatan" / "Journal")
- A tab in the Tab menu with 3 lists: Main, Side, Done.
- Each quest: title, giver, zone, current objective, earlier steps struck through, reward preview (key reward only).
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
- A headless check (same style as the recognizer test) that loads every `QuestData` and asserts: every `requires` flag is set by some step, every `marker` names an existing zone, every key exists in both `id` and `en` columns, and every item in `rewards` exists. This catches broken quest chains without playing.

## 8. First-hour path
Name entry -> prologue (5 cards, Laras is taken) -> class -> Ibu does not remember her, yet two cups are set out -> Laras's lontar from the burned stage -> Semar and Ka (the deed first, then the glyph) -> cast Ka -> the faceless in the village square -> the Hunter at the west gate ("Wrong child. A better one.") -> west -> MQ1 steps 1.1-1.4 (ribbon, petilasan and Cepot SQ-S4, the kampung ambush, then Ga from Abah Karna). In the first 15 minutes the player knows who they are looking for, who took her and who else is hunted, and meets the quest arrow, a side quest start to finish, two glyphs, each earned by a deed, and a codex entry (v3.1, 2026-11-06).

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
| Village elder (sesepuh) | Abah Karna | Tatar Sunda, MQ1 1.4 |
| Juru pantun | Ki Darsa | Tatar Sunda, SQ-S1 |
| Dalang | Ki Sumarto | Mataram, MQ2 2.4 and regional character |
| Stone-carver (pemahat batu) | Pak Karto | Mataram, `mt_reruntuhan`. Off the main path since v3.1 (Na is read off `arca_base`); a side-quest NPC (no quest assigned yet) |
| Ki Sumarto's son | Sapto | Keraton Galuh, `kg_pamali`, MQ2 aftermath (`truce`), **ASSUMED** |
| Juru kunci | Mbah Marto | Mataram, MQ2 2.8 |
| Empu | Mpu Wirasana | Tanah Timur, MQ3 3.3 |
| Wayang stage dalang | Ki Wangsa | Desa Purwa, MQ0 |
| Codex keeper | Nyai Rukmi | Desa Purwa, SQ-D2 |
| Juru kunci of the coast | Mbah Wiryo | Segara Kidul, MQ4 4.4 |
4. Docs to sync: [scope.md](scope.md) (bilingual moves from P2 to P0, side quests are 3-4 per zone), [story.md](story.md) (side quest section now points here), [items.md](items.md) (add Lontar Kuno, Flask Shard, Herb Pouch; Golok and Spear sources), [architecture.md](architecture.md) (translation keys, `QuestData`, `data/quests/`, `data/text/`), [rpg.md](rpg.md) (flask max 6 charges, heal up to 60%).
