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
	"mt_gapura": "res://zones/mt_gapura.tscn",
	"mt_sawah": "res://zones/mt_sawah.tscn",
	"mt_pasar": "res://zones/mt_pasar.tscn",
	"gk_mulut": "res://zones/gk_mulut.tscn",
	"gk_pasir": "res://zones/gk_pasir.tscn",
	"gk_lupa": "res://zones/gk_lupa.tscn",
	"gk_ruang_kala": "res://zones/gk_ruang_kala.tscn",
	"gk_pelataran": "res://zones/gk_pelataran.tscn",
	"gk_hutan": "res://zones/gk_hutan.tscn",
	"gk_jembatan": "res://zones/gk_jembatan.tscn",
	"mt_reruntuhan": "res://zones/mt_reruntuhan.tscn",
	"mt_kuburan": "res://zones/mt_kuburan.tscn",
	"mt_wetan": "res://zones/mt_wetan.tscn",
	"mt_candi": "res://zones/mt_candi.tscn",
	"mt_tegal": "res://zones/mt_tegal.tscn",
	"tt_kulon": "res://zones/tt_kulon.tscn",
	"tt_sabana": "res://zones/tt_sabana.tscn",
	"tt_kali": "res://zones/tt_kali.tscn",
	"tt_beringin": "res://zones/tt_beringin.tscn",
	"tt_ladang": "res://zones/tt_ladang.tscn",
	"tt_pasir": "res://zones/tt_pasir.tscn",
	"tt_candi": "res://zones/tt_candi.tscn",
	"tt_pesisir": "res://zones/tt_pesisir.tscn",
	"sk_karang": "res://zones/sk_karang.tscn",
	"sk_pantai": "res://zones/sk_pantai.tscn",
	"sk_tebing": "res://zones/sk_tebing.tscn",
	"sk_keraton": "res://zones/sk_keraton.tscn",
	"sk_nelayan": "res://zones/sk_nelayan.tscn",
	"sk_bakau": "res://zones/sk_bakau.tscn",
	"sk_gua": "res://zones/sk_gua.tscn",
	"kg_alun": "res://zones/kg_alun.tscn",
	"kg_keraton": "res://zones/kg_keraton.tscn",
	"kg_penjara": "res://zones/kg_penjara.tscn",
	"kg_pamali": "res://zones/kg_pamali.tscn",
	"kg_pasar": "res://zones/kg_pasar.tscn",
	"kg_pustaka": "res://zones/kg_pustaka.tscn",
	"kg_kaputren": "res://zones/kg_kaputren.tscn",
}
## Where you can walk from each area, for the objective arrow's breadth-first search (architecture.md 9).
## Directed: a drop and a shortcut are listed only from the side that can always pass (world.md World
## structure). Kabut links are listed as open. ponytail: an opened shortcut's back edge is not added;
## the arrow just takes the long way round.
const ADJ := {
	"desa_purwa": ["ts_kebun", "kg_alun", "gk_pelataran", "sk_pantai"],   # gk_pelataran: kabut mq4_9, sk_pantai: kabut mq4_2
	"ts_kebun": ["desa_purwa", "ts_kampung"],
	"ts_kampung": ["ts_kebun", "ts_leuweung", "ts_sawah", "ts_leuwi"],
	"ts_leuweung": ["ts_kampung", "ts_kebun"],   # ts_kebun: sc:ts_pagar, opened from this side
	"ts_leuwi": ["ts_kampung"],
	"ts_sawah": ["ts_kampung", "ts_situ"],
	"ts_situ": ["ts_sawah", "ts_kawah_jalan", "ts_kampung"],   # ts_kampung: sc:ts_tangga
	"ts_kawah_jalan": ["ts_situ", "ts_kawah", "ts_kampung"],   # ts_kampung: the one-way drop
	"ts_kawah": ["ts_kawah_jalan"],
	"mt_gapura": ["kg_pamali", "mt_sawah"],
	"mt_sawah": ["mt_gapura", "mt_pasar", "mt_tegal"],
	"mt_pasar": ["mt_sawah", "mt_reruntuhan"],
	"mt_reruntuhan": ["mt_pasar", "mt_wetan", "mt_kuburan", "mt_sawah"],   # mt_sawah: sc:mt_ruin_sawah
	"mt_kuburan": ["mt_reruntuhan", "mt_wetan"],
	"mt_wetan": ["mt_reruntuhan", "mt_kuburan", "mt_candi", "mt_tegal", "tt_kulon"],   # mt_tegal: the one-way drop
	"mt_candi": ["mt_wetan", "mt_gapura"],   # mt_gapura: sc:mt_candi_gapura
	"mt_tegal": ["mt_sawah"],
	"tt_kulon": ["mt_wetan", "tt_sabana"],
	"tt_sabana": ["tt_kulon", "tt_kali", "tt_beringin", "tt_pesisir", "mt_tegal"],   # mt_tegal: sc:mt_tt
	"tt_kali": ["tt_sabana", "tt_ladang"],
	"tt_beringin": ["tt_sabana", "tt_pesisir"],   # tt_pesisir: the one-way drop
	"tt_ladang": ["tt_kali", "tt_pasir", "tt_beringin"],   # tt_beringin: sc:tt_ladang
	"tt_pasir": ["tt_ladang", "tt_candi", "tt_sabana", "tt_pesisir"],   # tt_sabana: sc:tt_pasir
	"tt_candi": ["tt_pasir"],
	"tt_pesisir": ["tt_sabana", "tt_pasir", "sk_karang"],   # sk_karang: S, the back route, kabut mq4_9
	"sk_karang": ["tt_pesisir", "sk_pantai", "sk_keraton", "sk_tebing", "sk_bakau", "sk_gua"],   # sk_keraton: S, kabut mq4_8; sk_tebing: L4
	"sk_pantai": ["desa_purwa", "sk_karang", "sk_nelayan"],
	"sk_tebing": ["sk_karang", "sk_keraton", "ts_situ", "sk_gua"],   # sk_keraton: one-way drop, ts_situ: sc:ts_sk
	"sk_keraton": ["sk_karang", "sk_pantai", "gk_pelataran"],   # sk_pantai: sc:sk_gerbang, gk_pelataran: kabut mq4_9
	"sk_nelayan": ["sk_pantai", "sk_bakau"],
	"sk_bakau": ["sk_nelayan", "sk_karang"],
	"sk_gua": ["sk_karang", "sk_tebing"],
	"kg_alun": ["desa_purwa", "kg_keraton", "kg_pamali", "kg_pasar"],   # kg_keraton: kabut mqg_3, kg_pamali: kabut mqg_7
	"kg_keraton": ["kg_alun", "kg_penjara", "kg_pustaka"],
	"kg_penjara": ["kg_keraton", "kg_kaputren"],
	"kg_pamali": ["kg_alun", "mt_gapura"],
	"kg_pasar": ["kg_alun", "kg_pustaka"],
	"kg_pustaka": ["kg_pasar", "kg_kaputren", "kg_keraton"],
	"kg_kaputren": ["kg_pustaka", "kg_penjara"],
	"gk_mulut": ["gk_pasir", "gk_lupa", "gk_pelataran"],   # gk_lupa: sc:gk_lorong
	"gk_pasir": ["gk_mulut", "gk_lupa", "gk_pelataran", "gk_hutan"],   # gk_lupa: the one-way drop
	"gk_lupa": ["gk_mulut", "gk_ruang_kala", "gk_hutan", "gk_jembatan"],
	"gk_ruang_kala": ["gk_lupa", "desa_purwa"],   # desa_purwa: kala_exit, kabut mq5_3
	"gk_pelataran": ["gk_mulut", "gk_pasir", "desa_purwa", "sk_keraton"],
	"gk_hutan": ["gk_pasir", "gk_lupa"],
	"gk_jembatan": ["gk_lupa"],
}
## Edges in ADJ with no way back (drops, and the one-way kala_exit door). Shortcut edges are in SHORTCUTS.
const DROPS := [["ts_kawah_jalan", "ts_kampung"], ["mt_wetan", "mt_tegal"], ["tt_beringin", "tt_pesisir"], ["sk_tebing", "sk_keraton"], ["gk_pasir", "gk_lupa"], ["gk_ruang_kala", "desa_purwa"]]
## Shortcut id -> [area that can always open it, area behind the gate].
const SHORTCUTS := {"sc:ts_pagar": ["ts_leuweung", "ts_kebun"], "sc:ts_tangga": ["ts_situ", "ts_kampung"],
	"sc:ts_sk": ["sk_tebing", "ts_situ"], "sc:sk_gerbang": ["sk_keraton", "sk_pantai"],
	"sc:mt_ruin_sawah": ["mt_reruntuhan", "mt_sawah"], "sc:mt_candi_gapura": ["mt_candi", "mt_gapura"],
	"sc:mt_tt": ["tt_sabana", "mt_tegal"], "sc:tt_ladang": ["tt_ladang", "tt_beringin"], "sc:tt_pasir": ["tt_pasir", "tt_sabana"],
	"sc:gk_lorong": ["gk_lupa", "gk_mulut"]}

