extends SceneTree
## Dialogue choices, @SPEAKER lines, Game.play and the comma-list in Game.check, through the real dialogue box.

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


func press(action: String) -> void:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = true
	Input.parse_input_event(e)
	await frames(2)


func run() -> void:
	var g: Node = root.get_node("Game")
	g.save_path = "user://choice_test.json"
	g._reset()
	# comma-list check
	g.set_flag("a", false)
	check(g.check("flag:a,!flag:b"), "all-of true")
	check(not g.check("flag:a,flag:b"), "all-of false")
	check(g.check(""), "empty is true")
	check(g.check("flag:a"), "single form still works")

	var box: Control = load("res://ui/dialogue_box.tscn").instantiate()
	root.add_child(box)
	await frames(2)
	var entry := {
		"lines": ["@NPC_SEMAR_NAME", "L1", "@NPC_NAGAWIRU", "L2"],
		"choices": [{"text": "C_ONE", "do": ["flag:one"]}, {"text": "C_TWO", "do": ["flag:two"]}],
		"do": ["flag:entry"],
	}
	var done := [false]
	var go := func(en: Dictionary) -> void:
		await g.play("NPC_X", en)
		done[0] = true
	go.call(entry)
	await frames(2)
	check(box.is_open() and root.get_tree().paused, "box open and tree paused")
	var first_speaker: String = box._speaker.text
	check(box._text.text == "L1", "@ line is not shown, first line is L1: '%s'" % box._text.text)
	await press("interact")   # completes the typing
	await press("interact")   # next: skips the @ line
	check(box._text.text == "L2" and box._speaker.text != first_speaker, "second @ changes the speaker tag: '%s' / '%s'" % [box._text.text, box._speaker.text])
	await press("interact")
	await press("interact")
	check(box._choosing and box._list.text.contains("C_ONE") and box._list.text.contains("C_TWO"), "choices listed: '%s'" % box._list.text)
	check(not done[0], "waiting for a pick")
	await press("menu")
	check(box._choosing and not done[0], "cancel does nothing")
	await press("move_down")
	check(box._sel == 1, "down moves the selection")
	await press("interact")
	check(done[0] and g.has_flag("two") and not g.has_flag("one") and g.has_flag("entry"), "pick 2 ran its do, then the entry's do")
	check(not box.is_open() and not root.get_tree().paused, "box closed, pause restored")

	# no choices: plain entry still works
	done[0] = false
	entry = {"lines": ["P1"], "do": ["flag:plain"]}
	go.call(entry)
	await frames(2)
	await press("interact")
	await press("interact")
	check(done[0] and g.has_flag("plain"), "a plain entry still plays and runs its do")
	DirAccess.remove_absolute("user://choice_test.json")
