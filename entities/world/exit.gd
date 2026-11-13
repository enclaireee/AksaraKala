extends Area2D
## Edge exit (architecture.md 9): the player walks in -> Zones.go_to(target_zone, spawn_id).

const ARM_TIME := 0.5   # ignore the player right after load so arriving here never bounces back

@export var id := ""
@export var target_zone := ""   # a Zones.ZONES id (or a scene path)
@export var spawn_id := ""
@export var block := 1   # tiles per side of the exit's spot block (Zone.SCALE): the shape covers all of it

const ART := "res://assets/art/world_fx/%s.png"
const CELL := 16   # sheet cells (tools/gen_world_fx.py): 0 path stones, 1 gapura post, 2-5 mote fade stages

var _armed := false
var _sheet: Texture2D
var _seal: Texture2D
var _sealed := false
var _across := Vector2.RIGHT   # the line of the two posts, across the passage
var _out := Vector2.DOWN       # toward the nearest map edge: the way the mote drifts
var _t := 0.0
var _key := -1


func _ready() -> void:
	var r := RectangleShape2D.new()
	r.size = Vector2.ONE * 16.0 * block
	$Shape.shape = r
	get_tree().create_timer(ARM_TIME).timeout.connect(func() -> void: _armed = true)
	body_entered.connect(_on_body_entered)
	_look()


func _on_body_entered(b: Node) -> void:
	if _armed and b.is_in_group("player"):
		get_node("/root/Zones").go_to(target_zone, spawn_id)


## Region from the zone's scene name (ts_ sunda, kg_ galuh, mt_ mataram, tt_ timur, sk_ kidul, gk_ kala, else purwa).
static func region_of(zone: String) -> String:
	var prefixes := {"ts_": "sunda", "kg_": "galuh", "mt_": "mataram", "tt_": "timur", "sk_": "kidul", "gk_": "kala"}
	for p: String in prefixes:
		if zone.begins_with(p):
			return prefixes[p]
	return "purwa"


## The regional marker (tools/gen_world_fx.py). No art, no marker: the exit works the same.
func _look() -> void:
	var z: Node = get_parent()
	while z != null and not (z.get("size") is Vector2i):
		z = z.get_parent()
	var r := region_of(z.scene_file_path.get_file().get_basename() if z != null else "")
	if not ResourceLoader.exists(ART % ("exit_" + r)):
		return
	_sheet = load(ART % ("exit_" + r))
	if ResourceLoader.exists(ART % "exit_seal"):
		_seal = load(ART % "exit_seal")
	if z != null:   # the nearest map edge decides which way the passage runs
		var s := Vector2(z.get("size")) * 16.0
		var d := {Vector2.LEFT: position.x, Vector2.RIGHT: s.x - position.x, Vector2.UP: position.y, Vector2.DOWN: s.y - position.y}
		_out = d.keys()[0]
		for k: Vector2 in d:
			if d[k] < d[_out]:
				_out = k
		_across = _out.orthogonal().abs()
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	var sealed: bool = get_node("/root/Zones").sealed
	var key := int(_t * 6.0) % 24 + (100 if sealed else 0)
	if key != _key or sealed != _sealed:
		_key = key
		_sealed = sealed
		queue_redraw()


func _draw() -> void:
	if _sheet == null:
		return
	var half := 8.0 * block
	for i in block:   # path stones across the whole block, each cell flipped by a hash so they do not repeat
		for j in block:
			var at := Vector2(-half + i * CELL, -half + j * CELL)
			var flip := (i * 7 + j * 3) % 2 == 0
			draw_set_transform(at + Vector2(CELL if flip else 0, 0), 0.0, Vector2(-1 if flip else 1, 1))
			draw_texture_rect_region(_sheet, Rect2(0, 0, CELL, CELL), Rect2(0, 0, CELL, CELL))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if _sealed and _seal != null:   # ink-seal strip across the passage, the sheet's 4 pulse frames
		var f := int(_t * 6.0) % 4
		draw_set_transform(Vector2.ZERO, 0.0 if _across.x > 0.0 else PI * 0.5, Vector2.ONE)
		for i in block:
			draw_texture_rect_region(_seal, Rect2(-half + i * CELL, -8, CELL, CELL), Rect2(f * CELL, 0, CELL, CELL))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for sgn in [-1.0, 1.0]:   # a gapura post each side, standing just outside the block
		var c: Vector2 = _across * (half + 8.0) * sgn
		draw_texture_rect_region(_sheet, Rect2(c + Vector2(-8, -12), Vector2(CELL, CELL)), Rect2(CELL, 0, CELL, CELL))
	var u := fmod(_t / 3.0, 1.0)   # the mote drifts out along the passage, then steps down the fade
	var m := mini(3, int(u * 4.0))
	var wob := _across * sin(_t * 2.0) * 3.0
	draw_texture_rect_region(_sheet, Rect2((_out * (u * half * 0.8 - half * 0.2) + wob).round() - Vector2(8, 8), Vector2(CELL, CELL)), Rect2((2 + m) * CELL, 0, CELL, CELL))
