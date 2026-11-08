class_name BarmaWijaya extends EnemyBase
## Boss: Prabu Barma Wijaya, the false king and illusionist (bestiary.md Story v2). Moves: kris thrust, kris-dart fan,
## teleport flurry (ghost marks, three cuts), royal decree (rings of darts with a rotating gap), mirror volley (three
## decoy points converge on you), and the limit break Coronation (eight golden spokes, then a rotated second set).
## Glamour at 70% and 35% HP: 3 copies of this scene (copy = true) spread out with him over 1 s. Copies are always
## invincible: a weapon hit flickers through (Hurtbox.dodged), a spell (any script under res://spells/) breaks one.
## While a copy stands he is invincible too; the last break stuns him 3 s. Copies only thrust and fan, for half damage.
## Phase = 1 + glamours: phase 2 (after the 70% glamour) adds decree, mirror and Coronation.
## Defeat: he never dies. At 0 HP he kneels, goes inert, stays in Game.killed, then Events.boss_defeated.
## The HUD polls: group "boss", health, boss_name_key, engaged.

enum State { IDLE, CHASE, WINDUP, THRUST, RECOVER, GLAMOUR, STUN, ACT }

const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const STUNNED := Color(0.7, 0.75, 1.0)
const GOLD := Color(1.0, 0.8, 0.3)
const SHOT := preload("res://entities/enemies/spirit_shot.tscn")
const MARKS := [70, 35]   # spec: glamour at these HP percents
const COPIES := 3         # spec
const HEAVY: Array[String] = ["flurry", "decree", "mirror", "coronation"]

@export var boss_name_key := "BOSS_BARMA_WIJAYA"
@export var sabotage_flag := "laras_sabotage_glamour_seal"   # HUD boss bar reads this
@export var sabotage_stun_bonus := 1.5  # TUNE (v5): signet wax stolen, the stun after the last copy breaks lasts this much longer
@export var cond := ""                 # hidden and inert until Game.check(cond) holds (EliteGuard); "" = always
@export var speed := 45.0              # spec
@export var engage_range := 128.0      # 8 tiles
@export var thrust_windup := 0.5       # TUNE (light >= 0.5 s)
@export var thrust_length := 48.0      # spec: 3 tiles
@export var thrust_speed := 260.0      # TUNE
@export var thrust_damage := 14        # spec, light
@export var fan_windup := 0.6          # spec
@export var fan_damage := 12           # spec, light, each dart
@export var fan_spread := 30.0         # TUNE, degrees
@export var fan_range := 200.0         # TUNE
@export var shot_speed := 120.0        # TUNE
@export var refan_after := 2.0         # TUNE: unused since the move deck, kept for scenes
@export var recovery := 1.0            # TUNE: after a light move
@export var recovery_heavy := 2.5      # TUNE: the punish window after a set-piece
@export var flurry_hits := 3           # TUNE
@export var flurry_tele := 0.6         # TUNE: the ghost mark shows this long before he blinks there
@export var flurry_cut_windup := 0.5   # TUNE: cone marker after each blink
@export var flurry_radius := 40.0      # TUNE: blink spots lie this far from the player
@export var decree_windup := 0.9       # TUNE: heavy
@export var decree_damage := 12        # TUNE: each dart
@export var decree_count := 12         # TUNE: darts per ring
@export var decree_gap_slots := 2      # TUNE: missing darts per ring (the safe gap)
@export var decree_volleys := 5        # TUNE
@export var decree_interval := 0.55    # TUNE
@export var decree_speed := 85.0       # TUNE
@export var mirror_windup := 0.7       # TUNE
@export var mirror_volleys := 2        # TUNE
@export var mirror_speed := 190.0      # TUNE
@export var ult_windup := 1.4          # TUNE: Coronation, long telegraph
@export var ult_damage := 24           # TUNE: ~1.7x light, avoidable between the spokes
@export var ult_length := 150.0        # TUNE
@export var ult_cooldown := 22.0       # TUNE
@export var glamour_time := 1.0        # spec: the shuffle
@export var glamour_radius := 48.0     # TUNE: the 4 figures end on this ring
@export var stun_time := 3.0           # spec
@export var copy_mult := 0.5           # spec: copies hit for half

