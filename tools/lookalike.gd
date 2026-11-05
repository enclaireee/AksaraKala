class_name LookAlike
## Look-alike report over recorded templates (spells.md 10, schedule Phase 2 exit). Dev tool, not shipped logic.

const K := 20
const CLOSE := 0.80


## {glyphs: [{id, templates, total, right, smudged, fizzle, wrong, confused}], pairs: [{a, b, score}]}
static func report(glyphs: Array[GlyphData]) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var rows := []
	for g in glyphs:
		var row := {id = g.id, templates = g.templates.size(), total = 0, right = 0, smudged = 0, fizzle = 0, wrong = 0, confused = ""}
		var seen := {}
		for i in g.templates.size():
			var reads: Array[Dictionary] = []
			var rest := g.templates.duplicate()
			rest.remove_at(i)
			if not rest.is_empty():   # leave-one-out: skipped when it is the glyph's only template
				reads.append(Recognizer.classify(g.templates[i], _swap(glyphs, g, rest)))
			for k in K:
				reads.append(Recognizer.classify(jitter(g.templates[i], rng), glyphs))   # ponytail: jitter reads use the full set, so one template still gets a number
			for r in reads:
				row.total += 1
				var ok: bool = r.glyph != null and r.glyph.id == g.id
				if r.power == 0.0:
					row.fizzle += 1
				elif ok:
					row.right += 1 if r.power == 1.0 else 0
					row.smudged += 1 if r.power < 1.0 else 0
				else:
					row.wrong += 1
				if not ok and r.glyph != null:
					seen[r.glyph.id] = seen.get(r.glyph.id, 0) + 1
		var top := 0
		for id in seen:
			if seen[id] > top:
				top = seen[id]
				row.confused = id
		rows.append(row)
	var pairs := []
	for i in glyphs.size():
		for j in range(i + 1, glyphs.size()):
			var best := 0.0
			for a in glyphs[i].templates:
				for b in glyphs[j].templates:
					best = maxf(best, Recognizer.score(Recognizer.normalize(a), Recognizer.normalize(b)))
			if best >= CLOSE:
				pairs.append({a = glyphs[i].id, b = glyphs[j].id, score = best})
	return {glyphs = rows, pairs = pairs}


## Percent of reads that cast the right spell (full or smudged).
static func cast_pct(row: Dictionary) -> float:
	return 100.0 * (row.right + row.smudged) / maxi(row.total, 1)


static func _swap(glyphs: Array[GlyphData], g: GlyphData, templates: Array) -> Array[GlyphData]:
	var out: Array[GlyphData] = []
	for h in glyphs:
		if h == g:
			var c := GlyphData.new()
			c.id = g.id
			c.templates.assign(templates)
			out.append(c)
		else:
			out.append(h)
	return out


## A quick mouse drawing: wobble, uneven scale, slant, small tilt (same as sloppy() in tests/recognizer_test.gd).
static func jitter(p: PackedVector2Array, rng: RandomNumberGenerator) -> PackedVector2Array:
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
