extends SceneTree
## Kelir memory (architecture.md 9b), headless. Every zones/kelir/*.tscn loads and has a Stand. A fixture memory
## (Stand, ordered spots, a narrate spot, a checkpoint, a threat on a path): enter stores memory_return and saves,
## no saves inside, ordered spots, fail resets to Stand then to the checkpoint, a threat touch fails, finish sets
## the flag, emits memory_done and exit restores zone and position. A gap memory: wrong picks, the starred hint
## after 2, the right pick sets flag:gap_<id> and finishes. Continue from a save with a memory_return lands there.

const A := "res://tests/fixtures/zone_a.tscn"
const MEM := "user://memory_test_fixture.tscn"
const GAP := "user://memory_test_gap.tscn"

var fails := 0
var done: Array[String] = []
var started: Array[String] = []


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	var g: Node = root.get_node("Game")
	g.save_path = "user://memory_test.json"
	g._reset()
	g.class_id = "warrior"
	var ev := root.get_node("Events")
	ev.memory_done.connect(func(id: String) -> void: done.append(id))
	ev.memory_started.connect(func(id: String) -> void: started.append(id))
	await run()
	for p in [MEM, GAP, g.save_path, "user://memory_test.bak"]:
		DirAccess.remove_absolute(p)
	g._reset()
	quit(1 if fails > 0 else 0)


func frames(n: int) -> void:
	for i in n:
		await process_frame


func until(cond: Callable, seconds := 3.0) -> bool:
	var end := Time.get_ticks_msec() + int(seconds * 1000.0)
	while Time.get_ticks_msec() < end:
		if cond.call():
			return true
		await process_frame
	return cond.call()


func press(action: String) -> void:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = true
	Input.parse_input_event(e)
	await frames(2)
	var up := InputEventAction.new()
	up.action = action
	Input.parse_input_event(up)   # released, or a held move_down walks the next player off
	await frames(1)


func stand_in() -> Node2D:
	return current_scene.stand_in if current_scene is KelirMemory else null


func saved() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(root.get_node("Game").save_path))


