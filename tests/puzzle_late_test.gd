extends SceneTree
## Late-act prop puzzles (quests.md 9.5-9.9, Acts III-VI): each step advances only after ALL its props, in-order
## props refuse the wrong order (quiet hint, no flag, no talk), and the side-quest gates open on both Choice 2 outcomes.
## Props are pressed the way npc.gd does it: pick_entry, run its actions, then talked_to unless the entry is quiet.

var fails := 0
var g: Node
const PATH := "user://puzzle_late_test.json"


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func press(id: String) -> Dictionary:
	var d := DialogueData.by_id(id)
	check(d != null, "no dialogue for prop %s" % id)
	if d == null:
		return {}
	var e: Dictionary = g.pick_entry(d.entries)
	for a in e.get("do", []):
		g.run(a)
	if not (e.get("quiet", false) or e.get("hub", false) or e.has("topic")):
		g.on_event("talked_to", id)
	return e


func at(id: String, step: int) -> void:
	g.quests[id] = {"state": "active", "step": step, "count": 0, "resolution": "", "all": 0}


func want(id: String, step: int, why: String) -> void:
	var st: String = g.quest_state(id)
	var now := int(g.quests[id].step) if g.quests.has(id) else -1
	check(st == "active" and now == step or st == "done" and step < 0, "%s: %s is %s step %d, want step %d" % [why, id, st, now, step])


## Press `ids` in order; the step must stay at `step` until the last one (plus `then` events), then move on.
func each(q: String, step: int, ids: Array, then: Array = []) -> void:
	for i in ids.size():
		want(q, step, "before %s" % ids[i])
		press(ids[i])
		check(g.has_flag(ids[i]), "%s did not set its flag" % ids[i])
	for ev in then:
		want(q, step, "before %s" % ev)
		var p: PackedStringArray = ev.split(":", true, 1)
		g.on_event(p[0], p[1])
	want(q, step + 1, "after %s" % ", ".join(ids + then))


## Wrong order: pressing `id` too early is quiet, sets nothing and does not move the step.
func refused(q: String, step: int, id: String) -> void:
	var e := press(id)
	check(e.get("quiet", false) and not e.get("lines", []).is_empty(), "%s out of order should give a quiet hint line" % id)
	check(not g.has_flag(id), "%s out of order set its flag" % id)
	want(q, step, "wrong-order %s" % id)


