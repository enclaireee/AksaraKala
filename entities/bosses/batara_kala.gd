class_name BataraKala extends EnemyBase
## Final boss: Batara Kala (bestiary.md "Final: Gua Kala", build spec P0). A deity, calmed and turned back, never killed.
## Phase 1: devouring pulse (a thin ring), time-sand (ground-marked circles), scythe sweep (forehand + backhand) and the
## hour chime (a ring of orbs with a gap). Phase 2 (66%): a shield with a 3-glyph sequence and a countdown; the right casts
## in order break it. New moves: clock hands (two rotating blades, step through the gap), time skip (vanish, reappear behind
## you), time stop (frozen rings released as waves). Phase 3 (33%): faster, 20 s, 5 circles; adds eclipse meteors, hourglass
## beams and the limit break "Ruwatan Eclipse" (eight wedges, one safe).
## Defeat is a release: EnemyBase death (Ilmu, enemy_killed) then Events.boss_defeated.
## The HUD polls: group "boss", health, boss_name_key, engaged, dawn (null or 0..1), sequence, seq_index.
# ponytail: damage goes straight through the player's Hurtbox (so i-frames refuse it), no physics hitbox sweeps.

enum State { IDLE, CHASE, PULSE_WIND, PULSE, SAND_WIND, RECOVER, PAUSE, STUN, DEVOUR,
	SWEEP, CHIME, HANDS, SKIP, STOP, METEOR, BEAMS, RUWATAN }

const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const STUNNED := Color(0.7, 0.75, 1.0)
const GOLD := Color(1.0, 0.8, 0.3)
const VIOLET := Color(0.75, 0.4, 1.0)
const ICE := Color(0.6, 0.85, 1.0)
const EMBER := Color(1.0, 0.55, 0.2)
const WINDY := [State.PULSE_WIND, State.SAND_WIND, State.SWEEP, State.CHIME, State.HANDS, State.SKIP, State.STOP,
	State.METEOR, State.BEAMS, State.RUWATAN]
const HEAVY := ["pulse", "hands", "meteor", "beams", "stop", "ruwatan"]

@export var boss_name_key := "BOSS_BATARA_KALA"
@export var sabotage_flag := "laras_sabotage_kala_eclipse"   # HUD boss bar reads this
@export var sabotage_stun_bonus := 1.0  # TUNE (v5): Laras cracks the Eclipse shield, stun after a break is this much longer (3 -> 4 s)
@export var speed := 22.0              # TUNE
@export var engage_range := 160.0      # TUNE
@export var pulse_windup := 0.8        # TUNE
@export var pulse_grow := 1.2          # TUNE: seconds for the ring to reach pulse_radius
@export var pulse_radius := 96.0       # TUNE
@export var pulse_inner := 24.0        # TUNE: the ring starts here, so standing this close is safe
@export var pulse_band := 3.0          # TUNE: extra reach on the ring edge so a fast tick cannot skip a player
@export var pulse_damage := 41         # TUNE, heavy
@export var sand_windup := 0.9         # TUNE
@export var sand_radius := 20.0        # TUNE
@export var sand_damage := 18          # TUNE, light
@export var sand_count := 3            # TUNE
@export var sand_count_p3 := 5         # TUNE
@export var recovery := 1.2            # TUNE
@export var heavy_recovery := 2.4      # TUNE: the punish window after a heavy move
@export var ult_recovery := 3.0        # TUNE: after Ruwatan Eclipse
@export var pause_time := 1.0          # TUNE
@export var stun_time := 3.0           # TUNE
@export var open_time := 10.0          # TUNE: total seconds the shield stays down after breaking
@export var countdown_p2 := 30.0       # TUNE
@export var countdown_p3 := 20.0       # TUNE
@export var devour_time := 2.0         # TUNE: the red ring fills the arena
@export var devour_damage := 60        # TUNE, heavy
@export var arena_radius := 176.0      # TUNE
@export var wind_p3 := 0.7             # TUNE: wind-up multiplier in phase 3
@export var sweep_wind := 0.6          # TUNE: each cut of the scythe sweep
@export var sweep_arc := 1.9           # TUNE: radians
@export var sweep_len := 58.0          # TUNE
@export var sweep_damage := 22         # TUNE, light
@export var chime_wind := 0.8          # TUNE
@export var chime_damage := 18         # TUNE, light
@export var chime_speed := 55.0        # TUNE
@export var hands_wind := 0.9          # TUNE
@export var hands_damage := 34         # TUNE, heavy
@export var skip_wind := 0.9           # TUNE: the landing marker
@export var skip_damage := 30          # TUNE: the landing slam
@export var stop_hold := 1.4           # TUNE: seconds the rings stay frozen
@export var stop_damage := 24          # TUNE
@export var meteor_radius := 20.0      # TUNE
@export var meteor_fall := 0.9         # TUNE: marker time before each impact
@export var meteor_damage := 30        # TUNE
@export var beams_wind := 1.0          # TUNE
@export var beams_damage := 36         # TUNE, heavy
@export var ruwatan_windup := 2.4      # TUNE: the long telegraph of the limit break
@export var ruwatan_damage := 58       # TUNE, ultimate (~1.5x heavy), always avoidable

