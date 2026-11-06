extends SceneTree
## NPC, chest, pickup (quests.md 7). DialogueData has no dir var, so the NPC's `data` is preset.

var fails := 0
var log: Array[String] = []


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	var g: Node = root.get_node("Game")
	var ev: Node = root.get_node("Events")
	g.save_path = "user://npc_test.json"

	var d := DialogueData.new()
	d.npc_id = "t"
	d.name_key = "N"
	d.entries = [
		{"if": ["!flag:met"], "lines": ["A"], "do": ["flag:met"]},
		{"lines": ["B"], "do": []},
	]
	ev.dialogue_requested.connect(func(_n: String, l: PackedStringArray) -> void: log.append("req:" + l[0]))
	ev.talked_to.connect(func(id: String) -> void: log.append("talked:%s:%s" % [id, g.has_flag("met")]))
	var npc: Npc = load("res://entities/npc/npc.tscn").instantiate()
	npc.npc_id = "t"
	npc.data = d
	root.add_child(npc)
	npc.interact()
	npc.interact()   # ignored while the box is open
	check(log == ["req:A"], "first entry / double interact: %s" % [log])
	ev.dialogue_finished.emit()
	check(log == ["req:A", "talked:t:true"], "talked_to after finished and do: %s" % [log])
	log.clear()
	npc.interact()
	check(log == ["req:B"], "flag switches entry: %s" % [log])
	ev.dialogue_finished.emit()
	npc.queue_free()

	# cond: hidden and unusable until it holds, re-checked on Game.changed
	var cn: Npc = load("res://entities/npc/npc.tscn").instantiate()
	cn.npc_id = "t"
	cn.data = d
	cn.cond = "flag:show_me"
	root.add_child(cn)
	check(not cn.visible and not cn.usable, "npc with a false cond is hidden and unusable")
	g.set_flag("show_me", false)
	check(cn.visible and cn.usable, "npc appears when its cond holds")
	cn.queue_free()

	var chest: Node = load("res://entities/world/chest.tscn").instantiate()
	chest.chest_id = "c1"
	chest.item_id = "dagger"
	var picked: Array[String] = []
	ev.item_picked.connect(func(i: String) -> void: picked.append(i))
	root.add_child(chest)
	chest.interact()
	chest.interact()
	check(picked == ["dagger"] and g.inventory.count("dagger") == 1, "chest gives once: %s" % [picked])
	var snap: Dictionary = g.to_dict()
	g.from_dict(snap)
	var c2: Node = load("res://entities/world/chest.tscn").instantiate()
	c2.chest_id = "c1"
	c2.item_id = "dagger"
	root.add_child(c2)
	c2.interact()
	check(picked.size() == 1 and c2._open, "chest stays open after reload")
	var c3: Node = load("res://entities/world/chest.tscn").instantiate()
	c3.chest_id = "c3"
	c3.item_id = "ilmu:55"
	root.add_child(c3)
	var before: int = g.ilmu
	c3.interact()
	check(g.ilmu == before + 55 and not g.inventory.has("ilmu:55"), "ilmu chest gives Ilmu, not an item")

	g.set_flag("pickup:gem", false)
	var p: Node = load("res://entities/world/pickup.tscn").instantiate()
	p.item_id = "gem"
	root.add_child(p)
	check(p.is_queued_for_deletion(), "flagged pickup frees itself")

	DirAccess.remove_absolute("user://npc_test.json")
	quit(1 if fails else 0)
