class_name ButoIjo extends EnemyBase
## Miniboss: Buto Ijo (bestiary.md "Build spec", boss revamp v9). Four pouch phases (100/75/50/25%), one lit pouch each.
## Rule: his head-down charge (sig1) crossing the lit pouch stuns him for 4 s (TERBUKA) and lights the next pouch.
## Defeat: EnemyBase death, then Events.boss_defeated. The quest step sets mq3_4 (as with Bondowoso).
## The HUD polls: group "boss", health, boss_name_key, engaged.
# ponytail: Timun Mas is not a node. The arena centre is where the player stood when the fight began unless arena_center is set.
# Heavy hits landing free while stunned needs nothing: Buto has no shield, so every hit lands.

enum State { IDLE, CHASE, WINDUP, CHARGE, RECOVER, PAUSE, STUN, MOVE }

const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const GREEN := Color(0.45, 0.9, 0.2)
const HUNGER := Color(1.0, 0.45, 0.15)
const MOVES_ALL := ["pound", "charge", "devour", "seed_volley", "bramble_stomp", "quake"]   # the deck; charge is sig1, famine_maw (sig2) is the limit break
const HEAVY := ["pound", "charge", "devour", "quake", "famine_maw"]
const FIELD_SCENE := preload("res://entities/bosses/pouch_field.tscn")
const KINDS := ["bramble", "bamboo", "salt", "mud"]
const AMBUSH_RETREAT := {"buto_ambush_1": 0.80, "buto_ambush_2": 0.65, "buto_ambush_3": 0.50}   # TUNE: HP fraction he retreats at (quests.md 7.1)

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
@export var pouch_stun := 4.0          # spec (v9): his charge crossed the lit pouch
@export var pouch_dist := 80.0         # TUNE: the lit pouch sits this far from the arena centre
@export var maw_pull := 45.0           # TUNE: px/s the famine maw drags the player in
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
@export var zone_damage := 7           # TUNE: bramble patch tick (balance_model.py section 7.2: 3 ticks stay under one light hit)
@export var quake_windup := 0.55       # TUNE: between waves
@export var quake_damage := 28         # TUNE: one wave, dodge through it
@export var maw_windup := 2.2          # TUNE: limit break telegraph
@export var maw_outer := 150.0         # TUNE
@export var maw_inner := 36.0          # TUNE: the safe spot hugs him
@export var maw_damage := 60           # TUNE: ~1.5x heavy

var state := State.IDLE
var state_time := 0.0
var phase_marks := [0.75, 0.5, 0.25]   # the boss bar draws a tick at each pouch phase
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
var _lit_n := 0                        # pouches lit so far: turns the next spot around the arena
var _since_charge := 0                 # moves since his last charge: the rule needs it often
var _quake_left := 0
var _since_ult := 0
var _rec := 1.2
var _ghost_t := 0.0
var _body_pos := Vector2.ZERO
var _tgs: Array[Node2D] = []
var _owned: Array[Node] = []           # his zones, seeds and waves: freed when he kneels or dies (combat.md 5.3 v7)


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


## The one lit pouch, or null.
func pouch() -> PouchField:
	return fields[0] if not fields.is_empty() and is_instance_valid(fields[0]) else null


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
		_engage()
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
			var lit := pouch()
			if lit != null and lit.contains(global_position):   # the rule: he charged through the lit pouch
				_light_pouch()
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
			if state_time >= pouch_stun:
				_enter(State.CHASE)
	move_and_slide()


func _engage() -> void:
	if engaged:
		return
	engaged = true
	if arena_center == Vector2.INF:   # the lair: he stands at its centre; an ambush: where the player stood
		arena_center = _start if ambush_id == "" or target == null else target.global_position
	if phase == 0:
		_next_phase()


# --- pouches ---

func _next_phase() -> void:
	phase += 1
	_light_pouch()
	BossKit.hint(self, "BOSS_HINT_BUTO", 0.0)
	if phase > 1:
		attack_hitbox.deactivate()
		_enter(State.PAUSE)   # the roar; phase 1 starts as the fight does
		BossKit.roar(self, HUNGER, 90.0)


## One glowing pouch per phase (the kind follows the phase). Each time his charge crosses it, the next one lights
## further round the arena. ponytail: the spot is not checked against walls beyond clamp_arena_pos.
func _light_pouch() -> void:
	for f in fields:
		if is_instance_valid(f):
			f.queue_free()
	fields.clear()
	var c := arena_center if arena_center != Vector2.INF else _start
	var spot := BossKit.clamp_arena_pos(self, c + Vector2.from_angle(PI + _lit_n * 2.4) * pouch_dist)
	_lit_n += 1
	var f := FIELD_SCENE.instantiate() as PouchField
	f.kind = KINDS[maxi(phase, 1) - 1]
	f.position = spot
	get_parent().add_child(f)
	f.global_position = spot
	fields.append(f)
	BossKit.mark(self, f, "", 10.0, f.radius)   # a gold ring on the lit pouch


