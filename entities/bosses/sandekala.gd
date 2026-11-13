class_name Sandekala extends EnemyBase
## Optional miniboss (bestiary.md): the dusk terror that lives in darkness. The room darkens while engaged. While any
## oncor is unlit he fades out every few seconds and reappears behind the player with a grabbing wind-up (ground
## marker, then a hit). With all oncor lit he cannot fade. A lit oncor is also a haven: no dark pillars rise near it,
## and its light protects against the Eclipse.
## Moves (shuffled deck, never the same heavy twice in a row): dusk claws, grab, lantern void (homing skulls),
## umbral pillars (lingering dark zones), dusk pulse. At 50% HP nightfall: darkness grows faster, he moves faster and
## adds the shadow flurry (teleporting rakes) and the Eclipse (limit break, stand in the gold light).
## ponytail: no hold effect on the grab (damage only), no arena-edge pathing.

enum State { IDLE, CHASE, FADING, GONE, WINDUP, GRAB, RECOVER, DEAD, ACT }

const GRAB_R := 24.0
const OVERLAY_SIZE := Vector2(368, 192)   # the ts_leuwi Sandekala room, 23x12 tiles (zones/tatar_sunda.md)
const DUSK := Color(0.65, 0.35, 1.0)
const LIGHT := Color(1.0, 0.9, 0.5)
const HEAVY := ["pillars", "pulse", "flurry", "eclipse"]

@export var cond := ""                # Game.check condition; empty = always on (zone: `flag:mq1_h3`, after K1)
@export var engage_dist := 140.0      # TUNE
@export var move_speed := 36.0        # TUNE
@export var darken_time := 20.0       # TUNE: seconds to full darkness
@export var max_dark := 0.65          # TUNE: overlay alpha at full darkness, no oncor lit
@export var fade_every := 6.0         # TUNE: seconds in shadow between fades
@export var fade_time := 0.4          # TUNE
@export var gone_time := 1.0          # TUNE
@export var windup := 0.6             # bestiary.md
@export var grab_time := 0.15         # TUNE
@export var recover_time := 0.9       # TUNE
@export var melee_range := 26.0       # TUNE: lit-room grab starts from here
@export var attack_gap := 2.5         # TUNE
@export var grab_damage := 14         # TUNE: the grab (also the fade ambush)
@export var heavy_recovery := 2.2     # TUNE: punish window after a heavy move
@export var claw_damage := 10         # TUNE: three rakes, the last one +4
@export var claw_len := 44.0          # TUNE
@export var orb_damage := 9           # TUNE: one skull
@export var pillar_damage := 16       # TUNE: the eruption
@export var pillar_radius := 20.0     # TUNE
@export var zone_damage := 5          # TUNE: per tick in a lingering zone
@export var pulse_damage := 16        # TUNE
@export var pulse_radius := 34.0      # TUNE
@export var flurry_damage := 12       # TUNE: per rake
@export var eclipse_damage := 24      # TUNE: limit break, ~1.5x heavy
@export var eclipse_windup := 1.8     # TUNE
@export var eclipse_recovery := 2.6   # TUNE
@export var torch_safe := 44.0        # TUNE: radius around a lit oncor where pillars never rise

var boss_name_key := "BOSS_SANDEKALA"
var active := true                    # EliteGuard flips it
var engaged := false
var state := State.IDLE
var state_time := 0.0
var fade_timer := 0.0
var gap := 0.0
var dark := 0.0                       # 0..1, how far the darkness has crept
var phase := 1                        # 2 = nightfall
var moves_used: Dictionary = {}
var overlay: Polygon2D
var _move := ""
var _last := ""
var _stage := 0
var _mt := 0.0
var _ang := 0.0
var _wind := 0.5
var _claw_i := 0
var _flurry_i := 0
var _ambush := false
var _dark_rate := 1.0
var _recover_t := 0.9
var _spots: Array[Vector2] = []
var _deck: Array[String] = []
var _tele: Array[Node] = []
var _owned: Array[Node] = []

@onready var marker: Polygon2D = $Marker


func _ready() -> void:
	super()
	if is_queued_for_deletion():
		return
	add_to_group("boss")
	if cond != "":   # hidden and inert until Game.check(cond) holds, so he can't be fought before the Hunt (elite_guard.gd)
		var g := EliteGuard.new()
		g.cond = cond
		add_child(g)
	health.changed.connect(_on_health)
	marker.polygon = _circle(GRAB_R)
	var ov := Polygon2D.new()
	ov.polygon = PackedVector2Array([-OVERLAY_SIZE / 2.0, Vector2(OVERLAY_SIZE.x, -OVERLAY_SIZE.y) / 2.0,
			OVERLAY_SIZE / 2.0, Vector2(-OVERLAY_SIZE.x, OVERLAY_SIZE.y) / 2.0])
	ov.color = Color(0, 0, 0.05, 0)
	ov.z_index = 50
	ov.global_position = home
	overlay = ov
	get_parent().add_child.call_deferred(ov)
	ov.global_position = home
	tree_exiting.connect(func() -> void: if is_instance_valid(ov): ov.queue_free())


