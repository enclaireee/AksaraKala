extends Hitbox
## Jawa Na (spells.md 3). Base: dash 112 px through enemies, invincible. Each class moves differently:
## Hulubalang charges like a bull and slams where he stops (Terjang Banteng), Pamanah leaps backward while
## loosing a volley (Lompat Mundur), Pendekar teleports behind the nearest foe and stabs (Tebas Bayangan),
## Wiku blinks and leaves a delayed blast where he stood (Langkah Kabut).

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var perfect := false
var _t := 0.0
var _dist := 112.0
var _life := 0.16
var _cls := ""
var _moves := true
const TIME := 0.16       # TUNE
const STAB_LIFE := 0.25  # s the Pendekar's stab stays live after the teleport
const DISTANCE := {"": 112.0, "warrior": 124.0, "archer": 112.0}   # TUNE


func _ready() -> void:
	power *= SpellUtil.perfect_mult(perfect)
	_cls = SpellUtil.class_id(caster)
	_dist = DISTANCE.get(_cls, 112.0)
	damage = roundi(data.power * power * SpellUtil.damage(caster))
	source = caster
	poise_mult = preload("res://data/combat_tuning.tres").spell_poise_mult
	direction = direction.normalized()
	var tint := SpellUtil.tint(data.glyph_id, caster)
	var par := get_parent()
	var start := caster.global_position
	var live := true
	match _cls:
		"warrior":
			damage = roundi(damage * 1.15)
			knockback = 50.0
			poise_mult *= 2.0
		"archer":   # leap away from where the arrow flies, loosing three arrows that way
			live = false
			var aim := direction
			direction = -direction
			_fan(par, aim, start)
		"rogue":    # teleport behind the nearest foe
			_moves = false
			_life = STAB_LIFE
			damage = roundi(damage * 1.6)
			var foe := SpellUtil.nearest_enemy(get_tree(), start, 170.0)
			var to := direction
			if foe != null:
				to = (foe.global_position - start).normalized()
				caster.global_position = foe.global_position + to * 22.0   # the far side of him
			else:
				caster.global_position = start + direction * 100.0
			direction = to
			SpellFX.burst(par, "hit_burst", 5, start, tint, 1.2, 20.0)
			var cut := SpellFX.burst(par, "dash_slash", 4, caster.global_position, tint, 1.0, 24.0)
			if cut:
				cut.rotation = to.angle()
		"mage":     # blink ahead, leaving a rune that blows after half a second
			live = false
			_moves = false
			_life = 0.25
			var before := caster.global_position
			if caster is CharacterBody2D:
				(caster as CharacterBody2D).move_and_collide(direction * 120.0)
			else:
				caster.global_position += direction * 120.0
			SpellFX.burst(par, "cast_sigil", 6, before, tint, 1.0, 12.0)
			var p := power
			var who := caster
			SpellVariants.later(who, 0.5, func() -> void:
				SpellVariants.blast(who, before, "jawa_na", 30.0, 54.0, p, 1.5, 30.0))
	caster.health.set_invincible(_life + (0.3 if _cls == "rogue" else 0.15))   # TUNE
	hit_landed.connect(_on_hit)
	super()
	var streak := get_node_or_null("Streak") as Sprite2D   # the speed flare: class art, facing the dash
	if streak:
		var st := SpellFX.tex("dash_streak")
		if st:
			streak.texture = st
		streak.rotation = direction.angle()
	if live:
		activate()
	if _moves:
		var trail := SpellFX.burst(par, "dash_slash", 4, start + direction * _dist * 0.5, tint, 1.0, 20.0)
		if trail:
			trail.rotation = direction.angle()
			trail.scale = Vector2(_dist / 56.0, 1.0)
	SpellFX.burst(par, "hit_burst", 5, start, tint, 0.8, 20.0)


## Pamanah: centre arrow at full strength, two at 70%.
func _fan(par: Node, aim: Vector2, at: Vector2) -> void:
	var kd := SpellData.for_glyph("sunda_ka")
	if kd == null or kd.scene == null:
		return
	for a in [-0.26, 0.0, 0.26]:
		var s: Bolt = kd.scene.instantiate()
		s.caster = caster
		s.data = kd
		s.power = power * (1.0 if a == 0.0 else 0.7)
		s.direction = aim.rotated(a)
		s.global_position = at
		par.add_child.call_deferred(s)


func _on_hit(hb: Hurtbox) -> void:
	if _cls == "rogue":
		SpellUtil.burn(hb.owner, damage)   # a bleed
	SpellFX.burst(get_parent(), "hit_burst", 5, hb.global_position, SpellUtil.tint(data.glyph_id, caster), 0.9, 22.0)


func _physics_process(delta: float) -> void:
	if _moves:
		var step := direction * _dist * minf(delta, TIME - _t) / TIME
		# ponytail: the player's own move_and_slide still runs this frame; no player dash state hook exists yet.
		if caster is CharacterBody2D:
			(caster as CharacterBody2D).move_and_collide(step)
		else:
			caster.global_position += step
	global_position = caster.global_position
	_t += delta
	if _t >= (TIME if _moves else _life):
		_finish()
		queue_free()


## Hulubalang's charge ends in a slam.
func _finish() -> void:
	if _cls == "warrior":
		SpellVariants.blast(caster, caster.global_position, "jawa_na", 28.0, 46.0, power, 2.0, 44.0)
