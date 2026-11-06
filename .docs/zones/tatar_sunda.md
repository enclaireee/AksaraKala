# Tatar Sunda (region `tatar_sunda`, 8 areas), Act 1

Zone design on paper. Step 1 of the world design workflow ([AGENTS.md](../../AGENTS.md) section 5). Sources: [world.md](../world.md), [bestiary.md](../bestiary.md) (roster, Encounters, Glyph weaknesses), [quests.md](../quests.md) (MQ1, SQ-S1 to SQ-S4, marker rules). A builder turns each area section into one scene without redesign: change the layout here first.

Tatar Sunda is no longer one 120 x 51 zone. It is a region of 8 interlocking areas (scenes), each 60 x 34 tiles = 2 x 2 screens (30 x 17 each). Coordinates are (x, y) from the top-left tile (0,0) of that area. Area ids use the prefix `ts_`. The links between areas are topological, not a literal screen grid. The old single-zone id `tatar_sunda` stays only as the region name.

Design goals (Bloodborne-style): loops that come back on themselves, shortcuts that open from the far side, one one-way drop, and a boss landmark that is seen from the first area. Tone stays warm and forgiving: no enemies in the village, no fight between the last petilasan and the boss, shortcuts only save time.

Build rule: a char may repeat only when scene and props are identical (2-tile exit, 2-tile kabut, 2-tile shortcut gate). Every other char is one spot with the floor tile listed under it (paint the floor first, then place the spot).

Spawn ids follow `from_<other area id>`. A spawn is 1 tile, 1 to 2 tiles inside its exit. Exits sit on the map edge, 2 tiles wide.

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

## Area graph
`--` a two-way link, `=K=`/`=G=`/`=H=` a kabut gate, `~~sc~~` a shortcut (a gate that opens from the far side, then stays open), `..>` a one-way drop. Desa Purwa and Segara Kidul are outside the region.
```
 [Desa Purwa]
      |
 [ts_kebun] P1 ~~sc:ts_pagar~~ [ts_leuweung]   (lane, batu tulis grove, dark grove, spring, alcove)
      |        (gate in kebun)       |
      |                             =G= mq1_3
 [ts_kampung] -----------------------+
   |    |    ^                 ^
   |    |    : sc:ts_tangga    : drop landing
   |    |    : (gate in kampung)
   |    |    :                 :
   |   =H= mq1_5              :
   |    |    :                 :
   |  [ts_sawah]               :
   |    |    :                 :
   |    +--[ts_situ] ~~sc:ts_sk~~ [Segara Kidul sk_tebing]
   |         |  (gate in situ, closed in Phase 4)
   |        =K= mq1_7
   |         |
 [ts_leuwi]  [ts_kawah_jalan] P2 ..> (drop to ts_kampung)
 Sandekala        |
                  +--[ts_kawah]  BOSS Sangkuriang
```
The graph as plain edges: kebun-kampung, kampung-leuweung (G), kampung-sawah (H), kampung-leuwi, sawah-situ, situ-jalan (K), jalan-kawah, plus shortcuts leuweung-kebun and situ-kampung, plus the drop jalan to kampung.

Area sizes: all eight areas are 60 x 34 (2 x 2 screens). ASSUMED (the brief prefers 60 x 34).

## Link table
Every link needs an exit and a spawn on both ends (the drop has the exit on one end and a landing spawn on the other, no exit back). Spawn column: the spawn id on each end, arriving from the other side.

| from | to | kind | gate flag | spawn ids (arrival in each area) |
|------|----|------|-----------|-----------------------------------|
| `desa_purwa` | `ts_kebun` | link | - | `from_desa_purwa` in ts_kebun; `from_ts_kebun` in desa_purwa (ASSUMED rename) |
| `ts_kebun` | `ts_kampung` | link | - | `from_ts_kebun` in ts_kampung; `from_ts_kampung` in ts_kebun |
| `ts_kampung` | `ts_leuweung` | link | `mq1_3` | `from_ts_kampung` in ts_leuweung; `from_ts_leuweung` in ts_kampung |
| `ts_kampung` | `ts_sawah` | link | `mq1_5` | `from_ts_kampung` in ts_sawah; `from_ts_sawah` in ts_kampung |
| `ts_kampung` | `ts_leuwi` | link | - | `from_ts_kampung` in ts_leuwi; `from_ts_leuwi` in ts_kampung |
| `ts_sawah` | `ts_situ` | link | - | `from_ts_sawah` in ts_situ; `from_ts_situ` in ts_sawah |
| `ts_situ` | `ts_kawah_jalan` | link | `mq1_7` | `from_ts_situ` in ts_kawah_jalan; `from_ts_kawah_jalan` in ts_situ |
| `ts_kawah_jalan` | `ts_kawah` | link | - | `from_ts_kawah_jalan` in ts_kawah; `from_ts_kawah` in ts_kawah_jalan |
| `ts_leuweung` | `ts_kebun` | shortcut | `sc:ts_pagar` | `from_ts_leuweung` in ts_kebun (pocket); `from_ts_kebun` in ts_leuweung |
| `ts_situ` | `ts_kampung` | shortcut | `sc:ts_tangga` | `from_ts_situ` in ts_kampung (pocket); `from_ts_kampung` in ts_situ |
| `ts_situ` | `sk_tebing` | shortcut | `sc:ts_sk` | `from_sk_tebing` in ts_situ (pocket); `from_ts_situ` in sk_tebing (pending, Phase 5) |
| `ts_kawah_jalan` | `ts_kampung` | drop | - | `from_ts_kawah_jalan` in ts_kampung (landing); no exit and no spawn back |

Note: in two-way links the exit in area A has `spawn_id: "from_<A>"` and lands on the spawn `from_<A>` in area B.

## Shortcut table
A shortcut gate sits on a link corridor in the gate area. The pocket (exit, spawn, 2 tiles, gate) is on the open side. `open_side` points toward the pocket. The partner area has a normal exit and spawn pair. The gate opens when the player walks up to it from the open side, and then stays open (saved by id).

| id | gate area | open side | pocket (tiles) | opened from | leads back to petilasan |
|----|-----------|-----------|----------------|-------------|-------------------------|
| `sc:ts_pagar` | `ts_kebun` | `w` | (1..2, 26..27) | ts_leuweung, via the grove south path and corridor (no dark grove) | `sunda_1`: the pocket road reaches P (14,16) in the same area, about 20 tiles |
| `sc:ts_tangga` | `ts_kampung` | `n` | (10..11, 1..2) | ts_situ, by the ladder | `sunda_1`: one link (ts_kampung to ts_kebun) |
| `sc:ts_sk` | `ts_situ` | `e` | (57..58, 20..21) | `sk_tebing` in Segara Kidul only. Closed in Phase 4 (the Phase 5 end is pending, see Open questions) | `sunda_2`: one link (ts_situ to ts_kawah_jalan) |

## Loops
- **L1 fence loop**: ts_kebun -> ts_kampung -> (G) ts_leuweung -> grove east end -> south path -> south corridor -> `sc:ts_pagar` pocket -> ts_kebun. Opens the first shortcut.
- **L2 ladder loop**: ts_kampung -> (H) ts_sawah -> ts_situ -> `sc:ts_tangga` -> ts_kampung. Skips the whole sawah climb on every later trip.
- **L3 crater loop**: ts_kampung -> ts_sawah -> ts_situ -> (K) ts_kawah_jalan -> drop -> ts_kampung. After the boss, or a death run past the crater, the drop returns the player to the village in seconds.

Optional areas branch off loop nodes only: ts_leuwi (Sandekala) off ts_kampung; the dark grove, hidden spring and alcove off ts_leuweung (L1); the Kujang room off ts_situ (L2/L3).

## Critical path
ts_kebun (E1, P1, Cepot) -> ts_kampung (Abah Karna, Ga) -> `G` -> ts_leuweung (lane E2, grove E3, batu tulis Nga) -> back to ts_kampung (by the lane, or the south path (40..41,20..30) and south corridor to the pagar pocket, never through the dark grove, which opens `sc:ts_pagar`) -> `H` -> ts_sawah (E4, E5, weaver) -> ts_situ (Dayang Sumbi, Ca) -> `K` -> ts_kawah_jalan (E7) -> P2 -> ts_kawah (Sangkuriang) -> return: P2 -> drop -> ts_kampung -> ts_kebun -> Desa Purwa. No glyph is needed as a key: kabut open on quest flags set by talking and reading, never by casting. Glyphs are rewards.

Off the path: Sandekala (ts_leuwi), the dark grove elite, the hidden spring, the alcove, the Kujang room, 5 angklung, 3 chests, the codex.

## Landmark
The Tangkuban Perahu silhouette (the overturned-boat mountain). It is a backdrop art layer, not a map tile. It is visible in the sky of ts_kebun (small, far north) and grows through ts_sawah, ts_situ and ts_kawah_jalan until it fills ts_kawah, where the boss waits at its foot. The player sees the goal from the first screen and finds the way to it by loops. ASSUMED, art layer, one sprite scaled per area.

## Area 1: ts_kebun

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Open tea terraces and a bamboo fence, afternoon light. The Tangkuban Perahu silhouette fills the north sky.
- Purpose: Arrival from Desa Purwa, first teach fight (E1), petilasan 1 with Cepot, and the hub for loop L1. Holds the gate of shortcut `sc:ts_pagar`.

