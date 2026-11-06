# Keraton Galuh (region `keraton_galuh`, area prefix `kg_`), Ch 2 and 3

Built from `zones/mataram.md`'s format. Look: a Sundanese royal capital of stone terraces and walls, a big square with a ring, banyan trees, loosely based on the Karang Kamulyan site in Ciamis (`VERIFY`). Placeholder tiles from the tile table in [tatar_sunda.md](tatar_sunda.md) (`#` wall, `.` grass, `,` path, `~` water, `b` banyan (bamboo tile), `r` rock, `_` stone floor).

World order: Desa Purwa, Keraton Galuh, Pamali, Mataram. Kabut flags: `mqg_3` (palace gate), `mqg_6` (throne room), `mqg_7` (Pamali gate). Encounter flags: `mqg_1`, `mqg_2`.

## Area table
| area | size | look | purpose |
|------|------|------|---------|
| `kg_alun` | 60x34 | Town square and tournament ring | Hub, bouts, Lengser, gates |
| `kg_keraton` | 60x34 | Palace courtyard and throne room | Rest, boss Barma Wijaya |
| `kg_penjara` | 60x34 | The cells | Fight, deserter, cage codex |
| `kg_pamali` | 60x34 | River crossing | Duel Hariang Banga, link to Mataram |

## Link table
| from | to | kind | gate | spawns |
|------|----|------|------|--------|
| `desa_purwa` | `kg_alun` | link | - | `from_desa_purwa` in kg_alun; `from_kg_alun` in desa_purwa (added by others) |
| `kg_alun` | `kg_keraton` | link | kabut `mqg_3` | `from_kg_alun` in kg_keraton; `from_kg_keraton` in kg_alun |
| `kg_keraton` | `kg_penjara` | link | - | `from_kg_keraton` in kg_penjara; `from_kg_penjara` in kg_keraton |
| `kg_alun` | `kg_pamali` | link | kabut `mqg_7` | `from_kg_alun` in kg_pamali; `from_kg_pamali` in kg_alun |
| `kg_pamali` | `mt_gapura` | link | - | `from_kg_pamali` in mt_gapura (added by others); `from_mt_gapura` in kg_pamali |

## Area maps

## Area 1: kg_alun

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Town square of the false king's capital: grass plaza, banyan corners, a paved tournament ring in the centre (a stone terrace, loosely Karang Kamulyan, VERIFY). West road to Desa Purwa, north steps to the palace, east road to the Pamali.
- Purpose: Ch 2 hub. Tournament rounds `galuh_bout_1` then `galuh_bout_2` in the ring, Lengser appears after round 2, gates to the palace (kabut `mqg_3`) and the Pamali (kabut `mqg_7`).

