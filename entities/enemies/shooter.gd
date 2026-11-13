class_name Shooter extends EnemyBase
## Kuntilanak: keeps a distance band, telegraphs, fires one spirit shot (combat.md 3.1, 5.1).
## With shriek on (Kuntilanak) the attack is a cone instead of a shot, and a Bolt during the wind-up grounds her.
## ponytail: skipped the tier 2+ 3-shot spread.

enum State { IDLE, KEEP, WINDUP, SHRIEK, GROUNDED, RECOVER, FLINCH, RETURN, DEAD }

const TELEGRAPH := Color(1.0, 0.45, 0.45)
const STAGGERED := Color(0.7, 0.75, 1.0)
const SHOT := preload("res://entities/enemies/spirit_shot.tscn")

@export var shriek := false

var state := State.IDLE
var state_time := 0.0
var facing := 0.0          # radians

@onready var cone: Polygon2D = attack_hitbox.get_node_or_null("Slash")
@onready var arc: CollisionPolygon2D = attack_hitbox.get_node_or_null("Arc")


func _ready() -> void:
	super()
	if shriek:
		Chaser.attach_smear(cone, false, 2)
		arc.polygon = Player._arc(t("arc"), t("reach"))
		cone.polygon = arc.polygon


func _tick(delta: float) -> void:
	state_time += delta
	var to_target := Vector2.INF
	if target != null:
		to_target = target.global_position - global_position
	var d := to_target.length()
	if shriek:   # floats; sits on the ground while grounded
		body.position.y = 0.0 if state == State.GROUNDED else -4.0 - 2.0 * sin(Time.get_ticks_msec() / 250.0)
	match state:
		State.IDLE:
			if d <= tuning.enemy_notice:
				_enter(State.KEEP)
		State.KEEP:
			if (global_position - home).length() > tuning.enemy_leash or target == null:
				_enter(State.RETURN)
			else:
				_turn(to_target.angle(), delta)
				velocity = _band_velocity(to_target, d) * slow()
				if d >= t("near") and d <= t("far") and absf(angle_difference(facing, to_target.angle())) < 0.05 and request_token():   # aimed before it commits
					_enter(State.WINDUP)
		State.WINDUP:
			if state_time >= t("windup"):
				if shriek:
					_enter(State.SHRIEK)
				else:
					_fire()
					_enter(State.RECOVER)
		State.SHRIEK:
			if state_time >= t("shriek_time"):
				_enter(State.RECOVER)
		State.GROUNDED:
			if state_time >= tuning.weak_ground_time:
				_enter(State.KEEP)
		State.RECOVER:
			_turn(to_target.angle(), delta)
			velocity = _band_velocity(to_target, d) * slow()
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
				velocity = to_home.normalized() * t("speed") * slow()
	move_and_slide()


func _band_velocity(to_target: Vector2, d: float) -> Vector2:
	if d < t("near"):
		return -to_target / d * t("speed")
	if d > t("far"):
		return to_target / d * t("speed")
	return Vector2.ZERO


func _enter(s: State) -> void:
	if state in [State.WINDUP, State.GROUNDED]:
		body.modulate = Color.WHITE
	if shriek:
		attack_hitbox.deactivate()
		cone.visible = false
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	match s:
		State.WINDUP:
			body.modulate = TELEGRAPH
			if shriek:
				cone.visible = true
				cone.modulate.a = 0.3   # cone telegraph
		State.SHRIEK:
			attack_hitbox.activate()
			cone.visible = true
			cone.modulate.a = 0.8
		State.GROUNDED:
			body.modulate = STAGGERED


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


func _on_hurt(hitbox: Hitbox) -> void:
	var weak := shriek and state == State.WINDUP and hitbox is Bolt
	super(hitbox)
	if weak and not health.is_dead():
		_enter(State.GROUNDED)
		get_node("/root/Events").weakness_triggered.emit(kind)


func _on_flinch() -> void:
	if state != State.GROUNDED:
		_enter(State.FLINCH)


func _on_died() -> void:
	super()
	state = State.DEAD
