class_name Sangkuriang extends EnemyBase
## Boss: Sangkuriang (bestiary.md, combat.md boss revamp v9). An enraged giant of timber and boats. One rule: the sundial
## on the arena floor fills as the boat hull rises mid-arena. Light the cloth post (Sunda Ca near the hung Boeh Rarang
## post) for a false dawn: the boat crumbles, the dial empties and he is stunned (TERBUKA). Unanswered, the boat
## completes and the Dawn Wrath fires once (a ring of shards with a gap), then the dial starts over.
## Moves: log throw, timber rain, log roll, adze chop (sig1, chip cone), boulder heave (sig2); phase 2 (50%) adds the
## earthshaker leap and the lake seeps in.
## Defeat is a release: EnemyBase death (Ilmu, enemy_killed, Game.killed) then Events.boss_defeated.
## The HUD polls: group "boss", health, boss_name_key, engaged, dawn.

enum State { IDLE, CHASE, WINDUP, RECOVER, PAUSE, STUN }

const LOG_SPEED := 0.35        # TUNE: log flight time at the end of a throw wind-up
const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const STUNNED := Color(0.7, 0.75, 1.0)
const TIMBER := Color(0.7, 0.5, 0.25)
const DAWN := Color(1.0, 0.7, 0.2)
const SEEP := Color(0.3, 0.6, 0.9)
const SEEP_X := [-80.0, -56.0, -32.0]       # pool columns, px west of his lair spot: the lake side, one more as dawn nears
const SEEP_Y := [-72.0, -24.0, 24.0, 72.0]  # pool rows, px from his lair spot
const HEAVY := ["adze", "heave", "earthshaker", "roll", "wrath", "timber"]
const WIND := 1.15             # v9: an early boss's heavy attacks wind up 15% longer (telegraph and strike together)
const BOAT_OFFSET := Vector2(112, -16)   # arena centre from his lair spot (zones/tatar_sunda.md Area 8: rect centre, 3.5 cells east)
const DIAL_R := 28.0
const LIFT := 4096.0           # ponytail: as ArenaFloor, the dial sorts under every actor by lifting it in the y-sort

@export var boss_name_key := "BOSS_SANGKURIANG"
@export var cond := ""                  # Game.check condition; empty = always on
@export var sabotage_flag := "laras_sabotage_crater_seal"   # HUD boss bar reads this
@export var sabotage_dawn_mult := 1.4   # TUNE (v5): the dawn groove is jammed, dawn fills this much slower
@export var sabotage_stun_bonus := 2.0  # TUNE (v5): the fake dawn stuns this much longer
@export var post_id := "east"
@export var speed := 30.0              # TUNE
@export var engage_range := 128.0      # 8 tiles
@export var adze_range := 60.0         # TUNE: the chop reaches this far
@export var throw_min := 96.0          # TUNE: throws from this far
@export var throw_max := 200.0         # TUNE
@export var throw_windup := 0.9        # TUNE
@export var adze_windup := 0.7          # TUNE
@export var heave_windup := 1.2         # TUNE
@export var throw_radius := 20.0       # TUNE
@export var heave_radius := 30.0       # TUNE
@export var throw_damage := 16         # TUNE, balance.md 7 light hit
@export var slam_damage := 36          # TUNE, balance.md 7 heavy hit (the earthshaker landing)
@export var adze_damage := 24          # TUNE: the chop
@export var chip_damage := 8           # TUNE: one wood chip
@export var heave_damage := 30         # TUNE, heavy: the boulder
@export var recovery := 1.2            # TUNE: after a light move
@export var heavy_recovery := 2.2      # TUNE: punish window after a heavy move
@export var dawn_time := 25.0          # TUNE: seconds for the sundial to fill and the boat to rise
@export var stun_time := 4.0           # TUNE
@export var pause_time := 1.0          # TUNE: pause telegraphing phase 2
@export var post_range := 80.0         # 5 tiles
@export var answer_at := 0.5           # TUNE: the post answers once the dial is this full (and marks itself)
@export var rain_damage := 14          # TUNE: one falling log
@export var rain_radius := 18.0        # TUNE
@export var leap_radius := 34.0        # TUNE: earthshaker landing
@export var wave_damage := 18          # TUNE: the shockwave after the leap
@export var roll_len := 150.0          # TUNE
@export var roll_time := 0.6           # TUNE
@export var roll_damage := 28          # TUNE, heavy
@export var wrath_damage := 40         # TUNE: one shard of the Dawn Wrath (~1.1x heavy)
@export var wrath_windup := 1.6        # TUNE: the boat completes: wind-up before the ring
@export var wrath_recovery := 2.8      # TUNE
@export var seep_damage := 4           # TUNE: per tick in a seep pool (a light hit is throw_damage; v7 rule: at or below it)
@export var seep_radius := 18.0        # TUNE
@export var seep_warm := 0.6           # TUNE: v7 rule: at least 0.5
@export var seep_life := 120.0         # TUNE: they last until the fake dawn, his fall or a retry

