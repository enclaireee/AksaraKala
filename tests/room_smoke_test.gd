extends SceneTree
## End-to-end wiring: in the real room the chaser hurts an idle player, and a keris swing hurts the chaser.

var fails := 0


func _initialize() -> void:
	var room: Node = load("res://zones/test_room.tscn").instantiate()
	root.add_child(room)
	var p: Player = room.get_node("Entities/Player")
	for i in 240:   # 4 s: notice, chase, wind-up, lunge
		await physics_frame
	check(p.health.hp < p.health.max_hp, "chaser never hurt the player (hp %d)" % p.health.hp)
	var c: Chaser = get_first_node_in_group("enemy")
	check(c != null, "no chaser spawned")
	if c:
		var before := c.health.hp
		p.health.set_invincible(10.0)
		for i in 30:   # no mouse headless: keep the chaser where the player aims
			if is_instance_valid(c):
				c.global_position = p.global_position + p.aim_dir * 14.0
			p.buffer["attack"] = p.clock
			await physics_frame
		check(not is_instance_valid(c) or c.health.hp < before, "keris swing never hurt the chaser")
	quit(1 if fails > 0 else 0)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)
