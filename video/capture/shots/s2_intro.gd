extends "res://video/capture/s4_lib.gd"
## Segment 2: the game's launch intro (ui/intro.gd, 10 s: Kala's face in the storm, the Wiku on the crag writes
## Sundanese Ka in light, the storm breaks, the logo slams in), then into the title screen. No skip hint.
## --set music=1 records the intro's own music (its sound design is in the track).

func config() -> Dictionary:
	return {"music": arg("music", "0") == "1"}


func run() -> void:
	load("res://ui/title.gd").save_language("en")
	get_tree().change_scene_to_file("res://ui/intro.tscn")
	await wait_until(func() -> bool: return get_tree().current_scene != null and get_tree().current_scene.scene_file_path.ends_with("intro.tscn"), 120, "intro did not load")
	var intro := get_tree().current_scene
	var hint_hide := func() -> void:
		var h: Variant = intro.get("_skip_hint") if is_instance_valid(intro) else null
		if h:
			(h as CanvasItem).visible = false
	RenderingServer.frame_pre_draw.connect(hint_hide)
	rec_start()
	mark("intro_start")
	await wait_until(func() -> bool: return get_tree().current_scene != null and get_tree().current_scene.scene_file_path.ends_with("title.tscn"), 900, "title never came")
	mark("title_start")
	RenderingServer.frame_pre_draw.disconnect(hint_hide)
	var t := get_tree().current_scene
	var hide_menu := func() -> void:
		var b: Variant = t.get("_box") if is_instance_valid(t) else null
		if b:
			(b as CanvasItem).visible = false
		var l: Variant = t.get("_lang") if is_instance_valid(t) else null
		if l:
			(l as CanvasItem).visible = false
	if arg("menu", "0") != "1":
		RenderingServer.frame_pre_draw.connect(hide_menu)
	await wait_seconds(float(arg("tail", 4.0)))
	rec_stop()
	if RenderingServer.frame_pre_draw.is_connected(hide_menu):
		RenderingServer.frame_pre_draw.disconnect(hide_menu)