var state := State.IDLE
var state_time := 0.0
var phase := 1
var engaged := false
var shielded := false
var sequence := PackedStringArray()
var seq_index := 0
var dawn = null             # null without a shield, else elapsed / countdown (0..1)
var pulses := 0
var sands := 0
var devours := 0
var moves_used: Dictionary = {}   # move name -> times begun (tests)
var _forced_move := ""      # tests: begin this move next ("none" = never attack)
var _deck: Array[String] = []
var _last_move := ""
var _since_ult := 0
var _recover_len := 1.2
var _step := 0
var _aim := 0.0
var _elapsed := 0.0
var _open_left := 0.0
var _ring_r := 0.0
var _hit_ring := false
var _marks: Array[Polygon2D] = []
var _fx: Array[Node] = []
var _impacts: Array[Dictionary] = []
var _spots: Array[Vector2] = []
var _ring: Line2D
var _fill: Polygon2D
var _shield: Polygon2D
# rotating blades (clock hands and hourglass beams share one code path)
var _sw_lines: Array[Line2D] = []
var _sw_a := 0.0
var _sw_n := 2
var _sw_off := 2.4
var _sw_len := 140.0
var _sw_w := 8.0
var _sw_inner := 22.0
var _sw_omega := 1.3
var _sw_dur := 2.6
var _sw_flip := false
var _sw_dmg := 34
var _sw_wind := 0.9
var _sw_cd := 0.0
var _sw_fx := 0.0
var _sw_color := Color(1.0, 0.3, 0.3)
var _sw_spin := 1.0
# time skip and Ruwatan
var _skip_from := Vector2.ZERO
var _land := Vector2.ZERO
var _ru_base := 0.0
var _ru_safe := 0
var _ru_pulse := 0.0


func _ready() -> void:
	super()
	if dead or is_queued_for_deletion():
		return
	add_to_group("boss")
	health.changed.connect(_on_health)
	get_node("/root/Events").spell_cast.connect(_on_cast)


