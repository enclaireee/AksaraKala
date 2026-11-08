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
			if not by_cat.has(cat):
				continue
			box.add_child(MenuBook.bold(tr("UI_CAT_" + cat.to_upper()), MenuBook.INK_HEAD))
			for e: CodexEntry in by_cat[cat]:
				var U := e.id.to_upper()
				if e.id not in g.codex:
					_label(box, "UI_LOCKED", MenuBook.INK_FADE)
					continue
				box.add_child(MenuBook.bold(tr("CODEX_%s_TITLE" % U)))
				_label(box, "CODEX_%s_BODY" % U, MenuBook.INK_DIM)
				if g.has_flag("weak:" + e.id):
					_label(box, "%s: %s" % [tr("UI_WEAKNESS"), tr("CODEX_%s_WEAK" % U)])
	_restore.call_deferred(sl, sr)


func _restore(sl: int, sr: int) -> void:
	list.get_parent().scroll_vertical = sl
	_right.get_parent().scroll_vertical = sr


func hints() -> Array:
	return [["@mouse", "UI_BK_HINT_SCROLL"]]
