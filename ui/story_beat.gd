extends Node
## Story beats (quests.md 4): plays the first entry of data/dialogue/beats.tres whose `if` holds, once (each entry
## sets its own `beat_<id>` flag). Tried on Game.changed, after a zone loads and after each dialogue. While a dialogue,
## the menu (pause/tab/petilasan), a glyph lesson or the write card is up, it keeps retrying in _process.

var _data: DialogueData
var _busy := false      # a beat is playing: never two at once
var _pending := false   # a beat is ready but something is open


func _ready() -> void:
	_data = DialogueData.by_id("beats")
	var ev := get_node("/root/Events")
	get_node("/root/Game").changed.connect(_try)
	ev.zone_entered.connect(func(_z: String) -> void: _try.call_deferred())   # deferred: the zone has loaded
	ev.dialogue_finished.connect(_try.call_deferred)


func _process(_delta: float) -> void:
	if _pending and not _blocked():
		_try()


## The tree is paused while the dialogue box, the menu or the write card is open; a lesson card does not pause.
func _blocked() -> bool:
	var lesson := get_node_or_null("../GlyphLesson")
	var box := get_node_or_null("../DialogueBox")
	return get_tree().paused or (box != null and box.is_open()) or (lesson != null and (lesson.active != "" or lesson.writing != ""))


func _try() -> void:
	if _busy or _data == null or not is_inside_tree():   # a deferred call can arrive after a test freed the zone
		return
	var game := get_node("/root/Game")
	var e := _data.pick(game)
	_pending = not e.is_empty()
	if not _pending or _blocked():
		return
	_busy = true
	_pending = false
	var dir := get_node_or_null("../SceneDirector")
	var staged: bool = dir != null and not (e.get("lines", []) as Array).is_empty()   # a do-only entry shows no box: no bars
	if staged:
		dir.begin_beat()
	await game.play("", e)
	if staged and is_instance_valid(dir):
		dir.end_beat()
	_busy = false
	_try()
