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
	var amount := hitbox.damage
	if hitbox.source != null and hitbox.source.is_in_group("boss"):
		amount = BossKit.boss_damage(amount)   # boss revamp v9: x0.85 (balance.md 7.3)
	health.take_damage(amount, hitbox.source)
	hurt.emit(hitbox)
	return true
