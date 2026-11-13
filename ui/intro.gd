extends Control
## Launch intro (ui.md 4.0): the boot scene, ten seconds, no words, then the title screen. Any key, click or pad
## button skips.
##
##  0  black; lightning shows a face in the storm clouds; Kala's eyes open (the camera pushes in)
##  1  smash cut: the Wiku on the crag, cloak cracking in the wind, Kala looming over the volcanoes
##  2  the staff goes up and Sundanese Ka (Laras's letter) is written in light across Kala's face
##  3  the light breaks the storm: flash, rings, Kala torn apart, dawn; the logo slams in; fade to the title
##
## Everything is timed by the T_* constants, which mirror CUE in tools/audio/intro.py (music/intro.ogg). Change both.
## Art: tools/gen_intro_art.py -> assets/art/intro/ (positions below match its HERO_FEET, CLOSE and SKY_KALA).

signal finished

const ART := "res://assets/art/intro/"
const NEXT := "res://ui/title.tscn"
const TitleScript := preload("res://ui/title.gd")

const T_STRIKES := [0.7, 1.05]   # lightning in the dark shows the face
const T_EYES := 1.7
const T_CUT := 3.0
const T_BOLT := 3.8              # lightning in the wide shot
const T_RAISE := 4.5
const T_KA := 4.75
const T_IMPACT := 6.2
const T_TAG := 7.0
const T_OUT := 9.2               # + the 0.8 s fade = 10 s

const CLOSE_PIVOT := Vector2(240, 120)   # between Kala's eyes in the close-up
const HERO_POS := Vector2(342, 111)      # sprite top-left; feet on the crag at (372, 206)
const GEM_UP := Vector2(347, 114)        # the staff gem when raised
const KA_POS := Vector2(196, 96)         # Ka is written over Kala's face in the sky
const LOGO_CENTRE := Vector2(240, 70)
const DARK := Color(0.16, 0.13, 0.18)    # the close-up between lightning strikes

## key -> [id, en]. Used when the compiled translation does not have the key yet.
const LINES := {
	"INTRO_SKIP": ["Tekan tombol apa saja untuk melewati", "Press any key to skip"],
}

var next_scene := NEXT        # tests clear this so the intro does not leave the test scene

var _t := 0.0
var _events: Array = []       # [time, Callable], sorted; fired once each as _t passes them
var _ei := 0
var _leaving := false
var _shake := 0.0
var _rumble := 0.0

var _stage: Control           # everything that shakes
var _close_act: Control
var _close_kala: TextureRect
var _close_eyes: TextureRect
var _bolt: Sprite2D
var _wide_act: Control
var _storm: TextureRect
var _dawn: TextureRect
var _kala_sky: TextureRect
var _kala_eyes: TextureRect
var _land: Array = []         # [node, start offset y]: the camera tilts down onto these
var _hero: Sprite2D
var _gem_glow: TextureRect
var _ka: Ink
var _logo: TextureRect
var _tag: Label
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
	var _wet: Line2D
	var _brush: Line2D
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
		if _brush:
			_brush.default_color = c
			_wet.default_color = c.darkened(0.55)
		queue_redraw()

	func _draw() -> void:
		if _brush == null:   # brush look: wet edge under a tiled pixel brush, same as the cast stroke
			_wet = CastOverlay.brush_line(width * 2.0 + 2.0, core.darkened(0.55), false)
			_brush = CastOverlay.brush_line(width * 2.0, core)
			add_child(_wet)
			add_child(_brush)
		_wet.visible = progress > 0.0 and stroke.size() >= 2
		_brush.visible = _wet.visible
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
		_wet.points = pts
		_brush.points = pts
		if progress < 1.0:
			var tip := pts[pts.size() - 1]
			draw_rect(Rect2(tip - Vector2(2, 2), Vector2(4, 4)), Color(1, 1, 1, 0.9))


func _ready() -> void:
	TranslationServer.set_locale(TitleScript.load_language())
	GameSettings.apply_display()
	DisplayServer.window_set_title("AksaraKala")
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	var bg := ColorRect.new()
	bg.color = UIFx.LACQUER
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(bg)
	_stage = _group(self)
	_build_close()
	_build_wide()
	_build_logo()
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


func _sprite(name: String, frames: int, parent: Node) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(ART + name + ".png")
	s.hframes = frames
	s.centered = false
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(s)
	return s


## Embers rising through the frame.
func _embers(parent: Node, area: Rect2, amount: int) -> CPUParticles2D:
	var p := UIFx.motes_layer(area, amount)
	p.modulate = Color("F2B27A")
	p.lifetime = 3.0
	p.preprocess = 3.0
	p.initial_velocity_min = 18.0
	p.initial_velocity_max = 40.0
	p.gravity = Vector2(14, -10)
	parent.add_child(p)
	return p


