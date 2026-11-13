extends Node
## Audio director (architecture.md 3, .docs/audio.md). Assets are built by tools/build_audio.py and tools/gen_music.py.
##
## Music is layered, not switched: a zone has a base track (explore / dark / town) and, for field zones, a combat
## track of the same tempo and length that plays muted in sync with it. Fights fade the combat layer in and duck the
## base; a boss crossfades to its own theme; stingers (jingles) duck everything. Ambience loops run on their own bus.
## Buses: Master > Music, SFX, Ambience (Sistem tab sliders). Scripts call it through the static helper Snd.

const TitleScript := preload("res://ui/title.gd")   # settings path
const DIR := "res://assets/audio/"
const SILENT := -80.0
const BUSES := ["Music", "SFX", "Ambience"]
const POOL := 16
const FADE_ZONE := 2.0         # seconds: base track crossfade (TUNE, audio.md 5)
const FADE_COMBAT_IN := 0.8
const FADE_COMBAT_OUT := 3.0
const FADE_BOSS_IN := 1.0
const FADE_AMB := 3.0
const BLIP_PITCH := [0.8, 0.88, 0.96, 1.04, 1.14, 1.25]
const POLL := 0.15
const COMBAT_RANGE := 230.0
const COMBAT_HOLD := 4.0        # seconds the combat layer lingers after the last aggressor
const PERFECT := 0.92           # SpellUtil perfect-cast score

## Zone id -> region key; first match by prefix (zones/zone.gd region_key).
const PREFIX_REGION := {"desa": "sunda", "ts_": "sunda", "kg_": "galuh", "mt_": "mataram", "tt_": "timur", "sk_": "kidul", "gk_": "kala"}
const TOWN_TRACK := {"desa_purwa": "home", "ts_kampung": "town_kampung", "kg_alun": "town_galuh", "kg_pasar": "town_galuh",
		"mt_pasar": "town_mataram", "sk_nelayan": "town_kidul"}
## Sub-biome 2 of each region (zone.gd sub_biome): the grim, sparse "dark" music.
const DARK_ZONES := ["ts_kawah", "ts_kawah_2", "ts_kawah_boss", "kg_penjara", "kg_pamali", "mt_kuburan", "tt_pesisir",
		"tt_pasir", "tt_candi", "sk_karang", "sk_gua", "sk_keraton", "gk_pelataran", "gk_ruang_kala"]
const SCENE_MUSIC := {"hub": "select", "sanggar": "select"}
const AMBIENCE := {
	"desa_purwa": "village", "ts_kebun": "forest_day", "ts_kampung": "village", "ts_leuweung": "forest_night", "ts_leuwi": "river",
	"ts_sawah": "forest_day", "ts_situ": "river", "ts_kawah_jalan": "forest_day", "ts_kawah": "crater",
	"kg_alun": "market", "kg_keraton": "palace", "kg_penjara": "prison", "kg_pamali": "river", "kg_pasar": "market",
	"kg_pustaka": "ruins", "kg_kaputren": "palace",
	"mt_gapura": "village", "mt_sawah": "swamp", "mt_pasar": "market", "mt_reruntuhan": "ruins", "mt_kuburan": "graveyard",
	"mt_wetan": "ruins", "mt_candi": "ruins", "mt_tegal": "forest_day",
	"tt_kulon": "forest_day", "tt_sabana": "forest_day", "tt_kali": "river", "tt_beringin": "forge", "tt_ladang": "forest_day",
	"tt_pasir": "desert", "tt_candi": "ruins", "tt_pesisir": "desert",
	"sk_karang": "sea", "sk_pantai": "sea", "sk_tebing": "sea", "sk_keraton": "palace", "sk_nelayan": "sea", "sk_bakau": "swamp",
	"sk_gua": "cave",
	"gk_mulut": "cave", "gk_pasir": "kala", "gk_lupa": "kala", "gk_ruang_kala": "kala", "gk_pelataran": "kala",
	"gk_hutan": "graveyard", "gk_jembatan": "kala",
}
const SURFACE := {"sunda": "grass", "galuh": "stone", "mataram": "grass", "timur": "grass", "kidul": "sand", "kala": "stone"}
const SURFACE_ZONE := {"ts_kawah": "stone", "ts_kawah_2": "stone", "mt_candi": "stone", "mt_reruntuhan": "stone", "tt_pasir": "sand",
		"tt_pesisir": "sand", "tt_candi": "stone", "sk_bakau": "water", "sk_gua": "stone", "sk_keraton": "stone", "kg_alun": "stone",
		"kg_pasar": "stone", "kg_pamali": "water", "ts_leuwi": "water", "desa_purwa": "grass", "kg_kaputren": "wood", "kg_pustaka": "wood",
		"kg_penjara": "stone", "mt_pasar": "grass", "sk_nelayan": "sand", "gk_mulut": "stone"}
