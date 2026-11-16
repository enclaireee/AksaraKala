extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 2, "zone": "ts_kampung", "cam": Vector2(660,900), "vel": Vector2(0,-60), "hero": [Vector2(660,940), Vector2(660,520)], "hero_speed": 0.667})
