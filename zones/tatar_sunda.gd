extends Zone
## Tatar Sunda, built from .docs/zones/tatar_sunda.md (no redesign).

const MAP := [
	"########################################################################################################################",
	"########################################################################################################################",
	"###......................################..bbb....bbb.....bbbbb..####.........................................##########",
	"###......................################..bbb....bbb.....bbbbb..####...................~~~~~~~~~~~~~~~~~~~...##########",
	"###......................################..bbb............bbbbb..####...................~~~~~~~~~~~~~~~~~~~...##########",
	"###......................###.........####........................####...................~~~~~~~~~~~~~~~~~~~...##########",
	"###......................###.........####........................####...................~~~~~~~~~~~~~~~~~~~...##########",
	"###......................###.........####........................####...................~~~~~~~~~~~~~~~~~~~...##########",
	"###.,,,,,,B,,,,,,,,,,,Z,,,,,,,,,Q,,,,,,,,,,,,,,,,,,,,,O,,,,,,,,,,,,K,,,,,,,,,,,,,,,,,,D,~~~~~~~~~~~~~~~~~~~...##########",
	"###.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,K,,,,,,,,,,,,,,,,,,,,,.....................##########",
	"###......................###.........####........................####.....................,,..rrr...rrrrr.....#.......##",
	"###......................###.........####........................####.....................,,..rrr...rrrrr...rr#.......##",
	"###......................################..bbbb.............bbbb.####.......rrrrr.........,,..rrr.x.rrrrr.....,....k..##",
	"###......................################..bbbb.....bbbb....bbbb.####.......rrrrr.........,,..rrr...rrrrr...rr#.......##",
	"###......................################..bbbb.....bbbb....bbbb.####..5....rrrrr.........,,..rrr.............#.......##",
	"#####################################################################.....................,,..................#.......##",
	"############.....#########################################################################,,############################",
	"############..c..#########################################################################,,############################",
	"############.....#########################################################################,,############################",
	"##############,###########################################################################,,############################",
	"####.........r,r..............###########.........................###########....................................#######",
	"####..........................###########..#######..#######.......#.........#..#######..............ttttttttttttt#######",
	"####.bbbb.........bbb.bbb.....###########..#_____#..#_____#.......#.........#..#_____#..............tttttttttt3tt#######",
	"####.bbbb.........bbb.bbb.....###########..#_____#..#_____#.......#.........#..#__W__#..............ttttttttttttt#######",
	"####..................bbb.....###########..###,###..###,###.......#.........#..#_____#..............ttttttttttttt#######",
	"####...Y..............bbb.....###########..A.............V........#.........#..#_____#..............ttttttttttttt#######",
	"####.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,F,,,,G,,,,,,,,,,,,,,,,,,,,,,,,,H,,,,J,,,,,,,###,###,,,,.......................#######",
	"####.,,,,,,,,,T,,,R,,,,,,,,,,,,,,,,,,,,,G,,,,,,,,,,,,,,,,,,,,,,,,,H,,,,,,,,,,,ttttttttttttttttttMtttttttttttttttt#######",
	"####..........................###########......I,,........L...,,..#.........#....................................#######",
	"####.bbb......................###########.##,##.,,.........#,#,,..#.........#.ttttttttttttttttttttttttttttttttttt#######",
	"####.bbb................bbbb..###########.#_U_#.,,.........#_#,,..#.........#.........ttttttttttttttttttttttttttt#######",
	"####.bbbbbbb............bbbb..###########.#___#.,,.........#_#,,..###########.ttttttttttttttttttttttttttttttttttt#######",
	"####....bbbb............bbbb..###########.#####.,,.........###,,..###########.........ttttttttttttttttttttttttttt#######",
	"####....bbbb............bbbb..##################,,############,,########################################################",
	"####..4.bbbb............bbbb..##################,,############,,########################################################",
	"####..........................##################,,############,,############################...........................#",
	"##############,,################################,,############,,##########ttttttttttttttttt#....bbb.............bbb....#",
	"##############,,################################,,############,,##########ttttttttttttttttt#....bbb.........bbb.bbb.1..#",
	"###.......................############.......................#,,##########ttttttttttttttttt#....bbb.........bbb........#",
	"###.......................############...........j...........#,,##########ttttttttttttttttt#................bbb........#",
	"###..bbbbb..bb...bbbb.....###.......##....m.............n....#,,##########.................#...........................#",
	"###..bbbbb..bb...bbbb.....###.......##.......................#,,,,,,,,,,,,,,,,,,,,,,P,,,,,,,,,,,,,,,,,,,E,,,,,,,,,,,,,eX",
	"###..bbbb........bbbb.....###...N...##.......................#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.X",
	"###..bbbb.....d..bbbb.....###..~~~..##...........S...........#############............C....#...........................#",
	"###...........q.......bbb.,,,..~~~..##.......................#############ttttttttttttttttt#...................bbb.....#",
	"###........bb.........bbb.###..~~~..##.......................#############ttttt2ttttttttttt#..bb.....bbb.......bbb.....#",
	"###..bbbbb.bb.....bbbbbb..###...u...##.......................#############ttttttttttttttttt#..bb.....bbb.......bbb.....#",
	"###..bbbbb.bb.....bbbbbb..###.a.....##....p.............s....#############ttttttttttttttttt#.......bbbbb...............#",
	"###..bbbbb........bbbbbb..###.......##.......................###############################.......bb..................#",
	"###.......................############.......................###########################################################",
	"########################################################################################################################",
]

