class_name FacelessCaptain extends EnemyBase
## Boss: the Faceless Captain (bestiary.md Story v2). A disciplined legion commander: spear sweep, lunge, spear
## volley; from phase 2 a double whirlwind, a chain charge and a rally cry; in phase 3 the Edict (limit break).
## Moves are picked from a shuffled deck by distance and phase, never the same heavy move twice in a row.
## Muster at 66% and 33% HP: a rally-cry shockwave first, then 2 Faceless with a ground warning.
## Ca Burst during the muster wind-up breaks it: no adds, stun.
## Defeat: EnemyBase death, then Events.boss_defeated("faceless_captain").
## The HUD polls: group "boss", health, boss_name_key, engaged.

enum State { IDLE, CHASE, WINDUP, DASH, RECOVER, MUSTER, STUN }

const BURST := preload("res://spells/burst.gd")
const FACELESS := "res://entities/enemies/faceless.tscn"
const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const STUNNED := Color(0.7, 0.75, 1.0)
const STEEL := Color(0.85, 0.9, 1.0)
const GOLD := Color(1.0, 0.8, 0.3)
const MUSTER_AT := [0.66, 0.33]
const WARN := 0.5                    # TUNE: ground warning for the adds, as Encounter.WARN
const HEAVY := ["whirlwind", "chain", "rally", "edict"]

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
@export var recovery := 0.9              # TUNE: after a light move
@export var heavy_recovery := 2.2        # TUNE: punish window after a heavy move
@export var muster_windup := 1.2         # spec
@export var stun_time := 2.0             # spec
@export var add_offset := 72.0           # TUNE: adds appear this far left and right of the lair spot
@export var volley_damage := 12          # TUNE: one blade
@export var volley_range := 70.0         # TUNE: volley from this far
@export var whirl_radius := 50.0         # TUNE
@export var whirl_windup := 0.8          # TUNE
@export var whirl_damage := 22           # TUNE, heavy
@export var chain_len := 84.0            # TUNE: each of the 3 lunges
@export var chain_time := 0.2            # TUNE
@export var chain_damage := 14           # TUNE
@export var rally_windup := 0.8          # TUNE
@export var rally_damage := 16           # TUNE: the shockwave
@export var edict_windup := 1.4          # TUNE: limit break wind-up
@export var edict_outer := 120.0         # TUNE
@export var edict_inner := 30.0          # TUNE: the safe spot, hug the Captain
@export var edict_damage := 28           # TUNE: ~1.5x heavy
@export var edict_recovery := 2.6        # TUNE

var active := true   # EliteGuard flips it
var state := State.IDLE
var state_time := 0.0
var phase := 1
var phase_marks := [0.66, 0.33]   # the boss bar draws a tick at each muster (hud.gd)
var engaged := false
var attacks := 0
var moves_used: Dictionary = {}
var _muster_due := 0
var _muster_next := false
var _move := ""
var _last := ""
var _stage := 0
var _mt := 0.0
var _ang := 0.0
var _wind := 0.5
var _len := 96.0
var _dur := 0.25
var _chain_left := 0
var _volleys := 1
var _hit_done := false
var _ghost_t := 0.0
var _recover_t := 0.9
var _spot := Vector2.ZERO
var _deck: Array[String] = []
var _tele: Array[Node] = []
var _shots: Array[Node] = []


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
	var to_t := Vector2.INF
	if target != null:
		to_t = target.global_position - global_position
	var d := to_t.length()
	if d <= engage_range and BossKit.may_engage(self):
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
				_muster_next = true
				_begin_move("rally", to_t)
			else:
				var m: String = _pick(d)
				if m != "":
					_begin_move(m, to_t)
				else:
					velocity = to_t.normalized() * speed * slow()
		State.WINDUP:
			_run_move(delta)
		State.DASH:
			_enter(State.RECOVER)
		State.RECOVER:
			if state_time >= _recover_t:
				_enter(State.CHASE)
		State.MUSTER:
			if state_time >= muster_windup:
				_call_adds()
				_recover_t = recovery * 1.5
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
	if s in [State.IDLE, State.CHASE, State.RECOVER, State.STUN]:
		BossKit.anim_stop(self)
	if s == State.STUN:
		BossKit.open(self, stun_time)
		_move = ""
		attack_hitbox.deactivate()
	body.modulate = STUNNED if s == State.STUN else (Color(1.0, 0.45, 0.45) if s in [State.WINDUP, State.MUSTER] else Color.WHITE)


# --- the deck ------------------------------------------------------------------------------------------------

func _pool() -> Array[String]:
	var out: Array[String] = ["sweep", "lunge", "volley"]
	if phase >= 2:
		out.append("whirlwind")
		out.append("chain")
		out.append("rally")
	if phase >= 3:
		out.append("edict")
	return out


