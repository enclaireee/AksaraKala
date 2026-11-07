class_name Npc extends Interactable
## Runs data/dialogue/<npc_id>.tres (quests.md 7). Indicator: gold lontar when a non-fallback entry
## currently passes (new or advancing quest talk), grey otherwise; bobs when gold (7.6). Hub and topic entries
## ("Ask about...", script.md 2) never light it, and hubs and topics never count as the talk (talked_to).

@export var npc_id := ""
@export var cond := ""   # hidden and not interactable while Game.check(cond) is false

var data: DialogueData   # tests may preset this
var _busy := false
var _gold := false
var _t := 0.0


func _ready() -> void:
	verb = "UI_VERB_TALK"
	super()
	if data == null:
		data = DialogueData.by_id(npc_id)
	if data == null:
		push_warning("npc '%s': no dialogue data" % npc_id)
	var ev := get_node("/root/Events")
	for s in [ev.quest_started, ev.quest_updated, ev.quest_completed, ev.talked_to]:
		s.connect(func(_a: Variant = null) -> void: _recompute())
	var game := get_node("/root/Game")
	game.changed.connect(_apply_cond)
	_apply_cond()
	_recompute()


func _apply_cond() -> void:
	var on: bool = get_node("/root/Game").check(cond)
	visible = on
	usable = on and data != null   # dressing NPCs have no dialogue: no Talk prompt
	if not on:
		_prompt.visible = false
	elif _near:
		_refresh_prompt()


func _recompute() -> void:
	_gold = false
	if data:
		var game := get_node("/root/Game")
		for i in data.entries.size() - 1:   # last entry is the fallback
			var en: Dictionary = data.entries[i]
			if en.get("hub", false) or en.has("topic"):
				continue
			if en.get("if", []).all(func(c: String) -> bool: return game.check(c)):
				_gold = true
	queue_redraw()


func _process(delta: float) -> void:
	if _gold:
		_t += delta
		queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-6, -8, 12, 16), Color(0.55, 0.4, 0.3))
	var y := -18.0 + (sin(_t * 5.0) * 2.0 if _gold else 0.0)
	draw_rect(Rect2(-3, y, 6, 4), Color(1.0, 0.82, 0.2) if _gold else Color(0.5, 0.5, 0.5))


func interact() -> void:
	if _busy or data == null:
		return
	var e: Dictionary = get_node("/root/Game").pick_entry(data.entries)   # skips topic entries
	if e.is_empty():
		return
	_busy = true
	var ev := get_node("/root/Events")
	await get_node("/root/Game").play(data.name_key, e, data.entries)   # lines, choices, then the actions (a hub loops its topics)
	_busy = false
	if not (e.get("quiet", false) or e.get("hub", false) or e.has("topic")):   # a quiet entry (a refusal) does not count as the talk
		ev.talked_to.emit(npc_id)
	_recompute()
