extends Node
## Base class for trailer shot scripts (video/capture/README.md). A shot extends this file:
##
##     extends "res://video/capture/shot.gd"
##     func run() -> void:
##         await start_new("mage")
##         await go("ts_kampung", "from_ts_kebun")
##         rec_start()
##         await cam_pan(Vector2(100, 200), Vector2(600, 200), 8.0)
##         rec_stop()
##
## runner.gd adds the shot to /root (it survives zone changes), calls run(), and quits when it returns.
## Every wait counts rendered frames (Movie Maker runs at a fixed 60 fps), never wall-clock time.
## Anything unexpected calls fail(), which prints "@@SHOT FAIL", and the runner exits non-zero.

const FPS := 60.0
const NATIVE := Vector2(480, 270)
const GLYPHS := ["sunda_ka", "sunda_ga", "sunda_nga", "sunda_ca", "sunda_ha", "sunda_pa", "sunda_ba", "sunda_ta",
	"sunda_la", "sunda_ra", "sunda_sa", "jawa_ha", "jawa_na", "jawa_ca", "jawa_ra", "jawa_ka", "jawa_ga",
	"jawa_pa", "jawa_la", "jawa_wa"]
const UI_PARTS := ["hud", "tracker", "arrow", "menu_hint", "banner", "toast", "boss_bar", "saved", "area_title",
	"quest_card", "tutorial", "vignette", "dialogue"]

var G: Node    # /root/Game
var Z: Node    # /root/Zones
var EV: Node   # /root/Events
var frame := 0             # process frames since the shot started
var failed := false
var opts := {}             # from config(), merged over defaults by the runner

# --- recording marks
var _rec_start := -1
var _rec_stop := -1

# --- ui
var _hidden := {}          # UI part -> true while hidden
var _cursor_layer: CanvasLayer
var _cursor: Sprite2D

# --- camera
var _cam: Camera2D
var _cam_pos := Vector2.ZERO        # unsnapped
var _cam_follow: Node2D
var _cam_offset := Vector2.ZERO
var _cam_lerp := 1.0
## Grid the shot camera snaps to, in native pixels. 1.0: whole game pixels (the game's own camera does this).
## 0.25 at 1080p: one screen pixel, smoother slow pans. 0.0: no snap.
var cam_snap := 1.0

# --- hero input
var _move := Vector2.ZERO
var _move_keys := {}
var _mouse_screen := Vector2(-1, -1)   # native screen px the mouse is held at, or
var _mouse_world: Variant = null        # a world point / Node2D it tracks
var _mouse_last := Vector2(-999, -999)
var _drawing := false
var _draw_frames := 0
var god := false
var infinite_sakti := false
var infinite_stamina := false
var no_beats := true       # story beats (auto dialogues) stay off unless a shot turns this off
var _early: Node


## Override: the shot. Await helpers in order; return when the shot is over.
func run() -> void:
	pass


## Override to change defaults: {music: false, sfx: true, ambience: true, locale: "en", max_seconds: 600}
func config() -> Dictionary:
	return {}


func _ready() -> void:
	G = get_node("/root/Game")
	Z = get_node("/root/Zones")
	EV = get_node("/root/Events")
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_priority = 1000            # after the game: camera, UI hiding and mouse win
	_early = _EarlyNode.new()
	_early.shot = self
	_early.process_priority = -1000    # before the game: held keys, cast clock, god mode
	_early.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_early)


class _EarlyNode extends Node:
	var shot
	func _process(_d: float) -> void:
		shot._early_tick()


# ======================================================================================== setup

## Locale, settings, buses. The runner calls this before run().
func _base_setup() -> void:
	TranslationServer.set_locale(str(opts.get("locale", "en")))
	var title: Script = load("res://ui/title.gd")
	title.settings_path = "user://capture_settings.cfg"
	var gs: Script = load("res://ui/game_settings.gd")
	gs.save_value("language", str(opts.get("locale", "en")))
	gs.apply_volumes()
	gs.apply_input()
	set_bus("Music", bool(opts.get("music", false)))
	set_bus("SFX", bool(opts.get("sfx", true)))
	set_bus("Ambience", bool(opts.get("ambience", true)))
	G.hero_name = str(opts.get("hero_name", G.hero_name))
	G.hero_pronoun = str(opts.get("hero_pronoun", G.hero_pronoun))


