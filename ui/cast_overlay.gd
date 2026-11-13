class_name CastOverlay
extends CanvasLayer
## Cast mode overlay: vignette, cursor ring, ink trail, result text, practice ghost guide.
## Engine.time_scale is 0.2 while drawing, so every tween ignores time scale and nothing uses delta.

const SKY := Color("56B4E9") # Okabe-Ito sky blue (sakti)
const INK := Color(0.07, 0.06, 0.12)
const RING_R := 12.0
const INK_DIR := "res://assets/art/fx/ink/%s.png"
const BRUSH_W := 7.0          # brush width at the slowest pen speed
const MIN_W := 2.0            # the stroke never gets thinner than this
const WET_EXTRA := 2.0        # the darker wet edge is this much wider than the ink
const FAST := 0.9             # px per ms: at or above this the stroke is thinnest
const TURN_COS := 0.342       # cos(70 deg): a sharper turn than this splatters
const MAX_MARKS := 14
static var _tex_cache := {}

var _open := false
var _tween: Tween
var _vignette: TextureRect
var _ring: Line2D
var _glow: Line2D   # the wet edge: a wider line under the ink in a darkened element colour
var _ink: Line2D
var _marks: Node2D  # blots and splatters, fades with the stroke
var _speeds := PackedFloat32Array()   # pen speed per ink point, drives the width curve
var _last_ms := 0
var _since_splat := 0
var _ink_col := Color.WHITE
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
	_ink_col = SKY.lightened(0.3)
	_glow = _line(BRUSH_W + WET_EXTRA, _ink_col.darkened(0.55), false)
	_ink = _line(BRUSH_W, _ink_col)
	_marks = Node2D.new()
	_marks.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_marks)
	_ring = _line(4.0, Color(1, 1, 1, 0.45))
	for i in 24:
		_ring.add_point(Vector2.from_angle(TAU * i / 24.0) * RING_R)
	_ring.closed = true
	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_override("font", UIFx.head_font())   # Jersey 10 at 19: the heading step (ui.md 1)
	_label.add_theme_font_size_override("font_size", UIFx.HEAD_SIZE)
	_label.add_theme_color_override("font_outline_color", INK)
	_label.add_theme_constant_override("outline_size", 4)
	add_child(_label)
	_sub = Label.new()
	_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sub.add_theme_font_override("font", UIFx.body_font())
	_sub.add_theme_font_size_override("font_size", UIFx.BODY)
	_sub.add_theme_color_override("font_outline_color", INK)
	_sub.add_theme_constant_override("outline_size", 3)
	add_child(_sub)


## Pixel brush texture; null when the art is missing (the line then draws flat, still without AA).
static func ink_tex(name: String) -> Texture2D:
	if not _tex_cache.has(name):
		var p := INK_DIR % name
		_tex_cache[name] = load(p) if ResourceLoader.exists(p) else null
	return _tex_cache[name]


## A Line2D in the brush look: tiled pixel brush, hard pixels, no AA. `brush` false gives the flat wet edge.
static func brush_line(w: float, c: Color, brush := true) -> Line2D:
	var l := Line2D.new()
	l.width = w
	l.default_color = c
	l.antialiased = false
	l.joint_mode = Line2D.LINE_JOINT_ROUND
	l.begin_cap_mode = Line2D.LINE_CAP_ROUND
	l.end_cap_mode = Line2D.LINE_CAP_ROUND
	l.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if brush:
		l.texture = ink_tex("brush")
		l.texture_mode = Line2D.LINE_TEXTURE_TILE
		l.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	return l


func _line(w: float, c: Color, brush := true) -> Line2D:
	var l := brush_line(w, c, brush)
	add_child(l)
	return l


