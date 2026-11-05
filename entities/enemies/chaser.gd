class_name Chaser extends EnemyBase
## Melee walker: notice, chase, telegraphed attack, recover (combat.md 5.1).
## Used by the chaser and the tank roles; the role picks the tuning values.

enum State { IDLE, CHASE, WINDUP, ATTACK, RECOVER, FLINCH, STAGGER, RETURN, DEAD }

const TELEGRAPH := Color(1.0, 0.45, 0.45)
const STAGGERED := Color(0.7, 0.75, 1.0)   # ponytail: tint instead of shake + stars until the art pass

var state := State.IDLE
var state_time := 0.0
var stagger_time := 0.0
var facing := 0.0          # radians

@onready var slash: Polygon2D = attack_hitbox.get_node_or_null("Slash")
@onready var arc: CollisionPolygon2D = attack_hitbox.get_node_or_null("Arc")


func _ready() -> void:
	super()
	if arc != null:   # wide swing roles (tank) build their arc from tuning
		arc.polygon = Player._arc(t("arc"), t("reach"))
		slash.polygon = arc.polygon


func _tick(delta: float) -> void:
	state_time += delta
	var to_target := Vector2.INF
	if target != null:
		to_target = target.global_position - global_position
	match state:
		State.IDLE:
			if to_target.length() <= tuning.enemy_notice or since_hit < tuning.poise_refill:   # a hit wakes it too (poise roles never flinch)
				_enter(State.CHASE)
		State.CHASE:
			if (global_position - home).length() > tuning.enemy_leash or target == null:
				_enter(State.RETURN)
			else:
				_turn(to_target.angle(), delta)
				var d := to_target.length()
				if d <= tuning.circle_max and request_token():
					velocity = Vector2.from_angle(facing) * t("speed") * slow()
					if d <= t("attack_range"):
						_enter(State.WINDUP)
				else:
					if d > tuning.circle_max:
						release_token()   # the target ran off; let someone else attack
					velocity = circle_velocity(to_target, t("speed")) * slow()
		State.WINDUP:
			if state_time >= t("windup"):
				_enter(State.ATTACK)
		State.ATTACK:
			if state_time >= t("lunge_time"):
				_enter(State.RECOVER)
		State.RECOVER:
			if target != null:
				_turn(to_target.angle(), delta)
			if state_time >= t("recovery"):
				release_token()
				_enter(State.CHASE)
		State.FLINCH:
			velocity = knock
			if state_time >= tuning.enemy_flinch:
				_enter(State.CHASE)
		State.STAGGER:
			if state_time >= stagger_time:
				_enter(State.CHASE)
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


func _enter(s: State) -> void:
	if state in [State.WINDUP, State.ATTACK, State.STAGGER]:
		body.modulate = Color.WHITE
		attack_hitbox.deactivate()
		if slash != null:
			slash.visible = false
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	match s:
		State.WINDUP:
			body.modulate = TELEGRAPH
		State.ATTACK:
			velocity = Vector2.from_angle(facing) * t("lunge") / t("lunge_time")
			attack_hitbox.activate()
			if slash != null:
				slash.visible = true
		State.STAGGER:
			body.modulate = STAGGERED


func _turn(want: float, delta: float) -> void:
	# No turning in wind-up or attack, so dodging through opens the back (combat.md 5.1).
	var step := deg_to_rad(t("turn_rate")) * delta
	facing += clampf(angle_difference(facing, want), -step, step)
	aim.rotation = facing


func _on_flinch() -> void:
	_enter(State.FLINCH)


func _on_stagger(seconds: float) -> void:
	stagger_time = seconds
	_enter(State.STAGGER)


func _on_died() -> void:
	super()
	state = State.DEAD
	if slash != null:
		slash.visible = false
