extends SceneTree

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	await run()
	Engine.time_scale = 1.0
	quit(1 if fails > 0 else 0)


func frames(n: int) -> void:
	for i in n:
		await process_frame


func run() -> void:
	var o: CastOverlay = load("res://ui/cast_overlay.tscn").instantiate()
	root.add_child(o)
	check(not o.is_open(), "closed initially")
	o.begin()
	check(o.is_open(), "begin opens")
	o.add_point(Vector2(10, 10))
	o.add_point(Vector2(50, 40))
	check(o._ink.get_point_count() == 2, "add_point grows trail")
	o.finish(true, "Ka")
	await get_root().get_tree().create_timer(1.0, true, false, true).timeout
	check(not o.is_open() and not o.visible, "finish(true) closes")
	o.begin()
	o.add_point(Vector2(10, 10))
	o.finish(false, "")
	await get_root().get_tree().create_timer(1.0, true, false, true).timeout
	check(not o.is_open() and not o.visible, "finish(false) closes")
	o.begin()
	o.cancel()
	check(not o.is_open() and not o.visible, "cancel closes at once")
	var r := Rect2(100, 50, 200, 100)
	o.show_guide(PackedVector2Array([Vector2(0, 0), Vector2(10, 0), Vector2(10, 40), Vector2(30, 40)]), r)
	var ok := o._guide_line != null and o._guide_line.points.size() == 64
	if ok:
		for p in o._guide_line.points:
			ok = ok and r.grow(0.5).has_point(p)
	check(ok, "guide inside rect")
	o.hide_guide()
	check(o._guide_line == null, "hide_guide clears")
	# finish under slow motion: wall-clock wait
	Engine.time_scale = 0.2
	o.begin()
	o.add_point(Vector2(10, 10))
	o.finish(true, "Ka")
	var t0 := Time.get_ticks_msec()
	while o.visible and Time.get_ticks_msec() - t0 < 1500:
		await process_frame
	check(not o.visible and Time.get_ticks_msec() - t0 < 1100, "finish completes under time_scale 0.2")
