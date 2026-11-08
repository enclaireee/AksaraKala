extends MenuTab
## Catatan (Journal), ui.md 4.3 tab 3. Left page: quests grouped Utama / Sampingan / Selesai with seal icons and a
## tracked marker; confirm tracks / untracks. Right page: title, region, objective checklist (bullet assets), story
## log (step recaps), choices (remember_*) and clues grouped by the quest that hunts them. Both pages scroll; scroll,
## selection and focus survive Game.changed.

const GROUPS := ["main", "side", "done"]
const SEALS := {"main": "book_seal_main", "side": "book_seal_side", "done": "book_seal_done"}

var sel := ""                  # quest id shown on the right page
var detail: VBoxContainer      # right page contents (GameMenu._journal; tests read its Labels)
var _list: VBoxContainer
var _list_scroll: ScrollContainer
var _detail_scroll: ScrollContainer
var _rows := {}                # quest id -> row Button
var _clue_quest := {}          # clue id -> quest id (built once from QuestData steps)


func title_key() -> String:
	return "UI_BK_TAB_JOURNAL"


func icon() -> String:
	return "journal"


func build(l: Control, r: Control) -> void:
	_list = scroll(l, Rect2(0, 0, 200, 212))
	_list.add_theme_constant_override("separation", 0)
	_list_scroll = _list.get_parent()
	detail = scroll(r, Rect2(0, 0, 200, 212))
	detail.add_theme_constant_override("separation", 3)
	_detail_scroll = detail.get_parent()


func _lists(g: Node) -> Dictionary:
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
	return lists


func _tracked_id(g: Node) -> String:
	var t: Array = g._tracked()
	return t[0] if not t.is_empty() else ""


func refresh() -> void:
	var g := game
	var vp := get_viewport()
	var fo: Control = vp.gui_get_focus_owner() if vp else null
	var focus_q: String = fo.get_meta("quest", "") if fo and is_ancestor_of(fo) else ""
	var list_scroll := _list_scroll.scroll_vertical
	var lists := _lists(g)
	if not g.quests.has(sel) or QuestData.by_id(sel) == null:
		sel = ""
	if sel == "":
		for k in GROUPS:
			if not lists[k].is_empty():
				sel = lists[k][0].id
				break
	clear(_list)
	_rows.clear()
	var tracked := _tracked_id(g)
	for k in GROUPS:
		if lists[k].is_empty():
			continue
		var hdr := HBoxContainer.new()
		hdr.custom_minimum_size.y = 16
		hdr.add_theme_constant_override("separation", 4)
		var seal := MenuBook.pic(SEALS[k], Vector2.ZERO)
		seal.size_flags_vertical = SIZE_SHRINK_CENTER
		hdr.add_child(seal)
		var hl := MenuBook.head(tr("UI_JOURNAL_" + k.to_upper()))
		hl.size_flags_horizontal = SIZE_EXPAND_FILL
		hdr.add_child(hl)
		var cnt := MenuBook.num(str(lists[k].size()), MenuBook.INK_FADE)
		hdr.add_child(cnt)
		if _list.get_child_count() > 0:
			var gap := Control.new()
			gap.custom_minimum_size.y = 4
			_list.add_child(gap)
		_list.add_child(hdr)
		var rule := MenuBook.nine("book_rule", Rect2(0, 0, 200, 3), 8)
		rule.patch_margin_top = 0
		rule.patch_margin_bottom = 0
		rule.custom_minimum_size = Vector2(200, 3)
		_list.add_child(rule)
		for q: QuestData in lists[k]:
			_list.add_child(_row(g, q, k, tracked))
	if _list.get_child_count() == 0:
		_list.add_child(MenuBook.italic(tr("UI_JOURNAL_EMPTY"), MenuBook.INK_FADE))
	_fill_detail(g)
	_restore.call_deferred(list_scroll, focus_q)


func _restore(list_scroll: int, focus_q: String) -> void:
	_list_scroll.scroll_vertical = list_scroll
	if focus_q != "" and _rows.has(focus_q):
		_rows[focus_q].grab_focus()


