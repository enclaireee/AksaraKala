extends MenuTab
## Diri (Status), ui.md 4.3 tab 1. Left page: the hero's class figure (idle frames of class_<id>.png) on a painted
## ground disc, name, class, level wax seal, Ilmu bar. Right page: the 5 attributes (icon, pips, value, + when a point
## can be spent at a Petilasan), a points-to-spend seal, the derived-stat table and the learned glyph tiles.

const STATS := ["vit", "end", "str", "dex", "spi"]
const NAMES := {"vit": "UI_STAT_VIT", "end": "UI_STAT_END", "str": "UI_STAT_STR", "dex": "UI_STAT_DEX", "spi": "UI_STAT_SPI"}
const HINTS := {"vit": "UI_HINT_VIT", "end": "UI_HINT_END", "str": "UI_HINT_STR", "dex": "UI_HINT_DEX", "spi": "UI_HINT_SPI"}
const PIPS := 15          # pips per attribute row (a value above shows as a full row; the number is exact)
const FRAME_W := 96
const FRAME_H := 128
const FRAMES := 6
const FRAME_TIME := 0.16  # TUNE: idle cycle speed
const Lesson := preload("res://ui/glyph_lesson.gd")
const TUNING := preload("res://data/combat_tuning.tres")

var raise := {}           # stat -> "+" Button (tests and GameMenu._raise)
var confirm_yes: Button
var _pending := ""
var _rows := {}           # stat -> row Button
var _vals := {}           # stat -> value Label
var _pips := {}           # stat -> HBoxContainer
var _effect: Label
var _confirm: HBoxContainer
var _confirm_lbl: Label
var _name: Label
var _class: Label
var _level: Label
var _figure: TextureRect
var _atlas: AtlasTexture
var _frame := 0
var _clock := 0.0
var _ilmu_val: Label
var _bar_fill: NinePatchRect
var _bar_w := 0
var _status_line: Label
var _pts_seal: Control
var _pts_num: Label
var _derived := {}        # key -> value Label
var _glyphs: HBoxContainer
var _no_glyphs: Label
var _time: Label
var _focus_stat := "vit"


func title_key() -> String:
	return "UI_BK_TAB_STATUS"


func icon() -> String:
	return "status"


