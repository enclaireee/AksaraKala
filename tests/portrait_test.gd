extends SceneTree
## Speaker portraits (ui.md 3.1): every mapped bust is 48x48 with happy/angry/sad variants, the mood lookup falls back
## to neutral, and "#face:<mood>" (cue line or inline tag) swaps the face and never shows as text.

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	await run()
	quit(1 if fails > 0 else 0)


func frames(n: int) -> void:
	for i in n:
		await process_frame


func run() -> void:
	# 1. files: every mapped portrait and its variants exist at 48x48
	var names := {}
	for id: String in Portraits.MAP:
		names[Portraits.MAP[id]] = true
	for n: String in names:
		for suffix: String in ["", "_happy", "_angry", "_sad"]:
			var p := "res://assets/art/portraits/p_%s%s.png" % [n, suffix]
			var t := load(p) as Texture2D if ResourceLoader.exists(p) else null
			check(t != null, "portrait exists: " + p)
			if t:
				check(t.get_width() == 48 and t.get_height() == 48, "portrait is 48x48: " + p)
	var fr := load("res://assets/art/ui/frame_portrait.png") as Texture2D
	check(fr != null and fr.get_width() == 56 and fr.get_height() == 56, "frame_portrait is 56x56")

	# 2. lookup and fallback
	var neutral := Portraits.for_key("NPC_HERO_NAME")
	check(neutral != null, "hero has a portrait")
	check(Portraits.for_key("NPC_HERO_NAME", "neutral") == neutral, "neutral mood is the base bust")
	check(Portraits.for_key("NPC_HERO_NAME", "bogus") == neutral, "unknown mood falls back to neutral")
	var angry := Portraits.for_key("NPC_HERO_NAME", "angry")
	check(angry != null and angry != neutral, "angry variant differs from neutral")
	check(Portraits.for_key("NPC_NOBODY_NAME", "happy") == null, "unmapped speaker has no face")
	check(Portraits.for_key("DLG_SOMETHING") == null, "non-speaker key has no face")

	# 3. inline tag parsing
	var a := Portraits.strip_face("Hello there. #face:happy")
	check(a[0] == "Hello there." and a[1] == "happy", "inline tag stripped: %s" % [a])
	var b := Portraits.strip_face("A #face:sad B")
	check(b[0] == "A B" and b[1] == "sad", "mid-line tag stripped: %s" % [b])
	var c := Portraits.strip_face("No tag # here")
	check(c[0] == "No tag # here" and c[1] == "", "text without a tag is untouched")

	# 4. the dialogue box swaps faces and never shows the tag
	var game := root.get_node("Game")
	game.save_path = "user://test_portrait.json"
	game._reset()
	var ev := root.get_node("Events")
	var ui: Node = load("res://ui/game_ui.tscn").instantiate()
	ui.get_node("StoryBeat").free()
	root.add_child(ui)
	await frames(3)
	var box: Node = ui.get_node("DialogueBox")
	ev.dialogue_requested.emit("NPC_HERO_NAME", PackedStringArray(["#face:angry", "LINE_A", "LINE_B #face:happy", "@NPC_LARAS_NAME", "LINE_C"]))
	await frames(1)
	check(box.is_open(), "box open")
	check(box._portrait.size == Vector2(48, 48), "portrait drawn at 48x48")
	check(box._portrait.texture == angry, "#face:angry cue line swaps the face")
	check(box._text.text == "LINE_A", "cue line not shown: '%s'" % box._text.text)
	check(box._portrait.position - box._portrait_frame.position == Vector2(4, 4), "bust inset 4 px in the frame")
	check(is_equal_approx(box._portrait_frame.position.y + 56.0 - 8.0, box._frame.position.y), "frame overlaps the box by 8 px")
	check(is_equal_approx(box._plate.position.x, 28.0 + 66.0), "name plate steps right of the face (x+66)")
	box._next()
	check(box._text.text == "LINE_B", "inline tag stripped from the shown line: '%s'" % box._text.text)
	check(box._portrait.texture == Portraits.for_key("NPC_HERO_NAME", "happy"), "inline tag swaps the face")
	box._next()
	check(box._text.text == "LINE_C", "next speaker's line")
	check(box._portrait.texture == Portraits.for_key("NPC_LARAS_NAME"), "a new speaker starts neutral")
	box._close()
	await frames(1)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_portrait.json"))