func _row(g: Node, q: QuestData, group: String, tracked: String) -> Button:
	var b := MenuBook.row_button(16)
	b.set_meta("quest", q.id)
	if group == "side":
		b.set_meta("pin", q.id)   # `interact` also tracks, as before
	MenuBook.set_row_selected(b, q.id == sel)
	var title := MenuBook.text(tr("Q_%s_TITLE" % q.id.to_upper()), MenuBook.INK_FADE if group == "done" else MenuBook.INK)
	title.clip_text = true
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	put(b, title, Vector2(14, 2), Vector2(184, 12))
	if q.id == tracked:
		put(b, MenuBook.pic("book_track", Vector2.ZERO), Vector2(4, 4))
	elif group == "done":
		var chk := MenuBook.pic("bullet_check", Vector2.ZERO)
		chk.modulate.a = 0.7
		put(b, chk, Vector2(3, 4))
	b.focus_entered.connect(func() -> void:
		if sel != q.id:
			_select(q.id)
		menu.update_hints())
	b.pressed.connect(func() -> void: _track(q.id))
	_rows[q.id] = b
	return b


func _select(id: String) -> void:
	sel = id
	for qid in _rows:
		MenuBook.set_row_selected(_rows[qid], qid == sel)
	_fill_detail(game)
	_detail_scroll.scroll_vertical = 0


## Confirm on a quest: an active side quest is tracked (or untracked); a main quest clears the pin so the main quest
## is followed again. Finished quests do nothing.
func _track(id: String) -> void:
	var g := game
	if g.quest_state(id) != "active":
		return
	var q := QuestData.by_id(id)
	if q.kind == "side":
		g.pin_quest(id)
	elif g.pinned != "":
		g.pin_quest(g.pinned)


func handle_input(e: InputEvent) -> bool:
	if e.is_action_pressed("interact"):
		var f := get_viewport().gui_get_focus_owner()
		if f and is_ancestor_of(f) and f.has_meta("pin"):
			game.pin_quest(f.get_meta("pin"))
			return true
	return false


# --- right page ---

func _label(t: String, color := MenuBook.INK) -> Label:
	var l := MenuBook.text(t, color, true)
	detail.add_child(l)
	return l


func _sub(t: String) -> void:
	var gap := Control.new()
	gap.custom_minimum_size.y = 2
	detail.add_child(gap)
	detail.add_child(MenuBook.bold(t, MenuBook.INK_HEAD))


func _bullet(t: String, kind: String, color := MenuBook.INK) -> Label:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var b := MenuBook.pic(kind, Vector2.ZERO)
	b.size_flags_vertical = SIZE_SHRINK_BEGIN
	var wrap := MarginContainer.new()   # nudge the 7 px bullet onto the first text line
	wrap.add_theme_constant_override("margin_top", 3)
	wrap.add_child(b)
	row.add_child(wrap)
	var l := MenuBook.text(t, color, true)
	row.add_child(l)
	detail.add_child(row)
	return l


func _fill_detail(g: Node) -> void:
	clear(detail)
	var q := QuestData.by_id(sel) if sel != "" else null
	if q == null:
		_label(tr("UI_JOURNAL_EMPTY"), MenuBook.INK_FADE)
		_story_and_clues(g, "")
		return
	var done: bool = g.quest_state(q.id) == "done"
	var title := MenuBook.head(tr("Q_%s_TITLE" % q.id.to_upper()))
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.size_flags_horizontal = SIZE_EXPAND_FILL
	detail.add_child(title)
	var meta := HBoxContainer.new()
	meta.add_theme_constant_override("separation", 3)
	var pin := MenuBook.pic("book_ic_pin", Vector2.ZERO)
	pin.size_flags_vertical = SIZE_SHRINK_CENTER
	meta.add_child(pin)
	var zl := MenuBook.italic(zone_name(q.zone), MenuBook.INK_DIM, false)
	zl.size_flags_horizontal = SIZE_EXPAND_FILL
	meta.add_child(zl)
	if q.id == _tracked_id(g):
		meta.add_child(MenuBook.bold(tr("UI_BK_TRACKED"), MenuBook.WAX))
	elif done:
		meta.add_child(MenuBook.bold(tr("UI_JOURNAL_DONE"), MenuBook.VERD))
	detail.add_child(meta)
	var rule := MenuBook.nine("book_rule", Rect2(0, 0, 196, 3), 8)
	rule.patch_margin_top = 0
	rule.patch_margin_bottom = 0
	rule.custom_minimum_size = Vector2(0, 3)
	detail.add_child(rule)
	var dk := "Q_%s_DESC" % q.id.to_upper()
	if tr(dk) != dk:
		_label(tr(dk))
	var cur: int = q.steps.size() if done else int(g.quests[q.id].step)
	if not done and cur < q.steps.size():   # the open question
		_sub(tr("UI_BK_OBJECTIVE"))
		var step: QuestStep = q.steps[cur]
		if not step.all.is_empty():
			for c in g.step_checklist(q.id):
				_bullet(c.text, "bullet_check" if c.done else "bullet_now" if c.active else "bullet_open",
						MenuBook.INK_FADE if c.done else MenuBook.INK)
		else:
			var obj := tr(step.objective)
			if step.count > 1:
				obj += " (%d/%d)" % [int(g.quests[q.id].get("count", 0)), step.count]
			_bullet(obj, "bullet_now")
		var st: QuestStep = g.current_step(q.id)
		if st:
			if not st.marker.is_empty() and str(st.marker.get("zone", "")) != q.zone:
				_bullet("%s: %s" % [tr("UI_WHERE"), zone_name(str(st.marker.get("zone", "")))], "book_ic_pin", MenuBook.INK_DIM)
			var hk := st.objective.replace("_OBJ", "_HINT")
			if tr(hk) != hk:
				var keys := {}
				for act in ["interact", "cast", "attack", "dodge", "menu"]:
					keys[act] = g.key_name(act)
				keys.move = "%s%s%s%s" % [g.key_name("move_up"), g.key_name("move_left"), g.key_name("move_down"), g.key_name("move_right")]
				var tip := MenuBook.italic("%s: %s" % [tr("UI_TIP"), tr(hk).format(keys)])
				detail.add_child(tip)
	var entry := PackedStringArray()   # finished steps read as one flowing entry, in order
	for i in mini(cur, q.steps.size()):
		if q.steps[i].recap != "":
			entry.append(tr(q.steps[i].recap))
	if not entry.is_empty():
		_sub(tr("UI_JOURNAL_STORY"))
		_label(" ".join(entry), MenuBook.INK_DIM)
	_story_and_clues(g, q.id)


