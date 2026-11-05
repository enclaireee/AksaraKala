class_name Player
extends CharacterBody2D
## Player: movement, mouse aim, 3-hit combo, dodge, hurt (combat.md 2, controls.md 3).
## Casting arrives in Phase 2; "cast" is already buffered so the priority order is in place.

enum State { FREE, ATTACK, DODGE, HURT, DEAD }
enum Weapon { MELEE, RANGED }
enum Phase { WINDUP, ACTIVE, RECOVERY }

const PRIORITY := ["dodge", "cast", "attack"]   # combat.md 2.6
const ARROW := preload("res://entities/player/arrow.tscn")
const SNAP_PAD := 6.0                           # ASSUMED: enemy body radius added to reach for soft snap

@export var tuning: CombatTuning = preload("res://data/combat_tuning.tres")
@export var weapon := Weapon.MELEE

@onready var health: Health = $Health
@onready var stamina: Stamina = $Stamina
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hit_flash: HitFlash = $HitFlash
@onready var body: CanvasItem = $Body
@onready var aim: Node2D = $Aim
@onready var melee_hitbox: Hitbox = $Aim/MeleeHitbox
@onready var melee_shape: CollisionPolygon2D = $Aim/MeleeHitbox/Shape
@onready var slash: Polygon2D = $Aim/MeleeHitbox/Slash
@onready var camera: PlayerCamera = $Camera
@onready var vignette: CanvasItem = $Overlay/Vignette
@onready var debug: Label = $Overlay/Debug

var state := State.FREE
var phase := Phase.WINDUP
var state_time := 0.0      # time in the current state or attack phase
var clock := 0.0           # scaled game time; drives the buffer
var buffer := {}           # action -> clock time it was pressed
var combo := 0             # index of the next combo hit (0, 1, 2)
var hit := 0               # index of the hit being performed
var since_recovery := INF  # time since the last attack recovery ended
var aim_dir := Vector2.RIGHT
var move_dir := Vector2.ZERO
var dodge_dir := Vector2.RIGHT
var knock := Vector2.ZERO
var blink_until := 0.0
var frozen := 0.0          # hitstop time left


func _ready() -> void:
	add_to_group("player")
	hurtbox.hurt.connect(_on_hurt)
	health.died.connect(_on_died)
	camera.lean = tuning.camera_lean
	melee_hitbox.hit_landed.connect(func(hb: Hurtbox) -> void: _on_hit_landed(hb, self, melee_hitbox.heavy))
	stamina.empty_attempt.connect(func() -> void:
		debug.modulate = Color.RED
		create_tween().tween_property(debug, "modulate", Color.WHITE, 0.3))


func _unhandled_input(event: InputEvent) -> void:
	for a in PRIORITY:
		if event.is_action_pressed(a):
			buffer[a] = clock
	# ponytail: debug weapon swap until the menu exists (items.md swaps weapons in the menu)
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F1:
		weapon = Weapon.RANGED if weapon == Weapon.MELEE else Weapon.MELEE


func hitstop(seconds: float) -> void:
	frozen = maxf(frozen, seconds)


func _physics_process(delta: float) -> void:
	if frozen > 0.0:
		frozen -= delta
		return
	clock += delta
	state_time += delta
	since_recovery += delta
	for a in buffer.keys():
		if clock - buffer[a] > tuning.buffer_time:
			buffer.erase(a)
	if state != State.ATTACK and since_recovery > tuning.combo_reset:
		combo = 0
	move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# ASSUMED: the busur keeps tracking the mouse through its wind-up; melee commits to its snap
	var ranged_windup := state == State.ATTACK and weapon == Weapon.RANGED and phase == Phase.WINDUP
	if (state != State.ATTACK or ranged_windup) and state != State.DEAD:
		var to_mouse := get_global_mouse_position() - aim.global_position
		if to_mouse.length() > 1.0:
			aim_dir = to_mouse.normalized()
		aim.rotation = aim_dir.angle()

	match state:
		State.FREE: _free()
		State.ATTACK: _attack()
		State.DODGE: _dodge()
		State.HURT: _hurt()
		State.DEAD: velocity = Vector2.ZERO
	body.visible = clock >= blink_until or fmod(clock, 0.1) < 0.05
	move_and_slide()
	# ponytail: debug readout until the HUD (ui.md) exists
	debug.text = "HP %d  ST %d  %s [F1]" % [health.hp, stamina.value, "keris" if weapon == Weapon.MELEE else "busur"]


