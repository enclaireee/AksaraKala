# Quests

The main quest, all side quests, the reward economy and the quest system that runs them. Related: [story.md](story.md), [world.md](world.md), [bestiary.md](bestiary.md), [items.md](items.md), [spells.md](spells.md), [architecture.md](architecture.md).

Conventions as in [README.md](README.md): **ASSUMED**, **VERIFY**, **TUNE**. Every legend detail in this file is from general knowledge and is **VERIFY** unless it is already in the Nov 2026 fact-check (see [HANDOFF.md](HANDOFF.md) section 4).

## 1. Decisions (confirmed by the user, 2026-11-05)
| Topic | Decision |
|-------|----------|
| Guidance | Quest journal in the Tab menu, plus a soft edge-of-screen arrow for the **active main objective only** (the player may pin one side quest instead) |
| Main order | Fixed: Desa Purwa, Tatar Sunda, Mataram, Tanah Timur, (Segara Kidul, P1), Gua Kala. Fog gates enforce it |
| Side quest types | Folklore re-tellings, spirit bounties, errands for villagers. No aksara-reading puzzles as side quests |
| Volume | 3-4 side quests per zone, about 16 in total |
| Missable | Never. No quest closes, fails or times out. All stay open after their zone's boss and after the ending |
| Choices | Some quests can be resolved 2 ways (peaceful or fight). No effect on the main story |
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
  | Mataram | 55 | 110 | 165 |
  | Tanah Timur | 110 | 220 | 330 |
  | Segara Kidul | 190 | 380 | 570 |
  | Gua Kala | 190 | 380 | 570 |

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
| Kain Hijau | Main quest, Segara Kidul trial (MQ4, P1) |
| Silver Bangle | SQ-S4 Cepot |
| Feather Charm | SQ-M1 Jaka Tarub |
| Jimat | SQ-M2 Wewe Gombel |
| Stone Ring | SQ-T1 Ande-Ande Lumut |
| Lontar Kuno (new) | SQ-D2 Pustaka, at 50% codex |
| Flask Shard x3 | SQ-S3 Angklung, SQ-T4 Kuda Kepang, SQ-D1 Lakon (4 lakon) |
| Herb Pouch x4 | SQ-S2, SQ-M1, SQ-T2, SQ-K1 (P1) |

## 4. Main quest
Story v2 (user call 2026-11-06, [story_ciung_wanara.md](story_ciung_wanara.md)): the hunt for Laras. Six chapters. Quest ids stay as stable keys (`mq0`, `mq1`, `mqg`, `mq2`, `mq3`, `mq5`); the journal shows the chapter title. Old gate flag names are kept. The arrow always points at the current step. Glyphs are learned only here, and each teacher speaks one hint about the enemy that glyph counters ([bestiary.md](bestiary.md) Glyph weaknesses). Every line of text is in [script.md](script.md).

Pacing rules (2026-11-06): about 7 of 10 steps are play. No "return to Semar" steps: each chapter ends in a **story beat** that starts the next quest. A talk is at most 4 lines and ends on a lead. Lore lives in the codex.

**Story beats.** `data/dialogue/beats.tres` holds entries in the dialogue format (`if`, `lines`, `do`, optional `choices`). A listener in GameUI (`ui/story_beat.gd`) plays the first entry whose `if` holds, when no dialogue or menu is open, on `Game.changed` and after each zone load. Every beat's `if` includes `!flag:beat_<id>` and its `do` sets `flag:beat_<id>`, so it plays once. Lines may switch speaker with `@NPC_..._NAME` ([ui.md](ui.md) 3). Beats with no speaker are narration. Each chapter has one **Laras beat** at a petilasan: 2-3 lines, her voice from the dark.

**Choices** (3 in all, [ui.md](ui.md) 3): the deserter (MQG), mercy for the caged king (MQ2), the keris (MQ3). Each sets one flag; they change one epilogue card each and nothing else.

Step "Completes on" is the quest trigger; `sets` is the step's `set_flag`.

### MQ0 Prologue: "Malam Wayang" / "The Night of the Wayang" (Desa Purwa)
Teaches: movement, interacting, class choice, the first glyph, combat basics. Before the save: name entry, the prologue (5 cards: the show, Laras with her lontar, the faceless step out of the screen, she is taken, morning), class choice. New Game starts MQ0 at 0.4 with 0.1-0.3 struck.

| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| 0.1 | Watch the wayang show | Saksikan pertunjukan wayang | struck (prologue) |
| 0.2 | Survive the night | Bertahan malam itu | struck (prologue) |
| 0.3 | Choose your path | Pilih jalanmu | struck (`class_chosen`) |
| 0.4 | Ask Ibu where Laras is | Tanya Ibu di mana Laras | `talked_to:ibu` (she doesn't know any Laras; "Semar was up all night at the sanggar"), sets `mq0_4` |
| 0.5 | Find Semar in the sanggar | Temui Semar di sanggar | `glyph_learned:sunda_ka` (he remembers her; Ka, "for kakak, what she called you") |
| 0.6 | Cast Ka three times | Rapalkan Ka tiga kali | `spell_cast:sunda_ka` x3 |
| 0.7 | Drive the faceless out of the village | Usir para tanpa rupa dari desa | `area_cleared:purwa_raid` (3 Faceless at the plaza), sets `mq0_7` |
| 0.8 | Follow the raiders west | Ikuti jejak para perampok ke barat | `zone_entered:ts_kebun` |

Beat `hunter_raid` (if `flag:mq0_7`): the Nameless Hunter at the west gate. "Wrong child." He wanted the boy with the egg. Nini Balangantrang: our Ciung ran west in the night. The Hunter is gone. Codex `faceless`.

The training dummies stay in the sanggar for practice but no step needs them.

### MQ1 Act 1: "Jejak ke Barat" / "The Trail West" (Tatar Sunda)
Goal: catch the faceless and the boy they hunt. Twist: the faceless serve the king, and the king is false.

| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| 1.1 | Rest at the petilasan by the tea terraces | Beristirahat di petilasan dekat kebun teh | `petilasan_activated:sunda_1`, sets `mq1_1` (Cepot is here; SQ-S4) |
| 1.2 | Ask the village elder about the raiders, and learn Ga | Tanya sesepuh kampung soal perampok, dan pelajari Ga | `glyph_learned:sunda_ga`, sets `mq1_3` (the elder talk also sets `mq1_2`, SQ-S1/S2) |
| 1.3 | Clear the faceless from the batu tulis | Usir para tanpa rupa dari batu tulis | `area_cleared:sunda_batutulis` |
| 1.4 | Read the batu tulis and learn Nga | Baca batu tulis dan pelajari Nga | `glyph_learned:sunda_nga`, sets `mq1_5` (a king's face carved and scratched out) |
| 1.5 | Drive the faceless off the rice terraces | Usir para tanpa rupa dari teras sawah | `area_cleared:sunda_terraces` |
| 1.6 | Find the woman by the lake | Temui perempuan di tepi danau | `glyph_learned:sunda_ca`, sets `mq1_7` (Naganingrum, unnamed; teaches Ca; "the boy went up to the crater") |
| 1.7 | Climb to the crater rim | Daki ke bibir kawah | `petilasan_activated:sunda_2` |
| 1.8 | Save the naga from the faceless | Selamatkan naga dari para tanpa rupa | `boss_defeated:faceless_captain`, sets `mq1_8` |

Laras beat `laras_1` (at `sunda_2`): a man with no face keeps asking her name; she won't tell him.
Beat `naga` (if `quest:mq1=done`): Nagawiru, half-remembering, says the king wears his face; the egg hatches; Ciung Wanara heads for Galuh. `do`: `flag:mq1_10` (opens the Desa Purwa east gate), `start:mqg`, `codex:nagawiru`.

### MQG Act 2: "Topeng Sang Raja" / "The King's Mask" (Keraton Galuh)
Goal: get into the court and find where the taken are kept. Twist: the king is unmasked and caged, the forgetting gets worse, and Laras was never here.

| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| g.1 | Win the first bout of the king's tournament | Menangkan babak pertama sayembara raja | `area_cleared:galuh_bout_1`, sets `mqg_1` |
| g.2 | Win the second bout | Menangkan babak kedua | `area_cleared:galuh_bout_2`, sets `mqg_2` |
| g.3 | Speak with the old court officer | Bicara dengan abdi tua istana | `talked_to:lengser`, sets `mqg_3` (opens the palace gate) |
| g.4 | Rest in the palace courtyard | Beristirahat di pelataran istana | `petilasan_activated:galuh_1`, sets `mqg_4` |
| g.5 | Search the cells for Laras | Geledah sel tahanan, cari Laras | `area_cleared:galuh_cells`, sets `mqg_5` |
| g.6 | Decide the deserter's fate | Putuskan nasib si pembelot | `talked_to:faceless_deserter`, sets `mqg_6` (opens the throne room). **Choice 1:** free him (`choice_freed`) or hand him to Lengser (`choice_handed`) |
| g.7 | Unmask the king | Buka topeng sang raja | `boss_defeated:barma_wijaya`, sets `mqg_7` (opens the road to the Pamali) |

Beat `galuh_bout` (if `flag:mqg_2`): the rooster won off-screen; Lengser sees the queen's eyes in Ciung Wanara. Lengser then stands by the ring (cond `flag:mqg_2`).
Laras beat `laras_2` (at `galuh_1`): there is no palace where she is, only the dark and something breathing.
Beat `cage` (if `quest:mqg=done`): Ciung Wanara cages Barma Wijaya and Pangrenyep. The king: the forgotten go east, to the cave; he only fed it. The Hunter, from the shadows: the cage holds the man, not the name. `do`: `start:mq2`, `codex:barma_wijaya`.

Sensitivity: the rooster fights off-screen only. The hero never bets or handles it ([story_ciung_wanara.md](story_ciung_wanara.md) 5).

### MQ2 Act 2: "Perang Saudara" / "Brothers at War" (Mataram)
Goal: stop the war that feeds Kala. Hariang Banga raises an army on the east bank to free his mother. Twist: the Hunter feeds both armies.

| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| 2.1 | Rest at the petilasan by the rice fields | Beristirahat di petilasan dekat sawah | `petilasan_activated:mataram_1`, sets `mq2_1` |
| 2.2 | Find the dalang at the market and learn Ha | Temui dalang di pasar dan pelajari Ha | `glyph_learned:jawa_ha`, sets `mq2_2` |
| 2.3 | Learn Na from the stone-carver | Pelajari Na dari pemahat batu | `glyph_learned:jawa_na`, sets `mq2_3` |
| 2.4 | Clear the ruins the armies fight over | Bersihkan reruntuhan yang diperebutkan | `area_cleared:mataram_ruins` |
| 2.5 | Learn Ca from the women at the lesung | Pelajari Ca dari para perempuan di lesung | `glyph_learned:jawa_ca`, sets `mq2_5` |
| 2.6 | Ask the juru kunci for the tiger's blessing | Mohon restu macan dari juru kunci | `glyph_learned:jawa_ra`, sets `mq2_6` (opens the temple stairs) |
| 2.7 | Break the faceless camp at the temples | Hancurkan perkemahan tanpa rupa di candi | `area_cleared:mataram_camp`, sets `mq2_7` (the Pamali stone wakes) |
| 2.8 | Write the naga's true name on the Pamali stone | Tuliskan nama sejati sang naga di batu Pamali | `name_written:nagawiru`, sets `mq2_8` (Hariang Banga comes to the ford) |
| 2.9 | Stop Hariang Banga at the ford | Hentikan Hariang Banga di penyeberangan | `boss_defeated:hariang_banga`, sets `mq2_9` (opens the east gate) |

Beat `hunter_war` (if `flag:mq2_6`): the Hunter at the graves: two armies, twice the forgetting.
Laras beat `laras_3` (if `flag:mq2_7`, the temple petilasan `mataram_2`): she wrote your name again so she wouldn't lose it; the strip is short now.
The Pamali stone (`pamali_stone`, cond `flag:mq2_7`) runs `write:nagawiru:jawa_na,sunda_ga`: one letter from each script.
Beat `ford` (if `flag:mq2_8`): Hariang Banga wades into the ford alone; you helped cage his mother, so it is a duel, not a battle.
Beat `truce` (if `quest:mq2=done`): Hariang Banga yields. Nagawiru's voice from the water, Ciung Wanara on the west bank (Pangrenyep is caged): fighting your brother is pamali. The land splits at the river. **Choice 2:** ask Ciung Wanara to show the caged king mercy (`choice_mercy`) or say nothing (`choice_silent`). Hariang Banga will show you the road east. `do`: `start:mq3`, `codex:pamali`.

Path: after 2.7 the `sc:mt_candi_gapura` shortcut brings the player back to `mt_gapura`, one area from `kg_pamali`.

### MQ3 Act 3: "Keris dan Pemburu" / "The Keris and the Hunter" (Tanah Timur)
Goal: find the way into Kala's cave. Twist: the Hunter is Aria Kebonan's true self, the name the king gave away. Laras's lontar is down to the last letter.

| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| 3.1 | Rest at the petilasan on the savanna | Beristirahat di petilasan di sabana | `petilasan_activated:timur_1`, sets `mq3_1` |
| 3.2 | Find the empu at the forge | Temui sang empu di bengkel tempa | `talked_to:timur_empu`, sets `mq3_2` (the way in is through a blade Kala woke; he teaches breaking curse marks) |
| 3.3 | Help Mbok Srini find Timun Mas | Bantu Mbok Srini mencari Timun Mas | `talked_to:mbok_srini`, sets `mq3_3` (the four pouches) |
| 3.4 | Defeat Buto Ijo | Kalahkan Buto Ijo | `boss_defeated:buto_ijo`, sets `mq3_4` |
| 3.5 | Break two practice curse marks | Patahkan dua tanda kutukan latihan | `area_entered:timur_praktik_mark` x2 |
| 3.6 | Rest before the shrine | Beristirahat sebelum candi | `petilasan_activated:timur_2` |
| 3.7 | Lay the cursed keris to rest | Tenangkan keris terkutuk | `boss_defeated:keris_gandring`, sets `mq3_7` |
| 3.8 | Face the Nameless Hunter | Hadapi Si Tanpa Ngaran | `boss_defeated:nameless_hunter`, sets `mq3_8` (opens the Gua Kala gate in Desa Purwa) |

Laras beat `laras_4` (at `timur_2`): she can't remember your face; she has one letter of your name left.
Beat `keris` (if `flag:mq3_7`): the keris lies quiet. **Choice 3:** take it to the empu to reforge (`choice_reforge`) or give it to the river (`choice_sink`). Beat `hunter_shrine` (if `flag:beat_keris`): the Hunter steps out of the shrine's shadow (his boss cond is `flag:beat_keris`); a separate beat because no lines can follow a choice.
Beat `hunter_name` (if `quest:mq3=done`): his mask cracks; under it, the young face the king wore. "Aria Kebonan," he says, like a word he once knew. In Galuh, the caged man gets his old face back. Hariang Banga and Ciung Wanara will hold the cave mouth. `do`: `start:mq5`, `codex:nameless_hunter`.

Old step 3.5 (a second empu talk) is cut: the empu explains the marks in 3.2.

### MQ4 Act 4: "Ratu Laut Kidul" / "Queen of the Southern Sea" (Segara Kidul, P1)
| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| 4.1 | Reach the southern shore | Capai pantai selatan | `zone_entered:segara_kidul` |
| 4.2 | Speak with the juru kunci of the coast | Bicara dengan juru kunci pantai | `talked_to:kidul_jurukunci` (explains respect and the green belief, presented as belief) |
| 4.3 | Face the trial of the waves | Jalani ujian ombak | `trial_completed:kidul` (three waves, each with its own glyph answer, [bestiary.md](bestiary.md) Zone 4) |
| 4.4 | Receive the final letter | Terima aksara terakhir | `glyph_learned:jawa_ka` (Ombak / Tide, + Kain Hijau, [spells.md](spells.md) 3) |

Nyi Roro Kidul speaks once, from a distance. She is never fought or touched, and she is neither friend nor enemy.

### MQ5 Finale: "Gua Kala" / "Kala's Cave"
| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| 5.1 | Enter Gua Kala | Masuki Gua Kala | `zone_entered:gk_mulut`, sets `mq5_1` |
| 5.2 | Rest at the last petilasan | Beristirahat di petilasan terakhir | `petilasan_activated:kala_1`, sets `mq5_2` |
| 5.3 | Face Batara Kala | Hadapi Batara Kala | `boss_defeated:batara_kala`, sets `mq5_3` |
| 5.4 | Write Laras's name | Tuliskan nama Laras | `name_written:laras`, sets `mq5_4` (then the epilogue and credits) |

Beat `mouth` (if `flag:mq5_1`): the two brothers at the cave mouth, one from each bank, holding the faceless back. You go in alone.
Laras beat `laras_5` (at `kala_1`): "Who's there?" She has forgotten you. She is still writing.
Beat `write` (if `flag:mq5_3`): Kala turns back into the dark. Her lontar is blank. Semar: "Then write it." `do`: `flag:beat_write`; a second, line-less entry (if `!flag:mq5_4`, `flag:beat_write`) runs `write:laras:sunda_la,sunda_ra,sunda_sa`, so a quit mid-card reopens the card. The name-writing card ([ui.md](ui.md) 3) ends with `name_written:laras`.

Epilogue: 7 cards. 1 Laras comes home and nobody thinks she ever left. 2 Ciung Wanara rules the west, Hariang Banga the east. 3-5 one card per choice (`EPILOGUE_n` or `EPILOGUE_n_ALT` when `choice_handed`, `choice_silent`, `choice_sink` is set). 6 the village wayang plays your story, Semar telling it. 7 your name and hers, the credit line with the codex %. After it the player wakes in Desa Purwa (`from_gua_kala`).

Batara Kala is calmed and turned back, never killed. The ruwatan codex note from [story.md](story.md) applies.

**P0 build:** without Segara Kidul, MQ5 starts in the `hunter_name` beat. The way in is the fogged exit in Desa Purwa (kabut `mq3_8`, [desa_purwa.md](zones/desa_purwa.md)).

**Post-game (ASSUMED):** every zone stays open, so unfinished side quests can still be done (never missable).

## 5. Side quests
Card format: type, size, giver, unlock, steps, resolution, reward, culture and **VERIFY** notes. IDs: `SQ-<zone letter><n>`.

### Tatar Sunda
**SQ-S1 "Lutung Kasarung"** (re-telling, M)
- Giver: a juru pantun (singer of Sundanese pantun epics, **VERIFY** the role), at the village. Unlock: MQ1 step 1.2.
- Steps: (1) find the black lutung (langur) spirit in the forest, (2) clear the spirits from the hidden spring, (3) bring Purbasari to the spring. The bath cures her skin, as in the legend.
- Reward: **Iket Sunda**, lakon "Lutung Kasarung", Ilmu M.
- Culture: Purbasari, her sister Purbararang, and the lutung who is really Guruminda, a heavenly being. He is an ally. **VERIFY** the cure and the names.

**SQ-S2 "Kuntilanak Rumpun Bambu" / "The Bamboo-Grove Kuntilanak"** (bounty, L)
- Giver: the kepala desa (village head). Unlock: MQ1 step 1.2.
- Steps: (1) hear the reports, (2) find the elite kuntilanak in the bamboo grove at night (a marked arena), (3) defeat her, (4) report back.
- Reward: **Golok**, **Herb Pouch #1**, Ilmu L.
- Culture: label her as pan-Indonesian folklore. Cartoonish, no gore. Which tree she is tied to varies (**VERIFY**: bamboo, waru or another).

**SQ-S3 "Angklung yang Tercerai" / "The Scattered Angklung"** (errand, M)
- Giver: the leader of a village angklung group. Unlock: entering Tatar Sunda.
- Steps: (1) find 5 angklung scattered across the zone (each plays one note when picked up), (2) return them. The group plays a short piece with all 5 notes.
- Reward: **Flask Shard #1**, Ilmu M.
- Culture: each angklung sounds one note, so a tune needs every player. That is the point of the quest and the codex entry. Angklung is UNESCO 2010 (verified). **VERIFY** the traditional scale (pentatonic salendro/pelog vs the later diatonic angklung).

**SQ-S4 "Cepot Si Pemberani" / "Brave Cepot"** (errand, S, first-hour path)
- Giver: Cepot. Unlock: MQ1 step 1.1, so the quest system shows up early.
- Steps: (1) Cepot wants to prove he is brave and asks you to defeat 3 Wild Boar (was Maung, dropped with the tiger spirit, **ASSUMED** 2026-11-05) while he "supervises" from a tree, commenting on each kill, (2) report back.
- Reward: **Silver Bangle**, Ilmu S.
- Culture: Cepot's humor as in wayang golek. Barks are one-liners in both languages.

**SQ-S5 "Gema: Sangkuriang" / "Echo: Sangkuriang"** (echo, M; Story v2 2026-11-06)
- Giver: Dayang Sumbi, at the lake in ts_situ after MQ1 (cond `quest:mq1=done`). Naganingrum stood in her spot during MQ1.
- Steps: (1) ask the weaver for the boeh rarang, the cloth that makes a false dawn (`talked_to:sunda_weaver`), (2) stop Sangkuriang at the crater before the night ends (`boss_defeated:sangkuriang`, the old ts_kawah arena, his cond `quest:sq_s5=active`).
- Reward: lakon "Sangkuriang", Ilmu L, codex `sangkuriang`.
- Culture: the legend as before ([story.md](story.md)), now an echo the hero walks into. Same VERIFY notes as the old MQ1.

### Mataram
**SQ-M1 "Jaka Tarub dan Nawang Wulan" / "Jaka Tarub and Nawang Wulan"** (re-telling, M)
- Giver: Nawang Wulan, a quiet woman in a rice-farming household. Unlock: MQ2 step 2.1.
- Steps: (1) she says her rice pot's magic broke after someone lifted the lid, (2) search the lumbung (rice barn), (3) find her selendang (shawl) hidden under the last of the rice, (4) return it.
- Resolution: she returns to the sky, as in the legend, and leaves her weaving scarf behind as thanks.
- Reward: **Feather Charm**, **Herb Pouch #2**, lakon "Jaka Tarub", Ilmu M.
- Culture: one grain of rice filled the pot while the lid stayed closed. Jaka Tarub hid the shawl. Their daughter Nawangsih. Nawang Wulan is a bidadari (celestial maiden), not a deity, and shown with respect. **VERIFY** all beats and the legend's location.

**SQ-M2 "Wewe Gombel"** (bounty, two-way, L). Wewe Gombel moved to Mataram (decided 2026-11-05).
- Giver: a worried neighbor. Unlock: MQ2 step 2.2.
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
- Giver: Ki Dalang, the MQ2 teacher. Unlock: MQ2 step 2.2.
- Steps: (1) the village gamelan's gong ageng was carried off into the temple ruins, (2) fight through the Arca to find it, (3) bring it back. The zone music gains its gong layer from then on (a cheap audio-state change, strong payoff).
- Reward: **Blangkon**, Ilmu M.
- Culture: the gong ageng marks the end of the musical cycle (**VERIFY** wording). Gamelan is UNESCO 2021 (verified).

**SQ-M5 "Gema: Seribu Candi" / "Echo: A Thousand Temples"** (echo, M; Story v2 2026-11-06)
- Giver: the women at the lesung, after MQ2 step 2.5 (they still tell of the prince who tried to build a thousand temples in a night).
- Steps: (1) stop Bandung Bondowoso at the temples (`boss_defeated:bandung_bondowoso`, his cond `quest:sq_m5=active`). The women's rice-pounding makes the false dawn, as in the legend.
- Reward: lakon "Roro Jonggrang", Ilmu L, codex `roro_jonggrang`.
- Culture: same VERIFY notes as the old MQ2.

### Tanah Timur
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

### Segara Kidul (P1)
**SQ-K1 "Tukik Pulang ke Laut" / "Hatchlings Home to the Sea"** (errand, S)
- Giver: a fisher's child. Steps: (1) guide 5 turtle hatchlings past crabs and birds to the water (they move on their own, the player clears the path).
- Reward: **Herb Pouch #4**, Ilmu S.
- Culture: Java's south coast has real turtle nesting beaches (**VERIFY**: e.g. Pangumbahan, Sukamade). A conservation note in the codex.

**SQ-K2 sea spirit bounty** (bounty, L). Target: Bajul Putih Tua, an old white crocodile elite ([bestiary.md](bestiary.md) Zone 4). Reward: **Cakra** if the thrown archetype is built, otherwise Ilmu L x2.

## 6. Hub meta quests (Desa Purwa)
These grow with the content, so they reward the whole game without new systems.

### 6.1 SQ-D1 "Lakon" (the wayang stage)
- Giver: the Desa Purwa dalang who performs the prologue. Unlock: MQ0.
- Every finished re-telling (S1, M1, T1) and every echo and main-quest legend (Sangkuriang, Roro Jonggrang, Ciung Wanara, Timun Mas, Ken Arok) adds a lakon. 8 in total, plus the hero's own story at the end (Story v2).
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

Dialogue (`DialogueData`, one `.tres` per NPC in `data/dialogue/`, **ASSUMED** 2026-11-05): `npc_id`, `name_key`, `entries: Array[Dictionary]`, each `{"if": [conditions], "lines": [keys], "do": [actions]}`. The first entry whose conditions all hold plays; an entry with no `if` is the fallback and goes last.
- Conditions: `quest:<id>=<locked|available|active|done>`, `step:<id>=<n>` (0-based current step), `flag:<f>`, `!flag:<f>`, `glyph:<id>`, `item:<id>` (held).
- An entry with `"quiet": true` does not fire `talked_to` (a refusal that must not complete a talk step).
- Actions run when the box closes, in order: `start:<quest>`, `give:<item>`, `learn:<glyph>`, `flag:<f>`, `codex:<id>`. Then `talked_to:<npc_id>` fires.
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
Name entry -> prologue (5 cards, Laras is taken) -> class -> Ibu does not remember her -> Semar and Ka -> the faceless in the village -> the Hunter at the gate ("wrong child") -> west -> MQ1 steps 1.1-1.3 -> SQ-S4 Cepot -> glyph Ga. In the first 15 minutes the player knows who they are looking for, who took her and who else is hunted, and meets the quest arrow, a side quest start to finish, two glyphs and a codex entry (Story v2, 2026-11-06).

## 9. Scope
| Tier | Content |
|------|---------|
| P0 | Quest system (sections 7.1-7.7), main quest MQ0, MQ1, MQG, MQ2, MQ3 and MQ5, echoes SQ-S5 and SQ-M5, bilingual text for all of it, SQ-S4 (first-hour path) |
| P1 | All other side quests in Sunda, Mataram, Timur (11), hub meta quests, MQ4 and Segara Kidul quests, the headless quest check |
| P2 | Animated lakon performances, bonus glyphs from side quests, SQ-K2 Cakra reward |

Writing budget, rough: main quest about 120 dialogue lines, each side quest 15-30, so about 450 lines per language (**TUNE**).

## 10. VERIFY list for this file
Lutung Kasarung (cure at the spring, Guruminda, juru pantun role), kuntilanak's tree, angklung scale, Jaka Tarub (rice pot, lumbung, Nawangsih, location), Wewe Gombel folk practice of banging pots and returning children, tuyul distractions, gong ageng role, Ande-Ande Lumut (Yuyu Kangkang, sodo lanang, Panji link), Prambanan meteorite and pamor, turtle beaches, Roro Jonggrang's fake dawn (rice pounding, burning straw). Verified 2026-11-05: gejog lesung, Timun Mas (hermit, four pouches, Mbok Srini).

## 11. Open decisions and doc changes this implies
1. ~~Wewe Gombel to Mataram~~: decided yes (2026-11-05). Tatar Sunda's tank is Jurig Leuweung, a descriptive name kept on purpose ([bestiary.md](bestiary.md)).
2. **Sangkuriang's light glyph:** reuse Ca (Burst), no extra glyph (**ASSUMED** here).
3. **NPC names** (decided 2026-11-05, **ASSUMED**). Ordinary given names with the usual address: Abah (Sundanese elder), Ki (respected man, performers), Pak and Mbah (Javanese village), Mpu (smith), Nyai. **VERIFY** with a native speaker, and search each name so none matches a living dalang or juru kunci.

| Role | Name | Where |
|------|------|-------|
| Village elder (sesepuh) | Abah Karna | Tatar Sunda, MQ1 |
| Juru pantun | Ki Darsa | Tatar Sunda, SQ-S1 |
| Dalang | Ki Sumarto | Mataram, MQ2 |
| Stone-carver (pemahat batu) | Pak Karto | Mataram, MQ2 2.4 |
| Juru kunci | Mbah Marto | Mataram, MQ2 2.6 |
| Empu | Mpu Wirasana | Tanah Timur, MQ3 |
| Wayang stage dalang | Ki Wangsa | Desa Purwa, MQ0 |
| Codex keeper | Nyai Rukmi | Desa Purwa, SQ-D2 |
| Juru kunci of the coast | Mbah Wiryo | Segara Kidul, MQ4 4.2 |
4. Docs to sync: [scope.md](scope.md) (bilingual moves from P2 to P0, side quests are 3-4 per zone), [story.md](story.md) (side quest section now points here), [items.md](items.md) (add Lontar Kuno, Flask Shard, Herb Pouch; Golok and Spear sources), [architecture.md](architecture.md) (translation keys, `QuestData`, `data/quests/`, `data/text/`), [rpg.md](rpg.md) (flask max 6 charges, heal up to 60%).
