class_name ButoIjo extends EnemyBase
## Miniboss: Buto Ijo (bestiary.md "Build spec"). Four pouch phases (100/75/50/25%), each adds 3 fields that only hurt him.
## Defeat: EnemyBase death, then Events.boss_defeated. The quest step sets mq3_4 (as with Bondowoso).
## The HUD polls: group "boss", health, boss_name_key, engaged.
# ponytail: Timun Mas is not a node. The arena centre is where the player stood when the fight began unless arena_center is set.
# Heavy hits landing free while stunned needs nothing: Buto has no shield, so every hit lands.

enum State { IDLE, CHASE, WINDUP, CHARGE, RECOVER, PAUSE, STUN, MOVE }

const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const GREEN := Color(0.45, 0.9, 0.2)
const HUNGER := Color(1.0, 0.45, 0.15)
const MOVES_ALL := ["pound", "charge", "devour", "seed_volley", "bramble_stomp", "hunger_leap", "rampage", "quake"]   # the deck; famine_maw is the limit break
const HEAVY := ["pound", "charge", "devour", "hunger_leap", "rampage", "quake", "famine_maw"]
const FIELD_SCENE := preload("res://entities/bosses/pouch_field.tscn")
const KINDS := ["bramble", "bamboo", "salt", "mud"]
const AMBUSH_RETREAT := {"buto_ambush_1": 0.80, "buto_ambush_2": 0.65, "buto_ambush_3": 0.50}   # TUNE: HP fraction he retreats at (quests.md 7.1)
const ROWS := [0.2, 0.4, 0.6, 0.8]   # TUNE: per phase, how far from his start to the arena centre its 3 fields sit

@export var boss_name_key := "BOSS_BUTO_IJO"
@export var speed := 30.0              # TUNE
@export var engage_range := 128.0      # 8 tiles
@export var arena_center := Vector2.INF
## Stalking ambush (v5): "buto_ambush_1..3" makes him retreat at that HP and emit area_cleared. "" = the lair fight.
## Left empty, _ready takes it from an Encounter sibling whose area_id starts with "buto_ambush_" (the zone he is placed in).
@export var ambush_id := ""
@export var retreat_fade := 0.6        # TUNE: seconds he takes to slip away
@export var charge_min := 64.0         # spec
@export var charge_max := 200.0        # spec
@export var charge_length := 220.0     # spec
@export var charge_speed := 320.0      # TUNE
@export var charge_windup := 0.8       # spec
@export var charge_damage := 41        # spec, heavy
@export var pound_range := 56.0        # spec
@export var pound_radius := 48.0       # spec
@export var pound_windup := 0.8        # spec
@export var pound_damage := 41         # spec, heavy
@export var recovery := 1.2            # TUNE
@export var pause_time := 1.0          # spec: the roar
@export var field_spread := 36.0       # TUNE: sideways gap between a phase's fields
@export var bramble_slow := 0.5        # spec: speed multiplier
@export var salt_slow := 0.4           # spec: 60% slow
@export var bamboo_stun := 1.5         # spec
@export var mud_bind := 2.0            # spec
@export var mud_rest := 4.0            # spec
@export var heavy_recovery := 2.2      # TUNE: punish window after a heavy move
@export var devour_range := 64.0       # TUNE: close enough to start the grab
@export var devour_length := 60.0      # TUNE
@export var devour_arc := 100.0        # TUNE, degrees
@export var devour_windup := 0.9       # TUNE, heavy
@export var devour_damage := 50        # TUNE: ~1.2x heavy, the big bite
@export var seed_windup := 0.6         # TUNE
@export var seed_damage := 14          # TUNE, light
@export var seed_speed := 130.0        # TUNE
@export var stomp_windup := 0.7        # TUNE
@export var stomp_damage := 18         # TUNE, light
@export var zone_damage := 8           # TUNE: bramble patch tick
@export var leap_windup := 0.9         # TUNE
@export var leap_time := 0.5           # TUNE: seconds in the air
@export var leap_radius := 36.0        # TUNE
@export var leap_damage := 41          # TUNE, heavy
@export var rampage_chain := 3         # TUNE: charges in a row
@export var chain_windup := 0.55       # TUNE: telegraph of the 2nd and 3rd charge
@export var quake_windup := 0.55       # TUNE: between waves
@export var quake_damage := 28         # TUNE: one wave, dodge through it
@export var maw_windup := 2.2          # TUNE: limit break telegraph
@export var maw_outer := 150.0         # TUNE
@export var maw_inner := 36.0          # TUNE: the safe spot hugs him
@export var maw_damage := 60           # TUNE: ~1.5x heavy