func _tick(delta: float) -> void:
	state_time += delta
	var to_t := Vector2.INF
	if target != null:
		to_t = target.global_position - global_position
	var d := to_t.length()
	if d <= engage_range:
		engaged = true
	if phase >= 2 and state != State.PAUSE:
		if shielded:
			health.invincible_time = 1.0e9
			if state != State.DEVOUR:
				_elapsed += delta
				if _elapsed >= _countdown():
					_enter(State.DEVOUR)
			dawn = minf(1.0, _elapsed / _countdown())
		else:
			_open_left -= delta
			if _open_left <= 0.0:
				_raise_shield()
	var k := wind_p3 if phase >= 3 else 1.0
	match state:
		State.IDLE:
			if engaged:
				_enter(State.CHASE)
		State.CHASE:
			velocity = to_t.normalized() * speed * slow() if d > 40.0 else Vector2.ZERO
			if state_time >= 0.6 and _forced_move != "none":
				var mv := _forced_move if _forced_move != "" else _next_move(d)
				_forced_move = ""
				_begin(mv)
		State.PULSE_WIND:
			if state_time >= pulse_windup * k:
				_enter(State.PULSE)
				_hit_ring = false
				_ring_r = pulse_inner
				_ring = Line2D.new()
				_ring.width = 2.0
				_ring.default_color = Color(1.0, 0.3, 0.3, 0.8)
				add_child(_ring)
				_ring.position = Vector2(0, -6)
				BossKit.anim(self, "slam")
				BossKit.shake(self, 1.5, 0.2)
		State.PULSE:
			var prev := _ring_r
			_ring_r = pulse_inner + (pulse_radius - pulse_inner) * minf(1.0, state_time / pulse_grow)
			_ring.points = _circle(_ring_r, 32, true)
			if not _hit_ring and d >= prev - pulse_band and d <= _ring_r + pulse_band:
				_hit_ring = true
				pulses += 1
				_hurt(pulse_damage, true)
			if state_time >= pulse_grow:
				_enter(State.RECOVER)
		State.SAND_WIND:
			if state_time >= sand_windup * k:
				sands += 1
				for s in _spots:
					BossKit.ring_fx(self, s, sand_radius, 0.3, EMBER)
					if target != null and target.global_position.distance_to(s) <= sand_radius:
						_hurt(sand_damage, false)
				_enter(State.RECOVER)
		State.RECOVER:
			var rk := 1.0 if _recover_len > recovery + 0.01 else k   # heavy punish windows are not shortened
			if state_time >= _recover_len * rk:
				_enter(State.CHASE)
		State.PAUSE:
			if state_time >= pause_time:
				_enter(State.CHASE)
		State.STUN:
			if state_time >= stun_time + (sabotage_stun_bonus if _sabotaged() else 0.0):   # ASSUMED (v5)
				_enter(State.CHASE)
		State.DEVOUR:
			if is_instance_valid(_fill):
				_fill.scale = Vector2.ONE * minf(1.0, state_time / devour_time)
			if state_time >= devour_time:
				devours += 1
				BossKit.shake(self, 3.0, 0.4)
				_hurt(devour_damage, true)
				_new_sequence()
				_enter(State.CHASE)
		State.SWEEP:
			_tick_sweep()
		State.CHIME:
			_tick_chime()
		State.HANDS, State.BEAMS:
			_tick_blades(delta)
		State.SKIP:
			_tick_skip()
		State.STOP:
			_tick_stop()
		State.METEOR:
			_tick_meteor()
		State.RUWATAN:
			_tick_ruwatan(delta)
	move_and_slide()


func _countdown() -> float:
	var c := countdown_p3 if phase >= 3 else countdown_p2
	var g := get_node_or_null("/root/Game")
	if phase >= 3 and g and g.has_flag("choice_redeem_aria"):
		c += 6.0   # Choice 6: Aria's shadow adds +6 s to Phase 3 countdown (bestiary.md)
	return c


func _enter(s: State) -> void:
	_clear_attack()
	state = s
	state_time = 0.0
	_step = 0
	velocity = Vector2.ZERO
	body.visible = true
	body.modulate = STUNNED if s == State.STUN else Color.WHITE
	if s in WINDY:
		body.modulate = Color(1.0, 0.45, 0.45)
	if s == State.CHASE or s == State.RECOVER or s == State.STUN:
		BossKit.anim_stop(self)
	if s == State.DEVOUR:
		BossKit.anim(self, "roar", 8.0, false)
		BossKit.flash_fx(self, global_position + Vector2(0, -14), 40.0, 0.5, Color(1.0, 0.2, 0.2))
		_fill = Polygon2D.new()
		_fill.polygon = _circle(arena_radius, 48, false)
		_fill.color = Color(1.0, 0.1, 0.1, 0.3)
		_fill.z_index = -1
		_fill.scale = Vector2.ZERO
		add_child(_fill)


# --- move selection: a shuffled deck, distance and phase aware, never the same heavy twice ---

func _next_move(d: float) -> String:
	if phase >= 3 and _since_ult >= 5:
		return "ruwatan"
	for attempt in 3:
		if _deck.is_empty():
			_refill_deck()
		var pick := ""
		for i in range(_deck.size() - 1, -1, -1):
			var m: String = _deck[i]
			if m == "sweep" and d > 72.0:
				continue   # the scythe only when he is close
			if m == _last_move or (m in HEAVY and _last_move in HEAVY):
				continue
			pick = m
			_deck.remove_at(i)
			break
		if pick != "":
			return pick
		_deck.clear()
	return "sand"


func _refill_deck() -> void:
	var base: Array[String] = ["pulse", "sand", "sweep", "chime"]
	if phase >= 2:
		base.append("hands")
		base.append("skip")
		base.append("stop")
	if phase >= 3:
		base.append("meteor")
		base.append("beams")
	base.shuffle()
	_deck.append_array(base)


