class_name KelirDecor extends Node2D
## Shadow-screen dressing shared by every Kelir memory (memory.gd adds it): a backlit cloth under and around the map,
## a carved top beam with two hanging blencong lamps, posts down both sides, a banana-trunk (gedebog) floor line and a
## cast of wayang puppets standing in the margins, picked per memory. All sprites: tools/gen_cutscene_art.py.
## ASSUMED: puppet picks per memory (a flavour, not canon).

const ART := "res://assets/art/cutscene/"
const MARGIN := 192.0
const CASTS := {
	"k1": ["gunungan", "buto", "semar", "buto"], "k2": ["putri", "lesung", "bangau", "gunungan"],
	"k3": ["lesung", "putri", "semar"], "k4": ["putri", "buto", "gunungan", "kerbau"],
	"k5": ["pande", "arjuna", "gunungan"], "k6": ["putri", "cepot", "semar"],
	"k8": ["putri", "perahu", "semar"], "k9": ["perahu", "putri", "bangau"],
	"k10": ["kala", "gunungan", "buto"], "h": ["semar", "cepot", "gunungan"],
	"lc": ["putri", "bangau", "gunungan"], "sq_t": ["kerbau", "cepot", "gunungan"],
	"sq_s": ["lutung", "gunungan", "semar"], "sq_k": ["perahu", "bangau", "semar"],
	"sq_m": ["putri", "cepot", "gunungan"], "sq_c": ["cepot", "lesung", "gunungan"],
	"sq_g": ["putri", "cepot", "kerbau"],
}
const DEFAULT_CAST := ["semar", "gunungan", "arjuna"]

var _lamps: Array[Sprite2D] = []
var _puppets: Array = []
var _t := 0.0


## `rect` = the playable area (used tiles, px). `cool` tints Laras's chapters.
func setup(memory_id: String, rect: Rect2, cool: bool) -> void:
	z_index = -50
	var tint := Color("D5E2F0") if cool else Color.WHITE
	var area := rect.grow(MARGIN)
	var cloth := _tiled("cloth_tile", area)
	cloth.modulate = tint
	cloth.z_index = 0
	# beam, floor line and posts sit on the playable-area edge
	var beam := _tiled("beam_tile", Rect2(rect.position.x - 24.0, rect.position.y - 40.0, rect.size.x + 48.0, 12.0))
	beam.z_index = 3
	var floor_line := _tiled("prologue_floor", Rect2(rect.position.x - 24.0, rect.end.y + 4.0, rect.size.x + 48.0, 16.0))
	floor_line.z_index = 3
	for x in [rect.position.x - 24.0, rect.end.x + 16.0]:
		var post := _tiled("post_tile", Rect2(x, rect.position.y - 40.0, 8.0, rect.size.y + 64.0))
		post.z_index = 4
	for i in 2:
		var lamp := Sprite2D.new()
		lamp.texture = load(ART + "blencong.png")
		lamp.centered = false
		lamp.region_enabled = true
		lamp.region_rect = Rect2(0, 0, 14, 22)
		lamp.position = Vector2(rect.position.x + rect.size.x * (0.3 + 0.4 * i) - 7.0, rect.position.y - 28.0).round()
		lamp.z_index = 5
		add_child(lamp)
		_lamps.append(lamp)
	var cast := _cast_for(memory_id)
	var rnd := RandomNumberGenerator.new()
	rnd.seed = hash(memory_id)
	# puppets: a row along the top margin (above the beam they read as the dalang's shelf), a row under the floor line
	var n := int(rect.size.x / 80.0) + 2
	for i in n:
		var pn: String = cast[(i + rnd.randi() % 2) % cast.size()]
		var sp := Sprite2D.new()
		sp.texture = load(ART + "puppet_%s.png" % pn)
		sp.centered = false
		sp.offset = Vector2(-sp.texture.get_width() / 2.0, -sp.texture.get_height())
		var x := rect.position.x - 20.0 + float(i) * (rect.size.x + 40.0) / float(maxi(1, n - 1)) + rnd.randf_range(-10.0, 10.0)
		var base := Vector2(x, rect.position.y - 44.0 if i % 2 == 0 else rect.end.y + 52.0)
		sp.position = base.round()
		sp.modulate = Color(1, 1, 1, 0.78)
		sp.z_index = 2
		sp.flip_h = rnd.randf() < 0.5
		add_child(sp)
		_puppets.append([sp, base, rnd.randf_range(0.8, 2.2), rnd.randf() * TAU])


func _process(delta: float) -> void:
	_t += delta
	for l in _lamps:
		l.region_rect = Rect2(14 * (int(_t * 7.0 + l.position.x) % 3), 0, 14, 22)
	for p in _puppets:
		var s: Sprite2D = p[0]
		s.position = (p[1] + Vector2(roundf(sin(_t * p[2] + p[3]) * 2.0), 0.0))


func _tiled(art: String, r: Rect2) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(ART + art + ".png")
	s.centered = false
	s.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	s.region_enabled = true
	s.region_rect = Rect2(Vector2.ZERO, r.size)
	s.position = r.position.round()
	add_child(s)
	return s


static func _cast_for(memory_id: String) -> Array:
	var best := ""
	for k: String in CASTS:
		if memory_id.begins_with(k) and k.length() > best.length():
			best = k
	if best == "k1" and memory_id.begins_with("k10"):
		best = "k10"
	return CASTS.get(best, DEFAULT_CAST)
