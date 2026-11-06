class_name GameMenu extends Control
## Tab menu: Status (level-up at a petilasan), Equipment, Journal, Codex (ui.md 3, rpg.md 2, 6, 7, quests.md 7.4).
## Q/E switch tabs; it reopens on the last tab used. ponytail: the Aksara tab waits for its own system.

const GOLD := Color("E8D9A0")
const NAMES := {"vit": "UI_STAT_VIT", "end": "UI_STAT_END", "str": "UI_STAT_STR", "dex": "UI_STAT_DEX", "spi": "UI_STAT_SPI"}
const HINTS := {"vit": "UI_HINT_VIT", "end": "UI_HINT_END", "str": "UI_HINT_STR", "dex": "UI_HINT_DEX", "spi": "UI_HINT_SPI"}
const SLOTS := ["weapon", "armor", "accessory"]
const CATS := ["enemy", "legend", "item", "aksara"]
const DIM := Color(0.6, 0.6, 0.6)

var at_petilasan := false
var _pending := ""
var _tabs: TabContainer
var _summary: Label
var _hint: Label
var _raise := {}   # stat -> Button
var _stat_lbl := {}
var _confirm: HBoxContainer
var _confirm_lbl: Label
var _confirm_yes: Button
var _equip: VBoxContainer
var _journal: VBoxContainer
var _codex: VBoxContainer
var _last_tab := 0


func _ready() -> void:
	add_to_group("game_menu")
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	var t := Theme.new()
	t.default_font_size = 8
	theme = t
	var panel := Panel.new()
	panel.position = Vector2(60, 20)
	panel.size = Vector2(360, 230)
	add_child(panel)
	_tabs = TabContainer.new()
	_tabs.set_anchors_preset(PRESET_FULL_RECT)
	panel.add_child(_tabs)
	_build_status()
	_equip = VBoxContainer.new()
	_equip.name = "Equipment"
	_tabs.add_child(_equip)
	_journal = _scroll("Journal")
	_codex = _scroll("Codex")
	_tabs.tab_changed.connect(func(i: int) -> void: _last_tab = i)
	var g := get_node("/root/Game")
	g.changed.connect(refresh)
	get_node("/root/Events").rested.connect(func(_p: Node2D) -> void: open(true))


func _scroll(tab_name: String) -> VBoxContainer:
	var sc := ScrollContainer.new()
	sc.name = tab_name
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_tabs.add_child(sc)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(v)
	return v


func _build_status() -> void:
	var v := VBoxContainer.new()
	v.name = "Status"
	_tabs.add_child(v)
	_summary = Label.new()
	v.add_child(_summary)
	for s in NAMES:
		var row := HBoxContainer.new()
		v.add_child(row)
		var l := Label.new()
		l.custom_minimum_size.x = 200
		row.add_child(l)
		_stat_lbl[s] = l
		var b := Button.new()
		b.text = "+"
		b.custom_minimum_size = Vector2(24, 14)
		b.pressed.connect(_ask.bind(s))
		row.add_child(b)
		_raise[s] = b
	_hint = Label.new()
	v.add_child(_hint)
	_confirm = HBoxContainer.new()
	_confirm.visible = false
	v.add_child(_confirm)
	_confirm_lbl = Label.new()
	_confirm.add_child(_confirm_lbl)
	_confirm_yes = Button.new()
	_confirm_yes.text = "UI_YES"
	_confirm_yes.pressed.connect(_do_raise)
	_confirm.add_child(_confirm_yes)
	var no := Button.new()
	no.text = "UI_CANCEL"
	no.pressed.connect(_cancel)
	_confirm.add_child(no)


func open(petilasan := false) -> void:
	at_petilasan = petilasan
	visible = true
	var pl := get_tree().get_first_node_in_group("player")
	if pl and pl.get("cast"):
		pl.cast.cancel()   # a paused tree never sees the cast release: slow-mo would stick
	get_tree().paused = true
	_cancel()
	refresh()
	_tabs.current_tab = _last_tab
	_focus_tab()


