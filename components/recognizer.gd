class_name Recognizer
## Stroke matching (spells.md 4, architecture.md 7). Same math as .docs/glyph_strokes.py:
## resample, scale to a unit box, centre; never rotate, and point order matters (direction-sensitive).

const N := 64
const FULL := 0.80
const SMUDGE := 0.65
const TIE := 0.05
const HALF_DIAG := 0.70710678


## {glyph: GlyphData or null, score: float, power: 1.0 full, 0.7 smudged, 0.0 fizzle}.
## glyph is the best guess even on a fizzle, so the sanggar can show what it looked like.
static func classify(stroke: PackedVector2Array, glyphs: Array[GlyphData]) -> Dictionary:
	var s := normalize(stroke)
	var best: GlyphData
	var s1 := 0.0
	var s2 := 0.0
	for g in glyphs:
		var top := 0.0
		for t in g.templates:
			top = maxf(top, score(s, normalize(t)))   # ponytail: normalizes templates per call; cache if it ever shows in a profile
		if top > s1:
			s2 = s1
			s1 = top
			best = g
		elif top > s2:
			s2 = top
	var power := 0.0
	if s1 >= SMUDGE and s1 - s2 >= TIE:
		power = 1.0 if s1 >= FULL else 0.7   # smudged cast at 70% power
	return {glyph = best, score = s1, power = power}


static func score(a: PackedVector2Array, b: PackedVector2Array) -> float:
	var d := 0.0
	for i in N:
		d += a[i].distance_to(b[i])
	return maxf(0.0, 1.0 - d / N / HALF_DIAG)


static func normalize(p: PackedVector2Array) -> PackedVector2Array:
	p = resample(p)
	var lo := p[0]
	var hi := p[0]
	var c := Vector2.ZERO
	for q in p:
		lo = lo.min(q)
		hi = hi.max(q)
		c += q
	c /= N
	var size := maxf(hi.x - lo.x, hi.y - lo.y)
	if size == 0.0:
		size = 1.0
	for i in N:
		p[i] = (p[i] - c) / size
	return p


static func path_length(p: PackedVector2Array) -> float:
	var total := 0.0
	for i in range(1, p.size()):
		total += p[i - 1].distance_to(p[i])
	return total


static func resample(p: PackedVector2Array, n := N) -> PackedVector2Array:
	var out := PackedVector2Array()
	if p.is_empty():
		out.resize(n)
		return out
	var step := path_length(p) / (n - 1)
	out.append(p[0])
	var prev := p[0]
	var acc := 0.0
	var i := 1
	while i < p.size() and step > 0.0:
		var d := prev.distance_to(p[i])
		if d > 0.0 and acc + d >= step:
			prev = prev.lerp(p[i], (step - acc) / d)
			out.append(prev)
			acc = 0.0
		else:
			acc += d
			prev = p[i]
			i += 1
	while out.size() < n:
		out.append(p[p.size() - 1])
	out.resize(n)
	return out
