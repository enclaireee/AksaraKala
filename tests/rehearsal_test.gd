extends SceneTree
## Rehearsal object (quests.md 10, boss fights v7): the right glyph in range runs clue:<id>; anything else does nothing.
## Prints only failures.

var fails := 0
var examined: Array[String] = []


func check(ok: bool, what: String) -> void:
	if not ok:
		fails += 1
		print("FAIL: ", what)


func make(world: Node2D, id: String, glyph: String, cond := "") -> Node2D:
	var r: Node2D = (load("res://entities/world/rehearsal.tscn") as PackedScene).instantiate()
	r.id = id
	r.glyph = glyph
	r.cond = cond
	r.position = Vector2(100, 100)
	world.add_child(r)
	return r


func has_mark(r: Node2D) -> bool:
	for c in r.get_children():
		if c is BossKit.Mark:
			return true
	return false


func _initialize() -> void:
	await process_frame
	var game := root.get_node("Game")
	var ev := root.get_node("Events")
	game.save_path = "user://rehearsal_test.json"
	game._reset()
	ev.clue_examined.connect(func(id: String) -> void: examined.append(id))
	var world := Node2D.new()
	root.add_child(world)
	current_scene = world
	var player := Node2D.new()   # the object only reads the player's position, through the group
	player.add_to_group("player")
	player.position = Vector2(100, 100)
	world.add_child(player)

	var r := make(world, "reh_t1", "sunda_ca")
	await process_frame
	check(r.is_in_group("rehearsal"), "joins group rehearsal")
	check(r.visible, "visible with an empty cond")
	check(has_mark(r), "gold mark present before it is done")

	ev.spell_cast.emit("sunda_ka", 1.0)
	await process_frame
	check(not game.has_flag("clue_reh_t1") and examined.is_empty(), "wrong glyph does nothing")

	player.position = Vector2(100 + r.radius + 40.0, 100)
	ev.spell_cast.emit("sunda_ca", 1.0)
	await process_frame
	check(not game.has_flag("clue_reh_t1") and examined.is_empty(), "right glyph out of range does nothing")
	check(has_mark(r), "mark stays after a miss")

	player.position = Vector2(100, 100)
	ev.spell_cast.emit("sunda_ca", 1.0)
	await process_frame
	check(game.has_flag("clue_reh_t1"), "right glyph in range sets clue_<id>")
	check(examined.has("reh_t1"), "right glyph in range emits clue_examined")
	for i in 3:
		await process_frame
	check(not has_mark(r) or r._mark == null, "gold mark gone after")

	# a quest sub-goal on clue_examined:<id> is met by it
	check(game._already("clue_examined:reh_t1", 1) == 1, "a quest counts the examined rehearsal even when the signal is gone")

	# glyph "" accepts any spell
	var any := make(world, "reh_t2", "")
	await process_frame
	check(has_mark(any), "any-spell object also shows its mark")
	ev.spell_cast.emit("jawa_na", 0.5)
	await process_frame
	check(game.has_flag("clue_reh_t2") and examined.has("reh_t2"), "glyph \"\" accepts any spell")

	# cond false: hidden and deaf, then it wakes when the flag appears
	var hidden := make(world, "reh_t3", "sunda_ga", "flag:reh_test_gate")
	await process_frame
	check(not hidden.visible, "cond false hides it")
	check(not has_mark(hidden), "cond false shows no mark")
	ev.spell_cast.emit("sunda_ga", 1.0)
	await process_frame
	check(not game.has_flag("clue_reh_t3") and not examined.has("reh_t3"), "cond false makes it deaf")
	game.set_flag("reh_test_gate", false)
	await process_frame
	check(hidden.visible and has_mark(hidden), "cond true shows it and its mark")
	ev.spell_cast.emit("sunda_ga", 1.0)
	await process_frame
	check(game.has_flag("clue_reh_t3"), "cond true makes it answer")

	# once only: a second answer records nothing more
	var n3 := examined.count("reh_t3")
	ev.spell_cast.emit("sunda_ga", 1.0)
	await process_frame
	check(examined.count("reh_t3") == n3, "a second cast does not examine it again")

	# linked to a boss: the answer shows that boss's codex line; beating the boss unrehearsed counts as done
	var kinds: Array[String] = []
	ev.weakness_triggered.connect(func(k: String) -> void: kinds.append(k))
	var linked := make(world, "reh_t4", "sunda_nga")
	linked.boss = "test_boss_a"
	await process_frame
	ev.spell_cast.emit("sunda_nga", 1.0)
	await process_frame
	check(kinds == ["test_boss_a"] and game.has_flag("weak:test_boss_a"), "the answer reveals the boss's weakness line")
	var late := make(world, "reh_t5", "jawa_ka", "flag:reh_never")   # hidden, and never rehearsed
	late.boss = "test_boss_b"
	await process_frame
	ev.boss_defeated.emit("test_boss_a")
	await process_frame
	check(not game.has_flag("clue_reh_t5"), "another boss's fall does not complete it")
	ev.boss_defeated.emit("test_boss_b")
	await process_frame
	check(game.has_flag("clue_reh_t5") and examined.has("reh_t5"), "its boss's fall completes an unrehearsed one, even hidden")

	DirAccess.remove_absolute(game.save_path)
	DirAccess.remove_absolute(game.save_path + ".bak")
	game._reset()
	quit(1 if fails > 0 else 0)
