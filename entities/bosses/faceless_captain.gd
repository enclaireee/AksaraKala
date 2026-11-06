class_name FacelessCaptain extends EnemyBase
## Boss: the Faceless Captain (bestiary.md Story v2). Spear sweep and lunge, both with a wind-up marker.
## Muster at 66% and 33% HP: 2 Faceless with a ground warning. Ca Burst during the muster wind-up breaks it: no adds, stun.
## Defeat: EnemyBase death, then Events.boss_defeated("faceless_captain").
## The HUD polls: group "boss", health, boss_name_key, engaged.

enum State { IDLE, CHASE, WINDUP, DASH, RECOVER, MUSTER, STUN }

const BURST := preload("res://spells/burst.gd")
const FACELESS := "res://entities/enemies/faceless.tscn"
const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const STUNNED := Color(0.7, 0.75, 1.0)
const MUSTER_AT := [0.66, 0.33]
const WARN := 0.5                    # TUNE: ground warning for the adds, as Encounter.WARN

@export var boss_name_key := "BOSS_FACELESS_CAPTAIN"
@export var cond := ""                   # Game.check condition; empty = always on
@export var speed := 40.0                # spec
@export var engage_range := 128.0        # 8 tiles
@export var sweep_range := 40.0          # spec: arc radius
@export var sweep_arc := 120.0           # spec, degrees
@export var sweep_windup := 0.5          # spec
@export var sweep_damage := 18           # spec, heavy
@export var lunge_len := 96.0            # spec: 6 tiles
@export var lunge_windup := 0.6          # spec
@export var lunge_time := 0.25           # TUNE: dash duration
@export var lunge_damage := 16           # spec, heavy
@export var recovery := 0.9              # TUNE
@export var muster_windup := 1.2         # spec
@export var stun_time := 2.0             # spec
@export var add_offset := 72.0           # TUNE: adds appear this far left and right of the lair spot

var active := true   # EliteGuard flips it
var state := State.IDLE
var state_time := 0.0
var phase := 1
var engaged := false
var attacks := 0
var _lunge := false
var _muster_due := 0
var _facing := Vector2.RIGHT
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
	match state:
		State.IDLE:
			if engaged:
				_enter(State.CHASE)
		State.CHASE:
			if target == null:
				pass
			elif _muster_due > 0:
				_muster_due -= 1
				_begin_muster()
			elif d <= sweep_range:
				_begin_attack(false, to_t)
			elif d <= lunge_len + 16.0 and d > sweep_range + 16.0:
				_begin_attack(true, to_t)
			else:
				velocity = to_t.normalized() * speed * slow()
		State.WINDUP:
			if state_time >= (lunge_windup if _lunge else sweep_windup):
				if _lunge:
					attacks += 1
					_enter(State.DASH)
					_strike(CircleShape2D.new(), Vector2(10, 0), lunge_damage)
					velocity = _facing * lunge_len / lunge_time
				else:
					_land_sweep()
					_enter(State.RECOVER)
		State.DASH:
			if state_time >= lunge_time:
				attack_hitbox.deactivate()
				_enter(State.RECOVER)
		State.RECOVER:
			if state_time >= recovery:
				_enter(State.CHASE)
		State.MUSTER:
			if state_time >= muster_windup:
				_call_adds()
				_enter(State.RECOVER)
		State.STUN:
			if state_time >= stun_time:
				_enter(State.CHASE)
	move_and_slide()


func _enter(s: State) -> void:
	_clear_attack()
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	if s == State.STUN:
		attack_hitbox.deactivate()
	body.modulate = STUNNED if s == State.STUN else (Color(1.0, 0.45, 0.45) if s in [State.WINDUP, State.MUSTER] else Color.WHITE)


func _begin_attack(lunge: bool, to_t: Vector2) -> void:
	_enter(State.WINDUP)
	_lunge = lunge
	_facing = to_t.normalized()
	aim.rotation = _facing.angle()
	if lunge:
		_show(PackedVector2Array([Vector2(0, -6), Vector2(lunge_len, -6), Vector2(lunge_len, 6), Vector2(0, 6)]))
	else:
		_show(Player._arc(sweep_arc, sweep_range))


func _begin_muster() -> void:
	_enter(State.MUSTER)
	var pts := PackedVector2Array()
	for i in 16:
		pts.append(Vector2.from_angle(TAU * i / 16.0) * 20.0)
	aim.rotation = 0.0
	_show(pts)


## Wind-up marker: a red shape under Aim (so it turns with the attack).
func _show(pts: PackedVector2Array) -> void:
	_marker = Polygon2D.new()
	_marker.polygon = pts
	_marker.color = MARKER
	_marker.z_index = -1
	aim.add_child(_marker)


func _land_sweep() -> void:
	attacks += 1
	var cs := ConvexPolygonShape2D.new()
	cs.points = Player._arc(sweep_arc, sweep_range)
	_strike(cs, Vector2.ZERO, sweep_damage)
	_blast_left = 0.15


func _strike(shape: Shape2D, at: Vector2, dmg: int) -> void:
	if shape is CircleShape2D:
		(shape as CircleShape2D).radius = 12.0
	(attack_hitbox.get_node("Shape") as CollisionShape2D).shape = shape
	attack_hitbox.position = at
	attack_hitbox.damage = dmg
	attack_hitbox.heavy = true
	attack_hitbox.activate()


func _clear_attack() -> void:
	if is_instance_valid(_marker):
		_marker.queue_free()
	_marker = null


## Warning rings first, the Faceless drop in after WARN.
func _call_adds() -> void:
	var marks: Array[Node] = []
	var spots: Array[Vector2] = []
	for sx in [-1.0, 1.0]:
		var at := home + Vector2(sx * add_offset, 0)
		spots.append(at)
		var m := Polygon2D.new()
		var pts := PackedVector2Array()
		for i in 12:
			pts.append(Vector2.from_angle(TAU * i / 12.0) * Vector2(7, 4))
		m.polygon = pts
		m.color = MARKER
		m.position = at
		m.z_index = -1
		get_parent().add_child(m)
		marks.append(m)
	get_tree().create_timer(WARN, false).timeout.connect(_spawn_adds.bind(marks, spots))


func _spawn_adds(marks: Array[Node], spots: Array[Vector2]) -> void:
	for m in marks:
		if is_instance_valid(m):
			m.queue_free()
	if dead or not is_inside_tree():
		return
	for at in spots:
		var n: Node2D = (load(FACELESS) as PackedScene).instantiate()
		n.position = at
		get_parent().add_child(n)


func _on_health(hp: int, max_hp: int) -> void:
	engaged = true   # first hit
	while phase <= MUSTER_AT.size() and hp > 0 and hp <= max_hp * MUSTER_AT[phase - 1]:
		phase += 1
		_muster_due += 1


## Ca Burst during the muster wind-up breaks it.
func _on_hurt(hitbox: Hitbox) -> void:
	if state == State.MUSTER and hitbox.get_script() == BURST:
		get_node("/root/Events").weakness_triggered.emit(kind)
		_enter(State.STUN)
	super(hitbox)


func _on_flinch() -> void:
	pass   # bosses do not flinch


func _on_died() -> void:
	_clear_attack()
	super()
	var tw := body.create_tween().set_parallel()
	tw.tween_property(body, "modulate:a", 0.0, 0.35)   # the mask cracks and fades
	var events := get_node("/root/Events")
	get_tree().create_timer(0.3).timeout.connect(func() -> void: events.boss_defeated.emit("faceless_captain"))
