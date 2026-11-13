class_name BandungBondowoso extends EnemyBase
## Boss: Bandung Bondowoso (bestiary.md "Build spec"). Raises stone pillars; while one stands he takes no damage.
## Dawn beats expose pillars so one hit breaks them; Jawa Ca calls a beat at once. Phase 2: faster pillars, debris.
## Moves: boulder throw, stomp, golem fist (cone), seismic quake (stomp + two waves), pillar crush (stones drop on
## markers), leap slam (jump + shockwave), and the limit break Thousand Temples (phase 2: lanes of stone spikes, one safe lane).
## Defeat is a kneeling release: EnemyBase death, then Events.boss_defeated.
## The HUD polls: group "boss", health, boss_name_key, engaged, dawn (beat progress 0-1).
# ponytail: spirit builders and the lesung women at the arena edge are visual only and skipped.

enum State { IDLE, CHASE, WINDUP, RECOVER, PAUSE, ACT }

const STONE_SPEED := 0.35      # TUNE: stone flight time at the end of a throw wind-up
const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const RISE_MARKER := Color(0.8, 0.8, 0.5, 0.35)
const SHIELD := Color(0.6, 0.85, 1.0)
const PILLAR_SCENE := preload("res://entities/bosses/pillar.tscn")
const SHIELD_HP := 1 << 30
const STONE := Color(0.62, 0.58, 0.5)
const HEAVY: Array[String] = ["stomp", "fist", "quake", "pillar_crush", "leap", "temples"]
const TEMPLE_GAP := 36.0       # lane spacing of Thousand Temples
const TEMPLE_HALF := 150.0     # half length of a lane

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
@export var recovery_heavy := 2.4      # TUNE: the punish window after a heavy move
@export var shard_damage := 10         # TUNE: phase 2 boulders burst into shards
@export var fist_windup := 0.8         # TUNE
@export var fist_reach := 76.0         # TUNE
@export var fist_arc := 1.3            # TUNE
@export var fist_damage := 32          # TUNE: heavy
@export var quake_windup := 0.9        # TUNE
@export var quake_damage := 30         # TUNE: the stomp itself
@export var quake_wave_damage := 20    # TUNE: each wave, light
@export var quake_radius := 190.0      # TUNE: how far the waves run
@export var crush_windup := 1.0        # TUNE
@export var crush_radius := 22.0       # TUNE
@export var crush_damage := 30         # TUNE: heavy
@export var crush_count := 3           # TUNE: phase 2 adds 2
@export var leap_windup := 1.0         # TUNE: the landing marker
@export var leap_time := 0.45          # TUNE: airtime
@export var leap_radius := 30.0        # TUNE
@export var leap_damage := 41          # TUNE: heavy
@export var leap_wave_damage := 18     # TUNE
@export var temple_windup := 1.6       # TUNE: limit break, long telegraph
@export var temple_windup_2 := 1.0     # TUNE: the second sweep
@export var temple_damage := 50        # TUNE: ~1.2x heavy, one safe lane
@export var temple_cooldown := 26.0    # TUNE

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
var _marker: Node2D
var _stone: Polygon2D
var moves_used: Dictionary = {}   # move name -> times begun
var _move := ""
var _deck: Array[String] = []
var _last_move := ""
var _stage := 0
var _sub := 0.0
var _rec := 1.2
var _count := 0
var _ult_cd := 0.0
var _axis_h := true
var _safe := 0
var _from := Vector2.ZERO
var _body0 := Vector2.ZERO
var _spots: Array[Vector2] = []
var _tg: Array[Node2D] = []


