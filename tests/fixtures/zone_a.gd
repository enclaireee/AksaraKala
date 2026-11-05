extends Zone
## tests/zone_test.gd fixture: 2x2 screens, every tile char, one of each world entity.

const CHASER := "res://entities/enemies/chaser.tscn"


func map() -> PackedStringArray:
	var rows := PackedStringArray()
	for y in 34:
		rows.append("#" + ".".repeat(58) + "#" if y > 0 and y < 33 else "#".repeat(60))
	_put(rows, 2, 2, "S.......K.........T")
	_put(rows, 2, 4, ",~btr_")
	_put(rows, 40, 20, "X")
	_put(rows, 59, 5, "E")
	return rows


func spots() -> Dictionary:
	return {
		"S": {"scene": "res://entities/world/spawn.tscn", "props": {"id": "start"}},
		"K": {"scene": "res://entities/world/kabut.tscn", "props": {"flag": "fx_fog"}, "tile": ","},
		"T": {"scene": "res://entities/world/trigger.tscn", "props": {"trigger_id": "fx_trig"}},
		"X": {"scene": "res://entities/world/encounter.tscn", "props": {"area_id": "fx_area", "size": Vector2i(9, 7),
			"waves": [[[CHASER, Vector2i(3, 0)], [CHASER, Vector2i(-3, 0)]], [[CHASER, Vector2i(0, 3)]]]}},
		"E": {"scene": "res://entities/world/exit.tscn", "props": {"target_zone": "res://tests/fixtures/zone_b.tscn", "spawn_id": "west"}, "tile": ","},
	}


func _put(rows: PackedStringArray, x: int, y: int, s: String) -> void:
	rows[y] = rows[y].substr(0, x) + s + rows[y].substr(x + s.length())
