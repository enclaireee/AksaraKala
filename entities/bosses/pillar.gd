class_name Pillar extends Node2D
## Bandung Bondowoso's stone pillar (bestiary.md, Mataram boss). Weapons and spells hit it like an enemy.
## While the dawn beat exposes it, one hit breaks it. The boss drives tick(); there is no own process.

signal broken(pillar: Pillar)

const STONE := Color(0.55, 0.52, 0.48)
const EXPOSED := Color(1.0, 0.85, 0.4)

@onready var body: Polygon2D = $Body
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var health: Health = $Health
@onready var hit_flash: HitFlash = $HitFlash

var exposed_left := 0.0
var dead := false


func _ready() -> void:
	add_to_group("pillar")
	hurtbox.hurt.connect(_on_hurt)
	health.died.connect(_on_died)


func is_exposed() -> bool:
	return exposed_left > 0.0


func expose(seconds: float) -> void:
	exposed_left = seconds
	body.color = EXPOSED


func tick(delta: float) -> void:
	if exposed_left > 0.0:
		exposed_left -= delta
		if exposed_left <= 0.0:
			body.color = STONE


func _on_hurt(_hitbox: Hitbox) -> void:
	hit_flash.flash(0.08)
	if is_exposed() and not health.is_dead():
		health.take_damage(health.max_hp, null, true)


func _on_died() -> void:
	dead = true
	hurtbox.set_deferred("monitorable", false)
	broken.emit(self)
	queue_free()
