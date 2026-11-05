class_name KuntilanakElite extends Shooter
## SQ-S2 elite. Stats ASSUMED from the balance.md elite row (600 HP, Dmg 14, Ilmu 60, TUNE; 6.3 has no elite modifier yet). Soft-lock guard: stays hidden and inert until quest sq_s2 is at step 2
## (enemy_killed:kuntilanak_elite), so it can never be killed too early.

const FADE_IN := 0.8   # TUNE

var active := false


func _ready() -> void:
	super()
	if is_queued_for_deletion():
		return
	var game := get_node("/root/Game")
	if game.check("step:sq_s2=2"):
		active = true
		return
	_set_active(false)
	game.changed.connect(_on_game_changed)


func _on_game_changed() -> void:
	if not active and get_node("/root/Game").check("step:sq_s2=2"):
		_set_active(true)
		modulate.a = 0.0
		create_tween().tween_property(self, "modulate:a", 1.0, FADE_IN)


func _set_active(on: bool) -> void:
	active = on
	visible = on
	set_physics_process(on)
	if on:
		add_to_group("enemy")
	else:
		remove_from_group("enemy")
	collision_layer = 4 if on else 0
	collision_mask = 5 if on else 0
	hurtbox.set_deferred("monitorable", on)
