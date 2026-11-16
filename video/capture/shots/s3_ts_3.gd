extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 9, "zone": "ts_kawah", "cam": Vector2(330,540), "vel": Vector2(60,0), "hero": [Vector2(280,560), Vector2(750,560)], "hero_speed": 0.5})
