class_name Hurtbox extends Area2D

signal hurt(hitbox: Hitbox)
signal dodged(hitbox: Hitbox)   # refused by i-frames (perfect dodge check, combat.md 7)

@export var health: Health


func _ready() -> void:
	monitoring = false
	monitorable = true


func receive(hitbox: Hitbox) -> bool:
	if health == null or health.is_dead():
		return false
	if health.is_invincible():
		dodged.emit(hitbox)
		return false
	health.take_damage(hitbox.damage, hitbox.source)
	hurt.emit(hitbox)
	return true
