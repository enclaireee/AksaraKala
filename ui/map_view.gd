class_name MapView extends Control
## The menu's Peta tab. Two views of the same field book page (.docs/revamp_plan.md 4):
## WORLD  the illustrated map of the six regions and the village (assets/art/ui/map_world.png, tools/gen_map_art.py),
##        regions you have not visited yet are fogged, you and your goal are pins on it.
## AREA   the running area painted from its tile grid (MapRender.painted) with sprite markers for the hero, every quest
##        target, NPCs, rest shrines (petilasan), chests, clues and exits. Hover a marker for its name.
## Click the DUNIA / AREA pill (or press accept) to switch.

const GOLD := UIFx.HEAD
const LEGEND_H := 18.0   # strip below the map for the legend bar
const TOP_H := 17.0      # strip above the map for the WORLD / AREA pill (15 tall at y 1)
const ICON := 11
const ICON_TEX := "res://assets/art/ui/map_icons.png"
const WORLD_TEX := "res://assets/art/ui/map_world.png"
const FOG_TEX := "res://assets/art/ui/map_fog_%s.png"
const IDX := {"you": 0, "goal": 1, "npc": 2, "rest": 3, "chest": 4, "clue": 5, "exit": 6, "boss": 7}
const REGION_PREFIX := {"ts_": "tatar_sunda", "kg_": "keraton_galuh", "mt_": "mataram", "tt_": "tanah_timur",
		"sk_": "segara_kidul", "gk_": "gua_kala"}

var mode := "area"
var _tex: ImageTexture      # the painted area
var _tiles := Vector2.ZERO  # area size in tiles
var _hero := Vector2.ZERO
var _feats: Array = []   # [{pos (tiles), kind, name}]
var _pulse := 0.0
var _world: Texture2D
var _icons: Texture2D
var _halo_tex: Texture2D = load("res://assets/art/ui/map_halo.png")
var _fogs := {}
var _seen := {}            # region -> true once visited
var _region := ""          # the running area's region
var _goal_region := ""
var _goal_name := ""
var _zone_name := Callable()
var _pill := [Rect2(), Rect2()]
var _redraw_t := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	_icons = load(ICON_TEX)
	_world = load(WORLD_TEX)


func _process(d: float) -> void:
	if is_visible_in_tree():
		_pulse += d
		_redraw_t += d
		if _redraw_t >= 0.08:
			_redraw_t = 0.0
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


## Every tracked quest's current target in this zone: [{node, name}] (falls back to next visible sub-goal or st.marker).
func _goal_nodes(z: Node, g: Node) -> Array:
	var out := []
	var zone_id: String = z.zone_id if "zone_id" in z else ""
	for id in g._tracked():
		var st: QuestStep = g.current_step(id)
		if st == null:
			continue
		var found: Node2D = null
		var key := ""
		var i: int = g.focus_sub(id)
		if i >= 0:
			var sm: Dictionary = g._sub_marker(st, st.all[i])
			found = _find_goal_node(z, g, sm, zone_id)
			if found != null:
				key = str(st.all[i].get("objective", ""))
		if found == null and not st.all.is_empty():
			for j in st.all.size():
				if j == i or g._all_bit(id, j):
					continue
				var smj: Dictionary = g._sub_marker(st, st.all[j])
				found = _find_goal_node(z, g, smj, zone_id)
				if found != null:
					key = str(st.all[j].get("objective", ""))
					break
		if found == null:
			found = _find_goal_node(z, g, st.marker, zone_id)
		if found != null:
			out.append({"node": found, "name": tr(key if key != "" else st.objective)})
	return out


func _find_goal_node(z: Node, g: Node, m: Dictionary, zone_id: String) -> Node2D:
	if m.is_empty():
		return null
	var mz := str(m.get("zone", zone_id))
	if mz != "" and mz != zone_id:
		return null
	var tid := str(m.get("id", ""))
	if tid == "":
		return null
	for n in z.find_children("*", "Node2D", true, false):
		if not n.visible:
			continue
		if "cond" in n and str(n.cond) != "" and not g.check(str(n.cond)):
			continue
		if tid in [str(n.get("id")), str(n.get("npc_id")), str(n.get("trigger_id")), str(n.get("area_id")), str(n.get("item_id")), str(n.get("kind")), str(n.get("clue_id")), str(n.get("memory_id")), n.name]:
			return n
	return null


func _npc_name(id: String) -> String:
	var k := "NPC_%s_NAME" % id.to_upper()
	return tr(k) if tr(k) != k else id.replace("_", " ").capitalize()


func _fog(rid: String) -> Texture2D:
	if not _fogs.has(rid):
		var path := FOG_TEX % rid
		_fogs[rid] = load(path) if ResourceLoader.exists(path) else null
	return _fogs[rid]


func _world_rect() -> Rect2:
	var s := Vector2(432, 184)   # the art is 184 tall, the view is shorter: crop 3 px at the top, the rest at the foot
	return Rect2(Vector2(floorf((size.x - s.x) / 2.0), -3.0 if size.y < s.y else floorf((size.y - s.y) / 2.0)), s)


func _area_rect() -> Rect2:
	var area := Vector2(size.x, size.y - LEGEND_H - TOP_H)
	var sc := minf(area.x / maxf(_tiles.x, 1.0), area.y / maxf(_tiles.y, 1.0))
	return Rect2(((area - _tiles * sc) / 2.0).floor() + Vector2(0, TOP_H), _tiles * sc)


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
	draw_string_outline(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY, 1, UIFx.LACQUER)
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


