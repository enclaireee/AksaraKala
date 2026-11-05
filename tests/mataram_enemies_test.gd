extends SceneTree
## Mataram enemies: scene stats, Arca dormancy, quest elites inert until their step. Steps enemies by hand.

const DT := 1.0 / 60.0
const PATH := "user://test_mataram.json"
var fails := 0
var player: CharacterBody2D


func _initialize() -> void:
	var game := root.get_node("Game")
	game.save_path = PATH
	game._reset()
	player = CharacterBody2D.new()
	player.add_to_group("player")
	player.position = Vector2(170, 135)
	root.add_child(player)
	await process_frame

	# stats
	for row in [
		["tuyul", 31, "tuyul", 4], ["pocong", 78, "pocong", 14], ["arca", 78, "arca", 14],
		["genderuwo", 195, "genderuwo", 22], ["wewe_gombel", 780, "wewe_elite", 90], ["tuyul_leader", 600, "tuyul_leader", 60],
	]:
		var e := await _spawn(row[0], Vector2(1000, 1000))
		check(e.health.max_hp == row[1] and e.kind == row[2] and e.ilmu == row[3], "%s stats" % row[0])
		e.free()

	# Arca: dormant until the player is inside the wake radius, then shoots
	var a := await _spawn("arca", Vector2(300, 135)) as Arca
	check(not a.is_in_group("enemy"), "dormant arca is not an enemy target")
	player.position = Vector2(170, 135)   # 130 px: inside its firing reach, outside the wake radius
	for i in 300:
		a._physics_process(DT)
	check(not a.awake and a.state == Shooter.State.IDLE and a.body.modulate == Color.WHITE, "dormant at 130 px")
	check(_shots() == 0 and not a.has_token, "no shots, no token while dormant")
	player.position = Vector2(300 - Arca.WAKE_RADIUS - 1.0, 135)
	for i in 60:
		a._physics_process(DT)
	check(not a.awake, "still dormant just outside the wake radius")
	player.position = Vector2(300 - Arca.WAKE_RADIUS + 1.0, 135)
	for i in 400:
		a._physics_process(DT)
		if _shots() > 0:
			break
	check(a.awake and a.is_in_group("enemy"), "awake inside the wake radius")
	check(_shots() == 1, "arca fires a bolt")
	check(a.global_position == Vector2(300, 135), "arca never moves")
	a.free()
	for n in root.get_children():
		if n is Arrow:
			n.free()

	# Elites: inert until their quest step
	for row in [["wewe_gombel", "sq_m2", "wewe_elite"], ["tuyul_leader", "sq_m3", "tuyul_leader"]]:
		game.quests.erase(row[1])
		var e := await _spawn(row[0], Vector2(100, 100))
		check(not e.active and not e.visible and not e.is_in_group("enemy") and e.collision_layer == 0 and not e.is_physics_processing(), "%s inactive early" % row[0])
		game.quests[row[1]] = {"state": "active", "step": 1, "count": 0}
		game.changed.emit()
		check(not e.active, "%s still inactive at step 1" % row[0])
		game.quests[row[1]] = {"state": "active", "step": 2, "count": 0}
		game.changed.emit()
		check(e.active and e.visible and e.is_in_group("enemy") and e.collision_layer == 4 and e.is_physics_processing(), "%s active at step 2" % row[0])
		e.free()
		# already at step 2 when it spawns
		e = await _spawn(row[0], Vector2(100, 100))
		check(e.active and e.visible and e.is_in_group("enemy"), "%s active when spawned at step 2" % row[0])
		e.free()
		game.quests.erase(row[1])
		game.killed.erase(row[2])

	# Wewe's grab: telegraphed, pulls the player in, dodgeable with i-frames
	game.quests["sq_m2"] = {"state": "active", "step": 2, "count": 0}
	var w := await _spawn("wewe_gombel", Vector2(100, 135)) as WeweGombel
	player.position = Vector2(170, 135)
	w.grab_cd = 0.0
	for i in 600:
		if w.grabbing:
			break
		w._physics_process(DT)
	check(w.grabbing and w.line.visible, "grab is telegraphed")
	for i in 100:
		w._physics_process(DT)
	check(not w.grabbing and player.position.x < 130.0, "grab pulled the player in (x %f)" % player.position.x)
	w.free()
	w = await _spawn("wewe_gombel", Vector2(100, 135)) as WeweGombel
	player.position = Vector2(170, 135)
	w.grab_cd = 0.0
	for i in 600:
		if w.grabbing:
			break
		w._physics_process(DT)
	player.position = Vector2(170, 200)   # stepped off the line
	for i in 100:
		w._physics_process(DT)
	check(player.position == Vector2(170, 200), "dodged by leaving the line")
	w.free()
	game.quests.erase("sq_m2")

	for p in [PATH, PATH.get_basename() + ".bak", PATH + ".tmp"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)
	quit(1 if fails > 0 else 0)


func _shots() -> int:
	var n := 0
	for c in root.get_children():
		n += int(c is Arrow)
	return n


func _spawn(n: String, pos: Vector2) -> EnemyBase:
	var e := (load("res://entities/enemies/%s.tscn" % n) as PackedScene).instantiate() as EnemyBase
	e.position = pos
	root.add_child(e)
	await process_frame
	e.set_physics_process(false)
	return e


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: ", msg)
