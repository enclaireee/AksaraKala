class_name NamelessHunter extends EnemyBase
## Boss: the Nameless Hunter (bestiary.md Story v2). Shadow-step with a ground marker, chain hook that pulls,
## and Forget: a cone that empties sakti and locks casting. A Ga Ward up when it lands blocks it.
## Phase 2 at 50% HP: shadow-steps come in pairs and Forget follows the second.
## Defeat: EnemyBase death, then Events.boss_defeated("nameless_hunter").
## The HUD polls: group "boss", health, boss_name_key, engaged.
# ponytail: the pull is a collision-checked slide, not an animated chain.

enum State { IDLE, CHASE, FADE, MARK, HOOK, FORGET, RECOVER }

const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const PALE := Color(0.85, 0.85, 1.0, 0.4)

@export var boss_name_key := "BOSS_NAMELESS_HUNTER"
@export var cond := ""                   # Game.check condition; empty = always on
@export var speed := 55.0                # spec
@export var engage_range := 128.0        # 8 tiles
@export var fade_time := 0.3             # spec
@export var mark_time := 0.6             # spec: ground marker before he reappears
@export var step_damage := 22            # spec, heavy
@export var step_radius := 20.0          # TUNE: marker and cut radius
@export var step_behind := 24.0          # TUNE: the marker sits this far past the player
@export var hook_windup := 0.6           # spec
@export var hook_len := 128.0            # spec: 8 tiles
@export var hook_damage := 16            # spec, light
@export var hook_pull := 48.0            # spec: 3 tiles
@export var forget_windup := 0.8         # spec
@export var forget_radius := 64.0        # spec
@export var forget_arc := 90.0           # spec, degrees
@export var forget_lock := 4.0           # spec: seconds of cast lockout
@export var recovery := 1.0              # TUNE

var active := true   # EliteGuard flips it
var state := State.IDLE
var state_time := 0.0
var phase := 1
var engaged := false
var attacks := 0
var _seq := 0
var _steps_left := 0
var _spot := Vector2.ZERO
var _facing := Vector2.RIGHT
var _hooking := false
var _marker: Polygon2D
var _blast_left := 0.0


func _ready() -> void:
	super()
	if dead or is_queued_for_deletion():
		return
	add_to_group("boss")
	if cond != "":   # hidden and inert until Game.check(cond) holds (elite_guard.gd)
		var g := EliteGuard.new()
		g.cond = cond
		add_child(g)
	health.changed.connect(_on_health)
	attack_hitbox.hit_landed.connect(_on_hit_landed)


func _tick(delta: float) -> void:
	state_time += delta
	if _blast_left > 0.0:
		_blast_left -= delta
		if _blast_left <= 0.0:
			attack_hitbox.deactivate()
			_hooking = false
	var to_t := Vector2.INF
	if target != null:
		to_t = target.global_position - global_position
	var d := to_t.length()
	if d <= engage_range:
		engaged = true
	match state:
		State.IDLE:
			if engaged:
				_enter(State.CHASE)
		State.CHASE:
			if target == null:
				pass
			else:
				var want := _seq % (2 if phase == 2 else 3)   # step (a pair in phase 2, then Forget), hook, Forget
				if want == 0:
					_seq += 1
					_steps_left = 2 if phase == 2 else 1
					_begin_step()
				elif want == 1 and d <= hook_len and d >= 24.0:
					_seq += 1
					_begin_cone(true, to_t)
				elif want == 2 and d <= forget_radius - 8.0:
					_seq += 1
					_begin_cone(false, to_t)
				else:
					velocity = to_t.normalized() * speed * slow()
		State.FADE:
			if state_time >= fade_time:
				_spot = target.global_position + to_t.normalized() * step_behind if target != null else global_position
				_show_ring(step_radius)
				_marker.global_position = _spot
				_enter_keep(State.MARK)
		State.MARK:
			if state_time >= mark_time:
				_land_step()
		State.HOOK:
			if state_time >= hook_windup:
				_land_hook()
		State.FORGET:
			if state_time >= forget_windup:
				_land_forget()
		State.RECOVER:
			if state_time >= recovery:
				_enter(State.CHASE)
	move_and_slide()


func _enter(s: State) -> void:
	if is_instance_valid(_marker):
		_marker.queue_free()
	_marker = null
	_enter_keep(s)


func _enter_keep(s: State) -> void:
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	body.modulate = Color(1.0, 0.45, 0.45) if s in [State.HOOK, State.FORGET] else Color.WHITE
	if s == State.FADE or s == State.MARK:
		body.modulate.a = 0.0
	_gone(s == State.FADE or s == State.MARK)


