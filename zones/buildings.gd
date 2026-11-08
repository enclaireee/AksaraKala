extends Node2D
## Town buildings (architecture.md 9, "Towns (Phase 6c)"). Draws only: the tiles are already solid.
## `build(z)` finds every `[` rectangle (a non-enterable house) and every enterable room (a `#` ring around `_` floor with a
## door gap), picks a roof type, palette, door, windows and extras per building from the region's kit, composes the images
## from assets/art/buildings/<kit>/ (made by tools/gen_buildings.py, whose header documents the sheet layout) and adds them as
## y-sorted sprites. Seeded by zone_id plus the building position, so a rebuild is identical. Every footprint cell goes into
## `z.claimed`. An enterable building's roof and front wall fade to 15% alpha (0.25 s) while the player is inside its rect.
## Local coordinates of a building: (0,0) is the bottom-left corner of the footprint, the wall spans y -24..0, the roof's
## bottom edge is at y -20 (-20 - stilt_h with tall stilts).

const TILE := 16
const WH := 24            # front wall height
const CW := 24            # roof sheet: cap width, top, middle, bottom heights
const TH := 24
const MH := 16
const BH := 16
const ROOF_W := 64
const FADE_ALPHA := 0.15
const FADE_TIME := 0.25
const NEAR_TILES := 24.0  # two neighbours within this distance may not share both roof type and palette
const PATH := "res://assets/art/buildings/%s/%s.png"

const KITS := {
	"sunda": {"roofs": ["julang", "jolopong", "parahu"], "pals": 4, "front": "wall"},
	"galuh": {"roofs": ["joglo", "limasan", "kampung"], "pals": 4, "front": "wall"},
	"mataram": {"roofs": ["joglo", "limasan", "kampung"], "pals": 4, "front": "wall"},
	"kidul": {"roofs": ["nipah_a", "nipah_b", "nipah_c"], "pals": 4, "front": "wall"},
	"pasar": {"roofs": ["awning"], "pals": 4, "front": "warung"},
}
const KIT_OF := {"sunda": "sunda", "galuh": "galuh", "mataram": "mataram", "timur": "mataram", "kidul": "kidul", "kala": "sunda", "kelir": "mataram"}
const RIDGE := {"julang": 10, "jolopong": 12, "parahu": 11, "leuit": 4, "joglo": 12, "joglo_up": 6, "limasan": 10, "kampung": 6,
	"nipah_a": 3, "nipah_b": 9, "nipah_c": 10, "awning": 11}
const TIER_TINT := {1: [1.0], 2: [0.86, 1.0], 3: [0.76, 0.88, 1.0]}

## Wall sheet cells (col, row) of 16 x 24 px.
const CELLS := {
	"wall_a": Vector2i(0, 0), "wall_b": Vector2i(1, 0), "wall_c": Vector2i(2, 0), "post_l": Vector2i(3, 0), "post_r": Vector2i(4, 0),
	"stilt": Vector2i(5, 0), "step": Vector2i(6, 0), "pend_a": Vector2i(7, 0),
	"closed_0": Vector2i(0, 1), "closed_1": Vector2i(1, 1), "closed_2": Vector2i(2, 1), "closed_3": Vector2i(3, 1),
	"open_0": Vector2i(4, 1), "open_1": Vector2i(5, 1), "open_2": Vector2i(6, 1), "open_3": Vector2i(7, 1),
	"win_0": Vector2i(0, 2), "win_1": Vector2i(1, 2), "win_2": Vector2i(2, 2), "lit_0": Vector2i(3, 2), "lit_1": Vector2i(4, 2),
	"lit_2": Vector2i(5, 2), "wide_l": Vector2i(6, 2), "wide_r": Vector2i(7, 2),
	"wide_m": Vector2i(0, 3), "pend_post": Vector2i(1, 3), "pile": Vector2i(2, 3), "ladder": Vector2i(3, 3),
}
## Extras sheet: 24 x 24 cells, 8 columns, in this order.
const EXTRAS := ["lamp", "pot_a", "pot_b", "broom", "jar", "wood", "cage", "bench",
	"moss_0", "moss_1", "moss_2", "finial_a", "finial_b", "net", "basket", "sack"]

