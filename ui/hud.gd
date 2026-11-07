extends Control
## In-play HUD (ui.md 2). Placeholder bars; reads the player's components every frame.
## ponytail: polling instead of signals so a replaced player (scene change) needs no re-bind.

const HP_COL := Color("D55E00")
const ST_COL := Color("F0E442")
const SK_COL := Color("56B4E9")
const FLASK_COL := Color("009E73")
const GOLD := Color("F2D488")   # prada gold highlight (ui.md 3b)
const CREAM := Color("EDE3CC")
const OUTLINE := Color("0E0B0A")
const UI_DIR := "res://assets/art/ui/"
const LAG_HOLD := 0.4   # s before the cream lag chunk drains
const LOW_HP := 0.25
const MAX_OBJ := 4   # objective rows shown before "+n more"
const TRACKER_W := 156   # TUNE: card width, text wraps inside
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
const DIM := Color(0.62, 0.6, 0.55)
var _tracker_panel: PanelContainer   # framed card around the tracker (ui.md 2, pixel pass)
var _tracker: VBoxContainer   # inside the card: title, rule, then the objectives (docs/quest_system.md 3.1)
var _grp_hide: Control   # fades out while a dialogue is open: tracker, flasks, weapon, Ilmu, hints
var _grp_bars: Control   # dims to 40% while a dialogue is open: the vitals
var _focus_tw: Tween
var _hp_txt: Label   # "120/120" inside the HP bar
var _dist_bg: ColorRect   # lacquer pill behind the distance label
var _menu_hint: Label
var _ilmu_plate: NinePatchRect
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
	_bars.hp = _bar(Vector2(6, 6), 96, 9, HP_COL, "icon_heart", _grp_bars)
	_bars.st = _bar(Vector2(6, 22), 64, 3, ST_COL, "icon_bolt", _grp_bars)
	_bars.sk = _bar(Vector2(6, 31), 50, 3, SK_COL, "icon_brush", _grp_bars)
	_st_nodes = [_bars.st[2], _bars.st[4], _bars.st[5]]
	_hp_txt = Label.new()   # number inside the bar, right aligned, 1 px outline from the theme
	_hp_txt.size = Vector2(96, 9)
	_hp_txt.position = Vector2(0, -1)
	_hp_txt.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hp_txt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hp_txt.add_theme_font_size_override("font_size", 7)
	_hp_txt.add_theme_constant_override("outline_size", 2)
	_hp_txt.add_theme_color_override("font_color", CREAM)
	_hp_txt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bars.hp[4].add_child(_hp_txt)
	var well := TextureRect.new()   # weapon slot: slot.png well holding the equipped item's icon (bottom left cluster)
	well.texture = _ui_tex("slot")
	well.position = Vector2(6, 270 - 6 - 20)
	well.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_grp_hide.add_child(well)
	_weapon_icon = TextureRect.new()
	_weapon_icon.position = Vector2(2, 2)
	_weapon_icon.size = Vector2(16, 16)
	_weapon_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_weapon_icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	_weapon_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	well.add_child(_weapon_icon)
	for i in 6:   # flasks sit to the right of the weapon well, on its baseline
		var p := TextureRect.new()
		p.texture = _flask_full
		p.position = Vector2(6 + 20 + 5 + i * 9, 270 - 6 - 9)
		p.size = Vector2(7, 9)
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_grp_hide.add_child(p)
		_pips.append(p)
	_ilmu = Label.new()   # logical value, never shown
	_ilmu.visible = false
	add_child(_ilmu)
	_ilmu_plate = _nine("panel", Rect2(480 - 6 - 62, 6, 62, 16), [6, 6, 6, 6], _grp_hide)   # pill behind Ilmu: legible on any tile
	_ilmu_plate.modulate.a = 0.85
	var ii := TextureRect.new()
	ii.texture = _ui_tex("icon_ilmu")
	ii.position = Vector2(480 - 6 - 62 + 6, 10)
	ii.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_grp_hide.add_child(ii)
	_ilmu_disp = Label.new()
	_ilmu_disp.position = Vector2(480 - 6 - 62 + 16, 8)
	_ilmu_disp.size = Vector2(40, 12)
	_ilmu_disp.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_ilmu_disp.add_theme_color_override("font_color", GOLD)
	_grp_hide.add_child(_ilmu_disp)
	_saved_icon = TextureRect.new()
	_saved_icon.texture = _ui_tex("icon_save")
	_saved_icon.position = Vector2(480 - 6 - 8, 270 - 6 - 8)
	_saved_icon.visible = false
	_saved_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_saved_icon)
	_saved = Label.new()
	_saved.text = "UI_SAVED"
	_saved.position = Vector2(480 - 6 - 8 - 2 - 80, 270 - 6 - 10)
	_saved.size = Vector2(80, 10)
	_saved.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_saved.visible = false
	add_child(_saved)
	_build_extras()
	_tracker_panel = PanelContainer.new()   # a framed card under the vitals, never past x 164 (ui.md 2)
	_tracker_panel.position = Vector2(6, 44)
	_tracker_panel.custom_minimum_size = Vector2(TRACKER_W, 0)
	_tracker_panel.self_modulate = Color(1, 1, 1, 0.88)
	_tracker_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tracker_panel.visible = false
	_grp_hide.add_child(_tracker_panel)
	_tracker = VBoxContainer.new()
	_tracker.add_theme_constant_override("separation", 2)
	_tracker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tracker_panel.add_child(_tracker)
	_menu_hint = Label.new()   # quiet [Esc] Menu prompt under Ilmu; fades after a while
	_menu_hint.text = tr("UI_HINT_MENU") % get_node("/root/Game").key_name("pause").replace("Escape", "Esc")
	_menu_hint.position = Vector2(480 - 6 - 70, 24)
	_menu_hint.size = Vector2(70, 12)
	_menu_hint.add_theme_font_size_override("font_size", 7)
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


