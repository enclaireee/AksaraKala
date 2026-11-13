class_name SpellVariants extends RefCounted
## Class spells (spells.md 3). Each class draws the same aksara but casts a different spell. Ga is the only
## glyph that stays the same for everyone. The ones listed in HANDLED are built here from SpellZone, Bolt and
## Burst; the rest live in their own scene scripts and read the caster's class (Hulubalang's spear in bolt.gd,
## Heal, Dash-strike, Rally, Summon and Ombak). CastController asks `cast()` first and falls back to the scene.

const BURST := preload("res://spells/burst.tscn")

const NAMES := {
	"sunda_ka/warrior": "Tombak Petir", "sunda_ka/archer": "Hujan Panah", "sunda_ka/rogue": "Petir Berantai", "sunda_ka/mage": "Bola Petir",
	"sunda_nga/warrior": "Benteng Akar", "sunda_nga/archer": "Jerat Pemburu", "sunda_nga/rogue": "Tarik Bayangan", "sunda_nga/mage": "Sulur Pengisap",
	"sunda_ca/warrior": "Gempa Mengamuk", "sunda_ca/archer": "Suar Pemburu", "sunda_ca/rogue": "Putaran Silat", "sunda_ca/mage": "Lingkar Aksara",
	"jawa_ha/warrior": "Doa Penjaga", "jawa_ha/archer": "Angin Segar", "jawa_ha/rogue": "Napas Bayangan", "jawa_ha/mage": "Mata Air Batin",
	"jawa_na/warrior": "Terjang Banteng", "jawa_na/archer": "Lompat Mundur", "jawa_na/rogue": "Tebas Bayangan", "jawa_na/mage": "Langkah Kabut",
	"jawa_ca/warrior": "Seruan Perang", "jawa_ca/archer": "Fokus Pemburu", "jawa_ca/rogue": "Langkah Silat", "jawa_ca/mage": "Fokus Batin",
	"jawa_ra/warrior": "Macan Penjaga", "jawa_ra/archer": "Sepasang Elang", "jawa_ra/rogue": "Macan Bayangan", "jawa_ra/mage": "Macan Api",
	"sunda_ha/warrior": "Panji Hulubalang", "sunda_pa/archer": "Panah Sakti", "jawa_pa/rogue": "Seribu Bayangan", "jawa_wa/mage": "Gema Aksara",
	"jawa_ka/warrior": "Pasang Menghantam", "jawa_ka/archer": "Pasang Surut", "jawa_ka/rogue": "Arus Bawah", "jawa_ka/mage": "Banjir Aksara",
}
const HANDLED := [
	"sunda_ka/archer", "sunda_ka/rogue", "sunda_ka/mage",
	"sunda_nga/warrior", "sunda_nga/archer", "sunda_nga/rogue", "sunda_nga/mage",
	"sunda_ca/warrior", "sunda_ca/archer", "sunda_ca/rogue", "sunda_ca/mage",
	"jawa_ka/rogue",
	"sunda_ha/warrior", "sunda_pa/archer", "jawa_pa/rogue", "jawa_wa/mage",
]
## Signature aksara: glyph -> the only class that can learn it (classes.md).
const SIGNATURE := {"sunda_ha": "warrior", "sunda_pa": "archer", "jawa_pa": "rogue", "jawa_wa": "mage",
	"jawa_ga": "lancer", "sunda_ba": "herder", "sunda_ta": "dancer", "jawa_la": "dalang"}
const ECHO_DELAY := 0.6   # Gema Aksara, TUNE
const ECHO_POWER := 0.5


## The class spell's name for the result label ("" for Ga, for no class, or for an unknown pair).
static func title(glyph_id: String, cls: String) -> String:
	var kit = _kit(cls)
	if kit != null:
		return kit.NAMES.get(glyph_id, "")
	return NAMES.get("%s/%s" % [glyph_id, cls], "")


