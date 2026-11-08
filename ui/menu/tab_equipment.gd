extends MenuTab
## Perlengkapan (Equipment), ui.md 4.3 tab 2. Left page: a paper-doll outline with the Weapon / Armor / Accessory
## slots around it and the gear totals. Right page: the iron-rimmed inventory grid and an item card that always shows
## something (the focused item, else the equipped weapon) with compare arrows against the equipped item.

const SLOTS := ["weapon", "armor", "accessory"]
const ITEM_DIR := "res://assets/art/items/"
const COLS := 9
const STAT_KEYS := {"damage": "UI_DER_ATK", "defense": "UI_DER_DEF", "max_hp": "UI_DER_HP", "move_speed": "UI_BK_SPEED",
		"stamina_regen": "UI_BK_STA_REGEN", "vit": "UI_STAT_VIT", "end": "UI_STAT_END", "str": "UI_STAT_STR",
		"dex": "UI_STAT_DEX", "spi": "UI_STAT_SPI"}
# doll slot positions on the left page (24x24 wells) and the doll point each leader line runs to
const DOLL := Vector2(72, 24)
const SLOT_POS := {"weapon": Vector2(16, 64), "armor": Vector2(160, 40), "accessory": Vector2(160, 92)}
const SLOT_TO := {"weapon": Vector2(DOLL.x + 6, DOLL.y + 60), "armor": Vector2(DOLL.x + 40, DOLL.y + 40),
		"accessory": Vector2(DOLL.x + 34, DOLL.y + 21)}

var focus_id := ""        # item id focused in the grid (kept across rebuilds)
var _doll_btn := {}       # slot -> Button
var _doll_icon := {}      # slot -> TextureRect
var _doll_name := {}      # slot -> Label
var _totals: GridContainer
var _grid: GridContainer
var _grid_scroll: ScrollContainer
var _count: Label
var _card_icon: TextureRect
var _card_name: Label
var _card_type: Label
var _card_tag: Label
var _card_stats: VBoxContainer
var _card_desc: Label
var _card_item: ItemData
var _empty: Label


func title_key() -> String:
	return "UI_BK_TAB_EQUIP"


func icon() -> String:
	return "equip"


