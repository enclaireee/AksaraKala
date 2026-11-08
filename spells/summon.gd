extends Hitbox
## Jawa Ra: a tiger spirit hunts the nearest enemy for 10 s, swiping every 0.55 s and pouncing for double
## damage every couple of seconds (spells.md 3). Hulubalang's tiger heals its summoner, Pamanah's pounces from
## afar and runs faster, Pendekar calls a twin, Wiku's lasts longer and its claws burn.

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var perfect := false
var twin := false          # Pendekar's second tiger: does not call a third
var _left := 0.0
var _tick := 0.0
var _base_damage := 0
var _leap_t := 0.0
var _leap_cd := 0.8
var _leap_dir := Vector2.RIGHT
var _speed := SPEED
var _leap_range := 80.0
var _facing := 1.0
var _cls := ""
var _tint := Color.WHITE
var _run: SpellAnim
var _pounce: SpellAnim
const SPEED := 120.0      # TUNE
const PERIOD := 0.55
const LEAP_SPEED := 320.0
const LEAP_TIME := 0.2
const LEAP_COOLDOWN := 2.2
const LEAP_MULT := 2.0
const FADE := 0.6


func _ready() -> void:
	power *= SpellUtil.perfect_mult(perfect)
	_cls = SpellUtil.class_id(caster)
	_base_damage = roundi(data.power * power * SpellUtil.damage(caster) * (0.6 if twin else 1.0))
	damage = _base_damage
	source = caster
	poise_mult = preload("res://data/combat_tuning.tres").spell_poise_mult
	_left = data.duration * (1.4 if _cls == "mage" else 1.0)
	match _cls:
		"archer":
			_speed = SPEED * 1.3
			_leap_range = 120.0
	_tint = SpellUtil.tint(data.glyph_id, caster)
	hit_landed.connect(_on_hit)
	super()
	activate()
	_run = SpellFX.make("tiger_run", 4, 10.0)
	_pounce = SpellFX.make("tiger_pounce", 3, 14.0)
	if _run and _pounce:
		_run.loop = true
		_pounce.persist = true
		_pounce.visible = false
		for s in [_run, _pounce]:
			s.position = Vector2(0, -10)
			s.self_modulate = Color(1, 1, 1, 0.92)
			add_child(s)
		var poly := get_node_or_null("Tiger")
		if poly:
			poly.visible = false
	SpellFX.burst(get_parent(), "hit_burst", 5, global_position, _tint, 1.2, 16.0)
	if _cls == "rogue" and not twin:
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
		caster.health.heal(maxi(1, roundi(caster.health.max_hp * 0.015)))   # Hulubalang: each claw mends the summoner
	elif _cls == "mage":
		SpellUtil.burn(hb.owner, damage)


func _physics_process(delta: float) -> void:
	_left -= delta
	if _left <= 0.0:
		SpellFX.burst(get_parent(), "hit_burst", 5, global_position, _tint, 1.2, 16.0)
		queue_free()
		return
	_tick += delta
	if _tick >= PERIOD:
		_tick = 0.0
		deactivate()   # off then on re-reports overlaps, so the next swipe can land again
		activate()
	# ponytail: walks straight at the nearest enemy, no pathfinding; it follows the caster when none is near.
	var goal: Vector2 = caster.global_position if is_instance_valid(caster) else global_position
	var best := INF
	for e in get_tree().get_nodes_in_group("enemy"):
		var d: float = e.global_position.distance_to(global_position)
		if d < best:
			best = d
			goal = e.global_position
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
			_leap_cd = LEAP_COOLDOWN
			damage = roundi(_base_damage * LEAP_MULT)
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


func _swap(pounce: bool) -> void:
	if _run == null or _pounce == null:
		return
	_run.visible = not pounce
	_pounce.visible = pounce
	if pounce:
		_pounce.restart()
