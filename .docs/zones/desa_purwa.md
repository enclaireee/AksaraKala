# Desa Purwa (zone id `desa_purwa`)

Zone design for the start village. Step 1 of the world design workflow ([AGENTS.md](../../AGENTS.md) section 5). Targets: [world.md](../world.md) "Desa Purwa", [quests.md](../quests.md) MQ0 (Prologue, 9 steps), MQ4 4.1-4.8 (Interlude), the MQ5 epilogue, SQ-D1, SQ-D2. A builder agent turns this file into the zone scene without redesign: change the layout here first. **Story v4/v4b/v4c pass (2026-11-06):** the prologue is a day (tag, tea, errands, the show) then the raid; Ki Wangsa is cut (Semar is the dalang); the Interlude has doorposts, shelf, table and Aria; the south gate lifts on `mq4_i5`; the epilogue fills the village with people from every act. **Side stories v4d additions (2026-11-06):** SQ-C2 "Letters to Mother" ends here: the reply letter `c2_reply_letter` lies by the second cup on the Interlude table at `purwa_table` (new clue `&` (28,24), cond `flag:c2_reply`); it is a clue object, not an item, and does not change the 4.4 table setpiece or the map size.

Map: **60 x 34 tiles = 2 x 2 screens** (30 x 17 each). Coordinates are (x, y) from the top-left tile (0,0). The area is parsed by `gen_zones.py` as `## Area 1: desa_purwa` (this file now follows the region-doc format: `### Map` and `### Legend` under the Area heading; the old `## Map` / `## Legend (spots)` headings did not match the generator). Safe zone except the MQ0 raid (`purwa_raid` and its two outer skirmishes, step 0.8); the other enemy spots are the 4 training dummies in the sanggar. The zone is used four times: the Prologue (MQ0), the Interlude "The Quiet House" (MQ4 4.1-4.5, no combat), the Gua Kala gate (Act VI) and the Epilogue (after `mq5_4`, a short playable day).

Build rule: a char may repeat only when scene and props are identical (the 4 dummies, the 6 crowd villagers `p`, the 2-tile exits, the 2-tile kabut). Every other char is one spot with the floor tile listed under it (paint the floor first, then place the spot). Cond strings: `gen_zones.py` quotes every `word:` that follows a comma, so in a `cond:"..."` only the FIRST term may be positive (`flag:x`, `quest:x=y`, `step:x=n`, `item:x`); later terms must start with `!`.

## Tile chars
| Char | Tile |
|------|------|
| `#` | wall or cliff (solid) |
| `.` | grass |
| `,` | path |
| `~` | water (solid) |
| `b` | bamboo (solid); also the old banyan at (24..25,12..13) and Ciung's tree at (2..3,30..31) |
| `t` | tea terrace (walkable) |
| `r` | rock (solid) |
| `_` | indoor or wood floor |

## Area 1: desa_purwa

### Map
```
####################################################JJ######
#...................................................kk.....#
#...##################..............#############...ju.....#
#...#________________#..bb..........#_____q_____#...%.bbbb.#
#...#________________#..bb..........#______G____#.....bbbb.#
#...#___D__D__D__D___#..............#___________#.....bbbb.#
#...#________________#..............#_p_____p_p_#.....bbbb.#
#...#_______S________#..............#____$T_____#..........#
#...#_____________i__#..............#___p____L__#..........#
#...#__M_e___________#..............#_p___V____p#..........#
#...#________________#..............#####__######..........#
#...#________________#.?.................,,................#
#...########__########..bb.,,,,,,,......A,,.............r..#
#...........,,........./bb.,,,P,,,......^,,o4..............#
#...........,s........rr..Z,,,,,,,.Y.....,0.>..............#
#..h.n......,,Q.l.....!.c..,,,F,,,...U...,,................#
Ww,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,vKE
W,,,,,,,,,,,,,,,,,,,9,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,KE
#......,................7..,...g..rr.........,,............#
#......,...................z.....5..<.*......,,............#
#......,a..................,.+....:Od........,,f...........#
#...###_####............###_####.##_###.#####__######...r..#
#...#______#............#1_____#.#____#.#___________#......#
#...#______#............#2__B_m#.#____#.#___________#......#
#...#______#............#3_I&__#.#____#.#___________#......#
#...#______#............#_N__H_#.#____#.#_____R_____#......#
#...#______#..~~~~~~~...#______#.######.#___________#......#
#...########..~~~~~~~...########........#___________#.bbbb.#
#.............~~~~~~~6..................#___________#.bbbb.#
#.............~~~~~~~.;.................#############.bbbb.#
#.bb..........~~~~~~~.................................bbbb.#
#.bbC@................8.......y.......................bbbb.#
#.............................xx...........................#
##############################XX############################
```

