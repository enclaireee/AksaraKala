extends SceneTree
## Scripted playthrough of Mataram (Story v5: MQ2 2.1-2.24, zones/mataram.md critical path) from the
## border market to the Hariang Banga duel and the truce beat, in the real zones. Every hop and target
## must be walkable from where the player stands (physics on layer 1: walls, live kabut, closed gates).
## Talks run the real dialogue, petilasans rest, clues and memories play, encounters and bosses are
## killed by hand. Run: $GODOT --headless --path . -s tests/mataram_play_test.gd
## ponytail: enemies are killed by fiat and the player is invincible; feel is the user's playtest.

const ROUTE := [
	"q:mq2=active:0",
	# 2.1 both recruiters at the border market (`all`)
	"go:kg_alun", "go:kg_pamali", "go:mt_gapura",
	"do:recruiter_a", "do:recruiter_b", "q:mq2=active:1",
	# 2.2 the blockade, then rest at mataram_1
	"do:mataram_gerbang", "go:mt_sawah", "do:mataram_1", "q:mq2=active:2",
	# 2.3 defend Ki Sumarto's stage
	"go:mt_pasar", "do:mataram_pasar", "q:mq2=active:3",
	# 2.4 Ha from Ki Sumarto
	"do:mataram_dalang", "q:mq2=active:4",
	# 2.5 escort the market families across the paddies
	"go:mt_sawah", "do:mataram_sawah_road", "q:mq2=active:5",
	# 2.6 the ruins: clear them, read Na off the Arca base (the north gate is still shut, so via the market)
	"go:mt_pasar", "go:mt_reruntuhan", "do:ka_chalk", "do:mataram_ruins", "do:arca_base", "q:mq2=active:6",
	# 2.7 cleanse the graveyard, 2.8 the third mask fragment and H3
	"go:mt_kuburan", "do:mataram_kuburan", "q:mq2=active:7", "beat:hunter_war",
	"do:hunter_mask_3", "q:mq2=active:8",
	# 2.9 the lesung yard, 2.10 Ca from Nyai Gendhis
	"go:mt_wetan", "do:mataram_lesung_yard", "q:mq2=active:9", "do:lesung_women", "q:mq2=active:10",
	# 2.11 break the siege on the shrine, 2.12 align the braziers and take Ra
	"do:mataram_batu", "q:mq2=active:11",
	"do:shrine_brazier_1", "do:shrine_brazier_2", "do:shrine_brazier_3", "do:shrine_brazier_4", "do:juru_kunci", "q:mq2=active:12",
	# 2.13 the plain of rising stones
	"go:mt_tegal", "do:mataram_tegal_pillars", "q:mq2=active:13",
	# 2.14 the temple gate and the camp (the turn)
	"go:mt_sawah", "go:mt_pasar", "go:mt_reruntuhan", "go:mt_wetan", "go:mt_candi",
	"do:mataram_candi", "do:mataram_camp", "q:mq2=active:14", "beat:camp",
	# 2.15 the three K3 clues (no memory yet)
	"do:rubble", "do:lesung_mid", "do:ka_strip", "q:mq2=active:15",
	# 2.16 LC3 chapter: Laras unbars the crypt
	"do:lc3_lontar", "q:mq2=active:16",
	# 2.17 descend through the opened crypt
	"do:candi_crypt_hall", "q:mq2=active:17",
	# 2.18 the K3 memory of the false-dawn lesung
	"do:k3_lesung", "q:mq2=active:18",
	# 2.19 Bandung Bondowoso
	"do:bandung_bondowoso", "q:mq2=active:19",
	# 2.20 take the temple shortcut back to the border
	"go:mt_gapura", "do:sc:mt_candi_gapura", "do:mataram_causeway", "do:mataram_tepi", "go:kg_pamali", "q:mq2=active:20",
	# 2.21 the Pamali stone
	"do:pamali_bank", "do:pamali_ford", "do:pamali_stone",
	"write:nagawiru:jawa_na,sunda_ga", "q:mq2=active:21",
	# 2.22 K-III, Ki Sumarto's shadow play
	"do:sumarto_show", "q:mq2=active:22",
	# 2.23 Hariang Banga's unsent letters
	"do:hariang_letters", "q:mq2=active:23", "beat:ford",
	# 2.24 the duel, then the truce beat's choice (1 = judgment)
	"pick:1", "do:hariang_banga", "q:mq2=done", "beat:truce", "flag:choice_judgment", "q:mq3=active:0",
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
	for f in ["mq1_10", "mqg_7", "beat_hunter_raid", "beat_laras_1", "beat_naga", "beat_galuh_bout", "beat_laras_2", "beat_cage", "beat_confession", "beat_escape"]:
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
			"cast": events.spell_cast.emit(kv[1], 1.0)   # a drawn glyph (cast_controller emits the glyph id)
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
		if l.begins_with("#"):   # scene cue, not text
			continue
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
		if n is CanvasItem and not n.visible:
			continue   # a cond-hidden twin (e.g. Cepot at the south gate and on the beach)
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
	elif f.ends_with("clue.tscn"):
		return await _clue(n)
	elif n.is_in_group("boss"):
		return await _beat_boss(n)
	return true


## Examine a clue. A memory clue then enters its Kelir scene; finish it like the player would (draw the
## chapter's Ka card) and come back to the zone.
func _clue(n: Node) -> bool:
	var zid := zone.zone_id   # the zone is freed when a memory scene loads, so keep its name now
	var cid := String(n.get("clue_id"))
	var mem_id := String(n.get("memory_id"))
	if not check(bool(n.get("usable")), "%s: clue '%s' is not usable (cond)" % [zid, cid]):
		return false
	n.interact()
	await _drain()
	if mem_id == "":
		return true
	var zones := root.get_node("Zones")
	for i in 300:
		if current_scene is KelirMemory and not zones._busy:
			break
		await _drain()
		await process_frame
	if not check(current_scene is KelirMemory, "%s: clue '%s' did not enter memory '%s'" % [zid, cid, mem_id]):
		return false
	return await _memory()


## Finish the current Kelir memory: close its narration, draw any chapter card, wait for the exit fade.
func _memory() -> bool:
	var mem := current_scene as KelirMemory
	var mem_id := mem.memory_id
	await _drain()
	mem.finish()
	for i in 60 * 60:
		if current_scene != mem:
			break
		await _drain()
		var lesson := _find("res://ui/glyph_lesson.gd")
		if lesson and lesson.writing != "":
			lesson.write_attempt(GlyphData.by_id("sunda_ka").templates[0])
		await process_frame
	await _settle()
	return check(current_scene is Zone, "memory %s did not return to a zone" % mem_id)


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
	# A spot is a zone.area_scale() x zone.area_scale() block centred on the node: stand on it or on a tile edge-adjacent to it.
	var o := Vector2i(((n.global_position - Vector2.ONE * zone.area_scale() * 8.0) / 16.0).round())
	for y in range(-1, zone.area_scale() + 1):
		for x in range(-1, zone.area_scale() + 1):
			if (x < 0 or x >= zone.area_scale()) and (y < 0 or y >= zone.area_scale()):
				continue   # corners touch the block only diagonally
			out.append(o + Vector2i(x, y))
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


## Damage the enemies inside a target encounter rect only. A zone-wide sweep would clear an encounter the
## route has not visited yet: a later step then waits for an `area_cleared` that has already fired.
func _hit_inside(rect: Rect2) -> void:
	for e in zone.entities.get_children():   # not the "enemy" group: a dormant Arca is not in it
		if not (e is EnemyBase) or e.dead or not rect.has_point(e.global_position):
			continue
		if e.is_in_group("boss"):
			continue
		e.get_node("Health").take_damage(99999, player, true)


func _clear(id: String) -> bool:
	var done := [false]
	var cb := func(a: String) -> void: done[0] = done[0] or a == id
	events.area_cleared.connect(cb)
	var enc := _target(id)
	var rect := Rect2(player.global_position - Vector2(8, 8), Vector2(16, 16))
	if enc:
		var sz: Vector2i = enc.get("size")
		rect = Rect2(zone.tiles.map_to_local(_cell(enc.global_position)) - Vector2(sz) * 8.0, Vector2(sz) * 16.0)
	for i in 60 * 30:
		if done[0]:
			break
		_hit_inside(rect)
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
