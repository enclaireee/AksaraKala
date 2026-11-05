# Tatar Sunda (zone id `tatar_sunda`), Act 1

Zone design on paper. Step 1 of the world design workflow ([AGENTS.md](../../AGENTS.md) section 5). Sources: [world.md](../world.md), [bestiary.md](../bestiary.md) (roster, Encounters, Glyph weaknesses), [quests.md](../quests.md) (MQ1, SQ-S1 to SQ-S4, marker rules). A builder turns this file into the zone scene without redesign: change the layout here first.

Map: **120 x 51 tiles = 4 x 3 screens** (30 x 17 each). Coordinates are (x, y) from the top-left tile (0,0). Entry is the east edge, from Desa Purwa. The boss arena is far west, the crater path and lake are the north strip.

Build rule: a char may repeat only when scene and props are identical (2-tile exit, 2-tile kabut). Every other char is one spot with the floor tile listed under it (paint the floor first, then place the spot).

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

## Screen grid (overview, not buildable)
Each cell is one screen. `==K==` is a kabut, `-->` the critical path. Gate flags: `G` mq1_3, `H` mq1_5, `K` mq1_7.
```
          x 0-29           x 30-59          x 60-89              x 90-119
y 0-16    ARENA <- P2 <-   CRATER (E7) ==K==  LAKE (Dayang Sumbi)  LAKE east, Kujang room
          alcove below
y 17-33   GROVE (E3)  ==G== VILLAGE ==H==     CLEARING (E4) -> TERRACES (E5) -> north exit up to the lake
y 34-50   DARK GROVE, SPRING   SANDEKALA room  P1 terrace            ENTRY field (E1), exit east
```
Critical path: exit/entry -> E1 -> P1 -> village (Abah Karna) -> `G` -> lane E2 -> grove E3 -> batu tulis (Nga) -> back through village -> `H` -> clearing E4 -> terraces E5 -> weaver -> north exit -> lake (Dayang Sumbi) -> `K` -> crater path E7 -> P2 -> boss arena. Off the path: Sandekala room (village south), dark grove elite and hidden spring (south of the grove), alcove, Kujang room, angklung and chests.

