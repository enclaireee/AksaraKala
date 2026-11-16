extends SceneTree
## Prints every Demo-route checkpoint (DemoRoute.checkpoints()) as one line: index kind quest step zone boss.
## Run: $GODOT --headless --path . -s res://video/capture/list_checkpoints.gd
func _initialize() -> void:
	var cps: Array = load("res://ui/demo_route.gd").checkpoints()
	for i in cps.size():
		var c: Dictionary = cps[i]
		print("%2d  %-5s %-4s step %-2d %-16s %s" % [i, c.kind, c.quest, c.step, c.zone, c.boss])
	quit(0)
