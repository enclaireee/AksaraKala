extends SceneTree
## Faceless Captain: phases, muster adds, Burst breaks the muster, release, stays dead.

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


func step(b: Node, frames: int) -> void:
	for i in frames:
		b._physics_process(DT)


func step_to(b: Node, s: int, frames := 900) -> void:
	for i in frames:
		if b.state == s:
			return
		b._physics_process(DT)


func _faceless() -> int:
	var n := 0
	for c in root.get_children():
		n += int(c.get("kind") == "faceless")
	return n


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

	check(b.is_in_group("boss") and b.health.max_hp == 1800 and b.phase == 1, "starts phase 1, 1800 HP")
	step(b, 600)
	check(b.attacks > 0 and b.engaged, "attacks")

	# Muster 1 at 66%: Burst during the wind-up breaks it.
	b.health.take_damage(613, player)
	check(b.phase == 2, "phase 2 at 66%")
	step_to(b, FacelessCaptain.State.MUSTER)
	check(b.state == FacelessCaptain.State.MUSTER, "muster wind-up")
	var fp := FakePlayer.new()
	fp.add_child(fp.health)
	fp.position = Vector2(-1000, 0)
	root.add_child(fp)
	var bd := SpellData.for_glyph("sunda_ca")
	var burst := bd.scene.instantiate()
	burst.caster = fp
	burst.data = bd
	root.add_child(burst)
	b.hurtbox.receive(burst)
	check(b.state == FacelessCaptain.State.STUN and kinds == ["faceless_captain"], "Burst breaks the muster")
	step(b, 100)   # past the 2 s stun
	for i in 40:
		await physics_frame
	check(_faceless() == 0, "broken muster calls no adds")

	# Muster 2 at 33%: left alone, 2 Faceless after the warning.
	b.health.take_damage(594, player)
	check(b.phase == 3, "phase 3 at 33%")
	step_to(b, FacelessCaptain.State.MUSTER)
	step(b, int(b.muster_windup / DT) + 2)
	check(b.state == FacelessCaptain.State.RECOVER and _faceless() == 0, "warning first, no adds yet")
	for i in 40:
		await physics_frame
	check(_faceless() == 2, "muster calls 2 Faceless (%d)" % _faceless())
	for c in root.get_children():
		if c.get("kind") == "faceless":
			c.free()

	# Release.
	b.health.take_damage(b.health.hp, player)
	for i in 30:
		await physics_frame
	check(defeated == ["faceless_captain"] and "faceless_captain" in game.killed, "boss_defeated emitted, killed recorded")
	var again := (load("res://entities/bosses/faceless_captain.tscn") as PackedScene).instantiate()
	root.add_child(again)
	check(again.is_queued_for_deletion(), "stays dead")
	quit(1 if fails > 0 else 0)
