extends SceneTree
## Keris Gandring test (boss revamp v9): the floor clock lights in order, Jawa Ha resets it and stuns him, the 7th is the curse burst, moves, phase 2, defeat, practice stake.

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

	check(k.is_in_group("boss") and k.health.max_hp == 3570 and k.boss_name_key == "BOSS_KERIS_GANDRING", "stats")
	check(k.stakes().size() == 7 and k.lit_count() == 0, "7 unlit stakes")
	k.forced_move = "idle"   # no moves while the stakes are tested
	run(9.0)
	check(not k.engaged and k.lit_count() == 0 and not all.any(func(s: CurseStake) -> bool: return s.state != CurseStake.State.UNLIT), "inert until the player is near")

	# the floor clock: stakes light in stake_id order, the next one marked; a stake only reddens, then marks 1 s, then lights
	player.position = all[0].position   # on the first stake; nothing is lit yet
	run(k.stake_every * 0.5)
	check(all[0].charge > 0.4 and all[0].charge < 0.6 and all[1].charge == 0.0, "the next stake reddens as its turn nears (%f)" % all[0].charge)
	run(k.stake_every * 0.5 + 0.1)
	check(all[0].state == CurseStake.State.MARK and all.filter(func(s: CurseStake) -> bool: return s.state == CurseStake.State.MARK).size() == 1, "stake 1 is marked after 6 s")
	check(k.lit_count() == 0, "marking is not lit yet")
	run(1.0)
	check(k.lit_count() == 1 and all[0].is_lit(), "stake 1 lit after the 1 s mark")
	run(k.stake_every)
	run(1.1)
	check(all[1].is_lit() and not all[2].is_lit(), "stake 2 follows, in order")

	# other glyphs and a far Ha do nothing; boss stakes ignore casts
	player.position = all[0].position + Vector2(30, 0)
	events.spell_cast.emit("sunda_ca", 1.0)
	check(all[0].is_lit() and k.state != KerisGandring.State.STUN, "any other glyph: nothing")
	player.position = all[0].position + Vector2(100, 0)
	events.spell_cast.emit("jawa_ha", 1.0)
	check(all[0].is_lit() and k.state != KerisGandring.State.STUN, "Ha from 100 px: nothing")

	# the answer: Jawa Ha within 80 px of a lit stake resets the clock and stuns him for 3 s (TERBUKA)
	player.position = all[0].position + Vector2(40, 0)
	events.spell_cast.emit("jawa_ha", 1.0)
	check(k.lit_count() == 0 and not all.any(func(s: CurseStake) -> bool: return s.state != CurseStake.State.UNLIT), "Ha resets the whole clock")
	check(k.state == KerisGandring.State.STUN and BossKit.is_open(k), "and stuns him with TERBUKA")
	run(2.9)
	check(k.state == KerisGandring.State.STUN and k.lit_count() == 0 and all[0].state == CurseStake.State.UNLIT, "stunned 3 s: the clock does not run")
	run(0.2)
	check(k.state != KerisGandring.State.STUN, "stun ends after 3 s")
	k._light_t = 0.0

	# the 7th lit: too late, Ha does nothing and the ring starts
	for s in all:
		s.state = CurseStake.State.LIT
	k._enter(KerisGandring.State.CHASE)
	player.position = Vector2(300, 135) + Vector2(0, 40)
	run(DT * 2)
	check(k.state == KerisGandring.State.RING, "7 lit: ring")
	player.position = all[0].position + Vector2(10, 0)
	events.spell_cast.emit("jawa_ha", 1.0)
	check(k.state == KerisGandring.State.RING and all[0].is_lit(), "Ha during the ring is too late")
	player.position = Vector2(300, 135) + Vector2(0, 40)
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
	k.health.take_damage(k.health.hp - int(k.health.max_hp * 0.5), player)
	check(k.phase == 2 and k.state == KerisGandring.State.PAUSE and k.stake_interval == 4.0, "phase 2 at 50%: pause, 4 s stakes")
	k._enter(KerisGandring.State.CHASE)
	k.global_position = Vector2(300, 135)
	k._physics_process(DT)
	check(k.darts_left == 2, "phase 2: two darts in a row")
	k._enter(KerisGandring.State.PAUSE)
	k.forced_move = "idle"
	k._light_t = 0.0
	run(4.1)
	check(all.any(func(s: CurseStake) -> bool: return s.state == CurseStake.State.MARK), "a stake marked within 4 s")

	# every move starts and ends in RECOVER; the heavy ones leave a 2 s punish window; no stake lights meanwhile
	for s in all:
		s.state = CurseStake.State.UNLIT
		s._paint()
	var kit := {"dart": 100.0, "fan": 100.0, "teleport_flurry": 100.0, "orbit_blades": 60.0, "blade_drill": 100.0,
		"curse_mark": 100.0, "seven_swords": 100.0}
	var heavy := ["teleport_flurry", "orbit_blades", "blade_drill", "seven_swords"]
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
	k._last_move = "blade_drill"
	k._since_ult = 0
	k._deck.clear()
	k._deck.append("blade_drill")
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
