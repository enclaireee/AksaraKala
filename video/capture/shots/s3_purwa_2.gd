extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 38, "zone": "desa_purwa", "cam": Vector2(1190,520), "vel": Vector2(0,60), "hero": [Vector2(1190,580), Vector2(1190,860)], "hero_speed": 0.45})
