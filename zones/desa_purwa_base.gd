extends Zone
## Hand-written part of Desa Purwa: sanggar practice mode, draw guide, and Pelajaran Desa Purwa
## diegetic prologue coaching (world beacons, mentor barks, Sakti Phase B, replay skip).
## zones/desa_purwa.gd (generated) extends this.

const GUIDE_RECT := Rect2(380, 20, 80, 80)
const TAG_NPCS := ["purwa_cat", "purwa_well", "purwa_root"]

var guide: CastOverlay
var _in_sanggar := false
var _sakti_phase := false
var _beacons: Array[Node2D] = []
var _combo_bark_stage := 0
var _cepot_skipped := false
var _semar_skipped := false
var _tag_dodge_barked := false
var _guide_poll_open := false


func _ready() -> void:
	super()
	var stage_decor := RuwatanStageDecor.new()
	add_child(stage_decor)
	guide = preload("res://ui/cast_overlay.tscn").instantiate()
	guide.layer = 4
	add_child(guide)
	for t in find_children("*", "Area2D", true, false):
		if t.get("trigger_id") == "sanggar_enter":
			t.body_entered.connect(_sanggar.bind(true))
			t.body_exited.connect(_sanggar.bind(false))

	var ev := get_node("/root/Events")
	var g := get_node("/root/Game")
	ev.glyph_learned.connect(_on_glyph_learned)
	ev.talked_to.connect(_on_talked_to)
	ev.player_dodged.connect(_on_player_dodged)
	ev.player_struck.connect(_on_player_struck)
	ev.enemy_killed.connect(_on_enemy_killed)
	ev.lesson_offered.connect(_on_lesson_offered)
	ev.spell_cast.connect(_on_spell_cast)
	ev.area_cleared.connect(_on_area_cleared)
	ev.petilasan_activated.connect(_on_petilasan_activated)
	ev.dialogue_finished.connect(_on_state_refresh)
	g.changed.connect(_on_state_refresh)
	_on_state_refresh.call_deferred()


func _process(_delta: float) -> void:
	var open := _glyph_lesson_open()
	if open != _guide_poll_open:
		_guide_poll_open = open
		_show_guide()


func _sanggar(body: Node, inside: bool) -> void:
	if body.is_in_group("player"):
		_in_sanggar = inside
		if not _sakti_phase:
			body.cast.practice = inside   # no sakti gate in the sanggar: a new player starts with 0
		_show_guide()


func _glyph_lesson_open() -> bool:
	var gl := _glyph_lesson()
	return gl != null and (str(gl.get("active")) != "" or str(gl.get("writing")) != "")


func _glyph_lesson() -> Node:
	return get_tree().root.find_child("GlyphLesson", true, false)


func _tutorial() -> Node:
	return get_tree().root.find_child("Tutorial", true, false)


func _show_guide() -> void:
	var g: Array[GlyphData] = get_node("/root/Game").learned_glyphs()
	guide.hide_guide()
	# Never overlap GlyphLesson or Semar's Phase B Sakti drill with the sanggar's static top-right guide.
	guide.visible = _in_sanggar and not g.is_empty() and not _glyph_lesson_open() and not _sakti_phase
	if guide.visible:
		guide.show_guide(g[-1].templates[0], GUIDE_RECT)


# --- NPC / world lookup helpers ---

func _find_npc(id: String) -> Node2D:
	for n in find_children("*", "Node2D", true, false):
		if str(n.get("npc_id")) == id and n.visible:
			return n
	return null


func _find_dummies() -> Array[Node2D]:
	var out: Array[Node2D] = []
	for n in find_children("*", "Node2D", true, false):
		if str(n.get("kind")) == "dummy":
			out.append(n)
	return out


func _find_petilasan() -> Node2D:
	for n in find_children("*", "Node2D", true, false):
		if n.is_in_group("petilasan") and str(n.get("id")) == "desa_purwa":
			return n
	return null


func _clear_beacons() -> void:
	for n in _beacons:
		if is_instance_valid(n):
			WorldBeacon.clear(n)
	_beacons.clear()


