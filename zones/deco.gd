class_name Deco extends Node2D
## World dressing for a Zone (architecture.md 9, Phase 6b). Deterministic: seeded by zone_id.
## - Outdoor solid ground (`#` far from any `_` floor) is filled with foliage or rock and grown over with
##   tall trees or spires. Trees near the walkable edge are y-sorted sprites in Entities (the player walks
##   behind them); deep ones are drawn flat in chunked canvas items under Entities.
## - Walkable grass gets non-colliding tufts, flowers and pebbles; each sub-biome adds landmarks.
## - `_` floor gets furniture along the north walls.
## - Mood: a CanvasModulate tint and a low-count CPUParticles2D ambience that rides the camera.
## Nothing is ever placed on a path `,` tile, a spot block or within 2 tiles of one (`clear`).
## Sprites: assets/art/props/<name>_<region>.png from tools/gen_world_props.py.

const REGIONS := ["sunda", "galuh", "mataram", "timur", "kidul", "kala"]
const TEX := "res://assets/art/props/%s_%s.png"
const CHUNK := 16          # cells per draw chunk side
const NEAR := 2            # solid cells this close to a walkable cell get y-sorted sprites
const MAX_PARTICLES := 40

## Per region_sub: solid = "forest" | "rock" (ground fill), trees (weighted), low (edge props), density (ground cover per walkable
## tile), landmarks [name, count per 120x68 tiles], tint (CanvasModulate), fx (particle kind). **TUNE** all.
const STYLE := {
	"sunda_0": {"solid": "forest", "trees": ["tree_teak", "tree_teak", "tree_banyan", "bamboo"], "low": ["bush", "bush", "rock_s"], "density": 0.07,
		"landmarks": [["lantern", 3], ["shrine", 1], ["candi_block", 2], ["bamboo", 3]], "tint": Color(1.0, 0.93, 0.85), "fx": "leaf"},
	"sunda_1": {"solid": "forest", "trees": ["tree_banyan", "tree_banyan", "tree_teak", "tree_dead"], "low": ["bush", "rock_m"], "density": 0.07,
		"landmarks": [["shrine", 1], ["candi_block", 2], ["candi_pillar", 2], ["lantern", 2]], "tint": Color(0.8, 0.92, 0.88), "fx": "firefly"},
	"sunda_2": {"solid": "rock", "trees": ["tree_spire", "tree_spire", "tree_spire", "tree_dead"], "low": ["rock_m", "rock_l", "rock_s"], "density": 0.04,
		"landmarks": [["rock_l", 3], ["bones_0", 2], ["lantern", 1]], "tint": Color(1.0, 0.82, 0.74), "fx": "ember"},
	"galuh_0": {"solid": "forest", "trees": ["tree_teak", "tree_teak", "tree_palm", "tree_acacia"], "low": ["bush", "bush", "rock_s"], "density": 0.07,
		"landmarks": [["lantern", 4], ["shrine", 1], ["jar", 3]], "tint": Color(1.0, 0.96, 0.88), "fx": "leaf"},
	"galuh_1": {"solid": "rock", "trees": ["tree_spire", "tree_teak"], "low": ["rock_m", "bush"], "density": 0.04,
		"landmarks": [["jar", 4], ["lantern", 3]], "tint": Color(1.0, 0.95, 0.86), "fx": "dust"},
	"galuh_2": {"solid": "rock", "trees": ["tree_spire", "tree_dead"], "low": ["rock_m", "rock_s"], "density": 0.04,
		"landmarks": [["bones_1", 3], ["lantern", 2]], "tint": Color(0.84, 0.9, 0.92), "fx": "mist"},
	"mataram_0": {"solid": "forest", "trees": ["tree_teak", "tree_palm", "tree_banyan", "tree_palm"], "low": ["bush", "rock_s"], "density": 0.07,
		"landmarks": [["shrine", 1], ["lantern", 3], ["jar", 2]], "tint": Color(1.0, 0.95, 0.84), "fx": "mist"},
	"mataram_1": {"solid": "rock", "trees": ["tree_spire", "tree_spire", "tree_teak", "tree_dead"], "low": ["rock_m", "rock_l", "bush"], "density": 0.05,
		"landmarks": [["candi_pillar", 5], ["candi_block", 5], ["candi_arch", 2], ["lantern", 2]], "tint": Color(0.98, 0.93, 0.84), "fx": "dust"},
	"mataram_2": {"solid": "forest", "trees": ["tree_dead", "tree_dead", "tree_dead", "tree_teak"], "low": ["rock_s", "bush"], "density": 0.05,
		"landmarks": [["bones_0", 3], ["bones_1", 2], ["candi_block", 3], ["candi_pillar", 2]], "tint": Color(0.78, 0.82, 0.88), "fx": "mist"},
	"timur_0": {"solid": "forest", "trees": ["tree_acacia", "tree_acacia", "tree_acacia", "tree_dead"], "low": ["bush", "rock_m"], "density": 0.06,
		"landmarks": [["bones_1", 2], ["rock_l", 3], ["shrine", 1]], "tint": Color(1.0, 0.9, 0.76), "fx": "dust"},
	"timur_1": {"solid": "rock", "trees": ["tree_spire", "tree_dead", "tree_banyan"], "low": ["rock_m", "rock_l"], "density": 0.04,
		"landmarks": [["lantern", 3], ["bones_0", 2], ["rock_l", 3]], "tint": Color(1.0, 0.85, 0.72), "fx": "ember"},
	"timur_2": {"solid": "rock", "trees": ["tree_spire", "tree_spire", "tree_dead"], "low": ["rock_m", "rock_s"], "density": 0.03,
		"landmarks": [["bones_1", 3], ["candi_pillar", 3], ["rock_l", 2]], "tint": Color(0.95, 0.8, 0.76), "fx": "ember"},
	"kidul_0": {"solid": "forest", "trees": ["tree_palm", "tree_palm", "tree_palm", "tree_teak"], "low": ["bush", "rock_m"], "density": 0.06,
		"landmarks": [["boat", 3], ["rock_l", 2], ["lantern", 2]], "tint": Color(0.88, 0.95, 1.0), "fx": "spray"},
	"kidul_1": {"solid": "forest", "trees": ["tree_mangrove", "tree_mangrove", "tree_mangrove", "tree_palm"], "low": ["bush", "rock_m"], "density": 0.06,
		"landmarks": [["boat", 2], ["rock_m", 3], ["bones_0", 1]], "tint": Color(0.82, 0.95, 0.9), "fx": "firefly"},
	"kidul_2": {"solid": "rock", "trees": ["tree_spire", "tree_spire", "tree_mangrove"], "low": ["rock_m", "rock_s"], "density": 0.04,
		"landmarks": [["coral_0", 3], ["coral_1", 3], ["boat", 1], ["shrine", 1]], "tint": Color(0.78, 0.92, 1.0), "fx": "spray"},
	"kala_0": {"solid": "forest", "trees": ["tree_dead", "tree_dead", "tree_dead", "tree_crystal"], "low": ["rock_s", "rock_m"], "density": 0.05,
		"landmarks": [["crystal_s", 3], ["bones_0", 2], ["candi_block", 2]], "tint": Color(0.66, 0.58, 0.82), "fx": "ember"},
	"kala_1": {"solid": "rock", "trees": ["tree_crystal", "tree_crystal", "tree_spire"], "low": ["rock_m", "rock_s"], "density": 0.04,
		"landmarks": [["crystal_s", 4], ["candi_pillar", 3]], "tint": Color(0.6, 0.55, 0.8), "fx": "ember"},
	"kala_2": {"solid": "rock", "trees": ["tree_spire", "tree_crystal", "tree_spire"], "low": ["rock_m", "rock_l"], "density": 0.03,
		"landmarks": [["lantern", 3], ["candi_pillar", 3], ["crystal_s", 2]], "tint": Color(0.7, 0.6, 0.85), "fx": "ember"},
}
const INTERIOR_TINT := Color(1.0, 0.95, 0.88)   # indoor areas are lit: their tint is pulled halfway to this

