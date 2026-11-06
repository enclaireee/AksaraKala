# Segara Kidul (region id `segara_kidul`), Act V (after the Interlude at home), v4c

Area graph plus maps. Step 1 of the world design workflow ([AGENTS.md](../../AGENTS.md) section 5). Prefix `sk_`. Sources: [world.md](../world.md) (World structure, link table, Segara Kidul, Checkpoints), [bestiary.md](../bestiary.md) (Zone 4, Encounters, Glyph weaknesses), [quests.md](../quests.md) (MQ4 steps 4.6-4.12, SQ-K1, SQ-K2, 7.5, 9), [story.md](../story.md) (Pacing, Acts). Format follows [tatar_sunda.md](tatar_sunda.md). Scope is **P0**: Segara Kidul is Act V on the main path (story v3.1, 2026-11-06). It is entered after the Interlude "The Quiet House" in Desa Purwa (MQ4 4.1-4.5), when `flag:mq4_2` is set.

Story v4/v4b/v4c additions (2026-11-06; MQ4 4.6-4.12, [quests.md](../quests.md) 4 with its `Play` column): the **arrival slice** (the fishing village mending nets for the sea offering), the **K8 Hunt** (three forgotten verses with three families, clues `song_1` to `song_3`, memory `k8_wiryo_wife`), **K9** (the queen of the south as one retelling, memory `k9_queen_south`), **LC5** (Laras chapter, `lc5`), and the trial's pieces: three setpiece waves with two sign clues between them. Cut names: Mbah Wiryo (npc id `kidul_jurukunci`) is kept; the three families and the net menders are unnamed locals. The memory scenes are in "Memory scenes" below. **Puzzle convention (ASSUMED):** a puzzle is a `trigger.tscn` with `trigger_id` `puzzle_<id>`; the builder attaches the script (tests set `flag:puzzle_<id>`). Miniboss pieces are encounters whose first enemy carries `unique_id` and elite stats (HP x4, Ilmu x4, **TUNE**, the bestiary elite rule). Setpieces are encounters with a scripted frame.

Look: black-sand cliffs, a green sea, a palace beneath the waves. The landmark is the green glow of the sea pavilion. From the first spawn (`from_desa_purwa`) the player sees it low on the southern horizon, past the tidal flat of `sk_pantai`, with a stone sea arch standing offshore. The glow is the pavilion (`sk_keraton`) where the trial is held, so the end of the region is in view at the start. Regional character: **Mbah Wiryo**, the juru kunci of the coast (npc id `kidul_jurukunci`), who says his late wife's name to the sea every dusk because the sea says it back; it mirrors the hero's search for a name the world forgot. Nyi Roro Kidul speaks once, from a distance, after the last wave; she is never fought, never touched, neither friend nor enemy, and no enemy is called her servant. The green association is told as a belief by Mbah Wiryo (wearing green on the south coast is said to attract her), never as a punishment.

Areas: 4, all on the critical path (MQ4 4.6-4.12). Critical path: arrive from `desa_purwa` (or from `tt_pesisir`) -> `sk_pantai` (petilasan `kidul_1`, Mbah Wiryo) -> `sk_karang` (reef) -> `sk_tebing` (cliff path, petilasan `kidul_3` at the cliff shrine, K9 memory and LC5) -> drop D1 onto `sk_keraton` -> Trial of the Waves (3 waves) in the outer court -> Sea Altar (Ombak, Kain Hijau) -> pendopo (`kidul_2`) -> `gk_mulut`. Off the path: the Bajul Putih Tua cove (SQ-K2, inside `sk_karang`), the shortcuts.

**Petilasans: 3 (`kidul_1`, `kidul_3`, `kidul_2`).** world.md rule 7 allows 3 only in the largest region. This region is a full act of 45 minutes with a walk of about 20 minutes, so 3 is allowed here (**ASSUMED**), one per 15-20 minutes of walking (story.md Pacing rule 5). The ids are not in walking order (`kidul_3` is met before `kidul_2`) because quests.md 4.7 fixes `kidul_3` as the cliff shrine.

## Area table
Sizes: screens are 30 x 17 tiles. All four maps are 60 x 34 tiles (2x2). Spawn ids follow `from_<other area id>`.

