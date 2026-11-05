extends Interactable
## Opens once; the "chest:<id>" flag keeps it open across saves.

@export var chest_id := ""
@export var item_id := ""

var _open := false


func _ready() -> void:
	super()
	_open = get_node("/root/Game").has_flag("chest:" + chest_id)
	usable = not _open


func _draw() -> void:
	draw_rect(Rect2(-7, -5, 14, 10), Color(0.35, 0.25, 0.1) if _open else Color(0.7, 0.5, 0.2))
	if _open:
		draw_rect(Rect2(-7, -8, 14, 3), Color(0.2, 0.14, 0.05))


func interact() -> void:
	if _open:
		return
	_open = true
	usable = false
	_refresh_prompt()
	var game := get_node("/root/Game")
	game.add_item(item_id, false)
	game.set_flag("chest:" + chest_id, false)
	game.save_game()
	get_node("/root/Events").item_picked.emit(item_id)
	queue_redraw()
