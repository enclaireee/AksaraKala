extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 32, "zone": "tt_ladang", "cam": Vector2(960,540), "vel": Vector2(60,0), "hero": [Vector2(920,545), Vector2(1300,545)], "hero_speed": 0.55})
