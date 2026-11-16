extends "res://video/capture/s5_lib.gd"
## Moral choice 3, Judgment at the Pamali (story.md, the truce beat): Ciung Wanara, the young king, asks what to
## do with the caged usurper. The real dialogue box: his line types out, the two answers come up (mercy: a lit
## cell and a pardon / law: let Galuh's law run), the cursor weighs them, and mercy is chosen. ~8 s.

func config() -> Dictionary:
	return {"music": false}


func run() -> void:
	await start_new("warrior", arg("zone", "kg_pamali"))
	clear_enemies()
	god = true
	hide_hud()
	teleport(hero().global_position + Vector2(float(arg("dx", 150)), 0))
	face(Vector2.RIGHT)
	await wait_seconds(1.5)
	var entry := {
		"lines": ["@NPC_CIUNG_WANARA_NAME", "BEAT_TRUCE_9"],
		"choices": [{"text": "CHOICE_TRUCE_1", "do": ["flag:choice_mercy"]}, {"text": "CHOICE_TRUCE_2", "do": ["flag:choice_judgment"]}],
	}
	var box: Node = get_tree().get_first_node_in_group("dialogue_box")
	show_ui(["dialogue"])
	rec_start()
	await wait_seconds(0.3)
	G.play(arg("npc", "NPC_CIUNG_WANARA"), entry)
	await wait_seconds(float(arg("read", 3.0)))
	var box2: Node = _box()
	for i in 4:
		if box2 and box2.get("_choosing"):
			break
		await _tap("interact")   # completes the typing, then on to the choices
		await wait_seconds(0.25)
	if box2 == null or not box2.get("_choosing"):
		fail("no choices on screen")
	mark("choices")
	await wait_seconds(1.1)
	await _tap("move_down")
	mark("law")
	await wait_seconds(0.9)
	await _tap("move_up")
	mark("mercy")
	await wait_seconds(0.9)
	await _tap("interact")
	mark("chosen")
	await wait_seconds(1.0)
	rec_stop()


func _tap(action: String) -> void:
	press(action)
	await wait_frames(2)
	press(action, false)
	await wait_frames(1)


func _box() -> Node:
	for n in game_ui().find_children("*", "", true, false):
		if n.get("_choosing") != null:
			return n
	return null