var copy := false          # set before add_child: a glamour copy
var real: BarmaWijaya      # a copy's king
var copies: Array[BarmaWijaya] = []
var active := true         # EliteGuard
var state := State.IDLE
var state_time := 0.0
var engaged := false
var attacks := 0
var glamours := 0
var moves_used: Dictionary = {}   # move name -> times begun
var _move := ""
var _deck: Array[String] = []
var _last_move := ""
var _stage := 0
var _sub := 0.0
var _rec := 1.0
var _ult_cd := 0.0
var _dir := Vector2.RIGHT
var _from := Vector2.ZERO
var _spot := Vector2.ZERO
var _count := 0
var _base := 0.0
var _ghost_t := 0.0
var _tg: Array[Node2D] = []
var _mpts: Array[Vector2] = []
var _mdirs: Array[float] = []


func _ready() -> void:
	super()
	if dead or is_queued_for_deletion():
		return
	hurtbox.dodged.connect(_on_dodged)
	if copy:
		engaged = true
		health.invincible_time = INF   # ponytail: INF never counts down, so a copy is never hurt
		_enter(State.GLAMOUR)
		return
	add_to_group("boss")
	health.changed.connect(_on_health)
	var g := EliteGuard.new()
	g.cond = cond
	add_child(g)


func phase() -> int:
	return 1 + glamours


func _tick(delta: float) -> void:
	state_time += delta
	_ult_cd = maxf(0.0, _ult_cd - delta)
	if target == null:
		return
	var to_t := target.global_position - global_position
	var d := to_t.length()
	if d <= engage_range:
		engaged = true
	match state:
		State.IDLE:
			if engaged:
				_enter(State.CHASE)
		State.CHASE:
			var m := _pick(d)
			if m != "":
				_begin_move(m, to_t)
			elif d > thrust_length * 0.6:
				velocity = to_t.normalized() * speed * slow()
		State.WINDUP:
			if state_time >= (fan_windup if _move == "fan" else thrust_windup):
				if _move == "fan":
					_fire_fan()
					_finish(recovery)
				else:
					_start_thrust()
		State.THRUST:
			_ghost_t -= delta
			if _ghost_t <= 0.0:
				_ghost_t = 0.05
				BossKit.ghost(self, GOLD, 0.25)
			if global_position.distance_to(_from) >= thrust_length or (state_time > 0.05 and is_on_wall()):
				_finish(recovery)
		State.ACT:
			_act(delta)
		State.RECOVER:
			if state_time >= _rec:
				_enter(State.CHASE)
		State.GLAMOUR:
			if state_time >= glamour_time:
				_enter(State.CHASE)
		State.STUN:
			if state_time >= stun_time + (sabotage_stun_bonus if (_sabotaged() and not copy) else 0.0):   # ASSUMED (v5)
				_enter(State.CHASE)
	move_and_slide()


func _enter(s: State) -> void:
	_clear_marks()
	attack_hitbox.deactivate()
	BossKit.anim_stop(self)
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	body.modulate = Color(1.0, 0.45, 0.45) if s == State.WINDUP else (STUNNED if s == State.STUN else Color.WHITE)


func _finish(rec: float) -> void:
	_rec = rec
	_enter(State.RECOVER)


func _clear_marks() -> void:
	for n in _tg:
		if is_instance_valid(n):
			n.queue_free()
	_tg.clear()


func _dmg(n: int) -> int:
	return roundi(n * (copy_mult if copy else 1.0))


# --- the move deck ---

func _refill() -> void:
	_deck.clear()
	var names: Array[String] = ["thrust", "fan"]
	if not copy:
		names.append("flurry")
		if phase() >= 2:
			names.append("decree")
			names.append("mirror")
	_deck.append_array(names)
	_deck.shuffle()


func _ok(m: String, d: float) -> bool:
	if m in HEAVY and m == _last_move:
		return false
	match m:
		"thrust":
			return d <= thrust_length
		"fan":
			return d <= fan_range
		"flurry":
			return d <= 240.0
		"decree":
			return d <= 200.0
		"mirror":
			return d <= 220.0
	return false


## Next move by distance and phase: the Coronation when it is ready, else the first fitting card of the shuffled deck.
func _pick(d: float) -> String:
	if not copy and phase() >= 2 and _ult_cd <= 0.0 and d <= 220.0:
		return "coronation"
	for attempt in 2:
		for i in _deck.size():
			var m: String = _deck[i]
			if _ok(m, d):
				_deck.remove_at(i)
				return m
		if attempt == 0:
			_refill()
	return ""


