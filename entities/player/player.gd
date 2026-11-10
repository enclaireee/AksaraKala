class_name Player
extends CharacterBody2D
## Player: movement, mouse aim, 3-hit combo, dodge, hurt (combat.md 2, controls.md 3).
## Casting lives in the CastController child (spells.md 1).

signal blocked(what: String)   # "st", "sk" or "flask": the HUD flashes that bar (ui.md 2)

enum State { FREE, ATTACK, DODGE, HURT, DRINK, DEAD }
enum Phase { WINDUP, ACTIVE, RECOVERY }

const PRIORITY := ["dodge", "cast", "attack"]   # combat.md 2.6
const ARROW := preload("res://entities/player/arrow.tscn")
const SNAP_PAD := 6.0                           # ASSUMED: enemy body radius added to reach for soft snap

@export var tuning: CombatTuning = preload("res://data/combat_tuning.tres")

@onready var health: Health = $Health
@onready var stamina: Stamina = $Stamina
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hit_flash: HitFlash = $HitFlash
@onready var body: CanvasItem = $Body
@onready var sprite: Sprite2D = get_node_or_null("Sprite")
@onready var shadow: Sprite2D = get_node_or_null("Shadow")
@onready var aim: Node2D = $Aim
@onready var melee_hitbox: Hitbox = $Aim/MeleeHitbox
@onready var melee_shape: CollisionPolygon2D = $Aim/MeleeHitbox/Shape
@onready var slash: Polygon2D = $Aim/MeleeHitbox/Slash
@onready var camera: PlayerCamera = $Camera
@onready var vignette: CanvasItem = $Overlay/Vignette
@onready var debug: Label = $Overlay/Debug
@onready var status: Status = $Status
@onready var sakti: SaktiGauge = $Sakti
@onready var cast: CastController = $CastController
@onready var fx = get_node_or_null("AttackFX")   # AttackFX: visual only (combat.md 2.3b)

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
var last_perfect := -INF   # clock time of the last perfect dodge
var debug_status := 0

# Derived from Game by apply_from_game() (rpg.md 2, classes.md)
var game: Node             # the Game autoload (get_node, so tests can compile this script early)
var _ev: Node              # Events: the tutorial listens for my inputs (docs/tutorial.md 4)
var item: ItemData         # equipped weapon; the dagger when none is equipped
var class_id := ""
var dmg_mult := 1.0        # Str for melee, Dex for ranged and staff
var atk_speed := 1.0       # Dex: shortens wind-up and recovery
var move_mult := 1.0
var dodge_cost := 20.0
var _applied := false
var _regen_base := 35.0
var _zone_seen := ""

# Story v5 Major Choice effects (quests.md 4, items.md). TUNE.
const ARIA_REGEN := 0.15            # choice_release_aria: +15% stamina and Sakti regen in gk_ruang_kala
const ARIA_ZONE := "gk_ruang_kala"
const BERKAH_USED := "berkah_pesisir_used"   # flag: the one use per save


func _ready() -> void:
	add_to_group("player")
	game = get_node("/root/Game")
	_ev = get_node("/root/Events")
	_regen_base = stamina.regen
	apply_from_game()
	game.changed.connect(apply_from_game)
	hurtbox.hurt.connect(_on_hurt)
	hurtbox.dodged.connect(_on_dodged)
	health.died.connect(_on_died)
	camera.lean = tuning.camera_lean
	melee_hitbox.hit_landed.connect(func(hb: Hurtbox) -> void: _on_hit_landed(hb, self, melee_hitbox.heavy, melee_hitbox.damage))
	stamina.empty_attempt.connect(blocked.emit.bind("st"))
	cast.blocked.connect(blocked.emit.bind("sk"))
	blocked.connect(func(what: String) -> void: Snd.play("stamina_empty" if what == "st" else "wrong"))
	add_child(Footsteps.new())


func _unhandled_input(event: InputEvent) -> void:
	for a in PRIORITY:
		if event.is_action_pressed(a):
			buffer[a] = clock
	if event.is_action_pressed("heal_jamu"):
		_try_flask()
	# ponytail: debug weapon swap until the menu exists (items.md swaps weapons in the menu)
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F1:
		var ws: Array[String] = []
		for id in game.inventory:
			var it := ItemData.by_id(id)
			if it and it.slot == "weapon":
				ws.append(id)
		if not ws.is_empty():
			game.equip(ws[(ws.find(item.id) + 1) % ws.size()])
	# ponytail: debug status cycle (Burn of a 20 hit, Slow, Curse) until enemies apply them
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F2:
		var types := [Status.Type.BURN, Status.Type.SLOW, Status.Type.CURSE]
		status.apply(types[debug_status], -1.0, 20.0)
		debug_status = (debug_status + 1) % types.size()


