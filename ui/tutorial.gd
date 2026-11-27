extends Control
## Pelajaran Desa Purwa — Unified tutorial cue card & tactical coach (`.docs/tutorial.md`).
##
## Features:
## - Single crisp dusk-ink card anchored safely above weapon well (242) and boss bar (236).
## - Supports custom pixel mouse icons (tut_mouse_lmb / tut_mouse_rmb), WASD+keycaps, or single keycaps.
## - True 3-hit combo chain pip tracker (resets if chain drops before combo == 2 finisher) + per-class tip stage.
## - Real interact verification for the opening `move` lesson (empty-air E presses do not dismiss it).
## - Guarded brief tactical slow-mo on first Faceless windup (Perfect Dodge) and first low-HP hit (Jamu heal).
## - Automatic HUD bar spotlighting (Stamina, Sakti, Flasks, Menu) and zero collision with GlyphLesson.
## - Respects GameSettings.skip_tutorials() for replay veterans.

const Lessons = preload("res://data/lessons.gd")

const FADE := 0.16            # s (real-time fade)
const HOLD_DONE := 0.85       # s finished card holds with golden checkmark
const BOTTOM := 232.0         # card bottom: clear of boss bar (236) and weapon well (242)
const BOTTOM_BOSS := 224.0    # extra lift if a boss bar is ever on screen
const MIN_W := 168.0
const MAX_W := 280.0
const PAD := 6.0
const CAP_MIN := 12.0
const CAP_H := 14.0           # = MenuBook.KEYCAP_H
const ICON_GAP := 8.0         # icon column to text column

var H := 38.0                 # card height: PAD + 12 kicker + 2 + 12 per body line (1-2) + PAD
const WINDUP_RANGE := 84.0    # px: enemy windup triggers `perfect` only when threatening the player

var _game: Node
var _ev: Node
var _id := ""                 # active lesson id ("" when none)
var _lesson := {}
var _step := 0                # index into _lesson.steps
var _got := 0                 # progress counter within current step
var _queue: Array[String] = []
var _state := "off"           # off | on | done
var _a := 0.0
var _hold := 0.0
var _ttl := -1.0
var _t := 0.0
var _moved := false
var _interacted := false
var _combo_pips := 0          # 0..3 live combo chain pips during `combo` step 0
var _combat_dodges := 0       # fallback dodge count during `perfect` lesson
var _last_spotlight := ""
var _slow_scale := 0.0        # non-zero only while THIS node owns tactical slow-mo
var _slow_end_ms := 0
var _last_real_ms := 0

var _root: Control
var _panel: NinePatchRect
var _accent: ColorRect        # leading gold/cyan edge bar
var _cap: NinePatchRect
var _key: Label
var _mouse: TextureRect       # tut_mouse_lmb / tut_mouse_rmb (2-frame atlas)
var _mouse_atlas: AtlasTexture
var _check: TextureRect       # tut_check.png on completion
var _kicker: Label            # small caps title
var _lbl: Label               # 1-line body cue
var _pips: Array[ColorRect] = []   # 3 combo chain pips


