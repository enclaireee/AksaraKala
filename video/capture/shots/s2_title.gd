extends "res://video/capture/s4_lib.gd"
## Segment 2: the title screen from its first frame (fade up from night, the logo rises, the subtitle, glyphs
## rising from the Wiku's staff), the menu hidden (--set menu=1 keeps it). 10 s.

func config() -> Dictionary:
	return {"music": arg("music", "0") == "1"}


func run() -> void:
	load("res://ui/title.gd").save_language("en")
	get_tree().change_scene_to_file("res://ui/title.tscn")
	await wait_until(func() -> bool: return get_tree().current_scene != null and get_tree().current_scene.scene_file_path.ends_with("title.tscn"), 120, "title did not load")
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
	rec_start()
	await wait_seconds(float(arg("len", 10.0)))
	rec_stop()
	if RenderingServer.frame_pre_draw.is_connected(hide_menu):
		RenderingServer.frame_pre_draw.disconnect(hide_menu)
	get_tree().current_scene.queue_free()
	await wait_frames(2)
