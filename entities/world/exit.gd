extends Area2D
## Edge exit (architecture.md 9): the player walks in -> Zones.go_to(target_zone, spawn_id).

const ARM_TIME := 0.5   # ignore the player right after load so arriving here never bounces back

@export var target_zone := ""   # a Zones.ZONES id (or a scene path)
@export var spawn_id := ""
@export var block := 1   # tiles per side of the exit's spot block (Zone.SCALE): the shape covers all of it

var _armed := false


func _ready() -> void:
	var r := RectangleShape2D.new()
	r.size = Vector2.ONE * 16.0 * block
	$Shape.shape = r
	get_tree().create_timer(ARM_TIME).timeout.connect(func() -> void: _armed = true)
	body_entered.connect(_on_body_entered)


func _on_body_entered(b: Node) -> void:
	if _armed and b.is_in_group("player"):
		get_node("/root/Zones").go_to(target_zone, spawn_id)
