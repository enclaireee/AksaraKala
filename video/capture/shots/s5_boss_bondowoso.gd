extends "res://video/capture/s5_lib.gd"
## Bandung Bondowoso in the thousand temples (mt_candi). Through the arena gate: name card. Pillars rise around
## him. He calls the Thousand Temples (lanes of stone spikes, one safe lane); the hero rolls into the safe lane
## twice, then writes Jawa CA: the dawn beat exposes the pillars, and the hero breaks one.

func config() -> Dictionary:
	return {"music": false, "max_seconds": 900}


func run() -> void:
	await start_demo({"index": 26})
	make_strong(20)
	god = true
	infinite_sakti = true
	infinite_stamina = true
	flag("mq2_lc")
	G.changed.emit()
	await wait_frames(2)
	show_hud()
	hide_boss_hint()
	var b := boss()
	print("s5: boss ", b.global_position, " hero ", hero().global_position)
	var gate: Node2D = null
	for g in get_tree().get_nodes_in_group("arena_gate"):
		print("s5: gate ", g.global_position, " side ", g.side)
		if gate == null or absf(g.global_position.x - b.global_position.x) < absf(gate.global_position.x - b.global_position.x):
			gate = g
	if arg("probe", 0) == 1:
		teleport(gate.global_position + Vector2(0, 30))
		await wait_seconds(0.5)
		cam_detach((gate.global_position + b.global_position) / 2)
		_cam.zoom = Vector2(0.5, 0.5)
		rec_start(); await wait_frames(2); rec_stop()
		return
	b.global_position = gate.global_position + Vector2(arg("bdx", 0), -float(arg("bdy", 210)))
	teleport(gate.global_position + Vector2(0, 40))
	await wait_seconds(1.0)
	rec_start()
	hold_move(Vector2.UP)
	await wait_until(func() -> bool: return b.engaged, 400, "never engaged")
	mark("engaged")
	await wait_frames(3)
	await wait_until(func() -> bool: return not get_tree().paused, 600, "intro never ended")
	mark("card_done")
	await walk_to(hero().global_position + Vector2(0, -float(arg("walkin", 80))), 1.0, 4.0)
	# a few pillars rise
	for i in 3:
		b._raise(b.global_position + Vector2.from_angle(-PI * 0.15 - PI * 0.35 * i) * 70.0)
	b.phase = 2
	frame_pair(b, 0.5, Vector2(0, -4), 0.06)
	await wait_seconds(0.5)
	b._begin_move("temples")
	b._clear_attack()
	b._axis_h = false   # vertical lanes: the hero rolls sideways, across the frame
	b._temples_mark(b.temple_windup, false)
	b._goto(0)
	mark("temples"); boss_log("temples"); print("s5: zone ", Z.current_zone, " pillars ", b.pillars.map(func(q): return q.global_position))
	await _to_safe(b, 0.5)
	await wait_until(func() -> bool: return b._stage == 1, 200, "no sweep 1")
	mark("sweep1"); boss_log("sweep1"); print("s5: zone ", Z.current_zone, " pillars ", b.pillars.map(func(q): return q.global_position))
	await _to_safe(b, 0.05)
	await wait_until(func() -> bool: return b._stage == 2, 200, "no sweep 2")
	mark("sweep2"); boss_log("sweep2"); print("s5: zone ", Z.current_zone, " pillars ", b.pillars.map(func(q): return q.global_position))
	await wait_seconds(0.4)
	aim_at(b)
	var r := await cast_still("jawa_ca", {"center": Vector2(240, 96), "size": 96.0, "seconds": 1.3, "aim_at": b})
	mark("cast_ca"); boss_log("cast_ca"); print("s5: zone ", Z.current_zone, " pillars ", b.pillars.map(func(q): return q.global_position))
	await wait_seconds(0.3)
	if b.pillars.size() > 0:
		var p: Node2D = null
		for q in b.pillars:
			if is_instance_valid(q) and q.global_position.distance_to(b.global_position) < 200 and (p == null or q.global_position.distance_to(hero().global_position) < p.global_position.distance_to(hero().global_position)):
				p = q
		await walk_to(p.global_position + (hero().global_position - p.global_position).normalized() * 22.0, 1.2, 6.0)
		await attack(3, p.global_position + Vector2(0, -8))
		mark("pillar_hit")
	boss_log("end")
	await wait_seconds(arg("after", 1.5))
	rec_stop()


## Walks / rolls the hero into the safe lane of the current Thousand Temples sweep.
func _to_safe(b: Node, delay: float) -> void:
	await wait_seconds(delay)
	var ax: Vector2 = Vector2.RIGHT if b._axis_h else Vector2.DOWN
	var n := ax.orthogonal()
	var c: Vector2 = b._spot + n * b.TEMPLE_GAP * float(b._safe)
	var h := hero().global_position
	var target := c + ax * (h - c).dot(ax)
	var d := target - h
	print("s5: safe lane k=%d move %s" % [b._safe, d])
	if d.length() > 40.0:
		await dodge(d)
	await walk_to(target, 1.0, 3.0)
	aim_at(b)
