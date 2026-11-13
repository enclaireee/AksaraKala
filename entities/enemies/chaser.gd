class_name Chaser extends EnemyBase
## Melee walker: notice, chase, telegraphed attack, recover (combat.md 5.1).
## Used by the chaser and the tank roles; the role picks the tuning values.

enum State { IDLE, CHASE, WINDUP, ATTACK, RECOVER, FLINCH, STAGGER, RETURN, DEAD }

const TELEGRAPH := Color(1.0, 0.45, 0.45)
const STAGGERED := Color(0.7, 0.75, 1.0)   # ponytail: tint instead of shake + stars until the art pass

@export var bind_weak := false   # Jurig Leuweung: Bound means no new swing and x2 poise damage

var state := State.IDLE
var state_time := 0.0
var stagger_time := 0.0
var facing := 0.0          # radians

@onready var slash: Polygon2D = attack_hitbox.get_node_or_null("Slash")
@onready var arc: CollisionPolygon2D = attack_hitbox.get_node_or_null("Arc")


const SMEAR := "res://assets/art/fx/%s.png"


## Art pass v8: the swing wedge is the shape source only (its scene node is invisible); this child sprite is the
## visual. It plays the 4-frame enemy smear whenever the wedge is shown and holds `hold_frame`. Fits the polygon's
## reach and width at the moment it appears, so the polygon can be set after this call.
static func attach_smear(wedge: Polygon2D, heavy: bool, hold_frame := 3) -> void:
	var path := SMEAR % ("enemy_smear_heavy" if heavy else "enemy_smear")
	if wedge == null or not ResourceLoader.exists(path):
		return
	var spr := Sprite2D.new()
	spr.texture = load(path)
	spr.hframes = 4
	spr.visible = false
	wedge.add_child(spr)
	wedge.visibility_changed.connect(func() -> void:
		if not wedge.is_visible_in_tree() or wedge.polygon.is_empty():
			return
		var reach := 0.0
		var half := 0.0
		for v in wedge.polygon:
			reach = maxf(reach, v.x)
			half = maxf(half, absf(v.y))
		spr.scale = Vector2(maxf(reach, 8.0) / 20.0, maxf(half, 4.0) / (20.0 * sin(deg_to_rad(50.0))))
		spr.visible = true
		spr.frame = 0
		var tw := spr.create_tween()
		tw.tween_property(spr, "frame", hold_frame, 0.05 * (hold_frame + 1)))


func _ready() -> void:
	super()
	attach_smear(slash, arc != null)
	if bind_weak and status != null:
		status.started.connect(func(type: Status.Type) -> void:
			if type == Status.Type.BOUND:
				get_node("/root/Events").weakness_triggered.emit(kind))
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
					if d <= t("attack_range") and not _bound_weak():
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


func _bound_weak() -> bool:
	return bind_weak and status != null and status.has(Status.Type.BOUND)


func _poise_mult() -> float:
	return tuning.weak_bind_poise_mult if _bound_weak() else 1.0


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
