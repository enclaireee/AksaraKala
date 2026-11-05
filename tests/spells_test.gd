extends SceneTree
## Bolt, Ward, Bind against real enemies. Headless, steps by physics frames.

var fails := 0
var player: Dummy


class Dummy extends Node2D:
	var health := Health.new()
	var stamina := Stamina.new()
	var status := Status.new()
	var class_id := ""
	var atk_speed := 1.0
	var mult := 1.0

	func spell_mult() -> float:
		return mult


func _initialize() -> void:
	player = Dummy.new()
	player.add_child(player.health)
	player.add_child(player.stamina)
	player.add_child(player.status)
	player.position = Vector2(5000, 0)
	root.add_child(player)
	await physics_frame

	# Bolt vs chaser: 30, flinch; 0.7 -> 21
	var c := await _enemy("chaser", Vector2(60, 0))
	await _bolt(1.0, Vector2.ZERO)
	check(c.health.hp == 10, "bolt deals 30 (hp %d)" % c.health.hp)
	check((c as Chaser).state == Chaser.State.FLINCH, "bolt flinches chaser")
	c.queue_free()
	c = await _enemy("chaser", Vector2(60, 0))
	await _bolt(0.7, Vector2.ZERO)
	check(c.health.hp == 40 - 21, "rough bolt deals 21 (hp %d)" % c.health.hp)
	c.queue_free()

	# Bolt vs tank: 45 poise
	var t := await _enemy("tank", Vector2(60, 0))
	var p0: float = t.poise
	await _bolt(1.0, Vector2.ZERO)
	check(is_equal_approx(p0 - t.poise, 45.0), "bolt removes 45 poise (%f)" % (p0 - t.poise))
	t.queue_free()

	# Ward
	var h := player.health
	var w1 := await _spell("sunda_ga", 1.0)
	check(h.shield == 40, "ward shield 40")
	h.take_damage(40, null, true)
	check(h.hp == h.max_hp, "ward absorbed 40")
	await physics_frame
	await physics_frame
	check(h.shield == 0 and not is_instance_valid(w1), "ward gone at 0 shield")
	h.take_damage(10, null, true)
	check(h.hp == h.max_hp - 10, "hp drops after ward")
	w1 = await _spell("sunda_ga", 1.0)
	var w2 := await _spell("sunda_ga", 1.0)
	await physics_frame
	check(get_nodes_in_group("ward").size() == 1 and not is_instance_valid(w1), "recast leaves one ward")
	check(h.shield == 40, "recast shield intact (%d)" % h.shield)
	for i in 520:
		await physics_frame
	check(not is_instance_valid(w2) and h.shield == 0, "ward ends after 8 s")

	# Bind
	var near := await _enemy("chaser", Vector2(500, 0))
	var far := await _enemy("chaser", Vector2(600, 0))
	player.position = Vector2(500, 0) + Vector2(-110, 0)   # in notice range of both... bind at near's side
	var b := (SpellData.for_glyph("sunda_nga").scene as PackedScene).instantiate()
	b.caster = player
	b.data = SpellData.for_glyph("sunda_nga")
	b.global_position = near.global_position + Vector2(-50, 0)   # 50 from near, 150 from far; far set to 100 below
	far.global_position = b.global_position + Vector2(100, 0)
	root.add_child(b)
	await physics_frame
	check(near.status.speed_mult() == 0.0, "bind roots enemy at 50 px")
	check(far.status.speed_mult() == 1.0, "bind skips enemy at 100 px")
	var n0: Vector2 = near.global_position
	player.position = near.global_position + Vector2(-80, 0)
	for i in 30:
		await physics_frame
	check(near.global_position.distance_to(n0) < 0.5, "bound enemy does not move")

	# Burst: 40 in 64 px, nothing beyond. Warrior x0.9 damage, +25% radius.
	player.position = Vector2(0, 0)
	var bn := await _enemy("chaser", Vector2(40, 0))
	var bf := await _enemy("chaser", Vector2(76, 0))
	await _spell("sunda_ca", 1.0)
	for i in 4:
		await physics_frame
	check(bn.health.hp == 0, "burst near hp %d" % bn.health.hp)
	for i in 20:
		await physics_frame
	check(bf.health.hp == 40, "burst skips 76 px (hp %d)" % bf.health.hp)
	player.class_id = "warrior"
	bf.health.hp = 40
	await _spell("sunda_ca", 1.0)
	for i in 4:
		await physics_frame
	check(bf.health.hp == 40 - 36, "warrior burst: radius 80, damage 36 (hp %d)" % bf.health.hp)
	for i in 20:
		await physics_frame
	player.class_id = ""
	if is_instance_valid(bn): bn.queue_free()
	bf.queue_free()

	# Heal: 30% max HP scaled by spell_mult, clears Curse; Mage x1.2
	h.hp = 10
	player.status.apply(Status.Type.CURSE)
	await _spell("jawa_ha", 1.0)
	check(h.hp == 40 and not player.status.has(Status.Type.CURSE), "heal 30 and clear curse (hp %d)" % h.hp)
	player.mult = 1.5
	await _spell("jawa_ha", 1.0)
	check(h.hp == 85, "heal scaled by spell_mult 1.5 (hp %d)" % h.hp)
	player.mult = 1.0
	player.class_id = "mage"
	h.hp = 10
	await _spell("jawa_ha", 1.0)
	check(h.hp == 46, "mage heal x1.2 (hp %d)" % h.hp)
	player.class_id = ""

	# Dash-strike: moves 80 px along direction, damages, invincible
	player.position = Vector2(0, 0)
	var de := await _enemy("chaser", Vector2(40, 0))
	var d := SpellData.for_glyph("jawa_na")
	var ds := d.scene.instantiate()
	ds.caster = player
	ds.data = d
	ds.direction = Vector2.RIGHT
	root.add_child(ds)
	for i in 15:
		await physics_frame
	check(absf(player.position.x - 80.0) < 1.0, "dash moved player to %s" % player.position)
	check(de.health.hp == 40 - 25, "dash deals 25 (hp %d)" % de.health.hp)

	de.queue_free()

	# Rally: buffs on, back to normal after 10 s; recast does not stack
	var a0: float = player.atk_speed
	var r0: float = player.stamina.regen
	var r1 := await _spell("jawa_ca", 1.0)
	check(is_equal_approx(player.atk_speed, a0 * 1.3) and is_equal_approx(player.stamina.regen, r0 * 1.5), "rally buffs")
	var r2 := await _spell("jawa_ca", 1.0)
	check(is_equal_approx(player.atk_speed, a0 * 1.3), "rally recast does not stack (%f)" % player.atk_speed)
	for i in 640:
		await physics_frame
	check(not is_instance_valid(r2) and is_equal_approx(player.atk_speed, a0) and is_equal_approx(player.stamina.regen, r0), "rally ends after 10 s")

	# Summon: spawns, hits an enemy every 0.6 s, expires after 10 s
	player.position = Vector2(0, 0)
	var se := await _enemy("tank", Vector2(30, 0))
	var hp0: int = se.health.hp
	var sm := await _spell("jawa_ra", 1.0)
	for i in 80:
		await physics_frame
	check(se.health.hp <= hp0 - 30, "summon hit twice or more (hp %d of %d)" % [se.health.hp, hp0])
	for i in 600:
		await physics_frame
	check(not is_instance_valid(sm), "summon expired")
	if is_instance_valid(se): se.queue_free()

	# Spirit scaling reaches Ward and Bolt
	player.mult = 2.0
	var w3 := await _spell("sunda_ga", 1.0)
	check(h.shield == 80, "ward scaled by spell_mult (%d)" % h.shield)
	w3.queue_free()
	player.mult = 1.0

	# Every glyph maps to a spell
	for id in ["sunda_ka", "sunda_ga", "sunda_nga", "sunda_ca", "jawa_ha", "jawa_na", "jawa_ca", "jawa_ra"]:
		var sd := SpellData.for_glyph(id)
		check(sd != null and sd.scene != null, "no spell for " + id)

	# Cast gate: Mage starts at 14, Warrior needs 15; Rogue Dash-strike costs 14
	var world := Node2D.new()
	root.add_child(world)
	var p: Player = load("res://entities/player/player.tscn").instantiate()
	world.add_child(p)
	await process_frame
	p.class_id = "mage"
	p.sakti.value = 14.0
	check(p.cast.start(), "mage cannot cast at 14")
	p.cast.cancel()
	p.cast._locked_until = 0
	p.class_id = "warrior"
	check(not p.cast.start(), "warrior cast at 14")
	p.class_id = "rogue"
	check(is_equal_approx(SpellUtil.cost(p, SpellData.for_glyph("jawa_na")), 14.0), "rogue dash cost")
	p.cast._exit_cast_mode()
	world.free()

	player.free()
	quit(1 if fails > 0 else 0)


func _enemy(kind: String, pos: Vector2) -> EnemyBase:
	var n := (load("res://entities/enemies/%s.tscn" % kind) as PackedScene).instantiate() as EnemyBase
	n.position = pos
	root.add_child(n)
	await physics_frame
	n.set_physics_process(false)   # keep still; hits are what we test
	return n


func _spell(id: String, power: float) -> Node:
	var d := SpellData.for_glyph(id)
	var s := d.scene.instantiate()
	s.caster = player
	s.data = d
	s.power = power
	s.global_position = player.global_position
	root.add_child(s)
	await physics_frame
	return s


## Fires from the origin toward +x at the enemy 60 px away, then waits for it to land.
func _bolt(power: float, _unused: Vector2) -> void:
	player.position = Vector2(-1000, 0)
	var d := SpellData.for_glyph("sunda_ka")
	var s := d.scene.instantiate()
	s.caster = player
	s.data = d
	s.power = power
	s.direction = Vector2.RIGHT
	s.global_position = Vector2(20, -6)
	root.add_child(s)
	for i in 20:
		await physics_frame


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
