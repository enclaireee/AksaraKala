class_name Ririwa extends Pocong
## SQ-G2 elite (bestiary.md "Elite: Ririwa"): a Pocong-class Charger that first sweeps a wide broom arc
## (ground marker, 0.5 s wind-up), then rushes. Weakness Bind comes from Pocong. Inert until quest sq_g2 is at step 2.
## The name "ririwa" as a Sundanese ghost term is VERIFY. Cartoonish, no gore. All numbers TUNE.

const SWEEP_AT := 0.5      # TUNE: wind-up before the sweep lands (the scene's charger_windup is 1.0: sweep, then the rush line)
const SWEEP_TIME := 0.2    # TUNE: how long the arc hurts
const SWEEP_ARC := 200.0   # TUNE: degrees
const SWEEP_REACH := 34.0  # TUNE: pixels

var active := true
var swept := false

@onready var sweep: Hitbox = $Aim/Sweep
@onready var sweep_marker: Polygon2D = $Aim/Sweep/Slash


func _ready() -> void:
	super()
	if is_queued_for_deletion():
		return
	var pts := Player._arc(SWEEP_ARC, SWEEP_REACH)
	($Aim/Sweep/Arc as CollisionPolygon2D).polygon = pts
	sweep_marker.polygon = pts
	var g := EliteGuard.new()
	g.cond = "step:sq_g2=2"
	add_child(g)


func _tick(delta: float) -> void:
	super(delta)
	if state == State.TELEGRAPH and not swept and state_time >= SWEEP_AT:
		swept = true
		sweep_marker.color.a = 0.6
		sweep.activate()
	elif swept and state_time >= SWEEP_AT + SWEEP_TIME:
		sweep.deactivate()
		sweep_marker.visible = false


func _enter(s: State) -> void:
	sweep.deactivate()
	swept = false
	sweep_marker.visible = s == State.TELEGRAPH   # the ground marker while winding up
	sweep_marker.color.a = 0.25
	super(s)


func _on_died() -> void:
	super()
	sweep.deactivate()
	sweep_marker.visible = false
