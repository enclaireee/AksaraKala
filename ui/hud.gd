extends Control
## In-play HUD (ui.md 2). Placeholder bars; reads the player's components every frame.
## ponytail: polling instead of signals so a replaced player (scene change) needs no re-bind.

const HP_COL := Color("D55E00")
const ST_COL := Color("F0E442")
const SK_COL := Color("56B4E9")
const FLASK_COL := Color("009E73")
const GOLD := UIFx.WARM        # quest amber (ui.md 0.1)
const CREAM := UIFx.CREAM
const OUTLINE := UIFx.LACQUER
const M := 8.0                 # screen-safe margin (ui.md 2)
const HP_W := 100              # vitals widths (interior px)
const ST_W := 72
const UI_DIR := "res://assets/art/ui/"
const LAG_HOLD := 0.4   # s before the cream lag chunk drains
const LOW_HP := 0.25
const MAX_OBJ := 4   # objective rows shown before "+n more"
const TRACKER_W := 124   # TUNE: tracker width, text wraps inside
const TRACKER_REST_A := 0.5   # TUNE: tracker opacity once it has sat unchanged for TRACKER_IDLE
const TRACKER_IDLE := 5.0   # TUNE: s at full opacity after a change before it dims
const MENU_HINT_SHOW := 25.0   # s the [Esc] hint stays before it fades

var _bars := {}   # name -> [fill ColorRect, width, frame, lag ColorRect, well ColorRect]
var _pips: Array[TextureRect] = []
var _ilmu: Label        # logical value ("%d"), hidden; _ilmu_disp is the rolling one the player sees
var _ilmu_disp: Label
var _ilmu_shown := -1.0
var _weapon_icon: TextureRect
var _flask_full: Texture2D
var _flask_empty: Texture2D
var _lag := -1.0
var _lag_hold := 0.0
var _hp_prev := -1.0
var _st_full := 0.0
var _st_nodes: Array[CanvasItem] = []
var _t := 0.0
var _saved: Label
var _saved_icon: TextureRect
var _saved_left := 0.0
const DIM := UIFx.DIM
var _tracker_panel: PanelContainer   # framed card around the tracker (ui.md 2, pixel pass)
var _tracker: VBoxContainer   # inside the card: title, rule, then the objectives (docs/quest_system.md 3.1)
var _grp_hide: Control   # fades out while a dialogue is open: tracker, flasks, weapon, Ilmu, hints
var _grp_bars: Control   # dims to 40% while a dialogue is open: the vitals
var _dialogue_focus := false
var _focus_tw: Tween
var _hp_txt: Label   # "120/120" right of the HP bar
var _dist_bg: ColorRect   # lacquer pill behind the distance label
var _menu_hint: Label
var _tracker_sig := ""
var _pulse_tw: Tween
var _sub_seen := {}   # quest id -> [step, finished sub-goals] last seen, to spot a new step or sub-goal

# quest banner (docs/quest_system.md 3.3): caption + title or new objective, queued, one at a time
const BANNER_TIME := 3.6
var _banner_root: Control
var _banner_head: Label
var _banner_body: Label
var _banners: Array = []
var _banner_left := 0.0
var _player: Node   # the player whose `blocked` signal is connected (a new zone brings a new one)

# toasts (quests.md 7.6): one at a time, TOAST_TIME each, queued
const TOAST_TIME := 3.0
var _toast: Label
var _toast_root: Control
var _toast_rule: ColorRect
var _toasts: Array[String] = []
var _toast_left := 0.0

# objective arrow (quests.md 7.5)
const SCREEN := Vector2(480, 270)
const ARROW_MARGIN := 10.0
var _arrow: Node2D
var _tnode: Node2D   # what the arrow points at: a marker node, or the exit toward the target zone
var _tzone := ""     # the target's zone while _tnode is only the exit toward it, else ""
var _diamond: Node2D   # marker over an on-screen target
var _dist: Label       # metres to the target, or "-> zone" when it is elsewhere

# boss bar (ui.md 2). Contract: node in group "boss" with `health` (Health), `boss_name_key: String`,
# optional `dawn: float` (0-1), optional `sequence: PackedStringArray` + `seq_index: int` (shown while dawn
# is set), and `engaged: bool` which the HUD polls. Shown while engaged and alive.
const BOSS_W := 240
var _boss_root: Control
var _boss_name: Label
var _boss_fill: ColorRect
var _boss_mark: Node2D   # cracked-glyph mark at the bar end: the boss's Laras sabotage flag is set (ui.md 2, v5)
var _dawn_bg: ColorRect
var _dawn_fill: ColorRect


