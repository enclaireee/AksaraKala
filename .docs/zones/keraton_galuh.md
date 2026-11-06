# Keraton Galuh (region `keraton_galuh`, area prefix `kg_`), Act II (MQG, story v3.1)

Built from `zones/mataram.md`'s format. Look: a Sundanese royal capital of stone terraces and walls, a big square with a ring, banyan trees, loosely based on the Karang Kamulyan site in Ciamis (`VERIFY`). Placeholder tiles from the tile table in [tatar_sunda.md](tatar_sunda.md) (`#` wall, `.` grass, `,` path, `~` water, `b` banyan (bamboo tile), `r` rock, `_` stone floor).

Story v3.1 ([quests.md](../quests.md) section 4, MQG g.1-g.9): this region is Act II, "The Borrowed Face". `kg_pamali` (the Act III stone, `ford` and `truce` beats and the duel) belongs to MQ2; its markers are the MQ2 rows below. World order: Desa Purwa, Keraton Galuh, Pamali, Mataram. Kabut flags: `mqg_3` (palace gate), `mqg_6` (throne room), `mqg_7` (Pamali gate). Encounter flags: `mqg_1`, `mqg_2`.

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
| `C` | NPC Ciung Wanara at the square gates, tournament contender (MQG g.1 plan; moves to the camp at `galuh_1` once step g.5 is done) | `res://entities/npc/npc.tscn` | `{npc_id:"ciung_wanara", cond:"!flag:mqg_4"}` | grass | 1 |
| `c` | chest: 55 Ilmu (Ilmu S, ASSUMED) | `res://entities/world/chest.tscn` | `{chest_id:"galuh_chest_alun", item_id:"ilmu:55"}` | grass | 1 |
| `g` | codex spot, the Karang Kamulyan site (VERIFY) | `res://entities/world/pickup.tscn` | `{codex_id:"galuh"}` | grass | 1 |
| `u` | loose Faceless, roaming pack (respawns on zone reload, no unique_id) | `res://entities/enemies/faceless.tscn` | `{}` | grass | 3 |

