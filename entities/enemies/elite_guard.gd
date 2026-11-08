class_name EliteGuard extends Node
## Soft-lock guard for quest elites (same behaviour as kuntilanak_elite.gd): the parent is hidden and inert
## until Game.check(cond) holds, so it can never be killed too early. Parent keeps a `var active`.

var cond := ""
var enemy: EnemyBase


func _is_on(game: Node) -> bool:
	return game.check(cond) or (cond == "step:sq_g2=2" and game.check("step:sq_g2=3"))


func _ready() -> void:
	enemy = get_parent() as EnemyBase
	var game := get_node("/root/Game")
	if _is_on(game):
		enemy.set("active", true)
		return
	_set_active(false)
	game.changed.connect(_on_game_changed)


func _on_game_changed() -> void:
	var on: bool = _is_on(get_node("/root/Game"))
	if enemy.get("active") and not on and not enemy.dead:
		_set_active(false)   # resolved peacefully: the elite leaves
		return
	if not enemy.get("active") and on:
		_set_active(true)
		enemy.modulate.a = 0.0
		enemy.create_tween().tween_property(enemy, "modulate:a", 1.0, 0.8)   # TUNE: fade-in, as the Kuntilanak elite


func _set_active(on: bool) -> void:
	enemy.set("active", on)
	enemy.visible = on
	enemy.set_physics_process(on)
	if on:
		enemy.add_to_group("enemy")
		if enemy.target == null:
			enemy.target = get_tree().get_first_node_in_group("player") as Node2D
	else:
		enemy.remove_from_group("enemy")
	enemy.collision_layer = 4 if on else 0
	enemy.collision_mask = 5 if on else 0
	enemy.hurtbox.set_deferred("monitorable", on)
