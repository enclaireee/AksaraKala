extends KelirMemory
## K0, the first ruwatan (desa_purwa.md "Kelir memory K0"), v2 (.docs/revamp_plan.md 1).
## The interact spots are the lamp stands: the leftmost starts lit, each lit one is the checkpoint. Kala's shadow is a
## tide from the right edge that moves left at SHADOW_SPEED and stops at lit ground (the right edge of the rightmost lit
## circle); touching it is fail(). Everything on screen is a sprite from tools/gen_revamp_art.py:
## screen (cloth, beam, posts, log, dark house), lamp stands, lamp glow, ignition burst, the hint ring on the next dark
## lamp, the pointing hand, the shadow tide and Batara Kala in three poses. The stage pill and the danger meter come
## from KelirStage (kelir_stage.gd).

const LAMP_R := 120.0            # TUNE: lit circle radius, px (lamp_glow.png is 2 x this)
const SHADOW_SPEED := 16.0       # TUNE: 1 tile/s
const SHADOW_START := 29 * 16.0  # TUNE: start x
const WALK_Y := Vector2(88.0, 140.0)   # the stand-in walks the cloth only
const METER_RANGE := 224.0       # px of distance the meter spans
const ART := "res://assets/art/cutscene/"

var edge := SHADOW_START
var _t := 0.0
var _kala: Sprite2D
var _tide: Sprite2D
var _fill: ColorRect
var _eyes := Node2D.new()
var _lamps := {}                 # MemorySpot -> {stand, glow, hint, burst, burst_t, was_done}
var _hand: Sprite2D
var _obj_idx := -1


func _tex(name: String) -> Texture2D:
	return load(ART + name + ".png")


## Sprite from assets/art/cutscene/. `feet` = bottom-centre when true, else top-left.
func _sprite(parent: Node, art: String, pos: Vector2, feet := true, frame_w := 0, z := 0) -> Sprite2D:
	var sp := Sprite2D.new()
	sp.texture = _tex(art)
	sp.centered = false
	var w := frame_w if frame_w > 0 else sp.texture.get_width()
	if frame_w > 0:
		sp.region_enabled = true
		sp.region_rect = Rect2(0, 0, frame_w, sp.texture.get_height())
	if feet:
		sp.offset = Vector2(-w / 2.0, -sp.texture.get_height())
	sp.position = pos.round()
	sp.z_index = z
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

	var tiles := get_node_or_null("Tiles") as CanvasItem   # the walls still collide, the screen art is the picture
	if tiles:
		tiles.modulate.a = 0.0
	if stand_in:
		stand_in.z_index = 3

	_sprite(self, "k0_screen", Vector2.ZERO, false, 0, -20)

	# The gamelan in the dark house, and the puppets planted in the banana log
	_sprite(self, "niyaga_gong", Vector2(96, 222), true, 20, -12)
	_sprite(self, "niyaga_saron", Vector2(228, 230), true, 20, -12)
	_sprite(self, "niyaga_kendang", Vector2(372, 224), true, 0, -12)
	for d in [["puppet_semar", Vector2(32, 160)], ["puppet_gunungan", Vector2(14, 150)], ["puppet_semar", Vector2(452, 160)]]:
		var sp := _sprite(self, d[0], d[1], true, 0, -15)
		sp.modulate = Color(1, 1, 1, 0.9)
		if d[1].x > 400:
			sp.flip_h = true

	# The cloth is dim until a lamp lights it: a dark veil, and each lit lamp adds warm light on top of it
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.04, 0.58)
	dim.position = Vector2(8, 12)
	dim.size = Vector2(464, 136)
	dim.z_index = -6
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	for s: MemorySpot in l:
		var info := {}
		var glow := _sprite(self, "lamp_glow", s.position + Vector2(0, -6), false, 0, -5)
		glow.offset = Vector2(-120, -120)
		var mat := CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		glow.material = mat
		glow.visible = false
		info.glow = glow
		info.stand = _sprite(self, "lamp_stand", s.position + Vector2(0, 14), true, 14, 4)
		info.hint = _sprite(self, "lamp_hint", s.position + Vector2(0, -8), false, 28, 5)
		info.hint.offset = Vector2(-14, -14)
		info.hint.visible = false
		info.burst = _sprite(self, "lamp_burst", s.position + Vector2(0, -8), false, 40, 5)
		info.burst.offset = Vector2(-20, -20)
		info.burst.visible = false
		info.burst_t = -1.0
		info.was_done = s.done
		_lamps[s] = info
		if s.done:
			glow.visible = true

	# The goal beacon sits at Spot5 (the gate sprite comes from MemorySpot)
	_hand = _sprite(self, "pointing_hand", Vector2.ZERO, false, 20, 6)
	_hand.offset = Vector2(-20, -7)

	# Foreground: the shadow tide, Kala, and his eyes
	_fill = ColorRect.new()
	_fill.color = Color("0B0610")
	_fill.size = Vector2(4096, 4096)
	_fill.z_index = 6
	_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fill)
	_tide = _sprite(self, "shadow_tide", Vector2.ZERO, false, 40, 6)
	_tide.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_kala = _sprite(self, "k0_kala", Vector2.ZERO, false, 96, 7)
	_eyes.z_index = 8
	_eyes.draw.connect(_draw_eyes)
	add_child(_eyes)
	_place_shadow()


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


