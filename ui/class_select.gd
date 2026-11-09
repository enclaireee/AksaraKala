extends Control
## Class choice, Elden-style (ui.md 3b): list left, animated figure on a pedestal centre, framed details right,
## hints at the bottom. Confirm opens a small framed dialog. The old save is replaced only on confirm (_go).

const STATS := ["vit", "end", "str", "dex", "spi"]
const FRAMES := 6
const FPS := 6.0
const FIG := Vector2(96, 128)
const FIG_POS := Vector2(157, 74)   # feet (frame y 122) land on the pedestal
const STAT_MAX := 10

var cards: Array[Control] = []   # the list entries, one per class
var _confirm: Control
var _dialog: Control
var _no: Button
var _confirm_lbl: Label
var _chosen: ClassData
var _classes: Array[ClassData] = []
var _list: VBoxContainer
var _stage: Control
var _fig: Sprite2D
var _fig_t := 0.0
var _shown := ""
var _info: Control
var _name: Label
var _desc: Label
var _role: Label
var _bars := {}
var _w_icon: TextureRect
var _w_name: Label
var _p_name: Label
var _p_text: Label
var _hints: Label
var _fade: ColorRect
var _in_confirm := false


func _ready() -> void:
	Snd.music("select", 2.0)
	var sky := UIFx.rect_tex("title_sky", Vector2.ZERO)
	sky.modulate = Color(0.45, 0.45, 0.5)
	add_child(sky)
	_stage = Control.new()   # figure, cone, pedestal, particles
	_stage.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_stage)
	_stage.add_child(UIFx.rect_tex("light_cone", Vector2(157, 36)))
	_stage.add_child(UIFx.rect_tex("pedestal", Vector2(173, 190)))
	_fig = null
	var fog := CPUParticles2D.new()   # low fog / ink motes at the feet
	fog.texture = UIFx.tex("ink_mote")
	fog.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fog.position = Vector2(205, 196)
	fog.amount = 14
	fog.lifetime = 4.0
	fog.preprocess = 4.0
	fog.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog.emission_rect_extents = Vector2(34, 3)
	fog.direction = Vector2.UP
	fog.spread = 40.0
	fog.gravity = Vector2.ZERO
	fog.initial_velocity_min = 3.0
	fog.initial_velocity_max = 9.0
	fog.scale_amount_min = 1.0
	fog.scale_amount_max = 2.5
	var ramp := Gradient.new()
	ramp.set_color(0, Color(0.8, 0.75, 0.9, 0.0))
	ramp.set_color(1, Color(0.8, 0.75, 0.9, 0.0))
	ramp.add_point(0.3, Color(0.8, 0.75, 0.9, 0.35))
	fog.color_ramp = ramp
	_stage.add_child(fog)
	add_child(UIFx.rect_tex("vignette", Vector2.ZERO))

	_list = VBoxContainer.new()
	_list.position = Vector2(16, 92)
	_list.size = Vector2(120, 80)
	_list.add_theme_constant_override("separation", 2)
	add_child(_list)
	for id in ClassData.IDS:
		var c := ClassData.by_id(id)
		if c:
			_classes.append(c)
			_entry(c)

	_build_info()
	_hints = UIFx.text("", "body", UIFx.DIM)
	_hints.position = Vector2(0, 254)
	_hints.size = Vector2(480, 9)
	_hints.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_hints)
	_hints.text = "Enter  %s      Esc  %s" % [tr("UI_CHOOSE"), tr("UI_BACK")]

	_build_confirm()
	_fade = UIFx.cover(self)
	_fade.color.a = 1.0
	create_tween().tween_property(_fade, "color:a", 0.0, 0.35)
	UIFx.rise_in(_list, 6.0, 0.3)
	UIFx.rise_in(_info, 6.0, 0.3)
	_show_cards()


func _entry(c: ClassData) -> void:
	var b := LozengeButton.new(tr(c.title), 10)
	b.focus_entered.connect(_preview.bind(c))
	b.pressed.connect(_ask.bind(c))
	_list.add_child(b)
	cards.append(b)


func _ink_panel(pos: Vector2, sz: Vector2) -> Panel:
	var p := Panel.new()   # the dark-scene card (ui.md 0): same ink surface as the in-game UI
	p.add_theme_stylebox_override("panel", UIFx.ink_box())
	p.position = pos
	p.size = sz
	p.mouse_filter = MOUSE_FILTER_IGNORE
	return p


