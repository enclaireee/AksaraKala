extends Interactable
## Floor item or codex entry. ASSUMED: picked up on interact (not touch), so prompts stay consistent.
## Sparkles while an active quest's current step waits on item_picked:<item_id>.

@export var item_id := ""
@export var codex_id := ""
@export var drop := false   # enemy drop (bestiary.md Drops): item_id "herb" or "flask"; collected on touch, no flag, no save
@export var cond := ""      # hidden and not interactable while Game.check(cond) is false (like Npc.cond)

var _t := 0.0


func _key() -> String:
	return item_id if item_id != "" else codex_id


func _ready() -> void:
	verb = "UI_VERB_TAKE"
	super()
	if drop:
		usable = false
		body_entered.connect(_on_touch)
		return
	var game := get_node("/root/Game")
	if game.has_flag("pickup:" + _key()):
		queue_free()
		return
	game.changed.connect(_apply_cond)
	_apply_cond()


func _apply_cond() -> void:
	var on: bool = get_node("/root/Game").check(cond)
	visible = on
	usable = on
	if not on:
		_prompt.visible = false
	elif _near:
		_refresh_prompt()


func _process(delta: float) -> void:
	var game := get_node("/root/Game")
	var want := false
	if item_id != "":
		for q: String in game.quests:
			var s: QuestStep = game.current_step(q)
			if s == null:
				continue
			if game._matches(s.on, "item_picked", item_id):
				want = true
			for i in s.all.size():   # an `all` step: any trigger not yet struck
				if not game._all_bit(q, i) and game._matches(str(s.all[i].get("on", "")), "item_picked", item_id):
					want = true
	_t += delta
	modulate.a = 0.6 + 0.4 * sin(_t * 8.0) if want else 1.0


func _draw() -> void:
	var art := StoryArt.tex(_key(), true)
	if art != null and not drop:
		StoryArt.draw_standing(self, art)
		return
	draw_rect(Rect2(-4, -4, 8, 8), Color(0.09, 0.07, 0.16))
	if codex_id != "":
		draw_rect(Rect2(-3, -3, 6, 6), Color(0.25, 0.72, 0.95))
		draw_rect(Rect2(-2, -2, 4, 2), Color(0.75, 0.95, 1.0))
	elif item_id == "herb":
		draw_rect(Rect2(-3, -3, 6, 6), Color(0.35, 0.78, 0.35))
		draw_rect(Rect2(-2, -2, 3, 3), Color(0.68, 0.95, 0.52))
	elif item_id == "flask":
		draw_rect(Rect2(-3, -2, 6, 5), Color(0.88, 0.55, 0.18))
		draw_rect(Rect2(-1, -4, 2, 2), Color(0.95, 0.82, 0.45))
	else:
		draw_rect(Rect2(-3, -3, 6, 6), Color(0.95, 0.76, 0.25))
		draw_rect(Rect2(-2, -2, 3, 2), Color(1.0, 0.95, 0.72))


func _on_touch(b: Node) -> void:
	if not b.is_in_group("player"):
		return
	var game := get_node("/root/Game")
	if item_id == "herb":
		(b.get("health") as Health).heal(roundi(0.2 * b.health.max_hp))   # TUNE
	elif item_id == "flask":
		game.flask_charges = mini(game.flask_max, game.flask_charges + 1)
		game.changed.emit()
	get_node("/root/Events").item_picked.emit(item_id)   # HUD "Got:" toast; no quest step listens to herb/flask
	set_deferred("monitoring", false)
	queue_free()


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
