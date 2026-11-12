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
const CARD := Rect2(292, 56, 180, 160)   # right edge (8 px margin), under Ilmu and the toast row: clear of tracker, banner, dialogue
const GUIDE_RECT := Rect2(CARD.position.x + 14.0, CARD.position.y + 32.0, 68.0, 68.0)   # the ghost glyph sits in the card's slot
const INK_HEAD := UIFx.ACCENT   # on the dusk card: the cyan glyph light (ui.md 0.1)
const HINT_COL := UIFx.DIM
const JAWA := "res://assets/fonts/NotoSansJavanese.ttf"
const SUNDA := "res://assets/fonts/NotoSansSundanese.ttf"
const GOLD := UIFx.HEAD
const DIM := UIFx.DIM
const CHARS := {
	"sunda_ka": "ᮊ", "sunda_ga": "ᮌ", "sunda_nga": "ᮍ", "sunda_ca": "ᮎ",
	"jawa_ha": "ꦲ", "jawa_na": "ꦤ", "jawa_ca": "ꦕ", "jawa_ra": "ꦫ",
	"sunda_ha": "ᮠ", "sunda_pa": "ᮕ", "jawa_pa": "ꦥ", "jawa_wa": "ꦮ",
	"jawa_ga": "ꦒ", "sunda_ba": "ᮘ", "sunda_ta": "ᮒ", "jawa_la": "ꦭ",   # signature aksara, one per class
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
var _pips: Array[TextureRect] = []
var _hold_bar: ColorRect
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
var _leaf: NinePatchRect
var _lamp: TextureRect
var _wguide: CastOverlay
var _stroke: Line2D


func _ready() -> void:
	layer = 11
	process_mode = Node.PROCESS_MODE_ALWAYS   # write mode runs with the tree paused
	_guide = preload("res://ui/cast_overlay.tscn").instantiate()
	_guide.layer = 12   # over the card panel and slot
	add_child(_guide)
	_panel = Control.new()
	_panel.visible = false
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)
	var cx := CARD.position.x
	var cy := CARD.position.y
	var bg := _nine("ink_panel", CARD, 4)   # the in-world ink card (ui.md 0)
	_panel.move_child(bg, 0)
	_name = _label(Vector2(cx + 10, cy + 8), Vector2(CARD.size.x - 20, 13))
	_name.add_theme_font_override("font", UIFx.head_font())
	_name.add_theme_font_size_override("font_size", UIFx.HEAD_SIZE)
	_name.add_theme_color_override("font_color", UIFx.GOLD_HI)
	_name.autowrap_mode = TextServer.AUTOWRAP_OFF
	var rule := ColorRect.new()   # one hairline under the name
	rule.color = UIFx.LINE_DIM
	rule.position = Vector2(cx + 10, cy + 23)
	rule.size = Vector2(CARD.size.x - 20, 1)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(rule)
	_nine("ink_slot", Rect2(cx + 10, cy + 28, 76, 76), 4)   # the drawing well holding the ghost glyph
	_aksara = _label(Vector2(cx + 92, cy + 28), Vector2(78, 38))
	_aksara.autowrap_mode = TextServer.AUTOWRAP_OFF
	_aksara.add_theme_font_size_override("font_size", 28)
	_aksara.add_theme_color_override("font_color", INK_HEAD)
	_aksara.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aksara.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	for i in NEEDED:   # one lozenge per cast: lit once done
		var d := TextureRect.new()
		d.texture = load("res://assets/art/ui/ink_cursor.png")
		d.position = Vector2(cx + 92 + (78 - NEEDED * 5 - (NEEDED - 1) * 6) / 2 + i * 11, cy + 72)
		d.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_panel.add_child(d)
		_pips.append(d)
	_progress = _label(Vector2(cx + 92, cy + 82), Vector2(78, 12))
	_progress.autowrap_mode = TextServer.AUTOWRAP_OFF
	_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_msg = _label(Vector2(cx + 92, cy + 94), Vector2(78, 12))
	_msg.autowrap_mode = TextServer.AUTOWRAP_OFF
	_msg.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_msg.add_theme_color_override("font_color", INK_HEAD)
	_tip = _label(Vector2(cx + 10, cy + 108), Vector2(CARD.size.x - 20, 36))
	_body = _label(Vector2.ZERO, Vector2.ONE)   # the codex lore stays in the codex; the card only teaches the stroke
	_body.visible = false
	var hint := _label(Vector2(cx + 10, cy + CARD.size.y - 17), Vector2(CARD.size.x - 20, 12))
	hint.text = tr("UI_HOLD_SKIP")
	hint.autowrap_mode = TextServer.AUTOWRAP_OFF
	hint.add_theme_color_override("font_color", HINT_COL)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hold_bar = ColorRect.new()
	_hold_bar.color = INK_HEAD
	_hold_bar.position = Vector2(cx + 10, cy + CARD.size.y - 8)
	_hold_bar.size = Vector2(0, 1)
	_hold_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_hold_bar)
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
	_leaf = NinePatchRect.new()   # the lontar leaf the glyphs are written on (tools/gen_story_props.py)
	_leaf.texture = load("res://assets/art/ui/lontar_card.png")
	_leaf.patch_margin_left = 18
	_leaf.patch_margin_right = 18
	_leaf.patch_margin_top = 4
	_leaf.patch_margin_bottom = 4
	_leaf.modulate = Color(0.42, 0.34, 0.24)   # lamplit and dim, so the gold ink still reads
	_leaf.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_leaf.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(_leaf)
	_lamp = TextureRect.new()
	_lamp.texture = StoryArt.tex("kelir_lamp")
	_lamp.scale = Vector2(2, 2)
	_lamp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_lamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(_lamp)
	_wguide = preload("res://ui/cast_overlay.tscn").instantiate()
	_wguide.layer = 12   # over the card
	add_child(_wguide)
	_stroke = Line2D.new()
	_stroke.width = 2.0
	_stroke.default_color = GOLD
	_stroke.antialiased = false
	_card.add_child(_stroke)
	var hint_w := Label.new()
	hint_w.text = tr("UI_WRITE_HINT")
	hint_w.position = Vector2(0, 220)
	hint_w.size = Vector2(480, 12)
	hint_w.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_w.add_theme_color_override("font_color", DIM)   # the theme default is paper ink: invisible on this dark card
	_card.add_child(hint_w)


