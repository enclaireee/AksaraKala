class_name PathHerder extends RefCounted
## The Pangangon's own spell kit (spells.md 3 "Second paths", classes.md). SpellVariants.cast() routes here.

const NAMES := {
	"sunda_ka": "Batu Guntur",
	"sunda_nga": "Kandang Bambu",
	"sunda_ca": "Putar Bandring",
	"jawa_ha": "Tembang Suling",
	"jawa_na": "Tunggang Kerbau",
	"jawa_ca": "Napas Padang",
	"jawa_ra": "Kerbau Sakti",
	"jawa_ka": "Banjir Sawah",
	"sunda_ba": "Giring Kawanan",
}


const BOULDER_BASE := 40.0   # TUNE
const ROLL_BASE := 12.0      # TUNE
const PEN_RADIUS := 50.0     # TUNE
const STONE_DAMAGE := 18.0   # TUNE
const SONG_HEAL := 0.05      # TUNE: fraction of max HP per second
const RIDE_DIST := 150.0     # TUNE
const RIDE_DAMAGE := 26.0    # TUNE
const BUFFALO_MULT := 1.6    # TUNE
const BUFFALO_EVERY := 1.6   # TUNE
const MUD_RADIUS := 50.0     # TUNE
const HERD_DAMAGE := 60.0    # TUNE
const HERD_LANES := 5
const HERD_STEPS := 6


## `d` is the unit aim direction, `pos` the caster's position, `k` = Spirit x school x power (multiply base damage by it).
static func cast(spell: SpellData, caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float, power: float) -> void:
	match spell.glyph_id:
		"sunda_ka": _boulder(caster, par, d, pos, tint, power)
		"sunda_nga": _pen(caster, par, d, pos, tint, k)
		"sunda_ca": _stones(caster, par, pos, power)
		"jawa_ha": _song(caster, par, pos, tint)
		"jawa_na": _ride(caster, par, d, pos, tint, k)
		"jawa_ca":
			if caster.has_method("buff"):
				caster.buff("napas", 12.0)
			SpellFX.burst(par, "cast_sigil", 6, pos, tint, 1.0, 12.0)
		"jawa_ra": _buffalo(spell, caster, par, d, pos, tint, power)
		"jawa_ka": _flood(spell, caster, par, d, pos, tint, k, power)
		"sunda_ba": _herd(caster, par, d, pos, tint, k)


## Carries `e` by `v` over `t` seconds. Bosses stay put. ponytail: ignores walls, enemy AI may fight the tween.
static func _shove(e: Node, v: Vector2, t: float) -> void:
	if e is Node2D and not e.is_in_group("boss"):
		e.create_tween().tween_property(e, "global_position", (e as Node2D).global_position + v, t)


## Batu Guntur: a boulder lands, then rolls on as three small blasts.
static func _boulder(caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, power: float) -> void:
	var t := SpellUtil.nearest_enemy(caster.get_tree(), pos, 150.0, d, 0.7)
	var at: Vector2 = t.global_position if t != null else pos + d * 100.0
	SpellFX.burst(par, "cast_sigil", 6, at, tint, 0.9, 12.0)
	SpellVariants.later(caster, 0.35, func() -> void:
		SpellVariants.blast(caster, at, "sunda_ka", BOULDER_BASE, 40.0, power)
		for i in 3:
			var pt := at + d * (27.0 * (i + 1))
			SpellVariants.later(caster, 0.17 * (i + 1), func() -> void:
				SpellVariants.blast(caster, pt, "sunda_ka", ROLL_BASE, 22.0, power, 1.0, 40.0)))


## Kandang Bambu: a pen that slows, tugs in and eats shots.
static func _pen(caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float) -> void:
	var t := SpellUtil.nearest_enemy(caster.get_tree(), pos, 140.0, d, 0.7)
	var z := SpellVariants._zone(caster, t.global_position if t != null else pos + d * 80.0, tint)
	z.radius = PEN_RADIUS
	z.life = 5.0
	z.slow = 0.3
	z.pull = 40.0
	z.eat_shots = true
	z.damage = roundi(4.0 * k)
	SpellVariants._replace(caster.get_tree(), "pen", z)
	par.add_child(z)


## Putar Bandring: eight sling stones in a staggered spiral; each can Batu Pantul bounce.
static func _stones(caster: Node2D, par: Node, pos: Vector2, power: float) -> void:
	var kd := SpellData.for_glyph("sunda_ka")
	if kd == null or kd.scene == null:
		return
	var sd := SpellUtil.sub_data("sunda_ka", STONE_DAMAGE, 0.0, kd.scene)
	for i in 8:
		SpellVariants.later(caster, 0.04 * i, func() -> void:
			var s: Bolt = kd.scene.instantiate()
			s.mode = "stone"   # matches no special branch in bolt.gd: no spear, no homing, no flash
			s.caster = caster
			s.data = sd
			s.power = power
			s.reach = 140.0
			s.direction = Vector2.from_angle(TAU * i / 8.0)
			s.global_position = caster.global_position if is_instance_valid(caster) else pos
			par.add_child(s))


