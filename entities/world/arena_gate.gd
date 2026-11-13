extends StaticBody2D
## Arena gate (combat.md 5.3, boss fights v7): stands open at an arena mouth. Two tiles inside it (toward `side`)
## is the threshold. Crossing the threshold starts the fight: every gate in the zone turns solid, Zones.sealed
## stops exits, and every active boss engages. It opens again when no boss is engaged and alive.
## While a zone has a gate, its bosses cannot be hurt or engage before the threshold (BossKit.may_engage).

const DIRS := {"n": Vector2.UP, "e": Vector2.RIGHT, "s": Vector2.DOWN, "w": Vector2.LEFT}
const DEPTH := 2   # TUNE: tiles between the gate and the threshold

@export var side := "w"   # where the arena lies from the gate: n, e, s or w
@export var block := 1    # tiles per side of the gate's spot block (Zone.SCALE)

var entered := false   # the player crossed a threshold this attempt
var shut := false
var _t := 0.0
var _live_before := 0


func _ready() -> void:
	add_to_group("arena_gate")
	collision_layer = 1
	collision_mask = 0
	var cs := CollisionShape2D.new()
	cs.name = "Shape"
	var r := RectangleShape2D.new()
	r.size = Vector2.ONE * 16.0 * block
	cs.shape = r
	cs.disabled = true
	add_child(cs)
	var th := Area2D.new()
	th.name = "Threshold"
	th.collision_layer = 0
	th.collision_mask = 2   # player
	th.position = _dir() * 16.0 * (block * 0.5 + DEPTH)
	var ts := CollisionShape2D.new()
	var tr := RectangleShape2D.new()
	tr.size = Vector2.ONE * 16.0 * block
	ts.shape = tr
	th.add_child(ts)
	add_child(th)
	th.body_entered.connect(func(b: Node) -> void:
		if b.is_in_group("player"):
			enter())
	z_index = 5


func _dir() -> Vector2:
	return DIRS.get(side, Vector2.LEFT)


## Where a retry puts the player: just inside the open gate, short of the threshold.
## ponytail: inside, not outside: a gate on the map edge (gk_ruang_kala) has only the zone exit behind it.
func door() -> Vector2:
	return global_position + _dir() * 16.0 * (block * 0.5 + 0.5)


func _bosses() -> Array:
	return get_tree().get_nodes_in_group("boss").filter(func(b: Node) -> bool:
		var h: Variant = b.get("health")
		return b.get("active") != false and h != null and (h.hp > 0 or b.has_meta("kneeling")))


## Past every gate's threshold. One gate: its half-plane. Gates on opposite mouths (kg_pamali): the strip between them,
## so a player on the far bank is not "inside" by the near gate's reckoning.
func _inside(at: Vector2) -> bool:
	for g in get_tree().get_nodes_in_group("arena_gate"):
		var th := g.get_node_or_null("Threshold") as Node2D
		var d: Vector2 = DIRS.get(String(g.get("side")), Vector2.LEFT)
		if th == null or (at - th.global_position).dot(d) <= 0.0:
			return false
	return true


func enter() -> void:
	if entered or _bosses().is_empty():
		return
	for g in get_tree().get_nodes_in_group("arena_gate"):
		g.entered = true
	var zones := get_node("/root/Zones")
	get_node("/root/Game").boss_retry = {"zone": zones.current_zone, "pos": [door().x, door().y]}
	for b in _bosses():
		b.hurtbox.set_deferred("monitorable", true)
		if b.has_method("_engage"):   # Buto Ijo sets his arena up in it
			b.call("_engage")
		else:
			b.set("engaged", true)


func _physics_process(delta: float) -> void:
	_t += delta
	var live := _bosses()
	if not entered:
		for b in live:   # asleep until the threshold: no sniping from the door
			b.hurtbox.monitorable = false
		# A boss that wakes while the player already stands inside (Sangkuriang, by the cloth on the post):
		# the fight starts where they stand. ponytail: "inside" is the half-plane past the threshold.
		var p := get_tree().get_first_node_in_group("player") as Node2D
		if _live_before == 0 and not live.is_empty() and _t > 0.5 and p != null and _inside(p.global_position):
			enter()
	_live_before = live.size()
	var want: bool = entered and live.any(func(b: Node) -> bool: return bool(b.get("engaged")))
	if want != shut:
		shut = want
		$Shape.set_deferred("disabled", not shut)
		get_node("/root/Zones").sealed = shut
		Snd.play("gate_slam" if shut else "kabut")
		if not shut:   # won, or the boss stood down
			entered = false
			get_node("/root/Game").boss_retry = {}
	if shut:
		queue_redraw()


func _exit_tree() -> void:
	if shut:
		get_node("/root/Zones").sealed = false


## A wall of burning strokes: flickering columns over the whole block. Drawn only while shut.
func _draw() -> void:
	if not shut:
		return
	var half := 8.0 * block
	var across := _dir().orthogonal().abs()   # the wall runs across the passage
	for i in range(-int(half), int(half), 2):
		var f := 0.5 + 0.5 * sin(_t * 9.0 + i * 1.7)
		var h := 10.0 + 12.0 * f
		var at := across * float(i)
		draw_rect(Rect2(at + Vector2(-1, -h), Vector2(2, h + 4.0)), Color(1.0, 0.45 + 0.4 * f, 0.15, 0.85))
		if i % 6 == 0:   # a brighter stroke with a hook, like a written line
			draw_rect(Rect2(at + Vector2(-1, -h - 3.0), Vector2(4, 2)), Color(1.0, 0.9, 0.55))
