class_name Interactable extends Area2D
## Base for NPC, chest, pickup (layer 6). Shows a prompt while the player is in range; only the
## nearest overlapping interactable reacts to `interact`. Subclasses override interact().

var usable := true   # false hides the prompt and ignores input
var _near := false
var _prompt: Label


func _ready() -> void:
	add_to_group("interactable")
	_prompt = Label.new()
	_prompt.text = "[E]"
	_prompt.position = Vector2(-10, -30)
	_prompt.visible = false
	add_child(_prompt)
	body_entered.connect(func(b: Node) -> void: _set_near(b, true))
	body_exited.connect(func(b: Node) -> void: _set_near(b, false))


func _set_near(b: Node, on: bool) -> void:
	if b.is_in_group("player"):
		_near = on
		_refresh_prompt()


func _refresh_prompt() -> void:
	_prompt.visible = _near and usable


func _unhandled_input(event: InputEvent) -> void:
	if _near and usable and event.is_action_pressed("interact") and _is_nearest():
		get_viewport().set_input_as_handled()
		interact()


func _is_nearest() -> bool:
	var pl := get_tree().get_first_node_in_group("player") as Node2D
	if pl == null:
		return false
	for o: Interactable in get_tree().get_nodes_in_group("interactable"):
		if o != self and o._near and o.usable \
				and o.global_position.distance_to(pl.global_position) < global_position.distance_to(pl.global_position):
			return false
	return true


func interact() -> void:
	pass
