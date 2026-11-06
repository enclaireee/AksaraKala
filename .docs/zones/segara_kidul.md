# Segara Kidul (region id `segara_kidul`), Act 4

Area graph on paper. Step 1 of the world design workflow ([AGENTS.md](../../AGENTS.md) section 5), graph level only: no tile maps until Phase 5. Prefix `sk_`. Sources: [world.md](../world.md) (World structure, link table, Segara Kidul, Checkpoints), [bestiary.md](../bestiary.md) (Zone 4, Encounters, Glyph weaknesses), [quests.md](../quests.md) (MQ4, SQ-K1, SQ-K2, 7.5, 9). Format follows [tatar_sunda.md](tatar_sunda.md). Scope is P1: the whole region is skipped in a P0 build.

Look: black-sand cliffs, a green sea, a palace beneath the waves. The landmark is the trial site, the tidal flat in `sk_pantai`. It is a wide stretch of wet black sand with three weathered stone stumps in a row. From the first spawn (`from_desa_purwa`) the player sees it below the dunes, and beyond it a green glow under the water where the palace sleeps, with a stone sea arch standing offshore. The glow is the keraton, so the end of the region is in view at the start. Nyi Roro Kidul is shown with respect: she is never fought, never touched, and no enemy is called her servant. The green association is told as a belief by the juru kunci (wearing green on the south coast is said to attract her), never as a punishment.

Areas: 4. Critical path: `sk_pantai` (rest, trial) -> `sk_karang` -> `sk_keraton` -> `gk_mulut`. Off the path: `sk_tebing` (optional cliff, branches off `sk_pantai`, drops back onto the path), the Bajul Putih Tua cove (SQ-K2, inside `sk_karang`).

## Area table
Sizes: screens are 30 x 17 tiles. Spawn ids follow `from_<other area id>`.

| id | size (screens, tiles) | look | purpose | contents |
|----|-----------------------|------|---------|----------|
| `sk_pantai` | 3x3, 90x51 | Black-sand beach, dunes in the north, a wide tidal flat in the south, a green sea. A barred coral gate (the gerbang) stands on the south-east shore | Arrival, teach encounters, rest, the trial of the waves, turtle nest | Spawns `from_desa_purwa` (N), `from_sk_karang` (E), `from_sk_tebing` (W), `from_sk_keraton` (gerbang, SE). Petilasan `kidul_1` (north edge of the flat, before the trial). NPCs `kidul_jurukunci`, `kidul_nelayan_anak`, `semar` (at `kidul_1`). Encounters `kidul_pantai_1`, `kidul_pantai_2`, `kidul_pantai_3`, trial `kidul_trial`. Chest `kidul_chest_1` (behind driftwood in the dunes). Turtle nest `kidul_nest` (dunes), water trigger `kidul_tukik_laut` (shore). Shortcut gate `sc:sk_gerbang` (arrival side). Quest markers `kidul_edge`, `kidul_jurukunci`, `kidul_trial`, `kidul_nelayan_anak` |
| `sk_karang` | 3x2, 90x34 | Reef of dark rock and tide pools under cliffs, a long sandbar, a fishing hut | East entry from Tanah Timur, the long way to the keraton, the Bajul Putih Tua cove | Spawns `from_tt_pesisir` (E), `from_sk_pantai` (W), `from_sk_keraton` (S causeway). NPC `kidul_nelayan_tua` (hut, west end). Encounters `kidul_karang_1`, `kidul_karang_2`, `kidul_karang_3`. Elite room `kidul_elite_cove` (SQ-K2): Bajul Putih Tua. Chest `kidul_chest_2` (hidden tide pool between rocks). Quest markers `kidul_nelayan_tua`, `kidul_elite` |
| `sk_tebing` | 2x3, 60x51 | Tall black cliffs, a switchback stair, a sea cave, wind and gulls | Optional loop branch. Holds the Segara Kidul end of `sc:ts_sk`. Ends in a drop onto the keraton | Spawns `from_sk_pantai` (S), `from_ts_situ` (the shortcut door, N). Encounters `kidul_tebing_1`, `kidul_tebing_2`. Chest `kidul_chest_3` (sea cave, reached by a narrow ledge). Shortcut gate `sc:ts_sk` (opens from here). Drop `D1` at the cliff edge (east side). Quest marker `kidul_tebing` (none required, pointer for the shortcut hint only) |
| `sk_keraton` | 3x2, 90x34 | Outer causeway and court of green-glass stone over the sea, then a calm inner pendopo (open hall). Waves lap at the walls | Last rest, codex, the exit to Gua Kala | Spawns `from_sk_karang` (E), `from_sk_tebing` (drop landing, NE), `from_gk_mulut` (W exit). Encounter `kidul_keraton_1` (outer court only). Petilasan `kidul_2` (inner pendopo, right before the kabut). Codex spot `kidul_keraton_codex` (pendopo, Nyi Roro Kidul as belief). Shortcut gate `sc:sk_gerbang` (opens from here). Kabut `mq4_3` to `gk_mulut`. No fight in the pendopo. Quest marker `kidul_keraton` |

