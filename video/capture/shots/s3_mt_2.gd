extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 19, "zone": "mt_pasar", "cam": Vector2(930,900), "vel": Vector2(0,-60), "hero": [Vector2(930,950), Vector2(930,600)], "hero_speed": 0.5})
