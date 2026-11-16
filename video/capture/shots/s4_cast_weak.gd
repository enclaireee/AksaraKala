extends "res://video/capture/s4_lib.gd"
## Segment 4: accuracy matters. A shaky Aksara Sunda KA reads as a smudged cast (the game's own "Smudged 70%"
## line): the weak bolt only staggers the faceless. A clean KA right after reads Perfect and finishes it.
## Real recogniser both times; the shake is the harness's stroke jitter.

func config() -> Dictionary:
	return {"music": false}


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
	var foes := [spawn_enemy(arg("kind", "jurig_leuweung"), c + Vector2(95, 0), true)]
	await wait_seconds(0.6)
	rec_start()
	await wait_seconds(0.4)
	mark("weak_start")
	var r := await cast_at("sunda_ka", foes[0], {"center": Vector2(200, 112), "size": 110.0, "seconds": 1.5, "freeze": foes,
		"jitter": float(arg("jit", 14)), "expect": false})
	mark("weak_released")
	print("shot: weak score %.2f power %.2f" % [float(r.get("score", 0)), float(r.get("power", 0))])
	await wait_seconds(2.0)
	mark("clean_start")
	var r2 := await cast_at("sunda_ka", foes[0], {"center": Vector2(200, 112), "size": 110.0, "seconds": 1.2, "freeze": live(foes)})
	mark("clean_released")
	print("shot: clean score %.2f" % float(r2.get("score", 0)))
	await wait_seconds(2.0)
	print("shot: alive %d" % live(foes).size())
	rec_stop()
