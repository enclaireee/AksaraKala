extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 16, "zone": "kg_keraton", "cam": Vector2(960,940), "vel": Vector2(0,-60), "hero": [Vector2(960,960), Vector2(960,700)], "hero_speed": 0.45})
