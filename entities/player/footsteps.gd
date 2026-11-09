class_name Footsteps extends Node
## A step sound every STRIDE px the player walks, on the surface of the current zone (Audio.surface, audio.md).
## Child of Player (added in Player._ready). Dodges and teleports (spawn, zone change) make no steps.

const STRIDE := 13.0
const MAX_STEP := 40.0   # a jump bigger than this in one physics frame is a teleport

var _acc := 0.0
var _last := Vector2.INF


func _physics_process(_delta: float) -> void:
	var p := get_parent() as Node2D
	if p == null:
		return
	var pos := p.global_position
	if _last == Vector2.INF:
		_last = pos
		return
	var d := pos.distance_to(_last)
	_last = pos
	if d > MAX_STEP or d < 0.05:
		return
	if p.get("state") == Player.State.DODGE:
		_acc = 0.0
		return
	_acc += d
	if _acc >= STRIDE:
		_acc = 0.0
		Snd.step()
