extends SceneTree
## Game save (rpg.md 11): round trip, defaults for missing fields, .bak fallback, never deletes, level cost.

var fails := 0
const PATH := "user://save_test.json"


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	var g: Node = root.get_node("Game")
	g.save_path = PATH
	for p in [PATH, "user://save_test.bak", PATH + ".tmp"]:
		DirAccess.remove_absolute(p)   # this test's own files only

	# New game and leveling.
	var cls := ClassData.new()
	cls.id = "warrior"
	cls.stats = {"vit": 8, "end": 6, "str": 8, "dex": 4, "spi": 3}
	cls.start_weapon = ""
	cls.start_armor = ""
	check(not g.has_save(), "has_save before any save")
	g.hero_name = "Ayu"   # set on the name screen before class select
	g.hero_pronoun = "she"
	g.new_game(cls)
	check(g.hero_name == "Ayu" and g.hero_pronoun == "she", "new_game reset the hero name")
	check(g.has_save() and g.class_id == "warrior" and g.stats.vit == 8, "new_game did not save the class")
	check(g.level() == 1 and g.level_cost() == 40, "level 1 costs %d" % g.level_cost())
	check(not g.level_up("str"), "level_up with 0 Ilmu")
	g.add_ilmu(100)
	check(g.level_up("str") and g.stats.str == 9 and g.ilmu == 60 and g.level_cost() == 45, "level_up math: ilmu %d next %d" % [g.ilmu, g.level_cost()])
	check(not g.level_up("luck"), "level_up accepted an unknown stat")

	# Round trip through the file equals the live state.
	g.glyphs_learned.append("jawa_ha")
	g.killed.append("boss_z1")
	g.equipped.weapon = "broadsword"
	g.flags["met_guide"] = true
	g.last_petilasan = {"zone": "res://zones/hub.tscn", "id": "p1"}
	g.play_time = 123.456789
	var before := JSON.stringify(g.to_dict())
	check(g.save_game(), "save failed")
	g._reset()
	check(g.load_game(), "load failed")
	check(JSON.stringify(g.to_dict()) == before, "round trip changed the state:\n%s\n%s" % [before, JSON.stringify(g.to_dict())])
	check(typeof(g.ilmu) == TYPE_INT and typeof(g.stats.str) == TYPE_INT, "numbers came back as floats")

	# A missing field gets its default; a wrong type keeps the default; unknown keys are ignored.
	g.from_dict({"version": 1, "class_id": "mage", "ilmu": "lots", "future_field": 1})
	check(g.class_id == "mage" and g.ilmu == 0 and g.flask_max == 3 and g.glyphs_learned.is_empty() and g.quests.is_empty(), "merge onto defaults failed")
	check(g.hero_name == "Jaka" and g.hero_pronoun == "they", "an old save lacks the hero name: defaults expected")
	g.from_dict({"class_id": "mage", "hero_name": "[b]x{y}", "hero_pronoun": "xe"})
	check(g.hero_name == "bxy" and g.hero_pronoun == "they", "a hand-edited name/pronoun was not cleaned: %s %s" % [g.hero_name, g.hero_pronoun])

	# save.bak holds the previous good save. A broken save.json falls back to it and is not deleted.
	g.from_dict(JSON.parse_string(before))
	g.ilmu = 7
	g.save_game()   # save.json: ilmu 7, save.bak: ilmu 60
	_write(PATH, "{ broken")
	g._reset()
	check(g.load_game() and g.ilmu == 60, "did not fall back to .bak (ilmu %d)" % g.ilmu)
	check(FileAccess.file_exists(PATH), "the broken save was deleted")
	# A save over a broken save.json must not overwrite the good .bak.
	g.save_game()
	_write(PATH, "{ broken")
	g._reset()
	check(g.load_game() and g.ilmu == 60, "a broken save.json replaced the .bak")
	# Valid JSON with no run in it ({}) is not a save either.
	_write(PATH, "{}")
	g._reset()
	check(g.load_game() and g.ilmu == 60 and g.class_id != "", "an empty {} save loaded instead of the .bak")

	# Both broken: load fails, nothing deleted.
	_write("user://save_test.bak", "nope")
	g._reset()
	check(not g.load_game(), "load succeeded with both files broken")
	check(FileAccess.file_exists(PATH) and FileAccess.file_exists("user://save_test.bak"), "a broken file was deleted")
	check(not FileAccess.file_exists(PATH + ".tmp"), "tmp file left behind")

	for p in [PATH, "user://save_test.bak"]:
		DirAccess.remove_absolute(p)
	g._reset()
	quit(1 if fails > 0 else 0)


func _write(path: String, text: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text)
	f.close()