func lit_count() -> int:
	return lamps().filter(func(s: MemorySpot) -> bool: return s.done).size()


func spot_done(spot: MemorySpot) -> void:
	if spot.action_kind == "interact":
		checkpoint = spot
		if stage:
			stage.flash(0.3, 0.45)
		_refresh_objective()
	super(spot)


## The pill follows the lesson: first light a lamp, then stay in the light, then reach the edge.
func _refresh_objective() -> void:
	if stage == null or _intro:
		return
	var n := lit_count()
	var idx := 0 if n <= 1 else (1 if n < lamps().size() else 2)
	if idx == _obj_idx:
		return
	_obj_idx = idx
	var key := "MEM_K0_RUWATAN_HINT" if idx == 0 else "MEM_K0_RUWATAN_HINT_%d" % (idx + 1)
	stage.objective(tr(key), "move_right" if idx == 2 else "interact")


func show_objective() -> void:   # after the curtain-up, and again after the third fail
	_obj_idx = -1
	_refresh_objective()


func _physics_process(delta: float) -> void:
	super(delta)
	_t += delta
	if stand_in == null or _done:
		return
	stand_in.position.y = clampf(stand_in.position.y, WALK_Y.x, WALK_Y.y)
	if acting():
		edge = maxf(edge - SHADOW_SPEED * delta, lit_edge())   # lighting a lamp in the dark pushes it back
		if stand_in.position.x >= edge:
			fail()
	_update_lamps(delta)
	_place_shadow()
	if stage:
		var d := maxf(edge - stand_in.position.x, 0.0)
		stage.set_meter(tr("UI_KELIR_K0_METER").replace("{m}", str(int(d / 16.0))), d / METER_RANGE)


## A fail puts the stand-in at the last lamp; the tide gives back a little ground so the retry is fair.
func reset() -> void:
	super()
	edge = minf(edge + 48.0, SHADOW_START)


func _update_lamps(delta: float) -> void:
	var next: MemorySpot = null
	for s: MemorySpot in lamps():
		var info: Dictionary = _lamps[s]
		var stand: Sprite2D = info.stand
		var lit: bool = s.done
		var f := 1 + int(_t * 9.0 + s.position.x) % 3 if lit else 0
		stand.region_rect = Rect2(f * 14, 0, 14, 24)
		var glow: Sprite2D = info.glow
		glow.visible = lit
		if lit:
			glow.modulate.a = 0.92 + 0.08 * sin(_t * 9.0 + s.position.x)
		if lit and not info.was_done:   # just lit: burst, then the glow settles
			info.burst_t = 0.0
			Snd.play("pickup_rare")
		info.was_done = lit
		var b: Sprite2D = info.burst
		if info.burst_t >= 0.0:
			info.burst_t += delta
			var bf := int(info.burst_t / 0.07)
			b.visible = bf < 5
			if bf < 5:
				b.region_rect = Rect2(bf * 40, 0, 40, 40)
			else:
				info.burst_t = -1.0
		if not lit and next == null and s.position.x <= lit_edge() + LAMP_R:
			next = s
	for s: MemorySpot in lamps():
		var h: Sprite2D = _lamps[s].hint
		h.visible = s == next and not _intro
		if h.visible:
			h.region_rect = Rect2(28 * (int(_t * 6.0) % 4), 0, 28, 28)
	# the pointing hand leads the first step only (lamp 2), and bobs toward it
	_hand.visible = false
	if next != null and lit_count() <= 1 and not _intro:
		_hand.visible = true
		_hand.position = (next.position + Vector2(-34 + sin(_t * 5.0) * 3.0, -30)).round()
		_hand.region_rect = Rect2(20 * (int(_t * 3.0) % 2), 0, 20, 14)


## Moves the tide, Kala and his eyes. Kala reaches further the closer the stand-in is.
func _place_shadow() -> void:
	if _kala == null:
		return
	_fill.position = Vector2(edge + 24.0, -20.0)
	_tide.position = Vector2(roundf(edge - 15.0), -16.0).round()
	_tide.region_rect = Rect2(40 * (int(_t * 5.0) % 4), 0, 40, 64 * 5)
	var d := (edge - stand_in.position.x) if stand_in else 999.0
	var pose := 2 if d < 56.0 else (1 if d < 130.0 else 0)
	_kala.region_rect = Rect2(pose * 96, 0, 96, 96)
	_kala.position = Vector2(roundf(edge - 6.0 - pose * 3.0), roundf(44.0 + sin(_t * 2.2) * 3.0))
	_eyes.queue_redraw()


func _draw_eyes() -> void:
	var pose := int(_kala.region_rect.position.x / 96.0)
	var hx := (0, 5, 12)[pose]
	var pulse := 0.6 + 0.4 * sin(_t * 7.0)
	for e: Vector2 in [Vector2(22 + hx, 31), Vector2(36 + hx, 29)]:
		var ep := _kala.position + e + Vector2(0.5, 0.5)
		_eyes.draw_circle(ep, 4.2, Color(1.0, 0.25, 0.1, 0.22 * pulse))
		_eyes.draw_circle(ep, 2.4, Color(1.0, 0.45, 0.15, 0.35 * pulse))