func _ready() -> void:
	_game = get_node("/root/Game")
	_ev = get_node("/root/Events")
	_last_real_ms = Time.get_ticks_msec()
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

	_accent = ColorRect.new()
	_accent.color = UIFx.WARM
	_accent.position = Vector2(2.0, 3.0)
	_accent.size = Vector2(2.0, H - 6.0)  # resized in _refresh_text
	_accent.mouse_filter = MOUSE_FILTER_IGNORE
	_root.add_child(_accent)

	_cap = NinePatchRect.new()
	_cap.texture = UIFx.tex("keycap")
	for side in ["left", "top", "right", "bottom"]:
		_cap.set("patch_margin_" + side, 4 if side == "bottom" else 3)
	_cap.visible = false
	_cap.mouse_filter = MOUSE_FILTER_IGNORE
	_root.add_child(_cap)

	_key = Label.new()
	_key.add_theme_font_override("font", UIFx.body_font())
	_key.add_theme_font_size_override("font_size", UIFx.BODY)
	_key.add_theme_color_override("font_color", UIFx.NIGHT)
	_key.add_theme_constant_override("outline_size", 0)
	_key.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_key.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_key.clip_text = false
	_key.visible = false
	_key.mouse_filter = MOUSE_FILTER_IGNORE
	_root.add_child(_key)

	_mouse_atlas = AtlasTexture.new()
	_mouse_atlas.region = Rect2(0, 0, 12, 16)
	_mouse = TextureRect.new()
	_mouse.texture = _mouse_atlas
	_mouse.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_mouse.stretch_mode = TextureRect.STRETCH_KEEP
	_mouse.visible = false
	_mouse.mouse_filter = MOUSE_FILTER_IGNORE
	_root.add_child(_mouse)

	_check = TextureRect.new()
	if ResourceLoader.exists("res://assets/art/ui/tut_check.png"):
		_check.texture = load("res://assets/art/ui/tut_check.png")
	_check.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_check.stretch_mode = TextureRect.STRETCH_KEEP
	_check.visible = false
	_check.mouse_filter = MOUSE_FILTER_IGNORE
	_root.add_child(_check)

	_kicker = UIFx.text("", "label", UIFx.WARM)
	_kicker.mouse_filter = MOUSE_FILTER_IGNORE
	_root.add_child(_kicker)

	_lbl = UIFx.text("", "body", UIFx.TEXT)
	_lbl.mouse_filter = MOUSE_FILTER_IGNORE
	_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_root.add_child(_lbl)

	for i in 3:
		var pip := ColorRect.new()
		pip.size = Vector2(5, 3) if i < 2 else Vector2(7, 3)
		pip.color = UIFx.LINE_DIM
		pip.visible = false
		pip.mouse_filter = MOUSE_FILTER_IGNORE
		_root.add_child(pip)
		_pips.append(pip)

	_connect_events()
	_maybe_offer_opening()


func _exit_tree() -> void:
	_end_slow()
	_sync_spotlight("")


func _connect_events() -> void:
	_ev.lesson_offered.connect(func(id: String) -> void: offer(id))
	_ev.player_struck.connect(_on_struck)
	_ev.enemy_killed.connect(_on_enemy_killed)
	_ev.player_dodged.connect(_on_dodged)
	_ev.perfect_dodge.connect(_on_perfect_dodge)
	_ev.player_drank.connect(_on_drank)
	_ev.spell_cast.connect(func(_glyph: String, _score: float) -> void: _hit("cast"))
	_ev.petilasan_activated.connect(func(_id2: String) -> void: _hit("rest"))
	_ev.menu_opened.connect(func(_tab: int) -> void: _hit("menu"))
	_ev.talked_to.connect(func(_npc: String) -> void: _note_interact())
	_ev.clue_examined.connect(func(_clue: String) -> void: _note_interact())
	_ev.zone_entered.connect(func(_z: String) -> void:
		_end_slow()
		_maybe_offer_opening())
	_ev.player_hurt.connect(_on_hurt)
	_ev.enemy_windup.connect(_on_enemy_windup)
	_ev.player_died.connect(func() -> void:
		_end_slow()
		_quiet())
	_ev.dialogue_requested.connect(func(_k: String, _l: PackedStringArray) -> void:
		_end_slow()
		_refresh_visible())
	_ev.dialogue_finished.connect(func() -> void: _refresh_visible())
	_game.changed.connect(_on_changed)


## Offers a lesson. Ignored when skipped by settings, finished, on screen, queued, or condition false.
func offer(id: String) -> void:
	if GameSettings.skip_tutorials():
		return
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
	if _id == "move" or _id == "menu":
		_quiet()
	if _id == "":
		_begin(id)
	else:
		_queue.append(id)