func _focus_tab() -> void:
	var first: Control = null
	if _tabs.current_tab == 0:
		first = _raise.vit
		for s in _raise:
			if not _raise[s].disabled:
				first = _raise[s]
				break
	else:
		first = _first_button(_tabs.get_current_tab_control())
	if first:
		first.grab_focus()


func _first_button(n: Node) -> Button:
	if n is Button and n.focus_mode != Control.FOCUS_NONE:
		return n
	for c in n.get_children():
		var b := _first_button(c)
		if b:
			return b
	return null


func close() -> void:
	visible = false
	at_petilasan = false
	get_tree().paused = false


func _input(e: InputEvent) -> void:
	var box := get_node_or_null("../DialogueBox")
	var lesson := get_node_or_null("../GlyphLesson")
	if (box and box.is_open()) or (lesson and lesson.writing != ""):
		return   # the box and the write card own pause and input while they are open
	if e.is_action_pressed("menu"):
		if visible:
			close()
		else:
			open()
		get_viewport().set_input_as_handled()
	elif visible and e is InputEventKey and e.pressed and not e.echo and e.physical_keycode in [KEY_Q, KEY_E]:
		var n := _tabs.get_tab_count()
		_tabs.current_tab = posmod(_tabs.current_tab + (1 if e.physical_keycode == KEY_E else -1), n)
		_cancel()
		_focus_tab()
		get_viewport().set_input_as_handled()
	elif visible and e.is_action_pressed("interact"):
		var f := get_viewport().gui_get_focus_owner()
		if f and f.has_meta("pin"):
			get_node("/root/Game").pin_quest(f.get_meta("pin"))
			get_viewport().set_input_as_handled()
	elif visible and e.is_action_pressed("pause"):
		if _pending != "":
			_cancel()
		else:
			close()
		get_viewport().set_input_as_handled()


func _ask(stat: String) -> void:
	_pending = stat
	_confirm_lbl.text = tr("UI_RAISE_Q") % [tr(NAMES[stat]), get_node("/root/Game").level_cost()]
	_confirm.visible = true
	_confirm_yes.grab_focus()


func _do_raise() -> void:
	if _pending != "":
		get_node("/root/Game").level_up(_pending)
	_cancel()


func _cancel() -> void:
	var s := _pending
	_pending = ""
	_confirm.visible = false
	if s != "" and _raise[s].is_inside_tree() and not _raise[s].disabled:
		_raise[s].grab_focus()


func refresh() -> void:
	var g := get_node("/root/Game")
	var can: bool = at_petilasan and g.ilmu >= g.level_cost()
	_summary.text = tr("UI_LEVEL_LINE") % [g.level(), g.ilmu, g.level_cost()]
	_hint.text = "" if at_petilasan else "UI_REST_HINT"
	for s in NAMES:
		_stat_lbl[s].text = "%s %d  (%s)" % [tr(NAMES[s]), g.stat(s), tr(HINTS[s])]
		_raise[s].disabled = not can
	if not can:
		_confirm.visible = false
	_refresh_equipment(g)
	for i in _tabs.get_tab_count():
		_tabs.set_tab_title(i, ["UI_TAB_STATUS", "UI_TAB_EQUIP", "UI_TAB_JOURNAL", "UI_TAB_CODEX"][i])
	_refresh_journal(g)
	_refresh_codex(g)


func _refresh_equipment(g: Node) -> void:
	for c in _equip.get_children():
		_equip.remove_child(c)
		c.queue_free()
	for slot in SLOTS:
		var h := Label.new()
		h.text = "UI_SLOT_" + slot.to_upper()
		_equip.add_child(h)
		for id in g.inventory:
			var item := ItemData.by_id(id)
			if item == null or item.slot != slot:
				continue   # ponytail: an item whose data is missing is not listed
			var b := Button.new()
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.text = ("> " if g.equipped.get(slot, "") == id else "  ") + tr(item.title)
			b.pressed.connect(g.equip.bind(id))
			if item.mythic:
				b.add_theme_color_override("font_color", GOLD)
			_equip.add_child(b)
			if item.mythic:
				var l := Label.new()
				l.text = "   " + tr(item.lore)
				l.add_theme_color_override("font_color", GOLD)
				_equip.add_child(l)


