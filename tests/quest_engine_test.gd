extends SceneTree
## Quest engine follow-ups (quests.md 7.1): `all` steps, glyph_learned catch-up, the zone: condition and the
## goto:, restore and lakon: actions. goto runs from both an NPC talk and a story beat.

var fails := 0
var entered: Array[String] = []
const PATH := "user://quest_engine_test.json"
const QDIR := "user://quest_engine_fixtures"
const ZA := "res://tests/fixtures/zone_a.tscn"
const ZB := "res://tests/fixtures/zone_b.tscn"


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func step(on: String, flag := "", all: Array = []) -> QuestStep:
	var s := QuestStep.new()
	s.on = on
	s.set_flag = flag
	s.all = all
	return s


func quest(id: String, steps: Array[QuestStep], rewards := {}) -> void:
	var q := QuestData.new()
	q.id = id
	q.zone = "tatar_sunda"
	q.size = "S"
	q.steps = steps
	q.rewards = rewards
	ResourceSaver.save(q, QDIR + "/%s.tres" % id)


func until(cond: Callable, seconds := 3.0) -> bool:
	var end := Time.get_ticks_msec() + int(seconds * 1000.0)
	while Time.get_ticks_msec() < end:
		if cond.call():
			return true
		await process_frame
	return cond.call()


