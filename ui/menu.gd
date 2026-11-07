class_name GameMenu extends Control
## Tab menu: Status (level-up at a petilasan), Equipment, Journal, Codex (ui.md 3, rpg.md 2, 6, 7, quests.md 7.4).
## Q/E switch tabs; it reopens on the last tab used. ponytail: the Aksara tab waits for its own system.

const GOLD := Color("F2D488")   # prada gold highlight (ui.md 3b)
const NAMES := {"vit": "UI_STAT_VIT", "end": "UI_STAT_END", "str": "UI_STAT_STR", "dex": "UI_STAT_DEX", "spi": "UI_STAT_SPI"}
const HINTS := {"vit": "UI_HINT_VIT", "end": "UI_HINT_END", "str": "UI_HINT_STR", "dex": "UI_HINT_DEX", "spi": "UI_HINT_SPI"}
const SLOTS := ["weapon", "armor", "accessory"]
const CATS := ["enemy", "legend", "item", "aksara"]
const DIM := Color("9C8F78")
const GREEN := Color("6FCF8A")
const RED := Color("E0644A")
const TitleScript := preload("res://ui/title.gd")   # settings path and language save
const BUSES := ["Master", "Music", "SFX"]
const ITEM_DIR := "res://assets/art/items/"
const STAT_LABELS := {"max_hp": "HP", "move_speed": "Speed", "stamina_regen": "Stamina regen", "damage": "ATK", "defense": "DEF"}

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
var _prev_tab := 0
var _panel: Panel
var _tween: Tween
var _tip_name: Label
var _tip_slot: Label
var _tip_stats: VBoxContainer
var _tip_desc: Label
var _system: VBoxContainer
var _jlist: VBoxContainer
var _jsel := ""   # quest id shown in the journal detail pane
var _ilmu_bar: ProgressBar
var _derived: Label
var _map_view: MapView
var _map_note: Label
var _sys_modal: HBoxContainer
var _sys_modal_lbl: Label
var _sys_action := ""   # "title" or "quit" while the confirmation modal is open
var _sys_lang: Button
var _sys_full: Button
var _footer: Label
var _eq_focus := ""   # item id focused in the equipment grid (kept across a rebuild)


func _ready() -> void:
	add_to_group("game_menu")
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_panel = Panel.new()
	_panel.position = Vector2(60, 20)
	_panel.size = Vector2(360, 230)
	add_child(_panel)
	_tabs = TabContainer.new()
	_tabs.set_anchors_preset(PRESET_FULL_RECT)
	_tabs.offset_left = 5
	_tabs.offset_top = 3
	_tabs.offset_right = -5
	_tabs.offset_bottom = -5
	_panel.add_child(_tabs)
	_build_status()
	_equip = VBoxContainer.new()
	_equip.name = "Equipment"
	_tabs.add_child(_equip)
	var jroot := HBoxContainer.new()
	jroot.name = "Journal"
	_tabs.add_child(jroot)
	var jl := ScrollContainer.new()
	jl.custom_minimum_size.x = 118
	jl.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	jroot.add_child(jl)
	_jlist = VBoxContainer.new()
	_jlist.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	jl.add_child(_jlist)
	jroot.add_child(VSeparator.new())
	var jr := ScrollContainer.new()
	jr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	jr.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	jroot.add_child(jr)
	_journal = VBoxContainer.new()
	_journal.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	jr.add_child(_journal)
	_build_map()
	_codex = _scroll("Codex")
	_build_system()
	_tabs.tab_alignment = TabBar.ALIGNMENT_CENTER
	_tabs.offset_bottom = -16
	_footer = Label.new()
	_footer.text = "UI_FOOTER"
	_footer.position = Vector2(8, 216)
	_footer.size = Vector2(344, 12)
	_footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_footer.add_theme_color_override("font_color", DIM)
	_panel.add_child(_footer)
	for side in 2:   # shoulder prompts at both ends of the tab bar (ui.md 3)
		var sh := Label.new()
		sh.text = "[Q]" if side == 0 else "[E]"
		sh.position = Vector2(6 if side == 0 else 332, 4)
		sh.add_theme_color_override("font_color", GOLD)
		_panel.add_child(sh)
	_apply_settings()
	_tabs.tab_changed.connect(func(i: int) -> void:
		_last_tab = i
		_refresh_map()
		var dir := signi(i - _prev_tab)
		_prev_tab = i
		if dir != 0 and visible:
			_slide_page.call_deferred(_tabs.get_current_tab_control(), dir))
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
	var root := HBoxContainer.new()
	root.name = "Status"
	_tabs.add_child(root)
	# left card: who you are
	var card := VBoxContainer.new()
	card.custom_minimum_size.x = 120
	root.add_child(card)
	_summary = Label.new()
	_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_summary.custom_minimum_size.x = 118
	card.add_child(_summary)
	_ilmu_bar = ProgressBar.new()
	_ilmu_bar.custom_minimum_size = Vector2(110, 8)
	_ilmu_bar.show_percentage = false
	card.add_child(_ilmu_bar)
	_hint = Label.new()
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.custom_minimum_size.x = 118
	_hint.add_theme_color_override("font_color", DIM)
	card.add_child(_hint)
	root.add_child(VSeparator.new())
	# right: attributes, then the numbers they give
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(v)
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
	v.add_child(HSeparator.new())
	_derived = Label.new()
	_derived.add_theme_color_override("font_color", GOLD)
	v.add_child(_derived)


