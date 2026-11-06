extends SceneTree
## Game save (rpg.md 11): round trip, defaults for missing fields, .bak fallback, never deletes, level cost.

var fails := 0
const PATH := "user://save_test.json"
const QDIR := "user://save_test_quests"


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
	g.memory_return = {"zone": "res://zones/hub.tscn", "pos": [12.5, 40.0]}   # quit inside a Kelir memory (architecture.md 9b)
	# An all step mid-progress (quests.md 7.1): its trigger bits survive the round trip and still finish it.
	_all_quest()
	g.start_quest("sv_q")
	g.on_event("talked_to", "b")
	check(g.quests.sv_q.all == 2, "all bit not set before save: %s" % g.quests.sv_q)
	var before := JSON.stringify(g.to_dict())
	check(g.save_game(), "save failed")
	g._reset()
	check(g.load_game(), "load failed")
	check(JSON.stringify(g.to_dict()) == before, "round trip changed the state:\n%s\n%s" % [before, JSON.stringify(g.to_dict())])
	check(typeof(g.ilmu) == TYPE_INT and typeof(g.stats.str) == TYPE_INT, "numbers came back as floats")
	check(g.quests.sv_q.all == 2 and g.to_dict().version == g.VERSION, "all bits or version after load: %s" % g.quests.sv_q)
	check(g.memory_return.zone == "res://zones/hub.tscn" and g.memory_return.pos == [12.5, 40.0], "memory_return round trip: %s" % g.memory_return)
	g.on_event("talked_to", "a")
	check(g.quests.sv_q.step == 1 and g.has_flag("sv_all"), "loaded all step did not finish: %s" % g.quests.sv_q)
	g.from_dict(JSON.parse_string(before))
	# A version 1 save (quest records without `all`) loads with all = 0.
	g.from_dict({"version": 1, "class_id": "mage", "quests": {"sv_q": {"state": "active", "step": 0, "count": 0}}})
	check(g.quests.sv_q.all == 0 and g.current_step("sv_q").set_flag == "sv_all", "v1 quest record: %s" % g.quests.sv_q)
	g.from_dict(JSON.parse_string(before))
	# A save from before memory_return (version 2) loads with none; a malformed one is dropped.
	g.from_dict({"version": 2, "class_id": "mage", "flags": {"a": true}})
	check(g.class_id == "mage" and g.has_flag("a") and g.memory_return.is_empty(), "v2 save: %s" % g.memory_return)
	for bad: Variant in [{"zone": "", "pos": [1, 2]}, {"zone": "x"}, {"zone": "x", "pos": [1]}, {"zone": 3, "pos": [1, 2]}, {"zone": "x", "pos": ["a", 2]}, "nope"]:
		g.from_dict({"class_id": "mage", "memory_return": bad})
		check(g.memory_return.is_empty(), "malformed memory_return kept: %s" % [bad])
	g.from_dict(JSON.parse_string(before))

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

	for p in [PATH, "user://save_test.bak", QDIR + "/sv_q.tres", QDIR]:
		DirAccess.remove_absolute(p)
	g._reset()
	QuestData.dir = "res://data/quests"   # pointing it at user:// until exit leaks a resource
	quit(1 if fails > 0 else 0)


## Quest sv_q: an all step with two triggers, then a talk step. Its own function so no resource outlives it.
func _all_quest() -> void:
	DirAccess.make_dir_recursive_absolute(QDIR)
	QuestData.dir = QDIR
	var st := QuestStep.new()
	st.set_flag = "sv_all"
	st.all = [{"on": "talked_to:a", "set_flag": "sv_a"}, {"on": "talked_to:b", "set_flag": "sv_b"}]
	var last := QuestStep.new()
	last.on = "talked_to:z"
	var q := QuestData.new()
	q.id = "sv_q"
	q.steps = [st, last]
	ResourceSaver.save(q, QDIR + "/sv_q.tres")


func _write(path: String, text: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text)
	f.close()