## The tracker (docs/quest_system.md 3.1): the tracked quest's title, every objective of its step (a multi-goal step
## lists its sub-goals: [x] done, > the one the arrow follows, [ ] open) and the step's hint with live key names.
func refresh_objective() -> void:
	var g := get_node("/root/Game")
	var rows: Array = []   # [kind, text, colour, bullet]: kind "title", "obj" or "hint"
	for id in g._tracked():
		var st: QuestStep = g.current_step(id)
		if st == null:
			continue
		var q := QuestData.by_id(id)
		rows.append(["title", _title(id), GOLD if q.kind == "main" else CREAM, ""])
		if st.all.is_empty():
			rows.append(["obj", g.quest_objective_text(id), Color.WHITE, "bullet_now"])
		else:
			for c in g.step_checklist(id):
				rows.append(["obj", str(c.text), DIM if c.done else (GOLD if c.active else Color.WHITE),
						"bullet_check" if c.done else "bullet_now" if c.active else "bullet_open"])
		var key := st.objective.replace("_OBJ", "_HINT")
		if tr(key) != key:
			var keys := {}
			for a in ["interact", "cast", "attack", "dodge", "menu"]:
				keys[a] = g.key_name(a)
			keys.move = "%s%s%s%s" % [g.key_name("move_up"), g.key_name("move_left"), g.key_name("move_down"), g.key_name("move_right")]
			rows.append(["hint", tr(key).format(keys), DIM, ""])
		break
	var sig := str(rows)
	if sig == _tracker_sig:
		return
	_tracker_sig = sig
	for c in _tracker.get_children():
		c.queue_free()
	_tracker_panel.visible = not rows.is_empty()
	var inner := TRACKER_W - 12.0   # card width minus its 6 px margins
	var shown := 0
	for r in rows:
		if r[0] == "obj":
			shown += 1
			if shown > MAX_OBJ:   # a long checklist: the rest collapses into "+n"
				continue
		var l := Label.new()
		l.text = r[1]
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.add_theme_color_override("font_color", r[2])
		_outlined(l)
		if r[0] == "title":
			l.theme_type_variation = &"Heading"
			l.add_theme_color_override("font_color", r[2])
			l.custom_minimum_size.x = inner
			_tracker.add_child(l)
			var rule := ColorRect.new()   # 1 px gold rule under the title
			rule.color = Color("7A5A22")
			rule.custom_minimum_size = Vector2(inner, 1)
			rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_tracker.add_child(rule)
		elif r[0] == "obj":
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 3)
			row.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var ic := TextureRect.new()
			ic.texture = _ui_tex(r[3])
			ic.stretch_mode = TextureRect.STRETCH_KEEP
			ic.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			ic.custom_minimum_size = Vector2(7, 9)
			ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row.add_child(ic)
			l.custom_minimum_size.x = inner - 10.0
			l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(l)
			_tracker.add_child(row)
		else:
			l.custom_minimum_size.x = inner
			_tracker.add_child(l)
	var extra := shown - MAX_OBJ
	if extra > 0:
		var more := Label.new()
		more.text = tr("UI_Q_MORE") % extra
		more.add_theme_color_override("font_color", DIM)
		more.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_tracker.add_child(more)
	_tracker_panel.size = Vector2(TRACKER_W, 0)   # re-fit to the new rows


