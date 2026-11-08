class_name AreaTitle extends Control
## Area title card (ui.md 3b): region name in pixel display caps, a gold rule growing from the centre, the area name under it.
## Shown on a region change and on the first visit of an area in a save (flag seen_area_<id>); never blocks or pauses.
## Region names are proper nouns (no REGION_<PREFIX> key exists), so they live here; AREA_<ID> is used when a key exists.

const REGIONS := {
	"ts": "Tatar Sunda", "kg": "Keraton Galuh", "mt": "Mataram", "tt": "Tanah Timur",
	"sk": "Segara Kidul", "gk": "Gua Kala", "desa_purwa": "Desa Purwa",
}
const GOLD := Color("C8B38A")
const CREAM := Color("EADFC4")
const OUTLINE := Color("140E0A")
const FADE_IN := 0.6
const HOLD := 2.2
const FADE_OUT := 0.8
const RULE_W := 150.0
const Y := 70.0

static var _last_region := ""   # survives the per-zone GameUI instances

var _region: Label
var _area: Label
var _rule: ColorRect
var _tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	modulate.a = 0.0
	visible = false
	var fv := FontVariation.new()
	fv.base_font = load("res://assets/fonts/Almendra-Bold.ttf")
	fv.spacing_glyph = 2
	_region = Label.new()
	_region.add_theme_font_override("font", fv)
	_region.add_theme_font_size_override("font_size", 16)
	_region.add_theme_color_override("font_color", Color("F3E3B8"))
	_region.add_theme_color_override("font_outline_color", OUTLINE)
	_region.add_theme_constant_override("outline_size", 1)
	_region.position = Vector2(0, Y)
	_region.size = Vector2(480, 20)
	_region.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_region.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_region)
	_rule = ColorRect.new()
	_rule.color = GOLD
	_rule.position = Vector2(240, Y + 21)
	_rule.size = Vector2(0, 1)
	_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rule)
	_area = Label.new()
	_area.add_theme_font_size_override("font_size", 8)
	_area.add_theme_color_override("font_color", CREAM)
	_area.position = Vector2(0, Y + 24)
	_area.size = Vector2(480, 12)
	_area.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_area)
	get_node("/root/Events").zone_entered.connect(_on_zone)


## The region of an area id ("" for the hub, Kelir memories and anything unlisted).
static func region_of(zone_id: String) -> String:
	if zone_id == "desa_purwa":
		return zone_id
	var prefix := zone_id.get_slice("_", 0)
	return prefix if zone_id.contains("_") and REGIONS.has(prefix) else ""


func _on_zone(zone_id: String) -> void:
	var game := get_node("/root/Game")
	if game.has_method("in_memory") and game.in_memory():
		return
	var region := region_of(zone_id)
	if region == "":
		return
	var flag := "seen_area_" + zone_id
	var first: bool = not game.has_flag(flag)
	if first:
		game.set_flag(flag)
	if region != _last_region or first:
		_last_region = region
		show_card(zone_id, region)
	_last_region = region


func show_card(zone_id: String, region: String) -> void:
	_region.text = String(REGIONS[region]).to_upper()
	var key := "AREA_" + zone_id.to_upper()
	var name_ := tr(key) if tr(key) != key else (zone_id.trim_prefix(region + "_").replace("_", " ").capitalize() if zone_id != region else "")
	_area.text = name_
	if _tween:
		_tween.kill()
	visible = true
	modulate.a = 0.0
	_rule.size.x = 0.0
	_rule.position.x = 240.0
	_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_parallel(true)
	_tween.tween_property(self, "modulate:a", 1.0, FADE_IN)
	_tween.tween_property(_rule, "size:x", RULE_W, FADE_IN).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(_rule, "position:x", 240.0 - RULE_W / 2.0, FADE_IN).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.chain().tween_interval(HOLD)
	_tween.chain().tween_property(self, "modulate:a", 0.0, FADE_OUT)
	_tween.chain().tween_callback(func() -> void: visible = false)
