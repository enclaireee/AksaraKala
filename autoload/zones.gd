extends Node
## Zone changes and respawn (architecture.md 3, 9, rpg.md 7, 11). Position is never saved:
## the player always appears at the last petilasan, or where the zone places it if there is none.

var start_zone := "res://zones/desa_purwa.tscn"   # var so loop_test can start in the hub
const FADE := 0.25   # TUNE: seconds each way
const ZONES := {
	"hub": "res://zones/hub.tscn",
	"desa_purwa": "res://zones/desa_purwa.tscn",
	"ts_kebun": "res://zones/ts_kebun.tscn",
	"ts_kampung": "res://zones/ts_kampung.tscn",
	"ts_leuweung": "res://zones/ts_leuweung.tscn",
	"ts_leuwi": "res://zones/ts_leuwi.tscn",
	"ts_sawah": "res://zones/ts_sawah.tscn",
	"ts_situ": "res://zones/ts_situ.tscn",
	"ts_kawah_jalan": "res://zones/ts_kawah_jalan.tscn",
	"ts_kawah": "res://zones/ts_kawah.tscn",
}
## Where you can walk from each area, for the objective arrow's breadth-first search (architecture.md 9).
## Directed: a drop and a shortcut are listed only from the side that can always pass (world.md World
## structure). Kabut links are listed as open. ponytail: an opened shortcut's back edge is not added;
## the arrow just takes the long way round.
const ADJ := {
	"desa_purwa": ["ts_kebun", "mt_gapura"],
	"ts_kebun": ["desa_purwa", "ts_kampung"],
	"ts_kampung": ["ts_kebun", "ts_leuweung", "ts_sawah", "ts_leuwi"],
	"ts_leuweung": ["ts_kampung", "ts_kebun"],   # ts_kebun: sc:ts_pagar, opened from this side
	"ts_leuwi": ["ts_kampung"],
	"ts_sawah": ["ts_kampung", "ts_situ"],
	"ts_situ": ["ts_sawah", "ts_kawah_jalan", "ts_kampung"],   # ts_kampung: sc:ts_tangga
	"ts_kawah_jalan": ["ts_situ", "ts_kawah", "ts_kampung"],   # ts_kampung: the one-way drop
	"ts_kawah": ["ts_kawah_jalan"],
}
## Edges in ADJ with no way back (drops). Shortcut edges are in SHORTCUTS.
const DROPS := [["ts_kawah_jalan", "ts_kampung"]]
## Shortcut id -> [area that can always open it, area behind the gate].
const SHORTCUTS := {"sc:ts_pagar": ["ts_leuweung", "ts_kebun"], "sc:ts_tangga": ["ts_situ", "ts_kampung"]}

var current_zone := ""   # set by Zone._ready; "" in scenes that are not a Zone

var _busy := false
var _fade: ColorRect


func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100   # above GameUI (10)
	add_child(layer)
	_fade = ColorRect.new()
	_fade.color = Color.BLACK
	_fade.modulate.a = 0.0
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_fade)


## After class choice. Game.new_game() has already saved.
func start_new_game() -> void:
	respawn()


## Title screen Continue. Game.load_game() has already run.
func continue_game() -> void:
	respawn()


## Edge exits land here: fade out, load the zone, put the player on spawn_id, fade in.
## zone_id is a ZONES key or a scene path. Calls while a change is running are ignored.
func go_to(zone_id: String, spawn_id: String) -> void:
	var path: String = ZONES.get(zone_id, zone_id)
	if _busy:
		return
	if not ResourceLoader.exists(path):
		push_error("Zones.go_to: no scene for zone '%s'" % zone_id)
		return
	_busy = true
	var tree := get_tree()
	tree.paused = false
	Engine.time_scale = 1.0
	await _fade_to(1.0)
	current_zone = ""
	tree.change_scene_to_file(path)
	await tree.scene_changed
	tree.paused = false   # again: a menu or dialogue may have opened during the fade-out
	Engine.time_scale = 1.0
	var s := _spawn(spawn_id)
	var player := tree.get_first_node_in_group("player") as Node2D
	if s and player:
		player.global_position = s.global_position
		player.reset_physics_interpolation()
	elif spawn_id != "":
		push_warning("Zones.go_to: no spawn '%s' in %s" % [spawn_id, path])
	_busy = false   # before the fade-in so a death during it still respawns
	await _fade_to(0.0)


## The neighbour of `from` on the shortest path to `to`, or "" if there is none or they are equal.
func next_zone(from: String, to: String) -> String:
	if from == to:
		return ""
	var prev := {from: ""}
	var queue: Array = [from]
	while not queue.is_empty():
		var z: String = queue.pop_front()
		for n: String in ADJ.get(z, []):
			if prev.has(n):
				continue
			prev[n] = z
			if n == to:
				while prev[n] != from:
					n = prev[n]
				return n
			queue.append(n)
	return ""


## Death, rest, Continue and new game all land here: the zone reloads (normal enemies back,
## bosses stay dead through Game.killed), full HP and flask, player at the last petilasan.
## Death does not save; resting saved before calling this.
func respawn(rested := false) -> void:
	if _busy:
		return   # death fade and a rest in the same frame: one reload only
	_busy = true
	var game := get_node("/root/Game")
	game.flask_charges = game.flask_max
	game.changed.emit()
	var zone: String = game.last_petilasan.get("zone", "")
	if zone == "" or not ResourceLoader.exists(zone):
		zone = start_zone
	var tree := get_tree()
	tree.paused = false
	Engine.time_scale = 1.0
	current_zone = ""
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


func _fade_to(alpha: float) -> void:
	var tw := _fade.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_fade, "modulate:a", alpha, FADE)
	await tw.finished


func _spawn(id: String) -> Node2D:
	for s in get_tree().get_nodes_in_group("spawn"):
		if s.id == id:
			return s
	return null


func _petilasan(id: String) -> Node2D:
	for p in get_tree().get_nodes_in_group("petilasan"):
		if p.id == id:
			return p
	return null