func _ready() -> void:
	_flask_full = _ui_tex("flask_full")
	_flask_empty = _ui_tex("flask_empty")
	_grp_bars = _group()
	_grp_hide = _group()
	# vitals, top left: three bare bars on one left edge, 2 px apart; HP carries its number to the right
	_bars.hp = _bar(Vector2(M, M), HP_W, 6, HP_COL, _grp_bars)
	_bars.st = _bar(Vector2(M, M + 10), ST_W, 3, ST_COL, _grp_bars)
	_bars.sk = _bar(Vector2(M, M + 17), 60, 3, SK_COL, _grp_bars)
	_st_nodes = [_bars.st[2], _bars.st[4], _bars.st[5]]
	_hp_txt = UIFx.text("", "body", CREAM)
	_hp_txt.position = Vector2(M + HP_W + 2 + 4, M - 1)
	_hp_txt.size = Vector2(48, 9)
	_hp_txt.modulate.a = 0.85
	_grp_bars.add_child(_hp_txt)
	var well := TextureRect.new()   # weapon well, bottom left, with the flasks on its baseline
	well.texture = _ui_tex("ink_slot")
	well.position = Vector2(M, 270 - M - 20)
	well.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_grp_hide.add_child(well)
	_weapon_icon = TextureRect.new()
	_weapon_icon.position = Vector2(2, 2)
	_weapon_icon.size = Vector2(16, 16)
	_weapon_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_weapon_icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	_weapon_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	well.add_child(_weapon_icon)
	for i in 6:
		var p := TextureRect.new()
		p.texture = _flask_full
		p.position = Vector2(M + 20 + 4 + i * 9, 270 - M - 9)
		p.size = Vector2(7, 9)
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_grp_hide.add_child(p)
		_pips.append(p)
	_ilmu = Label.new()   # logical value, never shown
	_ilmu.visible = false
	add_child(_ilmu)
	var ii := TextureRect.new()   # Ilmu, top right: gem + rolling number, no plate (the outline carries it)
	ii.texture = _ui_tex("icon_ilmu")
	ii.position = Vector2(480 - M - 8, M)
	ii.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_grp_hide.add_child(ii)
	_ilmu_disp = UIFx.text("", "body", GOLD)
	_ilmu_disp.position = Vector2(480 - M - 8 - 3 - 60, M - 1)
	_ilmu_disp.size = Vector2(60, 9)
	_ilmu_disp.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_grp_hide.add_child(_ilmu_disp)
	_saved_icon = TextureRect.new()
	_saved_icon.texture = _ui_tex("icon_save")
	_saved_icon.position = Vector2(480 - M - 8, 270 - M - 8)
	_saved_icon.visible = false
	_saved_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_grp_hide.add_child(_saved_icon)   # fades with the rest of the HUD while a dialogue is open
	_saved = UIFx.text("UI_SAVED", "body", UIFx.DIM)
	_saved.position = Vector2(480 - M - 8 - 4 - 80, 270 - M - 9)
	_saved.size = Vector2(80, 9)
	_saved.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_saved.visible = false
	_grp_hide.add_child(_saved)
	_build_extras()
	_tracker_panel = PanelContainer.new()   # minimalistic floating quest HUD under vitals
	_tracker_panel.position = Vector2(M, M + 28)   # under the vitals, one 8 px gap
	_tracker_panel.custom_minimum_size = Vector2(TRACKER_W, 0)
	var sb := StyleBoxFlat.new()   # slim night strip with an amber edge: readable on any ground, hides little of the world
	sb.bg_color = Color(UIFx.INK_BG, 0.62)
	sb.border_color = GOLD
	sb.border_width_left = 1
	sb.content_margin_left = 6.0
	sb.content_margin_right = 6.0
	sb.content_margin_top = 4.0
	sb.content_margin_bottom = 5.0
	_tracker_panel.add_theme_stylebox_override("panel", sb)
	_tracker_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tracker_panel.visible = false
	_grp_hide.add_child(_tracker_panel)
	_tracker = VBoxContainer.new()
	_tracker.add_theme_constant_override("separation", 3)
	_tracker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tracker_panel.add_child(_tracker)
	_menu_hint = UIFx.text(tr("UI_HINT_MENU") % get_node("/root/Game").key_name("pause").replace("Escape", "Esc"), "body", UIFx.DIM)
	_menu_hint.position = Vector2(480 - M - 100, M + 12)   # quiet hint under Ilmu for the first minute; fades
	_menu_hint.size = Vector2(100, 9)
	_menu_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_menu_hint.modulate.a = 0.55
	_menu_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_grp_hide.add_child(_menu_hint)
	var g := get_node("/root/Game")
	g.changed.connect(refresh)
	g.changed.connect(refresh_objective)
	g.saved.connect(func() -> void:
		_saved_left = 1.0
		_saved.visible = true
		_saved_icon.visible = true)
	var ev := get_node("/root/Events")
	ev.dialogue_requested.connect(func(_k: String, _l: PackedStringArray) -> void: set_focus(true))
	ev.dialogue_finished.connect(func() -> void: set_focus(false))
	for qid in g.quests:   # what a loaded game already finished is not news
		_snap(qid)
	ev.quest_started.connect(func(id: String) -> void:
		_snap(id)
		_push_banner("UI_Q_NEW", _title(id))
		_show_step_hint(id)
		refresh_arrow())
	ev.quest_updated.connect(func(id: String) -> void:
		_on_quest_updated(id)
		refresh_arrow())
	for s in ["quest_started", "quest_updated", "quest_completed", "zone_entered"]:
		ev.connect(s, refresh_objective.unbind(1))
	ev.area_entered.connect(func(id: String) -> void:
		if id == "sande_room" and not g.has_flag("hint_sande"):   # one-time hint (bestiary.md Sandekala)
			g.run("flag:hint_sande")
			_push_toast(tr("UI_HINT_SANDE")))
	ev.consequence_noted.connect(func(key: String) -> void:
		var rk := "REMEMBER_" + key.to_upper()
		if tr(rk) == rk:
			return   # no sentence written yet: stay silent
		_push_banner("UI_Q_REMEMBER", tr(rk))
		_pulse_tracker())
	ev.quest_completed.connect(func(id: String) -> void:
		_push_banner("UI_Q_DONE", _title(id))
		refresh_arrow())
	ev.item_picked.connect(func(id: String) -> void:
		var what := "%s Ilmu" % id.get_slice(":", 1) if id.begins_with("ilmu:") else tr("ITEM_%s_NAME" % id.to_upper())
		_push_toast(tr("UI_TOAST_ITEM") % what))
	ev.glyph_learned.connect(func(id: String) -> void:
		_push_toast(tr("UI_TOAST_GLYPH") % id.split("_")[-1].capitalize()))   # sunda_ka -> Ka
	ev.zone_entered.connect(func(_z: String) -> void: refresh_arrow())
	refresh()
	refresh_arrow()
	refresh_objective()


