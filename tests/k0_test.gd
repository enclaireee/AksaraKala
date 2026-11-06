extends SceneTree
## K0 (desa_purwa.md "Kelir memory K0"), headless: the first lamp starts lit, the shadow stops at lit ground,
## touching it fails back to the stand, a lit lamp is the checkpoint and pushes the shadow back, the goal waits
## for every lamp.

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	root.get_node("Game")._reset()
	root.get_node("Zones").memory_id = "k0_ruwatan"
	var m: Node = load("res://zones/kelir/k0_ruwatan.tscn").instantiate()
	root.add_child(m)
	await close_box(m)
	await run(m)
	m.queue_free()
	root.get_node("Zones").memory_id = ""
	quit(1 if fails > 0 else 0)


func frames(n: int) -> void:
	for i in n:
		await process_frame


## Closes any open dialogue box (narration) and unpauses.
func close_box(m: Node) -> void:
	await frames(3)
	var box: Node = m.find_child("DialogueBox", true, false)
	while box and box.is_open():
		box._close()
		await frames(1)
	paused = false


func run(m: Node) -> void:
	var l: Array = m.lamps()
	check(l.size() == 4 and l[0].done and not l[1].done, "4 lamps, the first lit")
	check(l[1].line_key == "MEM_K0_RUWATAN_1" and l[0].line_key == "", "lamp lines in lighting order")
	m.edge = 216.0
	var end := Time.get_ticks_msec() + 2000   # 8 px at 16 px/s, plus slack
	while Time.get_ticks_msec() < end:
		await process_frame
	check(is_equal_approx(m.edge, l[0].position.x + m.LAMP_R), "shadow stops at lit ground: %f" % m.edge)
	m.stand_in.position.x = m.edge + 2
	await physics_frame   # the shadow check runs in _physics_process; headless process frames can outrun it
	await physics_frame
	check(m._busy, "touching the shadow fails")
	while m._busy:
		await process_frame
	check(m.stand_in.position.x < 60, "fail returns to the stand with no lamp lit since")

	l[1].interact()
	await close_box(m)
	check(l[1].done and m.checkpoint == l[1], "a lit lamp is the checkpoint")
	await frames(2)
	check(m.edge >= l[1].position.x + m.LAMP_R - 0.1, "lighting pushes the shadow back: %f" % m.edge)

	var goal: MemorySpot = m.spots().filter(func(s: MemorySpot) -> bool: return s.action_kind == "goal")[0]
	goal.interact()
	check(not goal.done, "the goal waits for every lamp")
