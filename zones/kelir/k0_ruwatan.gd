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

	# 3. Dalang Semar silhouette in the bottom-left corner
	var sx := 24.0
	var sy := 154.0
	_bg_fx.draw_circle(Vector2(sx, sy - 14), 7.0, Color(0.12, 0.09, 0.07)) # head & kuncung
	_bg_fx.draw_rect(Rect2(sx - 8, sy - 8, 16, 12), Color(0.12, 0.09, 0.07)) # stout body
	_bg_fx.draw_line(Vector2(sx + 5, sy - 4), Vector2(sx + 18, sy - 18), Color(0.12, 0.09, 0.07), 2.0) # cempurit / stick

	# 4. Wayang Gunungan (Tree of Life) puppet planted on the left
	var gx := 16.0
	var gy := 110.0
	var gunungan := PackedVector2Array([
		Vector2(gx, gy - 28),
		Vector2(gx + 12, gy + 4),
		Vector2(gx + 8, gy + 36),
		Vector2(gx - 8, gy + 36),
		Vector2(gx - 12, gy + 4)
	])
	_bg_fx.draw_colored_polygon(gunungan, Color(0.10, 0.07, 0.05, 0.75))

	# 5. Top ornate carved beam of the wayang screen
	_bg_fx.draw_rect(Rect2(0, 0, 480, 8), Color(0.24, 0.16, 0.10))
	_bg_fx.draw_rect(Rect2(0, 6, 480, 2), Color(0.75, 0.60, 0.25))


## Foreground effects: oil lamps, warm safe light circles, Batara Kala's shadow, and guidance banner.
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
	_draw_batara_kala_silhouette(Vector2(kala_x, kala_y))

	# 6. Brass Lamp Stands (Blencong) with animated flames
	for s: MemorySpot in lamps():
		var lp := s.position + Vector2(0, -4)
		_draw_lamp_stand(lp, s.done)

	# 7. Goal beacon at Spot5 (the exit of the shadow screen)
	var goal_spots := spots().filter(func(sp: MemorySpot) -> bool: return sp.action_kind == "goal")
	if not goal_spots.is_empty():
		var gp: Vector2 = goal_spots[0].position + Vector2(0, -8)
		var all_lit := lit_edge() >= 440.0
		var g_alpha := 0.7 + 0.3 * sin(_t * 4.0) if all_lit else 0.25
		_fx.draw_circle(gp, 6.0, Color(1.0, 0.85, 0.35, g_alpha))
		_fx.draw_arc(gp, 10.0 + sin(_t * 3.0) * 2.0, 0.0, TAU, 16, Color(1.0, 0.95, 0.6, g_alpha * 0.8), 1.5)

	# 8. Guidance HUD Banner at top of the Kelir
	_draw_guidance_banner()


## Draws Batara Kala's terrifying shadow silhouette with glowing demonic eyes.
func _draw_batara_kala_silhouette(pos: Vector2) -> void:
	var bx := pos.x
	var by := pos.y

	# Broad demonic shoulders & torso
	var torso := PackedVector2Array([
		Vector2(bx - 14, by - 12),
		Vector2(bx + 26, by - 16),
		Vector2(bx + 30, by + 40),
		Vector2(bx - 8, by + 40)
	])
	_fx.draw_colored_polygon(torso, Color(0.03, 0.01, 0.02, 0.98))

	# Massive horned demonic head
	var head := PackedVector2Array([
		Vector2(bx - 18, by - 26),
		Vector2(bx + 18, by - 36),
		Vector2(bx + 24, by - 18),
		Vector2(bx - 4, by - 10)
	])
	_fx.draw_colored_polygon(head, Color(0.02, 0.01, 0.02, 0.98))

	# Curving horns pointing forward
	_fx.draw_line(Vector2(bx - 10, by - 28), Vector2(bx - 26, by - 44), Color(0.02, 0.01, 0.02), 3.5)
	_fx.draw_line(Vector2(bx + 10, by - 30), Vector2(bx - 4, by - 50), Color(0.02, 0.01, 0.02), 3.5)

	# Gaping fanged jaws
	var jaw := PackedVector2Array([
		Vector2(bx - 16, by - 12),
		Vector2(bx - 24, by - 6),
		Vector2(bx - 14, by + 4),
		Vector2(bx - 6, by - 2)
	])
	_fx.draw_colored_polygon(jaw, Color(0.02, 0.01, 0.02))

	# Sharp white silhouette fangs
	_fx.draw_line(Vector2(bx - 20, by - 10), Vector2(bx - 22, by - 5), Color(0.9, 0.85, 0.8), 1.5)
	_fx.draw_line(Vector2(bx - 16, by - 8), Vector2(bx - 18, by - 3), Color(0.9, 0.85, 0.8), 1.5)

	# Piercing glowing crimson/amber eyes staring from the darkness
	var eye_pulse := 0.85 + 0.15 * sin(_t * 7.0)
	_fx.draw_circle(Vector2(bx - 12, by - 20), 3.0, Color(1.0, 0.25, 0.1, 0.6 * eye_pulse))
	_fx.draw_circle(Vector2(bx - 12, by - 20), 1.5, Color(1.0, 0.85, 0.3, eye_pulse))

	# Long reaching clawed shadow arm stretching toward the light
	var reach := sin(_t * 3.5) * 6.0
	_fx.draw_line(Vector2(bx - 8, by + 8), Vector2(bx - 28 + reach, by + 4), Color(0.03, 0.01, 0.02), 3.0)
	_fx.draw_line(Vector2(bx - 28 + reach, by + 4), Vector2(bx - 36 + reach, by - 2), Color(0.03, 0.01, 0.02), 2.0)
	_fx.draw_line(Vector2(bx - 28 + reach, by + 4), Vector2(bx - 38 + reach, by + 5), Color(0.03, 0.01, 0.02), 2.0)


