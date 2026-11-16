extends "res://video/capture/s4_lib.gd"
## Segment 2: the wayang prologue cards (ui/prologue.tscn): the backlit kelir, the blencong flame, Aji Saka's
## puppet walks on, the hanacaraka letters appear on the screen. Two narration cards. Hold-to-skip hint hidden.

func config() -> Dictionary:
	return {"music": arg("music", "0") == "1"}


func run() -> void:
	new_game("mage")
	get_tree().change_scene_to_file("res://ui/prologue.tscn")
	await wait_until(func() -> bool: return get_tree().current_scene != null and get_tree().current_scene.scene_file_path.ends_with("prologue.tscn"), 120, "prologue did not load")
	var p := get_tree().current_scene
	var hide_hint := func() -> void:
		if is_instance_valid(p):
			for c in p.get_children():
				if c is Label and (c as Label).text == "UI_HOLD_SKIP" or (c is Label and (c as Label).position == Vector2(232, 258)):
					(c as CanvasItem).visible = false
	RenderingServer.frame_pre_draw.connect(hide_hint)
	rec_start()
	for i in 2:
		await wait_until(func() -> bool: return not (p._tw and p._tw.is_running()), 900, "card never typed")
		mark("card_%d_typed" % (i + 1))
		await wait_seconds(float(arg("hold", 3.0)))
		if i == 0:
			press("interact")
			await wait_frames(1)
			press("interact", false)
	rec_stop()
	RenderingServer.frame_pre_draw.disconnect(hide_hint)
