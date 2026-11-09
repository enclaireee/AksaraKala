extends Control
## Launch intro (ui.md 4.0): the boot scene, about 30 s, then the title screen. Any key, click or pad button skips.
##
##  0  dark; a spark falls into the blencong (the wayang oil lamp) and it catches on the first gong
##  1  the lamp lights the kelir (shadow screen); the gunungan rises out of the banana trunk, dances, turns, sweeps away
##  2  ha na ca ra ka: five Javanese aksara written stroke by stroke in cyan light
##  3  Kala wakes: the screen bleeds red, ink crawls in from the edges, the kala head opens its eyes and swallows them
##  4  black: "Batara Kala eats."
##  5  dawn over the volcanoes: the Wiku on the peak raises the staff and writes Sundanese Ka (Laras's letter) in the sky
##  6  the Ka bursts into a pillar of light; the logo slams in; fade to the title
##
## Everything is timed by the T_* constants, which mirror CUE in tools/audio/intro.py (music/intro.ogg). Change both.
## Art: tools/gen_intro_art.py -> assets/art/intro/. Narration keys INTRO_* in data/text/ui.csv (with an inline
## fallback, so the lines still read right before the compiled translations are rebuilt).

signal finished

const ART := "res://assets/art/intro/"
const NEXT := "res://ui/title.tscn"
const TitleScript := preload("res://ui/title.gd")

const T_SPARK := 0.4
const T_LAMP := 1.2
const T_KELIR := 4.4
const T_GUNUNGAN := 5.6
const T_TURN := 7.4
const T_SWEEP := 8.6
const T_GLYPHS := [9.4, 10.2, 11.0, 11.8, 12.6]
const GLYPH_DRAW := 0.55
const T_FLARE := 13.4
const T_KALA := 14.2
const T_EYES := 15.8
const T_DEVOUR := 16.6
const T_BLACK := 17.6
const T_DAWN := 20.4
const T_RAISE := 23.6
const T_KA := 23.9
const T_IMPACT := 25.6
const T_TAG := 26.6
const T_OUT := 29.6

const GLYPHS := ["jawa_ha", "jawa_na", "jawa_ca", "jawa_ra", "jawa_ka"]
const LAMP_POS := Vector2(208, 58)
const SPOUT := Vector2(211, 79)          # bottom of the flame on the lamp's beak
const LAMP_LIFT := 46.0                  # how far the lamp is hauled up when the kelir lights
const GUN_REST := Vector2(200, 100)
const KALA_POS := Vector2(90, 62)
const MOUTH := KALA_POS + Vector2(150, 146)   # where Kala swallows the script
const SCRIPT_LIFT := -62.0               # the script is pushed up above his crown as he rises
const HERO_POS := Vector2(216, 136)      # feet on the peak at (240, 206)
const GEM_UP := Vector2(259, 137)        # the staff gem when raised
const LOGO_CENTRE := Vector2(240, 96)

## key -> [id, en]. Used when the compiled translation does not have the key yet.
const LINES := {
	"INTRO_1": ["Di dunia ini, sihir ditulis dalam aksara.", "In this world, magic is written in aksara."],
	"INTRO_2": ["Nama yang tertulis menambatkan jiwa.", "A written name anchors a soul."],
	"INTRO_3": ["Para leluhur menuliskan kutukan lama, agar tetap usai.", "The ancestors wrote the old curses down, so they would stay finished."],
	"INTRO_4": ["Namun apa yang tak pernah ditulis,", "But what nobody writes down,"],
	"INTRO_5": ["dimangsa Batara Kala.", "Batara Kala eats."],
	"INTRO_6": ["Tulislah, agar kau tak terlupa.", "Write, so you are not forgotten."],
	"INTRO_SKIP": ["Tekan tombol apa saja untuk melewati", "Press any key to skip"],
}

var next_scene := NEXT        # tests clear this so the intro does not leave the test scene

var _t := 0.0
var _events: Array = []       # [time, Callable], sorted; fired once each as _t passes them
var _ei := 0
var _leaving := false
var _shake := 0.0
var _rumble := 0.0
var _lift := 0.0              # extra y on the script row (tweened to SCRIPT_LIFT when Kala wakes)

