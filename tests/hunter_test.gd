extends SceneTree
## Nameless Hunter (boss revamp v9): shadow-step, hook pull, Forget locks casting, Ward blocks it, Sunda Ga in the mask window reflects it, pairs in phase 2, release.

const DT := 1.0 / 60.0
var fails := 0
var player: CharacterBody2D
var game: Node
var events: Node
var defeated: Array[String] = []


class FakeCast extends Node:
	var _locked_until := 0
	var locks := 0
	func _lock() -> void:
		locks += 1


class FakePlayer extends CharacterBody2D:
	var sakti := SaktiGauge.new()
	var cast := FakeCast.new()


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _player(at: Vector2) -> void:
	player = FakePlayer.new()
	player.add_to_group("player")
	player.position = at
	var hb := Hurtbox.new()
	hb.collision_layer = 2
	hb.position = Vector2(0, -6)
	var cs := CollisionShape2D.new()
	cs.shape = CircleShape2D.new()
	(cs.shape as CircleShape2D).radius = 7.0
	hb.add_child(cs)
	var hp := Health.new()
	hp.max_hp = 100000
	hb.health = hp
	player.add_child(hp)
	player.add_child(hb)
	root.add_child(player)


func art(b: Node) -> Node:
	return b.get_node("Body/Art")


func step(b: Node, frames: int) -> void:
	for i in frames:
		b._physics_process(DT)


func step_to(b: Node, s: int, frames := 900) -> void:
	for i in frames:
		if b.state == s:
			return
		b._physics_process(DT)


func _initialize() -> void:
	await process_frame
	game = root.get_node("Game")
	events = root.get_node("Events")
	game.save_path = "user://test_hunter.json"
	events.boss_defeated.connect(func(id: String) -> void: defeated.append(id))
	_player(Vector2(200, 135))
	var fp := player as FakePlayer
	fp.add_child(fp.sakti)
	fp.add_child(fp.cast)
	fp.sakti.max_value = 100.0
	var b := (load("res://entities/bosses/nameless_hunter.tscn") as PackedScene).instantiate() as NamelessHunter
	b.position = Vector2(150, 135)
	b.forced_move = "step"   # the move deck is shuffled; pin the shadow-step before the live ready frame can pick another
	root.add_child(b)
	await process_frame
	b.set_physics_process(false)
	check(b.is_in_group("boss") and b.health.max_hp == 3570 and b.phase == 1, "starts phase 1, 3570 HP (4200 x0.85, items.md 7)")

	# Shadow-step: faded, ground marker, reappears on it.
	b.engaged = true
	step_to(b, NamelessHunter.State.FADE)
	check(b.state == NamelessHunter.State.FADE and b.body.modulate.a == 0.0, "fades out")
	step_to(b, NamelessHunter.State.MARK)
	check(b.state == NamelessHunter.State.MARK and b._marker != null, "ground marker shown")
	var spot := b._spot
	step_to(b, NamelessHunter.State.RECOVER)
	check(b.global_position == spot and b.attacks == 1, "reappears on the marker")
	step_to(b, NamelessHunter.State.CHASE)

	# Hook: a landed hit pulls the player toward him.
	b.global_position = Vector2(100, 135)
	player.position = Vector2(200, 135)
	b._begin_cone(true, Vector2(100, 0))
	step_to(b, NamelessHunter.State.RECOVER)
	b.attack_hitbox.hit_landed.emit(null)
	check(is_equal_approx(player.position.x, 152.0), "hook pulls 3 tiles (x %s)" % player.position.x)

	# Forget: sakti empties, casting locked for 4 s.
	fp.sakti.value = 80.0
	b._begin_cone(false, Vector2(1, 0))
	check(b.state == NamelessHunter.State.FORGET, "forget wind-up")
	step_to(b, NamelessHunter.State.RECOVER)
	var now := Time.get_ticks_msec()
	check(fp.sakti.value == 0.0 and fp.cast.locks == 1, "forget empties sakti and calls the lockout")
	check(fp.cast._locked_until > now + 3500 and fp.cast._locked_until <= now + 4100, "locked for 4 s")

	# Ga Ward up when it lands blocks it.
	fp.sakti.value = 80.0
	fp.cast.locks = 0
	var ward := Node2D.new()
	ward.add_to_group("ward")
	root.add_child(ward)
	step_to(b, NamelessHunter.State.CHASE)
	b._begin_cone(false, Vector2(1, 0))
	step_to(b, NamelessHunter.State.RECOVER)
	check(fp.sakti.value == 80.0 and fp.cast.locks == 0, "Ward blocks Forget")
	ward.free()

	# v9: the mask is raised for 1.2 s (sig1); Sunda Ga in that window reflects Forget: no lock, he is unmasked and stunned 4 s.
	fp.sakti.value = 80.0
	fp.cast.locks = 0
	step_to(b, NamelessHunter.State.CHASE)
	b.global_position = Vector2(100, 135)
	b._begin_cone(false, Vector2(1, 0))
	check(is_equal_approx(b.forget_windup, 1.2) and art(b)._move == "sig1", "mask raise plays sig1 for a 1.2 s window")
	step(b, 20)
	events.spell_cast.emit("sunda_ca", 1.0)
	check(b.state == NamelessHunter.State.FORGET, "another glyph does not reflect it")
	events.spell_cast.emit("sunda_ga", 1.0)
	check(b.state == NamelessHunter.State.STUN and BossKit.is_open(b) and art(b)._move == "sig2", "Sunda Ga: unmasked stun, TERBUKA, sig2")
	step(b, 230)
	check(b.state == NamelessHunter.State.STUN, "still stunned at 3.8 s")
	step(b, 20)
	check(b.state != NamelessHunter.State.STUN, "stun ends after 4 s")
	check(fp.sakti.value == 80.0 and fp.cast.locks == 0, "a reflected Forget never lands")
	# Ga after the window (state RECOVER) does nothing.
	b._begin_cone(false, Vector2(1, 0))
	step_to(b, NamelessHunter.State.RECOVER)
	events.spell_cast.emit("sunda_ga", 1.0)
	check(b.state == NamelessHunter.State.RECOVER, "Ga after Forget landed: no reflect")
	fp.sakti.value = 80.0
	fp.cast.locks = 0

	# Outside the cone: nothing.
	step_to(b, NamelessHunter.State.CHASE)
	b._begin_cone(false, Vector2(-1, 0))
	step_to(b, NamelessHunter.State.RECOVER)
	check(fp.sakti.value == 80.0 and fp.cast.locks == 0, "behind the cone is safe")

	# Phase 2: steps in pairs, Forget after the second.
	b.health.take_damage(1801, player)
	check(b.phase == 2, "phase 2 at 50%")
	step_to(b, NamelessHunter.State.CHASE)
	b.attacks = 0
	step_to(b, NamelessHunter.State.FORGET, 2000)
	check(b.state == NamelessHunter.State.FORGET and b.attacks == 2, "two steps, then Forget (attacks %d)" % b.attacks)

	# Release.
	b.health.take_damage(b.health.hp, player)
	for i in 30:
		await physics_frame
	check(defeated == ["nameless_hunter"] and "nameless_hunter" in game.killed, "boss_defeated emitted, killed recorded")
	quit(1 if fails > 0 else 0)
