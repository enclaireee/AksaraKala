extends Control
## Tutorial cues (`.docs/tutorial.md`): one quiet pill at the bottom of the screen, offered when the story says
## what it is for and finished by the input itself. Data lives in `data/lessons.gd`.
##
## The flag `tut_<id>` (Game.flags) keeps a finished lesson from ever coming back. A lesson is shown only while
## its `when` condition holds, and it hides (without being forgotten) while a dialogue, the menu, a write card or
## the death screen is up. Nothing here pauses, blocks or dims the game.

const Lessons = preload("res://data/lessons.gd")

const FADE := 0.16          # s, in and out
const HOLD_DONE := 0.55     # s the finished pill stays before it goes
const Y := 224.0            # px from the top: clear of the weapon well (242) and the boss bar
const MIN_W := 108.0
const MAX_W := 316.0
const H := 15.0
const PAD := 8.0
const CAP_MIN := 9.0

var _game: Node
var _ev: Node
var _id := ""               # the lesson on screen, "" when there is none
var _lesson := {}
var _step := 0              # index into steps
var _got := 0               # hits counted for the current step
var _queue: Array[String] = []
var _state := "off"         # off | on | done
var _a := 0.0               # fade 0..1
var _hold := 0.0
var _ttl := -1.0
var _t := 0.0

var _root: Control
var _panel: NinePatchRect
var _cap: NinePatchRect
var _key: Label
var _lbl: Label


func _ready() -> void:
	_game = get_node("/root/Game")
	_ev = get_node("/root/Events")
	mouse_filter = MOUSE_FILTER_IGNORE
	_root = Control.new()
	_root.mouse_filter = MOUSE_FILTER_IGNORE
	_root.visible = false
	add_child(_root)
	_panel = NinePatchRect.new()
	_panel.texture = UIFx.tex("ink_panel")
	for side in ["left", "top", "right", "bottom"]:
		_panel.set("patch_margin_" + side, 4)
	_panel.mouse_filter = MOUSE_FILTER_IGNORE
	_root.add_child(_panel)
	_cap = NinePatchRect.new()
	_cap.texture = UIFx.tex("keycap")
	for side in ["left", "right"]:
		_cap.set("patch_margin_" + side, 3)
	for side in ["top", "bottom"]:
		_cap.set("patch_margin_" + side, 3)
	_cap.visible = false
	_cap.mouse_filter = MOUSE_FILTER_IGNORE
	_root.add_child(_cap)
	_key = Label.new()
	_key.add_theme_font_override("font", UIFx.body_font())
	_key.add_theme_font_size_override("font_size", UIFx.BODY)
	_key.add_theme_color_override("font_color", UIFx.NIGHT)   # night letter on the light keycap
	_key.add_theme_constant_override("outline_size", 0)
	_key.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_key.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_key.visible = false
	_key.mouse_filter = MOUSE_FILTER_IGNORE
	_root.add_child(_key)
	_lbl = UIFx.text("", "body", UIFx.TEXT)
	_lbl.mouse_filter = MOUSE_FILTER_IGNORE
	_root.add_child(_lbl)
	_connect_events()


func _connect_events() -> void:
	_ev.lesson_offered.connect(func(id: String) -> void: offer(id))
	_ev.player_struck.connect(func(_combo: int) -> void: _hit("struck"))
	_ev.player_dodged.connect(func() -> void: _hit("dodged"))
	_ev.perfect_dodge.connect(func() -> void: _hit("perfect"))
	_ev.player_drank.connect(func() -> void: _hit("drink"))
	_ev.spell_cast.connect(func(_glyph: String, _score: float) -> void: _hit("cast"))
	_ev.petilasan_activated.connect(func(_id2: String) -> void: _hit("rest"))
	_ev.player_hurt.connect(_on_hurt)
	_ev.player_died.connect(_quiet)
	_ev.dialogue_requested.connect(func(_k: String, _l: PackedStringArray) -> void: _refresh_visible())
	_ev.dialogue_finished.connect(func() -> void: _refresh_visible())
	_game.changed.connect(_on_changed)


## Offers a lesson. Ignored when it is finished, on screen already, queued, or its condition does not hold now.
func offer(id: String) -> void:
	if _id == id or id in _queue or _lesson_done(id):
		return
	var l := Lessons.by_id(id)
	if l.is_empty():
		push_warning("tutorial: unknown lesson '%s'" % id)
		return
	var when: String = l.get("when", "")
	if when != "" and not _game.check(when):
		return
	if l.get("needs_flask", false) and int(_game.flask_charges) <= 0:
		return
	if _id == "":
		_begin(id)
	else:
		_queue.append(id)


## The lesson on screen ("" when none). Tests read this; nothing else should.
func active() -> String:
	return _id


# --- the lesson in flight ---

func _begin(id: String) -> void:
	_id = id
	_lesson = Lessons.by_id(id)
	_step = 0
	_got = 0
	_ttl = float(_lesson.get("ttl", -1.0))
	_t = 0.0
	_hold = 0.0
	_state = "on"
	_a = 0.0
	_root.visible = true
	_refresh_text()
	_refresh_visible()


