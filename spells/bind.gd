extends Node2D
## Sunda Nga: roots every enemy in radius, no damage (spells.md 3).

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var _t := 0.0
const GROW := 0.3


func _ready() -> void:
	for e in get_tree().get_nodes_in_group("enemy"):
		if e.global_position.distance_to(global_position) <= data.radius and e.get("status") != null:
			# ponytail: elites and bosses will get Slow instead (combat.md 4); none exist yet.
			e.status.apply(Status.Type.BOUND, -1.0 if SpellUtil.class_id(caster) != "rogue" else 1.3 * e.status.tuning.bound_time)   # Rogue +30%


func _physics_process(delta: float) -> void:
	_t += delta
	queue_redraw()
	if _t >= GROW:
		queue_free()


func _draw() -> void:
	draw_arc(Vector2.ZERO, data.radius * minf(_t / GROW, 1.0), 0.0, TAU, 32, Color(0.337, 0.706, 0.914, 0.7), 1.0)
