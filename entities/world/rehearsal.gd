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
@export var look := "post"      # post, mirror, shade, mist, lock, lesung: drawn in code. ponytail: no sprite sheet

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
	var ink := Color(0.09, 0.07, 0.16)
	var k := _hit / 0.6   # 1 right after the answer
	var done: bool = _mark == null
	match look:
		"mirror":   # a standing mirror; the false reflection breaks
			draw_rect(Rect2(-6, -20, 12, 20), ink)
			draw_rect(Rect2(-5, -19, 10, 17), Color(0.55, 0.75, 0.85).lerp(Color.WHITE, k))
			if done:
				draw_line(Vector2(-4, -17), Vector2(3, -6), ink, 1.0)
				draw_line(Vector2(0, -12), Vector2(4, -15), ink, 1.0)
			else:
				draw_rect(Rect2(-2, -15, 4, 9), Color(0.85, 0.7, 0.3, 0.6 + 0.3 * sin(_t * 3.0)))
		"shade", "mist":   # a shape of mist; fades when answered
			var a := (0.15 if done else 0.55) + 0.1 * sin(_t * 2.0)
			var col := Color(0.6, 0.5, 0.8, a) if look == "shade" else Color(0.8, 0.85, 0.9, a)
			for i in 4:
				draw_circle(Vector2(sin(_t * 1.3 + i * 1.7) * 5.0, -8.0 - i * 3.0), 7.0 - i, col)
		"lock":   # a stone seal
			draw_circle(Vector2(0, -9), 10.0, ink)
			draw_circle(Vector2(0, -9), 9.0, Color(0.42, 0.36, 0.5).lerp(BossKit.GOLD, maxf(k, 0.5 if done else 0.0)))
			draw_arc(Vector2(0, -9), 5.0, 0.0, TAU, 16, ink, 1.0)
		"lesung":   # rice mortar and pestle
			draw_rect(Rect2(-9, -7, 18, 8), ink)
			draw_rect(Rect2(-8, -6, 16, 6), Color(0.48, 0.33, 0.2))
			draw_rect(Rect2(-1, -20 + 6.0 * k, 3, 14), Color(0.7, 0.55, 0.35))
		_:   # a post with a cloth
			draw_rect(Rect2(-2, -22, 4, 22), ink)
			draw_rect(Rect2(-1, -21, 2, 20), Color(0.48, 0.33, 0.2))
			draw_rect(Rect2(1, -20, 7.0 + 2.0 * sin(_t * 4.0), 6), Color(0.9, 0.9, 0.85).lerp(BossKit.GOLD, k))
