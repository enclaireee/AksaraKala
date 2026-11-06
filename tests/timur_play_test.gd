extends SceneTree
## Tanah Timur route (tanah_timur.md): MQ3 3.1-3.11 and SQ-T1..T4 walked area to area from the Mataram border (Story v3.1: ends on the keris choice, the Nameless Hunter and the hunter_name beat),
## the way mataram_play_test.gd walks MQ2. Same actions, plus "kill:<kind>" (an active quest elite) and
## "stakes" (cast next to the practice stakes). ponytail: kills and casts are faked, the user playtests combat.

const ROUTE := [
	# MQ3 step index = row order in quests.md 4 (3.1 = 0 ... 3.11 = 10).
	"q:mq3=active:0",
	"do:timur_gerbang", "q:mq3=active:1",
	"go:tt_sabana", "do:timur_1", "q:mq3=active:2",
	"do:timur_herder", "q:sq_t2=active:1", "do:timur_embers",
	"go:tt_kali", "do:klething_kuning", "q:sq_t1=active:1",
	"go:tt_sabana", "go:tt_beringin", "do:timur_empu", "q:mq3=active:3",
	"do:kepang_leader", "q:sq_t4=active:1",
	"do:sodo_lanang", "q:sq_t1=active:2",
	"go:tt_sabana", "do:kuda_kepang_1", "go:tt_kali", "do:kuda_kepang_2",
	"do:klething_kuning", "q:sq_t1=done", "has:stone_ring",
	"do:timur_wisps", "do:mbok_srini", "q:mq3=active:4",
	"go:tt_ladang", "do:timur_ladang", "do:buto_ijo", "q:mq3=active:5",
	"go:tt_beringin", "do:sc:tt_ladang", "do:timur_empu", "q:mq3=active:5",
	"do:timur_praktik", "q:mq3=active:5", "stakes", "q:mq3=active:6",
	"go:tt_pesisir", "do:kuda_kepang_3", "q:sq_t4=active:2",
	"do:burn_trail", "q:sq_t2=active:2", "kill:banaspati_elite", "q:sq_t2=active:3",
	"do:timur_pesisir", "q:mq3=active:7",
	"go:tt_sabana", "do:timur_herder", "q:sq_t2=done",
	"go:tt_beringin", "do:kepang_leader", "q:sq_t4=active:3", "do:kepang_stage", "q:sq_t4=done",
	# SQ-T3 opens with 3.3 but the empu offers it only once his step hints (steps 3 and 5) are past.
	"do:timur_empu", "q:sq_t3=active:1",
	"go:tt_sabana", "go:tt_kulon", "go:mt_wetan", "go:mt_candi", "do:batu_bintang", "q:sq_t3=active:2",
	"go:mt_wetan", "go:tt_kulon", "go:tt_sabana", "go:tt_beringin", "do:timur_empu", "q:sq_t3=done", "has:keris_luk_7",
	"go:tt_ladang", "go:tt_pasir", "do:timur_pasir", "q:mq3=active:8", "do:timur_2", "q:mq3=active:9", "beat:laras_4",
	"go:tt_candi", "pick:1", "do:keris_gandring", "q:mq3=active:10", "beat:keris", "flag:choice_sink",
	"beat:hunter_shrine", "do:nameless_hunter", "q:mq3=done", "beat:hunter_name", "q:mq4=active",
]

var fails := 0
var game: Node
var events: Node
var zone: Zone
var player: CharacterBody2D
var log_lines: PackedStringArray = []


func check(ok: bool, msg: String) -> bool:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)
	return ok


func _initialize() -> void:
	await process_frame
	game = root.get_node("Game")
	events = root.get_node("Events")
	game.save_path = "user://test_timur_play.json"
	for f in ["mq0_done", "mq1_10", "mqg_7", "mq2_1", "mq2_2", "mq2_3", "mq2_4", "mq2_5", "mq2_6", "mq2_7", "mq2_8", "mq2_9",
			"beat_hunter_raid", "beat_laras_1", "beat_naga", "beat_galuh_bout", "beat_laras_2", "beat_cage",
			"beat_hunter_war", "beat_laras_3", "beat_ford", "beat_truce"]:
		game.flags[f] = true
	for q in ["mq1", "mqg", "mq2"]:
		game.quests[q] = {"state": "done", "step": 0, "count": 0, "resolution": ""}
	game.start_quest("mq3")
	events.dialogue_requested.connect(_on_dialogue)
	change_scene_to_file(root.get_node("Zones").start_zone)
	await scene_changed
	await root.get_node("Zones").go_to("tt_kulon", "from_mt_wetan")
	await _settle()
	for a: String in ROUTE:
		var kv := a.split(":", true, 1)
		var ok := true
		if kv[0] == "pick":
			pick = int(kv[1])   # before the drain: the beat it answers is already up
			continue
		await _drain()
		match kv[0]:
			"go": ok = await _go(kv[1])
			"do": ok = await _do(kv[1])
			"q": ok = _expect(kv[1])
			"has": ok = check(game.inventory.has(kv[1]), "no %s in the inventory" % kv[1])
			"kill": ok = _kill(kv[1])
			"stakes": ok = await _stakes()
			"beat": ok = check(game.has_flag("beat_" + kv[1]), "beat %s did not play" % kv[1])
			"flag": ok = check(game.has_flag(kv[1]), "flag %s not set" % kv[1])
			"write": ok = await _write(kv[1])
			"see": ok = check(_exit_to(kv[1]) != null and _reachable(_cells_of(_exit_to(kv[1]))), "%s: exit to %s not reachable" % [zone.zone_id, kv[1]])
		if not ok:
			printerr("  stopped at '%s' in %s" % [a, zone.zone_id])
			break
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.save_path))
	quit(1 if fails > 0 else 0)


