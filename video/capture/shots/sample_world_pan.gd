extends "res://video/capture/shot.gd"
## Sample: Tatar Sunda village (ts_kampung) after Act I. HUD off; an 8 s slow pan east along the main road,
## over the plaza with the angklung frames and the village elders; the hero walks in from the left.

func config() -> Dictionary:
	return {"music": false}


func run() -> void:
	await start_demo({"index": 11})            # Act II start: Tatar Sunda's story is done, the town is at peace
	await go("ts_kampung", "from_ts_leuweung")
	make_strong(18)
	god = true
	hide_hud()
	cam_snap = arg("snap", 0.25)               # 0.25 = one screen pixel at 1080p; 1.0 = whole game pixels
	var road_y := 552.0                          # south lane of the main road: clear of the angklung players
	var from := Vector2(arg("x0", 900.0), 500.0)
	var to := Vector2(arg("x1", 1400.0), 500.0)
	teleport(Vector2(from.x - 250.0, road_y))
	aim_at(Vector2(5000, road_y))              # the facing marker points down the road
	cam_detach(from)
	await wait_seconds(1.0)                    # let town life settle, area title fade
	rec_start()
	hold_move(Vector2(arg("walk", 0.95), 0))   # the real move input, nearly full walk (90 px/s)
	await cam_pan(from, to, 8.0, "in_out")
	rec_stop()
	stop()
