class_name UIFx extends RefCounted
## Small shared helpers for the front-end screens (ui.md 3b): palette, fonts, frames, motes, fades.

## v3 "Senja" dusk palette (ui.md 0.1, 5). The v1/v2 names stay as aliases so every caller recolours with them:
## GOLD_HI = headings, CREAM = body, GOLD = caps labels, DIM = secondary; the old paper names (INK, INK_HEAD, INK_DIM)
## now mean the same light-on-night colours, because the paper book is gone.
const NIGHT := Color("141026")      # surface fill
const NIGHT_HI := Color("241C40")   # raised surface
const HEAD := Color("FFF4E6")       # headings
const TEXT := Color("ECE6F2")       # body, cool cream
const WARM := Color("F2B27A")       # amber: quests, loot, Ilmu, secondary emphasis
const WARM_LO := Color("C98A52")
const HALO := Color("3FB8C0")       # the cyan glow's outer ring
const GOLD := Color("A99BC8")       # old name: caps labels / rules (now lavender)
const GOLD_HI := HEAD
const GOLD_LO := Color("5A4E80")
const CREAM := TEXT
const DIM := Color("8C83A6")
const LACQUER := Color("0A0814")    # outline under text and surfaces
const SOGAN := NIGHT_HI
const VERMILLION := Color("E0566A")
const INK := TEXT
const INK_HEAD := HEAD
const INK_DIM := DIM
const PAPER := Color("1A1530")
const ART := "res://assets/art/ui/"


static var _cache := {}   # keeps textures alive: draw_texture does not hold a reference


static func tex(name: String) -> Texture2D:
	if not _cache.has(name):
		_cache[name] = load(ART + name + ".png")
	return _cache[name]


# ---------------------------------------------------------------------------------------------------------------
# Design system v2 (ui.md 0-1). Every screen takes its type, colour and spacing from here.
# Pixel fonts render crisp ONLY at their grid sizes; never pass any other size:
#   BODY    Tiny5 8    cap 5, line 10   all body text, numbers, hints, dialogue, lists
#   LABEL   Tiny5 8    CAPS + 1 px tracking, dim gold: small section labels and kickers
#   HEAD    Jersey10 19 cap 10, line 13  screen / page / card headings, names, boss name
#   DISPLAY Jersey15 27 cap 15, line 20  area titles, quest titles, "Fallen"; LOGO = 54
# ---------------------------------------------------------------------------------------------------------------
const FONT_BODY := "res://assets/fonts/Tiny5-Regular.woff"
const FONT_HEAD := "res://assets/fonts/Jersey10-Regular.ttf"
const FONT_DISPLAY := "res://assets/fonts/Jersey15-Regular.ttf"
const BODY := 8
const HEAD := 19
const DISPLAY := 27
const LOGO := 54
const LINE := 10        # body line pitch (9 px glyph box + 1 spacing)

# spacing: one 4 px grid. Screen-safe margin 8, panel padding 6, gaps 2 / 4 / 8 / 16.
const MARGIN := 8
const PAD := 6
const GAP_XS := 2
const GAP_S := 4
const GAP := 8
const GAP_L := 16

# the dusk surface (HUD cards, dialogue, prompts, banners, menus): one look everywhere
const INK_BG := NIGHT               # panel fill (drawn at ~90% in the art)
const LINE_DIM := Color("3A2F5C")    # hairlines on dusk
const ACCENT := Color("7FE8E0")      # cyan glyph glow: focus, selection, magic, new
const LABEL_COL := Color("A99BC8")   # caps labels on dusk (lavender)
const DANGER := Color("E0566A")      # rose: damage, low HP, destructive only
const OK := Color("8FD9A0")          # done / gained

static var _fonts := {}


static func _font(path: String, top := 0, bottom := 0, track := 0) -> Font:
	var k := "%s|%d|%d|%d" % [path, top, bottom, track]
	if not _fonts.has(k):
		var v := FontVariation.new()
		v.base_font = load(path)
		v.spacing_top = top
		v.spacing_bottom = bottom
		v.spacing_glyph = track
		_fonts[k] = v
	return _fonts[k]


## Tiny5: the body face for everything small.
static func body_font() -> Font:
	return _font(FONT_BODY)


## Tiny5 with 1 px tracking for CAPS labels.
static func caps_font() -> Font:
	return _font(FONT_BODY, 0, 0, 1)


## Jersey 10 at 19 (its 10 px cap grid), trimmed so the line box hugs the caps.
static func head_font() -> Font:
	return _font(FONT_HEAD, -4, -3)


## Old name kept for callers: the heading face.
static func cinzel() -> Font:
	return head_font()


## Jersey 15 at 27 / 54 for big titles.
static func display() -> Font:
	return _font(FONT_DISPLAY, -5, -2)


## Maps any old size to the nearest pixel-true step of the scale.
static func snap(size: int, display_face: bool = false) -> int:
	if display_face:
		return LOGO if size >= 40 else (DISPLAY if size >= 20 else HEAD)
	return 16 if size >= 16 else BODY


