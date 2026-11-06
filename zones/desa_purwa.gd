extends Zone
## Desa Purwa, built from .docs/zones/desa_purwa.md (no redesign).

const MAP := [
	"####################################################JJ######",
	"#...................................................kk.....#",
	"#...##################..............#############...ju.....#",
	"#...#________________#..bb..........#___________#.....bbbb.#",
	"#...#________________#..bb..........#___________#.....bbbb.#",
	"#...#___D__D__D__D___#..............#_____G_____#.....bbbb.#",
	"#...#________________#..............#___________#.....bbbb.#",
	"#...#_______S________#..............#_____T_____#..........#",
	"#...#________________#..............#___________#..........#",
	"#...#__M_____________#..............#___________#..........#",
	"#...#________________#..............#####__######..........#",
	"#...#________________#...................,,................#",
	"#...########__########.....,,,,,,,.......,,.............r..#",
	"#...........,,.............,,,P,,,.......,,................#",
	"#...........,s........rr...,,,,,,,.......,,................#",
	"#...........,,.............,,,F,,,.......,,................#",
	"Ww,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,vKE",
	"W,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,KE",
	"#......,...................,......rr.........,,............#",
	"#......,...................,.................,,............#",
	"#......,...................,.................,,............#",
	"#...###_####............###_####........#####__######...r..#",
	"#...#______#............#______#........#___________#......#",
	"#...#______#............#______#........#___________#......#",
	"#...#______#............#__I___#........#___________#......#",
	"#...#______#............#______#........#_____R_____#......#",
	"#...#______#..~~~~~~~...#______#........#___________#......#",
	"#...########..~~~~~~~...########........#___________#.bbbb.#",
	"#.............~~~~~~~...................#___________#.bbbb.#",
	"#.............~~~~~~~...................#############.bbbb.#",
	"#.bb..........~~~~~~~.................................bbbb.#",
	"#.bb..................................................bbbb.#",
	"#..........................................................#",
	"############################################################",
]

const W := "res://entities/world/"
const NPC := "res://entities/npc/npc.tscn"
const FACELESS := "res://entities/enemies/faceless.tscn"
const SPOTS := {
	"W": {"scene": W + "exit.tscn", "props": {"target_zone": "ts_kebun", "spawn_id": "from_desa_purwa"}, "tile": ","},
	"w": {"scene": W + "spawn.tscn", "props": {"id": "from_ts_kebun"}, "tile": ","},
	"v": {"scene": W + "spawn.tscn", "props": {"id": "from_kg_alun"}, "tile": ","},
	"K": {"scene": W + "kabut.tscn", "props": {"flag": "mq1_10"}, "tile": ","},
	"E": {"scene": W + "exit.tscn", "props": {"target_zone": "kg_alun", "spawn_id": "from_desa_purwa"}, "tile": ","},
	"s": {"scene": W + "spawn.tscn", "props": {"id": "start"}, "tile": ","},
	"P": {"scene": "res://entities/petilasan/petilasan.tscn", "props": {"id": "desa_purwa"}, "tile": ","},
	"M": {"scene": NPC, "props": {"npc_id": "semar"}, "tile": "_"},
	"G": {"scene": NPC, "props": {"npc_id": "ki_wangsa"}, "tile": "_"},
	"R": {"scene": NPC, "props": {"npc_id": "nyai_rukmi"}, "tile": "_"},
	"I": {"scene": NPC, "props": {"npc_id": "ibu"}, "tile": "_"},
	"F": {"scene": W + "encounter.tscn", "props": {"area_id": "purwa_raid", "cond": "step:mq0=6", "size": Vector2i(14, 8), "waves": [[[FACELESS, Vector2i(-4, -2)], [FACELESS, Vector2i(4, -2)], [FACELESS, Vector2i(0, 2)]]]}, "tile": ","},
	"D": {"scene": "res://entities/enemies/dummy.tscn", "props": {}, "tile": "_"},
	"T": {"scene": W + "trigger.tscn", "props": {"trigger_id": "wayang_stage", "size": Vector2i(11, 5)}, "tile": "_"},
	"S": {"scene": W + "trigger.tscn", "props": {"trigger_id": "sanggar_enter", "size": Vector2i(16, 9)}, "tile": "_"},
	"J": {"scene": W + "exit.tscn", "props": {"target_zone": "gk_mulut", "spawn_id": "from_desa_purwa"}, "tile": "."},
	"k": {"scene": W + "kabut.tscn", "props": {"flag": "mq3_8"}, "tile": "."},
	"j": {"scene": W + "spawn.tscn", "props": {"id": "from_gk_mulut"}, "tile": "."},
	"u": {"scene": W + "spawn.tscn", "props": {"id": "from_gua_kala"}, "tile": "."},
}


func map() -> PackedStringArray:
	return PackedStringArray(MAP)


func spots() -> Dictionary:
	return SPOTS


## The sanggar shows the ghost guide of the newest learned glyph while the player stands inside it
## (desa_purwa.md `S`). Same overlay and corner as zones/sanggar.gd.
const GUIDE_RECT := Rect2(380, 20, 80, 80)
var guide: CastOverlay
var _in_sanggar := false


func _ready() -> void:
	super()
	guide = preload("res://ui/cast_overlay.tscn").instantiate()
	guide.layer = 4
	add_child(guide)
	for t in find_children("*", "Area2D", true, false):
		if t.get("trigger_id") == "sanggar_enter":
			t.body_entered.connect(_sanggar.bind(true))
			t.body_exited.connect(_sanggar.bind(false))
	get_node("/root/Events").glyph_learned.connect(_show_guide.unbind(1))


func _sanggar(body: Node, inside: bool) -> void:
	if body.is_in_group("player"):
		_in_sanggar = inside
		body.cast.practice = inside   # no sakti gate in the sanggar: a new player starts with 0
		_show_guide()


func _show_guide() -> void:
	var g: Array[GlyphData] = get_node("/root/Game").learned_glyphs()
	guide.hide_guide()
	guide.visible = _in_sanggar and not g.is_empty()
	if guide.visible:
		guide.show_guide(g[-1].templates[0], GUIDE_RECT)
