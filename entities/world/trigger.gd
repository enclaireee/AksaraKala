extends Area2D
## Quest trigger: emits Events.area_entered(trigger_id) every time the player walks in.

@export var trigger_id := ""
@export var size := Vector2i(1, 1)   # tiles, centered on the node
@export var cond := ""


func _ready() -> void:
	var r := RectangleShape2D.new()
	r.size = Vector2(size * 16)
	$Shape.shape = r
	body_entered.connect(func(b: Node) -> void:
		if b.is_in_group("player") and get_node("/root/Game").check(cond):
			if not trigger_id.begins_with("beat_"):
				get_node("/root/Game").set_flag(trigger_id, false)
			var ev := get_node("/root/Events")
			ev.area_entered.emit(trigger_id)
			ev.puzzle_solved.emit(trigger_id.trim_prefix("puzzle_")))
