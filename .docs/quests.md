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
Six chapters, one per zone. The arrow always points at the current step. Glyphs are learned only here. Each glyph's teacher also speaks one hint about the enemy that glyph counters ([bestiary.md](bestiary.md) Glyph weaknesses). Objective lines below are journal text in both languages. Final dialogue goes in the string tables (section 7.7).

### MQ0 Prologue: "Wayang Terakhir" / "The Last Shadow Play" (Desa Purwa)
Teaches: movement, interacting, class choice, the first glyph, combat basics.

| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| 0.1 | Watch the wayang performance | Saksikan pertunjukan wayang | Prologue scene ends (Aji Saka legend, letters fade: the curse begins) |
| 0.2 | Speak with Semar | Bicara dengan Semar | `talked_to:semar` |
| 0.3 | Choose your class | Pilih kelasmu | `class_chosen` |
| 0.4 | Learn your first letter in the sanggar | Pelajari aksara pertamamu di sanggar | `glyph_learned:sunda_ka` (Semar teaches Ka, "the first letter of the west") |
| 0.5 | Cast Ka three times | Rapalkan Ka tiga kali | `spell_cast:sunda_ka` x3 |
| 0.6 | Defeat the training dummies | Kalahkan boneka latihan | `enemy_killed:dummy` x3 |
| 0.7 | Head west to Tatar Sunda | Pergilah ke barat, ke Tatar Sunda | `zone_entered:tatar_sunda` |

