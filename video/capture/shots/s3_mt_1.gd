extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 20, "zone": "mt_sawah", "cam": Vector2(700,420), "vel": Vector2(60,0), "hero": [Vector2(660,530), Vector2(1040,530)], "hero_speed": 0.55})
