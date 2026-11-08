extends Interactable
## Opens once; the "chest:<id>" flag keeps it open across saves.

@export var chest_id := ""
@export var item_id := ""

var _open := false


func _ready() -> void:
	verb = "UI_VERB_OPEN"
	super()
	_open = get_node("/root/Game").has_flag("chest:" + chest_id)
	usable = not _open


func _draw() -> void:
	draw_rect(Rect2(-8, -1, 16, 3), Color(0.09, 0.07, 0.16, 0.45))
	draw_rect(Rect2(-8, -9, 16, 10), Color(0.09, 0.07, 0.16))
	if _open:
		draw_rect(Rect2(-7, -12, 14, 4), Color(0.28, 0.18, 0.10))
		draw_rect(Rect2(-7, -8, 14, 3), Color(0.14, 0.09, 0.06))
		draw_rect(Rect2(-7, -5, 14, 5), Color(0.45, 0.29, 0.15))
		draw_rect(Rect2(-1, -5, 2, 3), Color(0.75, 0.58, 0.22))
	else:
		draw_rect(Rect2(-7, -8, 14, 3), Color(0.68, 0.45, 0.22))
		draw_rect(Rect2(-7, -5, 14, 5), Color(0.52, 0.33, 0.16))
		draw_rect(Rect2(-7, -5, 14, 1), Color(0.88, 0.68, 0.26))
		draw_rect(Rect2(-5, -8, 2, 8), Color(0.88, 0.68, 0.26))
		draw_rect(Rect2(3, -8, 2, 8), Color(0.88, 0.68, 0.26))
		draw_rect(Rect2(-1, -6, 2, 3), Color(1.0, 0.88, 0.45))


func interact() -> void:
	if _open:
		return
	_open = true
	usable = false
	_refresh_prompt()
	var game := get_node("/root/Game")
	if item_id.begins_with("ilmu:"):   # an Ilmu chest (items.md Consumables and pickups)
		game.add_ilmu(int(item_id.get_slice(":", 1)))
	else:
		game.add_item(item_id, false)
	game.set_flag("chest:" + chest_id, false)
	game.save_game()
	get_node("/root/Events").item_picked.emit(item_id)
	queue_redraw()
