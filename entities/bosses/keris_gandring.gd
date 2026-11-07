class_name KerisGandring extends EnemyBase
## Boss: Mpu Gandring's Keris (bestiary.md "Build spec"). Lights curse stakes (group "curse_stake") one by one; all 7 lit
## means a 2 s red ring, then a curse wave that only dash i-frames avoid. Phase 2 (50%): faster stakes, double dart.
## Defeat: EnemyBase death, then Events.boss_defeated. The quest step sets mq3_7 (as with Bondowoso).
## The HUD polls: group "boss", health, boss_name_key, engaged.

enum State { IDLE, CHASE, DART_WIND, DART, FAN_WIND, RECOVER, PAUSE, RING }

const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const SHOT := preload("res://entities/enemies/spirit_shot.tscn")

@export var boss_name_key := "BOSS_KERIS_GANDRING"
@export var speed := 26.0              # TUNE
@export var engage_range := 160.0      # TUNE
@export var sabotage_flag := "laras_sabotage_keris_seventh_stake"   # HUD boss bar reads this
@export var sabotage_mark_mult := 2.0  # TUNE (v5): the seventh stake takes this many times longer to light
@export var sabotage_ha_range := 120.0  # TUNE (v5): Jawa Ha cleanses this far (spec 80)
@export var arena_radius := 176.0      # TUNE: the curse wave reaches this far from the keris' start
@export var dart_min := 48.0           # TUNE
@export var dart_range := 200.0        # spec: it flies 200 px
@export var dart_speed := 300.0        # TUNE
@export var dart_windup := 0.7         # spec
@export var dart_damage := 18          # spec, light
@export var fan_windup := 0.6          # spec
@export var fan_damage := 18           # spec, light
@export var fan_spread := 30.0         # spec, degrees
@export var shot_speed := 110.0        # TUNE
@export var recovery := 1.0            # TUNE
@export var pause_time := 1.0          # spec
@export var stake_every := 8.0         # spec
@export var stake_every_2 := 5.0       # spec, phase 2
@export var ring_time := 2.0           # spec
@export var wave_damage := 60          # spec, heavy

var state := State.IDLE
var state_time := 0.0
var phase := 1
var engaged := false
var attacks := 0
var waves := 0
var darts_left := 0
var stake_interval := 8.0
var _start := Vector2.ZERO
var _light_t := 0.0
var _dir := Vector2.RIGHT
var _from := Vector2.ZERO
var _marker: Polygon2D
var _blast_left := 0.0
var _fan_next := false


func _ready() -> void:
	super()
	if dead or is_queued_for_deletion():
		return
	add_to_group("boss")
	_start = global_position
	stake_interval = stake_every
	health.changed.connect(_on_health)
	attack_hitbox.hit_landed.connect(_curse)
	get_node("/root/Events").spell_cast.connect(_on_cast)


func stakes() -> Array[CurseStake]:
	var out: Array[CurseStake] = []
	for n in get_tree().get_nodes_in_group("curse_stake"):
		if n is CurseStake and not n.practice:
			out.append(n)
	return out


func lit_count() -> int:
	return stakes().filter(func(s: CurseStake) -> bool: return s.is_lit()).size()


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
		engaged = true
	if engaged and state != State.RING:
		_run_stakes(delta)
	match state:
		State.IDLE:
			if engaged:
				_enter(State.CHASE)
		State.CHASE:
			if d >= dart_min and d <= dart_range:
				if _fan_next:
					_begin_fan()
				else:
					_begin_dart(2 if phase == 2 else 1)
				_fan_next = not _fan_next
			else:
				velocity = to_t.normalized() * speed * slow() if d > dart_min else Vector2.ZERO
		State.DART_WIND:
			if state_time >= dart_windup:
				_start_dart()
		State.DART:
			if global_position.distance_to(_from) >= dart_range or (state_time > 0.05 and is_on_wall()):
				attack_hitbox.deactivate()
				darts_left -= 1
				if darts_left > 0:
					_begin_dart(darts_left)   # phase 2: again at once
				else:
					_enter(State.RECOVER)
		State.FAN_WIND:
			if state_time >= fan_windup:
				_fire_fan()
				_enter(State.RECOVER)
		State.RECOVER:
			if state_time >= recovery:
				_enter(State.CHASE)
		State.PAUSE:
			if state_time >= pause_time:
				_enter(State.CHASE)
		State.RING:
			if state_time >= ring_time:
				_wave()
				_enter(State.RECOVER)
	move_and_slide()


# --- stakes ---

func _run_stakes(delta: float) -> void:
	var all := stakes()
	_light_t += delta
	if _light_t >= stake_interval:
		_light_t = 0.0
		var unlit := all.filter(func(s: CurseStake) -> bool: return s.state == CurseStake.State.UNLIT)
		if not unlit.is_empty():
			var st: CurseStake = unlit.pick_random()
			st.start_mark()
			if _sabotaged() and st == _seventh():   # ASSUMED (v5): "seventh" = the highest stake_id
				st._left = st.mark_time * sabotage_mark_mult
	if not all.is_empty() and all.all(func(s: CurseStake) -> bool: return s.is_lit()):
		_begin_ring()


