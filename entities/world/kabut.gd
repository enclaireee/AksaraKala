extends StaticBody2D
## Kabut fog gate (world.md Gating): blocks one tile until Game.flags[flag] is truthy, then fades away.
## Already lifted at load -> gone. An empty flag never lifts.

const FADE := 0.6   # TUNE

@export var flag := ""

var _pulse: Tween


func _ready() -> void:
	if _lifted():
		queue_free()
		return
	get_node("/root/Game").changed.connect(_on_changed)
	var fog: Node2D = $Fog
	_pulse = create_tween().set_loops()
	_pulse.tween_property(fog, "modulate:a", 0.55, 1.2).set_trans(Tween.TRANS_SINE)   # TUNE
	_pulse.tween_property(fog, "modulate:a", 1.0, 1.2).set_trans(Tween.TRANS_SINE)


func _lifted() -> bool:
	var flags: Dictionary = get_node("/root/Game").flags
	return flag != "" and flags.has(flag) and flags[flag]


func _on_changed() -> void:
	if not _lifted():
		return
	get_node("/root/Game").changed.disconnect(_on_changed)
	$Shape.set_deferred("disabled", true)
	_pulse.kill()
	var tw := create_tween()
	tw.tween_property($Fog, "modulate:a", 0.0, FADE)
	tw.tween_callback(queue_free)
