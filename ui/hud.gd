extends Control
## In-play HUD (ui.md 2). Placeholder bars; reads the player's components every frame.
## ponytail: polling instead of signals so a replaced player (scene change) needs no re-bind.

const HP_COL := Color("D55E00")
const ST_COL := Color("F0E442")
const SK_COL := Color("56B4E9")
const FLASK_COL := Color("009E73")
const GOLD := Color("E8D9A0")

var _bars := {}   # name -> [fill ColorRect, width]
var _pips: Array[ColorRect] = []
var _ilmu: Label
var _saved: Label
var _saved_left := 0.0
var _objective: Label
var _hint: Label
var _player: Node   # the player whose `blocked` signal is connected (a new zone brings a new one)

# toasts (quests.md 7.6): one at a time, TOAST_TIME each, queued
const TOAST_TIME := 3.0
var _toast: Label
var _toasts: Array[String] = []
var _toast_left := 0.0

# objective arrow (quests.md 7.5)
const SCREEN := Vector2(480, 270)
const ARROW_MARGIN := 10.0
var _arrow: Node2D
var _tnode: Node2D   # what the arrow points at: a marker node, or the exit toward the target zone

# boss bar (ui.md 2). Contract: node in group "boss" with `health` (Health), `boss_name_key: String`,
# optional `dawn: float` (0-1), and `engaged: bool` which the HUD polls. Shown while engaged and alive.
const BOSS_W := 240
var _boss_root: Control
var _boss_name: Label
var _boss_fill: ColorRect
var _dawn_bg: ColorRect
var _dawn_fill: ColorRect


func _ready() -> void:
	var t := Theme.new()
	t.default_font_size = 8
	theme = t
	_bars.hp = _bar(Vector2(6, 6), 80, 5, HP_COL)
	_bars.st = _bar(Vector2(6, 13), 64, 3, ST_COL)
	_bars.sk = _bar(Vector2(6, 18), 50, 3, SK_COL)
	for i in 6:
		var p := ColorRect.new()
		p.position = Vector2(6 + i * 9, 270 - 6 - 9)
		p.size = Vector2(7, 9)
		add_child(p)
		_pips.append(p)
	_ilmu = Label.new()
	_ilmu.position = Vector2(480 - 6 - 80, 4)
	_ilmu.size = Vector2(80, 12)
	_ilmu.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_ilmu.add_theme_color_override("font_color", GOLD)
	add_child(_ilmu)
	_saved = Label.new()
	_saved.text = "UI_SAVED"
	_saved.position = Vector2(480 - 6 - 90, 270 - 6 - 12)
	_saved.size = Vector2(90, 12)
	_saved.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_saved.visible = false
	add_child(_saved)
	_build_extras()
	_objective = _line(24, GOLD)
	_hint = _line(34, Color.WHITE)
	var g := get_node("/root/Game")
	g.changed.connect(refresh)
	g.changed.connect(refresh_objective)
	g.saved.connect(func() -> void:
		_saved_left = 1.0
		_saved.visible = true)
	var ev := get_node("/root/Events")
	ev.quest_started.connect(func(id: String) -> void:
		_push_toast(tr("UI_TOAST_QUEST_STARTED") % _title(id))
		refresh_arrow())
	ev.quest_updated.connect(func(_id: String) -> void: refresh_arrow())
	for s in ["quest_started", "quest_updated", "quest_completed", "zone_entered"]:
		ev.connect(s, refresh_objective.unbind(1))
	ev.area_entered.connect(func(id: String) -> void:
		if id == "sande_room" and not g.has_flag("hint_sande"):   # one-time hint (bestiary.md Sandekala)
			g.run("flag:hint_sande")
			_push_toast(tr("UI_HINT_SANDE")))
	ev.quest_completed.connect(func(id: String) -> void:
		_push_toast(tr("UI_TOAST_QUEST_DONE") % _title(id))
		refresh_arrow())
	ev.item_picked.connect(func(id: String) -> void:
		_push_toast(tr("UI_TOAST_ITEM") % tr("ITEM_%s_NAME" % id.to_upper())))
	ev.glyph_learned.connect(func(id: String) -> void:
		_push_toast(tr("UI_TOAST_GLYPH") % id.split("_")[-1].capitalize()))   # sunda_ka -> Ka
	ev.zone_entered.connect(func(_z: String) -> void: refresh_arrow())
	refresh()
	refresh_arrow()
	refresh_objective()