## The tracker (docs/quest_system.md 3.1): the tracked quest's title and its current active objective.
func refresh_objective() -> void:
	var g := get_node("/root/Game")
	var rows: Array = []   # [kind, text, colour, bullet]: kind "title" or "obj"
	for id in g._tracked():
		var st: QuestStep = g.current_step(id)
		if st == null:
			continue
		var q := QuestData.by_id(id)
		rows.append(["title", _title(id), GOLD if q.kind == "main" else UIFx.LABEL_COL, ""])
		if st.all.is_empty():
			rows.append(["obj", g.quest_objective_text(id), CREAM, "bullet_now"])
		else:
			var checklist: Array = g.step_checklist(id)
			var total: int = checklist.size()
			var done_count: int = 0
			var active_text := ""
			for c in checklist:
				if c.done:
					done_count += 1
				elif c.active and active_text == "":
					active_text = str(c.text)
			if active_text == "":
				for c in checklist:
					if not c.done:
						active_text = str(c.text)
						break
			if active_text == "" and not checklist.is_empty():
				active_text = str(checklist[0].text)
			if active_text == "":
				active_text = g.quest_objective_text(id)
			if total > 1:
				active_text += " (%d/%d)" % [done_count, total]
			rows.append(["obj", active_text, CREAM, "bullet_now"])
		break
	var sig := str(rows)
	if sig == _tracker_sig:
		return
	_tracker_sig = sig
	for c in _tracker.get_children():
		_tracker.remove_child(c)
		c.queue_free()
	_tracker_panel.visible = not rows.is_empty()
	var inner := float(TRACKER_W - 12)
	for r in rows:
		if r[0] == "title":   # small tracked caps: the quest's name is a label, the objective is the message
			var t := UIFx.text(String(r[1]), "label", r[2])
			t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			t.custom_minimum_size.x = inner
			_tracker.add_child(t)
		elif r[0] == "obj":
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 4)
			row.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var ic := TextureRect.new()
			ic.texture = _ui_tex("ink_cursor")
			ic.stretch_mode = TextureRect.STRETCH_KEEP
			ic.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			ic.custom_minimum_size = Vector2(5, 7)
			ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var pad := Control.new()   # drops the 5 px diamond onto the first line's caps
			pad.custom_minimum_size = Vector2(5, 2)
			pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var col := VBoxContainer.new()
			col.add_theme_constant_override("separation", 0)
			col.mouse_filter = Control.MOUSE_FILTER_IGNORE
			col.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			col.add_child(pad)
			col.add_child(ic)
			row.add_child(col)
			var l := UIFx.text(String(r[1]), "body", r[2])
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			l.add_theme_constant_override("line_spacing", 1)
			l.custom_minimum_size.x = inner - 9.0
			l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(l)
			_tracker.add_child(row)
	_tracker_panel.size = Vector2(TRACKER_W, 0)   # re-fit to the new rows
	_tracker_panel.reset_size()
	_tracker_wake(false)


## Remembers a quest's step and finished sub-goal count, to tell later whether an update is news.
func _snap(id: String) -> void:
	var q: Dictionary = get_node("/root/Game").quests.get(id, {})
	var bits := 0
	for i in 32:
		bits += (int(q.get("all", 0)) >> i) & 1
	_sub_seen[id] = [int(q.get("step", 0)), bits]


## Shows step-specific control hints via toasts when newly activated.
func _show_step_hint(id: String) -> void:
	var g := get_node("/root/Game")
	var st: QuestStep = g.current_step(id)
	if st == null:
		return
	var key := st.objective.replace("_OBJ", "_HINT")
	if tr(key) != key:
		var keys := {}
		for a in ["interact", "cast", "attack", "dodge", "menu"]:
			keys[a] = g.key_name(a)
		keys.move = "%s%s%s%s" % [g.key_name("move_up"), g.key_name("move_left"), g.key_name("move_down"), g.key_name("move_right")]
		_push_toast(tr(key).format(keys))


## A new step or a finished sub-goal: banner with the objective now in force, and a gold pulse on the tracker.
## A counted step ticking up (2/3) only pulses.
func _on_quest_updated(id: String) -> void:
	var seen: Array = _sub_seen.get(id, [0, 0])
	_snap(id)
	var now: Array = _sub_seen[id]
	if now[0] != seen[0] or now[1] > seen[1]:
		var t: String = get_node("/root/Game").quest_objective_text(id)
		if t != "":
			_push_banner("UI_Q_UPDATED", _title(id))   # just the quest name; the tracker card holds the detail
		if now[0] != seen[0]:
			_show_step_hint(id)
	_pulse_tracker()


