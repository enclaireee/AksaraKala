class_name HariangBanga extends EnemyBase
## Boss: Hariang Banga, the river duel (bestiary.md Story v2). Guard: he faces the player (never turning in a wind-up
## or attack); weapon hits from the front do x0.2. A Jawa Na Dash-strike through him (the Arca check) breaks the
## guard: 2 s stagger, x1.5 damage taken for 3 s. Hits from behind and spells land in full.
## Moves: 3-cut combo, lunge, rising crescent (blade wave), iaido (long stance, then an instant wide cone), triple-step
## cuts, and the parry stance (any hit during the glow is negated and countered; waiting it out leaves him open 1.5 s).
## Phase 2 at 50% HP (a pause and a roar): the river wakes: water lunges, flood circles that leave pools, and the limit
## break Tsunami (a huge cone with a safe wedge behind him, then a ring wave).
## Yields at 15% HP: he never dies; he sheathes, goes inert, stays in Game.killed, then Events.boss_defeated.
## The HUD polls: group "boss", health, boss_name_key, engaged.
# ponytail: the guard refunds hp after the hit lands (Hurtbox applies damage first), as PrajuritTerkutuk does.

enum State { IDLE, CHASE, WINDUP, LUNGE, RECOVER, STAGGER, ACT, PARRY, PHASE }

const MARKER := Color(1.0, 0.3, 0.3, 0.35)
const STUNNED := Color(0.7, 0.75, 1.0)
const WATER := Color(0.35, 0.7, 1.0)
const STEEL := Color(0.85, 0.92, 1.0)
const FRONT_HALF := PI / 2.0   # TUNE: the front is a half circle, as the Prajurit's shield
const HEAVY: Array[String] = ["lunge", "iaido", "parry", "river_lunge", "flood", "tsunami"]

@export var boss_name_key := "BOSS_HARIANG_BANGA"
@export var cond := ""                 # hidden and inert until Game.check(cond) holds (EliteGuard); "" = always
@export var speed := 60.0              # spec
@export var engage_range := 128.0      # 8 tiles
@export var turn_rate := 270.0         # TUNE: degrees per second
@export var guard_mult := 0.2          # spec
@export var open_mult := 1.5           # spec
@export var stagger_time := 2.0        # spec
@export var open_time := 3.0           # spec
@export var yield_at := 15             # spec: HP percent
@export var cut_range := 32.0          # TUNE: starts the combo at or inside this
@export var cut_windup := 0.5          # TUNE (light >= 0.5 s), each cut
@export var cut_reach := 16.0          # TUNE: cut centre ahead of him
@export var cut_radius := 18.0         # TUNE
@export var cut_damage := 15           # spec, light
@export var lunge_windup := 0.8        # TUNE (heavy, with a ground marker)
@export var lunge_length := 96.0       # spec: 6 tiles
@export var lunge_speed := 320.0       # TUNE
@export var lunge_damage := 20         # spec, heavy
@export var wave_windup := 0.6         # spec
@export var wave_length := 160.0       # spec: 10 tiles
@export var wave_speed := 160.0        # TUNE
@export var wave_damage := 14          # spec, light
@export var rewave_after := 2.0        # TUNE: unused since the move deck, kept for scenes
@export var recovery := 1.0            # TUNE: after a light move
@export var recovery_heavy := 2.5      # TUNE: the punish window after a heavy move
@export var iaido_windup := 1.2        # TUNE: the long stance
@export var iaido_arc := 2.4           # TUNE: radians, wide
@export var iaido_reach := 76.0        # TUNE
@export var iaido_damage := 28         # TUNE: heavy
@export var step_windup := 0.5         # TUNE: each of the three steps
@export var step_length := 30.0        # TUNE
@export var step_damage := 15          # TUNE: light, each
@export var parry_time := 1.4          # TUNE: the glow
@export var parry_open := 1.5          # TUNE: open (x1.5, guard down) after a parry nobody tried
@export var counter_reach := 60.0      # TUNE
@export var counter_damage := 24       # TUNE: heavy
@export var river_windup := 0.6        # TUNE
@export var river_length := 88.0       # TUNE
@export var river_speed := 340.0       # TUNE
@export var river_damage := 16         # TUNE
@export var river_lunges := 3          # TUNE
@export var flood_windup := 0.9        # TUNE: heavy
@export var flood_radius := 26.0       # TUNE
@export var flood_damage := 20         # TUNE
@export var pool_damage := 6           # TUNE: tick of a lingering pool
@export var tsunami_windup := 1.6      # TUNE: limit break, long telegraph
@export var tsunami_arc := 4.4         # TUNE: radians; the wedge behind him stays safe
@export var tsunami_reach := 112.0     # TUNE
@export var tsunami_damage := 30       # TUNE: ~1.5x heavy
@export var tsunami_wave_damage := 16  # TUNE
@export var tsunami_cooldown := 24.0   # TUNE
@export var pause_time := 1.0          # spec: the pause at the phase change

