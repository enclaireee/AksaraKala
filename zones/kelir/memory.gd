class_name KelirMemory extends Node2D
## Kelir memory base (architecture.md 9b). Not a Zone: no MAP, no exits, no saves (Game.in_memory).
## Spawns the stand-in at the `Stand` marker and moves it (move_* only). MemorySpot children are the progress:
## when every counting spot is done, finish(). MemoryThreat children call fail(), which puts the stand-in back
## at the last reached checkpoint (Marker2D in group "checkpoint" or named Checkpoint*), else at Stand.
## Narration MEM_<ID>_IN(_2) on enter and MEM_<ID>_OUT(_2) on finish, each only if the key exists.
## kind "gap": spots come from `data` (GapMemoryData). kind "chapter": Laras stand-in, `interact` freezes the
## nearest Faceless, and finish() first asks for a write of Ka.

const STAND_IN := "res://entities/player/stand_in.tscn"
const STAND_IN_LARAS := "res://entities/player/stand_in_laras.tscn"
const SPOT_SCENE := "res://zones/kelir/memory_spot.tscn"
const UI_SCENE := "res://ui/game_ui.tscn"
const SPEED := 70.0              # TUNE: stand-in px/s
const CHECKPOINT_RANGE := 12.0   # TUNE: px from a checkpoint marker that reaches it
const NAME_RANGE := 48.0         # TUNE: Laras's true name reach
const NAME_FREEZE := 3.0         # TUNE
const NAME_COOLDOWN := 6.0       # TUNE
const LARAS_KA := "sunda_ka"     # ASSUMED: the Ka Laras writes at a chapter's end
const WARM := Color("F2D9A0")
const COOL := Color("D5E2F0")    # Laras chapters

@export_enum("play", "walk", "chapter", "gap") var kind := "play"
@export var memory_id := ""        # the memory_done:<id> id; "" takes data.memory_id, then Zones.memory_id
@export var data: GapMemoryData    # kind gap only; null loads data/memories/gap_<Zones.memory_id>.tres
@export var allow_cast := false    # true in K7 (the finale ruwatan where you are the dalang)

var stand_in: CharacterBody2D
var checkpoint: Node2D   # last one reached
var _stand: Node2D
var _busy := false       # a fail fade is running
var _done := false
var _name_cd := 0.0
static var instant := false   # tests: no curtain-up card, no frozen intro (the opening lines still play)
var stage: KelirStage     # curtain-up card, objective pill, meter and flash (kelir_stage.gd)
var _intro := not instant   # the curtain-up card and Semar's opening lines are running: nobody moves
var _talk := 0            # open say() calls: the world waits while a line is on screen
var _fails := 0
var _chapter_in := PackedStringArray()    # kind chapter: the LC<n>_<i> lines, opening / closing
var _chapter_out := PackedStringArray()


## The memory a node belongs to, or null.
static func of(n: Node) -> KelirMemory:
	while n != null and not n is KelirMemory:
		n = n.get_parent()
	return n as KelirMemory


func _ready() -> void:
	var zones := get_node("/root/Zones")
	if kind == "gap" and data == null and ResourceLoader.exists(zones.gap_data_path(zones.memory_id)):
		data = load(zones.gap_data_path(zones.memory_id))
	if memory_id == "":
		memory_id = data.memory_id if data and data.memory_id != "" else zones.memory_id
	for c in find_children("Checkpoint*", "Marker2D", true, false):
		c.add_to_group("checkpoint")
	_stand = find_child("Stand", true, false) as Node2D
	if _stand == null:
		push_warning("memory %s: no Stand marker" % memory_id)
	stand_in = load(STAND_IN_LARAS if kind == "chapter" else STAND_IN).instantiate()
	add_child(stand_in)
	stand_in.global_position = _stand.global_position if _stand else Vector2.ZERO
	stand_in.reset_physics_interpolation()
	if kind == "gap" and data:
		for g: Dictionary in data.gaps:
			var s: MemorySpot = load(SPOT_SCENE).instantiate()
			s.action_kind = "gap"
			s.gap = g
			s.position = Vector2(g.get("pos", Vector2i.ZERO)) * 16.0 + Vector2(8, 8)
			add_child(s)
	var tiles_layer := get_node_or_null("Tiles") as TileMapLayer
	if tiles_layer and tiles_layer.tile_set and tiles_layer.tile_set.has_source(6):
		_skin_kelir_tiles(tiles_layer)
	if tiles_layer and memory_id not in ["k0_ruwatan", "k7_ruwatan"] and not tiles_layer.get_used_cells().is_empty():
		var ur := tiles_layer.get_used_rect()   # K0 and K7 draw their own kelir
		var decor := KelirDecor.new()
		decor.setup(memory_id, Rect2(Vector2(ur.position) * 16.0, Vector2(ur.size) * 16.0), kind == "chapter")
		add_child(decor)
	if find_children("*", "CanvasModulate", true, false).is_empty():
		var cm := CanvasModulate.new()
		cm.color = COOL if kind == "chapter" else WARM
		add_child(cm)
	var ui := find_child("GameUI", true, false)
	if ui == null:
		ui = load(UI_SCENE).instantiate()
		add_child(ui)
	stage = KelirStage.new()
	add_child(stage)
	if kind == "chapter":
		_spread_chapter_lines()
	var hud := ui.get_node_or_null("HUD")
	if hud:   # it reads the hero's hp/stamina/sakti, which a stand-in does not have
		hud.visible = false
		hud.process_mode = Node.PROCESS_MODE_DISABLED
	_start.call_deferred()


