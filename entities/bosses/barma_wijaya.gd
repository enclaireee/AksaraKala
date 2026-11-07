class_name BarmaWijaya extends EnemyBase
## Boss: Prabu Barma Wijaya, the false king (bestiary.md Story v2). Moves: a kris thrust and a fan of 3 kris-darts.
## Glamour at 70% and 35% HP: 3 copies of this scene (copy = true) spread out with him over 1 s. Copies are always
## invincible: a weapon hit flickers through (Hurtbox.dodged), a spell (any script under res://spells/) breaks one.
## While a copy stands he is invincible too; the last break stuns him 3 s.
## Defeat: he never dies. At 0 HP he kneels, goes inert, stays in Game.killed, then Events.boss_defeated.
## The HUD polls: group "boss", health, boss_name_key, engaged.

enum State { IDLE, CHASE, WINDUP, THRUST, RECOVER, GLAMOUR, STUN }

const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const STUNNED := Color(0.7, 0.75, 1.0)
const SHOT := preload("res://entities/enemies/spirit_shot.tscn")
const MARKS := [70, 35]   # spec: glamour at these HP percents
const COPIES := 3         # spec

@export var boss_name_key := "BOSS_BARMA_WIJAYA"
@export var sabotage_flag := "laras_sabotage_glamour_seal"   # HUD boss bar reads this
@export var sabotage_stun_bonus := 1.5  # TUNE (v5): signet wax stolen, the stun after the last copy breaks lasts this much longer
@export var cond := ""                 # hidden and inert until Game.check(cond) holds (EliteGuard); "" = always
@export var speed := 45.0              # spec
@export var engage_range := 128.0      # 8 tiles
@export var thrust_windup := 0.4       # spec
@export var thrust_length := 48.0      # spec: 3 tiles
@export var thrust_speed := 260.0      # TUNE
@export var thrust_damage := 14        # spec, light
@export var fan_windup := 0.6          # spec
@export var fan_damage := 12           # spec, light, each dart
@export var fan_spread := 30.0         # TUNE, degrees
@export var fan_range := 200.0         # TUNE
@export var shot_speed := 120.0        # TUNE
@export var refan_after := 2.0         # TUNE: kept out of thrust range this long, he fans again
@export var recovery := 1.0            # TUNE
@export var glamour_time := 1.0        # spec: the shuffle
@export var glamour_radius := 48.0     # TUNE: the 4 figures end on this ring
@export var stun_time := 3.0           # spec
@export var copy_mult := 0.5           # spec: copies hit for half

var copy := false          # set before add_child: a glamour copy
var real: BarmaWijaya      # a copy's king
var copies: Array[BarmaWijaya] = []
var active := true         # EliteGuard
var state := State.IDLE
var state_time := 0.0
var engaged := false
var attacks := 0
var glamours := 0
var _fan := false
var _fan_next := true
var _dir := Vector2.RIGHT
var _from := Vector2.ZERO
var _marker: Node2D


func _ready() -> void:
	super()
	if dead or is_queued_for_deletion():
		return
	hurtbox.dodged.connect(_on_dodged)
	if copy:
		engaged = true
		health.invincible_time = INF   # ponytail: INF never counts down, so a copy is never hurt
		_enter(State.GLAMOUR)
		return
	add_to_group("boss")
	health.changed.connect(_on_health)
	var g := EliteGuard.new()
	g.cond = cond
	add_child(g)


func _tick(delta: float) -> void:
	state_time += delta
	if target == null:
		return
	var to_t := target.global_position - global_position
	var d := to_t.length()
	if d <= engage_range:
		engaged = true
	match state:
		State.IDLE:
			if engaged:
				_enter(State.CHASE)
		State.CHASE:
			if d <= thrust_length:
				_begin(false, to_t)
			elif d <= fan_range and (_fan_next or state_time >= refan_after):
				_begin(true, to_t)
			else:
				velocity = to_t.normalized() * speed * slow()
		State.WINDUP:
			if state_time >= (fan_windup if _fan else thrust_windup):
				if _fan:
					_fire_fan()
					_enter(State.RECOVER)
				else:
					_start_thrust()
		State.THRUST:
			if global_position.distance_to(_from) >= thrust_length or (state_time > 0.05 and is_on_wall()):
				_enter(State.RECOVER)
		State.RECOVER:
			if state_time >= recovery:
				_enter(State.CHASE)
		State.GLAMOUR:
			if state_time >= glamour_time:
				_enter(State.CHASE)
		State.STUN:
			if state_time >= stun_time + (sabotage_stun_bonus if (_sabotaged() and not copy) else 0.0):   # ASSUMED (v5)
				_enter(State.CHASE)
	move_and_slide()


func _enter(s: State) -> void:
	if is_instance_valid(_marker):
		_marker.queue_free()
	_marker = null
	attack_hitbox.deactivate()
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	body.modulate = Color(1.0, 0.45, 0.45) if s == State.WINDUP else (STUNNED if s == State.STUN else Color.WHITE)


func _dmg(n: int) -> int:
	return roundi(n * (copy_mult if copy else 1.0))


