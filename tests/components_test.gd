extends SceneTree

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	run()


func run() -> void:
	var h := Health.new()
	h.max_hp = 30
	root.add_child(h)
	var log: Array = []
	h.damaged.connect(func(a: int, _s: Node) -> void: log.append(a))
	h.changed.connect(func(c: int, _m: int) -> void: log.append(c))
	var deaths := [0]
	h.died.connect(func() -> void: deaths[0] += 1)
	check(h.take_damage(10) and h.hp == 20, "damage lowers hp")
	check(log == [10, 20], "damaged/changed emitted")
	h.set_invincible(0.5)
	check(not h.take_damage(5) and h.hp == 20, "ignored while invincible")
	h.set_invincible(0.1)
	check(is_equal_approx(h.invincible_time, 0.5), "set_invincible keeps larger")
	h._physics_process(0.3)
	check(h.is_invincible(), "still invincible at 0.2 left")
	h._physics_process(0.3)
	check(not h.is_invincible(), "invincibility counted down")
	h.take_damage(100)
	h.take_damage(100)
	check(h.hp == 0 and deaths[0] == 1, "died once")

	var hp2 := Health.new()
	root.add_child(hp2)
	var hurtbox := Hurtbox.new()
	hurtbox.health = hp2
	root.add_child(hurtbox)
	var hit := Hitbox.new()
	hit.damage = 7
	root.add_child(hit)
	check(hurtbox.receive(hit) and hp2.hp == 93, "hurtbox applies damage")
	hp2.set_invincible(1.0)
	check(not hurtbox.receive(hit) and hp2.hp == 93, "hurtbox false when invincible")

	var s := Stamina.new()
	root.add_child(s)
	s.value = 5.0
	check(s.spend(20.0) and s.value == 0.0, "spend at 5 cost 20")
	var empties := [0]
	s.empty_attempt.connect(func() -> void: empties[0] += 1)
	check(not s.spend(1.0) and empties[0] == 1, "spend at 0 fails")
	s._physics_process(0.7)
	check(s.value == 0.0, "no regen within empty delay")
	s._physics_process(0.2)
	check(s.value == 0.0, "delay just ended, no regen yet")
	s._physics_process(0.1)
	check(s.value > 0.0, "regen after empty delay")
	s.value = 50.0
	s.spend(10.0)
	s._physics_process(0.3)
	check(s.value == 40.0, "no regen within regen_delay")
	s._physics_process(0.2)
	s._physics_process(0.1)
	check(s.value > 40.0, "regen after regen_delay")
	s.refund(1000.0)
	check(s.value == 100.0, "refund clamped")
	quit(1 if fails > 0 else 0)
