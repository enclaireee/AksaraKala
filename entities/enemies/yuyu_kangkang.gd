class_name YuyuKangkang extends Charger
## SQ-T1 elite crab: charges sideways along a 12-tile lane (scene charger_dash_max 192) and pinches twice up close.
## Weakness Bind mid-charge. Inert until SQ-T1 is at step 2 (index 1); the peaceful route moves the quest on and
## EliteGuard then removes it (as Wewe Gombel).

const LANE_HALF := 14.0      # TUNE: it only charges when the player is this close to its row
const PINCH_RANGE := 30.0    # TUNE
const PINCH_AT := [0.3, 0.75]   # TUNE: strike start times; the first 0.3 s is the telegraph
const PINCH_LEN := 0.15
const PINCH_END := 1.2
const PINCH_COOLDOWN := 2.5
const DROP_TIME := 2.0       # TUNE

var active := true
var pinching := false
var pinch_t := 0.0
var pinch_on := false
var pinch_cd := 1.0


func _ready() -> void:
	super()
	if is_queued_for_deletion():
		return
	if status != null:
		status.started.connect(func(type: Status.Type) -> void:
			if type == Status.Type.BOUND and state == State.DASH and not dead:
				stun_time = DROP_TIME
				_enter(State.STUN)
				get_node("/root/Events").weakness_triggered.emit(kind))
	var g := EliteGuard.new()
	g.cond = "step:sq_t1=1"
	add_child(g)


func _tick(delta: float) -> void:
	pinch_cd -= delta
	if not pinching and state == State.APPROACH and pinch_cd <= 0.0 and target != null \
			and global_position.distance_to(target.global_position) <= PINCH_RANGE:
		pinching = true
		pinch_t = 0.0
		release_token()
		velocity = Vector2.ZERO
		body.modulate = TELEGRAPH_TINT
	if pinching:
		pinch_t += delta
		var on := false
		for s in PINCH_AT:
			on = on or (pinch_t >= s and pinch_t < s + PINCH_LEN)
		if on and not pinch_on:
			attack_hitbox.activate()
		elif not on and pinch_on:
			attack_hitbox.deactivate()
		pinch_on = on
		if pinch_t >= PINCH_END:
			pinching = false
			pinch_cd = PINCH_COOLDOWN
			body.modulate = Color.WHITE
		return
	if state == State.APPROACH and target != null and absf(target.global_position.y - global_position.y) > LANE_HALF:
		velocity = (target.global_position - global_position).normalized() * t("speed") * slow()   # Charger stands still once in range
	super(delta)


func _enter(s: State) -> void:
	if s == State.TELEGRAPH:   # the lane is horizontal: only charge when lined up on its row
		if target == null or absf(target.global_position.y - global_position.y) > LANE_HALF:
			return
		facing = 0.0 if target.global_position.x >= global_position.x else PI
		aim.rotation = facing
	super(s)
