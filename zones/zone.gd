class_name Zone extends Node2D
## Zone base (architecture.md 9). A subclass returns its ASCII layout from map() and its placed
## things from spots(); this paints the tiles, places the spots, adds the player and UI when the
## scene has none, clamps the camera to the map and emits Events.zone_entered.
## Subclasses that override _ready must call super().

const TILE := 16
const SCREEN := Vector2i(30, 17)
## Tile chars in atlas order of zones/tiles.tres. # ~ b r are solid (physics layer 1).
const LEGEND := ".,t_#~br"
const PLAYER_SCENE := "res://entities/player/player.tscn"
const UI_SCENE := "res://ui/game_ui.tscn"

@export var zone_id := ""

var tiles: TileMapLayer
var entities: Node2D
var size := Vector2i.ZERO   # in tiles


## Rows of equal length, a multiple of 30x17 tiles.
func map() -> PackedStringArray:
	return PackedStringArray()


## Non-tile char -> {"scene": "res://...tscn", "props": {...}, "tile": "."}. Missing scenes warn and are skipped.
func spots() -> Dictionary:
	return {}


func map_rect() -> Rect2:
	return Rect2(Vector2.ZERO, Vector2(size * TILE))


func _ready() -> void:
	tiles = _child("Tiles", TileMapLayer) as TileMapLayer
	tiles.tile_set = preload("res://zones/tiles.tres")
	entities = _child("Entities", Node2D) as Node2D
	entities.y_sort_enabled = true
	_build()
	var player := _ensure_player()
	if find_child("GameUI", true, false) == null:
		add_child(load(UI_SCENE).instantiate())
	var start := spawn("start")
	if start == null:
		var all := _spawns()
		start = all[0] if all.size() > 0 else null
	if start:
		player.global_position = start.global_position
		player.reset_physics_interpolation()
	var cam := player.get_node_or_null("Camera")
	if cam and cam.has_method("set_bounds"):
		cam.set_bounds(map_rect())
	get_node("/root/Zones").current_zone = zone_id
	_entered.call_deferred()   # after the scene change finishes, so its listeners are connected


## Spawn marker in this zone with that id, or null.
func spawn(id: String) -> Node2D:
	for s in _spawns():
		if s.id == id:
			return s
	return null


func _spawns() -> Array:
	return get_tree().get_nodes_in_group("spawn").filter(func(s: Node) -> bool: return is_ancestor_of(s))


func _entered() -> void:
	get_node("/root/Events").zone_entered.emit(zone_id)


func _child(n: String, type: Variant) -> Node:
	var c := get_node_or_null(n)
	if c == null:
		c = type.new()
		c.name = n
		add_child(c)
	return c


func region_source() -> int:
	if zone_id.begins_with("kg_"):
		return 1
	if zone_id.begins_with("mt_"):
		return 2
	if zone_id.begins_with("tt_"):
		return 3
	if zone_id.begins_with("sk_"):
		return 4
	if zone_id.begins_with("gk_"):
		return 5
	return 0


func sub_biome() -> int:
	match zone_id:
		# Tatar Sunda: 0 = Village & Terraces, 1 = Deep Forest & Lake, 2 = Kawah Volcanic Crater
		"ts_hutan", "ts_hutan_2", "ts_leuweung", "ts_leuwi", "ts_situ":
			return 1
		"ts_kawah", "ts_kawah_2", "ts_kawah_boss":
			return 2
		# Karajaan Galuh: 0 = Keraton Palace & Gardens, 1 = Market & Lontar Archive, 2 = Prison & River
		"kg_pasar", "kg_pustaka":
			return 1
		"kg_penjara", "kg_pamali":
			return 2
		# Bhumi Mataram: 0 = Village & Flooded Sawah, 1 = Candi Ruins, 2 = War Graveyard
		"mt_reruntuhan", "mt_tegal", "mt_candi":
			return 1
		"mt_kuburan":
			return 2
		# Tanah Timur: 0 = Golden Savanna, 1 = Dry Riverbed & Banyan Forge, 2 = Volcanic Sea of Sand
		"tt_kali", "tt_beringin":
			return 1
		"tt_pesisir", "tt_pasir", "tt_candi":
			return 2
		# Segara Kidul: 0 = Black-Sand Beach & Village, 1 = Mangrove Swamp, 2 = Coral Reef & Sea Palace
		"sk_bakau":
			return 1
		"sk_karang", "sk_gua", "sk_keraton":
			return 2
		# Gua Kala: 0 = Cavern Mouth & Petrified Forest, 1 = Sands of Forgetting & Bridge, 2 = Kala Sanctum
		"gk_pasir", "gk_lupa", "gk_jembatan":
			return 1
		"gk_pelataran", "gk_ruang_kala":
			return 2
	return 0


