extends SceneTree
func _initialize() -> void:
	for p in ["res://assets/art/world_fx/shadow_m.png", "res://assets/art/hero_shadow.png"]:
		var t: Texture2D = load(p)
		var im := t.get_image()
		print(p, " ", im.get_size(), " fmt ", im.get_format(), " ", im.get_pixel(im.get_width()/2, im.get_height()/2))
	quit()