# --- attacks ---

## Wind-up with line markers: one along the thrust, three along the fan.
func _begin(fan: bool, to_t: Vector2) -> void:
	_enter(State.WINDUP)
	_fan = fan
	_fan_next = not fan
	_dir = to_t.normalized()
	_marker = Node2D.new()
	for i in (3 if fan else 1):
		var p := Polygon2D.new()
		var dir := _dir.rotated(deg_to_rad(fan_spread) * (i - 1) / 2.0) if fan else _dir
		var reach := fan_range if fan else thrust_length
		var n := dir.orthogonal() * 4.0
		p.polygon = PackedVector2Array([n, dir * reach + n, dir * reach - n, -n])
		p.color = MARKER
		_marker.add_child(p)
	_marker.z_index = -1
	get_parent().add_child(_marker)
	_marker.global_position = global_position


func _start_thrust() -> void:
	attacks += 1
	_enter(State.THRUST)
	_from = global_position
	velocity = _dir * thrust_speed
	attack_hitbox.position = Vector2.ZERO
	attack_hitbox.damage = _dmg(thrust_damage)
	attack_hitbox.heavy = false
	attack_hitbox.activate()


func _fire_fan() -> void:
	attacks += 1
	for i in 3:
		var shot := SHOT.instantiate() as Arrow
		shot.source = self
		shot.damage = _dmg(fan_damage)
		shot.direction = _dir.rotated(deg_to_rad(fan_spread) * (i - 1) / 2.0)
		shot.speed = shot_speed
		shot.max_range = fan_range
		shot.modulate = Color(0.75, 0.75, 0.8)   # ponytail: a recolored spirit shot until darts have art
		get_parent().add_child(shot)
		shot.global_position = aim.global_position


# --- glamour ---

func _on_health(hp: int, max_hp: int) -> void:
	engaged = true   # first hit
	if glamours < MARKS.size() and hp > 0 and hp * 100 <= max_hp * MARKS[glamours]:
		glamours += 1
		health.invincible_time = INF
		_enter(State.GLAMOUR)
		_glamour.call_deferred()   # ponytail: deferred, the hit can come mid physics query


## 3 copies appear on him, then all 4 figures move to shuffled spots on a ring over glamour_time.
func _glamour() -> void:
	var figs: Array[Node2D] = [self]
	var scene := load(scene_file_path) as PackedScene
	for i in COPIES:
		var c := scene.instantiate() as BarmaWijaya
		c.copy = true
		c.real = self
		c.unique_id = ""
		c.ilmu = 0
		c.position = position
		get_parent().add_child(c)
		copies.append(c)
		figs.append(c)
	figs.shuffle()
	var at := global_position
	for i in figs.size():
		var spot := at + Vector2.from_angle(TAU * (i + 0.5) / figs.size()) * glamour_radius
		figs[i].create_tween().tween_property(figs[i], "global_position", spot, glamour_time)


## Invincible figures (copies always, the king during glamour): weapons flicker through, a cast glyph breaks a copy.
func _on_dodged(hitbox: Hitbox) -> void:
	if copy and hitbox.get_script() != null and (hitbox.get_script() as Script).resource_path.begins_with("res://spells/"):
		_break()
		return
	body.modulate.a = 0.3
	body.create_tween().tween_property(body, "modulate:a", 1.0, 0.15)


func _break() -> void:
	if dead:
		return
	_enter(State.STUN)
	dead = true
	remove_from_group("enemy")
	hurtbox.set_deferred("monitorable", false)
	if is_instance_valid(real):
		real._copy_broken(self)
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.3)   # ponytail: a fade until the true-face reveal has art
	tw.tween_callback(queue_free)


func _copy_broken(c: BarmaWijaya) -> void:
	copies.erase(c)
	if copies.is_empty() and not dead:
		health.invincible_time = 0.0
		_enter(State.STUN)


## Story v5: Laras's sabotage flag is set (Game.has_flag, underscore form).
func _sabotaged() -> bool:
	var g := get_node_or_null("/root/Game")
	return g != null and sabotage_flag != "" and g.has_flag(sabotage_flag)


func _on_flinch() -> void:
	pass   # bosses do not flinch


## Never dies: EnemyBase death minus the free and enemy_killed. Kneels and stays, inert.
func _on_died() -> void:
	if dead:
		return
	_enter(State.STUN)
	dead = true
	engaged = false
	remove_from_group("enemy")
	remove_from_group("boss")
	hurtbox.set_deferred("monitorable", false)
	body.modulate = Color(0.75, 0.7, 0.65)
	body.create_tween().tween_property(body, "scale:y", 0.7, 0.35)   # ponytail: one knee, placeholder
	var game := get_node("/root/Game")
	game.add_ilmu(ilmu)
	if unique_id != "":
		game.killed.append(unique_id)
		game.save_game()
	_float_label()
	var events := get_node("/root/Events")
	get_tree().create_timer(0.3).timeout.connect(func() -> void: events.boss_defeated.emit("barma_wijaya"))