### Map
```
################%%##########################################
#...............@,.........................................#
#..tttttttttt...,,.........................................#
#..tttttttttt...,,....ttttttttttttttttttttttttttttttttttt..#
#..tttttttttt...,,....ttttttttttttttttttttttttttttttttttt..#
#..tttttttttt...,,....ttttttttttttttttttttttttttttttttttt..#
#..tttttttttt...,,....ttttttttttttttttttttttttttttttttttt..#
#..tttttttttt...,,....ttttttttttttttttttttttttttttttttttt..#
#..tttttttttt...,,....ttttttttttttttttttttttttttttttttttt..#
#..tttttttttt...,,....ttttttttttttttttttttttttttttttttttt..#
#...............,,...................bbb...................#
#...............,,...................bbb..........bbbb.....#
#......bbb......,,........w..........bbb..........bbbb.....#
#......bbb......,,..........w.....................bbbb.....#
#......bbb......,,.........................................#
#...............,,.........................................#
#.............P,,,,,,,,,,,,,,,,,,,,,,,,,,,,,E,,,,,,,,,,,,,eX
#.............,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,X
#...........C.,,...........................................#
#.............,,........bbb...................bbb..........#
#.......r.....,,........bbb...rr..............bbb..........#
#.............,,........bbb...r...............bbb..........#
#.............,,..........w.w..............................#
#.............,,.............v.........................1...#
#.............,,...........................................#
####..........,,....ttttttttttttttttttttttttttttttttt......#
&!,=,,,,,,,,,,,,....ttttttttttttttttttttttttttttttttt..bbb.#
&,,=,,,,,,,,,,,,....ttttttttttttttttttttttttttttttttt..bbb.#
####................tttttttttt2tttttttttttrtttttttttt..bbb.#
#...................ttttttttttttttttttttttttttttttttt..bbb.#
#...................ttttttttttttttttttttttttttttttttt......#
#...................ttttttttttttttttttttttttttttttttt......#
#..........................................................#
############################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to Desa Purwa (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"desa_purwa", spawn_id:"from_ts_kebun"}` | path | 2 |
| `e` | spawn, arrival from Desa Purwa | `res://entities/world/spawn.tscn` | `{id:"from_desa_purwa"}` | path | 1 |
| `%` | exit to ts_kampung (north edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_kampung", spawn_id:"from_ts_kebun"}` | path | 2 |
| `@` | spawn, arrival from ts_kampung | `res://entities/world/spawn.tscn` | `{id:"from_ts_kampung"}` | path | 1 |
| `&` | exit to ts_leuweung (west edge, behind the fence gate) | `res://entities/world/exit.tscn` | `{target_zone:"ts_leuweung", spawn_id:"from_ts_kebun"}` | path | 2 |
| `!` | spawn, arrival from ts_leuweung (in the pocket on the open side of `=`) | `res://entities/world/spawn.tscn` | `{id:"from_ts_leuweung"}` | path | 1 |
| `=` | shortcut gate, bamboo fence (opens from the west pocket, 2 tiles) | `res://entities/world/shortcut.tscn` | `{id:"sc:ts_pagar", open_side:"w"}` | path | 2 |
| `P` | petilasan 1 | `res://entities/petilasan/petilasan.tscn` | `{id:"sunda_1"}` | path | 1 |
| `C` | NPC Cepot (SQ-S4 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"cepot"}` | grass | 1 |
| `1` | angklung 1 | `res://entities/world/pickup.tscn` | `{item_id:"angklung_1"}` | grass | 1 |
| `2` | angklung 2 | `res://entities/world/pickup.tscn` | `{item_id:"angklung_2"}` | tea terrace | 1 |
| `E` | encounter sunda_edge | `res://entities/world/encounter.tscn` | `{area_id:"sunda_edge", size:Vector2i(22,10), waves:[[[res://entities/enemies/kuntilanak.tscn, Vector2i(-10,0)], [res://entities/enemies/faceless.tscn, Vector2i(-5,-2)], [res://entities/enemies/faceless.tscn, Vector2i(-5,2)]]]}` | path | 1 |
| `w` | loose faceless, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/faceless.tscn` | `{}` | grass | 4 |
| `v` | loose faceless archer, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/faceless_archer.tscn` | `{}` | grass | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| entry road | (45,15)-(58,18) 14x4 | Arrival from Desa Purwa | exit `X` (59,16..17), spawn `e` (58,16) | mq0 0.7 `from_desa_purwa` |
| field | (33,10)-(57,24) 25x15 | Open field with bamboo cover, first teach fight | E1 `E` (44,16), angklung `1` (55,23) | `sunda_edge` |
| p1 | (10,13)-(19,22) 10x10 | Tea-edge rest, petilasan 1 | petilasan `P` (14,16), Cepot `C` (12,18) | 1.1 `sunda_1`, SQ-S4 `cepot` |
| north road | (16,1)-(17,15) 2x15 | Road to ts_kampung | exit `%` (16..17,0), spawn `@` (16,1) | none |
| south terraces | (20,25)-(52,31) 33x7 | Tea terrace, side pickup | angklung `2` (30,28) | SQ-S3 pickup |
| fence road | (1,26)-(15,27) 15x2 + (14,18)-(15,27) | Path to the west fence. Gate `=` (3,26..27) sits in it. The pocket (1..2,26..27) is the open side. | gate `=` `sc:ts_pagar` (open_side `w`), exit `&` (0,26..27), spawn `!` (1,26) | none |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `sunda_edge` | `E (44,16)` | 22x10 | W1: Kuntilanak (-10,+0), Faceless (-5,-2), Faceless (-5,+2) | Ka Bolt (Kuntilanak shriek) |

Roaming packs (loose enemies, `w` faceless, `v` archer): K1 2 faceless (26,12), (28,13); K2 2 faceless (26,22), (28,22) + archer (29,23). 5 kills, skirtable, 12+ tiles from P1.

## Area 2: ts_kampung

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Wooden houses, a pond, smoke and gamelan. Warm lantern light. No enemies anywhere in this area.
- Purpose: The hub. Five NPCs, three kabut-free branches and two kabut gates, the drop landing, and the gate of shortcut `sc:ts_tangga`. Loops L1, L2 and L3 all pass here.

### Map
```
##########^^################################################
#........#;,#..............................................#
#........#,,#..............................................#
#..bbbb..#++#.........................bbbb.................#
#..bbbb...,,........#######...........bbbb..#######........#
#..bbbb...,,........#_____#.....:.....bbbb..#_____#........#
#..bbbb...,,........#__U__#.....,.....bbbb..#_____#........#
#.........,,........#_____#.....,...........#_____#........#
#.........,,........#_____#.....,...........#_____#........#
#.........,,........###,###.....,...........###,###........#
#.........,,...........,........,..............,...........#
#.........,,...........,........,..............,...........#
#.........,,...........,..,,,,,,,,,,,,,,,......,...........#
#.........,,...........,..,,,,,,,,,,,,,,,......,...........#
#.........,,...........,..,,,,,,,,V,,,,,,......,...........#
##########,,...........,..,,,,,,,,,,,,,,,......,..##########
&!,,,,G,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,H,,,?$
&,,,,,G,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,H,,,,$
##########......,,........,,,,,,,,,,,,,,,...,,....##########
#...............,,........,,I,,,,,,,,,,L,...,,.............#
#............r..,,........,,,,,,,,,,,,,,,...,,.............#
#...............,,........,,,,,,,,,,,,,,,...,,....#######..#
#..#######......,,...............,..........,,....#_____#..#
#..#_____#......,,...............,..........,,,,,,,_____#..#
#..#_____,,,,,,,,,.A..........###,####......,,....#_____#..#
#..#_____#......,,............#______#......,,....#_____#..#
#..#_____#......,,............#______#......,,....#######..#
#..#######......,,............#______#......,,.............#
#.............r.,,..bbbbb.....#______#..r...,,......bbbbb..#
#..~~~~~~.......,,..bbbbb.....########......,,......bbbbb..#
#..~~~~~~.......,,..bbbbb...................,,......bbbbb..#
#..~~~~~~.......,,..bbbbb...................,,......bbbbb..#
#...............e,..........................@,.............#
################XX##########################%%##############
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to ts_kebun (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_kebun", spawn_id:"from_ts_kampung"}` | path | 2 |
| `e` | spawn, arrival from ts_kebun | `res://entities/world/spawn.tscn` | `{id:"from_ts_kebun"}` | path | 1 |
| `%` | exit to ts_leuwi (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_leuwi", spawn_id:"from_ts_kampung"}` | path | 2 |
| `@` | spawn, arrival from ts_leuwi | `res://entities/world/spawn.tscn` | `{id:"from_ts_leuwi"}` | path | 1 |
| `&` | exit to ts_leuweung (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_leuweung", spawn_id:"from_ts_kampung"}` | path | 2 |
| `!` | spawn, arrival from ts_leuweung | `res://entities/world/spawn.tscn` | `{id:"from_ts_leuweung"}` | path | 1 |
| `$` | exit to ts_sawah (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_sawah", spawn_id:"from_ts_kampung"}` | path | 2 |
| `?` | spawn, arrival from ts_sawah | `res://entities/world/spawn.tscn` | `{id:"from_ts_sawah"}` | path | 1 |
| `^` | exit to ts_situ (north edge, up the ladder, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_situ", spawn_id:"from_ts_kampung"}` | path | 2 |
| `;` | spawn, arrival from ts_situ (in the pocket on the open side of `+`) | `res://entities/world/spawn.tscn` | `{id:"from_ts_situ"}` | path | 1 |
| `:` | spawn, landing of the drop from ts_kawah_jalan (no exit back) | `res://entities/world/spawn.tscn` | `{id:"from_ts_kawah_jalan"}` | path | 1 |
| `+` | shortcut gate, ladder (opens from the north pocket, 2 tiles) | `res://entities/world/shortcut.tscn` | `{id:"sc:ts_tangga", open_side:"n"}` | path | 2 |
| `G` | kabut, west gate to ts_leuweung (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq1_3"}` | path | 2 |
| `H` | kabut, east gate to ts_sawah (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq1_5"}` | path | 2 |
| `A` | NPC Abah Karna, elder, teaches Ga | `res://entities/npc/npc.tscn` | `{npc_id:"sunda_elder"}` | grass | 1 |
| `I` | NPC Ki Darsa, juru pantun (SQ-S1 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"ki_darsa"}` | path | 1 |
| `V` | NPC kepala desa (SQ-S2 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"kepala_desa"}` | path | 1 |
| `L` | NPC angklung group leader (SQ-S3 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"angklung_leader"}` | path | 1 |
| `U` | NPC Purbasari (SQ-S1), in her hut | `res://entities/npc/npc.tscn` | `{npc_id:"purbasari"}` | floor | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| plaza | (26,12)-(40,21) 15x10 | Village square, three quest givers | Ki Darsa `I` (28,19), kepala desa `V` (34,14), angklung leader `L` (39,19) | SQ-S1, SQ-S2, SQ-S3 givers |
| garden | (14,18)-(25,27) 12x10 | Elder's garden on the way from the south gate | Abah Karna `A` (19,24) | 1.2, 1.3 `sunda_elder` |
| hut N1 | (20,4)-(26,9) 7x6 | Purbasari's hut, door (23,9) | Purbasari `U` (23,6) | SQ-S1 `purbasari` |
| huts | (44,4)-(50,9), (3,22)-(9,27), (30,24)-(37,29), (50,21)-(56,26) | Four dressing houses, doors at (47,9), (9,24), (33,24), (50,23) | none | none |
| pond | (3,29)-(8,31) 6x3 | Dressing pond | water only | none |
| west walk | (1,16)-(9,17) 9x2 | Walk to ts_leuweung | kabut `G` (6,16..17) flag `mq1_3`, exit `&` (0,16..17), spawn `!` (1,16) | 1.3 opens `G` |
| east walk | (55,16)-(58,17) 4x2 | Walk to ts_sawah | kabut `H` (54,16..17) flag `mq1_5`, exit `$` (59,16..17), spawn `?` (58,16) | 1.5 opens `H` |
| south gates | (16,32)-(17,33), (44,32)-(45,33) | Arrival from ts_kebun and from ts_leuwi | exit `X` (16..17,33), spawn `e` (16,32), exit `%` (44..45,33), spawn `@` (44,32) | none |
| ladder | (10,1)-(11,15) 2x15 | Path north to the ladder. Gate `+` (10..11,3). The pocket (10..11,1..2) is the open side. | gate `+` `sc:ts_tangga` (open_side `n`), exit `^` (10..11,0), spawn `;` (10,1) | none |
| drop landing | (32,5)-(32,11) 1x7 | Landing path of the one-way drop | spawn `:` (32,5) | none |

### Encounters
None.

## Area 3: ts_leuweung

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Tall bamboo and moss, green dusk light. Quiet and a little eerie. The dark grove is darker, but never harsh.
- Purpose: Boar lane and batu tulis grove (Nga) on the path, plus the optional dark grove, hidden spring and alcove. A south path from the grove's east end (gap (40..41,20..30)) joins the south corridor to the pagar pocket in ts_kebun, which opens `sc:ts_pagar`. The dark grove is a side room and is never on that route.

### Map
```
############################################################
############################################################
############.....###########################################
############..c..###########################################
############.....###########################################
#############r.r############################################
##...........................................###############
##............................bbbb...........###############
##.....Y......................bbbb.......y...###############
##............................bbbb.........y.###############
##............T,,,R,,,........bbbb...........###############
##..................,,..............bbbb.....###############
##...bbbb...........,,..............bbbb.....###############
##...bbbb...........,,..............bbbb.....###############
##...bbbb...........,,......r.......bbbb.....###############
##...bbbb...........,,.......................###############
##..................,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,F,,,,,eX
##........r.........,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,X
##...4...............................h.......###############
##...............................w.w.........###############
##############,,#####################bbb,,bbbbbbbbbbbbbbbbb#
###.......................###.......#bbb,,bbbbbbbbbbbbbbbbb#
###.......................###.......#bbb,,bbbbbbbbbbbbbbbbb#
###..bbbb..........bbbb...###...N...#bbb,,bbbbbbbbbbbbbbbbb#
###..bbbb..........bbbb...r##..~~~..#bbb,,bbbbbbbbbbbbbbbbb#
###..bbbb..........bbbb...,,,..~~~..#bbb,,bbbbbbbbbbbbbbbbb#
###..bbbb.....d....bbbb...r##..~~~..#bbb,,bbbbbbbbbbbbbbbbb#
###.......................###...u...#bbb,,bbbbbbbbbbbbbbbbb#
###...........q...........###.a.....#bbb,,bbbbbbbbbbbbbbbbb#
###...bbbb................###.......#bbb,,bbbbbbbbbbbbbbbbb#
###...bbbb................##############,,##################
###...bbbb................,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@%
###.......................,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,%
############################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to ts_kampung (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_kampung", spawn_id:"from_ts_leuweung"}` | path | 2 |
| `e` | spawn, arrival from ts_kampung | `res://entities/world/spawn.tscn` | `{id:"from_ts_kampung"}` | path | 1 |
| `%` | exit to ts_kebun (east edge, the shortcut link, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_kebun", spawn_id:"from_ts_leuweung"}` | path | 2 |
| `@` | spawn, arrival from ts_kebun | `res://entities/world/spawn.tscn` | `{id:"from_ts_kebun"}` | path | 1 |
| `F` | encounter sunda_boarlane | `res://entities/world/encounter.tscn` | `{area_id:"sunda_boarlane", size:Vector2i(11,3), waves:[[[res://entities/enemies/wild_boar.tscn, Vector2i(-4,0)], [res://entities/enemies/wild_boar.tscn, Vector2i(-4,1)]]]}` | path | 1 |
| `R` | encounter sunda_batutulis | `res://entities/world/encounter.tscn` | `{area_id:"sunda_batutulis", size:Vector2i(20,12), waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-3,-3)], [res://entities/enemies/faceless.tscn, Vector2i(3,3)], [res://entities/enemies/kuntilanak.tscn, Vector2i(7,-4)]]]}` | path | 1 |
| `T` | batu tulis stone, teaches Nga (MQ1 1.5) | `res://entities/npc/npc.tscn` | `{npc_id:"batu_tulis"}` | path | 1 |
| `Y` | NPC Lutung Kasarung spirit (SQ-S1) | `res://entities/npc/npc.tscn` | `{npc_id:"lutung_kasarung"}` | grass | 1 |
| `4` | angklung 4 | `res://entities/world/pickup.tscn` | `{item_id:"angklung_4"}` | grass | 1 |
| `c` | chest: Iron Ring (secret 3, alcove) | `res://entities/world/chest.tscn` | `{chest_id:"sunda_ironring", item_id:"iron_ring"}` | grass | 1 |
| `q` | elite Kuntilanak (SQ-S2) | `res://entities/enemies/kuntilanak_elite.tscn` | `{}` | grass | 1 |
| `d` | trigger, dark grove entered (darkens arena, SQ-S2) | `res://entities/world/trigger.tscn` | `{trigger_id:"dark_grove", size:Vector2i(22,10)}` | grass | 1 |
| `N` | encounter sunda_spring | `res://entities/world/encounter.tscn` | `{area_id:"sunda_spring", size:Vector2i(7,9), waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-2,0)], [res://entities/enemies/faceless.tscn, Vector2i(2,0)], [res://entities/enemies/kuntilanak.tscn, Vector2i(-2,4)]]]}` | grass | 1 |
| `u` | trigger, spring bath (Purbasari delivered) | `res://entities/world/trigger.tscn` | `{trigger_id:"spring_bath", size:Vector2i(5,3)}` | grass | 1 |
| `a` | chest: Leather Armor (secret 2, hidden spring) | `res://entities/world/chest.tscn` | `{chest_id:"sunda_leather", item_id:"leather_armor"}` | grass | 1 |
| `y` | loose wild boar, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/wild_boar.tscn` | `{}` | grass | 2 |
| `w` | loose faceless, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/faceless.tscn` | `{}` | grass | 2 |
| `h` | loose kuntilanak, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/kuntilanak.tscn` | `{}` | grass | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| lane | (45,16)-(58,17) 14x2 | Straight boar lane, east entry | E2 `F` (52,16), exit `X` (59,16..17), spawn `e` (58,16) | `sunda_boarlane` |
| grove | (2,6)-(44,19) 43x14 | Batu tulis grove, bamboo cover | batu tulis `T` (14,10), E3 `R` (18,10), Lutung Kasarung `Y` (7,8), angklung `4` (5,18) | 1.4 `sunda_batutulis`, 1.5 `batu_tulis`, SQ-S1 `lutung_kasarung` |
| alcove | (12,2)-(16,4) 5x3 | Secret 3, behind rocks (13,5) and (15,5), gap (14,5) | chest Iron Ring `c` (14,3) | none |
| dark grove | (3,21)-(25,32) 23x12 | Dark bamboo grove, elite Kuntilanak (SQ-S2), optional side room. Two own gaps: (14..15,20) from the grove and (25,31..32) from the corridor. Trigger rect (3..24,21..30) does not touch the corridor rows. | trigger `d` (14,26), elite `q` (14,28) | SQ-S2 `dark_grove`, `kuntilanak_elite` |
| tunnel | (26,25)-(28,25) 3x1 | Gap between rocks to the spring, shown by a faint light | none | none |
| spring | (29,21)-(35,29) 7x9 | Secret 2, hidden spring, Purbasari's bath | pond (31..33,24..26), E6 `N` (32,23), trigger `u` (32,27), chest Leather Armor `a` (30,28) | SQ-S1 `sunda_spring`, `spring_bath` |
| south path | (40,20)-(41,30) 2x11 | Own path from the grove east end down to the corridor, through the bamboo. The L1 route; no enemies. | none | none |
| south corridor | (26,31)-(58,32) 33x2 | Back route to the ts_kebun fence pocket. Its west end is a side gap into the dark grove | spawn `@` (58,31), exit `%` (59,31..32) | none |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `sunda_boarlane` | `F (52,16)` | 11x3 | W1: Wild Boar (-4,+0), Wild Boar (-4,+1) | Ga Ward (Boar dash) |
| `sunda_batutulis` | `R (18,10)` | 20x12 | W1: Faceless (-3,-3), Faceless (+3,+3), Kuntilanak (+7,-4) | Ka Bolt (Kuntilanak) |
| `sunda_spring` | `N (32,23)` | 7x9 | W1: Faceless (-2,+0), Faceless (+2,+0), Kuntilanak (-2,+4) | Ka Bolt (Kuntilanak) |

Roaming packs (loose, respawn like bonfire enemies): L1 2 boars `y` (41,8), (43,9) (Ga is known, gate `mq1_3` passed); L2 2 faceless `w` (33,19), (35,19) + kuntilanak `h` (37,18) beside the lane. 5 kills.

## Area 4: ts_leuwi

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: A dark, damp cave-like hollow under the village roots. Cold blue light, oncor lanterns.
- Purpose: Optional dead end off ts_kampung: the Sandekala miniboss room, 23x12 with a four-oncor ring. No other exit.

### Map
```
############################################XX##############
############################################e,##############
############################################,,##############
############################################,,##############
############################################,,##############
############################################,,##############
############################################,,##############
############################################,,##############
######################,,,,,,,,,,,,,,,,,,,,,,,,##############
######################,,,,,,,,,,,,,,,,,,,,,,,,##############
######################,,####################################
######################,,####################################
######################,,####################################
######################,,####################################
######################,,####################################
######################,,####################################
######################,,####################################
######################,,####################################
######################,,####################################
############r.....................r#########################
############...........j...........#########################
############....m.............n....#########################
############.......................#########################
############.......................#########################
############...........S...........#########################
############.......................#########################
############.......................#########################
############.......................#########################
############....p.............s....#########################
############.......................#########################
############r.....................r#########################
############################################################
############################################################
############################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to ts_kampung (north edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_kampung", spawn_id:"from_ts_leuwi"}` | path | 2 |
| `e` | spawn, arrival from ts_kampung | `res://entities/world/spawn.tscn` | `{id:"from_ts_kampung"}` | path | 1 |
| `S` | miniboss Sandekala | `res://entities/bosses/sandekala.tscn` | `{}` | grass | 1 |
| `m` | oncor NW | `res://entities/bosses/oncor.tscn` | `{oncor_id:"nw"}` | grass | 1 |
| `n` | oncor NE | `res://entities/bosses/oncor.tscn` | `{oncor_id:"ne"}` | grass | 1 |
| `p` | oncor SW | `res://entities/bosses/oncor.tscn` | `{oncor_id:"sw"}` | grass | 1 |
| `s` | oncor SE | `res://entities/bosses/oncor.tscn` | `{oncor_id:"se"}` | grass | 1 |
| `j` | trigger, Sandekala room entered (starts darkening) | `res://entities/world/trigger.tscn` | `{trigger_id:"sande_room", size:Vector2i(21,10)}` | grass | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| passage | (44,1)-(45,9), (22,8)-(45,9), (22,10)-(23,18) | Long winding approach, no enemies | exit `X` (44..45,0), spawn `e` (44,1) | none |
| sande room | (12,19)-(34,30) 23x12 | Sandekala miniboss, optional | Sandekala `S` (23,24), oncor `m` (16,21) `n` (30,21) `p` (16,28) `s` (30,28), trigger `j` (23,20) | `sandekala` |

### Encounters
None.

## Area 5: ts_sawah

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Terraced tea fields climbing the slope, sunny, long sight lines. A stone clearing to the west.
- Purpose: Behind kabut `H`. Jurig teach clearing (E4), the hunting-party terraces (E5), the weaver (boeh rarang), and the north corridor up to ts_situ.

### Map
```
##############################%%############################
##############################@,############################
##############################,,############################
##############################,,############################
##############################,,############################
##############################,,############################
##############################,,############################
##############################,,############################
##############################,,############################
##############################,,############################
####.........#################,,############################
####..r......#################,,############################
####.........#################,,############################
####.........#################,,############################
####.........####tttttttttttttttttttttttttttttttttttt#######
####....J....####tt#######ttttttttttttttttttttttttttt#######
Xe,,.........,,,,tt#_____#tttttttttttttttttttttttt3tt#######
X,,,.........,,,,tt#__W__#ttttttttttttttttttttttttttt#######
####.......r.####tt#_____#ttttttttttttttttttttttttttt#######
####.........####tt#_____#ttttttttttttttttttttttttjtt#######
#################tt###,###ttttttttttttttttttttttttttt#######
#################tttttttttttttttttttMttttttttttttttit#######
#################tttttttttttttttttttttttttttttttttttt#######
#################tttrrttttttttttttttttttttttttttttttt#######
#################tttttttttttttttttttttttttttttrrttttt#######
#################tttttttttttttttttttttttttttttttttttt#######
#################tttttttttttttttttttttttttttttttttttt#######
############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to ts_kampung (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_kampung", spawn_id:"from_ts_sawah"}` | path | 2 |
| `e` | spawn, arrival from ts_kampung | `res://entities/world/spawn.tscn` | `{id:"from_ts_kampung"}` | path | 1 |
| `%` | exit to ts_situ (north edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_situ", spawn_id:"from_ts_sawah"}` | path | 2 |
| `@` | spawn, arrival from ts_situ | `res://entities/world/spawn.tscn` | `{id:"from_ts_situ"}` | path | 1 |
| `J` | encounter sunda_clearing | `res://entities/world/encounter.tscn` | `{area_id:"sunda_clearing", size:Vector2i(9,10), waves:[[[res://entities/enemies/jurig_leuweung.tscn, Vector2i(3,0)], [res://entities/enemies/faceless.tscn, Vector2i(2,-3)], [res://entities/enemies/faceless.tscn, Vector2i(2,3)]]]}` | path | 1 |
| `M` | encounter sunda_terraces | `res://entities/world/encounter.tscn` | `{area_id:"sunda_terraces", size:Vector2i(24,11), waves:[[[res://entities/enemies/wild_boar.tscn, Vector2i(6,0)], [res://entities/enemies/jurig_leuweung.tscn, Vector2i(-3,-3)], [res://entities/enemies/faceless_archer.tscn, Vector2i(4,-4)], [res://entities/enemies/faceless.tscn, Vector2i(-4,2)]], [[res://entities/enemies/faceless.tscn, Vector2i(-8,-3)], [res://entities/enemies/faceless.tscn, Vector2i(8,3)], [res://entities/enemies/wild_boar.tscn, Vector2i(8,-3)]]]}` | tea terrace | 1 |
| `W` | NPC weaver, gives boeh rarang (MQ1 1.6) | `res://entities/npc/npc.tscn` | `{npc_id:"sunda_weaver"}` | floor | 1 |
| `3` | angklung 3 | `res://entities/world/pickup.tscn` | `{item_id:"angklung_3"}` | tea terrace | 1 |
| `j` | loose faceless (terrace), roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/faceless.tscn` | `{}` | tea terrace | 1 |
| `i` | loose Jurig Leuweung (terrace), roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/jurig_leuweung.tscn` | `{}` | tea terrace | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| clearing | (4,10)-(12,19) 9x10 | Jurig teach clearing | E4 `J` (8,15) | `sunda_clearing` |
| link | (13,16)-(16,17) 4x2 | Path from clearing to terraces | none | none |
| terraces | (17,14)-(52,26) 36x13 | Tea terraces, hunting party | E5 `M` (36,21), angklung `3` (50,16) | `sunda_terraces` |
| weaver house | (19,15)-(25,20) 7x6 | Weaver's house, door (22,20) | weaver `W` (22,17) | 1.6 `sunda_weaver` |
| north corridor | (30,1)-(31,13) 2x13 | Corridor up to ts_situ | exit `%` (30..31,0), spawn `@` (30,1) | none |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `sunda_clearing` | `J (8,15)` | 9x10 | W1: Jurig Leuweung (+3,+0), Faceless (+2,-3), Faceless (+2,+3) | Nga Bind (Jurig) |
| `sunda_terraces` | `M (36,21)` | 24x11 | W1: Wild Boar (+6,+0), Jurig Leuweung (-3,-3), Faceless Archer (+4,-4), Faceless (-4,+2); W2: Faceless (-8,-3), Faceless (+8,+3), Wild Boar (+8,-3) | Nga Bind on Jurig, Ga Ward on Boar |

Roaming pack S1 east of the terraces, guarding angklung 3: faceless `j` (50,19) + Jurig `i` (51,21) (Nga is known, gate `mq1_5` passed). 2 kills. `sunda_terraces` also has a second wave (2 faceless + boar, +3 kills).

## Area 6: ts_situ

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: A still lake under the crater slope, pale light, ruins in the grass. The mountain is close and large.
- Purpose: Crossing point of loop L2 (ladder down to ts_kampung) and the gate to the crater path (kabut `K`). Dayang Sumbi, the codex ruin, the Kujang room, and the closed back door to Segara Kidul.

### Map
```
############################################################
############################################################
#######....................................................#
#######....................................................#
#######.......rr....~~~~~~~~~~~~~~~~~~~~~~~~~~~............#
#######.........r...~~~~~~~~~~~~~~~~~~~~~~~~~~~............#
#######.............~~~~~~~~~~~~~~~~~~~~~~~~~~~............#
#######.............~~~~~~~~~~~~~~~~~~~~~~~~~~~............#
&!,,,,K,,,,,,.......~~~~~~~~~~~~~~~~~~~~~~~~~~~............#
&,,,,,K,,,,,,.......~~~~~~~~~~~~~~~~~~~~~~~~~~~....#########
#######...dD........~~~~~~~~~~~~~~~~~~~~~~~~~~~....#.......#
#######.............~~~~~~~~~~~~~~~~~~~~~~~~~~~....r.......#
#######.............~~~~~~~~~~~~~~~~~~~~~~~~~~~.........k..#
#######............................................r.......#
#######.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#.......#
#######.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#.......#
#######.,,....................,,...................#########
#######.,,....................,,........r...r..............#
#######.,,5...................,,..........x................#
#######.,,....................,,........r...r...........####
#######.,,....................,,,,,,,,,,,,,,,,,,,,,,,,,,=,;$
#######.,,....................,,,,,,,,,,,,,,,,,,,,,,,,,,=,,$
#######.,,....................,,........................####
#######.,,....................,,...........................#
#######.,,........w...v.......,,...........................#
#######.,,....................,,...........................#
#######.,,....r.....w.........,,................r..........#
#######.,,.....r..............,,............y....r.........#
#######.,,....................,,...........................#
#######.,,....................,,..............y............#
#######.,,....................,,...........................#
#######.,,....................,,...........................#
#######.@,....................e,...........................#
########%%####################XX############################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to ts_sawah (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_sawah", spawn_id:"from_ts_situ"}` | path | 2 |
| `e` | spawn, arrival from ts_sawah | `res://entities/world/spawn.tscn` | `{id:"from_ts_sawah"}` | path | 1 |
| `%` | exit to ts_kampung (south edge, the ladder link, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_kampung", spawn_id:"from_ts_situ"}` | path | 2 |
| `@` | spawn, arrival from ts_kampung | `res://entities/world/spawn.tscn` | `{id:"from_ts_kampung"}` | path | 1 |
| `&` | exit to ts_kawah_jalan (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_kawah_jalan", spawn_id:"from_ts_situ"}` | path | 2 |
| `!` | spawn, arrival from ts_kawah_jalan | `res://entities/world/spawn.tscn` | `{id:"from_ts_kawah_jalan"}` | path | 1 |
| `$` | exit to Segara Kidul `sk_tebing` (east edge, 2 tiles, behind the gate) | `res://entities/world/exit.tscn` | `{target_zone:"sk_tebing", spawn_id:"from_ts_situ"}` | path | 2 |
| `;` | spawn, arrival from `sk_tebing` (in the pocket on the open side of `=`) | `res://entities/world/spawn.tscn` | `{id:"from_sk_tebing"}` | path | 1 |
| `=` | shortcut gate, back route to Segara Kidul (opens only from `sk_tebing`, 2 tiles) | `res://entities/world/shortcut.tscn` | `{id:"sc:ts_sk", open_side:"e"}` | path | 2 |
| `K` | kabut, crater path gate (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq1_7"}` | path | 2 |
| `D` | NPC Naganingrum, the woman by the lake, teaches Ca (MQ1 1.6), gone after MQ1 | `res://entities/npc/npc.tscn` | `{npc_id:"naganingrum", cond:"!quest:mq1=done"}` | grass | 1 |
| `d` | NPC Dayang Sumbi, gives SQ-S5 after MQ1 | `res://entities/npc/npc.tscn` | `{npc_id:"dayang_sumbi", cond:"quest:mq1=done"}` | grass | 1 |
| `x` | codex spot, ruin on the lake shore | `res://entities/world/pickup.tscn` | `{codex_id:"tangkuban_perahu"}` | grass | 1 |
| `5` | angklung 5 | `res://entities/world/pickup.tscn` | `{item_id:"angklung_5"}` | grass | 1 |
| `k` | chest: Kujang (secret 1) | `res://entities/world/chest.tscn` | `{chest_id:"sunda_kujang", item_id:"kujang"}` | grass | 1 |
| `w` | loose faceless, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/faceless.tscn` | `{}` | grass | 2 |
| `v` | loose faceless archer, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/faceless_archer.tscn` | `{}` | grass | 1 |
| `y` | loose wild boar, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/wild_boar.tscn` | `{}` | grass | 2 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| lake shore | (7,2)-(58,13) 52x12 | Shore ring around water (20..46,4..12) | Naganingrum `D` (11,10), Dayang Sumbi `d` (10,10) after MQ1, kabut `K` (6,8..9) flag `mq1_7` | 1.6 `naganingrum`, opens `K`; SQ-S5 `dayang_sumbi` |
| west gate | (1,8)-(5,9) 5x2 | Walk to ts_kawah_jalan | exit `&` (0,8..9), spawn `!` (1,8) | none |
| ruin | (40,17)-(44,19) 5x3 | Ruin ringed by four rocks, gaps at the diagonals | codex `x` (42,18) | codex `tangkuban_perahu` |
| south shore | (7,14)-(51,32) | Open shore and paths | angklung `5` (10,18), exit `%` (8..9,33) spawn `@` (8,32), exit `X` (30..31,33) spawn `e` (30,32) | none |
| kujang room | (52,10)-(58,15) 7x6 | Secret 1, behind rocks (51,11) and (51,13), gap (51,12) | chest Kujang `k` (56,12) | none |
| east corridor | (30,20)-(58,21) 29x2 | Corridor to Segara Kidul. Gate `=` (56,20..21). The pocket (57..58,20..21) is the open side. | gate `=` `sc:ts_sk` (open_side `e`), spawn `;` (58,20), exit `$` (59,20..21) | none |

### Encounters
No fixed encounter. Roaming packs: T1 south-west shore 2 faceless `w` (18,24), (20,26) + archer `v` (22,24); T2 south-east shore 2 boars `y` (44,27), (46,29). 5 kills, all skirtable, 8+ tiles from the path column and the spawn.

## Area 7: ts_kawah_jalan

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Black rock and mist, the crater path, red light on the cloud. The mountain fills the sky.
- Purpose: The last fight (E7), petilasan 2 right before the boss, and the one-way drop home. Entered through kabut `K` from ts_situ.

### Map
```
############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
###################rr..........................rr###########
###################rr.rrr...............rrrrr..rr###########
###################...rrr...............rrrrr....###########
###################..............................###########
###################..............................###########
#..........########..............................###########
#..........########..............................###########
#..........########..............................###########
%@,,,,Q,,,,,,,,,,,,,,,,,,,,,,,,,,,O,,,,,,,,,,,,,,,,,,,,,,,eX
%.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,X
#..........########..............................###########
#..........########..............................###########
#####,,############..............................###########
#####,,############..............................###########
#####,,############..rrr....................rrr..###########
#####,,############rrrrr....................rrrrr###########
#####,,############rr...............w..w.......rr###########
#####,,#####################################################
#####,,#####################################################
#####,,#####################################################
#####,,#####################################################
#####,,#####################################################
#####,,#####################################################
#####,,#####################################################
#####,,#####################################################
#####$$#####################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to ts_situ (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_situ", spawn_id:"from_ts_kawah_jalan"}` | path | 2 |
| `e` | spawn, arrival from ts_situ | `res://entities/world/spawn.tscn` | `{id:"from_ts_situ"}` | path | 1 |
| `%` | exit to ts_kawah (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_kawah", spawn_id:"from_ts_kawah_jalan"}` | path | 2 |
| `@` | spawn, arrival from ts_kawah | `res://entities/world/spawn.tscn` | `{id:"from_ts_kawah"}` | path | 1 |
| `$` | DROP exit to ts_kampung (south edge, 2 tiles, one-way) | `res://entities/world/exit.tscn` | `{target_zone:"ts_kampung", spawn_id:"from_ts_kawah_jalan"}` | path | 2 |
| `Q` | petilasan 2 | `res://entities/petilasan/petilasan.tscn` | `{id:"sunda_2"}` | path | 1 |
| `O` | encounter sunda_crater | `res://entities/world/encounter.tscn` | `{area_id:"sunda_crater", size:Vector2i(22,11), waves:[[[res://entities/enemies/jurig_leuweung.tscn, Vector2i(4,-2)], [res://entities/enemies/faceless.tscn, Vector2i(3,2)], [res://entities/enemies/wild_boar.tscn, Vector2i(-6,-1)], [res://entities/enemies/wild_boar.tscn, Vector2i(-6,1)]], [[res://entities/enemies/kuntilanak.tscn, Vector2i(-2,-4)], [res://entities/enemies/faceless.tscn, Vector2i(-2,4)]]]}` | path | 1 |
| `w` | loose faceless, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/faceless.tscn` | `{}` | grass | 2 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| east lane | (49,16)-(58,17) 10x2 | Entry lane from ts_situ | exit `X` (59,16..17), spawn `e` (58,16) | none |
| crater arena | (19,8)-(48,24) 30x17 | Crater floor, last fight, long boar lanes | E7 `O` (34,16) | `sunda_crater` |
| west lane | (11,16)-(18,17) 8x2 | Lane from the arena to P2 | none | none |
| p2 | (1,13)-(10,19) 10x7 | Petilasan 2, no enemies. The exit to ts_kawah is here. | petilasan `Q` (6,16), exit `%` (0,16..17), spawn `@` (1,16) | 1.8 `sunda_2` |
| drop corridor | (5,20)-(6,32) 2x13 | One-way drop south to ts_kampung | DROP exit `$` (5..6,33) | none |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `sunda_crater` | `O (34,16)` | 22x11 | W1: Jurig Leuweung (+4,-2), Faceless (+3,+2), Wild Boar (-6,-1), Wild Boar (-6,+1); W2: Kuntilanak (-2,-4), Faceless (-2,+4) | Nga Bind (Jurig), Ga Ward (Boars), Ca Burst (wave 2) |

Roaming pack J1 on the south side of the crater floor: 2 faceless `w` (36,24), (39,24), outside the `sunda_crater` rect. 2 kills. Nothing between P2 and the boss.

## Area 8: ts_kawah

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: The crater floor and the boss arena, red sky, Tangkuban Perahu overhead.
- Purpose: The boss arena. Entered only from ts_kawah_jalan by a straight causeway. No encounters, no petilasan (P2 is one link back).

### Map
```
############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
########r....................r##############################
########..........r.....r.....##############################
########......................##############################
########......................##############################
########......................##############################
########......................,,,,,,,,,,,,,,,,,,,,,,,,,,,,eX
########.......B.C.........Z..,,,,,,,,,,,,,,,,,,,,,,,,,,,,,X
########......................##############################
########......................##############################
########......................##############################
########......................##############################
########..........r.....r.....##############################
########r....................r##############################
############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to ts_kawah_jalan (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"ts_kawah_jalan", spawn_id:"from_ts_kawah"}` | path | 2 |
| `e` | spawn, arrival from ts_kawah_jalan | `res://entities/world/spawn.tscn` | `{id:"from_ts_kawah_jalan"}` | path | 1 |
| `B` | boss Sangkuriang, awakened after Captain breaks the Crater Seal | `res://entities/bosses/sangkuriang.tscn` | `{cond:"flag:mq1_8"}` | path | 1 |
| `C` | boss Faceless captain (MQ1 1.8) | `res://entities/bosses/faceless_captain.tscn` | `{}` | path | 1 |
| `Z` | arena post, east post (hang boeh rarang) | `res://entities/bosses/arena_post.tscn` | `{post_id:"east"}` | path | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents | quest markers |
|------|----------------------|---------|----------|---------------|
| causeway | (30,16)-(58,17) 29x2 | Straight walk to the arena | exit `X` (59,16..17), spawn `e` (58,16) | none |
| arena | (8,11)-(29,23) 22x13 | Nagawiru's lair: the captain (MQ1), later the Sangkuriang echo (SQ-S5) | captain `C` (17,17), boss `B` (15,17), arena post `Z` (27,17, east side) | 1.8 `faceless_captain`; SQ-S5 `sangkuriang` |

### Encounters
None.


## Quest markers per step
Marker form `{zone: "<area id>", id: ...}`. The marker id equals the spot's own id prop (npc_id, area_id, id, trigger_id, chest/codex id) or its scene name for the bosses and the elite. Ids from quests.md are marked (Q). Everything else is **ASSUMED**. Marker zones change from `tatar_sunda` to the area id.

| quest | step | marker id | area | char | event |
|-------|------|-----------|------|------|-------|
| MQ0 | 0.8 follow the raiders west | `from_desa_purwa` | `ts_kebun` | `e` | `zone_entered:ts_kebun` |
| MQ1 | 1.1 rest at petilasan | `sunda_1` (Q) | `ts_kebun` | `P` | `petilasan_activated:sunda_1`, sets `mq1_1` |
| MQ1 | 1.2 ask the elder, learn Ga | `sunda_elder` (Q) | `ts_kampung` | `A` | `glyph_learned:sunda_ga`; sets `mq1_3` (opens `G`). The talk also sets `mq1_2` |
| MQ1 | 1.3 clear the batu tulis grove | `sunda_batutulis` (Q) | `ts_leuweung` | `R` | `area_cleared:sunda_batutulis` |
| MQ1 | 1.4 read the batu tulis | `batu_tulis` | `ts_leuweung` | `T` | `glyph_learned:sunda_nga`; sets `mq1_5` (opens `H`) |
| MQ1 | 1.5 clear the terraces | `sunda_terraces` | `ts_sawah` | `M` | `area_cleared:sunda_terraces` |
| MQ1 | 1.6 the woman by the lake | `naganingrum` | `ts_situ` | `D` | `glyph_learned:sunda_ca`; sets `mq1_7` (opens `K`) |
| MQ1 | 1.7 climb to the crater rim | `sunda_2` (Q) | `ts_kawah_jalan` | `Q` | `petilasan_activated:sunda_2` (Laras beat 1) |
| MQ1 | 1.8 save the naga | `faceless_captain` | `ts_kawah` | `C` | `boss_defeated:faceless_captain`, sets `mq1_8`; then the `naga` beat sets `mq1_10` and starts MQG |
| SQ-S5 | giver Dayang Sumbi | `dayang_sumbi` | `ts_situ` | `d` | after MQ1 |
| SQ-S5 | (1) boeh rarang | `sunda_weaver` | `ts_sawah` | `W` | `talked_to:sunda_weaver` (`give:boeh_rarang`) |
| SQ-S5 | (2) Sangkuriang | `sangkuriang` | `ts_kawah` | `B` | `boss_defeated:sangkuriang`; post `Z` (hang boeh rarang on post_id "east", then Ca) |
| Optional | Sandekala | `sandekala` | `ts_leuwi` | `S` | `boss_defeated:sandekala` |
| SQ-S1 | giver Ki Darsa | `ki_darsa` | `ts_kampung` | `I` | `talked_to:ki_darsa`. Unlock: 1.2 |
| SQ-S1 | (1) Lutung Kasarung | `lutung_kasarung` | `ts_leuweung` | `Y` | `talked_to:lutung_kasarung` |
| SQ-S1 | (2) hidden spring | `sunda_spring` | `ts_leuweung` | `N` | `area_cleared:sunda_spring` |
| SQ-S1 | (3) Purbasari | `purbasari` | `ts_kampung` | `U` | `talked_to:purbasari`, then she follows to the spring |
| SQ-S1 | (3) spring bath | `spring_bath` | `ts_leuweung` | `u` | `area_entered:spring_bath` with Purbasari |
| SQ-S2 | giver kepala desa | `kepala_desa` | `ts_kampung` | `V` | `talked_to:kepala_desa`, and again to finish. Unlock: 1.2 |
| SQ-S2 | (2) enter the dark grove | `dark_grove` | `ts_leuweung` | `d` | `area_entered:dark_grove` |
| SQ-S2 | (3) kill the elite | `kuntilanak_elite` | `ts_leuweung` | `q` | `enemy_killed:kuntilanak_elite` |
| SQ-S3 | giver angklung leader | `angklung_leader` | `ts_kampung` | `L` | `item_picked:angklung_1` to `angklung_5` (spots `1` kebun, `2` kebun, `3` sawah, `4` leuweung, `5` situ; sparkle only, no marker), then `talked_to:angklung_leader`. Unlock: `zone_entered:ts_*` (ASSUMED, prefix form) |
| SQ-S4 | giver Cepot | `cepot` | `ts_kebun` | `C` | `enemy_killed:wild_boar` x3 (E2 gives 2, E5 1, E7 2), then `talked_to:cepot`. Unlock: 1.1 |
| Codex | tangkuban_perahu | `tangkuban_perahu` | `ts_situ` | `x` | `codex:tangkuban_perahu` |

Flags set or read in this region: `mq1_3`, `mq1_5` (**ASSUMED**, new), `mq1_7` (Q), `mq1_10` (Q, Desa Purwa). Shortcut gate ids `sc:ts_pagar`, `sc:ts_tangga` (**ASSUMED**).

## Flow
Desa Purwa -> ts_kebun `e` -> E1 field (Bolt teach) -> petilasan 1 `P` with Cepot -> north road -> ts_kampung (Abah Karna, Ga) -> `G` -> ts_leuweung lane E2 (Ward) -> grove E3 + batu tulis (Nga) -> back to ts_kampung (lane, or the south path and the pagar shortcut; the dark grove is never on the route) -> `H` -> ts_sawah clearing E4 (Bind teach) -> terraces E5 -> north corridor -> ts_situ, Naganingrum (Ca) -> `K` -> ts_kawah_jalan crater E7 -> petilasan 2 `Q` -> ts_kawah, the Faceless captain (Story v2). After the boss: P2 -> drop -> ts_kampung -> ts_kebun -> Desa Purwa, then east to Keraton Galuh. Echo SQ-S5: Dayang Sumbi in ts_situ, the weaver, Sangkuriang at the same arena. Optional: Sandekala (ts_leuwi), dark grove elite (SQ-S2), hidden spring (SQ-S1), 3 secret chests, 5 angklung, the codex.

## Validation
Run with `python3 ts_check.py` (kept outside the repo in the session scratch folder). It parses this file. Checks: row widths and sizes, solid edges except exits, spawn within 2 tiles of every exit, link pairs on both ends (the drop is one-way), BFS from every spawn reaching every spot (kabut and gates walkable), shortcut pockets separated by the gate, first-trip world BFS with shortcuts opened from the far side, kabut-closed reachability, encounter spawn tiles and boar lanes, petilasan before the boss with no fight between, and the graph rules (loops, shortcuts, drop, reachability).
```
PASS area count 8 (7-8): ts_kebun, ts_kampung, ts_leuweung, ts_leuwi, ts_sawah, ts_situ, ts_kawah_jalan, ts_kawah
PASS ts_kebun all 34 rows have equal width 60
PASS ts_kebun size 60x34 = 2x2 screens
PASS ts_kebun legend matches map (missing [], unused [])
PASS ts_kebun map edge solid except exit chars ['%', '&', 'X'] (violations [])
PASS ts_kebun exit % is 2 adjacent tiles on the map edge
PASS ts_kebun exit X is 2 adjacent tiles on the map edge
PASS ts_kebun exit & is 2 adjacent tiles on the map edge
PASS ts_kebun spawn ids unique, one tile each
PASS ts_kebun every spot has a valid floor name (bad [])
PASS ts_kebun spots never stand on solid tiles
PASS ts_kampung all 34 rows have equal width 60
PASS ts_kampung size 60x34 = 2x2 screens
PASS ts_kampung legend matches map (missing [], unused [])
PASS ts_kampung map edge solid except exit chars ['$', '%', '&', 'X', '^'] (violations [])
PASS ts_kampung exit ^ is 2 adjacent tiles on the map edge
PASS ts_kampung exit & is 2 adjacent tiles on the map edge
PASS ts_kampung exit $ is 2 adjacent tiles on the map edge
PASS ts_kampung exit X is 2 adjacent tiles on the map edge
PASS ts_kampung exit % is 2 adjacent tiles on the map edge
PASS ts_kampung spawn ids unique, one tile each
PASS ts_kampung every spot has a valid floor name (bad [])
PASS ts_kampung spots never stand on solid tiles
PASS ts_leuweung all 34 rows have equal width 60
PASS ts_leuweung size 60x34 = 2x2 screens
PASS ts_leuweung legend matches map (missing [], unused [])
PASS ts_leuweung map edge solid except exit chars ['%', 'X'] (violations [])
PASS ts_leuweung exit X is 2 adjacent tiles on the map edge
PASS ts_leuweung exit % is 2 adjacent tiles on the map edge
PASS ts_leuweung spawn ids unique, one tile each
PASS ts_leuweung every spot has a valid floor name (bad [])
PASS ts_leuweung spots never stand on solid tiles
PASS ts_leuwi all 34 rows have equal width 60
PASS ts_leuwi size 60x34 = 2x2 screens
PASS ts_leuwi legend matches map (missing [], unused [])
PASS ts_leuwi map edge solid except exit chars ['X'] (violations [])
PASS ts_leuwi exit X is 2 adjacent tiles on the map edge
PASS ts_leuwi spawn ids unique, one tile each
PASS ts_leuwi every spot has a valid floor name (bad [])
PASS ts_leuwi spots never stand on solid tiles
PASS ts_sawah all 34 rows have equal width 60
PASS ts_sawah size 60x34 = 2x2 screens
PASS ts_sawah legend matches map (missing [], unused [])
PASS ts_sawah map edge solid except exit chars ['%', 'X'] (violations [])
PASS ts_sawah exit % is 2 adjacent tiles on the map edge
PASS ts_sawah exit X is 2 adjacent tiles on the map edge
PASS ts_sawah spawn ids unique, one tile each
PASS ts_sawah every spot has a valid floor name (bad [])
PASS ts_sawah spots never stand on solid tiles
PASS ts_situ all 34 rows have equal width 60
PASS ts_situ size 60x34 = 2x2 screens
PASS ts_situ legend matches map (missing [], unused [])
PASS ts_situ map edge solid except exit chars ['$', '%', '&', 'X'] (violations [])
PASS ts_situ exit & is 2 adjacent tiles on the map edge
PASS ts_situ exit $ is 2 adjacent tiles on the map edge
PASS ts_situ exit % is 2 adjacent tiles on the map edge
PASS ts_situ exit X is 2 adjacent tiles on the map edge
PASS ts_situ spawn ids unique, one tile each
PASS ts_situ every spot has a valid floor name (bad [])
PASS ts_situ spots never stand on solid tiles
PASS ts_kawah_jalan all 34 rows have equal width 60
PASS ts_kawah_jalan size 60x34 = 2x2 screens
PASS ts_kawah_jalan legend matches map (missing [], unused [])
PASS ts_kawah_jalan map edge solid except exit chars ['$', '%', 'X'] (violations [])
PASS ts_kawah_jalan exit % is 2 adjacent tiles on the map edge
PASS ts_kawah_jalan exit X is 2 adjacent tiles on the map edge
PASS ts_kawah_jalan exit $ is 2 adjacent tiles on the map edge
PASS ts_kawah_jalan spawn ids unique, one tile each
PASS ts_kawah_jalan every spot has a valid floor name (bad [])
PASS ts_kawah_jalan spots never stand on solid tiles
PASS ts_kawah all 34 rows have equal width 60
PASS ts_kawah size 60x34 = 2x2 screens
PASS ts_kawah legend matches map (missing [], unused [])
PASS ts_kawah map edge solid except exit chars ['X'] (violations [])
PASS ts_kawah exit X is 2 adjacent tiles on the map edge
PASS ts_kawah spawn ids unique, one tile each
PASS ts_kawah every spot has a valid floor name (bad [])
PASS ts_kawah spots never stand on solid tiles
PASS link desa_purwa<->ts_kebun: ts_kebun has exit to desa_purwa with spawn_id from_ts_kebun
PASS link desa_purwa<->ts_kebun: ts_kebun has spawn from_desa_purwa
PASS link desa_purwa<->ts_kebun: spawn in ts_kebun is 1 tile(s) inside its exit
PASS link ts_kebun<->ts_kampung: ts_kebun has exit to ts_kampung with spawn_id from_ts_kebun
PASS link ts_kebun<->ts_kampung: ts_kebun has spawn from_ts_kampung
PASS link ts_kebun<->ts_kampung: spawn in ts_kebun is 1 tile(s) inside its exit
PASS link ts_kebun<->ts_kampung: ts_kampung has exit to ts_kebun with spawn_id from_ts_kampung
PASS link ts_kebun<->ts_kampung: ts_kampung has spawn from_ts_kebun
PASS link ts_kebun<->ts_kampung: spawn in ts_kampung is 1 tile(s) inside its exit
PASS link ts_kampung<->ts_leuweung: ts_kampung has exit to ts_leuweung with spawn_id from_ts_kampung
PASS link ts_kampung<->ts_leuweung: ts_kampung has spawn from_ts_leuweung
PASS link ts_kampung<->ts_leuweung: spawn in ts_kampung is 1 tile(s) inside its exit
PASS link ts_kampung<->ts_leuweung: ts_leuweung has exit to ts_kampung with spawn_id from_ts_leuweung
PASS link ts_kampung<->ts_leuweung: ts_leuweung has spawn from_ts_kampung
PASS link ts_kampung<->ts_leuweung: spawn in ts_leuweung is 1 tile(s) inside its exit
PASS kabut flag mq1_3 on exactly one kabut char [('ts_kampung', 'G')]
PASS link ts_kampung<->ts_sawah: ts_kampung has exit to ts_sawah with spawn_id from_ts_kampung
PASS link ts_kampung<->ts_sawah: ts_kampung has spawn from_ts_sawah
PASS link ts_kampung<->ts_sawah: spawn in ts_kampung is 1 tile(s) inside its exit
PASS link ts_kampung<->ts_sawah: ts_sawah has exit to ts_kampung with spawn_id from_ts_sawah
PASS link ts_kampung<->ts_sawah: ts_sawah has spawn from_ts_kampung
PASS link ts_kampung<->ts_sawah: spawn in ts_sawah is 1 tile(s) inside its exit
PASS kabut flag mq1_5 on exactly one kabut char [('ts_kampung', 'H')]
PASS link ts_kampung<->ts_leuwi: ts_kampung has exit to ts_leuwi with spawn_id from_ts_kampung
PASS link ts_kampung<->ts_leuwi: ts_kampung has spawn from_ts_leuwi
PASS link ts_kampung<->ts_leuwi: spawn in ts_kampung is 1 tile(s) inside its exit
PASS link ts_kampung<->ts_leuwi: ts_leuwi has exit to ts_kampung with spawn_id from_ts_leuwi
PASS link ts_kampung<->ts_leuwi: ts_leuwi has spawn from_ts_kampung
PASS link ts_kampung<->ts_leuwi: spawn in ts_leuwi is 1 tile(s) inside its exit
PASS link ts_sawah<->ts_situ: ts_sawah has exit to ts_situ with spawn_id from_ts_sawah
PASS link ts_sawah<->ts_situ: ts_sawah has spawn from_ts_situ
PASS link ts_sawah<->ts_situ: spawn in ts_sawah is 1 tile(s) inside its exit
PASS link ts_sawah<->ts_situ: ts_situ has exit to ts_sawah with spawn_id from_ts_situ
PASS link ts_sawah<->ts_situ: ts_situ has spawn from_ts_sawah
PASS link ts_sawah<->ts_situ: spawn in ts_situ is 1 tile(s) inside its exit
PASS link ts_situ<->ts_kawah_jalan: ts_situ has exit to ts_kawah_jalan with spawn_id from_ts_situ
PASS link ts_situ<->ts_kawah_jalan: ts_situ has spawn from_ts_kawah_jalan
PASS link ts_situ<->ts_kawah_jalan: spawn in ts_situ is 1 tile(s) inside its exit
PASS link ts_situ<->ts_kawah_jalan: ts_kawah_jalan has exit to ts_situ with spawn_id from_ts_kawah_jalan
PASS link ts_situ<->ts_kawah_jalan: ts_kawah_jalan has spawn from_ts_situ
PASS link ts_situ<->ts_kawah_jalan: spawn in ts_kawah_jalan is 1 tile(s) inside its exit
PASS kabut flag mq1_7 on exactly one kabut char [('ts_situ', 'K')]
PASS link ts_kawah_jalan<->ts_kawah: ts_kawah_jalan has exit to ts_kawah with spawn_id from_ts_kawah_jalan
PASS link ts_kawah_jalan<->ts_kawah: ts_kawah_jalan has spawn from_ts_kawah
PASS link ts_kawah_jalan<->ts_kawah: spawn in ts_kawah_jalan is 1 tile(s) inside its exit
PASS link ts_kawah_jalan<->ts_kawah: ts_kawah has exit to ts_kawah_jalan with spawn_id from_ts_kawah
PASS link ts_kawah_jalan<->ts_kawah: ts_kawah has spawn from_ts_kawah_jalan
PASS link ts_kawah_jalan<->ts_kawah: spawn in ts_kawah is 1 tile(s) inside its exit
PASS link ts_leuweung<->ts_kebun: ts_leuweung has exit to ts_kebun with spawn_id from_ts_leuweung
PASS link ts_leuweung<->ts_kebun: ts_leuweung has spawn from_ts_kebun
PASS link ts_leuweung<->ts_kebun: spawn in ts_leuweung is 1 tile(s) inside its exit
PASS link ts_leuweung<->ts_kebun: ts_kebun has exit to ts_leuweung with spawn_id from_ts_kebun
PASS link ts_leuweung<->ts_kebun: ts_kebun has spawn from_ts_leuweung
PASS link ts_leuweung<->ts_kebun: spawn in ts_kebun is 1 tile(s) inside its exit
PASS shortcut sc:ts_pagar has one gate char in its gate area [('ts_kebun', '=')]
PASS link ts_situ<->ts_kampung: ts_situ has exit to ts_kampung with spawn_id from_ts_situ
PASS link ts_situ<->ts_kampung: ts_situ has spawn from_ts_kampung
PASS link ts_situ<->ts_kampung: spawn in ts_situ is 1 tile(s) inside its exit
PASS link ts_situ<->ts_kampung: ts_kampung has exit to ts_situ with spawn_id from_ts_kampung
PASS link ts_situ<->ts_kampung: ts_kampung has spawn from_ts_situ
PASS link ts_situ<->ts_kampung: spawn in ts_kampung is 1 tile(s) inside its exit
PASS shortcut sc:ts_tangga has one gate char in its gate area [('ts_kampung', '+')]
PASS link ts_situ<->sk_tebing: ts_situ has exit to sk_tebing with spawn_id from_ts_situ
PASS link ts_situ<->sk_tebing: ts_situ has spawn from_sk_tebing
PASS link ts_situ<->sk_tebing: spawn in ts_situ is 1 tile(s) inside its exit
PASS shortcut sc:ts_sk has one gate char in its gate area [('ts_situ', '=')]
PASS link ts_kawah_jalan -> ts_kampung drop exit exists, no spawn back in ts_kawah_jalan
PASS link ts_kawah_jalan -> ts_kampung drop lands at spawn from_ts_kawah_jalan in ts_kampung with no exit back
PASS every exit char appears in the link table (uncovered [])
PASS ts_kebun gate sc:ts_pagar (=, open_side w): one pocket spawn on the open side ['from_ts_leuweung']
PASS ts_kebun gate sc:ts_pagar closed: pocket reaches no other spawn ([])
PASS ts_kebun gate sc:ts_pagar closed: main side cannot reach the pocket spawn
PASS ts_kebun gate sc:ts_pagar closed: exit ['&'] unreachable from the main side
PASS ts_kampung gate sc:ts_tangga (+, open_side n): one pocket spawn on the open side ['from_ts_situ']
PASS ts_kampung gate sc:ts_tangga closed: pocket reaches no other spawn ([])
PASS ts_kampung gate sc:ts_tangga closed: main side cannot reach the pocket spawn
PASS ts_kampung gate sc:ts_tangga closed: exit ['^'] unreachable from the main side
PASS ts_situ gate sc:ts_sk (=, open_side e): one pocket spawn on the open side ['from_sk_tebing']
PASS ts_situ gate sc:ts_sk closed: pocket reaches no other spawn ([])
PASS ts_situ gate sc:ts_sk closed: main side cannot reach the pocket spawn
PASS ts_situ gate sc:ts_sk closed: exit ['$'] unreachable from the main side
PASS ts_kebun BFS from spawn from_ts_kampung (16, 1) reaches all 16 spot tiles, gates walkable (unreachable [])
PASS ts_kebun BFS from spawn from_desa_purwa (58, 16) reaches all 16 spot tiles, gates walkable (unreachable [])
PASS ts_kebun BFS from spawn from_ts_leuweung (1, 26) reaches all 16 spot tiles, gates walkable (unreachable [])
PASS ts_kampung BFS from spawn from_ts_situ (10, 1) reaches all 27 spot tiles, gates walkable (unreachable [])
PASS ts_kampung BFS from spawn from_ts_kawah_jalan (32, 5) reaches all 27 spot tiles, gates walkable (unreachable [])
PASS ts_kampung BFS from spawn from_ts_leuweung (1, 16) reaches all 27 spot tiles, gates walkable (unreachable [])
PASS ts_kampung BFS from spawn from_ts_sawah (58, 16) reaches all 27 spot tiles, gates walkable (unreachable [])
PASS ts_kampung BFS from spawn from_ts_kebun (16, 32) reaches all 27 spot tiles, gates walkable (unreachable [])
PASS ts_kampung BFS from spawn from_ts_leuwi (44, 32) reaches all 27 spot tiles, gates walkable (unreachable [])
PASS ts_leuweung BFS from spawn from_ts_kampung (58, 16) reaches all 17 spot tiles, gates walkable (unreachable [])
PASS ts_leuweung BFS from spawn from_ts_kebun (58, 31) reaches all 17 spot tiles, gates walkable (unreachable [])
PASS ts_leuwi BFS from spawn from_ts_kampung (44, 1) reaches all 9 spot tiles, gates walkable (unreachable [])
PASS ts_sawah BFS from spawn from_ts_situ (30, 1) reaches all 10 spot tiles, gates walkable (unreachable [])
PASS ts_sawah BFS from spawn from_ts_kampung (1, 16) reaches all 10 spot tiles, gates walkable (unreachable [])
PASS ts_situ BFS from spawn from_ts_kawah_jalan (1, 8) reaches all 20 spot tiles, gates walkable (unreachable [])
PASS ts_situ BFS from spawn from_sk_tebing (58, 20) reaches all 20 spot tiles, gates walkable (unreachable [])
PASS ts_situ BFS from spawn from_ts_kampung (8, 32) reaches all 20 spot tiles, gates walkable (unreachable [])
PASS ts_situ BFS from spawn from_ts_sawah (30, 32) reaches all 20 spot tiles, gates walkable (unreachable [])
PASS ts_kawah_jalan BFS from spawn from_ts_kawah (1, 16) reaches all 10 spot tiles, gates walkable (unreachable [])
PASS ts_kawah_jalan BFS from spawn from_ts_situ (58, 16) reaches all 10 spot tiles, gates walkable (unreachable [])
PASS ts_kawah BFS from spawn from_ts_kawah_jalan (58, 16) reaches all 5 spot tiles, gates walkable (unreachable [])
PASS encounter sunda_edge in ts_kebun: 3 enemies, waves 1, tanks 0, shooters 1, walkable tiles in rect 196, boar lanes [], spawn tiles ok (bad [])
PASS encounter sunda_batutulis in ts_leuweung: 3 enemies, waves 1, tanks 0, shooters 1, walkable tiles in rect 202, boar lanes [], spawn tiles ok (bad [])
PASS encounter sunda_boarlane in ts_leuweung: 2 enemies, waves 1, tanks 0, shooters 0, walkable tiles in rect 22, boar lanes [46, 37], spawn tiles ok (bad [])
PASS encounter sunda_spring in ts_leuweung: 3 enemies, waves 1, tanks 0, shooters 1, walkable tiles in rect 47, boar lanes [], spawn tiles ok (bad [])
PASS encounter sunda_clearing in ts_sawah: 3 enemies, waves 1, tanks 1, shooters 0, walkable tiles in rect 88, boar lanes [], spawn tiles ok (bad [])
PASS encounter sunda_terraces in ts_sawah: 4 enemies, waves 1, tanks 1, shooters 1, walkable tiles in rect 256, boar lanes [25], spawn tiles ok (bad [])
PASS encounter sunda_crater in ts_kawah_jalan: 6 enemies, waves 2, tanks 1, shooters 1, walkable tiles in rect 242, boar lanes [20, 31], spawn tiles ok (bad [])
PASS encounter count 7 (6-10)
PASS all 7 original encounter ids present
PASS all required ids present (missing [])
PASS each required id appears in exactly one legend row (extra [])
PASS trigger dark_grove size 22x10 >= 22x10
PASS trigger spring_bath size 5x3 >= 5x3
PASS trigger sande_room size 21x10 >= 21x10
PASS every required quest marker id is in the marker table (missing [])
PASS each required marker id sits on its char in its area (bad [])
PASS graph has 3 independent loops; 3 shortcut/drop edges close a loop: [('ts_leuweung', 'ts_kebun', 'shortcut'), ('ts_situ', 'ts_kampung', 'shortcut'), ('ts_kawah_jalan', 'ts_kampung', 'drop')]
PASS shortcut count 3 (>=2): ['sc:ts_pagar', 'sc:ts_tangga', 'sc:ts_sk']
PASS drop count 1 (>=1): [('ts_kawah_jalan', 'ts_kampung')]
PASS shortcut sc:ts_pagar ends in ts_kebun: petilasan areas ['ts_kawah_jalan', 'ts_kebun'], within one link: True
PASS shortcut sc:ts_tangga ends in ts_kampung: petilasan areas ['ts_kawah_jalan', 'ts_kebun'], within one link: True
PASS shortcut sc:ts_sk ends in ts_situ: petilasan areas ['ts_kawah_jalan', 'ts_kebun'], within one link: True
PASS 2 petilasans in areas ['ts_kawah_jalan', 'ts_kebun']
PASS gates never opened, kabut open: all 8 areas reachable from ts_kebun ([])
PASS first trip with shortcuts opened from the far side: all areas reachable
PASS first trip opens exactly the two internal shortcuts ['sc:ts_pagar', 'sc:ts_tangga'] (sc:ts_sk stays closed)
PASS first trip reaches every spot except the closed sc:ts_sk pocket (unreached [('ts_situ', '='), ('ts_situ', '='), ('ts_situ', ';'), ('ts_situ', '$'), ('ts_situ', '$')])
PASS kabut mq1_3 alone solid: unreachable areas ['ts_leuweung'] (expected ['ts_leuweung'])
PASS kabut mq1_5 alone solid: unreachable areas ['ts_kawah', 'ts_kawah_jalan', 'ts_sawah', 'ts_situ'] (expected ['ts_kawah', 'ts_kawah_jalan', 'ts_sawah', 'ts_situ'])
PASS kabut mq1_7 alone solid: unreachable areas ['ts_kawah', 'ts_kawah_jalan'] (expected ['ts_kawah', 'ts_kawah_jalan'])
PASS all gates open: still all areas reached
PASS critical path ts_kebun -> ts_kawah boss reachable with no shortcut and no glyph (no tile or spot needs casting)
PASS petilasan sunda_2 is outside the sunda_crater trigger rect
PASS exit to ts_kawah is outside the sunda_crater trigger rect
PASS ts_kawah has no encounter before the boss
PASS link table has link, shortcut and drop rows
PASS ts_leuweung: from spawn from_ts_kampung the exit to ts_kebun (pagar pocket) is reachable with the dark_grove trigger rect solid
PASS ts_leuweung: elite q is unreachable without entering the dark_grove rect

RESULT: 218 checks, 0 FAIL
```

## Step 2 self-check ([AGENTS.md](../../AGENTS.md) section 5)
- [x] POI counts: 1 boss arena, 2 optional fight rooms (Sandekala miniboss, dark grove elite; world.md wants "1 miniboss or elite room"), 3 secrets (alcove, hidden spring, Kujang room), 1 codex spot, 7 encounters (6-10), 2 petilasans. **NPCs: 10 spots** vs the world.md target 3-5. See Doc conflicts.
- [x] Petilasan `Q` (6,16) in ts_kawah_jalan is the last stop before ts_kawah: the P2 room, the exit `%` and the causeway hold no enemies. The crater fight E7 is east of P2, its trigger rect (23..44) ends before the P2 room. The validator checks this.
- [x] First appearances (teach, then test): Faceless and Kuntilanak at E1 (player holds Ka). Wild Boar alone at E2 (Ka, Ga; kabut `G` needs `mq1_3`). Jurig at E4 with 2 Faceless (Ka, Ga, Nga; kabut `H` needs `mq1_5`). Faceless Archer at E5 with known enemies.
- [x] One tank per encounter (Jurig in E4, E5, E7 only), at most one shooter, at most two waves (crater only).
- [x] Rooms with 4+ enemies: terraces (36x13, 24x11 trigger) and crater (30x17 floor) are both above 15x9. Boar lanes 8+ (validator): E2 is 14 straight tiles, E7 boars have 20 clear tiles west and 31 east.
- [~] Newest glyph: Ca (Dayang Sumbi) has no weakness in this region. The newest glyph with a weakness is Nga (Bind). Ca Burst answers E7 wave 2 and Sangkuriang phase 2. See Doc conflicts.
- [x] Quest markers: every quests.md id and flag has a spot in an area (table above). The validator checks that each required marker id sits on its char.
- [x] Critical path walkable with no glyph: nothing requires casting. All shortcuts are optional.
- [x] Interlock 1: 8 areas (7-8). Interlock 2: 3 loops (L1, L2, L3), at least 2. Interlock 3: 3 shortcuts (2 internal, 1 external to Segara Kidul), each ends in an area with a petilasan or one link from one (table above). Interlock 4: 1 drop (jalan to kampung). Interlock 5: optional areas (leuwi, dark grove, spring, alcove, Kujang room) branch off loop nodes. Interlock 6: landmark (Tangkuban Perahu). Interlock 7: petilasan 2 directly before the boss, no fight between. Interlock 8: exactly 2 petilasans (`sunda_1` ts_kebun, `sunda_2` ts_kawah_jalan). The rule numbers follow the order in the brief (ASSUMED).

## ASSUMED
- Every layout decision in this file: area ids (`ts_` prefix), sizes, coordinates, the link graph, loop shapes, the drop destination, the placement of kabut `K` in ts_situ (not in ts_kawah_jalan, so the player is never stopped right after a load), the codex in ts_situ, and the new spawn ids.
- Desa Purwa's exit changes to `{target_zone:"ts_kebun", spawn_id:"from_desa_purwa"}` and gets a spawn `from_ts_kebun`.
- `sk_tebing` (Segara Kidul) gets an exit `{target_zone:"ts_situ", spawn_id:"from_sk_tebing"}` and a spawn `from_ts_situ`. That end is not built in Phase 4, so `sc:ts_sk` stays closed (the gate is never opened from the pocket).
- Shortcut ids `sc:ts_pagar`, `sc:ts_tangga`, `sc:ts_sk`, and the open-from-far-side rule.
- Marker ids were renamed to the spot's own id: `weaver_house` to `sunda_weaver`, `lutung` to `lutung_kasarung`, `hidden_spring` to `sunda_spring`, `elite_grove` to `dark_grove` and `kuntilanak_elite`.
- All other ids (npc ids, chest ids, `item_id` snake_case ids, codex id, trigger ids, `post_id`, `oncor_id`) carry over from the old design.
- Two kabut gates `G` (`mq1_3`) and `H` (`mq1_5`). They only guarantee teach-then-test order for Ward and Bind. Replace the kabut tiles with `,` and the region still works; the first-appearance checks then rest on the player's route.
- The batu tulis is an NPC-scene spot (`npc_id` `batu_tulis`): its dialogue runs `learn:sunda_nga` and `flag:mq1_5`.
- The weaver gives the boeh rarang by dialogue (`give:boeh_rarang`); the lutung is an NPC spirit.
- "Hidden" secrets are 1-tile gaps between rocks, visible but easy to miss. No extra mechanic.
- The four oncor are plain spots; the Sandekala script lights them. Dark grove darkening is trigger `d`, Sandekala darkening is trigger `j`.
- Decided by the coordinator: `zone_entered` fires with the area id, so steps that used `zone_entered:tatar_sunda` become `zone_entered:ts_*` (prefix `*` is supported). Purbasari stays in ts_kampung; the spring step only needs the player at the `spring_bath` trigger, no follow logic. Flags `mq1_3` and `mq1_5` already exist as set_flag in data/quests/mq1.tres, so gates `G` and `H` stay. No region registry: `QuestData.zone` stays the region id and `Zones.ZONES` lists the areas.
- The L1 route never enters the dark grove trigger rect (validator checks it), so the elite is fully optional.
- Starting numbers (TUNE): all enemy offsets, trigger sizes, and the lengths of the corridors. VERIFY tags from other docs stay with the culture facts they cover.

## Open questions
1. NPC count is 10 (world.md target 3-5). Keep (all quest-bound, recommended), or merge the weaver into the angklung leader and make the lutung a trigger?
2. E3 (batu tulis grove) uses Faceless plus Kuntilanak, not the bestiary's Jurig mix, because Bind is learned after the grove is cleared. OK?
3. Should Ca have a Tatar Sunda weakness enemy? Today only Lampor (Mataram, listed as "Ca (Sunda)") uses it.
4. Cepot "supervises from a tree": no tree tile, so he stands next to the petilasan.
5. Segara Kidul `sk_tebing` must get the `from_ts_situ` spawn and the pending shortcut end before `sc:ts_sk` can open. Until then it is a closed gate that is only decoration.

## Doc conflicts found (not fixed)
- bestiary.md "Encounters" Tatar Sunda mixes use 2 Kuntilanak (bamboo edge, batu tulis grove) and 1 Archer + 1 Kuntilanak (hunting party, crater path), which breaks its own and AGENTS.md "at most one shooter". Here: 1 shooter per encounter.
- bestiary.md batu tulis mix has Jurig Leuweung at MQ1 1.4, but Bind arrives at 1.5. Jurig first appears at E4 instead.
- bestiary.md "newest glyph earns its place" vs Ca (1.7) having no Tatar Sunda enemy.
- world.md "3-5 NPCs" vs quests.md needing Cepot, Abah Karna, Ki Darsa, kepala desa, angklung leader, weaver, Purbasari, Dayang Sumbi, lutung.
- quests.md SQ-S1 step 3 and 1.4 "spirits" wording: E3 holds Faceless and a Kuntilanak.
- world.md, architecture.md and schedule.md still describe Tatar Sunda as one zone with id `tatar_sunda`. They need the area list when this design is approved.
