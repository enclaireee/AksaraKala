extends Control
## Wayang prologue between New Game and the class cards (quests.md MQ0). PROLOGUE_1..2 in dialogue.csv:
## Story v4, 2 narration cards of an ordinary day (script.md 4; the raid is the `raid` beat now)
## (codex entry aji_saka, the hanacaraka legend, still unlocks at the end). Interact or click advances; holding interact ~1 s skips it all.
## The epilogue (ui/epilogue.tscn) reuses this with EPILOGUE_n keys and returns to Desa Purwa; a line with
## `%d` gets the codex percentage. Art: lit screen with wayang puppet sprites (assets/art/cutscene/, tools/gen_cutscene_art.py). ASSUMED: the Jawa glyph line uses the macOS system font
## (like aksara_render_test) and falls back to Latin when it is missing.

signal finished

@export var key_prefix := "PROLOGUE"
@export var lines := 2
@export var semar_from := 4
@export var semar_to := 5
@export var variants := {}   # card number -> flag; while the flag is set, card n uses <PREFIX>_<n>_ALT
@export var extras := {}     # card number -> [key, cond]; while Game.check(cond) holds, tr(key) is added under card n after a blank line
@export var next_scene := "res://ui/class_select.tscn"   # "" = back to Desa Purwa (epilogue)
const HOLD := 1.0
const SHADOW := Color("0E0A18")

var index := 0
var _hold := 0.0
var _done := false
var _text: Label
var _name: Label
var _aji: Node2D
var _lamp: Node2D
var _servants: Node2D
var _aksara: Label
var _tw: Tween
var _card: Control
var _arrow: TextureRect
var _cover: ColorRect
var _t := 0.0


func _ready() -> void:
	Snd.music("title" if key_prefix == "PROLOGUE" else "epilogue", 2.0)
	var bg := ColorRect.new()
	bg.color = SHADOW
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(bg)
	add_child(UIFx.frame(Vector2(31, 3), Vector2(418, 168)))   # card frame round the kelir
	var screen := ColorRect.new()   # the backlit kelir
	screen.color = Color("d9a24a")
	screen.position = Vector2(40, 12)
	screen.size = Vector2(400, 150)
	screen.mouse_filter = MOUSE_FILTER_IGNORE
	screen.clip_contents = true
	add_child(screen)
	var glow := Sprite2D.new()   # the blencong's warm pool on the cloth (dithered, scaled up)
	glow.texture = load("res://assets/art/cutscene/kelir_glow.png")
	glow.centered = false
	glow.scale = Vector2(5.0, 3.4)
	glow.position = Vector2(0, 0)
	glow.modulate.a = 0.55
	screen.add_child(glow)
	var floor_strip := Sprite2D.new()   # gedebog: the banana trunk the puppets are planted in
	floor_strip.texture = load("res://assets/art/cutscene/prologue_floor.png")
	floor_strip.centered = false
	floor_strip.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	floor_strip.region_enabled = true
	floor_strip.region_rect = Rect2(0, 0, 400, 16)
	floor_strip.position = Vector2(0, 134)
	screen.add_child(floor_strip)
	_aji = _puppet("puppet_ajisaka", Vector2(-60, 146), 3.0)   # the dalang's hero puppet
	_servants = Node2D.new()
	_servants.position = Vector2(300, 146)
	_servants.modulate.a = 0.0
	screen.add_child(_servants)
	for x in [-36, 36]:
		_servants.add_child(_puppet("puppet_buto", Vector2(x, 0), 2.5))   # the two faceless servants, drawn as raksasa
	screen.add_child(_aji)
	_lamp = _puppet("blencong", Vector2(200, 36), 3.0)   # the blencong hanging over the dalang's side
	_lamp.get_child(0).region_enabled = true
	screen.add_child(_lamp)
	_aksara = Label.new()
	_aksara.text = "ꦲꦤꦕꦫꦏ"
	_aksara.add_theme_font_override("font", load("res://assets/fonts/NotoSansJavanese.ttf"))
	_aksara.add_theme_font_size_override("font_size", 28)
	_aksara.add_theme_color_override("font_color", SHADOW)
	_aksara.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aksara.position = Vector2(100, 55)
	_aksara.size = Vector2(200, 40)
	_aksara.modulate.a = 0.0 if key_prefix == "PROLOGUE" else 1.0   # the epilogue: the letters are back
	screen.add_child(_aksara)
	var box := Panel.new()   # the same ink card as the in-game dialogue box (ui.md 3.1)
	box.add_theme_stylebox_override("panel", UIFx.ink_box())
	box.position = Vector2(40, 172)
	box.size = Vector2(400, 82)
	box.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(box)
	_card = Control.new()   # name and text fade and rise together between cards
	_card.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_card)
	_name = UIFx.text("", "label", UIFx.WARM)
	_name.position = Vector2(52, 180)
	_name.size = Vector2(376, 9)
	_card.add_child(_name)
	_text = UIFx.text("", "body", UIFx.CREAM)
	_text.position = Vector2(52, 193)
	_text.size = Vector2(376, 52)   # room for an extras line under a card
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.add_theme_constant_override("line_spacing", 3)
	_card.add_child(_text)
	_arrow = UIFx.rect_tex("continue_arrow", Vector2(425, 244))
	_arrow.visible = false
	add_child(_arrow)
	var hint := UIFx.text("UI_HOLD_SKIP", "body", UIFx.DIM)
	hint.position = Vector2(232, 258)
	hint.size = Vector2(240, 9)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(hint)
	_cover = UIFx.cover(self)
	_cover.color.a = 1.0
	create_tween().tween_property(_cover, "color:a", 0.0, 0.5)
	advance()


