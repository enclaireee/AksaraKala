extends Control
## Dialogue box (ui.md 2, quests.md 7.7). Listens to Events.dialogue_requested(speaker_key, lines),
## types each line out, `interact`, Enter or left click completes the line or advances, then emits dialogue_finished.
## Pauses the tree while open and restores the previous pause state.
## A line "@KEY" is not shown: it sets the speaker tag for the lines after it. Events.dialogue_choices (sent just
## before the request) lists 2-3 choices under the last line: move_up/move_down move, interact picks, cancel does
## nothing; Events.dialogue_picked(index) then dialogue_finished. All text goes through tr() then Game.fmt().
## A line "#name" or "#name:arg" is a scene cue (quest_story_ux.md 2): not shown, emitted as Events.scene_cue(name, arg).
## "#wait:<seconds>" holds the box on a silent beat (max 3 s, real time) before the next line.
## "#face:<mood>" (happy/angry/sad/neutral) swaps the speaker's portrait until the speaker changes (ui.md 3.1);
## the same tag inside a line's text is stripped from the shown text and applies from that line on.

signal speaker_changed(key: String)   # the speaker tag was set (SceneDirector auto-camera)

const CPS := 45.0   # TUNE: characters per second
const OUTLINE := Color("140E0A")
const UI_DIR := "res://assets/art/ui/"
const BOX_X := 40.0       # frame left and width (centred in 480)
const BOX_W := 400.0
const BOX_BOTTOM := 262.0 # frame bottom edge (8 px screen margin): the box grows upward from here
const PAD_X := 10.0       # text inset when there is no face
const PAD_TOP := 7.0      # frame top to the name row
const NAME_ROW := 12.0    # name row height (9 px caps line + 3 px gap) above the text
const PAD_BOT := 13.0     # room for the continue mark under the text
const MIN_H := 40.0
const LINE_H := 10.0      # Tiny5 8: 9 px line + 1 px spacing (ui.md 1)
const FACE_W := 70.0      # 6 px inset + 56 px frame + 8 px gap: the text column starts here
const MIN_H_FACE := 68.0  # the 56 px frame plus 6 px above and below
const TEXT_COL := Color("EADFC4")
const NARR_COL := Color("C9B48A")   # Semar (Dalang) narration: warm dim gold, set apart from speech
const DIM_SHADER := preload("res://ui/fx/focus_dim.gdshader")
const MAX_WAIT := 3.0   # seconds a #wait cue may hold
const PORTRAIT := 48.0    # bust size inside the 56x56 frame_portrait (ui.md 3.1)
const PORTRAIT_INSET := 4.0

var _lines := PackedStringArray()
var _i := 0
var _shown := 0.0
var _was_paused := false
var _opened_frame := -1
var _open := false
var _speaker: Label
var _text: Label
var _cue: TextureRect   # gold ▼ once the line is fully shown
var _plate: NinePatchRect   # gold name plate over the top edge
var _sel_bar: ColorRect
var _lozenge: TextureRect
var _frame: NinePatchRect
var _hint: Label   # "[E] Continue" until the first advance of a save
var _tween: Tween
var _choices := PackedStringArray()   # for the next request
var _opts := PackedStringArray()      # for the open box
var _choosing := false
var _sel := 0
var _list: Label
var _who: Label   # name tag (ui.md 3)
var _hold_until := 0   # Time.get_ticks_msec() when a #wait ends, 0 = not holding
var _portrait_frame: TextureRect   # the speaker's face above the box's left corner (ui.md 3.1)
var _portrait: TextureRect
var _speaker_key := ""
var _mood := ""   # current #face mood, "" = neutral
var _fresh := {}   # npc ids whose tag is up for this first talk
var _dim: ColorRect   # lit spot on the speaker, dimmed world around it
var _dim_mat: ShaderMaterial
var _focus: Node2D
var _dim_center := Vector2(240, 110)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	add_to_group("dialogue_box")
	_dim = ColorRect.new()
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim.size = Vector2(480, 270)
	_dim_mat = ShaderMaterial.new()
	_dim_mat.shader = DIM_SHADER
	_dim.material = _dim_mat
	_dim.z_index = -2   # under the frame (z -1)
	add_child(_dim)
	_frame = _nine("ink_panel", Rect2(BOX_X, BOX_BOTTOM - MIN_H, BOX_W, MIN_H), 4)
	_plate = NinePatchRect.new()   # the name row: no art of its own, it only holds the caps name (ui.md 3.1)
	_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plate.size = Vector2(60, 9)
	add_child(_plate)
	_speaker = UIFx.text("", "label", UIFx.ACCENT)
	_speaker.size = Vector2(60, 9)
	_plate.add_child(_speaker)
	_who = UIFx.text("", "body", UIFx.DIM)   # first meeting: "Anak Semar. Riuh." beside the name
	_who.size = Vector2(240, 9)
	add_child(_who)
	_text = UIFx.text("", "body", TEXT_COL)
	_text.size = Vector2(BOX_W - PAD_X * 2.0, LINE_H)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_text.add_theme_constant_override("line_spacing", 1)
	add_child(_text)
	_sel_bar = ColorRect.new()
	_sel_bar.color = Color(UIFx.ACCENT, 0.14)   # soft gold wash under the chosen line
	_sel_bar.size = Vector2(BOX_W - PAD_X * 2.0, LINE_H)
	_sel_bar.visible = false
	_sel_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sel_bar)
	_lozenge = TextureRect.new()
	_lozenge.texture = load(UI_DIR + "ink_cursor.png")
	_lozenge.visible = false
	_lozenge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_lozenge)
	_list = UIFx.text("", "body", TEXT_COL)
	_list.size = Vector2(BOX_W - PAD_X * 2.0 - 10.0, 30)
	_list.add_theme_constant_override("line_spacing", 1)
	add_child(_list)
	_cue = TextureRect.new()
	_cue.texture = load(UI_DIR + "continue_arrow.png")
	_cue.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cue)
	_hint = UIFx.text("", "body", UIFx.DIM)
	_hint.size = Vector2(120, 9)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_hint)
	_frame.z_index = -1
	_portrait = TextureRect.new()
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait.size = Vector2(PORTRAIT, PORTRAIT)
	add_child(_portrait)
	_portrait_frame = TextureRect.new()
	_portrait_frame.texture = load(UI_DIR + "frame_portrait.png")
	_portrait_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_portrait_frame)
	_layout()
	var ev := get_node("/root/Events")
	ev.dialogue_requested.connect(_on_requested)
	ev.dialogue_choices.connect(func(keys: PackedStringArray) -> void: _choices = keys)


