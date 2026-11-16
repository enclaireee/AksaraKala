extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 47, "zone": "gk_mulut", "cam": Vector2(700,880), "vel": Vector2(60,0), "hero": [Vector2(620,850), Vector2(900,850)], "hero_speed": 0.4})
