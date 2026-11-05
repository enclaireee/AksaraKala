extends SceneTree
## Desa Purwa and the Tatar Sunda areas build from their zone docs (.docs/zones/): sizes, spawns,
## kabut flags, NPC dialogue, encounters, petilasans and shortcut gates. Then the world graph
## (world.md World structure): every exit lands on a spawn, Zones.ADJ matches the exits, two-way
## links go both ways, every area is reachable, and the region meets the interlock minimums.

var fails := 0
## Exit targets that are built in Phase 5. Their exits are fogged or behind a closed gate.
const PENDING := ["mt_gapura", "sk_tebing"]


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	var zones := root.get_node("Zones")
	check(zones.start_zone == "res://zones/desa_purwa.tscn", "START_ZONE is %s" % zones.start_zone)
	var built := {}
	for id: String in zones.ZONES:
		if id == "hub":
			continue
		var packed := load(zones.ZONES[id]) as PackedScene
		check(packed != null, "%s does not load" % id)
		if packed == null:
			continue
		var z := packed.instantiate() as Zone
		root.add_child(z)
		await process_frame
		check(z.zone_id == id, "%s has zone_id %s" % [id, z.zone_id])
		built[id] = z
	var dp: Zone = built.get("desa_purwa")
	if dp:
		check(dp.size == Vector2i(60, 34), "desa_purwa size %s" % dp.size)
		check(dp.spawn("start") != null and dp.spawn("from_ts_kebun") != null and dp.spawn("from_mt_gapura") != null, "desa_purwa spawns")
		check(flags(dp) == ["mq1_10", "mq1_10"], "desa_purwa kabut flags %s" % [flags(dp)])
		check(pets(dp) == ["desa_purwa"], "desa_purwa petilasans %s" % [pets(dp)])
		check(of(dp, "dummy.tscn").size() == 4, "desa_purwa wants 4 dummies")
		check(encounters(dp).is_empty(), "desa_purwa has encounters")
		var pl := get_first_node_in_group("player")
		dp._sanggar(pl, true)
		check(not dp.guide.visible, "sanggar guide shown before any glyph is learned")
		check(pl.cast.practice, "sanggar does not put casting in practice mode")
		root.get_node("Game").run("learn:sunda_ka")
		check(dp.guide.visible, "sanggar guide hidden after learning Ka inside")
		dp._sanggar(pl, false)
		check(not dp.guide.visible, "sanggar guide still shown after leaving")
		check(not pl.cast.practice, "practice mode stays on outside the sanggar")

	# Tatar Sunda region totals (zones/tatar_sunda.md).
	var ts := built.keys().filter(func(id: String) -> bool: return id.begins_with("ts_"))
	check(ts.size() == 8, "tatar_sunda has %d areas, want 8" % ts.size())
	var f := []
	var p := []
	var gates := []
	var enc := 0
	for id: String in ts:
		var z: Zone = built[id]
		check(z.size == Vector2i(60, 34), "%s size %s" % [id, z.size])
		f += flags(z)
		p += pets(z)
		enc += encounters(z).size()
		for g in of(z, "shortcut.tscn"):
			gates.append(g.id)
			check_gate(zones, z, g)
	f.sort()
	p.sort()
	gates.sort()
	check(f == ["mq1_3", "mq1_3", "mq1_5", "mq1_5", "mq1_7", "mq1_7"], "tatar_sunda kabut flags %s" % [f])
	check(p == ["sunda_1", "sunda_2"], "tatar_sunda petilasans %s" % [p])
	check(enc == 7, "tatar_sunda has %d encounters, want 7" % enc)
	check(gates == ["sc:ts_pagar", "sc:ts_pagar", "sc:ts_sk", "sc:ts_sk", "sc:ts_tangga", "sc:ts_tangga"], "shortcut gates %s" % [gates])

	# Exits: each lands on a spawn, and together they are exactly ADJ plus the gated side of each shortcut.
	var exits := {}   # "a>b": true
	for z: Zone in built.values():
		for n in z.entities.get_children():
			if n.scene_file_path.ends_with("exit.tscn"):
				check_exit(zones, z, n, built)
				if not PENDING.has(n.target_zone):
					exits["%s>%s" % [z.zone_id, n.target_zone]] = true
			elif n.scene_file_path.ends_with("npc.tscn"):
				check(ResourceLoader.exists("res://data/dialogue/%s.tres" % n.npc_id), "no dialogue for npc %s" % n.npc_id)
	var want := {}
	for a: String in zones.ADJ:
		for b: String in zones.ADJ[a]:
			if not PENDING.has(b):
				want["%s>%s" % [a, b]] = true
			var back: bool = zones.ADJ.get(b, []).has(a) or PENDING.has(b)
			var one_way: bool = zones.DROPS.has([a, b]) or zones.SHORTCUTS.values().has([a, b])
			check(back or one_way, "ADJ %s -> %s has no way back and is not a drop or shortcut" % [a, b])
	for sc: String in zones.SHORTCUTS:
		var ab: Array = zones.SHORTCUTS[sc]
		want["%s>%s" % [ab[1], ab[0]]] = true   # the exit behind the gate
	check(exits.keys().all(func(k: String) -> bool: return want.has(k)), "exits not in ADJ: %s" % [exits.keys().filter(func(k: String) -> bool: return not want.has(k))])
	check(want.keys().all(func(k: String) -> bool: return exits.has(k)), "ADJ edges with no exit: %s" % [want.keys().filter(func(k: String) -> bool: return not exits.has(k))])

	# Reachability and the interlock minimums.
	var seen := {"desa_purwa": true}
	var queue := ["desa_purwa"]
	while not queue.is_empty():
		for n: String in zones.ADJ.get(queue.pop_front(), []):
			if not seen.has(n):
				seen[n] = true
				queue.append(n)
	for id: String in built:
		check(seen.has(id), "%s is not reachable from desa_purwa" % id)
	var undirected := {}
	for k: String in want:
		var ab := k.split(">")
		if ab[0].begins_with("ts_") and ab[1].begins_with("ts_"):
			ab.sort()
			undirected["-".join(ab)] = true
	var loops := undirected.size() - ts.size() + 1   # cycle rank of a connected graph
	check(loops >= 2, "tatar_sunda has %d loops, want 2+" % loops)
	check(zones.SHORTCUTS.keys().filter(func(s: String) -> bool: return s.begins_with("sc:ts_")).size() >= 2, "tatar_sunda wants 2+ shortcuts")
	check(zones.DROPS.any(func(d: Array) -> bool: return d[0].begins_with("ts_")), "tatar_sunda wants a drop")
	quit(1 if fails > 0 else 0)


