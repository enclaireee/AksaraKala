class_name SaktiGauge extends Node

signal changed(value: float, max_value: float)

@export var tuning: CombatTuning = preload("res://data/combat_tuning.tres")
@export var status: Status
var value := 0.0
var max_value: float


func _ready() -> void:
	max_value = tuning.sakti_max


func add(amount: float) -> void:
	if status and status.has(Status.Type.CURSE):
		return
	value = minf(max_value, value + amount)
	changed.emit(value, max_value)


func spend(cost: float) -> bool:
	if value < cost:
		return false
	value -= cost
	changed.emit(value, max_value)
	return true
