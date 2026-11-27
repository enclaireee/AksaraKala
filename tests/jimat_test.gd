extends SceneTree
## Jimat and Daya (items.md 4): the budget, refusals, summed and favoured bonuses, unequip, equip() routing.

const PATH := "user://test_jimat.json"
var fails := 0
var g: Node


func _initialize() -> void:
	g = root.get_node("Game")
	g.save_path = PATH   # never touch the real save
	await process_frame

	_fresh("mage")
	# Budget 2 at tier 0: Amulet (1) + Feather Charm (1) fit, a third does not.
	check(g.equip_jimat("amulet") and g.daya_used() == 1, "amulet did not equip")
	check(g.equip_jimat("feather_charm") and g.daya_used() == 2 and g.jimat == ["amulet", "feather_charm"], "feather charm did not equip: %s" % [g.jimat])
	check(not g.equip_jimat("silver_bangle") and g.jimat.size() == 2, "a jimat went over the budget: %s" % [g.jimat])
	check(not g.equip_jimat("amulet") and g.jimat.count("amulet") == 1, "a duplicate jimat equipped")
	check(not g.equip_jimat("kemenyan") and "kemenyan" not in g.jimat, "an unowned jimat equipped")
	check(not g.equip_jimat("oak_staff") and not g.equip_jimat("padded_tunic") and not g.equip_jimat("nope_xx"), "a non-jimat or unknown id equipped")
	check(g.jimat.size() == 2, "refusals changed the set: %s" % [g.jimat])

	# Unequip frees Daya; a raised budget admits more.
	g.unequip_jimat("amulet")
	check(g.jimat == ["feather_charm"] and g.daya_used() == 1, "unequip did not free Daya: %s used %d" % [g.jimat, g.daya_used()])
	g.unequip_jimat("not_worn")   # a no-op
	check(g.jimat == ["feather_charm"], "unequipping an unworn id changed the set")
	check(g.equip_jimat("silver_bangle") and g.daya_used() == 2, "freed Daya was not usable")
	check(not g.equip_jimat("iron_ring"), "iron ring (2) fit with 2 used of 2")
	g.ingatan = 2   # budget 4
	check(g.equip_jimat("iron_ring") and g.daya_used() == 4, "iron ring did not fit at budget 4")
	check(not g.equip_jimat("sabuk_galuh"), "3 Daya fit with 4 used of 4")

	# equip() on an accessory goes through equip_jimat (and obeys it); weapon and armor never enter the set.
	_fresh("mage")
	g.add_item("sabuk_galuh", false)
	check(not g.equip("sabuk_galuh") and g.jimat.is_empty(), "equip() bypassed the Daya budget")
	g.ingatan = 1
	check(g.equip("sabuk_galuh") and g.jimat == ["sabuk_galuh"], "equip() did not route an accessory to the jimat set")
	check(not g.equipped.has("accessory"), "equip() filled an accessory slot")
	g.add_item("padded_tunic", false)
	g.equip("padded_tunic")
	check(g.jimat == ["sabuk_galuh"] and g.equipped.armor == "padded_tunic", "armor equip touched the jimat set")

	# bonus() sums several jimat (stone ring has spell_mult, amulet max_hp, iron ring damage_mult).
	_fresh("mage")
	g.ingatan = 4
	for id in ["amulet", "iron_ring", "stone_ring"]:
		g.add_item(id, false)
		check(g.equip_jimat(id), "%s did not equip" % id)
	check(is_equal_approx(g.bonus("max_hp"), 15.0), "max_hp bonus %s" % g.bonus("max_hp"))
	check(is_equal_approx(g.bonus("damage_mult"), 0.05) and is_equal_approx(g.bonus("spell_mult"), 0.05), "damage_mult %s spell_mult %s" % [g.bonus("damage_mult"), g.bonus("spell_mult")])
	g.unequip_jimat("stone_ring")
	check(is_equal_approx(g.bonus("spell_mult"), 0.0), "unequipped jimat still gives a bonus")
	g.add_item("silver_bangle", false)
	g.equip_jimat("silver_bangle")
	g.add_item("feather_charm", false)
	g.equip_jimat("feather_charm")
	check(is_equal_approx(g.bonus("stamina_regen"), 0.10) and is_equal_approx(g.bonus("move_speed"), 0.08), "summed regen %s move %s" % [g.bonus("stamina_regen"), g.bonus("move_speed")])

	# The favoured bonus applies only to the matching class (Genitri: mage, smudge -0.03).
	_fresh("mage")
	g.add_item("genitri", false)
	g.equip_jimat("genitri")
	var base_smudge: float = float(ItemData.by_id("genitri").bonus.get("smudge", 0.0))
	check(is_equal_approx(g.bonus("smudge"), base_smudge - 0.03), "mage favoured smudge: %s" % g.bonus("smudge"))
	check(is_equal_approx(g.bonus("spi"), float(ItemData.by_id("genitri").bonus.get("spi", 0))), "genitri spi bonus %s" % g.bonus("spi"))
	g.class_id = "warrior"
	check(is_equal_approx(g.bonus("smudge"), base_smudge), "a warrior got the mage-favoured smudge: %s" % g.bonus("smudge"))
	_fresh("warrior")
	g.add_item("gelang_baja", false)
	g.equip_jimat("gelang_baja")
	check(is_equal_approx(g.bonus("str"), 1.0), "warrior favoured +1 str: %s" % g.bonus("str"))
	g.class_id = "mage"
	check(is_equal_approx(g.bonus("str"), 0.0), "a mage got the warrior-favoured str: %s" % g.bonus("str"))

	# Rajah (low_hp_damage) scales SpellUtil.damage() when caster HP < 30%.
	var world := Node2D.new()
	root.add_child(world)
	var pl: Player = (load("res://entities/player/player.tscn") as PackedScene).instantiate()
	world.add_child(pl)
	await process_frame
	pl.set_physics_process(false)
	_fresh("mage")
	g.add_item("rajah", false)
	g.equip_jimat("rajah")
	g.changed.emit()
	pl.health.hp = pl.health.max_hp
	var sp_hi := SpellUtil.damage(pl)
	pl.health.hp = 1
	var sp_lo := SpellUtil.damage(pl)
	check(is_equal_approx(sp_lo, sp_hi * 1.2), "Rajah low_hp_damage did not scale SpellUtil.damage: %s -> %s" % [sp_hi, sp_lo])
	world.free()

	DirAccess.remove_absolute(PATH)
	DirAccess.remove_absolute(PATH.replace(".json", ".bak"))
	quit(1 if fails > 0 else 0)


## A clean run with every item the test may wear in the inventory, nothing worn, tier 0.
func _fresh(cls: String) -> void:
	g._reset()
	g.class_id = cls
	g.inventory = PackedStringArray(["amulet", "feather_charm", "silver_bangle", "iron_ring"])
	g.equipped = {"weapon": "", "armor": ""}
	g.jimat = []
	g.ingatan = 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)
