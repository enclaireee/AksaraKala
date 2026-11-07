extends Control
## Title screen (rpg.md 11). Continue only with a save; New Game asks before overwriting.
## Language toggle (ID/EN) saved in user://settings.cfg. ponytail: Settings waits for the settings screen.

var _box: VBoxContainer
var _msg: Label
var _confirm: VBoxContainer
var _lang: Button
var _glow: TextureRect
var _guna: TextureRect
var _mount: Array[TextureRect] = []
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
	_set_cursor()
	var sky := UIFx.rect_tex("title_sky", Vector2.ZERO)
	add_child(sky)
	_glow = UIFx.rect_tex("title_glow", Vector2(240 - 128, 120 - 128), Vector2(256, 256))
	_glow.modulate = Color(1, 1, 1, 0.8)
	add_child(_glow)
	_guna = UIFx.rect_tex("title_gunungan", Vector2(180, 28))
	_guna.modulate = Color(0.75, 0.75, 0.75)   # sits back behind the logo
	add_child(_guna)
	for i in 2:   # periodic 520 px strip, two copies drifting left
		var m := UIFx.rect_tex("title_mountains", Vector2(520 * i, 130))
		add_child(m)
		_mount.append(m)
	_embers = CPUParticles2D.new()
	_embers.texture = UIFx.tex("ember")
	_embers.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_embers.position = Vector2(240, 275)
	_embers.amount = 26
	_embers.lifetime = 7.0
	_embers.preprocess = 7.0
	_embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_embers.emission_rect_extents = Vector2(250, 2)
	_embers.direction = Vector2.UP
	_embers.spread = 12.0
	_embers.gravity = Vector2(2, -2)
	_embers.initial_velocity_min = 10.0
	_embers.initial_velocity_max = 26.0
	_embers.scale_amount_min = 0.6
	_embers.scale_amount_max = 1.2
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1, 0.8, 0.45, 0.0))
	ramp.set_color(1, Color(1, 0.5, 0.2, 0.0))
	ramp.add_point(0.15, Color(1, 0.85, 0.5, 0.9))
	ramp.add_point(0.7, Color(1, 0.6, 0.3, 0.5))
	_embers.color_ramp = ramp
	add_child(_embers)
	add_child(UIFx.rect_tex("vignette", Vector2.ZERO))
	_logo_wipe = Control.new()   # the ink wipe: a clip box that opens left to right
	_logo_wipe.clip_contents = true
	_logo_wipe.position = Vector2(60, 66)
	_logo_wipe.size = Vector2(0, 40)
	_logo_wipe.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_logo_wipe)
	var title := UIFx.label("BUDAYAGO", 28, UIFx.GOLD, true)
	title.add_theme_constant_override("outline_size", 3)
	title.add_theme_constant_override("line_spacing", 0)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	title.add_theme_constant_override("shadow_offset_y", 2)
	title.size = Vector2(360, 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_logo_wipe.add_child(title)
	_sub = UIFx.label("ꦧꦸꦢꦪꦒꦺꦴ  ·  ᮘᮥᮓᮚᮌᮧ", 8, UIFx.CREAM)
	_sub.add_theme_constant_override("outline_size", 3)
	_sub.position = Vector2(60, 108)
	_sub.size = Vector2(360, 12)
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub.modulate.a = 0.0
	var f := FontVariation.new()
	f.base_font = load("res://assets/fonts/NotoSansJavanese.ttf")
	f.fallbacks = [load("res://assets/fonts/NotoSansSundanese.ttf")]
	_sub.add_theme_font_override("font", f)
	add_child(_sub)
	_box = VBoxContainer.new()
	_box.position = Vector2(26, 170)
	_box.size = Vector2(130, 70)
	_box.add_theme_constant_override("separation", 0)
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
	_msg = UIFx.label("", 8, UIFx.VERMILLION)
	_msg.position = Vector2(180, 240)
	_msg.size = Vector2(280, 24)
	_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_msg)
	_confirm = VBoxContainer.new()   # framed question, replaces the menu
	_confirm.position = Vector2(26, 160)
	_confirm.size = Vector2(190, 80)
	_confirm.visible = false
	add_child(_confirm)
	var q := UIFx.label("UI_NEW_CONFIRM", 8, UIFx.CREAM)
	q.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	q.custom_minimum_size.x = 190
	_confirm.add_child(q)
	var yes := LozengeButton.new("UI_YES")
	yes.pressed.connect(_go.bind(_to_class_select))
	_confirm.add_child(yes)
	var no := LozengeButton.new("UI_CANCEL")
	no.pressed.connect(_show_menu)
	_confirm.add_child(no)
	_fade = UIFx.cover(self)
	_fade.color.a = 1.0
	_show_menu()
	# idle intro: fade up from black, ink-wipe the logo, then the subtitle and the menu
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 0.0, 0.5)
	tw.tween_property(_logo_wipe, "size:x", 360.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_sub, "modulate:a", 1.0, 0.4)
	UIFx.rise_in(_box, 6.0, 0.4)


## Custom mouse cursor, scaled to the window so it stays readable (hotspot 0,0).
func _set_cursor() -> void:
	var img := UIFx.tex("cursor").get_image()
	var k := maxi(1, int(DisplayServer.window_get_size().x / 480.0))
	if k > 1:
		img.resize(img.get_width() * k, img.get_height() * k, Image.INTERPOLATE_NEAREST)
	Input.set_custom_mouse_cursor(ImageTexture.create_from_image(img), Input.CURSOR_ARROW, Vector2.ZERO)


func _process(delta: float) -> void:
	_t += delta
	for m in _mount:
		m.position.x -= 0.4 * delta   # 4 px per 10 s
	if _mount[0].position.x <= -520.0:
		_mount[0].position.x += 520.0
	_mount[1].position.x = _mount[0].position.x + 520.0
	_guna.position.y = 28.0 + sin(_t * 0.4) * 1.5
	# blencong flicker: a few incommensurate sines stand in for alpha noise
	var n := 0.5 + 0.25 * sin(_t * 7.3) + 0.15 * sin(_t * 12.9 + 1.0) + 0.1 * sin(_t * 3.1)
	_glow.modulate.a = clampf(0.55 + 0.3 * n, 0.0, 1.0)


func _btn(text: String, cb: Callable, fade := true) -> void:
	var b := LozengeButton.new(text)
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
