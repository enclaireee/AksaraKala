extends SceneTree
## Player stats, armor, passives, flask and weapons from data (rpg.md 2-5, items.md, classes.md).

const DT := 1.0 / 60.0
const PATH := "user://test_player_stats.json"
var fails := 0
var g: Node
var p: Player


func _initialize() -> void:
	g = root.get_node("Game")
	g.save_path = PATH   # never touch the real save
	var world := Node2D.new()
	root.add_child(world)
	p = load("res://entities/player/player.tscn").instantiate()
	world.add_child(p)
	await process_frame
	p.set_physics_process(false)   # stepped by hand

	# Formulas at the default 5 in every stat, dagger fallback.
	check(p.item.id == "dagger", "no weapon equipped should fall back to the dagger")
	check(p.health.max_hp == 130 and p.health.hp == 130, "max hp 80+10*5, full at start (%d)" % p.health.max_hp)
	check(is_equal_approx(p.stamina.max_stamina, 110.0) and is_equal_approx(p.stamina.value, 110.0), "stamina 80+6*5")
	check(is_equal_approx(p.stamina.regen, 35.0 * 1.05), "stamina regen +1 pct per End (%s)" % p.stamina.regen)
	check(is_equal_approx(p.dmg_mult, 1.25), "melee damage x(1+0.05*Str)")
	check(is_equal_approx(p.atk_speed, 1.05), "attack speed +1% per Dex")
	check(is_equal_approx(p.sakti.gain_mult, 1.1) and p.sakti.max_value == 100.0, "sakti gain x(1+0.02*Spi)")

	# New stats recompute, but never heal.
	p.health.hp = 100
	g.stats = {"vit": 20, "end": 0, "str": 0, "dex": 20, "spi": 10}
	g.changed.emit()
	check(p.health.max_hp == 280 and p.health.hp == 100, "apply_from_game must not heal (hp %d/%d)" % [p.health.hp, p.health.max_hp])
	check(is_equal_approx(p.stamina.max_stamina, 80.0), "stamina with 0 End")
	check(is_equal_approx(p.dmg_mult, 1.0) and is_equal_approx(p.atk_speed, 1.2), "Str 0, Dex 20")
	check(is_equal_approx(p.spell_mult(), 1.5), "spell_mult 1+0.05*Spi")
	g.stats = {"vit": 0, "end": 5, "str": 5, "dex": 5, "spi": 5}
	g.changed.emit()
	check(p.health.max_hp == 80 and p.health.hp == 80, "hp clamps to a lower max")
	g.stats = {"vit": 5, "end": 5, "str": 5, "dex": 5, "spi": 5}
	g.changed.emit()

	# Armor and accessory bonuses.
	g.add_item("leather_armor", false); g.add_item("amulet", false); g.add_item("feather_charm", false)
	g.equip("leather_armor"); g.equip("amulet")
	check(p.health.defense == 2 and p.health.max_hp == 140, "leather armor defense 2 and amulet +10 hp")
	p.health.hp = p.health.max_hp
	p.health.take_damage(20, null, true)
	check(p.health.hp == 140 - 18, "defense 2 takes 18 of 20 (hp %d)" % p.health.hp)
	p.health.defense = 19
	p.health.take_damage(1, null, true)
	check(p.health.hp == 140 - 19, "damage never drops below 1")
	p.health.take_damage(0, null, true)
	check(p.health.hp == 140 - 19, "0 damage stays 0")
	p.health.defense = 2
	g.equip("amulet")
	g.add_item("feather_charm", false); g.equipped.accessory = "feather_charm"; g.changed.emit()
	check(is_equal_approx(p.move_mult, 1.08), "feather charm +8% move speed")
	g.equipped.accessory = ""; g.changed.emit()

	# Healing flask.
	g.flask_charges = 3
	p.health.hp = p.health.max_hp
	p._try_flask()
	check(p.state == Player.State.FREE and g.flask_charges == 3, "flask used at full HP")
	p.health.hp = 40
	p._try_flask()
	check(p.state == Player.State.DRINK, "flask did not start")
	step(int(p.tuning.flask_time / DT) - 2)
	check(g.flask_charges == 3 and p.health.hp == 40, "flask paid out before the drink ended")
	step(4)
	check(p.state == Player.State.FREE and g.flask_charges == 2, "flask charge not spent (%d)" % g.flask_charges)
	check(p.health.hp == 40 + roundi(0.4 * p.health.max_hp), "flask heals 40 pct of max (hp %d)" % p.health.hp)
	g.herb_pouches = 2
	p.health.hp = 40
	p._try_flask(); step(40)
	check(p.health.hp == 40 + roundi(0.5 * p.health.max_hp), "2 herb pouches heal 50 pct (hp %d)" % p.health.hp)
	p.health.hp = 40
	p._try_flask(); p.buffer["dodge"] = p.clock; step(2)   # a dodge cancels the drink, charge kept
	check(p.state == Player.State.DODGE and g.flask_charges == 1, "dodge did not cancel the drink")
	step(60)
	g.flask_charges = 0
	p._try_flask()
	check(p.state == Player.State.FREE, "flask used with 0 charges")

	# Rogue Light Step.
	p.stamina.value = p.stamina.max_stamina
	p.buffer["dodge"] = p.clock; step(1)
	check(is_equal_approx(p.stamina.value, p.stamina.max_stamina - 20.0), "default dodge costs 20")
	step(60)
	g.class_id = "rogue"; g.changed.emit()
	p.stamina.value = p.stamina.max_stamina
	p.buffer["dodge"] = p.clock; step(1)
	check(is_equal_approx(p.stamina.value, p.stamina.max_stamina - 14.0), "rogue dodge costs 14 (%s)" % p.stamina.value)
	step(60)
	g.class_id = "mage"; g.changed.emit()
	check(p.sakti.max_value == 120.0 and is_equal_approx(p.sakti.gain_mult, 1.1 * 1.2), "Keen Mind")
	g.class_id = ""; g.changed.emit()

	# Weapons from data: Gandring's curse, then F1 to a heavy weapon.
	g.add_item("keris_mpu_gandring", false); g.add_item("dagger", false); g.add_item("broadsword", false)
	g.equip("keris_mpu_gandring")
	check(p.item.self_damage == 1, "gandring not equipped")
	var hb := Hurtbox.new()
	hb.health = Health.new()
	p.health.hp = 50
	p._on_hit_landed(hb, null, false, 0)
	check(p.health.hp == 49, "gandring hit should cost 1 HP (hp %d)" % p.health.hp)
	p.health.hp = 1
	p._on_hit_landed(hb, null, false, 0)
	check(p.health.hp == 1, "gandring must never kill")
	g.equip("dagger")
	f1()
	check(p.item.id == "broadsword" and p.item.archetype == "heavy", "F1 did not switch to the broadsword")
	check(p.item.sakti_per_hit == 10.0, "heavy sakti per hit")
	p.sakti.value = 0.0
	p._on_hit_landed(hb, null, false, 0)
	check(is_equal_approx(p.sakti.value, 10.0 * p.sakti.gain_mult), "heavy hit gave %s sakti" % p.sakti.value)
	check(p._damage() == roundi(22 * 1.25), "broadsword damage %d" % p._damage())
	check(is_equal_approx(p._phase_len(Player.Phase.WINDUP), 0.25 / 1.05), "heavy wind-up with Dex 5")
	p.stamina.value = p.stamina.max_stamina
	p.buffer["attack"] = p.clock; step(1)
	check(is_equal_approx(p.stamina.value, p.stamina.max_stamina - 25.0), "broadsword costs 25 stamina")

	hb.health.free(); hb.free()
	DirAccess.remove_absolute(PATH)
	DirAccess.remove_absolute(PATH.get_basename() + ".bak")
	g._reset()
	quit(1 if fails > 0 else 0)


func step(n: int) -> void:
	for i in n:
		p._physics_process(DT)


func f1() -> void:
	var e := InputEventKey.new()
	e.pressed = true
	e.physical_keycode = KEY_F1
	p._unhandled_input(e)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)
