extends "res://video/capture/shot.gd"
## Dev tool (segments 1/2/4): one zone, zoomed overview + a few frames around the spawn.
## --set demo=<i> --set zone=<id> [--set zoom=0.5]
func run() -> void:
	var d: int = int(arg("demo", 49))
	await start_demo({"index": d})
	var z: String = arg("zone", "")
	if z != "" and Z.current_zone != z:
		await go(z)
	hide_hud()
	clear_enemies()
	var r := map_rect()
	print("shot: zone ", Z.current_zone, " map ", r, " hero ", hero().global_position)
	for n in get_tree().get_nodes_in_group("spawn"):
		print("shot: spawn ", n.id, " ", n.global_position)
	await wait_seconds(0.5)
	cam_detach(r.get_center())
	cam_limits(false)
	var zm: float = float(arg("zoom", 0.25))
	_cam.zoom = Vector2(zm, zm)
	await wait_frames(3)
	rec_start()
	await wait_frames(2)
	_cam.zoom = Vector2(1, 1)
	cam_detach(hero().global_position)
	await wait_frames(2)
	rec_stop()
