class_name Health extends Node

signal damaged(amount: int, source: Node)
signal changed(hp: int, max_hp: int)
signal died

@export var max_hp: int = 100
var hp: int
var shield := 0   # absorbs damage before hp (Ward)
var defense := 0  # armor points: 5% less damage each, min 1 (rpg.md 5); enemies leave it 0
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


func take_damage(amount: int, source: Node = null, ignore_iframes := false) -> bool:
	if is_dead() or (is_invincible() and not ignore_iframes):
		return false
	if defense > 0 and amount > 0:
		amount = maxi(1, roundi(amount * (1.0 - 0.05 * defense)))
	var soaked := mini(shield, amount)
	shield -= soaked
	hp = maxi(0, hp - (amount - soaked))
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
