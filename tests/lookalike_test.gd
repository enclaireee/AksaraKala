extends SceneTree
## LookAlike report + glyph recorder logic. Recorder works on copies in user://, never res://data/glyphs.

const IDS := ["sunda_ka", "sunda_ga", "sunda_nga", "sunda_ca", "jawa_ha", "jawa_na", "jawa_ca", "jawa_ra", "jawa_ka"]
var fails := 0


func _initialize() -> void:
	var glyphs: Array[GlyphData] = []
	for id in IDS.slice(0, 8):
		glyphs.append(GlyphData.by_id(id))
	var rep := LookAlike.report(glyphs)
	check(rep.glyphs.size() == 8 and rep.glyphs[0].total > 0, "report has no rows")
	var pairs := []
	for p in rep.pairs:
		pairs.append(p.a + "/" + p.b)
	check("sunda_ga/sunda_nga" in pairs, "ga/nga not flagged: %s" % [pairs])
	check("jawa_na/jawa_ca" in pairs, "na/ca not flagged: %s" % [pairs])
	check(not ("sunda_ka/sunda_ca" in pairs), "ka/ca flagged")

	var dir := "user://lookalike_test"
	DirAccess.make_dir_recursive_absolute(dir)
	for id in IDS:
		DirAccess.copy_absolute("res://data/glyphs/%s.tres" % id, "%s/%s.tres" % [dir, id])
	var rec: Control = load("res://tools/glyph_recorder.gd").new()
	rec.glyph_dir = dir
	root.add_child(rec)
	await process_frame
	rec.picker.select(0)
	var g: GlyphData = rec.selected()
	var before := g.templates.size()
	check(not rec.submit_stroke(PackedVector2Array([Vector2(0, 0), Vector2(10, 10)])), "short stroke accepted")
	rec.save_current()
	check(g.templates.size() == before, "short stroke saved")
	var stroke := PackedVector2Array([Vector2(0, 0), Vector2(100, 0), Vector2(100, 100)])
	check(rec.submit_stroke(stroke), "long stroke rejected")
	rec.save_current()
	check(g.templates.size() == before + 1, "save did not add a template")
	var back: GlyphData = ResourceLoader.load(dir + "/sunda_ka.tres", "", ResourceLoader.CACHE_MODE_IGNORE)
	check(back.templates.size() == before + 1 and back.templates[before] == stroke, "file does not reload with the stroke")
	rec.delete_last()
	back = ResourceLoader.load(dir + "/sunda_ka.tres", "", ResourceLoader.CACHE_MODE_IGNORE)
	check(back.templates.size() == before, "delete_last did not remove it")
	quit(1 if fails > 0 else 0)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)
