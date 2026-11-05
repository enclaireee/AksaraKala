extends SceneTree
## Glyph weaknesses and the dummy. Steps enemies by hand.

const DT := 1.0 / 60.0
var fails := 0
var player: CharacterBody2D
var hp: Health
var kinds: Array[String] = []
var kills: Array[String] = []


class FakePlayer extends Node2D:
	var health := Health.new()
	var class_id := ""


func _initialize() -> void:
	player = CharacterBody2D.new()
	player.add_to_group("player")
	player.position = Vector2(170, 135)
	var hb := Hurtbox.new()
	hb.collision_layer = 2
	hb.position = Vector2(0, -6)
	var cs := CollisionShape2D.new()
	cs.shape = CircleShape2D.new()
	(cs.shape as CircleShape2D).radius = 7.0
	hb.add_child(cs)
	hp = Health.new()
	hp.max_hp = 1000
	hb.health = hp
	player.add_child(hp)
	player.add_child(hb)
	root.add_child(player)
	var ev := root.get_node("Events")
	ev.weakness_triggered.connect(func(k: String) -> void: kinds.append(k))
	ev.enemy_killed.connect(func(e: Node2D, _i: int) -> void: kills.append(str(e.get("kind"))))
	await process_frame

	# --- Kuntilanak: Bolt in the wind-up grounds her ---
	var k := await _spawn("kuntilanak", Vector2(225, 135))
	_until(k, Shooter.State.WINDUP)
	check(k.state == Shooter.State.WINDUP, "shriek windup")
	check(k.cone.visible, "cone telegraph")
	var before := hp.hp
	k.hurtbox.receive(_bolt())
	check(k.state == Shooter.State.GROUNDED, "grounded by Bolt in windup")
	check(kinds == ["kuntilanak"], "kuntilanak weakness emitted once")
	for i in 110:
		k._physics_process(DT)
	check(k.state == Shooter.State.GROUNDED and k.velocity == Vector2.ZERO, "grounded at 1.8 s, not moving")
	check(not k.attack_hitbox.monitoring and hp.hp == before, "no attack while grounded")
	var h0: int = k.health.hp
	k.hurtbox.receive(_hit())
	check(k.health.hp == h0 - 10 and k.state == Shooter.State.GROUNDED, "normal damage, stays grounded")
	for i in 20:
		k._physics_process(DT)
	check(k.state != Shooter.State.GROUNDED, "grounded ends after 2 s")
	k.free()
	kinds.clear()

	# Bolt outside the wind-up, and a non-Bolt hit in the wind-up, do nothing special
	k = await _spawn("kuntilanak", Vector2(225, 135))
	k.hurtbox.receive(_bolt())   # IDLE/KEEP
	check(k.state != Shooter.State.GROUNDED and kinds.is_empty(), "Bolt outside windup does not trigger")
	k.free()
	k = await _spawn("kuntilanak", Vector2(225, 135))
	_until(k, Shooter.State.WINDUP)
	k.hurtbox.receive(_hit())
	check(k.state == Shooter.State.FLINCH and kinds.is_empty(), "plain hit in windup only flinches")
	k.free()
	k = await _spawn("kuntilanak", Vector2(225, 135))
	_until(k, Shooter.State.WINDUP)
	_until(k, Shooter.State.SHRIEK)
	k.hurtbox.receive(_bolt())
	check(k.state != Shooter.State.GROUNDED and kinds.is_empty(), "Bolt during the shriek itself does not trigger")
	k.free()

	# --- Wild Boar: dash into Ward ---
	var ward := Node2D.new()
	ward.add_to_group("ward")
	ward.position = player.position
	root.add_child(ward)
	player.position = Vector2(200, 135)
	ward.position = player.position
	hp.hp = 1000
	var b := await _spawn("wild_boar", Vector2(100, 135))
	await _run_boar(b, Charger.State.STUN)
	check(b.state == Charger.State.STUN and kinds == ["wild_boar"], "boar staggered by Ward, emitted once")
	check(hp.hp == 1000, "bounced before touching the player")
	for i in 85:
		b._physics_process(DT)
	check(b.state == Charger.State.STUN, "still staggered at 1.4 s")
	for i in 20:
		b._physics_process(DT)
	check(b.state != Charger.State.STUN, "stagger ends at 1.5 s")
	check(kinds.size() == 1, "no repeat emit")
	b.free()
	kinds.clear()
	ward.position = Vector2(200, 235)   # Ward is elsewhere: the dash misses it
	b = await _spawn("wild_boar", Vector2(100, 135))
	await _run_boar(b, Charger.State.RECOVER)
	check(b.state == Charger.State.RECOVER and kinds.is_empty(), "dash that misses the Ward does not trigger")
	b.free()
	ward.free()
	player.position = Vector2(170, 135)

	# --- Jurig Leuweung: Bind ---
	var j := await _spawn("jurig_leuweung", Vector2(190, 135))
	var full: float = j.poise
	j.hurtbox.receive(_hit())
	check(is_equal_approx(j.poise, full - 10.0) and kinds.is_empty(), "hit while not Bound: normal poise, no trigger")
	j.free()
	j = await _spawn("jurig_leuweung", Vector2(190, 135))
	j.status.apply(Status.Type.BOUND, 2.0)
	check(kinds == ["jurig_leuweung"], "Bind emits once")
	full = j.poise
	j.hurtbox.receive(_hit())
	check(is_equal_approx(j.poise, full - 20.0), "x2 poise damage while Bound")
	for i in 100:
		j._physics_process(DT)
	check(j.state != Chaser.State.WINDUP and j.state != Chaser.State.ATTACK, "cannot swing while Bound")
	check(kinds.size() == 1, "hit does not emit again")
	j.status.clear(Status.Type.BOUND)
	_until_chaser(j, Chaser.State.WINDUP)
	check(j.state == Chaser.State.WINDUP, "swings again once free")
	j.free()
	kinds.clear()

	# --- Pocong: Bind mid-hop ---
	var pc := await _spawn("pocong", Vector2(270, 135))
	check(pc.health.max_hp == 78 and pc.kind == "pocong", "pocong stats")
	pc.status.apply(Status.Type.BOUND, 2.0)
	check(pc.state != Charger.State.STUN and kinds.is_empty() and not pc.flat, "Bound outside a hop does nothing special")
	pc.free()
	pc = await _spawn("pocong", Vector2(270, 135))
	for i in 600:
		if pc.state == Charger.State.DASH:
			break
		pc._physics_process(DT)
	check(pc.state == Charger.State.DASH, "pocong hops")
	pc.status.apply(Status.Type.BOUND, 2.0)
	check(pc.state == Charger.State.STUN and pc.flat and kinds == ["pocong"], "Bound mid-hop: flat, emitted once")
	pc.hurtbox.receive(_hit())
	check(pc.health.hp == 78 - 15, "x1.5 damage while flat (hp %d)" % pc.health.hp)
	for i in 110:
		pc._physics_process(DT)
	check(pc.state == Charger.State.STUN, "flat at 1.8 s")
	for i in 20:
		pc._physics_process(DT)
	check(pc.state != Charger.State.STUN and not pc.flat, "up again after 2 s")
	pc.hurtbox.receive(_hit())
	check(pc.health.hp == 78 - 15 - 10, "normal damage once up (hp %d)" % pc.health.hp)
	pc.free()
	kinds.clear()

	# --- Genderuwo: Bolt during the throw wind-up ---
	var gd := await _spawn("genderuwo", Vector2(290, 135))
	check(gd.health.max_hp == 195 and gd.kind == "genderuwo", "genderuwo stats")
	gd.hurtbox.receive(_bolt())
	check(not gd.throwing and gd.state != Chaser.State.STAGGER and kinds.is_empty(), "Bolt outside the wind-up does not trigger")
	gd.free()
	gd = await _spawn("genderuwo", Vector2(290, 135))
	gd.cooldown = 0.0
	for i in 20:
		if gd.throwing:
			break
		gd._physics_process(DT)
	check(gd.throwing and gd.rock.visible, "genderuwo holds the rock while winding up")
	gd.hurtbox.receive(_hit())
	check(gd.throwing and kinds.is_empty(), "plain hit does not shatter the rock")
	var h1: int = gd.health.hp
	gd.hurtbox.receive(_bolt())
	check(gd.health.hp == h1 - 10 - Genderuwo.ROCK_DAMAGE, "Bolt plus rock damage (hp %d)" % gd.health.hp)
	check(gd.state == Chaser.State.STAGGER and gd.stagger_time == 1.5 and not gd.throwing and not gd.rock.visible, "staggered 1.5 s, rock gone")
	check(kinds == ["genderuwo"], "genderuwo weakness emitted once")
	for i in 100:
		gd._physics_process(DT)
	check(gd.state != Chaser.State.STAGGER, "stagger ends at 1.5 s")
	gd.free()
	kinds.clear()

	# --- Arca: Dash-strike x3. Tuyul: one Burst clears the swarm ---
	var fp := FakePlayer.new()
	fp.add_child(fp.health)
	fp.position = Vector2(-1000, 0)
	root.add_child(fp)
	var ar := await _spawn("arca", Vector2(-960, 0))
	check(ar.health.max_hp == 78 and ar.kind == "arca", "arca stats")
	var ds_data := SpellData.for_glyph("jawa_na")
	var ds := ds_data.scene.instantiate()
	ds.caster = fp
	ds.data = ds_data
	ds.direction = Vector2.RIGHT
	root.add_child(ds)
	var ds_dmg: int = ds.damage
	for i in 15:
		await physics_frame
	check(ar.health.hp == 78 - 3 * ds_dmg and kinds == ["arca"], "dash-strike does x3 (hp %d)" % ar.health.hp)
	ar.free()
	kinds.clear()
	ar = await _spawn("arca", Vector2(-960, 0))
	ar.hurtbox.receive(_hit())
	check(ar.health.hp == 68 and kinds.is_empty(), "plain hit is x1")
	ar.free()
	fp.position = Vector2(-1000, 0)
	var swarm: Array[EnemyBase] = []
	for p in [Vector2(-980, 0), Vector2(-1000, 30), Vector2(-1020, -20), Vector2(-985, 40)]:
		swarm.append(await _spawn("tuyul", p))
	check(swarm[0].health.max_hp == 31 and swarm[0].kind == "tuyul", "tuyul stats")
	var bd := SpellData.for_glyph("sunda_ca")
	var burst := bd.scene.instantiate()
	burst.caster = fp
	burst.data = bd
	burst.global_position = fp.global_position
	root.add_child(burst)
	for i in 4:
		await physics_frame
	var alive := 0
	for e in swarm:
		alive += int(e.health.hp > 0)
	check(alive == 0, "one Burst clears the swarm (%d alive)" % alive)
	for e in swarm:
		e.free()
	fp.free()
	kills.clear()

	# --- Dummy ---
	var game := root.get_node("Game")
	var ilmu: int = game.ilmu
	var d := await _spawn("dummy", Vector2(300, 135))
	for i in 12:
		d.hurtbox.receive(_hit())   # 100 HP, 10 each: the tenth defeats it
	check(kills == ["dummy"], "dummy emits enemy_killed once per defeat")
	check(game.ilmu == ilmu and not d.dead and d.is_inside_tree(), "no Ilmu, not dead, still in the tree")
	check(not game.killed.has(""), "never in Game.killed")
	for i in 100:
		d._physics_process(DT)
	await create_timer(1.6).timeout
	check(d.health.hp == d.health.max_hp, "refilled after the beat")
	for i in 10:
		d.hurtbox.receive(_hit())
	check(kills == ["dummy", "dummy"], "defeated again emits again")
	d.free()

	quit(1 if fails > 0 else 0)


func _run_boar(b: Charger, st: Charger.State) -> void:
	for i in 600:
		await physics_frame
		b._physics_process(DT)
		if b.state == st:
			return


func _spawn(n: String, pos: Vector2) -> EnemyBase:
	var e := (load("res://entities/enemies/%s.tscn" % n) as PackedScene).instantiate() as EnemyBase
	e.position = pos
	root.add_child(e)
	await process_frame
	e.set_physics_process(false)
	return e


func _hit() -> Hitbox:
	var h := Hitbox.new()
	h.damage = 10
	h.source = player
	return h


func _bolt() -> Hitbox:
	var h := Bolt.new()
	h.damage = 10
	h.source = player
	return h


func _until(s: Shooter, st: Shooter.State) -> void:
	for i in 2000:
		if s.state == st:
			return
		s._physics_process(DT)


func _until_chaser(s: Chaser, st: Chaser.State) -> void:
	for i in 2000:
		if s.state == st:
			return
		s._physics_process(DT)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
