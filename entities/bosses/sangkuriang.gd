class_name Sangkuriang extends EnemyBase
## Boss: Sangkuriang (bestiary.md, balance.md 7). Phase 1 throws logs and slams the ground, both ground-marked.
## Phase 2 (50% HP): dawn fills; at 1 he enrages. Sunda Ca near the hung post is the fake dawn and stuns him.
## Defeat is a release: EnemyBase death (Ilmu, enemy_killed, Game.killed) then Events.boss_defeated.
## The HUD polls: group "boss", health, boss_name_key, engaged, dawn.

enum State { IDLE, CHASE, WINDUP, RECOVER, PAUSE, STUN }

const LOG_SPEED := 0.35        # TUNE: log flight time at the end of a throw wind-up
const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const STUNNED := Color(0.7, 0.75, 1.0)

@export var boss_name_key := "BOSS_SANGKURIANG"
@export var post_id := "east"
@export var speed := 30.0              # TUNE
@export var engage_range := 128.0      # 8 tiles
@export var slam_range := 48.0         # TUNE: slam at or inside this
@export var throw_min := 96.0          # TUNE: throws from this far
@export var throw_max := 200.0         # TUNE
@export var throw_windup := 0.9        # TUNE
@export var slam_windup := 0.8         # TUNE
@export var throw_radius := 20.0       # TUNE
@export var slam_radius := 28.0        # TUNE
@export var throw_damage := 16         # TUNE, balance.md 7 light hit
@export var slam_damage := 36          # TUNE, balance.md 7 heavy hit
@export var recovery := 1.2            # TUNE
@export var dawn_time := 25.0          # TUNE: seconds for dawn 0 to 1
@export var stun_time := 4.0           # TUNE
@export var pause_time := 1.0          # TUNE: pause telegraphing phase 2
@export var post_range := 80.0         # 5 tiles
@export var rage_speed := 0.6          # TUNE: wind-up and recovery multiplier when enraged
@export var rage_damage := 1.5         # TUNE

var state := State.IDLE
var state_time := 0.0
var phase := 1
var dawn := 0.0
var engaged := false
var enraged := false
var attacks := 0
var _slam := false
var _spot := Vector2.ZERO
var _launched := false
var _marker: Polygon2D
var _log: Polygon2D
var _blast_left := 0.0


func _ready() -> void:
	super()
	if dead or is_queued_for_deletion():
		return
	add_to_group("boss")
	health.changed.connect(_on_health)
	get_node("/root/Events").spell_cast.connect(_on_cast)


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
	if phase == 2 and state != State.STUN and state != State.PAUSE:
		dawn = minf(1.0, dawn + delta / dawn_time)
		enraged = dawn >= 1.0
	var k := rage_speed if enraged else 1.0
	match state:
		State.IDLE:
			if engaged:
				_enter(State.CHASE)
		State.CHASE:
			if d <= slam_range:
				_begin_attack(true, target.global_position)
			elif d >= throw_min and d <= throw_max:
				_begin_attack(false, target.global_position)
			else:
				velocity = to_t.normalized() * speed * slow() if d > slam_range else Vector2.ZERO
		State.WINDUP:
			var wind := (slam_windup if _slam else throw_windup) * k
			if not _slam and not _launched and state_time >= wind - LOG_SPEED:
				_launch_log()
			if state_time >= wind:
				_land()
				_enter(State.RECOVER)
		State.RECOVER:
			if state_time >= recovery * k:
				_enter(State.CHASE)
		State.PAUSE:
			if state_time >= pause_time:
				_enter(State.CHASE)
		State.STUN:
			if state_time >= stun_time:
				_enter(State.CHASE)
	move_and_slide()


func _enter(s: State) -> void:
	_clear_attack()
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	body.modulate = STUNNED if s == State.STUN else Color.WHITE
	if s == State.WINDUP:
		body.modulate = Color(1.0, 0.45, 0.45)


func _begin_attack(slam: bool, spot: Vector2) -> void:
	_enter(State.WINDUP)
	_slam = slam
	_spot = spot
	_launched = false
	_marker = Polygon2D.new()
	var r := slam_radius if slam else throw_radius
	var pts := PackedVector2Array()
	for i in 16:
		pts.append(Vector2.from_angle(TAU * i / 16.0) * r)
	_marker.polygon = pts
	_marker.color = MARKER
	_marker.z_index = -1
	get_parent().add_child(_marker)
	_marker.global_position = _spot


func _launch_log() -> void:
	_launched = true
	var lg := Polygon2D.new()
	_log = lg
	lg.polygon = PackedVector2Array([-6, -2, 6, -2, 6, 2, -6, 2])
	lg.color = Color(0.5, 0.33, 0.15)
	lg.z_index = 50
	get_parent().add_child(lg)
	var from := global_position + Vector2(0, -20)
	var to := _spot
	var tw := lg.create_tween()
	tw.tween_method(func(f: float) -> void:
		lg.global_position = from.lerp(to, f) + Vector2(0, -sin(PI * f) * 40.0), 0.0, 1.0, LOG_SPEED)


func _land() -> void:
	attacks += 1
	var big := _slam
	attack_hitbox.global_position = _spot
	(attack_hitbox.get_node("Shape") as CollisionShape2D).shape.radius = slam_radius if big else throw_radius
	attack_hitbox.damage = roundi((slam_damage if big else throw_damage) * (rage_damage if enraged else 1.0))
	attack_hitbox.heavy = big
	attack_hitbox.activate()
	_blast_left = 0.15


func _clear_attack() -> void:
	for n: Node in [_marker, _log]:
		if is_instance_valid(n):
			n.queue_free()
	_marker = null
	_log = null


func _on_health(hp: int, max_hp: int) -> void:
	engaged = true   # first hit
	if phase == 1 and hp > 0 and hp * 2 <= max_hp:
		phase = 2
		_enter(State.PAUSE)


## Fake dawn: Ca with the cloth hung and the player near the post.
func _on_cast(glyph_id: String, _score: float) -> void:
	if glyph_id != "sunda_ca" or phase != 2 or dead or target == null:
		return
	if not get_node("/root/Game").has_flag("post:" + post_id):
		return
	for p: Node in get_tree().get_nodes_in_group("interactable"):
		if p is ArenaPost and p.post_id == post_id and p.global_position.distance_to(target.global_position) <= post_range:
			dawn = 0.0
			enraged = false
			_enter(State.STUN)
			return


func _on_flinch() -> void:
	pass   # bosses do not flinch


func _on_died() -> void:
	_clear_attack()
	super()
	# Released, not killed: kneel and fade, then announce.
	var tw := body.create_tween().set_parallel()
	tw.tween_property(body, "modulate:a", 0.0, 0.35)
	tw.tween_property(body, "scale:y", 0.6, 0.35)
	var events := get_node("/root/Events")
	get_tree().create_timer(0.3).timeout.connect(func() -> void: events.boss_defeated.emit("sangkuriang"))
