extends SceneTree
## Zone system, headless (architecture.md 9): ASCII build and collision, spot props, camera bounds,
## trigger, kabut lifting, a 2-wave encounter, an exit into another zone, and next_zone BFS.

const A := "res://tests/fixtures/zone_a.tscn"

var fails := 0
var entered: Array[String] = []
var cleared: Array[String] = []
var triggered: Array[String] = []


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	var game := root.get_node("Game")
	game._reset()
	var ev := root.get_node("Events")
	ev.zone_entered.connect(func(id: String) -> void: entered.append(id))
	ev.area_cleared.connect(func(id: String) -> void: cleared.append(id))
	ev.area_entered.connect(func(id: String) -> void: triggered.append(id))
	await run()
	game._reset()
	quit(1 if fails > 0 else 0)


func frames(n: int) -> void:
	for i in n:
		await process_frame


## Headless runs unthrottled (~150 fps), so waits are in real seconds, not frames.
func until(cond: Callable, seconds := 3.0) -> bool:
	var end := Time.get_ticks_msec() + int(seconds * 1000.0)
	while Time.get_ticks_msec() < end:
		if cond.call():
			return true
		await process_frame
	return cond.call()


func player() -> Player:
	return get_first_node_in_group("player") as Player


func by_scene(path: String) -> Array:
	return current_scene.entities.get_children().filter(func(n: Node) -> bool: return n.scene_file_path == path)


func solid_at(cell: Vector2i) -> bool:
	var q := PhysicsPointQueryParameters2D.new()
	q.position = Vector2(cell * 16) + Vector2(8, 8)
	q.collision_mask = 1
	return not current_scene.get_world_2d().direct_space_state.intersect_point(q).is_empty()


