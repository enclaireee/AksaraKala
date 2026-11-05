# Desa Purwa (zone id `desa_purwa`)

Zone design for the start village. Step 1 of the world design workflow ([AGENTS.md](../../AGENTS.md) section 5). Targets: [world.md](../world.md) "Desa Purwa", [quests.md](../quests.md) MQ0, SQ-D1, SQ-D2. A builder agent turns this file into the zone scene without redesign: change the layout here first.

Map: **60 x 34 tiles = 2 x 2 screens** (30 x 17 each). Coordinates are (x, y) from the top-left tile (0,0). Safe zone: the only enemy spots are the 4 training dummies in the sanggar.

Build rule: a char may repeat only when scene and props are identical (the 4 dummies, the 2-tile exits, the 2-tile kabut). Every other char is one spot with the floor tile listed under it (paint the floor first, then place the spot).

## Tile chars
| Char | Tile |
|------|------|
| `#` | wall or cliff (solid) |
| `.` | grass |
| `,` | path |
| `~` | water (solid) |
| `b` | bamboo (solid) |
| `t` | tea terrace (walkable) |
| `r` | rock (solid) |
| `_` | indoor or wood floor |

## Map
```
####################################################JJ######
#...................................................kk.....#
#...##################..............#############...ju.....#
#...#________________#..bb..........#___________#.....bbbb.#
#...#________________#..bb..........#___________#.....bbbb.#
#...#___D__D__D__D___#..............#_____G_____#.....bbbb.#
#...#________________#..............#___________#.....bbbb.#
#...#_______S________#..............#_____T_____#..........#
#...#________________#..............#___________#..........#
#...#__M_____________#..............#___________#..........#
#...#________________#..............#####__######..........#
#...#________________#...................,,................#
#...########__########.....,,,,,,,.......,,.............r..#
#...........,,.............,,,P,,,.......,,................#
#...........,s........rr...,,,,,,,.......,,................#
#...........,,.............,,,,,,,.......,,................#
Ww,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,vKE
W,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,KE
#......,...................,......rr.........,,............#
#......,...................,.................,,............#
#......,...................,.................,,............#
#...###_####............###_####........#####__######...r..#
#...#______#............#______#........#___________#......#
#...#______#............#______#........#___________#......#
#...#______#............#______#........#___________#......#
#...#______#............#______#........#_____R_____#......#
#...#______#..~~~~~~~...#______#........#___________#......#
#...########..~~~~~~~...########........#___________#.bbbb.#
#.............~~~~~~~...................#___________#.bbbb.#
#.............~~~~~~~...................#############.bbbb.#
#.bb..........~~~~~~~.................................bbbb.#
#.bb..................................................bbbb.#
#..........................................................#
############################################################
```

