extends MenuTab
## Penuntun (Controls), ui.md 4.3 tab 6: live InputMap bindings with compact keycaps on the left,
## animated Sunda Ka stroke-order diagram and casting guide on the right.

const ACTIONS := ["move_up", "move_down", "move_left", "move_right", "attack", "cast", "dodge", "heal_jamu", "interact", "menu", "map", "pause"]

var _list: VBoxContainer
var _list_scroll: ScrollContainer
var _diagram: GestureDiagram


func title_key() -> String:
	return "UI_BK_TAB_CONTROLS"


func icon() -> String:
	return "controls"


func build(l: Control, r: Control) -> void:
	put(l, MenuBook.section(tr("UI_BK_TAB_CONTROLS")), Vector2.ZERO)
	_list = scroll(l, Rect2(0, 20, 200, 192))
	_list.add_theme_constant_override("separation", 3)
	_list_scroll = _list.get_parent()
	var rv := scroll(r, Rect2(0, 0, 200, 212))
	rv.add_theme_constant_override("separation", 4)
	rv.add_child(MenuBook.section(tr("UI_BK_HOWTO")))
	rv.add_child(MenuBook.text(tr("UI_BK_HOWTO_BODY"), MenuBook.INK_DIM, true))
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", MenuBook.box("book_card", 4, 4))
	frame.custom_minimum_size = Vector2(192, 78)
	frame.mouse_filter = MOUSE_FILTER_IGNORE
	rv.add_child(frame)
	_diagram = GestureDiagram.new()
	_diagram.custom_minimum_size = Vector2(184, 70)
	frame.add_child(_diagram)


static func _short_key(raw: String) -> String:
	var s := raw.get_slice(" (", 0).trim_suffix(" - Physical")
	match s:
		"Left Mouse Button":
			return "LMB"
		"Right Mouse Button":
			return "RMB"
		"Middle Mouse Button":
			return "MMB"
		"Escape":
			return "Esc"
		"Backspace":
			return "Bksp"
		"Control":
			return "Ctrl"
	return s


func refresh() -> void:
	clear(_list)
	for a in ACTIONS:
		if not InputMap.has_action(a):
			continue
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		row.custom_minimum_size.y = 14
		var name_ := MenuBook.bold(tr("UI_ACT_" + a.to_upper()), MenuBook.INK)
		name_.custom_minimum_size.x = 100
		name_.clip_text = true
		row.add_child(name_)
		var shown := {}
		for ev in InputMap.action_get_events(a):
			var t := _short_key(ev.as_text())
			if not shown.has(t):
				shown[t] = true
				row.add_child(MenuBook.keycap(t))
		_list.add_child(row)


func handle_input(e: InputEvent) -> bool:
	if e.is_action_pressed("ui_up", true):
		_list_scroll.scroll_vertical -= 20
		return true
	if e.is_action_pressed("ui_down", true):
		_list_scroll.scroll_vertical += 20
		return true
	return false


func hints() -> Array:
	return [["@updown", "UI_BK_HINT_SCROLL"]]


## Live pixel-art stroke preview of Sundanese Ka inside the Controls card.
class GestureDiagram extends Control:
	var _pts := PackedVector2Array()
	var _t := 0.0
	var _redraw_t := 0.0

	func _ready() -> void:
		mouse_filter = MOUSE_FILTER_IGNORE
		var g := GlyphData.by_id("sunda_ka")
		if g == null or g.templates.is_empty():
			return
		var raw: PackedVector2Array = g.templates[0]
		var bb := Rect2(raw[0], Vector2.ZERO)
		for p in raw:
			bb = bb.expand(p)
		var box := Vector2(84, 48)
		var s := minf(box.x / maxf(bb.size.x, 1.0), box.y / maxf(bb.size.y, 1.0))
		var center := Vector2(92, 35)
		for p in raw:
			_pts.append((center + (p - bb.get_center()) * s).round())

	func _process(d: float) -> void:
		if not is_visible_in_tree():
			return
		_t = fmod(_t + d, 2.8)
		_redraw_t += d
		if _redraw_t >= 0.05:
			_redraw_t = 0.0
			queue_redraw()

	func _draw() -> void:
		if _pts.size() < 2:
			return
		draw_dashed_line(_pts[0], _pts[0], UIFx.LINE_DIM, 1.0)
		for i in _pts.size() - 1:
			draw_dashed_line(_pts[i], _pts[i + 1], Color(UIFx.DIM, 0.45), 1.0, 2.0)
		draw_rect(Rect2(_pts[0] - Vector2(2, 2), Vector2(4, 4)), UIFx.WARM)
		var prog := clampf(_t / 1.8, 0.0, 1.0)
		var max_i := clampi(int(prog * (_pts.size() - 1)), 0, _pts.size() - 1)
		for i in max_i:
			draw_line(_pts[i], _pts[i + 1], UIFx.ACCENT, 2.0)
		var tip := _pts[max_i]
		if prog < 1.0:
			draw_rect(Rect2(tip - Vector2(2, 2), Vector2(4, 4)), UIFx.HEAD)
