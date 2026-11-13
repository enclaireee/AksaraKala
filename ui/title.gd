extends Control
## Title screen (rpg.md 11, ui.md 4.1 v4): the logo and menu on the left; a dusk valley under volcanoes, temples ruined on
## the mountains and in the misty valley, broken pillars along the foreground, an aksara written in stars, and the Wiku
## on a grassy cliff under a great tree, glyphs rising from the staff. Settings and About open as dusk cards
## in place of the logo column; Esc closes them.
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
var _rune: TextureRect   # the aksara carved in the broken pillar in the foreground; it breathes
var _next_glyph := 0.6
var _card: Panel                 # the open Settings / About card, or null
var _card_from: Control          # menu entry to refocus when the card closes
var _full_btn: Button
var _lang_btn: Button
var _fade: ColorRect
var _demo_class := 0              # index into DemoRoute.CLASSES
var _demo_act := 0                # index into DemoRoute.MAIN
var _demo_cps: Array = []         # DemoRoute.checkpoints(), read when the Demo card opens
var _demo_cls_btn: Button
var _demo_act_lbl: Label
var _demo_note: Label
var _demo_list: VBoxContainer
var _about_scroll: ScrollContainer   # the About body: taller than the card, so it scrolls
var _t := 0.0
var _leaving := false

const SETTINGS := "user://settings.cfg"
static var settings_path := SETTINGS   # tests point this at a scratch file

const MENU_W := 112.0
const LOGO_POS := Vector2(36, 32)
const HERO_POS := Vector2(372, 190)        # top-left of the 24 px frame: feet on the cliff flat (y 214)
const STAFF := Vector2(384, 180)           # where the glyphs leave the staff (their bottom centre)
const RUNE_POS := Vector2(244, 218)        # title_pillar_glyph on the foreground pillar (tools/title_scene.py PILLAR_GLYPH_AT)
const GLYPH_KEYS := ["title_glyph_ka", "title_glyph_ja", "title_glyph_la", "title_glyph_ra"]
const GLYPH_LIFE := 6.0                    # seconds from the staff to gone
const GLYPH_RISE := 92.0                   # px climbed over a life
const GLYPH_EVERY := 1.7
const CARD := Rect2(20, 22, 240, 226)   # Settings / About card: covers the logo column
const INDENT := 11.0                     # rows line up with LozengeButton text (its cursor gutter)
const CREDITS := ["Muhammad Fatih Zamzami", "Muhammad Nafis Yusa'", "Fahmi Milan Amyar"]
## CC BY 4.0 credit for the downloaded set-piece music (tools/audio/sources/music.json `credits`; ui.md About card).
const MUSIC_BY := "Kevin MacLeod (incompetech.com), CC BY 4.0"
const MUSIC := ["Night Vigil", "Morning", "Evening", "Heroic Age", "Tafi Maradi (no voice)", "River Fire", "Rynos Theme",
		"Crusade", "Mountain Emperor", "Curse of the Scarab", "Hitman", "Mystic Force", "Unlight", "Tempting Secrets"]
const ABOUT_STEP := 18.0   # px one Up/Down press scrolls the About body


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
	var gm := get_node("/root/Game")
	if gm.demo:   # back from a demo run: the real save slot again, and no demo state left in memory
		gm.demo = false
		gm.save_path = gm.SAVE_PATH
		gm._reset()
	TranslationServer.set_locale(load_language())
	GameSettings.apply_all()
	Snd.music("title", 2.0)
	DisplayServer.window_set_title("AksaraKala")
	# the scene, back to front: sky and stars, the aksara constellation, the valley, the cliff, the Wiku (ui.md 4.1)
	add_child(UIFx.rect_tex("title_sky", Vector2.ZERO))
	add_child(Twinkle.new())
	_stars = UIFx.rect_tex("title_constellation", Vector2(330, 24))
	add_child(_stars)
	add_child(UIFx.rect_tex("title_far", Vector2.ZERO))
	var pool := UIFx.rect_tex("title_glow", HERO_POS + Vector2(-8, -2), Vector2(40, 40))   # the staff's faint light
	pool.modulate.a = 0.75
	add_child(pool)
	add_child(UIFx.rect_tex("title_near", Vector2.ZERO))   # cliff and tree, foreground pillars, lantern, fallen column
	_rune = UIFx.rect_tex("title_pillar_glyph", Vector2.ZERO)
	_rune.position = RUNE_POS
	add_child(_rune)
	_hero = Sprite2D.new()   # the Wiku from behind, looking out over the valley
	_hero.texture = load("res://assets/art/hero_mage.png")
	_hero.hframes = 6
	_hero.vframes = 18
	_hero.frame_coords = Vector2i(0, 2)
	_hero.centered = false
	_hero.position = HERO_POS + Vector2(-4, -6)   # 32 px frame: same feet, same centre as the old 24 px one
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
	_btn("UI_DEMO", _open_card.bind("demo"), false)
	_btn("UI_SETTINGS", _open_card.bind("settings"), false)
	_btn("UI_ABOUT", _open_card.bind("about"), false)
	_btn("UI_QUIT", func() -> void: get_tree().quit())
	_lang = LozengeButton.new("", 8)
	_lang.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_lang.position = Vector2(408, 6)
	_lang.size = Vector2(64, 16)
	_lang.pressed.connect(_toggle_lang)
	add_child(_lang)
	_lang_text()
	_msg = UIFx.text("", "body", UIFx.DANGER)
	_msg.position = Vector2(LOGO_POS.x - 10, 234)
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
	GameSettings.apply_cursor()


