class_name Petilasan extends Area2D
## Checkpoint shrine (rpg.md 7). Interact: set respawn, save, then reload the zone (heals, refills
## the flask, respawns normal enemies) and open the menu with level-up enabled.

@export var id := "p1"   # unique within its zone

@onready var prompt: Label = $Prompt

var _near := false


func _ready() -> void:
	add_to_group("petilasan")
	body_entered.connect(func(b: Node) -> void: _set_near(b, true))
	body_exited.connect(func(b: Node) -> void: _set_near(b, false))
	prompt.visible = false


func _set_near(b: Node, on: bool) -> void:
	if b.is_in_group("player"):
		_near = on
		prompt.visible = on


func _unhandled_input(event: InputEvent) -> void:
	var pl := get_tree().get_first_node_in_group("player")
	if _near and event.is_action_pressed("interact") and pl and not pl.health.is_dead():
		get_viewport().set_input_as_handled()
		rest()


func rest() -> void:
	var game := get_node("/root/Game")
	game.last_petilasan = {"zone": get_tree().current_scene.scene_file_path, "id": id}
	game.flask_charges = game.flask_max
	game.save_game()
	get_node("/root/Events").petilasan_activated.emit(id)
	get_node("/root/Zones").respawn(true)
