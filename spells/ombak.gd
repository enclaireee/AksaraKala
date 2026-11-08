class_name Ombak extends Arrow
## Jawa Ka: a wave in the aim direction that pierces, pushes enemies back and eats enemy shots (spells.md 3).
## Hulubalang's wave hits like a wall, Pamanah throws three, Pendekar's chills (slow), Wiku's rolls further
## and a second wave follows.

var caster: Node2D
var data: SpellData
var power := 1.0
var perfect := false
var _side := false   # a fan wave or echo: does not spawn more
var _tint := Color.WHITE
var _spr: SpellAnim
const EAT := 20.0   # px: an enemy shot this close to the wave is destroyed (TUNE)
const FAN := 0.3    # rad, about 17 degrees (ASSUMED)
const ECHO_DELAY := 0.35


func _ready() -> void:
	power *= SpellUtil.perfect_mult(perfect)
	damage = roundi(data.power * power * SpellUtil.damage(caster))
	source = caster
	speed = 190.0       # TUNE
	max_range = 190.0   # TUNE
	pierce = true
	knockback = 64.0    # px of push: enemy_base flinches at knockback / enemy_flinch for enemy_flinch s (spells.md 3)
	poise_mult = preload("res://data/combat_tuning.tres").spell_poise_mult * SpellUtil.poise_mult(data)
	_tint = SpellUtil.tint(data.glyph_id, caster)
	var size := 0.75 if _side else 1.0
	match SpellUtil.class_id(caster):
		"warrior":   # Hulubalang: a wall of water
			knockback = 90.0
			poise_mult *= 2.0
			size = 1.25
		"archer":    # Pamanah: three waves
			if not _side:
				for a in [-FAN, FAN]:
					_spawn_copy(power * 0.6, direction.rotated(a), 0.0)
		"rogue":     # Pendekar: the cold sea slows
			hit_landed.connect(func(hb: Hurtbox) -> void: SpellUtil.slow(hb.owner, 3.0, 0.5))
		"mage":      # Wiku: rolls further, a second wave follows
			max_range = 250.0
			if not _side:
				_spawn_copy(power * 0.7, direction, ECHO_DELAY)
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


## A fan wave or echo of this one. `delay` 0 spawns next frame.
func _spawn_copy(p: float, dir: Vector2, delay: float) -> void:
	var par := get_parent()
	var sc := data.scene
	var who := caster
	var d := data
	var pos := global_position
	var make := func() -> void:
		if not is_instance_valid(who) or not is_instance_valid(par) or not par.is_inside_tree():
			return
		var s: Ombak = sc.instantiate()
		s._side = true
		s.caster = who
		s.data = d
		s.power = p
		s.direction = dir
		s.global_position = pos if delay <= 0.0 else who.global_position
		par.add_child(s)
	if delay <= 0.0:
		make.call_deferred()
	else:
		get_tree().create_timer(delay).timeout.connect(make)


func _physics_process(delta: float) -> void:
	super(delta)
	# ponytail: enemy shots aren't monitorable, so scan siblings; fine for a handful of shots on screen.
	for a in get_parent().get_children():
		if a is Arrow and a != self and a.source != caster and not a is Ombak \
				and a.global_position.distance_to(global_position) < EAT:
			a.queue_free()
