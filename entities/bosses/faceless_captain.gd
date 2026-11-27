class_name FacelessCaptain extends EnemyBase
## Boss: the Faceless Captain (bestiary.md, combat.md boss revamp v9). A disciplined legion commander. One rule: he
## plants his war banner (sig1) and ghost ranks fade in on the floor squares over 3 s. Sunda Ca cast near the banner
## burns it: the ranks scatter and he is stunned 3.5 s (TERBUKA). Unanswered, the ranks strike the squares once (a heavy
## hit if you stand on one), then the banner furls. Moves: spear sweep, long spear lunge (sig2), blade volley; phase 2
## (66%) adds the whirlwind and the chain charge; phase 3 (33%) fields more ranks and plants sooner.
## Defeat: EnemyBase death, then Events.boss_defeated("faceless_captain").
## The HUD polls: group "boss", health, boss_name_key, engaged.

enum State { IDLE, CHASE, WINDUP, DASH, RECOVER, STUN }

const WIND := 1.15                   # v9: an early boss's heavy attacks wind up 15% longer (telegraph and strike together)
const STEEL := Color(0.85, 0.9, 1.0)
const GOLD := Color(1.0, 0.8, 0.3)
const GHOST := Color(0.65, 0.75, 1.0)    # the ghost ranks
const STUNNED := Color(0.7, 0.75, 1.0)
const PHASE_AT := [0.66, 0.33]
const HEAVY := ["lunge", "whirlwind", "chain"]

@export var boss_name_key := "BOSS_FACELESS_CAPTAIN"
@export var cond := ""                   # Game.check condition; empty = always on
@export var speed := 40.0                # spec
@export var engage_range := 128.0        # 8 tiles
@export var sweep_range := 40.0          # spec: arc radius
@export var sweep_arc := 120.0           # spec, degrees
@export var sweep_windup := 0.5          # spec
@export var sweep_damage := 18           # spec, heavy
@export var lunge_len := 132.0           # TUNE: sig2, the long spear lunge
@export var lunge_windup := 0.6          # spec
@export var lunge_time := 0.3            # TUNE: dash duration
@export var lunge_damage := 16           # spec, heavy
@export var recovery := 0.9              # TUNE: after a light move
@export var heavy_recovery := 2.2        # TUNE: punish window after a heavy move
@export var stun_time := 3.5             # v9: the burnt banner
@export var volley_damage := 12          # TUNE: one blade
@export var volley_range := 70.0         # TUNE: volley from this far
@export var whirl_radius := 50.0         # TUNE
@export var whirl_windup := 0.8          # TUNE
@export var whirl_damage := 22           # TUNE, heavy
@export var chain_len := 84.0            # TUNE: each of the 3 lunges
@export var chain_time := 0.2            # TUNE
@export var chain_damage := 14           # TUNE
@export var plant_windup := 0.8          # TUNE: sig1, planting the banner
@export var plant_gap := 10.0            # TUNE: seconds between banners (2 s sooner each phase)
@export var rank_time := 3.0             # v9: the ranks fade in over 3 s, then strike once
@export var rank_radius := 18.0          # TUNE: one rank square
@export var rank_ring := 56.0            # TUNE: squares sit this far around the banner
@export var rank_damage := 22            # TUNE: the one heavy hit a missed banner costs
@export var banner_range := 90.0         # TUNE: Ca this near the banner burns it

var active := true   # EliteGuard flips it
var state := State.IDLE
var state_time := 0.0
var phase := 1
var phase_marks := [0.66, 0.33]   # the boss bar draws a tick at each phase (hud.gd)
var engaged := false
var attacks := 0
var moves_used: Dictionary = {}
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
var banner: Node2D          # the planted war banner; null when none
var banner_t := -1.0        # seconds since planting, -1 when none
var _plant_cd := 3.0
var _ranks: Array[Node] = []
var _rank_at: Array[Vector2] = []
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
	get_node("/root/Events").spell_cast.connect(_on_cast)


