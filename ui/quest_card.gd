class_name QuestCard extends Control
## Quest title and completion cards (docs/quest_story_ux.md 4). A main quest start shows a title card (act, title, stakes line);
## any quest end shows a summary card (title, rewards). Cards queue, never overlap, wait while a dialogue box is open or the
## tree is paused, and never block input. The HUD banner stays for updates.

const GOLD := UIFx.WARM       # quests are amber (ui.md 0.1)
const GOLD_LIGHT := UIFx.HEAD
const CREAM := UIFx.TEXT
const OUTLINE := UIFx.LACQUER
const BAND := Color(0.26, 0.2, 0.42, 0.92)   # tints the cream lontar leaf down to a night band under light text
const ART := "res://assets/art/ui/"
const FADE_IN := 0.5
const HOLD_START := 3.0
const HOLD_DONE := 3.5
const FADE_OUT := 0.6
const CENTER_Y := 120.0
const ACTS := {"mq0": "PROLOG", "mq1": "I", "mqg": "II", "mq2": "III", "mq3": "IV", "mq4": "V", "mq5": "VI"}

var _queue: Array[Dictionary] = []
var _showing := false
var _band: NinePatchRect
var _rule_top: NinePatchRect
var _rule_bottom: NinePatchRect
var _caption: Label
var _title: Label
var _body: Label
var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	modulate.a = 0.0
	visible = false
	_band = _nine("lontar_card", [12, 5, 12, 5])   # the leaf's end studs stay whole, its middle stretches
	_band.self_modulate = BAND
	_rule_top = _nine("book_rule", [6, 0, 0, 0])
	_rule_bottom = _nine("book_rule", [6, 0, 0, 0])
	_caption = _label(UIFx.caps_font(), UIFx.BODY, UIFx.WARM)   # tracked caps kicker (ui.md 1)
	_caption.uppercase = true
	_title = _label(UIFx.display(), UIFx.DISPLAY, GOLD_LIGHT)     # Jersey 15 at 27: the one display size
	_body = _label(UIFx.body_font(), UIFx.BODY, CREAM)
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var ev := get_node_or_null("/root/Events")
	if ev:
		ev.quest_started.connect(_on_started)
		ev.quest_completed.connect(_on_completed)


func _nine(tex: String, m: Array) -> NinePatchRect:
	var r := NinePatchRect.new()
	r.texture = load(ART + tex + ".png")
	r.patch_margin_left = m[0]
	r.patch_margin_top = m[1]
	r.patch_margin_right = m[2]
	r.patch_margin_bottom = m[3]
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	return r


func _label(font: Font, size: int, color: Color) -> Label:
	var l := Label.new()
	if font:
		l.add_theme_font_override("font", font)
		l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", OUTLINE)
	l.add_theme_constant_override("outline_size", 1)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l


## Number of cards waiting (not counting the one on screen).
func pending() -> int:
	return _queue.size()


func is_showing() -> bool:
	return _showing


## A translated string, or "" when the key has no translation.
static func _t(key: String) -> String:
	var s := TranslationServer.translate(key)
	return "" if s == key else String(s)


## The first sentence of text (up to and including . ! or ? followed by a space or the end).
static func first_sentence(text: String) -> String:
	var t := text.strip_edges().replace("\n", " ")
	for i in t.length():
		if t[i] in ".!?" and (i == t.length() - 1 or t[i + 1] == " "):
			return t.substr(0, i + 1)
	return t


## "PROLOG" / "ACT I" caption for a main quest; "" when the quest has no act.
static func act_label(id: String) -> String:
	if not ACTS.has(id):
		return ""
	if id == "mq0":
		return ACTS[id]
	var fmt := _t("UI_ACT_LABEL")
	return (fmt % ACTS[id]) if fmt != "" else ("ACT " + String(ACTS[id]))


## Reward lines for a rewards dict plus the Ilmu gained. Missing keys and empty entries are skipped.
static func build_reward_lines(rewards: Dictionary, ilmu_gain: int) -> PackedStringArray:
	var out := PackedStringArray()
	if ilmu_gain > 0:
		out.append("+%d Ilmu" % ilmu_gain)
	for item in rewards.get("items", []):
		var n := _t("ITEM_%s_NAME" % String(item).to_upper())
		out.append(n if n != "" else String(item).capitalize())
	var shard := int(rewards.get("flask_shard", 0))
	if shard > 0:
		var sf := _t("UI_REWARD_SHARD")
		out.append((sf % shard) if sf != "" else ("+%d flask shard" % shard))
	var pouch := int(rewards.get("herb_pouch", 0))
	if pouch > 0:
		var pf := _t("UI_REWARD_POUCH")
		out.append((pf % pouch) if pf != "" else ("+%d herb pouch" % pouch))
	var lakon := String(rewards.get("lakon", ""))
	if lakon != "":
		var lf := _t("UI_REWARD_LAKON")
		out.append((lf % lakon.capitalize()) if lf != "" else ("Lakon: " + lakon.capitalize()))
	for c in rewards.get("codex", []):
		var n := _t("CODEX_%s_TITLE" % String(c).to_upper())
		if n != "":
			out.append(n)
	return out


