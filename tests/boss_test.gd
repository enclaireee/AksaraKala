extends SceneTree
## Sangkuriang test (v9): sundial/boat set piece, every move, the dawn rule (answer = Ca at the cloth post: stun + TERBUKA; miss = one wrath ring), phase 2, release. Steps the boss by hand.

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
	var hb := Hurtbox.new()
	hb.name = "Hurtbox"
	var hp := Health.new()
	hp.max_hp = 100000
	hb.health = hp
	player.add_child(hp)
	player.add_child(hb)
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
	check(b.health.max_hp == 1785 and b.phase == 1 and b.dawn < 0.01, "starts phase 1, dawn ~0 (%s)" % [b.dawn])
	for i in 600:
		b._physics_process(DT)
	check(b.attacks > 0 and b.engaged, "phase 1 attacks")
	check(b.dawn > 0.0, "the sundial fills from the start of the fight")
	check(b._dial != null and b._boat != null, "set piece: sundial and boat are up")

	# Deck: phase 1 has 5 moves, never the same heavy twice in a row.
	check(b._pool().size() == 5 and not ("earthshaker" in b._pool()), "phase 1 pool")
	b._deck.clear()
	b._last = ""
	var prev := ""
	var dup := false
	for i in 60:
		var pm: String = b._pick(100.0)
		dup = dup or (pm == prev and pm in Sangkuriang.HEAVY)
		check(pm != "", "a move fits at 100 px")
		prev = pm
	check(not dup, "deck: no heavy twice in a row")

	# Every move runs to its recovery and is counted (sig1 = adze, sig2 = heave).
	for m in ["throw", "adze", "heave", "timber", "roll", "earthshaker", "wrath"]:
		var before: int = int(b.moves_used.get(m, 0))
		check(run_move(b, m), "move %s ends in RECOVER" % m)
		check(int(b.moves_used.get(m, 0)) == before + 1, "move %s counted" % m)
	b._enter(Sangkuriang.State.CHASE)
	b.global_position = Vector2(100, 135)
	b._deck.clear()
	player.position = Vector2(200, 135)

	# Early boss: the heave's wind-up is 15% longer.
	b._begin_move("heave")
	check(absf(b._wind - b.heave_windup * 1.15) < 0.001, "heave wind-up x1.15")
	b._enter(Sangkuriang.State.CHASE)

	# no cloth: interact does nothing
	post.interact()
	check(not post.hung and not game.has_flag("post:east"), "post stays bare without the item")

	b.health.take_damage(b.health.max_hp - b.health.max_hp / 2, player)
	check(b.phase == 2 and "earthshaker" in b._pool(), "phase 2 at 50% adds the earthshaker")
	for i in 120:
		b._physics_process(DT)

	# The rule: the post needs the cloth, the dial 50% full and the player near it.
	b.dawn = 0.6
	events.spell_cast.emit("sunda_ca", 1.0)
	check(b.state != Sangkuriang.State.STUN, "Ca without cloth does not stun")
	game.add_item("boeh_rarang", false)
	post.interact()
	check(post.hung and game.has_flag("post:east"), "cloth hung")
	events.spell_cast.emit("sunda_ka", 1.0)
	check(b.state != Sangkuriang.State.STUN, "other glyph does not stun")
	player.position = Vector2(400, 135)
	events.spell_cast.emit("sunda_ca", 1.0)
	check(b.state != Sangkuriang.State.STUN, "Ca far from the post does not stun")
	player.position = Vector2(200, 135)
	b.dawn = 0.2
	events.spell_cast.emit("sunda_ca", 1.0)
	check(b.state != Sangkuriang.State.STUN, "Ca before the dial is half full does not stun")
	b.dawn = 0.6
	events.spell_cast.emit("sunda_ca", 1.0)
	check(b.state == Sangkuriang.State.STUN and b.dawn == 0.0 and BossKit.is_open(b), "false dawn: stun, TERBUKA, dial empty")
	for i in int(b.stun_time / DT) + 2:
		b._physics_process(DT)
	check(b.state != Sangkuriang.State.STUN, "stun ends")

	# Missed: the dial fills, the boat is whole, the Dawn Wrath fires once and the dial starts over.
	b._enter(Sangkuriang.State.CHASE)
	b.global_position = Vector2(100, 135)
	b.dawn = 0.9999
	var wraths: int = int(b.moves_used.get("wrath", 0))
	for i in 10:
		b._physics_process(DT)
	check(int(b.moves_used.get("wrath", 0)) == wraths + 1 and b.dawn < 0.1, "dial full: one Dawn Wrath, dial resets")

	# release
	b.health.take_damage(5000, player)
	await create_timer(0.6).timeout
	check(defeated == ["sangkuriang"], "boss_defeated once: %s" % [defeated])
	check(game.killed.count("sangkuriang") == 1, "in Game.killed once")
	check(game.ilmu == ilmu0 + 150, "Ilmu 150")
	game.killed.clear()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.save_path))
	quit(1 if fails > 0 else 0)


## Runs one move by hand until it reaches RECOVER. The test player has no hurtbox, so nothing is hurt.
func run_move(b: Sangkuriang, m: String) -> bool:
	b._enter(Sangkuriang.State.CHASE)
	b.global_position = Vector2(100, 135)
	player.position = Vector2(200, 135)
	b._begin_move(m)
	for i in 900:
		b._physics_process(DT)
		if b.state == Sangkuriang.State.RECOVER:
			break
	return b.state == Sangkuriang.State.RECOVER


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
