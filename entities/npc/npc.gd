class_name Npc extends Interactable
## Runs data/dialogue/<npc_id>.tres (quests.md 7). Indicator: gold lontar when a non-fallback entry
## currently passes (new or advancing quest talk), grey otherwise; bobs when gold (7.6). Hub and topic entries
## ("Ask about...", script.md 2) never light it, and hubs and topics never count as the talk (talked_to).

@export var npc_id := ""
@export var cond := ""   # hidden and not interactable while Game.check(cond) is false

const DRESSING := [
	"villager", "laras_crowd", "laras_tag", "stray_cat", "galuh_crowd",
	"nelayan_jala", "faceless_captain_seen", "wirasana_daughter", "market_stranger",
]

const SHEET: Texture2D = preload("res://assets/art/npcs.png")
const CELL := 32   # px: npcs.png cells are 32x32 (the hero cell), 4 idle columns x 17 rows

const TALL_RANGE := 64.0   # px: the grey talk marker shows only this close (ui.md 3b)
const MARKER := "res://assets/art/ui/marker_%s.png"

static var _bounds: Dictionary = {}    # sheet row -> Vector2i(highest, lowest opaque frame row) over its 4 frames
static var _markers: Dictionary = {}   # "quest" / "talk" -> Texture2D or false (file not there yet)
static var _echo_sheet: Texture2D = null   # echo_sheet() cache

var data: DialogueData   # tests may preset this
var _busy := false
var _gold := false
var _t := 0.0
var _last_frame := -1
var _near_player := false
var _echo := false   # echo_<id>: a Gua Kala memory, redrawn every frame for its shimmer


func _ready() -> void:
	verb = "UI_VERB_TALK"
	super()
	_echo = npc_id.begins_with("echo_")
	if data == null:
		data = DialogueData.by_id(npc_id)
	if data == null and npc_id not in DRESSING:
		push_warning("npc '%s': no dialogue data" % npc_id)
	var ev := get_node("/root/Events")
	for s in [ev.quest_started, ev.quest_updated, ev.quest_completed, ev.talked_to]:
		s.connect(func(_a: Variant = null) -> void: _recompute())
	var game := get_node("/root/Game")
	game.changed.connect(_apply_cond)
	game.changed.connect(queue_redraw)   # a prop swaps to its <id>_on art when flag <id> is set
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
	if _gold or _echo or f != _last_frame or near != _near_player:
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
			for r in img.get_height() / CELL:
				var top := CELL
				var bot := -1
				for c in 4:
					for y in CELL:
						for x in CELL:
							if img.get_pixel(c * CELL + x, r * CELL + y).a > 0.1:
								top = mini(top, y)
								bot = maxi(bot, y)
				if bot >= 0:
					_bounds[r] = Vector2i(top, bot)
		_bounds[-1] = Vector2i(3, 30)   # marks the scan as done; also the fallback
	return _bounds.get(row, _bounds[-1])


## res://assets/art/ui/marker_<kind>.png when it exists (checked once), else null.
static func marker_texture(kind: String) -> Texture2D:
	if not _markers.has(kind):
		var path := MARKER % kind
		_markers[kind] = load(path) if ResourceLoader.exists(path) else false
	return _markers[kind] if _markers[kind] is Texture2D else null


## npcs.png with most of its colour drained, built once, for the echoes.
static func echo_sheet() -> Texture2D:
	if _echo_sheet == null:
		var img := SHEET.get_image()
		if img.is_compressed():
			img.decompress()
		img.adjust_bcs(1.4, 0.8, 0.2)   # TUNE: pale, washed-out ghost: brightness, contrast, saturation
		_echo_sheet = ImageTexture.create_from_image(img)
	return _echo_sheet


