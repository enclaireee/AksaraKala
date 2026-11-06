extends Area2D
## Encounter (architecture.md 9): the player walks into the rect -> wave 1 spawns. When every enemy
## of a wave has died, ground markers warn for WARN seconds where the next wave appears, then it
## spawns. After the last wave: Events.area_cleared(area_id). Runs once per zone load.

const WARN := 0.5   # TUNE

@export var area_id := ""
@export var size := Vector2i(15, 9)   # tiles, centered on the node
## Each wave: Array of [scene_path: String, tile_offset: Vector2i] (offset from this node's tile).
@export var waves: Array = []
## Game.check condition; the encounter stays off (starts nothing, draws nothing) until it holds. Empty = always on.
@export var cond := ""

var _wave := -1   # index of the wave on the field
var _alive := 0
var _started := false


func _ready() -> void:
	var r := RectangleShape2D.new()
	r.size = Vector2(size * 16)
	$Shape.shape = r
	body_entered.connect(_on_body_entered)
	if cond != "":
		get_node("/root/Game").changed.connect(_on_game_changed)


## The condition came true with the player already inside the rect.
func _on_game_changed() -> void:
	for b in get_overlapping_bodies():
		_on_body_entered(b)


func _on_body_entered(b: Node) -> void:
	if not _started and b.is_in_group("player") and get_node("/root/Game").check(cond):
		_started = true
		_next.call_deferred()   # no adding bodies during the physics flush


func _next() -> void:
	_wave += 1
	if _wave >= waves.size():
		get_node("/root/Events").area_cleared.emit(area_id)
		return
	if _wave == 0:
		_spawn()
		return
	var marks: Array[Node] = []
	for e in waves[_wave]:
		marks.append(_marker(position + Vector2(e[1] * 16)))
	# A connection, not an await: it drops by itself if the zone unloads first.
	get_tree().create_timer(WARN, false).timeout.connect(_after_warning.bind(marks))


func _after_warning(marks: Array[Node]) -> void:
	for m in marks:
		if is_instance_valid(m):
			m.queue_free()
	_spawn()


func _spawn() -> void:
	_alive = 0
	for e in waves[_wave]:
		if not ResourceLoader.exists(e[0]):
			push_warning("encounter %s: %s does not exist" % [area_id, e[0]])
			continue
		var n: Node2D = load(e[0]).instantiate()
		n.position = position + Vector2(e[1] * 16)
		get_parent().add_child(n)
		var h: Node = n.get_node_or_null("Health")
		if n.is_queued_for_deletion() or h == null:
			continue   # a unique enemy already in Game.killed frees itself
		_alive += 1
		h.died.connect(_on_died, CONNECT_ONE_SHOT)
	if _alive == 0:
		_next()


func _on_died() -> void:
	_alive -= 1
	if _alive == 0:
		_next()


func _marker(at: Vector2) -> Node2D:
	var m := Polygon2D.new()
	m.color = Color(0.9, 0.2, 0.15, 0.7)   # ASSUMED: red ground ring as the spawn warning
	var pts := PackedVector2Array()
	for i in 12:
		pts.append(Vector2.from_angle(TAU * i / 12.0) * Vector2(7, 4))
	m.polygon = pts
	m.position = at
	m.z_index = -1
	get_parent().add_child(m)
	var tw := m.create_tween().set_loops()
	tw.tween_property(m, "modulate:a", 0.3, 0.12)
	tw.tween_property(m, "modulate:a", 1.0, 0.12)
	return m