func _ready() -> void:
	super()
	if dead or is_queued_for_deletion():
		return
	_body0 = body.position
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
	_ult_cd = maxf(0.0, _ult_cd - delta)
	var to_t := Vector2.INF
	if target != null:
		to_t = target.global_position - global_position
	var d := to_t.length()
	if d <= engage_range and BossKit.may_engage(self):
		engaged = true
	if engaged:
		_run_builders(delta)
	for p in pillars:
		p.tick(delta)
		if engaged and not dead:
			BossKit.mark(self, p, "" if p.is_exposed() else "jawa_ca", 2.0, 18.0)
	if engaged and standing() > 0 and not dead:
		BossKit.hint(self, "BOSS_HINT_BANDUNG")
	_refresh_shield()
	match state:
		State.IDLE:
			if engaged:
				_enter(State.CHASE)
		State.CHASE:
			var m := _pick(d)
			if m != "":
				_begin_move(m)
			elif d > stomp_range:
				velocity = to_t.normalized() * speed * slow()
		State.WINDUP:
			var wind := stomp_windup if _stomp else throw_windup
			if not _stomp and not _launched and state_time >= wind - STONE_SPEED:
				_launch_stone()
			if state_time >= wind:
				_land()
				_finish(recovery_heavy if _stomp else recovery)
		State.ACT:
			_act(delta)
		State.RECOVER:
			if state_time >= _rec:
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


# --- the move deck ---

func _enter(s: State) -> void:
	if s == State.RECOVER and _rec >= recovery_heavy:
		BossKit.open(self, _rec)
	_clear_attack()
	BossKit.anim_stop(self)
	body.position = _body0   # a leap in the air ends on the ground
	body.scale = Vector2.ONE
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	body.modulate = Color(1.0, 0.45, 0.45) if s == State.WINDUP else Color.WHITE


func _finish(rec: float) -> void:
	_rec = rec
	_enter(State.RECOVER)


func _goto(stage: int) -> void:
	_stage = stage
	_sub = 0.0


func _refill() -> void:
	_deck.clear()
	var names: Array[String] = ["boulder", "stomp", "fist", "quake", "pillar_crush", "leap"]
	_deck.append_array(names)
	_deck.shuffle()


func _ok(m: String, d: float) -> bool:
	if m in HEAVY and m == _last_move:
		return false
	match m:
		"boulder":
			return d >= throw_min and d <= throw_max
		"stomp":
			return d <= stomp_range
		"fist":
			return d <= fist_reach + 8.0
		"quake":
			return d <= 190.0
		"pillar_crush":
			return d <= 200.0
		"leap":
			return d >= 70.0 and d <= 200.0
	return false


## Next move by distance and phase: Thousand Temples when ready, else the first fitting card of the shuffled deck.
func _pick(d: float) -> String:
	if phase == 2 and _ult_cd <= 0.0 and d <= 220.0:
		return "temples"
	for attempt in 2:
		for i in _deck.size():
			var m: String = _deck[i]
			if _ok(m, d):
				_deck.remove_at(i)
				return m
		if attempt == 0:
			_refill()
	return ""


func _begin_move(m: String) -> void:
	_move = m
	_last_move = m
	moves_used[m] = int(moves_used.get(m, 0)) + 1
	attacks += 1
	match m:
		"boulder":
			_begin_attack(false, target.global_position)
		"stomp":
			_begin_attack(true, target.global_position)
		"fist":
			_enter(State.ACT)
			var ang := (target.global_position - global_position).angle()
			_spot = Vector2.from_angle(ang)   # the aim, kept as a direction
			var c := BossKit.telegraph_cone(self, global_position, ang, fist_arc, fist_reach, fist_windup, BossKit.RED)
			c.follow = self
			_tg.append(c)
			BossKit.anim(self, "slam", 10.0, false)
			_goto(0)
		"quake":
			_enter(State.ACT)
			var r := BossKit.telegraph_circle(self, global_position, 44.0, quake_windup, BossKit.RED)
			r.follow = self
			_tg.append(r)
			BossKit.anim(self, "slam", 10.0, false)
			_goto(0)
		"pillar_crush":
			_enter(State.ACT)
			_crush_mark()
		"leap":
			_enter(State.ACT)
			_spot = target.global_position
			_from = global_position
			_tg.append(BossKit.telegraph_circle(self, _spot, leap_radius, leap_windup, BossKit.RED))
			BossKit.anim(self, "cast", 10.0, false)
			_goto(0)
		"temples":
			_ult_cd = temple_cooldown
			_enter(State.ACT)
			BossKit.roar(self, STONE, 90.0)
			_temples_mark(temple_windup, true)
		_:
			_finish(recovery)


