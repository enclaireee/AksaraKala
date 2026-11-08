class_name MenuBook extends Control
## The field-book frame shared by every menu tab (ui.md 4.3): dim + vignette, the leather cover, two parchment pages
## with a faint kawung tile, the spine gutter, carved corners, tab ribbons with Q / E keycaps and the footer hint band.
## Art: tools/gen_menu_book.py (assets/art/ui/book_*.png). Also holds the small style helpers the tabs share.

signal ribbon_pressed(index: int)

# 480x270 layout on the 8 px grid (whole pixels only)
const BOOK := Rect2(8, 16, 464, 248)
const PAGES := Rect2(12, 20, 456, 228)     # both pages; the TabContainer of spreads sits here
const FOOTER := Rect2(12, 248, 456, 12)
const SPINE_X := 240
const RIB_Y := 4                            # top of a closed ribbon (its foot hides under the cover)
const RIB_ON_Y := 0
const RIB_W := 20

# palette (ui.md 5)
const INK := Color("2A1C12")
const INK_HEAD := Color("7A2A1E")
const INK_DIM := Color("6B5A44")
const INK_FADE := Color("8A7656")
const PAPER := Color("E3D0A0")
const PAPER_HI := Color("F1E4BE")
const CREAM := Color("EADFC4")
const WAX := Color("9E2B25")
const VERD := Color("3F7A66")

const FONT_NUM := "res://assets/fonts/Jersey10-Regular.ttf"
const FONT_ITALIC := "res://assets/fonts/Jersey10-Regular.ttf"

var content: Control           # the menu adds its TabContainer here (between the pages and the front ornaments)
var footer_box: HBoxContainer
var _ribbons: Array[Button] = []
var _rib_layer: Control
var _keys: Array[Control] = []


func _init() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE


## Builds the frame for these tabs: titles are translation keys, icons are book_tab_* names.
func build(titles: Array, icons: Array) -> void:
	var shadow := ColorRect.new()   # soft drop shadow under the book
	shadow.color = Color(0.03, 0.02, 0.01, 0.5)
	shadow.position = BOOK.position + Vector2(2, 3)
	shadow.size = BOOK.size
	shadow.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(shadow)
	_rib_layer = Control.new()   # ribbons stick up from behind the cover
	_rib_layer.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_rib_layer)
	for i in titles.size():
		var b := Button.new()
		b.focus_mode = FOCUS_NONE
		b.icon = tex("book_tab_" + icons[i])
		b.expand_icon = false
		b.clip_text = true
		b.add_theme_font_override("font", UIFx.cinzel())
		b.add_theme_font_size_override("font_size", 10)
		b.add_theme_constant_override("h_separation", 4)
		b.add_theme_constant_override("outline_size", 0)
		b.set_meta("title", titles[i])
		b.pressed.connect(func() -> void: ribbon_pressed.emit(i))
		_rib_layer.add_child(b)
		_ribbons.append(b)
	add_child(nine("book_cover", BOOK, 8))
	add_child(_page("book_page_l", Rect2(PAGES.position, Vector2(PAGES.size.x / 2, PAGES.size.y))))
	add_child(_page("book_page_r", Rect2(PAGES.position + Vector2(PAGES.size.x / 2, 0), Vector2(PAGES.size.x / 2, PAGES.size.y))))
	var spine := pic("book_spine", Vector2(SPINE_X - 16, PAGES.position.y))
	spine.size = Vector2(32, PAGES.size.y)
	add_child(spine)
	content = Control.new()
	content.mouse_filter = MOUSE_FILTER_IGNORE
	content.set_anchors_preset(PRESET_FULL_RECT)
	add_child(content)
	# front: footer band, carved corners, Q / E keycaps
	add_child(nine("book_footer", FOOTER, 4, true))
	footer_box = HBoxContainer.new()
	footer_box.position = FOOTER.position + Vector2(0, 1)
	footer_box.size = Vector2(FOOTER.size.x, 10)
	footer_box.alignment = BoxContainer.ALIGNMENT_CENTER
	footer_box.add_theme_constant_override("separation", 3)
	footer_box.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(footer_box)
	for c in 4:
		var t := pic("book_corner", Vector2.ZERO)
		t.flip_h = c % 2 == 1
		t.flip_v = c >= 2
		t.position = Vector2(BOOK.position.x + (BOOK.size.x - 14 if t.flip_h else 0), BOOK.position.y + (BOOK.size.y - 14 if t.flip_v else 0))
		add_child(t)
	for k in ["Q", "E"]:
		var kc := keycap(k)
		_rib_layer.add_child(kc)
		_keys.append(kc)


