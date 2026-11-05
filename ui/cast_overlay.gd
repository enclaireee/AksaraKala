class_name CastOverlay
extends CanvasLayer
## Cast mode overlay: vignette, cursor ring, ink trail, result text, practice ghost guide.
## Engine.time_scale is 0.2 while drawing, so every tween ignores time scale and nothing uses delta.

const SKY := Color("56B4E9") # Okabe-Ito sky blue (sakti)
const INK := Color(0.07, 0.06, 0.12)
const RING_R := 12.0

var _open := false
var _tween: Tween
var _vignette: TextureRect
var _ring: Line2D
var _glow: Line2D
var _ink: Line2D
var _label: Label
var _guide: Node2D
var _guide_line: Line2D


func _ready() -> void:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	g.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0), Color(0, 0, 0, 0.7)])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 96 # ponytail: low-res gradient stretched to screen; fine for a vignette
	t.height = 54
	_vignette = TextureRect.new()
	_vignette.texture = t
	_vignette.stretch_mode = TextureRect.STRETCH_SCALE
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vignette.modulate.a = 0.0
	add_child(_vignette)
	_guide = Node2D.new()
	add_child(_guide)
	_glow = _line(5.0, Color(SKY, 0.35))
	_ink = _line(2.0, INK)
	_ring = _line(1.0, Color(1, 1, 1, 0.45))
	for i in 25:
		_ring.add_point(Vector2.from_angle(TAU * i / 24.0) * RING_R)
	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_color_override("font_outline_color", INK)
	_label.add_theme_constant_override("outline_size", 3)
	add_child(_label)


func _line(w: float, c: Color) -> Line2D:
	var l := Line2D.new()
	l.width = w
	l.default_color = c
	l.antialiased = false
	l.joint_mode = Line2D.LINE_JOINT_ROUND
	add_child(l)
	return l


func _process(_d: float) -> void:
	if _open:
		_ring.position = get_viewport().get_mouse_position().round()


func _kill() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_ignore_time_scale(true)


func _reset() -> void:
	_glow.clear_points()
	_ink.clear_points()
	_glow.modulate = Color.WHITE
	_ink.modulate = Color.WHITE
	_label.text = ""


func begin() -> void:
	_kill()
	_reset()
	_open = true
	visible = true
	_ring.visible = true
	_ring.modulate.a = 1.0
	_ring.scale = Vector2.ONE
	_ring.position = get_viewport().get_mouse_position().round()
	_tween.tween_property(_vignette, "modulate:a", 1.0, 0.15)


func add_point(p: Vector2) -> void:
	_glow.add_point(p)
	_ink.add_point(p)


func is_open() -> bool:
	return _open


func finish(ok: bool, text: String) -> void:
	if not _open:
		return
	_open = false # stops the ring tracking; stays visible until the tween ends
	_kill()
	var last := _ink.points[-1] if _ink.get_point_count() > 0 else get_viewport().get_mouse_position()
	_label.text = text
	_label.scale = Vector2.ONE * (3.0 if ok else 1.0)
	_label.reset_size()
	_label.position = (last + Vector2(8, -28)).round()
	_label.position.x = clampf(_label.position.x, 4.0, 476.0 - _label.size.x * _label.scale.x)
	_label.position.y = clampf(_label.position.y, 4.0, 266.0 - _label.size.y * _label.scale.y)
	_label.modulate = Color.WHITE if ok else Color(0.75, 0.75, 0.75)
	_label.modulate.a = 1.0 if text != "" else 0.0
	_tween.tween_property(_vignette, "modulate:a", 0.0, 0.3)
	if ok:
		_glow.modulate = Color(2, 2, 2)
		_ink.modulate = Color(12, 12, 12) # ink is dark; overbright modulate flashes it white
		_tween.parallel().tween_property(_glow, "modulate", Color(2, 2, 2, 0), 0.6)
		_tween.parallel().tween_property(_ink, "modulate:a", 0.0, 0.6)
		_tween.parallel().tween_property(_label, "modulate:a", 0.0, 0.6).set_delay(0.1)
	else:
		_glow.modulate = Color(0.5, 0.5, 0.5, 0.6)
		_ink.modulate = Color(0.6, 0.6, 0.6)
		_tween.parallel().tween_property(_glow, "modulate:a", 0.0, 0.3)
		_tween.parallel().tween_property(_ink, "modulate:a", 0.0, 0.3)
		_tween.parallel().tween_property(_label, "modulate:a", 0.0, 0.5).set_delay(0.1)
		# puff: the ring expands where the stroke ended
		_ring.position = last.round()
		_ring.modulate.a = 0.6
		_tween.parallel().tween_property(_ring, "scale", Vector2.ONE * 1.8, 0.3)
		_tween.parallel().tween_property(_ring, "modulate:a", 0.0, 0.3)
	_tween.chain().tween_callback(_hide)


func cancel() -> void:
	if _tween:
		_tween.kill()   # not _kill(): an empty new tween logs an error
	_open = false
	_hide()


func _hide() -> void:
	_open = false
	visible = false
	_vignette.modulate.a = 0.0
	_reset()


func show_guide(template: PackedVector2Array, rect: Rect2) -> void:
	hide_guide()
	var pts := Recognizer.resample(template, 64)
	if pts.size() < 2:
		return
	var bb := Rect2(pts[0], Vector2.ZERO)
	for p in pts:
		bb = bb.expand(p)
	var s := minf(rect.size.x / maxf(bb.size.x, 0.001), rect.size.y / maxf(bb.size.y, 0.001))
	var off := rect.get_center() - bb.get_center() * s
	for i in pts.size():
		pts[i] = (pts[i] * s + off).round()
	var c := Color(SKY, 0.35)
	_guide_line = Line2D.new()
	_guide_line.width = 2.0
	_guide_line.default_color = c
	_guide_line.antialiased = false
	_guide_line.points = pts
	_guide.add_child(_guide_line)
	var dot := Line2D.new() # start dot: a short fat line
	dot.width = 6.0
	dot.default_color = Color(SKY, 0.8)
	dot.antialiased = false
	dot.points = PackedVector2Array([pts[0], pts[0] + Vector2(0.5, 0)])
	_guide.add_child(dot)
	for i in range(12, pts.size(), 12):
		var d := (pts[i] - pts[i - 1]).normalized()
		if d == Vector2.ZERO:
			continue
		var a := Line2D.new()
		a.width = 1.0
		a.default_color = Color(SKY, 0.7)
		a.antialiased = false
		a.points = PackedVector2Array([pts[i] - d.rotated(0.5) * 5.0, pts[i], pts[i] - d.rotated(-0.5) * 5.0])
		_guide.add_child(a)
	# ponytail: guide shows while overlay is hidden only if the caller opens it; drawn on this layer
	_guide.visible = true


func hide_guide() -> void:
	for c in _guide.get_children():
		c.queue_free()
		_guide.remove_child(c)
	_guide_line = null
