extends SceneTree
## Soft-lock hunt: DemoRoute plays New Game to the end of MQ5, then every side quest, but each deed must be one
## a player could do at that moment: the area reachable on foot through open kabut gates and opened shortcuts
## (or by fast travel to a petilasan already rested at), the thing that fires the event live in the world (its
## `cond` true and not used up: an NPC with something to say that counts as a talk, a clue, a cleared-once
## encounter, a boss not dead), and no step that DemoRoute had to nudge. Prints FAIL per dead end, WARN for a
## marker that points away from the only live source. Run: $GODOT --headless --path . -s tests/playthrough_test.gd
## ponytail: walks choice 0 of every dialogue for one class (warrior); demo_test covers the other classes'
## route, and the other choices are not walked.


class Strict extends DemoRoute:
	## Events whose source must be live; others (items, glyphs, kills, written names) can come from dialogue.
	const HARD := ["talked_to", "clue_examined", "area_cleared", "boss_defeated", "area_entered", "puzzle_solved",
			"trial_completed", "memory_done", "petilasan_activated"]
	var src := {}          # "sig:arg" -> [{zone, cond, use}] where use is the flag/kill that spends it ("" = never)
	var fails := {}        # message -> true (dedupe)
	var warns := {}
	var lit := {}          # zone -> true, petilasans rested at (fast travel)
	var quiet := 0         # >0 while an event comes from dialogue, a beat, an arrival or loot: sourced by that
	var cur := ""          # "mq1 step 5 (talked_to:x)" of the step being worked
	var want := ""         # the trigger DemoRoute is doing, and the area its marker names
	var want_zone := ""
	var _kinds := {}       # enemy scene -> kind
	var late := false      # the after-the-story run of every side quest: a dead end is a fail, not a wait

	func index() -> void:
		for zone: String in z.ZONES:
			for s: Dictionary in _spots_of(zone).values():
				var p: Dictionary = s.get("props", {})
				var sc := String(s.get("scene", ""))
				var cond := str(p.get("cond", ""))
				var f := sc.get_file().get_basename()
				match f:
					"npc":
						_add("talked_to:" + str(p.get("npc_id", "")), zone, cond, "", str(p.get("npc_id", "")))
					"clue":
						if str(p.get("clue_id", "")) != "":
							_add("clue_examined:" + str(p.clue_id), zone, cond, "")
						if str(p.get("memory_id", "")) != "":
							_add("memory_done:" + str(p.memory_id), zone, cond, "flag:memory_" + str(p.memory_id))
					"rehearsal":
						_add("clue_examined:" + str(p.get("id", "")), zone, cond, "flag:clue_" + str(p.get("id", "")))
					"trigger":
						var t := str(p.get("trigger_id", ""))
						_add("area_entered:" + t, zone, cond, "")
						_add("puzzle_solved:" + t.trim_prefix("puzzle_"), zone, cond, "")
					"encounter":
						var a := str(p.get("area_id", ""))
						if a != "":
							_add("area_cleared:" + a, zone, cond, "flag:cleared:" + a)
						for wave: Array in p.get("waves", []):
							for e: Array in wave:
								var k := _kind(str(e[0]))
								if k != "":
									_add("boss_defeated:" + k, zone, cond, "kill:" + k)
									_add("enemy_killed:" + k, zone, cond, "")
					"petilasan":
						_add("petilasan_activated:" + str(p.get("id", "")), zone, cond, "")
					"chest":
						_add("item_picked:" + str(p.get("item_id", "")), zone, cond, "flag:chest:" + str(p.get("chest_id", "")))
					"pickup":
						var it := str(p.get("item_id", ""))
						_add("item_picked:" + it, zone, cond, "flag:pickup:" + (it if it != "" else str(p.get("codex_id", ""))))
					_:
						if sc.begins_with("res://entities/bosses/") or sc.begins_with("res://entities/enemies/"):
							var k := _kind(sc)
							if k != "":
								_add("boss_defeated:" + k, zone, cond, "kill:" + k)
								_add("enemy_killed:" + k, zone, cond, "")

	func _add(key: String, zone: String, cond: String, use: String, npc := "") -> void:
		if not src.has(key):
			src[key] = []
		src[key].append({"zone": zone, "cond": cond, "use": use, "npc": npc})

	func _kind(scene: String) -> String:
		if not _kinds.has(scene):
			var k := ""
			if ResourceLoader.exists(scene):
				var n: Node = (load(scene) as PackedScene).instantiate()
				var v: Variant = n.get("kind")
				k = String(v) if v is String or v is StringName else ""
				n.free()
			_kinds[scene] = k
		return _kinds[scene]

	## Can the hero get to `to` right now: on foot (gates and shortcuts as Zones routes), or fast travel.
	func _reachable(to: String) -> bool:
		if to == here or z._bfs_next(here, to, true) != "":
			return true
		for p: String in lit:
			if p == to or z._bfs_next(p, to, true) != "":
				return true
		return false

	## Is this source usable now (cond holds in its own area, an NPC with something to say). A quiet talk
	## still runs its `do` (Ciung's refusal shows the basket); a talk that never counts ends as a nudge note.
	## Used-up sources are fine: Game._catch_up counts clues, memories, kills, clears and held items.
	func _live(s: Dictionary) -> bool:
		var keep: String = z.current_zone
		z.current_zone = s.zone
		var ok: bool = g.check(s.cond)
		if ok and s.npc != "":
			var d := DialogueData.by_id(s.npc)
			ok = d != null and not g.pick_entry(d.entries).is_empty()
		z.current_zone = keep
		return ok

	func fail(msg: String) -> void:
		fails["%s: %s" % [cur, msg]] = true

	## As a player would: of the parts still open (an `all` step) or the routes (`alt`), do one that can be
	## done now first. Nothing doable: a main quest is stuck (super fails and nudges); a side quest waits.
	func _advance(q: String) -> bool:
		var st: QuestStep = g.current_step(q)
		if st == null:
			return false
		cur = "%s step %d (%s)" % [q, int(g.quests.get(q, {}).get("step", 0)) + 1, st.on if st.on != "" else "all/alt"]
		var before := _sig(q)
		var subs := []
		var trig := _all_subs(st)
		for i in trig.size():
			if st.all.is_empty() or not g._all_bit(q, i):
				subs.append(trig[i])
		for k: String in st.alt:
			if k != st.on and st.all.is_empty():
				subs.append([k, str(st.marker.get("zone", "")), str(st.marker.get("id", ""))])
		for sub: Array in subs:
			var npc := str(sub[0]).trim_prefix("talked_to:")
			var d := DialogueData.by_id(npc) if str(sub[0]).begins_with("talked_to:") else null
			if d and g.pick_entry(d.entries).get("quiet", false):
				for s: Dictionary in _sources("talked_to", npc):   # a refusal that opens the way (Ciung)
					if _live(s) and _reachable(s.zone):
						_travel(s.zone)
						_talk(npc)
						break
				continue
			if _doable(sub[0]):
				_do(q, before, sub[0], sub[1], sub[2])
				if _sig(q) != before:
					return true
		return super._advance(q) if q in MAIN or late else false

	## A world-prop trigger has a live, reachable source, after fetching any item it asks for (the objective
	## text names where; tt_beringin's sodo lanang for the jetty post).
	func _doable(on: String) -> bool:
		var kv := on.split(":", true, 1)
		if kv.size() < 2 or kv[0] not in HARD:
			return true
		var any := _sources(kv[0], kv[1])
		for s: Dictionary in any:
			_fetch(s)
		return any.is_empty() or any.any(func(s: Dictionary) -> bool: return _live(s) and _reachable(s.zone))

	func _sources(sig: String, arg: String) -> Array:
		var out := []
		for key: String in src:
			var kv := key.split(":", true, 1)
			if kv.size() == 2 and g._matches(sig + ":" + arg, kv[0], kv[1]):
				out.append_array(src[key])
		return out

	func _fetch(s: Dictionary) -> void:
		var need: Array = Array(s.cond.split(","))
		var d := DialogueData.by_id(s.npc) if s.npc != "" else null
		if d:
			for e: Dictionary in d.entries:
				if not e.get("quiet", false):
					need.append_array(e.get("if", []))
		for c: String in need:
			if c.begins_with("item:") and not g.check(c):
				for p: Dictionary in src.get("item_picked:" + c.substr(5), []):
					if _live(p) and _reachable(p.zone):
						_travel(p.zone)
						_give(c.substr(5))
						break

	func _do(q: String, before: String, on: String, zone: String, id: String) -> void:
		want = on
		want_zone = zone
		super._do(q, before, on, zone, id)
		want = ""
		want_zone = ""

	func _travel(to: String, deeds := true) -> void:
		if to != "" and z.ZONES.has(to) and not _reachable(to):
			if z._bfs_next(here, to, false) == "":
				fail("no route at all from %s to %s" % [here, to])
			else:
				fail("cannot walk from %s to %s: kabut gate shut, no rested petilasan beyond it" % [here, to])
		super._travel(to, deeds)

	func _arrive(zone: String, spawn: String) -> void:
		quiet += 1
		super._arrive(zone, spawn)
		quiet -= 1

	func _loot(zone: String) -> void:
		quiet += 1
		super._loot(zone)
		quiet -= 1

	func _play_beats() -> void:
		quiet += 1
		super._play_beats()
		quiet -= 1

	func _play(e: Dictionary, file: Array, depth: int) -> void:
		quiet += 1
		super._play(e, file, depth)
		quiet -= 1

	## The checks run before each deed, on the world as the player would find it.
	func _rest(id: String) -> void:
		_pre("petilasan_activated", id)
		if _pet(here) == id:
			lit[here] = true
		quiet += 1
		super._rest(id)
		quiet -= 1

	func _kill_boss(id: String) -> void:
		_pre("boss_defeated", id)
		quiet += 1
		super._kill_boss(id)
		quiet -= 1

	func _clear(area_id: String) -> void:
		_pre("area_cleared", area_id)
		quiet += 1
		super._clear(area_id)
		quiet -= 1

	func _act(action: String) -> void:
		var kv := action.split(":", true, 1)
		var sig: String = {"clue": "clue_examined", "puzzle": "puzzle_solved", "memory": "memory_done"}.get(kv[0], "")
		if sig != "" and kv.size() == 2:
			_pre(sig, kv[1])
		quiet += 1
		super._act(action)
		quiet -= 1

	## As Npc.interact: an NPC with nothing to say (or only a refusal) does not count as a talk.
	func _talk(npc: String) -> void:
		if want == "" or g._matches(want, "talked_to", npc):
			_pre("talked_to", npc)   # a talk to whoever stands at the marker on the way is optional
		var d := DialogueData.by_id(npc)
		if d != null and g.pick_entry(d.entries).is_empty():
			return   # DemoRoute counts it anyway; the game does not
		quiet += 1
		super._talk(npc)
		quiet -= 1

	func _event(sig: String, arg: String) -> void:
		_pre(sig, arg)   # area_entered, trial_completed and the nudges reach here directly
		super._event(sig, arg)

	func _pre(sig: String, arg: String) -> void:
		if quiet > 0 or sig not in HARD:
			return
		var ev := sig + ":" + arg
		var any := _sources(sig, arg)
		if any.is_empty():
			return   # not a world prop (dialogue, script, Kelir scene): quest_reach_test covers that it exists
		var live := any.filter(func(s: Dictionary) -> bool: return _live(s) and _reachable(s.zone))
		if live.is_empty():
			var why := []
			for s: Dictionary in any:
				var said := ""
				if s.npc != "" and g.check(s.cond):
					var d := DialogueData.by_id(s.npc)
					var e: Dictionary = g.pick_entry(d.entries) if d else {}
					said = " says %s%s" % [e.get("if", "nothing"), " (quiet)" if e.get("quiet", false) else ""]
				why.append("%s[%s]%s flag=%s" % [s.zone, s.cond, said, g.has_flag(arg)])
			fail("%s has no live source now; sources: %s; quests %s" % [ev, ", ".join(why), cur.get_slice(" ", 0) + "=" + str(g.quests.get(cur.get_slice(" ", 0), {}))])
		elif want_zone != "" and g._matches(want, sig, arg) and not live.any(func(s: Dictionary) -> bool: return s.zone == want_zone):
			warns["%s: %s is done in %s but the marker says %s" % [cur, ev, live[0].zone, want_zone]] = true

	## Every side quest not done yet: go to the giver, start it, then work it to the end.
	func sides() -> void:
		late = true
		for id: String in _side_ids:
			var data := QuestData.by_id(id)
			if data == null or g.quest_state(id) == "done":
				continue
			cur = "%s (start)" % id
			if g.quest_state(id) == "available" and data.giver != "":
				var at := ""
				for s: Dictionary in src.get("talked_to:" + data.giver, []):
					if g.check(s.cond):
						at = s.zone
				if at == "":
					fail("giver %s is not standing anywhere" % data.giver)
				else:
					_travel(at)
					_talk(data.giver)
					_play_beats()
			if g.quest_state(id) == "available":
				fail("talking to %s did not start it" % data.giver)
				g.start_quest(id)
			for _n in 60:
				if g.quest_state(id) != "active" or not _advance(id):
					break
				_loot(here)
			if g.quest_state(id) != "done":
				var st: QuestStep = g.current_step(id)
				fails["%s: ends %s at step %d (%s)" % [id, g.quest_state(id), int(g.quests.get(id, {}).get("step", 0)) + 1, st.on if st else "?"]] = true


func _initialize() -> void:
	await process_frame
	var game := root.get_node("Game")
	var zones := root.get_node("Zones")
	var keep: String = game.save_path
	game.save_path = "user://playthrough_test_save.json"
	var r := Strict.new(game, zones)
	r.index()
	r.build("warrior", {"kind": "act", "quest": "mq5", "step": 1 << 20, "zone": "", "boss": ""})
	game.replaying = true
	for q: String in DemoRoute.MAIN:
		if game.quest_state(q) != "done":
			r.fails["%s ends %s (%s)" % [q, game.quest_state(q), ", ".join(r.notes)]] = true
	r.sides()
	game.replaying = false
	for n: String in r.notes:
		if not n.begins_with("no main quest"):
			r.fails["route: " + n] = true
	for m: String in r.warns:
		printerr("WARN: " + m)
	for m: String in r.fails:
		printerr("FAIL: " + m)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.save_path))
	game._reset()
	game.save_path = keep
	quit(1 if not r.fails.is_empty() else 0)
