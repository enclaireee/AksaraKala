extends CanvasLayer
## One-time glyph lesson after every Events.glyph_learned (spells.md 5, ui.md). Waits while a dialogue is open,
## then shows a card (name, aksara, what it does, tip) and the ghost guide; the player casts the glyph NEEDED
## times in practice mode (no sakti, no cost). Does not pause the tree. Holding interact skips.
## Write mode: Events.write_requested(seq_id, glyphs) shows a full-screen ink card, pauses the tree and has the player draw
## each glyph in order with the ghost guide. A stroke is scored only against the glyph asked for (Recognizer, same threshold as
## the sanggar); a miss just clears it. After the last, the card fades, the pause is restored and Events.name_written(seq_id) fires.
## ASSUMED: Events.spell_cast's "score" is the cast power (1.0 full, 0.7 smudged), shown as a percentage.

const NEEDED := 3   # TUNE: successful casts per lesson
const HOLD := 1.0
const GUIDE_RECT := Rect2(380, 20, 80, 80)   # same corner as zones/desa_purwa.gd
const JAWA := "/System/Library/Fonts/Supplemental/NotoSansJavanese-Regular.otf"
const SUNDA := "/System/Library/Fonts/Supplemental/NotoSansSundanese-Regular.ttf"
# ponytail: system fonts like prologue.gd; falls back to the Latin name when missing
const CHARS := {
	"sunda_ka": "ᮊ", "sunda_ga": "ᮌ", "sunda_nga": "ᮍ", "sunda_ca": "ᮎ",
	"jawa_ha": "ꦲ", "jawa_na": "ꦤ", "jawa_ca": "ꦕ", "jawa_ra": "ꦫ",
	"sunda_la": "ᮜ", "sunda_ra": "ᮛ", "sunda_sa": "ᮞ",   # write-only (no lesson, no spell)
}
const MIN_LEN := 40.0   # px; a shorter stroke is a click, not an attempt
const SLOT := Vector2(100, 100)
const INK := Color(0.07, 0.06, 0.12)

var active := ""
var count := 0
var _queue: Array[String] = []
var _dialogue := false
var _prev_practice := false
var _cast: Node
var _hold := 0.0
var _guide: CastOverlay
var _panel: Control
var _name: Label
var _aksara: Label
var _body: Label
var _tip: Label
var _progress: Label
var _msg: Label
var writing := ""   # write-mode sequence id while the card is up
var _seq := PackedStringArray()
var _wi := 0
var _wait: Array = []   # [seq_id, glyphs] asked for during a dialogue
var _wpts := PackedVector2Array()
var _wdraw := false
var _wfade := false
var _wpaused := false
var _card: Control
var _wguide: CastOverlay
var _stroke: Line2D


func _ready() -> void:
	layer = 11
	process_mode = Node.PROCESS_MODE_ALWAYS   # write mode runs with the tree paused
	_guide = preload("res://ui/cast_overlay.tscn").instantiate()
	_guide.layer = 4
	add_child(_guide)
	_panel = Control.new()
	_panel.visible = false
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)
	var bg := ColorRect.new()
	bg.color = Color(INK, 0.85)
	bg.position = Vector2(6, 6)
	bg.size = Vector2(250, 108)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(bg)
	_name = _label(Vector2(12, 9), Vector2(150, 12))
	_aksara = _label(Vector2(200, 8), Vector2(50, 36))
	_aksara.add_theme_font_size_override("font_size", 28)
	_aksara.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body = _label(Vector2(12, 22), Vector2(184, 36))
	_tip = _label(Vector2(12, 60), Vector2(238, 28))
	_tip.modulate = Color("E8D9A0")
	_progress = _label(Vector2(12, 92), Vector2(150, 12))
	_msg = _label(Vector2(12, 120), Vector2(250, 12))
	_msg.modulate = Color(0.9, 0.7, 0.5)
	var hint := _label(Vector2(150, 92), Vector2(100, 12))
	hint.text = tr("UI_HOLD_SKIP")
	hint.modulate = Color(1, 1, 1, 0.6)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var ev := get_node("/root/Events")
	ev.glyph_learned.connect(_on_learned)
	ev.dialogue_requested.connect(func(_s, _l): _dialogue = true)
	ev.dialogue_finished.connect(_on_dialogue_finished)
	ev.spell_cast.connect(_on_cast)
	ev.write_requested.connect(_on_write)
	_card = ColorRect.new()
	_card.color = INK
	_card.set_anchors_preset(Control.PRESET_FULL_RECT)
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.visible = false
	add_child(_card)
	_wguide = preload("res://ui/cast_overlay.tscn").instantiate()
	_wguide.layer = 12   # over the card
	add_child(_wguide)
	_stroke = Line2D.new()
	_stroke.width = 2.0
	_stroke.default_color = Color("E8D9A0")
	_stroke.antialiased = false
	_card.add_child(_stroke)
	var hint_w := Label.new()
	hint_w.text = "UI_WRITE_HINT"
	hint_w.position = Vector2(0, 220)
	hint_w.size = Vector2(480, 12)
	hint_w.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_w.modulate = Color(1, 1, 1, 0.6)
	_card.add_child(hint_w)


func _label(pos: Vector2, sz: Vector2) -> Label:
	var l := Label.new()
	l.position = pos
	l.size = sz
	l.add_theme_font_size_override("font_size", 8)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(l)
	return l


func _on_learned(id: String) -> void:
	_queue.append(id)
	if not _dialogue:
		_next.call_deferred()


func _on_dialogue_finished() -> void:
	_dialogue = false
	if not _wait.is_empty():
		var w := _wait
		_wait = []
		_on_write.call_deferred(w[0], w[1])
	_next.call_deferred()


