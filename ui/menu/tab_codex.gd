extends MenuTab
## Pustaka (Codex), ui.md 4.3 tab 5: Enemy & Legend entries on the left page, Items & Aksara on the right,
## presented as archival cards with category counters, item wells, glyph tiles, and keyboard scrolling.

const CATS_LEFT := ["enemy", "legend"]
const CATS_RIGHT := ["item", "aksara"]
const Lesson := preload("res://ui/glyph_lesson.gd")

var list: VBoxContainer    # left page (GameMenu._codex, tests/i18n_test.gd)
var _right: VBoxContainer
var _left_scroll: ScrollContainer
var _right_scroll: ScrollContainer
static var _glyph_fonts := {}


func title_key() -> String:
	return "UI_BK_TAB_CODEX"


func icon() -> String:
	return "codex"


func build(l: Control, r: Control) -> void:
	list = scroll(l, Rect2(0, 0, 200, 208))   # ends clear of the footer rule
	list.add_theme_constant_override("separation", 4)
	_left_scroll = list.get_parent().get_parent()
	_right = scroll(r, Rect2(0, 0, 200, 208))   # ends clear of the footer rule
	_right.add_theme_constant_override("separation", 4)
	_right_scroll = _right.get_parent().get_parent()


static func _glyph_font(is_jawa: bool) -> FontVariation:
	if not _glyph_fonts.has(is_jawa):
		var f := FontVariation.new()
		f.base_font = load(Lesson.JAWA if is_jawa else Lesson.SUNDA)
		_glyph_fonts[is_jawa] = f
	return _glyph_fonts[is_jawa]


func _label(box: Control, text: String, color := MenuBook.INK, heading := false) -> Label:
	var l := MenuBook.head(tr(text)) if heading else MenuBook.text(tr(text), color, true)
	box.add_child(l)
	return l


func _card(box: Control) -> VBoxContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", MenuBook.box("book_card", 4, 5))
	p.size_flags_horizontal = SIZE_EXPAND_FILL
	p.mouse_filter = MOUSE_FILTER_IGNORE
	box.add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 1)   # 13 px line + 1 = the 14 px pitch
	v.mouse_filter = MOUSE_FILTER_IGNORE
	p.add_child(v)
	return v


func _cat_header(box: Control, cat: String, found: int, total: int) -> void:
	var hdr := Control.new()
	hdr.custom_minimum_size = Vector2(0, 16)
	hdr.mouse_filter = MOUSE_FILTER_IGNORE
	var sec := MenuBook.section(tr("UI_CAT_" + cat.to_upper()), 190)
	hdr.add_child(sec)
	if total > 0:
		var cnt := MenuBook.num("%d/%d" % [found, total], MenuBook.INK_DIM)
		cnt.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		cnt.position = Vector2(138, 1)
		cnt.size = Vector2(52, 13)
		hdr.add_child(cnt)
	box.add_child(hdr)


func refresh() -> void:
	var g := game
	var sl: int = _left_scroll.scroll_vertical
	var sr: int = _right_scroll.scroll_vertical
	clear(list)
	clear(_right)
	var by_cat := {}
	for f in DirAccess.get_files_at(CodexEntry.dir):
		var e := CodexEntry.by_id(f.trim_suffix(".remap").trim_suffix(".tres"))
		if e and f.contains(".tres"):
			by_cat.get_or_add(e.category, []).append(e)
	if by_cat.is_empty():
		_label(list, "UI_CODEX_EMPTY", MenuBook.INK_DIM)
		return
	var pct := MenuBook.bold(tr("UI_CODEX_PERCENT") % int(g.codex_percent()), UIFx.WARM)
	list.add_child(pct)
	for side in [[list, CATS_LEFT], [_right, CATS_RIGHT]]:
		var box: VBoxContainer = side[0]
		for cat: String in side[1]:
			if not by_cat.has(cat) and cat != "item":
				continue
			var entries: Array = by_cat.get(cat, [])
			if cat == "item":
				entries.sort_custom(func(a: CodexEntry, b: CodexEntry) -> bool: return a.id == "kujang" and b.id != "kujang")
			var unlocked := 0
			for e: CodexEntry in entries:
				if e.id in g.codex:
					unlocked += 1
			_cat_header(box, cat, unlocked, entries.size())
			var locked_count := 0
			for e: CodexEntry in entries:
				if e.id not in g.codex:
					locked_count += 1
					continue
				var U := e.id.to_upper()
				var c := _card(box)
				if cat == "aksara" and Lesson.CHARS.has(e.id):
					var row := HBoxContainer.new()
					row.add_theme_constant_override("separation", 6)
					row.mouse_filter = MOUSE_FILTER_IGNORE
					var tile := MenuBook.nine("book_glyph_tile", Rect2(0, 0, 18, 18), 4)
					tile.custom_minimum_size = Vector2(18, 18)
					var gl := Label.new()
					gl.text = Lesson.CHARS[e.id]
					gl.add_theme_font_override("font", _glyph_font(e.id.begins_with("jawa")))
					gl.add_theme_font_size_override("font_size", 10 if e.id.begins_with("jawa") else 12)
					gl.add_theme_color_override("font_color", UIFx.ACCENT)
					gl.add_theme_constant_override("outline_size", 0)
					gl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
					gl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
					gl.size = Vector2(18, 18)
					tile.add_child(gl)
					row.add_child(tile)
					var tl := MenuBook.bold(tr("CODEX_%s_TITLE" % U), MenuBook.INK_HEAD)
					tl.size_flags_vertical = SIZE_SHRINK_CENTER
					tl.size_flags_horizontal = SIZE_EXPAND_FILL
					row.add_child(tl)
					c.add_child(row)
				else:
					c.add_child(MenuBook.bold(tr("CODEX_%s_TITLE" % U), MenuBook.INK_HEAD))
				_label(c, "CODEX_%s_BODY" % U, MenuBook.INK_DIM)
				if e.id == "kujang":
					_label(c, "%s %d/4 · +%d%% · %s %d" % [tr("UI_INGATAN"), g.ingatan, roundi((g.power_mult() - 1.0) * 100.0), tr("UI_DAYA"), g.daya()], MenuBook.VERD)
				if g.has_flag("weak:" + e.id):
					_label(c, "%s: %s" % [tr("UI_WEAKNESS"), tr("CODEX_%s_WEAK" % U)], UIFx.ACCENT)
			if locked_count > 0:
				var urow := HBoxContainer.new()
				urow.add_theme_constant_override("separation", 4)
				urow.add_child(MenuBook.text(tr("UI_UNKNOWN"), MenuBook.INK_FADE))
				urow.add_child(MenuBook.text("×%d" % locked_count, MenuBook.INK_FADE))
				box.add_child(urow)
			if cat == "item":
				_items(box)
	_restore.call_deferred(sl, sr)