func hitstop(seconds: float) -> void:
	frozen = maxf(frozen, seconds)


func _physics_process(delta: float) -> void:
	if frozen > 0.0:
		frozen -= delta
		return
	var zone := _zone_id()
	if zone != _zone_seen:   # zone-gated choice effects (Keteguhan Sunyi) follow the area
		_zone_seen = zone
		apply_from_game()
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
	var ranged_windup := state == State.ATTACK and not item.is_melee() and phase == Phase.WINDUP
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
		State.DRINK: _drink()
		State.DEAD: velocity = Vector2.ZERO
	var vis := clock >= blink_until or fmod(clock, 0.1) < 0.05
	body.visible = vis and sprite == null
	if sprite:
		sprite.visible = vis
	_update_animation()
	move_and_slide()
	# ponytail: debug readout until the HUD (ui.md) exists
	debug.text = "HP %d  ST %d  SK %d  %s [F1]  status [F2]" % [health.hp, stamina.value, sakti.value, tr(item.title)]


# --- states ---

func _free() -> void:
	velocity = move_dir * _walk()
	_try_buffered(["dodge", "attack"])


func _attack() -> void:
	var ranged := not item.is_melee()
	velocity = move_dir * _walk() * tuning.ranged_move_factor if ranged else Vector2.ZERO
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
			velocity = aim_dir * item.lunge / _phase_len(Phase.ACTIVE)
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
		velocity = move_dir * _walk()   # dodge recovery: free to move, actions wait
		if state_time >= tuning.dodge_duration + tuning.dodge_recovery:
			_enter(State.FREE)


func _drink() -> void:
	velocity = move_dir * _walk() * tuning.ranged_move_factor   # 50% speed (controls.md 3)
	if _try_buffered(["dodge"]):   # a dodge cancels the drink, charge kept
		return
	if state_time >= tuning.flask_time:
		var pouches := mini(game.herb_pouches, 4)
		health.heal(roundi((tuning.flask_base_heal + tuning.flask_pouch_heal * pouches) * health.max_hp))
		game.flask_charges -= 1
		Snd.play("flask")
		_enter(State.FREE)
		game.changed.emit()
		_ev.player_drank.emit()


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


func _try_flask() -> void:
	if state != State.FREE:
		return   # ignored in every other state (controls.md 3)
	if game.flask_charges <= 0 or health.hp >= health.max_hp:
		blocked.emit("flask")
		return
	_enter(State.DRINK)   # the charge is spent when the drink ends, so a dodge cancel keeps it


func _start_dodge() -> bool:
	if not stamina.spend(dodge_cost):
		return false
	dodge_dir = move_dir.normalized() if move_dir != Vector2.ZERO else aim_dir
	health.set_invincible(tuning.dodge_iframes)
	status.clear(Status.Type.BURN)   # a dodge roll puts out a burn (combat.md 4)
	_swing(false)
	combo = 0
	_enter(State.DODGE)
	Snd.play("dodge", 0.0, 1.0, 0.05)
	_ev.player_dodged.emit()
	return true


func _start_attack() -> bool:
	if not stamina.spend(item.cost):
		return false
	hit = combo
	combo = (combo + 1) % 3
	aim_dir = _snap_aim(aim_dir)
	aim.rotation = aim_dir.angle()
	_enter(State.ATTACK)
	_set_phase(Phase.WINDUP)
	if item.is_melee():
		Snd.play("swing_%d" % (hit + 1), 0.0, 1.0, 0.05)
	return true


func _swing(on: bool) -> void:
	slash.visible = on
	if not on:
		melee_hitbox.deactivate()
		return
	var finisher := hit == 2
	var reach := item.reach * (tuning.melee_finisher_reach_mult if finisher else 1.0)
	var poly := _arc(item.arc, reach)
	melee_shape.polygon = poly
	slash.polygon = poly
	melee_hitbox.damage = _damage()
	melee_hitbox.heavy = finisher
	melee_hitbox.knockback = tuning.enemy_knockback_finisher if finisher else tuning.enemy_knockback_light
	melee_hitbox.activate()
	if fx: fx.on_swing()


