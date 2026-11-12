extends SceneTree
## Puzzle props (quests.md 9.2-9.4, 9.9): each step completes only after ALL its props are pressed, in-order props
## refuse the wrong order (quiet, one hint line), and a prop does nothing before its step. A press is what Npc.interact
## does: pick the entry, run its actions, emit talked_to unless the entry is quiet.
## Run: $GODOT --headless --path . -s tests/puzzle_test.gd

var fails := 0
var g: Node
var ev: Node
var written: Array[String] = []


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func press(id: String) -> Dictionary:
	var d := DialogueData.by_id(id)
	if d == null:
		check(false, "no dialogue for %s" % id)
		return {}
	var e: Dictionary = g.pick_entry(d.entries)
	for a: String in e.get("do", []):
		g.run(a)
	if not (e.get("quiet", false) or e.get("hub", false) or e.has("topic")):
		ev.talked_to.emit(id)
	return e


func at(q: String, step: int) -> void:
	g.quests[q] = {"state": "active", "step": step, "count": 0, "resolution": "", "all": 0}


func step_of(q: String) -> int:
	return -1 if not g.quests.has(q) else (99 if g.quests[q].state == "done" else int(g.quests[q].step))


## Press every prop but the last: the step must hold. Then the last: it must advance.
func all_props(q: String, step: int, ids: Array, label: String) -> void:
	for i in ids.size():
		check(step_of(q) == step, "%s: advanced early after %d of %d props (%s)" % [label, i, ids.size(), g.quests.get(q)])
		press(ids[i])
		check(g.has_flag(ids[i]), "%s: %s did not set its flag" % [label, ids[i]])


## Wrong order first: quiet, a hint line, no flag. Then the right order.
func in_order(q: String, step: int, ids: Array, label: String) -> void:
	for k in range(ids.size() - 1, 0, -1):
		var e := press(ids[k])
		check(e.get("quiet", false) and e.get("lines", []).size() == 1, "%s: %s out of order is not a quiet hint: %s" % [label, ids[k], e])
		check(not g.has_flag(ids[k]), "%s: %s accepted out of order" % [label, ids[k]])
	press(ids[0])
	if ids.size() > 2:
		var e := press(ids[2])
		check(not g.has_flag(ids[2]), "%s: %s accepted before %s" % [label, ids[2], ids[1]])
		check(e.get("quiet", false), "%s: wrong order not quiet" % label)
	all_props(q, step, ids.slice(1), label)


