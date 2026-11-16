extends "res://video/capture/s4_lib.gd"
## Segment 1 cold open A: night forest path (Tatar Sunda, ts_leuweung), no HUD. Six of Kala's faceless and forest
## spirits close in on the lone Wiku; time slows, the cursor draws Aksara Sunda CA in glowing ink, release:
## Lingkar Aksara (Burst) erupts round her and the pack burns. 1.5-2 s aftermath.

func config() -> Dictionary:
	return {"music": false}


func hook(demo: int, zone_id: String, off: Vector2, glyph: String, kinds: Array) -> void:
	await start_demo({"index": demo})
	if zone_id != "" and Z.current_zone != zone_id:
		await go(zone_id)
	make_strong(20)
	clear_enemies()
	god = true
	infinite_sakti = true
	english_spell_names()
	hide_hud()
	show_cursor()
	var c: Vector2 = hero().global_position + Vector2(float(arg("dx", off.x)), float(arg("dy", off.y)))
	teleport(c)
	face(Vector2.DOWN)
	var spots := [Vector2(-140, -12), Vector2(-118, 16), Vector2(-96, 0), Vector2(140, 8), Vector2(118, -14), Vector2(98, 18)]
	var foes := []
	for i in spots.size():
		foes.append(spawn_enemy(str(kinds[i % kinds.size()]), c + spots[i] * float(arg("spread", 1.25)), true))
	var zm := float(arg("zoom", 2.0))
	cam_detach(c + Vector2(0, float(arg("camy", -6))))
	cam_zoom(zm)
	await wait_seconds(1.0)
	rec_start()
	mark("start")
	await wait_seconds(float(arg("lead", 1.6)))
	for f in foes:
		wake(f)
	await wait_seconds(float(arg("approach", 1.5)))
	mark("cast_start")
	var r := await cast_at(glyph, foes[0], {"center": Vector2(240, float(arg("cy", 128))), "size": float(arg("size", 130)),
		"seconds": float(arg("secs", 2.1)), "freeze": foes, "wake_delay": float(arg("wake_delay", 0.8)), "creep": float(arg("creep", 30)), "creep_to": float(arg("creep_to", 30))})
	mark("released")
	print("shot: hook %s score %.2f" % [glyph, float(r.get("score", 0))])
	await wait_seconds(float(arg("after", 3.4)))
	print("shot: alive %d" % live(foes).size())
	rec_stop()


func run() -> void:
	await hook(5, "", Vector2(-260, 0), arg("glyph", "sunda_ca"), ["faceless"])
