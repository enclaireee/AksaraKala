extends Control
## Name entry screen between New Game and the prologue (ui.md 3). Keyboard only works: type, Enter.
## Down reaches the confirm button. Stores Game.hero_name; the name is sanitized as typed and again on confirm.

const NEXT := "res://ui/prologue.tscn"

var _edit: LineEdit
var _rule: ColorRect
var _spark: ColorRect
var _fade: ColorRect
var _t := 0.0


func _ready() -> void:
	Snd.music("select", 2.0)
	UIFx.sky(self, 0.55)
	add_child(UIFx.rect_tex("vignette", Vector2.ZERO))
	var card := Panel.new()   # ink card (ui.md 0), the same surface as class select and the dialogue box
	card.add_theme_stylebox_override("panel", UIFx.ink_box())
	card.position = Vector2(120, 80)
	card.size = Vector2(240, 108)
	card.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(card)
	var title := UIFx.text("UI_NAME_PROMPT", "label", UIFx.LABEL_COL)
	title.position = Vector2(0, 16)
	title.size = Vector2(240, 9)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(title)

	_edit = LineEdit.new()
	_edit.max_length = 12
	_edit.text = get_node("/root/Game").DEFAULT_NAME
	_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_edit.position = Vector2(50, 36)
	_edit.size = Vector2(140, 22)
	_edit.add_theme_font_override("font", UIFx.head_font())   # the name is the one big word on the card
	_edit.add_theme_font_size_override("font_size", UIFx.HEAD_SIZE)
	_edit.add_theme_color_override("font_color", UIFx.GOLD_HI)
	_edit.add_theme_color_override("selection_color", Color(UIFx.ACCENT, 0.25))
	_edit.add_theme_color_override("font_selected_color", UIFx.GOLD_HI)
	_edit.add_theme_color_override("caret_color", UIFx.ACCENT)
	for s in ["normal", "focus"]:
		var e := StyleBoxEmpty.new()
		e.content_margin_left = 4.0
		e.content_margin_right = 4.0
		_edit.add_theme_stylebox_override(s, e)
	_edit.text_changed.connect(_on_changed)
	_edit.text_submitted.connect(func(_s: String) -> void: confirm())
	card.add_child(_edit)
	_rule = ColorRect.new()   # the underline: dim gold, breathing, with a bright spark that sweeps along it
	_rule.position = Vector2(50, 60)
	_rule.size = Vector2(140, 1)
	_rule.color = UIFx.ACCENT
	_rule.mouse_filter = MOUSE_FILTER_IGNORE
	card.add_child(_rule)
	_spark = ColorRect.new()
	_spark.size = Vector2(14, 1)
	_spark.color = UIFx.GOLD_HI
	_spark.position = Vector2(50, 60)
	_spark.visible = false   # ui.md 0: no idle shimmer; the caret already shows focus
	_spark.mouse_filter = MOUSE_FILTER_IGNORE
	card.add_child(_spark)

	var ok := LozengeButton.new("UI_NAME_OK", 10)
	ok.alignment = HORIZONTAL_ALIGNMENT_CENTER
	ok.position = Vector2(70, 74)
	ok.size = Vector2(100, 18)
	ok.pressed.connect(confirm)
	card.add_child(ok)
	_edit.grab_focus()
	_edit.select_all()
	_fade = UIFx.cover(self)
	_fade.color.a = 1.0
	create_tween().tween_property(_fade, "color:a", 0.0, 0.3)
	UIFx.rise_in(card, 6.0, 0.25)


func _process(delta: float) -> void:
	_t += delta
	_rule.modulate.a = 0.6 if _edit.has_focus() else 0.3
	var on := false
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
	get_tree().change_scene_to_file(NEXT)
