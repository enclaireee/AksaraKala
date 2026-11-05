extends Node2D
## Sunda Ga: a shield on the caster that soaks damage, then ends (spells.md 3).

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var replaced := false
var _left := 0.0


func _ready() -> void:
	for w in get_tree().get_nodes_in_group("ward"):
		if w != self:
			w.replaced = true
			w.queue_free()
	add_to_group("ward")
	caster.health.shield = roundi(data.power * power * SpellUtil.spirit(caster) * (1.3 if SpellUtil.class_id(caster) == "warrior" else 1.0))   # Warrior x1.3
	_left = data.duration
	global_position = caster.global_position


func _physics_process(delta: float) -> void:
	_left -= delta
	if _left <= 0.0 or not is_instance_valid(caster) or caster.health.shield <= 0:
		queue_free()
		return
	global_position = caster.global_position


func _exit_tree() -> void:
	if is_instance_valid(caster) and not replaced:   # a room reload can free the player first
		caster.health.shield = 0


func _draw() -> void:
	draw_arc(Vector2(0, -6), 12.0, 0.0, TAU, 24, Color(0.337, 0.706, 0.914, 0.5), 1.0)
