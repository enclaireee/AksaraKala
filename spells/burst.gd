extends Hitbox
## Sunda Ca: a blast around the caster (spells.md 3). Hits everything in radius once, then ends.

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var _t := 0.0
var _radius := 0.0
const LIFE := 0.25   # ASSUMED


func _ready() -> void:
	damage = roundi(data.power * power * SpellUtil.damage(caster))
	source = caster
	poise_mult = preload("res://data/combat_tuning.tres").spell_poise_mult
	_radius = data.radius * (1.25 if SpellUtil.class_id(caster) == "warrior" else 1.0) * SpellUtil.radius_mult(data)   # Warrior +25%, Tell Ciung +10%
	var cs := CircleShape2D.new()   # own shape: the scene's is shared between instances
	cs.radius = _radius
	$Shape.shape = cs
	super()
	activate()


func _physics_process(delta: float) -> void:
	_t += delta
	queue_redraw()
	if _t >= LIFE:
		queue_free()


func _draw() -> void:
	draw_arc(Vector2.ZERO, _radius * minf(_t / LIFE, 1.0), 0.0, TAU, 32, Color(0.337, 0.706, 0.914, 0.8), 2.0)
