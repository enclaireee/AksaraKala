extends SceneTree
## Verifies the item roster, caps, text, bonus keys, starter class equipment, quest item rewards, and zone chest wiring.

var fails := 0

func _initialize() -> void:
	var game := root.get_node("Game")
	game.save_path = "user://items_test_save.json"

	# 1. Roster (items.md 2, 4): deleted ids gone, new ids present, every file loads cleanly.
	for gone in ["short_sword", "iron_staff", "longbow", "kujang"]:
		check(not ResourceLoader.exists("res://data/items/%s.tres" % gone), "deleted item %s still has a resource" % gone)
		check(ItemData.by_id(gone) == null, "deleted item %s still loads" % gone)
	var new_jimat := ["kembang_setaman", "batu_akik", "kemenyan", "rajah", "gelang_akar_bahar", "mustika"]
	for id in new_jimat + ["gada_rujakpolo", "teken_galih_asem"]:
		check(ItemData.by_id(id) != null, "new item %s is missing" % id)
	for id in new_jimat:
		var it := ItemData.by_id(id)
		check(it != null and it.slot == "accessory", "%s should be a jimat (accessory)" % id)
	check(ItemData.by_id("../classes/mage") == null and ItemData.by_id("") == null, "by_id accepted a bad id")

	var all_items: Array[ItemData] = []
	for f in DirAccess.get_files_at("res://data/items"):
		if f.ends_with(".tres"):
			var item := ItemData.by_id(f.get_basename())
			check(item != null, "Item %s loads via ItemData.by_id" % f)
			if item == null:
				continue
			all_items.append(item)
			var item_id := f.get_basename()
			check(item.id == item_id, "Item %s has matching id" % item_id)
			check(item.slot in ["weapon", "armor", "accessory"], "Item %s has valid slot: %s" % [item_id, item.slot])
			check(item.title != "", "Item %s has non-empty title" % item_id)
			check(item.icon != null, "Item %s has an icon" % item_id)
			if item.icon:
				check(item.icon.get_size() == Vector2(16, 16), "Item %s icon is 16x16" % item_id)
			if item.mythic:
				check(item.lore != "", "Mythic item %s has non-empty lore" % item_id)
			if item.slot == "accessory":
				check(item.daya >= 1 and item.daya <= 3, "jimat %s Daya %d outside 1-3" % [item_id, item.daya])
			else:
				check(item.daya == 0, "non-jimat %s has Daya %d" % [item_id, item.daya])
	check(all_items.size() >= 60, "only %d items found" % all_items.size())

	# 1b. Weapon cap (items.md 0): damage x (1 + damage_mult) <= 1.25 x the class starter (favoured) or archetype starter.
	var arche := {"light": 8.0, "heavy": 22.0, "ranged": 8.0, "staff": 8.0}
	var class_start := {}
	for c_id in ["warrior", "archer", "rogue", "mage", "lancer", "herder", "dancer", "dalang"]:
		var cd = load("res://data/classes/%s.tres" % c_id)
		var st := ItemData.by_id(cd.start_weapon)
		class_start[c_id] = float(st.damage)
	for item in all_items:
		if item.slot != "weapon" or item.id == "keris_mpu_gandring":
			continue
		var base: float = class_start.get(item.favoured, arche[item.archetype])
		var eff := item.damage * (1.0 + float(item.bonus.get("damage_mult", 0.0)) + float(item.favoured_bonus.get("damage_mult", 0.0)))
		check(eff <= 1.25 * base + 0.001, "weapon %s effective damage %.1f is over the cap %.1f" % [item.id, eff, 1.25 * base])

	# 1c. Text: every item has NAME, DESC and LORE rows with a non-empty id and en.
	var rows := {}
	var csv := FileAccess.open("res://data/text/items.csv", FileAccess.READ)
	csv.get_csv_line()
	while not csv.eof_reached():
		var line := csv.get_csv_line()
		if line.size() >= 3:
			rows[line[0]] = [line[1], line[2]]
	for item in all_items:
		for part in ["NAME", "DESC", "LORE"]:
			var key := "ITEM_%s_%s" % [item.id.to_upper(), part]
			check(rows.has(key) and rows[key][0].strip_edges() != "" and rows[key][1].strip_edges() != "", "items.csv lacks a filled id and en for %s" % key)

	# 1d. Every bonus key set in data is read in code as bonus("key") or through stat().
	var src := _gd_text("res://")
	var stat_keys := ["vit", "end", "str", "dex", "spi"]
	var seen := {}
	for item in all_items:
		for d in [item.bonus, item.favoured_bonus]:
			for k in d:
				if seen.has(k):
					continue
				seen[k] = true
				check(k in stat_keys or src.contains("bonus(\"%s\")" % k), "bonus key %s (%s) is never read in code" % [k, item.id])

	# 1e. Cakra (items.md 2.2): a returning arrow turns around at max range and flies back to its thrower.
	var thrower := Node2D.new()
	root.add_child(thrower)
	var arrow: Arrow = (load("res://entities/player/arrow.tscn") as PackedScene).instantiate()
	arrow.source = thrower
	arrow.direction = Vector2.RIGHT
	arrow.speed = 100.0
	arrow.max_range = 50.0
	arrow.returns = true
	root.add_child(arrow)
	await process_frame
	arrow.set_physics_process(false)   # stepped by hand
	arrow.global_position = Vector2.ZERO
	arrow._travelled = 0.0
	var out_x := 0.0
	for i in 40:   # 0.5 s out to 50 px, then it homes back
		arrow._physics_process(1.0 / 60.0)
		out_x = maxf(out_x, arrow.global_position.x)
	check(arrow._back, "returning arrow did not turn at max range")
	check(out_x > 48.0 and out_x < 56.0, "returning arrow outward reach was %.1f" % out_x)
	check(arrow.direction.x < 0.0, "returning arrow is not heading back (%s)" % arrow.direction)
	var plain: Arrow = (load("res://entities/player/arrow.tscn") as PackedScene).instantiate()
	plain.source = thrower
	plain.speed = 100.0
	plain.max_range = 50.0
	root.add_child(plain)
	await process_frame
	plain.set_physics_process(false)
	plain._travelled = 0.0
	for i in 40:
		if is_instance_valid(plain) and not plain.is_queued_for_deletion():
			plain._physics_process(1.0 / 60.0)
	check(not plain._back and plain.is_queued_for_deletion(), "a plain arrow should vanish at max range")
	thrower.free()
	if is_instance_valid(arrow):
		arrow.free()

	# 2. Verify all class starter gear
	var classes := ["warrior", "archer", "rogue", "mage", "lancer", "herder", "dancer", "dalang"]
	for c_id in classes:
		var c = load("res://data/classes/%s.tres" % c_id)
		check(c != null, "Class %s loads" % c_id)
		if c:
			var w := ItemData.by_id(c.start_weapon)
			check(w != null and w.slot == "weapon", "Class %s starter weapon %s exists" % [c_id, c.start_weapon])
			var a := ItemData.by_id(c.start_armor)
			check(a != null and a.slot == "armor", "Class %s starter armor %s exists" % [c_id, c.start_armor])

	# 3. Verify all quest rewards specifying items
	var dir := DirAccess.open("res://data/quests")
	if dir:
		dir.list_dir_begin()
		var fname := dir.get_next()
		while fname != "":
			if fname.ends_with(".tres"):
				var q = load("res://data/quests/%s" % fname)
				if q and "rewards" in q and q.rewards is Dictionary:
					var r_items = q.rewards.get("items", [])
					for q_item in r_items:
						var it := ItemData.by_id(q_item)
						check(it != null, "Quest %s reward item %s exists" % [fname, q_item])
			fname = dir.get_next()

	# 4. Verify all chests across all zone scenes
	var zdir := DirAccess.open("res://zones")
	var chest_count := 0
	if zdir:
		zdir.list_dir_begin()
		var zname := zdir.get_next()
		while zname != "":
			if zname.ends_with(".gd") and not zname.ends_with("_base.gd") and zname != "zone.gd":
				var script_res = load("res://zones/%s" % zname)
				if script_res:
					var inst = script_res.new()
					if inst and inst.has_method("spots"):
						var spots = inst.spots()
						for spot_key in spots:
							var spot_data = spots[spot_key]
							var scene_path = spot_data.get("scene", "")
							if scene_path == "res://entities/world/chest.tscn":
								chest_count += 1
								var props = spot_data.get("props", {})
								var chest_item = props.get("item_id", "")
								var chest_id = props.get("chest_id", "")
								check(chest_id != "", "Zone %s chest at %s has non-empty chest_id" % [zname, spot_key])
								if chest_item.begins_with("ilmu:"):
									var amt = int(chest_item.get_slice(":", 1))
									check(amt > 0, "Zone %s chest %s has positive ilmu: %d" % [zname, chest_id, amt])
								else:
									var it := ItemData.by_id(chest_item)
									check(it != null, "Zone %s chest %s has valid item %s" % [zname, chest_id, chest_item])
					if inst is Node:
						inst.free()
			zname = zdir.get_next()

	check(chest_count >= 15, "Found %d chests across zones (expected >= 15)" % chest_count)

	# 5. Verify chest interact mechanics
	var test_chest := (load("res://entities/world/chest.tscn") as PackedScene).instantiate()
	test_chest.chest_id = "test_unit_chest"
	test_chest.item_id = "kembang_setaman"
	root.add_child(test_chest)
	await process_frame
	test_chest.interact()
	check("kembang_setaman" in game.inventory, "Chest interact added kembang_setaman to inventory")
	check(game.has_flag("chest:test_unit_chest"), "Chest interact set flag")
	test_chest.free()

	DirAccess.remove_absolute("user://items_test_save.json")
	quit(1 if fails > 0 else 0)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)


func _gd_text(dir: String) -> String:
	var out := ""
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".gd"):
			out += FileAccess.get_file_as_string(dir + f) + "\n"
	for d in DirAccess.get_directories_at(dir):
		if d in ["tests", ".godot", "addons", ".docs", ".git"] or d.begins_with("."):
			continue
		out += _gd_text(dir + d + "/")
	return out
