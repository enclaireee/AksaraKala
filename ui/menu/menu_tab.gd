class_name MenuTab extends Control
## One page spread of the field book (ui.md 4.3). GameMenu adds it to its TabContainer, calls setup() once, then
## refresh() on open and on every Game.changed. Coordinates are local to the spread (MenuBook.PAGES, 456x228):
## LEFT and RIGHT are the 200x212 content areas of the two pages (8 px grid, whole pixels).
##
## Interface every tab implements (all optional except build):
##   title_key() -> String       ribbon label (translation key)
##   icon() -> String            ribbon icon, book_tab_<icon>.png
##   build(left, right)          create the page contents once
##   refresh()                   re-read Game state; keep scroll, selection and focus
##   hints() -> Array            footer hints for the current focus: [[key text or "@icon", label key], ...]
##   handle_input(e) -> bool     tab-specific keys; true when consumed
##   back() -> bool              Esc: true when the tab closed one of its own levels (modal, zoom), else the menu closes
##   is_modal() -> bool          a confirm is open (Tab must not close the menu)
##   cancel()                    drop any open confirm (tab switch, menu open)
##   focus_first()               give focus to the first useful control when the tab is shown

const LEFT := Rect2(12, 8, 200, 212)
const RIGHT := Rect2(244, 8, 200, 212)

var menu: Control   # GameMenu
var game: Node
var left: Control
var right: Control


func setup(m: Control) -> void:
	menu = m
	game = m.get_node("/root/Game")
	mouse_filter = MOUSE_FILTER_IGNORE
	left = _page(LEFT, "Left")
	right = _page(RIGHT, "Right")
	build(left, right)


func _page(r: Rect2, n: String) -> Control:
	var c := Control.new()
	c.name = n
	c.position = r.position
	c.size = r.size
	c.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(c)
	return c


func title_key() -> String:
	return ""


func icon() -> String:
	return ""


func build(_left: Control, _right: Control) -> void:
	pass


func refresh() -> void:
	pass


func hints() -> Array:
	return []


func handle_input(_e: InputEvent) -> bool:
	return false


func back() -> bool:
	return false


func is_modal() -> bool:
	return false


func cancel() -> void:
	pass


func focus_first() -> void:
	pass


# --- helpers shared by the tabs ---

func put(parent: Control, c: Control, pos: Vector2, sz := Vector2.ZERO) -> Control:
	c.position = pos
	if sz != Vector2.ZERO:
		c.size = sz
	parent.add_child(c)
	return c


func scroll(parent: Control, r: Rect2) -> VBoxContainer:
	var sc := ScrollContainer.new()
	sc.position = r.position
	sc.size = r.size
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.follow_focus = true
	parent.add_child(sc)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 2)
	sc.add_child(v)
	return v


func clear(box: Node) -> void:
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()


func zone_name(zone: String) -> String:
	var key := "UI_ZONE_" + zone.to_upper()
	return tr(key) if tr(key) != key else zone.capitalize()


func is_shown() -> bool:
	return is_visible_in_tree()
