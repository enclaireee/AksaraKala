extends MenuTab
## Sistem (Settings), ui.md 4.3 tab 7: volumes, display, accessibility & assists, resume / title / quit
## with live slider readouts, focus highlights, danger styling, and a centered confirm modal.

const BUSES := GameSettings.BUSES
const LABEL_W := 96   # one label column for toggles and sliders (text starts at x 6, like a row button's text)
const SIDE := 6       # left / right inner margin shared by both row kinds

var _label_w := LABEL_W
var action := ""   # "title" or "quit" while the confirm is open
var lang_btn: Button
var full_btn: Button
var _toggles := {}   # key -> [Button, Callable(-> String)]
var _modal_overlay: Control
var _modal_lbl: Label
var _modal_yes: Button
var _first: Control


func title_key() -> String:
	return "UI_BK_TAB_SYSTEM"


func icon() -> String:
	return "system"


func build(l: Control, r: Control) -> void:
	_label_w = LABEL_W
	for k in ["UI_SYS_MASTER", "UI_SYS_MUSIC", "UI_SYS_SFX", "UI_SYS_AMBIENCE", "UI_SYS_SHAKE", "UI_SYS_SLOWMO", "UI_SYS_DRAWTIME"]:
		_label_w = maxi(_label_w, ceili(MenuBook.text(tr(k)).get_minimum_size().x) + 2)   # no slider label touches its slider, in either language
	var lv := scroll(l, Rect2(0, 0, 200, 208))
	lv.add_theme_constant_override("separation", 0)   # 16 px rows touch: the row pitch for interactive rows
	lv.add_child(MenuBook.section(tr("UI_BK_AUDIO"), 190))
	for b in BUSES:
		_slider_row(lv, "UI_SYS_" + b.to_upper(), 0, 100, 5, float(load_setting("vol_" + b.to_lower(), 100)),
				set_volume.bind(b), func(v: float) -> String: return "%d%%" % int(v), b)
	_gap(lv)
	lv.add_child(MenuBook.section(tr("UI_BK_DISPLAY"), 190))
	full_btn = _button(lv, toggle_fullscreen)
	_slider_row(lv, "UI_SYS_SHAKE", 0, 100, 10, GameSettings.screenshake(),
			func(v: float) -> void: GameSettings.set_screenshake(int(v)),
			func(v: float) -> String: return "%d%%" % int(v))
	_toggle_row(lv, "reduce_flashes", func() -> void: GameSettings.set_reduce_flashes(not GameSettings.reduce_flashes()), func() -> String:
		return "%s: %s" % [tr("UI_SYS_REDUCE_FLASHES"), tr("UI_ON") if GameSettings.reduce_flashes() else tr("UI_OFF")])
	_toggle_row(lv, "damage_numbers", func() -> void: GameSettings.set_damage_numbers(not GameSettings.damage_numbers()), func() -> String:
		return "%s: %s" % [tr("UI_SYS_DAMAGE_NUMBERS"), tr("UI_ON") if GameSettings.damage_numbers() else tr("UI_OFF")])
	_toggle_row(lv, "cursor_size", func() -> void: GameSettings.set_cursor_size(1 if GameSettings.cursor_size() >= 2 else 2), func() -> String:
		return "%s: %dx" % [tr("UI_SYS_CURSOR_SIZE"), GameSettings.cursor_size()])

	var rv := scroll(r, Rect2(0, 0, 200, 208))
	rv.add_theme_constant_override("separation", 0)
	rv.add_child(MenuBook.section(tr("UI_SYS_LANG"), 190))
	lang_btn = _button(rv, toggle_language)
	_gap(rv)
	rv.add_child(MenuBook.section(tr("UI_BK_ACCESSIBILITY"), 190))
	_toggle_row(rv, "preset", func() -> void:
		GameSettings.set_control_preset("left_handed" if GameSettings.control_preset() == "default" else "default"), func() -> String:
		var k := "UI_SYS_PRESET_LEFT" if GameSettings.control_preset() == "left_handed" else "UI_SYS_PRESET_DEF"
		return "%s: %s" % [tr("UI_SYS_PRESET"), tr(k)])
	_toggle_row(rv, "swap_mouse", func() -> void: GameSettings.set_swap_mouse(not GameSettings.swap_mouse()), func() -> String:
		return "%s: %s" % [tr("UI_SYS_SWAP_MOUSE"), tr("UI_ON") if GameSettings.swap_mouse() else tr("UI_OFF")])
	_toggle_row(rv, "toggle_cast", func() -> void: GameSettings.set_toggle_cast(not GameSettings.toggle_cast()), func() -> String:
		return "%s: %s" % [tr("UI_SYS_TOGGLE_CAST"), tr("UI_ON") if GameSettings.toggle_cast() else tr("UI_OFF")])
	_slider_row(rv, "UI_SYS_SLOWMO", 10, 40, 5, GameSettings.slow_mo_strength(),
			func(v: float) -> void: GameSettings.set_slow_mo_strength(int(v)),
			func(v: float) -> String: return "%d%%" % int(v))
	_slider_row(rv, "UI_SYS_DRAWTIME", 2.5, 5.0, 0.5, GameSettings.draw_time(),
			func(v: float) -> void: GameSettings.set_draw_time(v),
			func(v: float) -> String: return "%.1fs" % v)
	_toggle_row(rv, "guide_always", func() -> void: GameSettings.set_guide_always_on(not GameSettings.guide_always_on()), func() -> String:
		return "%s: %s" % [tr("UI_SYS_GUIDE"), tr("UI_ON") if GameSettings.guide_always_on() else tr("UI_OFF")])
	_toggle_row(rv, "gentle_combat", func() -> void: GameSettings.set_gentle_combat(not GameSettings.gentle_combat()), func() -> String:
		return "%s: %s" % [tr("UI_SYS_GENTLE"), tr("UI_ON") if GameSettings.gentle_combat() else tr("UI_OFF")])
	_toggle_row(rv, "drawing_assist", func() -> void: GameSettings.set_drawing_assist(not GameSettings.drawing_assist()), func() -> String:
		return "%s: %s" % [tr("UI_SYS_DRAW_ASSIST"), tr("UI_ON") if GameSettings.drawing_assist() else tr("UI_OFF")])
	_gap(rv)
	rv.add_child(MenuBook.section(tr("UI_BK_GAME"), 190))
	_toggle_row(rv, "skip_tutorials", func() -> void: GameSettings.set_skip_tutorials(not GameSettings.skip_tutorials()), func() -> String:
		return "%s: %s" % [tr("UI_SYS_SKIP_TUT"), tr("UI_ON") if GameSettings.skip_tutorials() else tr("UI_OFF")])
	_toggle_row(rv, "check_updates", func() -> void: GameSettings.set_check_updates(not GameSettings.check_updates()), func() -> String:
		return "%s: %s" % [tr("UI_SYS_UPDATES"), tr("UI_ON") if GameSettings.check_updates() else tr("UI_OFF")])
	_button(rv, menu.close).text = tr("UI_SYS_RESUME")
	var tb := _button(rv, ask.bind("title"))
	tb.text = tr("UI_SYS_TITLE")
	_danger_style(tb)
	var qb := _button(rv, ask.bind("quit"))
	qb.text = tr("UI_SYS_QUIT")
	_danger_style(qb)

	_build_modal()
	apply_settings()