func run() -> void:
	var g: Node = root.get_node("Game")
	var zones: Node = root.get_node("Zones")

	# Every memory scene loads and has a Stand marker.
	var dir := "res://zones/kelir/"
	for f in DirAccess.get_files_at(dir):
		if f.trim_suffix(".remap").ends_with(".tscn") and not f.begins_with("memory_spot") and not f.begins_with("memory_threat"):
			var n: Node = load(dir + f.trim_suffix(".remap")).instantiate()
			check(n is KelirMemory and n.find_child("Stand", true, false) is Node2D, "%s: not a KelirMemory with a Stand" % f)
			n.free()
	check(zones.memory_path("k1_maghrib") == "res://zones/kelir/k1_maghrib.tscn", "memory_path: %s" % zones.memory_path("k1_maghrib"))
	check(zones.gap_data_path("la") == "res://data/memories/gap_la.tres" and zones.gap_data_path("gap_la") == "res://data/memories/gap_la.tres", "gap_data_path")

	# Enter from zone A.
	_fixture()
	zones.go_to(A, "start")
	check(await until(func() -> bool: return zones.current_zone == "fixture_a" and get_first_node_in_group("player") != null), "zone A never loaded")
	await frames(2)
	var player := get_first_node_in_group("player") as Player
	player.global_position = Vector2(150, 70)
	player.health.hp = 50
	zones.enter_memory(MEM)
	check(started == [MEM], "memory_started: %s" % [started])
	var sv := saved()
	check(sv.get("memory_return", {}).get("zone") == A, "the save at the clue lacks memory_return: %s" % sv.get("memory_return"))
	check(await until(func() -> bool: return current_scene is KelirMemory and not zones._busy), "enter_memory never reached the memory")
	await physics_frame
	var m: KelirMemory = current_scene
	var stand: Node2D = m.get_node("Stand")
	check(stand_in() != null and stand_in().is_in_group("player") and get_nodes_in_group("player").size() == 1, "no single stand-in in group player")
	check(stand_in().global_position == stand.global_position, "stand-in not at Stand: %s" % stand_in().global_position)
	check(m.memory_id == MEM and m.kind == "play", "memory id/kind: %s %s" % [m.memory_id, m.kind])
	check(g.in_memory() and not g.save_game(), "a save went through inside a memory")
	var hud := m.find_child("HUD", true, false)
	check(hud != null and not hud.visible, "HUD shown in a memory")

	# Ordered spots: second before first does nothing.
	var s0: MemorySpot = m.get_node("Spot0")
	var s1: MemorySpot = m.get_node("Spot1")
	s1.interact()
	check(not s1.done, "order 1 spot done before order 0")
	s0.interact()
	check(s0.done and not s1.done, "order 0 spot not done: %s %s" % [s0.done, s1.done])
	check(not m._done, "finish before every spot was done")

	# Threat on a path moves.
	var th: MemoryThreat = m.get_node("Threat")
	var p0 := th.global_position
	await frames(20)
	check(th.global_position != p0, "threat on a path does not move")

	# fail() with no checkpoint reached: back to Stand.
	stand_in().global_position = Vector2(300, 200)
	m.fail()
	check(await until(func() -> bool: return not m._busy), "fail never ended")
	check(stand_in().global_position == stand.global_position, "fail without checkpoint: %s" % stand_in().global_position)

	# Reach the checkpoint, then a threat touch: back at the checkpoint.
	var cp: Node2D = m.get_node("Checkpoint1")
	stand_in().global_position = cp.global_position
	await physics_frame
	await physics_frame
	check(m.checkpoint == cp, "checkpoint not reached")
	stand_in().global_position = th.global_position
	check(await until(func() -> bool: return m._busy), "touching the threat did not fail")
	check(await until(func() -> bool: return not m._busy), "threat fail never ended")
	check(stand_in().global_position == cp.global_position, "threat fail did not reset to the checkpoint: %s" % stand_in().global_position)

	# The narrate spot never counts; the last ordered spot finishes the memory.
	s1.interact()
	check(s1.done and m._done, "last spot did not finish")
	check(await until(func() -> bool: return zones.current_zone == "fixture_a" and get_first_node_in_group("player") is Player), "exit_memory did not return to zone A")
	await frames(2)
	player = get_first_node_in_group("player") as Player
	check(player.global_position == Vector2(150, 70), "exit did not restore the position: %s" % player.global_position)
	check(player.health.hp == 50, "exit did not keep the hero's hp: %d" % player.health.hp)
	check(done == [MEM] and g.has_flag("memory_" + MEM), "finish: memory_done %s, flag %s" % [done, g.has_flag("memory_" + MEM)])
	check(await until(func() -> bool: return g.memory_return.is_empty() and saved().get("memory_return", {"x": 1}).is_empty()), "memory_return not cleared and saved")
	check(saved().get("flags", {}).get("memory_" + MEM, false) == true, "the memory flag was not saved on exit")

	await _gap()

	# Continue from a save with a memory_return: player there, memory_return cleared.
	g.memory_return = {"zone": A, "pos": [200.0, 100.0]}
	check(g.save_game(), "save before continue failed")
	g._reset()
	check(g.load_game() and g.memory_return.get("zone") == A, "memory_return did not load")
	zones.continue_game()
	check(await until(func() -> bool: return zones.current_zone == "fixture_a" and not zones._busy and get_first_node_in_group("player") != null), "continue did not load zone A")
	await frames(2)
	check((get_first_node_in_group("player") as Node2D).global_position == Vector2(200, 100), "continue not at memory_return: %s" % (get_first_node_in_group("player") as Node2D).global_position)
	check(g.memory_return.is_empty(), "memory_return kept after continue")


