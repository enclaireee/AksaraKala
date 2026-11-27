extends SceneTree
## Pelajaran Desa Purwa tutorial verification (`.docs/tutorial.md`):
## 1) Static audit: all 8 lessons, 8 class tips, and barks resolve in both `id` and `en`; `talk` lessons are
##    offered by dialogue; `when` conditions parse; `prologue_tutorial` is absent from Zones.ZONES.
## 2) Live runtime tests on ui/tutorial.gd:
##    - `move` requires movement + real interact (`talked_to`), never empty-air interact;
##    - `combo` requires a true 3-hit combo (`combo == 2`), not 3 single hits, then shows the class tip & finishes on dummy kill;
##    - `cast` stays blocked while `GlyphLesson` is open (zero overlap) and finishes on live `spell_cast`;
##    - `flask` triggers on `player_hurt` and completes on `player_drank`;
##    - `perfect` triggers on `enemy_windup` within range and completes on `perfect_dodge` (time_scale stays 1.0);
##    - `GameSettings.skip_tutorials()` suppresses lessons cleanly;
##    - card geometry clears the boss name bar (`Y = 236`) and weapon well (`Y = 242`).

const Lessons = preload("res://data/lessons.gd")
const TitleScript = preload("res://ui/title.gd")

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	var prev_settings := TitleScript.settings_path
	TitleScript.settings_path = "user://tutorial_test_settings.cfg"
	GameSettings.set_skip_tutorials(false)

	var offered := {}
	for f in DirAccess.get_files_at("res://data/dialogue"):
		if not f.ends_with(".tres"):
			continue
		var d := load("res://data/dialogue/" + f) as DialogueData
		if d == null:
			continue
		for e: Dictionary in d.entries:
			for a: String in e.get("do", []):
				if a.begins_with("lesson:"):
					offered[a.trim_prefix("lesson:")] = f

	var game := root.get_node("Game")
	var ev := root.get_node("Events")

	# --- 1. Static coverage ---
	for id: String in Lessons.ids():
		var l: Dictionary = Lessons.by_id(id)
		for loc in ["id", "en"]:
			TranslationServer.set_locale(loc)
			check(TranslationServer.translate(l.text) != l.text, "%s: no %s text for %s" % [id, loc, l.text])
			if l.get("title", "") != "":
				check(TranslationServer.translate(l.title) != l.title, "%s: no %s title for %s" % [id, loc, l.title])
		check(l.get("steps", []).size() > 0, "%s has no steps" % id)
		if l.get("on", "") == "talk":
			check(offered.has(id), "%s is never offered: no dialogue entry runs lesson:%s" % [id, id])
		var when: String = l.get("when", "")
		if when != "":
			game.check(when)

	for cid: String in Lessons.CLASS_TIPS.keys():
		var k: String = Lessons.CLASS_TIPS[cid]
		for loc in ["id", "en"]:
			TranslationServer.set_locale(loc)
			check(TranslationServer.translate(k) != k, "class tip %s missing %s (%s)" % [cid, loc, k])

	for bk in ["BARK_LARAS_DODGE_CUE", "BARK_LARAS_DODGE_OK", "BARK_CEPOT_START", "BARK_CEPOT_HIT1",
			"BARK_CEPOT_HIT2", "BARK_CEPOT_HIT3", "BARK_CEPOT_DONE", "BARK_SEMAR_FORM",
			"BARK_SEMAR_SAKTI", "BARK_SEMAR_SAKTI_READY", "BARK_SEMAR_DONE",
			"UI_TUT_LEVELUP_HINT", "UI_TUT_SHRINE_SAVED", "UI_SYS_SKIP_TUT", "UI_TOGGLE_KEY"]:
		for loc in ["id", "en"]:
			TranslationServer.set_locale(loc)
			check(TranslationServer.translate(bk) != bk, "key %s missing %s" % [bk, loc])

	check(not root.get_node("Zones").ZONES.has("prologue_tutorial"), "the practice room is gone from ZONES")
	# ui.md 0.2 item 6: UIFx body fonts keep the trimmed 13 px box (LINE - 1) even with the aksara fallbacks attached.
	for fnt: Font in [UIFx.body_font(), UIFx.caps_font(), UIFx.head_font()]:
		check(is_equal_approx(fnt.get_height(UIFx.BODY), UIFx.LINE - 1.0), "UIFx font line box is %.0f, want %d" % [fnt.get_height(UIFx.BODY), UIFx.LINE - 1])
	for sz in [UIFx.DISPLAY, UIFx.LOGO]:
		var raw := load(UIFx.FONT_DISPLAY) as Font
		check(is_equal_approx(UIFx.display(sz).get_height(sz), raw.get_height(sz)), "display font at %d has a %.0f px line box" % [sz, UIFx.display(sz).get_height(sz)])
	TranslationServer.set_locale("id")

	# --- 2. Runtime behavior ---
	game.save_path = "user://tutorial_test_save.json"
	game.new_game(load("res://data/classes/lancer.tres") as ClassData)
	var ui: CanvasLayer = load("res://ui/game_ui.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	var tut: Control = ui.get_node("Tutorial")
	var gl: CanvasLayer = ui.get_node("GlyphLesson")

	# 2a. Opening `move` lesson: empty-air interact does not finish it; movement + talked_to does.
	check(tut.active() == "move", "opening move lesson should be active at mq0=0, got '%s'" % tut.active())
	check(tut._root.position.y + tut.H <= 236.0, "tutorial card overlaps boss bar (bottom %.1f > 236)" % (tut._root.position.y + tut.H))
	var ie := InputEventAction.new()
	ie.action = "interact"
	ie.pressed = true
	tut._input(ie)
	check(tut.active() == "move" and not game.has_flag("tut_move"), "empty-air interact should not dismiss move")
	var me := InputEventAction.new()
	me.action = "move_right"
	me.pressed = true
	tut._input(me)
	ev.talked_to.emit("purwa_well")
	check(game.has_flag("tut_move"), "movement + talked_to should finish move lesson")

	# 2b. `combo` lesson: requires true combo == 2 finisher, NOT 3 disconnected combo == 0 hits!
	game.quests["mq0"].step = 4
	game.set_flag("mq0_d4", false)
	tut._quiet()
	tut.offer("combo")
	check(tut.active() == "combo" and tut.active_step() == 0, "combo lesson should start at step 0")
	ev.player_struck.emit(0)
	ev.player_struck.emit(0)
	ev.player_struck.emit(0)
	check(tut.active_step() == 0, "3 disconnected single hits must NOT complete combo step 0")
	ev.player_struck.emit(0)
	ev.player_struck.emit(1)
	ev.player_struck.emit(2)
	check(tut.active_step() == 1, "true 3-hit finisher (combo == 2) should advance combo to step 1 (class tip)")
	var dummy := Node2D.new()
	var ds := GDScript.new()
	ds.source_code = "extends Node2D\nvar kind := 'dummy'\n"
	ds.reload()
	dummy.set_script(ds)
	ev.enemy_killed.emit(dummy, 0)
	check(game.has_flag("tut_combo"), "dummy knockdown should complete combo lesson")
	dummy.free()

	# 2c. `cast` lesson blocked while GlyphLesson is active (zero overlap), completes on spell_cast.
	game.quests["mq0"].step = 10
	game.glyphs_learned.append("sunda_ka")
	tut._quiet()
	gl.active = "sunda_ka"
	tut.offer("cast")
	check(tut.blocked_now(), "tutorial card must stay blocked while GlyphLesson is active")
	gl.active = ""
	check(not tut.blocked_now(), "tutorial card unblocks once GlyphLesson finishes Phase A")
	ev.spell_cast.emit("sunda_ka", 1.0)
	check(game.has_flag("tut_cast"), "live spell_cast should complete cast lesson")

	# 2d. `flask` and `perfect` triggers + time_scale safety.
	game.set_flag("mq0_5", false)
	game.flask_charges = 3
	tut._quiet()
	ev.player_hurt.emit(0.5)
	check(tut.active() == "flask", "player_hurt <= 0.75 should offer flask, got '%s'" % tut.active())
	ev.player_drank.emit()
	check(game.has_flag("tut_flask"), "player_drank should complete flask lesson")

	var fake_pl := Node2D.new()
	fake_pl.add_to_group("player")
	fake_pl.position = Vector2(100, 100)
	root.add_child(fake_pl)
	var fake_en := Node2D.new()
	fake_en.position = Vector2(124, 100)
	root.add_child(fake_en)
	tut._quiet()
	ev.enemy_windup.emit(fake_en)
	check(tut.active() == "perfect", "nearby enemy_windup should offer perfect lesson, got '%s'" % tut.active())
	ev.perfect_dodge.emit()
	check(game.has_flag("tut_perfect"), "perfect_dodge should complete perfect lesson")
	check(is_equal_approx(Engine.time_scale, 1.0), "Engine.time_scale must remain 1.0")
	fake_pl.free()
	fake_en.free()

	# 2e. Replay skip setting suppresses lessons.
	tut._quiet()
	GameSettings.set_skip_tutorials(true)
	game.quests["mq0"].step = 11
	game.set_flag("mq0_7", false)
	tut.offer("rest")
	check(tut.active() == "", "skip_tutorials must suppress offering new lessons")
	GameSettings.set_skip_tutorials(false)
	tut.offer("rest")
	check(tut.active() == "rest", "post-raid rest lesson should activate once mq0_7 holds")
	ev.petilasan_activated.emit("desa_purwa")
	check(game.has_flag("tut_rest"), "petilasan_activated should complete rest lesson")

	# A bark holds for its duration (the hold tween once ran in parallel and freed it after ~0.2 s).
	paused = false
	await process_frame   # the synchronous checks above make one long frame; let its delta pass before the tween starts
	await process_frame
	var anchor := Node2D.new()
	root.add_child(anchor)
	var bark := WorldBark.say(anchor, "hold", 3.2)
	await create_timer(1.0, true, false, true).timeout
	check(is_instance_valid(bark) and bark.modulate.a > 0.9, "a bark must still show 1 s after say(..., 3.2)")
	anchor.free()

	ui.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TitleScript.settings_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://tutorial_test_save.json"))
	TitleScript.settings_path = prev_settings
	quit(1 if fails > 0 else 0)
