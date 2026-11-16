extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 52, "zone": "gk_ruang_kala", "cam": Vector2(960,300), "vel": Vector2(0,60), "hero": [Vector2(960,340), Vector2(960,700)], "hero_speed": 0.5})