## Draws a carved brass oil lamp stand (blencong).
func _draw_lamp_stand(pos: Vector2, lit: bool) -> void:
	var x := pos.x
	var y := pos.y

	# Brass pedestal and stem
	var metal := Color(0.78, 0.62, 0.26) if lit else Color(0.38, 0.32, 0.25)
	_fx.draw_rect(Rect2(x - 4, y + 2, 8, 3), metal) # base
	_fx.draw_rect(Rect2(x - 1, y - 6, 2, 8), metal) # stem
	_fx.draw_rect(Rect2(x - 5, y - 9, 10, 4), metal) # oil bowl

	if lit:
		# Dancing flame
		var flame_y := y - 11.0 + sin(_t * 14.0) * 0.8
		var flame_x := x + cos(_t * 11.0) * 0.6
		_fx.draw_circle(Vector2(flame_x, flame_y), 3.5, Color(1.0, 0.6, 0.1, 0.85))
		_fx.draw_circle(Vector2(flame_x, flame_y), 2.0, Color(1.0, 0.95, 0.5, 0.95))
		# Spark motes rising
		for i in 2:
			var sy := flame_y - 4.0 - float(i * 3) - fmod(_t * 8.0 + float(i * 3), 6.0)
			_fx.draw_circle(Vector2(flame_x + sin(_t * 6.0 + float(i)) * 1.5, sy), 0.8, Color(1.0, 0.8, 0.3, 0.7))
	else:
		# Unlit lamp: subtle interactive beacon pulse
		var pulse := 0.5 + 0.5 * sin(_t * 4.0)
		_fx.draw_circle(Vector2(x, y - 7), 2.0, UNLIT)
		_fx.draw_arc(Vector2(x, y - 6), 9.0 + pulse * 2.0, 0.0, TAU, 12, Color(1.0, 0.85, 0.4, 0.4 * pulse), 1.0)


## Renders an atmospheric guidance banner at the top of the kelir screen.
func _draw_guidance_banner() -> void:
	# Banner backing
	var bw := 340.0
	var bh := 16.0
	var bx := 240.0 - bw * 0.5
	var by := 12.0
	_fx.draw_rect(Rect2(bx, by, bw, bh), Color(0.08, 0.05, 0.04, 0.75))
	_fx.draw_rect(Rect2(bx, by + bh - 1, bw, 1), Color(0.75, 0.60, 0.25, 0.6))

	# Text hint
	var loc := TranslationServer.get_locale()
	var is_id := loc.begins_with("id")
	var count := 0
	for s: MemorySpot in lamps():
		if s.done:
			count += 1
	var hint_text := "WAYANG RUWATAN: Nyalakan pelita minyak [E] sebelum bayangan Kala menelanmu! (%d/4)" % count if is_id else "RUWATAN: Light the oil lamps [E] before Kala's shadow overtakes you! (%d/4)" % count

	var font := ThemeDB.fallback_font
	if font:
		_fx.draw_string(font, Vector2(bx + 12, by + 12), hint_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.96, 0.90, 0.75))
