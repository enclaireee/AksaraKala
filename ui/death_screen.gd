extends Control
## Death: fade to night, "UI_FALLEN" swells in (rose, the danger colour, display face), a tip line, then respawn (rpg.md 7).

var _dim: ColorRect
var _text: Label
var _sub: Label


func _ready() -> void:
	visible = false
	_dim = ColorRect.new()
	_dim.color = Color(0.03, 0.02, 0.07, 0)
	_dim.set_anchors_preset(PRESET_FULL_RECT)
	_dim.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_dim)
	var l := UIFx.text("UI_FALLEN", "display", UIFx.VERMILLION)
	l.name = "Text"
	l.position = Vector2(0, 100)
	l.size = Vector2(480, 32)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.modulate.a = 0.0
	_dim.add_child(l)
	_text = l
	var sub := UIFx.text("UI_DEATH_SUB", "body", UIFx.DIM)
	sub.name = "Sub"
	sub.position = Vector2(0, 144)
	sub.size = Vector2(480, UIFx.LINE - 1)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.modulate.a = 0.0
	_dim.add_child(sub)
	_sub = sub
	get_node("/root/Events").player_died.connect(_on_died)


func _on_died() -> void:
	visible = true
	_text.modulate.a = 0.0
	_text.position.y = 106.0
	_sub.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_dim, "color:a", 0.95, 0.6)
	tw.tween_property(_text, "modulate:a", 1.0, 0.35).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_text, "position:y", 100.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(_sub, "modulate:a", 1.0, 0.25)
	tw.tween_interval(1.4)
	tw.tween_callback(func() -> void: get_node("/root/Zones").respawn())
