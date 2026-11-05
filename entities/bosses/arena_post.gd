class_name ArenaPost extends Interactable
## Sangkuriang's east post. Hang the boeh rarang on it; the "post:<id>" flag keeps it hung.

@export var post_id := "east"

var hung := false


func _ready() -> void:
	super()
	hung = get_node("/root/Game").has_flag("post:" + post_id)
	usable = not hung


func _draw() -> void:
	draw_rect(Rect2(-1, -22, 2, 22), Color(0.4, 0.28, 0.15))
	if hung:
		draw_rect(Rect2(1, -22, 9, 7), Color(0.8, 0.15, 0.15))   # ASSUMED red cloth (VERIFY: red or boeh rarang)


func interact() -> void:
	var game := get_node("/root/Game")
	if hung or "boeh_rarang" not in game.inventory:
		return
	hung = true
	usable = false
	_refresh_prompt()
	game.set_flag("post:" + post_id, false)   # stays hung for the rest of the fight; the cloth is kept
	queue_redraw()
