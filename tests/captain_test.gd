extends SceneTree
## Faceless Captain (v9): phases, every move, the banner rule (answer = Ca near it: stun + TERBUKA; miss = one heavy hit), release, stays dead.

const DT := 1.0 / 60.0
var fails := 0
var player: CharacterBody2D
var game: Node
var events: Node
var defeated: Array[String] = []


class FakePlayer extends Node2D:
	var health := Health.new()
	var class_id := ""


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _player(at: Vector2) -> void:
	player = CharacterBody2D.new()
	player.add_to_group("player")
	player.position = at
	var hb := Hurtbox.new()
	hb.name = "Hurtbox"   # BossKit.hurt_player finds it by name
	hb.collision_layer = 2
	hb.position = Vector2(0, -6)
	var cs := CollisionShape2D.new()
	cs.shape = CircleShape2D.new()
	(cs.shape as CircleShape2D).radius = 7.0
	hb.add_child(cs)
	var hp := Health.new()
	hp.max_hp = 100000
	hb.health = hp
	player.add_child(hp)
	player.add_child(hb)
	root.add_child(player)


func _hp() -> int:
	return (player.get_node("Hurtbox") as Hurtbox).health.hp


func step(b: Node, frames: int) -> void:
	for i in frames:
		b._physics_process(DT)


func step_to(b: Node, s: int, frames := 900) -> void:
	for i in frames:
		if b.state == s:
			return
		b._physics_process(DT)


## Runs one move by hand to its recovery. True if it ended in RECOVER.
func run_move(b: FacelessCaptain, m: String) -> bool:
	b._enter(FacelessCaptain.State.CHASE)
	b.global_position = Vector2(150, 135)
	b._begin_move(m, player.global_position - b.global_position)
	for i in 900:
		b._physics_process(DT)
		if b.state != FacelessCaptain.State.WINDUP:
			break
	return b.state == FacelessCaptain.State.RECOVER