func _act(delta: float) -> void:
	_sub += delta
	match _move:
		"fist":
			_act_fist()
		"quake":
			_act_quake()
		"pillar_crush":
			_act_crush()
		"leap":
			_act_leap()
		"temples":
			_act_temples()
		_:
			_finish(recovery)


# --- boulder and stomp (WINDUP, then _land) ---

func _begin_attack(stomp: bool, spot: Vector2) -> void:
	_enter(State.WINDUP)
	_stomp = stomp
	_spot = spot
	_launched = false
	_marker = BossKit.telegraph_circle(self, spot, stomp_radius if stomp else throw_radius, stomp_windup if stomp else throw_windup, BossKit.RED)
	BossKit.anim(self, "slam" if stomp else "cast", 10.0, false)


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
	var radius := stomp_radius if _stomp else throw_radius
	BossKit.strike_circle(self, _spot, radius, stomp_damage if _stomp else throw_damage, _stomp, STONE)
	BossKit.shake(self, 2.5 if _stomp else 1.5, 0.25)
	if _stomp:
		BossKit.punch(self, 1.12, 0.9, 0.25)
	elif phase == 2:
		var base := randf() * TAU
		for i in 6:   # phase 2: the boulder bursts into shards
			BossKit.shoot(self, _spot, base + TAU * float(i) / 6.0, 100.0, shard_damage, STONE, "shard", 4.0, 0.8)


func _clear_attack() -> void:
	for n: Node in [_marker, _stone]:
		if is_instance_valid(n):
			n.queue_free()
	_marker = null
	_stone = null
	for tg in _tg:
		if is_instance_valid(tg):
			tg.queue_free()
	_tg.clear()


# --- golem fist: a wide cone ---

func _act_fist() -> void:
	match _stage:
		0:
			if _sub >= fist_windup:
				BossKit.strike_cone(self, global_position, _spot.angle(), fist_arc, fist_reach, fist_damage, true, STONE)
				BossKit.punch(self, 1.15, 0.9, 0.25)
				BossKit.shake(self, 2.5, 0.25)
				_goto(1)
		1:
			if _sub >= 0.15:
				_finish(recovery_heavy)


# --- seismic quake: a stomp in place, then two waves that run out ---

func _act_quake() -> void:
	match _stage:
		0:
			if _sub >= quake_windup:
				BossKit.strike_circle(self, global_position, 44.0, quake_damage, true, STONE)
				BossKit.shake(self, 3.0, 0.4)
				BossKit.punch(self, 1.15, 0.88, 0.3)
				BossKit.wave(self, global_position, quake_radius, 120.0, quake_wave_damage, STONE, false)
				_goto(1)
		1:
			if _sub >= 0.8:
				BossKit.wave(self, global_position, quake_radius, 120.0, quake_wave_damage, STONE, false)
				BossKit.shake(self, 2.0, 0.3)
				_goto(2)
		2:
			if _sub >= 1.0:
				_finish(recovery_heavy)


# --- pillar crush: stones fall on the markers ---

func _crush_mark() -> void:
	_spots.clear()
	var feet := target.global_position
	_spots.append(feet)
	var n := crush_count + (2 if phase == 2 else 0)
	for i in range(1, n):
		_spots.append(feet + Vector2.from_angle(randf() * TAU) * randf_range(28.0, 84.0))
	for s in _spots:
		_tg.append(BossKit.telegraph_circle(self, s, crush_radius, crush_windup, BossKit.RED))
	BossKit.anim(self, "cast", 10.0, false)
	_goto(0)


func _act_crush() -> void:
	match _stage:
		0:
			if _sub >= crush_windup:
				var hit := false
				var p := BossKit.player_point(self)
				for s in _spots:
					BossKit.sparks(self, s, STONE, 12, 80.0, 0.45, 120.0)
					BossKit.ring_fx(self, s, crush_radius, 0.3, STONE)
					if BossKit.in_circle(p, s, crush_radius):
						hit = true
				if hit:
					BossKit.hurt_player(self, crush_damage, true)
				BossKit.shake(self, 2.5, 0.3)
				_goto(1)
		1:
			if _sub >= 0.3:
				_finish(recovery_heavy)


