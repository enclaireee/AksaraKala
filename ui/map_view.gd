class_name MapView extends Control
## The menu's Peta tab. Two views of the same field book page (.docs/revamp_plan.md 4):
## WORLD  the illustrated map of the six regions and the village (assets/art/ui/map_world.png, tools/gen_map_art.py),
##        regions you have not visited yet are fogged, you and your goal are pins on it.
## AREA   the running area painted from its tile grid (MapRender.painted) with sprite markers for the hero, every quest
##        target, NPCs, rest shrines (petilasan), chests, clues and exits. Hover a marker for its name.
## Click the DUNIA / AREA pill (or press accept) to switch.

const GOLD := UIFx.HEAD
const LEGEND_H := 14.0
const ICON := 11
const ICON_TEX := "res://assets/art/ui/map_icons.png"
const WORLD_TEX := "res://assets/art/ui/map_world.png"
const FOG_TEX := "res://assets/art/ui/map_fog_%s.png"
const IDX := {"you": 0, "goal": 1, "npc": 2, "rest": 3, "chest": 4, "clue": 5, "exit": 6, "boss": 7}
const REGION_PREFIX := {"ts_": "tatar_sunda", "kg_": "keraton_galuh", "mt_": "mataram", "tt_": "tanah_timur",
		"sk_": "segara_kidul", "gk_": "gua_kala"}

var mode := "world"
var _tex: ImageTexture      # the painted area
var _tiles := Vector2.ZERO  # area size in tiles
var _hero := Vector2.ZERO
var _feats: Array = []   # [{pos (tiles), kind, name}]
var _pulse := 0.0
var _world: Texture2D
var _icons: Texture2D
var _fogs := {}
var _seen := {}            # region -> true once visited
var _region := ""          # the running area's region
var _goal_region := ""
var _goal_name := ""
var _zone_name := Callable()
var _pill := [Rect2(), Rect2()]


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_icons = load(ICON_TEX)
	_world = load(WORLD_TEX)


func _process(d: float) -> void:
	if is_visible_in_tree():
		_pulse += d
		queue_redraw()


static func region_of(zone_id: String) -> String:
	if zone_id == "" or zone_id == "desa_purwa" or zone_id == "hub":
		return "desa_purwa"
	for p: String in REGION_PREFIX:
		if zone_id.begins_with(p):
			return REGION_PREFIX[p]
	return ""


func toggle() -> void:
	mode = "area" if mode == "world" else "world"
	queue_redraw()


## Rebuilds from the running zone. `name_of` maps a zone id to its display name.
func refresh(name_of: Callable) -> void:
	_zone_name = name_of
	_tex = null
	_feats.clear()
	var g := get_node("/root/Game")
	var zones := get_node("/root/Zones")
	_region = region_of(zones.current_zone)
	_seen = {"desa_purwa": true}
	if _region != "":
		_seen[_region] = true
	for f: String in g.flags:
		if f.begins_with("seen_zone:"):
			var r := region_of(f.trim_prefix("seen_zone:"))
			if r != "":
				_seen[r] = true
	var m: Dictionary = g.objective_marker()
	_goal_region = region_of(str(m.get("zone", ""))) if not m.is_empty() else ""
	_goal_name = ""
	var z := get_tree().current_scene
	var img := MapRender.painted(z)
	if img == null:
		queue_redraw()
		return
	_tex = ImageTexture.create_from_image(img)
	_tiles = Vector2(img.get_size()) / float(MapRender.PAINT)
	var pl := get_tree().get_first_node_in_group("player")
	if pl:
		_hero = MapRender.to_tile(pl.global_position)
	var goals := _goal_nodes(z, g)
	for n in z.find_children("*", "Node2D", true, false):
		if not n.visible or n == pl:
			continue
		var kind := ""
		var label := ""
		var sp: Script = n.get_script()
		var path: String = sp.resource_path if sp else ""
		if "target_zone" in n and n.target_zone != "":
			kind = "exit"
			label = name_of.call(n.target_zone)
		elif path.ends_with("/npc.gd") and n.get("npc_id") != null:
			kind = "npc"
			label = _npc_name(str(n.npc_id))
		elif path.contains("petilasan"):
			kind = "rest"
			label = tr("UI_LEG_REST")
		elif path.ends_with("/chest.gd"):
			kind = "chest"
			label = tr("UI_LEG_CHEST")
		elif path.ends_with("/clue.gd"):
			kind = "clue"
			label = tr("UI_LEG_CLUE")
		if kind != "":
			_feats.append({"pos": MapRender.to_tile(n.global_position), "kind": kind, "name": label, "node": n})
	for goal in goals:   # quest targets last so they draw on top
		_feats.append({"pos": MapRender.to_tile(goal.node.global_position), "kind": "goal", "name": goal.name})
		_goal_name = goal.name
	queue_redraw()


