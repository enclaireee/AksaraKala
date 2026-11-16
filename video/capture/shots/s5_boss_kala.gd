extends "res://video/capture/s5_lib.gd"
## Batara Kala in his chamber (gk_ruang_kala). Through the arena gate: his name card and scale. Phase 3: the
## Ruwatan Eclipse, eight violet wedges with one safe; the hero stands in the safe wedge as it falls. Then he
## kneels (spent), the gold mark of Jawa KA over him; the hero writes KA and he is calmed (released, not killed).

func config() -> Dictionary:
	return {"music": false, "max_seconds": 900}


func run() -> void:
	await start_demo({"index": 53})
	make_strong(20)
	god = true
	infinite_sakti = true
	infinite_stamina = true
	flag("mq5_lc")
	G.changed.emit()
	await wait_frames(2)
	show_hud()
	hide_boss_hint()
	var b := boss()
	for e in enemies():
		if e != b:
			e.queue_free()
	print("s5: boss ", b.global_position, " hero ", hero().global_position, " arena_radius ", b.arena_radius)
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
		_cam.zoom = Vector2(0.4, 0.4)
		rec_start(); await wait_frames(2); rec_stop()
		return
	teleport(gate.global_position + inward * 10)
	await wait_seconds(0.5)
	await wait_until(func() -> bool: return not get_tree().paused, 600, "first card")
	b.global_position = gate.global_position + inward * float(arg("bd", 230))
	G.boss_intro_seen.clear()
	b.engaged = false
	for g in get_tree().get_nodes_in_group("arena_gate"):
		g.entered = false
	boss_stage()._boss = null
	await wait_seconds(0.5)
	rec_start()
	hold_move(inward)
	await wait_until(func() -> bool: return b.engaged, 600, "never engaged")
	mark("engaged")
	await wait_frames(3)
	await wait_until(func() -> bool: return not get_tree().paused, 600, "intro never ended")
	mark("card_done")
	stop()
	boss_log("card")
	# into the chamber, toward him
	var stand := b.global_position + (hero().global_position - b.global_position).normalized() * float(arg("dist", 80))
	frame_pair(b, 0.45, Vector2(0, -10), 0.05)
	await walk_to(stand, 1.1, 4.0)
	aim_at(b)
	b.phase = 3
	b._enter(b.State.CHASE)
	await wait_frames(1)
	b._begin("ruwatan")
	# the hero runs to the safe wedge (marked by pulsing gold rings)
	var safe_at: Vector2 = b.global_position + Vector2.from_angle(b._ru_wedge_dir(b._ru_safe)) * 72.0
	print("s5: safe wedge ", b._ru_safe, " at ", safe_at, " fx ", b._fx.size())
	mark("eclipse")
	await wait_seconds(0.4)
	var dd := safe_at - hero().global_position
	if dd.length() > 50.0:
		await dodge(dd)
	await walk_to(safe_at, 1.2, 4.0)
	aim_at(b)
	await wait_until(func() -> bool: return b.state != b.State.RUWATAN, 600, "eclipse never fell")
	mark("eclipse_fall")
	await wait_seconds(0.8)
	# spent: he kneels; the hero writes Jawa KA
	b.shielded = false
	b.health.take_damage(b.health.hp, hero(), true)
	mark("kneel")
	await wait_seconds(0.9)
	var r := await cast_still("jawa_ka", {"center": Vector2(240, 96), "size": 96.0, "seconds": 1.4, "aim_at": b, "jitter": 0.0})
	mark("calmed")
	aim_at(b.global_position)   # he is freed once released: never leave the mouse on a freed node
	await wait_seconds(arg("after", 2.5))
	rec_stop()
