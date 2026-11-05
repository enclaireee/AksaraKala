extends SceneTree
## Soft-lock check for Phase 4: every quest step's event has a source in the built zones or the dialogue
## data (an NPC to talk to, a trigger, an encounter, a petilasan, a placed or spawned enemy, a chest,
## pickup or `give:`, a `learn:`), and every quest but MQ0 is started by a placed NPC.
## ponytail: static reachability only; it does not prove the order is playable, the playtest does.

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	var zones := root.get_node("Zones")
	var src := {}   # signal -> {arg: true}
	for s in ["talked_to", "area_entered", "area_cleared", "petilasan_activated", "enemy_killed", "boss_defeated",
			"item_picked", "glyph_learned", "zone_entered"]:
		src[s] = {}
	for id in ["desa_purwa", "tatar_sunda"]:
		src.zone_entered[id] = true
		var z := (load(zones.ZONES[id]) as PackedScene).instantiate()
		root.add_child(z)
		await process_frame
		for n in z.find_children("*", "", true, false):
			var f := n.scene_file_path
			if f.ends_with("npc.tscn"):
				src.talked_to[n.npc_id] = true
			elif f.ends_with("trigger.tscn"):
				src.area_entered[n.trigger_id] = true
			elif f.ends_with("encounter.tscn"):
				src.area_cleared[n.area_id] = true
				for wave in n.waves:
					for e in wave:
						add_enemy(src, load(e[0]).instantiate())
			elif f.ends_with("petilasan.tscn"):
				src.petilasan_activated[n.id] = true
			elif f.ends_with("chest.tscn") or f.ends_with("pickup.tscn"):
				if n.item_id != "":
					src.item_picked[n.item_id] = true
			elif n is EnemyBase:
				add_enemy(src, n)
		z.free()
	var starts := {}
	for f in DirAccess.get_files_at("res://data/dialogue"):
		if not f.ends_with(".tres"):
			continue
		var d: DialogueData = load("res://data/dialogue/" + f)
		for e in d.entries:
			for a in e.get("do", []):
				var p: PackedStringArray = a.split(":", true, 1)
				match p[0]:
					"give": src.item_picked[p[1]] = true
					"learn": src.glyph_learned[p[1]] = true
					"start":
						if src.talked_to.has(d.npc_id):
							starts[p[1]] = true
	var game := root.get_node("Game")
	for q in QuestData.all():
		check(q.id == "mq0" or starts.has(q.id), "%s: no placed NPC starts it" % q.id)
		for s in q.steps:
			var p: PackedStringArray = s.on.split(":", true, 1)
			if p[0] == "class_chosen" or p.size() == 1:
				continue
			if p[0] == "spell_cast":
				check(src.glyph_learned.has(p[1]), "%s: casts %s, which nobody teaches" % [q.id, p[1]])
				continue
			check(src.has(p[0]), "%s: no source list for '%s'" % [q.id, s.on])
			if src.has(p[0]):
				var hits: Array = src[p[0]].keys().filter(func(a: String) -> bool: return game._matches(s.on, p[0], a))
				check(not hits.is_empty(), "%s: nothing in the zones or dialogue fires '%s'" % [q.id, s.on])
	quit(1 if fails > 0 else 0)


func add_enemy(src: Dictionary, e: Node) -> void:
	src.enemy_killed[e.kind] = true
	if e.is_in_group("boss") or e is Sangkuriang or e is Sandekala:
		src.boss_defeated[e.kind] = true
	if not e.is_inside_tree():
		e.free()