## Glyph id -> spell sound (spells.md 3).
const SPELL_SFX := {"sunda_ka": "bolt", "sunda_ga": "ward", "sunda_nga": "bind", "sunda_ca": "burst", "jawa_ha": "heal",
		"jawa_na": "dash", "jawa_ca": "rally", "jawa_ra": "summon", "jawa_ka": "ombak",
		"sunda_ha": "rally", "sunda_pa": "bolt", "jawa_pa": "dash", "jawa_wa": "rally",
		"jawa_ga": "burst", "sunda_ba": "summon", "sunda_ta": "rally", "jawa_la": "bind"}
## Memory scene ids that get the ruwatan hymn instead of the shadow-play music.
const RUWATAN_MEMORIES := ["k0_ruwatan", "k10_murwakala"]
## Minimum seconds between two plays of the same sound (default 0.03).
const GAP := {"boss_telegraph": 0.4, "ui_move": 0.07, "ui_slider": 0.05, "hit_light": 0.05, "enemy_death": 0.08,
		"stagger": 0.15, "cast_ok_low": 0.2, "cast_ok_mid": 0.2, "cast_ok_high": 0.2, "enemy_telegraph": 0.25}
const JINGLE_HOLD := {"victory": 9.0, "death": 7.0, "quest_new": 2.6, "quest_done": 4.0, "rest": 5.0, "levelup": 3.6,
		"glyph": 3.4, "discover": 2.4, "area_clear": 3.0, "choice": 4.0, "boss_intro": 3.2, "area_title": 0.0}

class Voice extends RefCounted:
	var p: AudioStreamPlayer
	var x := 0.0              # fade position 0..1; gain = sin(x * PI/2), an equal-power curve in linear amplitude
	var target := -80.0       # dB
	var up := 2.0             # seconds for a full fade in
	var down := 2.0           # ... out
	var keep_alive := false   # stay playing while silent (sync layers)

	func tick(d: float) -> void:
		var goal := 0.0 if target <= -79.5 else asin(minf(db_to_linear(target), 1.0)) / (PI * 0.5)
		x = move_toward(x, goal, d / maxf(up if goal > x else down, 0.05))
		p.volume_linear = sin(x * PI * 0.5)
		if x <= 0.0 and goal <= 0.0 and p.playing and not keep_alive:
			p.stop()
			p.stream = null   # let a faded-out track be freed (Ogg streams keep their whole file in memory)

	func play(stream: AudioStream, from := 0.0) -> void:
		p.stream = stream
		p.play(from)

var _cache := {}
var _plan := {}               # current zone plan (plan_for)
var _bases: Array[Voice] = []
var _cur := 0
var _combat: Voice
var _boss: Voice
var _amb: Array[Voice] = []
var _amb_cur := 0
var _amb_id := ""
var _jingle: AudioStreamPlayer
var _ink: AudioStreamPlayer
var _pool: Array[AudioStreamPlayer] = []
var _last := {}               # sound id -> msec of the last play
var _base_id := ""
var _combat_id := ""
var _boss_id := ""
var _synced := false
var _scene_override := ""     # a non-zone scene (title, class select, epilogue...) owns the music
var _combat_on := false
var _combat_hold := 0.0
var _boss_on := false
var _boss_phase := 1
var _hush := 0.0              # seconds all music is held silent (victory / death stingers)
var _jingle_t := 0.0          # seconds the stinger is ducking the mix
var _dialogue := false
var _cast := false
var _ink_hold := 0.0
var _poll := 0.0
var _lpf := 20500.0
var surface := "grass"
var zone_id := ""
var enabled := true           # tests may switch it off


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for b in BUSES:
		_ensure_bus(b)
	_add_lpf("Music")
	_add_lpf("Ambience")
	_add_fx("Master", AudioEffectHardLimiter.new())   # stacked hits + stinger + music can never clip
	var comp := AudioEffectCompressor.new()
	comp.threshold = -12.0
	comp.ratio = 3.0
	_add_fx("SFX", comp)
	var duck := AudioEffectCompressor.new()           # a burst of sfx dips the music about 2 dB (TUNE)
	duck.sidechain = &"SFX"
	duck.threshold = -14.0
	duck.ratio = 1.3
	duck.release_ms = 350.0
	_add_fx("Music", duck)
	apply_settings()
	for i in 2:
		_bases.append(_voice("Music"))
		_amb.append(_voice("Ambience"))
	_combat = _voice("Music")
	_boss = _voice("Music")
	for v in _amb:
		v.up = FADE_AMB
		v.down = FADE_AMB
	_jingle = AudioStreamPlayer.new()
	_jingle.bus = "Music"
	add_child(_jingle)
	_ink = AudioStreamPlayer.new()
	_ink.bus = "SFX"
	_ink.volume_db = SILENT
	add_child(_ink)
	for i in POOL:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_pool.append(p)
	_connect_events()
	get_tree().node_added.connect(_on_node_added)


