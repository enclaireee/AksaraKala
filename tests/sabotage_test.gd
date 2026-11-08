extends SceneTree
## Story v5 sabotage test: each boss with and without its Laras flag, the boss-bar crack mark, Buto's ambush retreats.
## Steps bosses by hand. Flags are set without saving and erased (both spellings) between cases.

const DT := 1.0 / 60.0
var fails := 0
var game: Node
var events: Node
var player: CharacterBody2D


func _initialize() -> void:
	await process_frame
	game = root.get_node("Game")
	events = root.get_node("Events")
	game.save_path = "user://test_sabotage.json"
	player = CharacterBody2D.new()
	player.add_to_group("player")
	player.position = Vector2(900, 900)
	root.add_child(player)
	await process_frame
	await test_sangkuriang()
	await test_barma()
	await test_bondowoso()
	await test_keris()
	await test_kala()
	await test_bar_mark()
	await test_buto()
	clear_flags()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.save_path))
	quit(1 if fails > 0 else 0)


func set_sab(id: String, on: bool) -> void:
	clear_flags()
	if on:
		game.set_flag("laras_sabotage_" + id, false)


func clear_flags() -> void:
	for id in ["crater_seal", "glamour_seal", "bondowoso_pillar", "keris_seventh_stake", "kala_eclipse"]:
		game.flags.erase("laras_sabotage_" + id)
		game.flags.erase("laras_sabotage:" + id)


func spawn(path: String, pos: Vector2) -> Node:
	var n := (load(path) as PackedScene).instantiate()
	n.position = pos
	root.add_child(n)
	await process_frame
	n.set_physics_process(false)
	return n


func steps(b: Node, seconds: float) -> void:
	for i in int(seconds / DT):
		b._physics_process(DT)


func test_sangkuriang() -> void:
	var results := []
	for on in [false, true]:
		set_sab("crater_seal", on)
		var b := (await spawn("res://entities/bosses/sangkuriang.tscn", Vector2(100, 135))) as Sangkuriang
		check(b.sabotage_flag == "laras_sabotage_crater_seal", "sangkuriang flag name")
		b.phase = 2
		b.state = Sangkuriang.State.RECOVER   # not stunned, not paused: the dawn runs
		b.recovery = 1000.0
		steps(b, 5.0)
		results.append(b.dawn)
		b._enter(Sangkuriang.State.STUN)
		steps(b, b.stun_time + 0.1)
		results.append(b.state == Sangkuriang.State.STUN)
		steps(b, b.sabotage_stun_bonus)
		results.append(b.state != Sangkuriang.State.STUN)
		b.queue_free()
	check(absf(results[0] - 5.0 / 25.0) < 0.01, "sangkuriang no flag: dawn 25 s (%f)" % results[0])
	check(not results[1] and results[2], "sangkuriang no flag: stun 4 s")
	check(absf(results[3] - 5.0 / (25.0 * 1.4)) < 0.01, "sangkuriang flag: dawn slower (%f)" % results[3])
	check(results[4] and results[5], "sangkuriang flag: stun 4 s + bonus")


func test_barma() -> void:
	var results := []
	for on in [false, true]:
		set_sab("glamour_seal", on)
		var b := (await spawn("res://entities/bosses/barma_wijaya.tscn", Vector2(100, 135))) as BarmaWijaya
		check(b.sabotage_flag == "laras_sabotage_glamour_seal", "barma flag name")
		b._enter(BarmaWijaya.State.STUN)
		steps(b, b.stun_time + 0.1)
		results.append(b.state == BarmaWijaya.State.STUN)
		steps(b, b.sabotage_stun_bonus)
		results.append(b.state != BarmaWijaya.State.STUN)
		b.queue_free()
	check(not results[0] and results[1], "barma no flag: stun 3 s")
	check(results[2] and results[3], "barma flag: stun 3 s + bonus")


func test_bondowoso() -> void:
	var results := []
	for on in [false, true]:
		set_sab("bondowoso_pillar", on)
		var b := (await spawn("res://entities/bosses/bandung_bondowoso.tscn", Vector2(100, 135))) as BandungBondowoso
		check(b.sabotage_flag == "laras_sabotage_bondowoso_pillar", "bondowoso flag name")
		await process_frame   # the opening pillar is raised deferred
		check(b.standing() >= 1, "bondowoso opens with a pillar")
		b._beat()
		results.append(b.pillars[0].exposed_left)
		b.dawn = 0.0
		b.engaged = true
		b._run_builders(1.0)
		results.append(b.dawn)
		b.queue_free()
		for p in get_nodes_in_group("pillar"):
			p.queue_free()
	check(is_equal_approx(results[0], 3.0) and absf(results[1] - 1.0 / 20.0) < 0.001, "bondowoso no flag: expose 3 s, beat 20 s (%s)" % [results])
	check(is_equal_approx(results[2], 4.5) and absf(results[3] - 1.0 / 12.0) < 0.001, "bondowoso flag: expose 4.5 s, beat 12 s (%s)" % [results])


