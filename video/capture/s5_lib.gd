extends "res://video/capture/shot.gd"
## Segment 5 helpers (boss / class / feature shots). Shots extend this file instead of shot.gd.

func boss() -> Node2D:
	return get_tree().get_first_node_in_group("boss") as Node2D


func boss_stage() -> Node:
	return get_tree().get_first_node_in_group("boss_stage")


## Prints a one-line state of the boss (dev).
func boss_log(tag := "") -> void:
	var b := boss()
	if b == null:
		print("s5: ", tag, " no boss")
		return
	var hp: Variant = b.get("health")
	print("s5: %s f=%d boss=%s pos=%s hero=%s hp=%s engaged=%s state=%s move=%s phase=%s" % [tag, frame, b.name,
		b.global_position, hero().global_position, (hp.hp if hp else "?"), b.get("engaged"), b.get("state"),
		b.get("_move"), b.get("phase")])


## Logs the boss state every `every` seconds for `seconds` (dev, while the fight runs).
func watch_boss(seconds: float, every := 0.5) -> void:
	var n := roundi(seconds / every)
	for i in n:
		boss_log("t%.1f" % (i * every))
		await wait_seconds(every)


## Keeps the hero `dist` px from the boss on the side `dir`, strafing (real input) while the shot waits.
func kite(seconds: float, dist := 90.0, speed := 0.8) -> void:
	var n := roundi(seconds * FPS)
	for i in n:
		var b := boss()
		if b == null:
			break
		var d: Vector2 = hero().global_position - b.global_position
		var want := b.global_position + d.normalized() * dist
		var to := want - hero().global_position
		if to.length() > 6.0:
			hold_move(to.normalized() * speed)
		else:
			stop()
		await get_tree().process_frame
	stop()


# ---- pair framing: the shot camera on a weighted point between the hero and a second node ----
class _Mid extends Node2D:
	var a: Node2D
	var b: Node2D
	var w := 0.5            # 0 = on a, 1 = on b
	var bias := Vector2.ZERO
	func _process(_d: float) -> void:
		if is_instance_valid(a) and is_instance_valid(b):
			global_position = a.global_position.lerp(b.global_position, w) + bias
		elif is_instance_valid(a):
			global_position = a.global_position + bias

var mid: _Mid

## The shot camera frames the hero and `other` (weight w toward other), trailing by `lerp`.
func frame_pair(other: Node2D, w := 0.5, bias := Vector2.ZERO, lerp := 0.12) -> void:
	if mid == null or not is_instance_valid(mid):
		mid = _Mid.new()
		mid.process_priority = 900
		mid.process_mode = Node.PROCESS_MODE_ALWAYS
		zone().add_child(mid)
	mid.a = hero()
	mid.b = other
	mid.w = w
	mid.bias = bias
	mid._process(0)
	if _cam == null or not is_instance_valid(_cam):
		cam_detach(mid.global_position)
	cam_follow(mid, Vector2.ZERO, lerp)


func node_at(group: String, script_name := "") -> Array:
	var out := []
	for n in get_tree().get_nodes_in_group(group):
		if script_name == "" or (n.get_script() and String(n.get_script().resource_path).contains(script_name)):
			out.append(n)
	return out


## The boss stage's gimmick reminder line (some are cut off with an ellipsis): hidden for the shot.
func hide_boss_hint() -> void:
	var st := boss_stage()
	if st and st.get("_hint_bg"):
		st._hint_bg.visible = false


## Casts with the shot camera held still (a moving camera bends the stroke and the recogniser misreads it).
func cast_still(glyph: String, o := {}) -> Dictionary:
	var keep: Node2D = _cam_follow
	_cam_follow = null
	var r := await cast_glyph(glyph, o)
	if keep and is_instance_valid(keep):
		_cam_follow = keep
	return r


## A real key press (physical keycode), as the menu reads Q/E/Esc.
func key(code: Key) -> void:
	var e := InputEventKey.new()
	e.physical_keycode = code
	e.keycode = code
	e.pressed = true
	Input.parse_input_event(e)
	await wait_frames(2)
	var u := e.duplicate()
	u.pressed = false
	Input.parse_input_event(u)
	await wait_frames(1)


## Every codex entry unlocked (the Codex tab lists them all).
func unlock_codex() -> void:
	for f in DirAccess.get_files_at(CodexEntry.dir):
		var id := f.trim_suffix(".remap").trim_suffix(".tres")
		if f.contains(".tres") and id not in G.codex:
			G.codex.append(id)
