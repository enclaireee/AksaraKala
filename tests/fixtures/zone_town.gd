extends Zone
## tests/town_zone_test.gd fixture: one screen at scale 1, with every town char.


func area_scale() -> int:
	return 1


func map() -> PackedStringArray:
	var rows := PackedStringArray()
	for y in 17:
		rows.append("#" + ".".repeat(28) + "#" if y > 0 and y < 16 else "#".repeat(30))
	_put(rows, 3, 3, "S")
	_put(rows, 2, 8, ",".repeat(26))
	_put(rows, 10, 2, "[[[[")
	_put(rows, 10, 12, "----")
	_put(rows, 16, 12, "''''")
	_put(rows, 22, 12, "{{")
	return rows


func spots() -> Dictionary:
	return {"S": {"scene": "res://entities/world/spawn.tscn", "props": {"id": "start"}}}


func _put(rows: PackedStringArray, x: int, y: int, s: String) -> void:
	rows[y] = rows[y].substr(0, x) + s + rows[y].substr(x + s.length())
