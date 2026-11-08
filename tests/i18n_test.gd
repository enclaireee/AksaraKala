extends SceneTree
## Text keys exist in id and en, the title toggle persists, the menu's Journal and Codex tabs open empty.

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	await run()
	quit(1 if fails > 0 else 0)


func table() -> Dictionary:
	var out := {}
	for f in ["ui", "items"]:
		var fa := FileAccess.open("res://data/text/%s.csv" % f, FileAccess.READ)
		fa.get_csv_line()
		while not fa.eof_reached():
			var r := fa.get_csv_line()
			if r.size() >= 3:
				out[r[0]] = [r[1], r[2]]
	return out


func keys_of(dir: String, fields: Array) -> Array:
	var out := []
	for f in DirAccess.get_files_at(dir):
		var r: Resource = load(dir + "/" + f.trim_suffix(".remap"))
		for k in fields:
			if r.get(k) != "":
				out.append(r.get(k))
	return out


func run() -> void:
	var t := table()
	var used := keys_of("res://data/items", ["title", "description", "lore"]) \
		+ keys_of("res://data/classes", ["title", "description", "passive", "passive_text"]) \
		+ keys_of("res://data/spells", ["title"])
	check(used.size() > 50, "keys collected: %d" % used.size())
	for f in ["ui", "dialogue", "quests", "codex", "items"]:   # every row of every CSV has id and en
		var fa := FileAccess.open("res://data/text/%s.csv" % f, FileAccess.READ)
		fa.get_csv_line()
		while not fa.eof_reached():
			var r := fa.get_csv_line()
			if r.size() >= 1 and r[0] != "":
				check(r.size() >= 3 and r[1].strip_edges() != "" and r[2].strip_edges() != "", "%s.csv row %s lacks id or en" % [f, r[0]])
	for k in used:
		check(t.has(k) and t[k][0] != "" and t[k][1] != "", "key %s has id and en" % k)
	for k in t:
		check(t[k][0] != "" and t[k][1] != "", "ui/items row %s has id and en" % k)
	for k in ["ITEM_", "CLASS_", "SPELL_"]:
		check(used.any(func(u: String) -> bool: return u.begins_with(k)), "prefix %s used" % k)

	TranslationServer.set_locale("id")
	var id_txt := TranslationServer.translate("UI_NEW_GAME")
	TranslationServer.set_locale("en")
	var en_txt := TranslationServer.translate("UI_NEW_GAME")
	check(id_txt != en_txt and id_txt != "UI_NEW_GAME" and en_txt != "UI_NEW_GAME", "UI_NEW_GAME differs: %s / %s" % [id_txt, en_txt])

	for loc in ["id", "en"]:
		TranslationServer.set_locale(loc)
		var fa_ui := FileAccess.open("res://data/text/ui.csv", FileAccess.READ)
		fa_ui.get_csv_line()
		while not fa_ui.eof_reached():
			var r := fa_ui.get_csv_line()
			if r.size() >= 1 and r[0].strip_edges() != "":
				var k := r[0].strip_edges()
				check(TranslationServer.translate(k) != k, "ui.csv key %s is imported in %s translation" % [k, loc])


	var Title: GDScript = load("res://ui/title.gd")
	Title.settings_path = "user://test_settings.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_settings.cfg"))
	var first: String = Title.load_language()
	check(first in ["id", "en"], "first-launch language: " + first)
	Title.save_language("id")
	check(Title.load_language() == "id", "saved id")
	Title.save_language("en")
	check(Title.load_language() == "en", "saved en")
	var title: Control = load("res://ui/title.tscn").instantiate()
	root.add_child(title)
	await process_frame
	check(TranslationServer.get_locale() == "en", "title applies saved locale")
	title._toggle_lang()
	check(TranslationServer.get_locale() == "id" and Title.load_language() == "id", "toggle switches and saves")
	title.queue_free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_settings.cfg"))
	Title.settings_path = Title.SETTINGS

	var game := root.get_node("Game")
	game.save_path = "user://test_i18n.json"
	game._reset()
	var menu: GameMenu = load("res://ui/menu.tscn").instantiate()
	root.add_child(menu)
	await process_frame
	for i in 7:
		menu._last_tab = i
		menu.open()
		check(menu._tabs.current_tab == i, "menu reopens on tab %d" % i)
		await process_frame
	check(menu.tab(2).detail.get_child_count() >= 1, "journal builds")
	check(menu.tab(4).list.get_child_count() >= 1, "codex builds")
	menu.close()
	menu.queue_free()
	game._reset()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_i18n.json"))
	paused = false
