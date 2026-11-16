extends SceneTree
var n := 0
func _process(_d: float) -> bool:
	n += 1
	if n in [1, 3, 10]:
		print(n, " ds=", DisplayServer.window_get_size(), " root=", root.size, " vis=", root.get_visible_rect(), " tex=", root.get_texture().get_size(), " final=", root.get_final_transform().x)
	return n > 10
