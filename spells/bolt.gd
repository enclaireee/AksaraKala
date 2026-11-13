class_name Bolt extends Arrow
## Sunda Ka base spell: a bolt of light that burns what it hits and pierces one extra enemy (spells.md 3).
## Modes: "" the plain bolt, "spear" (Hulubalang: a thrown lightning spear that impales, roots and detonates),
## "seek" (homing sparks from Pamanah's flare). Other classes cast other spells (spells/spell_variants.gd).

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var power := 1.0     # damage multiplier (0.7 for a rough cast)
var perfect := false
var mode := ""
var reach := 220.0   # px of flight
var _hits_left := 2  # pierces one extra enemy, the second takes 75%
var _tint := Color.WHITE
var _spr: SpellAnim
const HOME_RANGE := 150.0
const HOME_TURN := 4.5   # rad per second
const SPEAR_FUSE := 0.6  # s from impale to detonation


func _ready() -> void:
	power *= SpellUtil.perfect_mult(perfect)
	damage = roundi(data.power * power * SpellUtil.damage(caster))
	source = caster
	speed = 260.0       # ASSUMED
	max_range = reach
	poise_mult = preload("res://data/combat_tuning.tres").spell_poise_mult
	_tint = SpellUtil.tint(data.glyph_id, caster)
	pierce = true       # Arrow frees a non-piercing shot on its first hit; _on_bolt_hit counts the hits instead
	if mode == "" and SpellUtil.class_id(caster) == "warrior":
		mode = "spear"
	var size := 1.0
	match mode:
		"spear":
			speed = 330.0
			max_range = 200.0
			damage = roundi(damage * 1.2)
			knockback = 14.0
			_hits_left = 1
			size = 1.4
		"seek":
			_hits_left = 1
			size = 0.7
		"sakti":   # Pamanah's Panah Sakti: through everything, Eagle Eye applies
			speed = 420.0
			_hits_left = 99
			size = 1.6
			if caster.get("tuning") != null:
				far_damage = roundi(damage * caster.tuning.eagle_mult)
				far_after = caster.tuning.eagle_range
	hit_landed.connect(_on_bolt_hit)
	super()
	_spr = SpellFX.make("bolt_fly", 4, 16.0)
	if _spr:
		_spr.loop = true
		_spr.modulate = SpellFX.tint_for("bolt_fly", _tint)
		_spr.scale = Vector2.ONE * size
		add_child(_spr)
		var d := get_node_or_null("Diamond")
		if d:
			d.visible = false
	if mode == "":
		SpellFX.burst(get_parent(), "hit_burst", 5, global_position, _tint, 0.6, 24.0)   # muzzle flash


func _on_bolt_hit(hb: Hurtbox) -> void:
	SpellFX.burst(get_parent(), "hit_burst", 5, global_position, _tint, 0.9, 20.0)
	if mode == "spear":
		_impale(hb.owner)
	else:
		SpellUtil.burn(hb.owner, damage)   # burn_share of the hit, as ticks
		if _hits_left > 1 and mode != "sakti":
			damage = roundi(damage * 0.75)   # the next foe takes less
	_hits_left -= 1
	if _hits_left <= 0:
		_spent = true
		queue_free()


## Hulubalang: the spear pins its target for the fuse, then detonates there.
func _impale(e: Node) -> void:
	if e == null or not e is Node2D:
		return
	if e.get("status") != null:
		var tuning: CombatTuning = e.status.tuning
		if e.is_in_group("boss"):
			e.status.apply(Status.Type.SLOW, SPEAR_FUSE + 1.0, tuning.bind_slow_mult)
		else:
			e.status.apply(Status.Type.BOUND, SPEAR_FUSE + 0.3)
	var pos: Vector2 = (e as Node2D).global_position
	var who := caster
	var p := power
	var par := get_parent()
	SpellFX.burst(par, "cast_sigil", 6, pos, _tint, 0.5, 8.0)
	SpellVariants.later(who, SPEAR_FUSE, func() -> void:
		SpellVariants.blast(who, pos, "sunda_ka", 26.0, 46.0, p, 2.0, 30.0))


func _physics_process(delta: float) -> void:
	if mode == "seek":
		var t := SpellUtil.nearest_enemy(get_tree(), global_position, HOME_RANGE, direction, 1.2)
		if t != null:
			var want := (t.global_position + Vector2(0, -6) - global_position).angle()
			direction = Vector2.from_angle(rotate_toward(direction.angle(), want, HOME_TURN * delta))
			rotation = direction.angle()
	super(delta)
