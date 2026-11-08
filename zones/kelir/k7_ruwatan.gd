extends "res://zones/kelir/k0_ruwatan.gd"
## K7, the finale ruwatan behind Semar's kelir (gua_kala.md "Memory k7_ruwatan").
## You take the dalang's place with casting enabled (`allow_cast = true`).


func _init() -> void:
	allow_cast = true


func _ready() -> void:
	super()
	var l := lamps()
	for i in l.size():
		l[i].line_key = "MEM_K7_RUWATAN_%d" % i if i > 0 else ""
