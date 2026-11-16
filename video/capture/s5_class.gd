extends "res://video/capture/s5_lib.gd"
## Base of the s5_class_<id> montage clips: the class in a zone of its own, hero centred at the same camera
## distance, a small pack closing in, two basic attacks and the class's signature aksara. HUD on. ~4.5 s.
## A shot sets: cls, zone, at (world px), foes (enemy kinds), glyph (signature), attacks.

var cls := "warrior"
var zone_id := "ts_kebun"
var at := Vector2.ZERO
var foes: Array = ["faceless", "faceless", "jurig_leuweung"]
var glyph := "sunda_ha"
var attacks := 2
var radius := 105.0
var pre_cast := 0.9      # seconds of attacks before the cast
var after := 2.0


func config() -> Dictionary:
	return {"music": false, "max_seconds": 600}


func run() -> void:
	await start_new(cls, zone_id)
	make_strong(20)
	clear_enemies()
	for b in get_tree().get_nodes_in_group("boss") + get_tree().get_nodes_in_group("arena_gate"):
		b.queue_free()
	for n in zone().get("entities").get_children():
		if n.get("boss_name_key") != null:
			n.queue_free()
	if boss_stage():
		boss_stage().visible = false
	for n in get_tree().get_nodes_in_group("npc"):
		n.queue_free()
	god = true
	infinite_sakti = true
	infinite_stamina = true
	show_hud()
	if at == Vector2.ZERO:   # no known open spot: a little way in from the arrival spawn
		at = hero().global_position + Vector2(150, 0)
	teleport(at)
	await wait_frames(2)
	var es: Array = []
	for i in foes.size():
		var a := -PI * 0.5 + TAU * (float(i) + 0.5) / foes.size() + 0.3
		es.append(spawn_enemy(foes[i], at + Vector2.from_angle(a) * Vector2(radius * 1.3, radius * 0.8), true))
	face(Vector2.RIGHT)
	await wait_seconds(1.2)
	cam_detach(at + Vector2(0, -12))   # a still camera: the same framing every clip, and a steady stroke
	rec_start()
	for e in es:
		wake(e)
	await wait_seconds(0.4)
	var near: Node2D = es[0]
	for e in es:
		if is_instance_valid(e) and e.global_position.distance_to(at) < near.global_position.distance_to(at):
			near = e
	await attack(attacks, near.global_position)
	await wait_seconds(maxf(0.0, pre_cast - attacks * 16.0 / 60.0))
	var aim: Vector2 = near.global_position if is_instance_valid(near) else at + Vector2.RIGHT * 60
	var r := await cast_glyph(glyph, {"center": Vector2(240, 92), "size": 92.0, "seconds": 1.1, "aim_at": aim, "jitter": 0.0})
	mark("cast_" + glyph)
	await wait_seconds(after)
	rec_stop()
