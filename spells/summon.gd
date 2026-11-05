extends Hitbox
## Jawa Ra: a tiger spirit chases the nearest enemy for 10 s, about 15 damage per 0.6 s (spells.md 3).

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var _left := 0.0
var _tick := 0.0
const SPEED := 90.0   # TUNE
const PERIOD := 0.6


func _ready() -> void:
	damage = roundi(data.power * power * SpellUtil.damage(caster))
	source = caster
	poise_mult = preload("res://data/combat_tuning.tres").spell_poise_mult
	_left = data.duration
	super()
	activate()


func _physics_process(delta: float) -> void:
	_left -= delta
	if _left <= 0.0:
		queue_free()
		return
	_tick += delta
	if _tick >= PERIOD:
		_tick = 0.0
		deactivate()   # off then on re-reports overlaps, so the next swipe can land again
		activate()
	# ponytail: walks straight at the nearest enemy, no pathfinding; it follows the caster when none is near.
	var goal: Vector2 = caster.global_position
	var best := INF
	for e in get_tree().get_nodes_in_group("enemy"):
		var d: float = e.global_position.distance_to(global_position)
		if d < best:
			best = d
			goal = e.global_position
	global_position = global_position.move_toward(goal, SPEED * delta)