## Legend (spots)
| Char | Entity | Scene | Props | Floor under | Tiles |
|------|--------|-------|-------|-------------|-------|
| `W` | exit to Tatar Sunda | `res://entities/world/exit.tscn` | `{target_zone:"ts_kebun", spawn_id:"from_desa_purwa"}` | path | 2 |
| `w` | spawn, arrival from Tatar Sunda | `res://entities/world/spawn.tscn` | `{id:"from_ts_kebun"}` | path | 1 |
| `v` | spawn, arrival from Mataram | `res://entities/world/spawn.tscn` | `{id:"from_mt_gapura"}` | path | 1 |
| `K` | kabut, Mataram gate (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq1_10"}` | path | 2 |
| `E` | exit to Mataram | `res://entities/world/exit.tscn` | `{target_zone:"mt_gapura", spawn_id:"from_desa_purwa"}` | path | 2 |
| `s` | spawn, player start after class choice | `res://entities/world/spawn.tscn` | `{id:"start"}` | path | 1 |
| `P` | petilasan | `res://entities/petilasan/petilasan.tscn` | `{id:"desa_purwa"}` | path | 1 |
| `M` | NPC Semar | `res://entities/npc/npc.tscn` | `{npc_id:"semar"}` | floor | 1 |
| `G` | NPC Ki Wangsa (wayang dalang) | `res://entities/npc/npc.tscn` | `{npc_id:"ki_wangsa"}` | floor | 1 |
| `R` | NPC Nyai Rukmi (codex keeper) | `res://entities/npc/npc.tscn` | `{npc_id:"nyai_rukmi"}` | floor | 1 |
| `D` | training dummy (same props on all 4 tiles) | `res://entities/enemies/dummy.tscn` | `{}` | floor | 4 |
| `T` | trigger, wayang stage (prologue scene, MQ0 0.1) | `res://entities/world/trigger.tscn` | `{trigger_id:"wayang_stage", size:Vector2i(11,5)}` | floor | 1 |
| `S` | trigger, sanggar entered (shows draw tutorial) | `res://entities/world/trigger.tscn` | `{trigger_id:"sanggar_enter", size:Vector2i(16,9)}` | floor | 1 |
| `J` | exit to Gua Kala (P0 entry, Phase 5) | `res://entities/world/exit.tscn` | `{target_zone:"gk_mulut", spawn_id:"from_desa_purwa"}` | grass | 2 |
| `k` | kabut, Gua Kala gate (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq3_8"}` | grass | 2 |
| `j` | spawn, arrival from Gua Kala's mouth | `res://entities/world/spawn.tscn` | `{id:"from_gk_mulut"}` | grass | 1 |
| `u` | spawn, arrival home after Batara Kala (`kala_exit`) | `res://entities/world/spawn.tscn` | `{id:"from_gua_kala"}` | grass | 1 |

Exits sit on the map edge (x = 0 and x = 59, rows 16-17). Each exit has a spawn one tile inside: `w` (1,16) for the west exit, `v` (57,16) for the east one. The east gate is two kabut tiles `K` at (58,16) and (58,17), between `v` and the exit `E`.

## Room table
| id | tile rect (x,y) size | purpose | contents | quest markers |
|----|----------------------|---------|----------|---------------|
| sanggar | (5,3)-(20,11) 16x9 interior, walls (4,2)-(21,12), door (12..13,12) | Practice hall: draw glyphs with a guide, kill dummies | Semar `M` (7,9), 4 dummies `D` at (8,5) (11,5) (14,5) (17,5), trigger `S` (12,7); open floor y 6-11 to draw in | `semar`, `sanggar`, `dummies` |
| plaza | (27,12)-(33,15) 7x4 | Hub, first petilasan, 2 tiles from the road | petilasan `P` (30,13), rocks | `pet_desa_purwa` |
| stage | (37,3)-(47,9) 11x7, walls (36,2)-(48,10), door (41..42,10) | Wayang stage | Ki Wangsa `G` (42,5), trigger `T` (42,7) | `wayang_stage`, `ki_wangsa` |
| pustaka | (41,22)-(51,28) 11x7, door (45..46,21) | Codex keeper's house | Nyai Rukmi `R` (46,25) | `nyai_rukmi` |
| house_a, house_b | (25,22)-(30,26), (5,22)-(10,26) | Empty houses, village dressing | none | none |
| start path | (12..13,13..15) | Start landing, 2 tiles below the sanggar door | spawn `s` (13,14) | none |
| west road | (1,16)-(12,17) | Exit to Tatar Sunda | spawn `w` (1,16), exit `W` (0,16..17) | `exit_tatar_sunda` |
| east road | (47,16)-(58,17) | Fogged exit to Mataram | spawn `v` (57,16), kabut `K` (58,16..17), exit `E` (59,16..17) | `exit_mataram` |
| north gap | (52..53,0..2) | Fogged exit to Gua Kala (Phase 5) | exit `J` (52..53,0), kabut `k` (52..53,1), spawns `j` (52,2) and `u` (53,2) | `exit_gua_kala` |
| green | (1,1)-(58,32) rest | Open grass, pond (14..20,26..30), bamboo and rock dressing | none | none |

## Encounter table
None. The village has no hostile enemies. The 4 dummies are plain placed spots (no `encounter.tscn`), so `enemy_killed:dummy` x3 (MQ0 0.6) counts them, and reloading the zone restores them.

## Quest markers per step
Marker form `{zone: "desa_purwa", id: ...}`. Marker ids are **ASSUMED** (quests.md names none for this zone).

| Step | Marker id | Spot | Completes on |
|------|-----------|------|--------------|
| MQ0 0.1 watch the wayang | `wayang_stage` | `T` (42,7) | prologue scene ends (see open question 1) |
| 0.2 speak with Semar | `semar` | `M` | `talked_to:semar` |
| 0.3 choose class | `semar` | `M` | `class_chosen` |
| 0.4 learn Ka in the sanggar | `sanggar` | `S` (12,7) | `glyph_learned:sunda_ka` |
| 0.5 cast Ka x3 | `sanggar` | `S` | `spell_cast:sunda_ka` x3 |
| 0.6 defeat dummies | `dummies` | `D` | `enemy_killed:dummy` x3 |
| 0.7 head west | `exit_tatar_sunda` | `W` | `zone_entered:tatar_sunda` |
| MQ1 1.10 return to Semar | `semar` | `M` | `talked_to:semar`, sets flag `mq1_10`, kabut `K` lifts |
| SQ-D1 Lakon (giver Ki Wangsa) | `ki_wangsa` | `G` | watch lakon at the stage |
| SQ-D2 Pustaka (giver Nyai Rukmi) | `nyai_rukmi` | `R` | codex thresholds |
| Petilasan | `desa_purwa` | `P` | `petilasan_activated:desa_purwa` |

Flag in this zone: `mq1_10` (named in quests.md/world.md) on the `K` kabut.

## Flow
Start `s` outside the sanggar -> sanggar (Semar, Ka, 4 dummies) -> plaza petilasan `P` -> optional stage (Ki Wangsa) and pustaka (Nyai Rukmi) -> west road to Tatar Sunda; the east road to Mataram stays fogged until `mq1_10`.

## Validation
```
PASS all 34 rows have equal length 60
PASS size 60x34 = 2x2 screens (multiple of 30x17)
PASS every non-tile char is in the legend (missing: [])
PASS every legend char is in the map (unused: [])
PASS map edge solid except exit chars ['E', 'W'] (violations: [])
PASS exit W on map edge (2 tiles) with spawn w 1 tiles away
PASS exit E on map edge (2 tiles) with spawn v 2 tiles away
PASS BFS from start s(13, 14), kabut walkable: all 19 spot tiles reachable (unreachable: [])
PASS kabut K solid: unreachable spots EK (expected at least E)
PASS critical path s->M->P->G->R->W walkable, 137 tiles, no glyph needed (no tile or spot requires casting)
PASS sanggar has 4 dummies in a 16x9 interior; no other enemy spot in the map
PASS exactly one spawn "start" at (13, 14), 2 tiles outside the sanggar door
```

## Step 2 checklist
Desa Purwa has no enemy encounters, so the combat items are not applicable. Spawn `start`, petilasan `desa_purwa`, Semar, Ki Wangsa, Nyai Rukmi, sanggar with 4 dummies, west exit and fogged east exit are all present and validated above.

## ASSUMED
- Back route to Segara Kidul (**ASSUMED** 2026-11-05, world.md link table): a south exit to `sk_pantai`, behind a kabut that lifts when the third boss is beaten. It is drawn into the map in Phase 5 with Segara Kidul; until then the south edge stays solid.
- Spawn ids (**ASSUMED** 2026-11-05, renamed for the area graph in [world.md](../world.md) World structure; the code still uses `from_sunda`/`from_mataram` until the Part B rebuild): `start`, `from_ts_kebun` (arrival from Tatar Sunda), `from_mt_gapura`. Exit targets: `{target_zone:"ts_kebun", spawn_id:"from_desa_purwa"}`, `{target_zone:"mt_gapura", spawn_id:"from_desa_purwa"}`.
- Trigger ids `wayang_stage` and `sanggar_enter`. Marker ids above. Dialogue by Semar for 0.2, 0.3, 0.4 happens in the sanggar.
- Wayang stage is a trigger plus Ki Wangsa NPC, no extra scene.
- Gua Kala entry (**ASSUMED** 2026-11-05, gua_kala.md P0 decisions): a north-edge exit `J` at (52..53,0) to `gk_mulut`, behind kabut `k` on `mq3_8` (Semar's MQ3 3.8 talk). Spawn `j` is the arrival from the cave mouth, `u` the arrival home after the final boss.
- The west gate to Tatar Sunda has no kabut (quests.md: only the Mataram gate is fogged).

## Open questions
1. MQ0 0.1 (prologue) and 0.3 (class choice) come before the player is at `start`, if the player appears at `start` after class choice. Is the prologue played in a separate scene before this zone, with the stage trigger `T` only for SQ-D1 replays? The map supports both.
2. Does Semar teach Ka inside the sanggar (as drawn) or at the plaza? Moving him is a one-char change.
