extends "res://video/capture/s3_lib.gd"
func run() -> void:
	await scenic({"demo": 31, "zone": "tt_ladang", "cam": Vector2(1050,540), "vel": Vector2(60,0), "hero": [Vector2(1000,2000)]})
