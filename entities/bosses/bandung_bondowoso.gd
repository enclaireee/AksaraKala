class_name BandungBondowoso extends EnemyBase
## Boss: Bandung Bondowoso (bestiary.md "Build spec"). Raises stone pillars; while one stands he takes no damage.
## Dawn beats expose pillars so one hit breaks them; Jawa Ca calls a beat at once. Phase 2: faster pillars, debris.
## Defeat is a kneeling release: EnemyBase death, then Events.boss_defeated.
## The HUD polls: group "boss", health, boss_name_key, engaged, dawn (beat progress 0-1).
# ponytail: spirit builders and the lesung women at the arena edge are visual only and skipped.

enum State { IDLE, CHASE, WINDUP, RECOVER, PAUSE }

const STONE_SPEED := 0.35      # TUNE: stone flight time at the end of a throw wind-up
const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const RISE_MARKER := Color(0.8, 0.8, 0.5, 0.35)
const SHIELD := Color(0.6, 0.85, 1.0)
const PILLAR_SCENE := preload("res://entities/bosses/pillar.tscn")
const SHIELD_HP := 1 << 30

@export var boss_name_key := "BOSS_BANDUNG_BONDOWOSO"
@export var cond := ""                  # Game.check condition; empty = always on
@export var sabotage_flag := "laras_sabotage_bondowoso_pillar"   # HUD boss bar reads this
@export var sabotage_beat_every := 12.0  # TUNE (v5): no keystone, the lesung beat comes this often (spec 20)
@export var sabotage_expose_time := 4.5  # TUNE (v5): pillars stay open this long (spec 3)
@export var speed := 28.0              # TUNE
@export var engage_range := 128.0      # 8 tiles
@export var stomp_range := 48.0        # spec
@export var throw_min := 96.0          # spec
@export var throw_max := 200.0         # spec
@export var throw_windup := 0.9        # spec
@export var stomp_windup := 0.8        # spec
@export var throw_radius := 20.0       # TUNE
@export var stomp_radius := 28.0       # TUNE
@export var throw_damage := 18         # balance.md light hit
@export var stomp_damage := 41         # balance.md heavy hit
@export var recovery := 1.2            # TUNE
@export var pause_time := 1.0          # spec: pause telegraphing phase 2
@export var max_pillars := 3           # spec
@export var pillar_every := 12.0       # spec
@export var pillar_every_2 := 6.0      # spec, phase 2
@export var ring_min := 80.0           # spec
@export var ring_max := 128.0          # spec
@export var player_gap := 32.0         # spec: new pillar at least this far from the player
@export var pillar_gap := 24.0         # ASSUMED: and this far from other pillars
@export var rise_mark := 1.5           # spec
@export var beat_every := 20.0         # spec
@export var expose_time := 3.0         # spec
@export var ca_cooldown := 8.0         # spec
@export var debris_every := 5.0        # spec, phase 2
@export var debris_count := 3          # spec
@export var debris_mark := 0.8         # spec
@export var debris_spread := 48.0      # TUNE: marks land within this of the player
@export var debris_radius := 16.0      # TUNE
@export var debris_damage := 18        # spec

var active := true:   # EliteGuard flips it
	set(v):
		active = v
		if active and is_inside_tree() and pillars.is_empty() and not dead:
			_raise.call_deferred(_ring_spot())
var state := State.IDLE
var state_time := 0.0
var phase := 1
var dawn := 0.0                        # beat progress 0-1, shown on the HUD dawn bar
var engaged := false
var attacks := 0
var pillars: Array[Pillar] = []
var build_interval := 12.0
var shield_flashes := 0
var _start := Vector2.ZERO
var _build_t := 0.0
var _debris_t := 0.0
var _ca_cd := 0.0
var _marks: Array[Dictionary] = []     # {pos, left, marker, kind: "pillar" | "debris"}
var _stomp := false
var _spot := Vector2.ZERO
var _launched := false
var _marker: Polygon2D
var _stone: Polygon2D
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
	_start = global_position
	build_interval = pillar_every
	health.changed.connect(_on_health)
	hurtbox.dodged.connect(_on_shield_hit)
	get_node("/root/Events").spell_cast.connect(_on_cast)
	if active:
		_raise.call_deferred(_ring_spot())   # the fight opens with one pillar


