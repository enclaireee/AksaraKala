class_name PathLancer extends RefCounted
## The Prajurit's own spell kit (spells.md 3 "Second paths", classes.md). SpellVariants.cast() routes here.

const NAMES := {
	"sunda_ka": "Lembing Kilat",
	"sunda_nga": "Pagar Tombak",
	"sunda_ca": "Sapuan Galah",
	"jawa_ha": "Sumpah Prajurit",
	"jawa_na": "Terjang Tombak",
	"jawa_ca": "Gelar Perang",
	"jawa_ra": "Barisan Bayangan",
	"jawa_ka": "Ombak Baris",
	"jawa_ga": "Supit Urang",
}


const JAVELIN_REACH := 240.0     # TUNE px
const JAVELIN_WIDTH := 12.0      # TUNE half-width of the line
const CHARGE_DIST := 140.0       # TUNE px
const CHARGE_TIME := 0.2         # TUNE s
const CHARGE_STEPS := 8
const LANCE_SPEED := 300.0       # TUNE px/s (about twice Ombak)
const LANCE_LIFE := 1.2          # TUNE s


## `d` is the unit aim direction, `pos` the caster's position, `k` = Spirit x school x power (multiply base damage by it).
static func cast(spell: SpellData, caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float, power: float) -> void:
	var id := spell.glyph_id
	var n := d.orthogonal()
	match id:
		"sunda_ka":   # an instant line hit; ponytail: no flying projectile, so no travel time
			for e in caster.get_tree().get_nodes_in_group("enemy"):
				if e is Node2D:
					var rel: Vector2 = (e as Node2D).global_position - pos
					var along := rel.dot(d)
					if along >= 0.0 and along <= JAVELIN_REACH and absf(rel.dot(n)) <= JAVELIN_WIDTH:
						SpellUtil.strike(e, roundi(28.0 * k))
						SpellFX.burst(par, "hit_burst", 5, e.global_position, tint, 0.9, 22.0)
			var cut := SpellFX.burst(par, "dash_slash", 4, pos + d * JAVELIN_REACH * 0.5, tint, 1.0, 20.0)
			if cut:
				cut.rotation = d.angle()
				cut.scale = Vector2(JAVELIN_REACH / 56.0, 0.6)
		"sunda_nga":
			var first := true
			for i in [-1, 0, 1]:
				var z := SpellVariants._zone(caster, pos + d * 34.0 + n * (26.0 * i), tint)
				z.radius = 18.0
				z.life = 7.0
				z.tick = 0.5
				z.damage = roundi(8.0 * k)
				z.slow = 0.4
				z.eat_shots = true
				if first:
					SpellVariants._replace(caster.get_tree(), "pagar", z)
					first = false
				else:
					z.add_to_group("pagar")
				par.add_child(z)
		"sunda_ca":
			SpellVariants.blast(caster, pos + d * 36.0, id, 40.0, 60.0, power, 1.0, 40.0)
		"jawa_ha":
			if caster.get("health") != null:
				caster.health.heal(maxi(1, roundi(caster.health.max_hp * 0.15 * power)))
			_buff(caster, "sumpah", 8.0)
			SpellFX.burst(par, "cast_sigil", 6, pos, tint, 1.0, 12.0)
		"jawa_na":
			_charge(caster, par, d, pos, tint, k)
		"jawa_ca":
			_buff(caster, "gelar", 12.0)
			SpellFX.burst(par, "cast_sigil", 6, pos, tint, 1.4, 12.0)
		"jawa_ra":   # ponytail: the zone ring is the only marker
			for side in [-1, 1]:
				var z := SpellVariants._zone(caster, pos + n * (22.0 * side), tint)
				z.radius = 50.0
				z.life = 10.0
				z.tick = 0.6
				z.damage = roundi(16.0 * k)
				if side == -1:
					SpellVariants._replace(caster.get_tree(), "barisan", z)
				else:
					z.add_to_group("barisan")
				par.add_child(z)
		"jawa_ka":   # a narrow drifting zone that strikes each foe once, no shove
			var z := SpellVariants._zone(caster, pos + d * 14.0, tint)
			z.radius = 12.0
			z.life = LANCE_LIFE
			z.tick = 0.05
			z.drift = d * LANCE_SPEED
			z.show_ring = false
			var hit := {}
			z.on_tick = func(zz: SpellZone) -> void:
				for e in SpellUtil.enemies_near(zz.get_tree(), zz.global_position, zz.radius):
					if not hit.has(e.get_instance_id()):
						hit[e.get_instance_id()] = true
						SpellUtil.strike(e, roundi(50.0 * k))
				var s := SpellFX.burst(par, "dash_slash", 4, zz.global_position, tint, 0.8, 20.0)
				if s:
					s.rotation = d.angle()
			par.add_child(z)
		"jawa_ga":
			var at := pos + d * 90.0
			for i in 4:
				var off := 80.0 - i * 20.0   # ponytail: even steps, the last pair stops 20 px from the point
				SpellVariants.later(caster, 0.5 * i / 3.0, func() -> void:
					for side in [-1.0, 1.0]:
						SpellVariants.blast(caster, at + n * (off * side), id, 20.0, 30.0, power))
			SpellVariants.later(caster, 0.55, func() -> void:
				var z := SpellVariants._zone(caster, at, tint)
				z.radius = 50.0
				z.life = 0.6
				z.root = 2.0
				par.add_child(z))


static func _buff(caster: Node2D, id: String, seconds: float) -> void:
	if caster.has_method("buff"):
		caster.buff(id, seconds)


## Terjang Tombak: step the caster forward in slices, striking each foe once; the last one is pinned.
static func _charge(caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float) -> void:
	if caster.get("health") != null:
		caster.health.set_invincible(CHARGE_TIME + 0.15)
	var hit := {}
	var last: Array = [null]
	SpellFX.burst(par, "hit_burst", 5, pos, tint, 0.8, 20.0)
	for i in CHARGE_STEPS:
		SpellVariants.later(caster, CHARGE_TIME * i / CHARGE_STEPS, func() -> void:
			var step := d * (CHARGE_DIST / CHARGE_STEPS)
			if caster is CharacterBody2D:
				(caster as CharacterBody2D).move_and_collide(step)   # stops at walls
			else:
				caster.global_position += step
			for e in SpellUtil.enemies_near(caster.get_tree(), caster.global_position, 18.0):
				if not hit.has(e.get_instance_id()):
					hit[e.get_instance_id()] = true
					last[0] = e
					SpellUtil.strike(e, roundi(30.0 * k))
					SpellFX.burst(par, "hit_burst", 5, e.global_position, tint, 0.9, 22.0))
	SpellVariants.later(caster, CHARGE_TIME + 0.02, func() -> void:
		var e: Node = last[0]
		if is_instance_valid(e) and e.get("status") != null:
			var tuning: CombatTuning = e.status.tuning
			if e.is_in_group("boss"):
				e.status.apply(Status.Type.SLOW, tuning.bind_slow_time, tuning.bind_slow_mult)   # bosses are never rooted
			else:
				e.status.apply(Status.Type.BOUND, 1.2))
