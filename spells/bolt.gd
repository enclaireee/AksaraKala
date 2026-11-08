class_name Bolt extends Arrow
## Sunda Ka: a bolt of light that burns what it hits (spells.md 3). Reuses Arrow flight and wall check.
## Every class bends it: Hulubalang a slow heavy bolt, Pamanah a piercing fan, Pendekar a twin strike, Wiku a seeker.

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var power := 1.0     # damage multiplier (0.7 for a rough cast)
var perfect := false
var reach := 220.0   # px of flight; Pamanah's Burst shards fly shorter
var _side := false   # a fan arrow, echo or shard: does not spawn more
var _hits_left := 2  # pierces one extra enemy, the second takes 75%
var _homing := false
var _tint := Color.WHITE
var _spr: SpellAnim
const FAN := 0.26    # rad, about 15 degrees (ASSUMED)
const ECHO_DELAY := 0.14
const HOME_RANGE := 150.0
const HOME_TURN := 4.5   # rad per second


func _ready() -> void:
	power *= SpellUtil.perfect_mult(perfect)
	damage = roundi(data.power * power * SpellUtil.damage(caster))
	source = caster
	speed = 260.0       # ASSUMED
	max_range = reach
	poise_mult = preload("res://data/combat_tuning.tres").spell_poise_mult
	_tint = SpellUtil.tint(data.glyph_id, caster)
	pierce = true       # Arrow frees a non-piercing shot on its first hit; _on_bolt_hit counts the hits instead
	var cls := SpellUtil.class_id(caster)
	var size := 0.8 if _side else 1.0
	match cls:
		"warrior":   # Hulubalang: a slow, heavy bolt that staggers
			damage = roundi(damage * 1.35)
			speed = 200.0
			knockback = 18.0
			poise_mult *= 1.6
			_hits_left = 1
			size = 1.3
		"archer":    # Pamanah: pierces everything, fans into three arrows
			_hits_left = 99
			if not _side:
				_fan()
		"rogue":     # Pendekar: a second bolt follows right behind
			if not _side:
				_echo()
		"mage":      # Wiku: the bolt curves toward the nearest foe ahead
			_homing = true
	hit_landed.connect(_on_bolt_hit)
	super()
	_spr = SpellFX.make("bolt_fly", 4, 16.0)
	if _spr:
		_spr.loop = true
		_spr.modulate = _tint
		_spr.scale = Vector2.ONE * size
		add_child(_spr)
		var d := get_node_or_null("Diamond")
		if d:
			d.visible = false
	if not _side:
		SpellFX.burst(get_parent(), "hit_burst", 5, global_position, _tint, 0.6, 24.0)   # muzzle flash


func _fan() -> void:
	for a in [-FAN, FAN]:
		var s: Bolt = data.scene.instantiate()
		s._side = true
		s.caster = caster
		s.data = data
		s.power = power * 0.6   # ASSUMED: side arrows deal 60%
		s.direction = direction.rotated(a)
		s.global_position = global_position
		get_parent().add_child.call_deferred(s)


func _echo() -> void:
	var par := get_parent()
	var dir := direction
	var sc := data.scene
	var who := caster
	var d := data
	var p := power * 0.8   # ASSUMED
	get_tree().create_timer(ECHO_DELAY).timeout.connect(func() -> void:
		if not is_instance_valid(who) or not is_instance_valid(par) or not par.is_inside_tree():
			return
		var s: Bolt = sc.instantiate()
		s._side = true
		s.caster = who
		s.data = d
		s.power = p
		s.direction = dir
		s.global_position = who.global_position
		par.add_child(s))


func _on_bolt_hit(hb: Hurtbox) -> void:
	SpellUtil.burn(hb.owner, damage)   # burn_share of the hit, as ticks
	SpellFX.burst(get_parent(), "hit_burst", 5, global_position, _tint, 0.9, 20.0)
	_hits_left -= 1
	if _hits_left < 50:
		damage = roundi(damage * 0.75)   # the next foe takes less (Pamanah's pierce is full strength)
	if _hits_left <= 0:
		_spent = true
		queue_free()


func _physics_process(delta: float) -> void:
	if _homing:
		var t := SpellUtil.nearest_enemy(get_tree(), global_position, HOME_RANGE, direction, 1.0)
		if t != null:
			var want := (t.global_position + Vector2(0, -6) - global_position).angle()
			direction = Vector2.from_angle(rotate_toward(direction.angle(), want, HOME_TURN * delta))
			rotation = direction.angle()
	super(delta)
