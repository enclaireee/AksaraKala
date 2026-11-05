# Gua Kala (region id `gua_kala`), the finale

Area graph on paper. Step 1 of the world design workflow ([AGENTS.md](../../AGENTS.md) section 5), graph level only: no tile maps until Phase 5. Prefix `gk_`. Sources: [world.md](../world.md) (World structure, link table, Gua Kala, Checkpoints), [bestiary.md](../bestiary.md) (Final: Gua Kala, Encounters, Glyph weaknesses), [quests.md](../quests.md) (MQ5, 7.5, 9), [story.md](../story.md) (Batara Kala). Format follows [tatar_sunda.md](tatar_sunda.md).

Look: a dark cavern of wet black rock, hourglass and clock-like motifs carved into the walls, and the forgotten letters floating about, faded and dim. Sand trickles in thin streams from the ceiling in the deeper halls. The landmark is Kala's chamber. From the first area (`gk_mulut`), across a wide chasm, the player sees an enormous hourglass and a round clock-face set in the far wall, glowing faintly. It grows nearer in each area, and its ticking gets louder. Batara Kala is a deity figure and is not killed: he is calmed and turned back (a respectful ruwatan note is in the codex, per story.md). Tone stays warm and a bit cartoonish.

Areas: 4. Critical path: `gk_mulut` -> `gk_pasir` -> (drop) `gk_lupa` -> `gk_ruang_kala`. A P0 build can reach Gua Kala directly (see conflicts).

## Area table
| id | size (screens, tiles) | look | purpose | contents |
|----|-----------------------|------|---------|----------|
| `gk_mulut` | 3x2, 90x34 | The cave mouth. Wet black rock, carved clock gears, drifting faded letters, the chasm with the far hourglass in view | Entry, first rest, landmark view | Spawns `from_desa_purwa` (W, P0 entry), `from_sk_keraton` (P1, pending), `from_gk_pasir` (link L1), `from_gk_lupa` (shortcut landing). Petilasan `kala_2` (near the entry). Encounter `kala_mulut`. Shortcut landing `sc:gk_lorong`. Quest marker `kala_mulut` |
| `gk_pasir` | 3x3, 90x51 | The sand halls. Giant hourglass shapes in the walls, thin sand streams that only look pretty, rocky floors and pillars | The long way in, two fights, a secret | Spawns `from_gk_mulut` (W). Encounters `kala_pasir_1`, `kala_pasir_2`. Chest `kala_chest_1` (hidden sand cave, gap between pillars). Drop `D1` (high gallery, sand-slide) onto `gk_lupa`. Quest marker none |
| `gk_lupa` | 2x3, 60x51 | The hall of faded letters. Aksara float like dim motes: Sunda, Jawa, forgotten scripts. Shelves of stone tablets | Rest before the boss, codex, the shortcut, the boss door | Spawns `from_gk_pasir` (drop landing, N), `from_gk_ruang_kala` (S door). Encounter `kala_lupa`. Chest `kala_chest_2` (behind tablets). Petilasan `kala_1` (south end, 10 tiles from the door, no fight between). NPC `semar` at `kala_1`. Codex spot `kala_aksara_pudar`. Shortcut gate `sc:gk_lorong` (opens from here). Quest markers `kala_1`, `kala_boss` (door) |
| `gk_ruang_kala` | 2x2, 60x34 | A round chamber. A clock face on the floor, the great hourglass overhead. Four quadrants, each with a motif of an earlier region (phase 3 uses them all) | Boss arena, Batara Kala | Spawn `from_gk_lupa`. Boss `batara_kala` (marker `kala_boss`). After the fight a lit door leads to the epilogue (`kala_exit`, **ASSUMED**). No other enemies |