func _voice(bus: String) -> Voice:
	var v := Voice.new()
	v.p = AudioStreamPlayer.new()
	v.p.bus = bus
	v.p.volume_db = SILENT
	add_child(v.p)
	return v


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	var i := AudioServer.bus_count - 1
	AudioServer.set_bus_name(i, bus_name)
	AudioServer.set_bus_send(i, "Master")


func _add_lpf(bus_name: String) -> void:
	var i := AudioServer.get_bus_index(bus_name)
	if i < 0 or AudioServer.get_bus_effect_count(i) > 0:
		return
	var fx := AudioEffectLowPassFilter.new()
	fx.cutoff_hz = 20500.0
	AudioServer.add_bus_effect(i, fx)


func _add_fx(bus_name: String, fx: AudioEffect) -> void:
	var i := AudioServer.get_bus_index(bus_name)
	for k in AudioServer.get_bus_effect_count(i):
		if AudioServer.get_bus_effect(i, k).get_class() == fx.get_class():
			return
	AudioServer.add_bus_effect(i, fx)


func apply_settings() -> void:
	var cf := ConfigFile.new()
	cf.load(TitleScript.settings_path)
	for b in ["Master", "Music", "SFX", "Ambience"]:
		var i := AudioServer.get_bus_index(b)
		if i >= 0:
			var pct := float(cf.get_value("settings", "vol_" + b.to_lower(), 100))
			AudioServer.set_bus_volume_db(i, linear_to_db(maxf(pct, 0.0) / 100.0))


# --- loading ---------------------------------------------------------------------------------------------------

## A stream by id: "music/explore_sunda", "sfx/hit_light". Cached; null when the file is missing (nothing to play, no
## error spam). A sound with variation files (hit_light.wav, hit_light__2.wav, ...) comes back as a randomizer.
func stream(rel: String, loop := false) -> AudioStream:
	var key := rel + ("|loop" if loop else "")
	if _cache.has(key):
		return _cache[key]
	var s := _load(rel)
	if s != null and loop:
		if s is AudioStreamWAV:
			s.loop_mode = AudioStreamWAV.LOOP_FORWARD
			s.loop_end = int(s.get_length() * s.mix_rate)
		elif "loop" in s:
			s.loop = true
	elif s != null:
		var v := _load(rel + "__2")
		if v != null:
			var r := AudioStreamRandomizer.new()
			r.add_stream(-1, s)
			var n := 2
			while v != null:
				r.add_stream(-1, v)
				n += 1
				v = _load("%s__%d" % [rel, n])
			s = r
	_cache[key] = s
	return s


func _load(rel: String) -> AudioStream:
	for ext: String in [".wav", ".ogg"]:
		var path := DIR + rel + ext
		if ResourceLoader.exists(path):
			return load(path)
		if FileAccess.file_exists(path):   # editor run before the first import
			return AudioStreamWAV.load_from_file(path) if ext == ".wav" else AudioStreamOggVorbis.load_from_file(path)
	return null


# --- plans: what a zone sounds like ----------------------------------------------------------------------------

static func region_of(zone: String) -> String:
	for k: String in PREFIX_REGION:
		if zone.begins_with(k):
			return PREFIX_REGION[k]
	return ""


