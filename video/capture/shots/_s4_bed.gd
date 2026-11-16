extends "res://video/capture/s4_lib.gd"
## Dev tool: every Wiku spell once on a fresh pack, to choose glyphs. --set glyphs=a,b,c
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
	var c := hero().global_position + Vector2(int(arg("dx", 300)), 0)
	teleport(c)
	await wait_seconds(0.6)
	rec_start()
	var list: PackedStringArray = str(arg("glyphs", "sunda_ka,sunda_nga,sunda_ca,sunda_ga,jawa_ha,jawa_na,jawa_ca,jawa_ra,jawa_wa,jawa_ka")).split(",")
	var jits: PackedStringArray = str(arg("jits", "")).split(",", false)
	for gi in list.size():
		var g := list[gi]
		for e in enemies():
			e.queue_free()
		teleport(c)
		var foes := spawn_ring("faceless", c, 5, 64.0, true, 0.3)
		await wait_seconds(0.3)
		if arg("wake", "1") == "1":
			for f in foes:
				wake(f)
		mark("cast_" + g)
		var r := await cast_at(g, c + Vector2(64, 0), {"center": Vector2(240, 95), "size": 90.0, "seconds": float(arg("secs", 1.0)), "jitter": float(jits[gi]) if gi < jits.size() else 0.6, "expect": false, "freeze": foes, "debug": arg("debug", "0") == "1"})
		print("shot: bed %s -> score %.2f" % [g, float(r.get("score", 0))])
		await wait_seconds(2.5)
		print("shot: bed %s alive %d" % [g, live(foes).size()])
	rec_stop()
