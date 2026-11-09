class_name LozengeButton extends Button
## Frameless menu entry: a diamond cursor on hover or focus and a 3 px indent, nothing else (ui.md 4: one cursor
## language, no shimmer). size >= 10 is a menu entry in the heading face (Jersey 10 at 19), smaller is body text.
## Hovering takes focus, so mouse, keyboard and gamepad share one cursor.

var _indent := 0.0
var _shim := -1.0
var _tw: Tween


var _paper := false   # v2 paper flag, kept for callers; v3 draws both the same (dusk text, cyan focus)


func _init(label := "", size := 10, paper := false) -> void:
	_paper = paper
	text = label
	flat = true
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	custom_minimum_size.y = 18 if size >= 10 else 12
	add_theme_font_override("font", UIFx.head_font() if size >= 10 else UIFx.body_font())
	add_theme_font_size_override("font_size", UIFx.HEAD_SIZE if size >= 10 else UIFx.BODY)
	add_theme_color_override("font_color", UIFx.TEXT)
	for c in ["font_hover_color", "font_focus_color", "font_pressed_color", "font_hover_pressed_color"]:
		add_theme_color_override(c, UIFx.ACCENT)   # v3: focus is the cyan glyph glow, paper or not
	add_theme_color_override("font_outline_color", UIFx.LACQUER)
	add_theme_constant_override("outline_size", 1)   # v3: every surface is dark, text keeps its 1 px outline
	for s in ["normal", "hover", "pressed", "focus", "hover_pressed", "disabled"]:
		add_theme_stylebox_override(s, _margin(0.0))


func _ready() -> void:
	mouse_entered.connect(func() -> void: grab_focus())
	focus_entered.connect(_on)
	focus_exited.connect(_off)


func _margin(extra: float) -> StyleBoxEmpty:
	var s := StyleBoxEmpty.new()
	s.content_margin_left = 11.0 + extra
	s.content_margin_right = 4.0
	return s


func _set_indent(v: float) -> void:
	_indent = v
	for s in ["normal", "hover", "pressed", "focus", "hover_pressed"]:
		add_theme_stylebox_override(s, _margin(v))
	queue_redraw()


func _set_shim(v: float) -> void:
	_shim = v
	queue_redraw()


func _on() -> void:
	if _tw:
		_tw.kill()
	_tw = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tw.tween_method(_set_indent, _indent, 3.0, 0.12)
	queue_redraw()


func _off() -> void:
	if _tw:
		_tw.kill()
	_tw = create_tween()
	_tw.tween_method(_set_indent, _indent, 0.0, 0.12)
	_set_shim(-1.0)


func _draw() -> void:
	if has_focus() or is_hovered():
		draw_texture(UIFx.tex("ink_cursor"), Vector2(roundf(1 + _indent), floorf((size.y - 5.0) / 2.0)))
