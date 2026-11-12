# Quests

The main quest, all side quests, the reward economy and the quest system that runs them. Related: [story.md](story.md), [world.md](world.md), [bestiary.md](bestiary.md), [items.md](items.md), [spells.md](spells.md), [architecture.md](architecture.md).

Conventions as in [README.md](README.md): **ASSUMED**, **VERIFY**, **TUNE**. Every legend detail in this file is from general knowledge and is **VERIFY** unless it is already in the Nov 2026 fact-check (see [HANDOFF.md](HANDOFF.md) section 4).

## 1. Structure and Scope
| Topic | Specification |
|-------|---------------|
| Guidance | Quest journal in the Tab/Esc menu, Tracker Card on HUD top-left, soft edge-of-screen arrow with distance/zone label, and floating in-world diamond for the active objective |
| Main order | Fixed: Desa Purwa (Prologue, 12 steps), Tatar Sunda (Act I, 24 steps), Keraton Galuh (Act II, 20 steps), Mataram (Act III, 24 steps), Tanah Timur (Act IV, 22 steps), Desa Purwa (Interlude, 8 steps), Segara Kidul (Act V, 14 steps), Gua Kala (Act VI, 14 steps). Total: **138 main steps (~21.5 hours)**. Fog gates enforce regional gating |
| Anti-repetition | Each Act and boss features a distinct gameplay and narrative structure (Folklore Hunt, Rising Floodwaters, 3-Wing Palace Heist, Two-Front War & Night-Building Siege, 3-Zone Stalking Predator & 7-Generation Curse, Coastal Recovery & 3 Sacred Trials, 3-Realm Memory Descent & Dual Finale) |
| Side quest types | 4 distinct types: Folklore Re-tellings, Two-Way Spirit Investigations, Cultural Craft/World-State Quests, and Multi-Act Companion Chains (`SQ-C1`–`SQ-C4`). 20 side quests total (~7+ hours) |
| Missable | Never. No quest closes, fails, or times out. All stay accessible after their zone's boss and in post-game |
| Choices | **6 Major Choices** (one per Act) that ripple across quests, allies, boss mechanics, and the Epilogue, plus two-way side quest resolutions (peaceful vs. fight) |
| Dialogue depth | Main-path & camp talks up to **8–12 lines**; story beats **8–10 lines**; major NPCs and companions offer optional **"Ask about..."** (`"quiet": true`) topic branches |
| Language | All quest, dialogue, item, codex, and UI text in **Indonesian and English** via CSV tables |

## 2. Principles
1. **Every quest is a piece of culture.** A quest exists to deliver one legend, custom, object or place. If it would work just as well with generic fantasy names, cut it.
2. **Never repeat the same loop twice in a row.** Only folklore mystery bosses (`Sandekala` and specific two-way spirit bounties) use the classic Witcher Hunt loop. Other bosses use environmental progression, palace faction infiltration, war-front sieges, multi-zone stalking encounters, and cross-time sabotage.
3. **Laras is an active co-protagonist (`LC1`–`LC6`).** In every Act, Laras's playable chapter sets physical flags (`laras_key:<id>`, `laras_sabotage:<id>`) that unlock routes, shortcuts, or boss vulnerabilities for the hero.
4. **Respect the sensitivity rules.** Deities are never enemies. Semar is never hostile. Nyi Roro Kidul is never fought. Living rituals (Yadnya Kasada, sedekah laut, labuhan) are community backdrop only. Kuda lumping is shown as performance only. Tuyul is only a money-stealing child spirit.
5. **The legend is told, not changed.** Where the game adds something (the forgetting curse, a seal flaw), the codex says what is legend and what is game.

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

  - Keraton Galuh (`zone = "keraton_galuh"`) uses the Tatar Sunda row (**ASSUMED**), so the quest income in `balance_model.py` stays calibrated.
  - Gua Kala uses the Segara Kidul row (**ASSUMED**). MQ5 pays out after the final boss, so `balance_model.py` counts 0 for it.
- **A codex entry** about the legend, figure or object, with a source line.

### 3.2 Plus one key reward, from these pools
| Pool | What it does | Count | Why it scales |
|------|--------------|-------|---------------|
| **Gear** | Weapons, armor and accessories in [items.md](items.md). Quests and choices are the main source of pusaka gear; chests and secrets hold the rest | 12 from quests/choices | Gear is already data. A new item is one resource |
| **Flask Shard** | +1 max flask charge. Base 3, max 6 | 3 | Rewards exploration with survivability |
| **Herb Pouch** | +5% flask heal each. Base 40%, max 60% | 4 | Flask power grows without new systems |
| **Lakon** (wayang story) | Unlocks a performance at the Desa Purwa wayang stage (section 6.1) | 9 total | Feeds the hub meta quest |
| **Lontar Kuno** | Accessory: the "smudged" threshold drops from 0.65 to 0.60 (**TUNE**) | 1 | Helps casting without adding a glyph |

### 3.3 Where every reward comes from
| Reward | Source |
|--------|--------|
| Kujang | Tatar Sunda secret chest |
| Golok | SQ-S2 Kuntilanak bounty |
| Spear (ex-Tombak) | SQ-M3 Tuyul bounty |
| Panah Pasopati | Mataram secret chest |
| Keris Luk 7 | SQ-T3 Pamor errand |
| Keris Mpu Gandring | Choice 4 (`choice_reforge`, MQ3) |
| Batu Kali | Choice 4 (`choice_sink`, MQ3) |
| Sabuk Galuh | Choice 3 (`choice_judgment`, MQ2, **ASSUMED**) |
| Cakra | SQ-K2 Bajul Putih Tua bounty (or Ilmu L x2) |
| Iket Sunda | SQ-S1 Lutung Kasarung |
| Blangkon | SQ-M4 Gamelan errand |
| Baju Batik | Main quest, Bandung Bondowoso (MQ2) |
| Kain Hijau | Main quest, Segara Kidul trial (MQ4) |
| Silver Bangle | SQ-S4 Cepot (SQ-C4 Part 1) |
| Feather Charm | SQ-M1 Jaka Tarub |
| Jimat | SQ-M2 Wewe Gombel |
| Stone Ring | SQ-T1 Ande-Ande Lumut |
| Lontar Kuno | SQ-D2 Pustaka, at 50% codex |
| Flask Shard x3 | SQ-S3 Angklung, SQ-T4 Kuda Kepang, SQ-D1 Lakon (4 lakon) |
| Herb Pouch x4 | SQ-S2, SQ-M1, SQ-T2, SQ-K1 |

---

## 4. Main quest (Story v5: 138 steps, ~21.5 hours)
[story.md](story.md) is the canon. Every step table has a `Play` column checked by `python3 .docs/pacing_model.py`.

| Quest | Part | Areas | Chapters | Steps | Target Min | Region |
|-------|------|-------|----------|-------|------------|--------|
| MQ0 | Prologue "The Last Ordinary Day" | 1 | 3 | 12 | 80 | Desa Purwa |
| MQ1 | Act I "Segel Kawah" | 8 | 5 | 24 | 210 | Tatar Sunda |
| MQG | Act II "Wajah Pinjaman" | 7 | 4 | 20 | 175 | Keraton Galuh |
| MQ2 | Act III "Darah di Pamali" | 8 | 5 | 24 | 220 | Mataram |
| MQ3 | Act IV "Bilah Tujuh Turunan" | 8 | 5 | 22 | 205 | Tanah Timur |
| MQ4 | Interlude "Rumah yang Sunyi" (4.1–4.8) & Act V "Laut Tak Pernah Lupa" (4.9–4.22) | 1 + 7 | 2 + 4 | 8 + 14 (22) | 45 + 160 (205) | Desa Purwa, Segara Kidul |
| MQ5 | Act VI "Ke Rahang Sang Waktu" | 7 | 4 | 14 | 160 | Gua Kala |
| **Total** | | **46 story areas (49 scenes with the dev rooms)** | **32** | **138** | **1,255 target (+15 epilogue = 1,270); modeled 1,285** | |

### Earned Glyphs Table
| Glyph | Deed (comes first) | Glyph step |
|-------|--------------------|------------|
| Sunda `Ka` (Bolt) | Pull Laras's half-lontar from the burned stage (`0.10`) | `0.11` Semar |
| Sunda `Ga` (Ward) | Defend the kampung against the Faceless & boar raid (`1.4`) | `1.5` the kampung elder |
| Sunda `Nga` (Bind) | Solve the three name-stones and read the defaced Batu Tulis (`1.11`–`1.12`) | `1.12` read in place |
| Sunda `Ca` (Burst) | Clear the flooded lakeshore of `ts_situ` (`1.18`) | `1.19` Dewi Naganingrum |
| Jawa `Ha` (Heal) | Save Ki Sumarto's market stage from war looters (`2.3`) | `2.4` Ki Sumarto |
| Jawa `Na` (Dash-strike) | Defeat the awakened stone guardians in `mt_reruntuhan` (`2.6`) | `2.6` read off `arca_base` |
| Jawa `Ca` (Rally) | Cleanse the desecrated war graves and reclaim the lesung yard (`2.7`–`2.9`) | `2.10` Nyai Gendhis & the lesung women |
| Jawa `Ra` (Summon) | Break the night-builder siege on the foothill shrine (`2.11`) | `2.12` the juru kunci |
| Jawa `Ka` (Ombak) | Pass all Three Sacred Trials of Segara Kidul (`4.14`, `4.17`, `4.21`) | `4.22` the Sea Altar |

### Six Major Choices Table
| Act | Choice | Flags | Gameplay & Story Ripples |
|-----|--------|-------|--------------------------|
| **Act I** | **Choice 1: Naganingrum's Secret** (`1.24`, beat `naga`) | `choice_tell_ciung` / `choice_keep_secret` | **Tell Ciung:** Ciung reconciles with Naganingrum at the crater; she blesses your lontar (`+10% Sunda Ca radius`) and sends lake-wardens to help in Act II's cell yard. **Keep Secret:** Ciung gains `+15% ally damage` in Galuh bouts, and they reunite in the Epilogue |
| **Act II** | **Choice 2: The Faceless Deserter** (`g.15`, Ranga) | `choice_freed` / `choice_handed` | **Freed:** Ranga scouts for you in Acts III–V (`SQ-C3`) and fights at `gk_pelataran` in Act VI. **Handed:** Lengser extracts the Candi Seribu camp layout in Act III (opens `sc:mt_candi_crypt` early and removes 1 camp wave) |
| **Act III** | **Choice 3: Judgment at the Pamali** (`2.24`, beat `truce`) | `choice_mercy` / `choice_judgment` | **Mercy:** Warm letter in `SQ-C2`, Hariang Banga brings Mataram lancers to Act IV's shrine assault, warm Interlude dinner. **Judgment:** Grants **Sabuk Galuh** defense ward, and Ciung's royal vanguard reinforces `gk_pelataran` in Act VI |
| **Act IV** | **Choice 4: Keris Mpu Gandring** (`3.20`, beat `keris`) | `choice_reforge` / `choice_sink` | **Reforge:** Grants **Keris Mpu Gandring** weapon; Ratna tempers your blade in Epilogue. **Sink:** Grants **Batu Kali** accessory; cursed wisps in Tanah Timur become peaceful fireflies |
| **Act V** | **Choice 5: The Sea's Offering** (`4.19`, cliff shrine) | `choice_offer_memory` / `choice_offer_song` | **Offer Memory:** *Ombak* costs 3 less Sakti and deals `+20% poise damage` in Act VI. **Offer Song:** Grants **Berkah Pesisir** ward blessing (1 auto-revive shield in Act VI) and coastal singers in Epilogue |
| **Act VI** | **Choice 6: Aria Kebonan's Name** (`5.2`, `gk_pelataran`) | `choice_redeem_aria` / `choice_release_aria` | **Redeem Aria:** Aria's shadow manifests in Phase 3 of Batara Kala, adding `+6 s` to the Ruwatan countdown. **Release Aria:** Grants **Keteguhan Sunyi** (`+15% stamina & sakti regen` in final boss) |

---

### MQ0 Prologue: "Hari Biasa Terakhir" / "The Last Ordinary Day" (Desa Purwa, 12 steps, ~80 min)
Regional character: **Ibu**. Chapters: Morning and Market, The Sanggar and the Ruwatan Night, The Morning After.

