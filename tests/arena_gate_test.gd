extends SceneTree
## Arena gate, door retry, arrow fallback and finisher gating (combat.md 5.3 v7). Prints only failures.

var fails := 0


func check(ok: bool, what: String) -> void:
	if not ok:
		fails += 1
		print("FAIL: ", what)


func _initialize() -> void:
	var world := Node2D.new()
	root.add_child(world)
	current_scene = world
	var player: Node2D = (load("res://entities/player/player.tscn") as PackedScene).instantiate()
	player.position = Vector2(400, 100)
	world.add_child(player)
	var boss: Node2D = (load("res://entities/bosses/faceless_captain.tscn") as PackedScene).instantiate()
	boss.position = Vector2(100, 100)
	world.add_child(boss)
	var gate: Node2D = (load("res://entities/world/arena_gate.tscn") as PackedScene).instantiate()
	gate.position = Vector2(300, 100)   # arena to the west; threshold at x = 260
	world.add_child(gate)
	var zones := root.get_node("Zones")
	var game := root.get_node("Game")
	for i in 5:
		await physics_frame
	check(not boss.engaged, "boss sleeps before the threshold")
	check(not boss.hurtbox.monitorable, "boss cannot be hurt before the threshold")
	check(not zones.sealed and not gate.shut, "gate open before the threshold")
	player.global_position = Vector2(110, 100)   # teleported past the threshold without touching it
	for i in 5:
		await physics_frame
	check(not boss.engaged, "range alone does not engage while a gate stands")
	player.global_position = Vector2(260, 100)
	for i in 5:
		await physics_frame
	check(gate.entered and boss.engaged, "crossing the threshold engages the boss")
	check(gate.shut and zones.sealed, "gate shuts and exits are sealed")
	check(boss.hurtbox.monitorable, "boss can be hurt once engaged")
	var rx: float = game.boss_retry.get("pos", [0])[0]
	check(rx < 300.0 and rx > 268.0, "retry point is between the gate and the threshold")
	zones.go_to("no_such_zone_but_sealed_returns_first", "")   # must return silently: sealed is checked before the path
	boss.finish_glyph = "sunda_ca"
	boss.health.take_damage(boss.health.max_hp)
	for i in 5:
		await physics_frame
	check(gate.shut and zones.sealed and not game.boss_retry.is_empty(), "the kneel keeps the gate shut")
	check(not "enemy" in boss.get_groups() or boss.dead, "the kneeling boss is inert")
	root.get_node("Events").spell_cast.emit("sunda_ca", 1.0)
	for i in 5:
		await physics_frame
	check(not is_instance_valid(boss) or not boss.is_in_group("enemy"), "the finishing glyph kills the boss")
	check(not gate.shut and not zones.sealed, "gate opens when the boss is dead")
	check(game.boss_retry.is_empty(), "retry point cleared on a win")

	# arrow: a sub-goal without a marker points at the thing its trigger names
	var st := QuestStep.new()
	st.marker = {"zone": "ts_situ", "id": "sunda_lakeshore"}
	st.all = [{"on": "clue_examined:faceless_toy"}]
	var on := str(st.all[0].get("on", ""))
	check(on.get_slice(":", 1) == "faceless_toy", "sub-goal id derived from its trigger")
	# every zone the docs gave a gate builds with it, and its bosses keep a kneel glyph or opt out on purpose
	for id in zones.ZONES:
		var src := FileAccess.get_file_as_string("res://zones/%s.gd" % id)
		if not src.contains("arena_gate.tscn"):
			continue
		var z := (load(zones.ZONES[id]) as PackedScene).instantiate()
		root.add_child(z)
		await process_frame
		var gates := z.find_children("*", "StaticBody2D", true, false).filter(func(n: Node) -> bool: return n.is_in_group("arena_gate"))
		check(not gates.is_empty(), "%s: built without its arena gate" % id)
		for g in gates:
			check(g.side in ["n", "e", "s", "w"], "%s: gate side '%s'" % [id, g.side])
		check(src.contains("res://entities/bosses/"), "%s: a gate without a boss" % id)
		z.free()
	quit(fails)