## True when this spell was built here, so the caller must not also spawn the scene.
static func cast(spell: SpellData, caster: Node2D, aim: Vector2, power: float, perfect: bool) -> bool:
	var key := "%s/%s" % [spell.glyph_id, SpellUtil.class_id(caster)]
	var par := caster.get_parent()
	var kit = _kit(SpellUtil.class_id(caster))
	if par == null or not (kit.NAMES.has(spell.glyph_id) if kit != null else HANDLED.has(key)):
		return false
	power *= SpellUtil.perfect_mult(perfect)
	var k := SpellUtil.damage(caster) * power
	var tint := SpellUtil.tint(spell.glyph_id, caster)
	var d := aim.normalized() if aim != Vector2.ZERO else Vector2.RIGHT
	var pos := caster.global_position
	if kit != null:
		kit.cast(spell, caster, par, d, pos, tint, k, power)
		return true
	match key:
		"sunda_ka/archer": _rain(spell, caster, par, d, pos, tint, k)
		"sunda_ka/rogue": _chain(spell, caster, par, d, pos, tint, k)
		"sunda_ka/mage": _orb(spell, caster, par, d, pos, tint, k, power)
		"sunda_nga/warrior": _thorn_ring(caster, par, pos, tint, k)
		"sunda_nga/archer": _trap(caster, par, d, pos, tint, k)
		"sunda_nga/rogue": _vacuum(caster, par, d, pos, tint, k)
		"sunda_nga/mage": _vines(caster, par, pos, tint, k)
		"sunda_ca/warrior": _fissure(caster, d, pos, power)
		"sunda_ca/archer": _flare(caster, par, d, pos, tint, power)
		"sunda_ca/rogue": _spin(caster, par, pos, tint, k)
		"sunda_ca/mage": _circle(caster, par, pos, tint, k)
		"jawa_ka/rogue": _vortex(spell, caster, par, d, pos, tint, k)
		"sunda_ha/warrior": _panji(spell, caster, par, pos, tint, power)
		"sunda_pa/archer": _sakti_arrow(spell, caster, par, d, pos, power)
		"jawa_pa/rogue": _bayangan(spell, caster, par, pos, tint, k)
		"jawa_wa/mage": _gema(spell, caster, par, pos, tint, power)
	return true


## The second paths have a whole kit of their own, one file each (classes.md "Second paths").
static func _kit(cls: String) -> GDScript:
	match cls:
		"lancer": return PathLancer
		"herder": return PathHerder
		"dancer": return PathDancer
		"dalang": return PathDalang
	return null


# ---- helpers ------------------------------------------------------------------------------------------

## Runs `f` after `seconds` unless the caster is gone by then.
static func later(who: Node, seconds: float, f: Callable) -> void:
	if who == null or not who.is_inside_tree():
		return
	who.get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if is_instance_valid(who):
			f.call())


## A Spirit-scaled explosion at `pos` (the Burst scene, flat). `base` is its damage before `power`.
static func blast(who: Node2D, pos: Vector2, glyph_id: String, base: float, radius: float, power: float, poise_scale := 1.0, knock := 18.0) -> void:
	if not is_instance_valid(who) or who.get_parent() == null:
		return
	var b: Node2D = BURST.instantiate()
	b.caster = who
	b.data = SpellUtil.sub_data(glyph_id, base, radius)
	b.flat = true
	b.power = power
	b.poise_scale = poise_scale
	b.knock = knock
	b.global_position = pos
	who.get_parent().add_child.call_deferred(b)


static func _zone(caster: Node2D, at: Vector2, tint: Color) -> SpellZone:
	var z := SpellZone.new()
	z.caster = caster
	z.tint = tint
	z.global_position = at
	return z


static func _replace(tree: SceneTree, group: String, z: Node) -> void:
	for old in tree.get_nodes_in_group(group):
		old.queue_free()   # one trap and one rune circle at a time
	z.add_to_group(group)


static func _zap(par: Node, a: Vector2, b: Vector2, tint: Color) -> void:
	var s := SpellFX.burst(par, "zap", 4, (a + b) * 0.5, tint.lightened(0.6), 1.0, 13.0)   # 0.3 s like the old fade
	if s == null:
		return
	s.top_level = true
	s.z_index = 9
	s.global_position = (a + b) * 0.5
	s.rotation = (b - a).angle()
	s.scale = Vector2(maxf(a.distance_to(b), 8.0) / 64.0, 1.0 if randf() < 0.5 else -1.0)


