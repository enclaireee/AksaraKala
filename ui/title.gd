extends Control
## Title screen (rpg.md 11). Continue only with a save; New Game asks before overwriting.
## Language toggle (ID/EN) saved in user://settings.cfg. ponytail: Settings waits for the settings screen.

var _box: VBoxContainer
var _msg: Label
var _confirm: VBoxContainer
var _lang: Button

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
	var t := Theme.new()
	t.default_font_size = 8
	theme = t
	var bg := ColorRect.new()
	bg.color = Color("14110f")
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	var title := Label.new()
	title.text = "BUDAYAGO"
	title.position = Vector2(0, 50)
	title.size = Vector2(480, 16)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	_box = VBoxContainer.new()
	_box.position = Vector2(190, 100)
	_box.size = Vector2(100, 90)
	add_child(_box)
	if get_node("/root/Game").has_save():
		_btn("UI_CONTINUE", _continue)
	_btn("UI_NEW_GAME", _new)
	_btn("UI_QUIT", func() -> void: get_tree().quit())
	_lang = Button.new()
	_lang.position = Vector2(430, 8)
	_lang.size = Vector2(44, 16)
	_lang.pressed.connect(_toggle_lang)
	add_child(_lang)
	_lang_text()
	_msg = Label.new()
	_msg.position = Vector2(40, 220)
	_msg.size = Vector2(400, 24)
	_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_msg)
	_confirm = VBoxContainer.new()
	_confirm.position = Vector2(90, 100)
	_confirm.size = Vector2(300, 60)
	_confirm.visible = false
	add_child(_confirm)
	var q := Label.new()
	q.text = "UI_NEW_CONFIRM"
	q.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_confirm.add_child(q)
	var yes := Button.new()
	yes.text = "UI_YES"
	yes.pressed.connect(_to_class_select)
	_confirm.add_child(yes)
	var no := Button.new()
	no.text = "UI_CANCEL"
	no.pressed.connect(_show_menu)
	_confirm.add_child(no)
	_show_menu()


func _btn(text: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.pressed.connect(cb)
	_box.add_child(b)


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
	get_tree().change_scene_to_file("res://ui/prologue.tscn")