## Quiet, non-blocking Move + Interact opening prompt at mq0 step 0.
func _maybe_offer_opening() -> void:
	if GameSettings.skip_tutorials():
		return
	if _id != "" or _lesson_done("move") or not _game.check("step:mq0=0"):
		return
	_moved = false
	_interacted = false
	_begin("move")


## Marks all prologue tutorials done (used by replay-skip choices or tests).
func mark_done(id: String) -> void:
	if id == "":
		return
	_game.set_flag(Lessons.flag(id))
	if _id == id:
		_end_slow()
		_quiet()
	_queue.erase(id)


## The lesson on screen ("" when none). Tests and zones read this.
func active() -> String:
	return _id


## Current step index inside the active lesson.
func active_step() -> int:
	return _step


# --- input & combat event handlers ---

func _note_interact() -> void:
	if _id != "move" or _state != "on":
		return
	_interacted = true
	if _moved:
		_finish()


func _input(event: InputEvent) -> void:
	if _id != "move" or _state != "on" or blocked_now():
		return
	if event.is_action_pressed("move_up") or event.is_action_pressed("move_down") \
			or event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
		_moved = true
		if _interacted:
			_finish()


func _on_struck(combo: int) -> void:
	if _id == "combo" and _state == "on" and _step == 0:
		# Track true 3-hit combo progression: 0 -> 1 -> 2. Dropping back to 0 resets the chain display.
		if combo == 0:
			_combo_pips = 1
		elif combo == 1:
			_combo_pips = maxi(_combo_pips, 2)
		elif combo >= 2:
			_combo_pips = 3
			_hit("combo")
			return
		_refresh_text()
		return
	_hit("struck")


func _on_enemy_killed(enemy: Node2D, _ilmu: int) -> void:
	if enemy != null and is_instance_valid(enemy) and str(enemy.get("kind")) == "dummy":
		_hit("dummy")


func _on_dodged() -> void:
	if _id == "perfect" and _state == "on":
		_end_slow()
		_combat_dodges += 1
		var fallback := int(_lesson.get("fallback_dodges", 0))
		if fallback > 0 and _combat_dodges >= fallback:
			_finish()
		return
	_hit("dodged")


func _on_perfect_dodge() -> void:
	_end_slow()
	_hit("perfect")


func _on_drank() -> void:
	_end_slow()
	_hit("drink")


func _on_hurt(hp_ratio: float) -> void:
	if GameSettings.skip_tutorials():
		return
	for id: String in Lessons.ON_HURT:
		var l := Lessons.by_id(id)
		if l.is_empty() or l.get("on", "") != "hurt":
			continue
		if hp_ratio > float(l.get("hp_below", 1.0)):
			continue
		offer(id)


func _on_enemy_windup(enemy: Node2D) -> void:
	if GameSettings.skip_tutorials() or enemy == null or not is_instance_valid(enemy):
		return
	var pl := get_tree().get_first_node_in_group("player") as Node2D
	if pl == null or pl.global_position.distance_to(enemy.global_position) > WINDUP_RANGE:
		return
	for id: String in Lessons.ON_WINDUP:
		if _lesson_done(id) or _id == id:
			continue
		var before := _id
		offer(id)
		if _id == id and before != id:
			WorldBeacon.attach(enemy, UIFx.DANGER, -22.0, 1.8)


# --- lesson lifecycle ---

func _begin(id: String) -> void:
	_id = id
	_lesson = Lessons.by_id(id)
	_step = 0
	_got = 0
	_combo_pips = 0
	_combat_dodges = 0
	_ttl = float(_lesson.get("ttl", -1.0))
	_t = 0.0
	_hold = 0.0
	_state = "on"
	_a = 0.0
	_root.visible = true
	_refresh_text()
	_refresh_visible()
	var sm: Array = _lesson.get("slow_mo", [])
	if sm.size() == 2 and not blocked_now():
		_start_slow(float(sm[0]), float(sm[1]))


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
		Snd.play("ui_page", 0.0, 0.9, 0.04)
		_refresh_text()


