extends Node2D
## Jawa Ha: restore 30% max HP and clear Curse (spells.md 3). Mage x1.2.

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var _t := 0.0
const LIFE := 0.4


func _ready() -> void:
	var h: Health = caster.health
	var mage := 1.2 if SpellUtil.class_id(caster) == "mage" else 1.0
	h.heal(roundi(h.max_hp * data.power / 100.0 * power * SpellUtil.spirit(caster) * mage))   # data.power is a percent
	if caster.get("status") != null:
		caster.status.clear(Status.Type.CURSE)
	global_position = caster.global_position


func _physics_process(delta: float) -> void:
	_t += delta
	queue_redraw()
	if _t >= LIFE:
		queue_free()


func _draw() -> void:
	draw_arc(Vector2(0, -6), 6.0 + 10.0 * _t / LIFE, 0.0, TAU, 24, Color(0.4, 0.85, 0.5, 1.0 - _t / LIFE), 1.0)
