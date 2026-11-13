class_name KerisGandring extends EnemyBase
## Boss: Mpu Gandring's Keris (bestiary.md "Build spec"). Lights curse stakes (group "curse_stake") one by one; all 7 lit
## means a 2 s red ring, then a curse wave that only dash i-frames avoid. Phase 2 (50%): faster stakes, double dart.
## Defeat: EnemyBase death, then Events.boss_defeated. The quest step sets mq3_7 (as with Bondowoso).
## The HUD polls: group "boss", health, boss_name_key, engaged.

enum State { IDLE, CHASE, DART_WIND, DART, FAN_WIND, RECOVER, PAUSE, RING, MOVE }

const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const SHOT := preload("res://entities/enemies/spirit_shot.tscn")
const CRIMSON := Color(1.0, 0.2, 0.25)
const STEEL := Color(0.75, 0.85, 1.0)
const CURSE_COLOR := Color(0.75, 0.3, 1.0)
const MOVES_ALL := ["dart", "fan", "teleport_flurry", "orbit_blades", "crimson_cross", "curse_mark"]   # the deck; seven_swords is the limit break
const HEAVY := ["teleport_flurry", "orbit_blades", "crimson_cross", "seven_swords"]


## The orbit-blades set-piece: a ring of shards around the boss that turns and closes in. The gaps are the way through.
class Orbit extends Node2D:
	var host: EnemyBase
	var count := 12
	var gaps: Array[int] = []
	var r_from := 120.0
	var r_to := 28.0
	var warm := 0.8
	var close_time := 3.0
	var spin := 0.6
	var damage := 18
	var _t := 0.0
	var _cool := 0.0
	var _angle := 0.0

	func _radius() -> float:
		return lerpf(r_from, r_to, clampf((_t - warm) / close_time, 0.0, 1.0))

	func _slot_angle(i: int) -> float:
		return _angle + TAU * i / count

	## The boss steps it (so its clock is the boss's clock). True once it has closed and gone.
	func step(delta: float) -> bool:
		_t += delta
		if host == null or not is_instance_valid(host) or _t >= warm + close_time:
			queue_free()
			return true
		global_position = host.global_position
		_angle += spin * delta
		_cool -= delta
		queue_redraw()
		if _t < warm or _cool > 0.0:
			return false
		var p: Vector2 = BossKit.player_point(host)
		var rad: float = _radius()
		for i in count:
			if gaps.has(i):
				continue
			if BossKit.in_circle(p, global_position + Vector2.from_angle(_slot_angle(i)) * rad, 4.0):
				BossKit.hurt_player(host, damage, false)
				_cool = 0.7   # one blade per pass, not a shredder
				break
		return false

	func _draw() -> void:
		var rad: float = _radius()
		var live: bool = _t >= warm
		var half: float = TAU / count * 0.5
		for i in count:
			var a: float = _slot_angle(i)
			if gaps.has(i):
				draw_arc(Vector2.ZERO, rad, a - half, a + half, 6, Color(1.0, 0.85, 0.3, 0.6), 1.0)
				continue
			draw_set_transform(Vector2.from_angle(a) * rad, a + PI * 0.5)
			var col := Color(0.75, 0.85, 1.0, 1.0 if live else 0.35)
			draw_colored_polygon(PackedVector2Array([Vector2(0, -8), Vector2(3, 3), Vector2(0, 6), Vector2(-3, 3)]), col)
			draw_colored_polygon(PackedVector2Array([Vector2(0, -6), Vector2(1, 2), Vector2(-1, 2)]), Color(1, 1, 1, 0.8 if live else 0.2))
		draw_set_transform(Vector2.ZERO, 0.0)

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
@export var heavy_recovery := 2.2      # TUNE: punish window after a heavy move
@export var flurry_count := 3          # TUNE: blink strikes before the finisher (phase 2: +1)
@export var flurry_windup := 0.55      # TUNE: marker time of each blink
@export var flurry_radius := 26.0      # TUNE
@export var flurry_damage := 18        # TUNE, light
@export var flurry_final_damage := 30  # TUNE: the finisher, heavy
@export var orbit_windup := 0.8        # TUNE: the ring hangs still and faint first
@export var orbit_time := 3.0          # TUNE: how long it takes to close in
@export var orbit_damage := 18         # TUNE, light
@export var orbit_radius := 120.0      # TUNE
@export var cross_windup := 1.0        # TUNE
@export var cross_damage := 45         # TUNE, heavy
@export var cross_width := 18.0        # TUNE
@export var mark_time := 2.0           # TUNE: the homing curse mark
@export var mark_speed := 55.0         # TUNE: it crawls toward you, you outrun it
@export var mark_radius := 28.0        # TUNE
@export var mark_damage := 22          # TUNE, light, curses
@export var sword_windup := 2.4        # TUNE: limit break telegraph
@export var sword_second := 1.1        # TUNE: telegraph of the shifted second volley
@export var sword_damage := 70         # TUNE: ~1.2x heavy, avoidable
@export var sword_count := 7           # seven beams, seven stakes

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
var _blast_left := 0.0
var moves_used: Dictionary = {}        # move name -> times started (tests)
var forced_move := ""                  # tests: "" = the deck, a move name = only that one, anything else = no move
var _deck: Array[String] = []
var _last_move := ""
var _move := ""
var _stage := 0
var _since_ult := 0
var _rec := 1.0
var _ghost_t := 0.0
var _tgs: Array[Node2D] = []
var _orbit: Orbit
var _spot := Vector2.ZERO
var _flur_i := 0
var _flur_total := 3
var _salvo := 0
var _marks: Array[Vector2] = []
var _mark_tgs: Array[Node2D] = []
@export var cond := ""   # Game.check condition; empty = always on
var active := true       # EliteGuard flips it


