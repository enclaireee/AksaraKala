extends Control
## Title screen (rpg.md 11). Continue only with a save; New Game asks before overwriting.
## Language toggle (ID/EN) saved in user://settings.cfg. ponytail: Settings waits for the settings screen.

var _box: VBoxContainer
var _msg: Label
var _confirm: VBoxContainer
var _lang: Button
var _glow: TextureRect
var _candle: Sprite2D
var _glyphs: Array[Label] = []   # the Javanese alphabet on the right page
var _embers: CPUParticles2D
var _logo_wipe: Control
var _sub: Label
var _fade: ColorRect
var _t := 0.0
var _leaving := false

const SETTINGS := "user://settings.cfg"
static var settings_path := SETTINGS   # tests point this at a scratch file


## Saved choice, else the OS language ("id" -> Indonesian, anything else English).
static func load_language() -> String:
	var cf := ConfigFile.new()
	cf.load(settings_path)
	return cf.get_value("settings", "language", "id" if OS.get_locale_language() == "id" else "en")


static func save_language(lang: String) -> void:
	var cf := ConfigFile.new()
	cf.load(settings_path)   # keep other settings
	cf.set_value("settings", "language", lang)
	cf.save(settings_path)


func _ready() -> void:
	TranslationServer.set_locale(load_language())
	DisplayServer.window_set_title("Aksara Kala")
	_set_cursor()
	# the desk, the open book, the candle's light (ui.md 4.1)
	add_child(UIFx.rect_tex("title_desk", Vector2.ZERO))
	var scroll := UIFx.rect_tex("title_scroll", Vector2(372, 224))
	scroll.rotation_degrees = -4.0
	add_child(scroll)
	add_child(UIFx.rect_tex("title_inkpot", Vector2(6, 206)))
	add_child(UIFx.rect_tex("title_seal", Vector2(424, 238)))
	add_child(UIFx.rect_tex("title_book", Vector2(54, 18)))
	_candle = Sprite2D.new()
	_candle.texture = UIFx.tex("title_candle")
	_candle.centered = false
	_candle.region_enabled = true
	_candle.region_rect = Rect2(0, 0, 14, 40)
	_candle.position = Vector2(428, 62)
	add_child(_candle)
	_glow = UIFx.rect_tex("title_glow", Vector2(435 - 150, 68 - 150), Vector2(300, 300))
	_glow.modulate = Color(1, 0.72, 0.38, 0.5)
	add_child(_glow)
	_embers = CPUParticles2D.new()   # dust motes drifting up through the candlelight
	_embers.texture = UIFx.tex("ember")
	_embers.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_embers.position = Vector2(300, 250)
	_embers.amount = 18
	_embers.lifetime = 9.0
	_embers.preprocess = 9.0
	_embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_embers.emission_rect_extents = Vector2(180, 4)
	_embers.direction = Vector2.UP
	_embers.spread = 20.0
	_embers.gravity = Vector2(3, -1)
	_embers.initial_velocity_min = 6.0
	_embers.initial_velocity_max = 14.0
	_embers.scale_amount_min = 0.5
	_embers.scale_amount_max = 1.0
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1, 0.85, 0.55, 0.0))
	ramp.set_color(1, Color(1, 0.8, 0.5, 0.0))
	ramp.add_point(0.2, Color(1, 0.9, 0.65, 0.7))
	ramp.add_point(0.7, Color(1, 0.8, 0.5, 0.35))
	_embers.color_ramp = ramp
	add_child(_embers)
	add_child(UIFx.rect_tex("vignette", Vector2.ZERO))
	# left page: the logo, written in ink (an ink wipe reveals it)
	_logo_wipe = Control.new()
	_logo_wipe.clip_contents = true
	_logo_wipe.position = Vector2(74, 50)
	_logo_wipe.size = Vector2(0, 100)
	_logo_wipe.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_logo_wipe)
	var title := UIFx.label("AKSARA KALA", 24, UIFx.INK, true)
	title.add_theme_constant_override("outline_size", 0)
	title.size = Vector2(156, 32)
	title.position = Vector2(0, 10)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_logo_wipe.add_child(title)
	var sub := UIFx.label("The Script of Time", 10, UIFx.INK_HEAD, true)
	sub.add_theme_constant_override("outline_size", 0)
	sub.size = Vector2(156, 16)
	sub.position = Vector2(0, 44)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_logo_wipe.add_child(sub)
	var rule := TextureRect.new()
	rule.texture = UIFx.tex("divider")
	rule.position = Vector2(46, 66)
	_logo_wipe.add_child(rule)
	_sub = UIFx.label("ꦲꦏ꧀ꦱꦫ  ·  ᮃᮊ᮪ᮞᮛ", 10, UIFx.INK_DIM)   # "aksara" in Javanese and Sundanese: the one cultural nod
	_sub.add_theme_constant_override("outline_size", 0)
	_sub.position = Vector2(74, 128)
	_sub.size = Vector2(156, 16)
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub.modulate.a = 0.0
	var f := FontVariation.new()
	f.base_font = load("res://assets/fonts/NotoSansJavanese.ttf")
	f.fallbacks = [load("res://assets/fonts/NotoSansSundanese.ttf")]
	_sub.add_theme_font_override("font", f)
	add_child(_sub)
	var sketch := UIFx.rect_tex("title_sketch", Vector2(77, 156))   # a quick ink sketch under the logo
	add_child(sketch)
	# right page: the menu, and the whole hanacaraka written below it (the letters the game is about)
	var rule2 := UIFx.rect_tex("divider", Vector2(296, 130))
	add_child(rule2)
	var jf := FontVariation.new()
	jf.base_font = load("res://assets/fonts/NotoSansJavanese.ttf")
	var letters := "ꦲꦤꦕꦫꦏꦢꦠꦱꦮꦭꦥꦝꦗꦪꦚꦩꦒꦧꦛꦔ"
	for i in letters.length():
		var g := Label.new()
		g.text = letters[i]
		g.add_theme_font_override("font", jf)
		g.add_theme_font_size_override("font_size", 13)
		g.add_theme_color_override("font_color", Color("8A7656"))
		g.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		g.size = Vector2(28, 18)
		g.position = Vector2(266 + (i % 5) * 29, 138 + (i / 5) * 15)
		g.modulate.a = 0.0
		g.mouse_filter = MOUSE_FILTER_IGNORE
		add_child(g)
		_glyphs.append(g)
	_box = VBoxContainer.new()
	_box.position = Vector2(262, 56)
	_box.size = Vector2(140, 90)
	_box.add_theme_constant_override("separation", 6)
	add_child(_box)
	if get_node("/root/Game").has_save():
		_btn("UI_CONTINUE", _continue)
	_btn("UI_NEW_GAME", _new, false)
	_btn("UI_QUIT", func() -> void: get_tree().quit())
	_lang = LozengeButton.new("", 8)
	_lang.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_lang.position = Vector2(410, 6)
	_lang.size = Vector2(64, 16)
	_lang.pressed.connect(_toggle_lang)
	add_child(_lang)
	_lang_text()
	_msg = UIFx.label("", 8, UIFx.INK_HEAD)
	_msg.add_theme_constant_override("outline_size", 0)
	_msg.position = Vector2(256, 186)
	_msg.size = Vector2(150, 24)
	_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_msg)
	_confirm = VBoxContainer.new()   # the overwrite question, replaces the menu on the right page
	_confirm.position = Vector2(258, 56)
	_confirm.size = Vector2(150, 90)
	_confirm.visible = false
	add_child(_confirm)
	var q := UIFx.label("UI_NEW_CONFIRM", 8, UIFx.INK)
	q.add_theme_constant_override("outline_size", 0)
	q.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	q.custom_minimum_size.x = 150
	_confirm.add_child(q)
	var yes := LozengeButton.new("UI_YES", 10, true)
	yes.pressed.connect(_go.bind(_to_class_select))
	_confirm.add_child(yes)
	var no := LozengeButton.new("UI_CANCEL", 10, true)
	no.pressed.connect(_show_menu)
	_confirm.add_child(no)
	_fade = UIFx.cover(self)
	_fade.color.a = 1.0
	_show_menu()
	# idle intro: fade up from black, the logo is inked in, then the subtitle and the menu
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 0.0, 0.5)
	tw.tween_property(_logo_wipe, "size:x", 156.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_sub, "modulate:a", 1.0, 0.4)
	UIFx.rise_in(_box, 6.0, 0.4)
	for i in _glyphs.size():   # the letters appear one by one, as if written
		tw.parallel().tween_property(_glyphs[i], "modulate:a", 0.75, 0.3).set_delay(0.04 * i)