func _settle() -> void:
	for i in 3:
		await physics_frame
	zone = current_scene as Zone
	player = get_first_node_in_group("player")
	player.get_node("Health").set_invincible(1e9)
	var menu := _find("res://ui/menu.gd")
	if menu and paused:
		menu.close()


## A story beat plays on its own (ui/story_beat.gd) once nothing else is open: close every box that opens, picking
## choice `pick` (set by "pick:<n>", then back to 0) like the player would. Chains take a few frames.
var pick := 0


func _drain() -> void:
	for i in 6:
		var box := _find("res://ui/dialogue_box.gd")
		while box and box.is_open():
			while not box._opts.is_empty() and not box._choosing:
				box._next()   # read on to the choice list
			if box._choosing:
				events.dialogue_picked.emit(pick)
				pick = 0
			box._close()
		await process_frame


## Draw the glyphs of a write card (Events.write_requested) with their stored templates, then wait out the fade.
func _write(spec: String) -> bool:
	var p := spec.split(":")
	var lesson := _find("res://ui/glyph_lesson.gd")
	if not check(lesson != null and lesson.writing == p[0], "no write card for %s" % p[0]):
		return false
	for g in p[1].split(","):
		check(lesson.write_attempt(GlyphData.by_id(g).templates[0]), "write %s: %s not accepted" % [p[0], g])
	for i in 600:
		if lesson.writing == "":
			break
		await process_frame
	return check(lesson.writing == "", "write card for %s never closed" % p[0])


func _find(script: String) -> Node:
	for n in root.find_children("*", "", true, false):
		if n.get_script() and n.get_script().resource_path == script:
			return n
	return null


## Every dialogue line the player sees must have a translation.
func _on_dialogue(_who: String, lines: PackedStringArray) -> void:
	for l in lines:
		if l.begins_with("@"):   # speaker switch; a bare "@" clears the tag
			l = l.substr(1)
			if l == "":
				continue
		check(tr(l) != l, "untranslated dialogue key %s" % l)


func _expect(spec: String) -> bool:
	var p := spec.split("=")
	var want := p[1].split(":")
	var st: String = game.quest_state(p[0])
	var step := int(game.quests[p[0]].step) if game.quests.has(p[0]) else -1
	var ok := st == want[0] and (want.size() == 1 or step == int(want[1]))
	return check(ok, "%s is %s step %d, want %s" % [p[0], st, step, p[1]])


func _exit_to(area: String) -> Node:
	for n in zone.entities.get_children():
		if n.scene_file_path.ends_with("exit.tscn") and n.target_zone == area:
			return n
	return null


func _go(area: String) -> bool:
	var e := _exit_to(area)
	if not check(e != null, "%s has no exit to %s" % [zone.zone_id, area]):
		return false
	if not check(_reachable(_cells_of(e)), "%s: exit to %s is not reachable from %s" % [zone.zone_id, area, _cell(player.global_position)]):
		return false
	await root.get_node("Zones").go_to(area, e.spawn_id)
	await _settle()
	return check(zone.zone_id == area and not _solid(_cell(player.global_position)), "arrived in %s at %s (solid?)" % [zone.zone_id, _cell(player.global_position)])


func _target(id: String) -> Node:
	for n in zone.entities.find_children("*", "", true, false):
		for k in [n.get("id"), n.get("npc_id"), n.get("trigger_id"), n.get("area_id"), n.get("item_id"), n.get("kind")]:
			if (k is String or k is StringName) and String(k) == id and not n.is_queued_for_deletion():
				return n
	return null


func _do(id: String) -> bool:
	var n := _target(id)
	if not check(n != null, "%s has no '%s'" % [zone.zone_id, id]):
		return false
	var goals := _cells_of(n)
	var at := _reach(goals)
	if not check(at != Vector2i(-1, -1), "%s: '%s' is not reachable from %s" % [zone.zone_id, id, _cell(player.global_position)]):
		return false
	player.global_position = zone.tiles.map_to_local(at)
	player.reset_physics_interpolation()
	await _settle()
	var f: String = n.scene_file_path
	if f.ends_with("npc.tscn"):
		n.interact()
		var box := _find("res://ui/dialogue_box.gd")
		while box and box.is_open():
			box._close()
		await process_frame
	elif f.ends_with("petilasan.tscn"):
		n.rest()
		await scene_changed
		await _settle()
	elif f.ends_with("shortcut.tscn"):
		check(n.from_open_side(player.global_position), "%s: gate %s reached from the closed side" % [zone.zone_id, id])
		n.interact()
		await _settle()
		return check(game.has_flag(id), "gate %s did not open" % id)
	elif f.ends_with("chest.tscn") or f.ends_with("pickup.tscn"):
		n.interact()
		await process_frame
		return check(game.inventory.has(id) or not is_instance_valid(n) or n.is_queued_for_deletion(), "%s: '%s' not picked" % [zone.zone_id, id])
	elif f.ends_with("encounter.tscn"):
		return await _clear(id)
	elif n.is_in_group("boss"):
		return await _beat_boss(n)
	return true