func _build_close() -> void:
	_close_act = _group(_stage)
	_close_act.pivot_offset = CLOSE_PIVOT
	_close_act.modulate = Color(1, 1, 1, 0.0)
	var sky := _tex("storm_sky", Vector2.ZERO, _close_act)
	sky.modulate = Color(0.3, 0.26, 0.34)
	_close_kala = _tex("kala_close", Vector2.ZERO, _close_act)
	_close_kala.modulate = DARK
	_close_eyes = _tex("kala_close_eyes", Vector2.ZERO, _close_act)
	_close_eyes.pivot_offset = CLOSE_PIVOT
	_close_eyes.modulate.a = 0.0
	_embers(_close_act, Rect2(0, 230, 480, 40), 30)
	_bolt = _sprite("lightning", 2, _stage)   # on the stage so the push-in does not scale it
	_bolt.visible = false


func _build_wide() -> void:
	_wide_act = _group(_stage)
	_wide_act.visible = false
	_storm = _tex("storm_sky", Vector2.ZERO, _wide_act)
	_dawn = _tex("dawn_sky", Vector2.ZERO, _wide_act)
	_dawn.modulate.a = 0.0
	_kala_sky = _tex("kala_sky", Vector2.ZERO, _wide_act)
	_kala_sky.pivot_offset = KA_POS
	_kala_sky.modulate = Color(0.85, 0.8, 0.85, 0.92)
	_kala_eyes = _tex("kala_sky_eyes", Vector2.ZERO, _wide_act)
	_kala_eyes.pivot_offset = KA_POS
	var crater := _tex("glow_red", Vector2(446 - 180, 158 - 120), _wide_act)
	crater.modulate.a = 0.5
	crater.name = "Crater"
	_land.append([crater, 12.0])
	for k: Array in [["storm_far", 12.0], ["storm_mid", 24.0], ["storm_peak", 44.0]]:
		_land.append([_tex(k[0], Vector2(0, k[1]), _wide_act), k[1]])
	_gem_glow = _tex("glow_cyan", GEM_UP - Vector2(48, 48), _wide_act)
	_gem_glow.pivot_offset = Vector2(48, 48)
	_gem_glow.modulate.a = 0.0
	_hero = _sprite("hero_storm", 3, _wide_act)
	_hero.position = HERO_POS + Vector2(0, 44)
	_land.append([_hero, 44.0])
	_embers(_wide_act, Rect2(300, 200, 180, 70), 24)
	_ka = Ink.new()
	_ka.setup(GlyphData.by_id("sunda_ka").templates[0], Vector2(130, 110), 3.0)
	_ka.position = KA_POS
	_wide_act.add_child(_ka)
	_stage.move_child(_bolt, -1)   # lightning over both shots


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
	_at(0.4, func() -> void: _tw(_skip_hint, "modulate:a", 0.7, 0.5))
	_at(2.4, func() -> void: _tw(_skip_hint, "modulate:a", 0.0, 0.5))
	# 0: the face in the storm
	_at(0.0, func() -> void:
		_rumble = 0.6
		_tw(_close_act, "modulate:a", 1.0, 1.2, Tween.EASE_IN)
		_tw(_close_act, "scale", Vector2(1.12, 1.12), T_CUT, Tween.EASE_IN))
	_at(T_STRIKES[0], _strike.bind(0, Vector2(330, 0), 0.6))
	_at(T_STRIKES[1], _strike.bind(1, Vector2(20, 0), 0.4))
	_at(T_EYES, _eyes_open)
	# 1: the Wiku on the crag
	_at(T_CUT, _cut_wide)
	_at(T_BOLT, func() -> void:
		_strike(0, Vector2(40, -20), 0.3)
		_kala_sky.modulate = Color(1.3, 1.2, 1.3, 0.92)
		_tw(_kala_sky, "modulate", Color(0.85, 0.8, 0.85, 0.92), 0.6))
	# 2: Ka
	_at(T_RAISE, _raise)
	_at(T_KA, func() -> void:
		_ka.modulate.a = 1.0
		_tw(_ka, "progress", 1.0, T_IMPACT - T_KA - 0.2, Tween.EASE_IN_OUT)
		_tw(self, "_rumble", 2.5, T_IMPACT - T_KA, Tween.EASE_IN))
	# 3: the light
	_at(T_IMPACT, _impact)
	_at(T_TAG, func() -> void: UIFx.rise_in(_tag, 4.0, 0.6))
	_at(T_OUT, func() -> void: _leave(0.8))
	_events.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])


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
	# the eyes smoulder, and burn hotter while Ka is written at them
	if _t >= T_EYES and _t < T_CUT:
		_close_eyes.self_modulate.a = 0.8 + 0.2 * sin(_t * 17.0)
	if _t >= T_CUT and _t < T_IMPACT:
		var heat := clampf((_t - T_KA) / (T_IMPACT - T_KA), 0.0, 1.0)
		_kala_eyes.self_modulate = Color(1.0 + heat * 0.6, 1.0 + heat * 0.3, 1.0, 0.75 + 0.25 * sin(_t * (13.0 + heat * 20.0)))
	# the cloak cracks in the wind until the staff goes up
	if _t >= T_CUT and _t < T_RAISE:
		_hero.frame = int(_t * 7.0) % 2
	if _gem_glow.modulate.a > 0.0 and _t < T_IMPACT:
		_gem_glow.scale = Vector2.ONE * (1.0 + 0.1 * sin(_t * 15.0))
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

