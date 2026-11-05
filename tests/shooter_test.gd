extends SceneTree
## Shooter state machine test. Headless, steps the shooters by hand; shots fly on live physics.

const DT := 1.0 / 60.0
var fails := 0
var player: CharacterBody2D
var hp: Health
var hits: Array[Hitbox] = []


func _initialize() -> void:
	player = CharacterBody2D.new()
	player.add_to_group("player")
	player.position = Vector2(170, 135)
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

	# 1. backs off to shooter_near
	var s := await _spawn(Vector2(210, 135))
	var near: float = s.t("near")
	for i in 200000:
		if s.global_position.distance_to(player.global_position) >= near:
			break
		s._physics_process(DT)
	check(s.global_position.distance_to(player.global_position) >= near, "backs off to near")
	s.free()

	# 2. fires and the shot damages the target
	s = await _spawn(Vector2(300, 135))
	_until(s, Shooter.State.WINDUP)
	check(s.state == Shooter.State.WINDUP, "windup in the band")
	check(s.body.modulate == Shooter.TELEGRAPH, "telegraph tint")
	_until(s, Shooter.State.RECOVER)
	check(_shots() == 1, "one shot fired")
	check(s.body.modulate == Color.WHITE, "tint cleared after windup")
	for i in 180:
		await physics_frame
	check(hp.hp == 92, "shot did 8 damage")
	check(_shots() == 0, "shot freed on hit")
	s.free()

	# 3. hit during windup cancels the shot
	s = await _spawn(Vector2(300, 135))
	_until(s, Shooter.State.WINDUP)
	s.hurtbox.receive(_hit())
	check(s.state == Shooter.State.FLINCH, "flinch on hit in windup")
	check(s.body.modulate == Color.WHITE, "tint cleared on flinch")
	for i in 120:
		s._physics_process(DT)
		if s.state == Shooter.State.WINDUP:
			break
	check(_shots() == 0, "no shot from cancelled windup")
	s.free()

	# 4. never more than 2 ranged tokens / windups at once
	var group: Array[Shooter] = []
	for p in [Vector2(290, 135), Vector2(280, 90), Vector2(280, 180)]:
		group.append(await _spawn(p))
	var peak := 0
	for i in 300:
		var winding := 0
		for g in group:
			g._physics_process(DT)
			winding += int(g.state == Shooter.State.WINDUP)
		peak = maxi(peak, winding)
		check(winding <= 2 and get_node_count_in_group("token_ranged") <= 2, "token limit at step %d" % i)
	check(peak == 2, "two shooters wind up together")

	# 5. tokens return
	for g in group:
		g.free()
	await process_frame
	check(get_node_count_in_group("token_ranged") == 0, "tokens returned")

	for h in hits:
		h.free()
	player.free()
	quit(1 if fails > 0 else 0)


func _spawn(pos: Vector2) -> Shooter:
	var n := (load("res://entities/enemies/shooter.tscn") as PackedScene).instantiate() as Shooter
	n.position = pos
	root.add_child(n)
	await process_frame
	n.set_physics_process(false)  # _ready re-enables it
	return n


func _shots() -> int:
	var c := 0
	for n in root.get_children():
		c += int(n is Arrow)
	return c


func _hit() -> Hitbox:
	var h := Hitbox.new()
	h.damage = 10
	h.source = player
	hits.append(h)
	return h


func _until(s: Shooter, st: Shooter.State) -> void:
	for i in 200000:
		if s.state == st:
			return
		s._physics_process(DT)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