func _clear(box: Control) -> void:
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()


func _label(box: Control, text: String, color := Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.modulate = color
	box.add_child(l)
	return l


func _zone_name(zone: String) -> String:
	var key := "UI_ZONE_" + zone.to_upper()
	return tr(key) if tr(key) != key else zone.capitalize()


## Journal: Main, Side, Done. Quests come from the ids in Game.quests; missing data is skipped.
func _refresh_journal(g: Node) -> void:
	var focus_pin: String = get_viewport().gui_get_focus_owner().get_meta("pin", "") if get_viewport().gui_get_focus_owner() else ""
	_clear(_journal)
	var lists := {"main": [], "side": [], "done": []}
	for id in g.quests:
		var q := QuestData.by_id(id)
		if q == null:
			continue
		var st: String = g.quest_state(id)
		if st == "done":
			lists.done.append(q)
		elif st == "active":
			lists[q.kind].append(q)
	var any := false
	for key in lists:
		if lists[key].is_empty():
			continue
		any = true
		_label(_journal, "UI_JOURNAL_" + key.to_upper(), GOLD)
		for q: QuestData in lists[key]:
			_quest_block(g, q, key == "done")
	if not any:
		_label(_journal, "UI_JOURNAL_EMPTY", DIM)
	if focus_pin != "":
		for b in _journal.find_children("*", "Button", true, false):
			if b.get_meta("pin", "") == focus_pin:
				b.grab_focus()


func _quest_block(g: Node, q: QuestData, done: bool) -> void:
	var title := tr("Q_%s_TITLE" % q.id.to_upper())
	if g.pinned == q.id:
		title += " " + tr("UI_PINNED")
	_label(_journal, title)
	_label(_journal, "%s: %s" % [tr("UI_ZONE"), _zone_name(q.zone)], DIM)
	if done:
		return
	var cur: int = int(g.quests[q.id].step)
	for i in mini(cur + 1, q.steps.size()):
		var obj := tr(q.steps[i].objective)
		if i < cur:
			_label(_journal, "  ✓ " + obj, DIM)
		else:
			if q.steps[i].count > 1:
				obj += " (%d/%d)" % [int(g.quests[q.id].get("count", 0)), q.steps[i].count]
			_label(_journal, "  > " + obj)
	if q.kind == "side":
		var b := Button.new()
		b.text = "UI_UNPIN" if g.pinned == q.id else "UI_PIN"
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.set_meta("pin", q.id)
		b.pressed.connect(g.pin_quest.bind(q.id))
		_journal.add_child(b)


## Codex: per category, unlocked entries in full, locked ones as "???". Weakness only once seen.
func _refresh_codex(g: Node) -> void:
	_clear(_codex)
	var by_cat := {}
	for f in DirAccess.get_files_at(CodexEntry.dir):
		var e := CodexEntry.by_id(f.trim_suffix(".remap").trim_suffix(".tres"))
		if e and f.contains(".tres"):
			by_cat.get_or_add(e.category, []).append(e)
	if by_cat.is_empty():
		_label(_codex, "UI_CODEX_EMPTY", DIM)
		return
	_label(_codex, tr("UI_CODEX_PERCENT") % int(g.codex_percent()), GOLD)
	for cat in CATS:
		if not by_cat.has(cat):
			continue
		_label(_codex, "UI_CAT_" + cat.to_upper(), GOLD)
		for e: CodexEntry in by_cat[cat]:
			var U := e.id.to_upper()
			if e.id not in g.codex:
				_label(_codex, "UI_LOCKED", DIM)
				continue
			_label(_codex, "CODEX_%s_TITLE" % U)
			_label(_codex, "CODEX_%s_BODY" % U, DIM)
			if g.has_flag("weak:" + e.id):
				_label(_codex, "%s: %s" % [tr("UI_WEAKNESS"), tr("CODEX_%s_WEAK" % U)])
