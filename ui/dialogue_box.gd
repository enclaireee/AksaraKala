extends Control
## Dialogue box (ui.md 2, quests.md 7.7). Listens to Events.dialogue_requested(speaker_key, lines),
## types each line out, `interact`, Enter or left click completes the line or advances, then emits dialogue_finished.
## Pauses the tree while open and restores the previous pause state.
## A line "@KEY" is not shown: it sets the speaker tag for the lines after it. Events.dialogue_choices (sent just
## before the request) lists 2-3 choices under the last line: move_up/move_down move, interact picks, cancel does
## nothing; Events.dialogue_picked(index) then dialogue_finished. All text goes through tr() then Game.fmt().

const CPS := 45.0   # TUNE: characters per second
const OUTLINE := Color("0E0B0A")
const UI_DIR := "res://assets/art/ui/"
const BOX := Rect2(32, 180, 416, 86)
const NARRATION := Color("F2E6C4")   # Semar (Dalang): italic, pale cream (ui.md 3)

var _lines := PackedStringArray()
var _i := 0
var _shown := 0.0
var _was_paused := false
var _opened_frame := -1
var _open := false
var _speaker: Label
var _text: Label
var _cue: TextureRect   # gold ▼ once the line is fully shown
var _plate: NinePatchRect   # gold name plate over the top edge
var _sel_bar: ColorRect
var _lozenge: TextureRect
var _tween: Tween
var _choices := PackedStringArray()   # for the next request
var _opts := PackedStringArray()      # for the open box
var _choosing := false
var _sel := 0
var _list: Label
var _who: Label   # name tag (ui.md 3)
var _fresh := {}   # npc ids whose tag is up for this first talk


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	add_to_group("dialogue_box")
	var frame := _nine("panel_dialogue", BOX, 8)
	_plate = _nine("button_normal", Rect2(46, 172, 60, 14), 5)
	_speaker = Label.new()
	_speaker.theme_type_variation = &"Heading"
	_speaker.position = Vector2(7, 1)
	_speaker.size = Vector2(160, 12)
	_speaker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_plate.add_child(_speaker)
	_who = _label(Vector2(44, 189), Vector2(396, 10), Color("BDB59A"))
	_who.add_theme_font_size_override("font_size", 7)
	_text = _label(Vector2(44, 190), Vector2(392, 44), Color.TRANSPARENT)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sel_bar = ColorRect.new()
	_sel_bar.color = Color(0.122, 0.165, 0.267, 0.8)   # indigo selection (ui.md 3b)
	_sel_bar.size = Vector2(380, 10)
	_sel_bar.visible = false
	_sel_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sel_bar)
	_lozenge = TextureRect.new()
	_lozenge.texture = load(UI_DIR + "lozenge.png")
	_lozenge.visible = false
	_lozenge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_lozenge)
	_list = _label(Vector2(62, 232), Vector2(372, 32), Color.TRANSPARENT)
	_cue = TextureRect.new()
	_cue.texture = load(UI_DIR + "continue_arrow.png")
	_cue.position = Vector2(433, 254)
	_cue.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cue)
	frame.z_index = -1
	var ev := get_node("/root/Events")
	ev.dialogue_requested.connect(_on_requested)
	ev.dialogue_choices.connect(func(keys: PackedStringArray) -> void: _choices = keys)


func _nine(tex: String, rect: Rect2, m: int) -> NinePatchRect:
	var r := NinePatchRect.new()
	r.texture = load(UI_DIR + tex + ".png")
	r.position = rect.position
	r.size = rect.size
	r.patch_margin_left = m
	r.patch_margin_top = m
	r.patch_margin_right = m
	r.patch_margin_bottom = m
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	return r


