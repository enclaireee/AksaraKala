extends Control
## Death: fade to dark, "UI_FALLEN" ink-bleeds in (vermillion Cinzel), a tip line, then respawn (rpg.md 7).

var _dim: ColorRect
var _text: Label
var _sub: Label


func _ready() -> void:
	visible = false
	_dim = ColorRect.new()
	_dim.color = Color(0, 0, 0, 0)
	_dim.set_anchors_preset(PRESET_FULL_RECT)
	_dim.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_dim)
	var l := UIFx.label("UI_FALLEN", 28, UIFx.VERMILLION, true)
	l.name = "Text"
	l.add_theme_constant_override("outline_size", 3)
	l.position = Vector2(0, 100)
	l.size = Vector2(480, 40)
	l.pivot_offset = Vector2(240, 20)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.modulate.a = 0.0
	_dim.add_child(l)
	_text = l
	var sub := UIFx.label("UI_DEATH_SUB", 8, UIFx.DIM)
	sub.name = "Sub"
	sub.position = Vector2(0, 150)
	sub.size = Vector2(480, 12)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.modulate.a = 0.0
	_dim.add_child(sub)
	_sub = sub
	get_node("/root/Events").player_died.connect(_on_died)


func _on_died() -> void:
	visible = true
	_text.modulate.a = 0.0
	_text.scale = Vector2(1.18, 1.18)
	_sub.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_dim, "color:a", 0.95, 0.6)
	# ink bleed: the word swells out of the dark, settling to size as it fills
	tw.tween_property(_text, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_text, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(_sub, "modulate:a", 1.0, 0.2)
	tw.tween_interval(1.4)
	tw.tween_callback(func() -> void: get_node("/root/Zones").respawn())
