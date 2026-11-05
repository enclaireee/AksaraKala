extends SceneTree

const DT := 1.0 / 60.0
var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	run()


func step(nodes: Array, seconds: float) -> void:
	for i in roundi(seconds / DT):
		for n in nodes:
			n._physics_process(DT)


func make(h: Health = null, tint: CanvasItem = null) -> Status:
	var s := Status.new()
	s.health = h
	s.tint_target = tint
	root.add_child(s)
	s.set_physics_process(false)
	return s


func run() -> void:
	var tun: CombatTuning = load("res://data/combat_tuning.tres")

	# 1. expiry + ended once
	var s := make()
	var ends := [0]
	s.ended.connect(func(_t: Status.Type) -> void: ends[0] += 1)
	s.apply(Status.Type.SLOW)
	check(s.has(Status.Type.SLOW), "apply -> has")
	step([s], tun.slow_time - 0.1)
	check(s.has(Status.Type.SLOW), "still active before end")
	step([s], 0.3)
	check(not s.has(Status.Type.SLOW) and ends[0] == 1, "expired, ended once")

	# 2. refresh, no stack
	s.apply(Status.Type.SLOW)
	step([s], 1.5)
	s.apply(Status.Type.SLOW)
	step([s], 1.0)
	check(s.has(Status.Type.SLOW), "refresh extends past original end")
	step([s], 1.2)
	check(not s.has(Status.Type.SLOW) and ends[0] == 2, "single expiry after refresh (no stack)")

	# 3. speed_mult
	check(s.speed_mult() == 1.0, "speed 1 normally")
	s.apply(Status.Type.SLOW)
	check(is_equal_approx(s.speed_mult(), tun.slow_mult), "slow_mult")
	s.apply(Status.Type.SLOW, -1.0, 0.4)
	check(is_equal_approx(s.speed_mult(), 0.4), "custom multiplier")
	s.apply(Status.Type.BOUND)
	check(s.speed_mult() == 0.0, "bound wins over slow")
	s.clear(Status.Type.BOUND)
	s.clear(Status.Type.SLOW)

	# 4. burn exact total, ignores i-frames
	var h := Health.new()
	h.max_hp = 100
	root.add_child(h)
	h.set_physics_process(false)
	var b := make(h)
	h.set_invincible(5.0)
	b.apply(Status.Type.BURN, -1.0, 20.0)
	var ticks := [0]
	h.damaged.connect(func(_a: int, _s: Node) -> void: ticks[0] += 1)
	step([b], tun.burn_time + 0.1)
	check(h.hp == 100 - roundi(20 * tun.burn_share), "burn total 6, got hp %d" % h.hp)
	check(ticks[0] == tun.burn_ticks, "3 ticks, got %d" % ticks[0])
	check(not b.has(Status.Type.BURN), "burn ended")

	# 5. clear stops ticks
	h.hp = 100
	b.apply(Status.Type.BURN, -1.0, 20.0)
	step([b], 0.6)
	b.clear(Status.Type.BURN)
	var hp_then := h.hp
	step([b], 2.0)
	check(h.hp == hp_then and hp_then > 90, "clear stops ticks")

	# 6. curse vs sakti
	var cs := make()
	var g := SaktiGauge.new()
	g.status = cs
	root.add_child(g)
	cs.apply(Status.Type.CURSE)
	g.add(10)
	check(g.value == 0.0, "curse blocks add")
	step([cs], tun.curse_time + 0.1)
	g.add(10)
	check(g.value == 10.0, "add works after curse")
	g.add(500)
	check(g.value == 120.0, "add clamps at max")
	g.value = 5.0
	check(not g.spend(6.0) and g.value == 5.0, "spend fails when short, unchanged")
	check(g.spend(5.0) and g.value == 0.0, "spend succeeds")

	# 7. tint
	var n := Node2D.new()
	root.add_child(n)
	var ts := make(null, n)
	ts.apply(Status.Type.SLOW)
	step([ts], DT)
	check(n.self_modulate != Color.WHITE, "tinted while active")
	step([ts], 2.2)
	check(n.self_modulate == Color.WHITE, "white after end")

	quit(1 if fails > 0 else 0)