const W := "res://entities/world/"
const B := "res://entities/bosses/"
const E := "res://entities/enemies/"
const PET := "res://entities/petilasan/petilasan.tscn"
const NPC := "res://entities/npc/npc.tscn"
const KUNTILANAK := E + "kuntilanak.tscn"
const BANDIT := E + "bandit.tscn"
const BOAR := E + "wild_boar.tscn"
const JURIG := E + "jurig_leuweung.tscn"
const ARCHER := E + "bandit_archer.tscn"
const SPOTS := {
	"X": {"scene": W + "exit.tscn", "props": {"target_zone": "desa_purwa", "spawn_id": "from_sunda"}, "tile": ","},
	"e": {"scene": W + "spawn.tscn", "props": {"id": "from_purwa"}, "tile": "."},
	"G": {"scene": W + "kabut.tscn", "props": {"flag": "mq1_3"}, "tile": ","},
	"H": {"scene": W + "kabut.tscn", "props": {"flag": "mq1_5"}, "tile": ","},
	"K": {"scene": W + "kabut.tscn", "props": {"flag": "mq1_7"}, "tile": ","},
	"P": {"scene": PET, "props": {"id": "sunda_1"}, "tile": ","},
	"Q": {"scene": PET, "props": {"id": "sunda_2"}, "tile": ","},
	"C": {"scene": NPC, "props": {"npc_id": "cepot"}, "tile": "."},
	"A": {"scene": NPC, "props": {"npc_id": "sunda_elder"}, "tile": "."},
	"I": {"scene": NPC, "props": {"npc_id": "ki_darsa"}, "tile": "."},
	"V": {"scene": NPC, "props": {"npc_id": "kepala_desa"}, "tile": "."},
	"L": {"scene": NPC, "props": {"npc_id": "angklung_leader"}, "tile": "."},
	"U": {"scene": NPC, "props": {"npc_id": "purbasari"}, "tile": "_"},
	"W": {"scene": NPC, "props": {"npc_id": "sunda_weaver"}, "tile": "_"},
	"Y": {"scene": NPC, "props": {"npc_id": "lutung_kasarung"}, "tile": "."},
	"D": {"scene": NPC, "props": {"npc_id": "dayang_sumbi"}, "tile": ","},
	"T": {"scene": NPC, "props": {"npc_id": "batu_tulis"}, "tile": ","},
	"k": {"scene": W + "chest.tscn", "props": {"chest_id": "sunda_kujang", "item_id": "kujang"}, "tile": "."},
	"a": {"scene": W + "chest.tscn", "props": {"chest_id": "sunda_leather", "item_id": "leather_armor"}, "tile": "."},
	"c": {"scene": W + "chest.tscn", "props": {"chest_id": "sunda_ironring", "item_id": "iron_ring"}, "tile": "."},
	"1": {"scene": W + "pickup.tscn", "props": {"item_id": "angklung_1"}, "tile": "."},
	"2": {"scene": W + "pickup.tscn", "props": {"item_id": "angklung_2"}, "tile": "t"},
	"3": {"scene": W + "pickup.tscn", "props": {"item_id": "angklung_3"}, "tile": "t"},
	"4": {"scene": W + "pickup.tscn", "props": {"item_id": "angklung_4"}, "tile": "."},
	"5": {"scene": W + "pickup.tscn", "props": {"item_id": "angklung_5"}, "tile": "."},
	"x": {"scene": W + "pickup.tscn", "props": {"codex_id": "tangkuban_perahu"}, "tile": "."},
	"B": {"scene": B + "sangkuriang.tscn", "props": {}, "tile": ","},
	"Z": {"scene": B + "arena_post.tscn", "props": {"post_id": "east"}, "tile": ","},
	"S": {"scene": B + "sandekala.tscn", "props": {}, "tile": "."},
	"m": {"scene": B + "oncor.tscn", "props": {"oncor_id": "nw"}, "tile": "."},
	"n": {"scene": B + "oncor.tscn", "props": {"oncor_id": "ne"}, "tile": "."},
	"p": {"scene": B + "oncor.tscn", "props": {"oncor_id": "sw"}, "tile": "."},
	"s": {"scene": B + "oncor.tscn", "props": {"oncor_id": "se"}, "tile": "."},
	"q": {"scene": E + "kuntilanak_elite.tscn", "props": {}, "tile": "."},
	"u": {"scene": W + "trigger.tscn", "props": {"trigger_id": "spring_bath", "size": Vector2i(5, 3)}, "tile": "."},
	"d": {"scene": W + "trigger.tscn", "props": {"trigger_id": "dark_grove", "size": Vector2i(22, 10)}, "tile": "."},
	"j": {"scene": W + "trigger.tscn", "props": {"trigger_id": "sande_room", "size": Vector2i(21, 10)}, "tile": "."},
	"E": {"scene": W + "encounter.tscn", "props": {"area_id": "sunda_edge", "size": Vector2i(22, 10), "waves": [[[KUNTILANAK, Vector2i(-10, 0)], [BANDIT, Vector2i(-5, -2)], [BANDIT, Vector2i(-5, 2)]]]}, "tile": ","},
	"F": {"scene": W + "encounter.tscn", "props": {"area_id": "sunda_boarlane", "size": Vector2i(11, 3), "waves": [[[BOAR, Vector2i(-4, 0)], [BOAR, Vector2i(-4, 1)]]]}, "tile": ","},
	"R": {"scene": W + "encounter.tscn", "props": {"area_id": "sunda_batutulis", "size": Vector2i(20, 12), "waves": [[[BANDIT, Vector2i(-3, -3)], [BANDIT, Vector2i(3, 3)], [KUNTILANAK, Vector2i(7, -4)]]]}, "tile": ","},
	"J": {"scene": W + "encounter.tscn", "props": {"area_id": "sunda_clearing", "size": Vector2i(9, 10), "waves": [[[JURIG, Vector2i(3, 0)], [BANDIT, Vector2i(2, -3)], [BANDIT, Vector2i(2, 3)]]]}, "tile": ","},
	"M": {"scene": W + "encounter.tscn", "props": {"area_id": "sunda_terraces", "size": Vector2i(24, 11), "waves": [[[BOAR, Vector2i(6, 0)], [JURIG, Vector2i(-3, -3)], [ARCHER, Vector2i(4, -4)], [BANDIT, Vector2i(-4, 2)]]]}, "tile": "t"},
	"N": {"scene": W + "encounter.tscn", "props": {"area_id": "sunda_spring", "size": Vector2i(7, 9), "waves": [[[BANDIT, Vector2i(-2, 0)], [BANDIT, Vector2i(2, 0)], [KUNTILANAK, Vector2i(-2, 4)]]]}, "tile": "."},
	"O": {"scene": W + "encounter.tscn", "props": {"area_id": "sunda_crater", "size": Vector2i(22, 11), "waves": [[[JURIG, Vector2i(4, -2)], [BANDIT, Vector2i(3, 2)], [BOAR, Vector2i(-6, -1)], [BOAR, Vector2i(-6, 1)]],[[KUNTILANAK, Vector2i(-2, -4)], [BANDIT, Vector2i(-2, 4)]]]}, "tile": ","},
}


func map() -> PackedStringArray:
	return PackedStringArray(MAP)


func spots() -> Dictionary:
	return SPOTS