## Music / ambience / surface for a zone id. Pure function of the id (tests call it directly).
func plan_for(zone: String) -> Dictionary:
	var region := region_of(zone)
	var plan := {"base": "", "combat": "", "boss": "", "amb": "", "surface": "grass"}
	if SCENE_MUSIC.has(zone):
		plan.base = SCENE_MUSIC[zone]
		plan.amb = "village"
		return plan
	if region == "":
		return plan
	if TOWN_TRACK.has(zone):
		plan.base = TOWN_TRACK[zone]
	elif zone in DARK_ZONES:
		plan.base = "dark_" + region
	else:
		plan.base = "explore_" + region
	plan.combat = "combat_" + region
	plan.boss = "boss_" + region
	plan.amb = AMBIENCE.get(zone, "forest_day")
	plan.surface = SURFACE_ZONE.get(zone, SURFACE[region])
	return plan


func _on_zone(zone: String) -> void:
	var plan := plan_for(zone)
	if plan.base == "":
		return   # a test scene or unknown id: leave the sound as it is
	zone_id = zone
	_scene_override = ""
	_hush = 0.0
	apply_plan(plan)
	_trim_cache(plan)


## Forgets the music and ambience this zone does not use (.docs/performance.md P3). An Ogg stream holds its whole
## file in memory and the cache kept every one ever played: about 105 MB after one walk through the world. SFX and
## jingles are small and stay. A voice that is still fading out keeps its own stream until it stops.
func _trim_cache(plan: Dictionary) -> void:
	var keep := {}
	for id: String in [plan.get("base", ""), plan.get("combat", ""), plan.get("boss", "")]:
		keep["music/%s|loop" % id] = true
	keep["amb/%s|loop" % plan.get("amb", "")] = true
	var voices: Array[Voice] = []
	voices.append_array(_bases)
	voices.append_array(_amb)
	voices.append_array([_combat, _boss])
	for v in voices:
		if not v.p.playing:
			v.p.stream = null   # a stopped player still holds its last track
	for key: String in _cache.keys():
		if (key.begins_with("music/") or key.begins_with("amb/")) and not keep.has(key):
			_cache.erase(key)


func apply_plan(plan: Dictionary) -> void:
	_plan = plan
	surface = plan.get("surface", "grass")
	_boss_on = false
	_combat_on = false
	_combat_hold = 0.0
	set_music(plan.base, plan.combat)
	set_ambience(plan.amb)


## Base track (+ optional combat layer of the same tempo). Same ids as already playing: nothing restarts.
func set_music(base: String, combat := "") -> void:
	if not enabled:
		return
	var synced := base.begins_with("explore_") and combat != ""
	if base != _base_id:
		var old := _bases[_cur]
		old.target = SILENT
		_cur = 1 - _cur
		var v := _bases[_cur]
		_base_id = base
		var s: AudioStream = stream("music/" + base, true) if base != "" else null
		if s != null:
			v.x = 0.0
			v.target = 0.0
			v.up = FADE_ZONE
			old.down = FADE_ZONE
			v.play(s)
		_combat_id = ""   # the combat layer restarts together with a new base
		_combat.p.stop()
		_combat.x = 0.0
	_synced = synced
	_combat.keep_alive = synced
	if combat != _combat_id:
		_combat_id = combat
		var cs: AudioStream = stream("music/" + combat, true) if combat != "" else null
		if cs != null and synced:
			var pos := _bases[_cur].p.get_playback_position() if _bases[_cur].p.playing else 0.0
			_combat.play(cs, pos)
		elif cs == null:
			_combat.p.stop()


## A non-zone scene (title, class select, epilogue, a memory) takes the music. Zones take it back on zone_entered.
func play_music(id: String, fade := 1.5) -> void:
	if not enabled:
		return
	_scene_override = id
	_plan = {}
	_boss_on = false
	_combat_on = false
	set_music(id, "")
	_bases[_cur].up = fade
	_bases[1 - _cur].down = fade


func stop_music(fade := 1.5) -> void:
	_scene_override = ""
	for v in _bases:
		v.target = SILENT
		v.down = fade
	_combat.target = SILENT
	_boss.target = SILENT
	_base_id = ""
	_combat_id = ""