func test_keris() -> void:
	var stake_scene := load("res://entities/bosses/curse_stake.tscn") as PackedScene
	var marks := []
	var ha_out := []
	for on in [false, true]:
		set_sab("keris_seventh_stake", on)
		var k := (await spawn("res://entities/bosses/keris_gandring.tscn", Vector2(300, 135))) as KerisGandring
		check(k.sabotage_flag == "laras_sabotage_keris_seventh_stake", "keris flag name")
		k.target = player
		var all: Array[CurseStake] = []
		for i in 7:
			var s := stake_scene.instantiate() as CurseStake
			s.stake_id = i + 1
			s.position = Vector2(300, 135) + Vector2.from_angle(TAU * i / 7.0) * 150.0
			root.add_child(s)
			s.set_physics_process(false)
			all.append(s)
		await process_frame
		for i in 6:
			all[i].state = CurseStake.State.LIT
		k._light_t = k.stake_interval
		k._run_stakes(DT)
		marks.append(all[6]._left)
		check(all[6].state == CurseStake.State.MARK, "keris lights the only unlit stake")
		# Jawa Ha from 100 px (past the stake's own 80 px)
		player.position = all[0].position + Vector2(100, 0)
		events.spell_cast.emit("jawa_ha", 1.0)
		ha_out.append(all[0].state == CurseStake.State.UNLIT)
		player.position = Vector2(900, 900)
		for s in all:
			s.queue_free()
		k.queue_free()
		await process_frame
	check(is_equal_approx(marks[0], 1.0), "keris no flag: stake 7 marks 1 s (%f)" % marks[0])
	check(is_equal_approx(marks[1], 2.0), "keris flag: stake 7 marks 2 s (%f)" % marks[1])
	check(not ha_out[0], "keris no flag: Ha at 100 px leaves the stake lit")
	check(ha_out[1], "keris flag: Ha reaches 120 px")


func test_kala() -> void:
	game.glyphs_learned = PackedStringArray(["sunda_ka", "sunda_ga", "sunda_nga", "sunda_ca"])
	var results := []
	for on in [false, true]:
		set_sab("kala_eclipse", on)
		var b := (await spawn("res://entities/bosses/batara_kala.tscn", Vector2(300, 135))) as BataraKala
		check(b.sabotage_flag == "laras_sabotage_kala_eclipse", "kala flag name")
		b._raise_shield()
		results.append(b.seq_index)
		b._break_shield()
		steps(b, b.stun_time + 0.1)
		results.append(b.state == BataraKala.State.STUN)
		steps(b, b.sabotage_stun_bonus)
		results.append(b.state != BataraKala.State.STUN)
		b.queue_free()
	check(results[0] == 0 and not results[1] and results[2], "kala no flag: full sequence, stun 3 s (%s)" % [results])
	check(results[3] == 1 and results[4] and results[5], "kala flag: first name spoken, stun 4 s (%s)" % [results])


## The boss bar shows the cracked mark only when the boss's flag is set.
func test_bar_mark() -> void:
	set_sab("crater_seal", false)
	player.remove_from_group("player")   # the HUD reads health and signals off the player group; this stand-in has none
	var ui: Node = load("res://ui/game_ui.tscn").instantiate()
	root.add_child(ui)
	var hud: Node = ui.get_node("HUD")
	var b := (await spawn("res://entities/bosses/sangkuriang.tscn", Vector2(100, 135))) as Sangkuriang
	b.engaged = true
	hud._update_boss()
	check(hud._boss_root.visible, "boss bar visible")
	check(not hud._boss_mark.visible, "no mark without the flag")
	set_sab("crater_seal", true)
	hud._update_boss()
	check(hud._boss_mark.visible, "mark with the flag")
	set_sab("crater_seal", false)
	hud._update_boss()
	check(not hud._boss_mark.visible, "mark gone when the flag is gone")
	# a boss with no flag name never shows it
	b.sabotage_flag = ""
	set_sab("crater_seal", true)
	hud._update_boss()
	check(not hud._boss_mark.visible, "no flag name: no mark")
	b.queue_free()
	ui.queue_free()
	await process_frame
	player.add_to_group("player")


func test_buto() -> void:
	clear_flags()
	var cleared: Array[String] = []
	var cb := func(id: String) -> void: cleared.append(id)
	events.area_cleared.connect(cb)
	var want := {"buto_ambush_1": 0.80, "buto_ambush_2": 0.65, "buto_ambush_3": 0.50}
	for id in want:
		var b := (load("res://entities/bosses/buto_ijo.tscn") as PackedScene).instantiate() as ButoIjo
		b.ambush_id = id
		b.position = Vector2(100, 135)
		root.add_child(b)
		await process_frame
		b.set_physics_process(false)
		var max_hp: int = b.health.max_hp
		var r: float = want[id]
		check(is_equal_approx(b.retreat_at(), r), "%s retreat threshold" % id)
		player.position = Vector2(200, 135)
		b._physics_process(DT)
		check(b.engaged, "%s engages" % id)
		# just above the threshold: still fighting
		b.health.take_damage(max_hp - int(max_hp * r) - 5, player)
		await process_frame
		check(not b.retreated and not cleared.has(id), "%s: above %d%% he stays" % [id, int(r * 100)])
		# cross it
		b.health.take_damage(10, player)
		await process_frame
		check(b.retreated and cleared == [id] and not b.is_in_group("boss"), "%s: retreats and emits area_cleared once (%s)" % [id, cleared])
		check(not b.dead and not game.killed.has("buto_ijo"), "%s: retreat is not a kill" % id)
		cleared.clear()
		b.queue_free()
		for f in b.fields:
			if is_instance_valid(f):
				f.queue_free()
		await process_frame
	# the lair fight (no ambush id, no encounter sibling): never retreats
	var lair := (load("res://entities/bosses/buto_ijo.tscn") as PackedScene).instantiate() as ButoIjo
	lair.position = Vector2(100, 135)
	root.add_child(lair)
	await process_frame
	lair.set_physics_process(false)
	player.position = Vector2(200, 135)
	lair._physics_process(DT)
	lair.health.take_damage(lair.health.max_hp * 6 / 10, player)
	await process_frame
	check(lair.ambush_id == "" and lair.retreat_at() == 0.0 and not lair.retreated and cleared.is_empty(), "lair: no retreat")
	events.area_cleared.disconnect(cb)
	player.position = Vector2(900, 900)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
