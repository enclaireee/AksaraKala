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

const TALL_RANGE := 64.0   # px: the grey talk marker shows only this close (ui.md 3b)
const MARKER := "res://assets/art/ui/marker_%s.png"

static var _bounds: Dictionary = {}    # sheet row -> Vector2i(highest, lowest opaque frame row) over its 4 frames
static var _markers: Dictionary = {}   # "quest" / "talk" -> Texture2D or false (file not there yet)

var data: DialogueData   # tests may preset this
var _busy := false
var _gold := false
var _t := 0.0
var _last_frame := -1
var _near_player := false


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
	var near := false
	if data != null and not _gold and usable:
		var pl := get_tree().get_first_node_in_group("player") as Node2D
		near = pl != null and pl.global_position.distance_to(global_position) <= TALL_RANGE
	if _gold or f != _last_frame or near != _near_player:
		_last_frame = f
		_near_player = near
		queue_redraw()


## Highest and lowest opaque rows of a sheet row's frames, so the feet can sit on y 0 over the shadow.
static func frame_bounds(row: int) -> Vector2i:
	if _bounds.is_empty():
		var img: Image = SHEET.get_image() if SHEET else null
		if img != null:
			if img.is_compressed():
				img.decompress()
			for r in img.get_height() / 24:
				var top := 24
				var bot := -1
				for c in 4:
					for y in 24:
						for x in 16:
							if img.get_pixel(c * 16 + x, r * 24 + y).a > 0.1:
								top = mini(top, y)
								bot = maxi(bot, y)
				if bot >= 0:
					_bounds[r] = Vector2i(top, bot)
		_bounds[-1] = Vector2i(2, 21)   # marks the scan as done; also the fallback
	return _bounds.get(row, _bounds[-1])


## res://assets/art/ui/marker_<kind>.png when it exists (checked once), else null.
static func marker_texture(kind: String) -> Texture2D:
	if not _markers.has(kind):
		var path := MARKER % kind
		_markers[kind] = load(path) if ResourceLoader.exists(path) else false
	return _markers[kind] if _markers[kind] is Texture2D else null


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
	var top := -20
	if SHEET:
		var col := int(_t * 3.5) % 4
		var row := _row()
		var fb := frame_bounds(row)
		var y0 := -(fb.y + 1)   # lowest opaque row ends on y 0, over the shadow
		draw_texture_rect_region(SHEET, Rect2(-8, y0, 16, 24), Rect2(col * 16, row * 24, 16, 24))
		top = y0 + fb.x
	else:
		draw_rect(Rect2(-6, -8, 12, 16), Color(0.55, 0.4, 0.3))
		top = -8
	if data == null:
		return
	if _gold:
		var bob := roundi(sin(_t * 4.0))   # +-1 px
		var tex := marker_texture("quest")
		if tex:
			draw_texture(tex, Vector2(-tex.get_width() * 0.5, top - 3 - tex.get_height() + bob))
		else:
			_draw_lontar(Vector2(-3, top - 3 - 9 + bob))
	elif _near_player:
		var tex := marker_texture("talk")
		if tex:
			draw_texture(tex, Vector2(-tex.get_width() * 0.5, top - 3 - tex.get_height()))
		else:
			_draw_dot(Vector2(-3, top - 3 - 5))


## Fallback quest marker: a 7x9 gold lontar leaf with a dark "!" and a 1 px outline.
func _draw_lontar(at: Vector2) -> void:
	var dark := Color(0.09, 0.07, 0.16, 0.95)
	draw_rect(Rect2(at, Vector2(7, 9)), dark)
	draw_rect(Rect2(at + Vector2(1, 1), Vector2(5, 7)), Color(1.0, 0.82, 0.2))
	draw_rect(Rect2(at + Vector2(1, 1), Vector2(5, 1)), Color(1.0, 0.94, 0.55))
	draw_rect(Rect2(at + Vector2(3, 2), Vector2(1, 3)), dark)
	draw_rect(Rect2(at + Vector2(3, 6), Vector2(1, 1)), dark)


## Fallback talk marker: a grey 7x5 speech bubble with three dots.
func _draw_dot(at: Vector2) -> void:
	var dark := Color(0.09, 0.07, 0.16, 0.9)
	draw_rect(Rect2(at, Vector2(7, 5)), dark)
	draw_rect(Rect2(at + Vector2(1, 1), Vector2(5, 3)), Color(0.72, 0.72, 0.78))
	for x in [1, 3, 5]:
		draw_rect(Rect2(at + Vector2(x, 2), Vector2(1, 1)), dark)


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
