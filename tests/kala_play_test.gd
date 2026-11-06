extends "res://tests/timur_play_test.gd"
## Gua Kala route (gua_kala.md, P0): the Hunter's fall (3.8) lifts the fog north of Desa Purwa and the hunter_name beat starts MQ5; MQ5 5.1-5.4
## walked area to area (5.4 = the write card, drawn with the stored templates), then the epilogue plays and drops the player home at from_gua_kala.
## Reuses timur_play_test.gd's walker. ponytail: kills and casts are faked, the user playtests combat.

const KALA_ROUTE := [
	"go:gk_mulut", "q:mq5=active:1", "beat:mouth", "do:kala_2", "do:kala_mulut", "q:mq5=active:2",
	"go:gk_pasir", "do:kala_pasir_1", "q:mq5=active:3", "do:kala_pasir_2", "q:mq5=active:4", "chest:kala_chest_1",
	"go:gk_lupa", "do:kala_lupa", "q:mq5=active:5", "chest:kala_chest_2", "do:batara_kala", "do:ruwatan",
	"go:gk_mulut", "do:sc:gk_lorong", "go:gk_lupa",
	"do:semar_kala", "do:kala_1", "q:mq5=active:6", "beat:laras_5",
	"go:gk_ruang_kala", "do:batara_kala", "q:mq5=active:7",
	"beat:write", "write:laras:sunda_la,sunda_ra,sunda_sa", "q:mq5=done",
]


func _initialize() -> void:
	await process_frame
	game = root.get_node("Game")
	events = root.get_node("Events")
	game.save_path = "user://test_kala_play.json"
	for f in ["mq0_done", "mq1_10", "mqg_7", "mq2_9", "mq3_1", "mq3_2", "mq3_3", "mq3_4", "mq3_7", "choice_sink",
			"beat_hunter_raid", "beat_laras_1", "beat_naga", "beat_galuh_bout", "beat_laras_2", "beat_cage", "beat_hunter_war",
			"beat_laras_3", "beat_ford", "beat_truce", "beat_laras_4", "beat_keris", "beat_hunter_shrine"]:
		game.flags[f] = true
	for q in ["mq1", "mqg", "mq2"]:
		game.quests[q] = {"state": "done", "step": 0, "count": 0, "resolution": ""}
	game.quests["mq3"] = {"state": "active", "step": 13, "count": 0, "resolution": ""}
	for g in ["sunda_ka", "sunda_ga", "jawa_na"]:
		game.run("learn:" + g)
	events.dialogue_requested.connect(_on_dialogue)
	change_scene_to_file(root.get_node("Zones").start_zone)
	await scene_changed
	await _settle()
	var ok: bool = check(_exit_to("gk_mulut") != null and not _reachable(_cells_of(_exit_to("gk_mulut"))), "Gua Kala gate open before 3.8")
	if ok:   # the Hunter falls at tt_candi (Tanah Timur walk); the hunter_name beat then starts MQ5
		events.boss_defeated.emit("nameless_hunter")
		await _drain()
	ok = ok and _expect("mq3=done") and check(game.has_flag("beat_hunter_name"), "hunter_name beat did not play") and _expect("mq5=active:0")
	for a: String in KALA_ROUTE if ok else []:
		var kv := a.split(":", true, 1)
		if kv[0] == "pick":
			pick = int(kv[1])
			continue
		await _drain()
		match kv[0]:
			"beat": ok = check(game.has_flag("beat_" + kv[1]), "beat %s did not play" % kv[1])
			"write": ok = await _write(kv[1])
			"go": ok = await _go(kv[1])
			"do": ok = await _do(kv[1])
			"q": ok = _expect(kv[1])
			"chest": ok = await _chest(kv[1])
		if not ok:
			printerr("  stopped at '%s' in %s" % [a, zone.zone_id])
			break
	if ok:
		await _epilogue()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.save_path))
	quit(1 if fails > 0 else 0)


## Writing Laras's name completes MQ5 and swaps in the epilogue; advancing through it lands in Desa Purwa.
func _epilogue() -> void:
	for i in 600:
		if current_scene and current_scene.scene_file_path == "res://ui/epilogue.tscn":
			break
		await process_frame
	var ep := current_scene
	if not check(ep and ep.scene_file_path == "res://ui/epilogue.tscn", "no epilogue after MQ5"):
		return
	await process_frame
	for i in 60:
		if ep._done:
			break
		ep.advance()
	check(ep.index == 7, "epilogue stopped at line %d, want 7" % ep.index)
	for i in 600:
		if current_scene is Zone and current_scene.zone_id == "desa_purwa":
			break
		await process_frame
	await _settle()
	check(zone and zone.zone_id == "desa_purwa", "epilogue does not return to Desa Purwa")
	check(zone.spawn("from_gua_kala").global_position.distance_to(player.global_position) < 1.0, "not home at from_gua_kala")


## Ilmu chests share item_id "ilmu:300", so they are found and checked by chest_id.
func _chest(id: String) -> bool:
	var n: Node = null
	for c in zone.entities.find_children("*", "", true, false):
		if c.get("chest_id") == id:
			n = c
	if not check(n != null, "%s has no chest '%s'" % [zone.zone_id, id]):
		return false
	var at := _reach(_cells_of(n))
	if not check(at != Vector2i(-1, -1), "%s: chest '%s' is not reachable" % [zone.zone_id, id]):
		return false
	player.global_position = zone.tiles.map_to_local(at)
	player.reset_physics_interpolation()
	await _settle()
	n.interact()
	return check(game.has_flag("chest:" + id), "%s: chest '%s' did not open" % [zone.zone_id, id])


## Codex pickups are found by codex_id too.
func _target(id: String) -> Node:
	var n := super(id)
	if n:
		return n
	for p in zone.entities.find_children("*", "", true, false):
		if p.get("codex_id") == id and not p.is_queued_for_deletion():
			return p
	return null


## The shield only drops to the shown glyphs: cast the next one each frame, then hit.
func _beat_boss(b: Node) -> bool:
	if b.get("sequence") == null:
		return await super(b)
	var done := [false]
	var cb := func(_a: String) -> void: done[0] = true
	events.boss_defeated.connect(cb)
	for i in 60 * 120:
		if done[0]:
			break
		if is_instance_valid(b) and b.dawn != null and not b.sequence.is_empty():
			events.spell_cast.emit(b.sequence[b.seq_index], 1.0)
		if is_instance_valid(b) and not b.health.is_dead():
			b.health.take_damage(200, player, true)
		await physics_frame
	events.boss_defeated.disconnect(cb)
	await _settle()
	return check(done[0], "%s: Batara Kala never calmed" % zone.zone_id)
