extends SceneTree
## Scripted playthrough of Mataram (zones/mataram.md critical path): MQ2 start to end (Story v3.1: from kg_pamali to the Hariang Banga duel and the truce beat) plus SQ-M1 to M4,
## in the real zones. Every hop and target must be walkable from where the player stands (physics on
## layer 1: walls, live kabut, closed gates). Talks run the real dialogue, petilasans rest, encounters
## and the boss are killed by hand. Run: $GODOT --headless --path . -s tests/mataram_play_test.gd
## ponytail: enemies are killed by fiat and the player is invincible; feel is the user's playtest.

const ROUTE := [
	"q:mq2=active:0",
	"go:kg_alun", "go:kg_pamali", "go:mt_gapura", "do:mataram_gerbang", "q:mq2=active:1",
	"go:mt_sawah", "do:mataram_1", "q:mq2=active:2",
	"do:nawang_wulan", "q:sq_m1=active:1", "do:lumbung", "do:selendang_nawang", "do:nawang_wulan", "q:sq_m1=done",
	# 2.3 the three leads (one `all` step, any order): market, ruins, graveyard. Each sets its lead flag.
	"go:mt_pasar", "do:mataram_pasar", "flag:lead_pasar", "q:mq2=active:2",
	"do:pande_besi", "q:sq_m3=active:1",
	"go:mt_reruntuhan", "do:pak_karto", "do:mataram_ruins", "flag:lead_ruins", "q:mq2=active:2",
	"go:mt_kuburan", "do:mataram_kuburan", "flag:lead_kuburan", "q:mq2=active:3", "beat:hunter_war",
	# 2.4 Ha from Ki Sumarto, 2.5 Na from the Arca base, 2.6 Ca from the lesung women.
	"go:mt_reruntuhan", "go:mt_sawah", "do:sc:mt_ruin_sawah", "go:mt_pasar", "do:mataram_dalang", "q:mq2=active:4", "do:mataram_dalang", "q:sq_m4=active:1",
	"do:wewe_neighbor", "q:sq_m2=active:1", "do:wewe_parents",   # SQ-M2 and SQ-M4 unlock with 2.4 (mq2_2)
	"go:mt_sawah", "go:mt_reruntuhan", "do:arca_base", "q:mq2=active:5",
	"do:gong_ageng", "q:sq_m4=active:2",
	"go:mt_sawah", "do:lesung_women", "q:mq2=active:6",
	# 2.7 the foothill blockade, 2.8 Ra from the juru kunci.
	"go:mt_reruntuhan", "go:mt_kuburan", "do:wewe_hill", "do:wewe_parents_2", "q:sq_m2=active:3", "go:mt_wetan", "do:mataram_batu", "q:mq2=active:7", "do:juru_kunci", "q:mq2=active:8",
	"go:mt_tegal", "do:tuyul_hideout", "do:tuyul_leader", "q:sq_m3=active:3",
	"go:mt_sawah", "go:mt_pasar", "do:pande_besi", "q:sq_m3=done", "do:wewe_neighbor", "q:sq_m2=done",
	"do:mataram_dalang", "q:sq_m4=done",
	# 2.9 the temple gate, 2.10 the camp (the turn), then the temple petilasan and the Laras beat.
	"go:mt_reruntuhan", "go:mt_wetan", "go:mt_candi", "do:mataram_candi", "q:mq2=active:9", "do:mataram_camp", "q:mq2=active:10", "beat:camp",
	"do:mataram_2", "beat:laras_3",
	# 2.11 Bandung Bondowoso, 2.12 the Pamali stone, 2.13 the duel.
	"do:bandung_bondowoso", "q:mq2=active:11",
	"go:mt_gapura", "do:sc:mt_candi_gapura", "go:kg_pamali",
	"do:pamali_stone", "write:nagawiru:jawa_na,sunda_ga", "q:mq2=active:12", "beat:ford",
	"pick:1", "do:hariang_banga", "q:mq2=done", "beat:truce", "flag:choice_silent", "q:mq3=active:0",
	"go:mt_gapura", "go:mt_sawah", "go:mt_reruntuhan", "go:mt_wetan", "see:tt_kulon",
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
	game.save_path = "user://test_mataram_play.json"
	game.flags["mq0_done"] = true
	game.quests["mq1"] = {"state": "done", "step": 0, "count": 0, "resolution": ""}
	game.quests["mqg"] = {"state": "done", "step": 0, "count": 0, "resolution": ""}
	for f in ["mq1_10", "mqg_7", "beat_hunter_raid", "beat_laras_1", "beat_naga", "beat_galuh_bout", "beat_laras_2", "beat_cage"]:
		game.flags[f] = true
	game.run("start:mq2")   # the beat_cage beat does this in play
	events.dialogue_requested.connect(_on_dialogue)
	change_scene_to_file(root.get_node("Zones").start_zone)
	await scene_changed
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
		for k in [n.get("id"), n.get("npc_id"), n.get("trigger_id"), n.get("area_id"), n.get("item_id"), n.get("kind"), n.get("clue_id"), n.get("memory_id")]:
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
