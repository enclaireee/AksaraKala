class_name Chaser extends EnemyBase
## Melee chaser: notice, chase, telegraphed lunge, recover (combat.md).

enum State { IDLE, CHASE, WINDUP, ATTACK, RECOVER, FLINCH, RETURN, DEAD }

const TELEGRAPH := Color(1.0, 0.45, 0.45)

var state := State.IDLE
var state_time := 0.0
var facing := 0.0          # radians


func _tick(delta: float) -> void:
	state_time += delta
	var to_target := Vector2.INF
	if target != null:
		to_target = target.global_position - global_position
	match state:
		State.IDLE:
			if to_target.length() <= tuning.enemy_notice:
				_enter(State.CHASE)
		State.CHASE:
			if (global_position - home).length() > tuning.enemy_leash or target == null:
				_enter(State.RETURN)
			else:
				_turn(to_target.angle(), delta)
				velocity = Vector2.from_angle(facing) * tuning.chaser_speed
				if to_target.length() <= tuning.chaser_attack_range:
					_enter(State.WINDUP)
		State.WINDUP:
			if state_time >= tuning.chaser_windup:
				_enter(State.ATTACK)
		State.ATTACK:
			if state_time >= tuning.chaser_lunge_time:
				_enter(State.RECOVER)
		State.RECOVER:
			if target != null:
				_turn(to_target.angle(), delta)
			if state_time >= tuning.chaser_recovery:
				_enter(State.CHASE)
		State.FLINCH:
			velocity = knock
			if state_time >= tuning.enemy_flinch:
				_enter(State.CHASE)
		State.RETURN:
			var to_home := home - global_position
			if to_home.length() <= tuning.chaser_speed * delta:
				global_position = home
				_enter(State.IDLE)
			else:
				_turn(to_home.angle(), delta)
				velocity = to_home.normalized() * tuning.chaser_speed
	move_and_slide()


func _enter(s: State) -> void:
	if state == State.WINDUP or state == State.ATTACK:
		body.modulate = Color.WHITE
		attack_hitbox.deactivate()
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	match s:
		State.WINDUP:
			body.modulate = TELEGRAPH
		State.ATTACK:
			velocity = Vector2.from_angle(facing) * tuning.chaser_lunge / tuning.chaser_lunge_time
			attack_hitbox.activate()


func _turn(want: float, delta: float) -> void:
	var step := deg_to_rad(tuning.enemy_turn_rate) * delta
	facing += clampf(angle_difference(facing, want), -step, step)
	aim.rotation = facing


func _on_flinch() -> void:
	_enter(State.FLINCH)


func _on_died() -> void:
	super()
	state = State.DEAD