func _build_modal() -> void:
	_modal_overlay = Control.new()
	_modal_overlay.position = Vector2.ZERO
	_modal_overlay.size = Vector2(456, 228)
	_modal_overlay.visible = false
	_modal_overlay.z_index = 10
	add_child(_modal_overlay)
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.06, 0.72)
	dim.set_anchors_preset(PRESET_FULL_RECT)
	_modal_overlay.add_child(dim)
	var card := Panel.new()
	card.add_theme_stylebox_override("panel", UIFx.ink_box(8))
	card.position = Vector2(118, 68)
	card.size = Vector2(220, 88)
	_modal_overlay.add_child(card)
	_modal_lbl = MenuBook.text("", MenuBook.INK_HEAD, true)
	_modal_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_modal_lbl.position = Vector2(12, 12)
	_modal_lbl.size = Vector2(196, 36)
	card.add_child(_modal_lbl)
	var row := HBoxContainer.new()
	row.position = Vector2(12, 56)
	row.size = Vector2(196, 18)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	card.add_child(row)
	_modal_yes = MenuBook.small_button(tr("UI_YES"))
	_modal_yes.custom_minimum_size.x = 68
	_modal_yes.add_theme_color_override("font_hover_color", MenuBook.WAX)
	_modal_yes.add_theme_color_override("font_focus_color", MenuBook.WAX)
	_modal_yes.pressed.connect(_do)
	row.add_child(_modal_yes)
	var no := MenuBook.small_button(tr("UI_CANCEL"))
	no.custom_minimum_size.x = 68
	no.pressed.connect(cancel)
	row.add_child(no)


