class_name Arrow
extends Hitbox
## Player arrow (combat.md 2.3 Busur). Flies straight; the finisher arrow pierces.

var direction := Vector2.RIGHT
var speed := 300.0
var max_range := 220.0
var pierce := false
var far_damage := 0        # damage once past far_after px (Archer Eagle Eye); 0 = off
var far_after := 120.0
var _travelled := 0.0
var _spent := false


func _ready() -> void:
	super._ready()
	rotation = direction.angle()
	body_entered.connect(func(b: Node2D) -> void: if not b is CharacterBody2D: queue_free())   # walls only; enemy bodies share layer 3
	hit_landed.connect(func(_h: Hurtbox) -> void:
		if not pierce:
			_spent = true   # queue_free alone still lets other overlaps queued this frame land
			queue_free())
	activate()


func _on_area_entered(area: Area2D) -> void:
	if not _spent:
		super(area)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_travelled += speed * delta
	if far_damage > 0 and _travelled > far_after:
		damage = far_damage
	if _travelled >= max_range:
		queue_free()
