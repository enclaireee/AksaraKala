extends SceneTree
## Clue (architecture.md 9b): cond hides it, examining plays the lines then sets flag clue_<id>, emits clue_examined
## (a quest step matches it) and enters its memory; finishing that memory emits memory_done (the next step matches),
## and an examined clue stays in the interactable group and examinable. Also the `clue:` action.

const A := "res://tests/fixtures/zone_a.tscn"
const MEM := "user://clue_test_memory.tscn"
const QDIR := "user://clue_test_quests"

var fails := 0
var examined: Array[String] = []
var done: Array[String] = []


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	var g: Node = root.get_node("Game")
	g.save_path = "user://clue_test.json"
	g._reset()
	var ev := root.get_node("Events")
	ev.clue_examined.connect(func(id: String) -> void: examined.append(id))
	ev.memory_done.connect(func(id: String) -> void: done.append(id))
	await run()
	for p in [MEM, QDIR + "/cq.tres", QDIR, g.save_path, "user://clue_test.bak"]:
		DirAccess.remove_absolute(p)
	g._reset()
	QuestData.dir = "res://data/quests"
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


func run() -> void:
	var g: Node = root.get_node("Game")
	var zones: Node = root.get_node("Zones")
	_quest()
	g.class_id = "warrior"
	check(g.start_quest("cq"), "quest cq did not start")

	# The action alone.
	g.run("clue:act")
	check(g.has_flag("clue_act") and examined == ["act"], "clue: action: flag %s, signals %s" % [g.has_flag("clue_act"), examined])
	check(g.quests.cq.step == 0, "clue_examined:act matched the cq step for fx_clue")

	_memory_fixture()
	zones.go_to(A, "start")
	check(await until(func() -> bool: return zones.current_zone == "fixture_a" and get_first_node_in_group("player") != null), "zone A never loaded")
	await frames(2)
	var player := get_first_node_in_group("player") as Node2D
	player.global_position = Vector2(120, 90)

	var clue: Clue = load("res://entities/world/clue.tscn").instantiate()
	clue.clue_id = "fx_clue"
	clue.memory_id = MEM
	clue.cond = "flag:fx_seen"
	clue.position = Vector2(140, 90)
	current_scene.add_child(clue)
	await frames(1)
	check(not clue.visible and not clue.usable, "clue with a false cond is shown")
	g.set_flag("fx_seen")
	check(clue.visible and clue.usable, "clue did not show once its cond held")
	check(clue.is_in_group("interactable"), "clue not in the interactable group")
	check(clue._lines().is_empty(), "a memory clue with no CLUE keys should pull straight in: %s" % clue._lines())
	var t := Translation.new()
	t.locale = TranslationServer.get_locale()
	t.add_message("CLUE_FX_CLUE_1", "A thought.")
	TranslationServer.add_translation(t)
	check(clue._lines() == PackedStringArray(["CLUE_FX_CLUE_1"]), "default lines: %s" % clue._lines())

	# Examine: one line in the real box, then flag, signal, quest step, memory.
	var box: Control = get_first_node_in_group("dialogue_box")
	clue.interact()
	await frames(2)
	check(box != null and box.is_open(), "examining opened no dialogue box")
	check(not clue.usable, "clue usable while its lines run")
	check(not g.has_flag("clue_fx_clue"), "flag set before the lines finished")
	for i in 4:
		if box.is_open():
			await press("interact")
	check(not box.is_open(), "dialogue did not close")
	check(g.has_flag("clue_fx_clue") and examined.has("fx_clue"), "examined: flag %s, signals %s" % [g.has_flag("clue_fx_clue"), examined])
	check(g.quests.cq.step == 1, "clue_examined:fx_clue did not advance cq: %s" % g.quests.cq)
	check(await until(func() -> bool: return current_scene is KelirMemory), "the clue did not enter its memory")
	check(g.memory_return.get("zone") == A and Vector2(g.memory_return.pos[0], g.memory_return.pos[1]) == Vector2(120, 90),
		"memory_return: %s" % g.memory_return)

	# Finish: memory_done advances the quest, flag memory_<id>, back in zone A at the clue spot.
	current_scene.finish()
	check(await until(func() -> bool: return zones.current_zone == "fixture_a" and get_first_node_in_group("player") is Player), "finish did not return to zone A")
	check(done == [MEM] and g.has_flag("memory_" + MEM), "memory_done: %s" % [done])
	check(g.quest_state("cq") == "done", "memory_done:<id> did not finish cq: %s" % g.quests.cq)
	await frames(2)

	# An examined clue at _ready stays in the group, replays, emits again, does not re-enter its memory.
	var again: Clue = load("res://entities/world/clue.tscn").instantiate()
	again.clue_id = "fx_clue"
	again.memory_id = MEM
	again.lines = PackedStringArray(["CLUE_FX_CLUE_2"])
	current_scene.add_child(again)
	await frames(1)
	check(again.is_in_group("interactable") and again.usable, "examined clue left the group or is not usable")
	box = get_first_node_in_group("dialogue_box")
	again.interact()
	await frames(2)
	check(box.is_open() and box._text.text == "CLUE_FX_CLUE_2", "replay did not show the line: '%s'" % box._text.text)
	for i in 4:
		if box.is_open():
			await press("interact")
	await frames(10)
	check(examined.count("fx_clue") == 2, "replay did not emit clue_examined again: %s" % [examined])
	check(not current_scene is KelirMemory and zones.current_zone == "fixture_a", "a done memory was entered again")
	await until(func() -> bool: return not zones._busy, 1.0)


## A memory with a Stand only.
func _memory_fixture() -> void:
	var m := KelirMemory.new()
	m.name = "ClueMemory"
	var s := Marker2D.new()
	s.name = "Stand"
	s.position = Vector2(40, 40)
	m.add_child(s)
	s.owner = m
	var ps := PackedScene.new()
	ps.pack(m)
	ResourceSaver.save(ps, MEM)
	m.free()


## cq: clue_examined:fx_clue, then memory_done:<MEM>.
func _quest() -> void:
	DirAccess.make_dir_recursive_absolute(QDIR)
	QuestData.dir = QDIR
	var a := QuestStep.new()
	a.on = "clue_examined:fx_clue"
	var b := QuestStep.new()
	b.on = "memory_done:" + MEM
	var q := QuestData.new()
	q.id = "cq"
	q.kind = "main"
	q.steps = [a, b]
	ResourceSaver.save(q, QDIR + "/cq.tres")