## Region graph
`==K==` kabut, `--` link, `=sc=` shortcut, `~D~>` drop (one way).
```
  [ts_situ] =sc:ts_sk=  [sk_tebing]
  (Tatar Sunda)              |  \
                             |   ~D1~>
                        L2 (link)        \
                             |            v
 [desa_purwa] ==K mq3_8== [sk_pantai] --L1-- [sk_karang] ==K mq3_8== [tt_pesisir]
                             ^  (kidul_1)          |
                             |                  L3 (link)
                             |                     |
                             +===sc:sk_gerbang=== [sk_keraton] (kidul_2) ==K mq4_3== [gk_mulut]
                                                  ^ D1 lands here
```
Critical path: `desa_purwa` or `tt_pesisir` -> `sk_pantai` (trial) -> `sk_karang` -> `sk_keraton` -> `gk_mulut`.

### Link table
| id | from area | to area | kind | gate flag | spawn ids |
|----|-----------|---------|------|-----------|-----------|
| X1 | `desa_purwa` (S) | `sk_pantai` | link, kabut | `mq3_8` | `from_desa_purwa` (in `sk_pantai`), `from_sk_pantai` (in `desa_purwa`) |
| X2 | `tt_pesisir` | `sk_karang` | link, kabut | `mq3_8` | `from_tt_pesisir`, `from_sk_karang` (in `tt_pesisir`) |
| L1 | `sk_pantai` | `sk_karang` | link | none | `from_sk_karang` (in pantai), `from_sk_pantai` (in karang) |
| L2 | `sk_pantai` | `sk_tebing` | link | none | `from_sk_tebing` (in pantai), `from_sk_pantai` (in tebing) |
| L3 | `sk_karang` | `sk_keraton` | link | none | `from_sk_keraton` (in karang), `from_sk_karang` (in keraton) |
| D1 | `sk_tebing` | `sk_keraton` | drop (one way) | none | `from_sk_tebing` (landing in keraton). No exit leads back up |
| S1 | `sk_keraton` | `sk_pantai` | shortcut `sc:sk_gerbang` | `sc:sk_gerbang` | `from_sk_keraton` (in pantai), `from_sk_pantai` (in keraton) |
| S2 | `sk_tebing` | `ts_situ` | shortcut `sc:ts_sk` | `sc:ts_sk` | `from_ts_situ` (in tebing), `from_sk_tebing` (in ts_situ) |
| X3 | `sk_keraton` | `gk_mulut` | link, kabut | `mq4_3` | `from_sk_keraton` (in gk_mulut), `from_gk_mulut` (in keraton) |

`mq3_8` is set by MQ3 step 3.8 (`talked_to:semar`, the return after the keris boss; main-session call, matching quests.md and the `mq1_10` pattern). `mq4_3` is set by MQ4 step 4.3 (`trial_completed:kidul`). Both are **ASSUMED** names, in the `mq<act>_<step>` form tatar_sunda.md uses. A kabut is lifted by a story flag, never by a glyph.

### Shortcut table
| id | gate area | opens from | leads back to |
|----|-----------|------------|---------------|
| `sc:ts_sk` | `sk_tebing` (north door, a rope-and-timber stair up the cliff) | `sk_tebing` only. From `ts_situ` the door is a sealed rock face | `ts_situ`, one link from the Tatar Sunda crater path and `sunda_2` (**ASSUMED**, see conflicts). Opening it needs a first visit to Segara Kidul, so it never skips ahead |
| `sc:sk_gerbang` | `sk_keraton` (west wall of the outer court, a coral gate with a latch on this side) | `sk_keraton` only. From `sk_pantai` it is a barred gate that can be seen but not opened | `sk_pantai`, next to petilasan `kidul_1` |

## Loops, drop, critical path, optional areas
Loops (each closes with a shortcut or a drop):
1. **Loop A:** `sk_pantai` -> L1 -> `sk_karang` -> L3 -> `sk_keraton` -> `sc:sk_gerbang` -> `sk_pantai`. First trip: the long walk through the reef. After the gerbang is open: the keraton is one gate from `kidul_1`.
2. **Loop B:** `sk_pantai` -> L2 -> `sk_tebing` -> D1 (drop) -> `sk_keraton` -> `sc:sk_gerbang` -> `sk_pantai`. First trip: up the cliff and down the slide. Later trips: the gerbang.

Drop: D1, a ledge-and-slide at the cliff edge of `sk_tebing` onto the keraton causeway. Nothing climbs back up. The player lands at the east side of the keraton outer court, near `kidul_2` and the gerbang latch, so a drop never strands anyone.

Critical path (MQ4): arrive in `sk_pantai` (from the hub or via `sk_karang`), meet the juru kunci, rest at `kidul_1`, pass the trial, learn Jawa Ka, then `sk_karang` -> `sk_keraton` -> kabut -> `gk_mulut`. A player who enters from `tt_pesisir` walks west through `sk_karang` to `sk_pantai` first, then back east.

