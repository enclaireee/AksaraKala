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
	add_to_group("encounter")
	var r := RectangleShape2D.new()
	r.size = Vector2(size * 16)
	$Shape.shape = r
	body_entered.connect(_on_body_entered)
	if cond != "":
		get_node("/root/Game").changed.connect(_on_game_changed)


## True when the given player node is physically within this encounter's arena rect.
func is_player_inside(pl: Node2D) -> bool:
	if pl == null or not is_instance_valid(pl):
		return false
	var s := Vector2(size * 16)
	var r := Rect2(global_position - s * 0.5, s)
	return r.grow(16.0).has_point(pl.global_position)


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
	var m := Polygon2D.new()   # a textured quad: cracked ground with a red ink seal (tools/gen_world_fx.py spawn_mark.png, 16x10)
	if ResourceLoader.exists("res://assets/art/world_fx/spawn_mark.png"):
		m.texture = load("res://assets/art/world_fx/spawn_mark.png")
		m.polygon = PackedVector2Array([Vector2(-8, -5), Vector2(8, -5), Vector2(8, 5), Vector2(-8, 5)])
		m.uv = PackedVector2Array([Vector2(0, 0), Vector2(16, 0), Vector2(16, 10), Vector2(0, 10)])
	else:
		m.color = Color(0.9, 0.2, 0.15, 0.7)
		m.polygon = PackedVector2Array([Vector2(-7, -4), Vector2(7, -4), Vector2(7, 4), Vector2(-7, 4)])
	m.position = at
	m.z_index = -1
	get_parent().add_child(m)
	var tw := m.create_tween().set_loops()
	tw.tween_property(m, "modulate:a", 0.3, 0.12)
	tw.tween_property(m, "modulate:a", 1.0, 0.12)
	return m
