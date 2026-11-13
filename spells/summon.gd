extends Hitbox
## Jawa Ra (spells.md 3). Base: a tiger spirit hunts the nearest enemy for 10 s, swiping every 0.55 s and
## pouncing for double damage. Each class calls a different spirit: Hulubalang's tiger guards him and mends
## him (Macan Penjaga), Pamanah calls two hawks that dive (Sepasang Elang), Pendekar two fast shadow tigers
## (Macan Bayangan), Wiku one huge fire tiger that scorches the ground and explodes at the end (Macan Api).

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var perfect := false
var twin := false          # the second hawk or shadow tiger: does not call a third
var _left := 0.0
var _tick := 0.0
var _base_damage := 0
var _leap_t := 0.0
var _leap_cd := 0.8
var _leap_dir := Vector2.RIGHT
var _leap_mult := 2.0
var _leap_cd_full := 2.2
var _leap_range := 80.0
var _speed := 120.0
var _period := 0.55
var _leash := 0.0          # >0: only fights enemies this close to the caster (the guardian)
var _facing := 1.0
var _cls := ""
var _hawk := false
var _fire_cd := 0.0
var _tint := Color.WHITE
var _look := Color.WHITE
var _run: SpellAnim
var _pounce: SpellAnim
const LEAP_SPEED := 320.0
const LEAP_TIME := 0.2
const FADE := 0.6
const FIRE_EVERY := 1.2


func _ready() -> void:
	power *= SpellUtil.perfect_mult(perfect)
	_cls = SpellUtil.class_id(caster)
	_tint = SpellUtil.tint(data.glyph_id, caster)
	var dmg_scale := 1.0
	var size := 1.0
	_left = data.duration
	match _cls:
		"warrior":
			_leash = 120.0
			_speed = 130.0
		"archer":
			_hawk = true
			_speed = 150.0
			_period = 0.5
			_leap_cd_full = 1.1
			_leap_cd = 0.4
			_leap_mult = 1.6
			_leap_range = 110.0
			dmg_scale = 0.55
			_look = Color(1, 1, 1)
		"rogue":
			_speed = 175.0
			_leap_cd_full = 1.4
			_leap_range = 100.0
			dmg_scale = 0.6
			_look = Color(0.6, 0.5, 0.85)
		"mage":
			size = 1.4
			_speed = 105.0
			_look = Color(1.0, 0.62, 0.35)
			_fire_cd = 0.4
	_base_damage = roundi(data.power * power * SpellUtil.damage(caster) * dmg_scale)
	damage = _base_damage
	source = caster
	poise_mult = preload("res://data/combat_tuning.tres").spell_poise_mult
	hit_landed.connect(_on_hit)
	super()
	activate()
	_run = SpellFX.make("hawk_fly" if _hawk else "tiger_run", 4, 12.0 if _hawk else 10.0)
	_pounce = null if _hawk else SpellFX.make("tiger_pounce", 3, 14.0)
	if _run and (_hawk or _pounce):
		_run.loop = true
		for s in [_run, _pounce]:
			if s:
				s.position = Vector2(0, -22 if _hawk else -10) * size
				s.scale = Vector2.ONE * size
				s.modulate = SpellFX.tint_for("hawk_fly", _look) if _hawk else _look
				s.self_modulate = Color(1, 1, 1, 0.92)
				add_child(s)
		if _pounce:
			_pounce.persist = true
			_pounce.visible = false
		var poly := get_node_or_null("Tiger")
		if poly:
			poly.visible = false
	SpellFX.burst(get_parent(), "hit_burst", 5, global_position, _tint, 1.2, 16.0)
	if (_cls == "archer" or _cls == "rogue") and not twin:
		var t: Node2D = data.scene.instantiate()
		t.caster = caster
		t.data = data
		t.power = power
		t.twin = true
		t.global_position = global_position + Vector2(0, 14)
		get_parent().add_child.call_deferred(t)


func _on_hit(hb: Hurtbox) -> void:
	SpellFX.burst(get_parent(), "hit_burst", 5, hb.global_position, _tint, 1.0, 22.0)
	if _cls == "warrior" and is_instance_valid(caster):
		caster.health.heal(maxi(1, roundi(caster.health.max_hp * 0.015)))   # each claw mends the summoner
	elif _cls == "mage":
		SpellUtil.burn(hb.owner, damage)


func _physics_process(delta: float) -> void:
	_left -= delta
	if _left <= 0.0:
		if _cls == "mage":
			SpellVariants.blast(caster, global_position, data.glyph_id, 36.0, 56.0, power, 1.5, 30.0)
		SpellFX.burst(get_parent(), "hit_burst", 5, global_position, _tint, 1.2, 16.0)
		queue_free()
		return
	_tick += delta
	if _tick >= _period:
		_tick = 0.0
		deactivate()   # off then on re-reports overlaps, so the next swipe can land again
		activate()
	var home: Vector2 = caster.global_position if is_instance_valid(caster) else global_position
	# ponytail: walks straight at the nearest enemy, no pathfinding; it follows the caster when none is near.
	var goal: Vector2 = home + (Vector2(24, 8) if _leash > 0.0 else Vector2.ZERO)
	var best := INF
	for e in get_tree().get_nodes_in_group("enemy"):
		if _leash > 0.0 and e.global_position.distance_to(home) > _leash:
			continue
		var d: float = e.global_position.distance_to(global_position)
		if d < best:
			best = d
			goal = e.global_position
	if _cls == "mage":
		_fire_cd -= delta
		if _fire_cd <= 0.0:
			_fire_cd = FIRE_EVERY
			_scorch()
	if _leap_t > 0.0:
		_leap_t -= delta
		global_position += _leap_dir * LEAP_SPEED * delta
		if _leap_t <= 0.0:
			damage = _base_damage
			_swap(false)
	else:
		_leap_cd -= delta
		if best < _leap_range and best > 24.0 and _leap_cd <= 0.0:
			_leap_dir = (goal - global_position).normalized()
			_leap_t = LEAP_TIME
			_leap_cd = _leap_cd_full
			damage = roundi(_base_damage * _leap_mult)
			deactivate()
			activate()
			_swap(true)
		else:
			var before := global_position
			global_position = global_position.move_toward(goal, _speed * delta)
			if absf(global_position.x - before.x) > 0.05:
				_facing = signf(global_position.x - before.x)
	if _leap_t > 0.0 and absf(_leap_dir.x) > 0.1:
		_facing = signf(_leap_dir.x)
	for s in [_run, _pounce]:
		if s:
			s.flip_h = _facing < 0.0
			s.self_modulate.a = 0.92 * minf(1.0, _left / FADE)


## Wiku's fire tiger leaves a patch of burning ground behind it.
func _scorch() -> void:
	var z := SpellZone.new()
	z.caster = caster
	z.tint = _tint
	z.global_position = global_position
	z.radius = 26.0
	z.life = 2.6
	z.tick = 0.5
	z.damage = roundi(8.0 * power * SpellUtil.damage(caster))
	get_parent().add_child.call_deferred(z)


func _swap(pounce: bool) -> void:
	if _run == null or _pounce == null:
		return
	_run.visible = not pounce
	_pounce.visible = pounce
	if pounce:
		_pounce.restart()