var active := true   # EliteGuard flips it
var state := State.IDLE
var state_time := 0.0
var phase := 1
var dawn := 0.0
var engaged := false
var attacks := 0
var moves_used: Dictionary = {}
var _move := ""
var _last := ""
var _stage := 0
var _mt := 0.0
var _ang := 0.0
var _wind := 0.8
var _spot := Vector2.ZERO
var _from := Vector2.ZERO
var _launched := false
var _hit_done := false
var _ghost_t := 0.0
var _idx := 0
var _dial: Node2D
var _boat: Sprite2D
var _gap1 := 0.0
var _rec_mult := 1.0
var _body_home := Vector2.ZERO
var _deck: Array[String] = []
var _tele: Array[Node] = []
var _shots: Array[Node] = []
var _spots: Array[Vector2] = []
var _land_at: Array[float] = []
var _done: Array[bool] = []
var _log: Node2D
var _seep: Array[Node] = []   # phase 2: the dammed lake seeps in (HazardZones)
var _seep_stage := 0


func _ready() -> void:
	super()
	if dead or is_queued_for_deletion():
		return
	add_to_group("boss")
	if cond != "":   # hidden and inert until Game.check(cond) holds (elite_guard.gd)
		var g := EliteGuard.new()
		g.cond = cond
		add_child(g)
	_body_home = body.position
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
	if _dial == null:
		_build_piece()   # first tick of an active boss: the set piece is up before he is engaged
	if state != State.IDLE and state != State.STUN and state != State.PAUSE:
		dawn = minf(1.0, dawn + delta / (dawn_time * (sabotage_dawn_mult if _sabotaged() else 1.0)))   # ASSUMED (v5)
		_sync_boat()
		if phase == 2:
			_seep_to(1 + mini(2, int(dawn / 0.34)))
		if dawn >= answer_at:   # the reminder: the post answers the dawn (combat.md 5.3 v7)
			BossKit.hint(self, "BOSS_HINT_SANGKURIANG")
			for p: Node in get_tree().get_nodes_in_group("interactable"):
				if p is ArenaPost and p.post_id == post_id:
					BossKit.mark(self, p, "sunda_ca", 1.0, 14.0)
		if dawn >= 1.0 and state == State.CHASE and target != null:
			_begin_move("wrath")   # the boat is whole: dawn breaks
	match state:
		State.IDLE:
			if engaged:
				_enter(State.CHASE)
		State.CHASE:
			if target == null:
				pass
			else:
				var m: String = _pick(d)
				if m != "":
					_begin_move(m)
				else:
					velocity = to_t.normalized() * speed * slow() if d > adze_range * 0.8 else Vector2.ZERO
		State.WINDUP:
			_run_move(delta)
		State.RECOVER:
			if state_time >= recovery * _rec_mult:
				_enter(State.CHASE)
		State.PAUSE:
			if state_time >= pause_time:
				_enter(State.CHASE)
		State.STUN:
			if state_time >= stun_time + (sabotage_stun_bonus if _sabotaged() else 0.0):   # ASSUMED (v5)
				_enter(State.CHASE)
	move_and_slide()


