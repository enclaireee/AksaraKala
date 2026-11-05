extends SceneTree
## Player input buffer, priority, combo and stamina gate (controls.md 3, combat.md 2.6).

const DT := 1.0 / 60.0
var fails := 0
var p: Player


func _initialize() -> void:
	p = load("res://entities/player/player.tscn").instantiate()
	root.add_child(p)
	await process_frame
	p.set_physics_process(false)   # stepped by hand below
	var t := p.tuning

	# Priority: dodge beats attack when both are buffered.
	press("attack"); press("dodge"); step(1)
	check(p.state == Player.State.DODGE, "dodge did not win over attack")

	# An attack pressed in the last 0.15 s of a dodge fires when it ends; an earlier one is dropped.
	reset()
	press("dodge"); step(1)
	press("attack")   # at dodge start: expires long before the dodge ends
	step_until(func() -> bool: return p.state != Player.State.DODGE, 2.0)
	step(1)
	check(p.state == Player.State.FREE, "early attack press survived the dodge")
	reset()
	press("dodge"); step(1)
	step_for(t.dodge_duration + t.dodge_recovery - 0.1)
	press("attack")
	step_until(func() -> bool: return p.state != Player.State.DODGE, 1.0)
	step(1)
	check(p.state == Player.State.ATTACK, "late attack press was not buffered through the dodge")

	# Combo resets after a pause; without one it continues.
	reset()
	for i in 2:
		press("attack")
		step_until(func() -> bool: return p.state == Player.State.ATTACK, 0.5)
		step_until(func() -> bool: return p.state == Player.State.FREE, 1.0)
	step_for(t.combo_reset + 0.1)
	press("attack"); step(1)
	check(p.hit == 0, "combo did not reset after a pause")
	reset()
	press("attack"); step(1)
	step_until(func() -> bool: return p.state == Player.State.FREE, 1.0)
	press("attack"); step(1)
	check(p.hit == 1, "combo did not continue without a pause")

	# Combo: three chained attacks, the third is the finisher at 1.5x damage.
	reset()
	var hits := []
	for i in 3:
		press("attack")
		step_until(func() -> bool: return p.state == Player.State.ATTACK, 0.5)
		hits.append(p.hit)
		step_until(func() -> bool: return p.phase == Player.Phase.ACTIVE, 0.5)
		if i == 2:
			check(p.melee_hitbox.damage == roundi(t.melee_damage * t.finisher_mult), "finisher damage %d" % p.melee_hitbox.damage)
		step_until(func() -> bool: return p.state == Player.State.FREE, 1.0)
	check(hits == [0, 1, 2], "combo order %s" % [hits])

	# Dodge cancels attack recovery.
	reset()
	press("attack")
	step_until(func() -> bool: return p.phase == Player.Phase.RECOVERY, 1.0)
	press("dodge"); step(1)
	check(p.state == Player.State.DODGE, "dodge did not cancel recovery")

	# Stamina: above 0 still acts (even below cost); at exactly 0 nothing starts.
	reset()
	p.stamina.value = 1.0
	press("attack"); step(1)
	check(p.state == Player.State.ATTACK, "attack at 1 stamina did not start")
	reset()
	p.stamina.value = 0.0
	press("attack"); step(1)
	check(p.state == Player.State.FREE, "attack at 0 stamina started")

	p.stamina.value = 0.0
	press("dodge"); step(1)
	check(p.state == Player.State.FREE, "dodge at 0 stamina started")

	# Hurt: stagger, i-frames, dodge only after hurt_dodge_after.
	reset()
	var hb := Hitbox.new()
	hb.damage = 5
	root.add_child(hb)
	hb.global_position = p.global_position + Vector2(-10, 0)
	p.health.invincible_time = 0.0   # Health only ticks with the engine; earlier dodges left i-frames
	check(p.hurtbox.receive(hb), "hit was not received")
	check(p.state == Player.State.HURT, "hit did not stagger")
	check(not p.hurtbox.receive(hb), "second hit landed during i-frames")
	p.stamina.value = 100.0
	press("dodge"); step(1)
	check(p.state == Player.State.HURT, "dodge allowed before hurt_dodge_after")
	step_until(func() -> bool: return p.state != Player.State.HURT, 0.5)
	check(p.state == Player.State.DODGE, "buffered dodge did not fire after hurt_dodge_after")
	reset()
	p.health.invincible_time = 0.0
	p.hurtbox.receive(hb)
	step_for(t.hitstop_player_hit + t.hurt_stagger + 0.02)
	check(p.state == Player.State.FREE, "stagger did not end after hurt_stagger")
	hb.queue_free()

	quit(1 if fails > 0 else 0)


func press(action: String) -> void:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = true
	p._unhandled_input(e)


func step(n: int) -> void:
	for i in n:
		p._physics_process(DT)


func step_for(seconds: float) -> void:
	step(ceili(seconds / DT))


func step_until(cond: Callable, limit: float) -> void:
	var n := 0
	while not cond.call() and n * DT < limit:
		step(1)
		n += 1


func reset() -> void:
	step_until(func() -> bool: return p.state == Player.State.FREE, 2.0)
	p.buffer.clear()
	p.combo = 0
	p.since_recovery = INF
	p.stamina.value = p.stamina.max_stamina


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)
