extends Control
## Title screen (rpg.md 11, ui.md 4.1 v3): the logo and menu on the left; on the right a twilight valley, an aksara
## written in stars, and the Wiku on a cliff with glyphs rising from the staff.
## Continue only with a save; New Game asks before overwriting. Language toggle (ID/EN) saved in user://settings.cfg.

var _box: VBoxContainer
var _msg: Label
var _confirm: VBoxContainer
var _lang: Button
var _logo: TextureRect
var _sub: Label
var _hero: Sprite2D
var _glyphs: Array = []   # rising glyphs: [TextureRect, age, drift]
var _stars: TextureRect
var _next_glyph := 0.6
var _fade: ColorRect
var _t := 0.0
var _leaving := false

const SETTINGS := "user://settings.cfg"
static var settings_path := SETTINGS   # tests point this at a scratch file

const MENU_W := 112.0
const LOGO_POS := Vector2(36, 32)
const HERO_POS := Vector2(372, 190)        # top-left of the 24 px frame: feet on the cliff flat (y 214)
const STAFF := Vector2(384, 180)           # where the glyphs leave the staff (their bottom centre)
const GLYPH_KEYS := ["title_glyph_ka", "title_glyph_ja", "title_glyph_la", "title_glyph_ra"]
const GLYPH_LIFE := 6.0                    # seconds from the staff to gone
const GLYPH_RISE := 92.0                   # px climbed over a life
const GLYPH_EVERY := 1.7


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
	Snd.music("title", 2.0)
	DisplayServer.window_set_title("Aksara Kala")
	_set_cursor()
	# the scene, back to front: sky and stars, the aksara constellation, the valley, the cliff, the Wiku (ui.md 4.1)
	add_child(UIFx.rect_tex("title_sky", Vector2.ZERO))
	add_child(Twinkle.new())
	_stars = UIFx.rect_tex("title_constellation", Vector2(330, 24))
	add_child(_stars)
	add_child(UIFx.rect_tex("title_far", Vector2.ZERO))
	var pool := UIFx.rect_tex("title_glow", HERO_POS + Vector2(-8, -2), Vector2(40, 40))   # the staff's faint light
	pool.modulate.a = 0.75
	add_child(pool)
	add_child(UIFx.rect_tex("title_near", Vector2.ZERO))
	_hero = Sprite2D.new()   # the Wiku from behind, looking out over the valley
	_hero.texture = load("res://assets/art/hero_mage.png")
	_hero.hframes = 6
	_hero.vframes = 18
	_hero.frame_coords = Vector2i(0, 2)
	_hero.centered = false
	_hero.position = HERO_POS
	_hero.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_hero)
	add_child(UIFx.motes_layer(Rect2(300, 200, 180, 30), 10))
	# the logo and its line
	_logo = UIFx.rect_tex("logo", LOGO_POS)
	add_child(_logo)
	_sub = UIFx.text("The script of time", "body", UIFx.TEXT)
	_sub.size = Vector2(_logo.size.x, 10)
	_sub.position = Vector2(LOGO_POS.x, LOGO_POS.y + _logo.size.y + 2)
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_sub)
	# the menu: a column under the logo
	_box = VBoxContainer.new()
	_box.position = Vector2(roundf(LOGO_POS.x + (_logo.size.x - MENU_W) / 2.0), 140)
	_box.size = Vector2(MENU_W, 60)
	_box.add_theme_constant_override("separation", 0)
	add_child(_box)
	if get_node("/root/Game").has_save():
		_btn("UI_CONTINUE", _continue)
	_btn("UI_NEW_GAME", _new, false)
	_btn("UI_QUIT", func() -> void: get_tree().quit())
	_lang = LozengeButton.new("", 8)
	_lang.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_lang.position = Vector2(408, 6)
	_lang.size = Vector2(64, 16)
	_lang.pressed.connect(_toggle_lang)
	add_child(_lang)
	_lang_text()
	_msg = UIFx.text("", "body", UIFx.DANGER)
	_msg.position = Vector2(LOGO_POS.x - 10, 200)
	_msg.size = Vector2(160, 20)
	_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_msg)
	_confirm = VBoxContainer.new()   # the overwrite question replaces the menu in place
	_confirm.position = Vector2(LOGO_POS.x - 20, 136)
	_confirm.size = Vector2(180, 60)
	_confirm.add_theme_constant_override("separation", 2)
	_confirm.visible = false
	add_child(_confirm)
	var q := UIFx.text("UI_NEW_CONFIRM", "body", UIFx.TEXT)
	q.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	q.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	q.custom_minimum_size.x = 180
	_confirm.add_child(q)
	for pair in [["UI_YES", _go.bind(_to_class_select)], ["UI_CANCEL", _show_menu]]:
		var row := CenterContainer.new()
		var b := LozengeButton.new(pair[0], 10)
		b.pressed.connect(pair[1])
		row.add_child(b)
		_confirm.add_child(row)
	_fade = UIFx.cover(self)
	_fade.color = Color(UIFx.LACQUER, 1.0)
	_show_menu()
	# intro: up from night, the logo rises in, then its line, then the menu; the glyphs start rising on their own
	_logo.modulate.a = 0.0
	_sub.modulate.a = 0.0
	_box.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 0.0, 0.8).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void: UIFx.rise_in(_logo, 6.0, 0.5))
	tw.tween_interval(0.35)
	tw.tween_property(_sub, "modulate:a", 1.0, 0.4)
	tw.tween_callback(func() -> void: UIFx.rise_in(_box, 4.0, 0.3))


