extends SceneTree
## Sandekala fade/grab/oncor/death and the elite Kuntilanak soft-lock guard. Steps nodes by hand.

const DT := 1.0 / 60.0
var fails := 0
var player: CharacterBody2D
var hp: Health
var defeated: Array[String] = []


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	var game: Node = root.get_node("Game")
	root.get_node("Events").boss_defeated.connect(func(id: String) -> void: defeated.append(id))
	player = CharacterBody2D.new()
	player.add_to_group("player")
	player.position = Vector2(300, 135)
	player.set("motion_mode", 1)
	var hb := Hurtbox.new()
	hb.collision_layer = 2
	hb.position = Vector2(0, -6)
	var cs := CollisionShape2D.new()
	cs.shape = CircleShape2D.new()
	(cs.shape as CircleShape2D).radius = 7.0
	hb.add_child(cs)
	hp = Health.new()
	hp.max_hp = 100
	hb.health = hp
	player.add_child(hp)
	player.add_child(hb)
	root.add_child(player)
	await process_frame

	var oncors: Array[Oncor] = []
	for p in [Vector2(250, 100), Vector2(350, 100), Vector2(250, 170), Vector2(350, 170)]:
		var o := (load("res://entities/bosses/oncor.tscn") as PackedScene).instantiate() as Oncor
		o.position = p
		root.add_child(o)
		oncors.append(o)
	var s := (load("res://entities/bosses/sandekala.tscn") as PackedScene).instantiate() as Sandekala
	s.position = Vector2(300, 100)
	root.add_child(s)
	s.set_physics_process(false)   # before any physics tick: the player is inside engage_dist, so a tick would engage it
	await process_frame
	check(s.is_in_group("boss") and s.is_in_group("enemy"), "groups boss and enemy")
	check(s.boss_name_key == "BOSS_SANDEKALA" and s.health.max_hp == 1100 and not s.engaged, "boss bar contract")

	# a hit on the oncor lights it, once, and the hit does not hurt the torch for good
	var hit := Hitbox.new()
	hit.damage = 10
	hit.source = player
	oncors[0].hurtbox.receive(hit)
	check(oncors[0].lit and s.lit_count() == 1, "player hit lights the oncor")
	oncors[0].hurtbox.receive(hit)
	check(oncors[0].health.hp == oncors[0].health.max_hp, "oncor survives hits")

	# engages near the player, darkens, fades while an oncor is unlit
	s.fade_every = 1.0
	_run(s, 5)
	check(s.engaged, "engages when the player is near")
	var seen := {}
	for i in 600:
		s._physics_process(DT)
		seen[s.state] = true
		if s.state == Sandekala.State.GONE:
			break
	check(seen.has(Sandekala.State.FADING) and s.state == Sandekala.State.GONE, "fades with an oncor unlit")
	check(s.modulate.a == 0.0 and s.health.is_invincible(), "invulnerable while faded")
	check(s.overlay.color.a > 0.0, "darkness grows while engaged")
	var dmg_before := s.health.hp
	s.hurtbox.receive(hit)
	check(s.health.hp == dmg_before, "no damage while faded")

	# reappears behind the player; marker shows before the damage lands
	player.set("aim_dir", Vector2.RIGHT)
	for i in 600:
		s._physics_process(DT)
		if s.state == Sandekala.State.WINDUP:
			break
	check(s.state == Sandekala.State.WINDUP and s.marker.visible, "marker shown at reappearance")
	check(s.global_position.x < player.global_position.x, "reappears behind the player")
	check(hp.hp == 100, "no damage during the wind-up")
	s.global_position = player.global_position   # stand on the marker
	s.attack_hitbox.global_position = player.global_position
	for i in int(s.windup / DT) - 2:
		s._physics_process(DT)
	check(s.state == Sandekala.State.WINDUP and hp.hp == 100, "still no damage just before the hit")
	for i in 30:
		s._physics_process(DT)
		await physics_frame
	check(hp.hp == 86, "grab did 14")
	check(not s.health.is_invincible(), "vulnerable again after reappearing")

	# new moves: each runs to its recovery and is counted; the deck never repeats a heavy move; nightfall adds two more
	check(s.phase == 1 and s._pool().size() == 5 and not ("eclipse" in s._pool()), "phase 1 pool has 5 moves")
	for m in ["claws", "lantern", "pillars", "pulse", "grab"]:
		check(run_move(s, m), "move %s ends in RECOVER and is counted" % m)
	s.health.take_damage(600, player)
	check(s.phase == 2 and "flurry" in s._pool() and "eclipse" in s._pool(), "nightfall at 50% adds flurry and eclipse")
	for m in ["flurry", "eclipse"]:
		check(run_move(s, m), "move %s ends in RECOVER and is counted" % m)
	s._deck.clear()
	var prev := ""
	var dup := false
	for i in 60:
		var pm: String = s._pick(20.0)
		dup = dup or (pm == prev and pm in Sandekala.HEAVY)
		prev = pm
	check(not dup and prev != "", "deck: no heavy twice in a row")
	check(s.moves_used.get("fade", 0) >= 1, "the fade ambush is counted")

	# all lit: no fade
	for o in oncors:
		o.light()
	s.global_position = Vector2(300, 100)
	s._enter(Sandekala.State.CHASE)
	s.fade_timer = 0.0
	player.global_position = Vector2(300, 600)   # out of melee range
	var faded := false
	for i in 900:
		s._physics_process(DT)
		faded = faded or s.state == Sandekala.State.FADING
	check(not faded, "no fade with all four lit")

	# death: boss_defeated once
	s.health.take_damage(5000, player)
	s.health.take_damage(5000, player)
	check(defeated == ["sandekala"], "boss_defeated emitted once: %s" % [defeated])
	check("sandekala" in game.killed, "listed in killed")
	game.killed.erase("sandekala")

	# elite: inert until sq_s2 is at step 2
	game.quests.erase("sq_s2")
	var e := (load("res://entities/enemies/kuntilanak_elite.tscn") as PackedScene).instantiate() as KuntilanakElite
	e.position = Vector2(100, 100)
	root.add_child(e)
	await process_frame
	check(e.kind == "kuntilanak_elite" and e.health.max_hp == 600, "elite stats")
	check(not e.active and not e.visible and not e.is_in_group("enemy") and e.collision_layer == 0, "elite inactive early")
	game.quests["sq_s2"] = {"state": "active", "step": 1, "count": 0}
	game.changed.emit()
	check(not e.active, "elite still inactive at step 1")
	game.quests["sq_s2"] = {"state": "active", "step": 2, "count": 0}
	game.changed.emit()
	check(e.active and e.visible and e.is_in_group("enemy") and e.collision_layer == 4, "elite active at step 2")
	e.free()
	game.quests.erase("sq_s2")
	game.killed.erase("kuntilanak_elite")

	player.free()
	quit(1 if fails > 0 else 0)


## Runs one move by hand until it reaches RECOVER, with the player standing next to him.
func run_move(s: Sandekala, m: String) -> bool:
	s._enter(Sandekala.State.CHASE)
	s.global_position = Vector2(300, 100)
	player.global_position = Vector2(300, 125)
	hp.hp = hp.max_hp
	s._begin_move(m)
	for i in 900:
		s._physics_process(DT)
		if s.state == Sandekala.State.RECOVER:
			break
	return s.state == Sandekala.State.RECOVER and int(s.moves_used.get(m, 0)) >= 1


func _run(s: Sandekala, frames: int) -> void:
	for i in frames:
		s._physics_process(DT)
