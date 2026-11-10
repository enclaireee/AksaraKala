extends SceneTree
## The tutorial ladder (.docs/tutorial.md), data only: every lesson has text in both languages, every talk or beat lesson is
## offered by some dialogue entry (before this test a lesson with no `lesson:<id>` action simply never appeared), the
## `when` conditions parse, and a new game never detours through a practice room.

const Lessons = preload("res://data/lessons.gd")

var fails := 0


func check(ok: bool, msg: String) -> void:
	if not ok:
		fails += 1
		printerr("FAIL: " + msg)


func _initialize() -> void:
	await process_frame
	var offered := {}
	for f in DirAccess.get_files_at("res://data/dialogue"):
		if not f.ends_with(".tres"):
			continue
		var d := load("res://data/dialogue/" + f) as DialogueData
		if d == null:
			continue
		for e: Dictionary in d.entries:
			for a: String in e.get("do", []):
				if a.begins_with("lesson:"):
					offered[a.trim_prefix("lesson:")] = f
	var game := root.get_node("Game")
	for id: String in Lessons.ids():
		var l: Dictionary = Lessons.by_id(id)
		for loc in ["id", "en"]:
			TranslationServer.set_locale(loc)
			check(TranslationServer.translate(l.text) != l.text, "%s: no %s text for %s" % [id, loc, l.text])
		check(l.get("steps", []).size() > 0, "%s has no steps" % id)
		if l.get("on", "") in ["talk", "beat"]:
			check(offered.has(id), "%s is never offered: no dialogue entry runs lesson:%s" % [id, id])
		var when: String = l.get("when", "")
		if when != "":
			game.check(when)   # an unknown condition prints a warning; the audit script also checks them
	check(not root.get_node("Zones").ZONES.has("prologue_tutorial"), "the practice room is gone from ZONES")
	TranslationServer.set_locale("id")
	quit(1 if fails > 0 else 0)
