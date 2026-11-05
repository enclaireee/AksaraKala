extends SceneTree
## End-to-end wiring in the real room: the grove tank hurts an idle player, keris hits break its poise
## without flinching it first, a 6-enemy crowd never has more than 4 attackers (combat.md 3.1, 5.2, 8),
## and a drawn Ka casts a Bolt that hits a chaser (spells.md 1).

var fails := 0


func _initialize() -> void:
	var room: Node = load("res://zones/test_room.tscn").instantiate()
	root.add_child(room)
	var p: Player = room.get_node("Entities/Player")
	await frames(300)   # 5 s: notice, walk in, wind-up, swing
	check(p.health.hp < p.health.max_hp, "the grove never hurt the player (hp %d)" % p.health.hp)

	var tank: Chaser
	for e in get_nodes_in_group("enemy"):
		if e is Chaser:
			tank = e
	check(tank != null and tank.role == "tank", "no tank in the grove")
	if tank:
		p.health.set_invincible(60.0)
		var flinched := false
		var staggered := false
		for i in 240:   # hold attack; no mouse headless, so keep the tank where the player aims
			if not is_instance_valid(tank) or staggered:
				break
			tank.global_position = p.global_position + p.aim_dir * 16.0
			p.buffer["attack"] = p.clock
			await physics_frame
			flinched = flinched or tank.state == Chaser.State.FLINCH
			staggered = tank.state == Chaser.State.STAGGER
		check(staggered, "keris combos never broke the tank's poise")
		check(not flinched, "the tank flinched before its poise broke")

	# Crowd: 3 chasers + 3 shooters around the player, all on screen.
	for e in get_nodes_in_group("enemy"):
		e.queue_free()
	await physics_frame
	for i in 6:
		var e: Node2D = load("res://entities/enemies/%s.tscn" % ("chaser" if i < 3 else "shooter")).instantiate()
		e.position = p.global_position + Vector2.from_angle(TAU * i / 6.0) * (60.0 if i < 3 else 110.0)
		room.get_node("Entities").add_child(e)
	var most := 0
	var melee_most := 0
	for i in 480:   # 8 s
		await physics_frame
		most = maxi(most, EnemyBase.attackers(self))
		melee_most = maxi(melee_most, get_node_count_in_group("token_melee"))
	check(most <= 4, "%d enemies attacked at once" % most)
	check(melee_most <= 2, "%d melee enemies attacked at once" % melee_most)
	check(most >= 2, "the crowd barely attacked (max %d at once)" % most)

	# Cast: draw the Ka template through the controller and hit a chaser 60 px away.
	for e in get_nodes_in_group("enemy"):
		e.queue_free()
	await physics_frame
	var target: Chaser = load("res://entities/enemies/chaser.tscn").instantiate()
	target.position = p.global_position + Vector2(60, -6)
	room.get_node("Entities").add_child(target)
	await physics_frame
	p.sakti.value = 50.0
	p.aim_dir = Vector2.RIGHT   # no mouse headless; the cast keeps the aim it started with
	check(p.cast.start(), "cast did not start with 50 sakti")
	var ka: PackedVector2Array = GlyphData.by_id("sunda_ka").templates[0]
	for q in ka:
		var e := InputEventMouseMotion.new()
		e.position = Vector2(170, 60) + q * 0.3   # templates are ~500 units; about 100 px on screen
		p.cast._unhandled_input(e)
	p.cast.release()
	check(p.sakti.value == 35.0, "drawing Ka did not spend 15 sakti (left %s)" % p.sakti.value)
	await frames(60)
	check(is_instance_valid(target) and target.health.hp < target.health.max_hp, "the Bolt never hit the chaser")
	quit(1 if fails > 0 else 0)


func frames(n: int) -> void:
	for i in n:
		await physics_frame


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)