func _skin_kelir_tiles(tl: TileMapLayer) -> void:
	var b0 := 10 if kind == "chapter" else (5 if kind == "walk" else 0)
	var cells := tl.get_used_cells()
	var cols := {}
	for cell: Vector2i in cells:
		cols[cell] = tl.get_cell_atlas_coords(cell).x
	for cell: Vector2i in cells:
		var col: int = cols[cell]
		var up: int = cols.get(cell + Vector2i(0, -1), 4)
		var dn: int = cols.get(cell + Vector2i(0, 1), 4)
		var lf: int = cols.get(cell + Vector2i(-1, 0), 4)
		var rt: int = cols.get(cell + Vector2i(1, 0), 4)
		var h := posmod(cell.x * 73 + cell.y * 37, 16)
		var row := b0
		if col == 4:
			row = b0 + ((2 if (h % 4 == 0 and up == 4) else 3) if dn != 4 else (4 if up != 4 else posmod(cell.x + cell.y, 2)))
		elif col == 5:
			row = b0 + (3 if up != 5 else (4 if dn != 5 else (2 if h % 5 == 0 else posmod(cell.x + cell.y, 2))))
		elif col == 1 and (up == 5 or dn == 5 or lf == 5 or rt == 5):
			row = 15
		elif col <= 3:
			row = b0 + (3 if up == 4 else (2 if h < 2 else (1 if h < 7 else 0)))
		else:
			row = b0 + posmod(cell.x * 3 + cell.y * 5, 4)
		tl.set_cell(cell, 6, Vector2i(col, row))


## Curtain-up: title card, Semar's opening lines, then one objective pill that says what to do.
func _start() -> void:
	_intro = not instant
	var tk := resolve("LC_%s_TITLE" % memory_id.trim_prefix("lc") if kind == "chapter" else "MEM_%s_TITLE" % _tid().to_upper())
	if not instant:
		await stage.curtain_up(tr(tk) if tk != "" else "", tr("UI_KELIR_SUB_" + kind.to_upper()))
	await say(_keys("IN"))
	_intro = false
	show_objective()


## What to do, in one line with its key: the memory's own HINT, else the line for its kind.
func show_objective() -> void:
	var hk := "MEM_%s_HINT" % _tid().to_upper()
	var action := "move_right" if kind == "walk" else "interact"
	var text := tr(hk) if tr(hk) != hk else tr("UI_KELIR_OBJ_" + kind.to_upper())
	stage.objective(text, action)


## True while the player may act and the world may press on: not in the curtain-up, a line, a fail fade or the end.
func acting() -> bool:
	return not (_intro or _busy or _done or _talk > 0)


## Speaker of every memory line: Semar the dalang, Laras in her chapters.
func speaker() -> String:
	return "NPC_LARAS_NAME" if kind == "chapter" else "NPC_SEMAR_NAME"


## Plays these line keys in the dialogue box; returns when it closed. No keys, no box.
func say(keys: PackedStringArray) -> void:
	if not keys.is_empty():
		_talk += 1
		await get_node("/root/Game").play(speaker(), {"lines": keys})
		_talk -= 1


## The text id of this memory: the id, or gap_<letter> for a gap memory.
func _tid() -> String:
	return memory_id if kind != "gap" or memory_id.begins_with("gap_") else "gap_" + memory_id


## `k` when it has text, else `k` without its MEM_ prefix (the Laras chapters are written LC<n>_<i>), else "".
func resolve(k: String) -> String:
	if k == "":
		return ""
	if tr(k) != k:
		return k
	var short := k.trim_prefix("MEM_")
	return short if short != k and tr(short) != short else ""


## Laras chapters: LC<n>_1 opens, the last two (three in the long ones) close, the lines between are handed out to the
## chapter's spots in order, so nothing she wrote is lost and nothing plays twice.
func _spread_chapter_lines() -> void:
	var n := memory_id.trim_prefix("lc")
	var ks := PackedStringArray()
	for i in range(1, 40):
		var k := resolve("LC%s_%d" % [n, i])
		if k == "":
			break
		ks.append(k)
	if ks.size() < 4:
		return
	var n_out := 3 if ks.size() >= 9 else 2
	_chapter_in = ks.slice(0, 1)
	_chapter_out = ks.slice(ks.size() - n_out)
	var mid := ks.slice(1, ks.size() - n_out)
	var sp := spots().filter(func(s: MemorySpot) -> bool: return s.action_kind != "gap")
	sp.sort_custom(func(a: Node, b: Node) -> bool: return String(a.name).naturalnocasecmp_to(String(b.name)) < 0)
	for i in sp.size():
		sp[i].line_key = ""
		sp[i].line_keys = mid.slice(i * mid.size() / sp.size(), (i + 1) * mid.size() / sp.size())