func _line(y: int, col: Color) -> Label:
	var l := Label.new()
	l.position = Vector2(6, y)
	l.size = Vector2(200, 10)
	l.add_theme_color_override("font_color", col)
	_outlined(l)
	add_child(l)
	return l


## Objective and hint lines (ui.md 2). A hint is the objective key with _HINT, filled with live key names.
func refresh_objective() -> void:
	var g := get_node("/root/Game")
	_objective.text = g.objective_text()
	_hint.text = ""
	for id in g._tracked():
		var st: QuestStep = g.current_step(id)
		if st:
			var key := st.objective.replace("_OBJ", "_HINT")
			if tr(key) != key:
				var keys := {}
				for a in ["interact", "cast", "attack", "dodge", "menu"]:
					keys[a] = g.key_name(a)
				keys.move = "%s%s%s%s" % [g.key_name("move_up"), g.key_name("move_left"), g.key_name("move_down"), g.key_name("move_right")]
				_hint.text = tr(key).format(keys)
			return


## Red flash on the bar whose resource ran out (ui.md 2).
func _on_blocked(what: String) -> void:
	var nodes: Array = _pips if what == "flask" else [_bars[what][0].get_parent()]
	for n: ColorRect in nodes:
		n.color = Color.RED
		var tw := create_tween()
		tw.tween_property(n, "color", Color(0, 0, 0, 0.6) if what != "flask" else FLASK_COL, 0.25)
		tw.finished.connect(refresh)   # restores the dim empty pips


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
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 1)


func _build_extras() -> void:
	_toast = Label.new()
	_toast.position = Vector2(90, 6)
	_toast.size = Vector2(300, 12)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.add_theme_color_override("font_color", GOLD)
	_outlined(_toast)
	_toast.visible = false
	add_child(_toast)
	_arrow = Node2D.new()
	for pts: Array in [[Vector2(-4, -4), Vector2(5, 0), Vector2(-4, 4)], [Vector2(-3, -2.5), Vector2(3, 0), Vector2(-3, 2.5)]]:
		var poly := Polygon2D.new()
		poly.polygon = PackedVector2Array(pts)
		poly.color = Color(0, 0, 0, 0.8) if pts[0].x < -3.5 else GOLD
		_arrow.add_child(poly)
	_arrow.visible = false
	add_child(_arrow)
	_boss_root = Control.new()
	_boss_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_boss_root.visible = false
	add_child(_boss_root)
	var x := (480 - BOSS_W) / 2
	_boss_name = Label.new()
	_boss_name.position = Vector2(x, 234)
	_boss_name.size = Vector2(BOSS_W, 12)
	_boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_outlined(_boss_name)
	_boss_root.add_child(_boss_name)
	_rect(Vector2(x, 247), Vector2(BOSS_W, 5), Color(0, 0, 0, 0.6), _boss_root)
	_boss_fill = _rect(Vector2(x, 247), Vector2(BOSS_W, 5), HP_COL, _boss_root)
	_rect(Vector2(x + BOSS_W / 2, 247), Vector2(1, 5), Color(0, 0, 0, 0.8), _boss_root)   # phase 2 at 50%
	_dawn_bg = _rect(Vector2(x, 253), Vector2(BOSS_W, 2), Color(0, 0, 0, 0.6), _boss_root)
	_dawn_fill = _rect(Vector2(x, 253), Vector2(BOSS_W, 2), SK_COL, _boss_root)