func lit_count() -> int:
	var n := 0
	for o: Oncor in get_tree().get_nodes_in_group("oncor"):
		n += int(o.lit)
	return n


func in_shadow() -> bool:
	for o: Oncor in get_tree().get_nodes_in_group("oncor"):
		if not o.lit:
			return true
	return false


## Inside the light of a lit oncor (pillars skip it, the Eclipse cannot hurt there).
func _in_light(p: Vector2) -> bool:
	for o: Oncor in get_tree().get_nodes_in_group("oncor"):
		if o.lit and o.global_position.distance_to(p) <= torch_safe:
			return true
	return false


func _tick(delta: float) -> void:
	state_time += delta
	gap -= delta
	if engaged and not dead:
		dark = minf(1.0, dark + delta / darken_time * _dark_rate)
		if state == State.CHASE or state == State.ACT or state == State.RECOVER:
			fade_timer += delta
	if engaged and not dead and in_shadow():   # the reminder: the dark oncor are the answer (combat.md 5.3 v7)
		BossKit.hint(self, "BOSS_HINT_SANDEKALA")
		for o: Oncor in get_tree().get_nodes_in_group("oncor"):
			if not o.lit:
				BossKit.mark(self, o, "", 1.0, 10.0)
	var total := maxi(1, get_tree().get_node_count_in_group("oncor"))
	overlay.color.a = max_dark * dark * (1.0 - float(lit_count()) / total)
	var to_target := Vector2.INF
	if target != null:
		to_target = target.global_position - global_position
	match state:
		State.IDLE:
			if engaged or (to_target.length() <= engage_dist and BossKit.may_engage(self)):   # the arena gate sets engaged
				engaged = true
				gap = attack_gap   # a breath before the first move
				_enter(State.CHASE)
		State.CHASE:
			engaged = true
			var d := to_target.length()
			var spd := move_speed * (1.25 if phase >= 2 else 1.0)
			velocity = to_target / maxf(d, 0.01) * spd * slow() if d > melee_range * 0.6 else Vector2.ZERO
			if in_shadow() and fade_timer >= fade_every:
				_enter(State.FADING)
			elif gap <= 0.0 and target != null:
				var m: String = _pick(d)
				if m != "":
					_begin_move(m)
		State.ACT:
			_run_move(delta)
		State.FADING:
			modulate.a = 1.0 - state_time / fade_time
			if state_time >= fade_time:
				_enter(State.GONE)
		State.GONE:
			if state_time >= gone_time:
				global_position = _behind_player()
				_enter(State.WINDUP)
		State.WINDUP:
			if state_time >= windup:
				_enter(State.GRAB)
		State.GRAB:
			if state_time >= grab_time:
				_recover_t = recover_time
				_enter(State.RECOVER)
		State.RECOVER:
			if state_time >= _recover_t:
				gap = attack_gap
				if _ambush:
					fade_timer = 0.0
					_ambush = false
				_enter(State.CHASE)
	move_and_slide()


func _enter(s: State) -> void:
	attack_hitbox.deactivate()
	_clear_attack()
	marker.visible = false
	state = s
	state_time = 0.0
	velocity = Vector2.ZERO
	match s:
		State.FADING:
			_ambush = true
			moves_used["fade"] = int(moves_used.get("fade", 0)) + 1
			health.set_invincible(1000.0)
			hurtbox.set_deferred("monitorable", false)
		State.GONE:
			modulate.a = 0.0
		State.WINDUP:
			modulate.a = 1.0
			health.invincible_time = 0.0
			hurtbox.set_deferred("monitorable", true)
			marker.visible = true
		State.GRAB:
			attack_hitbox.damage = grab_damage
			attack_hitbox.heavy = false
			attack_hitbox.activate()
		State.ACT:
			modulate.a = 1.0
		State.CHASE, State.RECOVER:
			BossKit.anim_stop(self)


# --- the deck ------------------------------------------------------------------------------------------------

func _pool() -> Array[String]:
	var out: Array[String] = ["claws", "grab", "lantern", "pillars", "pulse"]
	if phase >= 2:
		out.append("flurry")
		out.append("eclipse")
	return out


