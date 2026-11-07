extends Control
## Name and pronoun screen between New Game and the prologue (ui.md 3). Keyboard only works: type, Enter;
## Down reaches the pronoun row (Left/Right pick, focus selects) and the confirm button.
## Stores Game.hero_name / hero_pronoun; the name is sanitized as typed and again on confirm.

const NEXT := "res://ui/prologue.tscn"
const PRONOUNS := ["he", "she", "they"]

var pronoun := "they"
var _edit: LineEdit
var _buttons := {}
var _rule: ColorRect
var _spark: ColorRect
var _fade: ColorRect
var _t := 0.0


func _ready() -> void:
	var sky := UIFx.rect_tex("title_sky", Vector2.ZERO)
	sky.modulate = Color(0.4, 0.4, 0.45)
	add_child(sky)
	add_child(UIFx.rect_tex("vignette", Vector2.ZERO))
	var card := UIFx.frame(Vector2(120, 52), Vector2(240, 166))
	add_child(card)
	var title := UIFx.label("UI_NAME_PROMPT", 10, UIFx.GOLD_HI, true)
	title.position = Vector2(0, 16)
	title.size = Vector2(240, 14)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(title)
	var d := UIFx.rect_tex("divider", Vector2(88, 32))
	card.add_child(d)

	_edit = LineEdit.new()
	_edit.max_length = 12
	_edit.text = get_node("/root/Game").DEFAULT_NAME
	_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_edit.position = Vector2(50, 44)
	_edit.size = Vector2(140, 20)
	_edit.add_theme_font_override("font", UIFx.cinzel())
	_edit.add_theme_font_size_override("font_size", 10)
	_edit.add_theme_color_override("font_color", UIFx.CREAM)
	_edit.add_theme_color_override("selection_color", Color(UIFx.GOLD, 0.35))
	_edit.add_theme_color_override("caret_color", UIFx.GOLD_HI)
	for s in ["normal", "focus"]:
		var e := StyleBoxEmpty.new()
		e.content_margin_left = 4.0
		e.content_margin_right = 4.0
		_edit.add_theme_stylebox_override(s, e)
	_edit.text_changed.connect(_on_changed)
	_edit.text_submitted.connect(func(_s: String) -> void: confirm())
	card.add_child(_edit)
	_rule = ColorRect.new()   # the underline: dim gold, breathing, with a bright spark that sweeps along it
	_rule.position = Vector2(50, 65)
	_rule.size = Vector2(140, 1)
	_rule.color = UIFx.GOLD
	_rule.mouse_filter = MOUSE_FILTER_IGNORE
	card.add_child(_rule)
	_spark = ColorRect.new()
	_spark.size = Vector2(14, 1)
	_spark.color = UIFx.GOLD_HI
	_spark.position = Vector2(50, 65)
	_spark.mouse_filter = MOUSE_FILTER_IGNORE
	card.add_child(_spark)

	var pl := UIFx.label("UI_PRONOUN_PROMPT", 8, UIFx.DIM)
	pl.position = Vector2(0, 82)
	pl.size = Vector2(240, 12)
	pl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(pl)
	var row := HBoxContainer.new()
	row.position = Vector2(26, 98)
	row.size = Vector2(188, 20)
	row.add_theme_constant_override("separation", 4)
	card.add_child(row)
	var grp := ButtonGroup.new()
	for p: String in PRONOUNS:
		var b := Button.new()
		b.text = "UI_PRONOUN_" + p.to_upper()
		b.toggle_mode = true
		b.button_group = grp
		b.custom_minimum_size = Vector2(58, 20)
		b.button_pressed = p == pronoun
		_style_toggle(b)
		b.focus_entered.connect(func() -> void: b.button_pressed = true; pronoun = p)   # focus selects
		b.pressed.connect(func() -> void: pronoun = p)
		row.add_child(b)
		_buttons[p] = b
	var ok := LozengeButton.new("UI_NAME_OK")
	ok.alignment = HORIZONTAL_ALIGNMENT_CENTER
	ok.position = Vector2(80, 134)
	ok.size = Vector2(80, 20)
	ok.pressed.connect(confirm)
	card.add_child(ok)
	_edit.grab_focus()
	_edit.select_all()
	_fade = UIFx.cover(self)
	_fade.color.a = 1.0
	create_tween().tween_property(_fade, "color:a", 0.0, 0.3)
	UIFx.rise_in(card, 6.0, 0.25)


## Styled toggle: dark well when off, gold-lit frame when on (the focused one is the chosen one).
func _style_toggle(b: Button) -> void:
	b.add_theme_font_override("font", UIFx.cinzel())
	b.add_theme_font_size_override("font_size", 8)
	b.add_theme_color_override("font_color", UIFx.DIM)
	for c in ["font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(c, UIFx.GOLD_HI)
	b.add_theme_stylebox_override("normal", UIFx.box("button_disabled", 5.0))
	b.add_theme_stylebox_override("hover", UIFx.box("button_normal", 5.0))
	b.add_theme_stylebox_override("pressed", UIFx.box("button_hover", 5.0))
	b.add_theme_stylebox_override("hover_pressed", UIFx.box("button_hover", 5.0))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _process(delta: float) -> void:
	_t += delta
	_rule.modulate.a = 0.55 + 0.25 * sin(_t * 3.0)
	var on := _edit.has_focus()
	_spark.visible = on
	if on:
		var x := 50.0 + fposmod(_t * 70.0, 154.0) - 14.0
		var l := maxf(x, 50.0)
		_spark.position.x = l
		_spark.size.x = maxf(minf(x + 14.0, 190.0) - l, 0.0)


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
