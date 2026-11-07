extends SceneTree
## "Ask about..." topic hubs (script.md 2, quests.md 7.1 item 2) through a real NPC and the real dialogue box:
## the hub shows its choices, a topic plays its entry and returns to the hub, leave closes, topic and hub
## entries never emit talked_to, and the normal entry search skips topic entries.

var fails := 0
var talked: Array[String] = []


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


## Finishes the typing of the open line and moves past it.
func next_line() -> void:
	await press("interact")
	await press("interact")


func run() -> void:
	var g: Node = root.get_node("Game")
	var ev: Node = root.get_node("Events")
	g.save_path = "user://hub_test.json"
	g._reset()
	ev.talked_to.connect(func(id: String) -> void: talked.append(id))

	# The normal search skips topic entries, even ones with no `if`.
	var first: Dictionary = g.pick_entry([{"topic": "x", "lines": ["X"]}, {"lines": ["Y"]}])
	check(first.get("lines", []) == ["Y"], "pick_entry skips a topic entry: %s" % [first])
	check(g.pick_entry([{"topic": "x", "lines": ["X"]}]).is_empty(), "a file of only topics picks nothing")
	check(g.topic_entry([{"topic": "x", "if": ["flag:nope"], "lines": ["X0"]}, {"topic": "x", "lines": ["X1"]}], "x").get("lines", []) == ["X1"], "topic_entry takes the first whose if holds")

	var box: Control = load("res://ui/dialogue_box.tscn").instantiate()
	root.add_child(box)
	await frames(2)

	var d := DialogueData.new()
	d.npc_id = "h"
	d.name_key = "N"
	d.entries = [
		{"topic": "t2", "quiet": true, "lines": ["T2"], "do": ["flag:t2_seen"]},
		{"if": ["!flag:met"], "lines": ["A"], "do": ["flag:met"]},
		{"topic": "t1", "quiet": true, "if": ["flag:never"], "lines": ["T1_NO"]},
		{"topic": "t1", "quiet": true, "lines": ["T1"]},
		{"if": ["flag:met"], "hub": true, "quiet": true, "lines": ["H"], "do": ["flag:hub_do"], "choices": [
			{"text": "C_T1", "do": ["topic:t1"]},
			{"text": "C_T2", "do": ["flag:t2_pick", "topic:t2"]},
			{"text": "C_LEAVE", "do": ["flag:left"]},
		]},
		{"lines": ["B"]},
	]
	var npc: Npc = load("res://entities/npc/npc.tscn").instantiate()
	npc.npc_id = "h"
	npc.data = d
	root.add_child(npc)
	await frames(1)

	# First talk: the step entry, not the leading topic entry; it counts as the talk.
	npc.interact()
	await frames(2)
	check(box.is_open() and box._text.text == "A", "first talk plays A, not a topic: '%s'" % box._text.text)
	await next_line()
	check(not box.is_open() and talked == ["h"], "A closes and emits talked_to once: %s" % [talked])

	# Hub: its line, then its choices.
	npc.interact()
	await frames(2)
	check(box.is_open() and box._text.text == "H", "hub plays its line: '%s'" % box._text.text)
	await next_line()
	check(box._choosing and box._list.text.contains("C_T1") and box._list.text.contains("C_LEAVE"), "hub lists its choices: '%s'" % box._list.text)

	# Topic 1: the first t1 entry whose if holds, then the hub's choices again (no lines).
	await press("interact")
	check(box.is_open() and not box._choosing and box._text.text == "T1", "topic t1 plays T1: '%s'" % box._text.text)
	await next_line()
	check(box.is_open() and box._choosing and box._text.text == "" and box._list.text.contains("C_T2"), "back at the hub after t1: '%s'" % box._list.text)
	check(not g.has_flag("hub_do"), "the hub's do waits for leave")

	# Topic 2: its other actions run, then the topic plays and runs its own do.
	await press("move_down")
	await press("interact")
	check(box.is_open() and box._text.text == "T2" and g.has_flag("t2_pick"), "topic t2 plays T2 after its other actions: '%s'" % box._text.text)
	await next_line()
	check(box._choosing and g.has_flag("t2_seen"), "back at the hub after t2, its do ran")
	check(talked == ["h"], "topics and the hub never emit talked_to: %s" % [talked])

	# Leave: runs its do, then the hub's do, and closes.
	await press("move_down")
	await press("move_down")
	check(box._sel == 2, "leave selected: %d" % box._sel)
	await press("interact")
	await frames(1)
	check(not box.is_open() and not root.get_tree().paused, "leave closes the box and restores pause")
	check(g.has_flag("left") and g.has_flag("hub_do"), "leave ran its do and the hub's do")
	check(not npc._busy, "npc free again after the hub")
	check(talked == ["h"], "the hub never counts as the talk: %s" % [talked])

	# A talked_to quest step is not completed by a hub or topic talk.
	npc.interact()
	await frames(2)
	check(box._text.text == "H", "the hub plays again: '%s'" % box._text.text)
	await next_line()
	await press("interact")   # t1
	await next_line()
	await press("move_down")
	await press("move_down")
	await press("interact")   # leave
	await frames(1)
	check(talked == ["h"] and not box.is_open(), "still one talked_to after a second hub talk: %s" % [talked])

	npc.queue_free()
	box.queue_free()
	DirAccess.remove_absolute("user://hub_test.json")
