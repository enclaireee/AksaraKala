extends SceneTree
## Performance report, not a pass/fail test (.docs/performance.md, Step 0). Always exits 0.
## For every zone: cold build time (first load), warm build time (second load, as on a respawn), node count, and a
## fingerprint of everything the build produced (all TileMapLayer cells, the grid, deco props, entity positions), so a
## change to the build can be checked to give byte-identical areas. Then audio: streams cached after every zone's
## music and ambience has been requested once, and static memory.
## Run: $GODOT --headless --path . -s tests/perf_probe.gd

const RUNS := 3   # warm builds per zone; the median is reported
var only := OS.get_environment("PROBE_ONLY")   # a comma list of zone ids, or empty for all


func _h(ctx: HashingContext, b: PackedByteArray) -> void:
	if not b.is_empty():
		ctx.update(b)


## md5 per part: tiles | grid | deco props | everything under Entities (name, class, position; names the engine makes
## up, @..., count only as "@").
func _fingerprint(z: Node) -> String:
	var parts := PackedStringArray()
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_MD5)
	for l: TileMapLayer in z.find_children("*", "TileMapLayer", true, false):
		_h(ctx, str(z.get_path_to(l)).to_utf8_buffer())
		_h(ctx, l.tile_map_data)
	parts.append(ctx.finish().hex_encode().substr(0, 6))
	ctx.start(HashingContext.HASH_MD5)
	_h(ctx, "\n".join(PackedStringArray(z.grid)).to_utf8_buffer())
	parts.append(ctx.finish().hex_encode().substr(0, 6))
	ctx.start(HashingContext.HASH_MD5)
	if z.deco:
		_h(ctx, var_to_str(z.deco.placed).to_utf8_buffer())
	parts.append(ctx.finish().hex_encode().substr(0, 6))
	ctx.start(HashingContext.HASH_MD5)
	for n: Node in z.entities.find_children("*", "", true, false):   # nothing moves: the zone is not processing
		var nm := String(n.name)
		_h(ctx, ("%s|%s|%s" % ["@" if nm.begins_with("@") else nm, n.get_class(), n.get("position")]).to_utf8_buffer())
		if n.get("layout") != null:   # town modules record what they placed (villagers, animals, houses)
			_h(ctx, var_to_str(n.get("layout")).to_utf8_buffer())
	parts.append(ctx.finish().hex_encode().substr(0, 6))
	return "-".join(parts)


func _build_once(packed: PackedScene) -> Array:
	var n := packed.instantiate()
	if not (n is Zone):
		n.free()
		return []
	var z := n as Zone
	z.process_mode = Node.PROCESS_MODE_DISABLED
	var t0 := Time.get_ticks_usec()
	root.add_child(z)   # _ready runs _build
	var us := Time.get_ticks_usec() - t0
	var nodes := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	var fp := _fingerprint(z)
	root.remove_child(z)
	z.free()
	return [us, nodes, fp]


func _initialize() -> void:
	await process_frame
	var zones := root.get_node("Zones")
	var base_nodes := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	print("zone                 cold_ms  warm_ms  nodes  fingerprint")
	var tot_cold := 0.0
	var tot_warm := 0.0
	for id: String in zones.ZONES:
		if only != "" and not (id in only.split(",")):
			continue
		var packed := load(zones.ZONES[id]) as PackedScene
		if packed == null:
			continue
		var cold: Array = _build_once(packed)
		if cold.is_empty():
			continue   # not a Zone (the hub)
		var warm: Array[float] = []
		for i in RUNS:
			var r: Array = _build_once(packed)
			warm.append(r[0] / 1000.0)
			if r[2] != cold[2]:
				print("  NOTE: %s warm fingerprint %s differs from cold %s" % [id, r[2], cold[2]])
		warm.sort()
		var w := warm[RUNS / 2]
		tot_cold += cold[0] / 1000.0
		tot_warm += w
		print("%-20s %7.1f  %7.1f  %5d  %s" % [id, cold[0] / 1000.0, w, cold[1] - base_nodes, cold[2]])
	print("TOTAL                %7.1f  %7.1f" % [tot_cold, tot_warm])
	var orphans := int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	print("orphan nodes after all builds: %d" % orphans)

	var audio := root.get_node("Audio")
	var mem0 := Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
	for id: String in zones.ZONES:   # walk the whole world once, as a full playthrough does
		audio.apply_plan(audio.plan_for(id))
		var plan: Dictionary = audio.plan_for(id)
		for key: String in ["base", "combat", "boss"]:
			if String(plan.get(key, "")) != "":
				audio.stream("music/" + String(plan[key]), true)
		if String(plan.get("amb", "")) != "":
			audio.stream("amb/" + String(plan["amb"]), true)
		audio._on_zone(id)
		for i in 10:   # 5 s in the zone: the old tracks fade out and stop
			audio._process(0.5)
		await create_timer(0.1).timeout   # real time for the audio thread to drop the stopped playbacks
	var mem1 := Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
	var long := 0
	for k: String in audio._cache:
		if k.begins_with("music/") or k.begins_with("amb/"):
			long += 1
	print("audio: %d music/amb streams cached after visiting every zone; static memory %.1f MB -> %.1f MB" % [long, mem0, mem1])

	# Runtime, in the busiest town (49 NPCs, villagers, animals): script time per frame, then one quest event.
	var town := (load(zones.ZONES["desa_purwa"]) as PackedScene).instantiate()
	root.add_child(town)
	for i in 30:
		await process_frame
	# Two marker nodes: one processes before everything else, one after, so the span between them is the time all the
	# game's _process (and _physics_process) callbacks took that frame. Headless sleeps between frames, so wall clock
	# would only show that sleep.
	const FRAMES := 300
	var first := Mark.new(-1000000000)
	var last := Mark.new(1000000000)
	last.start = first
	root.add_child(first)
	root.add_child(last)
	for i in FRAMES:
		await process_frame
	print("frame (desa_purwa): game scripts take %.3f ms in _process + %.3f ms in _physics_process per frame (mean of %d)" % [last.proc_sum / last.n / 1000.0, last.phys_sum / maxi(last.pn, 1) / 1000.0, last.n])
	first.queue_free()
	last.queue_free()
	var ev := root.get_node("Events")
	var t0 := Time.get_ticks_usec()
	ev.quest_updated.emit("mq0")
	print("one quest_updated event (desa_purwa): %.1f ms" % ((Time.get_ticks_usec() - t0) / 1000.0))
	quit(0)


class Mark extends Node:
	var start: Mark
	var t := 0
	var tp := 0
	var proc_sum := 0
	var phys_sum := 0
	var n := 0
	var pn := 0

	func _init(prio: int) -> void:
		process_priority = prio
		process_physics_priority = prio
		process_mode = Node.PROCESS_MODE_ALWAYS

	func _process(_d: float) -> void:
		if start == null:
			t = Time.get_ticks_usec()
		elif start.t > 0:
			proc_sum += Time.get_ticks_usec() - start.t
			n += 1

	func _physics_process(_d: float) -> void:
		if start == null:
			tp = Time.get_ticks_usec()
		elif start.tp > 0:
			phys_sum += Time.get_ticks_usec() - start.tp
			pn += 1
