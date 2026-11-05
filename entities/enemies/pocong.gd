class_name Pocong extends Charger
## Mataram charger: hops forward (the dash) and slams down (recovery). Weakness Nga Bind (bestiary.md):
## Bound mid-hop it falls flat for 2 s and takes x1.5 damage.

const FLAT_TIME := 2.0   # TUNE
const FLAT_MULT := 1.5   # TUNE
const HOP_HEIGHT := 5.0

var flat := false


func _ready() -> void:
	super()
	if status != null:
		status.started.connect(func(type: Status.Type) -> void:
			if type == Status.Type.BOUND and state == State.DASH and not dead:
				flat = true
				stun_time = FLAT_TIME
				_enter(State.STUN)
				get_node("/root/Events").weakness_triggered.emit(kind))


func _tick(delta: float) -> void:
	super(delta)
	if flat and state != State.STUN:
		flat = false
	body.position.y = -HOP_HEIGHT * absf(sin(state_time * 14.0)) if state == State.DASH else 0.0


func _on_hurt(hitbox: Hitbox) -> void:
	super(hitbox)
	if flat and not health.is_dead():
		health.take_damage(roundi(hitbox.damage * (FLAT_MULT - 1.0)), hitbox.source, true)
