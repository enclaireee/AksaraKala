extends MenuTab
## Pustaka (Codex), ui.md 4.3 tab 5. Ported from the old menu with minimal change: the same entry list, split over the
## two pages (enemies and legends left, items and aksara right). The list/detail codex of ui.md 4.3 replaces it next.
## Scroll positions survive Game.changed.

const CATS_LEFT := ["enemy", "legend"]
const CATS_RIGHT := ["item", "aksara"]

var list: VBoxContainer    # left page (GameMenu._codex)
var _right: VBoxContainer


func title_key() -> String:
	return "UI_BK_TAB_CODEX"


func icon() -> String:
	return "codex"


func build(l: Control, r: Control) -> void:
	list = scroll(l, Rect2(0, 0, 200, 212))
	_right = scroll(r, Rect2(0, 0, 200, 212))


func _label(box: Control, text: String, color := MenuBook.INK, heading := false) -> Label:
	var l := MenuBook.head(tr(text)) if heading else MenuBook.text(tr(text), color, true)
	box.add_child(l)
	return l


func refresh() -> void:
	var g := game
	var sl: int = list.get_parent().scroll_vertical
	var sr: int = _right.get_parent().scroll_vertical
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
	_label(list, tr("UI_CODEX_PERCENT") % int(g.codex_percent()), MenuBook.INK, true)
	for side in [[list, CATS_LEFT], [_right, CATS_RIGHT]]:
		var box: VBoxContainer = side[0]
		for cat: String in side[1]:
			if not by_cat.has(cat) and cat != "item":
				continue
			box.add_child(MenuBook.bold(tr("UI_CAT_" + cat.to_upper()), MenuBook.INK_HEAD))
			var entries: Array = by_cat.get(cat, [])
			if cat == "item":   # the Kujang Pusaka first
				entries.sort_custom(func(a: CodexEntry, b: CodexEntry) -> bool: return a.id == "kujang" and b.id != "kujang")
			for e: CodexEntry in entries:
				var U := e.id.to_upper()
				if e.id not in g.codex:
					_label(box, "UI_LOCKED", MenuBook.INK_FADE)
					continue
				box.add_child(MenuBook.bold(tr("CODEX_%s_TITLE" % U)))
				_label(box, "CODEX_%s_BODY" % U, MenuBook.INK_DIM)
				if e.id == "kujang":
					_label(box, "%s %d/4 · +%d%% · %s %d" % [tr("UI_INGATAN"), g.ingatan, roundi((g.power_mult() - 1.0) * 100.0), tr("UI_DAYA"), g.daya()], MenuBook.VERD)
				if g.has_flag("weak:" + e.id):
					_label(box, "%s: %s" % [tr("UI_WEAKNESS"), tr("CODEX_%s_WEAK" % U)])
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
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		var ic := TextureRect.new()
		ic.texture = it.icon
		ic.custom_minimum_size = Vector2(16, 16)
		ic.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		ic.size_flags_vertical = SIZE_SHRINK_BEGIN
		ic.mouse_filter = MOUSE_FILTER_IGNORE
		row.add_child(ic)
		var col := VBoxContainer.new()
		col.size_flags_horizontal = SIZE_EXPAND_FILL
		col.add_theme_constant_override("separation", 0)
		col.add_child(MenuBook.bold(tr(it.title)))
		col.add_child(MenuBook.text(tr(it.description), MenuBook.INK_DIM, true))
		var lk := "ITEM_%s_LORE" % it.id.to_upper()
		if tr(lk) != lk:
			col.add_child(MenuBook.text(tr(lk), MenuBook.INK_FADE, true))
		row.add_child(col)
		box.add_child(row)
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
	list.get_parent().scroll_vertical = sl
	_right.get_parent().scroll_vertical = sr


func hints() -> Array:
	return [["@mouse", "UI_BK_HINT_SCROLL"]]
