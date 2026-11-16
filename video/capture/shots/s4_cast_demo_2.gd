extends "res://video/capture/s4_lib.gd"
## Segment 4 demo 2 (area): Aksara Sunda NGA -> Bind (vines burst from the ground round the Wiku) on a ring of foes.
func run() -> void:
	var ring := []
	for i in 6:
		ring.append([["faceless", "jurig_leuweung"][i % 2], Vector2.from_angle(0.4 + TAU * i / 6.0) * 92.0])
	await cast_demo(arg("glyph", "sunda_nga"), ring, {"approach": 1.0, "after": 3.6})
