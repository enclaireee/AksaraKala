extends Hitbox
## Sunda Ca: a shockwave around the caster that hits everything in radius once and shoves it back (spells.md 3).
## Hulubalang: wider, harder, staggers. Pamanah: also looses eight piercing shards. Pendekar: slows what it
## hits and slips away in the smoke. Wiku: a second, smaller detonation follows.
## `flat` (the Ward's break pulse) skips class changes; `echo` marks Wiku's second blast.

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var perfect := false
var flat := false
var echo := false
var _t := 0.0
var _radius := 0.0
var _off := false
var _echo_due := false
var _life := 0.3
const LIFE := 0.3          # ASSUMED: the hit window
const ECHO_AT := 0.45
const SHARDS := 8
const SHARD_REACH := 110.0   # TUNE


func _ready() -> void:
	power *= SpellUtil.perfect_mult(perfect)
	var cls := "" if flat else SpellUtil.class_id(caster)
	var dmg_mult := SpellUtil.spirit(caster) if flat else SpellUtil.damage(caster)
	damage = roundi(data.power * power * dmg_mult)
	source = caster
	poise_mult = preload("res://data/combat_tuning.tres").spell_poise_mult * (2.0 if cls == "warrior" else 1.0)
	knockback = 30.0 if cls == "warrior" else 18.0   # px of push (Hitbox default is 6)
	_radius = data.radius * (1.25 if cls == "warrior" else 1.0) * (1.15 if echo else 1.0) * SpellUtil.radius_mult(data)   # Hulubalang +25%, Tell Ciung +10%
	var cs := CircleShape2D.new()   # own shape: the scene's is shared between instances
	cs.radius = _radius
	$Shape.shape = cs
	super()
	activate()
	_echo_due = cls == "mage" and not echo
	_life = ECHO_AT + 0.1 if _echo_due else LIFE
	var tint := SpellUtil.tint(data.glyph_id, caster)
	var wave := SpellFX.make("shock", 6, 6.0 / LIFE)
	if wave:
		wave.modulate = Color(tint, 0.95)
		wave.scale = Vector2.ONE * _radius / 60.0
		add_child(wave)
	match cls:
		"archer":
			_shards()
		"rogue":
			for e in SpellUtil.enemies_near(get_tree(), global_position, _radius):
				SpellUtil.slow(e, 3.0, 0.5)
			if caster.get("health") != null:
				caster.health.set_invincible(0.6)


## Pamanah: eight shards fly out, each a weak piercing bolt.
func _shards() -> void:
	var kd := SpellData.for_glyph("sunda_ka")
	if kd == null or kd.scene == null:
		return
	for i in SHARDS:
		var s: Bolt = kd.scene.instantiate()
		s._side = true
		s.caster = caster
		s.data = kd
		s.power = power * 0.45   # ASSUMED
		s.reach = SHARD_REACH
		s.direction = Vector2.from_angle(TAU * i / SHARDS + PI / SHARDS)
		s.global_position = global_position
		get_parent().add_child.call_deferred(s)


func _physics_process(delta: float) -> void:
	_t += delta
	if not _off and _t >= LIFE:
		_off = true
		deactivate()
	if _echo_due and _t >= ECHO_AT:
		_echo_due = false
		var b: Node2D = data.scene.instantiate()
		b.caster = caster
		b.data = data
		b.power = power * 0.7   # ASSUMED
		b.echo = true
		b.global_position = global_position
		get_parent().add_child(b)
	if _t >= _life:
		queue_free()
