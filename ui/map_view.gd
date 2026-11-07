class_name MapView extends Control
## The menu's Peta tab: the current area with the hero, every quest target, NPCs, rest shrines (petilasan),
## chests, clues and exits. Hover a marker for its name (ui.md 3).

const GOLD := Color("F2D488")
const EXIT := Color("7fd6e6")
const NPC := Color("f1ead2")
const REST := Color("6fe3b4")
const CHEST := Color("e0a040")
const CLUE := Color("c9a0e8")
const LEGEND_H := 14.0

var _tex: ImageTexture
var _tex_size := Vector2.ZERO
var _hero := Vector2.ZERO
var _feats: Array = []   # [{pos (tiles), kind, name}]
var _pulse := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func _process(d: float) -> void:
	if is_visible_in_tree():
		_pulse += d
		queue_redraw()


## Rebuilds from the running zone. `name_of` maps a zone id to its display name.
func refresh(name_of: Callable) -> void:
	_tex = null
	_feats.clear()
	var z := get_tree().current_scene
	var img := MapRender.image(z)
	if img == null:
		return
	_tex = ImageTexture.create_from_image(img)
	_tex_size = Vector2(img.get_size())
	var pl := get_tree().get_first_node_in_group("player")
	if pl:
		_hero = MapRender.to_tile(pl.global_position)
	var g := get_node("/root/Game")
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


func _map_rect() -> Rect2:
	var area := Vector2(size.x, size.y - LEGEND_H)
	var sc := minf(area.x / maxf(_tex_size.x, 1.0), area.y / maxf(_tex_size.y, 1.0))
	return Rect2((area - _tex_size * sc) / 2.0, _tex_size * sc)


func _to_screen(tile: Vector2) -> Vector2:
	var r := _map_rect()
	return r.position + tile * (r.size.x / _tex_size.x)


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseMotion:
		var best := ""
		var bd := 7.0
		for f in _feats:
			var d: float = _to_screen(f.pos).distance_to(e.position)
			if d < bd:
				bd = d
				best = f.name
		tooltip_text = best


func _marker(p: Vector2, kind: String) -> void:
	match kind:
		"exit":
			draw_rect(Rect2(p - Vector2(2, 2), Vector2(4, 4)), EXIT)
		"npc":
			draw_circle(p, 2.0, Color.BLACK)
			draw_circle(p, 1.3, NPC)
		"rest":
			draw_colored_polygon(PackedVector2Array([p + Vector2(0, -3.5), p + Vector2(3, 2.5), p + Vector2(-3, 2.5)]), Color.BLACK)
			draw_colored_polygon(PackedVector2Array([p + Vector2(0, -2.3), p + Vector2(2, 1.8), p + Vector2(-2, 1.8)]), REST)
		"chest":
			draw_rect(Rect2(p - Vector2(2.5, 2), Vector2(5, 4)), Color.BLACK)
			draw_rect(Rect2(p - Vector2(1.7, 1.2), Vector2(3.4, 2.4)), CHEST)
		"clue":
			draw_string(get_theme_default_font(), p + Vector2(-2, 3), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, CLUE)
		"goal":
			var r := 4.0 + sin(_pulse * 4.0) * 0.8
			draw_colored_polygon(PackedVector2Array([p + Vector2(0, -r - 1), p + Vector2(r + 1, 0), p + Vector2(0, r + 1), p + Vector2(-r - 1, 0)]), Color.BLACK)
			draw_colored_polygon(PackedVector2Array([p + Vector2(0, -r), p + Vector2(r, 0), p + Vector2(0, r), p + Vector2(-r, 0)]), GOLD)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("120e0b"))
	if _tex == null:
		return
	var r := _map_rect()
	draw_texture_rect(_tex, r, false)
	draw_rect(Rect2(r.position - Vector2.ONE, r.size + Vector2(2, 2)), GOLD, false, 1.0)
	var font := get_theme_default_font()
	var seen := {}
	for kind in ["exit", "chest", "clue", "rest", "npc", "goal"]:
		for f in _feats:
			if f.kind != kind:
				continue
			var p := _to_screen(f.pos)
			_marker(p, kind)
			if kind == "exit" and not seen.has(f.name):   # one label per destination
				seen[f.name] = true
				var tp := p + Vector2(4, 3)
				var lw := font.get_string_size(f.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
				if tp.x + lw > size.x - 2:   # near the right edge: label sits left of the marker
					tp.x = p.x - 4 - lw
				draw_string(font, tp, f.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, EXIT)
	var h := _to_screen(_hero)
	draw_circle(h, 3.5, Color.BLACK)
	draw_circle(h, 2.5, Color.WHITE)
	_legend(font)


func _legend(font: Font) -> void:
	var y := size.y - LEGEND_H / 2.0 + 1
	var x := 4.0
	for it in [["you", "UI_LEG_YOU"], ["goal", "UI_LEG_GOAL"], ["npc", "UI_LEG_NPC"], ["rest", "UI_LEG_REST"],
			["chest", "UI_LEG_CHEST"], ["clue", "UI_LEG_CLUE"], ["exit", "UI_LEG_EXIT"]]:
		if it[0] == "you":
			draw_circle(Vector2(x + 3, y), 2.5, Color.WHITE)
		else:
			_marker(Vector2(x + 3, y), it[0])
		var t: String = tr(it[1])
		draw_string(font, Vector2(x + 9, y + 3), t, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1, 1, 1, 0.8))
		x += 14.0 + font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