## Remembers a quest's step and finished sub-goal count, to tell later whether an update is news.
func _snap(id: String) -> void:
	var q: Dictionary = get_node("/root/Game").quests.get(id, {})
	var bits := 0
	for i in 32:
		bits += (int(q.get("all", 0)) >> i) & 1
	_sub_seen[id] = [int(q.get("step", 0)), bits]


## A new step or a finished sub-goal: banner with the objective now in force, and a gold pulse on the tracker.
## A counted step ticking up (2/3) only pulses.
func _on_quest_updated(id: String) -> void:
	var seen: Array = _sub_seen.get(id, [0, 0])
	_snap(id)
	var now: Array = _sub_seen[id]
	if now[0] != seen[0] or now[1] > seen[1]:
		var t: String = get_node("/root/Game").quest_objective_text(id)
		if t != "":
			_push_banner("UI_Q_UPDATED", t)
	_pulse_tracker()


func _pulse_tracker() -> void:
	if _pulse_tw != null and _pulse_tw.is_valid():
		_pulse_tw.kill()
	_pulse_tw = create_tween()
	_tracker_panel.modulate = Color(1.8, 1.6, 0.9)
	_pulse_tw.tween_property(_tracker_panel, "modulate", Color.WHITE, 0.7)


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
		_banner_root.visible = true
		_banner_left = BANNER_TIME
	if _banner_root.visible:   # slide down, hold, fade
		var k := clampf((BANNER_TIME - _banner_left) / 0.3, 0.0, 1.0)
		k = 1.0 - (1.0 - k) * (1.0 - k)
		_banner_root.position.y = lerpf(16.0, 24.0, k)
		_banner_root.modulate.a = minf(k, clampf(_banner_left / 0.5, 0.0, 1.0))


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
	l.add_theme_constant_override("outline_size", 1)


func _ui_tex(n: String) -> Texture2D:
	return load(UI_DIR + n + ".png")


## A full-screen, click-through wrapper: one modulate fades everything inside it.
func _group() -> Control:
	var c := Control.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(c)
	return c


## Dialogue open: the tracker, flasks, weapon, Ilmu and hints fade out and the vitals dim to 40%, so nothing
## competes with the speech (ui.md 2). Back to full on close. 0.2 s.
func set_focus(on: bool) -> void:
	if _focus_tw != null and _focus_tw.is_valid():
		_focus_tw.kill()
	_focus_tw = create_tween().set_parallel(true)
	_focus_tw.tween_property(_grp_hide, "modulate:a", 0.0 if on else 1.0, 0.2)
	_focus_tw.tween_property(_grp_bars, "modulate:a", 0.4 if on else 1.0, 0.2)


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
	_toast_root = Control.new()
	_toast_root.position = Vector2(90, 6)
	_toast_root.size = Vector2(300, 14)
	_toast_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_root.visible = false
	add_child(_toast_root)
	_rect(Vector2.ZERO, Vector2(300, 13), Color(OUTLINE, 0.6), _toast_root)
	_toast_rule = _rect(Vector2(150, 13), Vector2(0, 1), Color("C9A24A"), _toast_root)   # gold rule grows from the centre
	_toast = Label.new()
	_toast.position = Vector2(0, 1)
	_toast.size = Vector2(300, 12)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.add_theme_color_override("font_color", GOLD)
	_toast.visible = false
	_toast_root.add_child(_toast)
	_banner_root = Control.new()
	_banner_root.position = Vector2(90, 24)
	_banner_root.size = Vector2(300, 34)
	_banner_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner_root.visible = false
	add_child(_banner_root)
	_rect(Vector2.ZERO, Vector2(300, 34), Color(OUTLINE, 0.7), _banner_root)
	_rect(Vector2(0, 0), Vector2(300, 1), Color("C9A24A"), _banner_root)
	_banner_head = Label.new()
	_banner_head.position = Vector2(0, 2)
	_banner_head.size = Vector2(300, 10)
	_banner_head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_head.add_theme_color_override("font_color", GOLD)
	_banner_root.add_child(_banner_head)
	_banner_body = Label.new()
	_banner_body.position = Vector2(6, 13)
	_banner_body.size = Vector2(288, 20)
	_banner_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_banner_body.max_lines_visible = 2
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
	_diamond.visible = false
	add_child(_diamond)
	_dist_bg = ColorRect.new()   # lacquer pill: "1 m" never floats loose over a character
	_dist_bg.color = Color(OUTLINE, 0.72)
	_dist_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dist_bg.visible = false
	add_child(_dist_bg)
	_dist = Label.new()
	_dist.size = Vector2(80, 12)
	_dist.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_dist.add_theme_color_override("font_color", GOLD)
	_dist.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_outlined(_dist)
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
	var x := (480 - BOSS_W) / 2
	_boss_name = Label.new()
	_boss_name.theme_type_variation = &"BossName"
	_boss_name.position = Vector2(x - 40, 231)
	_boss_name.size = Vector2(BOSS_W + 80, 13)
	_boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_root.add_child(_boss_name)
	var bf := NinePatchRect.new()
	bf.texture = _ui_tex("bar_frame")
	bf.position = Vector2(x - 2, 245)
	bf.size = Vector2(BOSS_W + 4, 9)
	bf.patch_margin_left = 3
	bf.patch_margin_right = 3
	bf.patch_margin_top = 3
	bf.patch_margin_bottom = 3
	bf.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_boss_root.add_child(bf)
	_rect(Vector2(x, 247), Vector2(BOSS_W, 5), Color(0, 0, 0, 0.6), _boss_root)
	_boss_fill = _rect(Vector2(x, 247), Vector2(BOSS_W, 5), HP_COL, _boss_root)
	_rect(Vector2(x + BOSS_W / 2, 247), Vector2(1, 5), Color(OUTLINE, 0.9), _boss_root)   # phase 2 at 50%
	_boss_mark = _make_crack_mark(Vector2(x + BOSS_W + 5, 244))
	_boss_root.add_child(_boss_mark)
	_dawn_bg = _rect(Vector2(x, 256), Vector2(BOSS_W, 2), Color(0, 0, 0, 0.6), _boss_root)
	_dawn_fill = _rect(Vector2(x, 256), Vector2(BOSS_W, 2), SK_COL, _boss_root)


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