func _finish() -> void:
	_end_slow()
	_game.set_flag(Lessons.flag(_id))
	Snd.play("ui_page", 0.0, 1.0, 0.04)
	_state = "done"
	_hold = HOLD_DONE
	_sync_spotlight("")
	_refresh_text()


## Clears the card without finishing the lesson (condition stopped holding, player died, or TTL elapsed).
func _quiet() -> void:
	_end_slow()
	_id = ""
	_lesson = {}
	_state = "off"
	_a = 0.0
	_root.visible = false
	_sync_spotlight("")
	if not _queue.is_empty():
		var nxt: String = _queue.pop_front()
		if not _lesson_done(nxt) and not GameSettings.skip_tutorials():
			var l := Lessons.by_id(nxt)
			var when: String = l.get("when", "")
			if when == "" or _game.check(when):
				_begin(nxt)


func _on_changed() -> void:
	if GameSettings.skip_tutorials() and _id != "":
		_quiet()
		return
	if _id != "" and _state == "on" and not _when_holds():
		_quiet()
		return
	for id in _queue.duplicate():
		var l := Lessons.by_id(id)
		var when: String = l.get("when", "")
		if when != "" and not _game.check(when):
			_queue.erase(id)
	_maybe_offer_opening()
	_refresh_visible()


func _when_holds() -> bool:
	var when: String = _lesson.get("when", "")
	return when == "" or _game.check(when)


# --- guarded tactical slow-mo (mirrors ui/boss_stage.gd safety) ---

func _start_slow(scale: float, real_seconds: float) -> void:
	if DisplayServer.get_name() == "headless":
		return
	if get_tree().paused or not is_equal_approx(Engine.time_scale, 1.0):
		return
	var pl := get_tree().get_first_node_in_group("player")
	if pl and pl.get("cast") and pl.cast.drawing:
		return
	Engine.time_scale = clampf(scale, 0.15, 0.5)
	_slow_scale = Engine.time_scale
	_slow_end_ms = Time.get_ticks_msec() + int(real_seconds * 1000.0)


func _end_slow() -> void:
	if _slow_scale > 0.0 and is_equal_approx(Engine.time_scale, _slow_scale):
		Engine.time_scale = 1.0
	_slow_scale = 0.0
	_slow_end_ms = 0


func _tick_slow() -> void:
	if _slow_scale <= 0.0:
		return
	var pl := get_tree().get_first_node_in_group("player")
	if get_tree().paused or blocked_now() or (pl and pl.get("cast") and pl.cast.drawing):
		_end_slow()
		return
	if not is_equal_approx(Engine.time_scale, _slow_scale):
		# Another system (CastController / BossStage) took ownership of time_scale; release ours cleanly.
		_slow_scale = 0.0
		_slow_end_ms = 0
		return
	if Time.get_ticks_msec() >= _slow_end_ms:
		_end_slow()


# --- HUD spotlight bridge ---

func _sync_spotlight(target: String) -> void:
	if target == _last_spotlight:
		return
	_last_spotlight = target
	var hud := get_node_or_null("../HUD")
	if hud == null:
		return
	if target == "" and hud.has_method("clear_spotlight"):
		hud.clear_spotlight()
	elif target != "" and hud.has_method("spotlight"):
		hud.spotlight(target)


# --- layout & drawing ---

func _keys_dict() -> Dictionary:
	var keys := {}
	for a in ["attack", "cast", "dodge", "interact", "heal_jamu", "menu", "map", "pause"]:
		keys[a] = _game.key_name(a).replace("Escape", "Esc")
	keys.move = "%s%s%s%s" % [_game.key_name("move_up"), _game.key_name("move_left"),
		_game.key_name("move_down"), _game.key_name("move_right")]
	return keys


