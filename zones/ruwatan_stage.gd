class_name RuwatanStageDecor extends Node2D
## Visual details for the Ruwatan wayang stage in Desa Purwa:
## - Large backlit Kelir (shadow screen) with puppet silhouettes and blencong oil lamp
## - Gamelan ensemble (Gong Ageng, Saron, Kendang) with sitting musicians (niyaga)
## - Sitting village children on woven mats watching the wayang
## - During the raid (flag:mq0_d8): Nameless Hunter and shadow raiders materializing on stage
## - After the raid (flag:beat_raid): Burned, charred stage with smoke embers and overturned instruments

const SCREEN_POS := Vector2(1192, 194)
const GONG_POS := Vector2(1136, 212)
const SARON_POS := Vector2(1248, 214)
const MAT_LEFT := Vector2(1174, 232)
const MAT_RIGHT := Vector2(1218, 234)

var _t := 0.0
var _game: Node


func _ready() -> void:
	z_index = 0
	y_sort_enabled = true
	_game = get_node_or_null("/root/Game")
	if _game:
		_game.changed.connect(queue_redraw)
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var raid_done := false
	var raid_active := false
	if _game:
		raid_done = _game.has_flag("beat_raid")
		raid_active = _game.has_flag("mq0_d8") and not raid_done

	_draw_kelir_screen(raid_done, raid_active)
	_draw_gamelan(raid_done)
	_draw_audience(raid_done, raid_active)
	if raid_active:
		_draw_attackers()


## Draws the wayang kelir (white shadow screen) on the stage.
func _draw_kelir_screen(burned: bool, chaos: bool) -> void:
	var w := 76.0
	var h := 32.0
	var rect := Rect2(SCREEN_POS.x - w * 0.5, SCREEN_POS.y - h * 0.5, w, h)

	# Teak wooden frame (posts and crossbeams)
	var wood_col := Color(0.24, 0.16, 0.11) if not burned else Color(0.12, 0.08, 0.06)
	var gold_col := Color(0.78, 0.62, 0.28) if not burned else Color(0.22, 0.18, 0.12)
	# Left and right carved vertical posts
	draw_rect(Rect2(rect.position.x - 4, rect.position.y - 6, 5, h + 10), wood_col)
	draw_rect(Rect2(rect.end.x - 1, rect.position.y - 6, 5, h + 10), wood_col)
	# Post finials (carved crowns)
	draw_rect(Rect2(rect.position.x - 5, rect.position.y - 9, 7, 4), gold_col)
	draw_rect(Rect2(rect.end.x - 2, rect.position.y - 9, 7, 4), gold_col)
	# Top and bottom horizontal frame beams
	draw_rect(Rect2(rect.position.x - 3, rect.position.y - 3, w + 6, 4), wood_col)
	draw_rect(Rect2(rect.position.x - 3, rect.end.y - 1, w + 6, 4), wood_col)

	if not burned:
		# Stretched white fabric (kelir)
		var cloth_col := Color(0.96, 0.94, 0.88)
		draw_rect(rect, cloth_col)

		# Warm golden backlight glow through fabric
		var flicker := 0.85 + 0.15 * sin(_t * 7.3)
		if chaos:
			flicker = 0.5 + 0.5 * sin(_t * 19.0)
		var glow_col := Color(1.0, 0.86, 0.52, 0.38 * flicker)
		draw_circle(SCREEN_POS, 26.0, glow_col)
		draw_circle(SCREEN_POS, 14.0, Color(1.0, 0.95, 0.75, 0.45 * flicker))

		# Wayang puppet shadows on the screen:
		# Gunungan (Kayon / Tree of Life) shadow in the center
		var g_x := SCREEN_POS.x + sin(_t * 1.2) * 1.5
		var g_pts := PackedVector2Array([
			Vector2(g_x, SCREEN_POS.y - 13),
			Vector2(g_x + 8, SCREEN_POS.y + 4),
			Vector2(g_x + 5, SCREEN_POS.y + 13),
			Vector2(g_x - 5, SCREEN_POS.y + 13),
			Vector2(g_x - 8, SCREEN_POS.y + 4)
		])
		draw_colored_polygon(g_pts, Color(0.15, 0.10, 0.08, 0.72))

		# Semar shadow puppet on the left
		var s_x := SCREEN_POS.x - 20.0 + sin(_t * 2.5) * 1.0
		var s_pts := PackedVector2Array([
			Vector2(s_x, SCREEN_POS.y - 6),
			Vector2(s_x + 5, SCREEN_POS.y),
			Vector2(s_x + 6, SCREEN_POS.y + 12),
			Vector2(s_x - 6, SCREEN_POS.y + 12),
			Vector2(s_x - 4, SCREEN_POS.y)
		])
		draw_colored_polygon(s_pts, Color(0.18, 0.12, 0.10, 0.65))

		# Knight / Hero shadow puppet on the right
		var k_x := SCREEN_POS.x + 20.0 + cos(_t * 2.1) * 1.2
		var k_pts := PackedVector2Array([
			Vector2(k_x, SCREEN_POS.y - 8),
			Vector2(k_x + 3, SCREEN_POS.y - 1),
			Vector2(k_x + 4, SCREEN_POS.y + 12),
			Vector2(k_x - 3, SCREEN_POS.y + 12),
			Vector2(k_x - 4, SCREEN_POS.y)
		])
		draw_colored_polygon(k_pts, Color(0.18, 0.12, 0.10, 0.65))

		# Banana trunk log (gedebog) where puppets stand
		draw_rect(Rect2(rect.position.x - 1, rect.end.y + 2, w + 2, 5), Color(0.32, 0.48, 0.22))

		# Blencong hanging oil lamp above screen
		var lamp_y := SCREEN_POS.y - 14.0
		draw_line(Vector2(SCREEN_POS.x, rect.position.y - 3), Vector2(SCREEN_POS.x, lamp_y), Color(0.4, 0.35, 0.25), 1.0)
		draw_rect(Rect2(SCREEN_POS.x - 3, lamp_y, 6, 4), Color(0.78, 0.62, 0.28))
		draw_circle(Vector2(SCREEN_POS.x, lamp_y - 2), 2.5 + 0.8 * sin(_t * 11.0), Color(1.0, 0.9, 0.4))
	else:
		# Burned, torn cloth
		draw_rect(rect, Color(0.20, 0.16, 0.14))
		# Jagged tear in the center showing dark background
		var tear := PackedVector2Array([
			Vector2(SCREEN_POS.x - 12, SCREEN_POS.y - 14),
			Vector2(SCREEN_POS.x + 4, SCREEN_POS.y - 2),
			Vector2(SCREEN_POS.x - 6, SCREEN_POS.y + 8),
			Vector2(SCREEN_POS.x + 14, SCREEN_POS.y + 14),
			Vector2(SCREEN_POS.x - 18, SCREEN_POS.y + 14)
		])
		draw_colored_polygon(tear, Color(0.08, 0.06, 0.07))
		# Charred banana trunk
		draw_rect(Rect2(rect.position.x - 1, rect.end.y + 2, w + 2, 4), Color(0.16, 0.14, 0.12))
		# Smoldering ember dots
		for i in 6:
			var ex := SCREEN_POS.x - 24.0 + float(i * 10)
			var ey := rect.end.y + sin(_t * 4.0 + float(i)) * 2.0
			var spark_a := 0.4 + 0.5 * sin(_t * 5.0 + float(i) * 1.8)
			draw_circle(Vector2(ex, ey), 1.2, Color(1.0, 0.45, 0.15, spark_a))