func _initialize() -> void:
	await process_frame
	g = root.get_node("Game")
	ev = root.get_node("Events")
	g.save_path = "user://puzzle_test.json"
	g._reset()
	g.class_id = "warrior"
	ev.write_requested.connect(func(id: String, _gl: PackedStringArray) -> void: written.append(id))

	# MQ0 0.1 tag: cat, well, root (press-each x3)
	at("mq0", 4)
	press("stage_lamp_1")
	check(not g.has_flag("stage_lamp_1"), "stage lamp lit before its step")
	at("mq0", 0)
	all_props("mq0", 0, ["purwa_cat", "purwa_well", "purwa_root"], "mq0 0.1")
	check(step_of("mq0") == 1 and g.has_flag("mq0_d1") and g.has_flag("tag_cat") and g.has_flag("tag_banyan"), "mq0 0.1 done: %s" % g.quests.mq0)

	# MQ0 0.3: Ciung refuses (quiet), the basket appears, then Ciung talks
	at("mq0", 2)
	var e := press("ciung_wanara")
	check(e.get("quiet", false) and g.has_flag("ciung_asked") and step_of("mq0") == 2, "mq0 0.3 refusal: %s" % e)
	check(g.check("flag:ciung_asked"), "basket clue cond")
	g.run("clue:ciung_basket")
	check(step_of("mq0") == 2, "mq0 0.3 advanced on the basket alone")
	press("ciung_wanara")
	check(step_of("mq0") == 3 and g.has_flag("mq0_d3"), "mq0 0.3 done: %s" % g.quests.mq0)

	# MQ0 0.4: the oil seller, then Cepot
	press("purwa_oil_seller")
	check(step_of("mq0") == 3, "mq0 0.4 advanced on the seller alone")
	ev.talked_to.emit("cepot")
	check(step_of("mq0") == 4 and g.has_flag("mq0_d6"), "mq0 0.4 done: %s" % g.quests.mq0)

	# MQ0 0.6: Laras opens the write card for La
	at("mq0", 5)
	written.clear()
	press("laras")
	check(written == ["laras_la"], "mq0 0.6: Laras did not open the write card: %s" % [written])
	check(step_of("mq0") == 5, "mq0 0.6 advanced before the card was written")
	ev.name_written.emit("laras_la")
	check(step_of("mq0") == 6 and g.has_flag("mq0_d5"), "mq0 0.6 done: %s" % g.quests.mq0)

	# MQ0 0.7: four stage lamps
	all_props("mq0", 6, ["stage_lamp_1", "stage_lamp_2", "stage_lamp_3", "stage_lamp_4"], "mq0 0.7")
	check(step_of("mq0") == 7 and g.has_flag("mq0_d6b"), "mq0 0.7 done: %s" % g.quests.mq0)

	# MQ0 0.12: raid, leave, and Ibu at the gate
	at("mq0", 11)
	ev.area_cleared.emit("purwa_raid")
	ev.zone_entered.emit("ts_kebun")
	check(step_of("mq0") == 11, "mq0 0.12 done without Ibu")
	press("ibu")
	check(step_of("mq0") == 99, "mq0 0.12 done: %s" % g.quests.mq0)

	# MQ1 1.8: three lanterns and the mist
	at("mq1", 7)
	all_props("mq1", 7, ["leuwi_oncor_1", "leuwi_oncor_2", "leuwi_oncor_3"], "mq1 1.8")
	check(step_of("mq1") == 7, "mq1 1.8 done before the mist fight")
	ev.area_cleared.emit("leuwi_mist")
	check(step_of("mq1") == 8 and g.has_flag("mq1_h2b"), "mq1 1.8 done: %s" % g.quests.mq1)

	# MQ1 1.11: the scouts, then the name-stones east to west
	at("mq1", 10)
	ev.area_cleared.emit("sunda_batutulis")
	in_order("mq1", 10, ["batu_stone_1", "batu_stone_2", "batu_stone_3"], "mq1 1.11")
	check(step_of("mq1") == 11 and g.has_flag("mq1_4") and g.has_flag("batu_3"), "mq1 1.11 done: %s" % g.quests.mq1)

	# MQ1 1.15: two upper sluice wheels and the weaver
	at("mq1", 14)
	all_props("mq1", 14, ["sluice_wheel_1", "sluice_wheel_2"], "mq1 1.15")
	check(step_of("mq1") == 14 and g.has_flag("sluice_2"), "mq1 1.15 wheels: %s" % g.quests.mq1)
	ev.talked_to.emit("sunda_weaver")
	check(step_of("mq1") == 15 and g.has_flag("mq1_6"), "mq1 1.15 done: %s" % g.quests.mq1)

	# MQ1 1.24: hang the cloth, then the boss
	at("mq1", 23)
	e = press("rarang_post")
	check(e.get("quiet", false) and not g.has_flag("rarang_post"), "mq1 1.24: post took no cloth: %s" % e)
	check(not g.check("flag:mq1_8,flag:rarang_post"), "boss cond before the cloth")
	g.add_item("boeh_rarang", false)
	press("rarang_post")
	check(g.has_flag("rarang_post") and g.has_flag("post:east") and step_of("mq1") == 23, "mq1 1.24 cloth: %s" % g.quests.mq1)
	ev.boss_defeated.emit("sangkuriang")
	check(step_of("mq1") == 99 and g.has_flag("mq1_10"), "mq1 1.24 done: %s" % g.quests.mq1)

	# MQG g.7: mirrors in order, then the scraped lontar
	at("mqg", 6)
	in_order("mqg", 6, ["archive_mirror_1", "archive_mirror_2", "archive_mirror_3"], "mqg g.7")
	check(step_of("mqg") == 6, "mqg g.7 done before the clue")
	ev.clue_examined.emit("scraped_genealogy")
	check(step_of("mqg") == 7 and g.has_flag("mqg_ar2"), "mqg g.7 done: %s" % g.quests.mqg)

	# MQG g.9: three screens, then the hairpin
	at("mqg", 8)
	all_props("mqg", 8, ["kaputren_screen_1", "kaputren_screen_2", "kaputren_screen_3"], "mqg g.9")
	check(g.check("flag:kaputren_screen_1,flag:kaputren_screen_2,flag:kaputren_screen_3"), "hairpin cond")
	ev.clue_examined.emit("laras_hairpin")
	check(step_of("mqg") == 9 and g.has_flag("mqg_kp2"), "mqg g.9 done: %s" % g.quests.mqg)

	# MQG g.13: the wall must be read
	at("mqg", 12)
	ev.area_cleared.emit("galuh_cells")
	check(step_of("mqg") == 12 and g.has_flag("mqg_cells") and not g.has_flag("mqg_5"), "mqg g.13 done without the wall: %s" % g.quests.mqg)
	ev.clue_examined.emit("laras_wall")
	check(step_of("mqg") == 13 and g.has_flag("mqg_5"), "mqg g.13 done: %s" % g.quests.mqg)

	# SQ-S3: three tubes, then the frame low to high
	at("sq_s3", 0)
	for t in ["angklung_1", "angklung_2"]:
		ev.item_picked.emit(t)
	check(step_of("sq_s3") == 0, "sq_s3 advanced after 2 tubes")
	ev.item_picked.emit("angklung_3")
	check(step_of("sq_s3") == 1, "sq_s3: 3 tubes did not finish step 1: %s" % g.quests.sq_s3)
	in_order("sq_s3", 1, ["angklung_frame_1", "angklung_frame_2", "angklung_frame_3"], "sq_s3 frame")
	check(step_of("sq_s3") == 2, "sq_s3 frame done: %s" % g.quests.sq_s3)

	# SQ-C1 step 4: grain on three roofs
	at("sq_c1", 3)
	all_props("sq_c1", 3, ["grain_roof_1", "grain_roof_2", "grain_roof_3"], "sq_c1")
	check(step_of("sq_c1") == 4 and g.has_flag("c1_rooster_found"), "sq_c1 step 4 done: %s" % g.quests.sq_c1)

	# SQ-S2 step 5: carving is a write card
	at("sq_s2", 4)
	written.clear()
	press("kepala_desa")
	check(written == ["s2_grave"] and step_of("sq_s2") == 4, "sq_s2: no write card: %s" % [written])
	ev.name_written.emit("s2_grave")
	check(step_of("sq_s2") == 99, "sq_s2 done: %s" % g.quests.sq_s2)

	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://puzzle_test.json"))
	quit(1 if fails > 0 else 0)