func standing() -> int:
	return pillars.size()


func _tick(delta: float) -> void:
	state_time += delta
	_ca_cd = maxf(0.0, _ca_cd - delta)
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
	if engaged:
		_run_builders(delta)
	for p in pillars:
		p.tick(delta)
	_refresh_shield()
	match state:
		State.IDLE:
			if engaged:
				_enter(State.CHASE)
		State.CHASE:
			if d <= stomp_range:
				_begin_attack(true, target.global_position)
			elif d >= throw_min and d <= throw_max:
				_begin_attack(false, target.global_position)
			else:
				velocity = to_t.normalized() * speed * slow() if d > stomp_range else Vector2.ZERO
		State.WINDUP:
			var wind := stomp_windup if _stomp else throw_windup
			if not _stomp and not _launched and state_time >= wind - STONE_SPEED:
				_launch_stone()
			if state_time >= wind:
				_land()
				_enter(State.RECOVER)
		State.RECOVER:
			if state_time >= recovery:
				_enter(State.CHASE)
		State.PAUSE:
			if state_time >= pause_time:
				_enter(State.CHASE)
	move_and_slide()


# --- pillars, beats, debris ---

func _run_builders(delta: float) -> void:
	_build_t += delta
	if _build_t >= build_interval and standing() + _pending("pillar") < max_pillars:
		_build_t = 0.0
		_mark(_ring_spot(), rise_mark, "pillar")
	if phase == 2:
		_debris_t += delta
		if _debris_t >= debris_every:
			_debris_t = 0.0
			for i in debris_count:
				_mark(target.global_position + Vector2.from_angle(randf() * TAU) * randf() * debris_spread, debris_mark, "debris")
	dawn = minf(1.0, dawn + delta / (sabotage_beat_every if _sabotaged() else beat_every))   # ASSUMED (v5)
	if dawn >= 1.0:
		_beat()
	for m in _marks.duplicate():
		m.left -= delta
		if m.left <= 0.0:
			_marks.erase(m)
			m.marker.queue_free()
			if m.kind == "pillar":
				_raise(m.pos)
			else:
				_drop_debris(m.pos)


func _beat() -> void:
	dawn = 0.0
	for p in pillars:
		p.expose(sabotage_expose_time if _sabotaged() else expose_time)   # ASSUMED (v5)


func _pending(kind: String) -> int:
	return _marks.filter(func(m: Dictionary) -> bool: return m.kind == kind).size()


func _ring_spot() -> Vector2:
	var s := _start
	for i in 20:
		s = _start + Vector2.from_angle(randf() * TAU) * randf_range(ring_min, ring_max)
		var ok := target == null or s.distance_to(target.global_position) >= player_gap
		for p in pillars:
			ok = ok and s.distance_to(p.global_position) >= pillar_gap
		for m in _marks:
			ok = ok and (m.kind != "pillar" or s.distance_to(m.pos) >= pillar_gap)
		if ok:
			break
	return s   # ponytail: after 20 misses take the last try; the arena is open ground


func _raise(pos: Vector2) -> void:
	if dead:
		return
	var p := PILLAR_SCENE.instantiate() as Pillar
	p.position = pos
	get_parent().add_child(p)
	p.global_position = pos
	pillars.append(p)
	p.broken.connect(func(q: Pillar) -> void:
		pillars.erase(q)
		_refresh_shield())
	_refresh_shield()


func _drop_debris(pos: Vector2) -> void:
	var hb := Hitbox.new()
	hb.source = self
	hb.collision_layer = 16
	hb.collision_mask = 2
	hb.damage = debris_damage
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = debris_radius
	cs.shape = c
	hb.add_child(cs)
	get_parent().add_child(hb)
	hb.global_position = pos
	hb.activate()
	get_tree().create_timer(0.15).timeout.connect(hb.queue_free)


func _mark(pos: Vector2, left: float, kind: String) -> void:
	_marks.append({"pos": pos, "left": left, "marker": _make_marker(pos, debris_radius if kind == "debris" else 10.0, RISE_MARKER if kind == "pillar" else MARKER), "kind": kind})