func set_ambience(id: String) -> void:
	if not enabled or id == _amb_id:
		return
	_amb_id = id
	_amb[_amb_cur].target = SILENT
	_amb_cur = 1 - _amb_cur
	var v := _amb[_amb_cur]
	var s: AudioStream = stream("amb/" + id, true) if id != "" else null
	if s != null:
		v.x = 0.0
		v.target = -2.0
		v.play(s, randf() * 8.0)


# --- sfx -------------------------------------------------------------------------------------------------------

## id: "hit_light" (the old "sfx_" prefix is accepted: lontar_shimmer asks for "sfx_lontar").
func play_sfx(id: String, vol_db := 0.0, pitch := 1.0, jitter := 0.0) -> void:
	if not enabled:
		return
	if id.begins_with("sfx_"):
		id = id.substr(4)
	var now := Time.get_ticks_msec()
	var gap: float = GAP.get(id, 0.03)
	if now - int(_last.get(id, -100000)) < int(gap * 1000.0):
		return
	var s := stream("sfx/" + id)
	if s == null:
		return
	_last[id] = now
	var p := _pool[0]   # a free player first; otherwise steal the one that has played longest
	for q in _pool:
		if not q.playing:
			p = q
			break
		if q.get_playback_position() > p.get_playback_position():
			p = q
	p.stream = s
	p.volume_db = vol_db
	p.pitch_scale = pitch * (1.0 + randf_range(-jitter, jitter))
	p.play()


func play_jingle(id: String, vol_db := 0.0) -> void:
	if not enabled:
		return
	var s := stream("jingle/" + id)
	if s == null:
		return
	_jingle.stream = s
	_jingle.volume_db = vol_db
	_jingle.play()
	_jingle_t = float(JINGLE_HOLD.get(id, 3.0))


## Dialogue typewriter tick: pitch follows the speaker, so each voice is recognisable.
func blip(speaker_key: String) -> void:
	var i := absi(speaker_key.hash()) % 6 if speaker_key != "" else 2
	play_sfx("blip", -2.0 if speaker_key != "" else -7.0, BLIP_PITCH[i], 0.03)


func step() -> void:
	play_sfx("step_" + surface, 0.0, 1.0, 0.07)


## Cast mode: the lontar opens, the world muffles. Drawing calls ink_draw() every stroke point.
func cast_mode(on: bool) -> void:
	_cast = on
	if on:
		play_sfx("cast_begin")


func ink_draw(speed := 150.0) -> void:
	if not enabled:
		return
	_ink_hold = 0.08
	if not _ink.playing:
		var s := stream("sfx/ink", true)
		if s == null:
			return
		_ink.stream = s
		_ink.play()
	_ink.pitch_scale = 0.85 + 0.35 * clampf(speed / 400.0, 0.0, 1.0)


# --- events ----------------------------------------------------------------------------------------------------

func _connect_events() -> void:
	var ev := get_node("/root/Events")
	ev.zone_entered.connect(_on_zone)
	ev.memory_started.connect(_on_memory)
	ev.memory_done.connect(func(_id: String) -> void: play_sfx("memory_out"))
	ev.spell_cast.connect(_on_spell)
	ev.enemy_killed.connect(_on_enemy_killed)
	ev.player_died.connect(_on_player_died)
	ev.boss_defeated.connect(_on_boss_defeated)
	ev.area_cleared.connect(func(_id: String) -> void: play_jingle("area_clear", -4.0))
	ev.petilasan_activated.connect(func(_id: String) -> void: play_sfx("petilasan"))
	ev.rested.connect(func(_p: Node2D) -> void: play_jingle("rest", -2.0))
	ev.quest_started.connect(func(_id: String) -> void: play_jingle("quest_new", -3.0))
	ev.quest_completed.connect(func(_id: String) -> void: play_jingle("quest_done", -2.0))
	ev.quest_updated.connect(func(_id: String) -> void: play_sfx("save", 0.0))
	ev.glyph_learned.connect(func(_id: String) -> void: play_jingle("glyph", -2.0))
	ev.item_picked.connect(func(_id: String) -> void: play_sfx("pickup"))
	ev.clue_examined.connect(func(_id: String) -> void: play_sfx("lontar"))
	ev.puzzle_solved.connect(func(_id: String) -> void: play_sfx("puzzle_solve"))
	ev.trial_completed.connect(func(_id: String) -> void: play_sfx("puzzle_solve"))
	ev.name_written.connect(func(_id: String) -> void: play_sfx("puzzle_solve", -3.0))
	ev.class_chosen.connect(func(_id: String) -> void: play_sfx("ui_start"))
	ev.dialogue_requested.connect(func(_k: String, _l: PackedStringArray) -> void: _dialogue = true)
	ev.dialogue_finished.connect(func() -> void: _dialogue = false)
	ev.dialogue_choices.connect(func(_k: PackedStringArray) -> void: play_sfx("ui_choice"))
	ev.scene_cue.connect(_on_cue)
	var game := get_node_or_null("/root/Game")
	if game and game.has_signal("saved"):
		game.saved.connect(func() -> void: play_sfx("save", -3.0))