## Ilmu a quest paid out: the same formula as Game._complete (the quest's resolution is still stored when quest_completed fires).
func _ilmu_gain(id: String, q: QuestData) -> int:
	var game := get_node_or_null("/root/Game")
	if game == null or q == null or not q.size in ["S", "M", "L"]:
		return 0
	var row: Array = game.QUEST_ILMU.get(q.zone, game.QUEST_ILMU.tatar_sunda)
	var base: int = row[["S", "M", "L"].find(q.size)]
	var res := ""
	if game.quests.has(id):
		res = String(game.quests[id].get("resolution", ""))
	return base * 3 / 2 if res == "fight" else base


func _on_started(id: String) -> void:
	var q := QuestData.by_id(id)
	if q == null or q.kind != "main":
		return
	var title := _t("Q_%s_TITLE" % id.to_upper())
	if title == "":
		return
	var stakes := first_sentence(_t("Q_%s_DESC" % id.to_upper()))
	var lines := PackedStringArray()
	if stakes != "":
		lines.append(stakes)
	_queue.append({"caption": act_label(id), "title": title, "lines": lines, "hold": HOLD_START})


func _on_completed(id: String) -> void:
	var q := QuestData.by_id(id)
	if q == null:
		return
	var title := _t("Q_%s_TITLE" % id.to_upper())
	if title == "":
		return
	var lines := build_reward_lines(get_node("/root/Game").quest_rewards(q), _ilmu_gain(id, q))
	var caption := _t("UI_Q_DONE")
	_queue.append({"caption": caption, "title": title, "lines": lines, "hold": HOLD_DONE})


func _blocked() -> bool:
	if get_tree().paused:
		return true
	var box := get_node_or_null("../DialogueBox")
	return box != null and box.has_method("is_open") and box.is_open()


func _process(_delta: float) -> void:
	if _showing or _queue.is_empty() or _blocked():
		return
	_show(_queue.pop_front())


func _show(card: Dictionary) -> void:
	_showing = true
	_caption.text = String(card.caption)
	_title.text = String(card.title)
	var lines: PackedStringArray = card.lines
	_body.text = "\n".join(lines)
	_body.visible = not lines.is_empty()
	# layout on the 2 px grid: 10 pad, caption 12 (13 box), 4 gap, title 24, 4 gap, body lines (UIFx.LINE each, wrapped), 10 pad
	_body.size = Vector2(360, UIFx.LINE - 1)
	var body_h := 0.0
	if not lines.is_empty():
		body_h = UIFx.LINE * maxi(1, _body.get_line_count())   # the label's own wrap count: the band grows to fit every line
	var h := 10.0 + 12.0 + 4.0 + 24.0 + (4.0 + body_h if body_h > 0.0 else 0.0) + 10.0
	var top := roundf(CENTER_Y - h / 2.0)
	_band.position = Vector2(0, top)
	_band.size = Vector2(480, h)
	_rule_top.position = Vector2(0, top)
	_rule_top.size = Vector2(480, 3)
	_rule_bottom.position = Vector2(0, top + h - 3.0)
	_rule_bottom.size = Vector2(480, 3)
	_caption.position = Vector2(0, top + 10.0)
	_caption.size = Vector2(480, UIFx.LINE - 1)
	_title.position = Vector2(0, top + 26.0)
	_title.size = Vector2(480, 24)
	_body.position = Vector2(60, top + 54.0)
	_body.size = Vector2(360, maxf(body_h - 1.0, 0.0))
	if _tween:
		_tween.kill()
	visible = true
	modulate.a = 0.0
	_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.tween_property(self, "modulate:a", 1.0, FADE_IN)
	_tween.tween_interval(float(card.hold))
	_tween.tween_property(self, "modulate:a", 0.0, FADE_OUT)
	_tween.tween_callback(_finish)


func _finish() -> void:
	visible = false
	_showing = false
