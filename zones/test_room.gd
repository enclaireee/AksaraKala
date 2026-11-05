@tool
extends Node2D
## Placeholder test room: 40x24 tiles with one Tatar Sunda encounter.

const LAYOUT := [
	"########################################",
	"#......................................#",
	"#......................................#",
	"#......................................#",
	"#...##.................................#",
	"#...##...........................##....#",
	"#................................##....#",
	"#......................................#",
	"#......................................#",
	"#......................................#",
	"#......................................#",
	"#......................................#",
	"#......................................#",
	"#......................................#",
	"#......................................#",
	"#......................................#",
	"#......................................#",
	"#.....#................................#",
	"#.....#.........................##.....#",
	"#.....#.........................##.....#",
	"#......................................#",
	"#......................................#",
	"#......................................#",
	"########################################",
]

func _ready() -> void:
	var tiles: TileMapLayer = $Tiles
	tiles.clear()
	for y in LAYOUT.size():
		for x in LAYOUT[y].length():
			# atlas x: 0 floor A, 1 floor B (checker), 2 wall
			var ax: int = 2 if LAYOUT[y][x] == "#" else (x + y) % 2
			tiles.set_cell(Vector2i(x, y), 0, Vector2i(ax, 0))
	if not Engine.is_editor_hint():
		_spawn_mix()


# "Batu tulis grove" (bestiary.md Encounters): tank in front, two shooters behind.
const MIX := [
	["tank", Vector2(376, 200)],
	["shooter", Vector2(456, 136)],
	["shooter", Vector2(456, 264)],
]


# ponytail: respawn the whole mix 2 s after it is cleared; real spawners come with zones (world.md)
func _spawn_mix() -> void:
	var alive := [MIX.size()]   # an array so the lambdas share one counter
	for m in MIX:
		var e: Node2D = load("res://entities/enemies/%s.tscn" % m[0]).instantiate()
		e.position = m[1]
		e.tree_exited.connect(func() -> void:
			alive[0] -= 1
			if alive[0] == 0 and is_inside_tree():
				get_tree().create_timer(2.0).timeout.connect(_spawn_mix))
		$Entities.add_child.call_deferred(e)
