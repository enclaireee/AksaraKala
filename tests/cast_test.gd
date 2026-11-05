extends SceneTree
## CastController: sakti gate, lockout, success cost and spawn, fizzles, and every exit restores time scale (spells.md 1, 9).

var fails := 0
var p: Player
var c: CastController
var world: Node2D


func _initialize() -> void:
	root.get_node("Game").glyphs_learned = PackedStringArray(["sunda_ka", "sunda_ga", "sunda_nga"])   # quests teach them in play
	world = Node2D.new()
	root.add_child(world)
	p = load("res://entities/player/player.tscn").instantiate()
	world.add_child(p)
	await process_frame
	c = p.cast
	var t := p.tuning

	# Gate: below 15 sakti nothing starts and the gauge flashes.
	var blocked := [0]
	c.blocked.connect(func() -> void: blocked[0] += 1)
	p.sakti.value = t.cast_min_sakti - 1.0
	press("cast")
	check(not c.drawing and Engine.time_scale == 1.0 and blocked[0] == 1, "cast started below the sakti gate")

	# Start: slow-mo. A click-sized stroke cancels at no cost and locks out for a moment.
	p.sakti.value = 50.0
	press("cast")
	check(c.drawing and is_equal_approx(Engine.time_scale, t.cast_time_scale), "cast did not start slow-mo")
	move(Vector2(240, 135)); move(Vector2(244, 137))
	release_cast()
	check(not c.drawing and Engine.time_scale == 1.0, "short stroke did not cancel")
	check(p.sakti.value == 50.0, "cancel cost sakti")
	press("cast")
	check(not c.drawing and blocked[0] == 2, "cast started inside the lockout")
	c._locked_until = 0

	# Success: a clean Ka casts Bolt, spends 15, spawns it aimed where the cast began.
	p.aim_dir = Vector2.UP
	var before := world.get_child_count()
	press("cast")
	p.aim_dir = Vector2.RIGHT   # the mouse moves while drawing; the spell keeps the start aim
	draw("sunda_ka")
	release_cast()
	check(Engine.time_scale == 1.0, "success left slow-mo on")
	check(p.sakti.value == 35.0, "Bolt cost %s, not 15" % (50.0 - p.sakti.value))
	check(world.get_child_count() == before + 1, "no spell was spawned")
	var bolt: Node = world.get_child(world.get_child_count() - 1)
	check(bolt.get("direction") == Vector2.UP and bolt.get("power") == 1.0, "spell got direction %s power %s" % [bolt.get("direction"), bolt.get("power")])
	bolt.queue_free()

	# Fizzle: nothing learned matches. No cost, lockout.
	var game: Node = root.get_node("Game")
	var learned: PackedStringArray = game.glyphs_learned
	game.glyphs_learned = PackedStringArray()
	press("cast"); draw("sunda_ka"); release_cast()
	check(p.sakti.value == 35.0 and Engine.time_scale == 1.0, "fizzle cost sakti or left slow-mo on")
	press("cast")
	check(not c.drawing, "no lockout after a fizzle")
	game.glyphs_learned = learned
	c._locked_until = 0

	# Not enough for the matched spell (Ward costs 25): fizzle, no cost.
	p.sakti.value = 20.0
	before = world.get_child_count()
	press("cast"); draw("sunda_ga"); release_cast()
	check(p.sakti.value == 20.0 and world.get_child_count() == before, "Ward cast without enough sakti")
	c._locked_until = 0

	# Every other exit restores time scale: draw limit, Esc, dodge, death, leaving the tree.
	p.sakti.value = 100.0
	press("cast"); c._started -= int(t.cast_draw_limit * 1000.0) + 10
	await process_frame
	check(not c.drawing and Engine.time_scale == 1.0, "draw limit did not cancel")
	for a in ["pause", "dodge"]:
		c._locked_until = 0
		press("cast"); press(a)
		check(not c.drawing and Engine.time_scale == 1.0, "%s did not cancel" % a)
	c._locked_until = 0
	press("cast")
	press("attack")
	check(not p.buffer.has("attack"), "attack was buffered while drawing")
	p.health.take_damage(9999, null, true)
	check(not c.drawing and Engine.time_scale == 1.0, "death did not cancel")

	# Sakti per landed keris or busur hit, and leaving the tree mid-cast.
	var p2: Player = load("res://entities/player/player.tscn").instantiate()
	world.add_child(p2)
	await process_frame
	var hb := Hurtbox.new()
	hb.health = Health.new()
	p2._on_hit_landed(hb, null, false, 0)
	check(is_equal_approx(p2.sakti.value, p2.item.sakti_per_hit * p2.sakti.gain_mult), "a landed hit gave %s sakti" % p2.sakti.value)
	p2.sakti.value = 100.0
	p2.cast.start()
	p2.free()
	check(Engine.time_scale == 1.0, "freeing the player mid-cast left slow-mo on")
	hb.health.free(); hb.free()

	Engine.time_scale = 1.0
	quit(1 if fails > 0 else 0)


## Through the real input path: the controller (a child) sees it before the player.
func press(action: String, pressed := true) -> void:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = pressed
	Input.parse_input_event(e)
	Input.flush_buffered_events()


func release_cast() -> void:
	press("cast", false)


func move(at: Vector2) -> void:
	var e := InputEventMouseMotion.new()
	e.position = at
	c._unhandled_input(e)


## Draws a glyph's first template fitted to a 100 px box in the middle of the 480x270 viewport.
func draw(glyph_id: String) -> void:
	var pts: PackedVector2Array = GlyphData.by_id(glyph_id).templates[0]
	var box := Rect2(pts[0], Vector2.ZERO)
	for q in pts:
		box = box.expand(q)
	var s := 100.0 / maxf(box.size.x, box.size.y)
	for q in pts:
		move(Vector2(240, 135) + (q - box.get_center()) * s)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)