func _aim_at() -> float:
	if target == null:
		return 0.0
	return (target.global_position - global_position).angle()


func _begin(mv: String) -> void:
	moves_used[mv] = int(moves_used.get(mv, 0)) + 1
	_last_move = mv
	_since_ult = 0 if mv == "ruwatan" else _since_ult + 1
	match mv:
		"pulse":
			_begin_pulse()
		"sweep":
			_begin_sweep()
		"chime":
			_begin_chime()
		"hands":
			_begin_blades(false)
		"beams":
			_begin_blades(true)
		"skip":
			_begin_skip()
		"stop":
			_begin_stop()
		"meteor":
			_begin_meteor()
		"ruwatan":
			_begin_ruwatan()
		_:
			_begin_sand()


func _begin_pulse() -> void:
	_enter(State.PULSE_WIND)
	_recover_len = heavy_recovery
	BossKit.anim(self, "cast")
	var m := Polygon2D.new()   # the ring's reach, drawn on the ground during the wind-up
	m.polygon = _circle(pulse_radius, 32, false)
	m.color = Color(1.0, 0.3, 0.3, 0.12)
	m.z_index = -1
	add_child(m)
	m.position = Vector2(0, -6)
	_marks.append(m)


func _begin_sand() -> void:
	_enter(State.SAND_WIND)
	_recover_len = recovery
	BossKit.anim(self, "cast")
	var n := sand_count_p3 if phase >= 3 else sand_count
	var c := target.global_position if target != null else global_position
	for i in n:
		var spot := c if i == 0 else c + Vector2.from_angle(TAU * (i - 1) / (n - 1) + randf() * 0.5) * randf_range(28.0, 56.0)
		_spots.append(spot)
		var m := Polygon2D.new()
		m.polygon = _circle(sand_radius, 16, false)
		m.color = MARKER
		m.z_index = -1
		get_parent().add_child(m)
		m.global_position = spot
		_marks.append(m)


# --- scythe sweep: forehand then backhand ---

func _begin_sweep() -> void:
	_enter(State.SWEEP)
	_recover_len = recovery + 0.2
	_aim = _aim_at()
	BossKit.anim(self, "slam")
	_fx.append(BossKit.telegraph_cone(self, global_position, _aim, sweep_arc, sweep_len, sweep_wind, GOLD))


func _tick_sweep() -> void:
	if _step == 0 and state_time >= sweep_wind:
		_step = 1
		BossKit.strike_cone(self, global_position, _aim, sweep_arc, sweep_len, sweep_damage, false, GOLD)
		BossKit.punch(self, 1.1, 0.92, 0.2)
		_fx.append(BossKit.telegraph_cone(self, global_position, _aim + PI, sweep_arc, sweep_len, sweep_wind, GOLD))
	elif _step == 1 and state_time >= sweep_wind * 2.0:
		_step = 2
		BossKit.strike_cone(self, global_position, _aim + PI, sweep_arc, sweep_len, sweep_damage, false, GOLD)
		BossKit.shake(self, 1.5, 0.15)
		_enter(State.RECOVER)


# --- hour chime: two rings of orbs, each with a gap that moves ---

func _begin_chime() -> void:
	_enter(State.CHIME)
	_recover_len = recovery + 0.2
	_aim = _aim_at() + 0.9   # the gap of the first ring (the second turns by 1.2 rad)
	BossKit.anim(self, "cast")
	_chime_hint(_aim)


func _chime_hint(gap: float) -> void:
	var at := global_position + Vector2.from_angle(gap) * 36.0 + Vector2(0, -8)
	BossKit.flash_fx(self, at, 8.0, 0.5, GOLD)
	BossKit.sparks(self, at, GOLD, 8, 30.0, 0.6)
	BossKit.ring_fx(self, global_position, 40.0, 0.6, ICE)


func _chime_ring(gap: float) -> void:
	BossKit.ring_fx(self, global_position, 50.0, 0.4, ICE)
	for i in 12:
		var a := TAU * i / 12.0
		if absf(angle_difference(a, gap)) <= 0.62:
			continue
		BossKit.shoot(self, global_position + Vector2(0, -8), a, chime_speed, chime_damage, ICE, "orb", 4.0, 3.4)


