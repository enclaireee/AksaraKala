extends SceneTree
## Sangkuriang test: phase 2, dawn, fake dawn stun, enrage, release. Steps the boss by hand.

const DT := 1.0 / 60.0
var fails := 0
var player: CharacterBody2D
var game: Node
var events: Node
var defeated: Array[String] = []


func _initialize() -> void:
	await process_frame
	game = root.get_node("Game")
	events = root.get_node("Events")
	game.save_path = "user://test_boss.json"
	events.boss_defeated.connect(func(id: String) -> void: defeated.append(id))
	player = CharacterBody2D.new()
	player.add_to_group("player")
	player.position = Vector2(200, 135)
	root.add_child(player)
	var post := (load("res://entities/bosses/arena_post.tscn") as PackedScene).instantiate() as ArenaPost
	post.position = Vector2(220, 135)
	root.add_child(post)
	var b := (load("res://entities/bosses/sangkuriang.tscn") as PackedScene).instantiate() as Sangkuriang
	b.position = Vector2(100, 135)
	root.add_child(b)
	await process_frame
	b.set_physics_process(false)
	var ilmu0: int = game.ilmu

	check(b.is_in_group("boss") and b.is_in_group("enemy"), "groups")
	check(b.health.max_hp == 2100 and b.phase == 1 and b.dawn == 0.0, "starts phase 1, dawn 0")
	for i in 600:
		b._physics_process(DT)
	check(b.attacks > 0 and b.engaged, "phase 1 attacks")
	check(b.dawn == 0.0, "dawn stays 0 in phase 1")

	# no cloth: interact does nothing
	post.interact()
	check(not post.hung and not game.has_flag("post:east"), "post stays bare without the item")

	b.health.take_damage(1050, player)
	check(b.phase == 2, "phase 2 at 50%")
	for i in 300:
		b._physics_process(DT)
	check(b.dawn > 0.0 and b.dawn < 1.0, "dawn rises")

	# Ca with no cloth does nothing
	events.spell_cast.emit("sunda_ca", 1.0)
	check(b.state != Sangkuriang.State.STUN, "Ca without cloth does not stun")

	game.add_item("boeh_rarang", false)
	post.interact()
	check(post.hung and game.has_flag("post:east"), "cloth hung")
	var before: float = b.dawn
	events.spell_cast.emit("sunda_ka", 1.0)
	check(b.state != Sangkuriang.State.STUN and b.dawn == before, "other glyph does not stun")
	player.position = Vector2(400, 135)
	events.spell_cast.emit("sunda_ca", 1.0)
	check(b.state != Sangkuriang.State.STUN, "Ca far from the post does not stun")
	player.position = Vector2(200, 135)
	events.spell_cast.emit("sunda_ca", 1.0)
	check(b.state == Sangkuriang.State.STUN and b.dawn == 0.0, "Ca near hung post stuns and resets dawn")
	for i in int(b.stun_time / DT) + 2:
		b._physics_process(DT)
	check(b.state != Sangkuriang.State.STUN, "stun ends")

	# enrage at dawn 1, then the fake dawn can repeat
	for i in int(b.dawn_time / DT) + 60:
		b._physics_process(DT)
	check(b.dawn == 1.0 and b.enraged, "dawn 1 enrages")
	events.spell_cast.emit("sunda_ca", 1.0)
	check(b.state == Sangkuriang.State.STUN and not b.enraged and b.dawn == 0.0, "stun repeats and calms him")

	# release
	b.health.take_damage(5000, player)
	await create_timer(0.6).timeout
	check(defeated == ["sangkuriang"], "boss_defeated once: %s" % [defeated])
	check(game.killed.count("sangkuriang") == 1, "in Game.killed once")
	check(game.ilmu == ilmu0 + 150, "Ilmu 150")
	game.killed.clear()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.save_path))
	quit(1 if fails > 0 else 0)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
