extends Control
## Dialogue box (ui.md 2, quests.md 7.7). Listens to Events.dialogue_requested(speaker_key, lines),
## types each line out, `interact`, Enter or left click completes the line or advances, then emits dialogue_finished.
## Pauses the tree while open and restores the previous pause state.
## A line "@KEY" is not shown: it sets the speaker tag for the lines after it. Events.dialogue_choices (sent just
## before the request) lists 2-3 choices under the last line: move_up/move_down move, interact picks, cancel does
## nothing; Events.dialogue_picked(index) then dialogue_finished. All text goes through tr() then Game.fmt().

const CPS := 45.0   # TUNE: characters per second
const OUTLINE := Color(0, 0, 0, 0.9)

var _lines := PackedStringArray()
var _i := 0
var _shown := 0.0
var _was_paused := false
var _opened_frame := -1
var _open := false
var _speaker: Label
var _text: Label
var _cue: Label   # "▼" once the line is fully shown
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
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.82)
	bg.position = Vector2(32, 180)
	bg.size = Vector2(416, 86)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_speaker = _label(Vector2(42, 184), Vector2(396, 12), Color("E8D9A0"))
	_who = _label(Vector2(42, 193), Vector2(396, 10), Color("BDB59A"))
	_who.add_theme_font_size_override("font_size", 7)
	_text = _label(Vector2(42, 198), Vector2(396, 56), Color.WHITE)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_cue = _label(Vector2(434, 252), Vector2(10, 10), Color("E8D9A0"))
	_cue.text = "▼"
	_list = _label(Vector2(50, 232), Vector2(388, 32), Color.WHITE)
	var ev := get_node("/root/Events")
	ev.dialogue_requested.connect(_on_requested)
	ev.dialogue_choices.connect(func(keys: PackedStringArray) -> void: _choices = keys)


func _label(pos: Vector2, sz: Vector2, col: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.size = sz
	l.add_theme_font_size_override("font_size", 8)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", OUTLINE)
	l.add_theme_constant_override("outline_size", 1)
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
	_i = -1
	_opened_frame = Engine.get_process_frames()
	_was_paused = get_tree().paused
	get_tree().paused = true
	_fresh.clear()
	_set_speaker(speaker_key)
	visible = true
	_next()


## Sets the name and, for a named NPC (key NPC_<ID>_NAME) with a NPC_<ID>_WHO text, the tag; flag seen_name_<id> on first sight.
func _set_speaker(key: String) -> void:
	_speaker.text = _t(key)
	_who.text = ""
	_text.position.y = 198
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
	_text.position.y = 202   # TUNE: body moves down 4 px under the tag


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
		out.append(("▶ " if i == _sel else "   ") + _t(_opts[i]))
	_list.text = "\n".join(out)


func _close() -> void:
	_list.text = ""
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
