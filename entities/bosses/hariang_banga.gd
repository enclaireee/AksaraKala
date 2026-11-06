class_name HariangBanga extends EnemyBase
## Boss: Hariang Banga, the river duel (bestiary.md Story v2). Guard: he faces the player (never turning in a wind-up
## or attack); weapon hits from the front do x0.2. A Jawa Na Dash-strike through him (the Arca check) breaks the
## guard: 2 s stagger, x1.5 damage taken for 3 s. Hits from behind and spells land in full.
## Moves: a 3-cut combo, a lunge, a ground-cut wave. Yields at 15% HP: he never dies; he sheathes, goes inert,
## stays in Game.killed, then Events.boss_defeated. The HUD polls: group "boss", health, boss_name_key, engaged.
# ponytail: the guard refunds hp after the hit lands (Hurtbox applies damage first), as PrajuritTerkutuk does.

enum State { IDLE, CHASE, WINDUP, LUNGE, RECOVER, STAGGER }

const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const STUNNED := Color(0.7, 0.75, 1.0)
const SHOT := preload("res://entities/enemies/spirit_shot.tscn")
const FRONT_HALF := PI / 2.0   # TUNE: the front is a half circle, as the Prajurit's shield

@export var boss_name_key := "BOSS_HARIANG_BANGA"
@export var cond := ""                 # hidden and inert until Game.check(cond) holds (EliteGuard); "" = always
@export var speed := 60.0              # spec
@export var engage_range := 128.0      # 8 tiles
@export var turn_rate := 270.0         # TUNE: degrees per second
@export var guard_mult := 0.2          # spec
@export var open_mult := 1.5           # spec
@export var stagger_time := 2.0        # spec
@export var open_time := 3.0           # spec
@export var yield_at := 15             # spec: HP percent
@export var cut_range := 32.0          # TUNE: starts the combo at or inside this
@export var cut_windup := 0.4          # spec, each cut
@export var cut_reach := 16.0          # TUNE: cut centre ahead of him
@export var cut_radius := 18.0         # TUNE
@export var cut_damage := 15           # spec, light
@export var lunge_windup := 0.5        # spec
@export var lunge_length := 96.0       # spec: 6 tiles
@export var lunge_speed := 320.0       # TUNE
@export var lunge_damage := 20         # spec, heavy
@export var wave_windup := 0.6         # spec
@export var wave_length := 160.0       # spec: 10 tiles
@export var wave_speed := 160.0        # TUNE
@export var wave_damage := 14          # spec, light
@export var rewave_after := 2.0        # TUNE: kept at range this long, he cuts a wave again
@export var recovery := 1.0            # TUNE

var active := true         # EliteGuard
var state := State.IDLE
var state_time := 0.0
var engaged := false
var attacks := 0
var facing := 0.0          # radians
var open_left := 0.0       # guard broken: x1.5 damage taken
var cuts_left := 0
var _move := ""            # "cut", "lunge" or "wave"
var _wave_next := true
var _dir := Vector2.RIGHT
var _from := Vector2.ZERO
var _marker: Polygon2D
var _blast_left := 0.0
var _floored := false      # a raw hit reached 0 hp: no guard refund, he yields


func _ready() -> void:
	super()
	if dead or is_queued_for_deletion():
		return
	add_to_group("boss")
	health.changed.connect(_on_health)
	var g := EliteGuard.new()
	g.cond = cond
	add_child(g)


func _tick(delta: float) -> void:
	state_time += delta
	open_left -= delta
	if _blast_left > 0.0:
		_blast_left -= delta
		if _blast_left <= 0.0:
			attack_hitbox.deactivate()
	if target == null:
		return
	var to_t := target.global_position - global_position
	var d := to_t.length()
	if d <= engage_range:
		engaged = true
	if state in [State.IDLE, State.CHASE, State.RECOVER]:
		var step := deg_to_rad(turn_rate) * delta
		facing += clampf(angle_difference(facing, to_t.angle()), -step, step)
		aim.rotation = facing
	match state:
		State.IDLE:
			if engaged:
				_enter(State.CHASE)
		State.CHASE:
			if d <= cut_range:
				cuts_left = 3
				_begin("cut")
			elif d <= lunge_length:
				_begin("lunge")
			elif d <= wave_length and (_wave_next or state_time >= rewave_after):
				_begin("wave")
			else:
				velocity = to_t.normalized() * speed * slow()
		State.WINDUP:
			if state_time >= {"cut": cut_windup, "lunge": lunge_windup, "wave": wave_windup}[_move]:
				_strike()
		State.LUNGE:
			if global_position.distance_to(_from) >= lunge_length or (state_time > 0.05 and is_on_wall()):
				attack_hitbox.deactivate()
				_enter(State.RECOVER)
		State.RECOVER:
			if state_time >= recovery:
				_enter(State.CHASE)
		State.STAGGER:
			if state_time >= stagger_time:
				_enter(State.CHASE)
	move_and_slide()