static var _imgs := {}      # path -> Image (null when the sheet is missing)
static var _shadows := {}   # width in tiles -> ImageTexture

## One entry per building: {rect: Rect2i (tiles), enterable, kit, kind, pal, door_col, door_w, node: Node2D, inside: bool}.
var list: Array[Dictionary] = []
var _tween := {}            # building node -> Tween
var _z: Node2D


func build(z: Node2D) -> void:
	_z = z
	y_sort_enabled = true
	if z.get("indoor") == true:
		return
	var g: Array = z.get("grid")
	var size: Vector2i = z.get("size")
	var zid := String(z.get("zone_id"))
	var rk := "sunda"
	if z.has_method("region_key"):
		rk = String(z.call("region_key"))
	var region_kit: String = KIT_OF.get(rk, "sunda")
	var found := _detect(g, size)
	var claimed: Variant = z.get("claimed")
	var taken: Array[Dictionary] = []
	for b: Dictionary in found:
		var r: Rect2i = b.rect
		if claimed is Dictionary:
			for y in range(r.position.y, r.end.y):
				for x in range(r.position.x, r.end.x):
					claimed[Vector2i(x, y)] = true
		var rng := RandomNumberGenerator.new()
		rng.seed = ("%s:%d:%d" % [zid, r.position.x, r.position.y]).hash()
		var plan := _plan(b, zid, region_kit, rng, taken)
		_make(plan, b)
		taken.append({"c": Vector2(r.position) + Vector2(r.size) * 0.5, "kind": plan.kind, "pal": plan.pal, "kit": plan.kit})
	set_process(true)


# ---------------------------------------------------------------- detection
## Returns [{rect: Rect2i, enterable: bool, door_col: int, door_w: int}] in row-major order of the top-left corner.
static func detect(g: Array, size: Vector2i) -> Array[Dictionary]:
	return _detect(g, size)


static func _ch(g: Array, x: int, y: int) -> String:
	if y < 0 or y >= g.size() or x < 0 or x >= String(g[y]).length():
		return ""
	return String(g[y])[x]


static func _detect(g: Array, size: Vector2i) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var w := size.x
	var h := size.y
	# enterable rooms: a rectangular block of `_` inside a ring of `#` with at least one gap
	var seen := PackedByteArray()
	seen.resize(w * h)
	for y in h:
		for x in w:
			if seen[y * w + x] == 1 or _ch(g, x, y) != "_":
				continue
			var comp: Array[Vector2i] = []
			var q: Array[Vector2i] = [Vector2i(x, y)]
			seen[y * w + x] = 1
			while not q.is_empty():
				var c: Vector2i = q.pop_back()
				comp.append(c)
				for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var n := c + d
					if n.x >= 0 and n.y >= 0 and n.x < w and n.y < h and seen[n.y * w + n.x] == 0 and _ch(g, n.x, n.y) == "_":
						seen[n.y * w + n.x] = 1
						q.append(n)
			if comp.size() > 1200:
				continue
			var room := _room_of(g, comp, w, h)
			if not room.is_empty():
				out.append(room)
	# non-enterable houses: greedy maximal rectangles of `[`
	var used := PackedByteArray()
	used.resize(w * h)
	for y in h:
		for x in w:
			if used[y * w + x] == 1 or _ch(g, x, y) != "[":
				continue
			var rw := 0
			while x + rw < w and _ch(g, x + rw, y) == "[" and used[y * w + x + rw] == 0:
				rw += 1
			var rh := 1
			while y + rh < h:
				var ok := true
				for i in rw:
					if _ch(g, x + i, y + rh) != "[" or used[(y + rh) * w + x + i] == 1:
						ok = false
						break
				if not ok:
					break
				rh += 1
			for j in rh:
				for i in rw:
					used[(y + j) * w + x + i] = 1
			if rw >= 2 and rh >= 2 and rw <= 40 and rh <= 24:
				out.append({"rect": Rect2i(x, y, rw, rh), "enterable": false, "door_col": -1, "door_w": 1})
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ra: Rect2i = a.rect
		var rb: Rect2i = b.rect
		return ra.position.y < rb.position.y or (ra.position.y == rb.position.y and ra.position.x < rb.position.x))
	return out