func build(l: Control, r: Control) -> void:
	put(l, MenuBook.section(tr("UI_BK_EQUIPPED")), Vector2.ZERO)
	var leaders := Control.new()   # dotted ink leader lines from each slot to the doll
	leaders.mouse_filter = MOUSE_FILTER_IGNORE
	leaders.draw.connect(func() -> void:
		for s in SLOTS:
			var p: Vector2 = SLOT_POS[s] + Vector2(12, 12)
			var from := p + Vector2(13 if p.x < DOLL.x else -13, 0)
			var to: Vector2 = SLOT_TO[s]
			var mid := Vector2(to.x + (-6 if from.x < to.x else 6), from.y)
			leaders.draw_dashed_line(from, mid, Color(MenuBook.INK_DIM, 0.7), 1.0, 2.0)
			leaders.draw_dashed_line(mid, to, Color(MenuBook.INK_DIM, 0.7), 1.0, 2.0)
			leaders.draw_rect(Rect2(to - Vector2(1, 1), Vector2(2, 2)), MenuBook.INK_DIM))
	put(l, leaders, Vector2.ZERO, Vector2(200, 140))
	put(l, MenuBook.pic("book_doll", Vector2.ZERO), DOLL)
	for s in SLOTS:
		var b := Button.new()
		b.focus_mode = FOCUS_ALL
		b.add_theme_stylebox_override("normal", MenuBook.box("book_slot", 5, 4))
		for st in ["hover", "focus", "pressed", "hover_pressed"]:
			b.add_theme_stylebox_override(st, MenuBook.box("book_slot_sel", 5, 4))
		b.mouse_entered.connect(func() -> void: b.grab_focus())
		b.focus_entered.connect(func() -> void:
			_show_card(game.equipped_item(s))
			menu.update_hints())
		b.pressed.connect(_jump_to_slot.bind(s))
		put(l, b, SLOT_POS[s], Vector2(24, 24))
		var ic := TextureRect.new()
		ic.mouse_filter = MOUSE_FILTER_IGNORE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		put(b, ic, Vector2(4, 4), Vector2(16, 16))
		_doll_btn[s] = b
		_doll_icon[s] = ic
		var cx: float = SLOT_POS[s].x + 12
		var lbl := MenuBook.bold(tr("UI_SLOT_" + s.to_upper()), MenuBook.INK_HEAD)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		put(l, lbl, Vector2(cx - 30, SLOT_POS[s].y + 25), Vector2(60, 10))
		var nm := MenuBook.text("", MenuBook.INK_DIM)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nm.clip_text = true
		nm.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		put(l, nm, Vector2(cx - 30, SLOT_POS[s].y + 34), Vector2(60, 10))
		_doll_name[s] = nm
	put(l, MenuBook.section(tr("UI_BK_GEAR_TOTALS")), Vector2(0, 144))
	_totals = GridContainer.new()
	_totals.columns = 2
	_totals.add_theme_constant_override("h_separation", 8)
	_totals.add_theme_constant_override("v_separation", 1)
	put(l, _totals, Vector2(0, 164), Vector2(200, 48))
	# right page: inventory grid + card
	put(r, MenuBook.section(tr("UI_BK_INVENTORY")), Vector2.ZERO)
	_count = MenuBook.num("", MenuBook.INK_DIM)
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	put(r, _count, Vector2(150, -1), Vector2(50, 12))
	_grid_scroll = ScrollContainer.new()
	_grid_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_grid_scroll.follow_focus = true
	put(r, _grid_scroll, Vector2(0, 20), Vector2(200, 86))
	_grid = GridContainer.new()
	_grid.columns = COLS
	_grid.add_theme_constant_override("h_separation", 2)
	_grid.add_theme_constant_override("v_separation", 2)
	_grid_scroll.add_child(_grid)
	_empty = MenuBook.italic(tr("UI_BK_NO_ITEMS"), MenuBook.INK_FADE, false)
	put(r, _empty, Vector2(0, 24), Vector2(200, 12))
	# item card
	put(r, MenuBook.nine("book_card", Rect2(0, 112, 200, 100), 4), Vector2(0, 112))
	put(r, MenuBook.nine("slot", Rect2(0, 0, 20, 20), 4), Vector2(6, 118))
	_card_icon = TextureRect.new()
	_card_icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	_card_icon.mouse_filter = MOUSE_FILTER_IGNORE
	put(r, _card_icon, Vector2(8, 120), Vector2(16, 16))
	_card_name = MenuBook.head("")
	_card_name.clip_text = true
	put(r, _card_name, Vector2(30, 115), Vector2(164, 14))
	_card_type = MenuBook.italic("", MenuBook.INK_DIM, false)
	put(r, _card_type, Vector2(30, 128), Vector2(110, 10))
	_card_tag = MenuBook.bold("", MenuBook.VERD)
	_card_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	put(r, _card_tag, Vector2(130, 128), Vector2(64, 10))
	_card_stats = VBoxContainer.new()
	_card_stats.add_theme_constant_override("separation", 0)
	put(r, _card_stats, Vector2(6, 142), Vector2(188, 10))
	_card_desc = MenuBook.text("", MenuBook.INK_DIM, true)
	_card_desc.clip_text = true
	put(r, _card_desc, Vector2(6, 162), Vector2(188, 46))


func _icon(item: ItemData) -> Texture2D:
	if item == null:
		return null
	var t: Variant = item.get("icon")
	if t is Texture2D:
		return t
	var path := ITEM_DIR + item.id + ".png"
	return load(path) if ResourceLoader.exists(path) else null


func refresh() -> void:
	var g := game
	var had_focus := get_viewport() != null and get_viewport().gui_get_focus_owner() != null \
			and is_ancestor_of(get_viewport().gui_get_focus_owner())
	for s in SLOTS:
		var it: ItemData = g.equipped_item(s)
		_doll_icon[s].texture = _icon(it)
		_doll_name[s].text = tr(it.title) if it else tr("UI_BK_EMPTY_SLOT")
	_refresh_totals(g)
	clear(_grid)
	var items: Array[ItemData] = []
	for s in SLOTS:
		for id in g.inventory:
			var it := ItemData.by_id(id)
			if it and it.slot == s:
				items.append(it)
	_count.text = str(items.size())
	_empty.visible = items.is_empty()
	var focus_btn: Button = null
	for it in items:
		var b := _slot_button(g, it)
		_grid.add_child(b)
		if it.id == focus_id:
			focus_btn = b
	if focus_btn == null and focus_id != "":
		focus_id = ""
	_show_card(ItemData.by_id(focus_id) if focus_id != "" else null)
	if focus_btn and had_focus:
		focus_btn.grab_focus.call_deferred()


func _slot_button(g: Node, item: ItemData) -> Button:
	var b := Button.new()
	b.theme_type_variation = &"SlotButton"
	b.custom_minimum_size = Vector2(20, 20)
	b.focus_mode = FOCUS_ALL
	b.set_meta("id", item.id)
	var tex := _icon(item)
	if tex:
		b.icon = tex
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	else:
		b.text = tr(item.title).left(2)
	if g.equipped.get(item.slot, "") == item.id:
		put(b, MenuBook.pic("book_equipped", Vector2.ZERO), Vector2(13, 0))
	b.pressed.connect(g.equip.bind(item.id))
	b.focus_entered.connect(func() -> void:
		focus_id = item.id
		_show_card(item)
		menu.update_hints())
	b.mouse_entered.connect(func() -> void: b.grab_focus())
	return b


