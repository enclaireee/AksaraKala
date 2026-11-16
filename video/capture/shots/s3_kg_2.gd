extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 12, "zone": "kg_pasar", "cam": Vector2(1000,540), "vel": Vector2(60,0), "hero": [Vector2(960,545), Vector2(1330,545)], "hero_speed": 0.55})
