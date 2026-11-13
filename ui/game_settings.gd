class_name GameSettings extends RefCounted
## Player settings in user://settings.cfg (path from the title script, so tests can redirect it): bus volumes,
## fullscreen, language, controls, comfort and assists (controls.md 6, balance.md 9).
## Shared by the title screen's Settings card and the pause menu's Sistem tab.

const TitleScript := preload("res://ui/title.gd")
const BUSES := ["Master", "Music", "SFX", "Ambience"]
const PRESETS := ["default", "left_handed"]


static func load_value(key: String, default: Variant) -> Variant:
	var cf := ConfigFile.new()
	cf.load(TitleScript.settings_path)
	return cf.get_value("settings", key, default)


static func save_value(key: String, v: Variant) -> void:
	var cf := ConfigFile.new()
	cf.load(TitleScript.settings_path)   # keep the other settings
	cf.set_value("settings", key, v)
	cf.save(TitleScript.settings_path)


static func volume(bus: String) -> int:
	return int(load_value("vol_" + bus.to_lower(), 100))


## Sets a bus volume (0-100), creating the bus on first use, without saving.
static func apply_volume(bus: String, pct: float) -> void:
	var i := AudioServer.get_bus_index(bus)
	if i < 0:
		AudioServer.add_bus()
		i = AudioServer.bus_count - 1
		AudioServer.set_bus_name(i, bus)
		AudioServer.set_bus_send(i, "Master")
	AudioServer.set_bus_volume_db(i, linear_to_db(maxf(pct, 0.0) / 100.0))


static func set_volume(bus: String, pct: float) -> void:
	apply_volume(bus, pct)
	save_value("vol_" + bus.to_lower(), int(pct))


static func apply_volumes() -> void:
	for b in BUSES:
		apply_volume(b, float(volume(b)))


static func is_fullscreen() -> bool:
	return DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]


static func set_fullscreen(on: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED)
	save_value("fullscreen", on)


## The saved window mode, applied once at boot (title screen). Headless runs keep their window as is.
static func apply_display() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var want := bool(load_value("fullscreen", false))
	if want != is_fullscreen():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if want else DisplayServer.WINDOW_MODE_WINDOWED)


static func toggle_language() -> String:
	var lang := "en" if TranslationServer.get_locale().begins_with("id") else "id"
	TranslationServer.set_locale(lang)
	TitleScript.save_language(lang)
	return lang


static func language_name() -> String:
	return "Bahasa Indonesia" if TranslationServer.get_locale().begins_with("id") else "English"


# --- Comfort & accessibility (controls.md 6) ---

static func screenshake() -> int:
	return clampi(int(load_value("screenshake", 100)), 0, 100)


static func set_screenshake(pct: int) -> void:
	save_value("screenshake", clampi(pct, 0, 100))


static func reduce_flashes() -> bool:
	return bool(load_value("reduce_flashes", false))


static func set_reduce_flashes(on: bool) -> void:
	save_value("reduce_flashes", on)


static func damage_numbers() -> bool:
	return bool(load_value("damage_numbers", true))


static func set_damage_numbers(on: bool) -> void:
	save_value("damage_numbers", on)


static func cursor_size() -> int:
	return 2 if int(load_value("cursor_size", 1)) >= 2 else 1


static func set_cursor_size(mult: int) -> void:
	save_value("cursor_size", 2 if mult >= 2 else 1)
	apply_cursor()


static func swap_mouse() -> bool:
	return bool(load_value("swap_mouse", false))


static func set_swap_mouse(on: bool) -> void:
	save_value("swap_mouse", on)
	apply_input()


static func toggle_cast() -> bool:
	return bool(load_value("toggle_cast", false))


static func set_toggle_cast(on: bool) -> void:
	save_value("toggle_cast", on)


static func control_preset() -> String:
	var p := str(load_value("control_preset", "default"))
	return p if p in PRESETS else "default"


static func set_control_preset(preset: String) -> void:
	save_value("control_preset", preset if preset in PRESETS else "default")
	apply_input()


static func slow_mo_strength() -> int:
	return clampi(int(load_value("slow_mo_strength", 20)), 10, 40)


