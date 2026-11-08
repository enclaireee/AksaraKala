class_name Portraits
## Speaker id (the <ID> of NPC_<ID>_NAME, lower case) -> portrait name in assets/art/portraits/p_<name>.png
## (tools/gen_speaker_portraits.py). ASSUMED: archetype picks for minor NPCs; unlisted speakers show no portrait.

const MAP := {
	"hero": "hero", "semar": "semar", "cepot": "cepot", "laras": "laras", "hunter": "hunter",
	"faceless_deserter": "faceless", "ririwa_name": "faceless", "ririwa_roll": "faceless", "tuyul_leader": "child",
	"batara_kala": "kala", "hariang_banga": "royal_m", "barma_wijaya": "royal_m", "bandung_bondowoso": "royal_m",
	"ciung_wanara": "royal_m", "nagawiru": "royal_m",
	"sunda_elder": "elder_m", "kepala_desa": "elder_m", "juru_kunci": "elder_m", "ki_darsa": "elder_m",
	"kidul_tua": "elder_m", "pak_karto": "elder_m", "lengser": "elder_m", "purwa_old_couple": "elder_m",
	"nini": "elder_f", "mbok_srini": "elder_f",
	"ibu": "woman", "sunda_mother": "woman", "sunda_weaver": "woman_b", "dayang_sumbi": "woman", "nyai_rukmi": "woman",
	"nyai_sekar": "woman_b", "kidul_sari": "woman_b", "lesung_women": "woman", "purbasari": "woman_b",
	"naganingrum": "woman", "nawang_wulan": "woman_b", "tea_picker": "woman_b", "kaputren_maid": "woman",
	"dayang_ratu": "woman", "m2_parents": "woman", "wewe_parents": "woman", "wewe_parents_2": "woman",
	"galuh_seller": "woman_b", "purwa_stall": "woman",
	"sapto": "man", "ranga": "man", "wiryo": "man", "kabayan": "man", "hauler": "man", "door_neighbour": "man",
	"m2_neighbour": "man", "wewe_neighbor": "man", "pasar_informant": "man", "pasar_refugee": "man",
	"angklung_leader": "man", "kepang_leader": "man", "klething_kuning": "man", "k2_fisher": "farmer",
	"kidul_nelayan_anak": "child", "kidul_anak": "child", "sunda_grandson": "child", "timur_daughter": "child",
	"sawah_farmer": "farmer", "t2_herder": "farmer", "timur_herder": "farmer", "kidul_nelayan": "farmer",
	"pande_besi": "smith", "m3_smith": "smith", "timur_empu": "smith",
	"recruiter_a": "guard", "recruiter_b": "guard", "galuh_herald": "guard", "galuh_official": "guard",
	"pangrenyep": "guard", "aria_kebonan": "guard",
	"galuh_queen": "queen", "ratu_kidul": "sea_queen", "mataram_dalang": "dalang", "lutung_kasarung": "lutung",
	"arca_base": "stone", "batu_tulis": "stone", "pamali_stone": "stone", "memorial_stone": "stone",
	"cliff_altar": "stone", "kidul_altar": "stone", "deserter_stone": "stone",
}
static var _cache := {}


## Texture for a speaker key ("NPC_CEPOT_NAME"), or null when that speaker has none.
static func for_key(key: String) -> Texture2D:
	if not (key.begins_with("NPC_") and key.ends_with("_NAME")):
		return null
	var id := key.trim_prefix("NPC_").trim_suffix("_NAME").to_lower()
	var pname: String = MAP.get(id, "")
	if pname == "":
		return null
	if not _cache.has(pname):
		var path := "res://assets/art/portraits/p_%s.png" % pname
		_cache[pname] = load(path) if ResourceLoader.exists(path) else null
	return _cache[pname]
