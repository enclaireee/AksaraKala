class_name Health extends Node

signal damaged(amount: int, source: Node)
signal changed(hp: int, max_hp: int)
signal died

@export var max_hp: int = 100
var hp: int
var invincible_time: float = 0.0


func _ready() -> void:
	hp = max_hp


func _physics_process(delta: float) -> void:
	invincible_time = maxf(0.0, invincible_time - delta)


func is_invincible() -> bool:
	return invincible_time > 0.0


func set_invincible(seconds: float) -> void:
	invincible_time = maxf(invincible_time, seconds)


func is_dead() -> bool:
	return hp <= 0


func take_damage(amount: int, source: Node = null) -> bool:
	if is_dead() or is_invincible():
		return false
	hp = maxi(0, hp - amount)
	damaged.emit(amount, source)
	changed.emit(hp, max_hp)
	if hp == 0:
		died.emit()
	return true


func heal(amount: int) -> void:
	if is_dead():
		return
	hp = mini(max_hp, hp + amount)
	changed.emit(hp, max_hp)
