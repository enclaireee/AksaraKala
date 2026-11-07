extends SceneTree
## Desa Purwa and the Tatar Sunda areas build from their zone docs (.docs/zones/): sizes, spawns,
## kabut flags, NPC dialogue, encounters, petilasans and shortcut gates. Then the world graph
## (world.md World structure): every exit lands on a spawn, Zones.ADJ matches the exits, two-way
## links go both ways, every area is reachable, and the region meets the interlock minimums.

var fails := 0
## Exit targets that are built in Phase 5. Their exits are fogged or behind a closed gate.
const PENDING := []
## Shortcuts opened only from a pending area: id -> that area.
const PENDING_OPENERS := {}
## Placed NPCs with no dialogue file: dressing with no lines in script.md (no Talk prompt).
const NO_TALK := ["villager", "laras_crowd", "laras_tag", "stray_cat", "faceless_captain_seen",
	"galuh_crowd", "nelayan_jala", "wirasana_daughter"]
const INTERNAL_GATES := {"sc:ts_leuwi": "s"}


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
		z.process_mode = Node.PROCESS_MODE_DISABLED   # all zones overlap at the origin: no player may walk into another zone's exit
		root.add_child(z)
		await process_frame
		check(z.zone_id == id, "%s has zone_id %s" % [id, z.zone_id])
		built[id] = z
	var dp: Zone = built.get("desa_purwa")
	if dp:
		check(dp.size == Vector2i(60, 34), "desa_purwa size %s" % dp.size)
		check(dp.spawn("start") != null and dp.spawn("from_ts_kebun") != null and dp.spawn("from_kg_alun") != null
				and dp.spawn("from_gk_pelataran") != null and dp.spawn("from_gua_kala") != null, "desa_purwa spawns")
		var dpf := flags(dp)
		dpf.sort()
		check(dpf == ["mq1_10", "mq1_10", "mq4_9", "mq4_9", "mq4_i5", "mq4_i5"], "desa_purwa kabut flags %s" % [dpf])
		check(pets(dp) == ["desa_purwa"], "desa_purwa petilasans %s" % [pets(dp)])
		check(of(dp, "dummy.tscn").size() == 4, "desa_purwa wants 4 dummies")
		check(encounters(dp).size() == 3, "desa_purwa wants 3 encounters (purwa_raid, _a, _b)")
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
	var loose := 0
	for id: String in ts:
		var z: Zone = built[id]
		check(z.size == Vector2i(60, 34), "%s size %s" % [id, z.size])
		f += flags(z)
		p += pets(z)
		enc += encounters(z).size()
		# Count enemy spot chars in the map: live children also hold encounter spawns, which depend on timing.
		var m := "\n".join(z.map())
		for c: String in z.spots():
			if String(z.spots()[c].scene).contains("/enemies/"):
				loose += m.count(c)
		for g in of(z, "shortcut.tscn"):
			gates.append(g.id)
			check_gate(zones, z, g)
	f.sort()
	p.sort()
	gates.sort()
	check(f == ["mq1_3", "mq1_3", "mq1_5", "mq1_5", "mq1_7", "mq1_7", "sluice_2", "sluice_2"], "tatar_sunda kabut flags %s" % [f])
	check(p == ["sunda_1", "sunda_2"], "tatar_sunda petilasans %s" % [p])
	check(enc == 13, "tatar_sunda has %d encounters, want 13" % enc)
	check(loose == 24, "tatar_sunda has %d placed enemies, want 24 (the legend counts of tatar_sunda.md)" % loose)
	check(gates == ["sc:ts_leuwi", "sc:ts_leuwi", "sc:ts_pagar", "sc:ts_pagar", "sc:ts_sk", "sc:ts_sk", "sc:ts_tangga", "sc:ts_tangga"], "shortcut gates %s" % [gates])

	# Exits: each lands on a spawn, and together they are exactly ADJ plus the gated side of each shortcut.
	var exits := {}   # "a>b": true
	for z: Zone in built.values():
		for n in z.entities.get_children():
			if n.scene_file_path.ends_with("exit.tscn"):
				check_exit(zones, z, n, built)
				if not PENDING.has(n.target_zone):
					exits["%s>%s" % [z.zone_id, n.target_zone]] = true
			elif n.scene_file_path.ends_with("npc.tscn"):
				check(n.npc_id in NO_TALK or ResourceLoader.exists("res://data/dialogue/%s.tres" % n.npc_id), "no dialogue for npc %s" % n.npc_id)
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

	# Mataram region totals (zones/mataram.md).
	var mt := built.keys().filter(func(id: String) -> bool: return id.begins_with("mt_"))
	check(mt.size() == 8, "mataram has %d areas, want 8" % mt.size())
	f = []
	p = []
	gates = []
	enc = 0
	for id: String in mt:
		var z: Zone = built[id]
		f += flags(z)
		p += pets(z)
		enc += encounters(z).size()
		for g in of(z, "shortcut.tscn"):
			gates.append(g.id)
			check_gate(zones, z, g)
	f.sort()
	p.sort()
	gates.sort()
	check(f == ["mq2_6", "mq2_6", "mq2_9", "mq2_9"], "mataram kabut flags %s" % [f])
	check(p == ["mataram_1", "mataram_2"], "mataram petilasans %s" % [p])
	check(enc == 20, "mataram has %d encounters, want 20" % enc)
	check(gates == ["sc:mt_candi_gapura", "sc:mt_candi_gapura", "sc:mt_ruin_sawah", "sc:mt_ruin_sawah", "sc:mt_tt", "sc:mt_tt"], "mataram shortcut gates %s" % [gates])
	check(of(built.get("mt_candi"), "bandung_bondowoso.tscn").size() == 1, "mt_candi wants the boss")
	undirected = {}
	for k: String in want:
		var ab := k.split(">")
		if ab[0].begins_with("mt_") and ab[1].begins_with("mt_"):
			ab.sort()
			undirected["-".join(ab)] = true
	check(undirected.size() - mt.size() + 1 >= 2, "mataram has too few loops")
	check(zones.DROPS.any(func(d: Array) -> bool: return d[0].begins_with("mt_")), "mataram wants a drop")

	# Tanah Timur region totals (zones/tanah_timur.md).
	var tt := built.keys().filter(func(id: String) -> bool: return id.begins_with("tt_"))
	check(tt.size() == 8, "tanah_timur has %d areas, want 8" % tt.size())
	f = []
	p = []
	gates = []
	enc = 0
	for id: String in tt:
		var z: Zone = built[id]
		for k in flags(z):
			if not f.has(k):
				f.append(k)
		p += pets(z)
		enc += encounters(z).size()
		for g in of(z, "shortcut.tscn"):
			if not gates.has(g.id):
				gates.append(g.id)
			check_gate(zones, z, g)
	f.sort()
	p.sort()
	gates.sort()
	check(f == ["mq2_9", "mq3_4", "mq3_h4", "mq4_9"], "tanah_timur kabut flags %s" % [f])
	check(p == ["timur_1", "timur_2"], "tanah_timur petilasans %s" % [p])
	check(enc == 15, "tanah_timur has %d encounters, want 15" % enc)
	check(gates == ["sc:tt_ladang", "sc:tt_pasir"], "tanah_timur shortcut gates %s" % [gates])
	check(of(built.get("tt_ladang"), "buto_ijo.tscn").size() == 1, "tt_ladang wants Buto Ijo")
	check(of(built.get("tt_candi"), "keris_gandring.tscn").size() == 1, "tt_candi wants the keris")
	check(of(built.get("tt_candi"), "curse_stake.tscn").size() == 7, "tt_candi wants 7 curse stakes")
	check(of(built.get("tt_beringin"), "curse_stake.tscn").size() == 3, "tt_beringin wants 3 practice stakes")
	undirected = {}
	for k: String in want:
		var ab := k.split(">")
		if ab[0].begins_with("tt_") and ab[1].begins_with("tt_"):
			ab.sort()
			undirected["-".join(ab)] = true
	check(undirected.size() - tt.size() + 1 >= 3, "tanah_timur has too few loops")
	check(zones.DROPS.has(["tt_beringin", "tt_pesisir"]), "tanah_timur wants the drop")

	# Gua Kala totals (zones/gua_kala.md, P0: entered from Desa Purwa).
	var gk := built.keys().filter(func(id: String) -> bool: return id.begins_with("gk_"))
	check(gk.size() == 7, "gua_kala has %d areas, want 7" % gk.size())
	f = []
	p = []
	gates = []
	enc = 0
	for id: String in gk:
		var z: Zone = built[id]
		f += flags(z)
		p += pets(z)
		enc += encounters(z).size()
		for g in of(z, "shortcut.tscn"):
			gates.append(g.id)
			check_gate(zones, z, g)
	p.sort()
	check(f == ["mq5_3", "mq5_3"], "gua_kala kabut flags %s" % [f])
	check(p == ["kala_0", "kala_1", "kala_2"], "gua_kala petilasans %s" % [p])
	check(enc == 9, "gua_kala has %d encounters, want 9" % enc)
	check(gates == ["sc:gk_lorong", "sc:gk_lorong"], "gua_kala shortcut gates %s" % [gates])
	check(of(built.get("gk_ruang_kala"), "batara_kala.tscn").size() == 1, "gk_ruang_kala wants Batara Kala")
	check(zones.DROPS.has(["gk_pasir", "gk_lupa"]), "gua_kala wants the drop")

	# Segara Kidul totals (zones/segara_kidul.md).
	var sk := built.keys().filter(func(id: String) -> bool: return id.begins_with("sk_"))
	check(sk.size() == 7, "segara_kidul has %d areas, want 7" % sk.size())
	f = []
	p = []
	gates = []
	enc = 0
	for id: String in sk:
		var z: Zone = built[id]
		f += flags(z)
		p += pets(z)
		enc += encounters(z).size()
		for g in of(z, "shortcut.tscn"):
			gates.append(g.id)
			check_gate(zones, z, g)
	p.sort()
	check(f == ["mq4_offering", "mq4_offering", "mq4_offering", "mq4_offering", "mq4_9", "mq4_9"], "segara_kidul kabut flags %s" % [f])
	check(p == ["kidul_1", "kidul_2", "kidul_3"], "segara_kidul petilasans %s" % [p])
	check(enc == 13, "segara_kidul has %d encounters, want 13" % enc)
	check(gates == ["sc:sk_gerbang", "sc:sk_gerbang"], "segara_kidul shortcut gates %s" % [gates])
	check(of(built.get("sk_karang"), "bajul_putih_tua.tscn").size() == 1, "sk_karang wants Bajul Putih Tua")
	undirected = {}
	for k: String in want:
		var ab := k.split(">")
		if ab[0].begins_with("sk_") and ab[1].begins_with("sk_"):
			ab.sort()
			undirected["-".join(ab)] = true
	check(undirected.size() - sk.size() + 1 >= 2, "segara_kidul has too few loops")
	check(zones.DROPS.has(["sk_tebing", "sk_keraton"]), "segara_kidul wants the drop")
	for z: Node in built.values():   # free before quit, or the HUDs call the freed autoloads on shutdown
		z.free()
	await process_frame
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
	if g.id in INTERNAL_GATES:   # a gate inside one area (tatar_sunda.md: the gorge tunnel opens from the sande room, south)
		check(g.open_side == INTERNAL_GATES[g.id], "%s open side %s" % [g.id, g.open_side])
		return
	var ab: Array = zones.SHORTCUTS.get(g.id, [PENDING_OPENERS.get(g.id, "?"), z.zone_id])
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