func _row() -> int:
	var id := npc_id.trim_prefix("echo_")   # a Gua Kala echo reuses its original's row
	# late-game rows first, by exact id, so the substring checks below cannot catch them
	if id in ["kidul_pencari_kepiting", "kidul_pemetik_walet", "kidul_fam_jala", "kidul_fam_bakul", "nelayan_jala", "k2_fisher", "pesisir_fisher"]:
		return 14   # Kidul fisher: iket, rolled trousers, cast net
	if id in ["sabana_old_drover", "sabana_water_warden", "timur_herder", "t2_herder", "kulon_gate_watchman", "ladang_farmer", "ladang_neighbor", "pesisir_salt_raker", "kidul_pedagang_garam"]:
		return 15   # Timur drover: wide straw hat, sarong across the chest, long stick
	if id in ["kidul_warung", "kidul_pemungut_karang"]:
		return 16   # coastal woman: head-cloth, cream kebaya, bakul of fish
	if id in ["sabana_camp_cook", "kidul_dayang", "sawah_farmer"]:   # sawah_farmer: her echo (gk_pasir) calls her "her"
		return 2
	if id in ["kidul_fam_wiryo", "candi_caretaker", "kidul_penjaga_pelita"]:
		return 1
	if id in ["nameless_hunter", "faceless_captain_seen", "market_stranger"]:
		return 12   # tall stranger in the blank mask
	if id == "faceless_deserter":
		return 13   # hooded, face a smooth blank
	if id in ["semar", "semar_kala"]:
		return 4
	if id == "cepot":
		return 5
	if id == "laras" or id.begins_with("laras_"):
		return 6
	if id in ["lutung_kasarung", "stray_cat", "purwa_cat"]:
		return 8
	if "lamp" in id or id.begins_with("leuwi_oncor_"):
		return 11
	if id.begins_with("door_") or id.begins_with("sluice_") or id in ["galuh_wagon", "purwa_stall", "purwa_well", "rarang_post"] or id.begins_with("angklung_frame_") or id.begins_with("kaputren_screen_") or id.begins_with("archive_mirror_"):
		return 10
	if "stone" in id or "altar" in id or id.begins_with("batu_") or id in ["arca_base", "beats", "ririwa_name", "purwa_root"] or id.begins_with("grain_roof_"):
		return 9
	if id in ["ciung_wanara", "purbasari", "nawang_wulan", "klething_kuning", "naganingrum", "galuh_queen"]:
		return 3
	if id in ["ibu", "dayang_sumbi", "sunda_weaver", "tea_picker", "lesung_women", "leuwi_mother", "mbok_srini", "nini_balangantrang", "nyai_rukmi", "nyai_sekar", "g2_maid", "kidul_sari", "timur_daughter", "wirasana_daughter"]:
		return 2
	if id in ["sunda_elder", "kepala_desa", "juru_kunci", "kidul_jurukunci", "lengser", "mataram_dalang", "ki_darsa", "ki_sumarto", "pak_karto", "nagawiru", "purwa_old_couple", "kidul_nelayan_tua"]:
		return 1
	if id in ["pande_besi", "m3_smith", "timur_empu", "aria_kebonan", "pangrenyep", "galuh_official", "galuh_herald", "recruiter_a", "recruiter_b", "hariang_banga"]:
		return 7
	return 0


## Pixel ground shadow (tools/gen_world_fx.py world_fx/shadow_<size>.png), centred on the feet; null when the art is missing.
static func shadow_tex(size: String) -> Texture2D:
	var path := "res://assets/art/world_fx/shadow_%s.png" % size
	return load(path) if ResourceLoader.exists(path) else null


func _draw() -> void:
	var tint := Color.WHITE
	if _echo:   # a memory: desaturated sheet, cool tint, a slow breath of alpha
		tint = Color(0.78, 0.9, 1.15, 0.52 + 0.14 * sin(_t * 1.7))   # TUNE
	var sh := Npc.shadow_tex("m")
	if sh != null:
		draw_texture(sh, Vector2(-7, -2), Color(1, 1, 1, 0.35) if _echo else Color.WHITE)
	var top := -27
	var art := _art()
	if art:   # story prop (assets/art/story/<npc_id>.png), feet on y 1 over the shadow
		StoryArt.draw_standing(self, art, Vector2(0, 1))
		top = 1 - art.get_height()
	elif SHEET:
		var col := int(_t * 3.5) % 4
		var row := _row()
		var fb := frame_bounds(row)
		var y0 := -(fb.y + 1)   # lowest opaque row ends on y 0, over the shadow
		draw_texture_rect_region(echo_sheet() if _echo else SHEET, Rect2(-CELL * 0.5, y0, CELL, CELL), Rect2(col * CELL, row * CELL, CELL, CELL), tint)
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


## assets/art/story/<npc_id>_on.png once flag <npc_id> is set (a lit lamp, a turned wheel), else <npc_id>.png, else null.
func _art() -> Texture2D:
	if npc_id != "" and get_node("/root/Game").has_flag(npc_id):
		var lit := StoryArt.tex(npc_id + "_on")
		if lit:
			return lit
	return StoryArt.tex(npc_id)


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
	var game := get_node("/root/Game")
	var e: Dictionary = game.pick_entry(data.entries)   # skips topic entries
	if e.is_empty():
		return
	_busy = true
	var ev := get_node("/root/Events")
	var lessons: Array[String] = []
	var e_play: Dictionary = e
	var raw_do: Array = e.get("do", [])
	if raw_do.any(func(a: Variant) -> bool: return str(a).begins_with("lesson:")):
		var kept: Array = []
		for a in raw_do:
			if str(a).begins_with("lesson:"):
				lessons.append(str(a))
			else:
				kept.append(a)
		e_play = e.duplicate()
		e_play["do"] = kept
	await game.play(data.name_key, e_play, data.entries)   # lines, choices, then the actions (a hub loops its topics)
	_busy = false
	if not (e.get("quiet", false) or e.get("hub", false) or e.has("topic")):   # a quiet entry (a refusal) does not count as the talk
		ev.talked_to.emit(npc_id)
	for a in lessons:
		game.run(a)
	_recompute()