func _on_health(hp: int, max_hp: int) -> void:
	_engage()   # first hit
	var r := retreat_at()
	if r > 0.0 and not retreated and hp <= max_hp * r:
		if hp <= 0:
			health.hp = 1
		retreated = true
		_retreat.call_deferred()   # the hit can come mid physics query
		return
	while phase > 0 and phase < 4 and hp > 0 and hp * 4 <= max_hp * (4 - phase):
		_next_phase()


## Ambush over: he drops back into the grass (not killed, so the lair fight stays), and notifies his Encounter.
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
	var enc: Node = null
	var par := get_parent()
	if par != null:
		if par.get("area_id") == ambush_id and par.has_method("_on_died"):
			enc = par
		else:
			for n in par.get_children():
				if n != self and n.get("area_id") == ambush_id and n.has_method("_on_died"):
					enc = n
					break
	if enc != null:
		var cb := Callable(enc, "_on_died")
		if health.died.is_connected(cb):
			health.died.disconnect(cb)
		enc.call("_on_died")
	else:
		get_node("/root/Events").area_cleared.emit(ambush_id)


# --- move deck ---

func _eligible(m: String, d: float) -> bool:
	match m:
		"pound":
			return d <= pound_range
		"charge":
			return d >= charge_min and d <= charge_max
		"devour":
			return d <= devour_range
		"seed_volley":
			return d >= 80.0 and d <= 240.0
		"bramble_stomp":
			return d <= 130.0
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
	if _since_charge >= 2 and _eligible("charge", d) and _last_move != "charge":
		return "charge"   # the rule lives on his charge, so it comes round often
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
	_since_charge = 0 if m == "charge" else _since_charge + 1
	_rec = heavy_recovery if HEAVY.has(m) else recovery
	_move = m
	match m:
		"pound":
			_begin_attack(true)
		"charge":
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
	if s == State.STUN:
		BossKit.open(self, pouch_stun)
	elif s == State.RECOVER and _rec >= heavy_recovery:
		BossKit.open(self, _rec)
	if s == State.CHASE or s == State.STUN or s == State.RECOVER or s == State.PAUSE:
		BossKit.anim_stop(self)
		body.position = _body_pos


func _windup_len() -> float:
	if _pound:
		return pound_windup
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
		BossKit.anim(self, "sig1", 10.0, true)   # head down
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
	_enter(next)


func _clear_attack() -> void:
	for t in _tgs:
		if is_instance_valid(t):
			t.queue_free()
	_tgs.clear()
	if dead or health.hp <= 0:   # the kneel (BossKit.finisher) and the death: nothing he made may hurt now
		for n in _owned:
			if is_instance_valid(n):
				n.queue_free()
		_owned.clear()


## A bramble patch of the stomp: never over a pouch field (the lure spot) nor the gate's door and threshold.
func _bramble(pos: Vector2) -> void:
	for f in fields:
		if is_instance_valid(f) and f.global_position.distance_to(pos) < f.radius + 24.0:
			return
	for g in get_tree().get_nodes_in_group("arena_gate"):
		var th := g.get_node_or_null("Threshold") as Node2D
		var door: Vector2 = g.call("door")
		if door.distance_to(pos) < 64.0 or (th != null and th.global_position.distance_to(pos) < 48.0):
			return
	_prune_owned()
	_owned.append(BossKit.zone(self, pos, 24.0, zone_damage, 5.0, Color(0.3, 0.7, 0.2), 0.7))


func _prune_owned() -> void:
	var keep: Array[Node] = []
	for n in _owned:
		if is_instance_valid(n):
			keep.append(n)
	_owned = keep


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
		"quake":
			_quake_left = 3 if phase >= 3 else 2
			BossKit.anim(self, "slam", 10.0, true)
			_tg(BossKit.telegraph_circle(self, global_position, 40.0, quake_windup, HUNGER))
		"famine_maw":
			BossKit.anim(self, "sig2", 6.0, true)   # the inhale
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
				_prune_owned()
				for sh in BossKit.fan(self, at + Vector2(0, -8), _dir.angle(), deg_to_rad(70.0), n, seed_speed, seed_damage, GREEN, "shard", 4.0, 2.5):
					_owned.append(sh)
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
					_bramble(at + _dir * r)
				if phase >= 3:
					_bramble(at + _dir.rotated(0.9) * 80.0)
					_bramble(at + _dir.rotated(-0.9) * 80.0)
				_end_move()
		"quake":
			if state_time >= quake_windup:
				attacks += 1
				_prune_owned()
				_owned.append(BossKit.wave(self, at, 130.0, 100.0, quake_damage, HUNGER, true))
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
			_maw_pull(at, delta)
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


## The inhale drags the player in while the ring fills. The safe direction is in: the inner ring hugs him.
func _maw_pull(at: Vector2, delta: float) -> void:
	if not target is CharacterBody2D:
		return
	var gap: Vector2 = at - BossKit.player_point(self)
	if gap.length() > maw_inner * 0.6 and gap.length() < maw_outer:
		(target as CharacterBody2D).move_and_collide(gap.normalized() * maw_pull * delta)


func _on_flinch() -> void:
	pass   # bosses do not flinch


func _on_died() -> void:
	if retreat_at() > 0.0:
		if not retreated:
			retreated = true
			_retreat()
		return
	for f in fields:
		if is_instance_valid(f):
			f.queue_free()
	fields.clear()
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
