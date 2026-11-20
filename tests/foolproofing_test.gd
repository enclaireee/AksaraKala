extends SceneTree
## Foolproofing regression tests covering Prologue step 0, navigation, gate-aware routing,
## Burn vs phase invulnerability, Kelir sq_c3_ranga spots, and order-resilient quest catch-up.

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	var game := root.get_node("Game")
	var zones := root.get_node("Zones")

	# 1. Prologue starts at mq0 step 0 (not skipped to step 2)
	await process_frame
	game.new_game(load("res://data/classes/warrior.tres"))
	check(game.quests.has("mq0") and int(game.quests["mq0"].step) == 0, "new_game starts mq0 at step 0")
	check(not game.has_flag("mq0_d1"), "new_game does not pre-set mq0_d1")
	var m0: Dictionary = game.objective_marker()
	check(m0.get("zone", "") == "desa_purwa" and m0.get("id", "") != "", "mq0 step 0 has valid objective marker")

	# 2. mq0 s3 orders ciung_wanara before hidden ciung_basket
	game.quests["mq0"] = {"state": "active", "step": 2, "count": 0}
	var m3: Dictionary = game.objective_marker()
	check(m3.get("id", "") == "ciung_wanara", "mq0 s3 points to ciung_wanara first, got %s" % [m3])

	# 3. Order-resilient _already() covers area_cleared & petilasan_activated
	game.flags["cleared:test_enc"] = true
	game.flags["petilasan:test_pet"] = true
	check(game._already("area_cleared:test_enc", 1), "_already catches up area_cleared")
	check(game._already("petilasan_activated:test_pet", 1), "_already catches up petilasan_activated")

	# 4. Burn (ignore_iframes=true) cannot pierce phase invulnerability (invincible_time == INF)
	var h := Health.new()
	h.max_hp = 100
	h.hp = 100
	h.invincible_time = INF
	var dealt: bool = h.take_damage(25, null, true)
	check(not dealt and h.hp == 100, "phase invulnerability (INF) blocks ignore_iframes damage")
	h.free()

	# 5. Gate-aware pathfinding never steers into locked kabut gates
	game.flags.erase("mq4_i5")
	game.flags.erase("mq4_9")
	for f in ["mq0_7", "mq1_10", "mqg_3", "mqg_7", "mq2_6", "mq2_9", "mq3_4"]:
		game.flags[f] = true
	var nxt_mt: String = zones.next_zone("desa_purwa", "mt_candi")
	check(nxt_mt != "sk_pantai", "desa_purwa -> mt_candi does not route into locked sk_pantai gate (got %s)" % nxt_mt)
	var nxt_home: String = zones.next_zone("tt_pesisir", "desa_purwa")
	check(nxt_home != "sk_karang", "tt_pesisir -> desa_purwa does not route into locked sk_karang gate (got %s)" % nxt_home)

	# 6. sq_c3_ranga.tscn has >= 1 MemorySpot (no permanent softlock)
	var mem: Node = (load("res://zones/kelir/sq_c3_ranga.tscn") as PackedScene).instantiate()
	var spots := mem.find_children("*", "", true, false).filter(func(n: Node) -> bool:
		return n.scene_file_path.ends_with("memory_spot.tscn"))
	check(spots.size() >= 1, "sq_c3_ranga.tscn has MemorySpot nodes (got %d)" % spots.size())
	mem.free()

	# 7. Tutorial 'perfect' requires flag:tut_flask (not inverted)
	var perf: Dictionary = Lessons.by_id("perfect")
	check(str(perf.get("when", "")) == "flag:tut_flask", "perfect lesson requires flag:tut_flask (got %s)" % str(perf.get("when", "")))

	# 8. Zones.GATED_EDGES is a hand copy of the kabut gates: each entry must match a kabut in the source zone
	for edge: String in zones.GATED_EDGES:
		var src := edge.split(">")[0]
		var dst := edge.split(">")[1]
		var req: String = zones.GATED_EDGES[edge]
		check(dst in zones.ADJ.get(src, []), "GATED_EDGES %s is not an ADJ edge" % edge)
		var path := "res://zones/%s.gd" % src
		var found := false
		if ResourceLoader.exists(path):
			var zspots: Dictionary = (load(path) as GDScript).get_script_constant_map().get("SPOTS", {})
			for k in zspots:
				var s: Dictionary = zspots[k]
				if str(s.scene).ends_with("kabut.tscn") and str(s.props.get("flag", "")) == req:
					found = true
		check(found, "GATED_EDGES %s needs a kabut with flag %s in %s" % [edge, req, src])

	quit(1 if fails > 0 else 0)
