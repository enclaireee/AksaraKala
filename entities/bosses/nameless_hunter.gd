class_name NamelessHunter extends EnemyBase
## Boss: the Nameless Hunter (bestiary.md Story v2). A silent stalker: shadow-step with a ground marker, chain hook that pulls,
## and Forget: a cone that empties sakti and locks casting. A Ga Ward up when it lands blocks it.
## Added (boss redesign): twin slash (two telegraphed blinks, each a cone), void lance (long line), phantom decoys that explode,
## and the limit break Erasure (a huge Forget cone, then one behind him; stand at his flank).
## Phase 2 at 50% HP: the mask cracks, steps come in pairs (Forget follows the second) and everything is quicker.
## Defeat: EnemyBase death, then Events.boss_defeated("nameless_hunter").
## The HUD polls: group "boss", health, boss_name_key, engaged.
# ponytail: the pull is a collision-checked slide, not an animated chain.

enum State { IDLE, CHASE, FADE, MARK, HOOK, FORGET, RECOVER, MOVE }

const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const PALE := Color(0.85, 0.85, 1.0, 0.4)
const MASK := Color(0.85, 0.85, 1.0)
const VOID := Color(0.55, 0.35, 0.95)
const RED := Color(1.0, 0.25, 0.2)
const MOVES_ALL := ["step", "hook", "forget", "twin_slash", "void_lance", "decoys"]   # the deck; erasure is the limit break
const HEAVY := ["void_lance", "decoys", "erasure"]

@export var boss_name_key := "BOSS_NAMELESS_HUNTER"
@export var cond := ""                   # Game.check condition; empty = always on
@export var speed := 55.0                # spec
@export var engage_range := 128.0        # 8 tiles
@export var fade_time := 0.3             # spec
@export var mark_time := 0.6             # spec: ground marker before he reappears
@export var step_damage := 22            # spec, heavy
@export var step_radius := 20.0          # TUNE: marker and cut radius
@export var step_behind := 24.0          # TUNE: the marker sits this far past the player
@export var hook_windup := 0.6           # spec
@export var hook_len := 128.0            # spec: 8 tiles
@export var hook_damage := 16            # spec, light
@export var hook_pull := 48.0            # spec: 3 tiles
@export var forget_windup := 0.8         # spec
@export var forget_radius := 64.0        # spec
@export var forget_arc := 90.0           # spec, degrees
@export var forget_lock := 4.0           # spec: seconds of cast lockout
@export var recovery := 1.0              # TUNE
@export var heavy_recovery := 2.0        # TUNE: punish window after a heavy move
@export var crack_pace := 0.85           # TUNE: phase 2 multiplier on fade, marker and slash times (markers stay >= 0.5 s)
@export var slash_windup := 0.6          # TUNE: marker before each blink of the twin slash
@export var slash_arc := 100.0           # TUNE, degrees
@export var slash_len := 52.0            # TUNE
@export var slash_damage := 16           # TUNE, light
@export var lance_len := 260.0           # TUNE
@export var lance_width := 14.0          # TUNE
@export var lance_windup := 0.9          # TUNE
@export var lance_damage := 28           # TUNE, heavy
@export var decoy_count := 3             # TUNE (phase 2: +1)
@export var decoy_windup := 1.4          # TUNE
@export var decoy_radius := 30.0         # TUNE
@export var decoy_spread := 56.0         # TUNE: decoys ring the player this far out; the middle is safe
@export var decoy_damage := 22           # TUNE, heavy
@export var erase_windup := 2.2          # TUNE: limit break telegraph
@export var erase_back := 1.0            # TUNE: the second cone, behind him
@export var erase_arc := 140.0           # TUNE, degrees
@export var erase_len := 150.0           # TUNE
@export var erase_damage := 33           # TUNE: 1.5x heavy, avoidable

