extends "res://video/capture/s5_lib.gd"
## Buto Ijo, the green giant of Timun Mas, in his field (tt_ladang). Through the arena gate: name card. He spits
## a fan of seeds (the hero rolls clear), then the Famine Maw: a ring of hunger 150 px wide whose only safe spot
## hugs him. The hero rolls in under his belly as it erupts, then answers with Jawa RA.

func config() -> Dictionary:
	return {"music": false, "max_seconds": 900}


func run() -> void:
	await start_demo({"index": 32})
	make_strong(20)
	god = true
	infinite_sakti = true
	infinite_stamina = true
	show_hud()
	hide_boss_hint()
	var b := boss()
	print("s5: boss ", b.global_position, " hero ", hero().global_position)
	var gate: Node2D = null
	for g in get_tree().get_nodes_in_group("arena_gate"):
		print("s5: gate ", g.global_position, " side ", g.side)
		if gate == null or g.global_position.distance_to(b.global_position) < gate.global_position.distance_to(b.global_position):
			gate = g
	var inward: Vector2 = {"n": Vector2.UP, "e": Vector2.RIGHT, "s": Vector2.DOWN, "w": Vector2.LEFT}[gate.side]
	if arg("probe", 0) == 1:
		teleport(gate.global_position - inward * 30)
		await wait_seconds(0.5)
		cam_detach((gate.global_position + b.global_position) / 2)
		_cam.zoom = Vector2(0.5, 0.5)
		rec_start(); await wait_frames(2); rec_stop()
		return
	b.global_position = gate.global_position + inward * float(arg("bd", 190)) + Vector2(0, float(arg("bdy", 0)))
	b.set("_start", b.global_position)
	teleport(gate.global_position - inward * 36)
	await wait_seconds(1.0)
	rec_start()
	hold_move(inward)
	await wait_until(func() -> bool: return b.engaged, 400, "never engaged")
	mark("engaged")
	await wait_frames(3)
	await wait_until(func() -> bool: return not get_tree().paused, 600, "intro never ended")
	mark("card_done")
	boss_log("card_done")
	await walk_to(hero().global_position + inward * float(arg("walkin", 50)), 1.0, 4.0)
	frame_pair(b, 0.5, Vector2(0, -6), 0.06)
	aim_at(b)
	b.phase = maxi(b.phase, 2)
	b._begin("seed_volley")
	mark("seeds")
	await wait_seconds(0.45)
	await dodge(Vector2.UP)
	await wait_seconds(0.35)
	await dodge(Vector2.DOWN * 1.0 + Vector2.RIGHT * 0.2)
	await wait_until(func() -> bool: return b.state != b.State.MOVE, 300, "seeds never ended")
	boss_log("after seeds")
	await wait_seconds(0.3)
	b._begin("famine_maw")
	mark("maw")
	await wait_seconds(0.9)
	var hug := b.global_position + (hero().global_position - b.global_position).normalized() * 22.0
	await dodge(hug - hero().global_position)
	await walk_to(hug, 1.0, 3.0)
	aim_at(b)
	await wait_until(func() -> bool: return b.state != b.State.MOVE, 300, "maw never ended")
	mark("maw_erupt")
	boss_log("after maw")
	await wait_seconds(0.3)
	await walk_to(hero().global_position + (hero().global_position - b.global_position).normalized() * 50.0, 1.2, 4.0)
	aim_at(b)
	var r := await cast_glyph(arg("glyph", "jawa_ra"), {"center": Vector2(240, 96), "size": 96.0, "seconds": 1.3, "aim_at": b})
	mark("cast")
	await wait_seconds(arg("after", 2.0))
	boss_log("end")
	rec_stop()
