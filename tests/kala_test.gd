extends SceneTree
## Batara Kala test (boss revamp v9): "The shield names its glyphs. The hourglass drains each phase."
## Phase 1 moves and sig1, the hourglass (drain, marked heavy pulse, refill), phase 2 shield (sig2, sockets, sequence,
## stun 4 s with TERBUKA, a wrong order or a miss costs one heavy hit at most), phase 3 (+6 s with choice_redeem_aria),
## the kneel and the release. Damage numbers are the scaled ones (BossKit.boss_damage, balance.md 7.3).

const DT := 1.0 / 60.0
var fails := 0
var player: CharacterBody2D
var ph: Health
var b: BataraKala
var defeated: Array[String] = []


func _initialize() -> void:
	await process_frame
	var game := root.get_node("Game")
	var events := root.get_node("Events")
	game.save_path = "user://test_kala.json"
	game.glyphs_learned = PackedStringArray(["sunda_ka", "sunda_ga", "sunda_nga", "sunda_ca"])
	events.boss_defeated.connect(func(id: String) -> void: defeated.append(id))
	player = CharacterBody2D.new()
	player.add_to_group("player")
	player.position = Vector2(900, 900)
	root.add_child(player)
	ph = Health.new()
	ph.max_hp = 1000
	player.add_child(ph)
	var hb := Hurtbox.new()
	hb.name = "Hurtbox"
	hb.health = ph
	player.add_child(hb)
	b = (load("res://entities/bosses/batara_kala.tscn") as PackedScene).instantiate() as BataraKala
	b.position = Vector2(300, 135)
	root.add_child(b)
	await process_frame
	b.set_physics_process(false)
	var art := b.body.get_node_or_null("Art") as EnemyArt

	check(b.health.max_hp == roundi(9300 * 0.85) and b.is_in_group("boss") and b.kind == "batara_kala", "stats")
	check(b.dawn == null and not b.shielded and not b.engaged, "phase 1: no shield, not engaged")
	check(art != null and art.cols == 8, "8-column sheets")
	check(b.hourglass != null and b.hourglass.is_inside_tree() and b.hourglass.position == b.position + BataraKala.HOURGLASS_AT, "hourglass prop stands in the room")
	b.countdown_p1 = 999.0   # the hourglass is tested on its own below

	# phase 1: a pulse hits a player standing on the ring path, not one close inside
	player.position = Vector2(300 + 60, 135 + 6)
	b._enter(BataraKala.State.CHASE)
	b._forced_move = "pulse"
	run(0.7)
	check(b.state == BataraKala.State.PULSE_WIND or b.state == BataraKala.State.PULSE, "pulse begins")
	run(2.4)
	check(b.pulses == 1 and ph.hp == 1000 - BossKit.boss_damage(b.pulse_damage), "ring crossing: one heavy (hp %d)" % ph.hp)
	reset_player()
	player.position = b.position + Vector2(10, -6)
	b._enter(BataraKala.State.CHASE)
	b._forced_move = "pulse"
	run(3.0)
	check(ph.hp == 1000, "standing close inside the ring is safe (hp %d)" % ph.hp)

	# time-sand: 3 marks, a light hit on the player
	player.position = b.position + Vector2(200, 0)
	b._enter(BataraKala.State.CHASE)
	b._forced_move = "sand"
	run(0.7)
	check(b.state == BataraKala.State.SAND_WIND and b._spots.size() == 3, "sand: 3 marks")
	run(1.0)
	check(b.sands == 1 and ph.hp == 1000 - BossKit.boss_damage(b.sand_damage), "sand hits (hp %d)" % ph.hp)
	reset_player()

	# every move, begun directly: counted, ends in RECOVER, leaves the boss in one piece
	b._forced_move = "none"   # no random follow-up attacks while single moves are under test
	for mv: String in ["sweep", "chime", "hands", "skip", "devour", "meteor", "beams", "ruwatan"]:
		b.global_position = Vector2(300, 135)
		player.position = b.position + Vector2(90, 0)
		ph.set_invincible(100.0)   # damage is checked below; here only the flow
		b._begin(mv)
		var seen := false
		for i in int(8.0 / DT):
			b._physics_process(DT)
			seen = seen or b.state == BataraKala.State.RECOVER
		check(b.moves_used.get(mv, 0) == 1 and seen, "move %s: counted and reaches recovery" % mv)
		b._enter(BataraKala.State.CHASE)
		check(b._fx.is_empty() and b._impacts.is_empty() and b.body.visible, "move %s: cleared on enter" % mv)
	reset_player()
	# the deck: phase 1 is pulse, sand, sweep, chime and the devour lunge; never the same heavy twice
	b._deck.clear()
	b._last_move = ""
	var seen_moves := deck_run(30.0)
	check(seen_moves.keys().all(func(m: String) -> bool: return m in BataraKala.DECK[1]) and seen_moves.size() == 5,
		"deck phase 1: pulse, sand, sweep, chime, devour (%s)" % [seen_moves.keys()])
	check(not seen_moves.has("twice"), "deck: never the same heavy twice")
	# scythe sweep: forehand hits a player in front of him
	b.global_position = Vector2(300, 135)
	player.position = b.position + Vector2(30, 0)
	b._begin("sweep")
	run(b.sweep_wind + 0.1)
	check(ph.hp == 1000 - BossKit.boss_damage(b.sweep_damage), "sweep forehand hits (hp %d)" % ph.hp)
	reset_player()
	# sig1, the devour lunge: the row plays, the line fills, one heavy bite at its end
	b.global_position = Vector2(300, 135)
	player.position = b.position + Vector2(70, 0)
	var lunges0 := b.lunges
	b._begin("devour")
	check(b.state == BataraKala.State.LUNGE and art._move == "sig1", "devour lunge plays sig1")
	run(b.lunge_wind - 0.1)
	check(ph.hp == 1000 and b.lunges == lunges0, "lunge: nothing lands during the wind-up")
	run(0.2)
	check(b.lunges == lunges0 + 1 and ph.hp == 1000 - BossKit.boss_damage(b.lunge_damage) and b.state == BataraKala.State.RECOVER,
		"lunge: one heavy bite (hp %d)" % ph.hp)
	check(b.global_position.distance_to(Vector2(300 + b.lunge_len, 135)) < 1.0, "lunge: he lands at the line's end")
	reset_player()
	# Ruwatan Eclipse: a player in an unsafe wedge takes the ultimate, one in the safe wedge does not
	for in_safe in [false, true]:
		b.global_position = Vector2(300, 135)
		b._begin("ruwatan")
		var wedge: int = b._ru_safe if in_safe else (b._ru_safe + 1) % 8
		player.position = b.global_position + Vector2.from_angle(b._ru_wedge_dir(wedge)) * 80.0 - Vector2(0, -8)
		run(b.ruwatan_windup + 0.1)
		var want := 1000 if in_safe else 1000 - BossKit.boss_damage(b.ruwatan_damage)
		check(ph.hp == want, "ruwatan %s wedge: hp %d want %d" % ["safe" if in_safe else "unsafe", ph.hp, want])
		reset_player()
	b.global_position = Vector2(300, 135)
	b._enter(BataraKala.State.CHASE)
	check(b._next_move(100.0) != "sweep", "deck: no scythe sweep from far away")

	# the hourglass in phase 1: it drains, an empty glass is one marked heavy pulse, then it refills
	b.countdown_p1 = 30.0
	player.position = b.position + Vector2(200, 0)
	b._elapsed = 15.0
	run(DT)
	check(absf(b.dawn - 0.5) < 0.01 and absf(b._sand.level - 0.5) < 0.01, "hourglass half drained (%s, %s)" % [b.dawn, b._sand.level])
	b._elapsed = b.countdown_p1 - 0.05
	run(0.2)
	check(b.state == BataraKala.State.EMPTY and b._sand.alarm, "hourglass empty: marked pulse (red fill, alarm)")
	run(b.empty_time + 0.1)
	check(b.empties == 1 and ph.hp == 1000 - BossKit.boss_damage(b.empty_damage), "empty hourglass: one heavy (hp %d)" % ph.hp)
	# phase 1 keeps draining after the refill, so allow the 0.1 s overrun
	check(b._elapsed < 0.3 and b._sand.level > 0.98 and not b._sand.alarm and b.state == BataraKala.State.CHASE,
		"hourglass refills")
	run(2.0)
	check(b.empties == 1 and ph.hp == 1000 - BossKit.boss_damage(b.empty_damage), "only one pulse per empty glass (hp %d)" % ph.hp)
	reset_player()

	# phase 2 at 66%: the form swaps with a roar, then the shield rises (sig2)
	b.health.take_damage(b.health.hp - b.health.max_hp * 2 / 3, player)
	b._forced_move = "none"   # no random attacks while the shield and countdown are under test
	check(b.phase == 2 and b.state == BataraKala.State.PAUSE and b.shielded and b._sockets.visible, "phase 2 at 66%: pause, shield, sockets")
	check(art._move == "roar", "phase 2: roar first (%s)" % art._move)
	art._update_form()
	check(art._form == 1 and art.base_tex == art._forms[1][0], "phase 2 form sheet")
	check(b.sequence.size() == 3 and b.sequence[0] != b.sequence[1] and b.sequence[1] != b.sequence[2] and b.sequence[0] != b.sequence[2], "3 distinct glyphs")
	check(Array(b.sequence).all(func(g: String) -> bool: return g in game.glyphs_learned), "glyphs are learned ones")
	check(b._sockets._glyph(b.sequence[0]).size() > 3, "a socket draws its glyph")
	var hp0: int = b.health.hp
	b.health.take_damage(500, player)
	check(b.health.hp == hp0, "shield blocks damage")
	run(1.1)
	check(art._move == "sig2", "the shield rises: sig2 (%s)" % art._move)
	run(0.9)
	check(b.dawn != null and b.dawn > 0.0 and b.dawn < 1.0, "the hourglass drains under the shield")
	check(b._crown.get_node_or_null("BossMark") != null, "the next glyph is marked over his crown")
	b._enter(BataraKala.State.CHASE)
	run(DT)
	check(art._move == "sig2" and art._move_t >= 4.0, "between moves he holds the shield (held frames)")

	# casts: in order; a wrong one resets and costs nothing
	var s := b.sequence.duplicate()
	events.spell_cast.emit(s[0], 1.0)
	events.spell_cast.emit(s[1], 1.0)
	check(b.seq_index == 2, "two right casts")
	events.spell_cast.emit("jawa_zzz", 1.0)
	check(b.seq_index == 0 and ph.hp == 1000, "wrong cast resets, no damage")
	events.spell_cast.emit(s[1], 1.0)
	events.spell_cast.emit(s[0], 1.0)
	check(b.seq_index == 1, "wrong glyph equal to the first counts as the first")
	events.spell_cast.emit(s[1], 1.0)
	events.spell_cast.emit(s[2], 1.0)
	check(not b.shielded and b.state == BataraKala.State.STUN and b.dawn == null and not b._sockets.visible, "third glyph breaks the shield, stun")
	check(BossKit.is_open(b), "TERBUKA while stunned")
	check(b._sand.level > 0.99, "the hourglass refills on a break")
	b.health.take_damage(100, player)
	check(b.health.hp == hp0 - 100, "damage lands when open")
	run(3.9)
	check(b.state == BataraKala.State.STUN, "still stunned at 3.9 s")
	run(0.2)
	check(b.state != BataraKala.State.STUN and not b.shielded, "stun over after 4 s, still open")
	run(6.0)
	check(b.shielded and b.seq_index == 0, "shield returns after 10 s")
	# with Ombak learned: Sunda, Jawa, then Ombak; Ombak out of order does not skip the sequence
	game.glyphs_learned = PackedStringArray(["sunda_ka", "sunda_ga", "jawa_ha", "jawa_ka"])
	b._new_sequence()
	check(b.sequence[0].begins_with("sunda_") and b.sequence[1].begins_with("jawa_") and b.sequence[1] != "jawa_ka" and b.sequence[2] == "jawa_ka", "sequence: Sunda, Jawa, Ombak (%s)" % ",".join(b.sequence))
	events.spell_cast.emit("jawa_ka", 1.0)
	check(b.shielded and b.seq_index == 0, "Ombak alone does not break the shield")
	s = b.sequence.duplicate()
	for g: String in s:
		events.spell_cast.emit(g, 1.0)
	check(not b.shielded and b.state == BataraKala.State.STUN, "Ombak as the last glyph breaks the shield")
	run(10.1)
	check(b.shielded, "shield returns after the Ombak break")

	# a miss: the hourglass empties under the shield. I-frames refuse the pulse; without them it is one heavy hit.
	reset_player()
	player.position = b.position + Vector2(200, 0)
	var old_seq := b.sequence.duplicate()
	b._elapsed = b.countdown_p2 - 0.05
	run(0.2)
	check(b.state == BataraKala.State.EMPTY, "countdown out: the empty pulse")
	ph.set_invincible(10.0)
	run(b.empty_time + 0.1)
	check(b.empties == 2 and ph.hp == 1000, "dash i-frames avoid the pulse (hp %d)" % ph.hp)
	check(b.shielded and b.dawn != null and b.dawn < 0.1, "refilled, new countdown")
	reset_player()
	b._elapsed = b.countdown_p2 - 0.05
	run(0.2)
	run(b.empty_time + 0.1)
	check(b.empties == 3 and ph.hp == 1000 - BossKit.boss_damage(b.empty_damage), "no i-frames: one heavy (hp %d)" % ph.hp)
	check(ph.hp > 0, "a miss never wipes")
	check(b.sequence.size() == 3, "the shield names new glyphs after a miss (was %s)" % [old_seq])
	reset_player()

	# phase 3 at 33%: the third form, 20 s glass, +6 s with choice_redeem_aria
	b._break_shield()
	b.health.take_damage(b.health.hp - b.health.max_hp / 3, player)
	check(b.phase == 3 and b.shielded and b._countdown() == 20.0, "phase 3 at 33%: shield, 20 s hourglass")
	art._update_form()
	check(art._form == 2 and art.base_tex == art._forms[2][0], "phase 3 form sheet")
	b._enter(BataraKala.State.CHASE)
	b._elapsed = 10.0
	run(DT)
	check(absf(b.dawn - 0.5) < 0.01, "dawn = elapsed / 20 (%s)" % [b.dawn])
	game.flags["choice_redeem_aria"] = true
	check(b._countdown() == 26.0, "choice_redeem_aria: +6 s in phase 3 (%s)" % b._countdown())
	b._elapsed = 13.0
	run(DT)
	check(absf(b.dawn - 0.5) < 0.01 and absf(b._sand.level - 0.5) < 0.01, "the hourglass drains over 26 s (%s)" % [b.dawn])
	game.flags.erase("choice_redeem_aria")
	b._deck.clear()
	b._last_move = ""
	seen_moves = deck_run(30.0)
	check(seen_moves.has("meteor") and seen_moves.has("beams") and seen_moves.has("ruwatan") and seen_moves.has("devour")
		and not seen_moves.has("chime") and not seen_moves.has("pulse"), "deck phase 3 (%s)" % [seen_moves.keys()])
	b._enter(BataraKala.State.CHASE)
	b._forced_move = "sand"
	b.global_position = Vector2(300, 135)
	player.position = Vector2(500, 135)
	run(0.7)
	check(b._spots.size() == 5, "phase 3: 5 time-sand circles")

	# the finisher: inside a gated arena he kneels; the finish glyph releases him
	var gs := GDScript.new()
	gs.source_code = "extends Node2D\nvar entered := true\nfunc door() -> Vector2:\n\treturn Vector2(-9999, -9999)\n"
	gs.reload()
	var gate := Node2D.new()
	gate.set_script(gs)
	gate.add_to_group("arena_gate")
	root.add_child(gate)
	b.finish_glyph = "jawa_ka"
	b._break_shield()
	b.health.take_damage(99999, player)
	check(b.dead and b.has_meta("kneeling") and defeated.is_empty(), "he kneels")
	events.spell_cast.emit("jawa_ka", 1.0)
	check(not b._sockets.visible and not b._sand.alarm, "released: no sockets, the hourglass is still")
	var glass := b.hourglass
	await create_timer(0.6).timeout
	check(defeated == ["batara_kala"], "boss_defeated once: %s" % [defeated])
	check(is_instance_valid(glass) and glass.is_inside_tree(), "the hourglass stays in the room")
	gate.queue_free()

	game.killed.clear()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.save_path))
	quit(1 if fails > 0 else 0)


## 60 picks from the deck; "twice" is set if a heavy ever follows a heavy.
func deck_run(d: float) -> Dictionary:
	var seen := {}
	for i in 60:
		var m: String = b._next_move(d)
		if m in BataraKala.HEAVY and b._last_move in BataraKala.HEAVY:
			seen["twice"] = true
		seen[m] = true
		b._last_move = m
		b._since_ult = 0 if m == "ruwatan" else b._since_ult + 1
	return seen


func reset_player() -> void:
	ph.hp = 1000
	ph.invincible_time = 0.0


func run(seconds: float) -> void:
	for i in int(seconds / DT):
		b._physics_process(DT)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
