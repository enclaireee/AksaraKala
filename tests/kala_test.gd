extends SceneTree
## Batara Kala test: stats, phase 2 shield and sequence, blocked damage, casts, countdown expiry, phase 3, release.

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

	check(b.health.max_hp == 9300 and b.is_in_group("boss") and b.kind == "batara_kala", "stats")
	check(b.dawn == null and not b.shielded and not b.engaged, "phase 1: no shield, not engaged")

	# phase 1: a pulse hits a player standing on the ring path, not one close inside
	player.position = Vector2(300 + 60, 135 + 6)
	b._enter(BataraKala.State.CHASE)
	b._next_pulse = true
	run(0.7)
	check(b.state == BataraKala.State.PULSE_WIND or b.state == BataraKala.State.PULSE, "pulse begins")
	run(2.4)
	check(b.pulses == 1 and ph.hp == 1000 - 41, "ring crossing: heavy 41 once (hp %d)" % ph.hp)
	ph.hp = 1000
	ph.invincible_time = 0.0
	player.position = b.position + Vector2(10, -6)
	b._enter(BataraKala.State.CHASE)
	b._next_pulse = true
	run(3.0)
	check(ph.hp == 1000, "standing close inside the ring is safe (hp %d)" % ph.hp)

	# time-sand: 3 marks, light 18 on the player
	player.position = b.position + Vector2(200, 0)
	b._enter(BataraKala.State.CHASE)
	b._next_pulse = false
	run(0.7)
	check(b.state == BataraKala.State.SAND_WIND and b._spots.size() == 3, "sand: 3 marks")
	run(1.0)
	check(b.sands == 1 and ph.hp == 982, "sand hits for 18 (hp %d)" % ph.hp)
	ph.hp = 1000
	ph.invincible_time = 0.0

	# phase 2
	b.health.take_damage(9300 - 6200, player)
	check(b.phase == 2 and b.state == BataraKala.State.PAUSE and b.shielded, "phase 2 at 66%: pause, shield")
	check(b.sequence.size() == 3 and b.sequence[0] != b.sequence[1] and b.sequence[1] != b.sequence[2] and b.sequence[0] != b.sequence[2], "3 distinct glyphs")
	check(Array(b.sequence).all(func(g: String) -> bool: return g in game.glyphs_learned), "glyphs are learned ones")
	var hp0: int = b.health.hp
	b.health.take_damage(500, player)
	check(b.health.hp == hp0, "shield blocks damage")
	run(1.2)
	check(b.dawn != null and b.dawn > 0.0 and b.dawn < 1.0, "dawn bar rises")

	# casts
	var s := b.sequence.duplicate()
	events.spell_cast.emit(s[0], 1.0)
	events.spell_cast.emit(s[1], 1.0)
	check(b.seq_index == 2, "two right casts")
	events.spell_cast.emit("jawa_zzz", 1.0)
	check(b.seq_index == 0, "wrong cast resets")
	events.spell_cast.emit(s[1], 1.0)
	events.spell_cast.emit(s[0], 1.0)
	check(b.seq_index == 1, "wrong glyph equal to the first counts as the first")
	events.spell_cast.emit(s[1], 1.0)
	events.spell_cast.emit(s[2], 1.0)
	check(not b.shielded and b.state == BataraKala.State.STUN and b.dawn == null, "third glyph breaks the shield, stun")
	b.health.take_damage(100, player)
	check(b.health.hp == hp0 - 100, "damage lands when open")
	run(3.1)
	check(b.state != BataraKala.State.STUN and not b.shielded, "stun over after 3 s, still open")
	run(7.0)
	check(b.shielded and b.seq_index == 0, "shield returns after 10 s")
	events.spell_cast.emit("jawa_ka", 1.0)
	check(not b.shielded and b.state == BataraKala.State.STUN, "Ombak (jawa_ka) breaks the shield at once")
	run(10.1)
	check(b.shielded, "shield returns after the Ombak break")

	# countdown expiry: i-frames refuse the wave, no i-frames take 60
	ph.hp = 1000
	ph.invincible_time = 0.0
	player.position = b.position + Vector2(200, 0)
	b._elapsed = b.countdown_p2 - 0.05
	run(0.2)
	check(b.state == BataraKala.State.DEVOUR, "countdown out: devour")
	ph.set_invincible(10.0)
	run(2.1)
	check(b.devours == 1 and ph.hp == 1000, "dash i-frames avoid the devour (hp %d)" % ph.hp)
	check(b.shielded and b.dawn != null and b.dawn < 0.1, "new countdown after devour")
	ph.hp = 1000
	ph.invincible_time = 0.0
	b._elapsed = b.countdown_p2 - 0.05
	run(0.2)
	run(2.1)
	check(b.devours == 2 and ph.hp == 940, "no i-frames: heavy 60 (hp %d)" % ph.hp)

	# phase 3
	b._break_shield()
	b.health.take_damage(b.health.hp - 3100, player)
	check(b.phase == 3 and b.shielded and b._countdown() == 20.0, "phase 3 at 33%: shield, 20 s countdown")
	b._enter(BataraKala.State.CHASE)
	b._elapsed = 10.0
	run(DT)
	check(absf(b.dawn - 0.5) < 0.01, "dawn = elapsed / 20 (%s)" % [b.dawn])
	b._enter(BataraKala.State.CHASE)
	b._next_pulse = false
	b.global_position = Vector2(300, 135)
	player.position = Vector2(500, 135)
	run(0.7)
	check(b._spots.size() == 5, "phase 3: 5 time-sand circles")

	# defeat
	b._break_shield()
	b.health.take_damage(99999, player)
	await create_timer(0.6).timeout
	check(defeated == ["batara_kala"], "boss_defeated once: %s" % [defeated])

	game.killed.clear()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.save_path))
	quit(1 if fails > 0 else 0)


func run(seconds: float) -> void:
	for i in int(seconds / DT):
		b._physics_process(DT)


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
