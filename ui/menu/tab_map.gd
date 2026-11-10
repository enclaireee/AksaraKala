extends MenuTab
## Peta (Map), ui.md 4.3 tab 4: the illustrated world map and the painted area map across both pages (ui/map_view.gd).
## Accept (Enter / Space) flips between them, as does clicking the pill.

var _view: MapView
var _note: Label


func title_key() -> String:
	return "UI_BK_TAB_MAP"


func icon() -> String:
	return "map"


func build(_l: Control, _r: Control) -> void:
	_view = MapView.new()
	put(self, _view, Vector2(12, 8), Vector2(432, 184))
	_note = MenuBook.text("", MenuBook.INK, true)
	put(self, _note, Vector2(12, 196), Vector2(432, 24))


func refresh() -> void:
	if not menu.visible:
		return
	_view.refresh(zone_name)
	var z: String = get_node("/root/Zones").current_zone
	var line := "%s: %s" % [tr("UI_MAP_HERE"), zone_name(z)] if z != "" else ""
	var obj: String = game.objective_text()
	if obj != "":
		line += "\n" + tr("UI_MAP_GOAL") + ": " + obj
		var m: Dictionary = game.objective_marker()
		if m.get("zone", z) != z:
			line += "  (" + zone_name(str(m.zone)) + ")"
	_note.text = line


func handle_input(e: InputEvent) -> bool:
	if e.is_action_pressed("ui_accept") and _view != null and _view.is_visible_in_tree():
		_view.toggle()
		return true
	return false