func _pulse_tracker() -> void:
	_tracker_wake(true)


## Full opacity on a change (with a gold flash when `flash`), then it settles back to a dim, unobtrusive strip.
func _tracker_wake(flash: bool) -> void:
	if _pulse_tw != null and _pulse_tw.is_valid():
		_pulse_tw.kill()
	_pulse_tw = create_tween()
	_tracker_panel.modulate = Color(1.8, 1.6, 0.9) if flash else Color.WHITE
	if flash:
		_pulse_tw.tween_property(_tracker_panel, "modulate", Color.WHITE, 0.7)
	_pulse_tw.tween_interval(TRACKER_IDLE)
	_pulse_tw.tween_property(_tracker_panel, "modulate", Color(1, 1, 1, TRACKER_REST_A), 1.5)


func _push_banner(head_key: String, body: String) -> void:
	_banners.append([tr(head_key), body])


func _update_banner(delta: float) -> void:
	if _banner_left > 0.0:
		_banner_left -= delta
		if _banner_left <= 0.0:
			_banner_root.visible = false
	if _banner_left <= 0.0 and not _banners.is_empty():
		var b: Array = _banners.pop_front()
		_banner_head.text = b[0]
		_banner_body.text = b[1]
		_fit_banner()
		_banner_root.visible = true
		_banner_left = BANNER_TIME
	if _banner_root.visible:   # slide in from top, hold, fade
		var k := clampf((BANNER_TIME - _banner_left) / 0.25, 0.0, 1.0)
		k = 1.0 - (1.0 - k) * (1.0 - k)
		_banner_root.position.x = roundf((480.0 - _banner_root.size.x) / 2.0)
		_banner_root.position.y = roundf(lerpf(-_banner_root.size.y, M, k))
		_banner_root.modulate.a = minf(k, clampf(_banner_left / 0.4, 0.0, 1.0))


## Red flash on the bar whose resource ran out (ui.md 2).
func _on_blocked(what: String) -> void:
	if what == "flask":
		for n in _pips:
			n.modulate = Color(1, 0.25, 0.2)
			var tw := create_tween()
			tw.tween_property(n, "modulate", Color.WHITE, 0.25)
			tw.finished.connect(refresh)
	elif _bars.has(what):
		var well: ColorRect = _bars[what][4]
		well.color = Color.RED
		var tw2 := create_tween()
		tw2.tween_property(well, "color", Color(0, 0, 0, 0.6), 0.25)
		_st_full = 0.0   # a flash on stamina shows the bar


func _title(id: String) -> String:
	return tr("Q_%s_TITLE" % id.to_upper())


func _rect(pos: Vector2, sz: Vector2, col: Color, parent: Node = self) -> ColorRect:
	var r := ColorRect.new()
	r.position = pos
	r.size = sz
	r.color = col
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)
	return r


func _outlined(l: Label) -> void:
	l.add_theme_color_override("font_outline_color", OUTLINE)
	l.add_theme_constant_override("outline_size", 2)


func _ui_tex(n: String) -> Texture2D:
	return load(UI_DIR + n + ".png")


## A full-screen, click-through wrapper: one modulate fades everything inside it.
func _group() -> Control:
	var c := Control.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(c)
	return c


## Dialogue open: the tracker, flasks, weapon, Ilmu, hints and the vitals plaque all fade out, so nothing
## competes with the speech (ui.md 2). Back to full on close. 0.2 s.
func set_focus(on: bool) -> void:
	_dialogue_focus = on
	if on:
		if is_instance_valid(_arrow):
			_arrow.visible = false
		if is_instance_valid(_diamond):
			_diamond.visible = false
		if is_instance_valid(_dist):
			_dist.visible = false
		if is_instance_valid(_dist_bg):
			_dist_bg.visible = false
	if _focus_tw != null and _focus_tw.is_valid():
		_focus_tw.kill()
	_focus_tw = create_tween().set_parallel(true)
	_focus_tw.tween_property(_grp_hide, "modulate:a", 0.0 if on else 1.0, 0.2)
	_focus_tw.tween_property(_grp_bars, "modulate:a", 0.0 if on else 1.0, 0.2)   # the vitals leave too: nothing competes with the speech


func _nine(tex: String, rect: Rect2, m: Array, parent: Node = null) -> NinePatchRect:
	var r := NinePatchRect.new()
	r.texture = _ui_tex(tex)
	r.position = rect.position
	r.size = rect.size
	r.patch_margin_left = m[0]
	r.patch_margin_top = m[1]
	r.patch_margin_right = m[2]
	r.patch_margin_bottom = m[3]
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(parent if parent != null else self).add_child(r)
	return r