var active := true   # EliteGuard flips it
var state := State.IDLE
var state_time := 0.0
var phase := 1
var engaged := false
var attacks := 0
var moves_used: Dictionary = {}          # move name -> times started (tests)
var forced_move := ""                    # tests: "" = the deck, a move name = only that one, anything else = no move
var _deck: Array[String] = []
var _last_move := ""
var _move := ""
var _stage := 0
var _since_ult := 0
var _rec := 1.0
var _steps_left := 0
var _spot := Vector2.ZERO
var _facing := Vector2.RIGHT
var _hooking := false
var _marker: Node2D
var _tgs: Array[Node2D] = []
var _decoys: Array[Vector2] = []
var _slash_i := 0
var _slash_total := 2
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
	attack_hitbox.hit_landed.connect(_on_hit_landed)


func _pace() -> float:
	return crack_pace if phase == 2 else 1.0


func _mark_len() -> float:
	return maxf(0.5, mark_time * _pace())


func _slash_wait() -> float:
	return maxf(0.5, slash_windup * _pace())


func _tick(delta: float) -> void:
	state_time += delta
	if _blast_left > 0.0:
		_blast_left -= delta
		if _blast_left <= 0.0:
			attack_hitbox.deactivate()
			_hooking = false
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
			else:
				var m: String = _pick_move(d)
				if m != "":
					_begin(m, to_t)
				else:
					velocity = to_t.normalized() * speed * (1.2 if phase == 2 else 1.0) * slow()
		State.FADE:
			if state_time >= fade_time * _pace():
				_spot = target.global_position + to_t.normalized() * step_behind if target != null else global_position
				_show_ring(step_radius, _spot, _mark_len())
				_enter_keep(State.MARK)
		State.MARK:
			if state_time >= _mark_len():
				_land_step()
		State.HOOK:
			if state_time >= hook_windup:
				_land_hook()
		State.FORGET:
			if state_time >= forget_windup:
				_land_forget()
		State.MOVE:
			_tick_move()
		State.RECOVER:
			if state_time >= _rec:
				_enter(State.CHASE)
	move_and_slide()


# --- move deck ---

func _eligible(m: String, d: float) -> bool:
	match m:
		"step":
			return d <= 400.0
		"hook":
			return d <= hook_len and d >= 24.0
		"forget":
			return d <= forget_radius - 8.0
		"twin_slash":
			return d <= 180.0
		"void_lance":
			return d >= 48.0 and d <= 240.0
		"decoys":
			return d <= 200.0
		"erasure":
			return phase >= 2 and d <= 200.0 and _since_ult >= 4
	return false


func _refill() -> void:
	_deck.clear()
	for m in MOVES_ALL:
		var mv: String = m
		_deck.append(mv)
	_deck.shuffle()


## The next move for this distance: the limit break when it is due, else the next fitting card of a shuffled deck.
## A heavy move never repeats back to back. "" = nothing fits, keep stalking.
func _pick_move(d: float) -> String:
	if forced_move != "":
		return forced_move if _eligible(forced_move, d) else ""
	if _eligible("erasure", d):
		return "erasure"
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


func _begin(m: String, to_t: Vector2) -> void:
	var n: int = int(moves_used.get(m, 0))
	moves_used[m] = n + 1
	_last_move = m
	_since_ult = 0 if m == "erasure" else _since_ult + 1
	_rec = heavy_recovery if HEAVY.has(m) else recovery
	_move = m
	match m:
		"step":
			_steps_left = 2 if phase == 2 else 1   # a pair in phase 2, then Forget
			if phase == 2:
				_rec = heavy_recovery
			_begin_step()
		"hook":
			_begin_cone(true, to_t)
		"forget":
			_begin_cone(false, to_t)
		_:
			_begin_move(m)


func _enter(s: State) -> void:
	_clear_all()
	_enter_keep(s)
	if s == State.CHASE or s == State.RECOVER:
		BossKit.anim_stop(self)