## Starts a move. thrust and fan use the WINDUP and THRUST states; the set-pieces run in ACT stages.
func _begin_move(m: String, to_t := Vector2.ZERO) -> void:
	_move = m
	_last_move = m
	moves_used[m] = int(moves_used.get(m, 0)) + 1
	attacks += 1
	if to_t == Vector2.ZERO and target != null:
		to_t = target.global_position - global_position
	_dir = to_t.normalized() if to_t != Vector2.ZERO else Vector2.RIGHT
	match m:
		"thrust", "fan":
			_begin_windup(m == "fan")
		"flurry":
			_enter(State.ACT)
			_count = flurry_hits
			_flurry_mark()
		"decree":
			_enter(State.ACT)
			_base = randf() * TAU
			_count = 0
			var r := BossKit.telegraph_ring(self, global_position, 110.0, 24.0, decree_windup, GOLD)
			r.follow = self
			_tg.append(r)
			BossKit.anim(self, "cast")
			BossKit.flash_fx(self, global_position + Vector2(0, -14), 22.0, 0.4, GOLD)
			_goto(0)
		"mirror":
			_enter(State.ACT)
			_count = mirror_volleys
			_mirror_mark()
		"coronation":
			_ult_cd = ult_cooldown
			_enter(State.ACT)
			_base = randf() * TAU
			BossKit.anim(self, "cast")
			BossKit.roar(self, GOLD, 60.0)
			_spoke_marks(_base, ult_windup)
			_goto(0)
		_:
			_finish(recovery)


func _goto(stage: int) -> void:
	_stage = stage
	_sub = 0.0


func _act(delta: float) -> void:
	_sub += delta
	match _move:
		"flurry":
			_act_flurry()
		"decree":
			_act_decree()
		"mirror":
			_act_mirror()
		"coronation":
			_act_coronation()
		_:
			_finish(recovery)


# --- thrust and fan ---

## Wind-up with line markers: one along the thrust, three along the fan.
func _begin_windup(fan: bool) -> void:
	_enter(State.WINDUP)
	BossKit.anim(self, "cast")
	var reach := fan_range if fan else thrust_length
	for i in (3 if fan else 1):
		var dir := _dir.rotated(deg_to_rad(fan_spread) * (i - 1) / 2.0) if fan else _dir
		_tg.append(BossKit.telegraph_line(self, global_position, global_position + dir * reach, 8.0, fan_windup if fan else thrust_windup, GOLD))


func _start_thrust() -> void:
	_enter(State.THRUST)
	BossKit.anim(self, "dash", 12.0, false)
	_from = global_position
	_ghost_t = 0.0
	velocity = _dir * thrust_speed
	attack_hitbox.position = Vector2.ZERO
	attack_hitbox.damage = _dmg(thrust_damage)
	attack_hitbox.heavy = false
	attack_hitbox.activate()


func _fire_fan() -> void:
	for i in 3:
		var shot := SHOT.instantiate() as Arrow
		shot.source = self
		shot.damage = _dmg(fan_damage)
		shot.direction = _dir.rotated(deg_to_rad(fan_spread) * (i - 1) / 2.0)
		shot.speed = shot_speed
		shot.max_range = fan_range
		shot.modulate = Color(1.0, 0.85, 0.4)   # ponytail: a recolored spirit shot until darts have art
		get_parent().add_child(shot)
		shot.global_position = aim.global_position


# --- teleport flurry: ghost mark, blink, cone cut, three times ---

func _flurry_mark() -> void:
	var feet := target.global_position
	_spot = feet + Vector2.from_angle(randf() * TAU) * flurry_radius
	_tg.append(BossKit.telegraph_circle(self, _spot, 14.0, flurry_tele, GOLD))
	BossKit.ghost(self, GOLD, flurry_tele)
	BossKit.anim(self, "dash", 12.0, false)
	body.modulate = Color(1.0, 1.0, 1.0, 0.45)
	_goto(1)


