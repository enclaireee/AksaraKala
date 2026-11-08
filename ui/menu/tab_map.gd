extends MenuTab
## Peta (Map), ui.md 4.3 tab 4. Ported unchanged from the old menu (ui/map_view.gd draws the current zone) and laid
## across both pages; the hand-inked world map of ui.md 4.3 replaces it next.

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
