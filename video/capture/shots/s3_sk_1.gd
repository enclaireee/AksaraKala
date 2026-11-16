extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 40, "zone": "sk_nelayan", "cam": Vector2(1000,880), "vel": Vector2(60,0), "hero": [Vector2(980,900), Vector2(1370,900)], "hero_speed": 0.55})
