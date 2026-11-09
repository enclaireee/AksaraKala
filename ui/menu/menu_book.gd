class_name MenuBook extends Control
## The field-book frame shared by every menu tab (ui.md 4.3, v3 dusk): the world dims to night, a dusk cover with a cyan
## hairline, two indigo star-chart pages, a spine of cyan dots, corner glints, tab pills with Q / E keycaps and the
## footer hint band. Art: tools/gen_ui_dusk.py (assets/art/ui/book_*.png). Also holds the style helpers the tabs share.

signal ribbon_pressed(index: int)

# 480x270 layout on the 8 px grid (whole pixels only)
const BOOK := Rect2(8, 16, 464, 248)
const PAGES := Rect2(12, 20, 456, 228)     # both pages; the TabContainer of spreads sits here
const FOOTER := Rect2(12, 248, 456, 12)
const SPINE_X := 240
const RIB_Y := 4                            # top of a closed ribbon (its foot hides under the cover)
const RIB_ON_Y := 0
const RIB_W := 20

# palette (ui.md 0.1, 5). v2 names kept so every tab recolours with them: INK = body text, INK_HEAD = headings,
# INK_DIM = secondary, WAX = danger / destructive, VERD = done or better.
const INK := Color("ECE6F2")
const INK_HEAD := Color("FFF4E6")
const INK_DIM := Color("A99BC8")
const INK_FADE := Color("8C83A6")
const PAPER := Color("1A1530")
const PAPER_HI := Color("241C40")
const CREAM := Color("ECE6F2")
const WAX := Color("E0566A")
const VERD := Color("8FD9A0")
const ACCENT := Color("7FE8E0")
const KEY_INK := Color("141026")   # letters on the light keycap

const FONT_NUM := "res://assets/fonts/Tiny5-Regular.woff"      # ui.md 1: body face, 8 / 16 only
const FONT_ITALIC := "res://assets/fonts/Tiny5-Regular.woff"

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
	shadow.color = Color(0.02, 0.01, 0.05, 0.6)
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
		b.add_theme_font_override("font", UIFx.caps_font())
		b.add_theme_font_size_override("font_size", UIFx.BODY)
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
	# front: footer band, corner glints, Q / E keycaps
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
	# no paper pattern under the text: plain parchment reads calmer (ui.md 0, v2)
	return p


## Lays the ribbons out for the open tab: closed ones are icon-only leather, the open one is taller, paper and named.
func select(index: int) -> void:
	var widths: Array[int] = []
	var total := 0
	for i in _ribbons.size():
		var b := _ribbons[i]
		var on := i == index
		b.text = tr(b.get_meta("title")).to_upper() if on else ""   # tracked caps label (Button has no uppercase flag)
		b.tooltip_text = "" if on else tr(b.get_meta("title"))
		var w := RIB_W
		if on:
			w = 4 * int(ceil((UIFx.caps_font().get_string_size(b.text.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x + 30) / 4.0))
		widths.append(w)
		total += w
		var st := _ribbon_box("book_ribbon_on" if on else "book_ribbon_off", on)
		var hv := st if on else _ribbon_box("book_ribbon_hover", false)
		for s in ["normal", "pressed", "focus", "disabled"]:
			b.add_theme_stylebox_override(s, st)
		for s in ["hover", "hover_pressed"]:
			b.add_theme_stylebox_override(s, hv)
		var col := ACCENT if on else INK_DIM
		for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
			b.add_theme_color_override(c, col)
		for c in ["icon_normal_color", "icon_pressed_color", "icon_focus_color"]:
			b.add_theme_color_override(c, ACCENT if on else INK_FADE)
		for c in ["icon_hover_color", "icon_hover_pressed_color"]:
			b.add_theme_color_override(c, ACCENT if on else INK)
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


## Footer hints: [[key text or "@icon", label key], ...]. Keys draw as keycaps, labels in lavender on the band.
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
		var l := text(tr(hints[i][1]), INK_DIM)
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


## Body text (Tiny5 8), cool cream on the night page.
static func text(t: String, color := INK, wrap := false) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_override("font", UIFx.body_font())
	l.add_theme_font_size_override("font_size", UIFx.BODY)
	l.add_theme_color_override("font_color", color)
	l.add_theme_constant_override("outline_size", 0)
	l.add_theme_constant_override("line_spacing", 1)
	l.mouse_filter = MOUSE_FILTER_IGNORE
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = SIZE_EXPAND_FILL
	return l


static func italic(t: String, color := INK_DIM, wrap := true) -> Label:
	return text(t, color, wrap)   # the pixel face has no italic: secondary text is the lavender colour


## Small tracked caps (Tiny5 8 +1): labels, section names, menu entries.
static func bold(t: String, color := INK) -> Label:
	var l := text(t, color)
	l.add_theme_font_override("font", UIFx.caps_font())
	l.uppercase = true
	return l


## Heading (page and section titles): Jersey 10 at 19, the one heading size (ui.md 1).
## `size` is kept for old callers and ignored.
static func head(t: String, _size := 12, color := INK_HEAD) -> Label:
	var l := text(t, color)
	l.add_theme_font_override("font", UIFx.head_font())
	l.add_theme_font_size_override("font_size", UIFx.HEAD)
	return l


## Numbers: Tiny5 at 8, or 16 for a big figure (size >= 16).
static func num(t: String, color := INK, size := 8) -> Label:
	var l := text(t, color)
	l.add_theme_font_size_override("font_size", 16 if size >= 16 else UIFx.BODY)
	return l


## A heading with a hairline rule under it (cyan lead-in), as one 200 px wide block (16 px tall).
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
		var f := UIFx.body_font()
		var w := f.get_string_size(k, HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x
		var l := Label.new()
		l.text = k
		l.add_theme_font_override("font", f)
		l.add_theme_font_size_override("font_size", UIFx.BODY)
		l.add_theme_color_override("font_color", KEY_INK)
		l.add_theme_constant_override("outline_size", 0)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		n.size = Vector2(maxi(10, int(ceil(w)) + 5), 10)
		l.position = Vector2(0, 0)
		l.size = n.size
		n.add_child(l)
	n.custom_minimum_size = n.size
	n.size_flags_vertical = SIZE_SHRINK_CENTER
	return n


## A flat list row: no frame, a faint cyan wash with a cyan edge when focused or hovered, `sel` keeps a pale highlight.
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


## A small dusk button with a hairline rim (cyan rim when focused), tracked caps.
static func small_button(t: String) -> Button:
	var b := Button.new()
	b.text = String(TranslationServer.translate(t)).to_upper()   # tracked caps; already-translated text passes through
	b.focus_mode = FOCUS_ALL
	b.add_theme_font_override("font", UIFx.caps_font())
	b.add_theme_font_size_override("font_size", UIFx.BODY)
	b.add_theme_constant_override("outline_size", 0)
	for c in ["font_color", "font_pressed_color"]:
		b.add_theme_color_override(c, INK)
	for c in ["font_hover_color", "font_focus_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(c, ACCENT)
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
