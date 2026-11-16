extends "res://video/capture/s3_lib.gd"
## The in-game world map (pause menu, MAP tab, world view), held steady for 6 s.
func run() -> void:
	await start_demo({"index": 46})
	make_strong(20)
	god = true
	hide_hud(); hide_cursor()
	clear_enemies()
	await wait_seconds(1.0)
	var menu: Node = game_ui().get_node("Menu")
	menu.open(false, 3)
	await wait_seconds(1.0)
	var t: Node = menu.tab(3)
	var note = t.get("_note")
	if note:
		note.text = ""
	var view = t.get("_view")
	if view:
		view.mode = "world"
	await wait_seconds(0.5)
	rec_start()
	await wait_seconds(6.0)
	rec_stop()