func build(l: Control, r: Control) -> void:
	# --- left page: who you are
	_name = MenuBook.head("", 16)
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	put(l, _name, Vector2(0, -2), Vector2(200, 20))
	_class = MenuBook.italic("", MenuBook.INK_DIM, false)
	_class.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	put(l, _class, Vector2(0, 18), Vector2(200, 10))
	put(l, MenuBook.pic("book_disc", Vector2(56, 150)), Vector2(56, 150))
	_atlas = AtlasTexture.new()
	_figure = TextureRect.new()
	_figure.texture = _atlas
	_figure.stretch_mode = TextureRect.STRETCH_KEEP
	_figure.mouse_filter = MOUSE_FILTER_IGNORE
	put(l, _figure, Vector2(52, 32), Vector2(FRAME_W, FRAME_H))
	# level seal, top left of the figure
	put(l, MenuBook.pic("book_seal", Vector2.ZERO), Vector2(8, 40))
	_level = MenuBook.num("", MenuBook.PAPER_HI, 20)
	_level.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_level.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	put(l, _level, Vector2(8, 40), Vector2(28, 26))
	var lv := MenuBook.bold(tr("UI_BK_LEVEL"), MenuBook.INK_HEAD)
	lv.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	put(l, lv, Vector2(0, 70), Vector2(44, 10))
	# play time, top right (balances the seal)
	put(l, MenuBook.pic("book_ic_time", Vector2.ZERO), Vector2(173, 32))
	_time = MenuBook.num("", MenuBook.INK, 10)
	_time.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	put(l, _time, Vector2(156, 46), Vector2(44, 12))
	var tl := MenuBook.bold(tr("UI_BK_TIME"), MenuBook.INK_HEAD)
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	put(l, tl, Vector2(156, 70), Vector2(44, 10))
	# Ilmu: label, value, bar, status line
	put(l, MenuBook.pic("book_ic_ilmu", Vector2.ZERO), Vector2(0, 170))
	put(l, MenuBook.bold(tr("UI_BK_ILMU"), MenuBook.INK_HEAD), Vector2(14, 168), Vector2(80, 12))
	_ilmu_val = MenuBook.num("", MenuBook.INK)
	_ilmu_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	put(l, _ilmu_val, Vector2(100, 167), Vector2(100, 12))
	put(l, MenuBook.nine("book_bar", Rect2(0, 182, 200, 8), 2), Vector2(0, 182))
	_bar_fill = MenuBook.nine("book_bar_fill", Rect2(1, 183, 0, 6), 1)
	_bar_fill.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
	_bar_fill.patch_margin_top = 0
	_bar_fill.patch_margin_bottom = 0
	put(l, _bar_fill, Vector2(1, 183))
	_bar_w = 198
	_status_line = MenuBook.italic("", MenuBook.INK_DIM, false)
	put(l, _status_line, Vector2(0, 194), Vector2(200, 12))
	# --- right page: attributes
	var sec := MenuBook.section(tr("UI_BK_ATTRS"))
	put(r, sec, Vector2(0, 0))
	_pts_seal = Control.new()
	_pts_seal.mouse_filter = MOUSE_FILTER_IGNORE
	put(r, _pts_seal, Vector2(120, -3), Vector2(80, 16))
	var pl := MenuBook.bold(tr("UI_BK_POINTS"), MenuBook.WAX)
	pl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	put(_pts_seal, pl, Vector2(0, 3), Vector2(62, 12))
	put(_pts_seal, MenuBook.pic("book_seal_small", Vector2.ZERO), Vector2(64, 0))
	_pts_num = MenuBook.num("", MenuBook.PAPER_HI)
	_pts_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pts_num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	put(_pts_seal, _pts_num, Vector2(64, 0), Vector2(16, 15))
	for i in STATS.size():
		var s: String = STATS[i]
		var row := MenuBook.row_button(16)
		row.name = "Row_" + s
		put(r, row, Vector2(0, 20 + i * 16), Vector2(200, 16))
		put(row, MenuBook.pic("book_ic_" + s, Vector2.ZERO), Vector2(4, 3))
		put(row, MenuBook.text(tr(NAMES[s])), Vector2(18, 2), Vector2(76, 12))
		var pips := HBoxContainer.new()
		pips.add_theme_constant_override("separation", 1)
		pips.mouse_filter = MOUSE_FILTER_IGNORE
		put(row, pips, Vector2(94, 5), Vector2(60, 5))
		_pips[s] = pips
		var v := MenuBook.num("", MenuBook.INK)
		v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		put(row, v, Vector2(154, 1), Vector2(20, 12))
		_vals[s] = v
		var b := Button.new()
		b.focus_mode = FOCUS_NONE
		b.flat = true
		b.icon = MenuBook.tex("book_plus")
		for st in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
			b.add_theme_stylebox_override(st, StyleBoxEmpty.new())
		b.pressed.connect(ask.bind(s))
		b.mouse_entered.connect(func() -> void: b.icon = MenuBook.tex("book_plus_hi") if not b.disabled else b.icon)
		b.mouse_exited.connect(_paint_plus.bind(s))
		put(row, b, Vector2(184, 2), Vector2(11, 11))
		raise[s] = b
		row.pressed.connect(func() -> void:
			if not raise[s].disabled:
				ask(s))
		row.focus_entered.connect(func() -> void:
			_focus_stat = s
			_show_effect()
			menu.update_hints())
		_rows[s] = row
	for i in STATS.size():   # keyboard: up/down walk the rows and wrap
		var row: Button = _rows[STATS[i]]
		row.focus_neighbor_top = row.get_path_to(_rows[STATS[posmod(i - 1, STATS.size())]])
		row.focus_neighbor_bottom = row.get_path_to(_rows[STATS[posmod(i + 1, STATS.size())]])
		row.focus_neighbor_left = row.get_path()
		row.focus_neighbor_right = row.get_path()
	_effect = MenuBook.italic("", MenuBook.INK_DIM, false)
	_effect.clip_text = true
	put(r, _effect, Vector2(4, 101), Vector2(196, 12))
	_confirm = HBoxContainer.new()
	_confirm.visible = false
	_confirm.add_theme_constant_override("separation", 4)
	put(r, _confirm, Vector2(4, 100), Vector2(196, 13))
	_confirm_lbl = MenuBook.bold("", MenuBook.WAX)
	_confirm_lbl.size_flags_horizontal = SIZE_EXPAND_FILL
	_confirm_lbl.clip_text = true
	_confirm.add_child(_confirm_lbl)
	confirm_yes = MenuBook.small_button("UI_YES")
	confirm_yes.pressed.connect(_do_raise)
	_confirm.add_child(confirm_yes)
	var no := MenuBook.small_button("UI_CANCEL")
	no.pressed.connect(cancel)
	_confirm.add_child(no)
	confirm_yes.focus_neighbor_left = confirm_yes.get_path_to(no)
	no.focus_neighbor_right = no.get_path_to(confirm_yes)
	# derived stats: 2 columns x 3 rows
	put(r, MenuBook.section(tr("UI_BK_DERIVED")), Vector2(0, 118))
	var keys := [["hp", "UI_DER_HP"], ["atk", "UI_DER_ATK"], ["sta", "UI_BK_STAMINA"], ["def", "UI_DER_DEF"],
			["sak", "UI_BK_SAKTI"], ["jamu", "UI_BK_JAMU"]]
	for i in keys.size():
		var x := (i % 2) * 104
		var y := 138 + (i / 2) * 13
		put(r, MenuBook.pic("book_ic_" + keys[i][0], Vector2.ZERO), Vector2(x + 2, y + 1))
		put(r, MenuBook.text(tr(keys[i][1])), Vector2(x + 16, y), Vector2(56, 12))
		var v := MenuBook.num("", MenuBook.INK)
		v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		put(r, v, Vector2(x + 56, y - 1), Vector2(40, 12))
		_derived[keys[i][0]] = v
	# learned glyphs
	put(r, MenuBook.section(tr("UI_BK_GLYPHS")), Vector2(0, 178))
	_glyphs = HBoxContainer.new()
	_glyphs.add_theme_constant_override("separation", 2)
	_glyphs.mouse_filter = MOUSE_FILTER_IGNORE
	put(r, _glyphs, Vector2(0, 196), Vector2(200, 16))
	_no_glyphs = MenuBook.italic(tr("UI_BK_NO_GLYPHS"), MenuBook.INK_FADE, false)
	put(r, _no_glyphs, Vector2(0, 198), Vector2(200, 12))