## Mutes (on=false) or unmutes a bus: "Music", "SFX", "Ambience". Audio creates the buses at boot.
func set_bus(bus: String, on: bool) -> void:
	var i := AudioServer.get_bus_index(bus)
	if i < 0:
		push_warning("shot: no audio bus " + bus)
		return
	AudioServer.set_bus_mute(i, not on)


## A plain new game as `cls` (the prologue's state), then the hero is moved with go(). Does not load a zone.
func new_game(cls := "mage") -> void:
	var c := load("res://data/classes/%s.tres" % cls) as ClassData
	if c == null:
		fail("no class " + cls)
		return
	G.save_path = G.DEMO_SAVE
	G.new_game(c)
	skip_tutorials()


## New game as `cls` and straight into `zone` by `spawn` (any Zones.ZONES key). The story is at its very start:
## use start_demo() when the area should be in its story state.
func start_new(cls := "mage", zone := "desa_purwa", spawn := "") -> void:
	new_game(cls)
	await go(zone, spawn)


## The game's Demo route (ui/demo_route.gd): plays the story up to a checkpoint and places the hero there.
## `query` matches DemoRoute.checkpoints() fields: {index}, or any of {kind, zone, boss, quest}; first match wins.
## List them with list_checkpoints.gd.
func start_demo(query: Dictionary, cls := "mage") -> void:
	var DemoRoute: Script = load("res://ui/demo_route.gd")
	var cps: Array = DemoRoute.checkpoints()
	var cp := {}
	if query.has("index"):
		cp = cps[int(query.index)]
	else:
		for c: Dictionary in cps:
			var ok := true
			for k: String in query:
				if str(c.get(k, "")) != str(query[k]):
					ok = false
			if ok:
				cp = c
				break
	if cp.is_empty():
		fail("no demo checkpoint matches %s" % [query])
		return
	G.demo = true
	G.save_path = G.DEMO_SAVE
	var route: RefCounted = DemoRoute.new(G, Z)
	var ok: bool = route.build(cls, cp)
	for n: String in route.notes:
		print("shot: demo note: ", n)
	if not ok:
		fail("demo route could not reach %s" % [cp])
		return
	skip_tutorials()
	print("shot: demo reached %s %s %s" % [cp.kind, cp.zone, cp.boss])
	route.place(cp)
	await _wait_zone()


## Loads a zone (Zones.ZONES key or scene path) at a spawn id, or at `pos` when given; waits for the fade-in.
func go(zone: String, spawn := "", pos := Vector2.INF) -> void:
	await wait_until(func() -> bool: return not Z._busy, 600, "Zones busy before go()")
	Z.go_to(zone, spawn, pos)
	await wait_frames(2)
	await _wait_zone()
	if Z.current_zone != zone and not zone.begins_with("res://"):
		fail("go(%s) landed in '%s'" % [zone, Z.current_zone])


func _wait_zone() -> void:
	await wait_until(func() -> bool:
		return not Z._busy and get_tree().current_scene != null and hero() != null and Z._fade.modulate.a <= 0.0,
		900, "zone did not finish loading")
	_cam = null
	_cam_follow = null
	await wait_frames(2)