func _enter(s: State) -> void:
	_clear_attack()
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	body.position = _body_home
	if s != State.WINDUP:
		_move = ""
	if s in [State.CHASE, State.RECOVER, State.STUN, State.PAUSE, State.IDLE]:
		BossKit.anim_stop(self)
	body.modulate = STUNNED if s == State.STUN else Color.WHITE
	if s == State.WINDUP:
		body.modulate = Color(1.0, 0.45, 0.45)


# --- the deck ------------------------------------------------------------------------------------------------

func _pool() -> Array[String]:
	var out: Array[String] = ["throw", "timber", "roll", "adze", "heave"]
	if phase >= 2:
		out.append("earthshaker")
	return out


func _fits(m: String, d: float) -> bool:
	match m:
		"adze":
			return d <= adze_range + 10.0
		"heave":
			return d >= 80.0 and d <= 240.0
		"throw":
			return d >= throw_min and d <= throw_max
		"timber":
			return d >= 40.0 and d <= 260.0
		"roll":
			return d >= 70.0 and d <= 260.0
		"earthshaker":
			return d >= 56.0 and d <= 240.0
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
		_deck.clear()
	return ""


# --- moves ---------------------------------------------------------------------------------------------------

func _begin_move(m: String) -> void:
	_enter(State.WINDUP)
	_move = m
	_last = m
	_stage = 0
	_mt = 0.0
	_launched = false
	_hit_done = false
	_rec_mult = 1.0
	attacks += 1
	moves_used[m] = int(moves_used.get(m, 0)) + 1
	_prune_shots()
	_spot = global_position
	_ang = 0.0
	if target != null:
		_spot = target.global_position
		_ang = (target.global_position - global_position).angle()
	match m:
		"throw":
			_wind = throw_windup
			BossKit.anim(self, "cast", 10.0, true)
			_track(BossKit.telegraph_circle(self, _spot, throw_radius, _wind), false)
		"adze":   # sig1
			_wind = adze_windup * WIND
			_rec_mult = heavy_recovery / recovery
			BossKit.anim(self, "sig1", 10.0, true)
			_track(BossKit.telegraph_cone(self, global_position, _ang, 1.6, adze_range, _wind))
		"heave":   # sig2
			_wind = heave_windup * WIND
			_rec_mult = heavy_recovery / recovery
			BossKit.anim(self, "sig2", 10.0, true)
			_track(BossKit.telegraph_circle(self, _spot, heave_radius, _wind), false)
		"timber":
			_idx = 0
			_spots.clear()
			_land_at.clear()
			_done.clear()
			BossKit.anim(self, "cast", 8.0, true)
		"earthshaker":
			_wind = 1.0 * WIND
			_from = global_position
			_spot = BossKit.clamp_arena_pos(self, _spot)
			_rec_mult = heavy_recovery / recovery
			BossKit.anim(self, "dash", 8.0, true)
			_track(BossKit.telegraph_circle(self, _spot, leap_radius, _wind), false)
		"roll":
			_wind = 0.9 * WIND
			_rec_mult = heavy_recovery / recovery
			BossKit.anim(self, "dash", 8.0, true)
			_track(BossKit.telegraph_line(self, global_position, global_position + Vector2.from_angle(_ang) * roll_len, 22.0, _wind))
		"wrath":
			dawn = 0.0   # the dial starts over
			_sync_boat()
			_rec_mult = wrath_recovery / recovery
			_gap1 = _ang + PI * 0.5
			BossKit.roar(self, DAWN, 100.0)
			BossKit.anim(self, "roar", 8.0, true)
			_wrath_marks(wrath_windup * WIND, _gap1)


func _run_move(delta: float) -> void:
	_mt += delta
	match _move:
		"throw":
			if not _launched and _mt >= _wind - LOG_SPEED:
				_launch_log()
			if _mt >= _wind:
				BossKit.strike_circle(self, _spot, throw_radius, throw_damage, false, TIMBER)
				_end_move()
		"adze":
			if _mt >= _wind:
				BossKit.strike_cone(self, global_position, _ang, 1.6, adze_range, adze_damage, true, TIMBER)
				for sh in BossKit.fan(self, global_position + Vector2(0, -8), _ang, 1.2, 5, 90.0, chip_damage, TIMBER, "shard", 3.0, 0.6):
					_shots.append(sh)   # the chips: a short fan past the chop
				BossKit.shake(self, 1.5, 0.15)
				BossKit.punch(self, 1.1, 0.9, 0.3)
				_end_move()
		"heave":
			if not _launched and _mt >= _wind - LOG_SPEED:
				_launch_log()
			if _mt >= _wind:
				BossKit.strike_circle(self, _spot, heave_radius, heave_damage, true, TIMBER)
				BossKit.shake(self, 2.0, 0.2)
				_end_move()
		"timber":
			_run_timber()
		"earthshaker":
			_run_leap(delta)
		"roll":
			_run_roll(delta)
		"wrath":
			_run_wrath()
		_:
			_end_move()


