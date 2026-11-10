class_name Oncor extends Node2D
## One of four torches ringing Sandekala's room. A player hit lights it for good (bestiary.md).
## ASSUMED: "a hit lights one" = the player hits the oncor itself (melee or spell), which makes the
## room the puzzle: the player must leave Sandekala and walk the ring.

signal lit_up

var lit := false

@onready var flame: Sprite2D = $Flame   # props/oncor.png: frame 0 cold, 1-3 burning
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var health: Health = $Health


func _ready() -> void:
	add_to_group("oncor")
	flame.frame = 0
	hurtbox.hurt.connect(func(_h: Hitbox) -> void:
		health.hp = health.max_hp   # the torch is never destroyed
		light())


func _process(_delta: float) -> void:
	if lit:
		flame.frame = 1 + int(Time.get_ticks_msec() / 110.0) % 3


func light() -> void:
	if lit:
		return
	lit = true
	flame.frame = 1
	lit_up.emit()