## Cells to stand on: inside a trigger or encounter rect, else the node's cell or one next to it.
func _cells_of(n: Node) -> Array[Vector2i]:
	var c := _cell(n.global_position)
	var out: Array[Vector2i] = []
	var sz = n.get("size")
	if sz is Vector2i and (n.scene_file_path.ends_with("trigger.tscn") or n.scene_file_path.ends_with("encounter.tscn")):
		for y in range(-(sz.y / 2), sz.y - sz.y / 2):
			for x in range(-(sz.x / 2), sz.x - sz.x / 2):
				out.append(c + Vector2i(x, y))
		return out
	for d in [Vector2i.ZERO, Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		out.append(c + d)
	return out


func _cell(p: Vector2) -> Vector2i:
	return zone.tiles.local_to_map(zone.tiles.to_local(p))


func _solid(c: Vector2i) -> bool:
	if c.x < 0 or c.y < 0 or c.x >= zone.size.x or c.y >= zone.size.y:
		return true
	var q := PhysicsPointQueryParameters2D.new()
	q.position = zone.tiles.to_global(zone.tiles.map_to_local(c))
	q.collision_mask = player.collision_mask
	q.exclude = [player.get_rid()]
	for hit in zone.get_world_2d().direct_space_state.intersect_point(q, 8):
		if not hit.collider is CharacterBody2D:
			return true
	return false


func _reachable(goals: Array[Vector2i]) -> bool:
	return _reach(goals) != Vector2i(-1, -1)


## BFS over walkable cells from the player; the first goal cell reached, or (-1, -1).
func _reach(goals: Array[Vector2i]) -> Vector2i:
	var start := _cell(player.global_position)
	var seen := {start: true}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var c: Vector2i = queue.pop_front()
		if goals.has(c) and not _solid(c):
			return c
		for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var n: Vector2i = c + d
			if not seen.has(n) and (not _solid(n) or goals.has(n)):
				seen[n] = true
				if not _solid(n):
					queue.append(n)
	return Vector2i(-1, -1)


func _kill_all() -> void:
	for e in zone.entities.get_children():   # not the "enemy" group: a dormant Arca is not in it
		if e is EnemyBase and not e.dead and not e.is_in_group("boss"):
			e.get_node("Health").take_damage(99999, player, true)


func _clear(id: String) -> bool:
	var done := [false]
	var cb := func(a: String) -> void: done[0] = done[0] or a == id
	events.area_cleared.connect(cb)
	for i in 60 * 30:
		if done[0]:
			break
		_kill_all()
		await physics_frame
	events.area_cleared.disconnect(cb)
	return check(done[0], "%s: encounter %s never cleared" % [zone.zone_id, id])


func _beat_boss(b: Node) -> bool:
	check(b.target == player, "%s: boss has no target (placed before the player?)" % zone.zone_id)
	var done := [false]
	var cb := func(_a: String) -> void: done[0] = true
	events.boss_defeated.connect(cb)
	for i in 60 * 120:
		if done[0]:
			break
		for p in b.get("pillars") if b.get("pillars") != null else []:
			if is_instance_valid(p) and not p.dead:
				p.expose(3.0)
				p.health.take_damage(99999, player, true)
		if is_instance_valid(b) and not b.health.is_dead():
			b.health.take_damage(200, player, true)
		await physics_frame
	events.boss_defeated.disconnect(cb)
	await _settle()
	return check(done[0], "%s: boss never defeated" % zone.zone_id)


func _kill(kind: String) -> bool:
	var e := _target(kind)
	if not check(e is EnemyBase and e.get("active") != false, "%s: no active %s" % [zone.zone_id, kind]):
		return false
	e.health.take_damage(99999, player, true)
	return check(e.dead, "%s: %s did not die" % [zone.zone_id, kind])


## Stand next to each practice stake in turn and cast, until step 3.6 (index 5) moves on.
func _stakes() -> bool:
	for s in get_nodes_in_group("curse_stake"):
		if game.quests.mq3.step != 5:
			break
		var at := _reach(_cells_of(s))
		if not check(at != Vector2i(-1, -1), "%s: practice stake not reachable" % zone.zone_id):
			return false
		player.global_position = zone.tiles.map_to_local(at)
		player.reset_physics_interpolation()
		await _settle()
		events.spell_cast.emit("sunda_ka", 1.0)
		await process_frame
	return true