func _seventh() -> CurseStake:
	var top: CurseStake = null
	for s in stakes():
		if top == null or s.stake_id > top.stake_id:
			top = s
	return top


## v5: with the flag, Jawa Ha puts out every lit stake within sabotage_ha_range (the stake itself reaches 80).
func _on_cast(glyph_id: String, _score: float) -> void:
	if glyph_id != "jawa_ha" or dead or target == null or not _sabotaged():
		return
	for s in stakes():
		if s.is_lit() and s.global_position.distance_to(target.global_position) <= sabotage_ha_range:   # ASSUMED (v5)
			s.put_out()


func _begin_ring() -> void:
	_enter(State.RING)
	_marker = Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 32:
		pts.append(Vector2.from_angle(TAU * i / 32.0) * arena_radius)
	_marker.polygon = pts
	_marker.color = MARKER
	_marker.z_index = -1
	get_parent().add_child(_marker)
	_marker.global_position = _start


## The curse wave: a heavy hit over the whole arena. A dodging player's i-frames refuse it. All stakes go out.
func _wave() -> void:
	waves += 1
	attack_hitbox.global_position = _start
	(attack_hitbox.get_node("Shape") as CollisionShape2D).shape.radius = arena_radius
	attack_hitbox.damage = wave_damage
	attack_hitbox.heavy = true
	attack_hitbox.activate()
	_blast_left = 0.15
	for s in stakes():
		s.state = CurseStake.State.UNLIT
		s._paint()
	_light_t = 0.0


# --- attacks ---

func _enter(s: State) -> void:
	if is_instance_valid(_marker):
		_marker.queue_free()
	_marker = null
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	body.modulate = Color(1.0, 0.45, 0.45) if s in [State.DART_WIND, State.FAN_WIND, State.RING] else Color.WHITE


func _begin_dart(left: int) -> void:
	_enter(State.DART_WIND)
	darts_left = left
	_dir = (target.global_position - global_position).normalized()
	var n := _dir.orthogonal() * 5.0
	_marker = Polygon2D.new()
	_marker.polygon = PackedVector2Array([n, _dir * dart_range + n, _dir * dart_range - n, -n])
	_marker.color = MARKER
	_marker.z_index = -1
	get_parent().add_child(_marker)
	_marker.global_position = global_position


func _start_dart() -> void:
	attacks += 1
	_enter(State.DART)
	_from = global_position
	velocity = _dir * dart_speed
	attack_hitbox.position = Vector2.ZERO
	(attack_hitbox.get_node("Shape") as CollisionShape2D).shape.radius = 8.0
	attack_hitbox.damage = dart_damage
	attack_hitbox.heavy = false
	attack_hitbox.activate()


func _begin_fan() -> void:
	_enter(State.FAN_WIND)
	_dir = (target.global_position - global_position).normalized()


func _fire_fan() -> void:
	attacks += 1
	for i in 3:
		var shot := SHOT.instantiate() as Arrow
		shot.source = self
		shot.damage = fan_damage
		shot.direction = _dir.rotated(deg_to_rad(fan_spread) * (i - 1) / 2.0)
		shot.speed = shot_speed
		shot.max_range = dart_range
		shot.hit_landed.connect(_curse)
		get_parent().add_child(shot)
		shot.global_position = global_position + Vector2(0, -6)


func _curse(hb: Hurtbox) -> void:
	var s := hb.owner.get("status") as Status if hb.owner else null
	if s:
		s.apply(Status.Type.CURSE)


func _on_health(hp: int, max_hp: int) -> void:
	engaged = true   # first hit
	if phase == 1 and hp > 0 and hp * 2 <= max_hp:
		phase = 2
		stake_interval = stake_every_2
		_enter(State.PAUSE)


## Story v5: Laras's sabotage flag is set (Game.has_flag, underscore form).
func _sabotaged() -> bool:
	var g := get_node_or_null("/root/Game")
	return g != null and sabotage_flag != "" and g.has_flag(sabotage_flag)


func _on_flinch() -> void:
	pass   # it floats: no knockback, no flinch


func _on_died() -> void:
	if is_instance_valid(_marker):
		_marker.queue_free()
	for s in stakes():
		s.state = CurseStake.State.UNLIT
		s._paint()
	super()
	# Laid to rest: falls point-down into the earth and goes quiet.
	var tw := body.create_tween().set_parallel()
	tw.tween_property(body, "modulate:a", 0.0, 0.35)
	tw.tween_property(body, "position:y", 8.0, 0.35)
	var events := get_node("/root/Events")
	get_tree().create_timer(0.3).timeout.connect(func() -> void: events.boss_defeated.emit("keris_gandring"))
