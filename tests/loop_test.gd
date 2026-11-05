extends SceneTree
## Phase 3 exit loop, headless (schedule.md): new game as Warrior, kill for Ilmu, rest, level up,
## die, respawn at the petilasan with full HP, then a save round trip loses nothing.

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	await run()
	var game := root.get_node("Game")
	for f in [game.save_path, game.save_path.get_basename() + ".bak"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(f))   # this test's own files only
	game._reset()
	quit(1 if fails > 0 else 0)


func frames(n: int) -> void:
	for i in n:
		await process_frame


func until(cond: Callable, max_frames := 600) -> bool:
	for i in max_frames:
		if cond.call():
			return true
		await process_frame
	return false


func player() -> Player:
	return get_first_node_in_group("player") as Player


func run() -> void:
	var game := root.get_node("Game")
	var zones := root.get_node("Zones")
	game.save_path = "user://test_loop.json"
	game.new_game(ClassData.by_id("warrior"))
	check(game.equipped.weapon == "broadsword", "warrior starts with %s" % game.equipped.weapon)
	check(game.has_save(), "class choice did not create the save")

	zones.start_zone = "res://zones/hub.tscn"
	zones.start_new_game()
	check(await until(func() -> bool: return current_scene != null and current_scene.scene_file_path == zones.start_zone and player() != null),
		"new game never reached the hub")
	await frames(2)
	var p := player()
	check(p.item.id == "broadsword", "player wields %s" % (p.item.id if p.item else "nothing"))
	var hp0: int = p.health.max_hp

	# Kill: a normal chaser and the unique tank.
	var normal: EnemyBase
	var elite: EnemyBase
	for e in get_nodes_in_group("enemy"):
		if e.unique_id == "hub_elite":
			elite = e
		elif normal == null:
			normal = e
	check(normal != null and elite != null, "hub enemies missing")
	var before: int = game.ilmu
	normal.health.take_damage(9999, p, true)
	elite.health.take_damage(9999, p, true)
	check(game.ilmu == before + normal.ilmu + elite.ilmu, "ilmu %d after kills (was %d)" % [game.ilmu, before])
	check("hub_elite" in game.killed, "the unique tank was not recorded")

	# Rest: saves, reloads the zone, opens the menu with level-up.
	var pet: Petilasan = get_first_node_in_group("petilasan")
	var old_scene := current_scene.get_instance_id()   # ids, not nodes: lambdas must not capture freed nodes
	pet.rest()
	check(await until(func() -> bool: return current_scene and current_scene.get_instance_id() != old_scene and player() != null),
		"rest did not reload the zone")
	await frames(2)
	check(game.last_petilasan.id == "hub", "rest did not set the petilasan (%s)" % game.last_petilasan)
	var menu: GameMenu = get_first_node_in_group("game_menu")
	check(menu != null and menu.visible and paused, "rest did not open the paused menu")
	var tank_back := false
	for e in get_nodes_in_group("enemy"):
		tank_back = tank_back or e.unique_id == "hub_elite"
	check(not tank_back, "the unique tank came back after rest")
	check(get_nodes_in_group("enemy").size() == 3, "%d enemies after rest, want 3" % get_nodes_in_group("enemy").size())

	# Level up Vitality: +10 max HP on the live player.
	p = player()
	game.ilmu = game.level_cost()
	check(game.level_up("vit"), "level-up refused")
	check(p.health.max_hp == hp0 + 10, "max hp %d after vit, want %d" % [p.health.max_hp, hp0 + 10])
	menu.close()
	check(not paused, "closing the menu left the tree paused")

	# Die: the death screen respawns at the petilasan, full HP, nothing lost.
	var ilmu_kept: int = game.ilmu
	var killed_scene := current_scene.get_instance_id()
	p.health.take_damage(9999, null, true)
	check(await until(func() -> bool: return current_scene and current_scene.get_instance_id() != killed_scene and player() != null, 600),
		"death never respawned")
	await frames(2)
	p = player()
	check(p.health.hp == p.health.max_hp, "respawn hp %d/%d" % [p.health.hp, p.health.max_hp])
	check(p.global_position.distance_to(get_first_node_in_group("petilasan").global_position) < 32.0,
		"respawned at %s, not the petilasan" % p.global_position)
	check(game.ilmu == ilmu_kept and game.stats.vit == 9, "death changed ilmu or stats")

	# Rally survives a kill's stat recompute and undoes cleanly (a divide-to-undo left stats low for good).
	var a0: float = p.atk_speed
	var rally: Node2D = SpellData.for_glyph("jawa_ca").scene.instantiate()
	rally.caster = p
	rally.data = SpellData.for_glyph("jawa_ca")
	current_scene.add_child(rally)
	game.add_ilmu(1)
	check(is_equal_approx(p.atk_speed, a0 * 1.3), "rally lost to a recompute (%f, want %f)" % [p.atk_speed, a0 * 1.3])
	rally.queue_free()
	await frames(1)
	game.add_ilmu(1)
	check(is_equal_approx(p.atk_speed, a0), "rally left atk speed at %f, want %f" % [p.atk_speed, a0])

	# Save round trip.
	game.flask_charges = 1
	check(game.save_game(), "save failed")
	var want := JSON.stringify(game.to_dict())
	game._reset()
	check(game.load_game(), "load failed")
	check(JSON.stringify(game.to_dict()) == want, "round trip differs")