## Custom mouse cursor, scaled to the window so it stays readable (hotspot 0,0).
func _set_cursor() -> void:
	var img := UIFx.tex("cursor").get_image()
	var k := maxi(1, int(DisplayServer.window_get_size().x / 480.0))
	if k > 1:
		img.resize(img.get_width() * k, img.get_height() * k, Image.INTERPOLATE_NEAREST)
	Input.set_custom_mouse_cursor(ImageTexture.create_from_image(img), Input.CURSOR_ARROW, Vector2.ZERO)


func _process(delta: float) -> void:
	_t += delta
	_candle.region_rect = Rect2(14 * (int(_t * 7.0) % 3), 0, 14, 40)   # the flame
	# candle flicker: a few incommensurate sines stand in for alpha noise
	var n := 0.5 + 0.25 * sin(_t * 7.3) + 0.15 * sin(_t * 12.9 + 1.0) + 0.1 * sin(_t * 3.1)
	_glow.modulate.a = clampf(0.32 + 0.22 * n, 0.0, 1.0)
	if _t > 4.0 and not _glyphs.is_empty():   # one letter at a time warms to wax red, like a remembered glyph
		var hot := int(_t * 0.5) % _glyphs.size()
		for i in _glyphs.size():
			var want := Color("9E2B25") if i == hot else Color("8A7656")
			_glyphs[i].add_theme_color_override("font_color", _glyphs[i].get_theme_color("font_color").lerp(want, minf(1.0, delta * 3.0)))


