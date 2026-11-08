class_name LontarShimmer extends Node2D
## Belt lontar glow when an unexamined clue is within SHIMMER_RANGE (architecture.md 9b, ui.md 3).
## Clue duck-typing (entities/world/clue.gd may not exist yet): in group "interactable" with `id` and `memory_id`.

const SHIMMER_RANGE := 48.0
const MOTES := 6
const GOLD := Color("F6E7A8")

var strength := 0.0   # 0 = off, else 1 - dist/48 of the nearest unexamined clue
var _chimed := {}
var _t := 0.0
var _motes: Array[ColorRect] = []


func _ready() -> void:
	position = Vector2(3, -5)   # belt
	for i in MOTES:
		var m := ColorRect.new()
		m.size = Vector2.ONE
		m.color = GOLD
		m.visible = false
		m.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(m)
		_motes.append(m)
	var tm := Timer.new()
	tm.wait_time = 0.25
	tm.timeout.connect(poll)
	add_child(tm)
	tm.start()


func suppressed() -> bool:
	var box := get_tree().get_first_node_in_group("dialogue_box")
	if box and box.is_open():
		return true
	var p := get_parent()
	if p and p.get("cast") and p.cast.drawing:
		return true
	var sc := get_tree().current_scene
	return sc != null and sc.get_script() != null and sc.get_script().resource_path.begins_with("res://zones/kelir/")


func poll() -> void:
	strength = 0.0
	if suppressed():
		return
	var g := get_node("/root/Game")
	for n in get_tree().get_nodes_in_group("interactable"):
		if not (n is Node2D) or n.get("clue_id") == null or n.get("memory_id") == null:
			continue
		var cid := str(n.clue_id)
		if g.has_flag("clue_" + cid):
			continue
		var s := 1.0 - global_position.distance_to(n.global_position) / SHIMMER_RANGE
		if s <= 0.0:
			continue
		strength = maxf(strength, s)
		if not _chimed.has(cid):
			_chimed[cid] = true
			var a := get_node_or_null("/root/Audio")
			if a and a.has_method("play_sfx"):   # ponytail: Audio is empty today; sfx_lontar when it grows play_sfx
				a.play_sfx("sfx_lontar")


func _process(delta: float) -> void:
	_t += delta
	for i in MOTES:
		var m := _motes[i]
		m.visible = strength > 0.0
		if m.visible:
			var ph := fposmod(_t * 0.8 + i / float(MOTES), 1.0)
			m.position = Vector2(i % 3 - 1, -ph * 8.0)
			m.modulate.a = strength * (1.0 - ph) * (0.6 + 0.4 * randf())
