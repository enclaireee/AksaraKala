class_name Compass extends Control
## Top-centre compass ribbon (ui.md 2): scrolls with the hero's heading, cardinals every 90 degrees, and the
## quest objective as a gold diamond with its distance, so a target is findable without opening the map.

const GOLD := Color("F2D488")
const W := 150.0
const H := 11.0
const SPAN := 180.0   # degrees visible across the ribbon
const TILE_M := 1.0   # one game tile reads as one metre

var _heading := 0.0   # degrees clockwise from north (up)
var _font: Font


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(W, H + 10)
	position = Vector2((480.0 - W) / 2.0, 22)
	_font = get_theme_default_font()


func _process(delta: float) -> void:
	var pl := get_tree().get_first_node_in_group("player")
	visible = pl != null and not get_tree().paused and get_tree().current_scene is Zone
	if not visible:
		return
	var v: Vector2 = pl.velocity if "velocity" in pl else Vector2.ZERO
	if v.length() > 20.0:   # keep the last heading while standing still
		_heading = lerp_angle(deg_to_rad(_heading), atan2(v.x, -v.y), clampf(delta * 8.0, 0.0, 1.0))
		_heading = rad_to_deg(_heading)
	queue_redraw()


func _x_for(bearing: float) -> float:
	var rel := wrapf(bearing - _heading, -180.0, 180.0)
	return W / 2.0 + rel / SPAN * W


func _label_for(deg: int) -> String:
	var id := TranslationServer.get_locale().begins_with("id")
	match deg:
		0: return "N" if not id else "U"
		90: return "E" if not id else "T"
		180: return "S"
		270: return "W" if not id else "B"
	return ""


func _draw() -> void:
	draw_rect(Rect2(0, 0, W, H), Color(0.07, 0.05, 0.04, 0.72))
	draw_rect(Rect2(0, 0, W, H), Color(GOLD, 0.55), false, 1.0)
	for d in range(0, 360, 15):
		var x := _x_for(float(d))
		if x < 1.0 or x > W - 1.0:
			continue
		if d % 90 == 0:
			var t := _label_for(d)
			var w := _font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x
			draw_string(_font, Vector2(x - w / 2.0, 9), t, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, GOLD if d == 0 else Color.WHITE)
		else:
			draw_line(Vector2(x, 3), Vector2(x, H - 3 if d % 45 == 0 else 6), Color(1, 1, 1, 0.45), 1.0)
	draw_colored_polygon(PackedVector2Array([Vector2(W / 2 - 3, -2), Vector2(W / 2 + 3, -2), Vector2(W / 2, 2)]), GOLD)
	var hud := get_parent()
	var pl := get_tree().get_first_node_in_group("player") as Node2D
	if hud == null or pl == null or not hud.has_method("target_pos"):
		return
	var tp: Variant = hud.target_pos()
	if not (tp is Vector2):
		return
	var d: Vector2 = tp - pl.global_position
	var bearing := rad_to_deg(atan2(d.x, -d.y))
	var x := clampf(_x_for(bearing), 5.0, W - 5.0)
	var c := Vector2(x, H / 2.0)
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, -4), c + Vector2(4, 0), c + Vector2(0, 4), c + Vector2(-4, 0)]), Color.BLACK)
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, -3), c + Vector2(3, 0), c + Vector2(0, 3), c + Vector2(-3, 0)]), GOLD)
	var dist := "%d m" % roundi(d.length() / float(Zone.TILE) * TILE_M)
	var dw := _font.get_string_size(dist, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x
	draw_string(_font, Vector2(W / 2.0 - dw / 2.0, H + 9), dist, HORIZONTAL_ALIGNMENT_CENTER, -1, 8, GOLD)
