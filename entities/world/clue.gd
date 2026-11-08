class_name Clue extends Interactable
## Examinable clue (architecture.md 9b). Plays the hero's thought, then runs `clue:<id>` (flag clue_<id>,
## Events.clue_examined) and, if memory_id is set and flag memory_<memory_id> is not, enters that Kelir memory.
## Examined clues stay examinable: lines replay, the signal fires again, the flag is already set.

@export var clue_id := ""                   # zone docs pass `clue_id`; lontar_shimmer.gd reads it and `memory_id`
@export var hunt_id := ""                   # optional hunt/investigation group id (quests.md 7.1)
@export var lines := PackedStringArray()    # empty: CLUE_<ID>_1 and _2, those that exist
@export var journal_key := ""               # CLUE_<ID>_NOTE (journal reads it)
@export var memory_id := ""
@export var cond := ""                      # hidden and not usable while Game.check(cond) is false, as npc.gd

var _busy := false


func _ready() -> void:
	verb = "UI_VERB_EXAMINE"
	super()
	var game := get_node("/root/Game")
	game.changed.connect(_apply_cond)
	_apply_cond()


func _apply_cond() -> void:
	var on: bool = get_node("/root/Game").check(cond)
	visible = on
	usable = on and not _busy
	if not usable:
		_prompt.visible = false
	elif _near:
		_refresh_prompt()


func _draw() -> void:
	var art := StoryArt.tex(clue_id)
	if art != null:
		StoryArt.draw_standing(self, art)
		return
	draw_rect(Rect2(-5, -4, 10, 8), Color(0.09, 0.07, 0.16))
	draw_rect(Rect2(-4, -3, 8, 6), Color("E6D299"))
	draw_rect(Rect2(-4, -3, 8, 1), Color("F6E8BE"))
	draw_rect(Rect2(-1, -3, 2, 6), Color("B8353A"))
	draw_rect(Rect2(-3, -1, 6, 1), Color("8A6A44"))


func interact() -> void:
	if _busy:
		return
	_busy = true
	_apply_cond()
	var game := get_node("/root/Game")
	await game.play("NPC_HERO_NAME", {"lines": _lines(), "do": ["clue:" + clue_id]})
	_busy = false
	_apply_cond()
	if memory_id != "" and not game.has_flag("memory_" + memory_id):
		get_node("/root/Zones").enter_memory(memory_id)


func _lines() -> PackedStringArray:
	if not lines.is_empty():
		return lines
	var up := clue_id.to_upper()
	var out := PackedStringArray()
	for k in ["CLUE_%s_1" % up, "CLUE_%s_2" % up]:
		if tr(k) != k:
			out.append(k)
	if out.is_empty() and memory_id == "":
		out.append("CLUE_%s_1" % up)   # a missing key shows itself; a memory clue with no thought just pulls you in
	return out
