extends "res://tests/kala_play_test.gd"
## Headless play-through of Act V (Segara Kidul: MQ4, SQ-K1, SQ-K2) across all 4 sk_* areas,
## verifying tile reachability, encounters, Trial of the Waves, jawa_ka write card, chests, and shortcuts.

const KIDUL_ROUTE := [
	# Enter sk_karang from tt_pesisir after MQ3 is done (mq3_8 open, mq4 active at step 0).
	"go:sk_karang", "q:mq4=active:1",
	"chest:kidul_chest_2",
	# Start SQ-K2 with Pak Raka (kidul_nelayan_tua), enter south-east cove, kill Bajul Putih Tua, report back -> Cakra reward.
	"do:kidul_nelayan_tua", "q:sq_k2=active:1",
	"do:kidul_elite_cove", "q:sq_k2=active:2",
	"kill:bajul_putih_tua", "q:sq_k2=active:3",
	"do:kidul_nelayan_tua", "q:sq_k2=done", "has:cakra",
	# Clear sk_karang encounters -> mq4 step 2.
	"do:kidul_karang_1", "do:kidul_karang_2", "q:mq4=active:2", "do:kidul_karang_3",
	# Walk west into sk_pantai, start SQ-K1 with Damar, rescue 3 hatchlings, release at surf -> Herb Pouch reward.
	"go:sk_pantai", "chest:kidul_chest_1",
	"do:kidul_pantai_1", "do:kidul_pantai_2", "do:kidul_pantai_3",
	"do:kidul_nelayan_anak", "q:sq_k1=active:1",
	"do:tukik_1", "do:tukik_2", "do:tukik_3", "q:sq_k1=active:2",
	"do:kidul_tukik_laut", "q:sq_k1=active:3",
	"do:kidul_nelayan_anak", "q:sq_k1=done",
	# Rest at kidul_1 -> mq4 step 3; talk to Nyai Ranti -> mq4 step 4; pass Trial of the Waves -> mq4 step 5 + beat_kidul_trial.
	"do:kidul_1", "q:mq4=active:3",
	"do:kidul_jurukunci", "q:mq4=active:4",
	"do:kidul_trial", "q:mq4=active:5", "beat:kidul_trial",
	# Return east to sk_karang and cross south causeway (kabut mq4_5 lifted) into sk_keraton.
	"go:sk_karang", "go:sk_keraton",
	# Clear outer court -> mq4 step 6; rest at inner pendopo kidul_2 -> mq4 step 7; inscribe jawa_ka at Sea Altar -> mq4 step 8.
	"do:kidul_keraton_1", "q:mq4=active:6",
	"do:nyi_roro_kidul",
	"do:kidul_2", "q:mq4=active:7",
	"do:kidul_altar", "write:ombak:jawa_ka", "q:mq4=active:8",
	# Open sc:sk_gerbang shortcut back to sk_pantai, ascend sk_tebing, clear summit -> mq4 done + kain_hijau + beat_kidul.
	"go:sk_pantai", "do:sc:sk_gerbang",
	"go:sk_tebing", "do:kidul_tebing_1", "chest:kidul_chest_3",
	"do:kidul_tebing_2", "q:mq4=done", "has:kain_hijau", "beat:kidul",
	# Verify cliff shortcut into Tatar Sunda (ts_situ) and back, then one-way drop into sk_keraton.
	"go:ts_situ", "do:sc:ts_sk", "go:sk_tebing", "go:sk_keraton",
]


func _initialize() -> void:
	await process_frame
	game = root.get_node("Game")
	events = root.get_node("Events")
	game.save_path = "user://test_kidul_play.json"
	for f in ["mq0_done", "mq1_10", "mqg_7", "mq2_9", "mq3_8",
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
	await root.get_node("Zones").go_to("tt_pesisir", "from_tt_sabana")
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