Optional areas: `sk_tebing` branches off `sk_pantai` (loop B), so the way back is one drop plus one gate, never a long walk. The Bajul Putih Tua cove is a side room of `sk_karang`, on loop A. The whole critical path can be walked without Jawa Ka, and without `sk_tebing`.

## Encounters
Newest glyph note: Jawa Ka (Ombak) has no enemy weakness ([bestiary.md](../bestiary.md)); it is the clean answer to Ula Segara's water arc and Lampor lines (pushes them back, destroys projectiles). It arrives after the trial, so it is tested in `sk_karang` / `sk_keraton` encounters.

Rooms with 4 or more enemies are at least 15 x 9 tiles. Offsets are not set yet (Phase 5). "Position" is a rough place in the area.

| encounter id | area | position | waves (enemy mix) | clean answer |
|--------------|------|----------|-------------------|--------------|
| `kidul_pantai_1` | pantai | north dunes | 3 Lampor (one line) | Ca Burst. Teaches Lampor |
| `kidul_pantai_2` | pantai | shore path | 1 Ula Segara, 2 Lampor | Ka Bolt on the spit wind-up. Teaches Ula Segara |
| `kidul_pantai_3` | pantai | dune lane (10-tile straight lane) | 1 Bajul Putih | Ga Ward on the lunge. Teaches Bajul Putih |
| `kidul_trial` | pantai | tidal flat | W1: 5 Lampor in two lines. W2: 2 Ula Segara, 3 Lampor. W3: 1 Bajul Putih, 2 Lampor | W1 Ca Burst, W2 Ka Bolt, W3 Ga Ward ([bestiary.md](../bestiary.md) trial of the waves). Waves rise out of the shallows with a 0.5 s warning, in view |
| `kidul_karang_1` | karang | east entry | 3 Lampor | Ca Burst. Teaches Lampor for players who enter here |
| `kidul_karang_2` | karang | tide pools | 1 Ula Segara, 2 Lampor | Ka Bolt, or Ombak after the trial |
| `kidul_karang_3` | karang | reef lane (8+ tile lane) | 1 Bajul Putih, 2 Lampor | Ga Ward |
| `kidul_elite_cove` | karang | cove (optional, SQ-K2) | 1 Bajul Putih Tua (elite, stays dead) | Own mechanics: elite, no weakness. Ga Ward still works on the lunge (**ASSUMED**) |
| `kidul_tebing_1` | tebing | lower stair landing | 4 Lampor (one line) | Ca Burst |
| `kidul_tebing_2` | tebing | upper ledge | 1 Ula Segara, 1 Bajul Putih, 2 Lampor | Ka Bolt, Ga Ward |
| `kidul_keraton_1` | keraton | outer court | 1 Ula Segara, 3 Lampor | Ombak (water arc and Lampor line), Ka Bolt works too |

Counts: 10 encounters plus the elite room (the miniboss slot). Newest glyph: Ombak has a clean answer at `kidul_karang_2`, `kidul_tebing_2` and `kidul_keraton_1`.

## Points of interest
| Thing | Count | Where |
|-------|-------|-------|
| Boss arena | 0, the trial site instead | `sk_pantai` tidal flat (`kidul_trial`) |
| Elite room | 1 | `kidul_elite_cove` in `sk_karang` |
| NPCs | 4 (+ Nyi Roro Kidul as a presence) | `kidul_jurukunci`, `kidul_nelayan_anak`, `semar` in pantai; `kidul_nelayan_tua` in karang. Nyi Roro Kidul (`kidul_ratu`, ASSUMED) is a green glimmer and a voice, not a talkable NPC |
| Secrets | 3 | `kidul_chest_1` (pantai), `kidul_chest_2` (karang), `kidul_chest_3` (tebing) |
| Codex spot | 1 | `kidul_keraton_codex` (pendopo) |
| Petilasans | 2 | `kidul_1` (pantai), `kidul_2` (keraton) |

## Quest step locations
Marker form `{zone: "segara_kidul", id: ...}`. Ids from quests.md are marked (Q). Everything else is **ASSUMED**.