## Tembang Suling: a song that follows you, mending you and slowing foes.
static func _song(caster: Node2D, par: Node, pos: Vector2, tint: Color) -> void:
	var z := SpellVariants._zone(caster, pos, tint)
	z.follow = true
	z.radius = 70.0
	z.life = 6.0
	z.tick = 1.0
	z.slow = 0.5
	z.heal_self = SONG_HEAL
	par.add_child(z)


## Tunggang Kerbau: ride forward untouchable, trampling and shoving foes sideways.
static func _ride(caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float) -> void:
	if caster.get("health") != null:
		caster.health.set_invincible(0.45)
	var side := d.orthogonal()
	var hit := {}
	var dmg := roundi(RIDE_DAMAGE * k)
	for i in 6:
		SpellVariants.later(caster, 0.05 * i, func() -> void:
			var step := d * (RIDE_DIST / 6.0)
			if caster is CharacterBody2D:
				(caster as CharacterBody2D).move_and_collide(step)   # stops at walls
			else:
				caster.global_position += step
			for e in SpellUtil.enemies_near(caster.get_tree(), caster.global_position, 24.0):
				if hit.has(e.get_instance_id()):
					continue
				hit[e.get_instance_id()] = true
				SpellUtil.strike(e, dmg)
				var away := signf(side.dot(e.global_position - caster.global_position))
				_shove(e, side * (away if away != 0.0 else 1.0) * 32.0, 0.25)
				SpellFX.burst(par, "hit_burst", 5, e.global_position, tint, 0.9, 22.0))
	SpellFX.burst(par, "dash_slash", 4, pos + d * RIDE_DIST * 0.5, tint, 1.0, 20.0)


## Kerbau Sakti: a spirit buffalo that charges in a line toward the nearest foe, shoving and breaking poise.
static func _buffalo(spell: SpellData, caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, power: float) -> void:
	var z := SpellVariants._zone(caster, pos + d * 20.0, tint)
	z.radius = 16.0
	z.life = spell.duration if spell.duration > 0.0 else 8.0
	z.delay = 0.5
	z.tick = BUFFALO_EVERY
	z.on_tick = func(zz: SpellZone) -> void:
		var t := SpellUtil.nearest_enemy(zz.get_tree(), zz.global_position, 180.0)
		if t == null:
			zz.global_position = caster.global_position + d * 20.0
			return
		var cdir: Vector2 = (t.global_position - zz.global_position).normalized()
		var dist := minf(110.0, zz.global_position.distance_to(t.global_position) + 24.0)
		for step in 4:
			var pt := zz.global_position + cdir * (dist * (step + 1) / 4.0)
			SpellVariants.later(caster, 0.06 * step, func() -> void:
				if is_instance_valid(zz):
					zz.global_position = pt
				var fx_s := SpellFX.burst(par, "dash_slash", 4, pt, tint, 0.85, 22.0)
				if fx_s:
					fx_s.rotation = cdir.angle()
				if step == 3:
					SpellVariants.blast(caster, pt, "jawa_ra", spell.power * BUFFALO_MULT, 32.0, power, 2.0, 44.0))
	par.add_child(z)


## Banjir Sawah: the normal wave (with full power), then damaging mud behind it.
static func _flood(spell: SpellData, caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float, power: float) -> void:
	if spell.scene != null:
		var s: Node2D = spell.scene.instantiate()
		s.caster = caster
		s.data = spell
		s.direction = d
		s.power = power
		s.global_position = pos
		par.add_child(s)
	for i in 3:
		var at := pos + d * (50.0 + 60.0 * i)
		SpellVariants.later(caster, 0.15 * i, func() -> void:
			var z := SpellVariants._zone(caster, at, tint)
			z.radius = MUD_RADIUS
			z.life = 4.0
			z.tick = 0.7
			z.damage = roundi(6.0 * k)
			z.slow = 0.5
			par.add_child(z))


## Giring Kawanan: five lanes of spirit herd; each foe takes the big hit once and is carried along `d`.
static func _herd(caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float) -> void:
	var hit := {}
	var dmg := roundi(HERD_DAMAGE * k)
	for lane in HERD_LANES:
		var base := pos + d.orthogonal() * (lane - 2) * 26.0
		for j in HERD_STEPS:
			var pt := base + d * (-30.0 + 40.0 * j)
			SpellVariants.later(caster, 0.1 * j, func() -> void:
				var s := SpellFX.burst(par, "dash_slash", 4, pt, tint, 0.9, 22.0)
				if s:
					s.rotation = d.angle()
				for e in SpellUtil.enemies_near(caster.get_tree(), pt, 22.0):
					if hit.has(e.get_instance_id()):
						continue
					hit[e.get_instance_id()] = true
					SpellUtil.strike(e, dmg)
					_shove(e, d * 100.0, 0.5)
					SpellFX.burst(par, "hit_burst", 5, e.global_position, tint, 1.0, 22.0))
