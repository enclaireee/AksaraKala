extends Node2D
## Jawa Ca: +30% attack speed and +50% stamina regen for 10 s (spells.md 3).

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var _left := 0.0
var _on := false
const ATK := 1.3
const REGEN := 1.5


func _ready() -> void:
	for r in get_tree().get_nodes_in_group("rally"):
		if r != self:
			r.end()   # undo now, not at queue_free: the buffs multiply
			r.queue_free()
	add_to_group("rally")
	_on = true
	_left = data.duration
	_boost()
	# Every Game.changed (a kill's Ilmu, an equip) recomputes the player's stats, so boost again after it.
	# The player connected first, so its apply_from_game() runs before this.
	if caster.has_method("apply_from_game"):
		get_node("/root/Game").changed.connect(_boost)


func _boost() -> void:
	caster.atk_speed *= ATK
	caster.stamina.regen *= REGEN


## Undo by recomputing, never by dividing: dividing after a recompute would leave the stats low for good.
func end() -> void:
	if not _on:
		return
	_on = false
	var game := get_node("/root/Game")
	if game.changed.is_connected(_boost):
		game.changed.disconnect(_boost)
	if is_instance_valid(caster):
		if caster.has_method("apply_from_game"):
			caster.apply_from_game()
		else:
			caster.atk_speed /= ATK   # test dummies with no recompute
			caster.stamina.regen /= REGEN


func _physics_process(delta: float) -> void:
	_left -= delta
	if _left <= 0.0 or not is_instance_valid(caster):
		queue_free()
		return
	global_position = caster.global_position
	queue_redraw()


func _exit_tree() -> void:
	end()


func _draw() -> void:
	draw_arc(Vector2(0, -6), 10.0, 0.0, TAU, 24, Color(0.95, 0.7, 0.25, 0.5), 1.0)
