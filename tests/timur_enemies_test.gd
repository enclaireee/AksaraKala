extends SceneTree
## Tanah Timur enemies: stats, glyph weaknesses, Burn and Curse on hit, elites inert until their step. Steps enemies by hand.

const DT := 1.0 / 60.0
const PATH := "user://test_timur.json"
var fails := 0
var player: CharacterBody2D
var kinds: Array[String] = []


class Victim extends Node2D:
	var status := Status.new()
	var melee_hitbox: Hitbox


func _initialize() -> void:
	var game := root.get_node("Game")
	game.save_path = PATH
	game._reset()
	player = CharacterBody2D.new()
	player.add_to_group("player")
	player.position = Vector2(170, 135)
	root.add_child(player)
	root.get_node("Events").weakness_triggered.connect(func(k: String) -> void: kinds.append(k))
	await process_frame

	# stats (the elites are spawned with their quest at the right step, so they are not freed or hidden)
	game.quests["sq_t1"] = {"state": "active", "step": 1, "count": 0}
	game.quests["sq_t2"] = {"state": "active", "step": 2, "count": 0}
	for row in [
		["banaspati", 64, "banaspati", 14], ["prajurit_terkutuk", 240, "prajurit_terkutuk", 34], ["kemamang", 64, "kemamang", 14],
		["keris_hantu", 96, "keris_hantu", 20], ["banaspati_elite", 256, "banaspati_elite", 56], ["yuyu_kangkang", 384, "yuyu_kangkang", 80],
	]:
		var e := await _spawn(row[0], Vector2(1000, 1000))
		check(e.health.max_hp == row[1] and e.kind == row[2] and e.ilmu == row[3], "%s stats" % row[0])
		e.free()
	game.quests.erase("sq_t1")
	game.quests.erase("sq_t2")

	# Banaspati: Burn on hit, trail, Ward snuff
	var b := await _spawn("banaspati", Vector2(100, 135)) as Banaspati
	var v := _victim(Vector2(1000, 1000))
	b._on_landed(v)
	check(v.status.has(Status.Type.BURN) and b.snuffed == 0.0 and kinds.is_empty(), "hit applies Burn")
	b.target = _victim(Vector2(220, 135))
	for i in 60:
		b._physics_process(DT)
		if not b.patches.is_empty():
			break
	check(not b.patches.is_empty() and b.trail_life == 3.0, "leaves a fire trail")
	var v2 := _victim(b.patches[0].global_position)
	b.target = v2
	b._tick(DT)
	check(v2.status.has(Status.Type.BURN), "standing in the trail applies Burn")
	b.free()
	b = await _spawn("banaspati", Vector2(100, 135)) as Banaspati
	var ward := Node2D.new()
	ward.add_to_group("ward")
	root.add_child(ward)
	var v3 := _victim(Vector2(1000, 1000))
	b._on_landed(v3)
	check(b.snuffed > 0.0 and not v3.status.has(Status.Type.BURN) and kinds == ["banaspati"], "hit into Ward: snuffed, no Burn")
	b.hurtbox.receive(_hit())
	check(b.health.hp == 64 - 15, "x1.5 damage while snuffed (hp %d)" % b.health.hp)
	b.target = _victim(Vector2(220, 135))
	for i in 30:
		b._physics_process(DT)
	check(b.patches.is_empty(), "no trail while snuffed")
	for i in 185:
		b._physics_process(DT)
	check(b.snuffed <= 0.0, "snuff wears off after 3 s")
	b.free()
	ward.free()
	kinds.clear()

	# Prajurit Terkutuk: shield, tiger turn
	var p := await _spawn("prajurit_terkutuk", Vector2(150, 135)) as PrajuritTerkutuk   # player is to its right, it faces right
	p.hurtbox.receive(_hit(40))
	check(p.health.hp == 240 - 10, "shield blocks 75%% from the front (hp %d)" % p.health.hp)
	p.facing = PI
	p.hurtbox.receive(_hit(40))
	check(p.health.hp == 240 - 10 - 40, "no block from behind (hp %d)" % p.health.hp)
	p.free()
	p = await _spawn("prajurit_terkutuk", Vector2(100, 135)) as PrajuritTerkutuk
	var tiger := _hit(0, "summon.gd")
	tiger.position = Vector2(70, 135)
	for i in 90:
		tiger.position = p.position + Vector2(-30, 0)
		p._physics_process(DT)
	check(kinds == ["prajurit_terkutuk"] and absf(angle_difference(p.facing, PI)) < 0.3, "tiger near: it turns to face it (facing %f)" % p.facing)
	p.hurtbox.receive(_hit(40))
	check(p.health.hp == 240 - 40, "back to the player after the tiger turn (hp %d)" % p.health.hp)
	tiger.free()
	p.free()
	p = await _spawn("prajurit_terkutuk", Vector2(150, 135)) as PrajuritTerkutuk
	tiger = _hit(5, "summon.gd")
	tiger.source = null
	tiger.position = Vector2(120, 135)
	p.hurtbox.receive(tiger)
	check(p.tiger_left > 0.0 and absf(angle_difference(p.tiger_angle, PI)) < 0.01 and p.health.hp == 235, "a tiger hit turns it and is not blocked")
	tiger.free()
	p.free()
	kinds.clear()

	# Kemamang: 3 wisps, melee cuts them, Dash-strike while it charges
	var k := await _spawn("kemamang", Vector2(310, 135)) as Kemamang
	k._fire()
	check(k.wisps.size() == 3 and k.wisps.all(func(w: Arrow) -> bool: return w.speed == Kemamang.WISP_SPEED and w.damage == 10), "fires 3 slow wisps")
	var mv := _victim(k.global_position)
	mv.melee_hitbox = Hitbox.new()
	root.add_child(mv.melee_hitbox)
	k.target = mv
	k._tick(DT)
	check(k.wisps.size() == 3, "idle melee hitbox does not cut wisps")
	mv.melee_hitbox.monitoring = true
	k._tick(DT)
	check(k.wisps.is_empty(), "player melee destroys the wisps")
	mv.melee_hitbox.free()
	k.free()
	for n in root.get_children():
		if n is Arrow:
			n.free()
	k = await _spawn("kemamang", Vector2(310, 135)) as Kemamang
	_until(k, func() -> bool: return k.state == Shooter.State.WINDUP)
	check(k.state == Shooter.State.WINDUP, "kemamang charges its spit")
	k.hurtbox.receive(_hit())
	check(k.state == Shooter.State.FLINCH and k.health.hp == 64 - 10 and kinds.is_empty(), "ordinary hit in the wind-up: no drop")
	k.free()
	k = await _spawn("kemamang", Vector2(310, 135)) as Kemamang
	_until(k, func() -> bool: return k.state == Shooter.State.WINDUP)
	k.hurtbox.receive(_hit(10, "dash_strike.gd"))
	check(k.state == Shooter.State.GROUNDED and k.health.hp == 64 - 20 and kinds == ["kemamang"], "Dash-strike in the wind-up: dropped, x2 (hp %d)" % k.health.hp)
	for i in 125:
		k._physics_process(DT)
	check(k.state != Shooter.State.GROUNDED, "up again after 2 s")
	k.free()
	for n in root.get_children():
		if n is Arrow:
			n.free()
	kinds.clear()

	# Keris Hantu: Curse on hit, Bind mid-dart
	var kh := await _spawn("keris_hantu", Vector2(100, 135)) as KerisHantu
	var cv := _victim(Vector2(1000, 1000))
	kh._on_landed(cv)
	check(cv.status.has(Status.Type.CURSE), "hit applies Curse")
	kh.status.apply(Status.Type.BOUND, 2.0)
	check(kh.state != Charger.State.STUN and kinds.is_empty(), "Bound outside a dart does nothing special")
	kh.free()
	kh = await _spawn("keris_hantu", Vector2(100, 135)) as KerisHantu
	_until(kh, func() -> bool: return kh.state == Charger.State.DASH)
	check(kh.state == Charger.State.DASH, "keris darts")
	kh.status.apply(Status.Type.BOUND, 2.0)
	check(kh.state == Charger.State.STUN and kinds == ["keris_hantu"], "Bind mid-dart drops it")
	for i in 140:
		kh._physics_process(DT)
	check(kh.state == Charger.State.STUN, "still down at 2.3 s")
	for i in 20:
		kh._physics_process(DT)
	check(kh.state != Charger.State.STUN, "up after 2.5 s")
	kh.free()
	kinds.clear()

	# Yuyu Kangkang: sideways lane charge, Bind, double pinch
	game.quests["sq_t1"] = {"state": "active", "step": 1, "count": 0}
	var y := await _spawn("yuyu_kangkang", Vector2(100, 135)) as YuyuKangkang
	_until(y, func() -> bool: return y.state == Charger.State.DASH)
	check(y.state == Charger.State.DASH and y.dash_dir == Vector2.RIGHT and y.marker.points[1].x == 192.0, "charges sideways along a 12-tile lane")
	y.status.apply(Status.Type.BOUND, 2.0)
	check(y.state == Charger.State.STUN and kinds == ["yuyu_kangkang"], "Bind mid-charge drops it")
	y.free()
	player.position = Vector2(170, 175)   # off its row
	y = await _spawn("yuyu_kangkang", Vector2(100, 135)) as YuyuKangkang
	for i in 60:
		y._physics_process(DT)
	check(y.state == Charger.State.APPROACH, "no charge while the player is off its row")
	_until(y, func() -> bool: return y.pinching, 600)
	check(y.pinching, "pinches up close")
	var rises := 0
	for i in 100:
		var was := y.pinch_on
		y._physics_process(DT)
		rises += int(y.pinch_on and not was)
	check(rises == 2 and not y.pinching, "two pinches (%d)" % rises)
	y.free()
	player.position = Vector2(170, 135)

	# Elites: inert until their step; Yuyu leaves on the peaceful route
	for row in [["banaspati_elite", "sq_t2", 2, "banaspati_elite"], ["yuyu_kangkang", "sq_t1", 1, "yuyu_kangkang"]]:
		game.quests.erase(row[1])
		var e := await _spawn(row[0], Vector2(100, 100))
		check(not e.active and not e.visible and not e.is_in_group("enemy") and e.collision_layer == 0 and not e.is_physics_processing(), "%s inactive early" % row[0])
		game.quests[row[1]] = {"state": "active", "step": row[2] - 1, "count": 0}
		game.changed.emit()
		check(not e.active, "%s still inactive one step early" % row[0])
		game.quests[row[1]] = {"state": "active", "step": row[2], "count": 0}
		game.changed.emit()
		check(e.active and e.visible and e.is_in_group("enemy") and e.collision_layer == 4 and e.is_physics_processing(), "%s active at its step" % row[0])
		if row[0] == "yuyu_kangkang":
			game.quests[row[1]] = {"state": "active", "step": 2, "count": 0}   # peaceful: sodo lanang handed over
			game.changed.emit()
			check(not e.active and not e.visible and not e.is_in_group("enemy") and e.collision_layer == 0, "yuyu leaves on the peaceful route")
		e.free()
		e = await _spawn(row[0], Vector2(100, 100))
		check(e.active == (row[0] == "banaspati_elite"), "%s state when spawned (active only for the elite at its step)" % row[0])
		e.free()
		game.quests.erase(row[1])
		game.killed.erase(row[3])

	for pth in [PATH, PATH.get_basename() + ".bak", PATH + ".tmp"]:
		if FileAccess.file_exists(pth):
			DirAccess.remove_absolute(pth)
	quit(1 if fails > 0 else 0)


func _until(e: EnemyBase, cond: Callable, frames := 900) -> void:
	for i in frames:
		if cond.call():
			return
		e._physics_process(DT)


func _victim(pos: Vector2) -> Victim:
	var v := Victim.new()
	v.position = pos
	root.add_child(v)
	return v


func _spawn(n: String, pos: Vector2) -> EnemyBase:
	var e := (load("res://entities/enemies/%s.tscn" % n) as PackedScene).instantiate() as EnemyBase
	e.position = pos
	root.add_child(e)
	await process_frame
	e.set_physics_process(false)
	return e


## A hit from the player; `script` swaps in a spell script (summon.gd, dash_strike.gd) without running its _ready.
func _hit(dmg := 10, script := "") -> Hitbox:
	var h := Hitbox.new()
	root.add_child(h)
	if script != "":
		h.set_script(load("res://spells/" + script))
		h.set_physics_process(false)
	h.damage = dmg
	h.source = player
	return h


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
