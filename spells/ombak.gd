class_name Ombak extends Arrow
## Jawa Ka (spells.md 3). Base: a wave that pierces, pushes enemies back 64 px and eats enemy shots.
## Hulubalang's is a slow wall that carries enemies along and crashes at the end (Pasang Menghantam),
## Pamanah's goes out and comes back (Pasang Surut), Wiku's rolls out in every direction (Banjir Aksara).
## Pendekar's is an undertow built in spell_variants.gd (Arus Bawah).

var caster: Node2D
var data: SpellData
var power := 1.0
var perfect := false
var _side := false   # one of the flood's other waves: does not spawn more
var _cls := ""
var _tint := Color.WHITE
var _ebb := false    # Pamanah's wave is on its way back
var _spr: SpellAnim
const EAT := 20.0    # px: an enemy shot this close to the wave is destroyed (TUNE)
const CARRY := 26.0  # px ahead of the wall that Hulubalang's wave carries
const FLOOD := 5     # extra waves in Wiku's ring


func _ready() -> void:
	power *= SpellUtil.perfect_mult(perfect)
	_cls = SpellUtil.class_id(caster)
	damage = roundi(data.power * power * SpellUtil.damage(caster))
	source = caster
	speed = 190.0       # TUNE
	max_range = 190.0   # TUNE
	pierce = true
	knockback = 64.0    # px of push: enemy_base flinches at knockback / enemy_flinch for enemy_flinch s (spells.md 3)
	poise_mult = preload("res://data/combat_tuning.tres").spell_poise_mult * SpellUtil.poise_mult(data)
	_tint = SpellUtil.tint(data.glyph_id, caster)
	var size := 0.75 if _side else 1.0
	match _cls:
		"warrior":   # a slow wall of water that shoves everything ahead of it
			speed = 120.0
			max_range = 150.0
			knockback = 20.0
			poise_mult *= 2.0
			size = 1.7
		"archer":    # out and back: it hits again on the return
			max_range = 100000.0
		"mage":      # a ring of waves
			if not _side:
				for i in FLOOD:
					_spawn_wave(direction.rotated(TAU * (i + 1) / (FLOOD + 1.0)))
	hit_landed.connect(func(_hb: Hurtbox) -> void: SpellFX.burst(get_parent(), "hit_burst", 5, global_position, _tint, 1.0, 20.0))
	super()
	_spr = SpellFX.make("ombak_wave", 5, 12.0)
	if _spr:
		_spr.loop = true
		_spr.modulate = _tint
		_spr.scale = Vector2.ONE * size
		add_child(_spr)
		var c := get_node_or_null("Crest")
		if c:
			c.visible = false


## One more wave of Wiku's flood, at 60% strength.
func _spawn_wave(dir: Vector2) -> void:
	var s: Ombak = data.scene.instantiate()
	s._side = true
	s.caster = caster
	s.data = data
	s.power = power * 0.6
	s.direction = dir
	s.global_position = global_position
	get_parent().add_child.call_deferred(s)


func _physics_process(delta: float) -> void:
	if _cls == "archer":
		if not _ebb and _travelled >= 130.0:
			_ebb = true
			_hit.clear()   # it may hit everything again on the way back
			damage = roundi(damage * 0.8)
		if _ebb and is_instance_valid(caster):
			var back: Vector2 = caster.global_position - global_position
			if back.length() < 14.0 or _travelled > 420.0:
				queue_free()
				return
			direction = back.normalized()
			rotation = direction.angle()
	elif _cls == "warrior":
		for e in SpellUtil.enemies_near(get_tree(), global_position + direction * CARRY * 0.6, CARRY):
			if not e.is_in_group("boss"):
				e.global_position += direction * speed * delta   # carried along
		if _travelled + speed * delta >= max_range:
			SpellVariants.blast(caster, global_position, data.glyph_id, 32.0, 56.0, power, 2.0, 50.0)   # the crash
	super(delta)
	# ponytail: enemy shots aren't monitorable, so scan siblings; fine for a handful of shots on screen.
	for a in get_parent().get_children():
		if a is Arrow and a != self and a.source != caster and not a is Ombak \
				and a.global_position.distance_to(global_position) < EAT:
			a.queue_free()
