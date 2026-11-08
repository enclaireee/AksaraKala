extends SceneTree
## Bandung Bondowoso test: shield, beats, Jawa Ca, pillar cap and ring, phase 2, defeat. Steps the boss by hand.

const DT := 1.0 / 60.0
var fails := 0
var player: CharacterBody2D
var defeated: Array[String] = []


func _initialize() -> void:
	await process_frame
	var game := root.get_node("Game")
	var events := root.get_node("Events")
	game.save_path = "user://test_bondowoso.json"
	events.boss_defeated.connect(func(id: String) -> void: defeated.append(id))
	player = CharacterBody2D.new()
	player.add_to_group("player")
	player.position = Vector2(200, 135)
	root.add_child(player)
	var b := (load("res://entities/bosses/bandung_bondowoso.tscn") as PackedScene).instantiate() as BandungBondowoso
	b.position = Vector2(100, 135)
	root.add_child(b)
	await process_frame
	b.set_physics_process(false)
	var hit := Hitbox.new()
	hit.damage = 10
	hit.source = player

	check(b.is_in_group("boss") and b.is_in_group("enemy"), "groups")
	check(b.health.max_hp == 3100 and b.phase == 1 and b.kind == "bandung_bondowoso", "stats and marker kind")
	check(b.standing() == 1, "opens with 1 pillar: %d" % b.standing())

	# shield
	var hp0: int = b.health.hp
	check(not b.hurtbox.receive(hit) and b.health.hp == hp0 and b.shield_flashes == 1, "shielded: no damage, flash")
	b.health.take_damage(10, player, true)
	check(b.health.hp == hp0, "shield soaks ignore-i-frame damage")

	# beat exposes, one hit breaks
	var p: Pillar = b.pillars[0]
	p.hurtbox.receive(hit)
	check(not p.dead and p.health.hp == 140, "unexposed pillar takes damage and survives")
	b.engaged = false
	events.spell_cast.emit("jawa_ca", 1.0)   # not engaged yet
	check(not p.is_exposed(), "no beat before the fight")
	b._physics_process(DT)
	check(b.engaged, "engaged when the player is near")
	b._beat()
	check(p.is_exposed(), "beat exposes pillars")
	for i in int(b.expose_time / DT) + 5:
		p.tick(DT)
	check(not p.is_exposed(), "exposure ends after 3 s")
	b.pillars[0].expose(3.0)
	p.hurtbox.receive(hit)
	check(p.dead and b.standing() == 0, "one hit breaks an exposed pillar")
	await process_frame

	# no pillars: full damage
	hp0 = b.health.hp
	check(b.hurtbox.receive(hit) and b.health.hp == hp0 - 10, "damage lands with 0 pillars")

	# Jawa Ca beat and cooldown (build timer keeps raising pillars; ignore them)
	b._raise(Vector2(100, 200))
	var q: Pillar = b.pillars[b.pillars.size() - 1]
	q.exposed_left = 0.0
	b._ca_cd = 0.0
	events.spell_cast.emit("sunda_ca", 1.0)
	check(not q.is_exposed(), "other glyph: no beat")
	events.spell_cast.emit("jawa_ca", 1.0)
	check(q.is_exposed() and b.dawn == 0.0, "Jawa Ca beats at once")
	q.exposed_left = 0.0
	events.spell_cast.emit("jawa_ca", 1.0)
	check(not q.is_exposed(), "Jawa Ca on cooldown")
	for i in int(b.ca_cooldown / DT) + 2:
		b._physics_process(DT)
		q.exposed_left = 0.0
	events.spell_cast.emit("jawa_ca", 1.0)
	check(q.is_exposed(), "Jawa Ca again after 8 s")

	# natural beat every 20 s
	q.exposed_left = 0.0
	b.dawn = 0.0
	for i in int(b.beat_every / DT) + 2:
		b._physics_process(DT)
		if q.is_exposed():
			break
	check(q.is_exposed(), "dawn bar fills and beats")

	# cap 3 and ring distance
	player.position = Vector2(100, 135)   # near the boss; ring spots still keep 32 px from the player
	for i in int(60.0 / DT):
		b._physics_process(DT)
		for r in b.pillars:
			r.exposed_left = 0.0
	check(b.standing() == 3, "cap 3: %d" % b.standing())
	for pl in b.pillars:
		var d: float = pl.global_position.distance_to(Vector2(100, 135))
		if pl.global_position != Vector2(100, 200):
			check(d >= 79.9 and d <= 128.1, "ring 80-128 px: %f" % d)
			check(pl.global_position.distance_to(player.global_position) >= 32.0, "32 px from the player")

	# phase 2
	for pl in b.pillars.duplicate():
		pl.expose(3.0)
		pl.hurtbox.receive(hit)
	await process_frame
	check(b.standing() == 0 or b.pillars.size() == b.standing(), "pillars cleared")
	b.build_interval = b.pillar_every
	b.health.take_damage(b.health.hp - 1500, player)
	check(b.phase == 2 and b.state == BandungBondowoso.State.PAUSE, "phase 2 at 50% with a pause")
	check(b.build_interval == 6.0, "phase 2 builds every 6 s")
	var n: int = b.standing()
	var t := 0.0
	while b.standing() <= n and t < 8.0:
		b._physics_process(DT)
		t += DT
	check(t < 8.0 and t > 1.0, "pillar within ~6 s + 1.5 s rise: %f" % t)
	var marks_before := root.get_child_count()
	for i in int(5.2 / DT):
		b._physics_process(DT)
	check(b._marks.any(func(m: Dictionary) -> bool: return m.kind == "debris") or root.get_child_count() != marks_before, "debris marks near the player")

	# every move runs to its end; heavy moves leave a 2 s+ window; temples is the phase 2 limit break
	player.position = Vector2(200, 135)
	for mv in ["boulder", "stomp", "fist", "quake", "pillar_crush", "leap", "temples"]:
		b.global_position = Vector2(100, 135)
		b._enter(BandungBondowoso.State.CHASE)
		b._begin_move(mv)
		check(b.moves_used.get(mv, 0) >= 1, "move counted: " + mv)
		var mt := 0.0
		while b.state != BandungBondowoso.State.RECOVER and mt < 12.0:
			b._physics_process(DT)
			mt += DT
		check(b.state == BandungBondowoso.State.RECOVER and mt < 12.0, "move ends in recovery: " + mv)
		if mv in BandungBondowoso.HEAVY:
			check(b._rec >= 2.0, "punish window after " + mv)
	check(b.body.position == b._body0, "leap ends on the ground")
	check(b._ult_cd > 0.0, "temples is on cooldown")
	b.global_position = Vector2(100, 135)
	b._enter(BandungBondowoso.State.CHASE)

	# defeat
	for pl in b.pillars.duplicate():
		pl.expose(3.0)
		pl.hurtbox.receive(hit)
	await process_frame
	b.health.take_damage(5000, player)
	await create_timer(0.6).timeout
	check(defeated == ["bandung_bondowoso"], "boss_defeated once: %s" % [defeated])
	check(game.killed.count("bandung_bondowoso") == 1, "in Game.killed once")
	check(get_nodes_in_group("pillar").is_empty(), "pillars gone")
	hit.free()
	game.killed.clear()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.save_path))
	quit(1 if fails > 0 else 0)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