func _shoot() -> void:
	var finisher := hit == 2
	var arrow: Arrow = ARROW.instantiate()
	arrow.source = self
	arrow.damage = _damage()
	if class_id == "archer":
		arrow.far_damage = roundi(arrow.damage * tuning.eagle_mult)   # Eagle Eye
		arrow.far_after = tuning.eagle_range
	if item.archetype == "staff":
		arrow.modulate = Color(0.6, 0.8, 1.0)   # ponytail: a recolored arrow until the bolt has art
	arrow.heavy = finisher
	arrow.pierce = finisher
	arrow.knockback = tuning.enemy_knockback_finisher if finisher else tuning.enemy_knockback_light
	arrow.direction = aim_dir
	arrow.speed = item.projectile_speed
	arrow.max_range = item.projectile_range
	arrow.position = aim.global_position + aim_dir * 8.0
	# ASSUMED: a ranged hit freezes only the target; the archer is not touching it
	arrow.hit_landed.connect(func(hb: Hurtbox) -> void: _on_hit_landed(hb, null, finisher, arrow.damage))
	get_parent().add_child(arrow)
	if fx: fx.on_shoot(arrow)
	Snd.play("shoot", 0.0, 1.0, 0.05)


func _snap_aim(dir: Vector2) -> Vector2:
	if not item.is_melee():
		return dir   # ranged shots go exactly where the mouse points
	var reach := item.reach * (tuning.melee_finisher_reach_mult if hit == 2 else 1.0) + SNAP_PAD
	var best := Vector2.ZERO
	for e: Node2D in get_tree().get_nodes_in_group("enemy"):
		var d := e.global_position - aim.global_position
		if d.length() <= reach and absf(rad_to_deg(dir.angle_to(d))) <= tuning.soft_snap_angle:
			if best == Vector2.ZERO or d.length() < best.length():
				best = d
	return best.normalized() if best != Vector2.ZERO else dir


# --- hit feedback (combat.md 3.2) ---

func _on_hit_landed(hb: Hurtbox, attacker: Node, heavy: bool, dmg: int) -> void:
	sakti.add(item.sakti_per_hit)   # weapon hits (balance.md 4); spells do not refill sakti
	_ev.player_struck.emit(hit)
	if item.self_damage > 0:   # Mpu Gandring's curse: costs HP, never kills
		health.hp = maxi(1, health.hp - item.self_damage)
		health.changed.emit(health.hp, health.max_hp)
	if _is_backstab(hb.owner):   # Light Step. ponytail: the bonus lands as a second hit, poise ignores it
		hb.health.take_damage(roundi(dmg * (tuning.backstab_mult - 1.0)), self, true)
	var kill := hb.health.is_dead()
	Snd.play("hit_kill" if kill else "hit_heavy" if heavy else "hit_light", 0.0, 1.0, 0.05)
	var stop := tuning.hitstop_kill if kill else tuning.hitstop_heavy if heavy else tuning.hitstop_light
	for n: Node in [hb.owner, attacker]:
		if n != null and n.has_method("hitstop"):
			n.hitstop(stop)
	var s := tuning.shake_kill if kill else tuning.shake_heavy if heavy else Vector2.ZERO
	if s.x > 0.0:
		camera.shake(s.x, s.y)
	if fx: fx.on_hit(hb, heavy, kill)


# --- getting hit ---

func _on_dodged(hitbox: Hitbox) -> void:
	# Perfect dodge: hit during the first part of a dodge, at most once a second (combat.md 2.5).
	if state != State.DODGE or state_time >= tuning.perfect_window or clock - last_perfect < tuning.perfect_cooldown:
		return
	last_perfect = clock
	stamina.refund(tuning.dodge_cost)
	sakti.add(tuning.perfect_sakti)
	hit_flash.flash(tuning.perfect_pause * 3.0)
	Snd.play("perfect_dodge")
	hitstop(tuning.perfect_pause)
	_ev.perfect_dodge.emit()
	if is_instance_valid(hitbox.source) and hitbox.source.has_method("hitstop"):   # a shot can outlive its shooter
		hitbox.source.hitstop(tuning.perfect_pause)


