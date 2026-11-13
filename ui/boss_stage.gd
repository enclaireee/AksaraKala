extends Control
## Boss fight staging (combat.md 5.3b, ui.md 2). Watches the node in group "boss" through the same contract as the HUD
## boss bar (`health`, `engaged`, `boss_name_key`, optional `phase`) and stages three beats, so no boss script changes:
##   entrance: letterbox bars close in and a name card opens between two brass rules
##   phase change: a warm flash, a short slow-motion beat and a camera shake
##   finishing blow: a white flash, a longer slow-motion beat and a hard shake
## "Reduce flashing" (controls.md 6) dims the flashes. Slow motion is skipped headless and while a cast holds time.

const BAR_H := 20.0
const RULE_W := 168.0
const GOLD := Color("D2A446")

var _boss: Node
var _was_engaged := false
var _phase := 0
var _alive := false
var _top: ColorRect
var _bot: ColorRect
var _card: Control
var _name: Label
var _rules: Array[ColorRect] = []
var _flash: ColorRect
var _tw: Tween
var _slow_scale := 0.0   # the time scale this node set, 0 when it holds none
var _epithet: Label
var _line: Label
var _hint: Label
var _hint_bg: ColorRect
var _hint_tw: Tween
var _staging := false    # the tree is paused for an entrance
var staged := DisplayServer.get_name() != "headless"   # tests set it true to run the paused entrance

const LONG := 2.6    # TUNE: seconds the card holds on a first entrance (3.6 s in all)
const SHORT := 0.3   # TUNE: and on a retry (0.9 s in all)


func _ready() -> void:
	add_to_group("boss_stage")
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(480, 270)
	_flash = _rect(Vector2.ZERO, Vector2(480, 270), Color(1.0, 0.95, 0.8, 0.0), self)
	_top = _rect(Vector2(0, -BAR_H), Vector2(480, BAR_H), Color(UIFx.INK_BG, 1.0), self)
	_bot = _rect(Vector2(0, 270), Vector2(480, BAR_H), Color(UIFx.INK_BG, 1.0), self)
	_rect(Vector2(0, BAR_H - 1), Vector2(480, 1), Color(GOLD, 0.6), _top)
	_rect(Vector2(0, 0), Vector2(480, 1), Color(GOLD, 0.6), _bot)
	_card = Control.new()
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.modulate.a = 0.0
	add_child(_card)
	_rect(Vector2(120, 86), Vector2(240, 50), Color(UIFx.INK_BG, 0.55), _card)
	_name = UIFx.text("", "head", UIFx.GOLD_HI)
	_name.position = Vector2(0, 98)
	_name.size = Vector2(240, 13)
	_name.scale = Vector2(2, 2)   # the heading face at twice its size: whole pixels
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_card.add_child(_name)
	_epithet = UIFx.text("", "body", UIFx.WARM)
	_epithet.position = Vector2(0, 137)
	_epithet.size = Vector2(480, 9)
	_epithet.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_card.add_child(_epithet)
	_line = UIFx.text("", "body", Color(1, 1, 1))
	_line.position = Vector2(40, 270 - BAR_H - 30)
	_line.size = Vector2(400, 20)
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_card.add_child(_line)
	_hint_bg = _rect(Vector2(90, 270 - 52), Vector2(300, 13), Color(UIFx.INK_BG, 0.8), self)
	_hint_bg.modulate.a = 0.0
	_hint = UIFx.text("", "body", UIFx.GOLD_HI)
	_hint.position = Vector2(0, 2)
	_hint.size = Vector2(300, 9)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_hint_bg.add_child(_hint)
	for y: float in [90.0, 131.0]:
		_rules.append(_rect(Vector2(240, y), Vector2(0, 1), GOLD, _card))
	for y: float in [88.0, 129.0]:   # a small lozenge on each rule
		_rect(Vector2(238, y), Vector2(5, 5), GOLD, _card)
		_rect(Vector2(239, y + 1), Vector2(3, 3), UIFx.INK_BG, _card)


func _rect(pos: Vector2, sz: Vector2, col: Color, parent: Node) -> ColorRect:
	var r := ColorRect.new()
	r.position = pos
	r.size = sz
	r.color = col
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)
	return r


## A fight reminder above the boss bar for `seconds` (BossKit.hint).
func show_hint(text: String, seconds := 4.0) -> void:
	_hint.text = text
	if _hint_tw:
		_hint_tw.kill()
	_hint_tw = create_tween()
	_hint_tw.tween_property(_hint_bg, "modulate:a", 1.0, 0.2)
	_hint_tw.tween_interval(seconds)
	_hint_tw.tween_property(_hint_bg, "modulate:a", 0.0, 0.4)


func _text_or_empty(key: String) -> String:
	var t := tr(key)
	return "" if t == key else t


func _process(_delta: float) -> void:
	if _staging and _tw and (Input.is_action_just_pressed("dodge") or Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("attack")):
		_tw.custom_step(60.0)   # skip: run the entrance to its end
		return
	var b := get_tree().get_first_node_in_group("boss")
	if b != _boss:
		_boss = b
		_was_engaged = false
		_alive = false
		_phase = 0
	if b == null:
		return
	var h: Variant = b.get("health")
	if h == null:
		return
	var pv: Variant = b.get("phase")
	var ph: int = pv if pv is int else 1   # some bosses keep a non-number phase
	if not _was_engaged:
		if bool(b.get("engaged")) and h.hp > 0:
			_was_engaged = true
			_alive = true
			_phase = ph
			_intro(b)
		return
	if _alive and h.hp > 0 and ph > _phase and _phase >= 1:
		_phase_shift()
	_phase = maxi(_phase, ph)
	if _alive and h.hp <= 0:
		_alive = false
		_finish()