## The room whose floor is `comp` (a 4-connected `_` set), or {} when it is not a `#`-ringed rectangle.
static func _room_of(g: Array, comp: Array[Vector2i], w: int, h: int) -> Dictionary:
	var x0 := 1 << 20
	var x1 := -1
	var y0 := 1 << 20
	var y1 := -1
	for c in comp:
		x0 = mini(x0, c.x)
		x1 = maxi(x1, c.x)
		y0 = mini(y0, c.y)
		y1 = maxi(y1, c.y)
	# per-row spans; the interior is the longest run of rows with one identical, gap-free span
	var rows := {}
	for c in comp:
		var r: Array = rows.get(c.y, [1 << 20, -1, 0])
		r[0] = mini(r[0], c.x)
		r[1] = maxi(r[1], c.x)
		r[2] += 1
		rows[c.y] = r
	var best := Rect2i()
	var run_start := -1
	var run_span: Array = []
	for y in range(y0, y1 + 2):
		var r: Variant = rows.get(y)
		var full: bool = r != null and r[2] == r[1] - r[0] + 1
		if full and run_start >= 0 and r[0] == run_span[0] and r[1] == run_span[1]:
			continue
		if run_start >= 0:
			var rr := Rect2i(run_span[0], run_start, run_span[1] - run_span[0] + 1, y - run_start)
			if rr.get_area() > best.get_area():
				best = rr
		if full:
			run_start = y
			run_span = [r[0], r[1]]
		else:
			run_start = -1
	if best.get_area() < 4:
		return {}
	var ix0 := best.position.x
	var iy0 := best.position.y
	var ix1 := best.end.x - 1
	var iy1 := best.end.y - 1
	if ix0 < 1 or iy0 < 1 or ix1 >= w - 1 or iy1 >= h - 1 or best.size.x > 24 or best.size.y > 16:
		return {}
	# ring check
	var gaps: Array[Vector2i] = []
	var solid := 0
	var total := 0
	for x in range(ix0 - 1, ix1 + 2):
		for y in [iy0 - 1, iy1 + 1]:
			total += 1
			if _ch(g, x, y) == "#":
				solid += 1
			else:
				gaps.append(Vector2i(x, y))
	for y in range(iy0, iy1 + 1):
		for x in [ix0 - 1, ix1 + 1]:
			total += 1
			if _ch(g, x, y) == "#":
				solid += 1
			else:
				gaps.append(Vector2i(x, y))
	if gaps.is_empty() or gaps.size() > 8 or float(solid) / float(total) < 0.8:
		return {}
	for x in range(ix0 - 1, ix1 + 2):    # the north wall must be solid
		if _ch(g, x, iy0 - 1) != "#":
			return {}
	var rect := Rect2i(ix0 - 1, iy0 - 1, best.size.x + 2, best.size.y + 2)
	# door: the longest gap run in the south wall, else the middle of the wall
	var door_col := rect.size.x / 2
	var door_w := 1
	var run := 0
	var run_at := 0
	var best_run := 0
	var best_at := -1
	for i in rect.size.x:
		if _ch(g, rect.position.x + i, rect.end.y - 1) != "#":
			if run == 0:
				run_at = i
			run += 1
			if run > best_run:
				best_run = run
				best_at = run_at
		else:
			run = 0
	if best_at >= 0:
		door_col = best_at
		door_w = mini(best_run, 3)
	return {"rect": rect, "enterable": true, "door_col": door_col, "door_w": door_w}