func _process(delta: float) -> void:
	_t += delta
	_stars.self_modulate.a = 0.75 + 0.25 * sin(_t * 0.9)   # the constellation breathes, slower than the stars
	_rune.self_modulate.a = 0.45 + 0.55 * pow(0.5 + 0.5 * sin(_t * 1.3), 2.0)   # the carved rune wakes and sleeps
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
	GameSettings.toggle_language()
	_lang_text()
	_card_text()


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


# ---------------------------------------------------------------- Settings and About cards

func _input(event: InputEvent) -> void:
	if _about_scroll and (event.is_action_pressed("ui_up", true) or event.is_action_pressed("ui_down", true)):
		_about_scroll.scroll_vertical += int(ABOUT_STEP * (-1.0 if event.is_action("ui_up") else 1.0))
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	Snd.play("ui_back")
	if _card:
		_close_card()
		get_viewport().set_input_as_handled()
	elif _confirm.visible:
		_show_menu()
		get_viewport().set_input_as_handled()


func _open_card(which: String) -> void:
	if _card or _leaving:
		return
	_card_from = get_viewport().gui_get_focus_owner()
	_msg.text = ""
	_box.visible = false
	_card = Panel.new()
	_card.add_theme_stylebox_override("panel", UIFx.ink_box())
	_card.position = CARD.position
	_card.size = Vector2(CARD.size.x, 176.0 if which == "settings" else CARD.size.y)   # Settings is shorter
	add_child(_card)
	move_child(_card, _fade.get_index())   # under the fade cover
	var v := VBoxContainer.new()
	v.position = Vector2(10, 8)
	v.size = _card.size - Vector2(20, 16)
	v.add_theme_constant_override("separation", 2)
	_card.add_child(v)
	v.add_child(UIFx.text({"settings": "UI_SETTINGS", "about": "UI_ABOUT", "demo": "UI_DEMO"}[which], "head", UIFx.HEAD))
	var rule := ColorRect.new()
	rule.color = UIFx.LINE_DIM
	rule.custom_minimum_size = Vector2(v.size.x, 1)
	rule.mouse_filter = MOUSE_FILTER_IGNORE
	v.add_child(rule)
	if which == "settings":
		_build_settings(v)
	elif which == "demo":
		_build_demo(v)
	else:
		_about_scroll = ScrollContainer.new()
		_about_scroll.size_flags_vertical = SIZE_EXPAND_FILL
		_about_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		var body := VBoxContainer.new()
		body.add_theme_constant_override("separation", 2)
		body.custom_minimum_size.x = v.size.x - 6   # room for the 4 px scroll bar
		body.size = Vector2(v.size.x - 6, 0)
		_about_scroll.add_child(body)
		v.add_child(_about_scroll)
		_build_about(body)
	if not _about_scroll:   # the About scroll already fills down to Back
		var fill := Control.new()   # Back sits at the foot of the card
		fill.size_flags_vertical = SIZE_EXPAND_FILL
		fill.mouse_filter = MOUSE_FILTER_IGNORE
		v.add_child(fill)
	var back := LozengeButton.new("UI_BACK", 8)
	back.pressed.connect(_close_card)
	v.add_child(back)
	_card_text()
	var tw := create_tween().set_parallel()
	tw.tween_property(_logo, "modulate:a", 0.0, 0.15)
	tw.tween_property(_sub, "modulate:a", 0.0, 0.15)
	UIFx.rise_in(_card, 4.0, 0.2)
	var first: Control = back
	if which == "settings":
		first = _card.find_children("*", "HSlider", true, false)[0]
	elif which == "demo":
		first = _demo_cls_btn
	first.grab_focus()


