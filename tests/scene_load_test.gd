## Every generated zone, Kelir memory and enemy scene loads and instantiates (gen_zones.py, gen_memories.py).
extends SceneTree
func _init() -> void:
	var bad := 0
	for d in ["res://zones/kelir/", "res://zones/", "res://entities/enemies/"]:
		for f in DirAccess.get_files_at(d):
			if not f.ends_with(".tscn"):
				continue
			var p: PackedScene = load(d + f)
			var n: Node = p.instantiate() if p else null
			if n == null:
				print("FAIL load ", d + f); bad += 1
			else:
				n.free()

	quit(1 if bad else 0)