# ---------------------------------------------------------------- style
func _plan(b: Dictionary, zid: String, region_kit: String, rng: RandomNumberGenerator, taken: Array[Dictionary]) -> Dictionary:
	var r: Rect2i = b.rect
	var W := r.size.x
	var D := r.size.y
	var enterable: bool = b.enterable
	var kit := region_kit
	var front: String = KITS[kit].front
	var forced := ""
	if zid.contains("pasar") and not enterable and W <= 7 and D <= 5 and rng.randf() < 0.65:
		kit = "pasar"
		front = "warung"
	elif kit == "sunda" and not enterable and W <= 4 and D <= 4:
		forced = "leuit"
	elif (kit == "galuh" or kit == "mataram") and W >= 8 and D >= 5 and not enterable and rng.randf() < 0.2:
		front = "pendopo"
		forced = "joglo"
	var kinds: Array = KITS[kit].roofs
	var npal: int = KITS[kit].pals
	# every (kind, palette) combination in a seeded order; take the first no near neighbour uses, else the least used
	var combos: Array[Vector2i] = []
	for ki in (1 if forced != "" else kinds.size()):
		for pi in npal:
			combos.append(Vector2i(ki, pi))
	for k in range(combos.size() - 1, 0, -1):
		var j := rng.randi_range(0, k)
		var t := combos[k]
		combos[k] = combos[j]
		combos[j] = t
	var centre := Vector2(r.position) + Vector2(r.size) * 0.5
	var pick := combos[0]
	var best_n := 1 << 20
	for c in combos:
		var kind: String = forced if forced != "" else kinds[c.x]
		var n := 0
		for o: Dictionary in taken:
			if o.kind == kind and o.pal == c.y and o.kit == kit and centre.distance_to(o.c) <= NEAR_TILES:
				n += 1
		if n < best_n:
			best_n = n
			pick = c
			if n == 0:
				break
	var kind2: String = forced if forced != "" else kinds[pick.x]
	var plan := {"kit": kit, "kind": kind2, "pal": pick.y, "front": front, "enterable": enterable, "W": W, "D": D,
		"wallv": rng.randi_range(0, 2), "mix": rng.randi_range(0, 1), "door": rng.randi_range(0, 3), "win": rng.randi_range(0, 2),
		"lit": [0.2, 0.4, 0.7][rng.randi_range(0, 2)], "finial": "", "moss": [], "ground": [], "hung": [],
		"stilts": kit == "sunda" or kit == "kidul", "stilt_h": 10 if kit == "kidul" else 0, "seed": rng.randi()}
	if kind2 == "leuit":
		plan.wallv = 1
	if kind2 == "julang":
		plan.finial = "a"
	var door_col: int = b.door_col
	var door_w: int = b.door_w
	if not enterable:
		door_col = W / 2 if rng.randf() < 0.5 else rng.randi_range(1, maxi(1, W - 2))
		door_w = 1
	if front == "warung":
		door_col = -1
		door_w = 0
	plan.door_col = door_col
	plan.door_w = door_w
	if (kit == "galuh" or kit == "mataram" or kit == "sunda") and front != "warung" and rng.randf() < 0.7:
		plan.finial = "ab"[rng.randi_range(0, 1)]
	if rng.randf() < 0.55:
		for i in rng.randi_range(1, 3):
			plan.moss.append([rng.randf(), rng.randf(), rng.randi_range(0, 2)])
	var door_cols: Array[int] = []
	for i in maxi(0, door_w):
		door_cols.append(door_col + i)
	var slots: Array[int] = [door_col - 1, door_col + door_w]
	for i in W:
		if not door_cols.has(i) and absi(i - door_col) > 1:
			slots.append(i)
	for k in range(slots.size() - 1, 0, -1):
		var j := rng.randi_range(0, k)
		var t := slots[k]
		slots[k] = slots[j]
		slots[j] = t
	var ground_pool := ["pot_a", "pot_b", "jar", "wood", "broom", "basket", "bench", "sack"]
	var hung_pool := ["lamp", "cage", "lamp"]
	if kit == "kidul":
		ground_pool = ["jar", "basket", "sack", "wood", "bench"]
		hung_pool = ["lamp", "cage", "lamp", "net", "net"]
	if front == "pendopo":
		hung_pool = ["lamp"]
	for i in mini(slots.size(), rng.randi_range(2, 4)):
		var s := slots[i]
		if s < 0 or s >= W:
			continue
		var cx := TILE * s + 8
		if rng.randf() < 0.35 and not door_cols.has(s):
			plan.hung.append([hung_pool[rng.randi_range(0, hung_pool.size() - 1)], cx, 6])
		else:
			plan.ground.append([ground_pool[rng.randi_range(0, ground_pool.size() - 1)], cx + rng.randi_range(-2, 2), 7])
	if front == "wall" and rng.randf() < 0.8:
		var lx := TILE * (door_col + door_w) + 3 if door_col + door_w < W else TILE * door_col - 3
		plan.hung.append(["lamp", lx, 8])
	return plan