### Legend
| Char | Entity | Scene | Props | Floor under | Tiles |
|------|--------|-------|-------|-------------|-------|
| `W` | exit to Tatar Sunda | `res://entities/world/exit.tscn` | `{target_zone:"ts_kebun", spawn_id:"from_desa_purwa"}` | path | 2 |
| `w` | spawn, arrival from Tatar Sunda | `res://entities/world/spawn.tscn` | `{id:"from_ts_kebun"}` | path | 1 |
| `v` | spawn, arrival from Keraton Galuh | `res://entities/world/spawn.tscn` | `{id:"from_kg_alun"}` | path | 1 |
| `K` | kabut, Galuh gate (one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq1_10"}` | path | 2 |
| `E` | exit to Keraton Galuh | `res://entities/world/exit.tscn` | `{target_zone:"kg_alun", spawn_id:"from_desa_purwa"}` | path | 2 |
| `I` | NPC Ibu, the hero's mother (MQ0 0.2 tea and 0.10, Interlude 4.4, epilogue cups) | `res://entities/npc/npc.tscn` | `{npc_id:"ibu"}` | floor | 1 |
| `F` | encounter purwa_raid, the plaza fight, 3 Faceless (MQ0 0.12, last of three skirmishes; `area_cleared:purwa_raid` sets `mq0_7`; v5 step index 11) | `res://entities/world/encounter.tscn` | `{area_id:"purwa_raid", cond:"step:mq0=11", size:Vector2i(14,8), waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-4,-2)], [res://entities/enemies/faceless.tscn, Vector2i(4,-2)], [res://entities/enemies/faceless.tscn, Vector2i(0,2)]]]}` | path | 1 |
| `9` | encounter purwa_raid_a, west road skirmish, 2 Faceless (MQ0 0.12, first) | `res://entities/world/encounter.tscn` | `{area_id:"purwa_raid_a", cond:"step:mq0=11", size:Vector2i(12,8), waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-3,0)], [res://entities/enemies/faceless.tscn, Vector2i(3,0)]]]}` | path | 1 |
| `0` | encounter purwa_raid_b, stage road skirmish, 2 Faceless (MQ0 0.12, second) | `res://entities/world/encounter.tscn` | `{area_id:"purwa_raid_b", cond:"step:mq0=11", size:Vector2i(12,8), waves:[[[res://entities/enemies/faceless.tscn, Vector2i(-3,0)], [res://entities/enemies/faceless.tscn, Vector2i(3,0)]]]}` | path | 1 |
| `s` | spawn, player start after class choice | `res://entities/world/spawn.tscn` | `{id:"start"}` | path | 1 |
| `P` | petilasan | `res://entities/petilasan/petilasan.tscn` | `{id:"desa_purwa"}` | path | 1 |
| `M` | NPC Semar, the village dalang (MQ0 0.5 and 0.11, Interlude 4.7; SQ-D1 lakon giver) | `res://entities/npc/npc.tscn` | `{npc_id:"semar"}` | floor | 1 |
| `e` | NPC Cepot, at Semar's side in the sanggar (MQ0 0.5) | `res://entities/npc/npc.tscn` | `{npc_id:"cepot"}` | floor | 1 |
| `R` | NPC Nyai Rukmi, codex keeper (SQ-D2) | `res://entities/npc/npc.tscn` | `{npc_id:"nyai_rukmi"}` | floor | 1 |
| `D` | training dummy (same props on all 4 tiles) | `res://entities/enemies/dummy.tscn` | `{}` | floor | 4 |
| `T` | trigger, wayang stage (MQ0 0.10 `area_entered:wayang_stage`) | `res://entities/world/trigger.tscn` | `{trigger_id:"wayang_stage", size:Vector2i(11,5)}` | floor | 1 |
| `$` | trigger, lighting the four ceremonial stage oil lamps at dusk (MQ0 0.7 `puzzle_solved:purwa_stage_lamps`) | `res://entities/world/trigger.tscn` | `{trigger_id:"purwa_stage_lamps", size:Vector2i(3,3)}` | floor | 1 |
| `S` | trigger, sanggar entered (shows draw tutorial) | `res://entities/world/trigger.tscn` | `{trigger_id:"sanggar_enter", size:Vector2i(16,9)}` | floor | 1 |
| `i` | trigger, the lontar table in the sanggar (MQ0 0.6 `area_entered:sanggar_lontar`; the write card for the hero's and Laras's names) | `res://entities/world/trigger.tscn` | `{trigger_id:"sanggar_lontar", size:Vector2i(3,3)}` | floor | 1 |
| `J` | exit to Gua Kala (P0 entry, the Act VI gate) | `res://entities/world/exit.tscn` | `{target_zone:"gk_pelataran", spawn_id:"from_desa_purwa"}` | grass | 2 |
| `k` | kabut, Gua Kala gate (one per tile), lifts when MQ4 is done (flag `mq4_9`, set by step 4.22) | `res://entities/world/kabut.tscn` | `{flag:"mq4_9"}` | grass | 2 |
| `%` | trigger, test the impenetrable fog at the northern cave mouth (Interlude 4.1 `area_entered:purwa_north_fog`) | `res://entities/world/trigger.tscn` | `{trigger_id:"purwa_north_fog", size:Vector2i(4,3)}` | grass | 1 |
| `j` | spawn, arrival from Gua Kala's courtyard | `res://entities/world/spawn.tscn` | `{id:"from_gk_pelataran"}` | grass | 1 |
| `u` | spawn, arrival home after Batara Kala (`kala_exit`) | `res://entities/world/spawn.tscn` | `{id:"from_gua_kala"}` | grass | 1 |
| `L` | pickup, Laras's lontar on the burned stage (MQ0 0.10, the deed before Ka; the `clue` piece) | `res://entities/world/pickup.tscn` | `{item_id:"laras_lontar", cond:"flag:mq0_4"}` | floor | 1 |
| `X` | exit to Segara Kidul `sk_pantai` (south edge, 2 tiles) | `res://entities/world/exit.tscn` | `{target_zone:"sk_pantai", spawn_id:"from_desa_purwa"}` | grass | 2 |
| `x` | kabut, south gate to the coast, lifts on the Semar talk (flag `mq4_i5`, step 4.7; one per tile) | `res://entities/world/kabut.tscn` | `{flag:"mq4_i5"}` | grass | 2 |
| `y` | spawn, arrival from `sk_pantai` | `res://entities/world/spawn.tscn` | `{id:"from_sk_pantai"}` | grass | 1 |
| `z` | spawn, the riders drop you here (Interlude 4.1, target of the `goto` after Act IV) | `res://entities/world/spawn.tscn` | `{id:"from_riders"}` | path | 1 |
| `N` | NPC Ciung Wanara at Ibu's table (Interlude 4.5) | `res://entities/npc/npc.tscn` | `{npc_id:"ciung_wanara", cond:"flag:mq4_2,!flag:mq4_9"}` | floor | 1 |
| `H` | NPC Hariang Banga at Ibu's table (Interlude 4.5) | `res://entities/npc/npc.tscn` | `{npc_id:"hariang_banga", cond:"flag:mq4_2,!flag:mq4_9"}` | floor | 1 |
| `h` | NPC the Nameless Hunter at the west gate, staging for the `hunter_raid` beat (no talk; `npc_id` ASSUMED) | `res://entities/npc/npc.tscn` | `{npc_id:"nameless_hunter", cond:"flag:mq0_7,!flag:beat_hunter_raid"}` | grass | 1 |
| `n` | NPC Nini Balangantrang at the west gate, speaks in the `hunter_raid` beat (display name "the old woman"; no talk of her own) | `res://entities/npc/npc.tscn` | `{npc_id:"nini_balangantrang", cond:"flag:mq0_7,!flag:beat_hunter_raid"}` | grass | 1 |
| `m` | codex spot, the Hunter's empty mask in the hearth (Interlude, id ASSUMED; hidden until MQ3 is done so the codex cannot spoil him) | `res://entities/world/pickup.tscn` | `{codex_id:"hunter_mask", cond:"quest:mq3=done"}` | floor | 1 |
| `l` | NPC Laras, the tag partner; runs the route, then waits at the last stop (MQ0 0.1; `npc_id` ASSUMED, the route is read by the NPC script) | `res://entities/npc/npc.tscn` | `{npc_id:"laras_tag", cond:"!flag:mq0_d1", route:[Vector2i(16,16), Vector2i(26,17), Vector2i(34,14), Vector2i(31,11), Vector2i(26,14)]}` | grass | 1 |
| `Z` | trigger, tag game ends at the old well, a few steps south of the banyan (MQ0 0.1 `area_entered:purwa_tag_end`, sets `mq0_d1`; plays beat `tag_end`; the well is dressing at this trigger, **ASSUMED**, no separate tile) | `res://entities/world/trigger.tscn` | `{trigger_id:"purwa_tag_end", size:Vector2i(3,3)}` | grass | 1 |
| `c` | NPC the stray cat; Laras calls it by its "real name" and it comes (MQ0 0.1 beat, no talk; the old banyan beside it shivers) | `res://entities/npc/npc.tscn` | `{npc_id:"stray_cat", cond:"!flag:mq0_d1"}` | grass | 1 |
| `O` | NPC the old couple outside their door (house_c); the lead-in talk before Ciung (MQ0 0.2, Interlude 4.2) | `res://entities/npc/npc.tscn` | `{npc_id:"purwa_old_couple", cond:"!flag:mq0_d3"}` | grass | 1 |
| `@` | trigger, climb the banyan ridge to Ciung Wanara (MQ0 0.3 `puzzle_solved:purwa_banyan_climb`) | `res://entities/world/trigger.tscn` | `{trigger_id:"purwa_banyan_climb", size:Vector2i(3,3)}` | grass | 1 |
| `C` | NPC Ciung Wanara up the big tree with his egg (MQ0 0.3, `talked_to:ciung_wanara` sets `mq0_d3`; he stays up the tree until the Semar talk, `mq0_d4`, step 0.5, since he walks with you in the v5 script) | `res://entities/npc/npc.tscn` | `{npc_id:"ciung_wanara", cond:"flag:mq0_d2,!flag:mq0_d4"}` | grass | 1 |
| `8` | codex spot, the old banyan shrine on the road to the tree (MQ0 0.3 `travel` find; id ASSUMED) | `res://entities/world/pickup.tscn` | `{codex_id:"banyan"}` | grass | 1 |
| `Y` | NPC the stall-keeper at the market stall (MQ0 0.4, which now comes before the sanggar, sets `mq0_d6`; and Interlude 4.2 `talked_to:purwa_stall`; the spot stays from `mq0_d3` on, the entries pick the talk; asks children's names, "a tall man in a blank mask") | `res://entities/npc/npc.tscn` | `{npc_id:"purwa_stall", cond:"flag:mq0_d3"}` | grass | 1 |
| `q` | clue, the lamp behind the kelir; examining it pulls you into K0 (MQ0 0.8, after the lamps are lit (`mq0_d6b`, step 0.7), `memory_id` `k0_ruwatan`) | `res://entities/world/clue.tscn` | `{clue_id:"kelir_lamp", memory_id:"k0_ruwatan", cond:"flag:mq0_d6b,!flag:memory_k0_ruwatan"}` | floor | 1 |
| `p` | NPC villager in the show crowd (same props on all 6 tiles; dressing, they scatter in the `raid` beat) | `res://entities/npc/npc.tscn` | `{npc_id:"villager", cond:"!flag:mq0_d8"}` | floor | 6 |
| `V` | trigger, the crowd in front of the kelir (MQ0 0.9 `area_entered:purwa_crowd`) | `res://entities/world/trigger.tscn` | `{trigger_id:"purwa_crowd", size:Vector2i(9,3)}` | floor | 1 |
| `G` | NPC Laras in the crowd, she looks up at the tallest shadow (MQ0 0.9 `raid` beat; taken by the Hunter) | `res://entities/npc/npc.tscn` | `{npc_id:"laras_crowd", cond:"flag:mq0_d7,!flag:beat_raid"}` | floor | 1 |
| `a` | doorpost 1, house_b (Interlude 4.3, write card seq `door_a`; NPC-scene whose entry runs `write:door_a:...`) | `res://entities/npc/npc.tscn` | `{npc_id:"door_a", cond:"step:mq4=2"}` | grass | 1 |
| `d` | doorpost 2, house_c (Interlude 4.3, `door_b`) | `res://entities/npc/npc.tscn` | `{npc_id:"door_b", cond:"step:mq4=2"}` | grass | 1 |
| `f` | doorpost 3, the pustaka (Interlude 4.3, `door_c`) | `res://entities/npc/npc.tscn` | `{npc_id:"door_c", cond:"step:mq4=2"}` | grass | 1 |
| `1` | clue, Ibu's shelf: set the ribbon down (Interlude 4.4, ids ASSUMED) | `res://entities/world/clue.tscn` | `{clue_id:"shelf_ribbon", cond:"item:laras_ribbon,!flag:mq4_2"}` | floor | 1 |
| `2` | clue, Ibu's shelf: set the wagon board down (Interlude 4.4) | `res://entities/world/clue.tscn` | `{clue_id:"shelf_board", cond:"item:laras_board,!flag:mq4_2"}` | floor | 1 |
| `3` | clue, Ibu's shelf: set the Ka strip down (Interlude 4.4) | `res://entities/world/clue.tscn` | `{clue_id:"shelf_strip", cond:"item:laras_strip_ka,!flag:mq4_2"}` | floor | 1 |
| `&` | clue, the queen's reply letter by the second cup on the table (SQ-C2 step 4, Interlude after 4.5: `clue_examined:c2_reply_letter`; appears only if the letters were given to the queen in Galuh, i.e. `c2_reply` is set; the player reads it or leaves it folded, no item; the letter's lines vary by `choice_mercy` or `choice_judgment`) | `res://entities/world/clue.tscn` | `{clue_id:"c2_reply_letter", cond:"flag:c2_reply"}` | floor | 1 |
| `B` | trigger, the table; starts the dinner setpiece (Interlude 4.5 `area_entered:purwa_table`) | `res://entities/world/trigger.tscn` | `{trigger_id:"purwa_table", size:Vector2i(5,4), cond:"flag:mq4_2,!flag:mq4_i3"}` | floor | 1 |
| `A` | NPC Aria Kebonan by the burned stage (Interlude 4.6 `talked_to:aria_kebonan`) | `res://entities/npc/npc.tscn` | `{npc_id:"aria_kebonan", cond:"flag:mq4_i3,!flag:mq4_9"}` | grass | 1 |
| `Q` | NPC Laras, home again; wakes you and dares you to tag (epilogue, `flag:mq5_4`) | `res://entities/npc/npc.tscn` | `{npc_id:"laras", cond:"flag:mq5_4"}` | grass | 1 |
| `g` | NPC the elder's grandson with his angklung (epilogue) | `res://entities/npc/npc.tscn` | `{npc_id:"sunda_grandson", cond:"flag:mq5_4"}` | grass | 1 |
| `U` | NPC Uwa Lengser (epilogue) | `res://entities/npc/npc.tscn` | `{npc_id:"lengser", cond:"flag:mq5_4"}` | grass | 1 |
| `o` | NPC Ki Sumarto, setting up his show (epilogue) | `res://entities/npc/npc.tscn` | `{npc_id:"mataram_dalang", cond:"flag:mq5_4"}` | grass | 1 |
| `4` | NPC Sapto, Ki Sumarto's son (epilogue) | `res://entities/npc/npc.tscn` | `{npc_id:"sapto", cond:"flag:mq5_4"}` | grass | 1 |
| `5` | NPC Ratna, Mpu Wirasana's daughter (epilogue; `timur_daughter`, quests.md section 8; Choice 4 talk) | `res://entities/npc/npc.tscn` | `{npc_id:"timur_daughter", cond:"flag:mq5_4"}` | grass | 1 |
| `6` | NPC Mbah Wiryo at the pond (epilogue) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_jurukunci", cond:"flag:mq5_4"}` | grass | 1 |
| `7` | NPC the Faceless Deserter, if freed (epilogue; Choice 2 is exclusive, so `!flag:choice_handed` means freed; his entries also need `choice_freed`) | `res://entities/npc/npc.tscn` | `{npc_id:"faceless_deserter", cond:"flag:mq5_4,!flag:choice_handed"}` | grass | 1 |
| `!` | trigger, tag beat at the cat (MQ0 0.1, area `purwa_tag_cat` sets `tag_cat`, **ASSUMED**; plays beat `tag_cat` while `step:mq0=0`) | `res://entities/world/trigger.tscn` | `{trigger_id:"purwa_tag_cat", size:Vector2i(3,3), cond:"!flag:mq0_d1"}` | grass | 1 |
| `?` | trigger, tag beat at the old banyan (MQ0 0.1, area `purwa_tag_banyan` sets `tag_banyan`, **ASSUMED**; plays beat `tag_banyan` while `step:mq0=0`) | `res://entities/world/trigger.tscn` | `{trigger_id:"purwa_tag_banyan", size:Vector2i(3,3), cond:"!flag:mq0_d1"}` | grass | 1 |
| `/` | trigger, the old banyan blur (epilogue beat `epi_banyan`, area `epi_banyan`, **ASSUMED**; only after Choice 5, Offer Memory) | `res://entities/world/trigger.tscn` | `{trigger_id:"epi_banyan", size:Vector2i(3,3), cond:"flag:beat_epi_wake,flag:choice_offer_memory"}` | grass | 1 |
| `*` | NPC Hariang Banga in the village (epilogue, Choice 3 talk; the table seat `H` is the Interlude one) | `res://entities/npc/npc.tscn` | `{npc_id:"hariang_banga", cond:"flag:mq5_4"}` | grass | 1 |
| `<` | NPC Ciung Wanara in the village (epilogue, Choices 1 and 3, hub; the tree spot `C` and the table seat `N` are earlier ones) | `res://entities/npc/npc.tscn` | `{npc_id:"ciung_wanara", cond:"flag:mq5_4"}` | grass | 1 |
| `+` | NPC Dewi Naganingrum (epilogue, Choice 1 talk) | `res://entities/npc/npc.tscn` | `{npc_id:"naganingrum", cond:"flag:mq5_4"}` | grass | 1 |
| `>` | NPC Cepot by the ruwatan stage, bragging to the village children (epilogue, SQ-C4; the sanggar spot `e` is the prologue one) | `res://entities/npc/npc.tscn` | `{npc_id:"cepot", cond:"flag:mq5_4"}` | grass | 1 |
| `;` | NPC Sari, the singer from Segara Kidul (epilogue, Choice 5 talk) | `res://entities/npc/npc.tscn` | `{npc_id:"kidul_sari", cond:"flag:mq5_4"}` | grass | 1 |
| `:` | NPC Mpu Wirasana (epilogue, Choice 4 reforge talk) | `res://entities/npc/npc.tscn` | `{npc_id:"timur_empu", cond:"flag:mq5_4,flag:choice_reforge"}` | grass | 1 |
| `^` | NPC Aria Kebonan at the ashes of the burned stage (epilogue, Choice 6; the Interlude spot `A` ends at `mq4_9`) | `res://entities/npc/npc.tscn` | `{npc_id:"aria_kebonan", cond:"flag:mq5_4"}` | grass | 1 |

Exits sit on the map edge (x = 0 and x = 59, rows 16-17; the south exit `X` at (30..31,33); the north exit `J` at (52..53,0)). Each exit has a spawn one tile inside: `w` (1,16) for the west exit, `v` (58,16) for the east one. The east gate is two kabut tiles `K` at (58,16) and (58,17), between `v` and the exit `E`. The south gate is two kabut tiles `x` at (30..31,32), between the spawn `y` (30,31) and the exit `X`.

## Room table
| id | tile rect (x,y) size | purpose | contents | quest markers |
|----|----------------------|---------|----------|---------------|
| sanggar | (5,3)-(20,11) 16x9 interior, walls (4,2)-(21,12), door (12..13,12) | Practice hall and Semar's workshop: draw glyphs, kill dummies, write the names | Semar `M` (7,9), Cepot `e` (9,9), 4 dummies `D` at (8,5) (11,5) (14,5) (17,5), trigger `S` (12,7), lontar table `i` (18,8); open floor y 6-11 to draw in | `semar`, `cepot`, `sanggar`, `sanggar_lontar`, `dummies` |
| plaza | (27,12)-(33,15) 7x4 | Hub, first petilasan, 2 tiles from the road; the raid's last skirmish; the tag loop (a 7x4 ring round `P`) | petilasan `P` (30,13), encounter `F` (30,15), rocks | `pet_desa_purwa`, `purwa_raid` |
| old banyan | (24,12)-(25,13) 2x2 solid, cat `c` (24,15), tag end `Z` (26,14) | The tag game: Laras calls the cat (`!` (22,15)), the banyan shivers (`?` (23,11)), and she is caught at the old well, `Z` (26,14) | banyan `b` x4, `c`, `!`, `?`, `Z` (the well) | `purwa_tag_cat`, `purwa_tag_banyan`, `purwa_tag_end` |
| market | (34,13)-(36,15) | One stall at the plaza's east edge, 3 tiles from the road | stall-keeper `Y` (35,14) | `purwa_stall` |
| stage | (37,3)-(47,9) 11x7, walls (36,2)-(48,10), door (41..42,10) | The wayang stage: the ruwatan night (K0, the crowd), then burned | kelir lamp `q` (42,3), crowd `p` x6, Laras `G` (43,4), crowd trigger `V` (42,9), trigger `T` (42,7), lontar `L` (45,8) | `kelir_lamp`, `purwa_crowd`, `wayang_stage`, `laras_lontar` |
| pustaka | (41,22)-(51,28) 11x7, door (45..46,21) | Codex keeper's house; doorpost 3 | Nyai Rukmi `R` (46,25), doorpost `f` (47,20) | `nyai_rukmi`, `door_c` |
| house_a | (25,22)-(30,26), door (27,21) | Ibu's house; the Interlude table. Door column x = 27 (y 22..23) stays free | Ibu `I` (27,24); shelf clues `1` (25,22) `2` (25,23) `3` (25,24); table trigger `B` (28,23), SQ-C2 reply letter `&` (28,24) by the second cup; Interlude: Ciung `N` (26,25), Hariang `H` (29,25), codex mask `m` (30,23) | `ibu`, `quiet_house`, `purwa_table`, `shelf_*` |
| house_b | (5,22)-(10,26), door (7,21) | Empty house; doorpost 1 | doorpost `a` (8,20) | `door_a` |
| house_c | (34,22)-(37,25), walls (33,21)-(38,26), door (35,21) | The old couple's house, next door to Ibu (5 tiles east); doorpost 2 | old couple `O` (35,20), doorpost `d` (36,20) | `purwa_old_couple`, `door_b` |
| tree | (2,30)-(4,31) | Ciung's tree (the 2x2 `b` block) and the road to it from the pond side | Ciung `C` (4,31), banyan shrine codex `8` (22,31) | `ciung_wanara`, `banyan` |
| start path | (12..13,13..15) | Start landing, 2 tiles below the sanggar door | spawn `s` (13,14), Laras (tag partner) `l` (16,15), Laras epilogue `Q` (14,15) | none |
| west road | (1,16)-(12,17) | Exit to Tatar Sunda; the `hunter_raid` beat is staged just north of it; the raid's first skirmish | spawn `w` (1,16), exit `W` (0,16..17), Hunter `h` (3,15) and Nini `n` (5,15), skirmish `9` (20,17) | `exit_tatar_sunda`, `purwa_raid_a` |
| stage road | (41,11)-(42,15) | Path from the stage door to the east road; the raid's second skirmish; epilogue ruwatan-stage crew; Aria's seat | skirmish `0` (42,14), Aria `A` (40,12), Ki Sumarto `o` (43,13), Sapto `4` (44,13) | `purwa_raid_b`, `aria_kebonan` |
| arrival | (27,19) | Interlude landing, 2 tiles north of Ibu's door | spawn `z` (27,19) | `from_riders` |
| east road | (47,16)-(58,17) | Fogged exit to Keraton Galuh | spawn `v` (58,16), kabut `K` (58,16..17), exit `E` (59,16..17) | `exit_mataram` |
| north gap | (52..53,0..2) | Fogged exit to Gua Kala. In the Interlude the fog at the mouth eats every glyph you throw at it (it is the `k` kabut) | exit `J` (52..53,0), kabut `k` (52..53,1) flag `mq4_9`, spawns `j` (52,2) and `u` (53,2) | `exit_gua_kala`, `gua_kala_fog` |
| south gap | (30..31,31..33) | Fogged exit to Segara Kidul, lifts on the Semar talk (4.5) | spawn `y` (30,31), kabut `x` (30..31,32) flag `mq4_i5`, exit `X` (30..31,33) | `exit_pantai` |
| epilogue spots | plaza, stage road and south lane | People from every act, all `cond:"flag:mq5_4"` (plus the choice shown in the legend) | grandson `g` (31,18), Ratna `5` (33,19), Wirasana `:` (34,20), Lengser `U` (37,15), Deserter `7` (24,18), Mbah Wiryo `6` (21,28), Sari `;` (22,29), Hariang `*` (38,19), Ciung `<` (36,19), Naganingrum `+` (29,20), Cepot `>` (44,14), Aria `^` (40,13), banyan blur trigger `/` (23,13) | `epi_banyan` |
| green | (1,1)-(58,32) rest | Open grass, pond (14..20,26..30), bamboo and rock dressing | none | none |

## Encounter table
| id | spot | cond | waves | notes |
|----|------|------|-------|-------|
| `purwa_raid_a` | `9` (20,17), 12x8 | `step:mq0=11` (step 0.12) | 2 Faceless | First skirmish, on the west road. Not a quest event |
| `purwa_raid_b` | `0` (42,14), 12x8 | `step:mq0=11` | 2 Faceless | Second skirmish, on the stage road. Not a quest event |
| `purwa_raid` | `F` (30,15), 14x8 | `step:mq0=11` | 3 Faceless | The last of three skirmishes; `area_cleared:purwa_raid` completes the fight half of step 0.12 (`fight x3`; `mq0_7`, then the walk to `ts_kebun`). The 4 dummies stay plain placed spots for the Ka practice (0.7) |

The cond is the 0-based index of step 0.8 (0.1 is index 0). Skirmishes `9` and `0` start when step 0.8 is current; the three are independent and the order is free.

## Piece placement per step (story v5)
Every piece in the `Play` column of quests.md 4 has a place. `travel` pieces are walks through a changed village with one thing to find (the village is safe, so their "encounters" are talks and the tag stops, **ASSUMED**).

| Step | Pieces | Place |
|------|--------|-------|
| 0.1 | `setpiece, talk` | Tag game, v5: cat trigger `!` (22,15) and banyan trigger `?` (23,11) play `tag_cat` and `tag_banyan`; the catch is at the well `Z`.  `s` (13,14) -> Laras `l` (16,15) runs the `route` (road east, plaza, round `P`, north of the banyan) and ends at `Z` (26,14). The cat `c` (24,15) comes at its real name; the banyan (24..25,12..13) shivers. Sets `mq0_d1` |
| 0.2 | `talk x2, clue, beat` | Ibu `I` (27,24) (tea, two cups) -> old couple `O` (35,20) at the house_c door (`mq0_d2`, `mq0_d2b`) |
| 0.3 | `travel, puzzle, talk` | Travel west along the south lane past the pond to the big tree: codex `8` (22,31) is the find -> climb trigger `@` (5,31) (`purwa_banyan_climb`) -> Ciung `C` (4,31) (`mq0_d3`) |
| 0.4 | `travel, clue, talk` | Walk the morning market with Laras to the stall `Y` (35,14) (`talked_to:purwa_stall`, sets `mq0_d6`); v5: this is before the sanggar |
| 0.5 | `travel, talk x2` | Semar `M` (7,9) (`mq0_d4`) and Cepot `e` (9,9) (`mq0_d4b`) in the sanggar |
| 0.6 | `puzzle, write, beat` | Lontar table `i` (18,8) (`sanggar_lontar`, write card, sets `mq0_d5`) |
| 0.7 | `travel, puzzle, talk` | Stage lamps trigger `$` (41,7) (`puzzle_solved:purwa_stage_lamps`, sets `mq0_d6b`; beat `lamps_lit`) |
| 0.8 | `memory, beat` | Behind the kelir: clue `q` (42,3) -> K0 (`zones/kelir/k0_ruwatan.tscn`, below) -> back at `q`; the dalang reads the children's names (`mq0_d7`) |
| 0.9 | `setpiece, beat` | Crowd `p` x6 and Laras `G` (43,4) in the stage; trigger `V` (42,9) (`purwa_crowd`, sets `mq0_d8`); the `raid` beat |
| 0.10 | `talk, beat, clue, travel` | Ibu `I` (second talk, `mq0_4`) -> stage trigger `T` (42,7) -> lontar `L` (45,8) (`laras_lontar`, sets `mq0_5`) |
| 0.11 | `talk, lesson, fight x2` | Semar `M`, Ka lesson (`glyph_learned:sunda_ka`); Ka x3 on the dummies `D` (8,5) (11,5) (14,5) (17,5) |
| 0.12 | `fight x2, beat, travel` | `9` west road, `0` stage road, `F` plaza (all `step:mq0=11`; `purwa_raid`, sets `mq0_7`); `hunter_raid` beat at `h` (3,15) and `n` (5,15), then west road `W` (0,16..17) to `ts_kebun` |
| 4.1 | `travel, beat` | Riders drop you at `z` (27,19) (beat `eclipse_home`, `step:mq4=0`); walk north to test the fog `%` (52,3) (`purwa_north_fog`, sets `mq4_i0`) |
| 4.2 | `talk x2, clue` | Old couple `O` (35,20) and stall-keeper `Y` (35,14) (`mq4_i0b`) |
| 4.3 | `travel, write x3` | Doorposts `a` (8,20), `d` (36,20), `f` (47,20), each cond `step:mq4=2`; each opens a write card (`door_a`, `door_b`, `door_c`, sets `mq4_i1`) |
| 4.4 | `clue x3, talk, beat` | Shelf clues `1` `2` `3` in house_a (`shelf_ribbon`, `shelf_board`, `shelf_strip`), then Ibu `I` (27,24) (sets `mq4_2`) |
| 4.5 | `setpiece, talk, beat` | Table trigger `B` (28,23) (`purwa_table`, cond `flag:mq4_2,!flag:mq4_i3`, sets `mq4_i3`; beats `table_dishes`, then `quiet_house` or `quiet_house_judgment` by Choice 3); Ciung `N` (26,25) and Hariang `H` (29,25) seated; SQ-C2 reply letter `&` (28,24) |
| 4.6 | `talk x2, beat` | Aria `A` (40,12) (`talked_to:aria_kebonan`, sets `mq4_i4`) |
| 4.7 | `talk x2, beat` | Semar `M` (7,9) in the sanggar (`talked_to:semar`, sets `mq4_i5`, lifts `x`) |
| 4.8 | `travel, talk` | South gate `X` (30..31,33) to `sk_pantai` (`zone_entered:sk_pantai`, sets `mq4_i6`) |

## Quest markers per step
Marker form `{zone: "desa_purwa", id: ...}`. Step numbers follow [quests.md](../quests.md) section 4 (story v5).

| Step | Marker id | Spot | Completes on |
|------|-----------|------|--------------|
| 0.1 catch Laras | `purwa_tag_cat`, `purwa_tag_banyan`, `purwa_tag_end` | `!` (22,15), `?` (23,11), `Z` (26,14, the well) | `area_entered:purwa_tag_end`, sets `mq0_d1` |
| 0.2 tea and old couple | `ibu`, `purwa_old_couple` | `I` (27,24), `O` (35,20) | `talked_to:ibu` sets `mq0_d2`; `talked_to:purwa_old_couple` sets `mq0_d2b` |
| 0.3 banyan ridge and Ciung | `purwa_banyan_climb`, `ciung_wanara` | `@` (5,31), `C` (4,31) | `puzzle_solved:purwa_banyan_climb`; `talked_to:ciung_wanara` sets `mq0_d3` |
| 0.4 morning market (before the sanggar) | `purwa_stall` | `Y` (35,14) | `talked_to:purwa_stall`, sets `mq0_d6` |
| 0.5 sanggar | `semar`, `cepot` | `M` (7,9), `e` (9,9) | `talked_to:semar` sets `mq0_d4`; `talked_to:cepot` sets `mq0_d4b` |
| 0.6 write names | `sanggar_lontar` | `i` (18,8) | `area_entered:sanggar_lontar`, sets `mq0_d5` |
| 0.7 stage oil lamps | `purwa_stage_lamps` | `$` (41,7) | `puzzle_solved:purwa_stage_lamps`, sets `mq0_d6b` |
| 0.8 the show | `kelir_lamp` (`k0_ruwatan`) | `q` (42,3) | `memory_done:k0_ruwatan`, sets `mq0_d7` |
| 0.9 the crowd | `purwa_crowd` | `V` (42,9) | `area_entered:purwa_crowd`, sets `mq0_d8`; plays `raid` |
| 0.10 Ibu, then the lontar | `ibu`, `laras_lontar` | `I` (27,24), `T` (42,7), `L` (45,8) | `talked_to:ibu` sets `mq0_4`; `item_picked:laras_lontar` sets `mq0_5` |
| 0.11 Ka | `semar`, `sanggar` | `M` (7,9), `S` (12,7) | `glyph_learned:sunda_ka`; `spell_cast:sunda_ka` x3 (dummies) |
| 0.12 raid and west gate | `purwa_raid`, `exit_tatar_sunda` | `F` (30,15), `W` (0,16..17), `h` (3,15), `n` (5,15) | `area_cleared:purwa_raid`, sets `mq0_7`; then `zone_entered:ts_kebun` (after beat `hunter_raid` & clue `mask_gate`) |
| MQ1 end | - | - | the `naga` beat in Tatar Sunda sets `mq1_10`, kabut `K` (Galuh road) lifts |
| 4.1 return & north fog | `from_riders`, `purwa_north_fog` | `z` (27,19), `%` (52,3) | `zone_entered:desa_purwa`; then `area_entered:purwa_north_fog`, sets `mq4_i0` |
| 4.2 bewildered villagers | `purwa_old_couple`, `purwa_stall` | `O` (35,20), `Y` (35,14) | `talked_to:purwa_old_couple`; then `talked_to:purwa_stall`, sets `mq4_i0b` |
| 4.3 doorposts (`step:mq4=2`) | `door_a`, `door_b`, `door_c` | `a`, `d`, `f` | `all`: `name_written:door_a`, `door_b`, `door_c`, sets `mq4_i1` |
| 4.4 Ibu's shelf | `shelf_ribbon`, `shelf_board`, `shelf_strip`, `ibu` | `1` `2` `3`, `I` | `all`: `clue_examined:shelf_ribbon`, `shelf_board`, `shelf_strip`; then `talked_to:ibu`, sets `mq4_2` |
| 4.5 the table | `purwa_table` | `B` (28,23), `N`, `H`, mask `m` | `area_entered:purwa_table`, sets `mq4_i3`; beat `quiet_house` |
| SQ-C2 (4) the reply letter | `c2_reply_letter` | `&` (28,24) | `clue_examined:c2_reply_letter`, cond `flag:c2_reply` |
| 4.6 Aria Kebonan | `aria_kebonan` | `A` (40,12) | `talked_to:aria_kebonan`, sets `mq4_i4` |
| 4.7 Semar | `semar` | `M` (7,9) | `talked_to:semar`, sets `mq4_i5` (lifts kabut `x`, opens the south exit `X`) |
| 4.8 walk south | `exit_pantai` | `X` (30..31,33) | `zone_entered:sk_pantai`, sets `mq4_i6` |
| MQ5 start | `exit_gua_kala` | `J` (52..53,0) | opens on `mq4_9` (MQ4 done); the finale gate |
| Epilogue | `epi_banyan` | `Q` `g` `U` `o` `4` `5` `6` `7` `*` `<` `+` `>` `;` `:` `^`, trigger `/` | `flag:mq5_4`: the village as listed in the room table; beats `epi_wake`, `epi_banyan` (Choice 5, Offer Memory), `epi_show` (area `wayang_stage`, evening); not quest steps |
| SQ-D1 Lakon (giver Semar, the village dalang) | `semar` | `M` | watch lakon at the stage; the Ki Wangsa giver is cut |
| SQ-D2 Pustaka (giver Nyai Rukmi) | `nyai_rukmi` | `R` | codex thresholds |
| Petilasan | `desa_purwa` | `P` | `petilasan_activated:desa_purwa` |

Flags in this zone: `mq1_10` on the `K` kabut (set by the `naga` beat), `mq4_i5` on the `x` kabut, `mq4_9` on the `k` kabut. Hunter appearances here: the west gate (Prologue) and his empty mask `m` (Interlude).

## Flow
Prologue: class choice -> `s` outside the sanggar -> tag with Laras round the plaza and the banyan (0.1) -> Ibu's tea `I` -> the old couple `O` -> west to Ciung's tree `C` (0.2) -> north to Semar `M` and Cepot `e`, write at `i`, east to the stall `Y` (0.3) -> the stage: lamp `q`, K0 (0.4) -> crowd `V`, the raid beat (0.5) -> next morning: Ibu, the burned stage, lontar `L` (0.6) -> Semar, Ka, dummies (0.7) -> three skirmishes `9`, `0`, `F` (0.8) -> the Hunter at the west gate, west road `W` to Tatar Sunda (0.9). Optional: plaza petilasan `P`, Nyai Rukmi `R`. The village is a clockwise loop (centre, south-west, north-west, east, north-east) with no walk repeated. The east road to Keraton Galuh stays fogged until `mq1_10`.

Interlude: the riders drop you at `z` (4.1) -> three doorposts `a`, `d`, `f` (4.2) -> shelf and Ibu `I` (4.3) -> the dinner `B` with `N` and `H` (4.4) -> Aria `A` (optional), Semar `M`, the south gate `x` lifts (4.5), south through `X` to `sk_pantai`. The north fog `k` stays shut (it eats every glyph) until MQ4 is done; then `J` leads to Gua Kala.

Epilogue: after `mq5_4` the village wakes: Laras `Q` dares you to tag (the same route as 0.1, mirrored), Ibu pours two cups, then you walk past `g`, `5`, `U`, `o`, `4`, `6` (and `7` if freed) while the ruwatan stage is rebuilt (`L`'s pickup is gone, the `T` stage trigger plays Semar's closing show).

## Kelir memory K0: `zones/kelir/k0_ruwatan.tscn`
Own scene (not part of this area), kind `play`, one screen 30 x 17, entered from clue `q` (`Zones.enter_memory("k0_ruwatan")`), returns to `q`. Not generated by `gen_zones.py`; the builder reads this section ([architecture.md](../architecture.md) 9b).
```
##############################
#............................#
#............................#
#............................#
#............................#
#............................#
#............................#
#.s..L....L.....L.....L....g.#
#............................#
#............................#
#............................#
#............................#
#............................#
#............................#
#............................#
#............................#
##############################
```
| Marker | What | Notes |
|--------|------|-------|
| `s` (2,7) | `Stand`, the stand-in: a wayang figure of the hero (`stand_in.tscn`, speed 70) | enters from the left of the kelir |
| `L` (5,7) (10,7) (16,7) (22,7) | four lamp stands; each lights a 120 px circle (the `lamp_pos` shader, radius 120 **TUNE**) | the first is lit; you light the others (`action_kind` `light`, `interact`) |
| `g` (27,7) | goal, the right edge of the kelir | reaching it ends the walk |
| shadow | Kala's shadow, a dark band that advances from the right edge at 1 tile/s and swallows unlit ground; it stops at lit ground | start x = 29 **TUNE** |
- **Stand-in and action.** The hero as a wayang figure; one action, `interact` at a lamp stand lights it. Teaches the kelir controls and "stand in the lamp's light".
- **Goal.** Walk to the right edge before the shadow reaches you; stay in a lit circle when it is near.
- **Checkpoints.** Each lit lamp stand is a `Checkpoint` marker; `fail()` (the shadow touches you) fades to the lamp and restarts at the last lit stand, no HP loss.
- **Narration.** Semar at the start (`MEM_K0_START_1..2`) and the end: Kala, the four Seals, Sangkuriang; then the dalang reads the children's names aloud, Ciung's among them (`MEM_K0_END_1..2`). About 3 minutes (**TUNE**).

## Callback spots (Act VI gap memories, story v4b thread 5)
The Act VI memories `la`, `ra`, `sa` replay prologue-day spots, so the builder keeps them recognisable and reuses these coordinates for `GapMemoryData.scene_spot`: **La, the tag game**: the plaza loop with the cat `c` (24,15) and the banyan (24..25,12..13), tag end `Z` (26,14). **Ra, the two cups**: house_a, Ibu `I` (27,24) and the table (25..30,22..26). **Sa, the written names**: the sanggar lontar table `i` (18,8) beside Semar `M` (7,9). Nothing in these spots may be removed or moved after v4c without updating `gap_*.tres`.

## Validation
Run with `python3 check.py` (a read-only checker kept in the session scratch folder; it mirrors the `gen_zones.py` parse: Area heading, `### Map`, `### Legend` rows with 5+ cells). `gen_zones.py` was NOT run (it writes `zones/*.gd`).
```
PASS desa_purwa map is 60x34 (60x34 = 2x2 screens)
PASS desa_purwa every non-tile char is in the legend (missing [])
PASS desa_purwa every legend char is in the map (unused [])
PASS desa_purwa legend counts match the map (bad [])
PASS desa_purwa map edge solid except exit chars ['E', 'J', 'W', 'X'] (violations [])
PASS desa_purwa exit E is 2 adjacent tiles on the map edge
PASS desa_purwa exit J is 2 adjacent tiles on the map edge
PASS desa_purwa exit W is 2 adjacent tiles on the map edge
PASS desa_purwa exit X is 2 adjacent tiles on the map edge
PASS desa_purwa BFS from spawn (1, 16), gates open: all 74 spot tiles reachable (unreachable [])
RESULT: 10 checks, 0 FAIL
```

## Step 2 checklist
Desa Purwa has four fights, all in the MQ0 raid (`purwa_raid_a`, `purwa_raid_b`, `purwa_raid`) plus the dummy practice; the Interlude has no combat.
- [x] Every MQ0 step 0.1-0.9, MQ4 4.1-4.5 step and the epilogue in quests.md section 4 has a marker or spot above (the piece table lists each piece).
- [x] No enemy before the raid: the tag, the walk, the errands and the show are safe; skirmishes `9` and `0` and the plaza `F` are cond `step:mq0=11` (step 0.12).
- [x] Interlude: no combat spot is enabled; the `N`/`H`/`1`-`3`/`B` spots sit inside house_a without blocking the door column x = 27; the doorposts stand on grass beside the doors.
- [x] Ki Wangsa `G` is removed; `G` is now the crowd Laras. SQ-D1's giver is Semar.
- [x] The whole critical path is walkable without a glyph (kabut open on flags set by talking: `mq1_10`, `mq4_i5`, `mq4_9`).
- [x] Rule 5: no return trip is empty. The village is a loop; the Interlude is one changed-village loop (doorposts, shelf, table, sanggar) and the south gate is its end.
- [x] Rule 7: Desa Purwa holds optional finds: banyan shrine codex `8`, Nyai Rukmi's pustaka (SQ-D2), the stage (SQ-D1), the Hunter mask codex `m`.

## ASSUMED
- **Story v5 (2026-11-06):** the market (0.4) comes before the sanggar, so the stall-keeper `Y` stands from `mq0_d3` on and the kelir lamp `q` needs `mq0_d6b` (the lamps, 0.7). The raid fights use `step:mq0=11` (step 0.12). The tag catch is at the old well, which is dressing at the existing trigger `Z` (26,14), a few steps from the banyan (coordinates kept for the `la` callback); new ASSUMED tag triggers `purwa_tag_cat` `!` and `purwa_tag_banyan` `?`. The doorposts use `step:mq4=2` (step 4.3). The epilogue cast is the v5 one: new spots `*` Hariang, `<` Ciung, `+` Naganingrum, `>` Cepot, `;` Sari, `:` Wirasana (`choice_reforge`), `^` Aria, and `5` is now `timur_daughter` (Ratna); the `epi_banyan` area trigger is `/`. The choice flags in epilogue conds are Choice 1 `choice_tell_ciung`/`choice_keep_secret`, Choice 2 `choice_freed`/`choice_handed`, Choice 3 `choice_mercy`/`choice_judgment`.
- Back route to Segara Kidul (**ASSUMED** 2026-11-06, quests.md Gating v3.1, updated v4b): a south exit `X` (30..31,33) to `sk_pantai`, drawn into the map now. The kabut `x` (30..31,32) lifts on `flag:mq4_i5` (the Semar talk, step 4.5), not on a boss. The arrival spawn from the coast is `y` (`from_sk_pantai`).
- Interlude landing (**ASSUMED**): the riders' `goto` targets spawn `z` (`from_riders`, 27,19).
- Interlude table (**ASSUMED**): Ciung `N` and Hariang `H` are plain NPC spots inside house_a with `cond:"flag:mq4_2,!flag:mq4_9"`; the `quiet_house` beat plays their meeting. The cups are Ibu's dialogue, not a spot.
- Interlude shelf (**ASSUMED**, new): quests.md 4.3 lists `clue x3` with no ids; they are placed as three examine spots on Ibu's shelf, clue ids `shelf_ribbon`, `shelf_board`, `shelf_strip`, cond on the item held. Delete them if the three clue minutes should come from the earlier pickups.
- Gua Kala gate (**ASSUMED** 2026-11-06): kabut `k` lifts on flag `mq4_9` because `kabut.gd` reads only `Game.flags`.
- Lontar (**ASSUMED**): `L` is a floor pickup on the burned stage at (45,8), hidden until `mq0_4` (the morning-after Ibu talk).
- Prologue day (**ASSUMED**, v4c): house_c is new (the old couple, 5 tiles east of Ibu); the old banyan (24..25,12..13) is new `b` dressing; Ciung's tree is the existing `bb` block (2..3,30..31); the stall is one NPC spot (`purwa_stall`) at (35,14). NPC ids `laras_tag`, `stray_cat`, `villager`, `laras_crowd`, `door_a`-`door_c`, `aria_kebonan`, `wirasana_daughter` are new. Laras's `route` is a prop read by the NPC script (not an existing export); if the script cannot read it, put the five points in `data/` instead.
- Spawn ids (**ASSUMED** 2026-11-05): `start`, `from_ts_kebun`, `from_kg_alun`. Exit targets: `{target_zone:"ts_kebun", spawn_id:"from_desa_purwa"}`, `{target_zone:"kg_alun", spawn_id:"from_desa_purwa"}`.
- Trigger ids `wayang_stage`, `sanggar_enter`, `sanggar_lontar`, `purwa_tag_end`, `purwa_crowd`, `purwa_table`. Marker ids above.
- Epilogue (**ASSUMED**): all epilogue NPCs gate on `flag:mq5_4`; the Deserter on `!flag:choice_handed` (Choice 2 is exclusive).
- The west gate to Tatar Sunda has no kabut (quests.md: only the Galuh gate is fogged until `mq1_10`).

## Open questions
1. The `route` prop for Laras `l` (and the epilogue mirror) needs a script that reads it. Alternative: a `waypoints` array in `data/`.
2. Does `clue.tscn` take a `cond` export (the `q`, `1`-`3` spots use one)? architecture.md 9b lists none; Pickup and Npc have it.
3. Item ids `laras_board` and `laras_strip_ka` are new (items.md); `laras_board` is a pickup in `kg_penjara` (keraton_galuh.md), `laras_strip_ka` comes from Act III.

## Doc conflicts found
- Resolved 2026-11-06 (consistency pass): world.md gates the hub to Gua Kala on `quest:mq4=done` (`mq4_9`) and the hub to `sk_pantai` on `mq4_i5` (was `mq4_2`); quests.md 7.1 and script.md name the `goto` spawn `from_riders`; `tt_pesisir` to `sk_karang` opens on `mq4_9` only.
- `entities/world/kabut.gd` reads only `Game.flags`, so a gate written `quest:mq4=done` needs the flag `mq4_9` (used here).
- Item id `laras_lontar` is in items.md; the codex ids `hunter_mask` and `banyan` still need `data/codex` files.
- This doc's quest-marker flags `mq4_9` now come from step 4.12 (the Sea Altar), not 4.9.
