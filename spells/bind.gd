extends Node2D
## Sunda Nga: roots erupt under every enemy in radius: they are Bound and take thorn damage (spells.md 3).
## Bosses are slowed instead (combat.md 4). Hulubalang: wider and sharper. Pamanah: a long slow after the root.
## Pendekar: longer root and a moment of invincibility. Wiku: drinks a little Sakti from each root.

var caster: Node2D   # a Player; typed loosely so spells load before player.gd does
var data: SpellData
var direction := Vector2.RIGHT
var power := 1.0
var perfect := false
var _t := 0.0
const LIFE := 0.45
const THORN := 14.0          # TUNE: damage of the roots
const SAKTI_PER_ROOT := 3.0  # TUNE: Wiku refund per rooted enemy, at most SAKTI_CAP
const SAKTI_CAP := 6.0


func _ready() -> void:
	power *= SpellUtil.perfect_mult(perfect)
	var cls := SpellUtil.class_id(caster)
	var radius := data.radius * (1.3 if cls == "warrior" else 1.0)
	var thorn := roundi(THORN * power * SpellUtil.spirit(caster) * (1.5 if cls == "warrior" else 1.0))
	var tint := SpellUtil.tint(data.glyph_id, caster)
	var rooted := 0
	for e in get_tree().get_nodes_in_group("enemy"):
		if e.global_position.distance_to(global_position) <= radius and e.get("status") != null:
			rooted += 1
			_root(e, cls, thorn, tint)
	if rooted > 0:
		if cls == "rogue":
			caster.health.set_invincible(0.5)
		elif cls == "mage" and caster.get("sakti") != null:
			caster.sakti.add(minf(SAKTI_CAP, SAKTI_PER_ROOT * rooted))
	var ring := SpellFX.make("bind_ring", 5, 14.0)
	if ring:
		ring.modulate = tint
		ring.scale = Vector2.ONE * radius / 62.0
		add_child(ring)


func _root(e: Node, cls: String, thorn: int, tint: Color) -> void:
	var tuning: CombatTuning = e.status.tuning
	var big := e.is_in_group("boss")
	var seconds := tuning.bound_time * (1.3 if cls == "rogue" else 1.0)
	if big:
		e.status.apply(Status.Type.SLOW, tuning.bind_slow_time, tuning.bind_slow_mult)   # bosses are never rooted
		seconds = 0.0
	else:
		e.status.apply(Status.Type.BOUND, seconds)
		if cls == "archer":   # the slow outlasts the root by 3 s
			e.status.apply(Status.Type.SLOW, seconds + 3.0, 0.5)
	SpellUtil.strike(e, thorn)
	var roots := SpellFX.make("bind_roots", 6, 14.0)
	if roots and e is Node2D:
		roots.modulate = tint
		roots.position = Vector2(0, 4)
		roots.life = maxf(seconds, 1.0)
		roots.fade = 0.3
		roots.z_index = 8
		e.add_child(roots)


func _physics_process(delta: float) -> void:
	_t += delta
	if _t >= LIFE:
		queue_free()
