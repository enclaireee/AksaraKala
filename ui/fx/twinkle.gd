class_name Twinkle extends Control
## Twinkling stars over the dusk sky (ui.md 0.1): a fixed scatter in the upper sky, each star fading on its own slow
## period. Positions are seeded so the sky is the same every time; whole pixels only.

const COUNT := 18
const BIG := 4          # the first few are the larger cross stars
const SKY_H := 120.0    # stars stay in the upper sky

var _stars: Array = []  # [pos, period, phase, big]
var _t := 0.0


func _init(seed_ := 7) -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE
	process_mode = PROCESS_MODE_ALWAYS
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	for i in COUNT:
		var p := Vector2(rng.randi_range(6, 472), roundf(pow(rng.randf(), 1.6) * SKY_H) + 4)
		_stars.append([p, rng.randf_range(2.4, 5.5), rng.randf() * TAU, i < BIG])


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var small := UIFx.tex("title_star")
	var big := UIFx.tex("title_star_big")
	for s in _stars:
		var a: float = 0.5 + 0.5 * sin(_t * TAU / s[1] + s[2])
		var tex: Texture2D = big if s[3] else small
		var off := (tex.get_size() / 2.0).floor()
		var at: Vector2 = s[0]
		draw_texture(tex, at - off, Color(1, 1, 1, 0.25 + 0.75 * a * a))
