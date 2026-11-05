class_name Shooter extends EnemyBase
## Kuntilanak: keeps a distance band, telegraphs, fires one spirit shot (combat.md 3.1, 5.1).
## ponytail: skipped the tier 2+ 3-shot spread and the bestiary's shriek cone.

enum State { IDLE, KEEP, WINDUP, RECOVER, FLINCH, RETURN, DEAD }

const TELEGRAPH := Color(1.0, 0.45, 0.45)
const SHOT := preload("res://entities/enemies/spirit_shot.tscn")

var state := State.IDLE
var state_time := 0.0
var facing := 0.0          # radians


func _tick(delta: float) -> void:
	state_time += delta
	var to_target := Vector2.INF
	if target != null:
		to_target = target.global_position - global_position
	var d := to_target.length()
	match state:
		State.IDLE:
			if d <= tuning.enemy_notice:
				_enter(State.KEEP)
		State.KEEP:
			if (global_position - home).length() > tuning.enemy_leash or target == null:
				_enter(State.RETURN)
			else:
				_turn(to_target.angle(), delta)
				velocity = _band_velocity(to_target, d)
				if d >= t("near") and d <= t("far") and absf(angle_difference(facing, to_target.angle())) < 0.05 and request_token():   # aimed before it commits
					_enter(State.WINDUP)
		State.WINDUP:
			if state_time >= t("windup"):
				_fire()
				_enter(State.RECOVER)
		State.RECOVER:
			_turn(to_target.angle(), delta)
			velocity = _band_velocity(to_target, d)
			if state_time >= t("recovery"):
				release_token()
				_enter(State.KEEP)
		State.FLINCH:
			velocity = knock
			if state_time >= tuning.enemy_flinch:
				_enter(State.KEEP)
		State.RETURN:
			release_token()
			var to_home := home - global_position
			if to_home.length() <= t("speed") * delta:
				global_position = home
				_enter(State.IDLE)
			else:
				_turn(to_home.angle(), delta)
				velocity = to_home.normalized() * t("speed")
	move_and_slide()


func _band_velocity(to_target: Vector2, d: float) -> Vector2:
	if d < t("near"):
		return -to_target / d * t("speed")
	if d > t("far"):
		return to_target / d * t("speed")
	return Vector2.ZERO


func _enter(s: State) -> void:
	if state == State.WINDUP:
		body.modulate = Color.WHITE
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	if s == State.WINDUP:
		body.modulate = TELEGRAPH


func _fire() -> void:
	var shot := SHOT.instantiate() as Arrow
	shot.source = self
	shot.direction = Vector2.from_angle(facing)
	shot.speed = tuning.shot_speed
	shot.max_range = tuning.shot_range
	get_parent().add_child(shot)
	shot.global_position = aim.global_position


func _turn(want: float, delta: float) -> void:
	var step := deg_to_rad(t("turn_rate")) * delta
	facing += clampf(angle_difference(facing, want), -step, step)
	aim.rotation = facing


func _on_flinch() -> void:
	_enter(State.FLINCH)


func _on_died() -> void:
	super()
	state = State.DEAD