## Lifts the hero to `level` (Ilmu spent the class's way), learns `glyphs` (default all 20) and equips the
## strongest weapon of the class's kind and the heaviest armor in the game. Call before or after a zone loads.
func make_strong(level := 20, glyphs: Array = GLYPHS) -> void:
	var DemoRoute: Script = load("res://ui/demo_route.gd")
	var order: Array = DemoRoute.BUILD.get(G.class_id, ["vit"])
	for _n in 200:
		if G.level() >= level:
			break
		G.add_ilmu(maxi(0, G.level_cost() - G.ilmu))
		if not G.level_up(String(order[int(G.points_spent) % order.size()])):
			break
	var gl := PackedStringArray(G.glyphs_learned)
	for id: String in glyphs:
		if id not in gl:
			gl.append(id)
	G.glyphs_learned = gl
	var c := load("res://data/classes/%s.tres" % G.class_id) as ClassData
	var start := ItemData.by_id(c.start_weapon) if c else null
	var best_w: ItemData = null
	var best_a: ItemData = null
	for f: String in DirAccess.get_files_at("res://data/items/"):
		if not f.ends_with(".tres") and not f.ends_with(".tres.remap"):
			continue
		var it := ItemData.by_id(f.trim_suffix(".remap").trim_suffix(".tres"))
		if it == null:
			continue
		if it.slot == "weapon" and start and it.archetype == start.archetype and (best_w == null or it.damage > best_w.damage):
			best_w = it
		elif it.slot == "armor" and (best_a == null or it.defense > best_a.defense):
			best_a = it
	for it: ItemData in [best_w, best_a]:
		if it:
			if it.id not in G.inventory:
				G.add_item(it.id, false)
			G.equipped[it.slot] = it.id
	G.restore()
	G.changed.emit()
	var h := hero()
	if h:
		h.health.hp = h.health.max_hp
		h.sakti.value = h.sakti.max_value
		h.health.changed.emit(h.health.hp, h.health.max_hp)
		h.sakti.changed.emit(h.sakti.value, h.sakti.max_value)


## Marks every tutorial lesson as done so no pill appears.
func skip_tutorials() -> void:
	var L: Script = load("res://data/lessons.gd")
	for id: String in L.ids():
		G.flags[L.flag(id)] = true
	G.flags["seen_hint_continue"] = true
	G.flags["hint_sande"] = true


## Story flag on, quietly (no save, no beat).
func flag(name: String) -> void:
	G.flags[name] = true


# ======================================================================================== recording

## The first recorded frame is the one drawn at the end of this frame. Frames before it are cut by shoot.sh.
func rec_start() -> void:
	_rec_start = Engine.get_frames_drawn()
	print("@@SHOT rec_start %d" % _rec_start)


## The last recorded frame is the one drawn at the end of the previous frame.
func rec_stop() -> void:
	_rec_stop = Engine.get_frames_drawn()
	print("@@SHOT rec_stop %d" % _rec_stop)


## Prints a marker the edit can use (frame-accurate, relative to rec_start).
func mark(label: String) -> void:
	print("@@SHOT mark %d %s" % [Engine.get_frames_drawn() - maxi(_rec_start, 0), label])


func fail(msg: String) -> void:
	if failed:
		return
	failed = true
	printerr("@@SHOT FAIL " + msg)
	push_error("shot failed: " + msg)
	get_tree().quit(3)


# ======================================================================================== waiting

func wait_frames(n: int) -> void:
	for _i in maxi(n, 0):
		await get_tree().process_frame


## Seconds of footage (frames at 60 fps). Engine.time_scale does not change it: slow motion records longer moves.
func wait_seconds(s: float) -> void:
	await wait_frames(roundi(s * FPS))


## Waits until cond() is true; fails the shot after timeout frames.
func wait_until(cond: Callable, timeout := 600, msg := "wait_until timed out") -> bool:
	for _i in timeout:
		if failed:
			return false
		if cond.call():
			return true
		await get_tree().process_frame
	fail(msg)
	return false


## Engine.time_scale (slow motion). `ramp` seconds of footage to get there (linear). Casting resets it to 1.
func time_scale(scale: float, ramp := 0.0) -> void:
	var from := Engine.time_scale
	var n := roundi(ramp * FPS)
	for i in n:
		Engine.time_scale = lerpf(from, scale, float(i + 1) / n)
		await get_tree().process_frame
	Engine.time_scale = scale


# ======================================================================================== scene access

func zone() -> Node:
	return get_tree().current_scene


func hero() -> Node2D:
	return get_tree().get_first_node_in_group("player") as Node2D


func game_ui() -> Node:
	var z := zone()
	return z.find_child("GameUI", true, false) if z else null


func hud() -> Node:
	var ui := game_ui()
	return ui.get_node_or_null("HUD") if ui else null