## Every obtainable ItemData weapon, armor and jimat, by slot then name, with its own found/total (codex_percent ignores these).
func _items(box: VBoxContainer) -> void:
	var all: Array[ItemData] = []
	var cls: String = game.class_id
	var start_w := ""
	if cls != "":
		var cd := ClassData.by_id(cls)
		if cd:
			start_w = cd.start_weapon
	const STARTERS := ["dagger", "broadsword", "hunting_bow", "oak_staff", "tombak_prajurit", "bandring", "kipas", "kayon"]
	for f in DirAccess.get_files_at("res://data/items"):
		var it := ItemData.by_id(f.trim_suffix(".remap").trim_suffix(".tres"))
		if it and f.contains(".tres"):
			if not owned(it) and cls != "":
				if it.favoured != "" and it.favoured != cls:
					continue
				if it.id in STARTERS and it.id != start_w:
					continue
			all.append(it)
	var order := ["weapon", "armor", "accessory"]
	all.sort_custom(func(a: ItemData, b: ItemData) -> bool:
		if a.slot != b.slot:
			return order.find(a.slot) < order.find(b.slot)
		return tr(a.title) < tr(b.title))
	var found := all.filter(func(it: ItemData) -> bool: return owned(it))
	box.add_child(MenuBook.bold(tr("UI_CODEX_ITEMS_FOUND") % [found.size(), all.size()], MenuBook.INK_HEAD))
	for it in found:
		var c := _card(box)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		row.mouse_filter = MOUSE_FILTER_IGNORE
		var well := MenuBook.nine("ink_slot", Rect2(0, 0, 20, 20), 4)
		well.custom_minimum_size = Vector2(20, 20)
		well.size_flags_vertical = SIZE_SHRINK_BEGIN
		var ic := TextureRect.new()
		ic.texture = it.icon
		ic.position = Vector2(2, 2)
		ic.size = Vector2(16, 16)
		ic.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		ic.mouse_filter = MOUSE_FILTER_IGNORE
		well.add_child(ic)
		row.add_child(well)
		var tl := MenuBook.bold(tr(it.title), MenuBook.INK_HEAD)
		tl.size_flags_vertical = SIZE_SHRINK_CENTER
		tl.size_flags_horizontal = SIZE_EXPAND_FILL
		tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(tl)
		c.add_child(row)   # body text below starts at the card edge, same as every other card
		c.add_child(MenuBook.text(tr(it.description), MenuBook.INK_DIM, true))
		var lk := "ITEM_%s_LORE" % it.id.to_upper()
		if tr(lk) != lk:
			c.add_child(MenuBook.text(tr(lk), MenuBook.INK_FADE, true))
	var unowned := all.size() - found.size()
	if unowned > 0:
		var urow := HBoxContainer.new()
		urow.add_theme_constant_override("separation", 4)
		urow.add_child(MenuBook.text(tr("UI_UNKNOWN"), MenuBook.INK_FADE))
		urow.add_child(MenuBook.text("×%d" % unowned, MenuBook.INK_FADE))
		box.add_child(urow)


func owned(it: ItemData) -> bool:
	return it.id in game.inventory or it.id in game.jimat or it.id in game.equipped.values()


func _restore(sl: int, sr: int) -> void:
	_left_scroll.scroll_vertical = sl
	_right_scroll.scroll_vertical = sr


func handle_input(e: InputEvent) -> bool:
	if e.is_action_pressed("ui_up", true):
		_left_scroll.scroll_vertical -= UIFx.LINE * 2
		return true
	if e.is_action_pressed("ui_down", true):
		_left_scroll.scroll_vertical += UIFx.LINE * 2
		return true
	if e.is_action_pressed("ui_left", true) or (e is InputEventKey and e.pressed and e.physical_keycode == KEY_PAGEUP):
		_right_scroll.scroll_vertical -= UIFx.LINE * 2
		return true
	if e.is_action_pressed("ui_right", true) or (e is InputEventKey and e.pressed and e.physical_keycode == KEY_PAGEDOWN):
		_right_scroll.scroll_vertical += UIFx.LINE * 2
		return true
	return false


func hints() -> Array:
	return [["@updown", "UI_BK_HINT_SCROLL"]]
