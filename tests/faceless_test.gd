extends SceneTree
## Faceless tier scaling by zone prefix (balance.md 6.2) and the cond gate on Encounter and bosses.

var fails := 0


class FakeZone extends Node2D:
	var zone_id := "gk_x"


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _spawn(path: String, parent: Node = root) -> EnemyBase:
	var e := (load(path) as PackedScene).instantiate() as EnemyBase
	parent.add_child(e)
	return e


func _initialize() -> void:
	await process_frame
	var game := root.get_node("Game")
	var zones := root.get_node("Zones")
	game.save_path = "user://test_faceless.json"
	var f := _spawn("res://entities/enemies/faceless.tscn")
	check(f.kind == "faceless" and f.health.max_hp == 40 and f.attack_hitbox.damage == 8 and f.ilmu == 6, "tier 0 by default (hp %d)" % f.health.max_hp)
	f.free()
	for row in [["ts_kebun", 40, 8, 6], ["mt_sawah", 52, 9, 9], ["kg_x", 52, 9, 9], ["tt_pasir", 64, 10, 14]]:
		zones.current_zone = row[0]
		f = _spawn("res://entities/enemies/faceless.tscn")
		check(f.health.max_hp == row[1] and f.health.hp == row[1] and f.attack_hitbox.damage == row[2] and f.ilmu == row[3],
				"%s: hp %d dmg %d ilmu %d" % [row[0], f.health.max_hp, f.attack_hitbox.damage, f.ilmu])
		f.free()
	zones.current_zone = "mt_sawah"
	var a := _spawn("res://entities/enemies/faceless_archer.tscn")
	check(a.kind == "faceless_archer" and a.health.max_hp == 52, "archer scales too (hp %d)" % a.health.max_hp)
	a.free()
	var z := FakeZone.new()
	root.add_child(z)
	f = _spawn("res://entities/enemies/faceless.tscn", z)
	check(f.health.max_hp == 88 and f.ilmu == 31, "zone_id of the parent zone wins over Zones.current_zone (hp %d)" % f.health.max_hp)
	z.free()
	zones.current_zone = ""

	# cond on bosses: hidden and inert until the flag holds.
	for path in ["sangkuriang", "bandung_bondowoso", "faceless_captain", "nameless_hunter"]:
		var b := (load("res://entities/bosses/%s.tscn" % path) as PackedScene).instantiate() as EnemyBase
		b.set("cond", "flag:cond_test_" + path)
		root.add_child(b)
		await process_frame
		check(not b.visible and not b.get("active") and not b.is_in_group("enemy"), path + " hidden and inert while cond is false")
		game.set_flag("cond_test_" + path, false)
		check(b.visible and b.get("active") and b.is_in_group("enemy"), path + " active once cond holds")
		b.free()

	# cond on Encounter.
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	player.collision_layer = 2
	var cs := CollisionShape2D.new()
	cs.shape = CircleShape2D.new()
	player.add_child(cs)
	player.position = Vector2(300, 135)
	root.add_child(player)
	var enc := (load("res://entities/world/encounter.tscn") as PackedScene).instantiate()
	enc.position = Vector2(300, 135)
	enc.area_id = "cond_test"
	enc.cond = "flag:enc_cond"
	enc.waves = [[["res://entities/enemies/faceless.tscn", Vector2i(3, 0)]]]
	root.add_child(enc)
	for i in 6:
		await physics_frame
	check(not enc._started and get_nodes_in_group("enemy").is_empty(), "encounter with a false cond does not start")
	game.set_flag("enc_cond", false)
	for i in 6:
		await physics_frame
	check(enc._started and get_nodes_in_group("enemy").size() == 1, "encounter starts once cond holds, player already inside")
	quit(1 if fails > 0 else 0)
