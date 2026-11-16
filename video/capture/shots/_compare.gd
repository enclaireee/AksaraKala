extends "res://video/capture/shot.gd"
## Dev: the same moments at any render size, for the 1080p-direct vs 480x270-upscaled comparison.
## Segments (frames from rec_start): 0-59 lesson card (aksara font), 60-~150 a cast stroke being drawn,
## then a 2 s slow linear pan (37.5 px/s: 0.625 game px per frame) with the shot camera.
func run() -> void:
	await start_demo({"index": 11})
	await go("ts_kebun", "from_ts_kampung")
	make_strong(18)
	clear_enemies()
	god = true
	show_hud()
	var c := cell(42, 18)
	teleport(c)
	var foes := spawn_ring("faceless", c, 3, 80.0, true, 0.4)
	face(Vector2.RIGHT)
	await wait_seconds(1.0)
	await show_lesson("sunda_ka")
	rec_start()
	await wait_frames(60)
	close_lesson()
	await wait_frames(2)
	await cast_glyph("sunda_ka", {"center": Vector2(240, 100), "size": 100.0, "seconds": 1.4, "expect": false})
	await wait_frames(30)
	cam_snap = arg("snap", 0.25)
	cam_detach()
	var a := cam_center()
	await cam_pan(a, a + Vector2(75, 0), 2.0, "linear")
	rec_stop()
