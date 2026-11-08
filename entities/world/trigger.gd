extends Area2D
## Quest trigger: emits Events.area_entered(trigger_id) every time the player walks in.

@export var trigger_id := ""
@export var size := Vector2i(1, 1)   # tiles, centered on the node
@export var cond := ""


func _ready() -> void:
	if StoryArt.tex(trigger_id) != null:   # a quest object stands here (lontar table, lamps...): draw it
		get_node("/root/Game").changed.connect(func() -> void: visible = get_node("/root/Game").check(cond))
		visible = get_node("/root/Game").check(cond)
		queue_redraw()
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


func _draw() -> void:
	var art := StoryArt.tex(trigger_id)
	if art != null:
		StoryArt.draw_centered(self, art)