## Region graph
`--` link, `=sc=` shortcut, `~D~>` drop (one way), `==K==` kabut.
```
 [sk_keraton] ==K mq4_3== [gk_mulut] --L1-- [gk_pasir]
                           (kala_2)   ^           |
                                      |           ~D1~> (one way)
                                      |                 |
                                      +==sc:gk_lorong== [gk_lupa] --L2-- [gk_ruang_kala]
                                                         (kala_1)         (Batara Kala)
                                                  codex, Semar
```
Critical path: `sk_keraton` -> `gk_mulut` (rest `kala_2`) -> `gk_pasir` -> D1 -> `gk_lupa` (rest `kala_1`) -> `gk_ruang_kala`.

### Link table
| id | from area | to area | kind | gate flag | spawn ids |
|----|-----------|---------|------|-----------|-----------|
| X1 | `sk_keraton` | `gk_mulut` | link, kabut | `mq4_3` | `from_sk_keraton` (in `gk_mulut`), `from_gk_mulut` (in `sk_keraton`). In a P0 build the kabut is already open (see conflicts) |
| L1 | `gk_mulut` | `gk_pasir` | link | none | `from_gk_pasir` (in mulut), `from_gk_mulut` (in pasir) |
| D1 | `gk_pasir` | `gk_lupa` | drop (one way) | none | `from_gk_pasir` (landing in lupa). No exit leads back up |
| S1 | `gk_lupa` | `gk_mulut` | shortcut `sc:gk_lorong` | `sc:gk_lorong` | `from_gk_lupa` (in mulut), `from_gk_mulut` (in lupa) |
| L2 | `gk_lupa` | `gk_ruang_kala` | link | none (the door is a plain door, closed during the fight) | `from_gk_lupa` (in ruang), `from_gk_ruang_kala` (in lupa) |

### Shortcut table
| id | gate area | opens from | leads back to |
|----|-----------|------------|---------------|
| `sc:gk_lorong` | `gk_lupa` (west wall near the drop landing, a door choked with packed sand) | `gk_lupa` only. From `gk_mulut` it is a sand-blocked arch with no handle | `gk_mulut`, petilasan `kala_2`. After it is open the trip from `kala_2` to the boss is mulut -> lorong -> lupa -> `kala_1`, about a minute |

## Loops, drop, critical path, optional areas
Loop: `gk_mulut` -> L1 -> `gk_pasir` -> D1 (drop) -> `gk_lupa` -> `sc:gk_lorong` -> `gk_mulut`. First trip: the long walk through two fights and a high gallery. Later trips: from `kala_2` through the shortcut to the boss door, skipping the sand halls.

Drop: D1, a sand-slide from the high gallery of `gk_pasir` (hourglass motif: the sand carries the player down). The landing is a few tiles from the `sc:gk_lorong` door, so the way back to `kala_2` opens early.

Critical path (MQ5): 5.1 enter `gk_mulut`; fight `kala_mulut`; rest `kala_2`; `gk_pasir` fights; drop to `gk_lupa`; fight `kala_lupa`; 5.2 rest at `kala_1` (no fight between it and the door); 5.3 `gk_ruang_kala`, Batara Kala; 5.4 the lit door after the fight.

Optional areas: none. With 4 areas all lie on the loop, and nothing dead-ends, so rule 4 is met by having no optional dead-end area. Optional content is inside areas: `kala_chest_1` in the hidden sand cave and `kala_chest_2` behind the tablets.

## Encounters
Bestiary: about 10 kills in Gua Kala, one mix from each earlier zone at tier 4. All four are from [bestiary.md](../bestiary.md) Encounters and Zone 4. Every enemy is already known by then, so the weakness is usable. Offsets are Phase 5.

| encounter id | area | zone mix reused | enemy mix | clean answer |
|--------------|------|-----------------|-----------|--------------|
| `kala_mulut` | mulut | Tatar Sunda (`sunda_batutulis`) | 2 Bandit, 1 Kuntilanak | Ka Bolt on the shriek |
| `kala_pasir_1` | pasir | Mataram rock thrower | 1 Genderuwo, 2 Pocong | Ka Bolt on the rock, Nga Bind on a hopping Pocong |
| `kala_pasir_2` | pasir | Tanah Timur wisps (dry riverbed with rock cover) | 2 Kemamang | Na Dash-strike |
| `kala_lupa` | lupa | Tanah Timur Old guard (P0; Segara Kidul trial W3 in a P1 build) | 1 Prajurit Terkutuk, 2 Banaspati | Na Dash-strike behind the shield, Ga Ward on the burn. One tank |

