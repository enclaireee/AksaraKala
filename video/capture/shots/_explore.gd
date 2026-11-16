extends "res://video/capture/shot.gd"
## Dev tool: an overview of a zone. --set zone=<id> [--set zoom=0.2] [--set demo=<index>] [--set wait=2.0]
## Writes a few frames: the whole map zoomed out, then the camera on the spawn.
func run() -> void:
	var z: String = arg("zone", "ts_kampung")
	var d: int = arg("demo", -1)
	if d >= 0:
		await start_demo({"index": d})
		if Z.current_zone != z:
			await go(z)
	else:
		await start_new("mage", z)
	hide_hud()
	var r := map_rect()
	print("shot: map rect ", r, " hero at ", hero().global_position)
	for n in get_tree().get_nodes_in_group("spawn"):
		print("shot: spawn ", n.id, " ", n.global_position)
	for n in zone().get("entities").get_children():
		if n.scene_file_path.ends_with("npc.tscn"):
			print("shot: npc ", n.get("npc_id"), " ", n.global_position, " groups ", n.get_groups())
	print("shot: enemies ", enemies().size())
	await wait_seconds(arg("wait", 1.0))
	var cx: float = arg("x", r.get_center().x)
	var cy: float = arg("y", r.get_center().y)
	cam_detach(Vector2(cx, cy))
	cam_limits(false)
	var zm: float = arg("zoom", 0.2)
	_cam.zoom = Vector2(zm, zm)
	await wait_frames(3)
	rec_start()
	await wait_frames(2)
	rec_stop()