func _build_extras() -> void:
	# toast (item, glyph, hint): a small ink pill under Ilmu, top right, sized to its text; never shares a spot
	# with the quest banner (top centre)
	_toast_root = Control.new()
	_toast_root.position = Vector2(480 - M - 120, M + 24)
	_toast_root.size = Vector2(120, 15)
	_toast_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_root.visible = false
	add_child(_toast_root)
	var tp := _nine("ink_panel", Rect2(0, 0, 120, 15), [4, 4, 4, 4], _toast_root)
	tp.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_toast_rule = _rect(Vector2(2, 2), Vector2(1, 11), GOLD, _toast_root)   # amber tick on the leading edge
	_toast = UIFx.text("", "body", CREAM)
	_toast.position = Vector2(8, 3)
	_toast.size = Vector2(104, 9)
	_toast.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_toast.visible = false
	_toast_root.add_child(_toast)

	# quest banner: one small ink pill, top centre: gold caps kicker then the quest name, both body size
	_banner_root = Control.new()
	_banner_root.size = Vector2(200, 15)
	_banner_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner_root.visible = false
	add_child(_banner_root)
	var bp := _nine("ink_panel", Rect2(0, 0, 200, 15), [4, 4, 4, 4], _banner_root)
	bp.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_banner_head = UIFx.text("", "label", GOLD)
	_banner_head.position = Vector2(8, 3)
	_banner_head.size = Vector2(80, 9)
	_banner_root.add_child(_banner_head)
	_banner_body = UIFx.text("", "body", CREAM)
	_banner_body.position = Vector2(94, 3)
	_banner_body.size = Vector2(100, 9)
	_banner_body.add_theme_constant_override("line_spacing", 1)
	_banner_body.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_banner_root.add_child(_banner_body)
	_diamond = Node2D.new()   # floats over an on-screen target
	var dk := Polygon2D.new()
	dk.polygon = PackedVector2Array([Vector2(0, -5), Vector2(5, 0), Vector2(0, 5), Vector2(-5, 0)])
	dk.color = OUTLINE
	_diamond.add_child(dk)
	var dg := Polygon2D.new()
	dg.polygon = PackedVector2Array([Vector2(0, -4), Vector2(4, 0), Vector2(0, 4), Vector2(-4, 0)])
	dg.color = GOLD
	_diamond.add_child(dg)
	var dh := Polygon2D.new()   # one lit facet
	dh.polygon = PackedVector2Array([Vector2(0, -3), Vector2(2, -1), Vector2(0, 0), Vector2(-2, -1)])
	dh.color = Color("FFE2BC")
	_diamond.add_child(dh)
	_diamond.visible = false
	add_child(_diamond)
	_dist_bg = ColorRect.new()   # lacquer pill: "1 m" never floats loose over a character
	_dist_bg.color = Color(UIFx.INK_BG, 0.8)
	_dist_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dist_bg.visible = false
	add_child(_dist_bg)
	_dist = UIFx.text("", "body", GOLD)
	_dist.size = Vector2(80, 9)
	_dist.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_dist.add_theme_constant_override("outline_size", 0)   # it sits on its own pill
	_dist.visible = false
	add_child(_dist)
	_arrow = Node2D.new()
	var spr := Sprite2D.new()
	spr.texture = _ui_tex("arrow_objective")   # points right; rotated toward the target
	_arrow.add_child(spr)
	_arrow.visible = false
	add_child(_arrow)
	_boss_root = Control.new()
	_boss_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_boss_root.visible = false
	add_child(_boss_root)
	# boss: name in the heading face, left-aligned over a long thin bar at the bottom centre (Souls convention)
	var x := (480 - BOSS_W) / 2
	_boss_name = UIFx.text("", "head", UIFx.GOLD_HI)
	_boss_name.position = Vector2(x, 270 - M - 26)
	_boss_name.size = Vector2(BOSS_W, 13)
	_boss_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_boss_root.add_child(_boss_name)
	var by := 270 - M - 10
	_rect(Vector2(x - 1, by - 1), Vector2(BOSS_W + 2, 6), Color(UIFx.INK_BG, 0.95), _boss_root)   # outline
	_rect(Vector2(x, by), Vector2(BOSS_W, 4), Color(0.2, 0.05, 0.04, 0.9), _boss_root)            # empty well
	_boss_fill = _rect(Vector2(x, by), Vector2(BOSS_W, 4), HP_COL, _boss_root)
	_boss_fill.clip_contents = true
	_rect(Vector2(0, 0), Vector2(BOSS_W, 1), Color(1, 1, 1, 0.25), _boss_fill)                   # lit top row
	_rect(Vector2(x + BOSS_W / 2, by), Vector2(1, 4), Color(UIFx.INK_BG, 0.9), _boss_root)       # phase 2 at 50%
	_boss_mark = _make_crack_mark(Vector2(x + BOSS_W + 4, by - 3))
	_boss_root.add_child(_boss_mark)
	_dawn_bg = _rect(Vector2(x, by + 6), Vector2(BOSS_W, 2), Color(UIFx.INK_BG, 0.8), _boss_root)
	_dawn_fill = _rect(Vector2(x, by + 6), Vector2(BOSS_W, 2), SK_COL, _boss_root)


