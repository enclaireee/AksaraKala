extends SceneTree
## Glyph lesson: waits for an open dialogue, 3 matching casts finish it, other glyphs do not count, practice restored.

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	await run()
	quit(1 if fails > 0 else 0)


func frames(n: int) -> void:
	for i in n:
		await process_frame


func run() -> void:
	for loc in ["id", "en"]:
		TranslationServer.set_locale(loc)
		for g in ["SUNDA_KA", "SUNDA_GA", "SUNDA_NGA", "SUNDA_CA", "JAWA_HA", "JAWA_NA", "JAWA_CA", "JAWA_RA"]:
			var k: String = "LESSON_" + g
			check(tr(k) != k and tr(k) != "", "%s translates in %s" % [k, loc])
	var cast := Node.new()
	var cs := GDScript.new()
	cs.source_code = "extends Node\nvar practice := true\n"   # sanggar already set it: must stay true
	cs.reload()
	cast.set_script(cs)
	var player := Node.new()
	var ps := GDScript.new()
	ps.source_code = "extends Node\nvar cast\n"
	ps.reload()
	player.set_script(ps)
	player.cast = cast
	player.add_to_group("player")
	player.add_child(cast)
	root.add_child(player)
	var lesson: CanvasLayer = load("res://ui/glyph_lesson.tscn").instantiate()
	root.add_child(lesson)
	await frames(2)
	var ev := root.get_node("Events")
	ev.dialogue_requested.emit("NPC_SEMAR_NAME", PackedStringArray(["x"]))
	ev.glyph_learned.emit("sunda_ga")
	await frames(2)
	check(lesson.active == "", "waits while a dialogue is open")
	ev.dialogue_finished.emit()
	await frames(2)
	check(lesson.active == "sunda_ga", "opens after dialogue_finished")
	lesson.finish()
	cast.practice = false   # next lesson starts from false
	ev.glyph_learned.emit("sunda_nga")
	await frames(2)
	check(lesson.active == "sunda_nga" and cast.practice, "practice on during the lesson")
	ev.spell_cast.emit("sunda_ga", 1.0)
	check(lesson.count == 0, "a different glyph does not count")
	for i in 3:
		check(lesson.active == "sunda_nga", "still active before cast %d" % (i + 1))
		ev.spell_cast.emit("sunda_nga", 1.0)
	await frames(2)
	check(lesson.active == "", "3 casts finish it")
	check(not cast.practice, "practice restored to false")
	cast.practice = true
	ev.glyph_learned.emit("jawa_ha")
	await frames(2)
	lesson.finish()
	check(cast.practice, "practice restored to true")

	# Write mode: strokes scored only against the target glyph; a miss retries; the end fires name_written.
	for gid in ["sunda_la", "sunda_ra", "sunda_sa"]:
		check(not root.get_node("Game").glyphs_learned.has(gid) and SpellData.for_glyph(gid) == null, "%s is not a spell" % gid)
	var written: Array[String] = []
	ev.name_written.connect(func(id: String) -> void: written.append(id))
	var seq := PackedStringArray(["jawa_na", "sunda_ga"])
	ev.write_requested.emit("nagawiru", seq)
	await frames(2)
	check(lesson.writing == "nagawiru" and paused, "write card up, tree paused")
	check(not lesson.write_attempt(GlyphData.by_id("sunda_ga").templates[0]), "the wrong glyph does not count")
	check(not lesson.write_attempt(PackedVector2Array([Vector2(0, 0), Vector2(3, 3)])), "a tiny stroke is a miss")
	check(lesson._wi == 0, "still on the first glyph after misses")
	check(lesson.write_attempt(GlyphData.by_id("jawa_na").templates[0]), "the right glyph counts")
	check(lesson._wi == 1 and written.is_empty(), "advanced to the second glyph")
	check(lesson.write_attempt(GlyphData.by_id("sunda_ga").templates[0]), "second glyph counts")
	for i in 400:   # fade is ~1.6 s real time
		if not written.is_empty():
			break
		await process_frame
	check(written == ["nagawiru"], "name_written fired once: %s" % [written])
	check(lesson.writing == "" and not paused, "write card gone, pause restored")
