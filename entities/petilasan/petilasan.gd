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
	if _art() != null:   # a drawn shrine replaces the placeholder polygons
		for n in ["Base", "Stone", "Flame"]:
			get_node(n).visible = false
		queue_redraw()


## Shrine sprite by region, picked from the zone scene name (tools/gen_story_props_late.py).
func _art() -> Texture2D:
	var zone := get_tree().current_scene.scene_file_path.get_file().get_basename()
	var region := "sunda"
	if zone.begins_with("kg_"):
		region = "galuh"
	elif zone.begins_with("mt_"):
		region = "mataram"
	elif zone.begins_with("sk_"):
		region = "kidul"
	elif zone.begins_with("tt_"):
		region = "timur"
	elif zone.begins_with("gk_"):
		region = "kala"
	return StoryArt.tex("petilasan_" + region)


func _draw() -> void:
	var art := _art() if is_inside_tree() else null
	if art != null:
		StoryArt.draw_standing(self, art, Vector2(0, 6))


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
	game.restore()   # flask now; HP and stamina also come back full when respawn reloads the zone
	game.save_game()
	get_node("/root/Events").petilasan_activated.emit(id)
	get_node("/root/Zones").respawn(true)
