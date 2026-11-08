extends SceneTree
## Barma Wijaya test: glamour copies, weapon vs spell hits on copies, real one immune then stunned, defeat, cond.

const DT := 1.0 / 60.0
var fails := 0
var player: CharacterBody2D
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
	root.add_child(player)
	var b := (load("res://entities/bosses/barma_wijaya.tscn") as PackedScene).instantiate() as BarmaWijaya
	b.position = Vector2(100, 135)
	root.add_child(b)
	await process_frame
	b.set_physics_process(false)
	var ilmu0: int = game.ilmu

	check(b.is_in_group("boss") and b.is_in_group("enemy") and b.visible, "groups, visible with empty cond")
	check(b.health.max_hp == 2400 and b.unique_id == "barma_wijaya", "stats")
	for i in 600:
		b._physics_process(DT)
	check(b.attacks > 0 and b.engaged, "phase 1 attacks")

	# glamour at 70%
	b.health.take_damage(720, player)
	check(b.state == BarmaWijaya.State.GLAMOUR and b.health.is_invincible(), "glamour at 70%, king invincible")
	await process_frame
	check(b.copies.size() == 3, "3 copies (%d)" % b.copies.size())
	var c := b.copies[0]
	check(c.copy and c.is_in_group("enemy") and not c.is_in_group("boss") and c.unique_id == "", "copy groups")
	check(c._dmg(c.thrust_damage) == 7 and c._dmg(c.fan_damage) == 6 and b._dmg(b.thrust_damage) == 14, "copies hit half")
	check(not c.hurtbox.receive(_hit()) and not c.dead and b.copies.size() == 3, "weapon hit on a copy does nothing")
	var hp0: int = b.health.hp
	b.hurtbox.receive(_hit())
	b.hurtbox.receive(_bolt())
	check(b.health.hp == hp0, "king takes no damage while copies stand")
	c.hurtbox.receive(_bolt())
	check(c.dead and b.copies.size() == 2, "a spell breaks a copy")
	b.copies[0].hurtbox.receive(_bolt())
	check(b.state != BarmaWijaya.State.STUN and b.health.is_invincible(), "still immune with one copy")
	b.copies[0].hurtbox.receive(_bolt())
	check(b.copies.is_empty() and b.state == BarmaWijaya.State.STUN and not b.health.is_invincible(), "last copy: stunned, open")
	b.hurtbox.receive(_hit())
	check(b.health.hp == hp0 - 10, "king hit while stunned")
	for i in int(b.stun_time / DT) + 2:
		b._physics_process(DT)
	check(b.state != BarmaWijaya.State.STUN, "stun ends")
	await create_timer(0.4).timeout
	check(root.get_children().filter(func(n: Node) -> bool: return n is BarmaWijaya).size() == 1, "broken copies freed")

	# every move runs to its end and leaves a recovery window (set-pieces: >= 2 s)
	check(b.phase() == 2 and b.moves_used.size() > 0, "phase 2 after the first glamour, moves counted")
	for mv in ["thrust", "fan", "flurry", "decree", "mirror", "coronation"]:
		b.global_position = Vector2(150, 135)
		b._enter(BarmaWijaya.State.CHASE)
		b._begin_move(mv)
		check(b.moves_used.get(mv, 0) >= 1, "move counted: " + mv)
		var t := 0.0
		while b.state != BarmaWijaya.State.RECOVER and t < 12.0:
			b._physics_process(DT)
			t += DT
		check(b.state == BarmaWijaya.State.RECOVER and t < 12.0, "move ends in recovery: " + mv)
		if mv in BarmaWijaya.HEAVY:
			check(b._rec >= 2.0, "punish window after " + mv)
	b._enter(BarmaWijaya.State.CHASE)
	b.global_position = Vector2(100, 135)

	# no new glamour above 35%, then the second one
	b.health.take_damage(b.health.hp - 841, player)
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
