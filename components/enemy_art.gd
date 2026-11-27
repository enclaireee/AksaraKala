class_name EnemyArt extends Sprite2D
## Sprite skin for enemies and bosses. Lives under `Body` (a transparent Polygon2D) so everything that already
## tweens body.modulate / scale / position or runs the hit-flash shader keeps working (use_parent_material).
## Sheet: assets/art/enemies/<scene name>.png, 4 rows: 0 idle, 1 walk, 2 telegraph, 3 hurt. Art faces right; flipped to face the player.
##   4 columns (enemies, old boss sheets): telegraph cols 0-1 windup, 2-3 strike; hurt col 0 stun, col 1 flinch.
##   8 columns (boss revamp v9, combat.md): telegraph cols 0-3 windup loop, 4-7 strike once; hurt cols 0-3 stun loop, 4-7 flinch.
## Bosses may add <name>_moves.png (same cell and columns): rows 0 cast, 1 slam, 2 dash, 3 roar, 4 rise, 5 kneel, 6 death,
## and (v9) 7 sig1, 8 sig2. Kneel and death also play while the host is `dead`. `play("slam")` runs a row (BossKit.anim);
## `stop()` hands control back to the automatic frames.
## Phase forms (v9): <name>_p2.png + <name>_p2_moves.png (and _p3) replace the sheets once the host's `phase` reaches 2 (3).

const DIR := "res://assets/art/enemies/"
const IDLE_FPS := 4.0    # per 4 columns: 8-column sheets play twice as fast so a cycle takes as long
const WALK_FPS := 9.0
const STRIKE_FPS := 16.0
const MOVE_ROWS := {"cast": 0, "slam": 1, "dash": 2, "roar": 3, "rise": 4, "kneel": 5, "death": 6, "sig1": 7, "sig2": 8}
const LAST_ROWS := 5   # rows 5 and 6 (kneel, death) show on a dead host

var host: CharacterBody2D
var cell := Vector2i(16, 24)
var cols := 4
var _t := randf() * 4.0
var base_tex: Texture2D
var moves_tex: Texture2D
var _forms: Array = []   # [[base, moves], ...] for phase 1, 2, 3
var _form := 0
var _move := ""
var _move_t := 0.0
var _move_fps := 10.0
var _move_hold := true
var _hb_t := 0.0
var _hb_on := false


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
	var stem := path.trim_suffix(".png")
	for suffix in ["", "_p2", "_p3"]:
		var b: String = stem + suffix + ".png"
		if suffix != "" and not ResourceLoader.exists(b):
			break
		var m: String = stem + suffix + "_moves.png"
		art._forms.append([load(b) as Texture2D, load(m) as Texture2D if ResourceLoader.exists(m) else null])
	art.base_tex = tex
	art.moves_tex = art._forms[0][1]
	var ch := tex.get_height() / 4
	# ponytail: a 9-row moves sheet means the v9 8-column contract; enemies and old boss sheets have 4 columns.
	if art.moves_tex != null and art.moves_tex.get_height() / ch >= 9:
		art.cols = 8
	art.cell = Vector2i(tex.get_width() / art.cols, ch)
	art.texture = tex
	art.hframes = art.cols
	art.vframes = 4
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
func play(anim_name: String, fps := 10.0, hold := true) -> bool:
	if moves_tex == null or not MOVE_ROWS.has(anim_name) or (int(MOVE_ROWS[anim_name]) + 1) * cell.y > moves_tex.get_height():
		return false
	_move = anim_name
	_move_t = 0.0
	_move_fps = fps
	_move_hold = hold
	return true


func stop() -> void:
	_move = ""
	if texture != base_tex and base_tex != null:
		texture = base_tex
		vframes = 4


## Swap to the sheets for the host's phase; a roar marks the change when nothing else is playing.
func _update_form() -> void:
	var ph: Variant = host.get("phase")
	if _forms.size() < 2 or not (ph is int):
		return
	var want := clampi(int(ph) - 1, 0, _forms.size() - 1)
	if want <= _form:   # forms never go back
		return
	_form = want
	var on_moves := texture == moves_tex and moves_tex != null
	base_tex = _forms[want][0]
	moves_tex = _forms[want][1] if _forms[want][1] != null else moves_tex
	texture = moves_tex if on_moves else base_tex
	if _move == "" and not bool(host.get("dead")):
		play("roar", 10.0, false)


func _process(delta: float) -> void:
	if host == null or not is_instance_valid(host):
		return
	var body_node := get_parent() as CanvasItem
	if body_node == null:
		return
	_t += delta
	_update_form()
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
	var half := cols / 2
	var speed := cols / 4.0
	var row := 0
	var col := 0
	var raw_hb: Variant = host.get("attack_hitbox")
	var hb: Area2D = raw_hb as Area2D if is_instance_valid(raw_hb) else null
	var striking := hb != null and hb.monitoring
	if striking and not _hb_on:
		_hb_t = 0.0
	_hb_on = striking
	_hb_t += delta
	var sh: float = float(host.get("since_hit"))
	if _move != "" and (not is_dead or int(MOVE_ROWS[_move]) >= LAST_ROWS) and m.b <= m.r + 0.12:
		_move_t += delta * _move_fps
		var mf := int(_move_t)
		if mf >= cols:
			if _move_hold:
				mf = cols - 1
			else:
				stop()
		if _move != "":
			if texture != moves_tex:
				texture = moves_tex
				vframes = moves_tex.get_height() / cell.y
			frame_coords = Vector2i(mf, int(MOVE_ROWS[_move]))
			return
	elif _move != "":
		stop()   # stunned or dead: the pose is over
	if is_dead:
		row = 3
	elif m.b > m.r + 0.12:                      # stagger/stun tint
		row = 3
		col = int(_t * 6.0) % half if cols == 8 else 0
	elif m.r > m.g + 0.3 and m.g < 0.7:          # telegraph tint (red)
		row = 2
		if not striking:
			col = int(_t * 8.0) % half
		elif cols == 8:
			col = half + mini(int(_hb_t * STRIKE_FPS), half - 1)
		else:
			col = 2 + int(_t * 8.0) % 2
	elif sh < 0.16:
		row = 3
		col = half + mini(int(sh / 0.16 * half), half - 1) if cols == 8 else 1
	elif v.length() > 8.0:
		row = 1
		col = int(_t * WALK_FPS * speed) % cols
	else:
		col = int(_t * IDLE_FPS * speed) % cols
	frame_coords = Vector2i(col, row)
