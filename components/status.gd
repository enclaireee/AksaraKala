class_name Status extends Node

signal started(type: Type)
signal ended(type: Type)

enum Type { BURN, SLOW, BOUND, CURSE }

@export var tuning: CombatTuning = preload("res://data/combat_tuning.tres")
@export var health: Health
## Tinted via self_modulate: enemies already use modulate for telegraphs and death grey.
@export var tint_target: CanvasItem

const COLORS := {
	Type.BURN: Color(1, 0.6, 0.3),
	Type.BOUND: Color(1, 0.95, 0.55),  # ponytail: script ring art comes later
	Type.SLOW: Color(0.55, 0.7, 1),
	Type.CURSE: Color(0.75, 0.5, 1),
}

var _left := {}  # Type -> seconds remaining
var _slow_mult := 1.0
var _burn_total := 0
var _burn_len := 1.0
var _burn_elapsed := 0.0
var _burn_ticks_done := 0
var _flicker := 0.0


func apply(type: Type, seconds := -1.0, value := 0.0) -> void:
	if seconds < 0.0:
		seconds = _default_time(type)
	var was := _left.has(type)
	_left[type] = seconds
	if type == Type.SLOW:
		_slow_mult = value if value > 0.0 else tuning.slow_mult
	elif type == Type.BURN:
		_burn_total = roundi(value * tuning.burn_share)
		if value > 0.0:
			_burn_total = maxi(1, _burn_total)
		_burn_len = seconds
		_burn_elapsed = 0.0
		_burn_ticks_done = 0
	if not was:
		started.emit(type)


func has(type: Type) -> bool:
	return _left.has(type)


func clear(type: Type) -> void:
	if _left.erase(type):
		ended.emit(type)
		_update_tint()


func speed_mult() -> float:
	if has(Type.BOUND):
		return 0.0
	return _slow_mult if has(Type.SLOW) else 1.0


func _default_time(type: Type) -> float:
	match type:
		Type.BURN: return tuning.burn_time
		Type.SLOW: return tuning.slow_time
		Type.BOUND: return tuning.bound_time
	return tuning.curse_time


func _physics_process(delta: float) -> void:
	if _left.is_empty():
		return
	_flicker += delta
	if has(Type.BURN):
		_burn_elapsed += delta
		_burn_tick(_burn_elapsed >= _burn_len or _left[Type.BURN] <= delta)   # never let the timer end before the last tick
	for t in _left.keys():
		_left[t] -= delta
		if _left[t] <= 0.0:
			clear(t)
	_update_tint()


# Ticks are cumulative so they always sum to _burn_total; the last lands at burn end.
func _burn_tick(finished: bool) -> void:
	var due := _burn_ticks_done
	if finished:
		due = tuning.burn_ticks
	else:
		due = mini(tuning.burn_ticks, int(_burn_elapsed / _burn_len * tuning.burn_ticks))
	while _burn_ticks_done < due:
		_burn_ticks_done += 1
		var amount := _burn_total * _burn_ticks_done / tuning.burn_ticks - _burn_total * (_burn_ticks_done - 1) / tuning.burn_ticks
		if health and amount > 0:
			health.take_damage(amount, null, true)


func _update_tint() -> void:
	if tint_target == null:
		return
	var c := Color.WHITE
	if has(Type.BURN):
		c = COLORS[Type.BURN] if int(_flicker / 0.08) % 2 == 0 else Color.WHITE
	else:
		for t in [Type.BOUND, Type.SLOW, Type.CURSE]:
			if has(t):
				c = COLORS[t]
				break
	tint_target.self_modulate = c
