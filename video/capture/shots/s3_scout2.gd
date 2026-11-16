extends "res://video/capture/s3_lib.gd"
## Dev tool: stills of a zone at given views. --set demo=N (or none) --set flags=a,b --set zone=z --set views="x:y:zoom;x:y:zoom" --set tag=name
func run() -> void:
	var d: int = arg("demo", -1)
	if d >= 0:
		await start_demo({"index": d})
	else:
		new_game("mage")
	for f in str(arg("flags", "")).split(",", false):
		flag(f)
	await go(str(arg("zone", "desa_purwa")), str(arg("spawn", "")))
	make_strong(20)
	hide_hud(); hide_cursor()
	if not arg("enemies", false):
		clear_enemies()
	if str(arg("tint", "")) != "":
		var t := str(arg("tint", "")).split(",")
		grade(Color(float(t[0]), float(t[1]), float(t[2])))
	print("scout2: rect ", map_rect(), " hero ", hero().global_position)
	for n in get_tree().get_nodes_in_group("spawn"):
		print("scout2: spawn ", n.id, " ", n.global_position)
	for n in zone().get("entities").get_children():
		if n.scene_file_path.ends_with("npc.tscn"):
			print("scout2: npc ", n.get("npc_id"), " ", n.global_position)
	await wait_seconds(float(arg("wait", 2.0)))
	var i := 0
	for v in str(arg("views", "")).split(";", false):
		var q := v.split(":")
		cam_detach(Vector2(float(q[0]), float(q[1])))
		cam_limits(false)
		var zm := float(q[2])
		_cam.zoom = Vector2(zm, zm)
		await wait_frames(8)
		get_viewport().get_texture().get_image().save_png("res://video/out/scout/%s_%d.png" % [arg("tag", "v"), i])
		i += 1
	rec_start()
	await wait_frames(2)
	rec_stop()
