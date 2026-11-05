class_name EnemyBase extends CharacterBody2D
## Shared enemy plumbing: hitstop, target, knockback, poise, attack tokens, death (combat.md 3, 5).

@export var tuning: CombatTuning = preload("res://data/combat_tuning.tres")
@export var role := "chaser"        # prefix of this enemy's values in CombatTuning (chaser_*, tank_*, shooter_*)
@export var poise_ratio := 0.0      # 0: flinch on every hit. Tank 0.6 (combat.md 3.1)
@export var ranged := false         # which token pool it draws from (combat.md 5.2)

@onready var body: Polygon2D = $Body
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var health: Health = $Health
@onready var hit_flash: HitFlash = $HitFlash
@onready var aim: Node2D = $Aim
@onready var attack_hitbox: Hitbox = $Aim/Hitbox

# Tokens are group membership: freed nodes leave groups by themselves, so nothing leaks (combat.md 5.2).
# ponytail: no autoload; elites and bosses will skip tokens.
const POOLS := ["token_melee", "token_ranged"]

var frozen := 0.0          # hitstop time left
var home := Vector2.ZERO
var target: Node2D
var knock := Vector2.ZERO
var dead := false
var has_token := false
var token_wait := 0.0
var poise := 0.0
var since_hit := INF
var poise_immune := 0.0


func _ready() -> void:
	add_to_group("enemy")
	home = global_position
	target = get_tree().get_first_node_in_group("player") as Node2D
	hurtbox.hurt.connect(_on_hurt)
	health.died.connect(_on_died)
	poise = _max_poise()


## A tuning value for this role, falling back to the shared enemy_* value.
func t(name: String) -> float:
	var v: Variant = tuning.get(role + "_" + name)
	return v if v != null else tuning.get("enemy_" + name)


func hitstop(seconds: float) -> void:
	frozen = maxf(frozen, seconds)


func _physics_process(delta: float) -> void:
	if frozen > 0.0:
		frozen -= delta
		return
	if dead:
		return
	token_wait -= delta
	poise_immune -= delta
	since_hit += delta
	if since_hit >= tuning.poise_refill:
		poise = _max_poise()
	_tick(delta)


func _tick(_delta: float) -> void:
	pass


func _on_flinch() -> void:
	pass


func _on_stagger(_seconds: float) -> void:
	pass


# --- attack tokens (combat.md 5.2) ---

func request_token() -> bool:
	if has_token:
		return true
	if token_wait > 0.0 or not _on_screen():
		return false
	if get_tree().get_node_count_in_group(POOLS[int(ranged)]) >= (tuning.tokens_ranged if ranged else tuning.tokens_melee):
		token_wait = tuning.token_retry
		return false
	add_to_group(POOLS[int(ranged)])
	has_token = true
	return true


func release_token() -> void:
	if has_token:
		has_token = false
		remove_from_group(POOLS[int(ranged)])
		token_wait = tuning.token_retry


static func attackers(tree: SceneTree) -> int:
	return tree.get_node_count_in_group(POOLS[0]) + tree.get_node_count_in_group(POOLS[1])


func _on_screen() -> bool:
	# Enemies off screen never attack (combat.md 5.1).
	return get_viewport().get_visible_rect().has_point(get_global_transform_with_canvas().origin)


## Movement while waiting for a token: hold a ring of circle_min..circle_max around the target.
func circle_velocity(to_target: Vector2, speed: float) -> Vector2:
	var d := to_target.length()
	if d > tuning.circle_max:
		return to_target / d * speed
	if d < tuning.circle_min:
		return -to_target / d * speed
	var side := 1.0 if get_instance_id() % 2 == 0 else -1.0
	return to_target.orthogonal() / d * speed * 0.5 * side   # ASSUMED: strafe at half speed


# --- getting hit (combat.md 3.1) ---

func _max_poise() -> float:
	return health.max_hp * poise_ratio


func _on_hurt(hitbox: Hitbox) -> void:
	if health.is_dead():
		return
	hit_flash.flash(tuning.flash_time)
	since_hit = 0.0
	if poise_ratio <= 0.0:
		var from := hitbox.global_position
		if hitbox.source is Node2D:
			from = (hitbox.source as Node2D).global_position
		knock = (global_position - from).normalized() * hitbox.knockback / tuning.enemy_flinch
		release_token()
		_on_flinch()
		return
	# Poise roles take no knockback and do not flinch until poise breaks.
	if poise_immune > 0.0:
		return
	poise -= hitbox.damage * (tuning.poise_finisher_mult if hitbox.heavy else 1.0)
	if poise <= 0.0:
		poise = _max_poise()
		poise_immune = tuning.poise_immunity
		release_token()
		_on_stagger(t("stagger"))


func _on_died() -> void:
	dead = true
	remove_from_group("enemy")   # corpses must not attract soft snap
	release_token()
	velocity = Vector2.ZERO
	attack_hitbox.deactivate()
	hurtbox.set_deferred("monitorable", false)
	body.modulate = Color(0.4, 0.4, 0.4)
	# ponytail: no death anim or drops yet.
	get_tree().create_timer(0.4).timeout.connect(queue_free)
