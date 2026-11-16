extends "res://video/capture/s5_lib.gd"
## Dev: --set demo=<index> --set cls=mage. Reaches the boss door, prints the boss and hero, walks in and records.

func config() -> Dictionary:
	return {"music": false, "max_seconds": 900}


func run() -> void:
	await start_demo({"index": int(arg("demo", 10))}, arg("cls", "mage"))
	make_strong(20)
	god = true
	infinite_sakti = true
	show_hud()
	await wait_frames(5)
	boss_log("start")
	for n in get_tree().get_nodes_in_group("spawn"):
		print("s5: spawn ", n.id, " ", n.global_position)
	print("s5: map ", map_rect(), " zone ", Z.current_zone)
	var b := boss()
	if b == null:
		fail("no boss")
		return
	rec_start()
	hold_move((b.global_position - hero().global_position).normalized())
	for i in 40:
		await wait_seconds(0.25)
		boss_log("walk%d" % i)
		if b.get("engaged"):
			break
	stop()
	await watch_boss(float(arg("fight", 8.0)), 0.5)
	rec_stop()