var _stage: Control           # everything that shakes
var _lamp_act: Control
var _flame: Sprite2D
var _lamp_glow: TextureRect
var _kelir: TextureRect
var _gunungan: TextureRect
var _glyph_act: Node2D
var _inks: Array = []         # Ink nodes, ha na ca ra ka
var _ink_home: Array = []     # their rest positions
var _glows: Array = []
var _kala_act: Control
var _kala: TextureRect
var _eyes: TextureRect
var _red: TextureRect
var _ink_edges: Array = []
var _dawn_act: Control
var _dawn_layers: Array = []  # [TextureRect or Sprite2D, start offset y]
var _hero: Sprite2D
var _gem_glow: TextureRect
var _ka: Ink
var _logo: TextureRect
var _tag: Label
var _say_label: Label
var _at_label := {}           # narration key -> the label showing it
var _flash: ColorRect
var _cover: ColorRect
var _skip_hint: Label


## One aksara drawn in light: a polyline revealed along its length by `progress` (0..1), a leading spark at the pen.
class Ink extends Node2D:
	var stroke := PackedVector2Array()
	var dist := PackedFloat32Array()
	var core := Color("7FE8E0")
	var halo := Color(0.25, 0.72, 0.75, 0.3)
	var hot := Color(1, 1, 1, 0.85)
	var width := 2.0
	var progress := 0.0:
		set(v):
			progress = v
			queue_redraw()

	## Fits the raw template points into `box`, centred on this node.
	func setup(pts: PackedVector2Array, box: Vector2, w := 2.0) -> void:
		width = w
		var r := Rect2(pts[0], Vector2.ZERO)
		for p in pts:
			r = r.expand(p)
		var s := minf(box.x / maxf(r.size.x, 1.0), box.y / maxf(r.size.y, 1.0))
		stroke = PackedVector2Array()
		dist = PackedFloat32Array()
		var total := 0.0
		for i in pts.size():
			var q := ((pts[i] - r.get_center()) * s).round()
			if i > 0:
				total += q.distance_to(stroke[i - 1])
			stroke.append(q)
			dist.append(total)

	func tint(c: Color) -> void:
		core = c
		halo = Color(c, 0.3)
		queue_redraw()

	func _draw() -> void:
		if progress <= 0.0 or stroke.size() < 2:
			return
		var target := dist[dist.size() - 1] * clampf(progress, 0.0, 1.0)
		var pts := PackedVector2Array([stroke[0]])
		for i in range(1, stroke.size()):
			if dist[i] <= target:
				pts.append(stroke[i])
			else:
				var seg := maxf(dist[i] - dist[i - 1], 0.001)
				pts.append(stroke[i - 1].lerp(stroke[i], (target - dist[i - 1]) / seg).round())
				break
		if pts.size() < 2:
			return
		draw_polyline(pts, halo, width + 4.0)
		draw_polyline(pts, core, width + 1.0)
		draw_polyline(pts, hot, maxf(1.0, width - 1.0))
		if progress < 1.0:
			var tip := pts[pts.size() - 1]
			draw_rect(Rect2(tip - Vector2(2, 2), Vector2(4, 4)), Color(1, 1, 1, 0.9))


func _ready() -> void:
	TranslationServer.set_locale(TitleScript.load_language())
	GameSettings.apply_display()
	DisplayServer.window_set_title("Aksara Kala")
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	var bg := ColorRect.new()
	bg.color = UIFx.LACQUER
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(bg)
	_stage = _group(self)
	_build_lamp()
	_build_glyphs()
	_build_kala()
	_build_dawn()
	_build_logo()
	_say_label = UIFx.text("", "head", UIFx.HEAD)
	_say_label.position = Vector2(8, 226)
	_say_label.size = Vector2(464, 30)
	_say_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_say_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_say_label.modulate.a = 0.0
	add_child(_say_label)
	_skip_hint = UIFx.text(_line("INTRO_SKIP"), "body", UIFx.DIM)
	_skip_hint.position = Vector2(8, 258)
	_skip_hint.size = Vector2(464, 10)
	_skip_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_skip_hint.modulate.a = 0.0
	add_child(_skip_hint)
	_flash = ColorRect.new()
	_flash.color = Color(1, 0.97, 0.9, 0.0)
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_flash)
	_cover = UIFx.cover(self)
	_cover.color = Color(UIFx.LACQUER, 0.0)
	_timeline()
	Snd.music("intro", 0.2)


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


