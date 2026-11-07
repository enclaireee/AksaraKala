extends SceneTree
## Verifies Phase 6 sprite sheets and runtime attachment across hero classes, enemies, bosses, and NPCs.

var fails := 0


func check(cond: bool, msg: String) -> void:
	if not cond:
		print("FAIL: ", msg)
		fails += 1


func _initialize() -> void:
	await process_frame
	# 1. Hero sheets
	for cls: String in ["base", "warrior", "archer", "rogue", "mage"]:
		var p := "res://assets/art/hero_%s.png" % cls
		var tex := load(p) as Texture2D
		check(tex != null, "hero sheet exists: " + p)
		if tex:
			check(tex.get_width() == 144 and tex.get_height() == 432, "hero sheet 144x432 (6 cols x 18 rows of 24x24): " + p)

	# 2. NPC sheet & regional world tilesets
	var npc_tex := load("res://assets/art/npcs.png") as Texture2D
	check(npc_tex != null and npc_tex.get_width() == 64 and npc_tex.get_height() == 288, "npcs.png 64x288")
	for reg: String in ["sunda", "galuh", "mataram", "timur", "kidul", "kala", "kelir"]:
		var tp := "res://assets/art/tiles_%s.png" % reg
		var ttex := load(tp) as Texture2D
		check(ttex != null and ttex.get_width() == 128 and ttex.get_height() == 256, "regional tileset 128x256: " + tp)
	var ts := load("res://zones/tiles.tres") as TileSet
	check(ts != null and ts.get_source_count() == 7, "zones/tiles.tres has 7 regional sources")
	for sid: int in 7:
		check(ts != null and ts.has_source(sid), "tiles.tres has source %d" % sid)
		if ts and ts.has_source(sid):
			var atlas := ts.get_source(sid) as TileSetAtlasSource
			check(atlas.has_tile(Vector2i(7, 15)), "source %d has 8x16 (128) tiles up to (7,15)" % sid)
	var z := Zone.new()
	z.zone_id = "desa_purwa"
	check(z.sub_biome() == 0, "desa_purwa sub_biome == 0")
	z.zone_id = "ts_hutan"
	check(z.sub_biome() == 1, "ts_hutan sub_biome == 1")
	z.zone_id = "ts_kawah_boss"
	check(z.sub_biome() == 2, "ts_kawah_boss sub_biome == 2")
	z.free()

	# 3. Enemy & Boss scenes attach EnemyArt
	var enemy_scenes: Array[String] = [
		"arca", "arca_penjaga", "bajul_putih", "bajul_putih_tua", "banaspati", "banaspati_elite",
		"bandit", "bandit_archer", "chaser", "dummy", "faceless", "faceless_archer", "faceless_champion",
		"genderuwo", "jurig_leuweung", "jurig_leuweung_elite", "kemamang", "keris_hantu", "kuntilanak",
		"kuntilanak_elite", "lampor", "pocong", "prajurit_terkutuk", "ririwa", "shooter", "tank",
		"tuyul", "tuyul_leader", "ula_segara", "wewe_gombel", "wewe_elite", "wild_boar", "wild_boar_elite",
		"yuyu_kangkang",
	]
	var boss_scenes: Array[String] = [
		"bandung_bondowoso", "barma_wijaya", "batara_kala", "buto_ijo", "faceless_captain",
		"hariang_banga", "keris_gandring", "nameless_hunter", "sandekala", "sangkuriang",
	]
	for n: String in enemy_scenes:
		_check_sheet("res://assets/art/enemies/%s.png" % n, n)
	for n: String in boss_scenes:
		_check_sheet("res://assets/art/enemies/%s.png" % n, n)

	# 4. Live runtime attachment on EnemyBase in tree
	var box := Node2D.new()
	root.add_child(box)
	for path: String in [
		"res://entities/enemies/chaser.tscn",
		"res://entities/enemies/shooter.tscn",
		"res://entities/enemies/wild_boar_elite.tscn",
		"res://entities/bosses/sandekala.tscn",
	]:
		var inst := (load(path) as PackedScene).instantiate() as CharacterBody2D
		box.add_child(inst)
		await process_frame
		var body_node := inst.get_node("Body") as Polygon2D
		var art := body_node.get_node_or_null("Art") as Sprite2D
		check(art != null and art.texture != null, "live EnemyArt attached: " + path)
		check(is_zero_approx(body_node.color.a), "placeholder polygon hidden: " + path)
	await process_frame
	box.free()

	quit(1 if fails > 0 else 0)


func _check_sheet(tex_path: String, label: String) -> void:
	var tex := load(tex_path) as Texture2D
	check(tex != null, "sheet loads: " + label)
	if tex:
		check(tex.get_width() % 4 == 0 and tex.get_height() % 4 == 0, "4x4 sheet: " + label)
