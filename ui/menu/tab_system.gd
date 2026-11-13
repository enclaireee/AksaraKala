extends MenuTab
## Sistem (Settings), ui.md 4.3 tab 7. Ported from the old menu: volumes, fullscreen, language, resume / title / quit
## with a confirm. The regrouped layout (Tampilan scale and shake, Aksesibilitas, "Simpan & Keluar") comes later.

const BUSES := GameSettings.BUSES

var action := ""   # "title" or "quit" while the confirm is open
var lang_btn: Button
var full_btn: Button
var _toggles := {}   # key -> [Button, Callable(-> String)]
var _modal: HBoxContainer
var _modal_lbl: Label
var _modal_yes: Button
var _first: Control


func title_key() -> String:
	return "UI_BK_TAB_SYSTEM"


func icon() -> String:
	return "system"


func build(l: Control, r: Control) -> void:
	var lv := scroll(l, Rect2(0, 0, 200, 212))
	lv.add_child(MenuBook.section(tr("UI_BK_AUDIO")))
	for b in BUSES:
		var row := HBoxContainer.new()
		lv.add_child(row)
		var lab := MenuBook.bold(tr("UI_SYS_" + b.to_upper()))
		lab.custom_minimum_size.x = 80
		row.add_child(lab)
		var sl := HSlider.new()
		sl.name = b
		sl.min_value = 0
		sl.max_value = 100
		sl.step = 5
		sl.custom_minimum_size = Vector2(110, 12)
		sl.value = load_setting("vol_" + b.to_lower(), 100)
		sl.value_changed.connect(set_volume.bind(b))
		row.add_child(sl)
		if _first == null:
			_first = sl
	lv.add_child(MenuBook.section(tr("UI_BK_DISPLAY")))
	full_btn = _button(lv, toggle_fullscreen)
	_slider_row(lv, "UI_SYS_SHAKE", 0, 100, 10, GameSettings.screenshake(), func(v: float) -> void: GameSettings.set_screenshake(int(v)))
	_toggle_row(lv, "reduce_flashes", func() -> void: GameSettings.set_reduce_flashes(not GameSettings.reduce_flashes()), func() -> String:
		return "%s: %s" % [tr("UI_SYS_REDUCE_FLASHES"), tr("UI_ON") if GameSettings.reduce_flashes() else tr("UI_OFF")])
	_toggle_row(lv, "damage_numbers", func() -> void: GameSettings.set_damage_numbers(not GameSettings.damage_numbers()), func() -> String:
		return "%s: %s" % [tr("UI_SYS_DAMAGE_NUMBERS"), tr("UI_ON") if GameSettings.damage_numbers() else tr("UI_OFF")])
	_toggle_row(lv, "cursor_size", func() -> void: GameSettings.set_cursor_size(1 if GameSettings.cursor_size() >= 2 else 2), func() -> String:
		return "%s: %dx" % [tr("UI_SYS_CURSOR_SIZE"), GameSettings.cursor_size()])
	var rv := scroll(r, Rect2(0, 0, 200, 212))
	rv.add_child(MenuBook.section(tr("UI_SYS_LANG")))
	lang_btn = _button(rv, toggle_language)
	rv.add_child(MenuBook.section(tr("UI_BK_ACCESSIBILITY")))
	_toggle_row(rv, "preset", func() -> void:
		GameSettings.set_control_preset("left_handed" if GameSettings.control_preset() == "default" else "default"), func() -> String:
		var k := "UI_SYS_PRESET_LEFT" if GameSettings.control_preset() == "left_handed" else "UI_SYS_PRESET_DEF"
		return "%s: %s" % [tr("UI_SYS_PRESET"), tr(k)])
	_toggle_row(rv, "swap_mouse", func() -> void: GameSettings.set_swap_mouse(not GameSettings.swap_mouse()), func() -> String:
		return "%s: %s" % [tr("UI_SYS_SWAP_MOUSE"), tr("UI_ON") if GameSettings.swap_mouse() else tr("UI_OFF")])
	_toggle_row(rv, "toggle_cast", func() -> void: GameSettings.set_toggle_cast(not GameSettings.toggle_cast()), func() -> String:
		return "%s: %s" % [tr("UI_SYS_TOGGLE_CAST"), tr("UI_ON") if GameSettings.toggle_cast() else tr("UI_OFF")])
	_slider_row(rv, "UI_SYS_SLOWMO", 10, 40, 5, GameSettings.slow_mo_strength(), func(v: float) -> void: GameSettings.set_slow_mo_strength(int(v)))
	_slider_row(rv, "UI_SYS_DRAWTIME", 2.5, 5.0, 0.5, GameSettings.draw_time(), func(v: float) -> void: GameSettings.set_draw_time(v))
	_toggle_row(rv, "guide_always", func() -> void: GameSettings.set_guide_always_on(not GameSettings.guide_always_on()), func() -> String:
		return "%s: %s" % [tr("UI_SYS_GUIDE"), tr("UI_ON") if GameSettings.guide_always_on() else tr("UI_OFF")])
	_toggle_row(rv, "gentle_combat", func() -> void: GameSettings.set_gentle_combat(not GameSettings.gentle_combat()), func() -> String:
		return "%s: %s" % [tr("UI_SYS_GENTLE"), tr("UI_ON") if GameSettings.gentle_combat() else tr("UI_OFF")])
	_toggle_row(rv, "drawing_assist", func() -> void: GameSettings.set_drawing_assist(not GameSettings.drawing_assist()), func() -> String:
		return "%s: %s" % [tr("UI_SYS_DRAW_ASSIST"), tr("UI_ON") if GameSettings.drawing_assist() else tr("UI_OFF")])
	rv.add_child(MenuBook.section(tr("UI_BK_GAME")))
	_button(rv, menu.close).text = tr("UI_SYS_RESUME")
	_button(rv, ask.bind("title")).text = tr("UI_SYS_TITLE")
	_button(rv, ask.bind("quit")).text = tr("UI_SYS_QUIT")
	_modal_lbl = MenuBook.text("", MenuBook.INK_HEAD, true)
	_modal_lbl.custom_minimum_size.x = 200
	_modal_lbl.visible = false
	rv.add_child(_modal_lbl)
	_modal = HBoxContainer.new()
	_modal.visible = false
	rv.add_child(_modal)
	_modal_yes = MenuBook.small_button(tr("UI_YES"))
	_modal_yes.pressed.connect(_do)
	_modal.add_child(_modal_yes)
	var no := MenuBook.small_button(tr("UI_CANCEL"))
	no.pressed.connect(cancel)
	_modal.add_child(no)
	apply_settings()