func _btn(text: String, cb: Callable, fade := true) -> void:
	var b := LozengeButton.new(text, 10, true)
	b.pressed.connect(_go.bind(cb) if fade else cb)
	_box.add_child(b)


## Any choice fades to black first, then acts. Failed loads fade back in.
func _go(cb: Callable) -> void:
	if _leaving:
		return
	_leaving = true
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 1.0, 0.3)
	tw.tween_callback(func() -> void:
		_leaving = false
		cb.call()
		if is_inside_tree() and get_tree().current_scene == self:
			create_tween().tween_property(_fade, "color:a", 0.0, 0.25))


func _lang_text() -> void:
	_lang.text = "ID | en" if TranslationServer.get_locale() == "id" else "id | EN"


func _toggle_lang() -> void:
	var lang := "en" if TranslationServer.get_locale().begins_with("id") else "id"
	TranslationServer.set_locale(lang)
	save_language(lang)
	_lang_text()


func _show_menu() -> void:
	_confirm.visible = false
	_box.visible = true
	_box.get_child(0).grab_focus()


func _continue() -> void:
	if get_node("/root/Game").load_game():
		get_node("/root/Zones").continue_game()
	else:
		_msg.text = "UI_SAVE_BAD"


func _new() -> void:
	if get_node("/root/Game").has_save():
		_box.visible = false
		_confirm.visible = true
		_confirm.get_child(1).grab_focus()
	else:
		_to_class_select()


func _to_class_select() -> void:
	get_tree().change_scene_to_file("res://ui/name_entry.tscn")
