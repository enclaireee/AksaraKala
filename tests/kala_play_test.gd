extends "res://tests/timur_play_test.gd"
## Gua Kala route (Story v5 gua_kala.md, P0): MQ4 done (flag mq4_9) lifts the fog north of Desa Purwa and the kidul beat starts MQ5;
## MQ5 5.1-5.14 walked area to area (5.14 = the write card, drawn with the stored templates), then the epilogue plays and drops the player home at from_gua_kala.
## Reuses timur_play_test.gd's walker. ponytail: kills and casts are faked, the user playtests combat.

const KALA_ROUTE := [
	# 5.1 courtyard siege, 5.2 Choice 6 at the ancestors' memorial stone
	"go:gk_pelataran", "beat:pelataran", "do:kala_pelataran_siege", "q:mq5=active:1",
	"pick:0", "do:memorial_stone", "q:mq5=active:2", "beat:aria",
	# 5.3 the cave mouth and petilasan kala_2, 5.4 gap memory La
	"go:gk_mulut", "do:kala_2", "do:kala_mulut", "q:mq5=active:3",
	"do:letter_la", "q:mq5=active:4", "beat:la_back",
	# 5.5 the two time-sand wards in gk_pasir
	"go:gk_pasir", "do:kala_pasir_1", "do:kala_pasir_2", "q:mq5=active:5", "beat:wards_down", "chest:kala_chest_1",
	# 5.6 the whispering name-trees in gk_hutan
	"go:gk_hutan", "do:kala_hutan_echoes", "do:hutan_name_chimes", "q:mq5=active:6", "chest:kala_chest_hutan",
	# 5.7 the Hall of Forgotten Names and gap memory Ra, plus shortcut sc:gk_lorong
	"go:gk_lupa", "do:kala_lupa_1", "do:kala_lupa", "do:letter_ra", "q:mq5=active:7", "beat:ra_back", "chest:kala_chest_2", "do:batara_kala", "do:ruwatan",
	"go:gk_mulut", "do:sc:gk_lorong", "go:gk_lupa",
	# 5.8 the Echo Bridge in gk_jembatan
	"go:gk_jembatan", "beat:bridge", "do:kala_jembatan_echoes", "q:mq5=active:8", "go:gk_lupa",
	# 5.9 petilasan kala_1 and gap memory Sa; 5.10 K10 Murwakala; 5.11 K7 Ruwatan; 5.12 LC6 chapter
	"do:kala_1", "do:letter_sa", "q:mq5=active:9", "beat:sa_back",
	"do:semar_tale", "q:mq5=active:10",
	"do:semar_kelir", "q:mq5=active:11",
	"do:lc6_lontar", "q:mq5=active:12",
	# 5.13 Batara Kala in gk_ruang_kala; 5.14 write Laras's name
	"go:gk_ruang_kala", "beat:kala_wake", "do:batara_kala", "q:mq5=active:13",
	"beat:write", "write:laras:sunda_la,sunda_ra,sunda_sa", "q:mq5=done",
]


func _initialize() -> void:
	await process_frame
	game = root.get_node("Game")
	events = root.get_node("Events")
	game.save_path = "user://test_kala_play.json"
	for f in ["mq0_done", "mq1_10", "mqg_7", "mq2_9", "mq3_7", "mq3_h6", "choice_sink",
			"beat_escape", "beat_keris_sink",
			"beat_hunter_raid", "beat_laras_1", "beat_naga", "beat_galuh_bout", "beat_laras_2", "beat_cage", "beat_hunter_war",
			"beat_laras_3", "beat_ford", "beat_truce", "beat_laras_4", "beat_keris", "beat_hunter_shrine"]:
		game.flags[f] = true
	for q in ["mq1", "mqg", "mq2"]:
		game.quests[q] = {"state": "done", "step": 0, "count": 0, "resolution": ""}
	game.quests["mq3"] = {"state": "active", "step": 21, "count": 0, "resolution": ""}
	for g in ["sunda_ka", "sunda_ga", "jawa_na"]:
		game.run("learn:" + g)
	events.dialogue_requested.connect(_on_dialogue)
	change_scene_to_file(root.get_node("Zones").start_zone)
	await scene_changed
	await _settle()
	for i in 20:   # the wall tiles take a few physics frames to become solid after the first scene loads
		await physics_frame
	var ok: bool = check(_exit_to("gk_pelataran") != null and not _reachable(_cells_of(_exit_to("gk_pelataran"))), "Gua Kala gate open before mq4_9")
	if ok:   # the Hunter falls at tt_candi (Tanah Timur walk); the hunter_name beat then starts MQ4 (Act V comes before Gua Kala)
		events.boss_defeated.emit("nameless_hunter")
		await _drain()
	ok = ok and _expect("mq3=done") and check(game.has_flag("beat_hunter_name"), "hunter_name beat did not play") and _expect("mq4=active")
	# ponytail: Act V is walked by kidul_play_test; here MQ4 is finished by fiat, lifting the gate (kabut mq4_9, quests.md 4.22). The kidul beat starts MQ5.
	if ok:
		for f in ["mq4_2", "mq4_4", "mq4_8", "mq4_9", "beat_eclipse_home", "beat_laras_kidul"]:
			game.flags[f] = true
		game.quests["mq4"] = {"state": "done", "step": 22, "count": 0, "resolution": ""}
		game.changed.emit()
		await _drain()
		await root.get_node("Zones").go_to("desa_purwa", "from_riders")
		await _settle()
		ok = check(game.has_flag("beat_kidul"), "kidul beat did not play") and _expect("mq5=active:0")
		ok = ok and check(_exit_to("gk_pelataran") != null and _reachable(_cells_of(_exit_to("gk_pelataran"))), "Gua Kala gate still shut after MQ4")
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
	check(ep.index == 8, "epilogue stopped at line %d, want 8" % ep.index)
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
