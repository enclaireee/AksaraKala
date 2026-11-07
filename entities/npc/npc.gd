class_name Npc extends Interactable
## Runs data/dialogue/<npc_id>.tres (quests.md 7). Indicator: gold lontar when a non-fallback entry
## currently passes (new or advancing quest talk), grey otherwise; bobs when gold (7.6). Hub and topic entries
## ("Ask about...", script.md 2) never light it, and hubs and topics never count as the talk (talked_to).

@export var npc_id := ""
@export var cond := ""   # hidden and not interactable while Game.check(cond) is false

const DRESSING := [
	"villager", "laras_crowd", "laras_tag", "stray_cat", "galuh_crowd",
	"nelayan_jala", "faceless_captain_seen", "wirasana_daughter",
]

const SHEET: Texture2D = preload("res://assets/art/npcs.png")

var data: DialogueData   # tests may preset this
var _busy := false
var _gold := false
var _t := 0.0
var _last_frame := -1


func _ready() -> void:
	verb = "UI_VERB_TALK"
	super()
	if data == null:
		data = DialogueData.by_id(npc_id)
	if data == null and npc_id not in DRESSING:
		push_warning("npc '%s': no dialogue data" % npc_id)
	var ev := get_node("/root/Events")
	for s in [ev.quest_started, ev.quest_updated, ev.quest_completed, ev.talked_to]:
		s.connect(func(_a: Variant = null) -> void: _recompute())
	var game := get_node("/root/Game")
	game.changed.connect(_apply_cond)
	_apply_cond()
	_recompute()


func _apply_cond() -> void:
	var on: bool = get_node("/root/Game").check(cond)
	visible = on
	usable = on and data != null   # dressing NPCs have no dialogue: no Talk prompt
	if not on:
		_prompt.visible = false
	elif _near:
		_refresh_prompt()


func _recompute() -> void:
	_gold = false
	if data:
		var game := get_node("/root/Game")
		for i in data.entries.size() - 1:   # last entry is the fallback
			var en: Dictionary = data.entries[i]
			if en.get("hub", false) or en.has("topic"):
				continue
			if en.get("if", []).all(func(c: String) -> bool: return game.check(c)):
				_gold = true
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	var f := int(_t * 3.5) % 4
	if _gold or f != _last_frame:
		_last_frame = f
		queue_redraw()


func _row() -> int:
	if npc_id in ["semar", "semar_kala"]:
		return 4
	if npc_id == "cepot":
		return 5
	if npc_id == "laras":
		return 6
	if npc_id in ["lutung_kasarung", "stray_cat"]:
		return 8
	if "lamp" in npc_id:
		return 11
	if npc_id.begins_with("door_") or npc_id.begins_with("sluice_") or npc_id in ["galuh_wagon", "purwa_stall"]:
		return 10
	if "stone" in npc_id or "altar" in npc_id or npc_id.begins_with("batu_") or npc_id in ["arca_base", "beats", "ririwa_name"]:
		return 9
	if npc_id in ["ciung_wanara", "purbasari", "nawang_wulan", "klething_kuning", "naganingrum", "galuh_queen"]:
		return 3
	if npc_id in ["ibu", "dayang_sumbi", "sunda_weaver", "tea_picker", "lesung_women", "leuwi_mother", "mbok_srini", "nini_balangantrang", "nyai_rukmi", "nyai_sekar", "g2_maid", "kidul_sari", "timur_daughter", "wirasana_daughter"]:
		return 2
	if npc_id in ["sunda_elder", "kepala_desa", "juru_kunci", "kidul_jurukunci", "lengser", "mataram_dalang", "ki_darsa", "ki_sumarto", "pak_karto", "nagawiru", "purwa_old_couple", "kidul_nelayan_tua"]:
		return 1
	if npc_id in ["pande_besi", "m3_smith", "timur_empu", "aria_kebonan", "pangrenyep", "galuh_official", "galuh_herald", "recruiter_a", "recruiter_b", "hariang_banga", "nameless_hunter", "faceless_deserter", "faceless_captain_seen"]:
		return 7
	return 0


func _draw() -> void:
	draw_rect(Rect2(-5, -1, 10, 3), Color(0.09, 0.07, 0.16, 0.42))
	if SHEET:
		var col := int(_t * 3.5) % 4
		var row := _row()
		draw_texture_rect_region(SHEET, Rect2(-8, -22, 16, 24), Rect2(col * 16, row * 24, 16, 24))
	else:
		draw_rect(Rect2(-6, -8, 12, 16), Color(0.55, 0.4, 0.3))
	if data != null:
		var y := -26.0 + (sin(_t * 5.0) * 2.0 if _gold else 0.0)
		draw_rect(Rect2(-4, y - 1, 8, 6), Color(0.09, 0.07, 0.16, 0.9))
		draw_rect(Rect2(-3, y, 6, 4), Color(1.0, 0.82, 0.2) if _gold else Color(0.55, 0.55, 0.6))


func interact() -> void:
	if _busy or data == null:
		return
	var e: Dictionary = get_node("/root/Game").pick_entry(data.entries)   # skips topic entries
	if e.is_empty():
		return
	_busy = true
	var ev := get_node("/root/Events")
	await get_node("/root/Game").play(data.name_key, e, data.entries)   # lines, choices, then the actions (a hub loops its topics)
	_busy = false
	if not (e.get("quiet", false) or e.get("hub", false) or e.has("topic")):   # a quiet entry (a refusal) does not count as the talk
		ev.talked_to.emit(npc_id)
	_recompute()
