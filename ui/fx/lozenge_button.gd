class_name LozengeButton extends Button
## Frameless menu entry: pixel-font text, a gold lozenge cursor on hover or focus, a slight indent and a 0.4 s
## shimmer sweep (ui.md 3b). Hovering takes focus, so mouse, keyboard and gamepad share one cursor.

var _indent := 0.0
var _shim := -1.0
var _tw: Tween


func _init(label := "", size := 10) -> void:
	text = label
	flat = true
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	custom_minimum_size.y = 18
	if size >= 10:
		add_theme_font_override("font", UIFx.cinzel())
	add_theme_font_size_override("font_size", size)
	add_theme_color_override("font_color", UIFx.CREAM)
	for c in ["font_hover_color", "font_focus_color", "font_pressed_color", "font_hover_pressed_color"]:
		add_theme_color_override(c, UIFx.GOLD_HI)
	add_theme_color_override("font_outline_color", UIFx.LACQUER)
	add_theme_constant_override("outline_size", 1)
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
	_set_shim(0.0)
	_tw.tween_method(_set_shim, 0.0, 1.0, 0.4)
	_tw.chain().tween_callback(_set_shim.bind(-1.0))
	queue_redraw()


func _off() -> void:
	if _tw:
		_tw.kill()
	_tw = create_tween()
	_tw.tween_method(_set_indent, _indent, 0.0, 0.12)
	_set_shim(-1.0)


func _draw() -> void:
	if has_focus() or is_hovered():
		draw_texture(UIFx.tex("lozenge"), Vector2(1 + _indent, floorf((size.y - 5.0) / 2.0)))
	if _shim >= 0.0:
		var x := floorf(lerpf(8.0, size.x, _shim))
		draw_rect(Rect2(x, 3, 1, size.y - 6), Color(UIFx.GOLD_HI, 0.8))
		draw_rect(Rect2(x - 3, 3, 3, size.y - 6), Color(UIFx.GOLD_HI, 0.15))