func _set_rules(f: float) -> void:
	for r in _rules:
		r.size.x = roundf(RULE_W * f)
		r.position.x = 240.0 - roundf(RULE_W * f * 0.5)


## The entrance (combat.md 5.3 v7): the game pauses, the bars close, the camera travels to the boss, the name
## card opens with its epithet and one spoken line, the camera returns and the boss roars. Short on a retry.
func _intro(b: Node) -> void:
	var key := str(b.get("boss_name_key"))
	var game := get_node_or_null("/root/Game")
	var seen: bool = game != null and key in game.boss_intro_seen
	if game != null and not seen:
		game.boss_intro_seen.append(key)
	_name.text = tr(key)
	_epithet.text = _text_or_empty(key + "_EPITHET")
	_line.text = "" if seen else _text_or_empty(key + "_INTRO")
	_set_rules(0.0)
	if _tw:
		_tw.kill()
	if _staging:   # an entrance cut short by another: its last step, the unpause, died with the tween
		_staging = false
		get_tree().paused = false
	var cam := get_viewport().get_camera_2d()
	var pan: bool = staged and cam != null and b is Node2D and BossKit.may_engage(b) and get_tree().get_first_node_in_group("arena_gate") != null
	var home := cam.global_position if cam else Vector2.ZERO
	_tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if pan:
		_staging = true
		get_tree().paused = true
		Snd.play("boss_intro")
		var art := b.get_node_or_null("Body/Art")
		if art != null:   # the entrance pose plays through the pause
			art.process_mode = Node.PROCESS_MODE_ALWAYS
			BossKit.anim(b, "rise", 4.0, false)
		_tw.parallel().tween_property(cam, "global_position", ((b as Node2D).global_position + Vector2(0, -12)).round(), 0.6).set_trans(Tween.TRANS_SINE)
	_tw.parallel().tween_property(_top, "position:y", 0.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tw.parallel().tween_property(_bot, "position:y", 270.0 - BAR_H, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tw.parallel().tween_property(_card, "modulate:a", 1.0, 0.3).set_delay(0.15)
	_tw.parallel().tween_method(_set_rules, 0.0, 1.0, 0.55).set_delay(0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tw.tween_interval((SHORT if seen else LONG) if pan else 1.5)
	_tw.tween_property(_card, "modulate:a", 0.0, 0.4)
	_tw.parallel().tween_property(_top, "position:y", -BAR_H, 0.4)
	_tw.parallel().tween_property(_bot, "position:y", 270.0, 0.4)
	if pan:
		_tw.parallel().tween_property(cam, "global_position", home, 0.4).set_trans(Tween.TRANS_SINE)
		_tw.tween_callback(func() -> void:
			_staging = false
			get_tree().paused = false
			if is_instance_valid(b) and b.has_node("Body/Art"):
				b.get_node("Body/Art").process_mode = Node.PROCESS_MODE_INHERIT
			if is_instance_valid(b) and b is EnemyBase:
				BossKit.roar(b))
	else:
		_shake(1.5, 0.3)


func _phase_shift() -> void:
	_do_flash(Color(1.0, 0.86, 0.5), 0.5, 0.6)
	_slow(0.35, 0.3)
	_shake(3.0, 0.5)
	if _tw and _tw.is_running():
		return   # the entrance is still on screen
	_tw = create_tween()   # the bars pinch in for a beat
	_tw.tween_property(_top, "position:y", -BAR_H * 0.5, 0.15)
	_tw.parallel().tween_property(_bot, "position:y", 270.0 - BAR_H * 0.5, 0.15)
	_tw.tween_interval(0.7)
	_tw.tween_property(_top, "position:y", -BAR_H, 0.3)
	_tw.parallel().tween_property(_bot, "position:y", 270.0, 0.3)


func _finish() -> void:
	_do_flash(Color(1.0, 1.0, 1.0), 0.75, 0.9)
	_slow(0.25, 0.7)
	_shake(4.0, 0.6)


func _reduced() -> bool:
	var g := get_node_or_null("/root/Game")
	return g != null and g.get("reduce_flashes") == true


func _do_flash(col: Color, alpha: float, seconds: float) -> void:
	_flash.color = Color(col, alpha * (0.25 if _reduced() else 1.0))
	create_tween().set_ignore_time_scale(true).tween_property(_flash, "color:a", 0.0, seconds)


func _shake(px: float, seconds: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam and cam.has_method("shake"):
		cam.call("shake", px, seconds)


## A slow-motion beat in real seconds. It never fights another owner of the time scale (the cast overlay).
func _slow(time_scale: float, seconds: float) -> void:
	if DisplayServer.get_name() == "headless" or not is_equal_approx(Engine.time_scale, 1.0):
		return
	Engine.time_scale = time_scale
	_slow_scale = time_scale
	get_tree().create_timer(seconds, true, false, true).timeout.connect(_end_slow)


func _end_slow() -> void:
	if _slow_scale > 0.0 and is_equal_approx(Engine.time_scale, _slow_scale):
		Engine.time_scale = 1.0
	_slow_scale = 0.0


func _exit_tree() -> void:
	_end_slow()
	if _staging:
		get_tree().paused = false
