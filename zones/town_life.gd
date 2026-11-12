class_name TownLife extends Node2D
## Town life (architecture.md 9, Phase 6c): ambient villagers, animals, animated details and town dressing.
## Added as a y-sorted child of `zone.entities`; `build(z)` reads z.grid, z.size, z.zone_id, z.region_key() and
## z.claimed (cells already taken: never used; every cell this module uses is added). Deterministic per zone_id.
## Dressing on the solid town chars: `-` fences (autotiled), `'` garden beds, `{` stall goods (batched sprites,
## one canvas item per row chunk so the y-sort stays right). Live things (villagers, animals, fx) are capped at
## MAX_LIVE and their _process is switched off while the player is farther than ACTIVE_RANGE.
## Sprites: assets/art/ambient/ from tools/gen_ambient.py.

const T := 16
const MAX_LIVE := 60
const MAX_VILLAGERS := 30
const MAX_ANIMALS := 14
const MAX_FX := 16
const ACTIVE_RANGE := 400.0
const SCREEN_CELLS := 510.0   # 30x17

const Defs := preload("res://entities/ambient/ambient_defs.gd")
const VillagerS := preload("res://entities/ambient/villager.gd")
const AnimalS := preload("res://entities/ambient/animal.gd")
const FxS := preload("res://entities/ambient/fx.gd")
const BatchS := preload("res://entities/ambient/prop_batch.gd")

const REGIONS := ["sunda", "galuh", "mataram", "timur", "kidul"]
## fence style weights per region: bamboo, bilik, stone
const FENCE_W := {"sunda": [5, 3, 1], "galuh": [2, 2, 3], "mataram": [2, 2, 4], "timur": [1, 2, 4], "kidul": [4, 3, 1]}
## crop slots (crops.png cells: cassava 0-1, chili 2-3, rice 4-5, banana 6-7) weighted by region
const CROP_W := {
	"sunda": [3, 3, 3, 2], "galuh": [2, 2, 4, 2], "mataram": [2, 2, 4, 2], "timur": [3, 4, 0, 1], "kidul": [3, 2, 0, 4],
}
## stall goods weights (goods.png pairs: fruit, batik, pottery, fish, spice)
const GOODS_W := {
	"sunda": [3, 1, 2, 1, 2], "galuh": [2, 3, 2, 1, 2], "mataram": [2, 3, 2, 1, 2], "timur": [2, 1, 2, 1, 3], "kidul": [1, 1, 1, 5, 2],
}
## animal weights per region: chicken, duck, cat, dog, goat, kerbau
const ANIMAL_W := {
	"sunda": [5.0, 2.0, 2.0, 1.5, 1.5, 1.0], "galuh": [5.0, 2.0, 2.0, 1.5, 1.0, 1.5], "mataram": [5.0, 1.5, 2.0, 1.5, 1.0, 2.0],
	"timur": [4.0, 1.0, 2.0, 2.0, 2.5, 1.0], "kidul": [4.0, 3.0, 3.0, 2.0, 0.5, 0.0],
}
const ANIMALS := ["chicken", "duck", "cat", "dog", "goat", "kerbau"]

var zone: Node2D
var grid: Array = []
var w := 0
var h := 0
var region := "sunda"
var rng := RandomNumberGenerator.new()
var claimed: Dictionary = {}
var villagers: Array[Node2D] = []
var animals: Array[Node2D] = []
var fx: Array[Node2D] = []
## One line per thing placed, in order ("v12:34,20"): tests compare it across builds.
var layout: Array[String] = []

var _walk := PackedByteArray()
var _water := PackedByteArray()
var _batches := {}
var _player: Node2D
var _poll := 0.0
var _seed := 0
var _fx_budget := 0
var _houses: Array[Rect2i] = []


func _ready() -> void:
	y_sort_enabled = true


# ---------------------------------------------------------------- queries (used by the entities)
func can_walk(p: Vector2, water := false) -> bool:
	var x := int(floorf(p.x / T))
	var y := int(floorf(p.y / T))
	if x < 0 or y < 0 or x >= w or y >= h:
		return false
	var i := y * w + x
	return _walk[i] == 1 or (water and _water[i] == 1)


func is_water(p: Vector2) -> bool:
	var x := int(floorf(p.x / T))
	var y := int(floorf(p.y / T))
	return x >= 0 and y >= 0 and x < w and y < h and _water[y * w + x] == 1


