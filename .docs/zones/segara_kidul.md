# Segara Kidul (region id `segara_kidul`), Act V (after the Interlude at home), Story v5

Area graph plus maps. Step 1 of the world design workflow ([AGENTS.md](../../AGENTS.md) section 5). Prefix `sk_`. Sources: [world.md](../world.md) (World structure, link table, Segara Kidul, Checkpoints), [bestiary.md](../bestiary.md) (Zone 4, Encounters, Glyph weaknesses), [quests.md](../quests.md) (MQ4 steps 4.9-4.22, SQ-K1, SQ-K2, 7.1, 9), [story.md](../story.md) (Pacing, Acts). Format follows [tatar_sunda.md](tatar_sunda.md). Scope is **P0**: Segara Kidul is Act V on the main path (story v3.1, 2026-11-06). It is entered after the Interlude "The Quiet House" in Desa Purwa (MQ4 4.1-4.5), when `flag:mq4_2` is set.

Story v4/v4b/v4c additions (2026-11-06; v4 numbering 4.6-4.12, now 4.9-4.22 in v5, [quests.md](../quests.md) 4 with its `Play` column): the **arrival slice** (the fishing village mending nets for the sea offering), the **K8 Hunt** (three forgotten verses with three families, clues `song_1` to `song_3`, memory `k8_wiryo_wife`), **K9** (the queen of the south as one retelling, memory `k9_queen_south`), **LC5** (Laras chapter, `lc5`), and the trial's pieces: three setpiece waves with two sign clues between them. Cut names: Mbah Wiryo (npc id `kidul_jurukunci`) is kept; the three families and the net menders are unnamed locals. The memory scenes are in "Memory scenes" below. Side stories v4d additions (2026-11-06; [quests.md](../quests.md) 4 and 5): SQ-K1 was checked against its card and stands as written (giver Damar `kidul_nelayan_anak`, three `tukik_*` pickups, surf trigger `kidul_tukik_laut`); SQ-K2 gets the giver `k2_fisher`, clue `k2_scale`, Mbah Wiryo's one line, memory `sq_k2_fisher` and the river-mouth arena where `bajul_putih_tua` is driven back into the deep, not killed; the Companion clue `c3_shore_net` (C3, fragment 3), the C4 part 3 lamp trial `c4_lamp` on the hatchlings' beach, and the `camp_kidul` camp talk (Mbah Wiryo at `kidul_1`) are placed. The placements are in "Side stories v4d spots" after the quest step table; the memory `sq_k2_fisher` is in "Memory scenes". **Puzzle convention (ASSUMED):** a puzzle is a `trigger.tscn` with `trigger_id` `puzzle_<id>`; the builder attaches the script (tests set `flag:puzzle_<id>`). Miniboss pieces are encounters whose first enemy carries `unique_id` and elite stats (HP x4, Ilmu x4, **TUNE**, the bestiary elite rule). Setpieces are encounters with a scripted frame.

**Story v5 pass (2026-11-06).** Act V is 14 steps (4.9-4.22, [quests.md](../quests.md) section 4) over 7 areas: `sk_pantai`, `sk_nelayan`, `sk_bakau`, `sk_karang`, `sk_gua`, `sk_tebing`, `sk_keraton`. Step indices in conds are 0-based over the whole MQ4 (the Interlude is 4.1-4.8), so step 4.9 is `step:mq4=8` and 4.22 is `step:mq4=21`. Regional characters: Mbah Wiryo (`kidul_jurukunci`, name NPC_WIRYO_NAME) and Sari (`kidul_sari`, name NPC_KIDUL_SARI_NAME), Semar at the petilasans `kidul_1` and `kidul_2`. New clue ids: `gua_bell_marks`, `causeway_post` (both **ASSUMED**), plus `reef_thread` and `lc5_cavern` (the old `lc5_lontar` at the cliff shrine is retired). The causeway kabut now lifts on Choice 5 (`mq4_offering`), not on the trial.

Look: black-sand cliffs, a green sea, a palace beneath the waves. The landmark is the green glow of the sea pavilion. From the first spawn (`from_desa_purwa`) the player sees it low on the southern horizon, past the tidal flat of `sk_pantai`, with a stone sea arch standing offshore. The glow is the pavilion (`sk_keraton`) where the trial is held, so the end of the region is in view at the start. Regional character: **Mbah Wiryo**, the juru kunci of the coast (npc id `kidul_jurukunci`), who says his late wife's name to the sea every dusk because the sea says it back; it mirrors the hero's search for a name the world forgot. Nyi Roro Kidul speaks once, from a distance, after the last wave; she is never fought, never touched, neither friend nor enemy, and no enemy is called her servant. The green association is told as a belief by Mbah Wiryo (wearing green on the south coast is said to attract her), never as a punishment.

Areas: 7, all on the critical path (MQ4 4.9-4.22). Critical path: arrive from `desa_purwa` -> `sk_pantai` (petilasan `kidul_1`, Semar; 4.8-4.9) -> `sk_nelayan` (Mbah Wiryo and Sari, 4.9-4.10; the K8 clues and memory at the net yard and shore in `sk_pantai`, 4.11-4.12) -> `sk_bakau` (the tidal beacons with Sari, 4.13) -> `sk_karang` (Trial I, the Torch-Lines, 4.14) -> `sk_gua` (the sunken-shrine approach, LC5, Trial II, 4.15-4.17) -> `sk_tebing` (cliff, petilasan `kidul_3`, K9, the cliff altar and Choice 5, 4.18-4.19) -> back down to `sk_karang` and the causeway (kabut `mq4_offering`) -> `sk_keraton` (petilasan `kidul_2`, 4.20; Trial III, 4.21; Sea Altar, 4.22) -> `gk_mulut`. Off the path: the Bajul Putih Tua cove (SQ-K2, inside `sk_karang`), the shortcuts.

**Petilasans: 3 (`kidul_1`, `kidul_3`, `kidul_2`).** world.md rule 7 allows 3 only in the largest region. This region is a full act of 45 minutes with a walk of about 20 minutes, so 3 is allowed here (**ASSUMED**), one per 15-20 minutes of walking (story.md Pacing rule 5). The ids are not in walking order (`kidul_3` is met before `kidul_2`) because quests.md 4.18 fixes `kidul_3` as the cliff shrine.

## Area table
Sizes: screens are 30 x 17 tiles. All seven maps are 60 x 34 tiles (2x2). Spawn ids follow `from_<other area id>`.

| id | size (screens, tiles) | look | purpose | contents |
|----|-----------------------|------|---------|----------|
| `sk_pantai` | 2x2, 60x34 | Black-sand beach, dunes in the north, a wide tidal flat in the south, a green sea. A barred coral gate (the gerbang) stands on the south-east shore | Arrival slice: the fishing village mends nets for the sea offering (the net yard `_`), teach encounters, rest, Mbah Wiryo, the three families and their forgotten song verses (K8), turtle nest. MQ4 4.8-4.9 (arrival, `kidul_1`) and 4.11-4.12 (K8 clues and memory) | Spawns `from_desa_purwa` (N), `from_sk_karang` (E), `from_sk_keraton` (gerbang, SE). Petilasan `kidul_1` (centre-west dunes, after the first fights). NPCs `kidul_jurukunci` (Mbah Wiryo), `kidul_nelayan_anak`, `semar` (at `kidul_1`). Encounters `kidul_pantai_1`, `kidul_pantai_2`, `kidul_pantai_3`. Chest `kidul_chest_1` (behind driftwood in the dunes). Turtle nest `kidul_nest` (dunes), water trigger `kidul_tukik_laut` (shore). Shortcut gate `sc:sk_gerbang` (arrival side). Clues `song_1`, `song_2`, `song_3` (K8, 4.11). Semar `M` at `kidul_1` (cond `step:mq4=8`); Mbah Wiryo `J` here after `mq4_4` (before it he stands in `sk_nelayan`). Quest markers `kidul_1`, `kidul_jurukunci`, `kidul_nelayan_anak`, `semar`. No exit to `sk_tebing` any more |
| `sk_karang` | 2x2, 60x34 | Reef of dark rock and tide pools under cliffs, a long sandbar, a fishing hut | Trial I, the Torch-Lines (MQ4 4.14: fight, sign clue, tide-pool puzzle, second fight, the Ula Segara miniboss at the stair foot), the way to the cliff stair, the Bajul Putih Tua cove | Spawns `from_tt_pesisir` (N), `from_sk_pantai` (W), `from_sk_tebing` (NW stair), `from_sk_keraton` (S causeway, behind kabut `mq4_8`). NPC `kidul_nelayan_tua` (hut, west end). Encounters `kidul_karang_1`, `kidul_karang_2`, `kidul_karang_3`. Elite room `kidul_elite_cove` (SQ-K2): Bajul Putih Tua. Chest `kidul_chest_2` (hidden tide pool between rocks). Reef pieces: `reef_thread` clue, `puzzle_kidul_tide`, `kidul_karang_4`, miniboss `kidul_karang_2`. Clue `causeway_post` (4.20) beside the causeway kabut (now `mq4_offering`). Quest markers `kidul_karang_2` (step 4.14), `kidul_nelayan_tua`, `kidul_elite` |
| `sk_tebing` | 2x2, 60x34 | Tall black cliffs, a switchback stair, a sea cave, wind and gulls, a small shrine with a lamp above the drop | The cliff path (MQ4 4.18), the cliff shrine with the K9 memory (4.18) and the cliff altar for Choice 5 (4.19), the drop onto the keraton (kabut-gated until Choice 5). Holds the Segara Kidul end of `sc:ts_sk` | Spawns `from_sk_karang` (S), `from_ts_situ` (the shortcut door, W). Encounters `kidul_tebing_1`, `kidul_tebing_2`. Petilasan `kidul_3` (cliff shrine beside the drop, after the last fight, no fight between it and the drop). Chest `kidul_chest_3` (sea cave, narrow ledge). Shortcut gate `sc:ts_sk` (opens from here). Drop `D1` at the cliff edge (east side). Clue `shrine_tale` (K9) and the cliff altar `cliff_altar` at the shrine (`lc5_lontar` is retired: LC5 opens in `sk_gua`). Quest markers `kidul_tebing_2` (step 4.18), `kidul_3` (step 4.18), `cliff_altar` (4.19) |
| `sk_keraton` | 2x2, 60x34 | Outer court of green-glass stone over the sea (the sea pavilion court), then a calm inner pendopo (open hall). Waves lap at the walls | The Trial of the Waves (4.21: three setpiece waves with two sign clues between them), the Sea Altar (4.22), the rest at `kidul_2` (4.20), codex, the exit to Gua Kala | Spawns `from_sk_karang` (N), `from_sk_tebing` (drop landing, NE), `from_sk_pantai` (W), `from_gk_mulut` (S). Trial `kidul_trial` (outer court centre, 3 waves). Petilasan `kidul_2` (inner pendopo, right before the kabut). Sea Altar `kidul_altar` (pendopo, Ombak and Kain Hijau). Codex spot `kidul_keraton_codex` (pendopo, Nyi Roro Kidul as belief). Shortcut gate `sc:sk_gerbang` (opens from here). Kabut `mq4_9` (= `quest:mq4=done`) to `gk_mulut`. No fight in the pendopo. Semar `M` at `kidul_2` (cond `step:mq4=19`). Clues `trial_sign_1`, `trial_sign_2` (4.21). Quest markers `kidul_2` (4.20), `kidul_trial` (4.21), `kidul_altar` (4.22) |
| `sk_nelayan` | 5x4, 150x68 (Scale 1) | Kampung Nelayan: a stilt-house fishing village with drying racks, net yards and a cove path toward the mangrove | Arrival into the village (4.9, beat `song_hook`), Mbah Wiryo and Sari (4.10), SQ-K2 giver, SQ-C3 fragment 3 | Spawns `from_sk_pantai` (W), `from_sk_bakau` (E). Mbah Wiryo `J` (before `mq4_4`), Sari `S` (until `mq4_h2`) and `s` (after the trial), fisher `k2_fisher`, clue `c3_shore_net`, chest `kidul_chest_nelayan`. Quest markers `kidul_jurukunci` (4.10), `kidul_sari` (4.10) |
| `sk_bakau` | 2x2, 60x34 | Hutan Bakau, a flooded mangrove with boardwalks and tidal beacons | The three tidal beacons with Sari (4.13), SQ-K2 clue, a chest | Spawns `from_sk_nelayan` (W), `from_sk_karang` (E). Puzzle trigger `bakau_beacons`, encounter `bakau_pack`, Sari `S` (step 4.13), clue `k2_scale`, chest `kidul_chest_bakau`. Quest markers `bakau_beacons` (4.13), `kidul_sari` |
| `sk_gua` | 2x2, 60x34 | Gua Karang: an echoing sea cavern with bronze bells and abyssal pools | The sunken-shrine approach (4.15), LC5 (4.16), Trial II, the Abyssal Current (4.17) | Spawns `from_sk_karang` (W), `from_sk_tebing` (N). Clue `gua_bell_marks` `G` (4.15), encounter `gua_karang_approach` `E`, clue `lc5_cavern` `L` (opens `lc5`), encounter `kidul_gua_trial` `F` (cond `flag:laras_key_tidal_gate`), Sari `S` at the mouth (step 4.17). Quest markers `gua_karang_approach`, `lc5_cavern`, `kidul_gua_trial` |

