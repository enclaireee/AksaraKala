extends KelirMemory
## K0, the first ruwatan (desa_purwa.md "Kelir memory K0"). The interact spots are the lamp stands: the leftmost
## starts lit, each lit one is the checkpoint. Kala's shadow is a band from the right edge that moves left at
## SHADOW_SPEED and stops at lit ground (the right edge of the rightmost lit circle); touching it is fail().

const LAMP_R := 120.0            # TUNE: lit circle radius, px
const SHADOW_SPEED := 16.0       # TUNE: 1 tile/s
const SHADOW_START := 29 * 16.0  # TUNE: start x
const SHADOW := Color(0.05, 0.03, 0.02, 0.94)
const LIT := Color("F2D9A0")
const UNLIT := Color("6B625A")

var edge := SHADOW_START
var _fx := Node2D.new()
var _bg_fx := Node2D.new()
var _t := 0.0
var _flash := 0.0
var _kala: Sprite2D
var _lamp_sprites := {}


## Sprite from assets/art/cutscene/; `feet` = bottom-centre when `feet_origin`, else top-left.
func _sprite(parent: Node, art: String, pos: Vector2, feet_origin := true) -> Sprite2D:
	var sp := Sprite2D.new()
	sp.texture = load("res://assets/art/cutscene/%s.png" % art)
	sp.centered = false
	var w := sp.texture.get_width() / (4 if art == "lamp_stand" else 1)
	if feet_origin:
		sp.offset = Vector2(-w / 2.0, -sp.texture.get_height())
	sp.position = pos.round()
	parent.add_child(sp)
	return sp


func _ready() -> void:
	super()
	var l := lamps()
	for i in l.size():   # the lamps you light tell the story in order: MEM_K0_RUWATAN_1..3
		l[i].line_key = "MEM_K0_RUWATAN_%d" % i if i > 0 else ""
	if not l.is_empty():
		l[0].done = true
		l[0].usable = false

	# Background screen dressing (behind stand-in)
	_bg_fx.z_index = 0
	_bg_fx.draw.connect(_draw_bg)
	add_child(_bg_fx)

	# Wayang sprites (tools/gen_cutscene_art.py): Semar and the gunungan planted in the banana log
	for d in [["puppet_semar", Vector2(32, 160)], ["puppet_gunungan", Vector2(14, 150)]]:
		var sp := _sprite(_bg_fx, d[0], d[1])
		sp.modulate = Color(1, 1, 1, 0.85)
	# Batara Kala is a sprite now; _draw_fx only moves it and draws his eyes
	_kala = _sprite(_fx, "puppet_kala", Vector2.ZERO, false)
	for s: MemorySpot in lamps():
		var ls := _sprite(_fx, "lamp_stand", s.position + Vector2(0, 14))
		ls.region_enabled = true
		_lamp_sprites[s] = ls

	# Foreground darkness and lighting effects (over stand-in)
	_fx.z_index = 5
	_fx.draw.connect(_draw_fx)
	add_child(_fx)


## Lamp stands, left to right.
func lamps() -> Array:
	var out := spots().filter(func(s: MemorySpot) -> bool: return s.action_kind == "interact")
	out.sort_custom(func(a: Node2D, b: Node2D) -> bool: return a.position.x < b.position.x)
	return out


## Right edge of lit ground: the shadow never passes it.
func lit_edge() -> float:
	var e := -INF
	for s: MemorySpot in lamps():
		if s.done:
			e = maxf(e, s.position.x + LAMP_R)
	return e


func spot_done(spot: MemorySpot) -> void:
	if spot.action_kind == "interact":
		checkpoint = spot
		_flash = 1.0
	super(spot)


func _physics_process(delta: float) -> void:
	super(delta)
	_t += delta
	if _flash > 0.0:
		_flash = maxf(0.0, _flash - delta * 2.0)
	if stand_in == null or _done:
		return
	if not _busy:
		edge = maxf(edge - SHADOW_SPEED * delta, lit_edge())   # lighting a lamp in the dark pushes it back
		if stand_in.position.x >= edge:
			fail()
	_bg_fx.queue_redraw()
	_fx.queue_redraw()


## Background elements of the Wayang Kelir: screen cloth, banana log, framing, and dalang silhouette.
func _draw_bg() -> void:
	# 1. Stretched kelir screen backing with warm backlit ambience
	_bg_fx.draw_rect(Rect2(0, 0, 480, 272), Color(0.92, 0.88, 0.78, 0.4))

	# 2. Gedebog (banana trunk) along the bottom where puppets are planted
	_bg_fx.draw_rect(Rect2(0, 148, 480, 12), Color(0.28, 0.42, 0.20))
	_bg_fx.draw_rect(Rect2(0, 160, 480, 112), Color(0.18, 0.14, 0.12))

	# 3. Semar and the gunungan are sprites (see _ready)

	# 5. Top ornate carved beam of the wayang screen
	_bg_fx.draw_rect(Rect2(0, 0, 480, 8), Color(0.24, 0.16, 0.10))
	_bg_fx.draw_rect(Rect2(0, 6, 480, 2), Color(0.75, 0.60, 0.25))