func check_exit(zones: Node, z: Zone, e: Node, built: Dictionary) -> void:
	var t: String = e.target_zone
	if PENDING.has(t):
		return
	check(zones.ZONES.has(t), "%s exit target %s is not in Zones.ZONES" % [z.zone_id, t])
	if built.has(t):
		check(built[t].spawn(e.spawn_id) != null, "%s exit: %s has no spawn %s" % [z.zone_id, t, e.spawn_id])


## The arrival spawn from the area that opens the gate must stand on the gate's open side.
func check_gate(zones: Node, z: Zone, g: Node) -> void:
	var ab: Array = zones.SHORTCUTS.get(g.id, ["sk_tebing", z.zone_id])   # sc:ts_sk opens from Segara Kidul
	check(ab[1] == z.zone_id, "%s gate is in %s, want %s" % [g.id, z.zone_id, ab[1]])
	var s := z.spawn("from_" + ab[0])
	check(s != null and g.from_open_side(s.global_position), "%s: spawn from_%s is not on the open side" % [g.id, ab[0]])


func of(z: Zone, file: String) -> Array:
	return z.entities.get_children().filter(func(n: Node) -> bool: return n.scene_file_path.ends_with(file))


func flags(z: Zone) -> Array:
	return of(z, "kabut.tscn").map(func(n: Node) -> String: return n.flag)


func pets(z: Zone) -> Array:
	return of(z, "petilasan.tscn").map(func(n: Node) -> String: return n.id)


func encounters(z: Zone) -> Array:
	return of(z, "encounter.tscn")