## Region graph
`==K==` kabut, `--` link, `=sc=` shortcut, `~D~>` drop (one way).
```
  [ts_situ] =sc:ts_sk=  [sk_tebing] (kidul_3, cliff altar)
  (Tatar Sunda)           |       \      ==Z mq4_offering== ~D1~> (one way)
                          |        \                              \
                       L9 (link)    L4 (stair)                     v
                          |           \
 [sk_gua] ==L8== [sk_karang] ==L3 K mq4_offering== [sk_keraton] (kidul_2, trial) ==K mq4_9== [gk_pelataran]
                     |   \                                 |
                     |    X2 ==K mq4_9== [tt_pesisir]      +==sc:sk_gerbang==+
                    L7 (bakau)                                              |
                     |                                                      v
 [desa_purwa] ==K mq4_2== [sk_pantai] --L5-- [sk_nelayan] --L6-- [sk_bakau]
                          (kidul_1)  --L1--> [sk_karang]  (L1 is also a direct link)
```
Critical path (v5): `desa_purwa` -> `sk_pantai` -> L5 -> `sk_nelayan` -> L6 -> `sk_bakau` -> L7 -> `sk_karang` -> L8 -> `sk_gua` -> L9 -> `sk_tebing` -> L4 -> `sk_karang` -> L3 (causeway) -> `sk_keraton` -> `gk_mulut`. One walk back through `sk_karang` after the cliff altar is the only repeat; its fights stay cleared. The drop D1 stays a one-way shortcut, behind a kabut until Choice 5. The direct link L1 (`sk_pantai` to `sk_karang`) still exists on the map; the quest arrow, not a gate, keeps the step order (**ASSUMED**).

### Link table
| id | from area | to area | kind | gate flag | spawn ids |
|----|-----------|---------|------|-----------|-----------|
| X1 | `desa_purwa` (S) | `sk_pantai` | link, kabut | `mq4_2` | `from_desa_purwa` (in `sk_pantai`), `from_sk_pantai` (in `desa_purwa`) |
| X2 | `tt_pesisir` | `sk_karang` | link, kabut | `mq4_9` (back route only, so Act V always starts after the Interlude) | `from_tt_pesisir` (in `sk_karang`), `from_sk_karang` (in `tt_pesisir`) |
| L1 | `sk_pantai` | `sk_karang` | link | none | `from_sk_karang` (in pantai), `from_sk_pantai` (in karang) |
| L4 | `sk_karang` | `sk_tebing` | link (north-west cliff stair) | none | `from_sk_tebing` (in karang), `from_sk_karang` (in tebing). New in v3.1; replaces the old pantai to tebing link (L2, removed) |
| L3 | `sk_karang` | `sk_keraton` | link, kabut (south causeway) | `mq4_offering` | `from_sk_keraton` (in karang), `from_sk_karang` (in keraton). Opens with Choice 5 (4.19); step 4.20 is the walk along it |
| L5 | `sk_pantai` | `sk_nelayan` | link (west edge) | none | `from_sk_nelayan` (in pantai), `from_sk_pantai` (in nelayan) |
| L6 | `sk_nelayan` | `sk_bakau` | link (east edge) | none | `from_sk_bakau` (in nelayan), `from_sk_nelayan` (in bakau) |
| L7 | `sk_bakau` | `sk_karang` | link (east edge of bakau, east edge of karang) | none | `from_sk_karang` (in bakau), `from_sk_bakau` (in karang) |
| L8 | `sk_karang` | `sk_gua` | link (east edge, main road) | none | `from_sk_gua` (in karang), `from_sk_karang` (in gua) |
| L9 | `sk_gua` | `sk_tebing` | link (north edge of gua, south-west edge of tebing) | none | `from_sk_tebing` (in gua), `from_sk_gua` (in tebing) |
| D1 | `sk_tebing` | `sk_keraton` | drop (one way, behind kabut `Z`) | `mq4_offering` | `from_sk_tebing` (landing in keraton). No exit leads back up |
| S1 | `sk_keraton` | `sk_pantai` | shortcut `sc:sk_gerbang` | `sc:sk_gerbang` | `from_sk_keraton` (in pantai), `from_sk_pantai` (in keraton) |
| S2 | `sk_tebing` | `ts_situ` | shortcut `sc:ts_sk` | `sc:ts_sk` | `from_ts_situ` (in tebing), `from_sk_tebing` (in ts_situ) |
| X3 | `sk_keraton` | `gk_pelataran` | link, kabut | `mq4_9` (`quest:mq4=done`) | `from_sk_keraton` (in gk_pelataran), `from_gk_pelataran` (in keraton) |

`mq4_2` is set by MQ4 step 4.3 (`talked_to:ibu`, the Interlude talk in Desa Purwa), as quests.md Gating says. `mq4_offering` is set by Choice 5 at the cliff altar (4.19) and opens the causeway (L3) and the drop (D1). `mq4_8` is set when the Trial of the Waves is passed (4.21). `mq4_9` is set by step 4.22, the last step, so the kabut flag `mq4_9` and `quest:mq4=done` hold together (the gen_zones kabut takes `flag` only). A kabut is lifted by a story flag, never by a glyph.

**Why L4 and no L2.** In v3.1 the cliff path is required (step 4.18) and follows the reef (4.14). If `sk_tebing` could be entered from `sk_pantai`, the player could climb before crossing the reef and the steps would run out of order, and the route would double back from the cliff to the reef. The pantai to tebing link is removed (its map tiles are now wall), and `sk_karang` gets a north-west stair (link L4) at the spot the player reaches right after the reef. Every step now moves forward: pantai (4.9) -> nelayan -> bakau -> karang (4.14) -> gua (4.15-4.17) -> tebing (4.18-4.19) -> keraton (4.20-4.22). Map edit sizes are unchanged (60 x 34).

**Entering from `tt_pesisir` (ASSUMED).** The player arrives at the north edge of `sk_karang`, so the first stops (`kidul_1`, Mbah Wiryo) are west in `sk_pantai`. That costs one extra crossing of the reef. It is not forced: the quest arrow points to `kidul_1`, and the reef fights cleared on the way stay cleared, so the second crossing is empty. The hub route is the intended one (the Interlude ends in Desa Purwa).

### Shortcut table
| id | gate area | opens from | leads back to |
|----|-----------|------------|---------------|
| `sc:ts_sk` | `sk_tebing` (west door, a rope-and-timber stair up the cliff) | `sk_tebing` only. From `ts_situ` the door is a sealed rock face | `ts_situ`, one link from the Tatar Sunda crater path and `sunda_2` (**ASSUMED**, see conflicts). Opening it needs a first visit to Segara Kidul, so it never skips ahead |
| `sc:sk_gerbang` | `sk_keraton` (west wall of the outer court, a coral gate with a latch on this side) | `sk_keraton` only. From `sk_pantai` it is a barred gate that can be seen but not opened | `sk_pantai`, next to petilasan `kidul_1` |

## Loops, drop, critical path, optional areas
Loops (each closes with a shortcut or a drop):
1. **Loop A:** `sk_pantai` -> L1 -> `sk_karang` -> L3 (after the trial) -> `sk_keraton` -> `sc:sk_gerbang` -> `sk_pantai`. First trip: the cliff and trial come first (see loop B), so loop A is the walk back for the cove, the hut and SQ-K2, and the gerbang makes it short.
2. **Loop B (the critical path):** `sk_pantai` -> L1 -> `sk_karang` -> L4 -> `sk_tebing` -> D1 (drop) -> `sk_keraton` -> `sc:sk_gerbang` -> `sk_pantai`. First trip: along the shore, up the cliff, down the slide. Later trips: the gerbang takes the player from the pavilion to `kidul_1` in one gate.

Drop: D1, a ledge-and-slide at the cliff edge of `sk_tebing` onto the pavilion court. Nothing climbs back up. `kidul_3` stands next to the ledge, so the last rest before the trial has no fight between it and the court, and the landing is at the north-east corner of the court, away from the trial ring, so a drop never strands anyone.

Critical path (MQ4, v5): 4.1-4.8 are in Desa Purwa (Interlude). 4.9 rest at `kidul_1` with Semar, enter `sk_nelayan` (beat `song_hook`); 4.10 Mbah Wiryo, then Sari; 4.11 three verses at the net yard and the shore (K8 clues); 4.12 K8 memory and the dusk talk; 4.13 `sk_bakau` beacons with Sari; 4.14 Trial I across the reef (`kidul_karang_3`, `reef_thread`, `puzzle_kidul_tide`, `kidul_karang_4`, miniboss `kidul_karang_2`); 4.15 `sk_gua` approach (`gua_bell_marks`, `gua_karang_approach`); 4.16 LC5 (`lc5_cavern`); 4.17 Trial II (`kidul_gua_trial`); 4.18 cliff (`kidul_tebing_1`, `kidul_tebing_2`), `kidul_3`, K9; 4.19 cliff altar, Choice 5; 4.20 causeway (`causeway_post`, `kidul_karang_1`), `kidul_2`; 4.21 Trial III (`kidul_trial`); 4.22 Sea Altar. Then the kabut and `gk_mulut`. All seven areas are on the path. Nothing on it needs Jawa Ka.

**Return trips (Pacing rule 5).** After the cliff altar the walk back to the causeway crosses `sk_karang` once (cleared); every other leg is forward. The two memory trips (K8 on the shore, K9 at the shrine) are scenes, not walks. A player entering from `tt_pesisir` still walks one extra reef crossing (**ASSUMED**; the reef fights stay cleared, the miniboss stays dead, the puzzle stays solved). Later trips use `sc:sk_gerbang`.

Optional: the Bajul Putih Tua cove (side room of `sk_karang`, SQ-K2), the three chests, the turtle nest (SQ-K1), and the shortcuts. These all lie on loop A or loop B, so turning back is never a long walk.

## Encounters
Newest glyph note: Jawa Ka (Ombak) has no enemy weakness ([bestiary.md](../bestiary.md)); it is the clean answer to Ula Segara's water arc and Lampor lines (pushes them back, destroys projectiles). It is earned by the trial and given at the altar, which is the end of the region, and the aftermath has no combat (story.md Pacing rule 6). So **no encounter in this region has Ombak as its clean answer**; its first use is in Gua Kala (`kala_mulut` projectiles, Batara Kala's time-sand). A player who walks back through the reef after the trial can test it on the cleared-and-respawned reef fights (ASSUMED, see the self-check).

Rooms with 4 or more enemies are at least 15 x 9 tiles. Offsets are in the legends. "Position" is a rough place in the area.

| encounter id | area | position | waves (enemy mix) | clean answer |
|--------------|------|----------|-------------------|--------------|
| `kidul_pantai_1` | pantai | north dunes | 3 Lampor (one line) | Ca Burst. Teaches Lampor |
| `kidul_pantai_2` | pantai | shore path | 1 Ula Segara, 2 Lampor | Ka Bolt on the spit wind-up. Teaches Ula Segara |
| `kidul_pantai_3` | pantai | dune lane (10-tile straight lane) | 1 Bajul Putih | Ga Ward on the lunge. Teaches Bajul Putih |
| `kidul_karang_1` | karang | north entry (also the first fight of the causeway walk, 4.20) | 3 Lampor | Ca Burst. Teaches Lampor for players who enter here |
| `kidul_karang_2` | karang | stair foot (step 4.14, **miniboss**) | 1 Ula Segara (elite `kidul_reef_elite`, HP x4, **TUNE**), 2 Lampor | Ka Bolt on the spit wind-up |
| `kidul_karang_4` | karang | pool north bank (fight 2 of 4.14) | 3 Lampor (12x7) | Ca Burst |
| `kidul_karang_3` | karang | reef lane on the road (8+ tile lane, moved from the south causeway, fight 1 of 4.14) | 1 Bajul Putih, 2 Lampor | Ga Ward |
| `kidul_elite_cove` | karang | cove (optional, SQ-K2; the river-mouth arena since v4d) | 1 Bajul Putih Tua (elite, `unique_id` `bajul_putih_tua`; at 0 HP it dives and fades, driven back into the deep, not killed; `enemy_killed:bajul_putih_tua` still fires) | Own mechanics: elite, no weakness. Ga Ward still works on the lunge (**ASSUMED**) |
| `kidul_tebing_1` | tebing | lower stair landing | 4 Lampor (one line) | Ca Burst |
| `kidul_tebing_2` | tebing | upper ledge (step 4.18) | 1 Ula Segara, 1 Bajul Putih, 2 Lampor | Ka Bolt, Ga Ward |
| `gua_karang_approach` | gua | sunken-shrine approach (step 4.15) | 2 Lampor, 1 Ula Segara (see the legend) | Ca Burst, Ka Bolt |
| `kidul_gua_trial` | gua | the trial ring (step 4.17, Trial II, miniboss; inert until `laras_key_tidal_gate`) | 1 Ula Segara, 1 Bajul Putih, 1 Lampor (see the legend) | Ka Bolt, Ga Ward |
| `bakau_pack` | bakau | mangrove boardwalk (step 4.13) | 1 Lampor, 1 Ula Segara | Ca Burst, Ka Bolt |
| `kidul_trial` | keraton | outer court centre (step 4.21, **three setpiece waves** with a pause for the sign clues `trial_sign_1`, `trial_sign_2` between them) | W1: 4 Lampor in two lines. W2: 2 Ula Segara, 1 Lampor. W3: 1 Bajul Putih, 2 Lampor | W1 Ca Burst, W2 Ka Bolt, W3 Ga Ward ([bestiary.md](../bestiary.md) trial of the waves). Waves rise out of the shallows and pools with a 0.5 s warning, in view. The three waves are the deed that earns Ombak |

