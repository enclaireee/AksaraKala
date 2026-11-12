extends SceneTree
## Demo mode (architecture.md 10b): every checkpoint on the title's Demo card is reachable by DemoRoute from
## New Game through the real quest engine, lands where it says, and leaves a state play could leave: earlier
## acts done, the act at its step, the boss not yet beaten, the hero at least at the boss door's level floor.
## The replay writes no save. Run: $GODOT --headless --path . -s tests/demo_test.gd

const SAVE := "user://demo_test_save.json"

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	var game := root.get_node("Game")
	var zones := root.get_node("Zones")
	var keep: String = game.save_path
	game.save_path = SAVE
	var cps := DemoRoute.checkpoints()
	var bosses := cps.filter(func(c: Dictionary) -> bool: return c.kind == "boss").map(func(c: Dictionary) -> String: return c.boss)
	bosses.sort()
	check(bosses == ["bandung_bondowoso", "barma_wijaya", "batara_kala", "buto_ijo", "faceless_captain", "hariang_banga",
			"keris_gandring", "nameless_hunter", "sandekala", "sangkuriang"], "boss checkpoints %s" % [bosses])
	check(cps.filter(func(c: Dictionary) -> bool: return c.kind == "act").size() == DemoRoute.MAIN.size(), "one start per act")
	for cp: Dictionary in cps:
		var label := "%s %s step %d %s" % [cp.kind, cp.quest, int(cp.step) + 1, cp.boss if cp.boss != "" else cp.zone]
		check(zones.ZONES.has(cp.zone), label + ": unknown zone")
		var r := DemoRoute.new(game, zones)
		var ok := r.build("warrior", cp)
		check(ok, "%s: not reached (%s)" % [label, ", ".join(r.notes)])
		check(not game.replaying, label + ": still replaying")
		if not ok:
			continue
		for n: String in r.notes:
			if n.begins_with("stuck"):
				check(false, "%s: %s" % [label, n])
		var qi := DemoRoute.MAIN.find(cp.quest)
		for i in qi:
			check(game.quest_state(DemoRoute.MAIN[i]) == "done", "%s: %s not done" % [label, DemoRoute.MAIN[i]])
		check(game.quest_state(cp.quest) == "active", "%s: %s is %s" % [label, cp.quest, game.quest_state(cp.quest)])
		if cp.quest != "mq0" or cp.kind != "act":
			check(r.here == cp.zone, "%s: hero in %s" % [label, r.here])
			check(r._spawn_in(r.here, str(r.entry.get(r.here, ""))) != "" or r._pet(r.here) != "", label + ": nowhere to stand")
		if cp.kind == "boss":
			check(cp.boss not in game.killed, label + ": boss already dead")
			check(game.level() >= int(DemoRoute.LEVEL_FLOOR.get(cp.boss, 0)), "%s: level %d" % [label, game.level()])
		check(not FileAccess.file_exists(SAVE), label + ": the replay saved")
	# every class reaches the last boss door with a weapon of its own kind in hand
	var last: Dictionary = cps.filter(func(c: Dictionary) -> bool: return c.boss == "batara_kala")[0]
	for cls: String in DemoRoute.CLASSES:
		var r := DemoRoute.new(game, zones)
		check(r.build(cls, last), "%s: last boss not reached (%s)" % [cls, ", ".join(r.notes)])
		var w := ItemData.by_id(str(game.equipped.get("weapon", "")))
		var start := ItemData.by_id((load("res://data/classes/%s.tres" % cls) as ClassData).start_weapon)
		check(w != null and start != null and w.archetype == start.archetype, "%s: weapon %s" % [cls, game.equipped.get("weapon", "")])
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))
	game._reset()
	game.save_path = keep
	quit(1 if fails > 0 else 0)
