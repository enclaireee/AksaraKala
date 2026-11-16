extends SceneTree
## Entry point for one trailer shot: godot ... -s res://video/capture/runner.gd -- --shot=<name>
## Loads res://video/capture/shots/<name>.gd (extends shot.gd), adds it under /root so it outlives zone
## changes, runs it, and quits: 0 when the shot finished, 3 when it called fail(), 4 on the watchdog.
## shoot.sh wraps this with xvfb-run, Movie Maker and the encode.

var shot: Node
var max_frames := 60 * 600


func _initialize() -> void:
	var name := ""
	var args := {}
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--shot="):
			name = a.substr(7)
		elif a.begins_with("--") and "=" in a:
			args[a.substr(2, a.find("=") - 2)] = a.substr(a.find("=") + 1)
	var path := name if name.begins_with("res://") else "res://video/capture/shots/%s.gd" % name
	var sc := load(path) as GDScript
	if sc == null:
		printerr("@@SHOT FAIL no shot script " + path)
		quit(2)
		return
	shot = sc.new()
	shot.name = "Shot"
	var cfg: Dictionary = {"music": false, "sfx": true, "ambience": true, "locale": "en", "max_seconds": 600}
	cfg.merge(shot.config(), true)
	shot.opts = cfg
	shot.args = args
	max_frames = int(float(cfg.max_seconds) * 60.0)
	root.add_child(shot)
	_go.call_deferred()


func _go() -> void:
	await process_frame
	Input.warp_mouse(Vector2(root.size) / 2.0)   # mouse at screen centre: no camera lean, no stray aim
	shot._base_setup()
	print("@@SHOT begin %s window %s" % [shot.get_script().resource_path, DisplayServer.window_get_size()])
	await shot.run()
	if shot.failed:
		return
	await process_frame
	print("@@SHOT done frames_drawn %d" % Engine.get_frames_drawn())
	Engine.time_scale = 1.0
	quit(0)


func _process(_delta: float) -> bool:
	if Engine.get_process_frames() > max_frames and shot and not shot.failed:
		printerr("@@SHOT FAIL watchdog: shot ran past max_seconds")
		shot.failed = true
		quit(4)
	return false