func _fits(m: String, d: float) -> bool:
	match m:
		"claws":
			return d <= claw_len
		"grab":
			return d <= melee_range
		"lantern":
			return d >= 50.0 and d <= 240.0
		"pillars":
			return d <= 240.0
		"pulse":
			return d <= 100.0
		"flurry":
			return d <= 200.0
		"eclipse":
			return d <= 240.0
	return false


## The next move that suits this distance, or "" to keep chasing. Refills and reshuffles when the deck runs dry.
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
	_last = m
	moves_used[m] = int(moves_used.get(m, 0)) + 1
	_prune_owned()
	if m == "grab":
		_enter(State.WINDUP)   # the lit-room grab: ground marker, then the hit
		return
	_enter(State.ACT)
	_move = m
	_stage = 0
	_mt = 0.0
	_ang = 0.0
	if target != null:
		_ang = (target.global_position - global_position).angle()
	match m:
		"claws":
			_claw_i = 0
			_aim_claw(0.6)
		"lantern":
			BossKit.anim(self, "cast", 8.0, true)
			_track(BossKit.telegraph_circle(self, global_position, 18.0, 0.7, DUSK))
		"pillars":
			_begin_pillars()
		"pulse":
			BossKit.anim(self, "slam", 10.0, true)
			_track(BossKit.telegraph_circle(self, global_position, pulse_radius, 0.9, DUSK))
		"flurry":
			BossKit.anim(self, "cast", 8.0, true)
			BossKit.ghost(self, DUSK, 0.5)
			modulate.a = 0.3
		"eclipse":
			_begin_eclipse()


func _run_move(delta: float) -> void:
	_mt += delta
	if target == null:
		_end_move(recover_time)
		return
	match _move:
		"claws":
			if _mt >= _wind:
				var last := _claw_i == 2
				BossKit.strike_cone(self, global_position, _ang, 1.5, claw_len, claw_damage + (4 if last else 0), last, DUSK)
				BossKit.shake(self, 1.0, 0.1)
				_claw_i += 1
				if _claw_i < 3:
					_aim_claw(0.5)
				else:
					_end_move(recover_time + 0.8)
		"lantern":
			if _mt >= 0.7:
				var n := 3 if phase == 1 else 5
				var base := (target.global_position - global_position).angle()
				for i in n:
					var a := base + (float(i) - (n - 1) * 0.5) * 0.5
					_owned.append(BossKit.shoot(self, global_position + Vector2(0, -8), a, 55.0, orb_damage, DUSK, "skull", 6.0, 4.0, 1.3))
				BossKit.flash_fx(self, global_position + Vector2(0, -8), 16.0, 0.3, DUSK)
				_end_move(recover_time + 0.7)
		"pillars":
			if _mt >= 0.9:
				for p in _spots:
					BossKit.strike_circle(self, p, pillar_radius, pillar_damage, true, DUSK)
					_owned.append(BossKit.zone(self, p, pillar_radius, zone_damage, 5.0, DUSK, 0.2))
				BossKit.shake(self, 2.0, 0.2)
				_end_move(heavy_recovery)
		"pulse":
			if _mt >= 0.9:
				BossKit.strike_circle(self, global_position, pulse_radius, pulse_damage, true, DUSK)
				_owned.append(BossKit.wave(self, global_position, 110.0, 100.0, 12, DUSK, true))
				BossKit.shake(self, 2.0, 0.2)
				_end_move(heavy_recovery)
		"flurry":
			_run_flurry()
		"eclipse":
			_run_eclipse()
		_:
			_end_move(recover_time)


func _end_move(rec: float) -> void:
	_move = ""
	modulate.a = 1.0
	_recover_t = rec
	_enter(State.RECOVER)


func _track(t: BossKit.Telegraph) -> void:
	t.follow = null
	_tele.append(t)


func _clear_attack() -> void:
	for n in _tele:
		if is_instance_valid(n):
			n.queue_free()
	_tele.clear()


func _prune_owned() -> void:
	var keep: Array[Node] = []
	for n in _owned:
		if is_instance_valid(n):
			keep.append(n)
	_owned = keep


func _aim_claw(wind: float) -> void:
	if target != null:
		_ang = (target.global_position - global_position).angle()
	_wind = wind
	_mt = 0.0
	BossKit.anim(self, "slam", 12.0, false)
	_track(BossKit.telegraph_cone(self, global_position, _ang, 1.5, claw_len, wind, DUSK))


## Dark pillars rise around the player (one right on him). None inside the light of a lit oncor.
func _begin_pillars() -> void:
	_spots.clear()
	BossKit.anim(self, "cast", 8.0, true)
	var base := global_position
	if target != null:
		base = target.global_position
	var n := 4 if phase == 1 else 6
	for i in n:
		var p := base
		if i > 0:
			p = base + Vector2.from_angle(_ang + TAU * i / n) * 46.0
		p = _clamp_room(p)
		if _in_light(p):
			continue
		_spots.append(p)
		_track(BossKit.telegraph_circle(self, p, pillar_radius, 0.9, DUSK))


