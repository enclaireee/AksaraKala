class_name BanaspatiElite extends Banaspati
## SQ-T2 elite: a bigger, faster Banaspati (scene tuning) whose trail lasts twice as long. Weakness Ward, as Banaspati.
## Inert until SQ-T2 is at its 3rd step (index 2).

var active := true


func _init() -> void:
	trail_life = 6.0   # TUNE: twice the base


func _ready() -> void:
	super()
	if is_queued_for_deletion():
		return
	var g := EliteGuard.new()
	g.cond = "step:sq_t2=2"
	add_child(g)
