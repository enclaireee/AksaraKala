extends "res://video/capture/s4_lib.gd"
## Segment 4 centrepiece: one flowing fight in the Tatar Sunda tea garden (ts_kebun), HUD on. Two waves of mixed
## foes (faceless, tuyul, forest jurig, a boar). Staff bolts, a dodge, Sunda CA (Burst ring) on the first wave,
## a dodge out, Jawa RA (fire tiger) for the second, bolts to finish. Fast strokes (~1 s): drawing is part of the fight.

func config() -> Dictionary:
	return {"music": false}


func run() -> void:
	await start_demo({"index": 11})
	await go("ts_kebun", "from_ts_kampung")
	make_strong(20)
	clear_enemies()
	god = true
	infinite_sakti = true
	infinite_stamina = true
	english_spell_names()
	show_hud()
	show_cursor()
	var c := cell(int(arg("cx", 40)), int(arg("cy", 20)))
	teleport(c)
	face(Vector2.UP)
	var wave_a := [
		spawn_enemy("faceless", c + Vector2(-70, -95), true),
		spawn_enemy("tuyul", c + Vector2(-20, -110), true),
		spawn_enemy("faceless", c + Vector2(40, -100), true),
		spawn_enemy("tuyul", c + Vector2(85, -80), true),
	]
	var wave_b := [
		spawn_enemy("jurig_leuweung", c + Vector2(110, 0), true),
		spawn_enemy("wild_boar", c + Vector2(125, 45), true),
		spawn_enemy("faceless", c + Vector2(100, -45), true),
	]
	await wait_seconds(1.0)
	rec_start()
	mark("start")
	for f in wave_a:
		wake(f)
	await walk_to(c + Vector2(0, -12), 0.9)
	stop()
	await attack(3, wave_a[1].global_position)
	mark("bolts")
	await wait_seconds(0.25)
	await dodge(Vector2(-1, 0.3))
	mark("dodge_1")
	await wait_seconds(0.35)
	mark("cast_1_start")
	await cast_at("sunda_ca", wave_a[0], {"center": Vector2(220, 105), "size": 100.0, "seconds": 1.0, "freeze": wave_a,
		"wake_delay": 0.5, "creep": 40.0, "creep_to": 30.0})
	mark("cast_1_released")
	for f in wave_b:
		wake(f)
	await wait_seconds(1.2)
	await dodge(Vector2(-0.6, 0.8))
	mark("dodge_2")
	await wait_seconds(0.3)
	var tgt: Variant = live(wave_b)[0] if live(wave_b).size() > 0 else c + Vector2(100, 0)
	mark("cast_2_start")
	await cast_at("jawa_ra", tgt, {"center": Vector2(260, 105), "size": 100.0, "seconds": 1.0, "freeze": live(wave_b + wave_a), "wake_delay": 0.5, "creep": 30.0, "creep_to": 45.0})
	mark("cast_2_released")
	await wait_seconds(0.6)
	for i in 3:
		var l := live(wave_a + wave_b)
		if l.is_empty():
			break
		await attack(2, (l[0] as Node2D).global_position)
		await wait_seconds(0.2)
	await wait_seconds(float(arg("after", 1.5)))
	print("shot: combo alive %d" % live(wave_a + wave_b).size())
	rec_stop()