# ---------------------------------------------------------------------------------------------------------------- build

func _group(parent: Node) -> Control:
	var c := Control.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = MOUSE_FILTER_IGNORE
	parent.add_child(c)
	return c


func _tex(name: String, pos: Vector2, parent: Node) -> TextureRect:
	var t := TextureRect.new()
	t.texture = load(ART + name + ".png")
	t.position = pos
	t.size = t.texture.get_size()
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	t.mouse_filter = MOUSE_FILTER_IGNORE
	parent.add_child(t)
	return t


func _build_lamp() -> void:
	_lamp_act = _group(_stage)
	_kelir = _tex("kelir", Vector2.ZERO, _lamp_act)
	_kelir.modulate.a = 0.0
	_gunungan = _tex("gunungan", Vector2(GUN_REST.x, 272), _lamp_act)
	_gunungan.pivot_offset = Vector2(40, 136)   # turns on its stick, where the dalang holds it
	_lamp_glow = _tex("glow_warm", SPOUT + Vector2(14, 0) - Vector2(80, 80), _lamp_act)
	_lamp_glow.modulate.a = 0.0
	var lamp := _tex("blencong", LAMP_POS, _lamp_act)
	lamp.name = "Lamp"
	_flame = Sprite2D.new()
	_flame.texture = load(ART + "flame.png")
	_flame.hframes = 4
	_flame.centered = false
	_flame.offset = Vector2(-6, -21)            # bottom centre of the frame sits on the spout
	_flame.position = SPOUT
	_flame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_flame.visible = false
	_lamp_act.add_child(_flame)


func _build_glyphs() -> void:
	_glyph_act = Node2D.new()
	_stage.add_child(_glyph_act)
	for i in GLYPHS.size():
		var at := Vector2(80 + i * 80, 112)
		var g := _tex("glow_cyan", at - Vector2(48, 48), _stage)
		g.modulate.a = 0.0
		_glows.append(g)
		var data: GlyphData = GlyphData.by_id(GLYPHS[i])
		var ink := Ink.new()
		ink.setup(data.templates[0], Vector2(60, 44), 2.0)
		ink.position = at
		_glyph_act.add_child(ink)
		_inks.append(ink)
		_ink_home.append(at)
	_stage.move_child(_glyph_act, -1)   # ink above its glow


func _build_kala() -> void:
	_kala_act = _group(_stage)
	_stage.move_child(_kala_act, _glows[0].get_index())   # Kala behind the script he is about to eat, and its glow
	_red = _tex("glow_red", KALA_POS + Vector2(-30, -20), _kala_act)
	_red.modulate.a = 0.0
	_kala = _tex("kala_head", KALA_POS, _kala_act)
	_kala.pivot_offset = MOUTH - KALA_POS
	_kala.modulate.a = 0.0
	_eyes = _tex("kala_eyes", KALA_POS, _kala_act)
	_eyes.pivot_offset = _kala.pivot_offset
	_eyes.modulate.a = 0.0
	for i in 4:   # ink crawling in from the frame; added to the stage at the end of _build_dawn, over every act
		var e := TextureRect.new()
		e.texture = load(ART + "ink_%d.png" % i)
		e.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		e.mouse_filter = MOUSE_FILTER_IGNORE
		e.size = Vector2(480, 270)
		e.modulate.a = 0.0
		_ink_edges.append(e)


func _build_dawn() -> void:
	_dawn_act = _group(_stage)
	_dawn_act.visible = false
	var offs := {"dawn_sky": 0.0, "dawn_far": 10.0, "dawn_haze": 16.0, "dawn_mid": 24.0, "dawn_peak": 40.0}
	for k: String in offs:
		var r := _tex(k, Vector2(0, offs[k]), _dawn_act)
		_dawn_layers.append([r, offs[k]])
	_dawn_act.add_child(UIFx.motes_layer(Rect2(0, 190, 480, 80), 14))
	_hero = Sprite2D.new()
	_hero.texture = load(ART + "hero_wiku.png")
	_hero.hframes = 2
	_hero.centered = false
	_hero.position = HERO_POS + Vector2(0, 40)
	_hero.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_dawn_act.add_child(_hero)
	_dawn_layers.append([_hero, 40.0])
	_gem_glow = _tex("glow_cyan", GEM_UP - Vector2(48, 48), _dawn_act)
	_gem_glow.pivot_offset = Vector2(48, 48)
	_gem_glow.modulate.a = 0.0
	_ka = Ink.new()
	_ka.setup(GlyphData.by_id("sunda_ka").templates[0], Vector2(120, 104), 3.0)
	_ka.position = Vector2(240, 68)
	_dawn_act.add_child(_ka)
	for e in _ink_edges:   # the ink crawls over the Kala scene; it lives on the stage above every act
		_stage.add_child(e)


