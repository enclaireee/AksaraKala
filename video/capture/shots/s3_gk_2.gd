extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 46, "zone": "gk_pelataran", "cam": Vector2(960,900), "vel": Vector2(0,-60), "hero": [Vector2(960,940), Vector2(960,600)], "hero_speed": 0.5})
