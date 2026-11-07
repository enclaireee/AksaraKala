extends SceneTree
## Verifies all 32 items, starter class equipment, quest item rewards, and zone chest wiring.

var fails := 0

func _initialize() -> void:
	var game := root.get_node("Game")
	game.save_path = "user://items_test_save.json"

	# 1. Verify all 32 items exist and load cleanly
	var expected_items := [
		"amulet", "axe", "baju_batik", "batu_kali", "blangkon", "broadsword",
		"cakra", "chainmail", "crossbow", "dagger", "feather_charm", "golok",
		"hunting_bow", "iket_sunda", "iron_ring", "iron_staff", "jimat",
		"kain_hijau", "keris_luk_7", "keris_mpu_gandring", "kujang",
		"leather_armor", "longbow", "lontar_kuno", "oak_staff", "padded_tunic",
		"panah_pasopati", "sabuk_galuh", "short_sword", "silver_bangle",
		"spear", "stone_ring"
	]
	check(expected_items.size() == 32, "exactly 32 items expected")

	for item_id in expected_items:
		var item := ItemData.by_id(item_id)
		check(item != null, "Item %s loads via ItemData.by_id" % item_id)
		if item:
			check(item.id == item_id, "Item %s has matching id" % item_id)
			check(item.slot in ["weapon", "armor", "accessory"], "Item %s has valid slot: %s" % [item_id, item.slot])
			check(item.title != "", "Item %s has non-empty title" % item_id)
			if item.mythic:
				check(item.lore != "", "Mythic item %s has non-empty lore" % item_id)

	# 2. Verify all class starter gear
	var classes := ["warrior", "archer", "rogue", "mage"]
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
	test_chest.item_id = "short_sword"
	root.add_child(test_chest)
	await process_frame
	test_chest.interact()
	check("short_sword" in game.inventory, "Chest interact added short_sword to inventory")
	check(game.has_flag("chest:test_unit_chest"), "Chest interact set flag")
	test_chest.free()

	DirAccess.remove_absolute("user://items_test_save.json")
	quit(1 if fails > 0 else 0)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