## Every tracked quest's current target in this zone: [{node, name}] (the sub-goal marker when the step has one).
func _goal_nodes(z: Node, g: Node) -> Array:
	var out := []
	var zone_id: String = z.zone_id if "zone_id" in z else ""
	for id in g._tracked():
		var st: QuestStep = g.current_step(id)
		if st == null:
			continue
		var m: Dictionary = st.marker
		var i: int = g.focus_sub(id)
		if i >= 0 and st.all[i].get("marker", {}) is Dictionary and not st.all[i].get("marker", {}).is_empty():
			m = st.all[i].marker
		if m.is_empty() or m.get("zone", zone_id) != zone_id:
			continue
		for n in z.find_children("*", "Node2D", true, false):
			if n.visible and str(m.get("id", "")) in [str(n.get("id")), str(n.get("npc_id")), str(n.get("trigger_id")), str(n.get("area_id")), str(n.get("item_id")), str(n.get("kind")), str(n.get("clue_id")), str(n.get("memory_id")), n.name]:
				var key: String = (st.all[i].get("objective", "") if i >= 0 else "")
				out.append({"node": n, "name": tr(key if key != "" else st.objective)})
				break
	return out


func _npc_name(id: String) -> String:
	var k := "NPC_%s_NAME" % id.to_upper()
	return tr(k) if tr(k) != k else id.replace("_", " ").capitalize()


func _fog(rid: String) -> Texture2D:
	if not _fogs.has(rid):
		var path := FOG_TEX % rid
		_fogs[rid] = load(path) if ResourceLoader.exists(path) else null
	return _fogs[rid]


func _world_rect() -> Rect2:
	var s := Vector2(432, 184)
	return Rect2(((size - s) / 2.0).floor(), s)


func _area_rect() -> Rect2:
	var area := Vector2(size.x, size.y - LEGEND_H)
	var sc := minf(area.x / maxf(_tiles.x, 1.0), area.y / maxf(_tiles.y, 1.0))
	return Rect2(((area - _tiles * sc) / 2.0).floor(), _tiles * sc)


func _to_screen(tile: Vector2) -> Vector2:
	var r := _area_rect()
	return (r.position + tile * (r.size.x / maxf(_tiles.x, 1.0))).round()


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		for i in 2:
			if _pill[i].has_point(e.position):
				mode = "world" if i == 0 else "area"
				queue_redraw()
				accept_event()
				return
	if e is InputEventMouseMotion:
		var best := ""
		if mode == "area":
			var bd := 7.0
			for f in _feats:
				var d: float = _to_screen(f.pos).distance_to(e.position)
				if d < bd:
					bd = d
					best = f.name
		else:
			var wr := _world_rect()
			var bd := 22.0
			for rid: String in MapRegions.REGIONS:
				var d: float = (wr.position + MapRegions.REGIONS[rid].pos).distance_to(e.position)
				if d < bd:
					bd = d
					best = _region_label(rid)
		tooltip_text = best


func _region_label(rid: String) -> String:
	return tr("UI_ZONE_" + rid.to_upper()) if _seen.get(rid, false) else tr("UI_MAP_UNKNOWN")


## Marker sprite centred on `p` (the icons are 11 px cells, drawn 9 px wide).
func _icon(kind: String, p: Vector2, lift := 0.0) -> void:
	if _icons == null or not IDX.has(kind):
		return
	draw_texture_rect_region(_icons, Rect2((p - Vector2(5, 5) + Vector2(0, lift)).round(), Vector2(ICON, ICON)),
			Rect2(IDX[kind] * ICON, 0, ICON, ICON))


func _label(text: String, p: Vector2, color: Color, centered := true) -> void:
	var font := UIFx.caps_font()
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x
	var at := Vector2(roundf(p.x - (w / 2.0 if centered else 0.0)), roundf(p.y))
	draw_string_outline(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY, 3, UIFx.LACQUER)
	draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY, color)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("0C0A18"))   # night well (ui.md 0.1)
	if mode == "world" and _world != null:
		_draw_world()
	elif _tex != null:
		_draw_area()
	else:
		mode = "world"
		if _world != null:
			_draw_world()
	_draw_pill()
	_legend()