func _end_move() -> void:
	_move = ""
	_enter(State.RECOVER)


func _track(t: BossKit.Telegraph, follow := true) -> void:
	if follow:
		t.follow = self
	_tele.append(t)


func _prune_shots() -> void:
	var keep: Array[Node] = []
	for n in _shots:
		if is_instance_valid(n):
			keep.append(n)
	_shots = keep


func _launch_log() -> void:
	_launched = true
	var lg := BossKit.prop("telegraph/small_log.png", Vector2(12, 4), Color(0.5, 0.33, 0.15))   # 14x6 log sprite
	_log = lg
	lg.z_index = 50
	if _move == "heave":   # the boulder: the same arc, bigger and grey
		lg.scale = Vector2(2, 2)
		lg.modulate = Color(0.7, 0.7, 0.75)
	get_parent().add_child(lg)
	var from := global_position + Vector2(0, -20)
	var to := _spot
	var tw := lg.create_tween()
	tw.tween_method(func(f: float) -> void:
		lg.global_position = from.lerp(to, f) + Vector2(0, -sin(PI * f) * 40.0), 0.0, 1.0, LOG_SPEED)


## A log falling onto a marked circle (visual only; the hit is the strike when the marker is full).
func _drop_log(spot: Vector2, time: float) -> void:
	var lg := BossKit.prop("telegraph/small_log.png", Vector2(14, 4), Color(0.5, 0.33, 0.15))   # 14x6 log sprite
	lg.z_index = 50
	get_parent().add_child(lg)
	var tw := lg.create_tween()
	tw.tween_method(func(f: float) -> void:
		lg.global_position = spot + Vector2(0, -90.0 * (1.0 - f)), 0.0, 1.0, time)
	tw.tween_callback(lg.queue_free)


## Timber rain: logs fall on and around the player, a new marked circle every 0.3 s, each with 0.7 s of warning.
func _run_timber() -> void:
	var n := 7 if phase >= 2 else 5
	if _idx < n and _mt >= _idx * 0.3:
		var base := global_position
		if target != null:
			base = target.global_position
		var p := base
		if _idx > 0:
			p = base + Vector2.from_angle(_idx * 2.4) * (22.0 + 8.0 * _idx)
		_spots.append(p)
		_land_at.append(_mt + 0.7)
		_done.append(false)
		_idx += 1
		_track(BossKit.telegraph_circle(self, p, rain_radius, 0.7), false)
		_drop_log(p, 0.7)
	var all_done := _idx >= n
	for i in _spots.size():
		if _done[i]:
			continue
		all_done = false
		if _mt >= _land_at[i]:
			_done[i] = true
			BossKit.strike_circle(self, _spots[i], rain_radius, rain_damage, false, TIMBER)
			BossKit.shake(self, 1.0, 0.1)
	if all_done:
		_rec_mult = heavy_recovery / recovery
		_end_move()


## Earthshaker: a marked landing spot, he leaps, lands with a smash and a shockwave you jump with a dodge.
func _run_leap(delta: float) -> void:
	var lift := 0.5
	if _mt >= _wind - lift and _mt < _wind:
		var f := (_mt - (_wind - lift)) / lift
		global_position = _from.lerp(_spot, f)
		body.position = _body_home + Vector2(0, -sin(PI * f) * 36.0)
		_ghost_t -= delta
		if _ghost_t <= 0.0:
			_ghost_t = 0.08
			BossKit.ghost(self, TIMBER, 0.3)
	if _mt >= _wind:
		global_position = _spot
		body.position = _body_home
		BossKit.strike_circle(self, _spot, leap_radius, slam_damage, true, TIMBER)
		_shots.append(BossKit.wave(self, _spot, 110.0, 100.0, wave_damage, TIMBER, true))
		BossKit.anim(self, "slam", 10.0, true)
		BossKit.shake(self, 3.0, 0.3)
		BossKit.punch(self, 1.15, 0.85, 0.35)
		_end_move()