func _act_flurry() -> void:
	match _stage:
		1:
			if _sub >= flurry_tele:
				BossKit.ghost(self, GOLD, 0.4)
				BossKit.flash_fx(self, global_position + Vector2(0, -10), 18.0, 0.3, GOLD)
				global_position = _spot
				BossKit.flash_fx(self, global_position + Vector2(0, -10), 18.0, 0.3, GOLD)
				body.modulate = Color.WHITE
				var to_t := target.global_position - global_position
				_dir = to_t.normalized() if to_t != Vector2.ZERO else Vector2.RIGHT
				_tg.append(BossKit.telegraph_cone(self, global_position, _dir.angle(), 1.2, thrust_length + 8.0, flurry_cut_windup, GOLD))
				BossKit.anim(self, "cast")
				_goto(2)
		2:
			if _sub >= flurry_cut_windup:
				BossKit.anim(self, "slam", 12.0, false)
				BossKit.strike_cone(self, global_position, _dir.angle(), 1.2, thrust_length + 8.0, _dmg(thrust_damage), false, GOLD)
				BossKit.punch(self, 1.15, 0.9, 0.2)
				_count -= 1
				if _count > 0:
					_flurry_mark()
				else:
					_finish(recovery_heavy)


# --- royal decree: rings of darts, each with a gap that turns ---

func _act_decree() -> void:
	match _stage:
		0:
			if _sub >= decree_windup:
				_goto(1)
				_sub = decree_interval   # the first ring goes at once
		1:
			if _sub >= decree_interval:
				_sub = 0.0
				_fire_ring()
				_count += 1
				if _count >= decree_volleys:
					_goto(2)
		2:
			if _sub >= 1.0:
				_finish(recovery_heavy)


func _fire_ring() -> void:
	var offset := _base + float(_count) * deg_to_rad(18.0)
	var from := global_position + Vector2(0, -8)
	BossKit.ring_fx(self, global_position, 40.0, 0.3, GOLD)
	BossKit.anim(self, "slam", 14.0, false)
	for i in decree_count:
		if i < decree_gap_slots:
			continue
		var a := offset + TAU * float(i) / float(decree_count)
		BossKit.shoot(self, from, a, decree_speed, _dmg(decree_damage), GOLD, "blade", 4.0, 2.6)


# --- mirror volley: three decoy points around the player, lines converge ---

func _mirror_mark() -> void:
	_mpts.clear()
	_mdirs.clear()
	var feet := target.global_position + Vector2(0, -8)
	var base := randf() * TAU
	for i in 3:
		var pt := feet + Vector2.from_angle(base + TAU * float(i) / 3.0) * 90.0
		var dir := (feet - pt).angle()
		_mpts.append(pt)
		_mdirs.append(dir)
		_tg.append(BossKit.telegraph_line(self, pt, pt + Vector2.from_angle(dir) * 150.0, 8.0, mirror_windup, GOLD))
		BossKit.flash_fx(self, pt, 10.0, mirror_windup, GOLD)
	BossKit.anim(self, "cast")
	_goto(1)


func _act_mirror() -> void:
	if _stage == 1 and _sub >= mirror_windup:
		for i in _mpts.size():
			BossKit.shoot(self, _mpts[i], _mdirs[i], mirror_speed, _dmg(fan_damage), GOLD, "blade", 4.0, 1.4)
			BossKit.sparks(self, _mpts[i], GOLD, 6, 40.0, 0.3)
		_count -= 1
		if _count > 0:
			_mirror_mark()
		else:
			_goto(2)
	elif _stage == 2 and _sub >= 0.6:
		_finish(recovery_heavy)


# --- Coronation (limit break): eight spokes, then eight more turned half a gap; stand between them ---

func _spoke_marks(base: float, life: float) -> void:
	for k in 8:
		var a := base + TAU * float(k) / 8.0
		_tg.append(BossKit.telegraph_line(self, global_position, global_position + Vector2.from_angle(a) * ult_length, 14.0, life, GOLD))


func _spoke_strike(base: float) -> void:
	var p := BossKit.player_point(self)
	var hit := false
	for k in 8:
		var a := base + TAU * float(k) / 8.0
		var to := global_position + Vector2.from_angle(a) * ult_length
		BossKit.beam_fx(self, global_position, to, 14.0, 0.3, GOLD)
		if BossKit.in_line(p, global_position, to, 14.0):
			hit = true
	BossKit.shake(self, 2.0, 0.3)
	if hit:
		BossKit.hurt_player(self, _dmg(ult_damage), true)


