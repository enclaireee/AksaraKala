# World

An open map of connected regions on the island of Java (Sunda and Javanese lands). Areas join at their edges and load when crossed. Legend details fact-checked Nov 2026 (secondary sources). Synced to **Story v5 (49 areas across 6 regions + Desa Purwa hub)**.

## Layout (west to east)
```
 [Tatar Sunda (8)]---[Desa Purwa (1)]---[Keraton Galuh (7)]---[Mataram (8)]===[Tanah Timur (8)]
        :                   |    |                                                   |
        :                   |    +---------------[Segara Kidul (7)]------------------+
        :                   |                            |
        :             [Gua Kala (7)]  (from Segara Kidul or Desa Purwa; opens on quest:mq4=done)
        :................................................:
 --- link   === link plus a back-road shortcut   ... back-route shortcut
```
- **Main path (Story v5, 138 steps, ~21.5 h):** Prologue Desa Purwa -> Act I Tatar Sunda -> Act II Keraton Galuh -> Act III Mataram -> Act IV Tanah Timur -> Interlude Desa Purwa -> Act V Segara Kidul -> Act VI Gua Kala -> Playable Epilogue Desa Purwa.
- **Total Areas:** **49 area scenes** in `zones/`: `1` Desa Purwa + `8` Tatar Sunda + `7` Keraton Galuh + `8` Mataram + `8` Tanah Timur + `7` Segara Kidul + `7` Gua Kala = 46 story areas, plus `3` dev rooms (`hub`, `sanggar`, `test_room`). `Zones.ZONES` lists 47 ids (the 46 plus `hub`). Every region has a full 7-8 area interlocking layout so late-game acts match the scale and depth of early acts.

## Technical frame
- Viewport 480x270, 16 px tiles (30x17 tiles per screen), integer-scaled. See [architecture.md](architecture.md).
- Each **Area** is one zone scene of 2x2 to 3x3 screens (60x34 to 90x51 tiles). Area IDs use `<prefix>_<name>`: `ts_` Tatar Sunda, `kg_` Keraton Galuh, `mt_` Mataram, `tt_` Tanah Timur, `sk_` Segara Kidul, `gk_` Gua Kala.
- **Cross-time Laras keys (`laras_key:<id>`):** In Story v5, Laras's playable chapters (`LC1`–`LC6`) unlock physical grates, crypt doors, wind-tunnels, and tidal gates that persist in the area scenes when the hero arrives.

## Inter-Region Links
| Link | Area A | Area B | Kind | Opens |
|------|--------|--------|------|-------|
| Hub to Tatar Sunda | `desa_purwa` (W) | `ts_kebun` | link | always |
| Hub to Keraton Galuh | `desa_purwa` (E) | `kg_alun` | link, kabut | `mq1_10` (end of Act I) |
| Galuh to Mataram | `kg_pamali` (E) | `mt_gapura` (W) | link | `mqg_7` (throne coup complete) |
| Mataram to Tanah Timur | `mt_wetan` | `tt_kulon` | link, kabut | `mq2_9` (Pamali truce complete) |
| Mataram back road | `mt_tegal` | `tt_sabana` | shortcut `sc:mt_tt` | from Tanah Timur side |
| Hub to Segara Kidul | `desa_purwa` (S) | `sk_pantai` | link, kabut | `mq4_i5` (Interlude Semar talk) |
| Tanah Timur to Segara Kidul | `tt_pesisir` | `sk_karang` | link, kabut | `mq4_9` (`quest:mq4=done`, back route) |
| Tatar Sunda back route | `ts_situ` | `sk_tebing` | shortcut `sc:ts_sk` | from `sk_tebing` |
| Hub to Gua Kala | `desa_purwa` (N) | `gk_pelataran` | link, kabut | `mq4_9` (`quest:mq4=done`) |
| Segara Kidul to Gua Kala | `sk_keraton` | `gk_pelataran` | link, kabut | `mq4_9` (`quest:mq4=done`) |

---

