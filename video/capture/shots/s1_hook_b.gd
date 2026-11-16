extends "res://video/capture/shots/s1_hook_a.gd"
## Segment 1 cold open B: the Mataram graveyard (mt_kuburan) at dusk-blue, no HUD. Faceless and pocong close in;
## the cursor draws Aksara Jawa KA, release: Banjir Aksara (Tide) floods outward and sweeps them away.
func run() -> void:
	await hook(22, "", Vector2(0, 230), arg("glyph", "jawa_ka"), ["faceless"])