func _nine(tex: String, rect: Rect2, m: int) -> NinePatchRect:
	var r := NinePatchRect.new()
	r.texture = load("res://assets/art/ui/%s.png" % tex)
	for side in ["left", "top", "right", "bottom"]:
		r.set("patch_margin_" + side, m)
	r.position = rect.position
	r.size = rect.size
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(r)
	return r


func _label(pos: Vector2, sz: Vector2) -> Label:
	var l := Label.new()
	l.position = pos
	l.size = sz
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_color_override("font_color", UIFx.CREAM)   # body on the ink card
	l.add_theme_constant_override("line_spacing", 1)
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
	if active != "" or writing != "" or _dialogue or _queue.is_empty():   # a write card holds lessons back
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
	if CHARS.has(g.id) and ResourceLoader.exists(path):
		l.add_theme_font_override("font", load(path))
	else:
		l.remove_theme_font_override("font")


func _set_progress(power: float, shown := true) -> void:
	_progress.text = "%d / %d" % [count, NEEDED] + ("  %d%%" % roundi(power * 100.0) if shown and count > 0 else "")
	for i in _pips.size():
		_pips[i].modulate = Color.WHITE if i < count else Color(1, 1, 1, 0.3)


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
	if _hold_bar != null:
		_hold_bar.size.x = (CARD.size.x - 20.0) * clampf(_hold / HOLD, 0.0, 1.0)
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
	var lx := (480.0 - _seq.size() * SLOT.x) / 2.0 - 26.0
	_leaf.position = Vector2(lx, 58)
	_leaf.size = Vector2(_seq.size() * SLOT.x + 52.0, 124)
	_lamp.position = Vector2(lx - 36.0, 120)
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
	l.add_theme_color_override("font_color", GOLD)
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
	_next()


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
