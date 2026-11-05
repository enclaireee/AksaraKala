extends SceneTree
## Recognizer (spells.md 4, architecture.md 12): matches the Python design check, casts clean and
## sloppy drawings right, and turns doubt into a fizzle instead of the wrong spell.

const MVP := ["sunda_ka", "sunda_ga", "sunda_nga", "sunda_ca", "jawa_ha", "jawa_na", "jawa_ca", "jawa_ra"]
const LOOK_ALIKES := ["sunda_ga", "sunda_nga", "jawa_na", "jawa_ca"]
var fails := 0


func _initialize() -> void:
	var glyphs: Array[GlyphData] = []
	for id in MVP:
		glyphs.append(GlyphData.by_id(id))
	var by := {}
	for g in glyphs:
		by[g.id] = g

	# Same numbers as `python3 .docs/glyph_strokes.py` (spells.md 10 table).
	var ga_nga := Recognizer.score(Recognizer.normalize(by.sunda_ga.templates[0]), Recognizer.normalize(by.sunda_nga.templates[0]))
	var na_ca := Recognizer.score(Recognizer.normalize(by.jawa_na.templates[0]), Recognizer.normalize(by.jawa_ca.templates[0]))
	check(absf(ga_nga - 0.80) < 0.01, "ga/nga similarity %.3f, Python says 0.80" % ga_nga)
	check(absf(na_ca - 0.84) < 0.01, "na/ca similarity %.3f, Python says 0.84" % na_ca)

	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	for g in glyphs:
		var r := Recognizer.classify(g.templates[0], glyphs)
		check(r.glyph == g and r.power == 1.0, "clean %s read as %s at power %.1f" % [g.id, r.glyph.id, r.power])
		var right := 0
		var wrong := 0
		for i in 200:
			r = Recognizer.classify(sloppy(g.templates[0], rng), glyphs)
			if r.power > 0.0:
				if r.glyph == g:
					right += 1
				else:
					wrong += 1
		var floor_ := 150 if g.id in LOOK_ALIKES else 180   # synthetic noise; the real gate is recorded templates (spells.md 10)
		check(right >= floor_, "sloppy %s cast only %d/200" % [g.id, right])
		check(wrong <= 6, "sloppy %s cast the wrong spell %d/200" % [g.id, wrong])

	var back: PackedVector2Array = by.sunda_ka.templates[0].duplicate()
	back.reverse()
	var rb := Recognizer.classify(back, glyphs)
	check(not (rb.glyph == by.sunda_ka and rb.power > 0.0), "a backwards ka still cast ka")

	var none: Array[GlyphData] = []
	check(Recognizer.classify(by.sunda_ka.templates[0], none).power == 0.0, "cast with nothing learned")
	var twin: GlyphData = by.sunda_ka.duplicate()
	var pair: Array[GlyphData] = [by.sunda_ka, twin]
	check(Recognizer.classify(by.sunda_ka.templates[0], pair).power == 0.0, "tie between two glyphs did not fizzle")
	var dot := PackedVector2Array([Vector2(5, 5), Vector2(5, 5)])
	check(Recognizer.classify(dot, glyphs).score >= 0.0, "a click crashed the recognizer")
	quit(1 if fails > 0 else 0)


## A quick mouse drawing: wobble, uneven scale, slant, small tilt (glyph_strokes.py sloppy()).
func sloppy(p: PackedVector2Array, rng: RandomNumberGenerator) -> PackedVector2Array:
	p = Recognizer.resample(p, 48)
	var lo := p[0]
	var hi := p[0]
	for q in p:
		lo = lo.min(q)
		hi = hi.max(q)
	var size := maxf(hi.x - lo.x, hi.y - lo.y)
	var sx := rng.randf_range(0.85, 1.15)
	var sy := rng.randf_range(0.85, 1.15)
	var sh := rng.randf_range(-0.15, 0.15)
	var a := deg_to_rad(rng.randf_range(-8, 8))
	var w := Vector2.ZERO
	var out := PackedVector2Array()
	for q in p:
		w = 0.6 * w + Vector2(rng.randfn(0, 0.03 * size), rng.randfn(0, 0.03 * size))
		out.append(Vector2(q.x * sx + sh * q.y + w.x, q.y * sy + w.y).rotated(a))
	return out


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)