## Draws the gamelan ensemble (Gong Ageng on left, Saron on right) with sitting musicians.
func _draw_gamelan(burned: bool) -> void:
	# --- 1. GONG AGENG (Left side) ---
	var gx := GONG_POS.x
	var gy := GONG_POS.y

	if not burned:
		# Wooden arch (gayor) with dragon finials
		draw_rect(Rect2(gx - 10, gy - 16, 3, 20), Color(0.28, 0.16, 0.10))
		draw_rect(Rect2(gx + 8, gy - 16, 3, 20), Color(0.28, 0.16, 0.10))
		draw_rect(Rect2(gx - 12, gy - 18, 25, 4), Color(0.35, 0.20, 0.12))
		# Gold carvings on arch
		draw_rect(Rect2(gx - 13, gy - 20, 4, 4), Color(0.85, 0.70, 0.25))
		draw_rect(Rect2(gx + 10, gy - 20, 4, 4), Color(0.85, 0.70, 0.25))
		# Hanging ropes
		draw_line(Vector2(gx - 4, gy - 14), Vector2(gx - 4, gy - 7), Color(0.7, 0.6, 0.4), 1.0)
		draw_line(Vector2(gx + 4, gy - 14), Vector2(gx + 4, gy - 7), Color(0.7, 0.6, 0.4), 1.0)
		# Large bronze gong disc
		draw_circle(Vector2(gx, gy - 5), 8.0, Color(0.55, 0.42, 0.22))
		draw_circle(Vector2(gx, gy - 5), 6.5, Color(0.68, 0.54, 0.28))
		# Raised center boss (pencon)
		draw_circle(Vector2(gx, gy - 5), 2.5, Color(0.88, 0.72, 0.35))

		# Kendang (barrel drum) lying horizontally nearby
		draw_rect(Rect2(gx + 12, gy - 3, 10, 6), Color(0.42, 0.26, 0.16))
		draw_rect(Rect2(gx + 11, gy - 4, 2, 8), Color(0.92, 0.88, 0.78))
		draw_rect(Rect2(gx + 21, gy - 3, 2, 6), Color(0.92, 0.88, 0.78))

		# Sitting Gong Musician (Niyaga)
		var mx := gx - 2.0
		var my := gy + 8.0
		# Sarong / crossed legs
		draw_rect(Rect2(mx - 6, my + 1, 12, 5), Color(0.32, 0.22, 0.45))
		# Torso / beskap
		draw_rect(Rect2(mx - 4, my - 6, 8, 8), Color(0.18, 0.16, 0.24))
		# Head & Blangkon
		draw_circle(Vector2(mx, my - 8), 3.0, Color(0.78, 0.58, 0.42))
		draw_rect(Rect2(mx - 3, my - 11, 7, 3), Color(0.38, 0.25, 0.18))
		# Arm holding gong mallet (taps subtly)
		var mallet_y := my - 4.0 + sin(_t * 3.0) * 1.5
		draw_line(Vector2(mx + 2, my - 2), Vector2(mx + 7, mallet_y), Color(0.78, 0.58, 0.42), 1.5)
		draw_circle(Vector2(mx + 8, mallet_y), 1.8, Color(0.85, 0.3, 0.3))
	else:
		# Overturned, charred gong
		draw_rect(Rect2(gx - 10, gy - 6, 18, 3), Color(0.18, 0.12, 0.08))
		draw_circle(Vector2(gx + 2, gy - 2), 7.5, Color(0.28, 0.24, 0.20))
		draw_circle(Vector2(gx + 2, gy - 2), 2.0, Color(0.38, 0.32, 0.26))

	# --- 2. SARON / METALLOPHONE (Right side) ---
	var sx := SARON_POS.x
	var sy := SARON_POS.y

	if not burned:
		# Wooden trough resonator (plangkan)
		draw_rect(Rect2(sx - 9, sy - 2, 18, 6), Color(0.42, 0.22, 0.12))
		# Bronze keys (bilah)
		for i in 6:
			var kx := sx - 8.0 + float(i * 2.8)
			var kh := 5.0 - float(i) * 0.4
			draw_rect(Rect2(kx, sy - 4, 2, kh), Color(0.85, 0.72, 0.35))

		# Sitting Saron Musician
		var smx := sx
		var smy := sy + 8.0
		# Crossed legs in batik sarong
		draw_rect(Rect2(smx - 5, smy + 1, 11, 5), Color(0.48, 0.32, 0.20))
		# Torso
		draw_rect(Rect2(smx - 4, smy - 6, 8, 8), Color(0.22, 0.26, 0.35))
		# Head & Blangkon
		draw_circle(Vector2(smx, smy - 8), 3.0, Color(0.78, 0.58, 0.42))
		draw_rect(Rect2(smx - 3, smy - 11, 7, 3), Color(0.35, 0.22, 0.15))
		# Mallet tapping the keys
		var tap_y := sy - 5.0 + abs(sin(_t * 5.0)) * 2.0
		draw_line(Vector2(smx - 1, smy - 2), Vector2(smx - 3, tap_y), Color(0.78, 0.58, 0.42), 1.2)
		draw_rect(Rect2(smx - 5, tap_y - 1, 3, 2), Color(0.65, 0.45, 0.25))
	else:
		# Scattered bronze keys and charred frame
		draw_rect(Rect2(sx - 8, sy - 1, 16, 4), Color(0.18, 0.14, 0.12))
		draw_rect(Rect2(sx - 6, sy + 3, 3, 2), Color(0.45, 0.38, 0.25))
		draw_rect(Rect2(sx + 3, sy + 4, 3, 2), Color(0.45, 0.38, 0.25))