## While faded he cannot be hit.
func _gone(on: bool) -> void:
	hurtbox.set_deferred("monitorable", not on and not dead)


func _begin_step() -> void:
	_enter(State.FADE)


func _land_step() -> void:
	if is_instance_valid(_marker):
		_marker.queue_free()
	_marker = null
	global_position = _spot
	attacks += 1
	_steps_left -= 1
	_enter(State.RECOVER)
	var cs := CircleShape2D.new()
	cs.radius = step_radius
	_strike(cs, Vector2.ZERO, step_damage)
	_blast_left = 0.15
	if _steps_left > 0:
		_begin_step()   # phase 2: the second step follows at once
	elif phase == 2 and target != null:
		_begin_cone(false, target.global_position - global_position)


func _begin_cone(hook: bool, to_t: Vector2) -> void:
	_enter(State.HOOK if hook else State.FORGET)
	_facing = to_t.normalized()
	aim.rotation = _facing.angle()
	if hook:
		_show(PackedVector2Array([Vector2(0, -4), Vector2(hook_len, -4), Vector2(hook_len, 4), Vector2(0, 4)]), MARKER)
	else:
		_show(Player._arc(forget_arc, forget_radius), PALE)


func _land_hook() -> void:
	attacks += 1
	var rect := RectangleShape2D.new()
	rect.size = Vector2(hook_len, 8)
	_strike(rect, Vector2(hook_len / 2.0, 0), hook_damage)
	_hooking = true
	_blast_left = 0.15
	_enter(State.RECOVER)


## A hook that connects pulls the player toward him.
func _on_hit_landed(_hb: Hurtbox) -> void:
	if not _hooking or not target is CharacterBody2D:
		return
	_hooking = false
	var gap := target.global_position - global_position
	(target as CharacterBody2D).move_and_collide(-gap.normalized() * minf(hook_pull, maxf(gap.length() - 16.0, 0.0)))


func _land_forget() -> void:
	attacks += 1
	_enter(State.RECOVER)
	if target == null or target.global_position.distance_to(global_position) > forget_radius:
		return
	var off := target.global_position - global_position
	if absf(angle_difference(_facing.angle(), off.angle())) > deg_to_rad(forget_arc / 2.0):
		return
	if not get_tree().get_nodes_in_group("ward").is_empty():
		return   # Ga Ward blocks it completely
	var sakti := target.get("sakti") as SaktiGauge
	if sakti != null:
		sakti.value = 0.0
		sakti.changed.emit(0.0, sakti.max_value)
	var cast: Object = target.get("cast")
	if cast != null:
		cast.call("_lock")   # the existing lockout (also ends a cast in progress), stretched to forget_lock
		cast.set("_locked_until", Time.get_ticks_msec() + int(forget_lock * 1000.0))


func _show(pts: PackedVector2Array, c: Color) -> void:
	_marker = Polygon2D.new()
	_marker.polygon = pts
	_marker.color = c
	_marker.z_index = -1
	aim.add_child(_marker)


## The step's ground ring, in the world (not under Aim).
func _show_ring(r: float) -> void:
	var pts := PackedVector2Array()
	for i in 16:
		pts.append(Vector2.from_angle(TAU * i / 16.0) * r)
	_marker = Polygon2D.new()
	_marker.polygon = pts
	_marker.color = MARKER
	_marker.z_index = -1
	get_parent().add_child(_marker)


func _strike(shape: Shape2D, at: Vector2, dmg: int) -> void:
	(attack_hitbox.get_node("Shape") as CollisionShape2D).shape = shape
	attack_hitbox.position = at
	attack_hitbox.damage = dmg
	attack_hitbox.heavy = dmg > 18
	attack_hitbox.activate()


func _on_health(hp: int, max_hp: int) -> void:
	engaged = true   # first hit
	if phase == 1 and hp > 0 and hp * 2 <= max_hp:
		phase = 2


func _on_flinch() -> void:
	pass   # bosses do not flinch


func _on_died() -> void:
	if is_instance_valid(_marker):
		_marker.queue_free()
	super()
	body.modulate.a = 1.0
	var tw := body.create_tween().set_parallel()
	tw.tween_property(body, "modulate:a", 0.0, 0.4)   # comes apart into name-strips (art later)
	var events := get_node("/root/Events")
	get_tree().create_timer(0.3).timeout.connect(func() -> void: events.boss_defeated.emit("nameless_hunter"))