# ---------------------------------------------------------------- images
static func _sheet(kit: String, name: String) -> Image:
	var path := PATH % [kit, name]
	if not _imgs.has(path):
		var im: Image = null
		if ResourceLoader.exists(path):
			var t := load(path) as Texture2D
			if t != null:
				im = t.get_image()
		if im == null and FileAccess.file_exists(path):
			im = Image.load_from_file(path)
		if im != null:
			im.convert(Image.FORMAT_RGBA8)
		_imgs[path] = im
	return _imgs[path]


static func _canvas(w: int, h: int) -> Image:
	var im := Image.create(maxi(1, w), maxi(1, h), false, Image.FORMAT_RGBA8)
	im.fill(Color(0, 0, 0, 0))
	return im


static func _blit(dst: Image, src: Image, rect: Rect2i, pos: Vector2i) -> void:
	if src != null and dst != null:
		dst.blend_rect(src, rect, pos)


static func _cell_rect(name: String) -> Rect2i:
	var c: Vector2i = CELLS[name]
	return Rect2i(c.x * TILE, c.y * WH, TILE, WH)


static func _extra_rect(name: String) -> Rect2i:
	var i: int = EXTRAS.find(name)
	return Rect2i((i % 8) * 24, (i / 8) * 24, 24, 24)


## Nine-slice roof of a footprint `w` tiles wide with `n` repeated middle rows.
static func _roof(kit: String, kind: String, pi: int, w: int, n: int) -> Image:
	var sh := _sheet(kit, "roof_%s_%d" % [kind, pi])
	var m := maxi(0, w - 2)
	var out := _canvas(CW * 2 + TILE * m, TH + MH * n + BH)
	if sh == null:
		return out
	var cols: Array = [[0, CW]]
	for i in m:
		cols.append([CW, TILE])
	cols.append([ROOF_W - CW, CW])
	var rows: Array = [[0, TH]]
	for i in n:
		rows.append([TH, MH])
	rows.append([TH + MH, BH])
	var x := 0
	for c: Array in cols:
		var y := 0
		for r: Array in rows:
			out.blend_rect(sh, Rect2i(c[0], r[0], c[1], r[1]), Vector2i(x, y))
			y += r[1]
		x += c[1]
	return out


## [[kind, width_tiles, n_mid_rows, inset_tiles]] from the bottom tier up.
static func _tiers(kind: String, w: int, d: int) -> Array:
	var n := maxi(0, d - 3)
	if kind == "awning":
		return [["awning", w, maxi(0, d - 4), 0]]
	if kind == "joglo" and w < 6:
		kind = "limasan"
	if kind == "joglo":
		if w >= 8 and n >= 2:
			return [["joglo", w, 1, 0], ["joglo_up", w - 4, n / 2, 2], ["joglo_up", w - 8, maxi(0, n / 2 - 1), 4]]
		return [["joglo", w, mini(n, 1), 0], ["joglo_up", w - 4, maxi(0, n - 2), 2]]
	if n >= 3 and w >= 4:
		return [[kind, w, 1, 0], [kind, w - 2, n - 2, 1]]
	return [[kind, w, n, 0]]