## Town design rules (Phase 6c, 2026-11-07, **ASSUMED**, numbers **TUNE**)
Research summary: Eastward (gamedeveloper.com "Road to the IGF: Pixpil's Eastward"), Sea of Stars (mobilesyrup.com 2023-09-11 level-design interview), Stardew Valley NPC schedules (wiki.stardewvalley.net/NPCs), and Knight Shift's devlog (itch.io/devlog/314447). The engine side is in [architecture.md](architecture.md) 9 "Towns".
1. **Many pockets, not one field.** A town is a set of dense yard-and-lane pockets around one plaza, with open lanes between them. Each town has one landmark that the main lanes have sightlines to: the gapura gate, a giant waringin, a joglo pendopo, or a leuit cluster.
2. **Scale.** Towns are drawn at 1x. Houses are 6-10 tiles wide (a landmark up to 14), and 2-3 fit on a screen. Lanes are 2-3 tiles wide, the plaza is at least 10x8, and doors are 1-2 tiles.
3. **Variety from a kit.** Each building takes a roof type, a wall material, a door, a palette and extras. No two neighbours share both roof and palette. Every building gets one unique detail.
4. **Every yard is dressed.** Each house has a threshold (a step, mat or pot), a side prop (firewood, gentong jar or bird cage) and a fence or hedge run (`-`). Some have a garden bed (`'`). The props cluster at doors, walls and lane edges, and the lane centres stay clear. Aim for about 15-25 props per screen.
5. **Life.** Wandering villagers at 3-6 per screen, chickens, cats, ducks and goats at 2-4 per screen, and desynced 2-4 frame loops: smoke, laundry and flags.
6. **Bigger at the edges.** The map border carries back-row rooftops (`[` blocks against the wall), tree lines and a half-seen gate, so the town reads as continuing past the edge.
7. **Ground wear.** Worn paths with soft edges, mud at doors and wells, and decals.
8. **Culture props** (**VERIFY** the details before shipping): sumur well with a pulley, pancuran bamboo spout, kolam fish pond, leuit or lumbung, gardu with a kentongan, gapura, warung, tampah of drying rice or chilli, jemuran clothes line, chicken coop, saung or bale pavilion, lesung rice mortar, firewood stack, banana and coconut palms, a pedati cart, and a waringin with a small shrine.
9. **Architecture by region** (**VERIFY**):
   - Sunda: julang ngapak, badak heuay, parahu kumureb and jolopong roofs in black ijuk; bilik walls; short stilts on umpak stones; leuit at the village edge (Kampung Naga).
   - Java (Galuh, Mataram): kampung, limasan and joglo roofs in red genteng; teak and gebyok walls; a pendopo.
   - Kidul: stilt houses with nipah thatch, jukung boats, drying racks and nets.
   - Pasar: warung stalls (`{`) with cloth or tin awnings.

## Regions & Area Roster (49 Areas)

### 0. Desa Purwa (1 Area: `desa_purwa`) — Prologue, Interlude & Playable Epilogue
- **Regional character:** **Ibu**.
- **State changes across the campaign:**
  1. **Prologue Day (`MQ0` 0.1–0.8):** Sunny festival preparation, tag game lane, banyan ridge, sanggar, morning market, lit wayang stage (`K0`).
  2. **Morning After (`MQ0` 0.9–0.12):** Burned wayang stage, amnesia in Ibu's house, Faceless raid in the square.
  3. **Interlude under the Eclipse (`MQ4` 4.1–4.8):** Darkened sky, northern fog at the cave gate, three village doorposts (`door_a`, `door_b`, `door_c`), brothers' dinner table (`purwa_table`), broken Aria Kebonan by the ashes.
  4. **Playable Epilogue (`mq5_4`):** Restored festival day populated by allies and regional friends shaped by your **6 Major Choices**.

### 1. Tatar Sunda (8 Areas) — Act I: "The Crater Seal"
- **Areas:** `ts_kebun` (tea terraces), `ts_kampung` (stilt-house village), `ts_leuwi` (river gorge & dusk hamlet), `ts_leuweung` (deep bamboo forest & Batu Tulis), `ts_sawah` (terraced paddies & Weaver's loom), `ts_situ` (flooded lake & Naganingrum's exile), `ts_kawah_jalan` (volcanic ascent), `ts_kawah` (Tangkuban Perahu crater rim).
- **Structural identity:** Classic **Folklore Hunt (`Sandekala`)** in the gorge + **Rising Floodwaters & Cross-Time Sabotage (`Faceless Captain` & `Sangkuriang`)** as the dammed river floods `ts_sawah` and `ts_situ`.
- **Laras cross-time mechanics (`LC1`):** Sets `laras_sabotage:crater_seal` (cracks the dawn groove on the seal-stone) and `laras_key:crater_post` (marks the eastern post for the *Boeh Rarang*).
- **Petilasans:** 2 (`sunda_1` in `ts_kebun`, `sunda_2` in `ts_kawah_jalan`).