# --- leap slam: marker, jump, land with a shockwave ---

func _act_leap() -> void:
	match _stage:
		0:
			body.scale = Vector2(1.0, lerpf(1.0, 0.85, clampf(_sub / leap_windup, 0.0, 1.0)))
			if _sub >= leap_windup:
				body.scale = Vector2.ONE
				_from = global_position
				BossKit.ghost(self, STONE, 0.4)
				_goto(1)
		1:
			var f := clampf(_sub / leap_time, 0.0, 1.0)
			global_position = _from.lerp(_spot, f)
			body.position = _body0 + Vector2(0, -sin(PI * f) * 36.0)
			if f >= 1.0:
				global_position = _spot
				body.position = _body0
				BossKit.strike_circle(self, _spot, leap_radius, leap_damage, true, STONE)
				BossKit.wave(self, _spot, 120.0, 130.0, leap_wave_damage, STONE, false)
				BossKit.punch(self, 1.2, 0.85, 0.3)
				BossKit.shake(self, 3.0, 0.4)
				_goto(2)
		2:
			if _sub >= 0.2:
				_finish(recovery_heavy)


# --- Thousand Temples (limit break): lanes of stone spikes rise across the arena, one lane is safe ---

func _lane_ends(k: int) -> Array[Vector2]:
	var ax := Vector2.RIGHT if _axis_h else Vector2.DOWN
	var c := _spot + ax.orthogonal() * TEMPLE_GAP * float(k)
	var out: Array[Vector2] = [c - ax * TEMPLE_HALF, c + ax * TEMPLE_HALF]
	return out


func _temples_mark(life: float, first: bool) -> void:
	var feet := target.global_position
	if first:
		_spot = feet
		_axis_h = randf() < 0.5
	var nx := (Vector2.RIGHT if _axis_h else Vector2.DOWN).orthogonal()
	var pk := clampi(roundi((feet - _spot).dot(nx) / TEMPLE_GAP), -3, 3)
	var cand: Array[int] = []
	for k in range(-3, 4):
		if absi(k - pk) >= 2:
			cand.append(k)
	_safe = cand[randi() % cand.size()]
	for k in range(-3, 4):
		if k == _safe:
			continue
		var ends := _lane_ends(k)
		_tg.append(BossKit.telegraph_line(self, ends[0], ends[1], 20.0, life, BossKit.RED))
	BossKit.anim(self, "cast", 10.0, false)
	_goto(0 if first else 1)


func _temples_strike() -> void:
	var p := BossKit.player_point(self)
	var hit := false
	for k in range(-3, 4):
		if k == _safe:
			continue
		var ends := _lane_ends(k)
		BossKit.beam_fx(self, ends[0], ends[1], 20.0, 0.35, STONE)
		BossKit.sparks(self, (ends[0] + ends[1]) * 0.5, STONE, 8, 90.0, 0.4, 100.0)
		if BossKit.in_line(p, ends[0], ends[1], 20.0):
			hit = true
	BossKit.shake(self, 3.0, 0.4)
	if hit:
		BossKit.hurt_player(self, temple_damage, true)


func _act_temples() -> void:
	match _stage:
		0:
			if _sub >= temple_windup:
				_temples_strike()
				_clear_attack()
				_temples_mark(temple_windup_2, false)
		1:
			if _sub >= temple_windup_2:
				_temples_strike()
				_clear_attack()
				BossKit.anim(self, "slam", 10.0, false)
				_goto(2)
		2:
			if _sub >= 0.4:
				_finish(recovery_heavy + 0.6)


func _on_health(hp: int, max_hp: int) -> void:
	engaged = true   # first hit
	if phase == 1 and hp > 0 and hp * 2 <= max_hp:
		phase = 2
		build_interval = pillar_every_2
		_deck.clear()
		_ult_cd = maxf(_ult_cd, 5.0)
		_enter(State.PAUSE)
		BossKit.roar(self, STONE, 100.0)


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
