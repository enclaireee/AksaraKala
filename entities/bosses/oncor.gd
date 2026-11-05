class_name Oncor extends Node2D
## One of four torches ringing Sandekala's room. A player hit lights it for good (bestiary.md).
## ASSUMED: "a hit lights one" = the player hits the oncor itself (melee or spell), which makes the
## room the puzzle: the player must leave Sandekala and walk the ring.

signal lit_up

const OFF := Color(0.35, 0.3, 0.25)
const ON := Color(1.0, 0.8, 0.3)

var lit := false

@onready var flame: Polygon2D = $Flame
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var health: Health = $Health


func _ready() -> void:
	add_to_group("oncor")
	flame.color = OFF
	hurtbox.hurt.connect(func(_h: Hitbox) -> void:
		health.hp = health.max_hp   # the torch is never destroyed
		light())


func light() -> void:
	if lit:
		return
	lit = true
	flame.color = ON
	lit_up.emit()