| id | size (screens, tiles) | look | purpose | contents |
|----|-----------------------|------|---------|----------|
| `sk_pantai` | 2x2, 60x34 | Black-sand beach, dunes in the north, a wide tidal flat in the south, a green sea. A barred coral gate (the gerbang) stands on the south-east shore | Arrival slice: the fishing village mends nets for the sea offering (the net yard `_`), teach encounters, rest, Mbah Wiryo, the three families and their forgotten song verses (K8), turtle nest. MQ4 4.6-4.8 | Spawns `from_desa_purwa` (N), `from_sk_karang` (E), `from_sk_keraton` (gerbang, SE). Petilasan `kidul_1` (centre-west dunes, after the first fights). NPCs `kidul_jurukunci` (Mbah Wiryo), `kidul_nelayan_anak`, `semar` (at `kidul_1`). Encounters `kidul_pantai_1`, `kidul_pantai_2`, `kidul_pantai_3`. Chest `kidul_chest_1` (behind driftwood in the dunes). Turtle nest `kidul_nest` (dunes), water trigger `kidul_tukik_laut` (shore). Shortcut gate `sc:sk_gerbang` (arrival side). Clues `song_1`, `song_2`, `song_3` (K8, 4.7). Quest markers `kidul_1`, `kidul_jurukunci`, `kidul_nelayan_anak`. No exit to `sk_tebing` any more |
| `sk_karang` | 2x2, 60x34 | Reef of dark rock and tide pools under cliffs, a long sandbar, a fishing hut | Cross the reef (MQ4 4.9: fight, sign clue, tide-pool puzzle, second fight, the Ula Segara miniboss at the stair foot), the way to the cliff stair, the Bajul Putih Tua cove | Spawns `from_tt_pesisir` (N), `from_sk_pantai` (W), `from_sk_tebing` (NW stair), `from_sk_keraton` (S causeway, behind kabut `mq4_8`). NPC `kidul_nelayan_tua` (hut, west end). Encounters `kidul_karang_1`, `kidul_karang_2`, `kidul_karang_3`. Elite room `kidul_elite_cove` (SQ-K2): Bajul Putih Tua. Chest `kidul_chest_2` (hidden tide pool between rocks). Reef pieces: `reef_thread` clue, `puzzle_kidul_tide`, `kidul_karang_4`, miniboss `kidul_karang_2`. Quest markers `kidul_karang` (step 4.9), `kidul_nelayan_tua`, `kidul_elite` |
| `sk_tebing` | 2x2, 60x34 | Tall black cliffs, a switchback stair, a sea cave, wind and gulls, a small shrine with a lamp above the drop | The cliff path (MQ4 4.10), the cliff shrine with the K9 memory (4.10) and Laras's chapter LC5 (4.11), the drop onto the keraton. Holds the Segara Kidul end of `sc:ts_sk` | Spawns `from_sk_karang` (S), `from_ts_situ` (the shortcut door, W). Encounters `kidul_tebing_1`, `kidul_tebing_2`. Petilasan `kidul_3` (cliff shrine beside the drop, after the last fight, no fight between it and the drop). Chest `kidul_chest_3` (sea cave, narrow ledge). Shortcut gate `sc:ts_sk` (opens from here). Drop `D1` at the cliff edge (east side). Clues `shrine_tale` (K9) and `lc5_lontar` at the shrine. Quest markers `kidul_tebing` (step 4.10), `kidul_3` (step 4.10) |
| `sk_keraton` | 2x2, 60x34 | Outer court of green-glass stone over the sea (the sea pavilion court), then a calm inner pendopo (open hall). Waves lap at the walls | The Trial of the Waves (4.12: three setpiece waves with two sign clues between them), the Sea Altar (4.12), last rest, codex, the exit to Gua Kala | Spawns `from_sk_karang` (N), `from_sk_tebing` (drop landing, NE), `from_sk_pantai` (W), `from_gk_mulut` (S). Trial `kidul_trial` (outer court centre, 3 waves). Petilasan `kidul_2` (inner pendopo, right before the kabut). Sea Altar `kidul_altar` (pendopo, Ombak and Kain Hijau). Codex spot `kidul_keraton_codex` (pendopo, Nyi Roro Kidul as belief). Shortcut gate `sc:sk_gerbang` (opens from here). Kabut `mq4_9` (= `quest:mq4=done`) to `gk_mulut`. No fight in the pendopo. Clues `trial_sign_1`, `trial_sign_2` (4.12). Quest markers `kidul_trial` (4.12), `kidul_altar` (4.12) |

## Region graph
`==K==` kabut, `--` link, `=sc=` shortcut, `~D~>` drop (one way).
```
  [ts_situ] =sc:ts_sk=  [sk_tebing] (kidul_3)
  (Tatar Sunda)           |       \
                          |        ~D1~> (one way)
                      L4 (link)           \
                          |                v
 [desa_purwa] ==K mq4_2== [sk_pantai] --L1-- [sk_karang] ==K mq4_9== [tt_pesisir]
                          (kidul_1)  ^          |
                                     |     L3 (==K mq4_8==)
                                     |          |
                                     +==sc:sk_gerbang== [sk_keraton] (kidul_2, trial) ==K mq4_9== [gk_mulut]
                                                         ^ D1 lands here
```
Critical path: `desa_purwa` (or `tt_pesisir`) -> `sk_pantai` -> L1 -> `sk_karang` -> L4 -> `sk_tebing` -> D1 -> `sk_keraton` -> `gk_mulut`. The path goes forward in one sweep: east along the shore, north up the cliff, then down to the pavilion. The only long backtrack is for a player who enters from `tt_pesisir`, see below.

### Link table
| id | from area | to area | kind | gate flag | spawn ids |
|----|-----------|---------|------|-----------|-----------|
| X1 | `desa_purwa` (S) | `sk_pantai` | link, kabut | `mq4_2` | `from_desa_purwa` (in `sk_pantai`), `from_sk_pantai` (in `desa_purwa`) |
| X2 | `tt_pesisir` | `sk_karang` | link, kabut | `mq4_9` (back route only, so Act V always starts after the Interlude) | `from_tt_pesisir` (in `sk_karang`), `from_sk_karang` (in `tt_pesisir`) |
| L1 | `sk_pantai` | `sk_karang` | link | none | `from_sk_karang` (in pantai), `from_sk_pantai` (in karang) |
| L4 | `sk_karang` | `sk_tebing` | link (north-west cliff stair) | none | `from_sk_tebing` (in karang), `from_sk_karang` (in tebing). New in v3.1; replaces the old pantai to tebing link (L2, removed) |
| L3 | `sk_karang` | `sk_keraton` | link, kabut (south causeway) | `mq4_8` | `from_sk_keraton` (in karang), `from_sk_karang` (in keraton). Closed until the trial is passed, so the drop is the only way in the first time |
| D1 | `sk_tebing` | `sk_keraton` | drop (one way) | none | `from_sk_tebing` (landing in keraton). No exit leads back up |
| S1 | `sk_keraton` | `sk_pantai` | shortcut `sc:sk_gerbang` | `sc:sk_gerbang` | `from_sk_keraton` (in pantai), `from_sk_pantai` (in keraton) |
| S2 | `sk_tebing` | `ts_situ` | shortcut `sc:ts_sk` | `sc:ts_sk` | `from_ts_situ` (in tebing), `from_sk_tebing` (in ts_situ) |
| X3 | `sk_keraton` | `gk_mulut` | link, kabut | `mq4_9` (`quest:mq4=done`) | `from_sk_keraton` (in gk_mulut), `from_gk_mulut` (in keraton) |

`mq4_2` is set by MQ4 step 4.3 (`talked_to:ibu`, the Interlude talk in Desa Purwa), as quests.md Gating says. `mq4_8` is set when the trial is passed (step 4.12). `mq4_9` is set by step 4.12, the last step, so the kabut flag `mq4_9` and `quest:mq4=done` hold together (the gen_zones kabut takes `flag` only). A kabut is lifted by a story flag, never by a glyph.

