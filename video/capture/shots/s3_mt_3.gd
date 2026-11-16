extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 22, "zone": "mt_kuburan", "cam": Vector2(600,300), "vel": Vector2(60,0), "hero": [Vector2(560,380), Vector2(940,380)], "hero_speed": 0.55})