func _tile_at(grid: Array[String], x: int, y: int) -> String:
	if y >= 0 and y < grid.size() and x >= 0 and x < grid[y].length():
		return grid[y][x]
	return "#"


func _tile_row(grid: Array[String], x: int, y: int, c: String) -> int:
	if zone_id.begins_with("fixture"):
		return 0
	var b0 := sub_biome() * 5
	var up := _tile_at(grid, x, y - 1)
	var dn := _tile_at(grid, x, y + 1)
	var lf := _tile_at(grid, x - 1, y)
	var rt := _tile_at(grid, x + 1, y)
	var h := (x * 73 + y * 37) % 16
	if c == "#":
		if dn != "#":
			return b0 + (2 if (h % 4 == 0 and up == "#") else 3)
		if up != "#":
			return b0 + 4
		return b0 + ((x + y) % 2)
	if c == "~":
		if up != "~":
			return b0 + 3
		if dn != "~":
			return b0 + 4
		return b0 + (2 if h % 5 == 0 else ((x + y) % 2))
	if c == "," and (up == "~" or dn == "~" or lf == "~" or rt == "~"):
		return 15
	if c in ".,t_":
		if up == "#":
			return b0 + 3
		if (c == "," or c == "_") and (up == "." or dn == "." or lf == "." or rt == "."):
			return b0 + 4
		return b0 + (2 if h < 2 else (1 if h < 7 else 0))
	return b0 + ((x * 3 + y * 5) % 4)


func _build() -> void:
	var rows := map()
	var sp := spots()
	var src_id := region_source()
	size = Vector2i(rows[0].length() if rows.size() > 0 else 0, rows.size())
	if size.x % SCREEN.x != 0 or size.y % SCREEN.y != 0:
		push_warning("zone %s: map %s is not a multiple of 30x17" % [zone_id, size])
	var grid: Array[String] = []
	for y in rows.size():
		if rows[y].length() != size.x:
			push_error("zone %s: row %d is %d wide, want %d" % [zone_id, y, rows[y].length(), size.x])
		var line := ""
		for x in rows[y].length():
			var ch := rows[y][x]
			if sp.has(ch):
				line += str((sp[ch] as Dictionary).get("tile", "."))
			elif LEGEND.find(ch) >= 0:
				line += ch
			else:
				line += "."
		grid.append(line)
	var scenes := {}   # char -> PackedScene or null, loaded once
	for y in rows.size():
		for x in rows[y].length():
			var c := rows[y][x]
			var cell := Vector2i(x, y)
			var tc := grid[y][x]
			var col := maxi(0, LEGEND.find(tc))
			var row := _tile_row(grid, x, y, tc)
			if sp.has(c):
				var spec: Dictionary = sp[c]
				tiles.set_cell(cell, src_id, Vector2i(col, row))
				if not scenes.has(c):
					scenes[c] = _load(spec.get("scene", ""))
				if scenes[c]:
					var n: Node = scenes[c].instantiate()
					var props: Dictionary = spec.get("props", {})
					for k in props:
						n.set(k, props[k])
					n.position = tiles.map_to_local(cell)
					entities.add_child(n)
				continue
			if LEGEND.find(c) < 0:
				push_error("zone %s: unknown tile '%s' at %s" % [zone_id, c, cell])
			tiles.set_cell(cell, src_id, Vector2i(col, row))


# Bosses and elites are referenced by path before they exist (architecture.md 9).
func _load(path: String) -> PackedScene:
	if not ResourceLoader.exists(path):
		push_warning("zone %s: spot scene %s does not exist yet" % [zone_id, path])
		return null
	return load(path)


func _ensure_player() -> Node2D:
	for n in find_children("*", "", true, false):
		if n.is_in_group("player"):
			return n
	var p: Node2D = load(PLAYER_SCENE).instantiate()
	p.position = map_rect().get_center()
	entities.add_child(p)
	return p
