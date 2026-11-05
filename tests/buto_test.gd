extends SceneTree
## Buto Ijo test: phases and fields, the four field effects, charge limits, defeat. Steps the boss by hand.

const DT := 1.0 / 60.0
var fails := 0
var player: CharacterBody2D
var b: ButoIjo
var defeated: Array[String] = []


func _initialize() -> void:
	await process_frame
	var game := root.get_node("Game")
	var events := root.get_node("Events")
	game.save_path = "user://test_buto.json"
	events.boss_defeated.connect(func(id: String) -> void: defeated.append(id))
	player = CharacterBody2D.new()
	player.add_to_group("player")
	player.position = Vector2(900, 135)
	root.add_child(player)
	b = (load("res://entities/bosses/buto_ijo.tscn") as PackedScene).instantiate() as ButoIjo
	b.position = Vector2(100, 135)
	root.add_child(b)
	await process_frame
	b.set_physics_process(false)

	check(b.is_in_group("boss") and b.health.max_hp == 3400 and b.boss_name_key == "BOSS_BUTO_IJO", "stats")
	check(b.phase == 0 and not b.engaged and b.fields.is_empty(), "inert until the player is near")
	player.position = Vector2(200, 135)
	b._physics_process(DT)
	check(b.engaged and b.phase == 1 and b.fields.size() == 3, "engages: phase 1, 3 fields")
	check(b.fields.all(func(f: PouchField) -> bool: return f.kind == "bramble"), "phase 1 is bramble")

	# phases at 75/50/25%, 3 fields each, one kind per phase
	var want := ["bramble", "bamboo", "salt", "mud"]
	for p in [2, 3, 4]:
		b.health.take_damage(b.health.hp - int(3400 * (1.0 - 0.25 * (p - 1))) + 1, player)   # just past the threshold
		check(b.phase == p and b.fields.size() == 3 * p, "phase %d with %d fields (%d)" % [p, 3 * p, b.fields.size()])
		check(b.state == ButoIjo.State.PAUSE, "roar pause in phase %d" % p)
		check(b.fields.filter(func(f: PouchField) -> bool: return f.kind == want[p - 1]).size() == 3, "3 %s fields" % want[p - 1])
	b.health.take_damage(1, player)
	check(b.phase == 4, "no phase 5")

	# bramble slows him
	solo("bramble", Vector2(100, 135))
	b._enter(ButoIjo.State.CHASE)
	b._physics_process(DT)
	check(is_equal_approx(b.slow(), 0.5), "bramble: half speed (%f)" % b.slow())
	solo("salt", Vector2(100, 135))
	b._physics_process(DT)
	check(is_equal_approx(b.slow(), 0.4), "salt: 60%% slow (%f)" % b.slow())

	# no charge from saltwater; a charge from outside works
	b._enter(ButoIjo.State.CHASE)
	player.position = Vector2(200, 135)
	b._physics_process(DT)
	check(b.state == ButoIjo.State.CHASE, "salt: no charge start")
	solo("salt", Vector2(100, 400))
	b._physics_process(DT)
	check(b.state == ButoIjo.State.WINDUP and not b._pound, "charge starts outside salt")

	# a charge into bamboo stops and stuns
	b.status.clear(Status.Type.SLOW)
	b.global_position = Vector2(100, 135)
	solo("bamboo", Vector2(160, 135))
	b._enter(ButoIjo.State.CHASE)
	run(b.charge_windup + 0.05)
	check(b.state == ButoIjo.State.CHARGE, "charging")
	run(0.6)
	check(b.state == ButoIjo.State.STUN, "bamboo stuns him")
	check(b.global_position.x < 100.0 + b.charge_length, "bamboo ended the charge early (x=%f)" % b.global_position.x)
	run(b.bamboo_stun + 0.05)
	check(b.state != ButoIjo.State.STUN, "stun ends after 1.5 s")

	# pound up close
	solo("bramble", Vector2(900, 900))
	b.global_position = Vector2(150, 135)
	b._enter(ButoIjo.State.CHASE)
	player.position = Vector2(180, 135)
	b._physics_process(DT)
	check(b.state == ButoIjo.State.WINDUP and b._pound, "ground pound at 56 px or closer")

	# mud binds once, then rests
	solo("mud", Vector2(400, 135))
	b._enter(ButoIjo.State.RECOVER)
	b.global_position = Vector2(300, 135)
	b._physics_process(DT)
	check(not b.status.has(Status.Type.BOUND), "outside mud: free")
	b.global_position = Vector2(400, 135)
	b._physics_process(DT)
	check(b.status.has(Status.Type.BOUND) and b.slow() == 0.0, "mud binds")
	b.status.clear(Status.Type.BOUND)
	b.global_position = Vector2(300, 135)
	b._physics_process(DT)
	b.global_position = Vector2(400, 135)
	b._physics_process(DT)
	check(not b.status.has(Status.Type.BOUND), "mud resting for 4 s")
	for i in int(b.mud_rest / DT) + 2:
		b._physics_process(DT)
	b.global_position = Vector2(300, 135)
	b._physics_process(DT)
	b.global_position = Vector2(400, 135)
	b._physics_process(DT)
	check(b.status.has(Status.Type.BOUND), "mud binds again after resting")

	# defeat
	b.health.take_damage(99999, player)
	await create_timer(0.6).timeout
	check(defeated == ["buto_ijo"], "boss_defeated once: %s" % [defeated])
	check(game.killed.count("buto_ijo") == 1, "in Game.killed once")
	game.killed.clear()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.save_path))
	quit(1 if fails > 0 else 0)


## Replaces his fields with one of this kind.
func solo(kind: String, pos: Vector2) -> void:
	for f in b.fields:
		f.queue_free()
	b.fields.clear()
	var f := (load("res://entities/bosses/pouch_field.tscn") as PackedScene).instantiate() as PouchField
	f.kind = kind
	root.add_child(f)
	f.global_position = pos
	b.fields.append(f)


func run(seconds: float) -> void:
	for i in int(seconds / DT):
		b._physics_process(DT)
		b.status._physics_process(DT)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
