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


func _build() -> void:
	var rows := map()
	var sp := spots()
	size = Vector2i(rows[0].length() if rows.size() > 0 else 0, rows.size())
	if size.x % SCREEN.x != 0 or size.y % SCREEN.y != 0:
		push_warning("zone %s: map %s is not a multiple of 30x17" % [zone_id, size])
	var scenes := {}   # char -> PackedScene or null, loaded once
	for y in rows.size():
		if rows[y].length() != size.x:
			push_error("zone %s: row %d is %d wide, want %d" % [zone_id, y, rows[y].length(), size.x])
		for x in rows[y].length():
			var c := rows[y][x]
			var cell := Vector2i(x, y)
			if sp.has(c):
				var spec: Dictionary = sp[c]
				tiles.set_cell(cell, 0, Vector2i(maxi(0, LEGEND.find(spec.get("tile", "."))), 0))
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
			var i := LEGEND.find(c)
			if i < 0:
				push_error("zone %s: unknown tile '%s' at %s" % [zone_id, c, cell])
				i = 0
			tiles.set_cell(cell, 0, Vector2i(i, 0))


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
