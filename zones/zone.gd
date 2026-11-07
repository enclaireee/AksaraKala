class_name Zone extends Node2D
## Zone base (architecture.md 9). A subclass returns its ASCII layout from map() and its placed
## things from spots(); this paints the tiles, places the spots, adds the player and UI when the
## scene has none, clamps the camera to the map and emits Events.zone_entered.
## Subclasses that override _ready must call super().

const TILE := 16
const SCREEN := Vector2i(30, 17)
## Default scale: each doc tile becomes SCALE x SCALE game tiles (architecture.md 9, Phase 6b). An area overrides
## area_scale() (towns: 1). size is in game tiles.
const SCALE := 2
const WALK := ".,t_"        # chars the player can stand on
const SOLID := "#~br"       # chars that collide
## Town chars (Phase 6c): solid, grass painted under them, collision from the Solids layer. Never eroded or dressed.
const TOWN_SOLID := "[-'{"
## Town areas: buildings.gd and town_life.gd run on these.
const TOWNS := ["desa_purwa", "ts_kampung", "kg_alun", "kg_pasar", "mt_pasar", "sk_nelayan"]
const BUILDINGS_SCRIPT := "res://zones/buildings.gd"
const TOWN_LIFE_SCRIPT := "res://zones/town_life.gd"
## Areas whose `_` floor is open ground (caves, sand, fields): erosion and dressing treat `_` as the ground.
const OPEN_FLOOR := ["gk_mulut", "gk_pasir", "gk_lupa", "gk_hutan", "gk_jembatan", "tt_pasir", "tt_ladang", "sk_gua"]
## Areas that are rooms: straight walls, furniture, no outdoor dressing.
const INDOOR := ["kg_penjara", "kg_pustaka", "sk_keraton", "gk_ruang_kala", "gk_pelataran", "tt_candi"]
const DECO_SCRIPT := preload("res://zones/deco.gd")
## Tile chars in atlas order of zones/tiles.tres (the first 8). # ~ b r are solid (physics layer 1); the town chars
## after them have no atlas tile of their own.
const LEGEND := ".,t_#~br[-'{"
const PLAYER_SCENE := "res://entities/player/player.tscn"
const UI_SCENE := "res://ui/game_ui.tscn"

@export var zone_id := ""

var tiles: TileMapLayer
var entities: Node2D
var k := SCALE              # this area's scale, cached from area_scale() at the start of _build
var solids: TileMapLayer            # collision only: the town chars
var claimed := {}                   # game cell (Vector2i) -> true: cells a town module placed things on; deco skips them
var size := Vector2i.ZERO   # in game tiles (doc size * k)
var doc_size := Vector2i.ZERO
var grid_base: Array[String] = []   # scaled map before erosion, spot tiles substituted
var grid: Array[String] = []        # scaled map after erosion: what is painted and collides
var spot_cells := {}                # doc cell (Vector2i) -> spot char
var indoor := false                 # a room-and-corridor area (INDOOR)
var ground_char := "."              # the open-ground tile: `_` in OPEN_FLOOR areas, else `.`
var deco: Node2D                    # zones/deco.gd, null for fixture zones


## Rows of equal length, a multiple of 30x17 tiles.
func map() -> PackedStringArray:
	return PackedStringArray()


## Non-tile char -> {"scene": "res://...tscn", "props": {...}, "tile": "."}. Missing scenes warn and are skipped.
func spots() -> Dictionary:
	return {}


## Doc tile -> game tile scale. Generated areas override it (`Scale: n` in the region doc).
func area_scale() -> int:
	return SCALE


func is_town() -> bool:
	return zone_id in TOWNS


## "sunda", "galuh", "mataram", "timur", "kidul", "kala" or "kelir": the art kit of this area (deco's REGIONS).
func region_key() -> String:
	if zone_id.begins_with("kelir"):
		return "kelir"
	return ["sunda", "galuh", "mataram", "timur", "kidul", "kala"][clampi(region_source(), 0, 5)]


func map_rect() -> Rect2:
	return Rect2(Vector2.ZERO, Vector2(size * TILE))


## Centre of the k x k block of a doc cell, in zone pixels: where its spot entity sits.
func cell_pos(doc_cell: Vector2i) -> Vector2:
	var s := area_scale()
	return Vector2(doc_cell * s * TILE) + Vector2.ONE * (s * TILE) * 0.5


## Game-tile cell holding a zone pixel position.
func tile_of(p: Vector2) -> Vector2i:
	return Vector2i((p / TILE).floor())


