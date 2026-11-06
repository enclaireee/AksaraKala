extends SceneTree
## Story beats (data/dialogue/beats.tres): a beat plays once, sets its beat_ flag, and runs its choice's do-list.

var fails := 0


func check(c: bool, msg: String) -> bool:
	if not c:
		fails += 1
		printerr("FAIL: " + msg)
	return c


func _initialize() -> void:
	await process_frame
	var game := root.get_node("Game")
	game.save_path = "user://test_story_beat.json"
	var d: DialogueData = DialogueData.by_id("beats")
	check(d != null and d.entries.size() >= 17, "beats.tres missing or short")
	for e in d.entries:
		var card: bool = e.get("lines", []).is_empty()   # the write card: no lines, replays until its quest flag (mq5_4) is set
		check(String(e["if"][0]).begins_with("!flag:" if card else "!flag:beat_") and (card or String(e["do"][0]).begins_with("flag:beat_")), "beat without once-flag: %s" % [e])
	# truce beat: ready once MQ2 is done, gone after it plays, choice sets its flag
	game.quests["mq2"] = {"state": "done", "step": 0, "count": 0, "resolution": ""}
	game.flags["mq2_9"] = true
	var truce: Dictionary = {}
	for e in d.entries:
		if "flag:beat_truce" in e["do"]:
			truce = e
	check(game.check_all(truce["if"]) if game.has_method("check_all") else truce["if"].all(func(c): return game.check(c)), "truce not ready after mq2 done")
	for a in truce["do"]:
		game.run(a)
	check(game.flags.get("beat_truce", false), "beat_truce not set")
	check(not truce["if"].all(func(c): return game.check(c)), "truce would replay")
	check(game.quests.has("mq3") and game.quests["mq3"]["state"] == "active", "truce did not start mq3")
	for a in truce["choices"][0]["do"]:
		game.run(a)
	check(game.flags.get("choice_mercy", false), "choice_mercy not set")
	# the write card replays after a reload until Laras's name is written (mq5_4), not just once
	game.flags["mq5_3"] = true
	game.flags["beat_write"] = true
	var card := d.pick(game)
	check(card.get("lines", ["x"]).is_empty() and "write:" in str(card["do"]), "write card not re-offered after reload: %s" % [card])
	game.flags["mq5_4"] = true
	check(d.pick(game).is_empty(), "write card still offered after the name was written")
	# a do-only entry must not wait on a dialogue box that never opens
	await game.play("", {"lines": [], "do": ["flag:t_do_only"]})
	check(game.flags.get("t_do_only", false), "do-only play did not run its do")
	quit(1 if fails > 0 else 0)
