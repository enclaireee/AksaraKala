class_name ButoIjo extends EnemyBase
## Miniboss: Buto Ijo (bestiary.md "Build spec"). Four pouch phases (100/75/50/25%), each adds 3 fields that only hurt him.
## Defeat: EnemyBase death, then Events.boss_defeated. The quest step sets mq3_4 (as with Bondowoso).
## The HUD polls: group "boss", health, boss_name_key, engaged.
# ponytail: Timun Mas is not a node. The arena centre is where the player stood when the fight began unless arena_center is set.
# Heavy hits landing free while stunned needs nothing: Buto has no shield, so every hit lands.

enum State { IDLE, CHASE, WINDUP, CHARGE, RECOVER, PAUSE, STUN }

const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const FIELD_SCENE := preload("res://entities/bosses/pouch_field.tscn")
const KINDS := ["bramble", "bamboo", "salt", "mud"]
const ROWS := [0.2, 0.4, 0.6, 0.8]   # TUNE: per phase, how far from his start to the arena centre its 3 fields sit

@export var boss_name_key := "BOSS_BUTO_IJO"
@export var speed := 30.0              # TUNE
@export var engage_range := 128.0      # 8 tiles
@export var arena_center := Vector2.INF
@export var charge_min := 64.0         # spec
@export var charge_max := 200.0        # spec
@export var charge_length := 220.0     # spec
@export var charge_speed := 320.0      # TUNE
@export var charge_windup := 0.8       # spec
@export var charge_damage := 41        # spec, heavy
@export var pound_range := 56.0        # spec
@export var pound_radius := 48.0       # spec
@export var pound_windup := 0.8        # spec
@export var pound_damage := 41         # spec, heavy
@export var recovery := 1.2            # TUNE
@export var pause_time := 1.0          # spec: the roar
@export var field_spread := 36.0       # TUNE: sideways gap between a phase's fields
@export var bramble_slow := 0.5        # spec: speed multiplier
@export var salt_slow := 0.4           # spec: 60% slow
@export var bamboo_stun := 1.5         # spec
@export var mud_bind := 2.0            # spec
@export var mud_rest := 4.0            # spec

var state := State.IDLE
var state_time := 0.0
var phase := 0                         # 0 until the fight starts
var engaged := false
var attacks := 0
var fields: Array[PouchField] = []
var _start := Vector2.ZERO
var _dir := Vector2.RIGHT
var _from := Vector2.ZERO
var _pound := false
var _marker: Polygon2D
var _blast_left := 0.0


func _ready() -> void:
	super()
	if dead or is_queued_for_deletion():
		return
	add_to_group("boss")
	_start = global_position
	health.changed.connect(_on_health)


func in_field(kind: String) -> bool:
	for f in fields:
		if f.kind == kind and f.contains(global_position):
			return true
	return false


func _tick(delta: float) -> void:
	state_time += delta
	if _blast_left > 0.0:
		_blast_left -= delta
		if _blast_left <= 0.0:
			attack_hitbox.deactivate()
	var to_t := Vector2.INF
	if target != null:
		to_t = target.global_position - global_position
	var d := to_t.length()
	if d <= engage_range:
		_engage()
	_field_effects(delta)
	match state:
		State.IDLE:
			if engaged:
				_enter(State.CHASE)
		State.CHASE:
			if d <= pound_range:
				_begin_attack(true)
			elif d >= charge_min and d <= charge_max and not in_field("salt"):
				_begin_attack(false)
			else:
				velocity = to_t.normalized() * speed * slow() if d > pound_range else Vector2.ZERO
		State.WINDUP:
			if state_time >= (pound_windup if _pound else charge_windup):
				if _pound:
					_land()
					_enter(State.RECOVER)
				else:
					_start_charge()
		State.CHARGE:
			if in_field("bamboo"):
				_end_charge(State.STUN)
			elif global_position.distance_to(_from) >= charge_length or (state_time > 0.05 and is_on_wall()):
				_end_charge(State.RECOVER)
		State.RECOVER:
			if state_time >= recovery:
				_enter(State.CHASE)
		State.PAUSE:
			if state_time >= pause_time:
				_enter(State.CHASE)
		State.STUN:
			if state_time >= bamboo_stun:
				_enter(State.CHASE)
	move_and_slide()