func _ready() -> void:
	tiles = _child("Tiles", TileMapLayer) as TileMapLayer
	tiles.tile_set = preload("res://zones/tiles.tres")
	entities = _child("Entities", Node2D) as Node2D
	entities.y_sort_enabled = true
	_build()
	var player := _ensure_player()
	if deco:
		deco.mood(player)
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


func _tile_at(g: Array[String], x: int, y: int) -> String:
	if y >= 0 and y < g.size() and x >= 0 and x < g[y].length():
		return g[y][x]
	return "#"


func _tile_row(g: Array[String], x: int, y: int, c: String) -> int:
	if zone_id.begins_with("fixture"):
		return 0
	var b0 := sub_biome() * 5
	var up := _tile_at(g, x, y - 1)
	var dn := _tile_at(g, x, y + 1)
	var lf := _tile_at(g, x - 1, y)
	var rt := _tile_at(g, x + 1, y)
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
	k = area_scale()
	doc_size = Vector2i(rows[0].length() if rows.size() > 0 else 0, rows.size())
	size = doc_size * k
	if size.x % SCREEN.x != 0 or size.y % SCREEN.y != 0:
		push_warning("zone %s: map %s is not a multiple of 30x17" % [zone_id, size])
	var dgrid: Array[String] = []
	for y in rows.size():
		if rows[y].length() != doc_size.x:
			push_error("zone %s: row %d is %d wide, want %d" % [zone_id, y, rows[y].length(), doc_size.x])
		var line := ""
		for x in rows[y].length():
			var ch := rows[y][x]
			if sp.has(ch):
				line += str((sp[ch] as Dictionary).get("tile", "."))
				spot_cells[Vector2i(x, y)] = ch
			elif LEGEND.find(ch) >= 0:
				line += ch
			else:
				push_error("zone %s: unknown tile '%s' at %s" % [zone_id, ch, Vector2i(x, y)])
				line += "."
		dgrid.append(line)
	grid_base = []
	for y in size.y:
		var line := ""
		for x in size.x:
			line += dgrid[y / k][x / k]
		grid_base.append(line)
	grid = grid_base.duplicate()
	indoor = zone_id in INDOOR
	ground_char = "_" if zone_id in OPEN_FLOOR else "."
	var dress := not zone_id.begins_with("fixture") and not rows.is_empty()
	if dress:
		_erode()
	solids = _child("Solids", TileMapLayer) as TileMapLayer
	solids.tile_set = _solid_tileset()
	for y in size.y:
		for x in size.x:
			var tc := grid[y][x]
			if TOWN_SOLID.find(tc) >= 0:   # grass to look at, a collision-only tile to bump into
				solids.set_cell(Vector2i(x, y), 0, Vector2i.ZERO)
				tc = "."
			tiles.set_cell(Vector2i(x, y), src_id, Vector2i(maxi(0, LEGEND.find(tc)), _tile_row(grid, x, y, tc)))
	var scenes := {}   # char -> PackedScene or null, loaded once
	for dc: Vector2i in spot_cells:
		var c: String = spot_cells[dc]
		var spec: Dictionary = sp[c]
		if not scenes.has(c):
			scenes[c] = _load(spec.get("scene", ""))
		if scenes[c]:
			var n: Node = scenes[c].instantiate()
			var props: Dictionary = spec.get("props", {})
			for k in props:
				n.set(k, props[k])
			_scale_spot(n)
			n.position = cell_pos(dc)
			entities.add_child(n)
	if is_town() and dress:   # modules first: they claim the cells deco must leave alone
		_run_module(BUILDINGS_SCRIPT, "Buildings")
		_run_module(TOWN_LIFE_SCRIPT, "TownLife")
	if dress:
		deco = DECO_SCRIPT.new()
		deco.name = "Deco"
		add_child(deco)
		move_child(deco, entities.get_index())   # above the tiles, under the y-sorted Entities
		deco.build(self)


## Instantiates a town module (a Node2D script with build(zone)) under the y-sorted Entities, when the file exists.
func _run_module(path: String, node_name: String) -> void:
	if not ResourceLoader.exists(path):
		return
	var n: Node2D = (load(path) as GDScript).new()
	n.name = node_name
	entities.add_child(n)
	if n.has_method("build"):
		n.call("build", self)


static var _solid_ts: TileSet