func _process(d: float) -> void:
	if not is_visible_in_tree() or _atlas.atlas == null:
		return
	_clock += d
	if _clock >= FRAME_TIME:
		_clock = fmod(_clock, FRAME_TIME)
		_frame = (_frame + 1) % FRAMES
		_atlas.region = Rect2(_frame * FRAME_W, 0, FRAME_W, FRAME_H)


func refresh() -> void:
	var g := game
	var cls_id: String = g.class_id if g.class_id != "" else "warrior"
	var path := "res://assets/art/portraits/class_%s.png" % cls_id
	var strip: Texture2D = load(path) if ResourceLoader.exists(path) else null
	if strip != _atlas.atlas:
		_atlas.atlas = strip
		_atlas.region = Rect2(0, 0, FRAME_W, FRAME_H)
	_name.text = g.hero_name
	var ck := "CLASS_%s_NAME" % cls_id.to_upper()
	_class.text = tr(ck) if tr(ck) != ck else cls_id.capitalize()
	_level.text = str(g.level())
	var t := int(g.play_time)
	_time.text = "%d:%02d" % [t / 3600, (t / 60) % 60]
	var cost: int = g.level_cost()
	_ilmu_val.text = "%d / %d" % [g.ilmu, cost]
	var frac := clampf(float(g.ilmu) / maxf(cost, 1), 0.0, 1.0)
	_bar_fill.size.x = roundi(_bar_w * frac)
	_bar_fill.visible = _bar_fill.size.x >= 2
	var pts := points(g)
	var at: bool = menu.at_petilasan
	if not at:
		_status_line.text = tr("UI_REST_HINT")
	elif pts > 0:
		_status_line.text = tr("UI_BK_AT_SHRINE")
	else:
		_status_line.text = tr("UI_BK_NEED_ILMU") % (cost - g.ilmu)
	_pts_seal.visible = pts > 0
	_pts_num.text = str(pts)
	var can: bool = at and pts > 0
	for s in STATS:
		var base: int = g.stats.get(s, 0)
		var total: int = g.stat(s)
		_vals[s].text = str(total)
		_vals[s].add_theme_color_override("font_color", MenuBook.VERD if total > base else MenuBook.INK)
		clear(_pips[s])
		for i in PIPS:
			var name_ := "book_pip_off"
			if i < mini(base, PIPS):
				name_ = "book_pip_on"
			elif i < mini(total, PIPS):
				name_ = "book_pip_gear"
			var p := MenuBook.pic(name_, Vector2.ZERO)
			p.custom_minimum_size = Vector2(3, 5)
			_pips[s].add_child(p)
		raise[s].disabled = not can
		raise[s].visible = at
		_paint_plus(s)
	if not can:
		_confirm.visible = false
		_pending = ""
	_effect.visible = not _confirm.visible
	_show_effect()
	_refresh_derived(g)
	_refresh_glyphs(g)


