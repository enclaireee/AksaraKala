extends SceneTree
## Launch intro (ui.md 4.0): the boot scene is the intro, its art and score exist, the timeline runs to the end
## and hands over in about ten seconds, a key press skips, and the skip hint resolves in both languages.

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	await run()
	quit(1 if fails > 0 else 0)


func run() -> void:
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://ui/intro.tscn", "the game boots into the intro")
	for n in ["storm_sky", "kala_close", "kala_close_eyes", "kala_sky", "kala_sky_eyes", "storm_far", "storm_mid",
			"storm_peak", "hero_storm", "lightning", "glow_cyan", "glow_red", "dawn_sky", "beam", "ring"]:
		check(ResourceLoader.exists("res://assets/art/intro/%s.png" % n), "intro art %s" % n)
	check(ResourceLoader.exists("res://assets/audio/music/intro.ogg"), "intro score")

	var Intro := load("res://ui/intro.gd")
	for key: String in Intro.LINES:
		check(Intro.LINES[key].size() == 2 and Intro.LINES[key][0] != "" and Intro.LINES[key][1] != "", "line %s has id + en" % key)

	# the whole timeline, fast-forwarded: every beat fires without error and it leaves on its own
	var a: Control = load("res://ui/intro.tscn").instantiate()
	a.next_scene = ""
	var done := [false]
	a.finished.connect(func() -> void: done[0] = true)
	root.add_child(a)
	await process_frame
	check(a.T_OUT + 0.8 <= 10.5, "about ten seconds long")
	check(a._ka.stroke.size() > 1, "the Ka has a stroke to write")
	var t := 0.0
	while t < a.T_OUT + 0.2:
		a._process(0.1)
		t += 0.1
	check(a._ei == a._events.size(), "every beat fired")
	check(a._leaving, "the intro leaves at the end of the timeline")
	await create_timer(1.5).timeout
	check(done[0], "finished after the fade")
	a.queue_free()
	await process_frame

	# skipping
	var b: Control = load("res://ui/intro.tscn").instantiate()
	b.next_scene = ""
	root.add_child(b)
	await process_frame
	b._process(0.5)
	var ev := InputEventKey.new()
	ev.pressed = true
	ev.physical_keycode = KEY_SPACE
	b._input(ev)
	check(b._leaving, "a key press skips")
	b.queue_free()
	await process_frame
