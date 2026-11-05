class_name PrajuritTerkutuk extends Chaser
## Zone 3 tank: the front shield blocks BLOCK of the damage from the front. Weakness Ra Summon: a tiger near it or
## hitting it makes it turn to face the tiger, exposing its back to the player. Tiger hits are never blocked.
## ponytail: the block refunds hp after the hit lands (Hurtbox applies damage first), so a killing blow still kills.

const BLOCK := 0.75           # bestiary.md
const FRONT_HALF := PI / 2.0  # TUNE: the front is a half circle
const TIGER_REACH := 64.0     # TUNE
const TURN_HOLD := 1.0        # TUNE: keeps facing the tiger this long after it was last near

var tiger_left := 0.0
var tiger_angle := 0.0
var _blocked := false


func _tick(delta: float) -> void:
	tiger_left -= delta
	for n in get_parent().get_children():
		if _is(n, "summon.gd") and (n as Node2D).global_position.distance_to(global_position) <= TIGER_REACH:
			_face((n as Node2D).global_position)
	super(delta)


func _face(at: Vector2) -> void:
	if tiger_left <= 0.0:
		get_node("/root/Events").weakness_triggered.emit(kind)
	tiger_left = TURN_HOLD
	tiger_angle = (at - global_position).angle()


func _turn(want: float, delta: float) -> void:
	super(tiger_angle if tiger_left > 0.0 else want, delta)


func _is(n: Object, file: String) -> bool:
	return n.get_script() != null and (n.get_script() as Script).resource_path.ends_with(file)


func _poise_mult() -> float:
	return 1.0 - BLOCK if _blocked else 1.0


func _on_hurt(hitbox: Hitbox) -> void:
	var from := hitbox.global_position
	if hitbox.source is Node2D:
		from = (hitbox.source as Node2D).global_position
	if _is(hitbox, "summon.gd"):
		_face(hitbox.global_position)
	else:
		_blocked = absf(angle_difference(facing, (from - global_position).angle())) < FRONT_HALF
	super(hitbox)
	if _blocked and not health.is_dead():
		health.heal(roundi(hitbox.damage * BLOCK))
	_blocked = false