0.1-0.3 happen before the save exists (prologue, Semar's line, class cards), so New Game starts MQ0 at 0.4 with 0.1-0.3 already struck (**ASSUMED** 2026-11-05).

The Mataram gate east of the village stays fogged until MQ1 is done.

### MQ1 Act 1: "Perahu yang Tertelungkup" / "The Overturned Boat" (Tatar Sunda)
Premise: cursed by the forgetting, Sangkuriang does not remember that dawn already came long ago. He keeps damming the river and building his boat, and the valley floods. The hero must recreate the fake dawn from the legend so he can finally remember.

| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| 1.1 | Rest at the petilasan by the tea terraces | Beristirahat di petilasan dekat kebun teh | `petilasan_activated:sunda_1` (Cepot is here; SQ-S4 becomes available) |
| 1.2 | Find the village elder | Temui sesepuh kampung | `talked_to:sunda_elder` |
| 1.3 | Learn Ga from the elder | Pelajari Ga dari sesepuh | `glyph_learned:sunda_ga` |
| 1.4 | Clear the bandits and the Kuntilanak from the batu tulis in the bamboo grove | Usir perampok dan Kuntilanak dari batu tulis di rumpun bambu | `area_cleared:sunda_batutulis` |
| 1.5 | Read the batu tulis to learn Nga | Baca batu tulis untuk mempelajari Nga | `glyph_learned:sunda_nga` (the stone shows Ga beside Nga: "Nga is Ga without the box", [spells.md](spells.md) 5) |
| 1.6 | Find the weaver who keeps the boeh rarang | Temui penenun penyimpan boeh rarang | `item_picked:boeh_rarang` |
| 1.7 | Meet Dayang Sumbi's spirit at the lake shore | Temui arwah Dayang Sumbi di tepi danau | `talked_to:dayang_sumbi` (teaches Ca: "the light before dawn") |
| 1.8 | Climb to the crater rim | Daki ke bibir kawah | `petilasan_activated:sunda_2` |
| 1.9 | Free Sangkuriang from the forgetting | Bebaskan Sangkuriang dari lupa | `boss_defeated:sangkuriang` |
| 1.10 | Return to Semar | Kembali ke Semar | `talked_to:semar` (fog lifts on the Mataram gate) |

Boss link: in phase 2 the player hangs the boeh rarang on the east post of the arena (interact) and casts **Ca (Burst)** next to it to make the "fake dawn". This resolves the open question in [spells.md](spells.md) section 3: **reuse Ca, no extra glyph** (**ASSUMED**). Ending: Sangkuriang remembers, kicks the boat over, and it becomes Tangkuban Perahu, as in the legend. He is released, not killed.

Culture: boeh rarang is used because the fact-check found the cloth is red or boeh rarang depending on the retelling. Pick one, cite it in the codex.

### MQ2 Act 2: "Seribu Candi" / "A Thousand Temples" (Mataram)
Premise: Bandung Bondowoso, cursed by the forgetting, keeps raising temples with his spirit builders and never reaches a thousand. He forgets the bargain, the trick and the ending. The hero learns the Hanacaraka and helps the village women repeat Roro Jonggrang's own fake dawn: pounding rice in the lesung.

Culture point: Tatar Sunda and Mataram both have a fake-dawn legend (cloth and roosters, and rice pounding and burning straw). The codex links them.

| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| 2.1 | Rest at the petilasan by the rice fields | Beristirahat di petilasan dekat sawah | `petilasan_activated:mataram_1` |
| 2.2 | Hear the dalang's story of the Hanacaraka | Dengarkan kisah Hanacaraka dari Ki Dalang | `talked_to:mataram_dalang` (teaches Ha) |
| 2.3 | Wake the temple guardians at the ruins | Bangunkan penjaga candi di reruntuhan | `area_cleared:mataram_ruins` (Arca enemies) |
| 2.4 | Learn Na from the stone-carver | Pelajari Na dari pemahat batu | `glyph_learned:jawa_na` |
| 2.5 | Join the women at the lesung | Bergabunglah dengan para perempuan di lesung | `talked_to:lesung_women` (teaches Ca: the rhythm of gejog lesung, rice-pounding music of Central Java and Yogyakarta, verified) |
| 2.6 | Ask the juru kunci for the guardian's blessing | Mohon restu penjaga dari juru kunci | `glyph_learned:jawa_ra` (the tiger spirit) |
| 2.7 | Enter the temple courtyard | Masuki pelataran candi | `petilasan_activated:mataram_2` |
| 2.8 | Stop Bandung Bondowoso's endless building | Hentikan pembangunan tanpa akhir Bandung Bondowoso | `boss_defeated:bandung_bondowoso` (drops Baju Batik) |
| 2.9 | Return to Semar | Kembali ke Semar | `talked_to:semar` (fog lifts east; Semar hints the forgetting comes from something older in the east) |

Boss link: the lesung women keep pounding during the fight. At each "dawn" beat, pillars are briefly exposed, and the arena has the women's lesung at the edge as a visual timer (**ASSUMED**, fits the pillar mechanic in [bestiary.md](bestiary.md)).

Sensitivity: the 1000th statue is identified with Roro Jonggrang in the legend, and the real statue in Prambanan is of Durga. Do not show or name the Durga statue as an enemy or a prop to break. Roro Jonggrang appears only in the codex and in the dalang's telling.

### MQ3 Act 3: "Kutukan Sang Empu" / "The Smith's Curse" (Tanah Timur)
Premise: the keris of Mpu Gandring has woken as a wraith. The way to it crosses the savanna of Buto Ijo. Here the hero learns that the forgetting is fed by something older: Kala.

| # | Objective (EN) | Objective (ID) | Completes on |
|---|----------------|----------------|--------------|
| 3.1 | Rest at the petilasan on the savanna | Beristirahat di petilasan di sabana | `petilasan_activated:timur_1` |
| 3.2 | Find the empu at the forge | Temui sang empu di bengkel tempa | `talked_to:timur_empu` (tells the Gandring legend; SQ-T3 becomes available) |
| 3.3 | Help Mbok Srini find Timun Mas | Bantu Mbok Srini mencari Timun Mas | `talked_to:mbok_srini` (she gives the four pouches: cucumber seeds, needles, salt, terasi) |
| 3.4 | Defeat Buto Ijo | Kalahkan Buto Ijo | `boss_defeated:buto_ijo` (miniboss; each phase uses one pouch, as in [bestiary.md](bestiary.md)) |
| 3.5 | Learn from the empu how to break curse marks | Pelajari dari sang empu cara mematahkan tanda kutukan | `talked_to:timur_empu` + practice: `spell_cast` on a practice mark x2 |
| 3.6 | Rest before the shrine | Beristirahat sebelum candi | `petilasan_activated:timur_2` |
| 3.7 | Lay the cursed keris to rest | Tenangkan keris terkutuk | `boss_defeated:keris_gandring` |
| 3.8 | Speak with Semar about Kala | Bicara dengan Semar tentang Kala | `talked_to:semar` |

In the legend a hermit (pertapa) gives the four pouches; here Mbok Srini hands them on (**ASSUMED**). Mbok Srini, the hermit and the four items are verified (2026-11-05, 2+ sources). Timun Mas escapes, as in the legend. The player fights only Buto Ijo.

After 3.8: in a P0 build, the Gua Kala gate opens now. With P1, the Segara Kidul path opens and Gua Kala waits for MQ4.

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
| 5.1 | Enter Gua Kala | Masuki Gua Kala | `zone_entered:gua_kala` |
| 5.2 | Rest at the last petilasan | Beristirahat di petilasan terakhir | `petilasan_activated:kala_1` |
| 5.3 | Face Batara Kala | Hadapi Batara Kala | `boss_defeated:batara_kala` |
| 5.4 | Return to the wayang stage | Kembali ke panggung wayang | `zone_entered:desa_purwa` (epilogue, credits) |

Batara Kala is defeated in the sense of being calmed and turned back. The codex note on ruwatan from [story.md](story.md) applies. He is a deity figure, so he is not "killed".

**Post-game (ASSUMED):** after the credits the player wakes in Desa Purwa with every zone open, so unfinished side quests can still be done (never missable).

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
- Every finished re-telling (S1, M1, T1) and every main-quest legend (Sangkuriang, Roro Jonggrang, Timun Mas, Ken Arok) adds a lakon. 7 in total, plus the Aji Saka prologue.
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
| `alt` | for two-way steps: `{"enemy_killed:wewe_elite": "fight", "talked_to:wewe_parents_2": "peaceful"}`. Not built until Mataram (Tatar Sunda has no two-way quest) |
| `marker` | `{zone: "mataram", id: "wewe_hill"}` |
| `set_flag` | `mq2_2` |

Dialogue (`DialogueData`, one `.tres` per NPC in `data/dialogue/`, **ASSUMED** 2026-11-05): `npc_id`, `name_key`, `entries: Array[Dictionary]`, each `{"if": [conditions], "lines": [keys], "do": [actions]}`. The first entry whose conditions all hold plays; an entry with no `if` is the fallback and goes last.
- Conditions: `quest:<id>=<locked|available|active|done>`, `step:<id>=<n>` (0-based current step), `flag:<f>`, `!flag:<f>`, `glyph:<id>`.
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
- Target in another zone: the arrow points to the exit toward that zone. `Zones` already knows the adjacency, so a breadth-first search over 6 zones is enough.
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
MQ0 (prologue, class, glyph Ka) -> MQ1 steps 1.1-1.3 -> SQ-S4 Cepot (quest system, journal, toast, reward) -> glyph Ga. In the first 15 minutes a new player meets the main quest arrow, a side quest from start to finish, two glyphs and a folklore enemy with a codex entry. This is a good opening, not a demo path for judges (2026-11-05).

## 9. Scope
| Tier | Content |
|------|---------|
| P0 | Quest system (sections 7.1-7.7), main quest MQ0-MQ3 and MQ5, bilingual text for all of it, SQ-S4 (first-hour path) |
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
