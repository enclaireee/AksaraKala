extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 38, "zone": "desa_purwa", "tint": Color(1.0,0.82,0.68), "cam": Vector2(300,1110), "vel": Vector2(60,0), "hero": [Vector2(380,1040), Vector2(720,1040)], "hero_speed": 0.5})
