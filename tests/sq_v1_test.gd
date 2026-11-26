extends SceneTree
## SQ-V1 "the small ruwatan" (quests.md 5, gua_kala.md): data shape, unlock on mq5_1c, the four steps driven
## by Events (not dialogue), then the reward: blencong, codex murwakala, Ilmu S for Gua Kala.

var fails := 0
const PATH := "user://sq_v1_test.json"
const ON := ["talked_to:echo_ki_sumarto", "clue_examined:sqv1_offerings", "area_entered:sqv1_ruwatan_place",
	"talked_to:echo_ki_sumarto"]


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	var g: Node = root.get_node("Game")
	var ev: Node = root.get_node("Events")
	g.save_path = PATH
	g._reset()
	g.class_id = "warrior"

	var q: QuestData = load("res://data/quests/sq_v1.tres")
	check(q != null and q.id == "sq_v1" and q.kind == "side" and q.zone == "gua_kala" and q.size == "S", "header")
	check(q.giver == "echo_ki_sumarto" and q.requires == ["mq5_1c"], "giver/requires: %s %s" % [q.giver, q.requires])
	check(q.steps.size() == 4, "4 steps, got %d" % q.steps.size())
	for i in mini(4, q.steps.size()):
		check(q.steps[i].on == ON[i], "step %d on = %s" % [i, q.steps[i].on])
		check(q.steps[i].marker.get("zone", "") == "gk_hutan", "step %d marker zone" % i)
	for item in q.rewards.get("items", []):
		check(ItemData.by_id(item) != null, "reward item %s exists" % item)
	for c in q.rewards.get("codex", []):
		check(CodexEntry.by_id(c) != null, "reward codex %s exists" % c)

	check(g.quest_state("sq_v1") == "locked", "locked before mq5_1c")
	g.set_flag("mq5_1c", false)
	check(g.quest_state("sq_v1") == "available", "available after mq5_1c")
	check(g.start_quest("sq_v1"), "start")
	var ilmu0: int = g.ilmu
	ev.clue_examined.emit("sqv1_offerings")
	check(g.quests.sq_v1.step == 0, "a later step advanced early")
	ev.talked_to.emit("echo_ki_sumarto")
	check(g.quests.sq_v1.step == 1, "step 0 -> 1: %s" % g.quests.sq_v1)
	ev.clue_examined.emit("sqv1_offerings")
	check(g.quests.sq_v1.step == 2, "step 1 -> 2: %s" % g.quests.sq_v1)
	ev.area_entered.emit("sqv1_ruwatan_place")
	check(g.quests.sq_v1.step == 3, "step 2 -> 3: %s" % g.quests.sq_v1)
	ev.talked_to.emit("echo_ki_sumarto")
	check(g.quest_state("sq_v1") == "done", "done: %s" % g.quests.sq_v1)
	check("blencong" in g.inventory, "keepsake blencong granted: %s" % [g.inventory])
	check("murwakala" in g.codex, "codex murwakala unlocked")
	check(g.ilmu - ilmu0 == 190, "Ilmu S Gua Kala = 190, got %d" % (g.ilmu - ilmu0))
	g.class_id = "dalang"   # a Dalang may own the blencong already (genitri sibling): Ilmu instead
	var dr: Dictionary = g.quest_rewards(QuestData.by_id("sq_v1"))
	check(dr.get("items", ["x"]).is_empty() and int(dr.get("ilmu", 0)) == 190 and "murwakala" in dr.get("codex", []), "dalang rewards: %s" % dr)

	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	quit(1 if fails else 0)
