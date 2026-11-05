class_name CastController extends Node
## Hold cast, draw an aksara, release to cast (spells.md 1, 4, 9; combat.md 6).
## The only code that sets Engine.time_scale. Every exit goes through _exit_cast_mode().

signal blocked   # cast pressed without enough sakti or inside the lockout
signal read(result: Dictionary)   # every recognized stroke: {glyph, score, power} (the sanggar shows it)

@export var overlay: CastOverlay
@export var practice := false   # sanggar: no sakti gate, no cost (spells.md 9)

@onready var player: Player = get_parent()

var drawing := false
var points := PackedVector2Array()
var aim := Vector2.RIGHT
var _started := 0       # real ms
var _locked_until := 0  # real ms


func _ready() -> void:
	($"../Health" as Health).died.connect(cancel)   # children are ready before the player's @onready vars


func _exit_tree() -> void:
	_exit_cast_mode()


func _unhandled_input(event: InputEvent) -> void:
	if not drawing:
		if event.is_action_pressed("cast"):
			start()
		return
	if event is InputEventMouseMotion:
		points.append(event.position)   # viewport coordinates (spells.md 9: HiDPI)
		overlay.add_point(event.position)
	elif event.is_action_released("cast"):
		release()
	elif event.is_action_pressed("pause") or event.is_action_pressed("menu"):
		cancel()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("dodge"):
		cancel()   # not handled: the player buffers the dodge and rolls
	elif event.is_action("attack"):
		get_viewport().set_input_as_handled()   # no swings while drawing


func _process(_delta: float) -> void:
	if drawing and Time.get_ticks_msec() - _started > player.tuning.cast_draw_limit * 1000.0:
		cancel()


func start() -> bool:
	var t := player.tuning
	if player.state == Player.State.DEAD:
		return false
	if not practice and (Time.get_ticks_msec() < _locked_until or player.sakti.value < _min_sakti()):
		blocked.emit()
		return false
	drawing = true
	points.clear()
	aim = player.aim_dir   # ASSUMED: the spell flies where the player aimed when the cast began
	_started = Time.get_ticks_msec()
	Engine.time_scale = t.cast_time_scale
	overlay.begin()
	return true


## Mage and Rogue start at 1 less: their cheapest spell costs 14 (spells.md 9). ASSUMED: min - 1.
func _min_sakti() -> float:
	var c := SpellUtil.class_id(player)
	return player.tuning.cast_min_sakti - (1.0 if c == "mage" or c == "rogue" else 0.0)


func release() -> void:
	if not drawing:
		return
	if Recognizer.path_length(points) < player.tuning.cast_min_length:
		cancel()   # a click or a twitch: no cost (spells.md 9)
		return
	# /root/Game, not the Game identifier: -s test scripts compile this before autoloads exist
	var r := Recognizer.classify(points, get_node("/root/Game").learned_glyphs())
	read.emit(r)
	var glyph: GlyphData = r.glyph
	var power: float = r.power
	var spell := SpellData.for_glyph(glyph.id) if glyph and power > 0.0 else null
	if spell == null:
		_fizzle("")
	elif not practice and not player.sakti.spend(SpellUtil.cost(player, spell)):
		_fizzle("needs %d" % ceili(SpellUtil.cost(player, spell)))
	else:
		_exit_cast_mode()
		overlay.finish(true, "%s · %s" % [glyph.latin.capitalize(), spell.title])
		_spawn(spell, power)


## Cancels and fizzles both lock casting out for a moment, so slow-mo cannot be spammed (spells.md 9).
func cancel() -> void:
	if drawing:
		_lock()
		overlay.cancel()


func _fizzle(text: String) -> void:
	_lock()
	overlay.finish(false, text)


func _lock() -> void:
	_exit_cast_mode()
	_locked_until = Time.get_ticks_msec() + int(player.tuning.cast_lockout * 1000.0)


func _spawn(spell: SpellData, power: float) -> void:
	var s: Node2D = spell.scene.instantiate()
	s.caster = player
	s.data = spell
	s.direction = aim
	s.power = power
	s.global_position = player.global_position
	player.get_parent().add_child(s)


func _exit_cast_mode() -> void:
	drawing = false
	Engine.time_scale = 1.0