var current_zone := ""   # set by Zone._ready; "" in scenes that are not a Zone
var memory_id := ""      # the Kelir memory entered last (enter_memory); gap.tscn reads its data by it

const MEMORY_DIR := "res://zones/kelir/"
const GAP_SCENE := "res://zones/kelir/gap.tscn"

var _busy := false
var _fade: ColorRect
var _carry := {}   # hero hp/sakti while a stand-in plays a memory (it has neither), put back on the way out


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
	get_node("/root/Events").quest_completed.connect(_on_quest_completed)


## MQ5 done (the walk home through kala_exit): play the epilogue once the arrival has settled.
func _on_quest_completed(id: String) -> void:
	if id != "mq5":
		return
	while _busy:
		await get_tree().process_frame
	go_to("res://ui/epilogue.tscn", "")


## After class choice. Game.new_game() has already saved.
func start_new_game() -> void:
	respawn()


## Title screen Continue. Game.load_game() has already run.
func continue_game() -> void:
	respawn()


## Edge exits land here: fade out, load the zone, put the player on spawn_id (or at `pos` when given), fade in.
## zone_id is a ZONES key or a scene path. Calls while a change is running are ignored.
func go_to(zone_id: String, spawn_id: String, pos := Vector2.INF) -> void:
	var path: String = ZONES.get(zone_id, zone_id)
	if _busy:
		return
	if not ResourceLoader.exists(path):
		push_error("Zones.go_to: no scene for zone '%s'" % zone_id)
		return
	_busy = true
	var tree := get_tree()
	var prev_player := tree.get_first_node_in_group("player") as Node2D
	var prev_hp: int = prev_player.health.hp if prev_player and prev_player.get("health") and not prev_player.health.is_dead() else -1
	var prev_sakti: float = prev_player.sakti.value if prev_player and prev_player.get("sakti") else -1.0
	if prev_hp < 0 and prev_sakti < 0.0:   # leaving a memory: the stand-in has no hp
		prev_hp = _carry.get("hp", -1)
		prev_sakti = _carry.get("sakti", -1.0)
	tree.paused = false
	Engine.time_scale = 1.0
	await fade_to(1.0)
	current_zone = ""
	tree.change_scene_to_file(path)
	await tree.scene_changed
	tree.paused = false   # again: a menu or dialogue may have opened during the fade-out
	Engine.time_scale = 1.0
	var s := _spawn(spawn_id)
	var player := tree.get_first_node_in_group("player") as Node2D
	if player:
		if prev_hp > 0 and player.get("health"):
			player.health.hp = mini(prev_hp, player.health.max_hp)
			player.health.changed.emit(player.health.hp, player.health.max_hp)
		if prev_sakti >= 0.0 and player.get("sakti"):
			player.sakti.value = minf(prev_sakti, player.sakti.max_value)
			player.sakti.changed.emit(player.sakti.value, player.sakti.max_value)
	if player and (s or pos != Vector2.INF):
		player.global_position = pos if pos != Vector2.INF else s.global_position
		player.reset_physics_interpolation()
	elif spawn_id != "":
		push_warning("Zones.go_to: no spawn '%s' in %s" % [spawn_id, path])
	_busy = false   # before the fade-in so a death during it still respawns
	await fade_to(0.0)


