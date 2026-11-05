class_name Hitbox extends Area2D

signal hit_landed(hurtbox: Hurtbox)

@export var damage: int = 10
@export var knockback: float = 6.0
@export var heavy: bool = false
var source: Node
var _hit: Array[Hurtbox] = []


func _ready() -> void:
	monitorable = false
	monitoring = false
	if source == null:
		source = owner
	area_entered.connect(_on_area_entered)


func activate() -> void:
	_hit.clear()
	set_deferred("monitoring", true)


func deactivate() -> void:
	_hit.clear()
	set_deferred("monitoring", false)


func _on_area_entered(area: Area2D) -> void:
	var hb := area as Hurtbox
	if hb == null or hb in _hit or (source != null and hb.owner == source):
		return
	_hit.append(hb)
	if hb.receive(self):
		hit_landed.emit(hb)
