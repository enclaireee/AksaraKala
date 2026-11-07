extends SceneTree
## QuestCard: queues main quest starts and every quest end, builds reward lines, waits while paused.

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	await run()
	paused = false
	quit(1 if fails > 0 else 0)


func frames(n: int) -> void:
	for i in n:
		await process_frame


func run() -> void:
	var ev := root.get_node("Events")
	var main_id := ""
	var side_id := ""
	for q in QuestData.all():
		var tk := "Q_%s_TITLE" % q.id.to_upper()
		if tr(tk) == tk:   # the card needs a translated title
			continue
		if q.kind == "main" and main_id == "":
			main_id = q.id
		elif q.kind == "side" and side_id == "":
			side_id = q.id
	check(main_id != "" and side_id != "", "fixture quests exist")

	var lines := QuestCard.build_reward_lines({"items": ["nope"], "flask_shard": 1, "herb_pouch": 2, "codex": []}, 30)
	check(lines.size() == 4, "reward lines built: %s" % str(lines))
	check(lines[0] == "+30 Ilmu", "ilmu line first")
	check("+1 flask shard" in lines and "+2 herb pouch" in lines, "shard and pouch lines")
	check(QuestCard.build_reward_lines({}, 0).is_empty(), "empty rewards give no lines")
	check(QuestCard.first_sentence("One two. Three.") == "One two.", "first sentence")
	check(QuestCard.first_sentence("No stop") == "No stop", "first sentence without stop")

	var card := QuestCard.new()
	root.add_child(card)
	card.process_mode = Node.PROCESS_MODE_ALWAYS
	await frames(2)

	paused = true
	ev.emit_signal("quest_started", side_id)
	check(card.pending() == 0, "side start queues nothing")
	ev.emit_signal("quest_started", main_id)
	check(card.pending() == 1, "main start queues a card")
	await frames(3)
	check(card.pending() == 1 and not card.is_showing(), "card waits while the tree is paused")
	paused = false
	await frames(2)
	check(card.is_showing() and card.pending() == 0, "card shows once unpaused")

	ev.emit_signal("quest_completed", side_id)
	check(card.pending() == 1, "quest end queues behind the card on screen")
	card.queue_free()
