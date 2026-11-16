extends "res://video/capture/shot.gd"
## Dev tool (segment 3): saves one zoomed-out still per zone into video/out/scout/. --set zones=a,b --set demo=38 --set zoom=0.25
func run() -> void:
	var d: int = arg("demo", 38)
	await start_demo({"index": d})
	var zs: PackedStringArray = str(arg("zones", "")).split(",", false)
	if zs.is_empty():
		zs = PackedStringArray(Z.ZONES.keys())
	var zm: float = arg("zoom", 0.25)
	for z in zs:
		await go(z)
		hide_hud()
		clear_enemies()
		var r := map_rect()
		print("scout: ", z, " rect ", r)
		await wait_frames(20)
		cam_detach(r.get_center())
		cam_limits(false)
		_cam.zoom = Vector2(zm, zm)
		await wait_frames(6)
		get_viewport().get_texture().get_image().save_png("res://video/out/scout/%s_%d.png" % [z, d])
	rec_start()
	await wait_frames(2)
	rec_stop()
