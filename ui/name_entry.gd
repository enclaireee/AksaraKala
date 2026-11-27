extends Control
## Name entry screen between New Game and the prologue (ui.md 3). Keyboard only works: type, Enter, Esc back to Title.
## Down reaches the confirm / back row. Stores Game.hero_name; the name is sanitized as typed and again on confirm.

const NEXT := "res://ui/prologue.tscn"

var _edit: LineEdit
var _rule: ColorRect
var _fade: ColorRect
var _leaving := false


func _ready() -> void:
	Snd.music("select", 2.0)
	UIFx.sky(self, 0.55)
	add_child(UIFx.rect_tex("vignette", Vector2.ZERO))
	var card := Panel.new()   # ink card (ui.md 0), the same surface as class select and the dialogue box
	card.add_theme_stylebox_override("panel", UIFx.ink_box())
	card.position = Vector2(120, 94)
	card.size = Vector2(240, 82)
	card.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(card)
	var title := UIFx.text("UI_NAME_PROMPT", "label", UIFx.LABEL_COL)
	title.position = Vector2(0, 10)
	title.size = Vector2(240, 12)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(title)

	_edit = LineEdit.new()
	_edit.max_length = 12
	_edit.text = get_node("/root/Game").DEFAULT_NAME
	_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_edit.position = Vector2(40, 24)
	_edit.size = Vector2(160, 24)
	_edit.add_theme_font_override("font", UIFx.display())
	_edit.add_theme_font_size_override("font_size", UIFx.DISPLAY)
	_edit.add_theme_color_override("font_color", UIFx.GOLD_HI)
	_edit.add_theme_color_override("selection_color", Color(UIFx.ACCENT, 0.25))
	_edit.add_theme_color_override("font_selected_color", UIFx.GOLD_HI)
	_edit.add_theme_color_override("caret_color", UIFx.ACCENT)
	for s in ["normal", "focus"]:
		var e := StyleBoxEmpty.new()
		e.content_margin_left = 4.0
		e.content_margin_right = 4.0
		e.content_margin_bottom = 8.0   # the display face's line box carries spare room below the glyphs
		_edit.add_theme_stylebox_override(s, e)
	_edit.text_changed.connect(_on_changed)
	_edit.text_submitted.connect(func(_s: String) -> void: confirm())
	card.add_child(_edit)
	_rule = ColorRect.new()
	_rule.position = Vector2(40, 45)
	_rule.size = Vector2(160, 1)
	_rule.color = UIFx.ACCENT
	_rule.mouse_filter = MOUSE_FILTER_IGNORE
	card.add_child(_rule)

	var row := HBoxContainer.new()
	row.position = Vector2(20, 54)
	row.size = Vector2(200, 18)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	card.add_child(row)
	var ok := LozengeButton.new("UI_NAME_OK", 10)
	ok.custom_minimum_size.x = 88
	ok.pressed.connect(confirm)
	row.add_child(ok)
	var back := LozengeButton.new("UI_BACK", 10)
	back.custom_minimum_size.x = 72
	back.pressed.connect(_back)
	row.add_child(back)
	var hints := HBoxContainer.new()   # footer: keycaps + lavender words
	hints.position = Vector2(0, 254)
	hints.size = Vector2(480, 12)
	hints.alignment = BoxContainer.ALIGNMENT_CENTER
	hints.add_theme_constant_override("separation", UIFx.GAP_S)
	add_child(hints)
	for h in [["Enter", "UI_NAME_OK"], ["Esc", "UI_BACK"]]:
		if hints.get_child_count() > 0:
			var sp := Control.new()
			sp.custom_minimum_size.x = UIFx.GAP_L - UIFx.GAP_S
			hints.add_child(sp)
		hints.add_child(MenuBook.keycap(h[0]))
		var hl := UIFx.text(tr(h[1]), "body", UIFx.LABEL_COL)
		hl.size_flags_vertical = Control.SIZE_SHRINK_END   # the cap face sits 1 px low in its 14 px box
		hints.add_child(hl)
	_edit.grab_focus()
	_edit.select_all()
	_fade = UIFx.cover(self)
	_fade.color.a = 1.0
	create_tween().tween_property(_fade, "color:a", 0.0, 0.3)
	UIFx.rise_in(card, 6.0, 0.25)


func _process(_delta: float) -> void:
	_rule.modulate.a = 0.65 if _edit.has_focus() else 0.3


## Drops disallowed characters as typed and keeps the caret in place.
func _on_changed(s: String) -> void:
	var clean: String = get_node("/root/Game").clean_name(s, false)
	if clean != s:
		var c := _edit.caret_column - (s.length() - clean.length())
		_edit.text = clean
		_edit.caret_column = clampi(c, 0, clean.length())


func confirm() -> void:
	if _leaving:
		return
	var g := get_node("/root/Game")
	g.hero_name = g.clean_name(_edit.text)
	get_tree().change_scene_to_file(NEXT)


func _back() -> void:
	if _leaving:
		return
	_leaving = true
	Snd.play("ui_back")
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 1.0, 0.25)
	tw.tween_callback(func() -> void: get_tree().change_scene_to_file("res://ui/title.tscn"))


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_back()