Total 11 kills (about 10). Four encounters, no room with 4 or more enemies, so the 15x9 rule is met by default; the Bajul lane in `gk_lupa` is 8+ tiles. No second tank right before the boss (the pre-boss exception is not used). The newest glyph, Ombak, answers Kala's time-sand in the boss fight; its other uses here are on Lampor and projectiles.

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
Marker form `{zone: "gua_kala", id: ...}`. Ids from quests.md are marked (Q). Everything else is **ASSUMED**.

| Step | Marker id | Area | Event string |
|------|-----------|------|--------------|
| MQ5 5.1 enter Gua Kala | `kala_mulut` | `gk_mulut` | `zone_entered:gk_mulut` (zone.gd emits the area id) |
| 5.2 rest at the last petilasan | `kala_1` | `gk_lupa` | `petilasan_activated:kala_1` (Q) |
| 5.3 face Batara Kala | `kala_boss` | `gk_ruang_kala` | `boss_defeated:batara_kala` (Q) |
| 5.4 return to the wayang stage | `kala_exit` | `gk_ruang_kala` (the lit door after the fight) | `zone_entered:desa_purwa` (Q). The door leads to Desa Purwa (spawn `from_gua_kala`), epilogue and credits |
| Petilasan | `kala_2` | `gk_mulut` | `petilasan_activated:kala_2` (not a quest step) |
| Codex | `kala_aksara_pudar` | `gk_lupa` | `codex:batara_kala`, `codex:ruwatan` (ASSUMED) |
| Semar line | `semar_kala` | `gk_lupa` | `talked_to:semar_kala` (optional, not a step; a separate npc_id so it never counts for MQ steps waiting on `talked_to:semar`) |

Flags: `mq4_3` (read, Segara Kidul trial passed), `sc:gk_lorong`. Post-game: after the credits the player wakes in Desa Purwa with every zone open.

## Flow
Enter `gk_mulut` (the far hourglass in view) -> Sunda mix `kala_mulut` -> petilasan `kala_2` -> `gk_pasir` -> Mataram mix `kala_pasir_1` -> Timur mix `kala_pasir_2` -> high gallery, sand-slide drop -> `gk_lupa` -> open `sc:gk_lorong` (short way back to `kala_2`) -> Segara mix `kala_lupa` -> codex and Semar at petilasan `kala_1` -> door -> `gk_ruang_kala`, Batara Kala -> the lit door home.

## Self-check ([AGENTS.md](../../AGENTS.md) section 5 Step 2)
- [~] POI counts: 1 boss arena, 0 elite rooms, 1 NPC (3-5), 2 secrets (2-3), 1 codex spot, 4 encounters (6-10), 2 petilasans. Smaller than usual: a 4-area finale with about 10 kills (bestiary), and Semar is the only talker.
- [x] Petilasan before the boss, no fight between: `kala_1` is 10 tiles from the door; `kala_lupa` is at the north end of `gk_lupa`, 20+ tiles away, and `gk_ruang_kala` has no other enemies.
- [x] First appearances: every enemy was met in an earlier zone, and each encounter has its weakness glyph (table above).
- [x] One tank per encounter: only `kala_lupa` has a tank (1 Bajul Putih). At most one shooter (`kala_pasir_1`: Genderuwo). At most 2 waves: all single wave.
- [x] Rooms with 4 or more enemies: none. Bajul lane 8+ tiles.
- [x] Newest glyph: Ombak answers time-sand and projectiles (boss), no weakness enemy here; Lampor can be pushed back with it.
- [x] Every MQ5 step has a marker (table above).
- [x] Critical path without any one glyph: no kabut inside Gua Kala; `mq4_3` opens on the trial flag (story), not on a glyph.
- [x] Rule: at least 1 loop or 1 shortcut: loop `mulut-pasir-(D1)-lupa-(sc)-mulut` plus `sc:gk_lorong` back to `kala_2`.
- [x] At least 1 drop: D1.
- [x] Landmark: the hourglass chamber shows from `gk_mulut`.
- [x] Petilasan right before Batara Kala with no fight between: `kala_1`.
- [~] Rule 7, 2 petilasans: `kala_2` then `kala_1`. The ids run backwards (the first rest is `kala_2`) because quests.md 5.2 fixes `kala_1` as the last one.