func _initialize() -> void:
	await process_frame
	g = root.get_node("Game")
	g.save_path = PATH
	g._reset()
	g.class_id = "warrior"

	# 2.12 four shrine braziers in chant order, then Ra from the juru kunci
	at("mq2", 11)
	refused("mq2", 11, "shrine_brazier_2")
	press("shrine_brazier_1")
	refused("mq2", 11, "shrine_brazier_3")
	check(press("juru_kunci").get("quiet", false), "juru kunci teaches Ra before the 4th brazier")
	for i in [2, 3, 4]:
		press("shrine_brazier_%d" % i)
		check(g.has_flag("shrine_brazier_%d" % i), "shrine_brazier_%d in order did not light" % i)
	want("mq2", 11, "4 braziers, no Ra yet")
	press("juru_kunci")   # learn:jawa_ra
	want("mq2", 12, "braziers + Ra")

	# 3.4 two Ha casts at the practice stakes; another glyph does not count
	at("mq3", 3)
	g.on_event("spell_cast", "jawa_ka")
	g.on_event("spell_cast", "jawa_ha")
	want("mq3", 3, "one Ha cast")
	g.on_event("spell_cast", "jawa_ha")
	want("mq3", 4, "two Ha casts")
	# 3.6 seeds at the marker, then the charge
	at("mq3", 5)
	each("mq3", 5, ["seed_marker"], ["area_cleared:buto_ambush_2"])
	# 3.7 three banyan roots and the ambush
	at("mq3", 6)
	each("mq3", 6, ["banyan_root_1", "banyan_root_3", "banyan_root_2"], ["area_cleared:buto_ambush_3"])
	# 3.15 waymarkers in order, plus the sand fight
	at("mq3", 14)
	refused("mq3", 14, "waymarker_2")
	g.on_event("area_cleared", "timur_pasir")
	press("waymarker_1")
	refused("mq3", 14, "waymarker_3")
	each("mq3", 14, ["waymarker_2", "waymarker_3"])
	# 3.16 rest and Hariang Banga (required)
	at("mq3", 15)
	g.on_event("petilasan_activated", "timur_2")
	want("mq3", 15, "petilasan without Hariang")
	g.on_event("talked_to", "hariang_banga")
	want("mq3", 16, "petilasan + Hariang")

	# 4.5 both brothers; 4.8 arrive + Cepot; 4.11 three verses; 4.13 three beacons
	at("mq4", 4)
	g.on_event("talked_to", "ciung_wanara")
	want("mq4", 4, "one brother")
	g.on_event("talked_to", "hariang_banga")
	want("mq4", 5, "both brothers")
	check(g.has_flag("mq4_i3"), "4.5 did not set mq4_i3 (beat table_dishes)")
	at("mq4", 7)
	g.on_event("zone_entered", "sk_pantai")
	want("mq4", 7, "arrived, Cepot not met")
	g.on_event("talked_to", "cepot")
	want("mq4", 8, "arrived + Cepot")
	at("mq4", 10)
	g.on_event("clue_examined", "song_1")
	g.on_event("clue_examined", "song_2")
	want("mq4", 10, "two verses")
	g.on_event("clue_examined", "song_3")
	want("mq4", 11, "three verses")
	at("mq4", 12)
	each("mq4", 12, ["tidal_beacon_2", "tidal_beacon_1", "tidal_beacon_3"])
	# 4.19 the write card first, then the offering choice
	at("mq4", 18)
	var e := press("cliff_altar")
	check(e.get("quiet", false) and "write:call_laras:sunda_la" in e.get("do", []), "cliff altar should open the La write card first")
	want("mq4", 18, "write card opened, not written")
	g.on_event("name_written", "call_laras")
	want("mq4", 18, "name written, no offering")
	check(not press("cliff_altar").get("choices", []).is_empty(), "cliff altar offers the choice after the name")
	want("mq4", 19, "name + offering")

	# 5.3 Ombak at the barrier, then the fight; 5.6 three whispering trees
	at("mq5", 2)
	check(press("ombak_barrier").get("quiet", false), "the barrier prop is a quiet hint")
	check(not g.check("flag:ombak_barrier"), "barrier open before the cast")
	g.on_event("spell_cast", "jawa_ka")
	check(g.has_flag("ombak_barrier"), "Ombak cast did not open the barrier (encounter cond)")
	want("mq5", 2, "cast, no fight")
	g.on_event("area_cleared", "kala_mulut")
	want("mq5", 3, "cast + fight")
	at("mq5", 5)
	each("mq5", 5, ["whisper_tree_1", "whisper_tree_2", "whisper_tree_3"], ["area_cleared:kala_hutan_echoes"])

	# Side quests
	at("sq_m3", 1)
	g.on_event("area_entered", "tuyul_hideout")
	want("sq_m3", 1, "hideout without the trap")
	press("bean_trap")
	want("sq_m3", 2, "hideout + trap")
	at("sq_m4", 2)
	press("gong_frame")
	check(not g.has_flag("gong_frame"), "gong hung without the gong")
	check(press("mataram_dalang").get("quiet", false), "Ki Sumarto counts the talk before the gong is hung")
	want("sq_m4", 2, "no gong")
	g.add_item("gong_ageng", false)
	press("gong_frame")
	want("sq_m4", 2, "gong hung, dalang not told")
	g.set_flag("mq2_7", false)
	g.quests["mq2"] = {"state": "done", "step": 99, "count": 0, "resolution": "", "all": 0}
	press("mataram_dalang")   # after Act III too (quest:mq2=done no longer shadows SQ-M4)
	want("sq_m4", -1, "gong + dalang")
	at("sq_t1", 1)
	check(press("jetty_post").get("quiet", false), "jetty without the sodo lanang should be a quiet hint")
	want("sq_t1", 1, "jetty without sodo")
	g.add_item("sodo_lanang", false)
	press("jetty_post")
	want("sq_t1", 2, "jetty with sodo")
	check(g.quests.sq_t1.resolution == "peaceful", "jetty strike should be the peaceful end")
	at("sq_t2", 2)
	g.on_event("enemy_killed", "banaspati_elite")
	want("sq_t2", 2, "elite without the wheel")
	press("channel_wheel")
	want("sq_t2", 3, "elite + wheel")
	at("sq_c4_3", 1)
	g.on_event("area_cleared", "c4_lamp_night")
	want("sq_c4_3", 1, "fight without the lamp")
	press("c4_lamp")
	want("sq_c4_3", 2, "lamp + fight")

	# SQ-C3 starts on both Choice 2 outcomes; SQ-C4 part 2 does not need SQ-S4 (c4_1)
	root.get_node("Zones").current_zone = "mt_candi"
	for who in [["choice_handed", "lengser"], ["choice_freed", "faceless_deserter"]]:
		g._reset()
		g.set_flag("mq2_7", false)
		g.set_flag(who[0], false)
		press(who[1])
		check(g.quest_state("sq_c3") == "active", "SQ-C3 not started by %s (%s)" % [who[1], who[0]])
	g._reset()
	g.set_flag("mq2_a1", false)
	press("cepot")
	check(g.quest_state("sq_c4_2") == "active", "SQ-C4 part 2 needs SQ-S4 (c4_1)")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	quit(1 if fails > 0 else 0)