func _build_logo() -> void:
	_logo = UIFx.rect_tex("logo", Vector2.ZERO)
	_logo.position = (LOGO_CENTRE - _logo.size / 2.0).round()
	_logo.pivot_offset = _logo.size / 2.0
	_logo.modulate.a = 0.0
	_stage.add_child(_logo)
	_tag = UIFx.text("The script of time", "body", UIFx.TEXT)
	_tag.size = Vector2(200, 10)
	_tag.position = Vector2(140, _logo.position.y + _logo.size.y + 4)
	_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tag.modulate.a = 0.0
	_stage.add_child(_tag)


# ---------------------------------------------------------------------------------------------------------------- timeline

func _at(t: float, f: Callable) -> void:
	_events.append([t, f])


func _timeline() -> void:
	_at(0.6, func() -> void: _tw(_skip_hint, "modulate:a", 0.8, 0.6))
	_at(4.6, func() -> void: _tw(_skip_hint, "modulate:a", 0.0, 0.8))
	# 0: the spark and the lamp
	_at(T_SPARK, _spark)
	_at(T_LAMP, _light_lamp)
	_say("INTRO_1", 2.0, 4.6)
	# 1: the kelir and the gunungan
	_at(T_KELIR, func() -> void:
		_tw(_kelir, "modulate:a", 1.0, 1.6, Tween.EASE_IN_OUT)
		_tw(_lamp_glow, "modulate:a", 0.45, 1.6)
		for n in [_lamp_act.get_node("Lamp"), _flame, _lamp_glow]:   # the lamp is hauled up to hang over the screen
			_tw(n, "position:y", n.position.y - LAMP_LIFT, 1.6, Tween.EASE_IN_OUT))
	_at(T_GUNUNGAN, func() -> void:
		var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(_gunungan, "position:y", GUN_REST.y, 1.2))
	_say("INTRO_2", 5.8, 8.4)
	_at(T_TURN, func() -> void:   # the dalang twirls the kayon: it turns face to back and back again
		var tw := create_tween().set_trans(Tween.TRANS_SINE)
		tw.tween_property(_gunungan, "scale:x", -1.0, 0.3)
		tw.tween_property(_gunungan, "scale:x", 1.0, 0.3)
		tw.tween_property(_gunungan, "scale:x", -1.0, 0.25)
		tw.tween_property(_gunungan, "scale:x", 1.0, 0.25))
	_at(T_SWEEP, func() -> void:
		var tw := create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_property(_gunungan, "rotation", deg_to_rad(-50.0), 0.6)
		tw.tween_property(_gunungan, "position:x", -140.0, 0.6)
		_tw(_kelir, "modulate", Color(0.22, 0.2, 0.42), 0.8)
		_tw(_lamp_glow, "modulate:a", 0.0, 0.6)
		_tw(_lamp_act.get_node("Lamp"), "modulate", Color(0.35, 0.3, 0.5), 0.8)
		_tw(_flame, "modulate", Color(1, 1, 1, 0.5), 0.8))
	# 2: ha na ca ra ka
	for i in T_GLYPHS.size():
		_at(T_GLYPHS[i], _write.bind(i))
	_say("INTRO_3", 9.9, 13.6)
	_at(T_FLARE, _flare)
	# 3: Kala
	_at(T_KALA, _kala_wakes)
	_say("INTRO_4", 14.8, 17.3, UIFx.DANGER)
	_at(T_EYES, _eyes_open)
	_at(T_DEVOUR, _devour)
	_at(T_BLACK, _cut_black)
	_say("INTRO_5", 18.0, 20.0, UIFx.DANGER, "display", 120.0)
	# 4: dawn
	_at(T_DAWN, _dawn)
	_say("INTRO_6", 21.0, 23.4, UIFx.ACCENT)
	_at(T_RAISE, _raise)
	_at(T_KA, func() -> void:
		_tw(_ka, "progress", 1.0, T_IMPACT - T_KA - 0.15, Tween.EASE_IN_OUT))
	_at(T_IMPACT, _impact)
	_at(T_TAG, func() -> void: UIFx.rise_in(_tag, 4.0, 0.6))
	_at(T_OUT, func() -> void: _leave(0.9))
	_events.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])