static var _tex := {}      # "name_region" -> Texture2D or null
static var _fx_tex := {}   # kind -> ImageTexture

var zone: Zone
var region := "sunda"
var style: Dictionary = {}
var rng := RandomNumberGenerator.new()
## Every prop placed: {name, cell: Vector2i, cells: Array[Vector2i] (ground footprint), pos: Vector2}. Tests read it.
var placed: Array[Dictionary] = []
var clear := PackedByteArray()   # 1 = no deco here (spot blocks +2 tiles around them, path tiles)

var _g: Array[String] = []
var _w := 0
var _h := 0
var _outdoor := PackedByteArray()
var _layers: Array[Node2D] = []   # fill, ground, canopy: draw order under Entities
var _chunks := [{}, {}, {}]       # per layer: chunk coord -> DecoChunk


## A canvas item that draws a list of [texture, position] in order. One per CHUNK x CHUNK cells and layer, so the
## engine culls the ones off screen.
class DecoChunk extends Node2D:
	var items: Array = []

	func _draw() -> void:
		for it: Array in items:
			draw_texture(it[0], it[1])


func build(z: Zone) -> void:
	zone = z
	region = REGIONS[clampi(z.region_source(), 0, REGIONS.size() - 1)]
	style = STYLE.get("%s_%d" % [region, z.sub_biome()], STYLE["sunda_0"])
	rng.seed = z.zone_id.hash()
	_g = z.grid
	_w = z.size.x
	_h = z.size.y
	for n in ["Fill", "Ground", "Canopy"]:
		var layer := Node2D.new()
		layer.name = n
		add_child(layer)
		_layers.append(layer)
	_prepare()
	if not z.indoor:
		_terrain()
		_ground_cover()
		_landmarks()
	if z.indoor or z.ground_char == ".":
		_furnish()


