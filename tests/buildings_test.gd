extends SceneTree
## zones/buildings.gd: detection, claimed cells, determinism, roof fade. Exits 0 on pass, prints only failures.

const BUILDINGS := preload("res://zones/buildings.gd")
const FAKE := """extends Node2D
var grid: Array[String] = []
var size := Vector2i.ZERO
var zone_id := "fixture_b"
var claimed := {}
var entities: Node2D
func region_key() -> String:
	return "sunda"
"""

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _grid() -> Array[String]:
	var rows: Array[String] = []
	for y in 20:
		rows.append(".".repeat(30))
	_put(rows, 2, 2, 6, 4, "[")
	# ring room: x 12..21, y 3..11, floor inside, door gap at x 16 on the south row
	_put(rows, 12, 3, 10, 9, "#")
	_put(rows, 13, 4, 8, 7, "_")
	var r: String = rows[11]
	rows[11] = r.substr(0, 16) + "," + r.substr(17)
	return rows


func _put(rows: Array[String], x: int, y: int, w: int, h: int, c: String) -> void:
	for j in h:
		var r: String = rows[y + j]
		rows[y + j] = r.substr(0, x) + c.repeat(w) + r.substr(x + w)


func _zone() -> Node2D:
	var s := GDScript.new()
	s.source_code = FAKE
	s.reload()
	var z := Node2D.new()
	z.set_script(s)
	z.set("grid", _grid())
	z.set("size", Vector2i(30, 20))
	var ent := Node2D.new()
	z.set("entities", ent)
	z.add_child(ent)
	return z


func _initialize() -> void:
	var z := _zone()
	root.add_child(z)
	var b: Node2D = BUILDINGS.new()
	z.get("entities").add_child(b)
	b.build(z)
	await process_frame
	check(b.is_inside_tree(), "buildings node not in the tree")
	check(b.list.size() == 2, "expected 2 buildings, got %d" % b.list.size())
	var claimed: Dictionary = z.get("claimed")
	var missing := 0
	for y in range(2, 6):
		for x in range(2, 8):
			missing += 0 if claimed.has(Vector2i(x, y)) else 1
	for y in range(3, 12):
		for x in range(12, 22):
			missing += 0 if claimed.has(Vector2i(x, y)) else 1
	check(missing == 0, "%d footprint cells are not claimed" % missing)
	var room: Dictionary = {}
	for e: Dictionary in b.list:
		if e.enterable:
			room = e
	check(not room.is_empty() and room.door_col == 4, "room door not at the gap: %s" % room.get("door_col"))

	# same seed, same result
	var z2 := _zone()
	root.add_child(z2)
	var b2: Node2D = BUILDINGS.new()
	z2.get("entities").add_child(b2)
	b2.build(z2)
	var same: bool = b2.list.size() == b.list.size()
	if same:
		for i in b.list.size():
			var p: Dictionary = b.list[i]
			var q: Dictionary = b2.list[i]
			same = same and p.kind == q.kind and p.pal == q.pal and p.rect == q.rect and p.door_col == q.door_col
			var ia: Image = (p.node.get_node("Roof0") as Sprite2D).texture.get_image()
			var ib: Image = (q.node.get_node("Roof0") as Sprite2D).texture.get_image()
			var ba: Image = (p.node.get_node("Body") as Sprite2D).texture.get_image()
			var bb: Image = (q.node.get_node("Body") as Sprite2D).texture.get_image()
			same = same and ia.get_data() == ib.get_data() and ba.get_data() == bb.get_data()
	check(same, "two builds with the same seed differ")

	# roof fade: a fake player inside the room
	var player := Node2D.new()
	player.add_to_group("player")
	root.add_child(player)
	player.global_position = Vector2(16 * 16 + 8, 8 * 16)
	var node: Node2D = room.node
	b._process(0.0)
	check(node.modulate.a > 0.99, "alpha changed before the tween ran")
	var tw: Tween = b._tween.get(node)
	check(tw != null, "no fade tween started inside the room")
	if tw != null:
		await tw.finished
	check(absf(node.modulate.a - 0.15) < 0.01, "roof alpha inside is %f" % node.modulate.a)
	player.global_position = Vector2(3 * 16, 8 * 16)
	b._process(0.0)
	tw = b._tween.get(node)
	if tw != null:
		await tw.finished
	check(node.modulate.a > 0.99, "roof alpha outside is %f" % node.modulate.a)
	quit(1 if fails > 0 else 0)