## A lightning bolt: two flickers, a violet-white flash, and the close-up's face lit for a moment.
func _strike(frame: int, at: Vector2, alpha: float) -> void:
	_bolt.frame = frame
	_bolt.position = at
	var tw := create_tween()
	tw.tween_callback(func() -> void: _bolt.visible = true)
	tw.tween_interval(0.06)
	tw.tween_callback(func() -> void: _bolt.visible = false)
	tw.tween_interval(0.04)
	tw.tween_callback(func() -> void: _bolt.visible = true)
	tw.tween_interval(0.08)
	tw.tween_callback(func() -> void: _bolt.visible = false)
	_flash_it(alpha, 0.35, Color("C8B8FF"))
	_kick(3.0)
	if _close_act.visible:
		_close_kala.modulate = Color(1.2, 1.1, 1.25)
		_tw(_close_kala, "modulate", DARK if _t < T_EYES else Color(0.6, 0.45, 0.5), 0.5)


func _eyes_open() -> void:
	_close_eyes.scale = Vector2(1.0, 0.1)
	var tw := create_tween().set_parallel()
	tw.tween_property(_close_eyes, "modulate:a", 1.0, 0.1)
	tw.tween_property(_close_eyes, "scale:y", 1.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tw(_close_kala, "modulate", Color(0.6, 0.45, 0.5), 0.3)
	_flash_it(0.5, 0.35, UIFx.DANGER)
	_kick(7.0)
	_rumble = 1.5


func _cut_wide() -> void:
	_close_act.visible = false
	_bolt.visible = false
	_wide_act.visible = true
	_rumble = 0.5
	_kick(5.0)
	_flash_it(0.3, 0.25)
	var tw := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	for pair in _land:   # the camera tilts down onto the crag: nearer layers travel further
		var n = pair[0]   # a TextureRect or the hero Sprite2D
		tw.tween_property(n, "position:y", n.position.y - pair[1], 1.4)


func _raise() -> void:
	_hero.frame = 2
	_kick(2.5)
	_tw(_gem_glow, "modulate:a", 1.0, 0.3)
	UIFx.burst(_wide_act, Rect2(GEM_UP - Vector2(6, 6), Vector2(12, 12)), 14, 0.6)


func _impact() -> void:
	_flash_it(1.0, 1.0)
	_kick(10.0)
	_rumble = 0.0
	# the Ka becomes the light
	_ka.tint(Color(1, 1, 1))
	_tw(_ka, "modulate:a", 0.0, 0.5)
	# the storm and Kala are torn apart; dawn behind them
	for n in [_kala_sky, _kala_eyes]:
		var tw := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(n, "scale", Vector2(1.3, 1.3), 0.9)
		tw.tween_property(n, "modulate:a", 0.0, 0.7)
	_tw(_storm, "modulate:a", 0.0, 1.0)
	_dawn.modulate.a = 1.0
	_tw(_wide_act.get_node("Crater"), "modulate:a", 0.0, 0.8)
	for pair in _land:
		if pair[0] is TextureRect and pair[0].name != "Crater":
			_tw(pair[0], "modulate", Color(0.8, 0.7, 0.9), 1.0)
	_wide_act.add_child(UIFx.motes_layer(Rect2(0, 180, 480, 90), 16))
	# rings off the letter, a pillar of light off the staff
	for k in 3:
		var r := _tex("ring", KA_POS - Vector2(48, 48), _wide_act)
		r.pivot_offset = Vector2(48, 48)
		r.scale = Vector2(0.2, 0.2)
		var rt := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		rt.tween_property(r, "scale", Vector2(8.0, 8.0), 1.2).set_delay(k * 0.14)
		rt.tween_property(r, "modulate:a", 0.0, 1.2).set_delay(k * 0.14)
	var b := _tex("beam", Vector2(GEM_UP.x - 20, 0), _wide_act)
	b.size = Vector2(40, GEM_UP.y)
	b.pivot_offset = Vector2(20, GEM_UP.y)
	b.scale = Vector2(0.1, 1.0)
	var bt := create_tween()
	bt.tween_property(b, "scale:x", 1.6, 0.15).set_ease(Tween.EASE_OUT)
	bt.tween_property(b, "scale:x", 0.7, 0.6)
	bt.parallel().tween_property(b, "modulate:a", 0.0, 2.0).set_delay(0.3)
	_tw(_gem_glow, "modulate:a", 0.0, 1.2)
	var p := UIFx.burst(_wide_act, Rect2(KA_POS - Vector2(50, 40), Vector2(100, 80)), 60, 1.4)
	p.initial_velocity_max = 160.0
	p.spread = 180.0
	p.gravity = Vector2(0, 20)
	# the logo slams in
	_logo.scale = Vector2(2.6, 2.6)
	var lt := create_tween().set_parallel()
	lt.tween_property(_logo, "modulate:a", 1.0, 0.1).set_delay(0.15)
	lt.tween_property(_logo, "scale", Vector2.ONE, 0.3).set_delay(0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
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
