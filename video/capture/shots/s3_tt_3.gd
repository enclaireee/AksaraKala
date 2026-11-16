extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 29, "zone": "tt_kulon", "cam": Vector2(600,520), "vel": Vector2(60,0), "hero": [Vector2(560,545), Vector2(940,545)], "hero_speed": 0.55})