## Clue or beat into a Kelir memory (architecture.md 9b): remember where the hero stands (saved, so a quit inside
## resumes at the clue), save, then go_to the memory scene. id is a memory id (zones/kelir/<id>.tscn, or gap.tscn
## when only data/memories/gap_<id>.tres exists) or a scene path (tests).
func enter_memory(id: String) -> void:
	var path := memory_path(id)
	var game := get_node("/root/Game")
	var tree := get_tree()
	if _busy or game.in_memory() or tree.current_scene == null or tree.current_scene.scene_file_path == "":
		return   # no memory inside a memory, and only from a real zone scene, so exit_memory has somewhere to go
	if not ResourceLoader.exists(path):
		push_error("Zones.enter_memory: no scene for memory '%s'" % id)
		return
	var p := tree.get_first_node_in_group("player") as Node2D
	var at := p.global_position if p else Vector2.ZERO
	game.memory_return = {"zone": tree.current_scene.scene_file_path, "pos": [at.x, at.y]}
	_carry = {"hp": p.health.hp if p and p.get("health") else -1, "sakti": p.sakti.value if p and p.get("sakti") else -1.0}
	if not game.save_game():
		push_warning("Zones.enter_memory: save failed; a quit inside resumes at the last save")
	memory_id = id
	get_node("/root/Events").memory_started.emit(id)
	await go_to(path, "")