func _tick(delta: float) -> void:
	state_time += delta
	var to_t := Vector2.INF
	if target != null:
		to_t = target.global_position - global_position
	var d := to_t.length()
	if d <= engage_range and BossKit.may_engage(self):
		engaged = true
	if engaged and banner == null and state != State.STUN:
		_plant_cd -= delta
	if banner != null:
		_run_banner(delta)
	match state:
		State.IDLE:
			if engaged:
				_enter(State.CHASE)
		State.CHASE:
			if target == null:
				pass
			elif banner == null and _plant_cd <= 0.0:
				_begin_move("plant", to_t)
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
	body.modulate = STUNNED if s == State.STUN else (Color(1.0, 0.45, 0.45) if s == State.WINDUP else Color.WHITE)


# --- the deck ------------------------------------------------------------------------------------------------

func _pool() -> Array[String]:
	var out: Array[String] = ["sweep", "lunge", "volley"]
	if phase >= 2:
		out.append("whirlwind")
		out.append("chain")
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
			_track(BossKit.telegraph_cone(self, global_position, _ang, deg_to_rad(sweep_arc), sweep_range, sweep_windup * WIND))
		"lunge":
			_aim_lunge(lunge_windup * WIND, lunge_len, lunge_time)
		"chain":
			_chain_left = 3
			_aim_lunge(lunge_windup * WIND, chain_len, chain_time)
		"volley":
			_volleys = 2 if phase >= 2 else 1
			_aim_volley(0.7)
		"whirlwind":
			BossKit.anim(self, "slam", 10.0, true)
			_track(BossKit.telegraph_circle(self, global_position, whirl_radius, whirl_windup * WIND))
		"plant":
			BossKit.anim(self, "sig1", 8.0, true)
			_spot = BossKit.clamp_arena_pos(self, global_position + Vector2.from_angle(_ang + PI) * 40.0)   # behind him, away from you
			_track(BossKit.telegraph_circle(self, _spot, 14.0, plant_windup * WIND, GOLD))

func _run_move(delta: float) -> void:
	_mt += delta
	velocity = Vector2.ZERO
	match _move:
		"sweep":
			if _mt >= sweep_windup * WIND:
				BossKit.strike_cone(self, global_position, _ang, deg_to_rad(sweep_arc), sweep_range, sweep_damage, true, STEEL)
				BossKit.shake(self, 1.5, 0.15)
				_end_move(recovery)
		"lunge", "chain":
			_run_lunge(delta)
		"volley":
			_run_volley()
		"whirlwind":
			_run_whirlwind()
		"plant":
			if _mt >= plant_windup * WIND:
				_plant_banner(_spot)
				_end_move(recovery)
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
	BossKit.anim(self, "sig2" if _move == "lunge" else "cast", 10.0, true)
	_track(BossKit.telegraph_line(self, global_position, global_position + Vector2.from_angle(_ang) * length, 14.0, wind))


func _run_lunge(delta: float) -> void:
	match _stage:
		0:
			if _mt >= _wind:
				_stage = 1
				_mt = 0.0
				_ghost_t = 0.0
				if _move != "lunge":
					BossKit.anim(self, "dash", 10.0, true)   # the lunge keeps its sig2 row
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
						_aim_lunge(0.5 * WIND, chain_len, chain_time)
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
			if _mt >= whirl_windup * WIND:
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


