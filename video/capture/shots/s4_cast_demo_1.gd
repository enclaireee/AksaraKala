extends "res://video/capture/s4_lib.gd"
## Segment 4 demo 1 (projectile): Aksara Sunda KA -> Bolt (the Wiku's lightning orb) at a pack to the right.
func run() -> void:
	await cast_demo(arg("glyph", "sunda_ka"), [["faceless", Vector2(110, -10)], ["faceless", Vector2(125, 18)], ["jurig_leuweung", Vector2(140, -2)]],
		{"approach": 0.7, "after": 3.6, "target": Vector2.INF})
