extends "res://video/capture/shot.gd"
func run() -> void:
	await start_new("mage", "ts_kampung", "from_ts_leuweung")
	var h := hero()
	print("shot: state ", h.state, " frozen ", h.frozen, " paused ", get_tree().paused, " pos ", h.global_position)
	hold_move(Vector2(0.75, 0))
	for i in 6:
		await wait_frames(1)
		print("shot: f", i, " strength ", Input.get_action_strength("move_right"), " vec ", Input.get_vector("move_left", "move_right", "move_up", "move_down"), " move_dir ", h.move_dir, " vel ", h.velocity, " pos ", h.global_position, " state ", h.state)