## The player in this node's space, or a far-away point when there is none.
func player_pos() -> Vector2:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D if is_inside_tree() else null
	if _player == null:
		return Vector2(1.0e9, 1.0e9)
	return to_local(_player.global_position)


func live_count() -> int:
	return villagers.size() + animals.size() + fx.size()


## Everything that stands on the ground (smoke sits on roofs and is left out).
func ground_things() -> Array[Node2D]:
	var out: Array[Node2D] = []
	out.append_array(villagers)
	out.append_array(animals)
	for f in fx:
		if f.kind != "smoke":
			out.append(f)
	return out


func _process(delta: float) -> void:
	_poll -= delta
	if _poll > 0.0:
		return
	_poll = 0.25
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
	if _player == null:
		return
	var pp := to_local(_player.global_position)
	var r2 := ACTIVE_RANGE * ACTIVE_RANGE
	for group in [villagers, animals, fx]:
		for n: Node2D in group:
			var on := n.position.distance_squared_to(pp) < r2
			if n.is_processing() != on:
				n.set_process(on)


# ---------------------------------------------------------------- build
func build(z: Node2D) -> void:
	zone = z
	y_sort_enabled = true
	grid = z.grid
	w = z.size.x
	h = z.size.y
	region = z.region_key() if z.has_method("region_key") else "sunda"
	if region not in REGIONS:
		region = "sunda"
	var zid: String = str(z.zone_id)
	_seed = hash(zid)
	rng.seed = _seed
	var cl: Variant = z.get("claimed")
	claimed = cl if cl is Dictionary else {}
	_water.resize(w * h)
	_walk.resize(w * h)
	for y in h:
		for x in w:
			_water[y * w + x] = 1 if _ch(x, y) == "~" else 0
	_budgets()
	_dress()
	_houses_scan()
	_static_fx()
	_build_walk()
	_spawn_villagers()
	_spawn_animals()
	_spawn_butterflies()


func _ch(x: int, y: int) -> String:
	if x < 0 or y < 0 or x >= w or y >= h:
		return "#"
	return grid[y][x]


func _open(x: int, y: int) -> bool:
	var c := _ch(x, y)
	return (c == "." or c == "," or c == "_") and not claimed.has(Vector2i(x, y))


func _claim(x: int, y: int) -> void:
	claimed[Vector2i(x, y)] = true


var _v_budget := 0
var _a_budget := 0


func _budgets() -> void:
	var open := 0
	for y in h:
		for x in w:
			if _open(x, y):
				open += 1
	var screens := open / SCREEN_CELLS
	var vmin := 0 if open < 12 else (2 if open >= 40 else 1)
	_v_budget = clampi(roundi(screens * 4.5), vmin, MAX_VILLAGERS)
	_a_budget = clampi(roundi(screens * 3.0), vmin, MAX_ANIMALS)
	_fx_budget = clampi(MAX_LIVE - _v_budget - _a_budget, 0, MAX_FX)


func _pick_w(weights: Array, r: float) -> int:
	var total := 0.0
	for x in weights:
		total += float(x)
	var t := r * total
	for i in weights.size():
		t -= float(weights[i])
		if t < 0.0:
			return i
	return weights.size() - 1


func _hash3(a: int, b: int, c: int) -> float:
	var v := (a * 73856093) ^ (b * 19349663) ^ (c * 83492791) ^ _seed
	return float(absi(v) % 10007) / 10007.0


## 4-connected groups of a map char, in scan order.
func _components(ch: String) -> Array:
	var seen := {}
	var out: Array = []
	for y in h:
		for x in w:
			if _ch(x, y) != ch or seen.has(Vector2i(x, y)):
				continue
			var comp: Array[Vector2i] = []
			var stack: Array[Vector2i] = [Vector2i(x, y)]
			seen[Vector2i(x, y)] = true
			while not stack.is_empty():
				var c: Vector2i = stack.pop_back()
				comp.append(c)
				for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var n: Vector2i = c + d
					if _ch(n.x, n.y) == ch and not seen.has(n):
						seen[n] = true
						stack.append(n)
			out.append(comp)
	return out


# ---------------------------------------------------------------- dressing: fences, gardens, stalls
func _batch(x: int, y: int) -> Node2D:
	var key := Vector2i(y, x / 16)
	if not _batches.has(key):
		var b: Node2D = BatchS.new()
		b.position = Vector2(key.y * 16 * T, y * T + 14)
		add_child(b)
		_batches[key] = b
	return _batches[key]


