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
var _gb: Array[PackedByteArray] = []   # _g as bytes: reading a String per cell was most of the build time
var _ground_b := Zone.C_GRASS          # zone.ground_char as a byte
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
	region = z.region_key() if z.region_key() in REGIONS else "kala"
	style = STYLE.get("%s_%d" % [region, z.sub_biome()], STYLE["sunda_0"])
	rng.seed = z.zone_id.hash()
	_g = z.grid
	_gb = Zone.rows_bytes(_g)
	_ground_b = z.ground_char.unicode_at(0)
	_w = z.size.x
	_h = z.size.y
	for n in ["Fill", "Ground", "Canopy"]:
		var layer := Node2D.new()
		layer.name = n
		add_child(layer)
		_layers.append(layer)
	_prepare()
	if not z.indoor:
		_ground()
		_terrain()
		_ground_cover()
		_landmarks()
	if z.indoor or z.ground_char == ".":
		_furnish()


# ---------------------------------------------------------------- setup
func _prepare() -> void:
	var ring := 3 * zone.k - 1   # `#` this close to a `_` floor is a room wall, not terrain (5 at 2x, 2 at 1x)
	var floor_d := Zone.dist_field(_g, "_", ring)
	_outdoor.resize(_w * _h)
	clear.resize(_w * _h)
	for y in _h:
		var row := _gb[y]
		for x in _w:
			var i := y * _w + x
			if row[x] == Zone.C_HASH and not zone.indoor and (floor_d[i] > ring or zone.ground_char == "_"):
				_outdoor[i] = 1
			if row[x] == Zone.C_PATH:
				clear[i] = 1
	var s := zone.k
	for c: Vector2i in zone.claimed:   # a town module placed something here
		if c.x >= 0 and c.y >= 0 and c.x < _w and c.y < _h:
			clear[c.y * _w + c.x] = 1
			_outdoor[c.y * _w + c.x] = 0
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