# ---------------------------------------------------------------- setup
func _prepare() -> void:
	var floor_d := Zone.dist_field(_g, "_", 5)
	_outdoor.resize(_w * _h)
	clear.resize(_w * _h)
	for y in _h:
		for x in _w:
			var i := y * _w + x
			if _g[y][x] == "#" and not zone.indoor and (floor_d[i] > 5 or zone.ground_char == "_"):
				_outdoor[i] = 1
			if _g[y][x] == ",":
				clear[i] = 1
	var s := Zone.SCALE
	for dc: Vector2i in zone.spot_cells:
		for y in range(maxi(0, dc.y * s - 2), mini(_h, dc.y * s + s + 2)):
			for x in range(maxi(0, dc.x * s - 2), mini(_w, dc.x * s + s + 2)):
				clear[y * _w + x] = 1


func texture(prop: String) -> Texture2D:
	var key := "%s_%s" % [prop, region]
	if not _tex.has(key):
		var path := TEX % [prop, region]
		_tex[key] = load(path) if ResourceLoader.exists(path) else null
	return _tex[key]


func _chunk(layer: int, x: int, y: int) -> DecoChunk:
	var key := Vector2i(x / CHUNK, y / CHUNK)
	var d: Dictionary = _chunks[layer]
	if not d.has(key):
		var c := DecoChunk.new()
		_layers[layer].add_child(c)
		d[key] = c
	return d[key]


func _flat(layer: int, prop: String, cell: Vector2i, pos: Vector2) -> void:
	var t := texture(prop)
	if t == null:
		return
	_chunk(layer, cell.x, cell.y).items.append([t, pos + Vector2(-t.get_width() * 0.5, -t.get_height() + 1)])


func _sprite(prop: String, pos: Vector2) -> void:
	var t := texture(prop)
	if t == null:
		return
	var s := Sprite2D.new()
	s.texture = t
	s.centered = false
	s.offset = Vector2(-t.get_width() * 0.5, -t.get_height() + 1)
	s.position = pos
	zone.entities.add_child(s)


func _record(prop: String, cell: Vector2i, cells: Array[Vector2i], pos: Vector2) -> void:
	placed.append({"name": prop, "cell": cell, "cells": cells, "pos": pos})


