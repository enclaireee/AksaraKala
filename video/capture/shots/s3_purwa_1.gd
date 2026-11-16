extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"zone": "desa_purwa", "flags": ["mq0_d1","mq0_d2","mq0_d2b","mq0_d3","mq0_d4","mq0_d4b","mq0_d5","mq0_d6","mq0_d6b","mq0_d7"], "tint": Color(0.56,0.6,1.0), "cam": Vector2(960,215), "vel": Vector2(60,0), "hero": [Vector2(1040,266), Vector2(1355,266)], "hero_speed": 0.5})
