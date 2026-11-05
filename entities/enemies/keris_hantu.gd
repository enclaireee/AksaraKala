class_name KerisHantu extends Charger
## Zone 3 charger: a flying keris that darts in lines; its hit applies Curse.
## Weakness Nga Bind mid-dart: it drops for DROP_TIME.

const DROP_TIME := 2.5   # TUNE


func _ready() -> void:
	super()
	if is_queued_for_deletion():
		return
	attack_hitbox.hit_landed.connect(func(hb: Hurtbox) -> void: _on_landed(hb.owner))
	if status != null:
		status.started.connect(func(type: Status.Type) -> void:
			if type == Status.Type.BOUND and state == State.DASH and not dead:
				stun_time = DROP_TIME
				_enter(State.STUN)
				get_node("/root/Events").weakness_triggered.emit(kind))


func _on_landed(victim: Node) -> void:
	var st: Variant = victim.get("status") if victim != null else null
	if st is Status:
		(st as Status).apply(Status.Type.CURSE)
