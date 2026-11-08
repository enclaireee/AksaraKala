extends SceneTree
## Story v5 Major Choice effects, each with the flag on and off (quests.md 4, spells.md, items.md).

const PATH := "user://test_choice_effects.json"
var fails := 0
var g: Node
var zones: Node
var p: Player
var world: Node2D


func _initialize() -> void:
	g = root.get_node("Game")
	zones = root.get_node("Zones")
	g.save_path = PATH   # never touch the real save
	world = Node2D.new()
	root.add_child(world)
	p = load("res://entities/player/player.tscn").instantiate()
	world.add_child(p)
	await process_frame
	p.set_physics_process(false)
	var burst := SpellData.for_glyph("sunda_ca")
	var ombak := SpellData.for_glyph("jawa_ka")

	# choice_tell_ciung: Sunda Ca radius +10%
	_reset()
	check(is_equal_approx(_radius(burst), burst.radius), "burst radius unchanged without the flag (%s)" % _radius(burst))
	g.flags["choice_tell_ciung"] = true
	check(is_equal_approx(_radius(burst), burst.radius * SpellUtil.TELL_CIUNG_BURST_RADIUS), "burst radius +10%% with the flag (%s)" % _radius(burst))
	check(is_equal_approx(SpellUtil.radius_mult(ombak), 1.0), "tell_ciung leaves other spells alone")

	# choice_offer_memory: Ombak costs 3 less; +20% poise only in Act VI
	_reset()
	check(is_equal_approx(SpellUtil.cost(p, ombak), 35.0), "ombak costs 35 without the flag")
	check(is_equal_approx(_poise(ombak), p.tuning.spell_poise_mult), "ombak poise unchanged without the flag")
	g.flags["choice_offer_memory"] = true
	check(is_equal_approx(SpellUtil.cost(p, ombak), 32.0), "ombak costs 32 with the flag (%s)" % SpellUtil.cost(p, ombak))
	check(is_equal_approx(SpellUtil.cost(p, burst), 30.0), "offer_memory leaves other costs alone")
	check(is_equal_approx(_poise(ombak), p.tuning.spell_poise_mult), "no poise bonus outside Act VI")
	zones.current_zone = "gk_lupa"
	check(is_equal_approx(_poise(ombak), p.tuning.spell_poise_mult * 1.2), "+20%% poise in Act VI (%s)" % _poise(ombak))
	g.flags.erase("choice_offer_memory")
	check(is_equal_approx(_poise(ombak), p.tuning.spell_poise_mult), "no poise bonus in Act VI without the flag")

	# choice_offer_song: Berkah Pesisir, one lethal hit survived in Act VI, once per save
	_reset()
	p.health.hp = 10
	p.health.take_damage(50, null, true)
	check(p.health.is_dead(), "no flag: lethal hit kills")
	_reset()
	g.flags["choice_offer_song"] = true
	p.health.hp = 10
	p.health.take_damage(50, null, true)
	check(p.health.is_dead(), "flag but outside Act VI: lethal hit kills")
	_reset()
	g.flags["choice_offer_song"] = true
	zones.current_zone = "gk_pelataran"
	p.health.hp = 10
	p.health.take_damage(50, null, true)
	check(p.health.hp == 1 and not p.health.is_dead() and p.state != Player.State.DEAD, "Act VI lethal hit leaves 1 HP (%d)" % p.health.hp)
	check(g.has_flag("berkah_pesisir_used"), "used state stored as a flag")
	p.health.invincible_time = 0.0
	p.health.take_damage(50, null, true)
	check(p.health.is_dead(), "second lethal hit kills")

	# choice_release_aria: +15% stamina and Sakti regen in gk_ruang_kala only
	_reset()
	g.changed.emit()
	var base_regen := p.stamina.regen
	var base_gain := p.sakti.gain_mult
	g.flags["choice_release_aria"] = true
	g.changed.emit()
	check(is_equal_approx(p.stamina.regen, base_regen) and is_equal_approx(p.sakti.gain_mult, base_gain), "aria flag, wrong zone: no bonus")
	zones.current_zone = "gk_ruang_kala"
	g.changed.emit()
	check(is_equal_approx(p.stamina.regen, base_regen + 35.0 * 0.15), "aria in gk_ruang_kala: stamina regen +15 pts (%s vs %s)" % [p.stamina.regen, base_regen])
	check(is_equal_approx(p.sakti.gain_mult, base_gain + 0.15), "aria in gk_ruang_kala: sakti gain +0.15 (%s)" % p.sakti.gain_mult)
	zones.current_zone = "gk_lupa"
	p._physics_process(0.0)   # the zone change re-applies by itself
	check(is_equal_approx(p.stamina.regen, base_regen), "leaving the zone drops the bonus")
	zones.current_zone = "gk_ruang_kala"
	g.flags.erase("choice_release_aria")
	g.changed.emit()
	check(is_equal_approx(p.stamina.regen, base_regen), "no flag in gk_ruang_kala: no bonus")

	# Sabuk Galuh: vit +1 and 8% less damage taken
	_reset()
	g.changed.emit()
	var hp0 := p.health.max_hp
	g.add_item("sabuk_galuh", false)
	g.equip("sabuk_galuh")
	check(g.stat("vit") == 6 and p.health.max_hp == hp0 + p.tuning.stat_hp_per, "sabuk +1 vit (max hp %d vs %d)" % [p.health.max_hp, hp0])
	check(is_equal_approx(p.health.reduction, 0.08), "sabuk sets 8%% reduction (%s)" % p.health.reduction)
	p.health.hp = p.health.max_hp
	p.health.take_damage(50, null, true)
	check(p.health.hp == p.health.max_hp - 46, "50 damage becomes 46 (hp %d/%d)" % [p.health.hp, p.health.max_hp])
	p.health.take_damage(1, null, true)
	check(p.health.hp == p.health.max_hp - 47, "damage never drops below 1")
	g.equipped.accessory = ""
	g.changed.emit()
	check(p.health.reduction == 0.0, "no sabuk, no reduction")

	# Lontar Kuno: smudged threshold 0.65 -> 0.60, no Spirit
	_reset()
	g.changed.emit()
	check(is_equal_approx(p.cast.smudge_threshold(), 0.65), "threshold 0.65 without the lontar")
	g.add_item("lontar_kuno", false)
	g.equip("lontar_kuno")
	check(is_equal_approx(p.cast.smudge_threshold(), 0.60), "threshold 0.60 with the lontar (%s)" % p.cast.smudge_threshold())
	check(g.stat("spi") == 5, "lontar gives no Spirit (%d)" % g.stat("spi"))
	var gl: Array[GlyphData] = [GlyphData.by_id("sunda_ka")]
	var stroke: PackedVector2Array = gl[0].templates[0]
	check(Recognizer.classify(stroke, gl).power > 0.0, "a clean stroke casts at the default threshold")
	check(Recognizer.classify(stroke, gl, 1.01).power == 0.0, "a threshold above the score fizzles")
	g.equipped.accessory = ""
	g.changed.emit()

	_finish()


func _reset() -> void:
	g.flags = {}
	g.stats = {"vit": 5, "end": 5, "str": 5, "dex": 5, "spi": 5}
	g.equipped.accessory = ""
	zones.current_zone = ""
	p.health.invincible_time = 0.0
	p.health.hp = p.health.max_hp
	p.state = Player.State.FREE
	g.changed.emit()


func _radius(spell: SpellData) -> float:
	var s: Node2D = spell.scene.instantiate()
	s.caster = p
	s.data = spell
	world.add_child(s)
	var r: float = s._radius
	s.queue_free()
	return r


func _poise(spell: SpellData) -> float:
	var s: Node2D = spell.scene.instantiate()
	s.caster = p
	s.data = spell
	world.add_child(s)
	var m: float = s.poise_mult
	s.queue_free()
	return m


func _finish() -> void:
	if fails == 0:
		quit(0)
	else:
		quit(1)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)
