extends Node
## Scene direction (docs/quest_story_ux.md 2). Listens to Events.scene_cue and directs story beats:
## letterbox bars, camera follow (eases the active Camera2D's `offset`, never its position, so PlayerCamera keeps
## working) and shake. StoryBeat calls begin_beat()/end_beat(); while a beat plays the camera follows the speaker.
## Runs with process_mode always (GameUI is). Everything is a silent no-op when there is no camera, player or NPC.

const BAR_H := 28.0        # TUNE: letterbox bar height in the 480x270 screen
const BAR_TIME := 0.4      # TUNE: slide in/out seconds
const FOLLOW := 6.0        # TUNE: camera ease rate (1/s)
const SHAKE_TIME := 0.6    # TUNE: seconds a #shake takes to die out
const SCREEN := Vector2(480, 270)

var _beat := false
var _bars := false
var _layer: CanvasLayer
var _top: ColorRect
var _bottom: ColorRect
var _tween: Tween
var _cam: Camera2D
var _target: Node2D
var _off := Vector2.ZERO
var _shake_amp := 0.0
var _shake_left := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_layer = CanvasLayer.new()
	var parent := get_parent() as CanvasLayer
	_layer.layer = parent.layer - 1 if parent != null else 50   # under the dialogue box
	add_child(_layer)
	_top = _bar(-BAR_H)
	_bottom = _bar(SCREEN.y)
	var ev := get_node("/root/Events")
	ev.scene_cue.connect(_on_cue)
	ev.dialogue_finished.connect(_on_dialogue_finished)
	ev.zone_entered.connect(func(_z: String) -> void: release_camera(true))
	var box := get_tree().get_first_node_in_group("dialogue_box")
	if box != null and box.has_signal("speaker_changed"):
		box.speaker_changed.connect(focus_speaker)


func _bar(y: float) -> ColorRect:
	var r := ColorRect.new()
	r.color = Color.BLACK
	r.position = Vector2(0, y)
	r.size = Vector2(SCREEN.x, BAR_H)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(r)
	return r


## A beat starts: bars slide in.
func begin_beat() -> void:
	_beat = true
	set_bars(true)


## The beat is over: bars slide out and the camera is released.
func end_beat() -> void:
	_beat = false
	set_bars(false)
	release_camera()


func bars_on() -> bool:
	return _bars


func set_bars(on: bool) -> void:
	_bars = on
	if _tween:
		_tween.kill()
	_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true)
	_tween.tween_property(_top, "position:y", 0.0 if on else -BAR_H, BAR_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_bottom, "position:y", SCREEN.y - BAR_H if on else SCREEN.y, BAR_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## Auto-direction: an `NPC_<ID>_NAME` speaker key sends the camera to that NPC; any other key (hero, narration) back.
## Only while a beat plays (a normal NPC talk keeps the plain box).
func focus_speaker(name_key: String) -> void:
	if not _beat:
		return
	if name_key == "NPC_HERO_NAME":   # the hero speaks: back to the hero
		_target = null
		return
	if name_key.begins_with("NPC_") and name_key.ends_with("_NAME"):
		var n := find_node_by_id(name_key.trim_prefix("NPC_").trim_suffix("_NAME").to_lower())
		if n != null:
			_target = n
			return
		if _target != null:
			return   # unknown NPC in this zone: stay where we are
	_target = null


## The Node2D matching id (npc_id / id / name, like the HUD arrow), or null.
func find_node_by_id(id: String) -> Node2D:
	if id == "" or id == "hero" or not is_inside_tree():
		return null
	for c in get_tree().root.find_children("*", "Node2D", true, false):
		var n := c as Node2D
		if n == null or n is Camera2D:
			continue
		if id in [n.get("npc_id"), n.get("id"), n.name]:
			return n
	return null


## Stops following; the offset eases back to 0. `instant` snaps (zone change).
func release_camera(instant := false) -> void:
	_target = null
	if instant:
		_shake_left = 0.0
		_off = Vector2.ZERO
		if is_instance_valid(_cam):
			_cam.offset = Vector2.ZERO


func _on_cue(cue: String, arg: String) -> void:
	match cue:
		"cam":
			_target = find_node_by_id(arg.to_lower())   # hero or unknown: back to the hero
		"bars":
			set_bars(arg == "on")
		"shake":
			_shake_amp = clampf(arg.to_float(), 0.0, 3.0)
			_shake_left = SHAKE_TIME if _shake_amp > 0.0 else 0.0


func _on_dialogue_finished() -> void:
	if _beat:
		return
	# cues used in a normal talk: nothing may stay displaced or letterboxed
	release_camera()
	if _bars:
		set_bars(false)


func _process(delta: float) -> void:
	if _target != null and (not is_instance_valid(_target) or not _target.is_inside_tree()):
		_target = null
	if _target == null and _off == Vector2.ZERO and _shake_left <= 0.0:
		return
	var cam: Camera2D = get_viewport().get_camera_2d() if is_inside_tree() else null
	if cam != _cam:
		if is_instance_valid(_cam):
			_cam.offset = Vector2.ZERO
		_cam = cam
		_off = Vector2.ZERO
	if cam == null:
		return
	var want := Vector2.ZERO
	if _target != null:
		want = _target.global_position - cam.global_position
	_off = _off.lerp(want, 1.0 - exp(-FOLLOW * delta))
	if _target == null and _off.length() < 0.5:
		_off = Vector2.ZERO
	var shake := Vector2.ZERO
	if _shake_left > 0.0:
		_shake_left = maxf(0.0, _shake_left - delta)
		var k := _shake_amp * _shake_left / SHAKE_TIME
		shake = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * k
	cam.offset = (_off + shake).round()