# ---------------------------------------------------------------- ground variety
## tools/gen_ground_tiles.py sheet: 8 columns, 3 sub-biome blocks of G_BLOCK rows (see that file's docstring).
## Opaque variants of grass, path, plaza stone, sand and wood floor are chosen per cell by a seeded hash (never the same as
## the left or upper neighbour), soft edge pieces bleed path, sand and shore onto the grass next to them, and decals add
## worn tracks, puddles, leaves, flowers, cracks and moss. All of it is non-colliding TileMapLayers under the Deco node.
const GROUND_TEX := "res://assets/art/ground/ground_%s.png"
const G_BLOCK := 24
const G_GRASS := 1
const G_PATH := 2
const G_PLAZA := 3
const G_SAND := 4
const G_WOOD := 5
const G_NB := [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
const G_DIAG := [Vector2i(1, -1), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(-1, -1)]
const G_CRACKS := [Vector2i(7, 21), Vector2i(6, 22), Vector2i(7, 22), Vector2i(0, 23)]

static var _gts := {}   # region -> TileSet or null

var ground_mat := PackedByteArray()   # per cell G_* (0 = not ground art), read by tests
var ground_var := PackedByteArray()   # per cell variant 0..7
var ground_layers: Array[TileMapLayer] = []   # tiles, edges, shore, decals


func _ground_tileset() -> TileSet:
	if _gts.has(region):
		return _gts[region]
	var ts: TileSet = null
	var path := GROUND_TEX % region
	if ResourceLoader.exists(path):
		var tex := load(path) as Texture2D
		var src := TileSetAtlasSource.new()
		src.texture = tex
		src.texture_region_size = Vector2i(16, 16)
		for r in tex.get_height() / 16:
			for c in tex.get_width() / 16:
				src.create_tile(Vector2i(c, r))
		ts = TileSet.new()
		ts.tile_size = Vector2i(16, 16)
		ts.add_source(src, 0)
	_gts[region] = ts
	return ts


func _ground_mat(x: int, y: int) -> int:
	return ground_mat[y * _w + x] if x >= 0 and y >= 0 and x < _w and y < _h else 0


func _ground() -> void:
	var ts := _ground_tileset()
	if ts == null:
		return
	for n in ["GroundTiles", "GroundEdges", "GroundShore", "GroundDecals"]:
		var l := TileMapLayer.new()
		l.name = n
		l.tile_set = ts
		add_child(l)
		ground_layers.append(l)
	var sbo := zone.sub_biome() * G_BLOCK
	var seed_i := zone.zone_id.hash() & 0xFFFFFF
	ground_mat.resize(_w * _h)
	ground_var.resize(_w * _h)
	var open_floor := zone.ground_char == "_"
	var plaza_cells := _plaza_cells()
	for y in _h:
		var row := _gb[y]
		for x in _w:
			var c := row[x]
			var m := 0
			if c == Zone.C_GRASS:
				m = G_GRASS
			elif c == Zone.C_PATH:
				m = G_PATH
				for o: Vector2i in G_NB:   # a path beside water is a bridge: keep the tileset's planks
					if _tile(x + o.x, y + o.y) == Zone.C_WATER:
						m = 0
			elif c == Zone.C_FLOOR:
				m = G_SAND if open_floor else (G_PLAZA if plaza_cells.has(Vector2i(x, y)) else G_WOOD)
			ground_mat[y * _w + x] = m
	for y in _h:
		for x in _w:
			var i := y * _w + x
			var m := ground_mat[i]
			if m == 0:
				continue
			var v := int(Zone._hash2(x, y, seed_i) * 8.0) % 8
			if m == G_GRASS:   # broad light and dark patches
				var dark := Zone.noise(x / 7.0, y / 7.0, seed_i + 3) > 0.5
				if Zone._hash2(x, y, seed_i + 1) < 0.15:
					dark = not dark
				v = v % 4 + (4 if dark else 0)
			var tries := 0
			while tries < 4 and ((x > 0 and ground_mat[i - 1] == m and ground_var[i - 1] == v) or (y > 0 and ground_mat[i - _w] == m and ground_var[i - _w] == v)):
				v = (v + 1 + int(Zone._hash2(x, y, seed_i + 50 + tries) * 6.0)) % 8
				tries += 1
			ground_var[i] = v
			ground_layers[0].set_cell(Vector2i(x, y), 0, Vector2i(v, sbo + m - 1))
	var dtree := Zone.dist_field(_g, "#", 3)
	# Per edge kind (0 path, 1 water, 2 sand), a mask with a 1-cell border of 0 (off the map is none of them), so
	# _edge reads 8 neighbours by index instead of 8 function calls.
	var pw := _w + 2
	var kinds: Array[PackedByteArray] = []
	for kind in 3:
		var km := PackedByteArray()
		km.resize(pw * (_h + 2))
		kinds.append(km)
	for y in _h:
		var row := _gb[y]
		for x in _w:
			var pi := (y + 1) * pw + x + 1
			var gm := ground_mat[y * _w + x]
			kinds[0][pi] = 1 if gm == G_PATH else 0
			kinds[1][pi] = 1 if row[x] == Zone.C_WATER else 0
			kinds[2][pi] = 1 if gm == G_SAND else 0
	for y in _h:
		for x in _w:
			var m := ground_mat[y * _w + x]
			if m == 0:
				continue
			var cell := Vector2i(x, y)
			if m == G_GRASS or m == G_SAND:
				_edge(cell, kinds[1], 1, sbo, seed_i, ground_layers[2])
			if m == G_GRASS:
				if not _edge(cell, kinds[0], 0, sbo, seed_i, ground_layers[1]):
					_edge(cell, kinds[2], 2, sbo, seed_i, ground_layers[1])
			var d := _decal(x, y, m, dtree[y * _w + x] <= 3, seed_i)
			if d.x >= 0 and not zone.claimed.has(cell):
				ground_layers[3].set_cell(cell, 0, Vector2i(d.x, sbo + d.y))


## The map char at (x, y) as a byte (Zone.C_*); outside the map is a wall.
func _tile(x: int, y: int) -> int:
	return _gb[y][x] if x >= 0 and y >= 0 and x < _w and y < _h else Zone.C_HASH


## Soft edge of a neighbouring material bleeding onto this cell: a side-mask piece, or a corner piece when only a diagonal
## touches. km is that kind's bordered mask (see _ground). Each cell is visited once per layer, so the cell is still empty.
func _edge(cell: Vector2i, km: PackedByteArray, kind: int, sbo: int, seed_i: int, layer: TileMapLayer) -> bool:
	var pw := _w + 2
	var pi := (cell.y + 1) * pw + cell.x + 1
	var mask := km[pi - pw] | (km[pi + 1] << 1) | (km[pi + pw] << 2) | (km[pi - 1] << 3)   # G_NB order: N E S W
	var piece := mask - 1
	if mask == 0:
		if km[pi - pw + 1] == 1:   # G_DIAG order: NE SE SW NW
			piece = 15
		elif km[pi + pw + 1] == 1:
			piece = 16
		elif km[pi + pw - 1] == 1:
			piece = 17
		elif km[pi - pw - 1] == 1:
			piece = 18
		else:
			return false
	var idx := int(Zone._hash2(cell.x, cell.y, seed_i + 11) * 2.0) % 2 * 19 + piece
	layer.set_cell(cell, 0, Vector2i(idx % 8, sbo + 5 + kind * 5 + idx / 8))
	return true


## Decal atlas coords (column, block row) for a cell, or (-1, -1).
func _decal(x: int, y: int, m: int, near_tree: bool, seed_i: int) -> Vector2i:
	if _tile(x, y - 1) == Zone.C_HASH and not zone.claimed.has(Vector2i(x, y - 1)):
		return Vector2i(0, 20)   # shadow under a north wall
	# The hashes and noise are pure, so each is worked out only on the branch that reads it (sand reads none).
	match m:
		G_GRASS:
			var h := Zone._hash2(x, y, seed_i + 21)
			if h < 0.012 or (h < 0.22 and Zone.noise(x / 5.0, y / 5.0, seed_i + 23) > 0.62):
				return Vector2i(_pick(x, y, seed_i), 22)
			if near_tree and Zone._hash2(x, y, seed_i + 22) < 0.1:
				return Vector2i(_pick(x, y, seed_i) % 4, 21)
		G_PATH:
			var h := Zone._hash2(x, y, seed_i + 21)
			var hz := _ground_mat(x - 1, y) == G_PATH and _ground_mat(x + 1, y) == G_PATH
			var vt := _ground_mat(x, y - 1) == G_PATH and _ground_mat(x, y + 1) == G_PATH
			if hz != vt and Zone.noise(x / 9.0, y / 9.0, seed_i + 24) > 0.35 and h < 0.6:
				return Vector2i(1 + (0 if hz else 2) + _pick(x, y, seed_i) % 2, 20)
			if Zone._hash2(x, y, seed_i + 22) < 0.06:
				return Vector2i(5 + _pick(x, y, seed_i) % 3, 20)
			if near_tree and h < 0.1:
				return Vector2i(_pick(x, y, seed_i) % 4, 21)
		G_PLAZA:
			if Zone._hash2(x, y, seed_i + 21) < 0.1:
				return G_CRACKS[_pick(x, y, seed_i) % 4]
			if Zone._hash2(x, y, seed_i + 22) < 0.06:
				return Vector2i(4 + _pick(x, y, seed_i) % 3, 21)
		G_WOOD:
			if Zone._hash2(x, y, seed_i + 21) < 0.05:
				return G_CRACKS[_pick(x, y, seed_i) % 4]
	return Vector2i(-1, -1)


func _pick(x: int, y: int, seed_i: int) -> int:
	return int(Zone._hash2(x, y, seed_i + 24) * 6.0) % 6


## `_` cells of open (plaza) floors, as opposed to rooms: a connected `_` area touching more than a few open ground cells,
## or any `_` area outside a town. Rooms get wood.
func _plaza_cells() -> Dictionary:
	var out := {}
	var seen := PackedByteArray()
	seen.resize(_w * _h)
	for sy in _h:
		for sx in _w:
			if _gb[sy][sx] != Zone.C_FLOOR or seen[sy * _w + sx] == 1:
				continue
			var comp: Array[Vector2i] = [Vector2i(sx, sy)]
			seen[sy * _w + sx] = 1
			var head := 0
			var open := 0
			while head < comp.size():
				var c := comp[head]
				head += 1
				for o: Vector2i in G_NB:
					var n: Vector2i = c + o
					var t := _tile(n.x, n.y)
					if t == Zone.C_FLOOR:
						if seen[n.y * _w + n.x] == 0:
							seen[n.y * _w + n.x] = 1
							comp.append(n)
					elif t == Zone.C_GRASS or t == Zone.C_PATH:
						open += 1
			if not zone.is_town() or open > 6:
				for c in comp:
					out[c] = true
	return out


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
			if _gb[y][x] != _ground_b or not _ok(x, y):
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
					if not _ok(x + dx, y + dy) or _gb[y + dy][x + dx] != _ground_b:
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
			if _gb[y][x] != Zone.C_FLOOR or _gb[y - 1][x] != Zone.C_HASH or not _ok(x, y) or (x * 3 + y * 5) % 5 != 0:
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
				if not _ok(c.x, c.y) or _gb[c.y][c.x] != Zone.C_FLOOR or _gb[c.y - 1][c.x] != Zone.C_HASH:
					fine = false
			if not fine:
				continue
			var pos := Vector2(x * 16 + (16 if wide else 8), y * 16 + 15)
			_record(prop, Vector2i(x, y), cells, pos)
			_sprite(prop, pos)
	for y in range(2, _h - 2):   # a few mats on open floor
		for x in range(2, _w - 2):
			if (x * 7 + y * 11) % 31 != 3 or _gb[y][x] != Zone.C_FLOOR or not _ok(x, y) or rng.randf() > 0.4:
				continue
			var cells: Array[Vector2i] = [Vector2i(x, y)]
			var fine := true
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if not _ok(x + dx, y + dy) or _gb[y + dy][x + dx] != Zone.C_FLOOR:
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
	var art := "res://assets/art/world_fx/fx_%s.png" % kind   # pixel PNGs from tools/gen_world_fx.py; the code below is the fallback
	if ResourceLoader.exists(art):
		_fx_tex[kind] = load(art)
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