func _on_hurt(hitbox: Hitbox) -> void:
	if health.is_dead():
		return
	health.set_invincible(tuning.hurt_iframes)
	Snd.play("player_hurt", 0.0, 1.0, 0.04)
	blink_until = clock + tuning.hurt_iframes
	hit_flash.flash(tuning.flash_time)
	var skin := class_id == "warrior" and not hitbox.heavy   # Iron Skin: no stagger or knockback
	if not skin:
		_swing(false)
		combo = 0
	var from := hitbox.global_position
	if hitbox.source is Node2D:
		from = (hitbox.source as Node2D).global_position
	var kb := tuning.player_knockback_heavy if hitbox.heavy else tuning.player_knockback_light
	knock = (global_position - from).normalized() * kb / tuning.hurt_stagger
	if not skin:
		_enter(State.HURT)
		hitstop(tuning.hitstop_player_hit)
	if is_instance_valid(hitbox.source) and hitbox.source.has_method("hitstop"):   # a shot can outlive its shooter
		hitbox.source.hitstop(tuning.hitstop_player_hit)
	camera.shake(tuning.shake_player_hit.x, tuning.shake_player_hit.y)
	vignette.modulate.a = 1.0
	create_tween().tween_property(vignette, "modulate:a", 0.0, 0.4)
	_ev.player_hurt.emit(health.hp / maxf(1.0, health.max_hp))


func _zone_id() -> String:
	var z := get_node_or_null("/root/Zones")
	return str(z.get("current_zone")) if z else ""


## Berkah Pesisir (choice_offer_song): in Act VI the first lethal hit leaves 1 HP instead. One use per save.
func _try_berkah_pesisir() -> bool:
	if not game.has_flag("choice_offer_song") or game.has_flag(BERKAH_USED) or not _zone_id().begins_with("gk_"):
		return false
	game.set_flag(BERKAH_USED)
	health.hp = 1
	health.shield = 0
	health.set_invincible(tuning.hurt_iframes)
	health.changed.emit(health.hp, health.max_hp)
	return true


func _on_died() -> void:
	if _try_berkah_pesisir():
		return
	_swing(false)
	_enter(State.DEAD)
	body.modulate = Color(0.4, 0.4, 0.4)
	if sprite:
		sprite.modulate = body.modulate
	get_node("/root/Events").player_died.emit()   # the UI and zones handle the rest


# --- helpers ---

func _enter(s: State) -> void:
	state = s
	state_time = 0.0


func _walk() -> float:
	return tuning.walk_speed * move_mult * status.speed_mult()   # Slow; dodge distance is unchanged (combat.md 4)


func _set_phase(p: Phase) -> void:
	phase = p
	state_time = 0.0


func _phase_len(p: Phase) -> float:
	var t: float = [item.windup, item.active if item.is_melee() else 0.0, item.recovery][p]
	if p != Phase.ACTIVE:
		t /= atk_speed
	return t * (tuning.finisher_mult if hit == 2 else 1.0)


func _damage() -> int:
	return roundi(item.damage * dmg_mult * (tuning.finisher_mult if hit == 2 else 1.0))


## Rogue Light Step: the hit lands within 60 degrees of the enemy's back. Never on bosses.
func _is_backstab(e: Node) -> bool:
	if class_id != "rogue" or e == null or e.is_in_group("boss") or not e.get("aim") is Node2D:
		return false
	var facing := Vector2.RIGHT.rotated((e.get("aim") as Node2D).global_rotation)
	var to_me := (global_position - (e as Node2D).global_position).normalized()
	return absf(rad_to_deg((-facing).angle_to(to_me))) <= tuning.backstab_angle