func _enter(s: State) -> void:
	if is_instance_valid(_marker):
		_marker.queue_free()
	_marker = null
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	body.modulate = Color(1.0, 0.45, 0.45) if s == State.WINDUP else (STUNNED if s == State.STAGGER else Color.WHITE)


## Wind-up with a marker along his facing: a circle for a cut, a line for the lunge and the wave.
func _begin(move: String) -> void:
	_enter(State.WINDUP)
	_move = move
	_wave_next = move != "wave"
	_dir = Vector2.from_angle(facing)
	_marker = Polygon2D.new()
	var pts := PackedVector2Array()
	if move == "cut":
		for i in 16:
			pts.append(_dir * cut_reach + Vector2.from_angle(TAU * i / 16.0) * cut_radius)
	else:
		var reach := lunge_length if move == "lunge" else wave_length
		var n := _dir.orthogonal() * (8.0 if move == "lunge" else 4.0)
		pts = PackedVector2Array([n, _dir * reach + n, _dir * reach - n, -n])
	_marker.polygon = pts
	_marker.color = MARKER
	_marker.z_index = -1
	get_parent().add_child(_marker)
	_marker.global_position = global_position


func _strike() -> void:
	attacks += 1
	var shape := (attack_hitbox.get_node("Shape") as CollisionShape2D).shape as CircleShape2D
	match _move:
		"cut":
			attack_hitbox.global_position = global_position + _dir * cut_reach
			shape.radius = cut_radius
			attack_hitbox.damage = cut_damage
			attack_hitbox.heavy = false
			attack_hitbox.activate()
			_blast_left = 0.12   # TUNE
			cuts_left -= 1
			if cuts_left > 0:
				_begin("cut")
			else:
				_enter(State.RECOVER)
		"lunge":
			_enter(State.LUNGE)
			_from = global_position
			velocity = _dir * lunge_speed
			attack_hitbox.position = Vector2.ZERO
			shape.radius = 12.0
			attack_hitbox.damage = lunge_damage
			attack_hitbox.heavy = true
			attack_hitbox.activate()
		"wave":
			var shot := SHOT.instantiate() as Arrow
			shot.source = self
			shot.damage = wave_damage
			shot.direction = _dir
			shot.speed = wave_speed
			shot.max_range = wave_length
			shot.modulate = Color(0.6, 0.85, 1.0)   # ponytail: a recolored spirit shot until the wave has art
			get_parent().add_child(shot)
			shot.global_position = global_position
			_enter(State.RECOVER)


func _stop_attack() -> void:
	attack_hitbox.deactivate()
	_blast_left = 0.0


# --- guard ---

func _on_hurt(hitbox: Hitbox) -> void:
	if dead:
		return
	var path := (hitbox.get_script() as Script).resource_path if hitbox.get_script() != null else ""
	var from := hitbox.global_position
	if hitbox.source is Node2D:
		from = (hitbox.source as Node2D).global_position
	var front := absf(angle_difference(facing, (from - global_position).angle())) < FRONT_HALF
	var mult := 1.0
	if open_left > 0.0:
		mult = open_mult
	elif front and not path.begins_with("res://spells/"):
		mult = guard_mult
	super(hitbox)
	if mult < 1.0 and not _floored:
		health.heal(roundi(hitbox.damage * (1.0 - mult)))
	elif mult > 1.0:
		health.take_damage(roundi(hitbox.damage * (mult - 1.0)), hitbox.source, true)
	if path.ends_with("dash_strike.gd") and open_left <= 0.0 and not dead:
		_stop_attack()
		open_left = open_time
		_enter(State.STAGGER)


func _on_health(hp: int, max_hp: int) -> void:
	engaged = true   # first hit
	if hp * 100 <= max_hp * yield_at:
		_check_yield.call_deferred()   # after _on_hurt's guard refund


func _check_yield() -> void:
	if not dead and health.hp * 100 <= health.max_hp * yield_at:
		_yield()


func _on_flinch() -> void:
	pass   # bosses do not flinch


## A hit that would kill him leaves 1 hp: he yields instead (the deferred check from _on_health follows).
## ponytail: judged on the raw hit, so a guarded blow bigger than his hp yields him; no hit comes near 15% of 2800.
func _on_died() -> void:
	health.hp = 1
	_floored = true


## EnemyBase death minus the free and enemy_killed: he stops, sheathes and stays, inert.
func _yield() -> void:
	_stop_attack()
	_enter(State.RECOVER)
	dead = true
	engaged = false
	remove_from_group("enemy")
	remove_from_group("boss")
	health.invincible_time = INF
	hurtbox.set_deferred("monitorable", false)
	aim.visible = false   # ponytail: the blade vanishing is the sheathe, placeholder
	var game := get_node("/root/Game")
	game.add_ilmu(ilmu)
	if unique_id != "":
		game.killed.append(unique_id)
		game.save_game()
	_float_label()
	var events := get_node("/root/Events")
	get_tree().create_timer(0.3).timeout.connect(func() -> void: events.boss_defeated.emit("hariang_banga"))
