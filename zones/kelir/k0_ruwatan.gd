extends KelirMemory
## K0, the first ruwatan (desa_purwa.md "Kelir memory K0"). The interact spots are the lamp stands: the leftmost
## starts lit, each lit one is the checkpoint. Kala's shadow is a band from the right edge that moves left at
## SHADOW_SPEED and stops at lit ground (the right edge of the rightmost lit circle); touching it is fail().

const LAMP_R := 120.0            # TUNE: lit circle radius, px
const SHADOW_SPEED := 16.0       # TUNE: 1 tile/s
const SHADOW_START := 29 * 16.0  # TUNE: start x
const SHADOW := Color(0.05, 0.03, 0.02, 0.92)
const LIT := Color("F2D9A0")
const UNLIT := Color("6B625A")

var edge := SHADOW_START
var _fx := Node2D.new()


func _ready() -> void:
	super()
	var l := lamps()
	for i in l.size():   # the lamps you light tell the story in order: MEM_K0_RUWATAN_1..3
		l[i].line_key = "MEM_K0_RUWATAN_%d" % i if i > 0 else ""
	if not l.is_empty():
		l[0].done = true
		l[0].usable = false
	_fx.z_index = 5   # over the tiles and the stand-in
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
	super(spot)


func _physics_process(delta: float) -> void:
	super(delta)
	if stand_in == null or _done:
		return
	if not _busy:
		edge = maxf(edge - SHADOW_SPEED * delta, lit_edge())   # lighting a lamp in the dark pushes it back
		if stand_in.position.x >= edge:
			fail()
	_fx.queue_redraw()


func _draw_fx() -> void:
	_fx.draw_rect(Rect2(edge, 0, 4096, 4096), SHADOW)
	for s: MemorySpot in lamps():
		_fx.draw_circle(s.position + Vector2(0, -6), 3.0, LIT if s.done else UNLIT)