func _next() -> void:
	if active != "" or _dialogue or _queue.is_empty():
		return
	var id: String = _queue.pop_front()
	var g := GlyphData.by_id(id)
	var spell := SpellData.for_glyph(id)
	if g == null or spell == null:
		_next()
		return
	active = id
	count = 0
	_hold = 0.0
	var up := id.to_upper()
	_name.text = "%s · %s" % [g.latin.capitalize(), _t(spell.title)]
	_aksara.text = CHARS.get(id, g.latin)
	_font(_aksara, g)
	_body.text = _t("CODEX_%s_BODY" % up)
	_tip.text = _t("LESSON_%s" % up)
	_msg.text = ""
	_set_progress(1.0, false)
	var player := get_tree().get_first_node_in_group("player")
	_cast = player.get("cast") if player else null
	if _cast:
		_prev_practice = _cast.practice
		_cast.practice = true
	_guide.visible = true
	_guide.show_guide(g.templates[0], GUIDE_RECT)
	_panel.visible = true


func _t(key: String) -> String:
	return get_node("/root/Game").fmt(tr(key))


## The aksara system font on a label, or the Latin fallback text when it is missing.
func _font(l: Label, g: GlyphData) -> void:
	var path: String = JAWA if g.aksara == "jawa" else SUNDA
	if FileAccess.file_exists(path) and CHARS.has(g.id):
		var f := FontFile.new()
		f.load_dynamic_font(path)
		l.add_theme_font_override("font", f)
	else:
		l.remove_theme_font_override("font")


func _set_progress(power: float, shown := true) -> void:
	var t := _t("UI_LESSON_PROGRESS") % [count, NEEDED]
	_progress.text = t + (" · %d%%" % roundi(power * 100.0) if shown else "")


func _on_cast(glyph_id: String, score: float) -> void:
	if active == "":
		return
	if glyph_id != active:
		var other := GlyphData.by_id(glyph_id)
		_msg.text = _t("UI_LESSON_WRONG") % [other.latin.capitalize() if other else glyph_id, GlyphData.by_id(active).latin.capitalize()]
		return
	count += 1
	_msg.text = ""
	_set_progress(score)
	if count >= NEEDED:
		finish()


func finish() -> void:
	if active == "":
		return
	active = ""
	# Only undo our own switch: the sanggar (desa_purwa.gd) may have changed practice since, so never set it back to true.
	if is_instance_valid(_cast) and not _prev_practice:
		_cast.practice = false
	_cast = null
	_guide.hide_guide()
	_guide.visible = false
	_panel.visible = false
	_next.call_deferred()


func _process(delta: float) -> void:
	_hold = _hold + delta if active != "" and not get_tree().paused and Input.is_action_pressed("interact") else 0.0
	if _hold >= HOLD:
		_hold = 0.0
		finish()


# --- write mode ---

func _on_write(seq_id: String, glyphs: PackedStringArray) -> void:
	if _dialogue:
		_wait = [seq_id, glyphs]
		return
	if writing != "" or glyphs.is_empty():
		return
	finish()   # a lesson in progress ends
	writing = seq_id
	_seq = glyphs
	_wi = 0
	_wfade = false
	_wdraw = false
	_card.modulate.a = 1.0
	_card.visible = true
	for c in _card.get_children():
		if c is Label and c.has_meta("written"):
			c.queue_free()
	_wpaused = get_tree().paused
	get_tree().paused = true
	_wshow()


func _slot(i: int) -> Rect2:
	return Rect2(Vector2((480.0 - _seq.size() * SLOT.x) / 2.0 + i * SLOT.x, 70), SLOT)


func _wshow() -> void:
	var g := GlyphData.by_id(_seq[_wi])
	_wguide.visible = true
	_wguide.show_guide(g.templates[0], _slot(_wi).grow(-10))


## One stroke attempt at the current glyph. True and moves on when it reads as that glyph, else nothing changes.
func write_attempt(stroke: PackedVector2Array) -> bool:
	if writing == "" or _wfade or Recognizer.path_length(stroke) < MIN_LEN:
		return false
	var g := GlyphData.by_id(_seq[_wi])
	if Recognizer.classify(stroke, [g] as Array[GlyphData]).power <= 0.0:
		return false
	var l := Label.new()
	l.set_meta("written", true)
	l.text = CHARS.get(g.id, g.latin)
	_font(l, g)
	l.add_theme_font_size_override("font_size", 48)
	l.add_theme_color_override("font_color", Color("E8D9A0"))
	l.position = _slot(_wi).position
	l.size = SLOT
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_card.add_child(l)
	_wi += 1
	if _wi < _seq.size():
		_wshow()
	else:
		_wguide.hide_guide()
		_wfade = true
		var tw := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_interval(0.8)
		tw.tween_property(_card, "modulate:a", 0.0, 0.8)
		tw.tween_callback(_write_done)
	return true


func _write_done() -> void:
	var id := writing
	writing = ""
	_card.visible = false
	_wguide.hide_guide()
	_wguide.visible = false
	_stroke.clear_points()
	get_tree().paused = _wpaused
	get_node("/root/Events").name_written.emit(id)


func _input(e: InputEvent) -> void:
	if writing == "" or _wfade:
		return
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		if e.pressed:
			_wdraw = true
			_wpts = PackedVector2Array([e.position])
			_stroke.points = _wpts
		elif _wdraw:
			_wdraw = false
			write_attempt(_wpts)   # a miss just clears it
			_stroke.clear_points()
	elif e is InputEventMouseMotion and _wdraw:
		_wpts.append(e.position)
		_stroke.add_point(e.position)
