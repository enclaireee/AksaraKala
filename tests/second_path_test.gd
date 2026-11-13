extends SceneTree
## The four second paths (classes.md): own spell kits, mechanics, favoured gear, sibling swap and SQ-X1.

const PATH := "user://second_path_test.json"
const SECOND := ["lancer", "herder", "dancer", "dalang"]
const SHARED := ["sunda_ka", "sunda_ga", "sunda_nga", "sunda_ca", "jawa_ha", "jawa_na", "jawa_ca", "jawa_ra"]
var fails := 0
var g: Node
var p: Player
var world: Node2D


func _initialize() -> void:
	await process_frame
	g = root.get_node("Game")
	g.save_path = PATH
	g._reset()
	world = Node2D.new()
	root.add_child(world)
	p = load("res://entities/player/player.tscn").instantiate()
	world.add_child(p)
	await process_frame
	p.set_physics_process(false)

	# Gear: 32 favoured items load, and every school item has a sibling for its second path.
	var n := 0
	for f in DirAccess.get_files_at("res://data/items"):
		var it: ItemData = ItemData.by_id(f.get_basename().get_basename())
		if it == null or it.favoured == "":
			continue
		n += 1
		check(it.icon != null and it.icon.get_size() == Vector2(16, 16), it.id + " icon")
		check(not it.favoured_bonus.is_empty(), it.id + " has a favoured bonus")
	check(n == 32, "32 favoured items (%d)" % n)
	for first in g.SIBLING_ITEM:
		var a := ItemData.by_id(first)
		var b := ItemData.by_id(g.SIBLING_ITEM[first])
		check(a != null and b != null and a.slot == b.slot and ClassData.school(b.favoured) == a.favoured, "sibling of " + first)

	# Sibling swap and favoured bonus, on and off.
	_class("lancer")
	check(g.add_item("parang_perang", false) == "tombak_galah", "a lancer gets the sibling")
	check(g.add_item("busur_petung", false) == "busur_petung", "another school's item is not swapped")
	check(g.check("class:lancer") and not g.check("class:warrior"), "class: cond")
	g.equip("tombak_galah")
	check(is_equal_approx(g.bonus("tip_damage"), 0.15), "favoured bonus on")
	var with_tip: float = g.bonus("tip_damage")
	_class("warrior")
	check(g.add_item("parang_perang", false) == "parang_perang", "a first path keeps the school item")
	check(is_zero_approx(g.bonus("tip_damage")) and with_tip > 0.0, "favoured bonus off for another class")
	g.equip("parang_perang")
	check(is_equal_approx(g.bonus("damage_mult"), 0.1), "first path damage_mult favoured bonus on")

	# Independent second-path spell scaling & cost rules.
	_class("lancer")
	check(is_equal_approx(SpellUtil.damage(p), p.spell_mult() * 1.0), "lancer has 1.0x spell damage")
	check(is_equal_approx(SpellUtil.cost(p, SpellData.for_glyph("sunda_nga")), 20.0 * 0.85), "lancer formation cost x0.85")
	_class("herder")
	check(is_equal_approx(SpellUtil.damage(p), p.spell_mult() * 0.95), "herder has 0.95x spell damage")
	check(is_equal_approx(SpellUtil.poise_mult(SpellData.for_glyph("sunda_ca"), p), 1.25), "herder spell poise x1.25")
	_class("dancer")
	check(is_equal_approx(SpellUtil.cost(p, SpellData.for_glyph("jawa_na")), 20.0 * 0.85), "dancer dance cost x0.85")
	g.add_item("kipas_kembar", false)
	g.equip("kipas_kembar")
	check(p.wirama_cap() == 10, "kipas_kembar raises wirama cap to 10")
	_class("dalang")
	check(is_equal_approx(SpellUtil.damage(p), p.spell_mult() * 1.05), "dalang has 1.05x spell damage")
	g.add_item("beskap_dalang", false)
	g.equip("beskap_dalang")
	check(p.lakon_cap() == 3, "beskap_dalang raises lakon cap to 3")
	g._reset()

	# Mechanics.
	_class("lancer")
	p._class_tick(0.6)
	check(p.braced() and is_equal_approx(p.health.reduction, 0.25), "kuda-kuda after standing still (%s)" % p.health.reduction)
	p.move_dir = Vector2.RIGHT
	p._class_tick(0.1)
	check(not p.braced() and is_zero_approx(p.health.reduction), "moving breaks the brace")
	p.move_dir = Vector2.ZERO
	_class("dancer")
	p.add_wirama(3)
	check(p.wirama == 3, "wirama builds")
	p.add_wirama(20)
	check(p.wirama == 8, "wirama caps at 8")
	_class("dalang")
	check(is_equal_approx(p.lakon("a"), 1.15) and is_equal_approx(p.lakon("b"), 1.3) and is_equal_approx(p.lakon("c"), 1.3), "lakon stacks to +30%")
	check(is_equal_approx(p.lakon("c"), 1.0), "repeating a glyph resets lakon")
	_class("herder")
	check(is_equal_approx(p.move_mult, 1.1), "herder moves 10%% faster (%s)" % p.move_mult)

	# Spell kits: every glyph of every second path casts; the two strike glyphs hurt a dummy.
	for cls in SECOND:
		_class(cls)
		var kit = SpellVariants._kit(cls)
		check(kit != null and kit.NAMES.size() == 9, cls + " kit has 9 spells")
		check(SpellVariants.SIGNATURE.find_key(cls) in kit.NAMES, cls + " has its signature")
		for id in kit.NAMES:
			var e := (load("res://entities/enemies/tank.tscn") as PackedScene).instantiate() as EnemyBase
			e.position = p.position + Vector2(40, 0)
			world.add_child(e)
			await physics_frame
			e.set_physics_process(false)
			var hp: int = e.health.hp
			check(SpellVariants.cast(SpellData.for_glyph(id), p, Vector2.RIGHT, 1.0, false), "%s/%s casts" % [id, cls])
			for i in 80:
				await physics_frame
			if id in ["sunda_ka", "sunda_ca"]:
				check(not is_instance_valid(e) or e.health.hp < hp, "%s/%s hurts" % [id, cls])
			for c in world.get_children():
				if c != p:
					c.queue_free()
			p.global_position = Vector2.ZERO
			await physics_frame

	# SQ-X1: each of the eight classes gets its own aksara and weapon.
	var q := QuestData.by_id("sq_x1")
	for cls in q.rewards.class_items:
		g._reset()
		g.class_id = cls
		g.glyphs_learned = PackedStringArray(SHARED)
		g.set_flag("mq1_10", false)
		check(g.start_quest("sq_x1"), "sq_x1 starts for " + cls)
		root.get_node("Events").talked_to.emit("nyai_rukmi")
		var sig: String = SpellVariants.SIGNATURE.find_key(cls)
		check(g.quest_state("sq_x1") == "done" and sig in g.glyphs_learned, "%s learns %s" % [cls, sig])
		var w := ItemData.by_id(q.rewards.class_items[cls])
		check(w != null and w.id in g.inventory and w.favoured == cls, cls + " gets its class weapon")

	for f in [PATH, PATH.get_basename() + ".bak", PATH + ".tmp"]:
		DirAccess.remove_absolute(f)
	g._reset()
	quit(1 if fails > 0 else 0)


func _class(cls: String) -> void:
	g.class_id = cls
	g.changed.emit()
	p.buffs.clear()
	p.still = 0.0
	p.wirama = 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)