func _tick_chime() -> void:
	if _step == 0 and state_time >= chime_wind:
		_step = 1
		_chime_ring(_aim)
		_aim += 1.2
		_chime_hint(_aim)
	elif _step == 1 and state_time >= chime_wind + 0.9:
		_step = 2
		_chime_ring(_aim)
	elif _step == 2 and state_time >= chime_wind + 1.4:
		_enter(State.RECOVER)


# --- clock hands (phase 2) / hourglass beams (phase 3): rotating blades from the boss ---

func _begin_blades(beams: bool) -> void:
	_enter(State.BEAMS if beams else State.HANDS)
	_recover_len = heavy_recovery
	BossKit.anim(self, "cast")
	_aim = _aim_at()
	_sw_a = _aim + 0.6
	_sw_spin = -_sw_spin if _sw_spin != 0.0 else 1.0   # alternate the turning direction
	_sw_cd = 0.0
	_sw_fx = 0.0
	if beams:
		_sw_n = 4
		_sw_off = TAU / 4.0
		_sw_len = arena_radius
		_sw_w = 9.0
		_sw_inner = 26.0
		_sw_omega = 0.9
		_sw_dur = 3.4
		_sw_flip = true   # the beams reverse at the half: do not run with them
		_sw_dmg = beams_damage
		_sw_wind = beams_wind
		_sw_color = VIOLET
	else:
		_sw_n = 3 if phase >= 3 else 2
		_sw_off = TAU / 3.0 if phase >= 3 else 2.4
		_sw_len = 140.0
		_sw_w = 8.0
		_sw_inner = 22.0
		_sw_omega = 1.6 if phase >= 3 else 1.3
		_sw_dur = 2.6
		_sw_flip = false
		_sw_dmg = hands_damage
		_sw_wind = hands_wind
		_sw_color = Color(1.0, 0.3, 0.3)
	_sw_lines.clear()
	for i in _sw_n:
		var ang := _sw_a + _sw_off * i
		var v := Vector2.from_angle(ang)
		_fx.append(BossKit.telegraph_line(self, global_position + v * _sw_inner, global_position + v * _sw_len, _sw_w, _sw_wind, _sw_color))
		var ln := Line2D.new()
		ln.width = _sw_w * 0.5
		ln.default_color = Color(_sw_color, 0.4)
		ln.z_index = -1
		add_child(ln)
		_sw_lines.append(ln)
		_fx.append(ln)
	_draw_blades(0.4)


func _draw_blades(alpha: float) -> void:
	for i in _sw_lines.size():
		var v := Vector2.from_angle(_sw_a + _sw_off * i)
		var ln := _sw_lines[i]
		if is_instance_valid(ln):
			ln.points = PackedVector2Array([v * _sw_inner, v * _sw_len])
			ln.default_color = Color(_sw_color, alpha)


func _tick_blades(delta: float) -> void:
	if state_time < _sw_wind:
		return   # the telegraph lines fill; the blades start where they point
	var t := state_time - _sw_wind
	if _step == 0:
		_step = 1
		BossKit.anim(self, "slam")
		BossKit.flash_fx(self, global_position + Vector2(0, -10), 30.0, 0.3, _sw_color)
		BossKit.shake(self, 2.0, 0.3)
	if t >= _sw_dur:
		_enter(State.RECOVER)
		return
	var dir := _sw_spin
	if _sw_flip and t >= _sw_dur * 0.5:
		dir = -_sw_spin
	_sw_a += dir * _sw_omega * delta
	_sw_cd -= delta
	_sw_fx -= delta
	_draw_blades(0.9)
	if _sw_fx <= 0.0:
		_sw_fx = 0.2
		for i in _sw_n:
			var tip := global_position + Vector2.from_angle(_sw_a + _sw_off * i) * _sw_len
			BossKit.sparks(self, tip, _sw_color, 3, 30.0, 0.3)
	if _sw_cd <= 0.0:
		var p := BossKit.player_point(self)
		for i in _sw_n:
			var v := Vector2.from_angle(_sw_a + _sw_off * i)
			if BossKit.in_line(p, global_position + v * _sw_inner, global_position + v * _sw_len, _sw_w):
				BossKit.hurt_player(self, _sw_dmg, true)
				_sw_cd = 0.8
				break


# --- time skip: vanish, a marker shows where he lands behind you, then a slam and a cut ---

func _begin_skip() -> void:
	_enter(State.SKIP)
	_recover_len = recovery + 0.4
	BossKit.anim(self, "cast")
	BossKit.ghost(self, ICE, 0.5)


