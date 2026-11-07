extends SceneTree
## World scale and dressing (architecture.md 9, Phase 6b), every area in Zones.ZONES: SCALE x SCALE blocks, erosion keeps
## every spot reachable, passage entities cover their whole block, deco never lands on a spot block, exit or path tile,
## the ambience stays under 40 particles, and a rebuild is identical.

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	var zones := root.get_node("Zones")
	var eroded := 0
	var dressed := 0
	for id: String in zones.ZONES:
		if id == "hub":
			continue
		var z := await build(zones.ZONES[id])
		check(z.size == z.doc_size * Zone.SCALE, "%s size %s is not doc %s * %d" % [id, z.size, z.doc_size, Zone.SCALE])
		check(z.cell_pos(Vector2i(1, 1)) == Vector2(Zone.SCALE * 16 * 1.5, Zone.SCALE * 16 * 1.5), "%s cell_pos" % id)
		check(z.deco != null, "%s has no Deco" % id)
		if z.deco == null:
			z.free()
			continue
		# Erosion: every spot reachable before is reachable after.
		var start := z._start_index()
		check(start >= 0, "%s has no spawn spot" % id)
		var base := z._flood(z.grid_base, start)
		var now := z._flood(z.grid, start)
		for dc: Vector2i in z.spot_cells:
			var i: int = dc.y * Zone.SCALE * z.size.x + dc.x * Zone.SCALE
			check(base[i] == 0 or now[i] == 1, "%s: spot '%s' at %s is cut off by erosion" % [id, z.spot_cells[dc], dc])
		for y in z.size.y:
			if z.grid[y] != z.grid_base[y]:
				eroded += 1
				break
		# Path tiles, spot blocks and exits never change or get dressed.
		for y in z.size.y:
			for x in z.size.x:
				if z.grid_base[y][x] == "," and z.grid[y][x] != ",":
					check(false, "%s: path tile %s eroded" % [id, Vector2i(x, y)])
		var bad := 0
		for p: Dictionary in z.deco.placed:
			for c: Vector2i in p.cells:
				var on_path: bool = z.grid_base[c.y][c.x] == ","
				var on_spot: bool = z.spot_cells.has(c / Zone.SCALE)
				if on_path or on_spot or z.deco.clear[c.y * z.size.x + c.x] == 1:
					bad += 1
		check(bad == 0, "%s: %d deco footprint cells sit on a path, spot block or near one" % [id, bad])
		if not z.indoor:
			dressed += 1
			check(z.deco.placed.size() > 30, "%s: only %d props placed" % [id, z.deco.placed.size()])
		# Blocking and detecting entities cover their whole block.
		for n in z.entities.get_children():
			if n.scene_file_path.ends_with("exit.tscn") or n.scene_file_path.ends_with("kabut.tscn"):
				var sh: RectangleShape2D = n.get_node("Shape").shape
				check(sh.size == Vector2.ONE * 16.0 * Zone.SCALE, "%s: %s shape %s does not cover its block" % [id, n.scene_file_path.get_file(), sh.size])
			elif n.scene_file_path.ends_with("shortcut.tscn"):
				var sh: RectangleShape2D = n.get_node("Wall/Shape").shape
				check(sh.size == Vector2.ONE * 16.0 * Zone.SCALE, "%s: shortcut wall %s does not cover its block" % [id, sh.size])
		# Mood.
		var cm := z.get_node_or_null("Mood") as CanvasModulate
		check(cm != null, "%s has no CanvasModulate" % id)
		for ps in z.find_children("*", "CPUParticles2D", true, false):
			check((ps as CPUParticles2D).amount <= 40, "%s: %d particles" % [id, ps.amount])
		check(z.find_children("*", "CPUParticles2D", true, false).size() == 1, "%s wants one ambience emitter" % id)
		z.free()
		await process_frame
	check(eroded >= 20, "only %d areas got eroded edges" % eroded)
	check(dressed >= 30, "only %d outdoor areas were dressed" % dressed)

	# Deterministic by zone_id.
	var a := await build(zones.ZONES["ts_leuweung"])
	var b := await build(zones.ZONES["ts_leuweung"])
	check(a.grid == b.grid and a.deco.placed.size() == b.deco.placed.size(), "rebuilding ts_leuweung differs")
	check(str(a.deco.placed.map(func(p: Dictionary) -> Vector2: return p.pos)) == str(b.deco.placed.map(func(p: Dictionary) -> Vector2: return p.pos)),
		"deco positions differ between builds")
	a.free()
	b.free()
	await process_frame
	quit(1 if fails > 0 else 0)


func build(path: String) -> Zone:
	var z := (load(path) as PackedScene).instantiate() as Zone
	z.process_mode = Node.PROCESS_MODE_DISABLED   # all zones overlap at the origin: no player may walk into another zone's exit
	root.add_child(z)
	await process_frame
	return z
