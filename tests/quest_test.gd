extends SceneTree
## Quest engine in Game (quests.md 7): only the active step advances, counts, flags, rewards with caps,
## codex on first kill, dialogue check/run, pinning, save round trip and malformed saves.

var fails := 0
const PATH := "user://quest_test.json"
const QDIR := "user://quest_fixtures"
const CDIR := "user://codex_fixtures"


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func step(on: String, count := 1, flag := "", marker := {}) -> QuestStep:
	var s := QuestStep.new()
	s.on = on
	s.count = count
	s.set_flag = flag
	s.marker = marker
	return s


func quest(id: String, steps: Array[QuestStep], rewards := {}, requires: Array[String] = []) -> void:
	var q := QuestData.new()
	q.id = id
	q.zone = "tatar_sunda"
	q.size = "S"
	q.steps = steps
	q.rewards = rewards
	q.requires = requires
	ResourceSaver.save(q, QDIR + "/%s.tres" % id)


func _initialize() -> void:
	await process_frame
	var g: Node = root.get_node("Game")
	var ev: Node = root.get_node("Events")
	g.save_path = PATH
	DirAccess.make_dir_recursive_absolute(QDIR)
	DirAccess.make_dir_recursive_absolute(CDIR)
	QuestData.dir = QDIR
	CodexEntry.dir = CDIR
	var c := CodexEntry.new()
	c.id = "wild_boar"
	c.category = "enemy"
	ResourceSaver.save(c, CDIR + "/wild_boar.tres")
	quest("t_a", [step("enemy_killed:wild_boar", 3, "ta_1"), step("talked_to:cepot")],
		{"items": ["golok"], "flask_shard": 1, "herb_pouch": 1, "lakon": "x", "flags": ["ta_done"], "codex": ["c1"]})
	var req: Array[String] = ["ta_done"]
	quest("t_b", [step("class_chosen")], {"flask_shard": 1}, req)
	quest("t_c", [step("area_entered:spring", 1, "", {"zone": "tatar_sunda", "id": "spring"})])
	quest("t_d", [step("item_picked:ang_*", 3), step("talked_to:z")])
	g._reset()
	g.class_id = "warrior"

	var log := []
	for s in ["quest_started", "quest_updated", "quest_completed"]:
		ev.connect(s, func(id: String) -> void: log.append(s + ":" + id))

	check(g.quest_state("t_a") == "available" and g.quest_state("t_b") == "locked" and g.quest_state("nope") == "locked", "initial states")
	ev.talked_to.emit("cepot")
	check(not g.quests.has("t_a"), "an event touched a quest that was not started")
	check(g.start_quest("t_a") and g.quest_state("t_a") == "active" and not g.start_quest("t_a"), "start_quest")
	check(not g.start_quest("t_b"), "a locked quest started")

	# Only the current step listens.
	ev.talked_to.emit("cepot")
	check(g.quests.t_a.step == 0, "a later step advanced early")
	var boar_script := GDScript.new()
	boar_script.source_code = "extends Node2D\nvar kind := \"wild_boar\""
	boar_script.reload()
	var boar: Node2D = boar_script.new()
	ev.enemy_killed.emit(boar, 9)
	ev.enemy_killed.emit(boar, 9)
	check(g.quests.t_a.step == 0 and g.quests.t_a.count == 2, "count: %s" % g.quests.t_a)
	check("wild_boar" in g.codex, "first kill did not unlock the codex entry")
	ev.enemy_killed.emit(boar, 9)
	check(g.quests.t_a.step == 1 and g.has_flag("ta_1"), "step 1 did not complete on the 3rd kill or set its flag")
	boar.free()

	# Completion and rewards.
	var ilmu: int = g.ilmu
	ev.talked_to.emit("cepot")
	check(g.quest_state("t_a") == "done", "t_a not done")
	check(g.ilmu == ilmu + 30, "S quest in Tatar Sunda gave %d Ilmu" % (g.ilmu - ilmu))
	check("golok" in g.inventory and g.flask_max == 4 and g.herb_pouches == 1, "item, shard or pouch missing")
	check(g.has_flag("ta_done") and g.has_flag("lakon:x") and "c1" in g.codex, "flags, lakon or codex reward missing")
	check(log == ["quest_started:t_a", "quest_updated:t_a", "quest_updated:t_a", "quest_updated:t_a", "quest_completed:t_a"], "events: %s" % [log])

	# requires unlocks; a bare signal matches any arg; the flask cap holds at 6.
	check(g.quest_state("t_b") == "available" and g.start_quest("t_b"), "t_b did not unlock")
	g.flask_max = 6
	ev.class_chosen.emit("mage")
	check(g.quest_state("t_b") == "done" and g.flask_max == 6, "bare signal or flask cap (max %d)" % g.flask_max)

	# Pinning and the marker.
	g.start_quest("t_c")
	check(g.objective_marker().is_empty(), "marker without a pin or main quest")
	g.pin_quest("t_c")
	check(g.pinned == "t_c" and g.objective_marker().get("id") == "spring", "pinned marker")
	g.pin_quest("t_a")
	check(g.pinned == "", "pinned a finished quest")
	g.pin_quest("t_c")

	# Dialogue conditions and actions.
	check(g.check("quest:t_a=done") and g.check("step:t_c=0") and not g.check("step:t_c=1"), "quest/step conditions")
	check(g.check("!flag:nope") and g.check("flag:ta_done") and not g.check("glyph:sunda_ka"), "flag/glyph conditions")
	var learned := []
	ev.glyph_learned.connect(func(id: String) -> void: learned.append(id))
	g.run("learn:sunda_ka")
	g.run("flag:f1")
	g.run("give:iket_sunda")
	check(g.check("glyph:sunda_ka") and learned == ["sunda_ka"] and g.has_flag("f1") and "iket_sunda" in g.inventory, "actions")
	ev.weakness_triggered.emit("kuntilanak")
	check(g.has_flag("weak:kuntilanak"), "weakness flag")

	# A prefix collect step counts items already held, and give: fires item_picked.
	g.add_item("ang_1", false)
	g.start_quest("t_d")
	check(g.quests.t_d.step == 0 and g.quests.t_d.count == 1, "catch-up: %s" % g.quests.t_d)
	ev.item_picked.emit("other")
	g.run("give:ang_2")
	check(g.quests.t_d.count == 2, "prefix or give: %s" % g.quests.t_d)
	ev.item_picked.emit("ang_3")
	check(g.quests.t_d.step == 1, "prefix step did not finish: %s" % g.quests.t_d)

	# Save round trip keeps quests, codex, pin and flags.
	var before := JSON.stringify(g.to_dict())
	check(g.save_game(), "save failed")
	g._reset()
	check(g.load_game() and JSON.stringify(g.to_dict()) == before, "round trip changed quest state")
	ev.area_entered.emit("spring")
	check(g.quest_state("t_c") == "done" and g.pinned == "", "loaded quest did not advance, or pin not cleared")

	# Old saves get defaults; malformed quest records are dropped or clamped.
	g.from_dict({"class_id": "mage"})
	check(g.quests.is_empty() and g.codex.is_empty() and g.pinned == "", "old save defaults")
	g.from_dict({"class_id": "mage", "quests": {"x": "bad", "y": {"state": "active", "step": -3}, "z": {"state": "won"}}, "flags": {"s": "yes"}})
	check(not g.quests.has("x") and not g.quests.has("z") and g.quests.y.step == 0 and g.quests.y.count == 0, "malformed quests: %s" % g.quests)
	check(not g.has_flag("s"), "a non-bool flag counted as set")
	check(g.current_step("y") == null, "a quest with no data returned a step")

	for p in [PATH, "user://quest_test.bak", PATH + ".tmp"]:
		DirAccess.remove_absolute(p)
	for d in [QDIR, CDIR]:
		for f in DirAccess.get_files_at(d):
			DirAccess.remove_absolute(d + "/" + f)
		DirAccess.remove_absolute(d)
	g._reset()
	quit(1 if fails > 0 else 0)
