class_name PathDancer extends RefCounted
## The Penari Topeng's own spell kit (spells.md 3 "Second paths", classes.md). SpellVariants.cast() routes here.

const NAMES := {
	"sunda_ka": "Kibas Kipas",
	"sunda_nga": "Selendang",
	"sunda_ca": "Topeng Klana",
	"jawa_ha": "Tari Panji",
	"jawa_na": "Langkah Kembang",
	"jawa_ca": "Gamelan Bertalu",
	"jawa_ra": "Penari Bayangan",
	"jawa_ka": "Menari di Ombak",
	"sunda_ta": "Panca Wanda",
}


const FAN_DMG := 12.0          # TUNE: per blade
const FAN_REACH := 110.0       # TUNE
const SCARF_DMG := 12.0        # TUNE
const KLANA_BLAST := 46.0      # TUNE
const PANJI_PER_STACK := 0.04  # TUNE: of max HP per Wirama stack
const PANJI_FLOOR := 0.06      # TUNE: heal with no stacks
const STEP_DMG := 16.0         # TUNE
const STEP_LEN := 40.0         # TUNE
const MASK_DMG := 10.0         # TUNE
const WAVE_CARRY := 100.0      # TUNE: px the caster rides the wave
const WAVE_TIME := 0.35        # TUNE


## `d` is the unit aim direction, `pos` the caster's position, `k` = Spirit x school x power (multiply base damage by it).
static func cast(spell: SpellData, caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float, power: float) -> void:
	match spell.glyph_id:
		"sunda_ka": _fan(caster, par, d, pos, tint, k)
		"sunda_nga": _scarf(caster, par, d, pos, tint, k)
		"sunda_ca":
			SpellVariants.blast(caster, pos, spell.glyph_id, KLANA_BLAST, 64.0, power)
			_buff(caster, "klana", 6.0)
		"jawa_ha": _panji(caster, par, pos, tint, power)
		"jawa_na": _steps(caster, par, d, tint, k)
		"jawa_ca":
			_buff(caster, "gamelan", 12.0)
			SpellFX.burst(par, "cast_sigil", 6, pos, tint, 1.2, 10.0)
		"jawa_ra": _masks(caster, par, pos, tint, k)
		"jawa_ka": _wave(spell, caster, par, d, power)
		"sunda_ta": _panca(spell, caster, par, tint, power)


static func _buff(caster: Node2D, id: String, seconds: float) -> void:
	if caster.has_method("buff"):
		caster.buff(id, seconds)


static func _wirama(caster: Node2D) -> int:
	var w: Variant = caster.get("wirama")
	return int(w) if w != null else 0


static func _heal(caster: Node2D, frac: float) -> void:
	if caster.get("health") != null:
		caster.health.heal(maxi(1, roundi(caster.health.max_hp * frac)))


## Moves the caster by `v`, stopping at walls (like dash_strike.gd).
static func _move(caster: Node2D, v: Vector2) -> void:
	if caster is CharacterBody2D:
		(caster as CharacterBody2D).move_and_collide(v)
	else:
		caster.global_position += v


static func _invincible(caster: Node2D, seconds: float) -> void:
	if caster.get("health") != null:
		caster.health.set_invincible(seconds)


## Sunda Ka: five blades across a wide cone, each cutting the nearest foe on its line and making it bleed.
static func _fan(caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float) -> void:
	var dmg := roundi(FAN_DMG * k)
	for i in 5:
		var dir := d.rotated(deg_to_rad(-40.0 + 20.0 * i))
		var e := SpellUtil.nearest_enemy(caster.get_tree(), pos, FAN_REACH, dir, deg_to_rad(10.0))
		var end := e.global_position if e != null else pos + dir * FAN_REACH
		SpellVariants._zap(par, pos + Vector2(0, -6), end + Vector2(0, -6), tint)
		if e != null:
			SpellUtil.strike(e, dmg)
			SpellUtil.burn(e, dmg)   # a bleed
			SpellFX.burst(par, "hit_burst", 5, end, tint, 0.8, 22.0)


