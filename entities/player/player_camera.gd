class_name PlayerCamera
extends Camera2D
## Follows the parent on whole pixels, leans toward the mouse, shakes (combat.md 2.1, 3.2).

const MAX_SHAKE := 3.0   # combat.md 3.2: never more than 3 px at 480x270

@export var lean := 16.0
var _amp := 0.0
var _left := 0.0
var _len := 1.0


func _ready() -> void:
	top_level = true
	make_current()


func shake(px: float, seconds: float) -> void:
	# ponytail: no settings slider yet (controls.md screenshake 0-100%); add with the settings menu
	if px >= _current():
		_amp = minf(px, MAX_SHAKE)
		_left = seconds
		_len = seconds


## Never show outside rect (the zone map). Camera2D limits clamp after lean and shake.
func set_bounds(rect: Rect2) -> void:
	limit_left = floori(rect.position.x)
	limit_top = floori(rect.position.y)
	limit_right = ceili(rect.end.x)
	limit_bottom = ceili(rect.end.y)


func _current() -> float:
	return _amp * _left / _len if _left > 0.0 else 0.0


func _process(delta: float) -> void:
	_left = maxf(0.0, _left - delta)
	# Lean from the mouse's screen offset, not its world position, so the lean cannot feed back into itself.
	var half := get_viewport_rect().size / 2.0
	var off := (get_viewport().get_mouse_position() - half) / half.y
	var shake := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _current()
	global_position = ((get_parent() as Node2D).global_position + off.limit_length(1.0) * lean + shake).round()
