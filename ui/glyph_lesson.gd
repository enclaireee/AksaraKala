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
const CARD := Rect2(256, 56, 216, 176)   # right edge (8 px margin), under Ilmu, the Esc hint and the toast row (ends Y 51): clear of tracker, banner, dialogue
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
var _target_count := NEEDED
var _sakti_handoff := false   # Semar's sunda_ka drill: Phase A (2 free draws) -> Phase B (live Sakti cast)
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
var _cast_cue: Label
var _cast_mouse: TextureRect
var _cast_keycap: Control   # keyboard-bound cast key (the mouse icon is for RMB/LMB)
var _cast_mouse_atlas: AtlasTexture
var _hint_w: Label
var _bg: NinePatchRect
var _hint: Label
var _h := CARD.size.y   # card height: stacks tip, cue row, skip hint, hold bar (_fit)
var _row_y := 0.0   # absolute y of the cue row (mouse icon / keycap + verb)
var _write_mouse: TextureRect
var _write_mouse_atlas: AtlasTexture
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
var _wet: Line2D


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
	_bg = _nine("ink_panel", CARD, 4)   # the in-world ink card (ui.md 0)
	_panel.move_child(_bg, 0)
	_name = _label(Vector2(cx + 10, cy + 8), Vector2(CARD.size.x - 20, UIFx.LINE - 1))
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
	_aksara = _label(Vector2(cx + 92, cy + 28), Vector2(CARD.size.x - 102, 38))
	_aksara.autowrap_mode = TextServer.AUTOWRAP_OFF
	_aksara.add_theme_font_size_override("font_size", 28)
	_aksara.add_theme_color_override("font_color", INK_HEAD)
	_aksara.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aksara.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	for i in NEEDED:   # one lozenge per cast: lit once done
		var d := TextureRect.new()
		d.texture = load("res://assets/art/ui/ink_cursor.png")
		d.position = Vector2(cx + 92 + (CARD.size.x - 102 - NEEDED * 5 - (NEEDED - 1) * 6) / 2 + i * 11, cy + 72)
		d.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_panel.add_child(d)
		_pips.append(d)
	_progress = _label(Vector2(cx + 92, cy + 80), Vector2(CARD.size.x - 102, UIFx.LINE - 1))
	_progress.autowrap_mode = TextServer.AUTOWRAP_OFF
	_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_msg = _label(Vector2(cx + 92, cy + 94), Vector2(CARD.size.x - 102, UIFx.LINE - 1))
	_msg.autowrap_mode = TextServer.AUTOWRAP_OFF
	_msg.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_msg.add_theme_color_override("font_color", INK_HEAD)
	_tip = _label(Vector2(cx + 10, cy + 108), Vector2(CARD.size.x - 20, UIFx.LINE * 3 - 1))
	_body = _label(Vector2.ZERO, Vector2.ONE)   # the codex lore stays in the codex; the card only teaches the stroke
	_body.visible = false
	_cast_mouse_atlas = AtlasTexture.new()
	if ResourceLoader.exists("res://assets/art/ui/tut_mouse_rmb.png"):
		_cast_mouse_atlas.atlas = load("res://assets/art/ui/tut_mouse_rmb.png")
	_cast_mouse_atlas.region = Rect2(0, 0, 12, 16)
	_cast_mouse = TextureRect.new()
	_cast_mouse.texture = _cast_mouse_atlas
	_cast_mouse.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_cast_mouse.position = Vector2(cx + 10, cy + CARD.size.y - 31)
	_cast_mouse.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_cast_mouse)
	_cast_cue = _label(Vector2(cx + 10 + 12 + UIFx.GAP, cy + CARD.size.y - 29), Vector2(CARD.size.x - 42, UIFx.LINE - 1))
	_cast_cue.autowrap_mode = TextServer.AUTOWRAP_OFF
	_cast_cue.add_theme_color_override("font_color", UIFx.GOLD_HI)
	_cast_cue.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_hint = _label(Vector2(cx + 10, cy + CARD.size.y - 18), Vector2(CARD.size.x - 20, UIFx.LINE - 1))
	_hint.text = tr("UI_HOLD_SKIP")
	_hint.autowrap_mode = TextServer.AUTOWRAP_OFF
	_hint.add_theme_color_override("font_color", HINT_COL)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hold_bar = ColorRect.new()
	_hold_bar.color = INK_HEAD
	_hold_bar.position = Vector2(cx + 10, cy + CARD.size.y - 6)
	_hold_bar.size = Vector2(0, 1)
	_hold_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_hold_bar)
	var ev := get_node("/root/Events")
	ev.glyph_learned.connect(_on_learned)
	ev.dialogue_requested.connect(func(_s, _l): _dialogue = true)
	ev.dialogue_finished.connect(_on_dialogue_finished)
	ev.spell_cast.connect(_on_cast)
	ev.practice_cast.connect(_on_cast)
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
	_wet = CastOverlay.brush_line(8.0, GOLD.darkened(0.55), false)   # wet edge under the brush stroke
	_card.add_child(_wet)
	_stroke = CastOverlay.brush_line(6.0, GOLD)
	_card.add_child(_stroke)
	_hint_w = UIFx.text(_write_cue_text(), "body", UIFx.HEAD)
	_hint_w.position = Vector2(0, 220)
	_hint_w.size = Vector2(480, UIFx.LINE - 1)
	_hint_w.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_card.add_child(_hint_w)
	_write_mouse_atlas = AtlasTexture.new()
	if ResourceLoader.exists("res://assets/art/ui/tut_mouse_lmb.png"):
		_write_mouse_atlas.atlas = load("res://assets/art/ui/tut_mouse_lmb.png")
	_write_mouse_atlas.region = Rect2(0, 0, 12, 16)
	_write_mouse = TextureRect.new()
	_write_mouse.texture = _write_mouse_atlas
	_write_mouse.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_write_mouse.position = Vector2(234, 200)
	_write_mouse.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(_write_mouse)
	_set_cast_cue()


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
	var g_node := get_node_or_null("/root/Game")
	if id == "sunda_ka" and g_node != null and g_node.check("step:mq0=10") and (GameSettings.skip_tutorials() or g_node.has_flag("skip_semar_drill")):
		return
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
	var g_node := get_node("/root/Game")
	_sakti_handoff = id == "sunda_ka" and g_node.check("step:mq0=10") and not GameSettings.skip_tutorials() and not g_node.has_flag("tut_cast")
	_target_count = 2 if _sakti_handoff else NEEDED
	var up := id.to_upper()
	_name.text = "%s · %s" % [g.latin.capitalize(), _t(spell.title)]
	_aksara.text = CHARS.get(id, g.latin)
	_font(_aksara, g)
	_body.text = _t("CODEX_%s_BODY" % up)
	_tip.text = _t("LESSON_%s" % up)
	_fit()
	_set_cast_cue()
	_msg.text = ""
	_set_progress(1.0, false)
	var player := get_tree().get_first_node_in_group("player")
	_cast = player.get("cast") if player else null
	if _cast:
		_prev_practice = _cast.practice
		_cast.practice = true
		if _sakti_handoff and "practice_only_signal" in _cast:
			_cast.practice_only_signal = true
	_guide.visible = true
	_guide.show_guide(g.templates[0], GUIDE_RECT)
	_panel.visible = true


