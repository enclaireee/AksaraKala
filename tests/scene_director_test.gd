extends SceneTree
## Scene director: cue lines, letterbox bars, safe with no camera / NPC.

var fails := 0
var cues: Array = []


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
	game.save_path = "user://test_scene_director.json"
	game._reset()
	var ev := root.get_node("Events")
	var ui: Node = load("res://ui/game_ui.tscn").instantiate()
	ui.get_node("StoryBeat").free()   # a real beat could open the box mid-test
	root.add_child(ui)
	await frames(3)
	var dir: Node = ui.get_node("SceneDirector")
	var box: Node = ui.get_node("DialogueBox")
	ev.scene_cue.connect(func(c: String, a: String) -> void: cues.append([c, a]))

	# no camera, no player, no NPC: nothing may error
	check(not dir.bars_on(), "bars start off")
	dir.focus_speaker("NPC_NOBODY_NAME")
	dir.begin_beat()
	dir.focus_speaker("NPC_NOBODY_NAME")
	dir.focus_speaker("")
	check(dir.bars_on(), "begin_beat turns bars on")
	ev.scene_cue.emit("cam", "nobody")
	ev.scene_cue.emit("cam", "hero")
	ev.scene_cue.emit("shake", "2")
	await frames(3)
	cues.clear()
	dir.end_beat()
	check(not dir.bars_on(), "end_beat turns bars off")
	ev.scene_cue.emit("bars", "on")
	check(dir.bars_on(), "bars:on cue")
	ev.scene_cue.emit("bars", "off")
	check(not dir.bars_on(), "bars:off cue")
	check(dir.find_node_by_id("hero") == null, "hero is not a node")

	# hidden and distant nodes are ignored by auto-direction; visible nearest or prefix node wins
	var hidden_npc := Node2D.new()
	hidden_npc.name = "laras"
	hidden_npc.visible = false
	root.add_child(hidden_npc)
	check(dir.find_node_by_id("laras") == null, "hidden node ignored by find_node_by_id")
	var vis_npc := Node2D.new()
	var ns := GDScript.new()
	ns.source_code = "extends Node2D\nvar npc_id := 'laras_tag'\nvar cond := ''\n"
	ns.reload()
	vis_npc.set_script(ns)
	root.add_child(vis_npc)
	check(dir.find_node_by_id("laras") == vis_npc, "visible prefix npc_id matched when exact is hidden")
	hidden_npc.free()
	vis_npc.free()

	# a cue line is emitted and never shown
	cues.clear()
	ev.dialogue_requested.emit("", PackedStringArray(["#cam:x", "#shake:1", "HELLO_LINE"]))
	check(box.is_open(), "box open")
	check(cues.size() == 2 and cues[0] == ["cam", "x"] and cues[1] == ["shake", "1"], "cues emitted in order: %s" % [cues])
	check(not box._text.text.contains("#"), "cue line shows no text")
	check(box._text.text.contains("HELLO_LINE"), "text line follows the cues")
	box._close()
	check(not box.is_open(), "box closed")

	# #wait holds the box with no text and clamps to 3 s
	cues.clear()
	ev.dialogue_requested.emit("", PackedStringArray(["#wait:99", "AFTER_WAIT"]))
	check(cues == [["wait", "99"]], "wait cue emitted")
	check(box._text.text == "", "wait shows no text")
	check(box._hold_until > 0 and box._hold_until - Time.get_ticks_msec() <= 3000, "wait clamped to 3 s")
	box._hold_until = Time.get_ticks_msec()   # skip the real-time wait
	await frames(2)
	check(box._hold_until == 0 and box._text.text.contains("AFTER_WAIT"), "box continues after the wait")
	box._close()
	check(not paused, "tree unpaused after close")
	quit_cleanup()


func quit_cleanup() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_scene_director.json"))
