extends Control
## Dialogue box (ui.md 2, quests.md 7.7). Listens to Events.dialogue_requested(speaker_key, lines),
## types each line out, `interact` completes the line or advances, then emits dialogue_finished.
## Pauses the tree while open and restores the previous pause state.

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


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.75)
	bg.position = Vector2(40, 194)
	bg.size = Vector2(400, 70)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_speaker = _label(Vector2(48, 198), Vector2(384, 12), Color("E8D9A0"))
	_text = _label(Vector2(48, 212), Vector2(384, 48), Color.WHITE)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	get_node("/root/Events").dialogue_requested.connect(_on_requested)


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
		return
	if lines.is_empty():
		get_node("/root/Events").dialogue_finished.emit()
		return
	_open = true
	_lines = lines
	_i = -1
	_opened_frame = Engine.get_process_frames()
	_was_paused = get_tree().paused
	get_tree().paused = true
	_speaker.text = tr(speaker_key)
	visible = true
	_next()


func _next() -> void:
	_i += 1
	if _i >= _lines.size():
		_close()
		return
	_text.text = tr(_lines[_i])
	_text.visible_characters = 0
	_shown = 0.0


func _close() -> void:
	_open = false
	visible = false
	get_tree().paused = _was_paused
	get_node("/root/Events").dialogue_finished.emit()


func _process(delta: float) -> void:
	if _open and _text.visible_characters < _text.get_total_character_count():
		_shown += delta * CPS
		_text.visible_characters = int(_shown)


func _unhandled_input(event: InputEvent) -> void:
	# the press that opened the box arrives in the same frame: not an advance
	if not _open or Engine.get_process_frames() == _opened_frame or not event.is_action_pressed("interact"):
		return
	get_viewport().set_input_as_handled()
	if _text.visible_characters < _text.get_total_character_count():
		_text.visible_characters = _text.get_total_character_count()
	else:
		_next()