## MEM_<ID>_<part> and _<part>_2, those that exist. A gap memory's text id is gap_<letter> (script.md).
func _keys(part: String) -> PackedStringArray:
	if kind == "chapter" and not _chapter_in.is_empty():
		return _chapter_in if part == "IN" else _chapter_out
	var tid := _tid()
	var out := PackedStringArray()
	for k in ["MEM_%s_%s" % [tid.to_upper(), part], "MEM_%s_%s_2" % [tid.to_upper(), part]]:
		if tr(k) != k:
			out.append(k)
	return out


func _physics_process(delta: float) -> void:
	if stand_in == null:
		return
	_name_cd = maxf(0.0, _name_cd - delta)
	stand_in.velocity = Vector2.ZERO if _busy or _done or _intro or _talk > 0 else \
			Input.get_vector("move_left", "move_right", "move_up", "move_down") * SPEED
	stand_in.move_and_slide()
	var sp := stand_in.get_node_or_null("Sprite") as Sprite2D
	if sp:
		if absf(stand_in.velocity.x) > 2.0:
			sp.flip_h = stand_in.velocity.x < 0.0
		var walking := stand_in.velocity.length() > 4.0
		var col := int(Time.get_ticks_msec() / 160.0) % (6 if walking and kind != "chapter" else 4)   # the hero sheet walks on 6 frames
		var row := 6 if kind == "chapter" else (3 if walking else 0)
		sp.frame_coords = Vector2i(col, row)
	for c in get_tree().get_nodes_in_group("checkpoint"):
		if is_ancestor_of(c) and c.global_position.distance_to(stand_in.global_position) <= CHECKPOINT_RANGE:
			checkpoint = c


## Laras's one action: say the true name, freezing the nearest Faceless in reach.
func _unhandled_input(event: InputEvent) -> void:
	if kind != "chapter" or _busy or _done or _name_cd > 0.0 or not event.is_action_pressed("interact"):
		return
	var best: Node2D = null
	var bd := NAME_RANGE
	for f in get_tree().get_nodes_in_group("faceless"):
		if is_ancestor_of(f) and f.has_method("freeze") and f.global_position.distance_to(stand_in.global_position) <= bd:
			best = f
			bd = f.global_position.distance_to(stand_in.global_position)
	if best:
		get_viewport().set_input_as_handled()
		best.freeze(NAME_FREEZE)
		_name_cd = NAME_COOLDOWN


func spots() -> Array:
	return find_children("*", "", true, false).filter(func(n: Node) -> bool: return n is MemorySpot)


## Ordered spots: `order` n can be done once every spot with a lower order (0 and up) is done.
func can_do(order: int) -> bool:
	return spots().all(func(s: MemorySpot) -> bool: return s.done or s.order < 0 or s.order >= order)


## A MemorySpot reports in; the last counting one finishes the memory.
func spot_done(_spot: MemorySpot) -> void:
	var counting := spots().filter(func(s: MemorySpot) -> bool: return s.counts())
	if not counting.is_empty() and counting.all(func(s: MemorySpot) -> bool: return s.done):
		finish()


## Touched by a threat or seen by a Faceless: fade, back to the last checkpoint, fade in. No counter, no loss.
func fail() -> void:
	if _busy or _done or _intro:
		return
	_busy = true
	_fails += 1
	var zones := get_node("/root/Zones")
	await zones.fade_to(1.0)
	reset()
	await zones.fade_to(0.0)
	_busy = false
	if _fails == 3:   # the third time the pill comes back; threats slow down (MemoryThreat reads fail_count())
		show_objective()


## How many times this memory was failed (3+ makes threats gentler, architecture.md 9b).
func fail_count() -> int:
	return _fails


## The stand-in back at the last checkpoint (else Stand), threats back at their start.
func reset() -> void:
	var at := checkpoint if checkpoint else _stand
	stand_in.global_position = at.global_position if at else Vector2.ZERO
	stand_in.velocity = Vector2.ZERO
	stand_in.reset_physics_interpolation()
	for t in find_children("*", "", true, false):
		if t is MemoryThreat:
			t.reset()


## End line, flag memory_<id>, Events.memory_done, back to the clue. A chapter first asks for the write of Ka.
func finish() -> void:
	while _busy:   # a fail() fade in flight finishes first
		await get_tree().process_frame
	if _done:
		return
	_done = true
	stage.clear_objective()
	stage.hide_meter()
	stage.flash(0.55, 0.9)   # the closing tableau: the whole cloth glows
	await get_tree().create_timer(0.9).timeout
	var ev := get_node("/root/Events")
	if kind == "chapter" and not ev.write_requested.get_connections().is_empty():   # no write card listening: skip, never hang
		ev.write_requested.emit(memory_id, PackedStringArray([LARAS_KA]))
		var got := ""
		while got != memory_id:
			got = await ev.name_written
	await say(_keys("OUT"))
	get_node("/root/Game").set_flag("memory_" + memory_id)
	ev.memory_done.emit(memory_id)
	await get_node("/root/Zones").exit_memory()
