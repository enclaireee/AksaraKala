extends Area2D
## Quest trigger: emits Events.area_entered(trigger_id) every time the player walks in.

@export var trigger_id := ""
@export var size := Vector2i(1, 1)   # tiles, centered on the node


func _ready() -> void:
	var r := RectangleShape2D.new()
	r.size = Vector2(size * 16)
	$Shape.shape = r
	body_entered.connect(func(b: Node) -> void:
		if b.is_in_group("player"):
			get_node("/root/Events").area_entered.emit(trigger_id))
