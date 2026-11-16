extends "res://video/capture/s4_lib.gd"
## Segment 4 demo 2 (area): Aksara Sunda NGA -> Bind (spirit vines burst from the ground round the Wiku).
func run() -> void:
	var ring := []
	for i in 6:
		var jur := i % 2 == 1
		ring.append([["faceless", "faceless"][int(jur)], Vector2.from_angle(0.4 + TAU * i / 6.0) * Vector2(1.3, 1.0) * (80.0 if jur else 110.0)])
	await cast_demo(arg("glyph", "sunda_nga"), ring, {"approach": 0.55, "after": 3.8, "creep": 30.0, "creep_to": 40.0})