## A narration line: fades and rises in at t0, out by t1. Heading lines share the bottom caption; a bigger kind
## gets its own label, drawn over the black cover.
func _say(key: String, t0: float, t1: float, color := UIFx.HEAD, kind := "head", y := 226.0) -> void:
	_at(t0, func() -> void:
		var l := _say_label
		if kind != "head":
			l = UIFx.text("", kind, color)
			l.size = Vector2(464, 30)
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.z_index = _cover.z_index + 1
			add_child(l)
		l.text = _line(key)
		l.add_theme_color_override("font_color", color)
		l.position = Vector2(8, y)
		UIFx.rise_in(l, 3.0, 0.5)
		_at_label[key] = l)
	_at(t1 - 0.4, func() -> void:
		if _at_label.has(key):
			_tw(_at_label[key], "modulate:a", 0.0, 0.4))


func _line(key: String) -> String:
	var s := tr(key)
	if s == key or s == "":
		s = LINES[key][0 if TranslationServer.get_locale().begins_with("id") else 1]
	return s


func _tw(n: Object, prop: String, to: Variant, time: float, ease := Tween.EASE_OUT) -> Tween:
	var tw := create_tween().set_ease(ease).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(n, prop, to, time)
	return tw


func _process(delta: float) -> void:
	_t += delta
	while _ei < _events.size() and _events[_ei][0] <= _t:
		var f: Callable = _events[_ei][1]
		_ei += 1
		f.call()
	# the flame flickers and its glow breathes with it
	if _flame.visible:
		_flame.frame = int(_t * 9.0) % 4
		if _t < T_KELIR:
			_lamp_glow.modulate.a = (0.85 + 0.15 * sin(_t * 23.0) * sin(_t * 7.0)) * clampf((_t - T_LAMP) * 3.0, 0.0, 1.0)
	# the gunungan sways on its stick while it stands
	if _t > T_GUNUNGAN + 1.0 and _t < T_SWEEP:
		_gunungan.rotation = deg_to_rad(4.0 * sin((_t - T_GUNUNGAN) * 2.6))
	# the script trembles while Kala wakes
	if _t >= T_KALA and _t < T_DEVOUR:
		for i in _inks.size():
			_inks[i].position = _ink_home[i] + Vector2(randi_range(-1, 1), roundf(_lift) + randi_range(-1, 1))
	# the eyes smoulder
	if _t >= T_EYES and _t < T_BLACK:
		_eyes.self_modulate.a = 0.8 + 0.2 * sin(_t * 17.0)
	if _gem_glow.modulate.a > 0.0 and _t < T_IMPACT:
		_gem_glow.scale = Vector2.ONE * (1.0 + 0.08 * sin(_t * 11.0))
	# camera shake: a decaying kick plus a held rumble
	_shake = move_toward(_shake, 0.0, delta * 14.0)
	var s := maxf(_shake, _rumble)
	_stage.position = (Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * s).round() if s > 0.05 else Vector2.ZERO


func _kick(amount: float) -> void:
	_shake = maxf(_shake, amount)


func _flash_it(alpha: float, time: float, tint := Color(1, 0.97, 0.9)) -> void:
	_flash.color = Color(tint, alpha)
	create_tween().tween_property(_flash, "color:a", 0.0, time).set_ease(Tween.EASE_OUT)


# ---------------------------------------------------------------------------------------------------------------- beats

func _spark() -> void:
	var s := _tex("shard", Vector2(SPOUT.x - 1, -4), _lamp_act)
	s.modulate = UIFx.WARM
	var tw := create_tween()
	tw.tween_property(s, "position:y", SPOUT.y - 3.0, T_LAMP - T_SPARK).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(s.queue_free)


