extends MenuTab
## Penuntun (Controls), ui.md 4.3 tab 6. Placeholder: lists every action with its bound keys, read live from the
## InputMap, and a short how-to on the right. Rebinding and the looping drawing diagram come next.

const ACTIONS := ["move_up", "move_down", "move_left", "move_right", "attack", "cast", "dodge", "heal_jamu", "interact", "menu", "map", "pause"]

var _list: VBoxContainer


func title_key() -> String:
	return "UI_BK_TAB_CONTROLS"


func icon() -> String:
	return "controls"


func build(l: Control, r: Control) -> void:
	_list = scroll(l, Rect2(0, 0, 200, 212))
	var rv := scroll(r, Rect2(0, 0, 200, 212))
	rv.add_child(MenuBook.section(tr("UI_BK_HOWTO")))
	rv.add_child(MenuBook.text(tr("UI_BK_HOWTO_BODY"), MenuBook.INK_DIM, true))


func refresh() -> void:
	clear(_list)
	for a in ACTIONS:
		if not InputMap.has_action(a):
			continue
		var row := HBoxContainer.new()
		var name_ := MenuBook.bold(tr("UI_ACT_" + a.to_upper()))
		name_.custom_minimum_size.x = 96
		row.add_child(name_)
		var shown := {}
		for ev in InputMap.action_get_events(a):
			var t := ev.as_text().get_slice(" (", 0)
			if not shown.has(t):
				shown[t] = true
				row.add_child(MenuBook.keycap(t))
		_list.add_child(row)


func hints() -> Array:
	return [["@mouse", "UI_BK_HINT_SCROLL"]]