func _paint_plus(s: String) -> void:
	raise[s].icon = MenuBook.tex("book_plus_off" if raise[s].disabled else "book_plus")


## How many level-ups the current Ilmu pays for (cost grows each time: Game.level_cost).
static func points(g: Node) -> int:
	var n := 0
	var spent: int = g.points_spent
	var left: int = g.ilmu
	while n < 99:
		var c := roundi(40.0 * pow(1.12, spent + n))
		if left < c:
			break
		left -= c
		n += 1
	return n


func _show_effect() -> void:
	if _effect:
		_effect.text = "%s: %s" % [tr(NAMES[_focus_stat]), tr(HINTS[_focus_stat])]


func _refresh_derived(g: Node) -> void:
	var w: ItemData = g.equipped_item("weapon")
	if w == null:
		w = ItemData.by_id("dagger")
	var hp: int = TUNING.stat_hp_base + TUNING.stat_hp_per * g.stat("vit") + int(g.bonus("max_hp"))
	var sta := int(TUNING.stat_stamina_base + TUNING.stat_stamina_per * g.stat("end"))
	var sak := int(TUNING.keen_mind_max if g.class_id == "mage" else TUNING.sakti_max)
	var atk := 0
	if w:
		atk = roundi(w.damage * (1.0 + TUNING.stat_damage_per * g.stat("str" if w.is_melee() else "dex")))
	var def := 0
	for slot in ["armor", "accessory"]:
		var it: ItemData = g.equipped_item(slot)
		def += it.defense if it else 0
	_derived.hp.text = str(hp)
	_derived.sta.text = str(sta)
	_derived.sak.text = str(sak)
	_derived.atk.text = str(atk)
	_derived["def"].text = str(def)
	_derived.jamu.text = "%d/%d" % [g.flask_charges, g.flask_max]


func _refresh_glyphs(g: Node) -> void:
	clear(_glyphs)
	var ids: PackedStringArray = g.glyphs_learned
	_no_glyphs.visible = ids.is_empty()
	for id in ids:
		var tile := MenuBook.nine("book_glyph_tile", Rect2(0, 0, 18, 18), 4)
		tile.custom_minimum_size = Vector2(18, 18)
		tile.tooltip_text = tr("SPELL_%s_NAME" % id.to_upper())
		tile.mouse_filter = MOUSE_FILTER_PASS
		var l := Label.new()
		l.text = Lesson.CHARS.get(id, "?")
		var f := FontVariation.new()
		f.base_font = load(Lesson.JAWA if id.begins_with("jawa") else Lesson.SUNDA)
		l.add_theme_font_override("font", f)
		l.add_theme_font_size_override("font_size", 10 if id.begins_with("jawa") else 12)
		l.add_theme_color_override("font_color", MenuBook.INK)
		l.add_theme_constant_override("outline_size", 0)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.position = Vector2(0, 0)
		l.size = Vector2(18, 18)
		l.mouse_filter = MOUSE_FILTER_IGNORE
		tile.add_child(l)
		_glyphs.add_child(tile)


func ask(stat: String) -> void:
	_pending = stat
	_confirm_lbl.text = tr("UI_RAISE_Q") % [tr(NAMES[stat]), game.level_cost()]
	_confirm.visible = true
	_effect.visible = false
	if is_inside_tree():
		confirm_yes.grab_focus()
	menu.update_hints()


func _do_raise() -> void:
	if _pending != "":
		game.level_up(_pending)
	cancel()


func cancel() -> void:
	var s := _pending
	_pending = ""
	_confirm.visible = false
	_effect.visible = true
	if s != "" and _rows[s].is_visible_in_tree():
		_rows[s].grab_focus()


func is_modal() -> bool:
	return _pending != ""


func back() -> bool:
	if _pending != "":
		cancel()
		return true
	return false


func focus_first() -> void:
	_rows[_focus_stat].grab_focus()


func hints() -> Array:
	if _pending != "":
		return [["Enter", "UI_YES"], ["Esc", "UI_CANCEL"]]
	var h := [["@updown", "UI_BK_HINT_SELECT"]]
	if menu.at_petilasan and points(game) > 0:
		h.append(["Enter", "UI_BK_HINT_RAISE"])
	return h