func _t(key: String) -> String:
	return get_node("/root/Game").fmt(tr(key))


## "Hold" / "Click" beside the mouse icon (RMB/LMB), or beside a keycap when the cast key is on the keyboard.
func _set_cast_cue() -> void:
	var k: String = get_node("/root/Game").key_name("cast")
	var mouse := k == tr("UI_KEY_RMB") or k == tr("UI_KEY_LMB")
	var verb := tr("UI_TOGGLE_KEY" if GameSettings.toggle_cast() else "UI_HOLD_KEY") % ""
	_cast_cue.text = verb.replace("[", "").replace("]", "").strip_edges()
	_cast_mouse.visible = mouse
	if _cast_keycap != null:
		_cast_keycap.queue_free()
		_cast_keycap = null
	var x := CARD.position.x + 10.0
	if mouse:
		var tex := "res://assets/art/ui/tut_mouse_%s.png" % ("lmb" if k == tr("UI_KEY_LMB") else "rmb")
		if ResourceLoader.exists(tex):
			_cast_mouse_atlas.atlas = load(tex)
		x += 12.0 + UIFx.GAP
	else:
		_cast_keycap = MenuBook.keycap(k)
		_cast_keycap.position = Vector2(x, _row_y + 1.0)
		_panel.add_child(_cast_keycap)
		x += _cast_keycap.size.x + UIFx.GAP
	_cast_cue.position.x = x


