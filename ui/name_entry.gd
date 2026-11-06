extends Control
## Name and pronoun screen between New Game and the prologue (ui.md 3). Keyboard only works: type, Enter;
## Down reaches the pronoun row (Left/Right pick, focus selects) and the confirm button.
## Stores Game.hero_name / hero_pronoun; the name is sanitized as typed and again on confirm.

const NEXT := "res://ui/prologue.tscn"
const PRONOUNS := ["he", "she", "they"]

var pronoun := "they"
var _edit: LineEdit
var _buttons := {}


func _ready() -> void:
	var t := Theme.new()
	t.default_font_size = 8
	theme = t
	var bg := ColorRect.new()
	bg.color = Color("14110f")
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(bg)
	_label("UI_NAME_PROMPT", 80)
	_edit = LineEdit.new()
	_edit.max_length = 12
	_edit.text = get_node("/root/Game").DEFAULT_NAME
	_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_edit.position = Vector2(170, 98)
	_edit.size = Vector2(140, 20)
	_edit.text_changed.connect(_on_changed)
	_edit.text_submitted.connect(func(_s: String) -> void: confirm())
	add_child(_edit)
	_label("UI_PRONOUN_PROMPT", 132)
	var row := HBoxContainer.new()
	row.position = Vector2(150, 146)
	row.size = Vector2(180, 18)
	add_child(row)
	var grp := ButtonGroup.new()
	for p: String in PRONOUNS:
		var b := Button.new()
		b.text = "UI_PRONOUN_" + p.to_upper()
		b.toggle_mode = true
		b.button_group = grp
		b.custom_minimum_size = Vector2(56, 18)
		b.button_pressed = p == pronoun
		b.focus_entered.connect(func() -> void: b.button_pressed = true; pronoun = p)   # focus selects
		b.pressed.connect(func() -> void: pronoun = p)
		row.add_child(b)
		_buttons[p] = b
	var ok := Button.new()
	ok.text = "UI_NAME_OK"
	ok.position = Vector2(200, 184)
	ok.size = Vector2(80, 18)
	ok.pressed.connect(confirm)
	add_child(ok)
	_edit.grab_focus()
	_edit.select_all()


func _label(key: String, y: float) -> void:
	var l := Label.new()
	l.text = key
	l.position = Vector2(0, y)
	l.size = Vector2(480, 12)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(l)


## Drops disallowed characters as typed and keeps the caret in place.
func _on_changed(s: String) -> void:
	var clean: String = get_node("/root/Game").clean_name(s, false)
	if clean != s:
		var c := _edit.caret_column - (s.length() - clean.length())
		_edit.text = clean
		_edit.caret_column = clampi(c, 0, clean.length())


func confirm() -> void:
	var g := get_node("/root/Game")
	g.hero_name = g.clean_name(_edit.text)
	g.hero_pronoun = pronoun
	get_tree().change_scene_to_file(NEXT)