**Why L4 and no L2.** In v3.1 the cliff path is required (step 4.10) and follows the reef (4.9). If `sk_tebing` could be entered from `sk_pantai`, the player could climb before crossing the reef and the steps would run out of order, and the route would double back from the cliff to the reef. The pantai to tebing link is removed (its map tiles are now wall), and `sk_karang` gets a north-west stair (link L4) at the spot the player reaches right after the reef. Every step now moves forward: pantai (4.6) -> karang (4.9) -> tebing (4.10) -> keraton (4.12). Map edit sizes are unchanged (60 x 34).

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

Critical path (MQ4, v4c): 4.1-4.5 are in Desa Purwa (Interlude). 4.6 rest at `kidul_1`, the net village, talk to Mbah Wiryo (`kidul_pantai_1`, `kidul_pantai_2` on the way); 4.7 find three verses with three families (K8 clues); 4.8 K8 memory; 4.9 cross the reef (`kidul_karang_3`, `reef_thread`, `puzzle_kidul_tide`, `kidul_karang_4`, miniboss `kidul_karang_2`); 4.10 climb the cliff (`kidul_tebing_1`, `kidul_tebing_2`), rest at `kidul_3`, K9 memory at the shrine; 4.11 LC5 at the shrine; drop; 4.12 the trial (`kidul_trial`, three setpiece waves, two sign clues), the Sea Altar (Ombak, Kain Hijau); then `kidul_2`, the kabut, `gk_mulut`. All four areas are on the path. Nothing on it needs Jawa Ka.

**Return trips (Pacing rule 5).** There is no empty backtrack: the pantai > karang > tebing > keraton sweep is forward only. The two memory trips (K8 on the shore, K9 at the shrine) are scenes, not walks. A player entering from `tt_pesisir` still walks one extra reef crossing (**ASSUMED**; the reef fights stay cleared, the miniboss stays dead, the puzzle stays solved). Later trips use `sc:sk_gerbang`.

Optional: the Bajul Putih Tua cove (side room of `sk_karang`, SQ-K2), the three chests, the turtle nest (SQ-K1), and the shortcuts. These all lie on loop A or loop B, so turning back is never a long walk.

## Encounters
Newest glyph note: Jawa Ka (Ombak) has no enemy weakness ([bestiary.md](../bestiary.md)); it is the clean answer to Ula Segara's water arc and Lampor lines (pushes them back, destroys projectiles). It is earned by the trial and given at the altar, which is the end of the region, and the aftermath has no combat (story.md Pacing rule 6). So **no encounter in this region has Ombak as its clean answer**; its first use is in Gua Kala (`kala_mulut` projectiles, Batara Kala's time-sand). A player who walks back through the reef after the trial can test it on the cleared-and-respawned reef fights (ASSUMED, see the self-check).

Rooms with 4 or more enemies are at least 15 x 9 tiles. Offsets are in the legends. "Position" is a rough place in the area.

| encounter id | area | position | waves (enemy mix) | clean answer |
|--------------|------|----------|-------------------|--------------|
| `kidul_pantai_1` | pantai | north dunes | 3 Lampor (one line) | Ca Burst. Teaches Lampor |
| `kidul_pantai_2` | pantai | shore path | 1 Ula Segara, 2 Lampor | Ka Bolt on the spit wind-up. Teaches Ula Segara |
| `kidul_pantai_3` | pantai | dune lane (10-tile straight lane) | 1 Bajul Putih | Ga Ward on the lunge. Teaches Bajul Putih |
| `kidul_karang_1` | karang | north entry | 3 Lampor | Ca Burst. Teaches Lampor for players who enter here |
| `kidul_karang_2` | karang | stair foot (step 4.9, **miniboss**) | 1 Ula Segara (elite `kidul_reef_elite`, HP x4, **TUNE**), 2 Lampor | Ka Bolt on the spit wind-up |
| `kidul_karang_4` | karang | pool north bank (fight 2 of 4.9) | 3 Lampor (12x7) | Ca Burst |
| `kidul_karang_3` | karang | reef lane on the road (8+ tile lane, moved from the south causeway, fight 1 of 4.9) | 1 Bajul Putih, 2 Lampor | Ga Ward |
| `kidul_elite_cove` | karang | cove (optional, SQ-K2) | 1 Bajul Putih Tua (elite, stays dead) | Own mechanics: elite, no weakness. Ga Ward still works on the lunge (**ASSUMED**) |
| `kidul_tebing_1` | tebing | lower stair landing | 4 Lampor (one line) | Ca Burst |
| `kidul_tebing_2` | tebing | upper ledge (step 4.10) | 1 Ula Segara, 1 Bajul Putih, 2 Lampor | Ka Bolt, Ga Ward |
| `kidul_trial` | keraton | outer court centre (step 4.12, **three setpiece waves** with a pause for the sign clues `trial_sign_1`, `trial_sign_2` between them) | W1: 4 Lampor in two lines. W2: 2 Ula Segara, 1 Lampor. W3: 1 Bajul Putih, 2 Lampor | W1 Ca Burst, W2 Ka Bolt, W3 Ga Ward ([bestiary.md](../bestiary.md) trial of the waves). Waves rise out of the shallows and pools with a 0.5 s warning, in view. The three waves are the deed that earns Ombak |

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
Marker form `{zone: "segara_kidul", id: ...}`. Ids from quests.md are marked (Q). Everything else is **ASSUMED**. Steps 4.1-4.5 take place in Desa Purwa ([desa_purwa.md](desa_purwa.md)) and have no marker here. Step numbers are the MQ4 v4c ones ([quests.md](../quests.md) 4, `Play` column); every piece has a place: `travel` = crossing that area with its fights and one find; `fight` = one encounter; `clue`, `puzzle`, `miniboss`, `setpiece`, `memory`, `chapter` as named. Unnamed clue pieces (`reef_thread`, `trial_sign_1`, `trial_sign_2`, `shrine_tale`, `lc5_lontar`) are **ASSUMED**; `reef_thread` and the two trial signs are journal-note clues with no quest trigger.

