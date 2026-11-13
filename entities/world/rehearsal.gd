extends Node2D
## Rehearsal target (quests.md 10, boss fights v7): a small thing outside a boss door that answers the fight's trick.
## Cast `glyph` within `radius` px and it reacts and runs `clue:<id>` (flag clue_<id>, Events.clue_examined), so a
## quest sub-goal `clue_examined:<id>` and the objective arrow work with no new trigger kind.
## glyph "" = any spell. The gold ring with the glyph shows until it is done once.

@export var id := ""
@export var glyph := ""
@export var boss := ""          # the boss this prepares for (its unique_id): answering it shows that boss's "Cara melawan" codex line,
                                # and beating the boss unrehearsed counts it as done, so a blocking quest sub-goal cannot strand
@export var cond := ""          # hidden and deaf while Game.check(cond) is false, as clue.gd
@export var radius := 64.0      # TUNE
@export var look := "post"      # post, mirror, shade, mist, lock, lesung: world_fx/rehearse_<look>.png

var _mark: Node2D
var _t := 0.0
var _hit := 0.0


func _ready() -> void:
	add_to_group("rehearsal")
	var game := get_node("/root/Game")
	game.changed.connect(_apply)
	var ev := get_node("/root/Events")
	ev.spell_cast.connect(_on_cast)
	ev.boss_defeated.connect(_on_boss_defeated)
	_apply()


func _apply() -> void:
	var game := get_node("/root/Game")
	visible = game.check(cond)
	var want: bool = visible and not game.has_flag("clue_" + id)
	if want and _mark == null:
		_mark = BossKit.Mark.new()
		_mark.glyph = GlyphData.by_id(glyph) if glyph != "" else null
		_mark.radius = 14.0
		_mark.position = Vector2(0, -8)
		_mark.z_index = 50
		add_child(_mark)
	elif not want and _mark != null:
		_mark.queue_free()
		_mark = null


func _on_cast(glyph_id: String, _score: float) -> void:
	var p := get_tree().get_first_node_in_group("player") as Node2D
	if not visible or p == null or (glyph != "" and glyph_id != glyph) or p.global_position.distance_to(global_position) > radius:
		return
	_hit = 0.6
	Snd.play("boss_finish", -8.0, 1.3)
	BossKit.ring_fx(self, global_position, 40.0, 0.5, BossKit.GOLD)
	BossKit.sparks(self, global_position + Vector2(0, -10), BossKit.GOLD, 16, 70.0, 0.6)
	_done()


## Runs `clue:<id>` once. Later casts still react (sound, sparks) but record nothing.
func _done() -> void:
	var game := get_node("/root/Game")
	if game.has_flag("clue_" + id):
		return
	if boss != "":
		get_node("/root/Events").weakness_triggered.emit(boss)
	game.run("clue:" + id)


func _on_boss_defeated(boss_id: String) -> void:
	if boss != "" and boss_id == boss:
		_done()


func _process(delta: float) -> void:
	_t += delta
	_hit = maxf(0.0, _hit - delta)
	queue_redraw()


func _draw() -> void:
	var tex := _sheet()
	if tex == null:
		return
	var done: bool = _mark == null
	var f := 2 if done or _hit > 0.3 else int(_t * 2.0) % 2   # 0-1 idle, 2 answered
	var a := 1.0
	if done and (look == "shade" or look == "mist"):
		a = 0.8
	draw_texture_rect_region(tex, Rect2(-12, -30, 24, 32), Rect2(f * 24, 0, 24, 32), Color(1, 1, 1, a))


## tools/gen_world_fx.py rehearse_<look>.png: 3 frames of 24x32, feet on row 30. Unknown look = the post.
func _sheet() -> Texture2D:
	var k := look if look in ["post", "mirror", "shade", "mist", "lock", "lesung"] else "post"
	var path := "res://assets/art/world_fx/rehearse_%s.png" % k
	return load(path) if ResourceLoader.exists(path) else null
