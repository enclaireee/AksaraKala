extends "res://video/capture/s5_lib.gd"
## Sangkuriang in the Tangkuban Perahu crater (ts_kawah). The hero walks through the arena gate: the gate seals,
## the name card opens. Dawn breaks, he roars and throws the Dawn Wrath (rings of burning shards with one safe
## gap); the hero stands in the gap, rolls to the next one, then writes Sunda CA by the hung cloth: the fake
## dawn stuns him.

func config() -> Dictionary:
	return {"music": false, "max_seconds": 900}


func run() -> void:
	await start_demo({"index": 10})
	make_strong(20)
	god = true
	infinite_sakti = true
	infinite_stamina = true
	flag("mq1_8"); flag("rarang_post"); flag("post:east")
	G.changed.emit()
	await wait_frames(2)
	show_hud()
	var b := boss()
	var post: Node2D = null
	for p in get_tree().get_nodes_in_group("interactable"):
		if p.get("post_id") == "east":
			post = p
	print("s5: post ", post.global_position if post else null, " boss ", b.global_position)
	for g in get_tree().get_nodes_in_group("arena_gate"):
		print("s5: gate ", g.global_position, " side ", g.side)
	b.global_position = Vector2(arg("bx", 730), 556)
	teleport(Vector2(1012, 544))
	await wait_seconds(1.0)
	rec_start()
	hold_move(Vector2.LEFT)
	await wait_until(func() -> bool: return b.engaged, 400, "never engaged")
	mark("engaged")
	await wait_frames(3)
	await wait_until(func() -> bool: return not get_tree().paused, 600, "intro never ended")
	mark("card_done")
	# dawn breaks: phase 2, enraged
	b.phase = 2
	b.dawn = 1.0
	await wait_frames(1)
	frame_pair(b, 0.4, Vector2(0, -10), 0.06)
	var stand := Vector2(arg("hx", 880), 548)
	var gap := (stand - b.global_position).angle()
	b._begin_move("wrath")
	b._gap1 = gap
	b._wrath_marks(b.wrath_windup, gap)
	mark("wrath_windup")
	await walk_to(stand, 1.0, 4.0)
	aim_at(b)
	await wait_until(func() -> bool: return b._stage == 1, 200, "no ring 1")
	mark("ring1")
	# the second gap: where the roll ends
	var roll_to := hero().global_position + Vector2(0, -float(arg("roll", 56)))
	var g2 := (roll_to - b.global_position).angle()
	b._gap1 = g2
	b._wrath_marks(0.9, g2)
	await wait_seconds(0.25)
	await dodge(Vector2.UP)
	await walk_to(roll_to, 1.0, 4.0)
	aim_at(b)
	await wait_until(func() -> bool: return b._stage == 2, 200, "no ring 2")
	mark("ring2")
	await wait_seconds(0.6)
	var r := await cast_glyph("sunda_ca", {"center": Vector2(240, 96), "size": 96.0, "seconds": 1.3, "aim_at": b})
	mark("cast_ca")
	boss_log("after cast")
	await wait_seconds(arg("after", 2.0))
	boss_log("end")
	rec_stop()