## Numbers the attributes and gear give right now (ATK from the weapon, HP from the live hero).
func _refresh_derived(g: Node) -> void:
	var lines := PackedStringArray()
	var pl := get_tree().get_first_node_in_group("player")
	if pl and pl.get("health"):
		lines.append("%s %d" % [tr("UI_DER_HP"), pl.health.max_hp])
	var w: ItemData = g.equipped_item("weapon")
	if w:
		lines.append("%s %d" % [tr("UI_DER_ATK"), w.damage])
	lines.append("%s %d" % [tr("UI_DER_DEF"), int(g.bonus("defense"))])
	lines.append("%s %d/%d" % [tr("UI_DER_FLASK"), g.flask_charges, g.flask_max])
	_derived.text = "   ".join(lines)


func open(petilasan := false) -> void:
	at_petilasan = petilasan
	visible = true
	var pl := get_tree().get_first_node_in_group("player")
	if pl and pl.get("cast"):
		pl.cast.cancel()   # a paused tree never sees the cast release: slow-mo would stick
	get_tree().paused = true
	_set_hud(false)
	_cancel()
	refresh()
	_prev_tab = _last_tab
	_tabs.current_tab = _last_tab
	_focus_tab()
	if _tween:
		_tween.kill()
	modulate.a = 0.0   # fade + rise 6 px (ui.md 3b)
	_panel.position.y = 26.0
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(self, "modulate:a", 1.0, 0.2)
	_tween.tween_property(_panel, "position:y", 20.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


## Page slide: 12 px in the switch direction while fading in (ui.md 3b).
func _slide_page(c: Control, dir: int) -> void:
	if c == null or not is_instance_valid(c):
		return
	var x := c.position.x
	c.position.x = x + 12.0 * dir
	c.modulate.a = 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(c, "position:x", x, 0.18).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(c, "modulate:a", 1.0, 0.18)


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
	_set_hud(true)
	at_petilasan = false
	get_tree().paused = false


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
		if _pending != "" or _sys_action != "":
			_cancel()   # the first Esc dismisses a modal, the next closes the menu
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
	_sys_action = ""
	if _sys_modal:
		_sys_modal.visible = false
	var s := _pending
	_pending = ""
	_confirm.visible = false
	if s != "" and _raise[s].is_inside_tree() and not _raise[s].disabled:
		_raise[s].grab_focus()


func refresh() -> void:
	var g := get_node("/root/Game")
	var can: bool = at_petilasan and g.ilmu >= g.level_cost()
	_summary.text = tr("UI_LEVEL_LINE") % [g.level(), g.ilmu, g.level_cost()]
	_ilmu_bar.max_value = maxf(g.level_cost(), 1)
	_ilmu_bar.value = mini(g.ilmu, g.level_cost())
	_refresh_derived(g)
	_hint.text = "" if at_petilasan else "UI_REST_HINT"
	for s in NAMES:
		_stat_lbl[s].text = "%s %d  (%s)" % [tr(NAMES[s]), g.stat(s), tr(HINTS[s])]
		_raise[s].disabled = not can
	if not can:
		_confirm.visible = false
	_refresh_equipment(g)
	for i in _tabs.get_tab_count():
		_tabs.set_tab_title(i, ["UI_TAB_STATUS", "UI_TAB_EQUIP", "UI_TAB_JOURNAL", "UI_TAB_MAP", "UI_TAB_PUSTAKA", "UI_TAB_SYSTEM"][i])
	_refresh_journal(g)
	_refresh_codex(g)
	_refresh_system()
	_refresh_map()


func _item_icon(item: ItemData) -> Texture2D:
	var tex: Variant = item.get("icon")   # `icon` export may be absent: fall back to the sheet by id
	if tex is Texture2D:
		return tex
	var path := ITEM_DIR + item.id + ".png"
	return load(path) if ResourceLoader.exists(path) else null


## Equipment tab: a 20x20 slot grid per slot kind with item icons, and a tooltip panel (ui.md 3b).
func _refresh_equipment(g: Node) -> void:
	_clear(_equip)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	_equip.add_child(row)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(left)
	var tip := PanelContainer.new()
	tip.custom_minimum_size = Vector2(150, 0)
	tip.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row.add_child(tip)
	var tv := VBoxContainer.new()
	tv.add_theme_constant_override("separation", 2)
	tip.add_child(tv)
	_tip_name = Label.new()
	_tip_name.theme_type_variation = &"HeaderLarge"
	_tip_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tip_name.custom_minimum_size.x = 134
	tv.add_child(_tip_name)
	_tip_slot = Label.new()
	_tip_slot.theme_type_variation = &"Dim"
	tv.add_child(_tip_slot)
	_tip_stats = VBoxContainer.new()
	_tip_stats.add_theme_constant_override("separation", 0)
	tv.add_child(_tip_stats)
	_tip_desc = Label.new()
	_tip_desc.theme_type_variation = &"Dim"
	_tip_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tip_desc.custom_minimum_size.x = 134
	tv.add_child(_tip_desc)
	var focus_btn: Button = null
	for slot in SLOTS:
		var h := Label.new()
		h.text = "UI_SLOT_" + slot.to_upper()
		h.theme_type_variation = &"Heading"
		left.add_child(h)
		var grid := GridContainer.new()
		grid.columns = 8
		grid.add_theme_constant_override("h_separation", 2)
		grid.add_theme_constant_override("v_separation", 2)
		left.add_child(grid)
		for id in g.inventory:
			var item := ItemData.by_id(id)
			if item == null or item.slot != slot:
				continue   # ponytail: an item whose data is missing is not listed
			var b := _slot_button(g, item)
			grid.add_child(b)
			if g.equipped.get(slot, "") == id:   # the equipped slot keeps the gold frame
				b.add_theme_stylebox_override("normal", b.get_theme_stylebox("hover", "SlotButton"))
			if id == _eq_focus:
				focus_btn = b
	_show_tip(null, g)
	if focus_btn and visible:
		focus_btn.grab_focus.call_deferred()


func _slot_button(g: Node, item: ItemData) -> Button:
	var b := Button.new()
	b.theme_type_variation = &"SlotButton"
	b.custom_minimum_size = Vector2(20, 20)
	b.focus_mode = Control.FOCUS_ALL
	b.tooltip_text = ""
	var tex := _item_icon(item)
	if tex:
		b.icon = tex
		b.expand_icon = false
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	else:
		b.text = tr(item.title).left(2)
	b.pressed.connect(g.equip.bind(item.id))
	b.focus_entered.connect(func() -> void:
		_eq_focus = item.id
		_show_tip(item, g))
	b.mouse_entered.connect(func() -> void: _show_tip(item, g))
	return b


## Tooltip: name (Cinzel), slot, bonus lines (green up / red down against the equipped item), description.
func _show_tip(item: ItemData, g: Node) -> void:
	if _tip_name == null:
		return
	for c in _tip_stats.get_children():
		_tip_stats.remove_child(c)
		c.queue_free()
	if item == null:
		_tip_name.text = ""
		_tip_slot.text = ""
		_tip_desc.text = ""
		return
	_tip_name.text = tr(item.title)
	_tip_name.add_theme_color_override("font_color", GOLD if item.mythic else Color("EDE3CC"))
	_tip_slot.text = "UI_SLOT_" + item.slot.to_upper()
	var cur: ItemData = g.equipped_item(item.slot)
	var mine := _item_stats(item)
	var theirs := _item_stats(cur) if cur and cur != item else {}
	var same := cur == item
	for k in mine:
		var line := Label.new()
		line.text = "%s %s" % [_stat_name(k), _fmt(mine[k])]
		if not same:
			var d: float = mine[k] - theirs.get(k, 0.0)
			if absf(d) > 0.001:
				line.text += " (%s%s)" % ["+" if d > 0 else "-", _fmt(absf(d))]
				line.add_theme_color_override("font_color", GREEN if d > 0 else RED)
		_tip_stats.add_child(line)
	if not same:   # a stat only the equipped item has shows as a loss
		for k in theirs:
			if not mine.has(k):
				var l2 := Label.new()
				l2.text = "%s 0 (-%s)" % [_stat_name(k), _fmt(absf(theirs[k]))]
				l2.add_theme_color_override("font_color", RED)
				_tip_stats.add_child(l2)
	_tip_desc.text = tr(item.description) + ("\n" + tr(item.lore) if item.mythic and item.lore != "" else "")


func _item_stats(item: ItemData) -> Dictionary:
	var out := {}
	if item == null:
		return out
	if item.slot == "weapon":
		out["damage"] = float(item.damage)
	if item.defense != 0:
		out["defense"] = float(item.defense)
	for k in item.bonus:
		out[k] = float(item.bonus[k])
	return out


func _stat_name(k: String) -> String:
	return tr(NAMES[k]) if NAMES.has(k) else STAT_LABELS.get(k, k.capitalize())


func _fmt(v: float) -> String:
	return str(int(v)) if is_equal_approx(v, roundf(v)) else "%.2f" % v


func _clear(box: Control) -> void:
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()


func _label(box: Control, text: String, color := Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if color == GOLD:
		l.theme_type_variation = &"Heading"
	else:
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
	_clear(_jlist)
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
	var first: QuestData = null
	for key in ["main", "side", "done"]:
		if not lists[key].is_empty():
			first = lists[key][0]
			break
	if not g.quests.has(_jsel) or QuestData.by_id(_jsel) == null:
		_jsel = ""
	if _jsel == "" and first:
		_jsel = first.id
	if first == null:
		_label(_journal, "UI_JOURNAL_EMPTY", DIM)
	for key in ["main", "side", "done"]:
		if lists[key].is_empty():
			continue
		_label(_jlist, "UI_JOURNAL_" + key.to_upper(), GOLD)
		for q: QuestData in lists[key]:
			var b := Button.new()
			b.text = ("> " if q.id == _jsel else "") + tr("Q_%s_TITLE" % q.id.to_upper()) + (" *" if g.pinned == q.id else "")
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.clip_text = true
			b.custom_minimum_size.x = 110
			b.pressed.connect(func() -> void:
				_jsel = q.id
				_refresh_journal(g))
			_jlist.add_child(b)
	if _jsel != "":
		_quest_block(g, QuestData.by_id(_jsel), g.quest_state(_jsel) == "done")
	_story_and_clues(g)
	if focus_pin != "":
		for b in _journal.find_children("*", "Button", true, false):
			if b.get_meta("pin", "") == focus_pin:
				b.grab_focus()


## "Story so far": recap of every step below the current one (all steps when done); "Clues": set clue_* flags.
func _story_and_clues(g: Node) -> void:
	var recaps := PackedStringArray()
	for id in g.quests:
		var q := QuestData.by_id(id)
		var st: String = g.quest_state(id)
		if q == null or st == "available" or q.kind != "main":
			continue
		var cur: int = q.steps.size() if st == "done" else int(g.quests[id].step)
		for i in mini(cur, q.steps.size()):
			var r: String = q.steps[i].get("recap") if q.steps[i].get("recap") != null else ""
			if r != "":
				recaps.append(tr(r))
	if not recaps.is_empty():
		_label(_journal, "UI_JOURNAL_STORY", GOLD)
		for r in recaps.slice(-6):   # ui.md: last 6 only
			_label(_journal, r, DIM)
	var notes := PackedStringArray()
	for f: String in g.flags:
		if f.begins_with("clue_") and g.has_flag(f):
			var k := "CLUE_%s_NOTE" % f.trim_prefix("clue_").to_upper()
			if tr(k) != k:
				notes.append(tr(k))
	if not notes.is_empty():
		_label(_journal, "UI_JOURNAL_CLUES", GOLD)
		for n in notes:
			_label(_journal, n, DIM)


func _quest_block(g: Node, q: QuestData, done: bool) -> void:
	var title := tr("Q_%s_TITLE" % q.id.to_upper())
	if g.pinned == q.id:
		title += " " + tr("UI_PINNED")
	_label(_journal, title)
	_label(_journal, "%s: %s" % [tr("UI_ZONE"), _zone_name(q.zone)], DIM)
	var dk := "Q_%s_DESC" % q.id.to_upper()
	if tr(dk) != dk:
		var dl := _label(_journal, tr(dk))
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		dl.custom_minimum_size.x = 200
	if done:
		return
	var cur: int = int(g.quests[q.id].step)
	for i in mini(cur + 1, q.steps.size()):
		if i == cur and not q.steps[i].all.is_empty():
			_label(_journal, "  " + tr(q.steps[i].objective))
			for c in g.step_checklist(q.id):
				_label(_journal, ("    [x] " if c.done else "    [>] " if c.active else "    [ ] ") + c.text,
						DIM if c.done else GOLD if c.active else Color.WHITE)
			continue
		var obj := tr(q.steps[i].objective)
		if i < cur:
			_label(_journal, "  ✓ " + obj, DIM)
		else:
			if q.steps[i].count > 1:
				obj += " (%d/%d)" % [int(g.quests[q.id].get("count", 0)), q.steps[i].count]
			_label(_journal, "  > " + obj)
	var st: QuestStep = g.current_step(q.id)
	if st:
		if not st.marker.is_empty() and str(st.marker.get("zone", "")) != q.zone:
			_label(_journal, "%s: %s" % [tr("UI_WHERE"), _zone_name(str(st.marker.get("zone", "")))], GOLD)
		var hk := st.objective.replace("_OBJ", "_HINT")
		if tr(hk) != hk:
			var keys := {}
			for act in ["interact", "cast", "attack", "dodge", "menu"]:
				keys[act] = g.key_name(act)
			keys.move = "%s%s%s%s" % [g.key_name("move_up"), g.key_name("move_left"), g.key_name("move_down"), g.key_name("move_right")]
			_label(_journal, "%s: %s" % [tr("UI_TIP"), tr(hk).format(keys)], DIM)
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


# --- System tab: audio, language, display, session (ui.md 3) ---

func _build_system() -> void:
	_system = _scroll("System")
	for b in BUSES:
		var row := HBoxContainer.new()
		_system.add_child(row)
		var l := Label.new()
		l.text = "UI_SYS_" + b.to_upper()
		l.custom_minimum_size.x = 110
		row.add_child(l)
		var sl := HSlider.new()
		sl.name = b
		sl.min_value = 0
		sl.max_value = 100
		sl.step = 5
		sl.custom_minimum_size = Vector2(160, 12)
		sl.value = _load_setting("vol_" + b.to_lower(), 100)
		sl.value_changed.connect(_set_volume.bind(b))
		row.add_child(sl)
	_sys_lang = _sys_button(_toggle_language)
	_sys_full = _sys_button(_toggle_fullscreen)
	_sys_button(close).text = "UI_SYS_RESUME"
	_sys_button(_ask_sys.bind("title")).text = "UI_SYS_TITLE"
	_sys_button(_ask_sys.bind("quit")).text = "UI_SYS_QUIT"
	_sys_modal = HBoxContainer.new()
	_sys_modal.visible = false
	_system.add_child(_sys_modal)
	_sys_modal_lbl = Label.new()
	_sys_modal.add_child(_sys_modal_lbl)
	var yes := Button.new()
	yes.text = "UI_YES"
	yes.pressed.connect(_do_sys)
	_sys_modal.add_child(yes)
	var no := Button.new()
	no.text = "UI_CANCEL"
	no.pressed.connect(_cancel)
	_sys_modal.add_child(no)


func _sys_button(cb: Callable) -> Button:
	var b := Button.new()
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.pressed.connect(cb)
	_system.add_child(b)
	return b


func _refresh_system() -> void:
	_sys_lang.text = "%s: %s" % [tr("UI_SYS_LANG"), "Bahasa Indonesia" if TranslationServer.get_locale().begins_with("id") else "English"]
	_sys_full.text = "%s: %s" % [tr("UI_SYS_FULLSCREEN"), tr("UI_ON") if _is_fullscreen() else tr("UI_OFF")]


func _is_fullscreen() -> bool:
	return DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]


func _load_setting(key: String, default: Variant) -> Variant:
	var cf := ConfigFile.new()
	cf.load(TitleScript.settings_path)
	return cf.get_value("settings", key, default)


func _save_setting(key: String, v: Variant) -> void:
	var cf := ConfigFile.new()
	cf.load(TitleScript.settings_path)   # keep the other settings
	cf.set_value("settings", key, v)
	cf.save(TitleScript.settings_path)


## Volumes and display from user://settings.cfg; the Music and SFX buses are created on first use.
func _apply_settings() -> void:
	for b in BUSES:
		_apply_volume(b, float(_load_setting("vol_" + b.to_lower(), 100)))


func _apply_volume(bus: String, pct: float) -> void:
	var i := AudioServer.get_bus_index(bus)
	if i < 0:
		AudioServer.add_bus()
		i = AudioServer.bus_count - 1
		AudioServer.set_bus_name(i, bus)
		AudioServer.set_bus_send(i, "Master")
	AudioServer.set_bus_volume_db(i, linear_to_db(pct / 100.0))


func _set_volume(v: float, bus: String) -> void:
	_apply_volume(bus, v)
	_save_setting("vol_" + bus.to_lower(), int(v))


func _toggle_language() -> void:
	var lang := "en" if TranslationServer.get_locale().begins_with("id") else "id"
	TranslationServer.set_locale(lang)
	TitleScript.save_language(lang)
	refresh()


func _toggle_fullscreen() -> void:
	var on := not _is_fullscreen()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED)
	_save_setting("fullscreen", on)
	refresh()


