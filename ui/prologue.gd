extends Control
## Wayang prologue between New Game and the class cards (quests.md MQ0). PROLOGUE_1..2 in dialogue.csv:
## Story v4, 2 narration cards of an ordinary day (script.md 4; the raid is the `raid` beat now)
## (codex entry aji_saka, the hanacaraka legend, still unlocks at the end). Interact or click advances; holding interact ~1 s skips it all.
## The epilogue (ui/epilogue.tscn) reuses this with EPILOGUE_n keys and returns to Desa Purwa; a line with
## `%d` gets the codex percentage. Placeholder art: lit screen, dark silhouettes. ASSUMED: the Jawa glyph line uses the macOS system font
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
const JAWA := "/System/Library/Fonts/Supplemental/NotoSansJavanese-Regular.otf"
const SHADOW := Color("14110f")

var index := 0
var _hold := 0.0
var _done := false
var _text: Label
var _name: Label
var _aji: Node2D
var _servants: Node2D
var _aksara: Label
var _tw: Tween


func _ready() -> void:
	var t := Theme.new()
	t.default_font_size = 8
	theme = t
	var bg := ColorRect.new()
	bg.color = SHADOW
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(bg)
	var screen := ColorRect.new()   # the backlit kelir
	screen.color = Color("d9a24a")
	screen.position = Vector2(40, 12)
	screen.size = Vector2(400, 150)
	screen.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(screen)
	_aji = _silhouette(PackedVector2Array([Vector2(-14, 60), Vector2(-10, 20), Vector2(-6, 8), Vector2(-4, -14), Vector2(4, -14), Vector2(6, 8), Vector2(10, 20), Vector2(14, 60)]), Vector2(-60, 80))
	_servants = Node2D.new()
	_servants.position = Vector2(300, 80)
	_servants.modulate.a = 0.0
	screen.add_child(_servants)
	for x in [-30, 30]:
		var s := _silhouette(PackedVector2Array([Vector2(-9, 50), Vector2(-6, 14), Vector2(-3, -4), Vector2(3, -4), Vector2(6, 14), Vector2(9, 50)]), Vector2(x, 10))
		_servants.add_child(s)
	screen.add_child(_aji)
	_aksara = Label.new()
	_aksara.text = "ꦲꦤꦕꦫꦏ" if FileAccess.file_exists(JAWA) else "ha na ca ra ka"
	if FileAccess.file_exists(JAWA):
		var f := FontFile.new()
		f.load_dynamic_font(JAWA)
		_aksara.add_theme_font_override("font", f)
	_aksara.add_theme_font_size_override("font_size", 28)
	_aksara.add_theme_color_override("font_color", SHADOW)
	_aksara.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aksara.position = Vector2(100, 55)
	_aksara.size = Vector2(200, 40)
	_aksara.modulate.a = 0.0 if key_prefix == "PROLOGUE" else 1.0   # the epilogue: the letters are back
	screen.add_child(_aksara)
	_name = Label.new()
	_name.position = Vector2(40, 170)
	_name.size = Vector2(400, 12)
	_name.modulate = Color("E8D9A0")
	add_child(_name)
	_text = Label.new()
	_text.position = Vector2(40, 184)
	_text.size = Vector2(400, 64)   # room for an extras line under a card
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_text)
	var hint := Label.new()
	hint.text = "UI_HOLD_SKIP"
	hint.position = Vector2(300, 252)
	hint.size = Vector2(174, 12)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.modulate = Color(1, 1, 1, 0.6)
	add_child(hint)
	advance()


func _silhouette(points: PackedVector2Array, pos: Vector2) -> Polygon2D:
	var p := Polygon2D.new()
	p.polygon = points
	p.color = SHADOW
	p.position = pos
	return p


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
	var body := tr(key)
	if "%d" in body:
		body = body % int(game.codex_percent())
	var ex: Variant = extras.get(index, extras.get(str(index), null))
	if ex is Array and ex.size() >= 2 and game.check(str(ex[1])):
		body += "\n\n" + tr(str(ex[0]))
	_text.text = game.fmt(body)
	_text.visible_ratio = 0.0
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
	_hold = _hold + delta if Input.is_action_pressed("interact") else 0.0
	if _hold >= HOLD:
		skip()
