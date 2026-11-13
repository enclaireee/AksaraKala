class_name AmbientFx extends Node2D
## Animated town details: chimney or kitchen smoke, steaming pot, cooking fire, butterfly and a laundry line
## (cloth flapping, 3 frames). Pure drawing, no collision. The node origin is the base on the ground.
## `step(delta)` advances it; TownLife turns _process off when the player is far.

var kind := "smoke"
var rng := RandomNumberGenerator.new()
var home := Vector2.ZERO
var length := 48.0           # laundry line span in px
var cloths: Array[int] = []  # laundry: row of laundry_cloth.png per hanging piece
var color_row := 0           # butterfly colour row

var _t := 0.0
var _tex: Texture2D
var _key := -1
var _p := Vector2.ZERO       # butterfly phase offsets
var _p0 := Vector2.ZERO


func setup(k: String, p: Vector2, seed_: int) -> void:
	kind = k
	position = p
	home = p
	rng.seed = seed_
	_t = rng.randf() * 20.0
	match kind:
		"smoke":
			_tex = AmbientBatch.tex("smoke")
		"pot":
			_tex = AmbientBatch.tex("pot")
		"fire":
			_tex = AmbientBatch.tex("fire")
		"butterfly":
			_tex = AmbientBatch.tex("butterfly")
			color_row = rng.randi() % 4
			_p = Vector2(rng.randf() * TAU, rng.randf() * TAU)
			_p0 = _flutter(_t)
		"laundry":
			_tex = AmbientBatch.tex("laundry_cloth")


func set_laundry(span: float) -> void:
	length = span
	cloths.clear()
	var n := maxi(1, int(span / 14.0))
	for i in n:
		cloths.append(rng.randi() % 6)


func _process(delta: float) -> void:
	step(delta)


func _flutter(t: float) -> Vector2:
	return Vector2(sin(t * 0.7 + _p.x) * 30.0 + sin(t * 1.9) * 4.0, cos(t * 0.5 + _p.y) * 20.0)


func step(delta: float) -> void:
	_t += minf(delta, 0.1)
	if kind == "butterfly":
		position = home + _flutter(_t) - _p0
	var key := _frame()
	if kind == "butterfly" or kind == "smoke" or key != _key:
		_key = key
		queue_redraw()


func _frame() -> int:
	match kind:
		"pot":
			return int(_t * 5.0) % 4
		"fire":
			return int(_t * 8.0) % 4
		"butterfly":
			return int(_t * 12.0) % 4
		"laundry":
			return int(_t * 3.0) % 3
	return int(_t * 4.0) % 6


func _draw() -> void:
	match kind:
		"smoke":
			_draw_smoke()
		"pot":
			if _tex:
				draw_texture_rect_region(_tex, Rect2(-8, -21, 16, 22), Rect2(_frame() * 16, 0, 16, 22))
			_glow("glow_pot", 24, 0, Vector2(0, -3))
		"fire":
			_glow("glow_fire", 32, _frame() % 2, Vector2(0, -5))
			if _tex:
				draw_texture_rect_region(_tex, Rect2(-6, -13, 12, 14), Rect2(_frame() * 12, 0, 12, 14))
		"butterfly":
			var h := 9.0 + sin(_t * 2.3) * 3.0
			var vx := cos(_t * 0.7 + _p.x)
			var sh := Npc.shadow_tex("xs")
			if sh != null:
				draw_texture(sh, Vector2(-3, -1))
			if _tex:
				if vx > 0.0:
					draw_set_transform(Vector2(0, -h), 0.0, Vector2(-1, 1))
				else:
					draw_set_transform(Vector2(0, -h), 0.0, Vector2.ONE)
				draw_texture_rect_region(_tex, Rect2(-3.5, -3, 7, 6), Rect2(_frame() * 7, color_row * 6, 7, 6))
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		"laundry":
			_draw_laundry()


func _draw_smoke() -> void:
	if _tex == null:
		return
	for k in 3:
		var u := fmod(_t / 4.2 + k / 3.0, 1.0)
		var f := mini(5, int(u * 6.0))
		var off := Vector2(sin(u * 5.0 + k) * 2.0 + u * 7.0, -u * 26.0)
		draw_texture_rect_region(_tex, Rect2(off + Vector2(-6, -12), Vector2(12, 12)), Rect2(f * 12, 0, 12, 12))


## A stepped-alpha glow from world_fx/<name>.png (square cells of `cell` px), centred on `at`.
func _glow(name: String, cell: int, frame: int, at: Vector2) -> void:
	var path := "res://assets/art/world_fx/%s.png" % name
	if not ResourceLoader.exists(path):
		return
	var t: Texture2D = load(path)
	draw_texture_rect_region(t, Rect2(at - Vector2(cell, cell) * 0.5, Vector2(cell, cell)), Rect2(frame * cell, 0, cell, cell))


func _draw_laundry() -> void:
	var top := -18.0
	var pole: Texture2D = load("res://assets/art/world_fx/pole.png") if ResourceLoader.exists("res://assets/art/world_fx/pole.png") else null
	if pole != null:
		draw_texture(pole, Vector2(-2, top))
		draw_texture(pole, Vector2(length - 2.0, top))
	for i in int(length) + 1:   # the string: 1 px thin, two tones (dark under, light on top), pixel-snapped sag
		var y := top + 2.0 + roundf(sin(PI * i / length) * 2.0)
		draw_rect(Rect2(i, y + 1.0, 1, 1), Color(0.5, 0.44, 0.34))
		draw_rect(Rect2(i, y, 1, 1), Color(0.88, 0.84, 0.72))
	if _tex == null:
		return
	var n := cloths.size()
	for i in n:
		var x := length * (i + 0.5) / n - 4.0
		var y := top + 3.0 + sin(PI * (i + 0.5) / n) * 2.0
		var f := (int(_t * 3.0) + i) % 3
		draw_texture_rect_region(_tex, Rect2(x, y, 8, 12), Rect2(f * 8, cloths[i] * 12, 8, 12))
