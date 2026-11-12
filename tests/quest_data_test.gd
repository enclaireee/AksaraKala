extends SceneTree
## Static check of the shipped quest and dialogue data (quests.md 7.8). Exits 0 on pass, prints only failures.

const SIGNALS := ["talked_to", "item_picked", "boss_defeated", "area_cleared", "area_entered", "zone_entered",
	"petilasan_activated", "glyph_learned", "spell_cast", "class_chosen", "enemy_killed", "name_written",
	"clue_examined", "memory_done", "puzzle_solved", "trial_completed"]
var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


## key -> true when both id and en are non-empty.
func table(path: String) -> Dictionary:
	var out := {}
	var f := FileAccess.open(path, FileAccess.READ)
	f.get_csv_line()
	while not f.eof_reached():
		var r := f.get_csv_line()
		if r.size() >= 3:
			out[r[0]] = r[1] != "" and r[2] != ""
	return out


func _initialize() -> void:
	var qt := table("res://data/text/quests.csv")
	var dt := table("res://data/text/dialogue.csv")
	var quests := QuestData.all()
	check(quests.size() == 31, "expected 31 quest files, got %d" % quests.size())
	check(quests.size() >= 6, "expected at least 6 quests, got %d" % quests.size())
	var dialogues: Array[DialogueData] = []
	for f in DirAccess.get_files_at("res://data/dialogue"):
		if f.ends_with(".tres"):
			dialogues.append(load("res://data/dialogue/" + f))
	var flags := {}
	for q in quests:
		for s in q.steps:
			flags[s.set_flag] = true
			for a in s.all:   # an `all` step's leads set their own flags (mq1_1, mq1_3)
				flags[a.get("set_flag", "")] = true
		for fl in q.rewards.get("flags", []):
			flags[fl] = true
	for d in dialogues:
		for e in d.entries:
			for a in e.get("do", []):
				if a.begins_with("flag:"):
					flags[a.substr(5)] = true
	for q in quests:
		check(qt.get("Q_%s_TITLE" % q.id.to_upper(), false), "%s: title key missing or empty" % q.id)
		for f in q.requires:
			check(flags.has(f), "%s: requires flag %s is never set" % [q.id, f])
		for it in q.rewards.get("items", []):
			check(ResourceLoader.exists("res://data/items/%s.tres" % it), "%s: reward item %s missing" % [q.id, it])
		for s in q.steps:
			check(qt.get(s.objective, false), "%s: objective key %s missing or empty" % [q.id, s.objective])
			# A step has its own `on`, or an empty `on` plus an `all` array of {on, set_flag} leads (quests.md 7.1).
			for o: String in ([s.on] if s.on != "" else s.all.map(func(a: Dictionary) -> String: return a.on)):
				check(o.split(":")[0] in SIGNALS, "%s: unknown signal in '%s'" % [q.id, o])
			# every step points somewhere; an `all` step's sub-goals are {on, objective, marker?} with real text
			check(not s.marker.is_empty(), "%s: step %s has no marker" % [q.id, s.objective])
			if not s.all.is_empty():
				check(s.on == "", "%s: all step %s must leave `on` empty" % [q.id, s.objective])
			for sub: Dictionary in s.all:
				check(str(sub.get("on", "")) != "", "%s: sub-step of %s has no `on`" % [q.id, s.objective])
				check(qt.get(str(sub.get("objective", "")), false), "%s: sub-goal key '%s' missing" % [q.id, sub.get("objective", "")])
				var sm: Dictionary = sub.get("marker", {})
				check(sm.is_empty() or (sm.get("zone", "") != "" and sm.get("id", "") != ""), "%s: sub-marker needs zone and id" % q.id)
			# ponytail: markers are only checked for shape, not against the zone docs
			check(s.marker.is_empty() or (s.marker.get("zone", "") != "" and s.marker.get("id", "") != ""),
				"%s: marker needs zone and id" % q.id)
	for d in dialogues:
		check(d.name_key == "" or dt.get(d.name_key, false), "%s: name key %s missing" % [d.npc_id, d.name_key])
		for e in d.entries:
			for k in e.get("lines", []):
				if k.begins_with("#"):   # scene cue (#cam, #wait ...), not a text key
					continue
				if k.begins_with("@"):   # speaker switch; a bare "@" clears the tag
					k = k.substr(1)
					if k == "":
						continue
				check(dt.get(k, false), "%s: line key %s missing or empty" % [d.npc_id, k])
			for a in e.get("do", []):
				var p: PackedStringArray = a.split(":", true, 1)
				if p[0] == "start":
					check(QuestData.by_id(p[1]) != null, "%s: start of unknown quest %s" % [d.npc_id, p[1]])
				elif p[0] == "learn":
					check(ResourceLoader.exists("res://data/spells/%s.tres" % p[1]), "%s: learn of unknown glyph %s" % [d.npc_id, p[1]])
	var ct := table("res://data/text/codex.csv")
	var ids := {}
	for f in DirAccess.get_files_at("res://data/codex"):
		if f.ends_with(".tres"):
			var c: CodexEntry = load("res://data/codex/" + f)
			ids[c.id] = true
			var U := c.id.to_upper()
			check(ct.get("CODEX_%s_TITLE" % U, false) and ct.get("CODEX_%s_BODY" % U, false), "codex %s: TITLE or BODY missing" % c.id)
			if c.category == "enemy" and c.id not in ["sandekala", "sangkuriang", "bandit", "bandit_archer"]:
				check(ct.get("CODEX_%s_WEAK" % U, false), "codex %s: WEAK missing" % c.id)
	for q in quests:
		for c in q.rewards.get("codex", []):
			check(ids.has(c), "%s: codex reward %s has no .tres" % [q.id, c])
	for d in dialogues:
		for e in d.entries:
			for a in e.get("do", []):
				if a.begins_with("codex:"):
					check(ids.has(a.substr(6)), "%s: codex action %s has no .tres" % [d.npc_id, a])
	for i in 2:   # script.md 4: two cards, PROLOGUE_3-5 retired
		check(dt.get("PROLOGUE_%d" % (i + 1), false), "PROLOGUE_%d missing" % (i + 1))
	quit(1 if fails > 0 else 0)