func _dress() -> void:
	var fences := BatchS.tex("fences")
	var crops := BatchS.tex("crops")
	var goods := BatchS.tex("goods")
	var comps := _components("-")
	for ci in comps.size():
		for c: Vector2i in comps[ci]:
			if fences != null:
				var m := 0
				for k in 4:
					var n: Vector2i = c + [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)][k]
					var nc := _ch(n.x, n.y)
					if nc == "-" or nc == "[":
						m |= 1 << k
				var style := _pick_w(FENCE_W[region], _hash3(ci, c.x / 24, c.y / 24))
				var b := _batch(c.x, c.y)
				b.add(fences, Rect2(m * 16, style * 16, 16, 16), Vector2(c.x * T - b.position.x, -14))
			_claim(c.x, c.y)
	comps = _components("'")
	for ci in comps.size():
		var kind := _pick_w(CROP_W[region], _hash3(ci, 1, 2))
		for c: Vector2i in comps[ci]:
			if crops != null:
				var var_i := int(_hash3(c.x, c.y, ci) * 2.0)
				var slot := kind * 2 + var_i
				if kind == 3 and (c.x + c.y) % 3 == 0:
					slot = 0   # gaps between the banana trees
				var b := _batch(c.x, c.y)
				b.add(crops, Rect2(slot * 16, 0, 16, 32), Vector2(c.x * T - b.position.x, -30))
			_claim(c.x, c.y)
	comps = _components("{")
	for ci in comps.size():
		for c: Vector2i in comps[ci]:
			if goods != null:
				var g := _pick_w(GOODS_W[region], _hash3(ci, c.x / 3, c.y))
				var slot := g * 2 + int(_hash3(c.x, c.y, 5) * 2.0)
				var b := _batch(c.x, c.y)
				b.add(goods, Rect2(slot * 16, 0, 16, 16), Vector2(c.x * T - b.position.x, -14))
			_claim(c.x, c.y)


# ---------------------------------------------------------------- houses, smoke, laundry, pots, mats
func _houses_scan() -> void:
	for comp: Array in _components("["):
		var r := Rect2i(comp[0].x, comp[0].y, 1, 1)
		for c: Vector2i in comp:
			r = r.expand(c)
		r.size += Vector2i.ONE
		_houses.append(r)


func _add_fx(kind: String, pos: Vector2, seed_: int) -> Node2D:
	if fx.size() >= _fx_budget:
		return null
	var f: Node2D = FxS.new()
	f.setup(kind, pos, seed_)
	add_child(f)
	fx.append(f)
	layout.append("fx_%s:%d,%d" % [kind, int(pos.x), int(pos.y)])
	return f


func _static_fx() -> void:
	var reserve := mini(4, _fx_budget / 3)
	var smoke_cap := maxi(0, mini(6, (_fx_budget - reserve) / 2))
	var smokes := 0
	var n := 0
	for r in _houses:
		n += 1
		if r.size.x >= 3 and smokes < smoke_cap and rng.randf() < 0.5:
			var x := r.position.x + 1 + rng.randi() % maxi(1, r.size.x - 2)
			var f := _add_fx("smoke", Vector2(x * T + 8, r.position.y * T + 8), _seed + n * 31)
			if f != null:
				f.z_index = 20
				smokes += 1
	var mats := BatchS.tex("mats")
	for r in _houses:
		n += 1
		var side := r.position.x - 1 if rng.randf() < 0.5 else r.end.x
		# pot or fire beside the house, near the door end
		if rng.randf() < 0.4 and fx.size() < _fx_budget - reserve:
			var cy := r.end.y - 1
			if _open(side, cy) and _ch(side, cy) == ".":
				var kind := "pot" if rng.randf() < 0.55 else "fire"
				var f := _add_fx(kind, Vector2(side * T + 8, cy * T + 14), _seed + n * 17)
				if f != null:
					_claim(side, cy)
		# laundry line in the yard
		if rng.randf() < 0.3 and fx.size() < _fx_budget - reserve:
			_try_laundry(r, n)
		# drying mat on open ground
		if mats != null and rng.randf() < 0.35:
			_try_mat(r, mats)


func _try_laundry(r: Rect2i, n: int) -> void:
	for _i in 6:
		var len_c := 3 + rng.randi() % 3
		var x := r.position.x + rng.randi() % maxi(1, r.size.x)
		var y := r.end.y + 2 + rng.randi() % 3
		var ok := true
		for k in range(0, len_c + 1):
			if not (_open(x + k, y) and _ch(x + k, y) == "." and _open(x + k, y + 1) and _ch(x + k, y + 1) == "."):
				ok = false
				break
		if not ok:
			continue
		var f := _add_fx("laundry", Vector2(x * T + 8, y * T + 14), _seed + n * 13)
		if f == null:
			return
		f.set_laundry(len_c * T)
		_claim(x, y)
		_claim(x + len_c, y)
		return