# --- states ---

func _free() -> void:
	velocity = move_dir * tuning.walk_speed
	_try_buffered(["dodge", "attack"])


func _attack() -> void:
	var ranged := weapon == Weapon.RANGED
	velocity = move_dir * tuning.walk_speed * tuning.ranged_move_factor if ranged else Vector2.ZERO
	match phase:
		Phase.WINDUP:
			if state_time >= _phase_len(Phase.WINDUP):
				if ranged:
					_shoot()
					_set_phase(Phase.RECOVERY)
				else:
					_swing(true)
					_set_phase(Phase.ACTIVE)
		Phase.ACTIVE:
			velocity = aim_dir * tuning.melee_lunge / _phase_len(Phase.ACTIVE)
			if state_time >= _phase_len(Phase.ACTIVE):
				_swing(false)
				_set_phase(Phase.RECOVERY)
		Phase.RECOVERY:
			if _try_buffered(["dodge"]):   # a dodge cancels the recovery (combat.md 2.4)
				return
			if state_time >= _phase_len(Phase.RECOVERY):
				since_recovery = 0.0
				_enter(State.FREE)
				if Input.is_action_pressed("attack"):   # holding keeps the combo going
					buffer["attack"] = clock
				_free()


func _dodge() -> void:
	if state_time < tuning.dodge_duration:
		velocity = dodge_dir * tuning.dodge_distance / tuning.dodge_duration
	else:
		velocity = move_dir * tuning.walk_speed   # dodge recovery: free to move, actions wait
		if state_time >= tuning.dodge_duration + tuning.dodge_recovery:
			_enter(State.FREE)


func _hurt() -> void:
	velocity = knock
	if state_time >= tuning.hurt_dodge_after and _try_buffered(["dodge"]):
		return
	if state_time >= tuning.hurt_stagger:
		_enter(State.FREE)


# --- actions ---

func _try_buffered(allowed: Array) -> bool:
	for a in PRIORITY:
		if a in allowed and buffer.has(a):
			buffer.erase(a)   # dropped even on failure, so nothing fires late by surprise
			return _start_dodge() if a == "dodge" else _start_attack()
	return false


func _start_dodge() -> bool:
	if not stamina.spend(tuning.dodge_cost):
		return false
	dodge_dir = move_dir.normalized() if move_dir != Vector2.ZERO else aim_dir
	health.set_invincible(tuning.dodge_iframes)
	_swing(false)
	combo = 0
	_enter(State.DODGE)
	return true


func _start_attack() -> bool:
	var cost := tuning.melee_cost if weapon == Weapon.MELEE else tuning.ranged_cost
	if not stamina.spend(cost):
		return false
	hit = combo
	combo = (combo + 1) % 3
	aim_dir = _snap_aim(aim_dir)
	aim.rotation = aim_dir.angle()
	_enter(State.ATTACK)
	_set_phase(Phase.WINDUP)
	return true


func _swing(on: bool) -> void:
	slash.visible = on
	if not on:
		melee_hitbox.deactivate()
		return
	var finisher := hit == 2
	var reach := tuning.melee_reach * (tuning.melee_finisher_reach_mult if finisher else 1.0)
	var poly := _arc(tuning.melee_arc, reach)
	melee_shape.polygon = poly
	slash.polygon = poly
	melee_hitbox.damage = _damage(tuning.melee_damage)
	melee_hitbox.heavy = finisher
	melee_hitbox.knockback = tuning.enemy_knockback_finisher if finisher else tuning.enemy_knockback_light
	melee_hitbox.activate()


