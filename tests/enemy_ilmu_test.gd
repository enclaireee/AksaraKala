extends SceneTree
## Ilmu award, unique kills, floating label.

var fails := 0
var killed_events := 0


func _initialize() -> void:
	var game := root.get_node("Game")
	game.save_path = "user://test_enemy_ilmu.json"
	game._reset()
	root.get_node("Events").enemy_killed.connect(func(_e, _i): killed_events += 1)
	var player := Node2D.new()
	player.add_to_group("player")
	player.position = Vector2(5000, 0)
	root.add_child(player)

	var c := await _spawn(game)
	var h := Hitbox.new()
	h.damage = 999
	h.source = player
	c.hurtbox.receive(h)
	c.hurtbox.receive(h)
	check(game.ilmu == 6, "chaser awards 6 Ilmu once, got %d" % game.ilmu)
	check(killed_events == 1, "enemy_killed emitted once")
	check(game.killed.is_empty(), "non-unique never in killed")
	var labels := 0
	for n in root.get_children():
		if n is Label:
			labels += 1
	check(labels == 1, "floating label spawned")

	var u := await _spawn(game, "test_boss")
	u.hurtbox.receive(h)
	check("test_boss" in game.killed, "unique id recorded")
	var again := (load("res://entities/enemies/chaser.tscn") as PackedScene).instantiate() as Chaser
	again.unique_id = "test_boss"
	root.add_child(again)
	check(again.is_queued_for_deletion(), "dead unique frees itself on ready")

	await process_frame
	h.free()
	game._reset()
	DirAccess.remove_absolute("user://test_enemy_ilmu.json")
	quit(1 if fails > 0 else 0)


func _spawn(_game: Node, id := "") -> Chaser:
	var n := (load("res://entities/enemies/chaser.tscn") as PackedScene).instantiate() as Chaser
	n.unique_id = id
	root.add_child(n)
	await process_frame
	n.set_physics_process(false)
	return n


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