func _skip_landing() -> Vector2:
	if target == null:
		return global_position
	var away := target.global_position - global_position
	if away.length() < 1.0:
		away = Vector2.RIGHT
	var spot := target.global_position + away.normalized() * 30.0
	var off := spot - home
	if off.length() > arena_radius - 16.0:
		spot = home + off.normalized() * (arena_radius - 16.0)
	return spot


func _tick_skip() -> void:
	var vanish := 0.5
	if _step == 0 and state_time >= vanish:
		_step = 1
		_skip_from = global_position
		_land = _skip_landing()
		BossKit.anim(self, "dash")
		BossKit.ghost(self, ICE, 0.6)
		BossKit.flash_fx(self, global_position + Vector2(0, -10), 28.0, 0.35, ICE)
		BossKit.sparks(self, global_position + Vector2(0, -10), ICE, 14, 80.0, 0.5)
		body.visible = false
		_fx.append(BossKit.telegraph_circle(self, _land, 26.0, skip_wind, ICE))
	elif _step == 1 and state_time >= vanish + skip_wind:
		_step = 2
		global_position = _land
		body.visible = true
		BossKit.beam_fx(self, _skip_from, _land, 8.0, 0.4, ICE)
		BossKit.ghost(self, ICE, 0.5)
		BossKit.strike_circle(self, _land, 26.0, skip_damage, true, ICE)
		BossKit.anim(self, "slam")
		BossKit.punch(self, 1.15, 0.9, 0.25)
		BossKit.shake(self, 2.0, 0.2)
		_aim = _aim_at()
		_fx.append(BossKit.telegraph_cone(self, global_position, _aim, 1.7, 56.0, 0.55, GOLD))
	elif _step == 2 and state_time >= vanish + skip_wind + 0.55:
		_step = 3
		BossKit.strike_cone(self, global_position, _aim, 1.7, 56.0, sweep_damage, false, GOLD)
		_enter(State.RECOVER)


# --- time stop: the rings freeze in the air, then are released outward as waves ---

func _begin_stop() -> void:
	_enter(State.STOP)
	_recover_len = heavy_recovery
	BossKit.anim(self, "cast")
	BossKit.flash_fx(self, global_position + Vector2(0, -10), 36.0, 0.4, Color(1, 1, 1))
	for r: float in [40.0, 80.0, 120.0]:
		_fx.append(BossKit.telegraph_ring(self, global_position, r + 3.0, r - 3.0, stop_hold, ICE))


func _tick_stop() -> void:
	var waves := 3 if phase >= 3 else 2
	if _step == 0 and state_time >= stop_hold:
		_step = 1
		BossKit.anim(self, "slam")
		BossKit.flash_fx(self, global_position, 120.0, 0.3, Color(1, 1, 1))
		BossKit.shake(self, 2.5, 0.3)
	if _step >= 1 and _step <= waves and state_time >= stop_hold + 0.3 * (_step - 1):
		BossKit.wave(self, global_position, 126.0, 110.0, stop_damage, ICE, false)
		_step += 1
	if _step > waves and state_time >= stop_hold + 0.3 * waves + 0.3:
		_enter(State.RECOVER)


# --- eclipse meteors: three volleys of ground markers (trail, ring around you, checkerboard) ---

func _begin_meteor() -> void:
	_enter(State.METEOR)
	_recover_len = heavy_recovery
	_aim = _aim_at()
	BossKit.anim(self, "cast")
	BossKit.flash_fx(self, global_position + Vector2(0, -14), 30.0, 0.4, EMBER)


func _meteor_volley(i: int) -> void:
	var p := target.global_position if target != null else global_position
	var pts: Array[Vector2] = []
	match i:
		0:   # a trail of falls walking from him to you
			var dir: Vector2 = Vector2.RIGHT
			if p.distance_to(global_position) > 1.0:
				dir = (p - global_position).normalized()
			for j in 6:
				pts.append(global_position + dir * (28.0 + 26.0 * j))
		1:   # a ring around you: the middle is safe
			for j in 7:
				pts.append(p + Vector2.from_angle(_aim + TAU * j / 7.0) * 48.0)
		_:   # checkerboard: your own cell burns, the neighbours are safe
			for gx in range(-2, 3):
				for gy in range(-2, 3):
					if (gx + gy) % 2 == 0:
						pts.append(p + Vector2(gx, gy) * 40.0)
	for j in pts.size():
		var delay := meteor_fall + (0.08 * j if i == 0 else 0.0)
		_fx.append(BossKit.telegraph_circle(self, pts[j], meteor_radius, delay, EMBER))
		_impacts.append({"pos": pts[j], "at": state_time + delay})


