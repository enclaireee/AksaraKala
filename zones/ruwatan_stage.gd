class_name RuwatanStageDecor extends Node2D
## The Ruwatan wayang stage in Desa Purwa, built from pixel sprites (tools/gen_cutscene_art.py, assets/art/cutscene/):
## - carved kelir frame, backlit cloth, blencong lamp and wayang puppets (gunungan, Semar, Arjuna)
## - gamelan (gong ageng, saron, kendang) with seated niyaga, and two children on mats
## - raid (flag:mq0_d8, not beat_raid): ink bleeds over the cloth, the puppets turn to Buto, the niyaga flee, the children
##   cower, the Nameless Hunter and two torch-bearing raiders step onto the stage
## - after the raid (flag:beat_raid): charred frame, torn cloth, fallen instruments, embers
## Rebuilt whenever Game state changes; _process only steps frame animation.

const ART := "res://assets/art/cutscene/"
const SCREEN_POS := Vector2(1192, 194)   # centre of the cloth
const GONG_POS := Vector2(1136, 212)
const SARON_POS := Vector2(1248, 214)
const MAT_LEFT := Vector2(1174, 232)
const MAT_RIGHT := Vector2(1218, 234)
const CLOTH := Rect2(6, 10, 80, 44)      # cloth opening inside kelir_frame.png

var _t := 0.0
var _game: Node
var _anim: Array = []                    # [sprite, frame_w, frames, fps, phase]
var _glow: Sprite2D
var _lamp: Sprite2D
var _puppets: Array = []                 # [sprite, base_pos, speed, amp]
var _embers: Array = []
var _state_key := -1
var _chaos := false
var _burned := false
var _tex := {}


func _ready() -> void:
	z_index = 0
	_game = get_node_or_null("/root/Game")
	if _game:
		_game.changed.connect(_rebuild)
	_rebuild()


func _process(delta: float) -> void:
	_t += delta
	for a in _anim:
		var s: Sprite2D = a[0]
		var f := int(_t * a[3] + a[4]) % int(a[2])
		s.region_rect = Rect2(f * a[1], 0, a[1], s.texture.get_height())
	for p in _puppets:
		var s: Sprite2D = p[0]
		var amp: float = p[3] * (3.0 if _chaos else 1.0)
		s.position = p[1] + Vector2(sin(_t * p[2]) * amp, 0.0)
	if _glow:
		var fl := 0.85 + 0.15 * sin(_t * 7.3)
		if _chaos:
			fl = 0.5 + 0.5 * sin(_t * 19.0)
		_glow.modulate.a = clampf(fl, 0.0, 1.0)
	for i in _embers.size():
		var e: Sprite2D = _embers[i]
		e.modulate.a = 0.35 + 0.65 * absf(sin(_t * 4.0 + float(i) * 1.7))
		e.position.y = e.get_meta("y0") - fmod(_t * 5.0 + float(i) * 3.0, 9.0)


func _t2(name: String) -> Texture2D:
	if not _tex.has(name):
		_tex[name] = load(ART + name + ".png")
	return _tex[name]


## Sprite whose origin is its bottom-centre (the feet), so positions read like the world props.
func _spr(parent: Node, name: String, feet: Vector2, frames := 1, fps := 0.0, phase := 0.0, flip := false) -> Sprite2D:
	var tex := _t2(name)
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = false
	var fw := tex.get_width() / frames
	s.offset = Vector2(-fw / 2.0, -tex.get_height())
	s.position = feet.round()
	s.flip_h = flip
	if frames > 1:
		s.region_enabled = true
		s.region_rect = Rect2(0, 0, fw, tex.get_height())
		if fps > 0.0:
			_anim.append([s, fw, frames, fps, phase])
	parent.add_child(s)
	return s


func _topleft(parent: Node, name: String, pos: Vector2) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = _t2(name)
	s.centered = false
	s.position = pos.round()
	parent.add_child(s)
	return s


func _rebuild() -> void:
	var state: bool = _game != null and _game.has_flag("beat_raid")
	var raid: bool = _game != null and _game.has_flag("mq0_d8")
	var key := int(state) * 2 + int(raid)
	if key == _state_key and get_child_count() > 0:
		return   # `changed` also fires for HP and ilmu; only rebuild on a stage-state change
	_state_key = key
	for c in get_children():
		c.queue_free()
	_anim.clear()
	_puppets.clear()
	_embers.clear()
	_glow = null
	_lamp = null
	_burned = _game != null and _game.has_flag("beat_raid")
	_chaos = _game != null and _game.has_flag("mq0_d8") and not _burned
	_build_screen()
	_build_gamelan()
	_build_audience()
	if _chaos:
		_build_raiders()


