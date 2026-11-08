extends SceneTree
## Hariang Banga test: front guard x0.2, back hits land, Na Dash-strike breaks the guard, yield at 15%, cond.

const DT := 1.0 / 60.0
var fails := 0
var player: CharacterBody2D
var game: Node
var events: Node
var defeated: Array[String] = []


class FakePlayer extends Node2D:
	var health := Health.new()
	var class_id := ""


func _initialize() -> void:
	await process_frame
	game = root.get_node("Game")
	events = root.get_node("Events")
	game.save_path = "user://test_duel.json"
	events.boss_defeated.connect(func(id: String) -> void: defeated.append(id))
	player = CharacterBody2D.new()
	player.add_to_group("player")
	player.position = Vector2(300, 135)
	root.add_child(player)
	var b := (load("res://entities/bosses/hariang_banga.tscn") as PackedScene).instantiate() as HariangBanga
	b.position = Vector2(100, 135)
	root.add_child(b)
	await process_frame
	b.set_physics_process(false)
	var ilmu0: int = game.ilmu

	check(b.is_in_group("boss") and b.visible and b.health.max_hp == 2800, "groups, stats")
	b.facing = PI   # away from the player; he turns to face him
	for i in 60:
		b._physics_process(DT)
	check(absf(angle_difference(b.facing, 0.0)) < 0.01, "turns to face the player")
	player.position = Vector2(200, 135)
	for i in 600:
		b._physics_process(DT)
	check(b.attacks > 0 and b.moves_used.size() > 0, "attacks, moves counted")

	# every move runs to its end (phase 2 moves too); heavy moves leave a 2 s+ window; an unanswered parry opens him
	b.phase = 2
	for mv in ["cut", "lunge", "wave", "iaido", "triple_step", "parry", "river_lunge", "flood", "tsunami"]:
		b._stop_attack()
		b.global_position = Vector2(150, 135)
		b.facing = 0.0
		b.open_left = 0.0
		b._enter(HariangBanga.State.CHASE)
		b._begin_move(mv)
		check(b.moves_used.get(mv, 0) >= 1, "move counted: " + mv)
		var t := 0.0
		while b.state != HariangBanga.State.RECOVER and t < 12.0:
			b._physics_process(DT)
			t += DT
		check(b.state == HariangBanga.State.RECOVER and t < 12.0, "move ends in recovery: " + mv)
		if mv in HariangBanga.HEAVY and mv != "parry":
			check(b._rec >= 2.0, "punish window after " + mv)
		if mv == "parry":
			check(b.open_left > 0.0, "an unanswered parry leaves him open")
	# a hit during the glow is negated and countered
	b.global_position = Vector2(150, 135)
	b.facing = 0.0
	b._enter(HariangBanga.State.CHASE)
	b._begin_move("parry")
	b._physics_process(DT)
	var hp_p: int = b.health.hp
	b.hurtbox.receive(_hit(player))
	check(b.health.hp == hp_p, "parry glow negates the hit (%d)" % (hp_p - b.health.hp))
	b._physics_process(DT)
	check(b.state == HariangBanga.State.RECOVER and b._rec >= 2.0, "parry counters, then recovers")
	b.phase = 1

	# guard: reset to a calm pose facing the player on his right
	b.global_position = Vector2(100, 135)
	b._stop_attack()
	b._enter(HariangBanga.State.RECOVER)
	b.facing = 0.0
	player.position = Vector2(130, 135)
	var hp0: int = b.health.hp
	b.hurtbox.receive(_hit(player))
	check(b.health.hp == hp0 - 2, "front weapon hit x0.2 (%d)" % (hp0 - b.health.hp))
	hp0 = b.health.hp
	b.hurtbox.receive(_bolt(player))
	check(b.health.hp == hp0 - 10, "front spell lands in full")
	player.position = Vector2(70, 135)
	hp0 = b.health.hp
	b.hurtbox.receive(_hit(player))
	check(b.health.hp == hp0 - 10, "hit from behind lands")

	# Na Dash-strike through him breaks the guard
	var fp := FakePlayer.new()
	fp.add_child(fp.health)
	fp.position = Vector2(60, 129)
	root.add_child(fp)
	var ds_data := SpellData.for_glyph("jawa_na")
	var ds := ds_data.scene.instantiate()
	ds.caster = fp
	ds.data = ds_data
	ds.direction = Vector2.RIGHT
	hp0 = b.health.hp
	root.add_child(ds)
	var ds_dmg: int = ds.damage
	for i in 15:
		await physics_frame
	check(b.health.hp == hp0 - ds_dmg, "dash-strike lands (%d of %d)" % [hp0 - b.health.hp, ds_dmg])
	check(b.state == HariangBanga.State.STAGGER and b.open_left > 0.0, "dash-strike breaks the guard")
	player.position = Vector2(130, 135)
	hp0 = b.health.hp
	b.hurtbox.receive(_hit(player))
	check(b.health.hp == hp0 - 15, "x1.5 while open, even from the front")
	for i in int(b.stagger_time / DT) + 2:
		b._physics_process(DT)
	check(b.state != HariangBanga.State.STAGGER, "stagger ends after 2 s")
	for i in 70:
		b._physics_process(DT)
	b.global_position = Vector2(100, 135)
	b._stop_attack()
	b._enter(HariangBanga.State.RECOVER)
	b.facing = 0.0
	hp0 = b.health.hp
	b.hurtbox.receive(_hit(player))
	check(b.health.hp == hp0 - 2, "guard back after 3 s")

	# yield at 15%, never 0
	b.health.take_damage(b.health.hp - 421, player)
	await process_frame
	check(b.phase == 2 and b.state == HariangBanga.State.PHASE, "phase 2 at 50% with a pause")
	check(not b.dead, "fights on above 15%")
	b.health.take_damage(5000, player)
	await process_frame
	check(b.dead and b.health.hp > 0, "yields, never 0 hp (%d)" % b.health.hp)
	check(not b.is_in_group("boss") and not b.is_in_group("enemy"), "inert after yield")
	await create_timer(0.6).timeout
	check(defeated == ["hariang_banga"], "boss_defeated once: %s" % [defeated])
	check(is_instance_valid(b) and not b.is_queued_for_deletion(), "he stays")
	check(game.killed.count("hariang_banga") == 1 and game.ilmu == ilmu0 + 320, "in Game.killed, Ilmu 320")
	b.free()
	game.killed.clear()

	# a front hit at 16% that would kill outright still yields at 1+ hp
	var y := await _spawn("")
	y.facing = 0.0
	y.health.hp = 450
	y.hurtbox.receive(_hit(player, 9999))
	await process_frame
	check(y.dead and y.health.hp > 0, "killing blow becomes a yield (%d)" % y.health.hp)
	y.free()
	game.killed.clear()

	# cond
	var hid := await _spawn("flag:test_duel_ford")
	check(not hid.visible and not hid.is_physics_processing(), "hidden while cond false")
	game.set_flag("test_duel_ford", false)
	check(hid.visible and hid.is_physics_processing(), "shown when cond holds")
	hid.free()
	game.flags.erase("test_duel_ford")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.save_path))
	quit(1 if fails > 0 else 0)


func _spawn(cond: String) -> HariangBanga:
	var e := (load("res://entities/bosses/hariang_banga.tscn") as PackedScene).instantiate() as HariangBanga
	e.cond = cond
	e.position = Vector2(100, 135)
	root.add_child(e)
	await process_frame
	return e


func _hit(src: Node, dmg := 10) -> Hitbox:
	var h := Hitbox.new()
	h.damage = dmg
	h.source = src
	return h


func _bolt(src: Node) -> Hitbox:
	var h := Bolt.new()
	h.damage = 10
	h.source = src
	return h


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