Counts (v4c): 11 encounters (`kidul_karang_4` and the `kidul_karang_2` miniboss variant added) and the three trial waves as setpieces; v3.1 counted 9 encounters (the trial is the climax) plus the elite room (the miniboss slot). The old outer-court encounter `kidul_keraton_1` is removed: the court is the trial ring, and there is no fight between `kidul_3` and the trial. Moving the trial from the beach also removes a 2-minute walk-back from the pantai flat to the pavilion.

## Points of interest
| Thing | Count | Where |
|-------|-------|-------|
| Boss arena | 0, the trial site instead | `sk_keraton` outer court (`kidul_trial`) |
| Elite room | 1 (+ 1 miniboss on the path) | `kidul_elite_cove` in `sk_karang`; the Ula Segara elite `kidul_karang_2` at the stair foot (4.9) |
| NPCs | 4 (+ Nyi Roro Kidul as a presence) | `kidul_jurukunci` (Mbah Wiryo), `kidul_nelayan_anak`, `semar` in pantai; `kidul_nelayan_tua` in karang. Main-path speakers: Mbah Wiryo and Semar; Damar and Pak Raka are side-quest NPCs (cast budget, story.md Pacing rule 2). Nyi Roro Kidul (`kidul_ratu`, ASSUMED) is a green glimmer and a voice, not a talkable NPC |
| Secrets and finds | 3 | `kidul_chest_1` (pantai), `kidul_chest_2` (karang), `kidul_chest_3` (tebing) |
| Codex spot | 1 | `kidul_keraton_codex` (pendopo) |
| Petilasans | 3 (full-act exception) | `kidul_1` (pantai), `kidul_3` (tebing, cliff shrine), `kidul_2` (keraton pendopo) |

## Quest step locations
Marker form `{zone: "segara_kidul", id: ...}`. Ids from quests.md are marked (Q). Everything else is **ASSUMED**. Steps 4.1-4.8 take place in Desa Purwa ([desa_purwa.md](desa_purwa.md)) and have no marker here. Step numbers are the MQ4 Story v5 ones ([quests.md](../quests.md) 4, `Play` column; Act V is 4.9-4.22); conds use the 0-based index over the whole MQ4, so 4.9 is `step:mq4=8`. Every piece has a place: `travel` = crossing that area with its fights and one find; `fight` = one encounter; `clue`, `puzzle`, `miniboss`, `setpiece`, `memory`, `chapter` as named. Unnamed clue pieces (`reef_thread`, `gua_bell_marks`, `causeway_post`, `trial_sign_1`, `trial_sign_2`, `shrine_tale`) are **ASSUMED** journal notes with no quest trigger, except `shrine_tale` and `lc5_cavern`, which open memories.