## World position of a spawn marker, petilasan, NPC id or node name in the current zone.
func spot(id: String) -> Vector2:
	for grp in ["spawn", "petilasan"]:
		for s in get_tree().get_nodes_in_group(grp):
			if str(s.get("id")) == id:
				return s.global_position
	for n in get_tree().get_nodes_in_group("npc"):
		if str(n.get("npc_id")) == id or n.name == id:
			return n.global_position
	var z := zone()
	var n := z.find_child(id, true, false) if z else null
	if n is Node2D:
		return n.global_position
	fail("no spot '%s' in %s" % [id, Z.current_zone])
	return Vector2.ZERO


## The zone's size in world px.
func map_rect() -> Rect2:
	var z := zone()
	return z.map_rect() if z and z.has_method("map_rect") else Rect2()


## Doc cell -> world px (the centre of that cell's block), as the zone docs and their ASCII maps count.
func cell(x: int, y: int) -> Vector2:
	return zone().cell_pos(Vector2i(x, y))


# ======================================================================================== UI

## Hides the whole HUD (vitals, tracker, arrow, toasts, banners), area titles, quest cards and tutorial pills.
func hide_hud() -> void:
	hide_ui(["hud", "area_title", "quest_card", "tutorial", "dialogue"])


## Shows the HUD again but keeps the noisy parts off: tracker, objective arrow, [Esc] hint, toasts, save icon.
func show_hud(clean := true) -> void:
	show_ui(UI_PARTS)
	if clean:
		hide_ui(["tracker", "arrow", "menu_hint", "toast", "saved", "banner", "area_title", "quest_card", "tutorial"])


## Hides UI parts (UI_PARTS) every frame until show_ui. "vignette" is the soft screen edge of the game look.
func hide_ui(parts: Array) -> void:
	for p: String in parts:
		if p not in UI_PARTS:
			fail("unknown UI part " + p)
		_hidden[p] = true
	_apply_ui()


func show_ui(parts: Array) -> void:
	for p: String in parts:
		if _hidden.has(p):
			_hidden.erase(p)
			for n in _ui_nodes(p):
				n.visible = true


func _ui_nodes(part: String) -> Array:
	var ui := game_ui()
	if ui == null:
		return []
	var h := ui.get_node_or_null("HUD")
	var out := []
	match part:
		"hud": out = [h]
		"tracker": out = [h.get("_tracker_panel")] if h else []
		"arrow": out = [h.get("_arrow"), h.get("_diamond"), h.get("_dist"), h.get("_dist_bg")] if h else []
		"menu_hint": out = [h.get("_menu_hint")] if h else []
		"banner": out = [h.get("_banner_root")] if h else []
		"toast": out = [h.get("_toast_root")] if h else []
		"boss_bar": out = [h.get("_boss_root")] if h else []
		"saved": out = [h.get("_saved"), h.get("_saved_icon")] if h else []
		"area_title": out = [ui.get_node_or_null("AreaTitle")]
		"quest_card": out = [ui.get_node_or_null("QuestCard")]
		"tutorial": out = [ui.get_node_or_null("Tutorial")]
		"vignette": out = [ui.get_node_or_null("Vignette")]
		"dialogue": out = [ui.get_node_or_null("DialogueBox")]
	return out.filter(func(n: Variant) -> bool: return n is CanvasItem or n is CanvasLayer)


func _apply_ui() -> void:
	for p: String in _hidden:
		for n in _ui_nodes(p):
			if n.visible:
				n.visible = false


## A software cursor (the game's own cursor art) drawn into the footage. The OS cursor is never recorded.
func show_cursor(on := true) -> void:
	if on and _cursor == null:
		_cursor_layer = CanvasLayer.new()
		_cursor_layer.layer = 120
		add_child(_cursor_layer)
		_cursor = Sprite2D.new()
		_cursor.texture = load("res://assets/art/ui/cursor.png")
		_cursor.centered = false
		_cursor_layer.add_child(_cursor)
	if _cursor_layer:
		_cursor_layer.visible = on


func hide_cursor() -> void:
	show_cursor(false)


# ======================================================================================== camera