## Map
```
########################################################################################################################
########################################################################################################################
###......................################..bbb....bbb.....bbbbb..####.........................................##########
###......................################..bbb....bbb.....bbbbb..####...................~~~~~~~~~~~~~~~~~~~...##########
###......................################..bbb............bbbbb..####...................~~~~~~~~~~~~~~~~~~~...##########
###......................###.........####........................####...................~~~~~~~~~~~~~~~~~~~...##########
###......................###.........####........................####...................~~~~~~~~~~~~~~~~~~~...##########
###......................###.........####........................####...................~~~~~~~~~~~~~~~~~~~...##########
###.,,,,,,B,,,,,,,,,,,Z,,,,,,,,,Q,,,,,,,,,,,,,,,,,,,,,O,,,,,,,,,,,,K,,,,,,,,,,,,,,,,,,D,~~~~~~~~~~~~~~~~~~~...##########
###.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,K,,,,,,,,,,,,,,,,,,,,,.....................##########
###......................###.........####........................####.....................,,..rrr...rrrrr.....#.......##
###......................###.........####........................####.....................,,..rrr...rrrrr...rr#.......##
###......................################..bbbb.............bbbb.####.......rrrrr.........,,..rrr.x.rrrrr.....,....k..##
###......................################..bbbb.....bbbb....bbbb.####.......rrrrr.........,,..rrr...rrrrr...rr#.......##
###......................################..bbbb.....bbbb....bbbb.####..5....rrrrr.........,,..rrr.............#.......##
#####################################################################.....................,,..................#.......##
############.....#########################################################################,,############################
############..c..#########################################################################,,############################
############.....#########################################################################,,############################
##############,###########################################################################,,############################
####.........r,r..............###########.........................###########....................................#######
####..........................###########..#######..#######.......#.........#..#######..............ttttttttttttt#######
####.bbbb.........bbb.bbb.....###########..#_____#..#_____#.......#.........#..#_____#..............tttttttttt3tt#######
####.bbbb.........bbb.bbb.....###########..#_____#..#_____#.......#.........#..#__W__#..............ttttttttttttt#######
####..................bbb.....###########..###,###..###,###.......#.........#..#_____#..............ttttttttttttt#######
####...Y..............bbb.....###########..A.............V........#.........#..#_____#..............ttttttttttttt#######
####.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,F,,,,G,,,,,,,,,,,,,,,,,,,,,,,,,H,,,,J,,,,,,,###,###,,,,.......................#######
####.,,,,,,,,,T,,,R,,,,,,,,,,,,,,,,,,,,,G,,,,,,,,,,,,,,,,,,,,,,,,,H,,,,,,,,,,,ttttttttttttttttttMtttttttttttttttt#######
####..........................###########......I,,........L...,,..#.........#....................................#######
####.bbb......................###########.##,##.,,.........#,#,,..#.........#.ttttttttttttttttttttttttttttttttttt#######
####.bbb................bbbb..###########.#_U_#.,,.........#_#,,..#.........#.........ttttttttttttttttttttttttttt#######
####.bbbbbbb............bbbb..###########.#___#.,,.........#_#,,..###########.ttttttttttttttttttttttttttttttttttt#######
####....bbbb............bbbb..###########.#####.,,.........###,,..###########.........ttttttttttttttttttttttttttt#######
####....bbbb............bbbb..##################,,############,,########################################################
####..4.bbbb............bbbb..##################,,############,,########################################################
####..........................##################,,############,,############################...........................#
##############,,################################,,############,,##########ttttttttttttttttt#....bbb.............bbb....#
##############,,################################,,############,,##########ttttttttttttttttt#....bbb.........bbb.bbb.1..#
###.......................############.......................#,,##########ttttttttttttttttt#....bbb.........bbb........#
###.......................############...........j...........#,,##########ttttttttttttttttt#................bbb........#
###..bbbbb..bb...bbbb.....###.......##....m.............n....#,,##########.................#...........................#
###..bbbbb..bb...bbbb.....###.......##.......................#,,,,,,,,,,,,,,,,,,,,,,P,,,,,,,,,,,,,,,,,,,E,,,,,,,,,,,,,eX
###..bbbb........bbbb.....###...N...##.......................#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.X
###..bbbb.....d..bbbb.....###..~~~..##...........S...........#############............C....#...........................#
###...........q.......bbb.,,,..~~~..##.......................#############ttttttttttttttttt#...................bbb.....#
###........bb.........bbb.###..~~~..##.......................#############ttttt2ttttttttttt#..bb.....bbb.......bbb.....#
###..bbbbb.bb.....bbbbbb..###...u...##.......................#############ttttttttttttttttt#..bb.....bbb.......bbb.....#
###..bbbbb.bb.....bbbbbb..###.a.....##....p.............s....#############ttttttttttttttttt#.......bbbbb...............#
###..bbbbb........bbbbbb..###.......##.......................###############################.......bb..................#
###.......................############.......................###########################################################
########################################################################################################################
```

