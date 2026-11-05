extends SceneTree
## Charger (Wild Boar) test. Steps the boar by hand, one live physics frame per step so Areas update.

const DT := 1.0 / 60.0
var fails := 0
var player: CharacterBody2D
var hp: Health


func _initialize() -> void:
	player = CharacterBody2D.new()
	player.add_to_group("player")
	player.position = Vector2(200, 135)
	var hb := Hurtbox.new()
	hb.collision_layer = 2
	hb.position = Vector2(0, -6)
	var cs := CollisionShape2D.new()
	cs.shape = CircleShape2D.new()
	(cs.shape as CircleShape2D).radius = 7.0
	hb.add_child(cs)
	hp = Health.new()
	hp.max_hp = 100
	hb.health = hp
	player.add_child(hp)
	player.add_child(hb)
	root.add_child(player)
	await process_frame

	# 1. telegraph before the dash, then the dash holds its direction while the player moves
	var b := await _spawn(Vector2(100, 135))
	var saw_tel := false
	var tel_frames := 0
	var dash_seen := false
	for i in 600:
		await physics_frame
		b._physics_process(DT)
		if b.state == Charger.State.TELEGRAPH:
			saw_tel = true
			tel_frames += 1
			check(b.marker.visible, "marker shown in telegraph")
		if b.state == Charger.State.DASH:
			check(saw_tel, "telegraph came before the dash")
			dash_seen = true
			break
	check(dash_seen, "boar dashes")
	check(absf(tel_frames * DT - b.t("windup")) < 0.05, "telegraph lasts about windup")
	var dir: Vector2 = b.dash_dir
	var y0 := b.global_position.y
	player.position = Vector2(200, 235)   # player steps away
	for i in 20:
		await physics_frame
		b._physics_process(DT)
	check(b.dash_dir == dir and absf(b.global_position.y - y0) < 0.5, "dash does not steer")
	b.free()
	player.position = Vector2(200, 135)

	# 2. damages the player once per dash
	b = await _spawn(Vector2(100, 135))
	hp.hp = 100
	for i in 600:
		await physics_frame
		b._physics_process(DT)
		if b.state == Charger.State.RECOVER:
			break
	check(b.state == Charger.State.RECOVER, "dash ends in recovery")
	check(hp.hp == 88, "one hit of 12 per dash, got %d" % hp.hp)
	b.free()

	# 3. stops on a wall with a self-stun
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	var ws := CollisionShape2D.new()
	ws.shape = RectangleShape2D.new()
	(ws.shape as RectangleShape2D).size = Vector2(10, 200)
	wall.add_child(ws)
	wall.position = Vector2(150, 135)
	root.add_child(wall)
	await process_frame
	hp.hp = 100
	b = await _spawn(Vector2(100, 135))
	for i in 600:
		await physics_frame
		b._physics_process(DT)
		if b.state == Charger.State.STUN:
			break
	check(b.state == Charger.State.STUN, "wall stuns the boar")
	check(b.global_position.x < 150.0, "stopped before the wall")
	check(hp.hp == 100, "no damage through the wall")
	b.free()

	quit(1 if fails > 0 else 0)


func _spawn(pos: Vector2) -> Charger:
	var n := (load("res://entities/enemies/wild_boar.tscn") as PackedScene).instantiate() as Charger
	n.position = pos
	root.add_child(n)
	await process_frame
	n.set_physics_process(false)
	return n


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
