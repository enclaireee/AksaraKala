extends Node
## Scene direction (docs/quest_story_ux.md 2). Listens to Events.scene_cue and directs story beats:
## letterbox bars, camera follow (eases the active Camera2D's `offset`, never its position, so PlayerCamera keeps
## working) and shake. StoryBeat calls begin_beat()/end_beat(); while a beat plays the camera follows the speaker.
## Runs with process_mode always (GameUI is). Everything is a silent no-op when there is no camera, player or NPC.

const BAR_H := 28.0        # TUNE: letterbox bar height in the 480x270 screen
const BAR_TIME := 0.4      # TUNE: slide in/out seconds
const FOLLOW := 6.0        # TUNE: camera ease rate (1/s)
const SHAKE_TIME := 0.6    # TUNE: seconds a #shake takes to die out
const MAX_SPEAKER_DIST := 160.0   # TUNE: auto-follow only speakers in the local scene around the hero
const MAX_PAN := 80.0      # TUNE: max camera offset (px) so the scene stays framed near the hero
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
var _standins := {}   # id -> Sprite2D shown beside the hero for this beat
var _wide := {}       # id -> far boss / set piece the camera may travel to this beat
const STANDIN_AS := {"hunter": "nameless_hunter", "wiryo": "kidul_jurukunci"}   # speaker id -> npc id whose sheet row it wears
const STANDIN_SPOTS := [Vector2(28, 0), Vector2(-28, 0), Vector2(0, -28), Vector2(44, -20), Vector2(-44, -20)]


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
	ev.zone_entered.connect(func(_z: String) -> void:
		release_camera(true)
		_drop_cast())
	var box := get_tree().get_first_node_in_group("dialogue_box")
	if box != null and box.has_signal("speaker_changed"):
		box.speaker_changed.connect(focus_speaker)
	ev.dialogue_requested.connect(_stage)
	if OS.has_environment("BEAT_AUDIT"):   # cutscene audit (tests/cutscene_test.gd)
		ev.dialogue_requested.connect(_audit_talk)


func _bar(y: float) -> ColorRect:
	var r := ColorRect.new()
	r.color = Color.BLACK
	r.position = Vector2(0, y)
	r.size = Vector2(SCREEN.x, BAR_H)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(r)
	return r


## Off-screen voices the audit accepts: "<id>|<first line key prefix>". Laras speaks through the lontar (LC*, BEAT_LARAS_*),
## Semar narrates the Kelir memories (MEM_*).
## Semar calls up the stair in wards_down; the Queen of the South is "a voice without a face" (kidul_trial).
const AUDIT_VOICES := ["laras|LC", "laras|BEAT_LARAS_", "semar|MEM_", "semar|BEAT_WARDS_DOWN", "ratu_kidul|BEAT_KIDUL_TRIAL"]


## BEAT_AUDIT=1: when a talk opens, prints every speaker and #cam target in it that is not in the scene within
## MAX_SPEAKER_DIST of the hero: BEATAUDIT|zone|beat/talk|first line key|speaker/cam|id|absent/far N.
func _audit_talk(who: String, lines: PackedStringArray) -> void:
	var first := ""
	for l in lines:
		if not l.begins_with("@") and not l.begins_with("#"):
			first = l
			break
	var seen := {}
	for c in _cast(who, lines):
		var kind: String = c[0]
		var id: String = c[1]
		if seen.has(kind + id) or _wide.has(id) or AUDIT_VOICES.any(func(v: String) -> bool: return v.get_slice("|", 0) == id and first.begins_with(v.get_slice("|", 1))):
			continue
		seen[kind + id] = true
		var n := find_node_by_id(id)
		var pl := get_tree().get_first_node_in_group("player") as Node2D
		var d := -1.0 if n == null or pl == null else n.global_position.distance_to(pl.global_position)
		if n == null and id == "semar":   # Semar off stage is a voice
			continue
		if n == null or d > MAX_SPEAKER_DIST:
			var z = get_node("/root/Zones").get("current_zone") if get_node_or_null("/root/Zones") != null else ""
			print("BEATAUDIT|%s|%s|%s|%s|%s|%s" % [z, "beat" if _beat else "talk", first, kind, id, "absent" if n == null else "far %d" % int(d)])


## Ids a beat line names: [kind, id] for each `@NPC_<ID>_NAME` speaker and `#cam:<id>` target (hero excluded).
func _cast(who: String, lines: PackedStringArray) -> Array:
	var out := []
	for l in PackedStringArray(["@" + who]) + lines:
		if l.begins_with("@NPC_") and l.ends_with("_NAME") and l != "@NPC_HERO_NAME":
			out.append(["speaker", l.trim_prefix("@NPC_").trim_suffix("_NAME").to_lower()])
		elif l.begins_with("#cam:") and l != "#cam:hero":
			out.append(["cam", l.trim_prefix("#cam:").to_lower()])
	return out