| # | Objective (EN) | Objective (ID) | Completes on | Play |
|---|----------------|----------------|--------------|------|
| **Ch 1** | **Pagi dan Pasar / Morning and Market** | | | |
| 0.1 | Catch Laras: she dares you to a game of tag across Desa Purwa | Tangkap Laras: dia menantangmu bermain kejar-kejaran melintasi Desa Purwa | `area_entered:purwa_tag_end`, sets `mq0_d1` (teaches move and dodge; Laras calls a stray cat and the old banyan by their true names) | `setpiece, talk` |
| 0.2 | Share morning tea with Ibu and hear the old couple's request | Minum teh pagi bersama Ibu dan dengarkan permintaan pasangan tua di sebelah | `talked_to:ibu`, sets `mq0_d2` (two cups set out); then `talked_to:purwa_old_couple`, sets `mq0_d2b` | `talk x2, clue, beat` |
| 0.3 | Climb the banyan ridge and fetch Ciung Wanara and his strange egg | Daki punggung beringin dan jemput Ciung Wanara beserta telurnya yang aneh | `puzzle_solved:purwa_banyan_climb`; then `talked_to:ciung_wanara`, sets `mq0_d3` (Laras: "Ciung isn't his whole name") | `travel, puzzle, talk` |
| 0.4 | Walk the morning market and ask the stall-keeper about the masked stranger, then find Cepot at the sanggar door | Susuri pasar pagi dan tanya penjaga lapak soal orang bertopeng, lalu temui Cepot di depan pintu sanggar | `talked_to:purwa_stall`; then `talked_to:cepot`, sets `mq0_d6` (the stall-keeper describes a tall man in a blank mask asking children's names; Cepot hurries everyone inside) | `travel, clue, talk x2` |
| **Ch 2** | **Sanggar dan Malam Ruwatan / The Sanggar and the Ruwatan Night** | | | |
| 0.5 | Meet Semar and Cepot inside the sanggar | Temui Semar dan Cepot di dalam sanggar | `talked_to:semar`, sets `mq0_d4`; then `talked_to:cepot`, sets `mq0_d4b` (Semar: a written name keeps a person in the world; Cepot fusses over the lamps) | `travel, talk x2, fight x2` |
| 0.6 | Write your name and Laras's name at opposite ends of her palm-leaf lontar | Tuliskan namamu dan nama Laras di kedua ujung daun lontarnya | `area_entered:sanggar_lontar`, sets `mq0_d5` | `puzzle, write, beat` |
| 0.7 | Help light the four ceremonial oil lamps around the wayang stage at dusk | Bantu nyalakan empat lampu minyak upacara di sekeliling panggung wayang saat senja | `puzzle_solved:purwa_stage_lamps`, sets `mq0_d6b` | `travel, puzzle, talk` |
| 0.8 | Play Semar's wayang ruwatan behind the lit kelir (`K0`) | Mainkan wayang ruwatan Semar di balik kelir yang menyala (`K0`) | `memory_done:k0_ruwatan`, sets `mq0_d7` (teaches Kelir light mechanics, Batara Kala, and the Four Great Seals) | `memory, beat` |
| **Ch 3** | **Pagi Setelahnya / The Morning After** | | | |
| 0.9 | Fight through the panicking crowd to reach Laras as shadows step off the screen | Terobos kerumunan yang panik untuk mencapai Laras saat bayangan turun dari layar | `area_entered:purwa_crowd`, sets `mq0_d8` (plays beat `raid`: Laras whispers "Aria"; the Hunter takes her and tears the lontar) | `setpiece, beat` |
| 0.10 | Wake in the quiet house, speak with Ibu by the two cups, and pull Laras's half-lontar from the burned stage | Bangun di rumah yang sunyi, bicara dengan Ibu di dekat dua cangkir, dan ambil separuh lontar Laras dari panggung terbakar | `talked_to:ibu`, sets `mq0_4`; then `item_picked:laras_lontar`, sets `mq0_5` | `talk, beat, clue, travel` |
| 0.11 | Bring the torn lontar to Semar, learn Sunda Ka, and practice casting it in the sanggar | Bawa lontar yang robek kepada Semar, pelajari Sunda Ka, dan berlatih merapalkannya di sanggar | `glyph_learned:sunda_ka`; then `spell_cast:sunda_ka` x3 | `talk, lesson, fight x2` |
| 0.12 | Drive the Faceless raiders from the village square and confront the Hunter's shadow at the west gate | Usir penyerbu Tanpa Rupa dari alun-alun desa dan hadapi bayangan sang Pemburu di gerbang barat | `area_cleared:purwa_raid`, sets `mq0_7`; then `zone_entered:ts_kebun` (after beat `hunter_raid` & clue `mask_gate`) | `fight x2, beat, travel` |

---

### MQ1 Act I: "Segel Kawah" / "The Crater Seal" (Tatar Sunda, 24 steps, 5 chapters, ~210 min)
Structure: **Folklore Investigation Hunt (`Sandekala`) + Rising Floodwaters & Cross-Time Seal Sabotage (`Captain` & `Sangkuriang`)**. Regional character: **Dewi Naganingrum**. Ally: **Ciung Wanara**.

| # | Objective (EN) | Objective (ID) | Completes on | Play |
|---|----------------|----------------|--------------|------|
| **Ch 1** | **Daun Teh dan Jejak Bambu / Tea and the Bamboo Trail** | | | |
| 1.1 | **Arrival.** Walk the dawn tea terraces (`ts_kebun`), meet the elder's grandson, and break the ambush where Laras dropped her ribbon | Susuri kebun teh saat fajar (`ts_kebun`), temui cucu sesepuh, dan patahkan penyergapan di tempat Laras menjatuhkan pitanya | `talked_to:sunda_grandson`, sets `mq1_a1`; then `area_cleared:sunda_edge`; then `clue_examined:laras_ribbon_spot` | `talk, travel, fight, clue` |
| 1.2 | Follow the broken bamboo trail across the upper slopes and clear the Faceless scout camp | Ikuti jejak bambu patah melintasi lereng atas dan bersihkan perkemahan pengintai Tanpa Rupa | `area_cleared:sunda_kebun_camp`, sets `mq1_a2` | `travel, fight x2, clue` |
| 1.3 | Rest at the terrace petilasan (`sunda_1`), speak with Cepot, and scout the road to the kampung | Beristirahat di petilasan kebun teh (`sunda_1`), bicara dengan Cepot, dan intai jalan menuju kampung | `petilasan_activated:sunda_1`, sets `mq1_1`; then `talked_to:cepot` | `travel, talk x2, fight` |
| 1.4 | Defend `ts_kampung` from the Faceless and wild boar raiding party | Pertahankan `ts_kampung` dari serangan Tanpa Rupa dan babi hutan | `area_cleared:sunda_kampung`, sets `mq1_2` | `fight x2, miniboss, beat` |
| 1.5 | Speak with the kampung elder to learn Sunda Ga, then follow a mother's cries toward the river gorge | Bicara dengan sesepuh kampung untuk mempelajari Sunda Ga, lalu ikuti tangisan seorang ibu menuju ngarai sungai | `glyph_learned:sunda_ga`, sets `mq1_3`; then `area_entered:sunda_hamlet`, sets `mq1_h1` | `talk, lesson, travel, beat` |
| **Ch 2** | **Roh Senja di Ngarai / The Dusk Spirit of the Gorge (Hunt K1)** | | | |
| 1.6 | Speak with the distraught mother at the gorge hamlet and search the dusk riverbank | Bicara dengan ibu yang cemas di dusun ngarai dan periksa tepi sungai saat senja | `talked_to:leuwi_mother`, sets `mq1_h1b`; then `clue_examined:sandal` | `talk, travel, fight, clue` |
| 1.7 | Examine the unlit maghrib oncor torches and the split tracks of Laras and Ciung in the gorge | Periksa obor oncor maghrib yang padam serta jejak terpisah Laras dan Ciung di ngarai | `all`: `clue_examined:oncor`, `clue_examined:gorge_prints`; sets `mq1_h2` | `travel, puzzle, clue x2` |
| 1.8 | Relight the outer hamlet bamboo lanterns to push back the encroaching dusk mist | Nyalakan kembali lentera bambu luar dusun untuk menghalau kabut senja yang merayap | `puzzle_solved:leuwi_outer_oncor`, sets `mq1_h2b` | `puzzle, fight x2, beat` |
| 1.9 | **K1 Memory.** Follow the lontar's pull: a child hurrying home at maghrib | Ikuti tarikan lontar: seorang anak yang bergegas pulang saat maghrib | `memory_done:k1_maghrib`, sets `mq1_h3` (teaches lighting the four oncor to banish Sandekala's shadow) | `memory, talk` |
| 1.10 | Defeat Sandekala in the river gorge by keeping the four oncor lit | Kalahkan Sandekala di ngarai sungai dengan menjaga keempat oncor tetap menyala | `boss_defeated:sandekala`, sets `mq1_3b` (rescues the hamlet children; Laras's tracks climb to `ts_leuweung`) | `boss, beat` |
| **Ch 3** | **Batu yang Dirusak dan Teras Sawah / The Defaced Stone and the Terraces** | | | |
| 1.11 | Climb into the deep forest (`ts_leuweung`), clear the spirit ambush, and align the three ancient name-stones | Daki ke hutan lebat (`ts_leuweung`), bersihkan penyergapan roh, dan selaraskan tiga batu nama kuno | `area_cleared:sunda_batutulis`; then `puzzle_solved:batu_stones_123`, sets `mq1_4` | `travel, fight x2, puzzle` |
| 1.12 | Read the defaced Batu Tulis where Laras carved her warning, and learn Sunda Nga | Baca Batu Tulis yang dirusak tempat Laras mengukir peringatannya, dan pelajari Sunda Nga | `glyph_learned:sunda_nga`, sets `mq1_5` (*"They need me to read"*) | `clue, lesson, beat, fight` |
| 1.13 | Descend to the rice terraces (`ts_sawah`), where Sangkuriang's waking curse is flooding the valley | Turun ke teras sawah (`ts_sawah`), tempat kutukan Sangkuriang yang bangkit mulai merendam lembah | `area_entered:sawah_flood_vista`, sets `mq1_5b` | `travel, fight x2, clue` |
| 1.14 | Drive the Faceless and Jurig Leuweung pack off the Weaver's terraces | Usir kawanan Tanpa Rupa dan Jurig Leuweung dari teras sawah Penenun | `area_cleared:sunda_terraces`, sets `mq1_5c` | `fight x2, miniboss, talk` |
| 1.15 | Open the two upper sluice wheels to drain the flooded paddy road and receive the Boeh Rarang from the Weaver | Buka dua roda pintu air atas untuk menyurutkan jalan sawah yang terendam dan terimalah Boeh Rarang dari Penenun | `puzzle_solved:sawah_sluices`; then `talked_to:sunda_weaver`, sets `mq1_6` | `puzzle, talk, beat` |
| **Ch 4** | **Ratu Terbuang di Tepi Danau / The Exiled Queen by the Lake** | | | |
| 1.16 | Follow the dammed river channel toward the rising lake (`ts_situ`) | Ikuti aliran sungai yang dibendung menuju danau yang meluap (`ts_situ`) | `area_cleared:sunda_lake_approach`, sets `mq1_6a` | `travel, fight x2, talk` |
| 1.17 | Inspect the felled giant trees and empty rooster coops along the flooded shore | Periksa pepohonan raksasa yang ditebang dan kandang ayam yang kosong di sepanjang tepi danau | `all`: `clue_examined:felled_trees`, `clue_examined:empty_coops`, `clue_examined:loom`; sets `mq1_h4` | `clue x3, fight` |
| 1.18 | Clear the lakeshore garrison and examine the carved wooden toy dropped by a fallen Faceless | Bersihkan garnisun tepi danau dan periksa mainan kayu ukir yang dijatuhkan seorang Tanpa Rupa | `area_cleared:sunda_lakeshore`, sets `mq1_6b`; then `clue_examined:faceless_toy`, sets `mq1_h5` | `fight, miniboss, clue` |
| 1.19 | Speak with Dewi Naganingrum in exile by the lake and learn Sunda Ca | Bicara dengan Dewi Naganingrum di pengasingan tepi danau dan pelajari Sunda Ca | `glyph_learned:sunda_ca`, sets `mq1_7` (**The Turn:** Ciung is her lost royal son; opens the crater road) | `talk, beat, lesson, fight` |
| **Ch 5** | **Air yang Naik dan Segel Kawah / The Rising Waters and the Crater Seal** | | | |
| 1.20 | Fight up the volcanic crater road (`ts_kawah_jalan`) and rest at the upper petilasan (`sunda_2`) | Bertempur mendaki jalan kawah gunung (`ts_kawah_jalan`) dan beristirahat di petilasan atas (`sunda_2`) | `area_cleared:sunda_crater`; then `petilasan_activated:sunda_2`, sets `mq1_7b` | `travel, fight x2, talk` |
| 1.21 | **LC1 Cross-Time Chapter.** Play Laras on the crater rim: sabotage the seal-stone groove and mark the eastern post | **Bab Lintas-Waktu LC1.** Mainkan Laras di bibir kawah: sabotase alur batu segel dan tandai tiang timur | `memory_done:lc1`, sets `mq1_lc`, `laras_sabotage:crater_seal`, `laras_key:crater_post` | `chapter, puzzle` |
| 1.22 | Defeat the Faceless Captain on the crater rim and witness Hunter Memory `H1` ("The Kind King") | Kalahkan Kapten Tanpa Rupa di bibir kawah dan saksikan Ingatan Pemburu `H1` ("Raja yang Baik") | `boss_defeated:faceless_captain`, sets `mq1_8`; then `memory_done:h1`, sets `mq1_h7` | `boss, beat, clue` |
| 1.23 | **K2 Memory.** Experience Dayang Sumbi's night as the cracked Crater Seal breaks | Alami malam Dayang Sumbi saat Segel Kawah yang retak pecah | `memory_done:k2_dayang_sumbi`, sets `mq1_h6` (teaches hanging the Boeh Rarang on the eastern post and casting Ca) | `memory, beat` |
| 1.24 | Defeat Sangkuriang with the false dawn, free Ciung Wanara and Nagawiru, and make **Choice 1** | Kalahkan Sangkuriang dengan fajar palsu, bebaskan Ciung Wanara dan Nagawiru, lalu tentukan **Pilihan 1** | `boss_defeated:sangkuriang`, sets `mq1_9` (beat `naga` presents **Choice 1**: `choice_tell_ciung` / `choice_keep_secret`, sets `mq1_10`) | `boss, setpiece, beat, talk` |

---

### MQG Act II: "Wajah Pinjaman" / "The Borrowed Face" (Keraton Galuh, 20 steps, 4 chapters, ~175 min)
Structure: **Undercover Palace Intrigue, 3-Wing Faction Heist & Throne-Room Coup** across **7 areas** (`kg_alun`, `kg_pasar` **[NEW]**, `kg_pustaka` **[NEW]**, `kg_kaputren` **[NEW]**, `kg_keraton`, `kg_penjara`, `kg_pamali`). Regional characters: **Uwa Lengser**, **Nyai Sekar**, **Ranga (the Deserter)**. Ally: **Ciung Wanara**.

| # | Objective (EN) | Objective (ID) | Completes on | Play |
|---|----------------|----------------|--------------|------|
| **Ch 1** | **Hari Sayembara dan Pasar Kuta / Tournament Day and Pasar Kuta** | | | |
| g.1 | **Arrival.** Enter the royal square (`kg_alun`) on tournament day and plan the undercover infiltration with Ciung Wanara | Masuki alun-alun kerajaan (`kg_alun`) pada hari sayembara dan susun rencana penyusupan bersama Ciung Wanara | `talked_to:galuh_seller`, sets `mqg_a1`; then `talked_to:ciung_wanara`, sets `mqg_0` | `travel, talk x2, beat` |
| g.2 | Scout Pasar Kuta (`kg_pasar`) to learn how the Faceless bring captives through the city gates | Intai Pasar Kuta (`kg_pasar`) untuk mencari tahu bagaimana Tanpa Rupa membawa tawanan melewati gerbang kota | `talked_to:pasar_informant`; then `clue_examined:wagon_manifest`, sets `mqg_p1` | `travel, talk, clue, fight` |
| g.3 | Expose and defeat the king's tournament riggers hiding in the market storehouse | Bongkar dan kalahkan para kecurangan sayembara raja yang bersembunyi di gudang pasar | `area_cleared:galuh_market_riggers`, sets `mqg_p2` | `fight x2, miniboss, talk` |
| g.4 | Win both bouts of the royal tournament in `kg_alun` to earn an audience inside the palace walls | Menangkan kedua babak sayembara kerajaan di `kg_alun` untuk mendapatkan izin masuk ke dalam tembok istana | `area_cleared:galuh_bout_1`, sets `mqg_1`; then `area_cleared:galuh_bout_2`, sets `mqg_2` | `setpiece, fight x2, beat` |
| g.5 | Speak with old chamberlain Uwa Lengser and enter the inner palace garden (`galuh_1`) | Bicara dengan abdi tua Uwa Lengser dan masuki taman dalam istana (`galuh_1`) | `talked_to:lengser`, sets `mqg_3`; then `petilasan_activated:galuh_1`, sets `mqg_4` | `talk, travel, puzzle` |
| **Ch 2** | **Balai Pustaka dan Kaputren / The Royal Archive and the Kaputren** | | | |
| g.6 | Infiltrate the Balai Pustaka (`kg_pustaka`, Royal Archive) and meet archivist Nyai Sekar | Menyusup ke Balai Pustaka (`kg_pustaka`) dan temui juru arsip Nyai Sekar | `area_cleared:pustaka_guards`; then `talked_to:nyai_sekar`, sets `mqg_ar1` | `travel, fight, talk` |
| g.7 | Solve the archive mirror-lamp cipher to uncover the scraped royal lontar of King Nagawiru | Pecahkan sandi lampu-cermin arsip untuk mengungkap lontar kerajaan Prabu Nagawiru yang dikerik | `puzzle_solved:pustaka_cipher`; then `clue_examined:scraped_genealogy`, sets `mqg_ar2` | `puzzle, clue, talk` |
| g.8 | Cross the guarded colonnade into the Kaputren (`kg_kaputren`, Royal Quarters) | Seberangi serambi yang dijaga menuju Kaputren (`kg_kaputren`, Keputren Kerajaan) | `area_cleared:kaputren_courtyard`, sets `mqg_kp1` | `travel, fight, miniboss, clue` |
| g.9 | Search the locked guest chamber in the Kaputren where Laras was held before her transfer | Periksa kamar tamu terkunci di Kaputren tempat Laras ditahan sebelum dipindahkan | `puzzle_solved:kaputren_screens`; then `clue_examined:laras_hairpin`, sets `mqg_kp2` | `puzzle, clue, beat` |
| g.10 | Overhear Prince Hariang Banga and the Queen's attendants, then unlock the passage to the prison yard | Dengarkan pembicaraan Pangeran Hariang Banga dan para dayang Ratu, lalu buka lorong menuju halaman penjara | `area_entered:kaputren_eavesdrop`, sets `mqg_kp3` | `travel, talk, beat, fight` |
| **Ch 3** | **Penyergapan di Halaman Penjara / The Cell-Yard Ambush and Escape** | | | |
| g.11 | Fight down the dungeon stairs (`kg_penjara`) as the prisoner wagon prepares to depart | Bertempur menuruni tangga penjara (`kg_penjara`) saat kereta tahanan bersiap berangkat | `area_cleared:penjara_stairs`, sets `mqg_4a` | `travel, clue, fight x2` |
| g.12 | **Wagon Setpiece.** Battle the Faceless escort in the cell yard as Laras's wagon escapes east | **Adegan Kereta.** Lawan pengawal Tanpa Rupa di halaman penjara saat kereta Laras meloloskan diri ke timur | `area_cleared:galuh_escort`, sets `mqg_4b` (a lontar strip with *Ka* flies over the wall) | `setpiece, fight, beat` |
| g.13 | Clear the inner dungeon cells and read Laras's message scratched into the stone wall | Bersihkan sel penjara dalam dan baca pesan Laras yang digoreskan di dinding batu | `area_cleared:galuh_cells`, sets `mqg_5` (*"The thousand temples. Don't stop."*) | `fight x2, clue, talk` |
| g.14 | **LC2 Cross-Time Chapter.** Play Laras in the Kaputren & wagon: steal the king's signet wax and unbolt the archive drainage grate | **Bab Lintas-Waktu LC2.** Mainkan Laras di Kaputren & kereta: curi lilin segel raja dan buka jeruji saluran arsip | `memory_done:lc2`, sets `mqg_lc`, `laras_sabotage:glamour_seal`, `laras_key:archive_grate` | `chapter, puzzle` |
| g.15 | Confront Ranga, the Faceless Deserter who guarded Laras, and make **Choice 2** | Hadapi Ranga, Pembelot Tanpa Rupa yang menjaga Laras, dan tentukan **Pilihan 2** | `talked_to:faceless_deserter`, sets `mqg_6` (**Choice 2**: `choice_freed` / `choice_handed`) | `talk, beat, clue, fight` |
| **Ch 4** | **Kudeta di Ruang Takhta / The Coup in the Throne Room** | | | |
| g.16 | Use Laras's unlocked archive grate (`laras_key:archive_grate`) to enter the upper palace gallery (`kg_keraton`) | Gunakan jeruji arsip yang dibuka Laras (`laras_key:archive_grate`) untuk memasuki galeri atas istana (`kg_keraton`) | `area_entered:keraton_upper_gallery`, sets `mqg_6b` | `travel, puzzle, fight` |
| g.17 | Examine the defaced royal portrait and relive Uwa Lengser's memory `K-II` ("The Night of the Mask") | Periksa lukisan potret raja yang dirusak dan alami kenangan Uwa Lengser `K-II` ("Malam Topeng") | `clue_examined:court_portrait`, sets `mqg_h1`; then `memory_done:k_ii`, sets `mqg_h2` | `clue, memory, talk` |
| g.18 | Take the second mask fragment behind the throne and witness Hunter Memory `H2` ("The Borrowed Face") | Ambil pecahan topeng kedua di balik takhta dan saksikan Ingatan Pemburu `H2` ("Wajah Pinjaman") | `memory_done:h2`, sets `mqg_h3` | `clue, memory, beat` |
| g.19 | Rally Lengser's palace guards and Ciung Wanara to breach the throne room | Kerahkan pengawal istana Lengser dan Ciung Wanara untuk mendobrak ruang takhta | `area_cleared:keraton_throne_approach`, sets `mqg_6c` | `fight x2, miniboss, talk` |
| g.20 | Unmask and defeat Prabu Barma Wijaya in the throne room | Buka kedok dan kalahkan Prabu Barma Wijaya di ruang takhta | `boss_defeated:barma_wijaya`, sets `mqg_7` (Laras's `laras_sabotage:glamour_seal` makes his Glamour illusions crack in one glyph hit; beats `confession`, `cage`, `escape` follow) | `boss, setpiece, beat x2` |

---

### MQ2 Act III: "Darah di Pamali" / "Blood on the Pamali" (Mataram, 24 steps, 5 chapters, ~220 min)
Structure: **Two-Front War Campaign, Real-Time Night-Building Siege (`Bandung Bondowoso`) & River-Ford Duel (`Hariang Banga`)**. Regional characters: **Ki Sumarto** and **Nyai Gendhis**.

| # | Objective (EN) | Objective (ID) | Completes on | Play |
|---|----------------|----------------|--------------|------|
| **Ch 1** | **Garis Perang Dua Tepi / The Two-Bank War Front** | | | |
| 2.1 | **Arrival.** Cross into `mt_gapura`, hear both armies' recruiters at the border market, and see the overnight stone pillars | Seberangi ke `mt_gapura`, dengarkan perekrut kedua pasukan di pasar perbatasan, dan lihat pilar batu yang tumbuh semalam | `all`: `talked_to:recruiter_a`, `talked_to:recruiter_b`; sets `mq2_a1` | `travel, talk x2, beat` |
| 2.2 | Break the deserter-looter blockade at the border gate and rest at the market petilasan (`mataram_1`) | Patahkan blokade penjarah di gerbang perbatasan dan beristirahat di petilasan pasar (`mataram_1`) | `area_cleared:mataram_gerbang`; then `petilasan_activated:mataram_1`, sets `mq2_1` | `fight x2, travel, talk` |
| 2.3 | Defend dalang Ki Sumarto's wayang stage in `mt_pasar` from war-profiteers and Tuyul swarms | Pertahankan panggung wayang Ki Sumarto di `mt_pasar` dari penjarah perang dan kawanan Tuyul | `area_cleared:mataram_pasar`, sets `lead_pasar` | `setpiece, fight x2` |
| 2.4 | Speak with Ki Sumarto about his son Sapto, learn Jawa Ha, and map the three leads across Mataram | Bicara dengan Ki Sumarto tentang putranya Sapto, pelajari Jawa Ha, dan petakan tiga petunjuk di Mataram | `glyph_learned:jawa_ha`, sets `mq2_2` | `talk, lesson, clue, fight` |
| 2.5 | Escort the displaced market families across the flooded paddies of `mt_sawah` | Kawal keluarga pasar yang mengungsi melintasi sawah `mt_sawah` | `area_cleared:mataram_sawah_road`, sets `mq2_2b` | `travel, fight x2, talk` |
| **Ch 2** | **Tiga Petunjuk di Reruntuhan / Three Leads in the Ruins** | | | |
| 2.6 | **Lead 1 (The Ruins).** Defeat the awakened Arca guardians in `mt_reruntuhan` and read Jawa Na off the ancient statue base | **Petunjuk 1 (Reruntuhan).** Kalahkan penjaga Arca yang bangkit di `mt_reruntuhan` dan baca Jawa Na dari dasar patung kuno | `area_cleared:mataram_ruins`, sets `lead_ruins`; then `glyph_learned:jawa_na`, sets `mq2_3` | `travel, clue, fight, miniboss, lesson` |
| 2.7 | **Lead 2 (The Graveyard).** Cleanse `mt_kuburan` where the Hunter's servants harvest the names of fallen soldiers | **Petunjuk 2 (Kuburan).** Bersihkan `mt_kuburan` tempat para pelayan Pemburu memanen nama prajurit yang gugur | `area_cleared:mataram_kuburan`, sets `lead_kuburan` (plays beat `hunter_war`) | `travel, clue, fight x2, beat` |
| 2.8 | Claim the third mask fragment in the graveyard and witness Hunter Memory `H3` ("The Price") | Ambil pecahan topeng ketiga di kuburan dan saksikan Ingatan Pemburu `H3` ("Harganya") | `memory_done:h3`, sets `mq2_h4` | `clue, memory, fight` |
| 2.9 | **Lead 3 (The Lesung Yard).** Help Nyai Gendhis and the lesung women clear the haunted mill yard in `mt_wetan` | **Petunjuk 3 (Pelataran Lesung).** Bantu Nyai Gendhis dan para perempuan lesung membersihkan pelataran tumbuk di `mt_wetan` | `area_cleared:mataram_lesung_yard`, sets `mq2_4` | `travel, fight, talk, puzzle, beat` |
| 2.10 | Learn the dawn rhythm and Jawa Ca from Nyai Gendhis | Pelajari irama fajar dan Jawa Ca dari Nyai Gendhis | `glyph_learned:jawa_ca`, sets `mq2_5` | `talk, lesson, fight x2` |
| **Ch 3** | **Malam yang Bergerak di Candi Seribu / The Shifting Night of Candi Seribu** | | | |
| 2.11 | Break the spirit-builder siege on the foothill shrine as Bondowoso's night-curse spreads | Hancurkan kepungan roh pembangun di kuil kaki bukit saat kutukan malam Bondowoso menyebar | `area_cleared:mataram_batu`, sets `mq2_5b` | `travel, clue, fight x2, miniboss` |
| 2.12 | Align the foothill shrine braziers and receive Jawa Ra from the juru kunci | Selaraskan tungku kuil kaki bukit dan terimalah Jawa Ra dari juru kunci | `puzzle_solved:puzzle_wetan_lamps`; then `glyph_learned:jawa_ra`, sets `mq2_6` | `puzzle, talk, lesson` |
| 2.13 | Fight across the plain of rising stones (`mt_tegal`), shattering the spirit-pillars blocking the temple road | Bertempur melintasi dataran batu yang tumbuh (`mt_tegal`), menghancurkan pilar-pilar roh yang menghalangi jalan candi | `area_cleared:mataram_tegal_pillars`, sets `mq2_6b` | `travel, clue, fight x2, setpiece` |
| 2.14 | Breach the outer temple gate of `mt_candi` and storm the Faceless reading-camp | Tembus gerbang luar `mt_candi` dan serbu perkemahan baca Tanpa Rupa | `area_cleared:mataram_candi`; then `area_cleared:mataram_camp`, sets `mq2_7` (**The Turn:** the camp was a reading room) | `fight, talk, fight, miniboss, beat` |
| 2.15 | Examine the spirit-chiseled rubble, the silent lesung, and Laras's *Ka*-covered lontar strip | Periksa puing berpahat roh, lesung yang membisu, dan helai lontar Laras yang penuh tulisan *Ka* | `all`: `clue_examined:rubble`, `clue_examined:lesung_mid`, `clue_examined:ka_strip`; sets `mq2_h1` | `clue x3, talk` |
| **Ch 4** | **Pilar Keseribu / The Thousandth Pillar** | | | |
| 2.16 | **LC3 Cross-Time Chapter.** Play Laras in Candi Seribu: unbar the crypt door and hide Bondowoso's master chisel | **Bab Lintas-Waktu LC3.** Mainkan Laras di Candi Seribu: buka pintu ruang bawah tanah dan sembunyikan pahat utama Bondowoso | `memory_done:lc3`, sets `mq2_lc`, `laras_key:candi_crypt`, `laras_sabotage:bondowoso_pillar` | `chapter, puzzle` |
| 2.17 | Descend through Laras's unlocked crypt (`laras_key:candi_crypt`) to reach the central temple sanctum | Turuni ruang bawah tanah yang dibuka Laras (`laras_key:candi_crypt`) untuk mencapai ruang suci utama candi | `area_cleared:candi_crypt_hall`, sets `mq2_7a` | `travel, puzzle, fight` |
| 2.18 | **K3 Memory.** Experience Roro Jonggrang's women pounding the false-dawn rhythm | Alami para dayang Roro Jonggrang menumbuk irama fajar palsu | `memory_done:k3_lesung`, sets `mq2_h2` | `memory, beat` |
| 2.19 | End Bandung Bondowoso's night with Nyai Gendhis's lesung rhythm and Jawa Ca | Akhiri malam Bandung Bondowoso dengan irama lesung Nyai Gendhis dan Jawa Ca | `boss_defeated:bandung_bondowoso`, sets `mq2_7b` (Laras's `laras_sabotage:bondowoso_pillar` exposes his pillars on every beat) | `boss, setpiece, beat` |
| **Ch 5** | **Darah di Penyeberangan Pamali / Blood on the Pamali Ford** | | | |
| 2.20 | Take the temple shortcut back toward the western border and reach the Pamali river (`kg_pamali`) | Ambil jalan pintas candi kembali ke perbatasan barat dan capai Sungai Pamali (`kg_pamali`) | `zone_entered:kg_pamali`, sets `mq2_7c` | `travel, fight x2, talk` |
| 2.21 | Clear the river-bank skirmish and write King Nagawiru's true name (`Na-Ga`) on the Pamali Stone (Seal 2 restored) | Bersihkan pertempuran tepi sungai dan tuliskan nama sejati Prabu Nagawiru (`Na-Ga`) di Batu Pamali (Segel 2 pulih) | `name_written:nagawiru`, sets `mq2_8` | `fight x2, write, beat` |
| 2.22 | **K-III Memory.** Watch Ki Sumarto's shadow play at the river camp: the brothers who split the land | Saksikan pertunjukan bayangan Ki Sumarto di perkemahan sungai: dua saudara yang membelah tanah | `memory_done:k_iii`, sets `mq2_h5` (teaches *pamali*: brothers must not shed brother's blood) | `memory, talk` |
| 2.23 | Read Hariang Banga's unsent letters to his mother at the eastern camp | Baca surat-surat Hariang Banga yang tak terkirim untuk ibunya di perkemahan timur | `clue_examined:hariang_letters`, sets `mq2_h3` (plays beat `ford`) | `travel, clue, beat` |
| 2.24 | Duel Prince Hariang Banga in the Pamali ford, witness the river truce, and make **Choice 3** | Berduel dengan Pangeran Hariang Banga di penyeberangan Pamali, saksikan gencatan senjata sungai, dan tentukan **Pilihan 3** | `boss_defeated:hariang_banga`, sets `mq2_9` (beat `truce` presents **Choice 3**: `choice_mercy` / `choice_judgment`) | `boss, setpiece, beat, talk` |

---

### MQ3 Act IV: "Bilah Tujuh Turunan" / "The Seven-Generation Blade" (Tanah Timur, 22 steps, 5 chapters, ~205 min)
Structure: **3-Zone Stalking Predator (`Buto Ijo`), 7-Generation Blood-Curse Mystery (`Keris Mpu Gandring`) & Personal Showdown (`The Nameless Hunter`)**. Regional characters: **Mpu Wirasana**, **Ratna**, **Mbok Srini**. Ally: **Hariang Banga**.

| # | Objective (EN) | Objective (ID) | Completes on | Play |
|---|----------------|----------------|--------------|------|
| **Ch 1** | **Jalan Para Empu dan Raksasa Pengintai / The Smiths' Road and the Stalking Giant** | | | |
| 3.1 | **Arrival.** Enter Tanah Timur (`tt_kulon` & `tt_sabana`), meet smith's apprentice Ratna, and rest at the savanna petilasan (`timur_1`) | Masuki Tanah Timur (`tt_kulon` & `tt_sabana`), temui Ratna sang murid empu, dan beristirahat di petilasan sabana (`timur_1`) | `talked_to:timur_daughter`, sets `mq3_a1`; then `petilasan_activated:timur_1`, sets `mq3_1` | `travel, talk x2, fight` |
| 3.2 | **Stalking Ambush #1.** Survive Buto Ijo's sudden rampage across the western savanna and drive him back with fire-wards | **Penyergapan #1.** Bertahan dari amukan mendadak Buto Ijo di sabana barat dan pukul mundur dia dengan penangkal api | `area_cleared:buto_ambush_1`, sets `mq3_b1` | `setpiece, miniboss, beat` |
| 3.3 | Follow the burning red curse marks on village doorposts to Mpu Wirasana's forge in `tt_beringin` | Ikuti tanda kutukan merah yang menyala di tiang pintu desa menuju bengkel Mpu Wirasana di `tt_beringin` | `area_entered:timur_marks`, sets `mq3_h1`; then `talked_to:timur_empu`, sets `mq3_2` | `travel, clue, talk` |
| 3.4 | Learn Mpu Wirasana's technique to extinguish blood-curse stakes in the forge yard | Pelajari teknik Mpu Wirasana untuk memadamkan patok kutukan darah di halaman tempa | `area_entered:timur_praktik_mark` x2, sets `flag:clue_practice_marks` | `lesson, puzzle, fight` |
| **Ch 2** | **Empat Bungkusan Timun Mas / The Four Pouches of Timun Mas** | | | |
| 3.5 | Reach Mbok Srini's smashed hut in `tt_kali` and examine the spilled relics of Timun Mas's flight | Capai pondok Mbok Srini yang hancur di `tt_kali` dan periksa peninggalan pelarian Timun Mas yang tercecer | `talked_to:mbok_srini`, sets `mq3_3`; then `all`: `clue_examined:seeds`, `clue_examined:needle_case`, `clue_examined:salt_terasi`; sets `mq3_h2` | `travel, talk, clue x3` |
| 3.6 | **Stalking Ambush #2.** Test the bramble-seed pouch to slow Buto Ijo's charge across the dry riverbed (`tt_kali`) | **Penyergapan #2.** Uji bungkusan biji semak berduri untuk memperlambat terjangan Buto Ijo di dasar sungai kering (`tt_kali`) | `area_cleared:buto_ambush_2`, sets `mq3_b2` | `setpiece, puzzle, fight, beat` |
| 3.7 | **Stalking Ambush #3.** Consecrate the needle, salt, and terasi pouches at the ancient banyan (`tt_beringin`) while holding off Buto Ijo | **Penyergapan #3.** Sucikan bungkusan jarum, garam, dan terasi di pohon beringin tua (`tt_beringin`) sambil menahan Buto Ijo | `area_cleared:buto_ambush_3`, sets `mq3_b3` | `travel, clue, puzzle, miniboss` |
| 3.8 | **K4 Memory.** Experience Timun Mas's flight and see how the four pouches trap the giant | Alami pelarian Timun Mas dan lihat bagaimana keempat bungkusan menjebak sang raksasa | `memory_done:k4_timun_mas`, sets `mq3_h3` | `memory, beat` |
| 3.9 | Lure Buto Ijo into his canyon lair and defeat him using the four pouch fields | Pancing Buto Ijo ke sarang ngarainya dan kalahkan dia menggunakan keempat medan bungkusan | `boss_defeated:buto_ijo`, sets `mq3_4` | `boss, beat, talk` |
| **Ch 3** | **Kutukan Darah Tujuh Turunan / The Seven-Generation Blood Curse** | | | |
| 3.10 | Return to `tt_ladang` as the waking Keris ignites seven-generation curse stakes across the dry fields | Kembali ke `tt_ladang` saat Keris yang bangkit menyalakan patok kutukan tujuh turunan di ladang kering | `area_cleared:timur_ladang_stakes`, sets `mq3_5a` | `travel, clue, fight x2, puzzle` |
| 3.11 | Help Mpu Wirasana and Ratna defend the forge quarter from flying Keris Hantu packs | Bantu Mpu Wirasana dan Ratna mempertahankan kampung tempa dari kawanan Keris Hantu | `area_cleared:timur_forge_defense`, sets `mq3_5b` | `fight, talk, fight, miniboss` |
| 3.12 | Inspect the broken scabbard and the seven-generation forge ledger in Wirasana's vault | Periksa sarung keris yang patah dan buku catatan tempa tujuh turunan di ruang simpan Wirasana | `all`: `clue_examined:scabbard`, `clue_examined:forge_records`; sets `mq3_h4` | `clue x2, puzzle, talk` |
| 3.13 | **K5 Memory.** Relive the night of Mpu Gandring's apprentice and douse the original forge curse marks | Alami kembali malam murid Mpu Gandring dan padamkan tanda kutukan tempa yang pertama | `memory_done:k5_forge`, sets `mq3_h5` | `memory, beat` |
| **Ch 4** | **Menyeberangi Lautan Pasir / Across the Sea of Sand** | | | |
| 3.14 | Follow the Hunter's ash-trail down the volcanic coast (`tt_pesisir`) with Hariang Banga's scouts | Ikuti jejak abu Pemburu menyusuri pesisir vulkanik (`tt_pesisir`) bersama pengintai Hariang Banga | `area_cleared:timur_pesisir`, sets `mq3_5c` | `travel, fight x2, talk` |
| 3.15 | Cross the blinding Sea of Sand (`tt_pasir`), using the ancient stone waymarkers to survive the ash-gale | Seberangi Lautan Pasir (`tt_pasir`), gunakan patok batu kuno untuk bertahan dari badai abu | `area_cleared:timur_pasir`; then `puzzle_solved:pasir_waymarkers`, sets `mq3_5d` | `travel, puzzle, fight, miniboss` |
| 3.16 | Rest at the desert petilasan (`timur_2`) and speak with Hariang Banga before the shrine assault | Beristirahat di petilasan gurun (`timur_2`) dan bicara dengan Hariang Banga sebelum menyerbu kuil | `petilasan_activated:timur_2`, sets `mq3_6` | `talk x2, clue, fight` |
| 3.17 | **LC4 Cross-Time Chapter.** Play Laras across the dunes & shrine: open the buried wind-tunnel and bind *Ka* onto the seventh curse stake | **Bab Lintas-Waktu LC4.** Mainkan Laras melintasi bukit pasir & kuil: buka terowongan angin yang terkubur dan ikat *Ka* pada patok kutukan ketujuh | `memory_done:lc4`, sets `mq3_lc`, `laras_key:sand_tunnel`, `laras_sabotage:keris_seventh_stake` | `chapter, puzzle, beat` |
| **Ch 5** | **Kuil Timur dan Wajah Aria / The Eastern Shrine and Aria's Face** | | | |
| 3.18 | Use Laras's wind-tunnel shortcut (`laras_key:sand_tunnel`) to breach `tt_candi` and see Laras across the altar | Gunakan jalan pintas terowongan angin Laras (`laras_key:sand_tunnel`) untuk menembus `tt_candi` dan lihat Laras di seberang altar | `area_entered:candi_inner_sanctum`, sets `mq3_6b` (plays beat `shrine_sight`) | `travel, fight x2, beat` |
| 3.19 | Lay the awakened Keris Mpu Gandring to rest using Laras's bound seventh stake | Tenangkan Keris Mpu Gandring yang bangkit menggunakan patok ketujuh yang diikat Laras | `boss_defeated:keris_gandring`, sets `mq3_7` | `boss, beat` |
| 3.20 | Decide the fate of Mpu Gandring's blade (**Choice 4**) | Putuskan nasib bilah Mpu Gandring (**Pilihan 4**) | `flag:beat_keris` (**Choice 4**: `choice_reforge` / `choice_sink`) | `talk, beat, puzzle` |
| 3.21 | Claim the fourth mask fragment (`H4` "Wrong Child") and join the full mask (`K6` "The Servant") | Ambil pecahan topeng keempat (`H4` "Anak yang Salah") dan satukan topeng utuh (`K6` "Sang Abdi") | `memory_done:h4`, sets `mq3_h7`; then `memory_done:k6_servant`, sets `mq3_h6` (plays beat `hunter_shrine`, `restore`) | `clue, memory x2, beat` |
| 3.22 | Defeat the Nameless Hunter, carve *Aria Kebonan* onto his mask, and witness the Eclipse take Laras | Kalahkan Si Tanpa Ngaran, ukir *Aria Kebonan* pada topengnya, dan saksikan Gerhana merenggut Laras | `boss_defeated:nameless_hunter`, sets `mq3_8` (beat `hunter_name` frees all held names, starts `mq4`, and `goto:desa_purwa:from_riders`) | `boss, setpiece, beat` |

---

### MQ4 Interlude ("Rumah yang Sunyi", 4.1–4.8, ~45 min) & Act V ("Laut Tak Pernah Lupa", 4.9–4.22, ~160 min)
Interlude structure: **Psychological Low Point & Village Name-Restoration** in `desa_purwa`.
Act V structure: **Coastal Community Healing, Sunken Cavern & Three Sacred Sea Trials** across **7 areas** (`sk_pantai`, `sk_nelayan` **[NEW]**, `sk_bakau` **[NEW]**, `sk_karang`, `sk_gua` **[NEW]**, `sk_tebing`, `sk_keraton`). Regional characters: **Mbah Wiryo** and **Sari**.

| # | Objective (EN) | Objective (ID) | Completes on | Play |
|---|----------------|----------------|--------------|------|
| **Ch 1** | **Desa Tanpa Nama / The Nameless Village (Interlude)** | | | |
| 4.1 | Return to Desa Purwa under the Eclipse and test the impenetrable fog at the northern cave mouth | Kembali ke Desa Purwa di bawah Gerhana dan uji kabut pekat di mulut gua utara | `zone_entered:desa_purwa`; then `area_entered:purwa_north_fog`, sets `mq4_i0` | `travel, beat` |
| 4.2 | Speak with the bewildered villagers in the square who are beginning to forget their own families | Bicara dengan warga desa yang kebingungan di alun-alun karena mulai melupakan keluarga mereka sendiri | `talked_to:purwa_old_couple`; then `talked_to:purwa_stall`, sets `mq4_i0b` | `talk x2, clue` |
| 4.3 | Anchor three households against the Eclipse by writing each family's name on their doorpost | Ikalkan tiga keluarga dari Gerhana dengan menuliskan nama keluarga mereka di tiang pintu | `all`: `name_written:door_a`, `name_written:door_b`, `name_written:door_c`; sets `mq4_i1` | `travel, write x3` |
| 4.4 | Examine Laras's empty shelf and bring Ibu her three keepsakes (the ribbon, the wagon board, the Ka strip) | Periksa rak kosong Laras dan bawakan Ibu tiga benda kenangannya (pita, papan kereta, helai Ka) | `all`: `clue_examined:shelf_ribbon`, `clue_examined:shelf_board`, `clue_examined:shelf_strip`; then `talked_to:ibu`, sets `mq4_2` (Ibu straightens the second tea cup) | `clue x3, talk, beat` |
| **Ch 2** | **Meja Dua Saudara / The Brothers' Table (Interlude)** | | | |
| 4.5 | Sit at your mother's table with brother-kings Ciung Wanara and Hariang Banga | Duduk di meja ibumu bersama dua saudara raja, Ciung Wanara dan Hariang Banga | `area_entered:purwa_table`, sets `mq4_i3` (playable dinner setpiece; shaped by **Choice 3**) | `setpiece, talk, beat` |
| 4.6 | Speak with the unmasked, broken Aria Kebonan beside the ashes of the wayang stage | Bicara dengan Aria Kebonan yang telah kehilangan topengnya di dekat abu panggung wayang | `talked_to:aria_kebonan`, sets `mq4_i4` (he reveals how Kala's sleeping maw works and asks to be forgotten) | `talk x2, beat` |
| 4.7 | Hear Semar at the sanggar explain Batara Ismaya's vow and why the Southern Sea never forgets | Dengarkan Semar di sanggar menjelaskan sumpah Batara Ismaya dan mengapa Laut Selatan tak pernah lupa | `talked_to:semar`, sets `mq4_i5` (opens the south gate to `sk_pantai`) | `talk x2, beat` |
| 4.8 | Walk south through the opened village gate toward Segara Kidul | Berjalan ke selatan melewati gerbang desa yang terbuka menuju Segara Kidul | `zone_entered:sk_pantai`, sets `mq4_i6` | `travel, talk` |
| **Ch 3** | **Kampung Nelayan dan Lagu yang Hilang / Kampung Nelayan and the Lost Song (Act V)** | | | |
| 4.9 | **Arrival.** Rest at the black-sand petilasan (`kidul_1`) and enter Kampung Nelayan (`sk_nelayan`), where fishers mend nets in silence | Beristirahat di petilasan pasir hitam (`kidul_1`) dan masuki Kampung Nelayan (`sk_nelayan`), tempat para nelayan menambal jala dalam diam | `petilasan_activated:kidul_1`; then `zone_entered:sk_nelayan`, sets `mq4_a1` | `travel, fight, talk, beat` |
| 4.10 | Meet coast juru kunci Mbah Wiryo and young diver Sari to learn of the forgotten *sedekah laut* song | Temui juru kunci pesisir Mbah Wiryo dan penyelam muda Sari untuk mengetahui lagu *sedekah laut* yang terlupa | `talked_to:kidul_jurukunci`, sets `mq4_4`; then `talked_to:kidul_sari`, sets `mq4_4b` | `talk, travel, fight, talk` |
| 4.11 | **K8 Clues.** Help three fishing families across `sk_nelayan` and `sk_pantai` recover the three verses of the sea-song | Bantu tiga keluarga nelayan di `sk_nelayan` dan `sk_pantai` menemukan kembali tiga bait lagu laut | `all`: `clue_examined:song_1`, `clue_examined:song_2`, `clue_examined:song_3`; sets `mq4_h1` | `travel, clue x2, fight, clue, beat` |
| 4.12 | **K8 Memory.** Experience Mbah Wiryo's wife on the shore teaching him to call a name to the sea | Alami kenangan istri Mbah Wiryo di pantai yang mengajarinya memanggil nama ke arah laut | `memory_done:k8_wiryo_wife`, sets `mq4_h2` | `memory, puzzle, beat, talk` |
| **Ch 4** | **Hutan Bakau dan Gua Karang / The Mangrove and the Sea Cavern (Act V)** | | | |
| 4.13 | Venture into the flooded Hutan Bakau (`sk_bakau`, mangrove) with Sari to relight the three tidal beacons | Masuk ke Hutan Bakau (`sk_bakau`) yang pasang bersama Sari untuk menyalakan kembali tiga suar pasang-surut | `puzzle_solved:bakau_beacons`, sets `mq4_5a` | `travel, talk, puzzle, fight x2` |
| 4.14 | **Sacred Trial I (Trial of the Torch-Lines).** Cross `sk_karang` and extinguish the Lampor legions on the low-tide reef | **Ujian Suci I (Ujian Barisan Obor).** Seberangi `sk_karang` dan padamkan barisan Lampor di karang surut | `area_cleared:kidul_karang_2`, sets `mq4_5b` | `setpiece, clue, fight x2, miniboss` |
| 4.15 | Descend into the echoing Gua Karang (`sk_gua`, sea cavern) and clear the sunken shrine approach | Turun ke Gua Karang (`sk_gua`) yang bergema dan bersihkan jalur kuil bawah air | `area_cleared:gua_karang_approach`, sets `mq4_6a` | `travel, fight, clue, fight, beat` |
| 4.16 | **LC5 Cross-Time Chapter.** Play Laras in the dark water: ring the three sunken bronze bells to answer the sea | **Bab Lintas-Waktu LC5.** Mainkan Laras di air gelap: bunyikan tiga lonceng perunggu tenggelam untuk menjawab panggilan laut | `memory_done:lc5`, sets `mq4_lc`, `laras_key:tidal_gate` (lowers the abyssal water barrier in `sk_gua`) | `chapter, puzzle, beat` |
| **Ch 5** | **Kuil Tebing dan Persembahan / The Cliff Shrine and the Offering (Act V)** | | | |
| 4.17 | **Sacred Trial II (Trial of the Abyssal Current).** Cross Laras's opened cavern gate (`laras_key:tidal_gate`) and overcome the cavern guardians | **Ujian Suci II (Ujian Arus Palung).** Seberangi gerbang gua yang dibuka Laras (`laras_key:tidal_gate`) dan taklukkan penjaga palung | `area_cleared:kidul_gua_trial`, sets `mq4_6b` | `setpiece, fight, talk, fight, miniboss` |
| 4.18 | Climb the storm cliffs (`sk_tebing`), rest at the cliff shrine (`kidul_3`), and hear `K9` ("The Queen of the South") | Daki tebing badai (`sk_tebing`), beristirahat di kuil tebing (`kidul_3`), dan dengarkan `K9` ("Ratu Laut Selatan") | `area_cleared:kidul_tebing_2`; then `petilasan_activated:kidul_3`; then `memory_done:k9_queen_south`, sets `mq4_h3` | `travel, fight x2, memory, beat` |
| 4.19 | Call Laras's name to the Southern Sea at the cliff altar and make **Choice 5** | Panggil nama Laras ke Laut Selatan di altar tebing dan tentukan **Pilihan 5** | `flag:mq4_offering` (**Choice 5**: `choice_offer_memory` / `choice_offer_song`, opens the Sea Pavilion causeway) | `talk, puzzle, fight, beat` |
| **Ch 6** | **Ujian Ombak di Keraton Laut / The Trial of the Waves (Act V)** | | | |
| 4.20 | Walk the ancient sea causeway into the Sea Pavilion (`sk_keraton`) and rest at `kidul_2` | Susuri jalan batu kuno menuju Keraton Laut (`sk_keraton`) dan beristirahat di `kidul_2` | `petilasan_activated:kidul_2`, sets `mq4_7` | `travel, fight x2, clue, talk` |
| 4.21 | **Sacred Trial III (The Trial of the Waves).** Pass the three waves of the Sea Pavilion court | **Ujian Suci III (Ujian Ombak).** Lalui tiga gelombang ujian di pelataran Keraton Laut | `area_cleared:kidul_trial`, sets `mq4_8` (beat `kidul_trial`: Nyi Roro Kidul speaks once from afar) | `setpiece, clue, setpiece, miniboss, beat` |
| 4.22 | Write and learn the ninth glyph, Jawa Ka (*Ombak*), and receive the Kain Hijau at the Sea Altar | Tulis dan pelajari aksara kesembilan, Jawa Ka (*Ombak*), serta terimalah Kain Hijau di Altar Laut | `glyph_learned:jawa_ka`, sets `mq4_9` (opens both entrances to Gua Kala) | `write, lesson, puzzle, beat, talk` |

---

### MQ5 Act VI: "Ke Rahang Sang Waktu" / "Into the Maw of Time" (Gua Kala, 14 steps, 4 chapters, ~160 min)
Structure: **Allied Stand at the Gate, Three-Realm Memory Descent (`La`, `Ra`, `Sa`) & Dual-Perspective Finale against `Batara Kala`** across **7 areas** (`gk_pelataran` **[NEW]**, `gk_mulut`, `gk_pasir`, `gk_hutan` **[NEW]**, `gk_lupa`, `gk_jembatan` **[NEW]**, `gk_ruang_kala`).

| # | Objective (EN) | Objective (ID) | Completes on | Play |
|---|----------------|----------------|--------------|------|
| **Ch 1** | **Pelataran Waktu dan Aksara Pertama / The Courtyard of Time and the First Letter** | | | |
| 5.1 | **Arrival.** Join Ciung Wanara, Hariang Banga, and your gathered allies holding the outer Courtyard of Time (`gk_pelataran`) | Bergabunglah dengan Ciung Wanara, Hariang Banga, dan para sekutumu yang mempertahankan Pelataran Waktu (`gk_pelataran`) | `zone_entered:gk_pelataran`; then `area_cleared:kala_pelataran_siege`, sets `mq5_0` | `travel, talk, setpiece, fight x2` |
| 5.2 | Stand before the ancestors' memorial stone in `gk_pelataran` and make **Choice 6** regarding Aria Kebonan's name | Berdiri di depan batu peringatan leluhur di `gk_pelataran` dan tentukan **Pilihan 6** mengenai nama Aria Kebonan | `flag:mq5_choice6` (**Choice 6**: `choice_redeem_aria` / `choice_release_aria`) | `talk, write, fight, beat` |
| 5.3 | Part the Eclipse barrier with *Ombak* and fight into the Cave Mouth (`gk_mulut`) | Belah tirai Gerhana dengan *Ombak* dan bertempur memasuki Mulut Gua (`gk_mulut`) | `area_cleared:kala_mulut`, sets `mq5_1b` | `travel, clue, fight x2, miniboss` |
| 5.4 | **Gap Memory `La`.** Reclaim the first letter of Laras's name in the eaten memory of the morning tag game | **Ingatan Rumpang `La`.** Rebut aksara pertama nama Laras dalam kenangan permainan kejar-kejaran pagi yang termakan | `memory_done:la`, sets `mq5_la` (fill 3 eaten details: the stray cat's name, the banyan's shiver, Laras's laugh) | `memory, puzzle, fight, beat` |
| **Ch 2** | **Pasir Jam Pasir dan Hutan Lupa / The Hourglass Sands and the Forgotten Woods** | | | |
| 5.5 | Cross the Hourglass Sands (`gk_pasir`) and shatter the western and eastern time-wards | Seberangi Pasir Jam Pasir (`gk_pasir`) dan hancurkan penangkal waktu barat serta timur | `area_cleared:kala_pasir_1`; then `area_cleared:kala_pasir_2`, sets `mq5_1c` | `travel, clue, fight x2, puzzle, beat` |
| 5.6 | Descend into Hutan Lupa (`gk_hutan`, the Forgotten Woods) and silence the whispering name-trees | Turun ke Hutan Lupa (`gk_hutan`) dan tenangkan pepohonan bisik yang menelan nama | `area_cleared:kala_hutan_echoes`; then `puzzle_solved:hutan_name_chimes`, sets `mq5_1cb` | `travel, clue, fight, puzzle` |
| 5.7 | Clear the Abyss of Forgetting (`gk_lupa`) and reclaim the second letter in **Gap Memory `Ra` (The Two Cups)** | Bersihkan Jurang Lupa (`gk_lupa`) dan rebut aksara kedua dalam **Ingatan Rumpang `Ra` (Dua Cangkir Teh)** | `area_cleared:kala_lupa`, sets `mq5_1d`; then `memory_done:ra`, sets `mq5_ra` | `fight, miniboss, memory, puzzle, beat` |
| **Ch 3** | **Jembatan Bayang dan Murwakala / The Shadow Bridge and Murwakala** | | | |
| 5.8 | Cross Jembatan Bayang (`gk_jembatan`, the Shadow Bridge), overcoming the time-echoes of fallen legends | Seberangi Jembatan Bayang (`gk_jembatan`), kalahkan gema waktu dari legenda-legenda yang telah lewat | `area_cleared:kala_jembatan_echoes`, sets `mq5_1e` | `travel, clue, setpiece, miniboss` |
| 5.9 | Rest at the final petilasan (`kala_1`), speak with Semar, and reclaim the third letter in **Gap Memory `Sa` (The Lontar)** | Beristirahat di petilasan terakhir (`kala_1`), bicara dengan Semar, dan rebut aksara ketiga dalam **Ingatan Rumpang `Sa` (Lontar di Sanggar)** | `petilasan_activated:kala_1`, sets `mq5_2`; then `memory_done:sa`, sets `mq5_sa` | `talk, memory, puzzle, beat` |
| 5.10 | **K10 Memory.** Hear Semar's ruwatan tale of *Murwakala*: how Batara Kala was born hungry and why words calm him | **Ingatan K10.** Dengarkan kisah ruwatan *Murwakala* dari Semar: bagaimana Batara Kala lahir dalam lapar dan mengapa kata-kata menenangkannya | `memory_done:k10_murwakala`, sets `mq5_h2` | `memory, talk, fight, clue` |
| 5.11 | **K7 Memory.** Take the dalang's place behind Semar's kelir and practice the alternating Sunda + Jawa + *Ombak* Ruwatan | **Ingatan K7.** Ambil tempat dalang di balik kelir Semar dan latih urutan Ruwatan aksara Sunda + Jawa + *Ombak* | `memory_done:k7_ruwatan`, sets `mq5_h1` | `memory, puzzle, beat` |
| **Ch 4** | **Ruwatan Fajar Ganda / The Dual Ruwatan of Dawn** | | | |
| 5.12 | **LC6 Cross-Time Chapter.** Play Laras at the bottom of Kala's dark: answer your sibling's voice and prepare to break the Eclipse from within | **Bab Lintas-Waktu LC6.** Mainkan Laras di dasar kegelapan Kala: jawab suara kakakmu dan bersiaplah memecahkan Gerhana dari dalam | `memory_done:lc6`, sets `mq5_lc`, `laras_sabotage:kala_eclipse` | `chapter, puzzle, beat` |
| 5.13 | **Dual-Perspective Finale.** Calm Batara Kala in the Ruwatan of Dawn alongside Laras inside his shadow | **Klimaks Dua Sudut Pandang.** Tenangkan Batara Kala dalam Ruwatan Fajar bersama Laras di dalam bayangannya | `boss_defeated:batara_kala`, sets `mq5_3` (Laras's `laras_sabotage:kala_eclipse` cracks his inner shadow while you cast Sunda -> Jawa -> *Ombak*) | `boss, setpiece, beat` |
| 5.14 | Write Laras's full name (`La - Ra - Sa`) stroke by stroke on your lontar to bring her home | Tuliskan nama lengkap Laras (`La - Ra - Sa`) gores demi gores di lontarmu untuk membawanya pulang | `name_written:laras`, sets `mq5_4` (triggers the playable Epilogue day and 6 choice cards) | `write, setpiece, beat` |

---

## 5. Side quests & Companion Stories (Story v5: 20 Quests, ~430+ min Modeled)
To prevent side content from feeling repetitive, side quests are divided into **four distinct gameplay templates** (Retellings, Two-Way Spirit Hunts, Cultural Craft/World-State Quests, and Multi-Act Companion Chains). Sizes in v5 (`pacing_model.py` bands): **S** (8–15 min), **M** (15–28 min), **L** (25–45 min).

### Tatar Sunda
**SQ-S1 "Lutung Kasarung" (Folklore Retelling, M)**
- Giver: Ki Darsa (juru pantun) & Purbasari in `ts_leuweung`. Unlock: `mq1_3`.
- Steps: (1) talk to Ki Darsa and Purbasari (`talked_to:ki_darsa`), (2) inspect the langur's fruit offerings and the corrupted forest spring (`clue_examined:s1_offerings`, `clue_examined:s1_spring`), (3) play `memory_done:sq_s1_lutung` (Guruminda as the lutung guiding Purbasari), (4) cleanse the spring guardians and restore the water puzzle (`area_cleared:s1_spring_guardians`), (5) speak with Purbasari (`talked_to:purbasari`).
- Reward: **Iket Sunda**, lakon "Lutung Kasarung", Ilmu M.
- Play: `talk, travel, clue x2, memory, puzzle, fight, talk, beat`

**SQ-S2 "Tangis di Rumpun Bambu" / "Crying in the Bamboo" (Kuntilanak Two-Way Hunt, L)**
- Giver: Kepala Desa in `ts_kampung`. Unlock: `mq1_3`.
- Steps: (1) talk to `kepala_desa`, (2) investigate the cempaka grave and torn white cloth in `ts_leuweung` (`clue_examined:s2_grave`, `clue_examined:s2_cloth`), (3) play `memory_done:sq_s2_grandmother` (teaches the beaten-earth safe ground), (4) defeat `enemy_killed:kuntilanak_elite` using the safe ground and Ka Bolt during her shriek, (5) carve the forgotten woman's name on her grave marker with `kepala_desa`.
- Reward: **Golok**, **Herb Pouch #1**, Ilmu L.
- Play: `talk, travel x2, fight x2, clue x2, memory, miniboss, write, talk, beat`

**SQ-S3 "Nada Angklung yang Hilang" / "The Lost Angklung Notes" (Cultural Craft & Harmony Puzzle, M)**
- Giver: The elder's grandson (`sunda_grandson`) in `ts_kebun`. Unlock: `mq1_1`.
- Steps: (1) recover 3 resonant bamboo tubes across `ts_kebun`, `ts_kampung`, and `ts_sawah`, (2) arrange the pentatonic scale puzzle at the kampung pavilion, (3) play the harmony with the villagers.
- Reward: **Flask Shard #1**, Ilmu M.
- Play: `talk, travel x2, fight, clue x2, puzzle, talk, beat`

**SQ-S4 "Cepot Si Pemberani (Bagian 1)" / "Brave Cepot (Part 1)" (Companion Errand, S)**
- Giver: Cepot at `sunda_1`. Unlock: `mq1_1`.
- Steps: (1) talk to `cepot`, (2) rescue his trapped supply pack from 3 wild boars in `ts_kebun` using Ga Ward, (3) report back to `cepot` (sets `c4_1`).
- Reward: **Silver Bangle**, Ilmu S.
- Play: `talk, travel, fight x2, talk, beat`

### Keraton Galuh
**SQ-G1 "Akal Si Kabayan" / "The Wit of Si Kabayan" (Trickster Comedy Retelling, M)**
- Giver: Kabayan resting under a banyan in `kg_pasar`. Unlock: `mqg_a1`.
- Steps: (1) talk to `kabayan`, (2) help him outwit the pompous tax official across three comedic market riddles in `kg_pasar` and `kg_alun` (`clue_examined:g1_debt_ledger`, `clue_examined:g1_palm_sack`), (3) play `memory_done:sq_g1_kabayan`, (4) watch the official's public embarrassment (`talked_to:kabayan`).
- Reward: lakon "Si Kabayan", codex `kabayan`.
- Play: `talk, travel, clue x2, puzzle, memory, talk, beat`

**SQ-G2 "Ririwa di Kaputren" / "The Sweeping Ghost of the Kaputren" (Two-Way Hunt, L)**
- Giver: An old palace maid in `kg_kaputren`. Unlock: `mqg_kp1`.
- Steps: (1) talk to `g2_maid`, (2) examine the worn-down broom in `kg_kaputren` and the scraped servants' roll in `kg_pustaka` (`clue_examined:g2_broom`, `clue_examined:g2_roll`), (3) play `memory_done:sq_g2_servant` (teaches that his stolen name is `Ca-Nga`, Canga), (4) `alt`: write his name on the servants' roll (`name_written:ririwa_name`, `write:ririwa_name:sunda_ca,sunda_nga`) = **peaceful**, or defeat `enemy_killed:ririwa` = **fight**, (5) report to the maid.
- Reward: codex `ririwa`.
- Play: `talk, beat, travel x2, fight, clue x2, puzzle, memory, write, talk, beat`

### Mataram
**SQ-M1 "Jaka Tarub dan Nawang Wulan" (Folklore Retelling, M)**
- Giver: Nawang Wulan in `mt_sawah`. Unlock: `mq2_1`.
- Steps: (1) talk to `nawang_wulan`, (2) examine the lifted rice-pot lid and the empty lumbung (`clue_examined:m1_pot_lid`, `clue_examined:m1_rice_gone`), (3) play `memory_done:sq_m1_selendang`, (4) clear the spirit thieves around the spring and return her selendang (`talked_to:nawang_wulan`).
- Reward: **Feather Charm**, **Herb Pouch #2**, lakon "Jaka Tarub", Ilmu M.
- Play: `talk, beat, travel, fight, clue x2, memory, puzzle, talk`

**SQ-M2 "Anak yang Tak Dipanggil" / "The Child Nobody Called" (Wewe Gombel Two-Way Hunt, L)**
- Giver: Worried neighbor (`m2_neighbour`) in `mt_pasar`. Unlock: `mq2_2`.
- Steps: (1) talk to `m2_neighbour`, (2) inspect the dropped wooden toy on the hill path and question the neglectful parents (`clue_examined:m2_toy`, `talked_to:m2_parents_1`), (3) play `memory_done:sq_m2_child` (teaches calling kindly and rhythmic pot-banging), (4) `alt`: guide the parents up the hill to call their son kindly (`talked_to:wewe_parents_2`) = **peaceful**, or defeat `enemy_killed:wewe_elite` = **fight**, (5) bring the child home.
- Reward: **Jimat**, Ilmu L (fight +50%).
- Play: `talk, beat, travel x3, fight x2, clue x2, memory, puzzle, talk, beat`

**SQ-M3 "Uang yang Hilang di Pasar" / "Coins Gone from the Market" (Tuyul Two-Way Hunt, M)**
- Giver: Blacksmith (`m3_smith`) in `mt_pasar`. Unlock: `mq2_1`.
- Steps: (1) talk to `m3_smith`, (2) examine the tiny ash footprints and half-counted green beans (`clue_examined:m3_footprints`, `clue_examined:m3_beans`), (3) play `memory_done:sq_m3_tuyul`, (4) `alt`: set the green-bean counting trap (`area_entered:m3_trap_sprung`) = **peaceful**, or defeat `enemy_killed:tuyul_leader` = **fight**, (5) tell `m3_smith`.
- Reward: **Spear**, Ilmu M (fight +50%).
- Play: `talk, beat, travel, fight, clue x2, memory, puzzle, talk`

**SQ-M4 "Gamelan yang Bisu" / "The Silent Gamelan" (Cultural World-State Quest, M)**
- Giver: Ki Sumarto in `mt_pasar`. Unlock: `mq2_2`.
- Steps: (1) talk to `mataram_dalang`, (2) fight into the sunken ruin vault of `mt_reruntuhan` to recover the stolen `gong_ageng`, (3) restore the gong to the pavilion so Mataram's background music gains its resonant gong layer.
- Reward: **Blangkon**, Ilmu M.
- Play: `talk, travel x2, fight x2, miniboss, puzzle, talk, beat`

### Tanah Timur
**SQ-T1 "Ande-Ande Lumut" (Folklore Retelling & Two-Way Crossing, M)**
- Giver: Klething Kuning at `tt_kali`. Unlock: `mq3_1`.
- Steps: (1) talk to `klething_kuning`, (2) examine the giant claw marks on the broken ferry jetty and the *sodo lanang* palm rib (`clue_examined:t1_claw_marks`, `clue_examined:t1_sodo`), (3) play `memory_done:sq_t1_klething`, (4) `alt`: strike the river with the *sodo lanang* (`area_entered:t1_crossing_dry`) = **peaceful**, or defeat `enemy_killed:yuyu_kangkang` = **fight**, (5) speak with `klething_kuning`.
- Reward: **Stone Ring**, lakon "Ande-Ande Lumut", Ilmu M (fight +50%).
- Play: `talk, beat, travel, fight, clue x2, memory, puzzle, talk`

**SQ-T2 "Api Tanpa Angin" / "Fire With No Wind" (Banaspati Hunt, L)**
- Giver: Herder (`t2_herder`) in `tt_kulon`. Unlock: `mq3_1`.
- Steps: (1) talk to `t2_herder`, (2) track the circular scorched grass trail in `tt_ladang` and the unlit campsite (`clue_examined:t2_burn_trail`, `clue_examined:t2_campfire`), (3) play `memory_done:sq_t2_herder` (teaches using running water channels against the fire spirit), (4) open the oasis water channel in `tt_pesisir` and defeat `enemy_killed:banaspati_elite`, (5) report to `t2_herder`.
- Reward: **Herb Pouch #3**, Ilmu L.
- Play: `talk, beat, travel x2, fight x2, clue x2, memory, puzzle, miniboss, talk`

**SQ-T3 "Pamor dari Langit" / "Pamor from the Sky" (Cross-Region Smithing Quest, M)**
- Giver: Mpu Wirasana & Ratna at the `tt_beringin` forge. Unlock: `mq3_2`.
- Steps: (1) talk to `timur_empu`, (2) travel back to the Mataram temple plain (`mt_tegal`) to locate the fallen Prambanan meteorite (`batu_bintang`), (3) defend the crater site from stone guardians, (4) bring the meteorite back to Wirasana and help fold the pamor steel.
- Reward: **Keris Luk 7**, Ilmu M.
- Play: `talk, travel x2, fight x2, clue, puzzle, talk, beat`

**SQ-T4 "Kuda Kepang yang Hilang" / "The Lost Kuda Kepang" (Cultural Performance Errand, S)**
- Giver: Troupe leader at the `tt_beringin` troupe camp. Unlock: `mq3_1`.
- Steps: (1) recover 3 woven bamboo horses (`kuda_kepang_1..3`) across `tt_kulon` and `tt_beringin`, (2) return them and watch the troupe's celebratory dance.
- Reward: **Flask Shard #2**, Ilmu S.
- Play: `talk, travel, fight, clue x2, beat`

### Segara Kidul
**SQ-K1 "Tukik Pulang ke Laut" / "Hatchlings Home to the Sea" (Conservation Errand, S)**
- Giver: Fisher's child in `sk_pantai` / `sk_nelayan`. Unlock: `mq4_4`.
- Steps: (1) gather 3 stranded sea-turtle hatchlings (`tukik_1..3`) across the dunes and mangrove edge, (2) clear the reef predators along the surf, (3) release the hatchlings into the tide.
- Reward: **Herb Pouch #4**, Ilmu S.
- Play: `talk, travel, fight, clue x2, beat`

**SQ-K2 "Jaring yang Robek" / "The Torn Nets" (Bajul Putih Tua Two-Way/Respect Hunt, L)**
- Giver: River-mouth fisher (`k2_fisher`) in `sk_nelayan`. Unlock: `mq4_4`.
- Steps: (1) talk to `k2_fisher`, (2) examine the ancient white scale in `sk_bakau` and ask Mbah Wiryo about the river-mouth guardian (`clue_examined:k2_scale`, `talked_to:kidul_jurukunci`), (3) play `memory_done:sq_k2_fisher` (teaches reading the receding tide-tell before its lunge), (4) face `enemy_killed:bajul_putih_tua` in the river-mouth lagoon (at 0 HP the ancient white crocodile dives peacefully back into the deep), (5) report to `k2_fisher`.
- Reward: **Cakra** (or Ilmu L x2).
- Play: `talk, beat, travel x2, fight x2, clue x2, memory, miniboss, talk, beat`

### Multi-Act Companion Stories (`SQ-C1`–`SQ-C4`)
**SQ-C1 "Ayam Jago Ciung" / "Ciung's Rooster" (Act II, M)**
- Giver: Ciung Wanara in `kg_alun`. Unlock: `mqg_a1`.
- Steps: (1) talk to `ciung_wanara`, (2) track the rooster's feathers through `kg_pasar` and find the old river-basket in `kg_kaputren` (`clue_examined:c1_feathers`, `clue_examined:c1_basket`), (3) play `memory_done:sq_c1_basket` (baby Ciung afloat on the river with the egg), (4) solve the market rooftop perch puzzle to coax the rooster down (`area_entered:c1_rooster_found`), (5) talk with Ciung and Uwa Lengser about the basket token.
- Reward: codex `ciung_egg`.
- Play: `talk, beat, travel, clue x2, memory, puzzle, talk, beat`

**SQ-C2 "Surat di Seberang Pamali" / "Letters Across the Pamali" (Acts III–IV, M, Cross-Zone)**
- Giver: Hariang Banga at `kg_pamali`. Unlock: `quest:mq2=done`.
- Steps: (1) talk to `hariang_banga`, (2) travel back into `kg_keraton`/`kg_penjara` and deliver his letters to Queen Pangrenyep (`talked_to:galuh_queen`, lines vary by **Choice 3** `choice_mercy` / `choice_judgment`), (3) retrieve the Queen's heirloom signet from `kg_kaputren`, (4) deliver her reply to Hariang Banga in Tanah Timur and read the final note on Ibu's table in the Interlude (`clue_examined:c2_reply_letter`).
- Reward: codex `pangrenyep_letter`.
- Play: `talk, travel x2, fight, talk, puzzle, clue, beat`

**SQ-C3 "Nama si Pembelot (Ranga)" / "The Deserter's Name" (Acts III–VI, L, Multi-Act Chain)**
- Giver: Ranga the Deserter (if `choice_freed`) or Uwa Lengser's intelligence notes (if `choice_handed`). Unlock: `mq2_7`.
- Steps: (1) find the stitched syllable cloth at Candi Seribu (`clue_examined:c3_camp_scrap`), (2) uncover his old shield mark in `tt_pasir` (`clue_examined:c3_road_mark`), (3) find his carved driftwood token in `sk_nelayan` (`clue_examined:c3_shore_net`) and relive his memory of the day his name was taken (`memory_done:sq_c3_ranga`), (4) at `gk_pelataran` in Act VI, write his true name `Ra-Nga` (`name_written:deserter_name`, `write:deserter_name:jawa_ra,sunda_nga`).
- Reward: Ranga fights at full strength beside the kings at `gk_pelataran` (if freed) and gains an Epilogue scene; codex `deserter_name`.
- Play: `clue x3, talk x2, travel x3, fight, memory, write, beat`

**SQ-C4 "Cepot Si Pemberani (Bagian 2 & 3)" / "Brave Cepot" (Acts III & V, S each)**
- **Part 2 (Act III, `c4_2`):** Cepot accidentally enlisted with both the Galuh and Mataram recruiters at `mt_gapura`. Inspect both muster rolls (`clue_examined:c4_roll_a`, `clue_examined:c4_roll_b`), solve the distraction puzzle to sneak him out (`area_entered:c4_market_clear`), and talk to `cepot`.
  - Play: `talk, clue x2, puzzle, talk, beat`
- **Part 3 (Act V, `c4_3`):** Cepot followed you to `sk_pantai` despite being terrified of the ocean. Hold the ward-lamp with him across a two-wave night defense on the turtle beach (`trial_completed:c4_lamp`), then talk to `cepot` (sets `c4_done`).
  - Play: `talk, travel, setpiece, fight, beat`

---

## 6. Hub meta quests (Desa Purwa)
### 6.1 SQ-D1 "Lakon" (the wayang stage)
- Every finished re-telling (`SQ-S1`, `SQ-G1`, `SQ-M1`, `SQ-T1`) and every main-quest legend (`Sangkuriang`, `Ciung Wanara`, `Roro Jonggrang`, `Timun Mas`, `Ken Arok`) adds a lakon (9 total), plus the hero's own story in the Epilogue.
- 4 lakon gives **Flask Shard #3**; all 9 adds a special verse to the Epilogue kelir performance.

### 6.2 SQ-D2 "Pustaka" (the codex keeper, Nyai Rukmi)
- 25% codex: Ilmu M; 50%: **Lontar Kuno**; 75%: Ilmu L; 100%: keeper's blessing and credits tribute.

---

## 7. Quest & Narrative System (Technical Architecture)
Fits [architecture.md](architecture.md): data-driven resources, state in `Game`, signals in `Events`. No separate autoload.

### 7.1 Cross-Time Mechanics & Story Flags
1. **Cross-Time Laras Flags (`laras_key:<id>` & `laras_sabotage:<id>`):**
   - Set automatically when the corresponding `MemorySpot` inside `LC1`–`LC6` is completed (or when `memory_done:lc<n>` fires).
   - Stored in `Game.flags` (`flag:laras_key_archive_grate`, `flag:laras_sabotage_crater_seal`).
   - Zone doors/gates (`kabut.gd` / `shortcut.gd`) and boss scripts (`sangkuriang.gd`, `barma_wijaya.gd`, `bandung_bondowoso.gd`, `keris_gandring.gd`, `batara_kala.gd`) check `Game.has_flag("laras_sabotage_...")` to trigger vulnerabilities or show cracked-glyph indicators on the boss bar.
2. **Six Major Choices:**
   - Recorded in `Game.flags`: `choice_tell_ciung` / `choice_keep_secret` (Act I), `choice_freed` / `choice_handed` (Act II), `choice_mercy` / `choice_judgment` (Act III), `choice_reforge` / `choice_sink` (Act IV), `choice_offer_memory` / `choice_offer_song` (Act V), `choice_redeem_aria` / `choice_release_aria` (Act VI).
3. **Puzzles & Stalking Ambushes:**
   - `puzzle_solved:<id>`: emitted when multi-step environmental puzzles (name-stones, sluice wheels, archive cipher, mangrove beacons, sand markers) complete.
   - Buto Ijo's 3 stalking ambushes (`buto_ambush_1..3` in `tt_kulon`, `tt_kali`, `tt_beringin`) complete on `area_cleared:buto_ambush_<n>` when forced below HP thresholds (80% / 65% / 50%).

### 7.2 Dialogue, Topics & Scene Direction
1. **Dialogue Entries:**
   - Main-path and camp talks support 8–12 lines; story beats support 8–10 lines.
   - Entries with `"hub": true` (or choices ending in `topic:<key>`) loop quiet sub-entries (`"quiet": true`) until `"Leave / Continue"` is chosen, allowing full lore exploration without skipping quest progression.
2. **Scene Director (`ui/scene_director.gd`):**
   - Dialogue lines starting with `#` are director cues:
     - `#cam:<npc_id>`: Smooth camera pan to specified NPC, entity, or `#cam:hero`.
     - `#bars:on` / `#bars:off`: Eases cinematic letterbox bars in/out.
     - `#shake:<0-3>`: Triggers screenshake of intensity 0 to 3.
     - `#wait:<seconds>`: Holds a silent dramatic pause (up to 3 s).
   - Auto-direction smoothly frames speakers within 160 px during story beats.
3. **Choices with Consequences:**
   - Dialogue actions execute `remember:<key>`, setting `remember_<key>` flag and emitting `Events.consequence_noted`.
   - Triggers the `UI_Q_REMEMBER` banner ("<Character> will remember that you...") and records the entry in the Journal's Choices section.

### 7.3 Data Architecture
- `QuestData`: `id`, `name_key`, `desc_key`, `type` (main/side), `zone`, `steps: Array[QuestStep]`.
- `QuestStep`: `target`, `desc_key`, `recap_key`, `marker: {zone, pos}`, `count`, `sub_goals: Array`, `completes_on: String`.
- `DialogueData`: `npc_id`, `name_key`, `entries: Array` with conditions (`if`), text lines, and actions (`do`).

### 7.4 In-Game Guidance (HUD & World)
1. **Tracker Panel (HUD top-left, 156 px):**
   - Displays tracked quest title in amber tracked caps, an amber left edge, and the objective checklist (ui.md 2.1).
   - Objectives show active status (`bullet_now`, gold), completed status (`bullet_check`, dim), and open status (`bullet_open`). Multi-part or counted goals show progress `n/total`.
   - Starting a side quest automatically tracks it (`Game.pinned`), with fallback to main quest upon completion. Track/untrack toggle available in the Journal.
2. **World Navigation:**
   - Screen-edge directional arrow showing distance in meters (1 tile = 1 m) or destination zone name (`-> <zone name>`) for cross-region travel.
   - When the objective is on-screen, a floating gold diamond appears 46 px above the target with a distance pill.
   - The old compass UI is removed in favor of direct in-world guidance.

### 7.5 Banners & Cards
1. **Banners (HUD top-center):**
   - Concise gold banners for `NEW QUEST`, `QUEST UPDATED`, `QUEST COMPLETE`, and `UI_Q_REMEMBER`. Queued sequentially.
2. **Quest Cards (`ui/quest_card.gd`):**
   - Title card on main quest start (act name, title, stakes sentence).
   - Summary card on quest completion (title, Ilmu earned, items, codex unlocks).

### 7.6 Journal as Story Log
The Journal tab in the Esc/Tab menu functions as an ongoing chronicle:
- **Story Log:** Narrative paragraph detailing quest premise, sequential `_DONE` recap entries of finished steps, and the active objective.
- **Choices:** Chronicled log of all major choices and remembered story actions.
- **Clues:** Examined clues grouped by investigation arc (`hunt_id`) with associated notes and Kelir memories.

### 7.7 Text & String Tables
All player-facing text is localized via CSV string tables in `data/text/`:
- `quests.csv`: `Q_<ID>_TITLE`, `Q_<ID>_DESC`, `Q_<ID>_S<n>_OBJ`, `Q_<ID>_S<n>_DONE`, `Q_<ID>_S<n>_HINT`.
- `dialogue.csv`: `NPC_<id>_NAME`, `NPC_<id>_<n>`, `DLG_*`, `REMEMBER_*`.
- `codex.csv`: `CODEX_<ID>_TITLE`, `CODEX_<ID>_BODY`, `CODEX_<ID>_WEAK`.
- `ui.csv`: UI labels, verbs, and prompts.

### 7.8 Validation & Headless Checks
Headless test scripts verify integrity without opening the Godot editor:
- `tests/quest_test.gd`: Verifies step progression, signals, and multi-goal completion.
- `tests/quest_engine_test.gd`: Verifies auto-tracking, sub-goal focus, and done/total counters.
- `.docs/know_check.py`: Ensures every character is properly introduced before being named.
- `.docs/pacing_model.py`: Validates runtime budgets and pacing distribution across all acts.

---

## 8. Expanded NPC Table (Story v5)
| Role | Display Name (EN / ID) | NPC ID | Region & Act |
|------|------------------------|--------|--------------|
| Mother | Ibu | `ibu` | Desa Purwa (Prologue, Interlude, Epilogue) |
| Sister | Laras | `laras` | Desa Purwa, Playable in `LC1`–`LC6`, Epilogue |
| Village Dalang | Semar | `semar` | Desa Purwa, Gua Kala |
| Semar's Son | Cepot | `cepot` | Desa Purwa, Sunda, Mataram, Kidul, Epilogue (`SQ-C4`) |
| Western Prince | Ciung Wanara | `ciung_wanara` | Desa Purwa, Sunda, Galuh, Mataram, Interlude, Gua Kala |
| Eastern Prince | Hariang Banga | `hariang_banga` | Galuh, Mataram, Timur, Interlude, Gua Kala |
| Exiled Queen | Dewi Naganingrum | `naganingrum` | Tatar Sunda (`ts_situ`), Galuh, Epilogue |
| Cursed Naga-King | Prabu Nagawiru | `nagawiru` | Tatar Sunda (`ts_kawah`), Mataram (`kg_pamali`) |
| Kampung Elder | Sesepuh Kampung / The Kampung Elder | `sunda_elder` | Tatar Sunda (`ts_kampung`) |
| Elder's Grandson | Cucu Sesepuh / The Elder's Grandson | `sunda_grandson` | Tatar Sunda (`ts_kebun`) |
| Terrace Weaver | Sang Penenun / The Weaver | `sunda_weaver` | Tatar Sunda (`ts_sawah`) |
| Juru Pantun | Ki Darsa | `ki_darsa` | Tatar Sunda (`ts_leuweung`, `SQ-S1`) |
| Royal Chamberlain | Uwa Lengser | `lengser` | Keraton Galuh, Epilogue |
| Royal Archivist | Nyai Sekar | `nyai_sekar` | Keraton Galuh (`kg_pustaka`, **NEW in v5**) |
| Faceless Deserter | Ranga (Si Pembelot) | `faceless_deserter` | Galuh, Mataram, Timur, Kidul, Gua Kala (`SQ-C3`) |
| Trickster | Si Kabayan | `kabayan` | Keraton Galuh (`kg_pasar`, `SQ-G1`, **NEW in v5**) |
| Caged Queen | Sang Ratu / The Queen | `galuh_queen` | Keraton Galuh (`kg_keraton` / `kg_penjara`, `SQ-C2`) |
| Mataram Dalang | Ki Sumarto | `mataram_dalang` | Mataram (`mt_pasar`, `kg_pamali`), Epilogue |
| Ki Sumarto's Son | Sapto | `sapto` | Mataram / Pamali (`kg_pamali`), Epilogue |
| Lesung Leader | Nyai Gendhis | `lesung_women` | Mataram (`mt_wetan` / `mt_candi`, **Named in v5**) |
| Foothill Juru Kunci | Sang Juru Kunci | `juru_kunci` | Mataram (`mt_wetan`) |
| Master Empu | Mpu Wirasana | `timur_empu` | Tanah Timur (`tt_beringin` forge), Epilogue |
| Empu's Daughter | Ratna | `timur_daughter` | Tanah Timur (`tt_kulon` / `tt_beringin`), Epilogue (**Named in v5**) |
| Timun Mas's Mother | Mbok Srini | `mbok_srini` | Tanah Timur (`tt_kali`) |
| Unmasked Hunter | Aria Kebonan / Si Tanpa Ngaran | `aria_kebonan` | Every Act (`nameless_hunter`), Interlude (`desa_purwa`) |
| Coast Juru Kunci | Mbah Wiryo | `kidul_jurukunci` | Segara Kidul (`sk_pantai` / `sk_nelayan`), Epilogue |
| Young Diver | Sari | `kidul_sari` | Segara Kidul (`sk_nelayan` / `sk_bakau`, **NEW in v5**) |
| Codex Keeper | Nyai Rukmi | `nyai_rukmi` | Desa Purwa (`SQ-D2`) |

---

## 9. Quest flow v6: old → new (APPROVED 2026-11-11; overrides §4–§6 where they differ)
Story, characters, reveals, bosses and the six choices do not change. What changes is what the player's hands do, who asks for it, and why. **Step numbers stay the same in every quest** (so `step:<q>=<n>` conditions, saves and play tests keep working); a filler step is given a real job instead of being deleted. Only steps that change are listed; every other step keeps its event and gets new text only. Prop convention: a puzzle prop is an `npc.tscn` whose `npc_id` is also the flag it sets; art is `assets/art/story/<npc_id>.png` and `<npc_id>_on.png` once the flag is set.

Build pieces used (all exist in the engine today): **press-each** (N props, counted step), **in-order** (a prop answers only when the one before it is done), **write card** (`name_written`), **clue + memory**, **encounter**, **witness** (walk-in trigger, allowed only for "arrive / see / overhear"), **cast** (`spell_cast` counted).

### 9.1 Threads that run through every act
| Thread | Where it shows |
|---|---|
| **Laras's trail** | Each act opens with something of hers you already carry and closes with one new thing: ribbon (I) → hairpin + wall message (II) → Ka strip (III) → sight of her at the altar (IV). All of them go on her shelf in the Interlude (4.4), and three come back as the gap memories in Act VI. |
| **The morning game** | The three things Laras names in 0.1 (the cat, the well, the banyan) are the three details you must restore in gap memory `La` (5.4). |
| **Lamp oil** | Ibu sends you to buy oil (0.4); you light the stage lamps with it (0.7); lighting lamps by hand is then how every dusk-spirit is handled (1.8, 2.12, 4.13). |
| **Mask fragments** | One per act, always found after a boss, always followed by a Hunter memory; text now says "mask fragment" everywhere (1.22 said "seal stone"). |
| **Companions** | Ciung, Cepot, Hariang Banga and Ranga each get one line at every petilasan that reacts to the last choice or finished side quest. |
| **Side quests** | Each is offered by a main-path character on a main-path step (column "Hook"), and each leaves one later callback line. |

### 9.2 Prologue (MQ0)
| # | Old | New | Piece |
|---|---|---|---|
| 0.1 | "Catch Laras": run to one invisible square | Laras runs ahead and calls three places by name (the cat **Si Belang**, the well, the banyan root). Touch all three before she does | press-each x3 |
| 0.2 | Tea, then old couple | Same, but the couple's request is the reason for 0.3: their grandson Ciung will not come down from the banyan. Ibu's lines fixed so he is their grandson everywhere | talk x2 |
| 0.3 | "Climbing puzzle" = walk-in square; Ciung stays in the tree | Talk to Ciung under the tree (he refuses: he is guarding an egg), find his fallen basket, bring it back; he climbs down and walks with you | talk, clue, talk |
| 0.4 | Ask about the masked stranger | Ibu's errand: buy lamp oil for tonight. The stall-keeper mentions the masked man while pouring it. Then Cepot | talk x2 |
| 0.6 | "Write your names" = walk-in square, Laras absent | Laras is there holding the leaf. You trace **La**, the first letter of her name, on the real write card; she writes yours | write card |
| 0.7 | "Light four lamps" = one square | Four lamps around the stage, lit one by one with the oil; Cepot comments on each | press-each x4 |
| 0.9 | "Fight through the crowd" (no fight) | "Push through the crowd to Laras" (it is a run, and the text says so) | witness |
| 0.12 | Clear raid, leave | Same, plus Ibu at the west gate gives the reason to go and the second cup line | fight, talk |

### 9.3 Act I Tatar Sunda (MQ1)
| # | Old | New | Piece |
|---|---|---|---|
| 1.3 | Cepot talk has no Act I entry | Cepot is at the petilasan with a real conversation; he offers SQ-S4 here | talk |
| 1.8 | "Relight the outer lanterns" = one square | Three bamboo lanterns around the hamlet, each lit by hand while the mist spawns shades. This is the Sandekala fight in small | press-each x3 + encounter |
| 1.11 | "Align the stones" = square that ignores the stones | The three name-stones are raised in the order their carvings give (dawn, noon, dusk); a wrong stone sinks them back | in-order x3 |
| 1.15 | Step is in the paddies, wheels are at the lake | Two sluice wheels moved to the upper paddies; turn both, the water drops, the Weaver can reach you | press-each x2 |
| 1.22 | Recap says "seal stone" | First mask fragment, then H1 | text |
| 1.24 | Boeh Rarang never used | Before the fight you hang the cloth on the eastern post Laras marked in LC1, then face Sangkuriang | prop + boss |

### 9.4 Act II Keraton Galuh (MQG)
| # | Old | New | Piece |
|---|---|---|---|
| g.3 | Text flips between "storehouse" and "cockfight arena" | One place: the market storehouse where the bouts are rigged | text |
| g.4 | "Win the cockfight bouts" (you fight soldiers) | You fight the king's two champions in the ring. The second one's helmet falls: no face. First proof the court is the Hunter's | encounter x2 |
| g.5 | Lengser's first meeting can never play; mentions "Aksara Ja" (not a glyph) | Intro gate fixed; the Ja line removed | gate, text |
| g.7 | "Mirror-lamp cipher" = one square | Nyai Sekar's lamp and three mirrors: turn them in the order of the shelf marks until light falls on the scraped lontar | in-order x3 |
| g.9 | "Screens puzzle" = one square | Three folding screens to slide aside in the guest chamber; behind the last, Laras's hairpin | press-each x3 |
| g.13 | Wall message optional | Reading the wall is required to finish the step | clue |
| g.15 | **Choice 2 never offered** (condition points at step 7, Ranga appears at 14) | Fixed; Ranga's scene plays right after LC2, which is why you now know what he did for her | gate |

### 9.5 Act III Mataram (MQ2)
| # | Old | New | Piece |
|---|---|---|---|
| 2.1 | Two recruiters | Same, and Cepot is in the queue, signed up with both. SQ-C4 part 2 starts here whether or not you did part 1 | talk x2 |
| 2.4 | "Map three leads" with no reason | Ki Sumarto names them and each is his: the statue that still holds a letter, the graveyard where his son Sapto's name was taken, the lesung women who hear builders at night | talk |
| 2.5 | "Escort families" (nobody to escort) | "Clear the paddy road so the families can cross"; they thank you on the far side | encounter |
| 2.12 | "Align braziers" = one square | Four shrine braziers lit in the order of the juru kunci's chant | in-order x4 |
| 2.20 | Walk to the river | On the way, word from Ranga (freed) or Lengser (handed): the first pay-off of Choice 2 | witness + beat |
| 2.24 | "Halt the duel" | "Duel Hariang Banga at the ford" (you fight him; the truce is the scene after) | text |

### 9.6 Act IV Tanah Timur (MQ3)
| # | Old | New | Piece |
|---|---|---|---|
| 3.4 | "Learn Aksara Ta" (not a glyph); two walk-in squares | Mpu Wirasana shows how **Ha** puts out a curse stake; cast it on the two practice stakes | cast x2 |
| 3.5 | Mbok Srini's daughter lost in one line, home in another | One version, taken from `story.md` | text |
| 3.6 | "Test the seed pouch" = a fight | Scatter the seeds at the riverbed marker, then survive the charge they slow | prop + encounter |
| 3.7 | "Consecrate the pouches" = a fight | Set the needle, salt and terasi pouches at three banyan roots while he circles | press-each x3 + encounter |
| 3.15 | "Waymarkers" = one square | Three stone waymarkers, each touched in the gale to see the next | in-order x3 |
| 3.16 | Hariang Banga talk optional | Required: he reacts to Choice 3 (lancers if mercy) | talk |

### 9.7 Interlude and Act V (MQ4)
| # | Old | New | Piece |
|---|---|---|---|
| 4.5 | "Sit at the table" = square | Speak to each brother at the table; the mood follows Choice 3 | talk x2 |
| 4.8 | Walk south | Cepot is waiting at the south gate with a bundle from Ibu; SQ-C4 part 3 hook | talk + witness |
| 4.11 | Finishes after the first verse | All three verses needed; each family gives theirs after a small favour | clue x3 |
| 4.13 | "Relight beacons" = one square | Three tidal beacons in the mangrove, lit with Sari as the water rises | press-each x3 |
| 4.19 | Unclear what you do | Call her name on the write card (La), then the offering choice | write, choice |

### 9.8 Act VI Gua Kala (MQ5)
| # | Old | New | Piece |
|---|---|---|---|
| 5.3 | "Part the barrier with Ombak" (nothing to cast at) | Cast Ombak at the barrier, then fight in | cast + encounter |
| 5.6 | "Name chimes" = square | Three whispering trees; each goes quiet when you answer it with the name of someone you helped (the grandson, Sapto, Ratna) | press-each x3 |
| 5.11 | "Chant the hymn" | "Take the dalang's seat and practise the Ruwatan" (it is a memory, and the text says so) | text |
| 5.13 | "Perform the Ruwatan" | "Calm Batara Kala" (it is the fight) | text |

### 9.9 Side quests
| Quest | Hook (main step, who) | What changes | Callback |
|---|---|---|---|
| SQ-S1 Lutung | 1.5, kampung elder | "Restore the water puzzle" dropped; cleanse the spring guardians | Purbasari's fruit at the Interlude table |
| SQ-S2 Kuntilanak | 1.5, Kepala Desa | Carving the name is a real write card | The grave has flowers in the Epilogue |
| SQ-S3 Angklung | 1.1, grandson | 3 tubes (was counted as 5); hang them low to high on the frame | Angklung heard in the kampung afterwards |
| SQ-S4 Cepot 1 | 1.3, Cepot | Text matches the boar fight | Cepot brags about it in 2.1 |
| SQ-G1 Kabayan | g.2, market informant | Text only | Kabayan heckles the unmasked king's guards |
| SQ-G2 Ririwa | g.9, old maid | Already real | Lengser adds the name to the palace roll |
| SQ-C1 Rooster | g.1, Ciung | "Perch puzzle" becomes three handfuls of grain laid across the roofs | The rooster crows at the Pamali truce |
| SQ-M1 Jaka Tarub | 2.5, a refugee | Text only | Nawang Wulan's line at the sea (4.10) |
| SQ-M2 Wewe | 2.4, Ki Sumarto | Text only | The boy is at the wayang stage |
| SQ-M3 Tuyul | 2.3, the smith after the defence | The bean trap is a thing you set down | Cheaper smith prices line |
| SQ-M4 Gamelan | 2.4, Ki Sumarto | Carry the gong back and hang it | Gong sounds in K-III |
| SQ-C2 Letters | 2.24, Hariang Banga | Text only | Read on Ibu's table (already there) |
| SQ-C3 Ranga | g.15 | Now reachable on both choices (Lengser's notes if handed) | Act VI gate |
| SQ-C4 Cepot 2, 3 | 2.1 and 4.8 | No longer needs SQ-S4 | Cepot at the Act VI gate |
| SQ-T1 Ande-Ande | 3.5, Mbok Srini | Striking the river is a thing you do at the jetty | Ferry runs in the Epilogue |
| SQ-T2 Banaspati | 3.1, Ratna | Opening the channel is a wheel you turn | Fireflies line if Choice 4 = sink |
| SQ-T3 Pamor | 3.3, Mpu Wirasana | Text matches defend-then-return | Ratna names the blade |
| SQ-T4 Kuda Kepang | 3.3, troupe at the forge road | Text only | Troupe dances in the Epilogue |
| SQ-K1 Hatchlings | 4.9, fisher's child | Text only | Turtles on the beach in C4 part 3 |
| SQ-K2 Bajul Putih | 4.10, Mbah Wiryo | Text only | Mbah Wiryo's line at the cliff |
