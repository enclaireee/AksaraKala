class_name Sandekala extends EnemyBase
## Optional miniboss (bestiary.md). The room darkens while engaged. While any oncor is unlit he fades out
## every few seconds and reappears behind the player with a grabbing wind-up (ground marker, then a hit).
## With all oncor lit he cannot fade, but still chases and grabs when close.
## ponytail: no hold effect on the grab (damage only), no arena-edge pathing.

enum State { IDLE, CHASE, FADING, GONE, WINDUP, GRAB, RECOVER, DEAD }

const GRAB_R := 24.0
const OVERLAY_SIZE := Vector2(368, 192)   # the sande area, 23x12 tiles (tatar_sunda.md)

@export var engage_dist := 140.0      # TUNE
@export var move_speed := 36.0        # TUNE
@export var darken_time := 20.0       # TUNE: seconds to full darkness
@export var max_dark := 0.65          # TUNE: overlay alpha at full darkness, no oncor lit
@export var fade_every := 6.0         # TUNE: seconds in shadow between fades
@export var fade_time := 0.4          # TUNE
@export var gone_time := 1.0          # TUNE
@export var windup := 0.6             # bestiary.md
@export var grab_time := 0.15         # TUNE
@export var recover_time := 0.9       # TUNE
@export var melee_range := 26.0       # TUNE: lit-room grab starts from here
@export var attack_gap := 2.5         # TUNE

var boss_name_key := "BOSS_SANDEKALA"
var engaged := false
var state := State.IDLE
var state_time := 0.0
var fade_timer := 0.0
var gap := 0.0
var dark := 0.0                       # 0..1, how far the darkness has crept
var overlay: Polygon2D

@onready var marker: Polygon2D = $Marker


func _ready() -> void:
	super()
	if is_queued_for_deletion():
		return
	add_to_group("boss")
	marker.polygon = _circle(GRAB_R)
	var ov := Polygon2D.new()
	ov.polygon = PackedVector2Array([-OVERLAY_SIZE / 2.0, Vector2(OVERLAY_SIZE.x, -OVERLAY_SIZE.y) / 2.0,
			OVERLAY_SIZE / 2.0, Vector2(-OVERLAY_SIZE.x, OVERLAY_SIZE.y) / 2.0])
	ov.color = Color(0, 0, 0.05, 0)
	ov.z_index = 50
	ov.global_position = home
	overlay = ov
	get_parent().add_child.call_deferred(ov)
	ov.global_position = home
	tree_exiting.connect(func() -> void: if is_instance_valid(ov): ov.queue_free())


func lit_count() -> int:
	var n := 0
	for o: Oncor in get_tree().get_nodes_in_group("oncor"):
		n += int(o.lit)
	return n


func in_shadow() -> bool:
	for o: Oncor in get_tree().get_nodes_in_group("oncor"):
		if not o.lit:
			return true
	return false


func _tick(delta: float) -> void:
	state_time += delta
	gap -= delta
	if engaged and not dead:
		dark = minf(1.0, dark + delta / darken_time)
	var total := maxi(1, get_tree().get_node_count_in_group("oncor"))
	overlay.color.a = max_dark * dark * (1.0 - float(lit_count()) / total)
	var to_target := Vector2.INF
	if target != null:
		to_target = target.global_position - global_position
	match state:
		State.IDLE:
			if to_target.length() <= engage_dist:
				engaged = true
				_enter(State.CHASE)
		State.CHASE:
			engaged = true
			fade_timer += delta
			var d := to_target.length()
			velocity = to_target / maxf(d, 0.01) * move_speed * slow() if d > melee_range * 0.6 else Vector2.ZERO
			if in_shadow() and fade_timer >= fade_every:
				_enter(State.FADING)
			elif d <= melee_range and gap <= 0.0:
				_enter(State.WINDUP)
		State.FADING:
			modulate.a = 1.0 - state_time / fade_time
			if state_time >= fade_time:
				_enter(State.GONE)
		State.GONE:
			if state_time >= gone_time:
				global_position = _behind_player()
				_enter(State.WINDUP)
		State.WINDUP:
			if state_time >= windup:
				_enter(State.GRAB)
		State.GRAB:
			if state_time >= grab_time:
				_enter(State.RECOVER)
		State.RECOVER:
			if state_time >= recover_time:
				fade_timer = 0.0
				gap = attack_gap
				_enter(State.CHASE)
	move_and_slide()


func _enter(s: State) -> void:
	attack_hitbox.deactivate()
	marker.visible = false
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	match s:
		State.FADING:
			health.set_invincible(1000.0)
			hurtbox.set_deferred("monitorable", false)
		State.GONE:
			modulate.a = 0.0
		State.WINDUP:
			modulate.a = 1.0
			health.invincible_time = 0.0
			hurtbox.set_deferred("monitorable", true)
			marker.visible = true
		State.GRAB:
			attack_hitbox.activate()


## ASSUMED: behind = opposite the player's aim, 28 px out, kept inside the room.
func _behind_player() -> Vector2:
	var dir: Vector2 = target.get("aim_dir") if target.get("aim_dir") != null else Vector2.RIGHT
	var p := target.global_position - dir.normalized() * 28.0
	var half := OVERLAY_SIZE / 2.0 - Vector2(16, 16)
	return Vector2(clampf(p.x, home.x - half.x, home.x + half.x), clampf(p.y, home.y - half.y, home.y + half.y))


func _on_hurt(hitbox: Hitbox) -> void:
	engaged = true
	super(hitbox)


func _on_died() -> void:
	super()
	state = State.DEAD
	marker.visible = false
	modulate.a = 1.0
	get_node("/root/Events").boss_defeated.emit("sandekala")
	if is_instance_valid(overlay):
		create_tween().tween_property(overlay, "color:a", 0.0, 1.0)   # TUNE


static func _circle(r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 16:
		pts.append(Vector2.from_angle(TAU * i / 16.0) * r)
	return pts