## A beat names someone who is not in frame: an NPC who is absent or far gets a stand-in sprite beside the hero until the
## beat ends; a far boss or set piece is let through so the camera travels to it. Semar, when absent, stays a voice.
## ponytail: fixed offsets around the hero, no wall check. Place the NPC in the zone doc if a stand-in lands badly.
func _stage(who: String, lines: PackedStringArray) -> void:
	var pl := get_tree().get_first_node_in_group("player") as Node2D if is_inside_tree() else null
	if not _beat or pl == null:
		return
	for c in _cast(who, lines):
		var id: String = c[1]
		if id == "semar" or (_standins.has(id) and is_instance_valid(_standins[id])) or _wide.has(id):
			continue
		var n := find_node_by_id(id)
		if n != null and n.global_position.distance_to(pl.global_position) <= MAX_SPEAKER_DIST:
			continue
		if n != null and not n is Npc:
			_wide[id] = n
			continue
		var probe := Npc.new()
		probe.npc_id = STANDIN_AS.get(id, n.npc_id if n != null else id)
		var row := probe._row()
		probe.free()
		var sp := Sprite2D.new()
		sp.name = id
		sp.texture = Npc.SHEET
		sp.region_enabled = true
		sp.region_rect = Rect2(0, row * 24, 16, 24)
		sp.offset = Vector2(0, -12)
		pl.get_parent().add_child(sp)
		sp.global_position = pl.global_position + STANDIN_SPOTS[_standins.size() % STANDIN_SPOTS.size()]
		_standins[id] = sp
	# the box announced the opening speaker before this ran: aim the camera again now the cast is on stage
	var opener := who
	for l in lines:
		if not l.begins_with("#"):
			if l.begins_with("@"):
				opener = l.trim_prefix("@")
			break
	if opener != "":
		focus_speaker(opener)


## Frees the stand-ins and forgets the far targets (beat over, or the zone changed under a running beat).
func _drop_cast() -> void:
	for sp in _standins.values():
		if is_instance_valid(sp):
			sp.free()
	_standins.clear()
	_wide.clear()


## A beat starts: bars slide in.
func begin_beat() -> void:
	_beat = true
	set_bars(true)


## The beat is over: bars slide out and the camera is released.
func end_beat() -> void:
	_beat = false
	set_bars(false)
	release_camera()
	_drop_cast()


func bars_on() -> bool:
	return _bars


func set_bars(on: bool) -> void:
	_bars = on
	if _tween:
		_tween.kill()
	_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true)
	_tween.tween_property(_top, "position:y", 0.0 if on else -BAR_H, BAR_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_bottom, "position:y", SCREEN.y - BAR_H if on else SCREEN.y, BAR_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## Auto-direction: an `NPC_<ID>_NAME` speaker key sends the camera to that NPC if nearby; any other key (hero, narration, distant voice) back.
## Only while a beat plays (a normal NPC talk keeps the plain box).
func focus_speaker(name_key: String) -> void:
	if not _beat:
		return
	if name_key == "NPC_HERO_NAME":   # the hero speaks: back to the hero
		_target = null
		return
	if name_key.begins_with("NPC_") and name_key.ends_with("_NAME"):
		var n := find_node_by_id(name_key.trim_prefix("NPC_").trim_suffix("_NAME").to_lower())
		var pl := get_tree().get_first_node_in_group("player") as Node2D if is_inside_tree() else null
		if n != null and (pl == null or _wide.values().has(n) or n.global_position.distance_to(pl.global_position) <= MAX_SPEAKER_DIST):
			_target = n
			return
	_target = null


## The visible, active Node2D matching id (npc_id / id / name, or npc_id prefix like laras_tag) nearest the player, or null.
func find_node_by_id(id: String) -> Node2D:
	if id == "" or id == "hero" or not is_inside_tree():
		return null
	var game := get_node_or_null("/root/Game")
	var pl := get_tree().get_first_node_in_group("player") as Node2D
	var best: Node2D = null
	var best_rank := 99
	var best_dist := INF
	for c in get_tree().root.find_children("*", "Node2D", true, false):
		var n := c as Node2D
		if n == null or n is Camera2D or not n.is_visible_in_tree():
			continue
		if "cond" in n and str(n.cond) != "" and game != null and not game.check(str(n.cond)):
			continue
		var dd = n.get("data")   # an NPC whose dialogue speaks under another name key (kidul_jurukunci is NPC_WIRYO_NAME)
		var exact: bool = id in [n.get("npc_id"), n.get("id"), n.get("trigger_id"), n.get("area_id"), n.get("clue_id"), n.get("memory_id"), n.get("unique_id"), n.name] \
				or (dd is DialogueData and dd.name_key == "NPC_%s_NAME" % id.to_upper()) \
				or (n.get("unique_id") != null and n.scene_file_path.get_file().get_basename() == id)   # a boss placed by scene file only
		var prefix: bool = not exact and str(n.get("npc_id")).begins_with(id + "_")
		var contains_id: bool = not exact and not prefix and (id.length() >= 4 and id in str(n.get("npc_id")))
		if not exact and not prefix and not contains_id:
			continue
		var rank := 0 if exact else (1 if prefix else 2)
		var dist := pl.global_position.distance_squared_to(n.global_position) if pl != null else 0.0
		if rank < best_rank or (rank == best_rank and dist < best_dist):
			best = n
			best_rank = rank
			best_dist = dist
	return best


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
	if _target != null and (not is_instance_valid(_target) or not _target.is_inside_tree() or not _target.is_visible_in_tree()):
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
		if not _wide.values().has(_target):
			want = want.limit_length(MAX_PAN)
	_off = _off.lerp(want, 1.0 - exp(-FOLLOW * delta))
	if _target == null and _off.length() < 0.5:
		_off = Vector2.ZERO
	var shake := Vector2.ZERO
	if _shake_left > 0.0:
		_shake_left = maxf(0.0, _shake_left - delta)
		var k := _shake_amp * _shake_left / SHAKE_TIME
		shake = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * k
	cam.offset = (_off + shake).round()
