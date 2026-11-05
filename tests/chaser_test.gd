extends SceneTree
## Chaser state machine test. Headless, steps physics by hand.

const DT := 1.0 / 60.0
var fails := 0
var player: Node2D
var c: Chaser
var hits: Array[Hitbox] = []


func _initialize() -> void:
	player = Node2D.new()
	player.add_to_group("player")
	player.position = Vector2(5000, 0)  # far, so live physics during the ready frame does nothing
	root.add_child(player)
	c = await _spawn()

	# 1. range
	player.position = Vector2(200, 0)
	_run(10)
	check(c.state == Chaser.State.IDLE, "idle out of range")
	player.position = Vector2(100, 0)
	_run(10)
	check(c.state == Chaser.State.CHASE, "chase at 100 px")
	check(c.global_position.x > 0.0, "moved closer")

	# 2. wind-up freezes facing
	player.position = c.global_position + Vector2(20, 0)
	_until(Chaser.State.WINDUP)
	check(c.state == Chaser.State.WINDUP, "windup inside 24 px")
	var f := c.facing
	player.position = c.global_position + Vector2(-20, 0)
	_run(5)
	check(c.facing == f, "facing frozen in windup")

	# 3. attack, recover, chase
	_until(Chaser.State.ATTACK)
	check(c.state == Chaser.State.ATTACK, "attack after windup")
	await process_frame
	check(c.attack_hitbox.monitoring, "hitbox on during attack")
	_until(Chaser.State.RECOVER)
	check(c.state == Chaser.State.RECOVER, "recover after attack")
	await process_frame
	check(not c.attack_hitbox.monitoring, "hitbox off after attack")
	_until(Chaser.State.CHASE)
	check(c.state == Chaser.State.CHASE, "chase after recover")
	c.queue_free()
	await process_frame

	# 4. hit during windup cancels the attack
	c = await _spawn()
	player.position = Vector2(20, 0)
	_until(Chaser.State.WINDUP)
	check(c.state == Chaser.State.WINDUP, "windup (hit test)")
	c.hurtbox.receive(_hit())
	check(c.state == Chaser.State.FLINCH, "flinch on hit in windup")
	check(c.body.modulate == Color.WHITE, "tint cleared on flinch")
	var attacked := false
	for i in 120:
		c._physics_process(DT)
		attacked = attacked or c.state == Chaser.State.ATTACK
		if c.state == Chaser.State.WINDUP:
			break
	check(not attacked, "no attack from cancelled windup")

	# 5. four hits kill
	for i in 3:
		c.hurtbox.receive(_hit())
	check(c.state == Chaser.State.DEAD and c.health.is_dead(), "dead after four hits")

	# 6. leash
	c.queue_free()
	await process_frame
	c = await _spawn()
	player.position = Vector2(100, 0)
	_run(5)
	check(c.state == Chaser.State.CHASE, "chase (leash test)")
	c.global_position = Vector2(c.tuning.enemy_leash + 10.0, 0)
	player.position = Vector2(10000, 0)
	_run(1)
	check(c.state == Chaser.State.RETURN, "return past leash")
	_until(Chaser.State.IDLE)
	check(c.state == Chaser.State.IDLE and c.global_position.is_equal_approx(c.home), "idle at home")

	for h in hits:
		h.free()
	c.free()
	player.free()
	quit(1 if fails > 0 else 0)


func _spawn() -> Chaser:
	var n := (load("res://entities/enemies/chaser.tscn") as PackedScene).instantiate() as Chaser
	root.add_child(n)
	await process_frame
	n.set_physics_process(false)  # _ready re-enables it
	return n


func _hit() -> Hitbox:
	var h := Hitbox.new()
	h.damage = 10
	h.source = player
	hits.append(h)
	return h


func _run(n: int) -> void:
	for i in n:
		c._physics_process(DT)


func _until(s: Chaser.State) -> void:
	# move_and_slide uses the real frame delta outside a physics frame, so allow many steps
	for i in 200000:
		if c.state == s:
			return
		c._physics_process(DT)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