static func set_slow_mo_strength(pct: int) -> void:
	save_value("slow_mo_strength", clampi(pct, 10, 40))


static func draw_time() -> float:
	return clampf(float(load_value("draw_time", 2.5)), 2.5, 5.0)


static func set_draw_time(sec: float) -> void:
	save_value("draw_time", clampf(sec, 2.5, 5.0))


static func guide_always_on() -> bool:
	return bool(load_value("guide_always_on", false))


static func set_guide_always_on(on: bool) -> void:
	save_value("guide_always_on", on)


# --- Assists (balance.md 9) ---

static func drawing_assist() -> bool:
	return bool(load_value("drawing_assist", false))


static func set_drawing_assist(on: bool) -> void:
	save_value("drawing_assist", on)


static func gentle_combat() -> bool:
	return bool(load_value("gentle_combat", false))


static func set_gentle_combat(on: bool) -> void:
	save_value("gentle_combat", on)


# --- Runtime application ---

static func _bind_keys(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		return
	InputMap.action_erase_events(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)


static func _bind_mouse(action: String, btn: MouseButton) -> void:
	if not InputMap.has_action(action):
		return
	InputMap.action_erase_events(action)
	var ev := InputEventMouseButton.new()
	ev.button_index = btn
	InputMap.action_add_event(action, ev)


## Applies mouse swap and control preset to InputMap (controls.md 2, 6).
static func apply_input() -> void:
	var sw := swap_mouse()
	_bind_mouse("attack", MOUSE_BUTTON_RIGHT if sw else MOUSE_BUTTON_LEFT)
	_bind_mouse("cast", MOUSE_BUTTON_LEFT if sw else MOUSE_BUTTON_RIGHT)
	if control_preset() == "left_handed":
		_bind_keys("move_up", [KEY_UP])
		_bind_keys("move_down", [KEY_DOWN])
		_bind_keys("move_left", [KEY_LEFT])
		_bind_keys("move_right", [KEY_RIGHT])
		_bind_keys("dodge", [KEY_CTRL])
		_bind_keys("heal_jamu", [KEY_SHIFT])
		_bind_keys("interact", [KEY_ENTER])
		_bind_keys("menu", [KEY_BACKSPACE])
	else:
		_bind_keys("move_up", [KEY_W, KEY_UP])
		_bind_keys("move_down", [KEY_S, KEY_DOWN])
		_bind_keys("move_left", [KEY_A, KEY_LEFT])
		_bind_keys("move_right", [KEY_D, KEY_RIGHT])
		_bind_keys("dodge", [KEY_SPACE])
		_bind_keys("heal_jamu", [KEY_Q])
		_bind_keys("interact", [KEY_E])
		_bind_keys("menu", [KEY_TAB])


## Scales the custom cursor (1x or 2x with high-contrast outline at 2x, controls.md 6).
static func apply_cursor() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var tex := ResourceLoader.load("res://assets/art/ui/cursor.png") as Texture2D
	if tex == null:
		return
	var img := tex.get_image()
	if cursor_size() >= 2:
		img = _outline_cursor(img)
	var k := maxi(1, int(DisplayServer.window_get_size().x / 480.0)) * cursor_size()
	if k > 1:
		img.resize(img.get_width() * k, img.get_height() * k, Image.INTERPOLATE_NEAREST)
	Input.set_custom_mouse_cursor(ImageTexture.create_from_image(img), Input.CURSOR_ARROW, Vector2.ZERO)


static func _outline_cursor(src: Image) -> Image:
	var w := src.get_width()
	var h := src.get_height()
	var out := Image.create(w + 2, h + 2, false, Image.FORMAT_RGBA8)
	var hi := Color(1.0, 1.0, 1.0, 0.95)
	for y in h:
		for x in w:
			if src.get_pixel(x, y).a > 0.1:
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						if dx != 0 or dy != 0:
							out.set_pixel(x + 1 + dx, y + 1 + dy, hi)
	for y in h:
		for x in w:
			var c := src.get_pixel(x, y)
			if c.a > 0.1:
				out.set_pixel(x + 1, y + 1, c)
	return out


static func apply_all() -> void:
	apply_volumes()
	apply_display()
	apply_input()
	apply_cursor()