func _beacon(target: Node2D, tint := UIFx.WARM, gem_y := -34.0) -> void:
	if target == null or not is_instance_valid(target):
		return
	WorldBeacon.attach(target, tint, gem_y)
	if not target in _beacons:
		_beacons.append(target)


func _bark(npc_id: String, text_key: String, col := UIFx.TEXT, duration := 3.2) -> void:
	if GameSettings.skip_tutorials():
		return
	var npc := _find_npc(npc_id)
	if npc == null:
		return
	var msg: String = str(get_node("/root/Game").fmt(tr(text_key)))
	if msg == text_key:
		return
	WorldBark.say(npc, msg, duration, col)


# --- Pelajaran Desa Purwa live coaching ---

func _on_state_refresh() -> void:
	var g := get_node("/root/Game")
	var ev := get_node("/root/Events")
	var tut := _tutorial()

	# Handle replay-skip choices or Skip Tutorials setting cleanly without softlocking MQ0.
	if g.check("step:mq0=4,flag:mq0_d4b,!flag:mq0_drill") and (g.has_flag("skip_cepot_drill") or GameSettings.skip_tutorials()) and not _cepot_skipped:
		_cepot_skipped = true
		g.set_flag("tut_combo", false)
		if tut and tut.has_method("mark_done"):
			tut.mark_done("combo")
		var dums := _find_dummies()
		if not dums.is_empty():
			ev.enemy_killed.emit(dums[0], 0)
		else:
			g.on_event("enemy_killed", "dummy")

	if g.check("step:mq0=10,glyph:sunda_ka") and (g.has_flag("skip_semar_drill") or GameSettings.skip_tutorials()) and not _semar_skipped:
		_semar_skipped = true
		g.set_flag("tut_cast", false)
		if tut and tut.has_method("mark_done"):
			tut.mark_done("cast")
		_end_sakti_phase()
		ev.spell_cast.emit("sunda_ka", 1.0)

	# Offer quiet Field Book / Map cue during village errands (0.2-0.3)
	if g.check("flag:mq0_d1,!flag:mq0_d4,!flag:tut_menu") and not GameSettings.skip_tutorials():
		if tut and tut.has_method("active") and tut.active() == "":
			ev.lesson_offered.emit("menu")

	# Offer post-raid Petilasan rest right after purwa_raid clears
	if g.check("step:mq0=11,flag:mq0_7,!flag:mq0_rested,!flag:tut_rest") and not GameSettings.skip_tutorials():
		if tut and tut.has_method("active") and tut.active() == "":
			ev.lesson_offered.emit("rest")

	_refresh_beacons()
	_show_guide()


func _refresh_beacons() -> void:
	_clear_beacons()
	if GameSettings.skip_tutorials():
		return
	var g := get_node("/root/Game")

	# 0.1 Dawn Tag: beacon on the first remaining tag target
	if g.check("step:mq0=0"):
		for tid in TAG_NPCS:
			if not g.has_flag(tid):
				var t := _find_npc(tid)
				if t:
					_beacon(t, UIFx.WARM, -34.0)
					break
		return

	# 0.5 Cepot Sanggar Drill: gold rings on the straw dummies
	if g.check("step:mq0=4,flag:mq0_d4b,!flag:mq0_drill"):
		for d in _find_dummies():
			_beacon(d, UIFx.WARM, -20.0)
		return

	# 0.11 Semar Phase B Sakti Drill: cyan rings on the straw dummies
	if _sakti_phase and g.check("step:mq0=10,glyph:sunda_ka"):
		for d in _find_dummies():
			_beacon(d, UIFx.ACCENT, -20.0)
		return

	# 0.12 Post-raid Petilasan rest: gold beacon on the plaza shrine
	if g.check("step:mq0=11,flag:mq0_7,!flag:mq0_rested"):
		var pet := _find_petilasan()
		if pet:
			_beacon(pet, UIFx.WARM, -28.0)


