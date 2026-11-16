extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 47, "zone": "gk_mulut", "cam": Vector2(700,880), "vel": Vector2(60,0), "hero": [Vector2(660,780), Vector2(1040,780)], "hero_speed": 0.55})
