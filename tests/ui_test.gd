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

	game._reset()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_ui.json"))
	paused = false
