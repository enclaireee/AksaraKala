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
	if find_children("*", "CanvasModulate", true, false).is_empty():
		var cm := CanvasModulate.new()
		cm.color = COOL if kind == "chapter" else WARM
		add_child(cm)
	var ui := find_child("GameUI", true, false)
	if ui == null:
		ui = load(UI_SCENE).instantiate()
		add_child(ui)
	var hud := ui.get_node_or_null("HUD")
	if hud:   # it reads the hero's hp/stamina/sakti, which a stand-in does not have
		hud.visible = false
		hud.process_mode = Node.PROCESS_MODE_DISABLED
	_start.call_deferred()


func _start() -> void:
	await say(_keys("IN"))


## Speaker of every memory line: Semar the dalang, Laras in her chapters.
func speaker() -> String:
	return "NPC_LARAS_NAME" if kind == "chapter" else "NPC_SEMAR_NAME"


## Plays these line keys in the dialogue box; returns when it closed. No keys, no box.
func say(keys: PackedStringArray) -> void:
	if not keys.is_empty():
		await get_node("/root/Game").play(speaker(), {"lines": keys})


## MEM_<ID>_<part> and _<part>_2, those that exist. A gap memory's text id is gap_<letter> (script.md).
func _keys(part: String) -> PackedStringArray:
	var tid := memory_id if kind != "gap" or memory_id.begins_with("gap_") else "gap_" + memory_id
	var out := PackedStringArray()
	for k in ["MEM_%s_%s" % [tid.to_upper(), part], "MEM_%s_%s_2" % [tid.to_upper(), part]]:
		if tr(k) != k:
			out.append(k)
	return out


func _physics_process(delta: float) -> void:
	if stand_in == null:
		return
	_name_cd = maxf(0.0, _name_cd - delta)
	stand_in.velocity = Vector2.ZERO if _busy or _done else \
			Input.get_vector("move_left", "move_right", "move_up", "move_down") * SPEED
	stand_in.move_and_slide()
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
	if _busy or _done:
		return
	_busy = true
	var zones := get_node("/root/Zones")
	await zones.fade_to(1.0)
	reset()
	await zones.fade_to(0.0)
	_busy = false


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
