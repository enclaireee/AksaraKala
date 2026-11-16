extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 39, "zone": "sk_pantai", "cam": Vector2(500,880), "vel": Vector2(60,0), "hero": [Vector2(460,860), Vector2(840,860)], "hero_speed": 0.55})
