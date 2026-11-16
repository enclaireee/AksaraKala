extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 7, "zone": "ts_situ", "cam": Vector2(560,350), "vel": Vector2(60,0), "hero": [Vector2(520,462), Vector2(900,462)], "hero_speed": 0.5})
