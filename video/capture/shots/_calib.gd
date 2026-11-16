extends "res://video/capture/shot.gd"
## Dev check: the frame drawn after rec_start() is the first kept frame (it shows white).
func run() -> void:
	await wait_frames(10)
	var l := CanvasLayer.new()
	var r := ColorRect.new()
	r.color = Color.WHITE
	r.size = Vector2(480, 270)
	l.add_child(r)
	add_child(l)
	rec_start()
	await wait_frames(5)
	rec_stop()
	l.queue_free()
	await wait_frames(3)