var active := true         # EliteGuard
var state := State.IDLE
var state_time := 0.0
var engaged := false
var attacks := 0
var phase := 1
var facing := 0.0          # radians
var open_left := 0.0       # guard broken: x1.5 damage taken
var cuts_left := 0
var moves_used: Dictionary = {}   # move name -> times begun
var _move := ""            # the move being run
var _deck: Array[String] = []
var _last_move := ""
var _stage := 0
var _sub := 0.0
var _rec := 1.0
var _count := 0
var _ult_cd := 0.0
var _counter := false      # parry: something touched him during the glow
var _hit_done := false
var _dir := Vector2.RIGHT
var _from := Vector2.ZERO
var _spots: Array[Vector2] = []
var _tg: Array[Node2D] = []
var _blast_left := 0.0
var _ghost_t := 0.0
var _dt := 0.0
var _floored := false      # a raw hit reached 0 hp: no guard refund, he yields


func _ready() -> void:
	super()
	if dead or is_queued_for_deletion():
		return
	add_to_group("boss")
	health.changed.connect(_on_health)
	var g := EliteGuard.new()
	g.cond = cond
	add_child(g)


func _tick(delta: float) -> void:
	state_time += delta
	open_left -= delta
	_ult_cd = maxf(0.0, _ult_cd - delta)
	if _blast_left > 0.0:
		_blast_left -= delta
		if _blast_left <= 0.0:
			attack_hitbox.deactivate()
	if target == null:
		return
	var to_t := target.global_position - global_position
	var d := to_t.length()
	if d <= engage_range:
		engaged = true
	if state in [State.IDLE, State.CHASE, State.RECOVER, State.PARRY]:
		var step := deg_to_rad(turn_rate) * delta
		facing += clampf(angle_difference(facing, to_t.angle()), -step, step)
		aim.rotation = facing
	match state:
		State.IDLE:
			if engaged:
				_enter(State.CHASE)
		State.CHASE:
			var m := _pick(d)
			if m != "":
				_begin_move(m)
			else:
				velocity = to_t.normalized() * speed * slow()
		State.WINDUP:
			if state_time >= {"cut": cut_windup, "lunge": lunge_windup, "wave": wave_windup}[_move]:
				_strike()
		State.LUNGE:
			_ghost_t -= delta
			if _ghost_t <= 0.0:
				_ghost_t = 0.05
				BossKit.ghost(self, WATER, 0.25)
			if global_position.distance_to(_from) >= lunge_length or (state_time > 0.05 and is_on_wall()):
				attack_hitbox.deactivate()
				_finish(recovery_heavy)
		State.ACT:
			_act(delta, to_t)
		State.PARRY:
			if _counter:
				_do_counter(to_t)
			elif state_time >= parry_time:
				open_left = parry_open   # he waited and nobody fell for it: guard down
				_finish(recovery)
		State.RECOVER:
			if state_time >= _rec:
				_enter(State.CHASE)
		State.STAGGER:
			if state_time >= stagger_time:
				_enter(State.CHASE)
		State.PHASE:
			if state_time >= pause_time:
				_enter(State.CHASE)
	move_and_slide()