func _shoot() -> void:
	var finisher := hit == 2
	var arrow: Arrow = ARROW.instantiate()
	arrow.source = self
	arrow.damage = _damage(tuning.ranged_damage)
	arrow.heavy = finisher
	arrow.pierce = finisher
	arrow.knockback = tuning.enemy_knockback_finisher if finisher else tuning.enemy_knockback_light
	arrow.direction = aim_dir
	arrow.speed = tuning.arrow_speed
	arrow.max_range = tuning.arrow_range
	arrow.position = aim.global_position + aim_dir * 8.0
	# ASSUMED: a ranged hit freezes only the target; the archer is not touching it
	arrow.hit_landed.connect(func(hb: Hurtbox) -> void: _on_hit_landed(hb, null, finisher))
	get_parent().add_child(arrow)


func _snap_aim(dir: Vector2) -> Vector2:
	if weapon != Weapon.MELEE:
		return dir   # ranged shots go exactly where the mouse points
	var reach := tuning.melee_reach * (tuning.melee_finisher_reach_mult if hit == 2 else 1.0) + SNAP_PAD
	var best := Vector2.ZERO
	for e: Node2D in get_tree().get_nodes_in_group("enemy"):
		var d := e.global_position - aim.global_position
		if d.length() <= reach and absf(rad_to_deg(dir.angle_to(d))) <= tuning.soft_snap_angle:
			if best == Vector2.ZERO or d.length() < best.length():
				best = d
	return best.normalized() if best != Vector2.ZERO else dir


# --- hit feedback (combat.md 3.2) ---

func _on_hit_landed(hb: Hurtbox, attacker: Node, heavy: bool) -> void:
	var kill := hb.health.is_dead()
	var stop := tuning.hitstop_kill if kill else tuning.hitstop_heavy if heavy else tuning.hitstop_light
	for n: Node in [hb.owner, attacker]:
		if n != null and n.has_method("hitstop"):
			n.hitstop(stop)
	var s := tuning.shake_kill if kill else tuning.shake_heavy if heavy else Vector2.ZERO
	if s.x > 0.0:
		camera.shake(s.x, s.y)


# --- getting hit ---

func _on_hurt(hitbox: Hitbox) -> void:
	if health.is_dead():
		return
	health.set_invincible(tuning.hurt_iframes)
	blink_until = clock + tuning.hurt_iframes
	hit_flash.flash(tuning.flash_time)
	_swing(false)
	combo = 0
	var from := hitbox.global_position
	if hitbox.source is Node2D:
		from = (hitbox.source as Node2D).global_position
	var kb := tuning.player_knockback_heavy if hitbox.heavy else tuning.player_knockback_light
	knock = (global_position - from).normalized() * kb / tuning.hurt_stagger
	_enter(State.HURT)
	hitstop(tuning.hitstop_player_hit)
	if hitbox.source != null and hitbox.source.has_method("hitstop"):
		hitbox.source.hitstop(tuning.hitstop_player_hit)
	camera.shake(tuning.shake_player_hit.x, tuning.shake_player_hit.y)
	vignette.modulate.a = 1.0
	create_tween().tween_property(vignette, "modulate:a", 0.0, 0.4)


func _on_died() -> void:
	_swing(false)
	_enter(State.DEAD)
	body.modulate = Color(0.4, 0.4, 0.4)
	# ponytail: reload the room on death; petilasan respawn is Phase 3 (rpg.md)
	get_tree().create_timer(1.5).timeout.connect(get_tree().reload_current_scene)


# --- helpers ---

func _enter(s: State) -> void:
	state = s
	state_time = 0.0


func _set_phase(p: Phase) -> void:
	phase = p
	state_time = 0.0


func _phase_len(p: Phase) -> float:
	var t: float
	if weapon == Weapon.MELEE:
		t = [tuning.melee_windup, tuning.melee_active, tuning.melee_recovery][p]
	else:
		t = [tuning.ranged_windup, 0.0, tuning.ranged_recovery][p]
	return t * (tuning.finisher_mult if hit == 2 else 1.0)


func _damage(base: int) -> int:
	return roundi(base * (tuning.finisher_mult if hit == 2 else 1.0))


static func _arc(arc_deg: float, reach: float) -> PackedVector2Array:
	var pts := PackedVector2Array([Vector2.ZERO])
	for i in 9:
		pts.append(Vector2.RIGHT.rotated(deg_to_rad(-arc_deg / 2.0 + arc_deg * i / 8.0)) * reach)
	return pts