func _page(name_: String, r: Rect2) -> Control:
	var p := nine(name_, r, 8)
	p.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
	p.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE
	var k := TextureRect.new()   # the faint kawung paper tile
	k.texture = tex("book_kawung")
	k.stretch_mode = TextureRect.STRETCH_TILE
	k.position = Vector2(6, 4)
	k.size = r.size - Vector2(10, 8)
	k.mouse_filter = MOUSE_FILTER_IGNORE
	p.add_child(k)
	return p


## Lays the ribbons out for the open tab: closed ones are icon-only leather, the open one is taller, paper and named.
func select(index: int) -> void:
	var widths: Array[int] = []
	var total := 0
	for i in _ribbons.size():
		var b := _ribbons[i]
		var on := i == index
		b.text = tr(b.get_meta("title")) if on else ""
		b.tooltip_text = "" if on else tr(b.get_meta("title"))
		var w := RIB_W
		if on:
			w = 4 * int(ceil((UIFx.cinzel().get_string_size(b.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x + 30) / 4.0))
		widths.append(w)
		total += w
		var st := _ribbon_box("book_ribbon_on" if on else "book_ribbon_off", on)
		var hv := st if on else _ribbon_box("book_ribbon_hover", false)
		for s in ["normal", "pressed", "focus", "disabled"]:
			b.add_theme_stylebox_override(s, st)
		for s in ["hover", "hover_pressed"]:
			b.add_theme_stylebox_override(s, hv)
		var col := INK_HEAD if on else CREAM
		for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
			b.add_theme_color_override(c, col)
		for c in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_focus_color", "icon_hover_pressed_color"]:
			b.add_theme_color_override(c, INK if on else Color(CREAM, 0.85))
	var gap := 2
	total += gap * (_ribbons.size() - 1)
	var x := SPINE_X - total / 2
	for i in _ribbons.size():
		var on := i == index
		_ribbons[i].position = Vector2(x, RIB_ON_Y if on else RIB_Y)
		_ribbons[i].size = Vector2(widths[i], 22 if on else 16)
		x += widths[i] + gap
	_keys[0].position = Vector2(SPINE_X - total / 2 - 6 - _keys[0].size.x, 5)
	_keys[1].position = Vector2(x - gap + 6, 5)


func _ribbon_box(name_: String, on: bool) -> StyleBoxTexture:
	var s := StyleBoxTexture.new()
	s.texture = tex(name_)
	s.texture_margin_left = 5
	s.texture_margin_right = 5
	s.texture_margin_top = 5
	s.texture_margin_bottom = 3
	s.content_margin_left = 5
	s.content_margin_right = 5
	s.content_margin_top = 5 if on else 2
	s.content_margin_bottom = 4 if on else 4
	return s


## Footer hints: [[key text or "@icon", label key], ...]. Keys draw as keycaps, labels in cream on the leather.
func set_hints(hints: Array) -> void:
	for c in footer_box.get_children():
		footer_box.remove_child(c)
		c.queue_free()
	for i in hints.size():
		if i > 0:
			var sp := Control.new()
			sp.custom_minimum_size.x = 7
			footer_box.add_child(sp)
		for k in str(hints[i][0]).split(" "):
			footer_box.add_child(keycap(k))
		var l := text(tr(hints[i][1]), CREAM)
		footer_box.add_child(l)


# ---------------------------------------------------------------- shared style helpers

static func tex(name_: String) -> Texture2D:
	return UIFx.tex(name_)


static func pic(name_: String, pos: Vector2) -> TextureRect:
	var t := TextureRect.new()
	t.texture = tex(name_)
	t.position = pos
	t.size = t.texture.get_size()
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.mouse_filter = MOUSE_FILTER_IGNORE
	return t


static func nine(name_: String, r: Rect2, m: int, tile := false) -> NinePatchRect:
	var n := NinePatchRect.new()
	n.texture = tex(name_)
	n.position = r.position
	n.size = r.size
	n.patch_margin_left = m
	n.patch_margin_right = m
	n.patch_margin_top = mini(m, int(n.texture.get_height() / 2.0) - 1) if tile else m
	n.patch_margin_bottom = n.patch_margin_top
	if tile:
		n.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
	n.mouse_filter = MOUSE_FILTER_IGNORE
	return n


static func box(name_: String, m: int, content := -1) -> StyleBoxTexture:
	var s := StyleBoxTexture.new()
	s.texture = tex(name_)
	for side in 4:
		s.set_texture_margin(side as Side, m)
		s.set_content_margin(side as Side, m if content < 0 else content)
	return s


## Body text (Crimson Pro 8), plain ink on paper.
static func text(t: String, color := INK, wrap := false) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_color_override("font_color", color)
	l.add_theme_constant_override("outline_size", 0)
	l.add_theme_constant_override("line_spacing", 0)
	l.mouse_filter = MOUSE_FILTER_IGNORE
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = SIZE_EXPAND_FILL
	return l


static func italic(t: String, color := INK_DIM, wrap := true) -> Label:
	var l := text(t, color, wrap)
	l.add_theme_font_override("font", load(FONT_ITALIC))
	return l


## Crimson Pro bold 8: labels, section names, menu entries.
static func bold(t: String, color := INK) -> Label:
	var l := text(t, color)
	l.add_theme_font_override("font", UIFx.cinzel())
	return l


## Almendra heading in ink red (page and section titles).
static func head(t: String, size := 12, color := INK_HEAD) -> Label:
	var l := text(t, color)
	l.add_theme_font_override("font", UIFx.display())
	l.add_theme_font_size_override("font_size", size)
	return l


## Jersey 10 for numbers (crisp pixel digits).
static func num(t: String, color := INK, size := 10) -> Label:
	var l := text(t, color)
	l.add_theme_font_override("font", load(FONT_NUM))
	l.add_theme_font_size_override("font_size", size)
	return l


## A heading with an ink rule under it, as one 200 px wide block (16 px tall).
static func section(t: String, width := 200) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(width, 16)
	c.mouse_filter = MOUSE_FILTER_IGNORE
	var h := head(t)
	h.position = Vector2(0, -1)
	c.add_child(h)
	var r := nine("book_rule", Rect2(0, 14, width, 3), 8)
	r.patch_margin_top = 0
	r.patch_margin_bottom = 0
	c.add_child(r)
	return c


## A keycap (keycap.png, 9-patch 3) with a key name, or "@name" for an icon (book_ic_<name>).
static func keycap(k: String) -> Control:
	var n := nine("keycap", Rect2(0, 0, 10, 10), 3)
	if k.begins_with("@"):
		var ic := pic("book_ic_" + k.substr(1), Vector2(1, 0))
		n.add_child(ic)
		n.size = Vector2(12, 10)
	else:
		var f := UIFx.cinzel()
		var w := f.get_string_size(k, HORIZONTAL_ALIGNMENT_LEFT, -1, 7).x
		var l := Label.new()
		l.text = k
		l.add_theme_font_override("font", f)
		l.add_theme_font_size_override("font_size", 10)
		l.add_theme_color_override("font_color", INK)
		l.add_theme_constant_override("outline_size", 0)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		n.size = Vector2(maxi(10, int(ceil(w)) + 6), 10)
		l.position = Vector2(0, -1)
		l.size = n.size
		n.add_child(l)
	n.custom_minimum_size = n.size
	n.size_flags_vertical = SIZE_SHRINK_CENTER
	return n


## A flat list row: no frame, a faint wax wash when focused or hovered, `sel` keeps a pale highlight.
static func row_button(height := 16) -> Button:
	var b := Button.new()
	b.custom_minimum_size.y = height
	b.focus_mode = FOCUS_ALL
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.clip_text = true
	var empty := StyleBoxEmpty.new()
	var hi := box("book_row", 4, 0)
	for s in ["normal", "disabled", "pressed"]:
		b.add_theme_stylebox_override(s, empty)
	for s in ["hover", "focus", "hover_pressed"]:
		b.add_theme_stylebox_override(s, hi)
	b.add_theme_constant_override("outline_size", 0)
	b.mouse_entered.connect(func() -> void:
		if b.focus_mode != FOCUS_NONE and b.is_visible_in_tree():
			b.grab_focus())
	return b


static func set_row_selected(b: Button, on: bool) -> void:
	b.add_theme_stylebox_override("normal", box("book_row_sel", 4, 0) if on else StyleBoxEmpty.new())


## A small paper button with an ink rim (wax rim when focused), Crimson bold 8 ink text.
static func small_button(t: String) -> Button:
	var b := Button.new()
	b.text = t
	b.focus_mode = FOCUS_ALL
	b.add_theme_font_override("font", UIFx.cinzel())
	b.add_theme_font_size_override("font_size", 10)
	b.add_theme_constant_override("outline_size", 0)
	for c in ["font_color", "font_pressed_color"]:
		b.add_theme_color_override(c, INK)
	for c in ["font_hover_color", "font_focus_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(c, INK_HEAD)
	var n := box("book_btn", 3)
	var h := box("book_btn_hi", 3)
	for s: StyleBoxTexture in [n, h]:
		s.content_margin_left = 6
		s.content_margin_right = 6
		s.content_margin_top = 0
		s.content_margin_bottom = 1
	for s in ["normal", "disabled"]:
		b.add_theme_stylebox_override(s, n)
	for s in ["hover", "focus", "pressed", "hover_pressed"]:
		b.add_theme_stylebox_override(s, h)
	b.custom_minimum_size.y = 12
	b.mouse_entered.connect(func() -> void:
		if b.is_visible_in_tree():
			b.grab_focus())
	return b
