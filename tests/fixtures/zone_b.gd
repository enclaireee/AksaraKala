extends Zone
## tests/zone_test.gd fixture: one screen, a kabut already lifted (fx_fog) and one that never lifts.


func map() -> PackedStringArray:
	var rows := PackedStringArray()
	for y in 17:
		rows.append("#" + ".".repeat(28) + "#" if y > 0 and y < 16 else "#".repeat(30))
	rows[8] = "EW" + rows[8].substr(2, 13) + "S" + rows[8].substr(16)
	rows[3] = rows[3].substr(0, 5) + "KN" + rows[3].substr(7)
	return rows


func spots() -> Dictionary:
	return {
		"S": {"scene": "res://entities/world/spawn.tscn", "props": {"id": "start"}},
		"W": {"scene": "res://entities/world/spawn.tscn", "props": {"id": "west"}},
		"E": {"scene": "res://entities/world/exit.tscn", "props": {"target_zone": "res://tests/fixtures/zone_a.tscn", "spawn_id": "start"}, "tile": ","},
		"K": {"scene": "res://entities/world/kabut.tscn", "props": {"flag": "fx_fog"}},
		"N": {"scene": "res://entities/world/kabut.tscn", "props": {"flag": ""}},
	}