func _nine(tex: String, rect: Rect2, m: int) -> NinePatchRect:
	var r := NinePatchRect.new()
	r.texture = load(UI_DIR + tex + ".png")
	r.position = rect.position
	r.size = rect.size
	r.patch_margin_left = m
	r.patch_margin_top = m
	r.patch_margin_right = m
	r.patch_margin_bottom = m
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	return r


func _label(pos: Vector2, sz: Vector2, col: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.size = sz
	if col.a > 0.0:
		l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l


func is_open() -> bool:
	return _open


func _on_requested(speaker_key: String, lines: PackedStringArray) -> void:
	if _open:
		_choices = PackedStringArray()
		return
	if lines.is_empty() and _choices.is_empty():
		get_node("/root/Events").dialogue_finished.emit()
		return
	_open = true
	_lines = lines
	_opts = _choices
	_choices = PackedStringArray()
	_choosing = false
	_list.text = ""
	_text.text = ""
	_sel_bar.visible = false
	_lozenge.visible = false
	_i = -1
	_opened_frame = Engine.get_process_frames()
	_hold_until = 0
	_was_paused = get_tree().paused
	get_tree().paused = true
	_fresh.clear()
	_speaker_key = ""   # a new talk starts on the neutral face
	var g0 := get_node("/root/Game")
	_hint.text = "" if g0.has_flag("seen_hint_continue") else "%s  %s" % [g0.key_name("interact"), tr("UI_HINT_CONTINUE")]
	_set_speaker(speaker_key)
	visible = true
	_animate_open()
	_next()


## Lights the speaker: world position -> screen, eased. Hero, narration and unknown voices fall back to the hero or the upper middle.
func _pick_focus(key: String) -> void:
	_focus = null
	var sd: Node = get_parent().get_node_or_null("SceneDirector") if get_parent() != null else null
	if key.begins_with("NPC_") and key.ends_with("_NAME") and key != "NPC_HERO_NAME" and sd != null and sd.has_method("find_node_by_id"):
		_focus = sd.call("find_node_by_id", key.trim_prefix("NPC_").trim_suffix("_NAME").to_lower())
	if _focus == null:
		_focus = get_tree().get_first_node_in_group("player") as Node2D


func _update_dim(delta: float) -> void:
	var want := Vector2(240, 100)
	if _focus != null and is_instance_valid(_focus) and _focus.is_inside_tree():
		want = get_viewport().get_canvas_transform() * (_focus.global_position + Vector2(0, -10))
	_dim_center = _dim_center.lerp(want, 1.0 - exp(-10.0 * delta))
	_dim_mat.set_shader_parameter("center", _dim_center.round())
	_dim.position.y = -position.y   # the box slides in; the dim must not


## Slide up 8 px and fade in; the name plate pops (ui.md 3b).
func _animate_open() -> void:
	if _tween:
		_tween.kill()
	modulate.a = 0.0
	position.y = 8.0
	_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true)
	_tween.tween_property(self, "modulate:a", 1.0, 0.2)
	_tween.tween_property(self, "position:y", 0.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_pop_plate()


func _pop_plate() -> void:
	_plate.pivot_offset = _plate.size / 2.0
	_plate.scale = Vector2(0.8, 0.8)
	create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(_plate, "scale", Vector2.ONE, 0.15) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Sets the name and, for a named NPC (key NPC_<ID>_NAME) with a NPC_<ID>_WHO text, the tag; flag seen_name_<id> on first sight.
func _set_speaker(key: String) -> void:
	speaker_changed.emit(key)
	_pick_focus(key)
	var prev := _speaker.text
	_speaker.text = _t(key)
	_plate.visible = _speaker.text != ""
	if key != _speaker_key:
		_mood = ""
	_speaker_key = key
	var face := Portraits.for_key(key, _mood)
	_portrait.texture = face
	_portrait.visible = face != null
	_portrait_frame.visible = face != null
	_plate.size.x = ceilf(_speaker.get_minimum_size().x)
	_speaker.size.x = _plate.size.x
	if _open and _speaker.text != prev:
		_pop_plate()
	var narr := key.contains("DALANG") or _speaker.text.to_lower().contains("(dalang)")
	_text.add_theme_color_override("font_color", NARR_COL if narr else TEXT_COL)
	_who.text = ""
	if not (key.begins_with("NPC_") and key.ends_with("_NAME")):
		return
	var nid := key.trim_prefix("NPC_").trim_suffix("_NAME").to_lower()
	var wk := "NPC_%s_WHO" % nid.to_upper()
	if tr(wk) == wk:
		return
	var g := get_node("/root/Game")
	if g.has_flag("seen_name_" + nid) and not _fresh.has(nid):
		return
	_fresh[nid] = true
	g.set_flag("seen_name_" + nid)
	_who.text = _t(wk)   # shown on the plate row, so the body text never shifts


## Swaps the current speaker's portrait to a mood; unknown moods show the neutral bust.
func _set_mood(mood: String) -> void:
	_mood = "" if mood == "neutral" else mood.strip_edges().to_lower()
	var face := Portraits.for_key(_speaker_key, _mood)
	if face != null:
		_portrait.texture = face


func _t(key: String) -> String:
	return get_node("/root/Game").fmt(tr(key))


func _next() -> void:
	_i += 1
	while _i < _lines.size() and (_lines[_i].begins_with("@") or _lines[_i].begins_with("#")):
		var ln := _lines[_i]
		_i += 1
		if ln.begins_with("@"):
			_set_speaker(ln.substr(1))
			continue
		var cue := ln.substr(1).get_slice(":", 0)
		var arg := ln.substr(1).substr(cue.length() + 1) if ln.contains(":") else ""
		get_node("/root/Events").scene_cue.emit(cue, arg)
		if cue == "face":
			_set_mood(arg)
			continue
		if cue == "wait":
			_text.text = ""
			_text.visible_characters = 0
			_hold_until = Time.get_ticks_msec() + int(clampf(arg.to_float(), 0.0, MAX_WAIT) * 1000.0)
			_i -= 1   # _process calls _next() when the hold ends, which steps forward again
			return
	if _i >= _lines.size():
		if _opts.is_empty():
			_close()
		else:
			_choosing = true
			_sel = 0
			_show_choices()
		return
	var parts := Portraits.strip_face(_t(_lines[_i]))
	if parts[1] != "":
		_set_mood(parts[1])
	_text.text = parts[0]
	_text.visible_characters = 0
	_shown = 0.0
	_layout()


func _show_choices() -> void:
	var out := PackedStringArray()
	for i in _opts.size():
		out.append(_t(_opts[i]))
	_list.text = "\n".join(out)
	_layout()
	var lh := LINE_H
	_sel_bar.size.y = lh
	_sel_bar.position = Vector2(_list.position.x - 10.0, _list.position.y + _sel * lh - 1.0)
	_lozenge.position = Vector2(_sel_bar.position.x + 2.0, _list.position.y + _sel * lh + 2.0)   # on the caps line
	_sel_bar.visible = true
	_lozenge.visible = true


func _calc_text_height(tw: float) -> float:
	if _text.text == "":
		return 0.0
	var font := _text.get_theme_font("font")
	var font_size := _text.get_theme_font_size("font_size")
	if font != null:   # whole lines on the 10 px pitch, so the box height is exact
		var sz := font.get_multiline_string_size(_text.text, _text.horizontal_alignment, tw, font_size)
		var lines := maxi(1, roundi(sz.y / maxf(font.get_height(font_size), 1.0)))
		return lines * LINE_H - 1.0
	return maxf(_text.get_minimum_size().y, LINE_H)


## Sizes the frame to its content and places everything from the bottom edge up: the box is only as tall as the
## text (and choices) need, so one line leaves no empty slab over the world.
func _layout() -> void:
	var has_face := _portrait.visible
	var tx := BOX_X + (FACE_W if has_face else PAD_X)
	var tw := BOX_X + BOX_W - PAD_X - tx
	_text.custom_minimum_size.x = tw
	_text.size.x = tw
	var th := _calc_text_height(tw)
	var top := PAD_TOP + (NAME_ROW if _plate.visible else 0.0)
	var ch := (4.0 + LINE_H * _opts.size()) if (_choosing and not _opts.is_empty()) else 0.0
	var h := maxf(MIN_H_FACE if has_face else MIN_H, top + th + ch + PAD_BOT)
	h = 2.0 * ceilf(h / 2.0)
	_frame.size = Vector2(BOX_W, h)
	_frame.position = Vector2(BOX_X, BOX_BOTTOM - h)
	var fy := _frame.position.y
	var fs := PORTRAIT + PORTRAIT_INSET * 2.0   # 56
	_portrait_frame.position = Vector2(BOX_X + 6.0, fy + roundf((h - fs) / 2.0))   # inside the box, centred on its height
	_portrait.position = _portrait_frame.position + Vector2(PORTRAIT_INSET, PORTRAIT_INSET)
	_plate.position = Vector2(tx, fy + PAD_TOP)
	_who.position = Vector2(tx + _plate.size.x + 6.0, fy + PAD_TOP)
	_who.size.x = maxf(BOX_X + BOX_W - PAD_X - _who.position.x, 0.0)
	var ty := fy + top   # text pinned under the name: lines never jump as the box grows
	_text.position = Vector2(tx, ty)
	_text.size.y = th
	_list.position = Vector2(tx + 10.0, ty + th + 4.0)
	_list.size.x = tw - 10.0
	_sel_bar.size.x = tw
	_cue.position = Vector2(BOX_X + BOX_W - PAD_X - 5.0, fy + h - 10.0)
	_hint.position = Vector2(_cue.position.x - 4.0 - _hint.size.x, fy + h - 12.0)


func _close() -> void:
	_list.text = ""
	_sel_bar.visible = false
	_lozenge.visible = false
	_open = false
	_hold_until = 0
	visible = false
	get_tree().paused = _was_paused
	get_node("/root/Events").dialogue_finished.emit()


func _process(delta: float) -> void:
	if _open:
		_update_dim(delta)
	if _open and _hold_until > 0 and Time.get_ticks_msec() >= _hold_until:
		_hold_until = 0
		_next()
	if _open and _text.visible_characters < _text.get_total_character_count():
		_shown += delta * CPS
		var vis := int(_shown)
		if vis != _text.visible_characters and vis % 2 == 0:
			Snd.blip(_speaker_key)   # typewriter tick, pitched per speaker (audio.md)
		_text.visible_characters = vis
	_cue.visible = _open and _hold_until == 0 and not _choosing and _text.visible_characters >= _text.get_total_character_count() \
			and Time.get_ticks_msec() % 800 < 500
	_cue.position.y = _frame.position.y + _frame.size.y - 10.0 + (1.0 if Time.get_ticks_msec() % 800 < 250 else 0.0)
	_hint.visible = _cue.visible and _hint.text != ""


func _unhandled_input(event: InputEvent) -> void:
	# the press that opened the box arrives in the same frame: not an advance
	if not _open or Engine.get_process_frames() == _opened_frame:
		return
	if _hold_until > 0:   # a #wait beat: input does not skip it
		return
	if _choosing:
		var d := int(event.is_action_pressed("move_down") or event.is_action_pressed("ui_down")) \
				- int(event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"))
		if d != 0:
			get_viewport().set_input_as_handled()
			_sel = posmod(_sel + d, _opts.size())
			_show_choices()
		elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
			get_viewport().set_input_as_handled()
			get_node("/root/Events").dialogue_picked.emit(_sel)
			_close()
		return
	if not (event.is_action_pressed("interact") or event.is_action_pressed("ui_accept") or event.is_action_pressed("attack")):
		return
	get_viewport().set_input_as_handled()
	if _text.visible_characters < _text.get_total_character_count():
		_text.visible_characters = _text.get_total_character_count()
	else:
		if _hint.text != "":   # the player found the key: the hint has done its job
			_hint.text = ""
			get_node("/root/Game").set_flag("seen_hint_continue")
		_next()