var state := State.IDLE
var state_time := 0.0
var phase := 0                         # 0 until the fight starts
var engaged := false
var attacks := 0
var fields: Array[PouchField] = []
var _start := Vector2.ZERO
var _dir := Vector2.RIGHT
var _from := Vector2.ZERO
var _pound := false
var _blast_left := 0.0
var retreated := false
var moves_used: Dictionary = {}        # move name -> times started (tests)
var forced_move := ""                  # tests: "" = the deck, a move name = only that one, anything else = no move
var _deck: Array[String] = []
var _last_move := ""
var _move := ""
var _stage := 0
var _spot := Vector2.ZERO
var _chain_left := 0
var _chain_idx := 0
var _quake_left := 0
var _since_ult := 0
var _rec := 1.2
var _ghost_t := 0.0
var _body_pos := Vector2.ZERO
var _tgs: Array[Node2D] = []


func _ready() -> void:
	super()
	if dead or is_queued_for_deletion():
		return
	add_to_group("boss")
	_start = global_position
	_body_pos = body.position
	health.changed.connect(_on_health)
	if ambush_id == "":
		_find_ambush.call_deferred()   # siblings may be added after him


func _find_ambush() -> void:
	if ambush_id != "" or not is_inside_tree() or get_parent() == null:
		return
	for n in get_parent().get_children():
		var a: Variant = n.get("area_id")
		if a is String and a.begins_with("buto_ambush_"):
			ambush_id = a
			return


## Retreat threshold of this ambush as an HP fraction, or 0.0 in the lair fight.
func retreat_at() -> float:
	return AMBUSH_RETREAT.get(ambush_id, 0.0)


func in_field(kind: String) -> bool:
	for f in fields:
		if f.kind == kind and f.contains(global_position):
			return true
	return false


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
		_engage()
	_field_effects(delta)
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
				velocity = to_t.normalized() * speed * slow() if d > pound_range else Vector2.ZERO
		State.WINDUP:
			if state_time >= _windup_len():
				if _pound:
					_land()
					_enter(State.RECOVER)
				else:
					_start_charge()
		State.CHARGE:
			_ghost_t -= delta
			if _ghost_t <= 0.0:
				_ghost_t = 0.05
				BossKit.ghost(self, Color(0.4, 1.0, 0.3), 0.3)
			if in_field("bamboo"):
				_end_charge(State.STUN)
			elif global_position.distance_to(_from) >= charge_length or (state_time > 0.05 and is_on_wall()):
				_end_charge(State.RECOVER)
		State.MOVE:
			_tick_move(delta)
		State.RECOVER:
			if state_time >= _rec:
				_enter(State.CHASE)
		State.PAUSE:
			if state_time >= pause_time:
				_enter(State.CHASE)
		State.STUN:
			if state_time >= bamboo_stun:
				_enter(State.CHASE)
	move_and_slide()


func _engage() -> void:
	if engaged:
		return
	engaged = true
	if arena_center == Vector2.INF and target != null:
		arena_center = target.global_position
	if phase == 0:
		_next_phase()


# --- pouches ---

func _field_effects(delta: float) -> void:
	for f in fields:
		f.rest_left = maxf(0.0, f.rest_left - delta)
		var now := f.contains(global_position)
		match f.kind:
			"bramble":
				if now and status:
					status.apply(Status.Type.SLOW, 0.1, bramble_slow)
			"salt":
				if now and status:
					status.apply(Status.Type.SLOW, 0.1, salt_slow)
			"mud":
				if now and not f.inside and f.rest_left <= 0.0 and status:
					status.apply(Status.Type.BOUND, mud_bind)
					f.rest_left = mud_rest
		f.inside = now


func _next_phase() -> void:
	phase += 1
	_spawn_fields(KINDS[phase - 1])
	if phase > 1:
		attack_hitbox.deactivate()
		_chain_left = 0
		_chain_idx = 0
		_enter(State.PAUSE)   # the roar; phase 1 starts as the fight does
		BossKit.roar(self, HUNGER, 90.0)


