extends SceneTree
## Keraton Galuh (zones/keraton_galuh.md): every kg area builds, exits land on existing zones and spawns,
## kabut flags, encounters and boss spots match the doc, and every kg area is reachable from kg_alun in ADJ.
## Run: $GODOT --headless --path . -s tests/galuh_play_test.gd
## ponytail: structure only, no walk; the quest flags (mqg_*) have no quest data yet.

const AREAS := ["kg_alun", "kg_keraton", "kg_penjara", "kg_pamali", "kg_pasar", "kg_pustaka", "kg_kaputren"]
## Spawns added by other agents in desa_purwa and mt_gapura.
const SKIP := ["desa_purwa:from_kg_alun", "mt_gapura:from_kg_pamali"]

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	var zones := root.get_node("Zones")
	var built := {}
	for id: String in AREAS:
		check(zones.ZONES.has(id), "%s not in ZONES" % id)
		var packed := load("res://zones/%s.tscn" % id) as PackedScene
		if not check_ok(packed != null, "%s does not load" % id):
			continue
		var z := packed.instantiate() as Zone
		root.add_child(z)
		await process_frame
		check(z.zone_id == id, "%s zone_id %s" % [id, z.zone_id])
		check(z.size == Vector2i(60, 34), "%s size %s" % [id, z.size])
		built[id] = z
	for id: String in built:
		for n in built[id].entities.get_children():
			if n.scene_file_path.ends_with("exit.tscn"):
				var t: String = n.target_zone
				var key := "%s:%s" % [t, n.spawn_id]
				check(zones.ZONES.has(t), "%s exit to unknown zone %s" % [id, t])
				if SKIP.has(key) or not built.has(t):
					check(SKIP.has(key) or not AREAS.has(t), "%s exit: %s not built" % [id, t])
					continue
				check(built[t].spawn(n.spawn_id) != null, "%s exit: %s has no spawn %s" % [id, t, n.spawn_id])
	var alun_f := flags(built.get("kg_alun"))
	alun_f.sort()
	check(alun_f == ["mqg_3", "mqg_3", "mqg_7", "mqg_7"], "kg_alun kabut %s" % [alun_f])
	var ker_f := flags(built.get("kg_keraton"))
	ker_f.sort()
	check(ker_f == ["lamps_3", "lamps_3", "mqg_6b", "mqg_6b", "mqg_h2", "mqg_h2"], "kg_keraton kabut %s" % [ker_f])
	for s: String in ["from_desa_purwa", "from_kg_keraton", "from_kg_pamali", "from_kg_pasar"]:
		check(built["kg_alun"].spawn(s) != null, "kg_alun spawn " + s)
	for s: String in ["from_kg_alun", "from_mt_gapura"]:
		check(built["kg_pamali"].spawn(s) != null, "kg_pamali spawn " + s)
	check(pets(built["kg_keraton"]) == ["galuh_1"], "kg_keraton petilasan %s" % [pets(built["kg_keraton"])])
	var ids := []
	for id: String in built:
		for n in built[id].entities.get_children():
			if n.scene_file_path.ends_with("encounter.tscn"):
				ids.append(String(n.area_id))
	ids.sort()
	check(ids == ["galuh_bout_1", "galuh_bout_2", "galuh_cells", "galuh_escort", "galuh_hall", "galuh_market_riggers", "kaputren_courtyard", "keraton_throne_approach", "pamali_bank", "pamali_ford", "penjara_stairs", "pustaka_guards"], "encounters %s" % [ids])
	# Boss spots come from the doc's spot table, so they are checked even while the boss scenes are being built.
	check(has_spot(built["kg_keraton"], "barma_wijaya.tscn"), "kg_keraton has no Barma Wijaya spot")
	check(has_spot(built["kg_pamali"], "hariang_banga.tscn"), "kg_pamali has no Hariang Banga spot")
	var seen := {"kg_alun": true}
	var queue := ["kg_alun"]
	while not queue.is_empty():
		for n: String in zones.ADJ.get(queue.pop_front(), []):
			if not seen.has(n):
				seen[n] = true
				queue.append(n)
	for id: String in AREAS:
		check(seen.has(id), "%s not reachable from kg_alun" % id)
	quit(1 if fails > 0 else 0)


func check_ok(ok: bool, msg: String) -> bool:
	check(ok, msg)
	return ok


func has_spot(z: Zone, file: String) -> bool:
	return z.spots().values().any(func(s: Dictionary) -> bool: return String(s.scene).ends_with(file))


func flags(z: Zone) -> Array:
	return z.entities.get_children().filter(func(n: Node) -> bool: return n.scene_file_path.ends_with("kabut.tscn")).map(func(n: Node) -> String: return n.flag)


func pets(z: Zone) -> Array:
	return z.entities.get_children().filter(func(n: Node) -> bool: return n.scene_file_path.ends_with("petilasan.tscn")).map(func(n: Node) -> String: return n.id)
