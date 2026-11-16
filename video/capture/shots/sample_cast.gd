extends "res://video/capture/shot.gd"
## Sample: the Wiku (mage) in the Tatar Sunda tea field (ts_kebun) with four foes closing in. HUD on.
## She draws Aksara Sunda CA (Lingkar Aksara: a burning ring around the caster), the real recogniser reads it,
## the ring fires and burns the pack. About 8 s.

func config() -> Dictionary:
	return {"music": false}


func run() -> void:
	await start_demo({"index": 11})
	await go("ts_kebun", "from_ts_kampung")
	make_strong(18)
	clear_enemies()
	god = true
	infinite_sakti = true
	show_hud()                                  # vitals, weapon well, flasks; no tracker, arrow or hints
	var c := cell(int(arg("cx", 42)), int(arg("cy", 18)))
	teleport(c)
	await wait_frames(2)
	var foes := [
		spawn_enemy("faceless", c + Vector2(-95, -30), true),
		spawn_enemy("faceless", c + Vector2(90, -40), true),
		spawn_enemy("jurig_leuweung", c + Vector2(100, 45), true),
		spawn_enemy("wild_boar", c + Vector2(-80, 55), true),
	]
	face(Vector2.RIGHT)
	await wait_seconds(1.0)
	rec_start()
	for f in foes:
		wake(f)
	await wait_seconds(arg("approach", 1.2))         # they close in
	await attack(2, foes[1])                    # two staff bolts at the nearest
	await wait_seconds(0.3)
	var r := await cast_glyph(arg("glyph", "sunda_ca"), {"center": Vector2(240, 100), "size": 100.0, "seconds": 1.4})
	mark("cast_released")
	await wait_seconds(arg("after", 4.0))
	rec_stop()