## ASSUMED
- Area names `gk_pasir`, `gk_lupa`, `gk_ruang_kala` (only `gk_mulut` is fixed), their sizes, the loop layout, D1 and `sc:gk_lorong`.
- `kala_2` is in `gk_mulut`; `kala_1` in `gk_lupa`.
- Encounter ids, chest ids, `kala_aksara_pudar`, `kala_exit`, codex ids, spawn `from_gua_kala` in Desa Purwa.
- The four mixes (one per earlier zone) and the one-wave rule; 11 kills is "about 10".
- Semar at `kala_1`, with an optional line.
- The lit door after the fight leads to Desa Purwa; it is not a graph edge.

## Open questions
1. VERIFY (ruwatan): the codex note on ruwatan, and the claim that Kala is "turned back", not killed, need sources ([story.md](../story.md) says verified with nuance). Any new culture claim about hourglass or clock motifs for Kala is a design invention, not folklore.
2. Should the arena be bigger than 2x2 for phase 3 "all arenas combined"? Here 60x34 with four quadrant motifs.
3. P0 build without Segara Kidul has no Lampor or Bajul Putih. Swap `kala_lupa` to the Timur "Old guard" mix (1 Prajurit Terkutuk, 2 Banaspati)? No Jawa Ka then either.
4. How does the player return to Desa Purwa after the boss? A lit door (ASSUMED) or a cutscene.
5. Is Semar at `kala_1` wanted, or does story.md want him silent in the finale?

## P0 decisions (ASSUMED 2026-11-05, resolve open questions 2-5 and the conflicts)
- Entry: link X0 from `desa_purwa` (a fogged east exit, kabut `mq3_8`) to `gk_mulut`, spawns `from_desa_purwa` (in mulut) and `from_gk_mulut` (in Desa Purwa). X1 from `sk_keraton` stays pending until Segara Kidul (P1). MQ5 requires `mq3_8`; Semar's 3.8 talk starts it.
- Arena: stays 2x2 (60x34), quadrant motifs are art only (open question 2).
- `kala_lupa` uses the Timur Old guard mix (open question 3).
- Return: the lit door `kala_exit`, an exit to `desa_purwa` (spawn `from_gua_kala`) that appears after `boss_defeated:batara_kala` (open question 4). Entering Desa Purwa completes 5.4 and MQ5, and the epilogue scene plays.
- Semar is at `kala_1` with one optional line, npc id `semar_kala` (open question 5).
- Kala HP 8400 (P0). No tier scaling exists, so the reused mixes keep their own stats.

## Doc conflicts found (not fixed)
- world.md and quests.md say Gua Kala may be reached directly in a P0 build, but the only link to `gk_mulut` is from `sk_keraton`. A P0 fallback entry is needed (for example a temporary link from Desa Purwa, spawn `from_desa_purwa`). Not decided.
- bestiary.md says Kala HP 9300 / 3 phases for a full build and 8400 for P0, with no arena size. world.md says 2x2 to 3x3 screens per area.
- quests.md fixes `kala_1` as "the last petilasan", so a two-petilasan region numbers its first rest `kala_2`.
- quests.md 5.4 `zone_entered:desa_purwa` has no graph edge from Gua Kala in world.md.
- world.md Points of interest asks 6-10 encounters and 3-5 NPCs per region; bestiary.md fixes about 10 kills for Gua Kala, which gives 4 encounters.