### 2. Keraton Galuh (7 Areas, Expanded in v5) — Act II: "The Borrowed Face"
- **Areas:**
  1. `kg_alun` — Royal square & tournament ring.
  2. `kg_pasar` (**NEW in v5**) — **Pasar Kuta**, the bustling outer market and storehouses where the king's tournament riggers and prisoner wagons operate (`SQ-G1` Si Kabayan, `SQ-C1` Ciung's Rooster).
  3. `kg_pustaka` (**NEW in v5**) — **Balai Pustaka**, the royal palm-leaf archive overseen by **Nyai Sekar**, holding the mirror-lamp cipher and King Nagawiru's scraped genealogy.
  4. `kg_kaputren` (**NEW in v5**) — **Kaputren**, the royal women's quarters and gardens where Laras was held before her transfer (`LC2`, `SQ-G2` Ririwa).
  5. `kg_penjara` — Dungeon stairs, cell yard (Wagon Escort setpiece), and Ranga the Deserter's post (**Choice 2**).
  6. `kg_keraton` — Inner palace garden (`galuh_1`), portrait gallery (`K-II`), and Barma Wijaya's throne room.
  7. `kg_pamali` — The eastern Pamali river border and sacred ford (used in Act III's finale duel against Hariang Banga and **Choice 3**).
- **Structural identity:** **Undercover Palace Intrigue, 3-Wing Faction Heist & Throne-Room Coup.**
- **Laras cross-time mechanics (`LC2`):** Sets `laras_key:archive_grate` (unlocks the drainage passage from `kg_pustaka`/`kg_penjara` into `kg_keraton`) and `laras_sabotage:glamour_seal` (steals Barma Wijaya's signet wax so his Glamour copies shatter in one glyph hit).
- **Petilasans:** 2 (`galuh_1` in `kg_keraton` garden, `galuh_2` at `kg_pamali` camp).

### 3. Mataram (8 Areas) — Act III: "Blood on the Pamali"
- **Areas:** `mt_gapura` (border gate & two-bank recruiters), `mt_pasar` (river market & Ki Sumarto's stage), `mt_sawah` (flooded paddies & Nawang Wulan's hut), `mt_reruntuhan` (sunken temple ruins & `arca_base`), `mt_kuburan` (war graveyard), `mt_wetan` (foothill shrine & Nyai Gendhis's lesung yard), `mt_tegal` (plain of rising spirit-pillars), `mt_candi` (Candi Seribu camp, crypt & Bondowoso arena).
- **Structural identity:** **Two-Front War Campaign, Real-Time Night-Building Siege (`Bandung Bondowoso`) & River-Ford Duel (`Hariang Banga`).**
- **Laras cross-time mechanics (`LC3`):** Sets `laras_key:candi_crypt` (unbars the subterranean crypt flank into `mt_candi`) and `laras_sabotage:bondowoso_pillar` (hides the master chisel so Bondowoso's pillars crack on every lesung beat).
- **Petilasans:** 2 (`mataram_1` in `mt_pasar`, `mataram_2` in `mt_candi`).

### 4. Tanah Timur (8 Areas) — Act IV: "The Seven-Generation Blade"
- **Areas:** `tt_kulon` (western savanna — **Buto Ijo Stalking Ambush #1**), `tt_sabana` (savanna hub, petilasan `timur_1`), `tt_kali` (dry riverbed & Mbok Srini's hut — **Buto Ijo Stalking Ambush #2**), `tt_beringin` (ancient banyan grove — **Buto Ijo Stalking Ambush #3** & Mpu Wirasana's forge), `tt_ladang` (cursed dry fields & Buto Ijo's lair arena), `tt_pesisir` (volcanic ash coast), `tt_pasir` (blinding Sea of Sand & stone waymarkers), `tt_candi` (Eastern Shrine of the Keris & the Nameless Hunter).
- **Structural identity:** **3-Zone Stalking Predator (`Buto Ijo`), 7-Generation Blood-Curse Mystery (`Keris Mpu Gandring`) & Personal Showdown (`The Nameless Hunter`).**
- **Laras cross-time mechanics (`LC4`):** Sets `laras_key:sand_tunnel` (opens the buried wind-tunnel shortcut in `tt_pasir`) and `laras_sabotage:keris_seventh_stake` (binds her *Ka* stroke onto the seventh curse stake at `tt_candi`).
- **Petilasans:** 2 (`timur_1` in `tt_kulon`, `timur_2` in `tt_pasir`).

### 5. Segara Kidul (7 Areas, Expanded in v5) — Act V: "The Sea Does Not Forget"
- **Areas:**
  1. `sk_pantai` — Black-sand beach and turtle dunes (`kidul_1`, `SQ-K1`, `SQ-C4` Part 3).
  2. `sk_nelayan` (**NEW in v5**) — **Kampung Nelayan**, the stilt-house fishing village where **Mbah Wiryo**, young diver **Sari**, and the three coastal families live (`K8` sea-song verses).
  3. `sk_bakau` (**NEW in v5**) — **Hutan Bakau**, the flooded coastal mangrove forest and river mouth holding the three tidal beacons and `SQ-K2` Bajul Putih Tua's lagoon.
  4. `sk_karang` — Low-tide coral reef (**Sacred Trial I: Trial of the Torch-Lines**).
  5. `sk_gua` (**NEW in v5**) — **Gua Karang**, the echoing sunken sea cavern where Laras's `LC5` bronze bells lower the abyssal barrier (**Sacred Trial II: Trial of the Abyssal Current**).
  6. `sk_tebing` — Storm-swept cliff path and cliff shrine (`kidul_3`, `K9`, **Choice 5: The Sea's Offering**).
  7. `sk_keraton` — Sea Pavilion court (`kidul_2`, **Sacred Trial III: The Trial of the Waves**, Sea Altar for `jawa_ka` *Ombak*).
- **Structural identity:** **Coastal Community Healing, Sunken Cavern & Three Sacred Sea Trials.**
- **Laras cross-time mechanics (`LC5`):** Sets `laras_key:tidal_gate` (rings the three sunken bells to open the abyssal causeway in `sk_gua`).
- **Petilasans:** 3 (`kidul_1` in `sk_pantai`, `kidul_3` in `sk_tebing`, `kidul_2` in `sk_keraton`).

### 6. Gua Kala (7 Areas, Expanded in v5) — Act VI: "Into the Maw of Time"
- **Areas:**
  1. `gk_pelataran` (**NEW in v5**) — **Pelataran Waktu (Courtyard of Time)**, the outer temple forecourt where Ciung Wanara, Hariang Banga, and your gathered allies hold the line against the shadow tide, and where the ancestors' memorial stone stands (**Choice 6: Aria Kebonan's Name**).
  2. `gk_mulut` — The Cave Mouth and the first Prologue **Gap Memory `La` (The Morning Tag Game)**.
  3. `gk_pasir` — The Hourglass Sands and its western/eastern time-wards.
  4. `gk_hutan` (**NEW in v5**) — **Hutan Lupa (The Forgotten Woods)**, a petrified forest of whispering name-trees and chime puzzles.
  5. `gk_lupa` — The Abyss of Forgetting and the second Prologue **Gap Memory `Ra` (The Two Cups of Tea)**.
  6. `gk_jembatan` (**NEW in v5**) — **Jembatan Bayang (The Shadow Bridge)**, spanning the chasm of eaten time where echoes of past bosses manifest, leading to the final petilasan (`kala_1`), **Gap Memory `Sa`**, `K10` (*Murwakala*), `K7`, and `LC6`.
  7. `gk_ruang_kala` — The Maw of Time, arena of the **Dual-Perspective Finale against Batara Kala**.
- **Structural identity:** **Allied Defense, Three-Realm Memory Descent & Dual-Perspective Finale.**
- **Laras cross-time mechanics (`LC6`):** Sets `laras_sabotage:kala_eclipse` (Laras speaks the true names of the stolen letters from inside Kala's shadow during Phases 2 & 3).
- **Petilasans:** 2 (`kala_0` in `gk_pelataran`, `kala_1` in `gk_jembatan` before `gk_ruang_kala`).
