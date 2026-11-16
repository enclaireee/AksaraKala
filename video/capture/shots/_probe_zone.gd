extends "res://video/capture/shot.gd"
func run() -> void:
	await start_new("mage", "ts_kampung", "from_ts_kebun")
	hide_hud()
	cam_detach(Vector2(1200, 520))
	var m: String = arg("m", "")
	if m == "nosort":
		zone().entities.y_sort_enabled = false
	elif m == "redraw":
		for n in zone().entities.get_children():
			if n is CanvasItem: n.queue_redraw()
	elif m == "deco":
		var d = zone().get("deco")
		if d: d.visible = false
	elif m == "tiles":
		zone().tiles.visible = false
	await wait_frames(2)
	rec_start()
	await wait_frames(1)
	rec_stop()
