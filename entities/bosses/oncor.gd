class_name Oncor extends Node2D
## One of four torches ringing Sandekala's room (combat.md boss revamp v9). A player hit lights it; the flame burns
## `burn` seconds and then gutters out, so the four must be lit together. Its light pool is drawn on the floor and
## shrinks as the flame dies; Sandekala cannot enter a lit pool. When he falls the torches stay lit (keep_lit).
## ASSUMED: "a hit lights one" = the player hits the oncor itself (melee or spell), which makes the
## room the puzzle: the player must leave Sandekala and walk the ring.

signal lit_up
signal went_out

const POOL := 44.0                 # px: the light pool at full flame (Sandekala keeps out of it)
const LIGHT := Color(1.0, 0.9, 0.5)

@export var burn := 16.0           # TUNE: seconds a lit oncor burns; 0 = for good

var lit := false
var _left := 0.0
var _r := POOL

@onready var flame: Sprite2D = $Flame   # props/oncor.png: frame 0 cold, 1-3 burning
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var health: Health = $Health


func _ready() -> void:
	add_to_group("oncor")
	z_index = 51   # above Sandekala's darkness overlay (z 50): the torch and its pool stay visible in the dark
	flame.frame = 0
	hurtbox.hurt.connect(func(_h: Hitbox) -> void:
		health.hp = health.max_hp   # the torch is never destroyed
		light())
	queue_redraw()


func _process(delta: float) -> void:
	if not lit:
		return
	flame.frame = 1 + int(Time.get_ticks_msec() / 110.0) % 3
	if burn > 0.0:
		_left -= delta
		if _left <= 0.0:
			lit = false
			flame.frame = 0
			queue_redraw()
			went_out.emit()
			return
	var r := pool_radius()
	if not is_equal_approx(r, _r):
		_r = r
		queue_redraw()


## The radius of the lit pool now (0 when cold): shrinks over the last third of the burn.
func pool_radius() -> float:
	if not lit:
		return 0.0
	return roundf(POOL * (1.0 if burn <= 0.0 else lerpf(0.6, 1.0, clampf(_left / (burn * 0.33), 0.0, 1.0))))


func light() -> void:
	_left = burn   # a hit on a burning oncor feeds it
	if lit:
		return
	lit = true
	flame.frame = 1
	_r = pool_radius()
	queue_redraw()
	lit_up.emit()


## The fight is won: the torches burn on.
func keep_lit() -> void:
	burn = 0.0
	light()
	queue_redraw()


func _draw() -> void:
	if lit:
		BossKit.px_fill(self, BossKit.px_disc(_r), Color(LIGHT, 0.16))
		BossKit.px_fill(self, BossKit.px_disc(_r, _r - 2.0), Color(LIGHT, 0.6))
	else:
		BossKit.px_fill(self, BossKit.px_disc(POOL, POOL - 2.0), Color(LIGHT, 0.2))   # the pool to be lit