## KelirMemory.finish() lands here: back to Game.memory_return (zone and position), cleared, then a save.
func exit_memory() -> void:
	var game := get_node("/root/Game")
	var r: Dictionary = game.memory_return
	while _busy:
		await get_tree().process_frame
	game.memory_return = {}   # before the zone loads, so a save during the fade-in has none
	memory_id = ""
	if r.is_empty() or not ResourceLoader.exists(ZONES.get(r.zone, r.zone)):
		push_warning("Zones.exit_memory: no way back, respawning at the petilasan")
		_carry = {}
		await respawn()   # never leave the hero frozen in a finished memory
		return
	await go_to(r.zone, "", Vector2(r.pos[0], r.pos[1]))
	_carry = {}
	game.save_game()


func memory_path(id: String) -> String:
	if id.begins_with("res://") or id.begins_with("user://"):
		return id
	var p := MEMORY_DIR + id + ".tscn"
	return GAP_SCENE if not ResourceLoader.exists(p) and ResourceLoader.exists(gap_data_path(id)) else p


## data/memories/gap_<letter>.tres for "la" or "gap_la".
static func gap_data_path(id: String) -> String:
	return "res://data/memories/%s.tres" % (id if id.begins_with("gap_") else "gap_" + id)


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
## A save that holds a memory_return (quit inside a memory) puts the player back at the clue instead.
## Death does not save; resting saved before calling this.
func respawn(rested := false) -> void:
	if _busy:
		return   # death fade and a rest in the same frame: one reload only
	_busy = true
	var game := get_node("/root/Game")
	game.restore()   # flask (and a living player, about to be replaced anyway)
	var zone: String = game.last_petilasan.get("zone", "")
	var at := Vector2.INF
	var mr: Dictionary = game.memory_return
	if not mr.is_empty() and ResourceLoader.exists(ZONES.get(mr.zone, mr.zone)):
		zone = ZONES.get(mr.zone, mr.zone)
		at = Vector2(mr.pos[0], mr.pos[1])
	game.memory_return = {}
	_carry = {}
	memory_id = ""
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
	if at != Vector2.INF and player:
		player.global_position = at
		player.reset_physics_interpolation()
	elif p and player:
		player.global_position = p.global_position + Vector2(0, 20)   # ASSUMED: just below the shrine
		if player.has_method("reset_physics_interpolation"):
			player.reset_physics_interpolation()
	_busy = false
	if rested and p:
		get_node("/root/Events").rested.emit(p)


func fade_to(alpha: float) -> void:
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