| Step | Marker id | Area | Event string |
|------|-----------|------|--------------|
| MQ4 4.1 reach the southern shore | `kidul_edge` | `sk_pantai` or `sk_karang` (first area entered) | `zone_entered:segara_kidul` (Q) |
| 4.2 speak with the juru kunci | `kidul_jurukunci` | `sk_pantai` | `talked_to:kidul_jurukunci` (Q). He explains respect for the sea and tells the green belief as belief |
| 4.3 face the trial of the waves | `kidul_trial` | `sk_pantai` tidal flat | `trial_completed:kidul` (Q). Sets `mq4_3`, lifts the kabut at `sk_keraton` |
| 4.4 receive the final letter | `kidul_trial` | `sk_pantai` tidal flat | `glyph_learned:jawa_ka` (Q). Nyi Roro Kidul speaks once from a distance after the last wave, the sea goes still, and the glyph and Kain Hijau are given as a gift. Sets `mq4_4` |
| SQ-K1 start | `kidul_nelayan_anak` | `sk_pantai` | `talked_to:kidul_nelayan_anak`. Unlock: `zone_entered:segara_kidul` (ASSUMED) |
| SQ-K1 (1) guide 5 hatchlings | `kidul_nest` (sparkle only, no extra marker) | `sk_pantai` dunes to shore | `area_entered:kidul_tukik_laut` x5 (one per hatchling that reaches the water) |
| SQ-K1 turn in | `kidul_nelayan_anak` | `sk_pantai` | `talked_to:kidul_nelayan_anak`. Reward Herb Pouch #4 |
| SQ-K2 start | `kidul_nelayan_tua` | `sk_karang` | `talked_to:kidul_nelayan_tua`. Unlock: `zone_entered:segara_kidul` (ASSUMED) |
| SQ-K2 find the old crocodile | `kidul_elite` | `sk_karang` cove | `area_entered:kidul_elite_cove` |
| SQ-K2 defeat it | `kidul_elite` | `sk_karang` cove | `enemy_killed:bajul_putih_tua` |
| SQ-K2 report back | `kidul_nelayan_tua` | `sk_karang` | `talked_to:kidul_nelayan_tua`. Reward Cakra (P2) or Ilmu L x2 |
| Petilasans | `kidul_1`, `kidul_2` | pantai, keraton | `petilasan_activated:kidul_1`, `petilasan_activated:kidul_2` (not quest steps) |
| Codex | `kidul_keraton_codex` | `sk_keraton` | `codex:nyi_roro_kidul` (ASSUMED) |

Flags read or set in this region: `mq3_8` (read, ASSUMED), `mq4_3` and `mq4_4` (set, ASSUMED), `sc:sk_gerbang` and `sc:ts_sk` (shortcuts).

## Flow
Arrive at `sk_pantai` (`from_desa_purwa`, or walk in from `sk_karang`) -> teach encounters (Lampor, Ula Segara, Bajul Putih) -> juru kunci and Semar at petilasan `kidul_1` -> trial of the waves on the tidal flat (the stone stumps light up one by one) -> Nyi Roro Kidul speaks, Jawa Ka learned -> east to `sk_karang` (fishing hut, SQ-K2 cove, Ombak test) -> causeway to `sk_keraton` outer court -> pendopo and petilasan `kidul_2` -> kabut `mq4_3` gone -> `gk_mulut`. Optional: cliff stair to `sk_tebing` (two fights, chest, `sc:ts_sk`), drop onto the causeway, open `sc:sk_gerbang`, walk back to `kidul_1`.

## Self-check ([AGENTS.md](../../AGENTS.md) section 5 Step 2)
- [~] POI counts: 0 boss arenas (the trial site replaces it, by design), 1 elite room, 4 NPCs (3-5), 3 secrets (2-3), 1 codex spot, 10 encounters (6-10), 2 petilasans (1-2). Smaller than usual: no boss, 4 areas.
- [x] Petilasan before the exit/trial: `kidul_1` is at the north edge of the flat, no fight between it and the first wave; `kidul_2` is in the calm pendopo right before the kabut to Gua Kala, no fight between.
- [x] First appearances: `kidul_pantai_1` (Lampor alone), `_2` (Ula with known Lampor), `_3` (Bajul alone), mirrored by `kidul_karang_1` to `_3` for the east entry. Weakness glyphs are all earlier glyphs.
- [~] One tank per encounter: yes (Bajul Putih only in `_3`, trial W3, `kidul_karang_3`, `kidul_tebing_2`). Trial W2 has 2 Ula Segara (two shooters) and the trial has 3 waves: both fixed by bestiary.md. See conflicts.
- [x] Rooms with 4+ enemies: trial flat about 45x24, tebing landing and keraton court 15x9 or larger. Bajul lanes 8-10 tiles (`kidul_pantai_3` 10, `kidul_karang_3` 8+).
- [x] Newest glyph: Ombak answers Ula's water arc in `kidul_karang_2`, `kidul_tebing_2`, `kidul_keraton_1`; it has no weakness (bestiary), so this is a usage answer. Burst, Bolt, Ward are the trial answers.
- [x] Every MQ4, SQ-K1 and SQ-K2 step has a marker and area (table above).
- [x] Critical path without Jawa Ka: kabut `mq3_8` and `mq4_3` open on story flags, and the trial is passed by melee and dodge as well.
- [x] Rule 1, at least 1 loop: loops A and B.
- [x] Rule 2, at least 1 shortcut besides `sc:ts_sk`: `sc:sk_gerbang` leads to `sk_pantai` (`kidul_1`). `sc:ts_sk` ends one link from `sunda_2`.
- [x] Rule 3, at least 1 drop: D1.
- [x] Rule 4, optional areas branch off a loop: `sk_tebing` is on loop B, the cove is on loop A.
- [x] Rule 5, landmark: the tidal flat and the green glow show from the first spawn.
- [x] Rule 6, petilasan right before the exit: `kidul_2`. (No boss; the trial has `kidul_1`.)
- [x] Rule 7, 2 petilasans. Rule 8: the critical path visits 3 of 4 areas, gates follow story flags, glyphs are rewards.