func _on_memory(id: String) -> void:
	play_sfx("memory_in")
	_hush = 0.0
	play_music("ruwatan" if id in RUWATAN_MEMORIES else "kelir", 2.0)
	set_ambience("kelir")


func _on_spell(glyph_id: String, score: float) -> void:
	play_sfx("spell_" + SPELL_SFX.get(glyph_id, "burst"))
	if score >= PERFECT:
		play_sfx("cast_perfect", -3.0)
	else:
		play_sfx("cast_ok_low" if score < 0.6 else "cast_ok_mid" if score < 0.82 else "cast_ok_high", -6.0)


func _on_enemy_killed(enemy: Node2D, ilmu: int) -> void:
	play_sfx("enemy_death", 0.0 if ilmu < 15 else 2.0, 1.0 if ilmu < 15 else 0.85, 0.05)


func _on_player_died() -> void:
	_boss_on = false
	_combat_on = false
	_hush = float(JINGLE_HOLD["death"])
	play_jingle("death")
	play_sfx("player_death")


func _on_boss_defeated(_id: String) -> void:
	_boss_on = false
	_combat_on = false
	_hush = float(JINGLE_HOLD["victory"])
	_boss.down = 0.6
	play_sfx("boss_death")
	play_jingle("victory")


## Story cues in dialogue: "#music:explore_sunda", "#sfx:chest_open", "#amb:sea" (docs/audio.md).
func _on_cue(cue: String, arg: String) -> void:
	match cue:
		"music":
			if arg == "":
				stop_music()
			else:
				play_music(arg)
		"sfx":
			play_sfx(arg)
		"amb":
			set_ambience(arg)
		"jingle":
			play_jingle(arg)


func _on_node_added(n: Node) -> void:
	if n is BaseButton:   # every button and slider in the game gets UI sounds, however it was built
		var b := n as BaseButton
		if not b.pressed.is_connected(_ui_confirm):
			b.pressed.connect(_ui_confirm)
			b.focus_entered.connect(_ui_move)
			b.mouse_entered.connect(_ui_move)
	elif n is Slider:
		var sl := n as Slider
		if not sl.value_changed.is_connected(_ui_slide):
			sl.value_changed.connect(_ui_slide)


func _ui_confirm() -> void:
	play_sfx("ui_confirm")


func _ui_move() -> void:
	play_sfx("ui_move")


func _ui_slide(_v: float) -> void:
	play_sfx("ui_slider")


# --- the mix ---------------------------------------------------------------------------------------------------

func _process(delta: float) -> void:
	if not enabled:
		return
	_poll -= delta
	if _poll <= 0.0:
		_poll = POLL
		_poll_state(POLL)
	_hush = maxf(0.0, _hush - delta)
	_jingle_t = maxf(0.0, _jingle_t - delta)
	_ink_hold = maxf(0.0, _ink_hold - delta)
	_mix()
	for v in _bases:
		v.tick(delta)
	_combat.tick(delta)
	_boss.tick(delta)
	for v in _amb:
		v.tick(delta)
	_tick_ink(delta)
	_tick_lpf(delta)


