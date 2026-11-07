extends SceneTree
## Attack animation and FX (combat.md 2.3b): hero sheet size, directional attack rows, FX spawn and free,
## and Reduce flashes. Stepped by hand, no timers.

const DT := 1.0 / 60.0
var fails := 0
var p: Player


func check(cond: bool, msg: String) -> void:
	if not cond:
		print("FAIL: ", msg)
		fails += 1


func _initialize() -> void:
	# 1. Hero sheets: 6 cols x 18 rows of 24x24
	for cls: String in ["base", "warrior", "archer", "rogue", "mage"]:
		var tex := load("res://assets/art/hero_%s.png" % cls) as Texture2D
		check(tex != null and tex.get_width() == 144 and tex.get_height() == 432, "hero_%s.png is 144x432" % cls)
	for n: String in ["smear_light", "smear_heavy", "smear_thrust", "smear_finisher", "smear_core", "spark", "ink_splash",
			"ring", "ink_puff", "dust", "step_dust", "muzzle", "arrow_trail", "bolt_glow", "bolt_spark"]:
		check(load("res://assets/art/fx/%s.png" % n) != null, "fx sheet exists: " + n)

	p = load("res://entities/player/player.tscn").instantiate()
	root.add_child(p)
	await process_frame
	p.set_physics_process(false)
	var fx: AttackFX = p.fx
	check(fx != null, "player has an AttackFX child")
	if fx == null:
		quit(1)
		return
	fx.set_process(false)   # ticked by hand below
	check(p.sprite.hframes == 6 and p.sprite.vframes == 18, "player sprite is 6x18")

	# 2. Directional attack rows: hit 1 down, side (both flips) and up
	var cases := [[Vector2.DOWN, 12, false], [Vector2.RIGHT, 6, false], [Vector2.LEFT, 6, true], [Vector2.UP, 15, false]]
	for hit in 3:
		for c: Array in cases:
			_reset()
			p.combo = hit
			_press("attack")
			_step(1)
			p.aim_dir = c[0]
			_step(1)
			check(p.state == Player.State.ATTACK and p.hit == hit, "attack %d started" % hit)
			check(p.sprite.frame_coords.y == c[1] + hit, "aim %s hit %d row %d, got %d" % [c[0], hit, c[1] + hit, p.sprite.frame_coords.y])
			check(p.sprite.flip_h == c[2], "aim %s flip_h %s" % [c[0], c[2]])
	# frames follow the phases: wind-up 0-1, active 2-3, recovery 4-5
	_reset()
	_press("attack")
	_step(1)
	check(p.sprite.frame_coords.x <= 1, "wind-up uses frames 0-1")
	_step_until(func() -> bool: return p.phase == Player.Phase.ACTIVE, 1.0)
	_step(1)
	check(p.sprite.frame_coords.x in [2, 3], "active uses frames 2-3, got %d" % p.sprite.frame_coords.x)
	_step_until(func() -> bool: return p.phase == Player.Phase.RECOVERY, 1.0)
	_step(1)
	check(p.sprite.frame_coords.x in [4, 5], "recovery uses frames 4-5, got %d" % p.sprite.frame_coords.x)
	_step_until(func() -> bool: return p.state == Player.State.FREE, 2.0)
	# dodge uses 6 frames
	_reset()
	_press("dodge")
	_step(1)
	check(p.state == Player.State.DODGE and p.sprite.frame_coords.y == 9, "dodge row 9")
	_step_until(func() -> bool: return p.state_time > 0.4, 1.0)
	check(p.sprite.frame_coords.x == 5, "dodge reaches frame 5, got %d" % p.sprite.frame_coords.x)

	# 3. An FX node appears on swing and is freed afterwards
	_reset()
	fx.tick(5.0)
	check(fx.fx_count() == 0, "no FX left before the swing")
	var kids_before := fx.get_child_count()
	_press("attack")
	_step_until(func() -> bool: return p.phase == Player.Phase.ACTIVE, 1.0)
	_step(1)
	check(fx.fx_count() > 0, "an FX node appeared on swing")
	check(fx.get_child_count() > kids_before, "the smear is a child of AttackFX")
	var nodes: Array = []
	for e: Dictionary in fx._fx:
		nodes.append(e.node)
	_step_until(func() -> bool: return p.state == Player.State.FREE, 2.0)
	for i in 120:
		fx.tick(DT)
	check(fx.fx_count() == 0, "FX list empty after their animations: %d" % fx.fx_count())
	await process_frame
	var leaked := 0
	for n in nodes:
		if is_instance_valid(n):
			leaked += 1
	check(leaked == 0, "%d FX nodes were not freed" % leaked)

	# 4. Reduce flashes: no ring, no target flash; sparks stay
	var target := Node2D.new()
	var stub := GDScript.new()
	stub.source_code = "extends Node\nvar n := 0\nfunc flash(_d := 0.0) -> void:\n\tn += 1\n"
	stub.reload()
	var hf := Node.new()
	hf.name = "HitFlash"
	hf.set_script(stub)
	target.add_child(hf)
	var hb := Node2D.new()
	target.add_child(hb)
	root.add_child(target)
	hb.owner = target
	target.global_position = p.global_position + Vector2(20, 0)
	fx.reduce_flashes = false
	fx.on_hit(hb, true, false)
	check(_has_tex(fx, "ring.png"), "a heavy hit spawns a ring")
	check(_has_tex(fx, "spark.png"), "a hit spawns a spark")
	check(hf.get("n") == 1, "a heavy hit flashes the target")
	fx.tick(5.0)
	fx.reduce_flashes = true
	hf.set("n", 0)
	fx.on_hit(hb, true, false)
	check(not _has_tex(fx, "ring.png"), "Reduce flashes: no ring")
	check(hf.get("n") == 0, "Reduce flashes: no white flash on the target")
	check(_has_tex(fx, "spark.png"), "Reduce flashes keeps the spark")
	fx.tick(5.0)
	check(fx.fx_count() == 0, "FX freed after the heavy hit")

	quit(1 if fails > 0 else 0)


func _has_tex(fx: AttackFX, file: String) -> bool:
	for e: Dictionary in fx._fx:
		var s := e.node as Sprite2D
		if s != null and s.texture != null and s.texture.resource_path.ends_with(file):
			return true
	return false


func _reset() -> void:
	p.state = Player.State.FREE
	p.state_time = 0.0
	p.combo = 0
	p.since_recovery = 0.0   # keeps p.combo (a pause longer than combo_reset would reset it)
	p.buffer.clear()
	p.stamina.value = p.stamina.max_stamina
	p.health.invincible_time = 0.0
	p.aim_dir = Vector2.RIGHT


func _press(action: String) -> void:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = true
	p._unhandled_input(e)


func _step(n: int) -> void:
	for i in n:
		p._physics_process(DT)
		p.fx.tick(DT)


func _step_until(cond: Callable, limit: float) -> void:
	var t := 0.0
	while not cond.call() and t < limit:
		_step(1)
		t += DT