func _spawn_fields(kind: String) -> void:
	var c := arena_center if arena_center != Vector2.INF else _start
	var along := (c - _start)
	var side := along.orthogonal().normalized() if along.length() > 1.0 else Vector2.DOWN
	for i in 3:
		var f := FIELD_SCENE.instantiate() as PouchField
		f.kind = kind
		var spot := _start.lerp(c, ROWS[phase - 1]) + side * field_spread * (i - 1)
		f.position = spot
		get_parent().add_child(f)
		f.global_position = spot
		fields.append(f)


func _on_health(hp: int, max_hp: int) -> void:
	_engage()   # first hit
	var r := retreat_at()
	if r > 0.0 and not retreated and hp > 0 and hp <= max_hp * r:
		retreated = true
		_retreat.call_deferred()   # the hit can come mid physics query
		return
	while phase > 0 and phase < 4 and hp > 0 and hp * 4 <= max_hp * (4 - phase):
		_next_phase()


## Ambush over: he drops back into the grass (not killed, so the lair fight stays), the encounter reports cleared.
func _retreat() -> void:
	if dead or is_queued_for_deletion():
		return
	engaged = false
	set_physics_process(false)
	attack_hitbox.deactivate()
	_clear_attack()
	BossKit.anim_stop(self)
	velocity = Vector2.ZERO
	remove_from_group("boss")
	remove_from_group("enemy")
	hurtbox.set_deferred("monitorable", false)
	for f in fields:
		if is_instance_valid(f):
			f.queue_free()
	fields.clear()
	var tw := body.create_tween()
	tw.tween_property(body, "modulate:a", 0.0, retreat_fade)
	tw.tween_callback(queue_free)
	get_node("/root/Events").area_cleared.emit(ambush_id)


# --- move deck ---

func _eligible(m: String, d: float) -> bool:
	var salt: bool = in_field("salt")
	match m:
		"pound":
			return d <= pound_range
		"charge":
			return d >= charge_min and d <= charge_max and not salt
		"devour":
			return d <= devour_range
		"seed_volley":
			return d >= 80.0 and d <= 240.0
		"bramble_stomp":
			return d <= 130.0
		"hunger_leap":
			return d >= 72.0 and d <= 220.0 and not salt
		"rampage":
			return phase >= 2 and d >= charge_min and d <= charge_max and not salt
		"quake":
			return phase >= 2 and d <= 100.0
		"famine_maw":
			return phase >= 3 and d <= 240.0 and _since_ult >= (3 if phase >= 4 else 5)
	return false


func _refill() -> void:
	_deck.clear()
	for m in MOVES_ALL:
		var mv: String = m
		_deck.append(mv)
	_deck.shuffle()


## The next move for this distance: the limit break when it is due, else the next fitting card of a shuffled deck.
## A heavy move never repeats back to back. "" = nothing fits, keep walking.
func _pick_move(d: float) -> String:
	if forced_move != "":
		return forced_move if _eligible(forced_move, d) else ""
	if _eligible("famine_maw", d):
		return "famine_maw"
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
	_since_ult = 0 if m == "famine_maw" else _since_ult + 1
	_rec = heavy_recovery if HEAVY.has(m) else recovery
	_move = m
	_chain_left = 0
	_chain_idx = 0
	match m:
		"pound":
			_begin_attack(true)
		"charge":
			_begin_attack(false)
		"rampage":
			_chain_left = rampage_chain - 1
			_rec = heavy_recovery + 0.6
			_begin_attack(false)
		_:
			_begin_move(m)


# --- attacks (ground telegraphs from BossKit) ---

func _enter(s: State) -> void:
	_clear_attack()
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	body.modulate = Color(1.0, 0.45, 0.45) if s == State.WINDUP or s == State.MOVE else (Color(0.7, 0.75, 1.0) if s == State.STUN else Color.WHITE)
	if s == State.CHASE or s == State.STUN or s == State.RECOVER or s == State.PAUSE:
		BossKit.anim_stop(self)
		body.position = _body_pos


func _windup_len() -> float:
	if _pound:
		return pound_windup
	if _chain_idx > 0:
		return chain_windup
	return charge_windup


func _tg(t: Node2D) -> void:
	_tgs.append(t)


func _begin_attack(pound: bool) -> void:
	_enter(State.WINDUP)
	_pound = pound
	_dir = (target.global_position - global_position).normalized()
	if pound:
		BossKit.anim(self, "slam", 10.0, true)
		_tg(BossKit.telegraph_circle(self, global_position, pound_radius, pound_windup, HUNGER))
	else:
		BossKit.anim(self, "dash", 10.0, true)
		_tg(BossKit.telegraph_line(self, global_position, global_position + _dir * charge_length, 16.0, _windup_len(), HUNGER))