## Sizes the banner pill to its text: "QUEST UPDATED  Quest name" on one 15 px line (max 300 px); a sentence too
## long for that (a "remembered" consequence) wraps under the kicker on a 260 px card.
func _fit_banner() -> void:
	var bf := UIFx.body_font()
	var kw := ceilf(UIFx.caps_font().get_string_size(_banner_head.text.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x)
	var tw := ceilf(bf.get_string_size(_banner_body.text, HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x)
	_banner_head.size.x = kw + 2.0
	var bw := 8.0 + kw + 6.0 + tw + 8.0
	if bw <= 300.0:
		_banner_body.autowrap_mode = TextServer.AUTOWRAP_OFF
		_banner_body.position = Vector2(8.0 + kw + 6.0, 3.0)
		_banner_body.size = Vector2(tw + 2.0, 9.0)
		_banner_root.size = Vector2(maxf(bw, 80.0), 15.0)
	else:
		bw = 260.0
		_banner_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var sz := bf.get_multiline_string_size(_banner_body.text, HORIZONTAL_ALIGNMENT_LEFT, bw - 16.0, UIFx.BODY)
		var lines := clampi(roundi(sz.y / maxf(bf.get_height(UIFx.BODY), 1.0)), 1, 3)
		_banner_body.position = Vector2(8.0, 14.0)
		_banner_body.size = Vector2(bw - 16.0, lines * 10.0 - 1.0)
		_banner_root.size = Vector2(bw, 14.0 + _banner_body.size.y + 4.0)


func _push_toast(text: String) -> void:
	_toasts.append(text)


## Finds the node the arrow points at (marker in this zone, or the exit toward the target's zone).
## Called on quest events and zone_entered; the position is read every frame.
func refresh_arrow() -> void:
	_tnode = null
	_tzone = ""
	var m: Dictionary = get_node("/root/Game").objective_marker()
	if m.is_empty():
		return
	var zones := get_node("/root/Zones")
	var zone: String = m.get("zone", "")
	var id: String = m.get("id", "")
	var nxt: String = ""
	if zone != zones.current_zone:
		nxt = zones.next_zone(zones.current_zone, zone)
		if nxt == "":
			return
		_tzone = zone
	# ponytail: one scan of the tree per event; no group or lookup hook in Zone yet
	for n in get_tree().root.find_children("*", "Node2D", true, false):
		if nxt != "":
			if "target_zone" in n and n.target_zone == nxt:
				_tnode = n
				return
		elif id in [n.get("id"), n.get("npc_id"), n.get("trigger_id"), n.get("area_id"), n.get("item_id"), n.get("kind"), n.get("clue_id"), n.get("memory_id"), n.name]:
			if "visible" in n and not n.visible:
				continue
			if "cond" in n and str(n.cond) != "" and not get_node("/root/Game").check(str(n.cond)):
				continue
			_tnode = n
			return


## True when the player is inside the arena/encounter where the hunt/fight is taking place.
func _is_in_target_arena() -> bool:
	if _tzone != "" or _tnode == null or not is_instance_valid(_tnode):
		return false
	var pl := get_tree().get_first_node_in_group("player") as Node2D
	if pl == null or not is_instance_valid(pl):
		return false
	var pl_pos := pl.global_position

	# 1. Target node is an Encounter (has area_id and size).
	if "size" in _tnode and ("area_id" in _tnode or "waves" in _tnode):
		var s: Vector2 = Vector2(_tnode.size * 16)
		var r := Rect2(_tnode.global_position - s * 0.5, s)
		if r.grow(16.0).has_point(pl_pos):
			return true

	# 2. Target node is a Boss or has arena_radius.
	if _tnode.is_in_group("boss") or "boss_name_key" in _tnode or "arena_radius" in _tnode:
		var rad: float = float(_tnode.arena_radius) if "arena_radius" in _tnode else 176.0
		if pl_pos.distance_to(_tnode.global_position) <= rad + 16.0:
			return true

	# 3. Target is an enemy in close combat engagement range.
	if _tnode.is_in_group("enemy") or _tnode.get("role") in ["charger", "chaser", "shooter", "tank"]:
		if pl_pos.distance_to(_tnode.global_position) <= 120.0:
			return true

	# 4. Target matches an active encounter in this zone whose arena the player is inside.
	var m: Dictionary = get_node("/root/Game").objective_marker()
	var tid: String = str(m.get("id", ""))
	if tid != "":
		for enc in get_tree().get_nodes_in_group("encounter"):
			if is_instance_valid(enc) and "area_id" in enc and enc.area_id == tid:
				var s: Vector2 = Vector2(enc.size * 16)
				var r := Rect2(enc.global_position - s * 0.5, s)
				if r.grow(16.0).has_point(pl_pos):
					return true

	return false


## World position of the objective node the arrow follows (an exit when the target is in another zone), or null.
func target_pos() -> Variant:
	return _tnode.global_position if _tnode != null and is_instance_valid(_tnode) else null


func _update_arrow() -> void:
	_diamond.visible = false
	_dist.visible = false
	_dist_bg.visible = false
	if _dialogue_focus or _tnode == null or not is_instance_valid(_tnode) or not _tnode.is_inside_tree():
		_arrow.visible = false
		return
	if _is_in_target_arena():
		_arrow.visible = false
		return
	var p: Vector2 = get_viewport().get_canvas_transform() * _tnode.global_position
	var label := _target_label()
	if Rect2(Vector2.ZERO, SCREEN).has_point(p):
		_arrow.visible = false
		_diamond.position = (p + Vector2(0, -46.0 + 2.0 * sin(_t * 4.0))).round()   # above the NPC's own prompt
		_diamond.visible = true
		_dist.text = label
		_dist.position = (p + Vector2(-40, 4)).round()
		_dist.visible = true
		_fit_pill()
		return
	var c := SCREEN / 2
	var d := p - c
	var half := c - Vector2(ARROW_MARGIN, ARROW_MARGIN)
	var k := minf(half.x / maxf(absf(d.x), 0.001), half.y / maxf(absf(d.y), 0.001))
	_arrow.position = (c + d * k).round()
	_arrow.rotation = d.angle()
	_arrow.scale = Vector2.ONE * (1.0 + 0.15 * sin(_t * 6.0))
	_arrow.visible = true
	_dist.text = label
	var lp := _arrow.position - d.normalized() * 16.0 - Vector2(40, 5)
	_dist.position = Vector2(clampf(lp.x, 0.0, SCREEN.x - 80.0), clampf(lp.y, 0.0, SCREEN.y - 12.0)).round()
	_dist.visible = true
	_fit_pill()


## Sizes the pill to the label text (the label is centred in its 80 px box).
func _fit_pill() -> void:
	var w := ceilf(_dist.get_minimum_size().x) + 8.0
	_dist_bg.size = Vector2(w, 11)
	_dist_bg.position = _dist.position + Vector2(roundf((_dist.size.x - w) / 2.0), -1)
	_dist_bg.visible = _dist.text != ""


## Metres to the target (1 tile = 1 m), or "-> <zone>" while the arrow only points at the exit toward another zone.
func _target_label() -> String:
	if _tzone != "":
		var key := "UI_ZONE_" + _tzone.to_upper()
		return "-> " + (tr(key) if tr(key) != key else _tzone.capitalize())
	var pl := get_tree().get_first_node_in_group("player") as Node2D
	if pl == null:
		return ""
	return "%d m" % roundi(pl.global_position.distance_to(_tnode.global_position) / float(Zone.TILE))


func _update_toast(delta: float) -> void:
	if _toast_left > 0.0:
		_toast_left -= delta
		if _toast_left <= 0.0:
			_toast.visible = false
			_toast_root.visible = false
	if _toast_left <= 0.0 and not _toasts.is_empty():
		_toast.text = _toasts.pop_front()
		var w := clampf(ceilf(UIFx.body_font().get_string_size(_toast.text, HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x) + 14.0, 60.0, 220.0)
		_toast_root.size.x = w
		_toast.size.x = w - 12.0
		_toast.visible = true
		_toast_root.visible = true
		_toast_left = TOAST_TIME
	if _toast_root.visible:   # slide in from the right edge, hold, fade (a pure function of the timer)
		var k := clampf((TOAST_TIME - _toast_left) / 0.2, 0.0, 1.0)
		k = 1.0 - (1.0 - k) * (1.0 - k)
		_toast_root.position.x = roundf(480.0 - M - _toast_root.size.x + 12.0 * (1.0 - k))
		_toast_root.position.y = M + 24.0
		_toast_root.modulate.a = minf(k, clampf(_toast_left / 0.4, 0.0, 1.0))


## Placeholder drawing, no asset: a small glyph box (open at the top right) with a zigzag crack through it.
func _make_crack_mark(at: Vector2) -> Node2D:
	var n := Node2D.new()
	n.position = at
	n.visible = false
	var frame := Line2D.new()
	frame.width = 1.0
	frame.default_color = Color(0.95, 0.85, 0.5)
	frame.points = PackedVector2Array([Vector2(7, 0), Vector2(0, 0), Vector2(0, 9), Vector2(9, 9), Vector2(9, 3)])
	n.add_child(frame)
	var crack := Line2D.new()
	crack.width = 1.0
	crack.default_color = Color(0.9, 0.2, 0.15)
	crack.points = PackedVector2Array([Vector2(8, -2), Vector2(5, 3), Vector2(6, 5), Vector2(2, 11)])
	n.add_child(crack)
	return n


## True when the current boss names a sabotage flag (`sabotage_flag`) and Game has it set.
func boss_sabotaged(b: Node) -> bool:
	var f: Variant = b.get("sabotage_flag") if b else null
	return f is String and f != "" and get_node("/root/Game").has_flag(f)


func _update_boss() -> void:
	var b := get_tree().get_first_node_in_group("boss")
	var h = b.get("health") if b else null
	_boss_root.visible = h != null and bool(b.get("engaged")) and h.hp > 0
	if not _boss_root.visible:
		return
	_boss_name.text = tr(str(b.get("boss_name_key")))
	_boss_mark.visible = boss_sabotaged(b)
	var seq = b.get("sequence")   # Batara Kala's shield: the glyphs to cast in order, the next one in brackets
	if seq is PackedStringArray and not seq.is_empty() and b.get("dawn") != null:
		var parts := PackedStringArray()
		for i in seq.size():
			var g := GlyphData.by_id(seq[i])
			var t: String = g.latin if g else seq[i]
			parts.append("[%s]" % t.to_upper() if i == int(b.get("seq_index")) else t)
		_boss_name.text += "   " + " · ".join(parts)
	_boss_fill.size.x = roundf(BOSS_W * clampf(float(h.hp) / maxf(h.max_hp, 1.0), 0.0, 1.0))
	var dawn = b.get("dawn")
	_dawn_bg.visible = dawn != null
	_dawn_fill.visible = dawn != null
	if dawn != null:
		_dawn_fill.size.x = roundf(BOSS_W * clampf(float(dawn), 0.0, 1.0))


## A bare bar: 1 px ink outline, dark well, fill with a lit top row (thick bars also get a shade row and
## ticks every 10 px). Returns [fill, width, outline, lag, well, outline] (index 5 kept for the stamina fade).
func _bar(pos: Vector2, w: int, h: int, col: Color, parent: Node) -> Array:
	var frame := _rect(pos, Vector2(w + 2, h + 2), Color(UIFx.INK_BG, 0.9), parent)
	var bg := _rect(pos + Vector2(1, 1), Vector2(w, h), Color(0, 0, 0, 0.55), parent)   # flashes red when blocked
	var lag := _rect(Vector2.ZERO, Vector2(w, h), Color(CREAM, 0.85), bg)
	lag.visible = false
	var fill := _rect(Vector2.ZERO, Vector2(w, h), col, bg)
	fill.clip_contents = true
	_rect(Vector2.ZERO, Vector2(w, 1), Color(1, 1, 1, 0.3), fill)
	if h >= 5:
		_rect(Vector2(0, h - 1), Vector2(w, 1), Color(0, 0, 0, 0.28), fill)
		for tx in range(10, w, 10):
			_rect(Vector2(tx, 0), Vector2(1, h), Color(0, 0, 0, 0.22), bg)
	return [fill, w, frame, lag, bg, frame]


func _fill(name: String, value: float, max_value: float) -> void:
	var b: Array = _bars[name]
	if name == "sk":   # Mage's 120 gauge draws 60 px wide (ui.md 2)
		var w := roundi(max_value * 0.5)
		if w != b[1]:
			b[1] = w
			b[2].size.x = w + 2
			b[4].size.x = w
			b[3].size.x = w
	b[0].size.x = roundf(b[1] * clampf(value / maxf(max_value, 1.0), 0.0, 1.0))


func refresh() -> void:
	var g := get_node("/root/Game")
	_ilmu.text = "%d" % g.ilmu
	if _ilmu_shown < 0.0 or g.ilmu < _ilmu_shown:
		_ilmu_shown = float(g.ilmu)
		_ilmu_disp.text = _ilmu.text
	for i in _pips.size():
		_pips[i].visible = i < g.flask_max
		_pips[i].texture = _flask_full if i < g.flask_charges else _flask_empty
	var item = g.equipped_item("weapon")
	var tex: Variant = null
	if item:
		tex = item.get("icon")   # `icon` export may not exist yet: fall back to the sheet by id
		if not tex is Texture2D:
			var path := "res://assets/art/items/%s.png" % item.id
			tex = load(path) if ResourceLoader.exists(path) else null
	_weapon_icon.texture = tex if tex is Texture2D else null


func _process(delta: float) -> void:
	_t += delta
	var p := get_tree().get_first_node_in_group("player")
	if p:
		if p != _player:
			_player = p
			p.blocked.connect(_on_blocked)
		_fill("hp", p.health.hp, p.health.max_hp)
		_fill("st", p.stamina.value, p.stamina.max_stamina)
		_fill("sk", p.sakti.value, p.sakti.max_value)
		_hp_txt.text = "%d/%d" % [ceili(p.health.hp), roundi(p.health.max_hp)]
		_update_hp_fx(delta, float(p.health.hp) / maxf(p.health.max_hp, 1.0))
		_update_stamina_fade(delta, p.stamina.value >= p.stamina.max_stamina)
	_menu_hint.modulate.a = 0.55 * clampf((MENU_HINT_SHOW + 2.0 - _t) / 2.0, 0.0, 1.0)
	_update_toast(delta)
	_update_banner(delta)
	_update_arrow()
	_update_boss()
	if _ilmu_shown < float(get_node("/root/Game").ilmu):   # roll up
		var target := float(get_node("/root/Game").ilmu)
		_ilmu_shown = minf(target, _ilmu_shown + maxf(20.0 * delta, (target - _ilmu_shown) * 6.0 * delta))
		_ilmu_disp.text = "%d" % roundi(_ilmu_shown) if _ilmu_shown < target else _ilmu.text
	if _saved_left > 0.0:
		_saved_left -= delta
		_saved.visible = _saved_left > 0.0
		_saved_icon.visible = _saved.visible
		_saved.modulate.a = clampf(_saved_left / 0.3, 0.0, 1.0)
		_saved_icon.modulate.a = _saved.modulate.a


## HP: a cream lag chunk drains LAG_HOLD s after the fill drops; below 25% the fill and frame pulse.
func _update_hp_fx(delta: float, ratio: float) -> void:
	var b: Array = _bars.hp
	var cur: float = b[0].size.x
	if _lag < 0.0 or cur >= _lag:
		_lag = cur
	elif cur < _hp_prev:
		_lag_hold = LAG_HOLD
	elif _lag_hold > 0.0:
		_lag_hold -= delta
	else:
		_lag = maxf(cur, _lag - 60.0 * delta)
	_hp_prev = cur
	b[3].visible = _lag > cur
	b[3].size.x = _lag
	if ratio < LOW_HP and ratio > 0.0:
		var s := 0.5 + 0.5 * sin(_t * 7.0)
		b[0].modulate = Color.WHITE.lerp(Color(1.5, 1.2, 1.0), s)
		b[2].modulate = Color.WHITE.lerp(Color(1.4, 0.6, 0.5), s)
	else:
		b[0].modulate = Color.WHITE
		b[2].modulate = Color.WHITE


## Stamina hides after 2 s at full and shows on use (ui.md 2).
func _update_stamina_fade(delta: float, full: bool) -> void:
	_st_full = _st_full + delta if full else 0.0
	var a := 0.0 if _st_full > 2.0 else 1.0
	for n in _st_nodes:
		n.modulate.a = move_toward(n.modulate.a, a, delta * 4.0)
	_bars.st[5].modulate.a = _st_nodes[0].modulate.a