## Log roll: a lane marker, then he barrels down it, hitting once.
func _run_roll(delta: float) -> void:
	match _stage:
		0:
			if _mt >= _wind:
				_stage = 1
				_mt = 0.0
				_ghost_t = 0.0
		1:
			velocity = Vector2.from_angle(_ang) * roll_len / roll_time
			_ghost_t -= delta
			if _ghost_t <= 0.0:
				_ghost_t = 0.06
				BossKit.ghost(self, TIMBER, 0.3)
			if not _hit_done and BossKit.in_circle(BossKit.player_point(self), global_position, 16.0):
				_hit_done = true
				BossKit.hurt_player(self, roll_damage, true)
				BossKit.sparks(self, global_position, TIMBER, 10, 70.0, 0.3)
			if _mt >= roll_time:
				BossKit.shake(self, 1.5, 0.15)
				_end_move()


## Dawn Wrath (the boat is whole): a ring of shards with a gap marked in gold. Stand in the gap.
func _wrath_marks(life: float, gap_dir: float) -> void:
	_clear_attack()
	_track(BossKit.telegraph_circle(self, global_position, 130.0, life, Color(1.0, 0.3, 0.2)))
	_track(BossKit.telegraph_cone(self, global_position, gap_dir, 0.8, 130.0, life, Color(1.0, 0.9, 0.5)))


func _wrath_ring(gap_dir: float) -> void:
	BossKit.ring_fx(self, global_position, 60.0, 0.5, DAWN)
	BossKit.shake(self, 2.5, 0.25)
	for i in 28:
		var a := gap_dir + TAU * (i + 0.5) / 28.0
		if absf(angle_difference(a, gap_dir)) < 0.4:
			continue
		_shots.append(BossKit.shoot(self, global_position + Vector2(0, -8), a, 95.0, wrath_damage, DAWN, "shard", 5.0, 2.2, 0.0, true))


func _run_wrath() -> void:
	match _stage:
		0:
			if _mt >= wrath_windup * WIND:
				_wrath_ring(_gap1)
				_stage = 1
				_mt = 0.0
		1:
			if _mt >= 0.5:
				_end_move()


func _clear_attack() -> void:
	for n in _tele:
		if is_instance_valid(n):
			n.queue_free()
	_tele.clear()
	if is_instance_valid(_log):
		_log.queue_free()
	_log = null
	if dead:   # the kneel (BossKit.finisher sets dead first): nothing he made may hurt the player now
		_clear_seep()
		_clear_piece()
		for n in _shots:
			if is_instance_valid(n):
				n.queue_free()
		_shots.clear()


## Phase 2 floor: water pools creep in from the lake (west) side, a column more at each third of the dawn. The east
## (the post, the gate, the threshold) stays dry. The fake dawn drains them (_on_cast).
func _seep_to(stage: int) -> void:
	while _seep_stage < stage:
		var x: float = SEEP_X[_seep_stage]
		_seep_stage += 1
		for y: float in SEEP_Y:
			_seep.append(BossKit.zone(self, home + Vector2(x, y), seep_radius, seep_damage, seep_life, SEEP, seep_warm))


func _clear_seep() -> void:
	for n in _seep:
		if is_instance_valid(n):
			n.queue_free()
	_seep.clear()
	_seep_stage = 0


func _on_health(hp: int, max_hp: int) -> void:
	engaged = true   # first hit
	if phase == 1 and hp > 0 and hp * 2 <= max_hp:
		phase = 2
		_deck.clear()
		_enter(State.PAUSE)
		BossKit.roar(self, DAWN)


