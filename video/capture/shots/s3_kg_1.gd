extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 11, "zone": "kg_alun", "cam": Vector2(1000,560), "vel": Vector2(60,0), "hero": [Vector2(960,600), Vector2(1330,600)], "hero_speed": 0.55})