# ---- Ka: Sunda Bolt ---------------------------------------------------------------------------------------

## Pamanah: arrows fall on a zone for a second and a half.
static func _rain(spell: SpellData, caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float) -> void:
	var t := SpellUtil.nearest_enemy(caster.get_tree(), pos, 170.0, d, 0.7)
	var at: Vector2 = t.global_position if t != null else pos + d * 110.0
	var z := _zone(caster, at, tint)
	z.radius = 38.0
	z.delay = 0.3
	z.tick = 0.26
	z.life = 1.45
	z.damage = roundi(spell.power * 0.35 * k)
	z.on_tick = func(zz: SpellZone) -> void:
		for i in 4:
			var off := Vector2(randf_range(-1.0, 1.0), randf_range(-0.7, 0.7)) * zz.radius
			var s := SpellFX.burst(par, "bolt_fly", 4, zz.global_position + off + Vector2(0, -14), tint, 0.8, 24.0)
			if s:
				s.rotation = PI / 2.0
	par.add_child(z)


## Pendekar: lightning leaps through up to four foes, weaker each jump, and leaves them staggered.
static func _chain(spell: SpellData, caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float) -> void:
	var tree := caster.get_tree()
	var cur := SpellUtil.nearest_enemy(tree, pos, 160.0, d, 1.2)
	if cur == null:
		cur = SpellUtil.nearest_enemy(tree, pos, 100.0)
	var from := pos + Vector2(0, -6)
	var dmg := roundi(spell.power * 1.05 * k)
	var hit := []
	while cur != null and hit.size() < 4:
		hit.append(cur)
		SpellUtil.strike(cur, dmg)
		SpellUtil.burn(cur, dmg)
		SpellUtil.slow(cur, 0.8, 0.3)   # a stagger: the shock nearly stops it
		var to := cur.global_position + Vector2(0, -6)
		_zap(par, from, to, tint)
		SpellFX.burst(par, "hit_burst", 5, to, tint, 0.9, 22.0)
		from = to
		dmg = roundi(dmg * 0.85)
		cur = null
		var best := 95.0
		for e in tree.get_nodes_in_group("enemy"):
			if e is Node2D and not hit.has(e):
				var dd: float = (e as Node2D).global_position.distance_to(from)
				if dd < best:
					best = dd
					cur = e
	if hit.is_empty():
		_zap(par, from, from + d * 70.0, tint)   # nothing in reach: a crackle in the air


## Wiku: a storm orb drifts forward, tugging foes in and zapping them, and bursts at the end.
static func _orb(spell: SpellData, caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float, power: float) -> void:
	var z := _zone(caster, pos + d * 18.0, tint)
	z.radius = 26.0
	z.drift = d * 42.0
	z.life = 3.6
	z.tick = 0.32
	z.pull = 36.0
	z.damage = roundi(spell.power * 0.38 * k)
	z.on_end = func(zz: SpellZone) -> void:
		blast(caster, zz.global_position, spell.glyph_id, 22.0, 50.0, power)
	par.add_child(z)


# ---- Nga: Sunda Bind ----------------------------------------------------------------------------------------

## Hulubalang: a thorn wall follows you, slowing and cutting what touches it, and eats arrows and spit.
static func _thorn_ring(caster: Node2D, par: Node, pos: Vector2, tint: Color, k: float) -> void:
	var z := _zone(caster, pos, tint)
	z.follow = true
	z.radius = 58.0
	z.life = 6.5
	z.tick = 0.5
	z.damage = roundi(9.0 * k)
	z.slow = 0.5
	z.eat_shots = true
	par.add_child(z)


## Pamanah: a hidden snare. The next enemy to step in is rooted and hurt.
static func _trap(caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float) -> void:
	var z := _zone(caster, pos + d * 90.0, tint)
	z.trap = true
	z.radius = 30.0
	z.delay = 0.5
	z.life = 10.0
	z.damage = roundi(32.0 * k)
	z.root = 3.0
	_replace(caster.get_tree(), "trap", z)
	par.add_child(z)