func _land() -> void:
	attacks += 1
	attack_hitbox.global_position = global_position
	(attack_hitbox.get_node("Shape") as CollisionShape2D).shape.radius = pound_radius
	attack_hitbox.damage = pound_damage
	attack_hitbox.heavy = true
	attack_hitbox.activate()
	_blast_left = 0.15
	BossKit.ring_fx(self, global_position, pound_radius, 0.3, HUNGER)
	BossKit.sparks(self, global_position, Color(0.6, 0.45, 0.25), 12, 80.0, 0.4)
	BossKit.punch(self, 1.15, 0.88, 0.25)
	BossKit.shake(self, 2.0, 0.25)


func _start_charge() -> void:
	attacks += 1
	_enter(State.CHARGE)
	_from = global_position
	_ghost_t = 0.0
	velocity = _dir * charge_speed
	(attack_hitbox.get_node("Shape") as CollisionShape2D).shape.radius = 14.0
	attack_hitbox.position = Vector2.ZERO
	attack_hitbox.damage = charge_damage
	attack_hitbox.heavy = true
	attack_hitbox.activate()


func _end_charge(next: State) -> void:
	attack_hitbox.deactivate()
	if next == State.RECOVER and _chain_left > 0 and target != null:
		_chain_left -= 1   # rampage: turn and charge again at once
		_chain_idx += 1
		_begin_attack(false)
		return
	_chain_left = 0
	_chain_idx = 0
	_enter(next)


func _clear_attack() -> void:
	for t in _tgs:
		if is_instance_valid(t):
			t.queue_free()
	_tgs.clear()


# --- scripted moves (State.MOVE): _move names it, _stage and state_time drive it ---

func _stage_to(n: int) -> void:
	_stage = n
	state_time = 0.0


func _aim() -> void:
	if target != null:
		_dir = (target.global_position - global_position).normalized()


func _begin_move(m: String) -> void:
	_enter(State.MOVE)
	_stage = 0
	_aim()
	match m:
		"devour":
			BossKit.anim(self, "slam", 10.0, true)
			_tg(BossKit.telegraph_cone(self, global_position, _dir.angle(), deg_to_rad(devour_arc), devour_length, devour_windup, GREEN))
		"seed_volley":
			BossKit.anim(self, "cast", 10.0, true)
			_tg(BossKit.telegraph_cone(self, global_position, _dir.angle(), deg_to_rad(70.0), 90.0, seed_windup, GREEN))
		"bramble_stomp":
			BossKit.anim(self, "slam", 10.0, true)
			_tg(BossKit.telegraph_circle(self, global_position, 40.0, stomp_windup, GREEN))
		"hunger_leap":
			BossKit.anim(self, "cast", 10.0, true)
			_spot = target.global_position
			_tg(BossKit.telegraph_circle(self, _spot, leap_radius, leap_windup, HUNGER))
		"quake":
			_quake_left = 3 if phase >= 3 else 2
			BossKit.anim(self, "slam", 10.0, true)
			_tg(BossKit.telegraph_circle(self, global_position, 40.0, quake_windup, HUNGER))
		"famine_maw":
			BossKit.anim(self, "cast", 6.0, true)
			_tg(BossKit.telegraph_ring(self, global_position, maw_outer, maw_inner, maw_windup, Color(1.0, 0.3, 0.1)))
			BossKit.flash_fx(self, global_position + Vector2(0, -14), 24.0, 0.4, HUNGER)


func _end_move() -> void:
	_enter(State.RECOVER)