func _tick_meteor() -> void:
	if _step < 3 and state_time >= 0.5 + float(_step):
		_meteor_volley(_step)
		_step += 1
		BossKit.anim(self, "slam")
	var i := _impacts.size() - 1
	while i >= 0:
		var im: Dictionary = _impacts[i]
		if state_time >= float(im["at"]):
			var pos: Vector2 = im["pos"]
			BossKit.strike_circle(self, pos, meteor_radius, meteor_damage, false, EMBER)
			BossKit.shake(self, 1.5, 0.1)
			_impacts.remove_at(i)
		i -= 1
	if _step >= 3 and _impacts.is_empty() and state_time >= 3.6:
		_enter(State.RECOVER)


# --- limit break: Ruwatan Eclipse. Eight wedges fill, one stays safe (it pulses gold). ---

func _begin_ruwatan() -> void:
	_enter(State.RUWATAN)
	_recover_len = ult_recovery
	_ru_base = randf() * TAU
	_ru_safe = randi() % 8
	_ru_pulse = 0.0
	BossKit.roar(self, VIOLET, 130.0)
	BossKit.anim(self, "cast")
	var w := TAU / 8.0
	for i in 8:
		if i != _ru_safe:
			_fx.append(BossKit.telegraph_cone(self, global_position, _ru_base + w * (i + 0.5), w, arena_radius, ruwatan_windup, Color(0.8, 0.2, 0.5)))


func _ru_wedge_dir(i: int) -> float:
	return _ru_base + TAU / 8.0 * (i + 0.5)


func _tick_ruwatan(delta: float) -> void:
	if _step == 0:
		_ru_pulse -= delta
		if _ru_pulse <= 0.0:
			_ru_pulse = 0.45
			var at := global_position + Vector2.from_angle(_ru_wedge_dir(_ru_safe)) * 70.0
			BossKit.ring_fx(self, at, 22.0, 0.45, GOLD)
			BossKit.sparks(self, at, GOLD, 6, 25.0, 0.5)
		if state_time >= ruwatan_windup:
			_step = 1
			BossKit.anim(self, "slam")
			BossKit.flash_fx(self, global_position, 150.0, 0.5, Color(1, 1, 1))
			BossKit.shake(self, 3.0, 0.5)
			for i in 8:
				if i != _ru_safe:
					BossKit.slash(self, global_position, _ru_wedge_dir(i), TAU / 8.0, arena_radius * 0.7, VIOLET)
					BossKit.beam_fx(self, global_position, global_position + Vector2.from_angle(_ru_wedge_dir(i)) * arena_radius, 10.0, 0.4, VIOLET)
			var rel := BossKit.player_point(self) - global_position
			if rel.length() <= arena_radius + BossKit.HURT_RADIUS and rel.x != INF:
				var idx := int(floor(wrapf(rel.angle() - _ru_base, 0.0, TAU) / (TAU / 8.0)))
				if idx != _ru_safe:
					BossKit.hurt_player(self, ruwatan_damage, true)
			_enter(State.RECOVER)


## Damage through the player's Hurtbox, so dodge i-frames refuse it.
func _hurt(amount: int, heavy: bool) -> void:
	var hb := target.get_node_or_null("Hurtbox") as Hurtbox if target != null else null
	if hb == null:
		return
	attack_hitbox.damage = amount
	attack_hitbox.heavy = heavy
	hb.receive(attack_hitbox)


func _circle(r: float, n: int, closed: bool) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n + int(closed):
		pts.append(Vector2.from_angle(TAU * i / n) * r)
	return pts


func _clear_attack() -> void:
	for n: Node in _marks + [_ring, _fill]:
		if is_instance_valid(n):
			n.queue_free()
	for n: Node in _fx:
		if is_instance_valid(n):
			n.queue_free()
	_marks.clear()
	_fx.clear()
	_sw_lines.clear()
	_impacts.clear()
	_spots.clear()
	_ring = null
	_fill = null


# --- the shield ---