## A Label on the scale. kind: "body", "label" (caps, tracked), "head", "display", "logo".
static func text(t: String, kind := "body", color := CREAM, paper := false) -> Label:
	var l := Label.new()
	l.text = t
	l.uppercase = kind == "label"
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", LACQUER)
	l.add_theme_constant_override("outline_size", 0 if paper else 1)
	match kind:
		"label":
			l.add_theme_font_override("font", caps_font())
			l.add_theme_font_size_override("font_size", BODY)
		"head":
			l.add_theme_font_override("font", head_font())
			l.add_theme_font_size_override("font_size", HEAD)
		"display":
			l.add_theme_font_override("font", display())
			l.add_theme_font_size_override("font_size", DISPLAY)
		"logo":
			l.add_theme_font_override("font", display())
			l.add_theme_font_size_override("font_size", LOGO)
		_:
			l.add_theme_font_override("font", body_font())
			l.add_theme_font_size_override("font_size", BODY)
	return l


## Old helper, now on the scale. With `use_cinzel` (a "title" face): >= 40 logo, >= 20 display, >= 13 heading,
## smaller sizes become tracked caps labels. Without it everything is body text.
static func label(t: String, size := 8, color := CREAM, use_cinzel := false, paper := false) -> Label:
	if use_cinzel:
		var kind := "label"
		if size >= 40:
			kind = "logo"
		elif size >= 20:
			kind = "display"
		elif size >= 13:
			kind = "head"
		return text(t, kind, color, paper)
	return text(t, "body", color, paper)


## Ink panel stylebox (ink_panel.png, 4 px margins) for anything drawn over the world.
static func ink_box(pad := PAD) -> StyleBoxTexture:
	var s := StyleBoxTexture.new()
	s.texture = tex("ink_panel")
	for side in 4:
		s.set_texture_margin(side as Side, 4.0)
		s.set_content_margin(side as Side, float(pad))
	return s


## panel.png (6 px margins) or button_*.png (5 px) as a stylebox.
static func box(name := "panel", margin := 6.0) -> StyleBoxTexture:
	var s := StyleBoxTexture.new()
	s.texture = tex(name)
	for side in 4:
		s.set_texture_margin(side as Side, margin)
		s.set_content_margin(side as Side, margin)
	return s


static func frame(pos: Vector2, size: Vector2, name := "panel") -> Panel:
	var p := Panel.new()
	p.add_theme_stylebox_override("panel", box(name))
	p.position = pos
	p.size = size
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return p


static func rect_tex(name: String, pos: Vector2, size := Vector2.ZERO) -> TextureRect:
	var t := TextureRect.new()
	t.texture = tex(name)
	t.position = pos
	t.size = size if size != Vector2.ZERO else t.texture.get_size()
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


## Fade + rise on open.
static func rise_in(n: CanvasItem, dist := 6.0, time := 0.2) -> void:
	var y: float = n.position.y
	n.modulate.a = 0.0
	n.position.y = y + dist
	var tw := n.create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(n, "modulate:a", 1.0, time)
	tw.tween_property(n, "position:y", y, time)


## A one-shot burst of rising cyan motes over a rectangle.
static func burst(parent: Node, rect: Rect2, amount := 28, life := 0.5) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.texture = tex("ink_mote")
	p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p.position = rect.get_center()
	p.amount = amount
	p.lifetime = life
	p.one_shot = true
	p.explosiveness = 0.9
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = rect.size / 2.0
	p.direction = Vector2.UP
	p.spread = 25.0
	p.gravity = Vector2(0, -30)
	p.initial_velocity_min = 20.0
	p.initial_velocity_max = 55.0
	p.color = Color(1, 1, 1, 0.9)
	p.emitting = true
	parent.add_child(p)
	p.finished.connect(p.queue_free)
	return p


## The full-screen dusk backdrop (ui.md 0.1): banded sky, twinkling stars and slow cyan motes. `dim` darkens it
## for screens where text sits on top. Returns the root so callers can add to or fade it.
static func sky(parent: Node, dim := 1.0, motes := true) -> Control:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(root)
	var bg := rect_tex("title_sky", Vector2.ZERO)
	bg.modulate = Color(dim, dim, dim)
	root.add_child(bg)
	root.add_child(Twinkle.new())
	if motes:
		root.add_child(motes_layer(Rect2(0, 200, 480, 70), 14))
	return root


## Slow cyan motes drifting up out of `area` (title grass, menu backdrop).
static func motes_layer(area: Rect2, amount := 16) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.texture = tex("ink_mote")
	p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p.position = area.get_center()
	p.amount = amount
	p.lifetime = 7.0
	p.preprocess = 7.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = area.size / 2.0
	p.direction = Vector2.UP
	p.spread = 18.0
	p.gravity = Vector2(2, -2)
	p.initial_velocity_min = 5.0
	p.initial_velocity_max = 12.0
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.0
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1, 1, 1, 0.0))
	ramp.set_color(1, Color(1, 1, 1, 0.0))
	ramp.add_point(0.25, Color(1, 1, 1, 0.85))
	ramp.add_point(0.7, Color(1, 1, 1, 0.4))
	p.color_ramp = ramp
	return p


## Fade-to-black cover; returns the rect so the caller can tween it.
static func cover(parent: Control) -> ColorRect:
	var c := ColorRect.new()
	c.color = Color(0, 0, 0, 0)
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.z_index = 100
	parent.add_child(c)
	return c
