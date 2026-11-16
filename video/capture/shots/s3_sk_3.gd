extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 45, "zone": "sk_keraton", "cam": Vector2(960,800), "vel": Vector2(0,-60), "hero": [Vector2(960,850), Vector2(960,520)], "hero_speed": 0.5})