func _raise_shield() -> void:
	shielded = true
	_elapsed = 0.0
	health.invincible_time = 1.0e9   # Health refuses damage while invincible: the cleanest block
	_new_sequence()
	if _shield == null:
		_shield = Polygon2D.new()
		_shield.polygon = _circle(18.0, 24, false)
		_shield.color = Color(0.6, 0.8, 1.0, 0.35)
		_shield.position = Vector2(0, -14)
		_shield.z_index = 1
		add_child(_shield)
	_shield.visible = true
	BossKit.roar(self, ICE, 90.0)


func _new_sequence() -> void:
	seq_index = 0
	_elapsed = 0.0
	var pool := PackedStringArray(get_node("/root/Game").glyphs_learned)
	if pool.is_empty():
		pool = PackedStringArray(["sunda_ka"])
	sequence = PackedStringArray()
	if "jawa_ka" in pool:   # bestiary.md: a Sunda glyph, a Jawa glyph, then Ombak breaks the shield
		var sunda := Array(pool).filter(func(g: String) -> bool: return g.begins_with("sunda_"))
		var jawa := Array(pool).filter(func(g: String) -> bool: return g.begins_with("jawa_") and g != "jawa_ka")
		var rest := Array(pool).filter(func(g: String) -> bool: return g != "jawa_ka")
		if rest.is_empty():
			rest = ["jawa_ka"]
		sequence.append(sunda.pick_random() if not sunda.is_empty() else rest.pick_random())
		sequence.append(jawa.pick_random() if not jawa.is_empty() else rest.pick_random())
		sequence.append("jawa_ka")
	elif pool.size() >= 3:
		var a := Array(pool)
		a.shuffle()
		sequence = PackedStringArray(a.slice(0, 3))
	else:
		for i in 3:
			sequence.append(pool[randi() % pool.size()])
	if _sabotaged():
		seq_index = 1   # ASSUMED (v5): Laras has already spoken the first name, so the first glyph is done


func _break_shield() -> void:
	shielded = false
	dawn = null
	health.invincible_time = 0.0
	_open_left = open_time
	_shield.visible = false
	BossKit.flash_fx(self, global_position + Vector2(0, -14), 40.0, 0.4, Color(1, 1, 1))
	BossKit.sparks(self, global_position + Vector2(0, -14), ICE, 20, 90.0, 0.6)
	_enter(State.STUN)


func _on_cast(glyph_id: String, _score: float) -> void:
	if not shielded or dead or state == State.PAUSE or sequence.size() < 3:
		return
	if glyph_id == sequence[seq_index]:
		seq_index += 1
	else:
		seq_index = 1 if glyph_id == sequence[0] else 0
	if seq_index >= sequence.size():
		_break_shield()


func _on_health(hp: int, max_hp: int) -> void:
	engaged = true   # first hit
	if hp <= 0:
		return
	if phase == 1 and hp * 3 <= max_hp * 2:
		phase = 2
		_deck.clear()
		_enter(State.PAUSE)
		_raise_shield()
		BossKit.ring_fx(self, global_position, 150.0, 0.9, VIOLET)
		BossKit.shake(self, 3.0, 0.5)
	if phase == 2 and hp * 3 <= max_hp:
		phase = 3
		_deck.clear()
		_since_ult = 3   # the first Ruwatan Eclipse comes after two moves
		_enter(State.PAUSE)
		_raise_shield()
		BossKit.ring_fx(self, global_position, 170.0, 0.9, VIOLET)
		BossKit.shake(self, 3.0, 0.5)


## Story v5: Laras's sabotage flag is set (Game.has_flag, underscore form).
func _sabotaged() -> bool:
	var g := get_node_or_null("/root/Game")
	return g != null and sabotage_flag != "" and g.has_flag(sabotage_flag)


func _on_flinch() -> void:
	pass   # bosses do not flinch


func _on_died() -> void:
	_clear_attack()
	body.visible = true
	if _shield != null:
		_shield.visible = false
	dawn = null
	shielded = false
	super()
	# Released, not killed: he lowers his hands and fades into the clock face, then announce.
	var tw := body.create_tween().set_parallel()
	tw.tween_property(body, "modulate:a", 0.0, 0.35)
	tw.tween_property(body, "scale:y", 0.6, 0.35)
	var events := get_node("/root/Events")
	get_tree().create_timer(0.3).timeout.connect(func() -> void: events.boss_defeated.emit("batara_kala"))