func _act_coronation() -> void:
	match _stage:
		0:
			if _sub >= ult_windup:
				_spoke_strike(_base)
				_clear_marks()
				_spoke_marks(_base + TAU / 16.0, 0.7)
				BossKit.anim(self, "slam", 12.0, false)
				_goto(1)
		1:
			if _sub >= 0.7:
				_spoke_strike(_base + TAU / 16.0)
				_clear_marks()
				_goto(2)
		2:
			if _sub >= 0.4:
				_finish(recovery_heavy + 0.5)


# --- glamour ---

func _on_health(hp: int, max_hp: int) -> void:
	engaged = true   # first hit
	if glamours < MARKS.size() and hp > 0 and hp * 100 <= max_hp * MARKS[glamours]:
		glamours += 1
		health.invincible_time = INF
		_deck.clear()
		_ult_cd = maxf(_ult_cd, 6.0)
		_enter(State.GLAMOUR)
		_glamour.call_deferred()   # ponytail: deferred, the hit can come mid physics query


## 3 copies appear on him, then all 4 figures move to shuffled spots on a ring over glamour_time.
func _glamour() -> void:
	if dead:
		return
	BossKit.roar(self, GOLD, 70.0)
	var figs: Array[Node2D] = [self]
	var scene := load(scene_file_path) as PackedScene
	for i in COPIES:
		var c := scene.instantiate() as BarmaWijaya
		c.copy = true
		c.real = self
		c.unique_id = ""
		c.ilmu = 0
		c.position = position
		get_parent().add_child(c)
		copies.append(c)
		figs.append(c)
	figs.shuffle()
	var at := global_position
	for i in figs.size():
		var spot := at + Vector2.from_angle(TAU * (i + 0.5) / figs.size()) * glamour_radius
		figs[i].create_tween().tween_property(figs[i], "global_position", spot, glamour_time)


## Invincible figures (copies always, the king during glamour): weapons flicker through, a cast glyph breaks a copy.
func _on_dodged(hitbox: Hitbox) -> void:
	if copy and hitbox.get_script() != null and (hitbox.get_script() as Script).resource_path.begins_with("res://spells/"):
		_break()
		return
	body.modulate.a = 0.3
	body.create_tween().tween_property(body, "modulate:a", 1.0, 0.15)


func _break() -> void:
	if dead:
		return
	_enter(State.STUN)
	dead = true
	remove_from_group("enemy")
	hurtbox.set_deferred("monitorable", false)
	BossKit.sparks(self, global_position + Vector2(0, -12), GOLD, 14, 70.0, 0.5)   # the glass shatters
	BossKit.ring_fx(self, global_position, 24.0, 0.3, GOLD)
	if is_instance_valid(real):
		real._copy_broken(self)
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.3)   # ponytail: a fade until the true-face reveal has art
	tw.tween_callback(queue_free)


func _copy_broken(c: BarmaWijaya) -> void:
	copies.erase(c)
	if copies.is_empty() and not dead:
		health.invincible_time = 0.0
		_enter(State.STUN)
		BossKit.flash_fx(self, global_position + Vector2(0, -12), 28.0, 0.4, Color(0.7, 0.75, 1.0))


## Story v5: Laras's sabotage flag is set (Game.has_flag, underscore form).
func _sabotaged() -> bool:
	var g := get_node_or_null("/root/Game")
	return g != null and sabotage_flag != "" and g.has_flag(sabotage_flag)


func _on_flinch() -> void:
	pass   # bosses do not flinch


## Never dies: EnemyBase death minus the free and enemy_killed. Kneels and stays, inert.
func _on_died() -> void:
	if dead:
		return
	_enter(State.STUN)
	dead = true
	engaged = false
	remove_from_group("enemy")
	remove_from_group("boss")
	hurtbox.set_deferred("monitorable", false)
	body.modulate = Color(0.75, 0.7, 0.65)
	body.create_tween().tween_property(body, "scale:y", 0.7, 0.35)   # ponytail: one knee, placeholder
	var game := get_node("/root/Game")
	game.add_ilmu(ilmu)
	if unique_id != "":
		game.killed.append(unique_id)
		game.save_game()
	_float_label()
	var events := get_node("/root/Events")
	get_tree().create_timer(0.3).timeout.connect(func() -> void: events.boss_defeated.emit("barma_wijaya"))