func run() -> void:
	var zones := root.get_node("Zones")
	var game := root.get_node("Game")

	# BFS over ADJ.
	check(zones.next_zone("desa_purwa", "tatar_sunda") == "tatar_sunda", "desa_purwa -> tatar_sunda")
	check(zones.next_zone("tatar_sunda", "mataram") == "desa_purwa", "tatar_sunda -> mataram should go via desa_purwa")
	check(zones.next_zone("tatar_sunda", "nowhere") == "", "unknown target")
	check(zones.next_zone("nowhere", "tatar_sunda") == "", "unknown start")
	check(zones.next_zone("tatar_sunda", "tatar_sunda") == "", "same zone")

	# Build.
	zones.go_to(A, "start")
	check(await until(func() -> bool: return zones.current_zone == "fixture_a" and player() != null),
		"go_to never reached fixture A")
	await physics_frame
	await physics_frame
	var z: Zone = current_scene
	check(z.size == Vector2i(60, 34), "fixture A size %s" % z.size)
	var want := {Vector2i(0, 0): 4, Vector2i(5, 5): 0, Vector2i(2, 4): 1, Vector2i(3, 4): 5, Vector2i(4, 4): 6,
		Vector2i(5, 4): 2, Vector2i(6, 4): 7, Vector2i(7, 4): 3, Vector2i(10, 2): 1}
	for cell: Vector2i in want:
		check(z.tiles.get_cell_atlas_coords(cell) == Vector2i(want[cell], 0),
			"tile at %s is %s, want %d" % [cell, z.tiles.get_cell_atlas_coords(cell), want[cell]])
	for cell in [Vector2i(0, 0), Vector2i(3, 4), Vector2i(4, 4), Vector2i(6, 4)]:
		check(solid_at(cell), "tile %s does not collide" % cell)
	for cell in [Vector2i(5, 5), Vector2i(2, 4), Vector2i(5, 4), Vector2i(7, 4)]:
		check(not solid_at(cell), "walkable tile %s collides" % cell)
	check(z.find_child("GameUI", true, false) != null, "the zone did not add the UI")
	var p := player()
	check(p.get_parent() == z.entities, "player is not in Entities")
	check(p.global_position == Vector2(40, 40), "player at %s, not spawn start" % p.global_position)
	await frames(2)
	check(entered == ["fixture_a"], "zone_entered: %s" % [entered])

	# Spot props.
	var exits := by_scene("res://entities/world/exit.tscn")
	check(exits.size() == 1 and exits[0].spawn_id == "west" and exits[0].position == Vector2(952, 88),
		"exit spot missing or wrong props")
	var trig := by_scene("res://entities/world/trigger.tscn")
	check(trig.size() == 1 and trig[0].trigger_id == "fx_trig", "trigger spot missing or wrong props")
	var enc := by_scene("res://entities/world/encounter.tscn")
	check(enc.size() == 1 and enc[0].area_id == "fx_area" and enc[0].waves.size() == 2, "encounter props")

	# Camera at the top-left corner stays inside the map.
	await frames(5)
	var cam: Camera2D = p.get_node("Camera")
	var vp := cam.get_viewport_rect().size
	var view := Rect2(cam.get_screen_center_position() - vp / 2.0, vp)
	check(z.map_rect().encloses(view), "camera view %s leaves the map %s" % [view, z.map_rect()])

	# Trigger fires on entry.
	p.health.set_invincible(120.0)
	p.global_position = trig[0].global_position
	check(await until(func() -> bool: return not triggered.is_empty(), 1.0) and triggered == ["fx_trig"],
		"area_entered: %s" % [triggered])

	# Kabut lifts when its flag is set after load.
	var fog: Node = by_scene("res://entities/world/kabut.tscn")[0]
	await frames(3)
	check(is_instance_valid(fog), "kabut gone before its flag was set")
	game.flags["fx_fog"] = true
	game.changed.emit()
	var fog_id := fog.get_instance_id()
	check(await until(func() -> bool: return not is_instance_id_valid(fog_id)), "kabut did not lift")

	# Encounter: 2 waves, area_cleared once, only after wave 2.
	p.global_position = enc[0].global_position
	check(await until(func() -> bool: return get_nodes_in_group("enemy").size() == 2, 1.0), "wave 1 did not spawn")
	for e in get_nodes_in_group("enemy"):
		e.health.take_damage(9999, p, true)
	await process_frame
	var marks := z.entities.get_children().filter(func(n: Node) -> bool: return n is Polygon2D)
	check(marks.size() == 1, "%d wave-2 warnings, want 1" % marks.size())
	check(cleared.is_empty(), "area_cleared after wave 1")
	await frames(10)
	check(get_nodes_in_group("enemy").is_empty(), "wave 2 skipped its warning")
	check(await until(func() -> bool: return get_nodes_in_group("enemy").size() == 1, 2.0), "wave 2 did not spawn")
	check(cleared.is_empty(), "area_cleared before wave 2 died")
	for e in get_nodes_in_group("enemy"):
		e.health.take_damage(9999, p, true)
	await frames(30)
	check(cleared == ["fx_area"], "area_cleared: %s" % [cleared])
	p.global_position = Vector2(100, 100)
	await frames(3)
	p.global_position = enc[0].global_position
	await frames(30)
	check(cleared.size() == 1 and get_nodes_in_group("enemy").is_empty(), "encounter ran twice")

	# Exit into fixture B at spawn "west".
	p.global_position = exits[0].global_position
	check(await until(func() -> bool: return zones.current_zone == "fixture_b" and not zones._busy and player() != null),
		"exit did not reach fixture B")
	var w: Node2D = current_scene.spawn("west")
	check(w != null and player().global_position == w.global_position,
		"player at %s, not spawn west" % player().global_position)
	await frames(2)
	check(entered == ["fixture_a", "fixture_b"], "zone_entered: %s" % [entered])

	# Kabut with a flag set before load is absent; one with no flag stays.
	var fogs := by_scene("res://entities/world/kabut.tscn").filter(func(n: Node) -> bool: return not n.is_queued_for_deletion())
	check(fogs.size() == 1 and fogs[0].flag == "", "fixture B kabut: %s" % [fogs.map(func(n: Node) -> String: return n.flag)])
	await frames(20)   # fade-in finishes before the tree goes