## A wayang sprite, feet at `pos`, scaled with whole-number-ish nearest filtering (the project default).
func _puppet(art: String, pos: Vector2, scl: float) -> Node2D:
	var n := Node2D.new()
	n.position = pos
	var sp := Sprite2D.new()
	sp.texture = load("res://assets/art/cutscene/%s.png" % art)
	sp.centered = false
	sp.offset = Vector2(-sp.texture.get_width() * (1.0 / 6.0 if art == "blencong" else 0.5), -sp.texture.get_height())
	sp.scale = Vector2(scl, scl)
	n.add_child(sp)
	return n


func _fade(n: CanvasItem, a: float, time := 0.8) -> void:
	create_tween().tween_property(n, "modulate:a", a, time)


## Shows the next line; after the last one, or while a line is still typing, it finishes the line first.
func advance() -> void:
	if _done:
		return
	if _tw and _tw.is_running():
		_tw.kill()
		_text.visible_ratio = 1.0
		return
	if index >= lines:
		_finish()
		return
	index += 1
	var game := get_node("/root/Game")
	var key := "%s_%d" % [key_prefix, index]
	if game.has_flag(str(variants.get(index, variants.get(str(index), "")))):
		key += "_ALT"
	_name.text = "NPC_SEMAR_NAME" if index >= semar_from and index <= semar_to else ""
	_text.position.y = 193.0 if _name.text != "" else 181.0
	var body := tr(key)
	if "%d" in body:
		body = body % int(game.codex_percent())
	var ex: Variant = extras.get(index, extras.get(str(index), null))
	if ex is Array and ex.size() >= 2 and game.check(str(ex[1])):
		body += "\n\n" + tr(str(ex[0]))
	_text.text = game.fmt(body)
	_text.visible_ratio = 0.0
	_card.modulate.a = 0.0   # fade and rise between cards
	_card.position.y = 5.0
	var rise := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	rise.tween_property(_card, "modulate:a", 1.0, 0.3)
	rise.tween_property(_card, "position:y", 0.0, 0.3)
	_tw = create_tween()
	_tw.tween_property(_text, "visible_ratio", 1.0, maxf(0.3, body.length() * 0.03))
	if key_prefix != "PROLOGUE":
		return
	var screen := _aji.get_parent() as CanvasItem
	match index:   # _aji = the dalang's puppet, _servants = the two faceless, _aksara = Laras's letters
		1: create_tween().tween_property(_aji, "position:x", 100.0, 1.2).set_trans(Tween.TRANS_SINE)
		2: _fade(_aksara, 1.0)
		3:
			_fade(_servants, 1.0)
			create_tween().tween_property(_servants, "scale", Vector2(1.4, 1.4), 1.5).set_trans(Tween.TRANS_SINE)
		4:
			create_tween().tween_property(screen, "modulate", Color(0.15, 0.13, 0.12), 1.2)
			_fade(_servants, 0.0, 1.2)
		5:
			create_tween().tween_property(screen, "modulate", Color(0.75, 0.8, 0.85), 1.5)
			_fade(_aji, 0.0, 0.2)
			_fade(_aksara, 0.35, 1.5)   # some of her letters have already faded

func skip() -> void:
	_finish()


func _finish() -> void:
	if _done:
		return
	_done = true
	if key_prefix == "PROLOGUE":
		get_node("/root/Game").unlock_codex("aji_saka")
	finished.emit()
	if next_scene == "":
		get_node("/root/Zones").go_to("desa_purwa", "from_gua_kala")
	else:
		get_tree().change_scene_to_file(next_scene)


func _input(e: InputEvent) -> void:
	if e.is_action_pressed("interact") or (e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT):
		get_viewport().set_input_as_handled()   # first: the last advance changes scene and drops the viewport
		advance()


func _process(delta: float) -> void:
	_t += delta
	if _lamp:   # blencong flame, 3 frames
		var sp: Sprite2D = _lamp.get_child(0)
		sp.region_rect = Rect2(14 * (int(_t * 7.0) % 3), 0, 14, sp.texture.get_height())
	_arrow.visible = not _done and not (_tw and _tw.is_running())   # blinking continue arrow
	_arrow.position.y = 242.0 + roundf(sin(_t * 5.0))
	_hold = _hold + delta if Input.is_action_pressed("interact") else 0.0
	if _hold >= HOLD:
		skip()
