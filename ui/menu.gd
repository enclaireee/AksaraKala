class_name GameMenu extends Control
## The field book (ui.md 4.3): hosts MenuBook (frame, ribbons, footer) and the seven tab spreads in ui/menu/.
## Q/E and the ribbons switch tabs; it reopens on the last tab used. Tabs refresh on open and on Game.changed.

const TitleScript := preload("res://ui/title.gd")   # settings path and language save (tests point it at a temp file)
const TAB_SCRIPTS := [
	preload("res://ui/menu/tab_status.gd"), preload("res://ui/menu/tab_equipment.gd"), preload("res://ui/menu/tab_journal.gd"),
	preload("res://ui/menu/tab_map.gd"), preload("res://ui/menu/tab_codex.gd"), preload("res://ui/menu/tab_controls.gd"),
	preload("res://ui/menu/tab_system.gd")]
const TURN_TIME := 0.14   # TUNE: page turn

var at_petilasan := false
var tabs: Array[MenuTab] = []
var book: MenuBook
var _tabs: TabContainer
var _last_tab := 0
var _prev_tab := 0
var _dim: ColorRect
var _tween: Tween


func _ready() -> void:
	add_to_group("game_menu")
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_dim = ColorRect.new()   # the world dims behind the book
	_dim.color = Color(0.02, 0.016, 0.014, 0.62)
	_dim.set_anchors_preset(PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_dim)
	book = MenuBook.new()
	add_child(book)
	_tabs = TabContainer.new()
	_tabs.tabs_visible = false   # the ribbons replace the tab bar
	_tabs.position = MenuBook.PAGES.position
	_tabs.size = MenuBook.PAGES.size
	var made: Array[MenuTab] = []
	for s in TAB_SCRIPTS:
		var t: MenuTab = s.new()
		made.append(t)
	var titles := []
	var icons := []
	for t in made:
		titles.append(t.title_key())
		icons.append(t.icon())
	book.build(titles, icons)
	book.content.add_child(_tabs)
	for t in made:
		_tabs.add_child(t)
		t.setup(self)
		tabs.append(t)
	book.ribbon_pressed.connect(_switch)
	_tabs.tab_changed.connect(_on_tab_changed)
	var g := get_node("/root/Game")
	g.changed.connect(refresh)
	get_node("/root/Events").rested.connect(func(_p: Node2D) -> void: open(true))
	refresh()


func current() -> MenuTab:
	return tabs[clampi(_tabs.current_tab, 0, tabs.size() - 1)]


func tab(i: int) -> MenuTab:
	return tabs[i]


func open(petilasan := false) -> void:
	at_petilasan = petilasan
	visible = true
	var pl := get_tree().get_first_node_in_group("player")
	if pl and pl.get("cast"):
		pl.cast.cancel()   # a paused tree never sees the cast release: slow-mo would stick
	get_tree().paused = true
	_set_hud(false)
	for t in tabs:
		t.cancel()
	refresh()
	_prev_tab = _last_tab
	_tabs.current_tab = _last_tab
	book.select(_last_tab)
	update_hints()
	current().focus_first()
	if _tween:
		_tween.kill()
	modulate.a = 0.0   # fade + rise 6 px (ui.md 4.3)
	book.position.y = 6.0
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(self, "modulate:a", 1.0, 0.2)
	_tween.tween_property(book, "position:y", 0.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func close() -> void:
	visible = false
	_set_hud(true)
	at_petilasan = false
	get_tree().paused = false


func refresh() -> void:
	for t in tabs:
		t.refresh()
	if book and visible:
		book.select(_tabs.current_tab)
		update_hints()


## Footer: the open tab's hints plus the book-wide ones.
func update_hints() -> void:
	if book == null:
		return
	var h: Array = current().hints().duplicate()
	h.append(["Q E", "UI_BK_HINT_TABS"])
	h.append(["Esc", "UI_BK_HINT_BACK"])
	book.set_hints(h)


func _switch(i: int) -> void:
	if _tabs.current_tab == i:
		return
	current().cancel()
	_tabs.current_tab = i
	current().focus_first()


func _on_tab_changed(i: int) -> void:
	_last_tab = i
	book.select(i)
	update_hints()
	var dir := signi(i - _prev_tab)
	_prev_tab = i
	if dir != 0 and visible:
		_turn.call_deferred(_tabs.get_current_tab_control(), dir)


## Page turn: the spread slides 12 px in the switch direction while fading in.
func _turn(c: Control, dir: int) -> void:
	if c == null or not is_instance_valid(c):
		return
	var x := c.position.x
	c.position.x = x + 12.0 * dir
	c.modulate.a = 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(c, "position:x", x, TURN_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(c, "modulate:a", 1.0, TURN_TIME)


func _modal_open() -> bool:
	return current().is_modal()


func _input(e: InputEvent) -> void:
	var box := get_node_or_null("../DialogueBox")
	var lesson := get_node_or_null("../GlyphLesson")
	if (box and box.is_open()) or (lesson and lesson.writing != ""):
		return   # the box and the write card own pause and input while they are open
	if (e.is_action_pressed("menu") and not _modal_open()) or (e.is_action_pressed("pause") and not visible):
		if visible:
			close()
		else:
			open()
		get_viewport().set_input_as_handled()
	elif visible and e is InputEventKey and e.pressed and not e.echo and e.physical_keycode in [KEY_Q, KEY_E]:
		_switch(posmod(_tabs.current_tab + (1 if e.physical_keycode == KEY_E else -1), tabs.size()))
		get_viewport().set_input_as_handled()
	elif visible and current().handle_input(e):
		get_viewport().set_input_as_handled()
	elif visible and e.is_action_pressed("pause"):
		var t := current()
		if t.is_modal():
			t.cancel()   # the first Esc dismisses a modal, the next closes the menu
			update_hints()
		elif not t.back():
			close()
		get_viewport().set_input_as_handled()


## The HUD (quest tracker, banner, arrow) would show through the dimmed world.
func _set_hud(on: bool) -> void:
	var hud := get_node_or_null("../HUD")
	if hud:
		hud.visible = on
