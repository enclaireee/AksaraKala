extends SceneTree
## Shortcut gate: opens only from its open side, sets its flag (saved), every gate with that id
## goes away, and a gate whose flag is already set is gone on load.

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	var g: Node = root.get_node("Game")
	g.save_path = "user://shortcut_test.json"
	g._reset()
	var pl := Node2D.new()
	pl.add_to_group("player")
	root.add_child(pl)
	var a := gate("e")
	var b := gate("e")
	await process_frame
	pl.global_position = Vector2(-20, 0)   # west: the wrong side
	a.interact()
	check(not g.has_flag("sc:t"), "opened from the wrong side")
	a._refresh_prompt()
	check(a._prompt.text == a.tr("UI_SC_LOCKED"), "wrong-side prompt: '%s'" % a._prompt.text)
	pl.global_position = Vector2(20, 0)
	a.interact()
	await process_frame
	check(g.has_flag("sc:t"), "did not open from the open side")
	check(not is_instance_valid(a) and not is_instance_valid(b), "a gate with this id stayed")
	var c := gate("e")
	await process_frame
	check(not is_instance_valid(c), "an opened gate came back on load")
	for p in ["user://shortcut_test.json", "user://shortcut_test.bak", "user://shortcut_test.json.tmp"]:
		DirAccess.remove_absolute(p)
	g._reset()
	quit(1 if fails > 0 else 0)


func gate(side: String) -> Node2D:
	var s: Node2D = load("res://entities/world/shortcut.tscn").instantiate()
	s.id = "sc:t"
	s.open_side = side
	root.add_child(s)
	return s
