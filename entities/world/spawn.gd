extends Marker2D
## Where Zones.go_to and the zone base place the player (architecture.md 9). Put it one tile inside an exit.

@export var id := ""


func _ready() -> void:
	add_to_group("spawn")
