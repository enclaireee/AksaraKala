class_name UIFx extends RefCounted
## Small shared helpers for the front-end screens (ui.md 3b): palette, fonts, frames, motes, fades.

## Parchment-and-ink palette. Dark scenes: GOLD_HI headings (bright paper), CREAM body, DIM secondary.
## Paper panels: INK, INK_HEAD, INK_DIM. GOLD/GOLD_LO are the aged-paper rule colours (the names stay for old callers).
const GOLD := Color("C8B38A")
const GOLD_HI := Color("F3E3B8")
const GOLD_LO := Color("6B5636")
const CREAM := Color("EADFC4")
const DIM := Color("A59A82")
const LACQUER := Color("140E0A")    # dark ink outline
const SOGAN := Color("3A2314")      # leather
const VERMILLION := Color("C0392B") # wax red
const INK := Color("2A1C12")
const INK_HEAD := Color("7A2A1E")
const INK_DIM := Color("6B5A44")
const PAPER := Color("E3D0A0")
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

# in-world "ink" surface (HUD cards, dialogue, prompts, banners): one look everywhere
const INK_BG := Color("140E0A")      # panel fill (drawn at ~90% in the art)
const LINE_DIM := Color("4A3A28")    # hairlines on ink
const ACCENT := Color("E0B35A")      # focus, selection, quest gold
const LABEL_COL := Color("B8A27A")   # caps labels on ink
const DANGER := Color("C9473B")      # wax red: damage, low HP, destructive only
const OK := Color("6FA37F")          # done / gained on ink

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


## A one-shot burst of rising ink motes over a rectangle.
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
	p.color = Color(1, 0.9, 0.7, 0.9)
	p.emitting = true
	parent.add_child(p)
	p.finished.connect(p.queue_free)
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