## ASSUMED
- Gate flags `mq3_8`, `mq4_3`, `mq4_4`; shortcut ids `sc:sk_gerbang` (and its position); the loop layout, D1 location and landing.
- All npc ids except `semar`, `kidul_jurukunci` (Q), the encounter ids, chest ids, trigger ids (`kidul_tukik_laut`, `kidul_elite_cove`), `kidul_ratu`, `codex:nyi_roro_kidul`.
- Trial on the beach in `sk_pantai`, the keraton as a peaceful sanctum with fights only in the outer court, no enemy tied to Nyi Roro Kidul.
- Semar is at `kidul_1` (story.md: guide at petilasan).
- Elite Bajul Putih Tua can be Warded on the lunge.
- Lampor in the tebing line count: 4 (bestiary says 3-5).
- SQ-K1 and SQ-K2 start and turn-in talks, and the hatchling counting trigger.

## Open questions
1. VERIFY: wearing green on the south coast and her association with the Parangkusumo / Parangtritis shore (a ritual stage, Panggung Sanggabuwana). Do not name real places in game text without a source.
2. VERIFY: sea-gate and "keraton" imagery (palace under the sea). A single source for any codex line.
3. SQ-K1 mentions crabs and birds that block hatchlings. bestiary.md has no such enemies ("mundane enemies to be added at Phase 5"). Use them as scripted hazards, or add mundane enemies?
4. Who teaches or gives Jawa Ka? Here the sea itself, with Nyi Roro Kidul speaking once. OK?
5. The P0 build has no Segara Kidul, so no Jawa Ka and no path into `gk_mulut`. See conflicts.

## Doc conflicts found (not fixed)
- bestiary.md trial W2 has 2 Ula Segara (two shooters) and the trial has 3 waves. Both break the Encounters rules (at most one shooter, at most two waves). Kept as written, the trial is a named exception.
- bestiary.md Zone 4 says mundane enemies are still to be added. Here only Lampor, Ula Segara and Bajul Putih are used, so the "2-3 mundane plus 1-2 folklore" mix rule is not met.
- world.md interlock rule 5 (boss site as landmark) and AGENTS.md "1 boss arena" assume a boss. Segara Kidul has none, so the trial flat stands in for both.
- world.md calls the ts_situ end of `sc:ts_sk` an area (`ts_situ`), but tatar_sunda.md is still a single zone `tatar_sunda`. The `ts_*` split and the position of `sunda_2` relative to `ts_situ` are undefined.
- quests.md 4.1 `zone_entered:segara_kidul` uses a region id, while the scenes are areas (`sk_*`). The event must fire on the first area entered.
- quests.md "After 3.8: in a P0 build the Gua Kala gate opens now" vs world.md, which links `gk_mulut` only from `sk_keraton`.

## Area 1: sk_karang

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Dark reef rock, tide pools, a long sandbar from `tt_pesisir`, a fishing hut in the west, and a rocky south-east cove where Bajul Putih Tua lurks.
- Purpose: Entry from `tt_pesisir`, reef encounters (`kidul_karang_1`, `kidul_karang_2`, `kidul_karang_3`), NPC `kidul_nelayan_tua` (SQ-K2), elite room `kidul_elite_cove` (`bajul_putih_tua`), secret chest `kidul_chest_2`, south causeway to `sk_keraton` (gated by kabut `mq4_5`).

