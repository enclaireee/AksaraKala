class_name GameSettings extends RefCounted
## Player settings in user://settings.cfg (path from the title script, so tests can redirect it): bus volumes,
## fullscreen and language. Shared by the title screen's Settings card and the pause menu's Sistem tab.

const TitleScript := preload("res://ui/title.gd")
const BUSES := ["Master", "Music", "SFX", "Ambience"]


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
