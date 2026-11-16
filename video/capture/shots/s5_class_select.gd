extends "res://video/capture/s5_lib.gd"
## The real class-select screen: the cursor walks down the list and each of the eight classes takes the pedestal
## in turn (figure, role, stats, weapon, path). About 8.5 s.

func config() -> Dictionary:
	return {"music": false}


func run() -> void:
	get_tree().change_scene_to_file("res://ui/class_select.tscn")
	await wait_frames(3)
	var cs := get_tree().current_scene
	await wait_seconds(0.6)
	var cards: Array = cs.cards
	cards[0].grab_focus()
	show_cursor(true)
	var per: float = float(arg("per", 1.05))
	await wait_seconds(0.2)
	rec_start()
	for i in cards.size():
		var c: Control = cards[i]
		mouse_screen((c.global_position + c.size * Vector2(0.8, 0.5)).round())
		if i > 0:
			press("ui_down")
			await wait_frames(2)
			press("ui_down", false)
			if not c.has_focus():
				c.grab_focus()
		mark("class_%d" % i)
		await wait_seconds(per)
	rec_stop()