func _draw_world() -> void:
	var wr := _world_rect()
	draw_texture(_world, wr.position)
	for rid: String in MapRegions.REGIONS:
		if not _seen.get(rid, false):
			var f := _fog(rid)
			if f != null:
				draw_texture(f, wr.position)
	for rid: String in MapRegions.REGIONS:
		var p: Vector2 = wr.position + MapRegions.REGIONS[rid].pos
		var here := rid == _region
		var col := UIFx.ACCENT if here else (UIFx.HEAD if _seen.get(rid, false) else UIFx.DIM)
		_label(_region_label(rid) if _seen.get(rid, false) else "???", p, col)
	if _region != "" and MapRegions.REGIONS.has(_region):
		var hp: Vector2 = wr.position + MapRegions.REGIONS[_region].pos + Vector2(0, 12)
		_icon("you", hp, sin(_pulse * 3.0) * 1.2)
	if _goal_region != "" and MapRegions.REGIONS.has(_goal_region):
		var gp: Vector2 = wr.position + MapRegions.REGIONS[_goal_region].pos + Vector2(12 if _goal_region == _region else 0, -12)
		var halo := 7.0 + sin(_pulse * 4.0) * 1.5
		draw_arc(gp, halo, 0.0, TAU, 16, Color(UIFx.WARM, 0.55), 1.0)
		_icon("goal", gp, sin(_pulse * 4.0) * 1.0)


func _draw_area() -> void:
	var r := _area_rect()
	draw_texture_rect(_tex, r, false)
	draw_rect(Rect2(r.position - Vector2.ONE, r.size + Vector2(2, 2)), UIFx.LINE_DIM, false, 1.0)
	var font := UIFx.body_font()
	var seen := {}
	for kind in ["exit", "chest", "clue", "rest", "npc", "goal"]:
		for f in _feats:
			if f.kind != kind:
				continue
			var p := _to_screen(f.pos)
			if kind == "goal":
				var halo := 6.0 + sin(_pulse * 4.0) * 1.2
				draw_arc(p, halo, 0.0, TAU, 14, Color(UIFx.WARM, 0.6), 1.0)
			_icon(kind, p, sin(_pulse * 4.0) * 1.0 if kind == "goal" else 0.0)
			if kind == "exit" and not seen.has(f.name):   # one label per destination
				seen[f.name] = true
				var tp := p + Vector2(7, 4)
				var lw := font.get_string_size(f.name, HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x
				if tp.x + lw > size.x - 2:   # near the right edge: label sits left of the marker
					tp.x = p.x - 7 - lw
				_label(f.name, tp, UIFx.ACCENT, false)
	var h := _to_screen(_hero)
	_icon("you", h, sin(_pulse * 3.0) * 1.0)


## DUNIA | AREA switch, top left, an ink pill with the active half lit.
func _draw_pill() -> void:
	var names := [tr("UI_MAP_WORLD"), tr("UI_MAP_AREA")]
	var font := UIFx.caps_font()
	var x := 6.0
	var rect := Rect2(x, 6, 0, 13)
	var widths := []
	for n: String in names:
		widths.append(font.get_string_size(n.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x + 10.0)
	rect.size.x = widths[0] + widths[1] + 3.0
	draw_style_box(UIFx.ink_box(1), rect)
	var cx := x + 2.0
	for i in 2:
		var seg := Rect2(cx, 8, widths[i], 9)
		_pill[i] = Rect2(seg.position - Vector2(1, 2), seg.size + Vector2(2, 4))
		var on := (mode == "world") == (i == 0)
		if on:
			draw_rect(seg, Color(UIFx.ACCENT, 0.22))
			draw_rect(Rect2(seg.position.x, seg.end.y - 1, seg.size.x, 1), UIFx.ACCENT)
		draw_string(font, Vector2(seg.position.x + 5, seg.position.y + 8), names[i].to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY, UIFx.HEAD if on else UIFx.DIM)
		cx += widths[i] + 3.0


func _legend() -> void:
	var items := [["you", "UI_LEG_YOU"], ["goal", "UI_LEG_GOAL"]]
	if mode == "area":
		items += [["npc", "UI_LEG_NPC"], ["rest", "UI_LEG_REST"], ["chest", "UI_LEG_CHEST"], ["clue", "UI_LEG_CLUE"], ["exit", "UI_LEG_EXIT"]]
	var font := UIFx.body_font()
	var total := 6.0
	var texts := []
	for it in items:
		var t: String = tr(it[1])
		texts.append(t)
		total += 16.0 + font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x
	var bar := Rect2(4, size.y - 16, total, 14)
	draw_style_box(UIFx.ink_box(1), bar)
	var x := bar.position.x + 6.0
	var y := bar.position.y + 7.0
	for i in items.size():
		_icon(items[i][0], Vector2(x + 5, y))
		draw_string(font, Vector2(x + 14, y + 4), texts[i], HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY, UIFx.TEXT)
		x += 16.0 + font.get_string_size(texts[i], HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x