func _button(box: Control, cb: Callable) -> Button:
	var b := MenuBook.row_button(16)
	b.add_theme_color_override("font_color", MenuBook.INK)
	b.pressed.connect(cb)
	box.add_child(b)
	return b


func _toggle_row(box: Control, key: String, cb: Callable, label_fn: Callable) -> void:
	var b := _button(box, func() -> void:
		cb.call()
		refresh())
	_toggles[key] = [b, label_fn]


func _slider_row(box: Control, key: String, mn: float, mx: float, step: float, val: float, cb: Callable) -> void:
	var row := HBoxContainer.new()
	box.add_child(row)
	var lab := MenuBook.bold(tr(key))
	lab.custom_minimum_size.x = 88
	row.add_child(lab)
	var sl := HSlider.new()
	sl.min_value = mn
	sl.max_value = mx
	sl.step = step
	sl.value = val
	sl.custom_minimum_size = Vector2(102, 12)
	sl.value_changed.connect(cb)
	row.add_child(sl)


func refresh() -> void:
	lang_btn.text = "%s: %s" % [tr("UI_SYS_LANG"), GameSettings.language_name()]
	full_btn.text = "%s: %s" % [tr("UI_SYS_FULLSCREEN"), tr("UI_ON") if is_fullscreen() else tr("UI_OFF")]
	for entry in _toggles.values():
		(entry[0] as Button).text = (entry[1] as Callable).call()


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
	if _modal:
		_modal.visible = false
		_modal_lbl.visible = false


func ask(a: String) -> void:
	action = a
	_modal_lbl.text = tr("UI_SYS_CONFIRM_" + a.to_upper())
	_modal_lbl.visible = true
	_modal.visible = true
	_modal_yes.grab_focus()
	menu.update_hints()


func _do() -> void:
	var a := action
	cancel()
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


## Volumes from user://settings.cfg; the Music and SFX buses are created on first use.
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
