extends SceneTree
## Prologue: advancing walks every line and ends at class select; hold skips; keys translate in both locales.

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


func start() -> Control:
	var p: Control = load("res://ui/prologue.tscn").instantiate()
	root.add_child(p)
	current_scene = p
	await frames(2)
	return p


func run() -> void:
	for loc in ["id", "en"]:
		TranslationServer.set_locale(loc)
		for i in range(1, 14):
			var k := "PROLOGUE_%d" % i
			check(tr(k) != k and tr(k) != "", "%s translates in %s" % [k, loc])
	check(tr("UI_HOLD_SKIP") != "UI_HOLD_SKIP", "hold hint translates")

	var p := await start()
	var seen := [p.index]
	for i in 40:
		if p.index == 13 and not p._tw.is_running():
			break
		p.advance()   # first call finishes the typing, the second moves on
		if p.index != seen[-1]:
			seen.append(p.index)
	check(seen == range(1, 14), "advance visits lines 1..13, got %s" % str(seen))
	check(not p._done, "still on the last line until advanced past it")
	p.advance()
	p.advance()
	check(p._done, "advancing past line 13 ends the prologue")
	await frames(3)
	check(current_scene != null and current_scene.scene_file_path == "res://ui/class_select.tscn", "ends at class select")

	p = await start()
	Input.action_press("interact")
	p._process(0.5)
	check(not p._done, "half a second does not skip")
	p._process(0.6)
	Input.action_release("interact")
	check(p._done, "holding interact skips")
	await frames(3)
	check(current_scene != null and current_scene.scene_file_path == "res://ui/class_select.tscn", "skip ends at class select")