func _modal_open() -> bool:
	return _pending != "" or _sys_action != ""


func _ask_sys(action: String) -> void:
	_sys_action = action
	_sys_modal_lbl.text = "UI_SYS_CONFIRM_" + action.to_upper()
	_sys_modal.visible = true


func _do_sys() -> void:
	var action := _sys_action
	_cancel()
	close()
	if action == "title":
		get_tree().change_scene_to_file("res://ui/title.tscn")
	elif action == "quit":
		get_tree().quit()


# --- Peta tab ---

func _build_map() -> void:
	var v := VBoxContainer.new()
	v.name = "Map"
	_tabs.add_child(v)
	_map_view = MapView.new()
	_map_view.custom_minimum_size = Vector2(340, 162)
	v.add_child(_map_view)
	_map_note = Label.new()
	_map_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_map_note.custom_minimum_size.x = 340
	v.add_child(_map_note)


func _refresh_map() -> void:
	if _map_view == null or not visible:
		return
	_map_view.refresh(_zone_name)
	var g := get_node("/root/Game")
	var z: String = get_node("/root/Zones").current_zone
	var line := "%s: %s" % [tr("UI_MAP_HERE"), _zone_name(z)] if z != "" else ""
	var obj: String = g.objective_text()
	if obj != "":
		line += "\n" + tr("UI_MAP_GOAL") + ": " + obj
		var m: Dictionary = g.objective_marker()
		if m.get("zone", z) != z:
			line += "  (" + _zone_name(str(m.zone)) + ")"
	_map_note.text = line


## The HUD (objective lines, compass) would show through the translucent panel.
func _set_hud(on: bool) -> void:
	var hud := get_node_or_null("../HUD")
	if hud:
		hud.visible = on