func _fits(m: String, d: float) -> bool:
	match m:
		"sweep":
			return d <= sweep_range + 6.0
		"lunge":
			return d >= 56.0 and d <= lunge_len + 24.0
		"volley":
			return d >= volley_range and d <= 220.0
		"whirlwind":
			return d <= 70.0
		"chain":
			return d >= 50.0 and d <= 170.0
		"rally":
			return d <= 140.0
		"edict":
			return d <= 160.0
	return false


## The next move that suits this distance, or "" to keep walking. Refills and reshuffles when the deck runs dry.
func _pick(d: float) -> String:
	for pass_i in 2:
		if _deck.is_empty():
			for m in _pool():
				_deck.append(m)
			_deck.shuffle()
		for i in _deck.size():
			var m: String = _deck[i]
			if m == _last and m in HEAVY:
				continue
			if _fits(m, d):
				_deck.remove_at(i)
				_last = m
				return m
		_deck.clear()   # nothing in this deck fits: reshuffle once, then give up and walk
	return ""


# --- moves ---------------------------------------------------------------------------------------------------

func _begin_move(m: String, to_t: Vector2) -> void:
	_enter(State.WINDUP)
	_move = m
	_last = m
	_ang = to_t.angle()
	_stage = 0
	_mt = 0.0
	_hit_done = false
	_spot = global_position
	attacks += 1
	moves_used[m] = int(moves_used.get(m, 0)) + 1
	_prune_shots()
	match m:
		"sweep":
			BossKit.anim(self, "slam", 10.0, true)
			_track(BossKit.telegraph_cone(self, global_position, _ang, deg_to_rad(sweep_arc), sweep_range, sweep_windup))
		"lunge":
			_aim_lunge(lunge_windup, lunge_len, lunge_time)
		"chain":
			_chain_left = 3
			_aim_lunge(lunge_windup, chain_len, chain_time)
		"volley":
			_volleys = 2 if phase >= 2 else 1
			_aim_volley(0.7)
		"whirlwind":
			BossKit.anim(self, "slam", 10.0, true)
			_track(BossKit.telegraph_circle(self, global_position, whirl_radius, whirl_windup))
		"rally":
			BossKit.anim(self, "roar", 8.0, true)
			_track(BossKit.telegraph_circle(self, global_position, 36.0, rally_windup, GOLD))
		"edict":
			BossKit.anim(self, "cast", 8.0, true)
			_track(BossKit.telegraph_ring(self, global_position, edict_outer, edict_inner, edict_windup))
			BossKit.ring_fx(self, global_position, edict_inner, 0.5, GOLD)


func _run_move(delta: float) -> void:
	_mt += delta
	velocity = Vector2.ZERO
	match _move:
		"sweep":
			if _mt >= sweep_windup:
				BossKit.strike_cone(self, global_position, _ang, deg_to_rad(sweep_arc), sweep_range, sweep_damage, true, STEEL)
				BossKit.shake(self, 1.5, 0.15)
				_end_move(recovery)
		"lunge", "chain":
			_run_lunge(delta)
		"volley":
			_run_volley()
		"whirlwind":
			_run_whirlwind()
		"rally":
			_run_rally()
		"edict":
			_run_edict()
		_:
			_end_move(recovery)


func _end_move(rec: float) -> void:
	if rec >= heavy_recovery:
		BossKit.open(self, rec)
	_move = ""
	_recover_t = rec
	_enter(State.RECOVER)


func _track(t: BossKit.Telegraph) -> void:
	t.follow = self
	_tele.append(t)


func _prune_shots() -> void:
	var keep: Array[Node] = []
	for n in _shots:
		if is_instance_valid(n):
			keep.append(n)
	_shots = keep


## Lunge and chain charge: a line marker, then a dash that hits once. The chain re-aims and repeats 3 times.
func _aim_lunge(wind: float, length: float, dur: float) -> void:
	if target != null:
		_ang = (target.global_position - global_position).angle()
	_wind = wind
	_len = length
	_dur = dur
	_stage = 0
	_mt = 0.0
	_hit_done = false
	BossKit.anim(self, "cast", 10.0, true)
	_track(BossKit.telegraph_line(self, global_position, global_position + Vector2.from_angle(_ang) * length, 14.0, wind))


func _run_lunge(delta: float) -> void:
	match _stage:
		0:
			if _mt >= _wind:
				_stage = 1
				_mt = 0.0
				_ghost_t = 0.0
				BossKit.anim(self, "dash", 10.0, true)
		1:
			velocity = Vector2.from_angle(_ang) * _len / _dur
			_ghost_t -= delta
			if _ghost_t <= 0.0:
				_ghost_t = 0.05
				BossKit.ghost(self, STEEL, 0.3)
			if not _hit_done and BossKit.in_circle(BossKit.player_point(self), global_position, 14.0):
				_hit_done = true
				BossKit.hurt_player(self, lunge_damage if _move == "lunge" else chain_damage, true)
				BossKit.sparks(self, global_position, STEEL, 8, 60.0, 0.3)
			if _mt >= _dur:
				velocity = Vector2.ZERO
				if _move == "chain":
					_chain_left -= 1
					if _chain_left > 0:
						_aim_lunge(0.5, chain_len, chain_time)
						return
					_end_move(heavy_recovery)
				else:
					_end_move(recovery)


