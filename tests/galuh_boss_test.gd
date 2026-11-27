extends SceneTree
## Barma Wijaya test (v9): mirror step copies, the shadow rule, king hit shatters copies, cleave, glamour, defeat, cond.

const DT := 1.0 / 60.0
var fails := 0
var player: CharacterBody2D
var player_hp: Health
var game: Node
var events: Node
var defeated: Array[String] = []


func _initialize() -> void:
	await process_frame
	game = root.get_node("Game")
	events = root.get_node("Events")
	game.save_path = "user://test_galuh_boss.json"
	events.boss_defeated.connect(func(id: String) -> void: defeated.append(id))
	player = CharacterBody2D.new()
	player.add_to_group("player")
	player.position = Vector2(200, 135)
	player_hp = Health.new()
	player_hp.max_hp = 500
	player_hp.hp = 500
	player.add_child(player_hp)
	var phb := Hurtbox.new()
	phb.name = "Hurtbox"
	phb.health = player_hp
	player.add_child(phb)
	root.add_child(player)
	var b := (load("res://entities/bosses/barma_wijaya.tscn") as PackedScene).instantiate() as BarmaWijaya
	b.position = Vector2(100, 135)
	root.add_child(b)
	await process_frame
	b.set_physics_process(false)
	var ilmu0: int = game.ilmu

	check(b.is_in_group("boss") and b.is_in_group("enemy") and b.visible, "groups, visible with empty cond")
	check(b.health.max_hp == 2040 and b.unique_id == "barma_wijaya", "stats")
	for i in 600:
		b._physics_process(DT)
	check(b.attacks > 0 and b.engaged, "phase 1 attacks")

	# the rule (v9): a mirror step lets a copy out; only the king has a shadow; hitting him shatters every copy
	check(b.get_children().any(func(n: Node) -> bool: return n is BarmaWijaya.Shadow), "the king casts a shadow")
	check(b._mirrors.size() == 4, "four wall mirrors")
	for k in b.copies.duplicate():   # the 10 s of phase 1 above may have let some out already
		k._break()
	b.global_position = Vector2(150, 135)
	b._enter(BarmaWijaya.State.CHASE)
	b._begin_move("step")
	check(b.copies.size() == 1 and (b._mirrors[b._src[b.copies[0]]] as Sprite2D).frame == 1, "mirror step: a copy steps out, its mirror cracks")
	check(not b.copies[0].get_children().any(func(n: Node) -> bool: return n is BarmaWijaya.Shadow), "a copy casts no shadow")
	var t := 0.0
	while b.state != BarmaWijaya.State.RECOVER and t < 12.0:
		b._physics_process(DT)
		t += DT
	check(b.state == BarmaWijaya.State.RECOVER and b._spots.any(func(v: Vector2) -> bool: return v.distance_to(b.global_position) < 24.0), "mirror step ends at a mirror")
	var c := b.copies[0]
	check(c.copy and c.is_in_group("enemy") and not c.is_in_group("boss") and c.unique_id == "", "copy groups")
	check(c._dmg(c.thrust_damage) == 7 and c._dmg(c.fan_damage) == 6 and b._dmg(b.thrust_damage) == 14, "copies hit half")
	check(not c.hurtbox.receive(_hit()) and not c.dead and b.copies.size() == 1, "weapon hit on a copy does nothing")
	var hp0: int = b.health.hp
	b.hurtbox.receive(_hit())
	check(b.health.hp == hp0 - 10 and b.copies.is_empty() and c.dead, "hit the king: the copy shatters")
	check(b.state == BarmaWijaya.State.STUN and BossKit.is_open(b), "the king is stunned and TERBUKA")
	check((b._mirrors[0] as Sprite2D).frame == 0 and (b._mirrors[1] as Sprite2D).frame == 0, "mirrors mend")
	b.hurtbox.receive(_hit())
	check(b.health.hp == hp0 - 20, "king hit while stunned")
	for i in int(b.stun_time / DT) + 2:
		b._physics_process(DT)
	check(b.state != BarmaWijaya.State.STUN, "stun ends")

	# royal cleave: a miss costs one heavy hit at most; the wind-up is 15% longer
	b.global_position = Vector2(150, 135)
	player.position = Vector2(190, 135)
	b._enter(BarmaWijaya.State.CHASE)
	var php: int = player_hp.hp
	b._begin_move("cleave")
	t = 0.0
	while player_hp.hp == php and t < 4.0:
		b._physics_process(DT)
		t += DT
	check(t >= b.cleave_windup * BarmaWijaya.WIND - 0.05, "cleave wind-up x1.15 (%.2f s)" % t)
	check(php - player_hp.hp == BossKit.boss_damage(b.cleave_damage), "cleave hits once, scaled (%d)" % (php - player_hp.hp))
	t = 0.0
	while b.state != BarmaWijaya.State.RECOVER and t < 12.0:
		b._physics_process(DT)
		t += DT
	check(b.state == BarmaWijaya.State.RECOVER and b._rec >= 2.0, "cleave leaves a punish window")
	check(php - player_hp.hp == BossKit.boss_damage(b.cleave_damage), "nothing else landed")

	# glamour at 70%: up to 3 copies step out of the mirrors, he is untouchable while they shuffle
	b.health.take_damage(b.health.hp - (b.health.max_hp * 70 / 100 - 1), player)
	check(b.state == BarmaWijaya.State.GLAMOUR and b.health.is_invincible() and b.glamours == 1, "glamour at 70%, king untouchable")
	await process_frame
	check(b.copies.size() == 3, "3 copies (%d)" % b.copies.size())
	hp0 = b.health.hp
	b.hurtbox.receive(_hit())
	check(b.health.hp == hp0 and b.copies.size() == 3, "no damage while they shuffle")
	for i in int(b.glamour_time / DT) + 2:
		b._physics_process(DT)
		for k in b.copies:
			k.set_physics_process(false)
	check(not b.health.is_invincible() and b.state != BarmaWijaya.State.GLAMOUR, "the king can be hit after the shuffle")
	b.copies[0].hurtbox.receive(_bolt())
	check(b.copies[0].dead == false and b.copies.size() == 2, "a spell breaks one copy")
	b.hurtbox.receive(_hit())
	check(b.health.hp == hp0 - 10 and b.copies.is_empty() and b.state == BarmaWijaya.State.STUN and BossKit.is_open(b), "king hit: all copies shatter, stun + TERBUKA")
	await create_timer(0.4).timeout
	check(root.get_children().filter(func(n: Node) -> bool: return n is BarmaWijaya).size() == 1, "broken copies freed")

	# every move runs to its end and leaves a recovery window (set-pieces: >= 2 s)
	check(b.phase() == 2 and b.moves_used.size() > 0, "phase 2 after the first glamour, moves counted")
	for mv in ["thrust", "fan", "step", "cleave", "decree", "mirror"]:
		b.global_position = Vector2(150, 135)
		player.position = Vector2(190, 135)
		b._enter(BarmaWijaya.State.CHASE)
		b._begin_move(mv)
		check(b.moves_used.get(mv, 0) >= 1, "move counted: " + mv)
		t = 0.0
		while b.state != BarmaWijaya.State.RECOVER and t < 12.0:
			b._physics_process(DT)
			t += DT
		check(b.state == BarmaWijaya.State.RECOVER and t < 12.0, "move ends in recovery: " + mv)
		if mv in BarmaWijaya.HEAVY:
			check(b._rec >= 2.0, "punish window after " + mv)
	check(not b._deck.has("flurry") and not b._deck.has("coronation"), "cut moves are gone")
	for k in b.copies.duplicate():
		k._break()
	b._enter(BarmaWijaya.State.CHASE)
	b.global_position = Vector2(100, 135)

	# no new glamour above 35%, then the second one
	b.health.take_damage(b.health.hp - (b.health.max_hp * 35 / 100 + 1), player)   # boss revamp v9: max_hp is scaled
	check(b.state != BarmaWijaya.State.GLAMOUR, "no glamour between marks")
	b.health.take_damage(1, player)
	check(b.state == BarmaWijaya.State.GLAMOUR and b.glamours == 2, "second glamour at 35%")
	await process_frame
	for n in b.copies.duplicate():
		n.hurtbox.receive(_bolt())
	check(b.copies.is_empty() and b.state == BarmaWijaya.State.STUN, "second glamour broken")

	# defeat: kneels, never freed
	b.health.take_damage(5000, player)
	check(b.dead and not b.is_in_group("boss") and not b.is_in_group("enemy"), "inert after defeat")
	await create_timer(0.6).timeout
	check(defeated == ["barma_wijaya"], "boss_defeated once: %s" % [defeated])
	check(is_instance_valid(b) and not b.is_queued_for_deletion(), "no corpse freed: he kneels and stays")
	check(game.killed.count("barma_wijaya") == 1 and game.ilmu == ilmu0 + 220, "in Game.killed, Ilmu 220")
	b.free()

	# stays defeated on reload
	var again := (load("res://entities/bosses/barma_wijaya.tscn") as PackedScene).instantiate()
	root.add_child(again)
	check(again.is_queued_for_deletion(), "stays defeated on reload")
	game.killed.clear()

	# cond: hidden and inert until it holds
	var hid := (load("res://entities/bosses/barma_wijaya.tscn") as PackedScene).instantiate() as BarmaWijaya
	hid.cond = "flag:test_galuh_throne"
	root.add_child(hid)
	await process_frame
	check(not hid.visible and not hid.is_physics_processing() and not hid.is_in_group("enemy"), "hidden while cond false")
	game.set_flag("test_galuh_throne", false)
	check(hid.visible and hid.is_physics_processing() and hid.is_in_group("enemy"), "shown when cond holds")
	hid.free()
	game.flags.erase("test_galuh_throne")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.save_path))
	quit(1 if fails > 0 else 0)


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


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