func _enter(s: State) -> void:
	_clear_marks()
	BossKit.anim_stop(self)
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	body.modulate = Color(1.0, 0.45, 0.45) if s == State.WINDUP else (STUNNED if s == State.STAGGER else Color.WHITE)


func _finish(rec: float) -> void:
	_rec = rec
	_enter(State.RECOVER)


func _clear_marks() -> void:
	for n in _tg:
		if is_instance_valid(n):
			n.queue_free()
	_tg.clear()


func _goto(stage: int) -> void:
	_stage = stage
	_sub = 0.0


## Face the player at once (between the steps of a combo, never inside a wind-up).
func _aim_now(to_t: Vector2) -> void:
	if to_t != Vector2.ZERO:
		facing = to_t.angle()
	aim.rotation = facing
	_dir = Vector2.from_angle(facing)


# --- the move deck ---

func _refill() -> void:
	_deck.clear()
	var names: Array[String] = ["cut", "lunge", "wave", "iaido", "triple_step", "parry"]
	if phase >= 2:
		names.append("river_lunge")
		names.append("flood")
	_deck.append_array(names)
	_deck.shuffle()


func _ok(m: String, d: float) -> bool:
	if m in HEAVY and m == _last_move:
		return false
	match m:
		"cut":
			return d <= cut_range + 8.0
		"lunge":
			return d >= 40.0 and d <= lunge_length + 12.0
		"wave":
			return d >= 64.0 and d <= wave_length
		"iaido":
			return d <= iaido_reach - 8.0
		"triple_step":
			return d >= 30.0 and d <= 110.0
		"parry":
			return d <= 120.0
		"river_lunge":
			return d <= 150.0
		"flood":
			return d <= 170.0
	return false


## Next move by distance and phase: Tsunami when ready, else the first fitting card of the shuffled deck.
func _pick(d: float) -> String:
	if phase >= 2 and _ult_cd <= 0.0 and d <= 140.0:
		return "tsunami"
	for attempt in 2:
		for i in _deck.size():
			var m: String = _deck[i]
			if _ok(m, d):
				_deck.remove_at(i)
				return m
		if attempt == 0:
			_refill()
	return ""


func _begin_move(m: String) -> void:
	_move = m
	_last_move = m
	moves_used[m] = int(moves_used.get(m, 0)) + 1
	attacks += 1
	_dir = Vector2.from_angle(facing)
	match m:
		"cut":
			cuts_left = 3
			_begin_windup("cut")
		"lunge", "wave":
			_begin_windup(m)
		"iaido":
			_enter(State.ACT)
			BossKit.anim(self, "cast")
			var c := BossKit.telegraph_cone(self, global_position, facing, iaido_arc, iaido_reach, iaido_windup, STEEL)
			c.follow = self
			_tg.append(c)
			_goto(0)
		"triple_step":
			_enter(State.ACT)
			_count = 3
			_step_mark()
		"parry":
			_counter = false
			_enter(State.PARRY)
			BossKit.anim(self, "cast")
			var p := BossKit.telegraph_circle(self, global_position, 30.0, parry_time, Color(1.0, 1.0, 0.7))
			p.follow = self
			_tg.append(p)
			body.modulate = Color(1.5, 1.5, 1.2)
		"river_lunge":
			_enter(State.ACT)
			_count = river_lunges
			_river_mark()
		"flood":
			_enter(State.ACT)
			_flood_mark()
		"tsunami":
			_ult_cd = tsunami_cooldown
			_enter(State.ACT)
			BossKit.anim(self, "cast")
			BossKit.roar(self, WATER, 60.0)
			var c := BossKit.telegraph_cone(self, global_position, facing, tsunami_arc, tsunami_reach, tsunami_windup, WATER)
			c.follow = self
			_tg.append(c)
			_goto(0)
		_:
			_finish(recovery)


func _act(delta: float, to_t: Vector2) -> void:
	_sub += delta
	_dt = delta
	match _move:
		"iaido":
			_act_iaido()
		"triple_step":
			_act_step(to_t)
		"river_lunge":
			_act_river(to_t)
		"flood":
			_act_flood()
		"tsunami":
			_act_tsunami()
		_:
			_finish(recovery)


