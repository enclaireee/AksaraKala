extends Control
## Dev-only glyph recorder. Pick a glyph, hold left mouse in the box and draw, release, then
## S = save as a template, D = discard. "Delete last" removes the newest template. Saves to glyph_dir.

const IDS: Array[String] = ["sunda_ka", "sunda_ga", "sunda_nga", "sunda_ca", "jawa_ha", "jawa_na", "jawa_ca", "jawa_ra", "jawa_ka"]
const MIN_LEN := 24.0
const BOX := Rect2(140, 35, 200, 200)

var glyph_dir := "res://data/glyphs"
var glyphs: Array[GlyphData] = []
var current: PackedVector2Array = PackedVector2Array()   # stroke waiting for save/discard
var drawing := false
var picker: OptionButton
var count_label: Label
var read_label: Label
var warn_label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	picker = OptionButton.new()
	for id in IDS:
		picker.add_item(id)
	picker.position = Vector2(4, 4)
	picker.item_selected.connect(func(_i): current = PackedVector2Array(); refresh())
	add_child(picker)
	count_label = _label(Vector2(4, 30), 130)
	read_label = _label(Vector2(4, 50), 130)
	var y := 100
	for b in [["Save (S)", save_current], ["Discard (D)", discard], ["Delete last", delete_last]]:
		var btn := Button.new()
		btn.text = b[0]
		btn.position = Vector2(4, y)
		btn.size = Vector2(120, 22)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(b[1])
		add_child(btn)
		y += 26
	warn_label = _label(Vector2(346, 4), 130)
	load_glyphs()


func _label(pos: Vector2, w: float) -> Label:
	var l := Label.new()
	l.position = pos
	l.custom_minimum_size.x = w
	l.size.x = w
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", 8)
	add_child(l)
	return l


func load_glyphs() -> void:
	glyphs.clear()
	for id in IDS:
		glyphs.append(ResourceLoader.load("%s/%s.tres" % [glyph_dir, id], "", ResourceLoader.CACHE_MODE_IGNORE))
	refresh()


func selected() -> GlyphData:
	return glyphs[picker.selected]


## Returns true if the stroke was kept as the pending take.
func submit_stroke(points: PackedVector2Array) -> bool:
	if Recognizer.path_length(points) < MIN_LEN:
		return false
	current = points
	var r := Recognizer.classify(current, glyphs)
	read_label.text = "read: %s\nscore %.2f power %.1f" % [r.glyph.id if r.glyph else "-", r.score, r.power]
	queue_redraw()
	return true


func save_current() -> void:
	if current.is_empty():
		return
	selected().templates.append(current)
	current = PackedVector2Array()
	_save()


func discard() -> void:
	current = PackedVector2Array()
	read_label.text = ""
	queue_redraw()


func delete_last() -> void:
	if selected().templates.is_empty():
		return
	selected().templates.pop_back()
	_save()


func _save() -> void:
	var g := selected()
	ResourceSaver.save(g, g.resource_path)
	refresh()


func refresh() -> void:
	count_label.text = "%s: %d templates" % [selected().id, selected().templates.size()]
	var rep := LookAlike.report(glyphs)   # ponytail: whole report each refresh, fine for 9 glyphs
	var lines: Array[String] = []
	for p in rep.pairs:
		lines.append("close: %s / %s %.2f" % [p.a, p.b, p.score])
	for r in rep.glyphs:
		if r.total > 0 and (r.wrong + r.fizzle) * 10 > r.total:
			lines.append("%s: %d wrong, %d fizzle of %d (vs %s)" % [r.id, r.wrong, r.fizzle, r.total, r.confused])
	warn_label.text = "\n".join(lines)
	queue_redraw()


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		if e.pressed and BOX.has_point(e.position):
			drawing = true
			current = PackedVector2Array([e.position])
		elif not e.pressed and drawing:
			drawing = false
			if not submit_stroke(current):
				current = PackedVector2Array()
		queue_redraw()
	elif e is InputEventMouseMotion and drawing:
		current.append(e.position)
		queue_redraw()


func _unhandled_key_input(e: InputEvent) -> void:
	if e.pressed and not e.echo:
		if e.keycode == KEY_S:
			save_current()
		elif e.keycode == KEY_D:
			discard()


func _draw() -> void:
	draw_rect(BOX, Color(0.15, 0.15, 0.2), true)
	draw_rect(BOX, Color.GRAY, false)
	if glyphs.is_empty():
		return
	for t in selected().templates:   # faint, fitted into the box
		var n := Recognizer.normalize(t)
		for i in range(1, n.size()):
			draw_line(BOX.get_center() + n[i - 1] * 160.0, BOX.get_center() + n[i] * 160.0, Color(1, 1, 1, 0.2), 2.0)
	if current.size() > 1:
		draw_polyline(current, Color.YELLOW, 2.0)