## The shot camera takes over at `at` (world px; default: what the screen shows now). The player camera stays
## on the hero but no longer draws.
func cam_detach(at: Variant = null) -> void:
	var z := zone()
	if _cam == null or not is_instance_valid(_cam):
		_cam = Camera2D.new()
		_cam.name = "ShotCam"
		_cam.process_callback = Camera2D.CAMERA2D_PROCESS_IDLE
		z.add_child(_cam)
	var pc: Camera2D = hero().get_node_or_null("Camera") if hero() else null
	if pc:
		_cam.limit_left = pc.limit_left
		_cam.limit_top = pc.limit_top
		_cam.limit_right = pc.limit_right
		_cam.limit_bottom = pc.limit_bottom
	_cam_pos = at if at != null else (pc.get_screen_center_position() if pc else Vector2.ZERO)
	_cam_follow = null
	_cam_place()
	_cam.make_current()


## Back to the game's own camera on the hero.
func cam_attach() -> void:
	_cam_follow = null
	var pc: Camera2D = hero().get_node_or_null("Camera") if hero() else null
	if pc:
		pc.make_current()
	if _cam:
		_cam.queue_free()
		_cam = null


## Lets the shot camera show past the zone's edge (false) or clamps it to the map (true, the default).
func cam_limits(on: bool) -> void:
	if _cam == null:
		cam_detach()
	if on:
		var r := map_rect()
		_cam.limit_left = int(r.position.x); _cam.limit_top = int(r.position.y)
		_cam.limit_right = int(r.end.x); _cam.limit_bottom = int(r.end.y)
	else:
		_cam.limit_left = -10000000; _cam.limit_top = -10000000
		_cam.limit_right = 10000000; _cam.limit_bottom = 10000000


## Screen centre in world px, now.
func cam_center() -> Vector2:
	return get_viewport().get_camera_2d().get_screen_center_position() if get_viewport().get_camera_2d() else Vector2.ZERO


## Moves the shot camera centre from `from` to `to` over `seconds` of footage. ease: linear | in | out | in_out
## (sine) | smooth (smootherstep). Returns when done.
func cam_pan(from: Vector2, to: Vector2, seconds: float, ease := "in_out") -> void:
	if _cam == null:
		cam_detach(from)
	_cam_follow = null
	var n := maxi(1, roundi(seconds * FPS))
	for i in n + 1:
		_cam_pos = from.lerp(to, ease_t(float(i) / n, ease))
		_cam_place()
		if i < n:
			await get_tree().process_frame


## Pan from wherever the camera is now.
func cam_move_to(to: Vector2, seconds: float, ease := "in_out") -> void:
	if _cam == null:
		cam_detach()
	await cam_pan(_cam_pos, to, seconds, ease)


## Zoom (2.0 = twice as close). Whole numbers keep the pixel grid; others resample the art.
func cam_zoom(z: float, seconds := 0.0, ease := "in_out") -> void:
	if _cam == null:
		cam_detach()
	var from := _cam.zoom.x
	var n := roundi(seconds * FPS)
	for i in n:
		var v := lerpf(from, z, ease_t(float(i + 1) / n, ease))
		_cam.zoom = Vector2(v, v)
		await get_tree().process_frame
	_cam.zoom = Vector2(z, z)


## The shot camera follows `node` (or the hero) with an offset. lerp 1.0: locked on; smaller trails behind.
func cam_follow(node: Node2D = null, offset := Vector2.ZERO, lerp := 1.0) -> void:
	if _cam == null:
		cam_detach()
	_cam_follow = node if node else hero()
	_cam_offset = offset
	_cam_lerp = clampf(lerp, 0.01, 1.0)


func _cam_place() -> void:
	if _cam == null or not is_instance_valid(_cam):
		return
	var p := _cam_pos
	if cam_snap > 0.0:
		p = (p / cam_snap).round() * cam_snap
	_cam.global_position = p


static func ease_t(t: float, kind: String) -> float:
	t = clampf(t, 0.0, 1.0)
	match kind:
		"linear": return t
		"in": return 1.0 - cos(t * PI * 0.5)
		"out": return sin(t * PI * 0.5)
		"smooth": return t * t * t * (t * (t * 6.0 - 15.0) + 10.0)
		_: return 0.5 - 0.5 * cos(t * PI)