## A TileSet with one invisible full-cell collider on the same physics layer as tiles.tres.
func _solid_tileset() -> TileSet:
	if _solid_ts:
		return _solid_ts
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, (preload("res://zones/tiles.tres") as TileSet).get_physics_layer_collision_layer(0))
	var src := TileSetAtlasSource.new()
	src.texture = ImageTexture.create_from_image(Image.create(TILE, TILE, false, Image.FORMAT_RGBA8))
	src.texture_region_size = Vector2i(TILE, TILE)
	ts.add_source(src, 0)   # the tile data only gets its physics layers once the source belongs to the set
	src.create_tile(Vector2i.ZERO)
	var td := src.get_tile_data(Vector2i.ZERO, 0)
	td.add_collision_polygon(0)
	td.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)]))
	_solid_ts = ts
	return ts


## Spot entities that block or detect a passage cover their whole block: `block` (exit, kabut, shortcut)
## or `size` in tiles (trigger, encounter, whose wave offsets are in tiles too).
func _scale_spot(n: Node) -> void:
	if "block" in n:
		n.set("block", k)
	var s: Variant = n.get("size")
	if s is Vector2i:
		n.set("size", (s as Vector2i) * k)
	var w: Variant = n.get("waves")
	if w is Array:
		var out := []
		for wave: Array in w:
			var ow := []
			for e: Array in wave:
				ow.append([e[0], (e[1] as Vector2i) * k])
			out.append(ow)
		n.set("waves", out)


# ---- erosion (architecture.md 9, Phase 6b) ----

static func _hash2(x: int, y: int, s: int) -> float:
	var h := ((x * 73856093) ^ (y * 19349663) ^ (s * 83492791)) & 0xFFFFFFFF
	h = (h * 2654435761) & 0xFFFFFFFF
	h ^= h >> 15
	h = (h * 2246822519) & 0xFFFFFFFF
	h ^= h >> 13
	return float(h & 0xFFFF) / 65535.0


## Smooth value noise in 0..1.
static func noise(x: float, y: float, s: int) -> float:
	var xi := floori(x)
	var yi := floori(y)
	var fx := x - xi
	var fy := y - yi
	fx = fx * fx * (3.0 - 2.0 * fx)
	fy = fy * fy * (3.0 - 2.0 * fy)
	var a := lerpf(_hash2(xi, yi, s), _hash2(xi + 1, yi, s), fx)
	var b := lerpf(_hash2(xi, yi + 1, s), _hash2(xi + 1, yi + 1, s), fx)
	return lerpf(a, b, fy)


## Chessboard distance from every cell to the nearest cell whose char is in `chars`, capped at `cap`
## (cells farther than cap hold cap + 1). Flat array, index y * w + x.
static func dist_field(g: Array[String], chars: String, cap: int) -> PackedByteArray:
	var h := g.size()
	var w: int = g[0].length() if h > 0 else 0
	var d := PackedByteArray()
	d.resize(w * h)
	d.fill(cap + 1)
	var q := PackedInt32Array()
	for y in h:
		for x in w:
			if chars.find(g[y][x]) >= 0:
				d[y * w + x] = 0
				q.append(y * w + x)
	var head := 0
	while head < q.size():
		var i := q[head]
		head += 1
		var nd: int = d[i] + 1
		if nd > cap:
			continue
		var x := i % w
		var y := i / w
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				var nx := x + dx
				var ny := y + dy
				if nx < 0 or ny < 0 or nx >= w or ny >= h:
					continue
				var ni := ny * w + nx
				if d[ni] > nd:
					d[ni] = nd
					q.append(ni)
	return d


func _walk_at(g: Array[String], i: int) -> bool:
	return WALK.find(g[i / size.x][i % size.x]) >= 0


## Walkable cells reachable from `from` (flat index), 4-connected, as a byte mask.
func _flood(g: Array[String], from: int) -> PackedByteArray:
	var w := size.x
	var seen := PackedByteArray()
	seen.resize(w * size.y)
	if from < 0 or not _walk_at(g, from):
		return seen
	var q := PackedInt32Array([from])
	seen[from] = 1
	var head := 0
	while head < q.size():
		var i := q[head]
		head += 1
		var x := i % w
		var y := i / w
		for o in [[1, 0], [-1, 0], [0, 1], [0, -1]]:
			var nx: int = x + o[0]
			var ny: int = y + o[1]
			if nx < 0 or ny < 0 or nx >= w or ny >= size.y:
				continue
			var ni := ny * w + nx
			if seen[ni] == 0 and WALK.find(g[ny][nx]) >= 0:
				seen[ni] = 1
				q.append(ni)
	return seen