## Draws woven sitting mats and children watching the show.
func _draw_audience(burned: bool, chaos: bool) -> void:
	# Mat 1 (Left of center)
	_draw_mat_and_child(MAT_LEFT, burned, chaos, 0)
	# Mat 2 (Right of center, next to Laras's spot)
	_draw_mat_and_child(MAT_RIGHT, burned, chaos, 1)


func _draw_mat_and_child(pos: Vector2, burned: bool, chaos: bool, idx: int) -> void:
	var mat_w := 20.0
	var mat_h := 10.0
	var mat_col := Color(0.82, 0.74, 0.54) if not burned else Color(0.18, 0.15, 0.13)
	draw_rect(Rect2(pos.x - mat_w * 0.5, pos.y - mat_h * 0.5, mat_w, mat_h), mat_col)
	if not burned:
		# Mat weave texture lines
		draw_line(Vector2(pos.x - 8, pos.y), Vector2(pos.x + 8, pos.y), Color(0.72, 0.64, 0.44), 1.0)
		draw_line(Vector2(pos.x, pos.y - 4), Vector2(pos.x, pos.y + 4), Color(0.72, 0.64, 0.44), 1.0)

		# Village child sitting watching the wayang
		var cx := pos.x
		var cy := pos.y - 1.0
		var breath := sin(_t * 2.5 + float(idx) * 1.3) * 0.5
		if not chaos:
			# Sitting crossed legs
			var sarong_col := Color(0.65, 0.28, 0.25) if idx == 0 else Color(0.25, 0.55, 0.45)
			draw_rect(Rect2(cx - 4, cy + 1, 8, 4), sarong_col)
			# Small child torso
			draw_rect(Rect2(cx - 3, cy - 4 + breath, 6, 6), Color(0.88, 0.82, 0.70))
			# Head looking up at the kelir
			draw_circle(Vector2(cx, cy - 7 + breath), 2.5, Color(0.78, 0.58, 0.42))
			# Ikat / headband
			draw_rect(Rect2(cx - 3, cy - 9 + breath, 6, 2), Color(0.35, 0.20, 0.15))
		else:
			# In chaos: child covering eyes / shrinking back
			draw_rect(Rect2(cx - 4, cy + 1, 8, 4), Color(0.45, 0.20, 0.20))
			draw_rect(Rect2(cx - 3, cy - 3, 6, 5), Color(0.70, 0.65, 0.60))
			draw_circle(Vector2(cx, cy - 5), 2.5, Color(0.78, 0.58, 0.42))
			# Hands over head
			draw_circle(Vector2(cx - 2, cy - 7), 1.2, Color(0.78, 0.58, 0.42))
			draw_circle(Vector2(cx + 2, cy - 7), 1.2, Color(0.78, 0.58, 0.42))


