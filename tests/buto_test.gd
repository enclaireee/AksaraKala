extends SceneTree
## Buto Ijo test (boss revamp v9): phases, the lit pouch rule (charge through it: 4 s stun, next pouch), the moves, defeat. Steps the boss by hand.

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

	var mx: int = b.health.max_hp
	check(b.is_in_group("boss") and mx == 2890 and b.boss_name_key == "BOSS_BUTO_IJO", "stats")
	check(b.phase == 0 and not b.engaged and b.fields.is_empty(), "inert until the player is near")
	player.position = Vector2(200, 135)
	b._physics_process(DT)
	check(b.engaged and b.phase == 1 and b.fields.size() == 1, "engages: phase 1, one lit pouch")
	check(b.pouch().kind == "bramble", "phase 1 pouch is bramble")

	# phases at 75/50/25%, one lit pouch each, one kind per phase
	var want := ["bramble", "bamboo", "salt", "mud"]
	for p in [2, 3, 4]:
		b.health.take_damage(b.health.hp - int(mx * (1.0 - 0.25 * (p - 1))) + 1, player)   # just past the threshold
		check(b.phase == p and b.fields.size() == 1, "phase %d with one pouch (%d)" % [p, b.fields.size()])
		check(b.state == ButoIjo.State.PAUSE, "roar pause in phase %d" % p)
		check(b.pouch().kind == want[p - 1], "phase %d pouch is %s" % [p, want[p - 1]])
	b.health.take_damage(1, player)
	check(b.phase == 4, "no phase 5")

	# the rule: a charge that misses the pouch just ends; one that crosses it stuns him for 4 s with TERBUKA and lights the next
	b.forced_move = "charge"
	player.position = Vector2(260, 135)
	b.global_position = Vector2(100, 135)
	put_pouch(Vector2(100, 300))
	var first := b.pouch()
	b._enter(ButoIjo.State.CHASE)
	run(b.charge_windup + 0.05)
	check(b.state == ButoIjo.State.CHARGE, "charging")
	for i in 300:
		if b.state != ButoIjo.State.CHARGE:
			break
		run(DT)
	check(b.state == ButoIjo.State.RECOVER and b.pouch() == first, "a miss: no stun, the same pouch stays lit (state %d, same %s, pos %s, dir %s, move %s)" % [b.state, b.pouch() == first, b.global_position, b._dir, b._move])
	b.global_position = Vector2(100, 135)
	put_pouch(Vector2(180, 135))
	first = b.pouch()
	b._enter(ButoIjo.State.CHASE)
	run(b.charge_windup + 0.05)
	for i in 120:
		if b.state == ButoIjo.State.STUN:
			break
		run(DT)
	check(b.state == ButoIjo.State.STUN and BossKit.is_open(b), "crossing the pouch stuns him and opens TERBUKA")
	check(b.pouch() != first and b.fields.size() == 1, "the next pouch lights")
	check(b.global_position.x < 100.0 + b.charge_length, "the stun ended the charge early (x=%f)" % b.global_position.x)
	run(3.9)
	check(b.state == ButoIjo.State.STUN, "still stunned at 3.9 s")
	run(0.2)
	check(b.state != ButoIjo.State.STUN, "stun ends after 4 s")

	# pound up close
	b.forced_move = "pound"
	b.global_position = Vector2(150, 135)
	b._enter(ButoIjo.State.CHASE)
	player.position = Vector2(180, 135)
	b._physics_process(DT)
	check(b.state == ButoIjo.State.WINDUP and b._pound, "ground pound at 56 px or closer")

	# every move starts and ends in RECOVER (heavy ones leave a punish window); the maw drags the player in
	put_pouch(Vector2(900, 900))
	var kit := {"pound": 30.0, "charge": 100.0, "devour": 40.0, "seed_volley": 120.0, "bramble_stomp": 60.0,
		"quake": 60.0, "famine_maw": 100.0}
	for m: String in kit:
		b.global_position = Vector2(100, 135)
		player.position = Vector2(100.0 + float(kit[m]), 135)
		b._since_ult = 5
		b.forced_move = m
		var before: int = int(b.moves_used.get(m, 0))
		b._enter(ButoIjo.State.CHASE)
		b._physics_process(DT)
		check(int(b.moves_used.get(m, 0)) == before + 1 and b._move == m, "move %s starts (%s)" % [m, b.moves_used])
		var ended := false
		for i in 900:
			b._physics_process(DT)
			b.status._physics_process(DT)
			if b.state == ButoIjo.State.RECOVER:
				ended = true
				break
		check(ended, "move %s ends in RECOVER" % m)
		if ended and ["pound", "charge", "devour", "quake", "famine_maw"].has(m):
			check(b._rec >= b.heavy_recovery, "heavy move %s leaves a punish window (%f)" % [m, b._rec])
		if m == "famine_maw":
			check(player.position.x < 100.0 + float(kit[m]) - 20.0, "the famine maw pulled the player in (x=%f)" % player.position.x)
	check(b._since_ult == 0, "the limit break resets its counter")
	check(b.moves_used.get("hunger_leap", 0) == 0 and b.moves_used.get("rampage", 0) == 0, "hunger_leap and rampage are cut")
	# the deck never repeats a heavy move back to back
	b.forced_move = ""
	b._last_move = "pound"
	b._deck.clear()
	b._deck.append("pound")
	b._deck.append("quake")
	player.position = Vector2(130, 135)
	b.global_position = Vector2(100, 135)
	b._since_ult = 0
	b._since_charge = 0
	check(b._pick_move(30.0) != "pound", "no heavy twice in a row")
	# the charge comes round after two other moves
	b._since_charge = 2
	b._last_move = "pound"
	player.position = Vector2(200, 135)
	check(b._pick_move(100.0) == "charge", "the charge is due after two other moves")
	b._deck.clear()
	b.forced_move = "idle"

	# defeat
	b.health.take_damage(99999, player)
	await create_timer(0.6).timeout
	check(defeated == ["buto_ijo"], "boss_defeated once: %s" % [defeated])
	check(game.killed.count("buto_ijo") == 1, "in Game.killed once")
	game.killed.clear()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.save_path))
	quit(1 if fails > 0 else 0)


## Replaces his lit pouch with one at pos.
func put_pouch(pos: Vector2) -> void:
	for f in b.fields:
		f.queue_free()
	b.fields.clear()
	var f := (load("res://entities/bosses/pouch_field.tscn") as PackedScene).instantiate() as PouchField
	f.kind = "bamboo"
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