func _enter_keep(s: State) -> void:
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	body.modulate = Color(1.0, 0.45, 0.45) if s in [State.HOOK, State.FORGET] else Color.WHITE
	if s == State.FADE or s == State.MARK:
		body.modulate.a = 0.0
	_gone(s == State.FADE or s == State.MARK)


func _clear_all() -> void:
	if is_instance_valid(_marker):
		_marker.queue_free()
	_marker = null
	for t in _tgs:
		if is_instance_valid(t):
			t.queue_free()
	_tgs.clear()


## While faded he cannot be hit.
func _gone(on: bool) -> void:
	hurtbox.set_deferred("monitorable", not on and not dead)


func _begin_step() -> void:
	_enter(State.FADE)
	BossKit.ghost(self, PALE, 0.4)
	BossKit.sparks(self, global_position + Vector2(0, -10), MASK, 8, 50.0, 0.4)


func _land_step() -> void:
	_clear_all()
	BossKit.flash_fx(self, _spot + Vector2(0, -8), 20.0, 0.3, MASK)
	global_position = _spot
	BossKit.ghost(self, MASK, 0.35)
	attacks += 1
	_steps_left -= 1
	_enter(State.RECOVER)
	var cs := CircleShape2D.new()
	cs.radius = step_radius
	_strike(cs, Vector2.ZERO, step_damage)
	_blast_left = 0.15
	BossKit.ring_fx(self, _spot, step_radius, 0.25, MASK)
	if _steps_left > 0:
		_begin_step()   # phase 2: the second step follows at once
	elif phase == 2 and target != null:
		_begin_cone(false, target.global_position - global_position)


func _begin_cone(hook: bool, to_t: Vector2) -> void:
	_enter(State.HOOK if hook else State.FORGET)
	_facing = to_t.normalized()
	aim.rotation = _facing.angle()
	BossKit.anim(self, "cast", 10.0, true)
	if hook:
		_marker = BossKit.telegraph_line(self, global_position, global_position + _facing * hook_len, 8.0, hook_windup, RED)
	else:
		_marker = BossKit.telegraph_cone(self, global_position, _facing.angle(), deg_to_rad(forget_arc), forget_radius, forget_windup, MASK)


func _land_hook() -> void:
	attacks += 1
	var rect := RectangleShape2D.new()
	rect.size = Vector2(hook_len, 8)
	_strike(rect, Vector2(hook_len / 2.0, 0), hook_damage)
	_hooking = true
	_blast_left = 0.15
	BossKit.beam_fx(self, global_position, global_position + _facing * hook_len, 5.0, 0.3, MASK)
	_enter(State.RECOVER)


## A hook that connects pulls the player toward him.
func _on_hit_landed(_hb: Hurtbox) -> void:
	if not _hooking or not target is CharacterBody2D:
		return
	_hooking = false
	var gap := target.global_position - global_position
	(target as CharacterBody2D).move_and_collide(-gap.normalized() * minf(hook_pull, maxf(gap.length() - 16.0, 0.0)))


func _land_forget() -> void:
	attacks += 1
	_enter(State.RECOVER)
	BossKit.slash(self, global_position, _facing.angle(), deg_to_rad(forget_arc), forget_radius, MASK)
	if target == null or target.global_position.distance_to(global_position) > forget_radius:
		return
	var off := target.global_position - global_position
	if absf(angle_difference(_facing.angle(), off.angle())) > deg_to_rad(forget_arc / 2.0):
		return
	_forget_effect()


func _warded() -> bool:
	return not get_tree().get_nodes_in_group("ward").is_empty()


## Empties sakti and locks casting. A Ga Ward up blocks it completely.
func _forget_effect() -> void:
	if _warded():
		return   # Ga Ward blocks it completely
	if target == null:
		return
	var sakti := target.get("sakti") as SaktiGauge
	if sakti != null:
		sakti.value = 0.0
		sakti.changed.emit(0.0, sakti.max_value)
	var cast: Object = target.get("cast")
	if cast != null:
		cast.call("_lock")   # the existing lockout (also ends a cast in progress), stretched to forget_lock
		cast.set("_locked_until", Time.get_ticks_msec() + int(forget_lock * 1000.0))


