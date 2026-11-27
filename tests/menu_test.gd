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
	# Phase 7c: Pusaka panel, Jamasan, jimat strip, codex Items list.
	game._reset()
	menu.open(false)
	var st: Control = menu.tab(0)
	var eq: Control = menu.tab(1)
	menu.refresh()
	check(not st._pusaka.visible, "Pusaka panel hidden without has_pusaka")
	game.set_flag("has_pusaka")
	game.killed.append("sangkuriang")
	game.killed.append("bandung_bondowoso")
	menu.refresh()
	check(st._pusaka.visible and st.jamasan_btn.visible, "Pusaka panel and Jamasan button shown with has_pusaka and a pending tier")
	check(st.jamasan_btn.disabled, "Jamasan disabled outside a petilasan")
	st._do_jamasan()
	check(game.ingatan == 0, "Jamasan refuses outside a petilasan")
	menu.open(true)
	menu.refresh()
	check(not st.jamasan_btn.disabled, "Jamasan enabled at a petilasan")
	st._do_jamasan()
	check(game.ingatan == 1 and st._card.visible, "Jamasan at a petilasan raises Ingatan and shows the memory card")
	st._close_card()
	check(not st._card.visible and st._pusaka.visible, "memory card closes")
	game.inventory.append("jimat")      # Daya 2
	game.inventory.append("amulet")     # Daya 1
	game.inventory.append("genitri")    # Daya 2
	menu.open(false)
	check(not eq.toggle_jimat("amulet") and game.jimat.is_empty(), "jimat strip refuses outside a petilasan")
	menu.open(true)
	check(eq.toggle_jimat("jimat") and eq.toggle_jimat("amulet"), "jimat equip within budget (Daya 3 of 3)")
	check(not eq.toggle_jimat("genitri") and not "genitri" in game.jimat, "jimat strip refuses over budget")
	check(eq.toggle_jimat("amulet") and not "amulet" in game.jimat, "jimat removed at a petilasan")
	check(not eq.get("_doll_btn").has("accessory"), "no accessory slot on the doll")
	var cx: MenuTab = menu.tab(4)
	cx.refresh()
	var lines := []
	for l in cx._right.find_children("*", "Label", true, false):
		lines.append(l.text)
	var unk: String = tr("UI_UNKNOWN")
	check(lines.has(tr(ItemData.by_id("jimat").title)), "codex Items shows an owned item's name")
	check(lines.has(unk) and not lines.has(tr(ItemData.by_id("blangkon").title)), "codex Items shows ??? for an unowned item")

	# Phase 7c UX fixes: Status ATK/DEF, Equipment STAT_KEYS & DR separation, Petilasan pending prompt.
	game.add_item("dagger", false)
	game.equip("dagger")
	game.ingatan = 0
	menu.refresh()
	var atk0 := int(st._derived.atk.text)
	game.ingatan = 3
	menu.refresh()
	check(int(st._derived.atk.text) > atk0, "Status ATK did not rise with Ingatan")
	game.add_item("gelang_akar_bahar", false)
	game.equip_jimat("gelang_akar_bahar")
	menu.refresh()
	check(st._derived["def"].text == "6%", "Status DEF did not reflect jimat DR: %s" % st._derived["def"].text)
	for bk in ["spell_mult", "flask_heal", "dodge_sakti", "ilmu_mult", "low_hp_damage", "kill_heal", "status_short"]:
		check(eq.STAT_KEYS.has(bk), "Equipment STAT_KEYS missing %s" % bk)
	var gab_stats: Dictionary = eq._item_stats(ItemData.by_id("gelang_akar_bahar"))
	check(gab_stats.has("damage_reduction") and not gab_stats.has("defense"), "jimat DR should not collide with armor defense")
	var pet: Petilasan = (load("res://entities/petilasan/petilasan.tscn") as PackedScene).instantiate()
	root.add_child(pet)
	await process_frame
	game.set_flag("has_pusaka")
	game.killed = PackedStringArray(["sangkuriang", "bandung_bondowoso", "keris_gandring"])
	game.ingatan = 1
	pet._refresh_prompt()
	check(pet.prompt.text.contains(tr("UI_JAMASAN_PENDING") % 2), "Petilasan prompt missing pending jamasan: %s" % pet.prompt.text)
	pet.queue_free()

	DirAccess.remove_absolute(settings)
	DirAccess.remove_absolute("user://test_menu.json")
