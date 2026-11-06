class_name MemorySpot extends Interactable
## A thing to do inside a Kelir memory (architecture.md 9b). "interact": press interact here. "goal": walk in.
## "narrate": walk in, plays its line once, never counts. "gap": a grey gap of a gap memory (KelirMemory spawns
## these from GapMemoryData); interact asks the prompt with 3 choices, the right one runs flag:gap_<gap_id>.
## A spot with `order` >= 0 waits until every lower-order spot is done; out of order it does nothing.

const GAP_SIZE := Vector2(24, 24)   # TUNE
const GAP_GREY := Color("8A8580")

@export_enum("interact", "goal", "narrate", "gap") var action_kind := "interact"
@export var order := -1        # -1 = any order
@export var line_key := ""     # played when done, e.g. MEM_<ID>_3

var done := false
var gap := {}     # {gap_id, pos, prompt_key, options, correct}, kind gap
var wrong := 0    # wrong picks on this gap; from 2 the right option is starred
var _busy := false
var _rect: ColorRect


func _ready() -> void:
	verb = "UI_VERB_USE"
	super()
	usable = action_kind in ["interact", "gap"]
	body_entered.connect(func(b: Node) -> void:
		if action_kind in ["goal", "narrate"] and b.is_in_group("player"):
			interact())
	if not gap.is_empty():
		_rect = ColorRect.new()
		_rect.size = GAP_SIZE
		_rect.position = -GAP_SIZE / 2.0
		_rect.color = GAP_GREY
		_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_rect)
		if get_node("/root/Game").has_flag("gap_" + str(gap.get("gap_id", ""))):
			_rect.visible = false
			done = true
			usable = false


## Counts toward finishing the memory.
func counts() -> bool:
	return action_kind != "narrate"


func interact() -> void:
	var mem := KelirMemory.of(self)
	if done or _busy or mem == null or (order >= 0 and not mem.can_do(order)):
		return
	if action_kind == "goal" and not mem.spots().all(func(s: MemorySpot) -> bool: return s == self or s.done or not s.counts()):
		return   # the goal closes the memory, so it waits for every other counting spot (walk out and back in)
	if action_kind == "gap":
		_busy = true
		var ok: bool = await _ask(mem)
		_busy = false
		if not ok:
			return
	done = true
	usable = false
	_prompt.visible = false
	if line_key != "" and tr(line_key) != line_key:   # generated keys with no text yet stay silent
		await mem.say(PackedStringArray([line_key]))
	if counts():
		mem.spot_done(self)


## One try at this gap. True when the right option was picked (its `do` set flag:gap_<id>).
func _ask(mem: KelirMemory) -> bool:
	var game := get_node("/root/Game")
	var correct := str(gap.get("correct", ""))
	var flag := "gap_" + str(gap.get("gap_id", ""))
	var choices := []
	for o: Variant in gap.get("options", []):
		var k := GapMemoryData.option_key(o)
		var hint := k == correct and wrong >= 2   # ponytail: the faint pulse is a "* " prefix until ui.md draws one
		choices.append({"text": "* " + tr(k) if hint else k, "do": ["flag:" + flag] if k == correct else []})
	await game.play(mem.speaker(), {"lines": [str(gap.get("prompt_key", ""))], "choices": choices})
	if game.has_flag(flag):
		_rect.visible = false   # ponytail: the gap just clears; the filled-in detail art comes with the scene art
		return true
	wrong += 1
	_rect.modulate = Color(1.8, 1.8, 1.8)
	create_tween().tween_property(_rect, "modulate", Color.WHITE, 0.5)
	var a := get_node_or_null("/root/Audio")
	if a and a.has_method("play_sfx"):
		a.play_sfx("sfx_thud")
	return false
