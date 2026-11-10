class_name MemorySpot extends Interactable
## A thing to do inside a Kelir memory (architecture.md 9b). "interact": press interact here. "goal": walk in.
## "narrate": walk in, plays its line once, never counts. "gap": a grey gap of a gap memory (KelirMemory spawns
## these from GapMemoryData); interact asks the prompt with 3 choices, the right one runs flag:gap_<gap_id>.
## A spot with `order` >= 0 waits until every lower-order spot is done; out of order it does nothing.

const GAP_SIZE := Vector2(24, 24)   # TUNE
const GAP_GREY := Color("8A8580")

@export_enum("interact", "goal", "narrate", "gap") var action_kind := "interact"
@export var order := -1        # -1 = any order
@export var line_key := ""     # played when done, e.g. MEM_<ID>_3 (a Laras chapter falls back to LC<n>_<i>)
var line_keys := PackedStringArray()   # extra lines KelirMemory hands out (the chapters)

var done := false
var gap := {}     # {gap_id, pos, prompt_key, options, correct}, kind gap
var wrong := 0    # wrong picks on this gap; from 2 the right option is starred
var _busy := false
var _gate: Sprite2D
var _rect: Sprite2D   # the torn-cloth gap, or the goal gate
var _prop: Sprite2D   # what you act on: a blencong stand (default), an oncor (K1) or a curse stake (K5); K0 draws its own
var _prop_kind := ""
var _ring: Sprite2D   # the pulsing hint ring over a spot that still wants you
var _t := 0.0


func _ready() -> void:
	verb = "UI_VERB_USE"
	super()
	usable = action_kind in ["interact", "gap"]
	body_entered.connect(func(b: Node) -> void:
		if action_kind in ["goal", "narrate"] and b.is_in_group("player"):
			interact())
	if action_kind == "interact":
		_make_prop()
	if action_kind == "goal":
		_gate = Sprite2D.new()
		_gate.texture = load("res://assets/art/cutscene/goal_gate.png")
		_gate.region_enabled = true
		_gate.region_rect = Rect2(0, 0, 20, 30)
		_gate.offset = Vector2(0, -8)
		add_child(_gate)
	if not gap.is_empty():
		_rect = Sprite2D.new()
		_rect.texture = load("res://assets/art/cutscene/gap_tear.png")
		_rect.region_enabled = true
		_rect.region_rect = Rect2(0, 0, 24, 20)
		add_child(_rect)
		if get_node("/root/Game").has_flag("gap_" + str(gap.get("gap_id", ""))):
			_rect.visible = false
			done = true
			usable = false


## The thing you act on, so a spot reads as a place and not an invisible dot.
func _make_prop() -> void:
	var mem := KelirMemory.of(self)
	var id: String = mem.memory_id if mem != null and mem.memory_id != "" else str(get_node("/root/Zones").memory_id)
	if id == "k0_ruwatan":
		return
	_prop_kind = {"k1_maghrib": "oncor", "k5_forge": "stake"}.get(id, "lamp")
	_prop = Sprite2D.new()
	_prop.centered = false
	match _prop_kind:
		"oncor":
			_prop.texture = load("res://assets/art/props/oncor.png")
			_prop.hframes = 4
			_prop.offset = Vector2(-8, -25)
		"stake":
			_prop.texture = load("res://assets/art/props/curse_stake.png")
			_prop.hframes = 3
			_prop.offset = Vector2(-6, -15)
			_prop.frame = 2
		_:
			_prop.texture = load("res://assets/art/cutscene/lamp_stand.png")
			_prop.hframes = 4
			_prop.offset = Vector2(-7, -10)
	_prop.z_index = 1
	add_child(_prop)
	_ring = Sprite2D.new()
	_ring.texture = load("res://assets/art/cutscene/lamp_hint.png")
	_ring.hframes = 4
	_ring.offset = Vector2(0, -6)
	_ring.z_index = 2
	add_child(_ring)


func _animate_prop() -> void:
	var lit := done
	match _prop_kind:
		"oncor", "lamp":
			_prop.frame = (1 + int(_t * 9.0 + position.x) % 3) if lit else 0
		"stake":
			_prop.frame = 0 if lit else 2
	_ring.visible = not lit and usable
	if _ring.visible:
		_ring.frame = int(_t * 6.0) % 4


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
	var ks := PackedStringArray()
	var rk := mem.resolve(line_key)   # generated keys with no text stay silent
	if rk != "":
		ks.append(rk)
	ks.append_array(line_keys)
	if not ks.is_empty():
		await mem.say(ks)
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
		_rect.visible = false
		return true
	wrong += 1
	_rect.modulate = Color(1.8, 1.8, 1.8)
	create_tween().tween_property(_rect, "modulate", Color.WHITE, 0.5)
	var a := get_node_or_null("/root/Audio")
	if a and a.has_method("play_sfx"):
		a.play_sfx("sfx_thud")
	return false


func _process(delta: float) -> void:
	_t += delta
	if _prop != null:
		_animate_prop()
	if _rect and _rect.visible:   # the gap's frayed edge shimmers
		_rect.region_rect = Rect2(24 * (int(Time.get_ticks_msec() / 350.0) % 2), 0, 24, 20)
	if _gate:   # the gate opens once every other counting spot is done
		var mem := KelirMemory.of(self)
		var open_ := mem != null and mem.spots().all(func(s: MemorySpot) -> bool: return s == self or s.done or not s.counts())
		_gate.region_rect = Rect2(20 if open_ else 0, 0, 20, 30)
		if open_ and not done and not _busy and has_overlapping_bodies():
			for b in get_overlapping_bodies():
				if b.is_in_group("player"):
					interact()
					break