## Custom mouse cursor, scaled to the window so it stays readable (hotspot 0,0).
func _set_cursor() -> void:
	var img := UIFx.tex("cursor").get_image()
	var k := maxi(1, int(DisplayServer.window_get_size().x / 480.0))
	if k > 1:
		img.resize(img.get_width() * k, img.get_height() * k, Image.INTERPOLATE_NEAREST)
	Input.set_custom_mouse_cursor(ImageTexture.create_from_image(img), Input.CURSOR_ARROW, Vector2.ZERO)


func _process(delta: float) -> void:
	_t += delta
	_stars.self_modulate.a = 0.75 + 0.25 * sin(_t * 0.9)   # the constellation breathes, slower than the stars
	_next_glyph -= delta
	if _next_glyph <= 0.0:
		_next_glyph = GLYPH_EVERY
		_spawn_glyph()
	# glyphs rise from the staff, sway, fade in then out; whole pixels only, so the art never resamples
	for g in _glyphs.duplicate():
		var r: TextureRect = g[0]
		g[1] += delta
		var k: float = g[1] / GLYPH_LIFE
		if k >= 1.0:
			r.queue_free()
			_glyphs.erase(g)
			continue
		var base := STAFF - Vector2(r.size.x / 2.0, r.size.y)
		r.position = (base + Vector2(sin(g[1] * 1.3 + g[2]) * 5.0 + g[2] * 6.0 * k, -GLYPH_RISE * (1.0 - pow(1.0 - k, 1.6)))).round()
		r.modulate.a = minf(1.0, k * 6.0) * (1.0 - smoothstep(0.55, 1.0, k))


func _spawn_glyph() -> void:
	var r := UIFx.rect_tex(GLYPH_KEYS[randi() % GLYPH_KEYS.size()], STAFF)
	r.modulate.a = 0.0
	add_child(r)
	move_child(r, _hero.get_index() + 1)   # above the scene, under the logo and the menu
	_glyphs.append([r, 0.0, randf_range(-1.0, 1.0)])


func _btn(text: String, cb: Callable, fade := true) -> void:
	var b := LozengeButton.new(text, 10)
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
		_confirm.get_child(1).get_child(0).grab_focus()
	else:
		_to_class_select()


func _to_class_select() -> void:
	get_tree().change_scene_to_file("res://ui/name_entry.tscn")