# ======================================================================================== mouse

## Holds the mouse at a point of the 480x270 screen (native px).
func mouse_screen(p: Vector2) -> void:
	_mouse_world = null
	_mouse_screen = p
	_warp_now()


## Keeps the mouse over a world point or a node (it follows as the camera moves). The hero aims there.
func aim_at(target: Variant) -> void:
	_mouse_world = target
	_warp_now()


## Faces a direction (aims 40 px that way from the hero).
func face(dir: Vector2) -> void:
	aim_at(hero().global_position + dir.normalized() * 40.0)


## Native screen px of a world point under the current camera.
func world_to_screen(p: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform() * p


func screen_to_world(p: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * p


func _mouse_target() -> Vector2:
	if _mouse_world is Node2D:
		return world_to_screen((_mouse_world as Node2D).global_position) if is_instance_valid(_mouse_world) else _mouse_last
	if _mouse_world is Vector2:
		return world_to_screen(_mouse_world)
	return _mouse_screen


func _warp_now() -> void:
	var p := _mouse_target()
	if p.x < 0.0:
		return
	if p.distance_squared_to(_mouse_last) < 0.0001:
		return
	_mouse_last = p
	var k := get_tree().root.get_final_transform()   # native -> window (the 4x stretch at 1080p)
	Input.warp_mouse(k * p)


# ======================================================================================== hero

## Teleports the hero (world px).
func teleport(p: Vector2) -> void:
	var h := hero()
	h.global_position = p
	h.reset_physics_interpolation()


## Holds a move direction (as the WASD keys would, analog strength). ZERO lets go.
func hold_move(dir: Vector2) -> void:
	_move = dir.limit_length(1.0)


func stop() -> void:
	_move = Vector2.ZERO


## Walks to a world point with the real move input. speed (0.3-1.0) is the stick strength. Fails if stuck.
func walk_to(p: Vector2, speed := 1.0, arrive := 3.0) -> void:
	var h := hero()
	var best := INF
	var since := 0
	var limit := 60 * 60
	for _i in limit:
		if failed:
			return
		var d := p - h.global_position
		if d.length() <= arrive:
			stop()
			return
		_move = d.normalized() * clampf(speed, 0.3, 1.0)
		if d.length() < best - 0.5:
			best = d.length()
			since = 0
		else:
			since += 1
			if since > 50:
				stop()
				fail("hero stuck at %s walking to %s (wall?)" % [h.global_position.round(), p])
				return
		await get_tree().process_frame
	fail("walk_to %s timed out" % p)


## Walks through each point in turn.
func walk_path(points: Array, speed := 1.0) -> void:
	for p: Vector2 in points:
		await walk_to(p, speed)
		if failed:
			return
	stop()


## A dodge roll toward `dir` (the real dodge input with the move keys held).
func dodge(dir: Vector2) -> void:
	var keep := _move
	_move = dir.normalized()
	await wait_frames(2)
	press("dodge")
	await wait_frames(2)
	press("dodge", false)
	await wait_frames(int(0.45 * FPS))
	_move = keep


## `times` melee (or staff/bow) attacks, aimed at `target` (world point or node) when given, `gap` frames apart.
func attack(times := 1, target: Variant = null, gap := 16) -> void:
	if target != null:
		aim_at(target)
		await wait_frames(2)
	for _i in times:
		press("attack")
		await wait_frames(3)
		press("attack", false)
		await wait_frames(maxi(gap - 3, 1))


## Sends an input action the way a key or mouse button would (through Input, so every listener sees it).
func press(action: String, pressed := true) -> void:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = pressed
	e.strength = 1.0 if pressed else 0.0
	Input.parse_input_event(e)


func _apply_move() -> void:
	var want := {"move_right": maxf(_move.x, 0.0), "move_left": maxf(-_move.x, 0.0),
		"move_down": maxf(_move.y, 0.0), "move_up": maxf(-_move.y, 0.0)}
	for a: String in want:
		var s: float = want[a]
		if s > 0.01:
			Input.action_press(a, s)
			_move_keys[a] = true
		elif _move_keys.has(a):
			Input.action_release(a)
			_move_keys.erase(a)


# ======================================================================================== casting

## Casts aksara `glyph_id` exactly as a player would: holds the cast button (time slows), moves the mouse along
## the glyph's stroke template so the ink trail draws, lets go, and the real recogniser picks the spell.
## o: center (native screen px, default above the hero), size (px of the glyph's longer side, 96),
##    seconds (draw time, 1.3), ease ("in_out"), jitter (px, 0.6), template (index, 0), aim_at (world point or
##    node the spell aims at), expect (true: fail the shot unless the drawn glyph is recognised at full power).
## Returns the recogniser's result {glyph, score, power} (glyph is the GlyphData).
func cast_glyph(glyph_id: String, o := {}) -> Dictionary:
	var gd := GlyphData.by_id(glyph_id)
	if gd == null or gd.templates.is_empty():
		fail("no glyph " + glyph_id)
		return {}
	var h := hero()
	var cc: Node = h.get("cast")
	if glyph_id not in G.glyphs_learned:
		var gl := PackedStringArray(G.glyphs_learned)
		gl.append(glyph_id)
		G.glyphs_learned = gl
	var path := stroke_path(gd.templates[clampi(int(o.get("template", 0)), 0, gd.templates.size() - 1)],
		o.get("center", world_to_screen(h.global_position) + Vector2(0, -40)), float(o.get("size", 96.0)))
	if o.has("aim_at"):
		aim_at(o.aim_at)
		await wait_frames(3)
	cc.set("_locked_until", 0)
	var spell := SpellData.for_glyph(glyph_id)
	if spell and h.sakti.value < 100.0:
		h.sakti.value = h.sakti.max_value
		h.sakti.changed.emit(h.sakti.value, h.sakti.max_value)
	var res := {}
	var on_read := func(r: Dictionary) -> void: res.merge(r, true)
	cc.read.connect(on_read)
	var aim_keep: Variant = _mouse_world
	press("cast")
	await wait_frames(1)
	if not cc.drawing:
		cc.read.disconnect(on_read)
		fail("cast did not start (sakti %s, state %s)" % [h.sakti.value, h.state])
		return {}
	_drawing = true
	_draw_frames = 0
	var n := maxi(8, roundi(float(o.get("seconds", 1.3)) * FPS))
	var jit := float(o.get("jitter", 0.6))
	var total := _path_len(path)
	var seed_a := randf() * 100.0
	for i in n + 1:
		var s := ease_t(float(i) / n, str(o.get("ease", "in_out"))) * total
		var p := _point_at(path, s)
		if jit > 0.0 and i > 0 and i < n:
			p += Vector2(sin(seed_a + i * 0.37) + sin(seed_a * 1.7 + i * 0.91) * 0.5,
				cos(seed_a + i * 0.41) + cos(seed_a * 2.3 + i * 0.83) * 0.5) * jit * 0.66
		mouse_screen(p)
		await get_tree().process_frame
	await wait_frames(int(o.get("hold_frames", 3)))   # the pen rests a moment, as hands do
	press("cast", false)
	await wait_frames(2)
	_drawing = false
	cc.read.disconnect(on_read)
	_mouse_world = aim_keep
	var g: GlyphData = res.get("glyph")
	print("shot: cast %s -> %s score %.2f power %.2f" % [glyph_id, g.id if g else "none", float(res.get("score", 0)), float(res.get("power", 0))])
	if bool(o.get("expect", true)) and (g == null or g.id != glyph_id or float(res.get("power", 0)) < 1.0):
		fail("cast %s read as %s (score %.2f power %.2f)" % [glyph_id, g.id if g else "nothing", float(res.get("score", 0)), float(res.get("power", 0))])
	return res


## A template fitted to a box of `size` px (longer side) centred on `center` (native screen px).
static func stroke_path(tpl: PackedVector2Array, center: Vector2, size: float) -> PackedVector2Array:
	var box := Rect2(tpl[0], Vector2.ZERO)
	for q in tpl:
		box = box.expand(q)
	var s := size / maxf(maxf(box.size.x, box.size.y), 1.0)
	var out := PackedVector2Array()
	for q in tpl:
		out.append(center + (q - box.get_center()) * s)
	return out


static func _path_len(p: PackedVector2Array) -> float:
	var l := 0.0
	for i in range(1, p.size()):
		l += p[i - 1].distance_to(p[i])
	return l


static func _point_at(p: PackedVector2Array, s: float) -> Vector2:
	for i in range(1, p.size()):
		var seg := p[i - 1].distance_to(p[i])
		if s <= seg:
			return p[i - 1].lerp(p[i], s / maxf(seg, 0.0001))
		s -= seg
	return p[p.size() - 1]


# ======================================================================================== enemies

## Spawns an enemy scene (entities/enemies/<kind>.tscn, or a res:// path) at a world point. It hunts the hero
## by its own AI as soon as it sees him; asleep=true freezes it until wake().
func spawn_enemy(kind: String, p: Vector2, asleep := false) -> Node2D:
	var path := kind if kind.begins_with("res://") else "res://entities/enemies/%s.tscn" % kind
	var sc := load(path) as PackedScene
	if sc == null:
		fail("no enemy scene " + path)
		return null
	var e := sc.instantiate() as Node2D
	e.position = p
	var parent: Node = zone().get("entities") if zone().get("entities") else zone()
	parent.add_child(e)
	if asleep:
		freeze(e, true)
	return e


## `count` enemies on a ring of `radius` around `center`.
func spawn_ring(kind: String, center: Vector2, count: int, radius := 48.0, asleep := false, phase := 0.0) -> Array:
	var out := []
	for i in count:
		out.append(spawn_enemy(kind, center + Vector2.from_angle(phase + TAU * i / count) * radius, asleep))
	return out


## Freezes (on) or wakes an enemy: its AI and physics stop, it stays drawn.
func freeze(e: Node, on: bool) -> void:
	if is_instance_valid(e):
		e.set_physics_process(not on)
		e.set_process(not on)


func wake(e: Node) -> void:
	freeze(e, false)


## Every enemy, or those within `radius` of `p`.
func enemies(p := Vector2.INF, radius := INF) -> Array:
	return get_tree().get_nodes_in_group("enemy").filter(func(e: Node) -> bool:
		return is_instance_valid(e) and not e.get("dead") and (p == Vector2.INF or (e as Node2D).global_position.distance_to(p) <= radius))


## Removes the zone's own enemies (placed spots and encounters) so a shot sets up its own.
func clear_enemies() -> void:
	for e in get_tree().get_nodes_in_group("enemy"):
		e.queue_free()


# ======================================================================================== per-frame

func _early_tick() -> void:
	frame += 1
	_apply_move()
	var h := hero()
	if h == null:
		return
	if god:
		h.health.hp = h.health.max_hp
	if infinite_sakti and not _drawing:
		h.sakti.value = h.sakti.max_value
	if infinite_stamina:
		h.stamina.value = h.stamina.max_stamina
	if _drawing:
		# The cast's time limit runs on the wall clock, which Movie Maker does not slow: give it footage time.
		_draw_frames += 1
		h.cast.set("_started", Time.get_ticks_msec() - int(_draw_frames * 1000.0 / FPS))
	if no_beats:
		var sb := game_ui().get_node_or_null("StoryBeat") if game_ui() else null
		if sb and not sb.get("_busy"):
			sb.set("_busy", true)


func _process(_d: float) -> void:
	if _cam and is_instance_valid(_cam):
		if _cam_follow and is_instance_valid(_cam_follow):
			_cam_pos = _cam_pos.lerp(_cam_follow.global_position + _cam_offset, _cam_lerp)
		_cam_place()
	_apply_ui()
	_warp_now()
	if _cursor and _cursor_layer.visible:
		_cursor.position = get_viewport().get_mouse_position().round()


func _input(event: InputEvent) -> void:
	# The ink brush thins with pen speed measured on the wall clock; under Movie Maker each frame takes far
	# longer than 1/60 s, so tell it one frame went by.
	if _drawing and event is InputEventMouseMotion:
		var ov: Node = hero().get("cast").get("overlay") if hero() else null
		if ov:
			ov.set("_last_ms", Time.get_ticks_msec() - int(1000.0 / FPS))