func _initialize() -> void:
	await process_frame
	var g: Node = root.get_node("Game")
	var ev: Node = root.get_node("Events")
	var zones: Node = root.get_node("Zones")
	g.save_path = PATH
	DirAccess.make_dir_recursive_absolute(QDIR)
	QuestData.dir = QDIR
	g._reset()
	g.class_id = "warrior"
	ev.zone_entered.connect(func(id: String) -> void: entered.append(id))

	# 1. all step: any order, own flag and bit each, step completes (own flag) when all are done.
	# A trigger whose event happened before the step is not counted, except held items / known glyphs / unique kills.
	var trig := [{"on": "talked_to:a", "set_flag": "lead_a"}, {"on": "area_cleared:b", "set_flag": "lead_b"},
		{"on": "item_picked:c", "set_flag": "lead_c"}, {"on": "glyph_learned:sunda_ga", "set_flag": "lead_g"}]
	quest("e_all", [step("talked_to:start"), step("", "all_done", trig), step("talked_to:z")])
	g.add_item("c", false)
	g.start_quest("e_all")
	g.learn_glyph("sunda_ga")   # during step 0: not current yet, caught up when the all step starts
	ev.talked_to.emit("a")      # during step 0: must not count later
	ev.talked_to.emit("start")
	check(g.quests.e_all.step == 1 and g.quests.e_all.all == 0b1100, "all catch-up (item, glyph only): %s" % g.quests.e_all)
	check(g.has_flag("lead_c") and g.has_flag("lead_g") and not g.has_flag("lead_a"), "all catch-up flags")
	ev.area_cleared.emit("b")
	check(g.quests.e_all.all == 0b1110 and g.has_flag("lead_b") and not g.has_flag("all_done"), "all: one trigger: %s" % g.quests.e_all)
	ev.area_cleared.emit("b")   # a repeat changes nothing
	check(g.quests.e_all.step == 1, "all: repeat completed the step")
	ev.talked_to.emit("a")
	check(g.quests.e_all.step == 2 and g.quests.e_all.all == 0 and g.has_flag("all_done") and g.has_flag("lead_a"), "all: last trigger: %s" % g.quests.e_all)
	# Every trigger already met when the step becomes current: completes at once.
	g.killed.append("boss_q")
	quest("e_all2", [step("", "all2_done", [{"on": "boss_defeated:boss_q"}, {"on": "item_picked:c"}]), step("talked_to:z")])
	g.start_quest("e_all2")
	check(g.quests.e_all2.step == 1 and g.has_flag("all2_done"), "all: fully caught up step: %s" % g.quests.e_all2)

	# 2. glyph_learned catch-up, as the first step and as a later step.
	quest("e_gl", [step("glyph_learned:sunda_ga", "gl_1"), step("talked_to:y"), step("glyph_learned:sunda_ga"), step("talked_to:z")])
	g.start_quest("e_gl")
	check(g.quests.e_gl.step == 1 and g.has_flag("gl_1"), "glyph catch-up at start: %s" % g.quests.e_gl)
	ev.talked_to.emit("y")
	check(g.quests.e_gl.step == 3, "glyph catch-up on a later step: %s" % g.quests.e_gl)
	quest("e_gl2", [step("glyph_learned:sunda_ka"), step("talked_to:z")])
	g.start_quest("e_gl2")
	check(g.quests.e_gl2.step == 0, "an unknown glyph was caught up")
	g.learn_glyph("sunda_ka")
	check(g.quests.e_gl2.step == 1, "glyph_learned did not fire the step")

	# 6. lakon: sets the same flag as a quest reward lakon.
	quest("e_lk", [], {"lakon": "sangkuriang"})
	g.start_quest("e_lk")
	check(g.has_flag("lakon:sangkuriang"), "reward lakon flag")
	g.run("lakon:lutung")
	check(g.has_flag("lakon:lutung"), "lakon: action did not set lakon:lutung")

	# 4. goto from an NPC talk (last action): after the box closes, zone changes to the spawn, zone_entered fires.
	var d := DialogueData.new()
	d.npc_id = "t"
	d.name_key = "N"
	d.entries = [{"lines": ["A"], "do": ["flag:goto_npc", "goto:%s:west" % ZB]}]
	var npc: Npc = load("res://entities/npc/npc.tscn").instantiate()
	npc.npc_id = "t"
	npc.data = d
	root.add_child(npc)
	var talked := []
	ev.talked_to.connect(func(id: String) -> void: talked.append(id))
	npc.interact()
	await process_frame
	check(zones.current_zone == "" and entered.is_empty(), "goto moved before the box closed")
	ev.dialogue_finished.emit()
	check(await until(func() -> bool: return zones.current_zone == "fixture_b" and not zones._busy), "npc goto never reached fixture_b")
	check(await until(func() -> bool: return "fixture_b" in entered), "npc goto: no zone_entered")
	check("t" in talked, "npc goto: talked_to not fired")
	var pl: Node2D = get_first_node_in_group("player")
	var w: Node2D = current_scene.spawn("west")
	check(pl != null and w != null and pl.global_position == w.global_position, "npc goto: player not on spawn west")
	npc.queue_free()

	# 3. zone: condition.
	check(g.check("zone:fixture_b") and not g.check("zone:fixture_a") and g.check("!zone:fixture_a"), "zone: condition")

	# 5. restore: HP, stamina, flask full; no save, no zone reload.
	pl.health.hp = 1
	pl.stamina.value = 0.0
	g.flask_charges = 0
	var saves := [0]
	g.saved.connect(func() -> void: saves[0] += 1)
	var scene := current_scene
	g.run("restore")
	check(pl.health.hp == pl.health.max_hp and pl.stamina.value == pl.stamina.max_stamina and g.flask_charges == g.flask_max,
		"restore: hp %d/%d st %d/%d flask %d/%d" % [pl.health.hp, pl.health.max_hp, pl.stamina.value, pl.stamina.max_stamina, g.flask_charges, g.flask_max])
	await process_frame
	check(saves[0] == 0 and current_scene == scene, "restore saved or reloaded the zone")

	# 4b. goto as the last action of a story beat.
	var sb: Node = load("res://ui/story_beat.gd").new()
	root.add_child(sb)
	var bd := DialogueData.new()
	bd.entries = [{"if": ["!flag:beat_t"], "lines": ["L"], "do": ["flag:beat_t", "goto:%s:start" % ZA]}]
	sb._data = bd
	entered.clear()
	sb._try()
	await process_frame
	ev.dialogue_finished.emit()
	check(await until(func() -> bool: return zones.current_zone == "fixture_a" and not zones._busy), "beat goto never reached fixture_a")
	check(await until(func() -> bool: return "fixture_a" in entered), "beat goto: no zone_entered")
	check(g.has_flag("beat_t"), "beat goto: beat flag")
	pl = get_first_node_in_group("player")
	var s: Node2D = current_scene.spawn("start")
	check(pl != null and s != null and pl.global_position == s.global_position, "beat goto: player not on spawn start")
	sb.queue_free()

	for p in [PATH, "user://quest_engine_test.bak", PATH + ".tmp"]:
		DirAccess.remove_absolute(p)
	for f in DirAccess.get_files_at(QDIR):
		DirAccess.remove_absolute(QDIR + "/" + f)
	DirAccess.remove_absolute(QDIR)
	g._reset()
	quit(1 if fails > 0 else 0)
