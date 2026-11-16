extends "res://video/capture/s4_lib.gd"
## Segment 4 demo 3 (summon, Aksara Jawa): Jawa RA -> Summon (the Wiku's fire tiger) that hunts the pack.
func run() -> void:
	await cast_demo(arg("glyph", "jawa_ra"), [["faceless", Vector2(105, -25)], ["faceless", Vector2(120, 20)], ["jurig_leuweung", Vector2(-110, 10)], ["faceless", Vector2(-100, -30)]],
		{"approach": 0.8, "after": 4.5})