# --- cut combo, lunge and crescent (WINDUP, then _strike) ---

## Wind-up with a marker along his facing: a circle for a cut, a line for the lunge and the crescent.
func _begin_windup(move: String) -> void:
	_enter(State.WINDUP)
	_move = move
	_dir = Vector2.from_angle(facing)
	BossKit.anim(self, "cast" if move != "lunge" else "dash", 10.0, false)
	match move:
		"cut":
			_tg.append(BossKit.telegraph_circle(self, global_position + _dir * cut_reach, cut_radius, cut_windup, BossKit.RED))
		"lunge":
			_tg.append(BossKit.telegraph_line(self, global_position, global_position + _dir * lunge_length, 22.0, lunge_windup, BossKit.RED))
		_:
			_tg.append(BossKit.telegraph_line(self, global_position, global_position + _dir * wave_length, 10.0, wave_windup, WATER))


func _strike() -> void:
	var shape := (attack_hitbox.get_node("Shape") as CollisionShape2D).shape as CircleShape2D
	match _move:
		"cut":
			attack_hitbox.global_position = global_position + _dir * cut_reach
			shape.radius = cut_radius
			attack_hitbox.damage = cut_damage
			attack_hitbox.heavy = false
			attack_hitbox.activate()
			_blast_left = 0.12   # TUNE
			BossKit.slash(self, global_position, facing, 1.6, cut_reach + cut_radius, STEEL)
			cuts_left -= 1
			if cuts_left > 0:
				_begin_windup("cut")
			else:
				_finish(recovery)
		"lunge":
			_enter(State.LUNGE)
			BossKit.anim(self, "dash", 12.0, false)
			_from = global_position
			_ghost_t = 0.0
			velocity = _dir * lunge_speed
			attack_hitbox.position = Vector2.ZERO
			shape.radius = 12.0
			attack_hitbox.damage = lunge_damage
			attack_hitbox.heavy = true
			attack_hitbox.activate()
		"wave":
			BossKit.slash(self, global_position, facing, 1.4, 28.0, WATER)
			var s := BossKit.shoot(self, global_position + Vector2(0, -8), facing, wave_speed, wave_damage, WATER, "blade", 7.0, wave_length / wave_speed)
			s.pierce = true
			_finish(recovery)


func _stop_attack() -> void:
	attack_hitbox.deactivate()
	_blast_left = 0.0


# --- iaido: a long still stance, then one instant wide cut ---

func _act_iaido() -> void:
	match _stage:
		0:
			body.modulate = Color(1.0, 1.0, 1.0, 1.0).lerp(Color(1.4, 1.4, 1.6), clampf(_sub / iaido_windup, 0.0, 1.0))
			if _sub >= iaido_windup:
				BossKit.anim(self, "slam", 12.0, false)
				BossKit.strike_cone(self, global_position, facing, iaido_arc, iaido_reach, iaido_damage, true, STEEL)
				BossKit.punch(self, 1.2, 0.85, 0.25)
				BossKit.shake(self, 2.5, 0.25)
				BossKit.sparks(self, global_position + _dir * 40.0, STEEL, 12, 90.0, 0.35)
				_goto(1)
		1:
			if _sub >= 0.2:
				_finish(recovery_heavy)


# --- triple step: three steps in, each ending in a cut where the marker showed ---

func _step_mark() -> void:
	_aim_now(BossKit.player_point(self) - global_position)
	var dest := global_position + _dir * step_length
	_tg.append(BossKit.telegraph_cone(self, dest, facing, 1.4, 44.0, step_windup, STEEL))
	BossKit.anim(self, "cast", 10.0, false)
	_goto(0)