func _close_card() -> void:
	if not _card:
		return
	_card.queue_free()
	_card = null
	_full_btn = null
	_lang_btn = null
	_demo_cls_btn = null
	_demo_act_lbl = null
	_demo_note = null
	_demo_list = null
	_about_scroll = null
	var tw := create_tween().set_parallel()
	tw.tween_property(_logo, "modulate:a", 1.0, 0.2)
	tw.tween_property(_sub, "modulate:a", 1.0, 0.2)
	_box.visible = true
	UIFx.rise_in(_box, 4.0, 0.2)
	if is_instance_valid(_card_from) and _card_from.is_visible_in_tree():
		_card_from.grab_focus()
	else:
		_box.get_child(0).grab_focus()


## A caps section label, indented to the button text, with a little air above it.
func _section(v: VBoxContainer, key: String) -> void:
	var gap := Control.new()
	gap.custom_minimum_size.y = 4
	v.add_child(gap)
	v.add_child(_row(UIFx.text(key, "label", UIFx.LABEL_COL)))


## Wraps a control in a row indented to the LozengeButton text column.
func _row(c: Control) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 0)
	var pad := Control.new()
	pad.custom_minimum_size.x = INDENT
	h.add_child(pad)
	h.add_child(c)
	return h


func _build_settings(v: VBoxContainer) -> void:
	_section(v, "UI_BK_AUDIO")
	for bus in GameSettings.BUSES:
		var name_lbl := UIFx.text("UI_SYS_" + bus.to_upper(), "body", UIFx.TEXT)
		name_lbl.custom_minimum_size.x = 88
		var row := _row(name_lbl)
		row.custom_minimum_size.y = 12
		var sl := HSlider.new()
		sl.name = bus
		sl.min_value = 0
		sl.max_value = 100
		sl.step = 5
		sl.value = GameSettings.volume(bus)
		sl.custom_minimum_size = Vector2(96, 10)
		sl.size_flags_vertical = SIZE_SHRINK_CENTER
		row.add_child(sl)
		var val := UIFx.text(str(int(sl.value)), "body", UIFx.DIM)
		val.custom_minimum_size.x = 24
		val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(val)
		sl.value_changed.connect(func(x: float) -> void:
			GameSettings.set_volume(bus, x)
			val.text = str(int(x)))
		# the slider has no cursor of its own: its name lights up cyan while it has focus
		sl.focus_entered.connect(func() -> void: name_lbl.add_theme_color_override("font_color", UIFx.ACCENT))
		sl.focus_exited.connect(func() -> void: name_lbl.add_theme_color_override("font_color", UIFx.TEXT))
		sl.mouse_entered.connect(func() -> void: sl.grab_focus())
		v.add_child(row)
	_section(v, "UI_BK_DISPLAY")
	_full_btn = LozengeButton.new("", 8)
	_full_btn.pressed.connect(func() -> void:
		GameSettings.set_fullscreen(not GameSettings.is_fullscreen())
		_card_text())
	v.add_child(_full_btn)
	_lang_btn = LozengeButton.new("", 8)
	_lang_btn.pressed.connect(_toggle_lang)
	v.add_child(_lang_btn)


func _build_about(v: VBoxContainer) -> void:
	v.add_child(_row(UIFx.text("AksaraKala  ·  The script of time", "body", UIFx.DIM)))
	_section(v, "UI_ABOUT_MADE_BY")
	for n in CREDITS:
		v.add_child(_row(UIFx.text(n, "body", UIFx.TEXT)))
	_section(v, "UI_ABOUT_MADE_FOR")
	v.add_child(_row(UIFx.text("BUDAYA GO! 2026", "body", UIFx.WARM)))
	v.add_child(_row(UIFx.text("Kompetisi Inovasi Digital Budaya Indonesia", "body", UIFx.TEXT)))
	v.add_child(_row(UIFx.text("Kementerian Kebudayaan Republik Indonesia", "body", UIFx.DIM)))
	_section(v, "UI_ABOUT_BUILT_WITH")
	v.add_child(_row(UIFx.text("Godot Engine", "body", UIFx.TEXT)))
	var fonts := UIFx.text("Tiny5, Jersey 10 / 15, Noto Sans Sundanese & Javanese (SIL OFL 1.1)", "body", UIFx.DIM)
	fonts.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fonts.custom_minimum_size.x = v.custom_minimum_size.x - INDENT
	v.add_child(_row(fonts))
	_section(v, "UI_ABOUT_MUSIC")
	v.add_child(_row(UIFx.text(MUSIC_BY, "body", UIFx.TEXT)))
	var tracks := UIFx.text(", ".join(MUSIC), "body", UIFx.DIM)
	tracks.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tracks.custom_minimum_size.x = v.custom_minimum_size.x - INDENT
	v.add_child(_row(tracks))
	_section(v, "UI_ABOUT_AUDIO")
	for line in [
		"VSCO-2 CE & VCSL (CC0)",
		"Kenney RPG & Interface Sounds (CC0)",
		"Socapex - Evol Online SFX (CC BY 3.0)"
	]:
		var lbl := UIFx.text(line, "body", UIFx.DIM)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.custom_minimum_size.x = v.custom_minimum_size.x - INDENT
		v.add_child(_row(lbl))