## A doll slot jumps into the grid: the equipped item of that slot, else the first item of that kind.
func _jump_to_slot(slot: String) -> void:
	var target: Button = null
	for b in _grid.get_children():
		var it := ItemData.by_id(b.get_meta("id", ""))
		if it and it.slot == slot and (target == null or game.equipped.get(slot, "") == it.id):
			target = b
	if target:
		target.grab_focus()


func _refresh_totals(g: Node) -> void:
	clear(_totals)
	var sum := {}
	for s in SLOTS:
		var st := _item_stats(g.equipped_item(s))
		for k in st:
			sum[k] = sum.get(k, 0.0) + st[k]
	if sum.is_empty():
		_totals.add_child(MenuBook.italic(tr("UI_BK_EMPTY_SLOT"), MenuBook.INK_FADE, false))
		return
	for k in sum:
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(96, 12)
		row.add_theme_constant_override("separation", 0)
		var n := MenuBook.text(_stat_name(k))
		n.size_flags_horizontal = SIZE_EXPAND_FILL
		row.add_child(n)
		var v := MenuBook.num(_fmt(sum[k], k))
		row.add_child(v)
		_totals.add_child(row)


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
	return tr(STAT_KEYS[k]) if STAT_KEYS.has(k) else k.capitalize()


## Flat numbers as-is; fractions (move_speed, stamina_regen) as percent.
func _fmt(v: float, k := "") -> String:
	if k in ["move_speed", "stamina_regen"] or (absf(v) < 1.0 and not is_zero_approx(v)):
		return "%+d%%" % roundi(v * 100.0)
	var s := str(roundi(v))
	return ("+" + s) if k not in ["damage", "defense"] and v > 0 else s


## The card always shows something: the given item, else the equipped weapon, else any equipped item.
func _show_card(item: ItemData) -> void:
	if item == null:
		for s in SLOTS:
			item = game.equipped_item(s)
			if item:
				break
	_card_item = item
	clear(_card_stats)
	if item == null:
		_card_icon.texture = null
		_card_name.text = tr("UI_BK_NO_ITEMS")
		_card_type.text = ""
		_card_tag.text = ""
		_card_desc.text = ""
		return
	_card_icon.texture = _icon(item)
	_card_name.text = tr(item.title)
	_card_name.add_theme_color_override("font_color", MenuBook.INK_HEAD if item.mythic else MenuBook.INK)
	_card_type.text = tr("UI_SLOT_" + item.slot.to_upper()) + (" · " + tr("UI_BK_PUSAKA") if item.mythic else "")
	var cur: ItemData = game.equipped_item(item.slot)
	var same := cur == item
	_card_tag.text = tr("UI_BK_WORN") if same else ""
	var mine := _item_stats(item)
	var theirs := _item_stats(cur) if cur and not same else {}
	var keys := mine.keys()
	for k in theirs:
		if k not in keys:
			keys.append(k)
	for k in keys:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 3)
		var n := MenuBook.text(_stat_name(k))
		n.custom_minimum_size.x = 84
		row.add_child(n)
		row.add_child(MenuBook.num(_fmt(mine.get(k, 0.0), k)))
		if not same and cur:
			var d: float = mine.get(k, 0.0) - theirs.get(k, 0.0)
			if absf(d) > 0.001:
				var arrow := MenuBook.pic("book_up" if d > 0 else "book_down", Vector2.ZERO)
				arrow.size_flags_vertical = SIZE_SHRINK_CENTER
				row.add_child(arrow)
				var dl := MenuBook.num(_fmt(absf(d), k).trim_prefix("+"), MenuBook.VERD if d > 0 else MenuBook.WAX)
				row.add_child(dl)
		_card_stats.add_child(row)
	var desc := tr(item.description)
	if item.mythic and item.lore != "":
		desc += " " + tr(item.lore)
	_card_desc.text = desc
	_card_desc.position.y = 142 + 10 * keys.size() + 4


func focus_first() -> void:
	var target: Button = null
	for b in _grid.get_children():
		if target == null or b.get_meta("id", "") == focus_id:
			target = b
	if target:
		target.grab_focus()
	else:
		_doll_btn.weapon.grab_focus()


func hints() -> Array:
	var f := get_viewport().gui_get_focus_owner() if get_viewport() else null
	if f and f.get_parent() == _grid:
		if _card_item and game.equipped.get(_card_item.slot, "") == _card_item.id:
			return [["@updown", "UI_BK_HINT_SELECT"]]
		return [["@updown", "UI_BK_HINT_SELECT"], ["Enter", "UI_BK_HINT_EQUIP"]]
	return [["@updown", "UI_BK_HINT_SELECT"], ["Enter", "UI_BK_HINT_CHOOSE"]]