### Rooms
| room | tile rect (x,y) size | purpose | contents |
|------|----------------------|---------|----------|
| tournament ring | (14,10)-(34,22) 21x13 | Stone terrace, both bouts | E (23,16) `galuh_bout_1` (g.2), F (25,16) `galuh_bout_2` (g.3) (exclusive by cond), Lengser `L` (38,14) (g.4), Ciung Wanara `C` (38,18) (g.1, the ring's east gate) |
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
#################____________H_____________#################
#################__________________________#################
#################__________________________#################
#################____________B_____________#################
#################_________Q_____O__________#################
#################__________________________#################
#################_________________R________#################
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
#.............C..............,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,X
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
| `B` | boss Barma Wijaya, the false king (MQG g.9) | `res://entities/bosses/barma_wijaya.tscn` | `{unique_id:"barma_wijaya"}` | floor | 1 |
| `C` | NPC Ciung Wanara, camp talk at the petilasan (optional, `quiet`, 2-4 lines, entry `camp_galuh`; reachable after the boss too) | `res://entities/npc/npc.tscn` | `{npc_id:"ciung_wanara", cond:"flag:mqg_4"}` | path | 1 |
| `H` | NPC the Nameless Hunter, a shadow behind the throne (`cage` beat): "The cage holds the man, not the name." | `res://entities/npc/npc.tscn` | `{npc_id:"nameless_hunter", cond:"flag:beat_confession,!flag:beat_escape"}` | floor | 1 |
| `Q` | NPC Queen Pangrenyep, caged with the king (`cage` beat, one line) | `res://entities/npc/npc.tscn` | `{npc_id:"pangrenyep", cond:"flag:mqg_7"}` | floor | 1 |
| `O` | NPC Ciung Wanara in the throne room, cages the king and queen, then holds Galuh (`cage` and `escape` beats) | `res://entities/npc/npc.tscn` | `{npc_id:"ciung_wanara", cond:"flag:mqg_7"}` | floor | 1 |
| `R` | NPC Prince Hariang Banga, escapes east (`escape` beat) | `res://entities/npc/npc.tscn` | `{npc_id:"hariang_banga", cond:"flag:beat_cage,!flag:beat_escape"}` | floor | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents |
|------|----------------------|---------|----------|
| south gate | (29,32)-(30,33) 2x2 | Arrival from the square | exit `S` (29..30,33), spawn `s` (29,32) |
| courtyard | (1,14)-(58,32) 58x19 | Rest and crossroads | petilasan `P` (12,22) (g.5), Ciung camp `C` (14,23), exit `X` (59,22..23), spawn `e` (58,22) |
| throne room | (17,1)-(42,12) 26x12 | Boss arena, then the confession and cage staging | boss `B` (29,4), Hunter shadow `H` (29,1), Pangrenyep `Q` (26,5), Ciung `O` (32,5), Hariang `R` (34,7), kabut `K` (29..30,13) flag `mqg_6` |

### Encounters
None. Barma Wijaya `unique_id:"barma_wijaya"` is a boss, not an encounter.

## Area 3: kg_penjara

- Size: 60 x 34 tiles = 2 x 2 screens (30 x 17 each).
- Look: Stone dungeon: a long guard hall with four barred cells along the north wall, torchless and cold.
- Purpose: Stop the wagon and search the cells (Ch 2). Fight `galuh_escort` and `galuh_cells`, talk to the deserter, read the cage. Dead end west-only.

### Map
```
############################################################
############################################################
############################################################
############################################################
############################################################
##########______####______####______####______##############
##########______####______####______####______##############
##########___m__####______####__D___####__g___##############
##########______####______####______####______##############
##########______####______####______####______##############
############__########__########__########__################
######_______________________________________________#######
######_______________________________________________#######
######_______________________________________________#######
######_______________________________________________#######
######_______________________________________________#######
Xe,,,,__________W_____________________G______________#######
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
| `W` | encounter galuh_escort (the wagon escort in the cell yard, the near miss) | `res://entities/world/encounter.tscn` | `{area_id:"galuh_escort", size:Vector2i(16,10), waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-5,-2)], [res://entities/enemies/faceless.tscn, Vector2i(0,3)], [res://entities/enemies/faceless.tscn, Vector2i(4,-2)], [res://entities/enemies/faceless_archer.tscn, Vector2i(6,2)]]]}` | floor | 1 |
| `D` | NPC the Faceless deserter, in a cell | `res://entities/npc/npc.tscn` | `{npc_id:"faceless_deserter"}` | floor | 1 |
| `g` | codex spot, the iron cage of the legend (VERIFY) | `res://entities/world/pickup.tscn` | `{codex_id:"pamali_cage"}` | floor | 1 |
| `m` | wall message, Laras's scratched words: "The thousand temples. Don't stop." (MQG g.7; codex id ASSUMED) | `res://entities/world/pickup.tscn` | `{codex_id:"laras_wall"}` | floor | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents |
|------|----------------------|---------|----------|
| west corridor | (1,16)-(5,17) 5x2 | Arrival | exit `X` (0,16..17), spawn `e` (1,16) |
| guard hall (the cell yard) | (6,11)-(52,22) 47x12 | Fights (g.6, g.7) | W (16,16) `galuh_escort`, G (38,16) `galuh_cells` |
| cells | (10,5)-(45,9), four 6x5 | Prisoners | wall message `m` (13,7) (west cell, Laras's), deserter `D` (32,7), codex `g` (42,7) |

### Encounters
| area_id | spot | size | waves (enemy, offset) | clean answer |
|---------|------|------|-----------------------|--------------|
| `galuh_escort` | `W (16,16)` | 16x10 | W1: Faceless (-5,-2), (0,+3), (+4,-2), Faceless Archer (+6,+2) | One wave, one shooter; the wagon leaves as the last guard falls |
| `galuh_cells` | `G (38,16)` | 22x10 | W1: Faceless (-8,-3), (-2,+3), (+5,-3); W2: Faceless (-6,+3), (+3,0), Faceless Archer (+8,+2) | Two waves, one shooter |

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
#....................c..,,,,,,,,,,,,.......................#
Xe,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,B,,,,,,,,,,,,,,,,,,,,,,,,yY
X,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Y
#.......................,,,,,s,,,,,,.......................#
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
| `s` | NPC Sapto, Ki Sumarto's son, a soldier of Hariang Banga's army; wades home across the ford in the `truce` beat (name key `NPC_SAPTO_NAME`, **ASSUMED**) | `res://entities/npc/npc.tscn` | `{npc_id:"sapto", cond:"quest:mq2=done,!flag:beat_truce"}` | path | 1 |
| `c` | NPC Ciung Wanara on the west bank, staging for the `truce` beat (the same `ciung_wanara` NPC id as Act II; he has no talk here) | `res://entities/npc/npc.tscn` | `{npc_id:"ciung_wanara", cond:"quest:mq2=done,!flag:beat_truce"}` | grass | 1 |

### Rooms
| room | tile rect (x,y) size | purpose | contents |
|------|----------------------|---------|----------|
| west bank | (1,1)-(23,32) | Arrival, stone, Ciung's staging spot | exit `X` (0,16..17), spawn `e` (1,16), stone `S` (16,14), Ciung `c` (21,15), codex `g` (16,27) |
| ford arena | (20,10)-(39,23) 20x14 | Duel; Sapto's crossing | boss `B` (33,16), Sapto `s` (29,18), rocks `r` for cover |
| river | (24,1)-(35,32) minus ford | Impassable water | none |
| east bank | (36,1)-(58,32) | Road to Mataram | exit `Y` (59,16..17), spawn `y` (58,16) |

### Encounters
None. Hariang Banga `unique_id:"hariang_banga"` is a boss.

## Quest markers per step
Marker form `{zone: "<area id>", id: ...}`. The marker id equals the spot's own id prop (npc_id, area_id, id, unique_id, codex_id). Step ids follow [quests.md](../quests.md) section 4 MQG; marker ids are **ASSUMED** unless they equal a quests.md id.

| step | marker id | area | char | event |
|------|-----------|------|------|-------|
| g.1 plan with Ciung at the square gates | `ciung_wanara` | `kg_alun` | `C` (38,18) | `talked_to:ciung_wanara`, sets `mqg_0` |
| g.2 first bout | `galuh_bout_1` | `kg_alun` | `E` | `area_cleared:galuh_bout_1`, sets `mqg_1` |
| g.3 second bout | `galuh_bout_2` | `kg_alun` | `F` | `area_cleared:galuh_bout_2`, sets `mqg_2`; beat `galuh_bout` (Lengser sees the queen's eyes in Ciung) |
| g.4 speak with Uwa Lengser | `lengser` | `kg_alun` | `L` | `talked_to:lengser`, sets `mqg_3` (lifts kabut `K` to `kg_keraton`) |
| g.5 rest in the palace courtyard | `galuh_1` | `kg_keraton` | `P` | `petilasan_activated:galuh_1`, sets `mqg_4` |
| g.5 camp talk (optional) | `camp_galuh` | `kg_keraton` | `C` (14,23) | `flag:camp_galuh`; `ciung_wanara` entry `camp_galuh`, cond `flag:mqg_4`, `quiet`. Never completes a step, reachable after the boss |
| g.6 stop the wagon in the cell yard | `galuh_escort` | `kg_penjara` | `W` | `area_cleared:galuh_escort`, sets `mqg_4b`; beat `galuh_escort` (the near miss: a strip with *Ka* comes over the wall, the wagon is gone east) |
| g.7 search the cells | `galuh_cells` | `kg_penjara` | `G` | `area_cleared:galuh_cells`, sets `mqg_5`; her message on the wall `laras_wall` `m` (13,7); Laras beat `laras_2` (`step:mqg=7`: she heard you in the yard; ASSUMED, no petilasan) |
| g.8 decide the deserter's fate | `faceless_deserter` | `kg_penjara` | `D` | `talked_to:faceless_deserter`, sets `mqg_6` (lifts kabut `K` to the throne room). Choice 1: `choice_freed` or `choice_handed` |
| g.9 unmask the king | `barma_wijaya` | `kg_keraton` | `B` | `boss_defeated:barma_wijaya`, sets `mqg_7` (lifts kabut `J` to the Pamali road) |
| beat `confession` (the turn) | `barma_wijaya` | `kg_keraton` | `B`, `Q`, `O` | `if flag:mqg_7`: Barma Wijaya admits Seal 2, the Hunter *is* the name; `do` `flag:beat_confession` |
| beat `cage` (Hunter appears) | `nameless_hunter` | `kg_keraton` | `H` (29,1), `O`, `Q` | `if flag:beat_confession`: Ciung cages the king and Pangrenyep (one line from her: "My son will come, child. What is caged is always ransomed."); the Hunter from the shadows: "The cage holds the man, not the name."; `do` `flag:beat_cage`, `codex:barma_wijaya`, `codex:pangrenyep` |
| beat `escape` (aftermath) | `hariang_banga` | `kg_keraton` | `R` (34,7), `O` | `if quest:mqg=done,flag:beat_cage`: Hariang escapes east to raise an army, Ciung stays to hold Galuh, you go on alone; `do` `flag:beat_escape`, `start:mq2` |
| MQ2 | 2.12 write Nagawiru's true name on the Pamali stone | `pamali_stone` | `kg_pamali` | `S` (16,14) | `name_written:nagawiru`, sets `mq2_8`; the stone's entry is `step:mq2=11` (script.md), the spot's cond is `flag:mq2_7` |
| MQ2 | beat `ford` | `hariang_banga` | `kg_pamali` | `B` (33,16) | `if flag:mq2_8`: Hariang Banga wades into the ford alone and the duel starts; `do` `flag:beat_ford`. The boss `B` is placed from `mq2_8` |
| MQ2 | 2.13 duel Hariang Banga at the ford | `hariang_banga` | `kg_pamali` | `B` (33,16) | `boss_defeated:hariang_banga`, sets `mq2_9` (opens `K3` in `mt_wetan`) |
| MQ2 | beat `truce` (aftermath, Choice 2) | `sapto` | `kg_pamali` | `s` (29,18), `c` (21,15) | `if quest:mq2=done`: Hariang yields, Nagawiru speaks from the water (no spot, a voice), Ciung `c` on the west bank, Sapto `s` wades home across the ford toward the market; `do` `flag:beat_truce`, `codex:pamali`, `start:mq3` |
| Codex | `galuh` | `kg_alun` | `g` | `codex:galuh` |
| Codex | `pamali_cage` | `kg_penjara` | `g` | `codex:pamali_cage` |

Flags set or read here: `mqg_0` to `mqg_7`, `mqg_4b`, `beat_galuh_escort`, `camp_galuh`, `beat_confession`, `beat_cage`, `beat_escape`, `choice_freed`, `choice_handed`; in `kg_pamali`: `mq2_7` (read, stone), `mq2_8`, `mq2_9`, `beat_ford`, `beat_truce`, `choice_mercy` and `choice_silent` (set by the `truce` choice). Hunter appearance of Act II: the shadow `H`. Sensitivity: the rooster fights off-screen only (no spot, no hero interaction).

## Flow
Desa Purwa east road (after `mq1_10`) -> `kg_alun` `e` -> Ciung at the east gate of the ring (g.1) -> bout 1 `E` (g.2) -> bout 2 `F` (g.3) -> Lengser `L` (g.4) opens kabut `K` -> north steps -> `kg_keraton` courtyard petilasan `P` (g.5, Laras beat, optional camp talk with Ciung `C`) -> east exit `X` -> `kg_penjara`: the wagon escort `galuh_escort` (g.6, beat `galuh_escort`), guard hall `galuh_cells` (g.7, Laras beat), wall message `m`, the deserter `D` (g.8, choice 1) -> back to the courtyard, kabut `K` to the throne room is open -> Barma Wijaya `B` (g.8) -> `confession`, `cage` (Pangrenyep `Q`, Ciung `O`, Hunter shadow `H`) and `escape` (Hariang `R`) in the throne room -> `kg_alun`, kabut `J` is open -> east road to `kg_pamali` and Mataram.

## Step 2 self-check ([AGENTS.md](../../AGENTS.md) section 5)
- [x] Every MQG step g.1-g.9 and beat (`galuh_bout`, `galuh_escort`, `laras_2`, camp talk, `confession`, `cage`, `escape`) in quests.md section 4 has a marker or spot above.
- [x] Petilasan `galuh_1` comes before the boss with no fight between it and the throne room (the cell-yard fights `galuh_escort` and `galuh_cells` are a side trip east, and the throne room door `K` stays shut until g.8).
- [x] One shooter per encounter, at most two waves; the 4-plus-enemy rooms (ring 17x9 rects, guard hall 22x10) are the existing ones.
- [x] Critical path walkable with no glyph; kabut open on talk and fight flags only.
- [~] Not re-checked after the v3.1 edit: world.md POI counts (3-5 NPCs: this region now holds Ciung (3 spots), Lengser, the deserter, Pangrenyep, Hariang, the Hunter shadow). See Doc conflicts.
- [ ] Re-run the map validator for `kg_keraton` (new chars `C H Q O R`) and `kg_penjara` (`m`, `W`; `G` moved to (38,16)); none of the new spots blocks the door column (29..30) or a path.

## ASSUMED
- Story v3.1 changes (**ASSUMED** 2026-11-06): Ciung `C` in `kg_alun` is where g.1 happens ("the square gates" = the east gate of the ring, (38,18)); he disappears from the square once g.5 sets `mqg_4`, and the same `ciung_wanara` NPC id appears at the courtyard petilasan as the camp-talk giver (`cond:"flag:mqg_4"`, entry `camp_galuh`, `quiet`).
- The `confession`, `cage` and `escape` beats are flag-driven (`quests.md`), not triggers. Their staging spots are NPC-scene spots in the throne room with `cond` on beat flags: Pangrenyep `Q`, Ciung `O`, the Hunter's shadow `H` (29,1) behind the throne, Hariang `R`. The boss `B` is removed once defeated; the confession is spoken by the beat, with `B` represented by the defeated state. NPC ids `pangrenyep` and `nameless_hunter` (reused from the boss scene's id) are ASSUMED.
- Laras's wall message `m` is a codex-style pickup (`laras_wall`, ASSUMED id) in the first cell. Step g.7 completes on clearing the guards, not on reading it.
- Spots in the throne room sit on the 26x12 floor at least 3 tiles from the door kabut `K` (29..30,13) and keep the door column clear.
- Hariang Banga `R` is only a staging actor here; the Act III duel `B` in `kg_pamali` is unchanged (`cond:"flag:mq2_8"`).

## Open questions
1. Does the Deserter stand in his cell (as drawn) or follow the player to the courtyard after choice 1? Today he stays; `choice_freed` puts him at the Gua Kala mouth in Act VI (beat `mouth_freed`).
2. Should the `escape` beat have Hariang leave through the east road (an exit-walk) or only vanish with a fade? Today it only fades.

## Doc conflicts found
- world.md "3-5 NPCs" vs this region's cast (Ciung, Lengser, the deserter, Pangrenyep, Hariang, Sapto, the Hunter shadow); the extra spots are beat staging, not talk NPCs.
- Resolved 2026-11-06 (consistency pass): quests.md and script.md name Queen Pangrenyep (NPC key `NPC_PANGRENYEP_NAME`, codex `pangrenyep`, one line in `cage`), `laras_wall` (codex row in script.md section 13) and the `nameless_hunter` NPC spot; `kg_pamali` now has the MQ2 marker rows, Sapto `s` and Ciung `c`; world.md says the Pamali duel is Act III.
- The caged king's face returns "in Galuh" at the `hunter_name` beat; that is narration only (BEAT_HUNTER_NAME_6), so no spot or state change is needed here.
