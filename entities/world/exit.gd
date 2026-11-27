extends Area2D
## Edge exit (architecture.md 9): the player walks in -> Zones.go_to(target_zone, spawn_id).

const ARM_TIME := 0.5   # ignore the player right after load so arriving here never bounces back

@export var id := ""
@export var target_zone := ""   # a Zones.ZONES id (or a scene path)
@export var spawn_id := ""
@export var block := 1   # tiles per side of the exit's spot block (Zone.SCALE): the shape covers all of it

const ART := "res://assets/art/world_fx/%s.png"
const CELL := 16   # sheet cells (tools/gen_world_fx.py): 0 path stones, 1 gapura post, 2-5 mote fade stages
const SIGN_RANGE := 64.0   # px from exit center where the quiet signpost appears
var SIGN_FONT := UIFx.body_font()

var _armed := false
var _sheet: Texture2D
var _seal: Texture2D
var _sealed := false
var _across := Vector2.RIGHT   # the line of the two posts, across the passage
var _out := Vector2.DOWN       # toward the nearest map edge: the way the mote drifts
var _t := 0.0
var _key := -1
var _sign: Label


func _ready() -> void:
	add_to_group("exit")
	var r := RectangleShape2D.new()
	r.size = Vector2.ONE * 16.0 * block
	$Shape.shape = r
	get_tree().create_timer(ARM_TIME).timeout.connect(func() -> void: _armed = true)
	body_entered.connect(_on_body_entered)
	_look()
	_make_sign()
	set_process(true)


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


func _make_sign() -> void:
	if target_zone == "" or target_zone.begins_with("res://"):
		return
	_sign = Label.new()
	_sign.add_theme_font_override("font", SIGN_FONT)
	_sign.add_theme_font_size_override("font_size", UIFx.BODY)
	_sign.add_theme_color_override("font_color", Color("F2E9D8"))
	_sign.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.12, 0.9))
	_sign.add_theme_constant_override("outline_size", 2)
	_sign.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sign.custom_minimum_size = Vector2(140, UIFx.LINE)
	var inset := -_out * (8.0 * block + 10.0)
	_sign.position = inset + Vector2(-70, -16)
	_sign.z_index = 20
	_sign.modulate.a = 0.0
	_sign.visible = false
	add_child(_sign)


## ASCII, not an arrow glyph: the body face has no U+2192 and would fall back to a system font.
func _arrow() -> String:
	if absf(_out.x) >= absf(_out.y):
		return ">" if _out.x > 0.0 else "<"
	return "^" if _out.y < 0.0 else "v"


func _zone_label() -> String:
	var key := "UI_ZONE_" + target_zone.to_upper()
	var t := tr(key)
	return t if t != key else target_zone.replace("_", " ").capitalize()


func _update_sign(delta: float) -> void:
	if _sign == null:
		return
	var show_sign := false
	if not _sealed:
		var pl := get_tree().get_first_node_in_group("player") as Node2D
		if pl != null and is_instance_valid(pl):
			var dist := global_position.distance_to(pl.global_position)
			var reach := SIGN_RANGE + 8.0 * block
			if dist <= reach:
				show_sign = true
				for other in get_tree().get_nodes_in_group("exit"):
					if other == self or other.get_parent() != get_parent():
						continue
					if other.get("target_zone") == target_zone:
						var od: float = other.global_position.distance_to(pl.global_position)
						if od < dist - 0.5 or (absf(od - dist) <= 0.5 and other.get_index() < get_index()):
							show_sign = false
							break
	if show_sign:
		_sign.text = "%s %s" % [_arrow(), _zone_label()]
	var target_a := 0.92 if show_sign else 0.0
	_sign.modulate.a = move_toward(_sign.modulate.a, target_a, delta * 5.0)
	_sign.visible = _sign.modulate.a > 0.01


func _process(delta: float) -> void:
	_t += delta
	var sealed: bool = get_node("/root/Zones").sealed
	var key := int(_t * 6.0) % 24 + (100 if sealed else 0)
	if key != _key or sealed != _sealed:
		_key = key
		_sealed = sealed
		if _sheet != null:
			queue_redraw()
	_update_sign(delta)


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
