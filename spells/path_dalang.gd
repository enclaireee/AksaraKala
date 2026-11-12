class_name PathDalang extends RefCounted
## The Dalang's own spell kit (spells.md 3 "Second paths", classes.md). SpellVariants.cast() routes here.

const NAMES := {
	"sunda_ka": "Panah Pasopati",
	"sunda_nga": "Benang Dalang",
	"sunda_ca": "Gara-gara",
	"jawa_ha": "Suluk Pangruwat",
	"jawa_na": "Cakil Menerjang",
	"jawa_ca": "Suluk",
	"jawa_ra": "Punakawan",
	"jawa_ka": "Ombak Kelir",
	"jawa_la": "Tancep Kayon",
}

const BOLT_DMG := 34.0         # TUNE Panah Pasopati
const BOLT_BACK := 14.0        # TUNE px behind the caster the shadow fires from
const STRING_RANGE := 120.0    # TUNE Benang Dalang reach
const STRING_COUNT := 4        # TUNE
const STRING_TIME := 2.2       # TUNE root time, then the blast
const STRING_BLAST := 14.0     # TUNE
const GARA_DELAY := 0.8        # TUNE telegraph
const GARA_BLAST := 62.0       # TUNE
const GARA_RADIUS := 96.0      # TUNE
const PANGRUWAT_HEAL := 0.15   # TUNE share of max HP
const PANGRUWAT_TIME := 6.0    # TUNE
const SULUK_TIME := 12.0       # TUNE
const CAKIL_DMG := 36.0        # TUNE
const CAKIL_STEPS := 5         # TUNE
const CAKIL_GAP := 26.0        # TUNE px between steps
const PUNAKAWAN_SHARE := 0.3   # TUNE of the normal summon damage
const PUNAKAWAN_TIME := 12.0   # TUNE
const KELIR_DMG := 36.0        # TUNE
const KELIR_ROOT := 1.5        # TUNE
const KAYON_RADIUS := 240.0    # TUNE
const KAYON_TIME := 3.0        # TUNE
const KAYON_BOSS_SLOW := 0.4   # TUNE


## `d` is the unit aim direction, `pos` the caster's position, `k` = Spirit x school x power (multiply base damage by it).
static func cast(spell: SpellData, caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float, power: float) -> void:
	match spell.glyph_id:
		"sunda_ka": _pasopati(caster, par, d, pos, power)
		"sunda_nga": _benang(caster, par, pos, tint, power)
		"sunda_ca": _gara(caster, par, pos, tint, power)
		"jawa_ha":
			if caster.get("health") != null:
				caster.health.heal(maxi(1, roundi(caster.health.max_hp * PANGRUWAT_HEAL * power)))
			_buff(caster, par, pos, tint, "pangruwat", PANGRUWAT_TIME)
		"jawa_na": _cakil(caster, par, d, pos, tint, k)
		"jawa_ca": _buff(caster, par, pos, tint, "suluk", SULUK_TIME)
		"jawa_ra": _punakawan(spell, caster, par, pos, tint, power)
		"jawa_ka": _kelir(caster, par, d, pos, tint, k)
		"jawa_la": _kayon(caster, par, pos, tint)


static func _buff(caster: Node2D, par: Node, pos: Vector2, tint: Color, id: String, seconds: float) -> void:
	if caster.has_method("buff"):
		caster.buff(id, seconds)
	SpellFX.burst(par, "cast_sigil", 6, pos, tint, 1.0, 12.0)


## Arjuna's shadow fires one homing arrow from behind the caster.
static func _pasopati(caster: Node2D, par: Node, d: Vector2, pos: Vector2, power: float) -> void:
	var kd := SpellData.for_glyph("sunda_ka")
	if kd == null or kd.scene == null:
		return
	var s: Bolt = kd.scene.instantiate()
	s.mode = "seek"
	s.caster = caster
	s.data = SpellUtil.sub_data("sunda_ka", BOLT_DMG, 0.0, kd.scene)
	s.power = power
	s.reach = 300.0
	s.direction = d
	s.global_position = pos - d * BOLT_BACK
	par.add_child(s)