## The step's ground ring, in the world (not under Aim).
func _show_ring(r: float, pos: Vector2, life: float) -> void:
	_marker = BossKit.telegraph_circle(self, pos, r, life, RED)


func _strike(shape: Shape2D, at: Vector2, dmg: int) -> void:
	(attack_hitbox.get_node("Shape") as CollisionShape2D).shape = shape
	attack_hitbox.position = at
	attack_hitbox.damage = dmg
	attack_hitbox.heavy = dmg > 18
	attack_hitbox.activate()


# --- scripted moves (State.MOVE): _move names it, _stage and state_time drive it ---

func _stage_to(n: int) -> void:
	_stage = n
	state_time = 0.0


func _end_move() -> void:
	_enter(State.RECOVER)   # also shows him again


func _player_ground() -> Vector2:
	return target.global_position if target != null else global_position


func _begin_move(m: String) -> void:
	_enter(State.MOVE)
	_stage = 0
	_facing = (_player_ground() - global_position).normalized()
	match m:
		"twin_slash":
			_slash_i = 0
			_slash_total = 3 if phase == 2 else 2
			BossKit.ghost(self, PALE, 0.4)
			_next_slash()
		"void_lance":
			BossKit.anim(self, "cast", 10.0, true)
			_marker = BossKit.telegraph_line(self, global_position, global_position + _facing * lance_len, lance_width, lance_windup, VOID)
		"decoys":
			_begin_decoys()
		"erasure":
			BossKit.ghost(self, PALE, 0.5)
			body.modulate.a = 0.0
			_gone(true)
			var p: Vector2 = _player_ground()
			var away: Vector2 = (p - global_position).normalized()
			if away == Vector2.ZERO:
				away = Vector2.RIGHT
			_spot = p + away * 90.0   # he reappears across the player and faces back
			_facing = -away


## Twin slash: vanish, a cone marker appears beside the player, he blinks in and cuts; again from another side.
func _next_slash() -> void:
	_clear_all()
	var p: Vector2 = _player_ground()
	var base: float = (global_position - p).angle()
	var offs: Array[float] = [PI, PI * 0.5, -PI * 0.5]
	_spot = p + Vector2.from_angle(base + offs[_slash_i % 3]) * 38.0
	_facing = (p - _spot).normalized()
	_marker = BossKit.telegraph_cone(self, _spot, _facing.angle(), deg_to_rad(slash_arc), slash_len, _slash_wait(), MASK)
	body.modulate.a = 0.0
	_gone(true)


func _begin_decoys() -> void:
	BossKit.anim(self, "cast", 10.0, true)
	_decoys.clear()
	var n: int = decoy_count + (1 if phase == 2 else 0)
	var c: Vector2 = BossKit.player_point(self)
	var base: float = (global_position - c).angle()
	var home: Vector2 = global_position
	for k in n:
		var spot: Vector2 = c + Vector2.from_angle(base + TAU * k / n) * decoy_spread
		_decoys.append(spot)
		_tgs.append(BossKit.telegraph_circle(self, spot, decoy_radius, decoy_windup, VOID))
		global_position = spot - BossKit.HURT_OFFSET   # a pale copy stands there until it bursts
		BossKit.ghost(self, PALE, decoy_windup)
	global_position = home


func _erase_hit(ang: float, arc_deg: float, length: float) -> void:
	var at: Vector2 = global_position
	if _warded():
		BossKit.slash(self, at, ang, deg_to_rad(arc_deg), length, MASK)   # Ga Ward turns it aside
		return
	if BossKit.strike_cone(self, at, ang, deg_to_rad(arc_deg), length, erase_damage, true, MASK):
		_forget_effect()