## Shadow flurry: vanish, then three telegraphed teleport rakes around the player. He stays hittable.
func _run_flurry() -> void:
	match _stage:
		0:
			if _mt >= 0.6:
				_stage = 1
				_flurry_i = 0
				_flurry_jump()
		1:
			if _mt >= 0.5:
				BossKit.strike_cone(self, global_position, _ang, 1.6, 44.0, flurry_damage, false, DUSK)
				BossKit.shake(self, 1.0, 0.1)
				_flurry_i += 1
				if _flurry_i < 3:
					_flurry_jump()
				else:
					_end_move(heavy_recovery)


func _flurry_jump() -> void:
	BossKit.ghost(self, DUSK, 0.4)
	BossKit.flash_fx(self, global_position + Vector2(0, -10), 14.0, 0.25, DUSK)
	var at := _clamp_room(target.global_position + Vector2.from_angle(_ang + TAU * _flurry_i / 3.0 + PI) * 30.0)
	global_position = at
	_ang = (target.global_position - global_position).angle()
	modulate.a = 1.0
	_mt = 0.0
	BossKit.flash_fx(self, global_position + Vector2(0, -10), 14.0, 0.25, DUSK)
	BossKit.anim(self, "slam", 12.0, false)
	_clear_attack()
	_track(BossKit.telegraph_cone(self, global_position, _ang, 1.6, 44.0, 0.5, DUSK))


## Eclipse (limit break): the whole room goes dark. Stand in a gold pool of light (or by a lit oncor) to be spared.
func _begin_eclipse() -> void:
	_spots.clear()
	BossKit.roar(self, DUSK, 90.0)
	var side := Vector2.from_angle(_ang + PI * 0.5) * 54.0
	var c := home
	if target != null:
		c = target.global_position
	_spots.append(_clamp_room(c + side))
	_spots.append(_clamp_room(c - side))
	_track(BossKit.telegraph_circle(self, home, 200.0, eclipse_windup, Color(0.55, 0.15, 0.7)))
	for p in _spots:
		_track(BossKit.telegraph_circle(self, p, 26.0, eclipse_windup, LIGHT))


func _run_eclipse() -> void:
	if _mt < eclipse_windup:
		return
	var pt := target.global_position
	var safe := _in_light(pt)
	for p in _spots:
		safe = safe or pt.distance_to(p) <= 30.0
	BossKit.flash_fx(self, home, 150.0, 0.6, DUSK)
	BossKit.ring_fx(self, home, 200.0, 0.6, DUSK)
	BossKit.shake(self, 3.0, 0.4)
	if not safe and pt.distance_to(home) <= 200.0:
		BossKit.hurt_player(self, eclipse_damage, true)
	dark = minf(1.0, dark + 0.25)
	_end_move(eclipse_recovery)


func _clamp_room(p: Vector2) -> Vector2:
	var half := OVERLAY_SIZE / 2.0 - Vector2(16, 16)
	return Vector2(clampf(p.x, home.x - half.x, home.x + half.x), clampf(p.y, home.y - half.y, home.y + half.y))


## ASSUMED: behind = opposite the player's aim, 28 px out, kept inside the room.
func _behind_player() -> Vector2:
	var dir: Vector2 = target.get("aim_dir") if target.get("aim_dir") != null else Vector2.RIGHT
	var p := target.global_position - dir.normalized() * 28.0
	return _clamp_room(p)


## Nightfall at 50% HP: the dark rushes in, he is faster and gains the flurry and the Eclipse.
func _on_health(hp: int, max_hp: int) -> void:
	if phase == 1 and hp > 0 and hp * 2 <= max_hp:
		phase = 2
		_dark_rate = 2.0
		dark = maxf(dark, 0.7)
		_deck.clear()
		BossKit.roar(self, DUSK, 100.0)


func _on_hurt(hitbox: Hitbox) -> void:
	engaged = true
	super(hitbox)


func _on_died() -> void:
	_move = ""
	_clear_attack()
	for n in _owned:
		if is_instance_valid(n):
			n.queue_free()
	_owned.clear()
	BossKit.anim_stop(self)
	super()
	state = State.DEAD
	marker.visible = false
	modulate.a = 1.0
	get_node("/root/Events").boss_defeated.emit("sandekala")
	if is_instance_valid(overlay):
		create_tween().tween_property(overlay, "color:a", 0.0, 1.0)   # TUNE


static func _circle(r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 16:
		pts.append(Vector2.from_angle(TAU * i / 16.0) * r)
	return pts
