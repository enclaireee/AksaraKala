extends SceneTree
## Enemy drops: chance, elites, touch pickup, bosses and dummy.

var fails := 0


class FakePlayer extends Node2D:
	var health := Health.new()


func _initialize() -> void:
	var player := FakePlayer.new()
	player.add_to_group("player")
	player.add_child(player.health)
	player.health.max_hp = 100
	root.add_child(player)
	await process_frame
	player.health.hp = 50   # Health._ready fills to max
	var game := root.get_node("Game")
	game.save_path = "user://drops_test_save.json"   # elites save on death: keep the real save untouched

	var e := await _spawn("chaser")
	e.drop_chance = 0.0
	e._on_died()
	await process_frame
	check(_pickups() == 0, "chance 0 drops nothing")

	e = await _spawn("chaser")
	e.drop_chance = 1.0
	e._on_died()
	await process_frame
	check(_pickups() == 1, "chance 1 drops a pickup")
	var p: Node = root.get_tree().get_nodes_in_group("interactable")[0]
	check(p.drop and p.item_id in ["herb", "flask"] and not p.usable, "drop is a touch pickup")
	p.item_id = "flask"
	game.flask_charges = 1
	p._on_touch(player)
	check(game.flask_charges == 2, "flask drop adds a charge")
	check(not game.has_flag("pickup:flask"), "no permanent flag")
	var q: Node = await _drop_of(player, "herb")
	check(player.health.hp == 70, "herb heals 20%% (hp %d)" % player.health.hp)
	q = q
	p.free()

	e = await _spawn("chaser")
	e.unique_id = "drops_test_elite"
	e.drop_chance = 0.0
	e._on_died()
	await process_frame
	check(_pickups() == 1, "elite always drops")
	for n in root.get_tree().get_nodes_in_group("interactable"):
		n.free()

	e = await _spawn("dummy")
	e.drop_chance = 1.0
	e.health.hp = 0
	e.health.damaged.emit(1, null)
	await process_frame
	check(_pickups() == 0, "dummy never drops")
	game.killed.erase("drops_test_elite")
	DirAccess.remove_absolute("user://drops_test_save.json")
	quit(1 if fails > 0 else 0)


func _drop_of(player: Node, id: String) -> Node:
	var p := (load("res://entities/world/pickup.tscn") as PackedScene).instantiate()
	p.drop = true
	p.item_id = id
	root.add_child(p)
	p._on_touch(player)
	return p


func _pickups() -> int:
	return root.get_tree().get_nodes_in_group("interactable").size()


func _spawn(n: String) -> EnemyBase:
	var e := (load("res://entities/enemies/%s.tscn" % n) as PackedScene).instantiate() as EnemyBase
	root.add_child(e)
	await process_frame
	e.set_physics_process(false)
	return e


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