func _make(plan: Dictionary, b: Dictionary) -> void:
	var r: Rect2i = b.rect
	var kit: String = plan.kit
	var pi: int = plan.pal
	var W: int = plan.W
	var D: int = plan.D
	var front: String = plan.front
	var sh: int = plan.stilt_h
	var rng := RandomNumberGenerator.new()
	rng.seed = plan.seed
	var walls := _sheet(kit, "wall_%d" % pi)
	var extras := _sheet(kit, "extras")
	# roof tiers
	var tiers := _tiers(plan.kind, W, D)
	var tints: Array = TIER_TINT[tiers.size()]
	var roofs: Array[Dictionary] = []
	var ybot := -WH + 4 - sh
	for ti in tiers.size():
		var t: Array = tiers[ti]
		var img := _roof(kit, t[0], pi, t[1], t[2])
		if ti > 0:
			ybot = int(roofs[ti - 1].pos.y) + 24
		roofs.append({"img": img, "pos": Vector2(TILE * t[3] - 8, ybot - img.get_height()), "kind": t[0], "tint": tints[ti]})
	var top := 0
	for rf: Dictionary in roofs:
		top = mini(top, int(rf.pos.y))
	top -= 24
	var cw := TILE * W + 16
	var chh := -top + 14
	var body := _canvas(cw, chh)
	var frontimg := _canvas(cw, chh)
	var ox := 8
	var oy := -top
	var names := ["wall_a", "wall_b", "wall_c"]
	var base: int = plan.wallv
	var wy := oy - WH - sh
	for i in W:
		var px := ox + TILE * i
		if front == "pendopo":
			_blit(body, walls, _cell_rect("pend_a"), Vector2i(px, wy))
			if i % 2 == 0 or i == W - 1:
				_blit(body, walls, _cell_rect("pend_post"), Vector2i(px, wy))
		elif front == "warung":
			_blit(body, walls, _cell_rect(names[(i + base) % 3]), Vector2i(px, wy))
		else:
			var nm: String = names[base] if plan.mix == 0 or i % 2 == 0 else names[(base + 1) % 3]
			_blit(body, walls, _cell_rect(nm), Vector2i(px, wy))
	if front == "wall" or front == "warung":
		_blit(body, walls, _cell_rect("post_l"), Vector2i(ox, wy))
		_blit(body, walls, _cell_rect("post_r"), Vector2i(ox + TILE * (W - 1), wy))
		if front == "warung":
			for i in range(4, W - 1, 4):
				_blit(body, walls, _cell_rect("post_l"), Vector2i(ox + TILE * i, wy))
	var door_col: int = plan.door_col
	var door_w: int = plan.door_w
	var door_cols: Array[int] = []
	if front == "wall":
		for i in door_w:
			door_cols.append(door_col + i)
	if sh > 0:
		for i in W:
			_blit(body, walls, _cell_rect("pile"), Vector2i(ox + TILE * i, oy - WH))
	elif plan.stilts and front == "wall":
		for i in W:
			if not door_cols.has(i):
				_blit(body, walls, _cell_rect("stilt"), Vector2i(ox + TILE * i, wy))
	if front == "wall":
		var prev := -9
		for i in W:
			if door_cols.has(i) or (not door_cols.is_empty() and absi(i - door_cols[0]) < 1):
				prev = -9
				continue
			if i - prev >= 2 and i > 0 and i < W - 1 and rng.randf() < 0.6:
				var lit := rng.randf() < float(plan.lit)
				_blit(body, walls, _cell_rect(("lit_%d" if lit else "win_%d") % plan.win), Vector2i(ox + TILE * i, wy))
				prev = i
	if not door_cols.is_empty():
		if door_w == 1:
			_blit(body, walls, _cell_rect(("open_%d" if plan.enterable else "closed_%d") % plan.door), Vector2i(ox + TILE * door_col, wy))
		else:
			for j in door_w:
				var cell := "wide_l" if j == 0 else ("wide_r" if j == door_w - 1 else "wide_m")
				_blit(body, walls, _cell_rect(cell), Vector2i(ox + TILE * (door_col + j), wy))
		for i in door_cols:
			_blit(body, walls, _cell_rect("ladder" if sh > 0 else "step"), Vector2i(ox + TILE * i, oy - WH if sh > 0 else oy))
	for e: Array in plan.ground:
		_blit(body, extras, _extra_rect(e[0]), Vector2i(ox + int(e[1]) - 12, oy + int(e[2]) - 22))
	# moss on the top tier's front slope, finial on its ridge, hung things under the eaves (drawn over the roof)
	var topr: Dictionary = roofs[roofs.size() - 1]
	var timg: Image = topr.img
	var tpos: Vector2 = topr.pos
	var mx0 := CW
	var mx1 := timg.get_width() - CW - 16
	var my0 := TH
	var my1 := timg.get_height() - BH - 16
	for m: Array in plan.moss:
		if mx1 > mx0 and my1 > my0:
			_blit(timg, extras, _extra_rect("moss_%d" % int(m[2])), Vector2i(int(mx0 + (mx1 - mx0) * float(m[0])) - 4, int(my0 + (my1 - my0) * float(m[1])) - 4))
	if plan.finial != "":
		var ridge: int = RIDGE.get(topr.kind, 8)
		if topr.kind == "julang":   # capit gunting (crossed poles) at both ridge ends
			_blit(frontimg, extras, _extra_rect("finial_a"), Vector2i(ox + int(tpos.x) + 2, oy + int(tpos.y) + ridge - 20))
			_blit(frontimg, extras, _extra_rect("finial_a"), Vector2i(ox + int(tpos.x) + timg.get_width() - 26, oy + int(tpos.y) + ridge - 20))
		else:
			_blit(frontimg, extras, _extra_rect("finial_%s" % plan.finial), Vector2i(ox + int(tpos.x) + timg.get_width() / 2 - 12, oy + int(tpos.y) + ridge - 20))
	for e: Array in plan.hung:
		_blit(frontimg, extras, _extra_rect(e[0]), Vector2i(ox + int(e[1]) - 12, wy + int(e[2])))
	# nodes
	var root := Node2D.new()
	root.name = "Building_%d_%d" % [r.position.x, r.position.y]
	root.position = Vector2(r.position.x * TILE, r.end.y * TILE)
	add_child(root)
	_sprite(root, "Body", body, Vector2(-ox, -oy))
	for i in roofs.size():
		var s := _sprite(root, "Roof%d" % i, roofs[i].img, roofs[i].pos)
		var tn: float = roofs[i].tint
		s.modulate = Color(tn, tn * 0.98, minf(1.0, tn * 1.03))
	_sprite(root, "Front", frontimg, Vector2(-ox, -oy))
	var shadow := Node2D.new()
	shadow.name = "Shadow_%d_%d" % [r.position.x, r.position.y]
	shadow.position = root.position - Vector2(0, 100000)   # sorts behind every entity
	add_child(shadow)
	var ss := Sprite2D.new()
	ss.texture = _shadow_tex(W)
	ss.centered = false
	ss.position = Vector2(-8, 100000 - 16)
	shadow.add_child(ss)
	list.append({"rect": r, "enterable": plan.enterable, "kit": kit, "kind": plan.kind, "pal": pi, "door_col": door_col,
		"door_w": door_w, "node": root, "inside": false, "front": front, "stilt_h": sh})