func _make_marker(pos: Vector2, r: float, col: Color) -> Polygon2D:
	var m := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 16:
		pts.append(Vector2.from_angle(TAU * i / 16.0) * r)
	m.polygon = pts
	m.color = col
	m.z_index = -1
	get_parent().add_child(m)
	m.global_position = pos
	return m


## While any pillar stands: no damage. Invincible stops hits (and so hit-stop); the huge shield soaks backstabs and status ticks.
func _refresh_shield() -> void:
	var on := standing() > 0 and not dead
	health.invincible_time = INF if on else 0.0
	health.shield = SHIELD_HP if on else 0


func _on_shield_hit(_hb: Hitbox) -> void:
	shield_flashes += 1
	body.modulate = SHIELD
	body.create_tween().tween_property(body, "modulate", Color.WHITE, 0.12)


## Jawa Ca (the lesung rhythm) anywhere in the arena calls a beat at once.
func _on_cast(glyph_id: String, _score: float) -> void:
	if glyph_id != "jawa_ca" or not engaged or dead or _ca_cd > 0.0:
		return
	_ca_cd = ca_cooldown
	_beat()


# --- attacks (same telegraph as Sangkuriang) ---

func _enter(s: State) -> void:
	_clear_attack()
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	body.modulate = Color(1.0, 0.45, 0.45) if s == State.WINDUP else Color.WHITE


func _begin_attack(stomp: bool, spot: Vector2) -> void:
	_enter(State.WINDUP)
	_stomp = stomp
	_spot = spot
	_launched = false
	_marker = _make_marker(spot, stomp_radius if stomp else throw_radius, MARKER)


func _launch_stone() -> void:
	_launched = true
	var st := Polygon2D.new()
	_stone = st
	st.polygon = PackedVector2Array([-4, -4, 4, -4, 4, 4, -4, 4])
	st.color = Color(0.5, 0.48, 0.45)
	st.z_index = 50
	get_parent().add_child(st)
	var from := global_position + Vector2(0, -20)
	var to := _spot
	var tw := st.create_tween()
	tw.tween_method(func(f: float) -> void:
		st.global_position = from.lerp(to, f) + Vector2(0, -sin(PI * f) * 40.0), 0.0, 1.0, STONE_SPEED)


func _land() -> void:
	attacks += 1
	attack_hitbox.global_position = _spot
	(attack_hitbox.get_node("Shape") as CollisionShape2D).shape.radius = stomp_radius if _stomp else throw_radius
	attack_hitbox.damage = stomp_damage if _stomp else throw_damage
	attack_hitbox.heavy = _stomp
	attack_hitbox.activate()
	_blast_left = 0.15


func _clear_attack() -> void:
	for n: Node in [_marker, _stone]:
		if is_instance_valid(n):
			n.queue_free()
	_marker = null
	_stone = null


func _on_health(hp: int, max_hp: int) -> void:
	engaged = true   # first hit
	if phase == 1 and hp > 0 and hp * 2 <= max_hp:
		phase = 2
		build_interval = pillar_every_2
		_enter(State.PAUSE)


## Story v5: Laras's sabotage flag is set (Game.has_flag, underscore form).
func _sabotaged() -> bool:
	var g := get_node_or_null("/root/Game")
	return g != null and sabotage_flag != "" and g.has_flag(sabotage_flag)


func _on_flinch() -> void:
	pass   # bosses do not flinch


func _on_died() -> void:
	_clear_attack()
	for m in _marks:
		m.marker.queue_free()
	_marks.clear()
	for p in pillars:
		if is_instance_valid(p):
			p.queue_free()
	pillars.clear()
	_refresh_shield()
	super()
	# Released, not killed: stops building, kneels, then announces.
	var tw := body.create_tween().set_parallel()
	tw.tween_property(body, "modulate:a", 0.0, 0.35)
	tw.tween_property(body, "scale:y", 0.6, 0.35)
	var events := get_node("/root/Events")
	get_tree().create_timer(0.3).timeout.connect(func() -> void: events.boss_defeated.emit("bandung_bondowoso"))