func _on_talked_to(npc_id: String) -> void:
	var g := get_node("/root/Game")
	# Any first tag target reliably triggers `dodge` (fixes Si Belang last-order skip bug)
	if npc_id in TAG_NPCS and g.check("step:mq0=0,!flag:tut_dodge") and not GameSettings.skip_tutorials():
		get_node("/root/Events").lesson_offered.emit("dodge")
		_bark("laras_tag", "BARK_LARAS_DODGE_CUE", UIFx.WARM, 3.4)
	_refresh_beacons()


func _on_player_dodged() -> void:
	var g := get_node("/root/Game")
	if g.check("step:mq0=0") and not _tag_dodge_barked:
		_tag_dodge_barked = true
		_bark("laras_tag", "BARK_LARAS_DODGE_OK", UIFx.OK, 2.8)


func _on_lesson_offered(id: String) -> void:
	if GameSettings.skip_tutorials():
		return
	var g := get_node("/root/Game")
	if id == "combo" and g.check("step:mq0=4,!flag:mq0_drill"):
		_combo_bark_stage = 0
		_bark("cepot", "BARK_CEPOT_START", UIFx.WARM, 3.4)
		_refresh_beacons()
	elif id == "cast" and g.check("step:mq0=10,glyph:sunda_ka"):
		_begin_sakti_phase()


func _on_player_struck(combo: int) -> void:
	var g := get_node("/root/Game")
	if g.check("step:mq0=4,flag:mq0_d4b,!flag:mq0_drill"):
		if combo == 0 and _combo_bark_stage == 0:
			_combo_bark_stage = 1
			_bark("cepot", "BARK_CEPOT_HIT1", UIFx.TEXT, 2.0)
		elif combo == 1 and _combo_bark_stage < 2:
			_combo_bark_stage = 2
			_bark("cepot", "BARK_CEPOT_HIT2", UIFx.WARM, 2.2)
		elif combo >= 2 and _combo_bark_stage < 3:
			_combo_bark_stage = 3
			_bark("cepot", "BARK_CEPOT_HIT3", UIFx.OK, 3.4)
	elif _sakti_phase:
		var pl := get_tree().get_first_node_in_group("player")
		if pl and pl.get("sakti") and float(pl.sakti.value) >= 15.0:
			_bark("semar", "BARK_SEMAR_SAKTI_READY", UIFx.ACCENT, 3.2)


func _on_enemy_killed(enemy: Node2D, _ilmu: int) -> void:
	if enemy == null or not is_instance_valid(enemy) or str(enemy.get("kind")) != "dummy":
		return
	var g := get_node("/root/Game")
	if g.has_flag("mq0_d4b") and not _cepot_skipped:
		_bark("cepot", "BARK_CEPOT_DONE", UIFx.OK, 3.4)
		_refresh_beacons()


func _on_glyph_learned(id: String) -> void:
	_show_guide()
	if id == "sunda_ka" and get_node("/root/Game").check("step:mq0=10"):
		_bark("semar", "BARK_SEMAR_FORM", UIFx.ACCENT, 3.6)


func _begin_sakti_phase() -> void:
	_sakti_phase = true
	var pl := get_tree().get_first_node_in_group("player")
	if pl and pl.get("cast"):
		pl.cast.practice = false
		if "practice_only_signal" in pl.cast:
			pl.cast.practice_only_signal = false
	_bark("semar", "BARK_SEMAR_SAKTI", UIFx.ACCENT, 4.0)
	_refresh_beacons()
	_show_guide()


func _end_sakti_phase() -> void:
	if not _sakti_phase:
		return
	_sakti_phase = false
	var pl := get_tree().get_first_node_in_group("player")
	if pl and pl.get("cast"):
		pl.cast.practice = _in_sanggar
	_refresh_beacons()
	_show_guide()


func _on_spell_cast(glyph_id: String, _score: float) -> void:
	if glyph_id == "sunda_ka" and _sakti_phase:
		_end_sakti_phase()
		_bark("semar", "BARK_SEMAR_DONE", UIFx.OK, 3.6)


func _on_area_cleared(area_id: String) -> void:
	if area_id == "purwa_raid":
		_on_state_refresh()


func _on_petilasan_activated(id: String) -> void:
	if id == "desa_purwa":
		_refresh_beacons()
