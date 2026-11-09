extends MenuTab
## Sistem (Settings), ui.md 4.3 tab 7. Ported from the old menu: volumes, fullscreen, language, resume / title / quit
## with a confirm. The regrouped layout (Tampilan scale and shake, Aksesibilitas, "Simpan & Keluar") comes later.

const BUSES := GameSettings.BUSES

var action := ""   # "title" or "quit" while the confirm is open
var lang_btn: Button
var full_btn: Button
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
	var rv := scroll(r, Rect2(0, 0, 200, 212))
	rv.add_child(MenuBook.section(tr("UI_SYS_LANG")))
	lang_btn = _button(rv, toggle_language)
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


func refresh() -> void:
	lang_btn.text = "%s: %s" % [tr("UI_SYS_LANG"), GameSettings.language_name()]
	full_btn.text = "%s: %s" % [tr("UI_SYS_FULLSCREEN"), tr("UI_ON") if is_fullscreen() else tr("UI_OFF")]


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