func _try_mat(r: Rect2i, mats: Texture2D) -> void:
	for _i in 6:
		var x := r.position.x - 2 + rng.randi() % (r.size.x + 3)
		var y := r.end.y + 1 + rng.randi() % 4
		if _ch(x, y) == "." and _ch(x + 1, y) == "." and _open(x, y) and _open(x + 1, y):
			var kind := rng.randi() % 3
			if region == "kidul" and rng.randf() < 0.6:
				kind = 3
			var b := _batch(x, y)
			b.add(mats, Rect2(kind * 32, 0, 32, 16), Vector2(x * T - b.position.x, -14))
			_claim(x, y)
			_claim(x + 1, y)
			layout.append("mat%d:%d,%d" % [kind, x, y])
			return


# ---------------------------------------------------------------- the walkable map
func _build_walk() -> void:
	for y in h:
		for x in w:
			_walk[y * w + x] = 1 if _open(x, y) else 0


## Weighted candidate cells: a cumulative table over walkable cells.
func _table(weight_fn: Callable) -> Array:
	var cells: Array[Vector2i] = []
	var cum: Array[float] = []
	var total := 0.0
	for y in h:
		for x in w:
			if _walk[y * w + x] == 1:
				var wt: float = weight_fn.call(x, y)
				if wt > 0.0:
					total += wt
					cells.append(Vector2i(x, y))
					cum.append(total)
	return [cells, cum, total]


func _sample(tab: Array) -> Vector2i:
	var cells: Array = tab[0]
	var cum: Array = tab[1]
	var r: float = rng.randf() * float(tab[2])
	var lo := 0
	var hi := cells.size() - 1
	while lo < hi:
		var mid := (lo + hi) / 2
		if cum[mid] < r:
			lo = mid + 1
		else:
			hi = mid
	return cells[lo]


var _near_fields := {}   # "chars|r" -> Zone.dist_field: one pass per query kind instead of (2r+1)^2 reads per cell


## True when a char of `chars` is within r cells (chessboard) of (x, y).
func _near_char(x: int, y: int, chars: String, r: int) -> bool:
	if chars == "":
		return false
	if x >= 0 and y >= 0 and x < w and y < h and not chars.contains("#") and grid.size() == h:
		var key := "%s|%d" % [chars, r]
		if not _near_fields.has(key):
			var g: Array[String] = []
			g.assign(grid)
			_near_fields[key] = Zone.dist_field(g, chars, r)
		return (_near_fields[key] as PackedByteArray)[y * w + x] <= r
	for yy in range(y - r, y + r + 1):   # off the map, or "#" (which the edge counts as): read the cells
		for xx in range(x - r, x + r + 1):
			if _ch(xx, yy) in chars and chars != "":
				return true
	return false


func _cell_pos(c: Vector2i) -> Vector2:
	return Vector2(c.x * T + 4 + rng.randi() % 8, c.y * T + 10 + rng.randi() % 4)


# ---------------------------------------------------------------- villagers
func _spawn_villagers() -> void:
	if _v_budget <= 0:
		return
	var tab := _table(func(x: int, y: int) -> float:
		var wt := 1.0
		if _ch(x, y) == ",":
			wt = 3.0
		if _near_char(x, y, "{", 3):
			wt += 3.0
		return wt)
	if tab[0].is_empty():
		return
	var used := {}
	var homes: Array[Vector2] = []
	var left := _v_budget
	var tries := 0
	while left > 0 and tries < 200:
		tries += 1
		var c := _sample(tab)
		var p := _cell_pos(c)
		var far := true
		for q in homes:
			if q.distance_to(p) < 26.0:
				far = false
				break
		if not far and tries < 120:
			continue
		var pair := left >= 2 and rng.randf() < 0.3
		var v1 := _pick_variant(used, not pair and rng.randf() < 0.2, pair)
		var a := _spawn_villager(v1, p)
		homes.append(p)
		left -= 1
		if pair:
			var p2 := p + Vector2(15, 0)
			if can_walk(p2) and can_walk(p2 + Vector2(4, 0)):
				var v2 := _pick_variant(used, false, true)
				var b := _spawn_villager(v2, p2)
				a.partner = b
				b.partner = a
				a.leader = true
				a.dir = 3
				b.dir = 2
				homes.append(p2)
				left -= 1