## The banner: planted at `at`, ghost ranks fade in on the floor squares around it over rank_time (telegraph circles
## that fill up). Left alone they strike once; Sunda Ca near the banner burns it first (_on_cast).
## ponytail: the squares are round telegraphs, not painted squares; the count grows with the phase.
func _plant_banner(at: Vector2) -> void:
	_clear_banner()
	banner = BossKit.prop("props/arena_banner.png", Vector2(16, 40), Color(0.7, 0.15, 0.15), 4)
	if banner is Sprite2D:
		banner.offset = Vector2(0, -20)
		var spr := banner as Sprite2D
		var tw := spr.create_tween().set_loops()
		tw.tween_callback(func() -> void: spr.frame = (spr.frame + 1) % 4)
		tw.tween_interval(0.15)
	banner.z_index = 4
	get_parent().add_child(banner)
	banner.global_position = at
	banner_t = 0.0
	BossKit.flash_fx(self, at + Vector2(0, -16), 18.0, 0.3, GOLD)
	BossKit.shake(self, 1.0, 0.1)
	var n := 4 + 2 * (phase - 1)
	for i in n:
		var p := at + Vector2.from_angle(TAU * i / n + 0.4) * rank_ring
		_rank_at.append(p)
		_ranks.append(BossKit.telegraph_circle(self, p, rank_radius, rank_time, GHOST))
	BossKit.hint(self, "BOSS_HINT_CAPTAIN", 0.0)


func _run_banner(delta: float) -> void:
	banner_t += delta
	BossKit.hint(self, "BOSS_HINT_CAPTAIN")
	BossKit.mark(self, banner, "sunda_ca", maxf(0.1, rank_time - banner_t), 16.0)
	if banner_t < rank_time:
		return
	for p in _rank_at:   # missed: the ranks strike once, then the banner furls
		BossKit.strike_circle(self, p, rank_radius, rank_damage, true, GHOST)
	BossKit.shake(self, 2.0, 0.2)
	_clear_banner()


func _clear_banner() -> void:
	for n in _ranks:
		if is_instance_valid(n):
			n.queue_free()
	_ranks.clear()
	_rank_at.clear()
	if is_instance_valid(banner):
		banner.queue_free()
	banner = null
	banner_t = -1.0
	_plant_cd = maxf(2.0, plant_gap - 2.0 * (phase - 1))


## The answer: Ca cast near the planted banner burns it. The ranks scatter and he reels (TERBUKA).
func _on_cast(glyph_id: String, _score: float) -> void:
	if glyph_id != "sunda_ca" or banner == null or dead or target == null:
		return
	if banner.global_position.distance_to(target.global_position) > banner_range:
		return
	BossKit.sparks(self, banner.global_position + Vector2(0, -16), Color(1.0, 0.5, 0.15), 14, 70.0, 0.5)
	BossKit.flash_fx(self, banner.global_position + Vector2(0, -16), 22.0, 0.4, Color(1.0, 0.55, 0.2))
	for p in _rank_at:
		BossKit.sparks(self, p, GHOST, 6, 40.0, 0.4)
	_clear_banner()
	get_node("/root/Events").weakness_triggered.emit(kind)
	_enter(State.STUN)


func _clear_attack() -> void:
	for n in _tele:
		if is_instance_valid(n):
			n.queue_free()
	_tele.clear()
	if dead:   # the kneel (BossKit.finisher sets dead first): nothing he made may hurt the player now
		_clear_owned()


func _clear_owned() -> void:
	for n in _shots:
		if is_instance_valid(n):
			n.queue_free()
	_shots.clear()
	_clear_banner()


func _on_health(hp: int, max_hp: int) -> void:
	engaged = true   # first hit
	var was := phase
	while phase <= PHASE_AT.size() and hp > 0 and hp <= max_hp * PHASE_AT[phase - 1]:
		phase += 1
	if phase != was:
		_deck.clear()
		_plant_cd = minf(_plant_cd, 1.0)   # the legion answers: a banner soon, more ranks
		BossKit.roar(self, GOLD)


func _on_flinch() -> void:
	pass   # bosses do not flinch


func _on_died() -> void:
	_move = ""
	_clear_attack()
	_clear_owned()
	BossKit.anim_stop(self)
	super()
	var tw := body.create_tween().set_parallel()
	tw.tween_property(body, "modulate:a", 0.0, 0.35)   # the mask cracks and fades
	var events := get_node("/root/Events")
	get_tree().create_timer(0.3).timeout.connect(func() -> void: events.boss_defeated.emit("faceless_captain"))