## Recompute everything that depends on Game. The first call fills HP and stamina; later calls keep them (clamped).
func apply_from_game() -> void:
	class_id = game.class_id
	if sprite:
		var tex_path := "res://assets/art/hero_%s.png" % (class_id if class_id != "" else "base")
		if ResourceLoader.exists(tex_path):
			sprite.texture = load(tex_path)
	item = game.equipped_item("weapon")
	if item == null:
		item = ItemData.by_id("dagger")
	var mage := class_id == "mage"
	health.max_hp = tuning.stat_hp_base + tuning.stat_hp_per * game.stat("vit") + int(game.bonus("max_hp"))
	health.hp = health.max_hp if not _applied else mini(health.hp, health.max_hp)
	health.defense = 0
	for slot in ["armor", "accessory"]:
		var g: ItemData = game.equipped_item(slot)
		health.defense += g.defense if g else 0
	stamina.max_stamina = tuning.stat_stamina_base + tuning.stat_stamina_per * game.stat("end")
	stamina.value = stamina.max_stamina if not _applied else minf(stamina.value, stamina.max_stamina)
	_zone_seen = _zone_id()
	health.reduction = game.bonus("defense")   # Sabuk Galuh
	var aria_regen := ARIA_REGEN if game.has_flag("choice_release_aria") and _zone_seen == ARIA_ZONE else 0.0
	stamina.regen = _regen_base * (1.0 + tuning.stat_speed_per * game.stat("end") + game.bonus("stamina_regen") + aria_regen)
	dmg_mult = 1.0 + tuning.stat_damage_per * game.stat("str" if item.is_melee() else "dex")
	atk_speed = 1.0 + tuning.stat_speed_per * game.stat("dex")
	move_mult = 1.0 + game.bonus("move_speed")
	dodge_cost = tuning.rogue_dodge_cost if class_id == "rogue" else tuning.dodge_cost
	sakti.max_value = tuning.keen_mind_max if mage else tuning.sakti_max   # Keen Mind
	sakti.gain_mult = (1.0 + tuning.stat_sakti_per * game.stat("spi") + aria_regen) * (tuning.keen_mind_gain if mage else 1.0)
	sakti.value = minf(sakti.value, sakti.max_value)
	_applied = true
	health.changed.emit(health.hp, health.max_hp)
	stamina.changed.emit(stamina.value, stamina.max_stamina)
	sakti.changed.emit(sakti.value, sakti.max_value)


## Spell damage multiplier from Spirit (rpg.md 2); spells apply it themselves.
func spell_mult() -> float:
	return 1.0 + tuning.stat_damage_per * game.stat("spi")


static func _arc(arc_deg: float, reach: float) -> PackedVector2Array:
	var pts := PackedVector2Array([Vector2.ZERO])
	for i in 9:
		pts.append(Vector2.RIGHT.rotated(deg_to_rad(-arc_deg / 2.0 + arc_deg * i / 8.0)) * reach)
	return pts


func _update_animation() -> void:
	if not sprite:
		return
	var facing_dir := aim_dir if (state == State.ATTACK or move_dir == Vector2.ZERO) else move_dir
	var row := 0
	var col := 0
	var dir_row := 0
	if absf(facing_dir.x) > absf(facing_dir.y) * 0.7:
		dir_row = 1
		sprite.flip_h = facing_dir.x < 0
	elif facing_dir.y < 0:
		dir_row = 2
		sprite.flip_h = false
	else:
		dir_row = 0
		sprite.flip_h = false

	match state:
		State.FREE:
			if move_dir != Vector2.ZERO:
				row = 3 + dir_row
				col = int(fmod(clock * 8.0, 4.0))
			else:
				row = dir_row
				col = int(fmod(clock * 4.0, 4.0))
		State.DRINK:
			row = dir_row
			col = 1
		State.DODGE:
			row = 9
			col = mini(5, int(state_time / 0.075))   # 6 frames over the dodge and its recovery (0.45 s)
			sprite.flip_h = facing_dir.x < -0.05
		State.ATTACK:
			row = [12, 6, 15][dir_row] + clampi(hit, 0, 2)   # down, side, up rows (hero sheet contract)
			var plen := maxf(_phase_len(phase), 0.001)
			var prog := clampf(state_time / plen, 0.0, 0.999)
			if item.is_melee():   # wind-up 0-1, active 2-3, recovery 4-5
				col = int(prog * 2.0) + [0, 2, 4][phase]
			else:                 # no active phase: wind-up 0-2 (raise, draw, hold), recovery 3-5 (release, recoil, settle)
				col = int(prog * 3.0) + (0 if phase == Phase.WINDUP else 3)
		State.HURT:
			row = 10
			col = 0 if state_time < 0.08 else 1
			sprite.flip_h = facing_dir.x < -0.05
		State.DEAD:
			row = 11
			col = mini(3, int(state_time / 0.15))
			sprite.flip_h = facing_dir.x < -0.05

	sprite.frame_coords = Vector2i(col, row)

