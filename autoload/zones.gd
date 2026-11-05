extends Node
## Zone changes and respawn (architecture.md 3, rpg.md 7, 11). Position is never saved:
## the player always appears at the last petilasan, or where the zone places it if there is none.

const START_ZONE := "res://zones/hub.tscn"   # ASSUMED: test hub until Desa Purwa (Phase 4)


## After class choice. Game.new_game() has already saved.
func start_new_game() -> void:
	respawn()


## Title screen Continue. Game.load_game() has already run.
func continue_game() -> void:
	respawn()


## Death, rest, Continue and new game all land here: the zone reloads (normal enemies back,
## bosses stay dead through Game.killed), full HP and flask, player at the last petilasan.
## Death does not save; resting saved before calling this.
var _busy := false


func respawn(rested := false) -> void:
	if _busy:
		return   # death fade and a rest in the same frame: one reload only
	_busy = true
	var game := get_node("/root/Game")
	game.flask_charges = game.flask_max
	game.changed.emit()
	var zone: String = game.last_petilasan.get("zone", "")
	if zone == "" or not ResourceLoader.exists(zone):
		zone = START_ZONE
	var tree := get_tree()
	tree.paused = false
	Engine.time_scale = 1.0
	tree.change_scene_to_file(zone)
	await tree.scene_changed
	var p := _petilasan(game.last_petilasan.get("id", ""))
	var player := tree.get_first_node_in_group("player") as Node2D
	if p and player:
		player.global_position = p.global_position + Vector2(0, 20)   # ASSUMED: just below the shrine
		if player.has_method("reset_physics_interpolation"):
			player.reset_physics_interpolation()
	_busy = false
	if rested and p:
		get_node("/root/Events").rested.emit(p)


func _petilasan(id: String) -> Node2D:
	for p in get_tree().get_nodes_in_group("petilasan"):
		if p.id == id:
			return p
	return null
