extends SceneTree
## Phase 2 exit check: $G --headless --path . -s tools/lookalike_check.gd (exit 1 = a target is missed).

const MVP: Array[String] = ["sunda_ka", "sunda_ga", "sunda_nga", "sunda_ca", "jawa_ha", "jawa_na", "jawa_ca", "jawa_ra"]


func _initialize() -> void:
	var glyphs: Array[GlyphData] = []
	for id in MVP:
		glyphs.append(GlyphData.by_id(id))
	var rep := LookAlike.report(glyphs)
	var bad := false
	var by := {}
	print("%-10s %4s %7s %7s %7s  %s" % ["glyph", "tmpl", "right%", "fizz%", "WRONG%", "most confused with"])
	for r in rep.glyphs:
		by[r.id] = r
		var n: float = maxf(r.total, 1)
		print("%-10s %4d %7.1f %7.1f %7.1f  %s" % [r.id, r.templates, LookAlike.cast_pct(r), 100.0 * r.fizzle / n, 100.0 * r.wrong / n, r.confused])
		if r.templates < 3:
			print("  note: %s has %d template(s), record at least 3" % [r.id, r.templates])
		if LookAlike.cast_pct(r) < 90.0 or r.wrong > 0:
			bad = true
	for pair in [["sunda_ga", "sunda_nga"], ["jawa_na", "jawa_ca"]]:
		for id in pair:
			if by[id].fizzle * 10 >= by[id].total:
				bad = true
	print("close pairs (>= 0.80):")
	for p in rep.pairs:
		print("  %s / %s  %.2f" % [p.a, p.b, p.score])
	print("RESULT: " + ("MISSES TARGET" if bad else "ok"))
	quit(1 if bad else 0)