func _build_screen() -> void:
	var origin := SCREEN_POS - CLOTH.position - CLOTH.size * 0.5   # kelir_frame.png top-left in the world
	var suffix := "_burned" if _burned else ""
	_topleft(self, "kelir_cloth" + suffix, origin + CLOTH.position)
	if not _burned:
		_glow = _topleft(self, "kelir_glow", origin + CLOTH.position)
		# Puppets live in a clipped box so none poke past the cloth
		var clip := Control.new()
		clip.clip_contents = true
		clip.position = (origin + CLOTH.position).round()
		clip.size = CLOTH.size
		clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(clip)
		var floor_y := CLOTH.size.y - 1.0
		var cx := CLOTH.size.x * 0.5
		var cast := [["puppet_semar", cx - 24.0, 2.5, 1.0],
			["puppet_gunungan", cx, 1.2, 1.2],
			["puppet_buto" if _chaos else "puppet_arjuna", cx + 24.0, 2.1, 1.2]]
		for c in cast:
			var s := _spr(clip, c[0], Vector2(c[1], floor_y))
			s.self_modulate = Color(1, 1, 1, 0.92)
			_puppets.append([s, s.position, c[2], c[3]])
		if _chaos:
			var ink := _topleft(clip, "ink_creep", Vector2.ZERO)
			ink.modulate.a = 0.9
	_topleft(self, "kelir_frame" + suffix, origin)
	if _burned:
		for i in 7:
			var e := _spr(self, "ember", origin + Vector2(10.0 + float(i) * 12.0, 66.0), 3, 0.0)
			e.region_rect = Rect2((i % 3) * 3, 0, 3, 3)
			e.set_meta("y0", e.position.y)
			_embers.append(e)
	else:
		_lamp = _spr(self, "blencong", Vector2(SCREEN_POS.x, origin.y + 18.0), 3, 7.0, 0.0)


func _build_gamelan() -> void:
	var sx := SARON_POS.x
	var sy := SARON_POS.y
	var gx := GONG_POS.x
	var gy := GONG_POS.y
	if _burned:
		var g := _spr(self, "gong_ageng_burned", Vector2(gx, gy + 8.0))
		g.rotation_degrees = 78.0
		var s := _spr(self, "saron_burned", Vector2(sx, sy + 8.0))
		s.rotation_degrees = -10.0
		var k := _spr(self, "kendang_burned", Vector2(gx + 30.0, gy + 14.0))
		k.rotation_degrees = 64.0
		return
	_spr(self, "gong_ageng", Vector2(gx, gy + 8.0))
	if not _chaos:
		_spr(self, "niyaga_gong", Vector2(gx + 1.0, gy + 20.0), 3, 1.6, 0.0)
		_spr(self, "niyaga_saron", Vector2(sx, sy + 4.0), 3, 2.4, 1.0)
		_spr(self, "niyaga_kendang", Vector2(gx + 38.0, gy + 16.0))
	_spr(self, "saron", Vector2(sx, sy + 8.0))
	_spr(self, "kendang", Vector2(gx + 28.0, gy + 16.0))


func _build_audience() -> void:
	var pairs := [[MAT_LEFT, "child_a"], [MAT_RIGHT, "child_b"]]
	for i in pairs.size():
		var pos: Vector2 = pairs[i][0]
		_spr(self, "mat_burned" if _burned else "mat", pos + Vector2(0, 6))
		if _burned:
			continue
		var kid := _spr(self, pairs[i][1], pos + Vector2(0, 5), 3)
		if _chaos:
			kid.region_rect = Rect2(28, 0, 14, kid.texture.get_height())   # huddled, hands over head
		else:
			_anim.append([kid, 14, 2, 1.4, float(i) * 0.5])   # breathing: the 2 calm frames


## Nameless Hunter (his enemy sheet, idle row) looming behind Laras, plus two torch raiders flanking the stage.
func _build_raiders() -> void:
	var hunter := Sprite2D.new()
	hunter.texture = load("res://assets/art/enemies/nameless_hunter.png")
	hunter.centered = false
	hunter.region_enabled = true
	hunter.region_rect = Rect2(0, 0, 28, 44)
	hunter.offset = Vector2(-14, -44)
	hunter.position = Vector2(1208, 226)
	add_child(hunter)
	_anim.append([hunter, 28, 4, 2.0, 0.0])
	_spr(self, "torch_raider", Vector2(1182, 228), 4, 8.0, 0.0)
	_spr(self, "torch_raider", Vector2(1236, 228), 4, 8.0, 2.0, true)