## Foreground effects: oil lamps, warm safe light circles, and Batara Kala's shadow.
func _draw_fx() -> void:
	# 1. Warm radiant safe-zone light from lit lamps
	for s: MemorySpot in lamps():
		if s.done:
			var lp := s.position + Vector2(0, -6)
			var flick := 1.0 + 0.05 * sin(_t * 9.0 + s.position.x)
			_fx.draw_circle(lp, LAMP_R * flick, Color(1.0, 0.90, 0.60, 0.12))
			_fx.draw_circle(lp, LAMP_R * 0.55 * flick, Color(1.0, 0.92, 0.70, 0.18))
			_fx.draw_circle(lp, LAMP_R * 0.25 * flick, Color(1.0, 0.96, 0.80, 0.28))

	# 2. Lighting burst flash when a new lamp is ignited
	if _flash > 0.0:
		_fx.draw_rect(Rect2(0, 0, 480, 272), Color(1.0, 0.95, 0.75, 0.35 * _flash))

	# 3. Creeping shadow of Batara Kala covering from `edge` to the right
	_fx.draw_rect(Rect2(edge, 0, 4096, 4096), SHADOW)

	# 4. Tendrils and swirling darkness along the shadow boundary
	for y_step in range(0, 272, 16):
		var y := float(y_step)
		var wave := sin(y * 0.12 + _t * 5.0) * 10.0 + cos(y * 0.06 - _t * 3.0) * 6.0
		var tx := edge + wave - 8.0
		_fx.draw_circle(Vector2(tx, y), 10.0, Color(0.04, 0.02, 0.02, 0.85))

	# 5. Batara Kala's looming monstrous silhouette towering at the shadow front
	var kala_x := edge + 22.0
	var kala_y := 105.0 + sin(_t * 2.2) * 4.0
	_place_kala(Vector2(kala_x, kala_y))

	# 6. Brass Lamp Stands (Blencong) with animated flames
	for s: MemorySpot in lamps():
		_draw_lamp_stand(s, s.done)

	# 7. Goal beacon at Spot5 (the exit of the shadow screen)
	var goal_spots := spots().filter(func(sp: MemorySpot) -> bool: return sp.action_kind == "goal")
	if not goal_spots.is_empty():
		var gp: Vector2 = goal_spots[0].position + Vector2(0, -8)
		var all_lit := lit_edge() >= 440.0
		var g_alpha := 0.7 + 0.3 * sin(_t * 4.0) if all_lit else 0.25
		_fx.draw_circle(gp, 6.0, Color(1.0, 0.85, 0.35, g_alpha))
		_fx.draw_arc(gp, 10.0 + sin(_t * 3.0) * 2.0, 0.0, TAU, 16, Color(1.0, 0.95, 0.6, g_alpha * 0.8), 1.5)


## Moves the Batara Kala sprite and pulses his eyes (sprite origin sits 27 px left and 40 px above `pos`).
func _place_kala(pos: Vector2) -> void:
	_kala.position = (pos - Vector2(27, 40)).round()
	var eye_pulse := 0.85 + 0.15 * sin(_t * 7.0)
	for e: Vector2 in [Vector2(15, 20), Vector2(21, 18)]:
		var ep := _kala.position + e + Vector2(0.5, 0.5)
		_fx.draw_circle(ep, 2.6, Color(1.0, 0.25, 0.1, 0.55 * eye_pulse))
		_fx.draw_circle(ep, 1.2, Color(1.0, 0.85, 0.3, eye_pulse))


## Brass lamp stand sprite: frame 0 unlit, 1-3 the flame. Unlit lamps also pulse a beacon ring.
func _draw_lamp_stand(spot: MemorySpot, lit: bool) -> void:
	var ls: Sprite2D = _lamp_sprites[spot]
	var f := 1 + int(_t * 9.0 + spot.position.x) % 3 if lit else 0
	ls.region_rect = Rect2(f * 14, 0, 14, 24)
	if lit:
		var fy := spot.position.y + 14.0 - 21.0
		for i in 2:   # spark motes rising
			var sy := fy - 4.0 - float(i * 3) - fmod(_t * 8.0 + float(i * 3), 6.0)
			_fx.draw_rect(Rect2(spot.position.x + roundf(sin(_t * 6.0 + float(i)) * 1.5), roundf(sy), 1, 1), Color(1.0, 0.8, 0.3, 0.8))
	else:
		var pulse := 0.5 + 0.5 * sin(_t * 4.0)
		_fx.draw_arc(spot.position + Vector2(0, -6), 9.0 + pulse * 2.0, 0.0, TAU, 12, Color(1.0, 0.85, 0.4, 0.4 * pulse), 1.0)

