extends "res://video/capture/shot.gd"
## Helpers for the segment 1/2/4 shots (s1_*, s2_*, s4_*). Shots extend this file instead of shot.gd.

# ---------------------------------------------------------------- story state

## The Demo route to any quest step (not only the listed checkpoints): `quest` reaches `step` (0-based index of the
## step that is current), then the hero is placed at the area's entry of `zone`.
func demo_to(quest: String, step: int, zone_id: String, cls := "mage") -> void:
	var DemoRoute: Script = load("res://ui/demo_route.gd")
	var cp := {"kind": "area", "quest": quest, "step": step, "zone": zone_id, "boss": ""}
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
	print("shot: demo reached %s step %d (%s)" % [quest, step, G.quests.get(quest, {})])
	route.place(cp)
	await _wait_zone()


# ---------------------------------------------------------------- English spell names

## The Wiku's class-spell names are Indonesian even in English (SpellVariants.NAMES has no translation). The cast
## result label is rewritten, just before each frame is drawn, to the game's own English spell title
## (tr(SpellData.title): Bolt, Burst, Bind, Heal, ...). Only the label text changes.
var _en_names := {}

func english_spell_names(on := true) -> void:
	_en_names.clear()
	if on:
		var SV: Script = load("res://spells/spell_variants.gd")
		for key: String in SV.NAMES:
			var gid := key.get_slice("/", 0)
			var sp := SpellData.for_glyph(gid)
			var en := tr(sp.title) if sp else ""
			if en != "" and en != str(SV.NAMES[key]):
				_en_names[str(SV.NAMES[key])] = en
		if not RenderingServer.frame_pre_draw.is_connected(_fix_names):
			RenderingServer.frame_pre_draw.connect(_fix_names)
	elif RenderingServer.frame_pre_draw.is_connected(_fix_names):
		RenderingServer.frame_pre_draw.disconnect(_fix_names)


func _fix_names() -> void:
	var h := hero()
	if h == null or h.get("cast") == null:
		return
	var ov: Node = h.cast.get("overlay")
	if ov == null:
		return
	var lb: Label = ov.get("_label")
	if lb == null or lb.text == "":
		return
	for id_name: String in _en_names:
		if lb.text.ends_with(id_name):
			lb.text = lb.text.trim_suffix(id_name) + str(_en_names[id_name])
			return


# ---------------------------------------------------------------- dialogue

func dbox() -> Node:
	return game_ui().get_node_or_null("DialogueBox") if game_ui() else null


func dline_done() -> bool:
	var b := dbox()
	if b == null or not b.is_open():
		return true
	var t: Label = b.get("_text")
	return int(b.get("_hold_until")) == 0 and t.visible_characters >= t.get_total_character_count() and t.text != ""


func dtext() -> String:
	var b := dbox()
	return (b.get("_text") as Label).text if b and b.is_open() else ""


## Waits until the current line is fully typed, holds `hold` seconds, then advances.
func dadvance(hold := 1.5) -> void:
	await wait_until(dline_done, 1200, "dialogue line never finished")
	await wait_seconds(hold)
	press("interact")
	await wait_frames(1)
	press("interact", false)
	await wait_frames(1)


# ---------------------------------------------------------------- staging

## Spawns `kind` asleep at each offset from `c` and returns them.
func spawn_at(kind_list: Array, c: Vector2, offsets: Array) -> Array:
	var out := []
	for i in offsets.size():
		out.append(spawn_enemy(str(kind_list[i % kind_list.size()]), c + offsets[i], true))
	return out


## Every live enemy marches toward `to` at `speed` px/s for `seconds` (AI frozen): a controlled approach that
## never reaches the hero. Faces/animation come from the enemy's own process being off, so it glides; use short.
func approach(foes: Array, to: Vector2, seconds: float, stop_at := 40.0) -> void:
	var n := roundi(seconds * FPS)
	for i in n:
		for f in foes:
			if is_instance_valid(f) and not f.get("dead"):
				var d: Vector2 = to - f.global_position
				if d.length() > stop_at:
					f.global_position += d.normalized() * minf(d.length() - stop_at, 0.0 + float(f.get_meta("spd", 30.0)) / FPS)
		await get_tree().process_frame


func live(foes: Array) -> Array:
	return foes.filter(func(f: Variant) -> bool: return is_instance_valid(f) and not f.get("dead"))


func freeze_all(foes: Array, on: bool) -> void:
	for f in foes:
		freeze(f, on)


# ---------------------------------------------------------------- aimed casts

## cast_glyph() with the spell aimed at `target` (world point or node). shot.gd's own `aim_at` option parks the
## pen on the target before the stroke, so the recorded stroke starts with a long line from there and misreads;
## here the pen starts on the glyph and the cast's aim (read once when the cast begins) is set to the target.
func cast_at(glyph_id: String, target: Variant, o := {}) -> Dictionary:
	o.erase("aim_at")
	var hold: Array = o.get("freeze", [])
	o.erase("freeze")
	freeze_all(hold, true)
	_aim_when_drawing(target)
	var r := await cast_glyph(glyph_id, o)
	freeze_all(live(hold), false)
	return r


func _aim_when_drawing(target: Variant) -> void:
	var cc: Node = hero().get("cast")
	for i in 30:
		await get_tree().process_frame
		if cc.get("drawing"):
			var p: Vector2 = target if target is Vector2 else ((target as Node2D).global_position if is_instance_valid(target) else hero().global_position + Vector2.RIGHT)
			cc.set("aim", (p - hero().global_position).normalized())
			return
