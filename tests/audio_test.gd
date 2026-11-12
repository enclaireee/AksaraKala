extends SceneTree
## Audio (docs/audio.md): every sound the code can ask for exists as a generated file, each zone has a music + ambience
## plan, the layers pick the right tracks, and playing a missing sound is a silent no-op.

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	await run()
	quit(1 if fails > 0 else 0)


func has_file(rel: String) -> bool:
	for ext: String in [".wav", ".ogg"]:
		if FileAccess.file_exists("res://assets/audio/" + rel + ext) or ResourceLoader.exists("res://assets/audio/" + rel + ext):
			return true
	return false


func run() -> void:
	var a := root.get_node_or_null("Audio")
	check(a != null, "Audio autoload exists")
	if a == null:
		return
	for b in ["Music", "SFX", "Ambience"]:
		check(AudioServer.get_bus_index(b) >= 0, "bus %s exists" % b)

	# --- plans ---
	var p: Dictionary = a.plan_for("ts_kebun")
	check(p.base == "explore_sunda" and p.combat == "combat_sunda" and p.boss == "boss_sunda", "ts_kebun: explore + combat + boss of Sunda")
	check(a.plan_for("desa_purwa").base == "home", "Desa Purwa has the home theme")
	check(a.plan_for("kg_alun").base == "town_galuh" and a.plan_for("kg_pasar").base == "town_galuh", "Galuh towns share a theme")
	check(a.plan_for("ts_kawah").base == "dark_sunda", "the crater is dark")
	check(a.plan_for("gk_ruang_kala").base == "dark_kala", "the sanctum is dark")
	check(a.plan_for("sk_gua").amb == "cave", "the sea cave has cave ambience")
	check(a.plan_for("sk_pantai").surface == "sand", "the beach is sand underfoot")
	check(a.plan_for("hub").base == "select", "the hub plays the select theme")
	check(a.plan_for("fixture_x").base == "", "an unknown / test zone changes nothing")

	# --- every file a plan, a table or the code can ask for exists ---
	var missing := PackedStringArray()
	var zones: Dictionary = root.get_node("Zones").ZONES
	for z: String in zones:
		var pl: Dictionary = a.plan_for(z)
		check(pl.base != "", "zone %s has music" % z)
		for key in ["base", "combat", "boss"]:
			if pl[key] != "" and not has_file("music/" + pl[key]):
				missing.append("music/" + pl[key])
		if pl.amb != "" and not has_file("amb/" + pl.amb):
			missing.append("amb/" + pl.amb)
		if not has_file("sfx/step_" + pl.surface):
			missing.append("sfx/step_" + pl.surface)
	for id in ["intro", "title", "select", "kelir", "ruwatan", "epilogue", "boss_kala_2", "home", "town_kampung", "town_galuh", "town_mataram", "town_kidul"]:
		if not has_file("music/" + id):
			missing.append("music/" + id)
	for k: String in a.SPELL_SFX:
		if not has_file("sfx/spell_" + a.SPELL_SFX[k]):
			missing.append("sfx/spell_" + a.SPELL_SFX[k])
	for j: String in a.JINGLE_HOLD:
		if not has_file("jingle/" + j):
			missing.append("jingle/" + j)
	for id in ["swing_1", "swing_2", "swing_3", "hit_light", "hit_heavy", "hit_kill", "player_hurt", "dodge", "perfect_dodge", "shoot", "flask",
			"stamina_empty", "wrong", "stagger", "enemy_death", "player_death", "cast_begin", "ink", "cast_fail", "cast_ok_low", "cast_ok_mid",
			"cast_ok_high", "cast_perfect", "chest_open", "pickup", "exit", "petilasan", "lontar", "shortcut_open", "puzzle_solve",
			"memory_in", "memory_out", "save", "boss_roar", "boss_slam", "boss_telegraph", "boss_phase", "boss_death", "ui_move", "ui_confirm",
			"ui_back", "ui_open", "ui_close", "ui_page", "ui_slider", "ui_choice", "ui_start", "blip", "arrow_hit", "enemy_telegraph", "kabut", "pickup_rare"]:
		if not has_file("sfx/" + id):
			missing.append("sfx/" + id)
	check(missing.is_empty(), "all referenced audio files exist (missing: %s)" % ", ".join(missing))

	check(a.stream("sfx/hit_light") is AudioStreamRandomizer, "a sound with variation files is a randomizer")
	check(a.stream("sfx/ink", true) != null and a.stream("music/explore_sunda", true) != null, "looped wav and ogg streams load")

	# --- layering ---
	a._on_zone("ts_kebun")
	await process_frame
	check(a._base_id == "explore_sunda" and a._combat_id == "combat_sunda" and a._synced, "field zone: explore with a synced combat layer")
	check(a._amb_id == "forest_day", "ambience follows the zone")
	a._on_zone("ts_kawah")
	check(a._base_id == "dark_sunda" and not a._synced, "dark zone: no combat sync")
	a._on_zone("ts_kampung")
	check(a._base_id == "town_kampung" and a._combat_id == "combat_sunda", "town: town theme, region combat music")
	a._on_cue("music", "kelir")
	check(a._base_id == "kelir" and a._scene_override == "kelir", "#music cue takes over")
	a._on_zone("ts_kebun")
	check(a._scene_override == "" and a._base_id == "explore_sunda", "a zone takes the music back")

	# --- API safety ---
	a.play_sfx("no_such_sound")
	a.play_sfx("sfx_lontar")   # the legacy prefix still resolves
	Snd.play("hit_light")
	Snd.music("title", 0.5)
	check(a._base_id == "title", "scene music via Snd.music")
	a.blip("")
	a.blip("laras")
	a.play_jingle("no_such_jingle")
	await process_frame
	await process_frame
	check(true, "no crash")
