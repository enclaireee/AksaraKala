extends "res://video/capture/s4_lib.gd"
## Segment 4 montage source: eight aksara drawn and fired back to back, same framing (ts_sawah meadow, HUD on),
## ~2 s each: a fresh trio of faceless each time. Cut at the [mark] rapid_<glyph> frames.

func config() -> Dictionary:
	return {"music": false, "max_seconds": 900}


func run() -> void:
	await start_demo({"index": 6})
	make_strong(20)
	clear_enemies()
	god = true
	infinite_sakti = true
	english_spell_names()
	show_hud()
	show_cursor()
	var c := hero().global_position + Vector2(300, 0)
	teleport(c)
	face(Vector2.RIGHT)
	await wait_seconds(0.6)
	rec_start()
	var list: PackedStringArray = str(arg("glyphs", "sunda_ka,sunda_nga,sunda_ca,sunda_ga,jawa_ha,jawa_na,jawa_ra,jawa_ka")).split(",")
	for g in list:
		for e in enemies():
			e.queue_free()
		teleport(c)
		var foes := [spawn_enemy("faceless", c + Vector2(62, -14), true), spawn_enemy("faceless", c + Vector2(70, 18), true),
			spawn_enemy("faceless", c + Vector2(-58, 8), true)]
		await wait_frames(2)
		mark("rapid_" + g)
		await cast_at(g, foes[0], {"center": Vector2(240, 112), "size": 110.0, "seconds": 0.9, "freeze": foes, "wake_delay": 0.4})
		await wait_seconds(1.0)
	await wait_seconds(0.5)
	rec_stop()