func _ready() -> void:
	super()
	if dead or is_queued_for_deletion():
		return
	add_to_group("boss")
	if cond != "":   # hidden and inert until Game.check(cond) holds (elite_guard.gd); the zone doc passes it
		var g := EliteGuard.new()
		g.cond = cond
		add_child(g)
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
	if d <= engage_range and BossKit.may_engage(self):
		engaged = true
	if engaged and state != State.RING:
		_run_stakes(delta)
	match state:
		State.IDLE:
			if engaged:
				_enter(State.CHASE)
		State.CHASE:
			var m := ""
			if target != null:
				m = _pick_move(d)
			if m != "":
				_begin(m)
			else:
				velocity = to_t.normalized() * speed * slow() if d > dart_min else Vector2.ZERO
		State.DART_WIND:
			if state_time >= dart_windup:
				_start_dart()
		State.DART:
			_ghost_t -= delta
			if _ghost_t <= 0.0:
				_ghost_t = 0.04
				BossKit.ghost(self, STEEL, 0.3)
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
		State.MOVE:
			_tick_move(delta)
		State.RECOVER:
			if state_time >= _rec:
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
	for s in all:
		if s.is_lit() and target != null and s.global_position.distance_to(target.global_position) < 160.0:
			BossKit.mark(self, s, "jawa_ha", 6.0, 14.0)   # a lit stake: Jawa Ha puts it out
	if lit_count() > 0:
		BossKit.hint(self, "BOSS_HINT_KERIS")
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
	BossKit.anim(self, "cast", 6.0, true)
	_tg(BossKit.telegraph_circle(self, _start, arena_radius, ring_time, CRIMSON))


## The curse wave: a heavy hit over the whole arena. A dodging player's i-frames refuse it. All stakes go out.
func _wave() -> void:
	waves += 1
	_rec = heavy_recovery
	attack_hitbox.global_position = _start
	(attack_hitbox.get_node("Shape") as CollisionShape2D).shape.radius = arena_radius
	attack_hitbox.damage = wave_damage
	attack_hitbox.heavy = true
	attack_hitbox.activate()
	_blast_left = 0.15
	BossKit.roar(self, CRIMSON, arena_radius * 0.6)
	BossKit.ring_fx(self, _start, arena_radius, 0.6, CRIMSON)
	BossKit.shake(self, 3.0, 0.5)
	for s in stakes():
		s.state = CurseStake.State.UNLIT
		s._paint()
	_light_t = 0.0


# --- move deck ---

func _eligible(m: String, d: float) -> bool:
	var in_arena: bool = BossKit.player_point(self).distance_to(_start) <= arena_radius + 24.0
	match m:
		"dart":
			return d >= dart_min and d <= dart_range
		"fan":
			return d >= dart_min and d <= dart_range
		"teleport_flurry":
			return d <= 220.0
		"orbit_blades":
			return d <= 110.0
		"crimson_cross":
			return d <= 240.0 and in_arena
		"curse_mark":
			return d >= 60.0 and d <= 240.0
		"seven_swords":
			return phase >= 2 and d <= 240.0 and in_arena and _since_ult >= 4
	return false


