@tool
extends Node2D
## Placeholder test room: 40x24 tiles. Spawns sit in an open 15x9 area.

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
		_spawn_chaser()


# ponytail: endless respawn so the feel can be tested; real spawners come with zones (world.md)
func _spawn_chaser() -> void:
	var c: Node2D = preload("res://entities/enemies/chaser.tscn").instantiate()
	c.position = $EnemySpawn.position
	c.tree_exited.connect(func() -> void:
		if is_inside_tree():
			get_tree().create_timer(2.0).timeout.connect(_spawn_chaser))
	$Entities.add_child.call_deferred(c)