## Fake dawn: Ca with the cloth hung, the dial at least `answer_at` full and the player near the post.
func _on_cast(glyph_id: String, _score: float) -> void:
	if glyph_id != "sunda_ca" or dead or target == null or state == State.IDLE or dawn < answer_at:
		return
	if not get_node("/root/Game").has_flag("post:" + post_id):
		return
	for p: Node in get_tree().get_nodes_in_group("interactable"):
		if p is ArenaPost and p.post_id == post_id and p.global_position.distance_to(target.global_position) <= post_range:
			dawn = 0.0
			_sync_boat()
			_clear_seep()
			_deck.clear()
			if _boat != null:   # the boat crumbles
				BossKit.sparks(self, _boat.global_position + Vector2(32, 0), TIMBER, 18, 60.0, 0.8, 80.0)
				BossKit.flash_fx(self, _boat.global_position + Vector2(32, 0), 40.0, 0.5, DAWN)
			get_node("/root/Events").weakness_triggered.emit(kind)
			_enter(State.STUN)
			BossKit.open(self, stun_time + (sabotage_stun_bonus if _sabotaged() else 0.0))
			return


## The set piece: the sundial inlay (fill drawn here) and the boat hull rising mid-arena.
## ponytail: the hull "rises" by revealing more of its top (region clip), not by a real sprite animation.
func _build_piece() -> void:
	var at := home + BOAT_OFFSET
	var dial := Dial.new()
	dial.boss = self
	dial.position = at - Vector2(0, LIFT)
	_dial = dial
	get_parent().add_child(dial)
	_boat = BossKit.prop("props/arena_boat.png", Vector2(64, 32), Color(0.45, 0.3, 0.15)) as Sprite2D
	if _boat != null:
		_boat.centered = false
		_boat.region_enabled = true
		_boat.position = at + Vector2(-32, 12)
		get_parent().add_child(_boat)
	tree_exiting.connect(_clear_piece)
	_sync_boat()


func _sync_boat() -> void:
	if _boat == null:
		return
	var h := roundf(4.0 + 28.0 * dawn)
	_boat.region_rect = Rect2(0, 0, 64, h)
	_boat.position.y = home.y + BOAT_OFFSET.y + 12.0 + (32.0 - h)


func _clear_piece() -> void:
	if is_instance_valid(_dial):
		_dial.queue_free()
	if is_instance_valid(_boat):
		_boat.queue_free()
	_dial = null
	_boat = null


## The sundial's gold fill, a pixel wedge growing clockwise from the top with `boss.dawn`.
class Dial extends Node2D:
	var boss: Sangkuriang
	var _tex: Texture2D = load("res://assets/art/props/arena_sundial.png")

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		draw_set_transform(Vector2(0, LIFT))
		if _tex != null:
			draw_texture(_tex, Vector2(-12, -12))
		var f := roundf(clampf(boss.dawn, 0.0, 1.0) * 24.0) / 24.0
		if f > 0.0:
			var arc := f * TAU
			BossKit.px_fill(self, BossKit.px_wedge(-PI * 0.5 + arc * 0.5, arc, DIAL_R, DIAL_R - 6.0), Color(DAWN, 0.55))
		BossKit.px_fill(self, BossKit.px_disc(DIAL_R, DIAL_R - 2.0), Color(DAWN, 0.3))


## Story v5: Laras's sabotage flag is set (Game.has_flag, underscore form).
func _sabotaged() -> bool:
	var g := get_node_or_null("/root/Game")
	return g != null and sabotage_flag != "" and g.has_flag(sabotage_flag)


func _on_flinch() -> void:
	pass   # bosses do not flinch


func _on_died() -> void:
	_move = ""
	_clear_attack()
	_clear_seep()
	_clear_piece()
	for n in _shots:
		if is_instance_valid(n):
			n.queue_free()
	_shots.clear()
	body.position = _body_home
	BossKit.anim_stop(self)
	super()
	# Released, not killed: kneel and fade, then announce.
	var tw := body.create_tween().set_parallel()
	tw.tween_property(body, "modulate:a", 0.0, 0.35)
	tw.tween_property(body, "scale:y", 0.6, 0.35)
	var events := get_node("/root/Events")
	get_tree().create_timer(0.3).timeout.connect(func() -> void: events.boss_defeated.emit("sangkuriang"))
