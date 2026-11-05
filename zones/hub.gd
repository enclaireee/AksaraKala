extends Node2D
## Test hub (ASSUMED until Desa Purwa, Phase 4): a petilasan, one encounter, and a debug grant
## of every item so equipping and all weapons can be tried. Enemies come back when the zone reloads.

const LAYOUT := [
	"##############################",
	"#............................#",
	"#............................#",
	"#....##..............##......#",
	"#....##..............##......#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#....##..............##......#",
	"#....##..............##......#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"##############################",
]

# Bandits (chasers) and a Bandit Archer, plus a unique tank that stays dead once killed.
const MIX := [
	["chaser", Vector2(360, 96), ""],
	["chaser", Vector2(392, 160), ""],
	["shooter", Vector2(440, 64), ""],
	["tank", Vector2(400, 220), "hub_elite"],
]


func _ready() -> void:
	var tiles: TileMapLayer = $Tiles
	for y in LAYOUT.size():
		for x in LAYOUT[y].length():
			tiles.set_cell(Vector2i(x, y), 0, Vector2i(2 if LAYOUT[y][x] == "#" else (x + y) % 2, 0))
	for m in MIX:
		var e: Node2D = load("res://entities/enemies/%s.tscn" % m[0]).instantiate()
		e.position = m[1]
		e.set("unique_id", m[2])
		$Entities.add_child(e)
	_grant_items()


# ponytail: debug grant of every item file, not saved by itself (the next save keeps them).
func _grant_items() -> void:
	var game := get_node("/root/Game")
	if game.class_id == "":
		return
	for f in DirAccess.get_files_at("res://data/items"):
		if f.ends_with(".tres"):
			game.add_item(f.get_basename(), false)