## Pendekar: a vacuum yanks every foe to a point ahead, then roots them there.
static func _vacuum(caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float) -> void:
	var z := _zone(caster, pos + d * 34.0, tint)
	z.radius = 118.0
	z.delay = 0.42
	z.life = 0.5
	z.tick = 1.0
	z.pull = 330.0
	z.damage = roundi(14.0 * k)
	z.root = 1.4
	if caster.get("health") != null:
		caster.health.set_invincible(0.3)
	par.add_child(z)


## Wiku: vines hold everything in reach and drink their life for you.
static func _vines(caster: Node2D, par: Node, pos: Vector2, tint: Color, k: float) -> void:
	var z := _zone(caster, pos, tint)
	z.radius = 84.0
	z.life = 3.2
	z.tick = 0.5
	z.damage = roundi(8.0 * k)
	z.root = 3.0
	z.drain = 0.6
	par.add_child(z)


# ---- Ca: Sunda Burst ---------------------------------------------------------------------------------------

## Hulubalang: the ground splits forward in a line of eruptions.
static func _fissure(caster: Node2D, d: Vector2, pos: Vector2, power: float) -> void:
	for i in 5:
		var pt := pos + d * (30.0 + i * 30.0)
		later(caster, 0.08 * i, func() -> void:
			blast(caster, pt, "sunda_ca", 26.0, 32.0, power, 2.0, 46.0))


## Pamanah: a flare lands, bursts, and releases eight homing sparks.
static func _flare(caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, power: float) -> void:
	var t := SpellUtil.nearest_enemy(caster.get_tree(), pos, 200.0, d, 0.8)
	var at: Vector2 = t.global_position if t != null else pos + d * 120.0
	SpellFX.burst(par, "cast_sigil", 6, at, tint, 0.9, 12.0)
	later(caster, 0.4, func() -> void:
		blast(caster, at, "sunda_ca", 28.0, 54.0, power, 1.5, 24.0)
		var kd := SpellData.for_glyph("sunda_ka")
		if kd == null or kd.scene == null or not is_instance_valid(par):
			return
		for i in 8:
			var s: Bolt = kd.scene.instantiate()
			s.mode = "seek"
			s.caster = caster
			s.data = kd
			s.power = power * 0.4   # ASSUMED
			s.reach = 170.0
			s.direction = Vector2.from_angle(TAU * i / 8.0)
			s.global_position = at
			par.add_child(s))


## Pendekar: a silat spin, four quick slashes around you while you cannot be touched.
static func _spin(caster: Node2D, par: Node, pos: Vector2, tint: Color, k: float) -> void:
	var z := _zone(caster, pos, tint)
	z.follow = true
	z.radius = 52.0
	z.tick = 0.13
	z.life = 0.5
	z.damage = roundi(17.0 * k)
	z.show_ring = false
	z.on_tick = func(zz: SpellZone) -> void:
		var s := SpellFX.burst(par, "dash_slash", 4, zz.global_position + Vector2(0, -6), tint, 0.8, 24.0)
		if s:
			s.rotation = randf() * TAU
	if caster.get("health") != null:
		caster.health.set_invincible(0.55)
	par.add_child(z)


## Wiku: a rune circle stays where it is drawn, slowing and cutting foes and destroying shots that cross it.
static func _circle(caster: Node2D, par: Node, pos: Vector2, tint: Color, k: float) -> void:
	var z := _zone(caster, pos, tint)
	z.radius = 68.0
	z.life = 5.5
	z.tick = 0.5
	z.damage = roundi(11.0 * k)
	z.slow = 0.5
	z.eat_shots = true
	_replace(caster.get_tree(), "circle", z)
	par.add_child(z)


# ---- Ka: Ombak ---------------------------------------------------------------------------------------------

## Pendekar: an undertow drags foes toward a point, slowing them as it cuts.
static func _vortex(spell: SpellData, caster: Node2D, par: Node, d: Vector2, pos: Vector2, tint: Color, k: float) -> void:
	var z := _zone(caster, pos + d * 85.0, tint)
	z.radius = 52.0
	z.life = 2.8
	z.tick = 0.4
	z.pull = 85.0
	z.slow = 0.4
	z.damage = roundi(spell.power * 0.25 * k)
	par.add_child(z)