## Flat index of the cell the player starts on: the "start" spawn spot, else any spawn, else -1.
func _start_index() -> int:
	var sp := spots()
	var any := -1
	for dc: Vector2i in spot_cells:
		var spec: Dictionary = sp[spot_cells[dc]]
		if String(spec.get("scene", "")).ends_with("spawn.tscn"):
			var i := (dc.y * k) * size.x + dc.x * k
			if (spec.get("props", {}) as Dictionary).get("id", "") == "start":
				return i
			if any < 0:
				any = i
	return any


func _erode() -> void:
	var w := size.x
	var h := size.y
	if indoor or (is_town() and k == 1):
		return   # a room-and-corridor area keeps its straight walls; a 1x town keeps its lanes and building rings
	var seed_i := zone_id.hash() & 0xFFFFFF
	var prot := PackedByteArray()   # cells erosion may not touch
	prot.resize(w * h)
	var ring := 3 * k - 1   # tiles around a `_` floor that stay as they are (5 at 2x, 2 at 1x)
	var floor_d := dist_field(grid_base, "_", ring)
	var dw := dist_field(grid_base, WALK, 3)
	var ds := dist_field(grid_base, SOLID, 3)
	for y in h:
		for x in w:
			var i := y * w + x
			if x < 2 or y < 2 or x >= w - 2 or y >= h - 2 or grid_base[y][x] == "," or (floor_d[i] <= ring and ground_char == "."):
				prot[i] = 1
	var sp := spots()
	for dc: Vector2i in spot_cells:
		_protect(prot, dc)
		var props: Dictionary = (sp[spot_cells[dc]] as Dictionary).get("props", {})
		for wave: Array in props.get("waves", []):   # an encounter's enemies stand on open ground
			for e: Array in wave:
				_protect(prot, dc + (e[1] as Vector2i))
	# Base walkable components: a carve may never merge two of them.
	var lab := PackedInt32Array()
	lab.resize(w * h)
	var n_lab := 0
	for i in w * h:
		if lab[i] == 0 and _walk_at(grid_base, i):
			n_lab += 1
			var m := _flood(grid_base, i)
			for j in w * h:
				if m[j] == 1:
					lab[j] = n_lab
	var carve: Array[int] = []
	var grow: Array[int] = []
	for y in h:
		for x in w:
			var i := y * w + x
			if prot[i] == 1:
				continue
			var ch := grid_base[y][x]
			var nv := noise(x / 5.0, y / 5.0, seed_i) * 0.65 + noise(x / 2.2 + 17.0, y / 2.2 + 9.0, seed_i) * 0.35
			nv = nv * 2.0 - 1.0
			if ch == "#" and dw[i] >= 1 and dw[i] <= 2:
				var depth := 2 if nv > 0.35 else (1 if nv > 0.05 else 0)
				if dw[i] <= depth and _single_label(lab, x, y):
					carve.append(i)
			elif ch == ground_char and ds[i] == 1 and nv < -0.1:
				grow.append(i)
	_apply(carve, ground_char)
	_apply(grow, "#")
	var start := _start_index()
	if start < 0:
		return
	var base_reach := _flood(grid_base, start)
	if not _spots_reached(base_reach, _flood(grid, start)):
		_apply(grow, ground_char)   # undo the growth; carving cannot disconnect anything
		if not _spots_reached(base_reach, _flood(grid, start)):
			grid = grid_base.duplicate()


## Marks the block of a doc cell and 2 tiles around it as off limits for erosion.
func _protect(prot: PackedByteArray, dc: Vector2i) -> void:
	for y in range(dc.y * k - 2, dc.y * k + k + 2):
		for x in range(dc.x * k - 2, dc.x * k + k + 2):
			if x >= 0 and y >= 0 and x < size.x and y < size.y:
				prot[y * size.x + x] = 1


## True when every spot reachable in `base` is reachable in `now`.
func _spots_reached(base: PackedByteArray, now: PackedByteArray) -> bool:
	for dc: Vector2i in spot_cells:
		var i := (dc.y * k) * size.x + dc.x * k
		if base[i] == 1 and now[i] == 0:
			return false
	return true


## All walkable cells within 3 tiles of (x, y) belong to one base component.
func _single_label(lab: PackedInt32Array, x: int, y: int) -> bool:
	var found := 0
	for yy in range(maxi(0, y - 3), mini(size.y, y + 4)):
		for xx in range(maxi(0, x - 3), mini(size.x, x + 4)):
			var l := lab[yy * size.x + xx]
			if l != 0:
				if found != 0 and found != l:
					return false
				found = l
	return true


func _apply(cells: Array[int], c: String) -> void:
	for i in cells:
		var y := i / size.x
		var x := i % size.x
		grid[y] = grid[y].substr(0, x) + c + grid[y].substr(x + 1)


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
