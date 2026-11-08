extends SceneTree
## Per-area scale and the town chars (architecture.md 9, Phase 6c): an area overriding area_scale() to 1 builds at 1x,
## `[ - ' {` collide and are painted as grass, claimed cells are left alone by deco, the town modules are called when
## they exist, and the ground has variants with no repeated neighbours.

var fails := 0
const TOWN := "res://tests/fixtures/zone_town.tscn"


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func solid_at(z: Zone, cell: Vector2i) -> bool:
	var q := PhysicsPointQueryParameters2D.new()
	q.position = Vector2(cell * 16) + Vector2(8, 8)
	q.collision_mask = 1
	return not z.get_world_2d().direct_space_state.intersect_point(q).is_empty()


func make(id: String, claim: Array[Vector2i] = []) -> Zone:
	var z := (load(TOWN) as PackedScene).instantiate() as Zone
	z.zone_id = id
	for c in claim:
		z.claimed[c] = true
	z.process_mode = Node.PROCESS_MODE_DISABLED
	root.add_child(z)
	return z


func _initialize() -> void:
	await process_frame
	check(Zone.SCALE == 2 and Zone.TOWNS.size() == 6, "defaults")
	var z := make("fixture_town")
	await process_frame
	await physics_frame
	await physics_frame
	check(z.area_scale() == 1 and z.k == 1, "fixture scale %d k %d" % [z.area_scale(), z.k])
	check(z.size == Vector2i(30, 17) and z.size == z.doc_size, "1x size %s doc %s" % [z.size, z.doc_size])
	check(z.cell_pos(Vector2i(3, 3)) == Vector2(3 * 16 + 8, 3 * 16 + 8), "1x cell_pos %s" % z.cell_pos(Vector2i(3, 3)))
	check(not z.is_town() and z.region_key() == "sunda", "fixture is not a town, region %s" % z.region_key())
	for c in [Vector2i(10, 2), Vector2i(13, 2), Vector2i(11, 12), Vector2i(17, 12), Vector2i(23, 12)]:
		check(solid_at(z, c), "town char at %s does not collide" % c)
		check(z.tiles.get_cell_atlas_coords(c).x == 0, "town char at %s is not painted as grass: %s" % [c, z.tiles.get_cell_atlas_coords(c)])
	for c in [Vector2i(9, 2), Vector2i(14, 2), Vector2i(14, 12), Vector2i(5, 8), Vector2i(3, 3)]:
		check(not solid_at(z, c), "open cell %s collides" % c)
	check(z.grid[2].substr(10, 4) == "[[[[" and z.grid[12].substr(22, 2) == "{{", "grid keeps the town chars")
	z.free()
	await process_frame

	# A real town id at 1x: dressed, no erosion, claimed cells skipped, ground variety, modules called when present.
	var cl: Array[Vector2i] = [Vector2i(20, 5), Vector2i(21, 5)]
	var t := make("ts_kampung", cl)
	await process_frame
	await physics_frame
	check(t.is_town() and t.region_key() == "sunda", "ts_kampung is a town: %s" % t.region_key())
	check(t.grid == t.grid_base, "a 1x town is not eroded")
	check(t.deco != null and t.deco.placed.size() > 0, "town has no deco")
	if t.deco:
		for p: Dictionary in t.deco.placed:
			for c: Vector2i in p.cells:
				check(not t.claimed.has(c), "deco prop %s on claimed cell %s" % [p.name, c])
				check("[-'{".find(t.grid[c.y][c.x]) < 0, "deco prop %s on town char at %s" % [p.name, c])
		check(t.deco.get_node_or_null("GroundTiles") != null, "no ground layer (run the import?)")
		check(t.deco.ground_layers[3].get_cell_source_id(Vector2i(20, 5)) == -1, "decal on a claimed cell")
		var same := 0
		var cells := 0
		for y in range(1, t.size.y):
			for x in range(1, t.size.x):
				var i: int = y * t.size.x + x
				if t.deco.ground_mat[i] == 1 and t.deco.ground_mat[i - 1] == 1:
					cells += 1
					if t.deco.ground_var[i] == t.deco.ground_var[i - 1]:
						same += 1
		check(cells > 100 and same == 0, "grass neighbours repeat a variant: %d of %d" % [same, cells])
		var seen := {}
		for i in t.deco.ground_var.size():
			if t.deco.ground_mat[i] == 1:
				seen[t.deco.ground_var[i]] = true
		check(seen.size() == 8, "grass uses %d of 8 variants" % seen.size())
		check(t.deco.ground_layers[1].get_used_cells().size() > 0, "no path edge pieces next to the lane")
	for pair in [["res://zones/buildings.gd", "Buildings"], ["res://zones/town_life.gd", "TownLife"]]:
		var n := t.entities.get_node_or_null(pair[1])
		if ResourceLoader.exists(pair[0]):
			check(n != null and n is Node2D, "%s exists but %s was not added under Entities" % [pair[0], pair[1]])
		else:
			check(n == null, "%s added without its script" % pair[1])
	t.free()
	await process_frame
	quit(1 if fails > 0 else 0)