| Step | Pieces (Play) | Marker id | Area | Event string |
|------|---------------|-----------|------|--------------|
| 4.6 rest at the petilasan, see the village mend its nets | `travel, fight x2, talk` | `kidul_pantai_1`, `kidul_pantai_2`, `kidul_1` (Q) | `sk_pantai` | `petilasan_activated:kidul_1` (Q); Semar's talk at the petilasan |
| 4.6 speak with Mbah Wiryo | `talk` | `kidul_jurukunci` (Q) | `sk_pantai` | `talked_to:kidul_jurukunci` (Q), sets `mq4_4`. Respect for the coast and the green belief, told as belief |
| 4.7 K8 clues: three verses of the sea song | `travel, clue x3` | `song_1`, `song_2`, `song_3` (Q; `song_3` has `memory_id: k8_wiryo_wife`) | `sk_pantai` (net yard, then the shore) | `all`: `clue_examined:song_1`, `song_2`, `song_3`; sets `mq4_h1` |
| 4.8 K8 memory | `memory, beat` | `k8_wiryo_wife` | `zones/kelir/k8_wiryo_wife.tscn` | `memory_done:k8_wiryo_wife`, sets `mq4_h2` |
| 4.9 cross the reef | `travel, fight, clue, puzzle, fight, miniboss, beat` | `kidul_karang_3`, `reef_thread`, `puzzle_kidul_tide`, `kidul_karang_4`, `kidul_karang_2` | `sk_karang` | `area_cleared:kidul_karang_2` (Q); the beat is Pak Raka's warning at the hut (`kidul_nelayan_tua` entry, ASSUMED) |
| 4.10 climb the cliff, rest at the shrine, K9 | `travel, fight x2, memory, beat` | `kidul_tebing_1`, `kidul_tebing_2`, `kidul_3` (Q), `shrine_tale` (`memory_id: k9_queen_south`) | `sk_tebing` and `zones/kelir/k9_queen_south.tscn` | `area_cleared:kidul_tebing_2`; then `petilasan_activated:kidul_3` (Q, new petilasan in `sk_tebing`); then `memory_done:k9_queen_south`, sets `mq4_h3` |
| 4.11 LC5: the voice on the water | `chapter` | `lc5_lontar` (`memory_id: lc5`, cond `flag:mq4_h3`) | `sk_tebing` (shrine) and `zones/kelir/lc5.tscn` | `memory_done:lc5`, sets `mq4_lc` |
| 4.12 pass the Trial of the Waves | `setpiece, clue, setpiece, clue, setpiece, beat` | `kidul_trial` (Q), `trial_sign_1`, `trial_sign_2` | `sk_keraton` outer court | `area_cleared:kidul_trial` (Q), sets `mq4_8`, lifts the kabut on L3. Beat `kidul_trial` (if `flag:mq4_8`): Nyi Roro Kidul speaks once, from a distance |
| 4.12 receive Ombak and the Kain Hijau | `lesson` | `kidul_altar` | `sk_keraton` pendopo (Sea Altar) | the altar entry (cond: the step that waits on `glyph_learned:jawa_ka`; was `step:mq4=8`, re-index when the QuestData is rebuilt) runs `write:ombak:jawa_ka` and `give:kain_hijau`; `glyph_learned:jawa_ka` (Q), sets `mq4_9`, MQ4 done, lifts the kabut on X3. Beat `kidul` (if `quest:mq4=done`): Semar, Ombak is the one letter the Eclipse can't eat; `start:mq5` |
| SQ-K1 start | `kidul_nelayan_anak` | `sk_pantai` | `talked_to:kidul_nelayan_anak`. Unlock: `zone_entered:segara_kidul` (ASSUMED) |
| SQ-K1 (1) pick up 3 hatchlings, (2) carry them to the surf | pickups `1`-`3` (sparkle), then `T` | `sk_pantai` dunes to shore | `item_picked:tukik_*` x3, then `area_entered:kidul_tukik_laut` once (synced 2026-11-06 to the map's 3 pickups) |
| SQ-K1 turn in | `kidul_nelayan_anak` | `sk_pantai` | `talked_to:kidul_nelayan_anak`. Reward Herb Pouch #4 |
| SQ-K2 start | `kidul_nelayan_tua` | `sk_karang` | `talked_to:kidul_nelayan_tua`. Unlock: `zone_entered:segara_kidul` (ASSUMED) |
| SQ-K2 find the old crocodile | `kidul_elite` | `sk_karang` cove | `area_entered:kidul_elite_cove` |
| SQ-K2 defeat it | `kidul_elite` | `sk_karang` cove | `enemy_killed:bajul_putih_tua` |
| SQ-K2 report back | `kidul_nelayan_tua` | `sk_karang` | `talked_to:kidul_nelayan_tua`. Reward Cakra (P2) or Ilmu L x2 |
| Petilasans | `kidul_1`, `kidul_3`, `kidul_2` | pantai, tebing, keraton | `petilasan_activated:kidul_2` is not a quest step; the other two are steps 4.6 and 4.10 |
| Codex | `kidul_keraton_codex` | `sk_keraton` | `codex:nyi_roro_kidul` (ASSUMED) |

Every step 4.6-4.12 and every beat of quests.md MQ4 has a location (the Interlude beat `quiet_house` and `quiet_house_silent` are in Desa Purwa). Flags read or set in this region: `mq4_2` (read, gates X1), `mq4_9` (also gates X2), `mq4_4`, `mq4_8`, `mq4_9` (set), `sc:sk_gerbang` and `sc:ts_sk` (shortcuts). Retired from the v2 doc: `mq3_8`, `mq4_3`, `mq4_5`, `trial_completed:kidul`, marker `kidul_edge`.

## Memory scenes (Story v4/v4b, [architecture.md](../architecture.md) 9b)
Small own scenes under `zones/kelir/`, not areas (no `## Area n:` heading, so `gen_zones.py` skips them). Built on `memory.gd` with a `Stand` marker and `Checkpoint` markers. Chars are this section's own (`_` lit floor, `#` dark wall, `~` water). Semar narrates 1-2 lines at the start and end; Laras chapters use her own lines. No death or fight is shown. All numbers **TUNE**.

### Memory `k8_wiryo_wife`: calling a name to the sea (K8)

- Scene `res://zones/kelir/k8_wiryo_wife.tscn` (not a Zone: no `gen_zones.py` output; built by hand on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `walk`. Size 30x17.
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

- Scene `res://zones/kelir/k9_queen_south.tscn` (not a Zone: no `gen_zones.py` output; built by hand on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `walk`. Size 60x17 (two screens).
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

- Scene `res://zones/kelir/lc5.tscn` (not a Zone: no `gen_zones.py` output; built by hand on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `chapter`. Size 30x17.
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

## Flow
Arrive at `sk_pantai` (`from_desa_purwa`, green glow on the horizon) > teach encounters (Lampor, Ula Segara) while the net village mends its nets > petilasan `kidul_1` with Semar, Mbah Wiryo (4.6) > the net yard and the shore: three families, three verses (4.7) > the K8 memory (4.8) > east to `sk_karang`: fight on the reef lane, the thread clue, the tide-pool puzzle, a second fight, the Ula Segara miniboss at the stair foot (4.9) > north-west stair (L4) to `sk_tebing` > two cliff fights > cliff shrine `kidul_3`, the K9 memory (4.10), Laras's chapter LC5 (4.11) > slide down D1 > pavilion court, the Trial of the Waves as three setpiece waves with two signs (4.12) > Nyi Roro Kidul speaks once, Ombak and the Kain Hijau at the Sea Altar > pendopo, petilasan `kidul_2` > kabut `mq4_9` gone > `gk_mulut`. Optional: the cove, chests, the turtle nest, `sc:sk_gerbang` and `sc:ts_sk`.

## Self-check ([AGENTS.md](../../AGENTS.md) section 5 Step 2), re-run for v4c 2026-11-06
- [~] POI counts: 0 boss arenas (the trial site replaces it, by design), 1 elite room plus the miniboss on the path (`kidul_karang_2`), 4 NPCs (3-5; the net mender and the three families are unnamed locals), 3 secrets (2-3), 1 codex spot, 11 encounters (6-10; every extra is a piece the step tables count), 3 petilasans (full-act exception, world.md rule 7).
- [x] Petilasan before the trial/exit: `kidul_3` is beside the drop, no fight between it and the pavilion court; the K9 memory and LC5 chapter are scenes, not fights. `kidul_2` is in the calm pendopo before the kabut to Gua Kala.
- [x] First appearances: `kidul_pantai_1` (Lampor alone), `_2` (Ula with known Lampor), `_3` (Bajul alone, optional); the reef lane (`kidul_karang_3`) repeats Bajul with known Lampor; the miniboss reuses the Ula Segara with its known Ka Bolt answer.
- [~] One tank per encounter: yes. Trial W2 has 2 Ula Segara (two shooters), the trial has 3 waves, both fixed by bestiary.md and quests.md 4.12. Named exception.
- [x] Rooms with 4+ enemies: trial ring 21x11, tebing landing and ledge 17x9 and 19x9. Bajul lanes 8-10 tiles (`kidul_pantai_3` 10, `kidul_karang_3` 8+). The new fights have 3 enemies.
- [~] Newest glyph: Ombak has no weakness and arrives at the end of the region; Burst, Bolt and Ward are the trial answers. Accepted.
- [x] Every MQ4 step 4.6-4.12, clue id (`song_1`, `song_2`, `song_3`), memory id (`k8_wiryo_wife`, `k9_queen_south`, `lc5`), beat, SQ-K1 and SQ-K2 step has a marker and area (table above).
- [x] Critical path without Jawa Ka: kabuts `mq4_2`, `mq4_8`, `mq4_9` open on story flags; the puzzle `puzzle_kidul_tide` gates nothing; the trial is passed by melee and dodge as well.
- [x] Rule 1, at least 2 loops: loops A and B (world.md asks for 2).
- [x] Rule 2, at least 2 shortcuts: `sc:sk_gerbang` leads to `sk_pantai` (`kidul_1`); `sc:ts_sk` ends one link from `sunda_2`.
- [x] Rule 3, at least 1 drop: D1.
- [x] Rule 4, optional areas branch off a loop: there are no optional areas now (all 4 are on the path); the cove is on loop A.
- [x] Rule 5, landmark: the green glow of the pavilion shows from the first spawn, and the sea arch stands offshore.
- [x] Rule 6, petilasan right before the trial/exit: `kidul_3` before the trial, `kidul_2` before the kabut.
- [~] Rule 7, petilasans: 3, because the region is a full act (ASSUMED, world.md "3 in the largest"). Rule 8: the critical path visits 4 of 4 areas, gates follow story flags, glyphs are rewards.
- [x] Pacing: arrival slice (the net village) first, then the first fight `kidul_pantai_1` within 5 minutes of the first spawn (Pacing v4b); LC5 at `kidul_3` replaces the Laras beat; turn = the trial and Nyi Roro Kidul's voice; aftermath = Semar's beat at the altar (hands you Gua Kala); the Hunter is felt in the Interlude, not here.
- [x] Pacing rule 5: forward-only sweep, `sc:sk_gerbang` for later trips. Pacing rule 7: every area holds an optional find (pantai: chest, SQ-K1; karang: cove, chest, SQ-K2; tebing: chest, `sc:ts_sk`; keraton: codex).

## ASSUMED
- Gate flags `mq4_2` (from quests.md), `mq4_8`, `mq4_9`, `mq4_4`; shortcut ids `sc:sk_gerbang` (and its position); the loop layout, D1 location and landing; link L4 (karang north-west stair to tebing) and removing the pantai to tebing link; kabut on L3 (`mq4_8`).
- The third petilasan `kidul_3` (quests.md 4.7 names it) and the 3-petilasan exception for a full act.
- All npc ids except `semar`, `kidul_jurukunci` (Q), the encounter ids, chest ids, trigger ids (`kidul_tukik_laut`, `kidul_elite_cove`), `kidul_ratu`, `kidul_altar`, `codex:nyi_roro_kidul`, marker ids `kidul_karang`, `kidul_tebing`, `kidul_3`.
- The trial in the pavilion court (moved from the beach), the pavilion as a peaceful sanctum with fights only in the trial ring, no enemy tied to Nyi Roro Kidul.
- Mbah Wiryo's name and backstory (his late wife's name said to the sea) is story.md canon; the map has him as the NPC `kidul_jurukunci`.
- Semar is at `kidul_1` (story.md: guide at petilasan).
- Elite Bajul Putih Tua can be Warded on the lunge.
- Lampor in the tebing line count: 4 (bestiary says 3-5). Trial W1 4 Lampor, W2 2 Ula Segara + 1 Lampor (as the pantai map had it).
- SQ-K1 and SQ-K2 start and turn-in talks, and the hatchling counting trigger.
- A player entering from `tt_pesisir` walks one extra crossing of the reef.

- v4c (2026-11-06): `kidul_karang_3` and `kidul_karang_2` swapped places (the Bajul lane fight is on the road, the Ula Segara elite is at the stair foot, so the step's `area_cleared:kidul_karang_2` is the last reef fight); the south causeway spot is empty. `kidul_karang_4` and the three setpiece waves are the pieces `fight` and `setpiece` that 4.9 and 4.12 count. Unnamed clue ids: `reef_thread`, `trial_sign_1`, `trial_sign_2`, `shrine_tale`, `lc5_lontar` (journal note only except the memory ones). The net village is the existing `_` yard at (7..26,21..27) of `sk_pantai`; the three families are the three song clues.

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
- Purpose: MQ4 4.9 (cross the reef, `kidul_karang_2`). Entry from `tt_pesisir`, reef encounters (`kidul_karang_1`, `kidul_karang_2`, `kidul_karang_3`), NPC `kidul_nelayan_tua` (SQ-K2), elite room `kidul_elite_cove` (`bajul_putih_tua`), secret chest `kidul_chest_2`, the cliff stair north to `sk_tebing` (the main path, link L4), and the south causeway to `sk_keraton` (kabut `mq4_8`, open only after the Trial, so the way in is the drop).

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
#..............rr...........,,...................rrrrrr....#
#..............rr...........,,.............................#
#...........................,,.............................#
#......A....................,,.............................#
Ww,,,,,,,,,,,,,,,,F,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#
W,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#
#.....................C.....,,.............................#
#...........................,,.............................#
#.........~~~~~~~~..........,,............#############....#
#.........~~~~~~~~..........,,............#...........#....#
#.........~~~~~~~~..........,,............#.....q.....#....#
#...........................,,............#...........#....#
#...........................,,............#####...#####....#
#...........................,,................T............#
#..............rr...........,,.............................#
#..............rr...........,,.............................#
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
| `K` | kabut on the causeway to the keraton, lifts when the Trial of the Waves is passed (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq4_8"}` | path | 2 |
| `U` | exit to sk_tebing (north edge, west of centre, 2 tiles; main path, L4) | `res://entities/world/exit.tscn` | `{target_zone:"sk_tebing", spawn_id:"from_sk_karang"}` | path | 2 |
| `u` | spawn, arrival from sk_tebing | `res://entities/world/spawn.tscn` | `{id:"from_sk_tebing"}` | path | 1 |
| `A` | NPC Pak Raka, old fisherman (SQ-K2) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_nelayan_tua"}` | grass | 1 |
| `E` | encounter kidul_karang_1 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_karang_1", size:Vector2i(17,9), waves:[[[res://entities/enemies/lampor.tscn, Vector2i(4,-2)], [res://entities/enemies/lampor.tscn, Vector2i(5,0)], [res://entities/enemies/lampor.tscn, Vector2i(4,2)]]]}` | grass | 1 |
| `F` | encounter kidul_karang_3 (4.9, fight 1: the reef lane on the road; moved here from the south causeway, so every reef fight is on the way to the stair) | `res://entities/world/encounter.tscn` | `{area_id:"kidul_karang_3", size:Vector2i(19,9), waves:[[[res://entities/enemies/bajul_putih.tscn, Vector2i(6,0)], [res://entities/enemies/lampor.tscn, Vector2i(-4,-2)], [res://entities/enemies/lampor.tscn, Vector2i(-4,2)]]]}` | path | 1 |
| `G` | encounter kidul_karang_2 (**miniboss**, 4.9: an elite Ula Segara `kidul_reef_elite` with 2 Lampor at the foot of the north-west stair; the step completes here) | `res://entities/world/encounter.tscn` | `{area_id:"kidul_karang_2", size:Vector2i(12,6), waves:[[[res://entities/enemies/ula_segara.tscn, Vector2i(4,0)], [res://entities/enemies/lampor.tscn, Vector2i(-3,-1)], [res://entities/enemies/lampor.tscn, Vector2i(-3,1)]]]}` | grass | 1 |
| `T` | trigger, SQ-K2 cove entrance | `res://entities/world/trigger.tscn` | `{trigger_id:"kidul_elite_cove", size:Vector2i(7,7)}` | grass | 1 |
| `q` | elite Bajul Putih Tua (SQ-K2) | `res://entities/enemies/bajul_putih_tua.tscn` | `{}` | grass | 1 |
| `c` | chest: 380 Ilmu (hidden tide pool) | `res://entities/world/chest.tscn` | `{chest_id:"kidul_chest_2", item_id:"ilmu:380"}` | grass | 1 |
| `B` | encounter kidul_karang_4 (4.9, fight 2, north bank of the tide pool) | `res://entities/world/encounter.tscn` | `{area_id:"kidul_karang_4", size:Vector2i(12,7), waves:[[[res://entities/enemies/lampor.tscn, Vector2i(-3,-1)], [res://entities/enemies/lampor.tscn, Vector2i(0,2)], [res://entities/enemies/lampor.tscn, Vector2i(3,-1)]]]}` | grass | 1 |
| `C` | clue, a green thread tied to a rock on the sandbar: Laras's trail (4.9 `clue` piece; journal note only, ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"reef_thread"}` | grass | 1 |
| `D` | trigger, puzzle `puzzle_kidul_tide` (4.9: move the water, turn the three sluice stones so the tide pool drains and the sandbar to the stair shows; sets `flag:puzzle_kidul_tide`, no gate) | `res://entities/world/trigger.tscn` | `{trigger_id:"puzzle_kidul_tide", size:Vector2i(8,4)}` | grass | 1 |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| reef crossing (4.9) | road row 16..17, pool (6,7)-(13,9), stair foot (12,1)-(15,5) | Fight 1 `F` (18,16), clue `C` (22,18), puzzle `D` (10,11), fight 2 `B` (20,9), miniboss `G` (14,3), then the stair `U` | 4.9 all pieces |
## Area 2: sk_pantai

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Black-sand dunes in the north, a wide wet tidal flat in the south, green southern surf, and the barred coral gate (`sc:sk_gerbang`) on the south-east shore.
- Purpose: MQ4 4.6 (rest at `kidul_1`, speak with Mbah Wiryo). Petilasan `kidul_1`, NPCs `kidul_jurukunci` (Mbah Wiryo) and `kidul_nelayan_anak` (SQ-K1), teach encounters (`kidul_pantai_1`, `kidul_pantai_2`, `kidul_pantai_3`), north exit to `desa_purwa`, east exit to `sk_karang`, shortcut gate `sc:sk_gerbang` to `sk_keraton`. The Trial of the Waves moved to `sk_keraton`; the tidal flat is now shore and landmark only.

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
#......___A________________.,,........................######
#......_______H____________.,,.............................#
#......____________________.,,.............................#
#......__________B_________.,,.............................#
#......____________________.,,.............................#
#...........................,,............T................#
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
| `J` | NPC Mbah Wiryo, juru kunci of the Southern Shore (regional character) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_jurukunci"}` | grass | 1 |
| `C` | NPC Damar, fisher child (SQ-K1) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_nelayan_anak"}` | grass | 1 |
| `1` | pickup, stranded hatchling 1 (SQ-K1) | `res://entities/world/pickup.tscn` | `{item_id:"tukik_1"}` | grass | 1 |
| `2` | pickup, stranded hatchling 2 (SQ-K1) | `res://entities/world/pickup.tscn` | `{item_id:"tukik_2"}` | grass | 1 |
| `3` | pickup, stranded hatchling 3 (SQ-K1) | `res://entities/world/pickup.tscn` | `{item_id:"tukik_3"}` | grass | 1 |
| `T` | trigger, surf release spot (SQ-K1) | `res://entities/world/trigger.tscn` | `{trigger_id:"kidul_tukik_laut", size:Vector2i(7,5)}` | grass | 1 |
| `E` | encounter kidul_pantai_1 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_pantai_1", size:Vector2i(17,9), waves:[[[res://entities/enemies/lampor.tscn, Vector2i(4,-2)], [res://entities/enemies/lampor.tscn, Vector2i(5,0)], [res://entities/enemies/lampor.tscn, Vector2i(4,2)]]]}` | grass | 1 |
| `F` | encounter kidul_pantai_2 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_pantai_2", size:Vector2i(17,9), waves:[[[res://entities/enemies/ula_segara.tscn, Vector2i(6,0)], [res://entities/enemies/lampor.tscn, Vector2i(3,-2)], [res://entities/enemies/lampor.tscn, Vector2i(3,2)]]]}` | path | 1 |
| `G` | encounter kidul_pantai_3 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_pantai_3", size:Vector2i(17,9), waves:[[[res://entities/enemies/bajul_putih.tscn, Vector2i(6,0)]]]}` | grass | 1 |
| `c` | chest: 380 Ilmu (behind driftwood) | `res://entities/world/chest.tscn` | `{chest_id:"kidul_chest_1", item_id:"ilmu:380"}` | grass | 1 |
| `A` | clue, the first forgotten verse, with the net-mending family at the west end of the net yard (4.7 K8, 1 of 3) | `res://entities/world/clue.tscn` | `{clue_id:"song_1"}` | floor | 1 |
| `B` | clue, the second verse, with the family drying the sea-offering baskets (4.7 K8, 2 of 3) | `res://entities/world/clue.tscn` | `{clue_id:"song_2"}` | floor | 1 |
| `D` | clue, the third verse, with Mbah Wiryo's own family on the shore rock where he calls his wife's name at dusk (4.7 K8, 3 of 3; opens memory `k8_wiryo_wife`) | `res://entities/world/clue.tscn` | `{clue_id:"song_3", memory_id:"k8_wiryo_wife"}` | grass | 1 |
| `H` | NPC net mender (arrival slice, flavor: the village is mending nets for the sea offering but nobody remembers the songs; unnamed) | `res://entities/npc/npc.tscn` | `{npc_id:"nelayan_jala"}` | floor | 1 |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| net yard (the village) | (7,21)-(26,27) 20x7 | Arrival slice: the fishing village mends nets for the sea offering | clue `A` song_1 (10,23), clue `B` song_2 (17,26), net mender `H` (14,24) | 4.6 view, 4.7 |
| shore rock | (28,28)-(34,29) | Mbah Wiryo's family, dusk calling place | clue `D` song_3 (31,29) | 4.7, opens K8 |
## Area 3: sk_tebing

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: High black sea cliffs, switchback stone stairs, wind-carved sea cave in the north-east, a small cliff shrine with a lamp above the drop, and a cliff-edge slide dropping onto `sk_keraton`.
- Purpose: MQ4 4.10 (climb the cliff path, rest at the cliff shrine `kidul_3`, K9 memory, LC5 chapter). On the main path, entered from `sk_karang` (south edge, link L4). Also holds the `sc:ts_sk` cliff shortcut into Tatar Sunda (`ts_situ`), two cliff encounters (`kidul_tebing_1`, `kidul_tebing_2`), secret chest `kidul_chest_3`, petilasan `kidul_3` (beside the drop, after the last fight) and the one-way drop `D` to `sk_keraton`. There is no link to `sk_pantai` any more.

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
#..........................,,........................B.....#
#..........................,,..............................#
#..........................,,..........................P...D
#..........................,,..............................D
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
#..........................s,..............................#
###########################SS###############################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `S` | exit to sk_karang (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_karang", spawn_id:"from_sk_tebing"}` | path | 2 |
| `s` | spawn, arrival from sk_karang | `res://entities/world/spawn.tscn` | `{id:"from_sk_karang"}` | path | 1 |
| `P` | petilasan 3, the cliff shrine (K9 memory and LC5 chapter) | `res://entities/petilasan/petilasan.tscn` | `{id:"kidul_3"}` | path | 1 |
| `W` | exit to ts_situ (west edge, opens sc:ts_sk in ts_situ, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_situ", spawn_id:"from_sk_tebing"}` | path | 2 |
| `w` | spawn, arrival from ts_situ | `res://entities/world/spawn.tscn` | `{id:"from_ts_situ"}` | path | 1 |
| `D` | exit, one-way drop D1 to sk_keraton (east cliff edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_keraton", spawn_id:"from_sk_tebing"}` | path | 2 |
| `E` | encounter kidul_tebing_1 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_tebing_1", size:Vector2i(17,9), waves:[[[res://entities/enemies/lampor.tscn, Vector2i(3,-3)], [res://entities/enemies/lampor.tscn, Vector2i(4,-1)], [res://entities/enemies/lampor.tscn, Vector2i(4,1)], [res://entities/enemies/lampor.tscn, Vector2i(3,3)]]]}` | path | 1 |
| `F` | encounter kidul_tebing_2 | `res://entities/world/encounter.tscn` | `{area_id:"kidul_tebing_2", size:Vector2i(19,9), waves:[[[res://entities/enemies/ula_segara.tscn, Vector2i(7,0)], [res://entities/enemies/bajul_putih.tscn, Vector2i(4,0)], [res://entities/enemies/lampor.tscn, Vector2i(2,-2)], [res://entities/enemies/lampor.tscn, Vector2i(2,2)]]]}` | grass | 1 |
| `c` | chest: 380 Ilmu (sea cave) | `res://entities/world/chest.tscn` | `{chest_id:"kidul_chest_3", item_id:"ilmu:380"}` | grass | 1 |
| `A` | clue, the shrine's carved tale and lamp, Ki Sumarto's version (4.10; opens memory `k9_queen_south`; ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"shrine_tale", memory_id:"k9_queen_south"}` | grass | 1 |
| `B` | clue, Laras's lontar fragment at the shrine (4.11, opens chapter `lc5`; ASSUMED id, cond `flag:mq4_h3`) | `res://entities/world/clue.tscn` | `{clue_id:"lc5_lontar", memory_id:"lc5", cond:"flag:mq4_h3"}` | grass | 1 |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| cliff shrine | (50,12)-(58,20) | Petilasan `kidul_3`, the shrine tale and Laras's fragment beside it, then the drop `D` | clues `A` shrine_tale (53,18), `B` lc5_lontar (53,14) | 4.10 memory, 4.11 chapter |
## Area 4: sk_keraton

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Outer causeway and court of green-glass stone over the Southern Sea, leading south into a tranquil inner pendopo where waves lap softly against carved pillars.
- Purpose: MQ4 4.12. The Trial of the Waves (`kidul_trial`, 3 waves) in the outer court, drop landing from `sk_tebing`, west coral gate exit to `sk_pantai` (opens `sc:sk_gerbang`), inner pendopo with petilasan `kidul_2`, codex `nyi_roro_kidul`, the Sea Altar (`kidul_altar`) where the player inscribes `jawa_ka` (*Ombak*) and receives the Queen's blessing (`kain_hijau`), and the south exit to `gk_mulut` behind a kabut that lifts when MQ4 is done.

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
#__________________________________________________________#
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
| `E` | encounter kidul_trial (Trial of the Waves, outer court; 4.12: **three setpiece waves**, the ring pauses 20 s after waves 1 and 2 so the sign clues can be read) | `res://entities/world/encounter.tscn` | `{area_id:"kidul_trial", size:Vector2i(21,11), waves:[[[res://entities/enemies/lampor.tscn, Vector2i(-5,-2)], [res://entities/enemies/lampor.tscn, Vector2i(-3,2)], [res://entities/enemies/lampor.tscn, Vector2i(3,-2)], [res://entities/enemies/lampor.tscn, Vector2i(5,2)]], [[res://entities/enemies/ula_segara.tscn, Vector2i(-6,0)], [res://entities/enemies/ula_segara.tscn, Vector2i(6,0)], [res://entities/enemies/lampor.tscn, Vector2i(0,-3)]], [[res://entities/enemies/bajul_putih.tscn, Vector2i(6,0)], [res://entities/enemies/lampor.tscn, Vector2i(-4,-2)], [res://entities/enemies/lampor.tscn, Vector2i(-4,2)]]]}` | floor | 1 |
| `P` | petilasan 2 (inner pendopo) | `res://entities/petilasan/petilasan.tscn` | `{id:"kidul_2"}` | floor | 1 |
| `x` | codex spot, Kanjeng Ratu Kidul | `res://entities/world/pickup.tscn` | `{codex_id:"nyi_roro_kidul"}` | floor | 1 |
| `A` | Sea Altar of the Southern Sanctuary (inscribe jawa_ka) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_altar"}` | floor | 1 |
| `X` | exit to gk_mulut (south edge, 2 tiles, behind the kabut) | `res://entities/world/exit.tscn` | `{target_zone:"gk_mulut", spawn_id:"from_sk_keraton"}` | floor | 2 |
| `m` | spawn, arrival from gk_mulut | `res://entities/world/spawn.tscn` | `{id:"from_gk_mulut"}` | floor | 1 |
| `K` | kabut to Gua Kala, lifts when MQ4 is done (`quest:mq4=done`, set with step 4.12, so flag `mq4_9`; one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq4_9"}` | floor | 2 |
| `B` | clue, a sign that rises from the shallows after wave 1: the water says names back (4.12 `clue` piece; journal note only, ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"trial_sign_1"}` | floor | 1 |
| `C` | clue, a second sign after wave 2 (4.12 `clue` piece; journal note only, ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"trial_sign_2"}` | floor | 1 |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| trial ring | (19,4)-(39,14) 21x11 | The three setpiece waves and the sign clues | E `kidul_trial` (29,9), clues `B` (22,13), `C` (36,13) | 4.12 |
