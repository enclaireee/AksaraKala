extends Hitbox
## Jawa Na: the caster dashes through enemies, brief invincibility (spells.md 3).

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var _t := 0.0
const DISTANCE := 80.0   # TUNE
const TIME := 0.15       # TUNE


func _ready() -> void:
	damage = roundi(data.power * power * SpellUtil.damage(caster))
	source = caster
	poise_mult = preload("res://data/combat_tuning.tres").spell_poise_mult
	direction = direction.normalized()
	caster.health.set_invincible(TIME + 0.1)   # TUNE
	super()
	activate()


func _physics_process(delta: float) -> void:
	var step := direction * DISTANCE * minf(delta, TIME - _t) / TIME
	# ponytail: the player's own move_and_slide still runs this frame; no player dash state hook exists yet.
	if caster is CharacterBody2D:
		(caster as CharacterBody2D).move_and_collide(step)
	else:
		caster.global_position += step
	global_position = caster.global_position
	_t += delta
	if _t >= TIME:
		queue_free()