## The goal halo: a two-frame pixel ring strip (small, large) that pulses with the icon.
func _halo(at: Vector2) -> void:
	var f := 0 if sin(_pulse * 4.0) < 0.0 else 1
	draw_texture_rect_region(_halo_tex, Rect2((at - Vector2(9, 9)).round(), Vector2(18, 18)), Rect2(f * 18, 0, 18, 18))


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
		hp.y = minf(hp.y, size.y - 7.0)   # the foot of the art is cropped: keep the pin on screen
		_icon("you", hp, sin(_pulse * 3.0) * 1.2)
	if _goal_region != "" and MapRegions.REGIONS.has(_goal_region):
		var gp: Vector2 = wr.position + MapRegions.REGIONS[_goal_region].pos + Vector2(12 if _goal_region == _region else 0, -12)
		gp.y = clampf(gp.y, 10.0, size.y - 10.0)
		_halo(gp)
		_icon("goal", gp, sin(_pulse * 4.0) * 1.0)


func _draw_area() -> void:
	var r := _area_rect()
	draw_texture_rect(_tex, r, false)
	draw_rect(Rect2(r.position - Vector2.ONE, r.size + Vector2(2, 2)), UIFx.LINE_DIM, false, 1.0)
	var seen := {}
	var taken: Array[Rect2] = []   # label boxes and marker boxes already on the map: labels dodge them
	var h := _to_screen(_hero)
	taken.append(Rect2(h - Vector2(6, 6), Vector2(12, 12)))
	for f in _feats:
		taken.append(Rect2(_to_screen(f.pos) - Vector2(6, 6), Vector2(12, 12)))
	for kind in ["exit", "chest", "clue", "rest", "npc", "goal"]:
		for f in _feats:
			if f.kind != kind:
				continue
			var p := _to_screen(f.pos)
			if kind == "goal":
				_halo(p)
			_icon(kind, p, sin(_pulse * 4.0) * 1.0 if kind == "goal" else 0.0)
			if kind == "exit" and not seen.has(f.name):   # one label per destination
				seen[f.name] = true
				var lw := UIFx.caps_font().get_string_size(f.name, HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x   # the font _label draws with
				var own := Rect2(p - Vector2(6, 6), Vector2(12, 12))
				var best := Vector2.ZERO
				var best_hits := 99
				# right of the marker, left of it, then centred below and above; the first spot that is clear wins
				for c in [Vector2(7, 4), Vector2(-7 - lw, 4), Vector2(-lw / 2.0, 17), Vector2(-lw / 2.0, -8), Vector2(7, 17), Vector2(-7 - lw, 17), Vector2(7, -8)]:
					var tp: Vector2 = p + c
					tp.x = clampf(tp.x, r.position.x + 2, maxf(r.end.x - 2 - lw, r.position.x + 2))   # labels stay inside the map
					tp.y = clampf(tp.y, r.position.y + 10, r.end.y - 3)
					var box := Rect2(tp.x, tp.y - 10, lw, 13)
					var hits := 0
					for t in taken:
						if t.intersects(box) and t != own:
							hits += 1
					if hits < best_hits:
						best_hits = hits
						best = tp
						if hits == 0:
							break
				taken.append(Rect2(best.x, best.y - 10, lw, 13))
				_label(f.name, best, UIFx.ACCENT, false)
	_icon("you", h, sin(_pulse * 3.0) * 1.0)


## DUNIA | AREA switch, top left, an ink pill with the active half lit.
func _draw_pill() -> void:
	var names := [tr("UI_MAP_WORLD"), tr("UI_MAP_AREA")]
	var font := UIFx.caps_font()
	var x := 6.0
	var rect := Rect2(x, 1, 0, 15)
	var widths := []
	for n: String in names:
		widths.append(font.get_string_size(n.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x + 10.0)
	rect.size.x = widths[0] + widths[1] + 3.0
	draw_style_box(UIFx.ink_box(1), rect)
	var cx := x + 2.0
	for i in 2:
		var seg := Rect2(cx, 3, widths[i], 11)   # cap 9 + 1 above and below
		_pill[i] = Rect2(seg.position - Vector2(1, 2), seg.size + Vector2(2, 4))
		var on := (mode == "world") == (i == 0)
		if on:
			draw_rect(seg, Color(UIFx.ACCENT, 0.22))
			draw_rect(Rect2(seg.position.x, seg.end.y - 1, seg.size.x, 1), UIFx.ACCENT)
		draw_string(font, Vector2(seg.position.x + 5, seg.position.y + 10), names[i].to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY, UIFx.HEAD if on else UIFx.DIM)
		cx += widths[i] + 3.0


func _legend() -> void:
	var items := [["you", "UI_LEG_YOU"], ["goal", "UI_LEG_GOAL"]]
	if mode == "area":
		items += [["npc", "UI_LEG_NPC"], ["rest", "UI_LEG_REST"], ["chest", "UI_LEG_CHEST"], ["clue", "UI_LEG_CLUE"], ["exit", "UI_LEG_EXIT"]]
	var font := UIFx.body_font()
	var total := 8.0
	var texts := []
	for it in items:
		var t: String = tr(it[1])
		texts.append(t)
		total += 14.0 + font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x
	var bar := Rect2(4, size.y - 16, minf(total, size.x - 8.0), 14)
	draw_style_box(UIFx.ink_box(1), bar)
	var x := bar.position.x + 6.0
	var y := bar.position.y + 7.0   # icon centre; the baseline below puts cap rows 3-11 of the 14 px bar
	for i in items.size():
		_icon(items[i][0], Vector2(x + 5, y))
		draw_string(font, Vector2(x + 12, y + 5), texts[i], HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY, UIFx.TEXT)
		x += 14.0 + font.get_string_size(texts[i], HORIZONTAL_ALIGNMENT_LEFT, -1, UIFx.BODY).x