func _tick_move(delta: float) -> void:
	var at := global_position
	match _move:
		"devour":
			if state_time >= devour_windup:
				attacks += 1
				BossKit.punch(self, 1.2, 0.85, 0.3)
				var bit: bool = BossKit.strike_cone(self, at, _dir.angle(), deg_to_rad(devour_arc), devour_length, devour_damage, true, GREEN)
				BossKit.shake(self, 2.0, 0.25)
				if not bit:
					_rec += 0.6   # snapped at nothing: he is slow to close his jaws
				_end_move()
		"seed_volley":
			if state_time >= seed_windup:
				attacks += 1
				var n: int = 7 if phase >= 2 else 5
				BossKit.fan(self, at + Vector2(0, -8), _dir.angle(), deg_to_rad(70.0), n, seed_speed, seed_damage, GREEN, "shard", 4.0, 2.5)
				BossKit.sparks(self, at + Vector2(0, -8), GREEN, 8, 60.0, 0.3)
				if phase >= 2 and _stage == 0:
					_aim()   # a second volley, re-aimed, with its own telegraph
					_clear_attack()
					_tg(BossKit.telegraph_cone(self, at, _dir.angle(), deg_to_rad(70.0), 90.0, seed_windup, GREEN))
					_stage_to(1)
				else:
					_end_move()
		"bramble_stomp":
			if state_time >= stomp_windup:
				attacks += 1
				BossKit.strike_circle(self, at, 40.0, stomp_damage, false, GREEN)
				BossKit.shake(self, 1.5, 0.2)
				var reach: Array[float] = [56.0, 96.0, 136.0]
				for r in reach:
					BossKit.zone(self, at + _dir * r, 24.0, zone_damage, 5.0, Color(0.3, 0.7, 0.2), 0.7)
				if phase >= 3:
					BossKit.zone(self, at + _dir.rotated(0.9) * 80.0, 24.0, zone_damage, 5.0, Color(0.3, 0.7, 0.2), 0.7)
					BossKit.zone(self, at + _dir.rotated(-0.9) * 80.0, 24.0, zone_damage, 5.0, Color(0.3, 0.7, 0.2), 0.7)
				_end_move()
		"hunger_leap":
			_tick_leap(at, delta)
		"quake":
			if state_time >= quake_windup:
				attacks += 1
				BossKit.wave(self, at, 130.0, 100.0, quake_damage, HUNGER, true)
				BossKit.ring_fx(self, at, 40.0, 0.3, HUNGER)
				BossKit.punch(self, 1.12, 0.9, 0.2)
				BossKit.shake(self, 2.0, 0.2)
				_quake_left -= 1
				if _quake_left > 0:
					_clear_attack()
					_tg(BossKit.telegraph_circle(self, at, 40.0, quake_windup, HUNGER))
					state_time = 0.0
				else:
					_end_move()
		"famine_maw":
			if state_time >= maw_windup:
				attacks += 1
				var d: float = BossKit.player_point(self).distance_to(at)
				BossKit.roar(self, HUNGER, maw_outer)
				BossKit.ring_fx(self, at, maw_outer, 0.5, Color(1.0, 0.3, 0.1))
				BossKit.shake(self, 3.0, 0.5)
				if d >= maw_inner and d <= maw_outer:
					BossKit.hurt_player(self, maw_damage, true)
				_rec = heavy_recovery + 0.8
				_end_move()
		_:
			_end_move()


## Hunger-leap: a fixed landing marker, then a hop over the arena onto it.
func _tick_leap(at: Vector2, delta: float) -> void:
	if _stage == 0:
		if state_time >= leap_windup:
			_from = at
			_ghost_t = 0.0
			BossKit.anim(self, "dash", 10.0, true)
			_clear_attack()
			_stage_to(1)
	else:
		var f: float = clampf(state_time / leap_time, 0.0, 1.0)
		global_position = _from.lerp(_spot, f)
		body.position = _body_pos + Vector2(0, -sin(f * PI) * 28.0)
		_ghost_t -= delta
		if _ghost_t <= 0.0:
			_ghost_t = 0.08
			BossKit.ghost(self, Color(0.4, 1.0, 0.3), 0.3)
		if f >= 1.0:
			attacks += 1
			body.position = _body_pos
			BossKit.strike_circle(self, _spot, leap_radius, leap_damage, true, HUNGER)
			BossKit.punch(self, 1.2, 0.8, 0.3)
			BossKit.shake(self, 2.5, 0.3)
			_end_move()


func _on_flinch() -> void:
	pass   # bosses do not flinch


func _on_died() -> void:
	_clear_attack()
	BossKit.anim_stop(self)
	body.position = _body_pos
	super()
	# Sinks to his knees in the mud; Timun Mas is safe off screen.
	var tw := body.create_tween().set_parallel()
	tw.tween_property(body, "modulate:a", 0.0, 0.35)
	tw.tween_property(body, "scale:y", 0.6, 0.35)
	var events := get_node("/root/Events")
	get_tree().create_timer(0.3).timeout.connect(func() -> void: events.boss_defeated.emit("buto_ijo"))