func _ok(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < _w and y < _h and clear[y * _w + x] == 0


func _jitter(r: float) -> float:
	return rng.randf_range(-r, r)


# ---------------------------------------------------------------- solid ground
func _terrain() -> void:
	var rock: bool = style.solid == "rock"
	var fill := "fill_rock" if rock else "fill_forest"
	var dw := Zone.dist_field(_g, Zone.WALK, 4)
	for y in _h:
		for x in _w:
			if _outdoor[y * _w + x] == 1:
				var v := int(Zone._hash2(x, y, 7) * 3.0) % 3
				_flat(0, "%s_%d" % [fill, v], Vector2i(x, y), Vector2(x * 16 + 8, y * 16 + 16))
	for y in range(0, _h, 2):
		for x in range((y / 2) % 2, _w, 2):
			var i := y * _w + x
			if _outdoor[i] == 0 or not _ok(x, y):
				continue
			var cell := Vector2i(x, y)
			var base := Vector2(x * 16 + 8 + _jitter(3.0), y * 16 + 16 + _jitter(2.0))
			var tall := y >= 2 and _outdoor[(y - 1) * _w + x] == 1 and _outdoor[(y - 2) * _w + x] == 1
			var prop := ""
			if tall and rng.randf() < 0.92:
				prop = style.trees[rng.randi() % style.trees.size()]
			elif dw[i] <= NEAR and rng.randf() < 0.75:
				prop = style.low[rng.randi() % style.low.size()]
				base.y = y * 16 + 14.0
			if prop == "":
				continue
			var cells: Array[Vector2i] = [cell]
			_record(prop, cell, cells, base)
			if dw[i] <= NEAR or not tall:
				_sprite(prop, base)
			else:
				_flat(2, prop, cell, base)


# ---------------------------------------------------------------- walkable ground
func _ground_cover() -> void:
	var dens: float = style.density
	for y in _h:
		for x in _w:
			if _g[y][x] != zone.ground_char or not _ok(x, y):
				continue
			if rng.randf() >= dens:
				continue
			var r := rng.randf()
			var prop := "tuft_%d" % rng.randi_range(0, 2)
			if r > 0.84:
				prop = "pebbles_%d" % rng.randi_range(0, 1)
			elif r > 0.62:
				prop = "flower_%d" % rng.randi_range(0, 2)
			var pos := Vector2(x * 16 + 8 + _jitter(4.0), y * 16 + 13 + _jitter(2.0))
			var cells: Array[Vector2i] = [Vector2i(x, y)]
			_record(prop, Vector2i(x, y), cells, pos)
			_flat(1, prop, Vector2i(x, y), pos)


func _landmarks() -> void:
	var scale_k := float(_w * _h) / 8160.0
	var water := Zone.dist_field(_g, "~", 2)
	var cand: Array[Vector2i] = []
	for y in range(1, _h - 1):
		for x in range(1, _w - 1):
			var open := true
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if not _ok(x + dx, y + dy) or _g[y + dy][x + dx] != zone.ground_char:
						open = false
			if open:
				cand.append(Vector2i(x, y))
	for k in range(cand.size() - 1, 0, -1):   # seeded shuffle
		var j := rng.randi_range(0, k)
		var t := cand[k]
		cand[k] = cand[j]
		cand[j] = t
	var used: Array[Vector2i] = []
	for entry: Array in style.landmarks:
		var prop: String = entry[0]
		var want := maxi(1, roundi(float(entry[1]) * scale_k))
		var shore := prop == "boat" or prop.begins_with("coral")
		for c in cand:
			if want == 0:
				break
			if shore and water[c.y * _w + c.x] > 2:
				continue
			if not shore and water[c.y * _w + c.x] <= 1 and prop != "bones_0" and prop != "bones_1":
				continue
			if used.any(func(u: Vector2i) -> bool: return maxi(absi(u.x - c.x), absi(u.y - c.y)) < 9):
				continue
			var pos := Vector2(c.x * 16 + 8, c.y * 16 + 14)
			var cells: Array[Vector2i] = []
			var t := texture(prop)
			var half := 0 if t == null else int(ceil(t.get_width() / 32.0))
			for dx in range(-half, half + 1):
				cells.append(Vector2i(c.x + dx, c.y))
			_record(prop, c, cells, pos)
			if prop in ["bones_0", "bones_1", "coral_0", "coral_1"]:
				_flat(1, prop, c, pos)
			else:
				_sprite(prop, pos)
			used.append(c)
			want -= 1


# ---------------------------------------------------------------- interiors
func _furnish() -> void:
	var picks := ["shelf", "jar", "table", "jar", "shelf", "jar"]
	for y in range(1, _h - 1):
		for x in range(1, _w - 1):
			if _g[y][x] != "_" or _g[y - 1][x] != "#" or not _ok(x, y) or (x * 3 + y * 5) % 5 != 0:
				continue
			if rng.randf() > 0.55:
				continue
			var prop: String = picks[rng.randi() % picks.size()]
			var cells: Array[Vector2i] = [Vector2i(x, y)]
			var wide := prop == "table" or prop == "shelf"
			if wide:
				cells.append(Vector2i(x + 1, y))
			var fine := true
			for c in cells:
				if not _ok(c.x, c.y) or _g[c.y][c.x] != "_" or _g[c.y - 1][c.x] != "#":
					fine = false
			if not fine:
				continue
			var pos := Vector2(x * 16 + (16 if wide else 8), y * 16 + 15)
			_record(prop, Vector2i(x, y), cells, pos)
			_sprite(prop, pos)
	for y in range(2, _h - 2):   # a few mats on open floor
		for x in range(2, _w - 2):
			if (x * 7 + y * 11) % 31 != 3 or _g[y][x] != "_" or not _ok(x, y) or rng.randf() > 0.4:
				continue
			var cells: Array[Vector2i] = [Vector2i(x, y)]
			var fine := true
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if not _ok(x + dx, y + dy) or _g[y + dy][x + dx] != "_":
						fine = false
			if fine:
				var pos := Vector2(x * 16 + 8, y * 16 + 14)
				_record("mat", Vector2i(x, y), cells, pos)
				_flat(1, "mat", Vector2i(x, y), pos)


# ---------------------------------------------------------------- mood
## Called by Zone once the player exists: the tint, and the particles that ride the camera.
func mood(player: Node2D) -> void:
	var cm := CanvasModulate.new()
	cm.name = "Mood"
	cm.color = (style.tint as Color).lerp(INTERIOR_TINT, 0.5) if zone.indoor else style.tint
	zone.add_child(cm)
	var kind: String = "dust" if zone.indoor else style.fx
	var p := _particles(kind)
	var cam := player.get_node_or_null("Camera") if player else null
	if cam:
		cam.add_child(p)
	else:
		p.position = zone.map_rect().get_center()
		add_child(p)


func _particles(kind: String) -> CPUParticles2D:
	var c: Dictionary = {
		"firefly": {"n": 18, "life": 4.0, "v": [3.0, 10.0], "dir": Vector2(0, -1), "spread": 180.0, "g": Vector2.ZERO,
			"col": Color(0.85, 1.0, 0.45, 0.95), "tex": "dot"},
		"leaf": {"n": 14, "life": 8.0, "v": [6.0, 14.0], "dir": Vector2(1, 0.5), "spread": 20.0, "g": Vector2(0, 4),
			"col": Color(0.6, 0.75, 0.3, 0.9), "tex": "leaf"},
		"mist": {"n": 8, "life": 14.0, "v": [3.0, 6.0], "dir": Vector2(1, 0), "spread": 12.0, "g": Vector2.ZERO,
			"col": Color(0.85, 0.92, 0.95, 0.5), "tex": "mist"},
		"ember": {"n": 24, "life": 3.5, "v": [6.0, 16.0], "dir": Vector2(0, -1), "spread": 28.0, "g": Vector2(0, -4),
			"col": Color(1.0, 0.55, 0.2, 1.0), "tex": "px"},
		"spray": {"n": 28, "life": 1.8, "v": [20.0, 40.0], "dir": Vector2(1, -0.5), "spread": 22.0, "g": Vector2(0, 30),
			"col": Color(0.9, 0.97, 1.0, 0.85), "tex": "px"},
		"dust": {"n": 20, "life": 7.0, "v": [3.0, 8.0], "dir": Vector2(1, 0.2), "spread": 60.0, "g": Vector2.ZERO,
			"col": Color(0.96, 0.88, 0.7, 0.55), "tex": "px"},
		"mote": {"n": 16, "life": 7.0, "v": [3.0, 8.0], "dir": Vector2(0, -1), "spread": 90.0, "g": Vector2.ZERO,
			"col": Color(0.95, 0.88, 0.7, 0.8), "tex": "leaf"},
	}[kind]
	var p := CPUParticles2D.new()
	p.name = "Ambience"
	p.amount = mini(int(c.n), MAX_PARTICLES)
	p.lifetime = c.life
	p.preprocess = c.life
	p.local_coords = false
	p.z_index = 3
	p.texture = _fx_texture(c.tex)
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(260, 150)
	p.direction = c.dir
	p.spread = c.spread
	p.gravity = c.g
	p.initial_velocity_min = c.v[0]
	p.initial_velocity_max = c.v[1]
	var col: Color = c.col
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 0.8, 1.0])
	ramp.colors = PackedColorArray([Color(col, 0.0), col, col, Color(col, 0.0)])
	p.color_ramp = ramp
	p.randomness = 0.5
	return p


func _fx_texture(kind: String) -> Texture2D:
	if _fx_tex.has(kind):
		return _fx_tex[kind]
	var img: Image
	match kind:
		"dot":
			img = Image.create(3, 3, false, Image.FORMAT_RGBA8)
			for o in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(2, 1), Vector2i(1, 2)]:
				img.set_pixelv(o, Color(1, 1, 1, 0.4))
			img.set_pixel(1, 1, Color.WHITE)
		"leaf":
			img = Image.create(3, 2, false, Image.FORMAT_RGBA8)
			img.fill(Color.WHITE)
			img.set_pixel(2, 1, Color(1, 1, 1, 0))
		"mist":
			img = Image.create(48, 24, false, Image.FORMAT_RGBA8)
			for y in 24:
				for x in 48:
					var d := Vector2((x - 23.5) / 24.0, (y - 11.5) / 12.0).length()
					img.set_pixel(x, y, Color(1, 1, 1, clampf(1.0 - d, 0.0, 1.0) * 0.35))
		_:
			img = Image.create(2, 2, false, Image.FORMAT_RGBA8)
			img.fill(Color.WHITE)
	var t := ImageTexture.create_from_image(img)
	_fx_tex[kind] = t
	return t
