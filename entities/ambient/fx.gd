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
			draw_circle(Vector2(0, -3), 12.0, Color(1.0, 0.6, 0.2, 0.07))
		"fire":
			draw_circle(Vector2(0, -5), 15.0, Color(1.0, 0.55, 0.15, 0.06 + 0.03 * float(_frame() % 2)))
			if _tex:
				draw_texture_rect_region(_tex, Rect2(-6, -13, 12, 14), Rect2(_frame() * 12, 0, 12, 14))
		"butterfly":
			var h := 9.0 + sin(_t * 2.3) * 3.0
			var vx := cos(_t * 0.7 + _p.x)
			draw_rect(Rect2(-2, -1, 4, 1), Color(0.0, 0.0, 0.0, 0.15))
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


func _draw_laundry() -> void:
	var pole := Color(0.5, 0.38, 0.22)
	var top := -18.0
	draw_rect(Rect2(-1, top, 2, 18), pole)
	draw_rect(Rect2(length - 1, top, 2, 18), pole)
	draw_rect(Rect2(-1, top, 2, 1), Color(0.7, 0.58, 0.36))
	draw_rect(Rect2(length - 1, top, 2, 1), Color(0.7, 0.58, 0.36))
	var pts := PackedVector2Array()
	for i in 9:
		var x := length * i / 8.0
		pts.append(Vector2(x, top + 2.0 + sin(PI * i / 8.0) * 2.0))
	draw_polyline(pts, Color(0.82, 0.78, 0.66), 1.0)
	if _tex == null:
		return
	var n := cloths.size()
	for i in n:
		var x := length * (i + 0.5) / n - 4.0
		var y := top + 3.0 + sin(PI * (i + 0.5) / n) * 2.0
		var f := (int(_t * 3.0) + i) % 3
		draw_texture_rect_region(_tex, Rect2(x, y, 8, 12), Rect2(f * 8, cloths[i] * 12, 8, 12))
