class_name Charger extends EnemyBase
## Wild Boar: approach, telegraph with a ground line, straight dash that never steers, recover (bestiary.md).
## Weakness: a dash into Ward staggers it (Ga, weak_ward_stagger).

enum State { IDLE, APPROACH, TELEGRAPH, DASH, STUN, RECOVER, FLINCH, RETURN, DEAD }

const TELEGRAPH_TINT := Color(1.0, 0.45, 0.45)
const STUNNED := Color(0.7, 0.75, 1.0)

var state := State.IDLE
var state_time := 0.0
var stun_time := 0.0
var facing := 0.0          # radians
var dash_dir := Vector2.RIGHT
var marker: Line2D


func _ready() -> void:
	super()
	marker = Line2D.new()
	marker.width = 3.0
	marker.default_color = Color(1.0, 0.3, 0.3, 0.5)
	marker.points = PackedVector2Array([Vector2.ZERO, Vector2(t("dash_max"), 0)])
	marker.visible = false
	aim.add_child(marker)


func _tick(delta: float) -> void:
	state_time += delta
	var to_target := Vector2.INF
	if target != null:
		to_target = target.global_position - global_position
	var d := to_target.length()
	match state:
		State.IDLE:
			if d <= tuning.enemy_notice or since_hit < tuning.poise_refill:
				_enter(State.APPROACH)
		State.APPROACH:
			if (global_position - home).length() > tuning.enemy_leash or target == null:
				_enter(State.RETURN)
			else:
				_turn(to_target.angle(), delta)
				if d > t("attack_range"):
					release_token()
					velocity = Vector2.from_angle(facing) * t("speed") * slow()
				elif request_token():
					if absf(angle_difference(facing, to_target.angle())) < 0.05:   # lined up before it commits
						_enter(State.TELEGRAPH)
				else:
					velocity = circle_velocity(to_target, t("speed")) * slow()
		State.TELEGRAPH:   # no turning: the marker is the promise
			if state_time >= t("windup"):
				_enter(State.DASH)
		State.DASH:
			for w in get_tree().get_nodes_in_group("ward"):
				if (w as Node2D).global_position.distance_to(global_position) <= tuning.weak_ward_reach:
					get_node("/root/Events").weakness_triggered.emit(kind)
					stun_time = tuning.weak_ward_stagger
					_enter(State.STUN)
					break
			if state == State.DASH and state_time * t("dash_speed") >= t("dash_max"):
				_enter(State.RECOVER)
		State.STUN:
			if state_time >= stun_time:
				release_token()
				_enter(State.APPROACH)
		State.RECOVER:
			if state_time >= t("recovery"):
				release_token()
				_enter(State.APPROACH)
		State.FLINCH:
			velocity = knock
			if state_time >= tuning.enemy_flinch:
				_enter(State.APPROACH)
		State.RETURN:
			release_token()
			var to_home := home - global_position
			if to_home.length() <= t("speed") * delta:
				global_position = home
				_enter(State.IDLE)
			else:
				_turn(to_home.angle(), delta)
				velocity = to_home.normalized() * t("speed") * slow()
	move_and_slide()
	if state == State.DASH and get_slide_collision_count() > 0:   # wall (or a body in the way)
		stun_time = t("wall_stun")
		_enter(State.STUN)


func _enter(s: State) -> void:
	if state in [State.TELEGRAPH, State.DASH, State.STUN]:
		body.modulate = Color.WHITE
		marker.visible = false
		attack_hitbox.deactivate()
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	match s:
		State.TELEGRAPH:
			body.modulate = TELEGRAPH_TINT
			marker.visible = true
		State.DASH:
			dash_dir = Vector2.from_angle(facing)
			velocity = dash_dir * t("dash_speed")
			attack_hitbox.activate()
		State.STUN:
			body.modulate = STUNNED


func _turn(want: float, delta: float) -> void:
	var step := deg_to_rad(t("turn_rate")) * delta
	facing += clampf(angle_difference(facing, want), -step, step)
	aim.rotation = facing


func _on_flinch() -> void:
	if state != State.DASH and state != State.STUN:   # a dash is not interrupted
		_enter(State.FLINCH)


func _on_died() -> void:
	super()
	marker.visible = false
	state = State.DEAD