func _refill() -> void:
	_deck.clear()
	for m in MOVES_ALL:
		var mv: String = m
		_deck.append(mv)
	_deck.shuffle()


## The next move for this distance: the limit break when it is due, else the next fitting card of a shuffled deck.
## A heavy move never repeats back to back. "" = nothing fits, keep drifting closer.
func _pick_move(d: float) -> String:
	if forced_move != "":
		return forced_move if _eligible(forced_move, d) else ""
	if _eligible("seven_swords", d):
		return "seven_swords"
	for _pass in 2:
		if _deck.is_empty():
			_refill()
		for i in _deck.size():
			var m: String = _deck[i]
			if not _eligible(m, d):
				continue
			if m == _last_move and HEAVY.has(m):
				continue
			_deck.remove_at(i)
			return m
		_refill()   # nothing in this hand fits: one fresh shuffle
	return ""


func _begin(m: String) -> void:
	var n: int = int(moves_used.get(m, 0))
	moves_used[m] = n + 1
	_last_move = m
	_since_ult = 0 if m == "seven_swords" else _since_ult + 1
	_rec = heavy_recovery if HEAVY.has(m) else recovery
	_move = m
	match m:
		"dart":
			_begin_dart(2 if phase == 2 else 1)
		"fan":
			_begin_fan()
		_:
			_begin_move(m)


# --- attacks ---

func _enter(s: State) -> void:
	_clear_attack()
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	body.modulate = Color(1.0, 0.45, 0.45) if s in [State.DART_WIND, State.FAN_WIND, State.RING, State.MOVE] else Color.WHITE
	if s == State.RECOVER and _rec >= heavy_recovery:
		BossKit.open(self, _rec)
	if s == State.CHASE or s == State.RECOVER or s == State.PAUSE:
		BossKit.anim_stop(self)


func _tg(t: Node2D) -> void:
	_tgs.append(t)


func _clear_attack() -> void:
	for t in _tgs:
		if is_instance_valid(t):
			t.queue_free()
	_tgs.clear()
	for t in _mark_tgs:
		if is_instance_valid(t):
			t.queue_free()
	_mark_tgs.clear()
	_marks.clear()
	if is_instance_valid(_orbit):
		_orbit.queue_free()
	_orbit = null


func _begin_dart(left: int) -> void:
	_enter(State.DART_WIND)
	darts_left = left
	_dir = (target.global_position - global_position).normalized()
	BossKit.anim(self, "cast", 10.0, true)
	_tg(BossKit.telegraph_line(self, global_position, global_position + _dir * dart_range, 10.0, dart_windup, CRIMSON))


func _start_dart() -> void:
	attacks += 1
	_enter(State.DART)
	BossKit.anim(self, "dash", 10.0, true)
	_from = global_position
	_ghost_t = 0.0
	velocity = _dir * dart_speed
	attack_hitbox.position = Vector2.ZERO
	(attack_hitbox.get_node("Shape") as CollisionShape2D).shape.radius = 8.0
	attack_hitbox.damage = dart_damage
	attack_hitbox.heavy = false
	attack_hitbox.activate()


func _fan_count() -> int:
	return 5 if phase == 2 else 3


func _begin_fan() -> void:
	_enter(State.FAN_WIND)
	_dir = (target.global_position - global_position).normalized()
	BossKit.anim(self, "cast", 10.0, true)
	var arc: float = deg_to_rad((_fan_count() - 1) * fan_spread * 0.5 + 10.0)
	_tg(BossKit.telegraph_cone(self, global_position, _dir.angle(), arc, dart_range * 0.6, fan_windup, CRIMSON))


func _fire_fan() -> void:
	attacks += 1
	var n: int = _fan_count()
	for i in n:
		var shot := SHOT.instantiate() as Arrow
		shot.source = self
		shot.damage = fan_damage
		shot.direction = _dir.rotated(deg_to_rad(fan_spread) * (float(i) - (n - 1) * 0.5) / 2.0)
		shot.speed = shot_speed
		shot.max_range = dart_range
		shot.hit_landed.connect(_curse)
		get_parent().add_child(shot)
		shot.global_position = global_position + Vector2(0, -6)


func _curse(hb: Hurtbox) -> void:
	var s := hb.owner.get("status") as Status if hb.owner else null
	if s:
		s.apply(Status.Type.CURSE)


