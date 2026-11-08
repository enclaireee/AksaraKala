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
var _sub: Label   # quality and cost line under the result
var _guide: Node2D
var _guide_line: Line2D


func _ready() -> void:
	_vignette = TextureRect.new()
	_vignette.texture = load("res://assets/art/ui/vignette.png")
	_vignette.self_modulate = Color("1F2A44").lightened(0.35)   # indigo cast tint (ui.md 3b)
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
	_label.theme_type_variation = &"HeaderLarge"
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_size_override("font_size", 15)   # Jersey 15 at its native size: crisp, never scaled
	_label.add_theme_color_override("font_outline_color", INK)
	_label.add_theme_constant_override("outline_size", 4)
	add_child(_label)
	_sub = Label.new()
	_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sub.add_theme_font_size_override("font_size", 10)
	_sub.add_theme_color_override("font_outline_color", INK)
	_sub.add_theme_constant_override("outline_size", 3)
	add_child(_sub)


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
	_glow.default_color = Color(SKY, 0.35)
	_glow.width = 5.0
	_ring.default_color = Color(1, 1, 1, 0.45)
	_label.text = ""
	_sub.text = ""


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


## 1.0 just started, 0.0 out of time: the cursor ring warms toward red and flickers in the last quarter.
func set_time_left(frac: float) -> void:
	if not _open:
		return
	var warm := clampf(1.0 - frac, 0.0, 1.0)
	var c := Color(1, 1, 1, 0.45).lerp(Color(1.0, 0.42, 0.32, 0.95), warm * warm)
	if frac < 0.25 and int(Time.get_ticks_msec() / 90) % 2 == 0:
		c.a *= 0.55
	_ring.default_color = c


func add_point(p: Vector2) -> void:
	_glow.add_point(p)
	_ink.add_point(p)


func is_open() -> bool:
	return _open


## `info` (all optional): glyph_id, perfect, power, cost, screen_pos (the caster on screen).
func finish(ok: bool, text: String, info := {}) -> void:
	if not _open:
		return
	_open = false # stops the ring tracking; stays visible until the tween ends
	_kill()
	var last: Vector2 = _ink.points[-1] if _ink.get_point_count() > 0 else get_viewport().get_mouse_position()
	var bb := Rect2(last, Vector2.ZERO)
	for pt in _ink.points:
		bb = bb.expand(pt)
	_label.text = text
	_label.scale = Vector2.ONE
	_label.reset_size()
	# centred over the stroke, just above it; flips below when there is no room
	var lw := _label.size.x
	var pos := Vector2(bb.get_center().x - lw / 2.0, bb.position.y - _label.size.y - 6.0)
	if pos.y < 6.0:
		pos.y = bb.end.y + 6.0
	_label.position = Vector2(clampf(pos.x, 6.0, 474.0 - lw), clampf(pos.y, 6.0, 264.0 - _label.size.y)).round()
	_label.pivot_offset = _label.size / 2.0
	var perfect: bool = info.get("perfect", false)
	var element: Color = SpellUtil.ELEMENT.get(info.get("glyph_id", ""), SKY)
	_label.add_theme_color_override("font_color", (Color("FFE08A") if perfect else Color("F3E3B8")) if ok else Color("B8AE98"))
	_sub.text = _quality_line(ok, info)
	_sub.add_theme_color_override("font_color", Color("FFE08A") if perfect else Color(element.lightened(0.45), 0.95))
	_sub.reset_size()
	_sub.modulate = Color.WHITE
	_sub.position = Vector2(
		clampf(_label.position.x + (_label.size.x - _sub.size.x) / 2.0, 6.0, 474.0 - _sub.size.x),
		clampf(_label.position.y + _label.size.y - 1.0, 6.0, 264.0 - _sub.size.y)).round()
	if ok and not info.is_empty():
		_glow.default_color = Color(element, 0.5)
		_glow.width = 8.0 if perfect else 6.0
		_sigil(info, element, perfect)
	_label.modulate = Color.WHITE
	_label.modulate.a = 1.0 if text != "" else 0.0
	if ok:
		_label.scale = Vector2(1.35, 1.35)   # a small pop, then settle
		create_tween().set_ignore_time_scale(true).tween_property(_label, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_vignette, "modulate:a", 0.0, 0.3)
	if ok:
		_glow.modulate = Color(2, 2, 2)
		_ink.modulate = Color(12, 12, 12) # ink is dark; overbright modulate flashes it white
		_tween.parallel().tween_property(_glow, "modulate", Color(2, 2, 2, 0), 0.6)
		_tween.parallel().tween_property(_ink, "modulate:a", 0.0, 0.6)
		_tween.parallel().tween_property(_label, "modulate:a", 0.0, 0.6).set_delay(0.1)
		_tween.parallel().tween_property(_sub, "modulate:a", 0.0, 0.6).set_delay(0.2)
	else:
		_glow.modulate = Color(0.5, 0.5, 0.5, 0.6)
		_ink.modulate = Color(0.6, 0.6, 0.6)
		_tween.parallel().tween_property(_glow, "modulate:a", 0.0, 0.3)
		_tween.parallel().tween_property(_ink, "modulate:a", 0.0, 0.3)
		_tween.parallel().tween_property(_label, "modulate:a", 0.0, 0.5).set_delay(0.1)
		_tween.parallel().tween_property(_sub, "modulate:a", 0.0, 0.5).set_delay(0.1)
		# puff: the ring expands where the stroke ended
		_ring.position = last.round()
		_ring.modulate.a = 0.6
		_tween.parallel().tween_property(_ring, "scale", Vector2.ONE * 1.8, 0.3)
		_tween.parallel().tween_property(_ring, "modulate:a", 0.0, 0.3)
	_tween.chain().tween_callback(_hide)


## "Perfect +12% · 25 sakti" under the result; empty when there is nothing to say.
func _quality_line(ok: bool, info: Dictionary) -> String:
	if not ok or info.is_empty():
		return ""
	var parts := PackedStringArray()
	if info.get("perfect", false):
		parts.append("%s +%d%%" % [SpellUtil.tr_or("UI_CAST_PERFECT", "Perfect"), roundi((SpellUtil.PERFECT_BONUS - 1.0) * 100.0)])
	elif float(info.get("power", 1.0)) >= 1.0:
		parts.append(SpellUtil.tr_or("UI_CAST_GOOD", "Clean"))
	else:
		parts.append("%s %d%%" % [SpellUtil.tr_or("UI_CAST_SMUDGED", "Smudged"), roundi(float(info.get("power", 0.7)) * 100.0)])
	if info.has("cost"):
		parts.append("-%d %s" % [ceili(float(info.cost)), SpellUtil.tr_or("UI_CAST_SAKTI", "sakti")])
	return "  ·  ".join(parts)


## A rune ring blooms around the caster; a Perfect cast gets a second, larger one. Frees itself.
func _sigil(info: Dictionary, element: Color, perfect: bool) -> void:
	if not info.has("screen_pos"):
		return
	for i in (2 if perfect else 1):
		var sg := SpellFX.make("cast_sigil", 6, 14.0 - 3.0 * i)
		if sg == null:
			return
		sg.modulate = Color("FFE08A") if (perfect and i == 1) else element
		sg.scale = Vector2.ONE * (0.9 + 0.7 * i + (0.3 if perfect else 0.0))
		sg.position = (info.screen_pos as Vector2).round()
		add_child(sg)


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
	var c := Color(SKY, 0.7)
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
