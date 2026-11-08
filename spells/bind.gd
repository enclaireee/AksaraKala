extends Node2D
## Sunda Nga base spell: roots erupt under every enemy in radius: they are Bound and take thorn damage
## (spells.md 3). Bosses are slowed instead (combat.md 4). Class versions are other spells (spell_variants.gd).

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var perfect := false
var _t := 0.0
const LIFE := 0.45
const THORN := 14.0          # TUNE: damage of the roots


func _ready() -> void:
	power *= SpellUtil.perfect_mult(perfect)
	var radius := data.radius
	var thorn := roundi(THORN * power * SpellUtil.spirit(caster))
	var tint := SpellUtil.tint(data.glyph_id, caster)
	for e in get_tree().get_nodes_in_group("enemy"):
		if e.global_position.distance_to(global_position) <= radius and e.get("status") != null:
			_root(e, thorn, tint)
	var ring := SpellFX.make("bind_ring", 5, 14.0)
	if ring:
		ring.modulate = tint
		ring.scale = Vector2.ONE * radius / 62.0
		add_child(ring)


func _root(e: Node, thorn: int, tint: Color) -> void:
	var tuning: CombatTuning = e.status.tuning
	var seconds := tuning.bound_time
	if e.is_in_group("boss"):
		e.status.apply(Status.Type.SLOW, tuning.bind_slow_time, tuning.bind_slow_mult)   # bosses are never rooted
		seconds = 0.0
	else:
		e.status.apply(Status.Type.BOUND, seconds)
	SpellUtil.strike(e, thorn)
	var roots := SpellFX.make("bind_roots", 6, 14.0)
	if roots and e is Node2D:
		roots.modulate = tint
		roots.position = Vector2(0, 4)
		roots.life = maxf(seconds, 1.0)
		roots.fade = 0.3
		e.add_child(roots)


func _physics_process(delta: float) -> void:
	_t += delta
	if _t >= LIFE:
		queue_free()
