extends "res://video/capture/s5_lib.gd"
## Semar, the clown-god and the hero's mentor, teases the hero beside him in Desa Purwa: the real dialogue box with
## his portrait, the line typing out in English. ~6 s.

func config() -> Dictionary:
	return {"music": false}


func run() -> void:
	await start_new("warrior", arg("zone", "desa_purwa"))
	clear_enemies()
	god = true
	hide_hud()
	var s := Vector2.INF
	for n in zone().get("entities").get_children():
		if n.get("npc_id") == arg("npc", "semar"):
			s = n.global_position
	print("s5: npc at ", s)
	if s != Vector2.INF:
		teleport(s + Vector2(30, 4))
		face(Vector2.LEFT)
	await wait_seconds(1.2)
	show_ui(["dialogue"])
	var entry := {"lines": ["@NPC_SEMAR_NAME", "#face:happy", arg("line", "DLG_SEMAR_V1")]}
	rec_start()
	await wait_seconds(0.3)
	G.play("semar", entry)
	await wait_seconds(float(arg("hold", 5.4)))
	rec_stop()
