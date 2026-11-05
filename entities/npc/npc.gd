class_name Npc extends Interactable
## Runs data/dialogue/<npc_id>.tres (quests.md 7). Indicator: gold lontar when a non-fallback entry
## currently passes (new or advancing quest talk), grey otherwise; bobs when gold (7.6).

@export var npc_id := ""

var data: DialogueData   # tests may preset this
var _busy := false
var _gold := false
var _t := 0.0


func _ready() -> void:
	super()
	if data == null:
		data = DialogueData.by_id(npc_id)
	if data == null:
		push_warning("npc '%s': no dialogue data" % npc_id)
	var ev := get_node("/root/Events")
	for s in [ev.quest_started, ev.quest_updated, ev.quest_completed, ev.talked_to]:
		s.connect(func(_a: Variant = null) -> void: _recompute())
	_recompute()


func _recompute() -> void:
	_gold = false
	if data:
		var game := get_node("/root/Game")
		for i in data.entries.size() - 1:   # last entry is the fallback
			if data.entries[i].get("if", []).all(func(c: String) -> bool: return game.check(c)):
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
	var e := data.pick(get_node("/root/Game"))
	if e.is_empty():
		return
	_busy = true
	var ev := get_node("/root/Events")
	ev.dialogue_requested.emit(data.name_key, PackedStringArray(e.get("lines", [])))
	await ev.dialogue_finished
	for a: String in e.get("do", []):
		get_node("/root/Game").run(a)
	_busy = false
	ev.talked_to.emit(npc_id)
	_recompute()
