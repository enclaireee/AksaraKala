class_name Arca extends Shooter
## Stationary stone shooter (bestiary.md). Dormant (no shots, no tokens, not a soft-snap target) until the player
## comes within WAKE_RADIUS. Weakness Na Dash-strike: passing through it does x3 damage.

const WAKE_RADIUS := 80.0   # TUNE: 5 tiles
const DASH_MULT := 3        # TUNE

var awake := false


func _ready() -> void:
	super()
	remove_from_group("enemy")


func _tick(delta: float) -> void:
	if not awake:
		if target == null or global_position.distance_to(target.global_position) > WAKE_RADIUS:
			return
		awake = true
		add_to_group("enemy")
	super(delta)


func _on_hurt(hitbox: Hitbox) -> void:
	var weak: bool = hitbox.get_script() != null and (hitbox.get_script() as Script).resource_path.ends_with("dash_strike.gd")
	super(hitbox)
	if weak and not health.is_dead():
		get_node("/root/Events").weakness_triggered.emit(kind)
		health.take_damage(hitbox.damage * (DASH_MULT - 1), hitbox.source, true)