static func _sprite(parent: Node2D, nm: String, img: Image, pos: Vector2) -> Sprite2D:
	var s := Sprite2D.new()
	s.name = nm
	s.texture = ImageTexture.create_from_image(img)
	s.centered = false
	s.position = pos
	parent.add_child(s)
	return s


## Ground shadow to the south-east: a soft translucent slab, 16 px taller than the wall base.
static func _shadow_tex(w: int) -> ImageTexture:
	if not _shadows.has(w):
		var im := _canvas(TILE * w + 16, 24)
		im.fill_rect(Rect2i(4, 8, TILE * w + 8, 14), Color(0.05, 0.04, 0.1, 0.32))
		for x in [4, TILE * w + 11]:
			im.set_pixel(x, 8, Color(0, 0, 0, 0))
			im.set_pixel(x, 21, Color(0, 0, 0, 0))
		_shadows[w] = ImageTexture.create_from_image(im)
	return _shadows[w]


# ---------------------------------------------------------------- roof fade
func _process(_delta: float) -> void:
	if list.is_empty() or not is_inside_tree():
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var p := to_local(player.global_position)
	for b: Dictionary in list:
		if not b.enterable:
			continue
		var r: Rect2i = b.rect
		var inside := Rect2(r.position * TILE, r.size * TILE).has_point(p)
		if inside == b.inside:
			continue
		b.inside = inside
		var node: Node2D = b.node
		if _tween.has(node) and _tween[node] is Tween:
			(_tween[node] as Tween).kill()
		var tw := create_tween()
		tw.tween_property(node, "modulate:a", FADE_ALPHA if inside else 1.0, FADE_TIME)
		_tween[node] = tw
