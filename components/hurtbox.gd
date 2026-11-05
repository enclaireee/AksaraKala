class_name Hurtbox extends Area2D

signal hurt(hitbox: Hitbox)

@export var health: Health


func _ready() -> void:
	monitoring = false
	monitorable = true


func receive(hitbox: Hitbox) -> bool:
	if health == null or health.is_dead() or health.is_invincible():
		return false
	health.take_damage(hitbox.damage, hitbox.source)
	hurt.emit(hitbox)
	return true
