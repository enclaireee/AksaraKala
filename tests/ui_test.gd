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
	st.marker = {"zone": "tatar_sunda", "id": "spring"}
	qd.steps = [st]
	ResourceSaver.save(qd, zdir + "/t_arrow.tres")
	zones.current_zone = "desa_purwa"
	hud.refresh_arrow()
	await frames(1)
	check(not hud._arrow.visible and hud._tnode == null, "arrow hidden without a marker")
	var ex: Node2D = load("res://entities/world/exit.tscn").instantiate()
	ex.target_zone = "tatar_sunda"
	ex.position = Vector2(2000, 0)
	root.add_child(ex)
	game.start_quest("t_arrow")
	game.pin_quest("t_arrow")
	hud.refresh_arrow()
	await frames(2)
	check(hud._tnode == ex and hud._arrow.visible, "arrow points to the exit toward the target zone")
	check(absf(hud._arrow.rotation) < 0.1 and hud._arrow.position.x > 400, "arrow at the right edge")
	ex.position = Vector2(100, 100)
	await frames(2)
	check(not hud._arrow.visible, "arrow hidden when the target is on screen")
	ex.queue_free()
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

	game._reset()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_ui.json"))
	paused = false