func _push_toast(text: String) -> void:
	_toasts.append(text)


## Finds the node the arrow points at (marker in this zone, or the exit toward the target's zone).
## Called on quest events and zone_entered; the position is read every frame.
func refresh_arrow() -> void:
	_tnode = null
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
	# ponytail: one scan of the tree per event; no group or lookup hook in Zone yet
	for n in get_tree().root.find_children("*", "Node2D", true, false):
		if nxt != "":
			if "target_zone" in n and n.target_zone == nxt:
				_tnode = n
				return
		elif id in [n.get("id"), n.get("npc_id"), n.get("trigger_id"), n.get("area_id"), n.get("kind"), n.name]:
			_tnode = n
			return


func _update_arrow() -> void:
	if _tnode == null or not is_instance_valid(_tnode) or not _tnode.is_inside_tree():
		_arrow.visible = false
		return
	var p: Vector2 = get_viewport().get_canvas_transform() * _tnode.global_position
	if Rect2(Vector2.ZERO, SCREEN).has_point(p):
		_arrow.visible = false
		return
	var c := SCREEN / 2
	var d := p - c
	var half := c - Vector2(ARROW_MARGIN, ARROW_MARGIN)
	var k := minf(half.x / maxf(absf(d.x), 0.001), half.y / maxf(absf(d.y), 0.001))
	_arrow.position = (c + d * k).round()
	_arrow.rotation = d.angle()
	_arrow.visible = true


func _update_toast(delta: float) -> void:
	if _toast_left > 0.0:
		_toast_left -= delta
		if _toast_left <= 0.0:
			_toast.visible = false
	if _toast_left <= 0.0 and not _toasts.is_empty():
		_toast.text = _toasts.pop_front()
		_toast.visible = true
		_toast_left = TOAST_TIME


func _update_boss() -> void:
	var b := get_tree().get_first_node_in_group("boss")
	var h = b.get("health") if b else null
	_boss_root.visible = h != null and bool(b.get("engaged")) and h.hp > 0
	if not _boss_root.visible:
		return
	_boss_name.text = tr(str(b.get("boss_name_key")))
	_boss_fill.size.x = roundf(BOSS_W * clampf(float(h.hp) / maxf(h.max_hp, 1.0), 0.0, 1.0))
	var dawn = b.get("dawn")
	_dawn_bg.visible = dawn != null
	_dawn_fill.visible = dawn != null
	if dawn != null:
		_dawn_fill.size.x = roundf(BOSS_W * clampf(float(dawn), 0.0, 1.0))


func _bar(pos: Vector2, w: int, h: int, col: Color) -> Array:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.position = pos
	bg.size = Vector2(w, h)
	add_child(bg)
	var fill := ColorRect.new()
	fill.color = col
	fill.size = Vector2(w, h)
	bg.add_child(fill)
	return [fill, w]


func _fill(name: String, value: float, max_value: float) -> void:
	var b: Array = _bars[name]
	b[0].size.x = roundf(b[1] * clampf(value / maxf(max_value, 1.0), 0.0, 1.0))


func refresh() -> void:
	var g := get_node("/root/Game")
	_ilmu.text = "Ilmu %d" % g.ilmu
	for i in _pips.size():
		_pips[i].visible = i < g.flask_max
		_pips[i].color = FLASK_COL if i < g.flask_charges else FLASK_COL.darkened(0.7)


func _process(delta: float) -> void:
	var p := get_tree().get_first_node_in_group("player")
	if p:
		if p != _player:
			_player = p
			p.blocked.connect(_on_blocked)
		_fill("hp", p.health.hp, p.health.max_hp)
		_fill("st", p.stamina.value, p.stamina.max_stamina)
		_fill("sk", p.sakti.value, p.sakti.max_value)
	_update_toast(delta)
	_update_arrow()
	_update_boss()
	if _saved_left > 0.0:
		_saved_left -= delta
		_saved.visible = _saved_left > 0.0
