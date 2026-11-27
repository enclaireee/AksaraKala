extends SceneTree
## Kujang Pusaka and Ingatan (items.md 1): jamasan_pending from main bosses, jamasan, the tier cap,
## Daya and power_mult, and power_mult scaling weapon and spell damage.

const PATH := "user://test_pusaka.json"
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
	p.set_physics_process(false)

	g._reset()
	check(g.ingatan == 0 and g.jamasan_pending() == 0, "fresh game: ingatan %d pending %d" % [g.ingatan, g.jamasan_pending()])
	check(not g.jamasan() and g.ingatan == 0, "jamasan with nothing pending must refuse")
	check(g.daya() == 2 and is_equal_approx(g.power_mult(), 1.0), "tier 0: daya %d power %s" % [g.daya(), g.power_mult()])

	# Pending rises per main boss in `killed`; other kills do nothing.
	g.killed.append("some_random_mob")
	check(g.jamasan_pending() == 0, "a non-main kill made a jamasan pending")
	g.killed.append("sangkuriang")
	check(g.jamasan_pending() == 1, "sangkuriang: pending %d" % g.jamasan_pending())
	g.killed.append("sangkuriang")
	check(g.jamasan_pending() == 1, "the same boss counted twice: %d" % g.jamasan_pending())
	g.killed.append("bandung_bondowoso")
	g.killed.append("keris_gandring")
	check(g.jamasan_pending() == 3, "three bosses: pending %d" % g.jamasan_pending())
	# The Kidul trial counts through its flag.
	g.flags["cleared:kidul_trial"] = true
	check(g.jamasan_pending() == 4, "kidul trial flag: pending %d" % g.jamasan_pending())

	# jamasan raises ingatan and lowers pending.
	check(g.jamasan() and g.ingatan == 1 and g.jamasan_pending() == 3, "jamasan 1: ingatan %d pending %d" % [g.ingatan, g.jamasan_pending()])
	check(g.daya() == 3 and is_equal_approx(g.power_mult(), 1.1), "tier 1: daya %d power %s" % [g.daya(), g.power_mult()])
	for i in 3:
		check(g.jamasan(), "jamasan %d refused" % (i + 2))
	check(g.ingatan == 4 and g.jamasan_pending() == 0, "tier 4: ingatan %d pending %d" % [g.ingatan, g.jamasan_pending()])
	check(g.daya() == 6 and is_equal_approx(g.power_mult(), 1.4), "tier 4: daya %d power %s" % [g.daya(), g.power_mult()])
	# The cap: a fifth is refused even with every boss down and an extra kill recorded.
	g.killed.append("sangkuriang")
	check(not g.jamasan() and g.ingatan == 4 and g.jamasan_pending() == 0, "tier went past the cap: %d" % g.ingatan)

	# A flag-only trial, with nothing in killed, still gives exactly one pending.
	g._reset()
	g.flags["cleared:kidul_trial"] = true
	check(g.jamasan_pending() == 1, "trial flag alone: pending %d" % g.jamasan_pending())
	g._reset()
	g.killed.append("kidul_trial")
	check(g.jamasan_pending() == 1, "trial in killed: pending %d" % g.jamasan_pending())

	# power_mult scales the weapon multiplier and the spell damage multiplier.
	g._reset()
	g.changed.emit()
	var melee0 := p.dmg_mult
	var spell0 := SpellUtil.damage(p)
	g.ingatan = 3
	g.changed.emit()
	check(is_equal_approx(p.dmg_mult, melee0 * 1.3), "weapon dmg_mult did not scale by 1.3: %s -> %s" % [melee0, p.dmg_mult])
	check(is_equal_approx(SpellUtil.damage(p), spell0 * 1.3), "spell damage did not scale by 1.3: %s -> %s" % [spell0, SpellUtil.damage(p)])
	g.ingatan = 0
	g.changed.emit()
	check(is_equal_approx(p.dmg_mult, melee0) and is_equal_approx(SpellUtil.damage(p), spell0), "back at tier 0 the multipliers did not return")

	# Dialogue wiring for Kujang Pusaka, Jamasan, and Act III/IV payoffs + Ward power_mult scaling.
	var ibu_dlg := FileAccess.get_file_as_string("res://data/dialogue/ibu.tres")
	check(ibu_dlg.contains("flag:has_pusaka") and ibu_dlg.contains("codex:kujang") and ibu_dlg.contains("DLG_IBU_V601") and ibu_dlg.contains("DLG_IBU_V602"), "ibu.tres missing Pusaka wiring")
	check(FileAccess.get_file_as_string("res://data/dialogue/semar.tres").contains("DLG_SEMAR_V601"), "semar.tres missing Jamasan tutorial")
	check(FileAccess.get_file_as_string("res://data/dialogue/timur_empu.tres").contains("DLG_TIMUR_EMPU_V601"), "timur_empu.tres missing pamor line")
	var ward := (load("res://spells/ward.tscn") as PackedScene).instantiate()
	ward.caster = p
	ward.data = SpellData.new()
	ward.data.power = 50.0
	ward.data.duration = 5.0
	g.ingatan = 0
	world.add_child(ward)
	var sh0: int = p.health.shield
	ward.queue_free()
	await process_frame
	var ward2 := (load("res://spells/ward.tscn") as PackedScene).instantiate()
	ward2.caster = p
	ward2.data = SpellData.new()
	ward2.data.power = 50.0
	ward2.data.duration = 5.0
	g.ingatan = 3
	world.add_child(ward2)
	check(p.health.shield == roundi(50.0 * p.spell_mult() * 1.3), "Ward shield did not scale with power_mult: %d -> %d" % [sh0, p.health.shield])
	ward2.queue_free()

	DirAccess.remove_absolute(PATH)
	DirAccess.remove_absolute(PATH.replace(".json", ".bak"))
	quit(1 if fails > 0 else 0)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)
