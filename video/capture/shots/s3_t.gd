extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 2, "zone": "ts_kampung", "spawn": "from_ts_leuweung", "cam": Vector2(900, 500), "vel": Vector2(60, 0), "hero": [Vector2(850, 552), Vector2(1250, 552)], "hero_speed": 0.667, "secs": 3.0})