func _act_step(_to_t: Vector2) -> void:
	match _stage:
		0:
			if _sub >= step_windup:
				_from = global_position
				velocity = _dir * 300.0
				BossKit.ghost(self, STEEL, 0.25)
				BossKit.anim(self, "dash", 12.0, false)
				_goto(1)
		1:
			velocity = _dir * 300.0
			if global_position.distance_to(_from) >= step_length or _sub > 0.3:
				velocity = Vector2.ZERO
				BossKit.anim(self, "slam", 12.0, false)
				BossKit.strike_cone(self, global_position, facing, 1.4, 44.0, step_damage, false, STEEL)
				_count -= 1
				if _count > 0:
					_step_mark()
				else:
					_finish(recovery + 0.5)


# --- parry: the counter ---

func _do_counter(to_t: Vector2) -> void:
	_counter = false
	facing = to_t.angle()
	aim.rotation = facing
	BossKit.flash_fx(self, global_position + Vector2(0, -12), 26.0, 0.3, Color(1.0, 1.0, 0.8))
	if to_t.length() <= counter_reach:
		BossKit.strike_cone(self, global_position, facing, 2.4, counter_reach, counter_damage, true, Color(1.0, 1.0, 0.8))
	else:
		BossKit.slash(self, global_position, facing, 1.6, 30.0, Color(1.0, 1.0, 0.8))
		BossKit.shoot(self, global_position + Vector2(0, -8), facing, 220.0, counter_damage, Color(1.0, 1.0, 0.8), "blade", 7.0, 1.2, 0.0, true)
	BossKit.anim(self, "slam", 12.0, false)
	BossKit.punch(self, 1.2, 0.85, 0.25)
	BossKit.shake(self, 2.5, 0.25)
	_finish(recovery_heavy)


# --- river lunges (phase 2): three marked dashes that leave pools ---

func _river_mark() -> void:
	_aim_now(BossKit.player_point(self) - global_position)
	_tg.append(BossKit.telegraph_line(self, global_position, global_position + _dir * river_length, 20.0, river_windup, WATER))
	BossKit.anim(self, "cast", 10.0, false)
	_goto(0)


func _act_river(_to_t: Vector2) -> void:
	match _stage:
		0:
			if _sub >= river_windup:
				_from = global_position
				_hit_done = false
				velocity = _dir * river_speed
				BossKit.anim(self, "dash", 12.0, false)
				_goto(1)
		1:
			velocity = _dir * river_speed
			_ghost_t -= _dt
			if _ghost_t <= 0.0:
				_ghost_t = 0.05
				BossKit.ghost(self, WATER, 0.25)
			if not _hit_done and BossKit.in_circle(BossKit.player_point(self), global_position, 12.0):
				_hit_done = true
				BossKit.hurt_player(self, river_damage, false)
			if global_position.distance_to(_from) >= river_length or _sub > 0.6 or (_sub > 0.05 and is_on_wall()):
				velocity = Vector2.ZERO
				BossKit.zone(self, global_position, 16.0, pool_damage, 3.0, WATER, 0.4)
				BossKit.ring_fx(self, global_position, 24.0, 0.3, WATER)
				_count -= 1
				if _count > 0:
					_river_mark()
				else:
					_finish(recovery_heavy)


# --- flood (phase 2): three circles around where you stood, each leaves a pool ---

func _flood_mark() -> void:
	_spots.clear()
	var feet := target.global_position
	var base := randf() * TAU
	_spots.append(feet)
	_spots.append(feet + Vector2.from_angle(base) * 56.0)
	_spots.append(feet + Vector2.from_angle(base + TAU / 2.0) * 56.0)
	for s in _spots:
		_tg.append(BossKit.telegraph_circle(self, s, flood_radius, flood_windup, WATER))
	BossKit.anim(self, "cast")
	_goto(0)


func _act_flood() -> void:
	match _stage:
		0:
			if _sub >= flood_windup:
				BossKit.anim(self, "slam", 12.0, false)
				var hit := false
				for s in _spots:
					BossKit.sparks(self, s, WATER, 10, 70.0, 0.35)
					BossKit.ring_fx(self, s, flood_radius, 0.3, WATER)
					BossKit.zone(self, s, flood_radius, pool_damage, 3.5, WATER, 0.5)
					if BossKit.in_circle(BossKit.player_point(self), s, flood_radius):
						hit = true
				if hit:
					BossKit.hurt_player(self, flood_damage, true)
				BossKit.shake(self, 2.0, 0.25)
				_goto(1)
		1:
			if _sub >= 0.3:
				_finish(recovery_heavy)


