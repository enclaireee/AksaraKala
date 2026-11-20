extends MenuTab
## Peta (Map), ui.md 4.3 tab 4: the illustrated world map and the painted area map across both pages (ui/map_view.gd).
## Accept (Enter / Space) flips between them, as does clicking the pill. Activated Petilasans allow Fast Travel.

var _view: MapView
var _note: Label
var _ft_bar: HBoxContainer
var _ft_lbl: Label
var _ft_prev: Button
var _ft_go: Button
var _ft_next: Button
var _ft_zones: Array[String] = []
var _ft_idx := 0


func title_key() -> String:
	return "UI_BK_TAB_MAP"


func icon() -> String:
	return "map"


func build(_l: Control, _r: Control) -> void:
	_view = MapView.new()
	put(self, _view, Vector2(12, 8), Vector2(432, 160))
	_note = MenuBook.text("", MenuBook.INK, true)
	put(self, _note, Vector2(12, 170), Vector2(432, 22))
	_ft_bar = HBoxContainer.new()
	_ft_bar.add_theme_constant_override("separation", 4)
	put(self, _ft_bar, Vector2(12, 196), Vector2(432, 22))
	_ft_lbl = MenuBook.bold(tr("UI_FT_LABEL"))
	_ft_bar.add_child(_ft_lbl)
	_ft_prev = MenuBook.small_button("<")
	_ft_prev.pressed.connect(_step_ft.bind(-1))
	_ft_bar.add_child(_ft_prev)
	_ft_go = MenuBook.small_button("")
	_ft_go.custom_minimum_size.x = 180
	_ft_go.pressed.connect(_do_fast_travel)
	_ft_bar.add_child(_ft_go)
	_ft_next = MenuBook.small_button(">")
	_ft_next.pressed.connect(_step_ft.bind(1))
	_ft_bar.add_child(_ft_next)


func hints() -> Array:
	return [["Enter", "UI_MAP_TOGGLE"], [game.key_name("interact"), "UI_VERB_TRAVEL"]]


func refresh() -> void:
	if not menu.visible:
		return
	_view.refresh(zone_name)
	var zones := get_node("/root/Zones")
	var z: String = zones.current_zone
	var line := "%s: %s" % [tr("UI_MAP_HERE"), zone_name(z)] if z != "" else ""
	var obj: String = game.objective_text()
	if obj != "":
		line += "\n" + tr("UI_MAP_GOAL") + ": " + obj
		var m: Dictionary = game.objective_marker()
		if m.get("zone", z) != z:
			line += "  (" + zone_name(str(m.zone)) + ")"
	_note.text = line
	_refresh_fast_travel(zones, z)


func _refresh_fast_travel(zones: Node, current_z: String) -> void:
	_ft_zones.clear()
	for zid: String in zones.PETILASANS:
		if zones.has_petilasan(zid) and zid != current_z:
			_ft_zones.append(zid)
	var blocked: bool = zones.sealed or game.in_memory()
	if _ft_zones.is_empty():
		_ft_idx = 0
		_ft_prev.disabled = true
		_ft_next.disabled = true
		_ft_go.disabled = true
		_ft_go.text = tr("UI_FT_LOCKED_WHY") if blocked else tr("UI_FT_NONE")
		return
	_ft_idx = clampi(_ft_idx, 0, _ft_zones.size() - 1)
	var multi := _ft_zones.size() > 1
	_ft_prev.disabled = blocked or not multi
	_ft_next.disabled = blocked or not multi
	_ft_go.disabled = blocked
	var dest := _ft_zones[_ft_idx]
	_ft_go.text = tr("UI_FT_LOCKED_WHY") if blocked else "%s: %s" % [tr("UI_VERB_TRAVEL"), zone_name(dest)]


func _step_ft(dir: int) -> void:
	if _ft_zones.is_empty():
		return
	_ft_idx = posmod(_ft_idx + dir, _ft_zones.size())
	_refresh_fast_travel(get_node("/root/Zones"), get_node("/root/Zones").current_zone)


func _do_fast_travel() -> void:
	var zones := get_node("/root/Zones")
	if _ft_zones.is_empty() or zones.sealed or game.in_memory():
		return
	var dest := _ft_zones[clampi(_ft_idx, 0, _ft_zones.size() - 1)]
	if zones.fast_travel(dest):
		menu.close()


func handle_input(e: InputEvent) -> bool:
	if e.is_action_pressed("ui_left") and _ft_zones.size() > 1:
		_step_ft(-1)
		return true
	if e.is_action_pressed("ui_right") and _ft_zones.size() > 1:
		_step_ft(1)
		return true
	if e.is_action_pressed("interact") and not _ft_go.disabled:
		_do_fast_travel()
		return true
	if e.is_action_pressed("ui_accept") and _view != null and _view.is_visible_in_tree():
		_view.toggle()
		return true
	return false