func _hit(event: String) -> void:
	if _id == "" or _state != "on" or _lesson.get("steps", []).is_empty():
		return
	if _step >= _lesson.steps.size():
		return
	var s: Dictionary = _lesson.steps[_step]
	if str(s.get("event", "")) != event:
		return
	_got += 1
	if _got >= int(s.get("n", 1)):
		_step += 1
		_got = 0
	if _step >= _lesson.steps.size():
		_finish()
	else:
		_refresh_text()


func _finish() -> void:
	_game.set_flag(Lessons.flag(_id))
	Snd.play("ui_page", 0.0, 0.8, 0.04)
	_state = "done"
	_hold = HOLD_DONE
	_refresh_text()


## Clears the pill without finishing the lesson (a condition stopped holding, the player died, or it timed out).
func _quiet() -> void:
	_id = ""
	_lesson = {}
	_state = "off"
	_a = 0.0
	_root.visible = false
	if not _queue.is_empty():
		var nxt: String = _queue.pop_front()
		_begin(nxt)


func _on_hurt(hp_ratio: float) -> void:
	for id: String in Lessons.ON_HURT:
		var l := Lessons.by_id(id)
		if l.is_empty() or l.get("on", "") != "hurt":
			continue
		if hp_ratio > float(l.get("hp_below", 1.0)):
			continue
		offer(id)


func _on_changed() -> void:
	# A step advanced or a flag moved: a lesson whose moment passed goes quiet (it is not marked done).
	if _id != "" and _state == "on" and not _when_holds():
		_quiet()
		return
	for id in _queue.duplicate():
		var l := Lessons.by_id(id)
		var when: String = l.get("when", "")
		if when != "" and not _game.check(when):
			_queue.erase(id)
	_refresh_visible()


func _when_holds() -> bool:
	var when: String = _lesson.get("when", "")
	return when == "" or _game.check(when)


# --- drawing ---

func _refresh_text() -> void:
	var l := _lesson
	if l.is_empty():
		return
	var keys := {}
	for a in ["attack", "cast", "dodge", "interact", "heal_jamu", "menu"]:
		keys[a] = _game.key_name(a)
	keys.move = "%s%s%s%s" % [_game.key_name("move_up"), _game.key_name("move_left"),
		_game.key_name("move_down"), _game.key_name("move_right")]
	var text: String = tr(str(l.get("text", ""))).format(keys)
	if _state != "done" and _lesson.steps.size() > 1 and _step < _lesson.steps.size():
		text += "  %d/%d" % [_got, int(_lesson.steps[_step].get("n", 1))]
	_lbl.text = text
	var k: String = str(l.get("key", ""))
	var kw := 0.0
	if k != "" and _state != "done":   # the keycap goes once the verb is learned
		_key.text = _game.key_name(k)
		var f := UIFx.body_font()
		kw = maxf(CAP_MIN, ceil(f.get_string_size(_key.text, HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x) + 5.0)
	_key.visible = kw > 0.0
	_cap.visible = kw > 0.0
	if kw > 0.0:
		_cap.size = Vector2(kw, H)
		_key.size = _cap.size
		_key.position = Vector2.ZERO
	var tw := UIFx.body_font().get_string_size(_lbl.text, HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x
	var w := clampf(PAD + (kw + 4.0 if kw > 0.0 else 0.0) + tw + PAD, MIN_W, MAX_W)
	_panel.size = Vector2(w, H)
	if kw > 0.0:
		_cap.position = Vector2(PAD, round((H - _cap.size.y) * 0.5))
	var lx := PAD + (kw + 4.0 if kw > 0.0 else 0.0)
	_lbl.position = Vector2(lx, 3)
	_lbl.size = Vector2(w - lx - PAD + 2.0, 9)
	_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_root.position = Vector2(round((480.0 - w) * 0.5), Y)


func _refresh_visible() -> void:
	if _id == "":
		_root.visible = false
		return
	var want := _state != "off" and not blocked_now() and _when_holds()
	_root.visible = want or _a > 0.01


## True while something modal or paused owns the screen; the pill waits behind it.
func blocked_now() -> bool:
	var box := get_node_or_null("../DialogueBox")
	var lesson := get_node_or_null("../GlyphLesson")
	return get_tree().paused \
		or (box != null and box.is_open()) \
		or (lesson != null and (lesson.active != "" or lesson.writing != ""))


func _process(delta: float) -> void:
	if _id == "":
		return
	_t += delta
	if _state == "on" and _ttl > 0.0 and _t >= _ttl:
		_quiet()
		return
	if _state == "done":
		_hold -= delta
		if _hold <= 0.0:
			_quiet()
			return
	var want := not blocked_now() and _when_holds()
	_a = move_toward(_a, 1.0 if want else 0.0, delta / FADE)
	_root.modulate.a = _a
	_root.visible = _a > 0.01


func _lesson_done(id: String) -> bool:
	if Lessons.by_id(id).is_empty():
		return false
	return _game.has_flag(Lessons.flag(id))