func _tick_move() -> void:
	var at: Vector2 = global_position
	match _move:
		"twin_slash":
			if state_time >= _slash_wait():
				attacks += 1
				global_position = _spot
				body.modulate.a = 1.0
				_gone(false)
				BossKit.flash_fx(self, _spot + Vector2(0, -8), 16.0, 0.25, MASK)
				BossKit.strike_cone(self, _spot, _facing.angle(), deg_to_rad(slash_arc), slash_len, slash_damage, false, MASK)
				_slash_i += 1
				if _slash_i < _slash_total:
					BossKit.ghost(self, PALE, 0.35)
					_next_slash()
					state_time = 0.0
				else:
					_end_move()
		"void_lance":
			var len: float = lance_len
			if _stage == 0 and state_time >= lance_windup:
				attacks += 1
				BossKit.strike_line(self, at, at + _facing * len, lance_width, lance_damage, true, VOID)
				BossKit.shake(self, 2.0, 0.25)
				if phase == 2:
					_clear_all()
					_facing = (_player_ground() - at).normalized()   # a second lance, re-aimed
					_marker = BossKit.telegraph_line(self, at, at + _facing * len, lance_width, maxf(0.5, lance_windup * 0.8), VOID)
					_stage_to(1)
				else:
					_end_move()
			elif _stage == 1 and state_time >= maxf(0.5, lance_windup * 0.8):
				attacks += 1
				BossKit.strike_line(self, at, at + _facing * len, lance_width, lance_damage, true, VOID)
				BossKit.shake(self, 2.0, 0.25)
				_end_move()
		"decoys":
			if state_time >= decoy_windup:
				attacks += 1
				for spot in _decoys:
					BossKit.strike_circle(self, spot, decoy_radius, decoy_damage, true, VOID)
					BossKit.flash_fx(self, spot, decoy_radius * 0.6, 0.3, MASK)
				BossKit.shake(self, 2.5, 0.3)
				_decoys.clear()
				_end_move()
		"erasure":
			if _stage == 0 and state_time >= fade_time + 0.1:
				global_position = _spot
				body.modulate.a = 1.0
				_gone(false)
				BossKit.roar(self, MASK, 70.0)
				_marker = BossKit.telegraph_cone(self, _spot, _facing.angle(), deg_to_rad(erase_arc), erase_len, erase_windup, MASK)
				_stage_to(1)
			elif _stage == 1 and state_time >= erase_windup:
				attacks += 1
				_erase_hit(_facing.angle(), erase_arc, erase_len)
				BossKit.shake(self, 3.0, 0.4)
				_clear_all()
				_marker = BossKit.telegraph_cone(self, at, _facing.angle() + PI, deg_to_rad(100.0), 110.0, erase_back, MASK)
				_stage_to(2)
			elif _stage == 2 and state_time >= erase_back:
				attacks += 1
				_erase_hit(_facing.angle() + PI, 100.0, 110.0)
				BossKit.shake(self, 3.0, 0.4)
				_rec = heavy_recovery + 0.8
				_end_move()
		_:
			_end_move()


func _on_health(hp: int, max_hp: int) -> void:
	engaged = true   # first hit
	if phase == 1 and hp > 0 and hp * 2 <= max_hp:
		phase = 2   # the mask cracks
		attack_hitbox.deactivate()
		_hooking = false
		_steps_left = 0
		_enter(State.RECOVER)
		_rec = 1.2
		BossKit.roar(self, MASK, 90.0)


func _on_flinch() -> void:
	pass   # bosses do not flinch


func _on_died() -> void:
	_clear_all()
	BossKit.anim_stop(self)
	super()
	body.modulate.a = 1.0
	var tw := body.create_tween().set_parallel()
	tw.tween_property(body, "modulate:a", 0.0, 0.4)   # comes apart into name-strips (art later)
	var events := get_node("/root/Events")
	get_tree().create_timer(0.3).timeout.connect(func() -> void: events.boss_defeated.emit("nameless_hunter"))