func _label(pos: Vector2, sz: Vector2, col: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.size = sz
	if col.a > 0.0:
		l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l


func is_open() -> bool:
	return _open


func _on_requested(speaker_key: String, lines: PackedStringArray) -> void:
	if _open:
		_choices = PackedStringArray()
		return
	if lines.is_empty() and _choices.is_empty():
		get_node("/root/Events").dialogue_finished.emit()
		return
	_open = true
	_lines = lines
	_opts = _choices
	_choices = PackedStringArray()
	_choosing = false
	_list.text = ""
	_text.text = ""
	_sel_bar.visible = false
	_lozenge.visible = false
	_i = -1
	_opened_frame = Engine.get_process_frames()
	_was_paused = get_tree().paused
	get_tree().paused = true
	_fresh.clear()
	_set_speaker(speaker_key)
	visible = true
	_animate_open()
	_next()


## Slide up 8 px and fade in; the name plate pops (ui.md 3b).
func _animate_open() -> void:
	if _tween:
		_tween.kill()
	modulate.a = 0.0
	position.y = 8.0
	_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true)
	_tween.tween_property(self, "modulate:a", 1.0, 0.2)
	_tween.tween_property(self, "position:y", 0.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_pop_plate()


func _pop_plate() -> void:
	_plate.pivot_offset = _plate.size / 2.0
	_plate.scale = Vector2(0.8, 0.8)
	create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(_plate, "scale", Vector2.ONE, 0.15) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Sets the name and, for a named NPC (key NPC_<ID>_NAME) with a NPC_<ID>_WHO text, the tag; flag seen_name_<id> on first sight.
func _set_speaker(key: String) -> void:
	var prev := _speaker.text
	_speaker.text = _t(key)
	_plate.visible = _speaker.text != ""
	_plate.size.x = ceilf(_speaker.get_minimum_size().x) + 14.0
	if _open and _speaker.text != prev:
		_pop_plate()
	var narr := key.contains("DALANG") or _speaker.text.to_lower().contains("(dalang)")
	_text.theme_type_variation = &"Italic" if narr else &""
	_who.text = ""
	_text.position.y = 190
	if not (key.begins_with("NPC_") and key.ends_with("_NAME")):
		return
	var nid := key.trim_prefix("NPC_").trim_suffix("_NAME").to_lower()
	var wk := "NPC_%s_WHO" % nid.to_upper()
	if tr(wk) == wk:
		return
	var g := get_node("/root/Game")
	if g.has_flag("seen_name_" + nid) and not _fresh.has(nid):
		return
	_fresh[nid] = true
	g.set_flag("seen_name_" + nid)
	_who.text = _t(wk)
	_text.position.y = 200   # TUNE: body moves down under the tag


func _t(key: String) -> String:
	return get_node("/root/Game").fmt(tr(key))


func _next() -> void:
	_i += 1
	while _i < _lines.size() and _lines[_i].begins_with("@"):
		_set_speaker(_lines[_i].substr(1))
		_i += 1
	if _i >= _lines.size():
		if _opts.is_empty():
			_close()
		else:
			_choosing = true
			_sel = 0
			_show_choices()
		return
	_text.text = _t(_lines[_i])
	_text.visible_characters = 0
	_shown = 0.0


func _show_choices() -> void:
	var out := PackedStringArray()
	for i in _opts.size():
		out.append(_t(_opts[i]))
	_list.text = "\n".join(out)
	var lh := _list.get_line_height() + 1.0   # theme line_spacing 1
	_list.position.y = 262.0 - _opts.size() * lh
	_sel_bar.size.y = lh
	_sel_bar.position = Vector2(48, _list.position.y + _sel * lh)
	_lozenge.position = Vector2(52, _sel_bar.position.y + roundf((lh - 5.0) / 2.0))
	_sel_bar.visible = true
	_lozenge.visible = true


func _close() -> void:
	_list.text = ""
	_sel_bar.visible = false
	_lozenge.visible = false
	_open = false
	visible = false
	get_tree().paused = _was_paused
	get_node("/root/Events").dialogue_finished.emit()


func _process(delta: float) -> void:
	if _open and _text.visible_characters < _text.get_total_character_count():
		_shown += delta * CPS
		_text.visible_characters = int(_shown)
	_cue.visible = _open and not _choosing and _text.visible_characters >= _text.get_total_character_count() \
			and Time.get_ticks_msec() % 800 < 500
	_cue.position.y = 254.0 + (1.0 if Time.get_ticks_msec() % 800 < 250 else 0.0)


func _unhandled_input(event: InputEvent) -> void:
	# the press that opened the box arrives in the same frame: not an advance
	if not _open or Engine.get_process_frames() == _opened_frame:
		return
	if _choosing:
		var d := int(event.is_action_pressed("move_down") or event.is_action_pressed("ui_down")) \
				- int(event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"))
		if d != 0:
			get_viewport().set_input_as_handled()
			_sel = posmod(_sel + d, _opts.size())
			_show_choices()
		elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
			get_viewport().set_input_as_handled()
			get_node("/root/Events").dialogue_picked.emit(_sel)
			_close()
		return
	if not (event.is_action_pressed("interact") or event.is_action_pressed("ui_accept") or event.is_action_pressed("attack")):
		return
	get_viewport().set_input_as_handled()
	if _text.visible_characters < _text.get_total_character_count():
		_text.visible_characters = _text.get_total_character_count()
	else:
		_next()
