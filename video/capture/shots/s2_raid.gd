extends "res://video/capture/s4_lib.gd"
## Segment 2: the ruwatan night raid in Desa Purwa (the `raid` story beat, MQ0 0.9). The hero walks into the
## crowd in front of the kelir; the beat plays: shadows step off the screen, the Hunter, Laras taken, the lamp
## goes out. One long take; clips are cut from it.

func config() -> Dictionary:
	return {"music": arg("music", "0") == "1", "max_seconds": 900}


func run() -> void:
	await demo_to("mq0", 8, "desa_purwa")
	G.set_flag("seen_hint_continue")
	hide_ui(["hud", "tracker", "arrow", "menu_hint", "toast", "saved", "quest_card", "tutorial", "area_title", "banner", "prompts"])
	clear_enemies()
	var crowd := Vector2.ZERO
	for n in zone().find_children("*", "", true, false):
		if str(n.get("trigger_id")) == "purwa_crowd":
			crowd = (n as Node2D).global_position
	if crowd == Vector2.ZERO:
		crowd = spot("laras_crowd")
	print("shot: crowd ", crowd, " hero ", hero().global_position)
	teleport(crowd + Vector2(0, float(arg("dy", 44))))
	face(Vector2.UP)
	await wait_seconds(1.0)
	var zm := float(arg("zoom", 2.0))
	if zm != 1.0:
		cam_detach(crowd + Vector2(float(arg("cx", 0)), float(arg("cy", 4))))
		cam_zoom(zm)
	rec_start()
	no_beats = false
	var sb := game_ui().get_node_or_null("StoryBeat")
	if sb:
		sb.set("_busy", false)
	hold_move(Vector2.UP * 0.6)
	await wait_until(func() -> bool: return dbox() != null and dbox().is_open(), 600, "raid beat did not start")
	stop()
	mark("beat_open")
	var n := 0
	while dbox().is_open():
		await wait_until(dline_done, 1200, "line never finished")
		print("shot: line %d at frame %d: %s" % [n, frame, dtext()])
		mark("line_%d" % n)
		n += 1
		await dadvance(float(arg("hold", 2.0)))
		await wait_frames(2)
	mark("beat_closed")
	await wait_seconds(float(arg("after", 3.0)))
	rec_stop()