## Choices: set remember_* flags as their REMEMBER_<KEY> sentence. Clues: set clue_* flags as CLUE_<ID>_NOTE, grouped
## by the quest whose steps examine them (this quest first); clues no quest names go under "Other".
func _story_and_clues(g: Node, qid: String) -> void:
	var choices := PackedStringArray()
	var keys: Array = g.flags.keys()
	keys.sort()   # the order flags were set is not stored: alphabetical is stable
	for f: String in keys:
		if f.begins_with("remember_") and g.has_flag(f):
			var rk := "REMEMBER_%s" % f.trim_prefix("remember_").to_upper()
			if tr(rk) != rk:
				choices.append(tr(rk))
	if not choices.is_empty():
		_sub(tr("UI_JOURNAL_CHOICES"))
		for c in choices:
			var l := MenuBook.italic(c, MenuBook.INK)
			detail.add_child(l)
	var groups := {}   # quest id ("" = other) -> notes
	for f: String in keys:
		if f.begins_with("clue_") and g.has_flag(f):
			var cid := f.trim_prefix("clue_")
			var k := "CLUE_%s_NOTE" % cid.to_upper()
			if tr(k) != k:
				groups.get_or_add(_clue_owner(cid), []).append(tr(k))
	if groups.is_empty():
		return
	_sub(tr("UI_JOURNAL_CLUES"))
	var order: Array = groups.keys()
	order.sort_custom(func(x: String, y: String) -> bool:
		return x == qid or (y != qid and x != "" and (y == "" or x < y)))
	for owner: String in order:
		if order.size() > 1 or owner != qid:
			var t := tr("Q_%s_TITLE" % owner.to_upper()) if owner != "" else tr("UI_BK_OTHER")
			detail.add_child(MenuBook.italic(t, MenuBook.INK_DIM, false))
		for n in groups[owner]:
			_bullet(n, "bullet_open", MenuBook.INK)


func _clue_owner(cid: String) -> String:
	if _clue_quest.is_empty():
		_clue_quest[""] = ""   # built marker
		for q in QuestData.all():
			if q == null:
				continue
			for st: QuestStep in q.steps:
				var ons := [st.on]
				for a: Dictionary in st.all:
					ons.append(str(a.get("on", "")))
				for o: String in ons:
					if o.begins_with("clue_examined:"):
						_clue_quest[o.trim_prefix("clue_examined:")] = q.id
	return _clue_quest.get(cid, "")


func focus_first() -> void:
	if _rows.has(sel):
		_rows[sel].grab_focus()
	elif not _rows.is_empty():
		_rows.values()[0].grab_focus()


func hints() -> Array:
	var h := [["@updown", "UI_BK_HINT_SELECT"]]
	var g := game
	if sel != "" and g.quest_state(sel) == "active":
		var q := QuestData.by_id(sel)
		if q and q.kind == "side":
			h.append(["Enter", "UI_UNPIN" if g.pinned == sel else "UI_PIN"])
		elif q and g.pinned != "":
			h.append(["Enter", "UI_PIN"])
	return h
