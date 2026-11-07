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
var _trail: Sprite2D   # 2-frame streak behind the shaft (combat.md 2.3b); visual only


func _ready() -> void:
	super._ready()
	rotation = direction.angle()
	var trail_tex := "res://assets/art/fx/arrow_trail.png"
	if ResourceLoader.exists(trail_tex):
		_trail = Sprite2D.new()
		_trail.texture = load(trail_tex)
		_trail.hframes = 2
		_trail.position = Vector2(-11.0, 0.0)   # its right end meets the tail of the 6 px shaft
		_trail.modulate = Color(1, 1, 1, 0.8)
		add_child(_trail)
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
	if _trail:
		_trail.frame = int(_travelled / 6.0) % 2
	if far_damage > 0 and _travelled > far_after:
		damage = far_damage
	if _travelled >= max_range:
		queue_free()
