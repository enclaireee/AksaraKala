extends SceneTree
## Town life test (architecture.md 9). Fixture zone: path, grass, fences, gardens, stalls, a house and a pond.
## Exits 0 on pass and prints only failures.

const TownLifeS := preload("res://zones/town_life.gd")

var fails := 0


class FakeZone extends Node2D:
	var zone_id := "fixture_a"
	var size := Vector2i.ZERO
	var grid: Array[String] = []
	var claimed := {}
	var entities: Node2D

	func region_key() -> String:
		return "sunda"


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _make_grid(w: int, hh: int) -> Array[String]:
	var rows: Array[String] = []
	for y in hh:
		var row := ""
		for x in w:
			var c := "."
			if y == hh / 2 or x == w / 2:
				c = ","
			elif y == 5 and x >= 4 and x <= 14:
				c = "-"
			elif y >= 8 and y <= 9 and x >= 4 and x <= 8:
				c = "'"
			elif y == 12 and x >= 20 and x <= 24:
				c = "{"
			elif y >= 3 and y <= 6 and x >= 30 and x <= 36:
				c = "["
			elif y >= 20 and y <= 23 and x >= 40 and x <= 46:
				c = "~"
			elif x == 0 or y == 0 or x == w - 1 or y == hh - 1:
				c = "#"
			row += c
		rows.append(row)
	return rows


func _zone(id: String, w: int, hh: int) -> FakeZone:
	var z := FakeZone.new()
	z.zone_id = id
	z.size = Vector2i(w, hh)
	z.grid = _make_grid(w, hh)
	z.entities = Node2D.new()
	z.add_child(z.entities)
	root.add_child(z)
	return z


func _initialize() -> void:
	await process_frame
	run()
	await process_frame
	quit(1 if fails > 0 else 0)


func _cell(p: Vector2) -> Vector2i:
	return Vector2i(int(floorf(p.x / 16.0)), int(floorf(p.y / 16.0)))


func run() -> void:
	# 1. spawn on walkable cells only, never on claimed ones
	var z := _zone("fixture_a", 60, 34)
	var pre := {}
	for cell in [Vector2i(10, 17), Vector2i(11, 17), Vector2i(30, 12), Vector2i(31, 12), Vector2i(30, 17), Vector2i(31, 17)]:
		z.claimed[cell] = true
		pre[cell] = true
	var life: Node2D = TownLifeS.new()
	z.entities.add_child(life)
	life.build(z)
	check(life.villagers.size() >= 2, "villagers spawn (%d)" % life.villagers.size())
	check(life.animals.size() >= 2, "animals spawn (%d)" % life.animals.size())
	for n: Node2D in life.ground_things():
		var c := _cell(n.position)
		var ch: String = z.grid[c.y][c.x]
		check(ch in [".", ",", "_"], "%s stands on walkable cell %s (%s)" % [n.name, c, ch])
		check(not pre.has(c), "%s not on a pre-claimed cell %s" % [n.name, c])
	for n: Node2D in life.villagers + life.animals:
		check(not z.claimed.has(_cell(n.position)), "%s not on a claimed cell" % n.name)
	# dressing: fences, gardens and stalls are drawn and claimed
	var items := 0
	for ch in life.get_children():
		if ch is AmbientBatch:
			items += ch.items.size()
	if AmbientBatch.tex("fences") != null:
		check(items >= 11 + 10 + 5, "fence, garden and stall tiles are batched (%d)" % items)
	check(z.claimed.has(Vector2i(6, 5)) and z.claimed.has(Vector2i(5, 8)) and z.claimed.has(Vector2i(22, 12)), "dressing cells are claimed")
	var kinds := {}
	for l in life.layout:
		kinds[l.split(":")[0].substr(0, 1)] = true
	check(life.live_count() <= TownLifeS.MAX_LIVE, "live count within cap")

	# 2. the count cap on a big town
	var zb := _zone("fixture_big", 120, 68)
	var big: Node2D = TownLifeS.new()
	zb.entities.add_child(big)
	big.build(zb)
	check(big.live_count() <= 60, "big town live count %d <= 60" % big.live_count())
	check(big.live_count() >= 30, "big town is lively (%d)" % big.live_count())

	# 3. determinism
	var z2 := _zone("fixture_a", 60, 34)
	for cell in pre:
		z2.claimed[cell] = true
	var life2: Node2D = TownLifeS.new()
	z2.entities.add_child(life2)
	life2.build(z2)
	check(life.layout == life2.layout and life.layout.size() > 0, "same zone_id gives the same layout")
	var z3 := _zone("fixture_other", 60, 34)
	var life3: Node2D = TownLifeS.new()
	z3.entities.add_child(life3)
	life3.build(z3)
	check(life3.layout != life.layout, "another zone_id gives another layout")

	# 4. a chicken moves away when the player comes near
	var player := Node2D.new()
	player.add_to_group("player")
	root.add_child(player)
	var start := Vector2(20 * 16 + 8, 20 * 16 + 8)
	var hen: Node2D = life._spawn_animal("chicken", start)
	hen.set_process(false)
	player.global_position = z.to_global(life.to_global(start) - life.global_position + Vector2(10, 0)) if false else life.to_global(start + Vector2(10, 0))
	var d0 := hen.position.distance_to(life.player_pos())
	for _i in 30:
		hen.step(0.05)
	var d1 := hen.position.distance_to(life.player_pos())
	check(d0 < 28.0 and d1 > d0 + 10.0, "chicken flees the player (%.1f -> %.1f)" % [d0, d1])
	check(life.can_walk(hen.position), "fleeing chicken stays on walkable ground")

	# 5. a villager pauses and steps aside near the player
	var vlg: Node2D = life._spawn_villager(0, start + Vector2(0, 48))
	vlg.set_process(false)
	player.global_position = life.to_global(vlg.position + Vector2(6, 0))
	for _i in 20:
		vlg.step(0.05)
	check(vlg.position.distance_to(life.player_pos()) >= 6.0, "villager does not stay inside the player")
	check(vlg.state == 6 or vlg.state == 0, "villager paused or resumed near the player")

	# 6. far things stop processing
	player.global_position = life.to_global(Vector2(-5000, -5000))
	life._poll = 0.0
	life._process(0.0)
	var off := 0
	for n: Node2D in life.villagers:
		if not n.is_processing():
			off += 1
	check(off == life.villagers.size(), "far villagers stop processing")
	for n in [z, zb, z2, z3, player]:
		n.free()