## Strings root the nearest foes (bosses are slowed), then each one still standing is hit.
static func _benang(caster: Node2D, par: Node, pos: Vector2, tint: Color, power: float) -> void:
	var foes := SpellUtil.enemies_near(caster.get_tree(), pos, STRING_RANGE)
	foes.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		return a.global_position.distance_squared_to(pos) < b.global_position.distance_squared_to(pos))
	for e in foes.slice(0, STRING_COUNT):
		SpellVariants._zap(par, pos + Vector2(0, -6), e.global_position + Vector2(0, -6), tint)
		if e.get("status") != null:
			var tuning: CombatTuning = e.status.tuning
			if e.is_in_group("boss"):
				e.status.apply(Status.Type.SLOW, tuning.bind_slow_time, tuning.bind_slow_mult)
			else:
				e.status.apply(Status.Type.BOUND, STRING_TIME)
		SpellVariants.later(caster, STRING_TIME, func() -> void:
			if is_instance_valid(e):
				SpellVariants.blast(caster, e.global_position, "sunda_nga", STRING_BLAST, 24.0, power))


## A telegraph ring, then the biggest burst where it was cast.
static func _gara(caster: Node2D, par: Node, pos: Vector2, tint: Color, power: float) -> void:
	var z := SpellVariants._zone(caster, pos, tint)
	z.radius = GARA_RADIUS
	z.delay = GARA_DELAY
	z.life = GARA_DELAY
	z.on_end = func(_z: SpellZone) -> void:
		SpellVariants.blast(caster, pos, "sunda_ca", GARA_BLAST, GARA_RADIUS, power, 2.0, 40.0)
	par.add_child(z)


## A puppet lunges along `d` in steps; the caster stays put. Each foe is hit once.
static func _cakil(caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float) -> void:
	var hit := {}
	var dmg := roundi(CAKIL_DMG * k)
	for i in CAKIL_STEPS:
		var pt := pos + d * CAKIL_GAP * (i + 1)
		SpellVariants.later(caster, 0.05 * i, func() -> void:
			for e in SpellUtil.enemies_near(caster.get_tree(), pt, CAKIL_GAP * 0.85):
				if not hit.has(e.get_instance_id()):
					hit[e.get_instance_id()] = true
					SpellUtil.strike(e, dmg)
			var cut := SpellFX.burst(par, "dash_slash", 4, pt + Vector2(0, -6), tint, 0.8, 24.0)
			if cut:
				cut.rotation = d.angle())


## Four small puppets, each a base summon at 30% damage.
static func _punakawan(spell: SpellData, caster: Node2D, par: Node, pos: Vector2, tint: Color, power: float) -> void:
	if spell.scene == null:
		return
	var sd := SpellUtil.sub_data("jawa_ra", spell.power * PUNAKAWAN_SHARE, spell.radius, spell.scene)
	sd.duration = PUNAKAWAN_TIME
	for i in 4:
		var s: Node2D = spell.scene.instantiate()
		s.caster = caster
		s.data = sd
		s.power = power
		s.global_position = pos + Vector2.from_angle(TAU * i / 4.0 + PI / 4.0) * 22.0
		par.add_child(s)
	SpellFX.burst(par, "cast_sigil", 6, pos, tint, 1.0, 12.0)


## The wave pins instead of pushing: stepped root zones, each foe hurt once per cast.
static func _kelir(caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float) -> void:
	var hit := {}
	var dmg := roundi(KELIR_DMG * k)
	for i in 5:
		var at := pos + d * 36.0 * (i + 1)
		SpellVariants.later(caster, 0.08 * i, func() -> void:
			var z := SpellVariants._zone(caster, at, tint)
			z.radius = 30.0
			z.life = 0.4
			z.tick = 1.0
			z.root = KELIR_ROOT
			z.on_tick = func(zz: SpellZone) -> void:
				for e in SpellUtil.enemies_near(zz.get_tree(), zz.global_position, zz.radius):
					if not hit.has(e.get_instance_id()):
						hit[e.get_instance_id()] = true
						SpellUtil.strike(e, dmg)
			par.add_child(z))


## The signature: a kayon planted at the caster freezes the whole screen of foes; spells cost half while it stands.
static func _kayon(caster: Node2D, par: Node, pos: Vector2, tint: Color) -> void:
	var z := SpellVariants._zone(caster, pos, tint)
	z.radius = KAYON_RADIUS
	z.life = KAYON_TIME
	z.tick = 0.5
	z.root = KAYON_TIME
	z.slow = KAYON_BOSS_SLOW   # ponytail: also slows rooted foes, harmless; bosses are slowed by this and by SpellZone's root fallback
	SpellVariants._replace(caster.get_tree(), "kayon", z)
	par.add_child(z)
	SpellFX.burst(par, "cast_sigil", 6, pos, tint, 2.0, 10.0)
