extends "res://video/capture/shot.gd"
## Dev tool: one PNG per UI screen for type and layout checks (ui.md 1). --set out=<abs dir> --set locale=en|id
## Run windowed (no Movie Maker): $GODOT --path . -s res://video/capture/runner.gd -- --shot=_ui_font --out=/abs/dir

func config() -> Dictionary:
	return {"music": false, "sfx": false, "ambience": false, "locale": str(arg("locale", "en"))}


func _snap(n: String) -> void:
	await wait_frames(4)
	var dir: String = str(arg("out", "user://ui_font"))
	DirAccess.make_dir_recursive_absolute(dir)
	RenderingServer.force_draw(false)   # draws even when the OS has stopped drawing a covered window
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, n])
	var gu := game_ui()
	print("ui_font: ", n, " paused=", get_tree().paused, " frame=", Engine.get_frames_drawn(), " dlg=", gu.get_node("DialogueBox").visible if gu else "-", " ts=", Engine.time_scale)


func run() -> void:
	get_tree().change_scene_to_file("res://ui/title.tscn")
	await wait_until(func() -> bool: return get_tree().current_scene != null and get_tree().current_scene.scene_file_path.ends_with("title.tscn"), 120, "title did not load")
	var t := get_tree().current_scene
	await wait_seconds(4.0)
	await _snap("01_title")
	var up := get_node("/root/Updater")   # the update card never shows in a debug run: fake its two longest states
	for s in [up.MANUAL, up.READY]:
		up.info.version = "1.2.0"
		up.state = s
		up.changed.emit()
		await wait_seconds(0.3)
		await _snap("01_title_update%d" % s)
	up.state = up.IDLE
	up.changed.emit()
	for c in ["settings", "about"]:
		t._open_card(c)
		await wait_seconds(0.6)
		await _snap("02_title_" + c)
		t._close_card()
		await wait_seconds(0.4)

	await start_new("warrior", "desa_purwa")
	clear_enemies()
	god = true
	make_strong(6, ["sunda_ka", "sunda_ga", "sunda_nga"])
	await wait_seconds(2.5)
	await _snap("03_hud")
	show_ui(["dialogue"])
	G.play("semar", {"lines": ["@NPC_SEMAR_NAME", "#face:happy",
		"Long ago the old scribes wrote on palm leaves, and every letter they carved still holds a little of the world they knew. Draw it right and it answers you."]})
	await wait_seconds(5.0)
	await _snap("04_dialogue")
	game_ui().get_node("DialogueBox")._close()
	await wait_seconds(0.5)

	EV.quest_started.emit("mq1")
	await wait_seconds(1.2)
	await _snap("05_quest_card")
	await wait_seconds(5.0)

	await show_lesson("sunda_ka")
	await wait_seconds(1.5)
	await _snap("06_glyph_lesson")
	close_lesson()
	await wait_seconds(1.0)

	var menu: Node = game_ui().get_node("Menu")
	for i in 7:
		menu.open(false, i)
		await wait_seconds(0.8)
		await _snap("07_menu_tab%d" % i)
		menu.close()
		await wait_seconds(0.4)