func _engage() -> void:
	if engaged:
		return
	engaged = true
	if arena_center == Vector2.INF and target != null:
		arena_center = target.global_position
	if phase == 0:
		_next_phase()


# --- pouches ---

func _field_effects(delta: float) -> void:
	for f in fields:
		f.rest_left = maxf(0.0, f.rest_left - delta)
		var now := f.contains(global_position)
		match f.kind:
			"bramble":
				if now and status:
					status.apply(Status.Type.SLOW, 0.1, bramble_slow)
			"salt":
				if now and status:
					status.apply(Status.Type.SLOW, 0.1, salt_slow)
			"mud":
				if now and not f.inside and f.rest_left <= 0.0 and status:
					status.apply(Status.Type.BOUND, mud_bind)
					f.rest_left = mud_rest
		f.inside = now


func _next_phase() -> void:
	phase += 1
	_spawn_fields(KINDS[phase - 1])
	if phase > 1:
		_enter(State.PAUSE)   # the roar; phase 1 starts as the fight does


func _spawn_fields(kind: String) -> void:
	var c := arena_center if arena_center != Vector2.INF else _start
	var along := (c - _start)
	var side := along.orthogonal().normalized() if along.length() > 1.0 else Vector2.DOWN
	for i in 3:
		var f := FIELD_SCENE.instantiate() as PouchField
		f.kind = kind
		var spot := _start.lerp(c, ROWS[phase - 1]) + side * field_spread * (i - 1)
		f.position = spot
		get_parent().add_child(f)
		f.global_position = spot
		fields.append(f)


func _on_health(hp: int, max_hp: int) -> void:
	_engage()   # first hit
	while phase > 0 and phase < 4 and hp > 0 and hp * 4 <= max_hp * (4 - phase):
		_next_phase()


# --- attacks (same telegraph style as Sangkuriang) ---

func _enter(s: State) -> void:
	_clear_attack()
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	body.modulate = Color(1.0, 0.45, 0.45) if s == State.WINDUP else (Color(0.7, 0.75, 1.0) if s == State.STUN else Color.WHITE)


func _begin_attack(pound: bool) -> void:
	_enter(State.WINDUP)
	_pound = pound
	_dir = (target.global_position - global_position).normalized()
	_marker = Polygon2D.new()
	if pound:
		var pts := PackedVector2Array()
		for i in 16:
			pts.append(Vector2.from_angle(TAU * i / 16.0) * pound_radius)
		_marker.polygon = pts
	else:
		var n := _dir.orthogonal() * 8.0
		_marker.polygon = PackedVector2Array([n, _dir * charge_length + n, _dir * charge_length - n, -n])
	_marker.color = MARKER
	_marker.z_index = -1
	get_parent().add_child(_marker)
	_marker.global_position = global_position


func _land() -> void:
	attacks += 1
	attack_hitbox.global_position = global_position
	(attack_hitbox.get_node("Shape") as CollisionShape2D).shape.radius = pound_radius
	attack_hitbox.damage = pound_damage
	attack_hitbox.heavy = true
	attack_hitbox.activate()
	_blast_left = 0.15


func _start_charge() -> void:
	attacks += 1
	_enter(State.CHARGE)
	_from = global_position
	velocity = _dir * charge_speed
	(attack_hitbox.get_node("Shape") as CollisionShape2D).shape.radius = 14.0
	attack_hitbox.position = Vector2.ZERO
	attack_hitbox.damage = charge_damage
	attack_hitbox.heavy = true
	attack_hitbox.activate()


func _end_charge(next: State) -> void:
	attack_hitbox.deactivate()
	_enter(next)


func _clear_attack() -> void:
	if is_instance_valid(_marker):
		_marker.queue_free()
	_marker = null


func _on_flinch() -> void:
	pass   # bosses do not flinch


func _on_died() -> void:
	_clear_attack()
	super()
	# Sinks to his knees in the mud; Timun Mas is safe off screen.
	var tw := body.create_tween().set_parallel()
	tw.tween_property(body, "modulate:a", 0.0, 0.35)
	tw.tween_property(body, "scale:y", 0.6, 0.35)
	var events := get_node("/root/Events")
	get_tree().create_timer(0.3).timeout.connect(func() -> void: events.boss_defeated.emit("buto_ijo"))
