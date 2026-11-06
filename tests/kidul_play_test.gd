extends "res://tests/kala_play_test.gd"
## Headless play-through of Act V (Segara Kidul: MQ4, SQ-K1, SQ-K2) across all 4 sk_* areas,
## verifying tile reachability, encounters, Trial of the Waves, jawa_ka write card, chests, and shortcuts.

const KIDUL_ROUTE := [
	# Interlude (4.1-4.2): the riders' goto lands in Desa Purwa (4.1), the Ibu talk sets mq4_2 and lifts the south kabut.
	"q:mq4=active:1", "do:ibu", "q:mq4=active:2", "beat:quiet_house",
	# Act V: south exit to sk_pantai. SQ-K1 (needs mq4_2): rescue 3 hatchlings, release at the surf -> Herb Pouch reward.
	"go:sk_pantai", "chest:kidul_chest_1",
	"do:kidul_pantai_1", "do:kidul_pantai_2", "do:kidul_pantai_3",
	"do:kidul_nelayan_anak", "q:sq_k1=active:1",
	"do:tukik_1", "do:tukik_2", "do:tukik_3", "q:sq_k1=active:2",
	"do:kidul_tukik_laut", "q:sq_k1=active:3",
	"do:kidul_nelayan_anak", "q:sq_k1=done",
	# 4.3 rest at kidul_1; 4.4 Mbah Wiryo.
	"do:kidul_1", "q:mq4=active:3",
	"do:kidul_jurukunci", "q:mq4=active:4",
	# 4.5 cross the reef (kidul_karang_2); SQ-K2 Bajul Putih Tua -> Cakra.
	"go:sk_karang", "chest:kidul_chest_2",
	"do:kidul_nelayan_tua", "q:sq_k2=active:1",
	"do:kidul_elite_cove", "q:sq_k2=active:2",
	"kill:bajul_putih_tua", "q:sq_k2=active:3",
	"do:kidul_nelayan_tua", "q:sq_k2=done", "has:cakra",
	"do:kidul_karang_1", "do:kidul_karang_2", "q:mq4=active:5", "do:kidul_karang_3",
	# 4.6 cliff path (kidul_tebing_2); 4.7 rest at the cliff shrine kidul_3 (+ Laras beat).
	"go:sk_tebing", "do:kidul_tebing_1", "chest:kidul_chest_3",
	"do:kidul_tebing_2", "q:mq4=active:6",
	"do:kidul_3", "q:mq4=active:7", "beat:laras_kidul",
	# Drop onto sk_keraton (the causeway kabut mq4_8 is still shut). 4.8 the trial; 4.9 Sea Altar (Ombak + Kain Hijau).
	"go:sk_keraton",
	"do:kidul_trial", "q:mq4=active:8", "beat:kidul_trial",
	"do:kidul_2",
	"do:kidul_altar", "write:ombak:jawa_ka", "q:mq4=done", "has:kain_hijau", "lesson:", "beat:kidul",
	# The west coral gate leads to sk_pantai, where the gerbang opens from the keraton side; the cliff shortcut into Tatar Sunda opens from sk_tebing.
	"go:sk_pantai", "do:sc:sk_gerbang",
	"go:sk_karang", "go:sk_tebing", "go:ts_situ", "do:sc:ts_sk",
]


func _initialize() -> void:
	await process_frame
	game = root.get_node("Game")
	events = root.get_node("Events")
	game.save_path = "user://test_kidul_play.json"
	for f in ["mq0_done", "mq1_10", "mqg_7", "mq2_9", "mq3_8", "choice_mercy",
			"beat_hunter_raid", "beat_laras_1", "beat_naga", "beat_galuh_bout", "beat_laras_2", "beat_cage",
			"beat_hunter_war", "beat_laras_3", "beat_ford", "beat_truce", "beat_laras_4", "beat_keris",
			"beat_hunter_shrine", "beat_hunter_name"]:
		game.flags[f] = true
	for q in ["mq1", "mqg", "mq2", "mq3"]:
		game.quests[q] = {"state": "done", "step": 0, "count": 0, "resolution": ""}
	for g in ["sunda_ka", "sunda_ga", "sunda_nga", "sunda_ca", "jawa_ha", "jawa_na", "jawa_ca", "jawa_ra"]:
		game.run("learn:" + g)
	game.start_quest("mq4")
	var pouches_before: int = game.herb_pouches
	events.dialogue_requested.connect(_on_dialogue)
	change_scene_to_file(root.get_node("Zones").start_zone)
	await scene_changed
	await _settle()
	var ok := true
	for a: String in KIDUL_ROUTE:
		var kv := a.split(":", true, 1)
		await _drain()
		match kv[0]:
			"beat": ok = check(game.has_flag("beat_" + kv[1]), "beat %s did not play" % kv[1])
			"write": ok = await _write(kv[1])
			"go": ok = await _go(kv[1])
			"do": ok = await _do(kv[1])
			"lesson":   # learning jawa_ka opens its lesson card, which holds the beat back until the player finishes it
				_find("res://ui/glyph_lesson.gd").finish()
				await _drain()
			"kill": ok = _kill(kv[1])
			"q": ok = _expect(kv[1])
			"has": ok = check(game.inventory.has(kv[1]), "missing %s" % kv[1])
			"chest": ok = await _chest(kv[1])
		if not ok:
			printerr("  stopped at '%s' in %s" % [a, zone.zone_id])
			break
	check(game.herb_pouches == pouches_before + 1, "SQ-K1 should grant +1 herb pouch")
	check(game.codex.has("nyi_roro_kidul"), "MQ4 should unlock codex nyi_roro_kidul")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.save_path))
	quit(1 if fails > 0 else 0)
