class_name EnemyBase extends CharacterBody2D
## Shared enemy plumbing: hitstop, target, knockback, death (combat.md).

@export var tuning: CombatTuning = preload("res://data/combat_tuning.tres")

@onready var body: Polygon2D = $Body
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var health: Health = $Health
@onready var hit_flash: HitFlash = $HitFlash
@onready var aim: Node2D = $Aim
@onready var attack_hitbox: Hitbox = $Aim/Hitbox

var frozen := 0.0          # hitstop time left
var home := Vector2.ZERO
var target: Node2D
var knock := Vector2.ZERO
var dead := false


func _ready() -> void:
	add_to_group("enemy")
	home = global_position
	target = get_tree().get_first_node_in_group("player") as Node2D
	hurtbox.hurt.connect(_on_hurt)
	health.died.connect(_on_died)


func hitstop(seconds: float) -> void:
	frozen = maxf(frozen, seconds)


func _physics_process(delta: float) -> void:
	if frozen > 0.0:
		frozen -= delta
		return
	if dead:
		return
	_tick(delta)


func _tick(_delta: float) -> void:
	pass


func _on_flinch() -> void:
	pass


func _on_hurt(hitbox: Hitbox) -> void:
	if health.is_dead():
		return
	hit_flash.flash(tuning.flash_time)
	var from := hitbox.global_position
	if hitbox.source is Node2D:
		from = (hitbox.source as Node2D).global_position
	knock = (global_position - from).normalized() * hitbox.knockback / tuning.enemy_flinch
	_on_flinch()


func _on_died() -> void:
	dead = true
	remove_from_group("enemy")   # corpses must not attract soft snap
	velocity = Vector2.ZERO
	attack_hitbox.deactivate()
	hurtbox.set_deferred("monitorable", false)
	body.modulate = Color(0.4, 0.4, 0.4)
	# ponytail: no death anim or drops yet.
	get_tree().create_timer(0.4).timeout.connect(queue_free)