func _mix() -> void:
	var duck := 0.0
	if _jingle_t > 0.0:
		duck -= 12.0
	if _dialogue:
		duck -= 4.0
	if _cast:
		duck -= 5.0
	var base_t := 0.0 if _base_id != "" else SILENT
	var combat_t := SILENT
	var boss_t := SILENT
	if _boss_on:
		base_t = SILENT
		boss_t = 0.0
	elif _combat_on and _combat_id != "":
		combat_t = 0.0
		base_t = -13.0 if _synced else -40.0
	if _hush > 0.0:
		base_t = SILENT
		combat_t = SILENT
		boss_t = SILENT
	if get_tree().paused:
		duck -= 6.0
	_bases[_cur].target = base_t + duck if base_t > SILENT else SILENT
	_bases[1 - _cur].target = SILENT
	_combat.target = combat_t + duck if combat_t > SILENT else SILENT
	_boss.target = boss_t + duck if boss_t > SILENT else SILENT
	_combat.up = FADE_COMBAT_IN
	_combat.down = FADE_COMBAT_OUT
	_boss.up = FADE_BOSS_IN
	if _hush <= 0.0 and not _boss_on:
		_boss.down = FADE_ZONE
	if get_tree().paused or _cast:
		_amb[_amb_cur].target = -8.0 if _amb_id != "" else SILENT
	elif _amb_id != "":
		_amb[_amb_cur].target = -2.0 if not _boss_on else -9.0
	_amb[1 - _amb_cur].target = SILENT
	if _combat_on and not _synced and _combat_id != "" and not _combat.p.playing:
		var cs: AudioStream = stream("music/" + _combat_id, true)
		if cs != null:
			_combat.play(cs)


func _tick_ink(delta: float) -> void:
	_ink.volume_linear = move_toward(_ink.volume_linear, 0.63 if _ink_hold > 0.0 else 0.0, delta / 0.06)
	if _ink_hold <= 0.0 and _ink.playing and _ink.volume_linear <= 0.0:
		_ink.stop()


func _tick_lpf(delta: float) -> void:
	var goal := 20500.0
	if get_tree().paused:
		goal = 1700.0
	elif _cast:
		goal = 1100.0
	_lpf = lerpf(_lpf, goal, minf(1.0, delta * 6.0))
	for b in ["Music", "Ambience"]:
		var i := AudioServer.get_bus_index(b)
		if i >= 0 and AudioServer.get_bus_effect_count(i) > 0:
			var fx := AudioServer.get_bus_effect(i, 0) as AudioEffectLowPassFilter
			if fx:
				fx.cutoff_hz = _lpf


## Combat and boss state, polled four times a second: the same signals the HUD uses (group "boss" + engaged).
func _poll_state(dt: float) -> void:
	if _scene_override != "" or _plan.is_empty():
		return
	var tree := get_tree()
	var player := tree.get_first_node_in_group("player") as Node2D
	var boss: Node = null
	for b in tree.get_nodes_in_group("boss"):
		var h: Variant = b.get("health")
		if h != null and bool(b.get("engaged")) and h.hp > 0:
			boss = b
			break
	if boss != null:
		var phase := int(boss.get("phase")) if boss.get("phase") != null else 1
		var id := String(_plan.get("boss", ""))
		if id == "boss_kala" and phase >= 3:
			id = "boss_kala_2"
		if not _boss_on:
			_boss_on = true
			_boss_phase = phase
			_hush = 0.0
			if tree.get_first_node_in_group("arena_gate") == null:   # a staged entrance (boss_stage.gd) roars when the camera returns
				play_sfx("boss_roar")
			play_jingle("boss_intro", -5.0)
			_start_boss(id)
		else:
			if phase != _boss_phase:
				_boss_phase = phase
				play_sfx("boss_phase")
			if id != _boss_id:
				_start_boss(id)
		return
	if _boss_on and _hush <= 0.0:   # boss gone without a defeat event (reset, respawn)
		_boss_on = false
	var fighting := false
	if player != null:
		for e in tree.get_nodes_in_group("enemy"):
			if not (e is Node2D) or e.get("dead") == true:
				continue
			var d := (e as Node2D).global_position.distance_to(player.global_position)
			if d > COMBAT_RANGE:
				continue
			var st: Variant = e.get("state")
			if (st is int and st >= 1 and st <= 6) or d < 90.0:   # EnemyBase-style State: CHASE..STAGGER
				fighting = true
				break
	if fighting:
		_combat_on = true
		_combat_hold = COMBAT_HOLD
	elif _combat_on:
		_combat_hold -= dt
		if _combat_hold <= 0.0:
			_combat_on = false


func _start_boss(id: String) -> void:
	_boss_id = id
	var s: AudioStream = stream("music/" + id, true) if id != "" else null
	if s != null:
		_boss.play(s)
