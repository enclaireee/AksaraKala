extends SceneTree
## Keris Gandring test: stakes light, cleanse (any glyph, Ha wide), the seven-mark wave, phase 2, defeat, practice stake.

const DT := 1.0 / 60.0
var fails := 0
var player: CharacterBody2D
var k: KerisGandring
var all: Array[CurseStake] = []
var defeated: Array[String] = []
var areas: Array[String] = []


func _initialize() -> void:
	await process_frame
	var game := root.get_node("Game")
	var events := root.get_node("Events")
	game.save_path = "user://test_keris.json"
	events.boss_defeated.connect(func(id: String) -> void: defeated.append(id))
	events.area_entered.connect(func(id: String) -> void: areas.append(id))
	player = CharacterBody2D.new()
	player.add_to_group("player")
	player.position = Vector2(900, 900)
	root.add_child(player)
	var stake_scene := load("res://entities/bosses/curse_stake.tscn") as PackedScene
	for i in 7:
		var s := stake_scene.instantiate() as CurseStake
		s.stake_id = i + 1
		s.position = Vector2(300, 135) + Vector2.from_angle(TAU * i / 7.0) * 150.0
		root.add_child(s)
		s.set_physics_process(false)
		all.append(s)
	k = (load("res://entities/bosses/keris_gandring.tscn") as PackedScene).instantiate() as KerisGandring
	k.position = Vector2(300, 135)
	root.add_child(k)
	await process_frame
	k.set_physics_process(false)

	check(k.is_in_group("boss") and k.health.max_hp == 4200 and k.boss_name_key == "BOSS_KERIS_GANDRING", "stats")
	check(k.stakes().size() == 7 and k.lit_count() == 0, "7 unlit stakes")
	k.forced_move = "idle"   # no moves while the stakes are tested
	run(9.0)
	check(not k.engaged and k.lit_count() == 0 and not all.any(func(s: CurseStake) -> bool: return s.state != CurseStake.State.UNLIT), "inert until the player is near")

	# stakes light over time: mark first, then lit
	player.position = all[0].position   # on the first stake; nothing is lit yet
	run(8.1)
	check(all.filter(func(s: CurseStake) -> bool: return s.state == CurseStake.State.MARK).size() == 1, "a stake is marked after 8 s")
	check(k.lit_count() == 0, "marking is not lit yet")
	run(1.0)
	check(k.lit_count() == 1, "lit after the 1 s mark")

	# cleanse: any glyph within 40 px, not outside it
	var lit := all.filter(func(s: CurseStake) -> bool: return s.is_lit())[0] as CurseStake
	player.position = lit.position + Vector2(60, 0)
	events.spell_cast.emit("sunda_ca", 1.0)
	check(lit.is_lit(), "60 px: no cleanse")
	player.position = lit.position + Vector2(30, 0)
	events.spell_cast.emit("sunda_ca", 1.0)
	check(not lit.is_lit(), "any glyph within 40 px cleanses")

	# Ha cleanses within 80 px
	var a := all[0]
	var c := all[1]
	for s in [a, c]:
		s.state = CurseStake.State.LIT
	player.position = (a.position + c.position) / 2.0
	var half := a.position.distance_to(c.position) / 2.0
	check(half > 40.0 and half <= 80.0, "fixture: stakes %f px from the player" % half)
	events.spell_cast.emit("sunda_ga", 1.0)
	check(a.is_lit() and c.is_lit(), "other glyph at 40-80 px: no cleanse")
	events.spell_cast.emit("jawa_ha", 1.0)
	check(not a.is_lit() and not c.is_lit(), "Ha cleanses every lit stake within 80 px")

	# all 7 lit: red ring, then the wave
	for s in all:
		s.state = CurseStake.State.LIT
	k._enter(KerisGandring.State.CHASE)
	player.position = Vector2(300, 135) + Vector2(0, 40)
	run(DT * 2)
	check(k.state == KerisGandring.State.RING, "7 lit: ring")
	run(1.5)
	check(k.waves == 0 and k.state == KerisGandring.State.RING, "ring fills for 2 s")
	run(0.6)
	check(k.waves == 1 and k.attack_hitbox.damage == 60 and k.attack_hitbox.heavy, "curse wave: heavy 60")
	check((k.attack_hitbox.get_node("Shape") as CollisionShape2D).shape.radius >= k.arena_radius - 0.1, "wave covers the arena")
	check(k.lit_count() == 0, "all stakes go out")

	# dart telegraph, phase 2 double dart and faster stakes
	k._enter(KerisGandring.State.CHASE)
	k.forced_move = "dart"
	k.global_position = Vector2(300, 135)
	player.position = Vector2(400, 135)
	k._physics_process(DT)
	check(k.state == KerisGandring.State.DART_WIND and k.darts_left == 1, "phase 1: one dart %d %d %s" % [k.state, k.darts_left, k.global_position.distance_to(player.position)])
	k.health.take_damage(k.health.hp - 2100, player)
	check(k.phase == 2 and k.state == KerisGandring.State.PAUSE and k.stake_interval == 5.0, "phase 2 at 50%: pause, 5 s stakes")
	k._enter(KerisGandring.State.CHASE)
	k.global_position = Vector2(300, 135)
	k._physics_process(DT)
	check(k.darts_left == 2, "phase 2: two darts in a row")
	k._enter(KerisGandring.State.PAUSE)
	k.forced_move = "idle"
	k._light_t = 0.0
	run(5.1)
	check(all.any(func(s: CurseStake) -> bool: return s.state == CurseStake.State.MARK), "a stake marked within 5 s")

	# every move starts and ends in RECOVER; the heavy ones leave a 2 s punish window; no stake lights meanwhile
	for s in all:
		s.state = CurseStake.State.UNLIT
		s._paint()
	var kit := {"dart": 100.0, "fan": 100.0, "teleport_flurry": 100.0, "orbit_blades": 60.0, "crimson_cross": 100.0,
		"curse_mark": 100.0, "seven_swords": 100.0}
	var heavy := ["teleport_flurry", "orbit_blades", "crimson_cross", "seven_swords"]
	for m: String in kit:
		k.global_position = Vector2(300, 135)
		player.position = Vector2(300.0 + float(kit[m]), 135)
		k._light_t = -9999.0
		k._since_ult = 9
		k.forced_move = m
		var before: int = int(k.moves_used.get(m, 0))
		k._enter(KerisGandring.State.CHASE)
		k._physics_process(DT)
		check(int(k.moves_used.get(m, 0)) == before + 1 and k._move == m, "move %s starts (%s)" % [m, k.moves_used])
		var ended := false
		for i in 1200:
			k._physics_process(DT)
			if k.state == KerisGandring.State.RECOVER:
				ended = true
				break
		check(ended, "move %s ends in RECOVER" % m)
		if ended and heavy.has(m):
			check(k._rec >= k.heavy_recovery, "heavy move %s leaves a punish window (%f)" % [m, k._rec])
		check(k.lit_count() == 0, "move %s lights no stake" % m)
	check(k._since_ult == 0, "the limit break resets its counter")
	check(k.phase == 2 and k.attacks >= 10, "moves landed their strikes (%d)" % k.attacks)
	# the deck never repeats a heavy move back to back
	k.forced_move = ""
	k._last_move = "crimson_cross"
	k._since_ult = 0
	k._deck.clear()
	k._deck.append("crimson_cross")
	k._deck.append("dart")
	k.global_position = Vector2(300, 135)
	player.position = Vector2(400, 135)
	check(k._pick_move(100.0) == "dart", "no heavy twice in a row")
	k._deck.clear()
	k.forced_move = "idle"
	player.position = Vector2(900, 900)

	# defeat
	k.health.take_damage(99999, player)
	await create_timer(0.6).timeout
	check(defeated == ["keris_gandring"], "boss_defeated once: %s" % [defeated])
	check(game.killed.count("keris_gandring") == 1, "in Game.killed once")
	check(not all.any(func(s: CurseStake) -> bool: return s.is_lit()), "stakes quiet after defeat")

	# practice stake
	var ps := stake_scene.instantiate() as CurseStake
	ps.practice = true
	ps.position = Vector2(-500, -500)
	root.add_child(ps)
	ps.set_physics_process(false)
	check(ps.is_lit(), "practice stake is always lit")
	player.position = ps.position + Vector2(10, 0)
	areas.clear()
	events.spell_cast.emit("sunda_ka", 1.0)
	check(not ps.is_lit() and areas == ["timur_praktik_mark"], "cast puts it out and emits timur_praktik_mark: %s" % [areas])
	for i in int(1.9 / DT):
		ps.tick(DT)
	check(not ps.is_lit(), "still out before 2 s")
	for i in int(0.2 / DT):
		ps.tick(DT)
	check(ps.is_lit(), "relights after 2 s")

	game.killed.clear()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.save_path))
	quit(1 if fails > 0 else 0)


func run(seconds: float) -> void:
	for i in int(seconds / DT):
		k._physics_process(DT)
		for s in all:
			s.tick(DT)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