## During raid (flag:mq0_d8,!flag:beat_raid): draws the looming Nameless Hunter and shadows on stage.
func _draw_attackers() -> void:
	var hx := 1208.0  # Right behind Laras (at row 13 col 75)
	var hy := 204.0

	# Swirling shadow smoke under the Hunter
	for i in 8:
		var ang := _t * 3.0 + float(i) * 0.8
		var rad := 8.0 + 4.0 * sin(_t * 4.0 + float(i))
		draw_circle(Vector2(hx + cos(ang) * rad, hy + 12.0 + sin(ang) * 3.0), 3.0, Color(0.04, 0.03, 0.06, 0.45))

	# The Nameless Hunter towering silhouette
	# Flowing dark cloak
	var cloak := PackedVector2Array([
		Vector2(hx - 8, hy + 14),
		Vector2(hx - 12, hy + 24),
		Vector2(hx + 12, hy + 24),
		Vector2(hx + 8, hy + 14)
	])
	draw_colored_polygon(cloak, Color(0.08, 0.06, 0.10))
	# Torso
	draw_rect(Rect2(hx - 6, hy + 4, 12, 11), Color(0.12, 0.09, 0.15))
	# Head
	draw_circle(Vector2(hx, hy), 4.5, Color(0.10, 0.08, 0.12))
	# Blank white mask (the eerie featureless white mask)
	draw_circle(Vector2(hx, hy + 0.5), 3.2, Color(0.92, 0.90, 0.86))
	# Reaching arm toward Laras
	draw_line(Vector2(hx, hy + 6), Vector2(hx + 6, hy + 16), Color(0.12, 0.09, 0.15), 2.0)

	# Shadow raider flanker on the left
	var r1_x := 1184.0
	var r1_y := 214.0
	draw_circle(Vector2(r1_x, r1_y - 6), 3.0, Color(0.05, 0.04, 0.07))
	draw_rect(Rect2(r1_x - 4, r1_y - 3, 8, 12), Color(0.05, 0.04, 0.07))
	draw_circle(Vector2(r1_x, r1_y - 6), 2.0, Color(0.85, 0.82, 0.78)) # mask

	# Shadow raider flanker on the right
	var r2_x := 1234.0
	var r2_y := 214.0
	draw_circle(Vector2(r2_x, r2_y - 6), 3.0, Color(0.05, 0.04, 0.07))
	draw_rect(Rect2(r2_x - 4, r2_y - 3, 8, 12), Color(0.05, 0.04, 0.07))
	draw_circle(Vector2(r2_x, r2_y - 6), 2.0, Color(0.85, 0.82, 0.78)) # mask
