class_name Kemamang extends Shooter
## Zone 3 shooter: spits 3 slow wisps in a spread; player melee within MELEE_CUT destroys them.
## Weakness Na Dash-strike while it charges the spit (WINDUP): it drops (Shooter's GROUNDED) and takes x2 while down.

const WISP_SPEED := 55.0   # TUNE: slow
const SPREAD := 0.35       # TUNE: radians between wisps (about 20 degrees)
const MELEE_CUT := 28.0    # TUNE
const DASH_MULT := 2.0     # TUNE

var wisps: Array[Arrow] = []


func _tick(delta: float) -> void:
	var mh: Variant = target.get("melee_hitbox") if target != null else null
	if mh is Hitbox and (mh as Hitbox).monitoring:   # ponytail: a radius around the player, not the swing's arc
		for w in wisps:
			if is_instance_valid(w) and w.global_position.distance_to(target.global_position) <= MELEE_CUT:
				w.queue_free()
	wisps = wisps.filter(func(w: Arrow) -> bool: return is_instance_valid(w) and not w.is_queued_for_deletion())
	super(delta)


func _fire() -> void:
	for a in [-SPREAD, 0.0, SPREAD]:
		var shot := SHOT.instantiate() as Arrow
		shot.source = self
		shot.direction = Vector2.from_angle(facing + a)
		shot.speed = WISP_SPEED
		shot.max_range = tuning.shot_range
		shot.damage = attack_hitbox.damage
		get_parent().add_child(shot)
		shot.global_position = aim.global_position
		(shot.get_node("Glow") as Polygon2D).color = Color(0.2, 0.9, 0.85)
		wisps.append(shot)


func _on_hurt(hitbox: Hitbox) -> void:
	var weak: bool = state == State.WINDUP and hitbox.get_script() != null and (hitbox.get_script() as Script).resource_path.ends_with("dash_strike.gd")
	super(hitbox)
	if weak and not health.is_dead():
		release_token()
		_enter(State.GROUNDED)
		get_node("/root/Events").weakness_triggered.emit(kind)
	if state == State.GROUNDED and not health.is_dead():
		health.take_damage(roundi(hitbox.damage * (DASH_MULT - 1.0)), hitbox.source, true)