## The curse for hits that do not come through a hitbox (blinks, marks).
func _curse_player() -> void:
	if target == null:
		return
	var sv: Variant = target.get("status")
	if sv is Status:
		(sv as Status).apply(Status.Type.CURSE)


# --- scripted moves (State.MOVE): _move names it, _stage and state_time drive it ---

func _stage_to(n: int) -> void:
	_stage = n
	state_time = 0.0


func _end_move() -> void:
	_enter(State.RECOVER)


func _begin_move(m: String) -> void:
	_enter(State.MOVE)
	_stage = 0
	_dir = Vector2.RIGHT
	if target != null:
		_dir = (target.global_position - global_position).normalized()
	match m:
		"teleport_flurry":
			_flur_i = 0
			_flur_total = flurry_count + (1 if phase == 2 else 0)
			BossKit.anim(self, "cast", 10.0, true)
			_next_blink()
		"orbit_blades":
			BossKit.anim(self, "cast", 10.0, true)
			var o := Orbit.new()
			o.host = self
			o.count = 12
			for g in [0, 1, 6, 7]:
				o.gaps.append(g)
			o.r_from = orbit_radius + (8.0 if phase == 2 else 0.0)
			o.warm = orbit_windup
			o.close_time = orbit_time
			o.spin = 0.8 if phase == 2 else 0.6
			o.damage = orbit_damage
			o.z_index = 35
			o.set_physics_process(false)
			get_parent().add_child(o)
			o.global_position = global_position
			_orbit = o
			_tg(BossKit.telegraph_ring(self, global_position, orbit_radius + 12.0, orbit_radius - 4.0, orbit_windup, STEEL))
		"crimson_cross":
			_salvo = 0
			_blink_to(_start)
			var out: Vector2 = Vector2.RIGHT
			if target != null:
				out = (target.global_position - _start).normalized()
			_dir = out   # one line points at the player: they must move
			BossKit.anim(self, "cast", 10.0, true)
			_cross_telegraph(_dir.angle(), cross_windup)
		"curse_mark":
			BossKit.anim(self, "cast", 10.0, true)
			var first: Vector2 = BossKit.player_point(self)
			_add_mark(first)
			if phase == 2:
				_add_mark(_start * 2.0 - first)   # a twin on the far side of the arena
		"seven_swords":
			_salvo = 0
			_blink_to(_start)
			if target != null:
				_dir = (target.global_position - _start).normalized()
			BossKit.roar(self, CRIMSON, 70.0)
			_sword_telegraph(_dir.angle() + TAU / sword_count * 0.5, sword_windup)


## Vanish from here, appear there (afterimage at both ends).
func _blink_to(pos: Vector2) -> void:
	BossKit.ghost(self, STEEL, 0.4)
	BossKit.flash_fx(self, global_position + Vector2(0, -8), 18.0, 0.3, STEEL)
	global_position = pos
	BossKit.ghost(self, CRIMSON, 0.4)
	BossKit.flash_fx(self, pos + Vector2(0, -8), 18.0, 0.3, CRIMSON)


func _next_blink() -> void:
	_clear_attack()
	var base: float = (global_position - target.global_position).angle() if target != null else 0.0
	var last: bool = _flur_i >= _flur_total   # the finisher
	_spot = (target.global_position if target != null else global_position) + Vector2.from_angle(base + _flur_i * 2.2) * 44.0
	var r: float = flurry_radius + (14.0 if last else 0.0)
	_tg(BossKit.telegraph_circle(self, _spot, r, flurry_windup + (0.2 if last else 0.0), CRIMSON))
	body.modulate = Color(1.0, 0.45, 0.45, 0.4)


func _add_mark(pos: Vector2) -> void:
	_marks.append(pos)
	var t: Node2D = BossKit.telegraph_circle(self, pos, mark_radius, mark_time, CURSE_COLOR)
	_mark_tgs.append(t)


## Line through the arena centre at `ang`, both ways, for a crimson-cross salvo (2 lines in phase 1, 3 in phase 2).
func _cross_lines() -> int:
	return 3 if phase == 2 else 2


func _cross_telegraph(base: float, life: float) -> void:
	_clear_attack()
	for k in _cross_lines():
		var a: float = base + PI * k / _cross_lines()
		var reach: Vector2 = Vector2.from_angle(a) * (arena_radius + 16.0)
		_tg(BossKit.telegraph_line(self, _start - reach, _start + reach, cross_width, life, CRIMSON))


