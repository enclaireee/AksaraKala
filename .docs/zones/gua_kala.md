# Gua Kala (region id `gua_kala`), the finale (Act VI, Story v5)

Area graph on paper. Step 1 of the world design workflow ([AGENTS.md](../../AGENTS.md) section 5), graph level only: no tile maps until Phase 5. Prefix `gk_`. Sources: [world.md](../world.md) (World structure, link table, Gua Kala, Checkpoints), [bestiary.md](../bestiary.md) (Final: Gua Kala, Encounters, Glyph weaknesses), [quests.md](../quests.md) (MQ5, 7.5, 9), [story.md](../story.md) (Batara Kala). Format follows [tatar_sunda.md](tatar_sunda.md).

Story v4b/v4c additions (2026-11-06; MQ5 5.1-5.9, [quests.md](../quests.md) 4 with its `Play` column): the three letters of her name are held in three **gap memories** of the prologue day, one per letter area: `la` (the tag game, in `gk_mulut`), `ra` (the two cups, in `gk_lupa` after the Abyss fight), `sa` (the written names, at the last petilasan `kala_1`); then K10 (Murwakala), LC6 (Laras's chapter) and K7 (the ruwatan, you are the dalang) at `kala_1`. The pacing pieces get places: two time-ward puzzles in `gk_pasir`, the Abyss miniboss in `gk_lupa`, extra fights. The memory scenes are in "Memory scenes" below. Side stories v4d additions (2026-11-06; [quests.md](../quests.md) 5): the only side content in Gua Kala is the last step of SQ-C3 "The Deserter's Name", the write stone `deserter_stone` at `gk_mulut` (`write:deserter_name:jawa_ra,sunda_nga`, event `name_written:deserter_name`); Act VI stays dense. **Puzzle convention (ASSUMED):** a puzzle is a `trigger.tscn` with `trigger_id` `puzzle_<id>`; the builder attaches the script (tests set `flag:puzzle_<id>`). Miniboss pieces are encounters whose first enemy carries `unique_id` and elite stats (HP x4, Ilmu x4, **TUNE**). Setpieces are scripted frames of the boss encounter.

Look: a dark cavern of wet black rock, hourglass and clock-like motifs carved into the walls, and the forgotten letters floating about, faded and dim. Sand trickles in thin streams from the ceiling in the deeper halls. The landmark is Kala's chamber. From the first area (`gk_mulut`), across a wide chasm, the player sees an enormous hourglass and a round clock-face set in the far wall, glowing faintly. It grows nearer in each area, and its ticking gets louder. Batara Kala is a deity figure and is not killed: he is calmed and turned back (a respectful ruwatan note is in the codex, per story.md). Tone stays warm and a bit cartoonish.

Areas: 4. Critical path: `gk_mulut` -> `gk_pasir` -> (drop) `gk_lupa` -> `gk_ruang_kala`. Gua Kala is Act VI (MQ5) and is entered from the sea pavilion (`sk_keraton`) once `quest:mq4=done`, the moment Ombak is earned. The Desa Purwa gate opens on the same flag, so a player who returns home after Act V can walk in from the village too (**ASSUMED**). Beat `mouth`/`mouth_freed`: Ciung Wanara and Hariang Banga hold the mouth, one king from each bank, and you go in alone. The Hunter does not appear in this act.

**Story v5 pass (2026-11-06, ASSUMED until playtest).** MQ5 is 14 steps (5.1-5.14) over 7 areas: `gk_pelataran`, `gk_mulut`, `gk_pasir`, `gk_hutan`, `gk_lupa`, `gk_jembatan`, `gk_ruang_kala`. The brothers hold `gk_pelataran` (the retired `mouth` and `mouth_freed` beats and the `gk_mulut` spots `c`, `h` and `deserter_mouth` are gone); Ranga (`faceless_deserter`, `choice_freed`), Naganingrum (`choice_tell_ciung`) and Cepot (`c4_done`) stand there by their conds, and the `memorial_stone` object (Choice 6) is there. The three memories run K10 (`mq5_h2`), K7 (`mq5_h1`), LC6 (`mq5_lc`), then the boss. The area table and graph below are the v4c four-area ones for the original areas; the three newer areas are listed in the extra rows.

## Area table
| id | size (screens, tiles) | look | purpose | contents |
|----|-----------------------|------|---------|----------|
| `gk_mulut` | 3x2, 90x34 | The cave mouth. Wet black rock, carved clock gears, drifting faded letters, the chasm with the far hourglass in view | Entry, first rest, landmark view | Spawns `from_desa_purwa` (W, gate `quest:mq4=done`), `from_sk_keraton` (S, a sea-cave passage from the pavilion, gate `quest:mq4=done`), `from_gk_pasir` (link L1), `from_gk_lupa` (shortcut landing). Petilasan `kala_2` (near the entry). Encounters `kala_mulut` and `kala_mulut_2` (5.1). Gap memory letter `letter_la` (east road). Optional chest `kala_chest_0` (rule 7). Shortcut landing `sc:gk_lorong`. NPC variant spot `mouth_freed` (the Deserter, `deserter_mouth`, only when `choice_freed`). Quest markers `kala_mulut` (5.1, 5.2) |
| `gk_pasir` | 3x3, 90x51 | The sand halls. Giant hourglass shapes in the walls, thin sand streams that only look pretty, rocky floors and pillars | The long way in, two fights, a secret | Spawns `from_gk_mulut` (W). Encounters `kala_pasir_1`, `kala_pasir_2`. Time-ward puzzles `puzzle_pasir_ward_w`, `puzzle_pasir_ward_e`, clue `ward_inscription`, beat spot `beat_wards_down` (5.2). Chest `kala_chest_1` (hidden sand cave, gap between pillars). Drop `D1` (high gallery, sand-slide) onto `gk_lupa`. Quest marker none |
| `gk_lupa` | 2x3, 60x51 | The hall of faded letters. Aksara float like dim motes: Sunda, Jawa, forgotten scripts. Shelves of stone tablets | Rest before the boss, codex, the shortcut, the boss door | Spawns `from_gk_pasir` (drop landing, N), `from_gk_ruang_kala` (S door). Encounters `kala_lupa_1` (fight) and `kala_lupa` (**miniboss**) (5.3). Gap memory letter `letter_ra` (5.3). Chest `kala_chest_2` (behind tablets). Petilasan `kala_1` (south end, 10 tiles from the door, no fight between). NPC `semar` at `kala_1`. Codex spot `kala_aksara_pudar`. Shortcut gate `sc:gk_lorong` (opens from here). Quest markers `kala_1`, `kala_boss` (door) |
| `gk_pelataran` | 2x2, 60x34 | Pelataran Waktu, the black-stone forecourt with ancestral pillars | First area of Act VI (5.1-5.2), the allies, the memorial stone, the siege | Spawns `from_gk_mulut` (N), `from_gk_pasir` (E). Encounter `kala_pelataran_siege`. NPCs `ciung_wanara`, `hariang_banga`, `faceless_deserter`, `naganingrum`, `cepot`, `memorial_stone`, `deserter_stone`. Petilasan `kala_0` |
| `gk_hutan` | 2x2, 60x34 | Hutan Lupa, a petrified forest of name-trees and stone chimes | 5.6: fight, name-chimes puzzle, chest | Spawns `from_gk_pasir` (W), `from_gk_lupa` (S). Encounter `kala_hutan_echoes`, puzzle `whisper_tree_1`-`_3` (props), clue `name_trees`, chest `kala_chest_hutan` |
| `gk_jembatan` | 2x2, 60x34 | Jembatan Bayang, the causeway over the chasm of eaten time | 5.8: the echoes of fallen legends | Spawns `from_gk_lupa` (W). Encounter `kala_jembatan_echoes`, clue `bridge_echo`, chest `kala_chest_jembatan` |
| `gk_ruang_kala` | 2x2, 60x34 | A round chamber. A clock face on the floor, the great hourglass overhead. Four quadrants, each with a motif of an earlier region (phase 3 uses them all) | Boss arena, Batara Kala | Spawn `from_gk_lupa`. Boss `batara_kala` (marker `kala_boss`), arena gate `A` in the north corridor. After the fight a lit door leads to the epilogue (`kala_exit`, **ASSUMED**). No other enemies |

## Region graph
`--` link, `=sc=` shortcut, `~D~>` drop (one way), `==K==` kabut. Story v5 (2026-11-07): the region is entered at `gk_pelataran`; the v4 entry into `gk_mulut` is retired.
```
 [sk_keraton] ==K mq4_9==+
                         v
 [desa_purwa] ==K mq4_9== [gk_pelataran] --L0-- [gk_mulut] --L1-- [gk_pasir] --L3-- [gk_hutan]
                (kala_0)     |   (kala_2)  ^        |  ~D1~> (one way)     |
                             +-----L4------+--------+       |              L5
                                           |                v              |
                                           +==sc:gk_lorong== [gk_lupa] -----+
                                                             (kala_1)
                                                        L6 /        \ L2
                                               [gk_jembatan]      [gk_ruang_kala]
                                               (out and back)     (Batara Kala)
```
Critical path (v5): `sk_keraton` (or `desa_purwa`) -> `gk_pelataran` (5.1-5.2, rest `kala_0`) -> L0 -> `gk_mulut` (5.3-5.4, rest `kala_2`) -> L1 -> `gk_pasir` (5.5) -> L3 -> `gk_hutan` (5.6) -> L5 -> `gk_lupa` (5.7) -> L6 -> `gk_jembatan` (5.8) and back -> `gk_lupa` (rest `kala_1`, 5.9-5.12) -> L2 -> `gk_ruang_kala` (5.13-5.14). The drop D1 is the fast way down from `gk_pasir` for a return trip.

### Link table
| id | from area | to area | kind | gate flag | spawn ids |
|----|-----------|---------|------|-----------|-----------|
| X1 | `sk_keraton` | `gk_pelataran` | link, kabut | `quest:mq4=done` (kabut flag `mq4_9`, on the `sk_keraton` side) | `from_sk_keraton` (in `gk_pelataran`), `from_gk_pelataran` (in `sk_keraton`). The main entry |
| X0 | `desa_purwa` (N) | `gk_pelataran` | link, kabut | `quest:mq4=done` (kabut flag `mq4_9`, on the village side) | `from_desa_purwa` (in `gk_pelataran`), `from_gk_pelataran` (in `desa_purwa`) |
| L0 | `gk_pelataran` | `gk_mulut` | link | none | `from_gk_mulut` (in pelataran), `from_gk_pelataran` (in mulut) |
| L4 | `gk_pelataran` | `gk_pasir` | link | none | `from_gk_pasir` (in pelataran), `from_gk_pelataran` (in pasir) |
| L1 | `gk_mulut` | `gk_pasir` | link | none | `from_gk_pasir` (in mulut), `from_gk_mulut` (in pasir) |
| L3 | `gk_pasir` | `gk_hutan` | link | none | `from_gk_hutan` (in pasir), `from_gk_pasir` (in hutan) |
| D1 | `gk_pasir` | `gk_lupa` | drop (one way) | none | `from_gk_pasir` (landing in lupa). No exit leads back up |
| L5 | `gk_hutan` | `gk_lupa` | link | none | `from_gk_lupa` (in hutan), `from_gk_hutan` (in lupa) |
| L6 | `gk_lupa` | `gk_jembatan` | link | none | `from_gk_jembatan` (in lupa), `from_gk_lupa` (in jembatan). Out and back: the bridge has no other exit |
| S1 | `gk_lupa` | `gk_mulut` | shortcut `sc:gk_lorong` | `sc:gk_lorong` | `from_gk_lupa` (in mulut), `from_gk_mulut` (in lupa) |
| L2 | `gk_lupa` | `gk_ruang_kala` | link | none (the door is a plain door, closed during the fight) | `from_gk_lupa` (in ruang), `from_gk_ruang_kala` (in lupa) |

### Shortcut table
| id | gate area | opens from | leads back to |
|----|-----------|------------|---------------|
| `sc:gk_lorong` | `gk_lupa` (west wall near the drop landing, a door choked with packed sand) | `gk_lupa` only. From `gk_mulut` it is a sand-blocked arch with no handle | `gk_mulut`, petilasan `kala_2`. After it is open the trip from `kala_2` to the boss is mulut -> lorong -> lupa -> `kala_1`, about a minute |

## Loops, drop, critical path, optional areas
Loop: `gk_mulut` -> L1 -> `gk_pasir` -> D1 (drop) -> `gk_lupa` -> `sc:gk_lorong` -> `gk_mulut`. First trip: the long walk through two fights and a high gallery. Later trips: from `kala_2` through the shortcut to the boss door, skipping the sand halls.

Drop: D1, a sand-slide from the high gallery of `gk_pasir` (hourglass motif: the sand carries the player down). The landing is a few tiles from the `sc:gk_lorong` door, so the way back to `kala_2` opens early.

Critical path (MQ5, v4c): 5.1 enter `gk_mulut`, fight `kala_mulut`, beat `mouth`, fight `kala_mulut_2`, letter `letter_la` and the gap memory `la`; 5.2 `gk_pasir`: `kala_pasir_1`, the inscription clue, the west time-ward puzzle, `kala_pasir_2`, the east time-ward puzzle, the beat at the gallery; drop D1; 5.3 `gk_lupa`: `kala_lupa_1`, the miniboss `kala_lupa`, letter `letter_ra` and the gap memory `ra`; 5.4 rest at `kala_1` (no fight between it and the door), Semar, letter `letter_sa` and the gap memory `sa`; 5.5 K10 (`semar_tale`); 5.6 LC6 (`lc6_lontar`); 5.7 K7 (`semar_kelir`); 5.8 `gk_ruang_kala`, Batara Kala (phase 3 is the setpiece); 5.9 write her name.

**Return trips (Pacing rule 5).** There is no backtrack on the path: mulut > pasir > drop > lupa > ruang is forward only; `sc:gk_lorong` is only for a player who wants `kala_2` again. Rule 7: every area holds an optional find: `gk_mulut` the new chest `kala_chest_0`, `gk_pasir` the sand-cave chest, `gk_lupa` the tablet chest and the codex, `gk_ruang_kala` none (the boss arena).

Optional areas: none. With 4 areas all lie on the loop, and nothing dead-ends, so rule 4 is met by having no optional dead-end area. Optional content is inside areas: `kala_chest_1` in the hidden sand cave and `kala_chest_2` behind the tablets.

## Encounters
Bestiary: about 10 kills in Gua Kala, one mix from each earlier zone at tier 4. All four are from [bestiary.md](../bestiary.md) Encounters and Zone 4. Every enemy is already known by then, so the weakness is usable. Offsets are Phase 5.

| encounter id | area | zone mix reused | enemy mix | clean answer |
|--------------|------|-----------------|-----------|--------------|
| `kala_mulut` | mulut | Tatar Sunda (`sunda_batutulis`) | 2 Faceless, 1 Kuntilanak | Ka Bolt on the shriek |
| `kala_pasir_1` | pasir | Mataram rock thrower | 1 Genderuwo, 2 Pocong | Ka Bolt on the rock, Nga Bind on a hopping Pocong |
| `kala_pasir_2` | pasir | Tanah Timur wisps (dry riverbed with rock cover) | 2 Kemamang | Na Dash-strike |
| `kala_mulut_2` | mulut | (v4c, 5.1 fight 2) | 2 Faceless, 1 Kuntilanak | Ka Bolt on the shriek |
| `kala_lupa_1` | lupa | (v4c, 5.3 fight) | 3 Lampor | Ca Burst; Ombak pushes them back |
| `kala_lupa` | lupa | Tanah Timur Old guard (**miniboss**, 5.3: the Prajurit is the elite `kala_lupa_elite`, HP x4, **TUNE**) (kept; the Segara Kidul W3 mix would also fit now, ASSUMED no change) | 1 Prajurit Terkutuk, 2 Banaspati | Na Dash-strike behind the shield, Ga Ward on the burn. One tank |

Total about 20 kills after v4c (two more fights, the Abyss fight and the miniboss's escorts; the v3.1 target was about 10, **TUNE**). Seven encounters (v3.1: four), no room with 4 or more enemies, so the 15x9 rule is met by default; the Bajul lane in `gk_lupa` is 8+ tiles. No second tank right before the boss (the pre-boss exception is not used). The newest glyph, Ombak, answers Kala's time-sand in the boss fight; its other uses here are on Lampor and projectiles.

## Points of interest
| Thing | Count | Where |
|-------|-------|-------|
| Boss arena | 1 | `gk_ruang_kala` |
| Elite room | 0 (smaller: short finale) | none |
| NPCs | 1 | `semar` at `kala_1` |
| Secrets | 2 | `kala_chest_1`, `kala_chest_2` |
| Codex spot | 1 | `kala_aksara_pudar` in `gk_lupa` (faded letters, Kala, ruwatan note) |
| Petilasans | 2 | `kala_2` (mulut), `kala_1` (lupa, the last one) |

## Quest step locations
Marker form `{zone: "gua_kala", id: ...}`. Ids from quests.md are marked (Q). Everything else is **ASSUMED**. Step numbers are the MQ5 Story v5 ones (14 steps 5.1-5.14, [quests.md](../quests.md) 4, `Play` column; `step:mq5=n` is step 5.(n+1)). The v5 flag order is K10 (`mq5_h2`), K7 (`mq5_h1`), LC6 (`mq5_lc`): `semar_kelir` needs `mq5_h2`, `lc6_lontar` needs `mq5_h1`, the boss needs `mq5_lc`. Unnamed clue ids (`letter_la`, `letter_ra`, `letter_sa`, `ward_inscription`, `eclipse_veil`, `name_trees`, `bridge_echo`, `lc6_lontar`) are **ASSUMED** journal or memory clues.

| Step | Pieces (Play) | Marker id | Area | Event string |
|------|---------------|-----------|------|--------------|
| 5.1 arrival, the siege with the allies | `travel, talk, setpiece, fight x2` | `kala_pelataran_siege` (Q), `ciung_wanara`, `hariang_banga` | `gk_pelataran` (`E`, `C`, `H`; allies `R` Ranga if `choice_freed`, `G` Naganingrum if `choice_tell_ciung`, `T` Cepot if `c4_done`) | `zone_entered:gk_pelataran`; then `area_cleared:kala_pelataran_siege`, sets `mq5_0`. Beat `pelataran` (`step:mq5=0`) |
| 5.2 the memorial stone, Choice 6 | `talk, write, fight, beat` | `memorial_stone` | `gk_pelataran` (`M`; stone `D` is the SQ-C3 write stone) | `flag:mq5_choice6` (`choice_redeem_aria` / `choice_release_aria`); beats `aria_redeem`, `aria_release` |
| 5.3 part the Eclipse, fight into the mouth | `travel, clue, fight x2, miniboss` | `eclipse_veil`, `kala_mulut` (Q), `kala_mulut_2` | `gk_mulut` (`V`, `E`, `A`) | `area_cleared:kala_mulut`, sets `mq5_1b` |
| 5.4 Gap Memory `La` | `memory, puzzle, fight, beat` | `letter_la` (`memory_id: la`, cond `flag:mq5_1b`) | `gk_mulut` (east road `B`) and `zones/kelir/gap.tscn` (`gap_la`) | `memory_done:la`, sets `mq5_la`; beat `la_back` |
| 5.5 the time-wards | `travel, clue, fight x2, puzzle, beat` | `ward_inscription`, `kala_pasir_1`, `kala_pasir_2`, `puzzle_pasir_ward_w`, `puzzle_pasir_ward_e`, `beat_wards_down` | `gk_pasir` | `area_cleared:kala_pasir_1`; then `area_cleared:kala_pasir_2`, sets `mq5_1c` |
| 5.6 the name-trees | `travel, clue, fight, puzzle` | `name_trees`, `kala_hutan_echoes`, `whisper_tree_1`-`_3` (props) | `gk_hutan` (`N`, `E`, `T`) | `area_cleared:kala_hutan_echoes`; then `puzzle_solved:hutan_name_chimes`, sets `mq5_1cb` |
| 5.7 the Abyss, Gap Memory `Ra` | `fight, miniboss, memory, puzzle, beat` | `kala_lupa_1`, `kala_lupa` (Q, miniboss), `letter_ra` (`memory_id: ra`, cond `flag:mq5_1d`) | `gk_lupa` and `zones/kelir/gap.tscn` (`gap_ra`) | `area_cleared:kala_lupa`, sets `mq5_1d`; then `memory_done:ra`, sets `mq5_ra`; beat `ra_back` |
| 5.8 the Shadow Bridge | `travel, clue, setpiece, miniboss` | `bridge_echo`, `kala_jembatan_echoes` | `gk_jembatan` (`B`, `E`) | `area_cleared:kala_jembatan_echoes`, sets `mq5_1e`; beat `bridge` (`step:mq5=7`) |
| 5.9 the last petilasan, Gap Memory `Sa` | `talk, memory, puzzle, beat` | `kala_1` (Q), `semar_kala`, `letter_sa` (`memory_id: sa`, cond `flag:mq5_2`) | `gk_lupa` (south) and `zones/kelir/gap.tscn` (`gap_sa`) | `petilasan_activated:kala_1`, sets `mq5_2`; then `memory_done:sa`, sets `mq5_sa`; beat `sa_back` |
| 5.10 K10 Murwakala | `memory, talk, fight, clue` | `semar_tale` (Q; `memory_id: k10_murwakala`, cond `flag:memory_sa`) | `gk_lupa` (beside `kala_1`) and `zones/kelir/k10_murwakala.tscn` | `memory_done:k10_murwakala`, sets `mq5_h2` (**VERIFY** the Murwakala lakon) |
| 5.11 K7 the dalang's place | `memory, puzzle, beat` | `semar_kelir` (Q; `memory_id: k7_ruwatan`, cond `flag:mq5_h2`) | `gk_lupa` and `zones/kelir/k7_ruwatan.tscn` | `memory_done:k7_ruwatan`, sets `mq5_h1` (casting on) |
| 5.12 LC6, the bottom of the dark | `chapter, puzzle, beat` | `lc6_lontar` (`memory_id: lc6`, cond `flag:mq5_h1`) | `gk_lupa` and `zones/kelir/lc6.tscn` | `memory_done:lc6`, sets `mq5_lc` and `laras_sabotage:kala_eclipse`; no `laras_key` in Act VI |
| 5.13 calm Batara Kala | `boss, setpiece, beat` | `kala_boss` (Q) | `gk_ruang_kala` (boss `B`, cond `flag:mq5_lc`; phase 3 is the ruwatan setpiece; kabut `K` lifts on `mq5_3`) | `boss_defeated:batara_kala`, sets `mq5_3`. Beats `kala_wake`, `kala_p2`, `kala_p3`, then `kala_p3_redeem` or `kala_p3_release` (Choice 6) |
| 5.14 write Laras's name | `write, setpiece, beat` | `kala_boss` (Q) | `gk_ruang_kala` | `name_written:laras`, sets `mq5_4` (epilogue, `from_gua_kala`); beat `write`. The lit door `kala_exit` stays as a walk home after the credits |
| Petilasans | `kala_0` (`gk_pelataran`), `kala_2` (`gk_mulut`), `kala_1` (`gk_lupa`) | | | `petilasan_activated:<id>` (not quest steps except `kala_1`) |
| Codex | `kala_aksara_pudar` | `gk_lupa` | `codex:batara_kala`, `codex:ruwatan` (ASSUMED) |
| SQ-C3 step 4: write the Deserter's name | `deserter_stone` | `gk_pelataran` (`D`; the duplicate stone in `gk_mulut` is removed) | NPC `deserter_stone`, the write stone; runs `write:deserter_name:jawa_ra,sunda_nga`, event `name_written:deserter_name`; its `quiet` entries never complete an MQ5 step; two variants by Choice 2: **freed** (Ranga `R` stands by it) and **handed** (a quiet stone with no one beside it) (**ASSUMED**) |
| Semar line | `semar_kala` | `gk_lupa` | `talked_to:semar_kala` is the step 5.9 main talk (hubs after it); a separate npc_id so it never counts for MQ steps waiting on `talked_to:semar` |

Flags: `mq4_9` / `quest:mq4=done` (read, Ombak earned; gates X0 and X1), `choice_freed`, `choice_tell_ciung`, `choice_judgment`, `c4_done`, `deserter_named` (read), `mq5_0`, `mq5_choice6`, `mq5_1b`, `mq5_la`, `mq5_1c`, `mq5_1cb`, `mq5_1d`, `mq5_ra`, `mq5_1e`, `mq5_2`, `mq5_sa`, `mq5_h2`, `mq5_h1`, `mq5_lc`, `mq5_3`, `mq5_4`, `kala_p2`, `kala_p3`, `sc:gk_lorong`. Post-game: after the credits the player wakes in Desa Purwa with every zone open.

## Memory scenes (Story v4/v4b, [architecture.md](../architecture.md) 9b)
Own scenes under `zones/kelir/`, not areas (no `## Area n:` heading, so `gen_zones.py` skips them). Built on `memory.gd` with a `Stand` marker and `Checkpoint` markers. Chars are this section's own (`_` lit floor, `#` dark wall). Gap memories use one scene `zones/kelir/gap.tscn` plus data `data/memories/gap_<la|ra|sa>.tres` and reuse the prologue-day spots of [desa_purwa.md](desa_purwa.md): the tag route, Ibu's table (house_a, (25,22)-(30,26)) and Laras's lontar spot (the burned stage, (37,3)-(47,9)); the builder copies those tile rects. Every `correct` option must match what script.md and the prologue (quests.md 0.1, 0.2) show; the script owner fixes the texts. All numbers **TUNE**.

### Memory `gap_la`: the tag game (La)

- Scene `res://zones/kelir/gap.tscn` with data `res://data/memories/gap_la.tres` (not a Zone; the one shared gap scene, [architecture.md](../architecture.md) 9b). Kind `gap`. Size 30x17 (a copy of the tag route lane of Desa Purwa).
- Stand-in: the hero on the prologue day (warm kelir look).
- The one action: `interact` at a grey gap opens a 3-option list; a wrong pick flashes grey 0.5 s and reopens (no counter); after 2 wrong picks the right option pulses.
- Goal: Fill 3 gaps; the third right pick calls `finish()` and `memory_done:la`; the letter joins the finale write card.
- Checkpoints: `C` is not needed (no fail state); resume at the clue on quit.

| gap_id | pos | prompt | options (3, key `GAP_<ID>_<n>`; `*` = correct) |
|---|---|---|---|
| `gap_la_cat` | (8,6) | What did she call the stray cat? | Cat name from the prologue* / a near name / another near name |
| `gap_la_tree` | (16,10) | Which tree's leaves shivered at its name? | the banyan* / the kapok / the bamboo |
| `gap_la_end` | (24,4) | Where did the chase end? | the place of `purwa_tag_end`* / the stage / the sanggar |

```
##############################
#____________________________#
#__________________________G_#
#____________________________#
#_______________________3____#
#____________________________#
#_______1____________________#
#____________________________#
#____________________________#
#____________________________#
#_______________2____________#
#____________________________#
#____________________________#
#__S_________________________#
#____________________________#
#____________________________#
##############################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (3,13) | start |
| `1 2 3` | grey gaps | positions in the table below |
| `G` | goal (27,2) | where the memory dissolves into the lamp |

### Memory `gap_ra`: the two cups (Ra)

- Scene `res://zones/kelir/gap.tscn` with data `res://data/memories/gap_ra.tres` (not a Zone; the one shared gap scene, [architecture.md](../architecture.md) 9b). Kind `gap`. Size 30x17 (a copy of house_a, Ibu's table).
- Stand-in: the hero on the prologue day (warm kelir look).
- The one action: `interact` at a grey gap opens a 3-option list; a wrong pick flashes grey 0.5 s and reopens (no counter); after 2 wrong picks the right option pulses.
- Goal: Fill 3 gaps; the third right pick calls `finish()` and `memory_done:ra`; the letter joins the finale write card.
- Checkpoints: `C` is not needed (no fail state); resume at the clue on quit.

| gap_id | pos | prompt | options (3, key `GAP_<ID>_<n>`; `*` = correct) |
|---|---|---|---|
| `gap_ra_cup` | (10,6) | Which cup was hers? | the one the prologue sets for Laras* / the other cup / the spare cup |
| `gap_ra_words` | (16,10) | What did Ibu say as she poured? | "have Laras home before the show"* / two other near lines |
| `gap_ra_seat` | (22,5) | Where did Laras sit? | her seat at the table* / by the door / on the step |

```
##############################
#____________________________#
#__________________________G_#
#____________________________#
#____________________________#
#_____________________3______#
#_________1__________________#
#____________________________#
#____________________________#
#____________________________#
#_______________2____________#
#____________________________#
#____________________________#
#__S_________________________#
#____________________________#
#____________________________#
##############################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (3,13) | start |
| `1 2 3` | grey gaps | positions in the table below |
| `G` | goal (27,2) | where the memory dissolves into the lamp |

### Memory `gap_sa`: the written names (Sa)

- Scene `res://zones/kelir/gap.tscn` with data `res://data/memories/gap_sa.tres` (not a Zone; the one shared gap scene, [architecture.md](../architecture.md) 9b). Kind `gap`. Size 30x17 (a copy of the burned stage, Laras's lontar spot).
- Stand-in: the hero on the prologue day (warm kelir look).
- The one action: `interact` at a grey gap opens a 3-option list; a wrong pick flashes grey 0.5 s and reopens (no counter); after 2 wrong picks the right option pulses.
- Goal: Fill 3 gaps; the third right pick calls `finish()` and `memory_done:sa`; the letter joins the finale write card.
- Checkpoints: `C` is not needed (no fail state); resume at the clue on quit.

| gap_id | pos | prompt | options (3, key `GAP_<ID>_<n>`; `*` = correct) |
|---|---|---|---|
| `gap_sa_first` | (9,5) | Which name did she write first? | yours* / hers / Ibu's |
| `gap_sa_hand` | (15,9) | Which hand held the stylus? | as the prologue shows* / the other / both |
| `gap_sa_slant` | (22,6) | How did her letters lean? | her handwriting from the lontar* / two other slants |

```
##############################
#____________________________#
#__________________________G_#
#____________________________#
#____________________________#
#________1___________________#
#_____________________3______#
#____________________________#
#____________________________#
#______________2_____________#
#____________________________#
#____________________________#
#____________________________#
#__S_________________________#
#____________________________#
#____________________________#
##############################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (3,13) | start |
| `1 2 3` | grey gaps | positions in the table below |
| `G` | goal (27,2) | where the memory dissolves into the lamp |

### Memory `k10_murwakala`: Murwakala (K10)

- Scene `res://zones/kelir/k10_murwakala.tscn` (not a Zone: no `gen_zones.py` output; generated by `gen_memories.py` on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `walk`. Size 30x17.
- Stand-in: young Kala, born hungry (silhouette; **VERIFY** the Murwakala lakon as the ruwatan story).
- The one action: none (walk only).
- Goal: Follow Kala from the feast table `K` through the hall; at each stop Semar the dalang `D` tells why he was hungry and how the dalang's words turned him back; end at `G`. Teaches why the ruwatan works.
- Checkpoints: none (no fail state).

```
##############################
#____________________________#
#_____________D______________#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#_____T_______K_________G____#
#____________________________#
#____________________________#
#____________________________#
#_____________T______________#
#__S_________________________#
#____________________________#
#____________________________#
##############################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (3,13) | start |
| `D` | Semar at the kelir (14,2) | narrator |
| `K` | the feast table (14,8) |  |
| `T` | narration stops | (6,8), (14,12) |
| `G` | goal (24,8) |  |

### Memory `lc6`: who's there? (LC6)

- Scene `res://zones/kelir/lc6.tscn` (not a Zone: no `gen_zones.py` output; generated by `gen_memories.py` on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `chapter`. Size 30x17.
- Stand-in: Laras at the bottom of the dark (`entities/player/stand_in_laras.tscn`), tiny lamp radius.
- The one action: `interact` = write *Ka* on a floor tablet `K`; also freeze a Faceless for 3 s.
- Goal: Cross the dark to the tablet `K` and write *Ka* once more while a Faceless circles; your own voice replies (a line from the hero) and the memory ends. She has forgotten you and still writes.
- Checkpoints: `C` (3,12). Seen = `fail()`, back to `C`, no HP loss.

```
##############################
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#_______h___f_______f_____KG_#
#____________________________#
#____________________________#
#____________________________#
#__C____________h____________#
#__S_________________________#
#____________________________#
#____________________________#
##############################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (3,13) | start |
| `f` | Faceless patrol | 2, row y=8 |
| `h` | hide prop | 2 |
| `K` | floor tablet (26,8) | the *Ka* write card |
| `C` | checkpoint | 1 |
| `G` | goal (27,8) |  |

### Memory `k7_ruwatan`: the ruwatan again (K7)

- Scene `res://zones/kelir/k7_ruwatan.tscn` (not a Zone: no `gen_zones.py` output; generated by `gen_memories.py` on `memory.gd`, [architecture.md](../architecture.md) 9b). Kind `play`. Size 30x17 (the K0 stage, mirrored).
- Stand-in: the dalang at the kelir (hero silhouette); `allow_cast = true`.
- The one action: Draw the shown letter (cast overlay) when its name lights on the kelir.
- Goal: Read six names aloud, alternating Sunda and Jawa letters (`1` to `6`); a wrong or late letter dims the lamp and repeats that name. Teaches that the Ruwatan of Dawn alternates the scripts.
- Checkpoints: `C` not needed; failing a letter repeats it (`fail()` resets that name only). After 3 fails the guide stroke shows.

```
##############################
#____________________________#
#____________________________#
#_____________K______________#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#____________________________#
#_______1__2__3__4__5__6_____#
#____________________________#
#_____________S______________#
#____________________________#
#____________________________#
#____________________________#
##############################
```

| Char | What | Notes |
|------|------|-------|
| `S` | Stand (14,12) | the dalang's place |
| `K` | kelir (14,3) | decor; the lit screen |
| `1-6` | name markers | (8..23,10), 3 tiles apart; odd = Sunda, even = Jawa |

## Flow
Story v5 order: `gk_pelataran` (siege, allies, memorial stone, 5.1-5.2) -> `gk_mulut` (veil, `kala_mulut`, letter La, 5.3-5.4) -> `gk_pasir` (wards, 5.5) -> `gk_hutan` (name-trees, 5.6) -> drop or link to `gk_lupa` (Abyss, letter Ra, 5.7) -> `gk_jembatan` (5.8) -> `gk_lupa` (`kala_1`, Sa, K10, K7, LC6, 5.9-5.12) -> `gk_ruang_kala` (5.13-5.14). The v4c flow below is kept for the original four areas.
Enter `gk_mulut` (the far hourglass in view) > `kala_mulut`, beat `mouth`, `kala_mulut_2`, letter La and the tag game (5.1) > petilasan `kala_2` is optional > `gk_pasir`: `kala_pasir_1`, the inscription, the west ward puzzle, `kala_pasir_2`, the east ward puzzle, the gallery beat (5.2) > sand-slide drop > `gk_lupa`: `kala_lupa_1`, the elite `kala_lupa`, letter Ra and the two cups (5.3) > open `sc:gk_lorong` (short way back) > petilasan `kala_1`, Semar, letter Sa (5.4), K10 (5.5), LC6 (5.6), K7 (5.7) > door > `gk_ruang_kala`, Batara Kala (5.8), write her name (5.9) > the lit door home.

## Self-check ([AGENTS.md](../../AGENTS.md) section 5 Step 2), re-run for v4c 2026-11-06
- [~] POI counts: 1 boss arena, 1 miniboss (`kala_lupa`), 1 NPC (3-5), 3 secrets or finds (`kala_chest_0`, `kala_chest_1`, `kala_chest_2`), 1 codex spot, 7 encounters (6-10), 2 petilasans. The finale keeps few talkers by design.
- [x] Petilasan before the boss, no fight between: `kala_1` is 10 tiles from the door; `kala_lupa` and `kala_lupa_1` are 20+ tiles away in the north; the gap memories, K10, LC6 and K7 are scenes, not fights.
- [x] First appearances: every enemy was met earlier, each encounter has its weakness glyph.
- [x] One tank per encounter (`kala_lupa` has the Prajurit), at most one shooter, single waves.
- [x] Rooms with 4 or more enemies: none (all new fights have 3 enemies). Lanes 8+.
- [x] Newest glyph: Ombak answers time-sand and projectiles; Lampor in `kala_lupa_1` can be pushed back with it.
- [x] Every MQ5 step 5.1-5.9, clue id, memory id (`la`, `ra`, `sa`, `k10_murwakala`, `lc6`, `k7_ruwatan`) and beat has a place.
- [x] Critical path without any one glyph: no kabut inside Gua Kala except the arena exit; puzzles gate nothing.
- [x] Loop or shortcut, drop, landmark, petilasan before the boss: unchanged.
- [x] Pacing rule 5 (forward only) and rule 7 (finds in every area but the arena).

## ASSUMED
- **Story v5 (2026-11-06):** conds follow the v5 step map (see the quest-step table). New ASSUMED clues `eclipse_veil` (`gk_mulut` `V`), `name_trees` (`gk_hutan` `N`), `bridge_echo` (`gk_jembatan` `B`), journal notes only. New ally spots in `gk_pelataran`: `R` Ranga, `G` Naganingrum, `T` Cepot. Removed: `gk_mulut` spots `c`, `h`, `d` (`deserter_mouth`) and the duplicate write stone `D` (the stone is in `gk_pelataran`). The royal vanguard of `choice_judgment` has no spot (it stands on the walls in the beat). `step:mq5=n` is step 5.(n+1).
- Area names `gk_pasir`, `gk_lupa`, `gk_ruang_kala` (only `gk_mulut` is fixed), their sizes, the loop layout, D1 and `sc:gk_lorong`.
- `kala_2` is in `gk_mulut`; `kala_1` in `gk_lupa`.
- Encounter ids, chest ids, `kala_aksara_pudar`, `kala_exit`, codex ids, spawn `from_gua_kala` in Desa Purwa.
- The four mixes (one per earlier zone) and the one-wave rule; 11 kills is "about 10".
- Semar at `kala_1`, with an optional line.
- The lit door after the fight leads to Desa Purwa; it is not a graph edge.

- v4c (2026-11-06): gap-memory letters, `ward_inscription`, `lc6_lontar` and the beat `beat_wards_down` are ASSUMED ids. The boss `B` waits on `flag:mq5_h1` (K7) so the sequence cannot be skipped. Gap `correct` options depend on the prologue text (script owner).

## Open questions
1. VERIFY (ruwatan): the codex note on ruwatan, and the claim that Kala is "turned back", not killed, need sources ([story.md](../story.md) says verified with nuance). Any new culture claim about hourglass or clock motifs for Kala is a design invention, not folklore.
2. Should the arena be bigger than 2x2 for phase 3 "all arenas combined"? Here 60x34 with four quadrant motifs.
3. Segara Kidul is now on the main path, so Lampor, Bajul Putih and Ombak are all known by Act VI. `kala_lupa` keeps the Timur "Old guard" mix (1 Prajurit Terkutuk, 2 Banaspati); swap to the Segara W3 mix? (ASSUMED no.)
4. How does the player return to Desa Purwa after the boss? A lit door (ASSUMED) or a cutscene.
5. Is Semar at `kala_1` wanted, or does story.md want him silent in the finale?

## Decisions (ASSUMED 2026-11-05, updated for v3.1 2026-11-06; resolve open questions 2-5 and the conflicts)
- Entry (v5): link X1 from `sk_keraton` (the main entry, a sea-cave passage in the south wall of `gk_pelataran`, spawn `from_sk_keraton`) and link X0 from `desa_purwa` (the west exit of `gk_pelataran`, spawns `from_desa_purwa` in pelataran and `from_gk_pelataran` in Desa Purwa). Both open on `quest:mq4=done` (kabut flag `mq4_9`). MQ5 requires `mq4_9`; the beat `kidul` starts it (`start:mq5`). The Hunter does not appear in Act VI.
- Arena: stays 2x2 (60x34), quadrant motifs are art only (open question 2).
- `kala_lupa` uses the Timur Old guard mix (open question 3).
- Return: the lit door `kala_exit`, an exit to `desa_purwa` (spawn `from_gua_kala`) that appears after `boss_defeated:batara_kala` (open question 4). Step 5.9 (`name_written:laras`) completes MQ5 and the epilogue plays first; after it the player wakes in Desa Purwa (`from_gua_kala`). The lit door is also a walk home afterwards.
- Semar is at `kala_1` with one optional line, npc id `semar_kala` (open question 5).
- Kala HP 9300 (starting value; Segara Kidul is on the main path, so the old P0 figure 8400 no longer applies). No tier scaling exists, so the reused mixes keep their own stats.

## Doc conflicts found (not fixed)
- v5 (2026-11-06): the link table still routes `sk_keraton` and `desa_purwa` into `gk_mulut`, while step 5.1 is `zone_entered:gk_pelataran` and `gk_pelataran` links only to `gk_mulut` and `gk_pasir`; the player walks mulut -> pelataran for 5.1-5.2 and back for 5.3. Needs a design call (an entry link into `gk_pelataran`, or 5.1 starting at the mouth). The critical-path and self-check paragraphs below are the v4c four-area text.
- Resolved by v3.1: Segara Kidul is P0 and `gk_mulut` has two entries (`sk_keraton`, `desa_purwa`) on `quest:mq4=done`.
- Resolved 2026-11-06 (consistency pass): desa_purwa.md gates its Gua Kala exit on `mq4_9`; bestiary.md calls Ombak P0 and Kala HP 9300.
- The three letters of her name (*huruf nama*: La, Ra, Sa) of quests.md MQ5 have no map object; they are released by the clears (La, Ra) and the petilasan (Sa). Phase 5 may want pickups.
- Deserter at the mouth: `deserter_mouth` is a new npc id (ASSUMED) needing a script.md line and a sprite; quests.md names only the beat `mouth_freed`.
- Quests.md 5.8 `name_written:laras` completes MQ5; the old 5.4 line `zone_entered:desa_purwa` in this doc is replaced.
- bestiary.md gives Kala HP 9300 / 3 phases (the 8400 P0 figure is retired) with no arena size. world.md says 2x2 to 3x3 screens per area. The built boss still has 8400 HP: code follow-up.
- quests.md fixes `kala_1` as "the last petilasan", so a two-petilasan region numbers its first rest `kala_2`.
- The lit door to Desa Purwa (`kala_exit`) is not a link in world.md; quests.md says only that the player wakes in Desa Purwa after the epilogue.
- world.md Points of interest asks 6-10 encounters and 3-5 NPCs per region; bestiary.md fixes about 10 kills for Gua Kala, which gives 4 encounters.

## Area maps (Phase 5)
The 4 sections below follow the format of [tanah_timur.md](tanah_timur.md) (tile chars as in tatar_sunda.md, legend, encounters). Coordinates are (x, y) from the top-left tile (0,0). The whole region is cave: floor is `_`, `#` is cave wall, `r` is rock or pillar. A shortcut gate (2-tile `shortcut.tscn`) sits only in the area behind it, with its pocket (spawn, exit) on the open side; the opener area has a plain exit into that pocket: the `sc:gk_lorong` gate is in gk_mulut (north wall, west end), the plain exit is in gk_lupa. The drop D1 is the `D` exit on the east rim of the gk_pasir gallery; it lands on spawn `from_gk_pasir` in gk_lupa and nothing leads back up. Quest marker `kala_exit` is a trigger node in gk_ruang_kala; the `kala_mulut` and `kala_1`/`kala_boss` markers are not placed here.

## Area 1: gk_mulut

- Size: 90 x 34 tiles = 3 x 2 screens (30 x 17 each).
- Look: Wet black cave mouth, carved clock gears, drifting faded letters, the far hourglass and clock face faint across the dark. A small sand-choked side pocket by the first petilasan.
- Purpose: Second area of Act VI, entered from `gk_pelataran` (Story v5: the region entries from `sk_keraton` and Desa Purwa land in `gk_pelataran`). MQ5 5.3-5.4 (the veil, `kala_mulut`, the first letter, La), first rest `kala_2`, link to gk_pasir, the gate of `sc:gk_lorong` (north wall, west) with its pocket and exit into gk_lupa.

### Map
```
############NN############################################################################
#__________#n_#__________________________________________________________________________#
#__________#__#_____________________________#####________________________________________#
#__________#++#_____________________________#####___________#########____________________#
#___________________#######___C_____________#####___________#########_______________rr___#
#___________________#######_____________________________rr__#########_______________rr___#
#___________________#######_____________rr______________rr__#########____________________#
#___________________#######_____________rr__________________#########____________________#
#_________P_________#######______________________________________________________________#
#___________________________________________________________________________#####________#
#___________________________________________________________________________#####________#
#___________________________________________________________________________#####________#
#_______________________rr__________________________________rr______________#####________#
#_______________________rr__________________________________rr______________#####________#
#_______________rr_______________________________________________________________________#
#_______________rr_______________________________________________________________________#
#_____________________________________________E_______________________A_________________yY
#________________________________________________________________________________________Y
#___________________________________________________________________________________B____#
#________________________________________________________________________________________#
#_________________rr_____________________________________________________________________#
#_________________rr_____________________________________________________________________#
#_______________________________________________________________________________rr_______#
#_______________________________________________________________________________rr_______#
#_______#####_____________________________________________________#########______________#
#_______#####_____________________________________________________#########______________#
#_______#####_________________#########_____________rr____________#########______________#
#_______#####_________________#########_____________rr____________#########______________#
#_______#####_________O_______#########___________________________#########______________#
#_____________________________#########___________________________#########______________#
#_____________________V_______#########__________________________________________________#
#________________________________________________________________________________________#
#___________________s____________________________________________________________________#
####################SS####################################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `S` | exit to gk_pelataran (south-west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_pelataran", spawn_id:"from_gk_mulut"}` | floor | 2 |
| `s` | spawn, arrival from gk_pelataran | `res://entities/world/spawn.tscn` | `{id:"from_gk_pelataran"}` | floor | 1 |
| `Y` | exit to gk_pasir (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_pasir", spawn_id:"from_gk_mulut"}` | floor | 2 |
| `y` | spawn, arrival from gk_pasir | `res://entities/world/spawn.tscn` | `{id:"from_gk_pasir"}` | floor | 1 |
| `N` | exit to gk_lupa (north edge, plain exit from the `sc:gk_lorong` pocket, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_lupa", spawn_id:"from_gk_mulut"}` | floor | 2 |
| `n` | spawn, arrival from gk_lupa (inside the pocket) | `res://entities/world/spawn.tscn` | `{id:"from_gk_lupa"}` | floor | 1 |
| `+` | shortcut gate sc:gk_lorong, sand-choked arch (opens from the north pocket, 2 tiles) | `res://entities/world/shortcut.tscn` | `{id:"sc:gk_lorong", open_side:"n"}` | floor | 2 |
| `P` | petilasan 2 | `res://entities/petilasan/petilasan.tscn` | `{id:"kala_2"}` | floor | 1 |
| `E` | encounter kala_mulut (5.3 `area_cleared:kala_mulut`, sets `mq5_1b`) | `res://entities/world/encounter.tscn` | `{area_id:"kala_mulut", size:Vector2i(20,11), cond:"flag:mq5_choice6,flag:ombak_barrier,!flag:mq5_1b", waves:[[[res://entities/enemies/faceless.tscn, Vector2i(6,-3)], [res://entities/enemies/faceless.tscn, Vector2i(6,3)], [res://entities/enemies/kuntilanak.tscn, Vector2i(8,0)]]]}` | floor | 1 |
| `A` | encounter kala_mulut_2 (5.3, second fight, east road) | `res://entities/world/encounter.tscn` | `{area_id:"kala_mulut_2", size:Vector2i(18,9), cond:"flag:mq5_choice6", waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-4,-2)], [res://entities/enemies/faceless.tscn, Vector2i(-4,2)], [res://entities/enemies/kuntilanak.tscn, Vector2i(4,0)]]]}` | floor | 1 |
| `B` | clue, a faded floating letter *La* (5.4; opens gap memory `la`; cond `flag:mq5_1b`; ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"letter_la", memory_id:"la", cond:"flag:mq5_1b"}` | floor | 1 |
| `C` | chest: 300 Ilmu (north nook, rule 7 optional find, ASSUMED) | `res://entities/world/chest.tscn` | `{chest_id:"kala_chest_0", item_id:"ilmu:300"}` | floor | 1 |
| `V` | clue, the Eclipse veil across the cave mouth; the player draws *Ombak* to part it (5.3 `clue` piece; journal note only; id `eclipse_veil`, hunt `kala`; ASSUMED position by the arrival from `gk_pelataran`) | `res://entities/world/clue.tscn` | `{clue_id:"eclipse_veil", cond:"flag:mq5_choice6"}` | floor | 1 |
| `O` | the Eclipse barrier across the cave mouth; cast Ombak (Jawa Ka) at it (5.3; `flag:ombak_barrier` is set by the cast) | `res://entities/npc/npc.tscn` | `{npc_id:"ombak_barrier"}` | floor | 1 |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `kala_mulut` | `E (46,16)` | 20x11 | W1: Faceless (+6,-3), Faceless (+6,+3), Kuntilanak (+8,+0) | Ka Bolt on the shriek |
| `kala_mulut_2` | `E (70,16)` | 18x9 | W1: Faceless (-4,-2), Faceless (-4,+2), Kuntilanak (+4,0) | Ka Bolt on the shriek |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| east road | (60,12)-(88,20) | Fight 2 and the letter | E `A` (70,16), clue `B` letter_la (84,18) | 5.3, 5.4 |
| veil | (18,28)-(26,32) | The Eclipse veil by the arrival from `gk_pelataran` | clue `V` eclipse_veil (22,30) | 5.3 |
| north nook | (28,2)-(34,6) | Optional chest | `C` (30,4) | rule 7 |
| name stone (v4d) | (5,16)-(7,18) | SQ-C3 step 4: the write stone `deserter_stone` at (6,17), not drawn on the map (**ASSUMED**: a plain NPC spot on floor; `gen_zones.py` reads only the legend). The stone is the only side spot in Gua Kala; it sits 2 tiles from the Deserter spot `d` (4,18), so the freed variant is one scene | NPC `{npc_id:"deserter_stone", cond:"flag:mq5_1"}` (the three clue conds are in the quest step table) | SQ-C3 `name_written:deserter_name` |
## Area 2: gk_pasir

- Size: 90 x 51 tiles = 3 x 3 screens (30 x 17 each).
- Look: Sand halls: giant hourglass shapes in the walls, thin sand streams, rocky pillars, a high gallery in the north-east and a pillar-gapped sand cave in the south.
- Purpose: Two fights (`kala_pasir_1`, `kala_pasir_2`), secret chest `kala_chest_1`, drop D1 from the high gallery to gk_lupa (one way).

### Map
```
##########################################################################################
#___________________________________________________________#____________________________#
#___________________________________________________________#____________________________#
#___________________________________________________________#_____________________rr_____#
#___________________________________________________________#_____rr______________rr_____#
#___________________________________________________________#_____rr_____________________#
#_______________________rr__________________________________#____________________________D
#_______________________rr__________________________________#____________________________D
#_____________________________rr________________rr__________#____________________________#
#_____________________________rr________________rr__________#_______________rr___________#
#_______rr____________________________rr____________________#_______________rr____G______#
#_______rr____________________________rr____________________#____________________________#
#___________________________________________________________#____________________________#
#___________________________________________________________#____________________________#
#___________________________________________________________##########__##################
Ww_______________________________________________________________________________________#
W_______________rr________________________________rr_____________________________________#
#_______________rr________________________________rr_____________________________________#
#________________________________________________________________________________________#
#________________________________________________________________________________________#
#_____________________________________B__________________________________________________#
#___________________________rr___________________________________________________________#
#___________________________rr______________________________________________C____________#
#________________________________________________________________________________________#
Xe________________A______________________________________________________________________#
X_________________________________E_________________________rr__________________________yY
#___________________rr______________________________________rr___________________________Y
#___________________rr__________________rr_______________________________________________#
#_______________________________________rr______________________F_rr_____________________#
#_________________________________________________________________rr_____________________#
#________________________________________________________________________________________#
#___________________________________________________________rr___________________________#
#___________________________________________________________rr___________________________#
#________________________________________________________________________________________#
#_______________rr__________________________rr___________________________________________#
#_______________rr__________________________rr___________________________________________#
#________________________________________________________________________________________#
#________________________________________________________________________________________#
#_______rr__________________________________________rr______rrrrrrrrrrrr__rrrrrrrrrrrrr__#
#_______rr__________________________________________rr______rrrrrrrrrrrr__rrrrrrrrrrrrr__#
#___________________________________rr______________________#_________________________#__#
#___________________________________rr______________________#_________________________#__#
#_________________________rr________________________________#_________________________#__#
#_________________________rr________________________________#_________________________#__#
#_____________rr______________________________rr____________#_________________________#__#
#_____________rr______________________________rr____________#____________c____________#__#
#___________________________________________________________#_________________________#__#
#___________________________________________________________#_________________________#__#
#___________________________________________________________#_________________________#__#
#___________________________________________________________#_________________________#__#
##########################################################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to gk_mulut (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_mulut", spawn_id:"from_gk_pasir"}` | floor | 2 |
| `e` | spawn, arrival from gk_mulut | `res://entities/world/spawn.tscn` | `{id:"from_gk_mulut"}` | floor | 1 |
| `W` | exit to gk_pelataran (west edge, north side, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_pelataran", spawn_id:"from_gk_pasir"}` | floor | 2 |
| `w` | spawn, arrival from gk_pelataran | `res://entities/world/spawn.tscn` | `{id:"from_gk_pelataran"}` | floor | 1 |
| `Y` | exit to gk_hutan (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_hutan", spawn_id:"from_gk_pasir"}` | floor | 2 |
| `y` | spawn, arrival from gk_hutan | `res://entities/world/spawn.tscn` | `{id:"from_gk_hutan"}` | floor | 1 |
| `D` | exit, the drop D1 to gk_lupa (east rim of the high gallery, 2 tiles, one way, no spawn back) | `res://entities/world/exit.tscn` | `{target_zone:"gk_lupa", spawn_id:"from_gk_pasir"}` | floor | 2 |
| `E` | encounter kala_pasir_1 (5.5) | `res://entities/world/encounter.tscn` | `{area_id:"kala_pasir_1", size:Vector2i(22,12), cond:"flag:mq5_la,!flag:mq5_1c", waves:[[[res://entities/enemies/genderuwo.tscn, Vector2i(7,0)], [res://entities/enemies/pocong.tscn, Vector2i(3,-4)], [res://entities/enemies/pocong.tscn, Vector2i(3,4)]]]}` | floor | 1 |
| `F` | encounter kala_pasir_2 (5.5, sets `mq5_1c`) | `res://entities/world/encounter.tscn` | `{area_id:"kala_pasir_2", size:Vector2i(20,11), cond:"flag:mq5_la,!flag:mq5_1c", waves:[[[res://entities/enemies/kemamang.tscn, Vector2i(6,-3)], [res://entities/enemies/kemamang.tscn, Vector2i(6,3)]]]}` | floor | 1 |
| `c` | chest: 300 Ilmu (secret, sand cave behind the pillar gap) | `res://entities/world/chest.tscn` | `{chest_id:"kala_chest_1", item_id:"ilmu:300"}` | floor | 1 |
| `A` | clue, the time-ward inscription (5.5 `clue` piece; journal note only, ASSUMED id) | `res://entities/world/clue.tscn` | `{clue_id:"ward_inscription", cond:"flag:mq5_la"}` | floor | 1 |
| `B` | trigger, puzzle `puzzle_pasir_ward_w` (5.5: turn the three hourglass stones until the sand runs up; the western ward shatters) | `res://entities/world/trigger.tscn` | `{trigger_id:"puzzle_pasir_ward_w", size:Vector2i(12,8), cond:"flag:mq5_la"}` | floor | 1 |
| `C` | trigger, puzzle `puzzle_pasir_ward_e` (5.5: same, mirrored; the eastern ward shatters) | `res://entities/world/trigger.tscn` | `{trigger_id:"puzzle_pasir_ward_e", size:Vector2i(12,8), cond:"flag:mq5_la"}` | floor | 1 |
| `G` | trigger, beat spot at the high gallery (5.5: both wards down, Semar's one line; ASSUMED) | `res://entities/world/trigger.tscn` | `{trigger_id:"beat_wards_down", size:Vector2i(8,6), cond:"flag:mq5_1c"}` | floor | 1 |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `kala_pasir_1` | `E (34,25)` | 22x12 | W1: Genderuwo (+7,+0), Pocong (+3,-4), Pocong (+3,+4) | Ka Bolt on the rock, Nga Bind on a hopping Pocong |
| `kala_pasir_2` | `F (64,28)` | 20x11 | W1: Kemamang (+6,-3), Kemamang (+6,+3) | Na Dash-strike |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| west ward | (30,15)-(45,25) | Clue, puzzle | clue `A` (18,24), trigger `B` (38,20) | 5.2 |
| east ward and gallery | (68,17)-(88,12) | Puzzle, beat before the drop | trigger `C` (76,22), trigger `G` (82,10) | 5.2 |
## Area 3: gk_lupa

- Size: 60 x 51 tiles = 2 x 3 screens (30 x 17 each).
- Look: Hall of faded letters: dim Sunda, Jawa and forgotten aksara drift like motes, shelves of stone tablets, a sand-choked west arch, the boss door in the south.
- Purpose: Drop landing, plain exit into the `sc:gk_lorong` pocket in gk_mulut, fight `kala_lupa` (north), chest behind tablets, codex spot, petilasan `kala_1` with Semar, door to gk_ruang_kala.

### Map
```
############################NN##############################
#___________________________n______________________________#
#__________________________________________________________#
#__________________________________________________________#
#_____l____________________________________________________#
Xm_________________________________________________________#
X__________________________________________________________#
#__________________________________________________________#
#_____________A_______________________________________rr___#
#_____________________________________________________rr___#
#__________________________________________________________#
#__________________________________________________________#
#__________________________________________________________#
#_______________________________E__________________________#
#___rr________________________________________________rr___#
#___rr________________________________________________rr___#
#_________________________________________________________yY
#__________________________________________________________Y
#__________________________________________________________#
#__________________________________________________________#
#___rr_____________________________________________________#
#___rr_____________________________________________________#
#____________________________________________________#######
#__________________________________________________rr#_____#
#_____________________________B____________________rr#_____#
#__________________________________________________________#
#___rr__________________________________________________c__#
#___rr_____________________________________________rr#_____#
#__________________________________________________rr#_____#
#_________rr______rr_________________________________#_____#
#_________rr______rr_________________________________#######
#__________________________________________________________#
#___________g___i__________________________________________#
#__________________________________________________________#
#__________________________________________________________#
#__________________________________________________________#
#___rr______________________F______________________________#
#___rr___________________________G_________________________#
#___________________rr__________________rr____________rr___#
#___________________rr__________________rr____________rr___#
#_____________________________P__H_________________________#
#__________________________________________________________#
#___rr_____________________C________D______________________#
#___rr_____________________________________________________#
#_______________rr__________________________rr________rr___#
#_______________rr__________________________rr________rr___#
#__________________________________________________________#
#__________________________________________________________#
#__________________________________________________________#
#____________________________s_____________________________#
#############################SS#############################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to gk_mulut (west edge, plain exit into the `sc:gk_lorong` pocket, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_mulut", spawn_id:"from_gk_lupa"}` | floor | 2 |
| `m` | spawn, arrival from gk_mulut | `res://entities/world/spawn.tscn` | `{id:"from_gk_mulut"}` | floor | 1 |
| `N` | exit to gk_hutan (north edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_hutan", spawn_id:"from_gk_lupa"}` | floor | 2 |
| `n` | spawn, arrival from gk_hutan | `res://entities/world/spawn.tscn` | `{id:"from_gk_hutan"}` | floor | 1 |
| `Y` | exit to gk_jembatan (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_jembatan", spawn_id:"from_gk_lupa"}` | floor | 2 |
| `y` | spawn, arrival from gk_jembatan | `res://entities/world/spawn.tscn` | `{id:"from_gk_jembatan"}` | floor | 1 |
| `l` | spawn, landing of the drop D1 from gk_pasir (no exit back) | `res://entities/world/spawn.tscn` | `{id:"from_gk_pasir"}` | floor | 1 |
| `E` | encounter kala_lupa (**miniboss**, 5.7: the Prajurit is the elite `kala_lupa_elite`) | `res://entities/world/encounter.tscn` | `{area_id:"kala_lupa", size:Vector2i(20,11), cond:"flag:mq5_1cb,!flag:mq5_1d", waves:[[[res://entities/enemies/prajurit_terkutuk.tscn, Vector2i(7,0)], [res://entities/enemies/banaspati.tscn, Vector2i(3,-3)], [res://entities/enemies/banaspati.tscn, Vector2i(3,3)]]]}` | floor | 1 |
| `c` | chest: 300 Ilmu (secret, behind stone tablets) | `res://entities/world/chest.tscn` | `{chest_id:"kala_chest_2", item_id:"ilmu:300"}` | floor | 1 |
| `g` | codex spot kala_aksara_pudar, faded letters 1 (Batara Kala) | `res://entities/world/pickup.tscn` | `{codex_id:"batara_kala"}` | floor | 1 |
| `i` | codex spot kala_aksara_pudar, faded letters 2 (ruwatan) | `res://entities/world/pickup.tscn` | `{codex_id:"ruwatan"}` | floor | 1 |
| `P` | petilasan 1 (last rest, no enemy and no encounter between it and the door) | `res://entities/petilasan/petilasan.tscn` | `{id:"kala_1"}` | floor | 1 |
| `H` | NPC Semar (`semar_kala`: step 5.9 main talk after `kala_1`, hubs; a separate id so it never counts for `talked_to:semar`) | `res://entities/npc/npc.tscn` | `{npc_id:"semar_kala"}` | floor | 1 |
| `S` | exit to gk_ruang_kala (south edge, the boss door, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_ruang_kala", spawn_id:"from_gk_lupa"}` | floor | 2 |
| `s` | spawn, arrival from gk_ruang_kala | `res://entities/world/spawn.tscn` | `{id:"from_gk_ruang_kala"}` | floor | 1 |
| `A` | encounter kala_lupa_1 (5.7, fight before the miniboss) | `res://entities/world/encounter.tscn` | `{area_id:"kala_lupa_1", size:Vector2i(14,8), cond:"flag:mq5_1cb,!flag:mq5_1d", waves:[[[res://entities/enemies/lampor.tscn, Vector2i(-3,-1)], [res://entities/enemies/lampor.tscn, Vector2i(0,2)], [res://entities/enemies/lampor.tscn, Vector2i(3,-1)]]]}` | floor | 1 |
| `B` | clue, a faded floating letter *Ra* (5.7; opens gap memory `ra`; cond `flag:mq5_1d`) | `res://entities/world/clue.tscn` | `{clue_id:"letter_ra", memory_id:"ra", cond:"flag:mq5_1d"}` | floor | 1 |
| `C` | clue, a faded floating letter *Sa* (5.9; opens gap memory `sa`; cond `flag:mq5_2`) | `res://entities/world/clue.tscn` | `{clue_id:"letter_sa", memory_id:"sa", cond:"flag:mq5_2"}` | floor | 1 |
| `D` | clue, Semar's tale stone (5.10 K10; opens `k10_murwakala`; cond `flag:memory_sa`) | `res://entities/world/clue.tscn` | `{clue_id:"semar_tale", memory_id:"k10_murwakala", cond:"flag:memory_sa"}` | floor | 1 |
| `F` | clue, Laras's lontar fragment (5.12 LC6, after K7; opens `lc6`; ASSUMED id; cond `flag:mq5_h2`) | `res://entities/world/clue.tscn` | `{clue_id:"lc6_lontar", memory_id:"lc6", cond:"flag:mq5_h1"}` | floor | 1 |
| `G` | clue, Semar's kelir (5.11 K7, after K10; opens `k7_ruwatan`; cond `flag:mq5_lc`) | `res://entities/world/clue.tscn` | `{clue_id:"semar_kelir", memory_id:"k7_ruwatan", cond:"flag:mq5_h2"}` | floor | 1 |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `kala_lupa` | `E (32,13)` | 20x11 | W1: Prajurit Terkutuk (+7,+0), Banaspati (+3,-3), Banaspati (+3,+3) | Na Dash-strike behind the shield, Ga Ward on the burn |
| `kala_lupa_1` | `E (14,8)` | 14x8 | W1: Lampor (-3,-1), Lampor (0,+2), Lampor (+3,-1) | Ca Burst |

### Rooms (v4c)
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| last rest | (24,34)-(38,46) | Petilasan `kala_1`, Semar, clues in v5 order: `C` letter_sa (5.9), `D` semar_tale (K10, 5.10), `G` semar_kelir (K7, 5.11), `F` lc6_lontar (LC6, 5.12) | 5.9-5.12 |
| abyss | (4,4)-(40,28) | Fight (14,8), miniboss (32,13), letter_ra `B` (30,24) | 5.7 |
## Area 4: gk_ruang_kala

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: A round chamber, a clock face on the floor, the great hourglass overhead (art layer). Open floor, no rocks.
- Purpose: Boss arena Batara Kala (interior about 44 x 29, no rocks). Arena gate `A` in the north corridor (the arrival spawn sits just inside it). North door back to gk_lupa, south lit door to Desa Purwa behind the kabut `mq5_3`, quest marker `kala_exit`.

### Map
```
#############################NN#############################
#############################AA#############################
##########################__Rn____##########################
#####################__________________#####################
##################________________________##################
################____________________________################
##############________________________________##############
#############__________________________________#############
############____________________________________############
###########______________________________________###########
##########________________________________________##########
##########________________________________________##########
#########__________________________________________#########
#########__________________________________________#########
########____________________________________________########
########____________________________________________########
########____________________________________________########
########______________________B_____________________########
########____________________________________________########
########____________________________________________########
#########__________________________________________#########
#########__________________________________________#########
##########________________________________________##########
##########________________________________________##########
###########______________________________________###########
############____________________________________############
#############__________________________________#############
##############________________________________##############
################____________________________################
##################________________________##################
#####################__________________#####################
##########################___T____##########################
#############################KK#############################
#############################SS#############################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `N` | exit to gk_lupa (north edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_lupa", spawn_id:"from_gk_ruang_kala"}` | floor | 2 |
| `A` | arena gate (combat.md 5.3 v7) at the north corridor mouth; open until the threshold two tiles inside is crossed | `res://entities/world/arena_gate.tscn` | `{side:"s"}` | floor | 2 |
| `n` | spawn, arrival from gk_lupa | `res://entities/world/spawn.tscn` | `{id:"from_gk_lupa"}` | floor | 1 |
| `B` | boss Batara Kala (arena centre; wakes after LC6, `flag:mq5_lc`, step 5.13; phase 3 is the ruwatan setpiece) | `res://entities/bosses/batara_kala.tscn` | `{cond:"flag:mq5_lc", finish_glyph:"jawa_ka"}` | floor | 1 |
| `S` | exit to desa_purwa (south edge, the lit door, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"desa_purwa", spawn_id:"from_gua_kala"}` | floor | 2 |
| `K` | kabut, lifts on the boss (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq5_3"}` | floor | 2 |
| `T` | trigger, quest marker kala_exit (4x2) | `res://entities/world/trigger.tscn` | `{trigger_id:"kala_exit", size:Vector2i(4,2)}` | floor | 1 |
| `R` | rehearsal lock for Kala (5.12): a sealed glyph lock in the corridor between the gate and the threshold, by the arrival spawn, so it is reachable before Kala wakes (the corridor is all that lies outside the threshold; the gate stands on the map edge). Cast Jawa Ka on it (rehearsal.tscn, id `reh_kala`) | `res://entities/world/rehearsal.tscn` | `{id:"reh_kala", glyph:"jawa_ka", look:"lock", boss:"batara_kala"}` | floor | 1 |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| none | none | none | none | none |

## Area 5: gk_pelataran

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Pelataran Waktu (Courtyard of Time), outer temple forecourt of black stone with ancestral pillars, memorial stones, and a petilasan flame.
- Purpose: MQ5 5.1–5.2 (`kala_pelataran_siege`, `memorial_stone` for Choice 6, `ciung_wanara`, `hariang_banga`), SQ-C3 step 4 (`deserter_stone`), and petilasan `kala_0`. The region entry: links to `desa_purwa` (west) and `sk_keraton` (south, both behind the `mq4_9` kabut on their side), `gk_mulut` and `gk_pasir`.

### Map
```
############################NN##############################
#___________________________n______________________________#
#__________________________________________________________#
#______________rr__________________________rr______________#
#______________rr__________________________rr______________#
#__________________________________________________________#
#______________________C___________H_______________________#
#___________________________R__G______T____________________#
#__________________________________________________________#
#___________________rr________________rr___________________#
#___________________rr________________rr___________________#
#__________________________________________________________#
#_____________________________E____________________________#
#__________________________________________________________#
#__________________________________________________________#
#___________________rr________________rr___________________#
Kk__________________rr________________rr__________________yY
K__________________________________________________________Y
#__________________________________________________________#
#__________________________________________________________#
#______________rr__________________________rr______________#
#______________rr__________________________rr______________#
#__________________________________________________________#
#____________________M________P________D___________________#
#__________________________________________________________#
#__________________________________________________________#
#___________________rr________________rr___________________#
#___________________rr________________rr___________________#
#__________________________________________________________#
#__________________________________________________________#
#__________________________________________________________#
#__________________________________________________________#
#_______________________________________w__________________#
########################################WW##################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `N` | exit to gk_mulut (north edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_mulut", spawn_id:"from_gk_pelataran"}` | floor | 2 |
| `n` | spawn, arrival from gk_mulut | `res://entities/world/spawn.tscn` | `{id:"from_gk_mulut"}` | floor | 1 |
| `K` | exit to desa_purwa (west edge, 2 tiles; the Act VI gate from the village north road) | `res://entities/world/exit.tscn` | `{target_zone:"desa_purwa", spawn_id:"from_gk_pelataran"}` | floor | 2 |
| `k` | spawn, arrival from desa_purwa | `res://entities/world/spawn.tscn` | `{id:"from_desa_purwa"}` | floor | 1 |
| `W` | exit to sk_keraton (south edge, a sea-cave passage, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_keraton", spawn_id:"from_gk_pelataran"}` | floor | 2 |
| `w` | spawn, arrival from sk_keraton | `res://entities/world/spawn.tscn` | `{id:"from_sk_keraton"}` | floor | 1 |
| `Y` | exit to gk_pasir (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_pasir", spawn_id:"from_gk_pelataran"}` | floor | 2 |
| `y` | spawn, arrival from gk_pasir | `res://entities/world/spawn.tscn` | `{id:"from_gk_pasir"}` | floor | 1 |
| `E` | encounter kala_pelataran_siege (5.1 setpiece with the allies, `area_cleared:kala_pelataran_siege` sets `mq5_0`) | `res://entities/world/encounter.tscn` | `{area_id:"kala_pelataran_siege", size:Vector2i(16,9), cond:"flag:mq4_9,!flag:mq5_0", waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-4,-2)], [res://entities/enemies/faceless.tscn, Vector2i(4,-2)], [res://entities/enemies/prajurit_terkutuk.tscn, Vector2i(0,2)]]]}` | floor | 1 |
| `M` | NPC ancestors' memorial stone for Choice 6 (5.2, `step:mq5=1`; the talk sets `mq5_choice6` and `choice_redeem_aria` / `choice_release_aria`, **Choice 6**) | `res://entities/npc/npc.tscn` | `{npc_id:"memorial_stone", cond:"flag:mq5_0,!flag:mq5_choice6"}` | floor | 1 |
| `D` | NPC write stone for Ranga's name (SQ-C3) | `res://entities/npc/npc.tscn` | `{npc_id:"deserter_stone"}` | floor | 1 |
| `C` | NPC Ciung Wanara holding the courtyard (5.1 main talk, hub; always here; if `choice_judgment` his royal vanguard stands on the walls, no spot) | `res://entities/npc/npc.tscn` | `{npc_id:"ciung_wanara"}` | floor | 1 |
| `H` | NPC Hariang Banga holding the courtyard (5.1, hub; always here) | `res://entities/npc/npc.tscn` | `{npc_id:"hariang_banga"}` | floor | 1 |
| `P` | petilasan 0 (courtyard rest) | `res://entities/petilasan/petilasan.tscn` | `{id:"kala_0"}` | floor | 1 |
| `R` | NPC Ranga, the freed Faceless Deserter, an ally in the siege (Choice 2; replaces the retired `gk_mulut` spot `deserter_mouth`; the write stone `D` is his SQ-C3 stone) | `res://entities/npc/npc.tscn` | `{npc_id:"faceless_deserter", cond:"flag:choice_freed"}` | floor | 1 |
| `G` | NPC Dewi Naganingrum with her lake-wardens (Choice 1, Tell Ciung) | `res://entities/npc/npc.tscn` | `{npc_id:"naganingrum", cond:"flag:choice_tell_ciung"}` | floor | 1 |
| `T` | NPC Cepot with the lamp from the turtle beach (SQ-C4 done) | `res://entities/npc/npc.tscn` | `{npc_id:"cepot", cond:"flag:c4_done"}` | floor | 1 |

## Area 6: gk_hutan

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Hutan Lupa (The Forgotten Woods), petrified underground forest of whispering name-trees and hanging stone chimes.
- Purpose: MQ5 5.6 (`kala_hutan_echoes`, `whisper_tree_1`-`_3` (props)), and chest `kala_chest_hutan`. Links to `gk_pasir` and `gk_lupa`.

### Map
```
############################################################
#__________________________________________________________#
#______##########__________________________##########______#
#______#________#__________________________#________#______#
#______#___c____#__________________________#________#______#
#______####__####__________________________####__####______#
#__________________________________________________________#
#______________rr__________________________rr______________#
#______________rr__________________________rr______________#
#__________________________________________________________#
#__________________________________________________________#
#___________________rr________________rr___________________#
#___________________rr________________rr___________________#
#__________________________________________________________#
#__________________________________________________________#
#__________________________________________________________#
Ww____________________________E____________________________#
W__________________________________________________________#
#_______________________________________N__________________#
#__________________________________________________________#
#___________________rr________________rr___________________#
#___________________rr________________rr___________________#
#__________________________________________________________#
#__________________________________________________________#
#_________________________1_______3________________________#
#______________rr__________________________rr______________#
#______________rr_____________2____________rr______________#
#__________________________________________________________#
#__________________________________________________________#
#__________________________________________________________#
#__________________________________________________________#
#__________________________________________________________#
#___________________________s______________________________#
############################SS##############################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `W` | exit to gk_pasir (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_pasir", spawn_id:"from_gk_hutan"}` | floor | 2 |
| `w` | spawn, arrival from gk_pasir | `res://entities/world/spawn.tscn` | `{id:"from_gk_pasir"}` | floor | 1 |
| `S` | exit to gk_lupa (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_lupa", spawn_id:"from_gk_hutan"}` | floor | 2 |
| `s` | spawn, arrival from gk_lupa | `res://entities/world/spawn.tscn` | `{id:"from_gk_lupa"}` | floor | 1 |
| `E` | encounter kala_hutan_echoes (5.6 `area_cleared:kala_hutan_echoes`) | `res://entities/world/encounter.tscn` | `{area_id:"kala_hutan_echoes", size:Vector2i(15,9), cond:"flag:mq5_1c,!flag:mq5_1cb", waves:[[[res://entities/enemies/kuntilanak.tscn, Vector2i(-4,0)], [res://entities/enemies/kemamang.tscn, Vector2i(4,-2)], [res://entities/enemies/kemamang.tscn, Vector2i(4,2)]]]}` | floor | 1 |
| `c` | chest: class gear `gelang_baja`, a second path gets its sibling (ASSUMED) | `res://entities/world/chest.tscn` | `{chest_id:"kala_chest_hutan", item_id:"gelang_baja"}` | floor | 1 |
| `N` | clue, the whispering stone name-trees (5.6; journal note only; id `name_trees`, hunt `kala`; ASSUMED position) | `res://entities/world/clue.tscn` | `{clue_id:"name_trees", cond:"flag:mq5_1c"}` | floor | 1 |
| `1` | whispering name-tree 1 of 3; answer it with the name of someone you helped (5.6; sets `flag:whisper_tree_1`) | `res://entities/npc/npc.tscn` | `{npc_id:"whisper_tree_1", cond:"flag:mq5_1c"}` | floor | 1 |
| `2` | whispering name-tree 2 of 3; answer it with the name of someone you helped (5.6; sets `flag:whisper_tree_2`) | `res://entities/npc/npc.tscn` | `{npc_id:"whisper_tree_2", cond:"flag:mq5_1c"}` | floor | 1 |
| `3` | whispering name-tree 3 of 3; answer it with the name of someone you helped (5.6; sets `flag:whisper_tree_3`) | `res://entities/npc/npc.tscn` | `{npc_id:"whisper_tree_3", cond:"flag:mq5_1c"}` | floor | 1 |

## Area 7: gk_jembatan

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Jembatan Bayang (The Shadow Bridge), ancient stone causeway spanning the chasm of eaten time.
- Purpose: MQ5 5.8 (`kala_jembatan_echoes`) and chest `kala_chest_jembatan`. Links to `gk_lupa`.

### Map
```
############################################################
#__________________________________________________________#
#_______~~~~____________________________________~~~~_______#
#_______~~~~____________________________________~~~~_______#
#_______~~~~____________________________________~~~~_______#
#__________________________________________________________#
#______________rr__________________________rr______________#
#______________rr__________________________rr______________#
#__________________________________________________________#
#__________________________________________________________#
#___________________rr________________rr___________________#
#___________________rr________________rr___________________#
#__________________________________________________________#
#__________________________________________________________#
#__________________________________________________________#
#__________________________________________________________#
Ww____________________________E____________________________#
W__________________________________________________________#
#_____________________________B____________________________#
#__________________________________________________________#
#___________________rr________________rr___________________#
#___________________rr________________rr___________________#
#__________________________________________________________#
#__________________________________________________c_______#
#______________rr__________________________rr______________#
#______________rr__________________________rr______________#
#__________________________________________________________#
#_______~~~~____________________________________~~~~_______#
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
| `W` | exit to gk_lupa (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_lupa", spawn_id:"from_gk_jembatan"}` | floor | 2 |
| `w` | spawn, arrival from gk_lupa | `res://entities/world/spawn.tscn` | `{id:"from_gk_lupa"}` | floor | 1 |
| `E` | encounter kala_jembatan_echoes (5.8, the miniboss is the Prajurit; sets `mq5_1e`; the beat `bridge` plays in this zone) | `res://entities/world/encounter.tscn` | `{area_id:"kala_jembatan_echoes", size:Vector2i(16,9), cond:"flag:mq5_ra,!flag:mq5_1e", waves:[[[res://entities/enemies/arca_penjaga.tscn, Vector2i(-4,0)], [res://entities/enemies/prajurit_terkutuk.tscn, Vector2i(0,0)], [res://entities/enemies/bajul_putih.tscn, Vector2i(4,0)]]]}` | floor | 1 |
| `c` | chest: class gear `kantong_panah`, a second path gets its sibling (ASSUMED) | `res://entities/world/chest.tscn` | `{chest_id:"kala_chest_jembatan", item_id:"kantong_panah"}` | floor | 1 |
| `B` | clue, the row of name-stones at the end of the bridge (5.8; journal note only; id `bridge_echo`, hunt `kala`; ASSUMED position) | `res://entities/world/clue.tscn` | `{clue_id:"bridge_echo", cond:"flag:mq5_ra"}` | floor | 1 |
