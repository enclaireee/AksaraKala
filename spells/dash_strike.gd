extends Hitbox
## Jawa Na: the caster dashes through enemies, invincible (spells.md 3). Each class dashes differently:
## Hulubalang a short shoulder charge that staggers, Pamanah a long leap that ends in an arrow,
## Pendekar a far dash that makes foes bleed, Wiku a blink that ends in a blast.

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var perfect := false
var _t := 0.0
var _dist := 112.0
var _cls := ""
const TIME := 0.16       # TUNE
const DISTANCE := {"": 112.0, "warrior": 96.0, "archer": 140.0, "rogue": 128.0, "mage": 104.0}   # TUNE
const BLAST_POWER := 20.0
const BLAST_RADIUS := 44.0


func _ready() -> void:
	power *= SpellUtil.perfect_mult(perfect)
	_cls = SpellUtil.class_id(caster)
	_dist = DISTANCE.get(_cls, 112.0)
	damage = roundi(data.power * power * SpellUtil.damage(caster))
	source = caster
	poise_mult = preload("res://data/combat_tuning.tres").spell_poise_mult
	if _cls == "warrior":
		damage = roundi(damage * 1.25)
		knockback = 40.0
		poise_mult *= 2.0
	direction = direction.normalized()
	caster.health.set_invincible(TIME + (0.3 if _cls == "rogue" else 0.15))   # TUNE
	hit_landed.connect(_on_hit)
	super()
	activate()
	var tint := SpellUtil.tint(data.glyph_id, caster)
	var par := get_parent()
	var trail := SpellFX.burst(par, "dash_slash", 4, global_position + direction * _dist * 0.5, tint, 1.0, 20.0)
	if trail:
		trail.rotation = direction.angle()
		trail.scale = Vector2(_dist / 56.0, 1.0)
	SpellFX.burst(par, "hit_burst", 5, global_position, tint, 0.8, 20.0)


func _on_hit(hb: Hurtbox) -> void:
	if _cls == "rogue":
		SpellUtil.burn(hb.owner, damage)   # a bleed: 30% of the hit over 1.5 s
	SpellFX.burst(get_parent(), "hit_burst", 5, hb.global_position, SpellUtil.tint(data.glyph_id, caster), 0.9, 22.0)


func _physics_process(delta: float) -> void:
	var step := direction * _dist * minf(delta, TIME - _t) / TIME
	# ponytail: the player's own move_and_slide still runs this frame; no player dash state hook exists yet.
	if caster is CharacterBody2D:
		(caster as CharacterBody2D).move_and_collide(step)
	else:
		caster.global_position += step
	global_position = caster.global_position
	_t += delta
	if _t >= TIME:
		_finish()
		queue_free()


## Class endings: Pamanah's arrow, Wiku's blast.
func _finish() -> void:
	var par := get_parent()
	if par == null:
		return
	match _cls:
		"archer":
			var kd := SpellData.for_glyph("sunda_ka")
			if kd and kd.scene:
				var s: Bolt = kd.scene.instantiate()
				s._side = true
				s.caster = caster
				s.data = kd
				s.power = power * 0.7   # ASSUMED
				s.direction = direction
				s.global_position = caster.global_position
				par.add_child.call_deferred(s)
		"mage":
			var bs := SpellData.for_glyph("sunda_ca")
			if bs and bs.scene:
				var b: Node2D = bs.scene.instantiate()
				b.caster = caster
				b.data = SpellUtil.sub_data("jawa_na", BLAST_POWER, BLAST_RADIUS, bs.scene)
				b.flat = true
				b.power = power
				b.global_position = caster.global_position
				par.add_child.call_deferred(b)