## A strip sprite played once by a tween that ignores Engine.time_scale. Holds the last frame when `hold` is true.
func _strip_fx(parent: Node, name: String, frames: int, pos: Vector2, tint: Color, sc: float, secs: float, hold: bool) -> Sprite2D:
	var t := ink_tex(name)
	if t == null:
		return null
	var s := Sprite2D.new()
	s.texture = t
	s.hframes = frames
	s.modulate = tint
	s.scale = Vector2.ONE * sc
	s.position = pos.round()
	parent.add_child(s)
	var tw := s.create_tween().set_ignore_time_scale(true)
	tw.tween_property(s, "frame", frames - 1, secs).from(0)
	if not hold:
		tw.tween_callback(s.queue_free)
	return s


func _mark(name: String, frames: int, pos: Vector2, sc: float) -> void:
	if _marks.get_child_count() < MAX_MARKS:
		_strip_fx(_marks, name, frames, pos, _ink_col, sc, 0.14, true)


## Thick when the pen is slow, thin when fast; never under MIN_W. `extra` widens the wet edge.
func _width_curve(extra: float) -> Curve:
	var c := Curve.new()
	var n := _speeds.size()
	var full := BRUSH_W + extra
	var step := maxi(1, n / 32)   # a Curve of at most ~32 points is plenty, and cheap to rebuild
	var i := 0
	while i < n:
		var px := lerpf(BRUSH_W, MIN_W, clampf(_speeds[i] / FAST, 0.0, 1.0))
		c.add_point(Vector2(float(i) / maxf(n - 1, 1), (px + extra) / full), 0.0, 0.0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
		i = n - 1 if (i < n - 1 and i + step >= n) else i + step
	return c


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
	_speeds.clear()
	_since_splat = 0
	for m in _marks.get_children():
		m.queue_free()
		_marks.remove_child(m)
	_marks.modulate = Color.WHITE
	_glow.modulate = Color.WHITE
	_ink.modulate = Color.WHITE
	_set_ink_color(SKY.lightened(0.3))
	_ring.default_color = Color(1, 1, 1, 0.45)
	_label.text = ""
	_sub.text = ""


func _set_ink_color(c: Color) -> void:
	_ink_col = c
	_ink.default_color = c
	_glow.default_color = c.darkened(0.55)


func begin() -> void:
	_kill()
	_reset()
	_open = true
	Snd.cast(true)
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
	Snd.ink(110.0 + randf() * 160.0)
	var now := Time.get_ticks_msec()   # wall clock, so slow motion does not thicken the stroke
	var n := _ink.get_point_count()
	var spd := 0.0
	if n > 0:
		spd = _ink.points[n - 1].distance_to(p) / maxf(float(now - _last_ms), 1.0)
		spd = lerpf(_speeds[n - 1], spd, 0.5) if n > 1 else spd   # smooth
	_last_ms = now
	_speeds.append(spd)
	if n == 1:
		_speeds[0] = spd
	_glow.add_point(p)
	_ink.add_point(p)
	_ink.width_curve = _width_curve(0.0)
	_glow.width_curve = _width_curve(WET_EXTRA)
	_since_splat += 1
	if n == 0:
		_mark("blot", 4, p, 1.0)
	elif n >= 4 and _since_splat > 5:
		var a := _ink.points[n - 1] - _ink.points[n - 4]
		var b := p - _ink.points[n - 1]
		if a.length() > 3.0 and b.length() > 1.5 and a.normalized().dot(b.normalized()) < TURN_COS:
			_since_splat = 0
			_mark("splatter", 4, _ink.points[n - 1], 1.0)


func is_open() -> bool:
	return _open


## `info` (all optional): glyph_id, perfect, power, cost, screen_pos (the caster on screen).
func finish(ok: bool, text: String, info := {}) -> void:
	if not _open:
		return
	_open = false # stops the ring tracking; stays visible until the tween ends
	Snd.cast(false)
	if not ok:
		Snd.play("cast_fail")
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
	_label.add_theme_color_override("font_color", (Color("D8FFFB") if perfect else UIFx.HEAD) if ok else UIFx.DIM)
	_sub.text = _quality_line(ok, info)
	_sub.add_theme_color_override("font_color", UIFx.ACCENT if perfect else Color(element.lightened(0.45), 0.95))
	_sub.reset_size()
	_sub.modulate = Color.WHITE
	_sub.position = Vector2(
		clampf(_label.position.x + (_label.size.x - _sub.size.x) / 2.0, 6.0, 474.0 - _sub.size.x),
		clampf(_label.position.y + _label.size.y - 1.0, 6.0, 264.0 - _sub.size.y)).round()
	if ok and not info.is_empty():
		_set_ink_color(element)
		_sigil(info, element, perfect)
	_label.modulate = Color.WHITE
	_label.modulate.a = 1.0 if text != "" else 0.0
	if ok:
		_label.scale = Vector2(1.35, 1.35)   # a small pop, then settle
		create_tween().set_ignore_time_scale(true).tween_property(_label, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if _ink.get_point_count() > 0:
		_mark("blot", 4, last, 1.0)   # the pen lifts: a blot at the end of the stroke
	_tween.tween_property(_vignette, "modulate:a", 0.0, 0.3)
	if ok:
		_seal(bb, element)
		_tween.parallel().tween_property(_glow, "modulate:a", 0.0, 0.6)
		_tween.parallel().tween_property(_ink, "modulate:a", 0.0, 0.6)
		_tween.parallel().tween_property(_marks, "modulate:a", 0.0, 0.6)
		_tween.parallel().tween_property(_label, "modulate:a", 0.0, 0.6).set_delay(0.1)
		_tween.parallel().tween_property(_sub, "modulate:a", 0.0, 0.6).set_delay(0.2)
	else:
		_glow.modulate = Color(0.5, 0.5, 0.5, 0.6)
		_ink.modulate = Color(0.6, 0.6, 0.6)
		_marks.modulate = Color(0.6, 0.6, 0.6)
		_tween.parallel().tween_property(_marks, "modulate:a", 0.0, 0.3)
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


## The carved seal stamps over the finished glyph in the element colour, bursts into chunks and is gone.
func _seal(bb: Rect2, element: Color) -> void:
	var sc := clampi(roundi(maxf(bb.size.x, bb.size.y) / 48.0), 1, 3)   # whole-number scale keeps pixels square
	var s := _strip_fx(self, "seal", 7, bb.get_center(), element, float(sc), 0.4, false)
	if s:
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		move_child(s, _label.get_index())


## A rune ring blooms around the caster; a Perfect cast gets a second, larger one. Frees itself.
func _sigil(info: Dictionary, element: Color, perfect: bool) -> void:
	if not info.has("screen_pos"):
		return
	for i in (2 if perfect else 1):
		var sg := SpellFX.make("cast_sigil", 6, 14.0 - 3.0 * i)
		if sg == null:
			return
		sg.modulate = UIFx.ACCENT if (perfect and i == 1) else element
		sg.scale = Vector2.ONE * (0.9 + 0.7 * i + (0.3 if perfect else 0.0))
		sg.position = (info.screen_pos as Vector2).round()
		add_child(sg)


func cancel() -> void:
	if _tween:
		_tween.kill()   # not _kill(): an empty new tween logs an error
	_open = false
	Snd.cast(false)
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
	_guide_line = brush_line(4.0, Color(SKY, 0.5))
	_guide_line.points = pts
	_guide.add_child(_guide_line)
	_strip_fx(_guide, "blot", 4, pts[0], Color(SKY, 0.7), 1.0, 0.01, true)   # start blot
	for i in range(12, pts.size(), 12):
		var d := (pts[i] - pts[i - 1]).normalized()
		if d == Vector2.ZERO:
			continue
		var a := brush_line(3.0, Color(SKY, 0.5))
		a.points = PackedVector2Array([pts[i] - d.rotated(0.5) * 5.0, pts[i], pts[i] - d.rotated(-0.5) * 5.0])
		_guide.add_child(a)
	# ponytail: guide shows while overlay is hidden only if the caller opens it; drawn on this layer
	_guide.visible = true


func hide_guide() -> void:
	for c in _guide.get_children():
		c.queue_free()
		_guide.remove_child(c)
	_guide_line = null