### Map
```
#############################NN#############################
#...........................#n,#...........................#
#...........................#,,#...........................#
#...........................#KK#...........................#
#..bbb.......................,,.....................bbb....#
#..bbb.......................,,.....................bbb....#
#..bbb.......................,,.....................bbb....#
#............................,,............................#
#............................,,...............g............#
#............................,,............................#
#............._____________________........................#
#............._____________________........................#
#............._____________________........................#
#............._____________________........................#
#............._____________________...L....................#
#............._____________________........................#
Xe,,,,,,,,,,,,_________E_F_________,,,,,,,,,,,,,,,,,,,J,,,yY
X,,,,,,,,,,,,,_____________________,,,,,,,,,,,,,,,,,,,J,,,,Y
#............._____________________...C....................#
#............._____________________........................#
#............._____________________........................#
#............._____________________........................#
#............._____________________........................#
#..........................................................#
#..........................................................#
#..........................................................#
#..bbb..................................bbb...u.....bbb....#
#..bbb..................................bbb.....u...bbb....#
#..bbbc.................................bbb....u....bbb....#
#..........................................................#
#..........................................................#
#..........................................................#
#..........................................................#
############################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to desa_purwa (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"desa_purwa", spawn_id:"from_kg_alun"}` | path | 2 |
| `e` | spawn, arrival from desa_purwa | `res://entities/world/spawn.tscn` | `{id:"from_desa_purwa"}` | path | 1 |
| `N` | exit to kg_keraton (north edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"kg_keraton", spawn_id:"from_kg_alun"}` | path | 2 |
| `n` | spawn, arrival from kg_keraton | `res://entities/world/spawn.tscn` | `{id:"from_kg_keraton"}` | path | 1 |
| `K` | kabut, north gate to the palace (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mqg_3"}` | path | 2 |
| `Y` | exit to kg_pamali (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"kg_pamali", spawn_id:"from_kg_alun"}` | path | 2 |
| `y` | spawn, arrival from kg_pamali | `res://entities/world/spawn.tscn` | `{id:"from_kg_pamali"}` | path | 1 |
| `J` | kabut, east gate to the Pamali (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mqg_7"}` | path | 2 |
| `E` | encounter galuh_bout_1 (tournament round 1) | `res://entities/world/encounter.tscn` | `{area_id:"galuh_bout_1", size:Vector2i(17,9), cond:"!flag:mqg_1", waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-5,-3)], [res://entities/enemies/faceless.tscn, Vector2i(-2,3)], [res://entities/enemies/faceless.tscn, Vector2i(3,-2)], [res://entities/enemies/faceless_archer.tscn, Vector2i(6,2)]]]}` | floor | 1 |
| `F` | encounter galuh_bout_2 (tournament round 2) | `res://entities/world/encounter.tscn` | `{area_id:"galuh_bout_2", size:Vector2i(17,9), cond:"flag:mqg_1,!flag:mqg_2", waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-5,-2)], [res://entities/enemies/faceless.tscn, Vector2i(-1,3)], [res://entities/enemies/faceless_archer.tscn, Vector2i(6,-2)]], [[res://entities/enemies/faceless.tscn, Vector2i(-4,2)], [res://entities/enemies/faceless.tscn, Vector2i(2,-3)], [res://entities/enemies/faceless.tscn, Vector2i(5,3)]]]}` | floor | 1 |
| `L` | NPC Uwa Batara Lengser, the old court officer (after round 2) | `res://entities/npc/npc.tscn` | `{npc_id:"lengser", cond:"flag:mqg_2"}` | grass | 1 |
| `C` | NPC Ciung Wanara, tournament contender | `res://entities/npc/npc.tscn` | `{npc_id:"ciung_wanara"}` | grass | 1 |
| `c` | chest: 55 Ilmu (Ilmu S, ASSUMED) | `res://entities/world/chest.tscn` | `{chest_id:"galuh_chest_alun", item_id:"ilmu:55"}` | grass | 1 |
| `g` | codex spot, the Karang Kamulyan site (VERIFY) | `res://entities/world/pickup.tscn` | `{codex_id:"galuh"}` | grass | 1 |
| `u` | loose Faceless, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/faceless.tscn` | `{}` | grass | 3 |

### Rooms
| room | tile rect (x,y) size | purpose | contents |
|------|----------------------|---------|----------|
| tournament ring | (14,10)-(34,22) 21x13 | Stone terrace, both bouts | E (23,16) `galuh_bout_1`, F (25,16) `galuh_bout_2` (exclusive by cond), Lengser `L` (38,14), Ciung Wanara `C` (38,18) |
| west road | (1,16)-(13,17) 13x2 | Arrival from Desa Purwa | exit `X` (0,16..17), spawn `e` (1,16) |
| palace steps | (29,0)-(30,9) 2x10 | Road north | kabut `K` (29..30,3) flag `mqg_3`, exit `N` (29..30,0), spawn `n` (29,1) |
| east road | (35,16)-(58,17) 24x2 | Road to the Pamali | kabut `J` (54,16..17) flag `mqg_7`, exit `Y` (59,16..17), spawn `y` (58,16) |
| banyan corner | (2,25)-(8,30) | Chest | chest `c` (6,28) |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `galuh_bout_1` | `E (23,16)` | 17x9 | W1: Faceless (-5,-3), Faceless (-2,+3), Faceless (+3,-2), Faceless Archer (+6,+2) | Burst clears the swarm, shoot the archer last |
| `galuh_bout_2` | `F (25,16)` | 17x9 | W1: Faceless (-5,-2), Faceless (-1,+3), Faceless Archer (+6,-2); W2: Faceless (-4,+2), (+2,-3), (+5,+3) | Two waves, one shooter |

Roaming packs: Faceless (46,26), (48,27), (47,28). 3 kills, skirtable, outside the ring rects and 10+ tiles from every spawn and exit.

## Area 2: kg_keraton

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: The palace: a walled courtyard with banyan corners, a paved path to the throne room door, and a long hall of stone with the throne at the far wall.
- Purpose: Rest (petilasan `galuh_1`), road to the cells (east), throne room boss behind kabut `mqg_6`. No roaming enemies; the arena is the throne room. No arena posts (Barma Wijaya has none in the brief; add `arena_post.tscn` rows if his script wants them).

### Map
```
############################################################
#################__________________________#################
#################__________________________#################
#################__________________________#################
#################____________B_____________#################
#################__________________________#################
#################__________________________#################
#################__________________________#################
#################__________________________#################
#################__________________________#################
#################__________________________#################
#################__________________________#################
#################__________________________#################
#############################KK#############################
#............................,,............................#
#............................,,............................#
#............................,,............................#
#.....bbb....................,,...................bbb......#
#.....bbb....................,,...................bbb......#
#.....bbb....................,,...................bbb......#
#............................,,............................#
#............................,,............................#
#...........P................,,,,,,,,,,,,,,,,,,,,,,,,,,,,,eX
#............................,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,X
#............................,,............................#
#............................,,............................#
#............................,,............................#
#.....bbb....................,,...................bbb......#
#.....bbb....................,,...................bbb......#
#.....bbb....................,,...................bbb......#
#............................,,............................#
#............................,,............................#
#............................s,............................#
#############################SS#############################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `S` | exit to kg_alun (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"kg_alun", spawn_id:"from_kg_keraton"}` | path | 2 |
| `s` | spawn, arrival from kg_alun | `res://entities/world/spawn.tscn` | `{id:"from_kg_alun"}` | path | 1 |
| `X` | exit to kg_penjara (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"kg_penjara", spawn_id:"from_kg_keraton"}` | path | 2 |
| `e` | spawn, arrival from kg_penjara | `res://entities/world/spawn.tscn` | `{id:"from_kg_penjara"}` | path | 1 |
| `K` | kabut, throne room door (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mqg_6"}` | path | 2 |
| `P` | petilasan galuh_1 | `res://entities/petilasan/petilasan.tscn` | `{id:"galuh_1"}` | path | 1 |
| `B` | boss Barma Wijaya, the false king | `res://entities/bosses/barma_wijaya.tscn` | `{unique_id:"barma_wijaya"}` | floor | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents |
|------|----------------------|---------|----------|
| south gate | (29,32)-(30,33) 2x2 | Arrival from the square | exit `S` (29..30,33), spawn `s` (29,32) |
| courtyard | (1,14)-(58,32) 58x19 | Rest and crossroads | petilasan `P` (12,22), exit `X` (59,22..23), spawn `e` (58,22) |
| throne room | (17,1)-(42,12) 26x12 | Boss arena | boss `B` (29,4), kabut `K` (29..30,13) flag `mqg_6` |

### Encounters
None. Barma Wijaya `unique_id:"barma_wijaya"` is a boss, not an encounter.

## Area 3: kg_penjara

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Stone dungeon: a long guard hall with four barred cells along the north wall, torchless and cold.
- Purpose: Search the cells (Ch 2). Fight `galuh_cells`, talk to the deserter, read the cage. Dead end west-only.

### Map
```
############################################################
############################################################
############################################################
############################################################
############################################################
##########______####______####______####______##############
##########______####______####______####______##############
##########______####______####__D___####__g___##############
##########______####______####______####______##############
##########______####______####______####______##############
############__########__########__########__################
######_______________________________________________#######
######_______________________________________________#######
######_______________________________________________#######
######_______________________________________________#######
######_______________________________________________#######
Xe,,,,______________________G________________________#######
X,,,,,_______________________________________________#######
######_______________________________________________#######
######_______________________________________________#######
######_______________________________________________#######
######_______________________________________________#######
######_______________________________________________#######
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
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to kg_keraton (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"kg_keraton", spawn_id:"from_kg_penjara"}` | path | 2 |
| `e` | spawn, arrival from kg_keraton | `res://entities/world/spawn.tscn` | `{id:"from_kg_keraton"}` | path | 1 |
| `G` | encounter galuh_cells (the guards of the cells) | `res://entities/world/encounter.tscn` | `{area_id:"galuh_cells", size:Vector2i(22,10), waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-8,-3)], [res://entities/enemies/faceless.tscn, Vector2i(-2,3)], [res://entities/enemies/faceless.tscn, Vector2i(5,-3)]], [[res://entities/enemies/faceless.tscn, Vector2i(-6,3)], [res://entities/enemies/faceless.tscn, Vector2i(3,0)], [res://entities/enemies/faceless_archer.tscn, Vector2i(8,2)]]]}` | floor | 1 |
| `D` | NPC the Faceless deserter, in a cell | `res://entities/npc/npc.tscn` | `{npc_id:"faceless_deserter"}` | floor | 1 |
| `g` | codex spot, the iron cage of the legend (VERIFY) | `res://entities/world/pickup.tscn` | `{codex_id:"pamali_cage"}` | floor | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents |
|------|----------------------|---------|----------|
| west corridor | (1,16)-(5,17) 5x2 | Arrival | exit `X` (0,16..17), spawn `e` (1,16) |
| guard hall | (6,11)-(52,22) 47x12 | Fight | G (28,16) `galuh_cells` |
| cells | (10,5)-(45,9), four 6x5 | Prisoners | deserter `D` (32,7), codex `g` (42,7) |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `galuh_cells` | `G (28,16)` | 22x10 | W1: Faceless (-8,-3), (-2,+3), (+5,-3); W2: Faceless (-6,+3), (+3,0), Faceless Archer (+8,+2) | Two waves, one shooter |

No roaming enemies.

## Area 4: kg_pamali

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: The Pamali: a wide dark river runs north to south with one stone ford, banyan banks either side. By legend, whoever crosses it ends the story of Galuh.
- Purpose: Link between Keraton Galuh and Mataram. Ch 3 duel with Hariang Banga on the ford (cond `mq2_8`), the Pamali stone on the west bank (cond `mq2_7`).

### Map
```
############################################################
#.......................~~~~~~~~~~~~.......................#
#.......................~~~~~~~~~~~~.......................#
#.......................~~~~~~~~~~~~.......................#
#...bbb.................~~~~~~~~~~~~........bbb............#
#...bbb.................~~~~~~~~~~~~........bbb............#
#...bbb.................~~~~~~~~~~~~........bbb............#
#.......................~~~~~~~~~~~~.......................#
#.......................~~~~~~~~~~~~.......................#
#.......................~~~~~~~~~~~~.......................#
#.......................,,,,,,,,,,,,.......................#
#.......................,,,,,r,,,,,,.......................#
#.......................,,,r,,,,,,,,..............bbb......#
#.......................,,,,,,,,,,,,..............bbb......#
#...............S.......,,,,,,,,,,,,..............bbb......#
#.......................,,,,,,,,,,,,.......................#
Xe,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,B,,,,,,,,,,,,,,,,,,,,,,,,yY
X,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Y
#.......................,,,,,,,,,,,,.......................#
#.......................,,,,,,,,,,,,.......................#
#.......................,,,,,,,,,,,,.......................#
#.......................,,,,,,,,r,,,.......................#
#.......................,,,,,,r,,,,,.......................#
#.......................,,,,,,,,,,,,.......................#
#.......................~~~~~~~~~~~~.......................#
#.......................~~~~~~~~~~~~.......................#
#.......................~~~~~~~~~~~~.......................#
#...............g.......~~~~~~~~~~~~.......................#
#...bbb.................~~~~~~~~~~~~........bbb............#
#...bbb.................~~~~~~~~~~~~........bbb............#
#...bbb.................~~~~~~~~~~~~........bbb............#
#.......................~~~~~~~~~~~~.......................#
#.......................~~~~~~~~~~~~.......................#
############################################################
```

### Legend
| Char | What | Scene | Props | Floor | Count |
|------|------|-------|-------|-------|-------|
| `X` | exit to kg_alun (west edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"kg_alun", spawn_id:"from_kg_pamali"}` | path | 2 |
| `e` | spawn, arrival from kg_alun | `res://entities/world/spawn.tscn` | `{id:"from_kg_alun"}` | path | 1 |
| `Y` | exit to mt_gapura (east edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"mt_gapura", spawn_id:"from_kg_pamali"}` | path | 2 |
| `y` | spawn, arrival from mt_gapura | `res://entities/world/spawn.tscn` | `{id:"from_mt_gapura"}` | path | 1 |
| `S` | NPC the Pamali stone, west bank (Ch 3) | `res://entities/npc/npc.tscn` | `{npc_id:"pamali_stone", cond:"flag:mq2_7"}` | grass | 1 |
| `B` | boss Hariang Banga, the duel on the ford | `res://entities/bosses/hariang_banga.tscn` | `{unique_id:"hariang_banga", cond:"flag:mq2_8"}` | path | 1 |
| `g` | codex spot, the Pamali river | `res://entities/world/pickup.tscn` | `{codex_id:"pamali"}` | grass | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents |
|------|----------------------|---------|----------|
| west bank | (1,1)-(23,32) | Arrival, stone | exit `X` (0,16..17), spawn `e` (1,16), stone `S` (16,14), codex `g` (16,27) |
| ford arena | (20,10)-(39,23) 20x14 | Duel | boss `B` (33,16), rocks `r` for cover |
| river | (24,1)-(35,32) minus ford | Impassable water | none |
| east bank | (36,1)-(58,32) | Road to Mataram | exit `Y` (59,16..17), spawn `y` (58,16) |

### Encounters
None. Hariang Banga `unique_id:"hariang_banga"` is a boss.
