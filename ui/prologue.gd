extends Control
## Wayang prologue between New Game and the class cards (quests.md MQ0). PROLOGUE_1..13 in dialogue.csv:
## 1-10 narration, 11-13 Semar. Interact or click advances; holding interact ~1 s skips it all.
## Placeholder art: lit screen, dark silhouettes. ASSUMED: the Jawa glyph line uses the macOS system font
## (like aksara_render_test) and falls back to Latin when it is missing.

signal finished

const LINES := 13
const SEMAR_FROM := 11
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
	_aksara.modulate.a = 0.0
	screen.add_child(_aksara)
	_name = Label.new()
	_name.position = Vector2(40, 170)
	_name.size = Vector2(400, 12)
	_name.modulate = Color("E8D9A0")
	add_child(_name)
	_text = Label.new()
	_text.position = Vector2(40, 184)
	_text.size = Vector2(400, 40)
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
	if index >= LINES:
		_finish()
		return
	index += 1
	var key := "PROLOGUE_%d" % index
	_name.text = "NPC_SEMAR_NAME" if index >= SEMAR_FROM else ""
	_text.text = key
	_text.visible_ratio = 0.0
	_tw = create_tween()
	_tw.tween_property(_text, "visible_ratio", 1.0, maxf(0.3, tr(key).length() * 0.03))
	match index:
		1: create_tween().tween_property(_aji, "position:x", 100.0, 1.2).set_trans(Tween.TRANS_SINE)
		2: _fade(_servants, 1.0)
		3: _fade(_aksara, 1.0)
		8: _fade(_aksara, 0.35, 1.5)
		9: _fade(_aksara, 0.0, 1.5)


func skip() -> void:
	_finish()


func _finish() -> void:
	if _done:
		return
	_done = true
	finished.emit()
	get_tree().change_scene_to_file("res://ui/class_select.tscn")


func _input(e: InputEvent) -> void:
	if e.is_action_pressed("interact") or (e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT):
		advance()
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	_hold = _hold + delta if Input.is_action_pressed("interact") else 0.0
	if _hold >= HOLD:
		skip()