# --- Tsunami (limit break): a huge cone with a safe wedge behind him, then a ring wave ---

func _act_tsunami() -> void:
	match _stage:
		0:
			body.modulate = Color(1.0, 1.0, 1.0, 1.0).lerp(Color(1.2, 1.4, 1.7), clampf(_sub / tsunami_windup, 0.0, 1.0))
			if _sub >= tsunami_windup:
				BossKit.anim(self, "slam", 12.0, false)
				BossKit.strike_cone(self, global_position, facing, tsunami_arc, tsunami_reach, tsunami_damage, true, WATER)
				BossKit.wave(self, global_position, 124.0, 150.0, tsunami_wave_damage, WATER, false)
				BossKit.punch(self, 1.25, 0.8, 0.3)
				BossKit.shake(self, 3.0, 0.4)
				_goto(1)
		1:
			if _sub >= 0.5:
				_finish(recovery_heavy + 0.5)


# --- guard ---

func _on_hurt(hitbox: Hitbox) -> void:
	if dead:
		return
	var path := (hitbox.get_script() as Script).resource_path if hitbox.get_script() != null else ""
	var from := hitbox.global_position
	if hitbox.source is Node2D:
		from = (hitbox.source as Node2D).global_position
	var front := absf(angle_difference(facing, (from - global_position).angle())) < FRONT_HALF
	var parry := state == State.PARRY and not _counter
	var mult := 1.0
	if parry:
		mult = 0.0   # the glow turns every blow aside and answers it
	elif open_left > 0.0:
		mult = open_mult
	elif front and not path.begins_with("res://spells/"):
		mult = guard_mult
	super(hitbox)
	if mult < 1.0 and not _floored:
		health.heal(roundi(hitbox.damage * (1.0 - mult)))
	elif mult > 1.0:
		health.take_damage(roundi(hitbox.damage * (mult - 1.0)), hitbox.source, true)
	if parry:
		_counter = true
		return
	if path.ends_with("dash_strike.gd") and open_left <= 0.0 and not dead:
		_stop_attack()
		open_left = open_time
		_enter(State.STAGGER)


func _on_health(hp: int, max_hp: int) -> void:
	engaged = true   # first hit
	if phase == 1 and hp * 100 > max_hp * yield_at and hp * 2 <= max_hp:
		phase = 2
		_deck.clear()
		_ult_cd = maxf(_ult_cd, 5.0)
		_stop_attack()
		_enter(State.PHASE)
		BossKit.roar(self, WATER, 90.0)
	if hp * 100 <= max_hp * yield_at:
		_check_yield.call_deferred()   # after _on_hurt's guard refund


func _check_yield() -> void:
	if not dead and health.hp * 100 <= health.max_hp * yield_at:
		_yield()


func _on_flinch() -> void:
	pass   # bosses do not flinch


## A hit that would kill him leaves 1 hp: he yields instead (the deferred check from _on_health follows).
## ponytail: judged on the raw hit, so a guarded blow bigger than his hp yields him; no hit comes near 15% of 2800.
func _on_died() -> void:
	health.hp = 1
	_floored = true


## EnemyBase death minus the free and enemy_killed: he stops, sheathes and stays, inert.
func _yield() -> void:
	_stop_attack()
	_enter(State.RECOVER)
	dead = true
	engaged = false
	remove_from_group("enemy")
	remove_from_group("boss")
	health.invincible_time = INF
	hurtbox.set_deferred("monitorable", false)
	aim.visible = false   # ponytail: the blade vanishing is the sheathe, placeholder
	var game := get_node("/root/Game")
	game.add_ilmu(ilmu)
	if unique_id != "":
		game.killed.append(unique_id)
		game.save_game()
	_float_label()
	var events := get_node("/root/Events")
	get_tree().create_timer(0.3).timeout.connect(func() -> void: events.boss_defeated.emit("hariang_banga"))