## Texts built from more than one key (they do not retranslate on their own).
func _card_text() -> void:
	if _full_btn:
		_full_btn.text = "%s: %s" % [tr("UI_SYS_FULLSCREEN"), tr("UI_ON") if GameSettings.is_fullscreen() else tr("UI_OFF")]
	if _lang_btn:
		_lang_btn.text = "%s: %s" % [tr("UI_SYS_LANG"), GameSettings.language_name()]
	if _demo_cls_btn:
		var cls := load("res://data/classes/%s.tres" % DemoRoute.CLASSES[_demo_class]) as ClassData
		_demo_cls_btn.text = "%s: %s" % [tr("UI_DEMO_CLASS"), tr(cls.title) if cls else DemoRoute.CLASSES[_demo_class]]
	if _demo_list:
		_demo_fill()


# ---------------------------------------------------------------- Demo card (architecture.md 10b)

## Pick a class, an act, then a point in it: the start of the act, the arrival in one of its areas, or the
## door of one of its bosses. DemoRoute plays the story up to there; the run saves to its own slot.
func _build_demo(v: VBoxContainer) -> void:
	_demo_cps = DemoRoute.checkpoints()
	_demo_note = UIFx.text("UI_DEMO_NOTE", "body", UIFx.DIM)
	_demo_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_demo_note.custom_minimum_size.x = v.size.x - INDENT
	v.add_child(_row(_demo_note))
	_demo_cls_btn = LozengeButton.new("", 8)
	_demo_cls_btn.pressed.connect(func() -> void:
		_demo_class = (_demo_class + 1) % DemoRoute.CLASSES.size()
		_card_text())
	v.add_child(_demo_cls_btn)
	var acts := HBoxContainer.new()
	acts.add_theme_constant_override("separation", 0)
	for d in [-1, 1]:
		var b := LozengeButton.new("<" if d < 0 else ">", 8)
		b.custom_minimum_size.x = 16
		b.pressed.connect(func() -> void:
			_demo_act = posmod(_demo_act + d, DemoRoute.MAIN.size())
			_demo_fill())
		acts.add_child(b)
		if d < 0:
			_demo_act_lbl = UIFx.text("", "body", UIFx.WARM)
			_demo_act_lbl.custom_minimum_size.x = v.size.x - 40
			_demo_act_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			acts.add_child(_demo_act_lbl)
	v.add_child(acts)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(v.size.x, 104)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_demo_list = VBoxContainer.new()
	_demo_list.add_theme_constant_override("separation", 0)
	_demo_list.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.add_child(_demo_list)
	v.add_child(scroll)


## The act's name, then one entry per checkpoint of that act.
func _demo_fill() -> void:
	var q: String = DemoRoute.MAIN[_demo_act]
	_demo_act_lbl.text = "%s  ·  %s" % [DemoRoute.act_label(q), tr("Q_%s_TITLE" % q.to_upper())]
	for c in _demo_list.get_children():
		_demo_list.remove_child(c)
		c.queue_free()
	for cp: Dictionary in _demo_cps:
		if cp.quest != q:
			continue
		var b := LozengeButton.new(_demo_label(cp), 8)
		if cp.kind == "boss":
			b.add_theme_color_override("font_color", UIFx.WARM)
		b.pressed.connect(_go.bind(_demo_start.bind(cp)))
		_demo_list.add_child(b)


func _demo_label(cp: Dictionary) -> String:
	match String(cp.kind):
		"act":
			return tr("UI_DEMO_START")
		"boss":
			return tr("UI_DEMO_BOSS") % tr("BOSS_" + String(cp.boss).to_upper())
	var zone: String = cp.zone
	var key := "AREA_" + zone.to_upper()
	if tr(key) != key:
		return tr(key)
	return "Desa Purwa" if zone == "desa_purwa" else zone.substr(zone.find("_") + 1).replace("_", " ").capitalize()


func _demo_start(cp: Dictionary) -> void:
	var game := get_node("/root/Game")
	game.demo = true
	game.save_path = game.DEMO_SAVE
	var route := DemoRoute.new(game, get_node("/root/Zones"))
	var ok := route.build(DemoRoute.CLASSES[_demo_class], cp)
	for n in route.notes:
		push_warning("demo: " + n)
	if ok:
		route.place(cp)
		return
	game.demo = false
	game.save_path = game.SAVE_PATH
	game._reset()
	if _demo_note:
		_demo_note.text = "UI_DEMO_FAIL"