func _gap() -> void:
	var g: Node = root.get_node("Game")
	var zones: Node = root.get_node("Zones")
	_gap_fixture()
	(get_first_node_in_group("player") as Node2D).global_position = Vector2(100, 60)
	done.clear()
	zones.enter_memory(GAP)
	check(await until(func() -> bool: return current_scene is KelirMemory and not zones._busy), "gap memory not entered")
	await frames(2)
	var m: KelirMemory = current_scene
	check(m.kind == "gap" and m.memory_id == "fx", "gap memory id from data: %s" % m.memory_id)
	var spots := m.spots()
	check(spots.size() == 1 and spots[0].action_kind == "gap" and spots[0].position == Vector2(5 * 16 + 8, 4 * 16 + 8), "gap spot: %s" % [spots])
	var s: MemorySpot = spots[0]
	var box: Control = get_first_node_in_group("dialogue_box")
	for attempt in 3:
		s.interact()
		await frames(2)
		check(box.is_open(), "gap prompt did not open")
		for i in 6:
			if box._choosing:
				break
			await press("interact")
		check(box._choosing and box._opts.size() == 3, "gap choices: %s" % box._opts)
		var starred: bool = box._opts[1].begins_with("* ")
		check(starred == (attempt == 2), "attempt %d: right option starred %s (%s)" % [attempt, starred, box._opts])
		var pick := 1 if attempt == 2 else 2   # wrong, wrong, right
		for i in pick:
			await press("move_down")
		await press("interact")
		await frames(2)
		if attempt < 2:
			check(not g.has_flag("gap_fx_a") and not s.done and s.wrong == attempt + 1 and s._rect.visible, "wrong pick %d: gap closed or flag set" % attempt)
			check(s._rect.modulate != Color.WHITE, "wrong pick did not flash")
			await until(func() -> bool: return not s._busy)
	check(g.has_flag("gap_fx_a") and s.done, "right pick did not set flag:gap_fx_a")
	check(await until(func() -> bool: return zones.current_zone == "fixture_a" and not zones._busy), "gap finish did not return")
	check(done == ["fx"] and g.has_flag("memory_fx"), "gap memory_done: %s" % [done])


## Stand (20,20); Spot0 order 0, Spot1 order 1, a narrate spot; Checkpoint1 at (200,40); a threat on a path far away.
func _fixture() -> void:
	var m := KelirMemory.new()
	m.name = "FixtureMemory"
	_add(m, Marker2D.new(), "Stand", Vector2(20, 20))
	_add(m, Marker2D.new(), "Checkpoint1", Vector2(200, 40))
	var spot: PackedScene = load("res://zones/kelir/memory_spot.tscn")
	for i in 2:
		var s: MemorySpot = spot.instantiate()
		s.order = i
		_add(m, s, "Spot%d" % i, Vector2(60 + i * 40, 200))
	var nar: MemorySpot = spot.instantiate()
	nar.action_kind = "narrate"
	_add(m, nar, "Narrate", Vector2(400, 20))
	var th: Node2D = load("res://zones/kelir/memory_threat.tscn").instantiate()
	_add(m, th, "Threat", Vector2(380, 200))
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2.ZERO)
	path.curve.add_point(Vector2(0, -40))
	th.add_child(path)
	path.owner = m
	var ps := PackedScene.new()
	ps.pack(m)
	ResourceSaver.save(ps, MEM)
	m.free()


## gap.tscn with one gap at tile (5,4): options a/b/c, b is right.
func _gap_fixture() -> void:
	var m: KelirMemory = load("res://zones/kelir/gap.tscn").instantiate()
	var d := GapMemoryData.new()
	d.memory_id = "fx"
	d.gaps = [{"gap_id": "fx_a", "pos": Vector2i(5, 4), "prompt_key": "GAP_FX_A_P", "options": ["GAP_FX_A_1", {"key": "GAP_FX_A_2"}, "GAP_FX_A_3"], "correct": "GAP_FX_A_2"}]
	m.data = d
	var ps := PackedScene.new()
	ps.pack(m)
	ResourceSaver.save(ps, GAP)
	m.free()


func _add(m: Node, n: Node, nm: String, pos: Vector2) -> void:
	n.name = nm
	n.position = pos
	m.add_child(n)
	n.owner = m