## Area maps (Phase 5)
The 4 sections below follow the format of [tanah_timur.md](tanah_timur.md) (tile chars as in tatar_sunda.md, legend, encounters). Coordinates are (x, y) from the top-left tile (0,0). The whole region is cave: floor is `_`, `#` is cave wall, `r` is rock or pillar. A shortcut gate (2-tile `shortcut.tscn`) sits only in the area behind it, with its pocket (spawn, exit) on the open side; the opener area has a plain exit into that pocket: the `sc:gk_lorong` gate is in gk_mulut (north wall, west end), the plain exit is in gk_lupa. The drop D1 is the `D` exit on the east rim of the gk_pasir gallery; it lands on spawn `from_gk_pasir` in gk_lupa and nothing leads back up. Quest marker `kala_exit` is a trigger node in gk_ruang_kala; the `kala_mulut` and `kala_1`/`kala_boss` markers are not placed here.

## Area 1: gk_mulut

- Size: 90 x 34 tiles = 3 x 2 screens (30 x 17 each).
- Look: Wet black cave mouth, carved clock gears, drifting faded letters, the far hourglass and clock face faint across the dark. A small sand-choked side pocket by the first petilasan.
- Purpose: Entry from Desa Purwa, first rest `kala_2`, fight `kala_mulut`, link to gk_pasir, the gate of `sc:gk_lorong` (north wall, west) with its pocket and exit into gk_lupa.

