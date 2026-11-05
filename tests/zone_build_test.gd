extends SceneTree
## Desa Purwa and Tatar Sunda build from their zone docs (.docs/zones/): size, spawns, exits,
## kabut flags, NPC dialogue, encounters and petilasans. Missing boss scenes only warn.

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	var zones := root.get_node("Zones")
	check(zones.start_zone == "res://zones/desa_purwa.tscn", "START_ZONE is %s" % zones.start_zone)
	var built := {}
	for id in ["desa_purwa", "tatar_sunda"]:
		var packed := load(zones.ZONES[id]) as PackedScene
		check(packed != null, "%s does not load" % id)
		if packed == null:
			continue
		var z := packed.instantiate() as Zone
		root.add_child(z)
		await process_frame
		built[id] = z
	var dp: Zone = built.get("desa_purwa")
	var ts: Zone = built.get("tatar_sunda")
	if dp:
		check(dp.size == Vector2i(60, 34), "desa_purwa size %s" % dp.size)
		check(dp.spawn("start") != null and dp.spawn("from_sunda") != null and dp.spawn("from_mataram") != null, "desa_purwa spawns")
		check(flags(dp) == ["mq1_10", "mq1_10"], "desa_purwa kabut flags %s" % [flags(dp)])
		check(pets(dp) == ["desa_purwa"], "desa_purwa petilasans %s" % [pets(dp)])
		check(of(dp, "dummy.tscn").size() == 4, "desa_purwa wants 4 dummies")
		check(encounters(dp).is_empty(), "desa_purwa has encounters")
	if ts:
		check(ts.size == Vector2i(120, 51), "tatar_sunda size %s" % ts.size)
		check(ts.spawn("from_purwa") != null, "tatar_sunda spawn from_purwa")
		var f := flags(ts)
		f.sort()
		check(f == ["mq1_3", "mq1_3", "mq1_5", "mq1_5", "mq1_7", "mq1_7"], "tatar_sunda kabut flags %s" % [f])
		var p := pets(ts)
		p.sort()
		check(p == ["sunda_1", "sunda_2"], "tatar_sunda petilasans %s" % [p])
		check(encounters(ts).size() == 7, "tatar_sunda has %d encounters, want 7" % encounters(ts).size())
	for z: Zone in built.values():
		for n in z.entities.get_children():
			if n.scene_file_path.ends_with("exit.tscn"):
				check_exit(zones, z, n, built)
			elif n.scene_file_path.ends_with("npc.tscn"):
				check(ResourceLoader.exists("res://data/dialogue/%s.tres" % n.npc_id), "no dialogue for npc %s" % n.npc_id)
	quit(1 if fails > 0 else 0)


func check_exit(zones: Node, z: Zone, e: Node, built: Dictionary) -> void:
	var t: String = e.target_zone
	if t == "mataram":   # no scene yet; ADJ already routes to it
		return
	var path: String = zones.ZONES.get(t, t)
	check(ResourceLoader.exists(path), "%s exit target %s missing" % [z.zone_id, t])
	if built.has(t):
		check(built[t].spawn(e.spawn_id) != null, "%s exit: %s has no spawn %s" % [z.zone_id, t, e.spawn_id])


func of(z: Zone, file: String) -> Array:
	return z.entities.get_children().filter(func(n: Node) -> bool: return n.scene_file_path.ends_with(file))


func flags(z: Zone) -> Array:
	return of(z, "kabut.tscn").map(func(n: Node) -> String: return n.flag)


func pets(z: Zone) -> Array:
	return of(z, "petilasan.tscn").map(func(n: Node) -> String: return n.id)


func encounters(z: Zone) -> Array:
	return of(z, "encounter.tscn")