## Legend (spots)
| Char | Entity | Scene path | Props | Floor under it |
|------|--------|-----------|-------|----------------|
| `X` | exit to Desa Purwa | `res://entities/world/exit.tscn` | `{target_zone:"desa_purwa", spawn_id:"from_sunda"}` | path |
| `e` | spawn, arrival from Desa Purwa | `res://entities/world/spawn.tscn` | `{id:"from_purwa"}` | grass |
| `G` | kabut, village west gate (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq1_3"}` | path |
| `H` | kabut, village east gate (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq1_5"}` | path |
| `K` | kabut, crater path (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq1_7"}` | path |
| `P` | petilasan 1 | `res://entities/petilasan/petilasan.tscn` | `{id:"sunda_1"}` | path |
| `Q` | petilasan 2 | `res://entities/petilasan/petilasan.tscn` | `{id:"sunda_2"}` | path |
| `C` | NPC Cepot (SQ-S4 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"cepot"}` | grass |
| `A` | NPC Abah Karna, elder, teaches Ga | `res://entities/npc/npc.tscn` | `{npc_id:"sunda_elder"}` | grass |
| `I` | NPC Ki Darsa, juru pantun (SQ-S1 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"ki_darsa"}` | grass |
| `V` | NPC kepala desa (SQ-S2 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"kepala_desa"}` | grass |
| `L` | NPC angklung group leader (SQ-S3 giver) | `res://entities/npc/npc.tscn` | `{npc_id:"angklung_leader"}` | grass |
| `U` | NPC Purbasari (SQ-S1) | `res://entities/npc/npc.tscn` | `{npc_id:"purbasari"}` | floor |
| `W` | NPC weaver, gives boeh rarang (MQ1 1.6) | `res://entities/npc/npc.tscn` | `{npc_id:"sunda_weaver"}` | floor |
| `Y` | NPC Lutung Kasarung spirit (SQ-S1) | `res://entities/npc/npc.tscn` | `{npc_id:"lutung_kasarung"}` | grass |
| `D` | NPC Dayang Sumbi, teaches Ca (MQ1 1.7) | `res://entities/npc/npc.tscn` | `{npc_id:"dayang_sumbi"}` | path |
| `T` | batu tulis stone, teaches Nga (MQ1 1.5) | `res://entities/npc/npc.tscn` | `{npc_id:"batu_tulis"}` | path |
| `k` | chest: Kujang (secret 1) | `res://entities/world/chest.tscn` | `{chest_id:"sunda_kujang", item_id:"kujang"}` | grass |
| `a` | chest: Leather Armor (secret 2, hidden spring) | `res://entities/world/chest.tscn` | `{chest_id:"sunda_leather", item_id:"leather_armor"}` | grass |
| `c` | chest: Iron Ring (secret 3, alcove) | `res://entities/world/chest.tscn` | `{chest_id:"sunda_ironring", item_id:"iron_ring"}` | grass |
| `1` | angklung 1 | `res://entities/world/pickup.tscn` | `{item_id:"angklung_1"}` | grass |
| `2` | angklung 2 | `res://entities/world/pickup.tscn` | `{item_id:"angklung_2"}` | tea terrace |
| `3` | angklung 3 | `res://entities/world/pickup.tscn` | `{item_id:"angklung_3"}` | tea terrace |
| `4` | angklung 4 | `res://entities/world/pickup.tscn` | `{item_id:"angklung_4"}` | grass |
| `5` | angklung 5 | `res://entities/world/pickup.tscn` | `{item_id:"angklung_5"}` | grass |
| `x` | codex spot, ruin on the lake shore | `res://entities/world/pickup.tscn` | `{codex_id:"tangkuban_perahu"}` | grass |
| `B` | boss Sangkuriang | `res://entities/bosses/sangkuriang.tscn` | `{}` | path |
| `Z` | arena post, east post (hang boeh rarang) | `res://entities/bosses/arena_post.tscn` | `{post_id:"east"}` | path |
| `S` | miniboss Sandekala | `res://entities/bosses/sandekala.tscn` | `{}` | grass |
| `m` | oncor NW | `res://entities/bosses/oncor.tscn` | `{oncor_id:"nw"}` | grass |
| `n` | oncor NE | `res://entities/bosses/oncor.tscn` | `{oncor_id:"ne"}` | grass |
| `p` | oncor SW | `res://entities/bosses/oncor.tscn` | `{oncor_id:"sw"}` | grass |
| `s` | oncor SE | `res://entities/bosses/oncor.tscn` | `{oncor_id:"se"}` | grass |
| `q` | elite Kuntilanak (SQ-S2) | `res://entities/enemies/kuntilanak_elite.tscn` | `{}` | grass |
| `u` | trigger, spring bath (Purbasari delivered) | `res://entities/world/trigger.tscn` | `{trigger_id:"spring_bath", size:Vector2i(5,3)}` | grass |
| `d` | trigger, dark grove entered (darkens arena, SQ-S2) | `res://entities/world/trigger.tscn` | `{trigger_id:"dark_grove", size:Vector2i(22,10)}` | grass |
| `j` | trigger, Sandekala room entered (starts darkening) | `res://entities/world/trigger.tscn` | `{trigger_id:"sande_room", size:Vector2i(21,10)}` | grass |
| `E` | encounter sunda_edge | `res://entities/world/encounter.tscn` | `{area_id:"sunda_edge", size:Vector2i(22,10), waves:[[[res://entities/enemies/kuntilanak.tscn, Vector2i(-10,0)], [res://entities/enemies/bandit.tscn, Vector2i(-5,-2)], [res://entities/enemies/bandit.tscn, Vector2i(-5,2)]]]}` | path |
| `F` | encounter sunda_boarlane | `res://entities/world/encounter.tscn` | `{area_id:"sunda_boarlane", size:Vector2i(11,3), waves:[[[res://entities/enemies/wild_boar.tscn, Vector2i(-4,0)], [res://entities/enemies/wild_boar.tscn, Vector2i(-4,1)]]]}` | path |
| `R` | encounter sunda_batutulis | `res://entities/world/encounter.tscn` | `{area_id:"sunda_batutulis", size:Vector2i(20,12), waves:[[[res://entities/enemies/bandit.tscn, Vector2i(-3,-3)], [res://entities/enemies/bandit.tscn, Vector2i(3,3)], [res://entities/enemies/kuntilanak.tscn, Vector2i(7,-4)]]]}` | path |
| `J` | encounter sunda_clearing | `res://entities/world/encounter.tscn` | `{area_id:"sunda_clearing", size:Vector2i(9,10), waves:[[[res://entities/enemies/jurig_leuweung.tscn, Vector2i(3,0)], [res://entities/enemies/bandit.tscn, Vector2i(2,-3)], [res://entities/enemies/bandit.tscn, Vector2i(2,3)]]]}` | path |
| `M` | encounter sunda_terraces | `res://entities/world/encounter.tscn` | `{area_id:"sunda_terraces", size:Vector2i(24,11), waves:[[[res://entities/enemies/wild_boar.tscn, Vector2i(6,0)], [res://entities/enemies/jurig_leuweung.tscn, Vector2i(-3,-3)], [res://entities/enemies/bandit_archer.tscn, Vector2i(4,-4)], [res://entities/enemies/bandit.tscn, Vector2i(-4,2)]]]}` | tea terrace |
| `N` | encounter sunda_spring | `res://entities/world/encounter.tscn` | `{area_id:"sunda_spring", size:Vector2i(7,9), waves:[[[res://entities/enemies/bandit.tscn, Vector2i(-2,0)], [res://entities/enemies/bandit.tscn, Vector2i(2,0)], [res://entities/enemies/kuntilanak.tscn, Vector2i(-2,4)]]]}` | grass |
| `O` | encounter sunda_crater | `res://entities/world/encounter.tscn` | `{area_id:"sunda_crater", size:Vector2i(22,11), waves:[[[res://entities/enemies/jurig_leuweung.tscn, Vector2i(4,-2)], [res://entities/enemies/bandit.tscn, Vector2i(3,2)], [res://entities/enemies/wild_boar.tscn, Vector2i(-6,-1)], [res://entities/enemies/wild_boar.tscn, Vector2i(-6,1)]], [[res://entities/enemies/kuntilanak.tscn, Vector2i(-2,-4)], [res://entities/enemies/bandit.tscn, Vector2i(-2,4)]]]}` | path |

Exit `X` is on the east edge (119,41..42). Its spawn `e` (118,41) is one tile inside. The three kabut chars are all two tiles tall; each sits across a 2-wide path.

## Room table
Sizes are interior tiles. Link rows are 1-3 wide corridors.

| id | tile rect (x,y) size | purpose | contents | quest markers |
|----|----------------------|---------|----------|---------------|
| entry | (92,35)-(118,48) 27x14 | Arrival field with bamboo cover, first teach encounter | exit `X`, spawn `e`, E1 `E` (104,41), angklung `1` (116,37) | `zone_entered:tatar_sunda`, `sunda_edge` |
| p1 | (74,36)-(90,47) 17x12 | Tea terrace rest, petilasan 1 | petilasan `P` (84,41), Cepot `C` (86,43), angklung `2` (79,45) | 1.1 `sunda_1`, SQ-S4 `cepot` |
| village | (41,20)-(65,32) 25x13 | Hub village, 5 NPCs, west gate `G`, east gate `H`, road to Sandekala | Abah Karna `A` (43,25), Ki Darsa `I` (47,28), kepala desa `V` (57,25), angklung leader `L` (58,28), Purbasari `U` (44,30, in a hut), 4 houses | 1.2, 1.3 `sunda_elder`; SQ-S1/S2/S3 givers |
| lane | (30,26)-(40,27) 11x2 | 11-tile straight Boar lane, kabut `G` at x=40 | E2 `F` (35,26), kabut `G` (40,26..27) | `sunda_boarlane` |
| grove | (4,20)-(29,35) 26x16 | Batu tulis bamboo grove, Nga teaching stone | batu tulis `T` (14,27), E3 `R` (18,27), lutung `Y` (7,25), angklung `4` (6,34), alcove gap (14,19..20) | 1.4 `sunda_batutulis`, 1.5 `batu_tulis`, SQ-S1 `lutung` |
| alcove | (12,16)-(16,18) 5x3 | Secret 3, hidden behind rocks at (13,20) and (15,20) | chest Iron Ring `c` (14,17) | none |
| dark | (3,38)-(25,49) 23x12 | Dark bamboo grove, elite Kuntilanak arena (SQ-S2); locally dark, no day/night | elite `q` (14,44), trigger `d` (14,43), hidden gap to spring (26..28,44) | SQ-S2 `elite_grove` |
| spring | (29,40)-(35,48) 7x9 | Secret 2, hidden spring (SQ-S1), Purbasari's bath | pond (31..33,43..45), E6 `N` (32,42), chest Leather Armor `a` (30,47), trigger `u` (32,46) | SQ-S1 `hidden_spring` |
| sande | (38,38)-(60,49) 23x12 | Sandekala miniboss room (optional), 23x12, 4 oncor ring | Sandekala `S` (49,43), oncor `m` (42,40) `n` (56,40) `p` (42,47) `s` (56,47), trigger `j` (49,39) | `sandekala` |
| clearing | (67,21)-(75,30) 9x10 | Jurig teach clearing, behind `H` | E4 `J` (71,26) | `sunda_clearing` |
| terraces | (77,20)-(112,32) 36x13 | Tea terraces, hunting party, weaver's house (80..84,22..25) | E5 `M` (96,27), weaver `W` (82,23), angklung `3` (110,22), north exit (90..91,16..19) | 1.6 `weaver_house`, `sunda_terraces` |
| lake | (69,2)-(109,15) 41x14 | Lake shore (water 88..106 x 3..8), Dayang Sumbi, codex ruin | Dayang Sumbi `D` (86,8), kabut `K` at (67,8..9) west end, codex `x` (98,12), angklung `5` (71,14), hidden gap east (110,12) | 1.7 `dayang_sumbi` |
| kujang | (111,10)-(117,15) 7x6 | Secret 1, behind rocks (108..109, 11 and 13) | chest Kujang `k` (115,12) | none |
| crater | (41,2)-(64,14) 24x13 | Crater path, last fight, 8+ tile lane y 5..11 | E7 `O` (54,8) | `sunda_crater` |
| p2 | (28,5)-(36,11) 9x7 | Petilasan 2, no enemies | petilasan `Q` (32,8) | 1.8 `sunda_2` |
| arena | (3,2)-(24,14) 22x13 | Sangkuriang arena, entered only from p2 | boss `B` (10,8), arena post `Z` (22,8, east side) | 1.9 `sangkuriang` |
| links | c_p1_entry (91,41..42), c_p1_west (62..73,41..42), c_village_p1 (62..63,33..40), c_village_sande (48..49,33..37), c_clear_terr (76,26..27), c_lake_terr (90..91,16..19), c_gate_crater (65..68,8..9), c_p2_crater (37..40,8..9), c_arena_p2 (25..27,8..9), c_grove_dark (14..15,36..37), c_dark_spring (26..28,44), c_alcove (14,19), c_kujang (110,12) | Corridors | none | none |

## Encounter table
Trigger rect is centered on the spot. Offsets are tiles from the spot. Wave 2 (crater only) rises from mist at its offsets with a 0.5 s warning, in view of the player (the player enters from the east, wave 2 spawns west and north/south of the lane).

| area_id | spot | room | size | waves (enemy, offset) | clean answer |
|---------|------|------|------|-----------------------|--------------|
| `sunda_edge` | `E` (104, 41) | entry | 22x10 | W1: Kuntilanak (-10,+0), Bandit (-5,-2), Bandit (-5,+2) | Ka Bolt (Kuntilanak shriek) |
| `sunda_boarlane` | `F` (35, 26) | lane | 11x3 | W1: Wild Boar (-4,+0), Wild Boar (-4,+1) | Ga Ward (Boar dash) |
| `sunda_batutulis` | `R` (18, 27) | grove | 20x12 | W1: Bandit (-3,-3), Bandit (+3,+3), Kuntilanak (+7,-4) | Ka Bolt (Kuntilanak). Ga Ward not needed |
| `sunda_clearing` | `J` (71, 26) | clearing | 9x10 | W1: Jurig Leuweung (+3,+0), Bandit (+2,-3), Bandit (+2,+3) | Nga Bind (Jurig, newest glyph with a weakness) |
| `sunda_terraces` | `M` (96, 27) | terraces | 24x11 | W1: Wild Boar (+6,+0), Jurig Leuweung (-3,-3), Bandit Archer (+4,-4), Bandit (-4,+2) | Nga Bind on Jurig, Ga Ward on Boar |
| `sunda_spring` | `N` (32, 42) | spring | 7x9 | W1: Bandit (-2,+0), Bandit (+2,+0), Kuntilanak (-2,+4) | Ka Bolt (Kuntilanak) |
| `sunda_crater` | `O` (54, 8) | crater | 22x11 | W1: Jurig Leuweung (+4,-2), Bandit (+3,+2), Wild Boar (-6,-1), Wild Boar (-6,+1) ; W2: Kuntilanak (-2,-4), Bandit (-2,+4) | Nga Bind (Jurig), Ga Ward (Boars), Ca Burst on the wave 2 pair |

Counts: 7 encounters, one tank at most each, one shooter at most each, 2 waves at most. 4+ enemies only in terraces (36x13) and crater (24x13). Boar lanes: E2 is 11 straight tiles (x 30-40); E5 Boar at (102,27) has 8+ clear tiles west along y 27; E7 Boars at (48,7) and (48,9) have 15 clear tiles east. Extra fights: elite Kuntilanak (dark grove), Sandekala (sande), Sangkuriang (arena).

First appearances (teach, then test), with the glyph the player holds at that point:
| Enemy | First seen | Player glyphs there | Weakness usable |
|-------|-----------|--------------------|-----------------|
| Bandit | E1 | Ka | none needed (mundane) |
| Kuntilanak | E1 (1 of 3, with Bandits) | Ka | Bolt, yes |
| Wild Boar | E2 (lane, 2 Boars alone) | Ka, Ga (kabut `G` needs flag mq1_3 = Ga learned) | Ward, yes |
| Jurig Leuweung | E4 (1 Jurig + 2 Bandits) | Ka, Ga, Nga (kabut `H` needs flag mq1_5 = Nga learned) | Bind, yes |
| Bandit Archer | E5 (with known enemies) | Ka, Ga, Nga | none needed |

## Quest markers per step
Marker form `{zone: "tatar_sunda", id: ...}`. Ids from quests.md are marked (Q). Everything else is **ASSUMED**.

| Step | Marker id | Spot | Completes on |
|------|-----------|------|--------------|
| 1.1 rest at petilasan | `sunda_1` (Q) | `P` | `petilasan_activated:sunda_1` (Q) |
| 1.2 find the elder | `sunda_elder` (Q) | `A` | `talked_to:sunda_elder` (Q) |
| 1.3 learn Ga | `sunda_elder` | `A` | `glyph_learned:sunda_ga` (Q); set flag `mq1_3` (opens `G`) |
| 1.4 clear the batu tulis grove | `sunda_batutulis` (Q) | `R` | `area_cleared:sunda_batutulis` (Q) = E3 area_id |
| 1.5 read the batu tulis | `batu_tulis` | `T` | `glyph_learned:sunda_nga` (Q); set flag `mq1_5` (opens `H`) |
| 1.6 find the weaver | `weaver_house` | `W` | `item_picked:boeh_rarang` (Q); the weaver gives it by dialogue (`give:boeh_rarang`) |
| 1.7 meet Dayang Sumbi | `dayang_sumbi` (Q) | `D` | `talked_to:dayang_sumbi` (Q); set flag `mq1_7` (opens `K`) |
| 1.8 climb to the crater rim | `sunda_2` (Q) | `Q` | `petilasan_activated:sunda_2` (Q) |
| 1.9 free Sangkuriang | `sangkuriang` | `B`, post `Z` (hang boeh rarang on post_id "east", then Ca) | `boss_defeated:sangkuriang` (Q) |
| 1.10 return to Semar | `semar` in `desa_purwa` | exit `X` leads there | `talked_to:semar`; sets `mq1_10` in Desa Purwa |
| Sandekala (optional) | `sandekala` | `S` | `boss_defeated:sandekala` |
| SQ-S1 (giver Ki Darsa `I`) | `ki_darsa`; (1) `lutung`; (2) `hidden_spring` | `Y`; `N` | (1) `talked_to:lutung_kasarung`; (2) `area_cleared:sunda_spring`; (3) `purbasari` `U`, then `area_entered:spring_bath` (trigger `u`) with Purbasari. Unlock: 1.2 |
| SQ-S2 (giver kepala desa `V`) | `kepala_desa`; `elite_grove` | `V`; `d`, `q` | (1) `talked_to:kepala_desa`; (2) `area_entered:dark_grove`; (3) `enemy_killed:kuntilanak_elite`; (4) `talked_to:kepala_desa`. Unlock: 1.2 |
| SQ-S3 (giver angklung leader `L`) | `angklung_leader`; angklung sparkle only (no marker) | `L`; `1` to `5` | `item_picked:angklung_1` to `angklung_5`, then `talked_to:angklung_leader`. Unlock: `zone_entered:tatar_sunda` |
| SQ-S4 (giver Cepot `C`) | `cepot` | `C` | `enemy_killed:wild_boar` x3 (E2 gives 2, E5 1, E7 2), then `talked_to:cepot`. Unlock: 1.1 |
| Codex | `tangkuban_perahu` | `x` | `codex:tangkuban_perahu` |

Flags set or read in this zone: `mq1_3`, `mq1_5` (**ASSUMED**, new), `mq1_7` (Q), `mq1_10` (Q, Desa Purwa).

## Flow
Entry `e` -> E1 bamboo edge (Bolt teach) -> petilasan 1 `P` with Cepot -> village (Abah Karna, Ga) -> `G` -> lane E2 (Ward) -> grove E3 + batu tulis (Nga) -> back to the village -> `H` -> clearing E4 (Bind teach) -> terraces E5 + weaver (boeh rarang) -> lake, Dayang Sumbi (Ca) -> `K` -> crater path E7 -> petilasan 2 `Q` -> boss arena (Sangkuriang). Optional branches: Sandekala (miniboss), dark grove elite (SQ-S2), hidden spring (SQ-S1), 3 secret chests, 5 angklung.

## Validation
```
PASS all 51 rows have equal length 120
PASS size 120x51 = 4x3 screens (multiple of 30x17)
PASS every non-tile char is in the legend (missing: [])
PASS every legend char is in the map (unused: [])
PASS map edge solid except exit chars ['X'] (violations: [])
PASS exit X on map edge (2 tiles) with spawn e 1 tiles away
PASS BFS from start e(118, 41), kabut walkable: all 48 spot tiles reachable (unreachable: [])
PASS kabut G solid: unreachable spots 4FGNRTYacdqu (expected at least RTYcq)
PASS kabut H solid: unreachable spots 35BDHJKMOQWZkx (expected at least DJMW)
PASS kabut K solid: unreachable spots BKOQZ (expected at least BOQZ)
PASS kabut ALL solid: unreachable spots 345BDFGHJKMNOQRTWYZacdkqux (expected at least BDJMOQRTWZq)
PASS critical path e->P->A->G->T->J->W->D->K->O->Q->B walkable, 307 tiles, no glyph needed (no tile or spot requires casting)
PASS encounter sunda_edge: 3 enemies in entry 27x14, waves 1, tanks 0, shooters 1, spawn tiles walkable and in trigger rect, boar lane >= 8
PASS encounter sunda_boarlane: 2 enemies in lane 11x2, waves 1, tanks 0, shooters 0, spawn tiles walkable and in trigger rect, boar lane >= 8
PASS encounter sunda_batutulis: 3 enemies in grove 26x16, waves 1, tanks 0, shooters 1, spawn tiles walkable and in trigger rect, boar lane >= 8
PASS encounter sunda_clearing: 3 enemies in clearing 9x10, waves 1, tanks 1, shooters 0, spawn tiles walkable and in trigger rect, boar lane >= 8
PASS encounter sunda_terraces: 4 enemies in terraces 36x13, waves 1, tanks 1, shooters 1, spawn tiles walkable and in trigger rect, boar lane >= 8
PASS encounter sunda_spring: 3 enemies in spring 7x9, waves 1, tanks 0, shooters 1, spawn tiles walkable and in trigger rect, boar lane >= 8
PASS encounter sunda_crater: 6 enemies in crater 24x13, waves 2, tanks 1, shooters 1, spawn tiles walkable and in trigger rect, boar lane >= 8
PASS every spot sits on a walkable floor tile (. , t _) []
```

## Step 2 self-check ([AGENTS.md](../../AGENTS.md) section 5)
- [x] POI counts: 1 boss arena, 2 optional fight rooms (Sandekala miniboss, dark grove elite; world.md wants "1 miniboss or elite room"), 2-3 secrets (3: alcove, hidden spring, Kujang room), 1 codex spot (`x`), 7 encounters (6-10), 2 petilasans. **NPCs: 10 spots** (Cepot, Abah Karna, Ki Darsa, kepala desa, angklung leader, Purbasari, weaver, lutung, Dayang Sumbi, batu tulis stone) vs the world.md target 3-5. See conflicts.
- [x] Petilasan `Q` (32,8) is directly before the arena (corridor 25..27), no fight between: corridor c_p2_crater and p2 hold no enemies; the crater fight E7 is before `Q`.
- [x] First appearances: table above.
- [x] One tank per encounter (Jurig in E4, E5, E7 only), at most one shooter, at most two waves (crater only).
- [x] Rooms with 4+ enemies: terraces 36x13, crater 24x13 (min 15x9). Boar lanes 8+ (validator).
- [~] Newest glyph: Ca (Dayang Sumbi) has no weakness in this zone. The newest glyph with a Tatar Sunda weakness is Nga (Bind), the clean answer in E4, E5, E7. Ca Burst is the answer to wave 2 and to Sangkuriang phase 2. See conflicts.
- [x] Quest markers: all quests.md ids and flags have a room (table above).
- [x] Critical path walkable with no glyph: nothing requires casting; kabut `G` and `H` open on quest flags set by talking and reading (not by casting), `K` on `mq1_7`.

## ASSUMED
- All spawn ids (`from_purwa`), exit targets, trigger ids (`spring_bath`, `dark_grove`, `sande_room`), prop names `post_id` and `oncor_id`, NPC ids (`kepala_desa`, `ki_darsa`, `angklung_leader`, `purbasari`, `sunda_weaver`, `lutung_kasarung`, `batu_tulis`, `cepot`), chest ids, `item_id` snake_case ids (`kujang`, `leather_armor`, `iron_ring`, `angklung_1..5`), codex id `tangkuban_perahu`, area ids, and every marker id not marked (Q).
- Two extra kabut gates (`G` flag `mq1_3`, `H` flag `mq1_5`). They only guarantee teach-then-test order for Ward and Bind. Replace the `G` and `H` tiles with `,` and the zone still works; the checks on first appearances then rest on the player's route.
- The batu tulis is an NPC-scene spot (`npc_id` `batu_tulis`): its dialogue runs `learn:sunda_nga` and `flag:mq1_5`.
- The weaver hands over the boeh rarang by dialogue (`give:boeh_rarang`), so there is no pickup spot for it. The lutung is an NPC spirit.
- "Hidden" secrets are 1-tile gaps between rocks, visible but easy to miss; no extra mechanic.
- The four oncor are plain spots; the Sandekala script lights them.
- Dark grove darkening is done by trigger `d` (tint on enter) and the Sandekala darkening by trigger `j`.

## Open questions
1. Counts vs world.md (3-5 NPCs). Quest NPCs total 10. Options: keep (recommended, all are quest-bound), or merge the weaver into the angklung leader and drop the lutung spot (trigger instead).
2. Add the new flags `mq1_3` and `mq1_5` to QuestData steps 1.3 and 1.5, or remove gates `G` and `H`?
3. E3 (batu tulis grove) uses Bandits plus Kuntilanak, not the bestiary's Jurig mix, because Bind is learned after the grove is cleared. OK?
4. Should Ca have a Tatar Sunda weakness enemy? Today only Lampor (Mataram, listed as "Ca (Sunda)") uses it.
5. Chest item ids and Cepot's "supervises from a tree" (no tree tile; Cepot stands next to the petilasan).

## Doc conflicts found (not fixed)
- bestiary.md "Encounters" Tatar Sunda mixes use 2 Kuntilanak (bamboo edge, batu tulis grove) and 1 Archer + 1 Kuntilanak (hunting party, crater path), which breaks its own and AGENTS.md "at most one shooter". Here: 1 shooter per encounter.
- bestiary.md batu tulis mix has Jurig Leuweung at MQ1 1.4, but Bind arrives at 1.5. Jurig first appears at E4 instead.
- bestiary.md "newest glyph earns its place" vs Ca (1.7) having no Tatar Sunda enemy.
- world.md "3-5 NPCs" vs quests.md needing Cepot, Abah Karna, Ki Darsa, kepala desa, angklung leader, weaver, Purbasari, Dayang Sumbi, lutung.
- quests.md SQ-S1 step 3 and 1.4 "spirits" wording: E3 holds Bandits and a Kuntilanak.
