class_name UIFx extends RefCounted
## Small shared helpers for the front-end screens (ui.md 3b): palette, fonts, frames, motes, fades.

const GOLD := Color("C9A24A")
const GOLD_HI := Color("F2D488")
const GOLD_LO := Color("7A5A22")
const CREAM := Color("EDE3CC")
const DIM := Color("9C8F78")
const LACQUER := Color("0E0B0A")
const SOGAN := Color("3A2618")
const VERMILLION := Color("B8432B")
const ART := "res://assets/art/ui/"


static var _cache := {}   # keeps textures alive: draw_texture does not hold a reference


static func tex(name: String) -> Texture2D:
	if not _cache.has(name):
		_cache[name] = load(ART + name + ".png")
	return _cache[name]


static func cinzel() -> Font:
	return load("res://assets/fonts/Cinzel.ttf")


## A Label in the theme's body font, or Cinzel, with the 1 px outline.
static func label(text: String, size := 8, color := CREAM, use_cinzel := false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", LACQUER)
	l.add_theme_constant_override("outline_size", 1)
	if use_cinzel:
		l.add_theme_font_override("font", cinzel())
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


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