### Map
```
############################NN##############################
#...........................n,.............................#
#.......rr..................,,............rr...............#
#.......rr..................,,............rr...............#
#...........................,,.............................#
#...........................,,........E....................#
#...........................,,.............................#
#.....~~~~~~~~..............,,...................rrrrrr....#
#.....~~~~~~~~..............,,...................r....r....#
#.....~~~~~~~~..............,,...................r..c.r....#
#...........................,,...................r....r....#
#...........................,,........................r....#
#..............rr...........,,...................rrrrrr....#
#..............rr...........,,.............................#
#...........................,,.............................#
#......A....................,,.............................#
Ww,,,,,,,,,,,,,,,,F,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#
W,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#
#...........................,,.............................#
#...........................,,.............................#
#.........~~~~~~~~..........,,............#############....#
#.........~~~~~~~~..........,,............#...........#....#
#.........~~~~~~~~..........,,............#.....q.....#....#
#...........................,,............#...........#....#
#...........................,,............#####...#####....#
#...........................,,................T............#
#..............rr...........,,.............................#
#..............rr...........,,.............................#
#...........................G,.............................#
############################KK##############################
############################,,##############################
############################,,##############################
############################s,##############################
############################SS##############################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `N` | exit to tt_pesisir (north edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"tt_pesisir", spawn_id:"from_sk_karang"}` | path | 2 |
| `n` | spawn, arrival from tt_pesisir | `res://entities/world/spawn.tscn` | `{id:"from_tt_pesisir"}` | path | 1 |
| `W` | exit to sk_pantai (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_pantai", spawn_id:"from_sk_karang"}` | path | 2 |
| `w` | spawn, arrival from sk_pantai | `res://entities/world/spawn.tscn` | `{id:"from_sk_pantai"}` | path | 1 |
| `S` | exit to sk_keraton (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_keraton", spawn_id:"from_sk_karang"}` | path | 2 |
| `s` | spawn, arrival from sk_keraton | `res://entities/world/spawn.tscn` | `{id:"from_sk_keraton"}` | path | 1 |
| `K` | kabut, lifts after the Trial of the Waves (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq4_5"}` | path | 2 |
| `A` | NPC Pak Raka, old fisherman (SQ-K2) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_nelayan_tua"}` | grass | 1 |
| `E` | encounter kidul_karang_1 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_karang_1", size:Vector2i(17,9), waves:[[[res://entities/enemies/lampor.tscn, Vector2i(4,-2)], [res://entities/enemies/lampor.tscn, Vector2i(5,0)], [res://entities/enemies/lampor.tscn, Vector2i(4,2)]]]}` | grass | 1 |
| `F` | encounter kidul_karang_2 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_karang_2", size:Vector2i(17,9), waves:[[[res://entities/enemies/ula_segara.tscn, Vector2i(6,0)], [res://entities/enemies/lampor.tscn, Vector2i(3,-2)], [res://entities/enemies/lampor.tscn, Vector2i(3,2)]]]}` | path | 1 |
| `G` | encounter kidul_karang_3 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_karang_3", size:Vector2i(19,9), waves:[[[res://entities/enemies/bajul_putih.tscn, Vector2i(6,0)], [res://entities/enemies/lampor.tscn, Vector2i(3,-2)], [res://entities/enemies/lampor.tscn, Vector2i(3,2)]]]}` | path | 1 |
| `T` | trigger, SQ-K2 cove entrance | `res://entities/world/trigger.tscn` | `{trigger_id:"kidul_elite_cove", size:Vector2i(7,7)}` | grass | 1 |
| `q` | elite Bajul Putih Tua (SQ-K2) | `res://entities/enemies/bajul_putih_tua.tscn` | `{}` | grass | 1 |
| `c` | chest: 380 Ilmu (hidden tide pool) | `res://entities/world/chest.tscn` | `{chest_id:"kidul_chest_2", item_id:"ilmu:380"}` | grass | 1 |

## Area 2: sk_pantai

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Black-sand dunes in the north, a wide wet tidal flat in the south, green southern surf, and the barred coral gate (`sc:sk_gerbang`) on the south-east shore.
- Purpose: Petilasan `kidul_1`, NPCs `kidul_jurukunci` and `kidul_nelayan_anak` (SQ-K1), teach encounters (`kidul_pantai_1`, `kidul_pantai_2`, `kidul_pantai_3`), Trial of the Southern Waves (`kidul_trial`), north stair to `sk_tebing`, shortcut gate `sc:sk_gerbang` to `sk_keraton`.

### Map
```
############################NN##############################
#...........................n,.............................#
#......rrrrrr...............,,...................rr........#
#......r....r...............,,...................rr........#
#......r..c.r...............,,.............................#
#......r....................,,.........1...................#
#......rrrrrr...............,,.............................#
#...........................,,.......................2.....#
#.............E.............,,.............................#
#...........................,,.............................#
#...........................,,.............................#
#......C....................,,...................3.........#
#...........................,,.............................#
#...........................,,.............................#
#...................P....J..,,.............................#
#...........................,,.............................#
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,F,,,,,,,,,,,,,,,yY
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Y
#...........................,,.............................#
#.........G.................,,.............................#
#...........................,,........................######
#......____________________.,,........................=,;..$
#......____________________.,,........................=,,..$
#......____________________.,,........................######
#......_________W__________.,,.............................#
#......____________________.,,.............................#
#......____________________.,,.............................#
#......____________________.,,.............................#
#...........................,,............T................#
#..........................................................#
#.....~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.....#
#.....~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.....#
#..........................................................#
############################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `Y` | exit to sk_karang (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_karang", spawn_id:"from_sk_pantai"}` | path | 2 |
| `y` | spawn, arrival from sk_karang | `res://entities/world/spawn.tscn` | `{id:"from_sk_karang"}` | path | 1 |
| `N` | exit to sk_tebing (north edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_tebing", spawn_id:"from_sk_pantai"}` | path | 2 |
| `n` | spawn, arrival from sk_tebing | `res://entities/world/spawn.tscn` | `{id:"from_sk_tebing"}` | path | 1 |
| `$` | exit to sk_keraton (east edge behind shortcut gate, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_keraton", spawn_id:"from_sk_pantai"}` | path | 2 |
| `;` | spawn, arrival from sk_keraton (on open side of `=`) | `res://entities/world/spawn.tscn` | `{id:"from_sk_keraton"}` | path | 1 |
| `=` | shortcut gate sc:sk_gerbang (opens from sk_keraton, 2 tiles) | `res://entities/world/shortcut.tscn` | `{id:"sc:sk_gerbang", open_side:"e"}` | path | 2 |
| `P` | petilasan 1 | `res://entities/petilasan/petilasan.tscn` | `{id:"kidul_1"}` | grass | 1 |
| `J` | NPC Nyai Ranti, juru kunci of the Southern Shore | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_jurukunci"}` | grass | 1 |
| `C` | NPC Damar, fisher child (SQ-K1) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_nelayan_anak"}` | grass | 1 |
| `1` | pickup, stranded hatchling 1 (SQ-K1) | `res://entities/world/pickup.tscn` | `{item_id:"tukik_1"}` | grass | 1 |
| `2` | pickup, stranded hatchling 2 (SQ-K1) | `res://entities/world/pickup.tscn` | `{item_id:"tukik_2"}` | grass | 1 |
| `3` | pickup, stranded hatchling 3 (SQ-K1) | `res://entities/world/pickup.tscn` | `{item_id:"tukik_3"}` | grass | 1 |
| `T` | trigger, surf release spot (SQ-K1) | `res://entities/world/trigger.tscn` | `{trigger_id:"kidul_tukik_laut", size:Vector2i(7,5)}` | grass | 1 |
| `E` | encounter kidul_pantai_1 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_pantai_1", size:Vector2i(17,9), waves:[[[res://entities/enemies/lampor.tscn, Vector2i(4,-2)], [res://entities/enemies/lampor.tscn, Vector2i(5,0)], [res://entities/enemies/lampor.tscn, Vector2i(4,2)]]]}` | grass | 1 |
| `F` | encounter kidul_pantai_2 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_pantai_2", size:Vector2i(17,9), waves:[[[res://entities/enemies/ula_segara.tscn, Vector2i(6,0)], [res://entities/enemies/lampor.tscn, Vector2i(3,-2)], [res://entities/enemies/lampor.tscn, Vector2i(3,2)]]]}` | path | 1 |
| `G` | encounter kidul_pantai_3 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_pantai_3", size:Vector2i(17,9), waves:[[[res://entities/enemies/bajul_putih.tscn, Vector2i(6,0)]]]}` | grass | 1 |
| `W` | encounter kidul_trial (Trial of the Southern Waves) | `res://entities/world/encounter.tscn` | `{area_id:"kidul_trial", size:Vector2i(21,11), waves:[[[res://entities/enemies/lampor.tscn, Vector2i(-5,-2)], [res://entities/enemies/lampor.tscn, Vector2i(-3,2)], [res://entities/enemies/lampor.tscn, Vector2i(3,-2)], [res://entities/enemies/lampor.tscn, Vector2i(5,2)]], [[res://entities/enemies/ula_segara.tscn, Vector2i(-6,0)], [res://entities/enemies/ula_segara.tscn, Vector2i(6,0)], [res://entities/enemies/lampor.tscn, Vector2i(0,-3)]], [[res://entities/enemies/bajul_putih.tscn, Vector2i(6,0)], [res://entities/enemies/lampor.tscn, Vector2i(-4,-2)], [res://entities/enemies/lampor.tscn, Vector2i(-4,2)]]]}` | floor | 1 |
| `c` | chest: 380 Ilmu (behind driftwood) | `res://entities/world/chest.tscn` | `{chest_id:"kidul_chest_1", item_id:"ilmu:380"}` | grass | 1 |

## Area 3: sk_tebing

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: High black sea cliffs, switchback stone stairs, wind-carved sea cave in the north-east, and a cliff-edge slide dropping onto `sk_keraton`.
- Purpose: Connects `sk_pantai` up to the `sc:ts_sk` cliff shortcut into Tatar Sunda (`ts_situ`), two cliff encounters (`kidul_tebing_1`, `kidul_tebing_2`), secret chest `kidul_chest_3`, and one-way drop `D` to `sk_keraton`.

### Map
```
############################################################
#..........................................................#
#...........................................##########.....#
#........rr.................................#........#.....#
#........rr.................................#....c...#.....#
#...........................................#........#.....#
Ww,,,,,,,,,,,,,,,,,,,,,,,,,,,...............####..####.....#
W,,,,,,,,,,,,,,,,,,,,,,,,,,,,..............................#
#..........................,,..............................#
#..........................,,.......F......................#
#..........................,,..............................#
#..........................,,..............................#
#.............rr...........,,...................rr.........#
#.............rr...........,,...................rr.........#
#..........................,,..............................#
#..........................,,..............................#
#..........................,,..............................D
#..........................,,..............................D
#..........................,,..............................#
#..........................,,..............................#
#.......rr.................,,..............rr..............#
#.......rr.................,,..............rr..............#
#..........................,,..............................#
#..........................E,..............................#
#..........................,,..............................#
#..........................,,..............................#
#..........................,,..............................#
#.................rr.......,,..............................#
#.................rr.......,,..............................#
#..........................,,..............................#
#..........................,,..............................#
#..........................,,..............................#
#..........................s,..............................#
###########################SS###############################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `S` | exit to sk_pantai (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_pantai", spawn_id:"from_sk_tebing"}` | path | 2 |
| `s` | spawn, arrival from sk_pantai | `res://entities/world/spawn.tscn` | `{id:"from_sk_pantai"}` | path | 1 |
| `W` | exit to ts_situ (west edge, opens sc:ts_sk in ts_situ, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_situ", spawn_id:"from_sk_tebing"}` | path | 2 |
| `w` | spawn, arrival from ts_situ | `res://entities/world/spawn.tscn` | `{id:"from_ts_situ"}` | path | 1 |
| `D` | exit, one-way drop D1 to sk_keraton (east cliff edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_keraton", spawn_id:"from_sk_tebing"}` | path | 2 |
| `E` | encounter kidul_tebing_1 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_tebing_1", size:Vector2i(17,9), waves:[[[res://entities/enemies/lampor.tscn, Vector2i(3,-3)], [res://entities/enemies/lampor.tscn, Vector2i(4,-1)], [res://entities/enemies/lampor.tscn, Vector2i(4,1)], [res://entities/enemies/lampor.tscn, Vector2i(3,3)]]]}` | path | 1 |
| `F` | encounter kidul_tebing_2 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_tebing_2", size:Vector2i(19,9), waves:[[[res://entities/enemies/ula_segara.tscn, Vector2i(7,0)], [res://entities/enemies/bajul_putih.tscn, Vector2i(4,0)], [res://entities/enemies/lampor.tscn, Vector2i(2,-2)], [res://entities/enemies/lampor.tscn, Vector2i(2,2)]]]}` | grass | 1 |
| `c` | chest: 380 Ilmu (sea cave) | `res://entities/world/chest.tscn` | `{chest_id:"kidul_chest_3", item_id:"ilmu:380"}` | grass | 1 |

## Area 4: sk_keraton

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Outer causeway and court of green-glass stone over the Southern Sea, leading south into a tranquil inner pendopo where waves lap softly against carved pillars.
- Purpose: Outer court encounter (`kidul_keraton_1`), drop landing from `sk_tebing`, west coral gate exit to `sk_pantai` (opens `sc:sk_gerbang`), inner pendopo with petilasan `kidul_2`, codex `nyi_roro_kidul`, and the Sea Altar (`kidul_altar`) where the player inscribes `jawa_ka` (*Ombak*) and receives the Queen's blessing (`kain_hijau`).

### Map
```
############################NN##############################
#___________________________n______________________________#
#______________________________________________l___________#
#_______~~~~____________________________________~~~~_______#
#_______~~~~____________________________________~~~~_______#
#__________________________________________________________#
#___________________rr________________rr___________________#
#___________________rr________________rr___________________#
#__________________________________________________________#
#____________________________E_____________________________#
#__________________________________________________________#
#___________________rr________________rr___________________#
#___________________rr________________rr___________________#
#__________________________________________________________#
#__________________________________________________________#
#__________________________________________________________#
Ww_________________________________________________________#
W__________________________________________________________#
#__________________________________________________________#
#___________############____________############___________#
#___________############____________############___________#
#__________________________________________________________#
#___________________rr________________rr___________________#
#___________________rr________________rr___________________#
#__________________________________________________________#
#_______________________P_________x________________________#
#__________________________________________________________#
#____________________________A_____________________________#
#__________________________________________________________#
#_______~~~~____________________________________~~~~_______#
#_______~~~~____________________________________~~~~_______#
#__________________________________________________________#
#__________________________________________________________#
############################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `N` | exit to sk_karang (north edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_karang", spawn_id:"from_sk_keraton"}` | floor | 2 |
| `n` | spawn, arrival from sk_karang | `res://entities/world/spawn.tscn` | `{id:"from_sk_karang"}` | floor | 1 |
| `l` | spawn, landing of drop D1 from sk_tebing | `res://entities/world/spawn.tscn` | `{id:"from_sk_tebing"}` | floor | 1 |
| `W` | exit to sk_pantai (west edge, opens sc:sk_gerbang in sk_pantai, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_pantai", spawn_id:"from_sk_keraton"}` | floor | 2 |
| `w` | spawn, arrival from sk_pantai | `res://entities/world/spawn.tscn` | `{id:"from_sk_pantai"}` | floor | 1 |
| `E` | encounter kidul_keraton_1 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_keraton_1", size:Vector2i(19,9), waves:[[[res://entities/enemies/ula_segara.tscn, Vector2i(6,0)], [res://entities/enemies/lampor.tscn, Vector2i(3,-3)], [res://entities/enemies/lampor.tscn, Vector2i(4,0)], [res://entities/enemies/lampor.tscn, Vector2i(3,3)]]]}` | floor | 1 |
| `P` | petilasan 2 (inner pendopo) | `res://entities/petilasan/petilasan.tscn` | `{id:"kidul_2"}` | floor | 1 |
| `x` | codex spot, Kanjeng Ratu Kidul | `res://entities/world/pickup.tscn` | `{codex_id:"nyi_roro_kidul"}` | floor | 1 |
| `A` | Sea Altar of the Southern Sanctuary (inscribe jawa_ka) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_altar"}` | floor | 1 |