func _body_text(keys: Dictionary) -> String:
	if _state == "done":
		return tr("UI_TUT_DONE")
	# Cepot Stage B: show the player's own class mechanic tip while finishing off the dummy!
	if _id == "combo" and _step == 1:
		return tr(Lessons.class_tip_key(str(_game.class_id))).format(keys)
	# Semar Phase B: dynamically adapt for toggle_cast & show Sakti readiness
	if _id == "cast":
		var pl := get_tree().get_first_node_in_group("player")
		var sk: float = float(pl.sakti.value) if pl and pl.get("sakti") else 0.0
		var need := 15
		if sk < float(need):
			return tr("UI_TUT_SAKTI_FILL").format(keys) % [int(sk), need]
		var k := "UI_TUT_CAST_TOGGLE" if GameSettings.toggle_cast() else "UI_TUT_CAST"
		return tr(k).format(keys)
	return tr(str(_lesson.get("text", ""))).format(keys)


func _refresh_text() -> void:
	var l := _lesson
	if l.is_empty():
		return
	var keys := _keys_dict()
	var title_key := str(l.get("title", ""))
	if _id == "combo" and _step == 1:
		var ck := "CLASS_%s_PASSIVE" % str(_game.class_id).to_upper()
		_kicker.text = tr(ck) if tr(ck) != ck else tr(title_key)
	else:
		_kicker.text = tr(title_key) if title_key != "" else ""
	_kicker.add_theme_color_override("font_color", UIFx.OK if _state == "done" else (UIFx.ACCENT if _id == "cast" else UIFx.WARM))
	_accent.color = UIFx.OK if _state == "done" else (UIFx.ACCENT if _id == "cast" else UIFx.WARM)

	_lbl.text = _body_text(keys)
	var icon_kind := str(l.get("icon", ""))
	var k := str(l.get("key", ""))
	var left_w := 0.0

	_check.visible = _state == "done" and _check.texture != null
	_mouse.visible = false
	_cap.visible = false
	_key.visible = false

	if _check.visible:
		left_w = 9.0
	elif icon_kind in ["mouse_lmb", "mouse_rmb"]:
		var tex_name := "tut_" + icon_kind
		if ResourceLoader.exists("res://assets/art/ui/%s.png" % tex_name):
			_mouse_atlas.atlas = load("res://assets/art/ui/%s.png" % tex_name)
			_mouse.visible = true
			left_w = 12.0
	elif k != "":
		var kn: String = str(_game.key_name(k)).replace("Escape", "Esc")
		if icon_kind == "wasd":
			kn = str(keys.move)
		_key.text = kn
		var f := UIFx.body_font()
		left_w = maxf(CAP_MIN, ceilf(f.get_string_size(_key.text, HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x) + 6.0)
		_cap.visible = true
		_key.visible = true
		_cap.size = Vector2(left_w, CAP_H)
		_key.size = Vector2(left_w, UIFx.LINE - 1.0)

	# 3-hit combo pip strip (only during `combo` step 0 while active)
	var show_pips := _id == "combo" and _step == 0 and _state == "on"
	for i in _pips.size():
		_pips[i].visible = show_pips
		if show_pips:
			_pips[i].color = (UIFx.WARM if i < 2 else UIFx.ACCENT) if i < _combo_pips else UIFx.LINE_DIM

	var f_body := UIFx.body_font()
	var f_lbl := UIFx.caps_font()
	var tw: float = f_body.get_string_size(_lbl.text, HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x
	var kw_title: float = f_lbl.get_string_size(_kicker.text.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x + (26.0 if show_pips else 0.0)
	var lx := PAD + (left_w + ICON_GAP if left_w > 0.0 else 0.0)
	var w := clampf(lx + maxf(tw, kw_title) + PAD, MIN_W, MAX_W)
	var tx_w := w - lx - PAD
	_lbl.size = Vector2(tx_w, UIFx.LINE)
	var lines := clampi(_lbl.get_line_count(), 1, 2)
	H = PAD * 2.0 + UIFx.LINE + UIFx.GAP_XS + UIFx.LINE * lines
	_panel.size = Vector2(w, H)
	_accent.size = Vector2(2.0, H - 6.0)
	_kicker.position = Vector2(lx, PAD)
	_kicker.size = Vector2(tx_w, UIFx.LINE)
	_lbl.position = Vector2(lx, PAD + UIFx.LINE + UIFx.GAP_XS)
	_lbl.size = Vector2(tx_w, UIFx.LINE * lines)
	var cy := roundf(H * 0.5)
	_check.position = Vector2(PAD, cy - 5.0)
	_mouse.position = Vector2(PAD, cy - 8.0)
	_cap.position = Vector2(PAD, cy - CAP_H * 0.5)
	_key.position = _cap.position + Vector2(0.0, 1.0)   # ink starts on face row 2
	if show_pips:
		var px := w - PAD - 21.0
		for i in _pips.size():
			_pips[i].position = Vector2(px, PAD + 4.0)
			px += _pips[i].size.x + 2.0
	var y := (BOTTOM_BOSS if _boss_bar_visible() else BOTTOM) - H
	_root.position = Vector2(roundf((480.0 - w) * 0.5), y)


func _boss_bar_visible() -> bool:
	var hud := get_node_or_null("../HUD")
	if hud == null:
		return false
	var br: Variant = hud.get("_boss_root")
	return br is CanvasItem and (br as CanvasItem).visible


func _refresh_visible() -> void:
	if _id == "":
		_root.visible = false
		_sync_spotlight("")
		return
	var want := _state != "off" and not blocked_now() and _when_holds()
	_root.visible = want or _a > 0.01
	_sync_spotlight(str(_lesson.get("spotlight", "")) if (want and _state == "on") else "")


## True while something modal, paused or GlyphLesson owns the screen; the card waits behind it.
func blocked_now() -> bool:
	var box := get_node_or_null("../DialogueBox")
	var lesson := get_node_or_null("../GlyphLesson")
	var glyph_blocks: bool = lesson != null and (str(lesson.get("writing")) != "" or str(lesson.get("active")) != "")
	var stage := get_tree().get_first_node_in_group("boss_stage")   # the boss entrance card owns the lower screen
	var card: Variant = stage.get("_card") if stage != null else null
	var entrance: bool = card is CanvasItem and (card as CanvasItem).modulate.a > 0.01
	return get_tree().paused \
		or (box != null and box.is_open()) \
		or glyph_blocks or entrance


func _process(_delta: float) -> void:
	var now := Time.get_ticks_msec()
	var real_dt := clampf(float(now - _last_real_ms) * 0.001, 0.0, 0.1)
	_last_real_ms = now
	_tick_slow()
	if _id == "":
		return
	_t += real_dt
	if _mouse.visible:
		var frame := 1 if int(_t * 2.2) % 2 == 1 else 0
		_mouse_atlas.region = Rect2(frame * 12, 0, 12, 16)
	# Live-refresh Sakti counter during Semar Phase B so the prompt flips the instant Sakti >= 15
	if _id == "cast" and _state == "on":
		_refresh_text()
	if _state == "on" and _ttl > 0.0 and _t >= _ttl:
		_quiet()
		return
	if _state == "done":
		_hold -= real_dt
		if _hold <= 0.0:
			_quiet()
			return
	var want := not blocked_now() and _when_holds()
	_a = move_toward(_a, 1.0 if want else 0.0, real_dt / FADE)
	_root.modulate.a = _a
	_root.visible = _a > 0.01
	_sync_spotlight(str(_lesson.get("spotlight", "")) if (want and _state == "on") else "")


func _lesson_done(id: String) -> bool:
	if Lessons.by_id(id).is_empty():
		return false
	return _game.has_flag(Lessons.flag(id))
