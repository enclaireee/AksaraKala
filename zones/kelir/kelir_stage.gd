class_name KelirStage extends CanvasLayer
## The show around every Kelir memory (.docs/revamp_plan.md 1): curtain-up title card, one objective pill with a keycap,
## an optional danger meter, and a warm flash for the closing tableau. KelirMemory owns one. It never pauses or blocks
## the game; the memory decides when the stand-in may move.

const VEIL := Color("0A0606")
const PILL_Y := 232.0
const METER_W := 120.0

var _veil: ColorRect
var _title: Label
var _sub: Label
var _flash: ColorRect
var _pill: PanelContainer
var _key: Label
var _lbl: Label
var _meter: Control
var _meter_lbl: Label
var _meter_ratio := 1.0
var _meter_on := false
var _t := 0.0


func _init() -> void:
	layer = 7


func _ready() -> void:
	_flash = ColorRect.new()
	_flash.color = Color("FFE6A8")
	_flash.modulate.a = 0.0
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash)

	_pill = PanelContainer.new()
	_pill.add_theme_stylebox_override("panel", UIFx.ink_box(4))
	_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pill.add_child(row)
	_key = UIFx.text("", "label", UIFx.HEAD)
	_key.add_theme_stylebox_override("normal", UIFx.box("keycap", 2.0))
	row.add_child(_key)
	_lbl = UIFx.text("", "body", UIFx.CREAM)
	row.add_child(_lbl)
	_pill.modulate.a = 0.0
	add_child(_pill)

	_meter = Control.new()
	_meter.size = Vector2(METER_W, 12)
	_meter.position = Vector2(round((480.0 - METER_W) / 2.0), 16)
	_meter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_meter.draw.connect(_draw_meter)
	_meter.visible = false
	add_child(_meter)
	_meter_lbl = UIFx.text("", "label", UIFx.WARM)
	_meter_lbl.position = Vector2(0, -10)
	_meter.add_child(_meter_lbl)

	_veil = ColorRect.new()
	_veil.color = VEIL
	_veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_veil)
	_title = UIFx.text("", "display", UIFx.HEAD)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.set_anchors_preset(Control.PRESET_FULL_RECT)
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.modulate.a = 0.0
	add_child(_title)
	_sub = UIFx.text("", "label", UIFx.WARM)
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub.set_anchors_preset(Control.PRESET_FULL_RECT)
	_sub.position.y = 22.0
	_sub.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_sub.modulate.a = 0.0
	add_child(_sub)


func _process(delta: float) -> void:
	_t += delta
	if _meter_on:
		_meter.queue_redraw()


## Black screen, the title and a caps line fade in, hold, then the veil lifts. Returns when the cloth is visible.
func curtain_up(title: String, sub: String) -> void:
	_veil.modulate.a = 1.0
	_title.text = title
	_sub.text = sub
	var tw := create_tween()
	tw.tween_property(_title, "modulate:a", 1.0, 0.5)
	tw.parallel().tween_property(_sub, "modulate:a", 1.0, 0.5).set_delay(0.25)
	tw.tween_interval(1.1)
	tw.tween_property(_title, "modulate:a", 0.0, 0.35)
	tw.parallel().tween_property(_sub, "modulate:a", 0.0, 0.35)
	tw.tween_property(_veil, "modulate:a", 0.0, 0.7)
	await tw.finished


## One line at the bottom: a keycap (an InputMap action, "" for none) and a body line. `text` may hold {key}.
func objective(text: String, action := "") -> void:
	var key := ""
	if action != "":
		var g := get_node_or_null("/root/Game")
		key = g.key_name(action) if g and g.has_method("key_name") else action
	_key.visible = key != ""
	_key.text = key
	_lbl.text = text.replace("{key}", key)
	_pill.reset_size()
	_pill.position = Vector2(round((480.0 - _pill.size.x) / 2.0), PILL_Y)
	var tw := create_tween()
	tw.tween_property(_pill, "modulate:a", 1.0, 0.25)


func clear_objective() -> void:
	var tw := create_tween()
	tw.tween_property(_pill, "modulate:a", 0.0, 0.25)


## Danger meter at the top: `ratio` 1 = far, 0 = touching.
func set_meter(text: String, ratio: float) -> void:
	_meter_on = true
	_meter.visible = true
	_meter_lbl.text = text
	_meter_ratio = clampf(ratio, 0.0, 1.0)


func hide_meter() -> void:
	_meter_on = false
	_meter.visible = false


## A warm flash (a lamp catching, the tableau). `amount` 0..1.
func flash(amount := 0.5, secs := 0.5) -> void:
	_flash.modulate.a = amount
	create_tween().tween_property(_flash, "modulate:a", 0.0, secs)


func _draw_meter() -> void:
	var danger := 1.0 - _meter_ratio
	var col := UIFx.WARM.lerp(UIFx.DANGER, clampf(danger * 1.6 - 0.2, 0.0, 1.0))
	_meter.draw_rect(Rect2(0, 0, METER_W, 5), UIFx.LACQUER)
	_meter.draw_rect(Rect2(1, 1, METER_W - 2, 3), UIFx.NIGHT_HI)
	var w := (METER_W - 2.0) * _meter_ratio
	_meter.draw_rect(Rect2(1, 1, w, 3), col)
	if danger > 0.7 and int(_t * 6.0) % 2 == 0:
		_meter.draw_rect(Rect2(0, 0, METER_W, 5), UIFx.DANGER, false, 1.0)