func _spawn_villager(v: int, p: Vector2) -> Node2D:
	var n: Node2D = VillagerS.new()
	n.setup(v, self, p, _seed + villagers.size() * 7919 + 1)
	add_child(n)
	villagers.append(n)
	layout.append("v%d:%d,%d" % [v, int(p.x), int(p.y)])
	return n


func _pick_variant(used: Dictionary, want_child: bool, adult_only: bool) -> int:
	var opts: Array[int] = []
	var wts: Array[float] = []
	for i in Defs.VILLAGERS.size():
		var d: Dictionary = Defs.VILLAGERS[i]
		var is_child: bool = d.body == "child"
		if is_child != want_child or (adult_only and is_child):
			continue
		var wt: float = 1.0 / (1.0 + float(used.get(i, 0)) * 1.5)
		wt *= 1.0 if region in d.regions else 0.05
		opts.append(i)
		wts.append(wt)
	if opts.is_empty():
		return 0
	var pick := opts[_pick_w(wts, rng.randf())]
	used[pick] = used.get(pick, 0) + 1
	return pick


# ---------------------------------------------------------------- animals
func _spawn_animals() -> void:
	if _a_budget <= 0:
		return
	var yard := _table(func(x: int, y: int) -> float:
		if _ch(x, y) != ".":
			return 0.4 if _ch(x, y) == "," else 0.0
		return 3.0 if _near_char(x, y, "[-", 3) else 0.6)
	if yard[0].is_empty():
		return
	var duck_ok := _water.count(1) > 0
	var weights: Array = ANIMAL_W[region].duplicate()
	if not duck_ok:
		weights[1] = 0.0
	var left := _a_budget
	var tries := 0
	while left > 0 and tries < 120:
		tries += 1
		var sp: String = ANIMALS[_pick_w(weights, rng.randf())]
		var c := _sample(yard)
		match sp:
			"duck":
				if not _near_char(c.x, c.y, "~", 4):
					continue
			"cat":
				if not _near_char(c.x, c.y, "[", 2):
					continue
			"goat", "kerbau":
				if not _block_free(c):
					continue
		var p := _cell_pos(c)
		if sp == "chicken":
			var hen := _spawn_animal("rooster" if rng.randf() < 0.25 else "chicken", p)
			left -= 1
			var chicks := rng.randi() % 3 if hen.species == "chicken" else 0
			for _k in chicks:
				if left <= 0:
					break
				var cp := p + Vector2(rng.randf_range(-8, 8), rng.randf_range(-3, 3))
				if can_walk(cp):
					var ck := _spawn_animal("chick", cp)
					ck.leader = hen
					left -= 1
		elif sp == "duck":
			_spawn_animal("duck", p)
			left -= 1
			if left > 0 and rng.randf() < 0.6:
				var dp := p + Vector2(10, 0)
				if can_walk(dp, true):
					_spawn_animal("duck", dp)
					left -= 1
		else:
			_spawn_animal(sp, p)
			left -= 1


func _block_free(c: Vector2i) -> bool:
	for yy in range(c.y - 1, c.y + 2):
		for xx in range(c.x - 1, c.x + 2):
			if not (xx >= 0 and yy >= 0 and xx < w and yy < h and _walk[yy * w + xx] == 1):
				return false
	return true


func _spawn_animal(sp: String, p: Vector2) -> Node2D:
	var rows: int = Defs.ANIMALS[sp].rows
	var n: Node2D = AnimalS.new()
	n.setup(sp, rng.randi() % rows, self, p, _seed + animals.size() * 104729 + 3)
	add_child(n)
	animals.append(n)
	layout.append("a_%s:%d,%d" % [sp, int(p.x), int(p.y)])
	return n


# ---------------------------------------------------------------- butterflies
func _spawn_butterflies() -> void:
	var count := mini(fx.size(), 0)
	count = clampi(_fx_budget - fx.size(), 0, 6)
	if count <= 0:
		return
	var tab := _table(func(x: int, y: int) -> float:
		if _ch(x, y) != ".":
			return 0.0
		return 4.0 if _near_char(x, y, "'", 3) else 0.5)
	if tab[0].is_empty():
		return
	for k in count:
		var c := _sample(tab)
		_add_fx("butterfly", Vector2(c.x * T + 8, c.y * T + 12), _seed + 555 + k * 23)
