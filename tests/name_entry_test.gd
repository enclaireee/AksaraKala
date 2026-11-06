extends SceneTree
## Name entry screen: sanitizing as typed and on confirm, default name, pronoun, Game.fmt, save round trip.

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	await run()
	quit(1 if fails > 0 else 0)


func frames(n: int) -> void:
	for i in n:
		await process_frame


func run() -> void:
	var g: Node = root.get_node("Game")
	g.save_path = "user://name_entry_test.json"
	for loc in ["id", "en"]:
		TranslationServer.set_locale(loc)
		for k in ["UI_NAME_PROMPT", "UI_PRONOUN_PROMPT", "UI_PRONOUN_HE", "UI_PRONOUN_SHE", "UI_PRONOUN_THEY", "UI_NAME_OK", "UI_WRITE_HINT"]:
			check(tr(k) != k and tr(k) != "", "%s translates in %s" % [k, loc])
	check(g.clean_name("[b]x{y}") == "bxy", "sanitize: %s" % g.clean_name("[b]x{y}"))
	check(g.clean_name("  ") == "Jaka" and g.clean_name("") == "Jaka" and g.clean_name("[]") == "Jaka", "blank falls back to Jaka")
	check(g.clean_name("Ayu-Putri d'Éa9") == "Ayu-Putri d'Éa9".left(12), "letters, digits, space, ' and - are kept")
	check(g.clean_name("abcdefghijklmnop") == "abcdefghijkl", "max 12")
	check(g.clean_name("Siti Ñandú") == "Siti Ñandú", "unicode letters kept")

	var n: Control = load("res://ui/name_entry.tscn").instantiate()
	root.add_child(n)
	current_scene = n
	await frames(2)
	check(n._edit.text == "Jaka" and n.pronoun == "they", "defaults: Jaka, they")
	n._edit.text = "[b]x{y}"
	n._edit.text_changed.emit(n._edit.text)
	check(n._edit.text == "bxy", "typing drops bad characters: '%s'" % n._edit.text)
	n._buttons["she"].grab_focus()
	check(n.pronoun == "she", "focusing the she button selects it")
	n.confirm()
	check(g.hero_name == "bxy" and g.hero_pronoun == "she", "confirm stores name and pronoun")
	await frames(3)
	check(current_scene != null and current_scene.scene_file_path == "res://ui/prologue.tscn", "continues to the prologue")
	check(g.fmt("{name} {They} {them} {their}") == "bxy She her her", "fmt she: %s" % g.fmt("{name} {They} {them} {their}"))
	g.hero_pronoun = "they"
	check(g.fmt("{They} {they} {them} {their}") == "They they them their", "fmt they")

	# blank name: Jaka
	current_scene.queue_free()
	n = load("res://ui/name_entry.tscn").instantiate()
	root.add_child(n)
	current_scene = n
	await frames(2)
	n._edit.text = "   "
	n.confirm()
	check(g.hero_name == "Jaka", "blank name becomes Jaka")

	# save round trip, and new_game keeps the name
	g.hero_name = "Ayu"
	g.hero_pronoun = "he"
	var cls := ClassData.by_id("warrior")
	g.new_game(cls)
	check(g.hero_name == "Ayu" and g.hero_pronoun == "he", "new_game keeps the name")
	g._reset()
	check(g.hero_name == "Jaka", "reset defaults")
	check(g.load_game() and g.hero_name == "Ayu" and g.hero_pronoun == "he", "save round trip")
	for p in ["user://name_entry_test.json", "user://name_entry_test.bak"]:
		DirAccess.remove_absolute(p)