### Map
```
############NN############################################################################
#__________#n_#__________________________________________________________________________#
#__________#__#_____________________________#####________________________________________#
#__________#++#_____________________________#####___________#########____________________#
#___________________#######_________________#####___________#########_______________rr___#
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
Xe____________________________________________E_________________________________________yY
X________________________________________________________________________________________Y
#________________________________________________________________________________________#
#________________________________________________________________________________________#
#_________________rr_____________________________________________________________________#
#_________________rr_____________________________________________________________________#
#_______________________________________________________________________________rr_______#
#_______________________________________________________________________________rr_______#
#_______#####_____________________________________________________#########______________#
#_______#####_____________________________________________________#########______________#
#_______#####_________________#########_____________rr____________#########______________#
#_______#####_________________#########_____________rr____________#########______________#
#_______#####_________________#########___________________________#########______________#
#_____________________________#########___________________________#########______________#
#_____________________________#########__________________________________________________#
#________________________________________________________________________________________#
#________________________________________________________________________________________#
##########################################################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to desa_purwa (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"desa_purwa", spawn_id:"from_gk_mulut"}` | floor | 2 |
| `e` | spawn, arrival from desa_purwa | `res://entities/world/spawn.tscn` | `{id:"from_desa_purwa"}` | floor | 1 |
| `Y` | exit to gk_pasir (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_pasir", spawn_id:"from_gk_mulut"}` | floor | 2 |
| `y` | spawn, arrival from gk_pasir | `res://entities/world/spawn.tscn` | `{id:"from_gk_pasir"}` | floor | 1 |
| `N` | exit to gk_lupa (north edge, plain exit from the `sc:gk_lorong` pocket, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_lupa", spawn_id:"from_gk_mulut"}` | floor | 2 |
| `n` | spawn, arrival from gk_lupa (inside the pocket) | `res://entities/world/spawn.tscn` | `{id:"from_gk_lupa"}` | floor | 1 |
| `+` | shortcut gate sc:gk_lorong, sand-choked arch (opens from the north pocket, 2 tiles) | `res://entities/world/shortcut.tscn` | `{id:"sc:gk_lorong", open_side:"n"}` | floor | 2 |
| `P` | petilasan 2 | `res://entities/petilasan/petilasan.tscn` | `{id:"kala_2"}` | floor | 1 |
| `E` | encounter kala_mulut | `res://entities/world/encounter.tscn` | `{area_id:"kala_mulut", size:Vector2i(20,11), waves:[[[res://entities/enemies/bandit.tscn, Vector2i(6,-3)], [res://entities/enemies/bandit.tscn, Vector2i(6,3)], [res://entities/enemies/kuntilanak.tscn, Vector2i(8,0)]]]}` | floor | 1 |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `kala_mulut` | `E (46,16)` | 20x11 | W1: Bandit (+6,-3), Bandit (+6,+3), Kuntilanak (+8,+0) | Ka Bolt on the shriek |

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
#_______rr____________________________rr____________________#_______________rr___________#
#_______rr____________________________rr____________________#____________________________#
#___________________________________________________________#____________________________#
#___________________________________________________________#____________________________#
#___________________________________________________________##########__##################
#________________________________________________________________________________________#
#_______________rr________________________________rr_____________________________________#
#_______________rr________________________________rr_____________________________________#
#________________________________________________________________________________________#
#________________________________________________________________________________________#
#________________________________________________________________________________________#
#___________________________rr___________________________________________________________#
#___________________________rr___________________________________________________________#
#________________________________________________________________________________________#
Xe_______________________________________________________________________________________#
X_________________________________E_________________________rr___________________________#
#___________________rr______________________________________rr___________________________#
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
| `D` | exit, the drop D1 to gk_lupa (east rim of the high gallery, 2 tiles, one way, no spawn back) | `res://entities/world/exit.tscn` | `{target_zone:"gk_lupa", spawn_id:"from_gk_pasir"}` | floor | 2 |
| `E` | encounter kala_pasir_1 | `res://entities/world/encounter.tscn` | `{area_id:"kala_pasir_1", size:Vector2i(22,12), waves:[[[res://entities/enemies/genderuwo.tscn, Vector2i(7,0)], [res://entities/enemies/pocong.tscn, Vector2i(3,-4)], [res://entities/enemies/pocong.tscn, Vector2i(3,4)]]]}` | floor | 1 |
| `F` | encounter kala_pasir_2 | `res://entities/world/encounter.tscn` | `{area_id:"kala_pasir_2", size:Vector2i(20,11), waves:[[[res://entities/enemies/kemamang.tscn, Vector2i(6,-3)], [res://entities/enemies/kemamang.tscn, Vector2i(6,3)]]]}` | floor | 1 |
| `c` | chest: 300 Ilmu (secret, sand cave behind the pillar gap) | `res://entities/world/chest.tscn` | `{chest_id:"kala_chest_1", item_id:"ilmu:300"}` | floor | 1 |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `kala_pasir_1` | `E (34,25)` | 22x12 | W1: Genderuwo (+7,+0), Pocong (+3,-4), Pocong (+3,+4) | Ka Bolt on the rock, Nga Bind on a hopping Pocong |
| `kala_pasir_2` | `F (64,28)` | 20x11 | W1: Kemamang (+6,-3), Kemamang (+6,+3) | Na Dash-strike |

## Area 3: gk_lupa

- Size: 60 x 51 tiles = 2 x 3 screens (30 x 17 each).
- Look: Hall of faded letters: dim Sunda, Jawa and forgotten aksara drift like motes, shelves of stone tablets, a sand-choked west arch, the boss door in the south.
- Purpose: Drop landing, plain exit into the `sc:gk_lorong` pocket in gk_mulut, fight `kala_lupa` (north), chest behind tablets, codex spot, petilasan `kala_1` with Semar, door to gk_ruang_kala.

### Map
```
############################################################
#__________________________________________________________#
#__________________________________________________________#
#__________________________________________________________#
#_____l____________________________________________________#
Xm_________________________________________________________#
X__________________________________________________________#
#__________________________________________________________#
#_____________________________________________________rr___#
#_____________________________________________________rr___#
#__________________________________________________________#
#__________________________________________________________#
#__________________________________________________________#
#_______________________________E__________________________#
#___rr________________________________________________rr___#
#___rr________________________________________________rr___#
#__________________________________________________________#
#__________________________________________________________#
#__________________________________________________________#
#__________________________________________________________#
#___rr_____________________________________________________#
#___rr_____________________________________________________#
#____________________________________________________#######
#__________________________________________________rr#_____#
#__________________________________________________rr#_____#
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
#___rr_____________________________________________________#
#___rr_____________________________________________________#
#___________________rr__________________rr____________rr___#
#___________________rr__________________rr____________rr___#
#_____________________________P__H_________________________#
#__________________________________________________________#
#___rr_____________________________________________________#
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
| `l` | spawn, landing of the drop D1 from gk_pasir (no exit back) | `res://entities/world/spawn.tscn` | `{id:"from_gk_pasir"}` | floor | 1 |
| `E` | encounter kala_lupa | `res://entities/world/encounter.tscn` | `{area_id:"kala_lupa", size:Vector2i(20,11), waves:[[[res://entities/enemies/prajurit_terkutuk.tscn, Vector2i(7,0)], [res://entities/enemies/banaspati.tscn, Vector2i(3,-3)], [res://entities/enemies/banaspati.tscn, Vector2i(3,3)]]]}` | floor | 1 |
| `c` | chest: 300 Ilmu (secret, behind stone tablets) | `res://entities/world/chest.tscn` | `{chest_id:"kala_chest_2", item_id:"ilmu:300"}` | floor | 1 |
| `g` | codex spot kala_aksara_pudar, faded letters 1 (Batara Kala) | `res://entities/world/pickup.tscn` | `{codex_id:"batara_kala"}` | floor | 1 |
| `i` | codex spot kala_aksara_pudar, faded letters 2 (ruwatan) | `res://entities/world/pickup.tscn` | `{codex_id:"ruwatan"}` | floor | 1 |
| `P` | petilasan 1 (last rest, no enemy and no encounter between it and the door) | `res://entities/petilasan/petilasan.tscn` | `{id:"kala_1"}` | floor | 1 |
| `H` | NPC Semar (optional line) | `res://entities/npc/npc.tscn` | `{npc_id:"semar_kala"}` | floor | 1 |
| `S` | exit to gk_ruang_kala (south edge, the boss door, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"gk_ruang_kala", spawn_id:"from_gk_lupa"}` | floor | 2 |
| `s` | spawn, arrival from gk_ruang_kala | `res://entities/world/spawn.tscn` | `{id:"from_gk_ruang_kala"}` | floor | 1 |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `kala_lupa` | `E (32,13)` | 20x11 | W1: Prajurit Terkutuk (+7,+0), Banaspati (+3,-3), Banaspati (+3,+3) | Na Dash-strike behind the shield, Ga Ward on the burn |

## Area 4: gk_ruang_kala

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: A round chamber, a clock face on the floor, the great hourglass overhead (art layer). Open floor, no rocks.
- Purpose: Boss arena Batara Kala (interior about 44 x 29, no rocks). North door back to gk_lupa, south lit door to Desa Purwa behind the kabut `mq5_3`, quest marker `kala_exit`.

### Map
```
#############################NN#############################
#############################n_#############################
##########################________##########################
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
| `n` | spawn, arrival from gk_lupa | `res://entities/world/spawn.tscn` | `{id:"from_gk_lupa"}` | floor | 1 |
| `B` | boss Batara Kala (arena centre) | `res://entities/bosses/batara_kala.tscn` | `{}` | floor | 1 |
| `S` | exit to desa_purwa (south edge, the lit door, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"desa_purwa", spawn_id:"from_gua_kala"}` | floor | 2 |
| `K` | kabut, lifts on the boss (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq5_3"}` | floor | 2 |
| `T` | trigger, quest marker kala_exit (4x2) | `res://entities/world/trigger.tscn` | `{trigger_id:"kala_exit", size:Vector2i(4,2)}` | floor | 1 |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| none | none | none | none | none |