func _danger_style(b: Button) -> void:
	for c in ["font_hover_color", "font_focus_color", "font_pressed_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(c, MenuBook.WAX)


func _gap(box: Control) -> void:
	var g := Control.new()
	g.custom_minimum_size.y = UIFx.GAP_S
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(g)


## "Label: value" on a row button: the label stays the button text (left column), the value sits in a right column
## that lines up with the slider readouts.
func _set_toggle(b: Button, t: String) -> void:
	var i := t.rfind(": ")
	var v: Label = b.get_meta("val") if b.has_meta("val") else null
	if i < 0:
		b.text = t
		if v:
			v.text = ""
		return
	if v == null:
		v = MenuBook.text("", MenuBook.INK_DIM)
		v.set_anchors_preset(Control.PRESET_FULL_RECT)
		v.offset_right = -SIDE
		v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		v.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		b.add_child(v)
		b.set_meta("val", v)
	b.text = t.left(i)
	v.text = t.substr(i + 2)


func _button(box: Control, cb: Callable) -> Button:
	var b := MenuBook.row_button(16)
	b.pressed.connect(cb)
	box.add_child(b)
	return b


func _toggle_row(box: Control, key: String, cb: Callable, label_fn: Callable) -> void:
	var b := _button(box, func() -> void:
		cb.call()
		refresh())
	_toggles[key] = [b, label_fn]


func _slider_row(box: Control, key: String, mn: float, mx: float, step: float, val: float, cb: Callable, fmt: Callable, node_name := "") -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row.custom_minimum_size.y = 16
	box.add_child(row)
	var pad := Control.new()
	pad.custom_minimum_size.x = SIDE - 4
	row.add_child(pad)
	var lab := MenuBook.text(tr(key), MenuBook.INK)
	lab.custom_minimum_size.x = _label_w
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(lab)
	var sl := HSlider.new()
	if node_name != "":
		sl.name = node_name
	sl.min_value = mn
	sl.max_value = mx
	sl.step = step
	sl.value = val
	sl.custom_minimum_size = Vector2(30, 12)
	sl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(sl)
	var num_lbl := MenuBook.num(fmt.call(val), MenuBook.INK_DIM)
	num_lbl.custom_minimum_size.x = 26
	num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	num_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(num_lbl)
	var rpad := Control.new()
	rpad.custom_minimum_size.x = SIDE - 4
	row.add_child(rpad)
	sl.value_changed.connect(func(v: float) -> void:
		cb.call(v)
		num_lbl.text = fmt.call(v))
	sl.focus_entered.connect(func() -> void: lab.add_theme_color_override("font_color", MenuBook.ACCENT))
	sl.focus_exited.connect(func() -> void: lab.add_theme_color_override("font_color", MenuBook.INK))
	sl.mouse_entered.connect(func() -> void: sl.grab_focus())
	if _first == null:
		_first = sl


func refresh() -> void:
	_set_toggle(lang_btn, "%s: %s" % [tr("UI_SYS_LANG"), GameSettings.language_name()])
	_set_toggle(full_btn, "%s: %s" % [tr("UI_SYS_FULLSCREEN"), tr("UI_ON") if is_fullscreen() else tr("UI_OFF")])
	for entry in _toggles.values():
		_set_toggle(entry[0], (entry[1] as Callable).call())


func focus_first() -> void:
	if _first:
		_first.grab_focus()


func hints() -> Array:
	if is_modal():
		return [["Enter", "UI_BK_HINT_CONFIRM"], ["Esc", "UI_BK_HINT_BACK"]]
	return [["@updown", "UI_BK_HINT_SELECT"], ["Enter", "UI_BK_HINT_CONFIRM"]]


func is_modal() -> bool:
	return action != ""


func back() -> bool:
	if action == "":
		return false
	cancel()
	return true


func cancel() -> void:
	action = ""
	if _modal_overlay:
		_modal_overlay.visible = false


func ask(a: String) -> void:
	action = a
	_modal_lbl.text = tr("UI_SYS_CONFIRM_" + a.to_upper())
	_modal_overlay.visible = true
	_modal_yes.grab_focus()
	menu.update_hints()


func _do() -> void:
	var a := action
	cancel()
	if game and not game.in_memory():
		game.save_game()
	menu.close()
	if a == "title":
		get_tree().change_scene_to_file("res://ui/title.tscn")
	elif a == "quit":
		get_tree().quit()


func is_fullscreen() -> bool:
	return GameSettings.is_fullscreen()


func load_setting(key: String, default: Variant) -> Variant:
	return GameSettings.load_value(key, default)


func save_setting(key: String, v: Variant) -> void:
	GameSettings.save_value(key, v)


func apply_settings() -> void:
	GameSettings.apply_volumes()


func apply_volume(bus: String, pct: float) -> void:
	GameSettings.apply_volume(bus, pct)


func set_volume(v: float, bus: String) -> void:
	GameSettings.set_volume(bus, v)


func toggle_language() -> void:
	GameSettings.toggle_language()
	game.changed.emit()


func toggle_fullscreen() -> void:
	GameSettings.set_fullscreen(not is_fullscreen())
	refresh()