## Sunda Nga: the scarf binds three spots along a line.
static func _scarf(caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float) -> void:
	for i in 3:
		var z := SpellVariants._zone(caster, pos + d * (40.0 * (i + 1)), tint)
		z.radius = 22.0
		z.life = 0.5
		z.tick = 1.0   # one tick only
		z.damage = roundi(SCARF_DMG * k)
		z.root = 1.8
		par.add_child(z)


## Jawa Ha: heals per Wirama stack and cleanses, like heal.gd's base spell.
static func _panji(caster: Node2D, par: Node, pos: Vector2, tint: Color, power: float) -> void:
	_heal(caster, maxf(PANJI_FLOOR, PANJI_PER_STACK * _wirama(caster)) * power)
	if caster.get("status") != null:
		for t in [Status.Type.CURSE, Status.Type.BURN, Status.Type.SLOW]:
			caster.status.clear(t)
	SpellFX.burst(par, "shock", 6, pos, Color(tint, 0.7), 0.3, 14.0)


## Jawa Na: three zigzag steps, each cutting what is near the landing point and feeding Wirama.
static func _steps(caster: Node2D, par: Node, d: Vector2, tint: Color, k: float) -> void:
	var dirs := [d.rotated(deg_to_rad(35.0)), d.rotated(deg_to_rad(-35.0)), d]
	_invincible(caster, 0.5)
	for i in 3:
		SpellVariants.later(caster, 0.1 * i, func() -> void:
			var before := caster.global_position
			_move(caster, dirs[i] * STEP_LEN)
			var cut := SpellFX.burst(par, "dash_slash", 4, (before + caster.global_position) * 0.5, tint, 0.8, 20.0)
			if cut:
				cut.rotation = (dirs[i] as Vector2).angle()
			for e in SpellUtil.enemies_near(caster.get_tree(), caster.global_position, 26.0):
				SpellUtil.strike(e, roundi(STEP_DMG * k))
				if caster.has_method("add_wirama"):
					caster.add_wirama(1))


## Jawa Ra: four masks circle the caster. ponytail: the ring zone stands in for the mask sprites; each tick flashes four.
static func _masks(caster: Node2D, par: Node, pos: Vector2, tint: Color, k: float) -> void:
	var z := SpellVariants._zone(caster, pos, tint)
	z.follow = true
	z.radius = 46.0
	z.life = 10.0
	z.tick = 0.4
	z.damage = roundi(MASK_DMG * k)
	z.on_tick = func(zz: SpellZone) -> void:
		var a := Time.get_ticks_msec() / 400.0
		for i in 4:
			SpellFX.burst(par, "hit_burst", 5, zz.global_position + Vector2.from_angle(a + i * TAU / 4.0) * zz.radius, tint, 0.6, 10.0)
	SpellVariants._replace(caster.get_tree(), "dancer_masks", z)
	par.add_child(z)


## Jawa Ka: the normal Ombak wave, with the caster riding along inside it.
static func _wave(spell: SpellData, caster: Node2D, par: Node, d: Vector2, power: float) -> void:
	if spell.scene != null:
		var s: Node2D = spell.scene.instantiate()
		s.caster = caster
		s.data = spell
		s.direction = d
		s.power = power
		s.global_position = caster.global_position
		par.add_child(s)
	_invincible(caster, WAVE_TIME + 0.1)
	for i in 7:
		SpellVariants.later(caster, WAVE_TIME * (i + 1) / 7.0, func() -> void:
			_move(caster, d * WAVE_CARRY / 7.0))


## Sunda Ta: five masks, one a second, each acting where the caster stands then.
static func _panca(spell: SpellData, caster: Node2D, par: Node, tint: Color, power: float) -> void:
	for i in 5:
		SpellVariants.later(caster, float(i), func() -> void: _mask(i, spell.glyph_id, caster, par, tint, power))


static func _mask(i: int, id: String, caster: Node2D, par: Node, tint: Color, power: float) -> void:
	var at := caster.global_position
	SpellFX.burst(par, "cast_sigil", 6, at, tint, 0.9, 12.0)
	match i:
		0: _heal(caster, 0.08)
		1: _buff(caster, "wanda", 5.0)
		2: SpellVariants.blast(caster, at, id, 24.0, 64.0, power)
		3: SpellVariants.blast(caster, at, id, 4.0, 80.0, power, 6.0)   # the stagger
		4: SpellVariants.blast(caster, at, id, 60.0, 90.0, power)
