extends SceneTree
## BossKit test: geometry queries, telegraph/shot/zone/wave nodes free themselves, damage goes through the Hurtbox.

const DT := 1.0 / 60.0
var fails := 0


func _initialize() -> void:
	await process_frame
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	player.position = Vector2(200, 135)
	root.add_child(player)
	var b := (load("res://entities/bosses/sangkuriang.tscn") as PackedScene).instantiate() as EnemyBase
	b.position = Vector2(100, 135)
	root.add_child(b)
	await process_frame
	b.set_physics_process(false)

	# geometry
	var p := Vector2(150, 135)
	check(BossKit.in_circle(p, Vector2(140, 135), 8.0), "circle hit")
	check(not BossKit.in_circle(p, Vector2(100, 135), 8.0), "circle miss")
	check(BossKit.in_cone(p, Vector2(100, 135), 0.0, 1.0, 80.0), "cone hit straight ahead")
	check(not BossKit.in_cone(p, Vector2(100, 135), PI, 1.0, 80.0), "cone miss behind")
	check(not BossKit.in_cone(p, Vector2(100, 135), 0.0, 1.0, 20.0), "cone miss beyond reach")
	check(BossKit.in_line(p, Vector2(100, 135), Vector2(200, 135), 10.0), "line hit")
	check(not BossKit.in_line(p, Vector2(100, 100), Vector2(200, 100), 10.0), "line miss")

	# nodes: spawn and free by themselves
	var before := b.get_parent().get_child_count()
	BossKit.telegraph_circle(b, Vector2(150, 135), 20.0, 0.2)
	BossKit.telegraph_cone(b, b.global_position, 0.0, 1.0, 60.0, 0.2)
	BossKit.telegraph_line(b, b.global_position, Vector2(200, 135), 10.0, 0.2)
	BossKit.telegraph_ring(b, b.global_position, 60.0, 30.0, 0.2)
	BossKit.ring_fx(b, b.global_position, 30.0, 0.2)
	BossKit.sparks(b, b.global_position, Color.WHITE, 6, 40.0, 0.2)
	check(b.get_parent().get_child_count() == before + 6, "fx nodes added")
	await create_timer(0.5).timeout
	check(b.get_parent().get_child_count() == before, "fx nodes freed")

	# shots, zones, waves hurt the player through the Hurtbox (a bare CharacterBody2D has none: no damage, no crash)
	var s := BossKit.shoot(b, b.global_position, 0.0, 120.0, 10, Color.RED)
	check(s != null and s.vel.length() > 100.0, "shot flies")
	var z := BossKit.zone(b, Vector2(300, 135), 20.0, 5, 0.2)
	var w := BossKit.wave(b, b.global_position, 30.0, 200.0, 10)
	check(z != null and w != null, "zone and wave spawn")
	await create_timer(0.6).timeout
	check(not is_instance_valid(w) or w.is_queued_for_deletion(), "wave ends")

	var fan := BossKit.fan(b, b.global_position, 0.0, 1.0, 5, 80.0, 8, Color.BLUE)
	check(fan.size() == 5, "fan has 5 shots")
	var ringed := BossKit.fan(b, b.global_position, 0.0, TAU, 8, 80.0, 8, Color.BLUE)
	check(ringed.size() == 8, "ring has 8 shots")

	check(not BossKit.hurt_player(b, 5), "no Hurtbox on the stand-in player: refused, no crash")
	BossKit.anim(b, "slam")
	BossKit.anim_stop(b)
	BossKit.punch(b, 1.2, 0.9)
	BossKit.shake(b, 2.0, 0.2)
	BossKit.ghost(b)

	quit(1 if fails > 0 else 0)


func check(cond: bool, msg: String) -> void:
	if not cond:
		fails += 1
		print("FAIL: ", msg)