func _light_lamp() -> void:
	_flame.visible = true
	_flame.scale = Vector2(1.6, 1.6)
	create_tween().tween_property(_flame, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_flash_it(0.25, 0.5, UIFx.WARM)
	var p := UIFx.burst(_lamp_act, Rect2(SPOUT - Vector2(6, 10), Vector2(12, 8)), 14, 0.9)
	p.modulate = UIFx.WARM


func _write(i: int) -> void:
	var ink: Ink = _inks[i]
	var tw := create_tween()
	tw.tween_property(ink, "progress", 1.0, GLYPH_DRAW).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(func() -> void:
		_tw(_glows[i], "modulate:a", 0.7, 0.3)
		UIFx.burst(_stage, Rect2(_ink_home[i] - Vector2(22, 16), Vector2(44, 32)), 16, 0.7)
		var lat := UIFx.text(GlyphData.by_id(GLYPHS[i]).latin, "label", UIFx.LABEL_COL)
		lat.size = Vector2(40, 10)
		lat.position = _ink_home[i] + Vector2(-20, 30)
		lat.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lat.name = "Latin%d" % i
		_glyph_act.add_child(lat)
		UIFx.rise_in(lat, 3.0, 0.3))


func _flare() -> void:
	_flash_it(0.35, 0.5, UIFx.ACCENT)
	_kick(2.0)
	for ink in _inks:
		ink.tint(Color(1, 1, 1))
		create_tween().tween_method(Callable(ink, "tint"), Color(1, 1, 1), UIFx.ACCENT, 0.6)


func _kala_wakes() -> void:
	_flash_it(0.6, 0.4, UIFx.DANGER)
	_kick(7.0)
	_rumble = 1.0
	_tw(_kelir, "modulate", Color(0.6, 0.12, 0.2), 0.5)
	_tw(self, "_lift", SCRIPT_LIFT, 1.2, Tween.EASE_IN_OUT)
	_tw(_red, "modulate:a", 1.0, 1.2)
	for g in _glows:
		_tw(g, "modulate", Color(UIFx.DANGER, 0.5), 0.6)
		_tw(g, "position:y", g.position.y + SCRIPT_LIFT, 1.2, Tween.EASE_IN_OUT)
	for ink in _inks:
		create_tween().tween_method(Callable(ink, "tint"), UIFx.ACCENT, UIFx.DANGER, 0.8)
	for n in _glyph_act.get_children():
		if n is Label:
			_tw(n, "modulate:a", 0.0, 0.5)
	_kala.position.y = KALA_POS.y + 24
	var tw := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(_kala, "modulate:a", 1.0, 1.2).set_delay(0.2)
	tw.tween_property(_kala, "position:y", KALA_POS.y, 1.3).set_delay(0.2)
	for i in _ink_edges.size():   # the ink crawls in, step by step
		var e: TextureRect = _ink_edges[i]
		var d: float = [0.0, 0.8, 1.8, 2.8][i]
		tw.tween_property(e, "modulate:a", 1.0, 0.35).set_delay(d)


func _eyes_open() -> void:
	_eyes.position = KALA_POS
	_eyes.pivot_offset = Vector2(150, 97)   # the eyes open about their own middle
	_eyes.scale = Vector2(1.0, 0.1)
	var tw := create_tween().set_parallel()
	tw.tween_property(_eyes, "modulate:a", 1.0, 0.15)
	tw.tween_property(_eyes, "scale:y", 1.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_flash_it(0.45, 0.3, UIFx.DANGER)
	_kick(6.0)
	_rumble = 2.0


func _devour() -> void:
	_eyes.pivot_offset = _kala.pivot_offset   # from here on they grow with the head, about the mouth
	var tw := create_tween().set_parallel().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	for i in _inks.size():
		var ink: Ink = _inks[i]
		var d := 0.06 * absf(i - 2.0)
		tw.tween_property(ink, "position", MOUTH, 0.7).set_delay(d)
		tw.tween_property(ink, "scale", Vector2(0.1, 0.1), 0.7).set_delay(d)
		tw.tween_property(ink, "modulate:a", 0.0, 0.7).set_delay(d + 0.1)
		tw.tween_property(_glows[i], "modulate:a", 0.0, 0.4).set_delay(d)
	tw.tween_property(_kala, "scale", Vector2(1.08, 1.08), 0.9)
	tw.tween_property(_eyes, "scale", Vector2(1.08, 1.08), 0.9)
	var p := UIFx.burst(_stage, Rect2(Vector2(60, 80), Vector2(360, 60)), 40, 0.9)
	p.modulate = UIFx.DANGER
	p.direction = Vector2.DOWN
	p.gravity = Vector2(0, 40)


func _cut_black() -> void:
	_rumble = 0.0
	_shake = 0.0
	_cover.color = Color(UIFx.LACQUER, 1.0)
	_lamp_act.visible = false
	_glyph_act.visible = false
	_kala_act.visible = false
	for g in _glows:
		g.visible = false
	for e in _ink_edges:
		e.visible = false
	_say_label.modulate.a = 0.0


func _dawn() -> void:
	_dawn_act.visible = true
	_tw(_cover, "color:a", 0.0, 1.6, Tween.EASE_IN_OUT)
	var tw := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	for pair in _dawn_layers:   # the camera rises: nearer layers travel further
		var n = pair[0]   # a TextureRect or the hero Sprite2D
		tw.tween_property(n, "position:y", n.position.y - pair[1], 3.2)


func _raise() -> void:
	_hero.frame = 1
	_kick(1.5)
	_tw(_gem_glow, "modulate:a", 1.0, 0.4)
	UIFx.burst(_dawn_act, Rect2(GEM_UP - Vector2(6, 6), Vector2(12, 12)), 12, 0.6)
	_ka.modulate.a = 1.0


func _impact() -> void:
	_flash_it(1.0, 1.1)
	_kick(9.0)
	# the Ka becomes the light
	_ka.tint(Color(1, 1, 1))
	_tw(_ka, "modulate:a", 0.0, 0.5)
	# a pillar of light from the staff to the sky
	var b := _tex("beam", Vector2(GEM_UP.x - 20, 0), _dawn_act)
	b.size = Vector2(40, GEM_UP.y)
	b.pivot_offset = Vector2(20, GEM_UP.y)
	b.scale = Vector2(0.1, 1.0)
	var tw := create_tween()
	tw.tween_property(b, "scale:x", 1.8, 0.15).set_ease(Tween.EASE_OUT)
	tw.tween_property(b, "scale:x", 0.8, 0.6)
	tw.parallel().tween_property(b, "modulate:a", 0.0, 2.2).set_delay(0.3)
	# two shockwave rings off the gem
	for k in 2:
		var r := _tex("ring", GEM_UP - Vector2(48, 48), _dawn_act)
		r.pivot_offset = Vector2(48, 48)
		r.scale = Vector2(0.15, 0.15)
		var rt := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		rt.tween_property(r, "scale", Vector2(7.0, 7.0), 1.1).set_delay(k * 0.18)
		rt.tween_property(r, "modulate:a", 0.0, 1.1).set_delay(k * 0.18)
	var p := UIFx.burst(_dawn_act, Rect2(GEM_UP - Vector2(30, 10), Vector2(60, 20)), 48, 1.4)
	p.initial_velocity_max = 140.0
	p.spread = 70.0
	# the world dims under the logo
	_tw(_dawn_act, "modulate", Color(0.55, 0.5, 0.65), 1.4)
	_tw(_gem_glow, "modulate:a", 0.0, 1.2)
	# the logo slams in
	_logo.scale = Vector2(2.6, 2.6)
	var lt := create_tween().set_parallel()
	lt.tween_property(_logo, "modulate:a", 1.0, 0.12)
	lt.tween_property(_logo, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	lt.chain().tween_callback(func() -> void: _kick(4.0))
	UIFx.burst(_stage, Rect2(_logo.position, _logo.size), 30, 1.2)


# ---------------------------------------------------------------------------------------------------------------- leaving

func _input(event: InputEvent) -> void:
	if _leaving or _t < 0.3:
		return
	var press := event.is_pressed() and not event.is_echo() \
			and (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton)
	if press:
		get_viewport().set_input_as_handled()
		skip()


## Jumps straight to the title (a short fade). Also what the end of the timeline does, with a longer fade.
func skip() -> void:
	_leave(0.35)


func _leave(time: float) -> void:
	if _leaving:
		return
	_leaving = true
	var tw := create_tween()
	tw.tween_property(_cover, "color:a", 1.0, time)
	tw.tween_callback(func() -> void:
		finished.emit()
		if next_scene != "":
			get_tree().change_scene_to_file(next_scene))
