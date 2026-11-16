extends "res://video/capture/s5_lib.gd"
## The pause menu's Culture Codex (all 97 entries unlocked): the book opens on the Codex, the left page (bestiary,
## legends) scrolls through folktale figures, each with what the legend says and what the game invented; then the
## right page (items, aksara). ~8 s.

func config() -> Dictionary:
	return {"music": false}


func run() -> void:
	await start_new("warrior", "desa_purwa")
	clear_enemies()
	hide_hud()
	unlock_codex()
	for e in G.codex:
		var k := "CODEX_%s_WEAK" % e.to_upper()
		if int(arg("weak", 0)) == 1 and tr(k) != k:
			G.flags["weak:" + e] = true   # the "how to fight" lines show (only where one exists)
	await wait_seconds(1.0)
	var menu: Node = game_ui().get_node("Menu")
	menu.open(false, int(arg("tab", 4)))
	await wait_seconds(0.8)
	var t: Node = menu.tab(int(arg("tab", 4)))
	var left: ScrollContainer = t.list.get_parent()
	var right: ScrollContainer = t._right.get_parent()
	await wait_frames(3)
	var ly := _head_y(t.list, "UI_CAT_LEGEND")
	var ry := _head_y(t._right, "UI_CAT_AKSARA")
	print("s5: legend y ", ly, " aksara y ", ry)
	left.scroll_vertical = int(ly) - int(arg("lpre", 150))
	right.scroll_vertical = int(ry) - 40
	await wait_frames(3)
	print("s5: left max ", left.get_v_scroll_bar().max_value, " right max ", right.get_v_scroll_bar().max_value)
	rec_start()
	await wait_seconds(0.8)
	await _scroll(left, int(ly) + int(arg("lpost", 330)), float(arg("ls", 3.6)))
	await wait_seconds(0.6)
	await _scroll(right, int(ry) + int(arg("rpost", 220)), float(arg("rs", 2.2)))
	await wait_seconds(0.8)
	rec_stop()


func _scroll(sc: ScrollContainer, to: int, seconds: float) -> void:
	var from := sc.scroll_vertical
	var n := roundi(seconds * FPS)
	for i in n:
		sc.scroll_vertical = roundi(lerpf(from, to, ease_t(float(i + 1) / n, "in_out")))
		await wait_frames(1)


func _head_y(box: Control, key: String) -> float:
	for c in box.get_children():
		if c is Label and c.text == tr(key):
			return c.position.y
	return 0.0
