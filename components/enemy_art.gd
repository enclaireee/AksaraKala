class_name EnemyArt extends Sprite2D
## Sprite skin for enemies and bosses. Lives under `Body` (a transparent Polygon2D) so everything that already
## tweens body.modulate / scale / position or runs the hit-flash shader keeps working (use_parent_material).
## Sheet: assets/art/enemies/<scene name>.png, 4 columns x 4 rows:
##   row 0 idle, row 1 walk, row 2 telegraph (cols 0-1 windup, 2-3 strike), row 3 hurt. Art faces right; flipped to face the player.
## Bosses may add assets/art/enemies/<name>_moves.png (same cell size, 4x4, tools/gen_boss_moves.py): row 0 cast, 1 slam,
## 2 dash, 3 roar. `play("slam")` runs a row (BossKit.anim); `stop()` hands control back to the automatic frames.

const DIR := "res://assets/art/enemies/"
const IDLE_FPS := 4.0
const WALK_FPS := 9.0
const MOVE_ROWS := {"cast": 0, "slam": 1, "dash": 2, "roar": 3}

var host: CharacterBody2D
var cell := Vector2i(16, 24)
var _t := randf() * 4.0
var base_tex: Texture2D
var moves_tex: Texture2D
var _move := ""
var _move_t := 0.0
var _move_fps := 10.0
var _move_hold := true


static func attach(e: CharacterBody2D) -> void:
	var path := _find(e)
	if path == "":
		return
	var tex := load(path) as Texture2D
	if tex == null:
		return
	var body_node := e.get_node_or_null("Body") as Polygon2D
	if body_node == null:
		return
	var art := EnemyArt.new()
	art.host = e
	art.texture = tex
	art.base_tex = tex
	var mp := path.trim_suffix(".png") + "_moves.png"
	if ResourceLoader.exists(mp):
		art.moves_tex = load(mp) as Texture2D
	art.hframes = 4
	art.vframes = 4
	art.cell = Vector2i(tex.get_width() / 4, tex.get_height() / 4)
	art.centered = false
	art.offset = Vector2(-art.cell.x / 2.0, -art.cell.y + 1)
	art.use_parent_material = true
	art.name = "Art"
	body_node.color.a = 0.0
	body_node.add_child(art)


static func _find(e: Node) -> String:
	var n: String = e.scene_file_path.get_file().get_basename()
	var k: String = str(e.get("kind"))
	var cands: Array[String] = [n, k, n.trim_suffix("_elite"), n.trim_suffix("_tua")]
	for cand: String in cands:
		if cand == "":
			continue
		var p: String = DIR + cand + ".png"
		if ResourceLoader.exists(p):
			return p
	return ""


## Run a row of the moves sheet. hold: stay on the last frame until stop(); otherwise return to auto frames after it.
func play(anim_name: String, fps := 10.0, hold := true) -> void:
	if moves_tex == null or not MOVE_ROWS.has(anim_name):
		return
	_move = anim_name
	_move_t = 0.0
	_move_fps = fps
	_move_hold = hold


func stop() -> void:
	_move = ""
	if texture != base_tex and base_tex != null:
		texture = base_tex


func _process(delta: float) -> void:
	if host == null or not is_instance_valid(host):
		return
	var body_node := get_parent() as CanvasItem
	if body_node == null:
		return
	_t += delta
	self_modulate = body_node.self_modulate
	var v: Vector2 = host.velocity
	var is_dead: bool = bool(host.get("dead"))
	var raw_tgt: Variant = host.get("target")
	var tgt: Node2D = raw_tgt as Node2D if is_instance_valid(raw_tgt) else null
	if absf(v.x) > 6.0:
		flip_h = v.x < 0.0
	elif tgt != null and not is_dead:
		var dx := tgt.global_position.x - host.global_position.x
		if absf(dx) > 3.0:
			flip_h = dx < 0.0
	var m: Color = body_node.modulate
	var row := 0
	var col := 0
	var raw_hb: Variant = host.get("attack_hitbox")
	var hb: Area2D = raw_hb as Area2D if is_instance_valid(raw_hb) else null
	var sh: float = float(host.get("since_hit"))
	if _move != "" and not is_dead and m.b <= m.r + 0.12:
		_move_t += delta * _move_fps
		var mf := int(_move_t)
		if mf >= 4:
			if _move_hold:
				mf = 3
			else:
				stop()
		if _move != "":
			if texture != moves_tex:
				texture = moves_tex
			frame_coords = Vector2i(mf, int(MOVE_ROWS[_move]))
			return
	elif _move != "":
		stop()   # stunned or dead: the pose is over
	if is_dead:
		row = 3
		col = 0
	elif m.b > m.r + 0.12:                      # stagger/stun tint
		row = 3
		col = 0
	elif m.r > m.g + 0.3 and m.g < 0.7:          # telegraph tint (red)
		row = 2
		col = 0 if hb == null or not hb.monitoring else 2
		col += int(_t * 8.0) % 2
	elif sh < 0.16:
		row = 3
		col = 1
	elif v.length() > 8.0:
		row = 1
		col = int(_t * WALK_FPS) % 4
	else:
		col = int(_t * IDLE_FPS) % 4
	frame_coords = Vector2i(col, row)
