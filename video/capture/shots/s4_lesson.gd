extends "res://video/capture/s4_lib.gd"
## Segment 4: the glyph lesson card for Aksara Sunda KA (name, the aksara in Noto Sans Sundanese, what it does, the
## ghost stroke guide), then the Wiku traces it in practice mode and the bolt fires. HUD on (clean).

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
	var g: String = arg("glyph", "sunda_ka")
	if g in G.glyphs_learned:
		var gl := PackedStringArray(G.glyphs_learned)
		gl.remove_at(gl.find(g))
		G.glyphs_learned = gl
	await wait_seconds(0.6)
	rec_start()
	mark("lesson_open")
	await show_lesson(g)
	await wait_seconds(float(arg("read", 2.6)))
	mark("trace_start")
	var r := await cast_glyph(g, {"center": Vector2(float(arg("cx", 150)), 125.0), "size": 110.0, "seconds": float(arg("secs", 1.8))})
	mark("trace_released")
	print("shot: lesson trace %.2f" % float(r.get("score", 0)))
	await wait_seconds(float(arg("after", 2.4)))
	rec_stop()
