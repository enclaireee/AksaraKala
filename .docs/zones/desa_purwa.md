# Desa Purwa (zone id `desa_purwa`)

Zone design for the start village. Step 1 of the world design workflow ([AGENTS.md](../../AGENTS.md) section 5). Targets: [world.md](../world.md) "Desa Purwa", [quests.md](../quests.md) MQ0, SQ-D1, SQ-D2. A builder agent turns this file into the zone scene without redesign: change the layout here first.

Map: **60 x 34 tiles = 2 x 2 screens** (30 x 17 each). Coordinates are (x, y) from the top-left tile (0,0). Safe zone except the MQ0 raid (`purwa_raid`, story v3.1); the other enemy spots are the 4 training dummies in the sanggar. Story v3.1 uses this zone three times: the Prologue (MQ0), the Interlude "The Quiet House" (MQ4 4.1-4.2, no combat) and the Gua Kala gate for the finale.

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
#...#________________#..............#________L__#..........#
#...#__M_____________#..............#___________#..........#
#...#________________#..............#####__######..........#
#...#________________#...................,,................#
#...########__########.....,,,,,,,.......,,.............r..#
#...........,,.............,,,P,,,.......,,................#
#...........,s........rr...,,,,,,,.......,,................#
#..h.n......,,.............,,,F,,,.......,,................#
Ww,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,vKE
W,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,KE
#......,...................,......rr.........,,............#
#......,...................z.................,,............#
#......,...................,.................,,............#
#...###_####............###_####........#####__######...r..#
#...#______#............#______#........#___________#......#
#...#______#............#_____m#........#___________#......#
#...#______#............#__I___#........#___________#......#
#...#______#............#_N__H_#........#_____R_____#......#
#...#______#..~~~~~~~...#______#........#___________#......#
#...########..~~~~~~~...########........#___________#.bbbb.#
#.............~~~~~~~...................#___________#.bbbb.#
#.............~~~~~~~...................#############.bbbb.#
#.bb..........~~~~~~~.................................bbbb.#
#.bb..........................y.......................bbbb.#
#.............................xx...........................#
##############################XX############################
```

## Legend (spots)
| Char | Entity | Scene | Props | Floor under | Tiles |
|------|--------|-------|-------|-------------|-------|
| `W` | exit to Tatar Sunda | `res://entities/world/exit.tscn` | `{target_zone:"ts_kebun", spawn_id:"from_desa_purwa"}` | path | 2 |
| `w` | spawn, arrival from Tatar Sunda | `res://entities/world/spawn.tscn` | `{id:"from_ts_kebun"}` | path | 1 |
| `v` | spawn, arrival from Keraton Galuh | `res://entities/world/spawn.tscn` | `{id:"from_kg_alun"}` | path | 1 |
| `K` | kabut, Galuh gate (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq1_10"}` | path | 2 |
| `E` | exit to Keraton Galuh | `res://entities/world/exit.tscn` | `{target_zone:"kg_alun", spawn_id:"from_desa_purwa"}` | path | 2 |
| `I` | NPC Ibu, the hero's mother (MQ0 0.3 and Interlude 4.2) | `res://entities/npc/npc.tscn` | `{npc_id:"ibu"}` | floor | 1 |
| `F` | encounter purwa_raid, 3 Faceless at the plaza (MQ0 0.7, starts at step 0.7) | `res://entities/world/encounter.tscn` | `{area_id:"purwa_raid", cond:"step:mq0=6", size:Vector2i(14,8), waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-4,-2)], [res://entities/enemies/faceless.tscn, Vector2i(4,-2)], [res://entities/enemies/faceless.tscn, Vector2i(0,2)]]]}` | path | 1 |
| `s` | spawn, player start after class choice | `res://entities/world/spawn.tscn` | `{id:"start"}` | path | 1 |
| `P` | petilasan | `res://entities/petilasan/petilasan.tscn` | `{id:"desa_purwa"}` | path | 1 |
| `M` | NPC Semar | `res://entities/npc/npc.tscn` | `{npc_id:"semar"}` | floor | 1 |
| `G` | NPC Ki Wangsa (wayang dalang) | `res://entities/npc/npc.tscn` | `{npc_id:"ki_wangsa"}` | floor | 1 |
| `R` | NPC Nyai Rukmi (codex keeper) | `res://entities/npc/npc.tscn` | `{npc_id:"nyai_rukmi"}` | floor | 1 |
| `D` | training dummy (same props on all 4 tiles) | `res://entities/enemies/dummy.tscn` | `{}` | floor | 4 |
| `T` | trigger, wayang stage (prologue scene, MQ0 0.1) | `res://entities/world/trigger.tscn` | `{trigger_id:"wayang_stage", size:Vector2i(11,5)}` | floor | 1 |
| `S` | trigger, sanggar entered (shows draw tutorial) | `res://entities/world/trigger.tscn` | `{trigger_id:"sanggar_enter", size:Vector2i(16,9)}` | floor | 1 |
| `J` | exit to Gua Kala (P0 entry, the Act VI gate) | `res://entities/world/exit.tscn` | `{target_zone:"gk_mulut", spawn_id:"from_desa_purwa"}` | grass | 2 |
| `k` | kabut, Gua Kala gate (one per tile), lifts when MQ4 is done (flag `mq4_9`, set by step 4.9) | `res://entities/world/kabut.tscn` | `{flag:"mq4_9"}` | grass | 2 |
| `j` | spawn, arrival from Gua Kala's mouth | `res://entities/world/spawn.tscn` | `{id:"from_gk_mulut"}` | grass | 1 |
| `u` | spawn, arrival home after Batara Kala (`kala_exit`) | `res://entities/world/spawn.tscn` | `{id:"from_gua_kala"}` | grass | 1 |
| `L` | pickup, Laras's lontar on the burned stage (MQ0 0.4, the deed before Ka) | `res://entities/world/pickup.tscn` | `{item_id:"laras_lontar"}` | floor | 1 |
| `X` | exit to Segara Kidul `sk_pantai` (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_pantai", spawn_id:"from_desa_purwa"}` | grass | 2 |
| `x` | kabut, south gate to the coast, lifts on the Ibu talk (flag `mq4_2`, one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq4_2"}` | grass | 2 |
| `y` | spawn, arrival from `sk_pantai` | `res://entities/world/spawn.tscn` | `{id:"from_sk_pantai"}` | grass | 1 |
| `z` | spawn, the riders drop you here (Interlude 4.1, target of the `goto` after Act IV) | `res://entities/world/spawn.tscn` | `{id:"from_riders"}` | path | 1 |
| `N` | NPC Ciung Wanara at Ibu's table (Interlude beat spot) | `res://entities/npc/npc.tscn` | `{npc_id:"ciung_wanara", cond:"flag:mq4_2,!flag:mq4_9"}` | floor | 1 |
| `H` | NPC Hariang Banga at Ibu's table (Interlude beat spot) | `res://entities/npc/npc.tscn` | `{npc_id:"hariang_banga", cond:"flag:mq4_2,!flag:mq4_9"}` | floor | 1 |
| `h` | NPC the Nameless Hunter at the west gate, staging for the `hunter_raid` beat (no talk; `npc_id` ASSUMED) | `res://entities/npc/npc.tscn` | `{npc_id:"nameless_hunter", cond:"flag:mq0_7,!flag:beat_hunter_raid"}` | grass | 1 |
| `n` | NPC Nini Balangantrang at the west gate, speaks in the `hunter_raid` beat (name key `NPC_NINI_NAME`; no talk of her own) | `res://entities/npc/npc.tscn` | `{npc_id:"nini_balangantrang", cond:"flag:mq0_7,!flag:beat_hunter_raid"}` | grass | 1 |
| `m` | codex spot, the Hunter's empty mask in the hearth (Interlude, id ASSUMED; hidden until MQ3 is done so the codex cannot spoil him) | `res://entities/world/pickup.tscn` | `{codex_id:"hunter_mask", cond:"quest:mq3=done"}` | floor | 1 |

Exits sit on the map edge (x = 0 and x = 59, rows 16-17; the south exit `X` at (30..31,33); the north exit `J` at (52..53,0)). Each exit has a spawn one tile inside: `w` (1,16) for the west exit, `v` (57,16) for the east one. The east gate is two kabut tiles `K` at (58,16) and (58,17), between `v` and the exit `E`. The south gate is two kabut tiles `x` at (30..31,32), between the spawn `y` (30,31) and the exit `X`.

## Room table
| id | tile rect (x,y) size | purpose | contents | quest markers |
|----|----------------------|---------|----------|---------------|
| sanggar | (5,3)-(20,11) 16x9 interior, walls (4,2)-(21,12), door (12..13,12) | Practice hall: draw glyphs with a guide, kill dummies | Semar `M` (7,9), 4 dummies `D` at (8,5) (11,5) (14,5) (17,5), trigger `S` (12,7); open floor y 6-11 to draw in | `semar`, `sanggar`, `dummies` |
| plaza | (27,12)-(33,15) 7x4 | Hub, first petilasan, 2 tiles from the road; the raid fight | petilasan `P` (30,13), encounter `F` (30,15), rocks | `pet_desa_purwa`, `purwa_raid` |
| stage | (37,3)-(47,9) 11x7, walls (36,2)-(48,10), door (41..42,10) | Wayang stage, burned on the night of the raid | Ki Wangsa `G` (42,5), trigger `T` (42,7), lontar `L` (45,8) | `wayang_stage`, `laras_lontar`, `ki_wangsa` |
| pustaka | (41,22)-(51,28) 11x7, door (45..46,21) | Codex keeper's house | Nyai Rukmi `R` (46,25) | `nyai_rukmi` |
| house_a | (25,22)-(30,26), door (27,21) | The hero's home; the Interlude table. Door column x = 27 (y 22..23) stays free | Ibu `I` (27,24); Interlude only: Ciung `N` (26,25), Hariang `H` (29,25), codex mask `m` (30,23) | `ibu`, `quiet_house` |
| house_b | (5,22)-(10,26) | Empty house, village dressing | none | none |
| start path | (12..13,13..15) | Start landing, 2 tiles below the sanggar door | spawn `s` (13,14) | none |
| west road | (1,16)-(12,17) | Exit to Tatar Sunda; the `hunter_raid` beat is staged just north of it | spawn `w` (1,16), exit `W` (0,16..17), Hunter `h` (3,15) and Nini `n` (5,15) (cond `flag:mq0_7,!flag:beat_hunter_raid`) | `exit_tatar_sunda` |
| arrival | (27,19) | Interlude landing, 2 tiles north of Ibu's door | spawn `z` (27,19) | `from_riders` |
| east road | (47,16)-(58,17) | Fogged exit to Keraton Galuh | spawn `v` (57,16), kabut `K` (58,16..17), exit `E` (59,16..17) | `exit_mataram` |
| north gap | (52..53,0..2) | Fogged exit to Gua Kala. In the Interlude the fog at the mouth eats every glyph you throw at it (it is the `k` kabut) | exit `J` (52..53,0), kabut `k` (52..53,1) flag `mq4_9`, spawns `j` (52,2) and `u` (53,2) | `exit_gua_kala`, `gua_kala_fog` |
| south gap | (30..31,31..33) | Fogged exit to Segara Kidul, lifts on the Ibu talk | spawn `y` (30,31), kabut `x` (30..31,32) flag `mq4_2`, exit `X` (30..31,33) | `exit_pantai` |
| green | (1,1)-(58,32) rest | Open grass, pond (14..20,26..30), bamboo and rock dressing | none | none |

## Encounter table
| id | spot | cond | waves | notes |
|----|------|------|-------|-------|
| `purwa_raid` | `F` (30,15), 14x8 | `step:mq0=6` (after Ka x3; step 0.7) | 3 Faceless | The first real fight. The 4 dummies stay plain placed spots for the Ka practice |

## Quest markers per step
Marker form `{zone: "desa_purwa", id: ...}`. Marker ids are **ASSUMED** (quests.md names none for this zone). Step numbers follow [quests.md](../quests.md) section 4 (story v3.1).

| Step | Marker id | Spot | Completes on |
|------|-----------|------|--------------|
| MQ0 0.1-0.2 | struck | - | prologue, then class choice |
| 0.3 ask Ibu where Laras is | `ibu` | `I` (27,24) | `talked_to:ibu`, sets `mq0_4` (she doesn't know any Laras; two cups are set out; "Semar was up all night at the sanggar") |
| 0.4 pull Laras's lontar from the burned stage | `laras_lontar` | `L` (45,8) inside the stage, trigger `T` (42,7) is the area | `area_entered:wayang_stage`, sets `mq0_5`; the pickup fires `item_picked:laras_lontar` |
| 0.5 show the lontar to Semar, learn Ka | `semar` | `M` (7,9) | `glyph_learned:sunda_ka` (his entry needs `flag:mq0_5`) |
| 0.6 cast Ka x3 | `sanggar` | `S` (12,7) | `spell_cast:sunda_ka` x3 (the dummies are the targets) |
| 0.7 drive the Faceless out of the square | `purwa_raid` | `F` (30,15) | `area_cleared:purwa_raid`, sets `mq0_7` |
| 0.7 beat `hunter_raid` | `exit_tatar_sunda` | `W` (0,16..17), Hunter `h` (3,15), Nini `n` (5,15) | the Hunter at the west gate (beat, `if flag:mq0_7`): "Wrong child. A better one."; Nini Balangantrang says Ciung ran west. Sets `beat_hunter_raid`, starts `mq1` |
| 0.8 follow the raiders west | `exit_tatar_sunda` | `W` | `zone_entered:ts_kebun` |
| MQ1 end | - | - | the `naga` beat in Tatar Sunda sets `mq1_10`, kabut `K` (Galuh road) lifts |
| Interlude 4.1 go home | `from_riders` | `z` (27,19) | `zone_entered:desa_purwa` (the riders' `goto` lands you on `z`) |
| 4.2 talk to Ibu | `ibu` | `I` (27,24) | `talked_to:ibu`, sets `mq4_2` (two cups; lifts kabut `x` and opens the south exit `X`; the `tt_pesisir` link opens only on `mq4_9`) |
| Interlude beat `quiet_house` / `quiet_house_silent` | `quiet_house` | `N` (26,25), `H` (29,25), mask `m` (30,23) | `if flag:mq4_2` plus `choice_mercy` or `choice_silent`: Ciung and Hariang meet as brothers at Ibu's table, the Hunter's empty mask lies in the fire, Semar: "The sea does not forget." Sets `beat_quiet_house` |
| Interlude fog | `gua_kala_fog` | `k` (52..53,1) | the fog at the Gua Kala mouth eats every glyph thrown at it (set dressing, no step); lifts on `mq4_9` |
| 4.3 on | `exit_pantai` | `X` (30..31,33) | the walk south to `sk_pantai` (4.3 is `petilasan_activated:kidul_1`) |
| MQ5 start | `exit_gua_kala` | `J` (52..53,0) | opens on `mq4_9` (MQ4 done); the finale gate |
| SQ-D1 Lakon (giver Ki Wangsa) | `ki_wangsa` | `G` | watch lakon at the stage |
| SQ-D2 Pustaka (giver Nyai Rukmi) | `nyai_rukmi` | `R` | codex thresholds |
| Petilasan | `desa_purwa` | `P` | `petilasan_activated:desa_purwa` |

Flags in this zone: `mq1_10` on the `K` kabut (set by the `naga` beat), `mq4_2` on the `x` kabut, `mq4_9` on the `k` kabut. Hunter appearances here: the west gate (Prologue) and his empty mask `m` (Interlude).

## Flow
Prologue: prologue and class choice -> `s` outside the sanggar -> Ibu `I` (0.3) -> burned stage, lontar `L` (0.4) -> Semar `M` in the sanggar, Ka (0.5), Ka x3 on the dummies (0.6) -> plaza raid `F` (0.7) -> the Hunter at the west gate -> west road `W` to Tatar Sunda (0.8). Optional: plaza petilasan `P`, Ki Wangsa `G`, Nyai Rukmi `R`. The east road to Keraton Galuh stays fogged until `mq1_10`.

Interlude: the riders drop you at `z` (4.1) -> Ibu `I` (4.2) -> the `quiet_house` beat at the table (`N`, `H`, mask `m`; no combat) -> the south gate `x` lifts, walk south through `X` to `sk_pantai`. The north fog `k` stays shut (it eats every glyph) until MQ4 is done; then `J` leads to Gua Kala.

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
Desa Purwa has one encounter, the MQ0 raid `purwa_raid`; the Interlude has no combat. Spawn `start`, petilasan `desa_purwa`, Semar, Ki Wangsa, Nyai Rukmi, sanggar with 4 dummies, west exit and fogged east exit are all present and validated above (the validation block was run on the pre-v3.1 map and must be re-run for the new chars `L X x y z N H m`).
- [x] Every MQ0 step 0.1-0.8 and MQ4 4.1-4.2 beat in quests.md section 4 has a marker or spot above (lontar `L`, Semar `M`, raid `F`, west exit `W`, riders' spawn `z`, Ibu `I`, table `N`/`H`/`m`, south gate `x`/`X`, Gua Kala fog `k`/`J`).
- [x] Interlude: no combat spot is placed or enabled; the `N`/`H` NPCs sit inside house_a without blocking the door column x = 27.
- [x] The whole critical path is walkable without a glyph (kabut open on flags set by talking, not casting).

## ASSUMED
- Back route to Segara Kidul (**ASSUMED** 2026-11-06, quests.md Gating v3.1): a south exit `X` (30..31,33) to `sk_pantai`, drawn into the map now. The kabut `x` (30..31,32) lifts on `flag:mq4_2` (the Ibu talk, step 4.2), not on a boss. The arrival spawn from the coast is `y` (`from_sk_pantai`). The position (centre of the south edge, open grass, 2 tiles clear of the pond) is **ASSUMED**.
- Interlude landing (**ASSUMED**): the riders' `goto` targets spawn `z` (`from_riders`, 27,19) on the road 2 tiles from Ibu's door. quests.md 7.1 does not name the spawn id.
- Interlude table (**ASSUMED**): Ciung `N` and Hariang `H` are plain NPC spots inside house_a with `cond:"flag:mq4_2,!flag:mq4_9"`; the `quiet_house` beat plays their meeting, they do not need dialogue files of their own. The Hunter's empty mask is a codex pickup `m` (`hunter_mask`, id ASSUMED). The cups are Ibu's dialogue, not a spot.
- Gua Kala gate (**ASSUMED** 2026-11-06): kabut `k` lifts on flag `mq4_9` (set by step 4.9, which completes MQ4) because `kabut.gd` reads only `Game.flags`, so `quest:mq4=done` cannot be written there. The same fog is the Interlude's "eats every glyph" dressing; no extra mechanic.
- Lontar (**ASSUMED**): `L` is a floor pickup on the burned stage at (45,8), clear of Ki Wangsa `G` (42,5) and trigger `T` (42,7). Step 0.4 completes on `area_entered:wayang_stage` as in quests.md; the pickup is the visible deed and its `item_picked:laras_lontar` unlocks Semar's Ka entry together with `mq0_5`.
- Spawn ids (**ASSUMED** 2026-11-05, renamed for the area graph in [world.md](../world.md) World structure; the code still uses `from_sunda`/`from_mataram` until the Part B rebuild): `start`, `from_ts_kebun` (arrival from Tatar Sunda), `from_kg_alun` (the east exit goes to Keraton Galuh, not Mataram). Exit targets: `{target_zone:"ts_kebun", spawn_id:"from_desa_purwa"}`, `{target_zone:"kg_alun", spawn_id:"from_desa_purwa"}`.
- Trigger ids `wayang_stage` and `sanggar_enter`. Marker ids above. Dialogue by Semar for 0.2, 0.3, 0.4 happens in the sanggar.
- Wayang stage is a trigger plus Ki Wangsa NPC, no extra scene.
- Gua Kala entry (**ASSUMED** 2026-11-05, gua_kala.md P0 decisions): a north-edge exit `J` at (52..53,0) to `gk_mulut`, behind kabut `k` on `mq4_9` (set by step 4.9, `quest:mq4=done`; quests.md Gating v3.1). Spawn `j` is the arrival from the cave mouth, `u` the arrival home after the final boss.
- The west gate to Tatar Sunda has no kabut (quests.md: only the Galuh gate is fogged until `mq1_10`).

## Open questions
1. MQ0 0.1 (prologue) and 0.2 (class choice) come before the player is at `start`, if the player appears at `start` after class choice. Is the prologue played in a separate scene before this zone, with the stage trigger `T` only for SQ-D1 replays? The map supports both.
2. Does Semar teach Ka inside the sanggar (as drawn) or at the plaza? Moving him is a one-char change.

## Doc conflicts found
- Resolved 2026-11-06 (consistency pass): world.md now gates the hub to Gua Kala on `quest:mq4=done` (`mq4_9`) and the hub to `sk_pantai` on `mq4_2`; quests.md 7.1 and script.md name the `goto` spawn `from_riders`; world.md no longer lists `sk_desa`/`sk_hutan`; `tt_pesisir` to `sk_karang` opens on `mq4_9` only.
- `entities/world/kabut.gd` reads only `Game.flags`, so a gate written `quest:mq4=done` needs the flag `mq4_9` (used here) or kabut support for `Game.check` conds.
- Item id `laras_lontar` is now in items.md (Main-path quest items); the codex id `hunter_mask` has a row in script.md section 13 and still needs its `data/codex` file.