## Long stroke tips (id runs to 5 lines) push the cue row, skip hint and hold bar down instead of under the text.
func _fit() -> void:
	_tip.size.y = UIFx.LINE - 1
	var n := maxi(_tip.get_line_count(), 3)
	_tip.size.y = n * UIFx.LINE - 1
	_row_y = _tip.position.y + _tip.size.y + UIFx.GAP_S   # cue row: 16 px (the mouse icon), its own space under the text
	_hint.position.y = _row_y + 2.0   # right end of the cue row: icon + verb left, "Hold to skip" right
	_hold_bar.position.y = _row_y + 16.0 + 2.0
	_h = _hold_bar.position.y + 1.0 + 6.0 - CARD.position.y
	_bg.size.y = _h
	_cast_mouse.position.y = _row_y
	_cast_cue.position.y = _row_y + 2.0   # 13 px label centred on the 16 px row
	if _cast_keycap != null:
		_cast_keycap.position.y = _row_y + 1.0


func _write_cue_text() -> String:
	return tr("UI_WRITE_HINT")   # the animated LMB icon above it says "hold"


## The aksara system font on a label, or the Latin fallback text when it is missing.
func _font(l: Label, g: GlyphData) -> void:
	var path: String = JAWA if g.aksara == "jawa" else SUNDA
	if CHARS.has(g.id) and ResourceLoader.exists(path):
		l.add_theme_font_override("font", load(path))
	else:
		l.remove_theme_font_override("font")


func _set_progress(power: float, shown := true) -> void:
	_progress.text = "%d / %d" % [count, _target_count] + ("  %d%%" % roundi(power * 100.0) if shown and count > 0 else "")
	for i in _pips.size():
		_pips[i].visible = i < _target_count
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
	if count >= _target_count:
		finish()


func finish() -> void:
	if active == "":
		return
	var handoff := _sakti_handoff
	_sakti_handoff = false
	active = ""
	if is_instance_valid(_cast) and "practice_only_signal" in _cast:
		_cast.practice_only_signal = false
	# Only undo our own switch: the sanggar (desa_purwa.gd) may have changed practice since, so never set it back to true.
	if is_instance_valid(_cast) and not _prev_practice:
		_cast.practice = false
	_cast = null
	_guide.hide_guide()
	_guide.visible = false
	_panel.visible = false
	if handoff:
		var ev := get_node_or_null("/root/Events")
		if ev:
			ev.lesson_offered.emit("cast")
	_next.call_deferred()


func _process(delta: float) -> void:
	var frame := 1 if int(Time.get_ticks_msec() / 420) % 2 == 1 else 0
	if _panel.visible and _cast_mouse_atlas.atlas != null:
		_cast_mouse_atlas.region = Rect2(frame * 12, 0, 12, 16)
	if _card.visible and _write_mouse_atlas.atlas != null:
		_write_mouse_atlas.region = Rect2(frame * 12, 0, 12, 16)
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
	_hint_w.text = _write_cue_text()
	var lx := (480.0 - _seq.size() * SLOT.x) / 2.0 - 26.0
	_leaf.position = Vector2(lx, 58)
	_leaf.size = Vector2(_seq.size() * SLOT.x + 52.0, 124)
	_lamp.position = Vector2(lx - 36.0, 120)
	for c in _card.get_children():
		if c is Label and c.has_meta("written"):
			c.queue_free()
	_stroke.clear_points()
	_wet.clear_points()
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
	_wet.clear_points()
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
			_wet.points = _wpts
		elif _wdraw:
			_wdraw = false
			write_attempt(_wpts)   # a miss just clears it
			_stroke.clear_points()
			_wet.clear_points()
	elif e is InputEventMouseMotion and _wdraw:
		_wpts.append(e.position)
		_stroke.add_point(e.position)
		_wet.add_point(e.position)