func _cross_strike(base: float) -> void:
	for k in _cross_lines():
		var a: float = base + PI * k / _cross_lines()
		var reach: Vector2 = Vector2.from_angle(a) * (arena_radius + 16.0)
		BossKit.strike_line(self, _start - reach, _start + reach, cross_width, cross_damage, true, CRIMSON)


func _sword_telegraph(base: float, life: float) -> void:
	_clear_attack()
	for k in sword_count:
		var a: float = base + TAU * k / sword_count
		_tg(BossKit.telegraph_line(self, _start, _start + Vector2.from_angle(a) * (arena_radius + 16.0), 16.0, life, CRIMSON))


func _sword_strike(base: float) -> void:
	for k in sword_count:
		var a: float = base + TAU * k / sword_count
		BossKit.strike_line(self, _start, _start + Vector2.from_angle(a) * (arena_radius + 16.0), 16.0, sword_damage, true, CRIMSON)


func _tick_move(delta: float) -> void:
	match _move:
		"teleport_flurry":
			var last: bool = _flur_i >= _flur_total
			if state_time >= flurry_windup + (0.2 if last else 0.0):
				attacks += 1
				_blink_to(_spot)
				var dmg: int = flurry_final_damage if last else flurry_damage
				var rad: float = flurry_radius + (14.0 if last else 0.0)
				if BossKit.strike_circle(self, _spot, rad, dmg, last, CRIMSON):
					_curse_player()
				BossKit.slash(self, _spot, _dir.angle(), 2.4, rad, STEEL)
				if last:
					BossKit.shake(self, 2.0, 0.25)
					_end_move()
				else:
					_flur_i += 1
					_next_blink()
					state_time = 0.0
		"orbit_blades":
			if _orbit == null or not is_instance_valid(_orbit) or _orbit.step(delta):
				_end_move()
		"crimson_cross":
			if _salvo == 0 and state_time >= cross_windup:
				attacks += 1
				_cross_strike(_dir.angle())
				BossKit.shake(self, 2.5, 0.3)
				_salvo = 1   # the second volley is shifted half a gap, onto where the safe wedges were
				_cross_telegraph(_dir.angle() + PI / (2.0 * _cross_lines()), cross_windup * 0.9)
				state_time = 0.0
			elif _salvo == 1 and state_time >= cross_windup * 0.9:
				attacks += 1
				_cross_strike(_dir.angle() + PI / (2.0 * _cross_lines()))
				BossKit.shake(self, 2.5, 0.3)
				_end_move()
		"curse_mark":
			var crawl: bool = state_time < mark_time - 0.5
			var p: Vector2 = BossKit.player_point(self)
			for i in _marks.size():
				if crawl and p.x != INF:
					_marks[i] = _marks[i].move_toward(p, mark_speed * delta)
				if i < _mark_tgs.size() and is_instance_valid(_mark_tgs[i]):
					_mark_tgs[i].global_position = _marks[i]
			if state_time >= mark_time:
				attacks += 1
				for pos in _marks:
					if BossKit.strike_circle(self, pos, mark_radius, mark_damage, false, CURSE_COLOR):
						_curse_player()
				_end_move()
		"seven_swords":
			if _salvo == 0 and state_time >= sword_windup:
				attacks += 1
				var base: float = _dir.angle() + TAU / sword_count * 0.5
				_sword_strike(base)
				BossKit.shake(self, 3.0, 0.4)
				_salvo = 1
				_sword_telegraph(base + TAU / sword_count * 0.5, sword_second)
				state_time = 0.0
			elif _salvo == 1 and state_time >= sword_second:
				attacks += 1
				_sword_strike(_dir.angle() + TAU / sword_count)
				BossKit.shake(self, 3.0, 0.4)
				_rec = heavy_recovery + 0.8
				_end_move()
		_:
			_end_move()


func _on_health(hp: int, max_hp: int) -> void:
	engaged = true   # first hit
	if phase == 1 and hp > 0 and hp * 2 <= max_hp:
		phase = 2
		stake_interval = stake_every_2
		_enter(State.PAUSE)
		BossKit.roar(self, CRIMSON, 100.0)


## Story v5: Laras's sabotage flag is set (Game.has_flag, underscore form).
func _sabotaged() -> bool:
	var g := get_node_or_null("/root/Game")
	return g != null and sabotage_flag != "" and g.has_flag(sabotage_flag)


func _on_flinch() -> void:
	pass   # it floats: no knockback, no flinch


func _on_died() -> void:
	_clear_attack()
	BossKit.anim_stop(self)
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
