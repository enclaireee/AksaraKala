class_name BataraKala extends EnemyBase
## Final boss: Batara Kala (bestiary.md "Final: Gua Kala", build spec P0). A deity, calmed and turned back, never killed.
## Phase 1: devouring pulse (a thin ring) and time-sand (ground-marked circles). Phase 2 (66%): a shield with a
## 3-glyph sequence and a countdown; the right casts in order break it. Phase 3 (33%): faster, 20 s, 5 circles.
## Defeat is a release: EnemyBase death (Ilmu, enemy_killed) then Events.boss_defeated.
## The HUD polls: group "boss", health, boss_name_key, engaged, dawn (null or 0..1), sequence, seq_index.
# ponytail: damage goes straight through the player's Hurtbox (so i-frames refuse it), no physics hitbox sweeps.

enum State { IDLE, CHASE, PULSE_WIND, PULSE, SAND_WIND, RECOVER, PAUSE, STUN, DEVOUR }

const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const STUNNED := Color(0.7, 0.75, 1.0)

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
@export var pause_time := 1.0          # TUNE
@export var stun_time := 3.0           # TUNE
@export var open_time := 10.0          # TUNE: total seconds the shield stays down after breaking
@export var countdown_p2 := 30.0       # TUNE
@export var countdown_p3 := 20.0       # TUNE
@export var devour_time := 2.0         # TUNE: the red ring fills the arena
@export var devour_damage := 60        # TUNE, heavy
@export var arena_radius := 176.0      # TUNE
@export var wind_p3 := 0.7             # TUNE: wind-up multiplier in phase 3

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
var _elapsed := 0.0
var _open_left := 0.0
var _next_pulse := true
var _ring_r := 0.0
var _hit_ring := false
var _marks: Array[Polygon2D] = []
var _spots: Array[Vector2] = []
var _ring: Line2D
var _fill: Polygon2D
var _shield: Polygon2D


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
			if state_time >= 0.6:
				_begin_pulse() if _next_pulse else _begin_sand()
				_next_pulse = not _next_pulse
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
					if target != null and target.global_position.distance_to(s) <= sand_radius:
						_hurt(sand_damage, false)
				_enter(State.RECOVER)
		State.RECOVER:
			if state_time >= recovery * k:
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
				_hurt(devour_damage, true)
				_new_sequence()
				_enter(State.CHASE)
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
	velocity = Vector2.ZERO
	body.modulate = STUNNED if s == State.STUN else Color.WHITE
	if s == State.PULSE_WIND or s == State.SAND_WIND:
		body.modulate = Color(1.0, 0.45, 0.45)
	if s == State.DEVOUR:
		_fill = Polygon2D.new()
		_fill.polygon = _circle(arena_radius, 48, false)
		_fill.color = Color(1.0, 0.1, 0.1, 0.3)
		_fill.z_index = -1
		_fill.scale = Vector2.ZERO
		add_child(_fill)


func _begin_pulse() -> void:
	_enter(State.PULSE_WIND)
	var m := Polygon2D.new()   # the ring's reach, drawn on the ground during the wind-up
	m.polygon = _circle(pulse_radius, 32, false)
	m.color = Color(1.0, 0.3, 0.3, 0.12)
	m.z_index = -1
	add_child(m)
	m.position = Vector2(0, -6)
	_marks.append(m)


func _begin_sand() -> void:
	_enter(State.SAND_WIND)
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
	_marks.clear()
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
		_enter(State.PAUSE)
		_raise_shield()
	if phase == 2 and hp * 3 <= max_hp:
		phase = 3
		_enter(State.PAUSE)
		_raise_shield()


## Story v5: Laras's sabotage flag is set (Game.has_flag, underscore form).
func _sabotaged() -> bool:
	var g := get_node_or_null("/root/Game")
	return g != null and sabotage_flag != "" and g.has_flag(sabotage_flag)


func _on_flinch() -> void:
	pass   # bosses do not flinch


func _on_died() -> void:
	_clear_attack()
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
