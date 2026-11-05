class_name PouchField extends Node2D
## One pouch field (bestiary.md Buto Ijo). Only affects Buto; Buto's script reads kind, radius and rest.

const COLORS := {
	"bramble": Color(0.25, 0.5, 0.2, 0.45),
	"bamboo": Color(0.7, 0.8, 0.35, 0.45),
	"salt": Color(0.75, 0.9, 1.0, 0.45),
	"mud": Color(0.4, 0.28, 0.15, 0.55),
}

var kind := "bramble"
var radius := 32.0     # spec
var rest_left := 0.0   # mud: seconds until it can Bind again
var inside := false


func _ready() -> void:
	add_to_group("pouch_field")
	var p := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 20:
		pts.append(Vector2.from_angle(TAU * i / 20.0) * radius)
	p.polygon = pts
	p.color = COLORS.get(kind, Color.WHITE)
	p.z_index = -1
	add_child(p)


func contains(pos: Vector2) -> bool:
	return global_position.distance_to(pos) <= radius
