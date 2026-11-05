extends Control
## Death: fade to dark, "Gugur / Fallen", then respawn (rpg.md 7).

var _dim: ColorRect


func _ready() -> void:
	visible = false
	_dim = ColorRect.new()
	_dim.color = Color(0, 0, 0, 0)
	_dim.set_anchors_preset(PRESET_FULL_RECT)
	_dim.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_dim)
	var l := Label.new()
	l.name = "Text"
	l.text = "Gugur / Fallen"
	l.set_anchors_preset(PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.modulate.a = 0.0
	_dim.add_child(l)
	get_node("/root/Events").player_died.connect(_on_died)


func _on_died() -> void:
	visible = true
	var tw := create_tween()
	tw.tween_property(_dim, "color:a", 0.95, 0.6)
	tw.tween_property(_dim.get_node("Text"), "modulate:a", 1.0, 0.2)
	tw.tween_interval(1.5)
	tw.tween_callback(func() -> void: get_node("/root/Zones").respawn())