| Step | Pieces (Play) | Marker id | Area | Event string |
|------|---------------|-----------|------|--------------|
| 4.8 (entry) | `travel, talk` | `from_desa_purwa` | `sk_pantai` | `zone_entered:sk_pantai`, sets `mq4_i6` |
| 4.9 Arrival: rest at `kidul_1`, enter Kampung Nelayan | `travel, fight, talk, beat` | `kidul_pantai_1`, `kidul_pantai_2`, `kidul_1` (Q), `semar` (`M`, cond `step:mq4=8`), `sk_nelayan` | `sk_pantai`, `sk_nelayan` | `petilasan_activated:kidul_1`; then `zone_entered:sk_nelayan`, sets `mq4_a1` (beat `song_hook`, `codex:sedekah_laut`) |
| 4.10 Meet Mbah Wiryo and Sari | `talk, travel, fight, talk` | `kidul_jurukunci` (Q, `J` in `sk_nelayan` until `mq4_4`), `kidul_pantai_3`, `kidul_sari` (`S` in `sk_nelayan`) | `sk_nelayan`, `sk_pantai` | `talked_to:kidul_jurukunci`, sets `mq4_4`; then `talked_to:kidul_sari`, sets `mq4_4b` |
| 4.11 K8 clues: three verses of the sea song | `travel, clue x2, fight, clue, beat` | `song_1`, `song_2`, `song_3` (Q; `song_3` has `memory_id: k8_wiryo_wife`), `kidul_pantai_2` | `sk_pantai` (net yard, then the shore) | `all`: `clue_examined:song_1`, `song_2`, `song_3`; sets `mq4_h1` (beat `song_whole`) |
| 4.12 K8 memory | `memory, puzzle, beat, talk` | `k8_wiryo_wife`, Mbah Wiryo `J` (`flag:mq4_4`) | `zones/kelir/k8_wiryo_wife.tscn`, `sk_pantai` | `memory_done:k8_wiryo_wife`, sets `mq4_h2` (beat `wiryo_dusk`) |
| 4.13 The mangrove beacons with Sari | `travel, talk, puzzle, fight x2` | `kidul_sari` (`S`, cond `step:mq4=12`), `bakau_beacons`, `bakau_pack` | `sk_bakau` | `puzzle_solved:bakau_beacons`, sets `mq4_5a` (beat `beacons_lit`) |
| 4.14 Sacred Trial I, the Torch-Lines | `setpiece, clue, fight x2, miniboss` | `kidul_karang_3`, `reef_thread`, `puzzle_kidul_tide`, `kidul_karang_4`, `kidul_karang_2` | `sk_karang` | `area_cleared:kidul_karang_2`, sets `mq4_5b` (beat `trial_torch`) |
| 4.15 The sea cavern approach | `travel, fight, clue, fight, beat` | `gua_bell_marks`, `gua_karang_approach` | `sk_gua` | `area_cleared:gua_karang_approach`, sets `mq4_6a` (beat `gua_approach`) |
| 4.16 LC5: the sunken bells | `chapter, puzzle, beat` | `lc5_cavern` (`memory_id: lc5`) | `sk_gua` and `zones/kelir/lc5.tscn` | `memory_done:lc5`, sets `mq4_lc`, `laras_key:tidal_gate` (`flag:laras_key_tidal_gate` opens `kidul_gua_trial`) |
| 4.17 Sacred Trial II, the Abyssal Current | `setpiece, fight, talk, fight, miniboss` | `kidul_gua_trial` (cond `flag:laras_key_tidal_gate`), `kidul_sari` (`S` at the gua mouth, cond `step:mq4=16`) | `sk_gua` | `area_cleared:kidul_gua_trial`, sets `mq4_6b` (beat `trial_current`) |
| 4.18 Climb the cliffs, rest at `kidul_3`, K9 | `travel, fight x2, memory, beat` | `kidul_tebing_1`, `kidul_tebing_2`, `kidul_3` (Q), `shrine_tale` (`memory_id: k9_queen_south`) | `sk_tebing` and `zones/kelir/k9_queen_south.tscn` | `area_cleared:kidul_tebing_2`; then `petilasan_activated:kidul_3`; then `memory_done:k9_queen_south`, sets `mq4_h3` (beat `k9_after`) |
| 4.19 Call Laras's name at the cliff altar, Choice 5 | `talk, puzzle, fight, beat` | `cliff_altar` (`C`) | `sk_tebing` | `flag:mq4_offering` (`choice_offer_memory` / `choice_offer_song`; beats `offering_memory`, `offering_song`); opens the causeway kabut `K` and the drop kabut `Z` |
| 4.20 The causeway into the Sea Pavilion | `travel, fight x2, clue, talk` | `causeway_post` (`Q`), `kidul_karang_1`, `semar` (`M`, cond `step:mq4=19`), `kidul_2` | `sk_karang` (causeway), `sk_keraton` (pendopo) | `petilasan_activated:kidul_2`, sets `mq4_7` |
| 4.21 Sacred Trial III, the Waves | `setpiece, clue, setpiece, miniboss, beat` | `kidul_trial`, `trial_sign_1`, `trial_sign_2` | `sk_keraton` outer court | `area_cleared:kidul_trial`, sets `mq4_8` (beat `kidul_trial`: Nyi Roro Kidul speaks once, from a distance) |
| 4.22 Receive Ombak and the Kain Hijau | `write, lesson, puzzle, beat, talk` | `kidul_altar` | `sk_keraton` pendopo (Sea Altar) | the altar entry (cond `step:mq4=21`) runs `write:ombak:jawa_ka` and `give:kain_hijau`; `glyph_learned:jawa_ka` (Q), sets `mq4_9`, MQ4 done, lifts the kabut on X3. Beat `kidul` (if `quest:mq4=done`): Semar, `start:mq5` |
| SQ-K1 start | `kidul_nelayan_anak` | `sk_pantai` | `talked_to:kidul_nelayan_anak`. Unlock: `zone_entered:segara_kidul` (ASSUMED) |
| SQ-K1 (1) pick up 3 hatchlings, (2) carry them to the surf | pickups `1`-`3` (sparkle), then `T` | `sk_pantai` dunes to shore | `item_picked:tukik_*` x3, then `area_entered:kidul_tukik_laut` once (synced 2026-11-06 to the map's 3 pickups) |
| SQ-K1 turn in | `kidul_nelayan_anak` | `sk_pantai` | `talked_to:kidul_nelayan_anak`. Reward Herb Pouch #4 |
| SQ-K2 (1) the fisher at the river mouth | `k2_fisher` | `sk_karang` (cove mouth) | `talked_to:k2_fisher`. Unlock: `flag:mq4_4` (Mbah Wiryo met, step 4.10) |
| SQ-K2 (2) `all`: the white scale, Mbah Wiryo's line | `k2_scale`, `kidul_jurukunci` | `sk_karang`, `sk_pantai` | `clue_examined:k2_scale`, `talked_to:kidul_jurukunci` |
| SQ-K2 (3) the fisher's memory | `k2_scale` (`memory_id: sq_k2_fisher`) | `zones/kelir/sq_k2_fisher.tscn` | `memory_done:sq_k2_fisher` |
| SQ-K2 (4) drive back the old one | `bajul_putih_tua` | `sk_karang` (river-mouth arena, trigger `kidul_elite_cove`) | `enemy_killed:bajul_putih_tua` (at 0 HP it dives; a fade) |
| SQ-K2 (5) report | `k2_fisher` | `sk_karang` | `talked_to:k2_fisher`. The fishers cast again and leave a first catch on the sand |
| C3 fragment 3 (Act V) | `c3_shore_net` | `sk_pantai` (net yard) | `clue_examined:c3_shore_net`, cond `flag:mq4_4` |
| C4 part 3 (1) Cepot on the coast | `cepot` | `sk_pantai` (hatchlings' beach) | `talked_to:cepot`. Unlock: `flag:c4_2`, `flag:mq4_4` |
| C4 part 3 (2) hold the lamp through one wave | `c4_lamp` | `sk_pantai` (hatchlings' beach, trigger `kidul_tukik_laut` rect) | `trial_completed:c4_lamp` |
| C4 part 3 (3) | `cepot` | `sk_pantai` | `talked_to:cepot`; sets `c4_done` |
| Camp talk `camp_kidul` | `kidul_jurukunci` | `sk_pantai` (petilasan `kidul_1`; two variants after Choice 5, `choice_offer_song` / `choice_offer_memory`) | entry `camp_kidul`, cond `flag:mq4_8`, `zone:sk_pantai`, `!flag:mq5_1`; `"quiet": true`, `do`: `flag:camp_kidul`; never a step |
| Petilasans | `kidul_1`, `kidul_3`, `kidul_2` | pantai, tebing, keraton | steps 4.9, 4.18 and 4.20 |
| Codex | `kidul_keraton_codex` | `sk_keraton` | `codex:nyi_roro_kidul` (ASSUMED) |

### Side stories v4d spots (2026-11-06)
Not drawn into the maps (**ASSUMED**: the builder adds them as plain spots at these coordinates, on floor tiles; `gen_zones.py` reads only the legends). Clue props follow `{clue_id, memory_id?, cond?}`; the memory id sits on the clue examined last (as `song_3` does), and `cond` uses `quest:<id>=active` or a flag.

| Area | Spot | Scene and props | At | Card | Notes |
|------|------|-----------------|----|------|-------|
| `sk_karang` | `k2_fisher` | NPC `{npc_id:"k2_fisher", cond:"flag:mq4_4"}`, `quiet` entries | (44,27) | SQ-K2 | An unnamed fisher at the river mouth (the cove entrance `T` (46,25) is the river mouth, **ASSUMED**). Pak Raka `A` stays the hut warning of 4.9 and is not the giver |
| `sk_karang` | `k2_scale` | `clue.tscn` `{clue_id:"k2_scale", memory_id:"sq_k2_fisher", cond:"quest:sq_k2=active"}` | (49,27) | SQ-K2 | A white scale in the torn net on the sand. Opens `sq_k2_fisher` once Mbah Wiryo has spoken |
| `sk_pantai` | Mbah Wiryo's line | entry in the `kidul_jurukunci` dialogue, `quiet`, cond `quest:sq_k2=active` (`talked_to:kidul_jurukunci`) | `J` (25,14) | SQ-K2 | One line only: the old one who keeps the river mouth, the white crocodile; told as belief (**VERIFY**), never the Queen's servant |
| `sk_karang` | the river-mouth arena | trigger `T` `kidul_elite_cove` (46,25), elite `q` (48,22) `bajul_putih_tua` | cove room (42,20)-(54,24) | SQ-K2 | Fight only. The elite lunges after a tide tell (the water draws back 1 s before the charge, **TUNE**); at 0 HP it dives into the deep and fades, no corpse. Ga Ward on the lunge (**ASSUMED**) |
| `sk_pantai` | `c3_shore_net` | `clue.tscn` `{clue_id:"c3_shore_net", cond:"flag:mq4_4"}` | (24,22) | SQ-C3 fragment 3 | A knot of net on the black-sand shore of the net yard (rect (7,21)-(26,27)), with a stitched sound. Freed variant: a scrap in the net. Handed variant: Uwa Lengser's note |
| `sk_pantai` | `cepot` | NPC `{npc_id:"cepot", cond:"flag:c4_2,flag:mq4_4,!flag:c4_done"}` | (38,28) | SQ-C4 part 3 | At the edge of the hatchlings' beach, afraid of the sea; `quiet` entries |
| `sk_pantai` | `c4_lamp` | trigger, `trigger_id` `trial_c4_lamp`, same rect as `kidul_tukik_laut` `T` (42,28), `size:Vector2i(7,5)` | (42,28) | SQ-C4 part 3 | Reuses SQ-K1's hatchlings' beach with its conservation note. The player holds a lamp (interact, hold) at the surf line through one wave (8 s, **TUNE**, **ASSUMED**); the hatchlings go down to the sea by its light; no enemy. Completing it fires `trial_completed:c4_lamp`. Works with or without SQ-K1 done |
| `sk_pantai` | `camp_kidul` | `kidul_jurukunci` entry in the same NPC `J` (25,14), by petilasan `kidul_1` (20,14) | (25,14) | MQ4 camp talk | Optional, 2-4 lines after the trial: what he will say to the sea now. Cond `flag:mq4_8`, `zone:sk_pantai`, `!flag:mq5_1`; `"quiet": true`; `do`: `flag:camp_kidul` (**ASSUMED**). Never completes a step |

Every step 4.9-4.22 and every Act V beat of quests.md MQ4 (`song_hook`, `song_whole`, `wiryo_dusk`, `beacons_lit`, `trial_torch`, `gua_approach`, `trial_current`, `k9_after`, `offering_memory`, `offering_song`, `kidul_trial`, `kidul`) has a location (the Interlude beats are in Desa Purwa). Flags read or set in this region: `mq4_2` (read, gates X1), `mq4_9` (also gates X2), `mq4_4`, `mq4_offering` (gates L3 and D1), `mq4_8`, `mq4_9` (set), `sc:sk_gerbang` and `sc:ts_sk` (shortcuts). Retired from the v2 doc: `mq3_8`, `mq4_3`, `mq4_5`, `trial_completed:kidul`, marker `kidul_edge`.

## Memory scenes (Story v4/v4b, [architecture.md](../architecture.md) 9b)
Small own scenes under `zones/kelir/`, not areas (no `## Area n:` heading, so `gen_zones.py` skips them). Built on `memory.gd` with a `Stand` marker and `Checkpoint` markers. Chars are this section's own (`_` lit floor, `#` dark wall, `~` water). Semar narrates 1-2 lines at the start and end; Laras chapters use her own lines. No death or fight is shown. All numbers **TUNE**.

### Memory `k8_wiryo_wife`: calling a name to the sea (K8)

- Scene `res://zones/kelir/k8_wiryo_wife.tscn` (not a Zone: no `gen_zones.py` output; generated by `gen_memories.py` on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `walk`. Size 30x17.
- Stand-in: Mbah Wiryo's wife, young (silhouette); her husband `w` walks beside her.
- The one action: `interact` at each calling point `c` = call a name to the water; the sea answers (echo and a ripple). No fail state.
- Goal: Walk the shore at dusk, teaching him to call a name to the water at three points; then she walks into the evening light `G` (no death shown, fade to light). Teaches calling a name to the sea, the opening of the trial. Entered from `song_3`.
- Checkpoints: none (no fail state).

```
##############################
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#__________________________G_#
#____________________________#
#____________________________#
#___S_w______________________#
#____________________________#
#_________c_____c_____c______#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
##############################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (4,9) | start |
| `w` | her husband (6,9) | follows one step behind |
| `c` | calling point | 3, on the waterline at (10,11), (16,11), (22,11) |
| `G` | the evening light (27,6) | goal; the memory ends in the lamp |
| `~` | surf | not walkable |

### Memory `k9_queen_south`: the queen of the south, as one retelling (K9)

- Scene `res://zones/kelir/k9_queen_south.tscn` (not a Zone: no `gen_zones.py` output; generated by `gen_memories.py` on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `walk`. Size 60x17 (two screens).
- Stand-in: the sea queen in Ki Sumarto's telling (a robed silhouette; **VERIFY**, shown with respect, as belief).
- The one action: none (walk only; she pauses at each retelling).
- Goal: Pass three alcoves, each with another retelling of her (`A` the princess sent away, `B` the lady of the green sea, `C` the one who keeps the sea's memory); Ki Sumarto says in his closing line that these are tellings among many. No fight. Entered from `shrine_tale` at the cliff shrine.
- Checkpoints: none (no fail state).

```
############################################################
############################################################
############################################################
#__________________##__________________##__________________#
#__________________##__________________##__________________#
#_________T________##_________T________##_________T________#
#__________________##__________________##__________________#
#__________________##__________________##__________________#
#__S______A___________________B___________________C______G_#
#__________________##__________________##__________________#
#__________________##__________________##__________________#
#__________________##__________________##__________________#
#__________________##__________________##__________________#
#__________________##__________________##__________________#
############################################################
############################################################
############################################################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (3,8) | start |
| `A` | retelling 1 (10,8) | a silhouette figure and a short kelir panel |
| `B` | retelling 2 (30,8) |  |
| `C` | retelling 3 (50,8) |  |
| `T` | narration stops | 3, Ki Sumarto, 1 line each |
| `G` | goal (57,8) | fade to the lamp |

### Memory `lc5`: the voice on the water (LC5)

- Scene `res://zones/kelir/lc5.tscn` (not a Zone: no `gen_zones.py` output; generated by `gen_memories.py` on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `chapter`. Size 30x17.
- Stand-in: Laras (`entities/player/stand_in_laras.tscn`), cooler blue tint; the lamp radius is small (Kala's dark).
- The one action: `interact` = say a Faceless's true name: it freezes for 3 s (6 s cooldown).
- Goal: Follow the voice that says her name through four calling points `V` to `G`; the sea still says it. One Faceless patrol `f` walks the middle row between `V` 2 and `V` 3. Ends with the *Ka* write card, then `memory_done:lc5`.
- Checkpoints: `C` (3,9) and (14,9). Seen by the Faceless = `fail()`: fade to the last `C`, no HP loss.

```
##############################
#____________________________#
#____________________________#
#____________________________#
#_________________h__________#
#_____________V______________#
#____________________________#
#_______fffffffffffff________#
#__S__V____________________G_#
#__C__________C______________#
#_____________________V______#
#____________________________#
#_________h__________________#
#____________________________#
#____________________________#
#____________________________#
##############################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (3,8) | start |
| `V` | voice point | 4, at (6,8), (14,5), (22,10); the fourth is `G` |
| `f` | Faceless patrol | row y=7, x 8..20 |
| `h` | hide prop | 2 |
| `C` | checkpoint | 2 |
| `G` | goal (27,8) | the write card |

### Memory `sq_k2_fisher`: the offering at the river mouth (SQ-K2)

- Scene `res://zones/kelir/sq_k2_fisher.tscn` (not a Zone; generated by `gen_memories.py` on `memory.gd`). Kind `walk`. Size 30x17. Opened by clue `k2_scale` in `sk_karang`.
- Stand-in: a fisher (a small silhouette) carrying an offering basket.
- The one action: none (walk only); at the waterline he sets the offering down and steps back.
- Goal: Walk to the river mouth `G` and leave the offering, as a belief told with respect (**VERIFY**). Teaches the tide tell: the water draws back a moment before the old one's charge. No fight.
- Checkpoints: none (no fail state).
- Layout: a plain 30x17 room with a river-mouth `~` in the east third, Stand (3,8), tide-tell point `T` (20,8), goal `G` (24,8), all **TUNE**.

### Memory `sq_c3_ranga`: the day his name was taken

- Scene `res://zones/kelir/sq_c3_ranga.tscn` (not a Zone; generated by `gen_memories.py` on `memory.gd`). Kind `walk`. Size 30x17. Opened by clue `c3_shore_net` in `sk_nelayan`.
- Stand-in: Ranga (young soldier silhouette) before the mask.
- The one action: none (walk only).
- Goal: Relive the day Ranga's name was taken at the camp and the syllable cloth was hidden.
- Checkpoints: none (no fail state).
- Layout: Stand(2,8) -> T(10,8):DLG_MEM_C3_1 -> T(18,8):DLG_MEM_C3_2 -> E(26,8):DLG_MEM_C3_3

## Flow
Arrive at `sk_pantai` (`from_desa_purwa`, green glow on the horizon; 4.8) > petilasan `kidul_1` with Semar, teach encounters (Lampor, Ula Segara) (4.9) > west to `sk_nelayan`, beat `song_hook`, Mbah Wiryo and Sari (4.10) > the net yard and the shore in `sk_pantai`: three families, three verses (4.11), the K8 memory and the dusk talk (4.12) > `sk_nelayan` east to `sk_bakau`: the beacons with Sari (4.13) > `sk_karang`: Trial I across the reef, the thread clue, the tide-pool puzzle, the Ula Segara miniboss at the stair foot (4.14) > east to `sk_gua`: the bell marks and the approach fight (4.15), LC5 (4.16), Trial II (4.17) with Sari at the mouth > north to `sk_tebing`: two cliff fights, `kidul_3`, the K9 memory (4.18), the cliff altar and Choice 5 (4.19) > back down to `sk_karang` and the causeway (kabut `mq4_offering`, `causeway_post`) > `sk_keraton`: `kidul_2` with Semar (4.20), the Trial of the Waves (4.21), Nyi Roro Kidul speaks once, Ombak and the Kain Hijau at the Sea Altar (4.22) > kabut `mq4_9` gone > `gk_mulut`. Optional: the cove, chests, the turtle nest, `sc:sk_gerbang` and `sc:ts_sk`.

## Self-check ([AGENTS.md](../../AGENTS.md) section 5 Step 2), re-run for Story v5 2026-11-06
- [~] POI counts: 0 boss arenas (the trial site replaces it, by design), 1 elite room plus the miniboss on the path (`kidul_karang_2`), 4 NPCs (3-5; the net mender and the three families are unnamed locals), 3 secrets (2-3), 1 codex spot, 11 encounters (6-10; every extra is a piece the step tables count), 3 petilasans (full-act exception, world.md rule 7).
- [x] Petilasan before the trial/exit: `kidul_3` is beside the drop, no fight between it and the pavilion court; the K9 memory and LC5 chapter are scenes, not fights. `kidul_2` is in the calm pendopo before the kabut to Gua Kala.
- [x] First appearances: `kidul_pantai_1` (Lampor alone), `_2` (Ula with known Lampor), `_3` (Bajul alone, optional); the reef lane (`kidul_karang_3`) repeats Bajul with known Lampor; the miniboss reuses the Ula Segara with its known Ka Bolt answer.
- [~] One tank per encounter: yes. Trial W2 has 2 Ula Segara (two shooters), the trial has 3 waves, both fixed by bestiary.md and quests.md 4.21. Named exception.
- [x] Rooms with 4+ enemies: trial ring 21x11, tebing landing and ledge 17x9 and 19x9. Bajul lanes 8-10 tiles (`kidul_pantai_3` 10, `kidul_karang_3` 8+). The new fights have 3 enemies.
- [~] Newest glyph: Ombak has no weakness and arrives at the end of the region; Burst, Bolt and Ward are the trial answers. Accepted.
- [x] Every MQ4 step 4.9-4.22, clue id (`song_1`, `song_2`, `song_3`, `reef_thread`, `gua_bell_marks`, `lc5_cavern`, `shrine_tale`, `causeway_post`, `trial_sign_1`, `trial_sign_2`), memory id (`k8_wiryo_wife`, `k9_queen_south`, `lc5`), beat, SQ-K1 and SQ-K2 step has a marker and area (table above).
- [x] Critical path without Jawa Ka: kabuts `mq4_2`, `mq4_offering`, `mq4_9` open on story flags; the puzzle `puzzle_kidul_tide` gates nothing; the trial is passed by melee and dodge as well.
- [x] Rule 1, at least 2 loops: loops A and B (world.md asks for 2).
- [x] Rule 2, at least 2 shortcuts: `sc:sk_gerbang` leads to `sk_pantai` (`kidul_1`); `sc:ts_sk` ends one link from `sunda_2`.
- [x] Rule 3, at least 1 drop: D1.
- [x] Rule 4, optional areas branch off a loop: there are no optional areas now (all 7 are on the path); the cove is on loop A.
- [x] Rule 5, landmark: the green glow of the pavilion shows from the first spawn, and the sea arch stands offshore.
- [x] Rule 6, petilasan right before the trial/exit: `kidul_3` before the trial, `kidul_2` before the kabut.
- [~] Rule 7, petilasans: 3, because the region is a full act (ASSUMED, world.md "3 in the largest"). Rule 8: the critical path visits 7 of 7 areas, gates follow story flags, glyphs are rewards.
- [x] Pacing: arrival slice (the net village) first, then the first fight `kidul_pantai_1` within 5 minutes of the first spawn (Pacing v4b); LC5 at `kidul_3` replaces the Laras beat; turn = the trial and Nyi Roro Kidul's voice; aftermath = Semar's beat at the altar (hands you Gua Kala); the Hunter is felt in the Interlude, not here.
- [x] Pacing rule 5: forward-only sweep, `sc:sk_gerbang` for later trips. Pacing rule 7: every area holds an optional find (pantai: chest, SQ-K1; karang: cove, chest, SQ-K2; tebing: chest, `sc:ts_sk`; keraton: codex).

## ASSUMED
- Gate flags `mq4_2` (from quests.md), `mq4_offering`, `mq4_8`, `mq4_9`, `mq4_4`; shortcut ids `sc:sk_gerbang` (and its position); the loop layout, D1 location and landing; link L4 (karang north-west stair to tebing) and removing the pantai to tebing link; kabut on L3 (`mq4_8`).
- The third petilasan `kidul_3` (quests.md 4.18 names it) and the 3-petilasan exception for a full act.
- All npc ids except `semar`, `kidul_jurukunci` (Q), the encounter ids, chest ids, trigger ids (`kidul_tukik_laut`, `kidul_elite_cove`), `kidul_ratu`, `kidul_altar`, `codex:nyi_roro_kidul`, marker ids `kidul_karang`, `kidul_tebing`, `kidul_3`.
- The trial in the pavilion court (moved from the beach), the pavilion as a peaceful sanctum with fights only in the trial ring, no enemy tied to Nyi Roro Kidul.
- Mbah Wiryo's name and backstory (his late wife's name said to the sea) is story.md canon; the map has him as the NPC `kidul_jurukunci`.
- Semar is at `kidul_1` (story.md: guide at petilasan).
- Elite Bajul Putih Tua can be Warded on the lunge.
- Lampor in the tebing line count: 4 (bestiary says 3-5). Trial W1 4 Lampor, W2 2 Ula Segara + 1 Lampor (as the pantai map had it).
- SQ-K1 and SQ-K2 start and turn-in talks, and the hatchling counting trigger.
- A player entering from `tt_pesisir` walks one extra crossing of the reef.

- v4c (2026-11-06): `kidul_karang_3` and `kidul_karang_2` swapped places (the Bajul lane fight is on the road, the Ula Segara elite is at the stair foot, so the step's `area_cleared:kidul_karang_2` is the last reef fight); the south causeway spot is empty. `kidul_karang_4` and the three setpiece waves are the pieces `fight` and `setpiece` that 4.14 and 4.21 count. Unnamed clue ids: `reef_thread`, `trial_sign_1`, `trial_sign_2`, `shrine_tale`, `lc5_lontar` (retired in v5; journal note only except the memory ones). The net village is the existing `_` yard at (7..26,21..27) of `sk_pantai`; the three families are the three song clues.

- Story v5 pass (**ASSUMED**): Mbah Wiryo has two instances (`J` in `sk_nelayan` with cond `!flag:mq4_4`, `J` in `sk_pantai` with cond `flag:mq4_4`); Sari has four (`sk_nelayan` `S` until `mq4_h2` and `s` after `mq4_8`, `sk_bakau` `S` at `step:mq4=12`, the mouth of `sk_gua` `S` at `step:mq4=16`); Semar stands at `kidul_1` (`step:mq4=8`) and `kidul_2` (`step:mq4=19`). The causeway kabut (L3) and a new drop kabut `Z` on D1 lift with Choice 5 (`mq4_offering`), so the Sea Pavilion cannot be reached before the cliff altar; the old `mq4_8` kabut flag is retired. `kidul_gua_trial` carries cond `flag:laras_key_tidal_gate`. New journal clues `gua_bell_marks` (`sk_gua` (28,21)) and `causeway_post` (`sk_karang` (30,27)); `lc5_lontar` is gone (the chapter opens from `lc5_cavern`). The direct link L1 (`sk_pantai` to `sk_karang`) is kept, so the order pantai > nelayan > bakau > karang is held by the quest arrow only.

## Open questions
1. VERIFY: wearing green on the south coast and her association with the Parangkusumo / Parangtritis shore (a ritual stage, Panggung Sanggabuwana). Do not name real places in game text without a source.
2. VERIFY: sea-gate and "keraton" imagery (palace under the sea). A single source for any codex line.
3. ~~SQ-K1 mentions crabs and birds that block hatchlings.~~ Resolved 2026-11-06: SQ-K1 is the built 3-pickup version, no crabs or birds.
4. Who gives Jawa Ka? Here the trial and the sea, with Nyi Roro Kidul speaking once, at the Sea Altar (quests.md 4.9).
5. Does the quest engine complete a step whose event already happened (for a `tt_pesisir` arrival who cleared `kidul_karang_2` on the first pass)? If not, the second crossing needs the encounter to respawn, or the step must accept the cleared state. quests.md 7 does not say.
6. Mbah Wiryo's words to the sea: the name of his wife. Script.md owns the line (VERIFY nothing cultural, but keep the name plain, not a real figure).

## Doc conflicts found (not fixed)
- Resolved 2026-11-06 (consistency pass): the `mq3_8` gates in tanah_timur.md and desa_purwa.md now read `mq4_9` and `mq4_2`/`mq4_9`; bestiary.md and spells.md call Segara Kidul main path and P0; script.md uses Mbah Wiryo and the v3.1 flow.
- bestiary.md trial W2 has 2 Ula Segara (two shooters) and the trial has 3 waves. Both break the Encounters rules (at most one shooter, at most two waves). Kept as written, the trial is a named exception. bestiary.md Zone 4 and AGENTS.md still place the trial on the beach/flat; it is now in `sk_keraton`.
- bestiary.md Zone 4 says mundane enemies are still to be added. Here only Lampor, Ula Segara and Bajul Putih are used, so the "2-3 mundane plus 1-2 folklore" mix rule is not met.
- world.md interlock rule 5 (boss site as landmark) and AGENTS.md "1 boss arena" assume a boss. Segara Kidul has none, so the pavilion court stands in for the arena and its glow for the landmark. AGENTS.md "1-2 petilasans" vs 3 here (world.md rule 7 allows 3 in the largest region; AGENTS.md checklist should say so).
- world.md calls the ts_situ end of `sc:ts_sk` an area (`ts_situ`), but tatar_sunda.md is still a single zone `tatar_sunda`. The `ts_*` split and the position of `sunda_2` relative to `ts_situ` are undefined.
- quests.md 4.1 and SQ-K1/K2 unlocks use `zone_entered:segara_kidul`, a region id, while the scenes are areas (`sk_*`). The event must fire on the first area entered. (MQ4 4.1 is now `zone_entered:desa_purwa`.)
- bestiary.md trial text names "the tidal flat" and the stumps; the trial is now in the pavilion court (3 waves from the pools and shallows).
- Area sizes: the v2 area table listed 3x3 / 3x2 / 2x3 areas, but the maps were always 60 x 34 tiles. The table now matches the maps.

## Area 1: sk_karang

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Dark reef rock, tide pools, a long sandbar from `tt_pesisir`, a fishing hut in the west, a switchback stair up the cliff in the north-west (to `sk_tebing`), and a rocky south-east cove where Bajul Putih Tua lurks.
- Purpose: MQ4 4.14 (Trial I, `kidul_karang_2`) and 4.20 (the causeway, `causeway_post`). Entry from `tt_pesisir`, reef encounters (`kidul_karang_1`, `kidul_karang_2`, `kidul_karang_3`), NPC `kidul_nelayan_tua` (SQ-K2), elite room `kidul_elite_cove` (`bajul_putih_tua`), secret chest `kidul_chest_2`, the cliff stair north to `sk_tebing` (the main path, link L4), and the south causeway to `sk_keraton` (kabut `mq4_8`, open only after the Trial, so the way in is the drop).

### Map
```
############UU##############NN##############################
#...........u...............n,.............................#
#.......rr..................,,............rr...............#
#.......rr....G.............,,............rr...............#
#...........................,,.............................#
#...........................,,........E....................#
#...........................,,.............................#
#.....~~~~~~~~..............,,...................rrrrrr....#
#.....~~~~~~~~..............,,...................r....r....#
#.....~~~~~~~~......B.......,,...................r..c.r....#
#...........................,,...................r....r....#
#.........D.................,,........................r....#
#..............rr...........,,...................rrrrrr....X
#..............rr...........,,............................xX
#...........................,,.............................#
#......A....................,,.............................#
Ww,,,,,,,,,,,,,,,,F,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Y
W,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,yY
#.....................C.....,,.............................#
#...........................,,.............................#
#.........~~~~~~~~..........,,............#############....#
#.........~~~~~~~~..........,,............#...........#....#
#.........~~~~~~~~..........,,............#.....q.....#....#
#...........................,,............#...........#....#
#...........................,,............#####...#####....#
#...........................,,................T............#
#..............rr...........,,.............................#
#..............rr...........,,Q............................#
#...........................,,.............................#
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
| `K` | kabut on the causeway to the keraton, lifts with Choice 5 (`mq4_offering`, 4.19; one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq4_offering"}` | path | 2 |
| `U` | exit to sk_tebing (north edge, west of centre, 2 tiles; main path, L4) | `res://entities/world/exit.tscn` | `{target_zone:"sk_tebing", spawn_id:"from_sk_karang"}` | path | 2 |
| `u` | spawn, arrival from sk_tebing | `res://entities/world/spawn.tscn` | `{id:"from_sk_tebing"}` | path | 1 |
| `A` | NPC Pak Raka, old fisherman (the hut beat of 4.9 only; the SQ-K2 giver is `k2_fisher`, see Side stories v4d spots) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_nelayan_tua"}` | grass | 1 |
| `E` | encounter kidul_karang_1 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_karang_1", size:Vector2i(17,9), waves:[[[res://entities/enemies/lampor.tscn, Vector2i(4,-2)], [res://entities/enemies/lampor.tscn, Vector2i(5,0)], [res://entities/enemies/lampor.tscn, Vector2i(4,2)]]]}` | grass | 1 |
| `F` | encounter kidul_karang_3 (4.14, fight 1: the reef lane on the road; moved here from the south causeway, so every reef fight is on the way to the stair) | `res://entities/world/encounter.tscn` | `{area_id:"kidul_karang_3", size:Vector2i(19,9), waves:[[[res://entities/enemies/bajul_putih.tscn, Vector2i(6,0)], [res://entities/enemies/lampor.tscn, Vector2i(-4,-2)], [res://entities/enemies/lampor.tscn, Vector2i(-4,2)]]]}` | path | 1 |
| `G` | encounter kidul_karang_2 (**miniboss**, 4.14: an elite Ula Segara `kidul_reef_elite` with 2 Lampor at the foot of the north-west stair; the step completes here) | `res://entities/world/encounter.tscn` | `{area_id:"kidul_karang_2", size:Vector2i(12,6), waves:[[[res://entities/enemies/ula_segara.tscn, Vector2i(4,0)], [res://entities/enemies/lampor.tscn, Vector2i(-3,-1)], [res://entities/enemies/lampor.tscn, Vector2i(-3,1)]]]}` | grass | 1 |
| `T` | trigger, SQ-K2 cove entrance (the river-mouth arena) | `res://entities/world/trigger.tscn` | `{trigger_id:"kidul_elite_cove", size:Vector2i(7,7)}` | grass | 1 |
| `q` | elite Bajul Putih Tua (SQ-K2; `unique_id` `bajul_putih_tua`, inert until step 4; at 0 HP it dives and fades) | `res://entities/enemies/bajul_putih_tua.tscn` | `{unique_id:"bajul_putih_tua"}` | grass | 1 |
| `c` | chest: 380 Ilmu (hidden tide pool) | `res://entities/world/chest.tscn` | `{chest_id:"kidul_chest_2", item_id:"ilmu:380"}` | grass | 1 |
| `B` | encounter kidul_karang_4 (4.14, fight 2, north bank of the tide pool) | `res://entities/world/encounter.tscn` | `{area_id:"kidul_karang_4", size:Vector2i(12,7), waves:[[[res://entities/enemies/lampor.tscn, Vector2i(-3,-1)], [res://entities/enemies/lampor.tscn, Vector2i(0,2)], [res://entities/enemies/lampor.tscn, Vector2i(3,-1)]]]}` | grass | 1 |
| `C` | clue, a green thread tied to a rock on the sandbar: Laras's trail (4.14 `clue` piece; journal note only, ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"reef_thread"}` | grass | 1 |
| `Q` | clue, a mooring post on the sea causeway, rope-marks and a dry shell (4.20 `clue` piece; journal note only, ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"causeway_post"}` | grass | 1 |
| `D` | trigger, puzzle `puzzle_kidul_tide` (4.14: move the water, turn the three sluice stones so the tide pool drains and the sandbar to the stair shows; sets `flag:puzzle_kidul_tide`, no gate) | `res://entities/world/trigger.tscn` | `{trigger_id:"puzzle_kidul_tide", size:Vector2i(8,4)}` | grass | 1 |
| `X` | exit to sk_bakau (east edge, north path, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_bakau", spawn_id:"from_sk_karang"}` | grass | 2 |
| `x` | spawn, arrival from sk_bakau | `res://entities/world/spawn.tscn` | `{id:"from_sk_bakau"}` | grass | 1 |
| `Y` | exit to sk_gua (east edge, main road, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_gua", spawn_id:"from_sk_karang"}` | path | 2 |
| `y` | spawn, arrival from sk_gua | `res://entities/world/spawn.tscn` | `{id:"from_sk_gua"}` | path | 1 |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| reef crossing (4.14) | road row 16..17, pool (6,7)-(13,9), stair foot (12,1)-(15,5) | Fight 1 `F` (18,16), clue `C` (22,18), puzzle `D` (10,11), fight 2 `B` (20,9), miniboss `G` (14,3), then the stair `U` | 4.14 all pieces; causeway clue `Q` (30,27) 4.20 |
## Area 2: sk_pantai

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Black-sand dunes in the north, a wide wet tidal flat in the south, green southern surf, and the barred coral gate (`sc:sk_gerbang`) on the south-east shore.
- Purpose: MQ4 4.8-4.9 and 4.11-4.12 (rest at `kidul_1` with Semar, the K8 clues and memory). Petilasan `kidul_1`, NPCs `semar` `M`, `kidul_jurukunci` (Mbah Wiryo, after `mq4_4`) and `kidul_nelayan_anak` (SQ-K1), teach encounters (`kidul_pantai_1`, `kidul_pantai_2`, `kidul_pantai_3`), north exit to `desa_purwa`, east exit to `sk_karang`, shortcut gate `sc:sk_gerbang` to `sk_keraton`. The Trial of the Waves moved to `sk_keraton`; the tidal flat is now shore and landmark only.

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
#.....................M.....,,.............................#
Ww,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,F,,,,,,,,,,,,,,,yY
W,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Y
#...........................,,.............................#
#.........G.................,,.............................#
#...........................,,........................######
#......____________________.,,........................=,;..$
#......____________________.,,........................=,,..$
#......___A________________.,,........................######
#......_______H____________.,,.............................#
#......_________________s__.,,.............................#
#......__________B_________.,,.............................#
#......____________________.,,........k....................#
#...........................,,.......p....T...l............#
#..............................D...........................#
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
| `N` | exit to desa_purwa (north edge, 2 tiles; X1, kabut `mq4_2` is on the desa_purwa side) | `res://entities/world/exit.tscn` | `{target_zone:"desa_purwa", spawn_id:"from_sk_pantai"}` | path | 2 |
| `n` | spawn, arrival from desa_purwa | `res://entities/world/spawn.tscn` | `{id:"from_desa_purwa"}` | path | 1 |
| `$` | exit to sk_keraton (east edge behind shortcut gate, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_keraton", spawn_id:"from_sk_pantai"}` | path | 2 |
| `;` | spawn, arrival from sk_keraton (on open side of `=`) | `res://entities/world/spawn.tscn` | `{id:"from_sk_keraton"}` | path | 1 |
| `=` | shortcut gate sc:sk_gerbang (opens from sk_keraton, 2 tiles) | `res://entities/world/shortcut.tscn` | `{id:"sc:sk_gerbang", open_side:"e"}` | path | 2 |
| `P` | petilasan 1 | `res://entities/petilasan/petilasan.tscn` | `{id:"kidul_1"}` | grass | 1 |
| `J` | NPC Mbah Wiryo, juru kunci of the Southern Shore (regional character; stands here after the first talk in `sk_nelayan`, hosts the K8 dusk calling and the camp talk) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_jurukunci", cond:"flag:mq4_4"}` | grass | 1 |
| `M` | NPC Semar at petilasan `kidul_1` (4.9 entry K, `"quiet": true`; shared NPC) | `res://entities/npc/npc.tscn` | `{npc_id:"semar", cond:"step:mq4=8"}` | grass | 1 |
| `C` | NPC Damar, fisher child (SQ-K1) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_nelayan_anak"}` | grass | 1 |
| `1` | pickup, stranded hatchling 1 (SQ-K1) | `res://entities/world/pickup.tscn` | `{item_id:"tukik_1"}` | grass | 1 |
| `2` | pickup, stranded hatchling 2 (SQ-K1) | `res://entities/world/pickup.tscn` | `{item_id:"tukik_2"}` | grass | 1 |
| `3` | pickup, stranded hatchling 3 (SQ-K1) | `res://entities/world/pickup.tscn` | `{item_id:"tukik_3"}` | grass | 1 |
| `T` | trigger, surf release spot (SQ-K1) | `res://entities/world/trigger.tscn` | `{trigger_id:"kidul_tukik_laut", size:Vector2i(7,5)}` | grass | 1 |
| `E` | encounter kidul_pantai_1 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_pantai_1", size:Vector2i(17,9), waves:[[[res://entities/enemies/lampor.tscn, Vector2i(4,-2)], [res://entities/enemies/lampor.tscn, Vector2i(5,0)], [res://entities/enemies/lampor.tscn, Vector2i(4,2)]]]}` | grass | 1 |
| `F` | encounter kidul_pantai_2 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_pantai_2", size:Vector2i(17,9), waves:[[[res://entities/enemies/ula_segara.tscn, Vector2i(6,0)], [res://entities/enemies/lampor.tscn, Vector2i(3,-2)], [res://entities/enemies/lampor.tscn, Vector2i(3,2)]]]}` | path | 1 |
| `G` | encounter kidul_pantai_3 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_pantai_3", size:Vector2i(17,9), waves:[[[res://entities/enemies/bajul_putih.tscn, Vector2i(6,0)]]]}` | grass | 1 |
| `c` | chest: 380 Ilmu (behind driftwood) | `res://entities/world/chest.tscn` | `{chest_id:"kidul_chest_1", item_id:"ilmu:380"}` | grass | 1 |
| `A` | clue, the first forgotten verse, with the net-mending family at the west end of the net yard (4.11 K8, 1 of 3) | `res://entities/world/clue.tscn` | `{clue_id:"song_1"}` | floor | 1 |
| `B` | clue, the second verse, with the family drying the sea-offering baskets (4.11 K8, 2 of 3) | `res://entities/world/clue.tscn` | `{clue_id:"song_2"}` | floor | 1 |
| `D` | clue, the third verse, with Mbah Wiryo's own family on the shore rock where he calls his wife's name at dusk (4.11 K8, 3 of 3; opens memory `k8_wiryo_wife`) | `res://entities/world/clue.tscn` | `{clue_id:"song_3", memory_id:"k8_wiryo_wife"}` | grass | 1 |
| `H` | NPC net mender (arrival slice, flavor: the village is mending nets for the sea offering but nobody remembers the songs; unnamed) | `res://entities/npc/npc.tscn` | `{npc_id:"nelayan_jala"}` | floor | 1 |
| `W` | exit to sk_nelayan (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_nelayan", spawn_id:"from_sk_pantai"}` | path | 2 |
| `w` | spawn, arrival from sk_nelayan | `res://entities/world/spawn.tscn` | `{id:"from_sk_nelayan"}` | path | 1 |
| `k` | NPC river-mouth fisher (SQ-K2) | `res://entities/npc/npc.tscn` | `{npc_id:"k2_fisher"}` | grass | 1 |
| `s` | clue, Ranga's carved driftwood token in the shore net (SQ-C3) | `res://entities/world/clue.tscn` | `{clue_id:"c3_shore_net", memory_id:"sq_c3_ranga"}` | floor | 1 |
| `p` | NPC Cepot on the coast (SQ-C4 part 3) | `res://entities/npc/npc.tscn` | `{npc_id:"cepot"}` | grass | 1 |
| `l` | trigger, hold the ward-lamp through the wave (SQ-C4 part 3) | `res://entities/world/trigger.tscn` | `{trigger_id:"c4_lamp", size:Vector2i(7,5)}` | grass | 1 |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| net yard (the village) | (7,21)-(26,27) 20x7 | Arrival slice: the fishing village mends nets for the sea offering | clue `A` song_1 (10,23), clue `B` song_2 (17,26), net mender `H` (14,24) | 4.9 view, 4.11 |
| shore rock | (28,28)-(34,29) | Mbah Wiryo's family, dusk calling place | clue `D` song_3 (31,29) | 4.11, opens K8 (4.12) |
## Area 3: sk_tebing

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: High black sea cliffs, switchback stone stairs, wind-carved sea cave in the north-east, a small cliff shrine with a lamp above the drop, and a cliff-edge slide dropping onto `sk_keraton`.
- Purpose: MQ4 4.18-4.19 (climb the cliff path, rest at the cliff shrine `kidul_3`, K9 memory, the cliff altar and Choice 5; LC5 is now in `sk_gua`). On the main path, entered from `sk_karang` (south edge, link L4). Also holds the `sc:ts_sk` cliff shortcut into Tatar Sunda (`ts_situ`), two cliff encounters (`kidul_tebing_1`, `kidul_tebing_2`), secret chest `kidul_chest_3`, petilasan `kidul_3` (beside the drop, after the last fight) and the one-way drop `D` to `sk_keraton`. There is no link to `sk_pantai` any more.

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
#..........................,,........................C.P..ZD
#..........................,,.............................ZD
#..........................,,........................A.....#
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
#.............g............s,..............................#
#############GG############SS###############################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `S` | exit to sk_karang (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_karang", spawn_id:"from_sk_tebing"}` | path | 2 |
| `s` | spawn, arrival from sk_karang | `res://entities/world/spawn.tscn` | `{id:"from_sk_karang"}` | path | 1 |
| `G` | exit to sk_gua (south-west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_gua", spawn_id:"from_sk_tebing"}` | grass | 2 |
| `g` | spawn, arrival from sk_gua | `res://entities/world/spawn.tscn` | `{id:"from_sk_gua"}` | grass | 1 |
| `P` | petilasan 3, the cliff shrine (K9 memory and LC5 chapter) | `res://entities/petilasan/petilasan.tscn` | `{id:"kidul_3"}` | path | 1 |
| `W` | exit to ts_situ (west edge, opens sc:ts_sk in ts_situ, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_situ", spawn_id:"from_sk_tebing"}` | path | 2 |
| `w` | spawn, arrival from ts_situ | `res://entities/world/spawn.tscn` | `{id:"from_ts_situ"}` | path | 1 |
| `D` | exit, one-way drop D1 to sk_keraton (east cliff edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_keraton", spawn_id:"from_sk_tebing"}` | path | 2 |
| `E` | encounter kidul_tebing_1 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_tebing_1", size:Vector2i(17,9), waves:[[[res://entities/enemies/lampor.tscn, Vector2i(3,-3)], [res://entities/enemies/lampor.tscn, Vector2i(4,-1)], [res://entities/enemies/lampor.tscn, Vector2i(4,1)], [res://entities/enemies/lampor.tscn, Vector2i(3,3)]]]}` | path | 1 |
| `F` | encounter kidul_tebing_2 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_tebing_2", size:Vector2i(19,9), waves:[[[res://entities/enemies/ula_segara.tscn, Vector2i(7,0)], [res://entities/enemies/bajul_putih.tscn, Vector2i(4,0)], [res://entities/enemies/lampor.tscn, Vector2i(2,-2)], [res://entities/enemies/lampor.tscn, Vector2i(2,2)]]]}` | grass | 1 |
| `c` | chest: 380 Ilmu (sea cave) | `res://entities/world/chest.tscn` | `{chest_id:"kidul_chest_3", item_id:"ilmu:380"}` | grass | 1 |
| `A` | clue, the shrine's carved tale and lamp, Ki Sumarto's version (4.18; opens memory `k9_queen_south`; ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"shrine_tale", memory_id:"k9_queen_south"}` | grass | 1 |
| `Z` | kabut on the drop D1, lifts with Choice 5 (`mq4_offering`; one per tile; ASSUMED, keeps the drop from skipping the causeway walk) | `res://entities/world/kabut.tscn` | `{flag:"mq4_offering"}` | path | 2 |
| `C` | NPC cliff altar for Choice 5 (4.19, sets `mq4_offering`) | `res://entities/npc/npc.tscn` | `{npc_id:"cliff_altar"}` | grass | 1 |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| cliff shrine | (50,12)-(58,20) | Petilasan `kidul_3`, the shrine tale and the cliff altar beside it, then the drop `D` behind kabut `Z` (58,16..17) | clue `A` shrine_tale (53,18), altar `C` (53,16) | 4.18 memory, 4.19 Choice 5 |
## Area 4: sk_keraton

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Outer causeway and court of green-glass stone over the Southern Sea, leading south into a tranquil inner pendopo where waves lap softly against carved pillars.
- Purpose: MQ4 4.20-4.22. The Trial of the Waves (`kidul_trial`, 3 waves) in the outer court, drop landing from `sk_tebing`, west coral gate exit to `sk_pantai` (opens `sc:sk_gerbang`), inner pendopo with petilasan `kidul_2`, codex `nyi_roro_kidul`, the Sea Altar (`kidul_altar`) where the player inscribes `jawa_ka` (*Ombak*) and receives the Queen's blessing (`kain_hijau`), and the south exit to `gk_mulut` behind a kabut that lifts when MQ4 is done.

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
#_____________________B_____________C______________________#
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
#_________________________M________________________________#
#____________________________A_____________________________#
#__________________________________________________________#
#_______~~~~____________________________________~~~~_______#
#_______~~~~____________________________________~~~~_______#
#___________________________m______________________________#
############################KK##############################
############################XX##############################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `N` | exit to sk_karang (north edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_karang", spawn_id:"from_sk_keraton"}` | floor | 2 |
| `n` | spawn, arrival from sk_karang | `res://entities/world/spawn.tscn` | `{id:"from_sk_karang"}` | floor | 1 |
| `l` | spawn, landing of drop D1 from sk_tebing | `res://entities/world/spawn.tscn` | `{id:"from_sk_tebing"}` | floor | 1 |
| `W` | exit to sk_pantai (west edge, opens sc:sk_gerbang in sk_pantai, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_pantai", spawn_id:"from_sk_keraton"}` | floor | 2 |
| `w` | spawn, arrival from sk_pantai | `res://entities/world/spawn.tscn` | `{id:"from_sk_pantai"}` | floor | 1 |
| `E` | encounter kidul_trial (Trial of the Waves, outer court; 4.21: **three setpiece waves**, the ring pauses 20 s after waves 1 and 2 so the sign clues can be read) | `res://entities/world/encounter.tscn` | `{area_id:"kidul_trial", size:Vector2i(21,11), waves:[[[res://entities/enemies/lampor.tscn, Vector2i(-5,-2)], [res://entities/enemies/lampor.tscn, Vector2i(-3,2)], [res://entities/enemies/lampor.tscn, Vector2i(3,-2)], [res://entities/enemies/lampor.tscn, Vector2i(5,2)]], [[res://entities/enemies/ula_segara.tscn, Vector2i(-6,0)], [res://entities/enemies/ula_segara.tscn, Vector2i(6,0)], [res://entities/enemies/lampor.tscn, Vector2i(0,-3)]], [[res://entities/enemies/bajul_putih.tscn, Vector2i(6,0)], [res://entities/enemies/lampor.tscn, Vector2i(-4,-2)], [res://entities/enemies/lampor.tscn, Vector2i(-4,2)]]]}` | floor | 1 |
| `M` | NPC Semar at petilasan `kidul_2` (4.20 entry L, `"quiet": true`; shared NPC) | `res://entities/npc/npc.tscn` | `{npc_id:"semar", cond:"step:mq4=19"}` | floor | 1 |
| `P` | petilasan 2 (inner pendopo; 4.20) | `res://entities/petilasan/petilasan.tscn` | `{id:"kidul_2"}` | floor | 1 |
| `x` | codex spot, Kanjeng Ratu Kidul | `res://entities/world/pickup.tscn` | `{codex_id:"nyi_roro_kidul"}` | floor | 1 |
| `A` | Sea Altar of the Southern Sanctuary (4.22, inscribe jawa_ka; the altar entry waits on `step:mq4=21`) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_altar"}` | floor | 1 |
| `X` | exit to gk_pelataran (south edge, 2 tiles, behind the kabut) | `res://entities/world/exit.tscn` | `{target_zone:"gk_pelataran", spawn_id:"from_sk_keraton"}` | floor | 2 |
| `m` | spawn, arrival from gk_pelataran | `res://entities/world/spawn.tscn` | `{id:"from_gk_pelataran"}` | floor | 1 |
| `K` | kabut to Gua Kala, lifts when MQ4 is done (`quest:mq4=done`, set with step 4.22, so flag `mq4_9`; one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq4_9"}` | floor | 2 |
| `B` | clue, a sign that rises from the shallows after wave 1: the water says names back (4.21 `clue` piece; journal note only, ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"trial_sign_1"}` | floor | 1 |
| `C` | clue, a second sign after wave 2 (4.21 `clue` piece; journal note only, ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"trial_sign_2"}` | floor | 1 |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| trial ring | (19,4)-(39,14) 21x11 | The three setpiece waves and the sign clues | E `kidul_trial` (29,9), clues `B` (22,13), `C` (36,13) | 4.21 |
| pendopo | (20,24)-(36,28) | Semar at `kidul_2`, the Sea Altar | `M` (26,26), `P` (24,25), `A` (29,27) | 4.20, 4.22 |

## Area 5: sk_nelayan
Scale: 1

- Size: 150 x 68 tiles = 5 x 4 screens (30 x 17 each), drawn at Scale 1 (a town, Phase 6c; it was 60 x 34). 3 enterable rooms (see Rooms), about 55 `[` houses and rooftops, 12 fenced drying-rack and net yards (`'` beds), a sand beach (y53-57) with rocks, the sea (`~`, y58-66), a boat-landing plaza (62-90, 34-52) and a jetty of path (75-77, 53-63, T-head 68-84, 62-64) as the landmark. A second short jetty stands at (125-126, 54-62).
- Look: Kampung Nelayan, stilt-house fishing village with drying racks, net-mending yards, and a cove path toward the mangrove.
- Purpose: MQ4 4.9–4.10 (beat `song_hook`, Mbah Wiryo `J`, `kidul_sari` `S`), SQ-K2 giver (`k2_fisher`), SQ-C3 fragment 3 (`c3_shore_net` opening `sq_c3_ranga`), and chest `kidul_chest_nelayan`. Links to `sk_pantai` and `sk_bakau`.

### Map
```
######################################################################################################################################################
#...............[[[[[[[[b[[[[[[.......,,,.[[[[[[[[[[bbbbbbbbbbb[[[[[[[.....,,,.[[[[[[.........................,,,.[[[[[[bbb[[[[[[[[..................#
#...############[[[[[[[[b[[[[[[.......,,,.[[[[[[[[[[bbbbbbbbbbb[[[[[[[.....,,,.[[[[[[....b....................,,,.[[[[[[bbb[[[[[[[[..................#
#...#__________#[[[[[[[[b[[[[[[..bb...,,,.[[[[[[[[[[bbb[[[[[[[[[[[[[[[.....,,,.[[[[[[......[[[[[[[[[..........,,,.[[[[[[bbb[[[[[[[[.......[[[[[[[[...#
#...#__________#...[[[[[[[[......bb.r.,,,...[[[[[[[[[bb[[[[[[[[bb[[[[[[[[[.,,,.............[[[[[[[[[..[[[[[[[.,,,...[[[[[[[[[.............[[[[[[[[...#
#...#____J_____#.r.[[[[[[[[...........,,,...[[[[[[[[[bb[[[[[[[[bb[[[[[[[[[.,,,.b.[[[[[[[[..[[[[[[[[[..[[[[[[[.,,,...[[[[[[[[[...[[[[[[[[..[[[[[[[[...#
#...#__________#...[[[[[[[[..[[[[[[[[.,,,...[[[[[[[[[bb[[[[[[[[bb[[[[[[[[[.,,,...[[[[[[[[..[[[[[[[[[..[[[[[[[.,,,...[[[[[[[[[...[[[[[[[[..[[[[[[[[...#
#...#__________#...[[[[[[[[..[[[[[[[[.,,,...[[[[[[[[[bb[[[[[[[[bb[[[[[[[[[.,,,...[[[[[[[[..[[[[[[[[[..[[[[[[[.,,,...[[[[[[[[[...[[[[[[[[..[[[[[[[[...#
#...#__________#...[[[[[[[[..[[[[[[[[.,,,...[[[[[[[[[bb[[[[[[[[bb[[[[[[[[[.,,,...[[[[[[[[..[[[[[[[[[..[[[[[[[.,,,...[[[[[[[[[...[[[[[[[[..[[[[[[[[...#
#...#####,,#####..-........-.[[[[[[[[.,,,..-.........--........--.........-,,,..-........--.........--.......-,,,..-.........-.-........--........-..#
#..-............-.-''''....--........-,,,..-''''.....--''''..b.--''''.....-,,,..-''''....--''''.....--''''...-,,,..-''''..r..-.-''''....--''''....-..#
#..-............-.-........--''''....-,,,..-.........--........--.........-,,,..-........--.........--.......-,,,..-.........-.-........--........-..#
#..------..------.----..--------..----,,,..----..---------..--------..-----,,,..----..--------..--------..----,,,..----..-----.----..--------..----..#
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#
#..----..----.----..----------..-----.,,,..----..----.----..---------..----,,,..-----..-----------..------....,,,..----..---------..--------..-----..#
#..-''''....-.-''''.....--''''......-.,,,..-''''....-.-''''.....--''''....-,,,..-''''......--............-....,,,..-''''.....--''''....--''''.....-..#
#..-........-.-.........--..........-.,,,..-........-.-.........--........-,,,..-..........-.#####,,#####.....,,,..-.........--........--.........-..#
#...[[[[[[[[...[[[[[[[[[..[[[[[[[[[[..,,,...[[[[[[[[...[[[[[[[[[..[[[[[[[[.,,,...[[[[[[[[[[..#__________#.....,,,...[[[[[[[[[..[[[[[[[[..[[[[[[[[[...#
#...[[[[[[[[...[[[[[[[[[..[[[[[[[[[[..,,,...[[[[[[[[...[[[[[[[[[..[[[[[[[[.,,,...[[[[[[[[[[..#___S__s___#.....,,,.b.[[[[[[[[[..[[[[[[[[..[[[[[[[[[...#
#...[[[[[[[[...[[[[[[[[[..[[[[[[[[[[..,,,...[[[[[[[[...[[[[[[[[[..[[[[[[[[.,,,...[[[[[[[[[[..#__________#..r..,,,.b.[[[[[[[[[..[[[[[[[[..[[[[[[[[[...#
#...[[[[[[[[...[[[[[[[[[..[[[[[[[[[[..,,,...[[[[[[[[...[[[[[[[[[..[[[[[[[[.,,,...[[[[[[[[[[..#__________#..r..,,,...[[[[[[[[[..[[[[[[[[..[[[[[[[[[.b.#
#...[[[[[[[[...[[[[[[[[[..............,,,.r.[[[[[[[[...[[[[[[[[[..[[[[[[[[.,,,...............#__________#.....,,,...[[[[[[[[[..[[[[[[[[..[[[[[[[[[.b.#
#.........................b....r......,,,.r.......................[[[[[[[[.,,,.....b.........############.....,,,....................................#
#.b..............r..................r.,,,..................................,,,................................,,,..b.................................#
#...------------.r.--------------...r.,,,..--------------.------------..bb.,,,..------------...--------------.,,,....------------...------------.....#
#.r.-.''''''''.-...-.''''''''''.-.....,,,..-.''''''''''.-.-.''''''''.-..bb.,,,..-.''''''''.-...-.''''''''''.-.,,,....-.''''''''.-...-.''''''''.-.....#
#.r.-..........-...-............-.....,,,..-............-.-..........-.....,,,..-..........-...-............-.,,,.b..-..........-...-..........-.....#
#...------..----...-------..-----.....,,,..-------..-----.------..----.....,,,..------..----...-------..-----.,,,.b..------..----...------..----.....#
#.....................................,,,..................................,,,................................,,,....................................#
Ww,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,yY
W,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Y
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#
#..----..----.----..---------..-----..,,,..----..-------..---.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.---..-------..----,,,.----..---------..----.----..----...#
#..-''''....-.-''''.....--''''.....-..,,,..-''''....--''''bb-.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.-''''bbb--''''bbb-,,,.-''''.....--''''....-.-''''....-...#
#..-........-.-.........--.........-..,,,..-........--bbbbbb-.,--------,,,,,,,,,,,--------,.-bbbbbbb--bbbbbbb-,,,.-.........--........-.-........-...#
#...[[[[[[[[...[[[[[[[[[..[[[[[[[[[...,,,...[[[[[[[[..[[[[[[..,-,,,,,,-,,,,,,,,,,,-,,,,,,-,..[[[[[[[..[[[[[[[.,,,..[[[[[[[[[..[[[[[[[[...[[[[[[[[....#
#...[[[[[[[[.r.[[[[[[[[[..[[[[[[[[[.b.,,,...[[[[[[[[..[[[[[[..,-,'''',-,,,,,,,,,,,-,'''',-,..[[[[[[[..[[[[[[[.,,,..[[[[[[[[[..[[[[[[[[...[[[[[[[[....#
#...[[[[[[[[.r.[[[[[[[[[..[[[[[[[[[.b.,,,...[[[[[[[[..[[[[[[..,-,,,,,,-,,,,,,,,,,,-,,,,,,-,..[[[[[[[..[[[[[[[.,,,..[[[[[[[[[..[[[[[[[[...[[[[[[[[.r..#
#...[[[[[[[[...[[[[[[[[[..[[[[[[[[[...,,,...[[[[[[[[..[[[[[[..,---,,---,,,,,,,,,,,---,,---,..[[[[[[[..[[[[[[[.,,,..[[[[[[[[[..[[[[[[[[...[[[[[[[[....#
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#
#.....................................,,,......##########.....,,,,,,,,,,,,,,,,,,,,,,,,,,,,,...................,,,....................................#
#............................b.b......,,,.b.bb.#________#.....,,,,,,,,,,,,,,,,,,,,,,,,,,,,,................bb.,,,..............b.......r.............#
#...[[[[[[[[...[[[[[[[[[..............,,,...bb.#_c______#.....,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..[[[[[[[[.r....bb.,,,..[[[[[[[[[..............[[[[[[[[...#
#...[[[[[[[[...[[[[[[[[[..[[[[[[[[[...,,,......#________#.bbb.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..[[[[[[[[....r.bb.,,,..[[[[[[[[[...[[[[[[[[...[[[[[[[[...#
#...[[[[[[[[...[[[[[[[[[..[[[[[[[[[...,,,......#______C_#.bbb.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..[[[[[[[[.........,,,..[[[[[[[[[...[[[[[[[[...[[[[[[[[...#
#...[[[[[[[[...[[[[[[[[[..[[[[[[[[[...,,,.bb...#________#.....,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..[[[[[[[[....b....,,,..[[[[[[[[[...[[[[[[[[...[[[[[[[[...#
#...[[[[[[[[...[[[[[[[[[..[[[[[[[[[...,,,.bb...####,,####..b..,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..[[[[[[[[.........,,,..[[[[[[[[[...[[[[[[[[...[[[[[[[[...#
#..-........-.-.........--.........-..,,,.bb..-..........-.b..,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.-........-.r......,,,.-.........-.-........-.-........-..#
#..----..----.----..---------..-----..,,,.....-----..-----....,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.----..----........,,,.----..-----.----..----.----..----..#
#..........................................................r...............,,,.......................................................................#
#.......------,,----..-----,,----.....r.............rr..........rr.........,,,..................------,,----....------,,----.,,...............rr.....#
#.......-b''''''''b-..-b'''''''b-.......rr....rrr........rrr..........rr...,,,..r.......rr..rrr.-b''''''''b-....-b''''''''b-.,,.rr........r..........#
#.......-bbbbbbbbbb-..-bbbbbbbbb-..r..........rrr........rrr...............,,,....F.rr......rrr.-bbbbbbbbbb-....-bbbbbbbbbb-.,,......................#
#.......------------..-----------..........................................,,,..................------------....------------.,,......................#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~,,,~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~,,~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~,,,~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~,,~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~,,,~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~,,~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~,,,~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~,,~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~,,,,,,,,,,,,,,,,,~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~,,~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~,,,,,,,,,,,,,,,,,~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~,,,,,,,,,,,,,,,,,~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
######################################################################################################################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `W` | exit to sk_pantai (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_pantai", spawn_id:"from_sk_nelayan"}` | path | 2 |
| `w` | spawn, arrival from sk_pantai | `res://entities/world/spawn.tscn` | `{id:"from_sk_pantai"}` | path | 1 |
| `Y` | exit to sk_bakau (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_bakau", spawn_id:"from_sk_nelayan"}` | path | 2 |
| `y` | spawn, arrival from sk_bakau | `res://entities/world/spawn.tscn` | `{id:"from_sk_bakau"}` | path | 1 |
| `S` | NPC Sari, young diver (4.10 entries 1 and 2; stays until the K8 memory is done) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_sari", cond:"!flag:mq4_h2"}` | floor | 1 |
| `J` | NPC Mbah Wiryo, first met here (4.10, `talked_to:kidul_jurukunci`, sets `mq4_4`; the instance in `sk_pantai` takes over once `mq4_4` is set) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_jurukunci", cond:"!flag:mq4_4"}` | floor | 1 |
| `s` | NPC Sari after the Trial of the Waves (entry 5, `"quiet": true`, hub `H`) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_sari", cond:"flag:mq4_8"}` | floor | 1 |
| `F` | NPC river-mouth fisher (SQ-K2) | `res://entities/npc/npc.tscn` | `{npc_id:"k2_fisher"}` | grass | 1 |
| `C` | clue, Ranga's carved driftwood token in the shore net (SQ-C3) | `res://entities/world/clue.tscn` | `{clue_id:"c3_shore_net", memory_id:"sq_c3_ranga"}` | floor | 1 |
| `c` | chest: 55 Ilmu | `res://entities/world/chest.tscn` | `{chest_id:"kidul_chest_nelayan", item_id:"ilmu:55"}` | floor | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| west gate | (1,31)-(3,33) | Arrival from sk_pantai on the main lane (y31-33) | exit `W` (0,31..32), spawn `w` (1,31) | none |
| east gate | (146,31)-(148,33) | Arrival from sk_bakau | exit `Y` (149,31..32), spawn `y` (148,31) | none |
| Mbah Wiryo's house | (4,2)-(15,9) 12x8 | Door (9..10,9) | J (9,5) | 4.10 `kidul_jurukunci` |
| Sari's house | (93,18)-(104,24) 12x7 | Door (98..99,18) on the north lane | S (97,20), s (100,20) | 4.10 `kidul_sari` |
| gudang jaring (net store) | (47,44)-(56,50) 10x7 | Near the landing, door (51..52,50) onto the beach yard | chest `c` (49,46), clue `C` (54,48) | SQ-C3 `c3_shore_net` |
| boat landing | plaza (62,34)-(90,52), jetty (75,53)-(77,63) | The landmark: the lane V2 (75-77) runs 57 tiles from the north edge to the jetty | fisher `F` (82,56) on the beach | SQ-K2 `k2_fisher` |

## Area 6: sk_bakau

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Hutan Bakau, flooded coastal mangrove forest and river mouth with tidal beacons and boardwalks.
- Purpose: MQ4 4.13 (`bakau_beacons`, `bakau_pack`), SQ-K2 clue (`k2_scale`), and chest `kidul_chest_bakau`. Links to `sk_nelayan` and `sk_karang`.

### Map
```
############################################################
#..........................................................#
#.....~~~~~~~~................................~~~~~~~~.....#
#.....~~~~~~~~.......rrrrrr...................~~~~~~~~.....#
#.....~~~~~~~~.......r....r...................~~~~~~~~.....#
#....................r..c.r................................#
#....................r....r................................#
#....................rrrrrr................................#
#..........................................................#
#..............rr..........................rr..............#
#..............rr..........................rr..............#
#..........................................................#
#...........................T..............................#
#.........................S................................#
#..........................................................#
#..........................................................#
Ww,,,,,,,,,,,,,,,,,,,,,,,,,,,E,,,,,,,,,,,,,,,,,,,,,,,,,,,,yY
W,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Y
#..........................................................#
#..........................................................#
#..............rr..........................rr..............#
#..............rr..........................rr..............#
#..........................................................#
#......................................K...................#
#.....~~~~~~~~................................~~~~~~~~.....#
#.....~~~~~~~~................................~~~~~~~~.....#
#.....~~~~~~~~................................~~~~~~~~.....#
#..........................................................#
#..........................................................#
#..........................................................#
#.....~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.....#
#.....~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.....#
#..........................................................#
############################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `W` | exit to sk_nelayan (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_nelayan", spawn_id:"from_sk_bakau"}` | path | 2 |
| `w` | spawn, arrival from sk_nelayan | `res://entities/world/spawn.tscn` | `{id:"from_sk_nelayan"}` | path | 1 |
| `Y` | exit to sk_karang (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_karang", spawn_id:"from_sk_bakau"}` | path | 2 |
| `y` | spawn, arrival from sk_karang | `res://entities/world/spawn.tscn` | `{id:"from_sk_karang"}` | path | 1 |
| `S` | NPC Sari, in the mangrove with you (4.13 entry 3, `"quiet": true`) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_sari", cond:"step:mq4=12"}` | grass | 1 |
| `T` | trigger, tidal beacons puzzle (4.13 `puzzle_solved:bakau_beacons`) | `res://entities/world/trigger.tscn` | `{trigger_id:"bakau_beacons", size:Vector2i(4,4)}` | grass | 1 |
| `E` | encounter bakau_pack | `res://entities/world/encounter.tscn` | `{area_id:"bakau_pack", size:Vector2i(14,8), waves:[[[res://entities/enemies/lampor.tscn, Vector2i(-3,0)], [res://entities/enemies/ula_segara.tscn, Vector2i(3,0)]]]}` | path | 1 |
| `K` | clue, white scale in torn net (SQ-K2) | `res://entities/world/clue.tscn` | `{clue_id:"k2_scale", memory_id:"sq_k2_fisher"}` | grass | 1 |
| `c` | chest: 55 Ilmu | `res://entities/world/chest.tscn` | `{chest_id:"kidul_chest_bakau", item_id:"ilmu:55"}` | grass | 1 |

## Area 7: sk_gua

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Gua Karang, echoing sunken sea cavern with bronze bells and abyssal pools.
- Purpose: MQ4 4.15–4.17 (`gua_bell_marks`, `gua_karang_approach`, `lc5_cavern`, `kidul_gua_trial`, Sari at the mouth). Links to `sk_karang` and `sk_tebing`.

### Map
```
############################NN##############################
#___________________________n______________________________#
#__________________________________________________________#
#_______~~~~____________________________________~~~~_______#
#_______~~~~____________________________________~~~~_______#
#__________________________________________________________#
#___________________rr________________rr___________________#
#___________________rr________________rr___________________#
#__________________________________________________________#
#_____________________________F____________________________#
#__________________________________________________________#
#__________________________________________________________#
#______________rr__________________________rr______________#
#______________rr__________________________rr______________#
#__________________________________________________________#
#_____________________________L____________________________#
Ww_________________________________________________________#
W__________________________________________________________#
#___S______________________________________________________#
#__________________________________________________________#
#______________rr__________________________rr______________#
#______________rr___________G______________rr______________#
#__________________________________________________________#
#_____________________________E____________________________#
#__________________________________________________________#
#___________________rr________________rr___________________#
#___________________rr________________rr___________________#
#__________________________________________________________#
#_______~~~~____________________________________~~~~_______#
#_______~~~~____________________________________~~~~_______#
#__________________________________________________________#
#__________________________________________________________#
#__________________________________________________________#
############################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `W` | exit to sk_karang (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_karang", spawn_id:"from_sk_gua"}` | floor | 2 |
| `w` | spawn, arrival from sk_karang | `res://entities/world/spawn.tscn` | `{id:"from_sk_karang"}` | floor | 1 |
| `N` | exit to sk_tebing (north edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_tebing", spawn_id:"from_sk_gua"}` | floor | 2 |
| `n` | spawn, arrival from sk_tebing | `res://entities/world/spawn.tscn` | `{id:"from_sk_tebing"}` | floor | 1 |
| `S` | NPC Sari at the mouth of the cavern (4.17 entry 4, `"quiet": true`) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_sari", cond:"step:mq4=16"}` | floor | 1 |
| `G` | clue, green stains and bronze marks on the cave wall (4.15 `clue` piece; journal note only, ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"gua_bell_marks"}` | floor | 1 |
| `E` | encounter gua_karang_approach (4.15) | `res://entities/world/encounter.tscn` | `{area_id:"gua_karang_approach", size:Vector2i(15,9), waves:[[[res://entities/enemies/lampor.tscn, Vector2i(-4,-2)], [res://entities/enemies/lampor.tscn, Vector2i(4,-2)], [res://entities/enemies/ula_segara.tscn, Vector2i(0,2)]]]}` | floor | 1 |
| `F` | encounter kidul_gua_trial (4.17 Sacred Trial II; inert until Laras opens the tidal gate) | `res://entities/world/encounter.tscn` | `{area_id:"kidul_gua_trial", size:Vector2i(16,9), cond:"flag:laras_key_tidal_gate", waves:[[[res://entities/enemies/ula_segara.tscn, Vector2i(-4,0)], [res://entities/enemies/bajul_putih.tscn, Vector2i(0,0)], [res://entities/enemies/lampor.tscn, Vector2i(4,0)]]]}` | floor | 1 |
| `L` | clue, the sunken bronze bells (4.16, opens chapter `lc5`; replaces the retired `lc5_lontar`) | `res://entities/world/clue.tscn` | `{clue_id:"lc5_cavern", memory_id:"lc5"}` | floor | 1 |