func _initialize() -> void:
	await process_frame
	game = root.get_node("Game")
	events = root.get_node("Events")
	game.save_path = "user://test_captain.json"
	events.boss_defeated.connect(func(id: String) -> void: defeated.append(id))
	var kinds: Array[String] = []
	events.weakness_triggered.connect(func(k: String) -> void: kinds.append(k))
	_player(Vector2(200, 135))
	var b := (load("res://entities/bosses/faceless_captain.tscn") as PackedScene).instantiate() as FacelessCaptain
	b.position = Vector2(150, 135)
	root.add_child(b)
	await process_frame
	b.set_physics_process(false)

	check(b.is_in_group("boss") and b.health.max_hp == 1530 and b.phase == 1, "starts phase 1, 1530 HP (v9 x0.85)")
	step(b, 600)
	check(b.attacks > 0 and b.engaged, "attacks")

	# Deck: phase 1 has only the 3 base moves; later phases add the rest; never the same heavy twice in a row.
	check(b._pool().size() == 3 and "sweep" in b._pool() and "lunge" in b._pool() and "volley" in b._pool(), "phase 1 pool")
	b.phase = 2
	check("whirlwind" in b._pool() and "chain" in b._pool() and b._pool().size() == 5, "phase 2 pool")
	b.phase = 3
	check(b._pool().size() == 5, "phase 3 pool: the banner grows, no new move")
	var prev := ""
	var dup := false
	var picked := {}
	for i in 80:
		var pm: String = b._pick(60.0)
		dup = dup or (pm == prev and pm in FacelessCaptain.HEAVY)
		picked[pm] = true
		prev = pm
	check(not dup and not picked.has("") and picked.size() >= 3, "deck: no heavy twice in a row, varied (%s)" % [picked.keys()])
	b.phase = 1
	b._deck.clear()
	b._clear_banner()

	# Every move runs to its recovery and is counted (sig1 = plant, sig2 = lunge).
	for m in ["sweep", "lunge", "volley", "whirlwind", "chain", "plant"]:
		var before: int = int(b.moves_used.get(m, 0))
		check(run_move(b, m), "move %s ends in RECOVER" % m)
		check(int(b.moves_used.get(m, 0)) == before + 1, "move %s counted" % m)
	check(b.banner != null and b._ranks.size() == 4, "plant: banner up, 4 ranks in phase 1")
	b._clear_banner()
	b._enter(FacelessCaptain.State.CHASE)
	b.global_position = Vector2(150, 135)

	# Early boss: the whirlwind's wind-up is 15% longer (0.8 s -> 0.92 s).
	b._begin_move("whirlwind", Vector2.RIGHT)
	step(b, int(b.whirl_windup / DT) + 2)
	check(b.state == FacelessCaptain.State.WINDUP and b._stage == 0, "whirlwind has not struck at the old wind-up")
	step(b, int(b.whirl_windup * 0.15 / DT) + 4)
	check(b._stage == 1, "whirlwind strikes after the 15% longer wind-up")
	b._enter(FacelessCaptain.State.CHASE)

	# The rule, missed: the ranks strike once, one heavy hit on a square, then the banner furls.
	player.global_position = Vector2(200, 135)
	b._plant_banner(Vector2(150, 135))
	check(b.banner != null and b.banner_t == 0.0, "banner planted")
	player.global_position = b._rank_at[0]
	var hp_before := _hp()
	for i in int(b.rank_time / DT) + 4:
		if b.banner != null:
			b._run_banner(DT)   # the banner alone: his own attacks would muddy the count
	check(b.banner == null and b._ranks.is_empty(), "missed: the banner furls")
	check(hp_before - _hp() == BossKit.boss_damage(b.rank_damage), "missed: exactly one heavy hit (%d)" % [hp_before - _hp()])

	# The rule, answered: Ca near the banner burns it, ranks gone, stun 3.5 s with TERBUKA.
	b._enter(FacelessCaptain.State.CHASE)
	b._plant_banner(Vector2(150, 135))
	player.global_position = Vector2(400, 135)
	events.spell_cast.emit("sunda_ca", 1.0)
	check(b.banner != null and b.state != FacelessCaptain.State.STUN, "Ca far from the banner does nothing")
	player.global_position = Vector2(180, 135)
	events.spell_cast.emit("sunda_ka", 1.0)
	check(b.banner != null and b.state != FacelessCaptain.State.STUN, "another glyph does nothing")
	events.spell_cast.emit("sunda_ca", 1.0)
	check(b.state == FacelessCaptain.State.STUN and b.banner == null and b._ranks.is_empty(), "Ca burns the banner: ranks gone, stun")
	check(BossKit.is_open(b) and kinds == ["faceless_captain"], "answered: TERBUKA and the codex line")
	step(b, int(3.3 / DT))
	check(b.state == FacelessCaptain.State.STUN, "stunned 3.3 s in")
	step(b, int(0.4 / DT))
	check(b.state != FacelessCaptain.State.STUN, "stun over after 3.5 s")

	# Phases at 66% and 33%: more ranks each time.
	b.health.take_damage(b.health.hp - int(b.health.max_hp * 0.66), player)
	check(b.phase == 2, "phase 2 at 66%")
	b._clear_banner()
	b._plant_banner(Vector2(150, 135))
	check(b._ranks.size() == 6, "phase 2: 6 ranks")
	b.health.take_damage(b.health.hp - int(b.health.max_hp * 0.33), player)
	check(b.phase == 3, "phase 3 at 33%")
	b._clear_banner()
	b._plant_banner(Vector2(150, 135))
	check(b._ranks.size() == 8, "phase 3: 8 ranks")
	b._clear_banner()

	# Release.
	b.health.take_damage(b.health.hp, player)
	for i in 30:
		await physics_frame
	check(defeated == ["faceless_captain"] and "faceless_captain" in game.killed, "boss_defeated emitted, killed recorded")
	var again := (load("res://entities/bosses/faceless_captain.tscn") as PackedScene).instantiate()
	root.add_child(again)
	check(again.is_queued_for_deletion(), "stays dead")
	quit(1 if fails > 0 else 0)
