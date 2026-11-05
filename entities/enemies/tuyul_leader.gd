class_name TuyulLeader extends Chaser
## SQ-M3 elite: a tougher Tuyul. Stats are the balance.md elite row at tier 0 (600 HP, Dmg 14, Ilmu 60), TUNE.
## Inert until quest sq_m3 is at step 2.

var active := true


func _ready() -> void:
	super()
	if is_queued_for_deletion():
		return
	var g := EliteGuard.new()
	g.cond = "step:sq_m3=2"
	add_child(g)
