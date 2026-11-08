class_name Portraits
## Speaker id (the <ID> of NPC_<ID>_NAME, lower case) -> portrait name in assets/art/portraits/p_<name>.png
## (tools/gen_speaker_portraits.py, 48x48, ui.md 3.1). Each bust has mood variants p_<name>_<mood>.png (MOODS);
## for_key(key, mood) falls back to the neutral bust. ASSUMED: archetype picks for minor NPCs; unlisted speakers show no portrait.

const MAP := {
	"hero": "hero", "semar": "semar", "cepot": "cepot", "laras": "laras", "hunter": "hunter",
	"faceless_deserter": "faceless", "ririwa_name": "faceless", "ririwa_roll": "faceless", "tuyul_leader": "child",
	"batara_kala": "kala", "hariang_banga": "royal_m", "barma_wijaya": "royal_m", "bandung_bondowoso": "bondowoso",
	"ciung_wanara": "ciung_wanara", "nagawiru": "royal_m",
	"sunda_elder": "elder_m", "kepala_desa": "elder_m", "juru_kunci": "elder_m", "ki_darsa": "elder_m",
	"kidul_tua": "elder_m", "pak_karto": "elder_m", "lengser": "elder_m", "purwa_old_couple": "elder_m",
	"nini": "elder_f", "mbok_srini": "elder_f",
	"ibu": "woman", "sunda_mother": "woman", "sunda_weaver": "woman_b", "dayang_sumbi": "dayang_sumbi", "nyai_rukmi": "woman",
	"nyai_sekar": "woman_b", "kidul_sari": "woman_b", "lesung_women": "woman", "purbasari": "purbasari",
	"naganingrum": "woman", "nawang_wulan": "nawang_wulan", "tea_picker": "woman_b", "kaputren_maid": "woman",
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
const MOODS: Array[String] = ["happy", "angry", "sad"]   # plus the neutral base file
static var _cache := {}


## Portrait name for a speaker key ("NPC_CEPOT_NAME"), or "" when that speaker has none.
static func name_for_key(key: String) -> String:
	if not (key.begins_with("NPC_") and key.ends_with("_NAME")):
		return ""
	var id := key.trim_prefix("NPC_").trim_suffix("_NAME").to_lower()
	return MAP.get(id, "")


## Texture for a speaker key in a mood ("" or "neutral" = the base bust), or null when that speaker has none.
## An unknown or missing mood falls back to the neutral bust.
static func for_key(key: String, mood := "") -> Texture2D:
	var pname := name_for_key(key)
	if pname == "":
		return null
	if mood != "" and mood != "neutral" and MOODS.has(mood):
		var t := _load("p_%s_%s" % [pname, mood])
		if t != null:
			return t
	return _load("p_" + pname)


static func _load(file: String) -> Texture2D:
	if not _cache.has(file):
		var path := "res://assets/art/portraits/%s.png" % file
		_cache[file] = load(path) if ResourceLoader.exists(path) else null
	return _cache[file]


## Splits inline "#face:<mood>" tags out of a shown line: returns [clean text, last mood or ""].
static func strip_face(text: String) -> Array:
	var re := RegEx.create_from_string("\\s*#face:([a-z_]+)\\s*")
	var mood := ""
	for m in re.search_all(text):
		mood = m.get_string(1)
	return [re.sub(text, " ", true).strip_edges() if mood != "" else text, mood]
