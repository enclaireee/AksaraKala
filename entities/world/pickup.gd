extends Interactable
## Floor item or codex entry. ASSUMED: picked up on interact (not touch), so prompts stay consistent.
## Sparkles while an active quest's current step waits on item_picked:<item_id>.

@export var item_id := ""
@export var codex_id := ""

var _t := 0.0


func _key() -> String:
	return item_id if item_id != "" else codex_id


func _ready() -> void:
	verb = "UI_VERB_TAKE"
	super()
	if get_node("/root/Game").has_flag("pickup:" + _key()):
		queue_free()


func _process(delta: float) -> void:
	var game := get_node("/root/Game")
	var want := false
	if item_id != "":
		for q: String in game.quests:
			var s: QuestStep = game.current_step(q)
			if s and game._matches(s.on, "item_picked", item_id):
				want = true
	_t += delta
	modulate.a = 0.6 + 0.4 * sin(_t * 8.0) if want else 1.0


func _draw() -> void:
	draw_rect(Rect2(-3, -3, 6, 6), Color(0.4, 0.8, 1.0) if codex_id != "" else Color(0.9, 0.9, 0.5))


func interact() -> void:
	var game := get_node("/root/Game")
	usable = false
	if item_id != "":
		game.add_item(item_id, false)
		get_node("/root/Events").item_picked.emit(item_id)
	else:
		game.unlock_codex(codex_id, false)
	game.set_flag("pickup:" + _key(), false)
	game.save_game()
	queue_free()