func _aim_volley(wind: float) -> void:
	if target != null:
		_ang = (target.global_position - global_position).angle()
	_stage = 0
	_mt = 0.0
	_wind = wind
	BossKit.anim(self, "cast", 10.0, true)
	_track(BossKit.telegraph_cone(self, global_position, _ang, 0.8, 150.0, wind, Color(0.9, 0.9, 1.0)))


func _run_volley() -> void:
	if _mt < _wind:
		return
	var count := 7 if phase >= 2 else 5
	for s in BossKit.fan(self, global_position + Vector2(0, -8), _ang, 0.8, count, 140.0, volley_damage, STEEL, "blade", 4.0, 2.2):
		_shots.append(s)
	_volleys -= 1
	if _volleys > 0:
		_aim_volley(0.5)
	else:
		_end_move(recovery)


## Double spin: the second ring tracks the Captain as he drifts toward the player.
func _run_whirlwind() -> void:
	match _stage:
		0:
			if _mt >= whirl_windup:
				BossKit.strike_circle(self, global_position, whirl_radius, whirl_damage, true, STEEL)
				BossKit.shake(self, 1.5, 0.15)
				_stage = 1
				_mt = 0.0
				_track(BossKit.telegraph_circle(self, global_position, whirl_radius + 8.0, 0.55))
		1:
			if target != null:
				velocity = (target.global_position - global_position).normalized() * speed * 1.5 * slow()
			if _mt >= 0.55:
				velocity = Vector2.ZERO
				BossKit.strike_circle(self, global_position, whirl_radius + 8.0, whirl_damage, true, STEEL)
				BossKit.shake(self, 2.0, 0.2)
				_end_move(heavy_recovery)


## Rally cry: a gold shockwave (dodge through it). Before a muster it is followed by the muster wind-up.
func _run_rally() -> void:
	if _mt < rally_windup:
		return
	BossKit.roar(self, GOLD)
	BossKit.wave(self, global_position, 120.0, 110.0, rally_damage, GOLD, true)
	if _muster_next:
		_muster_next = false
		_begin_muster()
	else:
		_end_move(heavy_recovery)


## Limit break (phase 3): stand inside the inner circle, next to the Captain, or dodge through the ring.
func _run_edict() -> void:
	match _stage:
		0:
			if _mt >= edict_windup:
				var dist := BossKit.player_point(self).distance_to(_spot)
				BossKit.ring_fx(self, _spot, edict_outer, 0.5, STEEL)
				BossKit.flash_fx(self, _spot + Vector2(0, -10), 40.0, 0.4, GOLD)
				BossKit.shake(self, 3.0, 0.3)
				if dist <= edict_outer + BossKit.HURT_RADIUS and dist >= edict_inner:
					BossKit.hurt_player(self, edict_damage, true)
				BossKit.wave(self, _spot, 150.0, 100.0, rally_damage, GOLD, true)
				_stage = 1
				_mt = 0.0
		1:
			if _mt >= 0.6:
				_end_move(edict_recovery)


func _begin_muster() -> void:
	_enter(State.MUSTER)
	BossKit.hint(self, "BOSS_HINT_CAPTAIN", 0.0)   # every muster: it happens twice a fight
	BossKit.mark(self, self, "sunda_ca", muster_windup, 20.0)
	BossKit.anim(self, "cast", 8.0, true)
	_track(BossKit.telegraph_circle(self, global_position, 28.0, muster_windup, GOLD))


func _clear_attack() -> void:
	for n in _tele:
		if is_instance_valid(n):
			n.queue_free()
	_tele.clear()


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
	var was := phase
	while phase <= MUSTER_AT.size() and hp > 0 and hp <= max_hp * MUSTER_AT[phase - 1]:
		phase += 1
		_muster_due += 1
	if phase != was:
		_deck.clear()
		BossKit.roar(self, GOLD)   # the legion answers: new moves join the deck


## Ca Burst during the muster wind-up breaks it.
func _on_hurt(hitbox: Hitbox) -> void:
	if state == State.MUSTER and hitbox.get_script() == BURST:
		get_node("/root/Events").weakness_triggered.emit(kind)
		_enter(State.STUN)
	super(hitbox)


func _on_flinch() -> void:
	pass   # bosses do not flinch


func _on_died() -> void:
	_move = ""
	_clear_attack()
	for n in _shots:
		if is_instance_valid(n):
			n.queue_free()
	_shots.clear()
	BossKit.anim_stop(self)
	super()
	var tw := body.create_tween().set_parallel()
	tw.tween_property(body, "modulate:a", 0.0, 0.35)   # the mask cracks and fades
	var events := get_node("/root/Events")
	get_tree().create_timer(0.3).timeout.connect(func() -> void: events.boss_defeated.emit("faceless_captain"))
