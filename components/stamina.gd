class_name Stamina extends Node

signal changed(value: float, max_value: float)
signal empty_attempt

@export var max_stamina: float = 100.0
@export var regen: float = 35.0
@export var regen_delay: float = 0.4
@export var empty_regen_delay: float = 0.8
var value: float
var _delay_left: float = 0.0


func _ready() -> void:
	value = max_stamina


func _physics_process(delta: float) -> void:
	if _delay_left > 0.0:
		_delay_left -= delta
	elif value < max_stamina:
		value = minf(max_stamina, value + regen * delta)
		changed.emit(value, max_stamina)


func spend(cost: float) -> bool:
	if value <= 0.0:
		empty_attempt.emit()
		return false
	value = maxf(0.0, value - cost)
	_delay_left = empty_regen_delay if value == 0.0 else regen_delay
	changed.emit(value, max_stamina)
	return true


func refund(amount: float) -> void:
	value = minf(max_stamina, value + amount)
	changed.emit(value, max_stamina)
