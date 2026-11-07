extends SceneTree

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
	var game := root.get_node("Game")
	game.save_path = "user://test_ui.json"
	game._reset()
	var player: Node = load("res://entities/player/player.tscn").instantiate()
	root.add_child(player)
	var ui: Node = load("res://ui/game_ui.tscn").instantiate()
	root.add_child(ui)
	await frames(3)
	var hud: Node = ui.get_node("HUD")
	var menu: GameMenu = ui.get_node("Menu")
	check(menu.is_in_group("game_menu"), "menu in group")

	var w0: float = hud._bars.hp[0].size.x
	player.health.hp = int(player.health.max_hp / 2)
	await frames(2)
	check(hud._bars.hp[0].size.x < w0, "hp bar follows damage")

	game.add_ilmu(7)
	check(hud._ilmu.text.contains(str(game.ilmu)), "ilmu label follows add_ilmu")

	menu.open()
	check(paused, "menu pauses the tree")
	for s in menu._raise:
		check(menu._raise[s].disabled, "level-up disabled outside petilasan")
	menu.close()
	check(not paused, "menu unpauses the tree")

	game.ilmu = 1000
	var before: int = game.stats.vit
	menu.open(true)
	check(not menu._raise.vit.disabled, "level-up enabled at petilasan")
	menu._raise.vit.pressed.emit()
	check(game.stats.vit == before, "raise needs confirm")
	menu._confirm_yes.pressed.emit()
	check(game.stats.vit == before + 1, "confirm raises the stat")
	menu.close()

	var cs: Node = load("res://ui/class_select.tscn").instantiate()
	root.add_child(cs)
	await frames(2)
	check(cs.cards.size() == 4, "class select shows 4 cards, got %d" % cs.cards.size())
	cs.queue_free()

	# Toasts: one at a time, 3 s each.
	var ev := root.get_node("Events")
	hud._toasts.clear()
	hud._toast_left = 0.0
	ev.item_picked.emit("golok")
	ev.glyph_learned.emit("sunda_ka")
	hud._update_toast(0.0)
	var first: String = hud._toast.text
	check(hud._toast.visible and first.contains(tr("ITEM_GOLOK_NAME")), "first toast shown: " + first)
	hud._update_toast(2.9)
	check(hud._toast.text == first, "toast stays 3 s")
	hud._update_toast(0.2)
	check(hud._toast.visible and hud._toast.text.contains("Ka") and hud._toast.text != first, "second toast after the first")
	hud._update_toast(3.1)
	check(not hud._toast.visible, "toasts end")

	# Objective arrow.
	var zones := root.get_node("Zones")
	var zdir := "user://ui_quest_fixtures"
	DirAccess.make_dir_recursive_absolute(zdir)
	QuestData.dir = zdir
	var qd := QuestData.new()
	qd.id = "t_arrow"
	var st := QuestStep.new()
	st.on = "area_entered:spring"
	st.marker = {"zone": "ts_kampung", "id": "spring"}
	qd.steps = [st]
	ResourceSaver.save(qd, zdir + "/t_arrow.tres")
	zones.current_zone = "desa_purwa"
	hud.refresh_arrow()
	await frames(1)
	check(not hud._arrow.visible and hud._tnode == null, "arrow hidden without a marker")
	var ex: Node2D = load("res://entities/world/exit.tscn").instantiate()
	ex.target_zone = "ts_kebun"   # first hop toward ts_kampung
	ex.position = Vector2(2000, 0)
	root.add_child(ex)
	game.start_quest("t_arrow")
	hud.refresh_arrow()
	await frames(2)
	check(hud._tnode == ex and hud._arrow.visible, "arrow points to the exit toward the target zone")
	check(hud._dist.visible and hud._dist.text.begins_with("-> "), "label names the target zone: '%s'" % hud._dist.text)
	hud.set_focus(true)
	hud._update_arrow()
	check(not hud._arrow.visible and not hud._dist.visible, "arrow and dist hidden during dialogue")
	hud.set_focus(false)
	hud._update_arrow()
	check(hud._arrow.visible and hud._dist.visible, "arrow and dist restored after dialogue")
	hud.refresh_objective()
	await frames(1)
	check(hud._tracker.get_child_count() >= 2, "tracker lists the started side quest")
	hud._banners.clear()
	hud._banner_left = 0.0
	hud._push_banner("UI_Q_NEW", "Judul")
	hud._update_banner(0.0)
	check(hud._banner_root.visible and hud._banner_body.text == "Judul", "banner shown")
	hud._update_banner(hud.BANNER_TIME + 0.1)
	check(not hud._banner_root.visible, "banner leaves after BANNER_TIME")
	for loc in ["id", "en"]:
		var rt: Translation = Translation.new()
		rt.locale = loc
		rt.add_message("REMEMBER_UI_TEST", "Dia akan mengingat")
		TranslationServer.add_translation(rt)
	hud._banners.clear()
	hud._banner_left = 0.0
	root.get_node("Events").consequence_noted.emit("ui_test")
	hud._update_banner(0.0)
	check(hud._banner_root.visible and hud._banner_body.text == "Dia akan mengingat", "consequence banner shows the REMEMBER sentence")
	hud._banners.clear()
	hud._banner_left = 0.0
	hud._update_banner(hud.BANNER_TIME + 0.1)
	root.get_node("Events").consequence_noted.emit("ui_missing")
	check(hud._banners.is_empty(), "no banner when the REMEMBER text is missing")
	check(absf(hud._arrow.rotation) < 0.1 and hud._arrow.position.x > 400, "arrow at the right edge")
	ex.position = Vector2(100, 100)
	await frames(2)
	check(not hud._arrow.visible, "arrow hidden when the target is on screen")
	ex.queue_free()
	game.quests.erase("t_arrow")
	game.pinned = ""
	zones.current_zone = ""

	# Boss bar.
	var boss := Node2D.new()
	var gs := GDScript.new()   # stub following the boss-bar contract (ui/hud.gd)
	gs.source_code = "extends Node2D\nvar health := Health.new()\nvar boss_name_key := 'UI_SAVED'\nvar dawn := 0.0\nvar engaged := false\nfunc _ready() -> void:\n\thealth.max_hp = 100\n\thealth.hp = 50\n"
	gs.reload()
	boss.set_script(gs)
	root.add_child(boss)
	boss.add_to_group("boss")
	await frames(2)
	check(not hud._boss_root.visible, "boss bar hidden until engaged")
	boss.engaged = true
	boss.dawn = 0.5
	await frames(2)
	check(hud._boss_root.visible and hud._dawn_fill.visible and hud._boss_fill.size.x == 120.0, "boss bar shows hp")
	boss.queue_free()

	# Dialogue box flow.
	var box: Node = ui.get_node("DialogueBox")
	var done := [0]
	ev.dialogue_finished.connect(func() -> void: done[0] += 1)
	var press := InputEventAction.new()
	press.action = "interact"
	press.pressed = true
	paused = true   # a pre-existing pause must come back
	ev.dialogue_requested.emit("NPC_X", PackedStringArray(["first line", "second"]))
	ev.dialogue_requested.emit("NPC_Y", PackedStringArray(["ignored"]))
	box._unhandled_input(press)   # same frame as the open: not an advance
	check(box.is_open() and paused, "box open and paused")
	check(box._text.visible_characters == 0, "opening press did not advance")
	await frames(1)
	box._unhandled_input(press)
	check(box._text.visible_characters == box._text.get_total_character_count() and box._text.text == "first line", "press completes the line")
	box._unhandled_input(press)
	check(box._text.text == "second", "press advances")
	box._unhandled_input(press)
	box._unhandled_input(press)
	check(not box.is_open() and done[0] == 1 and paused, "closed, finished once, pause restored")
	paused = false

	# Name tag, journal recap/clues, lontar shimmer (Story v4).
	var tr_en := Translation.new()
	tr_en.locale = TranslationServer.get_locale()
	tr_en.add_message("NPC_CEPOT_NAME", "Cepot")
	tr_en.add_message("NPC_CEPOT_WHO", "Semar's son. Loud.")
	tr_en.add_message("NPC_MUTE_NAME", "Mute")
	tr_en.add_message("CLUE_ASH_NOTE", "Ash by the door")
	tr_en.add_message("T_RECAP_0", "recap zero")
	tr_en.add_message("T_RECAP_1", "recap one")
	tr_en.add_message("T_RECAP_2", "recap two")
	TranslationServer.add_translation(tr_en)
	ev.dialogue_requested.emit("NPC_MUTE_NAME", PackedStringArray(["hi"]))
	check(box._who.text == "" and not game.has_flag("seen_name_mute"), "no tag without a WHO key")
	box._close()
	ev.dialogue_requested.emit("NPC_CEPOT_NAME", PackedStringArray(["a", "b"]))
	check(box._who.text == "Semar's son. Loud." and game.has_flag("seen_name_cepot"), "tag shown and seen flag set")
	await frames(1)
	box._unhandled_input(press)
	box._unhandled_input(press)
	check(box._who.text != "", "tag stays up for the whole first talk")
	box._close()
	ev.dialogue_requested.emit("NPC_CEPOT_NAME", PackedStringArray(["a"]))
	check(box._who.text == "", "no tag on a later talk")
	box._close()
	paused = false

	var rq := QuestData.new()
	rq.id = "t_recap"
	rq.kind = "main"   # recap lists main quests only
	for i in 3:
		var s2 := QuestStep.new()
		s2.on = "talked_to:r%d" % i
		rq.steps.append(s2)
	ResourceSaver.save(rq, zdir + "/t_recap.tres")
	var rq2 := QuestData.by_id("t_recap")
	for i in 3:
		rq2.steps[i].set("recap", "" if i == 1 else "T_RECAP_%d" % i)
	rq2.steps[0].set("recap", "T_RECAP_0")
	game.start_quest("t_recap")
	game.quests.t_recap.step = 2
	game.flags["clue_ash"] = true
	game.flags["clue_unknown"] = true   # no note key: skipped
	menu.refresh()
	var texts := PackedStringArray()
	for l in menu._journal.find_children("*", "Label", true, false):
		texts.append(l.text)
	check("recap zero" in texts and "recap two" not in texts and "recap one" not in texts, "recap lists steps below current, skips empty: %s" % str(texts))
	check("Ash by the door" in texts and texts.size() >= 2, "clue note listed from flags")

	var sh: LontarShimmer = player.get_node("LontarShimmer")
	var clue := Node2D.new()
	var cs2 := GDScript.new()
	cs2.source_code = "extends Node2D\nvar clue_id := 'well'\nvar memory_id := 'm'\n"
	cs2.reload()
	clue.set_script(cs2)
	root.add_child(clue)
	clue.add_to_group("interactable")
	player.global_position = Vector2.ZERO
	clue.global_position = sh.global_position + Vector2(12, 0)
	sh.poll()
	var near := sh.strength
	clue.global_position = sh.global_position + Vector2(36, 0)
	sh.poll()
	var far := sh.strength
	check(absf(near - 0.75) < 0.01 and absf(far - 0.25) < 0.01, "shimmer alpha follows 1 - dist/48: %f %f" % [near, far])
	clue.global_position = sh.global_position + Vector2(60, 0)
	sh.poll()
	check(sh.strength == 0.0, "no shimmer beyond 48 px")
	clue.global_position = sh.global_position + Vector2(12, 0)
	game.flags["clue_well"] = true
	sh.poll()
	check(sh.strength == 0.0, "no shimmer for an examined clue")
	game.flags.erase("clue_well")
	ev.dialogue_requested.emit("NPC_X", PackedStringArray(["x"]))
	sh.poll()
	check(sh.strength == 0.0, "shimmer off while a dialogue is open")
	box._close()
	paused = false
	sh.poll()
	check(sh.strength > 0.0, "shimmer back after the dialogue")
	clue.queue_free()
	game.quests.erase("t_recap")

	game._reset()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_ui.json"))
	paused = false
