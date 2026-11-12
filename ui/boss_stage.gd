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


func _ready() -> void:
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


func _process(_delta: float) -> void:
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
	var ph := int(b.get("phase")) if b.get("phase") != null else 1
	if not _was_engaged:
		if bool(b.get("engaged")) and h.hp > 0:
			_was_engaged = true
			_alive = true
			_phase = ph
			_intro(tr(str(b.get("boss_name_key"))))
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


func _intro(title: String) -> void:
	_name.text = title
	_set_rules(0.0)
	if _tw:
		_tw.kill()
	_tw = create_tween()
	_tw.tween_property(_top, "position:y", 0.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tw.parallel().tween_property(_bot, "position:y", 270.0 - BAR_H, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tw.parallel().tween_property(_card, "modulate:a", 1.0, 0.3).set_delay(0.15)
	_tw.parallel().tween_method(_set_rules, 0.0, 1.0, 0.55).set_delay(0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tw.tween_interval(1.5)
	_tw.tween_property(_card, "modulate:a", 0.0, 0.4)
	_tw.parallel().tween_property(_top, "position:y", -BAR_H, 0.4)
	_tw.parallel().tween_property(_bot, "position:y", 270.0, 0.4)
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