## Right card, on the 2 px grid: name (heading) / role (caps) / rule / description / 5 stats / weapon / passive.
func _build_info() -> void:
	_info = _ink_panel(Vector2(296, 32), Vector2(176, 214))
	add_child(_info)
	var x := 10.0
	var w := 156.0
	_name = UIFx.text("", "head", UIFx.GOLD_HI)
	_name.position = Vector2(x, 8)
	_name.size = Vector2(w, 13)
	_info.add_child(_name)
	_role = UIFx.text("", "label", UIFx.LABEL_COL)
	_role.position = Vector2(x, 24)
	_role.size = Vector2(w, 9)
	_info.add_child(_role)
	var rule := ColorRect.new()
	rule.color = UIFx.LINE_DIM
	rule.position = Vector2(x, 37)
	rule.size = Vector2(w, 1)
	_info.add_child(rule)
	_desc = UIFx.text("", "body", UIFx.CREAM)
	_desc.position = Vector2(x, 42)
	_desc.size = Vector2(w, 29)
	_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc.add_theme_constant_override("line_spacing", 1)
	_info.add_child(_desc)
	var y := 78.0
	for s: String in STATS:
		var l := UIFx.text(tr("UI_STAT_" + s.to_upper()), "body", UIFx.DIM)
		l.position = Vector2(x, y - 1)
		l.size = Vector2(56, 9)
		_info.add_child(l)
		var bar := StatBar.new()
		bar.position = Vector2(x + 58, y + 1)
		_info.add_child(bar)
		_bars[s] = bar
		y += 10.0
	y += 6.0   # 134: weapon well with its caps label and name beside it
	var slot := UIFx.rect_tex("ink_slot", Vector2(x, y))
	_info.add_child(slot)
	_w_icon = TextureRect.new()
	_w_icon.position = Vector2(2, 2)
	_w_icon.size = Vector2(16, 16)
	_w_icon.mouse_filter = MOUSE_FILTER_IGNORE
	slot.add_child(_w_icon)
	var w_lbl := UIFx.text(tr("UI_WEAPON"), "label", UIFx.LABEL_COL)
	w_lbl.position = Vector2(x + 26, y + 1)
	w_lbl.size = Vector2(w - 26, 9)
	_info.add_child(w_lbl)
	_w_name = UIFx.text("", "body", UIFx.CREAM)
	_w_name.position = Vector2(x + 26, y + 11)
	_w_name.size = Vector2(w - 26, 9)
	_info.add_child(_w_name)
	y += 28.0   # 162: passive
	_p_name = UIFx.text("", "label", UIFx.ACCENT)
	_p_name.position = Vector2(x, y)
	_p_name.size = Vector2(w, 9)
	_info.add_child(_p_name)
	_p_text = UIFx.text("", "body", UIFx.CREAM)
	_p_text.position = Vector2(x, y + 12)
	_p_text.size = Vector2(w, 39)
	_p_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_p_text.add_theme_constant_override("line_spacing", 1)
	_info.add_child(_p_text)


func _build_confirm() -> void:
	_confirm = Control.new()   # dimmer plus a small ink dialog
	_confirm.set_anchors_preset(PRESET_FULL_RECT)
	_confirm.visible = false
	_confirm.z_index = 10
	add_child(_confirm)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(PRESET_FULL_RECT)
	_confirm.add_child(dim)
	_dialog = _ink_panel(Vector2(140, 100), Vector2(200, 64))
	_confirm.add_child(_dialog)
	_confirm_lbl = UIFx.text("", "head", UIFx.GOLD_HI)
	_confirm_lbl.position = Vector2(8, 10)
	_confirm_lbl.size = Vector2(184, 13)
	_confirm_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_confirm_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_dialog.add_child(_confirm_lbl)
	var row := HBoxContainer.new()
	row.position = Vector2(20, 34)
	row.size = Vector2(160, 18)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	_dialog.add_child(row)
	var yes := LozengeButton.new(tr("UI_YES"), 10)
	yes.pressed.connect(_go)
	yes.custom_minimum_size.x = 76
	row.add_child(yes)
	_no = LozengeButton.new(tr("UI_CANCEL"), 10)
	_no.pressed.connect(_show_cards)
	_no.custom_minimum_size.x = 76
	row.add_child(_no)


