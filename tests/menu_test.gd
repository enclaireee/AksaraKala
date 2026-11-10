extends SceneTree
## Esc menu (ui.md 3): opens and pauses on `pause`, closes on `pause`, Q/E cycle the seven tabs, the language toggle persists.

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	await run()
	quit(1 if fails > 0 else 0)


func key(code: Key, action := "") -> void:
	var e := InputEventKey.new()
	e.physical_keycode = code
	e.keycode = code
	e.pressed = true
	Input.parse_input_event(e)
	await process_frame
	await process_frame


func run() -> void:
	var game := root.get_node("Game")
	game.save_path = "user://test_menu.json"
	game._reset()
	var ui: Node = load("res://ui/game_ui.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	var menu: GameMenu = ui.get_node("Menu")
	var settings := "user://test_menu_settings.cfg"
	menu.TitleScript.settings_path = settings
	await key(KEY_ESCAPE)
	check(menu.visible and paused, "Esc opens the menu and pauses")
	check(menu._tabs.get_tab_count() == 7, "seven tabs, got %d" % menu._tabs.get_tab_count())
	var seen := []
	for i in 7:
		seen.append(menu._tabs.current_tab)
		await key(KEY_E)
	check(seen == [0, 1, 2, 3, 4, 5, 6] and menu._tabs.current_tab == 0, "E cycles all tabs: %s" % str(seen))
	await key(KEY_Q)
	check(menu._tabs.current_tab == 6, "Q goes back (wraps to System)")
	# modal first: Esc dismisses it, the next Esc closes the menu
	var sys: MenuTab = menu.tab(6)
	sys.ask("quit")
	await key(KEY_ESCAPE)
	check(menu.visible and not sys.is_modal(), "first Esc dismisses the modal")
	# language toggle persists and updates the TranslationServer
	TranslationServer.set_locale("id")
	sys.toggle_language()
	check(TranslationServer.get_locale().begins_with("en"), "toggle switches the locale to en")
	var cf := ConfigFile.new()
	cf.load(settings)
	check(cf.get_value("settings", "language", "") == "en", "language saved in settings.cfg")
	sys.toggle_language()
	check(TranslationServer.get_locale().begins_with("id"), "toggle back to id")
	sys.set_volume(40.0, "Music")
	cf.load(settings)
	check(int(cf.get_value("settings", "vol_music", -1)) == 40, "volume saved")
	await key(KEY_ESCAPE)
	check(not menu.visible and not paused, "Esc closes the menu and unpauses")
	# M opens the Map tab directly, pressing M again closes it
	await key(KEY_M)
	check(menu.visible and paused and menu._tabs.current_tab == 3, "M opens the menu directly to the Map tab")
	await key(KEY_M)
	check(not menu.visible and not paused, "M on Map tab closes the menu and unpauses")
	# Choices section: a set remember_ flag with a translation is listed; without one it is skipped.
	for loc in ["id", "en"]:
		var tr_: Translation = Translation.new()
		tr_.locale = loc
		tr_.add_message("REMEMBER_TEST_KEY", "Tes akan mengingat ini")
		TranslationServer.add_translation(tr_)
	game.set_flag("remember_test_key")
	game.set_flag("remember_no_text")
	menu.refresh()
	var texts := []
	for l in menu.tab(2).detail.find_children("*", "Label", true, false):
		texts.append(l.text)
	check(texts.has("UI_JOURNAL_CHOICES") or texts.has(tr("UI_JOURNAL_CHOICES")), "choices heading shown")
	check(texts.has("Tes akan mengingat ini"), "remember sentence listed in the Journal")
	check(not texts.has("REMEMBER_NO_TEXT"), "untranslated remember flag skipped")
	DirAccess.remove_absolute(settings)
	DirAccess.remove_absolute("user://test_menu.json")