# ---- Signature aksara (classes.md) ------------------------------------------------------------------------

## Hulubalang, Sunda Ha: a war banner. Inside it you take 30% less, are not staggered, and melee hits shock.
static func _panji(spell: SpellData, caster: Node2D, par: Node, pos: Vector2, tint: Color, power: float) -> void:
	var z := _zone(caster, pos, tint)
	z.radius = spell.radius
	z.life = spell.duration
	z.tick = 0.2
	var inside := func() -> bool:
		return caster.global_position.distance_to(z.global_position) <= z.radius
	var g := SpellUtil._game()
	var set_buff := func(on: bool) -> void:
		caster.set_meta("panji", on)   # player._on_hurt reads it: no stagger
		if caster.get("health") != null:
			caster.health.reduction = (g.bonus("defense") if g else 0.0) + (0.3 if on else 0.0)   # TUNE
	z.on_tick = func(_z: SpellZone) -> void: set_buff.call(inside.call())
	var shock := func(hb: Hurtbox) -> void:
		if inside.call():
			blast(caster, hb.global_position, spell.glyph_id, spell.power, 40.0, power)
	var melee: Variant = caster.get("melee_hitbox")
	if melee != null:
		melee.hit_landed.connect(shock)
	z.tree_exiting.connect(func() -> void:
		if is_instance_valid(caster):
			set_buff.call(false)
			if melee != null and melee.hit_landed.is_connected(shock):
				melee.hit_landed.disconnect(shock))
	_replace(caster.get_tree(), "panji", z)
	par.add_child(z)
	set_buff.call(true)


## Pamanah, Sunda Pa: one charged arrow that goes through everything (bolt.gd mode "sakti").
static func _sakti_arrow(spell: SpellData, caster: Node2D, par: Node, d: Vector2, pos: Vector2, power: float) -> void:
	var kd := SpellData.for_glyph("sunda_ka")
	if kd == null or kd.scene == null:
		return
	var s: Bolt = kd.scene.instantiate()
	s.mode = "sakti"
	s.caster = caster
	s.data = spell
	s.power = power
	s.reach = 420.0
	s.direction = d
	s.global_position = pos
	par.add_child(s)


## Pendekar, Jawa Pa: a stab for each of up to five foes in reach, one after another, untouchable throughout.
static func _bayangan(spell: SpellData, caster: Node2D, par: Node, pos: Vector2, tint: Color, k: float) -> void:
	var foes := caster.get_tree().get_nodes_in_group("enemy").filter(func(e: Node) -> bool:
		return e is Node2D and (e as Node2D).global_position.distance_to(pos) <= spell.radius)
	foes.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		return a.global_position.distance_squared_to(pos) < b.global_position.distance_squared_to(pos))
	foes = foes.slice(0, 5)
	var dmg := roundi(spell.power * k)
	if caster.get("health") != null:
		caster.health.set_invincible(0.12 * foes.size() + 0.3)
	SpellFX.burst(par, "hit_burst", 5, pos, tint, 1.2, 20.0)
	for i in foes.size():
		var e: Node2D = foes[i]
		later(caster, 0.12 * i, func() -> void:
			if not is_instance_valid(e):
				return
			var to := (e.global_position - caster.global_position).normalized()
			caster.global_position = e.global_position + to * 22.0   # the far side of him, like Tebas Bayangan
			SpellUtil.strike(e, dmg)
			SpellUtil.burn(e, dmg)   # a bleed
			var cut := SpellFX.burst(par, "dash_slash", 4, e.global_position, tint, 1.0, 24.0)
			if cut:
				cut.rotation = to.angle())


## Wiku, Jawa Wa: for a while every other spell echoes once (CastController reads the meta).
static func _gema(spell: SpellData, caster: Node2D, par: Node, pos: Vector2, tint: Color, power: float) -> void:
	caster.set_meta("gema_until", Time.get_ticks_msec() + int(spell.duration * power * 1000.0))
	SpellFX.burst(par, "cast_sigil", 6, pos, tint, 1.4, 10.0)


## True while the caster's spells echo.
static func echoing(caster: Node) -> bool:
	return Time.get_ticks_msec() < int(caster.get_meta("gema_until", 0))