func _process(delta: float) -> void:
	if _fig == null:
		return
	_fig_t += delta
	_fig.frame = int(_fig_t * FPS) % FRAMES


## Shows class c on the stage: the old figure dissolves into ink motes, the new one fades up.
func _preview(c: ClassData) -> void:
	if c.id == _shown:
		return
	var first := _shown == ""
	_shown = c.id
	if _fig:
		var old := _fig
		UIFx.burst(_stage, Rect2(old.position + Vector2(28, 20), Vector2(40, 100)), 30, 0.5)
		var d := create_tween().set_parallel()
		d.tween_property(old, "modulate:a", 0.0, 0.3)
		d.tween_property(old, "position:y", old.position.y - 8, 0.3)
		d.chain().tween_callback(old.queue_free)
	_fig = Sprite2D.new()
	_fig.texture = load("res://assets/art/portraits/class_%s.png" % c.id)
	_fig.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_fig.hframes = FRAMES
	_fig.centered = false
	_fig.position = FIG_POS
	_fig.modulate.a = 0.0
	_stage.add_child(_fig)
	_stage.move_child(_fig, 2)   # above cone and pedestal... below the fog
	create_tween().tween_property(_fig, "modulate:a", 1.0, 0.0 if first else 0.3).set_delay(0.0 if first else 0.15)
	_fill(c)


func _fill(c: ClassData) -> void:
	_name.text = tr(c.title)
	_role.text = tr(c.title.replace("_NAME", "_ROLE"))
	_desc.text = tr(c.description)
	for s: String in STATS:
		_bars[s].set_value(int(c.stats.get(s, 0)))
	var w := ItemData.by_id(c.start_weapon)
	_w_icon.texture = w.icon if w else null
	_w_name.text = tr(w.title) if w else c.start_weapon
	_p_name.text = tr(c.passive)
	_p_text.text = tr(c.passive_text)


func _show_cards() -> void:
	_in_confirm = false
	_confirm.visible = false
	_list.mouse_filter = MOUSE_FILTER_PASS
	for b in cards:
		(b as Button).disabled = false
	if cards.size() > 0:
		var i := maxi(0, _classes.find(_chosen))
		cards[i].grab_focus()
		_preview(_classes[i])


func _ask(c: ClassData) -> void:
	_chosen = c
	_in_confirm = true
	_confirm_lbl.text = tr("UI_CHOOSE_Q") % tr(c.title)
	for b in cards:
		(b as Button).disabled = true
	_confirm.visible = true
	UIFx.rise_in(_dialog, 4.0, 0.15)
	_no.grab_focus()   # Cancel first: a stray Enter never commits


func _go() -> void:
	get_node("/root/Game").new_game(_chosen)
	get_node("/root/Events").class_chosen.emit(_chosen.id)
	get_node("/root/Zones").start_new_game()


func _back() -> void:
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 1.0, 0.25)
	tw.tween_callback(func() -> void: get_tree().change_scene_to_file("res://ui/title.tscn"))


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if _in_confirm:
			_show_cards()
		else:
			_back()


## Ten-segment stat bar that tweens to its value.
class StatBar extends Control:
	var shown := 0.0
	var _target := 0
	var _tw: Tween

	func _init() -> void:
		custom_minimum_size = Vector2(88, 6)
		size = Vector2(88, 6)
		mouse_filter = MOUSE_FILTER_IGNORE

	func set_value(v: int) -> void:
		_target = v
		if _tw:
			_tw.kill()
		_tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		_tw.tween_method(func(x: float) -> void: shown = x; queue_redraw(), shown, float(v), 0.35)

	func _draw() -> void:
		for i in 10:   # 10 pips, 6 px on a 7 px pitch: empty = hairline, filled = gold with a lit top row
			var r := Rect2(i * 7, 1, 6, 5)
			draw_rect(r, UIFx.LINE_DIM)
			var f := clampf(shown - i, 0.0, 1.0)
			if f > 0.0:
				var fw := roundf(6.0 * f)
				draw_rect(Rect2(r.position, Vector2(fw, 5)), UIFx.ACCENT)
				draw_rect(Rect2(r.position, Vector2(fw, 1)), Color("FFECB4"))
		draw_string(UIFx.body_font(), Vector2(74, 6), str(_target), HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY, UIFx.CREAM)