## World position of the objective node the arrow follows (an exit when the target is in another zone), or null.
func target_pos() -> Variant:
	return _tnode.global_position if _tnode != null and is_instance_valid(_tnode) else null


func _update_arrow() -> void:
	_diamond.visible = false
	_dist.visible = false
	_dist_bg.visible = false
	if _tnode == null or not is_instance_valid(_tnode) or not _tnode.is_inside_tree():
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
	_dist_bg.position = _dist.position + Vector2(roundf((_dist.size.x - w) / 2.0), 0)
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
		_toast.visible = true
		_toast_root.visible = true
		_toast_left = TOAST_TIME
	if _toast_root.visible:   # slide in from the top, hold, fade (a pure function of the timer)
		var k := clampf((TOAST_TIME - _toast_left) / 0.25, 0.0, 1.0)
		k = 1.0 - (1.0 - k) * (1.0 - k)
		_toast_root.position.y = lerpf(-10.0, 6.0, k)
		_toast_root.modulate.a = minf(k, clampf(_toast_left / 0.4, 0.0, 1.0))
		_toast_rule.size.x = 300.0 * k
		_toast_rule.position.x = 150.0 - _toast_rule.size.x / 2.0


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


func _bar(pos: Vector2, w: int, h: int, col: Color, icon: String, parent: Node) -> Array:
	var ic := TextureRect.new()
	ic.texture = _ui_tex(icon)
	ic.position = Vector2(pos.x, pos.y + (h + 4 - 7) / 2)
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(ic)
	var frame := _nine("bar_frame", Rect2(pos.x + 9, pos.y, w + 4, h + 4), [3, 3, 3, 3], parent)
	var bg := ColorRect.new()   # the well: flashes red on a blocked action
	bg.color = Color(0, 0, 0, 0.6)
	bg.position = pos + Vector2(11, 2)
	bg.size = Vector2(w, h)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(bg)
	var lag := ColorRect.new()
	lag.color = Color(CREAM, 0.9)
	lag.size = Vector2(w, h)
	lag.visible = false
	bg.add_child(lag)
	var fill := ColorRect.new()
	fill.color = col
	fill.size = Vector2(w, h)
	bg.add_child(fill)
	return [fill, w, frame, lag, bg, ic]


func _fill(name: String, value: float, max_value: float) -> void:
	var b: Array = _bars[name]
	if name == "sk":   # Mage's 120 gauge draws 60 px wide (ui.md 2)
		var w := roundi(max_value * 0.5)
		if w != b[1]:
			b[1] = w
			b[2].size.x = w + 4
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
